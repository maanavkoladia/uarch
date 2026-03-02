"""
fsm2rtl.py  <input.csv>  <output.sv>

CSV column naming conventions:
  *_i   → primary input signals
  *_o   → Moore/Mealy output signals
  *_s   → current-state column  (exactly ONE column, enumerated state names)
  *_ns  → next-state column     (exactly ONE column, enumerated state names)

Pipeline:
  1. Parse CSV, encode states in binary (ceil(log2(N)) bits)
  2. Write  <stem>.pla          (inputs: state-bits + _i cols;
                                  outputs: NS-bits + _o cols)
  3. Minimise per-output with Quine-McCluskey  → <stem>_espresso.out
  4. Emit structural Verilog with:
       - reg1b FFs for each state bit
       - inv1$, andN$, orN$, buffer$ gates for the SOP logic
"""

import sys, os, csv, math, itertools
from collections import defaultdict

# ─────────────────────────────────────────────────────────────────────────────
# 0.  CLI
# ─────────────────────────────────────────────────────────────────────────────
if len(sys.argv) != 3:
    print("Usage: python3 fsm2rtl.py <input.csv> <output.sv>")
    sys.exit(1)

csv_path = sys.argv[1]
sv_path  = sys.argv[2]
stem     = os.path.splitext(os.path.basename(csv_path))[0]
pla_path = os.path.splitext(csv_path)[0] + ".pla"
esp_path = os.path.splitext(csv_path)[0] + "_espresso.out"

# ─────────────────────────────────────────────────────────────────────────────
# 1.  Parse CSV
# ─────────────────────────────────────────────────────────────────────────────
with open(csv_path, newline='') as fh:
    reader   = csv.DictReader(fh)
    headers  = reader.fieldnames
    rows     = list(reader)

# Identify column groups
input_cols  = [h for h in headers if h.endswith('_i')]
output_cols = [h for h in headers if h.endswith('_o')]
state_cols  = [h for h in headers if h.endswith('_s')]
ns_cols     = [h for h in headers if h.endswith('_ns')]

if len(state_cols) != 1:
    sys.exit(f"ERROR: Expected exactly 1 '_s' column, found: {state_cols}")
if len(ns_cols) != 1:
    sys.exit(f"ERROR: Expected exactly 1 '_ns' column, found: {ns_cols}")

state_col = state_cols[0]
ns_col    = ns_cols[0]

# Enumerate states
all_states = sorted(set(
    r[state_col].strip() for r in rows
) | set(
    r[ns_col].strip() for r in rows
))
n_states     = len(all_states)
n_state_bits = max(1, math.ceil(math.log2(n_states))) if n_states > 1 else 1
state_enc    = {s: i for i, s in enumerate(all_states)}

print(f"States ({n_states}, {n_state_bits} bits): {state_enc}")
print(f"Inputs  : {input_cols}")
print(f"Outputs : {output_cols}")

# Signal name helpers
def state_bit_name(b):   return f"S_{b}"
def ns_bit_name(b):      return f"NS_{b}"

state_bit_names = [state_bit_name(b) for b in range(n_state_bits)]
ns_bit_names    = [ns_bit_name(b)    for b in range(n_state_bits)]

# PLA column order:
#   inputs  = state-bits (MSB→LSB) + _i columns
#   outputs = NS-bits    (MSB→LSB) + _o columns
pla_inputs  = state_bit_names + input_cols          # signal names (for header)
pla_outputs = ns_bit_names    + output_cols

ni = len(pla_inputs)
no = len(pla_outputs)

# ─────────────────────────────────────────────────────────────────────────────
# 2.  Build truth-table rows (expand don't-cares in inputs)
# ─────────────────────────────────────────────────────────────────────────────
def expand_dc(pattern):
    """Yield all binary strings produced by expanding '-' and 'x' in pattern."""
    positions = [i for i, c in enumerate(pattern) if c in ('-', 'x', 'X')]
    if not positions:
        yield pattern
        return
    for combo in itertools.product('01', repeat=len(positions)):
        lst = list(pattern)
        for pos, val in zip(positions, combo):
            lst[pos] = val
        yield ''.join(lst)

truth_table = {}   # in_str → out_str  (last write wins – no conflict check)

for row in rows:
    # State bits (MSB first)
    s_enc   = state_enc[row[state_col].strip()]
    ns_enc  = state_enc[row[ns_col].strip()]
    s_bits  = format(s_enc,  f'0{n_state_bits}b')
    ns_bits = format(ns_enc, f'0{n_state_bits}b')

    # Primary input bits
    in_bits = ''.join(row[c].strip() for c in input_cols)

    # Output bits
    out_bits = ''.join(
        row[c].strip() if row[c].strip() in ('0','1','-','x','X') else '0'
        for c in output_cols
    )

    addr_pattern = s_bits + in_bits
    data_str     = ns_bits + out_bits

    for expanded in expand_dc(addr_pattern):
        truth_table[expanded] = data_str

