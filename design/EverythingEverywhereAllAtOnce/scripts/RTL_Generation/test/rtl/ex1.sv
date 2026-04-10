// ======================================================================
// Combinational block : ex1
// Tool: csv2rtl.py  (auto-generated -- do not hand-edit)
// Std : Verilog-2005 (IEEE 1364-2005)
// WARNING: 12 input vector(s) had no CSV row.
//          Those vectors produce all-zero outputs (OFF-set default).
//          See: /home/maanav/projects/school_projects/uarch/uarch_project/design/EverythingEverywhereAllAtOnce/scripts/RTL_Generation/test/ex1_coverage_report.txt
// ======================================================================

// Truth table (expanded, from CSV)
// ----------------------------------------------------------------------------------------------------------------------
//           u_i           v_i           w_i           x_i           y_i  |          k0_o          k1_o          k2_o
// ----------------------------------------------------------------------------------------------------------------------
//             0             0             0             0             0  |             0             1             0
//             0             0             0             0             1  |             0             0             1
//             0             0             0             1             1  |             1             0             0
//             0             0             1             0             1  |             1             1             0
//             0             0             1             1             0  |             0             1             1
//             0             1             0             0             0  |             0             0             1
//             0             1             0             1             0  |             1             0             0
//             0             1             0             1             1  |             0             1             0
//             0             1             1             0             1  |             1             1             1
//             0             1             1             1             1  |             1             1             0
//             1             0             0             0             1  |             0             1             0
//             1             0             0             1             0  |             0             0             1
//             1             0             1             0             0  |             1             0             0
//             1             0             1             0             1  |             0             1             1
//             1             0             1             1             1  |             1             1             1
//             1             1             0             0             0  |             0             0             1
//             1             1             0             1             0  |             1             1             0
//             1             1             1             0             0  |             1             0             0
//             1             1             1             0             1  |             0             1             0
//             1             1             1             1             1  |             1             1             1
// ----------------------------------------------------------------------------------------------------------------------

module ex1 (
    output wire  k0_o,
    output wire  k1_o,
    output wire  k2_o,
    input  wire u_i,
    input  wire  v_i,
    input  wire  w_i,
    input  wire  x_i,
    input  wire  y_i
);

// ----------------------------------------------------------------
// Inverters for negated literals
// ----------------------------------------------------------------
wire  v_i_inv;
wire  w_i_inv;
wire  x_i_inv;
wire  y_i_inv;
wire u_i_inv;

`INV_N(inv_ v_i, 1,  v_i,  v_i_inv)
`INV_N(inv_ w_i, 1,  w_i,  w_i_inv)
`INV_N(inv_ x_i, 1,  x_i,  x_i_inv)
`INV_N(inv_ y_i, 1,  y_i,  y_i_inv)
`INV_N(inv_u_i, 1, u_i, u_i_inv)

// ----------------------------------------------------------------
// SOP logic (Quine-McCluskey minimised)
// ----------------------------------------------------------------

//  k0_o = ( v_i &  w_i &  x_i &  y_i) | (!u_i &  w_i & ! x_i &  y_i) | ( v_i & ! w_i &  x_i & ! y_i) | (u_i &  w_i & ! x_i & ! y_i) | (u_i &  w_i &  x_i &  y_i) | (!u_i & ! v_i & ! w_i &  x_i &  y_i)
wire  k0_o_t0;
`AND_4( k0_o_and0, 1,  k0_o_t0,  v_i,  w_i,  x_i,  y_i)
wire  k0_o_t1;
`AND_4( k0_o_and1, 1,  k0_o_t1, u_i_inv,  w_i,  x_i_inv,  y_i)
wire  k0_o_t2;
`AND_4( k0_o_and2, 1,  k0_o_t2,  v_i,  w_i_inv,  x_i,  y_i_inv)
wire  k0_o_t3;
`AND_4( k0_o_and3, 1,  k0_o_t3, u_i,  w_i,  x_i_inv,  y_i_inv)
wire  k0_o_t4;
`AND_4( k0_o_and4, 1,  k0_o_t4, u_i,  w_i,  x_i,  y_i)
wire  k0_o_t5;
`AND_5( k0_o_and5, 1,  k0_o_t5, u_i_inv,  v_i_inv,  w_i_inv,  x_i,  y_i)

`OR_6( k0_o_or, 1,  k0_o,  k0_o_t0,  k0_o_t1,  k0_o_t2,  k0_o_t3,  k0_o_t4,  k0_o_t5)

