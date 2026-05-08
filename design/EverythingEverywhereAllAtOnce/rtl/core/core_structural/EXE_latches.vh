`define EXE_LATCHES \
wire        exe_latches_valid; \
wire        exe_latches_cs_ST_OP; \
wire [5:0]  exe_latches_cs_OP_TYPE; \
wire [4:0]  exe_latches_cs_alu_inputA_sel; \
wire [4:0]  exe_latches_cs_alu_inputA_sel_b; \
wire [4:0]  exe_latches_cs_alu_inputA_sel_c; \
wire [4:0]  exe_latches_cs_alu_inputB_sel; \
wire [4:0]  exe_latches_cs_alu_inputB_sel_b; \
wire [4:0]  exe_latches_cs_alu_inputB_sel_c; \
wire [4:0]  exe_latches_cs_branch_target_sel; \
wire [4:0]  exe_latches_cs_branch_target_sel_b; \
wire [4:0]  exe_latches_cs_branch_target_sel_c; \
wire        exe_latches_shift_sr_up_b; \
wire        exe_latches_shift_sr_up_c; \
wire        exe_latches_shift_sr_down_b; \
wire        exe_latches_shift_sr_down_c; \
wire [14:0] exe_latches_ST_PADDR_0_b; \
wire [14:0] exe_latches_ST_PADDR_0_c; \
wire [4:0]  exe_latches_sr_id_b; \
wire [4:0]  exe_latches_sr_id_c; \
wire [4:0]  exe_latches_dr_id_b; \
wire [4:0]  exe_latches_dr_id_c; \
wire [14:0] exe_latches_ld_addy_b; \
wire [14:0] exe_latches_ld_addy_c; \
wire        exe_latches_cs_shift_by_one; \
wire        exe_latches_cs_br_ucond; \
wire        exe_latches_cs_relative_branch; \
wire        exe_latches_cs_special_br; \
wire        exe_latches_cs_is_far; \
wire        exe_latches_cs_is_call; \
wire        exe_latches_cs_second_flag_needed; \
wire        exe_latches_cs_rep_no_zf_update; \
wire        exe_latches_wb_cs_ST_OP; \
wire        exe_latches_wb_cs_WB_DR; \
wire        exe_latches_wb_cs_WB_SR; \
wire        exe_latches_wb_cs_WB_EAX; \
wire [3:0]  exe_latches_data_size_vec; \
wire [3:0]  exe_latches_sr_data_size_vec; \
wire        exe_latches_shift_sr_up; \
wire        exe_latches_shift_sr_down; \
wire        exe_latches_ST_XCL; \
wire [14:0] exe_latches_ST_PADDR_0; \
wire [14:0] exe_latches_ST_PADDR_1; \
wire        exe_latches_MIO; \
wire        exe_latches_br_info_valid; \
wire [31:0] exe_latches_br_info_br_eip; \
wire        exe_latches_br_info_br_xcl; \
wire        exe_latches_br_info_br_pred_taken; \
wire [31:0] exe_latches_br_info_speculative_target; \
wire [31:0] exe_latches_br_rel_target; \
wire [31:0] exe_latches_NEIP; \
wire [31:0] exe_latches_EIP; \
wire [31:0] exe_latches_EAX; \
wire [63:0] exe_latches_imm64; \
wire [255:0] exe_latches_ld_buf; \
wire [255:0] exe_latches_ld_buf_b; \
wire [255:0] exe_latches_ld_buf_c; \
wire [4:0]  exe_latches_sr_id; \
wire [63:0] exe_latches_sr_data; \
wire [4:0]  exe_latches_dr_id; \
wire [63:0] exe_latches_dr_data; \
wire [14:0] exe_latches_ld_addy; \
EXE_Latches exe_latches_unit ( \
    .clk            (clk), \
    .rst            (rst), \
    .write_enable_n_i (mem_outputs_exe_stage_latch_we_n), \
    .flush          (exe_outputs_br_res_flush), \
    .nextLatches_valid_i                       (exe_latches_next_valid), \
    .nextLatches_cs_ST_OP_i                    (exe_latches_next_cs_ST_OP), \
    .nextLatches_cs_OP_TYPE_i                  (exe_latches_next_cs_OP_TYPE), \
    .nextLatches_cs_alu_inputA_sel_i           (exe_latches_next_cs_alu_inputA_sel), \
    .nextLatches_cs_alu_inputB_sel_i           (exe_latches_next_cs_alu_inputB_sel), \
    .nextLatches_cs_branch_target_sel_i        (exe_latches_next_cs_branch_target_sel), \
    .nextLatches_cs_shift_by_one_i             (exe_latches_next_cs_shift_by_one), \
    .nextLatches_cs_br_ucond_i                 (exe_latches_next_cs_br_ucond), \
    .nextLatches_cs_relative_branch_i          (exe_latches_next_cs_relative_branch), \
    .nextLatches_cs_special_br_i               (exe_latches_next_cs_special_br), \
    .nextLatches_cs_is_far_i                   (exe_latches_next_cs_is_far), \
    .nextLatches_cs_is_call_i                  (exe_latches_next_cs_is_call), \
    .nextLatches_cs_second_flag_needed_i       (exe_latches_next_cs_second_flag_needed), \
    .nextLatches_cs_rep_no_zf_update_i         (exe_latches_next_cs_rep_no_zf_update), \
    .nextLatches_wb_cs_ST_OP_i                 (exe_latches_next_wb_cs_ST_OP), \
    .nextLatches_wb_cs_WB_DR_i                 (exe_latches_next_wb_cs_WB_DR), \
    .nextLatches_wb_cs_WB_SR_i                 (exe_latches_next_wb_cs_WB_SR), \
    .nextLatches_wb_cs_WB_EAX_i                (exe_latches_next_wb_cs_WB_EAX), \
    .nextLatches_data_size_vec_i               (exe_latches_next_data_size_vec), \
    .nextLatches_sr_data_size_vec_i            (exe_latches_next_sr_data_size_vec), \
    .nextLatches_shift_sr_up_i                 (exe_latches_next_shift_sr_up), \
    .nextLatches_shift_sr_down_i               (exe_latches_next_shift_sr_down), \
    .nextLatches_ST_XCL_i                      (exe_latches_next_ST_XCL), \
    .nextLatches_ST_PADDR_0_i                  (mem_latches_ST_PADDR_0_to_exe), \
    .nextLatches_ST_PADDR_1_i                  (exe_latches_next_ST_PADDR_1), \
    .nextLatches_MIO_i                         (exe_latches_next_MIO), \
    .nextLatches_br_info_valid_i               (exe_latches_next_br_info_valid), \
    .nextLatches_br_info_br_eip_i              (exe_latches_next_br_info_br_eip), \
    .nextLatches_br_info_br_xcl_i              (exe_latches_next_br_info_br_xcl), \
    .nextLatches_br_info_br_pred_taken_i       (exe_latches_next_br_info_br_pred_taken), \
    .nextLatches_br_info_speculative_target_i  (exe_latches_next_br_info_speculative_target), \
    .nextLatches_br_rel_target_i               (exe_latches_next_br_rel_target), \
    .nextLatches_NEIP_i                        (exe_latches_next_NEIP), \
    .nextLatches_EIP_i                         (exe_latches_next_EIP), \
    .nextLatches_EAX_i                         (exe_latches_next_EAX), \
    .nextLatches_imm64_i                       (exe_latches_next_imm64), \
    .nextLatches_ld_buf_i                      (exe_latches_next_ld_buf), \
    .nextLatches_sr_id_i                       (exe_latches_next_sr_id), \
    .nextLatches_sr_data_i                     (exe_latches_next_sr_data), \
    .nextLatches_dr_id_i                       (exe_latches_next_dr_id), \
    .nextLatches_dr_data_i                     (exe_latches_next_dr_data), \
    .nextLatches_ld_addy_i                     (exe_latches_next_ld_addy), \
    .latches_valid_o                           (exe_latches_valid), \
    .latches_cs_ST_OP_o                        (exe_latches_cs_ST_OP), \
    .latches_cs_OP_TYPE_o                      (exe_latches_cs_OP_TYPE), \
    .latches_cs_alu_inputA_sel_o               (exe_latches_cs_alu_inputA_sel), \
    .latches_cs_alu_inputA_sel_b_o             (exe_latches_cs_alu_inputA_sel_b), \
    .latches_cs_alu_inputA_sel_c_o             (exe_latches_cs_alu_inputA_sel_c), \
    .latches_cs_alu_inputB_sel_o               (exe_latches_cs_alu_inputB_sel), \
    .latches_cs_alu_inputB_sel_b_o             (exe_latches_cs_alu_inputB_sel_b), \
    .latches_cs_alu_inputB_sel_c_o             (exe_latches_cs_alu_inputB_sel_c), \
    .latches_cs_branch_target_sel_o            (exe_latches_cs_branch_target_sel), \
    .latches_cs_branch_target_sel_b_o          (exe_latches_cs_branch_target_sel_b), \
    .latches_cs_branch_target_sel_c_o          (exe_latches_cs_branch_target_sel_c), \
    .latches_cs_shift_by_one_o                 (exe_latches_cs_shift_by_one), \
    .latches_cs_br_ucond_o                     (exe_latches_cs_br_ucond), \
    .latches_cs_relative_branch_o              (exe_latches_cs_relative_branch), \
    .latches_cs_special_br_o                   (exe_latches_cs_special_br), \
    .latches_cs_is_far_o                       (exe_latches_cs_is_far), \
    .latches_cs_is_call_o                      (exe_latches_cs_is_call), \
    .latches_cs_second_flag_needed_o           (exe_latches_cs_second_flag_needed), \
    .latches_cs_rep_no_zf_update_o             (exe_latches_cs_rep_no_zf_update), \
    .latches_wb_cs_ST_OP_o                     (exe_latches_wb_cs_ST_OP), \
    .latches_wb_cs_WB_DR_o                     (exe_latches_wb_cs_WB_DR), \
    .latches_wb_cs_WB_SR_o                     (exe_latches_wb_cs_WB_SR), \
    .latches_wb_cs_WB_EAX_o                    (exe_latches_wb_cs_WB_EAX), \
    .latches_data_size_vec_o                   (exe_latches_data_size_vec), \
    .latches_sr_data_size_vec_o                (exe_latches_sr_data_size_vec), \
    .latches_shift_sr_up_o                     (exe_latches_shift_sr_up), \
    .latches_shift_sr_up_b_o                   (exe_latches_shift_sr_up_b), \
    .latches_shift_sr_up_c_o                   (exe_latches_shift_sr_up_c), \
    .latches_shift_sr_down_o                   (exe_latches_shift_sr_down), \
    .latches_shift_sr_down_b_o                 (exe_latches_shift_sr_down_b), \
    .latches_shift_sr_down_c_o                 (exe_latches_shift_sr_down_c), \
    .latches_ST_XCL_o                          (exe_latches_ST_XCL), \
    .latches_ST_PADDR_0_o                      (exe_latches_ST_PADDR_0), \
    .latches_ST_PADDR_0_b_o                    (exe_latches_ST_PADDR_0_b), \
    .latches_ST_PADDR_0_c_o                    (exe_latches_ST_PADDR_0_c), \
    .latches_ST_PADDR_1_o                      (exe_latches_ST_PADDR_1), \
    .latches_MIO_o                             (exe_latches_MIO), \
    .latches_br_info_valid_o                   (exe_latches_br_info_valid), \
    .latches_br_info_br_eip_o                  (exe_latches_br_info_br_eip), \
    .latches_br_info_br_xcl_o                  (exe_latches_br_info_br_xcl), \
    .latches_br_info_br_pred_taken_o           (exe_latches_br_info_br_pred_taken), \
    .latches_br_info_speculative_target_o      (exe_latches_br_info_speculative_target), \
    .latches_br_rel_target_o                   (exe_latches_br_rel_target), \
    .latches_NEIP_o                            (exe_latches_NEIP), \
    .latches_EIP_o                             (exe_latches_EIP), \
    .latches_EAX_o                             (exe_latches_EAX), \
    .latches_imm64_o                           (exe_latches_imm64), \
    .latches_ld_buf_o                          (exe_latches_ld_buf), \
    .latches_ld_buf_b_o                        (exe_latches_ld_buf_b), \
    .latches_ld_buf_c_o                        (exe_latches_ld_buf_c), \
    .latches_sr_id_o                           (exe_latches_sr_id), \
    .latches_sr_id_b_o                         (exe_latches_sr_id_b), \
    .latches_sr_id_c_o                         (exe_latches_sr_id_c), \
    .latches_sr_data_o                         (exe_latches_sr_data), \
    .latches_dr_id_o                           (exe_latches_dr_id), \
    .latches_dr_id_b_o                         (exe_latches_dr_id_b), \
    .latches_dr_id_c_o                         (exe_latches_dr_id_c), \
    .latches_dr_data_o                         (exe_latches_dr_data), \
    .latches_ld_addy_o                         (exe_latches_ld_addy), \
    .latches_ld_addy_b_o                       (exe_latches_ld_addy_b), \
    .latches_ld_addy_c_o                       (exe_latches_ld_addy_c) \
);
