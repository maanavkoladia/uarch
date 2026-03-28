#!/usr/bin/env python3
"""
compile.py
----------
Stage 1 of the memGen pipeline.

Reads a JSON config, assembles an x86-32 .s source file (via GNU as + ld),
and produces:
  1. <metaDir>/program_flat.hex   – full 32 KB flat image, annotated by cache line
  2. <metaDir>/program_sections.hex – only the code+data regions, annotated
  3. <metaDir>/program.bin         – raw 32 KB binary (used by genHexMem.py)

JSON config keys consumed here:
  useProgram          : "true" / "false"
  input_Program_Path  : path to .s source
  input_hex_file      : path to pre-built flat hex (used when useProgram == "false")
  output_metaData_Path: directory for debug / meta outputs
  randomizeMem        : "true" / "false"  – fill unused bytes randomly vs 0x00
  mem_size_bytes      : (optional) default 32768
  cache_line_bytes    : (optional) default 16
"""

import json, sys, os, struct, subprocess, tempfile, random, re, argparse, shutil

# ── constants ────────────────────────────────────────────────────────────────
DEFAULT_MEM_SIZE   = 32 * 1024   # 32 KB
DEFAULT_LINE_BYTES = 16

# ── helpers ──────────────────────────────────────────────────────────────────

def load_config(path: str) -> dict:
    with open(path) as f:
        # allow trailing commas / comments? – use strict json for now
        return json.load(f)

def make_dir(p: str):
    os.makedirs(p, exist_ok=True)

def random_fill(size: int) -> bytearray:
    return bytearray(random.getrandbits(8) for _ in range(size))

def zero_fill(size: int) -> bytearray:
    return bytearray(size)

# ── assembler ────────────────────────────────────────────────────────────────

def parse_sections(src: str):
    """
    Very small .s parser to extract:
      - .org directives  → section start addresses
      - .code / .data    → section labels (informal, not real GAS directives)
    Returns list of (name, org_addr) in order they appear.
    Handles both // and # line comments.
    """
    sections = []
    current_org = None
    for line in src.splitlines():
        # strip comments
        stripped = re.sub(r'(//|#).*$', '', line).strip()
        if not stripped:
            continue
        # .org 0x1000  or  .org x1000
        m = re.match(r'\.org\s+(0?[xX]?[0-9a-fA-F]+)', stripped)
        if m:
            val = m.group(1)
            if not val.lower().startswith('0x'):
                val = '0x' + val.lstrip('xX')
            current_org = int(val, 16)
        if re.match(r'\.code\b', stripped):
            if current_org is not None:
                sections.append(('code', current_org))
        if re.match(r'\.data\b', stripped):
            if current_org is not None:
                sections.append(('data', current_org))
    return sections


def convert_pseudo_to_gas(src: str) -> str:
    """
    Convert our informal .s format into something GNU as (i386) can handle.

    The .org directives are used by parse_sections() to learn *where* each
    section lives, then the linker script places the sections there.
    Inside the assembled .s the .org lines must be REMOVED — keeping them
    would cause GAS to pad the section to that offset from the section
    start, which breaks linker placement.

    Transformations applied per line:
      // comment          →  # comment
      .org xNNNN  line    →  dropped (placement is done by linker script)
      .code               →  .text
      .data               →  .data  (already valid GAS)
    """
    lines = []
    for line in src.splitlines():
        # convert // comments to #
        out = re.sub(r'//.*$', lambda m: '# ' + m.group(0)[2:], line)
        # drop .org lines entirely (linker script handles placement)
        if re.match(r'\s*\.org\b', out):
            lines.append('# ' + out.lstrip())
            continue
        # .code → .text
        out = re.sub(r'^(\s*)\.code\b', r'\1.text', out)
        lines.append(out)
    # ensure file ends with newline
    return '\n'.join(lines) + '\n'


