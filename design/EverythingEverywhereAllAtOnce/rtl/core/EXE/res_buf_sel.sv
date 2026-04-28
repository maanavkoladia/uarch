import common_pkg::*;
import control_store_pkg::*;

module res_buf_sel (
    input exe_cs_operation_type_e op_type,
    
    // All res_buf inputs from functional units
    input uint64_t adc_res_buf_i,
    input uint64_t add_res_buf_i,
    input uint64_t and_res_buf_i,
    input uint64_t call_res_buf_i,
    input uint64_t cmpxchg_buf_i,
    input uint64_t far_call_res_buf_i,
    input uint64_t mov_res_buf_i,
    input uint64_t mov_s_res_buf_i,
    input uint64_t not_res_buf_i,
    input uint64_t or_res_buf_i,
    input uint64_t push_res_buf_i,
    input uint64_t pop_res_buf_i,
    input uint64_t sal_res_buf_i,
    input uint64_t sar_res_buf_i,
    input uint64_t sbb_res_buf_i,
    input uint64_t xchg_res_buf_i,
    input uint64_t exp_call_res_buf_i,
    
    // Selected output
    output uint64_t res_buf_o
);

    always_comb begin
        case (op_type)
            ADC:      res_buf_o = adc_res_buf_i;
            ADD:      res_buf_o = add_res_buf_i;
            AND:      res_buf_o = and_res_buf_i;
            CALL:     res_buf_o = call_res_buf_i;
            CMPXCHG:  res_buf_o = cmpxchg_buf_i;
            FAR_CALL: res_buf_o = far_call_res_buf_i;
            MOV:      res_buf_o = mov_res_buf_i;
            MOVS:     res_buf_o = mov_s_res_buf_i;
            NOT:      res_buf_o = not_res_buf_i;
            OR:       res_buf_o = or_res_buf_i;
            PUSH:     res_buf_o = push_res_buf_i;
            POP:      res_buf_o = pop_res_buf_i;
            SAR:      res_buf_o = sar_res_buf_i;
            SAL:      res_buf_o = sal_res_buf_i;
            SBB:      res_buf_o = sbb_res_buf_i;
            XCHG:     res_buf_o = xchg_res_buf_i;
            EXP_CALL: res_buf_o = exp_call_res_buf_i;
            default:  res_buf_o = 64'h0;
        endcase
    end

endmodule