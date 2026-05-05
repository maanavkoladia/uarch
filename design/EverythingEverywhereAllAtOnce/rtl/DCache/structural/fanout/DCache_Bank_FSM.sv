// ======================================================================
// FSM : DCache_Bank_FSM
// Tool: fsm2rtl.py  (auto-generated -- hand-edited copy in fanout/ folder)
// Std : Verilog-2005 (IEEE 1364-2005)
// ======================================================================
// Fanout fix (round 2): ff_X split into copies per state bit.
//   S_0: K=4 (14 internal loads -> 4-4-3-3)
//   S_1: K=3 (12 loads -> 4-4-4)
//   S_2: K=3 (11 loads -> 4-4-3)
//   S_3: K=2 (5 loads -> 3-2)
// 0 ns added on internal paths. NS_X fanout 1->{4,3,3,2}, all <=4 OK.
// busy_o (fanout 163) and ldFrom_V_swap_o (fanout 147) NOT addressed
// in this round -- they need separate structural rebuilds.
// ======================================================================

module DCache_Bank_FSM (
    input  wire clk,
    input  wire rst,
    input  wire D_Miss_i,
    input  wire V_Miss_i,
    input  wire EB_Hit_i,
    input  wire Line_valid_i,
    input  wire DTE_Mem_valid_i,
    input  wire D_Swap_valid_i,
    input  wire we_i,
    output wire S_0,
    output wire S_1,
    output wire S_2,
    output wire S_3,
    output wire write_to_dswap_o,
    output wire D_will_evict_o,
    output wire ldFrom_V_swap_o,
    output wire clr_v_swap_o,
    output wire MakeReq_o,
    output wire Blocked_o,
    output wire busy_o,
    output wire fill0_o,
    output wire fill1_o,
    output wire fill2_o,
    output wire fill3_o
);

wire NS_0;
wire NS_1;
wire NS_2;
wire NS_3;

// Triplicated/quadruplicated state FFs.
wire S_0_a, S_0_b, S_0_c, S_0_d;
wire S_1_a, S_1_b, S_1_c, S_1_d;
wire S_2_a, S_2_b, S_2_c;
wire S_3_a, S_3_b;

