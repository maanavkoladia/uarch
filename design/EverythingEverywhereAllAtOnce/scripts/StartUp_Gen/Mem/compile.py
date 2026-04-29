#!/usr/bin/env python3
"""
compile.py  (v5 – linear/virtual .org addresses, no segmentation logic)
------------------------------------------------------------------------
Stage 1 of the memGen pipeline.

Pipeline:
  Source .s
    └─[1]─ gcc -E  (preprocessor only, resolves #defines the user filled in)
    └─[2]─ GNU as + ld  (sections placed at their .org linear addresses)
    └─[3]─ VM mapping: for each VM_Mappings entry [va_page, frame]
               copy 4 KB from the sparse VA image at va_page
               into physical frame slot  (frame * page_size)
    └─[4]─ Diagnostic report

  Pre-built hex (useProgram == "false"):
    Supports annotated hex dump format:
      0xADDR:  BB CC DD ...  // optional comment
    Lines not matching this pattern (comments, blank lines, etc.) are ignored.
    Bytes are written DIRECTLY into the flat physical image at the given
    address — no VA translation, no VM_Mappings.  The address in each hex
    line is treated as a physical byte offset into the output binary.

Key design points
  • NO segment translation.  .org values are treated as 32-bit linear/VA
    addresses directly.  The user manages segment registers manually in
    source; macros are preprocessed as-is.
  • VA image is a sparse dict {page_base: bytearray(page_size)} so sections
    can live anywhere in the 32-bit address space without allocating 4 GB.
  • VM_Mappings drives what ends up in the 32 KB physical image (compiled
    path only).  Any VA page not listed is simply not present in physical
    memory.  Any listed VA page that has no assembled content gets background
    fill (zero/random).
  • For the pre-built hex path VM_Mappings is ignored entirely — addresses
    are physical offsets written straight into the output binary.

JSON config keys:
  useProgram             : "true" / "false"
  input_Program_Path     : path to .s source
  input_hex_file         : path to annotated hex dump (useProgram == "false")
  output_metaData_Path   : directory for debug / meta outputs
  output_LoadableHex_Path: directory for per-bank hex files (genHexMem input)
  randomizeMem           : "true" / "false"  background fill for unmapped pages
  mem_size_bytes         : (optional) default 32768
  cache_line_bytes       : (optional) default 16
  page_size_bytes        : (optional) default 4096
  gcc_extra_flags        : (optional) list of extra flags for gcc -E

  VM_Mappings : list of [va_page_or_any_addr_in_page, frame_index]
                (compiled path only – ignored when useProgram == "false")
                va address is masked to page boundary automatically.
                frame_index selects the physical 4 KB slot in the 32 KB image.
                Up to mem_size/page_size entries (e.g. 8 for default config).
"""

import json, sys, os, subprocess, tempfile, random, re, argparse, shutil

# ── constants ────────────────────────────────────────────────────────────────
DEFAULT_MEM_SIZE   = 32 * 1024
DEFAULT_LINE_BYTES = 16
DEFAULT_PAGE_SIZE  = 4096

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

def parse_int(v) -> int:
    if isinstance(v, int):
        return v
    s = str(v).strip()
    return int(s, 16) if s.lower().startswith('0x') else int(s, 10)


# ══════════════════════════════════════════════════════════════════════════════
#  Sparse VA page dict  (compiled path)
# ══════════════════════════════════════════════════════════════════════════════

def sparse_write(pages: dict, addr: int, data: bytes, page_size: int):
    """Write bytes into the sparse page dict starting at addr."""
    offset = 0
    while offset < len(data):
        page_base = (addr + offset) & ~(page_size - 1)
        page_off  = (addr + offset) -  page_base
        chunk_len = min(len(data) - offset, page_size - page_off)
        if page_base not in pages:
            pages[page_base] = bytearray(page_size)
        pages[page_base][page_off : page_off + chunk_len] = \
            data[offset : offset + chunk_len]
        offset += chunk_len


