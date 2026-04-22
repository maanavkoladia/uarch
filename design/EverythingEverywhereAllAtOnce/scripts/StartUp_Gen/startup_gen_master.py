#!/usr/bin/env python3
"""
startup_gen_master.py
---------------------
Master orchestrator for RTL startup generation.

Arguments:
    argv[1]  – JSON string (or path to a .json file) containing resolved
               script paths, as emitted by MASTER_SCRIPT_GEN_SCRIPTS_PATH_JSON
               in the Makefile.  Example:
                 {
                   "Master_Startup_Script":    "/repo/scripts/.../startup_gen_master.py",
                   "Mem_Compile_Path":         "/repo/scripts/.../Mem/compile.py",
                   "Mem_Gen_Hex_Path":         "/repo/scripts/.../Mem/genHexMem.py",
                   "Mem_Gen_Readmem_Path":     "/repo/scripts/.../Mem/genReadMemFile.py",
                   "ICache_Startup_Path":      "/repo/scripts/.../ICache/ICache_Startup_Gen.py",
                   "DCache_Startup_Path":      "/repo/scripts/.../DCache/DCache_StartUp_Gen.py",
                   "TLB_Startup_Path":         "/repo/scripts/.../TLB/TLB_StartUp_Gen.py",
                   "Disk_Startup_Path":        "/repo/scripts/.../Disk/Disk_StartUp_Gen.py",
                   "Core_Regs_Startup_Path":   "/repo/scripts/.../CoreRegs/CoreRegs_StartUp_Gen.py"
                 }

    argv[2]  – Path to mastergen.conf.json.  Example:
                 {
                   "mem_conf_path":       "mem.conf.json",
                   "icache_conf_path":    "icache.conf.json",
                   "dcache_conf_path":    "dcache.conf.json",
                   "TLB_conf_path":       "TLB.conf.json",
                   "disk_conf_path":      "disk.conf.json",
                   "core_regs_conf_path": "CoreRegs.conf.json",
                   "idt_conf_path":       "IDT.conf.json"
                 }
               Keys that are absent → the corresponding step is SKIPPED.
               All sub-conf paths are resolved relative to mastergen.conf.json.

Exit codes:
    0  – all active steps passed
    1  – one or more steps FAILED or had a MISSING_SCRIPT
    2  – bad arguments / unreadable files
"""

import json
import subprocess
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# ANSI colour helpers (auto-disabled when stdout is not a tty)
# ---------------------------------------------------------------------------
_USE_COLOUR = sys.stdout.isatty()

def _c(code: str, text: str) -> str:
    return f"\033[{code}m{text}\033[0m" if _USE_COLOUR else text

GREEN  = lambda t: _c("32;1", t)
RED    = lambda t: _c("31;1", t)
YELLOW = lambda t: _c("33;1", t)
CYAN   = lambda t: _c("36;1", t)
BOLD   = lambda t: _c("1",    t)
DIM    = lambda t: _c("2",    t)

# ---------------------------------------------------------------------------
# Status tokens
# ---------------------------------------------------------------------------
PASS = "PASS"
FAIL = "FAIL"
SKIP = "SKIP"
MISS = "MISSING_SCRIPT"

# ---------------------------------------------------------------------------
# Step registry
#
# Defines the ordered list of steps the master script knows about.
# Each step maps:
#   conf_key    – key looked up in mastergen.conf.json to get the sub-conf path.
#                 None means the step has no per-step conf (not used yet).
#   script_keys – ordered list of keys into the paths JSON (argv[1]).
#                 Multiple keys = chained execution; first failure aborts chain.
#                 All entries in a chain receive the SAME sub-conf path.
# ---------------------------------------------------------------------------
STEPS: list[dict] = [
    {
        "label":       "Memory Init",
        "conf_key":    "mem_conf_path",
        "script_keys": [
            "Mem_Compile_Path",
            "Mem_Gen_Hex_Path",
            "Mem_Gen_Readmem_Path",
        ],
    },
    {
        "label":       "ICache Startup",
        "conf_key":    "icache_conf_path",
        "script_keys": ["ICache_Startup_Path"],
    },
    {
        "label":       "DCache Startup",
        "conf_key":    "dcache_conf_path",
        "script_keys": ["DCache_Startup_Path"],
    },
    {
        "label":       "TLB Startup",
        "conf_key":    "TLB_conf_path",
        "script_keys": ["TLB_Startup_Path"],
    },
    {
        "label":       "Disk Startup",
        "conf_key":    "disk_conf_path",
        "script_keys": ["Disk_Startup_Path"],
    },
    {
        "label":       "Core Regs Startup",
        "conf_key":    "core_regs_conf_path",
        "script_keys": ["Core_Regs_Startup_Path"],
    },
    # IDT not yet in the paths JSON — will hit MISSING_SCRIPT gracefully
    # when "IDT_Startup_Path" is added to the Makefile JSON and a script exists.
    {
        "label":       "IDT Startup",
        "conf_key":    "idt_conf_path",
        "script_keys": ["IDT_Startup_Path"],
    },
]

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _make_record(label: str, script_key: str, status: str, detail: str = "") -> dict:
    return {
        "label":      label,
        "script_key": script_key,
        "status":     status,
        "detail":     detail,
    }


