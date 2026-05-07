// Auxiliary Carry Flag Selection Module
import control_store_pkg::*;
import common_pkg::*;

module af_flag_sel(
	input bool and_af,
	input bool or_af,
	input bool aaa_af,
	input bool adc_af,
    input bool add_op_af,
	input bool sal_op_af,
	input bool sar_op_af,

	input bool cmp_af,
	input bool cmpxchg_af,
	input bool sbb_af,
	input bool iretd_af,
	
    input bool curr_af_flag,

	input exe_cs_operation_type_e op_type,

	output bool af_flag_o
);

	// Selection logic placeholder
	// af_flag_o = ...
	//8 to 1 mux
	always_comb begin
		case(op_type)
		    OR:       af_flag_o = or_af;
			AND : 	  af_flag_o = and_af;
			SAL:      af_flag_o = sal_op_af;
			SAR:      af_flag_o = sar_op_af;
			AAA:      af_flag_o = aaa_af;
			ADC:      af_flag_o = adc_af;
			ADD:      af_flag_o = add_op_af;
			CMP:      af_flag_o = cmp_af;
			CMPXCHG:  af_flag_o = cmpxchg_af;
			SBB:      af_flag_o = sbb_af;
			IRETD:	  af_flag_o = iretd_af;
			default:  af_flag_o = curr_af_flag;
		endcase
	end

endmodule
