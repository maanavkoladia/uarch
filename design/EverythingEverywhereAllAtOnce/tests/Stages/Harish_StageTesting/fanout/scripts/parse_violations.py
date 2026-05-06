#!/usr/bin/env python3
"""
parse_violations.py — group fanout VIOLATION and WARNING lines from check.log.

Usage:
    python3 scripts/parse_violations.py [check.log]

Sections:
    VIOLATIONS BY GROUP  — deduplicated by exact driver path, sorted by unique-path count
    FIX RECIPE           — edit module, overloaded wire name, leaf driver, buffer recipe
    INPUT PORT BUFFERING — WARNING input ports with fanout breakdown and buffer stage count
    MODULE SUMMARY       — which RTL modules appear most often across deduplicated violations
"""

import sys
import re
import collections

LOG = sys.argv[1] if len(sys.argv) > 1 else "check.log"

# ── regex patterns ──────────────────────────────────────────────────────────
RE_VIOLATION = re.compile(
    r"^VIOLATION:\s+wire\s+'([^']+)'\s+\(fanout=(\d+)[^)]*\)\s+"
    r"driven by\s+([^,]+),\s+expected\s+(.+)$"
)
# WARNING with internal/external breakdown
RE_WARNING_SPLIT = re.compile(
    r"^WARNING:\s+'([^']+)'\s+\(fanout=(\d+):\s*(\d+)\s+internal\s*\+\s*(\d+)\s+output ports\)"
)
# WARNING without breakdown (fallback)
RE_WARNING_PLAIN = re.compile(
    r"^WARNING:\s+'([^']+)'\s+\(fanout=(\d+)[^)]*\)"
)
RE_DRIVER = re.compile(r"^\s+driver:\s+(.+)$")
RE_INPUT_PORT = re.compile(r"^\s+driver:\s+input port\s+'([^']+)'$")

# Parses every  inst(module)  or  inst(cell).port  segment
RE_SEG = re.compile(r"([\w.\[\]]+)\(([^)]+)\)(?:\.(\w+))?")


def parse_segments(driver_str):
    return RE_SEG.findall(driver_str)


def leaf_cell(driver_str):
    segs = parse_segments(driver_str)
    return segs[-1][1] if segs else "unknown"


def containing_module(driver_str):
    segs = parse_segments(driver_str)
    return segs[-2][1] if len(segs) >= 2 else "unknown"


def leaf_inst_port(driver_str):
    segs = parse_segments(driver_str)
    if not segs:
        return "?", "?", "?"
    inst_raw, cell, port = segs[-1]
    return re.sub(r"\[\d+\]", "[N]", inst_raw), cell, port or "out"


def module_chain_collapsed(driver_str):
    return re.sub(r"\[\d+\]", "[*]", driver_str).strip()


def all_modules(driver_str):
    return [m for _, m, _ in parse_segments(driver_str)]


def collapse_name(name):
    return re.sub(r"\[\d+\]", "[*]", name)


def stages_needed(fanout):
    """Cascaded bufferH16$ stages required (each stage drives ≤16 loads)."""
    if fanout <= 16:   return 1
    if fanout <= 256:  return 2
    return 3


# ── parse ───────────────────────────────────────────────────────────────────
records_raw  = []   # all VIOLATION records before dedup
warnings_raw = []   # all WARNING records before dedup
pending      = None

