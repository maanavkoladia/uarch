#!/usr/bin/env python3
"""
gen.py  —  CSV truth-table  →  pure structural Verilog (ROM-based)

Usage:
    python gen.py <input.csv> <output.v> [--module <n>]

Column naming convention in the CSV:
    <n>_i   →  input port
    <n>_o   →  output port

ROM primitive  (32 words × 64-bit output, active-high OE):
    `ROM_32W_64b(__unitName__, __ADDR__, __OE__, __dout__)

Gate macros available (from std-lib header):
    `INV_N  `AND_2 … `AND_12  `OR_2 … `OR_12

Design rules
------------
* N input bits  → 2^(N-5) address banks  (1 bank when N ≤ 5)
  - Lower 5 bits  → ROM .A port (common to every ROM)
  - Upper (N-5) bits → one-hot bank select via AND/INV gate tree (minterm per bank)
* M output bits → ceil(M/64) output slices per bank
* Total ROMs    = num_addr_banks × num_out_slices
* OE logic      : if 1 bank → tied 1'b1
                  if >1 bank → minterm AND gate for each bank (pure structural)
* Output mux    : per output bit: AND each bank's dout bit with its OE,
                  then OR all bank contributions together (gate tree, max 12 inputs
                  per gate, so stages are inserted for >12 banks).
* No == operator, no for-loops in generated Verilog, no $readmemh.
"""

import csv
import sys
import math
import argparse
import os
from itertools import product
from datetime import datetime

MAX_GATE_INPUTS = 12   # library goes up to AND_12 / OR_12

# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def parse_args():
    p = argparse.ArgumentParser(
        description="Generate structural ROM-based Verilog from a CSV truth table."
    )
    p.add_argument("csv_path",  help="Path to input CSV file")
    p.add_argument("v_path",    help="Path to output .v file")
    p.add_argument("--module",  default=None,
                   help="Module name (default: output filename without .v)")
    return p.parse_args()

# ---------------------------------------------------------------------------
# CSV parsing
# ---------------------------------------------------------------------------

def parse_csv(csv_path):
    log_lines = []
    with open(csv_path, newline='') as f:
        reader = csv.DictReader(f)
        headers = reader.fieldnames
        if headers is None:
            raise ValueError("CSV has no header row")

        input_cols  = [h for h in headers if h.strip().endswith('_i')]
        output_cols = [h for h in headers if h.strip().endswith('_o')]

        unknown = [h for h in headers
                   if not h.strip().endswith('_i') and not h.strip().endswith('_o')]
        if unknown:
            log_lines.append(f"WARNING: Columns with unrecognised suffix ignored: {unknown}")

        rows = []
        for row in reader:
            rows.append({k.strip(): v.strip().lower() for k, v in row.items()})

    return input_cols, output_cols, rows, log_lines

# ---------------------------------------------------------------------------
# Truth-table expansion
# ---------------------------------------------------------------------------

def expand_rows(rows, input_cols, output_cols, log_lines):
    truth_table = {}
    duplicates  = []

    for row in rows:
        in_pat = []
        for col in input_cols:
            v = row.get(col, 'x')
            if v not in ('0', '1', 'x'):
                log_lines.append(
                    f"WARNING: Unexpected input value '{v}' in column '{col}', treating as x")
                v = 'x'
            in_pat.append(v)

        out_bits = []
        for col in output_cols:
            v = row.get(col, 'x')
            if v == 'x':
                v = '0'
            elif v not in ('0', '1'):
                log_lines.append(
                    f"WARNING: Unexpected output value '{v}' in column '{col}', treating as 0")
                v = '0'
            out_bits.append(v)

        out_int = int(''.join(out_bits), 2) if out_bits else 0

        dc_positions = [i for i, b in enumerate(in_pat) if b == 'x']
        for dc_vals in product('01', repeat=len(dc_positions)):
            concrete = in_pat[:]
            for pos, val in zip(dc_positions, dc_vals):
                concrete[pos] = val
            addr = int(''.join(concrete), 2)
            if addr in truth_table:
                duplicates.append(addr)
            truth_table[addr] = out_int

    for addr in sorted(set(duplicates)):
        log_lines.append(
            f"WARNING: Address 0x{addr:X} defined more than once (last definition wins)")

    return truth_table

# ---------------------------------------------------------------------------
# ROM layout
# ---------------------------------------------------------------------------