# ══════════════════════════════════════════════════════════════════════════════
#  Annotated hex dump → flat physical image  (useProgram == "false")
# ══════════════════════════════════════════════════════════════════════════════

# Matches lines like:
#   0x0:    bc 00 03 00 00   // comment
#   0x2068:  52 00 00 00     //cs=0x0 …
#   0x43fc:  01 02 03 04
#
# Group 1 = address (hex), Group 2 = byte tokens (space-separated hex pairs)
_HEX_LINE_RE = re.compile(
    r'^\s*(0[xX][0-9a-fA-F]+)\s*:\s*((?:[0-9a-fA-F]{2}\s*)+)',
    re.IGNORECASE
)

def load_hex_to_physical(hex_path: str,
                          mem_size: int,
                          randomize: bool) -> tuple:
    """
    Parse an annotated hex dump and write bytes DIRECTLY into a flat physical
    image.  The address on each line is treated as a physical byte offset —
    no page table, no VM_Mappings.

    Accepted line format (anything after the byte tokens is a comment):
        0xADDR:   BB CC DD EE ...   // optional comment

    Lines that do not match are silently skipped.

    Returns
    -------
    phys_image   : bytearray(mem_size)
    sections_out : list of {'name', 'elf_name', 'va', 'size'}  (one per run)
    warnings     : list of warning strings
    """
    phys_image   = random_fill(mem_size) if randomize else zero_fill(mem_size)
    total_bytes  = 0
    runs         = []   # list of (start_addr, byte_count) for the report
    warnings     = []

    with open(hex_path) as fh:
        for raw_line in fh:
            m = _HEX_LINE_RE.match(raw_line)
            if not m:
                continue        # blank, comment, or non-matching line

            addr        = int(m.group(1), 16)
            byte_tokens = re.findall(r'[0-9a-fA-F]{2}', m.group(2))
            if not byte_tokens:
                continue

            data = bytes(int(t, 16) for t in byte_tokens)

            # bounds check
            end = addr + len(data)
            if end > mem_size:
                w = (f"WARNING: hex line at 0x{addr:08x} extends to "
                     f"0x{end:08x}, beyond mem_size=0x{mem_size:x}. "
                     f"Truncating.")
                print(f"[compile] {w}")
                warnings.append(w)
                data = data[:mem_size - addr]
                if not data:
                    continue

            phys_image[addr : addr + len(data)] = data
            runs.append((addr, len(data)))
            total_bytes += len(data)

    if not runs:
        sys.exit(f"[compile] No valid hex data found in '{hex_path}'.")

    print(f"[compile] Loaded {total_bytes} bytes from '{hex_path}' "
          f"across {len(runs)} address run(s) (direct physical write).")

    # Merge consecutive runs into contiguous regions for the report.
    runs.sort()
    merged = []
    for start, length in runs:
        if merged and start <= merged[-1][0] + merged[-1][1]:
            end_new = max(merged[-1][0] + merged[-1][1], start + length)
            merged[-1] = (merged[-1][0], end_new - merged[-1][0])
        else:
            merged.append([start, length])

    sections_out = []
    for i, (start, length) in enumerate(merged):
        sections_out.append({
            'name'    : 'data',
            'elf_name': f'.hexdata{i}',
            'va'      : start,
            'size'    : length,
        })
        print(f"[compile]   .hexdata{i:<4}  phys=0x{start:08x}  size={length} B  "
              f"end=0x{start+length:08x}")

    return phys_image, sections_out, warnings


