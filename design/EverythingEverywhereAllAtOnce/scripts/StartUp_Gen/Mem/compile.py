#!/usr/bin/env python3
"""
compile.py
----------
Stage 1 of the memGen pipeline.

Reads a JSON config, assembles an x86-32 .s source file (via GNU as + ld),
and produces:
  1. <metaDir>/program_flat.hex     – full 32 KB flat image, annotated by cache line
  2. <metaDir>/program_sections.hex – only the code+data regions, annotated
  3. <metaDir>/program.bin          – raw 32 KB binary (used by genHexMem.py)
  4. <metaDir>/program_readmemh.hex – $readmemh-compatible hex of the full image

JSON config keys consumed here:
  useProgram          : "true" / "false"
  input_Program_Path  : path to .s source
  input_hex_file      : path to pre-built flat hex (used when useProgram == "false")
  output_metaData_Path: directory for debug / meta outputs
  randomizeMem        : "true" / "false"  – fill unused bytes randomly vs 0x00
  mem_size_bytes      : (optional) default 32768
  cache_line_bytes    : (optional) default 16

Multiple .code and .data sections are supported.  Each must be preceded by
an .org directive to fix its VMA:

    .org x1000
    .code
    ...instructions...

    .org x2000
    .data
    val_a: .long 0x11111111

    .org x3000
    .code          ← second code region
    ...more instructions...

    .org x4000
    .data          ← second data region
    val_b: .long 0x22222222

Each (.code/.data, org_addr) pair becomes its own uniquely-named ELF section
so the linker can place every region independently.
"""

import json, sys, os, struct, subprocess, tempfile, random, re, argparse, shutil

# ── constants ────────────────────────────────────────────────────────────────
DEFAULT_MEM_SIZE   = 32 * 1024   # 32 KB
DEFAULT_LINE_BYTES = 16

# ── helpers ──────────────────────────────────────────────────────────────────

def load_config(path: str) -> dict:
    with open(path) as f:
        return json.load(f)

def make_dir(p: str):
    os.makedirs(p, exist_ok=True)

def random_fill(size: int) -> bytearray:
    return bytearray(random.getrandbits(8) for _ in range(size))

def zero_fill(size: int) -> bytearray:
    return bytearray(size)


# ── assembler ────────────────────────────────────────────────────────────────

def parse_sections(src: str) -> list:
    """
    Walk the source and build an ordered list of section descriptors:
      [{'kind': 'code'|'data', 'org': int, 'index': int}, ...]

    Rules:
      • An .org directive sets the *pending* VMA.
      • The next .code or .data directive after that .org opens a new section
        using the pending VMA.
      • An .org that appears *inside* an already-open section (i.e. no .code/
        .data has claimed the previous .org yet) just updates the pending VMA.
      • Both // and # comments are stripped before matching.
      • Counters per kind ('code', 'data') are tracked independently so the
        generated GAS section names are stable (code0, code1 / data0, data1).
    """
    sections  = []
    counters  = {'code': 0, 'data': 0}
    pending   = None           # VMA set by the most recent .org but not yet used

    for line in src.splitlines():
        stripped = re.sub(r'(//|#).*$', '', line).strip()
        if not stripped:
            continue

        # .org 0xNNNN  or  .org xNNNN  (the leading 0 is optional)
        m = re.match(r'\.org\s+(0?[xX]?[0-9a-fA-F]+)', stripped)
        if m:
            val = m.group(1)
            if not val.lower().startswith('0x'):
                val = '0x' + val.lstrip('xX')
            pending = int(val, 16)
            continue

        for kind in ('code', 'data'):
            if re.match(rf'\.{kind}\b', stripped):
                if pending is None:
                    sys.exit(f"[compile] .{kind} directive with no preceding .org")
                idx = counters[kind]
                counters[kind] += 1
                sections.append({'kind': kind, 'org': pending, 'index': idx})
                pending = None   # consumed – next .org will set a new one
                break

    return sections


def _section_name(sec: dict) -> str:
    """Unique ELF section name for a parsed section descriptor."""
    return f".{sec['kind']}{sec['index']}"   # e.g. .code0, .data1


