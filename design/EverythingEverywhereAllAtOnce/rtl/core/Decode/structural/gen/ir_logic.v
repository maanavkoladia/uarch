module ir_logic (
    output o0_5_o,
    output o0_4_o,
    output o0_3_o,
    output o0_2_o,
    output o0_1_o,
    output o0_0_o,
    output o1_5_o,
    output o1_4_o,
    output o1_3_o,
    output o1_2_o,
    output o1_1_o,
    output o1_0_o,
    output o2_5_o,
    output o2_4_o,
    output o2_3_o,
    output o2_2_o,
    output o2_1_o,
    output o2_0_o,
    output o3_5_o,
    output o3_4_o,
    output o3_3_o,
    output o3_2_o,
    output o3_1_o,
    output o3_0_o,
    output o4_5_o,
    output o4_4_o,
    output o4_3_o,
    output o4_2_o,
    output o4_1_o,
    output o4_0_o,
    output o5_5_o,
    output o5_4_o,
    output o5_3_o,
    output o5_2_o,
    output o5_1_o,
    output o5_0_o,
    output o6_5_o,
    output o6_4_o,
    output o6_3_o,
    output o6_2_o,
    output o6_1_o,
    output o6_0_o,
    output o7_5_o,
    output o7_4_o,
    output o7_3_o,
    output o7_2_o,
    output o7_1_o,
    output o7_0_o,
    output o8_5_o,
    output o8_4_o,
    output o8_3_o,
    output o8_2_o,
    output o8_1_o,
    output o8_0_o,
    output o9_5_o,
    output o9_4_o,
    output o9_3_o,
    output o9_2_o,
    output o9_1_o,
    output o9_0_o,
    output o10_5_o,
    output o10_4_o,
    output o10_3_o,
    output o10_2_o,
    output o10_1_o,
    output o10_0_o,
    output o11_5_o,
    output o11_4_o,
    output o11_3_o,
    output o11_2_o,
    output o11_1_o,
    output o11_0_o,
    output o12_5_o,
    output o12_4_o,
    output o12_3_o,
    output o12_2_o,
    output o12_1_o,
    output o12_0_o,
    output o13_5_o,
    output o13_4_o,
    output o13_3_o,
    output o13_2_o,
    output o13_1_o,
    output o13_0_o,
    output o14_5_o,
    output o14_4_o,
    output o14_3_o,
    output o14_2_o,
    output o14_1_o,
    output o14_0_o,
    output o15_5_o,
    output o15_4_o,
    output o15_3_o,
    output o15_2_o,
    output o15_1_o,
    output o15_0_o,
    input  i5_i,
    input  i4_i,
    input  i3_i,
    input  i2_i,
    input  i1_i,
    input  i0_i
);

wire i0_i_inv;
wire i1_i_inv;
wire i2_i_inv;
wire i3_i_inv;
wire i4_i_inv;
wire i5_i_inv;

inv1$ inv_i0_i (i0_i_inv, i0_i);
inv1$ inv_i1_i (i1_i_inv, i1_i);
inv1$ inv_i2_i (i2_i_inv, i2_i);
inv1$ inv_i3_i (i3_i_inv, i3_i);
inv1$ inv_i4_i (i4_i_inv, i4_i);
inv1$ inv_i5_i (i5_i_inv, i5_i);

// o0_5_o = i5_i
assign o0_5_o = i5_i;

// o0_4_o = i4_i
assign o0_4_o = i4_i;

// o0_3_o = i3_i
assign o0_3_o = i3_i;

// o0_2_o = i2_i
assign o0_2_o = i2_i;

// o0_1_o = i1_i
assign o0_1_o = i1_i;

// o0_0_o = i0_i
assign o0_0_o = i0_i;

// o1_5_o = (i5_i & !i2_i) | (i5_i & !i0_i) | (i5_i & !i3_i) | (i5_i & !i1_i) | (i5_i & !i4_i) | (!i5_i & i4_i & i3_i & i2_i & i1_i & i0_i)
wire o1_5_o_t0;
wire o1_5_o_t1;
wire o1_5_o_t2;
wire o1_5_o_t3;
wire o1_5_o_t4;
wire o1_5_o_t5;

and2$ o1_5_o_and0 (o1_5_o_t0, i5_i, i2_i_inv);
and2$ o1_5_o_and1 (o1_5_o_t1, i5_i, i0_i_inv);
and2$ o1_5_o_and2 (o1_5_o_t2, i5_i, i3_i_inv);
and2$ o1_5_o_and3 (o1_5_o_t3, i5_i, i1_i_inv);
and2$ o1_5_o_and4 (o1_5_o_t4, i5_i, i4_i_inv);
and6$ o1_5_o_and5 (o1_5_o_t5, i5_i_inv, i4_i, i3_i, i2_i, i1_i, i0_i);
or6$  o1_5_o_or  (o1_5_o, o1_5_o_t0, o1_5_o_t1, o1_5_o_t2, o1_5_o_t3, o1_5_o_t4, o1_5_o_t5);

// o1_4_o = (i4_i & !i1_i) | (i4_i & !i0_i) | (i4_i & !i2_i) | (i4_i & !i3_i) | (!i4_i & i3_i & i2_i & i1_i & i0_i)
wire o1_4_o_t0;
wire o1_4_o_t1;
wire o1_4_o_t2;
wire o1_4_o_t3;
wire o1_4_o_t4;

and2$ o1_4_o_and0 (o1_4_o_t0, i4_i, i1_i_inv);
and2$ o1_4_o_and1 (o1_4_o_t1, i4_i, i0_i_inv);
and2$ o1_4_o_and2 (o1_4_o_t2, i4_i, i2_i_inv);
and2$ o1_4_o_and3 (o1_4_o_t3, i4_i, i3_i_inv);
and5$ o1_4_o_and4 (o1_4_o_t4, i4_i_inv, i3_i, i2_i, i1_i, i0_i);
or5$  o1_4_o_or  (o1_4_o, o1_4_o_t0, o1_4_o_t1, o1_4_o_t2, o1_4_o_t3, o1_4_o_t4);

// o1_3_o = (i3_i & !i0_i) | (i3_i & !i1_i) | (i3_i & !i2_i) | (!i3_i & i2_i & i1_i & i0_i)
wire o1_3_o_t0;
wire o1_3_o_t1;
wire o1_3_o_t2;
wire o1_3_o_t3;

and2$ o1_3_o_and0 (o1_3_o_t0, i3_i, i0_i_inv);
and2$ o1_3_o_and1 (o1_3_o_t1, i3_i, i1_i_inv);
and2$ o1_3_o_and2 (o1_3_o_t2, i3_i, i2_i_inv);
and4$ o1_3_o_and3 (o1_3_o_t3, i3_i_inv, i2_i, i1_i, i0_i);
or4$  o1_3_o_or  (o1_3_o, o1_3_o_t0, o1_3_o_t1, o1_3_o_t2, o1_3_o_t3);

// o1_2_o = (i2_i & !i0_i) | (i2_i & !i1_i) | (!i2_i & i1_i & i0_i)
wire o1_2_o_t0;
wire o1_2_o_t1;
wire o1_2_o_t2;

and2$ o1_2_o_and0 (o1_2_o_t0, i2_i, i0_i_inv);
and2$ o1_2_o_and1 (o1_2_o_t1, i2_i, i1_i_inv);
and3$ o1_2_o_and2 (o1_2_o_t2, i2_i_inv, i1_i, i0_i);
or3$  o1_2_o_or  (o1_2_o, o1_2_o_t0, o1_2_o_t1, o1_2_o_t2);

