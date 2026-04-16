#!/usr/bin/env python3
"""
TLB RTL Generation Script
Reads a JSON config and emits pure SystemVerilog-2005 structural stimulus
to populate one or more TLBs via hierarchical path assignments.
"""

import json
import sys
import os
import argparse
import re


# --------------------------------------------------------------------------- #
#  Helpers
# --------------------------------------------------------------------------- #

def parse_verilog_literal(literal: str) -> tuple[int, int, str]:
    """
    Parse a Verilog-style literal like  20'h12345  or  1'b0 .
    Returns (width, value, base_char).
    """
    literal = literal.strip().replace("_", "").replace("\u0027", "'")
    m = re.fullmatch(r"(\d+)'([bBoOdDhH])([0-9a-fA-FxXzZ]+)", literal)
    if not m:
        raise ValueError(f"Cannot parse Verilog literal: '{literal}'")
    width = int(m.group(1))
    base  = m.group(2).lower()
    digits = m.group(3)
    bases  = {"b": 2, "o": 8, "d": 10, "h": 16}
    value  = int(digits, bases[base])
    return width, value, base


def format_literal(width: int, value: int, base: str = "h") -> str:
    """Re-format as a clean Verilog literal."""
    if base == "h":
        hex_digits = (width + 3) // 4
        return f"{width}'h{value:0{hex_digits}X}"
    elif base == "b":
        return f"{width}'b{value:0{width}b}"
    else:
        return f"{width}'d{value}"


def bool_bit(val) -> str:
    """Normalise a JSON 0/1 or '0'/'1' field to '0' or '1'."""
    return "1" if str(val).strip() in ("1", "true", "True") else "0"


# --------------------------------------------------------------------------- #
#  JSON loading  (tolerant of the 'paths' array-inside-object quirk)
# --------------------------------------------------------------------------- #

def load_config(path: str) -> dict:
    with open(path) as f:
        raw = f.read()

    # Fix the malformed  "paths": { [ ... ] }  →  "paths": [ ... ]
    raw = re.sub(
        r'"paths"\s*:\s*\{\s*(\[.*?\])\s*\}',
        r'"paths": \1',
        raw,
        flags=re.DOTALL,
    )

    # Replace bare apostrophes inside JSON string values with a safe placeholder
    # (Verilog width specifiers like  20'h  break standard JSON)
    TICK = "__VERILOG_TICK__"
    def escape_ticks(text: str) -> str:
        result, in_str = [], False
        for i, c in enumerate(text):
            if c == '"' and (i == 0 or text[i-1] != '\\'):
                in_str = not in_str
                result.append(c)
            elif c == "'" and in_str:
                result.append(TICK)
            else:
                result.append(c)
        return "".join(result)

    raw = escape_ticks(raw)

    # Remove trailing commas before } or ]
    raw = re.sub(r",\s*([}\]])", r"\1", raw)

    # Deduplicate numeric keys (handles repeated "0" entry keys in original spec)
    def dedup_keys(text):
        out, idx = [], 0
        for line in text.splitlines(keepends=True):
            m = re.match(r'(\s*)"(\d+)"\s*:(.*)', line)
            if m:
                rest = m.group(3)   # preserve anything after the colon (e.g.  " {")
                line = f'{m.group(1)}"{idx}":{rest}\n'
                idx += 1
            out.append(line)
        return "".join(out)

    raw = dedup_keys(raw)

    cfg = json.loads(raw)

    # Restore tick placeholder in all string values recursively
    def restore_ticks(obj):
        if isinstance(obj, dict):
            return {k: restore_ticks(v) for k, v in obj.items()}
        if isinstance(obj, list):
            return [restore_ticks(v) for v in obj]
        if isinstance(obj, str):
            return obj.replace(TICK, "'")
        return obj

    return restore_ticks(cfg)


# --------------------------------------------------------------------------- #
#  Verilog generation
# --------------------------------------------------------------------------- #

INDENT = "    "

def entry_assignments(path: str, idx: int, entry: dict) -> list[str]:
    """
    Return a list of non-blocking assignment lines for one TLB entry.
    path  – hierarchical path to the TLB array, e.g.  dut.u_tlb0.entries
    idx   – entry index
    entry – dict with keys: valid, present, r_w, MMIO, VPN, PFN
    """
    lines = []
    base  = f"{path}[{idx}]"

    # 1-bit fields
    for field in ("valid", "present", "r_w", "MMIO"):
        lines.append(f"{INDENT}{base}.{field} = 1'b{bool_bit(entry[field])};")

    # Multi-bit fields – preserve original width/base from JSON
    for field in ("VPN", "PFN"):
        w, v, b = parse_verilog_literal(entry[field])
        lines.append(f"{INDENT}{base}.{field} = {format_literal(w, v, b)};")

    return lines


def generate_verilog(cfg: dict) -> str:
    module_name  = cfg.get("Module Name", "tlb_init").strip() or "tlb_init"
    startup_ns   = cfg.get("startUpDelay", "30")
    paths        = cfg["paths"]               # list of hierarchical paths
    entries_dict = cfg["entries"]             # dict keyed "0".."N"

    # Sort entries numerically
    entries = [entries_dict[k] for k in sorted(entries_dict, key=lambda x: int(x))]

    num_tlbs    = int(cfg.get("num tlbs",    len(paths)))
    num_entries = int(cfg.get("num entries", len(entries)))

    # Pad / trim paths and entries to declared counts
    while len(paths) < num_tlbs:
        paths.append(f"dut.u_tlb{len(paths)}.entries")
    paths = paths[:num_tlbs]

    while len(entries) < num_entries:
        entries.append(entries[-1])   # repeat last as placeholder
    entries = entries[:num_entries]

    # ------------------------------------------------------------------ #
    lines = []
    lines.append(f"// Auto-generated by gen_tlb.py")
    lines.append(f"// TLBs : {num_tlbs}   Entries/TLB : {num_entries}")
    lines.append("")
    lines.append(f"module {module_name} ();")
    lines.append("")
    lines.append(f"{INDENT}initial begin")
    lines.append(f"{INDENT}{INDENT}// Wait for design to come out of reset")
    lines.append(f"{INDENT}{INDENT}#{startup_ns};")
    lines.append("")

    for t_idx, tlb_path in enumerate(paths):
        lines.append(f"{INDENT}{INDENT}// ---- TLB {t_idx} : {tlb_path} ----")
        for e_idx, entry in enumerate(entries):
            lines.append(f"{INDENT}{INDENT}// Entry {e_idx}")
            lines.extend(entry_assignments(tlb_path, e_idx, entry))
            lines.append("")

    lines.append(f"{INDENT}end  // initial")
    lines.append("")
    lines.append(f"endmodule : {module_name}")
    lines.append("")

    return "\n".join(lines)


# --------------------------------------------------------------------------- #
#  Main
# --------------------------------------------------------------------------- #

def main():
    ap = argparse.ArgumentParser(description="Generate TLB-population Verilog from JSON config.")
    ap.add_argument("config", help="Path to the JSON configuration file")
    args = ap.parse_args()

    cfg = load_config(args.config)

    verilog = generate_verilog(cfg)

    out_dir  = cfg.get("outputPath", "gen/").rstrip("/")
    os.makedirs(out_dir, exist_ok=True)

    module_name = cfg.get("Module Name", "tlb_init").strip() or "tlb_init"
    out_path = os.path.join(out_dir, f"{module_name}.sv")

    with open(out_path, "w") as f:
        f.write(verilog)

    print(f"[gen_tlb] Written → {out_path}")
    print(verilog)


if __name__ == "__main__":
    main()
