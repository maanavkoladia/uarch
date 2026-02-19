#!/usr/bin/env python3
import csv
import sys
import math
import itertools

if len(sys.argv) != 3:
    print(f"Usage: {sys.argv[0]} input.csv output_basename")
    sys.exit(1)

input_csv = sys.argv[1]
output_basename = sys.argv[2]

# Read CSV
with open(input_csv, newline='') as csvfile:
    reader = csv.DictReader(csvfile)
    rows = list(reader)
    fieldnames = reader.fieldnames

# Collect unique states
states_set = set(row['state'].strip() for row in rows)
nextstates_set = set(row['nextstate'].strip() for row in rows)

# Validate nextstates
unknown_ns = nextstates_set - states_set
if unknown_ns:
    raise ValueError(f"Nextstates not in states: {unknown_ns}")

# Assign sequential binary encodings
states_list = sorted(states_set)
n_state_bits = math.ceil(math.log2(len(states_list)))
state_encoding = {state: i for i, state in enumerate(states_list)}

print(f"States: {states_list}")
print(f"State encoding ({n_state_bits} bits): {state_encoding}")

# Identify columns
input_cols = [c for c in fieldnames if c.endswith('_i')]
output_cols = [c for c in fieldnames if c.endswith('_o')]

# Total input/output bits (state bits + input bits for ROM address)
n_input_bits = len(input_cols)
n_output_bits = len(output_cols)
n_rom_addr_bits = n_state_bits + n_input_bits
n_rom_data_bits = n_state_bits + n_output_bits  # nextstate + outputs

print(f"Input signals: {input_cols} ({n_input_bits} bits)")
print(f"Output signals: {output_cols} ({n_output_bits} bits)")
print(f"ROM address width: {n_rom_addr_bits} bits")
print(f"ROM data width: {n_rom_data_bits} bits")

# Function to expand don't cares
def expand_dont_care(bits):
    positions = [i for i, b in enumerate(bits) if b.lower() == 'x' or b == '-']
    if not positions:
        return [bits]
    expansions = []
    for combo in itertools.product('01', repeat=len(positions)):
        new_bits = list(bits)
        for pos, val in zip(positions, combo):
            new_bits[pos] = val
        expansions.append(''.join(new_bits))
    return expansions

# Build full truth table
truth_table = {}  # address -> data

for row in rows:
    # Build input pattern (state + inputs)
    state_bits = format(state_encoding[row['state'].strip()], f'0{n_state_bits}b')
    input_bits = ''.join([row[col].strip() for col in input_cols])
    
    # Build output pattern (nextstate + outputs)
    nextstate_bits = format(state_encoding[row['nextstate'].strip()], f'0{n_state_bits}b')
    output_bits = ''.join([row[col].strip() for col in output_cols])
    
    # Combine
    address_pattern = state_bits + input_bits
    data_pattern = nextstate_bits + output_bits
    
    # Expand don't cares in address
    for expanded_addr in expand_dont_care(address_pattern):
        addr_int = int(expanded_addr, 2)
        data_int = int(data_pattern, 2)
        truth_table[addr_int] = data_int

# Fill in missing addresses with default (stay in state 0, outputs 0)
rom_size = 2 ** n_rom_addr_bits
for addr in range(rom_size):
    if addr not in truth_table:
        truth_table[addr] = 0  # Default: go to state 0, outputs all 0

# Determine ROM configuration
# Each ROM is 5-bit address (32 words)
# Need to handle > 5 bit addresses with multiple ROMs and muxing
# Need to handle > 64 bit data width by stacking ROMs horizontally

ROM_ADDR_BITS = 5
ROM_MAX_WIDTH = 64

if n_rom_addr_bits <= ROM_ADDR_BITS:
    # Simple case: single ROM or stacked ROMs for width
    n_addr_roms = 1
    addr_select_bits = 0
else:
    # Need multiple ROMs with muxing
    n_addr_roms = 2 ** (n_rom_addr_bits - ROM_ADDR_BITS)
    addr_select_bits = n_rom_addr_bits - ROM_ADDR_BITS

# Determine data width ROMs needed
if n_rom_data_bits <= 4:
    rom_width = 4
    rom_module = "rom4b32w$"
elif n_rom_data_bits <= 32:
    rom_width = 32
    rom_module = "rom32b32w$"
