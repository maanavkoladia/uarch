module bank_controller_fsm_logic (
    input  wire clk,
    input  wire rst,
    input  wire ld_address_change_i,
    input  wire start_store_i,
    output wire st_addr_release_o,
    output wire OE_o,
    output wire WE_o,
    output wire clear_writebufV_o,
    output wire PreCharged_o
);

// Current-state and next-state wires
wire S_0;
wire S_1;
wire S_2;
wire S_3;
wire S_4;

wire NS_0;
wire NS_1;
wire NS_2;
wire NS_3;
wire NS_4;

// State encoding
//   IDLE                 = 00000 (decimal 0)
//   LD_ADDR_WAIT_0       = 00001 (decimal 1)
//   LD_WAIT_0            = 00010 (decimal 2)
//   LD_WAIT_1            = 00011 (decimal 3)
//   LD_WAIT_2            = 00100 (decimal 4)
//   LD_WAIT_3            = 00101 (decimal 5)
//   LD_WAIT_4            = 00110 (decimal 6)
//   LD_WAIT_5            = 00111 (decimal 7)
//   ST_ADDR_WAIT_0       = 01000 (decimal 8)
//   ST_ADDR_WAIT_1       = 01001 (decimal 9)
//   ST_ADDR_WAIT_2       = 01010 (decimal 10)
//   ST_ADDR_WAIT_3       = 01011 (decimal 11)
//   ST_WRITE_WAIT_0      = 01100 (decimal 12)
//   ST_WRITE_WAIT_1      = 01101 (decimal 13)
//   ST_WRITE_WAIT_2      = 01110 (decimal 14)
//   ST_WRITE_WAIT_3      = 01111 (decimal 15)
//   ST_WRITE_WAIT_4      = 10000 (decimal 16)
//   ST_WRITE_WAIT_5      = 10001 (decimal 17)

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
reg1b ff_4 (
    .clk(clk),
    .rst(rst),
    .d(NS_4),
    .q(S_4)
);

// Inversion wires and inv1$ instances
wire S_0_inv;
wire S_1_inv;
wire S_2_inv;
wire S_3_inv;
wire S_4_inv;
wire ld_address_change_i_inv;
wire start_store_i_inv;

inv1$ inv_S_0 (S_0_inv, S_0);
inv1$ inv_S_1 (S_1_inv, S_1);
inv1$ inv_S_2 (S_2_inv, S_2);
inv1$ inv_S_3 (S_3_inv, S_3);
inv1$ inv_S_4 (S_4_inv, S_4);
inv1$ inv_ld_address_change_i (ld_address_change_i_inv, ld_address_change_i);
inv1$ inv_start_store_i (start_store_i_inv, start_store_i);

// Next-state and output SOP logic

// NS_0 = (!S_0 & S_1 & S_2 & S_3 & S_4) | (S_0 & !S_1 & !S_2 & !S_3 & !S_4)
wire NS_0_t0;
wire NS_0_t1;

and5$ NS_0_and0 (NS_0_t0, S_0_inv, S_1, S_2, S_3, S_4);
and5$ NS_0_and1 (NS_0_t1, S_0, S_1_inv, S_2_inv, S_3_inv, S_4_inv);
or2$  NS_0_or  (NS_0, NS_0_t0, NS_0_t1);

// NS_1 = (!S_0 & !S_4 & start_store_i) | (!S_0 & S_1 & !S_3) | (!S_0 & S_1 & !S_2) | (!S_0 & !S_1 & S_3 & start_store_i) | (!S_0 & S_1 & !S_4) | (!S_0 & !S_1 & S_2 & start_store_i)
wire NS_1_t0;
wire NS_1_t1;
wire NS_1_t2;
wire NS_1_t3;
wire NS_1_t4;
wire NS_1_t5;

and3$ NS_1_and0 (NS_1_t0, S_0_inv, S_4_inv, start_store_i);
and3$ NS_1_and1 (NS_1_t1, S_0_inv, S_1, S_3_inv);
and3$ NS_1_and2 (NS_1_t2, S_0_inv, S_1, S_2_inv);
and4$ NS_1_and3 (NS_1_t3, S_0_inv, S_1_inv, S_3, start_store_i);
and3$ NS_1_and4 (NS_1_t4, S_0_inv, S_1, S_4_inv);
and4$ NS_1_and5 (NS_1_t5, S_0_inv, S_1_inv, S_2, start_store_i);
or6$  NS_1_or  (NS_1, NS_1_t0, NS_1_t1, NS_1_t2, NS_1_t3, NS_1_t4, NS_1_t5);

