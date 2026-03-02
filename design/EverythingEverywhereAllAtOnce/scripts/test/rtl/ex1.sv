module ex1 (
    output  k0_o,
    output  k1_o,
    output  k2_o,
    input  u_i,
    input   v_i,
    input   w_i,
    input   x_i,
    input   y_i
);

wire  v_i_inv;
wire  w_i_inv;
wire  x_i_inv;
wire  y_i_inv;
wire u_i_inv;

inv1$ inv_ v_i ( v_i_inv,  v_i);
inv1$ inv_ w_i ( w_i_inv,  w_i);
inv1$ inv_ x_i ( x_i_inv,  x_i);
inv1$ inv_ y_i ( y_i_inv,  y_i);
inv1$ inv_u_i (u_i_inv, u_i);

//  k0_o = (!u_i &  v_i &  w_i &  y_i) | (u_i &  w_i & ! x_i & ! y_i) | ( v_i & ! w_i &  x_i & ! y_i) | (u_i &  w_i &  x_i &  y_i) | (!u_i &  w_i & ! x_i &  y_i) | (!u_i & ! v_i & ! w_i &  x_i &  y_i)
wire  k0_o_t0;
wire  k0_o_t1;
wire  k0_o_t2;
wire  k0_o_t3;
wire  k0_o_t4;
wire  k0_o_t5;

and4$  k0_o_and0 ( k0_o_t0, u_i_inv, v_i, w_i, y_i);
and4$  k0_o_and1 ( k0_o_t1, u_i, w_i,  x_i_inv,  y_i_inv);
and4$  k0_o_and2 ( k0_o_t2, v_i,  w_i_inv, x_i,  y_i_inv);
and4$  k0_o_and3 ( k0_o_t3, u_i, w_i, x_i, y_i);
and4$  k0_o_and4 ( k0_o_t4, u_i_inv, w_i,  x_i_inv, y_i);
and5$  k0_o_and5 ( k0_o_t5, u_i_inv,  v_i_inv,  w_i_inv, x_i, y_i);
or6$   k0_o_or  ( k0_o,  k0_o_t0,  k0_o_t1,  k0_o_t2,  k0_o_t3,  k0_o_t4,  k0_o_t5);

//  k1_o = ( w_i & ! x_i &  y_i) | (u_i &  w_i &  y_i) | (!u_i &  v_i &  x_i &  y_i) | (u_i & ! v_i & ! x_i &  y_i) | (!u_i & ! v_i &  w_i &  x_i & ! y_i) | (u_i &  v_i & ! w_i &  x_i & ! y_i) | (!u_i & ! v_i & ! w_i & ! x_i & ! y_i)
wire  k1_o_t0;
wire  k1_o_t1;
wire  k1_o_t2;
wire  k1_o_t3;
wire  k1_o_t4;
wire  k1_o_t5;
wire  k1_o_t6;

and3$  k1_o_and0 ( k1_o_t0, w_i,  x_i_inv, y_i);
and3$  k1_o_and1 ( k1_o_t1, u_i, w_i, y_i);
and4$  k1_o_and2 ( k1_o_t2, u_i_inv, v_i, x_i, y_i);
and4$  k1_o_and3 ( k1_o_t3, u_i,  v_i_inv,  x_i_inv, y_i);
and5$  k1_o_and4 ( k1_o_t4, u_i_inv,  v_i_inv, w_i, x_i,  y_i_inv);
and5$  k1_o_and5 ( k1_o_t5, u_i, v_i,  w_i_inv, x_i,  y_i_inv);
and5$  k1_o_and6 ( k1_o_t6, u_i_inv,  v_i_inv,  w_i_inv,  x_i_inv,  y_i_inv);
or7$   k1_o_or  ( k1_o,  k1_o_t0,  k1_o_t1,  k1_o_t2,  k1_o_t3,  k1_o_t4,  k1_o_t5,  k1_o_t6);

//  k2_o = (u_i & ! v_i &  w_i &  y_i) | ( v_i & ! w_i & ! x_i & ! y_i) | (u_i &  w_i &  x_i &  y_i) | (!u_i & ! v_i &  w_i &  x_i & ! y_i) | (!u_i &  v_i &  w_i & ! x_i &  y_i) | (u_i & ! v_i & ! w_i &  x_i & ! y_i) | (!u_i & ! v_i & ! w_i & ! x_i &  y_i)
wire  k2_o_t0;
wire  k2_o_t1;
wire  k2_o_t2;
wire  k2_o_t3;
wire  k2_o_t4;
wire  k2_o_t5;
wire  k2_o_t6;

and4$  k2_o_and0 ( k2_o_t0, u_i,  v_i_inv, w_i, y_i);
and4$  k2_o_and1 ( k2_o_t1, v_i,  w_i_inv,  x_i_inv,  y_i_inv);
and4$  k2_o_and2 ( k2_o_t2, u_i, w_i, x_i, y_i);
and5$  k2_o_and3 ( k2_o_t3, u_i_inv,  v_i_inv, w_i, x_i,  y_i_inv);
and5$  k2_o_and4 ( k2_o_t4, u_i_inv, v_i, w_i,  x_i_inv, y_i);
and5$  k2_o_and5 ( k2_o_t5, u_i,  v_i_inv,  w_i_inv, x_i,  y_i_inv);
and5$  k2_o_and6 ( k2_o_t6, u_i_inv,  v_i_inv,  w_i_inv,  x_i_inv, y_i);
or7$   k2_o_or  ( k2_o,  k2_o_t0,  k2_o_t1,  k2_o_t2,  k2_o_t3,  k2_o_t4,  k2_o_t5,  k2_o_t6);

endmodule
