`define DECODE_STAGE \
    Decode decode_unit ( \
        .clk(clk), \
        .rst(rst), \
        .idm_outs_idm_slots_0_valid         (idm_outputs_idm_slots_0_valid), \
        .idm_outs_idm_slots_0_br_valid      (idm_outputs_idm_slots_0_br_valid), \
        .idm_outs_idm_slots_0_br_eip        (idm_outputs_idm_slots_0_br_eip), \
        .idm_outs_idm_slots_0_br_btb_target (idm_outputs_idm_slots_0_br_btb_target), \
        .idm_outs_idm_slots_0_br_xcl        (idm_outputs_idm_slots_0_br_xcl), \
        .idm_outs_idm_slots_0_data          (idm_outputs_idm_slots_0_data), \
        .idm_outs_idm_slots_1_valid         (idm_outputs_idm_slots_1_valid), \
        .idm_outs_idm_slots_1_br_valid      (idm_outputs_idm_slots_1_br_valid), \
        .idm_outs_idm_slots_1_br_eip        (idm_outputs_idm_slots_1_br_eip), \
        .idm_outs_idm_slots_1_br_btb_target (idm_outputs_idm_slots_1_br_btb_target), \
        .idm_outs_idm_slots_1_br_xcl        (idm_outputs_idm_slots_1_br_xcl), \
        .idm_outs_idm_slots_1_data          (idm_outputs_idm_slots_1_data), \
        .idm_outs_idm_slots_2_valid         (idm_outputs_idm_slots_2_valid), \
        .idm_outs_idm_slots_2_br_valid      (idm_outputs_idm_slots_2_br_valid), \
        .idm_outs_idm_slots_2_br_eip        (idm_outputs_idm_slots_2_br_eip), \
        .idm_outs_idm_slots_2_br_btb_target (idm_outputs_idm_slots_2_br_btb_target), \
        .idm_outs_idm_slots_2_br_xcl        (idm_outputs_idm_slots_2_br_xcl), \
        .idm_outs_idm_slots_2_data          (idm_outputs_idm_slots_2_data), \
        .idm_outs_idm_slots_3_valid         (idm_outputs_idm_slots_3_valid), \
        .idm_outs_idm_slots_3_br_valid      (idm_outputs_idm_slots_3_br_valid), \
        .idm_outs_idm_slots_3_br_eip        (idm_outputs_idm_slots_3_br_eip), \
        .idm_outs_idm_slots_3_br_btb_target (idm_outputs_idm_slots_3_br_btb_target), \
        .idm_outs_idm_slots_3_br_xcl        (idm_outputs_idm_slots_3_br_xcl), \
        .idm_outs_idm_slots_3_data          (idm_outputs_idm_slots_3_data), \
        .fetch_outs_exp_pipe_clear (fetch_outputs_exp_pipe_clear), \
        .fetch_outs_exp_mode_jk    (fetch_outputs_exp_mode_jk), \
        .fetch_outs_int_mode_jk    (fetch_outputs_int_mode_jk), \
        .rr_outs_valid         (rr_outputs_valid), \
        .rr_outs_stall         (rr_outputs_stall), \
        .rr_outs_ecx_sb        (rr_outputs_ecx_sb), \
        .rr_outs_ecx           (rr_outputs_ecx), \
        .rr_outs_eax           (rr_outputs_eax), \
        .rr_outs_codeSeg_limit (rr_outputs_codeSeg_limit), \
        .dc_outs_valid  (dc_outputs_valid), \
        .dc_outs_stall  (dc_outputs_stall), \
        .dc_outs_dc_eip (dc_outputs_dc_eip), \
        .mem_outs_valid (mem_outputs_valid), \
        .mem_outs_stall (mem_outputs_stall), \
        .exe_outs_valid            (exe_outputs_valid), \
        .exe_outs_br_res_valid     (exe_outputs_br_res_valid_decode), \
        .exe_outs_br_res_flush     (exe_outputs_br_res_flush_decode), \
        .exe_outs_br_res_br_target (exe_outputs_br_res_br_target), \
        .exe_outs_clr_ZF_sb        (exe_outputs_clr_ZF_sb), \
        .exe_outs_ZF               (exe_outputs_ZF), \
        .wb_outs_wb_stall (wb_outputs_wb_stall), \
        .outs_valid               (decode_outputs_valid), \
        .outs_stall               (decode_outputs_stall), \
        .outs_eip                 (decode_outputs_eip), \
        .outs_invalid_instruction (decode_outputs_invalid_instruction), \
        .outs_decode_gp           (decode_outputs_decode_gp), \
        .outs_rr_stage_latch_we   (decode_outputs_rr_stage_latch_we), \
        .outs_rep_latch           (decode_outputs_rep_latch), \
        .outs_decode_forward      (decode_outputs_decode_forward), \
        .rr_latches_next_normal_latches_valid                (rr_latches_next_normal_latches_valid), \
        .rr_latches_next_normal_latches_cs_ST_SEL            (rr_latches_next_normal_latches_cs_ST_SEL), \
        .rr_latches_next_normal_latches_cs_MODRM_NEEDED      (rr_latches_next_normal_latches_cs_MODRM_NEEDED), \
        .rr_latches_next_normal_latches_cs_RM_IS_DR          (rr_latches_next_normal_latches_cs_RM_IS_DR), \
        .rr_latches_next_normal_latches_cs_SWITCH_LD_ADDY    (rr_latches_next_normal_latches_cs_SWITCH_LD_ADDY), \
        .rr_latches_next_normal_latches_cs_LD_OP             (rr_latches_next_normal_latches_cs_LD_OP), \
        .rr_latches_next_normal_latches_cs_ST_OP             (rr_latches_next_normal_latches_cs_ST_OP), \
        .rr_latches_next_normal_latches_cs_dr_id             (rr_latches_next_normal_latches_cs_dr_id), \
        .rr_latches_next_normal_latches_cs_sr_id             (rr_latches_next_normal_latches_cs_sr_id), \
        .rr_latches_next_normal_latches_cs_dr_rd             (rr_latches_next_normal_latches_cs_dr_rd), \
        .rr_latches_next_normal_latches_cs_sr_rd             (rr_latches_next_normal_latches_cs_sr_rd), \
        .rr_latches_next_normal_latches_cs_eax_rd            (rr_latches_next_normal_latches_cs_eax_rd), \
        .rr_latches_next_normal_latches_cs_dr_wr             (rr_latches_next_normal_latches_cs_dr_wr), \
        .rr_latches_next_normal_latches_cs_sr_wr             (rr_latches_next_normal_latches_cs_sr_wr), \
        .rr_latches_next_normal_latches_cs_eax_wr            (rr_latches_next_normal_latches_cs_eax_wr), \
        .rr_latches_next_normal_latches_cs_MOVS_OP           (rr_latches_next_normal_latches_cs_MOVS_OP), \
        .rr_latches_next_normal_latches_cs_datasize          (rr_latches_next_normal_latches_cs_datasize), \
        .rr_latches_next_normal_latches_cs_will_mod_zf       (rr_latches_next_normal_latches_cs_will_mod_zf), \
        .rr_latches_next_normal_latches_cs_seg_1_valid       (rr_latches_next_normal_latches_cs_seg_1_valid), \
        .rr_latches_next_normal_latches_cs_seg_0_id          (rr_latches_next_normal_latches_cs_seg_0_id), \
        .rr_latches_next_normal_latches_cs_seg_1_id          (rr_latches_next_normal_latches_cs_seg_1_id), \
        .rr_latches_next_normal_latches_cs_special_modrm_bs  (rr_latches_next_normal_latches_cs_special_modrm_bs), \
        .rr_latches_next_normal_latches_cs_special_br        (rr_latches_next_normal_latches_cs_special_br), \
        .rr_latches_next_normal_latches_dc_cs_LD_OP          (rr_latches_next_normal_latches_dc_cs_LD_OP), \
        .rr_latches_next_normal_latches_dc_cs_ST_OP          (rr_latches_next_normal_latches_dc_cs_ST_OP), \
        .rr_latches_next_normal_latches_dc_cs_dr_upper8      (rr_latches_next_normal_latches_dc_cs_dr_upper8), \
        .rr_latches_next_normal_latches_dc_cs_sr_upper8      (rr_latches_next_normal_latches_dc_cs_sr_upper8), \
        .rr_latches_next_normal_latches_dc_cs_datasize       (rr_latches_next_normal_latches_dc_cs_datasize), \
        .rr_latches_next_normal_latches_mem_cs_ST_OP         (rr_latches_next_normal_latches_mem_cs_ST_OP), \
        .rr_latches_next_normal_latches_mem_cs_LD_OP         (rr_latches_next_normal_latches_mem_cs_LD_OP), \
        .rr_latches_next_normal_latches_exe_cs_ST_OP         (rr_latches_next_normal_latches_exe_cs_ST_OP), \
        .rr_latches_next_normal_latches_exe_cs_OP_TYPE       (rr_latches_next_normal_latches_exe_cs_OP_TYPE), \
        .rr_latches_next_normal_latches_exe_cs_alu_inputA_sel(rr_latches_next_normal_latches_exe_cs_alu_inputA_sel), \
        .rr_latches_next_normal_latches_exe_cs_alu_inputB_sel(rr_latches_next_normal_latches_exe_cs_alu_inputB_sel), \
        .rr_latches_next_normal_latches_exe_cs_branch_target_sel(rr_latches_next_normal_latches_exe_cs_branch_target_sel), \
        .rr_latches_next_normal_latches_exe_cs_shift_by_one  (rr_latches_next_normal_latches_exe_cs_shift_by_one), \
        .rr_latches_next_normal_latches_exe_cs_br_ucond      (rr_latches_next_normal_latches_exe_cs_br_ucond), \
        .rr_latches_next_normal_latches_exe_cs_relative_branch(rr_latches_next_normal_latches_exe_cs_relative_branch), \
        .rr_latches_next_normal_latches_exe_cs_special_br    (rr_latches_next_normal_latches_exe_cs_special_br), \
        .rr_latches_next_normal_latches_exe_cs_is_far        (rr_latches_next_normal_latches_exe_cs_is_far), \
        .rr_latches_next_normal_latches_exe_cs_is_call       (rr_latches_next_normal_latches_exe_cs_is_call), \
        .rr_latches_next_normal_latches_exe_cs_second_flag_needed(rr_latches_next_normal_latches_exe_cs_second_flag_needed), \
        .rr_latches_next_normal_latches_exe_cs_rep_no_zf_update(rr_latches_next_normal_latches_exe_cs_rep_no_zf_update), \
        .rr_latches_next_normal_latches_wb_cs_ST_OP          (rr_latches_next_normal_latches_wb_cs_ST_OP), \
        .rr_latches_next_normal_latches_wb_cs_WB_DR          (rr_latches_next_normal_latches_wb_cs_WB_DR), \
        .rr_latches_next_normal_latches_wb_cs_WB_SR          (rr_latches_next_normal_latches_wb_cs_WB_SR), \
        .rr_latches_next_normal_latches_wb_cs_WB_EAX         (rr_latches_next_normal_latches_wb_cs_WB_EAX), \
        .rr_latches_next_normal_latches_br_info_valid        (rr_latches_next_normal_latches_br_info_valid), \
        .rr_latches_next_normal_latches_br_info_br_eip       (rr_latches_next_normal_latches_br_info_br_eip), \
        .rr_latches_next_normal_latches_br_info_br_xcl       (rr_latches_next_normal_latches_br_info_br_xcl), \
        .rr_latches_next_normal_latches_br_info_br_pred_taken(rr_latches_next_normal_latches_br_info_br_pred_taken), \
        .rr_latches_next_normal_latches_br_info_speculative_target(rr_latches_next_normal_latches_br_info_speculative_target), \
        .rr_latches_next_normal_latches_NEIP                 (rr_latches_next_normal_latches_NEIP), \
        .rr_latches_next_normal_latches_EIP                  (rr_latches_next_normal_latches_EIP), \
        .rr_latches_next_normal_latches_EAX                  (rr_latches_next_normal_latches_EAX), \
        .rr_latches_next_normal_latches_imm64                (rr_latches_next_normal_latches_imm64), \
        .rr_latches_next_normal_latches_sib_idx_id           (rr_latches_next_normal_latches_sib_idx_id), \
        .rr_latches_next_normal_latches_sib_base_id          (rr_latches_next_normal_latches_sib_base_id), \
        .rr_latches_next_normal_latches_sib_needed           (rr_latches_next_normal_latches_sib_needed), \
        .rr_latches_next_normal_latches_sib_scale            (rr_latches_next_normal_latches_sib_scale), \
        .rr_latches_next_normal_latches_disp_needed          (rr_latches_next_normal_latches_disp_needed), \
        .rr_latches_next_normal_latches_disp_size            (rr_latches_next_normal_latches_disp_size), \
        .rr_latches_next_normal_latches_displacement         (rr_latches_next_normal_latches_displacement), \
        .rr_latches_next_rep_latches_valid                (rr_latches_next_rep_latches_valid), \
        .rr_latches_next_rep_latches_cs_ST_SEL            (rr_latches_next_rep_latches_cs_ST_SEL), \
        .rr_latches_next_rep_latches_cs_MODRM_NEEDED      (rr_latches_next_rep_latches_cs_MODRM_NEEDED), \
        .rr_latches_next_rep_latches_cs_RM_IS_DR          (rr_latches_next_rep_latches_cs_RM_IS_DR), \
        .rr_latches_next_rep_latches_cs_SWITCH_LD_ADDY    (rr_latches_next_rep_latches_cs_SWITCH_LD_ADDY), \
        .rr_latches_next_rep_latches_cs_LD_OP             (rr_latches_next_rep_latches_cs_LD_OP), \
        .rr_latches_next_rep_latches_cs_ST_OP             (rr_latches_next_rep_latches_cs_ST_OP), \
        .rr_latches_next_rep_latches_cs_dr_id             (rr_latches_next_rep_latches_cs_dr_id), \
        .rr_latches_next_rep_latches_cs_sr_id             (rr_latches_next_rep_latches_cs_sr_id), \
        .rr_latches_next_rep_latches_cs_dr_rd             (rr_latches_next_rep_latches_cs_dr_rd), \
        .rr_latches_next_rep_latches_cs_sr_rd             (rr_latches_next_rep_latches_cs_sr_rd), \
        .rr_latches_next_rep_latches_cs_eax_rd            (rr_latches_next_rep_latches_cs_eax_rd), \
        .rr_latches_next_rep_latches_cs_dr_wr             (rr_latches_next_rep_latches_cs_dr_wr), \
        .rr_latches_next_rep_latches_cs_sr_wr             (rr_latches_next_rep_latches_cs_sr_wr), \
        .rr_latches_next_rep_latches_cs_eax_wr            (rr_latches_next_rep_latches_cs_eax_wr), \
        .rr_latches_next_rep_latches_cs_MOVS_OP           (rr_latches_next_rep_latches_cs_MOVS_OP), \
        .rr_latches_next_rep_latches_cs_datasize          (rr_latches_next_rep_latches_cs_datasize), \
        .rr_latches_next_rep_latches_cs_will_mod_zf       (rr_latches_next_rep_latches_cs_will_mod_zf), \
        .rr_latches_next_rep_latches_cs_seg_1_valid       (rr_latches_next_rep_latches_cs_seg_1_valid), \
        .rr_latches_next_rep_latches_cs_seg_0_id          (rr_latches_next_rep_latches_cs_seg_0_id), \
        .rr_latches_next_rep_latches_cs_seg_1_id          (rr_latches_next_rep_latches_cs_seg_1_id), \
        .rr_latches_next_rep_latches_cs_special_modrm_bs  (rr_latches_next_rep_latches_cs_special_modrm_bs), \
        .rr_latches_next_rep_latches_cs_special_br        (rr_latches_next_rep_latches_cs_special_br), \
        .rr_latches_next_rep_latches_dc_cs_LD_OP          (rr_latches_next_rep_latches_dc_cs_LD_OP), \
        .rr_latches_next_rep_latches_dc_cs_ST_OP          (rr_latches_next_rep_latches_dc_cs_ST_OP), \
        .rr_latches_next_rep_latches_dc_cs_dr_upper8      (rr_latches_next_rep_latches_dc_cs_dr_upper8), \
        .rr_latches_next_rep_latches_dc_cs_sr_upper8      (rr_latches_next_rep_latches_dc_cs_sr_upper8), \
        .rr_latches_next_rep_latches_dc_cs_datasize       (rr_latches_next_rep_latches_dc_cs_datasize), \
        .rr_latches_next_rep_latches_mem_cs_ST_OP         (rr_latches_next_rep_latches_mem_cs_ST_OP), \
        .rr_latches_next_rep_latches_mem_cs_LD_OP         (rr_latches_next_rep_latches_mem_cs_LD_OP), \
        .rr_latches_next_rep_latches_exe_cs_ST_OP         (rr_latches_next_rep_latches_exe_cs_ST_OP), \
        .rr_latches_next_rep_latches_exe_cs_OP_TYPE       (rr_latches_next_rep_latches_exe_cs_OP_TYPE), \
        .rr_latches_next_rep_latches_exe_cs_alu_inputA_sel(rr_latches_next_rep_latches_exe_cs_alu_inputA_sel), \
        .rr_latches_next_rep_latches_exe_cs_alu_inputB_sel(rr_latches_next_rep_latches_exe_cs_alu_inputB_sel), \
        .rr_latches_next_rep_latches_exe_cs_branch_target_sel(rr_latches_next_rep_latches_exe_cs_branch_target_sel), \
        .rr_latches_next_rep_latches_exe_cs_shift_by_one  (rr_latches_next_rep_latches_exe_cs_shift_by_one), \
        .rr_latches_next_rep_latches_exe_cs_br_ucond      (rr_latches_next_rep_latches_exe_cs_br_ucond), \
        .rr_latches_next_rep_latches_exe_cs_relative_branch(rr_latches_next_rep_latches_exe_cs_relative_branch), \
        .rr_latches_next_rep_latches_exe_cs_special_br    (rr_latches_next_rep_latches_exe_cs_special_br), \
        .rr_latches_next_rep_latches_exe_cs_is_far        (rr_latches_next_rep_latches_exe_cs_is_far), \
        .rr_latches_next_rep_latches_exe_cs_is_call       (rr_latches_next_rep_latches_exe_cs_is_call), \
        .rr_latches_next_rep_latches_exe_cs_second_flag_needed(rr_latches_next_rep_latches_exe_cs_second_flag_needed), \
        .rr_latches_next_rep_latches_exe_cs_rep_no_zf_update(rr_latches_next_rep_latches_exe_cs_rep_no_zf_update), \
        .rr_latches_next_rep_latches_wb_cs_ST_OP          (rr_latches_next_rep_latches_wb_cs_ST_OP), \
        .rr_latches_next_rep_latches_wb_cs_WB_DR          (rr_latches_next_rep_latches_wb_cs_WB_DR), \
        .rr_latches_next_rep_latches_wb_cs_WB_SR          (rr_latches_next_rep_latches_wb_cs_WB_SR), \
        .rr_latches_next_rep_latches_wb_cs_WB_EAX         (rr_latches_next_rep_latches_wb_cs_WB_EAX), \
        .rr_latches_next_rep_latches_br_info_valid        (rr_latches_next_rep_latches_br_info_valid), \
        .rr_latches_next_rep_latches_br_info_br_eip       (rr_latches_next_rep_latches_br_info_br_eip), \
        .rr_latches_next_rep_latches_br_info_br_xcl       (rr_latches_next_rep_latches_br_info_br_xcl), \
        .rr_latches_next_rep_latches_br_info_br_pred_taken(rr_latches_next_rep_latches_br_info_br_pred_taken), \
        .rr_latches_next_rep_latches_br_info_speculative_target(rr_latches_next_rep_latches_br_info_speculative_target), \
        .rr_latches_next_rep_latches_NEIP                 (rr_latches_next_rep_latches_NEIP), \
        .rr_latches_next_rep_latches_EIP                  (rr_latches_next_rep_latches_EIP), \
        .rr_latches_next_rep_latches_EAX                  (rr_latches_next_rep_latches_EAX), \
        .rr_latches_next_rep_latches_imm64                (rr_latches_next_rep_latches_imm64), \
        .rr_latches_next_rep_latches_sib_idx_id           (rr_latches_next_rep_latches_sib_idx_id), \
        .rr_latches_next_rep_latches_sib_base_id          (rr_latches_next_rep_latches_sib_base_id), \
        .rr_latches_next_rep_latches_sib_needed           (rr_latches_next_rep_latches_sib_needed), \
        .rr_latches_next_rep_latches_sib_scale            (rr_latches_next_rep_latches_sib_scale), \
        .rr_latches_next_rep_latches_disp_needed          (rr_latches_next_rep_latches_disp_needed), \
        .rr_latches_next_rep_latches_disp_size            (rr_latches_next_rep_latches_disp_size), \
        .rr_latches_next_rep_latches_displacement         (rr_latches_next_rep_latches_displacement) \
    );
