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

// HAND-EDIT: emit BOTH active-high EXE_we_o (for the local in-MEM consumer)
// and active-low EXE_we_n_o (for EXE_Latches, which absorbs the inversion in
// a small bufferHInv16$ tree -- see EXE_Latches.v). Active-low + bufferHInv
// is faster than active-high + bufferH at low fanout-per-driver, and packing
// the small EXE_Latches fields drops total fanout below 64. The internal
// logic is now NAND-NAND directly producing the active-low form.
// Re-apply on csv2rtl.py regen.
module EXE_valid_logic (
    output wire EXE_we_o,
    output wire EXE_we_n_o,
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
// NAND-NAND (SOP of !f) realisation -- 2-level, same depth as the prior
// NOR-NOR (POS). Critical path = INV(0.15) -> NAND2(0.20) -> NAND2(0.20)
// = 0.55 ns to active-low EXE_we_n_o.
// ----------------------------------------------------------------
//   f  = (MEM_V_i + !MEM_stall_i) * (!EXE_V_i + !WB_stall_i)   [POS]
//   !f = !MEM_V_i * MEM_stall_i  +  EXE_V_i * WB_stall_i        [SOP]
//   2-level NAND-NAND of the SOP:
//     !P1 = NAND2(MEM_V_i_inv, MEM_stall_i)   = !(!MV * MS)
//     !P2 = NAND2(EXE_V_i, WB_stall_i)        = !(EV * WS)
//     !f  = NAND2(!P1, !P2)                   = P1 + P2
//   (!P2 uses primaries directly; only !MV needs an inverter.)
//
// EXE_we_n_o is consumed only by EXE_Latches' inverting-buffer tree, so
// the producer doesn't need a sized buffer here.
wire EXE_we_o_nP1;
wire EXE_we_o_nP2;
wire EXE_we_n_local;
`NAND_2(u_nand_p1,    1, EXE_we_o_nP1,   MEM_V_i_inv,  MEM_stall_i)
`NAND_2(u_nand_p2,    1, EXE_we_o_nP2,   EXE_V_i,      WB_stall_i)

// Replicate the top NAND2 so the active-low net going to EXE_Latches
// (drives 4 bufferHInv16$ ports = fanout 4) and the local active-high
// derivation (drives one INV = fanout 1) don't share a fanout. Both NANDs
// sit on the shared t1/t2 nets at fanout 2, comfortably within rating.
`NAND_2(u_nand_top_a, 1, EXE_we_n_o,     EXE_we_o_nP1, EXE_we_o_nP2)
`NAND_2(u_nand_top_b, 1, EXE_we_n_local, EXE_we_o_nP1, EXE_we_o_nP2)

// EXE_we_o (active-high) for the in-MEM forward_valid_w AND consumer (fanout
// 1). Single INV off the local active-low; off the EXE_Latches critical path.
`INV_N(u_inv_EXE_we_o, 1, EXE_we_n_local, EXE_we_o)

// N_EXE_V_o = (MEM_V_i & !MEM_stall_i) = NOR2(MEM_V_i_inv, MEM_stall_i)
// Path: INV(0.15) -> NOR2(0.20) = 0.35 ns
`NOR_2(N_EXE_V_o_nor, 1, N_EXE_V_o, MEM_V_i_inv, MEM_stall_i)

endmodule
