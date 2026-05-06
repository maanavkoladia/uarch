`define RR_OUTPUTS


    // ---- rr_outputs_t : RR.outs_* (driven by RR) ----
    wire        rr_outputs_valid;
    wire        rr_outputs_stall;
    wire        rr_outputs_ecx_sb;
    wire [31:0] rr_outputs_ecx;
    wire [31:0] rr_outputs_eax;
    wire        rr_outputs_set_ZF_sb;
    wire        rr_outputs_codeSeg_sb;
    wire [31:0] rr_outputs_codeSeg_data;
    wire [31:0] rr_outputs_codeSeg_limit;
    wire        rr_outputs_dc_stage_latch_we;

    // regFileValues_o[NUM_REGS=26] -- one 64-bit wire per reg id
    wire [63:0] rr_outputs_regFileValues_0;    // CS
    wire [63:0] rr_outputs_regFileValues_1;    // DS
    wire [63:0] rr_outputs_regFileValues_2;    // SS
    wire [63:0] rr_outputs_regFileValues_3;    // ES
    wire [63:0] rr_outputs_regFileValues_4;    // FS
    wire [63:0] rr_outputs_regFileValues_5;    // GS
    wire [63:0] rr_outputs_regFileValues_6;    // EXPS
    wire [63:0] rr_outputs_regFileValues_7;    // EAX
    wire [63:0] rr_outputs_regFileValues_8;    // EBX
    wire [63:0] rr_outputs_regFileValues_9;    // ECX
    wire [63:0] rr_outputs_regFileValues_10;   // EDX
    wire [63:0] rr_outputs_regFileValues_11;   // ESI
    wire [63:0] rr_outputs_regFileValues_12;   // EDI
    wire [63:0] rr_outputs_regFileValues_13;   // ESP
    wire [63:0] rr_outputs_regFileValues_14;   // EBP
    wire [63:0] rr_outputs_regFileValues_15;   // MM0
    wire [63:0] rr_outputs_regFileValues_16;   // MM1
    wire [63:0] rr_outputs_regFileValues_17;   // MM2
    wire [63:0] rr_outputs_regFileValues_18;   // MM3
    wire [63:0] rr_outputs_regFileValues_19;   // MM4
    wire [63:0] rr_outputs_regFileValues_20;   // MM5
    wire [63:0] rr_outputs_regFileValues_21;   // MM6
    wire [63:0] rr_outputs_regFileValues_22;   // MM7
    wire [63:0] rr_outputs_regFileValues_23;   // ETR
    wire [63:0] rr_outputs_regFileValues_24;   // ERROR_REG
    wire [63:0] rr_outputs_regFileValues_25;   // NO_REG


    // ====================================================================
    // dc_latches_next : driven by RR, consumed by DC_Latches
    // ====================================================================
    wire        dc_latches_next_valid;

    // dc_cs_t (dc_latches_next.cs)
    wire        dc_latches_next_cs_LD_OP;
    wire        dc_latches_next_cs_ST_OP;
    wire        dc_latches_next_cs_dr_upper8;
    wire        dc_latches_next_cs_sr_upper8;
    wire [1:0]  dc_latches_next_cs_datasize;

    // mem_cs_t (dc_latches_next.mem_cs)
    wire        dc_latches_next_mem_cs_ST_OP;
    wire        dc_latches_next_mem_cs_LD_OP;

    // exe_cs_t (dc_latches_next.exe_cs)
    wire        dc_latches_next_exe_cs_ST_OP;
    wire [5:0]  dc_latches_next_exe_cs_OP_TYPE;
    wire [4:0]  dc_latches_next_exe_cs_alu_inputA_sel;
    wire [4:0]  dc_latches_next_exe_cs_alu_inputB_sel;
    wire [4:0]  dc_latches_next_exe_cs_branch_target_sel;
    wire        dc_latches_next_exe_cs_shift_by_one;
    wire        dc_latches_next_exe_cs_br_ucond;
    wire        dc_latches_next_exe_cs_relative_branch;
    wire        dc_latches_next_exe_cs_special_br;
    wire        dc_latches_next_exe_cs_is_far;
    wire        dc_latches_next_exe_cs_is_call;
    wire        dc_latches_next_exe_cs_second_flag_needed;
    wire        dc_latches_next_exe_cs_rep_no_zf_update;

    // wb_cs_t (dc_latches_next.wb_cs)
    wire        dc_latches_next_wb_cs_ST_OP;
    wire        dc_latches_next_wb_cs_WB_DR;
    wire        dc_latches_next_wb_cs_WB_SR;
    wire        dc_latches_next_wb_cs_WB_EAX;

    // br_info_t (dc_latches_next.br_info)
    wire        dc_latches_next_br_info_valid;
    wire [31:0] dc_latches_next_br_info_br_eip;
    wire        dc_latches_next_br_info_br_xcl;
    wire        dc_latches_next_br_info_br_pred_taken;
    wire [31:0] dc_latches_next_br_info_speculative_target;

    wire        dc_latches_next_rr_gp;

    // load-side address / segmentation
    wire [31:0] dc_latches_next_ld_vaddy;
    wire [31:0] dc_latches_next_seg0_limit_w_datasize;
    wire [31:0] dc_latches_next_seg0_limit_wo_datasize;
    wire [31:0] dc_latches_next_next_ld_vaddy;
    wire [31:0] dc_latches_next_ld_laddy;
    wire        dc_latches_next_ld_stack_access;

    // store-side address / segmentation
    wire [31:0] dc_latches_next_st_vaddy;
    wire [31:0] dc_latches_next_seg1_limit_w_datasize;
    wire [31:0] dc_latches_next_seg1_limit_wo_datasize;
    wire [31:0] dc_latches_next_next_st_vaddy;
    wire [31:0] dc_latches_next_st_laddy;
    wire        dc_latches_next_st_stack_access;

    // pipeline data
    wire [31:0] dc_latches_next_NEIP;
    wire [31:0] dc_latches_next_EIP;
    wire [31:0] dc_latches_next_EAX;
    wire [63:0] dc_latches_next_imm64;

    // operand reg ids / data
    wire [4:0]  dc_latches_next_sr_id;
    wire [63:0] dc_latches_next_sr_data;
    wire [4:0]  dc_latches_next_dr_id;
    wire [63:0] dc_latches_next_dr_data;
