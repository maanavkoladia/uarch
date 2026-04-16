import core_stage_latches_pkg::*;
import reg_ids_pkg::*;
import Decode_pkg::*;
import control_store_pkg::*;
module control_store (
    input logic [9:0] total_pf_vector,
    input byte_t opcode,
    input byte_t modrm,
    output decode_cs_t decode_cs,
    output rr_cs_t rr_cs,
    output dc_cs_t dc_cs,
    output mem_cs_t mem_cs,
    output exe_cs_t exe_cs,
    output wb_cs_t wb_cs
);

    decode_cs_t temp_decode_cs;
    rr_cs_t temp_rr_cs;
    dc_cs_t temp_dc_cs;
    mem_cs_t temp_mem_cs;
    exe_cs_t temp_exe_cs;
    wb_cs_t temp_wb_cs;

    // =====================
    // Input wires
    // =====================
    //MSB --> 2e, 36, 3e, 26, 64, 65, 66, 67, 0f, f3  <-- LSB vector
    logic [9:0] input_bus;
    assign input_bus = {(total_pf_vector[0] || total_pf_vector[1]), opcode, total_pf_vector[3]};

    // =====================
    // Single-bit outputs
    // =====================
    logic REP_o;
    logic REP_CMP_o;
    logic HALT_o;
    logic MOVS_o;
    logic SHIFT_BY_ONE_o;

    logic MODRM_NEEDED_o;
    logic RM_IS_DR_o;
    logic REG_IS_DR_o;
    logic REG_IS_SEGMENT_o;

    logic HARD_CODED_DR_o;
    logic HARD_CODED_SR_o;

    logic OP_IN_MODRM_o;

    logic HARDCODED_DR_RD_o;
    logic HARDCODED_DR_WR_o;
    logic HARDCODED_SR_RD_o;
    logic HARDCODED_SR_WR_o;
    logic HARDCODED_LD_OP_o;
    logic HARDCODED_ST_OP_o;
    logic LD_OP_CANCEL_o;
    logic ST_OP_CANCEL_o;
    logic ST_SEL_o;

    logic br_uncond_o;
    logic relative_branch_o;
    logic special_br_o;
    logic is_far_o;
    logic second_flag_needed_o;

    logic will_mod_zf_o;

    logic HARDCODED_SEGMENT1_V_o;

    // =====================
    // Packed outputs
    // =====================
    logic [4:0] HARD_CODED_DR_ID_o;
    logic [4:0] HARD_CODED_SR_ID_o;

    logic [1:0] DATA_SIZE_o;

    logic [1:0] OP_IN_MODRM_SUBSET_o;

    logic [4:0] alu_inputA_sel_o;
    logic [4:0] alu_inputB_sel_o;
    logic [4:0] branch_target_sel_o;

    logic [4:0] OP_TYPE_o;

    logic [4:0] HARDCODED_SEGMENT0_o;
    logic [4:0] HARDCODED_SEGMENT1_o;
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
        .SHIFT_BY_ONE_o(SHIFT_BY_ONE_o),

        .MODRM_NEEDED_o(MODRM_NEEDED_o),
        .RM_IS_DR_o(RM_IS_DR_o),
        .REG_IS_DR_o(REG_IS_DR_o),
        .REG_IS_SEGMENT_o(REG_IS_SEGMENT_o),

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
        .second_flag_needed_o(second_flag_needed_o),

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

    modrm_processor_outs_t mod_rm_cs_outs;
    modrm_processor mod_rm_cs_gen(
        .modrm_byte(modrm), 
        .datasize(DATA_SIZE_o), 
        .decode_cs_inputs(decode_cs), 
        .outputs(mod_rm_cs_outs)
    );

    // DECODE
    assign temp_decode_cs = '{
        REP               : REP_o,
        REP_CMP           : REP_CMP_o,
        HALT              : HALT_o,
        MODRM_NEEDED      : MODRM_NEEDED_o,
        RM_IS_DR          : RM_IS_DR_o,
        REG_IS_DR         : REG_IS_DR_o,
        REG_IS_SEGMENT    : REG_IS_SEGMENT_o,
        HARDCODED_DR      : HARD_CODED_DR_o,
        HARDCODED_DR_ID   : HARD_CODED_DR_ID_o,
        HARDCODED_SR      : HARD_CODED_SR_o,
        HARDCODED_SR_ID   : HARD_CODED_SR_ID_o,
        HARDCODED_DR_RD   : HARDCODED_DR_RD_o,
        HARDCODED_DR_WR   : HARDCODED_DR_WR_o,
        HARDCODED_SR_RD   : HARDCODED_SR_RD_o,
        HARDCODED_SR_WR   : HARDCODED_SR_WR_o,
        HARDCODED_LD_OP   : HARDCODED_LD_OP_o,
        HARDCODED_ST_OP   : HARDCODED_ST_OP_o,
        LD_OP_CANCEL      : LD_OP_CANCEL_o,
        ST_OP_CANCEL      : ST_OP_CANCEL_o,
        OP_IN_MODRM       : OP_IN_MODRM_o,
        dr_id             : mod_rm_cs_outs.dr_id,
        sr_id             : mod_rm_cs_outs.sr_id,
        DATA_SIZE         : DATA_SIZE_o
    };

    // RR
    assign temp_rr_cs = '{
        //HARDCODED_DR_RD  : HARDCODED_DR_RD_o,
        //HARDCODED_SR_RD  : HARDCODED_SR_RD_o,
        ST_SEL           : ST_SEL_o,
        MODRM_NEEDED     : MODRM_NEEDED_o,
        RM_IS_DR         : RM_IS_DR_o,
        LD_OP            : mod_rm_cs_outs.ld_op,
        ST_OP            : mod_rm_cs_outs.st_op,
        dr_id            : mod_rm_cs_outs.dr_id,
        sr_id            : mod_rm_cs_outs.sr_id,
        dr_rd            : mod_rm_cs_outs.dr_rd,
        sr_rd            : mod_rm_cs_outs.sr_rd,
        dr_wr            : mod_rm_cs_outs.dr_wr,
        sr_wr            : mod_rm_cs_outs.sr_wr,
        datasize         : DATA_SIZE_o,
        will_mod_zf      : will_mod_zf_o,
        seg_1_valid      : HARDCODED_SEGMENT1_V_o,
        seg_0_id         : HARDCODED_SEGMENT0_o,
        seg_1_id         : HARDCODED_SEGMENT1_o
    };

    // DC
    assign temp_dc_cs = '{
        LD_OP : mod_rm_cs_outs.ld_op,
        ST_OP : mod_rm_cs_outs.st_op,
        upper8: mod_rm_cs_outs.high8,
        datasize: DATA_SIZE_o
    };

    // MEM
    assign temp_mem_cs = '{
        ST_OP  : mod_rm_cs_outs.st_op,
        LD_OP  : mod_rm_cs_outs.ld_op
    };

    // EXE
    assign temp_exe_cs = '{
        ST_OP               : mod_rm_cs_outs.st_op,
        OP_TYPE             : OP_TYPE_o,

        alu_inputA_sel      : mod_rm_cs_outs.alu_inputA_override ?
                                mod_rm_cs_outs.alu_inputA_override_sel :
                                alu_inputA_sel_o,

        alu_inputB_sel      : mod_rm_cs_outs.alu_inputB_override ?
                                mod_rm_cs_outs.alu_inputB_override_sel :
                                alu_inputB_sel_o,

        branch_target_sel   : branch_target_sel_o,

        shift_by_one        : SHIFT_BY_ONE_o,

        br_ucond            : br_uncond_o,
        relative_branch     : relative_branch_o,
        special_br          : special_br_o,
        is_far              : is_far_o,
        second_flag_needed  : second_flag_needed_o
    };

    // WB
    assign temp_wb_cs = '{
        ST_OP : mod_rm_cs_outs.st_op,
        WB_DR : mod_rm_cs_outs.dr_wr,
        WB_SR : mod_rm_cs_outs.sr_wr
    };

    cs_post_processor cs_post_prossesing_unit(
        .modrm_byte(modrm),
        .movs(MOVS_o),
        .op_in_modrm(OP_IN_MODRM_o),
        .op_in_modrm_subset(OP_IN_MODRM_SUBSET_o),
        .decode_cs_i(temp_decode_cs),
        .rr_cs_i(temp_rr_cs),
        .dc_cs_i(temp_dc_cs),
        .mem_cs_i(temp_mem_cs),
        .exe_cs_i(temp_exe_cs),
        .wb_cs_i(temp_wb_cs),
        .decode_cs_o(decode_cs),
        .rr_cs_o(rr_cs),
        .dc_cs_o(dc_cs),
        .mem_cs_o(mem_cs),
        .exe_cs_o(exe_cs),
        .wb_cs_o(wb_cs)
    );

endmodule
