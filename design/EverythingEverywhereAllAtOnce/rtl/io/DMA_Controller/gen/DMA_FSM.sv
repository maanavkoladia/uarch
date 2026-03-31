// ======================================================================
// FSM : DMA_FSM
// Tool: fsm2rtl.py  (auto-generated -- do not hand-edit)
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

// Next-state wires  (NS_0=LSB ... NS_{N-1}=MSB)
wire NS_0;
wire NS_1;
wire NS_2;

// State encoding  (IDLE = 0, ERROR = highest, guaranteed by tool)
//   IDLE                         = 000  (decimal 0)  // IDLE (reset state)
//   LD_BUF                       = 001  (decimal 1)
//   WAIT_FOR_LD                  = 010  (decimal 2)
//   WAIT_FOR_WR                  = 011  (decimal 3)
//   ERROR                        = 100  (decimal 4)  // ERROR (trap state), synthesised

// State flip-flops  (reg1b, active-low async reset)
// Reset drives all state bits to 0, which is IDLE by construction.
reg1b ff_0 (
    .clk(clk),
    .rst(rst),
    .d(NS_0),
    .q(S_0)
);
reg1b ff_1 (
    .clk(clk),
    .rst(rst),
    .d(NS_1),
    .q(S_1)
);
reg1b ff_2 (
    .clk(clk),
    .rst(rst),
    .d(NS_2),
    .q(S_2)
);

// Inverters
wire S_0_inv;
wire S_1_inv;
wire S_2_inv;
wire ld_buf_data_V_i_inv;
wire write_Complete_i_inv;

inv1$ inv_S_0 (S_0_inv, S_0);
inv1$ inv_S_1 (S_1_inv, S_1);
inv1$ inv_S_2 (S_2_inv, S_2);
inv1$ inv_ld_buf_data_V_i (ld_buf_data_V_i_inv, ld_buf_data_V_i);
inv1$ inv_write_Complete_i (write_Complete_i_inv, write_Complete_i);

// Next-state and output SOP logic

// NS_0 = (S_0 & S_1 & !S_2) | (S_1 & !S_2 & ld_buf_data_V_i) | (S_0 & !S_2 & !write_Complete_i)
wire NS_0_t0;
wire NS_0_t1;
wire NS_0_t2;

and3$ NS_0_and0 (NS_0_t0, S_0, S_1, S_2_inv);
and3$ NS_0_and1 (NS_0_t1, S_1, S_2_inv, ld_buf_data_V_i);
and3$ NS_0_and2 (NS_0_t2, S_0, S_2_inv, write_Complete_i_inv);
or3$  NS_0_or  (NS_0, NS_0_t0, NS_0_t1, NS_0_t2);

<<<<<<< HEAD
// NS_1 = (!S_0 & !S_1 & !S_2 & start_write_i) | (S_0 & !S_2 & !write_Complete_i & writeBuf_V_i) | (!S_0 & S_1 & !S_2 & !ld_buf_data_V_i) | (S_0 & !S_1 & !S_2 & !write_Complete_i) | (S_0 & S_1 & !S_2 & writeBuf_V_i)
=======
// NS_1 = (S_1 & !S_2 & !ld_buf_data_V_i & writeBuf_V_i) | (S_0 & !S_1 & !S_2 & !write_Complete_i) | (!S_0 & !S_1 & !S_2 & start_write_i) | (S_0 & S_1 & !S_2 & writeBuf_V_i) | (!S_0 & S_1 & !S_2 & !ld_buf_data_V_i)
>>>>>>> icache-debuggin-branch
wire NS_1_t0;
wire NS_1_t1;
wire NS_1_t2;
wire NS_1_t3;
wire NS_1_t4;

