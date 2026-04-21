"""AT&T syntax x86-32 assembly parser.

Two-phase approach:
1. Parse .s file text to extract data sections and symbol addresses.
2. Use GNU as/ld/objdump to get real instruction bytes and addresses.
   Falls back to text-only parsing if toolchain unavailable.
"""

import re
import os
import subprocess
import tempfile


def _run(cmd):
    """subprocess.run wrapper compatible with Python 3.6."""
    return subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)


class Instruction:
    """Parsed instruction representation."""
    def __init__(self, addr, size, mnemonic, operands, raw="", size_suffix=None):
        self.addr = addr              # virtual address of this instruction
        self.size = size              # byte size of encoded instruction
        self.mnemonic = mnemonic      # e.g. "add", "jmp", "hlt"
        self.operands = operands      # list of Operand
        self.raw = raw
        self.size_suffix = size_suffix  # 'b', 'w', 'l', or None

    def __repr__(self):
        ops = ", ".join(str(o) for o in self.operands)
        return f"0x{self.addr:08X}: {self.mnemonic} {ops}"


class Operand:
    """Represents a single operand."""
    # Types: 'imm', 'reg', 'mem'
    def __init__(self, typ, **kwargs):
        self.typ = typ
        self.imm_val = kwargs.get("imm_val", None)       # immediate value
        self.reg_name = kwargs.get("reg_name", None)      # register name (no %)
        self.base_reg = kwargs.get("base_reg", None)      # memory base (no %)
        self.index_reg = kwargs.get("index_reg", None)    # memory index (no %)
        self.scale = kwargs.get("scale", 1)               # SIB scale
        self.disp = kwargs.get("disp", 0)                 # displacement
        self.seg_prefix = kwargs.get("seg_prefix", None)  # segment override
        # For far jump pointer
        self.far_seg = kwargs.get("far_seg", None)
        self.far_off = kwargs.get("far_off", None)

    def __repr__(self):
        if self.typ == 'imm':
            return f"${hex(self.imm_val)}"
        if self.typ == 'reg':
            return f"%{self.reg_name}"
        if self.typ == 'mem':
            parts = []
            if self.disp:
                parts.append(hex(self.disp))
            inner = []
            if self.base_reg:
                inner.append(f"%{self.base_reg}")
            if self.index_reg:
                inner.append(f"%{self.index_reg}")
                inner.append(str(self.scale))
            parts.append(f"({','.join(inner)})")
            return "".join(parts)
        return "?"


def _parse_int(s):
    """Parse an integer from string, handling hex and decimal."""
    s = s.strip()
    if s.startswith("0x") or s.startswith("0X"):
        return int(s, 16)
    if s.startswith("-0x") or s.startswith("-0X"):
        return -int(s[1:], 16)
    if s.startswith("-"):
        return int(s)
    return int(s, 0)


# Memory operand regex: disp(base,index,scale) with all parts optional
_MEM_RE = re.compile(
    r'^'
    r'(?:([a-z]{2}):)?'               # optional segment prefix
    r'([-+]?(?:0[xX][0-9a-fA-F]+|\d+))?' # optional displacement
    r'\('
    r'(?:%([a-z]+))?'                  # optional base
    r'(?:,%([a-z]+))?'                 # optional index
    r'(?:,(\d+))?'                     # optional scale
    r'\)$'
)