with open(LOG) as fh:
    for line in fh:
        line = line.rstrip("\n")

        vm = RE_VIOLATION.match(line)
        ws = RE_WARNING_SPLIT.match(line)
        wp = RE_WARNING_PLAIN.match(line) if not ws else None

        if vm:
            pending = {
                "severity":    "VIOLATION",
                "wire_name":   vm.group(1),
                "fanout":      int(vm.group(2)),
                "driver_cell": vm.group(3).strip(),
                "driver_path": None,
                "internal":    None,
                "external":    None,
            }
            continue

        if ws:
            pending = {
                "severity":    "WARNING",
                "wire_name":   ws.group(1),
                "fanout":      int(ws.group(2)),
                "internal":    int(ws.group(3)),
                "external":    int(ws.group(4)),
                "driver_cell": "input_port",
                "driver_path": None,
            }
            continue

        if wp:
            pending = {
                "severity":    "WARNING",
                "wire_name":   wp.group(1),
                "fanout":      int(wp.group(2)),
                "internal":    None,
                "external":    None,
                "driver_cell": "input_port",
                "driver_path": None,
            }
            continue

        dm = RE_DRIVER.match(line)
        if dm and pending is not None:
            pending["driver_path"] = dm.group(1)
            # for input-port WARNINGs, capture exact port name from driver line
            ip = RE_INPUT_PORT.match(line)
            pending["port_name"] = ip.group(1) if ip else pending["wire_name"]
            if pending["severity"] == "VIOLATION":
                records_raw.append(pending)
            else:
                warnings_raw.append(pending)
            pending = None
            continue

        if line.strip() and pending is not None:
            pending = None


# ── deduplicate by exact driver_path ─────────────────────────────────────────
def dedup(lst):
    seen, out = set(), []
    for r in lst:
        k = r["driver_path"]
        if k not in seen:
            seen.add(k)
            out.append(r)
    return out


records  = dedup(records_raw)
warnings = dedup(warnings_raw)
dup_viol = len(records_raw)  - len(records)
dup_warn = len(warnings_raw) - len(warnings)


# ── group violations ──────────────────────────────────────────────────────────
GroupKey = collections.namedtuple("GroupKey", ["driver_cell", "path"])

groups = collections.defaultdict(list)
for r in records:
    path = module_chain_collapsed(r["driver_path"]) if r["driver_path"] else "(no driver)"
    groups[GroupKey(r["driver_cell"], path)].append(r)

module_counts = collections.Counter()
for r in records:
    if r["driver_path"]:
        for mod in all_modules(r["driver_path"]):
            module_counts[mod] += 1

sorted_groups = sorted(groups.items(), key=lambda kv: -len(kv[1]))


# ── group warnings by collapsed port name ─────────────────────────────────────
warn_groups = collections.defaultdict(list)
for w in warnings:
    warn_groups[collapse_name(w["wire_name"])].append(w)


# ── output ────────────────────────────────────────────────────────────────────
SEP = "=" * 80

print(SEP)
print("VIOLATIONS BY GROUP  (deduplicated — duplicate log lines removed, sorted by count)")
print(SEP)
print(f"  Unique VIOLATION paths : {len(records)}  ({dup_viol} duplicate lines removed from log)")
print(f"  Unique WARNING paths   : {len(warnings)}  ({dup_warn} duplicate lines removed from log)")
print(f"  Unique violation groups: {len(groups)}")
print()

for key, recs in sorted_groups:
    fanouts = sorted({r["fanout"] for r in recs})
    max_fan = max(fanouts)
    fan_str = ", ".join(str(f) for f in fanouts)
    print(f"[VIOLATION]  unique_paths={len(recs)}   driver_cell={key.driver_cell}"
          f"   fanout(s)={fan_str}   ({stages_needed(max_fan)}-stage buffer)")
    print(f"  path : {key.path}")
    print()


# ── FIX RECIPE ────────────────────────────────────────────────────────────────
print()
print(SEP)
print("FIX RECIPE  (VIOLATIONS only, deduplicated)")
print(SEP)
print("  EDIT MODULE : Verilog module whose source needs changing")
print("  WIRE        : overloaded net name inside that module")
print("  LEAF DRIVER : inst(cell).port — the gate driving WIRE")
print("  STAGES      : cascaded bufferH16$ needed  (1→fanout≤16, 2→≤256, 3→≤4096)")
print("  FIX         : wire WIRE_buf;")
print("                bufferH16$ u_buf_INST (.out(WIRE_buf), .in(WIRE));")
print("                replace all downstream uses of WIRE with WIRE_buf")
print("  EXAMPLE     : one concrete (non-collapsed) driver path from the log")
print()