def compute_layout(n_inputs, n_outputs):
    addr_space      = 1 << n_inputs
    num_addr_banks  = max(1, addr_space // 32)
    num_out_slices  = max(1, math.ceil(n_outputs / 64))
    total_roms      = num_addr_banks * num_out_slices
    upper_addr_bits = max(0, n_inputs - 5)
    return num_addr_banks, num_out_slices, total_roms, addr_space, upper_addr_bits

# ---------------------------------------------------------------------------
# ROM content builder
# ---------------------------------------------------------------------------

def build_rom_contents(truth_table, num_addr_banks, num_out_slices,
                        n_outputs, addr_space, log_lines):
    rom_data = [
        [[0] * 32 for _ in range(num_out_slices)]
        for _ in range(num_addr_banks)
    ]

    for addr in range(addr_space):
        if addr not in truth_table:
            log_lines.append(f"INFO: Address 0x{addr:03X} not in CSV; defaulting to 0")
            out_int = 0
        else:
            out_int = truth_table[addr]

        bank = addr // 32
        word = addr  % 32
        out_padded = out_int & ((1 << n_outputs) - 1)

        for sl in range(num_out_slices):
            shift    = (num_out_slices - 1 - sl) * 64
            word_val = (out_padded >> shift) & 0xFFFFFFFFFFFFFFFF
            rom_data[bank][sl][word] = word_val

    return rom_data

# ---------------------------------------------------------------------------
# Gate-tree helpers
# ---------------------------------------------------------------------------

def gate_macro(kind, unit, width, out_wire, in_wires):
    """Emit one AND_N or OR_N macro line."""
    n = len(in_wires)
    assert 2 <= n <= MAX_GATE_INPUTS, f"gate arity {n} out of range"
    args = ", ".join([unit, str(width), out_wire] + list(in_wires))
    return f"    `{kind}_{n}({args})"


def build_gate_tree(kind, prefix, width, leaves, out):
    """
    Reduce `leaves` down to a single wire using a balanced tree of
    AND or OR gates (max MAX_GATE_INPUTS inputs each).
    Intermediate wire declarations are appended to `out`.
    Returns the name of the final output wire.
    """
    if len(leaves) == 1:
        return leaves[0]

    level   = 0
    current = list(leaves)

    while len(current) > 1:
        next_level = []
        group_idx  = 0
        i          = 0
        while i < len(current):
            chunk = current[i : i + MAX_GATE_INPUTS]
            i    += MAX_GATE_INPUTS
            if len(chunk) == 1:
                next_level.append(chunk[0])
                continue
            wire_name = f"{prefix}_l{level}_g{group_idx}"
            group_idx += 1
            out.append(f"    wire [{width-1}:0] {wire_name};")
            out.append(gate_macro(kind, wire_name + "_gate", width, wire_name, chunk))
            next_level.append(wire_name)
        current = next_level
        level  += 1

    return current[0]

# ---------------------------------------------------------------------------
# Wire name helpers
# ---------------------------------------------------------------------------

def rom_name(bank, sl):         return f"rom_b{bank}_s{sl}"
def oe_wire(bank):              return f"oe_bank{bank}"
def dout_wire(bank, sl):        return f"dout_b{bank}_s{sl}"
def inv_addr_wire(bit):         return f"addr_upper_inv{bit}"
def oe_and_name(bank):          return f"oe_bank{bank}_gate"
def masked_wire(bank, sl, bit): return f"masked_b{bank}_s{sl}_bit{bit}"

# ---------------------------------------------------------------------------
# Verilog emission
# ---------------------------------------------------------------------------

def emit_module_header(out, module_name, input_cols, output_cols):
    port_list = ', '.join(input_cols + output_cols)
    out.append(f"module {module_name} ({port_list});")
    out.append("")
    out.append("    // -- Port declarations --")
    for col in input_cols:
        out.append(f"    input  wire {col};")
    for col in output_cols:
        out.append(f"    output wire {col};")
    out.append("")


def emit_internal_wires(out, n_inputs, num_addr_banks, num_out_slices, upper_addr_bits):
    out.append("    // -- Internal wires --")
    out.append(f"    wire [4:0] addr_lower;")
    if upper_addr_bits > 0:
        out.append(f"    wire [{upper_addr_bits-1}:0] addr_upper;")
        for b in range(upper_addr_bits):
            out.append(f"    wire {inv_addr_wire(b)};")
    for b in range(num_addr_banks):
        out.append(f"    wire {oe_wire(b)};")
    for b in range(num_addr_banks):
        for sl in range(num_out_slices):
            out.append(f"    wire [63:0] {dout_wire(b, sl)};")
    out.append("")


def emit_addr_assigns(out, n_inputs, input_cols, upper_addr_bits):
    """Continuous assigns for addr_lower and addr_upper buses."""
    out.append("    // -- Address bus assembly --")

    lower_cols = input_cols[-5:] if len(input_cols) >= 5 else input_cols
    if len(lower_cols) == 1:
        lower_str = f"{{4'b0, {lower_cols[0]}}}"
    elif len(lower_cols) < 5:
        pad = 5 - len(lower_cols)
        inner = ", ".join(lower_cols)
        lower_str = f"{{{pad}'b0, {inner}}}"
    else:
        lower_str = "{" + ", ".join(lower_cols) + "}"

    out.append(f"    assign addr_lower = {lower_str};")

    if upper_addr_bits > 0:
        upper_cols = input_cols[:upper_addr_bits]
        upper_str  = ("{" + ", ".join(upper_cols) + "}") if len(upper_cols) > 1 else upper_cols[0]
        out.append(f"    assign addr_upper = {upper_str};")

    out.append("")


def emit_oe_logic(out, num_addr_banks, upper_addr_bits, input_cols):
    """
    Pure-structural OE one-hot decoder.

    Single bank  : assign oe_bank0 = 1'b1  (constant tie, no logic needed)
    Multiple banks: invert each upper-address bit once, then for each bank B
                   form the minterm using AND of the true or complemented
                   upper-address bits.  No == operator anywhere.
    """
    out.append("    // -- OE decoder (structural, no == operator) --")

    if num_addr_banks == 1:
        out.append(f"    assign {oe_wire(0)} = 1'b1;")
        out.append("")
        return

    # One INV per upper address bit
    for b in range(upper_addr_bits):
        out.append(
            f"    `INV_N({inv_addr_wire(b)}_gate, 1, addr_upper[{b}], {inv_addr_wire(b)})"
        )
    out.append("")

    # Minterm AND gate per bank
    for bank in range(num_addr_banks):
        # bits_str: MSB-first binary representation of `bank`
        # bits_str[k] corresponds to addr_upper[upper_addr_bits-1-k]
        bits_str = format(bank, f'0{upper_addr_bits}b')
        inputs = []
        for k in range(upper_addr_bits):
            addr_bit_idx = upper_addr_bits - 1 - k
            if bits_str[k] == '1':
                inputs.append(f"addr_upper[{addr_bit_idx}]")
            else:
                inputs.append(inv_addr_wire(addr_bit_idx))

        if len(inputs) == 1:
            out.append(f"    assign {oe_wire(bank)} = {inputs[0]};")
        else:
            out.append(
                gate_macro('AND', oe_and_name(bank), 1, oe_wire(bank), inputs)
            )

    out.append("")


def emit_rom_instantiations(out, num_addr_banks, num_out_slices):
    out.append("    // -- ROM instantiations --")
    for b in range(num_addr_banks):
        for sl in range(num_out_slices):
            name = rom_name(b, sl)
            oe   = oe_wire(b)
            dout = dout_wire(b, sl)
            out.append(f"    `ROM_32W_64b({name}, addr_lower, {oe}, {dout})")
    out.append("")


def emit_rom_init(out, rom_data, num_addr_banks, num_out_slices):
    out.append("    // -- ROM data initialisation --")
    out.append("    initial begin")
    for b in range(num_addr_banks):
        for sl in range(num_out_slices):
            name = rom_name(b, sl)
            for word in range(32):
                val = rom_data[b][sl][word]
                out.append(f"        {name}.mem[{word:<2}] = 64'h{val:016X};")
    out.append("    end")
    out.append("")


def emit_output_assigns(out, output_cols, num_addr_banks, num_out_slices, n_outputs):
    """
    For each output bit:
      Single bank  : assign directly from dout (OE is tied 1'b1)
      Multiple banks:
        1. AND each bank's dout bit with that bank's OE  → masked wire
        2. Build an OR gate-tree across all masked wires → output port
    """
    out.append("    // -- Output assignments (structural) --")

    # Pre-declare masked wires
    if num_addr_banks > 1:
        for i in range(n_outputs):
            sl     = (n_outputs - 1 - i) // 64
            bit_sl = (n_outputs - 1 - i) % 64
            for b in range(num_addr_banks):
                out.append(f"    wire {masked_wire(b, sl, bit_sl)};")
        out.append("")

    for i, col in enumerate(output_cols):
        bit_idx = n_outputs - 1 - i   # bit 0 = LSB
        sl      = bit_idx // 64
        bit_sl  = bit_idx % 64

        if num_addr_banks == 1:
            out.append(f"    assign {col} = {dout_wire(0, sl)}[{bit_sl}];")
        else:
            # Step 1: mask per bank
            masked_list = []
            for b in range(num_addr_banks):
                mw = masked_wire(b, sl, bit_sl)
                out.append(
                    gate_macro('AND', mw + "_gate", 1, mw,
                               [oe_wire(b), f"{dout_wire(b, sl)}[{bit_sl}]"])
                )
                masked_list.append(mw)

            # Step 2: OR-tree
            # Use a safe prefix (strip special chars from col name)
            safe = col.replace('[','_').replace(']','_').replace(' ','_')
            final = build_gate_tree('OR', f"out_{safe}", 1, masked_list, out)
            if final != col:
                out.append(f"    assign {col} = {final};")

    out.append("")

# ---------------------------------------------------------------------------
# Top-level
# ---------------------------------------------------------------------------

def generate(csv_path, v_path, module_name):
    log_lines = []

    input_cols, output_cols, rows, parse_logs = parse_csv(csv_path)
    log_lines.extend(parse_logs)

    n_inputs  = len(input_cols)
    n_outputs = len(output_cols)

    if n_inputs  == 0: raise ValueError("No input columns (_i) found")
    if n_outputs == 0: raise ValueError("No output columns (_o) found")

    log_lines.append(f"INFO: {n_inputs} input bits, {n_outputs} output bits")

    truth_table = expand_rows(rows, input_cols, output_cols, log_lines)

    (num_addr_banks, num_out_slices, total_roms,
     addr_space, upper_addr_bits) = compute_layout(n_inputs, n_outputs)

    log_lines.append(
        f"INFO: Address banks={num_addr_banks}, Output slices={num_out_slices}, "
        f"Total ROMs={total_roms}"
    )

    rom_data = build_rom_contents(
        truth_table, num_addr_banks, num_out_slices,
        n_outputs, addr_space, log_lines
    )

    out = []
    out.append(f"// Auto-generated by gen.py on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    out.append(f"// Source CSV : {os.path.basename(csv_path)}")
    out.append(f"// Inputs     : {n_inputs}   Outputs : {n_outputs}")
    out.append(f"// ROM banks  : {num_addr_banks}   Out slices: {num_out_slices}   Total ROMs: {total_roms}")
    out.append("")

    emit_module_header(out, module_name, input_cols, output_cols)
    emit_internal_wires(out, n_inputs, num_addr_banks, num_out_slices, upper_addr_bits)
    emit_addr_assigns(out, n_inputs, input_cols, upper_addr_bits)
    emit_oe_logic(out, num_addr_banks, upper_addr_bits, input_cols)
    emit_rom_instantiations(out, num_addr_banks, num_out_slices)
    emit_rom_init(out, rom_data, num_addr_banks, num_out_slices)
    emit_output_assigns(out, output_cols, num_addr_banks, num_out_slices, n_outputs)

    out.append("endmodule")
    out.append("")

    with open(v_path, 'w') as f:
        f.write('\n'.join(out))

    print(f"Verilog written to : {v_path}")

    log_path = os.path.splitext(v_path)[0] + "_gen.log"
    with open(log_path, 'w') as f:
        f.write(f"gen.py log - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"CSV   : {csv_path}\n")
        f.write(f"Output: {v_path}\n")
        f.write("-" * 60 + "\n")
        for line in log_lines:
            f.write(line + "\n")

    print(f"Log written to     : {log_path}")
    warnings = [l for l in log_lines if l.startswith("WARNING")]
    infos    = [l for l in log_lines if l.startswith("INFO")]
    print(f"  {len(warnings)} warnings, {len(infos)} info messages (see log)")


if __name__ == "__main__":
    args = parse_args()
    module_name = args.module or os.path.splitext(os.path.basename(args.v_path))[0]
    generate(args.csv_path, args.v_path, module_name)
