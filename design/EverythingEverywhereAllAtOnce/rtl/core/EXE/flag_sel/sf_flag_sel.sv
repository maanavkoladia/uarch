// Sign Flag Selection Module
import control_store_pkg::*;
import common_pkg::*;

module sf_flag_sel(
	input bool add_sf,
	input bool adc_sf,
	input bool and_sf,
	input bool cmp_sf,
	input bool cmpxchg_sf,
	input bool or_sf,
	input bool sal_sf,
	input bool sar_sf,
	input bool sbb_sf,
	input bool iretd_sf,

	// Add more as needed if new functional units affect SF
	input exe_cs_operation_type_e op_type,
	input bool curr_sf_flag,
	output bool sf_flag_o

);

	always_comb begin
		case(op_type)
			ADC:      sf_flag_o = adc_sf;
			ADD:      sf_flag_o = add_sf;
			AND:      sf_flag_o = and_sf;
			CMP:      sf_flag_o = cmp_sf;
			CMPXCHG:  sf_flag_o = cmpxchg_sf;
			OR:       sf_flag_o = or_sf;
			SAL:      sf_flag_o = sal_sf;
			SAR:      sf_flag_o = sar_sf;
			SBB:      sf_flag_o = sbb_sf;
			IRETD:	  sf_flag_o = iretd_sf;
			default:  sf_flag_o = curr_sf_flag;
		endcase
	end

	// Selection logic placeholder
	// sf_flag_o = ...

endmodule