<<<<<<< HEAD
and4$ NS_1_and0 (NS_1_t0, S_0_inv, S_1_inv, S_2_inv, start_write_i);
and4$ NS_1_and1 (NS_1_t1, S_0, S_2_inv, write_Complete_i_inv, writeBuf_V_i);
and4$ NS_1_and2 (NS_1_t2, S_0_inv, S_1, S_2_inv, ld_buf_data_V_i_inv);
and4$ NS_1_and3 (NS_1_t3, S_0, S_1_inv, S_2_inv, write_Complete_i_inv);
and4$ NS_1_and4 (NS_1_t4, S_0, S_1, S_2_inv, writeBuf_V_i);
=======
and4$ NS_1_and0 (NS_1_t0, S_1, S_2_inv, ld_buf_data_V_i_inv, writeBuf_V_i);
and4$ NS_1_and1 (NS_1_t1, S_0, S_1_inv, S_2_inv, write_Complete_i_inv);
and4$ NS_1_and2 (NS_1_t2, S_0_inv, S_1_inv, S_2_inv, start_write_i);
and4$ NS_1_and3 (NS_1_t3, S_0, S_1, S_2_inv, writeBuf_V_i);
and4$ NS_1_and4 (NS_1_t4, S_0_inv, S_1, S_2_inv, ld_buf_data_V_i_inv);
>>>>>>> icache-debuggin-branch
or5$  NS_1_or  (NS_1, NS_1_t0, NS_1_t1, NS_1_t2, NS_1_t3, NS_1_t4);

// NS_2 = (!S_0 & !S_1 & S_2)
and3$ NS_2_and (NS_2, S_0_inv, S_1_inv, S_2);

// req_ld_o = (!S_0 & !S_1 & !S_2 & start_write_i)
and4$ req_ld_o_and (req_ld_o, S_0_inv, S_1_inv, S_2_inv, start_write_i);

// ld_counter_o = (!S_0 & S_1 & !S_2 & ld_buf_data_V_i)
and4$ ld_counter_o_and (ld_counter_o, S_0_inv, S_1, S_2_inv, ld_buf_data_V_i);

// inc_counter_o = (S_0 & !S_1 & !S_2 & !write_Complete_i)
and4$ inc_counter_o_and (inc_counter_o, S_0, S_1_inv, S_2_inv, write_Complete_i_inv);

// ld_writeBuf_o = (S_0 & !S_1 & !S_2 & !write_Complete_i)
and4$ ld_writeBuf_o_and (ld_writeBuf_o, S_0, S_1_inv, S_2_inv, write_Complete_i_inv);

// clr_start_write_bit_o = (S_0 & !S_1 & !S_2 & write_Complete_i)
and4$ clr_start_write_bit_o_and (clr_start_write_bit_o, S_0, S_1_inv, S_2_inv, write_Complete_i);

// req_bus_o = (S_0 & S_1 & !S_2 & writeBuf_V_i)
and4$ req_bus_o_and (req_bus_o, S_0, S_1, S_2_inv, writeBuf_V_i);

<<<<<<< HEAD
// busy_o = (S_0 & !S_2) | (!S_2 & start_write_i) | (S_1 & !S_2)
=======
// busy_o = (S_1 & !S_2) | (S_0 & !S_2) | (!S_2 & start_write_i)
>>>>>>> icache-debuggin-branch
wire busy_o_t0;
wire busy_o_t1;
wire busy_o_t2;

<<<<<<< HEAD
and2$ busy_o_and0 (busy_o_t0, S_0, S_2_inv);
and2$ busy_o_and1 (busy_o_t1, S_2_inv, start_write_i);
and2$ busy_o_and2 (busy_o_t2, S_1, S_2_inv);
=======
and2$ busy_o_and0 (busy_o_t0, S_1, S_2_inv);
and2$ busy_o_and1 (busy_o_t1, S_0, S_2_inv);
and2$ busy_o_and2 (busy_o_t2, S_2_inv, start_write_i);
>>>>>>> icache-debuggin-branch
or3$  busy_o_or  (busy_o, busy_o_t0, busy_o_t1, busy_o_t2);

// interrupt_o = (S_0 & !S_1 & !S_2 & write_Complete_i)
and4$ interrupt_o_and (interrupt_o, S_0, S_1_inv, S_2_inv, write_Complete_i);

endmodule
