#!/usr/bin/env python3
"""
compile.py  (v4 – sections written into sparse dict at translated VA)
---------------------------------------------------------------------
Key change from v3:
  After assembling, each ELF section's data is placed into the sparse
  VA page dict at its TRANSLATED virtual address (seg_val << 16 + org),
  not at the raw .org address.  This means VM_Mappings can use the
  post-translation VAs that the TLB is hardcoded to.

  The translation used here is:
      translated_VA = org_addr + (seg_val << 16)
  where seg_val is looked up from SegmentMappings by finding the entry
  whose logical_base page contains the section's .org address.

  If no SegmentMapping covers a section, it is written at its raw .org
  address (identity / CS0 behaviour).
"""

import json, sys, os, struct, subprocess, tempfile, random, re, argparse, shutil

DEFAULT_MEM_SIZE   = 32 * 1024
DEFAULT_LINE_BYTES = 16
DEFAULT_PAGE_SIZE  = 4096
SEG_REG_BITS       = 16

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


# ── sparse VA page dict helpers ───────────────────────────────────────────────

def sparse_write(pages: dict, addr: int, data: bytes, page_size: int):
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
#  STAGE A – Segment translation
# ══════════════════════════════════════════════════════════════════════════════

def compute_segment_values(seg_mappings: list) -> list:
    results = []
    for entry in seg_mappings:
        if len(entry) != 3:
            sys.exit(f"[compile] SegmentMappings entry must have 3 elements: {entry}")
        logical_base = parse_int(entry[0])
        va_base      = parse_int(entry[1])
        macro        = str(entry[2]).strip()

        diff = va_base - logical_base
        if diff < 0:
            sys.exit(f"[compile] Segment mapping for {macro}: "
                     f"va_base (0x{va_base:08x}) < logical_base (0x{logical_base:05x}).")
        if diff % (1 << SEG_REG_BITS) != 0:
            print(f"[compile] WARNING: for {macro}: "
                  f"(va_base - logical_base) = 0x{diff:x} is not a multiple of "
                  f"0x{(1<<SEG_REG_BITS):x}.  seg_val will be truncated.")
        seg_val  = diff >> SEG_REG_BITS
        check_va = logical_base + (seg_val << SEG_REG_BITS)
        results.append({
            'macro'       : macro,
            'logical_base': logical_base,
            'va_base'     : va_base,
            'seg_val'     : seg_val,
            'check_va'    : check_va,
        })
    return results


def find_seg_for_org(org_addr: int, seg_values: list) -> dict | None:
    """
    Return the SegmentMapping entry whose logical_base page contains org_addr.
    We pick the entry with the largest logical_base that is <= org_addr
    (closest enclosing segment base).
    Returns None if no entry qualifies (identity mapping / CS0 with seg_val=0).
    """
    candidates = [sv for sv in seg_values if sv['logical_base'] <= org_addr]
    if not candidates:
        return None
    return max(candidates, key=lambda sv: sv['logical_base'])


def translate_org_to_va(org_addr: int, seg_values: list) -> int:
    """
    Apply segment translation to a raw .org address.
    translated_VA = org_addr + (seg_val << 16)
    Falls back to identity if no matching segment found.
    """
    sv = find_seg_for_org(org_addr, seg_values)
    if sv is None or sv['seg_val'] == 0:
        return org_addr
    return org_addr + (sv['seg_val'] << SEG_REG_BITS)