// o1_1_o = (i1_i & !i0_i) | (!i1_i & i0_i)
wire o1_1_o_t0;
wire o1_1_o_t1;

and2$ o1_1_o_and0 (o1_1_o_t0, i1_i, i0_i_inv);
and2$ o1_1_o_and1 (o1_1_o_t1, i1_i_inv, i0_i);
or2$  o1_1_o_or  (o1_1_o, o1_1_o_t0, o1_1_o_t1);

// o1_0_o = !i0_i
assign o1_0_o = i0_i_inv;

// o2_5_o = (i5_i & !i2_i) | (i5_i & !i3_i) | (i5_i & !i1_i) | (i5_i & !i4_i) | (!i5_i & i4_i & i3_i & i2_i & i1_i)
wire o2_5_o_t0;
wire o2_5_o_t1;
wire o2_5_o_t2;
wire o2_5_o_t3;
wire o2_5_o_t4;

and2$ o2_5_o_and0 (o2_5_o_t0, i5_i, i2_i_inv);
and2$ o2_5_o_and1 (o2_5_o_t1, i5_i, i3_i_inv);
and2$ o2_5_o_and2 (o2_5_o_t2, i5_i, i1_i_inv);
and2$ o2_5_o_and3 (o2_5_o_t3, i5_i, i4_i_inv);
and5$ o2_5_o_and4 (o2_5_o_t4, i5_i_inv, i4_i, i3_i, i2_i, i1_i);
or5$  o2_5_o_or  (o2_5_o, o2_5_o_t0, o2_5_o_t1, o2_5_o_t2, o2_5_o_t3, o2_5_o_t4);

// o2_4_o = (i4_i & !i2_i) | (i4_i & !i1_i) | (i4_i & !i3_i) | (!i4_i & i3_i & i2_i & i1_i)
wire o2_4_o_t0;
wire o2_4_o_t1;
wire o2_4_o_t2;
wire o2_4_o_t3;

and2$ o2_4_o_and0 (o2_4_o_t0, i4_i, i2_i_inv);
and2$ o2_4_o_and1 (o2_4_o_t1, i4_i, i1_i_inv);
and2$ o2_4_o_and2 (o2_4_o_t2, i4_i, i3_i_inv);
and4$ o2_4_o_and3 (o2_4_o_t3, i4_i_inv, i3_i, i2_i, i1_i);
or4$  o2_4_o_or  (o2_4_o, o2_4_o_t0, o2_4_o_t1, o2_4_o_t2, o2_4_o_t3);

// o2_3_o = (i3_i & !i1_i) | (i3_i & !i2_i) | (!i3_i & i2_i & i1_i)
wire o2_3_o_t0;
wire o2_3_o_t1;
wire o2_3_o_t2;

and2$ o2_3_o_and0 (o2_3_o_t0, i3_i, i1_i_inv);
and2$ o2_3_o_and1 (o2_3_o_t1, i3_i, i2_i_inv);
and3$ o2_3_o_and2 (o2_3_o_t2, i3_i_inv, i2_i, i1_i);
or3$  o2_3_o_or  (o2_3_o, o2_3_o_t0, o2_3_o_t1, o2_3_o_t2);

// o2_2_o = (!i2_i & i1_i) | (i2_i & !i1_i)
wire o2_2_o_t0;
wire o2_2_o_t1;

and2$ o2_2_o_and0 (o2_2_o_t0, i2_i_inv, i1_i);
and2$ o2_2_o_and1 (o2_2_o_t1, i2_i, i1_i_inv);
or2$  o2_2_o_or  (o2_2_o, o2_2_o_t0, o2_2_o_t1);

// o2_1_o = !i1_i
assign o2_1_o = i1_i_inv;

// o2_0_o = i0_i
assign o2_0_o = i0_i;

// o3_5_o = (i5_i & !i2_i) | (i5_i & !i3_i) | (i5_i & !i4_i) | (!i5_i & i4_i & i3_i & i2_i & i0_i) | (i5_i & !i1_i & !i0_i) | (!i5_i & i4_i & i3_i & i2_i & i1_i)
wire o3_5_o_t0;
wire o3_5_o_t1;
wire o3_5_o_t2;
wire o3_5_o_t3;
wire o3_5_o_t4;
wire o3_5_o_t5;

and2$ o3_5_o_and0 (o3_5_o_t0, i5_i, i2_i_inv);
and2$ o3_5_o_and1 (o3_5_o_t1, i5_i, i3_i_inv);
and2$ o3_5_o_and2 (o3_5_o_t2, i5_i, i4_i_inv);
and5$ o3_5_o_and3 (o3_5_o_t3, i5_i_inv, i4_i, i3_i, i2_i, i0_i);
and3$ o3_5_o_and4 (o3_5_o_t4, i5_i, i1_i_inv, i0_i_inv);
and5$ o3_5_o_and5 (o3_5_o_t5, i5_i_inv, i4_i, i3_i, i2_i, i1_i);
or6$  o3_5_o_or  (o3_5_o, o3_5_o_t0, o3_5_o_t1, o3_5_o_t2, o3_5_o_t3, o3_5_o_t4, o3_5_o_t5);

// o3_4_o = (i4_i & !i2_i) | (i4_i & !i3_i) | (!i4_i & i3_i & i2_i & i0_i) | (i4_i & !i1_i & !i0_i) | (!i4_i & i3_i & i2_i & i1_i)
wire o3_4_o_t0;
wire o3_4_o_t1;
wire o3_4_o_t2;
wire o3_4_o_t3;
wire o3_4_o_t4;

and2$ o3_4_o_and0 (o3_4_o_t0, i4_i, i2_i_inv);
and2$ o3_4_o_and1 (o3_4_o_t1, i4_i, i3_i_inv);
and4$ o3_4_o_and2 (o3_4_o_t2, i4_i_inv, i3_i, i2_i, i0_i);
and3$ o3_4_o_and3 (o3_4_o_t3, i4_i, i1_i_inv, i0_i_inv);
and4$ o3_4_o_and4 (o3_4_o_t4, i4_i_inv, i3_i, i2_i, i1_i);
or5$  o3_4_o_or  (o3_4_o, o3_4_o_t0, o3_4_o_t1, o3_4_o_t2, o3_4_o_t3, o3_4_o_t4);

// o3_3_o = (i3_i & !i2_i) | (!i3_i & i2_i & i1_i) | (!i3_i & i2_i & i0_i) | (i3_i & !i1_i & !i0_i)
wire o3_3_o_t0;
wire o3_3_o_t1;
wire o3_3_o_t2;
wire o3_3_o_t3;

and2$ o3_3_o_and0 (o3_3_o_t0, i3_i, i2_i_inv);
and3$ o3_3_o_and1 (o3_3_o_t1, i3_i_inv, i2_i, i1_i);
and3$ o3_3_o_and2 (o3_3_o_t2, i3_i_inv, i2_i, i0_i);
and3$ o3_3_o_and3 (o3_3_o_t3, i3_i, i1_i_inv, i0_i_inv);
or4$  o3_3_o_or  (o3_3_o, o3_3_o_t0, o3_3_o_t1, o3_3_o_t2, o3_3_o_t3);

// o3_2_o = (!i2_i & i1_i) | (!i2_i & i0_i) | (i2_i & !i1_i & !i0_i)
wire o3_2_o_t0;
wire o3_2_o_t1;
wire o3_2_o_t2;

