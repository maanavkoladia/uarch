"""
csv2rtl.py  <input.csv>  <output.sv>

Pipeline:
  1. Parse & validate CSV (columns ending _i = inputs, _o = outputs)
  2. Write  <stem>.pla
  3. Minimise with Quine-McCluskey   →  <stem>_minimised.pla
  4. Write coverage report           →  <stem>_coverage_report.txt
       * Lists every input vector with no row defined in the CSV
       * Lists every ON-set minterm that could not be covered (should be none)
       * Pipeline does NOT abort; report is informational only.
  5. Generate structural Verilog     →  <output.sv>

No external dependencies required.
"""

import sys, os, csv, itertools, math
from collections import defaultdict

BANNER = "=" * 72

def log(msg=""):
    print(msg)

def die(msg):
    print(f"\nFATAL: {msg}", file=sys.stderr)
    sys.exit(1)

def stage(n, title):
    log()
    log(f"{'─'*72}")
    log(f"  Stage {n}: {title}")
    log(f"{'─'*72}")

# ─────────────────────────────────────────────────────────────────────────────
# 0.  CLI & path setup
# ─────────────────────────────────────────────────────────────────────────────
if len(sys.argv) != 3:
    die("Usage: python3 csv2rtl.py <input.csv> <output.sv>")

csv_path = sys.argv[1]
sv_path  = sys.argv[2]

if not os.path.isfile(csv_path):
    die(f"Input file not found: {csv_path}")

base = os.path.splitext(csv_path)[0]
stem = os.path.splitext(os.path.basename(csv_path))[0]

p_pla           = base + ".pla"
p_minimised_pla = base + "_minimised.pla"
p_coverage      = base + "_coverage_report.txt"

log(BANNER)
log(f"  csv2rtl pipeline -- {stem}")
log(BANNER)
log(f"  Input CSV : {csv_path}")
log(f"  Output SV : {sv_path}")

# ─────────────────────────────────────────────────────────────────────────────
# Stage 1: Parse & validate CSV
# ─────────────────────────────────────────────────────────────────────────────
stage(1, "CSV parse & structural validation")

with open(csv_path, newline='') as fh:
    reader  = csv.DictReader(fh)
    headers = list(reader.fieldnames or [])
    rows    = list(reader)

if not headers:
    die("CSV has no header row.")
if not rows:
    die("CSV has no data rows.")

inputs  = [h for h in headers if h.endswith('_i')]
outputs = [h for h in headers if h.endswith('_o')]
unknown = [h for h in headers if not h.endswith('_i') and not h.endswith('_o')]

log(f"  Headers   : {headers}")
log(f"  Inputs    : {inputs}")
log(f"  Outputs   : {outputs}")
if unknown:
    log(f"  WARNING -- unrecognised columns (ignored): {unknown}")

errors = []
if not inputs:
    errors.append("No '_i' input columns found.")
if not outputs:
    errors.append("No '_o' output columns found.")

valid_chars = {'0', '1', '-', 'x', 'X'}
for lineno, row in enumerate(rows, start=2):
    for col in inputs + outputs:
        v = row[col].strip()
        if v not in valid_chars:
            errors.append(
                f"Row {lineno} col '{col}': invalid value '{v}' (expected 0/1/X/-)"
            )

if errors:
    log("\n  Structural errors:")
    for e in errors:
        log(f"    ERROR: {e}")
    die("Fix structural errors before proceeding.")

ni = len(inputs)
no = len(outputs)
log(f"\n  {len(rows)} data rows, {ni} input(s), {no} output(s)  OK")

# ─────────────────────────────────────────────────────────────────────────────
# Stage 2: X-expansion & conflict detection
# ─────────────────────────────────────────────────────────────────────────────
stage(2, "X-expansion (don't-care inputs) & conflict detection")

def expand_row(row, in_cols):
    """Expand a single CSV row over all don't-care input positions."""
    dc_positions = [(i, col) for i, col in enumerate(in_cols)
                    if row[col].strip() in ('-', 'x', 'X')]
    if not dc_positions:
        return [dict(row)]
    expanded = []
    for combo in itertools.product('01', repeat=len(dc_positions)):
        new_row = dict(row)
        for val, (_, col) in zip(combo, dc_positions):
            new_row[col] = val
        expanded.append(new_row)
    return expanded

