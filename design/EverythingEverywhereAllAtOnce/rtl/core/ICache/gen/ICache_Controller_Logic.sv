// ======================================================================
// FSM : ICache_Controller_Logic
// Tool: fsm2rtl.py  (auto-generated -- do not hand-edit)
// ======================================================================
//
// State Enumeration  (3 bits, 5 states)
// --------------------------------------------------
//   IDLE                          000  (decimal 0)  // IDLE (reset state)
//   Fill0                         001  (decimal 1)
//   Fill1                         010  (decimal 2)
//   Fill2                         011  (decimal 3)
//   Fill3                         100  (decimal 4)
//
// Truth Table (pre-expansion, original CSV rows)
// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
//         S_0         S_1         S_2  hit_or_miss_i  mem_valid_i  |        NS_0        NS_1        NS_2  mem_request_o     fill0_o     fill1_o     fill2_o     fill3_o   transition
// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
//           1           0           0           x           0  |           1           0           0           1           1           1           1           1   Fill0 -> Fill0
//           1           0           0           x           1  |           0           1           0           1           0           1           1           1   Fill0 -> Fill1
//           0           1           0           x           0  |           0           1           0           1           1           1           1           1   Fill1 -> Fill1
//           0           1           0           x           1  |           1           1           0           1           1           0           1           1   Fill1 -> Fill2
//           1           1           0           x           0  |           1           1           0           1           1           1           1           1   Fill2 -> Fill2
//           1           1           0           x           1  |           0           0           1           1           1           1           0           1   Fill2 -> Fill3
//           0           0           1           x           0  |           0           0           1           1           1           1           1           1   Fill3 -> Fill3
//           0           0           1           x           1  |           0           0           0           1           1           1           1           0   Fill3 -> IDLE
//           0           0           0           0           x  |           1           0           0           0           1           1           1           1   IDLE -> Fill0
//           0           0           0           1           x  |           0           0           0           1           1           1           1           1   IDLE -> IDLE
// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
//

module ICache_Controller_Logic (
    input  wire clk,
    input  wire rst,
    input  wire hit_or_miss_i,
    input  wire mem_valid_i,
    output wire S_0,  // current-state bit 0 (LSB)
    output wire S_1,  // current-state bit 1 (1)
    output wire S_2,  // current-state bit 2 (MSB)
    output wire mem_request_o,
    output wire fill0_o,
    output wire  fill1_o,
    output wire  fill2_o,
    output wire  fill3_o
);

// Next-state wires  (NS_0=LSB ... NS_{N-1}=MSB)
wire NS_0;
wire NS_1;
wire NS_2;

// State encoding  (IDLE = 0, guaranteed by tool)
//   IDLE                         = 000  (decimal 0)  // IDLE (reset state)
//   Fill0                        = 001  (decimal 1)
//   Fill1                        = 010  (decimal 2)
//   Fill2                        = 011  (decimal 3)
//   Fill3                        = 100  (decimal 4)

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
wire hit_or_miss_i_inv;
wire mem_valid_i_inv;

inv1$ inv_S_0 (S_0_inv, S_0);
inv1$ inv_S_1 (S_1_inv, S_1);
inv1$ inv_S_2 (S_2_inv, S_2);
inv1$ inv_hit_or_miss_i (hit_or_miss_i_inv, hit_or_miss_i);
inv1$ inv_mem_valid_i (mem_valid_i_inv, mem_valid_i);

// Next-state and output SOP logic

// NS_0 = (S_0 & !S_2 & !mem_valid_i) | (!S_0 & !S_1 & !S_2 & !hit_or_miss_i) | (!S_0 & S_1 & !S_2 & mem_valid_i)
wire NS_0_t0;
wire NS_0_t1;
wire NS_0_t2;

and3$ NS_0_and0 (NS_0_t0, S_0, S_2_inv, mem_valid_i_inv);
and4$ NS_0_and1 (NS_0_t1, S_0_inv, S_1_inv, S_2_inv, hit_or_miss_i_inv);
and4$ NS_0_and2 (NS_0_t2, S_0_inv, S_1, S_2_inv, mem_valid_i);
or3$  NS_0_or  (NS_0, NS_0_t0, NS_0_t1, NS_0_t2);

// NS_1 = (!S_0 & S_1 & !S_2) | (S_1 & !S_2 & !mem_valid_i) | (S_0 & !S_1 & !S_2 & mem_valid_i)
wire NS_1_t0;
wire NS_1_t1;
wire NS_1_t2;

