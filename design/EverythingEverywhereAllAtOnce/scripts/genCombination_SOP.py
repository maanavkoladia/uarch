"""
csv2rtl.py  <input.csv>  <output.sv>

Pipeline:
  1. Parse CSV (columns ending _i = inputs, _o = outputs)
  2. Write  <stem>.pla
  3. Minimise with built-in Quine-McCluskey  → <stem>_espresso.out
  4. Generate structural Verilog              → <output.sv>

No external dependencies required.
"""

import sys, os, csv, itertools
from collections import defaultdict

# ─────────────────────────────────────────────────────────────────────────────
# 0.  CLI
# ─────────────────────────────────────────────────────────────────────────────
if len(sys.argv) != 3:
    print("Usage: python3 csv2rtl.py <input.csv> <output.sv>")
    sys.exit(1)

csv_path  = sys.argv[1]
sv_path   = sys.argv[2]
stem      = os.path.splitext(os.path.basename(csv_path))[0]
pla_path  = os.path.splitext(csv_path)[0] + ".pla"
esp_path  = os.path.splitext(csv_path)[0] + "_espresso.out"

# ─────────────────────────────────────────────────────────────────────────────
# 1.  Parse CSV
# ─────────────────────────────────────────────────────────────────────────────
with open(csv_path, newline='') as fh:
    reader = csv.DictReader(fh)
    headers = reader.fieldnames
    rows    = list(reader)

inputs  = [h for h in headers if h.endswith('_i')]
outputs = [h for h in headers if h.endswith('_o')]

if not inputs:
    sys.exit("ERROR: No columns ending with '_i' found.")
if not outputs:
    sys.exit("ERROR: No columns ending with '_o' found.")

ni, no = len(inputs), len(outputs)
print(f"Inputs  ({ni}): {inputs}")
print(f"Outputs ({no}): {outputs}")

# Build minterms per output  (value "1" → ON-set, "0" or "" → OFF, "-" → DC)
on_sets = defaultdict(list)   # output_idx → [input_tuple, ...]
dc_sets = defaultdict(list)

for row in rows:
    in_vec = tuple(row[c].strip() for c in inputs)
    # skip rows with non-binary input values
    if any(v not in ('0','1') for v in in_vec):
        continue
    for oi, out_col in enumerate(outputs):
        val = row[out_col].strip()
        if val == '1':
            on_sets[oi].append(in_vec)
        elif val in ('-', 'x', 'X'):
            dc_sets[oi].append(in_vec)

# ─────────────────────────────────────────────────────────────────────────────
# 2.  Write PLA
# ─────────────────────────────────────────────────────────────────────────────
def write_pla(path, inputs, outputs, on_sets, dc_sets, rows_bin):
    ni, no = len(inputs), len(outputs)
    with open(path, 'w') as f:
        f.write(f".i {ni}\n")
        f.write(f".o {no}\n")
        f.write(f".ilb {' '.join(inputs)}\n")
        f.write(f".ob  {' '.join(outputs)}\n")
        f.write(".type fr\n")

        seen = set()
        for row in rows_bin:
            in_vec = tuple(row[c].strip() for c in inputs)
            if any(v not in ('0','1') for v in in_vec):
                continue
            key = in_vec
            if key in seen:
                continue
            seen.add(key)
            out_vec = ''.join(
                row[c].strip() if row[c].strip() in ('0','1','-') else '0'
                for c in outputs
            )
            f.write(''.join(in_vec) + ' ' + out_vec + '\n')

        f.write(".e\n")

write_pla(pla_path, inputs, outputs, on_sets, dc_sets, rows)
print(f"Written PLA → {pla_path}")

# ─────────────────────────────────────────────────────────────────────────────
# 3.  Quine-McCluskey minimiser (pure Python, per output)
# ─────────────────────────────────────────────────────────────────────────────

def qm_minimise(on_set, dc_set, ni):
    """
    Returns a list of prime implicant cubes (as strings of '0','1','-')
    that cover the on_set using Quine-McCluskey + Petrick's method.
    """
    # Represent cubes as tuples of chars
    on_cubes = [tuple(v) for v in on_set]
    dc_cubes = [tuple(v) for v in dc_set]
    all_cubes = list(set(on_cubes) | set(dc_cubes))

    if not all_cubes:
        return []

    def can_merge(a, b):
        diffs = [i for i in range(ni) if a[i] != b[i]]
        if len(diffs) != 1:
            return None
        if a[diffs[0]] == '-' or b[diffs[0]] == '-':
            return None
        merged = list(a)
        merged[diffs[0]] = '-'
        return tuple(merged)

    def covers(implicant, minterm):
        return all(i == '-' or i == m for i, m in zip(implicant, minterm))

    # Iterative merging
    groups = all_cubes
    prime_implicants = set()
    while groups:
        merged_set = set()
        used       = set()
        new_groups = []
        g = list(set(groups))
        for i in range(len(g)):
            for j in range(i+1, len(g)):
                m = can_merge(g[i], g[j])
                if m is not None:
                    merged_set.add(m)
                    used.add(i); used.add(j)
        for i, cube in enumerate(g):
            if i not in used:
                prime_implicants.add(cube)
        groups = list(merged_set)

    prime_implicants = list(prime_implicants)

    # Essential prime implicant cover (Petrick's simplified greedy)
    if not on_cubes:
        return []

    uncovered = list(on_cubes)
    chosen    = []

    # Sort PIs by number of minterms covered (descending) then by dashes (descending)
    def score(pi):
        return (sum(1 for m in uncovered if covers(pi, m)),
                pi.count('-'))

    remaining_pis = list(prime_implicants)
    while uncovered:
        if not remaining_pis:
            break
        remaining_pis.sort(key=score, reverse=True)
        best = remaining_pis.pop(0)
        if any(covers(best, m) for m in uncovered):
            chosen.append(best)
            uncovered = [m for m in uncovered if not covers(best, m)]

    return chosen   # list of tuples

