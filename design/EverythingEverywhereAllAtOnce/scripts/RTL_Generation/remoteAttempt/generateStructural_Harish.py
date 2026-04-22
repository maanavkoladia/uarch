"""
run_gen_parallel.py  <config.json>  [--dry-run] [--jobs N]

Parallel generator runner with:
- Ordered logs per job
- Progress bar (tqdm if available, fallback otherwise)
- Per-job timing summary

Example:
    python run_gen_parallel.py ./config/gen.conf.json --jobs 8
"""

import sys
import os
import json
import subprocess
import time
from concurrent.futures import ThreadPoolExecutor, as_completed

# ──────────────────────────────────────────────────────────────────────────────
# Optional tqdm (graceful fallback)
# ──────────────────────────────────────────────────────────────────────────────

try:
    from tqdm import tqdm
except ImportError:
    def tqdm(iterable, total=None, desc=None):
        count = 0
        total = total or "?"
        print(f"{desc or 'Progress'}...")
        for item in iterable:
            count += 1
            print(f"[{count}/{total}] done")
            yield item

# ──────────────────────────────────────────────────────────────────────────────
# Config
# ──────────────────────────────────────────────────────────────────────────────

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

# ──────────────────────────────────────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────────────────────────────────────

def resolve(rel_path: str) -> str:
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

    return enabled[0]


def ensure_dir(path: str):
    parent = os.path.dirname(path)
    if parent and not os.path.exists(parent):
        os.makedirs(parent, exist_ok=True)

# ──────────────────────────────────────────────────────────────────────────────
# Worker
# ──────────────────────────────────────────────────────────────────────────────

def process_entry(name, entry, script_paths, dry_run):
    start_time = time.perf_counter()

    logs = []
    status = "skipped"

    def log(msg):
        logs.append(msg)

    log(f"{'─'*60}")
    log(f"Entry: {name}")

    flag = normalise_flag(entry)
    if flag is None:
        log("  [SKIP] No run flag set to true.")
        elapsed = time.perf_counter() - start_time
        log(f"  [TIME] {elapsed:.2f}s")
        return name, status, logs, elapsed

    script_label = SCRIPT_KEY_MAP[flag]
    script_path = script_paths.get(script_label)

    if not script_path or not os.path.isfile(script_path):
        log(f"  [ERROR] Script not found: {script_path}")
        elapsed = time.perf_counter() - start_time
        log(f"  [TIME] {elapsed:.2f}s")
        return name, "failed", logs, elapsed

    csv_abs = resolve(entry.get("csv", ""))
    out_abs = resolve(entry.get("outputFilePath", ""))

    if not entry.get("csv"):
        log("  [ERROR] Missing 'csv' field.")
        elapsed = time.perf_counter() - start_time
        log(f"  [TIME] {elapsed:.2f}s")
        return name, "failed", logs, elapsed

    if not entry.get("outputFilePath"):
        log("  [ERROR] Missing 'outputFilePath' field.")
        elapsed = time.perf_counter() - start_time
        log(f"  [TIME] {elapsed:.2f}s")
        return name, "failed", logs, elapsed

    if not os.path.isfile(csv_abs):
        log(f"  [ERROR] CSV not found: {csv_abs}")
        elapsed = time.perf_counter() - start_time
        log(f"  [TIME] {elapsed:.2f}s")
        return name, "failed", logs, elapsed

    log(f"  Script : {script_label}  →  {os.path.basename(script_path)}")
    log(f"  CSV    : {csv_abs}")
    log(f"  Output : {out_abs}")

    cmd = [sys.executable, script_path, csv_abs, out_abs]
    log(f"  CMD    : {' '.join(cmd)}")

    if dry_run:
        log("  [DRY-RUN] Would execute the above command.")
        elapsed = time.perf_counter() - start_time
        log(f"  [TIME] {elapsed:.2f}s")
        return name, "passed", logs, elapsed

    ensure_dir(out_abs)

    result = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    if result.stdout:
        for line in result.stdout.strip().splitlines():
            log(f"    {line}")

    if result.stderr:
        for line in result.stderr.strip().splitlines():
            log(f"    [STDERR] {line}")

    if result.returncode == 0:
        log(f"  [OK] Generated: {out_abs}")
        status = "passed"
    else:
        log(f"  [FAIL] Exit code {result.returncode}")
        status = "failed"

    elapsed = time.perf_counter() - start_time
    log(f"  [TIME] {elapsed:.2f}s")

    return name, status, logs, elapsed

# ──────────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────────

def main():
    dry_run = "--dry-run" in sys.argv
    args = [a for a in sys.argv[1:] if not a.startswith("--")]

    if len(args) != 1:
        print("Usage: python3 run_gen_parallel.py <config.json> [--dry-run] [--jobs N]")
        sys.exit(1)

    config_path = args[0]

    if not os.path.isfile(config_path):
        sys.exit(f"ERROR: Config file not found: {config_path}")

    max_workers = os.cpu_count() or 4
    if "--jobs" in sys.argv:
        try:
            idx = sys.argv.index("--jobs")
            max_workers = int(sys.argv[idx + 1])
        except:
            pass

    print(f"Project root : {os.getcwd()}")
    print(f"Config       : {config_path}")
    print(f"Workers      : {max_workers}")
    print()

    with open(config_path) as fh:
        config = json.load(fh)

    script_paths = {
        label: resolve(rel)
        for label, rel in config.get("script path", {}).items()
    }

    print("Script paths:")
    for label, path in script_paths.items():
        status = "✓" if os.path.isfile(path) else "✗ NOT FOUND"
        print(f"  [{status}] {label}: {path}")
    print()

    gen_files = config.get("genFiles", {})
    if not gen_files:
        print("No entries in 'genFiles'. Nothing to do.")
        return

    results = {"passed": 0, "failed": 0, "skipped": 0}
    timings = []

    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = [
            executor.submit(process_entry, name, entry, script_paths, dry_run)
            for name, entry in gen_files.items()
        ]

        for future in tqdm(as_completed(futures), total=len(futures), desc="Running"):
            name, status, logs, elapsed = future.result()

            print("\n".join(logs))

            results[status] += 1
            timings.append((name, elapsed, status))

    # ── Timing summary ────────────────────────────────────────────────────────

    print(f"\n{'─'*60}")
    print("Timing Summary (slowest first):")

    for name, elapsed, status in sorted(timings, key=lambda x: x[1], reverse=True):
        print(f"  {elapsed:8.2f}s  [{status.upper():7}]  {name}")

    # ── Final summary ─────────────────────────────────────────────────────────

    total = len(gen_files)

    print(f"\n{'═'*60}")
    print(
        f"Done.  {total} entries  →  "
        f"{results['passed']} passed  |  "
        f"{results['failed']} failed  |  "
        f"{results['skipped']} skipped"
    )

    if results["failed"]:
        sys.exit(1)


if __name__ == "__main__":
    main()