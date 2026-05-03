// Structural Verilog 2005 port of EXE/flag_sel/df_flag_sel.sv
// DF flag is set by STD (→1), cleared by CLD (→0), else holds curr_df_flag.
// Tristate-mux of 2 ops + 2:1 MUX with match_any select.

`include "STDCell_Macros.vh"
`include "exe_structural_defines.vh"

module df_flag_sel (
    input  wire                          curr_df_flag,
    input  wire [`EXE_STRUCT_OP_W-1:0]   op_type,
    output wire                          df_flag_o
);

    wire is_std;
    wire is_cld;
    `CMP_N(u_cmp_std, `EXE_STRUCT_OP_W, is_std, op_type, `EXE_OP_STD)
    `CMP_N(u_cmp_cld, `EXE_STRUCT_OP_W, is_cld, op_type, `EXE_OP_CLD)

    // match_any = is_std | is_cld   (2 inputs — single OR_2 is the right size)
    wire match_any;
    `OR_2(u_or_match_any, 1, match_any, is_std, is_cld)

    // Active-low enables
    wire enbar_std, enbar_cld;
    `INV_N(u_inv_std, 1, is_std, enbar_std)
    `INV_N(u_inv_cld, 1, is_cld, enbar_cld)

    // Constants for matched paths
    wire one_b;
    wire zero_b;
    assign one_b  = 1'b1;
    assign zero_b = 1'b0;

    // Two tristate drivers feed tristated_bus; exactly one fires when match_any=1.
    wire tristated_bus;
    `TRISTATE_L(u_tri_std, 1, enbar_std, one_b,  tristated_bus)
    `TRISTATE_L(u_tri_cld, 1, enbar_cld, zero_b, tristated_bus)

    // Final 2:1 mux: match_any ? tristated_bus : curr_df_flag
    `MUX_2(u_mux_df_o, 1, df_flag_o, curr_df_flag, tristated_bus, match_any)

endmodule
