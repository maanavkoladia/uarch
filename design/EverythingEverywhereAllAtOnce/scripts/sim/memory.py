"""32KB memory with TLB-based virtual-to-physical translation."""

import json

class TLB:
    """Simple TLB: maps 20-bit VPN -> 3-bit PFN with valid/present/rw/mmio."""
    def __init__(self):
        self.entries = []  # list of dicts

    def load_from_config(self, config_path):
        with open(config_path) as f:
            cfg = json.load(f)
        num_entries = int(cfg["num entries"])
        self.entries = []
        for i in range(num_entries):
            e = cfg["entries"][str(i)]
            self.entries.append({
                "valid":   int(e["valid"]),
                "present": int(e["present"]),
                "r_w":     int(e["r_w"]),
                "mmio":    int(e["MMIO"]),
                "vpn":     int(e["VPN"].split("'h")[1], 16),
                "pfn":     int(e["PFN"].split("'h")[1], 16),
            })

    def add_identity_mapping(self, vaddr, size):
        """Add TLB entries to identity-map a virtual address range into physical memory.
        Maps VPN -> PFN such that data fits within the 32KB physical space.
        Uses the next available physical page."""
        used_pfns = set(e["pfn"] for e in self.entries if e["valid"])
        start_vpn = (vaddr >> 12) & 0xFFFFF
        num_pages = ((size + 0xFFF) >> 12)
        # Find free PFNs (within 32KB = 8 pages with 4KB pages -> PFN 0-7)
        max_pfn = (Memory.SIZE >> 12) - 1
        next_pfn = 0
        for i in range(num_pages):
            vpn = start_vpn + i
            # Skip if already mapped
            if any(e["vpn"] == vpn and e["valid"] for e in self.entries):
                continue
            while next_pfn in used_pfns and next_pfn <= max_pfn:
                next_pfn += 1
            if next_pfn > max_pfn:
                break
            self.entries.append({
                "valid": 1, "present": 1, "r_w": 1, "mmio": 0,
                "vpn": vpn, "pfn": next_pfn,
            })
            used_pfns.add(next_pfn)
            next_pfn += 1

    def translate(self, vaddr):
        """Translate virtual address -> physical address.
        Returns (phys_addr, error_str or None).
        Page size = 4KB (12-bit offset)."""
        vpn = (vaddr >> 12) & 0xFFFFF
        offset = vaddr & 0xFFF
        for e in self.entries:
            if e["vpn"] == vpn:
                if not e["valid"]:
                    return None, f"Page fault: VPN 0x{vpn:05X} not valid"
                if not e["present"]:
                    return None, f"Page fault: VPN 0x{vpn:05X} not present"
                pfn = e["pfn"]
                paddr = (pfn << 12) | offset
                return paddr, None
        return None, f"Page fault: VPN 0x{vpn:05X} not in TLB"


class Memory:
    """32KB byte-addressable memory (15-bit physical address space)."""
    SIZE = 32 * 1024  # 32KB

    def __init__(self):
        self.data = bytearray(self.SIZE)
        self.tlb = TLB()

    def _check_phys(self, paddr, size):
        if paddr < 0 or paddr + size > self.SIZE:
            return f"GP exception: physical address 0x{paddr:04X} + {size} out of range (max 0x{self.SIZE:04X})"
        return None

    def read(self, vaddr, size, seg_base=0):
        """Read `size` bytes from virtual address. Returns (value, error)."""
        linear = (seg_base + vaddr) & 0xFFFFFFFF
        paddr, err = self.tlb.translate(linear)
        if err:
            return None, err
        chk = self._check_phys(paddr, size)
        if chk:
            return None, chk
        val = int.from_bytes(self.data[paddr:paddr+size], 'little')
        return val, None

    def write(self, vaddr, size, value, seg_base=0):
        """Write `size` bytes to virtual address. Returns error or None."""
        linear = (seg_base + vaddr) & 0xFFFFFFFF
        paddr, err = self.tlb.translate(linear)
        if err:
            return err
        chk = self._check_phys(paddr, size)
        if chk:
            return chk
        self.data[paddr:paddr+size] = value.to_bytes(size, 'little')
        return None

    def load_data_section(self, vaddr, byte_data):
        """Load raw bytes at a virtual address (for initialization)."""
        paddr, err = self.tlb.translate(vaddr)
        if err:
            # Direct physical load fallback for init
            paddr = vaddr & (self.SIZE - 1)
        for i, b in enumerate(byte_data):
            pa = paddr + i
            if 0 <= pa < self.SIZE:
                self.data[pa] = b

    def load_bytes_physical(self, paddr, byte_data):
        """Load raw bytes at a physical address directly."""
        for i, b in enumerate(byte_data):
            if 0 <= paddr + i < self.SIZE:
                self.data[paddr + i] = b
