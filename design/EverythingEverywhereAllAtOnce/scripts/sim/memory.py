"""Segmented memory model with TLB-based linear-to-physical translation.

Address translation pipeline (per OVERHAUL_SPEC.md):

    effective_offset
        |  Step 1 — Segment limit check (skipped for SS)
        |  Step 2 — Segment translation:  linear = (seg_reg << 16) + offset
        v
    linear address (32-bit)
        |  Step 3 — TLB lookup: vpn = linear >> 12, offset = linear & 0xFFF
        |              pfn = TLB(vpn);  paddr = (pfn << 12) | offset
        v
    physical address (15-bit, 0x0000-0x7FFF)
        |  Step 4 — read/write physical memory[paddr : paddr+size]
        v
    value
"""

import json


class Memory:
    """32KB byte-addressable physical memory + TLB + segmented translation."""

    SIZE_BYTES = 32 * 1024

    def __init__(self):
        self.data = bytearray(self.SIZE_BYTES)
        self.entries = []  # TLB entries

    # --------------------------------------------------------------
    # Loaders
    # --------------------------------------------------------------
    def load_from_bin(self, path):
        """Load a flat physical image into self.data (must be exactly 32 KiB)."""
        with open(path, "rb") as f:
            buf = f.read()
        if len(buf) > self.SIZE_BYTES:
            buf = buf[:self.SIZE_BYTES]
        self.data = bytearray(self.SIZE_BYTES)
        self.data[:len(buf)] = buf

    def load_tlb(self, path):
        """Parse TLB.conf.json and populate self.entries."""
        with open(path) as f:
            cfg = json.load(f)
        n = int(cfg["num entries"])
        self.entries = []
        for i in range(n):
            e = cfg["entries"][str(i)]
            self.entries.append({
                "valid":   int(e["valid"]),
                "present": int(e["present"]),
                "r_w":     int(e["r_w"]),
                "mmio":    int(e["MMIO"]),
                "vpn":     int(e["VPN"].split("'h")[1], 16),
                "pfn":     int(e["PFN"].split("'h")[1], 16),
            })

    # --------------------------------------------------------------
    # Translation
    # --------------------------------------------------------------
    def translate(self, linear):
        """Linear address -> (paddr, error_str|None) via TLB lookup."""
        vpn    = (linear >> 12) & 0xFFFFF
        offset = linear & 0xFFF
        for e in self.entries:
            if e["valid"] and e["vpn"] == vpn:
                if not e["present"]:
                    return None, f"#PF: VPN 0x{vpn:05X} not present"
                paddr = (e["pfn"] << 12) | offset
                if paddr < 0 or paddr >= len(self.data):
                    return None, f"#GP: paddr 0x{paddr:X} out of physical range"
                if e["mmio"]:
                    import sys
                    print(f"[memory] WARN: MMIO TLB hit at VPN 0x{vpn:05X}", file=sys.stderr)
                return paddr, None
        return None, f"#PF: VPN 0x{vpn:05X} not in TLB"

    # --------------------------------------------------------------
    # Read / write
    # --------------------------------------------------------------
    def read(self, effective_offset, size, seg_reg_val, seg_name, seg_limits, skip_limit=False):
        """Read `size` bytes through the segmented + TLB pipeline.
        Returns (value, error_str|None)."""
        if not skip_limit:
            limit = seg_limits.get(seg_name, 0xFFFFF)
            if (effective_offset & 0xFFFFFFFF) > limit:
                return None, (f"#GP: {seg_name.upper()} offset "
                              f"0x{effective_offset:08X} exceeds limit 0x{limit:05X}")
        linear = ((seg_reg_val & 0xFFFF) << 16) + (effective_offset & 0xFFFFFFFF)
        linear &= 0xFFFFFFFF
        paddr, err = self.translate(linear)
        if err:
            return None, err
        if paddr + size > len(self.data):
            return None, f"#GP: paddr 0x{paddr:04X} + {size} overflows physical memory"
        val = int.from_bytes(self.data[paddr:paddr + size], "little")
        return val, None

    def write(self, effective_offset, size, value, seg_reg_val, seg_name, seg_limits, skip_limit=False):
        """Write `size` bytes through the segmented + TLB pipeline.
        Returns error_str|None."""
        if not skip_limit:
            limit = seg_limits.get(seg_name, 0xFFFFF)
            if (effective_offset & 0xFFFFFFFF) > limit:
                return (f"#GP: {seg_name.upper()} offset "
                        f"0x{effective_offset:08X} exceeds limit 0x{limit:05X}")
        linear = ((seg_reg_val & 0xFFFF) << 16) + (effective_offset & 0xFFFFFFFF)
        linear &= 0xFFFFFFFF
        paddr, err = self.translate(linear)
        if err:
            return err
        if paddr + size > len(self.data):
            return f"#GP: paddr 0x{paddr:04X} + {size} overflows physical memory"
        mask = (1 << (size * 8)) - 1
        self.data[paddr:paddr + size] = (value & mask).to_bytes(size, "little")
        return None

    # --------------------------------------------------------------
    # Instruction fetch (CS-based)
    # --------------------------------------------------------------
    def fetch_bytes(self, eip, cs_val, seg_limits, count=15):
        """Fetch up to `count` raw bytes from CS:EIP through the TLB.
        Returns (bytes_fetched, first_error|None).  CS limit checked first.
        SS limit check is NOT involved here — this is a code fetch."""
        cs_limit = seg_limits.get("cs", 0xFFFFF)
        if (eip & 0xFFFFFFFF) > cs_limit:
            return b"", f"#GP: CS EIP 0x{eip:08X} exceeds limit 0x{cs_limit:05X}"

        out = bytearray()
        first_err = None
        linear_base = ((cs_val & 0xFFFF) << 16) + (eip & 0xFFFFFFFF)
        for i in range(count):
            linear = (linear_base + i) & 0xFFFFFFFF
            paddr, err = self.translate(linear)
            if err:
                first_err = err
                break
            out.append(self.data[paddr])
        return bytes(out), first_err