// NS_2 = (!S_0 & S_1 & S_2 & !S_3) | (!S_0 & S_1 & S_2 & !S_4) | (!S_0 & S_1 & !S_2 & S_3 & S_4) | (!S_0 & !S_1 & S_2 & !ld_address_change_i & !start_store_i) | (!S_0 & !S_1 & S_3 & S_4 & !ld_address_change_i & !start_store_i)
wire NS_2_t0;
wire NS_2_t1;
wire NS_2_t2;
wire NS_2_t3;
wire NS_2_t4;

and4$ NS_2_and0 (NS_2_t0, S_0_inv, S_1, S_2, S_3_inv);
and4$ NS_2_and1 (NS_2_t1, S_0_inv, S_1, S_2, S_4_inv);
and5$ NS_2_and2 (NS_2_t2, S_0_inv, S_1, S_2_inv, S_3, S_4);
and5$ NS_2_and3 (NS_2_t3, S_0_inv, S_1_inv, S_2, ld_address_change_i_inv, start_store_i_inv);
and6$ NS_2_and4 (NS_2_t4, S_0_inv, S_1_inv, S_3, S_4, ld_address_change_i_inv, start_store_i_inv);
or5$  NS_2_or  (NS_2, NS_2_t0, NS_2_t1, NS_2_t2, NS_2_t3, NS_2_t4);

// NS_3 = (!S_0 & S_3 & !S_4 & !start_store_i) | (!S_0 & S_1 & !S_3 & S_4) | (!S_0 & S_1 & S_3 & !S_4) | (!S_0 & !S_1 & S_2 & S_4 & !start_store_i) | (!S_0 & !S_1 & S_2 & ld_address_change_i & !start_store_i) | (!S_0 & !S_1 & S_3 & ld_address_change_i & !start_store_i)
wire NS_3_t0;
wire NS_3_t1;
wire NS_3_t2;
wire NS_3_t3;
wire NS_3_t4;
wire NS_3_t5;

and4$ NS_3_and0 (NS_3_t0, S_0_inv, S_3, S_4_inv, start_store_i_inv);
and4$ NS_3_and1 (NS_3_t1, S_0_inv, S_1, S_3_inv, S_4);
and4$ NS_3_and2 (NS_3_t2, S_0_inv, S_1, S_3, S_4_inv);
and5$ NS_3_and3 (NS_3_t3, S_0_inv, S_1_inv, S_2, S_4, start_store_i_inv);
and5$ NS_3_and4 (NS_3_t4, S_0_inv, S_1_inv, S_2, ld_address_change_i, start_store_i_inv);
and5$ NS_3_and5 (NS_3_t5, S_0_inv, S_1_inv, S_3, ld_address_change_i, start_store_i_inv);
or6$  NS_3_or  (NS_3, NS_3_t0, NS_3_t1, NS_3_t2, NS_3_t3, NS_3_t4, NS_3_t5);

// NS_4 = (!S_0 & S_1 & !S_4) | (!S_0 & !S_4 & !ld_address_change_i & !start_store_i) | (S_0 & !S_1 & !S_2 & !S_3 & !S_4) | (!S_1 & !S_2 & !S_3 & !S_4 & !start_store_i) | (!S_0 & !S_1 & S_2 & S_3 & !ld_address_change_i & !start_store_i)
wire NS_4_t0;
wire NS_4_t1;
wire NS_4_t2;
wire NS_4_t3;
wire NS_4_t4;

and3$ NS_4_and0 (NS_4_t0, S_0_inv, S_1, S_4_inv);
and4$ NS_4_and1 (NS_4_t1, S_0_inv, S_4_inv, ld_address_change_i_inv, start_store_i_inv);
and5$ NS_4_and2 (NS_4_t2, S_0, S_1_inv, S_2_inv, S_3_inv, S_4_inv);
and5$ NS_4_and3 (NS_4_t3, S_1_inv, S_2_inv, S_3_inv, S_4_inv, start_store_i_inv);
and6$ NS_4_and4 (NS_4_t4, S_0_inv, S_1_inv, S_2, S_3, ld_address_change_i_inv, start_store_i_inv);
or5$  NS_4_or  (NS_4, NS_4_t0, NS_4_t1, NS_4_t2, NS_4_t3, NS_4_t4);