elif n_rom_data_bits <= 64:
    rom_width = 64
    rom_module = "rom64b32w$"
else:
    # Need to stack multiple 64-bit ROMs horizontally
    rom_width = 64
    rom_module = "rom64b32w$"

n_width_roms = math.ceil(n_rom_data_bits / rom_width)
total_roms = n_addr_roms * n_width_roms

print(f"ROM configuration: {n_addr_roms} address ROMs x {n_width_roms} width ROMs = {total_roms} total ROMs")
print(f"Using {rom_module} ({rom_width}-bit data)")

# Generate HEX files for each ROM
hex_files = []
for addr_rom_idx in range(n_addr_roms):
    for width_rom_idx in range(n_width_roms):
        hex_filename = f"{output_basename}_rom{addr_rom_idx}_{width_rom_idx}.hex"
        hex_files.append(hex_filename)
        
        with open(hex_filename, 'w') as f:
            for local_addr in range(32):  # 32 words per ROM
                # Calculate global address
                global_addr = (addr_rom_idx << ROM_ADDR_BITS) | local_addr
                
                if global_addr < rom_size:
                    data = truth_table.get(global_addr, 0)
                    # Extract the portion for this width ROM
                    data_start_bit = width_rom_idx * rom_width
                    data_end_bit = min(data_start_bit + rom_width, n_rom_data_bits)
                    mask = (1 << (data_end_bit - data_start_bit)) - 1
                    data_slice = (data >> data_start_bit) & mask
                    
                    # Write in hex format (pad to rom_width/4 hex digits)
                    hex_digits = rom_width // 4
                    f.write(f"{data_slice:0{hex_digits}x}\n")
                else:
                    # Padding for unused addresses
                    hex_digits = rom_width // 4
                    f.write(f"{'0' * hex_digits}\n")

print(f"Generated {len(hex_files)} HEX files")

# Generate Verilog module
verilog_filename = f"{output_basename}.sv"
module_name = output_basename

