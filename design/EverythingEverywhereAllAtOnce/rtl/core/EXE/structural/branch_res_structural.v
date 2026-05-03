// Structural Verilog 2005 port of EXE/branch_res.sv
// Resolves branch outcome and target, detects mispredictions, and emits the
// flat fields of exe_br_resolution_outputs_t. The wrapping EXE.sv is
// responsible for re-assembling the SV struct from these outputs.

`include "STDCell_Macros.vh"
`include "common_define.vh"

module branch_res (
    // ---- br_info ----
    input  wire        stage_valid_i,
    input  wire        br_info_valid_i,
    input  wire        flush_mask,
    input  wire [`ADDRESS_BITS-1:0] br_eip_i,
    input  wire        br_xcl_i,

    // ---- prediction info ----
    input  wire        br_pred_taken_i,
    input  wire [`ADDRESS_BITS-1:0] speculative_target_i,

    // ---- exe_cs ----
    input  wire        br_ucond_i,
    input  wire        relative_branch_i,
    input  wire        special_br_i,
    input  wire        is_far_i,
    input  wire        is_call_i,
    input  wire        second_flag_needed_i,

    // ---- runtime inputs ----
    input  wire [31:0] br_source_i,
    input  wire [`ADDRESS_BITS-1:0] NEIP_i,
    input  wire [`ADDRESS_BITS-1:0] br_rel_target,
    input  wire [`ADDRESS_BITS-1:0] exp_target,
    input  wire        CF,
    input  wire        ZF,

    // ---- flat outputs (EXE.sv assembles these into exe_br_resolution_outputs_t) ----
    output wire        outs_valid_o,
    output wire        outs_flush_o,
    output wire        outs_farFlush_o,
    output wire        outs_callFlush_o,
    output wire        outs_miss_prediction_o,
    output wire [`ADDRESS_BITS-1:0] outs_br_eip_o,
    output wire [`ADDRESS_BITS-1:0] outs_neip_o,
    output wire [`ADDRESS_BITS-1:0] outs_br_target_o,
    output wire        outs_taken_o,
    output wire        outs_br_XCL_o,
    output wire        outs_clr_exp_mode_o,
    output wire        outs_br_ucond_o
);

    // valid = stage_valid_i & br_info_valid_i
    wire valid;
    `AND_2(u_and_valid, 1, valid, stage_valid_i, br_info_valid_i)

    // second_flag_result = second_flag_needed_i ? ~CF : 1'b1
    wire nCF;
    `INV_N(u_inv_cf, 1, CF, nCF)
    wire one_b;
    assign one_b = 1'b1;
    wire second_flag_result;
    `MUX_2(u_mux_sfr, 1, second_flag_result, one_b, nCF, second_flag_needed_i)

    // cond_br_res = ~ZF & second_flag_result
    wire nZF;
    `INV_N(u_inv_zf, 1, ZF, nZF)
    wire cond_br_res;
    `AND_2(u_and_cond_br, 1, cond_br_res, nZF, second_flag_result)

    // taken = (br_ucond_i | cond_br_res) & valid
    wire br_ucond_or_cond;
    `OR_2(u_or_ucond_cond, 1, br_ucond_or_cond, br_ucond_i, cond_br_res)
    wire taken;
    `AND_2(u_and_taken, 1, taken, br_ucond_or_cond, valid)

    // farFlush = is_far_i & valid;  callFlush = is_call_i & valid
    wire farFlush, callFlush;
    `AND_2(u_and_farFlush,  1, farFlush,  is_far_i,  valid)
    `AND_2(u_and_callFlush, 1, callFlush, is_call_i, valid)

    // real_br_target = relative_branch_i ? br_rel_target : (special_br_i ? exp_target : br_source_i)
    wire [`ADDRESS_BITS-1:0] inner_target;
    `MUX_2(u_mux_inner_target, `ADDRESS_BITS, inner_target, br_source_i, exp_target, special_br_i)
    wire [`ADDRESS_BITS-1:0] real_br_target;
    `MUX_2(u_mux_real_target, `ADDRESS_BITS, real_br_target, inner_target, br_rel_target, relative_branch_i)

    // target_match = (speculative_target_i == real_br_target)
    wire target_match;
    `CMP_N(u_cmp_target, `ADDRESS_BITS, target_match, speculative_target_i, real_br_target)
    wire n_target_match;
    `INV_N(u_inv_target_match, 1, target_match, n_target_match)

    // miss_prediction = ((taken ^ br_pred_taken_i) |
    //                    (taken & br_pred_taken_i & ~target_match) |
    //                    (farFlush | callFlush | special_br_i)) & valid
    wire taken_xor_pred;
    xor2$ u_xor_taken_pred (.out(taken_xor_pred), .in0(taken), .in1(br_pred_taken_i));

    wire and3_term;
    `AND_3(u_and3_term, 1, and3_term, taken, br_pred_taken_i, n_target_match)

    wire flush_or_term;
    `OR_3(u_or_flush_terms, 1, flush_or_term, farFlush, callFlush, special_br_i)

    wire mp_combined;
    `OR_3(u_or_mp_combined, 1, mp_combined, taken_xor_pred, and3_term, flush_or_term)

    wire miss_prediction;
    `AND_2(u_and_miss_pred, 1, miss_prediction, mp_combined, valid)

    // clr_exp_mode = special_br_i & valid
    wire clr_exp_mode;
    `AND_2(u_and_clr_exp, 1, clr_exp_mode, special_br_i, valid)

    // ---- Output assembly ----
    // outs.valid = valid & ~flush_mask
    wire n_flush_mask;
    `INV_N(u_inv_flush_mask, 1, flush_mask, n_flush_mask)
    `AND_2(u_and_outs_valid, 1, outs_valid_o, valid, n_flush_mask)

    // outs.flush = miss_prediction & ~flush_mask & valid
    `AND_3(u_and_outs_flush, 1, outs_flush_o, miss_prediction, n_flush_mask, valid)

    // outs.br_target = taken ? real_br_target : NEIP_i
    `MUX_2(u_mux_br_target, `ADDRESS_BITS, outs_br_target_o, NEIP_i, real_br_target, taken)

    // Pure-passthrough outputs
    assign outs_farFlush_o        = farFlush;
    assign outs_callFlush_o       = callFlush;
    assign outs_miss_prediction_o = miss_prediction;
    assign outs_br_eip_o          = br_eip_i;
    assign outs_neip_o            = NEIP_i;
    assign outs_taken_o           = taken;
    assign outs_br_XCL_o          = br_xcl_i;
    assign outs_clr_exp_mode_o    = clr_exp_mode;
    assign outs_br_ucond_o        = br_ucond_i;

endmodule
