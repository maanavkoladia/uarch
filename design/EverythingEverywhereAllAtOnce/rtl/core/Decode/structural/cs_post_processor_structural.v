module cs_post_processor (
    input wire          invalid_inst,
    input wire          xchg,
    input wire          cmpxchg,
    input wire          op_in_modrm,
    input wire [`OP_IN_MODRM_W-1:0]    op_in_modrm_subset,
    input wire [7:0]    modrm_byte,

    // decode_cs inputs
    input wire          decode_cs_i_REP,
    input wire          decode_cs_i_REP_CMP,
    input wire          decode_cs_i_HALT,
    input wire          decode_cs_i_MODRM_NEEDED,
    input wire          decode_cs_i_RM_IS_DR,
    input wire          decode_cs_i_REG_IS_DR,
    input wire          decode_cs_i_REG_IS_SEGMENT,
    input wire          decode_cs_i_HARDCODED_DR_HIGH8,
    input wire          decode_cs_i_MODRM_BUT_NO_SR,
    input wire          decode_cs_i_HARDCODED_DR,
    input wire [`REG_ID_W-1:0] decode_cs_i_HARDCODED_DR_ID,
    input wire          decode_cs_i_HARDCODED_SR,
    input wire [`REG_ID_W-1:0] decode_cs_i_HARDCODED_SR_ID,
    input wire          decode_cs_i_HARDCODED_DR_RD,
    input wire          decode_cs_i_HARDCODED_DR_WR,
    input wire          decode_cs_i_HARDCODED_SR_RD,
    input wire          decode_cs_i_HARDCODED_SR_WR,
    input wire          decode_cs_i_HARDCODED_LD_OP,
    input wire          decode_cs_i_HARDCODED_ST_OP,
    input wire          decode_cs_i_LD_OP_CANCEL,
    input wire          decode_cs_i_ST_OP_CANCEL,
    input wire          decode_cs_i_OP_IN_MODRM,
    input wire [1:0]    decode_cs_i_DATA_SIZE,

    // rr_cs inputs
    input wire          rr_cs_i_ST_SEL,
    input wire          rr_cs_i_MODRM_NEEDED,
    input wire          rr_cs_i_RM_IS_DR,
    input wire          rr_cs_i_SWITCH_LD_ADDY,
    input wire          rr_cs_i_LD_OP,
    input wire          rr_cs_i_ST_OP,
    input wire          rr_cs_i_MOVS_OP,
    input wire [`REG_ID_W-1:0] rr_cs_i_dr_id,
    input wire [`REG_ID_W-1:0] rr_cs_i_sr_id,
    input wire          rr_cs_i_dr_rd,
    input wire          rr_cs_i_sr_rd,
    input wire          rr_cs_i_eax_rd,
    input wire          rr_cs_i_dr_wr,
    input wire          rr_cs_i_sr_wr,
    input wire          rr_cs_i_eax_wr,
    input wire [1:0]    rr_cs_i_datasize,
    input wire          rr_cs_i_will_mod_zf,
    input wire          rr_cs_i_seg_1_valid,
    input wire [`REG_ID_W-1:0] rr_cs_i_seg_0_id,
    input wire [`REG_ID_W-1:0] rr_cs_i_seg_1_id,
    input wire          rr_cs_i_special_modrm_bs,
    input wire          rr_cs_i_special_br,

    // dc_cs inputs
    input wire          dc_cs_i_LD_OP,
    input wire          dc_cs_i_ST_OP,
    input wire          dc_cs_i_dr_upper8,
    input wire          dc_cs_i_sr_upper8,
    input wire [1:0]    dc_cs_i_datasize,

    // mem_cs inputs
    input wire          mem_cs_i_ST_OP,
    input wire          mem_cs_i_LD_OP,

    // exe_cs inputs
    input wire          exe_cs_i_ST_OP,
    input wire [`EXE_OP_W-1:0] exe_cs_i_OP_TYPE,
    input wire [`SRC_SEL_W-1:0] exe_cs_i_alu_inputA_sel,
    input wire [`SRC_SEL_W-1:0] exe_cs_i_alu_inputB_sel,
    input wire [`SRC_SEL_W-1:0] exe_cs_i_branch_target_sel,
    input wire          exe_cs_i_shift_by_one,
    input wire          exe_cs_i_br_ucond,
    input wire          exe_cs_i_relative_branch,
    input wire          exe_cs_i_special_br,
    input wire          exe_cs_i_is_far,
    input wire          exe_cs_i_is_call,
    input wire          exe_cs_i_second_flag_needed,
    input wire          exe_cs_i_rep_no_zf_update,

    // wb_cs inputs
    input wire          wb_cs_i_ST_OP,
    input wire          wb_cs_i_WB_DR,
    input wire          wb_cs_i_WB_SR,
    input wire          wb_cs_i_WB_EAX,

    // decode_cs outputs (passthrough)
    output wire         decode_cs_o_REP,
    output wire         decode_cs_o_REP_CMP,
    output wire         decode_cs_o_HALT,
    output wire         decode_cs_o_MODRM_NEEDED,
    output wire         decode_cs_o_RM_IS_DR,
    output wire         decode_cs_o_REG_IS_DR,
    output wire         decode_cs_o_REG_IS_SEGMENT,
    output wire         decode_cs_o_HARDCODED_DR_HIGH8,
    output wire         decode_cs_o_MODRM_BUT_NO_SR,
    output wire         decode_cs_o_HARDCODED_DR,
    output wire [`REG_ID_W-1:0] decode_cs_o_HARDCODED_DR_ID,
    output wire         decode_cs_o_HARDCODED_SR,
    output wire [`REG_ID_W-1:0] decode_cs_o_HARDCODED_SR_ID,
    output wire         decode_cs_o_HARDCODED_DR_RD,
    output wire         decode_cs_o_HARDCODED_DR_WR,
    output wire         decode_cs_o_HARDCODED_SR_RD,
    output wire         decode_cs_o_HARDCODED_SR_WR,
    output wire         decode_cs_o_HARDCODED_LD_OP,
    output wire         decode_cs_o_HARDCODED_ST_OP,
    output wire         decode_cs_o_LD_OP_CANCEL,
    output wire         decode_cs_o_ST_OP_CANCEL,
    output wire         decode_cs_o_OP_IN_MODRM,
    output wire [1:0]   decode_cs_o_DATA_SIZE,

    // rr_cs outputs
    output wire         rr_cs_o_ST_SEL,
    output wire         rr_cs_o_MODRM_NEEDED,
    output wire         rr_cs_o_RM_IS_DR,
    output wire         rr_cs_o_SWITCH_LD_ADDY,
    output wire         rr_cs_o_LD_OP,
    output wire         rr_cs_o_ST_OP,
    output wire         rr_cs_o_MOVS_OP,
    output wire [`REG_ID_W-1:0] rr_cs_o_dr_id,
    output wire [`REG_ID_W-1:0] rr_cs_o_sr_id,
    output wire         rr_cs_o_dr_rd,
    output wire         rr_cs_o_sr_rd,
    output wire         rr_cs_o_eax_rd,
    output wire         rr_cs_o_dr_wr,
    output wire         rr_cs_o_sr_wr,
    output wire         rr_cs_o_eax_wr,
    output wire [1:0]   rr_cs_o_datasize,
    output wire         rr_cs_o_will_mod_zf,
    output wire         rr_cs_o_seg_1_valid,
    output wire [`REG_ID_W-1:0] rr_cs_o_seg_0_id,
    output wire [`REG_ID_W-1:0] rr_cs_o_seg_1_id,
    output wire         rr_cs_o_special_modrm_bs,
    output wire         rr_cs_o_special_br,

    // dc_cs outputs
    output wire         dc_cs_o_LD_OP,
    output wire         dc_cs_o_ST_OP,
    output wire         dc_cs_o_dr_upper8,
    output wire         dc_cs_o_sr_upper8,
    output wire [1:0]   dc_cs_o_datasize,

    // mem_cs outputs
    output wire         mem_cs_o_ST_OP,
    output wire         mem_cs_o_LD_OP,

    // exe_cs outputs
    output wire         exe_cs_o_ST_OP,
    output wire [`EXE_OP_W-1:0] exe_cs_o_OP_TYPE,
    output wire [`SRC_SEL_W-1:0] exe_cs_o_alu_inputA_sel,
    output wire [`SRC_SEL_W-1:0] exe_cs_o_alu_inputB_sel,
    output wire [`SRC_SEL_W-1:0] exe_cs_o_branch_target_sel,
    output wire         exe_cs_o_shift_by_one,
    output wire         exe_cs_o_br_ucond,
    output wire         exe_cs_o_relative_branch,
    output wire         exe_cs_o_special_br,
    output wire         exe_cs_o_is_far,
    output wire         exe_cs_o_is_call,
    output wire         exe_cs_o_second_flag_needed,
    output wire         exe_cs_o_rep_no_zf_update,

    // wb_cs outputs
    output wire         wb_cs_o_ST_OP,
    output wire         wb_cs_o_WB_DR,
    output wire         wb_cs_o_WB_SR,
    output wire         wb_cs_o_WB_EAX
);

    wire [2:0] reg_field;
    assign reg_field = modrm_byte[5:3];

    wire rr_cs_o_LD_OP_holder;
    assign rr_cs_o_LD_OP_holder = invalid_inst ? 1'b0 : rr_cs_i_LD_OP;

    // =====================
    // op_in_modrm_subset decode
    // =====================
    wire is_CTRL, is_SHF, is_ALU, is_NONE;
    `CMP_N(op_subset_is_CTRL, `OP_IN_MODRM_W, is_CTRL, op_in_modrm_subset, `CTRL)
    `CMP_N(op_subset_is_SHF,  `OP_IN_MODRM_W, is_SHF,  op_in_modrm_subset, `SHF)
    `CMP_N(op_subset_is_ALU,  `OP_IN_MODRM_W, is_ALU,  op_in_modrm_subset, `ALU)
    `CMP_N(op_subset_is_NONE,  `OP_IN_MODRM_W, is_NONE,  op_in_modrm_subset, `NONE)

    // reg_field[5:3] comparators
    wire rf_eq0, rf_eq1, rf_eq2, rf_eq3, rf_eq4, rf_eq6, rf_eq7;
    `CMP_N(reg_field_eq0, 3, rf_eq0, reg_field, 3'd0)
    `CMP_N(reg_field_eq1, 3, rf_eq1, reg_field, 3'd1)
    `CMP_N(reg_field_eq2, 3, rf_eq2, reg_field, 3'd2)
    `CMP_N(reg_field_eq3, 3, rf_eq3, reg_field, 3'd3)
    `CMP_N(reg_field_eq4, 3, rf_eq4, reg_field, 3'd4)
    `CMP_N(reg_field_eq6, 3, rf_eq6, reg_field, 3'd6)
    `CMP_N(reg_field_eq7, 3, rf_eq7, reg_field, 3'd7)

    // ff_call / ff_jmp / ff_push: only active when CTRL and matching reg_field
    wire ff_jmp, ff_push, ff_call;
    `AND_2(ff_call_gate, 1, ff_call, is_CTRL, rf_eq2)
    `AND_2(ff_jmp_gate,  1, ff_jmp,  is_CTRL, rf_eq4)
    `AND_2(ff_push_gate, 1, ff_push, is_CTRL, rf_eq6)

    // overriden_br_sel
    wire [`SRC_SEL_W-1:0] overriden_br_sel;
    `MUX_4(overriden_br_sel_mux, `SRC_SEL_W, overriden_br_sel, 
            exe_cs_i_branch_target_sel,
            exe_cs_i_branch_target_sel, 
            `DR_REGISTER,
            `BUF32,
            {is_CTRL, rr_cs_o_LD_OP_holder})

    //shf, ctrl, alu optype selection for each
    wire [`EXE_OP_W-1:0] shf_overriden_op_type, ctrl_overriden_op_type, alu_overriden_op_type, alu_overriden_sub_op_type;
    wire [`EXE_OP_W-1:0] overriden_op_type;
    `MUX_2(shf_overriden_op_type_mux, `EXE_OP_W, shf_overriden_op_type, `SAR, `SAL, rf_eq4)
    `MUX_4(ctrl_overriden_op_type_mux, `EXE_OP_W, ctrl_overriden_op_type, 
            `PUSH,
            `CALL, 
            `JMP, 
            `CALL, 
            {rf_eq4, rf_eq2})
    `MUX_2(alu_overriden_sub_op_type_mux, `EXE_OP_W, alu_overriden_sub_op_type, `AND, `SBB, rf_eq3)
    `MUX_8(alu_overriden_op_type_mux, `EXE_OP_W, alu_overriden_op_type,
                alu_overriden_sub_op_type,
                `ADD,
                `OR,
                alu_overriden_sub_op_type,
                `ADC,
                alu_overriden_sub_op_type,
                alu_overriden_sub_op_type,
                alu_overriden_sub_op_type,
                {rf_eq2, rf_eq1, rf_eq0})
    
    //shf, alu, ctrl, optype selction between each
    `MUX_4(total_overriden_op_type_mux, `EXE_OP_W, overriden_op_type, 
            exe_cs_i_OP_TYPE,
            ctrl_overriden_op_type, 
            shf_overriden_op_type, 
            alu_overriden_op_type, 
            op_in_modrm_subset)
    

    


    // =====================
    // DECODE (passthrough)
    // =====================
    assign decode_cs_o_REP                = decode_cs_i_REP;
    assign decode_cs_o_REP_CMP            = decode_cs_i_REP_CMP;
    assign decode_cs_o_HALT               = decode_cs_i_HALT;
    assign decode_cs_o_MODRM_NEEDED       = decode_cs_i_MODRM_NEEDED;
    assign decode_cs_o_RM_IS_DR           = decode_cs_i_RM_IS_DR;
    assign decode_cs_o_REG_IS_DR          = decode_cs_i_REG_IS_DR;
    assign decode_cs_o_REG_IS_SEGMENT     = decode_cs_i_REG_IS_SEGMENT;
    assign decode_cs_o_HARDCODED_DR_HIGH8 = decode_cs_i_HARDCODED_DR_HIGH8;
    assign decode_cs_o_MODRM_BUT_NO_SR    = decode_cs_i_MODRM_BUT_NO_SR;
    assign decode_cs_o_HARDCODED_DR       = decode_cs_i_HARDCODED_DR;
    assign decode_cs_o_HARDCODED_DR_ID    = decode_cs_i_HARDCODED_DR_ID;
    assign decode_cs_o_HARDCODED_SR       = decode_cs_i_HARDCODED_SR;
    assign decode_cs_o_HARDCODED_SR_ID    = decode_cs_i_HARDCODED_SR_ID;
    assign decode_cs_o_HARDCODED_DR_RD    = decode_cs_i_HARDCODED_DR_RD;
    assign decode_cs_o_HARDCODED_DR_WR    = decode_cs_i_HARDCODED_DR_WR;
    assign decode_cs_o_HARDCODED_SR_RD    = decode_cs_i_HARDCODED_SR_RD;
    assign decode_cs_o_HARDCODED_SR_WR    = decode_cs_i_HARDCODED_SR_WR;
    assign decode_cs_o_HARDCODED_LD_OP    = decode_cs_i_HARDCODED_LD_OP;
    assign decode_cs_o_HARDCODED_ST_OP    = decode_cs_i_HARDCODED_ST_OP;
    assign decode_cs_o_LD_OP_CANCEL       = decode_cs_i_LD_OP_CANCEL;
    assign decode_cs_o_ST_OP_CANCEL       = decode_cs_i_ST_OP_CANCEL;
    assign decode_cs_o_OP_IN_MODRM        = decode_cs_i_OP_IN_MODRM;
    assign decode_cs_o_DATA_SIZE          = decode_cs_i_DATA_SIZE;

    // =====================
    // RR
    // =====================
    assign rr_cs_o_ST_SEL          = ff_jmp ? 1'b0 : rr_cs_i_ST_SEL;
    assign rr_cs_o_MODRM_NEEDED    = rr_cs_i_MODRM_NEEDED;
    assign rr_cs_o_RM_IS_DR        = rr_cs_i_RM_IS_DR;
    assign rr_cs_o_SWITCH_LD_ADDY  = rr_cs_i_SWITCH_LD_ADDY;
    assign rr_cs_o_LD_OP           = rr_cs_o_LD_OP_holder;
    assign rr_cs_o_ST_OP           = invalid_inst ? 1'b0 : ff_jmp ? 1'b0 : rr_cs_i_ST_OP;
    assign rr_cs_o_MOVS_OP         = rr_cs_i_MOVS_OP;
    assign rr_cs_o_dr_id           = rr_cs_i_dr_id;
    assign rr_cs_o_sr_id           = ff_jmp ? `NO_REG : rr_cs_i_sr_id;
    assign rr_cs_o_dr_rd           = rr_cs_i_dr_rd;
    assign rr_cs_o_sr_rd           = ff_jmp ? 1'b0 : rr_cs_i_sr_rd;
    assign rr_cs_o_eax_rd          = cmpxchg ? 1'b1 : 1'b0;
    assign rr_cs_o_dr_wr           = invalid_inst ? 1'b0 : (ff_jmp || ff_call || ff_push) ? 1'b0 : rr_cs_i_dr_wr;
    assign rr_cs_o_sr_wr           = invalid_inst ? 1'b0 : xchg ? 1'b1 : ff_jmp ? 1'b0 : rr_cs_i_sr_wr;
    assign rr_cs_o_eax_wr          = invalid_inst ? 1'b0 : cmpxchg ? 1'b1 : 1'b0;
    assign rr_cs_o_datasize        = rr_cs_i_datasize;
    assign rr_cs_o_will_mod_zf     = rr_cs_i_will_mod_zf;
    assign rr_cs_o_seg_1_valid     = ff_jmp ? 1'b0 : rr_cs_i_seg_1_valid;
    assign rr_cs_o_seg_0_id        = ff_push ? `DS : rr_cs_i_seg_0_id;
    assign rr_cs_o_seg_1_id        = rr_cs_i_seg_1_id;
    assign rr_cs_o_special_modrm_bs = rr_cs_i_special_modrm_bs;
    assign rr_cs_o_special_br      = rr_cs_i_special_br;

    // =====================
    // DC
    // =====================
    assign dc_cs_o_LD_OP                  = invalid_inst ? 1'b0 : dc_cs_i_LD_OP;
    assign dc_cs_o_ST_OP                  = invalid_inst ? 1'b0 : ff_jmp ? 1'b0 : dc_cs_i_ST_OP;
    assign dc_cs_o_dr_upper8              = dc_cs_i_dr_upper8;
    assign dc_cs_o_sr_upper8              = dc_cs_i_sr_upper8;
    assign dc_cs_o_datasize               = dc_cs_i_datasize;

    // =====================
    // MEM
    // =====================
    assign mem_cs_o_LD_OP                  = invalid_inst ? 1'b0 : mem_cs_i_LD_OP;
    assign mem_cs_o_ST_OP                  = invalid_inst ? 1'b0 : ff_jmp ? 1'b0 : mem_cs_i_ST_OP;

    // =====================
    // EXE
    // =====================
    assign exe_cs_o_ST_OP              = invalid_inst ? 1'b0 : ff_jmp ? 1'b0 : mem_cs_i_ST_OP;
    assign exe_cs_o_OP_TYPE            = op_in_modrm ? overriden_op_type : exe_cs_i_OP_TYPE;
    assign exe_cs_o_alu_inputA_sel     = ff_jmp ? `NO_EXE : ff_call ? `NEIP : exe_cs_i_alu_inputA_sel;
    assign exe_cs_o_alu_inputB_sel     = ff_jmp ? `NO_EXE : exe_cs_i_alu_inputB_sel;
    assign exe_cs_o_branch_target_sel  = op_in_modrm ? overriden_br_sel : exe_cs_i_branch_target_sel;
    assign exe_cs_o_shift_by_one       = exe_cs_i_shift_by_one;
    assign exe_cs_o_br_ucond           = ff_push ? 1'b0 : exe_cs_i_br_ucond;
    assign exe_cs_o_relative_branch    = exe_cs_i_relative_branch;
    assign exe_cs_o_special_br         = exe_cs_i_special_br;
    assign exe_cs_o_is_far             = exe_cs_i_is_far;
    assign exe_cs_o_is_call            = (ff_jmp || ff_push) ? 1'b0 : exe_cs_i_is_call;
    assign exe_cs_o_second_flag_needed = exe_cs_i_second_flag_needed;
    assign exe_cs_o_rep_no_zf_update   = 1'b0;
    // =====================
    // WB
    // =====================
    assign wb_cs_o_ST_OP                  = invalid_inst ? 1'b0 : ff_jmp ? 1'b0 : mem_cs_i_ST_OP;
    assign wb_cs_o_WB_DR                  = invalid_inst ? 1'b0 : (ff_jmp || ff_call || ff_push) ? 1'b0 : rr_cs_i_dr_wr;
    assign wb_cs_o_WB_SR                  = invalid_inst ? 1'b0 : xchg ? 1'b1 : ff_jmp ? 1'b0 : rr_cs_i_sr_wr;
    assign wb_cs_o_WB_EAX                 = invalid_inst ? 1'b0 : cmpxchg ? 1'b1 : 1'b0;

endmodule