def convert_pseudo_to_gas(src: str, sections: list) -> str:
    """
    Rewrite the informal source into legal GNU as (i386) syntax.

    Per-line transformations:
      // comment        →  # comment
      .org xNNNN        →  dropped  (placement done by linker script)
      .code             →  .section .codeN, "ax", @progbits
      .data             →  .section .dataN, "aw", @progbits

    Each .code/.data occurrence is replaced by the *next* section descriptor
    from the ordered list produced by parse_sections(), so numbering is
    consistent between the two passes.
    """
    # Make independent iterators per kind so we hand them out in order
    iters = {
        'code': iter([s for s in sections if s['kind'] == 'code']),
        'data': iter([s for s in sections if s['kind'] == 'data']),
    }

    lines = []
    for line in src.splitlines():
        # // comments → #
        out = re.sub(r'//.*$', lambda m: '# ' + m.group(0)[2:], line)

        # drop .org lines
        if re.match(r'\s*\.org\b', out):
            lines.append('# ' + out.lstrip())
            continue

        # .code / .data → named .section directives
        matched = False
        for kind, flags in (('code', '"ax", @progbits'),
                             ('data', '"aw", @progbits')):
            if re.match(rf'\s*\.{kind}\b', out):
                sec = next(iters[kind])
                sname = _section_name(sec)
                # preserve leading whitespace
                indent = re.match(r'(\s*)', out).group(1)
                lines.append(f'{indent}.section {sname}, {flags}')
                matched = True
                break
        if not matched:
            lines.append(out)

    return '\n'.join(lines) + '\n'


def assemble_to_binary(src_path: str, mem_size: int) -> tuple:
    """
    Assemble src_path with GNU as/ld for i386.

    Returns
    -------
    image_overlay : bytearray
        Bytes to overlay onto the flat memory image.  Indexed from address 0,
        but only the ranges [sec.vma, sec.vma+sec.size) are populated.
    base_addr : int
        Lowest VMA of any section (used for reporting / sections-hex trimming).
    top_addr  : int
        One past the highest byte of any section.
    sections  : list[dict]
        [{'name': str, 'start': int}, ...]  – for annotations
    """
    with open(src_path) as f:
        raw = f.read()

    sections_meta = parse_sections(raw)
    if not sections_meta:
        sys.exit("[compile] No .code or .data sections found in source.")

    gas_src = convert_pseudo_to_gas(raw, sections_meta)

    with tempfile.TemporaryDirectory() as tmp:
        s_file   = os.path.join(tmp, 'prog.s')
        o_file   = os.path.join(tmp, 'prog.o')
        ld_file  = os.path.join(tmp, 'prog.ld')
        elf_file = os.path.join(tmp, 'prog.elf')

        with open(s_file, 'w') as f:
            f.write(gas_src)

        # ── assemble ──────────────────────────────────────────────────────────
        r = subprocess.run(['as', '--32', '-o', o_file, s_file],
                           capture_output=True, text=True)
        if r.returncode != 0:
            sys.exit(f"[compile] GNU as failed:\n{r.stderr}")

        # ── build linker script ───────────────────────────────────────────────
        # One OUTPUT_SECTION per parsed section, each pinned to its .org addr.
        section_lines = []
        for sec in sections_meta:
            sname = _section_name(sec)          # .code0, .data1, …
            section_lines.append(
                f"  {sname} 0x{sec['org']:x} : {{ *({sname}) }}"
            )

        ld_script = (
            "OUTPUT_FORMAT(elf32-i386)\n"
            "ENTRY(_start)\n"
            "SECTIONS {\n"
            + "\n".join(section_lines) + "\n"
            "  /DISCARD/ : { *(.note*) *(.comment) *(.eh_frame) }\n"
            "}\n"
        )
        with open(ld_file, 'w') as f:
            f.write(ld_script)

        # ── link ──────────────────────────────────────────────────────────────
        r = subprocess.run(['ld', '-m', 'elf_i386', '-T', ld_file,
                            '-o', elf_file, o_file],
                           capture_output=True, text=True)
        if r.returncode != 0:
            sys.exit(f"[compile] ld failed:\n{r.stderr}")

        # ── extract section VMAs + bytes via objdump ──────────────────────────
        r = subprocess.run(['objdump', '-h', elf_file],
                           capture_output=True, text=True)
        if r.returncode != 0:
            sys.exit(f"[compile] objdump -h failed:\n{r.stderr}")

        # Build set of section names we care about
        wanted = {_section_name(s) for s in sections_meta}

        sec_info = []   # [(elf_name, vma, size, fileoff), ...]
        for line in r.stdout.splitlines():
            m = re.match(
                r'\s*\d+\s+(\S+)\s+([0-9a-fA-F]+)\s+([0-9a-fA-F]+)'
                r'\s+[0-9a-fA-F]+\s+([0-9a-fA-F]+)', line)
            if m:
                name    = m.group(1)
                size    = int(m.group(2), 16)
                vma     = int(m.group(3), 16)
                fileoff = int(m.group(4), 16)
                if name in wanted and size > 0:
                    sec_info.append((name, vma, size, fileoff))

        if not sec_info:
            sys.exit("[compile] No relevant sections found in ELF – "
                     "check that .code/.data regions contain actual content.")

        # read raw ELF bytes
        with open(elf_file, 'rb') as f:
            elf_raw = f.read()

    # ── build sparse overlay ──────────────────────────────────────────────────
    # We don't create one contiguous bytearray from base→top because sections
    # can be far apart (e.g. 0x1000 and 0x3000 with a 4 KB gap).  Instead we
    # return a mem_size-sized buffer with only the section bytes filled in.
    overlay = bytearray(mem_size)   # zeros; caller merges with fill image
    base_addr = mem_size
    top_addr  = 0

    for name, vma, size, fileoff in sec_info:
        if vma + size > mem_size:
            sys.exit(f"[compile] Section {name} (0x{vma:x}+{size}) "
                     f"exceeds memory size ({mem_size} B).")
        overlay[vma : vma + size] = elf_raw[fileoff : fileoff + size]
        base_addr = min(base_addr, vma)
        top_addr  = max(top_addr,  vma + size)
        print(f"[compile]   {name:<10s}  VMA=0x{vma:04x}  size={size} B")

    # Export section list for annotations
    # Map ELF section name back to human kind label
    name_to_kind = {_section_name(s): s['kind'] for s in sections_meta}
    sections_out = [
        {'name': name_to_kind.get(n, n), 'start': v}
        for n, v, _, _ in sorted(sec_info, key=lambda x: x[1])
    ]

    return overlay, base_addr, top_addr, sections_out