# truth_table : input_str -> output_str   (fully resolved, no don't-cares in inputs)
truth_table  = {}   # key = '01...' string of input bits
conflict_log = []   # human-readable conflict descriptions

for lineno, row in enumerate(rows, start=2):
    for exp in expand_row(row, inputs):
        in_tup  = tuple(exp[c].strip() for c in inputs)
        out_tup = tuple(exp[c].strip() for c in outputs)
        in_str  = ''.join(in_tup)
        out_str = ''.join(out_tup)

        # Normalise output: treat 'x'/'X' as don't-care '-'
        out_str = out_str.replace('x', '-').replace('X', '-')

        if in_str in truth_table:
            existing = truth_table[in_str]
            if existing != out_str:
                conflict_log.append(
                    f"  CONFLICT input={dict(zip(inputs, in_tup))} "
                    f"(CSV row {lineno}):\n"
                    f"    existing output = '{existing}'\n"
                    f"    new      output = '{out_str}'  (keeping existing)"
                )
            # Always keep first-seen entry (deterministic)
        else:
            truth_table[in_str] = out_str

if conflict_log:
    log(f"\n  {len(conflict_log)} conflict(s) detected (first-seen kept):")
    for c in conflict_log:
        log(c)
else:
    log(f"  No conflicts detected  OK")

log(f"  Expanded truth table: {len(truth_table)} fully-specified rows")

# ─────────────────────────────────────────────────────────────────────────────
# Stage 3: Write raw PLA
# ─────────────────────────────────────────────────────────────────────────────
stage(3, "PLA construction")

with open(p_pla, 'w') as f:
    f.write(f"# PLA for: {stem}\n")
    f.write(f".i {ni}\n")
    f.write(f".o {no}\n")
    f.write(f".ilb {' '.join(inputs)}\n")
    f.write(f".ob  {' '.join(outputs)}\n")
    f.write(".type fr\n")
    for in_str, out_str in sorted(truth_table.items()):
        f.write(f"{in_str} {out_str}\n")
    f.write(".e\n")

log(f"  PLA written -> {p_pla}  ({len(truth_table)} minterms)")

# Build per-output ON/DC sets for QM
on_sets = defaultdict(list)   # output_idx -> [input_tuple, ...]
dc_sets = defaultdict(list)

for in_str, out_str in truth_table.items():
    in_tup = tuple(in_str)
    for oi in range(no):
        v = out_str[oi] if oi < len(out_str) else '0'
        if v == '1':
            on_sets[oi].append(in_tup)
        elif v == '-':
            dc_sets[oi].append(in_tup)

# ─────────────────────────────────────────────────────────────────────────────
# Stage 4: Quine-McCluskey minimisation
# ─────────────────────────────────────────────────────────────────────────────
stage(4, "Quine-McCluskey minimisation")

def qm_minimise(on_set, dc_set, n_vars):
    """
    Pure-Python Quine-McCluskey followed by a greedy essential-PI cover.

    Parameters
    ----------
    on_set  : list of tuples of chars ('0'/'1')  — must-cover minterms
    dc_set  : list of tuples of chars ('0'/'1')  — optional don't-cares
    n_vars  : number of input variables

    Returns
    -------
    list of prime-implicant tuples (chars '0', '1', or '-')
    """
    on_cubes  = [tuple(v) for v in on_set]
    all_cubes = list(set(on_cubes) | set(tuple(v) for v in dc_set))

    if not all_cubes:
        return []

    # ── Step 1: iterative cube merging ──────────────────────────────────────
    def try_merge(a, b):
        """Merge two cubes that differ in exactly one non-'-' position."""
        diffs = [i for i in range(n_vars) if a[i] != b[i]]
        if len(diffs) != 1:
            return None
        if a[diffs[0]] == '-' or b[diffs[0]] == '-':
            return None   # already a don't-care in that position — not mergeable
        merged = list(a)
        merged[diffs[0]] = '-'
        return tuple(merged)

    def covers(pi, minterm):
        return all(p == '-' or p == c for p, c in zip(pi, minterm))

    groups = all_cubes
    prime_implicants = set()
    while groups:
        g      = list(set(groups))
        merged = set()
        used   = set()
        for i in range(len(g)):
            for j in range(i + 1, len(g)):
                m = try_merge(g[i], g[j])
                if m is not None:
                    merged.add(m)
                    used.add(i)
                    used.add(j)
        for i, cube in enumerate(g):
            if i not in used:
                prime_implicants.add(cube)
        groups = list(merged)

    if not on_cubes:
        return []

    # ── Step 2: greedy essential-PI cover ────────────────────────────────────
    # Re-sort after *every* pick so the coverage score reflects the
    # shrinking uncovered set (matches fsm2rtl.py behaviour).
    uncovered = list(on_cubes)
    chosen    = []
    remaining = list(prime_implicants)

    while uncovered and remaining:
        # Score: (#minterms newly covered, #don't-cares in PI) — both descending
        remaining.sort(
            key=lambda pi: (
                sum(1 for m in uncovered if covers(pi, m)),
                pi.count('-')
            ),
            reverse=True
        )
        best = remaining.pop(0)
        if any(covers(best, m) for m in uncovered):
            chosen.append(best)
            uncovered = [m for m in uncovered if not covers(best, m)]

    if uncovered:
        log(f"  WARNING: QM cover incomplete — {len(uncovered)} minterm(s) uncovered")

    return chosen