for idx, (key, recs) in enumerate(sorted_groups, 1):
    fanouts  = sorted({r["fanout"] for r in recs})
    max_fan  = max(fanouts)
    fan_str  = ", ".join(str(f) for f in fanouts)
    ex       = next((r for r in recs if r["driver_path"]), None)
    if ex:
        inst, cell, port = leaf_inst_port(ex["driver_path"])
        cont_mod = containing_module(ex["driver_path"])
        wire     = ex["wire_name"]
        ex_path  = ex["driver_path"]
    else:
        inst = cell = port = cont_mod = wire = ex_path = "?"

    buf_inst = f"u_buf_{inst.replace('[N]','').rstrip('_')}"
    print(f"── #{idx}  unique_paths={len(recs)}  max_fanout={max_fan}  ({stages_needed(max_fan)}-stage buffer)")
    print(f"   EDIT MODULE : {cont_mod}")
    print(f"   WIRE        : {wire}")
    print(f"   LEAF DRIVER : {inst}({cell}).{port}")
    print(f"   FIX         : wire {wire}_buf;")
    print(f"                 bufferH16$ {buf_inst} (.out({wire}_buf), .in({wire}));")
    print(f"   EXAMPLE     : {ex_path}")
    print()


# ── INPUT PORT BUFFERING ──────────────────────────────────────────────────────
print()
print(SEP)
print("INPUT PORT BUFFERING  (WARNING input ports — add bufferH16$ tree at EXE top-level)")
print(SEP)
print("  Each row = one bus/port at the EXE module boundary with too many internal loads.")
print("  Fix: in EXE_structural.v, buffer the input through a bufferH16$ and use the")
print("  buffered copy internally.  If STAGES=2, cascade two bufferH16$ in a fan-out tree.")
print()
hdr = f"  {'PORT (collapsed)':<48} {'MAX_FAN':>7}  {'INTERNAL':>8}  {'EXT_PORTS':>9}  {'STAGES':>6}  {'BITS':>4}"
print(hdr)
print("  " + "-" * (len(hdr) - 2))

for col_name, wrecs in sorted(warn_groups.items(), key=lambda kv: -max(w["fanout"] for w in kv[1])):
    max_fan  = max(w["fanout"] for w in wrecs)
    best     = max(wrecs, key=lambda w: w["fanout"])
    internal = str(best["internal"]) if best["internal"] is not None else "?"
    external = str(best["external"]) if best["external"] is not None else "?"
    bits     = len(wrecs)
    print(f"  {col_name:<48} {max_fan:>7}  {internal:>8}  {external:>9}  {stages_needed(max_fan):>6}  {bits:>4}")


# ── MODULE SUMMARY ────────────────────────────────────────────────────────────
print()
print(SEP)
print("MODULE SUMMARY  (deduplicated violation count by RTL module, highest first)")
print(SEP)

SKIP = re.compile(r"(mux[234]\$|nand[234]\$|nor[234]\$|and[234]\$|or[234]\$|"
                  r"xor2\$|xnor2\$|inv1\$|dff\$|buffer\$|bufferH\d+\$|"
                  r"bufferHInv\d+\$|reg64e\$|reg32e\$|latch\$|MPS_|EQ_\d|"
                  r"GEN_XOR|GEN_STAGE|GEN_BIT|g_active|g_gray|g_black|"
                  r"gen_pg|gen_stage|gen_bit|gen_sum)")
rtl_mods = {m: c for m, c in module_counts.items() if not SKIP.match(m)}
for mod, cnt in sorted(rtl_mods.items(), key=lambda kv: -kv[1]):
    print(f"  {cnt:5d}  {mod}")

print()
print(SEP)
print("DONE")

