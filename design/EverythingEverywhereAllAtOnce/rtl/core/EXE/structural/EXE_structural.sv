// EXE stage top-level. Stays SystemVerilog because it owns the struct ports
// for stage latches and outputs, but every internal sub-module is the new
// Verilog-2005 structural implementation in `structural/*_structural.v`.
//
// All flop placement and struct unpacking lives here. The structural files
// are pure combinational, single-driver, no SV types.


import core_common_pkg::*;
import core_stage_latches_pkg::*;
import common_pkg::*;
import control_store_pkg::*;
import reg_ids_pkg::*;

module EXE (
    input wire clk,
    input wire rst,

    input  exe_latches_t latches_i,
    input  wb_outputs_t  wb_outs_i,
    input  rr_outputs_t  rr_outs_i,

    output wb_latches_t  wb_latches_next_o,
    output exe_outputs_t outs_o
);


    //==========================================================================
    // VALID-LOGIC + STALL FLOP
    //==========================================================================
    bool wb_stage_we_valid_unit_o;
    bool wb_stage_next_vaild_o;
    wb_valid_logic wb_valid_logic_unit (
        .WB_we_o    (wb_stage_we_valid_unit_o),
        .N_WB_V_o   (wb_stage_next_vaild_o),
        .EXE_V_i    (latches_i.valid),
        .WB_stall_i (wb_outs_i.wb_stall)
    );

    bool stall_flop;
    `REG_RST(u_stall_flop, 1, clk, rst, wb_outs_i.wb_stall, stall_flop)


    //==========================================================================
    // CONTROL SIGNAL FLATTENING (struct → flat wires)
    //==========================================================================
    wire [5:0] op_type_w;
    wire [3:0] data_size_w;
    wire [3:0] sr_data_size_vec_w;
    wire [4:0] alu_inputA_sel_w;
    wire [4:0] alu_inputB_sel_w;
    wire [4:0] br_input_sel_w;

    assign op_type_w          = latches_i.cs.OP_TYPE[5:0];
    assign data_size_w        = latches_i.data_size_vec;
    assign sr_data_size_vec_w = latches_i.sr_data_size_vec;
    assign alu_inputA_sel_w   = latches_i.cs.alu_inputA_sel[4:0];
    assign alu_inputB_sel_w   = latches_i.cs.alu_inputB_sel[4:0];
    assign br_input_sel_w     = latches_i.cs.branch_target_sel[4:0];

    wire WB_DR_w;
    wire WB_SR_w;
    wire WB_EAX_w;
    assign WB_DR_w  = latches_i.wb_cs.WB_DR;
    assign WB_SR_w  = latches_i.wb_cs.WB_SR;
    assign WB_EAX_w = latches_i.wb_cs.WB_EAX;


    //==========================================================================
    // REGFILE-VALUE FORWARDING MUX  (structural — replaces inline array index)
    //==========================================================================
    // dr_data/sr_data come from rr_outs_i.regFileValues indexed by latches_i.dr_id/sr_id.
    // EAX index is constant (=7) so it's a direct wire.
    uint64_t dr_data;
    uint64_t sr_data;
    uint32_t eax_data;

    wire [4:0] dr_id_w;
    wire [4:0] sr_id_w;
    assign dr_id_w = latches_i.dr_id[4:0];
    assign sr_id_w = latches_i.sr_id[4:0];

    `MUX_32(u_mux_dr_data, 64, dr_data,
        rr_outs_i.regFileValues[0],  rr_outs_i.regFileValues[1],
        rr_outs_i.regFileValues[2],  rr_outs_i.regFileValues[3],
        rr_outs_i.regFileValues[4],  rr_outs_i.regFileValues[5],
        rr_outs_i.regFileValues[6],  rr_outs_i.regFileValues[7],
        rr_outs_i.regFileValues[8],  rr_outs_i.regFileValues[9],
        rr_outs_i.regFileValues[10], rr_outs_i.regFileValues[11],
        rr_outs_i.regFileValues[12], rr_outs_i.regFileValues[13],
        rr_outs_i.regFileValues[14], rr_outs_i.regFileValues[15],
        rr_outs_i.regFileValues[16], rr_outs_i.regFileValues[17],
        rr_outs_i.regFileValues[18], rr_outs_i.regFileValues[19],
        rr_outs_i.regFileValues[20], rr_outs_i.regFileValues[21],
        rr_outs_i.regFileValues[22], rr_outs_i.regFileValues[23],
        rr_outs_i.regFileValues[24], rr_outs_i.regFileValues[25],
        64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0,
        dr_id_w)

    `MUX_32(u_mux_sr_data, 64, sr_data,
        rr_outs_i.regFileValues[0],  rr_outs_i.regFileValues[1],
        rr_outs_i.regFileValues[2],  rr_outs_i.regFileValues[3],
        rr_outs_i.regFileValues[4],  rr_outs_i.regFileValues[5],
        rr_outs_i.regFileValues[6],  rr_outs_i.regFileValues[7],
        rr_outs_i.regFileValues[8],  rr_outs_i.regFileValues[9],
        rr_outs_i.regFileValues[10], rr_outs_i.regFileValues[11],
        rr_outs_i.regFileValues[12], rr_outs_i.regFileValues[13],
        rr_outs_i.regFileValues[14], rr_outs_i.regFileValues[15],
        rr_outs_i.regFileValues[16], rr_outs_i.regFileValues[17],
        rr_outs_i.regFileValues[18], rr_outs_i.regFileValues[19],
        rr_outs_i.regFileValues[20], rr_outs_i.regFileValues[21],
        rr_outs_i.regFileValues[22], rr_outs_i.regFileValues[23],
        rr_outs_i.regFileValues[24], rr_outs_i.regFileValues[25],
        64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0,
        sr_id_w)

    assign eax_data = rr_outs_i.regFileValues[EAX][31:0];


    //==========================================================================
    // ALU INPUT SELECTION  (latches_i.ld_buf 32-byte array → 256-bit packed)
    //==========================================================================
    wire [255:0] ld_buf_packed;
    genvar gi_ld;
    generate
        for (gi_ld = 0; gi_ld < EXE_BUFFER_SIZE; gi_ld = gi_ld + 1) begin : g_ld_pack
            assign ld_buf_packed[gi_ld*8 +: 8] = latches_i.ld_buf[gi_ld];
        end
    endgenerate

    uint64_t srA;
    uint64_t srB;
    uint32_t br_sel;
    uint64_t exp_ld_buf_o;

    alu_input_sel u_alu_input_sel (
        .ld_addr_0      (latches_i.ld_addy),
        .res_buf_in     (ld_buf_packed),
        .imm64          (latches_i.imm64),
        .sr_data        (sr_data),
        .dr_data        (dr_data),
        .EAX            (eax_data),
        .NEIP           (latches_i.NEIP),
        .EIP            (latches_i.EIP),
        .flags          (flags_reg),
        .alu_inputA_sel (alu_inputA_sel_w),
        .alu_inputB_sel (alu_inputB_sel_w),
        .shift_sr_down  (latches_i.shift_sr_down),
        .shift_sr_up    (latches_i.shift_sr_up),
        .br_input_sel   (br_input_sel_w),
        .exp_ld_buf_o   (exp_ld_buf_o),
        .srA_64         (srA),
        .srB_64         (srB),
        .br_sel         (br_sel)
    );


    //==========================================================================
    // FUNCTIONAL UNIT OUTPUT WIRES  (data + flags)
    //==========================================================================
    uint64_t aaa_dr_o;
    uint64_t adc_dr_o, adc_res_buf_o;
    uint64_t add_dr_o, add_res_buf_o;
    uint64_t add_df_dr_o, add_df_sr_o;
    uint64_t and_dr_o, and_res_buf_o;
    uint64_t bsf_dr_o, bsf_res_buf_o;
    uint64_t call_sr_o, call_res_buf;
    uint64_t cmpxchg_EAX_o, cmpxchg_dr_o, cmpxchg_buf_o;
    uint64_t far_call_sr_o, far_call_res_buf, far_call_dr_o;
    uint64_t exp_call_sr_o, exp_call_res_buf, exp_call_dr_o;
    uint32_t exp_call_eip;
    uint64_t iretd_cs_o, iretd_stack_ptr_o;
    uint64_t mov_dr_o, mov_res_buf_o;
    uint64_t mov_s_dr_o, mov_s_sr_o, mov_s_res_buf_o;
    uint64_t not_dr_o, not_res_buf_o;
    uint64_t or_dr_o, or_res_buf_o;
    uint64_t packssdw_dr_o, packsswb_dr_o;
    uint64_t paddd_dr_o, paddw_dr_o;
    uint64_t pavgb_dr_o, pavgw_dr_o;
    uint64_t pop_dr_o, pop_sr_o, pop_res_buf;
    uint64_t push_res_buf, push_sr_o;
    uint64_t ret_far_imm_dr_o, ret_far_imm_sr_o;
    uint64_t ret_far_cs_o, ret_far_next_ptr_o;
    uint64_t ret_imm_sr_o, ret_sr_o;
    uint64_t sal_dr_o, sal_res_buf_o;
    uint64_t sar_dr_o, sar_res_buf_o;
    uint64_t sbb_dr_o, sbb_res_buf_o;
    uint64_t xchg_dr_o, xchg_sr_o, xchg_res_buf;
    uint64_t far_jmp_dr_o;

    logic aaa_af_o, aaa_cf_o;
    logic adc_af_o, adc_cf_o, adc_of_o, adc_pf_o, adc_sf_o, adc_zf_o;
    logic add_af_o, add_cf_o, add_of_o, add_pf_o, add_sf_o, add_zf_o;
    logic and_of_o, and_pf_o, and_sf_o, and_zf_o, and_cf_o, and_af_o;
    logic bsf_zf_o;
    logic cmp_cf_o, cmp_pf_o, cmp_af_o, cmp_zf_o, cmp_sf_o, cmp_of_o;
    logic cmpxchg_cf_o, cmpxchg_pf_o, cmpxchg_af_o, cmpxchg_zf_o, cmpxchg_sf_o, cmpxchg_of_o;
    logic or_cf_o, or_pf_o, or_zf_o, or_sf_o, or_of_o, or_af_o;
    logic sal_cf_o, sal_pf_o, sal_zf_o, sal_sf_o, sal_of_o, sal_af_o;
    logic sar_cf_o, sar_pf_o, sar_zf_o, sar_sf_o, sar_of_o, sar_af_o;
    logic sbb_cf_o, sbb_pf_o, sbb_af_o, sbb_zf_o, sbb_sf_o, sbb_of_o;
    logic iretd_cf_o, iretd_pf_o, iretd_af_o, iretd_zf_o, iretd_sf_o, iretd_of_o;
    logic rep_cmp_zf_o;


    //==========================================================================
    // RESULT-BUFFER SELECT + LOGIC + BIT-VECTOR
    //==========================================================================
    uint64_t res_buf_selected;
    res_buf_sel u_res_buf_sel (
        .op_type            (op_type_w),
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

    wire [255:0] res_buf_packed;
    res_buf_logic u_res_buf_logic (
        .res_info_i (res_buf_selected),
        .st_addr_0  (latches_i.ST_PADDR_0),
        .res_buf    (res_buf_packed)
    );

    // Unpack 256-bit res_buf_packed back into the byte-array field of wb_latches_next_o.
    genvar gi_rb;
    generate
        for (gi_rb = 0; gi_rb < CACHE_LINES_SIZE_B*2; gi_rb = gi_rb + 1) begin : g_rb_unpack
            assign wb_latches_next_o.res_buf[gi_rb] = res_buf_packed[gi_rb*8 +: 8];
        end
    endgenerate

    uint16_t bit_vec_0_next;
    uint16_t bit_vec_1_next;
    bit_vec_logic u_bit_vec_logic (
        .st_addr_0 (latches_i.ST_PADDR_0),
        .ST_XCL    (latches_i.ST_XCL),
        .data_size (data_size_w),
        .st_vec0   (bit_vec_0_next),
        .st_vec1   (bit_vec_1_next)
    );


    //==========================================================================
    // DR / SR SELECT
    //==========================================================================
    uint64_t dr_next;
    dr_sel u_dr_sel (
        .op_type          (op_type_w),
        .WB_DR            (WB_DR_w),
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
        .dr_data          (dr_data),
        .dr_o             (dr_next)
    );

    uint64_t sr_next;
    sr_sel u_sr_sel (
        .op_type          (op_type_w),
        .WB_SR            (WB_SR_w),
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
    reg_ids_e dr0_id_o, dr1_id_o;
    bool dr0_we_o, dr1_we_o;
    uint64_t dr0_data_o, dr1_data_o;

    uint64_t next_EAX;
    assign next_EAX = WB_EAX_w ? cmpxchg_EAX_o : {32'd0, eax_data};

    reg_wb_logic u_reg_wb (
        .op_type      (op_type_w),
        .next_dr_data (dr_next),
        .dr_id        (latches_i.dr_id[4:0]),
        .WB_DR        (WB_DR_w),
        .next_EAX     (next_EAX),
        .next_sr_data (sr_next),
        .sr_id        (latches_i.sr_id[4:0]),
        .WB_EAX       (WB_EAX_w),
        .WB_SR        (WB_SR_w),
        .valid        (latches_i.valid),
        .stall_flop   (stall_flop),
        .dr0_id_o     (dr0_id_o),
        .dr0_we_o     (dr0_we_o),
        .dr0_data_o   (dr0_data_o),
        .dr1_id_o     (dr1_id_o),
        .dr1_we_o     (dr1_we_o),
        .dr1_data_o   (dr1_data_o)
    );


    //==========================================================================
    // BRANCH RESOLUTION  (flat outputs reassembled into struct)
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
        .stage_valid_i        (latches_i.valid),
        .br_info_valid_i      (latches_i.br_info.valid),
        .flush_mask           (stall_flop),
        .br_eip_i             (latches_i.br_info.br_eip),
        .br_xcl_i             (latches_i.br_info.br_xcl),
        .br_pred_taken_i      (latches_i.br_info.br_pred_taken),
        .speculative_target_i (latches_i.br_info.speculative_target),
        .br_ucond_i           (latches_i.cs.br_ucond),
        .relative_branch_i    (latches_i.cs.relative_branch),
        .special_br_i         (latches_i.cs.special_br),
        .is_far_i             (latches_i.cs.is_far),
        .is_call_i            (latches_i.cs.is_call),
        .second_flag_needed_i (latches_i.cs.second_flag_needed),
        .br_source_i          (br_sel),
        .NEIP_i               (latches_i.NEIP),
        .br_rel_target        (latches_i.br_rel_target),
        .exp_target           (exp_call_eip),
        .CF                   (flags_reg[CF_IDX]),
        .ZF                   (flags_reg[ZF_IDX]),
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
    // FLAGS REGISTER  (structural REG_RST_WE 32-bit, gated by latches_i.valid)
    //==========================================================================
    uint32_t flags_reg;

    logic af_flag_o;
    logic cf_flag_o;
    logic df_flag_o;
    logic of_flag_o;
    logic pf_flag_o;
    logic sf_flag_o;
    logic zf_flag_o;
    bool  clr_ZF_sb;

    // flags_din: pack the 7 flag bits at their flags_idx_e positions,
    // all unused bits tied to 0 so they stay 0 forever (post-reset).
    wire [31:0] flags_din;
    assign flags_din = {20'b0,            // bits 31..12
                        of_flag_o,        // bit 11 = OF_IDX
                        df_flag_o,        // bit 10 = DF_IDX
                        1'b0, 1'b0,       // bits 9, 8
                        sf_flag_o,        // bit 7 = SF_IDX
                        zf_flag_o,        // bit 6 = ZF_IDX
                        1'b0,             // bit 5
                        af_flag_o,        // bit 4 = AF_IDX
                        1'b0,             // bit 3
                        pf_flag_o,        // bit 2 = PF_IDX
                        1'b0,             // bit 1
                        cf_flag_o};       // bit 0 = CF_IDX

    `REG_RST_WE(u_flags_reg, 32, clk, rst, latches_i.valid, flags_din, flags_reg)


    //==========================================================================
    // FLAG SELECTORS  (structural)
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
        .curr_af_flag (flags_reg[AF_IDX]),
        .op_type      (op_type_w),
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
        .curr_cf_flag (flags_reg[CF_IDX]),
        .op_type      (op_type_w),
        .cf_flag_o    (cf_flag_o)
    );

    df_flag_sel u_df_flag_sel (
        .curr_df_flag (flags_reg[DF_IDX]),
        .op_type      (op_type_w),
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
        .op_type      (op_type_w),
        .curr_of_flag (flags_reg[OF_IDX]),
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
        .op_type      (op_type_w),
        .curr_pf_flag (flags_reg[PF_IDX]),
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
        .op_type      (op_type_w),
        .curr_sf_flag (flags_reg[SF_IDX]),
        .sf_flag_o    (sf_flag_o)
    );

    zf_flag_sel u_zf_flag_sel (
        .rep_no_zf_update (latches_i.cs.rep_no_zf_update),
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
        .curr_zf_flag     (flags_reg[ZF_IDX]),
        .op_type          (op_type_w),
        .zf_flag_o        (zf_flag_o),
        .clr_ZF_sb        (clr_ZF_sb)
    );


    //==========================================================================
    // NEXT-LATCH ASSIGNMENTS  (per-field; struct literal split)
    //==========================================================================
    assign wb_latches_next_o.valid        = wb_stage_next_vaild_o;
    assign wb_latches_next_o.cs           = latches_i.wb_cs;
    assign wb_latches_next_o.ST_XCL       = latches_i.ST_XCL;
    assign wb_latches_next_o.ST_PADDR_0   = latches_i.ST_PADDR_0;
    assign wb_latches_next_o.ST_BIT_VEC_0 = bit_vec_0_next;
    assign wb_latches_next_o.ST_PADDR_1   = latches_i.ST_PADDR_1;
    assign wb_latches_next_o.ST_BIT_VEC_1 = bit_vec_1_next;
    assign wb_latches_next_o.MIO          = latches_i.MIO;
    assign wb_latches_next_o.EIP          = latches_i.EIP;
    assign wb_latches_next_o.sr_id        = latches_i.sr_id;
    assign wb_latches_next_o.sr_data      = sr_next;
    assign wb_latches_next_o.dr_id        = latches_i.dr_id;
    assign wb_latches_next_o.dr_data      = dr_next;
    assign wb_latches_next_o.EAX          = WB_EAX_w ? cmpxchg_EAX_o : eax_data;
    // wb_latches_next_o.res_buf is assigned by the generate loop above.

    // outs_o assembly (per-field).
    assign outs_o.valid                       = latches_i.valid;
    assign outs_o.br_res_out.valid            = br_outs_valid_w;
    assign outs_o.br_res_out.flush            = br_outs_flush_w;
    assign outs_o.br_res_out.farFlush         = br_outs_farFlush_w;
    assign outs_o.br_res_out.callFlush        = br_outs_callFlush_w;
    assign outs_o.br_res_out.miss_prediction  = br_outs_miss_prediction_w;
    assign outs_o.br_res_out.br_eip           = br_outs_br_eip_w;
    assign outs_o.br_res_out.neip             = br_outs_neip_w;
    assign outs_o.br_res_out.br_target        = br_outs_br_target_w;
    assign outs_o.br_res_out.taken            = br_outs_taken_w;
    assign outs_o.br_res_out.br_XCL           = br_outs_br_XCL_w;
    assign outs_o.br_res_out.clr_exp_mode     = br_outs_clr_exp_mode_w;
    assign outs_o.br_res_out.br_ucond         = br_outs_br_ucond_w;
    assign outs_o.DR_0_we                     = dr0_we_o;
    assign outs_o.DR_0_id                     = dr0_id_o;
    assign outs_o.DR_0_data                   = dr0_data_o;
    assign outs_o.DR_1_we                     = dr1_we_o;
    assign outs_o.DR_1_id                     = dr1_id_o;
    assign outs_o.DR_1_data                   = dr1_data_o;
    assign outs_o.ZF                          = flags_reg[ZF_IDX];
    assign outs_o.clr_ZF_sb                   = clr_ZF_sb && latches_i.valid;
    assign outs_o.ST_OP                       = latches_i.cs.ST_OP;
    assign outs_o.ST_XCL                      = latches_i.ST_XCL;
    assign outs_o.ST_PADDR_0                  = latches_i.ST_PADDR_0;
    assign outs_o.ST_PADDR_1                  = latches_i.ST_PADDR_1;
    assign outs_o.wb_stage_latch_we           = wb_stage_we_valid_unit_o;


    //==========================================================================
    // FUNCTIONAL UNITS  (still SystemVerilog behavioral — to be ported in step 2)
    //==========================================================================

    aaa_op u_aaa (
        .EAX_in    (srA),
        .AF_flag_in(flags_reg[AF_IDX]),
        .dr_o      (aaa_dr_o),
        .CF        (aaa_cf_o),
        .AF        (aaa_af_o)
    );

    adc_op u_adc_op (
        .srA(srA), .srB(srB),
        .CF_in(flags_reg[CF_IDX]),
        .data_size(data_size_w),
        .dr_o(adc_dr_o), .res_buf_o(adc_res_buf_o),
        .CF(adc_cf_o), .PF(adc_pf_o), .AF(adc_af_o),
        .ZF(adc_zf_o), .SF(adc_sf_o), .OF(adc_of_o)
    );

    add_op u_add_op (
        .srA(srA), .srB(srB), .data_size(data_size_w),
        .dr_o(add_dr_o), .res_buf_o(add_res_buf_o),
        .ZF(add_zf_o), .SF(add_sf_o), .PF(add_pf_o),
        .OF(add_of_o), .CF(add_cf_o), .AF(add_af_o)
    );

    rep_cmp u_rep_cmp_op (
        .srA(srA), .srB(srB), .data_size(data_size_w),
        .ZF(rep_cmp_zf_o)
    );

    add_df_op u_add_df_op (
        .srA(srA), .srB(srB),
        .curr_df_flag(flags_reg[DF_IDX]),
        .data_size(data_size_w),
        .dr_o(add_df_dr_o), .sr_o(add_df_sr_o)
    );

    and_op u_and_op (
        .srA(srA), .srB(srB), .data_size(data_size_w),
        .dr_o(and_dr_o), .res_buf_o(and_res_buf_o),
        .ZF(and_zf_o), .SF(and_sf_o), .PF(and_pf_o),
        .OF(and_of_o), .CF(and_cf_o), .AF(and_af_o)
    );

    bsf_op u_bsf (
        .srA(srB), .data_size(data_size_w),
        .dr_o(bsf_dr_o), .res_buf_o(bsf_res_buf_o),
        .ZF(bsf_zf_o)
    );

    cmp u_cmp (
        .srA(srA), .srB(srB), .data_size(data_size_w),
        .CF(cmp_cf_o), .OF(cmp_of_o), .SF(cmp_sf_o),
        .ZF(cmp_zf_o), .AF(cmp_af_o), .PF(cmp_pf_o)
    );

    cmpxchg_op u_cmpxchg_op (
        .EAX(srB[31:0]), .rm(srA), .r(srB[63:32]),
        .data_size(data_size_w), .sr_data_size_vec(sr_data_size_vec_w),
        .dr_o(cmpxchg_dr_o), .EAX_o(cmpxchg_EAX_o), .res_buf(cmpxchg_buf_o),
        .ZF(cmpxchg_zf_o), .SF(cmpxchg_sf_o), .PF(cmpxchg_pf_o),
        .CF(cmpxchg_cf_o), .OF(cmpxchg_of_o), .AF(cmpxchg_af_o)
    );

    not_op u_not_op (
        .srA(srA), .data_size(data_size_w),
        .dr_o(not_dr_o), .res_buf_o(not_res_buf_o)
    );

    or_op u_or_op (
        .srA(srA), .srB(srB), .data_size(data_size_w),
        .dr_o(or_dr_o), .res_buf_o(or_res_buf_o),
        .ZF(or_zf_o), .SF(or_sf_o), .PF(or_pf_o),
        .OF(or_of_o), .CF(or_cf_o), .AF(or_af_o)
    );

    sal_op u_sal_op (
        .value_i(srA), .shift_amt_i(srB),
        .data_size(data_size_w), .sr_data_size_vec(sr_data_size_vec_w),
        .shift_by_one(latches_i.cs.shift_by_one),
        .curr_zf_flag(flags_reg[ZF_IDX]), .curr_sf_flag(flags_reg[SF_IDX]),
        .curr_pf_flag(flags_reg[PF_IDX]), .curr_of_flag(flags_reg[OF_IDX]),
        .curr_cf_flag(flags_reg[CF_IDX]), .curr_af_flag(flags_reg[AF_IDX]),
        .dr_o(sal_dr_o), .res_buf_o(sal_res_buf_o),
        .ZF(sal_zf_o), .SF(sal_sf_o), .PF(sal_pf_o),
        .OF(sal_of_o), .AF(sal_af_o), .CF(sal_cf_o)
    );

    sar_op u_sar_op (
        .value_i(srA), .shift_amt_i(srB),
        .data_size(data_size_w), .shift_by_one(latches_i.cs.shift_by_one),
        .sr_data_size_vec(sr_data_size_vec_w),
        .curr_zf_flag(flags_reg[ZF_IDX]), .curr_sf_flag(flags_reg[SF_IDX]),
        .curr_pf_flag(flags_reg[PF_IDX]), .curr_of_flag(flags_reg[OF_IDX]),
        .curr_cf_flag(flags_reg[CF_IDX]), .curr_af_flag(flags_reg[AF_IDX]),
        .dr_o(sar_dr_o), .res_buf_o(sar_res_buf_o),
        .ZF(sar_zf_o), .SF(sar_sf_o), .PF(sar_pf_o),
        .OF(sar_of_o), .CF(sar_cf_o), .AF(sar_af_o)
    );

    sbb_op u_sbb_op (
        .srA(srA), .srB(srB),
        .CF_in(flags_reg[CF_IDX]),
        .data_size(data_size_w),
        .dr_o(sbb_dr_o), .res_buf_o(sbb_res_buf_o),
        .CF(sbb_cf_o), .PF(sbb_pf_o), .AF(sbb_af_o),
        .ZF(sbb_zf_o), .SF(sbb_sf_o), .OF(sbb_of_o)
    );

    mov_op u_mov_op (
        .srA(srA), .srB(srB), .data_size(data_size_w),
        .op_type(latches_i.cs.OP_TYPE),
        .curr_cf_flag(flags_reg[CF_IDX]),
        .res_buf_o(mov_res_buf_o), .dr_o(mov_dr_o)
    );

    movs_op u_movs_op (
        .srA(srA), .srB(srB), .data_size(data_size_w),
        .curr_df_flag(flags_reg[DF_IDX]),
        .res_buf_o(mov_s_res_buf_o), .dr_o(mov_s_dr_o), .sr_o(mov_s_sr_o)
    );

    xchg_op u_xchg_op (
        .srA(srA), .srB(srB), .data_size(data_size_w),
        .sr_data_size_vec(sr_data_size_vec_w),
        .res_buf(xchg_res_buf), .dr_o(xchg_dr_o), .sr_o(xchg_sr_o)
    );

    call_op u_call_op (
        .NEIP(srA), .stack_ptr(srB),
        .sr_o(call_sr_o), .res_buf(call_res_buf)
    );

    far_call_op u_far_op (
        .neip(srA[31:0]), .segment(srA[63:32]),
        .stack_ptr(srB), .new_cs({16'd0, latches_i.imm64[47:32]}),
        .res_buf(far_call_res_buf), .sr_o(far_call_sr_o), .dr_o(far_call_dr_o)
    );

    exp_call_op u_exp_call_op (
        .idt(exp_ld_buf_o), .eip(srA[63:32]),
        .curr_cs(rr_outs_i.codeSeg_data), .stack_ptr(srB),
        .res_buf(exp_call_res_buf), .dr_o(exp_call_dr_o),
        .sr_o(exp_call_sr_o), .exp_eip(exp_call_eip)
    );

    far_jmp_op u_far_jmp_op (
        .op_type(latches_i.cs.OP_TYPE), .srA(srA), .dr_o(far_jmp_dr_o)
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
        .cs(srA[63:32]), .stack_ptr(srB), .imm64(latches_i.imm64),
        .dr_o(ret_far_imm_dr_o), .sr_o(ret_far_imm_sr_o)
    );

    pop_op u_pop_op (
        .value_i(srA), .sp_i(srB),
        .dr_o(pop_dr_o), .sr_o(pop_sr_o), .res_buf(pop_res_buf)
    );

    push_op u_push_op (
        .value(srA), .sp(srB), .data_size_vec(data_size_w),
        .res_buf(push_res_buf), .sr_o(push_sr_o)
    );

    packssdw u_packssdw (.srA(srA), .srB(srB), .dr_o(packssdw_dr_o));
    packsswb u_packsswb (.srA(srA), .srB(srB), .dr_o(packsswb_dr_o));
    paddd    u_paddd    (.srA(srA), .srB(srB), .dr_o(paddd_dr_o));
    paddw    u_paddw    (.srA(srA), .srB(srB), .dr_o(paddw_dr_o));
    pavgb    u_pavgb    (.srA(srA), .srB(srB), .dr_o(pavgb_dr_o));
    pavgw    u_pavgw    (.srA(srA), .srB(srB), .dr_o(pavgw_dr_o));

endmodule
