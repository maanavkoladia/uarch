import common_pkg::*;
import control_store_pkg::*;

module sr_sel (
    input exe_cs_operation_type_e op_type,

    // All sr_o inputs from functional units
    input uint64_t sr_data,
    input uint64_t pop_sr_i,
    input uint64_t push_sr_i,
    input uint64_t ret_far_sr_i,
    input uint64_t ret_far_imm_sr_i,
    input uint64_t ret_imm_sr_i,
    input uint64_t ret_sr_i,
    input uint64_t xchg_sr_i,
    input uint64_t call_sr_i,
    input uint64_t far_call_sr_i,
    input uint64_t mov_s_sr_i,
    input uint64_t add_df_sr_i,
    input uint64_t exp_call_sr_i,
    // Selected output
    output uint64_t sr_o
);

    always_comb begin
        case (op_type)
            ADD_DF:      sr_o = add_df_sr_i;
            POP:         sr_o = pop_sr_i;
            PUSH:        sr_o = push_sr_i;
            RET_FAR:     sr_o = ret_far_sr_i;
            RET_FAR_IMM: sr_o = ret_far_imm_sr_i;
            RET_IMM:     sr_o = ret_imm_sr_i;
            RET:         sr_o = ret_sr_i;
            XCHG:        sr_o = xchg_sr_i;
            CALL:        sr_o = call_sr_i;
            FAR_CALL:    sr_o = far_call_sr_i;
            MOVS:        sr_o = mov_s_sr_i;
            EXP_CALL:    sr_o = exp_call_sr_i;
            default:     sr_o = sr_data;
        endcase
    end

endmodule
