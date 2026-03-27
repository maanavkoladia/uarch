"""
csv2rom.py  <input.csv>  <output.sv>

Generates ROM-based combinational logic from a truth-table CSV.

CSV conventions (same as csv2rtl.py / fsm2rtl.py):
  *_i  columns  →  input signals   (binary values or X/- for don't-care)
  *_o  columns  →  output signals  (binary values or X/- for don't-care)

Pipeline:
  Stage 1 : Structural CSV validation               (die on error)
  Stage 2 : X-expansion & conflict detection        (die on conflict)
  Stage 3 : Undefined-vector report                 -> <stem>_undefined.txt
  Stage 4 : ROM data file generation                -> rom/<stem>_romRC.data
  Stage 5 : Structural SystemVerilog                -> <output.sv>

ROM primitives available (from library):
  rom4b32w$   — 5-bit address, 32 words,  4-bit  output
  rom32b32w$  — 5-bit address, 32 words, 32-bit  output
  rom64b32w$  — 5-bit address, 32 words, 64-bit  output

Stacking strategy:
  Horizontal (output width > 64 bits):
      Multiple ROM columns with the same address and shared OE.
      Each column covers a 64-bit (or 32-bit or 4-bit) output slice.
      Outputs are simply concatenated onto the output bus.

  Vertical (input bits > 5):
      The full address is split into a 5-bit low slice (A[4:0]) and
      upper bits (A[N-1:5]).  A binary decoder drives the OE of each
      ROM row so that exactly one row is active at a time and all
      others output Z.  The wired-OR of the tri-state outputs gives
      the correct value on the shared bus.

  <=5 input bits:
      Single row, OE tied to 1'b1 permanently.
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
# 0.  CLI
# ─────────────────────────────────────────────────────────────────────────────
if len(sys.argv) != 3:
    die("Usage: python3 csv2rom.py <input.csv> <output.sv>")

csv_path = sys.argv[1]
sv_path  = sys.argv[2]

if not os.path.isfile(csv_path):
    die(f"Input file not found: {csv_path}")

base      = os.path.splitext(csv_path)[0]
stem      = os.path.splitext(os.path.basename(csv_path))[0]
sv_dir    = os.path.dirname(os.path.abspath(sv_path))
rom_dir   = os.path.join(sv_dir, "rom")

p_undef   = base + "_undefined.txt"

log(BANNER)
log(f"  csv2rom pipeline -- {stem}")
log(BANNER)
log(f"  Input CSV  : {csv_path}")
log(f"  Output SV  : {sv_path}")
log(f"  ROM data   : {rom_dir}/")

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
    errors.append("No '_i' input columns found — every input must end with '_i'.")
if not outputs:
    errors.append("No '_o' output columns found — every output must end with '_o'.")

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
    """Expand a CSV row over all don't-care input positions -> list of dicts."""
    dc_pos = [(i, col) for i, col in enumerate(in_cols)
               if row[col].strip() in ('-', 'x', 'X')]
    if not dc_pos:
        return [dict(row)]
    result = []
    for combo in itertools.product('01', repeat=len(dc_pos)):
        new_row = dict(row)
        for val, (_, col) in zip(combo, dc_pos):
            new_row[col] = val
        result.append(new_row)
    return result

# truth_table : input_str (binary, length=ni) -> output_str (length=no)
# Output don't-cares ('x'/'-') are stored as '-' and later resolved to '0'
# when writing ROM data (conservative default).
truth_table  = {}   # str -> str
conflict_log = []

for lineno, row in enumerate(rows, start=2):
    for exp in expand_row(row, inputs):
        in_tup  = tuple(exp[c].strip() for c in inputs)
        out_tup = tuple(exp[c].strip() for c in outputs)
        in_str  = ''.join(in_tup)
        out_str = ''.join(v.replace('x','-').replace('X','-') for v in out_tup)

        if in_str in truth_table:
            existing = truth_table[in_str]
            if existing != out_str:
                conflict_log.append(
                    f"  CONFLICT input={dict(zip(inputs, in_tup))} (CSV row {lineno}):\n"
                    f"    existing = '{existing}'\n"
                    f"    new      = '{out_str}'  (keeping existing)"
                )
        else:
            truth_table[in_str] = out_str

if conflict_log:
    log(f"\n  {len(conflict_log)} conflict(s) (first-seen kept):")
    for c in conflict_log:
        log(c)
    die("Resolve conflicts before proceeding.")
