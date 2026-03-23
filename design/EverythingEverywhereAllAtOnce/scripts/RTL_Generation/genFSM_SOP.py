"""
fsm2rtl.py  <input.csv>  <output.sv>

CSV column naming conventions:
  *_i   → primary input signals
  *_o   → Moore/Mealy output signals
  *_s   → current-state column  (exactly ONE column, enumerated state names)
  *_ns  → next-state column     (exactly ONE column, enumerated state names)

Staged debug pipeline — intermediate files written after every stage:
  Stage 1 : Structural CSV validation
  Stage 2 : State/next-state semantic checks
              -> <stem>_state_list.txt
  Stage 3 : X-expansion (don't-care inputs) in original state-name space
              -> <stem>_expanded.csv
  Stage 4 : State enumeration (replace names with binary encodings)
              -> <stem>_enumerated.csv
              -> <stem>_enum_map.txt
  Stage 5 : PLA construction
              -> <stem>.pla
  Stage 6 : Quine-McCluskey minimisation
              -> <stem>_minimised.pla
              -> <stem>_equations.txt
  Stage 7 : Conflict / coverage report
              -> <stem>_conflict_report.txt
  Stage 8 : Structural SystemVerilog
              -> <output.sv>

ERROR-state policy
  If no state named ERROR exists in the CSV, one is synthesised automatically.
  Every (state, input) combination that has no defined transition is routed to
  ERROR with all outputs driven 0.  The ERROR state itself loops back to ERROR
  on all inputs (encoded as a single all-don't-care row).
  The conflict report lists every transition that was undefined and records
  that it was auto-routed to ERROR.
"""

import sys, os, csv, math, itertools
from collections import defaultdict

BANNER = "=" * 72
IDLE_STATE_NAME  = "IDLE"
ERROR_STATE_NAME = "ERROR"

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
    die("Usage: python3 fsm2rtl.py <input.csv> <output.sv>")

csv_path = sys.argv[1]
sv_path  = sys.argv[2]

if not os.path.isfile(csv_path):
    die(f"Input file not found: {csv_path}")

base = os.path.splitext(csv_path)[0]
stem = os.path.splitext(os.path.basename(csv_path))[0]

# All output paths derived from the input stem
p_state_list    = base + "_state_list.txt"
p_expanded_csv  = base + "_expanded.csv"
p_enumerated    = base + "_enumerated.csv"
p_enum_map      = base + "_enum_map.txt"
p_pla           = base + ".pla"
p_minimised_pla = base + "_minimised.pla"
p_equations     = base + "_equations.txt"
p_conflict      = base + "_conflict_report.txt"

log(BANNER)
log(f"  fsm2rtl pipeline -- {stem}")
log(BANNER)
log(f"  Input CSV : {csv_path}")
log(f"  Output SV : {sv_path}")

# ─────────────────────────────────────────────────────────────────────────────
# Stage 1: Structural CSV validation
# ─────────────────────────────────────────────────────────────────────────────
stage(1, "Structural CSV validation")

with open(csv_path, newline='') as fh:
    reader  = csv.DictReader(fh)
    headers = list(reader.fieldnames or [])
    rows    = list(reader)

if not headers:
    die("CSV has no header row.")
if not rows:
    die("CSV has no data rows.")

# Classify columns by suffix
input_cols   = [h for h in headers if h.endswith('_i')]
output_cols  = [h for h in headers if h.endswith('_o')]
state_cols   = [h for h in headers if h.endswith('_s') and not h.endswith('_ns')]
ns_cols      = [h for h in headers if h.endswith('_ns')]
unknown_cols = [h for h in headers
                if h not in input_cols and h not in output_cols
                and h not in state_cols and h not in ns_cols]

log(f"  Headers found    : {headers}")
log(f"  Input cols  (_i) : {input_cols}")
log(f"  Output cols (_o) : {output_cols}")
log(f"  State col   (_s) : {state_cols}")
log(f"  NS col     (_ns) : {ns_cols}")
if unknown_cols:
    log(f"  WARNING -- unrecognised columns (ignored): {unknown_cols}")

errors = []
if len(state_cols) != 1:
    errors.append(f"Expected exactly 1 '_s' column, found: {state_cols}")
if len(ns_cols) != 1:
    errors.append(f"Expected exactly 1 '_ns' column, found: {ns_cols}")
