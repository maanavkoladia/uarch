// ======================================================================
// Combinational block : mem_valid_logic
// Tool: csv2rtl.py  (auto-generated -- do not hand-edit)
// Std : Verilog-2005 (IEEE 1364-2005)
// ======================================================================

// Truth table (expanded, from CSV)
// ----------------------------------------------------------------------------------------------------------------------
//    DC_stall_i        DC_V_i       MEM_V_i   MEM_stall_i       EXE_V_i    WB_stall_i  |      MEM_we_o     N_MEM_V_o
// ----------------------------------------------------------------------------------------------------------------------
//             0             0             0             0             0             0  |             1             0
//             0             0             0             0             0             1  |             1             0
//             0             0             0             0             1             0  |             1             0
//             0             0             0             0             1             1  |             1             0
//             0             0             0             1             0             0  |             1             0
//             0             0             0             1             0             1  |             1             0
//             0             0             0             1             1             0  |             1             0
//             0             0             0             1             1             1  |             1             0
//             0             0             1             0             0             0  |             1             0
//             0             0             1             0             0             1  |             1             0
//             0             0             1             0             1             0  |             1             0
//             0             0             1             0             1             1  |             0             0
//             0             0             1             1             0             0  |             0             0
//             0             0             1             1             0             1  |             0             0
//             0             0             1             1             1             0  |             0             0
//             0             0             1             1             1             1  |             0             0
//             0             1             0             0             0             0  |             1             1
//             0             1             0             0             0             1  |             1             1
//             0             1             0             0             1             0  |             1             1
//             0             1             0             0             1             1  |             1             1
//             0             1             0             1             0             0  |             1             1
//             0             1             0             1             0             1  |             1             1
//             0             1             0             1             1             0  |             1             1
//             0             1             0             1             1             1  |             1             1
//             0             1             1             0             0             0  |             1             1
//             0             1             1             0             0             1  |             1             1
//             0             1             1             0             1             0  |             1             1
//             0             1             1             0             1             1  |             0             1
//             0             1             1             1             0             0  |             0             1
//             0             1             1             1             0             1  |             0             1
//             0             1             1             1             1             0  |             0             1
//             0             1             1             1             1             1  |             0             1
//             1             0             0             0             0             0  |             1             0
//             1             0             0             0             0             1  |             1             0
//             1             0             0             0             1             0  |             1             0
//             1             0             0             0             1             1  |             1             0
//             1             0             0             1             0             0  |             1             0
//             1             0             0             1             0             1  |             1             0
//             1             0             0             1             1             0  |             1             0
//             1             0             0             1             1             1  |             1             0
//             1             0             1             0             0             0  |             1             0
//             1             0             1             0             0             1  |             1             0
//             1             0             1             0             1             0  |             1             0
//             1             0             1             0             1             1  |             0             0
//             1             0             1             1             0             0  |             0             0
//             1             0             1             1             0             1  |             0             0
//             1             0             1             1             1             0  |             0             0
//             1             0             1             1             1             1  |             0             0
//             1             1             0             0             0             0  |             1             0
//             1             1             0             0             0             1  |             1             0
//             1             1             0             0             1             0  |             1             0
//             1             1             0             0             1             1  |             1             0
//             1             1             0             1             0             0  |             1             0
//             1             1             0             1             0             1  |             1             0
//             1             1             0             1             1             0  |             1             0
//             1             1             0             1             1             1  |             1             0
//             1             1             1             0             0             0  |             1             0
//             1             1             1             0             0             1  |             1             0
//             1             1             1             0             1             0  |             1             0
//             1             1             1             0             1             1  |             0             0
//             1             1             1             1             0             0  |             0             0
//             1             1             1             1             0             1  |             0             0
//             1             1             1             1             1             0  |             0             0
//             1             1             1             1             1             1  |             0             0
// ----------------------------------------------------------------------------------------------------------------------

module mem_valid_logic (
    output wire MEM_we_o,
    output wire N_MEM_V_o,
    input  wire DC_stall_i,
    input  wire DC_V_i,
    input  wire MEM_V_i,
    input  wire MEM_stall_i,
    input  wire EXE_V_i,
    input  wire WB_stall_i
);

// ----------------------------------------------------------------
// Inverters for negated literals
// ----------------------------------------------------------------
wire DC_stall_i_inv;
wire EXE_V_i_inv;
wire MEM_V_i_inv;
wire MEM_stall_i_inv;
wire WB_stall_i_inv;

`INV_N(inv_DC_stall_i, 1, DC_stall_i, DC_stall_i_inv)
`INV_N(inv_EXE_V_i, 1, EXE_V_i, EXE_V_i_inv)
`INV_N(inv_MEM_V_i, 1, MEM_V_i, MEM_V_i_inv)
`INV_N(inv_MEM_stall_i, 1, MEM_stall_i, MEM_stall_i_inv)
`INV_N(inv_WB_stall_i, 1, WB_stall_i, WB_stall_i_inv)

// ----------------------------------------------------------------
// SOP logic (Quine-McCluskey minimised)
// ----------------------------------------------------------------

// MEM_we_o = !MEM_V_i | (!MEM_stall_i & !EXE_V_i) | (!MEM_stall_i & !WB_stall_i)
wire MEM_we_o_t0;
wire MEM_we_o_and0_buf_mid;
`INV_N(MEM_we_o_and0_buf_i0, 1, MEM_V_i_inv, MEM_we_o_and0_buf_mid)
`INV_N(MEM_we_o_and0_buf_i1, 1, MEM_we_o_and0_buf_mid, MEM_we_o_t0)
wire MEM_we_o_t1;
`AND_2(MEM_we_o_and1, 1, MEM_we_o_t1, MEM_stall_i_inv, EXE_V_i_inv)
wire MEM_we_o_t2;
`AND_2(MEM_we_o_and2, 1, MEM_we_o_t2, MEM_stall_i_inv, WB_stall_i_inv)

`OR_3(MEM_we_o_or, 1, MEM_we_o, MEM_we_o_t0, MEM_we_o_t1, MEM_we_o_t2)

// N_MEM_V_o = (!DC_stall_i & DC_V_i)
`AND_2(N_MEM_V_o_and, 1, N_MEM_V_o, DC_stall_i_inv, DC_V_i)

endmodule
