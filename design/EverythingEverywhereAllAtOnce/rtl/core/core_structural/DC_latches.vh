`define DC_LATCHES \
wire        dc_latches_valid; \
wire        dc_latches_cs_LD_OP; \
wire        dc_latches_cs_ST_OP; \
wire        dc_latches_cs_dr_upper8; \
wire        dc_latches_cs_sr_upper8; \
wire [1:0]  dc_latches_cs_datasize; \
wire        dc_latches_mem_cs_ST_OP; \
wire        dc_latches_mem_cs_LD_OP; \
wire        dc_latches_exe_cs_ST_OP; \
wire [5:0]  dc_latches_exe_cs_OP_TYPE; \
wire [4:0]  dc_latches_exe_cs_alu_inputA_sel; \
wire [4:0]  dc_latches_exe_cs_alu_inputB_sel; \
wire [4:0]  dc_latches_exe_cs_branch_target_sel; \
wire        dc_latches_exe_cs_shift_by_one; \
wire        dc_latches_exe_cs_br_ucond; \
wire        dc_latches_exe_cs_relative_branch; \
wire        dc_latches_exe_cs_special_br; \
wire        dc_latches_exe_cs_is_far; \
wire        dc_latches_exe_cs_is_call; \
wire        dc_latches_exe_cs_second_flag_needed; \
wire        dc_latches_exe_cs_rep_no_zf_update; \
wire        dc_latches_wb_cs_ST_OP; \
wire        dc_latches_wb_cs_WB_DR; \
wire        dc_latches_wb_cs_WB_SR; \
wire        dc_latches_wb_cs_WB_EAX; \
wire        dc_latches_br_info_valid; \
wire [31:0] dc_latches_br_info_br_eip; \
wire        dc_latches_br_info_br_xcl; \
wire        dc_latches_br_info_br_pred_taken; \
wire [31:0] dc_latches_br_info_speculative_target; \
wire        dc_latches_rr_gp; \
wire [31:0] dc_latches_ld_vaddy; \
wire [31:0] dc_latches_seg0_limit_w_datasize; \
wire [31:0] dc_latches_seg0_limit_wo_datasize; \
wire [31:0] dc_latches_next_ld_vaddy; \
wire [31:0] dc_latches_ld_laddy; \
wire        dc_latches_ld_stack_access; \
wire [31:0] dc_latches_st_vaddy; \
wire [31:0] dc_latches_seg1_limit_w_datasize; \
wire [31:0] dc_latches_seg1_limit_wo_datasize; \
wire [31:0] dc_latches_next_st_vaddy; \
wire [31:0] dc_latches_st_laddy; \
wire        dc_latches_st_stack_access; \
wire [31:0] dc_latches_NEIP; \
wire [31:0] dc_latches_EIP; \
wire [31:0] dc_latches_EAX; \
wire [63:0] dc_latches_imm64; \
wire [4:0]  dc_latches_sr_id; \
wire [63:0] dc_latches_sr_data; \
wire [4:0]  dc_latches_dr_id; \
wire [63:0] dc_latches_dr_data; \
wire [1:0]  dc_latches_cs_datasize_0; \
wire [1:0]  dc_latches_cs_datasize_1; \
wire [1:0]  dc_latches_cs_datasize_2; \
wire        dc_latches_cs_LD_OP_0; \
wire        dc_latches_cs_LD_OP_1; \
wire        dc_latches_cs_LD_OP_2; \
wire        dc_latches_cs_LD_OP_3; \
wire        dc_latches_cs_ST_OP_0; \
wire        dc_latches_valid_0; \
wire        dc_latches_valid_1; \
wire        dc_latches_valid_2; \
DC_Latches dc_latches_unit ( \
    .clk            (clk), \
    .rst            (rst), \
    .write_enable_i (rr_outputs_dc_stage_latch_we), \
    .flush          (exe_outputs_br_res_flush_dc), \
    .farFlush       (exe_outputs_br_res_farFlush), \
    .exp_pipe_clear (fetch_outputs_exp_pipe_clear), \
    .nextLatches_valid_i                       (dc_latches_next_valid), \
    .nextLatches_cs_LD_OP_i                    (dc_latches_next_cs_LD_OP), \
    .nextLatches_cs_ST_OP_i                    (dc_latches_next_cs_ST_OP), \
    .nextLatches_cs_dr_upper8_i                (dc_latches_next_cs_dr_upper8), \
    .nextLatches_cs_sr_upper8_i                (dc_latches_next_cs_sr_upper8), \
    .nextLatches_cs_datasize_i                 (dc_latches_next_cs_datasize), \
    .nextLatches_mem_cs_ST_OP_i                (dc_latches_next_mem_cs_ST_OP), \
    .nextLatches_mem_cs_LD_OP_i                (dc_latches_next_mem_cs_LD_OP), \
    .nextLatches_exe_cs_ST_OP_i                (dc_latches_next_exe_cs_ST_OP), \
    .nextLatches_exe_cs_OP_TYPE_i              (dc_latches_next_exe_cs_OP_TYPE), \
    .nextLatches_exe_cs_alu_inputA_sel_i       (dc_latches_next_exe_cs_alu_inputA_sel), \
    .nextLatches_exe_cs_alu_inputB_sel_i       (dc_latches_next_exe_cs_alu_inputB_sel), \
    .nextLatches_exe_cs_branch_target_sel_i    (dc_latches_next_exe_cs_branch_target_sel), \
    .nextLatches_exe_cs_shift_by_one_i         (dc_latches_next_exe_cs_shift_by_one), \
    .nextLatches_exe_cs_br_ucond_i             (dc_latches_next_exe_cs_br_ucond), \
    .nextLatches_exe_cs_relative_branch_i      (dc_latches_next_exe_cs_relative_branch), \
    .nextLatches_exe_cs_special_br_i           (dc_latches_next_exe_cs_special_br), \
    .nextLatches_exe_cs_is_far_i               (dc_latches_next_exe_cs_is_far), \
    .nextLatches_exe_cs_is_call_i              (dc_latches_next_exe_cs_is_call), \
    .nextLatches_exe_cs_second_flag_needed_i   (dc_latches_next_exe_cs_second_flag_needed), \
    .nextLatches_exe_cs_rep_no_zf_update_i     (dc_latches_next_exe_cs_rep_no_zf_update), \
    .nextLatches_wb_cs_ST_OP_i                 (dc_latches_next_wb_cs_ST_OP), \
    .nextLatches_wb_cs_WB_DR_i                 (dc_latches_next_wb_cs_WB_DR), \
    .nextLatches_wb_cs_WB_SR_i                 (dc_latches_next_wb_cs_WB_SR), \
    .nextLatches_wb_cs_WB_EAX_i                (dc_latches_next_wb_cs_WB_EAX), \
    .nextLatches_br_info_valid_i               (dc_latches_next_br_info_valid), \
    .nextLatches_br_info_br_eip_i              (dc_latches_next_br_info_br_eip), \
    .nextLatches_br_info_br_xcl_i              (dc_latches_next_br_info_br_xcl), \
    .nextLatches_br_info_br_pred_taken_i       (dc_latches_next_br_info_br_pred_taken), \
    .nextLatches_br_info_speculative_target_i  (dc_latches_next_br_info_speculative_target), \
    .nextLatches_rr_gp_i                       (dc_latches_next_rr_gp), \
    .nextLatches_ld_vaddy_i                    (_dc_latches_next_ld_vaddy_), \
    .nextLatches_seg0_limit_w_datasize_i       (dc_latches_next_seg0_limit_w_datasize), \
    .nextLatches_seg0_limit_wo_datasize_i      (dc_latches_next_seg0_limit_wo_datasize), \
    .nextLatches_next_ld_vaddy_i               (dc_latches_next_next_ld_vaddy), \
    .nextLatches_ld_laddy_i                    (dc_latches_next_ld_laddy), \
    .nextLatches_ld_stack_access_i             (dc_latches_next_ld_stack_access), \
    .nextLatches_st_vaddy_i                    (_dc_latches_next_st_vaddy_), \
    .nextLatches_seg1_limit_w_datasize_i       (dc_latches_next_seg1_limit_w_datasize), \
    .nextLatches_seg1_limit_wo_datasize_i      (dc_latches_next_seg1_limit_wo_datasize), \
    .nextLatches_next_st_vaddy_i               (dc_latches_next_next_st_vaddy), \
    .nextLatches_st_laddy_i                    (dc_latches_next_st_laddy), \
    .nextLatches_st_stack_access_i             (dc_latches_next_st_stack_access), \
    .nextLatches_NEIP_i                        (dc_latches_next_NEIP), \
    .nextLatches_EIP_i                         (dc_latches_next_EIP), \
    .nextLatches_EAX_i                         (dc_latches_next_EAX), \
    .nextLatches_imm64_i                       (dc_latches_next_imm64), \
    .nextLatches_sr_id_i                       (dc_latches_next_sr_id), \
    .nextLatches_sr_data_i                     (dc_latches_next_sr_data), \
    .nextLatches_dr_id_i                       (dc_latches_next_dr_id), \
    .nextLatches_dr_data_i                     (dc_latches_next_dr_data), \
    .nextLatches_cs_datasize_0_i               (dc_latches_next_cs_datasize_0), \
    .nextLatches_cs_datasize_1_i               (dc_latches_next_cs_datasize_1), \
    .nextLatches_cs_datasize_2_i               (dc_latches_next_cs_datasize_2), \
    .nextLatches_cs_LD_OP_0_i                  (dc_latches_next_cs_LD_OP_0), \
    .nextLatches_cs_LD_OP_1_i                  (dc_latches_next_cs_LD_OP_1), \
    .nextLatches_cs_LD_OP_2_i                  (dc_latches_next_cs_LD_OP_2), \
    .nextLatches_cs_LD_OP_3_i                  (dc_latches_next_cs_LD_OP_3), \
    .nextLatches_cs_ST_OP_0_i                  (dc_latches_next_cs_ST_OP_0), \
    .nextLatches_valid_0_i                     (dc_latches_next_valid_0), \
    .nextLatches_valid_1_i                     (dc_latches_next_valid_1), \
    .nextLatches_valid_2_i                     (dc_latches_next_valid_2), \
    .latches_valid_o                      (dc_latches_valid), \
    .latches_cs_LD_OP_o                   (dc_latches_cs_LD_OP), \
    .latches_cs_ST_OP_o                   (dc_latches_cs_ST_OP), \
    .latches_cs_dr_upper8_o               (dc_latches_cs_dr_upper8), \
    .latches_cs_sr_upper8_o               (dc_latches_cs_sr_upper8), \
    .latches_cs_datasize_o                (dc_latches_cs_datasize), \
    .latches_mem_cs_ST_OP_o               (dc_latches_mem_cs_ST_OP), \
    .latches_mem_cs_LD_OP_o               (dc_latches_mem_cs_LD_OP), \
    .latches_exe_cs_ST_OP_o               (dc_latches_exe_cs_ST_OP), \
    .latches_exe_cs_OP_TYPE_o             (dc_latches_exe_cs_OP_TYPE), \
    .latches_exe_cs_alu_inputA_sel_o      (dc_latches_exe_cs_alu_inputA_sel), \
    .latches_exe_cs_alu_inputB_sel_o      (dc_latches_exe_cs_alu_inputB_sel), \
    .latches_exe_cs_branch_target_sel_o   (dc_latches_exe_cs_branch_target_sel), \
    .latches_exe_cs_shift_by_one_o        (dc_latches_exe_cs_shift_by_one), \
    .latches_exe_cs_br_ucond_o            (dc_latches_exe_cs_br_ucond), \
    .latches_exe_cs_relative_branch_o     (dc_latches_exe_cs_relative_branch), \
    .latches_exe_cs_special_br_o          (dc_latches_exe_cs_special_br), \
    .latches_exe_cs_is_far_o              (dc_latches_exe_cs_is_far), \
    .latches_exe_cs_is_call_o             (dc_latches_exe_cs_is_call), \
    .latches_exe_cs_second_flag_needed_o  (dc_latches_exe_cs_second_flag_needed), \
    .latches_exe_cs_rep_no_zf_update_o    (dc_latches_exe_cs_rep_no_zf_update), \
    .latches_wb_cs_ST_OP_o                (dc_latches_wb_cs_ST_OP), \
    .latches_wb_cs_WB_DR_o                (dc_latches_wb_cs_WB_DR), \
    .latches_wb_cs_WB_SR_o                (dc_latches_wb_cs_WB_SR), \
    .latches_wb_cs_WB_EAX_o               (dc_latches_wb_cs_WB_EAX), \
    .latches_br_info_valid_o              (dc_latches_br_info_valid), \
    .latches_br_info_br_eip_o             (dc_latches_br_info_br_eip), \
    .latches_br_info_br_xcl_o             (dc_latches_br_info_br_xcl), \
    .latches_br_info_br_pred_taken_o      (dc_latches_br_info_br_pred_taken), \
    .latches_br_info_speculative_target_o (dc_latches_br_info_speculative_target), \
    .latches_rr_gp_o                      (dc_latches_rr_gp), \
    .latches_ld_vaddy_o                   (dc_latches_ld_vaddy), \
    .latches_seg0_limit_w_datasize_o      (dc_latches_seg0_limit_w_datasize), \
    .latches_seg0_limit_wo_datasize_o     (dc_latches_seg0_limit_wo_datasize), \
    .latches_next_ld_vaddy_o              (dc_latches_next_ld_vaddy), \
    .latches_ld_laddy_o                   (dc_latches_ld_laddy), \
    .latches_ld_stack_access_o            (dc_latches_ld_stack_access), \
    .latches_st_vaddy_o                   (dc_latches_st_vaddy), \
    .latches_seg1_limit_w_datasize_o      (dc_latches_seg1_limit_w_datasize), \
    .latches_seg1_limit_wo_datasize_o     (dc_latches_seg1_limit_wo_datasize), \
    .latches_next_st_vaddy_o              (dc_latches_next_st_vaddy), \
    .latches_st_laddy_o                   (dc_latches_st_laddy), \
    .latches_st_stack_access_o            (dc_latches_st_stack_access), \
    .latches_NEIP_o                       (dc_latches_NEIP), \
    .latches_EIP_o                        (dc_latches_EIP), \
    .latches_EAX_o                        (dc_latches_EAX), \
    .latches_imm64_o                      (dc_latches_imm64), \
    .latches_sr_id_o                      (dc_latches_sr_id), \
    .latches_sr_data_o                    (dc_latches_sr_data), \
    .latches_dr_id_o                      (dc_latches_dr_id), \
    .latches_dr_data_o                    (dc_latches_dr_data), \
    .latches_cs_datasize_0_o              (dc_latches_cs_datasize_0), \
    .latches_cs_datasize_1_o              (dc_latches_cs_datasize_1), \
    .latches_cs_datasize_2_o              (dc_latches_cs_datasize_2), \
    .latches_cs_LD_OP_0_o                 (dc_latches_cs_LD_OP_0), \
    .latches_cs_LD_OP_1_o                 (dc_latches_cs_LD_OP_1), \
    .latches_cs_LD_OP_2_o                 (dc_latches_cs_LD_OP_2), \
    .latches_cs_LD_OP_3_o                 (dc_latches_cs_LD_OP_3), \
    .latches_cs_ST_OP_0_o                 (dc_latches_cs_ST_OP_0), \
    .latches_valid_0_o                    (dc_latches_valid_0), \
    .latches_valid_1_o                    (dc_latches_valid_1), \
    .latches_valid_2_o                    (dc_latches_valid_2) \
);