def assemble_to_binary(src_path: str, mem_size: int) -> tuple:
    """
    Assemble src_path with GNU as/ld for i386.
    Returns (code_bytes, base_addr, sections) where:
      code_bytes : raw bytes filling [base_addr, base_addr+len) in the image
      base_addr  : lowest VMA (from .org directives)
      sections   : [{'name': str, 'start': int}, ...]

    Strategy
    --------
    1. as --32  →  .o
    2. Build a minimal linker script that places .text at code_org and
       .data at data_org (read from parse_sections).
    3. ld with that script  →  ELF
    4. Read ELF sections via objdump to find each section's VMA + raw bytes.
    5. Merge into a single contiguous bytearray from base_addr to highest byte.
    """
    with open(src_path) as f:
        raw = f.read()

    sections_meta = parse_sections(raw)   # [('code', addr), ('data', addr), ...]
    gas_src       = convert_pseudo_to_gas(raw)

    # default orgs if not specified
    code_org = next((a for n,a in sections_meta if n=='code'), 0x1000)
    data_org = next((a for n,a in sections_meta if n=='data'), None)

    with tempfile.TemporaryDirectory() as tmp:
        s_file  = os.path.join(tmp, 'prog.s')
        o_file  = os.path.join(tmp, 'prog.o')
        ld_file = os.path.join(tmp, 'prog.ld')
        elf_file= os.path.join(tmp, 'prog.elf')

        with open(s_file, 'w') as f:
            f.write(gas_src)

        # ── assemble ──────────────────────────────────────────────────────────
        r = subprocess.run(['as', '--32', '-o', o_file, s_file],
                           capture_output=True, text=True)
        if r.returncode != 0:
            sys.exit(f"[compile] GNU as failed:\n{r.stderr}")

        # ── build linker script ───────────────────────────────────────────────
        # Place .text at code_org, .data at data_org (if present).
        # This avoids the in-section .org padding that makes objcopy binary
        # layouts confusing.
        data_section = (f"  .data 0x{data_org:x} : {{ *(.data) }}"
                        if data_org is not None else "")
        ld_script = f"""\
OUTPUT_FORMAT(elf32-i386)
ENTRY(_start)
SECTIONS {{
  .text 0x{code_org:x} : {{ *(.text) }}
  {data_section}
  /DISCARD/ : {{ *(.note*) *(.comment) *(.eh_frame) }}
}}
"""
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

        # parse section table: Name, Size, VMA, File-off
        sec_info = []   # [(name, vma, size, fileoff), ...]
        for line in r.stdout.splitlines():
            # '  0 .text         00000017  00001000  ...'
            m = re.match(
                r'\s*\d+\s+(\S+)\s+([0-9a-fA-F]+)\s+([0-9a-fA-F]+)'
                r'\s+[0-9a-fA-F]+\s+([0-9a-fA-F]+)', line)
            if m:
                name    = m.group(1)
                size    = int(m.group(2), 16)
                vma     = int(m.group(3), 16)
                fileoff = int(m.group(4), 16)
                if name in ('.text', '.data') and size > 0:
                    sec_info.append((name, vma, size, fileoff))

        if not sec_info:
            sys.exit("[compile] No .text/.data sections found in ELF.")

        # read raw ELF to extract bytes
        with open(elf_file, 'rb') as f:
            elf_raw = f.read()

        # determine overall span
        base_addr = min(vma for _, vma, _, _ in sec_info)
        top_addr  = max(vma + size for _, vma, size, _ in sec_info)
        span      = top_addr - base_addr

        code_bytes = bytearray(span)
        for name, vma, size, fileoff in sec_info:
            offset_in_span = vma - base_addr
            code_bytes[offset_in_span : offset_in_span + size] = \
                elf_raw[fileoff : fileoff + size]

    sections = [{'name': n, 'start': a} for (n, a) in sections_meta]
    return code_bytes, base_addr, sections


# ── flat image builder ───────────────────────────────────────────────────────

def build_flat_image(code_bytes: bytearray, base_addr: int,
                     mem_size: int, randomize: bool) -> bytearray:
    """
    Place assembled code into a full mem_size image.

    ld --oformat binary produces a raw binary that begins at the lowest VMA
    (base_addr). The binary itself is NOT padded by the VMA — byte 0 of the
    binary corresponds to address base_addr. So we place code_bytes at
    image[base_addr].
    """
    if randomize:
        image = random_fill(mem_size)
    else:
        image = zero_fill(mem_size)

    if base_addr + len(code_bytes) > mem_size:
        sys.exit(f"[compile] Program ({len(code_bytes)} B @ 0x{base_addr:x}) "
                 f"exceeds memory size ({mem_size} B).")
    image[base_addr : base_addr + len(code_bytes)] = code_bytes
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
            addr   = ln * line_bytes
            chunk  = image[addr: addr + line_bytes]
            # pretty print: groups of 4
            groups = []
            for g in range(0, line_bytes, 4):
                groups.append(' '.join(f'{b:02x}' for b in chunk[g:g+4]))
            f.write(f"// $line_{ln:<5d}  addr: 0x{addr:04x}\n")
            f.write('  ' + '  '.join(groups) + '\n\n')
    print(f"[compile] Wrote flat hex  → {out_path}")