minimised = {}
for oi, out_col in enumerate(outputs):
    on    = on_sets[oi]
    dc    = dc_sets[oi]
    cubes = qm_minimise(on, dc, ni) if on else []
    minimised[out_col] = cubes
    log(f"  {out_col:<24}: {len(on):>4} ON-minterms  ->  {len(cubes):>3} prime implicants")

# Write minimised PLA
cube_out_map = defaultdict(lambda: ['0'] * no)
for oi, out_col in enumerate(outputs):
    for cube in minimised[out_col]:
        cube_out_map[''.join(cube)][oi] = '1'

with open(p_minimised_pla, 'w') as f:
    f.write(f"# Minimised SOP (Quine-McCluskey) for: {stem}\n")
    f.write(f".i {ni}\n")
    f.write(f".o {no}\n")
    f.write(f".ilb {' '.join(inputs)}\n")
    f.write(f".ob  {' '.join(outputs)}\n")
    f.write(".type f\n")
    for in_str, out_list in sorted(cube_out_map.items()):
        f.write(f"{in_str} {''.join(out_list)}\n")
    f.write(".e\n")

log(f"\n  Minimised PLA written -> {p_minimised_pla}  OK")

# ─────────────────────────────────────────────────────────────────────────────
# Stage 5: Coverage report   (does NOT abort the pipeline)
# ─────────────────────────────────────────────────────────────────────────────
stage(5, "Coverage report (undefined input vectors + QM coverage check)")

def covers_cube(cube, minterm):
    return all(p == '-' or p == c for p, c in zip(cube, minterm))

# ── 5a. Undefined input vectors ───────────────────────────────────────────────
# Every possible binary input combination that has no row in truth_table.
all_input_combos    = list(itertools.product('01', repeat=ni))
defined_input_set   = set(truth_table.keys())
undefined_combos    = [c for c in all_input_combos if ''.join(c) not in defined_input_set]

# ── 5b. QM coverage errors ───────────────────────────────────────────────────
coverage_errors = []
for oi, out_col in enumerate(outputs):
    on    = on_sets[oi]
    cubes = minimised[out_col]
    uncov = [m for m in on
             if not any(covers_cube(c, m) for c in cubes)]
    if uncov:
        coverage_errors.append((out_col, uncov))

