// ======================================================================
// Combinational block : EXE_valid_logic
// Tool: csv2rtl.py  (auto-generated -- do not hand-edit)
// Std : Verilog-2005 (IEEE 1364-2005)
// Lib : std_cell_macros.vh
// WARNING: 4 input vector(s) had no CSV row.
//          Those vectors produce all-zero outputs (OFF-set default).
//          See: /home/maanav/projects/school_projects/uarch/uarch_project/design/EverythingEverywhereAllAtOnce/rtl/core/MEM/gen/EXE_valid_logic_coverage_report.txt
// ======================================================================

// Truth table (expanded, from CSV)
// ------------------------------------------------------------------------------------------
//       MEM_V_i   MEM_stall_i       EXE_V_i    WB_stall_i  |      EXE_we_o     N_EXE_V_o
// ------------------------------------------------------------------------------------------
//             0             0             0             0  |             1             0
//             0             0             0             1  |             1             0
//             0             0             1             0  |             1             0
//             0             0             1             1  |             0             0
//             1             0             0             0  |             1             1
//             1             0             0             1  |             1             1
//             1             0             1             0  |             1             1
//             1             0             1             1  |             0             1
//             1             1             0             0  |             1             0
//             1             1             0             1  |             1             0
//             1             1             1             0  |             1             0
//             1             1             1             1  |             0             0
// ------------------------------------------------------------------------------------------

`include "std_cell_macros.vh"

module EXE_valid_logic (
    output wire EXE_we_o,
    output wire N_EXE_V_o,
    input  wire MEM_V_i,
    input  wire MEM_stall_i,
    input  wire EXE_V_i,
    input  wire WB_stall_i
);

// ----------------------------------------------------------------
// Inverters for negated literals
// ----------------------------------------------------------------
wire EXE_V_i_inv;
wire MEM_stall_i_inv;
wire WB_stall_i_inv;

`INV_N(inv_EXE_V_i, 1, EXE_V_i, EXE_V_i_inv)
`INV_N(inv_MEM_stall_i, 1, MEM_stall_i, MEM_stall_i_inv)
`INV_N(inv_WB_stall_i, 1, WB_stall_i, WB_stall_i_inv)

// ----------------------------------------------------------------
// SOP logic (Quine-McCluskey minimised)
// ----------------------------------------------------------------

// EXE_we_o = (!MEM_stall_i & !EXE_V_i) | (MEM_V_i & !WB_stall_i) | (!MEM_stall_i & !WB_stall_i) | (MEM_V_i & !EXE_V_i)
wire EXE_we_o_t0;
`AND_2(EXE_we_o_and0, 1, EXE_we_o_t0, MEM_stall_i_inv, EXE_V_i_inv)
wire EXE_we_o_t1;
`AND_2(EXE_we_o_and1, 1, EXE_we_o_t1, MEM_V_i, WB_stall_i_inv)
wire EXE_we_o_t2;
`AND_2(EXE_we_o_and2, 1, EXE_we_o_t2, MEM_stall_i_inv, WB_stall_i_inv)
wire EXE_we_o_t3;
`AND_2(EXE_we_o_and3, 1, EXE_we_o_t3, MEM_V_i, EXE_V_i_inv)

`OR_4(EXE_we_o_or, 1, EXE_we_o, EXE_we_o_t0, EXE_we_o_t1, EXE_we_o_t2, EXE_we_o_t3)

// N_EXE_V_o = (MEM_V_i & !MEM_stall_i)
`AND_2(N_EXE_V_o_and, 1, N_EXE_V_o, MEM_V_i, MEM_stall_i_inv)

endmodule
