// ======================================================================
// Combinational block : 4_2_pendcoder
// Tool: csv2rtl.py  (auto-generated -- do not hand-edit)
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

module m_4_2_pendcoder (
    output wire out1_o,
    output wire  out0_o,
    input  wire  in3_i,
    input  wire in2_i,
    input  wire in1_i,
    input  wire in0_i
);

// Inverter wires
wire in2_i_inv;

inv1$ inv_in2_i (in2_i_inv, in2_i);

// SOP logic (Quine-McCluskey minimised)

// out1_o =  in3_i | in2_i
wire out1_o_t0;
wire out1_o_t1;

buffer$ out1_o_buf0 (out1_o_t0,  in3_i);
buffer$ out1_o_buf1 (out1_o_t1, in2_i);
or2$  out1_o_or  (out1_o, out1_o_t0, out1_o_t1);

//  out0_o =  in3_i | (!in2_i & in1_i)
wire  out0_o_t0;
wire  out0_o_t1;

buffer$  out0_o_buf0 ( out0_o_t0,  in3_i);
and2$  out0_o_and1 ( out0_o_t1, in2_i_inv, in1_i);
or2$   out0_o_or  ( out0_o,  out0_o_t0,  out0_o_t1);

endmodule