# ── Write report ──────────────────────────────────────────────────────────────
with open(p_coverage, 'w') as f:

    f.write(f"# Coverage report for: {stem}\n")
    f.write(f"# Generated by csv2rtl.py\n")
    f.write(f"# Input signals  : {inputs}\n")
    f.write(f"# Output signals : {outputs}\n")
    f.write(f"# Total possible input combos : {len(all_input_combos)}\n")
    f.write(f"# Defined in CSV             : {len(defined_input_set)}\n")
    f.write(f"# Undefined (no CSV row)     : {len(undefined_combos)}\n\n")

    # ── Section 1: Undefined input vectors ───────────────────────────────────
    f.write("## Section 1 — Undefined input vectors\n")
    f.write("#\n")
    f.write("# These input combinations have no row in the CSV (after X-expansion).\n")
    f.write("# The generated Verilog treats them as OFF (output = 0) by default.\n")
    f.write("# Review each entry and add CSV rows if a different behaviour is needed.\n")
    f.write("#\n")
    if not undefined_combos:
        f.write("  None — all input combinations are explicitly defined.  OK\n")
    else:
        # Column header
        in_hdr = "  ".join(f"{inp:>10}" for inp in inputs)
        f.write(f"  {'#':>6}  {in_hdr}   note\n")
        f.write("  " + "-" * (8 + 12 * ni + 8) + "\n")
        for idx, combo in enumerate(undefined_combos, 1):
            vals = "  ".join(f"{v:>10}" for v in combo)
            f.write(f"  {idx:>6}  {vals}   UNDEFINED -> outputs all 0\n")

    f.write("\n")

    # ── Section 2: Input/output conflict log ─────────────────────────────────
    f.write("## Section 2 — Input/output conflicts detected during expansion\n")
    f.write("#\n")
    if not conflict_log:
        f.write("  None — no conflicting rows found.  OK\n")
    else:
        for c in conflict_log:
            f.write(c + "\n")
    f.write("\n")

    # ── Section 3: QM minimisation coverage ──────────────────────────────────
    f.write("## Section 3 — Quine-McCluskey minimisation coverage check\n")
    f.write("#\n")
    if not coverage_errors:
        f.write("  None — all ON-set minterms are covered by the minimised SOP.  OK\n")
    else:
        for out_col, uncov in coverage_errors:
            f.write(f"  {out_col}: {len(uncov)} ON-minterm(s) NOT covered:\n")
            for m in uncov[:20]:
                f.write(f"    {''.join(m)}\n")
            if len(uncov) > 20:
                f.write(f"    ... ({len(uncov)-20} more)\n")
    f.write("\n")

    # ── Section 4: Summary ───────────────────────────────────────────────────
    f.write("## Section 4 — Summary\n")
    f.write(f"  Input combinations : {len(all_input_combos)}\n")
    f.write(f"  Defined            : {len(defined_input_set)}\n")
    f.write(f"  Undefined          : {len(undefined_combos)}"
            + ("  <-- action recommended" if undefined_combos else "  OK") + "\n")
    f.write(f"  Conflicts          : {len(conflict_log)}"
            + ("  <-- review" if conflict_log else "  OK") + "\n")
    f.write(f"  QM coverage errors : {len(coverage_errors)}"
            + ("  <-- BUG in minimiser" if coverage_errors else "  OK") + "\n")

log(f"  Undefined input vectors  : {len(undefined_combos)}")
log(f"  Input/output conflicts   : {len(conflict_log)}")
log(f"  QM coverage errors       : {len(coverage_errors)}")
log(f"  Coverage report written  -> {p_coverage}  OK")
if undefined_combos:
    log(f"  NOTE: {len(undefined_combos)} undefined vector(s) — "
        f"see report. Pipeline continues; Verilog generated with outputs = 0 for those inputs.")

# ─────────────────────────────────────────────────────────────────────────────
# Stage 6: Structural SystemVerilog
# ─────────────────────────────────────────────────────────────────────────────
stage(6, "Structural SystemVerilog generation")

def make_module_name(name):
    return ("m_" + name) if name[0].isdigit() else name

def clean(sig):
    return sig.replace('[', '_').replace(']', '')

def literal_to_wire(lit):
    neg = lit.startswith('!')
    sig = clean(lit.lstrip('!'))
    return (sig + '_inv') if neg else sig

# Build SOP equations:  output_col -> list-of-product-terms (each = list-of-literals)
equations = {}
for out_col in outputs:
    cubes = minimised[out_col]
    if not cubes:
        equations[out_col] = []
        continue
    terms = []
    for cube in cubes:
        lits = []
        for bit, inp in zip(cube, inputs):
            if bit == '1':
                lits.append(inp)
            elif bit == '0':
                lits.append('!' + inp)
        terms.append(lits if lits else ['1'])  # tautology cube
    equations[out_col] = terms

# Which signals need inverters?
negated_signals = set()
for terms in equations.values():
    for term in terms:
        for lit in term:
            if lit.startswith('!'):
                negated_signals.add(clean(lit.lstrip('!')))
negated_signals = sorted(negated_signals)

mod = make_module_name(stem)

