// ======================================================================
// Combinational block : 4_2_pendcoder
// Tool: csv2rtl.py  (auto-generated -- do not hand-edit)
// Std : Verilog-2005 (IEEE 1364-2005)
// Lib : std_cell_macros.vh
// ======================================================================

// Truth table (expanded, from CSV)
// ------------------------------------------------------------------------------------------
//         in3_i         in2_i         in1_i         in0_i  |        out1_o        out0_o
// ------------------------------------------------------------------------------------------
//             0             0             0             0  |             0             0
//             0             0             0             1  |             0             0
//             0             0             1             0  |             0             1
//             0             0             1             1  |             0             1
//             0             1             0             0  |             1             0
//             0             1             0             1  |             1             0
//             0             1             1             0  |             1             0
//             0             1             1             1  |             1             0
//             1             0             0             0  |             1             1
//             1             0             0             1  |             1             1
//             1             0             1             0  |             1             1
//             1             0             1             1  |             1             1
//             1             1             0             0  |             1             1
//             1             1             0             1  |             1             1
//             1             1             1             0  |             1             1
//             1             1             1             1  |             1             1
// ------------------------------------------------------------------------------------------

`include "std_cell_macros.vh"

module m_4_2_pendcoder (
    output wire out1_o,
    output wire  out0_o,
    input  wire  in3_i,
    input  wire in2_i,
    input  wire in1_i,
    input  wire in0_i
);

// ----------------------------------------------------------------
// Inverters for negated literals
// ----------------------------------------------------------------
wire in2_i_inv;

`INV_N(inv_in2_i, 1, in2_i, in2_i_inv)

// ----------------------------------------------------------------
// SOP logic (Quine-McCluskey minimised)
// ----------------------------------------------------------------

// out1_o = in2_i |  in3_i
wire out1_o_t0;
wire out1_o_and0_buf_mid;
`INV_N(out1_o_and0_buf_i0, 1, in2_i, out1_o_and0_buf_mid)
`INV_N(out1_o_and0_buf_i1, 1, out1_o_and0_buf_mid, out1_o_t0)
wire out1_o_t1;
wire out1_o_and1_buf_mid;
`INV_N(out1_o_and1_buf_i0, 1,  in3_i, out1_o_and1_buf_mid)
`INV_N(out1_o_and1_buf_i1, 1, out1_o_and1_buf_mid, out1_o_t1)

`OR_2(out1_o_or, 1, out1_o, out1_o_t0, out1_o_t1)

//  out0_o =  in3_i | (!in2_i & in1_i)
wire  out0_o_t0;
wire  out0_o_and0_buf_mid;
`INV_N( out0_o_and0_buf_i0, 1,  in3_i,  out0_o_and0_buf_mid)
`INV_N( out0_o_and0_buf_i1, 1,  out0_o_and0_buf_mid,  out0_o_t0)
wire  out0_o_t1;
`AND_2( out0_o_and1, 1,  out0_o_t1, in2_i_inv, in1_i)

`OR_2( out0_o_or, 1,  out0_o,  out0_o_t0,  out0_o_t1)

endmodule
