`define EXE_OUTPUTS \
wire wb_latches_next_valid; \
wire wb_latches_next_cs_ST_OP; \
wire wb_latches_next_cs_WB_DR; \
wire wb_latches_next_cs_WB_SR; \
wire wb_latches_next_cs_WB_EAX; \
wire wb_latches_next_ST_XCL; \
wire [14:0] wb_latches_next_ST_PADDR_0; \
wire [15:0] wb_latches_next_ST_BIT_VEC_0; \
wire [14:0] wb_latches_next_ST_PADDR_1; \
wire [15:0] wb_latches_next_ST_BIT_VEC_1; \
wire wb_latches_next_MIO; \
wire [31:0] wb_latches_next_EIP; \
wire [255:0] wb_latches_next_res_buf; \
wire [4:0] wb_latches_next_sr_id; \
wire [63:0] wb_latches_next_sr_data; \
wire [4:0] wb_latches_next_dr_id; \
wire [63:0] wb_latches_next_dr_data; \
wire [31:0] wb_latches_next_EAX; \
wire exe_outputs_valid; \
wire exe_outputs_br_res_valid_decode; \
wire exe_outputs_br_res_valid_btb; \
wire exe_outputs_br_res_valid_pred; \
wire exe_outputs_br_res_valid_fetch; \
wire exe_outputs_br_res_flush_decode; \
wire exe_outputs_br_res_flush_fetch; \
wire exe_outputs_br_res_flush_dc; \
wire exe_outputs_br_res_flush_mem; \
wire exe_outputs_br_res_flush_rr; \
wire exe_outputs_br_res_flush_exe_latches; \
wire exe_outputs_br_res_farFlush; \
wire exe_outputs_br_res_callFlush; \
wire exe_outputs_br_res_miss_prediction_pred; \
wire [31:0] exe_outputs_br_res_br_eip; \
wire [31:0] exe_outputs_br_res_neip; \
wire [31:0] exe_outputs_br_res_br_target; \
wire exe_outputs_br_res_taken; \
wire exe_outputs_br_res_br_XCL; \
wire exe_outputs_br_res_clr_exp_mode; \
wire exe_outputs_br_res_br_ucond; \
wire exe_outputs_DR_0_we; \
wire [4:0] exe_outputs_DR_0_id; \
wire [63:0] exe_outputs_DR_0_data; \
wire exe_outputs_DR_1_we; \
wire [4:0] exe_outputs_DR_1_id; \
wire [63:0] exe_outputs_DR_1_data; \
wire exe_outputs_clr_ZF_sb; \
wire exe_outputs_ZF; \
wire exe_outputs_ST_OP; \
wire exe_outputs_ST_XCL; \
wire [14:0] exe_outputs_ST_PADDR_0; \
wire [14:0] exe_outputs_ST_PADDR_1; \
wire exe_outputs_wb_stage_latch_we;
