"""Capstone-based x86-32 instruction decoder.

Replaces the old GNU-toolchain `parser.py`.  Given raw bytes and a linear
address, produces a single `Instruction` whose fields match the contract the
existing `execute.py` dispatch table expects.
"""

from capstone import Cs, CS_ARCH_X86, CS_MODE_32
from capstone.x86 import (
    X86_OP_IMM, X86_OP_REG, X86_OP_MEM,
    X86_PREFIX_REP, X86_PREFIX_REPE, X86_PREFIX_REPNE,
)

# Operand-size override prefix byte (0x66).  Capstone stores raw prefix bytes
# in insn.prefix so we can check membership directly.
_OPSIZE_PREFIX = 0x66


# --------------------------------------------------------------
# Capstone disassembler (singleton).  We use the default Intel syntax for the
# human-readable string; structural decode (operands) is via insn.operands.
# --------------------------------------------------------------
_CS = Cs(CS_ARCH_X86, CS_MODE_32)
_CS.detail = True


# --------------------------------------------------------------
# Instruction / Operand classes — same shape as old parser.py
# --------------------------------------------------------------
class Instruction:
    def __init__(self, addr, size, mnemonic, operands, raw="", size_suffix=None):
        self.addr        = addr        # linear address (CS_base + EIP) at fetch time
        self.size        = size        # encoded byte length
        self.mnemonic    = mnemonic    # lowercase, size-suffix stripped
        self.operands    = operands    # list of Operand
        self.raw         = raw         # human-readable string from Capstone
        self.size_suffix = size_suffix # 'b'/'w'/'l'/'q' or None

    def __repr__(self):
        ops = ", ".join(repr(o) for o in self.operands)
        return f"0x{self.addr:08X}: {self.mnemonic} {ops}"


class Operand:
    def __init__(self, typ, **kwargs):
        self.typ        = typ
        self.imm_val    = kwargs.get("imm_val")
        self.reg_name   = kwargs.get("reg_name")
        self.base_reg   = kwargs.get("base_reg")
        self.index_reg  = kwargs.get("index_reg")
        self.scale      = kwargs.get("scale", 1)
        self.disp       = kwargs.get("disp", 0)
        self.seg_prefix = kwargs.get("seg_prefix")
        self.far_seg    = kwargs.get("far_seg")
        self.far_off    = kwargs.get("far_off")
        self.mem_size   = kwargs.get("mem_size", 0)  # Capstone op.size for MEM operands (bytes)

    def __repr__(self):
        if self.typ == "imm":
            if self.far_seg is not None:
                return f"${hex(self.far_seg)}:${hex(self.far_off)}"
            return f"${hex(self.imm_val)}"
        if self.typ == "reg":
            return f"%{self.reg_name}"
        if self.typ == "mem":
            inner = []
            if self.base_reg:  inner.append(f"%{self.base_reg}")
            if self.index_reg: inner.append(f"%{self.index_reg}"); inner.append(str(self.scale))
            seg = f"%{self.seg_prefix}:" if self.seg_prefix else ""
            disp = hex(self.disp) if self.disp else ""
            return f"{seg}{disp}({','.join(inner)})"
        return "?"


# --------------------------------------------------------------
# Mnemonic normalization
# --------------------------------------------------------------
# MMX mnemonics where the trailing letter is part of the name, not a size suffix.
_MMX_MNEMONICS = frozenset({
    "packsswb", "packssdw",
    "paddw", "paddd",
    "pavgb", "pavgw",
    "movq", "movd",
})

# Capstone uses Intel "*sd" mnemonics for the 32-bit string ops; the assembler
# (and our handlers) prefer the AT&T '*sl' form.  Map them explicitly.
_INTEL_DWORD_STRING_OPS = {
    "movsd": ("movs", "l"),
    "cmpsd": ("cmps", "l"),
    "scasd": ("scas", "l"),
    "lodsd": ("lods", "l"),
    "stosd": ("stos", "l"),
}

# Last-two-char endings that look like a size suffix but aren't.
_NO_STRIP_ENDINGS = ("al", "bb", "ub", "ul", "hl")
# Force-strip mnemonics: push/pop end in 'hl' (push/pop) but the 'l' IS the size suffix.
_FORCE_STRIP_PREFIXES = ("push", "pop")


def _strip_size_suffix(mnemonic):
    """Return (clean_mnemonic, size_suffix_or_None) using the same rules as the
    old `parse_objdump`.  Mnemonic must already be lowercase."""
    if mnemonic in _INTEL_DWORD_STRING_OPS:
        return _INTEL_DWORD_STRING_OPS[mnemonic]
    if (mnemonic in ("hlt", "nop", "lcall", "ljmp", "lret", "lretf", "retf")
            or mnemonic in _MMX_MNEMONICS
            or mnemonic.startswith("j")
            or mnemonic.startswith("call")
            or mnemonic.startswith("ret")
            or mnemonic.startswith("cmov")):
        return mnemonic, None
    force_strip = any(mnemonic.startswith(p) for p in _FORCE_STRIP_PREFIXES)
    if (len(mnemonic) > 2
            and mnemonic[-1] in ("b", "w", "l")
            and (mnemonic[-2:] not in _NO_STRIP_ENDINGS or force_strip)):
        return mnemonic[:-1], mnemonic[-1]
    return mnemonic, None


