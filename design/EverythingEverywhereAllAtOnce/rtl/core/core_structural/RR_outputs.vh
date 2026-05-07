`define RR_OUTPUTS \
    wire        rr_outputs_valid; \
    wire        rr_outputs_stall; \
    wire        rr_outputs_ecx_sb; \
    wire [31:0] rr_outputs_ecx; \
    wire [31:0] rr_outputs_eax; \
    wire        rr_outputs_set_ZF_sb; \
    wire        rr_outputs_codeSeg_sb; \
    wire [31:0] rr_outputs_codeSeg_data; \
    wire [31:0] rr_outputs_codeSeg_limit; \
    wire        rr_outputs_dc_stage_latch_we; \
    wire [63:0] rr_outputs_regFileValues_0; \
    wire [63:0] rr_outputs_regFileValues_1; \
    wire [63:0] rr_outputs_regFileValues_2; \
    wire [63:0] rr_outputs_regFileValues_3; \
    wire [63:0] rr_outputs_regFileValues_4; \
    wire [63:0] rr_outputs_regFileValues_5; \
    wire [63:0] rr_outputs_regFileValues_6; \
    wire [63:0] rr_outputs_regFileValues_7; \
    wire [63:0] rr_outputs_regFileValues_8; \
    wire [63:0] rr_outputs_regFileValues_9; \
    wire [63:0] rr_outputs_regFileValues_10; \
    wire [63:0] rr_outputs_regFileValues_11; \
    wire [63:0] rr_outputs_regFileValues_12; \
    wire [63:0] rr_outputs_regFileValues_13; \
    wire [63:0] rr_outputs_regFileValues_14; \
    wire [63:0] rr_outputs_regFileValues_15; \
    wire [63:0] rr_outputs_regFileValues_16; \
    wire [63:0] rr_outputs_regFileValues_17; \
    wire [63:0] rr_outputs_regFileValues_18; \
    wire [63:0] rr_outputs_regFileValues_19; \
    wire [63:0] rr_outputs_regFileValues_20; \
    wire [63:0] rr_outputs_regFileValues_21; \
    wire [63:0] rr_outputs_regFileValues_22; \
    wire [63:0] rr_outputs_regFileValues_23; \
    wire [63:0] rr_outputs_regFileValues_24; \
    wire [63:0] rr_outputs_regFileValues_25; \
    wire        dc_latches_next_valid; \
    wire        dc_latches_next_cs_LD_OP; \
    wire        dc_latches_next_cs_ST_OP; \
    wire        dc_latches_next_cs_dr_upper8; \
    wire        dc_latches_next_cs_sr_upper8; \
    wire [1:0]  dc_latches_next_cs_datasize; \
    wire        dc_latches_next_mem_cs_ST_OP; \
    wire        dc_latches_next_mem_cs_LD_OP; \
    wire        dc_latches_next_exe_cs_ST_OP; \
    wire [5:0]  dc_latches_next_exe_cs_OP_TYPE; \
    wire [4:0]  dc_latches_next_exe_cs_alu_inputA_sel; \
    wire [4:0]  dc_latches_next_exe_cs_alu_inputB_sel; \
    wire [4:0]  dc_latches_next_exe_cs_branch_target_sel; \
    wire        dc_latches_next_exe_cs_shift_by_one; \
    wire        dc_latches_next_exe_cs_br_ucond; \
    wire        dc_latches_next_exe_cs_relative_branch; \
    wire        dc_latches_next_exe_cs_special_br; \
    wire        dc_latches_next_exe_cs_is_far; \
    wire        dc_latches_next_exe_cs_is_call; \
    wire        dc_latches_next_exe_cs_second_flag_needed; \
    wire        dc_latches_next_exe_cs_rep_no_zf_update; \
    wire        dc_latches_next_wb_cs_ST_OP; \
    wire        dc_latches_next_wb_cs_WB_DR; \
    wire        dc_latches_next_wb_cs_WB_SR; \
    wire        dc_latches_next_wb_cs_WB_EAX; \
    wire        dc_latches_next_br_info_valid; \
    wire [31:0] dc_latches_next_br_info_br_eip; \
    wire        dc_latches_next_br_info_br_xcl; \
    wire        dc_latches_next_br_info_br_pred_taken; \
    wire [31:0] dc_latches_next_br_info_speculative_target; \
    wire        dc_latches_next_rr_gp; \
    wire [31:0] _dc_latches_next_ld_vaddy_; \
    wire [31:0] dc_latches_next_seg0_limit_w_datasize; \
    wire [31:0] dc_latches_next_seg0_limit_wo_datasize; \
    wire [31:0] dc_latches_next_next_ld_vaddy; \
    wire [31:0] dc_latches_next_ld_laddy; \
    wire        dc_latches_next_ld_stack_access; \
    wire [31:0] _dc_latches_next_st_vaddy_; \
    wire [31:0] dc_latches_next_seg1_limit_w_datasize; \
    wire [31:0] dc_latches_next_seg1_limit_wo_datasize; \
    wire [31:0] dc_latches_next_next_st_vaddy; \
    wire [31:0] dc_latches_next_st_laddy; \
    wire        dc_latches_next_st_stack_access; \
    wire [31:0] dc_latches_next_NEIP; \
    wire [31:0] dc_latches_next_EIP; \
    wire [31:0] dc_latches_next_EAX; \
    wire [63:0] dc_latches_next_imm64; \
    wire [4:0]  dc_latches_next_sr_id; \
    wire [63:0] dc_latches_next_sr_data; \
    wire [4:0]  dc_latches_next_dr_id; \
    wire [63:0] dc_latches_next_dr_data;