else:
    log(f"  No conflicts detected  OK")

log(f"  Expanded truth table: {len(truth_table)} fully-specified rows")

# ─────────────────────────────────────────────────────────────────────────────
# Stage 3: Undefined-vector report
# ─────────────────────────────────────────────────────────────────────────────
stage(3, "Undefined-vector report")

all_combos      = list(itertools.product('01', repeat=ni))
defined_set     = set(truth_table.keys())
undefined_combos = [''.join(c) for c in all_combos if ''.join(c) not in defined_set]

# Undefined vectors → output 0s (safe default for ROM)
for uv in undefined_combos:
    truth_table[uv] = '0' * no

with open(p_undef, 'w') as f:
    f.write(f"# Undefined input vectors for: {stem}\n")
    f.write(f"# Input signals  : {inputs}\n")
    f.write(f"# Output signals : {outputs}\n")
    f.write(f"# Total possible : {len(all_combos)}\n")
    f.write(f"# Defined in CSV : {len(defined_set)}\n")
    f.write(f"# Undefined      : {len(undefined_combos)}\n\n")
    f.write("# Undefined vectors default to all-zero outputs in the ROM.\n")
    f.write("# Add rows to the CSV to override.\n\n")
    if not undefined_combos:
        f.write("  None — all input combinations explicitly defined.  OK\n")
    else:
        hdr = "  ".join(f"{inp:>12}" for inp in inputs)
        f.write(f"  {'#':>6}  {hdr}   ROM output\n")
        f.write("  " + "-"*(8 + 14*ni + 12) + "\n")
        for idx, uv in enumerate(undefined_combos, 1):
            vals = "  ".join(f"{v:>12}" for v in uv)
            f.write(f"  {idx:>6}  {vals}   {'0'*no}  (all zero)\n")

log(f"  Undefined vectors: {len(undefined_combos)}  (defaulting to 0 in ROM)")
log(f"  Report written   -> {p_undef}  OK")

# ─────────────────────────────────────────────────────────────────────────────
# ROM sizing helpers
# ─────────────────────────────────────────────────────────────────────────────

ROM_ADDR_BITS  = 5          # all primitives have 5-bit address = 32 words
ROM_WORDS      = 32         # 2^5

# Available ROM widths (widest first — prefer fewest column instances)
ROM_WIDTHS     = [64, 32, 4]  # bits

def rom_primitive(width):
    """Return the Verilog module name for a given data width."""
    return f"rom{width}b32w$"

def choose_col_plan(total_bits):
    """
    Decompose total_bits into a list of ROM column widths (widest first).
    Returns list of ints, e.g. 100 bits -> [64, 32, 4]
    """
    remaining = total_bits
    plan = []
    for w in ROM_WIDTHS:
        while remaining >= w:
            plan.append(w)
            remaining -= w
    # remaining should be 0; if CSV output width isn't a multiple of 4, pad
    if remaining > 0:
        # Use the smallest ROM (4-bit) and only use 'remaining' bits of it
        plan.append(4)
        # We track the actual padding separately
    return plan

# ─────────────────────────────────────────────────────────────────────────────
# Stage 4: ROM data file generation
# ─────────────────────────────────────────────────────────────────────────────
stage(4, "ROM data file generation")

os.makedirs(rom_dir, exist_ok=True)

# Vertical dimension: how many 5-bit address rows are needed?
# If ni <= 5: 1 row, use lower ni bits, upper (5-ni) address bits are 0.
# If ni > 5:  ceil(2^ni / 32) rows, each covering a 5-bit window.
#             Row r covers addresses [r*32 .. r*32+31].

n_rows_v = max(1, 2**(ni - ROM_ADDR_BITS)) if ni > ROM_ADDR_BITS else 1
# Total address space this covers (always a power of 2 >= 2^ni)
total_addr = n_rows_v * ROM_WORDS   # = 2^ni when ni>=5, else 32 (with padding)

log(f"  Input bits        : {ni}  ->  address space {2**ni} entries")
log(f"  Vertical rows     : {n_rows_v}  (each covers {ROM_WORDS} addresses)")

# Horizontal dimension: column plan for output width
col_plan   = choose_col_plan(no)
n_cols_h   = len(col_plan)
padded_no  = sum(col_plan)           # may be > no if padding was needed