def write_hex_diagnostic_report(out_path, hex_path,
                                 sections_out, warnings,
                                 mem_size, phys_image):
    """Simplified diagnostic report for the direct-physical hex path."""
    DIV  = '═' * 78
    div2 = '─' * 78

    with open(out_path, 'w') as f:
        def w(s=''):
            f.write(s + '\n')

        w(DIV)
        w('  memGen v5  –  Physical Hex Load Diagnostic Report')
        w(DIV)
        w()
        w(f'  Source file  : {hex_path}')
        w(f'  Phys mem     : {mem_size} B  (0x{mem_size:x})')
        w(f'  Mode         : direct physical write (no VM translation)')
        w()

        if warnings:
            w(DIV)
            w('  WARNINGS')
            w(DIV)
            w()
            for wn in warnings:
                w(f'  ⚠  {wn}')
            w()

        w(DIV)
        w('  SECTION 1 – Loaded Regions  (addresses = physical offsets)')
        w(DIV)
        w()
        w(f"  {'Region':<12}  {'phys start':>12}  {'size':>8}  {'phys end':>12}")
        w(div2)
        for s in sections_out:
            w(f"  {s['elf_name']:<12}  "
              f"0x{s['va']:08x}    "
              f"{s['size']:>8} B  "
              f"0x{s['va']+s['size']:08x}")
        w()

        # non-zero byte summary of the full image
        w(DIV)
        w('  SECTION 2 – Physical Image Non-Zero Summary')
        w(DIV)
        w()
        nz_total = sum(1 for b in phys_image if b != 0)
        w(f'  Total non-zero bytes in physical image: {nz_total} / {mem_size}')
        w()
        w(DIV)
        w('  End of report')
        w(DIV)

    print(f"[compile] Wrote diagnostic report → {out_path}")


# ══════════════════════════════════════════════════════════════════════════════
#  STAGE 1 – Preprocess  (gcc -E only, no macro injection)
# ══════════════════════════════════════════════════════════════════════════════

def preprocess_source(src_path: str, extra_flags: list, tmp_dir: str) -> str:
    """
    Run gcc -E on the source so that any #defines the user already filled in
    are expanded.  We do NOT inject any values ourselves.
    """
    pp_file = os.path.join(tmp_dir, 'prog_pp.s')
    cmd = ['gcc', '-E', '-x', 'assembler-with-cpp',
           '-m32', '-o', pp_file, src_path] + extra_flags
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        sys.exit(f"[compile] gcc -E failed:\n{r.stderr}")
    print(f"[compile] Preprocessed → {pp_file}")
    return pp_file


# ══════════════════════════════════════════════════════════════════════════════
#  STAGE 2 – Assemble into sparse VA image
# ══════════════════════════════════════════════════════════════════════════════

def parse_sections(src: str) -> list:
    """
    Walk the source and collect (kind, org, index) for each .code/.data
    section preceded by a .org directive.
    .org values are parsed as 32-bit hex or decimal integers.
    """
    sections = []
    counters = {'code': 0, 'data': 0}
    pending  = None

    for line in src.splitlines():
        # strip comments
        stripped = re.sub(r'/\*.*?\*/', '', line)
        stripped = re.sub(r'(//|#).*$', '', stripped).strip()
        if not stripped:
            continue

        m = re.match(r'\.org\s+(0[xX][0-9a-fA-F]+|\d+)', stripped)
        if m:
            pending = int(m.group(1), 16) if m.group(1).lower().startswith('0x') \
                      else int(m.group(1))
            continue

        for kind in ('code', 'data'):
            if re.match(rf'\.{kind}\b', stripped):
                if pending is None:
                    sys.exit(f"[compile] .{kind} with no preceding .org")
                sections.append({'kind': kind, 'org': pending,
                                  'index': counters[kind]})
                counters[kind] += 1
                pending = None
                break

    return sections


def _sec_name(sec: dict) -> str:
    return f".{sec['kind']}{sec['index']}"


def convert_pseudo_to_gas(src: str, sections: list) -> str:
    """Replace pseudo .code/.data directives with GAS .section directives."""
    iters = {
        'code': iter([s for s in sections if s['kind'] == 'code']),
        'data': iter([s for s in sections if s['kind'] == 'data']),
    }
    lines = []
    for line in src.splitlines():
        # comment out .org lines (the linker script handles placement)
        if re.match(r'\s*\.org\b', line):
            lines.append('# ' + line.lstrip())
            continue
        matched = False
        for kind, flags in (('code', '"ax", @progbits'),
                             ('data', '"aw", @progbits')):
            if re.match(rf'\s*\.{kind}\b', line):
                sec    = next(iters[kind])
                indent = re.match(r'(\s*)', line).group(1)
                lines.append(f'{indent}.section {_sec_name(sec)}, {flags}')
                matched = True
                break
        if not matched:
            lines.append(line)
    return '\n'.join(lines) + '\n'


