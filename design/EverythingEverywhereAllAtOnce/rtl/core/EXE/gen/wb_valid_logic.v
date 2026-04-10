// ======================================================================
// Combinational block : wb_valid_logic
// Tool: csv2rtl.py  (auto-generated -- do not hand-edit)
// Std : Verilog-2005 (IEEE 1364-2005)
// ======================================================================

// Truth table (expanded, from CSV)
// --------------------------------------------------------------
//       EXE_V_i    WB_stall_i  |       WB_we_o      N_WB_V_o
// --------------------------------------------------------------
//             0             0  |             1             0
//             0             1  |             0             0
//             1             0  |             1             1
//             1             1  |             0             1
// --------------------------------------------------------------

module wb_valid_logic (
    output wire WB_we_o,
    output wire N_WB_V_o,
    input  wire EXE_V_i,
    input  wire WB_stall_i
);

// ----------------------------------------------------------------
// Inverters for negated literals
// ----------------------------------------------------------------
wire WB_stall_i_inv;

`INV_N(inv_WB_stall_i, 1, WB_stall_i, WB_stall_i_inv)

// ----------------------------------------------------------------
// SOP logic (Quine-McCluskey minimised)
// ----------------------------------------------------------------

// WB_we_o = !WB_stall_i
wire WB_we_o_and_buf_mid;
`INV_N(WB_we_o_and_buf_i0, 1, WB_stall_i_inv, WB_we_o_and_buf_mid)
`INV_N(WB_we_o_and_buf_i1, 1, WB_we_o_and_buf_mid, WB_we_o)

// N_WB_V_o = EXE_V_i
wire N_WB_V_o_and_buf_mid;
`INV_N(N_WB_V_o_and_buf_i0, 1, EXE_V_i, N_WB_V_o_and_buf_mid)
`INV_N(N_WB_V_o_and_buf_i1, 1, N_WB_V_o_and_buf_mid, N_WB_V_o)

endmodule
