"""x86-32 register file with sub-register access."""

class RegisterFile:
    """Manages 8 GPRs (32-bit each) with sub-register views."""

    # Canonical 32-bit register indices
    REG32 = {"eax": 0, "ecx": 1, "edx": 2, "ebx": 3,
             "esp": 4, "ebp": 5, "esi": 6, "edi": 7}
    REG16 = {"ax": 0, "cx": 1, "dx": 2, "bx": 3,
             "sp": 4, "bp": 5, "si": 6, "di": 7}
    REG8L = {"al": 0, "cl": 1, "dl": 2, "bl": 3}
    REG8H = {"ah": 0, "ch": 1, "dh": 2, "bh": 3}

    def __init__(self):
        self.gpr = [0] * 8  # 32-bit values
        self.eip = 0
        # Segment base addresses (flat model, all 0)
        self.seg_bases = {"cs": 0, "ds": 0, "ss": 0, "es": 0, "fs": 0, "gs": 0}
        # Segment limits (20-bit granularity)
        self.seg_limits = {"cs": 0xFFFFF, "ds": 0xFFFFF, "ss": 0xFFFFF,
                           "es": 0x00000, "fs": 0x00000, "gs": 0x00000}

    def _mask(self, val, bits):
        return val & ((1 << bits) - 1)

    def get(self, name):
        """Read a register by AT&T name (without %)."""
        name = name.lower()
        if name in self.REG32:
            return self._mask(self.gpr[self.REG32[name]], 32)
        if name in self.REG16:
            return self._mask(self.gpr[self.REG16[name]], 16)
        if name in self.REG8L:
            return self._mask(self.gpr[self.REG8L[name]], 8)
        if name in self.REG8H:
            return (self.gpr[self.REG8H[name]] >> 8) & 0xFF
        raise ValueError(f"Unknown register: {name}")

    def set(self, name, value):
        """Write a register by AT&T name (without %)."""
        name = name.lower()
        if name in self.REG32:
            self.gpr[self.REG32[name]] = self._mask(value, 32)
        elif name in self.REG16:
            idx = self.REG16[name]
            self.gpr[idx] = (self.gpr[idx] & 0xFFFF0000) | self._mask(value, 16)
        elif name in self.REG8L:
            idx = self.REG8L[name]
            self.gpr[idx] = (self.gpr[idx] & 0xFFFFFF00) | self._mask(value, 8)
        elif name in self.REG8H:
            idx = self.REG8H[name]
            self.gpr[idx] = (self.gpr[idx] & 0xFFFF00FF) | (self._mask(value, 8) << 8)
        else:
            raise ValueError(f"Unknown register: {name}")

    def reg_size(self, name):
        """Return bit width of a register name."""
        name = name.lower()
        if name in self.REG32:
            return 32
        if name in self.REG16:
            return 16
        if name in self.REG8L or name in self.REG8H:
            return 8
        raise ValueError(f"Unknown register: {name}")

    def is_register(self, name):
        name = name.lower()
        return name in self.REG32 or name in self.REG16 or name in self.REG8L or name in self.REG8H

    def dump(self):
        """Return dict of all register values."""
        names = ["eax", "ecx", "edx", "ebx", "esp", "ebp", "esi", "edi"]
        result = {}
        for n in names:
            result[n] = self.gpr[self.REG32[n]]
        result["eip"] = self.eip
        return result

    def dump_str(self):
        d = self.dump()
        lines = []
        for k in ["eax", "ebx", "ecx", "edx", "esp", "ebp", "esi", "edi", "eip"]:
            lines.append(f"  {k} = 0x{d[k]:08X}")
        return "\n".join(lines)