and2$ o3_2_o_and0 (o3_2_o_t0, i2_i_inv, i1_i);
and2$ o3_2_o_and1 (o3_2_o_t1, i2_i_inv, i0_i);
and3$ o3_2_o_and2 (o3_2_o_t2, i2_i, i1_i_inv, i0_i_inv);
or3$  o3_2_o_or  (o3_2_o, o3_2_o_t0, o3_2_o_t1, o3_2_o_t2);

// o3_1_o = (!i1_i & !i0_i) | (i1_i & i0_i)
wire o3_1_o_t0;
wire o3_1_o_t1;

and2$ o3_1_o_and0 (o3_1_o_t0, i1_i_inv, i0_i_inv);
and2$ o3_1_o_and1 (o3_1_o_t1, i1_i, i0_i);
or2$  o3_1_o_or  (o3_1_o, o3_1_o_t0, o3_1_o_t1);

// o3_0_o = !i0_i
assign o3_0_o = i0_i_inv;

// o4_5_o = (i5_i & !i2_i) | (i5_i & !i4_i) | (i5_i & !i3_i) | (!i5_i & i4_i & i3_i & i2_i)
wire o4_5_o_t0;
wire o4_5_o_t1;
wire o4_5_o_t2;
wire o4_5_o_t3;

and2$ o4_5_o_and0 (o4_5_o_t0, i5_i, i2_i_inv);
and2$ o4_5_o_and1 (o4_5_o_t1, i5_i, i4_i_inv);
and2$ o4_5_o_and2 (o4_5_o_t2, i5_i, i3_i_inv);
and4$ o4_5_o_and3 (o4_5_o_t3, i5_i_inv, i4_i, i3_i, i2_i);
or4$  o4_5_o_or  (o4_5_o, o4_5_o_t0, o4_5_o_t1, o4_5_o_t2, o4_5_o_t3);

// o4_4_o = (i4_i & !i2_i) | (i4_i & !i3_i) | (!i4_i & i3_i & i2_i)
wire o4_4_o_t0;
wire o4_4_o_t1;
wire o4_4_o_t2;

and2$ o4_4_o_and0 (o4_4_o_t0, i4_i, i2_i_inv);
and2$ o4_4_o_and1 (o4_4_o_t1, i4_i, i3_i_inv);
and3$ o4_4_o_and2 (o4_4_o_t2, i4_i_inv, i3_i, i2_i);
or3$  o4_4_o_or  (o4_4_o, o4_4_o_t0, o4_4_o_t1, o4_4_o_t2);

// o4_3_o = (!i3_i & i2_i) | (i3_i & !i2_i)
wire o4_3_o_t0;
wire o4_3_o_t1;

and2$ o4_3_o_and0 (o4_3_o_t0, i3_i_inv, i2_i);
and2$ o4_3_o_and1 (o4_3_o_t1, i3_i, i2_i_inv);
or2$  o4_3_o_or  (o4_3_o, o4_3_o_t0, o4_3_o_t1);

// o4_2_o = !i2_i
assign o4_2_o = i2_i_inv;

// o4_1_o = i1_i
assign o4_1_o = i1_i;

// o4_0_o = i0_i
assign o4_0_o = i0_i;

// o5_5_o = (i5_i & !i3_i) | (i5_i & !i4_i) | (!i5_i & i4_i & i3_i & i2_i) | (i5_i & !i2_i & !i0_i) | (i5_i & !i2_i & !i1_i) | (!i5_i & i4_i & i3_i & i1_i & i0_i)
wire o5_5_o_t0;
wire o5_5_o_t1;
wire o5_5_o_t2;
wire o5_5_o_t3;
wire o5_5_o_t4;
wire o5_5_o_t5;

and2$ o5_5_o_and0 (o5_5_o_t0, i5_i, i3_i_inv);
and2$ o5_5_o_and1 (o5_5_o_t1, i5_i, i4_i_inv);
and4$ o5_5_o_and2 (o5_5_o_t2, i5_i_inv, i4_i, i3_i, i2_i);
and3$ o5_5_o_and3 (o5_5_o_t3, i5_i, i2_i_inv, i0_i_inv);
and3$ o5_5_o_and4 (o5_5_o_t4, i5_i, i2_i_inv, i1_i_inv);
and5$ o5_5_o_and5 (o5_5_o_t5, i5_i_inv, i4_i, i3_i, i1_i, i0_i);
or6$  o5_5_o_or  (o5_5_o, o5_5_o_t0, o5_5_o_t1, o5_5_o_t2, o5_5_o_t3, o5_5_o_t4, o5_5_o_t5);

// o5_4_o = (i4_i & !i3_i) | (!i4_i & i3_i & i2_i) | (i4_i & !i2_i & !i0_i) | (i4_i & !i2_i & !i1_i) | (!i4_i & i3_i & i1_i & i0_i)
wire o5_4_o_t0;
wire o5_4_o_t1;
wire o5_4_o_t2;
wire o5_4_o_t3;
wire o5_4_o_t4;

and2$ o5_4_o_and0 (o5_4_o_t0, i4_i, i3_i_inv);
and3$ o5_4_o_and1 (o5_4_o_t1, i4_i_inv, i3_i, i2_i);
and3$ o5_4_o_and2 (o5_4_o_t2, i4_i, i2_i_inv, i0_i_inv);
and3$ o5_4_o_and3 (o5_4_o_t3, i4_i, i2_i_inv, i1_i_inv);
and4$ o5_4_o_and4 (o5_4_o_t4, i4_i_inv, i3_i, i1_i, i0_i);
or5$  o5_4_o_or  (o5_4_o, o5_4_o_t0, o5_4_o_t1, o5_4_o_t2, o5_4_o_t3, o5_4_o_t4);

// o5_3_o = (!i3_i & i2_i) | (i3_i & !i2_i & !i0_i) | (i3_i & !i2_i & !i1_i) | (!i3_i & i1_i & i0_i)
wire o5_3_o_t0;
wire o5_3_o_t1;
wire o5_3_o_t2;
wire o5_3_o_t3;

and2$ o5_3_o_and0 (o5_3_o_t0, i3_i_inv, i2_i);
and3$ o5_3_o_and1 (o5_3_o_t1, i3_i, i2_i_inv, i0_i_inv);
and3$ o5_3_o_and2 (o5_3_o_t2, i3_i, i2_i_inv, i1_i_inv);
and3$ o5_3_o_and3 (o5_3_o_t3, i3_i_inv, i1_i, i0_i);
or4$  o5_3_o_or  (o5_3_o, o5_3_o_t0, o5_3_o_t1, o5_3_o_t2, o5_3_o_t3);

// o5_2_o = (!i2_i & !i0_i) | (!i2_i & !i1_i) | (i2_i & i1_i & i0_i)
wire o5_2_o_t0;
wire o5_2_o_t1;
wire o5_2_o_t2;

and2$ o5_2_o_and0 (o5_2_o_t0, i2_i_inv, i0_i_inv);
and2$ o5_2_o_and1 (o5_2_o_t1, i2_i_inv, i1_i_inv);
and3$ o5_2_o_and2 (o5_2_o_t2, i2_i, i1_i, i0_i);
or3$  o5_2_o_or  (o5_2_o, o5_2_o_t0, o5_2_o_t1, o5_2_o_t2);

// o5_1_o = (i1_i & !i0_i) | (!i1_i & i0_i)
wire o5_1_o_t0;
wire o5_1_o_t1;