`REG_RST(ff_0_a, 1, clk, rst, NS_0, S_0_a)
`REG_RST(ff_0_b, 1, clk, rst, NS_0, S_0_b)
`REG_RST(ff_0_c, 1, clk, rst, NS_0, S_0_c)
`REG_RST(ff_0_d, 1, clk, rst, NS_0, S_0_d)
`REG_RST(ff_1_a, 1, clk, rst, NS_1, S_1_a)
`REG_RST(ff_1_b, 1, clk, rst, NS_1, S_1_b)
`REG_RST(ff_1_c, 1, clk, rst, NS_1, S_1_c)
`REG_RST(ff_1_d, 1, clk, rst, NS_1, S_1_d)
`REG_RST(ff_2_a, 1, clk, rst, NS_2, S_2_a)
`REG_RST(ff_2_b, 1, clk, rst, NS_2, S_2_b)
`REG_RST(ff_2_c, 1, clk, rst, NS_2, S_2_c)
`REG_RST(ff_3_a, 1, clk, rst, NS_3, S_3_a)
`REG_RST(ff_3_b, 1, clk, rst, NS_3, S_3_b)

assign S_0 = S_0_d;
assign S_1 = S_1_d;
assign S_2 = S_2_c;
assign S_3 = S_3_b;

wire DTE_Mem_valid_i_inv;
wire D_Swap_valid_i_inv;
wire EB_Hit_i_inv;
wire Line_valid_i_inv;
wire S_0_inv;
wire S_1_inv;
wire S_2_inv;
wire S_3_inv;
wire V_Miss_i_inv;
wire we_i_inv;

`INV_N(inv_DTE_Mem_valid_i, 1, DTE_Mem_valid_i, DTE_Mem_valid_i_inv)
`INV_N(inv_D_Swap_valid_i, 1, D_Swap_valid_i, D_Swap_valid_i_inv)
`INV_N(inv_EB_Hit_i, 1, EB_Hit_i, EB_Hit_i_inv)
`INV_N(inv_Line_valid_i, 1, Line_valid_i, Line_valid_i_inv)
`INV_N(inv_S_0, 1, S_0_d, S_0_inv)
`INV_N(inv_S_1, 1, S_1_d, S_1_inv)
`INV_N(inv_S_2, 1, S_2_c, S_2_inv)
`INV_N(inv_S_3, 1, S_3_b, S_3_inv)
`INV_N(inv_V_Miss_i, 1, V_Miss_i, V_Miss_i_inv)
`INV_N(inv_we_i, 1, we_i, we_i_inv)

// ----------------------------------------------------------------
// Distribution maps:
//   S_0_a (4): NS_0_and1, NS_0_and2, NS_0_and6, NS_1_and4
//   S_0_b (4): NS_2_and3, NS_3_and0, ldFrom_V_swap_o_and, clr_v_swap_o_and
//   S_0_c (3): MakeReq_o_and, Blocked_o_and, busy_o_nand0
//   S_0_d (3+inv+port): fill0_o_and, fill2_o_and, inv_S_0, output port
//
//   S_1_a (4): NS_0_and3, NS_0_and5, NS_0_and6, NS_1_and0
//   S_1_b (4): NS_1_and2, NS_1_and3, NS_2_and3, ldFrom_V_swap_o_and
//   S_1_c (4+inv+port): clr_v_swap_o_and, MakeReq_o_and,
//                       busy_o_nand2, fill3_o_and, inv_S_1, output port
//
//   S_2_a (4): NS_0_and2, NS_0_and4, NS_1_and4, NS_2_and0
//   S_2_b (4): NS_2_and2, ldFrom_V_swap_o_and, clr_v_swap_o_and, busy_o_nand1
//   S_2_c (3+inv+port): fill1_o_and, fill2_o_and, inv_S_2, output port
//                       (Note: 2 internal + inv + port; well below limit)
//
//   S_3_a (3): NS_0_and0, NS_1_and1, NS_2_and1
//   S_3_b (1+inv+port): NS_3_and0, inv_S_3, output port
// ----------------------------------------------------------------

// NS_0 = (!S_1 & !S_2 & S_3) | (S_0 & !S_1 & !S_2 & EB_Hit_i) | (S_0 & !S_1 & S_2 & !S_3 & !DTE_Mem_valid_i) | ...
wire NS_0_t0;
`AND_3(NS_0_and0, 1, NS_0_t0, S_1_inv, S_2_inv, S_3_a)
wire NS_0_t1;
`AND_4(NS_0_and1, 1, NS_0_t1, S_0_a, S_1_inv, S_2_inv, EB_Hit_i)
wire NS_0_t2;
`AND_5(NS_0_and2, 1, NS_0_t2, S_0_a, S_1_inv, S_2_a, S_3_inv, DTE_Mem_valid_i_inv)
wire NS_0_t3;
`AND_5(NS_0_and3, 1, NS_0_t3, S_1_a, S_2_inv, S_3_inv, DTE_Mem_valid_i_inv, D_Swap_valid_i_inv)
wire NS_0_t4;
`AND_5(NS_0_and4, 1, NS_0_t4, S_0_inv, S_1_inv, S_2_a, S_3_inv, DTE_Mem_valid_i)
wire NS_0_t5;
`AND_5(NS_0_and5, 1, NS_0_t5, S_0_inv, S_1_a, S_2_inv, S_3_inv, D_Swap_valid_i_inv)
wire NS_0_t6;
`AND_5(NS_0_and6, 1, NS_0_t6, S_0_a, S_1_a, S_2_inv, S_3_inv, DTE_Mem_valid_i_inv)
wire NS_0_t7;
`AND_5(NS_0_and7, 1, NS_0_t7, S_0_inv, S_1_inv, S_2_inv, D_Miss_i, Line_valid_i_inv)
wire NS_0_t8;
`AND_5(NS_0_and8, 1, NS_0_t8, S_1_inv, S_2_inv, D_Miss_i, EB_Hit_i, we_i_inv)
wire NS_0_t9;
`AND_5(NS_0_and9, 1, NS_0_t9, S_1_inv, S_2_inv, D_Miss_i, V_Miss_i, EB_Hit_i)
wire NS_0_t10;
`AND_6(NS_0_and10, 1, NS_0_t10, S_0_inv, S_1_inv, S_2_inv, D_Miss_i, V_Miss_i_inv, we_i_inv)

