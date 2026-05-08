// ======================================================================
// FSM : DMA_FSM
// Tool: fsm2rtl.py  (auto-generated -- hand-edited copy in fanout/ folder)
// Std : Verilog-2005 (IEEE 1364-2005)
// ======================================================================
// Fanout fixes:
//  - ff_0 / ff_1 triplication was being merged by synthesis (still showing
//    fanout 11 / 10).  Collapsed back to single FFs and broadcast each Q
//    through bufferH16$ to break the merge and limit fanout. +0.13 ns on
//    S_0 / S_1 paths (one buffer-tier).
//  - inv_S_2 re-driven through bufferH64$ (fanout 18 external),
//    +0.13 ns on that path.
//  - ld_counter_o re-driven through bufferH64$ (fanout 33 external),
//    +0.30 ns on that output.
//  - ld_writeBuf_o re-driven through bufferH64$ (fanout 19 external),
//    +0.30 ns on that output.
// ======================================================================

module DMA_FSM (
    input  wire clk,
    input  wire rst,
    input  wire start_write_i,
    input  wire ld_buf_data_V_i,
    input  wire write_Complete_i,
    input  wire writeBuf_V_i,
    output wire S_0,
    output wire S_1,
    output wire S_2,
    output wire req_ld_o,
    output wire ld_counter_o,
    output wire inc_counter_o,
    output wire ld_writeBuf_o,
    output wire clr_start_write_bit_o,
    output wire req_bus_o,
    output wire busy_o,
    output wire interrupt_o
);

wire NS_0;
wire NS_1;
wire NS_2;

// ff_0 / ff_1 are single FFs with bufferH16$ broadcasts (a/b/c). The
// previous triplication was getting merged by synthesis; the buffers
// also break that merge by giving each fan-out group a distinct sink.
wire S_0_q, S_1_q;
wire S_0_a, S_0_b, S_0_c;
wire S_1_a, S_1_b, S_1_c;

// ff_0 / ff_1 q outputs are now redirected through attached buffers per spec.
wire S_0_q_pre_buf, S_1_q_pre_buf;
`REG_RST(ff_0, 1, clk, rst, NS_0, S_0_q_pre_buf)
bufferH16$ u_attach_ff_0_q_0 (.out(S_0_q), .in(S_0_q_pre_buf)); // fanout
`REG_RST(ff_1, 1, clk, rst, NS_1, S_1_q_pre_buf)
bufferH16$ u_attach_ff_1_q_0 (.out(S_1_q), .in(S_1_q_pre_buf)); // fanout
`REG_RST(ff_2, 1, clk, rst, NS_2, S_2)

bufferH16$ u_S_0_a_buf (.out(S_0_a), .in(S_0_q));
bufferH16$ u_S_0_b_buf (.out(S_0_b), .in(S_0_q));
bufferH16$ u_S_0_c_buf (.out(S_0_c), .in(S_0_q));
bufferH16$ u_S_1_a_buf (.out(S_1_a), .in(S_1_q));
bufferH16$ u_S_1_b_buf (.out(S_1_b), .in(S_1_q));
bufferH16$ u_S_1_c_buf (.out(S_1_c), .in(S_1_q));

assign S_0 = S_0_c;
assign S_1 = S_1_c;

wire S_0_inv;
wire S_1_inv;
wire S_2_inv;
wire ld_buf_data_V_i_inv;
wire writeBuf_V_i_inv;
wire write_Complete_i_inv;

`INV_N(inv_S_0, 1, S_0_c, S_0_inv)
`INV_N(inv_S_1, 1, S_1_c, S_1_inv)
// inv_S_2 external fanout 18 -> bufferH64$.
wire S_2_inv_pre;
`INV_N(inv_S_2, 1, S_2, S_2_inv_pre)
bufferH64$ u_S_2_inv_buf (.out(S_2_inv), .in(S_2_inv_pre));
`INV_N(inv_ld_buf_data_V_i, 1, ld_buf_data_V_i, ld_buf_data_V_i_inv)
`INV_N(inv_writeBuf_V_i, 1, writeBuf_V_i, writeBuf_V_i_inv)
`INV_N(inv_write_Complete_i, 1, write_Complete_i, write_Complete_i_inv)

// NS_0 = (S_1 & !S_2 & ld_buf_data_V_i) | (S_0 & !S_2 & !write_Complete_i) | (S_0 & S_1 & !S_2)
wire NS_0_n0;
`NAND_3(NS_0_nand0, 1, NS_0_n0, S_1_a, S_2_inv, ld_buf_data_V_i)
wire NS_0_n1;
`NAND_3(NS_0_nand1, 1, NS_0_n1, S_0_a, S_2_inv, write_Complete_i_inv)
wire NS_0_n2;
`NAND_3(NS_0_nand2, 1, NS_0_n2, S_0_a, S_1_a, S_2_inv)