and2$ o5_1_o_and0 (o5_1_o_t0, i1_i, i0_i_inv);
and2$ o5_1_o_and1 (o5_1_o_t1, i1_i_inv, i0_i);
or2$  o5_1_o_or  (o5_1_o, o5_1_o_t0, o5_1_o_t1);

// o5_0_o = !i0_i
assign o5_0_o = i0_i_inv;

// o6_5_o = (i5_i & !i3_i) | (i5_i & !i4_i) | (!i5_i & i4_i & i3_i & i2_i) | (i5_i & !i2_i & !i1_i) | (!i5_i & i4_i & i3_i & i1_i)
wire o6_5_o_t0;
wire o6_5_o_t1;
wire o6_5_o_t2;
wire o6_5_o_t3;
wire o6_5_o_t4;

and2$ o6_5_o_and0 (o6_5_o_t0, i5_i, i3_i_inv);
and2$ o6_5_o_and1 (o6_5_o_t1, i5_i, i4_i_inv);
and4$ o6_5_o_and2 (o6_5_o_t2, i5_i_inv, i4_i, i3_i, i2_i);
and3$ o6_5_o_and3 (o6_5_o_t3, i5_i, i2_i_inv, i1_i_inv);
and4$ o6_5_o_and4 (o6_5_o_t4, i5_i_inv, i4_i, i3_i, i1_i);
or5$  o6_5_o_or  (o6_5_o, o6_5_o_t0, o6_5_o_t1, o6_5_o_t2, o6_5_o_t3, o6_5_o_t4);

// o6_4_o = (i4_i & !i3_i) | (!i4_i & i3_i & i1_i) | (!i4_i & i3_i & i2_i) | (i4_i & !i2_i & !i1_i)
wire o6_4_o_t0;
wire o6_4_o_t1;
wire o6_4_o_t2;
wire o6_4_o_t3;

and2$ o6_4_o_and0 (o6_4_o_t0, i4_i, i3_i_inv);
and3$ o6_4_o_and1 (o6_4_o_t1, i4_i_inv, i3_i, i1_i);
and3$ o6_4_o_and2 (o6_4_o_t2, i4_i_inv, i3_i, i2_i);
and3$ o6_4_o_and3 (o6_4_o_t3, i4_i, i2_i_inv, i1_i_inv);
or4$  o6_4_o_or  (o6_4_o, o6_4_o_t0, o6_4_o_t1, o6_4_o_t2, o6_4_o_t3);

// o6_3_o = (!i3_i & i1_i) | (!i3_i & i2_i) | (i3_i & !i2_i & !i1_i)
wire o6_3_o_t0;
wire o6_3_o_t1;
wire o6_3_o_t2;

and2$ o6_3_o_and0 (o6_3_o_t0, i3_i_inv, i1_i);
and2$ o6_3_o_and1 (o6_3_o_t1, i3_i_inv, i2_i);
and3$ o6_3_o_and2 (o6_3_o_t2, i3_i, i2_i_inv, i1_i_inv);
or3$  o6_3_o_or  (o6_3_o, o6_3_o_t0, o6_3_o_t1, o6_3_o_t2);

// o6_2_o = (!i2_i & !i1_i) | (i2_i & i1_i)
wire o6_2_o_t0;
wire o6_2_o_t1;

and2$ o6_2_o_and0 (o6_2_o_t0, i2_i_inv, i1_i_inv);
and2$ o6_2_o_and1 (o6_2_o_t1, i2_i, i1_i);
or2$  o6_2_o_or  (o6_2_o, o6_2_o_t0, o6_2_o_t1);

// o6_1_o = !i1_i
assign o6_1_o = i1_i_inv;

// o6_0_o = i0_i
assign o6_0_o = i0_i;

// o7_5_o = (i5_i & !i3_i) | (i5_i & !i4_i) | (!i5_i & i4_i & i3_i & i2_i) | (!i5_i & i4_i & i3_i & i0_i) | (!i5_i & i4_i & i3_i & i1_i) | (i5_i & !i2_i & !i1_i & !i0_i)
wire o7_5_o_t0;
wire o7_5_o_t1;
wire o7_5_o_t2;
wire o7_5_o_t3;
wire o7_5_o_t4;
wire o7_5_o_t5;

and2$ o7_5_o_and0 (o7_5_o_t0, i5_i, i3_i_inv);
and2$ o7_5_o_and1 (o7_5_o_t1, i5_i, i4_i_inv);
and4$ o7_5_o_and2 (o7_5_o_t2, i5_i_inv, i4_i, i3_i, i2_i);
and4$ o7_5_o_and3 (o7_5_o_t3, i5_i_inv, i4_i, i3_i, i0_i);
and4$ o7_5_o_and4 (o7_5_o_t4, i5_i_inv, i4_i, i3_i, i1_i);
and4$ o7_5_o_and5 (o7_5_o_t5, i5_i, i2_i_inv, i1_i_inv, i0_i_inv);
or6$  o7_5_o_or  (o7_5_o, o7_5_o_t0, o7_5_o_t1, o7_5_o_t2, o7_5_o_t3, o7_5_o_t4, o7_5_o_t5);

// o7_4_o = (i4_i & !i3_i) | (!i4_i & i3_i & i1_i) | (!i4_i & i3_i & i0_i) | (!i4_i & i3_i & i2_i) | (i4_i & !i2_i & !i1_i & !i0_i)
wire o7_4_o_t0;
wire o7_4_o_t1;
wire o7_4_o_t2;
wire o7_4_o_t3;
wire o7_4_o_t4;

and2$ o7_4_o_and0 (o7_4_o_t0, i4_i, i3_i_inv);
and3$ o7_4_o_and1 (o7_4_o_t1, i4_i_inv, i3_i, i1_i);
and3$ o7_4_o_and2 (o7_4_o_t2, i4_i_inv, i3_i, i0_i);
and3$ o7_4_o_and3 (o7_4_o_t3, i4_i_inv, i3_i, i2_i);
and4$ o7_4_o_and4 (o7_4_o_t4, i4_i, i2_i_inv, i1_i_inv, i0_i_inv);
or5$  o7_4_o_or  (o7_4_o, o7_4_o_t0, o7_4_o_t1, o7_4_o_t2, o7_4_o_t3, o7_4_o_t4);

// o7_3_o = (!i3_i & i1_i) | (!i3_i & i2_i) | (!i3_i & i0_i) | (i3_i & !i2_i & !i1_i & !i0_i)
wire o7_3_o_t0;
wire o7_3_o_t1;
wire o7_3_o_t2;
wire o7_3_o_t3;

and2$ o7_3_o_and0 (o7_3_o_t0, i3_i_inv, i1_i);
and2$ o7_3_o_and1 (o7_3_o_t1, i3_i_inv, i2_i);
and2$ o7_3_o_and2 (o7_3_o_t2, i3_i_inv, i0_i);
and4$ o7_3_o_and3 (o7_3_o_t3, i3_i, i2_i_inv, i1_i_inv, i0_i_inv);
or4$  o7_3_o_or  (o7_3_o, o7_3_o_t0, o7_3_o_t1, o7_3_o_t2, o7_3_o_t3);

// o7_2_o = (i2_i & i0_i) | (i2_i & i1_i) | (!i2_i & !i1_i & !i0_i)
wire o7_2_o_t0;
wire o7_2_o_t1;
wire o7_2_o_t2;

