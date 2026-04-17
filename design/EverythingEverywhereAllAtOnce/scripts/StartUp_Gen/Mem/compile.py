#!/usr/bin/env python3
"""
compile.py
----------
Stage 1 of the memGen pipeline.

Reads a JSON config, assembles an x86-32 .s source file (via GNU as + ld),
and produces:
  1. <metaDir>/program_flat.hex         – full 32 KB flat image, annotated by cache line
  2. <metaDir>/program_sections.hex     – only the code+data regions, annotated
  3. <metaDir>/program.bin              – raw 32 KB binary (used by genHexMem.py)
  4. <metaDir>/program_readmemh.hex     – $readmemh-compatible hex of the full image
  5. <metaDir>/program_instructions.txt – every instruction with EIP and hex encoding

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
    elf_path_out : str
        Path to a temporary ELF file (caller must clean up).  Used by the
        instruction-listing pass.  Caller is responsible for deleting it.
    """
    with open(src_path) as f:
        raw = f.read()

    sections_meta = parse_sections(raw)
    if not sections_meta:
        sys.exit("[compile] No .code or .data sections found in source.")

    gas_src = convert_pseudo_to_gas(raw, sections_meta)

    # Use a persistent temp dir so the ELF survives for the disassembly pass.
    tmp = tempfile.mkdtemp()

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
        shutil.rmtree(tmp, ignore_errors=True)
        sys.exit(f"[compile] GNU as failed:\n{r.stderr}")

    # ── build linker script ───────────────────────────────────────────────
    section_lines = []
    for sec in sections_meta:
        sname = _section_name(sec)
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
        shutil.rmtree(tmp, ignore_errors=True)
        sys.exit(f"[compile] ld failed:\n{r.stderr}")

    # ── extract section VMAs + bytes via objdump ──────────────────────────
    r = subprocess.run(['objdump', '-h', elf_file],
                       capture_output=True, text=True)
    if r.returncode != 0:
        shutil.rmtree(tmp, ignore_errors=True)
        sys.exit(f"[compile] objdump -h failed:\n{r.stderr}")

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
        shutil.rmtree(tmp, ignore_errors=True)
        sys.exit("[compile] No relevant sections found in ELF – "
                 "check that .code/.data regions contain actual content.")

    with open(elf_file, 'rb') as f:
        elf_raw = f.read()

    # ── build sparse overlay ──────────────────────────────────────────────
    overlay   = bytearray(mem_size)
    base_addr = mem_size
    top_addr  = 0

    for name, vma, size, fileoff in sec_info:
        if vma + size > mem_size:
            shutil.rmtree(tmp, ignore_errors=True)
            sys.exit(f"[compile] Section {name} (0x{vma:x}+{size}) "
                     f"exceeds memory size ({mem_size} B).")
        overlay[vma : vma + size] = elf_raw[fileoff : fileoff + size]
        base_addr = min(base_addr, vma)
        top_addr  = max(top_addr,  vma + size)
        print(f"[compile]   {name:<10s}  VMA=0x{vma:04x}  size={size} B")

    name_to_kind = {_section_name(s): s['kind'] for s in sections_meta}
    sections_out = [
        {'name': name_to_kind.get(n, n), 'start': v}
        for n, v, _, _ in sorted(sec_info, key=lambda x: x[1])
    ]

    return overlay, base_addr, top_addr, sections_out, elf_file, tmp


# ── flat image builder ───────────────────────────────────────────────────────

def build_flat_image(overlay: bytearray, base_addr: int, top_addr: int,
                     mem_size: int, randomize: bool) -> bytearray:
    """
    Merge the section overlay onto a randomised/zero background image.
    """
    if randomize:
        image = random_fill(mem_size)
    else:
        image = zero_fill(mem_size)

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
            if line_end <= base_addr or addr >= top_addr:
                continue
            chunk  = image[addr: addr + line_bytes]
            groups = []
            for g in range(0, line_bytes, 4):
                groups.append(' '.join(f'{b:02x}' for b in chunk[g:g+4]))
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


