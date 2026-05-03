module control_store (
    input wire invalid_inst,
    input wire [9:0] total_pf_vector,
    input wire [7:0] opcode,
    input wire [7:0] modrm,
    input wire seg_override,
    input wire [`REG_ID_W-1:0] seg0,

    output wire decode_cs_REP,
    output wire decode_cs_REP_CMP,
    output wire decode_cs_HALT,
    output wire decode_cs_MODRM_NEEDED,
    output wire decode_cs_RM_IS_DR,
    output wire decode_cs_REG_IS_DR,
    output wire decode_cs_REG_IS_SEGMENT,
    output wire decode_cs_HARDCODED_DR_HIGH8,
    output wire decode_cs_MODRM_BUT_NO_SR,
    output wire decode_cs_HARDCODED_DR,
    output wire [`REG_ID_W-1:0] decode_cs_HARDCODED_DR_ID,
    output wire decode_cs_HARDCODED_SR,
    output wire [`REG_ID_W-1:0] decode_cs_HARDCODED_SR_ID,
    output wire decode_cs_HARDCODED_DR_RD,
    output wire decode_cs_HARDCODED_DR_WR,
    output wire decode_cs_HARDCODED_SR_RD,
    output wire decode_cs_HARDCODED_SR_WR,
    output wire decode_cs_HARDCODED_LD_OP,
    output wire decode_cs_HARDCODED_ST_OP,
    output wire decode_cs_LD_OP_CANCEL,
    output wire decode_cs_ST_OP_CANCEL,
    output wire decode_cs_OP_IN_MODRM,
    output wire [1:0] decode_cs_DATA_SIZE,

    output wire rr_cs_ST_SEL,
    output wire rr_cs_MODRM_NEEDED,
    output wire rr_cs_RM_IS_DR,
    output wire rr_cs_SWITCH_LD_ADDY,
    output wire rr_cs_LD_OP,
    output wire rr_cs_ST_OP,
    output wire [`REG_ID_W-1:0] rr_cs_dr_id,
    output wire [`REG_ID_W-1:0] rr_cs_sr_id,
    output wire rr_cs_dr_rd,
    output wire rr_cs_sr_rd,
    output wire rr_cs_eax_rd,
    output wire rr_cs_dr_wr,
    output wire rr_cs_sr_wr,
    output wire rr_cs_eax_wr,
    output wire rr_cs_MOVS_OP,
    output wire [1:0] rr_cs_datasize,
    output wire rr_cs_will_mod_zf,
    output wire rr_cs_seg_1_valid,
    output wire [`REG_ID_W-1:0] rr_cs_seg_0_id,
    output wire [`REG_ID_W-1:0] rr_cs_seg_1_id,
    output wire rr_cs_special_modrm_bs,
    output wire rr_cs_special_br,

    output wire dc_cs_LD_OP,
    output wire dc_cs_ST_OP,
    output wire dc_cs_dr_upper8,
    output wire dc_cs_sr_upper8,
    output wire [1:0] dc_cs_datasize,
    output wire dc_cs_st_optimization_disable,

    output wire mem_cs_ST_OP,
    output wire mem_cs_LD_OP,
    output wire mem_cs_st_optimization_disable,

    output wire exe_cs_ST_OP,
    output wire [`EXE_OP_W-1:0] exe_cs_OP_TYPE,
    output wire [`SRC_SEL_W-1:0] exe_cs_alu_inputA_sel,
    output wire [`SRC_SEL_W-1:0] exe_cs_alu_inputB_sel,
    output wire [`SRC_SEL_W-1:0] exe_cs_branch_target_sel,
    output wire exe_cs_shift_by_one,
    output wire exe_cs_br_ucond,
    output wire exe_cs_relative_branch,
    output wire exe_cs_special_br,
    output wire exe_cs_is_far,
    output wire exe_cs_is_call,
    output wire exe_cs_second_flag_needed,
    output wire exe_cs_rep_no_zf_update,
    output wire exe_cs_st_optimization_disable,

    output wire wb_cs_ST_OP,
    output wire wb_cs_WB_DR,
    output wire wb_cs_WB_SR,
    output wire wb_cs_WB_EAX,
    output wire wb_cs_st_optimization_disable
);

    wire temp_decode_cs_REP;
    wire temp_decode_cs_REP_CMP;
    wire temp_decode_cs_HALT;
    wire temp_decode_cs_MODRM_NEEDED;
    wire temp_decode_cs_RM_IS_DR;
    wire temp_decode_cs_REG_IS_DR;
    wire temp_decode_cs_REG_IS_SEGMENT;
    wire temp_decode_cs_HARDCODED_DR_HIGH8;
    wire temp_decode_cs_MODRM_BUT_NO_SR;
    wire temp_decode_cs_HARDCODED_DR;
    wire [`REG_ID_W-1:0] temp_decode_cs_HARDCODED_DR_ID;
    wire temp_decode_cs_HARDCODED_SR;
    wire [`REG_ID_W-1:0] temp_decode_cs_HARDCODED_SR_ID;
    wire temp_decode_cs_HARDCODED_DR_RD;
    wire temp_decode_cs_HARDCODED_DR_WR;
    wire temp_decode_cs_HARDCODED_SR_RD;
    wire temp_decode_cs_HARDCODED_SR_WR;
    wire temp_decode_cs_HARDCODED_LD_OP;
    wire temp_decode_cs_HARDCODED_ST_OP;
    wire temp_decode_cs_LD_OP_CANCEL;
    wire temp_decode_cs_ST_OP_CANCEL;
    wire temp_decode_cs_OP_IN_MODRM;
    wire [1:0] temp_decode_cs_DATA_SIZE;

    wire temp_rr_cs_ST_SEL;
    wire temp_rr_cs_MODRM_NEEDED;
    wire temp_rr_cs_RM_IS_DR;
    wire temp_rr_cs_SWITCH_LD_ADDY;
    wire temp_rr_cs_LD_OP;
    wire temp_rr_cs_ST_OP;
    wire [`REG_ID_W-1:0] temp_rr_cs_dr_id;
    wire [`REG_ID_W-1:0] temp_rr_cs_sr_id;
    wire temp_rr_cs_dr_rd;
    wire temp_rr_cs_sr_rd;
    wire temp_rr_cs_eax_rd;
    wire temp_rr_cs_dr_wr;
    wire temp_rr_cs_sr_wr;
    wire temp_rr_cs_eax_wr;
    wire temp_rr_cs_MOVS_OP;
    wire [1:0] temp_rr_cs_datasize;
    wire temp_rr_cs_will_mod_zf;
    wire temp_rr_cs_seg_1_valid;
    wire [`REG_ID_W-1:0] temp_rr_cs_seg_0_id;
    wire [`REG_ID_W-1:0] temp_rr_cs_seg_1_id;
    wire temp_rr_cs_special_modrm_bs;
    wire temp_rr_cs_special_br;

    wire temp_dc_cs_LD_OP;
    wire temp_dc_cs_ST_OP;
    wire temp_dc_cs_dr_upper8;
    wire temp_dc_cs_sr_upper8;
    wire [1:0] temp_dc_cs_datasize;
    wire temp_dc_cs_st_optimization_disable;

    wire temp_mem_cs_ST_OP;
    wire temp_mem_cs_LD_OP;
    wire temp_mem_cs_st_optimization_disable;

    wire temp_exe_cs_ST_OP;
    wire [`EXE_OP_W-1:0] temp_exe_cs_OP_TYPE;
    wire [`SRC_SEL_W-1:0] temp_exe_cs_alu_inputA_sel;
    wire [`SRC_SEL_W-1:0] temp_exe_cs_alu_inputB_sel;
    wire [`SRC_SEL_W-1:0] temp_exe_cs_branch_target_sel;
    wire temp_exe_cs_shift_by_one;
    wire temp_exe_cs_br_ucond;
    wire temp_exe_cs_relative_branch;
    wire temp_exe_cs_special_br;
    wire temp_exe_cs_is_far;
    wire temp_exe_cs_is_call;
    wire temp_exe_cs_second_flag_needed;
    wire temp_exe_cs_rep_no_zf_update;
    wire temp_exe_cs_st_optimization_disable;

    wire temp_wb_cs_ST_OP;
    wire temp_wb_cs_WB_DR;
    wire temp_wb_cs_WB_SR;
    wire temp_wb_cs_WB_EAX;
    wire temp_wb_cs_st_optimization_disable;

    // =====================
    // Input wires
    // =====================
    //MSB --> 2e, 36, 3e, 26, 64, 65, 66, 67, 0f, f3  <-- LSB vector
    wire [9:0] input_bus;
    wire vector_ored;
    `OR_2(vector_ored_gate, 1, vector_ored, total_pf_vector[0], total_pf_vector[1])
    assign input_bus = {vector_ored, opcode, total_pf_vector[3]};

    // =====================
    // Single-bit outputs
    // =====================
    wire REP_o;
    wire REP_CMP_o;
    wire HALT_o;
    wire MOVS_o;
    wire XCHG_o;
    wire CMPXCHG_o;
    wire SHIFT_BY_ONE_o;

    wire MODRM_NEEDED_o;
    wire RM_IS_DR_o;
    wire REG_IS_DR_o;
    wire REG_IS_SEGMENT_o;
    wire MODRM_BUT_NO_SR_o;
    wire SWITCH_LD_ADDY_o;

    wire HARD_CODED_DR_o;
    wire HARD_CODED_SR_o;
    wire HARDCODED_DR_HIGH8_o;

    wire OP_IN_MODRM_o;

    wire HARDCODED_DR_RD_o;
    wire HARDCODED_DR_WR_o;
    wire HARDCODED_SR_RD_o;
    wire HARDCODED_SR_WR_o;
    wire HARDCODED_LD_OP_o;
    wire HARDCODED_ST_OP_o;
    wire LD_OP_CANCEL_o;
    wire ST_OP_CANCEL_o;
    wire ST_SEL_o;

    wire br_uncond_o;
    wire relative_branch_o;
    wire special_br_o;
    wire is_far_o;
    wire is_call_o;
    wire second_flag_needed_o;
    wire st_optimization_disable_o;

    wire will_mod_zf_o;

    wire HARDCODED_SEGMENT1_V_o;

    // =====================
    // Packed outputs
    // =====================
    wire [4:0] HARD_CODED_DR_ID_o;
    wire [4:0] HARD_CODED_SR_ID_o;

    wire [1:0] DATA_SIZE_o;

    wire [1:0] OP_IN_MODRM_SUBSET_o;

    wire [4:0] alu_inputA_sel_o;
    wire [4:0] alu_inputB_sel_o;
    wire [4:0] branch_target_sel_o;

    wire [5:0] OP_TYPE_o;

    wire [4:0] HARDCODED_SEGMENT0_o;
    wire [4:0] HARDCODED_SEGMENT1_o;
    // =====================
    // Module instantiation
    // =====================

    control_store_genned control_store (
        // Input bits
        .in_9_i(input_bus[9]),
        .in_8_i(input_bus[8]),
        .in_7_i(input_bus[7]),
        .in_6_i(input_bus[6]),
        .in_5_i(input_bus[5]),
        .in_4_i(input_bus[4]),
        .in_3_i(input_bus[3]),
        .in_2_i(input_bus[2]),
        .in_1_i(input_bus[1]),
        .in_0_i(input_bus[0]),

        // General Control
        .REP_o(REP_o),
        .REP_CMP_o(REP_CMP_o),
        .HALT_o(HALT_o),
        .MOVS_o(MOVS_o),
        .XCHG_o(XCHG_o),
        .CMPXCHG_o(CMPXCHG_o),
        .SHIFT_BY_ONE_o(SHIFT_BY_ONE_o),

        .MODRM_NEEDED_o(MODRM_NEEDED_o),
        .RM_IS_DR_o(RM_IS_DR_o),
        .REG_IS_DR_o(REG_IS_DR_o),
        .REG_IS_SEGMENT_o(REG_IS_SEGMENT_o),
        .MODRM_BUT_NO_SR_o(MODRM_BUT_NO_SR_o),
        .SWITCH_LD_ADDY_o(SWITCH_LD_ADDY_o),
        .HARDCODED_DR_HIGH8_o(HARDCODED_DR_HIGH8_o),

        .OP_IN_MODRM_o(OP_IN_MODRM_o),

        // Packed subset wiring
        .OP_IN_MODRM_SUBSET_1_o(OP_IN_MODRM_SUBSET_o[1]),
        .OP_IN_MODRM_SUBSET_0_o(OP_IN_MODRM_SUBSET_o[0]),

        // Op Enables / Selects
        .HARDCODED_DR_RD_o(HARDCODED_DR_RD_o),
        .HARDCODED_DR_WR_o(HARDCODED_DR_WR_o),
        .HARDCODED_SR_RD_o(HARDCODED_SR_RD_o),
        .HARDCODED_SR_WR_o(HARDCODED_SR_WR_o),
        .HARDCODED_LD_OP_o(HARDCODED_LD_OP_o),
        .HARDCODED_ST_OP_o(HARDCODED_ST_OP_o),
        .LD_OP_CANCEL_o(LD_OP_CANCEL_o),
        .ST_OP_CANCEL_o(ST_OP_CANCEL_o),
        .ST_SEL_o(ST_SEL_o),

        // Destination Register Hardcoding
        .HARD_CODED_DR_o(HARD_CODED_DR_o),
        .HARD_CODED_DR_ID_4_o(HARD_CODED_DR_ID_o[4]),
        .HARD_CODED_DR_ID_3_o(HARD_CODED_DR_ID_o[3]),
        .HARD_CODED_DR_ID_2_o(HARD_CODED_DR_ID_o[2]),
        .HARD_CODED_DR_ID_1_o(HARD_CODED_DR_ID_o[1]),
        .HARD_CODED_DR_ID_0_o(HARD_CODED_DR_ID_o[0]),

        // Source Register Hardcoding
        .HARD_CODED_SR_o(HARD_CODED_SR_o),
        .HARD_CODED_SR_ID_4_o(HARD_CODED_SR_ID_o[4]),
        .HARD_CODED_SR_ID_3_o(HARD_CODED_SR_ID_o[3]),
        .HARD_CODED_SR_ID_2_o(HARD_CODED_SR_ID_o[2]),
        .HARD_CODED_SR_ID_1_o(HARD_CODED_SR_ID_o[1]),
        .HARD_CODED_SR_ID_0_o(HARD_CODED_SR_ID_o[0]),

        // DATA SIZE
        .DATA_SIZE_1_o(DATA_SIZE_o[1]),
        .DATA_SIZE_0_o(DATA_SIZE_o[0]),

        // ALU A
        .alu_inputA_sel_4_o(alu_inputA_sel_o[4]),
        .alu_inputA_sel_3_o(alu_inputA_sel_o[3]),
        .alu_inputA_sel_2_o(alu_inputA_sel_o[2]),
        .alu_inputA_sel_1_o(alu_inputA_sel_o[1]),
        .alu_inputA_sel_0_o(alu_inputA_sel_o[0]),

        // ALU B
        .alu_inputB_sel_4_o(alu_inputB_sel_o[4]),
        .alu_inputB_sel_3_o(alu_inputB_sel_o[3]),
        .alu_inputB_sel_2_o(alu_inputB_sel_o[2]),
        .alu_inputB_sel_1_o(alu_inputB_sel_o[1]),
        .alu_inputB_sel_0_o(alu_inputB_sel_o[0]),

        // Branch target
        .branch_target_sel_4_o(branch_target_sel_o[4]),
        .branch_target_sel_3_o(branch_target_sel_o[3]),
        .branch_target_sel_2_o(branch_target_sel_o[2]),
        .branch_target_sel_1_o(branch_target_sel_o[1]),
        .branch_target_sel_0_o(branch_target_sel_o[0]),

        // OP_TYPE
        .OP_TYPE_5_o(OP_TYPE_o[5]),
        .OP_TYPE_4_o(OP_TYPE_o[4]),
        .OP_TYPE_3_o(OP_TYPE_o[3]),
        .OP_TYPE_2_o(OP_TYPE_o[2]),
        .OP_TYPE_1_o(OP_TYPE_o[1]),
        .OP_TYPE_0_o(OP_TYPE_o[0]),

        // Branch / Execution Flags
        .br_uncond_o(br_uncond_o),
        .relative_branch_o(relative_branch_o),
        .special_br_o(special_br_o),
        .is_far_o(is_far_o),
        .is_call_o(is_call_o),
        .second_flag_needed_o(second_flag_needed_o),
        .st_optimization_disable_o(st_optimization_disable_o),

        // Misc
        .will_mod_zf_o(will_mod_zf_o),

        // Segment 0
        .HARDCODED_SEGMENT0_4_o(HARDCODED_SEGMENT0_o[4]),
        .HARDCODED_SEGMENT0_3_o(HARDCODED_SEGMENT0_o[3]),
        .HARDCODED_SEGMENT0_2_o(HARDCODED_SEGMENT0_o[2]),
        .HARDCODED_SEGMENT0_1_o(HARDCODED_SEGMENT0_o[1]),
        .HARDCODED_SEGMENT0_0_o(HARDCODED_SEGMENT0_o[0]),

        // Segment 1
        .HARDCODED_SEGMENT1_V_o(HARDCODED_SEGMENT1_V_o),
        .HARDCODED_SEGMENT1_4_o(HARDCODED_SEGMENT1_o[4]),
        .HARDCODED_SEGMENT1_3_o(HARDCODED_SEGMENT1_o[3]),
        .HARDCODED_SEGMENT1_2_o(HARDCODED_SEGMENT1_o[2]),
        .HARDCODED_SEGMENT1_1_o(HARDCODED_SEGMENT1_o[1]),
        .HARDCODED_SEGMENT1_0_o(HARDCODED_SEGMENT1_o[0])
    );

    wire [`REG_ID_W-1:0] mod_rm_cs_outs_dr_id;
    wire [`REG_ID_W-1:0] mod_rm_cs_outs_sr_id;
    wire mod_rm_cs_outs_dr_rd;
    wire mod_rm_cs_outs_sr_rd;
    wire mod_rm_cs_outs_dr_wr;
    wire mod_rm_cs_outs_sr_wr;
    wire mod_rm_cs_outs_st_op;
    wire mod_rm_cs_outs_ld_op;
    wire mod_rm_cs_outs_dr_high8;
    wire mod_rm_cs_outs_sr_high8;
    wire mod_rm_cs_outs_alu_inputA_override;
    wire mod_rm_cs_outs_alu_inputB_override;
    wire [`SRC_SEL_W-1:0] mod_rm_cs_outs_alu_inputA_override_sel;
    wire [`SRC_SEL_W-1:0] mod_rm_cs_outs_alu_inputB_override_sel;
    wire mod_rm_cs_outs_special_modrm_bs;

    // DECODE
    assign temp_decode_cs_REP                = REP_o;
    assign temp_decode_cs_REP_CMP            = REP_CMP_o;
    assign temp_decode_cs_HALT               = HALT_o;
    assign temp_decode_cs_MODRM_NEEDED       = MODRM_NEEDED_o;
    assign temp_decode_cs_RM_IS_DR           = RM_IS_DR_o;
    assign temp_decode_cs_REG_IS_DR          = REG_IS_DR_o;
    assign temp_decode_cs_REG_IS_SEGMENT     = REG_IS_SEGMENT_o;
    assign temp_decode_cs_HARDCODED_DR_HIGH8 = HARDCODED_DR_HIGH8_o;
    assign temp_decode_cs_MODRM_BUT_NO_SR    = MODRM_BUT_NO_SR_o;
    assign temp_decode_cs_HARDCODED_DR       = HARD_CODED_DR_o;
    assign temp_decode_cs_HARDCODED_DR_ID    = HARD_CODED_DR_ID_o;
    assign temp_decode_cs_HARDCODED_SR       = HARD_CODED_SR_o;
    assign temp_decode_cs_HARDCODED_SR_ID    = HARD_CODED_SR_ID_o;
    assign temp_decode_cs_HARDCODED_DR_RD    = HARDCODED_DR_RD_o;
    assign temp_decode_cs_HARDCODED_DR_WR    = HARDCODED_DR_WR_o;
    assign temp_decode_cs_HARDCODED_SR_RD    = HARDCODED_SR_RD_o;
    assign temp_decode_cs_HARDCODED_SR_WR    = HARDCODED_SR_WR_o;
    assign temp_decode_cs_HARDCODED_LD_OP    = HARDCODED_LD_OP_o;
    assign temp_decode_cs_HARDCODED_ST_OP    = HARDCODED_ST_OP_o;
    assign temp_decode_cs_LD_OP_CANCEL       = LD_OP_CANCEL_o;
    assign temp_decode_cs_ST_OP_CANCEL       = ST_OP_CANCEL_o;
    assign temp_decode_cs_OP_IN_MODRM        = OP_IN_MODRM_o;
    assign temp_decode_cs_DATA_SIZE          = DATA_SIZE_o;

    // RR
    assign temp_rr_cs_ST_SEL           = ST_SEL_o;
    assign temp_rr_cs_MODRM_NEEDED     = MODRM_NEEDED_o;
    assign temp_rr_cs_RM_IS_DR         = RM_IS_DR_o;
    assign temp_rr_cs_SWITCH_LD_ADDY   = SWITCH_LD_ADDY_o;
    assign temp_rr_cs_LD_OP            = mod_rm_cs_outs_ld_op;
    assign temp_rr_cs_ST_OP            = mod_rm_cs_outs_st_op;
    assign temp_rr_cs_MOVS_OP          = MOVS_o;
    assign temp_rr_cs_dr_id            = mod_rm_cs_outs_dr_id;
    assign temp_rr_cs_sr_id            = mod_rm_cs_outs_sr_id;
    assign temp_rr_cs_dr_rd            = mod_rm_cs_outs_dr_rd;
    assign temp_rr_cs_sr_rd            = mod_rm_cs_outs_sr_rd;
    assign temp_rr_cs_dr_wr            = mod_rm_cs_outs_dr_wr;
    assign temp_rr_cs_sr_wr            = mod_rm_cs_outs_sr_wr;
    assign temp_rr_cs_eax_wr           = 1'b0;                //will be overriden in cs_post_processor
    assign temp_rr_cs_eax_rd           = 1'b0;                //will be overriden in cs_post_processor
    assign temp_rr_cs_datasize         = DATA_SIZE_o;
    assign temp_rr_cs_will_mod_zf      = will_mod_zf_o;
    assign temp_rr_cs_seg_1_valid      = HARDCODED_SEGMENT1_V_o;
    assign temp_rr_cs_seg_0_id         = seg_override ? seg0 : HARDCODED_SEGMENT0_o;
    assign temp_rr_cs_seg_1_id         = HARDCODED_SEGMENT1_o;
    assign temp_rr_cs_special_modrm_bs = mod_rm_cs_outs_special_modrm_bs;
    assign temp_rr_cs_special_br       = special_br_o;


    // DC
    assign temp_dc_cs_LD_OP = mod_rm_cs_outs_ld_op;
    assign temp_dc_cs_ST_OP = mod_rm_cs_outs_st_op;
    assign temp_dc_cs_dr_upper8 = mod_rm_cs_outs_dr_high8;
    assign temp_dc_cs_sr_upper8 = mod_rm_cs_outs_sr_high8;
    assign temp_dc_cs_datasize = DATA_SIZE_o;
    assign temp_dc_cs_st_optimization_disable = st_optimization_disable_o;

    // MEM
    assign temp_mem_cs_ST_OP = mod_rm_cs_outs_st_op;
    assign temp_mem_cs_LD_OP = mod_rm_cs_outs_ld_op;
    assign temp_mem_cs_st_optimization_disable = st_optimization_disable_o;

    // EXE
    assign temp_exe_cs_ST_OP               = mod_rm_cs_outs_st_op;
    assign temp_exe_cs_OP_TYPE             = OP_TYPE_o;
    assign temp_exe_cs_alu_inputA_sel      = mod_rm_cs_outs_alu_inputA_override ?
                                mod_rm_cs_outs_alu_inputA_override_sel :
                                alu_inputA_sel_o;
    assign temp_exe_cs_alu_inputB_sel      = mod_rm_cs_outs_alu_inputB_override ?
                                mod_rm_cs_outs_alu_inputB_override_sel :
                                alu_inputB_sel_o;
    assign temp_exe_cs_branch_target_sel   = branch_target_sel_o;
    assign temp_exe_cs_shift_by_one        = SHIFT_BY_ONE_o;
    assign temp_exe_cs_br_ucond            = br_uncond_o;
    assign temp_exe_cs_relative_branch     = relative_branch_o;
    assign temp_exe_cs_special_br          = special_br_o;
    assign temp_exe_cs_is_far              = is_far_o;
    assign temp_exe_cs_is_call             = is_call_o;
    assign temp_exe_cs_second_flag_needed  = second_flag_needed_o;
    assign temp_exe_cs_rep_no_zf_update    = 1'b0;
    assign temp_exe_cs_st_optimization_disable = st_optimization_disable_o;


    // WB
    assign temp_wb_cs_ST_OP = mod_rm_cs_outs_st_op;
    assign temp_wb_cs_WB_DR = mod_rm_cs_outs_dr_wr;
    assign temp_wb_cs_WB_SR = mod_rm_cs_outs_sr_wr;
    assign temp_wb_cs_WB_EAX = 1'b0;               //will be overriden in cs_post_processor
    assign temp_wb_cs_st_optimization_disable = st_optimization_disable_o;


    modrm_processor mod_rm_cs_gen(
        .modrm_byte(modrm), 
        .datasize(DATA_SIZE_o), 

        //.decode_cs_inputs(temp_decode_cs), 
        .cs_MODRM_NEEDED      (temp_decode_cs_MODRM_NEEDED),
        .cs_RM_IS_DR          (temp_decode_cs_RM_IS_DR),
        .cs_REG_IS_DR         (temp_decode_cs_REG_IS_DR),
        .cs_REG_IS_SEGMENT    (temp_decode_cs_REG_IS_SEGMENT),
        .cs_HARDCODED_DR_HIGH8(temp_decode_cs_HARDCODED_DR_HIGH8),
        .cs_MODRM_BUT_NO_SR   (temp_decode_cs_MODRM_BUT_NO_SR),
        .cs_HARDCODED_DR      (temp_decode_cs_HARDCODED_DR),
        .cs_HARDCODED_DR_ID   (temp_decode_cs_HARDCODED_DR_ID),
        .cs_HARDCODED_SR      (temp_decode_cs_HARDCODED_SR),
        .cs_HARDCODED_SR_ID   (temp_decode_cs_HARDCODED_SR_ID),
        .cs_HARDCODED_DR_RD   (temp_decode_cs_HARDCODED_DR_RD),
        .cs_HARDCODED_DR_WR   (temp_decode_cs_HARDCODED_DR_WR),
        .cs_HARDCODED_SR_RD   (temp_decode_cs_HARDCODED_SR_RD),
        .cs_HARDCODED_SR_WR   (temp_decode_cs_HARDCODED_SR_WR),
        .cs_HARDCODED_LD_OP   (temp_decode_cs_HARDCODED_LD_OP),
        .cs_HARDCODED_ST_OP   (temp_decode_cs_HARDCODED_ST_OP),
        .cs_LD_OP_CANCEL      (temp_decode_cs_LD_OP_CANCEL),
        .cs_ST_OP_CANCEL      (temp_decode_cs_ST_OP_CANCEL),

        .dr_id                      (mod_rm_cs_outs_dr_id),
        .sr_id                      (mod_rm_cs_outs_sr_id),
        .dr_rd                      (mod_rm_cs_outs_dr_rd),
        .sr_rd                      (mod_rm_cs_outs_sr_rd),
        .dr_wr                      (mod_rm_cs_outs_dr_wr),
        .sr_wr                      (mod_rm_cs_outs_sr_wr),
        .st_op                      (mod_rm_cs_outs_st_op),
        .ld_op                      (mod_rm_cs_outs_ld_op),
        .dr_high8                   (mod_rm_cs_outs_dr_high8),
        .sr_high8                   (mod_rm_cs_outs_sr_high8),
        .alu_inputA_override        (mod_rm_cs_outs_alu_inputA_override),
        .alu_inputB_override        (mod_rm_cs_outs_alu_inputB_override),
        .alu_inputA_override_sel    (mod_rm_cs_outs_alu_inputA_override_sel),
        .alu_inputB_override_sel    (mod_rm_cs_outs_alu_inputB_override_sel),
        .special_modrm_bs           (mod_rm_cs_outs_special_modrm_bs)
    );


    cs_post_processor cs_post_prossesing_unit(
        .invalid_inst               (invalid_inst),
        .modrm_byte                 (modrm),
        .xchg                       (XCHG_o),
        .cmpxchg                    (CMPXCHG_o),
        .op_in_modrm                (OP_IN_MODRM_o),
        .op_in_modrm_subset         (OP_IN_MODRM_SUBSET_o),

        // decode_cs inputs
        .decode_cs_i_REP                (temp_decode_cs_REP),
        .decode_cs_i_REP_CMP            (temp_decode_cs_REP_CMP),
        .decode_cs_i_HALT               (temp_decode_cs_HALT),
        .decode_cs_i_MODRM_NEEDED       (temp_decode_cs_MODRM_NEEDED),
        .decode_cs_i_RM_IS_DR           (temp_decode_cs_RM_IS_DR),
        .decode_cs_i_REG_IS_DR          (temp_decode_cs_REG_IS_DR),
        .decode_cs_i_REG_IS_SEGMENT     (temp_decode_cs_REG_IS_SEGMENT),
        .decode_cs_i_HARDCODED_DR_HIGH8 (temp_decode_cs_HARDCODED_DR_HIGH8),
        .decode_cs_i_MODRM_BUT_NO_SR    (temp_decode_cs_MODRM_BUT_NO_SR),
        .decode_cs_i_HARDCODED_DR       (temp_decode_cs_HARDCODED_DR),
        .decode_cs_i_HARDCODED_DR_ID    (temp_decode_cs_HARDCODED_DR_ID),
        .decode_cs_i_HARDCODED_SR       (temp_decode_cs_HARDCODED_SR),
        .decode_cs_i_HARDCODED_SR_ID    (temp_decode_cs_HARDCODED_SR_ID),
        .decode_cs_i_HARDCODED_DR_RD    (temp_decode_cs_HARDCODED_DR_RD),
        .decode_cs_i_HARDCODED_DR_WR    (temp_decode_cs_HARDCODED_DR_WR),
        .decode_cs_i_HARDCODED_SR_RD    (temp_decode_cs_HARDCODED_SR_RD),
        .decode_cs_i_HARDCODED_SR_WR    (temp_decode_cs_HARDCODED_SR_WR),
        .decode_cs_i_HARDCODED_LD_OP    (temp_decode_cs_HARDCODED_LD_OP),
        .decode_cs_i_HARDCODED_ST_OP    (temp_decode_cs_HARDCODED_ST_OP),
        .decode_cs_i_LD_OP_CANCEL       (temp_decode_cs_LD_OP_CANCEL),
        .decode_cs_i_ST_OP_CANCEL       (temp_decode_cs_ST_OP_CANCEL),
        .decode_cs_i_OP_IN_MODRM        (temp_decode_cs_OP_IN_MODRM),
        .decode_cs_i_DATA_SIZE          (temp_decode_cs_DATA_SIZE),

        // rr_cs inputs
        .rr_cs_i_ST_SEL                 (temp_rr_cs_ST_SEL),
        .rr_cs_i_MODRM_NEEDED           (temp_rr_cs_MODRM_NEEDED),
        .rr_cs_i_RM_IS_DR               (temp_rr_cs_RM_IS_DR),
        .rr_cs_i_SWITCH_LD_ADDY         (temp_rr_cs_SWITCH_LD_ADDY),
        .rr_cs_i_LD_OP                  (temp_rr_cs_LD_OP),
        .rr_cs_i_ST_OP                  (temp_rr_cs_ST_OP),
        .rr_cs_i_MOVS_OP                (temp_rr_cs_MOVS_OP),
        .rr_cs_i_dr_id                  (temp_rr_cs_dr_id),
        .rr_cs_i_sr_id                  (temp_rr_cs_sr_id),
        .rr_cs_i_dr_rd                  (temp_rr_cs_dr_rd),
        .rr_cs_i_sr_rd                  (temp_rr_cs_sr_rd),
        .rr_cs_i_eax_rd                 (temp_rr_cs_eax_rd),
        .rr_cs_i_dr_wr                  (temp_rr_cs_dr_wr),
        .rr_cs_i_sr_wr                  (temp_rr_cs_sr_wr),
        .rr_cs_i_eax_wr                 (temp_rr_cs_eax_wr),
        .rr_cs_i_datasize               (temp_rr_cs_datasize),
        .rr_cs_i_will_mod_zf            (temp_rr_cs_will_mod_zf),
        .rr_cs_i_seg_1_valid            (temp_rr_cs_seg_1_valid),
        .rr_cs_i_seg_0_id               (temp_rr_cs_seg_0_id),
        .rr_cs_i_seg_1_id               (temp_rr_cs_seg_1_id),
        .rr_cs_i_special_modrm_bs       (temp_rr_cs_special_modrm_bs),
        .rr_cs_i_special_br             (temp_rr_cs_special_br),

        // dc_cs inputs
        .dc_cs_i_LD_OP                  (temp_dc_cs_LD_OP),
        .dc_cs_i_ST_OP                  (temp_dc_cs_ST_OP),
        .dc_cs_i_dr_upper8              (temp_dc_cs_dr_upper8),
        .dc_cs_i_sr_upper8              (temp_dc_cs_sr_upper8),
        .dc_cs_i_datasize               (temp_dc_cs_datasize),
        .dc_cs_i_st_optimization_disable(temp_dc_cs_st_optimization_disable),

        // mem_cs inputs
        .mem_cs_i_ST_OP                 (temp_mem_cs_ST_OP),
        .mem_cs_i_LD_OP                 (temp_mem_cs_LD_OP),
        .mem_cs_i_st_optimization_disable(temp_mem_cs_st_optimization_disable),

        // exe_cs inputs
        .exe_cs_i_ST_OP                 (temp_exe_cs_ST_OP),
        .exe_cs_i_OP_TYPE               (temp_exe_cs_OP_TYPE),
        .exe_cs_i_alu_inputA_sel        (temp_exe_cs_alu_inputA_sel),
        .exe_cs_i_alu_inputB_sel        (temp_exe_cs_alu_inputB_sel),
        .exe_cs_i_branch_target_sel     (temp_exe_cs_branch_target_sel),
        .exe_cs_i_shift_by_one          (temp_exe_cs_shift_by_one),
        .exe_cs_i_br_ucond              (temp_exe_cs_br_ucond),
        .exe_cs_i_relative_branch       (temp_exe_cs_relative_branch),
        .exe_cs_i_special_br            (temp_exe_cs_special_br),
        .exe_cs_i_is_far                (temp_exe_cs_is_far),
        .exe_cs_i_is_call               (temp_exe_cs_is_call),
        .exe_cs_i_second_flag_needed    (temp_exe_cs_second_flag_needed),
        .exe_cs_i_rep_no_zf_update      (temp_exe_cs_rep_no_zf_update),
        .exe_cs_i_st_optimization_disable(temp_exe_cs_st_optimization_disable),

        // wb_cs inputs
        .wb_cs_i_ST_OP                  (temp_wb_cs_ST_OP),
        .wb_cs_i_WB_DR                  (temp_wb_cs_WB_DR),
        .wb_cs_i_WB_SR                  (temp_wb_cs_WB_SR),
        .wb_cs_i_WB_EAX                 (temp_wb_cs_WB_EAX),
        .wb_cs_i_st_optimization_disable(temp_wb_cs_st_optimization_disable),

        // decode_cs outputs
        .decode_cs_o_REP                (decode_cs_REP),
        .decode_cs_o_REP_CMP            (decode_cs_REP_CMP),
        .decode_cs_o_HALT               (decode_cs_HALT),
        .decode_cs_o_MODRM_NEEDED       (decode_cs_MODRM_NEEDED),
        .decode_cs_o_RM_IS_DR           (decode_cs_RM_IS_DR),
        .decode_cs_o_REG_IS_DR          (decode_cs_REG_IS_DR),
        .decode_cs_o_REG_IS_SEGMENT     (decode_cs_REG_IS_SEGMENT),
        .decode_cs_o_HARDCODED_DR_HIGH8 (decode_cs_HARDCODED_DR_HIGH8),
        .decode_cs_o_MODRM_BUT_NO_SR    (decode_cs_MODRM_BUT_NO_SR),
        .decode_cs_o_HARDCODED_DR       (decode_cs_HARDCODED_DR),
        .decode_cs_o_HARDCODED_DR_ID    (decode_cs_HARDCODED_DR_ID),
        .decode_cs_o_HARDCODED_SR       (decode_cs_HARDCODED_SR),
        .decode_cs_o_HARDCODED_SR_ID    (decode_cs_HARDCODED_SR_ID),
        .decode_cs_o_HARDCODED_DR_RD    (decode_cs_HARDCODED_DR_RD),
        .decode_cs_o_HARDCODED_DR_WR    (decode_cs_HARDCODED_DR_WR),
        .decode_cs_o_HARDCODED_SR_RD    (decode_cs_HARDCODED_SR_RD),
        .decode_cs_o_HARDCODED_SR_WR    (decode_cs_HARDCODED_SR_WR),
        .decode_cs_o_HARDCODED_LD_OP    (decode_cs_HARDCODED_LD_OP),
        .decode_cs_o_HARDCODED_ST_OP    (decode_cs_HARDCODED_ST_OP),
        .decode_cs_o_LD_OP_CANCEL       (decode_cs_LD_OP_CANCEL),
        .decode_cs_o_ST_OP_CANCEL       (decode_cs_ST_OP_CANCEL),
        .decode_cs_o_OP_IN_MODRM        (decode_cs_OP_IN_MODRM),
        .decode_cs_o_DATA_SIZE          (decode_cs_DATA_SIZE),

        // rr_cs outputs
        .rr_cs_o_ST_SEL                 (rr_cs_ST_SEL),
        .rr_cs_o_MODRM_NEEDED           (rr_cs_MODRM_NEEDED),
        .rr_cs_o_RM_IS_DR               (rr_cs_RM_IS_DR),
        .rr_cs_o_SWITCH_LD_ADDY         (rr_cs_SWITCH_LD_ADDY),
        .rr_cs_o_LD_OP                  (rr_cs_LD_OP),
        .rr_cs_o_ST_OP                  (rr_cs_ST_OP),
        .rr_cs_o_MOVS_OP                (rr_cs_MOVS_OP),
        .rr_cs_o_dr_id                  (rr_cs_dr_id),
        .rr_cs_o_sr_id                  (rr_cs_sr_id),
        .rr_cs_o_dr_rd                  (rr_cs_dr_rd),
        .rr_cs_o_sr_rd                  (rr_cs_sr_rd),
        .rr_cs_o_eax_rd                 (rr_cs_eax_rd),
        .rr_cs_o_dr_wr                  (rr_cs_dr_wr),
        .rr_cs_o_sr_wr                  (rr_cs_sr_wr),
        .rr_cs_o_eax_wr                 (rr_cs_eax_wr),
        .rr_cs_o_datasize               (rr_cs_datasize),
        .rr_cs_o_will_mod_zf            (rr_cs_will_mod_zf),
        .rr_cs_o_seg_1_valid            (rr_cs_seg_1_valid),
        .rr_cs_o_seg_0_id               (rr_cs_seg_0_id),
        .rr_cs_o_seg_1_id               (rr_cs_seg_1_id),
        .rr_cs_o_special_modrm_bs       (rr_cs_special_modrm_bs),
        .rr_cs_o_special_br             (rr_cs_special_br),

        // dc_cs outputs
        .dc_cs_o_LD_OP                  (dc_cs_LD_OP),
        .dc_cs_o_ST_OP                  (dc_cs_ST_OP),
        .dc_cs_o_dr_upper8              (dc_cs_dr_upper8),
        .dc_cs_o_sr_upper8              (dc_cs_sr_upper8),
        .dc_cs_o_datasize               (dc_cs_datasize),
        .dc_cs_o_st_optimization_disable(dc_cs_st_optimization_disable),

        // mem_cs outputs
        .mem_cs_o_ST_OP                 (mem_cs_ST_OP),
        .mem_cs_o_LD_OP                 (mem_cs_LD_OP),
        .mem_cs_o_st_optimization_disable(mem_cs_st_optimization_disable),

        // exe_cs outputs
        .exe_cs_o_ST_OP                 (exe_cs_ST_OP),
        .exe_cs_o_OP_TYPE               (exe_cs_OP_TYPE),
        .exe_cs_o_alu_inputA_sel        (exe_cs_alu_inputA_sel),
        .exe_cs_o_alu_inputB_sel        (exe_cs_alu_inputB_sel),
        .exe_cs_o_branch_target_sel     (exe_cs_branch_target_sel),
        .exe_cs_o_shift_by_one          (exe_cs_shift_by_one),
        .exe_cs_o_br_ucond              (exe_cs_br_ucond),
        .exe_cs_o_relative_branch       (exe_cs_relative_branch),
        .exe_cs_o_special_br            (exe_cs_special_br),
        .exe_cs_o_is_far                (exe_cs_is_far),
        .exe_cs_o_is_call               (exe_cs_is_call),
        .exe_cs_o_second_flag_needed    (exe_cs_second_flag_needed),
        .exe_cs_o_rep_no_zf_update      (exe_cs_rep_no_zf_update),
        .exe_cs_o_st_optimization_disable(exe_cs_st_optimization_disable),

        // wb_cs outputs
        .wb_cs_o_ST_OP                  (wb_cs_ST_OP),
        .wb_cs_o_WB_DR                  (wb_cs_WB_DR),
        .wb_cs_o_WB_SR                  (wb_cs_WB_SR),
        .wb_cs_o_WB_EAX                 (wb_cs_WB_EAX),
        .wb_cs_o_st_optimization_disable(wb_cs_st_optimization_disable)
    );

endmodule
