import core_stage_latches_pkg::*;
import reg_ids_pkg::*;
import Decode_pkg::*;
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
    // Packed output wires
    // =====================

    // HARD_CODED_DR_ID[5:0]
    logic [5:0] HARD_CODED_DR_ID;

    logic RM_IS_DR;
    logic REG_IS_DR;

    // Single-bit signals
    logic REP;
    logic MODRM_NEEDED;
    logic HARD_CODED_DR;
    logic HARD_CODED_SR;
    logic HARD_CODED_SR_ID;
    logic OP_IN_MODRM;

    // DATA_SIZE[2:0]
    logic [2:0] DATA_SIZE;

    // Misc control
    logic RR_OP;
    logic HARDCODED_DR_RD;
    logic HARDCODED_SR_RD;
    logic ST_SEL;
    logic DC_OP;
    logic MEM_OP;
    logic EXE_OP;

    // ALU selects
    logic [3:0] alu_inputA_sel;
    logic [3:0] alu_inputB_sel;

    // Branch target select
    logic [3:0] branch_target_sel;

    // OP_TYPE[5:0]
    logic [5:0] OP_TYPE;

    // Branch/control flags
    logic br_uncond;
    logic relative_branch;
    logic special_dr;
    logic is_far;
    logic second_flag_needed;

    logic WB_OP;

    // =====================
    // Module instantiation
    // =====================

    cs control_store(
        .REP_o(REP),
        .MODRM_NEEDED_o(MODRM_NEEDED),
        .HARD_CODED_DR_o(HARD_CODED_DR),

        .RM_IS_DR_o(RM_IS_DR),
        .REG_IS_DR_o(REG_IS_DR),

        // Packed DR IDs
        .HARD_CODED_DR_ID5_o(HARD_CODED_DR_ID[5]),
        .HARD_CODED_DR_ID4_o(HARD_CODED_DR_ID[4]),
        .HARD_CODED_DR_ID3_o(HARD_CODED_DR_ID[3]),
        .HARD_CODED_DR_ID2_o(HARD_CODED_DR_ID[2]),
        .HARD_CODED_DR_ID1_o(HARD_CODED_DR_ID[1]),
        .HARD_CODED_DR_ID0_o(HARD_CODED_DR_ID[0]),

        .HARD_CODED_SR_o(HARD_CODED_SR),
        .HARD_CODED_SR_ID_o(HARD_CODED_SR_ID),
        .OP_IN_MODRM_o(OP_IN_MODRM),

        // DATA_SIZE
        .DATA_SIZE2_o(DATA_SIZE[2]),
        .DATA_SIZE1_o(DATA_SIZE[1]),
        .DATA_SIZE0_o(DATA_SIZE[0]),

        .RR_OP_o(RR_OP),
        .HARDCODED_DR_RD_o(HARDCODED_DR_RD),
        .HARDCODED_SR_RD_o(HARDCODED_SR_RD),
        .ST_SEL_o(ST_SEL),
        .DC_OP_o(DC_OP),
        .MEM_OP_o(MEM_OP),
        .EXE_OP_o(EXE_OP),

        // ALU A
        .alu_inputA_sel3_o(alu_inputA_sel[3]),
        .alu_inputA_sel2_o(alu_inputA_sel[2]),
        .alu_inputA_sel1_o(alu_inputA_sel[1]),
        .alu_inputA_sel0_o(alu_inputA_sel[0]),

        // ALU B
        .alu_inputB_sel3_o(alu_inputB_sel[3]),
        .alu_inputB_sel2_o(alu_inputB_sel[2]),
        .alu_inputB_sel1_o(alu_inputB_sel[1]),
        .alu_inputB_sel0_o(alu_inputB_sel[0]),

        // Branch target
        .branch_target_sel3_o(branch_target_sel[3]),
        .branch_target_sel2_o(branch_target_sel[2]),
        .branch_target_sel1_o(branch_target_sel[1]),
        .branch_target_sel0_o(branch_target_sel[0]),

        // OP_TYPE
        .OP_TYPE5_o(OP_TYPE[5]),
        .OP_TYPE4_o(OP_TYPE[4]),
        .OP_TYPE3_o(OP_TYPE[3]),
        .OP_TYPE2_o(OP_TYPE[2]),
        .OP_TYPE1_o(OP_TYPE[1]),
        .OP_TYPE0_o(OP_TYPE[0]),

        .br_uncond_o(br_uncond),
        .relative_branch_o(relative_branch),
        .special_dr_o(special_dr),
        .is_far_o(is_far),
        .second_flag_needed_o(second_flag_needed),

        .WB_OP_o(WB_OP),

        // Input bus slicing
        .input9_i(input_bus[9]),
        .input8_i(input_bus[8]),
        .input7_i(input_bus[7]),
        .input6_i(input_bus[6]),
        .input5_i(input_bus[5]),
        .input4_i(input_bus[4]),
        .input3_i(input_bus[3]),
        .input2_i(input_bus[2]),
        .input1_i(input_bus[1]),
        .input0_i(input_bus[0])
    );

    modrm_processor_outs_t mod_rm_cs_outs;
    modrm_processor mod_rm_cs_gen(.modrm_byte(modrm), .datasize(DATA_SIZE), .decode_cs_inputs(decode_cs), .outputs(mod_rm_cs_outs));



    // =====================
    // Struct Initializations
    // =====================

    // DECODE
    assign decode_cs = '{
        REP               : REP,
        MODRM_NEEDED      : MODRM_NEEDED,
        RM_IS_DR          : RM_IS_DR,
        REG_IS_DR         : REG_IS_DR,
        HARDCODED_DR      : HARD_CODED_DR,
        HARDCODED_DR_ID   : HARD_CODED_DR_ID,
        HARDCODED_SR      : HARD_CODED_SR,
        HARDCODED_SR_ID   : HARD_CODED_SR_ID,
        OP_IN_MODRM       : OP_IN_MODRM,
        dr_id             : mod_rm_cs_outs.dr_id,
        sr_id             : mod_rm_cs_outs.sr_id,
        DATA_SIZE         : DATA_SIZE
    };

    // RR
    assign rr_cs = '{
        RR_OP            : RR_OP,
        HARDCODED_DR_RD  : HARDCODED_DR_RD,
        HARDCODED_SR_RD  : HARDCODED_SR_RD,
        ST_SEL           : ST_SEL,
        MODRM_NEEDED     : MODRM_NEEDED,
        RM_IS_DR         : RM_IS_DR,
        LD_OP            : mod_rm_cs_outs.ld_op,
        ST_OP            : mod_rm_cs_outs.st_op,
        dr_id            : mod_rm_cs_outs.dr_id,
        sr_id            : mod_rm_cs_outs.sr_id,
        dr_rd            : mod_rm_cs_outs.dr_rd,
        sr_rd            : mod_rm_cs_outs.sr_rd,
        dr_wr            : mod_rm_cs_outs.dr_wr,
        sr_wr            : mod_rm_cs_outs.sr_wr,
        st_op            : mod_rm_cs_outs.st_op,
        ld_op            : mod_rm_cs_outs.ld_op,
        datasize         : DATA_SIZE,
        will_mod_zf      : 1'b0             //need to add this to cs excel sheet
    };

    // DC
    assign dc_cs = '{
        DC_OP : DC_OP,
        LD_OP : mod_rm_cs_outs.ld_op,
        ST_OP : mod_rm_cs_outs.st_op
    };

    // MEM
    assign mem_cs = '{
        MEM_OP : MEM_OP,
        ST_OP  : mod_rm_cs_outs.st_op,
        LD_OP  : mod_rm_cs_outs.ld_op
    };

    // EXE
    assign exe_cs = '{
        EXE_OP              : EXE_OP,
        ST_OP               : mod_rm_cs_outs.st_op,
        DATA_SIZE           : DATA_SIZE,
        OP_TYPE             : OP_TYPE,

        alu_inputA_sel      : alu_inputA_sel,
        alu_inputB_sel      : alu_inputB_sel,
        branch_target_sel   : branch_target_sel,

        br_ucond            : br_uncond,
        relative_branch     : relative_branch,
        special_br          : special_dr,
        is_far              : is_far,
        second_flag_needed  : second_flag_needed
    };

    // WB
    assign wb_cs = '{
        WB_OP : WB_OP,
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
