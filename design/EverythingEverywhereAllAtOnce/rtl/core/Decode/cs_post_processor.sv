import control_store_pkg::*;

module cs_post_processor (
    input bool movs,
    input bool op_in_modrm,
    input op_in_modrm_subset_t op_in_modrm_subset,
    input byte modrm_byte,
    input decode_cs_t decode_cs_i,
    input rr_cs_t rr_cs_i,
    input dc_cs_t dc_cs_i,
    input mem_cs_t mem_cs_i,
    input exe_cs_t exe_cs_i,
    input wb_cs_t wb_cs_i,

    output decode_cs_t decode_cs_o,
    output rr_cs_t rr_cs_o,
    output dc_cs_t dc_cs_o,
    output mem_cs_t mem_cs_o,
    output exe_cs_t exe_cs_o,
    output wb_cs_t wb_cs_o
);

    exe_cs_operation_type_e overriden_op_type;
    logic [2:0] reg_field;
    assign reg_field = modrm_byte[5:3];

    //op_type setting
    always_comb begin
    overriden_op_type = exe_cs_i.OP_TYPE;
        case(op_in_modrm_subset)
            SHF: begin
                if(reg_field == 3'd4) overriden_op_type = SAL;
                else if (reg_field == 3'd7) overriden_op_type = SAR;
            end
            CTRL: begin
                if(reg_field == 3'd2) overriden_op_type = CALL;
                else if(reg_field == 3'd6) overriden_op_type = PUSH;
            end
            ALU: begin
                if(reg_field == 3'd0) overriden_op_type = ADD;
                else if(reg_field == 3'd1) overriden_op_type = OR;
                else if(reg_field == 3'd2) overriden_op_type = ADC;
                else if(reg_field == 3'd3) overriden_op_type = SBB;
                else if(reg_field == 3'd4) overriden_op_type = AND;
            end
        endcase
    end

    // =====================
    // DECODE
    // =====================
    assign decode_cs_o = decode_cs_i;
    // assign decode_cs_o = '{
    //     REP                     : decode_cs_i.REP,
    //     REP_CMP                 : decode_cs_i.REP_CMP,
    //     HALT                    : decode_cs_i.HALT,
    //     MODRM_NEEDED            : decode_cs_i.MODRM_NEEDED,
    //     RM_IS_DR                : decode_cs_i.RM_IS_DR,
    //     REG_IS_DR               : decode_cs_i.REG_IS_DR,
    //     REG_IS_SEGMENT          : decode_cs_i.REG_IS_SEGMENT,
    //     HARDCODED_DR            : decode_cs_i.HARDCODED_DR,
    //     HARDCODED_DR_ID         : decode_cs_i.HARDCODED_DR_ID,
    //     HARDCODED_SR            : decode_cs_i.HARDCODED_SR,
    //     HARDCODED_SR_ID         : decode_cs_i.HARDCODED_SR_ID,
    //     HARDCODED_DR_RD         : decode_cs_i.HARDCODED_DR_RD,
    //     HARDCODED_SR_RD         : decode_cs_i.HARDCODED_SR_RD,
    //     HARDCODED_DR_WR         : decode_cs_i.HARDCODED_DR_WR,
    //     HARDCODED_SR_WR         : decode_cs_i.HARDCODED_SR_WR,
    //     HARDCODED_LD_OP         : decode_cs_i.HARDCODED_LD_OP,
    //     HARDCODED_ST_OP         : decode_cs_i.HARDCODED_ST_OP,
    //     LD_OP_CANCEL            : decode_cs_i.
    //     OP_IN_MODRM             : decode_cs_i.OP_IN_MODRM,
    //     dr_id                   : decode_cs_i.dr_id,
    //     sr_id                   : decode_cs_i.sr_id,
    //     DATA_SIZE               : decode_cs_i.DATA_SIZE
    // };

    // =====================
    // RR
    // =====================
    assign rr_cs_o = '{
        //HARDCODED_DR_RD : rr_cs_i.HARDCODED_DR_RD,
        //HARDCODED_SR_RD : rr_cs_i.HARDCODED_SR_RD,
        ST_SEL          : rr_cs_i.ST_SEL,
        MODRM_NEEDED    : rr_cs_i.MODRM_NEEDED,
        RM_IS_DR        : rr_cs_i.RM_IS_DR,
        LD_OP           : movs ? 1'b1 : rr_cs_i.LD_OP,
        ST_OP           : movs ? 1'b1 : rr_cs_i.ST_OP,
        dr_id           : rr_cs_i.dr_id,
        sr_id           : rr_cs_i.sr_id,
        dr_rd           : rr_cs_i.dr_rd,
        sr_rd           : rr_cs_i.sr_rd,
        dr_wr           : movs ? 1'b0 : rr_cs_i.dr_wr,
        sr_wr           : rr_cs_i.sr_wr,
        datasize        : rr_cs_i.datasize,
        will_mod_zf     : rr_cs_i.will_mod_zf,
        seg_1_valid     : rr_cs_i.seg_1_valid,
        seg_0_id        : rr_cs_i.seg_0_id,
        seg_1_id        : rr_cs_i.seg_1_id
    };

    // =====================
    // DC
    // =====================
    assign dc_cs_o = '{
        LD_OP    : dc_cs_i.LD_OP,
        ST_OP    : dc_cs_i.ST_OP,
        dr_upper8   : dc_cs_i.dr_upper8,
        sr_upper8 : dc_cs_i.sr_upper8,
        datasize : dc_cs_i.datasize
    };

    // =====================
    // MEM
    // =====================
    assign mem_cs_o = '{
        ST_OP : mem_cs_i.ST_OP,
        LD_OP : mem_cs_i.LD_OP
    };

    // =====================
    // EXE
    // =====================
    assign exe_cs_o = '{
        ST_OP              : exe_cs_i.ST_OP,
        OP_TYPE            : (op_in_modrm) ? overriden_op_type : exe_cs_i.OP_TYPE,
        alu_inputA_sel     : exe_cs_i.alu_inputA_sel,
        alu_inputB_sel     : exe_cs_i.alu_inputB_sel,
        branch_target_sel  : exe_cs_i.branch_target_sel,
        shift_by_one       : exe_cs_i.shift_by_one,
        br_ucond           : exe_cs_i.br_ucond,
        relative_branch    : exe_cs_i.relative_branch,
        special_br         : exe_cs_i.special_br,
        is_far             : exe_cs_i.is_far,
        second_flag_needed : exe_cs_i.second_flag_needed
    };

    // =====================
    // WB
    // =====================
    assign wb_cs_o = '{
        ST_OP : wb_cs_i.ST_OP,
        WB_DR : wb_cs_i.WB_DR,
        WB_SR : wb_cs_i.WB_SR
    };
    
endmodule