def write_sections_hex(image: bytearray, sections: list,
                       base_addr: int, code_len: int,
                       line_bytes: int, out_path: str):
    """
    Write only the code+data region(s) as annotated hex.
    We mark which cache lines fall inside the assembled region.
    """
    mem_size = len(image)
    n_lines  = mem_size // line_bytes

    # determine byte range covered by sections
    region_start = base_addr
    region_end   = base_addr + code_len

    with open(out_path, 'w') as f:
        f.write(f"// Sections hex  base=0x{base_addr:04x}  "
                f"len={code_len} B  line_size={line_bytes} B\n")
        f.write(f"// Sections: {[s['name'] for s in sections]}\n\n")

        for ln in range(n_lines):
            addr     = ln * line_bytes
            line_end = addr + line_bytes
            if line_end <= region_start or addr >= region_end:
                continue  # skip lines outside our program region
            chunk  = image[addr: addr + line_bytes]
            groups = []
            for g in range(0, line_bytes, 4):
                groups.append(' '.join(f'{b:02x}' for b in chunk[g:g+4]))
            f.write(f"// $line_{ln:<5d}  addr: 0x{addr:04x}\n")
            f.write('  ' + '  '.join(groups) + '\n\n')
    print(f"[compile] Wrote sections hex → {out_path}")


# ── readmemh hex writer ──────────────────────────────────────────────────────

def write_readmemh_flat(image: bytearray, line_bytes: int, out_path: str):
    """
    Write a $readmemh-compatible hex file of the full image.
    Each line is one byte (standard readmemh word = 8-bit here).
    Address tags are included so the file is self-describing.
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
    print(f"[compile] Wrote readmemh flat → {out_path}")


# ── main ─────────────────────────────────────────────────────────────────────

def main():
    ap = argparse.ArgumentParser(description="Stage 1: assemble → flat image")
    ap.add_argument('config', help='Path to JSON config file')
    args = ap.parse_args()

    cfg = load_config(args.config)

    use_program  = cfg.get('useProgram',  'true').strip().lower() == 'true'
    randomize    = cfg.get('randomizeMem','false').strip().lower() == 'true'
    mem_size     = int(cfg.get('mem_size_bytes',   DEFAULT_MEM_SIZE))
    line_bytes   = int(cfg.get('cache_line_bytes', DEFAULT_LINE_BYTES))
    meta_dir     = cfg['output_metaData_Path']

    make_dir(meta_dir)

    if use_program:
        src_path = cfg['input_Program_Path']
        print(f"[compile] Assembling {src_path} ...")
        code_bytes, base_addr, sections = assemble_to_binary(src_path, mem_size)
        print(f"[compile] Assembled {len(code_bytes)} bytes  base=0x{base_addr:04x}")
    else:
        # load a pre-built flat hex file (readmemh format)
        hex_path = cfg['input_hex_file']
        print(f"[compile] Loading pre-built hex {hex_path} ...")
        code_bytes = bytearray()
        base_addr  = 0
        sections   = []
        with open(hex_path) as f:
            for line in f:
                line = line.strip()
                if line.startswith('//') or not line:
                    continue
                if line.startswith('@'):
                    if base_addr == 0:
                        base_addr = int(line[1:], 16)
                    continue
                code_bytes.extend(bytes.fromhex(line))

    # build full memory image
    image = build_flat_image(code_bytes, base_addr, mem_size, randomize)

    # save binary for stage 2
    bin_out = os.path.join(meta_dir, 'program.bin')
    with open(bin_out, 'wb') as f:
        f.write(image)
    print(f"[compile] Saved binary     → {bin_out}")

    # human-readable flat hex (annotated, NOT readmemh)
    write_flat_hex(image, line_bytes,
                   os.path.join(meta_dir, 'program_flat.hex'))

    # sections-only hex
    write_sections_hex(image, sections, base_addr, len(code_bytes),
                       line_bytes,
                       os.path.join(meta_dir, 'program_sections.hex'))

    # readmemh flat (for completeness / TB use)
    write_readmemh_flat(image, line_bytes,
                        os.path.join(meta_dir, 'program_readmemh.hex'))

    print("[compile] Done.")


if __name__ == '__main__':
    main()