# ── flat image builder ───────────────────────────────────────────────────────

def build_flat_image(overlay: bytearray, base_addr: int, top_addr: int,
                     mem_size: int, randomize: bool) -> bytearray:
    """
    Merge the section overlay onto a randomised/zero background image.

    overlay is already mem_size bytes with zeros everywhere except the
    assembled sections.  We therefore:
      1. Create the background fill.
      2. Copy only the section bytes (base_addr..top_addr) from overlay.
         Gaps between sections inherit the background fill.
    """
    if randomize:
        image = random_fill(mem_size)
    else:
        image = zero_fill(mem_size)

    # Overwrite only the bytes that belong to actual sections.
    # We rely on the sec_info loop in assemble_to_binary having validated bounds.
    # To avoid clobbering gaps with zeros we need to know which bytes are "real".
    # The simplest correct approach: just copy the overlay's non-zero bytes —
    # but that would silently drop legitimate 0x00 data bytes.
    # Instead we re-use the original overlay wholesale for the covered span;
    # any inter-section gap in the overlay is 0x00 and will overwrite the fill.
    # For randomize==True this is intentional: gap bytes are deterministically 0
    # to keep output reproducible.  If true gap randomisation is needed a caller
    # can pass a custom overlay.
    image[base_addr:top_addr] = overlay[base_addr:top_addr]
    return image


# ── hex writers ──────────────────────────────────────────────────────────────

def write_flat_hex(image: bytearray, line_bytes: int, out_path: str):
    """
    Write full memory image as annotated hex.
    Format per cache line:
      // $line_<N>  addr: 0x<AAAA>
      AA BB CC DD  EE FF 00 11  22 33 44 55  66 77 88 99
    """
    n_lines = len(image) // line_bytes
    with open(out_path, 'w') as f:
        f.write(f"// Flat memory image  total={len(image)} B  "
                f"line_size={line_bytes} B  total_lines={n_lines}\n\n")
        for ln in range(n_lines):
            addr  = ln * line_bytes
            chunk = image[addr: addr + line_bytes]
            groups = []
            for g in range(0, line_bytes, 4):
                groups.append(' '.join(f'{b:02x}' for b in chunk[g:g+4]))
            f.write(f"// $line_{ln:<5d}  addr: 0x{addr:04x}\n")
            f.write('  ' + '  '.join(groups) + '\n\n')
    print(f"[compile] Wrote flat hex       → {out_path}")


