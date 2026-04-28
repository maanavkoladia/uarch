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

    def _resolve_seg_name(self, op, default='ds'):
        """Return the segment register name for a memory operand."""
        return op.seg_prefix if op.seg_prefix else default

    def _resolve_seg(self, op, default='ds'):
        """Return the 16-bit segment register value for a memory operand."""
        return self.regs.get(self._resolve_seg_name(op, default))

    def _read_operand(self, op, size_bytes):
        """Read value from an operand."""
        if op.typ == 'imm':
            return op.imm_val & ((1 << (size_bytes * 8)) - 1)
        if op.typ == 'reg':
            return self.regs.get(op.reg_name)
        if op.typ == 'mem':
            if op.far_seg is not None:
                raise CPUException("Cannot read from far pointer operand")
            addr     = self._effective_addr(op)
            seg_name = self._resolve_seg_name(op, default='ds')
            seg_val  = self.regs.get(seg_name)
            val, err = self.mem.read(addr, size_bytes, seg_val,
                                     seg_name, self.regs.seg_limits)
            if err:
                raise CPUException(err)
            return val
        raise CPUException(f"Unknown operand type: {op.typ}")

    def _write_operand(self, op, value, size_bytes):
        """Write value to an operand."""
        if op.typ == 'reg':
            self.regs.set(op.reg_name, value)
        elif op.typ == 'mem':
            addr     = self._effective_addr(op)
            seg_name = self._resolve_seg_name(op, default='ds')
            seg_val  = self.regs.get(seg_name)
            mask = (1 << (size_bytes * 8)) - 1
            err = self.mem.write(addr, size_bytes, value & mask, seg_val,
                                 seg_name, self.regs.seg_limits)
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

    def exec_and(self, inst):
        """AND src, dst  (AT&T: src is first, dst is second)"""
        src_op = inst.operands[0]
        dst_op = inst.operands[1]
        size_bytes = self._operand_size(inst.operands, getattr(inst, 'size_suffix', None))
        bits = size_bytes * 8
        mask = (1 << bits) - 1

        src_val = self._read_operand(src_op, size_bytes) & mask
        dst_val = self._read_operand(dst_op, size_bytes) & mask

        result = src_val & dst_val
        self.flags.update_logic(result, bits)
        self._write_operand(dst_op, result & mask, size_bytes)

    def exec_or(self, inst):
        """OR src, dst  (AT&T: src is first, dst is second)"""
        src_op = inst.operands[0]
        dst_op = inst.operands[1]
        size_bytes = self._operand_size(inst.operands, getattr(inst, 'size_suffix', None))
        bits = size_bytes * 8
        mask = (1 << bits) - 1

        src_val = self._read_operand(src_op, size_bytes) & mask
        dst_val = self._read_operand(dst_op, size_bytes) & mask

        result = src_val | dst_val
        self.flags.update_logic(result, bits)
        self._write_operand(dst_op, result & mask, size_bytes)

    def exec_not(self, inst):
        """NOT dst  (single operand — bitwise complement, no flags affected)"""
        dst_op = inst.operands[0]
        size_bytes = self._operand_size(inst.operands, getattr(inst, 'size_suffix', None))
        bits = size_bytes * 8
        mask = (1 << bits) - 1

        val = self._read_operand(dst_op, size_bytes)
        result = (~val) & mask
        self._write_operand(dst_op, result, size_bytes)

    def exec_movs(self, inst):
        """MOVS - move byte/word/dword from DS:ESI to ES:EDI."""
        suffix_map = {'b': 1, 'w': 2, 'l': 4}
        size_bytes = suffix_map.get(getattr(inst, 'size_suffix', None), 4)
        src_val = self.regs.get('ds')
        dst_val = self.regs.get('es')
        src_addr = self.regs.get('esi')
        dst_addr = self.regs.get('edi')
        val, err = self.mem.read(src_addr, size_bytes, src_val,
                                 'ds', self.regs.seg_limits)
        if err:
            raise CPUException(f"MOVS read DS:ESI error: {err}")
        err = self.mem.write(dst_addr, size_bytes, val, dst_val,
                             'es', self.regs.seg_limits)
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
        src_val = self.regs.get('ds')
        dst_val = self.regs.get('es')
        df = self.flags.get_df()
        delta = -size_bytes if df else size_bytes
        for _ in range(count):
            src_addr = self.regs.get('esi')
            dst_addr = self.regs.get('edi')
            val, err = self.mem.read(src_addr, size_bytes, src_val,
                                     'ds', self.regs.seg_limits)
            if err:
                raise CPUException(f"REP MOVS read DS:ESI error: {err}")
            err = self.mem.write(dst_addr, size_bytes, val, dst_val,
                                 'es', self.regs.seg_limits)
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
            self.regs.eip = self._linear_to_eip(op.imm_val & 0xFFFFFFFF)
            return True
        if op.typ == 'mem':
            if op.far_seg is not None:
                self.regs.set('cs', op.far_seg & 0xFFFF)
                self.regs.eip = op.far_off & 0xFFFFFFFF
                return True
            # Near absolute indirect
            size_bytes = self._operand_size(inst.operands)
            if size_bytes == 1:
                size_bytes = 4  # default
            val = self._read_operand(op, size_bytes)
            self.regs.eip = val & 0xFFFFFFFF
            return True
        if op.typ == 'reg':
            self.regs.eip = self.regs.get(op.reg_name) & 0xFFFFFFFF
            return True
        raise CPUException("Invalid JMP operand")

    def exec_ljmp(self, inst):
        """LJMP — far jump: load CS:EIP from operand."""
        op = inst.operands[0]
        if op.far_seg is None:
            raise CPUException("LJMP requires a far seg:off operand")
        self.regs.set('cs', op.far_seg & 0xFFFF)
        self.regs.eip = op.far_off & 0xFFFFFFFF
        return True

    def _linear_to_eip(self, linear):
        """Convert an absolute linear branch target to an EIP offset within CS."""
        cs_base = (self.regs.get('cs') & 0xFFFF) << 16
        return (linear - cs_base) & 0xFFFFFFFF

    def exec_jcc(self, inst, condition_fn):
        """Conditional jump: if condition_fn() is true, jump."""
        op = inst.operands[0]
        if condition_fn():
            self.regs.eip = self._linear_to_eip(op.imm_val & 0xFFFFFFFF)
            return True
        return False

    def exec_aaa(self, inst):
        """AAA - ASCII adjust AL after addition."""
        al = self.regs.get('al')
        af = self.flags.get_af()
        if (al & 0x0F) > 9 or af == 1:
            ax = self.regs.get('ax')
            ax = (ax + 0x106) & 0xFFFF
            self.regs.set('ax', ax)
            self.flags._set_bit(4, 1)  # AF
            self.flags._set_bit(0, 1)  # CF
        else:
            self.flags._set_bit(4, 0)  # AF
            self.flags._set_bit(0, 0)  # CF
        # AL = AL & 0x0F
        al = self.regs.get('al') & 0x0F
        self.regs.set('al', al)

    def exec_adc(self, inst):
        """ADC src, dst  (AT&T: src is first, dst is second) — add with carry."""
        src_op = inst.operands[0]
        dst_op = inst.operands[1]
        size_bytes = self._operand_size(inst.operands, getattr(inst, 'size_suffix', None))
        bits = size_bytes * 8
        mask = (1 << bits) - 1

        src_val = self._read_operand(src_op, size_bytes) & mask
        dst_val = self._read_operand(dst_op, size_bytes) & mask
        carry = self.flags.get_cf()

        result = src_val + dst_val + carry
        self.flags.update_add(src_val, dst_val, result, bits)
        self._write_operand(dst_op, result & mask, size_bytes)

    def exec_sbb(self, inst):
        """SBB src, dst  (AT&T: src is first, dst is second) — subtract with borrow."""
        src_op = inst.operands[0]
        dst_op = inst.operands[1]
        size_bytes = self._operand_size(inst.operands, getattr(inst, 'size_suffix', None))
        bits = size_bytes * 8
        mask = (1 << bits) - 1

        src_val = self._read_operand(src_op, size_bytes) & mask
        dst_val = self._read_operand(dst_op, size_bytes) & mask
        borrow = self.flags.get_cf()

        result = dst_val - src_val - borrow
        self.flags.update_sub(dst_val, src_val, result, bits, borrow)
        self._write_operand(dst_op, result & mask, size_bytes)

    def exec_bsf(self, inst):
        """BSF src, dst  (AT&T: src is first, dst is second) — bit scan forward."""
        src_op = inst.operands[0]
        dst_op = inst.operands[1]
        size_bytes = self._operand_size(inst.operands, getattr(inst, 'size_suffix', None))
        bits = size_bytes * 8
        mask = (1 << bits) - 1

        src_val = self._read_operand(src_op, size_bytes) & mask

        if src_val == 0:
            self.flags._set_bit(6, 1)  # ZF = 1
            # dst is undefined; leave it unchanged
        else:
            self.flags._set_bit(6, 0)  # ZF = 0
            bit_idx = 0
            while (src_val >> bit_idx) & 1 == 0:
                bit_idx += 1
            self._write_operand(dst_op, bit_idx, size_bytes)

    def exec_sal(self, inst):
        """SAL/SHL dst, count  (AT&T: count is first, dst is second; or implicit 1)"""
        if len(inst.operands) == 1:
            dst_op = inst.operands[0]
            count = 1
        else:
            count_op = inst.operands[0]
            dst_op = inst.operands[1]
            count = self._read_operand(count_op, 1) & 0x1F  # x86 masks to 5 bits

        size_bytes = self._operand_size([dst_op], getattr(inst, 'size_suffix', None))
        bits = size_bytes * 8
        mask = (1 << bits) - 1

        original = self._read_operand(dst_op, size_bytes) & mask

        if count == 0:
            return  # no operation, no flags changed

        result = (original << count) & mask
        self.flags.update_sal(original, result, count, bits)
        self._write_operand(dst_op, result, size_bytes)

    def exec_sar(self, inst):
        """SAR dst, count  (AT&T: count is first, dst is second; or implicit 1)"""
        if len(inst.operands) == 1:
            dst_op = inst.operands[0]
            count = 1
        else:
            count_op = inst.operands[0]
            dst_op = inst.operands[1]
            count = self._read_operand(count_op, 1) & 0x1F  # x86 masks to 5 bits

        size_bytes = self._operand_size([dst_op], getattr(inst, 'size_suffix', None))
        bits = size_bytes * 8
        mask = (1 << bits) - 1

        original = self._read_operand(dst_op, size_bytes) & mask

        if count == 0:
            return  # no operation, no flags changed

        # Arithmetic right shift: sign-extend to Python int, shift, mask back
        signed_val = original
        if original & (1 << (bits - 1)):
            signed_val = original - (1 << bits)
        result = (signed_val >> count) & mask

        self.flags.update_sar(original, result, count, bits)
        self._write_operand(dst_op, result, size_bytes)

    def exec_xchg(self, inst):
        """XCHG op1, op2  (AT&T order) — exchange values."""
        op1 = inst.operands[0]
        op2 = inst.operands[1]
        size_bytes = self._operand_size(inst.operands, getattr(inst, 'size_suffix', None))

        val1 = self._read_operand(op1, size_bytes)
        val2 = self._read_operand(op2, size_bytes)
        self._write_operand(op1, val2, size_bytes)
        self._write_operand(op2, val1, size_bytes)

    def exec_nop(self, inst):
        """NOP - no operation."""
        pass

    def exec_cld(self, inst):
        """CLD - clear direction flag (DF=0)."""
        self.flags._set_bit(10, 0)

    def exec_std(self, inst):
        """STD - set direction flag (DF=1)."""
        self.flags._set_bit(10, 1)

    def exec_cmovc(self, inst):
        """CMOVC src, dst  (AT&T: src first, dst second) — move if CF=1."""
        src_op = inst.operands[0]
        dst_op = inst.operands[1]
        size_bytes = self._operand_size(inst.operands, getattr(inst, 'size_suffix', None))

        if self.flags.get_cf() == 1:
            val = self._read_operand(src_op, size_bytes)
            self._write_operand(dst_op, val, size_bytes)

    def exec_cmpxchg(self, inst):
        """CMPXCHG r/m, r  (AT&T: r is first, r/m is second).
        Compare accumulator with dst. If equal, dst = src and ZF=1.
        Else, ZF=0 and accumulator = dst."""
        src_op = inst.operands[0]  # register operand (r8/r16/r32)
        dst_op = inst.operands[1]  # r/m operand
        size_bytes = self._operand_size(inst.operands, getattr(inst, 'size_suffix', None))
        bits = size_bytes * 8
        mask = (1 << bits) - 1

        # Determine accumulator based on size
        acc_name = {1: 'al', 2: 'ax', 4: 'eax'}[size_bytes]
        acc_val = self.regs.get(acc_name) & mask
        dst_val = self._read_operand(dst_op, size_bytes) & mask
        src_val = self._read_operand(src_op, size_bytes) & mask

        # Compare accumulator with dst (sets flags like SUB)
        cmp_result = acc_val - dst_val
        self.flags.update_sub(acc_val, dst_val, cmp_result, bits)

        if acc_val == dst_val:
            # Equal: dst = src, ZF already set to 1 by update_sub
            self._write_operand(dst_op, src_val, size_bytes)
        else:
            # Not equal: accumulator = dst, ZF already set to 0 by update_sub
            self.regs.set(acc_name, dst_val)

    # ---------------------------------------------------------------
    # MMX instruction helpers
    # ---------------------------------------------------------------
    @staticmethod
    def _sat_word_to_byte(w):
        """Saturate an unsigned 16-bit value as a signed 16-bit int into [-128, 127],
        returning the result as an unsigned byte."""
        s = w if w < 0x8000 else w - 0x10000
        return max(-128, min(127, s)) & 0xFF

    @staticmethod
    def _sat_dword_to_word(d):
        """Saturate an unsigned 32-bit value as a signed 32-bit int into [-32768, 32767],
        returning the result as an unsigned 16-bit value."""
        s = d if d < 0x80000000 else d - 0x100000000
        return max(-32768, min(32767, s)) & 0xFFFF

    def exec_packsswb(self, inst):
        """PACKSSWB src, dst  (AT&T: src first, dst second)
        Pack 4 signed words from dst and 4 signed words from src into 8 signed bytes
        in dst using signed saturation."""
        src_op = inst.operands[0]
        dst_op = inst.operands[1]
        src_val = self._read_operand(src_op, 8)
        dst_val = self._read_operand(dst_op, 8)
        result = 0
        for i in range(4):
            w = (dst_val >> (i * 16)) & 0xFFFF
            result |= self._sat_word_to_byte(w) << (i * 8)
        for i in range(4):
            w = (src_val >> (i * 16)) & 0xFFFF
            result |= self._sat_word_to_byte(w) << ((i + 4) * 8)
        self._write_operand(dst_op, result, 8)

    def exec_packssdw(self, inst):
        """PACKSSDW src, dst  (AT&T: src first, dst second)
        Pack 2 signed dwords from dst and 2 signed dwords from src into 4 signed words
        in dst using signed saturation."""
        src_op = inst.operands[0]
        dst_op = inst.operands[1]
        src_val = self._read_operand(src_op, 8)
        dst_val = self._read_operand(dst_op, 8)
        result = 0
        for i in range(2):
            d = (dst_val >> (i * 32)) & 0xFFFFFFFF
            result |= self._sat_dword_to_word(d) << (i * 16)
        for i in range(2):
            d = (src_val >> (i * 32)) & 0xFFFFFFFF
            result |= self._sat_dword_to_word(d) << ((i + 2) * 16)
        self._write_operand(dst_op, result, 8)

    def exec_paddw(self, inst):
        """PADDW src, dst  (AT&T: src first, dst second)
        Add 4 packed unsigned word integers (modular, no saturation)."""
        src_op = inst.operands[0]
        dst_op = inst.operands[1]
        src_val = self._read_operand(src_op, 8)
        dst_val = self._read_operand(dst_op, 8)
        result = 0
        for i in range(4):
            s = (src_val >> (i * 16)) & 0xFFFF
            d = (dst_val >> (i * 16)) & 0xFFFF
            result |= ((s + d) & 0xFFFF) << (i * 16)
        self._write_operand(dst_op, result, 8)

    def exec_paddd(self, inst):
        """PADDD src, dst  (AT&T: src first, dst second)
        Add 2 packed unsigned dword integers (modular, no saturation)."""
        src_op = inst.operands[0]
        dst_op = inst.operands[1]
        src_val = self._read_operand(src_op, 8)
        dst_val = self._read_operand(dst_op, 8)
        result = 0
        for i in range(2):
            s = (src_val >> (i * 32)) & 0xFFFFFFFF
            d = (dst_val >> (i * 32)) & 0xFFFFFFFF
            result |= ((s + d) & 0xFFFFFFFF) << (i * 32)
        self._write_operand(dst_op, result, 8)

    def exec_pavgb(self, inst):
        """PAVGB src, dst  (AT&T: src first, dst second)
        Average 8 packed unsigned byte integers with rounding: (a + b + 1) >> 1."""
        src_op = inst.operands[0]
        dst_op = inst.operands[1]
        src_val = self._read_operand(src_op, 8)
        dst_val = self._read_operand(dst_op, 8)
        result = 0
        for i in range(8):
            s = (src_val >> (i * 8)) & 0xFF
            d = (dst_val >> (i * 8)) & 0xFF
            result |= ((s + d + 1) >> 1) << (i * 8)
        self._write_operand(dst_op, result, 8)

    def exec_pavgw(self, inst):
        """PAVGW src, dst  (AT&T: src first, dst second)
        Average 4 packed unsigned word integers with rounding: (a + b + 1) >> 1."""
        src_op = inst.operands[0]
        dst_op = inst.operands[1]
        src_val = self._read_operand(src_op, 8)
        dst_val = self._read_operand(dst_op, 8)
        result = 0
        for i in range(4):
            s = (src_val >> (i * 16)) & 0xFFFF
            d = (dst_val >> (i * 16)) & 0xFFFF
            result |= ((s + d + 1) >> 1) << (i * 16)
        self._write_operand(dst_op, result, 8)

    def _stack_read(self, esp, size_bytes):
        """Read `size_bytes` from SS:ESP, bypassing the SS limit check."""
        ss_val = self.regs.get('ss')
        return self.mem.read(esp, size_bytes, ss_val,
                             'ss', self.regs.seg_limits, skip_limit=True)

    def _stack_write(self, esp, size_bytes, value):
        """Write `size_bytes` to SS:ESP, bypassing the SS limit check."""
        ss_val = self.regs.get('ss')
        return self.mem.write(esp, size_bytes, value, ss_val,
                              'ss', self.regs.seg_limits, skip_limit=True)

    def exec_push(self, inst):
        """PUSH — decrement ESP by size, write value to SS:ESP."""
        op = inst.operands[0]
        suffix = getattr(inst, 'size_suffix', None)
        size_bytes = 2 if suffix == 'w' else 4
        val = self._read_operand(op, size_bytes)
        esp = (self.regs.get('esp') - size_bytes) & 0xFFFFFFFF
        self.regs.set('esp', esp)
        err = self._stack_write(esp, size_bytes, val & ((1 << (size_bytes * 8)) - 1))
        if err:
            raise CPUException(f"PUSH: stack write error: {err}")

    def exec_pop(self, inst):
        """POP — read from SS:ESP, increment ESP by size, write to operand."""
        op = inst.operands[0]
        suffix = getattr(inst, 'size_suffix', None)
        size_bytes = 2 if suffix == 'w' else 4
        esp = self.regs.get('esp')
        val, err = self._stack_read(esp, size_bytes)
        if err:
            raise CPUException(f"POP: stack read error: {err}")
        self.regs.set('esp', (esp + size_bytes) & 0xFFFFFFFF)
        self._write_operand(op, val, size_bytes)

    def exec_call(self, inst):
        """CALL — push return address (next EIP), jump to target."""
        op = inst.operands[0]
        # sim.py pre-increments EIP before execute(), so eip == return address
        ret_addr = self.regs.eip
        esp = (self.regs.get('esp') - 4) & 0xFFFFFFFF
        self.regs.set('esp', esp)
        err = self._stack_write(esp, 4, ret_addr)
        if err:
            raise CPUException(f"CALL: stack write error: {err}")
        if op.typ == 'imm':
            self.regs.eip = self._linear_to_eip(op.imm_val & 0xFFFFFFFF)
        elif op.typ == 'reg':
            self.regs.eip = self.regs.get(op.reg_name) & 0xFFFFFFFF
        elif op.typ == 'mem':
            target = self._read_operand(op, 4)
            self.regs.eip = target & 0xFFFFFFFF
        else:
            raise CPUException(f"CALL: unsupported operand type: {op.typ}")
        return True

    def exec_lcall(self, inst):
        """LCALL — far call: push CS then EIP, load new CS:EIP."""
        op = inst.operands[0]
        ret_addr = self.regs.eip
        # Push CS (zero-extended to 32 bits)
        cs_val = self.regs.get('cs')
        esp = (self.regs.get('esp') - 4) & 0xFFFFFFFF
        self.regs.set('esp', esp)
        err = self._stack_write(esp, 4, cs_val)
        if err:
            raise CPUException(f"LCALL: CS push error: {err}")
        # Push EIP
        esp = (esp - 4) & 0xFFFFFFFF
        self.regs.set('esp', esp)
        err = self._stack_write(esp, 4, ret_addr)
        if err:
            raise CPUException(f"LCALL: EIP push error: {err}")
        # Load new CS:EIP
        self.regs.set('cs', op.far_seg & 0xFFFF)
        self.regs.eip = op.far_off & 0xFFFFFFFF
        return True

    def exec_ret(self, inst):
        """RET — pop return address from stack; optionally add imm16 to ESP."""
        esp = self.regs.get('esp')
        ret_addr, err = self._stack_read(esp, 4)
        if err:
            raise CPUException(f"RET: stack read error: {err}")
        esp = (esp + 4) & 0xFFFFFFFF
        if inst.operands:
            extra = inst.operands[0].imm_val & 0xFFFF
            esp = (esp + extra) & 0xFFFFFFFF
        self.regs.set('esp', esp)
        self.regs.eip = ret_addr & 0xFFFFFFFF
        return True

    def exec_lret(self, inst):
        """LRET — far return: pop EIP then CS from stack."""
        esp = self.regs.get('esp')
        ret_addr, err = self._stack_read(esp, 4)
        if err:
            raise CPUException(f"LRET: EIP read error: {err}")
        esp = (esp + 4) & 0xFFFFFFFF
        cs_val, err = self._stack_read(esp, 4)
        if err:
            raise CPUException(f"LRET: CS read error: {err}")
        esp = (esp + 4) & 0xFFFFFFFF
        if inst.operands:
            extra = inst.operands[0].imm_val & 0xFFFF
            esp = (esp + extra) & 0xFFFFFFFF
        self.regs.set('esp', esp)
        self.regs.set('cs', cs_val & 0xFFFF)
        self.regs.eip = ret_addr & 0xFFFFFFFF
        return True

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
            "and": self.exec_and,
            "or": self.exec_or,
            "not": self.exec_not,
            "hlt": self.exec_hlt,
            "jmp":  self.exec_jmp,
            "ljmp": self.exec_ljmp,
            "jnbe": lambda inst: self.exec_jcc(inst, lambda: self.flags.get_cf() == 0 and self.flags.get_zf() == 0),
            "ja":   lambda inst: self.exec_jcc(inst, lambda: self.flags.get_cf() == 0 and self.flags.get_zf() == 0),
            "jne": lambda inst: self.exec_jcc(inst, lambda: self.flags.get_zf() == 0),
            "jnz": lambda inst: self.exec_jcc(inst, lambda: self.flags.get_zf() == 0),
            "jbe": lambda inst: self.exec_jcc(inst, lambda: self.flags.get_cf() == 1 or self.flags.get_zf() == 1),
            "je":  lambda inst: self.exec_jcc(inst, lambda: self.flags.get_zf() == 1),
            "jz":  lambda inst: self.exec_jcc(inst, lambda: self.flags.get_zf() == 1),
            "sal": self.exec_sal,
            "shl": self.exec_sal,
            "sar": self.exec_sar,
            "aaa": self.exec_aaa,
            "adc": self.exec_adc,
            "sbb": self.exec_sbb,
            "bsf": self.exec_bsf,
            "xchg": self.exec_xchg,
            "cld":   self.exec_cld,
            "std":   self.exec_std,
            "cmovc": self.exec_cmovc,
            "cmovb": self.exec_cmovc,
            "cmpxchg": self.exec_cmpxchg,
            "packsswb": self.exec_packsswb,
            "packssdw": self.exec_packssdw,
            "paddw": self.exec_paddw,
            "paddd": self.exec_paddd,
            "pavgb": self.exec_pavgb,
            "pavgw": self.exec_pavgw,
            "push":  self.exec_push,
            "pop":   self.exec_pop,
            "call":  self.exec_call,
            "lcall": self.exec_lcall,
            "ret":   self.exec_ret,
            "lret":  self.exec_lret,
            "lretf": self.exec_lret,
            "retf":  self.exec_lret,
            "nop":   self.exec_nop,
        }

    def execute(self, inst):
        """Execute a single instruction. Returns True if EIP was modified by instruction."""
        self._build_dispatch()
        handler = self.DISPATCH.get(inst.mnemonic)
        if handler is None:
            raise CPUException(f"Unimplemented instruction: '{inst.mnemonic}' at 0x{inst.addr:08X} (raw: {inst.raw!r})")
        result = handler(inst)
        return result is True  # True means EIP was explicitly set
