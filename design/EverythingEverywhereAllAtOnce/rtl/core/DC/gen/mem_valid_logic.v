// ======================================================================
// Combinational block : mem_valid_logic
// Tool: csv2rtl.py  (auto-generated -- do not hand-edit)
// Std : Verilog-2005 (IEEE 1364-2005)
// ======================================================================

// Truth table (expanded, from CSV)
// ----------------------------------------------------------------------------------------------------------------------
//    DC_stall_i        DC_V_i       MEM_V_i   MEM_stall_i       EXE_V_i    WB_stall_i  |      MEM_we_o     N_MEM_V_o
// ----------------------------------------------------------------------------------------------------------------------
//             0             0             0             0             0             0  |             1             0
//             0             0             0             0             0             1  |             1             0
//             0             0             0             0             1             0  |             1             0
//             0             0             0             0             1             1  |             1             0
//             0             0             0             1             0             0  |             1             0
//             0             0             0             1             0             1  |             1             0
//             0             0             0             1             1             0  |             1             0
//             0             0             0             1             1             1  |             1             0
//             0             0             1             0             0             0  |             1             0
//             0             0             1             0             0             1  |             1             0
//             0             0             1             0             1             0  |             1             0
//             0             0             1             0             1             1  |             0             0
//             0             0             1             1             0             0  |             0             0
//             0             0             1             1             0             1  |             0             0
//             0             0             1             1             1             0  |             0             0
//             0             0             1             1             1             1  |             0             0
//             0             1             0             0             0             0  |             1             1
//             0             1             0             0             0             1  |             1             1
//             0             1             0             0             1             0  |             1             1
//             0             1             0             0             1             1  |             1             1
//             0             1             0             1             0             0  |             1             1
//             0             1             0             1             0             1  |             1             1
//             0             1             0             1             1             0  |             1             1
//             0             1             0             1             1             1  |             1             1
//             0             1             1             0             0             0  |             1             1
//             0             1             1             0             0             1  |             1             1
//             0             1             1             0             1             0  |             1             1
//             0             1             1             0             1             1  |             0             1
//             0             1             1             1             0             0  |             0             1
//             0             1             1             1             0             1  |             0             1
//             0             1             1             1             1             0  |             0             1
//             0             1             1             1             1             1  |             0             1
//             1             0             0             0             0             0  |             1             0
//             1             0             0             0             0             1  |             1             0
//             1             0             0             0             1             0  |             1             0
//             1             0             0             0             1             1  |             1             0
//             1             0             0             1             0             0  |             1             0
//             1             0             0             1             0             1  |             1             0
//             1             0             0             1             1             0  |             1             0
//             1             0             0             1             1             1  |             1             0
//             1             0             1             0             0             0  |             1             0
//             1             0             1             0             0             1  |             1             0
//             1             0             1             0             1             0  |             1             0
//             1             0             1             0             1             1  |             0             0
//             1             0             1             1             0             0  |             0             0
//             1             0             1             1             0             1  |             0             0
//             1             0             1             1             1             0  |             0             0
//             1             0             1             1             1             1  |             0             0
//             1             1             0             0             0             0  |             1             0
//             1             1             0             0             0             1  |             1             0
//             1             1             0             0             1             0  |             1             0
//             1             1             0             0             1             1  |             1             0
//             1             1             0             1             0             0  |             1             0
//             1             1             0             1             0             1  |             1             0
//             1             1             0             1             1             0  |             1             0
//             1             1             0             1             1             1  |             1             0
//             1             1             1             0             0             0  |             1             0
//             1             1             1             0             0             1  |             1             0
//             1             1             1             0             1             0  |             1             0
//             1             1             1             0             1             1  |             0             0
//             1             1             1             1             0             0  |             0             0
//             1             1             1             1             0             1  |             0             0
//             1             1             1             1             1             0  |             0             0
//             1             1             1             1             1             1  |             0             0
// ----------------------------------------------------------------------------------------------------------------------

module mem_valid_logic (
    output wire MEM_we_o,
    output wire N_MEM_V_o,
    input  wire DC_stall_i,
    input  wire DC_V_i,
    input  wire MEM_V_i,
    input  wire MEM_stall_i,
    input  wire EXE_V_i,
    input  wire WB_stall_i
);

// ----------------------------------------------------------------
// Inverters for negated literals (stage 1, 0.15 ns)
// ----------------------------------------------------------------
wire DC_V_i_inv;
wire EXE_V_i_inv;
wire MEM_stall_i_inv;
wire WB_stall_i_inv;

`INV_N(inv_DC_V_i, 1, DC_V_i, DC_V_i_inv)
`INV_N(inv_EXE_V_i, 1, EXE_V_i, EXE_V_i_inv)
`INV_N(inv_MEM_stall_i, 1, MEM_stall_i, MEM_stall_i_inv)
`INV_N(inv_WB_stall_i, 1, WB_stall_i, WB_stall_i_inv)

// ----------------------------------------------------------------
// Timing-optimal NAND-NAND realisation (critical path = 0.55 ns)
// ----------------------------------------------------------------
//   f = !MEM_V_i | T2 | T3 = NAND3( MEM_V_i, !T2, !T3 )
//     !T2 = NAND2(MEM_stall_i_inv, EXE_V_i_inv) = MEM_stall_i | EXE_V_i
//     !T3 = NAND2(MEM_stall_i_inv, WB_stall_i_inv) = MEM_stall_i | WB_stall_i
//   MEM_V_i feeds the final NAND3 directly (no inverter for T1).
//   Path: INV(0.15) -> NAND2(0.20) -> NAND3(0.20) = 0.55 ns

// MEM_we_o = !MEM_V_i | (!MEM_stall_i & !EXE_V_i) | (!MEM_stall_i & !WB_stall_i)
wire MEM_we_o_nT2;
wire MEM_we_o_nT3;
`NAND_2(MEM_we_o_nand_t2, 1, MEM_we_o_nT2, MEM_stall_i_inv, EXE_V_i_inv)
`NAND_2(MEM_we_o_nand_t3, 1, MEM_we_o_nT3, MEM_stall_i_inv, WB_stall_i_inv)
`NAND_3(MEM_we_o_nand_top, 1, MEM_we_o, MEM_V_i, MEM_we_o_nT2, MEM_we_o_nT3)

// N_MEM_V_o = (!DC_stall_i & DC_V_i) = NOR2(DC_stall_i, DC_V_i_inv)
// Path: INV(0.15) -> NOR2(0.20) = 0.35 ns
`NOR_2(N_MEM_V_o_nor, 1, N_MEM_V_o, DC_stall_i, DC_V_i_inv)

endmodule
