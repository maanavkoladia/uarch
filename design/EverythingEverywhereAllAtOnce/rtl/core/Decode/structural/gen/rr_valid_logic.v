module rr_valid_logic (
    output wire RR_we_o,
    output wire N_RR_V_o,
    input  wire DECODE_V_i,
    input  wire RR_stall_i,
    input  wire RR_V_i,
    input  wire DC_stall_i,
    input  wire DC_V_i,
    input  wire MEM_V_i,
    input  wire MEM_stall_i,
    input  wire EXE_V_i,
    input  wire WB_stall_i
);

// ----------------------------------------------------------------
// Timing-optimal NOR + OR_5 realisation (critical path = 0.75 ns)
// ----------------------------------------------------------------
//   f = !RR_V_i
//     | (!RR_stall_i & !DC_V_i)
//     | (!RR_stall_i & !DC_stall_i & !MEM_V_i)
//     | (!RR_stall_i & !DC_stall_i & !MEM_stall_i & !EXE_V_i)
//     | (!RR_stall_i & !DC_stall_i & !MEM_stall_i & !WB_stall_i)
//   Each product of inverted literals = NOR_k of the primary inputs:
//     T1 = INV(RR_V_i)                                                   = 0.15 ns
//     T2 = NOR_2(RR_stall_i, DC_V_i)                                     = 0.20 ns
//     T3 = NOR_3(RR_stall_i, DC_stall_i, MEM_V_i)                        = 0.25 ns
//     T4 = NOR_4(RR_stall_i, DC_stall_i, MEM_stall_i, EXE_V_i)           = 0.35 ns
//     T5 = NOR_4(RR_stall_i, DC_stall_i, MEM_stall_i, WB_stall_i)        = 0.35 ns
//     f  = OR_5(T1, T2, T3, T4, T5)                                       +0.40 ns
//   No literal inverters needed (NOR consumes the polarity).
//   Path: NOR_4(0.35) -> OR_5(0.40) = 0.75 ns.

// RR_we_o
wire RR_we_o_T1;
wire RR_we_o_T2;
wire RR_we_o_T3;
wire RR_we_o_T4;
wire RR_we_o_T5;
`INV_N(RR_we_o_inv_t1, 1, RR_V_i, RR_we_o_T1)
`NOR_2(RR_we_o_nor_t2, 1, RR_we_o_T2, RR_stall_i, DC_V_i)
`NOR_3(RR_we_o_nor_t3, 1, RR_we_o_T3, RR_stall_i, DC_stall_i, MEM_V_i)
`NOR_4(RR_we_o_nor_t4, 1, RR_we_o_T4, RR_stall_i, DC_stall_i, MEM_stall_i, EXE_V_i)
`NOR_4(RR_we_o_nor_t5, 1, RR_we_o_T5, RR_stall_i, DC_stall_i, MEM_stall_i, WB_stall_i)
`OR_5(RR_we_o_or_top, 1, RR_we_o, RR_we_o_T1, RR_we_o_T2, RR_we_o_T3, RR_we_o_T4, RR_we_o_T5)

// N_RR_V_o = DECODE_V_i  --> direct wire (0 ns; 2-INV buffer dropped for timing)
assign N_RR_V_o = DECODE_V_i;

endmodule