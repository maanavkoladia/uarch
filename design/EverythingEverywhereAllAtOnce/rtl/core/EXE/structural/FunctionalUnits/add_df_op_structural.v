// Structural Verilog 2005 port of EXE/FunctionalUnits/add_df_op.sv
// size = 1 (data_size = 4'b0001 or 4'b0010), 2 (4'b0011), 4 (4'b0111), else 0.
// dr_o = curr_df_flag ? srA - size : srA + size;
// sr_o = curr_df_flag ? srB - size : srB + size;

module add_df_op (
    input  wire [63:0] srA,
    input  wire [63:0] srB,
    input  wire [3:0]  data_size,
    input  wire        curr_df_flag,
    output wire [63:0] dr_o,
    output wire [63:0] sr_o
);

    // Decode size as 3-bit one-hot of 1, 2, 4 (or zero).
    wire is_0001, is_0010, is_0011, is_0111, is_size1;
    `CMP_N(u_cmp_01, 4, is_0001, data_size, 4'b0001)
    `CMP_N(u_cmp_02, 4, is_0010, data_size, 4'b0010)
    wire is_0011_raw, is_0111_raw, is_size1_raw;
    `CMP_N(u_cmp_03, 4, is_0011_raw, data_size, 4'b0011)
    `CMP_N(u_cmp_07, 4, is_0111_raw, data_size, 4'b0111)
    `OR_2(u_or_size1, 1, is_size1_raw, is_0001, is_0010)
    // All three signals fanout 5 → bufferH16$ smallest fit.
    bufferH16$ u_buf_is_0011  (.out(is_0011),  .in(is_0011_raw));
    bufferH16$ u_buf_is_0111  (.out(is_0111),  .in(is_0111_raw));
    bufferH16$ u_buf_is_size1 (.out(is_size1), .in(is_size1_raw));

    wire [63:0] size_64;
    assign size_64 = {61'd0, is_0111, is_0011, is_size1};

    // For subtract: srA - size = srA + ~size + 1
    wire [63:0] size_inv;
    `INV_N(u_inv_size, 64, size_64, size_inv)

    wire [63:0] dr_pos, dr_neg;
    wire        c_dr_pos, c_dr_neg;
    `ADD_N(u_add_dr_pos, 64, dr_pos, c_dr_pos, srA, size_64,  1'b0)
    `ADD_N(u_add_dr_neg, 64, dr_neg, c_dr_neg, srA, size_inv, 1'b1)

    wire [63:0] sr_pos, sr_neg;
    wire        c_sr_pos, c_sr_neg;
    `ADD_N(u_add_sr_pos, 64, sr_pos, c_sr_pos, srB, size_64,  1'b0)
    `ADD_N(u_add_sr_neg, 64, sr_neg, c_sr_neg, srB, size_inv, 1'b1)

    `MUX_2(u_mux_dr, 64, dr_o, dr_pos, dr_neg, curr_df_flag)
    `MUX_2(u_mux_sr, 64, sr_o, sr_pos, sr_neg, curr_df_flag)

endmodule