log(f"  Output bits       : {no}  (padded to {padded_no} for ROM alignment)")
log(f"  Horizontal cols   : {n_cols_h}  widths={col_plan}")
log(f"  Total ROM instances: {n_rows_v * n_cols_h}")

# Build the full ROM content:
# rom_data[row][col] = list of hex strings, one per word (32 per row)
# Each hex string encodes col_plan[col] bits.

# First build a flat array indexed by full address (0 .. 2^ni - 1)
# output_bits[addr] = string of 'no' bits (MSB first)
output_bits = {}
for addr_int in range(2**ni):
    addr_str = format(addr_int, f'0{ni}b')
    raw      = truth_table.get(addr_str, '0' * no)
    # Replace any remaining don't-cares with 0
    resolved = raw.replace('-', '0')
    output_bits[addr_int] = resolved

# For each ROM instance (row r, col c), extract the relevant bit slice
# and format as hex.
rom_files = {}   # (r, c) -> path

for r in range(n_rows_v):
    for c, col_width in enumerate(col_plan):
        # Bit slice within the output word: col c covers bits [hi:lo]
        # Columns go MSB -> LSB  (col 0 = most-significant bits)
        hi = padded_no - sum(col_plan[:c])         # exclusive upper index
        lo = padded_no - sum(col_plan[:c+1])       # inclusive lower index
        # (bits are indexed MSB=0 in our string)

        hex_digits = col_width // 4   # e.g. 64-bit -> 16 hex chars

        words = []
        for word_idx in range(ROM_WORDS):
            addr_int = r * ROM_WORDS + word_idx
            if addr_int < 2**ni:
                bits_str = output_bits[addr_int]
                # Pad to padded_no if output_bits is shorter (shouldn't happen)
                bits_str = bits_str.ljust(padded_no, '0')[:padded_no]
                # Extract slice [hi-1 downto lo] from the MSB-first string
                # MSB-first: index 0 is bit (no-1), index (no-1) is bit 0
                # Our padded string has padded_no chars; slice indices:
                slice_start = padded_no - hi
                slice_end   = padded_no - lo
                bit_slice   = bits_str[slice_start:slice_end]
                # bit_slice may be shorter than col_width if padding
                bit_slice   = bit_slice.ljust(col_width, '0')
            else:
                # Address out of range (padding) -> all zeros
                bit_slice = '0' * col_width

            word_val = int(bit_slice, 2)
            words.append(format(word_val, f'0{hex_digits}x'))

        # Write readmemh file
        fname     = f"{stem}_rom{r+1}{c+1}.data"
        fpath     = os.path.join(rom_dir, fname)
        rom_files[(r, c)] = fname
        with open(fpath, 'w') as f:
            f.write(f"// ROM data for {stem}  row={r+1} col={c+1}\n")
            f.write(f"// Covers input address range [{r*ROM_WORDS} .. {r*ROM_WORDS+ROM_WORDS-1}]\n")
            f.write(f"// Output bits [{hi-1} downto {lo}]  ({col_width} bits, {hex_digits} hex digits per word)\n")
            f.write(f"// Format: readmemh — one hex word per line (addr 0 first)\n")
            for word in words:
                f.write(word + "\n")
        log(f"  Written: rom/{fname}  ({ROM_WORDS} words x {col_width} bits)")

# ─────────────────────────────────────────────────────────────────────────────
# Stage 5: Structural SystemVerilog
# ─────────────────────────────────────────────────────────────────────────────
stage(5, "Structural SystemVerilog generation")

def make_module_name(name):
    return ("m_" + name) if name[0].isdigit() else name

def clean(sig):
    return sig.replace('[','_').replace(']','')

mod = make_module_name(stem)
need_decoder = ni > ROM_ADDR_BITS  # vertical stacking requires OE decoder