def assemble_to_sparse(src_path: str, page_size: int) -> tuple:
    """
    Assemble preprocessed source → ELF → sparse VA page dict.

    Sections are linked at their .org addresses (treated as 32-bit linear VAs).

    Returns
    -------
    va_pages     : dict { page_base: bytearray(page_size) }
    sections_out : list of {'name', 'kind', 'va', 'size'}
    elf_path     : path to temp ELF (inside tmp_dir)
    tmp_dir      : temp directory (caller cleans up)
    """
    with open(src_path) as f:
        raw = f.read()

    sections_meta = parse_sections(raw)
    if not sections_meta:
        sys.exit("[compile] No .code or .data sections found.")

    gas_src = convert_pseudo_to_gas(raw, sections_meta)

    tmp      = tempfile.mkdtemp()
    s_file   = os.path.join(tmp, 'prog.s')
    o_file   = os.path.join(tmp, 'prog.o')
    ld_file  = os.path.join(tmp, 'prog.ld')
    elf_file = os.path.join(tmp, 'prog.elf')

    with open(s_file, 'w') as f:
        f.write(gas_src)

    # assemble
    r = subprocess.run(['as', '--32', '-o', o_file, s_file],
                       capture_output=True, text=True)
    if r.returncode != 0:
        shutil.rmtree(tmp, ignore_errors=True)
        sys.exit(f"[compile] GNU as failed:\n{r.stderr}")

    # linker script: place each section at its .org VA
    sec_lines = [
        f"  {_sec_name(s)} 0x{s['org']:08x} : {{ *({_sec_name(s)}) }}"
        for s in sections_meta
    ]
    ld_script = (
        "OUTPUT_FORMAT(elf32-i386)\n"
        "ENTRY(_start)\n"
        "SECTIONS {\n"
        + "\n".join(sec_lines) + "\n"
        + "  /DISCARD/ : { *(.note*) *(.comment) *(.eh_frame) }\n"
        + "}\n"
    )
    with open(ld_file, 'w') as f:
        f.write(ld_script)

    # link
    r = subprocess.run(['ld', '-m', 'elf_i386', '-T', ld_file,
                        '-o', elf_file, o_file],
                       capture_output=True, text=True)
    if r.returncode != 0:
        shutil.rmtree(tmp, ignore_errors=True)
        sys.exit(f"[compile] ld failed:\n{r.stderr}")

    # read section headers
    r = subprocess.run(['objdump', '-h', elf_file], capture_output=True, text=True)
    if r.returncode != 0:
        shutil.rmtree(tmp, ignore_errors=True)
        sys.exit(f"[compile] objdump -h failed:\n{r.stderr}")

    wanted   = {_sec_name(s) for s in sections_meta}
    sec_info = []
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
        sys.exit("[compile] No relevant sections found in ELF.")

    with open(elf_file, 'rb') as f:
        elf_raw = f.read()

    name_to_kind = {_sec_name(s): s['kind'] for s in sections_meta}
    va_pages     = {}
    sections_out = []

    for name, vma, size, fileoff in sorted(sec_info, key=lambda x: x[1]):
        data = elf_raw[fileoff : fileoff + size]
        sparse_write(va_pages, vma, data, page_size)
        sections_out.append({
            'name': name_to_kind.get(name, name),
            'elf_name': name,
            'va'  : vma,
            'size': size,
        })
        print(f"[compile]   {name:<12}  VA=0x{vma:08x}  size={size} B  "
              f"pages=[0x{vma & ~(page_size-1):08x}"
              f"..0x{(vma+size-1) & ~(page_size-1):08x}]")

    return va_pages, sections_out, elf_file, tmp


# ══════════════════════════════════════════════════════════════════════════════
#  STAGE 3 – VM mapping  (sparse VA dict → flat 32 KB physical image)
#  Compiled path only.
# ══════════════════════════════════════════════════════════════════════════════