if not input_cols:
    errors.append("No '_i' input columns found.")
if not output_cols:
    errors.append("No '_o' output columns found.")

# Validate cell values in _i / _o columns
valid_io_chars = {'0', '1', '-', 'x', 'X'}
for lineno, row in enumerate(rows, start=2):
    for col in input_cols:
        v = row[col].strip()
        if v not in valid_io_chars:
            errors.append(f"Row {lineno} col '{col}': invalid value '{v}' "
                          f"(expected 0/1/X/-)")
    for col in output_cols:
        v = row[col].strip()
        if v not in valid_io_chars:
            errors.append(f"Row {lineno} col '{col}': invalid value '{v}' "
                          f"(expected 0/1/X/-)")

if errors:
    log("\n  Structural errors found:")
    for e in errors:
        log(f"    ERROR: {e}")
    die("Fix structural errors before proceeding.")

state_col = state_cols[0]
ns_col    = ns_cols[0]

log(f"\n  {len(rows)} data rows, {len(input_cols)} input(s), "
    f"{len(output_cols)} output(s)  OK")

# ─────────────────────────────────────────────────────────────────────────────
# Stage 2: State / next-state semantic checks  ->  _state_list.txt
# ─────────────────────────────────────────────────────────────────────────────
stage(2, "State & next-state semantic checks")

defined_states = sorted(set(r[state_col].strip() for r in rows))
ns_values_seen = sorted(set(r[ns_col].strip() for r in rows))

log(f"  Defined states ({len(defined_states)}): {defined_states}")
log(f"  NS values seen ({len(ns_values_seen)}): {ns_values_seen}")

# ── IDLE state check ──────────────────────────────────────────────────────────
if IDLE_STATE_NAME not in defined_states:
    die(f"No '{IDLE_STATE_NAME}' state found in the '{state_col}' column. "
        f"Every FSM must have an IDLE state (it will be assigned encoding 0). "
        f"Defined states are: {defined_states}")
else:
    log(f"\n  IDLE state found  OK  (will be assigned encoding 0)")

# ── ERROR state check — synthesise if absent ─────────────────────────────────
error_state_synthesised = False
if ERROR_STATE_NAME not in defined_states:
    defined_states = sorted(defined_states + [ERROR_STATE_NAME])
    error_state_synthesised = True
    log(f"  ERROR state not found in CSV -- will be synthesised automatically")
else:
    log(f"  ERROR state found in CSV  OK")

# Collect all undefined-NS errors before dying
# (next-states are allowed to reference ERROR even if it wasn't in the CSV,
#  because we may be about to synthesise it)
all_valid_states = set(defined_states)
errors = []
for lineno, row in enumerate(rows, start=2):
    ns_val = row[ns_col].strip()
    if ns_val not in all_valid_states:
        errors.append(f"  Row {lineno}: next-state '{ns_val}' (column '{ns_col}') "
                      f"is not a defined state.")

if errors:
    log(f"\n  {len(errors)} undefined next-state reference(s):")
    for e in errors:
        log(e)
    log(f"\n  Defined states are: {sorted(all_valid_states)}")
    die("All next-states must reference a defined current state.")

# Warnings: states never targeted (possible dead-ends)
# ERROR is intentionally never a *source* of any user-defined transition, so
# exclude it from this check only if it was synthesised (user-defined ERROR
# states should still be checked normally).
ns_values_for_sink_check = sorted(set(r[ns_col].strip() for r in rows))
sink_states = [s for s in defined_states
               if s not in ns_values_for_sink_check
               and not (s == ERROR_STATE_NAME and error_state_synthesised)]
if sink_states:
    log(f"\n  WARNING: These states are never a next-state target "
        f"(possible dead-ends): {sink_states}")

# Write state list file
n_bits_preview = max(1, math.ceil(math.log2(len(defined_states)))) \
                 if len(defined_states) > 1 else 1
