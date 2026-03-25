module OP_LUT (
    output needrm_o,
    output imm_size_2_o,
    output imm_size_1_o,
    output imm_size_0_o,
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
wire input_3_i_inv;
wire input_4_i_inv;
wire input_5_i_inv;
wire input_6_i_inv;
wire input_7_i_inv;

inv1$ inv_input_0_i (input_0_i_inv, input_0_i);
inv1$ inv_input_1_i (input_1_i_inv, input_1_i);
inv1$ inv_input_2_i (input_2_i_inv, input_2_i);
inv1$ inv_input_3_i (input_3_i_inv, input_3_i);
inv1$ inv_input_4_i (input_4_i_inv, input_4_i);
inv1$ inv_input_5_i (input_5_i_inv, input_5_i);
inv1$ inv_input_6_i (input_6_i_inv, input_6_i);
inv1$ inv_input_7_i (input_7_i_inv, input_7_i);

// needrm_o = (!input_7_i & !input_6_i & !input_4_i & !input_3_i & !input_2_i) | (input_7_i & !input_6_i & !input_5_i & !input_4_i & input_3_i & !input_2_i) | (input_7_i & !input_6_i & !input_5_i & !input_4_i & !input_2_i & !input_1_i) | (input_7_i & !input_6_i & !input_5_i & !input_4_i & input_3_i & !input_0_i) | (!input_7_i & !input_6_i & !input_5_i & !input_3_i & !input_2_i & input_0_i) | (input_7_i & !input_6_i & input_5_i & input_4_i & !input_3_i & !input_2_i & !input_1_i) | (input_7_i & input_6_i & !input_5_i & !input_4_i & !input_3_i & input_2_i & input_1_i) | (input_7_i & !input_6_i & !input_5_i & !input_4_i & !input_2_i & input_0_i) | (!input_7_i & !input_5_i & !input_4_i & !input_3_i & !input_2_i & input_1_i & !input_0_i) | (input_7_i & !input_6_i & input_5_i & input_4_i & input_3_i & input_2_i & !input_1_i & !input_0_i) | (input_7_i & input_6_i & input_5_i & input_4_i & input_3_i & input_2_i & input_1_i & input_0_i)
wire needrm_o_t0;
wire needrm_o_t1;
wire needrm_o_t2;
wire needrm_o_t3;
wire needrm_o_t4;
wire needrm_o_t5;
wire needrm_o_t6;
wire needrm_o_t7;
wire needrm_o_t8;
wire needrm_o_t9;
wire needrm_o_t10;

and5$ needrm_o_and0 (needrm_o_t0, input_7_i_inv, input_6_i_inv, input_4_i_inv, input_3_i_inv, input_2_i_inv);
and6$ needrm_o_and1 (needrm_o_t1, input_7_i, input_6_i_inv, input_5_i_inv, input_4_i_inv, input_3_i, input_2_i_inv);
and6$ needrm_o_and2 (needrm_o_t2, input_7_i, input_6_i_inv, input_5_i_inv, input_4_i_inv, input_2_i_inv, input_1_i_inv);
and6$ needrm_o_and3 (needrm_o_t3, input_7_i, input_6_i_inv, input_5_i_inv, input_4_i_inv, input_3_i, input_0_i_inv);
and6$ needrm_o_and4 (needrm_o_t4, input_7_i_inv, input_6_i_inv, input_5_i_inv, input_3_i_inv, input_2_i_inv, input_0_i);
and7$ needrm_o_and5 (needrm_o_t5, input_7_i, input_6_i_inv, input_5_i, input_4_i, input_3_i_inv, input_2_i_inv, input_1_i_inv);
and7$ needrm_o_and6 (needrm_o_t6, input_7_i, input_6_i, input_5_i_inv, input_4_i_inv, input_3_i_inv, input_2_i, input_1_i);
and6$ needrm_o_and7 (needrm_o_t7, input_7_i, input_6_i_inv, input_5_i_inv, input_4_i_inv, input_2_i_inv, input_0_i);
and7$ needrm_o_and8 (needrm_o_t8, input_7_i_inv, input_5_i_inv, input_4_i_inv, input_3_i_inv, input_2_i_inv, input_1_i, input_0_i_inv);
and8$ needrm_o_and9 (needrm_o_t9, input_7_i, input_6_i_inv, input_5_i, input_4_i, input_3_i, input_2_i, input_1_i_inv, input_0_i_inv);
and8$ needrm_o_and10 (needrm_o_t10, input_7_i, input_6_i, input_5_i, input_4_i, input_3_i, input_2_i, input_1_i, input_0_i);
or11$  needrm_o_or  (needrm_o, needrm_o_t0, needrm_o_t1, needrm_o_t2, needrm_o_t3, needrm_o_t4, needrm_o_t5, needrm_o_t6, needrm_o_t7, needrm_o_t8, needrm_o_t9, needrm_o_t10);

// imm_size_2_o = (input_7_i & input_6_i & input_5_i & !input_4_i & input_3_i & !input_2_i & !input_0_i) | (!input_7_i & !input_6_i & !input_4_i & !input_3_i & input_2_i & !input_1_i & input_0_i) | (input_7_i & input_6_i & input_5_i & !input_4_i & input_3_i & !input_2_i & !input_1_i) | (input_7_i & !input_6_i & !input_5_i & !input_4_i & !input_3_i & input_2_i & input_1_i & input_0_i) | (input_7_i & !input_6_i & !input_5_i & input_4_i & input_3_i & !input_2_i & input_1_i & !input_0_i) | (input_7_i & !input_6_i & !input_5_i & !input_4_i & !input_3_i & !input_2_i & !input_1_i & input_0_i) | (!input_7_i & input_6_i & !input_5_i & !input_4_i & !input_3_i & !input_2_i & input_1_i & !input_0_i)
wire imm_size_2_o_t0;
wire imm_size_2_o_t1;
wire imm_size_2_o_t2;
wire imm_size_2_o_t3;
wire imm_size_2_o_t4;
wire imm_size_2_o_t5;
wire imm_size_2_o_t6;

and7$ imm_size_2_o_and0 (imm_size_2_o_t0, input_7_i, input_6_i, input_5_i, input_4_i_inv, input_3_i, input_2_i_inv, input_0_i_inv);
and7$ imm_size_2_o_and1 (imm_size_2_o_t1, input_7_i_inv, input_6_i_inv, input_4_i_inv, input_3_i_inv, input_2_i, input_1_i_inv, input_0_i);
and7$ imm_size_2_o_and2 (imm_size_2_o_t2, input_7_i, input_6_i, input_5_i, input_4_i_inv, input_3_i, input_2_i_inv, input_1_i_inv);
and8$ imm_size_2_o_and3 (imm_size_2_o_t3, input_7_i, input_6_i_inv, input_5_i_inv, input_4_i_inv, input_3_i_inv, input_2_i, input_1_i, input_0_i);
and8$ imm_size_2_o_and4 (imm_size_2_o_t4, input_7_i, input_6_i_inv, input_5_i_inv, input_4_i, input_3_i, input_2_i_inv, input_1_i, input_0_i_inv);
and8$ imm_size_2_o_and5 (imm_size_2_o_t5, input_7_i, input_6_i_inv, input_5_i_inv, input_4_i_inv, input_3_i_inv, input_2_i_inv, input_1_i_inv, input_0_i);
and8$ imm_size_2_o_and6 (imm_size_2_o_t6, input_7_i_inv, input_6_i, input_5_i_inv, input_4_i_inv, input_3_i_inv, input_2_i_inv, input_1_i, input_0_i_inv);
or7$  imm_size_2_o_or  (imm_size_2_o, imm_size_2_o_t0, imm_size_2_o_t1, imm_size_2_o_t2, imm_size_2_o_t3, imm_size_2_o_t4, imm_size_2_o_t5, imm_size_2_o_t6);

// imm_size_1_o = (input_7_i & input_6_i & input_5_i & !input_4_i & input_3_i & !input_2_i & input_1_i & !input_0_i) | (input_7_i & !input_6_i & !input_5_i & input_4_i & input_3_i & !input_2_i & input_1_i & !input_0_i)
wire imm_size_1_o_t0;
wire imm_size_1_o_t1;

and8$ imm_size_1_o_and0 (imm_size_1_o_t0, input_7_i, input_6_i, input_5_i, input_4_i_inv, input_3_i, input_2_i_inv, input_1_i, input_0_i_inv);
and8$ imm_size_1_o_and1 (imm_size_1_o_t1, input_7_i, input_6_i_inv, input_5_i_inv, input_4_i, input_3_i, input_2_i_inv, input_1_i, input_0_i_inv);
or2$  imm_size_1_o_or  (imm_size_1_o, imm_size_1_o_t0, imm_size_1_o_t1);

// imm_size_0_o = (!input_7_i & !input_6_i & !input_4_i & !input_3_i & input_2_i & !input_1_i & !input_0_i) | (!input_7_i & input_6_i & input_5_i & input_4_i & !input_3_i & input_2_i & input_0_i) | (input_7_i & !input_6_i & !input_5_i & !input_4_i & !input_3_i & !input_2_i & input_1_i & input_0_i) | (input_7_i & input_6_i & input_5_i & !input_4_i & input_3_i & !input_2_i & input_1_i & input_0_i) | (input_7_i & !input_6_i & !input_5_i & !input_4_i & !input_3_i & !input_2_i & !input_1_i & !input_0_i)
wire imm_size_0_o_t0;
wire imm_size_0_o_t1;
wire imm_size_0_o_t2;
wire imm_size_0_o_t3;
wire imm_size_0_o_t4;

and7$ imm_size_0_o_and0 (imm_size_0_o_t0, input_7_i_inv, input_6_i_inv, input_4_i_inv, input_3_i_inv, input_2_i, input_1_i_inv, input_0_i_inv);
and7$ imm_size_0_o_and1 (imm_size_0_o_t1, input_7_i_inv, input_6_i, input_5_i, input_4_i, input_3_i_inv, input_2_i, input_0_i);
and8$ imm_size_0_o_and2 (imm_size_0_o_t2, input_7_i, input_6_i_inv, input_5_i_inv, input_4_i_inv, input_3_i_inv, input_2_i_inv, input_1_i, input_0_i);
and8$ imm_size_0_o_and3 (imm_size_0_o_t3, input_7_i, input_6_i, input_5_i, input_4_i_inv, input_3_i, input_2_i_inv, input_1_i, input_0_i);
and8$ imm_size_0_o_and4 (imm_size_0_o_t4, input_7_i, input_6_i_inv, input_5_i_inv, input_4_i_inv, input_3_i_inv, input_2_i_inv, input_1_i_inv, input_0_i_inv);
or5$  imm_size_0_o_or  (imm_size_0_o, imm_size_0_o_t0, imm_size_0_o_t1, imm_size_0_o_t2, imm_size_0_o_t3, imm_size_0_o_t4);

endmodule
