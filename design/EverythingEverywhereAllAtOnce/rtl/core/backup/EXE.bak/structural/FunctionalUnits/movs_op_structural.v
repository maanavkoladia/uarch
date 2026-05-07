// Structural Verilog 2005 port of EXE/FunctionalUnits/movs_op.sv
// res_buf_o = srB
// dr_o = {32'd0, curr_df_flag ? (srA[31:0] - size) : (srA[31:0] + size)}
// sr_o = {32'd0, curr_df_flag ? (srA[63:32] - size) : (srA[63:32] + size)}
// size encoding identical to add_df_op (1, 2, 4, 0).

module movs_op (
    input  wire [63:0] srA,
    input  wire [63:0] srB,
    input  wire [3:0]  data_size,
    input  wire        curr_df_flag,
    output wire [63:0] res_buf_o,
    output wire [63:0] dr_o,
    output wire [63:0] sr_o
);

    wire is_0001, is_0010, is_0011, is_0111, is_size1;
    `CMP_N(u_cmp_01, 4, is_0001, data_size, 4'b0001)
    `CMP_N(u_cmp_02, 4, is_0010, data_size, 4'b0010)
    `CMP_N(u_cmp_03, 4, is_0011, data_size, 4'b0011)
    `CMP_N(u_cmp_07, 4, is_0111, data_size, 4'b0111)
    `OR_2(u_or_size1, 1, is_size1, is_0001, is_0010)

    wire [31:0] size_32;
    assign size_32 = {29'd0, is_0111, is_0011, is_size1};

    wire [31:0] size_32_inv;
    `INV_N(u_inv_size, 32, size_32, size_32_inv)

    wire [31:0] dr_pos, dr_neg;
    wire        c_dr_pos, c_dr_neg;
    `ADD_N(u_add_dr_pos, 32, dr_pos, c_dr_pos, srA[31:0],  size_32,     1'b0)
    `ADD_N(u_add_dr_neg, 32, dr_neg, c_dr_neg, srA[31:0],  size_32_inv, 1'b1)

    wire [31:0] sr_pos, sr_neg;
    wire        c_sr_pos, c_sr_neg;
    `ADD_N(u_add_sr_pos, 32, sr_pos, c_sr_pos, srA[63:32], size_32,     1'b0)
    `ADD_N(u_add_sr_neg, 32, sr_neg, c_sr_neg, srA[63:32], size_32_inv, 1'b1)

    wire [31:0] dr_sel32, sr_sel32;
    `MUX_2(u_mux_dr, 32, dr_sel32, dr_pos, dr_neg, curr_df_flag)
    `MUX_2(u_mux_sr, 32, sr_sel32, sr_pos, sr_neg, curr_df_flag)

    assign dr_o      = {32'd0, dr_sel32};
    assign sr_o      = {32'd0, sr_sel32};
    assign res_buf_o = srB;

endmodule
