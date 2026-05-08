`define RR_LATCHES \
    wire        rr_latches_normal_valid; \
    wire        rr_latches_normal_cs_ST_SEL; \
    wire        rr_latches_normal_cs_MODRM_NEEDED; \
    wire        rr_latches_normal_cs_RM_IS_DR; \
    wire        rr_latches_normal_cs_SWITCH_LD_ADDY; \
    wire        rr_latches_normal_cs_LD_OP; \
    wire        rr_latches_normal_cs_ST_OP; \
    wire [4:0]  rr_latches_normal_cs_dr_id; \
    wire [4:0]  rr_latches_normal_cs_sr_id; \
    wire        rr_latches_normal_cs_dr_rd; \
    wire        rr_latches_normal_cs_sr_rd; \
    wire        rr_latches_normal_cs_eax_rd; \
    wire        rr_latches_normal_cs_dr_wr; \
    wire        rr_latches_normal_cs_sr_wr; \
    wire        rr_latches_normal_cs_eax_wr; \
    wire        rr_latches_normal_cs_MOVS_OP; \
    wire [1:0]  rr_latches_normal_cs_datasize; \
    wire        rr_latches_normal_cs_will_mod_zf; \
    wire        rr_latches_normal_cs_seg_1_valid; \
    wire [4:0]  rr_latches_normal_cs_seg_0_id; \
    wire [4:0]  rr_latches_normal_cs_seg_1_id; \
    wire        rr_latches_normal_cs_special_modrm_bs; \
    wire        rr_latches_normal_cs_special_br; \
    wire        rr_latches_normal_dc_cs_LD_OP; \
    wire        rr_latches_normal_dc_cs_ST_OP; \
    wire        rr_latches_normal_dc_cs_dr_upper8; \
    wire        rr_latches_normal_dc_cs_sr_upper8; \
    wire [1:0]  rr_latches_normal_dc_cs_datasize; \
    wire        rr_latches_normal_mem_cs_ST_OP; \
    wire        rr_latches_normal_mem_cs_LD_OP; \
    wire        rr_latches_normal_exe_cs_ST_OP; \
    wire [5:0]  rr_latches_normal_exe_cs_OP_TYPE; \
    wire [4:0]  rr_latches_normal_exe_cs_alu_inputA_sel; \
    wire [4:0]  rr_latches_normal_exe_cs_alu_inputB_sel; \
    wire [4:0]  rr_latches_normal_exe_cs_branch_target_sel; \
    wire        rr_latches_normal_exe_cs_shift_by_one; \
    wire        rr_latches_normal_exe_cs_br_ucond; \
    wire        rr_latches_normal_exe_cs_relative_branch; \
    wire        rr_latches_normal_exe_cs_special_br; \
    wire        rr_latches_normal_exe_cs_is_far; \
    wire        rr_latches_normal_exe_cs_is_call; \
    wire        rr_latches_normal_exe_cs_second_flag_needed; \
    wire        rr_latches_normal_exe_cs_rep_no_zf_update; \
    wire        rr_latches_normal_wb_cs_ST_OP; \
    wire        rr_latches_normal_wb_cs_WB_DR; \
    wire        rr_latches_normal_wb_cs_WB_SR; \
    wire        rr_latches_normal_wb_cs_WB_EAX; \
    wire        rr_latches_normal_br_info_valid; \
    wire [31:0] rr_latches_normal_br_info_br_eip; \
    wire        rr_latches_normal_br_info_br_xcl; \
    wire        rr_latches_normal_br_info_br_pred_taken; \
    wire [31:0] rr_latches_normal_br_info_speculative_target; \
    wire [31:0] rr_latches_normal_NEIP; \
    wire [31:0] rr_latches_normal_EIP; \
    wire [31:0] rr_latches_normal_EAX; \
    wire [63:0] rr_latches_normal_imm64; \
    wire [4:0]  rr_latches_normal_sib_idx_id; \
    wire [4:0]  rr_latches_normal_sib_base_id; \
    wire        rr_latches_normal_sib_needed; \
    wire [7:0]  rr_latches_normal_sib_scale; \
    wire        rr_latches_normal_disp_needed; \
    wire        rr_latches_normal_disp_size; \
    wire [31:0] rr_latches_normal_displacement; \
    wire        rr_latches_rep_valid; \
    wire        rr_latches_rep_cs_ST_SEL; \
    wire        rr_latches_rep_cs_MODRM_NEEDED; \
    wire        rr_latches_rep_cs_RM_IS_DR; \
    wire        rr_latches_rep_cs_SWITCH_LD_ADDY; \
    wire        rr_latches_rep_cs_LD_OP; \
    wire        rr_latches_rep_cs_ST_OP; \
    wire [4:0]  rr_latches_rep_cs_dr_id; \
    wire [4:0]  rr_latches_rep_cs_sr_id; \
    wire        rr_latches_rep_cs_dr_rd; \
    wire        rr_latches_rep_cs_sr_rd; \
    wire        rr_latches_rep_cs_eax_rd; \
    wire        rr_latches_rep_cs_dr_wr; \
    wire        rr_latches_rep_cs_sr_wr; \
    wire        rr_latches_rep_cs_eax_wr; \
    wire        rr_latches_rep_cs_MOVS_OP; \
    wire [1:0]  rr_latches_rep_cs_datasize; \
    wire        rr_latches_rep_cs_will_mod_zf; \
    wire        rr_latches_rep_cs_seg_1_valid; \
    wire [4:0]  rr_latches_rep_cs_seg_0_id; \
    wire [4:0]  rr_latches_rep_cs_seg_1_id; \
    wire        rr_latches_rep_cs_special_modrm_bs; \
    wire        rr_latches_rep_cs_special_br; \
    wire        rr_latches_rep_dc_cs_LD_OP; \
    wire        rr_latches_rep_dc_cs_ST_OP; \
    wire        rr_latches_rep_dc_cs_dr_upper8; \
    wire        rr_latches_rep_dc_cs_sr_upper8; \
    wire [1:0]  rr_latches_rep_dc_cs_datasize; \
    wire        rr_latches_rep_mem_cs_ST_OP; \
    wire        rr_latches_rep_mem_cs_LD_OP; \
    wire        rr_latches_rep_exe_cs_ST_OP; \
    wire [5:0]  rr_latches_rep_exe_cs_OP_TYPE; \
    wire [4:0]  rr_latches_rep_exe_cs_alu_inputA_sel; \
    wire [4:0]  rr_latches_rep_exe_cs_alu_inputB_sel; \
    wire [4:0]  rr_latches_rep_exe_cs_branch_target_sel; \
    wire        rr_latches_rep_exe_cs_shift_by_one; \
    wire        rr_latches_rep_exe_cs_br_ucond; \
    wire        rr_latches_rep_exe_cs_relative_branch; \
    wire        rr_latches_rep_exe_cs_special_br; \
    wire        rr_latches_rep_exe_cs_is_far; \
    wire        rr_latches_rep_exe_cs_is_call; \
    wire        rr_latches_rep_exe_cs_second_flag_needed; \
    wire        rr_latches_rep_exe_cs_rep_no_zf_update; \
    wire        rr_latches_rep_wb_cs_ST_OP; \
    wire        rr_latches_rep_wb_cs_WB_DR; \
    wire        rr_latches_rep_wb_cs_WB_SR; \
    wire        rr_latches_rep_wb_cs_WB_EAX; \
    wire        rr_latches_rep_br_info_valid; \
    wire [31:0] rr_latches_rep_br_info_br_eip; \
    wire        rr_latches_rep_br_info_br_xcl; \
    wire        rr_latches_rep_br_info_br_pred_taken; \
    wire [31:0] rr_latches_rep_br_info_speculative_target; \
    wire [31:0] rr_latches_rep_NEIP; \
    wire [31:0] rr_latches_rep_EIP; \
    wire [31:0] rr_latches_rep_EAX; \
    wire [63:0] rr_latches_rep_imm64; \
    wire [4:0]  rr_latches_rep_sib_idx_id; \
    wire [4:0]  rr_latches_rep_sib_base_id; \
    wire        rr_latches_rep_sib_needed; \
    wire [7:0]  rr_latches_rep_sib_scale; \
    wire        rr_latches_rep_disp_needed; \
    wire        rr_latches_rep_disp_size; \
    wire [31:0] rr_latches_rep_displacement; \
    RR_Latches rr_latches_unit ( \
        .clk(clk), \
        .rst(rst), \
        .write_enable_i (decode_outputs_rr_stage_latch_we), \
        .flush          (exe_outputs_br_res_flush_rr), \
        .farFlush       (exe_outputs_br_res_farFlush), \
        .exp_pipe_clear (fetch_outputs_exp_pipe_clear), \
        .nextLatches_normal_valid_i                (rr_latches_next_normal_latches_valid), \
        .nextLatches_normal_cs_ST_SEL_i            (rr_latches_next_normal_latches_cs_ST_SEL), \
        .nextLatches_normal_cs_MODRM_NEEDED_i      (rr_latches_next_normal_latches_cs_MODRM_NEEDED), \
        .nextLatches_normal_cs_RM_IS_DR_i          (rr_latches_next_normal_latches_cs_RM_IS_DR), \
        .nextLatches_normal_cs_SWITCH_LD_ADDY_i    (rr_latches_next_normal_latches_cs_SWITCH_LD_ADDY), \
        .nextLatches_normal_cs_LD_OP_i             (rr_latches_next_normal_latches_cs_LD_OP), \
        .nextLatches_normal_cs_ST_OP_i             (rr_latches_next_normal_latches_cs_ST_OP), \
        .nextLatches_normal_cs_dr_id_i             (rr_latches_next_normal_latches_cs_dr_id), \
        .nextLatches_normal_cs_sr_id_i             (rr_latches_next_normal_latches_cs_sr_id), \
        .nextLatches_normal_cs_dr_rd_i             (rr_latches_next_normal_latches_cs_dr_rd), \
        .nextLatches_normal_cs_sr_rd_i             (rr_latches_next_normal_latches_cs_sr_rd), \
        .nextLatches_normal_cs_eax_rd_i            (rr_latches_next_normal_latches_cs_eax_rd), \
        .nextLatches_normal_cs_dr_wr_i             (rr_latches_next_normal_latches_cs_dr_wr), \
        .nextLatches_normal_cs_sr_wr_i             (rr_latches_next_normal_latches_cs_sr_wr), \
        .nextLatches_normal_cs_eax_wr_i            (rr_latches_next_normal_latches_cs_eax_wr), \
        .nextLatches_normal_cs_MOVS_OP_i           (rr_latches_next_normal_latches_cs_MOVS_OP), \
        .nextLatches_normal_cs_datasize_i          (rr_latches_next_normal_latches_cs_datasize), \
        .nextLatches_normal_cs_will_mod_zf_i       (rr_latches_next_normal_latches_cs_will_mod_zf), \
        .nextLatches_normal_cs_seg_1_valid_i       (rr_latches_next_normal_latches_cs_seg_1_valid), \
        .nextLatches_normal_cs_seg_0_id_i          (rr_latches_next_normal_latches_cs_seg_0_id), \
        .nextLatches_normal_cs_seg_1_id_i          (rr_latches_next_normal_latches_cs_seg_1_id), \
        .nextLatches_normal_cs_special_modrm_bs_i  (rr_latches_next_normal_latches_cs_special_modrm_bs), \
        .nextLatches_normal_cs_special_br_i        (rr_latches_next_normal_latches_cs_special_br), \
        .nextLatches_normal_dc_cs_LD_OP_i          (rr_latches_next_normal_latches_dc_cs_LD_OP), \
        .nextLatches_normal_dc_cs_ST_OP_i          (rr_latches_next_normal_latches_dc_cs_ST_OP), \
        .nextLatches_normal_dc_cs_dr_upper8_i      (rr_latches_next_normal_latches_dc_cs_dr_upper8), \
        .nextLatches_normal_dc_cs_sr_upper8_i      (rr_latches_next_normal_latches_dc_cs_sr_upper8), \
        .nextLatches_normal_dc_cs_datasize_i       (rr_latches_next_normal_latches_dc_cs_datasize), \
        .nextLatches_normal_mem_cs_ST_OP_i         (rr_latches_next_normal_latches_mem_cs_ST_OP), \
        .nextLatches_normal_mem_cs_LD_OP_i         (rr_latches_next_normal_latches_mem_cs_LD_OP), \
        .nextLatches_normal_exe_cs_ST_OP_i         (rr_latches_next_normal_latches_exe_cs_ST_OP), \
        .nextLatches_normal_exe_cs_OP_TYPE_i       (rr_latches_next_normal_latches_exe_cs_OP_TYPE), \
        .nextLatches_normal_exe_cs_alu_inputA_sel_i(rr_latches_next_normal_latches_exe_cs_alu_inputA_sel), \
        .nextLatches_normal_exe_cs_alu_inputB_sel_i(rr_latches_next_normal_latches_exe_cs_alu_inputB_sel), \
        .nextLatches_normal_exe_cs_branch_target_sel_i(rr_latches_next_normal_latches_exe_cs_branch_target_sel), \
        .nextLatches_normal_exe_cs_shift_by_one_i  (rr_latches_next_normal_latches_exe_cs_shift_by_one), \
        .nextLatches_normal_exe_cs_br_ucond_i      (rr_latches_next_normal_latches_exe_cs_br_ucond), \
        .nextLatches_normal_exe_cs_relative_branch_i(rr_latches_next_normal_latches_exe_cs_relative_branch), \
        .nextLatches_normal_exe_cs_special_br_i    (rr_latches_next_normal_latches_exe_cs_special_br), \
        .nextLatches_normal_exe_cs_is_far_i        (rr_latches_next_normal_latches_exe_cs_is_far), \
        .nextLatches_normal_exe_cs_is_call_i       (rr_latches_next_normal_latches_exe_cs_is_call), \
        .nextLatches_normal_exe_cs_second_flag_needed_i(rr_latches_next_normal_latches_exe_cs_second_flag_needed), \
        .nextLatches_normal_exe_cs_rep_no_zf_update_i(rr_latches_next_normal_latches_exe_cs_rep_no_zf_update), \
        .nextLatches_normal_wb_cs_ST_OP_i          (rr_latches_next_normal_latches_wb_cs_ST_OP), \
        .nextLatches_normal_wb_cs_WB_DR_i          (rr_latches_next_normal_latches_wb_cs_WB_DR), \
        .nextLatches_normal_wb_cs_WB_SR_i          (rr_latches_next_normal_latches_wb_cs_WB_SR), \
        .nextLatches_normal_wb_cs_WB_EAX_i         (rr_latches_next_normal_latches_wb_cs_WB_EAX), \
        .nextLatches_normal_br_info_valid_i        (rr_latches_next_normal_latches_br_info_valid), \
        .nextLatches_normal_br_info_br_eip_i       (rr_latches_next_normal_latches_br_info_br_eip), \
        .nextLatches_normal_br_info_br_xcl_i       (rr_latches_next_normal_latches_br_info_br_xcl), \
        .nextLatches_normal_br_info_br_pred_taken_i(rr_latches_next_normal_latches_br_info_br_pred_taken), \
        .nextLatches_normal_br_info_speculative_target_i(rr_latches_next_normal_latches_br_info_speculative_target), \
        .nextLatches_normal_NEIP_i                 (rr_latches_next_normal_latches_NEIP), \
        .nextLatches_normal_EIP_i                  (rr_latches_next_normal_latches_EIP), \
        .nextLatches_normal_EAX_i                  (rr_latches_next_normal_latches_EAX), \
        .nextLatches_normal_imm64_i                (rr_latches_next_normal_latches_imm64), \
        .nextLatches_normal_sib_idx_id_i           (rr_latches_next_normal_latches_sib_idx_id), \
        .nextLatches_normal_sib_base_id_i          (rr_latches_next_normal_latches_sib_base_id), \
        .nextLatches_normal_sib_needed_i           (rr_latches_next_normal_latches_sib_needed), \
        .nextLatches_normal_sib_scale_i            (rr_latches_next_normal_latches_sib_scale), \
        .nextLatches_normal_disp_needed_i          (rr_latches_next_normal_latches_disp_needed), \
        .nextLatches_normal_disp_size_i            (rr_latches_next_normal_latches_disp_size), \
        .nextLatches_normal_displacement_i         (rr_latches_next_normal_latches_displacement), \
        .nextLatches_rep_valid_i                (rr_latches_next_rep_latches_valid), \
        .nextLatches_rep_cs_ST_SEL_i            (rr_latches_next_rep_latches_cs_ST_SEL), \
        .nextLatches_rep_cs_MODRM_NEEDED_i      (rr_latches_next_rep_latches_cs_MODRM_NEEDED), \
        .nextLatches_rep_cs_RM_IS_DR_i          (rr_latches_next_rep_latches_cs_RM_IS_DR), \
        .nextLatches_rep_cs_SWITCH_LD_ADDY_i    (rr_latches_next_rep_latches_cs_SWITCH_LD_ADDY), \
        .nextLatches_rep_cs_LD_OP_i             (rr_latches_next_rep_latches_cs_LD_OP), \
        .nextLatches_rep_cs_ST_OP_i             (rr_latches_next_rep_latches_cs_ST_OP), \
        .nextLatches_rep_cs_dr_id_i             (rr_latches_next_rep_latches_cs_dr_id), \
        .nextLatches_rep_cs_sr_id_i             (rr_latches_next_rep_latches_cs_sr_id), \
        .nextLatches_rep_cs_dr_rd_i             (rr_latches_next_rep_latches_cs_dr_rd), \
        .nextLatches_rep_cs_sr_rd_i             (rr_latches_next_rep_latches_cs_sr_rd), \
        .nextLatches_rep_cs_eax_rd_i            (rr_latches_next_rep_latches_cs_eax_rd), \
        .nextLatches_rep_cs_dr_wr_i             (rr_latches_next_rep_latches_cs_dr_wr), \
        .nextLatches_rep_cs_sr_wr_i             (rr_latches_next_rep_latches_cs_sr_wr), \
        .nextLatches_rep_cs_eax_wr_i            (rr_latches_next_rep_latches_cs_eax_wr), \
        .nextLatches_rep_cs_MOVS_OP_i           (rr_latches_next_rep_latches_cs_MOVS_OP), \
        .nextLatches_rep_cs_datasize_i          (rr_latches_next_rep_latches_cs_datasize), \
        .nextLatches_rep_cs_will_mod_zf_i       (rr_latches_next_rep_latches_cs_will_mod_zf), \
        .nextLatches_rep_cs_seg_1_valid_i       (rr_latches_next_rep_latches_cs_seg_1_valid), \
        .nextLatches_rep_cs_seg_0_id_i          (rr_latches_next_rep_latches_cs_seg_0_id), \
        .nextLatches_rep_cs_seg_1_id_i          (rr_latches_next_rep_latches_cs_seg_1_id), \
        .nextLatches_rep_cs_special_modrm_bs_i  (rr_latches_next_rep_latches_cs_special_modrm_bs), \
        .nextLatches_rep_cs_special_br_i        (rr_latches_next_rep_latches_cs_special_br), \
        .nextLatches_rep_dc_cs_LD_OP_i          (rr_latches_next_rep_latches_dc_cs_LD_OP), \
        .nextLatches_rep_dc_cs_ST_OP_i          (rr_latches_next_rep_latches_dc_cs_ST_OP), \
        .nextLatches_rep_dc_cs_dr_upper8_i      (rr_latches_next_rep_latches_dc_cs_dr_upper8), \
        .nextLatches_rep_dc_cs_sr_upper8_i      (rr_latches_next_rep_latches_dc_cs_sr_upper8), \
        .nextLatches_rep_dc_cs_datasize_i       (rr_latches_next_rep_latches_dc_cs_datasize), \
        .nextLatches_rep_mem_cs_ST_OP_i         (rr_latches_next_rep_latches_mem_cs_ST_OP), \
        .nextLatches_rep_mem_cs_LD_OP_i         (rr_latches_next_rep_latches_mem_cs_LD_OP), \
        .nextLatches_rep_exe_cs_ST_OP_i         (rr_latches_next_rep_latches_exe_cs_ST_OP), \
        .nextLatches_rep_exe_cs_OP_TYPE_i       (rr_latches_next_rep_latches_exe_cs_OP_TYPE), \
        .nextLatches_rep_exe_cs_alu_inputA_sel_i(rr_latches_next_rep_latches_exe_cs_alu_inputA_sel), \
        .nextLatches_rep_exe_cs_alu_inputB_sel_i(rr_latches_next_rep_latches_exe_cs_alu_inputB_sel), \
        .nextLatches_rep_exe_cs_branch_target_sel_i(rr_latches_next_rep_latches_exe_cs_branch_target_sel), \
        .nextLatches_rep_exe_cs_shift_by_one_i  (rr_latches_next_rep_latches_exe_cs_shift_by_one), \
        .nextLatches_rep_exe_cs_br_ucond_i      (rr_latches_next_rep_latches_exe_cs_br_ucond), \
        .nextLatches_rep_exe_cs_relative_branch_i(rr_latches_next_rep_latches_exe_cs_relative_branch), \
        .nextLatches_rep_exe_cs_special_br_i    (rr_latches_next_rep_latches_exe_cs_special_br), \
        .nextLatches_rep_exe_cs_is_far_i        (rr_latches_next_rep_latches_exe_cs_is_far), \
        .nextLatches_rep_exe_cs_is_call_i       (rr_latches_next_rep_latches_exe_cs_is_call), \
        .nextLatches_rep_exe_cs_second_flag_needed_i(rr_latches_next_rep_latches_exe_cs_second_flag_needed), \
        .nextLatches_rep_exe_cs_rep_no_zf_update_i(rr_latches_next_rep_latches_exe_cs_rep_no_zf_update), \
        .nextLatches_rep_wb_cs_ST_OP_i          (rr_latches_next_rep_latches_wb_cs_ST_OP), \
        .nextLatches_rep_wb_cs_WB_DR_i          (rr_latches_next_rep_latches_wb_cs_WB_DR), \
        .nextLatches_rep_wb_cs_WB_SR_i          (rr_latches_next_rep_latches_wb_cs_WB_SR), \
        .nextLatches_rep_wb_cs_WB_EAX_i         (rr_latches_next_rep_latches_wb_cs_WB_EAX), \
        .nextLatches_rep_br_info_valid_i        (rr_latches_next_rep_latches_br_info_valid), \
        .nextLatches_rep_br_info_br_eip_i       (rr_latches_next_rep_latches_br_info_br_eip), \
        .nextLatches_rep_br_info_br_xcl_i       (rr_latches_next_rep_latches_br_info_br_xcl), \
        .nextLatches_rep_br_info_br_pred_taken_i(rr_latches_next_rep_latches_br_info_br_pred_taken), \
        .nextLatches_rep_br_info_speculative_target_i(rr_latches_next_rep_latches_br_info_speculative_target), \
        .nextLatches_rep_NEIP_i                 (rr_latches_next_rep_latches_NEIP), \
        .nextLatches_rep_EIP_i                  (rr_latches_next_rep_latches_EIP), \
        .nextLatches_rep_EAX_i                  (rr_latches_next_rep_latches_EAX), \
        .nextLatches_rep_imm64_i                (rr_latches_next_rep_latches_imm64), \
        .nextLatches_rep_sib_idx_id_i           (rr_latches_next_rep_latches_sib_idx_id), \
        .nextLatches_rep_sib_base_id_i          (rr_latches_next_rep_latches_sib_base_id), \
        .nextLatches_rep_sib_needed_i           (rr_latches_next_rep_latches_sib_needed), \
        .nextLatches_rep_sib_scale_i            (rr_latches_next_rep_latches_sib_scale), \
        .nextLatches_rep_disp_needed_i          (rr_latches_next_rep_latches_disp_needed), \
        .nextLatches_rep_disp_size_i            (rr_latches_next_rep_latches_disp_size), \
        .nextLatches_rep_displacement_i         (rr_latches_next_rep_latches_displacement), \
        .latches_normal_valid_o                  (rr_latches_normal_valid), \
        .latches_normal_cs_ST_SEL_o              (rr_latches_normal_cs_ST_SEL), \
        .latches_normal_cs_MODRM_NEEDED_o        (rr_latches_normal_cs_MODRM_NEEDED), \
        .latches_normal_cs_RM_IS_DR_o            (rr_latches_normal_cs_RM_IS_DR), \
        .latches_normal_cs_SWITCH_LD_ADDY_o      (rr_latches_normal_cs_SWITCH_LD_ADDY), \
        .latches_normal_cs_LD_OP_o               (rr_latches_normal_cs_LD_OP), \
        .latches_normal_cs_ST_OP_o               (rr_latches_normal_cs_ST_OP), \
        .latches_normal_cs_dr_id_o               (rr_latches_normal_cs_dr_id), \
        .latches_normal_cs_sr_id_o               (rr_latches_normal_cs_sr_id), \
        .latches_normal_cs_dr_rd_o               (rr_latches_normal_cs_dr_rd), \
        .latches_normal_cs_sr_rd_o               (rr_latches_normal_cs_sr_rd), \
        .latches_normal_cs_eax_rd_o              (rr_latches_normal_cs_eax_rd), \
        .latches_normal_cs_dr_wr_o               (rr_latches_normal_cs_dr_wr), \
        .latches_normal_cs_sr_wr_o               (rr_latches_normal_cs_sr_wr), \
        .latches_normal_cs_eax_wr_o              (rr_latches_normal_cs_eax_wr), \
        .latches_normal_cs_MOVS_OP_o             (rr_latches_normal_cs_MOVS_OP), \
        .latches_normal_cs_datasize_o            (rr_latches_normal_cs_datasize), \
        .latches_normal_cs_will_mod_zf_o         (rr_latches_normal_cs_will_mod_zf), \
        .latches_normal_cs_seg_1_valid_o         (rr_latches_normal_cs_seg_1_valid), \
        .latches_normal_cs_seg_0_id_o            (rr_latches_normal_cs_seg_0_id), \
        .latches_normal_cs_seg_1_id_o            (rr_latches_normal_cs_seg_1_id), \
        .latches_normal_cs_special_modrm_bs_o    (rr_latches_normal_cs_special_modrm_bs), \
        .latches_normal_cs_special_br_o          (rr_latches_normal_cs_special_br), \
        .latches_normal_dc_cs_LD_OP_o            (rr_latches_normal_dc_cs_LD_OP), \
        .latches_normal_dc_cs_ST_OP_o            (rr_latches_normal_dc_cs_ST_OP), \
        .latches_normal_dc_cs_dr_upper8_o        (rr_latches_normal_dc_cs_dr_upper8), \
        .latches_normal_dc_cs_sr_upper8_o        (rr_latches_normal_dc_cs_sr_upper8), \
        .latches_normal_dc_cs_datasize_o         (rr_latches_normal_dc_cs_datasize), \
        .latches_normal_mem_cs_ST_OP_o           (rr_latches_normal_mem_cs_ST_OP), \
        .latches_normal_mem_cs_LD_OP_o           (rr_latches_normal_mem_cs_LD_OP), \
        .latches_normal_exe_cs_ST_OP_o           (rr_latches_normal_exe_cs_ST_OP), \
        .latches_normal_exe_cs_OP_TYPE_o         (rr_latches_normal_exe_cs_OP_TYPE), \
        .latches_normal_exe_cs_alu_inputA_sel_o  (rr_latches_normal_exe_cs_alu_inputA_sel), \
        .latches_normal_exe_cs_alu_inputB_sel_o  (rr_latches_normal_exe_cs_alu_inputB_sel), \
        .latches_normal_exe_cs_branch_target_sel_o(rr_latches_normal_exe_cs_branch_target_sel), \
        .latches_normal_exe_cs_shift_by_one_o    (rr_latches_normal_exe_cs_shift_by_one), \
        .latches_normal_exe_cs_br_ucond_o        (rr_latches_normal_exe_cs_br_ucond), \
        .latches_normal_exe_cs_relative_branch_o (rr_latches_normal_exe_cs_relative_branch), \
        .latches_normal_exe_cs_special_br_o      (rr_latches_normal_exe_cs_special_br), \
        .latches_normal_exe_cs_is_far_o          (rr_latches_normal_exe_cs_is_far), \
        .latches_normal_exe_cs_is_call_o         (rr_latches_normal_exe_cs_is_call), \
        .latches_normal_exe_cs_second_flag_needed_o(rr_latches_normal_exe_cs_second_flag_needed), \
        .latches_normal_exe_cs_rep_no_zf_update_o(rr_latches_normal_exe_cs_rep_no_zf_update), \
        .latches_normal_wb_cs_ST_OP_o            (rr_latches_normal_wb_cs_ST_OP), \
        .latches_normal_wb_cs_WB_DR_o            (rr_latches_normal_wb_cs_WB_DR), \
        .latches_normal_wb_cs_WB_SR_o            (rr_latches_normal_wb_cs_WB_SR), \
        .latches_normal_wb_cs_WB_EAX_o           (rr_latches_normal_wb_cs_WB_EAX), \
        .latches_normal_br_info_valid_o          (rr_latches_normal_br_info_valid), \
        .latches_normal_br_info_br_eip_o         (rr_latches_normal_br_info_br_eip), \
        .latches_normal_br_info_br_xcl_o         (rr_latches_normal_br_info_br_xcl), \
        .latches_normal_br_info_br_pred_taken_o  (rr_latches_normal_br_info_br_pred_taken), \
        .latches_normal_br_info_speculative_target_o(rr_latches_normal_br_info_speculative_target), \
        .latches_normal_NEIP_o                   (rr_latches_normal_NEIP), \
        .latches_normal_EIP_o                    (rr_latches_normal_EIP), \
        .latches_normal_EAX_o                    (rr_latches_normal_EAX), \
        .latches_normal_imm64_o                  (rr_latches_normal_imm64), \
        .latches_normal_sib_idx_id_o             (rr_latches_normal_sib_idx_id), \
        .latches_normal_sib_base_id_o            (rr_latches_normal_sib_base_id), \
        .latches_normal_sib_needed_o             (rr_latches_normal_sib_needed), \
        .latches_normal_sib_scale_o              (rr_latches_normal_sib_scale), \
        .latches_normal_disp_needed_o            (rr_latches_normal_disp_needed), \
        .latches_normal_disp_size_o              (rr_latches_normal_disp_size), \
        .latches_normal_displacement_o           (rr_latches_normal_displacement), \
        .latches_rep_valid_o                  (rr_latches_rep_valid), \
        .latches_rep_cs_ST_SEL_o              (rr_latches_rep_cs_ST_SEL), \
        .latches_rep_cs_MODRM_NEEDED_o        (rr_latches_rep_cs_MODRM_NEEDED), \
        .latches_rep_cs_RM_IS_DR_o            (rr_latches_rep_cs_RM_IS_DR), \
        .latches_rep_cs_SWITCH_LD_ADDY_o      (rr_latches_rep_cs_SWITCH_LD_ADDY), \
        .latches_rep_cs_LD_OP_o               (rr_latches_rep_cs_LD_OP), \
        .latches_rep_cs_ST_OP_o               (rr_latches_rep_cs_ST_OP), \
        .latches_rep_cs_dr_id_o               (rr_latches_rep_cs_dr_id), \
        .latches_rep_cs_sr_id_o               (rr_latches_rep_cs_sr_id), \
        .latches_rep_cs_dr_rd_o               (rr_latches_rep_cs_dr_rd), \
        .latches_rep_cs_sr_rd_o               (rr_latches_rep_cs_sr_rd), \
        .latches_rep_cs_eax_rd_o              (rr_latches_rep_cs_eax_rd), \
        .latches_rep_cs_dr_wr_o               (rr_latches_rep_cs_dr_wr), \
        .latches_rep_cs_sr_wr_o               (rr_latches_rep_cs_sr_wr), \
        .latches_rep_cs_eax_wr_o              (rr_latches_rep_cs_eax_wr), \
        .latches_rep_cs_MOVS_OP_o             (rr_latches_rep_cs_MOVS_OP), \
        .latches_rep_cs_datasize_o            (rr_latches_rep_cs_datasize), \
        .latches_rep_cs_will_mod_zf_o         (rr_latches_rep_cs_will_mod_zf), \
        .latches_rep_cs_seg_1_valid_o         (rr_latches_rep_cs_seg_1_valid), \
        .latches_rep_cs_seg_0_id_o            (rr_latches_rep_cs_seg_0_id), \
        .latches_rep_cs_seg_1_id_o            (rr_latches_rep_cs_seg_1_id), \
        .latches_rep_cs_special_modrm_bs_o    (rr_latches_rep_cs_special_modrm_bs), \
        .latches_rep_cs_special_br_o          (rr_latches_rep_cs_special_br), \
        .latches_rep_dc_cs_LD_OP_o            (rr_latches_rep_dc_cs_LD_OP), \
        .latches_rep_dc_cs_ST_OP_o            (rr_latches_rep_dc_cs_ST_OP), \
        .latches_rep_dc_cs_dr_upper8_o        (rr_latches_rep_dc_cs_dr_upper8), \
        .latches_rep_dc_cs_sr_upper8_o        (rr_latches_rep_dc_cs_sr_upper8), \
        .latches_rep_dc_cs_datasize_o         (rr_latches_rep_dc_cs_datasize), \
        .latches_rep_mem_cs_ST_OP_o           (rr_latches_rep_mem_cs_ST_OP), \
        .latches_rep_mem_cs_LD_OP_o           (rr_latches_rep_mem_cs_LD_OP), \
        .latches_rep_exe_cs_ST_OP_o           (rr_latches_rep_exe_cs_ST_OP), \
        .latches_rep_exe_cs_OP_TYPE_o         (rr_latches_rep_exe_cs_OP_TYPE), \
        .latches_rep_exe_cs_alu_inputA_sel_o  (rr_latches_rep_exe_cs_alu_inputA_sel), \
        .latches_rep_exe_cs_alu_inputB_sel_o  (rr_latches_rep_exe_cs_alu_inputB_sel), \
        .latches_rep_exe_cs_branch_target_sel_o(rr_latches_rep_exe_cs_branch_target_sel), \
        .latches_rep_exe_cs_shift_by_one_o    (rr_latches_rep_exe_cs_shift_by_one), \
        .latches_rep_exe_cs_br_ucond_o        (rr_latches_rep_exe_cs_br_ucond), \
        .latches_rep_exe_cs_relative_branch_o (rr_latches_rep_exe_cs_relative_branch), \
        .latches_rep_exe_cs_special_br_o      (rr_latches_rep_exe_cs_special_br), \
        .latches_rep_exe_cs_is_far_o          (rr_latches_rep_exe_cs_is_far), \
        .latches_rep_exe_cs_is_call_o         (rr_latches_rep_exe_cs_is_call), \
        .latches_rep_exe_cs_second_flag_needed_o(rr_latches_rep_exe_cs_second_flag_needed), \
        .latches_rep_exe_cs_rep_no_zf_update_o(rr_latches_rep_exe_cs_rep_no_zf_update), \
        .latches_rep_wb_cs_ST_OP_o            (rr_latches_rep_wb_cs_ST_OP), \
        .latches_rep_wb_cs_WB_DR_o            (rr_latches_rep_wb_cs_WB_DR), \
        .latches_rep_wb_cs_WB_SR_o            (rr_latches_rep_wb_cs_WB_SR), \
        .latches_rep_wb_cs_WB_EAX_o           (rr_latches_rep_wb_cs_WB_EAX), \
        .latches_rep_br_info_valid_o          (rr_latches_rep_br_info_valid), \
        .latches_rep_br_info_br_eip_o         (rr_latches_rep_br_info_br_eip), \
        .latches_rep_br_info_br_xcl_o         (rr_latches_rep_br_info_br_xcl), \
        .latches_rep_br_info_br_pred_taken_o  (rr_latches_rep_br_info_br_pred_taken), \
        .latches_rep_br_info_speculative_target_o(rr_latches_rep_br_info_speculative_target), \
        .latches_rep_NEIP_o                   (rr_latches_rep_NEIP), \
        .latches_rep_EIP_o                    (rr_latches_rep_EIP), \
        .latches_rep_EAX_o                    (rr_latches_rep_EAX), \
        .latches_rep_imm64_o                  (rr_latches_rep_imm64), \
        .latches_rep_sib_idx_id_o             (rr_latches_rep_sib_idx_id), \
        .latches_rep_sib_base_id_o            (rr_latches_rep_sib_base_id), \
        .latches_rep_sib_needed_o             (rr_latches_rep_sib_needed), \
        .latches_rep_sib_scale_o              (rr_latches_rep_sib_scale), \
        .latches_rep_disp_needed_o            (rr_latches_rep_disp_needed), \
        .latches_rep_disp_size_o              (rr_latches_rep_disp_size), \
        .latches_rep_displacement_o           (rr_latches_rep_displacement) \
    );