def _parse_operand(tok, is_branch=False):
    """Parse a single operand token from objdump output.
    is_branch: if True, bare hex numbers are branch targets (imm);
               otherwise they are direct memory addresses (mem)."""
    tok = tok.strip()

    # Immediate
    if tok.startswith("$"):
        val_str = tok[1:]
        return Operand('imm', imm_val=_parse_int(val_str))

    # Segment-prefixed memory: %ds:disp(base,index,scale) or %es:(%edi)
    if tok.startswith("%") and ":" in tok:
        colon_idx = tok.index(":")
        seg = tok[1:colon_idx].lower()
        rest = tok[colon_idx+1:]
        if seg in ('cs', 'ds', 'ss', 'es', 'fs', 'gs'):
            m = _MEM_RE.match(rest)
            if m:
                disp_s = m.group(2)
                base = m.group(3)
                index = m.group(4)
                scale = int(m.group(5)) if m.group(5) else 1
                disp = _parse_int(disp_s) if disp_s else 0
                return Operand('mem', base_reg=base, index_reg=index, scale=scale,
                               disp=disp, seg_prefix=seg)

    # Register
    if tok.startswith("%"):
        return Operand('reg', reg_name=tok[1:].lower())

    # Far pointer: 0x1234:0x5678
    if ":" in tok and "(" not in tok:
        parts = tok.split(":")
        seg = _parse_int(parts[0])
        off = _parse_int(parts[1])
        return Operand('mem', far_seg=seg, far_off=off)

    # Memory operand
    m = _MEM_RE.match(tok)
    if m:
        seg = m.group(1)
        disp_s = m.group(2)
        base = m.group(3)
        index = m.group(4)
        scale = int(m.group(5)) if m.group(5) else 1
        disp = _parse_int(disp_s) if disp_s else 0
        return Operand('mem', base_reg=base, index_reg=index, scale=scale,
                       disp=disp, seg_prefix=seg)

    # Plain hex number: branch target (imm) or direct memory address (mem)
    # For branch targets, objdump always emits bare hex addresses (e.g. "102c")
    # without 0x prefix — parse as hex first to avoid misinterpreting as decimal.
    if is_branch:
        try:
            val = int(tok, 16)
            return Operand('imm', imm_val=val)
        except ValueError:
            pass

    try:
        val = _parse_int(tok)
        if is_branch:
            return Operand('imm', imm_val=val)
        else:
            return Operand('mem', disp=val)
    except ValueError:
        pass

    raise ValueError(f"Cannot parse operand: {tok}")


def _split_operands(s):
    """Split comma-separated operands respecting parentheses."""
    result = []
    depth = 0
    current = []
    for ch in s:
        if ch == '(':
            depth += 1
        elif ch == ')':
            depth -= 1
        elif ch == ',' and depth == 0:
            result.append("".join(current).strip())
            current = []
            continue
        current.append(ch)
    if current:
        result.append("".join(current).strip())
    return [r for r in result if r]


def assemble_and_disassemble(asm_path):
    """Assemble .s file and return objdump disassembly + binary data sections.
    Returns (objdump_text, data_bytes_dict) where data_bytes_dict maps vaddr -> bytes."""
    with tempfile.TemporaryDirectory() as tmpdir:
        obj_path = os.path.join(tmpdir, "prog.o")
        elf_path = os.path.join(tmpdir, "prog.elf")
        bin_path = os.path.join(tmpdir, "prog.bin")

        # Preprocess: replace .code with .text, fix .org for gas compatibility
        with open(asm_path) as f:
            src = f.read()

        # Extract .org addresses BEFORE modifying source
        text_org, data_org = _extract_orgs(src)

        # gas doesn't support .code as section directive; replace with .text
        processed = src.replace(".code", ".text")
        # Move ".org <addr>\n .data" to ".data" (strip the .org, linker handles it)
        import re as _re
        processed = _re.sub(
            r'\.org\s+(0x[0-9a-fA-F]+|\d+)\s*\n(\s*\.data)',
            r'\2',
            processed
        )
        # Strip all remaining .org directives — the linker script places sections
        processed = _re.sub(r'^\s*\.org\s+(0x[0-9a-fA-F]+|\d+)\s*$', '', processed, flags=_re.MULTILINE)

        proc_path = os.path.join(tmpdir, "prog.s")
        with open(proc_path, 'w') as f:
            f.write(processed)

        # Assemble
        r = _run(["as", "--32", "-o", obj_path, proc_path])
        if r.returncode != 0:
            raise RuntimeError(f"Assembly failed:\n{r.stderr}")

        # Link — place sections at their .org addresses so labels resolve correctly
        ld_script = os.path.join(tmpdir, "link.ld")
        with open(ld_script, 'w') as f:
            f.write('OUTPUT_FORMAT("elf32-i386")\n'
                    'ENTRY(_start)\n'
                    'SECTIONS {\n'
                    f'    . = 0x{text_org:X};\n'
                    '    .text : { *(.text) }\n'
                    f'    . = 0x{data_org:X};\n'
                    '    .data : { *(.data) }\n'
                    '}\n')

        r = _run(["ld", "-m", "elf_i386", "-T", ld_script, "-o", elf_path, obj_path])
        if r.returncode != 0:
            raise RuntimeError(f"Linking failed:\n{r.stderr}")

        # Disassemble text section
        r = _run(["objdump", "-d", "-M", "att", "--no-show-raw-insn", elf_path])
        if r.returncode != 0:
            raise RuntimeError(f"objdump failed:\n{r.stderr}")
        objdump_text = r.stdout

        # Also get raw disassembly with bytes for instruction sizes
        r2 = _run(["objdump", "-d", "-M", "att", elf_path])
        objdump_raw = r2.stdout

        # Extract data section binary
        r = _run(["objcopy", "-O", "binary", "-j", ".data", elf_path, bin_path])
        data_bytes = {}
        if r.returncode == 0 and os.path.exists(bin_path):
            with open(bin_path, 'rb') as f:
                data_bytes[data_org] = f.read()

        return objdump_text, objdump_raw, data_bytes, text_org, data_org