with open(sv_path, 'w') as f:

    # ── File header ───────────────────────────────────────────────────────────
    f.write(f"// {'='*70}\n")
    f.write(f"// ROM-based combinational block : {stem}\n")
    f.write(f"// Tool: csv2rom.py  (auto-generated -- do not hand-edit)\n")
    f.write(f"//\n")
    f.write(f"// Configuration:\n")
    f.write(f"//   Input  bits     : {ni}\n")
    f.write(f"//   Output bits     : {no}  (ROM width {padded_no} bits, padded)\n")
    f.write(f"//   Vertical rows   : {n_rows_v}  (5-bit address slices)\n")
    f.write(f"//   Horizontal cols : {n_cols_h}  widths={col_plan}\n")
    f.write(f"//   ROM primitive(s): {sorted(set(rom_primitive(w) for w in col_plan))}\n")
    if undefined_combos:
        f.write(f"//\n")
        f.write(f"// WARNING: {len(undefined_combos)} input vector(s) had no CSV row.\n")
        f.write(f"//          Those addresses are programmed to all-zero outputs.\n")
        f.write(f"//          See: {p_undef}\n")
    f.write(f"// {'='*70}\n\n")

    # ── Truth-table comment ───────────────────────────────────────────────────
    in_hdr  = "  ".join(f"{c:>10}" for c in inputs)
    out_hdr = "  ".join(f"{c:>10}" for c in outputs)
    sep     = "-" * (len(in_hdr) + len(out_hdr) + 10)
    f.write(f"// Truth table (from CSV, X-expanded, undefined -> 0)\n")
    f.write(f"// {sep}\n")
    f.write(f"//  {in_hdr}  |  {out_hdr}\n")
    f.write(f"// {sep}\n")
    for addr_int in range(2**ni):
        addr_str = format(addr_int, f'0{ni}b')
        out_str  = output_bits[addr_int].replace('-','0')
        in_vals  = "  ".join(f"{v:>10}" for v in addr_str)
        out_vals = "  ".join(f"{v:>10}" for v in out_str)
        marker   = "" if addr_str in defined_set else "  // UNDEFINED->0"
        f.write(f"//  {in_vals}  |  {out_vals}{marker}\n")
    f.write(f"// {sep}\n\n")

    # ── Module declaration ────────────────────────────────────────────────────
    f.write(f"module {mod} (\n")
    port_lines = []
    for idx, inp in enumerate(inputs):
        comma = "," if (idx < ni - 1) or (no > 0) else ""
        port_lines.append(f"    input  wire {clean(inp)}{comma}")
    for idx, out in enumerate(outputs):
        comma = "," if idx < no - 1 else ""
        port_lines.append(f"    output wire {clean(out)}{comma}")
    f.write("\n".join(port_lines))
    f.write("\n);\n\n")

    # ── Address bus: concatenate all inputs (MSB first = inputs[0]) ───────────
    addr_bus_width = ni
    addr_bits_str  = ", ".join(clean(inp) for inp in inputs)
    f.write(f"// Full address bus (MSB = {inputs[0]}, LSB = {inputs[-1]})\n")
    f.write(f"wire [{ni-1}:0] addr_bus;\n")
    f.write(f"assign addr_bus = {{{addr_bits_str}}};\n\n")

    # Low 5 bits of address go to all ROMs (A input)
    f.write(f"// Lower 5 address bits (ROM A input)\n")
    if ni >= ROM_ADDR_BITS:
        f.write(f"wire [4:0] rom_addr = addr_bus[4:0];\n\n")
    else:
        # Fewer than 5 bits: zero-extend
        f.write(f"wire [4:0] rom_addr = {{{{({ROM_ADDR_BITS-ni})'b0}}, addr_bus}};\n\n")

    # ── OE decoder for vertical stacking ─────────────────────────────────────
    upper_bits = ni - ROM_ADDR_BITS   # number of bits selecting the row

    if need_decoder:
        f.write(f"// Row-select decoder: upper {upper_bits} address bit(s) -> OE per row\n")
        f.write(f"// Only one ROM row drives the bus at a time (others output Z).\n")
        f.write(f"wire [{upper_bits-1}:0] row_sel = addr_bus[{ni-1}:{ROM_ADDR_BITS}];\n")
        for r in range(n_rows_v):
            f.write(f"wire oe_row{r+1} = (row_sel == {upper_bits}'d{r});\n")
        f.write("\n")
    else:
        # Single row — OE always asserted
        f.write(f"// Single ROM row — OE permanently asserted (<=5 input bits)\n")
        f.write(f"wire oe_row1 = 1'b1;\n\n")

    # ── ROM instance wires ────────────────────────────────────────────────────
    # Each ROM row contributes a tri-state bus segment.
    # Columns are concatenated to form the full output word.
    # When ni > 5: multiple rows share the same output bus wires (tri-state).

    # output_bus: one wire per output bit, driven tri-state from ROMs
    # We'll declare them as 'wire' (Verilog tri-state resolution).
    f.write(f"// Output bus wires (tri-state, resolved by ROM OE)\n")
    f.write(f"wire [{padded_no-1}:0] rom_out_bus;\n\n")

    # Instantiate all ROMs
    f.write(f"// ROM instances  (ROMrc: r=row, c=column)\n\n")
    for r in range(n_rows_v):
        for c, col_width in enumerate(col_plan):
            inst_name  = f"ROM{r+1}{c+1}"
            prim       = rom_primitive(col_width)
            data_fname = rom_files[(r, c)]

            # Bit slice of rom_out_bus this column drives
            hi_bit = padded_no - 1 - sum(col_plan[:c])
            lo_bit = padded_no      - sum(col_plan[:c+1])

            f.write(f"// Row {r+1}, Col {c+1}: covers addr [{r*ROM_WORDS}..{r*ROM_WORDS+ROM_WORDS-1}], "
                    f"output bits [{hi_bit}:{lo_bit}]\n")
            f.write(f"{prim} {inst_name} (\n")
            f.write(f"    .A   (rom_addr),\n")
            f.write(f"    .OE  (oe_row{r+1}),\n")
            f.write(f"    .DOUT(rom_out_bus[{hi_bit}:{lo_bit}])\n")
            f.write(f");\n")
            f.write(f"initial readmemh(\"rom/{data_fname}\", {inst_name}.mem);\n\n")

    # ── Connect ROM output bus to module output ports ─────────────────────────
    f.write(f"// Connect ROM output bus bits to named output ports\n")
    f.write(f"// Output signals are MSB-first in col order; LSB-aligned if padded.\n")

    # Map: each output signal is one bit.
    # outputs[0] is the MSB of the no-bit output word.
    # rom_out_bus is padded_no wide; outputs occupy the lowest 'no' bits.
    pad_offset = padded_no - no   # number of padding bits at the top of rom_out_bus

    for idx, out in enumerate(outputs):
        # outputs[0] -> rom_out_bus bit (padded_no-1 - pad_offset - 0) = no-1
        # outputs[k] -> rom_out_bus bit (no - 1 - k)
        bus_bit = no - 1 - idx + pad_offset  # MSB of output word -> highest bus bit after pad
        # Simpler: output index 0 (MSB) maps to bus bit (padded_no-1-pad_offset) = no-1
        bus_bit = (no - 1 - idx)   # bit index within the no-bit logical word
        # Adjust for padding (padding occupies top bits of rom_out_bus)
        rom_bit = bus_bit   # padding is at the TOP of the bus (high bits); outputs fill from bit 0 up
        # Column plan goes MSB-first: col 0 drives [padded_no-1 : padded_no-col_plan[0]]
        # outputs[0] = MSB = rom_out_bus[no-1+pad_offset]  but pad is at top...
        # Let's be explicit:
        #   outputs[idx] corresponds to logical output bit (no-1-idx)
        #   rom_out_bus layout: [padded_no-1 : pad_offset] = output bits [no-1:0]
        #                       [pad_offset-1 : 0]         = padding zeros (if any)
        rom_bus_bit = (no - 1 - idx) + pad_offset  # bit position in rom_out_bus
        f.write(f"assign {clean(out)} = rom_out_bus[{rom_bus_bit}];\n")

    f.write("\nendmodule\n")

log(f"  Structural Verilog written -> {sv_path}  OK")

# ─────────────────────────────────────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────────────────────────────────────
log()
log(BANNER)
log("  Pipeline complete -- output files:")
log(BANNER)
manifest = [
    ("Undefined vectors",  p_undef),
    ("Structural Verilog", sv_path),
]
for label, path in manifest:
    size = os.path.getsize(path) if os.path.exists(path) else 0
    log(f"  {label:<22}  {path}  ({size} bytes)")
log(f"  {'ROM data files':<22}  {rom_dir}/  ({n_rows_v * n_cols_h} files)")
for r in range(n_rows_v):
    for c in range(n_cols_h):
        fname = rom_files[(r, c)]
        fpath = os.path.join(rom_dir, fname)
        size  = os.path.getsize(fpath) if os.path.exists(fpath) else 0
        log(f"    row{r+1} col{c+1}  ->  rom/{fname}  ({size} bytes)")
log()
