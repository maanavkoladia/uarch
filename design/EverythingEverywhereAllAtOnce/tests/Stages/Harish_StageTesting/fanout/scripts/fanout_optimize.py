#!/usr/bin/env python3
"""fanout_optimize.py -- analyze Design Vision fanout violations and emit
a markdown report of register-duplication / buffer-insertion options
ranked by added delay.

Usage:
    python3 scripts/fanout_optimize.py \
        --check-log ./check.log \
        --module icache \
        --output reports/icache_fanout_plan.md

`--module` selects the module-of-interest. The script filters violations
whose driver lives anywhere inside that module's hierarchy and recommends
fixes. A separate appendix lists cross-module violations whose driver's
module name suggests a load on the requested module (heuristic, since
check.log does not expose load lists by default).
"""

import argparse
import re
from collections import Counter
from pathlib import Path
from typing import List, Optional, Tuple, Dict


# ----------------------------------------------------------------------
# Cost model from lib/Gates/lib2.v (typical t_p in ns; mid value)
# ----------------------------------------------------------------------
BUFFER_DELAY_NS = {
    "bufferH16$":      0.24,
    "bufferH64$":      0.30,
    "bufferH256$":     0.54,
    "bufferH1024$":    0.60,
    "bufferH4096$":    0.80,
    "bufferHInv16$":   0.15,
    "bufferHInv64$":   0.39,
    "bufferHInv256$":  0.45,
    "bufferHInv1024$": 0.69,
    "bufferHInv4096$": 0.89,
}

SEQUENTIAL_REFS = {
    "reg64e$", "reg32e$",
    "dff$", "dff8$", "dff16$", "dff16b$", "dff32b$",
    "jkff8$", "jkff16$",
    "ioreg8$", "ioreg16$",
    "latch$", "latch8$", "latch16$",
}
INV_REFS = {"inv1$"}
COMB_REFS = {
    "and2$", "and3$", "and4$",
    "nand2$", "nand3$", "nand4$",
    "or2$", "or3$", "or4$",
    "nor2$", "nor3$", "nor4$",
    "mux2$", "mux3$", "mux4$",
    "mux2_8$", "mux2_16$", "mux3_8$", "mux3_16$", "mux4_8$", "mux4_16$",
    "xor2$", "xnor2$",
}


def required_tier(fanout: int) -> Optional[Tuple[str, str]]:
    if fanout <= 4:     return None
    if fanout <= 16:    return ("bufferH16$",   "bufferHInv16$")
    if fanout <= 64:    return ("bufferH64$",   "bufferHInv64$")
    if fanout <= 256:   return ("bufferH256$",  "bufferHInv256$")
    if fanout <= 1024:  return ("bufferH1024$", "bufferHInv1024$")
    if fanout <= 4096:  return ("bufferH4096$", "bufferHInv4096$")
    return None


def tier_delay(fanout: int) -> float:
    """Min added delay to satisfy the rule for a wire with this fanout. 0 if fanout<=4."""
    t = required_tier(fanout)
    if t is None:
        return 0.0
    return BUFFER_DELAY_NS[t[0]]