def _extract_orgs(src):
    """Extract .org values for text and data sections from source.
    Handles both '.org X / .data' (org before directive) and '.data / .org X' orderings."""
    text_org = 0x1000
    data_org = 0x56559000
    in_data = False
    lines = src.split("\n")
    for i, line in enumerate(lines):
        stripped = line.strip().lower()
        if stripped.startswith(".data"):
            in_data = True
        elif stripped.startswith(".code") or stripped.startswith(".text"):
            in_data = False
        elif stripped.startswith(".org"):
            val = _parse_int(stripped.split()[1])
            if in_data:
                data_org = val
            else:
                # Check if the next non-blank line is .data — if so, this org
                # belongs to the data section, not the text section.
                is_data_org = False
                for j in range(i + 1, len(lines)):
                    next_s = lines[j].strip().lower()
                    if not next_s or next_s.startswith("#"):
                        continue
                    if next_s.startswith(".data"):
                        is_data_org = True
                    break
                if is_data_org:
                    data_org = val
                else:
                    text_org = val
    return text_org, data_org


def parse_objdump(objdump_text, objdump_raw):
    """Parse objdump output into list of Instruction objects.
    Uses raw output (with bytes) to get instruction sizes."""

    # Build addr -> byte_count map from raw output
    size_map = {}
    for line in objdump_raw.split("\n"):
        line = line.strip()
        if not line or ":" not in line:
            continue
        # Format: "    1000:	04 01                	add    $0x1,%al"
        m = re.match(r'^\s*([0-9a-fA-F]+):\s+((?:[0-9a-fA-F]{2}\s)+)', line)
        if m:
            addr = int(m.group(1), 16)
            byte_str = m.group(2).strip()
            num_bytes = len(byte_str.split())
            size_map[addr] = num_bytes

    instructions = []
    for line in objdump_text.split("\n"):
        line = line.strip()
        if not line or ":" not in line:
            continue
        # Skip section headers and labels
        if line.endswith(":") or line.startswith("Disassembly"):
            continue
        if not re.match(r'^\s*[0-9a-fA-F]+:', line):
            continue

        # Format: "    1000:	add    $0x1,%al"
        m = re.match(r'^\s*([0-9a-fA-F]+):\s+(.+)$', line)
        if not m:
            continue

        addr = int(m.group(1), 16)
        rest = m.group(2).strip()

        # Split mnemonic and operands
        parts = rest.split(None, 1)
        mnemonic = parts[0].lower()

        # Handle REP/REPE/REPNE prefix
        rep_prefix = None
        if mnemonic in ('rep', 'repe', 'repz', 'repne', 'repnz'):
            rep_prefix = mnemonic
            if len(parts) > 1:
                sub_rest = parts[1].strip()
                sub_parts = sub_rest.split(None, 1)
                mnemonic = sub_parts[0].lower()
                if len(sub_parts) > 1:
                    parts = [mnemonic, sub_parts[1]]
                else:
                    parts = [mnemonic]
            else:
                parts = [mnemonic]

        # Strip size suffixes that objdump sometimes adds (addl -> add, movl -> mov)
        # But keep jmp, jne etc as-is, and keep MMX mnemonics whole (their
        # trailing b/w/d is part of the name, not a size suffix).
        _MMX_MNEMONICS = frozenset({
            'packsswb', 'packssdw',
            'paddw', 'paddd',
            'pavgb', 'pavgw',
            'movq', 'movd',
        })
        size_suffix = None
        clean_mnemonic = mnemonic
        if (mnemonic not in ("hlt", "nop")
                and mnemonic not in _MMX_MNEMONICS
                and not mnemonic.startswith("j")
                and not mnemonic.startswith("call")
                and not mnemonic.startswith("ret")):
            # Strip trailing b/w/l suffix if present.
            # Exclude last-two-char combos where the 'b'/'w'/'l' is part of
            # the mnemonic itself, not a size suffix:
            #   'al' → sal/sar  'bb' → sbb  'ub' → sub  'ul' → mul/imul
            _NO_STRIP_ENDINGS = ('al', 'bb', 'ub', 'ul', 'hl')
            if len(mnemonic) > 2 and mnemonic[-1] in ('b', 'w', 'l') and mnemonic[-2:] not in _NO_STRIP_ENDINGS:
                size_suffix = mnemonic[-1]
                clean_mnemonic = mnemonic[:-1]

        # Re-add rep prefix
        if rep_prefix:
            clean_mnemonic = "rep_" + clean_mnemonic

        operands = []
        if len(parts) > 1:
            op_str = parts[1].strip()
            # Remove trailing comments from objdump (e.g. "# 0x1050 <_start+0x50>")
            # But be careful not to strip hex prefixes
            if "#" in op_str:
                op_str = op_str[:op_str.index("#")].strip()
            if "<" in op_str:
                op_str = op_str[:op_str.index("<")].strip().rstrip(",").strip()

            op_tokens = _split_operands(op_str)
            is_branch = mnemonic.startswith("j") or mnemonic.startswith("call") or mnemonic.startswith("loop")
            operands = [_parse_operand(o, is_branch=is_branch) for o in op_tokens if o]

        size = size_map.get(addr, 2)  # fallback to 2 bytes
        instructions.append(Instruction(addr, size, clean_mnemonic, operands, rest, size_suffix=size_suffix))

    return instructions