and3$ NS_1_and0 (NS_1_t0, S_0_inv, S_1, S_2_inv);
and3$ NS_1_and1 (NS_1_t1, S_1, S_2_inv, mem_valid_i_inv);
and4$ NS_1_and2 (NS_1_t2, S_0, S_1_inv, S_2_inv, mem_valid_i);
or3$  NS_1_or  (NS_1, NS_1_t0, NS_1_t1, NS_1_t2);

// NS_2 = (S_0 & S_1 & !S_2 & mem_valid_i) | (!S_0 & !S_1 & S_2 & !mem_valid_i)
wire NS_2_t0;
wire NS_2_t1;

and4$ NS_2_and0 (NS_2_t0, S_0, S_1, S_2_inv, mem_valid_i);
and4$ NS_2_and1 (NS_2_t1, S_0_inv, S_1_inv, S_2, mem_valid_i_inv);
or2$  NS_2_or  (NS_2, NS_2_t0, NS_2_t1);

// mem_request_o = (!S_2 & hit_or_miss_i) | (S_1 & !S_2) | (!S_0 & !S_1 & S_2) | (S_0 & !S_2)
wire mem_request_o_t0;
wire mem_request_o_t1;
wire mem_request_o_t2;
wire mem_request_o_t3;

and2$ mem_request_o_and0 (mem_request_o_t0, S_2_inv, hit_or_miss_i);
and2$ mem_request_o_and1 (mem_request_o_t1, S_1, S_2_inv);
and3$ mem_request_o_and2 (mem_request_o_t2, S_0_inv, S_1_inv, S_2);
and2$ mem_request_o_and3 (mem_request_o_t3, S_0, S_2_inv);
or4$  mem_request_o_or  (mem_request_o, mem_request_o_t0, mem_request_o_t1, mem_request_o_t2, mem_request_o_t3);

// fill0_o = (S_1 & !S_2) | (!S_0 & !S_1) | (!S_2 & !mem_valid_i)
wire fill0_o_t0;
wire fill0_o_t1;
wire fill0_o_t2;

and2$ fill0_o_and0 (fill0_o_t0, S_1, S_2_inv);
and2$ fill0_o_and1 (fill0_o_t1, S_0_inv, S_1_inv);
and2$ fill0_o_and2 (fill0_o_t2, S_2_inv, mem_valid_i_inv);
or3$  fill0_o_or  (fill0_o, fill0_o_t0, fill0_o_t1, fill0_o_t2);

//  fill1_o = (S_0 & !S_2) | (!S_0 & !S_1) | (!S_2 & !mem_valid_i)
wire  fill1_o_t0;
wire  fill1_o_t1;
wire  fill1_o_t2;

and2$  fill1_o_and0 ( fill1_o_t0, S_0, S_2_inv);
and2$  fill1_o_and1 ( fill1_o_t1, S_0_inv, S_1_inv);
and2$  fill1_o_and2 ( fill1_o_t2, S_2_inv, mem_valid_i_inv);
or3$   fill1_o_or  ( fill1_o,  fill1_o_t0,  fill1_o_t1,  fill1_o_t2);

//  fill2_o = (!S_0 & !S_1) | (!S_2 & !mem_valid_i) | (!S_1 & !S_2) | (!S_0 & !S_2)
wire  fill2_o_t0;
wire  fill2_o_t1;
wire  fill2_o_t2;
wire  fill2_o_t3;

and2$  fill2_o_and0 ( fill2_o_t0, S_0_inv, S_1_inv);
and2$  fill2_o_and1 ( fill2_o_t1, S_2_inv, mem_valid_i_inv);
and2$  fill2_o_and2 ( fill2_o_t2, S_1_inv, S_2_inv);
and2$  fill2_o_and3 ( fill2_o_t3, S_0_inv, S_2_inv);
or4$   fill2_o_or  ( fill2_o,  fill2_o_t0,  fill2_o_t1,  fill2_o_t2,  fill2_o_t3);

//  fill3_o = !S_2 | (!S_0 & !S_1 & !mem_valid_i)
wire  fill3_o_t0;
wire  fill3_o_t1;

buffer$  fill3_o_buf0 ( fill3_o_t0, S_2_inv);
and3$  fill3_o_and1 ( fill3_o_t1, S_0_inv, S_1_inv, mem_valid_i_inv);
or2$   fill3_o_or  ( fill3_o,  fill3_o_t0,  fill3_o_t1);

endmodule