def apply_vm_mappings(va_pages: dict,
                      vm_mappings: list,
                      page_size: int,
                      mem_size: int,
                      randomize: bool) -> tuple:
    """
    For each [va_addr, frame] in vm_mappings:
      va_page = va_addr & ~(page_size-1)
      Copy va_pages[va_page] (or background fill) into
      phys_image[frame*page_size : (frame+1)*page_size].

    Returns (phys_image bytearray, list of record dicts for the report).
    """
    n_frames  = mem_size // page_size
    max_frame = n_frames - 1

    phys_image  = random_fill(mem_size) if randomize else zero_fill(mem_size)
    records     = []
    seen_frames = set()
    warnings    = []

    for entry in vm_mappings:
        if len(entry) != 2:
            sys.exit(f"[compile] VM_Mappings entry needs 2 elements: {entry}")
        va_raw  = parse_int(entry[0])
        frame   = parse_int(entry[1])
        va_page = va_raw & ~(page_size - 1)
        phys_base = frame * page_size

        if frame < 0 or frame > max_frame:
            sys.exit(f"[compile] Frame {frame} out of range [0,{max_frame}].")

        if frame in seen_frames:
            w = f"WARNING: physical frame {frame} mapped more than once – last writer wins."
            print(f"[compile] {w}")
            warnings.append(w)
        seen_frames.add(frame)

        if va_page not in va_pages:
            status = "VA page not assembled – background fill"
            warnings.append(f"WARNING: VA page 0x{va_page:08x} → frame {frame}: "
                            f"no assembled content found.")
        else:
            page_data = va_pages[va_page]
            phys_image[phys_base : phys_base + page_size] = page_data
            nz = [i for i, b in enumerate(page_data) if b != 0]
            status = (f"{len(nz)} non-zero bytes, "
                      f"range [+0x{nz[0]:03x}..+0x{nz[-1]:03x}]"
                      if nz else "all zero")

        records.append({
            'va_raw'   : va_raw,
            'va_page'  : va_page,
            'frame'    : frame,
            'phys_base': phys_base,
            'status'   : status,
        })

    return phys_image, records, warnings


# ══════════════════════════════════════════════════════════════════════════════
#  STAGE 4 – Diagnostic report  (compiled path)
# ══════════════════════════════════════════════════════════════════════════════

