"""EFLAGS management for x86-32 functional sim."""

CF = 0   # Carry
PF = 2   # Parity
AF = 4   # Auxiliary carry
ZF = 6   # Zero
SF = 7   # Sign
OF = 11  # Overflow
DF = 10  # Direction

class Flags:
    def __init__(self):
        self.eflags = 0x00000002  # bit 1 always set

    def _set_bit(self, bit, val):
        if val:
            self.eflags |= (1 << bit)
        else:
            self.eflags &= ~(1 << bit)

    def get_cf(self): return (self.eflags >> CF) & 1
    def get_pf(self): return (self.eflags >> PF) & 1
    def get_af(self): return (self.eflags >> AF) & 1
    def get_zf(self): return (self.eflags >> ZF) & 1
    def get_sf(self): return (self.eflags >> SF) & 1
    def get_of(self): return (self.eflags >> OF) & 1
    def get_df(self): return (self.eflags >> DF) & 1

    def update_add(self, a, b, result, bits):
        """Update flags after an ADD operation."""
        mask = (1 << bits) - 1
        res_masked = result & mask
        sign_bit = bits - 1

        # CF: carry out
        self._set_bit(CF, result > mask)

        # ZF
        self._set_bit(ZF, res_masked == 0)

        # SF
        self._set_bit(SF, (res_masked >> sign_bit) & 1)

        # OF: signed overflow
        a_sign = (a >> sign_bit) & 1
        b_sign = (b >> sign_bit) & 1
        r_sign = (res_masked >> sign_bit) & 1
        self._set_bit(OF, (a_sign == b_sign) and (r_sign != a_sign))

        # PF: parity of low byte
        low_byte = res_masked & 0xFF
        self._set_bit(PF, (bin(low_byte).count('1') % 2) == 0)

        # AF: carry from bit 3 to 4
        self._set_bit(AF, ((a & 0xF) + (b & 0xF)) > 0xF)

    def update_logic(self, result, bits):
        """Update flags after a logical operation (AND, OR, XOR, TEST).
        CF and OF are cleared. SF, ZF, PF are set. AF is undefined (cleared here)."""
        mask = (1 << bits) - 1
        res_masked = result & mask
        sign_bit = bits - 1

        self._set_bit(CF, 0)
        self._set_bit(OF, 0)
        self._set_bit(ZF, res_masked == 0)
        self._set_bit(SF, (res_masked >> sign_bit) & 1)
        low_byte = res_masked & 0xFF
        self._set_bit(PF, (bin(low_byte).count('1') % 2) == 0)
        self._set_bit(AF, 0)

    def update_sub(self, a, b, result, bits, borrow=0):
        """Update flags after a SUB/SBB operation.
        a = dst, b = src (what was subtracted), result = a - b (- borrow)."""
        mask = (1 << bits) - 1
        res_masked = result & mask
        sign_bit = bits - 1

        # CF: borrow out (unsigned underflow)
        self._set_bit(CF, result < 0 or result > mask)

        # ZF
        self._set_bit(ZF, res_masked == 0)

        # SF
        self._set_bit(SF, (res_masked >> sign_bit) & 1)

        # OF: signed overflow — different signs on operands and result sign != dst sign
        a_sign = (a >> sign_bit) & 1
        b_sign = (b >> sign_bit) & 1
        r_sign = (res_masked >> sign_bit) & 1
        self._set_bit(OF, (a_sign != b_sign) and (r_sign != a_sign))

        # PF: parity of low byte
        low_byte = res_masked & 0xFF
        self._set_bit(PF, (bin(low_byte).count('1') % 2) == 0)

        # AF: borrow from bit 4 (must include incoming borrow for SBB)
        self._set_bit(AF, (a & 0xF) < (b & 0xF) + borrow)

    def update_sal(self, original, result, count, bits):
        """Update flags after SAL/SHL operation.
        count has already been masked to 5 bits by the caller."""
        if count == 0:
            return  # no flags modified
        mask = (1 << bits) - 1
        res_masked = result & mask
        sign_bit = bits - 1

        # CF = last bit shifted out of the MSB
        if count <= bits:
            self._set_bit(CF, (original >> (bits - count)) & 1)
        else:
            self._set_bit(CF, 0)

        # SF, ZF, PF
        self._set_bit(ZF, res_masked == 0)
        self._set_bit(SF, (res_masked >> sign_bit) & 1)
        low_byte = res_masked & 0xFF
        self._set_bit(PF, (bin(low_byte).count('1') % 2) == 0)

        # OF: defined only for 1-bit shifts; MSB(result) XOR CF
        if count == 1:
            self._set_bit(OF, ((res_masked >> sign_bit) & 1) ^ self.get_cf())
        else :
            self._set_bit(OF, 0)


        # AF is undefined; clear it
        self._set_bit(AF, 0)

    def update_sar(self, original, result, count, bits):
        """Update flags after SAR operation.
        count has already been masked to 5 bits by the caller."""
        if count == 0:
            return  # no flags modified
        mask = (1 << bits) - 1
        res_masked = result & mask
        sign_bit = bits - 1

        # CF = last bit shifted out of the LSB
        if count <= bits:
            self._set_bit(CF, (original >> (count - 1)) & 1)
        else:
            self._set_bit(CF, (original >> sign_bit) & 1)

        # SF, ZF, PF
        self._set_bit(ZF, res_masked == 0)
        self._set_bit(SF, (res_masked >> sign_bit) & 1)
        low_byte = res_masked & 0xFF
        self._set_bit(PF, (bin(low_byte).count('1') % 2) == 0)

        # OF: defined only for 1-bit shifts; SAR always clears OF
        if count != 0:
            self._set_bit(OF, 0)

        # AF is undefined; clear it
        self._set_bit(AF, 0)

    def dump(self):
        return {
            "CF": self.get_cf(), "PF": self.get_pf(), "AF": self.get_af(),
            "ZF": self.get_zf(), "SF": self.get_sf(), "OF": self.get_of(),
            "eflags": self.eflags
        }

    def dump_str(self):
        d = self.dump()
        return (f"  EFLAGS = 0x{d['eflags']:08X}  "
                f"CF=0x{d['CF']:X} PF=0x{d['PF']:X} AF=0x{d['AF']:X} "
                f"ZF=0x{d['ZF']:X} SF=0x{d['SF']:X} OF=0x{d['OF']:X}")