# ── instruction listing ───────────────────────────────────────────────────────

def write_instruction_listing(elf_path: str, sections: list, out_path: str):
    """
    Disassemble all executable (.code) sections from the ELF using
    ``objdump -d`` and write a structured listing to *out_path*.

    Output format (one instruction per line, preceded by a section header):

        ──────────────────────────────────────────
        Section: code  base: 0x1000
        ──────────────────────────────────────────
        EIP       hex encoding          mnemonic + operands
        0x001000  55                    push   %ebp
        0x001001  89 e5                 mov    %esp,%ebp
        0x001003  83 ec 10              sub    $0x10,%esp
        ...

    Data sections are listed as raw byte dumps (no disassembly) so the
    file is complete even when data lives between code regions.

    Parameters
    ----------
    elf_path : str
        Path to the linked ELF binary.
    sections : list[dict]
        [{'name': 'code'|'data', 'start': int}, ...]  – from assemble_to_binary.
    out_path : str
        Destination file path.
    """
    # Run objdump -d  (disassemble only code sections, i386 syntax)
    r = subprocess.run(
        ['objdump', '-d', '-M', 'intel', '--no-show-raw-insn', elf_path],
        capture_output=True, text=True
    )
    # We'll also get the raw-bytes version for the hex encoding column.
    r_raw = subprocess.run(
        ['objdump', '-d', elf_path],   # AT&T + raw bytes (default)
        capture_output=True, text=True
    )
    if r.returncode != 0:
        print(f"[compile] WARNING: objdump -d failed, skipping instruction listing.\n"
              f"          {r.stderr.strip()}")
        return

    # ── parse the raw-bytes objdump to build  addr → (hex_bytes, mnemonic) ──
    # Example raw line:
    #   1000:       55                      push   %ebp
    #   1001:       89 e5                   mov    %esp,%ebp
    insn_map: dict[int, tuple[str, str]] = {}   # addr → (hex_bytes, mnemonic_at&t)

    for line in r_raw.stdout.splitlines():
        # Match:  <hex_addr>:  <hex bytes>       <mnemonic...>
        m = re.match(
            r'\s*([0-9a-fA-F]+):\s+'     # address
            r'((?:[0-9a-fA-F]{2}\s)+)'   # one or more hex byte pairs
            r'\s*(.*)',                   # mnemonic (may be empty for data)
            line
        )
        if m:
            addr     = int(m.group(1), 16)
            hex_enc  = m.group(2).strip()
            mnemonic = m.group(3).strip()
            insn_map[addr] = (hex_enc, mnemonic)

    # ── parse the intel-syntax objdump to get clean mnemonic lines ──────────
    # We use the intel output for the mnemonic column (cleaner for most readers)
    # and the AT&T raw output only for the hex encoding.
    #
    # Structure of objdump -d output:
    #   <elf_name>:     file format elf32-i386
    #
    #   Disassembly of section .code0:
    #
    #   00001000 <_start>:
    #      1000:	push   ebp
    #      1001:	mov    ebp,esp
    intel_insn_map: dict[int, str] = {}  # addr → intel mnemonic

    for line in r.stdout.splitlines():
        m = re.match(r'\s*([0-9a-fA-F]+):\s+(.*)', line)
        if m:
            addr     = int(m.group(1), 16)
            mnemonic = m.group(2).strip()
            if mnemonic:
                intel_insn_map[addr] = mnemonic

    # ── build section address ranges from objdump -h ─────────────────────────
    rh = subprocess.run(['objdump', '-h', elf_path], capture_output=True, text=True)
    sec_ranges: list[dict] = []   # [{'name', 'kind', 'vma', 'size'}, ...]

    for line in rh.stdout.splitlines():
        m = re.match(
            r'\s*\d+\s+(\S+)\s+([0-9a-fA-F]+)\s+([0-9a-fA-F]+)'
            r'\s+[0-9a-fA-F]+\s+([0-9a-fA-F]+)', line)
        if m:
            name = m.group(1)
            size = int(m.group(2), 16)
            vma  = int(m.group(3), 16)
            if size > 0 and re.match(r'\.(code|data)\d+', name):
                kind = 'code' if name.startswith('.code') else 'data'
                sec_ranges.append({'elf_name': name, 'kind': kind,
                                   'vma': vma, 'size': size})

    sec_ranges.sort(key=lambda s: s['vma'])

    # ── write the listing ────────────────────────────────────────────────────
    DIVIDER = '─' * 72

    with open(out_path, 'w') as f:
        f.write("Instruction Listing\n")
        f.write("Generated by compile.py  (x86-32, Intel syntax)\n")
        f.write(f"ELF: {elf_path}\n\n")
        f.write(f"{'EIP':<10}  {'Hex Encoding':<24}  Mnemonic\n")
        f.write(DIVIDER + "\n\n")

        if not sec_ranges:
            f.write("(no sections found)\n")
        else:
            for sec in sec_ranges:
                vma  = sec['vma']
                size = sec['size']
                kind = sec['kind']
                f.write(DIVIDER + "\n")
                f.write(f"Section: {sec['elf_name']}  "
                        f"kind={kind}  base=0x{vma:04x}  size={size} B\n")
                f.write(DIVIDER + "\n")

                if kind == 'data':
                    # Emit raw bytes for data sections – no disassembly.
                    f.write(f"  (data section – raw bytes)\n")
                    for addr in range(vma, vma + size):
                        if addr in insn_map:
                            hex_enc, _ = insn_map[addr]
                            f.write(f"  0x{addr:08x}  {hex_enc}\n")
                        # Data sections may not appear in disassembly at all;
                        # if we have no byte info just note the range.
                    if not any(a in insn_map for a in range(vma, vma + size)):
                        f.write(f"  0x{vma:08x} – 0x{vma+size-1:08x}  "
                                f"({size} bytes, no disassembly available)\n")
                    f.write("\n")
                    continue

                # code section – walk every address that objdump decoded
                addrs_in_sec = sorted(
                    a for a in insn_map if vma <= a < vma + size
                )

                if not addrs_in_sec:
                    f.write("  (no instructions decoded)\n\n")
                    continue

                for addr in addrs_in_sec:
                    hex_enc, _        = insn_map[addr]
                    intel_mnemonic    = intel_insn_map.get(addr, '???')
                    f.write(f"  0x{addr:08x}  {hex_enc:<24}  {intel_mnemonic}\n")

                f.write("\n")

        f.write(DIVIDER + "\n")
        total = sum(1 for s in sec_ranges if s['kind'] == 'code'
                    for a in insn_map if s['vma'] <= a < s['vma'] + s['size'])
        f.write(f"Total instructions decoded: {total}\n")

    print(f"[compile] Wrote instruction listing → {out_path}")


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

    elf_path = None
    tmp_dir  = None

    if use_program:
        src_path = cfg['input_Program_Path']
        print(f"[compile] Assembling {src_path} ...")
        overlay, base_addr, top_addr, sections, elf_path, tmp_dir = \
            assemble_to_binary(src_path, mem_size)
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

    # ── instruction listing (only when we have an ELF to disassemble) ─────────
    if elf_path and os.path.isfile(elf_path):
        write_instruction_listing(
            elf_path,
            sections,
            os.path.join(meta_dir, 'program_instructions.txt')
        )
    else:
        print("[compile] Skipping instruction listing "
              "(no ELF available for pre-built hex mode).")

    # clean up the temporary directory that holds the ELF
    if tmp_dir:
        shutil.rmtree(tmp_dir, ignore_errors=True)

    print("[compile] Done.")


if __name__ == '__main__':
    main()