and2$ o7_2_o_and0 (o7_2_o_t0, i2_i, i0_i);
and2$ o7_2_o_and1 (o7_2_o_t1, i2_i, i1_i);
and3$ o7_2_o_and2 (o7_2_o_t2, i2_i_inv, i1_i_inv, i0_i_inv);
or3$  o7_2_o_or  (o7_2_o, o7_2_o_t0, o7_2_o_t1, o7_2_o_t2);

// o7_1_o = (!i1_i & !i0_i) | (i1_i & i0_i)
wire o7_1_o_t0;
wire o7_1_o_t1;

and2$ o7_1_o_and0 (o7_1_o_t0, i1_i_inv, i0_i_inv);
and2$ o7_1_o_and1 (o7_1_o_t1, i1_i, i0_i);
or2$  o7_1_o_or  (o7_1_o, o7_1_o_t0, o7_1_o_t1);

// o7_0_o = !i0_i
assign o7_0_o = i0_i_inv;

// o8_5_o = (i5_i & !i4_i) | (i5_i & !i3_i) | (!i5_i & i4_i & i3_i)
wire o8_5_o_t0;
wire o8_5_o_t1;
wire o8_5_o_t2;

and2$ o8_5_o_and0 (o8_5_o_t0, i5_i, i4_i_inv);
and2$ o8_5_o_and1 (o8_5_o_t1, i5_i, i3_i_inv);
and3$ o8_5_o_and2 (o8_5_o_t2, i5_i_inv, i4_i, i3_i);
or3$  o8_5_o_or  (o8_5_o, o8_5_o_t0, o8_5_o_t1, o8_5_o_t2);

// o8_4_o = (!i4_i & i3_i) | (i4_i & !i3_i)
wire o8_4_o_t0;
wire o8_4_o_t1;

and2$ o8_4_o_and0 (o8_4_o_t0, i4_i_inv, i3_i);
and2$ o8_4_o_and1 (o8_4_o_t1, i4_i, i3_i_inv);
or2$  o8_4_o_or  (o8_4_o, o8_4_o_t0, o8_4_o_t1);

// o8_3_o = !i3_i
assign o8_3_o = i3_i_inv;

// o8_2_o = i2_i
assign o8_2_o = i2_i;

// o8_1_o = i1_i
assign o8_1_o = i1_i;

// o8_0_o = i0_i
assign o8_0_o = i0_i;

// o9_5_o = (i5_i & !i4_i) | (!i5_i & i4_i & i3_i) | (i5_i & !i3_i & !i1_i) | (i5_i & !i3_i & !i2_i) | (i5_i & !i3_i & !i0_i) | (!i5_i & i4_i & i2_i & i1_i & i0_i)
wire o9_5_o_t0;
wire o9_5_o_t1;
wire o9_5_o_t2;
wire o9_5_o_t3;
wire o9_5_o_t4;
wire o9_5_o_t5;

and2$ o9_5_o_and0 (o9_5_o_t0, i5_i, i4_i_inv);
and3$ o9_5_o_and1 (o9_5_o_t1, i5_i_inv, i4_i, i3_i);
and3$ o9_5_o_and2 (o9_5_o_t2, i5_i, i3_i_inv, i1_i_inv);
and3$ o9_5_o_and3 (o9_5_o_t3, i5_i, i3_i_inv, i2_i_inv);
and3$ o9_5_o_and4 (o9_5_o_t4, i5_i, i3_i_inv, i0_i_inv);
and5$ o9_5_o_and5 (o9_5_o_t5, i5_i_inv, i4_i, i2_i, i1_i, i0_i);
or6$  o9_5_o_or  (o9_5_o, o9_5_o_t0, o9_5_o_t1, o9_5_o_t2, o9_5_o_t3, o9_5_o_t4, o9_5_o_t5);

// o9_4_o = (!i4_i & i3_i) | (i4_i & !i3_i & !i1_i) | (i4_i & !i3_i & !i2_i) | (i4_i & !i3_i & !i0_i) | (!i4_i & i2_i & i1_i & i0_i)
wire o9_4_o_t0;
wire o9_4_o_t1;
wire o9_4_o_t2;
wire o9_4_o_t3;
wire o9_4_o_t4;

and2$ o9_4_o_and0 (o9_4_o_t0, i4_i_inv, i3_i);
and3$ o9_4_o_and1 (o9_4_o_t1, i4_i, i3_i_inv, i1_i_inv);
and3$ o9_4_o_and2 (o9_4_o_t2, i4_i, i3_i_inv, i2_i_inv);
and3$ o9_4_o_and3 (o9_4_o_t3, i4_i, i3_i_inv, i0_i_inv);
and4$ o9_4_o_and4 (o9_4_o_t4, i4_i_inv, i2_i, i1_i, i0_i);
or5$  o9_4_o_or  (o9_4_o, o9_4_o_t0, o9_4_o_t1, o9_4_o_t2, o9_4_o_t3, o9_4_o_t4);

// o9_3_o = (!i3_i & !i1_i) | (!i3_i & !i0_i) | (!i3_i & !i2_i) | (i3_i & i2_i & i1_i & i0_i)
wire o9_3_o_t0;
wire o9_3_o_t1;
wire o9_3_o_t2;
wire o9_3_o_t3;

and2$ o9_3_o_and0 (o9_3_o_t0, i3_i_inv, i1_i_inv);
and2$ o9_3_o_and1 (o9_3_o_t1, i3_i_inv, i0_i_inv);
and2$ o9_3_o_and2 (o9_3_o_t2, i3_i_inv, i2_i_inv);
and4$ o9_3_o_and3 (o9_3_o_t3, i3_i, i2_i, i1_i, i0_i);
or4$  o9_3_o_or  (o9_3_o, o9_3_o_t0, o9_3_o_t1, o9_3_o_t2, o9_3_o_t3);

// o9_2_o = (i2_i & !i0_i) | (i2_i & !i1_i) | (!i2_i & i1_i & i0_i)
wire o9_2_o_t0;
wire o9_2_o_t1;
wire o9_2_o_t2;

and2$ o9_2_o_and0 (o9_2_o_t0, i2_i, i0_i_inv);
and2$ o9_2_o_and1 (o9_2_o_t1, i2_i, i1_i_inv);
and3$ o9_2_o_and2 (o9_2_o_t2, i2_i_inv, i1_i, i0_i);
or3$  o9_2_o_or  (o9_2_o, o9_2_o_t0, o9_2_o_t1, o9_2_o_t2);

// o9_1_o = (i1_i & !i0_i) | (!i1_i & i0_i)
wire o9_1_o_t0;
wire o9_1_o_t1;

and2$ o9_1_o_and0 (o9_1_o_t0, i1_i, i0_i_inv);
and2$ o9_1_o_and1 (o9_1_o_t1, i1_i_inv, i0_i);
or2$  o9_1_o_or  (o9_1_o, o9_1_o_t0, o9_1_o_t1);

// o9_0_o = !i0_i
assign o9_0_o = i0_i_inv;

// o10_5_o = (i5_i & !i4_i) | (!i5_i & i4_i & i3_i) | (i5_i & !i3_i & !i1_i) | (i5_i & !i3_i & !i2_i) | (!i5_i & i4_i & i2_i & i1_i)
wire o10_5_o_t0;
wire o10_5_o_t1;
wire o10_5_o_t2;
wire o10_5_o_t3;
wire o10_5_o_t4;

