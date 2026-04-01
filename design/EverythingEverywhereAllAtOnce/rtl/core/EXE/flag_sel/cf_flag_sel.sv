// Carry Flag Selection Module
import common_pkg::*;
import contorl_store_pkg::*;

module cf_flag_sel(
	input bool aaa_cf,
	input bool adc_cf,
	input bool add_cf,
	input bool cmp_cf,
	input bool cmpxchg_cf,
	input bool or_cf,
	input bool sal_cf,
	input bool sar_cf,
	input bool sbb_cf,
	input bool iretd_cf,

	// Add more as needed if new functional units affect CF
	input curr_cf_flag,
	input exe_cs_operation_type_e op_type;

	output bool cf_flag_o
);

	always_comb begin
		case(op_type)
			AAA:      cf_flag_o = aaa_cf;
			ADC:      cf_flag_o = adc_cf;
			ADD:      cf_flag_o = add_cf;
			CMP:      cf_flag_o = cmp_cf;
			CMPXCHG:  cf_flag_o = cmpxchg_cf;
			OR:       cf_flag_o = or_cf;
			SAL:      cf_flag_o = sal_cf;
			SAR:      cf_flag_o = sar_cf;
			SBB:      cf_flag_o = sbb_cf;
			IRETD:	  cf_flag_o = iretd_cf;
			default:  cf_flag_o = curr_cf_flag;
		endcase
	end
	
endmodule
