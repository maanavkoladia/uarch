`define DECODE_OUTPUTS


    // ---- decode_outputs_t : Decode.outs_* (driven by Decode) ----
    wire        decode_outputs_valid;
    wire        decode_outputs_stall;
    wire [31:0] decode_outputs_eip;
    wire        decode_outputs_invalid_instruction;
    wire        decode_outputs_decode_gp;
    wire        decode_outputs_rr_stage_latch_we;
    wire        decode_outputs_rep_latch;
    wire        decode_outputs_decode_forward;


    // ====================================================================
    // rr_latches_next : driven by Decode, consumed by RR_Latches
    //   rr_latches_t = { normal_latches : rr_latches_general_t,
    //                    rep_latches    : rr_latches_general_t }
    // ====================================================================

    // ---- rr_latches_next.normal_latches : rr_latches_general_t ----
    wire        rr_latches_next_normal_latches_valid;

    // rr_cs_t (cs)
    wire        rr_latches_next_normal_latches_cs_ST_SEL;
    wire        rr_latches_next_normal_latches_cs_MODRM_NEEDED;
    wire        rr_latches_next_normal_latches_cs_RM_IS_DR;
    wire        rr_latches_next_normal_latches_cs_SWITCH_LD_ADDY;
    wire        rr_latches_next_normal_latches_cs_LD_OP;
    wire        rr_latches_next_normal_latches_cs_ST_OP;
    wire [4:0]  rr_latches_next_normal_latches_cs_dr_id;
    wire [4:0]  rr_latches_next_normal_latches_cs_sr_id;
    wire        rr_latches_next_normal_latches_cs_dr_rd;
    wire        rr_latches_next_normal_latches_cs_sr_rd;
    wire        rr_latches_next_normal_latches_cs_eax_rd;
    wire        rr_latches_next_normal_latches_cs_dr_wr;
    wire        rr_latches_next_normal_latches_cs_sr_wr;
    wire        rr_latches_next_normal_latches_cs_eax_wr;
    wire        rr_latches_next_normal_latches_cs_MOVS_OP;
    wire [1:0]  rr_latches_next_normal_latches_cs_datasize;
    wire        rr_latches_next_normal_latches_cs_will_mod_zf;
    wire        rr_latches_next_normal_latches_cs_seg_1_valid;
    wire [4:0]  rr_latches_next_normal_latches_cs_seg_0_id;
    wire [4:0]  rr_latches_next_normal_latches_cs_seg_1_id;
    wire        rr_latches_next_normal_latches_cs_special_modrm_bs;
    wire        rr_latches_next_normal_latches_cs_special_br;

    // dc_cs_t (dc_cs)
    wire        rr_latches_next_normal_latches_dc_cs_LD_OP;
    wire        rr_latches_next_normal_latches_dc_cs_ST_OP;
    wire        rr_latches_next_normal_latches_dc_cs_dr_upper8;
    wire        rr_latches_next_normal_latches_dc_cs_sr_upper8;
    wire [1:0]  rr_latches_next_normal_latches_dc_cs_datasize;

    // mem_cs_t (mem_cs)
    wire        rr_latches_next_normal_latches_mem_cs_ST_OP;
    wire        rr_latches_next_normal_latches_mem_cs_LD_OP;

    // exe_cs_t (exe_cs)
    wire        rr_latches_next_normal_latches_exe_cs_ST_OP;
    wire [31:0] rr_latches_next_normal_latches_exe_cs_OP_TYPE;
    wire [31:0] rr_latches_next_normal_latches_exe_cs_alu_inputA_sel;
    wire [31:0] rr_latches_next_normal_latches_exe_cs_alu_inputB_sel;
    wire [31:0] rr_latches_next_normal_latches_exe_cs_branch_target_sel;
    wire        rr_latches_next_normal_latches_exe_cs_shift_by_one;
    wire        rr_latches_next_normal_latches_exe_cs_br_ucond;
    wire        rr_latches_next_normal_latches_exe_cs_relative_branch;
    wire        rr_latches_next_normal_latches_exe_cs_special_br;
    wire        rr_latches_next_normal_latches_exe_cs_is_far;
    wire        rr_latches_next_normal_latches_exe_cs_is_call;
    wire        rr_latches_next_normal_latches_exe_cs_second_flag_needed;
    wire        rr_latches_next_normal_latches_exe_cs_rep_no_zf_update;

    // wb_cs_t (wb_cs)
    wire        rr_latches_next_normal_latches_wb_cs_ST_OP;
    wire        rr_latches_next_normal_latches_wb_cs_WB_DR;
    wire        rr_latches_next_normal_latches_wb_cs_WB_SR;
    wire        rr_latches_next_normal_latches_wb_cs_WB_EAX;

    // br_info_t (br_info)
    wire        rr_latches_next_normal_latches_br_info_valid;
    wire [31:0] rr_latches_next_normal_latches_br_info_br_eip;
    wire        rr_latches_next_normal_latches_br_info_br_xcl;
    wire        rr_latches_next_normal_latches_br_info_br_pred_taken;
    wire [31:0] rr_latches_next_normal_latches_br_info_speculative_target;

    // pipeline data
    wire [31:0] rr_latches_next_normal_latches_NEIP;
    wire [31:0] rr_latches_next_normal_latches_EIP;
    wire [31:0] rr_latches_next_normal_latches_EAX;
    wire [63:0] rr_latches_next_normal_latches_imm64;

    // SIB / displacement
    wire [4:0]  rr_latches_next_normal_latches_sib_idx_id;
    wire [4:0]  rr_latches_next_normal_latches_sib_base_id;
    wire        rr_latches_next_normal_latches_sib_needed;
    wire [7:0]  rr_latches_next_normal_latches_sib_scale;
    wire        rr_latches_next_normal_latches_disp_needed;
    wire        rr_latches_next_normal_latches_disp_size;
    wire [31:0] rr_latches_next_normal_latches_displacement;


    // ---- rr_latches_next.rep_latches : rr_latches_general_t ----
    wire        rr_latches_next_rep_latches_valid;

    // rr_cs_t (cs)
    wire        rr_latches_next_rep_latches_cs_ST_SEL;
    wire        rr_latches_next_rep_latches_cs_MODRM_NEEDED;
    wire        rr_latches_next_rep_latches_cs_RM_IS_DR;
    wire        rr_latches_next_rep_latches_cs_SWITCH_LD_ADDY;
    wire        rr_latches_next_rep_latches_cs_LD_OP;
    wire        rr_latches_next_rep_latches_cs_ST_OP;
    wire [4:0]  rr_latches_next_rep_latches_cs_dr_id;
    wire [4:0]  rr_latches_next_rep_latches_cs_sr_id;
    wire        rr_latches_next_rep_latches_cs_dr_rd;
    wire        rr_latches_next_rep_latches_cs_sr_rd;
    wire        rr_latches_next_rep_latches_cs_eax_rd;
    wire        rr_latches_next_rep_latches_cs_dr_wr;
    wire        rr_latches_next_rep_latches_cs_sr_wr;
    wire        rr_latches_next_rep_latches_cs_eax_wr;
    wire        rr_latches_next_rep_latches_cs_MOVS_OP;
    wire [1:0]  rr_latches_next_rep_latches_cs_datasize;
    wire        rr_latches_next_rep_latches_cs_will_mod_zf;
    wire        rr_latches_next_rep_latches_cs_seg_1_valid;
    wire [4:0]  rr_latches_next_rep_latches_cs_seg_0_id;
    wire [4:0]  rr_latches_next_rep_latches_cs_seg_1_id;
    wire        rr_latches_next_rep_latches_cs_special_modrm_bs;
    wire        rr_latches_next_rep_latches_cs_special_br;

    // dc_cs_t (dc_cs)
    wire        rr_latches_next_rep_latches_dc_cs_LD_OP;
    wire        rr_latches_next_rep_latches_dc_cs_ST_OP;
    wire        rr_latches_next_rep_latches_dc_cs_dr_upper8;
    wire        rr_latches_next_rep_latches_dc_cs_sr_upper8;
    wire [1:0]  rr_latches_next_rep_latches_dc_cs_datasize;

    // mem_cs_t (mem_cs)
    wire        rr_latches_next_rep_latches_mem_cs_ST_OP;
    wire        rr_latches_next_rep_latches_mem_cs_LD_OP;

    // exe_cs_t (exe_cs)
    wire        rr_latches_next_rep_latches_exe_cs_ST_OP;
    wire [31:0] rr_latches_next_rep_latches_exe_cs_OP_TYPE;
    wire [31:0] rr_latches_next_rep_latches_exe_cs_alu_inputA_sel;
    wire [31:0] rr_latches_next_rep_latches_exe_cs_alu_inputB_sel;
    wire [31:0] rr_latches_next_rep_latches_exe_cs_branch_target_sel;
    wire        rr_latches_next_rep_latches_exe_cs_shift_by_one;
    wire        rr_latches_next_rep_latches_exe_cs_br_ucond;
    wire        rr_latches_next_rep_latches_exe_cs_relative_branch;
    wire        rr_latches_next_rep_latches_exe_cs_special_br;
    wire        rr_latches_next_rep_latches_exe_cs_is_far;
    wire        rr_latches_next_rep_latches_exe_cs_is_call;
    wire        rr_latches_next_rep_latches_exe_cs_second_flag_needed;
    wire        rr_latches_next_rep_latches_exe_cs_rep_no_zf_update;

    // wb_cs_t (wb_cs)
    wire        rr_latches_next_rep_latches_wb_cs_ST_OP;
    wire        rr_latches_next_rep_latches_wb_cs_WB_DR;
    wire        rr_latches_next_rep_latches_wb_cs_WB_SR;
    wire        rr_latches_next_rep_latches_wb_cs_WB_EAX;

    // br_info_t (br_info)
    wire        rr_latches_next_rep_latches_br_info_valid;
    wire [31:0] rr_latches_next_rep_latches_br_info_br_eip;
    wire        rr_latches_next_rep_latches_br_info_br_xcl;
    wire        rr_latches_next_rep_latches_br_info_br_pred_taken;
    wire [31:0] rr_latches_next_rep_latches_br_info_speculative_target;

    // pipeline data
    wire [31:0] rr_latches_next_rep_latches_NEIP;
    wire [31:0] rr_latches_next_rep_latches_EIP;
    wire [31:0] rr_latches_next_rep_latches_EAX;
    wire [63:0] rr_latches_next_rep_latches_imm64;

    // SIB / displacement
    wire [4:0]  rr_latches_next_rep_latches_sib_idx_id;
    wire [4:0]  rr_latches_next_rep_latches_sib_base_id;
    wire        rr_latches_next_rep_latches_sib_needed;
    wire [7:0]  rr_latches_next_rep_latches_sib_scale;
    wire        rr_latches_next_rep_latches_disp_needed;
    wire        rr_latches_next_rep_latches_disp_size;
    wire [31:0] rr_latches_next_rep_latches_displacement;
