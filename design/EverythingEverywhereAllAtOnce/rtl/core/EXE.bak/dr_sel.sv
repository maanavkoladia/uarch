import common_pkg::*;
import control_store_pkg::*;

module dr_sel (
    input exe_cs_operation_type_e op_type,
    
    // All dr_o inputs from functional units
    input uint64_t aaa_dr_i,
    input uint64_t adc_dr_i,
    input uint64_t add_dr_i,
    input uint64_t add_df_dr_i,
    input uint64_t and_dr_i,
    input uint64_t bsf_dr_i,
    input uint64_t cmpxchg_dr_i,
    input uint64_t mov_dr_i,
    input uint64_t mov_s_dr_i,
    input uint64_t not_dr_i,
    input uint64_t or_dr_i,
    input uint64_t packssdw_dr_i,
    input uint64_t packsswb_dr_i,
    input uint64_t paddd_dr_i,
    input uint64_t paddw_dr_i,
    input uint64_t pavgb_dr_i,
    input uint64_t pavgw_dr_i,
    input uint64_t pop_dr_i,
    input uint64_t ret_far_dr_i,
    input uint64_t ret_far_imm_dr_i,
    input uint64_t far_call_dr_i,
    input uint64_t far_jmp_dr_i,
    input uint64_t sal_dr_i,
    input uint64_t sar_dr_i,
    input uint64_t sbb_dr_i,
    input uint64_t xchg_dr_i,
    input uint64_t exp_call_dr_i,
    input uint64_t iretd_cs_dr_i,
    input uint64_t dr_data,
    
    // Selected output
    output uint64_t dr_o
);

    always_comb begin
        case (op_type)
            AAA:      dr_o = aaa_dr_i;
            ADC:      dr_o = adc_dr_i;
            ADD:      dr_o = add_dr_i;
            ADD_DF:   dr_o = add_df_dr_i;
            AND:      dr_o = and_dr_i;
            BSF:      dr_o = bsf_dr_i;
            CMPXCHG:  dr_o = cmpxchg_dr_i;
            MOV:      dr_o = mov_dr_i;
            MOVS:     dr_o = mov_s_dr_i;
            CMOVC:    dr_o = mov_dr_i; //part of mov unit
            NOT:      dr_o = not_dr_i;
            OR:       dr_o = or_dr_i;
            PACKSSDW: dr_o = packssdw_dr_i;
            PACKSSWB: dr_o = packsswb_dr_i;
            PADDD:    dr_o = paddd_dr_i;
            PADDW:    dr_o = paddw_dr_i;
            PAVGB:    dr_o = pavgb_dr_i;
            PAVGW:    dr_o = pavgw_dr_i;
            POP:      dr_o = pop_dr_i;
            RET_FAR:  dr_o = ret_far_dr_i;
            RET_FAR_IMM: dr_o = ret_far_imm_dr_i;
            FAR_CALL: dr_o = far_call_dr_i;
            FAR_JMP32:  dr_o = far_jmp_dr_i;
            FAR_JMP16:  dr_o = far_jmp_dr_i;
            SAL:      dr_o = sal_dr_i;
            SAR:      dr_o = sar_dr_i;
            SBB:      dr_o = sbb_dr_i;
            XCHG:     dr_o = xchg_dr_i;
            IRETD:    dr_o = iretd_cs_dr_i;
            EXP_CALL: dr_o = exp_call_dr_i;
            default:  dr_o = dr_data;
        endcase
    end

endmodule

