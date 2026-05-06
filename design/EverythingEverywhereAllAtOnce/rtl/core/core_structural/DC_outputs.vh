`define DC_OUTPUTS

    wire        mem_latches_next_valid;
    wire        mem_latches_next_cs_ST_OP;
    wire        mem_latches_next_cs_LD_OP;
    wire        mem_latches_next_exe_cs_ST_OP;
    wire [31:0] mem_latches_next_exe_cs_OP_TYPE;
    wire [31:0] mem_latches_next_exe_cs_alu_inputA_sel;
    wire [31:0] mem_latches_next_exe_cs_alu_inputB_sel;
    wire [31:0] mem_latches_next_exe_cs_branch_target_sel;
    wire        mem_latches_next_exe_cs_shift_by_one;
    wire        mem_latches_next_exe_cs_br_ucond;
    wire        mem_latches_next_exe_cs_relative_branch;
    wire        mem_latches_next_exe_cs_special_br;
    wire        mem_latches_next_exe_cs_is_far;
    wire        mem_latches_next_exe_cs_is_call;
    wire        mem_latches_next_exe_cs_second_flag_needed;
    wire        mem_latches_next_exe_cs_rep_no_zf_update;
    wire        mem_latches_next_wb_cs_ST_OP;
    wire        mem_latches_next_wb_cs_WB_DR;
    wire        mem_latches_next_wb_cs_WB_SR;
    wire        mem_latches_next_wb_cs_WB_EAX;
    wire        mem_latches_next_br_info_valid;
    wire [31:0] mem_latches_next_br_info_br_eip;
    wire        mem_latches_next_br_info_br_xcl;
    wire        mem_latches_next_br_info_br_pred_taken;
    wire [31:0] mem_latches_next_br_info_speculative_target;
    wire [3:0]  mem_latches_next_data_size_vec;
    wire [3:0]  mem_latches_next_sr_data_size_vec;
    wire        mem_latches_next_shift_sr_up;
    wire        mem_latches_next_shift_sr_down;
    wire        mem_latches_next_ST_XCL;
    wire [14:0] mem_latches_next_ST_PADDR_0;
    wire [14:0] mem_latches_next_ST_PADDR_1;
    wire        mem_latches_next_MIO;
    wire [31:0] mem_latches_next_NEIP;
    wire [31:0] mem_latches_next_EIP;
    wire [31:0] mem_latches_next_EAX;
    wire [63:0] mem_latches_next_imm64;
    wire [4:0]  mem_latches_next_sr_id;
    wire [63:0] mem_latches_next_sr_data;
    wire [4:0]  mem_latches_next_dr_id;
    wire [63:0] mem_latches_next_dr_data;
    wire        mem_latches_next_LD_XCL;
    wire        mem_latches_next_swapLines;
    wire [14:0] mem_latches_next_LD_PADDR_0;
    wire [14:0] mem_latches_next_LD_PADDR_1;


