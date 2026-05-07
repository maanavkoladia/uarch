`define MEM_LATCHES \
wire        mem_latches_valid; \
wire        mem_latches_cs_ST_OP; \
wire        mem_latches_cs_LD_OP; \
wire        mem_latches_exe_cs_ST_OP; \
wire [5:0]  mem_latches_exe_cs_OP_TYPE; \
wire [4:0]  mem_latches_exe_cs_alu_inputA_sel; \
wire [4:0]  mem_latches_exe_cs_alu_inputB_sel; \
wire [4:0]  mem_latches_exe_cs_branch_target_sel; \
wire        mem_latches_exe_cs_shift_by_one; \
wire        mem_latches_exe_cs_br_ucond; \
wire        mem_latches_exe_cs_relative_branch; \
wire        mem_latches_exe_cs_special_br; \
wire        mem_latches_exe_cs_is_far; \
wire        mem_latches_exe_cs_is_call; \
wire        mem_latches_exe_cs_second_flag_needed; \
wire        mem_latches_exe_cs_rep_no_zf_update; \
wire        mem_latches_wb_cs_ST_OP; \
wire        mem_latches_wb_cs_WB_DR; \
wire        mem_latches_wb_cs_WB_SR; \
wire        mem_latches_wb_cs_WB_EAX; \
wire        mem_latches_br_info_valid; \
wire [31:0] mem_latches_br_info_br_eip; \
wire        mem_latches_br_info_br_xcl; \
wire        mem_latches_br_info_br_pred_taken; \
wire [31:0] mem_latches_br_info_speculative_target; \
wire [3:0]  mem_latches_data_size_vec; \
wire [3:0]  mem_latches_sr_data_size_vec; \
wire        mem_latches_shift_sr_up; \
wire        mem_latches_shift_sr_down; \
wire        mem_latches_ST_XCL; \
wire [14:0] mem_latches_ST_PADDR_0; \
wire [14:0] mem_latches_ST_PADDR_1; \
wire        mem_latches_MIO; \
wire [31:0] mem_latches_NEIP; \
wire [31:0] mem_latches_EIP; \
wire [31:0] mem_latches_EAX; \
wire [63:0] mem_latches_imm64; \
wire [4:0]  mem_latches_sr_id; \
wire [63:0] mem_latches_sr_data; \
wire [4:0]  mem_latches_dr_id; \
wire [63:0] mem_latches_dr_data; \
wire        mem_latches_LD_XCL; \
wire        mem_latches_swapLines; \
wire [14:0] mem_latches_LD_PADDR_0; \
wire [14:0] mem_latches_LD_PADDR_1; \
MEM_Latches mem_latches_unit ( \
    .clk            (clk), \
    .rst            (rst), \
    .write_enable_i (dc_outputs_mem_stage_latch_we), \
    .flush          (exe_outputs_br_res_flush), \
    .farFlush       (exe_outputs_br_res_farFlush), \
    .nextLatches_valid_i                       (mem_latches_next_valid), \
    .nextLatches_cs_ST_OP_i                    (mem_latches_next_cs_ST_OP), \
    .nextLatches_cs_LD_OP_i                    (mem_latches_next_cs_LD_OP), \
    .nextLatches_exe_cs_ST_OP_i                (mem_latches_next_exe_cs_ST_OP), \
    .nextLatches_exe_cs_OP_TYPE_i              (mem_latches_next_exe_cs_OP_TYPE), \
    .nextLatches_exe_cs_alu_inputA_sel_i       (mem_latches_next_exe_cs_alu_inputA_sel), \
    .nextLatches_exe_cs_alu_inputB_sel_i       (mem_latches_next_exe_cs_alu_inputB_sel), \
    .nextLatches_exe_cs_branch_target_sel_i    (mem_latches_next_exe_cs_branch_target_sel), \
    .nextLatches_exe_cs_shift_by_one_i         (mem_latches_next_exe_cs_shift_by_one), \
    .nextLatches_exe_cs_br_ucond_i             (mem_latches_next_exe_cs_br_ucond), \
    .nextLatches_exe_cs_relative_branch_i      (mem_latches_next_exe_cs_relative_branch), \
    .nextLatches_exe_cs_special_br_i           (mem_latches_next_exe_cs_special_br), \
    .nextLatches_exe_cs_is_far_i               (mem_latches_next_exe_cs_is_far), \
    .nextLatches_exe_cs_is_call_i              (mem_latches_next_exe_cs_is_call), \
    .nextLatches_exe_cs_second_flag_needed_i   (mem_latches_next_exe_cs_second_flag_needed), \
    .nextLatches_exe_cs_rep_no_zf_update_i     (mem_latches_next_exe_cs_rep_no_zf_update), \
    .nextLatches_wb_cs_ST_OP_i                 (mem_latches_next_wb_cs_ST_OP), \
    .nextLatches_wb_cs_WB_DR_i                 (mem_latches_next_wb_cs_WB_DR), \
    .nextLatches_wb_cs_WB_SR_i                 (mem_latches_next_wb_cs_WB_SR), \
    .nextLatches_wb_cs_WB_EAX_i                (mem_latches_next_wb_cs_WB_EAX), \
    .nextLatches_br_info_valid_i               (mem_latches_next_br_info_valid), \
    .nextLatches_br_info_br_eip_i              (mem_latches_next_br_info_br_eip), \
    .nextLatches_br_info_br_xcl_i              (mem_latches_next_br_info_br_xcl), \
    .nextLatches_br_info_br_pred_taken_i       (mem_latches_next_br_info_br_pred_taken), \
    .nextLatches_br_info_speculative_target_i  (mem_latches_next_br_info_speculative_target), \
    .nextLatches_data_size_vec_i               (mem_latches_next_data_size_vec), \
    .nextLatches_sr_data_size_vec_i            (mem_latches_next_sr_data_size_vec), \
    .nextLatches_shift_sr_up_i                 (mem_latches_next_shift_sr_up), \
    .nextLatches_shift_sr_down_i               (mem_latches_next_shift_sr_down), \
    .nextLatches_ST_XCL_i                      (mem_latches_next_ST_XCL), \
    .nextLatches_ST_PADDR_0_i                  (mem_latches_next_ST_PADDR_0), \
    .nextLatches_ST_PADDR_1_i                  (mem_latches_next_ST_PADDR_1), \
    .nextLatches_MIO_i                         (mem_latches_next_MIO), \
    .nextLatches_NEIP_i                        (mem_latches_next_NEIP), \
    .nextLatches_EIP_i                         (mem_latches_next_EIP), \
    .nextLatches_EAX_i                         (mem_latches_next_EAX), \
    .nextLatches_imm64_i                       (mem_latches_next_imm64), \
    .nextLatches_sr_id_i                       (mem_latches_next_sr_id), \
    .nextLatches_sr_data_i                     (mem_latches_next_sr_data), \
    .nextLatches_dr_id_i                       (mem_latches_next_dr_id), \
    .nextLatches_dr_data_i                     (mem_latches_next_dr_data), \
    .nextLatches_LD_XCL_i                      (mem_latches_next_LD_XCL), \
    .nextLatches_swapLines_i                   (mem_latches_next_swapLines), \
    .nextLatches_LD_PADDR_0_i                  (mem_latches_next_LD_PADDR_0), \
    .nextLatches_LD_PADDR_1_i                  (mem_latches_next_LD_PADDR_1), \
    .latches_valid_o                           (mem_latches_valid), \
    .latches_cs_ST_OP_o                        (mem_latches_cs_ST_OP), \
    .latches_cs_LD_OP_o                        (mem_latches_cs_LD_OP), \
    .latches_exe_cs_ST_OP_o                    (mem_latches_exe_cs_ST_OP), \
    .latches_exe_cs_OP_TYPE_o                  (mem_latches_exe_cs_OP_TYPE), \
    .latches_exe_cs_alu_inputA_sel_o           (mem_latches_exe_cs_alu_inputA_sel), \
    .latches_exe_cs_alu_inputB_sel_o           (mem_latches_exe_cs_alu_inputB_sel), \
    .latches_exe_cs_branch_target_sel_o        (mem_latches_exe_cs_branch_target_sel), \
    .latches_exe_cs_shift_by_one_o             (mem_latches_exe_cs_shift_by_one), \
    .latches_exe_cs_br_ucond_o                 (mem_latches_exe_cs_br_ucond), \
    .latches_exe_cs_relative_branch_o          (mem_latches_exe_cs_relative_branch), \
    .latches_exe_cs_special_br_o               (mem_latches_exe_cs_special_br), \
    .latches_exe_cs_is_far_o                   (mem_latches_exe_cs_is_far), \
    .latches_exe_cs_is_call_o                  (mem_latches_exe_cs_is_call), \
    .latches_exe_cs_second_flag_needed_o       (mem_latches_exe_cs_second_flag_needed), \
    .latches_exe_cs_rep_no_zf_update_o         (mem_latches_exe_cs_rep_no_zf_update), \
    .latches_wb_cs_ST_OP_o                     (mem_latches_wb_cs_ST_OP), \
    .latches_wb_cs_WB_DR_o                     (mem_latches_wb_cs_WB_DR), \
    .latches_wb_cs_WB_SR_o                     (mem_latches_wb_cs_WB_SR), \
    .latches_wb_cs_WB_EAX_o                    (mem_latches_wb_cs_WB_EAX), \
    .latches_br_info_valid_o                   (mem_latches_br_info_valid), \
    .latches_br_info_br_eip_o                  (mem_latches_br_info_br_eip), \
    .latches_br_info_br_xcl_o                  (mem_latches_br_info_br_xcl), \
    .latches_br_info_br_pred_taken_o           (mem_latches_br_info_br_pred_taken), \
    .latches_br_info_speculative_target_o      (mem_latches_br_info_speculative_target), \
    .latches_data_size_vec_o                   (mem_latches_data_size_vec), \
    .latches_sr_data_size_vec_o                (mem_latches_sr_data_size_vec), \
    .latches_shift_sr_up_o                     (mem_latches_shift_sr_up), \
    .latches_shift_sr_down_o                   (mem_latches_shift_sr_down), \
    .latches_ST_XCL_o                          (mem_latches_ST_XCL), \
    .latches_ST_PADDR_0_o                      (mem_latches_ST_PADDR_0), \
    .latches_ST_PADDR_1_o                      (mem_latches_ST_PADDR_1), \
    .latches_MIO_o                             (mem_latches_MIO), \
    .latches_NEIP_o                            (mem_latches_NEIP), \
    .latches_EIP_o                             (mem_latches_EIP), \
    .latches_EAX_o                             (mem_latches_EAX), \
    .latches_imm64_o                           (mem_latches_imm64), \
    .latches_sr_id_o                           (mem_latches_sr_id), \
    .latches_sr_data_o                         (mem_latches_sr_data), \
    .latches_dr_id_o                           (mem_latches_dr_id), \
    .latches_dr_data_o                         (mem_latches_dr_data), \
    .latches_LD_XCL_o                          (mem_latches_LD_XCL), \
    .latches_swapLines_o                       (mem_latches_swapLines), \
    .latches_LD_PADDR_0_o                      (mem_latches_LD_PADDR_0), \
    .latches_LD_PADDR_1_o                      (mem_latches_LD_PADDR_1) \
);