`OR_11(NS_0_or, 1, NS_0, NS_0_t0, NS_0_t1, NS_0_t2, NS_0_t3, NS_0_t4, NS_0_t5, NS_0_t6, NS_0_t7, NS_0_t8, NS_0_t9, NS_0_t10)

// NS_1 = ...
wire NS_1_t0;
`AND_4(NS_1_and0, 1, NS_1_t0, S_0_inv, S_1_a, S_2_inv, S_3_inv)
wire NS_1_t1;
`AND_4(NS_1_and1, 1, NS_1_t1, S_0_inv, S_1_inv, S_2_inv, S_3_a)
wire NS_1_t2;
`AND_4(NS_1_and2, 1, NS_1_t2, S_1_b, S_2_inv, S_3_inv, DTE_Mem_valid_i_inv)
wire NS_1_t3;
`AND_4(NS_1_and3, 1, NS_1_t3, S_0_inv, S_1_b, S_3_inv, DTE_Mem_valid_i_inv)
wire NS_1_t4;
`AND_5(NS_1_and4, 1, NS_1_t4, S_0_a, S_1_inv, S_2_a, S_3_inv, DTE_Mem_valid_i)
wire NS_1_t5;
`AND_6(NS_1_and5, 1, NS_1_t5, S_0_inv, S_1_inv, S_2_inv, D_Miss_i, V_Miss_i, EB_Hit_i_inv)
wire NS_1_t6;
`AND_6(NS_1_and6, 1, NS_1_t6, S_0_inv, S_1_inv, S_2_inv, D_Miss_i, V_Miss_i, Line_valid_i_inv)
wire NS_1_t7;
`AND_7(NS_1_and7, 1, NS_1_t7, S_0_inv, S_1_inv, S_2_inv, D_Miss_i, V_Miss_i_inv, Line_valid_i, we_i_inv)

`OR_8(NS_1_or, 1, NS_1, NS_1_t0, NS_1_t1, NS_1_t2, NS_1_t3, NS_1_t4, NS_1_t5, NS_1_t6, NS_1_t7)

// NS_2 = ...
wire NS_2_t0;
`AND_3(NS_2_and0, 1, NS_2_t0, S_1_inv, S_2_a, S_3_inv)
wire NS_2_t1;
`AND_4(NS_2_and1, 1, NS_2_t1, S_0_inv, S_1_inv, S_2_inv, S_3_a)
wire NS_2_t2;
`AND_4(NS_2_and2, 1, NS_2_t2, S_0_inv, S_2_b, S_3_inv, DTE_Mem_valid_i_inv)
wire NS_2_t3;
`AND_5(NS_2_and3, 1, NS_2_t3, S_0_b, S_1_b, S_2_inv, S_3_inv, DTE_Mem_valid_i)
wire NS_2_t4;
`AND_7(NS_2_and4, 1, NS_2_t4, S_0_inv, S_1_inv, S_2_inv, D_Miss_i, V_Miss_i_inv, Line_valid_i, we_i_inv)

`OR_5(NS_2_or, 1, NS_2, NS_2_t0, NS_2_t1, NS_2_t2, NS_2_t3, NS_2_t4)

// NS_3 = ...
wire NS_3_t0;
`AND_4(NS_3_and0, 1, NS_3_t0, S_0_b, S_1_inv, S_2_inv, S_3_b)
wire NS_3_t1;
`AND_7(NS_3_and1, 1, NS_3_t1, S_0_inv, S_1_inv, S_2_inv, S_3_inv, D_Miss_i, V_Miss_i_inv, we_i)
wire NS_3_t2;
`AND_7(NS_3_and2, 1, NS_3_t2, S_0_inv, S_1_inv, S_2_inv, S_3_inv, D_Miss_i, V_Miss_i_inv, Line_valid_i_inv)

`OR_3(NS_3_or, 1, NS_3, NS_3_t0, NS_3_t1, NS_3_t2)

// write_to_dswap_o (fanout=8 across DataStore + TagStore + parent).
// bufferH16$ at output, +0.24 ns. Off cache-read critical path -- this is
// a fill/swap-write path control signal.
wire write_to_dswap_o_t0;
`AND_7(write_to_dswap_o_and0, 1, write_to_dswap_o_t0, S_0_inv, S_1_inv, S_2_inv, S_3_inv, D_Miss_i, V_Miss_i_inv, Line_valid_i)
wire write_to_dswap_o_t1;
`AND_7(write_to_dswap_o_and1, 1, write_to_dswap_o_t1, S_0_inv, S_1_inv, S_2_inv, S_3_inv, D_Miss_i, EB_Hit_i_inv, Line_valid_i)
wire write_to_dswap_o_pre;
`OR_2(write_to_dswap_o_or, 1, write_to_dswap_o_pre, write_to_dswap_o_t0, write_to_dswap_o_t1)
bufferH16$ u_write_to_dswap_o_buf (.out(write_to_dswap_o), .in(write_to_dswap_o_pre));

// D_will_evict_o (fanout=6 -> bank-level signal flat). bufferH16$ +0.24 ns,
// off read crit path (eviction control).
wire D_will_evict_o_pre;
`AND_8(D_will_evict_o_and, 1, D_will_evict_o_pre, S_0_inv, S_1_inv, S_2_inv, S_3_inv, D_Miss_i, V_Miss_i, EB_Hit_i_inv, Line_valid_i)
bufferH16$ u_D_will_evict_o_buf (.out(D_will_evict_o), .in(D_will_evict_o_pre));