def best_dup_strategy(F: int):
    """Find the K (copies of a register) that minimizes total added delay.

    Modeling assumptions:
      - The original register's D input was fanout-1 before duplication. After cloning into K copies,
        D has fanout K and may itself need a buffer of tier(K).
      - Each copy drives ~ceil(F/K) loads on its Q. If that exceeds 4, a per-copy buffer of
        tier(ceil(F/K)) is needed.
      - Total added delay on a load path = D_input_buffer_delay + per_copy_output_buffer_delay
        (the two buffers are in series on the same path). Tcq is unchanged.

    Returns dict with K, per_copy, out_tier, in_tier, out_delay, in_delay, total_delay.
    """
    if F <= 4:
        return None
    candidates = set()
    candidates.add(2)
    candidates.add(3)
    candidates.add(max(2, (F + 3) // 4))     # K such that per-copy <= 4 (no output buffer)
    candidates.add(max(2, (F + 15) // 16))    # K such that per-copy <= 16
    candidates.add(max(2, (F + 63) // 64))    # K such that per-copy <= 64
    candidates.add(max(2, (F + 255) // 256))  # K such that per-copy <= 256
    best = None
    for K in sorted(candidates):
        per_copy = (F + K - 1) // K
        out_t = required_tier(per_copy)
        in_t = required_tier(K)
        out_d = BUFFER_DELAY_NS[out_t[0]] if out_t else 0.0
        in_d = BUFFER_DELAY_NS[in_t[0]] if in_t else 0.0
        total = out_d + in_d
        rec = {
            "K": K, "per_copy": per_copy,
            "out_tier": out_t, "in_tier": in_t,
            "out_delay": out_d, "in_delay": in_d,
            "total_delay": total,
        }
        if best is None or total < best["total_delay"]:
            best = rec
    return best


# ----------------------------------------------------------------------
# Per-module configuration
# ----------------------------------------------------------------------
MODULE_CONFIG = {
    "icache": {
        "filter_modules": [
            "ICache",
            "ICache_Controller_Logic",
            "ICache_TagStore",
            "ICache_DataStore",
            "I_VCache",
        ],
        "fanout_folder": "rtl/ICache/structural/fanout",
        "module_to_file": {
            "ICache":                  "rtl/ICache/structural/fanout/ICache_structural.v",
            "ICache_Controller_Logic": "rtl/ICache/structural/fanout/ICache_Controller_Logic.sv",
            "ICache_TagStore":         "rtl/ICache/structural/fanout/ICache_TagStore_structural.v",
            "ICache_DataStore":        "rtl/ICache/structural/fanout/ICache_DataStore_structural.v",
            "I_VCache":                "rtl/ICache/structural/fanout/I_VCache_structural.v",
        },
        "cross_module_hints": ["icache"],  # case-insensitive substring match on driver-side module name
    },
    "dcache": {
        "filter_modules": [
            "DCache_TOP", "DCache_Block", "DCache_Bank", "DCache_Bank_TagStore",
            "DCache_Bank_DataStore", "DCache_Bank_FSM", "DCache_Arbitration",
            "EvictionBuf", "LRU", "MIO_Block", "VCache", "VCache_TagStore",
            "VCache_DataStore", "VCache_FSM",
        ],
        "fanout_folder": "rtl/DCache/structural/fanout",
        "module_to_file": {},  # to be populated when fanout/ is seeded
        "cross_module_hints": ["dcache"],
    },
    "mem": {
        "filter_modules": [
            "mem_TOP", "MemBank", "mem_controller",
            "bank_controller_fsm_logic", "mem_controller_fsm",
        ],
        "fanout_folder": "rtl/mem/structural/fanout",
        "module_to_file": {},
        "cross_module_hints": ["mem"],
    },
    "busArb": {
        "filter_modules": [
            "BusArbitration", "DTE", "Scheduler", "Scheduler_DCachePicking",
            "DTE_Core_2_DDR5_FSM", "DTE_Core_2_DMA_FSM", "DTE_DCache_2_MEM_FSM",
            "DTE_DDR5_2_Core_FSM", "DTE_DMA_2_MEM_FSM", "DTE_MEM_2_DCache_FSM",
            "DTE_MEM_2_ICache_FSM",
        ],
        "fanout_folder": "rtl/BusArbitration/structural/fanout",
        "module_to_file": {},
        "cross_module_hints": ["busarb", "scheduler", "dte"],
    },
    "dma": {
        "filter_modules": ["DMA_Controller", "DMA_FSM"],
        "fanout_folder": "rtl/io/DMA_Controller/structural/fanout",
        "module_to_file": {},
        "cross_module_hints": ["dma"],
    },
    "ddr5": {
        "filter_modules": ["ddr5"],
        "fanout_folder": "rtl/io/ddr5/structural/fanout",
        "module_to_file": {},
        "cross_module_hints": ["ddr5"],
    },
}


# ----------------------------------------------------------------------
# Data classes (plain classes for Python 3.6 compatibility)
# ----------------------------------------------------------------------
class HierarchyNode:
    __slots__ = ("instance", "module")
    def __init__(self, instance: str, module: str):
        self.instance = instance
        self.module = module

class Violation:
    __slots__ = ("kind", "raw_line", "wire", "fanout", "driver_ref",
                 "expected", "driver_paths", "note", "n_internal", "n_outputs")
    def __init__(self, kind: str, raw_line: str, wire: str, fanout: int,
                 driver_ref: str, expected: List[str],
                 driver_paths: Optional[List[List[HierarchyNode]]] = None,
                 note: str = "", n_internal: int = 0, n_outputs: int = 0):
        self.kind = kind
        self.raw_line = raw_line
        self.wire = wire
        self.fanout = fanout
        self.driver_ref = driver_ref
        self.expected = expected
        self.driver_paths = driver_paths if driver_paths is not None else []
        self.note = note
        self.n_internal = n_internal
        self.n_outputs = n_outputs

class Recommendation:
    __slots__ = ("label", "delay_ns", "description")
    def __init__(self, label: str, delay_ns: float, description: str):
        self.label = label
        self.delay_ns = delay_ns
        self.description = description


# ----------------------------------------------------------------------
# Parser
# ----------------------------------------------------------------------
HEADER_RE = re.compile(r'^(VIOLATION|WARNING|INFO|OK):')
WIRE_FANOUT_RE = re.compile(r"wire '([^']+)'\s*\(fanout=(\d+)\)")
PORT_FANOUT_RE = re.compile(r"'([^']+)'\s*\(fanout=(\d+):\s*(\d+)\s+internal\s+\+\s+(\d+)\s+output")
DRIVEN_BY_RE = re.compile(r"driven by ([\w$]+)")
EXPECTED_RE = re.compile(r"expected\s+([\w$]+)(?:\s+or\s+([\w$]+))?")
CHAIN_NODE_RE = re.compile(r"^([^()\s][^()]*)\(([^)]+)\)(?:\.(.+))?$")
INPUT_PORT_RE = re.compile(r"input port '([^']+)'")


def parse_check_log(path: Path) -> List[Violation]:
    """Read check.log and return one Violation per emitted block."""
    text = path.read_text(errors="replace")
    lines = text.splitlines()
    out: List[Violation] = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if not HEADER_RE.match(line):
            i += 1
            continue
        block = [line]
        j = i + 1
        # Block continues for any line starting with 2+ spaces; blank line ends it.
        while j < len(lines):
            nxt = lines[j]
            if nxt.strip() == "":
                break
            if HEADER_RE.match(nxt):
                break
            if not nxt.startswith("  "):
                break
            block.append(nxt)
            j += 1
        v = parse_block(block)
        if v is not None:
            out.append(v)
        i = j
    return out


def parse_block(block: List[str]) -> Optional[Violation]:
    header = block[0]
    m_kind = HEADER_RE.match(header)
    if not m_kind:
        return None
    kind = m_kind.group(1)

    wire = ""
    fanout = 0
    n_internal = 0
    n_outputs = 0

    m_wf = WIRE_FANOUT_RE.search(header)
    if m_wf:
        wire = m_wf.group(1)
        fanout = int(m_wf.group(2))
    else:
        m_pf = PORT_FANOUT_RE.search(header)
        if m_pf:
            wire = m_pf.group(1)
            fanout = int(m_pf.group(2))
            n_internal = int(m_pf.group(3))
            n_outputs = int(m_pf.group(4))
        else:
            # tristate-bus mismatch: "wire 'addressBus[X]' has K non-tristate..."
            m_tri = re.search(r"wire '([^']+)' has \d+ non-tristate", header)
            if m_tri:
                wire = m_tri.group(1)
                fanout = 0
            else:
                # Unknown header form -- skip
                return None

    m_drv = DRIVEN_BY_RE.search(header)
    driver_ref = m_drv.group(1) if m_drv else ""

    expected: List[str] = []
    m_exp = EXPECTED_RE.search(header)
    if m_exp:
        expected = [m_exp.group(1)]
        if m_exp.group(2):
            expected.append(m_exp.group(2))

    note = classify_note(header)

    driver_paths: List[List[HierarchyNode]] = []
    for L in block[1:]:
        s = L.strip()
        if not s:
            continue
        # Header lines: "driver:", "drivers:", "bad drivers:", "internal loads:", etc.
        if s.endswith(":") and " " not in s.rstrip(":"):
            continue
        if s.startswith("driver:"):
            chain_str = s[len("driver:"):].strip()
        else:
            chain_str = s
        # Chain begins with "(top)" or "input port '...'"
        if chain_str.startswith("(") or chain_str.startswith("input port"):
            hpath = parse_chain(chain_str)
            if hpath:
                driver_paths.append(hpath)

    return Violation(
        kind=kind, raw_line=header, wire=wire, fanout=fanout,
        driver_ref=driver_ref, expected=expected,
        driver_paths=driver_paths, note=note,
        n_internal=n_internal, n_outputs=n_outputs,
    )


def classify_note(header: str) -> str:
    if "over-buffered" in header:                  return "over-buffered"
    if "tristate_bus_driver" in header:            return "tristate-bus"
    if "non-tristate_bus_driver" in header:        return "tristate-bus-mismatch"
    if "is a clock signal" in header:              return "clock"
    if "is a reset signal" in header:              return "reset"
    if "tied constant" in header:                  return "tied-const"
    if "undefined (X)" in header:                  return "undefined-x"
    if "driver is external" in header or "loads are external" in header:
        return "boundary"
    return ""


def parse_chain(chain_str: str) -> List[HierarchyNode]:
    """Parse '(top) -> inst1(mod1) -> ... -> instN(modN).pin' into HierarchyNodes."""
    nodes: List[HierarchyNode] = []
    parts = [p.strip() for p in chain_str.split("->")]
    for p in parts:
        if not p:
            continue
        if p.startswith("(") and p.endswith(")"):
            nodes.append(HierarchyNode(instance="(top)", module=p[1:-1]))
            continue
        m_in = INPUT_PORT_RE.match(p)
        if m_in:
            nodes.append(HierarchyNode(instance=m_in.group(1), module="<INPUT_PORT>"))
            continue
        m = CHAIN_NODE_RE.match(p)
        if m:
            nodes.append(HierarchyNode(instance=m.group(1).strip(),
                                       module=m.group(2).strip()))
    return nodes


# ----------------------------------------------------------------------
# Scope and host-module identification
# ----------------------------------------------------------------------
def violation_in_scope(v: Violation, cfg: dict) -> bool:
    """Driver lives somewhere inside the requested module's hierarchy."""
    for path in v.driver_paths:
        for n in path:
            if n.module in cfg["filter_modules"]:
                return True
    return False


def is_cross_module_hint(v: Violation, cfg: dict) -> bool:
    """Heuristic: driver module name contains the module hint (e.g. ICache as substring
    of DTE_MEM_2_ICache_FSM). Driver isn't in our scope but probably affects loads in our module."""
    hints = [h.lower() for h in cfg.get("cross_module_hints", [])]
    for path in v.driver_paths:
        for n in path:
            mod_l = n.module.lower()
            if any(h in mod_l for h in hints):
                # Don't double-count if it's already in scope
                return not violation_in_scope(v, cfg)
    return False


def locate_user_module(v: Violation, cfg: dict) -> Tuple[str, str]:
    """Walk the driver path; return (host_module, instance_below_host).
    Host = deepest node whose module is in filter_modules.
    Instance = the next node down (the user-visible wrapper instance to clone)."""
    if not v.driver_paths:
        return ("?", "?")
    p = v.driver_paths[0]
    for i in range(len(p) - 1, -1, -1):
        if p[i].module in cfg["filter_modules"]:
            below = p[i + 1] if i + 1 < len(p) else p[i]
            return (p[i].module, below.instance)
    return ("?", "?")


def classify_driver(driver_ref: str) -> str:
    if driver_ref in SEQUENTIAL_REFS:
        return "SEQ"
    if driver_ref in INV_REFS:
        return "INV"
    if "buffer" in driver_ref.lower():
        return "BUFFER"
    if driver_ref in COMB_REFS:
        return "COMB"
    return "OTHER"


# ----------------------------------------------------------------------
# Recommendations
# ----------------------------------------------------------------------
def recommend_for_seq(v: Violation, cfg: dict, tier: Tuple[str, str]) -> List[Recommendation]:
    nonInv, inv = tier
    nonInv_d = BUFFER_DELAY_NS[nonInv]
    inv_d = BUFFER_DELAY_NS[inv]
    host_module, inst = locate_user_module(v, cfg)
    host_file = cfg["module_to_file"].get(host_module, f"<file for {host_module}>")

    F = v.fanout
    best = best_dup_strategy(F)

    opts: List[Recommendation] = []

    # Build register-duplication recommendation with cascade-aware costing.
    K = best["K"]
    per_copy = best["per_copy"]
    out_t = best["out_tier"]
    in_t = best["in_tier"]
    out_d = best["out_delay"]
    in_d = best["in_delay"]
    total = best["total_delay"]
    out_buf_str = f"`{out_t[0]}` ({out_d:.2f} ns)" if out_t else "no per-copy buffer"
    in_buf_str = f"`{in_t[0]}` ({in_d:.2f} ns)" if in_t else "no input buffer"
    desc_dup = (
        f"In `{host_file}` clone `{inst}` into {K} copies (`{inst}_a` … `{inst}_{chr(ord('a')+K-1)}`); "
        f"each copy drives ~{per_copy} loads. "
        f"**Output side**: per-copy fanout = {per_copy} → {out_buf_str}. "
        f"**Input side (D)**: fanout = {K} on the next-state wire → {in_buf_str}. "
        f"clk/rst are clock-tree distributed so they don't count. "
        f"Total added delay on a load path = {out_d:.2f} + {in_d:.2f} = **{total:.2f} ns**. "
        f"This assumes D was fanout-1 before duplication; if the next-state expression already feeds "
        f"other loads, the input-side cost may be smaller (existing buffer reused) or larger "
        f"(extra cascade)."
    )
    opts.append(Recommendation(f"Register duplication × {K}", total, desc_dup))

    # Buffer-only alternative (no duplication, just one buffer between Q and loads).
    desc_buf = (
        f"Insert `{nonInv}` between `{inst}.q` and its loads in `{host_file}`. The buffer's input is "
        f"a single load on `{inst}.q` (fanout-1, no upstream cascade). Adds **{nonInv_d:.2f} ns** "
        f"on every path through this signal."
    )
    opts.append(Recommendation(f"Buffer with {nonInv}", nonInv_d, desc_buf))

    # Inverting buffer (cheaper but requires polarity absorption).
    desc_inv = (
        f"Use `{inv}` (single inverter, **{inv_d:.2f} ns**) only if every downstream consumer of "
        f"`{inst}.q` can absorb the inversion (NAND↔AND swap, mux input swap, etc.). Otherwise "
        f"pair-cost = {2*inv_d:.2f} ns and `{nonInv}` is cheaper."
    )
    opts.append(Recommendation(f"Buffer with {inv} (polarity flip needed)", inv_d, desc_inv))

    # Lead with whichever is cheapest. Use a stable sort that preserves input order on ties.
    opts.sort(key=lambda r: r.delay_ns)
    return opts


def recommend_for_comb(v: Violation, cfg: dict, tier: Tuple[str, str]) -> List[Recommendation]:
    nonInv, inv = tier
    nonInv_d = BUFFER_DELAY_NS[nonInv]
    inv_d = BUFFER_DELAY_NS[inv]
    host_module, inst = locate_user_module(v, cfg)
    host_file = cfg["module_to_file"].get(host_module, f"<file for {host_module}>")

    F = v.fanout
    best = best_dup_strategy(F)

    opts: List[Recommendation] = []

    # Combinational gate replication / fanin-tree replication via upstream register cloning.
    # Cost model: same as register duplication. Each copy of the gate has its M inputs each at
    # fanout K (assuming the original inputs were fanout-1 to this gate). Only one delay matters
    # because the M input buffers are in parallel.
    K = best["K"]
    per_copy = best["per_copy"]
    out_t = best["out_tier"]
    in_t = best["in_tier"]
    out_d = best["out_delay"]
    in_d = best["in_delay"]
    total = best["total_delay"]
    out_buf_str = f"`{out_t[0]}` ({out_d:.2f} ns)" if out_t else "no per-copy buffer"
    in_buf_str = f"`{in_t[0]}` ({in_d:.2f} ns) per upstream input wire" if in_t else "no input buffer"
    desc_dup = (
        f"In `{host_file}` instantiate `{inst}` (a `{v.driver_ref}`-class gate) {K} times with the "
        f"same fanin; split loads ~{per_copy} per copy. **Cleaner equivalent**: trace upstream to the "
        f"source register(s) feeding `{inst}` and clone *those*; the gate is rebuilt per copy "
        f"automatically. Either way: "
        f"**Output side**: per-copy fanout = {per_copy} → {out_buf_str}. "
        f"**Input side**: each fan-in wire of `{inst}` now has +{K-1} extra loads → {in_buf_str}. "
        f"Total added delay = {out_d:.2f} + {in_d:.2f} = **{total:.2f} ns**. "
        f"If the gate's fanin signals were already high-fanout, the cascade may be cheaper than "
        f"shown (existing buffer reused) -- worth inspecting `{host_file}`."
    )
    opts.append(Recommendation(f"Replicate gate × {K} (or duplicate source register × {K})", total, desc_dup))

    desc_buf = (
        f"Insert `{nonInv}` after `{inst}.out` in `{host_file}`; routes all {F} loads through "
        f"one buffer. The buffer's input is a fanout-1 load on `{inst}.out` (no upstream cascade). "
        f"Adds **{nonInv_d:.2f} ns** to every load path."
    )
    opts.append(Recommendation(f"Buffer with {nonInv}", nonInv_d, desc_buf))

    desc_inv = (
        f"Use `{inv}` (inverting, **{inv_d:.2f} ns**) only if every consumer of `{inst}.out` "
        f"can absorb the inversion. Pair cost = {2*inv_d:.2f} ns."
    )
    opts.append(Recommendation(f"Buffer with {inv} (polarity flip needed)", inv_d, desc_inv))

    opts.sort(key=lambda r: r.delay_ns)
    return opts


def recommend_for_inv(v: Violation, cfg: dict, tier: Tuple[str, str]) -> List[Recommendation]:
    nonInv, inv = tier
    inv_d = BUFFER_DELAY_NS[inv]
    nonInv_d = BUFFER_DELAY_NS[nonInv]
    host_module, inst = locate_user_module(v, cfg)
    host_file = cfg["module_to_file"].get(host_module, f"<file for {host_module}>")

    opts: List[Recommendation] = []
    opts.append(Recommendation(
        f"Swap inv1$ → {inv} at this gate", 0.00,
        f"In `{host_file}` (instance `{inst}`), replace the `inv1$` cell with `{inv}` "
        f"(single inverter, higher drive). Same logical function, same single-stage delay. "
        f"**Note**: `inv_N$` macro in `lib/STDCells/UniqueLib.v` currently maps to `inv1$`; "
        f"upgrading the macro globally would clear all such inverter violations at once."
    ))
    opts.append(Recommendation(
        f"Insert {inv} after the inverter", inv_d,
        f"Keep `inv1$` and add a `{inv}` buffer downstream; flip polarity in dependent logic. "
        f"Adds {inv_d:.2f} ns; pair cost = {2*inv_d:.2f} ns."
    ))
    opts.append(Recommendation(
        f"Insert {nonInv} (non-inverting)", nonInv_d,
        f"Cleanest fix: keep current inverter as the polarity flip and add `{nonInv}` buffer "
        f"to drive the high fanout. Adds {nonInv_d:.2f} ns."
    ))
    return opts


def make_recommendations(v: Violation, cfg: dict) -> List[Recommendation]:
    if v.fanout <= 4:
        return []
    tier = required_tier(v.fanout)
    if tier is None:
        return []
    cls = classify_driver(v.driver_ref)
    if cls == "SEQ":
        opts = recommend_for_seq(v, cfg, tier)
    elif cls == "COMB":
        opts = recommend_for_comb(v, cfg, tier)
    elif cls == "INV":
        opts = recommend_for_inv(v, cfg, tier)
    elif cls == "BUFFER":
        return [Recommendation("Already buffered", 0.00,
                               "Driver is itself a buffer. Likely an over-buffering INFO -- "
                               "either downsize the buffer or accept the slack.")]
    else:
        nonInv, inv = tier
        nonInv_d = BUFFER_DELAY_NS[nonInv]
        opts = [Recommendation(f"Insert {nonInv}", nonInv_d,
                               f"Driver class for `{v.driver_ref}` not specifically modeled. "
                               f"Default: insert `{nonInv}` ({nonInv_d:.2f} ns).")]
    # Keep the order chosen by each recommend_for_* function: position 0 is the recommendation.
    # Don't sort by delay alone -- a 0-ns option may still be the wrong recommendation
    # (e.g. cloning a wide combinational gate × 34 explodes the fanin tree).
    return opts


# ----------------------------------------------------------------------
# Report rendering
# ----------------------------------------------------------------------
INV_MACRO_WARNING = (
    "> **Note on `inv_N$`**: as of this report, `lib/STDCells/UniqueLib.v` "
    "still wraps `inv1$` (drive ~1) inside `inv_N$`, **not** `bufferHInv16$`. "
    "Many recommendations assume the macro will be upgraded. If the macro has "
    "already been changed in another branch, ignore this note. Otherwise, "
    "either upgrade the macro globally (clears every inverter-driven violation "
    "at once) or instantiate `bufferHInv*$` explicitly per violation.\n"
)


def render_report(violations: List[Violation], cfg: dict, module_name: str) -> str:
    in_scope     = [v for v in violations if v.kind == "VIOLATION" and v.note != "tristate-bus-mismatch" and violation_in_scope(v, cfg)]
    cross_module = [v for v in violations if v.kind == "VIOLATION" and v.note != "tristate-bus-mismatch" and is_cross_module_hint(v, cfg)]
    bus_mismatch = [v for v in violations if v.kind == "VIOLATION" and v.note == "tristate-bus-mismatch"]
    boundary     = [v for v in violations if v.kind == "WARNING" and is_cross_module_hint(v, cfg)]
    overbuf      = [v for v in violations if v.kind == "INFO" and v.note == "over-buffered" and violation_in_scope(v, cfg)]

    total_violations = sum(1 for v in violations if v.kind == "VIOLATION")

    L: List[str] = []
    L.append(f"# Fanout report -- module `{module_name}`")
    L.append("")
    L.append(f"_Generated by `tests/Stages/Harish_StageTesting/fanout/scripts/fanout_optimize.py`._")
    L.append("")
    L.append(INV_MACRO_WARNING)
    L.append("## Summary")
    L.append("")
    L.append(f"- Total VIOLATIONs in check.log: **{total_violations}**")
    L.append(f"- In-scope (driver inside `{module_name}`): **{len(in_scope)}**")
    L.append(f"- Cross-module (driver outside but module name suggests `{module_name}` loads): **{len(cross_module)}**")
    L.append(f"- Tristate-bus mismatches: **{len(bus_mismatch)}**")
    L.append(f"- Boundary WARNINGs touching `{module_name}`: **{len(boundary)}**")
    L.append(f"- Over-buffered INFOs in scope: **{len(overbuf)}**")
    L.append("")

    if in_scope:
        cnt = Counter(v.driver_ref for v in in_scope)
        L.append("### In-scope driver-class breakdown")
        L.append("")
        L.append("| Driver cell | Count | Default strategy |")
        L.append("|---|---|---|")
        for ref, c in cnt.most_common():
            cls = classify_driver(ref)
            strat = {
                "SEQ":  "register duplication (0 ns)",
                "COMB": "gate replication (0 ns) or buffer (tier delay)",
                "INV":  "swap inv1$ for bufferHInv (0 ns)",
                "BUFFER": "downsize / no action",
                "OTHER": "buffer (tier delay)",
            }[cls]
            L.append(f"| `{ref}` | {c} | {strat} |")
        L.append("")

    L.append("---")
    L.append("")
    L.append(f"## In-scope violations ({len(in_scope)})")
    L.append("")
    if not in_scope:
        L.append("_None._")
        L.append("")
    for n, v in enumerate(in_scope, 1):
        L.extend(render_entry(n, v, cfg))

    if cross_module:
        L.append("---")
        L.append("")
        L.append(f"## Cross-module violations affecting `{module_name}` ({len(cross_module)})")
        L.append("")
        L.append("Driver lives outside the requested module but the driver-side module name suggests "
                 f"loads in `{module_name}`. Recommended fix is normally on the driver side; "
                 f"alternatively, re-buffer at the `{module_name}` input port.")
        L.append("")
        for n, v in enumerate(cross_module, 1):
            L.extend(render_entry(n, v, cfg, brief=True))

    if boundary:
        L.append("---")
        L.append("")
        L.append(f"## Boundary WARNINGs touching `{module_name}` ({len(boundary)})")
        L.append("")
        L.append("Driver or some loads are external to the analyzed scope. Buffer rule could not "
                 "be applied; verify buffering at the parent module.")
        L.append("")
        for v in boundary:
            chains = " | ".join(_chain_str(p) for p in v.driver_paths) if v.driver_paths else "?"
            L.append(f"- `{v.wire}` (fanout={v.fanout}, internal={v.n_internal}, output_ports={v.n_outputs}) -- driver: {chains}")
        L.append("")

    if bus_mismatch:
        L.append("---")
        L.append("")
        L.append(f"## Tristate-bus driver mismatch ({len(bus_mismatch)})")
        L.append("")
        L.append("Listed bus nets have non-tristate drivers on a bus that already includes "
                 "tristate_bus_driver(s). Convert these drivers to `tristate_bus_driver*$`.")
        L.append("")
        for v in bus_mismatch:
            chains = " | ".join(_chain_str(p) for p in v.driver_paths) if v.driver_paths else "?"
            L.append(f"- `{v.wire}` -- bad driver: {chains}")
        L.append("")

    if overbuf:
        L.append("---")
        L.append("")
        L.append(f"## Over-buffered INFOs ({len(overbuf)})")
        L.append("")
        L.append("Buffer rule satisfied with stronger drive than required; valid but wasteful. "
                 "Optional cleanup.")
        L.append("")
        for v in overbuf:
            L.append(f"- `{v.wire}` (fanout={v.fanout}) driven by `{v.driver_ref}`")
        L.append("")

    return "\n".join(L)


def _chain_str(path: List[HierarchyNode]) -> str:
    parts = []
    for n in path:
        if n.instance == "(top)":
            parts.append(f"({n.module})")
        else:
            parts.append(f"{n.instance}({n.module})")
    return " → ".join(parts)


def render_entry(n: int, v: Violation, cfg: dict, brief: bool = False) -> List[str]:
    L: List[str] = []
    chain = _chain_str(v.driver_paths[0]) if v.driver_paths else "?"
    L.append(f"### {n}. `{v.wire}` (fanout={v.fanout}) — driven by `{v.driver_ref}`")
    L.append("")
    L.append(f"- **Driver path**: {chain}")
    if v.expected:
        L.append(f"- **Required tier**: `{' / '.join(v.expected)}`")
    if brief:
        L.append("")
        return L

    opts = make_recommendations(v, cfg)
    if not opts:
        L.append("")
        L.append("_No recommendation: fanout below threshold or driver class unknown._")
        L.append("")
        return L

    L.append("")
    L.append("| # | Option | Added delay | Action |")
    L.append("|---|---|---|---|")
    for i, r in enumerate(opts):
        marker = "**✅ recommended**" if i == 0 else f"alt {i}"
        L.append(f"| {marker} | {r.label} | {r.delay_ns:.2f} ns | {r.description} |")
    L.append("")
    return L


# ----------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------
def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--check-log", required=True, type=Path,
                    help="Path to Design Vision check.log")
    ap.add_argument("--module", required=True,
                    choices=list(MODULE_CONFIG.keys()) + ["all"],
                    help="Module of interest")
    ap.add_argument("--output", required=True, type=Path,
                    help="Output report path (markdown). For --module all, this is "
                         "treated as a directory and one report per module is written.")
    args = ap.parse_args()

    if not args.check_log.exists():
        ap.error(f"check-log not found: {args.check_log}")

    print(f"Parsing {args.check_log} ...")
    violations = parse_check_log(args.check_log)
    print(f"  parsed {len(violations)} entries")

    if args.module == "all":
        out_dir = args.output
        out_dir.mkdir(parents=True, exist_ok=True)
        for mod_name, cfg in MODULE_CONFIG.items():
            text = render_report(violations, cfg, mod_name)
            outpath = out_dir / f"{mod_name}_fanout_plan.md"
            outpath.write_text(text)
            print(f"  wrote {outpath}")
    else:
        cfg = MODULE_CONFIG[args.module]
        text = render_report(violations, cfg, args.module)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(text)
        print(f"  wrote {args.output}")


if __name__ == "__main__":
    main()
