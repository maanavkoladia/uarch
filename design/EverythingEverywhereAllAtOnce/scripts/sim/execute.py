"""Instruction execution engine for x86-32 functional sim.

Dispatch-table based design: each opcode group has a handler function.
To add a new instruction, add a handler and register it in DISPATCH.
"""

from flags import Flags
from registers import RegisterFile
from memory import Memory


class CPUException(Exception):
    """Raised for GP faults, page faults, etc."""
    def __init__(self, msg):
        super().__init__(msg)


class HaltException(Exception):
    """Raised on HLT instruction."""
    pass


class CPU:
    def __init__(self, regs, flags, mem):
        self.regs: RegisterFile = regs
        self.flags: Flags = flags
        self.mem: Memory = mem
        self.cycle = 0
        self.halted = False
        self.trace = []
        self._dispatch_built = False
        self.DISPATCH = {}

    # ---------------------------------------------------------------
    # Operand helpers
    # ---------------------------------------------------------------
    def _effective_addr(self, op):
        """Compute effective address for a memory operand."""
        addr = op.disp
        if op.base_reg:
            addr += self.regs.get(op.base_reg)
        if op.index_reg:
            addr += self.regs.get(op.index_reg) * op.scale
        return addr & 0xFFFFFFFF

    def _operand_size(self, operands, size_suffix=None):
        """Infer operand size in bytes from the register operand or size suffix."""
        for op in operands:
            if op.typ == 'reg':
                return self.regs.reg_size(op.reg_name) // 8
        if size_suffix:
            return {'b': 1, 'w': 2, 'l': 4, 'q': 8}.get(size_suffix, 4)
        # Default to 32-bit for memory-only
        return 4

    def _read_operand(self, op, size_bytes):
        """Read value from an operand."""
        if op.typ == 'imm':
            return op.imm_val & ((1 << (size_bytes * 8)) - 1)
        if op.typ == 'reg':
            return self.regs.get(op.reg_name)
        if op.typ == 'mem':
            if op.far_seg is not None:
                raise CPUException(f"Cannot read from far pointer operand")
            addr = self._effective_addr(op)
            val, err = self.mem.read(addr, size_bytes)
            if err:
                raise CPUException(err)
            return val
        raise CPUException(f"Unknown operand type: {op.typ}")

    def _write_operand(self, op, value, size_bytes):
        """Write value to an operand."""
        if op.typ == 'reg':
            self.regs.set(op.reg_name, value)
        elif op.typ == 'mem':
            addr = self._effective_addr(op)
            mask = (1 << (size_bytes * 8)) - 1
            err = self.mem.write(addr, size_bytes, value & mask)
            if err:
                raise CPUException(err)
        else:
            raise CPUException(f"Cannot write to operand type: {op.typ}")

    def _sign_extend(self, value, from_bits, to_bits):
        """Sign extend a value from from_bits to to_bits."""
        mask = (1 << from_bits) - 1
        value = value & mask
        if value & (1 << (from_bits - 1)):
            value |= ((1 << to_bits) - 1) ^ mask
        return value & ((1 << to_bits) - 1)

    # ---------------------------------------------------------------
    # Instruction handlers
    # ---------------------------------------------------------------
    def exec_add(self, inst):
        """ADD src, dst  (AT&T: src is first, dst is second)"""
        src_op = inst.operands[0]
        dst_op = inst.operands[1]
        size_bytes = self._operand_size(inst.operands)
        bits = size_bytes * 8
        mask = (1 << bits) - 1

        src_val = self._read_operand(src_op, size_bytes)

        # Sign extend imm8 to larger size if needed (opcode 83 behavior)
        if src_op.typ == 'imm' and size_bytes > 1:
            imm_raw = src_op.imm_val
            # If the immediate fits in 8 bits and dest is 16/32, sign extend
            if -128 <= imm_raw <= 0xFF:
                # Only sign extend if it looks like a small imm
                pass  # parser already provides correct value
            src_val = src_val & mask

        dst_val = self._read_operand(dst_op, size_bytes)

        result = src_val + dst_val
        self.flags.update_add(src_val & mask, dst_val & mask, result, bits)
        self._write_operand(dst_op, result & mask, size_bytes)

    def exec_mov(self, inst):
        """MOV src, dst  (handles all MOV variants: reg/mem/imm, segment regs, MMX via movq)"""
        src_op = inst.operands[0]
        dst_op = inst.operands[1]
        size_bytes = self._operand_size(inst.operands, getattr(inst, 'size_suffix', None))
        val = self._read_operand(src_op, size_bytes)
        self._write_operand(dst_op, val, size_bytes)

    def exec_movs(self, inst):
        """MOVS - move byte/word/dword from DS:ESI to ES:EDI."""
        suffix_map = {'b': 1, 'w': 2, 'l': 4}
        size_bytes = suffix_map.get(getattr(inst, 'size_suffix', None), 4)
        src_base = self.regs.seg_bases.get('ds', 0)
        dst_base = self.regs.seg_bases.get('es', 0)
        src_addr = self.regs.get('esi')
        dst_addr = self.regs.get('edi')
        val, err = self.mem.read(src_addr, size_bytes, src_base)
        if err:
            raise CPUException(f"MOVS read DS:ESI error: {err}")
        err = self.mem.write(dst_addr, size_bytes, val, dst_base)
        if err:
            raise CPUException(f"MOVS write ES:EDI error: {err}")
        delta = -size_bytes if self.flags.get_df() else size_bytes
        self.regs.set('esi', (self.regs.get('esi') + delta) & 0xFFFFFFFF)
        self.regs.set('edi', (self.regs.get('edi') + delta) & 0xFFFFFFFF)

    def exec_rep_movs(self, inst):
        """REP MOVS - repeat move string ECX times."""
        suffix_map = {'b': 1, 'w': 2, 'l': 4}
        size_bytes = suffix_map.get(getattr(inst, 'size_suffix', None), 4)
        count = self.regs.get('ecx')
        src_base = self.regs.seg_bases.get('ds', 0)
        dst_base = self.regs.seg_bases.get('es', 0)
        df = self.flags.get_df()
        delta = -size_bytes if df else size_bytes
        for _ in range(count):
            src_addr = self.regs.get('esi')
            dst_addr = self.regs.get('edi')
            val, err = self.mem.read(src_addr, size_bytes, src_base)
            if err:
                raise CPUException(f"REP MOVS read DS:ESI error: {err}")
            err = self.mem.write(dst_addr, size_bytes, val, dst_base)
            if err:
                raise CPUException(f"REP MOVS write ES:EDI error: {err}")
            self.regs.set('esi', (self.regs.get('esi') + delta) & 0xFFFFFFFF)
            self.regs.set('edi', (self.regs.get('edi') + delta) & 0xFFFFFFFF)
        self.regs.set('ecx', 0)

    def exec_hlt(self, inst):
        """HLT - halt processor."""
        raise HaltException()

    def exec_jmp(self, inst):
        """JMP - unconditional jump."""
        op = inst.operands[0]
        if op.typ == 'imm':
            # objdump gives absolute target address for relative jumps
            self.regs.eip = op.imm_val & 0xFFFFFFFF
            return True
        if op.typ == 'mem':
            if op.far_seg is not None:
                # Far jump - just set EIP to offset (flat model)
                self.regs.eip = op.far_off & 0xFFFFFFFF
                return True
            # Near absolute indirect
            size_bytes = self._operand_size(inst.operands)
            if size_bytes == 1:
                size_bytes = 4  # default
            addr = self._effective_addr(op)
            val, err = self.mem.read(addr, size_bytes)
            if err:
                raise CPUException(err)
            self.regs.eip = val & 0xFFFFFFFF
            return True
        if op.typ == 'reg':
            self.regs.eip = self.regs.get(op.reg_name) & 0xFFFFFFFF
            return True
        raise CPUException(f"Invalid JMP operand")

    def exec_jcc(self, inst, condition_fn):
        """Conditional jump: if condition_fn() is true, jump."""
        op = inst.operands[0]
        if condition_fn():
            # objdump gives absolute target address
            target = op.imm_val & 0xFFFFFFFF
            self.regs.eip = target
            return True
        return False

    # ---------------------------------------------------------------
    # Dispatch
    # ---------------------------------------------------------------

    def _build_dispatch(self):
        if self._dispatch_built:
            return
        self._dispatch_built = True
        self.DISPATCH = {
            "add": self.exec_add,
            "mov": self.exec_mov,
            "movq": self.exec_mov,
            "movs": self.exec_movs,
            "rep_movs": self.exec_rep_movs,
            "hlt": self.exec_hlt,
            "jmp": self.exec_jmp,
            "jnbe": lambda inst: self.exec_jcc(inst, lambda: self.flags.get_cf() == 0 and self.flags.get_zf() == 0),
            "ja":   lambda inst: self.exec_jcc(inst, lambda: self.flags.get_cf() == 0 and self.flags.get_zf() == 0),
            "jne": lambda inst: self.exec_jcc(inst, lambda: self.flags.get_zf() == 0),
            "jnz": lambda inst: self.exec_jcc(inst, lambda: self.flags.get_zf() == 0),
            "jbe": lambda inst: self.exec_jcc(inst, lambda: self.flags.get_cf() == 1 or self.flags.get_zf() == 1),
            "je":  lambda inst: self.exec_jcc(inst, lambda: self.flags.get_zf() == 1),
            "jz":  lambda inst: self.exec_jcc(inst, lambda: self.flags.get_zf() == 1),
        }

    def execute(self, inst):
        """Execute a single instruction. Returns True if EIP was modified by instruction."""
        self._build_dispatch()
        handler = self.DISPATCH.get(inst.mnemonic)
        if handler is None:
            raise CPUException(f"Unimplemented instruction: {inst.mnemonic} (line {inst.line_num})")
        result = handler(inst)
        return result is True  # True means EIP was explicitly set
