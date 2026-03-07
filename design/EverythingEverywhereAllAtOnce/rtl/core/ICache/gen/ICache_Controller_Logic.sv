module ICache_Controller_Logic (
    input  wire clk,
    input  wire rst,
    input  wire hit_or_miss_i,
    input  wire mem_valid_i,
    output wire mem_request_o,
    output wire fill0_o,
    output wire  fill1_o,
    output wire  fill2_o,
    output wire  fill3_o
);

// Current-state and next-state wires
wire S_0;
wire S_1;
wire S_2;

wire NS_0;
wire NS_1;
wire NS_2;

// State encoding
//   Fill0                = 000 (decimal 0)
//   Fill1                = 001 (decimal 1)
//   Fill2                = 010 (decimal 2)
//   Fill3                = 011 (decimal 3)
//   IDLE                 = 100 (decimal 4)

// State flip-flops (reg1b, active-low async reset)
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

// Inversion wires and inv1$ instances
wire S_0_inv;
wire S_1_inv;
wire S_2_inv;
wire mem_valid_i_inv;

inv1$ inv_S_0 (S_0_inv, S_0);
inv1$ inv_S_1 (S_1_inv, S_1);
inv1$ inv_S_2 (S_2_inv, S_2);
inv1$ inv_mem_valid_i (mem_valid_i_inv, mem_valid_i);

// Next-state and output SOP logic

// NS_0 = (!S_0 & S_1 & S_2 & mem_valid_i) | (S_0 & !S_1 & !S_2 & hit_or_miss_i)
wire NS_0_t0;
wire NS_0_t1;

and4$ NS_0_and0 (NS_0_t0, S_0_inv, S_1, S_2, mem_valid_i);
and4$ NS_0_and1 (NS_0_t1, S_0, S_1_inv, S_2_inv, hit_or_miss_i);
or2$  NS_0_or  (NS_0, NS_0_t0, NS_0_t1);

// NS_1 = (!S_0 & S_1 & !mem_valid_i) | (!S_0 & S_1 & !S_2) | (!S_0 & !S_1 & S_2 & mem_valid_i)
wire NS_1_t0;
wire NS_1_t1;
wire NS_1_t2;

and3$ NS_1_and0 (NS_1_t0, S_0_inv, S_1, mem_valid_i_inv);
and3$ NS_1_and1 (NS_1_t1, S_0_inv, S_1, S_2_inv);
and4$ NS_1_and2 (NS_1_t2, S_0_inv, S_1_inv, S_2, mem_valid_i);
or3$  NS_1_or  (NS_1, NS_1_t0, NS_1_t1, NS_1_t2);

// NS_2 = (!S_0 & S_2 & !mem_valid_i) | (!S_0 & !S_2 & mem_valid_i)
wire NS_2_t0;
wire NS_2_t1;

and3$ NS_2_and0 (NS_2_t0, S_0_inv, S_2, mem_valid_i_inv);
and3$ NS_2_and1 (NS_2_t1, S_0_inv, S_2_inv, mem_valid_i);
or2$  NS_2_or  (NS_2, NS_2_t0, NS_2_t1);

// mem_request_o = !S_0 | (!S_1 & !S_2 & hit_or_miss_i)
wire mem_request_o_t0;
wire mem_request_o_t1;

buffer$ mem_request_o_buf0 (mem_request_o_t0, S_0_inv);
and3$ mem_request_o_and1 (mem_request_o_t1, S_1_inv, S_2_inv, hit_or_miss_i);
or2$  mem_request_o_or  (mem_request_o, mem_request_o_t0, mem_request_o_t1);

// fill0_o = (!S_0 & S_1) | (!S_0 & S_2) | (!S_1 & !S_2 & !mem_valid_i) | (S_0 & !S_1 & !S_2)
wire fill0_o_t0;
wire fill0_o_t1;
wire fill0_o_t2;
wire fill0_o_t3;

and2$ fill0_o_and0 (fill0_o_t0, S_0_inv, S_1);
and2$ fill0_o_and1 (fill0_o_t1, S_0_inv, S_2);
and3$ fill0_o_and2 (fill0_o_t2, S_1_inv, S_2_inv, mem_valid_i_inv);
and3$ fill0_o_and3 (fill0_o_t3, S_0, S_1_inv, S_2_inv);
or4$  fill0_o_or  (fill0_o, fill0_o_t0, fill0_o_t1, fill0_o_t2, fill0_o_t3);

//  fill1_o = (!S_1 & !S_2) | (!S_0 & S_1) | (!S_0 & !mem_valid_i)
wire  fill1_o_t0;
wire  fill1_o_t1;
wire  fill1_o_t2;

and2$  fill1_o_and0 ( fill1_o_t0, S_1_inv, S_2_inv);
and2$  fill1_o_and1 ( fill1_o_t1, S_0_inv, S_1);
and2$  fill1_o_and2 ( fill1_o_t2, S_0_inv, mem_valid_i_inv);
or3$   fill1_o_or  ( fill1_o,  fill1_o_t0,  fill1_o_t1,  fill1_o_t2);

//  fill2_o = (!S_1 & !S_2) | (!S_0 & S_2) | (!S_0 & !mem_valid_i)
wire  fill2_o_t0;
wire  fill2_o_t1;
wire  fill2_o_t2;

and2$  fill2_o_and0 ( fill2_o_t0, S_1_inv, S_2_inv);
and2$  fill2_o_and1 ( fill2_o_t1, S_0_inv, S_2);
and2$  fill2_o_and2 ( fill2_o_t2, S_0_inv, mem_valid_i_inv);
or3$   fill2_o_or  ( fill2_o,  fill2_o_t0,  fill2_o_t1,  fill2_o_t2);

//  fill3_o = (!S_0 & !S_2) | (!S_1 & !S_2) | (!S_0 & !mem_valid_i) | (!S_0 & !S_1)
wire  fill3_o_t0;
wire  fill3_o_t1;
wire  fill3_o_t2;
wire  fill3_o_t3;

and2$  fill3_o_and0 ( fill3_o_t0, S_0_inv, S_2_inv);
and2$  fill3_o_and1 ( fill3_o_t1, S_1_inv, S_2_inv);
and2$  fill3_o_and2 ( fill3_o_t2, S_0_inv, mem_valid_i_inv);
and2$  fill3_o_and3 ( fill3_o_t3, S_0_inv, S_1_inv);
or4$   fill3_o_or  ( fill3_o,  fill3_o_t0,  fill3_o_t1,  fill3_o_t2,  fill3_o_t3);

endmodule
