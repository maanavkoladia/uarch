// ======================================================================
// FSM : VCache_FSM
// Tool: fsm2rtl.py  (auto-generated -- hand-edited copy in fanout/ folder)
// Std : Verilog-2005 (IEEE 1364-2005)
// ======================================================================
// Fanout fix (round 2): ff_0/1/2 split into 3 copies each (a/b/c).
// 0 ns added on internal paths. NS_X fanout 1->3 (<=4 ok), no further cascade.
// busy_o (fanout 173) NOT addressed in this round -- needs separate
// structural rebuild of the saveReq mux chain.
// ======================================================================

module VCache_FSM (
    input  wire clk,
    input  wire rst,
    input  wire V_Hit_i,
    input  wire DC_will_evict_i,
    input  wire VC_needs_2_evict_i,
    input  wire EB_V_i,
    input  wire we_i,
    output wire S_0,
    output wire S_1,
    output wire S_2,
    output wire WR_2_EB_o,
    output wire CLR_D_SWAP_V_o,
    output wire Read_DSWAP_o,
    output wire Write_VSWAP_o,
    output wire Update_LRU_o,
    output wire busy_o,
    output wire blocked_o
);

wire NS_0;
wire NS_1;
wire NS_2;

// State flip-flops triplicated for fanout (a/b/c per state bit).
wire S_0_a, S_0_b, S_0_c;
wire S_1_a, S_1_b, S_1_c;
wire S_2_a, S_2_b, S_2_c;

`REG_RST(ff_0_a, 1, clk, rst, NS_0, S_0_a)
`REG_RST(ff_0_b, 1, clk, rst, NS_0, S_0_b)
`REG_RST(ff_0_c, 1, clk, rst, NS_0, S_0_c)
`REG_RST(ff_1_a, 1, clk, rst, NS_1, S_1_a)
`REG_RST(ff_1_b, 1, clk, rst, NS_1, S_1_b)
`REG_RST(ff_1_c, 1, clk, rst, NS_1, S_1_c)
`REG_RST(ff_2_a, 1, clk, rst, NS_2, S_2_a)
`REG_RST(ff_2_b, 1, clk, rst, NS_2, S_2_b)
`REG_RST(ff_2_c, 1, clk, rst, NS_2, S_2_c)

assign S_0 = S_0_c;
assign S_1 = S_1_c;
assign S_2 = S_2_c;

// Inverters use the *_c copy (port-driving wire) so inv shares load with port
wire EB_V_i_inv;
wire S_0_inv;
wire S_1_inv;
wire S_2_inv;
wire VC_needs_2_evict_i_inv;
wire V_Hit_i_inv;
wire we_i_inv;

`INV_N(inv_EB_V_i, 1, EB_V_i, EB_V_i_inv)
`INV_N(inv_S_0, 1, S_0_c, S_0_inv)
`INV_N(inv_S_1, 1, S_1_c, S_1_inv)
`INV_N(inv_S_2, 1, S_2_c, S_2_inv)
`INV_N(inv_VC_needs_2_evict_i, 1, VC_needs_2_evict_i, VC_needs_2_evict_i_inv)
`INV_N(inv_V_Hit_i, 1, V_Hit_i, V_Hit_i_inv)
`INV_N(inv_we_i, 1, we_i, we_i_inv)

// ----------------------------------------------------------------
// Distribution map (each state-bit copy <=4 internal loads):
//   S_0_a: NS_0_and2, NS_1_and2, NS_2_and0
//   S_0_b: CLR_D_SWAP_V_o, Read_DSWAP_o, Write_VSWAP_o_nand0
//   S_0_c: Update_LRU_o, busy_o_nand0, inv_S_0, output port
//
//   S_1_a: NS_0_and3, NS_1_and0, WR_2_EB_o_nand1
//   S_1_b: CLR_D_SWAP_V_o, Read_DSWAP_o, Update_LRU_o
//   S_1_c: busy_o_nand1, blocked_o_and, inv_S_1, output port
//
//   S_2_a: NS_0_and1, NS_1_and1
//   S_2_b: NS_2_and0, WR_2_EB_o_nand0
//   S_2_c: busy_o_nand2, inv_S_2, output port
// ----------------------------------------------------------------

