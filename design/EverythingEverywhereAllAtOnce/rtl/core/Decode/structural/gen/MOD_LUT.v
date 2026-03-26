module MOD_LUT (
    output msd_size_2_o,
    output msd_size_1_o,
    output msd_size_0_o,
    input  input_7_i,
    input  input_6_i,
    input  input_5_i,
    input  input_4_i,
    input  input_3_i,
    input  input_2_i,
    input  input_1_i,
    input  input_0_i
);

wire input_0_i_inv;
wire input_1_i_inv;
wire input_2_i_inv;
wire input_6_i_inv;
wire input_7_i_inv;

inv1$ inv_input_0_i (input_0_i_inv, input_0_i);
inv1$ inv_input_1_i (input_1_i_inv, input_1_i);
inv1$ inv_input_2_i (input_2_i_inv, input_2_i);
inv1$ inv_input_6_i (input_6_i_inv, input_6_i);
inv1$ inv_input_7_i (input_7_i_inv, input_7_i);

// msd_size_2_o = (input_7_i & !input_6_i) | (!input_6_i & input_2_i & !input_1_i & input_0_i)
wire msd_size_2_o_t0;
wire msd_size_2_o_t1;

and2$ msd_size_2_o_and0 (msd_size_2_o_t0, input_7_i, input_6_i_inv);
and4$ msd_size_2_o_and1 (msd_size_2_o_t1, input_6_i_inv, input_2_i, input_1_i_inv, input_0_i);
or2$  msd_size_2_o_or  (msd_size_2_o, msd_size_2_o_t0, msd_size_2_o_t1);

// msd_size_1_o = (!input_7_i & input_6_i) | (!input_6_i & input_2_i & !input_1_i & !input_0_i)
wire msd_size_1_o_t0;
wire msd_size_1_o_t1;

and2$ msd_size_1_o_and0 (msd_size_1_o_t0, input_7_i_inv, input_6_i);
and4$ msd_size_1_o_and1 (msd_size_1_o_t1, input_6_i_inv, input_2_i, input_1_i_inv, input_0_i_inv);
or2$  msd_size_1_o_or  (msd_size_1_o, msd_size_1_o_t0, msd_size_1_o_t1);

// msd_size_0_o = (input_7_i & !input_2_i) | (!input_6_i & input_1_i) | (input_7_i & input_6_i) | (!input_6_i & input_0_i) | (!input_6_i & !input_2_i) | (input_6_i & input_2_i & !input_1_i & !input_0_i)
wire msd_size_0_o_t0;
wire msd_size_0_o_t1;
wire msd_size_0_o_t2;
wire msd_size_0_o_t3;
wire msd_size_0_o_t4;
wire msd_size_0_o_t5;

and2$ msd_size_0_o_and0 (msd_size_0_o_t0, input_7_i, input_2_i_inv);
and2$ msd_size_0_o_and1 (msd_size_0_o_t1, input_6_i_inv, input_1_i);
and2$ msd_size_0_o_and2 (msd_size_0_o_t2, input_7_i, input_6_i);
and2$ msd_size_0_o_and3 (msd_size_0_o_t3, input_6_i_inv, input_0_i);
and2$ msd_size_0_o_and4 (msd_size_0_o_t4, input_6_i_inv, input_2_i_inv);
and4$ msd_size_0_o_and5 (msd_size_0_o_t5, input_6_i, input_2_i, input_1_i_inv, input_0_i_inv);
or6$  msd_size_0_o_or  (msd_size_0_o, msd_size_0_o_t0, msd_size_0_o_t1, msd_size_0_o_t2, msd_size_0_o_t3, msd_size_0_o_t4, msd_size_0_o_t5);

endmodule