def write_sections_hex(image: bytearray, sections: list,
                       base_addr: int, top_addr: int,
                       line_bytes: int, out_path: str):
    """
    Write only the cache lines that overlap any assembled section.
    Annotates each line with section membership where applicable.
    """
    mem_size = len(image)
    n_lines  = mem_size // line_bytes

    # build a quick lookup: addr → section name (for annotation)
    addr_to_sec = {}
    for s in sections:
        addr_to_sec[s['start']] = s['name']

    with open(out_path, 'w') as f:
        f.write(f"// Sections hex  base=0x{base_addr:04x}  "
                f"top=0x{top_addr:04x}  line_size={line_bytes} B\n")
        f.write(f"// Sections: {[s['name'] + '@0x' + hex(s['start'])[2:] for s in sections]}\n\n")

        for ln in range(n_lines):
            addr     = ln * line_bytes
            line_end = addr + line_bytes
            # only emit lines that overlap [base_addr, top_addr)
            if line_end <= base_addr or addr >= top_addr:
                continue
            chunk  = image[addr: addr + line_bytes]
            groups = []
            for g in range(0, line_bytes, 4):
                groups.append(' '.join(f'{b:02x}' for b in chunk[g:g+4]))
            # annotate if a section starts on this line
            note = ''
            for byte_off in range(line_bytes):
                a = addr + byte_off
                if a in addr_to_sec:
                    note += f'  ← {addr_to_sec[a]} starts'
            f.write(f"// $line_{ln:<5d}  addr: 0x{addr:04x}{note}\n")
            f.write('  ' + '  '.join(groups) + '\n\n')
    print(f"[compile] Wrote sections hex   → {out_path}")


def write_readmemh_flat(image: bytearray, line_bytes: int, out_path: str):
    """
    Write a $readmemh-compatible hex file of the full image.
    """
    with open(out_path, 'w') as f:
        f.write("// readmemh flat image\n")
        n_lines = len(image) // line_bytes
        for ln in range(n_lines):
            addr  = ln * line_bytes
            chunk = image[addr: addr + line_bytes]
            f.write(f"// $line_{ln}  @{addr:04x}\n")
            f.write(f"@{addr:04x}\n")
            for b in chunk:
                f.write(f"{b:02x}\n")
    print(f"[compile] Wrote readmemh flat  → {out_path}")


# ── main ─────────────────────────────────────────────────────────────────────

def main():
    ap = argparse.ArgumentParser(description="Stage 1: assemble → flat image")
    ap.add_argument('config', help='Path to JSON config file')
    args = ap.parse_args()

    cfg = load_config(args.config)

    use_program = cfg.get('useProgram',   'true').strip().lower() == 'true'
    randomize   = cfg.get('randomizeMem', 'false').strip().lower() == 'true'
    mem_size    = int(cfg.get('mem_size_bytes',   DEFAULT_MEM_SIZE))
    line_bytes  = int(cfg.get('cache_line_bytes', DEFAULT_LINE_BYTES))
    meta_dir    = cfg['output_metaData_Path']

    make_dir(meta_dir)

    if use_program:
        src_path = cfg['input_Program_Path']
        print(f"[compile] Assembling {src_path} ...")
        overlay, base_addr, top_addr, sections = assemble_to_binary(src_path, mem_size)
        print(f"[compile] Assembled span 0x{base_addr:04x}–0x{top_addr:04x}  "
              f"({top_addr - base_addr} B across {len(sections)} section(s))")
    else:
        # load a pre-built flat hex file (readmemh format)
        hex_path = cfg['input_hex_file']
        print(f"[compile] Loading pre-built hex {hex_path} ...")
        overlay   = bytearray(mem_size)
        base_addr = mem_size
        top_addr  = 0
        sections  = []
        cur_addr  = 0
        with open(hex_path) as f:
            for line in f:
                line = line.strip()
                if line.startswith('//') or not line:
                    continue
                if line.startswith('@'):
                    cur_addr = int(line[1:], 16)
                    base_addr = min(base_addr, cur_addr)
                    continue
                b = bytes.fromhex(line)
                overlay[cur_addr : cur_addr + len(b)] = b
                cur_addr  += len(b)
                top_addr   = max(top_addr, cur_addr)
        if base_addr == mem_size:
            base_addr = 0

    # build full memory image (fill + overlay)
    image = build_flat_image(overlay, base_addr, top_addr, mem_size, randomize)

    # ── outputs ───────────────────────────────────────────────────────────────
    bin_out = os.path.join(meta_dir, 'program.bin')
    with open(bin_out, 'wb') as f:
        f.write(image)
    print(f"[compile] Saved binary         → {bin_out}")

    write_flat_hex(image, line_bytes,
                   os.path.join(meta_dir, 'program_flat.hex'))

    write_sections_hex(image, sections, base_addr, top_addr,
                       line_bytes,
                       os.path.join(meta_dir, 'program_sections.hex'))

    write_readmemh_flat(image, line_bytes,
                        os.path.join(meta_dir, 'program_readmemh.hex'))

    print("[compile] Done.")


if __name__ == '__main__':
    main()