def _run_script(script_path: Path, sub_conf_abs: str) -> tuple[str, str]:
    """
    Execute: python3 <script_path> <sub_conf_abs>
    Output streams live to the terminal.
    Returns (PASS|FAIL, detail).
    """
    cmd = [sys.executable, str(script_path), sub_conf_abs]
    print(f"      {CYAN('RUN')}  {' '.join(cmd)}")
    try:
        proc = subprocess.run(cmd, text=True)
        if proc.returncode == 0:
            return PASS, ""
        return FAIL, f"exit code {proc.returncode}"
    except Exception as exc:
        return FAIL, str(exc)

# ---------------------------------------------------------------------------
# Load helpers
# ---------------------------------------------------------------------------

def _load_json_arg(raw: str, label: str) -> dict:
    """
    Accept either a raw JSON string or a path to a .json file.
    Returns the parsed dict, or exits with code 2 on failure.
    """
    raw = raw.strip()
    # If it looks like a file path, try reading it first
    if raw.endswith(".json") or ("/" in raw and not raw.startswith("{")):
        p = Path(raw)
        if not p.exists():
            print(RED(f"[ERROR] {label}: file not found: {p}"))
            sys.exit(2)
        try:
            return json.loads(p.read_text())
        except json.JSONDecodeError as exc:
            print(RED(f"[ERROR] {label}: failed to parse JSON file {p}: {exc}"))
            sys.exit(2)
    # Otherwise treat as inline JSON string
    try:
        return json.loads(raw)
    except json.JSONDecodeError as exc:
        print(RED(f"[ERROR] {label}: failed to parse JSON string: {exc}"))
        sys.exit(2)

# ---------------------------------------------------------------------------
# Orchestration
# ---------------------------------------------------------------------------

def orchestrate(paths: dict, master_conf: dict, work_dir: Path) -> list[dict]:
    """
    Walk STEPS in order.

    Per step:
      SKIP           – conf_key absent from master_conf
      MISSING_SCRIPT – script_key absent from paths JSON, or .py not on disk
      FAIL           – script exited non-zero
      PASS           – script(s) succeeded

    Chains (mem): first MISS or FAIL aborts remaining steps in that chain,
    then orchestration continues with the next step.
    """
    records: list[dict] = []

    for step in STEPS:
        label       = step["label"]
        conf_key    = step["conf_key"]
        script_keys = step["script_keys"]
        is_chain    = len(script_keys) > 1

        # ── SKIP ───────────────────────────────────────────────────────────
        sub_conf_rel = master_conf.get(conf_key)
        if sub_conf_rel is None:
            print(f"\n{BOLD(label)}: {YELLOW('SKIP')} — '{conf_key}' not in master conf")
            records.append(_make_record(label, "", SKIP, f"'{conf_key}' absent from master conf"))
            continue

        sub_conf_abs = str((work_dir / sub_conf_rel).resolve())
        print(f"\n{BOLD(label)}  [{conf_key}]")
        print(f"    sub-conf → {sub_conf_abs}")

        chain_ok = True

        for sk in script_keys:

            # ── MISSING: key not in paths JSON ─────────────────────────────
            if sk not in paths:
                detail = f"'{sk}' not present in paths JSON"
                print(f"    {RED('MISS')}  {sk}  —  {detail}")
                records.append(_make_record(label, sk, MISS, detail))
                chain_ok = False
                break

            script_path = Path(paths[sk])

            # ── MISSING: file not on disk ───────────────────────────────────
            if not script_path.exists():
                detail = f"file not found: {script_path}"
                print(f"    {RED('MISS')}  {sk}  —  {detail}")
                records.append(_make_record(label, sk, MISS, detail))
                chain_ok = False
                break

            # ── RUN ────────────────────────────────────────────────────────
            status, detail = _run_script(script_path, sub_conf_abs)

            if status == PASS:
                print(f"    {GREEN('PASS')}  {sk}")
            else:
                print(f"    {RED('FAIL')}  {sk}  —  {detail}")

            records.append(_make_record(label, sk, status, detail))

            if status == FAIL:
                chain_ok = False
                break

        if is_chain:
            tag = GREEN("CHAIN PASS") if chain_ok else RED("CHAIN FAIL")
            print(f"  └─ {tag}")

    return records

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

