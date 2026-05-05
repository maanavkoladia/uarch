// Structural Verilog 2005 port of EXE/FunctionalUnits/xchg_op.sv
// Byte-lane swap between srA (rm) and srB (r32). Each value re-assembled per
// data_size / sr_data_size_vec one-hot lanes. No flags.

module xchg_op (
    input  wire [63:0] srA,
    input  wire [63:0] srB,
    input  wire [3:0]  data_size,
    input  wire [3:0]  sr_data_size_vec,
    output wire [63:0] res_buf,
    output wire [63:0] dr_o,
    output wire [63:0] sr_o
);

    // ---- Per-lane source selectors (intra-byte mux on AL/AH ↔ BL/BH) ----
    wire [7:0] new_rm_low_sel;
    wire [7:0] new_rm_upper_sel;
    wire [7:0] new_r32_low_sel;
    wire [7:0] new_r32_upper_sel;

    `MUX_2(u_mux_rm_lo, 8, new_rm_low_sel,   srB[15:8], srB[7:0],  sr_data_size_vec[0])
    `MUX_2(u_mux_rm_up, 8, new_rm_upper_sel, srB[7:0],  srB[15:8], sr_data_size_vec[1])
    `MUX_2(u_mux_r32_lo, 8, new_r32_low_sel,   srA[15:8], srA[7:0],  data_size[0])
    `MUX_2(u_mux_r32_up, 8, new_r32_upper_sel, srA[7:0],  srA[15:8], data_size[1])

    // ---- new_rm_value ----
    wire [7:0]  new_rm_b0, new_rm_b1;
    wire [15:0] new_rm_hi;

    `MUX_2(u_mux_rm_b0, 8,  new_rm_b0, srA[7:0],   new_rm_low_sel,   data_size[0])
    `MUX_2(u_mux_rm_b1, 8,  new_rm_b1, srA[15:8],  new_rm_upper_sel, data_size[1])
    `MUX_2(u_mux_rm_hi, 16, new_rm_hi, srA[31:16], srB[31:16],       data_size[2])

    wire [31:0] new_rm_value;
    assign new_rm_value = {new_rm_hi, new_rm_b1, new_rm_b0};

    // ---- new_r32_val ----
    wire [7:0]  new_r32_b0, new_r32_b1;
    wire [15:0] new_r32_hi;

    `MUX_2(u_mux_r32_b0, 8,  new_r32_b0, srB[7:0],   new_r32_low_sel,   sr_data_size_vec[0])
    `MUX_2(u_mux_r32_b1, 8,  new_r32_b1, srB[15:8],  new_r32_upper_sel, sr_data_size_vec[1])
    `MUX_2(u_mux_r32_hi, 16, new_r32_hi, srB[31:16], srA[31:16],        sr_data_size_vec[2])

    wire [31:0] new_r32_val;
    assign new_r32_val = {new_r32_hi, new_r32_b1, new_r32_b0};

    assign res_buf = {32'd0, new_rm_value};
    assign dr_o    = {32'd0, new_rm_value};
    assign sr_o    = {32'd0, new_r32_val};

endmodule