with open(p_state_list, 'w') as f:
    f.write(f"# State list for FSM: {stem}\n")
    f.write(f"# Total states      : {len(defined_states)}\n")
    f.write(f"# State bits needed : {n_bits_preview}\n")
    f.write(f"# NOTE: IDLE is always assigned encoding 0\n")
    if error_state_synthesised:
        f.write(f"# NOTE: ERROR state was synthesised (not present in CSV)\n")
    f.write(f"#\n")
    f.write(f"# {'idx':>4}  {'binary':<{n_bits_preview}}  state_name\n")
    f.write("# " + "-"*50 + "\n")
    for i, s in enumerate(defined_states):
        tag = "  # synthesised" if (s == ERROR_STATE_NAME and error_state_synthesised) else ""
        f.write(f"  {i:>4}  {format(i, f'0{n_bits_preview}b')}  {s}{tag}\n")
    if sink_states:
        f.write(f"\n# WARNING - states never targeted as next-state:\n")
        for s in sink_states:
            f.write(f"#   {s}\n")

log(f"\n  State list written -> {p_state_list}  OK")
log(f"  No undefined next-states found  OK")

# ─────────────────────────────────────────────────────────────────────────────
# Stage 3: X-expansion in state-name space  ->  _expanded.csv
# ─────────────────────────────────────────────────────────────────────────────
stage(3, "X-expansion (don't-care inputs, state names preserved)")

def expand_row_inputs(row, in_cols):
    dc_cols = [(i, col) for i, col in enumerate(in_cols)
               if row[col].strip() in ('-', 'x', 'X')]
    if not dc_cols:
        return [dict(row)]
    result = []
    for combo in itertools.product('01', repeat=len(dc_cols)):
        new_row = dict(row)
        for val, (_, col) in zip(combo, dc_cols):
            new_row[col] = val
        result.append(new_row)
    return result

expanded_rows = []
for lineno, row in enumerate(rows, start=2):
    for exp_row in expand_row_inputs(row, input_cols):
        exp_row['_src_row'] = lineno
        expanded_rows.append(exp_row)

log(f"  Original rows : {len(rows)}")
log(f"  Expanded rows : {len(expanded_rows)}")

conflict_key = {}
conflicts    = []
for exp_row in expanded_rows:
    in_tup  = tuple(exp_row[c].strip() for c in input_cols)
    out_tup = tuple(exp_row[c].strip() for c in output_cols)
    key     = (exp_row[state_col].strip(), in_tup)
    ns_val  = exp_row[ns_col].strip()
    entry   = (ns_val, out_tup, exp_row['_src_row'])
    if key in conflict_key:
        prev_ns, prev_out, prev_line = conflict_key[key]
        if (ns_val, out_tup) != (prev_ns, prev_out):
            conflicts.append(
                f"  CONFLICT state='{key[0]}' inputs={dict(zip(input_cols,in_tup))}:\n"
                f"    Row {prev_line}: NS='{prev_ns}' outputs={prev_out}\n"
                f"    Row {exp_row['_src_row']}: NS='{ns_val}' outputs={out_tup}"
            )
    else:
        conflict_key[key] = entry

if conflicts:
    log(f"\n  {len(conflicts)} conflict(s) detected after expansion:")
    for c in conflicts:
        log(c)
    die("Resolve conflicting rows before proceeding.")
else:
    log(f"  No conflicts after expansion  OK")

# ── Synthesise missing transitions -> ERROR ───────────────────────────────────
# Build the set of (state, input_combo) pairs that exist in the user CSV
# (using the expanded rows so don't-care patterns are already resolved).
# For every combination that is absent, inject a synthetic row that drives
# NS = ERROR and all outputs = 0.  Collect those for reporting.

all_input_combos    = list(itertools.product('01', repeat=len(input_cols)))
zero_outputs        = tuple('0' for _ in output_cols)
auto_error_routes   = []   # list of (state, input_combo_dict) for the report

user_defined_states = sorted(s for s in defined_states if s != ERROR_STATE_NAME)

for state in user_defined_states:
    for combo in all_input_combos:
        if (state, combo) not in conflict_key:
            # Record for reporting
            auto_error_routes.append((state, dict(zip(input_cols, combo))))
            # Inject into conflict_key so Stage 5 picks it up
            conflict_key[(state, combo)] = (ERROR_STATE_NAME, zero_outputs, 'AUTO')
            # Build a synthetic expanded row
            syn_row = {state_col: state, ns_col: ERROR_STATE_NAME}
            for col, val in zip(input_cols, combo):
                syn_row[col] = val
            for col in output_cols:
                syn_row[col] = '0'
            syn_row['_src_row'] = 'AUTO'
            expanded_rows.append(syn_row)

