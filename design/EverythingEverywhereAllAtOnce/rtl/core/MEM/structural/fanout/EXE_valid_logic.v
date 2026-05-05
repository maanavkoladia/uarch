// ======================================================================
// Combinational block : EXE_valid_logic
// Tool: csv2rtl.py  (auto-generated -- do not hand-edit)
// Std : Verilog-2005 (IEEE 1364-2005)
// WARNING: 4 input vector(s) had no CSV row.
//          Those vectors produce all-zero outputs (OFF-set default).
//          See: /misc/scratch/he3837/UARCH/uarch/design/EverythingEverywhereAllAtOnce/rtl/core/MEM/gen/EXE_valid_logic_coverage_report.txt
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

module EXE_valid_logic (
    output wire EXE_we_o,
    output wire N_EXE_V_o,
    input  wire MEM_V_i,
    input  wire MEM_stall_i,
    input  wire EXE_V_i,
    input  wire WB_stall_i
);

// ----------------------------------------------------------------
// Inverters for negated literals (stage 1, 0.15 ns)
// ----------------------------------------------------------------
wire MEM_V_i_inv;
wire MEM_stall_i_inv;

`INV_N(inv_MEM_V_i, 1, MEM_V_i, MEM_V_i_inv)
`INV_N(inv_MEM_stall_i, 1, MEM_stall_i, MEM_stall_i_inv)

// ----------------------------------------------------------------
// Timing-optimal NOR-NOR (POS) realisation (critical path = 0.55 ns)
// ----------------------------------------------------------------
//   f = (MEM_V_i  & !EXE_V_i)
//     | (!MEM_stall_i & !WB_stall_i)
//     | (MEM_V_i  & !WB_stall_i)
//     | (!MEM_stall_i & !EXE_V_i)
//   factors as
//     f = (MEM_V_i + !MEM_stall_i) * (!EXE_V_i + !WB_stall_i)
//   which is a 2-level POS implemented as NOR-NOR:
//     !S1 = NOR2(MEM_V_i, MEM_stall_i_inv) = !MEM_V_i & MEM_stall_i
//     !S2 = AND2(EXE_V_i, WB_stall_i)      = EXE_V_i & WB_stall_i
//     f   = NOR2(!S1, !S2)                 = S1 * S2
//   Path: INV(0.15) -> NOR2(0.20) -> NOR2(0.20) = 0.55 ns
//   (!S2 uses primaries directly; no inverters needed for EXE_V_i / WB_stall_i.)

// EXE_we_o
wire EXE_we_o_nS1;
wire EXE_we_o_nS2;
`NOR_2(EXE_we_o_nor_s1, 1, EXE_we_o_nS1, MEM_V_i, MEM_stall_i_inv)
`AND_2(EXE_we_o_and_s2, 1, EXE_we_o_nS2, EXE_V_i, WB_stall_i)
`NOR_2(EXE_we_o_nor_top, 1, EXE_we_o, EXE_we_o_nS1, EXE_we_o_nS2)

// N_EXE_V_o = (MEM_V_i & !MEM_stall_i) = NOR2(MEM_V_i_inv, MEM_stall_i)
// Path: INV(0.15) -> NOR2(0.20) = 0.35 ns
`NOR_2(N_EXE_V_o_nor, 1, N_EXE_V_o, MEM_V_i_inv, MEM_stall_i)

endmodule