# ─────────────────────────────────────────────────────────────────────────────
# 3.  Write PLA
# ─────────────────────────────────────────────────────────────────────────────
with open(pla_path, 'w') as f:
    f.write(f".i {ni}\n")
    f.write(f".o {no}\n")
    f.write(f".ilb {' '.join(pla_inputs)}\n")
    f.write(f".ob  {' '.join(pla_outputs)}\n")
    f.write(".type fr\n")
    for in_str, out_str in sorted(truth_table.items()):
        f.write(f"{in_str} {out_str}\n")
    f.write(".e\n")

print(f"Written PLA → {pla_path}")

# ─────────────────────────────────────────────────────────────────────────────
# 4.  Quine-McCluskey minimiser (pure Python, per output bit)
# ─────────────────────────────────────────────────────────────────────────────

def qm_minimise(on_set, dc_set, ni):
    """Return list of prime-implicant cubes (tuples) covering on_set."""
    on_cubes  = [tuple(v) for v in on_set]
    all_cubes = list(set(on_cubes) | set(tuple(v) for v in dc_set))
    if not all_cubes:
        return []

    def can_merge(a, b):
        diffs = [i for i in range(ni) if a[i] != b[i]]
        if len(diffs) != 1 or a[diffs[0]] == '-' or b[diffs[0]] == '-':
            return None
        m = list(a); m[diffs[0]] = '-'
        return tuple(m)

    def covers(pi, m):
        return all(p == '-' or p == c for p, c in zip(pi, m))

    groups = all_cubes
    prime_implicants = set()
    while groups:
        g      = list(set(groups))
        merged = set()
        used   = set()
        for i in range(len(g)):
            for j in range(i+1, len(g)):
                m = can_merge(g[i], g[j])
                if m is not None:
                    merged.add(m); used.add(i); used.add(j)
        for i, cube in enumerate(g):
            if i not in used:
                prime_implicants.add(cube)
        groups = list(merged)

    if not on_cubes:
        return []

    # Greedy essential-PI cover
    uncovered = list(on_cubes)
    chosen    = []
    remaining = list(prime_implicants)

    while uncovered:
        if not remaining:
            break
        remaining.sort(
            key=lambda pi: (sum(1 for m in uncovered if covers(pi, m)), pi.count('-')),
            reverse=True
        )
        best = remaining.pop(0)
        if any(covers(best, m) for m in uncovered):
            chosen.append(best)
            uncovered = [m for m in uncovered if not covers(best, m)]

    return chosen

# Build per-output-bit on/dc sets
on_sets = defaultdict(list)
dc_sets = defaultdict(list)

for in_str, out_str in truth_table.items():
    in_tup = tuple(in_str)
    for oi in range(no):
        v = out_str[oi] if oi < len(out_str) else '0'
        if v == '1':
            on_sets[oi].append(in_tup)
        elif v in ('-','x','X'):
            dc_sets[oi].append(in_tup)

minimised = {}   # output_col_name → list-of-cubes
for oi, oname in enumerate(pla_outputs):
    on = on_sets[oi]
    dc = dc_sets[oi]
    minimised[oname] = qm_minimise(on, dc, ni) if on else []

# ─────────────────────────────────────────────────────────────────────────────
# 5.  Write espresso-style .out file
# ─────────────────────────────────────────────────────────────────────────────
with open(esp_path, 'w') as f:
    f.write(f"# Minimised SOP (Quine-McCluskey) for FSM: {stem}\n")
    f.write(f".i {ni}\n")
    f.write(f".o {no}\n")
    f.write(f".ilb {' '.join(pla_inputs)}\n")
    f.write(f".ob  {' '.join(pla_outputs)}\n")
    f.write(".type f\n")

    cube_out = defaultdict(lambda: ['0']*no)
    for oi, oname in enumerate(pla_outputs):
        for cube in minimised[oname]:
            key = ''.join(cube)
            cube_out[key][oi] = '1'

    for in_str, out_list in sorted(cube_out.items()):
        f.write(in_str + ' ' + ''.join(out_list) + '\n')
    f.write(".e\n")

print(f"Written espresso-style output → {esp_path}")

# ─────────────────────────────────────────────────────────────────────────────
# 6.  Build SOP equations: signal_name → list-of-product-terms
#     each product term = list of literal strings  e.g. ['S_0', '!a_i']
# ─────────────────────────────────────────────────────────────────────────────
def cube_to_term(cube, signal_names):
    """Convert a QM cube to a list of literals using full signal names."""
    lits = []
    for bit, name in zip(cube, signal_names):
        if bit == '1':
            lits.append(name)
        elif bit == '0':
            lits.append('!' + name)
        # '-' = don't care → omit
    return lits if lits else ['1']   # tautology guard