def write_diagnostic_report(out_path, src_path,
                             vm_records, warnings,
                             sections_out,
                             page_size, mem_size,
                             va_pages):
    DIV  = '═' * 78
    div2 = '─' * 78

    with open(out_path, 'w') as f:
        def w(s=''):
            f.write(s + '\n')

        w(DIV)
        w('  memGen v5  –  Virtual Memory Diagnostic Report')
        w(DIV)
        w()
        w(f'  Source file  : {src_path}')
        w(f'  Page size    : {page_size} B  (0x{page_size:x})')
        w(f'  Phys mem     : {mem_size} B  (0x{mem_size:x})')
        w(f'  Sparse pages : {len(va_pages)} allocated')
        w()

        # Warnings
        if warnings:
            w(DIV)
            w('  WARNINGS')
            w(DIV)
            w()
            for wn in warnings:
                w(f'  ⚠  {wn}')
            w()

        # Section 1 – ELF section placement
        w(DIV)
        w('  SECTION 1 – Assembled ELF Sections  (linear/VA addresses)')
        w(DIV)
        w()
        w(f"  {'ELF section':<12}  {'kind':<5}  {'VA start':>12}  "
          f"{'size':>8}  {'VA pages spanned'}")
        w(div2)
        for s in sections_out:
            pg_lo = s['va'] & ~(page_size - 1)
            pg_hi = (s['va'] + s['size'] - 1) & ~(page_size - 1)
            pages_str = (f"0x{pg_lo:08x}" if pg_lo == pg_hi
                         else f"0x{pg_lo:08x} – 0x{pg_hi:08x}")
            w(f"  {s['elf_name']:<12}  {s['name']:<5}  "
              f"0x{s['va']:08x}  {s['size']:>8} B  {pages_str}")
        w()

        # Section 2 – VM mappings
        w(DIV)
        w('  SECTION 2 – Virtual → Physical Page Mappings (TLB)')
        w(DIV)
        w()
        w(f"  {'#':>2}  {'VA (config)':>12}  {'VA page':>12}  "
          f"{'frame':>6}  {'phys base':>12}  Contents")
        w(div2)
        for i, r in enumerate(vm_records):
            w(f"  {i:>2}  0x{r['va_raw']:08x}    "
              f"0x{r['va_page']:08x}  "
              f"     {r['frame']:>1}    "
              f"0x{r['phys_base']:08x}  {r['status']}")
        w()

        # Section 3 – sparse VA inventory
        w(DIV)
        w('  SECTION 3 – Sparse VA Page Inventory')
        w(DIV)
        w()
        w(f"  {'VA page':>12}  {'non-zero B':>10}  "
          f"{'first nz offset':>16}  {'last nz offset':>15}  mapped?")
        w(div2)
        mapped_pages = {r['va_page'] for r in vm_records}
        for pg in sorted(va_pages):
            data    = va_pages[pg]
            nz      = [i for i, b in enumerate(data) if b != 0]
            mapped  = '✓ mapped' if pg in mapped_pages else '✗ NOT in VM_Mappings'
            first_s = f'+0x{nz[0]:03x}'  if nz else '—'
            last_s  = f'+0x{nz[-1]:03x}' if nz else '—'
            w(f"  0x{pg:08x}  {len(nz):>10d}  "
              f"{first_s:>16}  {last_s:>15}  {mapped}")
        w()

        # Section 4 – physical frame layout
        w(DIV)
        w('  SECTION 4 – Physical Frame Layout')
        w(DIV)
        w()
        w(f"  {'frame':>5}  {'phys base':>12}  {'phys top':>12}  source VA page")
        w(div2)
        frame_map = {r['frame']: r for r in vm_records}
        n_frames  = mem_size // page_size
        for fr in range(n_frames):
            if fr in frame_map:
                r = frame_map[fr]
                src = f"0x{r['va_page']:08x}"
            else:
                src = '(unmapped – background fill)'
            phys_base = fr * page_size
            w(f"  {fr:>5}  0x{phys_base:08x}    "
              f"0x{phys_base+page_size-1:08x}  {src}")
        w()
        w(DIV)
        w('  End of report')
        w(DIV)

    print(f"[compile] Wrote diagnostic report → {out_path}")


# ══════════════════════════════════════════════════════════════════════════════
#  Hex / listing writers
# ══════════════════════════════════════════════════════════════════════════════

def write_flat_hex(image: bytearray, line_bytes: int, out_path: str):
    n_lines = len(image) // line_bytes
    with open(out_path, 'w') as f:
        f.write(f"// Flat physical image  {len(image)} B  "
                f"line={line_bytes} B  lines={n_lines}\n\n")
        for ln in range(n_lines):
            addr  = ln * line_bytes
            chunk = image[addr: addr + line_bytes]
            groups = ['  '.join(f'{b:02x}' for b in chunk[g:g+4])
                      for g in range(0, line_bytes, 4)]
            f.write(f"// $line_{ln:<5d}  phys: 0x{addr:04x}\n")
            f.write('  ' + '  '.join(groups) + '\n\n')
    print(f"[compile] Wrote flat hex       → {out_path}")


def write_readmemh_flat(image: bytearray, line_bytes: int, out_path: str):
    with open(out_path, 'w') as f:
        f.write("// readmemh flat physical image\n")
        n_lines = len(image) // line_bytes
        for ln in range(n_lines):
            addr  = ln * line_bytes
            chunk = image[addr: addr + line_bytes]
            f.write(f"// $line_{ln}  @{addr:04x}\n@{addr:04x}\n")
            for b in chunk:
                f.write(f"{b:02x}\n")
    print(f"[compile] Wrote readmemh flat  → {out_path}")