and2$ o10_5_o_and0 (o10_5_o_t0, i5_i, i4_i_inv);
and3$ o10_5_o_and1 (o10_5_o_t1, i5_i_inv, i4_i, i3_i);
and3$ o10_5_o_and2 (o10_5_o_t2, i5_i, i3_i_inv, i1_i_inv);
and3$ o10_5_o_and3 (o10_5_o_t3, i5_i, i3_i_inv, i2_i_inv);
and4$ o10_5_o_and4 (o10_5_o_t4, i5_i_inv, i4_i, i2_i, i1_i);
or5$  o10_5_o_or  (o10_5_o, o10_5_o_t0, o10_5_o_t1, o10_5_o_t2, o10_5_o_t3, o10_5_o_t4);

// o10_4_o = (!i4_i & i3_i) | (i4_i & !i3_i & !i2_i) | (i4_i & !i3_i & !i1_i) | (!i4_i & i2_i & i1_i)
wire o10_4_o_t0;
wire o10_4_o_t1;
wire o10_4_o_t2;
wire o10_4_o_t3;

and2$ o10_4_o_and0 (o10_4_o_t0, i4_i_inv, i3_i);
and3$ o10_4_o_and1 (o10_4_o_t1, i4_i, i3_i_inv, i2_i_inv);
and3$ o10_4_o_and2 (o10_4_o_t2, i4_i, i3_i_inv, i1_i_inv);
and3$ o10_4_o_and3 (o10_4_o_t3, i4_i_inv, i2_i, i1_i);
or4$  o10_4_o_or  (o10_4_o, o10_4_o_t0, o10_4_o_t1, o10_4_o_t2, o10_4_o_t3);

// o10_3_o = (!i3_i & !i2_i) | (!i3_i & !i1_i) | (i3_i & i2_i & i1_i)
wire o10_3_o_t0;
wire o10_3_o_t1;
wire o10_3_o_t2;

and2$ o10_3_o_and0 (o10_3_o_t0, i3_i_inv, i2_i_inv);
and2$ o10_3_o_and1 (o10_3_o_t1, i3_i_inv, i1_i_inv);
and3$ o10_3_o_and2 (o10_3_o_t2, i3_i, i2_i, i1_i);
or3$  o10_3_o_or  (o10_3_o, o10_3_o_t0, o10_3_o_t1, o10_3_o_t2);

// o10_2_o = (!i2_i & i1_i) | (i2_i & !i1_i)
wire o10_2_o_t0;
wire o10_2_o_t1;

and2$ o10_2_o_and0 (o10_2_o_t0, i2_i_inv, i1_i);
and2$ o10_2_o_and1 (o10_2_o_t1, i2_i, i1_i_inv);
or2$  o10_2_o_or  (o10_2_o, o10_2_o_t0, o10_2_o_t1);

// o10_1_o = !i1_i
assign o10_1_o = i1_i_inv;

// o10_0_o = i0_i
assign o10_0_o = i0_i;

// o11_5_o = (i5_i & !i4_i) | (!i5_i & i4_i & i3_i) | (i5_i & !i3_i & !i2_i) | (!i5_i & i4_i & i2_i & i1_i) | (!i5_i & i4_i & i2_i & i0_i) | (i5_i & !i3_i & !i1_i & !i0_i)
wire o11_5_o_t0;
wire o11_5_o_t1;
wire o11_5_o_t2;
wire o11_5_o_t3;
wire o11_5_o_t4;
wire o11_5_o_t5;

and2$ o11_5_o_and0 (o11_5_o_t0, i5_i, i4_i_inv);
and3$ o11_5_o_and1 (o11_5_o_t1, i5_i_inv, i4_i, i3_i);
and3$ o11_5_o_and2 (o11_5_o_t2, i5_i, i3_i_inv, i2_i_inv);
and4$ o11_5_o_and3 (o11_5_o_t3, i5_i_inv, i4_i, i2_i, i1_i);
and4$ o11_5_o_and4 (o11_5_o_t4, i5_i_inv, i4_i, i2_i, i0_i);
and4$ o11_5_o_and5 (o11_5_o_t5, i5_i, i3_i_inv, i1_i_inv, i0_i_inv);
or6$  o11_5_o_or  (o11_5_o, o11_5_o_t0, o11_5_o_t1, o11_5_o_t2, o11_5_o_t3, o11_5_o_t4, o11_5_o_t5);

// o11_4_o = (!i4_i & i3_i) | (i4_i & !i3_i & !i2_i) | (!i4_i & i2_i & i0_i) | (!i4_i & i2_i & i1_i) | (i4_i & !i3_i & !i1_i & !i0_i)
wire o11_4_o_t0;
wire o11_4_o_t1;
wire o11_4_o_t2;
wire o11_4_o_t3;
wire o11_4_o_t4;

and2$ o11_4_o_and0 (o11_4_o_t0, i4_i_inv, i3_i);
and3$ o11_4_o_and1 (o11_4_o_t1, i4_i, i3_i_inv, i2_i_inv);
and3$ o11_4_o_and2 (o11_4_o_t2, i4_i_inv, i2_i, i0_i);
and3$ o11_4_o_and3 (o11_4_o_t3, i4_i_inv, i2_i, i1_i);
and4$ o11_4_o_and4 (o11_4_o_t4, i4_i, i3_i_inv, i1_i_inv, i0_i_inv);
or5$  o11_4_o_or  (o11_4_o, o11_4_o_t0, o11_4_o_t1, o11_4_o_t2, o11_4_o_t3, o11_4_o_t4);

// o11_3_o = (!i3_i & !i2_i) | (i3_i & i2_i & i0_i) | (i3_i & i2_i & i1_i) | (!i3_i & !i1_i & !i0_i)
wire o11_3_o_t0;
wire o11_3_o_t1;
wire o11_3_o_t2;
wire o11_3_o_t3;

and2$ o11_3_o_and0 (o11_3_o_t0, i3_i_inv, i2_i_inv);
and3$ o11_3_o_and1 (o11_3_o_t1, i3_i, i2_i, i0_i);
and3$ o11_3_o_and2 (o11_3_o_t2, i3_i, i2_i, i1_i);
and3$ o11_3_o_and3 (o11_3_o_t3, i3_i_inv, i1_i_inv, i0_i_inv);
or4$  o11_3_o_or  (o11_3_o, o11_3_o_t0, o11_3_o_t1, o11_3_o_t2, o11_3_o_t3);

// o11_2_o = (!i2_i & i1_i) | (!i2_i & i0_i) | (i2_i & !i1_i & !i0_i)
wire o11_2_o_t0;
wire o11_2_o_t1;
wire o11_2_o_t2;

and2$ o11_2_o_and0 (o11_2_o_t0, i2_i_inv, i1_i);
and2$ o11_2_o_and1 (o11_2_o_t1, i2_i_inv, i0_i);
and3$ o11_2_o_and2 (o11_2_o_t2, i2_i, i1_i_inv, i0_i_inv);
or3$  o11_2_o_or  (o11_2_o, o11_2_o_t0, o11_2_o_t1, o11_2_o_t2);

// o11_1_o = (!i1_i & !i0_i) | (i1_i & i0_i)
wire o11_1_o_t0;
wire o11_1_o_t1;

and2$ o11_1_o_and0 (o11_1_o_t0, i1_i_inv, i0_i_inv);
and2$ o11_1_o_and1 (o11_1_o_t1, i1_i, i0_i);
or2$  o11_1_o_or  (o11_1_o, o11_1_o_t0, o11_1_o_t1);