def preprocess_source(src_path: str, seg_values: list,
                      extra_flags: list, tmp_dir: str) -> str:
    with open(src_path) as f:
        original = f.read()

    patched = original
    replaced_macros = set()
    for sv in seg_values:
        macro   = sv['macro']
        pattern = re.compile(
            rf'^([ \t]*#[ \t]*define[ \t]+{re.escape(macro)})([ \t]*)$',
            re.MULTILINE
        )
        replacement = f'#define {macro} 0x{sv["seg_val"]:04x}'
        new_src, n = pattern.subn(replacement, patched)
        if n > 0:
            patched = new_src
            replaced_macros.add(macro)

    remaining = [sv for sv in seg_values if sv['macro'] not in replaced_macros]
    if remaining:
        extra_defs = '\n'.join(f'#define {sv["macro"]} 0x{sv["seg_val"]:04x}'
                               for sv in remaining) + '\n'
        patched = extra_defs + patched

    macro_file = os.path.join(tmp_dir, 'prog_macros.s')
    with open(macro_file, 'w') as f:
        f.write(patched)

    pp_file = os.path.join(tmp_dir, 'prog_pp.s')
    cmd = ['gcc', '-E', '-x', 'assembler-with-cpp',
           '-m32', '-o', pp_file, macro_file] + extra_flags
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        sys.exit(f"[compile] gcc -E failed:\n{r.stderr}")

    print(f"[compile] Preprocessed source  → {pp_file}")
    return pp_file


# ══════════════════════════════════════════════════════════════════════════════
#  STAGE B – Assembler  (writes sparse dict at TRANSLATED VAs)
# ══════════════════════════════════════════════════════════════════════════════

def parse_sections(src: str) -> list:
    sections = []
    counters = {'code': 0, 'data': 0}
    pending  = None
    for line in src.splitlines():
        stripped = re.sub(r'(//|#).*$', '', line).strip()
        if not stripped:
            continue
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
                pending = None
                break
    return sections


def _section_name(sec: dict) -> str:
    return f".{sec['kind']}{sec['index']}"


def convert_pseudo_to_gas(src: str, sections: list) -> str:
    iters = {
        'code': iter([s for s in sections if s['kind'] == 'code']),
        'data': iter([s for s in sections if s['kind'] == 'data']),
    }
    lines = []
    for line in src.splitlines():
        out = re.sub(r'//.*$', lambda m: '# ' + m.group(0)[2:], line)
        if re.match(r'\s*\.org\b', out):
            lines.append('# ' + out.lstrip())
            continue
        matched = False
        for kind, flags in (('code', '"ax", @progbits'),
                             ('data', '"aw", @progbits')):
            if re.match(rf'\s*\.{kind}\b', out):
                sec    = next(iters[kind])
                sname  = _section_name(sec)
                indent = re.match(r'(\s*)', out).group(1)
                lines.append(f'{indent}.section {sname}, {flags}')
                matched = True
                break
        if not matched:
            lines.append(out)
    return '\n'.join(lines) + '\n'