// NS_0 = (!S_1 & V_Hit_i) | (!S_1 & S_2) | (S_0 & !S_1) | (!S_0 & S_1 & !S_2 & !EB_V_i) | (!S_1 & DC_will_evict_i & !VC_needs_2_evict_i)
wire NS_0_t0;
`AND_2(NS_0_and0, 1, NS_0_t0, S_1_inv, V_Hit_i)
wire NS_0_t1;
`AND_2(NS_0_and1, 1, NS_0_t1, S_1_inv, S_2_a)
wire NS_0_t2;
`AND_2(NS_0_and2, 1, NS_0_t2, S_0_a, S_1_inv)
wire NS_0_t3;
`AND_4(NS_0_and3, 1, NS_0_t3, S_0_inv, S_1_a, S_2_inv, EB_V_i_inv)
wire NS_0_t4;
`AND_3(NS_0_and4, 1, NS_0_t4, S_1_inv, DC_will_evict_i, VC_needs_2_evict_i_inv)

`OR_5(NS_0_or, 1, NS_0, NS_0_t0, NS_0_t1, NS_0_t2, NS_0_t3, NS_0_t4)

// NS_1 = (!S_0 & S_1 & !S_2) | (!S_0 & !S_1 & S_2) | (S_0 & !S_1 & !S_2) | (!S_1 & !S_2 & V_Hit_i & !we_i) | (!S_1 & !S_2 & !V_Hit_i & DC_will_evict_i & !VC_needs_2_evict_i) | (!S_1 & !S_2 & !V_Hit_i & DC_will_evict_i & EB_V_i)
wire NS_1_t0;
`AND_3(NS_1_and0, 1, NS_1_t0, S_0_inv, S_1_a, S_2_inv)
wire NS_1_t1;
`AND_3(NS_1_and1, 1, NS_1_t1, S_0_inv, S_1_inv, S_2_a)
wire NS_1_t2;
`AND_3(NS_1_and2, 1, NS_1_t2, S_0_a, S_1_inv, S_2_inv)
wire NS_1_t3;
`AND_4(NS_1_and3, 1, NS_1_t3, S_1_inv, S_2_inv, V_Hit_i, we_i_inv)
wire NS_1_t4;
`AND_5(NS_1_and4, 1, NS_1_t4, S_1_inv, S_2_inv, V_Hit_i_inv, DC_will_evict_i, VC_needs_2_evict_i_inv)
wire NS_1_t5;
`AND_5(NS_1_and5, 1, NS_1_t5, S_1_inv, S_2_inv, V_Hit_i_inv, DC_will_evict_i, EB_V_i)

`OR_6(NS_1_or, 1, NS_1, NS_1_t0, NS_1_t1, NS_1_t2, NS_1_t3, NS_1_t4, NS_1_t5)

// NS_2 = (S_0 & !S_1 & S_2) | (!S_0 & !S_1 & !S_2 & !V_Hit_i & DC_will_evict_i & VC_needs_2_evict_i & !EB_V_i)
wire NS_2_t0;
`AND_3(NS_2_and0, 1, NS_2_t0, S_0_a, S_1_inv, S_2_b)
wire NS_2_t1;
`AND_7(NS_2_and1, 1, NS_2_t1, S_0_inv, S_1_inv, S_2_inv, V_Hit_i_inv, DC_will_evict_i, VC_needs_2_evict_i, EB_V_i_inv)

`OR_2(NS_2_or, 1, NS_2, NS_2_t0, NS_2_t1)

