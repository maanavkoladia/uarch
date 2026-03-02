"""
run_gen.py  <config.json>  [--dry-run]

All paths in the JSON are relative to the project root (CWD).
Invoke from your project root, e.g.:
    python ./scripts/generateStructural.py ./config/gen.conf.json
"""

import sys
import os
import json
import subprocess

SCRIPT_PRIORITY = [
    "run FSM SOP Gen",
    "run Combinational SOP Gen",
    "run FSM LUT Gen",
    "run Combinational LUT Gen",
]

SCRIPT_KEY_MAP = {
    "run Combinational SOP Gen": "Combinational SOP GEN",
    "run FSM SOP Gen":           "FSM SOP GEN",
    "run Combinational LUT Gen": "Combinational LUT GEN",
    "run FSM LUT Gen":           "FSM LUT GEN",
}

def resolve(rel_path: str) -> str:
    """Resolve a path relative to CWD (project root). Abs paths pass through."""
    if os.path.isabs(rel_path):
        return rel_path
    return os.path.normpath(os.path.join(os.getcwd(), rel_path))

def normalise_flag(entry: dict):
    lower_map = {k.lower(): k for k in entry.keys()}
    enabled = []
    for canonical in SCRIPT_PRIORITY:
        key = lower_map.get(canonical.lower())
        if key and str(entry[key]).strip().lower() == "true":
            enabled.append(canonical)
    if not enabled:
        return None
    if len(enabled) > 1:
        print(f"  [WARN] Multiple run flags true: {enabled}. Using '{enabled[0]}'.")
    return enabled[0]

def ensure_dir(path: str):
    parent = os.path.dirname(path)
    if parent and not os.path.exists(parent):
        os.makedirs(parent, exist_ok=True)
        print(f"  [INFO] Created directory: {parent}")

def main():
    dry_run = "--dry-run" in sys.argv
    args    = [a for a in sys.argv[1:] if not a.startswith("--")]

    if len(args) != 1:
        print("Usage: python3 run_gen.py <config.json> [--dry-run]")
        sys.exit(1)

    config_path = args[0]
    if not os.path.isfile(config_path):
        sys.exit(f"ERROR: Config file not found: {config_path}")

    print(f"Project root : {os.getcwd()}")
    print(f"Config       : {config_path}")
    print()

    with open(config_path) as fh:
        try:
            config = json.load(fh)
        except json.JSONDecodeError as e:
            sys.exit(f"ERROR: Invalid JSON: {e}")

    # ── Script paths (all relative to project root / CWD) ───────────────────
    script_paths = {
        label: resolve(rel)
        for label, rel in config.get("script path", {}).items()
    }

    print("Script paths:")
    for label, path in script_paths.items():
        status = "✓" if os.path.isfile(path) else "✗ NOT FOUND"
        print(f"  [{status}] {label}: {path}")
    print()

    # ── genFiles ─────────────────────────────────────────────────────────────
    gen_files = config.get("genFiles", {})
    if not gen_files:
        print("No entries in 'genFiles'. Nothing to do.")
        sys.exit(0)

    total = passed = failed = skipped = 0

    for name, entry in gen_files.items():
        total += 1
        print(f"{'─'*60}")
        print(f"Entry: {name}")

        flag = normalise_flag(entry)
        if flag is None:
            print("  [SKIP] No run flag set to true.")
            skipped += 1
            continue

        script_label = SCRIPT_KEY_MAP[flag]
        script_path  = script_paths.get(script_label)

        if not script_path or not os.path.isfile(script_path):
            print(f"  [ERROR] Script not found: {script_path}")
            failed += 1
            continue

        csv_abs = resolve(entry.get("csv", ""))
        out_abs = resolve(entry.get("outputFilePath", ""))

        if not entry.get("csv"):
            print("  [ERROR] Missing 'csv' field.")
            failed += 1
            continue
        if not entry.get("outputFilePath"):
            print("  [ERROR] Missing 'outputFilePath' field.")
            failed += 1
            continue
        if not os.path.isfile(csv_abs):
            print(f"  [ERROR] CSV not found: {csv_abs}")
            failed += 1
            continue

        print(f"  Script : {script_label}  →  {os.path.basename(script_path)}")
        print(f"  CSV    : {csv_abs}")
        print(f"  Output : {out_abs}")

        cmd = [sys.executable, script_path, csv_abs, out_abs]
        print(f"  CMD    : {' '.join(cmd)}")

        if dry_run:
            print("  [DRY-RUN] Would execute the above command.")
            passed += 1
            continue

        ensure_dir(out_abs)
        result = subprocess.run(cmd, capture_output=True, text=True)

        for line in result.stdout.strip().splitlines():
            print(f"    {line}")
        for line in result.stderr.strip().splitlines():
            print(f"    [STDERR] {line}")

        if result.returncode == 0:
            print(f"  [OK] Generated: {out_abs}")
            passed += 1
        else:
            print(f"  [FAIL] Exit code {result.returncode}")
            failed += 1

    print(f"\n{'═'*60}")
    print(f"Done.  {total} entries  →  {passed} passed  |  {failed} failed  |  {skipped} skipped")
    if failed:
        sys.exit(1)

if __name__ == "__main__":
    main()