# ── ERROR self-loop: one all-don't-care row ───────────────────────────────────
# Add a single row  ERROR + ----... -> ERROR, outputs all 0.
# We expand it here just like any other row (all 2^n combos).
error_self_loop_row = {state_col: ERROR_STATE_NAME, ns_col: ERROR_STATE_NAME}
for col in input_cols:
    error_self_loop_row[col] = '-'
for col in output_cols:
    error_self_loop_row[col] = '0'
error_self_loop_row['_src_row'] = 'AUTO'

for exp_row in expand_row_inputs(error_self_loop_row, input_cols):
    exp_row['_src_row'] = 'AUTO'
    in_tup = tuple(exp_row[c].strip() for c in input_cols)
    key    = (ERROR_STATE_NAME, in_tup)
    if key not in conflict_key:
        conflict_key[key] = (ERROR_STATE_NAME, zero_outputs, 'AUTO')
    expanded_rows.append(exp_row)

if auto_error_routes:
    log(f"\n  {len(auto_error_routes)} undefined transition(s) auto-routed to ERROR")
else:
    log(f"\n  All transitions explicitly defined -- ERROR state is unreachable trap")

with open(p_expanded_csv, 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=headers, extrasaction='ignore')
    writer.writeheader()
    writer.writerows(expanded_rows)

log(f"  Expanded CSV written -> {p_expanded_csv}  OK")

# ─────────────────────────────────────────────────────────────────────────────
# Stage 4: State enumeration  ->  _enumerated.csv  +  _enum_map.txt
# ─────────────────────────────────────────────────────────────────────────────
stage(4, "State enumeration (name -> binary, IDLE always = 0)")

n_states     = len(defined_states)
n_state_bits = max(1, math.ceil(math.log2(n_states))) if n_states > 1 else 1

# IDLE is forced to 0.
# ERROR gets the last encoding (highest value) so it stands out in waveforms.
# All other states fill in between in sorted order.
middle_states  = sorted(s for s in defined_states
                        if s != IDLE_STATE_NAME and s != ERROR_STATE_NAME)
ordered_states = [IDLE_STATE_NAME] + middle_states + [ERROR_STATE_NAME]
state_enc      = {s: i for i, s in enumerate(ordered_states)}

log(f"  States : {n_states}  ->  {n_state_bits} bit(s)")
log(f"  (IDLE forced to encoding 0, ERROR gets highest encoding)")
for s, v in state_enc.items():
    tags = []
    if s == IDLE_STATE_NAME:  tags.append("IDLE (forced 0)")
    if s == ERROR_STATE_NAME: tags.append("ERROR (highest encoding)")
    if error_state_synthesised and s == ERROR_STATE_NAME: tags.append("synthesised")
    tag_str = "  <- " + ", ".join(tags) if tags else ""
    log(f"    {s:<30}  {format(v, f'0{n_state_bits}b')}  ({v}){tag_str}")

def state_bit_name(b):  return f"S_{b}"
def ns_bit_name(b):     return f"NS_{b}"

state_bit_names = [state_bit_name(b) for b in range(n_state_bits)]
ns_bit_names    = [ns_bit_name(b)    for b in range(n_state_bits)]

enum_headers = state_bit_names + input_cols + ns_bit_names + output_cols
enum_rows = []
for exp_row in expanded_rows:
    s_name  = exp_row[state_col].strip()
    ns_name = exp_row[ns_col].strip()
    if s_name not in state_enc or ns_name not in state_enc:
        continue   # safety guard (should never trigger)
    s_enc_val  = state_enc[s_name]
    ns_enc_val = state_enc[ns_name]
    s_bits_str  = format(s_enc_val,  f'0{n_state_bits}b')[::-1]
    ns_bits_str = format(ns_enc_val, f'0{n_state_bits}b')[::-1]
    new_row = {}
    for b in range(n_state_bits):
        new_row[state_bit_name(b)] = s_bits_str[b]
        new_row[ns_bit_name(b)]    = ns_bits_str[b]
    for col in input_cols:
        new_row[col] = exp_row[col].strip()
    for col in output_cols:
        new_row[col] = exp_row[col].strip()
    enum_rows.append(new_row)

with open(p_enumerated, 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=enum_headers)
    writer.writeheader()
    writer.writerows(enum_rows)

log(f"\n  Enumerated CSV written -> {p_enumerated}  OK")

