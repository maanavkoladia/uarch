// Structural Verilog 2005 port of EXE/FunctionalUnits/xchg_op.sv
// Byte-lane swap between srA (rm) and srB (r32). Each value re-assembled per
// data_size / sr_data_size_vec one-hot lanes. No flags.
// same-register detection (srA_id == srB_id, gated by ~st_op) merges both
// outputs into one value so an intra-register swap (e.g. xchg AH,AL) is
// correct.

module xchg_op (
    input  wire [63:0] srA,
    input  wire [63:0] srB,
    input  wire [4:0]  srA_id,
    input  wire [4:0]  srB_id,
    input  wire        st_op,
    input  wire [3:0]  data_size,
    input  wire [3:0]  sr_data_size_vec,
    output wire [63:0] res_buf,
    output wire [63:0] dr_o,
    output wire [63:0] sr_o
);

    // ---- same_id: true when both operands live in the same register
    //      and this is not a store (store IDs may be garbage)          ----
    wire id_eq;
    `CMP_N(u_cmp_id, 5, id_eq, srA_id, srB_id)
    wire same_id;
    wire same_id_raw;
    wire st_op_n;
    inv1$ u_inv_st_op      (.out(st_op_n),      .in(st_op));
    and2$ u_and_same_id_raw(.out(same_id_raw), .in0(st_op_n), .in1(id_eq));
    // same_id feeds 64 mux2$ select pins across u_mux_dr/sr and other paths
    // (fanout 64). bufferH64$ rated 64 — exact fit, 0.30 ns typ.
    bufferH64$ u_buf_same_id (.out(same_id), .in(same_id_raw));

    // ---- Per-lane source selectors (intra-byte mux on AL/AH ↔ BL/BH) ----
    wire [7:0] new_rm_low_sel;
    wire [7:0] new_rm_upper_sel;
    wire [7:0] new_r32_low_sel;
    wire [7:0] new_r32_upper_sel;

    `MUX_2(u_mux_rm_lo,  8, new_rm_low_sel,   srB[15:8], srB[7:0],  sr_data_size_vec[0])
    `MUX_2(u_mux_rm_up,  8, new_rm_upper_sel, srB[7:0],  srB[15:8], sr_data_size_vec[1])
    `MUX_2(u_mux_r32_lo, 8, new_r32_low_sel,  srA[15:8], srA[7:0],  data_size[0])
    `MUX_2(u_mux_r32_up, 8, new_r32_upper_sel,srA[7:0],  srA[15:8], data_size[1])

    // ---- new_rm_value (DR output when operands are different registers) ----
    wire [7:0]  new_rm_b0, new_rm_b1;
    wire [15:0] new_rm_hi;

    `MUX_2(u_mux_rm_b0, 8,  new_rm_b0, srA[7:0],   new_rm_low_sel,   data_size[0])
    `MUX_2(u_mux_rm_b1, 8,  new_rm_b1, srA[15:8],  new_rm_upper_sel, data_size[1])
    `MUX_2(u_mux_rm_hi, 16, new_rm_hi, srA[31:16], srB[31:16],       data_size[2])

    wire [31:0] new_rm_value;
    assign new_rm_value = {new_rm_hi, new_rm_b1, new_rm_b0};

    // ---- new_r32_val (SR output when operands are different registers) ----
    wire [7:0]  new_r32_b0, new_r32_b1;
    wire [15:0] new_r32_hi;

    `MUX_2(u_mux_r32_b0, 8,  new_r32_b0, srB[7:0],   new_r32_low_sel,   sr_data_size_vec[0])
    `MUX_2(u_mux_r32_b1, 8,  new_r32_b1, srB[15:8],  new_r32_upper_sel, sr_data_size_vec[1])
    `MUX_2(u_mux_r32_hi, 16, new_r32_hi, srB[31:16], srA[31:16],        sr_data_size_vec[2])

    wire [31:0] new_r32_val;
    assign new_r32_val = {new_r32_hi, new_r32_b1, new_r32_b0};

    // ---- merged_value: single value used for both dr_o and sr_o when
    //      same_id is set (e.g. xchg AH,AL within the same AX register).
    //      Priority per slot: DR target > SR target > unchanged srA.      ----
    //
    // [7:0]:   data_size[0] → new_rm_b0 ; sr_data_size_vec[0] → new_r32_b0 ; srA[7:0]
    wire [7:0] merged_b0_inner, merged_b0;
    `MUX_2(u_mrg_b0_inner, 8, merged_b0_inner, srA[7:0],   new_r32_b0, sr_data_size_vec[0])
    `MUX_2(u_mrg_b0,       8, merged_b0,       merged_b0_inner, new_rm_b0,  data_size[0])

    // [15:8]:  data_size[1] → new_rm_b1 ; sr_data_size_vec[1] → new_r32_b1 ; srA[15:8]
    wire [7:0] merged_b1_inner, merged_b1;
    `MUX_2(u_mrg_b1_inner, 8, merged_b1_inner, srA[15:8],  new_r32_b1, sr_data_size_vec[1])
    `MUX_2(u_mrg_b1,       8, merged_b1,       merged_b1_inner, new_rm_b1,  data_size[1])

    // [31:16]: data_size[2] → new_rm_hi ; sr_data_size_vec[2] → new_r32_hi ; srA[31:16]
    wire [15:0] merged_hi_inner, merged_hi;
    `MUX_2(u_mrg_hi_inner, 16, merged_hi_inner, srA[31:16], new_r32_hi, sr_data_size_vec[2])
    `MUX_2(u_mrg_hi,       16, merged_hi,       merged_hi_inner, new_rm_hi,  data_size[2])

    wire [31:0] merged_value;
    assign merged_value = {merged_hi, merged_b1, merged_b0};

    // ---- Output selection ----
    wire [31:0] dr_low, sr_low;
    `MUX_2(u_mux_dr, 32, dr_low, new_rm_value, merged_value, same_id)
    `MUX_2(u_mux_sr, 32, sr_low, new_r32_val,  merged_value, same_id)

    assign res_buf = {32'd0, new_rm_value};
    assign dr_o    = {32'd0, dr_low};
    assign sr_o    = {32'd0, sr_low};

endmodule