`NAND_3(NS_0_nand, 1, NS_0, NS_0_n0, NS_0_n1, NS_0_n2)

// NS_1 = (!S_0 & S_1 & !S_2 & !ld_buf_data_V_i) | (S_0 & !S_2 & !write_Complete_i & writeBuf_V_i) | (!S_0 & !S_1 & !S_2 & start_write_i) | (S_0 & !S_1 & !S_2 & !write_Complete_i) | (S_0 & S_1 & !S_2 & writeBuf_V_i)
wire NS_1_t0;
`AND_4(NS_1_and0, 1, NS_1_t0, S_0_inv, S_1_a, S_2_inv, ld_buf_data_V_i_inv)
wire NS_1_t1;
`AND_4(NS_1_and1, 1, NS_1_t1, S_0_a, S_2_inv, write_Complete_i_inv, writeBuf_V_i)
wire NS_1_t2;
`AND_4(NS_1_and2, 1, NS_1_t2, S_0_inv, S_1_inv, S_2_inv, start_write_i)
wire NS_1_t3;
`AND_4(NS_1_and3, 1, NS_1_t3, S_0_a, S_1_inv, S_2_inv, write_Complete_i_inv)
wire NS_1_t4;
`AND_4(NS_1_and4, 1, NS_1_t4, S_0_b, S_1_b, S_2_inv, writeBuf_V_i)

`OR_5(NS_1_or, 1, NS_1, NS_1_t0, NS_1_t1, NS_1_t2, NS_1_t3, NS_1_t4)

// NS_2 = (!S_0 & !S_1 & S_2)
`AND_3(NS_2_and, 1, NS_2, S_0_inv, S_1_inv, S_2)

// req_ld_o = (!S_0 & !S_1 & !S_2 & start_write_i)
`AND_4(req_ld_o_and, 1, req_ld_o, S_0_inv, S_1_inv, S_2_inv, start_write_i)

// ld_counter_o = (!S_0 & S_1 & !S_2 & ld_buf_data_V_i) -- buffered (fanout 33 external)
wire ld_counter_o_pre;
`AND_4(ld_counter_o_and, 1, ld_counter_o_pre, S_0_inv, S_1_b, S_2_inv, ld_buf_data_V_i)
bufferH64$ u_ld_counter_o_buf (.out(ld_counter_o), .in(ld_counter_o_pre));

// inc_counter_o = (S_0 & S_1 & !S_2 & !writeBuf_V_i)
`AND_4(inc_counter_o_and, 1, inc_counter_o, S_0_b, S_1_b, S_2_inv, writeBuf_V_i_inv)

// ld_writeBuf_o = (S_0 & !S_1 & !S_2 & !write_Complete_i) -- buffered (fanout 19 external)
wire ld_writeBuf_o_pre;
`AND_4(ld_writeBuf_o_and, 1, ld_writeBuf_o_pre, S_0_b, S_1_inv, S_2_inv, write_Complete_i_inv)
bufferH64$ u_ld_writeBuf_o_buf (.out(ld_writeBuf_o), .in(ld_writeBuf_o_pre));

// clr_start_write_bit_o = (S_0 & !S_1 & !S_2 & write_Complete_i)
`AND_4(clr_start_write_bit_o_and, 1, clr_start_write_bit_o, S_0_b, S_1_inv, S_2_inv, write_Complete_i)

// req_bus_o = (S_0 & S_1 & !S_2 & writeBuf_V_i)
`AND_4(req_bus_o_and, 1, req_bus_o, S_0_c, S_1_c, S_2_inv, writeBuf_V_i)

// busy_o = (S_0 & !S_2) | (S_1 & !S_2)
wire busy_o_n0;
`NAND_2(busy_o_nand0, 1, busy_o_n0, S_0_c, S_2_inv)
wire busy_o_n1;
`NAND_2(busy_o_nand1, 1, busy_o_n1, S_1_c, S_2_inv)

`NAND_2(busy_o_nand, 1, busy_o, busy_o_n0, busy_o_n1)

// interrupt_o = (S_0 & !S_1 & !S_2 & write_Complete_i)
`AND_4(interrupt_o_and, 1, interrupt_o, S_0_c, S_1_inv, S_2_inv, write_Complete_i)

endmodule
