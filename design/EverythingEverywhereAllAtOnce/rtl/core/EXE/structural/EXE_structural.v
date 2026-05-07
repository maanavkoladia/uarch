// EXE_structural.v
//
// Pure Verilog-2005 top of the execute stage. Same internal structure as
// EXE_structural.sv (kept on disk as the SV reference) but with all SV-only
// constructs removed:
//   * No `import` of any package.
//   * No struct or typedef ports -- exe_latches_t, wb_outputs_t (the one
//     field consumed: wb_stall), rr_outputs_t, wb_latches_t, exe_outputs_t
//     are unrolled into individual flat wires whose widths come from the
//     field types.
//   * No unpacked-array ports -- byte arrays (ld_buf, res_buf) are passed
//     as packed buses; regFileValues[NUM_REGS] is split into 26 named wires.
//   * `bool`/`logic`/`uint*_t` -> `wire [W-1:0]`.
//
// Body is identical in shape to EXE_structural.sv; the only deletions are
// the per-byte ld_buf pack and per-byte res_buf unpack generates (now
// pass-through, since both are packed buses on the port boundary).

module EXE (
    input  wire         clk,
    input  wire         rst,

    // ====================================================================
    // exe_latches_t (latches_i)
    // ====================================================================
    input  wire         latches_valid,

    // exe_cs_t (latches_i.cs)
    input  wire         latches_cs_ST_OP,
    input  wire [5:0]   latches_cs_OP_TYPE,
    input  wire [4:0]   latches_cs_alu_inputA_sel,
    input  wire [4:0]   latches_cs_alu_inputB_sel,
    input  wire [4:0]   latches_cs_branch_target_sel,
    input  wire         latches_cs_shift_by_one,
    input  wire         latches_cs_br_ucond,
    input  wire         latches_cs_relative_branch,
    input  wire         latches_cs_special_br,
    input  wire         latches_cs_is_far,
    input  wire         latches_cs_is_call,
    input  wire         latches_cs_second_flag_needed,
    input  wire         latches_cs_rep_no_zf_update,

    // wb_cs_t (latches_i.wb_cs)
    input  wire         latches_wb_cs_ST_OP,
    input  wire         latches_wb_cs_WB_DR,
    input  wire         latches_wb_cs_WB_SR,
    input  wire         latches_wb_cs_WB_EAX,

    input  wire [3:0]   latches_data_size_vec,
    input  wire [3:0]   latches_sr_data_size_vec,
    input  wire         latches_shift_sr_up,
    input  wire         latches_shift_sr_down,
    input  wire         latches_ST_XCL,
    input  wire [14:0]  latches_ST_PADDR_0,
    input  wire [14:0]  latches_ST_PADDR_1,
    input  wire         latches_MIO,

    // br_info_t (latches_i.br_info)
    input  wire         latches_br_info_valid,
    input  wire [31:0]  latches_br_info_br_eip,
    input  wire         latches_br_info_br_xcl,
    input  wire         latches_br_info_br_pred_taken,
    input  wire [31:0]  latches_br_info_speculative_target,

    input  wire [31:0]  latches_br_rel_target,
    input  wire [31:0]  latches_NEIP,
    input  wire [31:0]  latches_EIP,
    input  wire [31:0]  latches_EAX,
    input  wire [63:0]  latches_imm64,
    input  wire [255:0] latches_ld_buf,         // EXE_BUFFER_SIZE = 32 bytes
    input  wire [4:0]   latches_sr_id,
    input  wire [63:0]  latches_sr_data,
    input  wire [4:0]   latches_dr_id,
    input  wire [63:0]  latches_dr_data,
    input  wire [14:0]  latches_ld_addy,

    // ====================================================================
    // wb_outputs_t (wb_outs_i) -- only wb_stall is consumed
    // ====================================================================
    input  wire         wb_outs_wb_stall,

    // ====================================================================
    // rr_outputs_t (rr_outs_i)
    // ====================================================================
    input  wire [31:0]  rr_outs_codeSeg_data,
    input  wire [63:0]  rr_outs_regFileValues_0,
    input  wire [63:0]  rr_outs_regFileValues_1,
    input  wire [63:0]  rr_outs_regFileValues_2,
    input  wire [63:0]  rr_outs_regFileValues_3,
    input  wire [63:0]  rr_outs_regFileValues_4,
    input  wire [63:0]  rr_outs_regFileValues_5,
    input  wire [63:0]  rr_outs_regFileValues_6,
    input  wire [63:0]  rr_outs_regFileValues_7,
    input  wire [63:0]  rr_outs_regFileValues_8,
    input  wire [63:0]  rr_outs_regFileValues_9,
    input  wire [63:0]  rr_outs_regFileValues_10,
    input  wire [63:0]  rr_outs_regFileValues_11,
    input  wire [63:0]  rr_outs_regFileValues_12,
    input  wire [63:0]  rr_outs_regFileValues_13,
    input  wire [63:0]  rr_outs_regFileValues_14,
    input  wire [63:0]  rr_outs_regFileValues_15,
    input  wire [63:0]  rr_outs_regFileValues_16,
    input  wire [63:0]  rr_outs_regFileValues_17,
    input  wire [63:0]  rr_outs_regFileValues_18,
    input  wire [63:0]  rr_outs_regFileValues_19,
    input  wire [63:0]  rr_outs_regFileValues_20,
    input  wire [63:0]  rr_outs_regFileValues_21,
    input  wire [63:0]  rr_outs_regFileValues_22,
    input  wire [63:0]  rr_outs_regFileValues_23,
    input  wire [63:0]  rr_outs_regFileValues_24,
    input  wire [63:0]  rr_outs_regFileValues_25,

    // ====================================================================
    // wb_latches_t (wb_latches_next_o)
    // ====================================================================
    output wire         wb_latches_next_valid,
    output wire         wb_latches_next_cs_ST_OP,
    output wire         wb_latches_next_cs_WB_DR,
    output wire         wb_latches_next_cs_WB_SR,
    output wire         wb_latches_next_cs_WB_EAX,
    output wire         wb_latches_next_ST_XCL,
    output wire [14:0]  wb_latches_next_ST_PADDR_0,
    output wire [15:0]  wb_latches_next_ST_BIT_VEC_0,
    output wire [14:0]  wb_latches_next_ST_PADDR_1,
    output wire [15:0]  wb_latches_next_ST_BIT_VEC_1,
    output wire         wb_latches_next_MIO,
    output wire [31:0]  wb_latches_next_EIP,
    output wire [255:0] wb_latches_next_res_buf,
    output wire [4:0]   wb_latches_next_sr_id,
    output wire [63:0]  wb_latches_next_sr_data,
    output wire [4:0]   wb_latches_next_dr_id,
    output wire [63:0]  wb_latches_next_dr_data,
    output wire [31:0]  wb_latches_next_EAX,

    // ====================================================================
    // exe_outputs_t (outs_o)
    // ====================================================================
    output wire         outs_valid,

    // exe_br_resolution_outputs_t (outs_o.br_res_out)
    output wire         outs_br_res_valid,
    output wire         outs_br_res_flush,
    output wire         outs_br_res_farFlush,
    output wire         outs_br_res_callFlush,
    output wire         outs_br_res_miss_prediction,
    output wire [31:0]  outs_br_res_br_eip,
    output wire [31:0]  outs_br_res_neip,
    output wire [31:0]  outs_br_res_br_target,
    output wire         outs_br_res_taken,
    output wire         outs_br_res_br_XCL,
    output wire         outs_br_res_clr_exp_mode,
    output wire         outs_br_res_br_ucond,

    output wire         outs_DR_0_we,
    output wire [4:0]   outs_DR_0_id,
    output wire [63:0]  outs_DR_0_data,
    output wire         outs_DR_1_we,
    output wire [4:0]   outs_DR_1_id,
    output wire [63:0]  outs_DR_1_data,
    output wire         outs_clr_ZF_sb,
    output wire         outs_ZF,
    output wire         outs_ST_OP,
    output wire         outs_ST_XCL,
    output wire [14:0]  outs_ST_PADDR_0,
    output wire [14:0]  outs_ST_PADDR_1,
    output wire         outs_wb_stage_latch_we
);

    wire [31:0] flags_reg;

    //==========================================================================
    // VALID-LOGIC + STALL FLOP
    //==========================================================================
    wire wb_stage_we_valid_unit_o;
    wire wb_stage_next_vaild_o;
    wb_valid_logic wb_valid_logic_unit (
        .WB_we_o    (wb_stage_we_valid_unit_o),
        .N_WB_V_o   (wb_stage_next_vaild_o),
        .EXE_V_i    (latches_valid),
        .WB_stall_i (wb_outs_wb_stall)
    );

    wire stall_flop;
    `REG_RST(u_stall_flop, 1, clk, rst, wb_outs_wb_stall, stall_flop)


    //==========================================================================
    // REGFILE-VALUE FORWARDING MUX
    //==========================================================================
    wire [63:0] dr_data;
    wire [63:0] sr_data;
    wire [31:0] eax_data;

    // Pre-buffer wires; dr_data / sr_data are driven by bufferH16$ below
    // to absorb their fanout (~9 / ~6) into a single H-buffer driver.
    wire [63:0] dr_data_raw;
    wire [63:0] sr_data_raw;

    `MUX_32(u_mux_dr_data, 64, dr_data_raw,
        rr_outs_regFileValues_0,  rr_outs_regFileValues_1,
        rr_outs_regFileValues_2,  rr_outs_regFileValues_3,
        rr_outs_regFileValues_4,  rr_outs_regFileValues_5,
        rr_outs_regFileValues_6,  rr_outs_regFileValues_7,
        rr_outs_regFileValues_8,  rr_outs_regFileValues_9,
        rr_outs_regFileValues_10, rr_outs_regFileValues_11,
        rr_outs_regFileValues_12, rr_outs_regFileValues_13,
        rr_outs_regFileValues_14, rr_outs_regFileValues_15,
        rr_outs_regFileValues_16, rr_outs_regFileValues_17,
        rr_outs_regFileValues_18, rr_outs_regFileValues_19,
        rr_outs_regFileValues_20, rr_outs_regFileValues_21,
        rr_outs_regFileValues_22, rr_outs_regFileValues_23,
        rr_outs_regFileValues_24, rr_outs_regFileValues_25,
        64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0,
        latches_dr_id)

    `MUX_32(u_mux_sr_data, 64, sr_data_raw,
        rr_outs_regFileValues_0,  rr_outs_regFileValues_1,
        rr_outs_regFileValues_2,  rr_outs_regFileValues_3,
        rr_outs_regFileValues_4,  rr_outs_regFileValues_5,
        rr_outs_regFileValues_6,  rr_outs_regFileValues_7,
        rr_outs_regFileValues_8,  rr_outs_regFileValues_9,
        rr_outs_regFileValues_10, rr_outs_regFileValues_11,
        rr_outs_regFileValues_12, rr_outs_regFileValues_13,
        rr_outs_regFileValues_14, rr_outs_regFileValues_15,
        rr_outs_regFileValues_16, rr_outs_regFileValues_17,
        rr_outs_regFileValues_18, rr_outs_regFileValues_19,
        rr_outs_regFileValues_20, rr_outs_regFileValues_21,
        rr_outs_regFileValues_22, rr_outs_regFileValues_23,
        rr_outs_regFileValues_24, rr_outs_regFileValues_25,
        64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0,
        latches_sr_id)

    // Buffer dr_data / sr_data with bufferH16$ (0.24 ns typ, rated 16 loads)
    // — smallest H-buffer covering both signals' worst fanouts (9 and 6).
    genvar gi_buf_rf;
    generate
        for (gi_buf_rf = 0; gi_buf_rf < 64; gi_buf_rf = gi_buf_rf + 1) begin : g_rf_buf
            bufferH16$ u_buf_dr (.out(dr_data[gi_buf_rf]), .in(dr_data_raw[gi_buf_rf]));
            bufferH16$ u_buf_sr (.out(sr_data[gi_buf_rf]), .in(sr_data_raw[gi_buf_rf]));
        end
    endgenerate

    assign eax_data = rr_outs_regFileValues_7[31:0];   // EAX register id = 7


    //==========================================================================
    // ALU INPUT SELECTION
    //==========================================================================
    wire [63:0] srA;
    wire [63:0] srB;
    wire [31:0] br_sel;
    wire [63:0] exp_ld_buf_o;

    alu_input_sel u_alu_input_sel (
        .ld_addr_0      (latches_ld_addy),
        .res_buf_in     (latches_ld_buf),
        .imm64          (latches_imm64),
        .sr_data        (sr_data),
        .dr_data        (dr_data),
        .EAX            (eax_data),
        .NEIP           (latches_NEIP),
        .EIP            (latches_EIP),
        .flags          (flags_reg),
        .alu_inputA_sel (latches_cs_alu_inputA_sel),
        .alu_inputB_sel (latches_cs_alu_inputB_sel),
        .shift_sr_down  (latches_shift_sr_down),
        .shift_sr_up    (latches_shift_sr_up),
        .br_input_sel   (latches_cs_branch_target_sel),
        .exp_ld_buf_o   (exp_ld_buf_o),
        .srA_64         (srA),
        .srB_64         (srB),
        .br_sel         (br_sel)
    );


    //==========================================================================
    // FUNCTIONAL UNIT OUTPUT WIRES
    //==========================================================================
    wire [63:0] aaa_dr_o;
    wire [63:0] adc_dr_o, adc_res_buf_o;
    wire [63:0] add_dr_o, add_res_buf_o;
    wire [63:0] add_df_dr_o, add_df_sr_o;
    wire [63:0] and_dr_o, and_res_buf_o;
    wire [63:0] bsf_dr_o, bsf_res_buf_o;
    wire [63:0] call_sr_o, call_res_buf;
    wire [63:0] cmpxchg_EAX_o, cmpxchg_dr_o, cmpxchg_buf_o;
    wire [63:0] far_call_sr_o, far_call_res_buf, far_call_dr_o;
    wire [63:0] exp_call_sr_o, exp_call_res_buf, exp_call_dr_o;
    wire [31:0] exp_call_eip;
    wire [63:0] iretd_cs_o, iretd_stack_ptr_o;
    wire [63:0] mov_dr_o, mov_res_buf_o;
    wire [63:0] mov_s_dr_o, mov_s_sr_o, mov_s_res_buf_o;
    wire [63:0] not_dr_o, not_res_buf_o;
    wire [63:0] or_dr_o, or_res_buf_o;
    wire [63:0] packssdw_dr_o, packsswb_dr_o;
    wire [63:0] paddd_dr_o, paddw_dr_o;
    wire [63:0] pavgb_dr_o, pavgw_dr_o;
    wire [63:0] pop_dr_o, pop_sr_o, pop_res_buf;
    wire [63:0] push_res_buf, push_sr_o;
    wire [63:0] ret_far_imm_dr_o, ret_far_imm_sr_o;
    wire [63:0] ret_far_cs_o, ret_far_next_ptr_o;
    wire [63:0] ret_imm_sr_o, ret_sr_o;
    wire [63:0] sal_dr_o, sal_res_buf_o;
    wire [63:0] sar_dr_o, sar_res_buf_o;
    wire [63:0] sbb_dr_o, sbb_res_buf_o;
    wire [63:0] xchg_dr_o, xchg_sr_o, xchg_res_buf;
    wire [63:0] far_jmp_dr_o;

    wire aaa_af_o, aaa_cf_o;
    wire adc_af_o, adc_cf_o, adc_of_o, adc_pf_o, adc_sf_o, adc_zf_o;
    wire add_af_o, add_cf_o, add_of_o, add_pf_o, add_sf_o, add_zf_o;
    wire and_of_o, and_pf_o, and_sf_o, and_zf_o, and_cf_o, and_af_o;
    wire bsf_zf_o;
    wire cmp_cf_o, cmp_pf_o, cmp_af_o, cmp_zf_o, cmp_sf_o, cmp_of_o;
    wire cmpxchg_cf_o, cmpxchg_pf_o, cmpxchg_af_o, cmpxchg_zf_o, cmpxchg_sf_o, cmpxchg_of_o;
    wire or_cf_o, or_pf_o, or_zf_o, or_sf_o, or_of_o, or_af_o;
    wire sal_cf_o, sal_pf_o, sal_zf_o, sal_sf_o, sal_of_o, sal_af_o;
    wire sar_cf_o, sar_pf_o, sar_zf_o, sar_sf_o, sar_of_o, sar_af_o;
    wire sbb_cf_o, sbb_pf_o, sbb_af_o, sbb_zf_o, sbb_sf_o, sbb_of_o;
    wire iretd_cf_o, iretd_pf_o, iretd_af_o, iretd_zf_o, iretd_sf_o, iretd_of_o;
    wire rep_cmp_zf_o;


    //==========================================================================
    // RESULT-BUFFER SELECT + LOGIC + BIT-VECTOR
    //==========================================================================
    wire [63:0] res_buf_selected;
    res_buf_sel u_res_buf_sel (
        .op_type            (latches_cs_OP_TYPE),
        .adc_res_buf_i      (adc_res_buf_o),
        .add_res_buf_i      (add_res_buf_o),
        .and_res_buf_i      (and_res_buf_o),
        .call_res_buf_i     (call_res_buf),
        .cmpxchg_buf_i      (cmpxchg_buf_o),
        .far_call_res_buf_i (far_call_res_buf),
        .mov_res_buf_i      (mov_res_buf_o),
        .mov_s_res_buf_i    (mov_s_res_buf_o),
        .not_res_buf_i      (not_res_buf_o),
        .or_res_buf_i       (or_res_buf_o),
        .push_res_buf_i     (push_res_buf),
        .pop_res_buf_i      (pop_res_buf),
        .sar_res_buf_i      (sar_res_buf_o),
        .sal_res_buf_i      (sal_res_buf_o),
        .sbb_res_buf_i      (sbb_res_buf_o),
        .xchg_res_buf_i     (xchg_res_buf),
        .exp_call_res_buf_i (exp_call_res_buf),
        .res_buf_o          (res_buf_selected)
    );

    res_buf_logic u_res_buf_logic (
        .res_info_i (res_buf_selected),
        .st_addr_0  (latches_ST_PADDR_0),
        .res_buf    (wb_latches_next_res_buf)
    );

    wire [15:0] bit_vec_0_next;
    wire [15:0] bit_vec_1_next;
    bit_vec_logic u_bit_vec_logic (
        .st_addr_0 (latches_ST_PADDR_0),
        .ST_XCL    (latches_ST_XCL),
        .data_size (latches_data_size_vec),
        .st_vec0   (bit_vec_0_next),
        .st_vec1   (bit_vec_1_next)
    );


    //==========================================================================
    // DR / SR SELECT
    //==========================================================================
    wire [63:0] dr_next;
    dr_sel u_dr_sel (
        .op_type          (latches_cs_OP_TYPE),
        .WB_DR            (latches_wb_cs_WB_DR),
        .aaa_dr_i         (aaa_dr_o),
        .adc_dr_i         (adc_dr_o),
        .add_dr_i         (add_dr_o),
        .add_df_dr_i      (add_df_dr_o),
        .and_dr_i         (and_dr_o),
        .bsf_dr_i         (bsf_dr_o),
        .cmpxchg_dr_i     (cmpxchg_dr_o),
        .mov_dr_i         (mov_dr_o),
        .mov_s_dr_i       (mov_s_dr_o),
        .not_dr_i         (not_dr_o),
        .or_dr_i          (or_dr_o),
        .packssdw_dr_i    (packssdw_dr_o),
        .packsswb_dr_i    (packsswb_dr_o),
        .paddd_dr_i       (paddd_dr_o),
        .paddw_dr_i       (paddw_dr_o),
        .pavgb_dr_i       (pavgb_dr_o),
        .pavgw_dr_i       (pavgw_dr_o),
        .pop_dr_i         (pop_dr_o),
        .ret_far_dr_i     (ret_far_cs_o),
        .ret_far_imm_dr_i (ret_far_imm_dr_o),
        .far_call_dr_i    (far_call_dr_o),
        .far_jmp_dr_i     (far_jmp_dr_o),
        .sal_dr_i         (sal_dr_o),
        .sar_dr_i         (sar_dr_o),
        .sbb_dr_i         (sbb_dr_o),
        .xchg_dr_i        (xchg_dr_o),
        .exp_call_dr_i    (exp_call_dr_o),
        .iretd_cs_dr_i    (iretd_cs_o),
        .dr_data          (dr_data),
        .dr_o             (dr_next)
    );

    wire [63:0] sr_next;
    sr_sel u_sr_sel (
        .op_type          (latches_cs_OP_TYPE),
        .WB_SR            (latches_wb_cs_WB_SR),
        .sr_data          (sr_data),
        .add_df_sr_i      (add_df_sr_o),
        .mov_s_sr_i       (mov_s_sr_o),
        .pop_sr_i         (pop_sr_o),
        .push_sr_i        (push_sr_o),
        .ret_far_sr_i     (ret_far_next_ptr_o),
        .ret_far_imm_sr_i (ret_far_imm_sr_o),
        .ret_imm_sr_i     (ret_imm_sr_o),
        .ret_sr_i         (ret_sr_o),
        .xchg_sr_i        (xchg_sr_o),
        .call_sr_i        (call_sr_o),
        .far_call_sr_i    (far_call_sr_o),
        .exp_call_sr_i    (exp_call_sr_o),
        .iretd_sr_i       (iretd_stack_ptr_o),
        .sr_o             (sr_next)
    );


    //==========================================================================
    // REGISTER WRITEBACK CONTROL
    //==========================================================================
    wire [4:0]  dr0_id_o, dr1_id_o;
    wire        dr0_we_o, dr1_we_o;
    wire [63:0] dr0_data_o, dr1_data_o;

    wire [63:0] next_EAX;
    assign next_EAX = latches_wb_cs_WB_EAX ? cmpxchg_EAX_o : {32'd0, eax_data};

    reg_wb_logic u_reg_wb (
        .op_type      (latches_cs_OP_TYPE),
        .next_dr_data (dr_next),
        .dr_id        (latches_dr_id),
        .WB_DR        (latches_wb_cs_WB_DR),
        .next_EAX     (next_EAX),
        .next_sr_data (sr_next),
        .sr_id        (latches_sr_id),
        .WB_EAX       (latches_wb_cs_WB_EAX),
        .WB_SR        (latches_wb_cs_WB_SR),
        .valid        (latches_valid),
        .stall_flop   (stall_flop),
        .dr0_id_o     (dr0_id_o),
        .dr0_we_o     (dr0_we_o),
        .dr0_data_o   (dr0_data_o),
        .dr1_id_o     (dr1_id_o),
        .dr1_we_o     (dr1_we_o),
        .dr1_data_o   (dr1_data_o)
    );


    //==========================================================================
    // BRANCH RESOLUTION
    //==========================================================================
    wire        br_outs_valid_w;
    wire        br_outs_flush_w;
    wire        br_outs_farFlush_w;
    wire        br_outs_callFlush_w;
    wire        br_outs_miss_prediction_w;
    wire [31:0] br_outs_br_eip_w;
    wire [31:0] br_outs_neip_w;
    wire [31:0] br_outs_br_target_w;
    wire        br_outs_taken_w;
    wire        br_outs_br_XCL_w;
    wire        br_outs_clr_exp_mode_w;
    wire        br_outs_br_ucond_w;

    branch_res u_br_res (
        .stage_valid_i        (latches_valid),
        .br_info_valid_i      (latches_br_info_valid),
        .flush_mask           (stall_flop),
        .br_eip_i             (latches_br_info_br_eip),
        .br_xcl_i             (latches_br_info_br_xcl),
        .br_pred_taken_i      (latches_br_info_br_pred_taken),
        .speculative_target_i (latches_br_info_speculative_target),
        .br_ucond_i           (latches_cs_br_ucond),
        .relative_branch_i    (latches_cs_relative_branch),
        .special_br_i         (latches_cs_special_br),
        .is_far_i             (latches_cs_is_far),
        .is_call_i            (latches_cs_is_call),
        .second_flag_needed_i (latches_cs_second_flag_needed),
        .br_source_i          (br_sel),
        .NEIP_i               (latches_NEIP),
        .br_rel_target        (latches_br_rel_target),
        .exp_target           (exp_call_eip),
        .CF                   (flags_reg[`EXE_FLAG_CF_IDX]),
        .ZF                   (flags_reg[`EXE_FLAG_ZF_IDX]),
        .outs_valid_o            (br_outs_valid_w),
        .outs_flush_o            (br_outs_flush_w),
        .outs_farFlush_o         (br_outs_farFlush_w),
        .outs_callFlush_o        (br_outs_callFlush_w),
        .outs_miss_prediction_o  (br_outs_miss_prediction_w),
        .outs_br_eip_o           (br_outs_br_eip_w),
        .outs_neip_o             (br_outs_neip_w),
        .outs_br_target_o        (br_outs_br_target_w),
        .outs_taken_o            (br_outs_taken_w),
        .outs_br_XCL_o           (br_outs_br_XCL_w),
        .outs_clr_exp_mode_o     (br_outs_clr_exp_mode_w),
        .outs_br_ucond_o         (br_outs_br_ucond_w)
    );


    //==========================================================================
    // FLAGS REGISTER  (REG_RST_WE 32-bit, gated by latches_valid)
    //==========================================================================
    wire af_flag_o;
    wire cf_flag_o;
    wire df_flag_o;
    wire of_flag_o;
    wire pf_flag_o;
    wire sf_flag_o;
    wire zf_flag_o;
    wire clr_ZF_sb;

    wire [31:0] flags_din;
    assign flags_din = {20'b0,
                        of_flag_o,
                        df_flag_o,
                        1'b0, 1'b0,
                        sf_flag_o,
                        zf_flag_o,
                        1'b0,
                        af_flag_o,
                        1'b0,
                        pf_flag_o,
                        1'b0,
                        cf_flag_o};

    wire [31:0] flags_reg_raw;
    `REG_RST_WE(u_flags_reg, 32, clk, rst, latches_valid, flags_din, flags_reg_raw)

    // flags_reg has one bit (likely CF or ZF) with fanout 195 — feeds many
    // conditional ops across EXE. bufferH256$ (rated 256, 0.54 ns typ) is the
    // smallest H-buffer that covers 195. Other flag bits have lower fanout
    // but are buffered uniformly here for code simplicity; if that 0.30 ns
    // delta vs bufferH16$ shows up on the critical path, individual bits can
    // be downsized later (the dead bits at flags_reg[1,3,5,8,9,11..31] could
    // also be left unbuffered, but flag-register output is non-critical
    // versus the read-side fanout cost).
    genvar gi_fl;
    generate
        for (gi_fl = 0; gi_fl < 32; gi_fl = gi_fl + 1) begin : g_flags_buf
            bufferH256$ u_buf_fl (.out(flags_reg[gi_fl]), .in(flags_reg_raw[gi_fl]));
        end
    endgenerate


    //==========================================================================
    // FLAG SELECTORS
    //==========================================================================
    af_flag_sel u_af_flag_sel (
        .and_af       (and_af_o),
        .or_af        (or_af_o),
        .aaa_af       (aaa_af_o),
        .adc_af       (adc_af_o),
        .add_op_af    (add_af_o),
        .sal_op_af    (sal_af_o),
        .sar_op_af    (sar_af_o),
        .cmp_af       (cmp_af_o),
        .cmpxchg_af   (cmpxchg_af_o),
        .sbb_af       (sbb_af_o),
        .iretd_af     (iretd_af_o),
        .curr_af_flag (flags_reg[`EXE_FLAG_AF_IDX]),
        .op_type      (latches_cs_OP_TYPE),
        .af_flag_o    (af_flag_o)
    );

    cf_flag_sel u_cf_flag_sel (
        .aaa_cf       (aaa_cf_o),
        .adc_cf       (adc_cf_o),
        .add_cf       (add_cf_o),
        .and_cf       (and_cf_o),
        .cmp_cf       (cmp_cf_o),
        .cmpxchg_cf   (cmpxchg_cf_o),
        .or_cf        (or_cf_o),
        .sal_cf       (sal_cf_o),
        .sar_cf       (sar_cf_o),
        .sbb_cf       (sbb_cf_o),
        .iretd_cf     (iretd_cf_o),
        .curr_cf_flag (flags_reg[`EXE_FLAG_CF_IDX]),
        .op_type      (latches_cs_OP_TYPE),
        .cf_flag_o    (cf_flag_o)
    );

    df_flag_sel u_df_flag_sel (
        .curr_df_flag (flags_reg[`EXE_FLAG_DF_IDX]),
        .op_type      (latches_cs_OP_TYPE),
        .df_flag_o    (df_flag_o)
    );

    of_flag_sel u_of_flag_sel (
        .adc_of       (adc_of_o),
        .add_of       (add_of_o),
        .and_of       (and_of_o),
        .cmp_of       (cmp_of_o),
        .cmpxchg_of   (cmpxchg_of_o),
        .or_of        (or_of_o),
        .sal_of       (sal_of_o),
        .sar_of       (sar_of_o),
        .sbb_of       (sbb_of_o),
        .iretd_of     (iretd_of_o),
        .op_type      (latches_cs_OP_TYPE),
        .curr_of_flag (flags_reg[`EXE_FLAG_OF_IDX]),
        .of_flag_o    (of_flag_o)
    );

    pf_flag_sel u_pf_flag_sel (
        .adc_pf       (adc_pf_o),
        .add_pf       (add_pf_o),
        .and_pf       (and_pf_o),
        .cmp_pf       (cmp_pf_o),
        .cmpxchg_pf   (cmpxchg_pf_o),
        .or_pf        (or_pf_o),
        .sal_pf       (sal_pf_o),
        .sar_pf       (sar_pf_o),
        .sbb_pf       (sbb_pf_o),
        .iretd_pf     (iretd_pf_o),
        .op_type      (latches_cs_OP_TYPE),
        .curr_pf_flag (flags_reg[`EXE_FLAG_PF_IDX]),
        .pf_flag_o    (pf_flag_o)
    );

    sf_flag_sel u_sf_flag_sel (
        .add_sf       (add_sf_o),
        .adc_sf       (adc_sf_o),
        .and_sf       (and_sf_o),
        .cmp_sf       (cmp_sf_o),
        .cmpxchg_sf   (cmpxchg_sf_o),
        .or_sf        (or_sf_o),
        .sal_sf       (sal_sf_o),
        .sar_sf       (sar_sf_o),
        .sbb_sf       (sbb_sf_o),
        .iretd_sf     (iretd_sf_o),
        .op_type      (latches_cs_OP_TYPE),
        .curr_sf_flag (flags_reg[`EXE_FLAG_SF_IDX]),
        .sf_flag_o    (sf_flag_o)
    );

    zf_flag_sel u_zf_flag_sel (
        .rep_no_zf_update (latches_cs_rep_no_zf_update),
        .adc_zf           (adc_zf_o),
        .add_zf           (add_zf_o),
        .and_zf           (and_zf_o),
        .bsf_zf           (bsf_zf_o),
        .cmp_zf           (cmp_zf_o),
        .cmpxchg_zf       (cmpxchg_zf_o),
        .iretd_zf         (iretd_zf_o),
        .or_zf            (or_zf_o),
        .sal_zf           (sal_zf_o),
        .sar_zf           (sar_zf_o),
        .sbb_zf           (sbb_zf_o),
        .rep_cmp_zf       (rep_cmp_zf_o),
        .curr_zf_flag     (flags_reg[`EXE_FLAG_ZF_IDX]),
        .op_type          (latches_cs_OP_TYPE),
        .zf_flag_o        (zf_flag_o),
        .clr_ZF_sb        (clr_ZF_sb)
    );


    //==========================================================================
    // NEXT-LATCH ASSIGNMENTS
    //==========================================================================
    assign wb_latches_next_valid        = wb_stage_next_vaild_o;
    assign wb_latches_next_cs_ST_OP     = latches_wb_cs_ST_OP;
    assign wb_latches_next_cs_WB_DR     = latches_wb_cs_WB_DR;
    assign wb_latches_next_cs_WB_SR     = latches_wb_cs_WB_SR;
    assign wb_latches_next_cs_WB_EAX    = latches_wb_cs_WB_EAX;
    assign wb_latches_next_ST_XCL       = latches_ST_XCL;
    assign wb_latches_next_ST_PADDR_0   = latches_ST_PADDR_0;
    assign wb_latches_next_ST_BIT_VEC_0 = bit_vec_0_next;
    assign wb_latches_next_ST_PADDR_1   = latches_ST_PADDR_1;
    assign wb_latches_next_ST_BIT_VEC_1 = bit_vec_1_next;
    assign wb_latches_next_MIO          = latches_MIO;
    assign wb_latches_next_EIP          = latches_EIP;
    assign wb_latches_next_sr_id        = latches_sr_id;
    assign wb_latches_next_sr_data      = sr_next;
    assign wb_latches_next_dr_id        = latches_dr_id;
    assign wb_latches_next_dr_data      = dr_next;
    assign wb_latches_next_EAX          = latches_wb_cs_WB_EAX ? cmpxchg_EAX_o[31:0] : eax_data;
    // wb_latches_next_res_buf is driven by res_buf_logic above.

    // outs_o assembly (per-field).
    assign outs_valid               = latches_valid;
    assign outs_br_res_valid        = br_outs_valid_w;
    assign outs_br_res_flush        = br_outs_flush_w;
    assign outs_br_res_farFlush     = br_outs_farFlush_w;
    assign outs_br_res_callFlush    = br_outs_callFlush_w;
    assign outs_br_res_miss_prediction = br_outs_miss_prediction_w;
    assign outs_br_res_br_eip       = br_outs_br_eip_w;
    assign outs_br_res_neip         = br_outs_neip_w;
    assign outs_br_res_br_target    = br_outs_br_target_w;
    assign outs_br_res_taken        = br_outs_taken_w;
    assign outs_br_res_br_XCL       = br_outs_br_XCL_w;
    assign outs_br_res_clr_exp_mode = br_outs_clr_exp_mode_w;
    assign outs_br_res_br_ucond     = br_outs_br_ucond_w;
    assign outs_DR_0_we             = dr0_we_o;
    assign outs_DR_0_id             = dr0_id_o;
    assign outs_DR_0_data           = dr0_data_o;
    assign outs_DR_1_we             = dr1_we_o;
    assign outs_DR_1_id             = dr1_id_o;
    assign outs_DR_1_data           = dr1_data_o;
    assign outs_ZF                  = flags_reg[`EXE_FLAG_ZF_IDX];
    assign outs_clr_ZF_sb           = clr_ZF_sb && latches_valid;
    assign outs_ST_OP               = latches_cs_ST_OP;
    assign outs_ST_XCL              = latches_ST_XCL;
    assign outs_ST_PADDR_0          = latches_ST_PADDR_0;
    assign outs_ST_PADDR_1          = latches_ST_PADDR_1;
    assign outs_wb_stage_latch_we   = wb_stage_we_valid_unit_o;


    //==========================================================================
    // FUNCTIONAL UNITS
    //==========================================================================
    aaa_op u_aaa (
        .EAX_in    (srA),
        .AF_flag_in(flags_reg[`EXE_FLAG_AF_IDX]),
        .dr_o      (aaa_dr_o),
        .CF        (aaa_cf_o),
        .AF        (aaa_af_o)
    );

    adc_op u_adc_op (
        .srA(srA), .srB(srB),
        .CF_in(flags_reg[`EXE_FLAG_CF_IDX]),
        .data_size(latches_data_size_vec),
        .dr_o(adc_dr_o), .res_buf_o(adc_res_buf_o),
        .CF(adc_cf_o), .PF(adc_pf_o), .AF(adc_af_o),
        .ZF(adc_zf_o), .SF(adc_sf_o), .OF(adc_of_o)
    );

    add_op u_add_op (
        .srA(srA), .srB(srB), .data_size(latches_data_size_vec),
        .dr_o(add_dr_o), .res_buf_o(add_res_buf_o),
        .ZF(add_zf_o), .SF(add_sf_o), .PF(add_pf_o),
        .OF(add_of_o), .CF(add_cf_o), .AF(add_af_o)
    );

    rep_cmp u_rep_cmp_op (
        .srA(srA), .srB(srB),
        .ZF(rep_cmp_zf_o)
    );

    add_df_op u_add_df_op (
        .srA(srA), .srB(srB),
        .curr_df_flag(flags_reg[`EXE_FLAG_DF_IDX]),
        .data_size(latches_data_size_vec),
        .dr_o(add_df_dr_o), .sr_o(add_df_sr_o)
    );

    and_op u_and_op (
        .srA(srA), .srB(srB), .data_size(latches_data_size_vec),
        .dr_o(and_dr_o), .res_buf_o(and_res_buf_o),
        .ZF(and_zf_o), .SF(and_sf_o), .PF(and_pf_o),
        .OF(and_of_o), .CF(and_cf_o), .AF(and_af_o)
    );

    bsf_op u_bsf (
        .srA(srA), .srB(srB), .data_size(latches_data_size_vec),
        .dr_o(bsf_dr_o), .res_buf_o(bsf_res_buf_o),
        .ZF(bsf_zf_o)
    );

    cmp u_cmp (
        .srA(srA), .srB(srB), .data_size(latches_data_size_vec),
        .CF(cmp_cf_o), .OF(cmp_of_o), .SF(cmp_sf_o),
        .ZF(cmp_zf_o), .AF(cmp_af_o), .PF(cmp_pf_o)
    );

    cmpxchg_op u_cmpxchg_op (
        .EAX(srB[31:0]), .rm(srA), .r(srB[63:32]),
        .data_size(latches_data_size_vec), .sr_data_size_vec(latches_sr_data_size_vec),
        .dr_o(cmpxchg_dr_o), .EAX_o(cmpxchg_EAX_o), .res_buf(cmpxchg_buf_o),
        .ZF(cmpxchg_zf_o), .SF(cmpxchg_sf_o), .PF(cmpxchg_pf_o),
        .CF(cmpxchg_cf_o), .OF(cmpxchg_of_o), .AF(cmpxchg_af_o)
    );

    not_op u_not_op (
        .srA(srA), .data_size(latches_data_size_vec),
        .dr_o(not_dr_o), .res_buf_o(not_res_buf_o)
    );

    or_op u_or_op (
        .srA(srA), .srB(srB), .data_size(latches_data_size_vec),
        .dr_o(or_dr_o), .res_buf_o(or_res_buf_o),
        .ZF(or_zf_o), .SF(or_sf_o), .PF(or_pf_o),
        .OF(or_of_o), .CF(or_cf_o), .AF(or_af_o)
    );

    sal_op u_sal_op (
        .value_i(srA), .shift_amt_i(srB),
        .data_size(latches_data_size_vec), .sr_data_size_vec(latches_sr_data_size_vec),
        .shift_by_one(latches_cs_shift_by_one),
        .curr_zf_flag(flags_reg[`EXE_FLAG_ZF_IDX]), .curr_sf_flag(flags_reg[`EXE_FLAG_SF_IDX]),
        .curr_pf_flag(flags_reg[`EXE_FLAG_PF_IDX]), .curr_of_flag(flags_reg[`EXE_FLAG_OF_IDX]),
        .curr_cf_flag(flags_reg[`EXE_FLAG_CF_IDX]), .curr_af_flag(flags_reg[`EXE_FLAG_AF_IDX]),
        .dr_o(sal_dr_o), .res_buf_o(sal_res_buf_o),
        .ZF(sal_zf_o), .SF(sal_sf_o), .PF(sal_pf_o),
        .OF(sal_of_o), .AF(sal_af_o), .CF(sal_cf_o)
    );

    sar_op u_sar_op (
        .value_i(srA), .shift_amt_i(srB),
        .data_size(latches_data_size_vec), .shift_by_one(latches_cs_shift_by_one),
        .sr_data_size_vec(latches_sr_data_size_vec),
        .curr_zf_flag(flags_reg[`EXE_FLAG_ZF_IDX]), .curr_sf_flag(flags_reg[`EXE_FLAG_SF_IDX]),
        .curr_pf_flag(flags_reg[`EXE_FLAG_PF_IDX]), .curr_of_flag(flags_reg[`EXE_FLAG_OF_IDX]),
        .curr_cf_flag(flags_reg[`EXE_FLAG_CF_IDX]), .curr_af_flag(flags_reg[`EXE_FLAG_AF_IDX]),
        .dr_o(sar_dr_o), .res_buf_o(sar_res_buf_o),
        .ZF(sar_zf_o), .SF(sar_sf_o), .PF(sar_pf_o),
        .OF(sar_of_o), .CF(sar_cf_o), .AF(sar_af_o)
    );

    sbb_op u_sbb_op (
        .srA(srA), .srB(srB),
        .CF_in(flags_reg[`EXE_FLAG_CF_IDX]),
        .data_size(latches_data_size_vec),
        .dr_o(sbb_dr_o), .res_buf_o(sbb_res_buf_o),
        .CF(sbb_cf_o), .PF(sbb_pf_o), .AF(sbb_af_o),
        .ZF(sbb_zf_o), .SF(sbb_sf_o), .OF(sbb_of_o)
    );

    mov_op u_mov_op (
        .srA(srA), .srB(srB), .data_size(latches_data_size_vec),
        .op_type(latches_cs_OP_TYPE),
        .curr_cf_flag(flags_reg[`EXE_FLAG_CF_IDX]),
        .res_buf_o(mov_res_buf_o), .dr_o(mov_dr_o)
    );

    movs_op u_movs_op (
        .srA(srA), .srB(srB), .data_size(latches_data_size_vec),
        .curr_df_flag(flags_reg[`EXE_FLAG_DF_IDX]),
        .res_buf_o(mov_s_res_buf_o), .dr_o(mov_s_dr_o), .sr_o(mov_s_sr_o)
    );

    xchg_op u_xchg_op(
        .srA(srA),
        .srB(srB),
        .srA_id(latches_dr_id),
        .srB_id(latches_sr_id),
        .st_op(latches_cs_ST_OP),
        .data_size(latches_data_size_vec),
        .sr_data_size_vec(latches_sr_data_size_vec),
        .res_buf(xchg_res_buf),
        .dr_o(xchg_dr_o),
        .sr_o(xchg_sr_o)
    );

    call_op u_call_op (
        .NEIP(srA), .stack_ptr(srB),
        .sr_o(call_sr_o), .res_buf(call_res_buf)
    );

    far_call_op u_far_op (
        .neip(srA[31:0]), .segment(srA[63:32]),
        .stack_ptr(srB), .new_cs({16'd0, latches_imm64[47:32]}),
        .res_buf(far_call_res_buf), .sr_o(far_call_sr_o), .dr_o(far_call_dr_o)
    );

    exp_call_op u_exp_call_op (
        .idt(exp_ld_buf_o), .eip(srA[63:32]),
        .curr_cs(rr_outs_codeSeg_data), .stack_ptr(srB),
        .res_buf(exp_call_res_buf), .dr_o(exp_call_dr_o),
        .sr_o(exp_call_sr_o), .exp_eip(exp_call_eip)
    );

    far_jmp_op u_far_jmp_op (
        .op_type(latches_cs_OP_TYPE), .srA(srA), .dr_o(far_jmp_dr_o)
    );

    iretd_op u_iretd_op (
        .cs(srA[31:0]), .flags(srA[63:32]), .stack_ptr(srB),
        .dr_o(iretd_cs_o), .sr_o(iretd_stack_ptr_o),
        .CF(iretd_cf_o), .PF(iretd_pf_o), .AF(iretd_af_o),
        .ZF(iretd_zf_o), .SF(iretd_sf_o), .OF(iretd_of_o)
    );

    ret_op u_ret_op (.stack_ptr(srB), .sr_o(ret_sr_o));
    ret_imm_op u_ret_imm_op (.imm64(srA), .stack_ptr(srB), .sr_o(ret_imm_sr_o));

    ret_far_op u_ret_far_op (
        .cs(srA[63:32]), .stack_ptr(srB),
        .dr_o(ret_far_cs_o), .sr_o(ret_far_next_ptr_o)
    );

    ret_far_imm u_ret_far_imm (
        .cs(srA[63:32]), .stack_ptr(srB), .imm64(latches_imm64),
        .dr_o(ret_far_imm_dr_o), .sr_o(ret_far_imm_sr_o)
    );

    pop_op u_pop_op (
        .value_i(srA), .sp_i(srB), .curr_dr(latches_dr_data), .data_size(latches_data_size_vec),
        .dr_o(pop_dr_o), .sr_o(pop_sr_o), .res_buf(pop_res_buf)
    );

    push_op u_push_op (
        .value(srA), .sp(srB), .data_size_vec(latches_data_size_vec),
        .res_buf(push_res_buf), .sr_o(push_sr_o)
    );

    packssdw u_packssdw (.srA(srA), .srB(srB), .dr_o(packssdw_dr_o));
    packsswb u_packsswb (.srA(srA), .srB(srB), .dr_o(packsswb_dr_o));
    paddd    u_paddd    (.srA(srA), .srB(srB), .dr_o(paddd_dr_o));
    paddw    u_paddw    (.srA(srA), .srB(srB), .dr_o(paddw_dr_o));
    pavgb    u_pavgb    (.srA(srA), .srB(srB), .dr_o(pavgb_dr_o));
    pavgw    u_pavgw    (.srA(srA), .srB(srB), .dr_o(pavgw_dr_o));

endmodule