with open(sv_path, 'w') as f:

    f.write(f"// {'='*70}\n")
    f.write(f"// Combinational block : {stem}\n")
    f.write(f"// Tool: csv2rtl.py  (auto-generated -- do not hand-edit)\n")
    if undefined_combos:
        f.write(f"// WARNING: {len(undefined_combos)} input vector(s) had no CSV row.\n")
        f.write(f"//          Those vectors produce all-zero outputs (OFF-set default).\n")
        f.write(f"//          See: {p_coverage}\n")
    f.write(f"// {'='*70}\n\n")

    # Truth table comment header
    in_hdr  = "  ".join(f"{c:>12}" for c in inputs)
    out_hdr = "  ".join(f"{c:>12}" for c in outputs)
    sep = "-" * (len(in_hdr) + len(out_hdr) + 10)
    f.write(f"// Truth table (expanded, from CSV)\n")
    f.write(f"// {sep}\n")
    f.write(f"//  {in_hdr}  |  {out_hdr}\n")
    f.write(f"// {sep}\n")
    for in_str, out_str in sorted(truth_table.items()):
        in_vals  = "  ".join(f"{v:>12}" for v in in_str)
        out_vals = "  ".join(f"{v:>12}" for v in out_str)
        f.write(f"//  {in_vals}  |  {out_vals}\n")
    f.write(f"// {sep}\n\n")

    f.write(f"module {mod} (\n")
    port_lines = []
    for out_col in outputs:
        port_lines.append(f"    output wire {clean(out_col)},")
    for idx, inp in enumerate(inputs):
        comma = "" if idx == len(inputs) - 1 else ""
        port_lines.append(f"    input  wire {clean(inp)}" + ("," if idx < len(inputs)-1 else ""))
    # Fix last output comma
    if port_lines:
        # Remove trailing comma from last input line (already handled above),
        # but the last output line before inputs needs its comma kept.
        pass
    f.write("\n".join(port_lines))
    f.write("\n);\n\n")

    if negated_signals:
        f.write("// Inverter wires\n")
        for s in negated_signals:
            f.write(f"wire {s}_inv;\n")
        f.write("\n")
        for s in negated_signals:
            f.write(f"inv1$ inv_{s} ({s}_inv, {s});\n")
        f.write("\n")

    f.write("// SOP logic (Quine-McCluskey minimised)\n\n")

    for out_col in outputs:
        out    = clean(out_col)
        terms  = equations[out_col]
        n_terms = len(terms)

        if n_terms == 0:
            f.write(f"// {out} = 0  (no ON-set minterms)\n")
            f.write(f"assign {out} = 1'b0;\n\n")
            continue

        expr_comment = " | ".join(
            ("(" + " & ".join(t) + ")") if len(t) > 1 else (t[0] if t else "1")
            for t in terms
        )
        f.write(f"// {out} = {expr_comment}\n")

        if n_terms > 1:
            for i in range(n_terms):
                f.write(f"wire {out}_t{i};\n")
            f.write("\n")

        for i, term in enumerate(terms):
            wires  = [literal_to_wire(lit) for lit in term]
            n_in   = len(wires)
            target = out if n_terms == 1 else f"{out}_t{i}"

            if n_in == 1 and wires[0] == '1':
                f.write(f"assign {target} = 1'b1;\n")
            elif n_in == 1:
                tag = f"{out}_buf" if n_terms == 1 else f"{out}_buf{i}"
                f.write(f"buffer$ {tag} ({target}, {wires[0]});\n")
            else:
                tag = f"{out}_and" if n_terms == 1 else f"{out}_and{i}"
                f.write(f"and{n_in}$ {tag} ({target}, {', '.join(wires)});\n")

        if n_terms > 1:
            ints = [f"{out}_t{i}" for i in range(n_terms)]
            f.write(f"or{n_terms}$  {out}_or  ({out}, {', '.join(ints)});\n")

        f.write("\n")

    f.write("endmodule\n")

log(f"  Structural Verilog written -> {sv_path}  OK")

# ─────────────────────────────────────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────────────────────────────────────
log()
log(BANNER)
log("  Pipeline complete -- output files:")
log(BANNER)
manifest = [
    ("PLA (raw)",          p_pla),
    ("PLA (minimised)",    p_minimised_pla),
    ("Coverage report",    p_coverage),
    ("Structural Verilog", sv_path),
]
for label, path in manifest:
    size = os.path.getsize(path) if os.path.exists(path) else 0
    log(f"  {label:<22}  {path}  ({size} bytes)")
log()