// st_addr_release_o = (!S_0 & S_1) | (!S_0 & !S_4 & start_store_i) | (!S_0 & S_2 & start_store_i) | (S_0 & !S_1 & !S_2 & !S_3 & !S_4) | (!S_0 & S_3 & start_store_i)
wire st_addr_release_o_t0;
wire st_addr_release_o_t1;
wire st_addr_release_o_t2;
wire st_addr_release_o_t3;
wire st_addr_release_o_t4;

and2$ st_addr_release_o_and0 (st_addr_release_o_t0, S_0_inv, S_1);
and3$ st_addr_release_o_and1 (st_addr_release_o_t1, S_0_inv, S_4_inv, start_store_i);
and3$ st_addr_release_o_and2 (st_addr_release_o_t2, S_0_inv, S_2, start_store_i);
and5$ st_addr_release_o_and3 (st_addr_release_o_t3, S_0, S_1_inv, S_2_inv, S_3_inv, S_4_inv);
and3$ st_addr_release_o_and4 (st_addr_release_o_t4, S_0_inv, S_3, start_store_i);
or5$  st_addr_release_o_or  (st_addr_release_o, st_addr_release_o_t0, st_addr_release_o_t1, st_addr_release_o_t2, st_addr_release_o_t3, st_addr_release_o_t4);

// OE_o = (!S_0 & S_1) | (!S_0 & !S_4 & start_store_i) | (S_0 & !S_1 & !S_2 & !S_3) | (!S_0 & S_2 & start_store_i) | (!S_0 & S_3 & start_store_i)
wire OE_o_t0;
wire OE_o_t1;
wire OE_o_t2;
wire OE_o_t3;
wire OE_o_t4;

and2$ OE_o_and0 (OE_o_t0, S_0_inv, S_1);
and3$ OE_o_and1 (OE_o_t1, S_0_inv, S_4_inv, start_store_i);
and4$ OE_o_and2 (OE_o_t2, S_0, S_1_inv, S_2_inv, S_3_inv);
and3$ OE_o_and3 (OE_o_t3, S_0_inv, S_2, start_store_i);
and3$ OE_o_and4 (OE_o_t4, S_0_inv, S_3, start_store_i);
or5$  OE_o_or  (OE_o, OE_o_t0, OE_o_t1, OE_o_t2, OE_o_t3, OE_o_t4);

// WE_o = (!S_0 & !S_1 & S_3) | (!S_0 & !S_2 & !S_4) | (!S_0 & !S_1 & S_2) | (!S_0 & S_1 & !S_2 & !S_3) | (S_0 & !S_1 & !S_2 & !S_3 & S_4)
wire WE_o_t0;
wire WE_o_t1;
wire WE_o_t2;
wire WE_o_t3;
wire WE_o_t4;

and3$ WE_o_and0 (WE_o_t0, S_0_inv, S_1_inv, S_3);
and3$ WE_o_and1 (WE_o_t1, S_0_inv, S_2_inv, S_4_inv);
and3$ WE_o_and2 (WE_o_t2, S_0_inv, S_1_inv, S_2);
and4$ WE_o_and3 (WE_o_t3, S_0_inv, S_1, S_2_inv, S_3_inv);
and5$ WE_o_and4 (WE_o_t4, S_0, S_1_inv, S_2_inv, S_3_inv, S_4);
or5$  WE_o_or  (WE_o, WE_o_t0, WE_o_t1, WE_o_t2, WE_o_t3, WE_o_t4);

// clear_writebufV_o = (S_0 & !S_1 & !S_2 & !S_3 & S_4)
and5$ clear_writebufV_o_and (clear_writebufV_o, S_0, S_1_inv, S_2_inv, S_3_inv, S_4);

// PreCharged_o = (!S_0 & !S_1 & S_2 & S_3 & S_4 & !ld_address_change_i & !start_store_i)
and7$ PreCharged_o_and (PreCharged_o, S_0_inv, S_1_inv, S_2, S_3, S_4, ld_address_change_i_inv, start_store_i_inv);

endmodule