def assemble_to_va_image(src_path: str, page_size: int,
                         seg_values: list) -> tuple:
    """
    Assemble source → ELF, then write each section into the sparse VA dict
    at its TRANSLATED virtual address (org + seg_val<<16).

    Returns
    -------
    va_pages     : dict { translated_page_base: bytearray(page_size) }
    base_addr    : lowest translated VA
    top_addr     : one past highest translated VA byte
    sections_out : list of {'name', 'org', 'translated_va'}
    elf_path     : path to temp ELF
    tmp_dir      : temp dir to clean up
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

    r = subprocess.run(['as', '--32', '-o', o_file, s_file],
                       capture_output=True, text=True)
    if r.returncode != 0:
        shutil.rmtree(tmp, ignore_errors=True)
        sys.exit(f"[compile] GNU as failed:\n{r.stderr}")

    section_lines = [
        f"  {_section_name(sec)} 0x{sec['org']:x} : {{ *({_section_name(sec)}) }}"
        for sec in sections_meta
    ]
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

    r = subprocess.run(['ld', '-m', 'elf_i386', '-T', ld_file,
                        '-o', elf_file, o_file],
                       capture_output=True, text=True)
    if r.returncode != 0:
        shutil.rmtree(tmp, ignore_errors=True)
        sys.exit(f"[compile] ld failed:\n{r.stderr}")

    r = subprocess.run(['objdump', '-h', elf_file], capture_output=True, text=True)
    if r.returncode != 0:
        shutil.rmtree(tmp, ignore_errors=True)
        sys.exit(f"[compile] objdump -h failed:\n{r.stderr}")

    wanted   = {_section_name(s) for s in sections_meta}
    sec_info = []
    for line in r.stdout.splitlines():
        m = re.match(
            r'\s*\d+\s+(\S+)\s+([0-9a-fA-F]+)\s+([0-9a-fA-F]+)'
            r'\s+[0-9a-fA-F]+\s+([0-9a-fA-F]+)', line)
        if m:
            name    = m.group(1)
            size    = int(m.group(2), 16)
            vma     = int(m.group(3), 16)   # this is the .org address
            fileoff = int(m.group(4), 16)
            if name in wanted and size > 0:
                sec_info.append((name, vma, size, fileoff))

    if not sec_info:
        shutil.rmtree(tmp, ignore_errors=True)
        sys.exit("[compile] No relevant sections found in ELF.")

    with open(elf_file, 'rb') as f:
        elf_raw = f.read()

    # Build org→section lookup for translated_va computation
    org_to_meta = {s['org']: s for s in sections_meta}

    va_pages  = {}
    base_addr = 0xFFFFFFFF
    top_addr  = 0
    sections_out = []

    for name, org_addr, size, fileoff in sec_info:
        # Translate the .org address to the post-segment VA
        translated_va = translate_org_to_va(org_addr, seg_values)
        data = elf_raw[fileoff : fileoff + size]
        sparse_write(va_pages, translated_va, data, page_size)
        base_addr = min(base_addr, translated_va)
        top_addr  = max(top_addr,  translated_va + size)

        name_to_kind = {_section_name(s): s['kind'] for s in sections_meta}
        sections_out.append({
            'name'         : name_to_kind.get(name, name),
            'org'          : org_addr,
            'translated_va': translated_va,
        })
        sv = find_seg_for_org(org_addr, seg_values)
        seg_label = f"seg_val=0x{sv['seg_val']:04x} ({sv['macro']})" if sv else "identity"
        print(f"[compile]   {name:<12s}  org=0x{org_addr:08x}  "
              f"→ translated_VA=0x{translated_va:08x}  size={size} B  [{seg_label}]")

    if base_addr == 0xFFFFFFFF:
        base_addr = 0

    sections_out.sort(key=lambda s: s['translated_va'])
    return va_pages, base_addr, top_addr, sections_out, elf_file, tmp


# ══════════════════════════════════════════════════════════════════════════════
#  STAGE C – VM mapping
# ══════════════════════════════════════════════════════════════════════════════

def apply_vm_mappings(va_pages: dict,
                      vm_mappings: list,
                      page_size: int,
                      mem_size: int,
                      randomize: bool) -> tuple:
    n_frames    = mem_size // page_size
    max_frame   = n_frames - 1
    phys_image  = random_fill(mem_size) if randomize else zero_fill(mem_size)
    records     = []
    seen_frames = set()

    for entry in vm_mappings:
        if len(entry) != 2:
            sys.exit(f"[compile] VM_Mappings entry must have 2 elements: {entry}")
        va_raw  = parse_int(entry[0])
        frame   = parse_int(entry[1])
        va_page = va_raw & ~(page_size - 1)
        phys_base = frame * page_size

        if frame < 0 or frame > max_frame:
            sys.exit(f"[compile] VM_Mappings frame {frame} out of range [0,{max_frame}].")
        if frame in seen_frames:
            print(f"[compile] WARNING: frame {frame} mapped more than once.")
        seen_frames.add(frame)

        if va_page not in va_pages:
            records.append({
                'va_page': va_page, 'va_raw': va_raw, 'frame': frame,
                'phys_base': phys_base,
                'status': 'VA page not in sparse image – background fill',
            })
            continue

        page_data = va_pages[va_page]
        phys_image[phys_base : phys_base + page_size] = page_data

        non_zero = [i for i, b in enumerate(page_data) if b != 0]
        summary  = (f"{len(non_zero)} non-zero bytes, "
                    f"range [+0x{non_zero[0]:03x}, +0x{non_zero[-1]:03x}]"
                    if non_zero else "all zero")
        records.append({
            'va_page': va_page, 'va_raw': va_raw, 'frame': frame,
            'phys_base': phys_base, 'status': summary,
        })

    return phys_image, records


# ══════════════════════════════════════════════════════════════════════════════
#  STAGE D – Diagnostic report
# ══════════════════════════════════════════════════════════════════════════════

def write_diagnostic_report(out_path, src_path, seg_values, vm_records,
                             sections_out, page_size, mem_size,
                             va_base_addr, va_top_addr, va_pages):
    DIV  = '═' * 78
    div2 = '─' * 78

    with open(out_path, 'w') as f:
        f.write(DIV + '\n')
        f.write('  memGen v4  –  Segment + Virtual Memory Diagnostic Report\n')
        f.write(DIV + '\n\n')
        f.write(f'  Source file  : {src_path}\n')
        f.write(f'  Page size    : {page_size} B  (0x{page_size:x})\n')
        f.write(f'  Phys mem     : {mem_size} B  (0x{mem_size:x})\n')
        f.write(f'  VA span      : 0x{va_base_addr:08x} – 0x{va_top_addr:08x}\n')
        f.write(f'  Sparse pages : {len(va_pages)} allocated\n\n')

        # Section 1 – segment values
        f.write(DIV + '\n')
        f.write('  SECTION 1 – Segment Register Values\n')
        f.write(DIV + '\n\n')
        f.write('  VA = logical_addr + (seg_reg << 16)\n\n')
        f.write(f"  {'Macro':<20}  {'logical_base':>12}  {'VA_base':>12}  "
                f"{'seg_val':>10}  {'verify':>12}\n")
        f.write(div2 + '\n')
        for sv in seg_values:
            ok = '✓' if sv['check_va'] == sv['va_base'] else '✗ MISMATCH'
            f.write(f"  {sv['macro']:<20}  0x{sv['logical_base']:08x}    "
                    f"0x{sv['va_base']:08x}  "
                    f"0x{sv['seg_val']:04x}      "
                    f"0x{sv['check_va']:08x}  {ok}\n")
        f.write('\n')

        # Section 2 – section placement (org → translated VA)
        f.write(DIV + '\n')
        f.write('  SECTION 2 – ELF Section Placement  (org → translated VA)\n')
        f.write(DIV + '\n\n')
        f.write(f"  {'Section':<10}  {'org (.org addr)':>16}  "
                f"{'translated VA':>14}  {'sparse page':>12}\n")
        f.write(div2 + '\n')
        for s in sections_out:
            pg = s['translated_va'] & ~(page_size - 1)
            f.write(f"  {s['name']:<10}  0x{s['org']:08x}            "
                    f"0x{s['translated_va']:08x}    "
                    f"0x{pg:08x}\n")
        f.write('\n')

        # Section 3 – VM mappings
        f.write(DIV + '\n')
        f.write('  SECTION 3 – Virtual → Physical Page Mappings (TLB)\n')
        f.write(DIV + '\n\n')
        f.write(f"  {'#':>2}  {'VA (raw)':>12}  {'VA page':>12}  "
                f"{'frame':>6}  {'phys base':>12}  Contents\n")
        f.write(div2 + '\n')
        for i, r in enumerate(vm_records):
            f.write(f"  {i:>2}  0x{r['va_raw']:08x}    "
                    f"0x{r['va_page']:08x}  "
                    f"     {r['frame']:>1}    "
                    f"0x{r['phys_base']:08x}  {r['status']}\n")
        f.write('\n')

        # Section 4 – sparse page inventory
        f.write(DIV + '\n')
        f.write('  SECTION 4 – Sparse VA Page Inventory\n')
        f.write(DIV + '\n\n')
        f.write(f"  {'Page base':>12}  {'non-zero':>10}  "
                f"{'first nz':>10}  {'last nz':>10}\n")
        f.write(div2 + '\n')
        for pg in sorted(va_pages):
            data = va_pages[pg]
            nz   = [i for i, b in enumerate(data) if b != 0]
            f.write(f"  0x{pg:08x}  {len(nz):>10d}  "
                    f"{'%+5d' % nz[0] if nz else '—':>10}  "
                    f"{'%+5d' % nz[-1] if nz else '—':>10}\n")
        f.write('\n')
        f.write(DIV + '\n  End of report\n' + DIV + '\n')

    print(f"[compile] Wrote diagnostic report → {out_path}")


# ══════════════════════════════════════════════════════════════════════════════
#  Hex / listing writers
# ══════════════════════════════════════════════════════════════════════════════

def write_flat_hex(image: bytearray, line_bytes: int, out_path: str):
    n_lines = len(image) // line_bytes
    with open(out_path, 'w') as f:
        f.write(f"// Flat physical memory image  total={len(image)} B  "
                f"line_size={line_bytes} B  total_lines={n_lines}\n\n")
        for ln in range(n_lines):
            addr  = ln * line_bytes
            chunk = image[addr: addr + line_bytes]
            groups = ['  '.join(f'{b:02x}' for b in chunk[g:g+4])
                      for g in range(0, line_bytes, 4)]
            f.write(f"// $line_{ln:<5d}  addr: 0x{addr:04x}\n")
            f.write('  ' + '  '.join(groups) + '\n\n')
    print(f"[compile] Wrote flat hex       → {out_path}")


def write_sections_hex(image, sections, base_addr, top_addr, line_bytes, out_path):
    addr_to_sec = {s['translated_va']: s['name'] for s in sections}
    n_lines     = len(image) // line_bytes
    with open(out_path, 'w') as f:
        f.write(f"// Sections hex  line_size={line_bytes} B\n\n")
        for ln in range(n_lines):
            addr     = ln * line_bytes
            line_end = addr + line_bytes
            if line_end <= base_addr or addr >= top_addr:
                continue
            chunk  = image[addr: addr + line_bytes]
            groups = ['  '.join(f'{b:02x}' for b in chunk[g:g+4])
                      for g in range(0, line_bytes, 4)]
            note = ''.join(f'  ← {addr_to_sec[a]} starts'
                           for a in range(addr, line_end) if a in addr_to_sec)
            f.write(f"// $line_{ln:<5d}  addr: 0x{addr:04x}{note}\n")
            f.write('  ' + '  '.join(groups) + '\n\n')
    print(f"[compile] Wrote sections hex   → {out_path}")


def write_readmemh_flat(image: bytearray, line_bytes: int, out_path: str):
    with open(out_path, 'w') as f:
        f.write("// readmemh flat image\n")
        n_lines = len(image) // line_bytes
        for ln in range(n_lines):
            addr  = ln * line_bytes
            chunk = image[addr: addr + line_bytes]
            f.write(f"// $line_{ln}  @{addr:04x}\n@{addr:04x}\n")
            for b in chunk:
                f.write(f"{b:02x}\n")
    print(f"[compile] Wrote readmemh flat  → {out_path}")


def write_instruction_listing(elf_path: str, sections: list, out_path: str):
    r_raw   = subprocess.run(['objdump', '-d', elf_path],
                             capture_output=True, text=True)
    r_intel = subprocess.run(
        ['objdump', '-d', '-M', 'intel', '--no-show-raw-insn', elf_path],
        capture_output=True, text=True)
    if r_raw.returncode != 0 or r_intel.returncode != 0:
        print("[compile] WARNING: objdump -d failed, skipping instruction listing.")
        return

    intel_insn_map = {}
    for line in r_intel.stdout.splitlines():
        m = re.match(r'\s*([0-9a-fA-F]+):\s+(.*)', line)
        if m:
            mn = m.group(2).strip()
            if mn:
                intel_insn_map[int(m.group(1), 16)] = mn

    raw_hex_map    = {}
    last_real_addr = None
    for line in r_raw.stdout.splitlines():
        m = re.match(r'\s*([0-9a-fA-F]+):\s+((?:[0-9a-fA-F]{2}\s)+)', line)
        if not m:
            continue
        addr     = int(m.group(1), 16)
        hex_part = m.group(2).strip()
        if addr in intel_insn_map:
            raw_hex_map[addr] = hex_part
            last_real_addr    = addr
        elif last_real_addr is not None:
            raw_hex_map[last_real_addr] += ' ' + hex_part

    rh = subprocess.run(['objdump', '-h', elf_path], capture_output=True, text=True)
    sec_ranges = []
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

    DIVIDER = '─' * 72
    with open(out_path, 'w') as f:
        f.write("Instruction Listing\n")
        f.write("Generated by compile.py v4  (x86-32, Intel syntax)\n")
        f.write("NOTE: addresses shown are .org (logical) addresses as assembled.\n\n")
        f.write(f"{'EIP (org/logical)':<20}  {'Hex Encoding':<28}  Mnemonic\n")
        f.write(DIVIDER + '\n\n')
        for sec in sec_ranges:
            vma, size, kind = sec['vma'], sec['size'], sec['kind']
            f.write(DIVIDER + '\n')
            f.write(f"Section: {sec['elf_name']}  kind={kind}  "
                    f"org=0x{vma:08x}  size={size} B\n")
            f.write(DIVIDER + '\n')
            if kind == 'data':
                f.write(f"  (data – raw bytes)  "
                        f"0x{vma:08x}–0x{vma+size-1:08x}  ({size} B)\n\n")
                continue
            addrs = sorted(a for a in intel_insn_map if vma <= a < vma + size)
            if not addrs:
                f.write("  (no instructions decoded)\n\n")
                continue
            for addr in addrs:
                f.write(f"  0x{addr:08x}  "
                        f"{raw_hex_map.get(addr,'?'):<28}  "
                        f"{intel_insn_map[addr]}\n")
            f.write('\n')
        total = sum(1 for s in sec_ranges if s['kind'] == 'code'
                    for a in intel_insn_map
                    if s['vma'] <= a < s['vma'] + s['size'])
        f.write(DIVIDER + '\n')
        f.write(f"Total instructions decoded: {total}\n")
    print(f"[compile] Wrote instruction listing → {out_path}")


# ══════════════════════════════════════════════════════════════════════════════
#  MAIN
# ══════════════════════════════════════════════════════════════════════════════

def main():
    ap = argparse.ArgumentParser(
        description="Stage 1 (v4): assemble → sparse VA dict at translated VAs → physical image")
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
    seg_mappings = cfg.get('SegmentMappings', [])
    vm_mappings  = cfg.get('VM_Mappings', [])

    make_dir(meta_dir)

    seg_values = compute_segment_values(seg_mappings)
    if seg_values:
        print(f"[compile] Computed {len(seg_values)} segment register value(s):")
        for sv in seg_values:
            print(f"[compile]   {sv['macro']:<20}  seg_val=0x{sv['seg_val']:04x}  "
                  f"(logical 0x{sv['logical_base']:08x} → VA 0x{sv['va_base']:08x})")
    else:
        print("[compile] No SegmentMappings.")

    elf_path = None
    tmp_dir  = None

    if use_program:
        src_path = cfg['input_Program_Path']
        print(f"[compile] Source: {src_path}")

        pp_tmp = tempfile.mkdtemp()
        try:
            pp_src = preprocess_source(src_path, seg_values, extra_flags, pp_tmp)
        except Exception:
            shutil.rmtree(pp_tmp, ignore_errors=True)
            raise

        print(f"[compile] Assembling (sections placed at translated VAs) ...")
        va_pages, va_base, va_top, sections_out, elf_path, tmp_dir = \
            assemble_to_va_image(pp_src, page_size, seg_values)
        print(f"[compile] VA span: 0x{va_base:08x} – 0x{va_top:08x}  "
              f"| {len(va_pages)} sparse page(s)")

        shutil.rmtree(pp_tmp, ignore_errors=True)

    else:
        hex_path = cfg['input_hex_file']
        print(f"[compile] Loading pre-built hex {hex_path} ...")
        va_pages     = {}
        va_base      = 0xFFFFFFFF
        va_top       = 0
        sections_out = []
        cur_addr     = 0
        buf          = bytearray()
        with open(hex_path) as f:
            for line in f:
                line = line.strip()
                if line.startswith('//') or not line:
                    continue
                if line.startswith('@'):
                    if buf:
                        sparse_write(va_pages, cur_addr - len(buf),
                                     bytes(buf), page_size)
                        buf = bytearray()
                    cur_addr = int(line[1:], 16)
                    va_base  = min(va_base, cur_addr)
                    continue
                b = bytes.fromhex(line)
                buf += b
                cur_addr += len(b)
                va_top = max(va_top, cur_addr)
        if buf:
            sparse_write(va_pages, cur_addr - len(buf), bytes(buf), page_size)
        if va_base == 0xFFFFFFFF:
            va_base = 0

    # VM mapping
    if vm_mappings:
        print(f"[compile] Applying {len(vm_mappings)} VM mapping(s) ...")
        phys_image, vm_records = apply_vm_mappings(
            va_pages, vm_mappings, page_size, mem_size, randomize)
        print(f"[compile] Physical image built  ({mem_size} B)")
    else:
        print("[compile] No VM_Mappings – legacy mode.")
        phys_image = zero_fill(mem_size)
        for pg in sorted(va_pages):
            if pg + page_size <= mem_size:
                phys_image[pg : pg + page_size] = va_pages[pg]
        vm_records = []

    # Outputs
    bin_out = os.path.join(meta_dir, 'program.bin')
    with open(bin_out, 'wb') as f:
        f.write(phys_image)
    print(f"[compile] Saved binary         → {bin_out}")

    write_flat_hex(phys_image, line_bytes,
                   os.path.join(meta_dir, 'program_flat.hex'))

    nz = [i for i, b in enumerate(phys_image) if b != 0]
    phys_base_addr = nz[0]  if nz else 0
    phys_top_addr  = nz[-1] + 1 if nz else mem_size

    write_sections_hex(phys_image, sections_out,
                       phys_base_addr, phys_top_addr, line_bytes,
                       os.path.join(meta_dir, 'program_sections.hex'))

    write_readmemh_flat(phys_image, line_bytes,
                        os.path.join(meta_dir, 'program_readmemh.hex'))

    write_diagnostic_report(
        out_path     = os.path.join(meta_dir, 'segment_vm_report.txt'),
        src_path     = cfg.get('input_Program_Path', cfg.get('input_hex_file', '?')),
        seg_values   = seg_values,
        vm_records   = vm_records,
        sections_out = sections_out,
        page_size    = page_size,
        mem_size     = mem_size,
        va_base_addr = va_base,
        va_top_addr  = va_top,
        va_pages     = va_pages,
    )

    if elf_path and os.path.isfile(elf_path):
        write_instruction_listing(elf_path, sections_out,
                                  os.path.join(meta_dir, 'program_instructions.txt'))
    else:
        print("[compile] Skipping instruction listing (no ELF).")

    if tmp_dir:
        shutil.rmtree(tmp_dir, ignore_errors=True)

    print("[compile] Done.")


if __name__ == '__main__':
    main()
