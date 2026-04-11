// ======================================================================
// FSM : DMA_FSM
// Tool: fsm2rtl.py  (auto-generated -- do not hand-edit)
// Std : Verilog-2005 (IEEE 1364-2005)
// NOTE: ERROR state was synthesised automatically.
//       Any undefined transition lands here (all outputs = 0).
// ======================================================================
//
// State Enumeration  (3 bits, 5 states)
// --------------------------------------------------
//   IDLE                          000  (decimal 0)  // IDLE (reset state)
//   LD_BUF                        001  (decimal 1)
//   WAIT_FOR_LD                   010  (decimal 2)
//   WAIT_FOR_WR                   011  (decimal 3)
//   ERROR                         100  (decimal 4)  // ERROR (trap state), synthesised
//
// Truth Table (pre-expansion, original CSV rows)
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//         S_0         S_1         S_2  start_write_i  ld_buf_data_V_i  write_Complete_i  writeBuf_V_i  |        NS_0        NS_1        NS_2    req_ld_o  ld_counter_o  inc_counter_o  ld_writeBuf_o  clr_start_write_bit_o   req_bus_o      busy_o  interrupt_o   transition
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//           0           0           0           0           x           x           x  |           0           0           0           0           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           0           1           x           x           x  |           0           1           0           1           0           0           0           0           0           1           0   IDLE -> WAIT_FOR_LD
//           0           1           0           x           0           x           x  |           0           1           0           0           0           0           0           0           0           1           0   WAIT_FOR_LD -> WAIT_FOR_LD
//           0           1           0           x           1           x           x  |           1           0           0           0           1           0           0           0           0           1           0   WAIT_FOR_LD -> LD_BUF
//           1           0           0           x           x           0           x  |           1           1           0           0           0           1           1           0           0           1           0   LD_BUF -> WAIT_FOR_WR
//           1           0           0           x           x           1           x  |           0           0           0           0           0           0           0           1           0           1           1   LD_BUF -> IDLE
//           1           1           0           x           x           x           1  |           1           1           0           0           0           0           0           0           1           1           0   WAIT_FOR_WR -> WAIT_FOR_WR
//           1           1           0           x           x           x           0  |           1           0           0           0           0           0           0           0           0           1           0   WAIT_FOR_WR -> LD_BUF
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//

module DMA_FSM (
    input  wire clk,
    input  wire rst,
    input  wire start_write_i,
    input  wire ld_buf_data_V_i,
    input  wire write_Complete_i,
    input  wire writeBuf_V_i,
    output wire S_0,  // current-state bit 0 (LSB)
    output wire S_1,  // current-state bit 1 (1)
    output wire S_2,  // current-state bit 2 (MSB)
    output wire req_ld_o,
    output wire ld_counter_o,
    output wire inc_counter_o,
    output wire ld_writeBuf_o,
    output wire clr_start_write_bit_o,
    output wire req_bus_o,
    output wire busy_o,
    output wire interrupt_o
);

// ----------------------------------------------------------------
// Next-state wires  (NS_0 = LSB ... NS_{N-1} = MSB)
// ----------------------------------------------------------------
wire NS_0;
wire NS_1;
wire NS_2;

// State encoding  (IDLE = 0, ERROR = highest, guaranteed by tool)
//   IDLE                         = 000  (decimal 0)  // IDLE (reset state)
//   LD_BUF                       = 001  (decimal 1)
//   WAIT_FOR_LD                  = 010  (decimal 2)
//   WAIT_FOR_WR                  = 011  (decimal 3)
//   ERROR                        = 100  (decimal 4)  // ERROR (trap state), synthesised

// ----------------------------------------------------------------
// State flip-flops
// `REG_RST samples D on every rising clk edge.
// Active-high rst drives all state bits to 0 (= IDLE encoding).
// ----------------------------------------------------------------
`REG_RST(ff_0, 1, clk, rst, NS_0, S_0)
`REG_RST(ff_1, 1, clk, rst, NS_1, S_1)
`REG_RST(ff_2, 1, clk, rst, NS_2, S_2)

// ----------------------------------------------------------------
// Inverters for negated literals
// ----------------------------------------------------------------
wire S_0_inv;
wire S_1_inv;
wire S_2_inv;
wire ld_buf_data_V_i_inv;
wire write_Complete_i_inv;

`INV_N(inv_S_0, 1, S_0, S_0_inv)
`INV_N(inv_S_1, 1, S_1, S_1_inv)
`INV_N(inv_S_2, 1, S_2, S_2_inv)
`INV_N(inv_ld_buf_data_V_i, 1, ld_buf_data_V_i, ld_buf_data_V_i_inv)
`INV_N(inv_write_Complete_i, 1, write_Complete_i, write_Complete_i_inv)

// ----------------------------------------------------------------
// Next-state and output SOP logic
// ----------------------------------------------------------------

