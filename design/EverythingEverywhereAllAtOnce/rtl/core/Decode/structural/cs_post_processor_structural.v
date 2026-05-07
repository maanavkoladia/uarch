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

    // Parallel ld-op-holder muxes: independent drivers for the high-fanout
    // net split between overriden_br_sel_mux's H8 lo/hi halves and the
    // rr_cs_o_LD_OP output port, replacing what would otherwise be a
    // single-source fanout-of-6 violation.
    wire rr_cs_o_LD_OP_holder, rr_cs_o_LD_OP_holder_duplicate;
    `MUX_2(ld_op_holder_mux,     1, rr_cs_o_LD_OP_holder,           rr_cs_i_LD_OP, 1'b0, invalid_inst)
    `MUX_2(ld_op_holder_mux_dup, 1, rr_cs_o_LD_OP_holder_duplicate, rr_cs_i_LD_OP, 1'b0, invalid_inst)

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

    // fanout duplicates: parallel comparators driven independently
    wire rf_eq0_duplicate, rf_eq1_duplicate, rf_eq2_duplicate, rf_eq3_duplicate, rf_eq4_duplicate;
    `CMP_N(reg_field_eq0_dup, 3, rf_eq0_duplicate, reg_field, 3'd0)
    `CMP_N(reg_field_eq1_dup, 3, rf_eq1_duplicate, reg_field, 3'd1)
    `CMP_N(reg_field_eq2_dup, 3, rf_eq2_duplicate, reg_field, 3'd2)
    `CMP_N(reg_field_eq3_dup, 3, rf_eq3_duplicate, reg_field, 3'd3)
    `CMP_N(reg_field_eq4_dup, 3, rf_eq4_duplicate, reg_field, 3'd4)

    // fanout duplicate of op_in_modrm_subset via buffer
    wire [`OP_IN_MODRM_W-1:0] op_in_modrm_subset_duplicate;
    `BUFFER_DELAY(op_in_modrm_subset_dup_buf, 1, `OP_IN_MODRM_W, op_in_modrm_subset, op_in_modrm_subset_duplicate)

    // ff_call / ff_jmp / ff_push: only active when CTRL and matching reg_field
    wire ff_jmp, ff_push, ff_call;
    `AND_2(ff_call_gate, 1, ff_call, is_CTRL, rf_eq2)
    `AND_2(ff_jmp_gate,  1, ff_jmp,  is_CTRL, rf_eq4)
    `AND_2(ff_push_gate, 1, ff_push, is_CTRL, rf_eq6)

    // combined condition wires reused across sections
    wire ff_jmp_call_push;
    `OR_3(ff_jmp_call_push_or, 1, ff_jmp_call_push, ff_jmp, ff_call, ff_push)

    wire ff_jmp_push;
    `OR_2(ff_jmp_push_or, 1, ff_jmp_push, ff_jmp, ff_push)

    // overriden_br_sel — H8 split so the LD_OP_holder fanout is shared between
    // the lo (bits [3:0]) and hi (bit [4]) halves via two parallel ld-op-holder
    // mux instances.
    wire [`SRC_SEL_W-1:0] overriden_br_sel;
    `MUX_4_H8(overriden_br_sel_mux, `SRC_SEL_W, overriden_br_sel,
            exe_cs_i_branch_target_sel,
            exe_cs_i_branch_target_sel,
            `DR_REGISTER,
            `BUF32,
            {is_CTRL, rr_cs_o_LD_OP_holder},
            {is_CTRL, rr_cs_o_LD_OP_holder_duplicate})

    //shf, ctrl, alu optype selection for each
    wire [`EXE_OP_W-1:0] shf_overriden_op_type, ctrl_overriden_op_type, alu_overriden_op_type, alu_overriden_sub_op_type, alu_overriden_sub_op_type0;
    wire [`EXE_OP_W-1:0] overriden_op_type;
    `MUX_2_H8(shf_overriden_op_type_mux, `EXE_OP_W, shf_overriden_op_type, `SAR, `SAL, rf_eq4, rf_eq4_duplicate)
    `MUX_4_H8(ctrl_overriden_op_type_mux, `EXE_OP_W, ctrl_overriden_op_type,
            `PUSH,
            `CALL,
            `JMP,
            `CALL,
            {rf_eq4, rf_eq2}, {rf_eq4_duplicate, rf_eq2_duplicate})
    `MUX_2_H8(alu_overriden_sub_op_type_mux, `EXE_OP_W, alu_overriden_sub_op_type, `AND, `SBB, rf_eq3, rf_eq3_duplicate)
    `MUX_2_H8(alu_overriden_sub_op_type_mux0, `EXE_OP_W, alu_overriden_sub_op_type0, `AND, `SBB, rf_eq3, rf_eq3_duplicate)

    `MUX_8_H8(alu_overriden_op_type_mux, `EXE_OP_W, alu_overriden_op_type,
                alu_overriden_sub_op_type,
                `ADD,
                `OR,
                alu_overriden_sub_op_type,
                `ADC,
                alu_overriden_sub_op_type0,
                alu_overriden_sub_op_type0,
                alu_overriden_sub_op_type0,
                {rf_eq2, rf_eq1, rf_eq0}, {rf_eq2_duplicate, rf_eq1_duplicate, rf_eq0_duplicate})

    //shf, alu, ctrl, optype selction between each
    `MUX_4_H8(total_overriden_op_type_mux, `EXE_OP_W, overriden_op_type,
            exe_cs_i_OP_TYPE,
            ctrl_overriden_op_type,
            shf_overriden_op_type,
            alu_overriden_op_type,
            op_in_modrm_subset, op_in_modrm_subset_duplicate)




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
    `MUX_2(rr_st_sel_mux,        1,          rr_cs_o_ST_SEL,         rr_cs_i_ST_SEL,            1'b0,    ff_jmp)
    assign rr_cs_o_MODRM_NEEDED    = rr_cs_i_MODRM_NEEDED;
    assign rr_cs_o_RM_IS_DR        = rr_cs_i_RM_IS_DR;
    assign rr_cs_o_SWITCH_LD_ADDY  = rr_cs_i_SWITCH_LD_ADDY;
    assign rr_cs_o_LD_OP           = rr_cs_o_LD_OP_holder_duplicate;
    // sel={invalid_inst, ff_jmp}: 00->rr_cs_i_ST_OP, 01->0, 10->0, 11->0
    `MUX_4(rr_st_op_mux,          1,          rr_cs_o_ST_OP,          rr_cs_i_ST_OP,             1'b0, 1'b0, 1'b0, {invalid_inst, ff_jmp})
    assign rr_cs_o_MOVS_OP         = rr_cs_i_MOVS_OP;
    assign rr_cs_o_dr_id           = rr_cs_i_dr_id;
    `MUX_2(rr_sr_id_mux,          `REG_ID_W,  rr_cs_o_sr_id,          rr_cs_i_sr_id,             `NO_REG, ff_jmp)
    assign rr_cs_o_dr_rd           = rr_cs_i_dr_rd;
    `MUX_2(rr_sr_rd_mux,          1,          rr_cs_o_sr_rd,          rr_cs_i_sr_rd,             1'b0,    ff_jmp)
    `MUX_2(rr_eax_rd_mux,         1,          rr_cs_o_eax_rd,         1'b0,                      1'b1,    cmpxchg)
    // sel={invalid_inst, ff_jmp_call_push}: 00->rr_cs_i_dr_wr, 01->0, 10->0, 11->0
    `MUX_4(rr_dr_wr_mux,          1,          rr_cs_o_dr_wr,          rr_cs_i_dr_wr,             1'b0, 1'b0, 1'b0, {invalid_inst, ff_jmp_call_push})
    // 3-level: invalid_inst>0, xchg>1, ff_jmp>0, else rr_cs_i_sr_wr
    // inner sel={xchg, ff_jmp}: 00->rr_cs_i_sr_wr, 01->0, 10->1, 11->1
    wire rr_sr_wr_inner;
    `MUX_4(rr_sr_wr_inner_mux,    1,          rr_sr_wr_inner,         rr_cs_i_sr_wr,             1'b0, 1'b1, 1'b1, {xchg, ff_jmp})
    `MUX_2(rr_sr_wr_mux,          1,          rr_cs_o_sr_wr,          rr_sr_wr_inner,            1'b0,    invalid_inst)
    // sel={invalid_inst, cmpxchg}: 00->0, 01->1, 10->0, 11->0
    `MUX_4(rr_eax_wr_mux,         1,          rr_cs_o_eax_wr,         1'b0,                      1'b1, 1'b0, 1'b0, {invalid_inst, cmpxchg})
    assign rr_cs_o_datasize        = rr_cs_i_datasize;
    assign rr_cs_o_will_mod_zf     = rr_cs_i_will_mod_zf;
    `MUX_2(rr_seg_1_valid_mux,    1,          rr_cs_o_seg_1_valid,    rr_cs_i_seg_1_valid,       1'b0,    ff_jmp)
    `MUX_2(rr_seg_0_id_mux,       `REG_ID_W,  rr_cs_o_seg_0_id,       rr_cs_i_seg_0_id,          `DS,     ff_push)
    assign rr_cs_o_seg_1_id        = rr_cs_i_seg_1_id;
    assign rr_cs_o_special_modrm_bs = rr_cs_i_special_modrm_bs;
    assign rr_cs_o_special_br      = rr_cs_i_special_br;

    // =====================
    // DC
    // =====================
    `MUX_2(dc_ld_op_mux,          1,          dc_cs_o_LD_OP,          dc_cs_i_LD_OP,             1'b0,    invalid_inst)
    // sel={invalid_inst, ff_jmp}: 00->dc_cs_i_ST_OP, 01->0, 10->0, 11->0
    `MUX_4(dc_st_op_mux,          1,          dc_cs_o_ST_OP,          dc_cs_i_ST_OP,             1'b0, 1'b0, 1'b0, {invalid_inst, ff_jmp})
    assign dc_cs_o_dr_upper8              = dc_cs_i_dr_upper8;
    assign dc_cs_o_sr_upper8              = dc_cs_i_sr_upper8;
    assign dc_cs_o_datasize               = dc_cs_i_datasize;

    // =====================
    // MEM
    // =====================
    `MUX_2(mem_ld_op_mux,         1,          mem_cs_o_LD_OP,         mem_cs_i_LD_OP,            1'b0,    invalid_inst)
    // sel={invalid_inst, ff_jmp}: 00->mem_cs_i_ST_OP, 01->0, 10->0, 11->0
    `MUX_4(mem_st_op_mux,         1,          mem_cs_o_ST_OP,         mem_cs_i_ST_OP,            1'b0, 1'b0, 1'b0, {invalid_inst, ff_jmp})

    // =====================
    // EXE
    // =====================
    // sel={invalid_inst, ff_jmp}: 00->mem_cs_i_ST_OP, 01->0, 10->0, 11->0
    `MUX_4(exe_st_op_mux,         1,          exe_cs_o_ST_OP,         mem_cs_i_ST_OP,            1'b0, 1'b0, 1'b0, {invalid_inst, ff_jmp})
    `MUX_2(exe_op_type_mux,       `EXE_OP_W,  exe_cs_o_OP_TYPE,       exe_cs_i_OP_TYPE,          overriden_op_type,      op_in_modrm)
    // sel={ff_jmp, ff_call}: 00->exe_cs_i_alu_inputA_sel, 01->NEIP, 10->NO_EXE, 11->NO_EXE
    `MUX_4(exe_inputA_sel_mux,    `SRC_SEL_W, exe_cs_o_alu_inputA_sel, exe_cs_i_alu_inputA_sel, `NEIP, `NO_EXE, `NO_EXE, {ff_jmp, ff_call})
    `MUX_2(exe_inputB_sel_mux,    `SRC_SEL_W, exe_cs_o_alu_inputB_sel, exe_cs_i_alu_inputB_sel, `NO_EXE,        ff_jmp)
    `MUX_2(exe_br_target_mux,     `SRC_SEL_W, exe_cs_o_branch_target_sel, exe_cs_i_branch_target_sel, overriden_br_sel, op_in_modrm)
    assign exe_cs_o_shift_by_one       = exe_cs_i_shift_by_one;
    `MUX_2(exe_br_ucond_mux,      1,          exe_cs_o_br_ucond,      exe_cs_i_br_ucond,         1'b0,    ff_push)
    assign exe_cs_o_relative_branch    = exe_cs_i_relative_branch;
    assign exe_cs_o_special_br         = exe_cs_i_special_br;
    assign exe_cs_o_is_far             = exe_cs_i_is_far;
    `MUX_2(exe_is_call_mux,       1,          exe_cs_o_is_call,       exe_cs_i_is_call,          1'b0,    ff_jmp_push)
    assign exe_cs_o_second_flag_needed = exe_cs_i_second_flag_needed;
    assign exe_cs_o_rep_no_zf_update   = 1'b0;

    // =====================
    // WB
    // =====================
    // sel={invalid_inst, ff_jmp}: 00->mem_cs_i_ST_OP, 01->0, 10->0, 11->0
    `MUX_4(wb_st_op_mux,          1,          wb_cs_o_ST_OP,          mem_cs_i_ST_OP,            1'b0, 1'b0, 1'b0, {invalid_inst, ff_jmp})
    // sel={invalid_inst, ff_jmp_call_push}: 00->rr_cs_i_dr_wr, 01->0, 10->0, 11->0
    `MUX_4(wb_wb_dr_mux,          1,          wb_cs_o_WB_DR,          rr_cs_i_dr_wr,             1'b0, 1'b0, 1'b0, {invalid_inst, ff_jmp_call_push})
    // 3-level: invalid_inst>0, xchg>1, ff_jmp>0, else rr_cs_i_sr_wr
    // inner sel={xchg, ff_jmp}: 00->rr_cs_i_sr_wr, 01->0, 10->1, 11->1
    wire wb_sr_inner;
    `MUX_4(wb_sr_inner_mux,       1,          wb_sr_inner,            rr_cs_i_sr_wr,             1'b0, 1'b1, 1'b1, {xchg, ff_jmp})
    `MUX_2(wb_wb_sr_mux,          1,          wb_cs_o_WB_SR,          wb_sr_inner,               1'b0,    invalid_inst)
    // sel={invalid_inst, cmpxchg}: 00->0, 01->1, 10->0, 11->0
    `MUX_4(wb_wb_eax_mux,         1,          wb_cs_o_WB_EAX,         1'b0,                      1'b1, 1'b0, 1'b0, {invalid_inst, cmpxchg})

endmodule
