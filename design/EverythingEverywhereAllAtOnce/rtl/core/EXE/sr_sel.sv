import common_pkg::*;
import control_store_pkg::*;

module sr_sel (
    input exe_cs_operation_type_e op_type,
    
    // All sr_o inputs from functional units
    input uint64_t cmpxchg_sr_i,
    input uint64_t pop_sr_i,
    input uint64_t push_sr_i,
    input uint64_t ret_far_imm_sr_i,
    input uint64_t ret_imm_sr_i,
    input uint64_t ret_sr_i,
    input uint64_t xchg_sr_i,
    
    // Selected output
    output uint64_t sr_o
);

    always_comb begin
        case (op_type)
            CMPXCHG_OP:     sr_o = cmpxchg_sr_i;
            POP_OP:         sr_o = pop_sr_i;
            PUSH_OP:        sr_o = push_sr_i;
            RET_FAR_IMM_OP: sr_o = ret_far_imm_sr_i;
            RET_IMM_OP:     sr_o = ret_imm_sr_i;
            RET_OP:         sr_o = ret_sr_i;
            XCHG_OP:        sr_o = xchg_sr_i;
            default:        sr_o = 64'h0;
        endcase
    end

endmodule