// NS_0 = (S_1 & !S_2 & ld_buf_data_V_i) | (S_0 & !S_2 & !write_Complete_i) | (S_0 & S_1 & !S_2)
wire NS_0_t0;
`AND_3(NS_0_and0, 1, NS_0_t0, S_1, S_2_inv, ld_buf_data_V_i)
wire NS_0_t1;
`AND_3(NS_0_and1, 1, NS_0_t1, S_0, S_2_inv, write_Complete_i_inv)
wire NS_0_t2;
`AND_3(NS_0_and2, 1, NS_0_t2, S_0, S_1, S_2_inv)

`OR_3(NS_0_or, 1, NS_0, NS_0_t0, NS_0_t1, NS_0_t2)

// NS_1 = (!S_1 & !S_2 & start_write_i & !write_Complete_i) | (S_1 & !S_2 & !ld_buf_data_V_i & writeBuf_V_i) | (!S_0 & S_1 & !S_2 & !ld_buf_data_V_i) | (S_0 & S_1 & !S_2 & writeBuf_V_i) | (!S_0 & !S_1 & !S_2 & start_write_i) | (S_0 & !S_1 & !S_2 & !write_Complete_i)
wire NS_1_t0;
`AND_4(NS_1_and0, 1, NS_1_t0, S_1_inv, S_2_inv, start_write_i, write_Complete_i_inv)
wire NS_1_t1;
`AND_4(NS_1_and1, 1, NS_1_t1, S_1, S_2_inv, ld_buf_data_V_i_inv, writeBuf_V_i)
wire NS_1_t2;
`AND_4(NS_1_and2, 1, NS_1_t2, S_0_inv, S_1, S_2_inv, ld_buf_data_V_i_inv)
wire NS_1_t3;
`AND_4(NS_1_and3, 1, NS_1_t3, S_0, S_1, S_2_inv, writeBuf_V_i)
wire NS_1_t4;
`AND_4(NS_1_and4, 1, NS_1_t4, S_0_inv, S_1_inv, S_2_inv, start_write_i)
wire NS_1_t5;
`AND_4(NS_1_and5, 1, NS_1_t5, S_0, S_1_inv, S_2_inv, write_Complete_i_inv)

`OR_6(NS_1_or, 1, NS_1, NS_1_t0, NS_1_t1, NS_1_t2, NS_1_t3, NS_1_t4, NS_1_t5)

// NS_2 = (!S_0 & !S_1 & S_2)
`AND_3(NS_2_and, 1, NS_2, S_0_inv, S_1_inv, S_2)

// req_ld_o = (!S_0 & !S_1 & !S_2 & start_write_i)
`AND_4(req_ld_o_and, 1, req_ld_o, S_0_inv, S_1_inv, S_2_inv, start_write_i)

// ld_counter_o = (!S_0 & S_1 & !S_2 & ld_buf_data_V_i)
`AND_4(ld_counter_o_and, 1, ld_counter_o, S_0_inv, S_1, S_2_inv, ld_buf_data_V_i)

// inc_counter_o = (S_0 & !S_1 & !S_2 & !write_Complete_i)
`AND_4(inc_counter_o_and, 1, inc_counter_o, S_0, S_1_inv, S_2_inv, write_Complete_i_inv)

// ld_writeBuf_o = (S_0 & !S_1 & !S_2 & !write_Complete_i)
`AND_4(ld_writeBuf_o_and, 1, ld_writeBuf_o, S_0, S_1_inv, S_2_inv, write_Complete_i_inv)

// clr_start_write_bit_o = (S_0 & !S_1 & !S_2 & write_Complete_i)
`AND_4(clr_start_write_bit_o_and, 1, clr_start_write_bit_o, S_0, S_1_inv, S_2_inv, write_Complete_i)

// req_bus_o = (S_0 & S_1 & !S_2 & writeBuf_V_i)
`AND_4(req_bus_o_and, 1, req_bus_o, S_0, S_1, S_2_inv, writeBuf_V_i)

// busy_o = (!S_2 & start_write_i) | (S_1 & !S_2) | (S_0 & !S_2)
wire busy_o_t0;
`AND_2(busy_o_and0, 1, busy_o_t0, S_2_inv, start_write_i)
wire busy_o_t1;
`AND_2(busy_o_and1, 1, busy_o_t1, S_1, S_2_inv)
wire busy_o_t2;
`AND_2(busy_o_and2, 1, busy_o_t2, S_0, S_2_inv)

`OR_3(busy_o_or, 1, busy_o, busy_o_t0, busy_o_t1, busy_o_t2)

// interrupt_o = (S_0 & !S_1 & !S_2 & write_Complete_i)
`AND_4(interrupt_o_and, 1, interrupt_o, S_0, S_1_inv, S_2_inv, write_Complete_i)

endmodule
