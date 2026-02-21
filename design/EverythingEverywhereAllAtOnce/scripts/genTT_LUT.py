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

# Identify columns
input_cols = [c for c in fieldnames if c.endswith('_i')]
output_cols = [c for c in fieldnames if c.endswith('_o')]

if not input_cols:
    raise ValueError("No input columns found (columns ending with '_i')")
if not output_cols:
    raise ValueError("No output columns found (columns ending with '_o')")

# Total input/output bits
n_input_bits = len(input_cols)
n_output_bits = len(output_cols)
n_rom_addr_bits = n_input_bits
n_rom_data_bits = n_output_bits

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
    # Build input pattern
    input_bits = ''.join([row[col].strip() for col in input_cols])
    
    # Build output pattern
    output_bits = ''.join([row[col].strip() for col in output_cols])
    
    # Expand don't cares in input
    for expanded_input in expand_dont_care(input_bits):
        addr_int = int(expanded_input, 2)
        data_int = int(output_bits, 2)
        if addr_int in truth_table and truth_table[addr_int] != data_int:
            print(f"WARNING: Conflicting outputs for input {expanded_input}: {truth_table[addr_int]:0{n_output_bits}b} vs {data_int:0{n_output_bits}b}")
        truth_table[addr_int] = data_int

# Fill in missing addresses with default (outputs all 0)
rom_size = 2 ** n_rom_addr_bits
for addr in range(rom_size):
    if addr not in truth_table:
        truth_table[addr] = 0  # Default: outputs all 0

print(f"Truth table size: {len(truth_table)} entries")

# Determine ROM configuration
# Each ROM is 5-bit address (32 words)
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
    
    # ROM address construction
    f.write(f"    // ROM address = {{{', '.join(input_cols)}}}\n")
    f.write(f"    wire [{n_rom_addr_bits-1}:0] rom_addr;\n")
    if n_input_bits > 1:
        input_concat = ', '.join(input_cols)
        f.write(f"    assign rom_addr = {{{input_concat}}};\n\n")
    else:
        f.write(f"    assign rom_addr = {input_cols[0]};\n\n")
    
    # ROM data output
    f.write(f"    // ROM data = outputs\n")
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
            elif n_addr_roms == 8:
                # Need to handle 8-way mux - use two 4-way muxes followed by a 2-way mux
                f.write(f"    wire [{rom_width-1}:0] {mux_out_name}_mux0;\n")
                f.write(f"    wire [{rom_width-1}:0] {mux_out_name}_mux1;\n")
                f.write(f"    mux4_{rom_width}$ mux_col{width_idx}_0 (\n")
                f.write(f"        .Y({mux_out_name}_mux0),\n")
                f.write(f"        .IN0(ROM_0_{width_idx}_out),\n")
                f.write(f"        .IN1(ROM_1_{width_idx}_out),\n")
                f.write(f"        .IN2(ROM_2_{width_idx}_out),\n")
                f.write(f"        .IN3(ROM_3_{width_idx}_out),\n")
                f.write(f"        .S0(rom_select[0]),\n")
                f.write(f"        .S1(rom_select[1])\n")
                f.write(f"    );\n")
                f.write(f"    mux4_{rom_width}$ mux_col{width_idx}_1 (\n")
                f.write(f"        .Y({mux_out_name}_mux1),\n")
                f.write(f"        .IN0(ROM_4_{width_idx}_out),\n")
                f.write(f"        .IN1(ROM_5_{width_idx}_out),\n")
                f.write(f"        .IN2(ROM_6_{width_idx}_out),\n")
                f.write(f"        .IN3(ROM_7_{width_idx}_out),\n")
                f.write(f"        .S0(rom_select[0]),\n")
                f.write(f"        .S1(rom_select[1])\n")
                f.write(f"    );\n")
                f.write(f"    mux2_{rom_width}$ mux_col{width_idx}_final (\n")
                f.write(f"        .Y({mux_out_name}),\n")
                f.write(f"        .IN0({mux_out_name}_mux0),\n")
                f.write(f"        .IN1({mux_out_name}_mux1),\n")
                f.write(f"        .S0(rom_select[2])\n")
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
    f.write(f"    // Extract outputs from ROM data\n")
    for i, col in enumerate(output_cols):
        f.write(f"    assign {col} = rom_data[{i}];\n")
    
    f.write(f"\nendmodule\n")

print(f"Generated Verilog file: {verilog_filename}")
print("Done!")