def parse_data_from_source(asm_path):
    """Parse data sections directly from .s source as fallback."""
    with open(asm_path) as f:
        src = f.read()

    data_sections = []
    current_org = None
    in_data = False
    current_data_addr = None
    current_data_bytes = bytearray()
    symbols = {}

    for line in src.split("\n"):
        stripped = line.strip()
        if "#" in stripped:
            stripped = stripped[:stripped.index("#")].strip()
        if not stripped:
            continue

        low = stripped.lower()
        if low.startswith(".org"):
            val = _parse_int(stripped.split()[1])
            current_org = val
            if in_data:
                if current_data_bytes and current_data_addr is not None:
                    data_sections.append((current_data_addr, bytes(current_data_bytes)))
                current_data_addr = val
                current_data_bytes = bytearray()
            continue
        if low.startswith(".data"):
            in_data = True
            if current_org is not None:
                current_data_addr = current_org
            continue
        if low.startswith(".code") or low.startswith(".text"):
            in_data = False
            continue

        if in_data:
            if stripped.endswith(":"):
                label = stripped[:-1].strip()
                addr = current_data_addr + len(current_data_bytes) if current_data_addr else 0
                symbols[label] = addr
                continue
            if low.startswith(".long"):
                val = _parse_int(stripped.split()[1])
                current_data_bytes.extend(val.to_bytes(4, 'little'))
            elif low.startswith(".word"):
                val = _parse_int(stripped.split()[1])
                current_data_bytes.extend((val & 0xFFFF).to_bytes(2, 'little'))
            elif low.startswith(".byte"):
                val = _parse_int(stripped.split()[1])
                current_data_bytes.append(val & 0xFF)

    if current_data_bytes and current_data_addr is not None:
        data_sections.append((current_data_addr, bytes(current_data_bytes)))

    return data_sections, symbols