def _has_rep_prefix(insn):
    """True if this instruction has a REP/REPE/REPNE prefix.
    Capstone exposes prefixes both via `insn.prefix[]` and by emitting "rep "
    in the mnemonic for some builds."""
    for p in (X86_PREFIX_REP, X86_PREFIX_REPE, X86_PREFIX_REPNE):
        if p in insn.prefix:
            return True
    return insn.mnemonic.lower().startswith(("rep ", "repe ", "repne ", "repz ", "repnz "))


# --------------------------------------------------------------
# Capstone -> our Operand
# --------------------------------------------------------------
def _empty_to_none(name):
    return name if name else None


def _capstone_op(insn, op):
    if op.type == X86_OP_IMM:
        return Operand("imm", imm_val=op.imm)
    if op.type == X86_OP_REG:
        return Operand("reg", reg_name=insn.reg_name(op.reg).lower())
    if op.type == X86_OP_MEM:
        base_reg  = _empty_to_none(insn.reg_name(op.mem.base).lower()  if op.mem.base  else None)
        index_reg = _empty_to_none(insn.reg_name(op.mem.index).lower() if op.mem.index else None)
        scale     = op.mem.scale or 1
        disp      = op.mem.disp
        seg_name  = _empty_to_none(insn.reg_name(op.mem.segment).lower() if op.mem.segment else None)
        return Operand("mem",
                       base_reg=base_reg, index_reg=index_reg,
                       scale=scale, disp=disp, seg_prefix=seg_name,
                       mem_size=op.size)
    raise ValueError(f"Unsupported Capstone operand type: {op.type}")


def _capstone_to_instruction(insn):
    raw_mnem = insn.mnemonic.lower().strip()

    # Rep/repe/repne prefix: handler names in execute.py use "rep_<base>".
    rep_kind = None
    base_mnem = raw_mnem
    if _has_rep_prefix(insn):
        # Capstone may either return "rep movsb" or just "movsb" with a prefix.
        parts = raw_mnem.split()
        if parts[0] in ("rep", "repe", "repz", "repne", "repnz"):
            rep_kind = parts[0]
            base_mnem = " ".join(parts[1:]) if len(parts) > 1 else ""
        else:
            rep_kind = "rep"
            base_mnem = raw_mnem
    else:
        base_mnem = raw_mnem

    clean, size_suffix = _strip_size_suffix(base_mnem)
    if rep_kind:
        # Distinguish rep / repe / repne so the CMPS family can pick its
        # termination condition.  REP and REPZ/REPE on CMPS are equivalent in
        # real silicon, but we keep the prefix the user wrote so the dispatch
        # key matches exactly what they expect.
        if rep_kind in ("repe", "repz"):
            clean = "repe_" + clean
        elif rep_kind in ("repne", "repnz"):
            clean = "repne_" + clean
        else:
            clean = "rep_" + clean

    # Far call / far jump have a single immediate operand of type IMM that
    # is actually the (segment:offset) pair.  Capstone exposes these via
    # X86_OP_IMM whose value is the offset, and there is a separate
    # X86_OP_IMM for the segment (depends on Capstone version).  In ATT
    # syntax the human string is e.g. "lcall $0x10, $0x1234".
    operands = []
    far_seg = far_off = None
    cs_ops = list(insn.operands)
    if clean in ("ljmp", "lcall") and len(cs_ops) == 2 \
            and cs_ops[0].type == X86_OP_IMM and cs_ops[1].type == X86_OP_IMM:
        far_seg = cs_ops[0].imm & 0xFFFF
        far_off = cs_ops[1].imm & 0xFFFFFFFF
        operands = [Operand("imm", imm_val=far_off, far_seg=far_seg, far_off=far_off)]
    else:
        for op in cs_ops:
            operands.append(_capstone_op(insn, op))
        # Capstone uses Intel order (dst, src, ...).  execute.py handlers expect
        # AT&T order (src, dst).  Reverse for multi-operand instructions.
        if len(operands) > 1:
            operands.reverse()

    # Intel-syntax Capstone never appends 'w'/'l' to push/pop mnemonics.
    # Detect the operand-size override prefix (0x66) and promote size_suffix.
    if clean in ('push', 'pop') and size_suffix is None:
        if _OPSIZE_PREFIX in insn.prefix:
            size_suffix = 'w'

    raw_str = f"{insn.mnemonic}\t{insn.op_str}".strip()
    return Instruction(addr=insn.address, size=insn.size,
                       mnemonic=clean, operands=operands,
                       raw=raw_str, size_suffix=size_suffix)


# --------------------------------------------------------------
# Public entry point
# --------------------------------------------------------------
def decode_one(raw_bytes, linear_addr):
    """Decode a single x86-32 instruction.  Returns an Instruction or None."""
    if not raw_bytes:
        return None
    for insn in _CS.disasm(raw_bytes, linear_addr, count=1):
        return _capstone_to_instruction(insn)
    return None