def write_instruction_listing(elf_path: str, out_path: str):
    r_raw   = subprocess.run(['objdump', '-d', elf_path],
                             capture_output=True, text=True)
    r_intel = subprocess.run(
        ['objdump', '-d', '-M', 'intel', '--no-show-raw-insn', elf_path],
        capture_output=True, text=True)
    if r_raw.returncode != 0 or r_intel.returncode != 0:
        print("[compile] WARNING: objdump -d failed, skipping listing.")
        return

    intel_map = {}
    for line in r_intel.stdout.splitlines():
        m = re.match(r'\s*([0-9a-fA-F]+):\s+(.*)', line)
        if m and m.group(2).strip():
            intel_map[int(m.group(1), 16)] = m.group(2).strip()

    raw_map = {}
    last    = None
    for line in r_raw.stdout.splitlines():
        m = re.match(r'\s*([0-9a-fA-F]+):\s+((?:[0-9a-fA-F]{2}\s)+)', line)
        if not m:
            continue
        addr = int(m.group(1), 16)
        hp   = m.group(2).strip()
        if addr in intel_map:
            raw_map[addr] = hp
            last = addr
        elif last is not None:
            raw_map[last] += ' ' + hp

    rh = subprocess.run(['objdump', '-h', elf_path], capture_output=True, text=True)
    sec_ranges = []
    for line in rh.stdout.splitlines():
        m = re.match(
            r'\s*\d+\s+(\S+)\s+([0-9a-fA-F]+)\s+([0-9a-fA-F]+)'
            r'\s+[0-9a-fA-F]+\s+[0-9a-fA-F]+', line)
        if m:
            name = m.group(1)
            size = int(m.group(2), 16)
            vma  = int(m.group(3), 16)
            if size > 0 and re.match(r'\.(code|data)\d+', name):
                kind = 'code' if name.startswith('.code') else 'data'
                sec_ranges.append({'name': name, 'kind': kind,
                                   'vma': vma, 'size': size})
    sec_ranges.sort(key=lambda s: s['vma'])

    DIV = '─' * 72
    with open(out_path, 'w') as f:
        f.write("Instruction Listing  –  compile.py v5\n")
        f.write("Addresses are linear/VA as assembled.\n\n")
        f.write(f"{'VA':<12}  {'Hex encoding':<28}  Mnemonic\n")
        f.write(DIV + '\n\n')
        for sec in sec_ranges:
            vma, size, kind = sec['vma'], sec['size'], sec['kind']
            f.write(DIV + '\n')
            f.write(f"  {sec['name']}  kind={kind}  VA=0x{vma:08x}  size={size} B\n")
            f.write(DIV + '\n')
            if kind == 'data':
                f.write(f"  (data)  0x{vma:08x}–0x{vma+size-1:08x}  ({size} B)\n\n")
                continue
            addrs = sorted(a for a in intel_map if vma <= a < vma + size)
            for addr in addrs:
                f.write(f"  0x{addr:08x}  {raw_map.get(addr,'?'):<28}  "
                        f"{intel_map[addr]}\n")
            f.write('\n')
        total = sum(1 for s in sec_ranges if s['kind'] == 'code'
                    for a in intel_map if s['vma'] <= a < s['vma'] + s['size'])
        f.write(DIV + '\n')
        f.write(f"Total instructions decoded: {total}\n")
    print(f"[compile] Wrote instruction listing → {out_path}")


# ══════════════════════════════════════════════════════════════════════════════
#  MAIN
# ══════════════════════════════════════════════════════════════════════════════