with open(p_enum_map, 'w') as f:
    f.write(f"# Enumeration map for FSM: {stem}\n")
    f.write(f"# {n_states} states -> {n_state_bits} bit(s)\n")
    f.write(f"# IDLE is always assigned encoding 0\n")
    f.write(f"# ERROR is always assigned the highest encoding\n")
    if error_state_synthesised:
        f.write(f"# ERROR was synthesised (not present in source CSV)\n")
    f.write(f"#\n")
    f.write(f"# {'state_name':<30} {'decimal':>8}  binary\n")
    f.write("# " + "-"*50 + "\n")
    for s, v in state_enc.items():
        tags = []
        if s == IDLE_STATE_NAME:  tags.append("IDLE (forced 0)")
        if s == ERROR_STATE_NAME:
            tags.append("ERROR (highest)")
            if error_state_synthesised: tags.append("synthesised")
        tag_str = "  # " + ", ".join(tags) if tags else ""
        f.write(f"  {s:<30} {v:>8}  {format(v, f'0{n_state_bits}b')}{tag_str}\n")

log(f"  Enumeration map written -> {p_enum_map}  OK")

# ─────────────────────────────────────────────────────────────────────────────
# Stage 5: PLA construction  ->  <stem>.pla
# ─────────────────────────────────────────────────────────────────────────────
stage(5, "PLA construction")

pla_inputs  = state_bit_names + input_cols
pla_outputs = ns_bit_names    + output_cols
ni = len(pla_inputs)
no = len(pla_outputs)

truth_table = {}
for erow in enum_rows:
    in_str  = ''.join(erow[c] for c in pla_inputs)
    out_str = ''.join(erow[c] for c in pla_outputs)
    if in_str in truth_table and truth_table[in_str] != out_str:
        log(f"  WARNING (Stage 5): key collision {in_str}  "
            f"old={truth_table[in_str]}  new={out_str}  (keeping old)")
    truth_table[in_str] = out_str

log(f"  PLA size: {ni} inputs, {no} outputs, {len(truth_table)} minterms")

with open(p_pla, 'w') as f:
    f.write(f"# PLA for FSM: {stem}\n")
    f.write(f".i {ni}\n")
    f.write(f".o {no}\n")
    f.write(f".ilb {' '.join(pla_inputs)}\n")
    f.write(f".ob  {' '.join(pla_outputs)}\n")
    f.write(".type fr\n")
    for in_str, out_str in sorted(truth_table.items()):
        f.write(f"{in_str} {out_str}\n")
    f.write(".e\n")

log(f"  PLA written -> {p_pla}  OK")

# ─────────────────────────────────────────────────────────────────────────────
# Stage 6: Quine-McCluskey minimisation ->  _minimised.pla  +  _equations.txt
# ─────────────────────────────────────────────────────────────────────────────
stage(6, "Quine-McCluskey minimisation")

def qm_minimise(on_set, dc_set, n_vars):
    on_cubes  = [tuple(v) for v in on_set]
    all_cubes = list(set(on_cubes) | set(tuple(v) for v in dc_set))
    if not all_cubes:
        return []

    def can_merge(a, b):
        diffs = [i for i in range(n_vars) if a[i] != b[i]]
        if len(diffs) != 1:
            return None
        if a[diffs[0]] == '-' or b[diffs[0]] == '-':
            return None
        m = list(a)
        m[diffs[0]] = '-'
        return tuple(m)

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
                m = can_merge(g[i], g[j])
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

    uncovered = list(on_cubes)
    chosen    = []
    remaining = list(prime_implicants)

    while uncovered:
        if not remaining:
            log(f"  WARNING: QM cover incomplete -- {len(uncovered)} minterms uncovered")
            break
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

    return chosen

on_sets = defaultdict(list)
dc_sets = defaultdict(list)

for in_str, out_str in truth_table.items():
    in_tup = tuple(in_str)
    for oi in range(no):
        v = out_str[oi] if oi < len(out_str) else '0'
        if v == '1':
            on_sets[oi].append(in_tup)
        elif v in ('-', 'x', 'X'):
            dc_sets[oi].append(in_tup)

minimised = {}
for oi, oname in enumerate(pla_outputs):
    on    = on_sets[oi]
    dc    = dc_sets[oi]
    cubes = qm_minimise(on, dc, ni) if on else []
    minimised[oname] = cubes
    log(f"  {oname:<20}: {len(on):>4} ON minterms  ->  {len(cubes):>3} prime implicants")