// WR_2_EB_o = (!S_0 & !S_1 & S_2) | (!S_0 & S_1 & !S_2)
wire WR_2_EB_o_n0;
`NAND_3(WR_2_EB_o_nand0, 1, WR_2_EB_o_n0, S_0_inv, S_1_inv, S_2_b)
wire WR_2_EB_o_n1;
`NAND_3(WR_2_EB_o_nand1, 1, WR_2_EB_o_n1, S_0_inv, S_1_a, S_2_inv)

// WR_2_EB_o fanout=7 -- bufferH16$ +0.24 ns, off read crit (EB write trigger).
wire WR_2_EB_o_pre;
`NAND_2(WR_2_EB_o_nand, 1, WR_2_EB_o_pre, WR_2_EB_o_n0, WR_2_EB_o_n1)
bufferH16$ u_WR_2_EB_o_buf (.out(WR_2_EB_o), .in(WR_2_EB_o_pre));

// CLR_D_SWAP_V_o = (S_0 & S_1 & !S_2)
`AND_3(CLR_D_SWAP_V_o_and, 1, CLR_D_SWAP_V_o, S_0_b, S_1_b, S_2_inv)

// Read_DSWAP_o = (S_0 & S_1 & !S_2)
// fanout=7 -- bufferH16$ +0.24 ns, off read crit (D-swap read trigger).
wire Read_DSWAP_o_pre;
`AND_3(Read_DSWAP_o_and, 1, Read_DSWAP_o_pre, S_0_b, S_1_b, S_2_inv)
bufferH16$ u_Read_DSWAP_o_buf (.out(Read_DSWAP_o), .in(Read_DSWAP_o_pre));

// Write_VSWAP_o = (S_0 & !S_1 & !S_2) | (!S_1 & !S_2 & V_Hit_i & !we_i)
wire Write_VSWAP_o_n0;
`NAND_3(Write_VSWAP_o_nand0, 1, Write_VSWAP_o_n0, S_0_b, S_1_inv, S_2_inv)
wire Write_VSWAP_o_n1;
`NAND_4(Write_VSWAP_o_nand1, 1, Write_VSWAP_o_n1, S_1_inv, S_2_inv, V_Hit_i, we_i_inv)

// Write_VSWAP_o fanout=7 -- bufferH16$ +0.24 ns, off read crit (V-swap write).
wire Write_VSWAP_o_pre;
`NAND_2(Write_VSWAP_o_nand, 1, Write_VSWAP_o_pre, Write_VSWAP_o_n0, Write_VSWAP_o_n1)
bufferH16$ u_Write_VSWAP_o_buf (.out(Write_VSWAP_o), .in(Write_VSWAP_o_pre));

// Update_LRU_o = (S_0 & S_1 & !S_2)
`AND_3(Update_LRU_o_and, 1, Update_LRU_o, S_0_c, S_1_b, S_2_inv)

// busy_o = (S_0 & !S_2) | (S_1 & !S_2) | (!S_0 & !S_1 & S_2)
// Fanout 173 external (saveReq mux chain inside VCache parent). bufferH256$
// on the output port, +0.54 ns added on this signal's path. busy_o is the
// FSM busy/saveReq signal, not on the cache hit/load critical path.
wire busy_o_n0;
`NAND_2(busy_o_nand0, 1, busy_o_n0, S_0_c, S_2_inv)
wire busy_o_n1;
`NAND_2(busy_o_nand1, 1, busy_o_n1, S_1_c, S_2_inv)
wire busy_o_n2;
`NAND_3(busy_o_nand2, 1, busy_o_n2, S_0_inv, S_1_inv, S_2_c)

wire busy_o_pre;
`NAND_3(busy_o_nand, 1, busy_o_pre, busy_o_n0, busy_o_n1, busy_o_n2)
bufferH256$ u_busy_o_buf (.out(busy_o), .in(busy_o_pre));

// blocked_o = (!S_0 & S_1 & !S_2 & EB_V_i)
`AND_4(blocked_o_and, 1, blocked_o, S_0_inv, S_1_c, S_2_inv, EB_V_i)

endmodule