def main():
    ap = argparse.ArgumentParser(
        description="Stage 1 (v5): assemble at 32-bit VA, VM-map to physical image")
    ap.add_argument('config', help='Path to JSON config file')
    args = ap.parse_args()

    cfg = load_config(args.config)

    use_program = cfg.get('useProgram',   'true').strip().lower() == 'true'
    randomize   = cfg.get('randomizeMem', 'false').strip().lower() == 'true'
    mem_size    = int(cfg.get('mem_size_bytes',   DEFAULT_MEM_SIZE))
    line_bytes  = int(cfg.get('cache_line_bytes', DEFAULT_LINE_BYTES))
    page_size   = int(cfg.get('page_size_bytes',  DEFAULT_PAGE_SIZE))
    meta_dir    = cfg['output_metaData_Path']
    extra_flags = cfg.get('gcc_extra_flags', [])
    meta_dir    = cfg['output_metaData_Path']

    make_dir(meta_dir)

    if use_program:
        # ── Compiled .s path ──────────────────────────────────────────────────
        vm_mappings = cfg.get('VM_Mappings', [])
        if not vm_mappings:
            sys.exit("[compile] VM_Mappings is empty – nothing to put in physical image.")

        src_path = cfg['input_Program_Path']
        print(f"[compile] Source: {src_path}")

        pp_tmp = tempfile.mkdtemp()
        try:
            pp_src = preprocess_source(src_path, extra_flags, pp_tmp)
        except Exception:
            shutil.rmtree(pp_tmp, ignore_errors=True)
            raise

        print(f"[compile] Assembling into sparse 32-bit VA image ...")
        va_pages, sections_out, elf_path, tmp_dir = \
            assemble_to_sparse(pp_src, page_size)
        print(f"[compile] {len(va_pages)} sparse VA page(s) assembled.")

        shutil.rmtree(pp_tmp, ignore_errors=True)

        print(f"[compile] Applying {len(vm_mappings)} VM mapping(s) ...")
        phys_image, vm_records, warnings = apply_vm_mappings(
            va_pages, vm_mappings, page_size, mem_size, randomize)
        print(f"[compile] Physical image: {mem_size} B")

        bin_out = os.path.join(meta_dir, 'program.bin')
        with open(bin_out, 'wb') as f:
            f.write(phys_image)
        print(f"[compile] Saved binary         → {bin_out}")

        write_flat_hex(phys_image, line_bytes,
                       os.path.join(meta_dir, 'program_flat.hex'))
        write_readmemh_flat(phys_image, line_bytes,
                            os.path.join(meta_dir, 'program_readmemh.hex'))

        write_diagnostic_report(
            out_path     = os.path.join(meta_dir, 'segment_vm_report.txt'),
            src_path     = src_path,
            vm_records   = vm_records,
            warnings     = warnings,
            sections_out = sections_out,
            page_size    = page_size,
            mem_size     = mem_size,
            va_pages     = va_pages,
        )

        if elf_path and os.path.isfile(elf_path):
            write_instruction_listing(
                elf_path,
                os.path.join(meta_dir, 'program_instructions.txt')
            )

        shutil.rmtree(tmp_dir, ignore_errors=True)

    else:
        # ── Pre-built annotated hex dump path ─────────────────────────────────
        # Addresses in the hex dump are treated as physical byte offsets.
        # VM_Mappings is intentionally ignored for this path.
        hex_path = cfg['input_hex_file']
        print(f"[compile] Loading annotated hex dump (direct physical write): {hex_path}")

        phys_image, sections_out, warnings = load_hex_to_physical(
            hex_path, mem_size, randomize)
        print(f"[compile] Physical image: {mem_size} B  (no VM translation)")

        bin_out = os.path.join(meta_dir, 'program.bin')
        with open(bin_out, 'wb') as f:
            f.write(phys_image)
        print(f"[compile] Saved binary         → {bin_out}")

        write_flat_hex(phys_image, line_bytes,
                       os.path.join(meta_dir, 'program_flat.hex'))
        write_readmemh_flat(phys_image, line_bytes,
                            os.path.join(meta_dir, 'program_readmemh.hex'))

        write_hex_diagnostic_report(
            out_path     = os.path.join(meta_dir, 'segment_vm_report.txt'),
            hex_path     = hex_path,
            sections_out = sections_out,
            warnings     = warnings,
            mem_size     = mem_size,
            phys_image   = phys_image,
        )

    print("[compile] Done.")


if __name__ == '__main__':
    main()