cube_out_map = defaultdict(lambda: ['0'] * no)
for oi, oname in enumerate(pla_outputs):
    for cube in minimised[oname]:
        key = ''.join(cube)
        cube_out_map[key][oi] = '1'

with open(p_minimised_pla, 'w') as f:
    f.write(f"# Minimised SOP (Quine-McCluskey) for FSM: {stem}\n")
    f.write(f".i {ni}\n")
    f.write(f".o {no}\n")
    f.write(f".ilb {' '.join(pla_inputs)}\n")
    f.write(f".ob  {' '.join(pla_outputs)}\n")
    f.write(".type f\n")
    for in_str, out_list in sorted(cube_out_map.items()):
        f.write(f"{in_str} {''.join(out_list)}\n")
    f.write(".e\n")

log(f"\n  Minimised PLA written -> {p_minimised_pla}  OK")

def cube_to_term(cube, signal_names):
    lits = []
    for bit, name in zip(cube, signal_names):
        if bit == '1':
            lits.append(name)
        elif bit == '0':
            lits.append('!' + name)
    return lits if lits else ['1']

equations = {}
for oname in pla_outputs:
    cubes = minimised[oname]
    equations[oname] = [cube_to_term(c, pla_inputs) for c in cubes] if cubes else []

with open(p_equations, 'w') as f:
    f.write(f"# Human-readable SOP equations for FSM: {stem}\n")
    f.write(f"# Input  signal order : {pla_inputs}\n")
    f.write(f"# Output signal order : {pla_outputs}\n\n")
    for oname in pla_outputs:
        terms = equations[oname]
        if not terms:
            f.write(f"{oname} = 0\n\n")
        else:
            parts = []
            for term in terms:
                if term == ['1']:
                    parts.append("1")
                elif len(term) == 1:
                    parts.append(term[0])
                else:
                    parts.append("(" + " & ".join(term) + ")")
            f.write(f"{oname} = {' | '.join(parts)}\n\n")

log(f"  Equations written -> {p_equations}  OK")

# ─────────────────────────────────────────────────────────────────────────────
# Stage 7: Coverage & conflict audit  ->  _conflict_report.txt
# ─────────────────────────────────────────────────────────────────────────────
stage(7, "Coverage & conflict audit")

def covers_cube(cube, minterm):
    return all(p == '-' or p == c for p, c in zip(cube, minterm))

coverage_errors = []
for oi, oname in enumerate(pla_outputs):
    on    = on_sets[oi]
    cubes = minimised[oname]
    uncov = [m for m in on
             if not any(covers_cube(c, m) for c in cubes)]
    if uncov:
        snippet = ["    " + ''.join(m) for m in uncov[:10]]
        if len(uncov) > 10:
            snippet.append(f"    ... ({len(uncov)-10} more)")
        coverage_errors.append(
            f"  {oname}: {len(uncov)} ON minterms NOT covered:\n"
            + "\n".join(snippet)
        )

with open(p_conflict, 'w') as f:
    f.write(f"# Conflict & coverage report for FSM: {stem}\n\n")

    # ── Coverage errors ───────────────────────────────────────────────────────
    f.write("## Coverage errors (minimisation did not cover ON minterms)\n")
    if coverage_errors:
        for e in coverage_errors:
            f.write(e + "\n")
    else:
        f.write("  None -- all ON-set minterms covered  OK\n")
    f.write("\n")

    # ── Undefined transitions auto-routed to ERROR ────────────────────────────
    f.write("## Undefined transitions (auto-routed to ERROR state)\n")
    if auto_error_routes:
        if error_state_synthesised:
            f.write("  NOTE: ERROR state was not present in the source CSV and was "
                    "synthesised automatically.\n")
        else:
            f.write("  NOTE: ERROR state was present in the source CSV.\n")
        f.write(f"  {len(auto_error_routes)} transition(s) had no definition "
                f"and were routed to ERROR with all outputs = 0:\n\n")
        for state, inp_dict in auto_error_routes:
            f.write(f"  State '{state}' + {inp_dict}  ->  ERROR  (outputs all 0)\n")
    else:
        f.write("  None -- all state/input combinations were explicitly defined  OK\n")
    f.write("\n")

    # ── Sink states ───────────────────────────────────────────────────────────
    f.write("## Sink states (states never targeted as next-state, "
            "excluding synthesised ERROR)\n")
    if sink_states:
        for s in sink_states:
            f.write(f"  {s}\n")
    else:
        f.write("  None\n")

