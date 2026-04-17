"""EFLAGS management for x86-32 functional sim."""

CF = 0   # Carry
PF = 2   # Parity
AF = 4   # Auxiliary carry
ZF = 6   # Zero
SF = 7   # Sign
OF = 11  # Overflow

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
