module mem_controller_fsm (
    input  wire clk,
    input  wire rst,
    input  wire ld_req_i,
    input  wire write_req_i,
    input  wire hit_i,
    output wire mem_ready_o,
    output wire set_ld_tristate_o,
    output wire start_store_o,
    output wire ld_address_changed_o,
    output wire set_WriteBuf_V_o,
    output wire fill0_o,
    output wire fill1_o,
    output wire fill2_o,
    output wire fill3_o
);

// Current-state and next-state wires
wire S_0;
wire S_1;
wire S_2;
wire S_3;

wire NS_0;
wire NS_1;
wire NS_2;
wire NS_3;

// State encoding
//   ERROR                = 0000 (decimal 0)
//   IDLE                 = 0001 (decimal 1)
//   LD_0                 = 0010 (decimal 2)
//   LD_1                 = 0011 (decimal 3)
//   LD_2                 = 0100 (decimal 4)
//   LD_HIT               = 0101 (decimal 5)
//   LD_MISS              = 0110 (decimal 6)
//   W0                   = 0111 (decimal 7)
//   W1                   = 1000 (decimal 8)
//   W2                   = 1001 (decimal 9)

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
reg1b ff_3 (
    .clk(clk),
    .rst(rst),
    .d(NS_3),
    .q(S_3)
);

// Inversion wires and inv1$ instances
wire S_0_inv;
wire S_1_inv;
wire S_2_inv;
wire S_3_inv;
wire hit_i_inv;
wire ld_req_i_inv;
wire write_req_i_inv;

inv1$ inv_S_0 (S_0_inv, S_0);
inv1$ inv_S_1 (S_1_inv, S_1);
inv1$ inv_S_2 (S_2_inv, S_2);
inv1$ inv_S_3 (S_3_inv, S_3);
inv1$ inv_hit_i (hit_i_inv, hit_i);
inv1$ inv_ld_req_i (ld_req_i_inv, ld_req_i);
inv1$ inv_write_req_i (write_req_i_inv, write_req_i);

// Next-state and output SOP logic

// NS_0 = (!S_0 & S_1 & S_2 & S_3) | (S_0 & !S_1 & !S_2 & !S_3)
wire NS_0_t0;
wire NS_0_t1;

and4$ NS_0_and0 (NS_0_t0, S_0_inv, S_1, S_2, S_3);
and4$ NS_0_and1 (NS_0_t1, S_0, S_1_inv, S_2_inv, S_3_inv);
or2$  NS_0_or  (NS_0, NS_0_t0, NS_0_t1);

// NS_1 = (!S_0 & S_1 & !S_3) | (!S_0 & !S_1 & !S_2 & S_3 & !ld_req_i & write_req_i) | (!S_0 & !S_1 & !S_2 & S_3 & ld_req_i & !write_req_i)
wire NS_1_t0;
wire NS_1_t1;
wire NS_1_t2;

and3$ NS_1_and0 (NS_1_t0, S_0_inv, S_1, S_3_inv);
and6$ NS_1_and1 (NS_1_t1, S_0_inv, S_1_inv, S_2_inv, S_3, ld_req_i_inv, write_req_i);
and6$ NS_1_and2 (NS_1_t2, S_0_inv, S_1_inv, S_2_inv, S_3, ld_req_i, write_req_i_inv);
or3$  NS_1_or  (NS_1, NS_1_t0, NS_1_t1, NS_1_t2);

// NS_2 = (!S_0 & S_1 & !S_2 & S_3) | (!S_0 & S_2 & !S_3 & !hit_i) | (!S_0 & !S_1 & S_2 & !S_3) | (!S_0 & !S_2 & S_3 & !ld_req_i & write_req_i) | (!S_0 & !S_2 & S_3 & ld_req_i & !write_req_i & !hit_i)
wire NS_2_t0;
wire NS_2_t1;
wire NS_2_t2;
wire NS_2_t3;
wire NS_2_t4;

and4$ NS_2_and0 (NS_2_t0, S_0_inv, S_1, S_2_inv, S_3);
and4$ NS_2_and1 (NS_2_t1, S_0_inv, S_2, S_3_inv, hit_i_inv);
and4$ NS_2_and2 (NS_2_t2, S_0_inv, S_1_inv, S_2, S_3_inv);
and5$ NS_2_and3 (NS_2_t3, S_0_inv, S_2_inv, S_3, ld_req_i_inv, write_req_i);
and6$ NS_2_and4 (NS_2_t4, S_0_inv, S_2_inv, S_3, ld_req_i, write_req_i_inv, hit_i_inv);
or5$  NS_2_or  (NS_2, NS_2_t0, NS_2_t1, NS_2_t2, NS_2_t3, NS_2_t4);