log(f"  Coverage errors          : {len(coverage_errors)}")
log(f"  Undefined -> ERROR routes: {len(auto_error_routes)}")
log(f"  Sink states              : {len(sink_states)}")
log(f"  Conflict report written -> {p_conflict}  OK")

if coverage_errors:
    die("Minimisation produced incomplete coverage -- see conflict report.")

# ─────────────────────────────────────────────────────────────────────────────
# Stage 8: Structural SystemVerilog
# ─────────────────────────────────────────────────────────────────────────────
stage(8, "Structural SystemVerilog generation")

def make_module_name(name):
    return ("m_" + name) if name[0].isdigit() else name

def literal_to_wire(lit):
    neg = lit.startswith('!')
    sig = lit.lstrip('!')
    return (sig + '_inv') if neg else sig

negated_signals = set()
for terms in equations.values():
    for term in terms:
        for lit in term:
            if lit.startswith('!'):
                negated_signals.add(lit.lstrip('!'))
negated_signals = sorted(negated_signals)

mod = make_module_name(stem)

def tt_header():
    cols_in  = state_bit_names + input_cols
    cols_out = ns_bit_names + output_cols
    in_hdr  = '  '.join(f"{c:>10}" for c in cols_in)
    out_hdr = '  '.join(f"{c:>10}" for c in cols_out)
    sep = '-' * (len(in_hdr) + 6 + len(out_hdr))
    return in_hdr, out_hdr, sep

