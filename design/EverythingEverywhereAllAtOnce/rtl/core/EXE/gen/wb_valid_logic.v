// ======================================================================
// Combinational block : wb_valid_logic
// Tool: csv2rtl.py  (auto-generated -- do not hand-edit)
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

// Inverter wires
wire WB_stall_i_inv;

inv1$ inv_WB_stall_i (WB_stall_i_inv, WB_stall_i);

// SOP logic (Quine-McCluskey minimised)

// WB_we_o = !WB_stall_i
buffer$ WB_we_o_buf (WB_we_o, WB_stall_i_inv);

// N_WB_V_o = EXE_V_i
buffer$ N_WB_V_o_buf (N_WB_V_o, EXE_V_i);

endmodule