// NS_3 = (S_0 & !S_1 & !S_2) | (!S_0 & S_2 & !S_3 & hit_i) | (!S_0 & !S_1 & S_2 & !S_3) | (!S_1 & !S_2 & S_3 & !ld_req_i & write_req_i) | (!S_1 & !S_2 & S_3 & ld_req_i & !write_req_i & hit_i)
wire NS_3_t0;
wire NS_3_t1;
wire NS_3_t2;
wire NS_3_t3;
wire NS_3_t4;

and3$ NS_3_and0 (NS_3_t0, S_0, S_1_inv, S_2_inv);
and4$ NS_3_and1 (NS_3_t1, S_0_inv, S_2, S_3_inv, hit_i);
and4$ NS_3_and2 (NS_3_t2, S_0_inv, S_1_inv, S_2, S_3_inv);
and5$ NS_3_and3 (NS_3_t3, S_1_inv, S_2_inv, S_3, ld_req_i_inv, write_req_i);
and6$ NS_3_and4 (NS_3_t4, S_1_inv, S_2_inv, S_3, ld_req_i, write_req_i_inv, hit_i);
or5$  NS_3_or  (NS_3, NS_3_t0, NS_3_t1, NS_3_t2, NS_3_t3, NS_3_t4);

// mem_ready_o = (!S_0 & S_1 & S_2 & !S_3 & hit_i) | (!S_0 & !S_1 & !S_2 & S_3 & ld_req_i & !write_req_i & hit_i)
wire mem_ready_o_t0;
wire mem_ready_o_t1;

and5$ mem_ready_o_and0 (mem_ready_o_t0, S_0_inv, S_1, S_2, S_3_inv, hit_i);
and7$ mem_ready_o_and1 (mem_ready_o_t1, S_0_inv, S_1_inv, S_2_inv, S_3, ld_req_i, write_req_i_inv, hit_i);
or2$  mem_ready_o_or  (mem_ready_o, mem_ready_o_t0, mem_ready_o_t1);

// set_ld_tristate_o = (!S_0 & S_1 & !S_2) | (!S_0 & S_2 & !S_3 & hit_i) | (!S_0 & !S_1 & S_2 & !S_3) | (!S_0 & !S_2 & S_3 & ld_req_i & !write_req_i & hit_i)
wire set_ld_tristate_o_t0;
wire set_ld_tristate_o_t1;
wire set_ld_tristate_o_t2;
wire set_ld_tristate_o_t3;

and3$ set_ld_tristate_o_and0 (set_ld_tristate_o_t0, S_0_inv, S_1, S_2_inv);
and4$ set_ld_tristate_o_and1 (set_ld_tristate_o_t1, S_0_inv, S_2, S_3_inv, hit_i);
and4$ set_ld_tristate_o_and2 (set_ld_tristate_o_t2, S_0_inv, S_1_inv, S_2, S_3_inv);
and6$ set_ld_tristate_o_and3 (set_ld_tristate_o_t3, S_0_inv, S_2_inv, S_3, ld_req_i, write_req_i_inv, hit_i);
or4$  set_ld_tristate_o_or  (set_ld_tristate_o, set_ld_tristate_o_t0, set_ld_tristate_o_t1, set_ld_tristate_o_t2, set_ld_tristate_o_t3);

// start_store_o = 0  (no ON-set minterms)
assign start_store_o = 1'b0;

// ld_address_changed_o = (!S_0 & !S_1 & !S_2 & S_3 & ld_req_i & !write_req_i & !hit_i)
and7$ ld_address_changed_o_and (ld_address_changed_o, S_0_inv, S_1_inv, S_2_inv, S_3, ld_req_i, write_req_i_inv, hit_i_inv);

// set_WriteBuf_V_o = (S_0 & !S_1 & !S_2 & S_3)
and4$ set_WriteBuf_V_o_and (set_WriteBuf_V_o, S_0, S_1_inv, S_2_inv, S_3);

// fill0_o = (!S_0 & !S_1 & !S_2 & S_3 & !ld_req_i & write_req_i)
and6$ fill0_o_and (fill0_o, S_0_inv, S_1_inv, S_2_inv, S_3, ld_req_i_inv, write_req_i);

// fill1_o = (!S_0 & S_1 & S_2 & S_3)
and4$ fill1_o_and (fill1_o, S_0_inv, S_1, S_2, S_3);

// fill2_o = (S_0 & !S_1 & !S_2 & !S_3)
and4$ fill2_o_and (fill2_o, S_0, S_1_inv, S_2_inv, S_3_inv);

// fill3_o = (S_0 & !S_1 & !S_2 & S_3)
and4$ fill3_o_and (fill3_o, S_0, S_1_inv, S_2_inv, S_3);

endmodule