with open(sv_path, 'w') as f:

    f.write(f"// {'='*70}\n")
    f.write(f"// FSM : {stem}\n")
    f.write(f"// Tool: fsm2rtl.py  (auto-generated -- do not hand-edit)\n")
    if error_state_synthesised:
        f.write(f"// NOTE: ERROR state was synthesised automatically.\n")
        f.write(f"//       Any undefined transition lands here (all outputs = 0).\n")
    f.write(f"// {'='*70}\n//\n")

    f.write(f"// State Enumeration  ({n_state_bits} bit{'s' if n_state_bits>1 else ''}, "
            f"{n_states} states)\n")
    f.write(f"// {'-'*50}\n")
    for sname, sval in state_enc.items():
        tags = []
        if sname == IDLE_STATE_NAME:  tags.append("IDLE (reset state)")
        if sname == ERROR_STATE_NAME:
            tags.append("ERROR (trap state)")
            if error_state_synthesised: tags.append("synthesised")
        tag_str = "  // " + ", ".join(tags) if tags else ""
        f.write(f"//   {sname:<28}  {format(sval, f'0{n_state_bits}b')}  (decimal {sval}){tag_str}\n")
    f.write("//\n")

    in_hdr, out_hdr, sep = tt_header()
    f.write("// Truth Table (pre-expansion, original CSV rows)\n")
    f.write(f"// {sep}\n")
    f.write(f"//  {in_hdr}  |  {out_hdr}   transition\n")
    f.write(f"// {sep}\n")
    for row in rows:
        s_val   = state_enc[row[state_col].strip()]
        ns_val  = state_enc[row[ns_col].strip()]
        s_str   = format(s_val,  f'0{n_state_bits}b')[::-1]
        ns_str  = format(ns_val, f'0{n_state_bits}b')[::-1]
        in_vals  = list(s_str) + [row[c].strip() for c in input_cols]
        out_vals = list(ns_str) + [row[c].strip() for c in output_cols]
        in_part  = '  '.join(f"{v:>10}" for v in in_vals)
        out_part = '  '.join(f"{v:>10}" for v in out_vals)
        f.write(f"//  {in_part}  |  {out_part}"
                f"   {row[state_col].strip()} -> {row[ns_col].strip()}\n")
    f.write(f"// {sep}\n//\n\n")

    f.write(f"module {mod} (\n")
    port_lines = [
        "    input  wire clk,",
        "    input  wire rst,",
    ]
    for inp in input_cols:
        port_lines.append(f"    input  wire {inp},")
    for b in range(n_state_bits):
        port_lines.append(
            f"    output wire {state_bit_name(b)},  // current-state bit {b} ({"LSB" if b==0 else "MSB" if b==n_state_bits-1 else str(b)})")
    for idx, out in enumerate(output_cols):
        comma = "," if idx < len(output_cols) - 1 else ""
        port_lines.append(f"    output wire {out}{comma}")
    f.write("\n".join(port_lines))
    f.write("\n);\n\n")

    f.write("// Next-state wires  (NS_0=LSB ... NS_{N-1}=MSB)\n")
    for b in range(n_state_bits):
        f.write(f"wire {ns_bit_name(b)};\n")
    f.write("\n")

    f.write("// State encoding  (IDLE = 0, ERROR = highest, guaranteed by tool)\n")
    for sname, sval in state_enc.items():
        tags = []
        if sname == IDLE_STATE_NAME:  tags.append("IDLE (reset state)")
        if sname == ERROR_STATE_NAME:
            tags.append("ERROR (trap state)")
            if error_state_synthesised: tags.append("synthesised")
        tag_str = "  // " + ", ".join(tags) if tags else ""
        f.write(f"//   {sname:<28} = {format(sval, f'0{n_state_bits}b')}  (decimal {sval}){tag_str}\n")
    f.write("\n")

    f.write("// State flip-flops  (reg1b, active-low async reset)\n")
    f.write("// Reset drives all state bits to 0, which is IDLE by construction.\n")
    for b in range(n_state_bits):
        f.write(
            f"reg1b ff_{b} (\n"
            f"    .clk(clk),\n"
            f"    .rst(rst),\n"
            f"    .d({ns_bit_name(b)}),\n"
            f"    .q({state_bit_name(b)})\n"
            f");\n"
        )
    f.write("\n")

    if negated_signals:
        f.write("// Inverters\n")
        for s in negated_signals:
            f.write(f"wire {s}_inv;\n")
        f.write("\n")
        for s in negated_signals:
            f.write(f"inv1$ inv_{s} ({s}_inv, {s});\n")
        f.write("\n")

    f.write("// Next-state and output SOP logic\n\n")

    for sig in pla_outputs:
        terms   = equations[sig]
        n_terms = len(terms)

        if n_terms == 0:
            f.write(f"// {sig} = 0  (no ON-set minterms)\n")
            f.write(f"assign {sig} = 1'b0;\n\n")
            continue

        expr_comment = ' | '.join(
            ('(' + ' & '.join(t) + ')') if len(t) > 1 else t[0]
            for t in terms
        )
        f.write(f"// {sig} = {expr_comment}\n")

        if n_terms > 1:
            for i in range(n_terms):
                f.write(f"wire {sig}_t{i};\n")
            f.write("\n")

        for i, term in enumerate(terms):
            wires  = [literal_to_wire(lit) for lit in term]
            n_in   = len(wires)
            target = sig if n_terms == 1 else f"{sig}_t{i}"

            if n_in == 1 and wires[0] == '1':
                f.write(f"assign {target} = 1'b1;\n")
            elif n_in == 1:
                tag = f"{sig}_buf" if n_terms == 1 else f"{sig}_buf{i}"
                f.write(f"buffer$ {tag} ({target}, {wires[0]});\n")
            else:
                tag = f"{sig}_and" if n_terms == 1 else f"{sig}_and{i}"
                f.write(f"and{n_in}$ {tag} ({target}, {', '.join(wires)});\n")

        if n_terms > 1:
            ints = [f"{sig}_t{i}" for i in range(n_terms)]
            f.write(f"or{n_terms}$  {sig}_or  ({sig}, {', '.join(ints)});\n")

        f.write("\n")

    f.write("endmodule\n")

log(f"  Structural Verilog written -> {sv_path}  OK")

# ─────────────────────────────────────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────────────────────────────────────
log()
log(BANNER)
log("  Pipeline complete -- all output files:")
log(BANNER)
file_manifest = [
    ("State list",         p_state_list),
    ("Expanded CSV",       p_expanded_csv),
    ("Enumerated CSV",     p_enumerated),
    ("Enumeration map",    p_enum_map),
    ("PLA (raw)",          p_pla),
    ("PLA (minimised)",    p_minimised_pla),
    ("SOP equations",      p_equations),
    ("Conflict report",    p_conflict),
    ("Structural Verilog", sv_path),
]
for label, path in file_manifest:
    size = os.path.getsize(path) if os.path.exists(path) else 0
    log(f"  {label:<22}  {path}  ({size} bytes)")
log()