with open(verilog_filename, 'w') as f:
    # Module header
    f.write(f"module {module_name} (\n")
    f.write(f"    input wire clk,\n")
    f.write(f"    input wire reset,\n")
    
    # Input ports
    for col in input_cols:
        f.write(f"    input wire {col},\n")
    
    # Output ports
    for i, col in enumerate(output_cols):
        if i < len(output_cols) - 1:
            f.write(f"    output wire {col},\n")
        else:
            f.write(f"    output wire {col}\n")
    f.write(f");\n\n")
    
    # State registers
    f.write(f"    localparam STATE_SIZE = {n_state_bits};\n\n")
    f.write(f"    wire [STATE_SIZE-1:0] state;\n")
    f.write(f"    wire [STATE_SIZE-1:0] nextstate;\n\n")
    
    # State flip-flops
    f.write(f"    genvar i;\n")
    f.write(f"    generate\n")
    f.write(f"        for (i = 0; i < STATE_SIZE; i = i + 1) begin : state_regs\n")
    f.write(f"            reg1b ff (\n")
    f.write(f"                .clk(clk),\n")
    f.write(f"                .rst(reset),\n")
    f.write(f"                .d(nextstate[i]),\n")
    f.write(f"                .q(state[i])\n")
    f.write(f"            );\n")
    f.write(f"        end\n")
    f.write(f"    endgenerate\n\n")
    
    # ROM address construction
    f.write(f"    // ROM address = {{state, inputs}}\n")
    f.write(f"    wire [{n_rom_addr_bits-1}:0] rom_addr;\n")
    if n_input_bits > 0:
        input_concat = ', '.join(input_cols)
        f.write(f"    assign rom_addr = {{state, {input_concat}}};\n\n")
    else:
        f.write(f"    assign rom_addr = state;\n\n")
    
    # ROM data output
    f.write(f"    // ROM data = {{nextstate, outputs}}\n")
    f.write(f"    wire [{n_rom_data_bits-1}:0] rom_data;\n\n")
    
    # Instantiate ROMs
    if n_addr_roms == 1:
        # Simple case: single ROM address
        for width_idx in range(n_width_roms):
            rom_inst_name = f"ROM_{width_idx}"
            f.write(f"    wire [{rom_width-1}:0] {rom_inst_name}_out;\n")
            f.write(f"    {rom_module} {rom_inst_name} (\n")
            f.write(f"        .A(rom_addr[{ROM_ADDR_BITS-1}:0]),\n")
            f.write(f"        .OE(1'b1),\n")
            f.write(f"        .DOUT({rom_inst_name}_out)\n")
            f.write(f"    );\n")
            hex_file = f"{output_basename}_rom0_{width_idx}.hex"
            f.write(f"    initial $readmemh(\"{hex_file}\", {rom_inst_name}.mem);\n\n")
        
        # Concatenate ROM outputs
        if n_width_roms == 1:
            f.write(f"    assign rom_data = ROM_0_out[{n_rom_data_bits-1}:0];\n\n")
        else:
            rom_concat = ', '.join([f"ROM_{i}_out" for i in range(n_width_roms-1, -1, -1)])
            f.write(f"    assign rom_data = {{{rom_concat}}};\n\n")
    else:
        # Multiple ROMs with muxing
        for addr_idx in range(n_addr_roms):
            for width_idx in range(n_width_roms):
                rom_inst_name = f"ROM_{addr_idx}_{width_idx}"
                f.write(f"    wire [{rom_width-1}:0] {rom_inst_name}_out;\n")
                f.write(f"    {rom_module} {rom_inst_name} (\n")
                f.write(f"        .A(rom_addr[{ROM_ADDR_BITS-1}:0]),\n")
                f.write(f"        .OE(1'b1),\n")
                f.write(f"        .DOUT({rom_inst_name}_out)\n")
                f.write(f"    );\n")
                hex_file = f"{output_basename}_rom{addr_idx}_{width_idx}.hex"
                f.write(f"    initial $readmemh(\"{hex_file}\", {rom_inst_name}.mem);\n\n")
        
        # Mux the ROM outputs based on upper address bits
        f.write(f"    wire [{addr_select_bits-1}:0] rom_select;\n")
        f.write(f"    assign rom_select = rom_addr[{n_rom_addr_bits-1}:{ROM_ADDR_BITS}];\n\n")
        
        # For each width column, mux across address ROMs
        for width_idx in range(n_width_roms):
            mux_out_name = f"rom_data_col{width_idx}"
            f.write(f"    wire [{rom_width-1}:0] {mux_out_name};\n")
            
            # Determine mux type based on number of inputs
            if n_addr_roms == 2:
                f.write(f"    mux2_{rom_width}$ mux_col{width_idx} (\n")
                f.write(f"        .Y({mux_out_name}),\n")
                f.write(f"        .IN0(ROM_0_{width_idx}_out),\n")
                f.write(f"        .IN1(ROM_1_{width_idx}_out),\n")
                f.write(f"        .S0(rom_select[0])\n")
                f.write(f"    );\n\n")
            elif n_addr_roms == 4:
                f.write(f"    mux4_{rom_width}$ mux_col{width_idx} (\n")
                f.write(f"        .Y({mux_out_name}),\n")
                f.write(f"        .IN0(ROM_0_{width_idx}_out),\n")
                f.write(f"        .IN1(ROM_1_{width_idx}_out),\n")
                f.write(f"        .IN2(ROM_2_{width_idx}_out),\n")
                f.write(f"        .IN3(ROM_3_{width_idx}_out),\n")
                f.write(f"        .S0(rom_select[0]),\n")
                f.write(f"        .S1(rom_select[1])\n")
                f.write(f"    );\n\n")
            else:
                print(f"WARNING: Need to add support for {n_addr_roms}-way mux")
        
        # Concatenate muxed outputs
        if n_width_roms == 1:
            f.write(f"    assign rom_data = rom_data_col0[{n_rom_data_bits-1}:0];\n\n")
        else:
            rom_concat = ', '.join([f"rom_data_col{i}" for i in range(n_width_roms-1, -1, -1)])
            f.write(f"    assign rom_data = {{{rom_concat}}};\n\n")
    
    # Extract outputs from ROM data
    f.write(f"    // Extract nextstate and outputs from ROM data\n")
    f.write(f"    assign nextstate = rom_data[{n_rom_data_bits-1}:{n_output_bits}];\n")
    for i, col in enumerate(output_cols):
        f.write(f"    assign {col} = rom_data[{i}];\n")
    
    f.write(f"\nendmodule\n")

print(f"Generated Verilog file: {verilog_filename}")
print("Done!")
