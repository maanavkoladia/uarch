// Overflow Flag Selection Module
import common_pkg::*;
import contorl_store_pkg::*;


module of_flag_sel(
	input bool adc_of,
	input bool add_of,
	input bool and_of,
	input bool cmp_of,
	input bool cmpxchg_of,
	input bool or_of,
	input bool sal_of,
	input bool sar_of,
	input bool sbb_of,
	// Add more as needed if new functional units affect OF
	input exe_cs_operation_type_e op_type,
	input bool curr_of_flag,
	output bool of_flag_o
);

	// Selection logic placeholder
	// of_flag_o = ...

	always_comb begin
		case(op_type)
			ADC:      of_flag_o = adc_of;
			ADD:      of_flag_o = add_of;
			AND:      of_flag_o = and_of;
			CMP:      of_flag_o = cmp_of;
			CMPXCHG:  of_flag_o = cmpxchg_of;
			OR:       of_flag_o = or_of;
			SAL:      of_flag_o = sal_of;
			SAR:      of_flag_o = sar_of;
			SBB:      of_flag_o = sbb_of;
			default:  of_flag_o = curr_of_flag;
		endcase
	end
endmodule