// o11_0_o = !i0_i
assign o11_0_o = i0_i_inv;

// o12_5_o = (i5_i & !i4_i) | (!i5_i & i4_i & i2_i) | (!i5_i & i4_i & i3_i) | (i5_i & !i3_i & !i2_i)
wire o12_5_o_t0;
wire o12_5_o_t1;
wire o12_5_o_t2;
wire o12_5_o_t3;

and2$ o12_5_o_and0 (o12_5_o_t0, i5_i, i4_i_inv);
and3$ o12_5_o_and1 (o12_5_o_t1, i5_i_inv, i4_i, i2_i);
and3$ o12_5_o_and2 (o12_5_o_t2, i5_i_inv, i4_i, i3_i);
and3$ o12_5_o_and3 (o12_5_o_t3, i5_i, i3_i_inv, i2_i_inv);
or4$  o12_5_o_or  (o12_5_o, o12_5_o_t0, o12_5_o_t1, o12_5_o_t2, o12_5_o_t3);

// o12_4_o = (!i4_i & i2_i) | (!i4_i & i3_i) | (i4_i & !i3_i & !i2_i)
wire o12_4_o_t0;
wire o12_4_o_t1;
wire o12_4_o_t2;

and2$ o12_4_o_and0 (o12_4_o_t0, i4_i_inv, i2_i);
and2$ o12_4_o_and1 (o12_4_o_t1, i4_i_inv, i3_i);
and3$ o12_4_o_and2 (o12_4_o_t2, i4_i, i3_i_inv, i2_i_inv);
or3$  o12_4_o_or  (o12_4_o, o12_4_o_t0, o12_4_o_t1, o12_4_o_t2);

// o12_3_o = (i3_i & i2_i) | (!i3_i & !i2_i)
wire o12_3_o_t0;
wire o12_3_o_t1;

and2$ o12_3_o_and0 (o12_3_o_t0, i3_i, i2_i);
and2$ o12_3_o_and1 (o12_3_o_t1, i3_i_inv, i2_i_inv);
or2$  o12_3_o_or  (o12_3_o, o12_3_o_t0, o12_3_o_t1);

// o12_2_o = !i2_i
assign o12_2_o = i2_i_inv;

// o12_1_o = i1_i
assign o12_1_o = i1_i;

// o12_0_o = i0_i
assign o12_0_o = i0_i;

// o13_5_o = (i5_i & !i4_i) | (!i5_i & i4_i & i2_i) | (!i5_i & i4_i & i3_i) | (i5_i & !i3_i & !i2_i & !i1_i) | (i5_i & !i3_i & !i2_i & !i0_i) | (!i5_i & i4_i & i1_i & i0_i)
wire o13_5_o_t0;
wire o13_5_o_t1;
wire o13_5_o_t2;
wire o13_5_o_t3;
wire o13_5_o_t4;
wire o13_5_o_t5;

and2$ o13_5_o_and0 (o13_5_o_t0, i5_i, i4_i_inv);
and3$ o13_5_o_and1 (o13_5_o_t1, i5_i_inv, i4_i, i2_i);
and3$ o13_5_o_and2 (o13_5_o_t2, i5_i_inv, i4_i, i3_i);
and4$ o13_5_o_and3 (o13_5_o_t3, i5_i, i3_i_inv, i2_i_inv, i1_i_inv);
and4$ o13_5_o_and4 (o13_5_o_t4, i5_i, i3_i_inv, i2_i_inv, i0_i_inv);
and4$ o13_5_o_and5 (o13_5_o_t5, i5_i_inv, i4_i, i1_i, i0_i);
or6$  o13_5_o_or  (o13_5_o, o13_5_o_t0, o13_5_o_t1, o13_5_o_t2, o13_5_o_t3, o13_5_o_t4, o13_5_o_t5);

// o13_4_o = (!i4_i & i3_i) | (!i4_i & i2_i) | (i4_i & !i3_i & !i2_i & !i0_i) | (!i4_i & i1_i & i0_i) | (i4_i & !i3_i & !i2_i & !i1_i)
wire o13_4_o_t0;
wire o13_4_o_t1;
wire o13_4_o_t2;
wire o13_4_o_t3;
wire o13_4_o_t4;

and2$ o13_4_o_and0 (o13_4_o_t0, i4_i_inv, i3_i);
and2$ o13_4_o_and1 (o13_4_o_t1, i4_i_inv, i2_i);
and4$ o13_4_o_and2 (o13_4_o_t2, i4_i, i3_i_inv, i2_i_inv, i0_i_inv);
and3$ o13_4_o_and3 (o13_4_o_t3, i4_i_inv, i1_i, i0_i);
and4$ o13_4_o_and4 (o13_4_o_t4, i4_i, i3_i_inv, i2_i_inv, i1_i_inv);
or5$  o13_4_o_or  (o13_4_o, o13_4_o_t0, o13_4_o_t1, o13_4_o_t2, o13_4_o_t3, o13_4_o_t4);

// o13_3_o = (i3_i & i2_i) | (!i3_i & !i2_i & !i1_i) | (!i3_i & !i2_i & !i0_i) | (i3_i & i1_i & i0_i)
wire o13_3_o_t0;
wire o13_3_o_t1;
wire o13_3_o_t2;
wire o13_3_o_t3;

and2$ o13_3_o_and0 (o13_3_o_t0, i3_i, i2_i);
and3$ o13_3_o_and1 (o13_3_o_t1, i3_i_inv, i2_i_inv, i1_i_inv);
and3$ o13_3_o_and2 (o13_3_o_t2, i3_i_inv, i2_i_inv, i0_i_inv);
and3$ o13_3_o_and3 (o13_3_o_t3, i3_i, i1_i, i0_i);
or4$  o13_3_o_or  (o13_3_o, o13_3_o_t0, o13_3_o_t1, o13_3_o_t2, o13_3_o_t3);

// o13_2_o = (!i2_i & !i0_i) | (!i2_i & !i1_i) | (i2_i & i1_i & i0_i)
wire o13_2_o_t0;
wire o13_2_o_t1;
wire o13_2_o_t2;

and2$ o13_2_o_and0 (o13_2_o_t0, i2_i_inv, i0_i_inv);
and2$ o13_2_o_and1 (o13_2_o_t1, i2_i_inv, i1_i_inv);
and3$ o13_2_o_and2 (o13_2_o_t2, i2_i, i1_i, i0_i);
or3$  o13_2_o_or  (o13_2_o, o13_2_o_t0, o13_2_o_t1, o13_2_o_t2);

// o13_1_o = (i1_i & !i0_i) | (!i1_i & i0_i)
wire o13_1_o_t0;
wire o13_1_o_t1;

and2$ o13_1_o_and0 (o13_1_o_t0, i1_i, i0_i_inv);
and2$ o13_1_o_and1 (o13_1_o_t1, i1_i_inv, i0_i);
or2$  o13_1_o_or  (o13_1_o, o13_1_o_t0, o13_1_o_t1);

// o13_0_o = !i0_i
assign o13_0_o = i0_i_inv;

// o14_5_o = (i5_i & !i4_i) | (!i5_i & i4_i & i2_i) | (!i5_i & i4_i & i1_i) | (!i5_i & i4_i & i3_i) | (i5_i & !i3_i & !i2_i & !i1_i)
wire o14_5_o_t0;
wire o14_5_o_t1;
wire o14_5_o_t2;
wire o14_5_o_t3;
wire o14_5_o_t4;

