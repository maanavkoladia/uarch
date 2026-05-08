// Structural Verilog 2005 port of EXE/branch_res.sv
// Resolves branch outcome and target, detects mispredictions, and emits the
// flat fields of exe_br_resolution_outputs_t. The wrapping EXE.sv is
// responsible for re-assembling the SV struct from these outputs.

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
    // outs_valid replicated 4-way to break up the 77-load fanout to Decode/Fetch.
    // Each replica is a parallel AND_2 with the same inputs (valid, n_flush_mask)
    // and is consumed by a single downstream cluster.
    output wire        outs_valid_to_decode_o,
    output wire        outs_valid_to_btb_o,
    output wire        outs_valid_to_pred_o,
    output wire        outs_valid_to_fetch_o,
    output wire        outs_flush_o,
    output wire        outs_farFlush_o,
    output wire        outs_callFlush_o,
    // miss_prediction replicated to keep the external consumer (Predictor/GShare)
    // off the internal u_and_outs_flush load.
    output wire        outs_miss_prediction_to_pred_o,
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
    wire valid_raw;
    `AND_2(u_and_valid, 1, valid_raw, stage_valid_i, br_info_valid_i)
    // valid fanout 7 → bufferH16$ smallest fit.
    bufferH16$ u_buf_valid (.out(valid), .in(valid_raw));

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
    // taken fans out to ~70 cells (used in many flush/select paths) -- buffer
    // with bufferH256$ (0.54 ns).  Single consumer paths means replication
    // doesn't help; smallest single-cell that fits 70 is bufferH256$.
    wire br_ucond_or_cond;
    `OR_2(u_or_ucond_cond, 1, br_ucond_or_cond, br_ucond_i, cond_br_res)
    wire taken;
    wire taken_raw;
    `AND_2(u_and_taken, 1, taken_raw, br_ucond_or_cond, valid)
    bufferH256$ u_buf_taken (.out(taken), .in(taken_raw));

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

    // miss_prediction replicated: one internal copy for u_and_outs_flush below,
    // one external copy that drives the Predictor/GShare port.
    wire miss_prediction_int;
    `AND_2(u_and_miss_pred_int,  1, miss_prediction_int,            mp_combined, valid)
    `AND_2(u_and_miss_pred_pred, 1, outs_miss_prediction_to_pred_o, mp_combined, valid)

    // clr_exp_mode = special_br_i & valid
    wire clr_exp_mode;
    `AND_2(u_and_clr_exp, 1, clr_exp_mode, special_br_i, valid)

    // ---- Output assembly ----
    // outs.valid = valid & ~flush_mask
    // Replicated 4-way: one internal copy for u_and_outs_flush, four external
    // copies (one per consumer cluster: Decode, Fetch BTB, Fetch Predictor,
    // Fetch top/BTFN). Each AND_2 is parallel-driven by (valid, n_flush_mask).
    wire n_flush_mask;
    `INV_N(u_inv_flush_mask, 1, flush_mask, n_flush_mask)
    wire outs_valid_int;
    `AND_2(u_and_outs_valid_int,    1, outs_valid_int,         valid, n_flush_mask)
    `AND_2(u_and_outs_valid_decode, 1, outs_valid_to_decode_o, valid, n_flush_mask)
    `AND_2(u_and_outs_valid_btb,    1, outs_valid_to_btb_o,    valid, n_flush_mask)
    `AND_2(u_and_outs_valid_pred,   1, outs_valid_to_pred_o,   valid, n_flush_mask)
    `AND_2(u_and_outs_valid_fetch,  1, outs_valid_to_fetch_o,  valid, n_flush_mask)

    // outs.flush = miss_prediction_int & ~flush_mask & valid (uses internal copies)
    `AND_3(u_and_outs_flush, 1, outs_flush_o, miss_prediction_int, n_flush_mask, valid)

    // outs.br_target = taken ? real_br_target : NEIP_i
    // mux2$ output (32-bit) drives 66 cells/bit -- bufferH256$ per bit.
    wire [`ADDRESS_BITS-1:0] outs_br_target_raw;
    `MUX_2(u_mux_br_target, `ADDRESS_BITS, outs_br_target_raw, NEIP_i, real_br_target, taken)
    genvar gi_brt;
    generate
        for (gi_brt = 0; gi_brt < `ADDRESS_BITS; gi_brt = gi_brt + 1) begin : g_brt_buf
            bufferH256$ u_buf_brt (
                .out(outs_br_target_o[gi_brt]),
                .in (outs_br_target_raw[gi_brt]));
        end
    endgenerate

    // Pure-passthrough outputs
    assign outs_farFlush_o        = farFlush;
    assign outs_callFlush_o       = callFlush;
    assign outs_br_eip_o          = br_eip_i;
    assign outs_neip_o            = NEIP_i;
    assign outs_taken_o           = taken;
    assign outs_br_XCL_o          = br_xcl_i;
    assign outs_clr_exp_mode_o    = clr_exp_mode;
    assign outs_br_ucond_o        = br_ucond_i;

endmodule