def print_summary(records: list[dict]) -> bool:
    """Print the results table. Returns True if no FAIL or MISS."""
    print("\n" + "═" * 72)
    print(BOLD("  STARTUP GEN  —  SUMMARY"))
    print("═" * 72)

    any_bad = False
    prev_label = None

    for r in records:
        status     = r["status"]
        label      = r["label"]
        script_key = r["script_key"]
        detail     = r["detail"]

        # Group header when a step has multiple records (chain)
        if label != prev_label:
            print(f"\n  {BOLD(label)}")
            prev_label = label

        if status == PASS:
            tag = GREEN(f"[{PASS}]     ")
        elif status == SKIP:
            tag = YELLOW(f"[{SKIP}]     ")
        elif status == FAIL:
            tag = RED(f"[{FAIL}]     ")
            any_bad = True
        elif status == MISS:
            tag = RED("[MISSING]")
            any_bad = True
        else:
            tag = f"[{status}]"

        line = f"    {tag}"
        if script_key:
            line += f"  {DIM(script_key)}"
        print(line)
        if detail:
            print(f"             {YELLOW(detail)}")

    print("\n" + "═" * 72)
    overall = GREEN("ALL STEPS PASSED") if not any_bad else RED("ONE OR MORE STEPS FAILED / MISSING")
    print(f"  {overall}")
    print("═" * 72 + "\n")

    return not any_bad

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main() -> int:
    if len(sys.argv) != 3:
        print(
            f"Usage: {sys.argv[0]} <paths_json> <master_conf_json>\n"
            f"  paths_json       – inline JSON string or path to .json file\n"
            f"                     containing resolved script paths from Make\n"
            f"  master_conf_json – path to mastergen.conf.json"
        )
        return 2

    paths_raw    = sys.argv[1]
    conf_path    = Path(sys.argv[2]).resolve()

    # ── Parse paths JSON ─────────────────────────────────────────────────
    paths = _load_json_arg(paths_raw, "paths JSON (argv[1])")

    # ── Parse master conf ─────────────────────────────────────────────────
    master_conf = _load_json_arg(str(conf_path), "master conf (argv[2])")
    # Strip internal comment keys
    master_conf = {k: v for k, v in master_conf.items() if not k.startswith("_")}

    # ── Banner ────────────────────────────────────────────────────────────
    print(BOLD("\n╔══ RTL Startup Gen Master ══════════════════════════════════╗"))
    print(f"  master conf : {conf_path}")
    print(f"  script keys : {list(paths.keys())}")
    active   = [s["label"] for s in STEPS if s["conf_key"] in master_conf]
    inactive = [s["label"] for s in STEPS if s["conf_key"] not in master_conf]
    print(f"  will run    : {active   or '(none)'}")
    print(f"  will skip   : {inactive or '(none)'}")
    print(BOLD("╚════════════════════════════════════════════════════════════╝"))

    # ── Orchestrate ──────────────────────────────────────────────────────
    work_dir = conf_path.parent
    records  = orchestrate(paths, master_conf, work_dir)

    # ── Summary ──────────────────────────────────────────────────────────
    all_ok = print_summary(records)
    return 0 if all_ok else 1


if __name__ == "__main__":
    sys.exit(main())