and2$ o14_5_o_and0 (o14_5_o_t0, i5_i, i4_i_inv);
and3$ o14_5_o_and1 (o14_5_o_t1, i5_i_inv, i4_i, i2_i);
and3$ o14_5_o_and2 (o14_5_o_t2, i5_i_inv, i4_i, i1_i);
and3$ o14_5_o_and3 (o14_5_o_t3, i5_i_inv, i4_i, i3_i);
and4$ o14_5_o_and4 (o14_5_o_t4, i5_i, i3_i_inv, i2_i_inv, i1_i_inv);
or5$  o14_5_o_or  (o14_5_o, o14_5_o_t0, o14_5_o_t1, o14_5_o_t2, o14_5_o_t3, o14_5_o_t4);

// o14_4_o = (!i4_i & i2_i) | (!i4_i & i3_i) | (!i4_i & i1_i) | (i4_i & !i3_i & !i2_i & !i1_i)
wire o14_4_o_t0;
wire o14_4_o_t1;
wire o14_4_o_t2;
wire o14_4_o_t3;

and2$ o14_4_o_and0 (o14_4_o_t0, i4_i_inv, i2_i);
and2$ o14_4_o_and1 (o14_4_o_t1, i4_i_inv, i3_i);
and2$ o14_4_o_and2 (o14_4_o_t2, i4_i_inv, i1_i);
and4$ o14_4_o_and3 (o14_4_o_t3, i4_i, i3_i_inv, i2_i_inv, i1_i_inv);
or4$  o14_4_o_or  (o14_4_o, o14_4_o_t0, o14_4_o_t1, o14_4_o_t2, o14_4_o_t3);

// o14_3_o = (i3_i & i1_i) | (i3_i & i2_i) | (!i3_i & !i2_i & !i1_i)
wire o14_3_o_t0;
wire o14_3_o_t1;
wire o14_3_o_t2;

and2$ o14_3_o_and0 (o14_3_o_t0, i3_i, i1_i);
and2$ o14_3_o_and1 (o14_3_o_t1, i3_i, i2_i);
and3$ o14_3_o_and2 (o14_3_o_t2, i3_i_inv, i2_i_inv, i1_i_inv);
or3$  o14_3_o_or  (o14_3_o, o14_3_o_t0, o14_3_o_t1, o14_3_o_t2);

// o14_2_o = (!i2_i & !i1_i) | (i2_i & i1_i)
wire o14_2_o_t0;
wire o14_2_o_t1;

and2$ o14_2_o_and0 (o14_2_o_t0, i2_i_inv, i1_i_inv);
and2$ o14_2_o_and1 (o14_2_o_t1, i2_i, i1_i);
or2$  o14_2_o_or  (o14_2_o, o14_2_o_t0, o14_2_o_t1);

// o14_1_o = !i1_i
assign o14_1_o = i1_i_inv;

// o14_0_o = i0_i
assign o14_0_o = i0_i;

// o15_5_o = (i5_i & !i4_i) | (!i5_i & i4_i & i0_i) | (!i5_i & i4_i & i2_i) | (!i5_i & i4_i & i1_i) | (!i5_i & i4_i & i3_i) | (i5_i & !i3_i & !i2_i & !i1_i & !i0_i)
wire o15_5_o_t0;
wire o15_5_o_t1;
wire o15_5_o_t2;
wire o15_5_o_t3;
wire o15_5_o_t4;
wire o15_5_o_t5;

and2$ o15_5_o_and0 (o15_5_o_t0, i5_i, i4_i_inv);
and3$ o15_5_o_and1 (o15_5_o_t1, i5_i_inv, i4_i, i0_i);
and3$ o15_5_o_and2 (o15_5_o_t2, i5_i_inv, i4_i, i2_i);
and3$ o15_5_o_and3 (o15_5_o_t3, i5_i_inv, i4_i, i1_i);
and3$ o15_5_o_and4 (o15_5_o_t4, i5_i_inv, i4_i, i3_i);
and5$ o15_5_o_and5 (o15_5_o_t5, i5_i, i3_i_inv, i2_i_inv, i1_i_inv, i0_i_inv);
or6$  o15_5_o_or  (o15_5_o, o15_5_o_t0, o15_5_o_t1, o15_5_o_t2, o15_5_o_t3, o15_5_o_t4, o15_5_o_t5);

// o15_4_o = (!i4_i & i3_i) | (!i4_i & i1_i) | (!i4_i & i2_i) | (!i4_i & i0_i) | (i4_i & !i3_i & !i2_i & !i1_i & !i0_i)
wire o15_4_o_t0;
wire o15_4_o_t1;
wire o15_4_o_t2;
wire o15_4_o_t3;
wire o15_4_o_t4;

and2$ o15_4_o_and0 (o15_4_o_t0, i4_i_inv, i3_i);
and2$ o15_4_o_and1 (o15_4_o_t1, i4_i_inv, i1_i);
and2$ o15_4_o_and2 (o15_4_o_t2, i4_i_inv, i2_i);
and2$ o15_4_o_and3 (o15_4_o_t3, i4_i_inv, i0_i);
and5$ o15_4_o_and4 (o15_4_o_t4, i4_i, i3_i_inv, i2_i_inv, i1_i_inv, i0_i_inv);
or5$  o15_4_o_or  (o15_4_o, o15_4_o_t0, o15_4_o_t1, o15_4_o_t2, o15_4_o_t3, o15_4_o_t4);

// o15_3_o = (i3_i & i2_i) | (i3_i & i0_i) | (i3_i & i1_i) | (!i3_i & !i2_i & !i1_i & !i0_i)
wire o15_3_o_t0;
wire o15_3_o_t1;
wire o15_3_o_t2;
wire o15_3_o_t3;

and2$ o15_3_o_and0 (o15_3_o_t0, i3_i, i2_i);
and2$ o15_3_o_and1 (o15_3_o_t1, i3_i, i0_i);
and2$ o15_3_o_and2 (o15_3_o_t2, i3_i, i1_i);
and4$ o15_3_o_and3 (o15_3_o_t3, i3_i_inv, i2_i_inv, i1_i_inv, i0_i_inv);
or4$  o15_3_o_or  (o15_3_o, o15_3_o_t0, o15_3_o_t1, o15_3_o_t2, o15_3_o_t3);

// o15_2_o = (i2_i & i0_i) | (i2_i & i1_i) | (!i2_i & !i1_i & !i0_i)
wire o15_2_o_t0;
wire o15_2_o_t1;
wire o15_2_o_t2;

and2$ o15_2_o_and0 (o15_2_o_t0, i2_i, i0_i);
and2$ o15_2_o_and1 (o15_2_o_t1, i2_i, i1_i);
and3$ o15_2_o_and2 (o15_2_o_t2, i2_i_inv, i1_i_inv, i0_i_inv);
or3$  o15_2_o_or  (o15_2_o, o15_2_o_t0, o15_2_o_t1, o15_2_o_t2);

// o15_1_o = (!i1_i & !i0_i) | (i1_i & i0_i)
wire o15_1_o_t0;
wire o15_1_o_t1;

and2$ o15_1_o_and0 (o15_1_o_t0, i1_i_inv, i0_i_inv);
and2$ o15_1_o_and1 (o15_1_o_t1, i1_i, i0_i);
or2$  o15_1_o_or  (o15_1_o, o15_1_o_t0, o15_1_o_t1);

// o15_0_o = !i0_i
assign o15_0_o = i0_i_inv;

endmodule
