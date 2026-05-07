`define MEM_OUTPUTS \
wire exe_latches_next_valid; \
wire exe_latches_next_cs_ST_OP; \
wire [5:0]  exe_latches_next_cs_OP_TYPE; \
wire [4:0]  exe_latches_next_cs_alu_inputA_sel; \
wire [4:0]  exe_latches_next_cs_alu_inputB_sel; \
wire [4:0]  exe_latches_next_cs_branch_target_sel; \
wire exe_latches_next_cs_shift_by_one; \
wire exe_latches_next_cs_br_ucond; \
wire exe_latches_next_cs_relative_branch; \
wire exe_latches_next_cs_special_br; \
wire exe_latches_next_cs_is_far; \
wire exe_latches_next_cs_is_call; \
wire exe_latches_next_cs_second_flag_needed; \
wire exe_latches_next_cs_rep_no_zf_update; \
wire exe_latches_next_wb_cs_ST_OP; \
wire exe_latches_next_wb_cs_WB_DR; \
wire exe_latches_next_wb_cs_WB_SR; \
wire exe_latches_next_wb_cs_WB_EAX; \
wire [3:0] exe_latches_next_data_size_vec; \
wire [3:0] exe_latches_next_sr_data_size_vec; \
wire exe_latches_next_shift_sr_up; \
wire exe_latches_next_shift_sr_down; \
wire exe_latches_next_ST_XCL; \
wire [14:0] exe_latches_next_ST_PADDR_0; \
wire [14:0] exe_latches_next_ST_PADDR_1; \
wire exe_latches_next_MIO; \
wire exe_latches_next_br_info_valid; \
wire [31:0] exe_latches_next_br_info_br_eip; \
wire exe_latches_next_br_info_br_xcl; \
wire exe_latches_next_br_info_br_pred_taken; \
wire [31:0] exe_latches_next_br_info_speculative_target; \
wire [31:0] exe_latches_next_br_rel_target; \
wire [31:0] exe_latches_next_NEIP; \
wire [31:0] exe_latches_next_EIP; \
wire [31:0] exe_latches_next_EAX; \
wire [63:0] exe_latches_next_imm64; \
wire [255:0] exe_latches_next_ld_buf; \
wire [4:0] exe_latches_next_sr_id; \
wire [63:0] exe_latches_next_sr_data; \
wire [4:0] exe_latches_next_dr_id; \
wire [63:0] exe_latches_next_dr_data; \
wire [14:0] exe_latches_next_ld_addy; \
wire mem_outputs_valid; \
wire mem_outputs_stall; \
wire mem_outputs_ST_XCL; \
wire [14:0] mem_outputs_ST_PADDR_0; \
wire [14:0] mem_outputs_ST_PADDR_1; \
wire mem_outputs_ST_OP; \
wire mem_outputs_exe_stage_latch_we;