def cube_to_expr(cube, input_names):
    """Convert a cube tuple to a SOP literal string, e.g. 'a_i & !b_i'."""
    lits = []
    for bit, name in zip(cube, input_names):
        if bit == '1':
            lits.append(name)
        elif bit == '0':
            lits.append('!' + name)
        # '-' → don't care, skip
    if not lits:
        return '1'   # tautology
    return ' & '.join(lits)

# Minimise each output
minimised = {}   # output_name → list-of-cubes (tuples)

for oi, out_col in enumerate(outputs):
    on  = on_sets[oi]
    dc  = dc_sets[oi]
    if not on:
        minimised[out_col] = []
    else:
        minimised[out_col] = qm_minimise(on, dc, ni)

# ─────────────────────────────────────────────────────────────────────────────
# 4.  Write espresso-style .out file
# ─────────────────────────────────────────────────────────────────────────────
with open(esp_path, 'w') as f:
    f.write(f"# Minimised SOP (Quine-McCluskey) for {stem}\n")
    f.write(f".i {ni}\n")
    f.write(f".o {no}\n")
    f.write(f".ilb {' '.join(inputs)}\n")
    f.write(f".ob  {' '.join(outputs)}\n")
    f.write(".type f\n")

    # Collect all distinct cubes with their output masks
    cube_out = defaultdict(lambda: ['0']*no)

    for oi, out_col in enumerate(outputs):
        for cube in minimised[out_col]:
            key = ''.join(cube)
            cube_out[key][oi] = '1'

    for in_str, out_list in cube_out.items():
        f.write(in_str + ' ' + ''.join(out_list) + '\n')

    f.write(".e\n")

print(f"Written espresso-style output → {esp_path}")

# ─────────────────────────────────────────────────────────────────────────────
# 5.  Structural Verilog generation  (reuses / extends original genV logic)
# ─────────────────────────────────────────────────────────────────────────────

def make_module_name(name):
    return ("m_" + name) if name[0].isdigit() else name

def clean(sig):
    return sig.replace('[','_').replace(']','')

def literal_to_wire(lit):
    lit = lit.strip()
    neg = lit.startswith('!')
    sig = clean(lit.lstrip('!'))
    return (sig + '_inv') if neg else sig

# Build equations dict:  output_name → list-of-product-terms (each = list-of-literals)
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
        if not lits:
            lits = ['1']   # constant-1 (tautology cube)
        terms.append(lits)
    equations[out_col] = terms

# Which input signals need inverters?
negated_inputs = set()
for terms in equations.values():
    for term in terms:
        for lit in term:
            if lit.startswith('!'):
                sig = clean(lit.lstrip('!'))
                negated_inputs.add(sig)

with open(sv_path, 'w') as fout:
    mod = make_module_name(stem)
    fout.write(f"module {mod} (\n")
    port_lines = (
        [f"    output {clean(o)}" for o in outputs] +
        [f"    input  {clean(i)}" for i in inputs]
    )
    fout.write(",\n".join(port_lines))
    fout.write("\n);\n\n")

    inv_wires = sorted(negated_inputs)
    if inv_wires:
        for w in inv_wires:
            fout.write(f"wire {w}_inv;\n")
        fout.write("\n")
        for w in inv_wires:
            fout.write(f"inv1$ inv_{w} ({w}_inv, {w});\n")
        fout.write("\n")

    for out_col in outputs:
        out   = clean(out_col)
        terms = equations[out_col]
        n_terms = len(terms)

        if n_terms == 0:
            fout.write(f"// {out} = 0  (no ON-set minterms)\n")
            fout.write(f"assign {out} = 1'b0;\n\n")
            continue

        # Stringify for comment
        expr_str = ' | '.join(
            '(' + ' & '.join(t) + ')' if len(t)>1 else (t[0] if t else '1')
            for t in terms
        )
        fout.write(f"// {out} = {expr_str}\n")

        if n_terms > 1:
            for i in range(n_terms):
                fout.write(f"wire {out}_t{i};\n")
            fout.write("\n")

        for i, term in enumerate(terms):
            wires    = [literal_to_wire(lit) for lit in term]
            n_inputs = len(wires)
            target   = out if n_terms == 1 else f"{out}_t{i}"

            if n_inputs == 1 and wires[0] == '1':
                fout.write(f"assign {target} = 1'b1;\n")
            elif n_inputs == 1:
                fout.write(f"assign {target} = {wires[0]};\n")
            else:
                tag = f"{out}_and" if n_terms == 1 else f"{out}_and{i}"
                fout.write(f"and{n_inputs}$ {tag} ({target}, {', '.join(wires)});\n")

        if n_terms > 1:
            ints = [f"{out}_t{i}" for i in range(n_terms)]
            fout.write(f"or{n_terms}$  {out}_or  ({out}, {', '.join(ints)});\n")

        fout.write("\n")

    fout.write("endmodule\n")

print(f"Generated structural Verilog → {sv_path}")
print()
print("Summary")
print("───────")
print(f"  PLA file          : {pla_path}")
print(f"  Espresso-out file : {esp_path}")
print(f"  Structural Verilog: {sv_path}")
