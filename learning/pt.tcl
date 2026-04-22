# Read technology library
read_lib {/misc/scratch/he3837/UARCH/uarch/design/EverythingEverywhereAllAtOnce//lib/Gates/ /misc/scratch/he3837/UARCH/uarch/design/EverythingEverywhereAllAtOnce//lib/STDCells/}

# Read Verilog design
read_verilog {/misc/scratch/he3837/UARCH/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/PreDecode/structural/}

# Set top module
current_design predecode

# Link the design
link

# Read constraints
read_sdc constraints.sdc

# Update timing
update_timing

# Reports
report_timing
report_constraints
report_qor