// ldFrom_V_swap_o = (S_0 & S_1 & S_2 & !S_3)
// Fanout 147 external (DataStore byte-iter consumers). bufferH256$ on output,
// +0.54 ns. This signal IS on the swap-data load path -- accept the cost
// for now; can revisit with deeper rebuild if margin needs it.
wire ldFrom_V_swap_o_pre;
`AND_4(ldFrom_V_swap_o_and, 1, ldFrom_V_swap_o_pre, S_0_b, S_1_b, S_2_b, S_3_inv)
bufferH256$ u_ldFrom_V_swap_o_buf (.out(ldFrom_V_swap_o), .in(ldFrom_V_swap_o_pre));

// clr_v_swap_o = (S_0 & S_1 & S_2 & !S_3)
`AND_4(clr_v_swap_o_and, 1, clr_v_swap_o, S_0_b, S_1_c, S_2_b, S_3_inv)

// MakeReq_o = (S_0 & S_1 & !S_2 & !S_3 & !DTE_Mem_valid_i)
`AND_5(MakeReq_o_and, 1, MakeReq_o, S_0_c, S_1_c, S_2_inv, S_3_inv, DTE_Mem_valid_i_inv)

// Blocked_o = (S_0 & !S_1 & !S_2 & !S_3 & EB_Hit_i)
`AND_5(Blocked_o_and, 1, Blocked_o, S_0_c, S_1_inv, S_2_inv, S_3_inv, EB_Hit_i)

// busy_o = (S_0 & !S_3) | (S_2 & !S_3) | (S_1 & !S_3) | (!S_0 & !S_1 & !S_2 & S_3)
// Fanout 163 external (saveReq mux chain inside DCache_Bank parent).
// bufferH256$ on output, +0.54 ns. Not on cache hit/load critical path.
wire busy_o_n0;
`NAND_2(busy_o_nand0, 1, busy_o_n0, S_0_c, S_3_inv)
wire busy_o_n1;
`NAND_2(busy_o_nand1, 1, busy_o_n1, S_2_b, S_3_inv)
wire busy_o_n2;
`NAND_2(busy_o_nand2, 1, busy_o_n2, S_1_c, S_3_inv)
wire busy_o_n3;
`NAND_4(busy_o_nand3, 1, busy_o_n3, S_0_inv, S_1_inv, S_2_inv, S_3_b)

wire busy_o_pre;
`NAND_4(busy_o_nand, 1, busy_o_pre, busy_o_n0, busy_o_n1, busy_o_n2, busy_o_n3)
bufferH256$ u_busy_o_buf (.out(busy_o), .in(busy_o_pre));

// fill0_o..fill3_o each fan out 37-39 (16 byte iters in DataStore + internal
// FSM uses). bufferH64$ on each, +0.30 ns. NOT on cache read-hit critical
// path -- these gate the fill/refill write data muxes, only active during
// memory line fill (cold-miss / VC-swap), which already pays a multi-cycle
// memory latency upstream.
// fill0_o = (S_0 & S_1 & !S_2 & !S_3 & DTE_Mem_valid_i)
wire fill0_o_pre, fill1_o_pre, fill2_o_pre, fill3_o_pre;
`AND_5(fill0_o_and, 1, fill0_o_pre, S_0_d, S_1_d, S_2_inv, S_3_inv, DTE_Mem_valid_i)
`AND_5(fill1_o_and, 1, fill1_o_pre, S_0_inv, S_1_inv, S_2_c, S_3_inv, DTE_Mem_valid_i)
`AND_5(fill2_o_and, 1, fill2_o_pre, S_0_d, S_1_inv, S_2_c, S_3_inv, DTE_Mem_valid_i)
`AND_5(fill3_o_and, 1, fill3_o_pre, S_0_inv, S_1_d, S_2_c, S_3_inv, DTE_Mem_valid_i)
bufferH64$ u_fill0_buf (.out(fill0_o), .in(fill0_o_pre));
bufferH64$ u_fill1_buf (.out(fill1_o), .in(fill1_o_pre));
bufferH64$ u_fill2_buf (.out(fill2_o), .in(fill2_o_pre));
bufferH64$ u_fill3_buf (.out(fill3_o), .in(fill3_o_pre));

endmodule
