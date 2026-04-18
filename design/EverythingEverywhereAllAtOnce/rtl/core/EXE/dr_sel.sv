import common_pkg::*;
import control_store_pkg::*;

module dr_sel (
    input exe_cs_operation_type_e op_type,
    
    // All dr_o inputs from functional units
    input uint64_t aaa_dr_i,
    input uint64_t adc_dr_i,
    input uint64_t add_dr_i,
    input uint64_t and_dr_i,
    input uint64_t bsf_dr_i,
    input uint64_t call_dr_i,
    input uint64_t cmpxchg_dr_i,
    input uint64_t far_call_dr_i,
    input uint64_t mov_dr_i,
    input uint64_t not_dr_i,
    input uint64_t or_dr_i,
    input uint64_t packssdw_dr_i,
    input uint64_t packsswb_dr_i,
    input uint64_t paddd_dr_i,
    input uint64_t paddw_dr_i,
    input uint64_t pavgb_dr_i,
    input uint64_t pavgw_dr_i,
    input uint64_t pop_dr_i,
    input uint64_t ret_far_imm_dr_i,
    input uint64_t sal_dr_i,
    input uint64_t sar_dr_i,
    input uint64_t sbb_dr_i,
    input uint64_t xchg_dr_i,
    input uint64_t dr_data,
    
    // Selected output
    output uint64_t dr_o
);

    always_comb begin
        case (op_type)
            AAA:      dr_o = aaa_dr_i;
            ADC:      dr_o = adc_dr_i;
            ADD:      dr_o = add_dr_i;
            AND:      dr_o = and_dr_i;
            BSF:      dr_o = bsf_dr_i;
            CALL:     dr_o = call_dr_i;
            CMPXCHG:  dr_o = cmpxchg_dr_i;
            FAR_CALL: dr_o = far_call_dr_i;
            MOV:      dr_o = mov_dr_i;
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
            RET_FAR_IMM: dr_o = ret_far_imm_dr_i;
            SAL:      dr_o = sal_dr_i;
            SAR:      dr_o = sar_dr_i;
            SBB:      dr_o = sbb_dr_i;
            XCHG:     dr_o = xchg_dr_i;
            default:  dr_o = dr_data;
        endcase
    end

endmodule


/* notes for porting

// Use the parallel decode + OR approach
// Synthesis will optimize the OR tree automatically
always_comb begin
    logic [22:0] sel;
    sel[0]  = (op_type == AAA_OP);
    sel[1]  = (op_type == ADC_OP);
    // ... all 23
    
    dr_o = ({64{sel[0]}} & aaa_dr_i) |
           ({64{sel[1]}} & adc_dr_i) |
           ({64{sel[2]}} & add_dr_i) |
           // ... all 23
           64'h0;  // default
end

Fastest Approach: Parallel Decode + Wide OR
Timing: ~7-8 gate delays total

Comparator: ~2 gates
AND gate: ~1 gate
OR tree (5 levels): ~5 gates
Even Faster: Tristate Buffers (ASIC only)
Timing: ~3-4 gate delays total

Decoder: ~2 gates
Tristate buffer: ~2 gates
No OR tree!
Comparison
Approach	Delay	Area	Power	Notes
Tristate	3-4 gates ✓	Medium	Low	ASIC only, not FPGA
Parallel + OR	7-8 gates	Large	High	All comparators active
Binary Mux Tree	10 gates	Small	Medium	What I showed earlier


                                   RESULT
                                       |
                        ┌──────────────┴──────────────┐
                     op[2]=0                       op[2]=1
                        |                              |
                  level2_mux0                    level2_mux1
                        |                              |
            ┌───────────┴──────────┐       ┌───────────┴──────────┐
         op[1]=0              op[1]=1   op[1]=0              op[1]=1
            |                    |         |                    |
      level1_mux0          level1_mux1  level1_mux2        level1_mux3
            |                    |         |                    |
      ┌─────┴─────┐        ┌─────┴─────┐ ┌─────┴─────┐      ┌─────┴─────┐
   op[0]=0    op[0]=1   op[0]=0   op[0]=1 op[0]=0  op[0]=1 op[0]=0   op[0]=1
      |          |         |         |       |        |       |          |
    ADD        SUB       AND        OR      XOR      SHL     0x0        0x0
   (000)      (001)     (010)     (011)   (100)    (101)   (110)      (111)

For dr_sel with 23 operations, you'd need:

5 bits to encode (2^5 = 32 possible values, 23 used)
5 levels of muxes
Round up to 32 inputs (pad with zeros for unused slots 24-32)
Level 1: 16 muxes (pair up 32 inputs using bit[0])
Level 2: 8 muxes (using bit[1])
Level 3: 4 muxes (using bit[2])
Level 4: 2 muxes (using bit[3])
Level 5: 1 mux (using bit[4]) → final output

Total: 31 two-input muxes, each 64 bits wide.

*/