//  k1_o = (u_i &  w_i &  y_i) | ( v_i &  w_i &  y_i) | ( w_i & ! x_i &  y_i) | (!u_i &  v_i &  x_i &  y_i) | (u_i & ! v_i & ! x_i &  y_i) | (!u_i & ! v_i & ! w_i & ! x_i & ! y_i) | (u_i &  v_i & ! w_i &  x_i & ! y_i) | (!u_i & ! v_i &  w_i &  x_i & ! y_i)
wire  k1_o_t0;
`AND_3( k1_o_and0, 1,  k1_o_t0, u_i,  w_i,  y_i)
wire  k1_o_t1;
`AND_3( k1_o_and1, 1,  k1_o_t1,  v_i,  w_i,  y_i)
wire  k1_o_t2;
`AND_3( k1_o_and2, 1,  k1_o_t2,  w_i,  x_i_inv,  y_i)
wire  k1_o_t3;
`AND_4( k1_o_and3, 1,  k1_o_t3, u_i_inv,  v_i,  x_i,  y_i)
wire  k1_o_t4;
`AND_4( k1_o_and4, 1,  k1_o_t4, u_i,  v_i_inv,  x_i_inv,  y_i)
wire  k1_o_t5;
`AND_5( k1_o_and5, 1,  k1_o_t5, u_i_inv,  v_i_inv,  w_i_inv,  x_i_inv,  y_i_inv)
wire  k1_o_t6;
`AND_5( k1_o_and6, 1,  k1_o_t6, u_i,  v_i,  w_i_inv,  x_i,  y_i_inv)
wire  k1_o_t7;
`AND_5( k1_o_and7, 1,  k1_o_t7, u_i_inv,  v_i_inv,  w_i,  x_i,  y_i_inv)

`OR_8( k1_o_or, 1,  k1_o,  k1_o_t0,  k1_o_t1,  k1_o_t2,  k1_o_t3,  k1_o_t4,  k1_o_t5,  k1_o_t6,  k1_o_t7)

//  k2_o = ( v_i & ! w_i & ! x_i & ! y_i) | (u_i &  w_i &  x_i &  y_i) | (u_i & ! v_i &  w_i &  y_i) | (!u_i & ! v_i & ! w_i & ! x_i &  y_i) | (u_i & ! v_i & ! w_i &  x_i & ! y_i) | (!u_i & ! v_i &  w_i &  x_i & ! y_i) | (!u_i &  v_i &  w_i & ! x_i &  y_i)
wire  k2_o_t0;
`AND_4( k2_o_and0, 1,  k2_o_t0,  v_i,  w_i_inv,  x_i_inv,  y_i_inv)
wire  k2_o_t1;
`AND_4( k2_o_and1, 1,  k2_o_t1, u_i,  w_i,  x_i,  y_i)
wire  k2_o_t2;
`AND_4( k2_o_and2, 1,  k2_o_t2, u_i,  v_i_inv,  w_i,  y_i)
wire  k2_o_t3;
`AND_5( k2_o_and3, 1,  k2_o_t3, u_i_inv,  v_i_inv,  w_i_inv,  x_i_inv,  y_i)
wire  k2_o_t4;
`AND_5( k2_o_and4, 1,  k2_o_t4, u_i,  v_i_inv,  w_i_inv,  x_i,  y_i_inv)
wire  k2_o_t5;
`AND_5( k2_o_and5, 1,  k2_o_t5, u_i_inv,  v_i_inv,  w_i,  x_i,  y_i_inv)
wire  k2_o_t6;
`AND_5( k2_o_and6, 1,  k2_o_t6, u_i_inv,  v_i,  w_i,  x_i_inv,  y_i)

`OR_7( k2_o_or, 1,  k2_o,  k2_o_t0,  k2_o_t1,  k2_o_t2,  k2_o_t3,  k2_o_t4,  k2_o_t5,  k2_o_t6)

endmodule
