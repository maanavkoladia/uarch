#!/usr/bin/env python3
"""
startup_gen_master.py
---------------------
Master orchestrator for RTL startup generation.

Usage:
    python startup_gen_master.py [-s] <paths_json> <master_conf_json>

Options:
    -s    Short mode:
          Only runs Mem_Compile_Path for the Memory step (skips hex + readmem)

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
# ANSI colour helpers
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
# Step registry (IDT REMOVED)
# ---------------------------------------------------------------------------
STEPS = [
    {
        "label": "Memory Init",
        "conf_key": "mem_conf_path",
        "script_keys": [
            "Mem_Compile_Path",
            "Mem_Gen_Hex_Path",
            "Mem_Gen_Readmem_Path",
        ],
    },
    {
        "label": "ICache Startup",
        "conf_key": "icache_conf_path",
        "script_keys": ["ICache_Startup_Path"],
    },
    {
        "label": "DCache Startup",
        "conf_key": "dcache_conf_path",
        "script_keys": ["DCache_Startup_Path"],
    },
    {
        "label": "TLB Startup",
        "conf_key": "TLB_conf_path",
        "script_keys": ["TLB_Startup_Path"],
    },
    {
        "label": "Disk Startup",
        "conf_key": "disk_conf_path",
        "script_keys": ["Disk_Startup_Path"],
    },
    {
        "label": "Core Regs Startup",
        "conf_key": "core_regs_conf_path",
        "script_keys": ["Core_Regs_Startup_Path"],
    },
]

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _make_record(label, script_key, status, detail=""):
    return {
        "label": label,
        "script_key": script_key,
        "status": status,
        "detail": detail,
    }


def _run_script(script_path: Path, sub_conf_abs: str):
    cmd = [sys.executable, str(script_path), sub_conf_abs]
    print(f"      {CYAN('RUN')}  {' '.join(cmd)}")

    try:
        proc = subprocess.run(cmd, text=True)
        if proc.returncode == 0:
            return PASS, ""
        return FAIL, f"exit code {proc.returncode}"
    except Exception as exc:
        return FAIL, str(exc)


def _load_json_arg(raw: str, label: str):
    raw = raw.strip()

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

    try:
        return json.loads(raw)
    except json.JSONDecodeError as exc:
        print(RED(f"[ERROR] {label}: failed to parse JSON string: {exc}"))
        sys.exit(2)

# ---------------------------------------------------------------------------
# Orchestration
# ---------------------------------------------------------------------------

def orchestrate(paths, master_conf, work_dir, short_mode):
    records = []

    for step in STEPS:
        label = step["label"]
        conf_key = step["conf_key"]
        script_keys = step["script_keys"]

        # Short mode override (ONLY affects Memory)
        if short_mode and label == "Memory Init":
            script_keys = ["Mem_Compile_Path", "Mem_Gen_Hex_Path",]

        # SKIP
        sub_conf_rel = master_conf.get(conf_key)
        if sub_conf_rel is None:
            print(f"\n{BOLD(label)}: {YELLOW('SKIP')} — '{conf_key}' not in master conf")
            records.append(_make_record(label, "", SKIP))
            continue

        sub_conf_abs = str((work_dir / sub_conf_rel).resolve())
        print(f"\n{BOLD(label)} [{conf_key}]")
        print(f"    sub-conf → {sub_conf_abs}")

        for sk in script_keys:

            # Missing key
            if sk not in paths:
                detail = f"'{sk}' not in paths JSON"
                print(f"    {RED('MISS')}  {sk} — {detail}")
                records.append(_make_record(label, sk, MISS, detail))
                break

            script_path = Path(paths[sk])

            # Missing file
            if not script_path.exists():
                detail = f"file not found: {script_path}"
                print(f"    {RED('MISS')}  {sk} — {detail}")
                records.append(_make_record(label, sk, MISS, detail))
                break

            # Run
            status, detail = _run_script(script_path, sub_conf_abs)

            if status == PASS:
                print(f"    {GREEN('PASS')}  {sk}")
            else:
                print(f"    {RED('FAIL')}  {sk} — {detail}")

            records.append(_make_record(label, sk, status, detail))

            if status != PASS:
                break

    return records

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

def print_summary(records):
    print("\n" + "═" * 70)
    print(BOLD("  SUMMARY"))
    print("═" * 70)

    any_bad = False
    prev_label = None

    for r in records:
        if r["label"] != prev_label:
            print(f"\n  {BOLD(r['label'])}")
            prev_label = r["label"]

        status = r["status"]

        if status == PASS:
            tag = GREEN("[PASS]")
        elif status == SKIP:
            tag = YELLOW("[SKIP]")
        else:
            tag = RED(f"[{status}]")
            any_bad = True

        line = f"    {tag}"
        if r["script_key"]:
            line += f"  {DIM(r['script_key'])}"
        print(line)

        if r["detail"]:
            print(f"        {YELLOW(r['detail'])}")

    print("\n" + "═" * 70)
    print(GREEN("ALL PASSED") if not any_bad else RED("FAILURES DETECTED"))
    print("═" * 70 + "\n")

    return not any_bad

# ---------------------------------------------------------------------------
# Entry
# ---------------------------------------------------------------------------

def main():
    args = sys.argv[1:]

    short_mode = False
    if args and args[0] == "-s":
        short_mode = True
        args = args[1:]

    if len(args) != 2:
        print(f"Usage: {sys.argv[0]} [-s] <paths_json> <master_conf_json>")
        return 2

    paths = _load_json_arg(args[0], "paths JSON")
    conf_path = Path(args[1]).resolve()
    master_conf = _load_json_arg(str(conf_path), "master conf")

    master_conf = {k: v for k, v in master_conf.items() if not k.startswith("_")}

    print(BOLD("\n╔══ RTL Startup Gen Master ═════════════════════╗"))
    print(f"  mode        : {'SHORT (-s)' if short_mode else 'FULL'}")
    print(f"  master conf : {conf_path}")
    print(f"  script keys : {list(paths.keys())}")
    print(BOLD("╚═══════════════════════════════════════════════╝"))

    records = orchestrate(paths, master_conf, conf_path.parent, short_mode)
    ok = print_summary(records)

    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