equations = {}   # signal_name → [[lit,...], ...]
for oname in pla_outputs:
    cubes = minimised[oname]
    if not cubes:
        equations[oname] = []
    else:
        equations[oname] = [cube_to_term(c, pla_inputs) for c in cubes]

# ─────────────────────────────────────────────────────────────────────────────
# 7.  Structural Verilog
# ─────────────────────────────────────────────────────────────────────────────
def make_module_name(name):
    return ("m_" + name) if name[0].isdigit() else name

def literal_to_wire(lit):
    lit = lit.strip()
    neg = lit.startswith('!')
    sig = lit.lstrip('!')
    return (sig + '_inv') if neg else sig

# Collect all signals that need inverters
negated_signals = set()
for terms in equations.values():
    for term in terms:
        for lit in term:
            if lit.startswith('!'):
                negated_signals.add(lit.lstrip('!'))
negated_signals = sorted(negated_signals)

mod = make_module_name(stem)

with open(sv_path, 'w') as f:

    # ── Module header ──────────────────────────────────────────────────────
    f.write(f"module {mod} (\n")
    port_lines = ["    input  wire clk,", "    input  wire rst,"]
    for inp in input_cols:
        port_lines.append(f"    input  wire {inp},")
    for idx, out in enumerate(output_cols):
        comma = "," if idx < len(output_cols) - 1 else ""
        port_lines.append(f"    output wire {out}{comma}")
    f.write("\n".join(port_lines))
    f.write("\n);\n\n")

    # ── State / NS wires ───────────────────────────────────────────────────
    f.write("// Current-state and next-state wires\n")
    for b in range(n_state_bits):
        f.write(f"wire {state_bit_name(b)};\n")
    f.write("\n")
    for b in range(n_state_bits):
        f.write(f"wire {ns_bit_name(b)};\n")
    f.write("\n")

    # ── State encoding comment ─────────────────────────────────────────────
    f.write("// State encoding\n")
    for sname, sval in state_enc.items():
        f.write(f"//   {sname:20s} = {format(sval, f'0{n_state_bits}b')} (decimal {sval})\n")
    f.write("\n")

    # ── reg1b flip-flops ───────────────────────────────────────────────────
    f.write("// State flip-flops (reg1b, active-low async reset)\n")
    for b in range(n_state_bits):
        f.write(f"reg1b ff_{b} (\n")
        f.write(f"    .clk(clk),\n")
        f.write(f"    .rst(rst),\n")
        f.write(f"    .d({ns_bit_name(b)}),\n")
        f.write(f"    .q({state_bit_name(b)})\n")
        f.write(f");\n")
    f.write("\n")

    # ── Inverters ─────────────────────────────────────────────────────────
    if negated_signals:
        f.write("// Inversion wires and inv1$ instances\n")
        for s in negated_signals:
            f.write(f"wire {s}_inv;\n")
        f.write("\n")
        for s in negated_signals:
            f.write(f"inv1$ inv_{s} ({s}_inv, {s});\n")
        f.write("\n")

    # ── SOP combinational logic ────────────────────────────────────────────
    f.write("// Next-state and output SOP logic\n\n")

    for sig in pla_outputs:
        terms   = equations[sig]
        n_terms = len(terms)

        if n_terms == 0:
            f.write(f"// {sig} = 0  (no ON-set minterms)\n")
            f.write(f"assign {sig} = 1'b0;\n\n")
            continue

        expr_comment = ' | '.join(
            '(' + ' & '.join(t) + ')' if len(t) > 1 else t[0]
            for t in terms
        )
        f.write(f"// {sig} = {expr_comment}\n")

        if n_terms > 1:
            for i in range(n_terms):
                f.write(f"wire {sig}_t{i};\n")
            f.write("\n")

        for i, term in enumerate(terms):
            wires    = [literal_to_wire(lit) for lit in term]
            n_in     = len(wires)
            target   = sig if n_terms == 1 else f"{sig}_t{i}"

            if n_in == 1 and wires[0] == '1':
                f.write(f"assign {target} = 1'b1;\n")
            elif n_in == 1:
                f.write(f"buffer$ {sig}_buf{i if n_terms>1 else ''} ({target}, {wires[0]});\n")
            else:
                tag = f"{sig}_and" if n_terms == 1 else f"{sig}_and{i}"
                f.write(f"and{n_in}$ {tag} ({target}, {', '.join(wires)});\n")

        if n_terms > 1:
            ints = [f"{sig}_t{i}" for i in range(n_terms)]
            f.write(f"or{n_terms}$  {sig}_or  ({sig}, {', '.join(ints)});\n")

        f.write("\n")

    f.write("endmodule\n")

print(f"Generated structural Verilog → {sv_path}")
print()
print("Summary")
print("───────")
print(f"  States            : {n_states} ({n_state_bits} state bits)")
print(f"  PLA               : {pla_path}")
print(f"  Espresso-out      : {esp_path}")
print(f"  Structural Verilog: {sv_path}")
