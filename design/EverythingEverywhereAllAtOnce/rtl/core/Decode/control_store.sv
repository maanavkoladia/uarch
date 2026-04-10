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
    //wire [63:0] cs_out[2];
    //logic [9:0] rom_index;
    //assign rom_index = {(total_pf_vector[0] || total_pf_vector[1]), opcode, total_pf_vector[3]};

    // =====================
    // Input wires
    // =====================
    logic [9:0] input_bus;
    assign input_bus = {(total_pf_vector[0] || total_pf_vector[1]), opcode, total_pf_vector[3]};
    // =====================
    // Packed output wires (FROM cs_parsed)
    // =====================

    // Single-bit
    logic MODRM_NEEDED_o;
    logic RM_IS_DR_o;
    logic REG_IS_DR_o;
    logic HARD_CODED_DR_o;
    logic HARD_CODED_SR_o;
    logic OP_IN_MODRM_o;

    logic HARDCODED_DR_RD_o;
    logic HARDCODED_SR_RD_o;
    logic ST_SEL_o;

    logic br_uncond_o;
    logic relative_branch_o;
    logic special_dr_o;
    logic is_far_o;
    logic second_flag_needed_o;

    logic REP_o;

    // Packed fields
    logic [4:0] HARD_CODED_DR_ID_o;
    logic [4:0] HARD_CODED_SR_ID_o;
    logic [2:0] DATA_SIZE_o;

    logic [4:0] alu_inputA_sel_o;
    logic [4:0] alu_inputB_sel_o;
    logic [4:0] branch_target_sel_o;

    logic [4:0] OP_TYPE_o; // (fix width to 5 unless you truly have 6 bits)
    // =====================
    // Module instantiation
    // =====================

    cs_parsed control_store (
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
        .MODRM_NEEDED_o(MODRM_NEEDED_o),
        .RM_IS_DR_o(RM_IS_DR_o),
        .REG_IS_DR_o(REG_IS_DR_o),
        
        .OP_IN_MODRM_o(OP_IN_MODRM_o),

        // Op Enables / Selects
        .HARDCODED_DR_RD_o(HARDCODED_DR_RD_o),
        .HARDCODED_SR_RD_o(HARDCODED_SR_RD_o),
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
        .DATA_SIZE_2_o(DATA_SIZE_o[2]),
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
        .special_dr_o(special_dr_o),
        .is_far_o(is_far_o),
        .second_flag_needed_o(second_flag_needed_o)
    );

    modrm_processor_outs_t mod_rm_cs_outs;
    modrm_processor mod_rm_cs_gen(.modrm_byte(modrm), .datasize(DATA_SIZE_o), .decode_cs_inputs(decode_cs), .outputs(mod_rm_cs_outs));



    // DECODE
    assign decode_cs = '{
        REP               : REP_o,
        MODRM_NEEDED      : MODRM_NEEDED_o,
        RM_IS_DR          : RM_IS_DR_o,
        REG_IS_DR         : REG_IS_DR_o,
        HARDCODED_DR      : HARD_CODED_DR_o,
        HARDCODED_DR_ID   : HARD_CODED_DR_ID_o,
        HARDCODED_SR      : HARD_CODED_SR_o,
        HARDCODED_SR_ID   : HARD_CODED_SR_ID_o,
        HARDCODED_DR_RD   : HARDCODED_DR_RD_o,
        HARDCODED_SR_RD   : HARDCODED_SR_RD_o,
        OP_IN_MODRM       : OP_IN_MODRM_o,
        dr_id             : mod_rm_cs_outs.dr_id,
        sr_id             : mod_rm_cs_outs.sr_id,
        DATA_SIZE         : DATA_SIZE_o
    };

    // RR
    assign rr_cs = '{
        HARDCODED_DR_RD  : HARDCODED_DR_RD_o,
        HARDCODED_SR_RD  : HARDCODED_SR_RD_o,
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
        will_mod_zf      : 1'b0
    };

    // DC
    assign dc_cs = '{
        LD_OP : mod_rm_cs_outs.ld_op,
        ST_OP : mod_rm_cs_outs.st_op,
        upper8: 0, //TODO
        data_size: DATA_SIZE_o
    };

    // MEM
    assign mem_cs = '{
        ST_OP  : mod_rm_cs_outs.st_op,
        LD_OP  : mod_rm_cs_outs.ld_op
    };

    // EXE
    assign exe_cs = '{
        ST_OP               : mod_rm_cs_outs.st_op,
        OP_TYPE             : OP_TYPE_o,

        alu_inputA_sel      : mod_rm_cs_outs.alu_inputA_override ?
                                mod_rm_cs_outs.alu_inputA_override_sel :
                                alu_inputA_sel_o,

        alu_inputB_sel      : mod_rm_cs_outs.alu_inputB_override ?
                                mod_rm_cs_outs.alu_inputB_override_sel :
                                alu_inputB_sel_o,

        branch_target_sel   : branch_target_sel_o,

        br_ucond            : br_uncond_o,
        relative_branch     : relative_branch_o,
        special_br          : special_dr_o,
        is_far              : is_far_o,
        second_flag_needed  : second_flag_needed_o
    };

    // WB
    assign wb_cs = '{
        ST_OP : mod_rm_cs_outs.st_op,
        WB_DR : mod_rm_cs_outs.dr_wr,
        WB_SR : mod_rm_cs_outs.sr_wr
    };





    // assign rr_cs = '{
    //     RR_OP       : cs_out[0][0],
    //     DR_RD      : cs_out[0][1],
    //     SR_RD   : cs_out[0][2],
    //     SIB_NEEDED  : cs_out[0][3],
    //     DISP_NEEDED : cs_out[0][4],
    //     DR_WR       : cs_out[0][5],
    //     SR_WR       : cs_out[0][6],
    //     ST_SEL      : cs_out[0][7],
    //     DR_SEL      : cs_out[0][8],
    //     LD_OP       : cs_out[0][9],
    //     ST_OP       : cs_out[0][10],
    //     datasize    : cs_out[0][11 +: 3],
    //     ld_flags    : 1'b0,                 //need to fill out
    //     flag_modified_vector : 32'b0       //need to fill out
    // };

    // assign dc_cs = '{
    //     DC_OP  : cs_out[0][14],
    //     LD_OP  : cs_out[0][15],
    //     ST_OP  : cs_out[0][16],
    //     MEM_OP : cs_out[0][17]
    // };

    // assign mem_cs = '{
    //     MEM_OP : cs_out[0][18],
    //     ST_OP  : cs_out[0][19],
    //     LD_OP  : cs_out[0][20]
    // };

    // assign exe_cs = '{
    //     EXE_OP              : cs_out[0][21],
    //     ST_OP               : cs_out[0][22],
    //     ld_flags            : cs_out[0][23],
    //     flag_modified_vector: cs_out[0][24 +: 32],
    //     xchg                : cs_out[0][56],
    //     DATA_SIZE           : cs_out[0][57 +: 3],
    //     alu_inputA_sel      : cs_out[0][60 +: 4],

    //     //start of second rom (horizontal stacking)
    //     alu_inputB_sel      : cs_out[1][0 +: 4],
    //     branch_target_sel   : cs_out[1][4 +: 4],
    //     OP_TYPE             : cs_out[1][8 +: 6],
    //     cmpxchg             : cs_out[1][14],
    //     cmovc               : cs_out[1][15],


    //     clear_df            : cs_out[1][16],
    //     set_df              : cs_out[1][17],
    //     br_ucond            : cs_out[1][18],
    //     relative_branch     : cs_out[1][19],
    //     special_br          : cs_out[1][20],
    //     is_far              : cs_out[1][21],
    //     second_flag_needed  : cs_out[1][22]
    // };

    // assign wb_cs = '{
    //     ST_OP : cs_out[1][23],
    //     WB_DR : cs_out[1][24],
    //     WB_SR : cs_out[1][25]
    // };
endmodule
