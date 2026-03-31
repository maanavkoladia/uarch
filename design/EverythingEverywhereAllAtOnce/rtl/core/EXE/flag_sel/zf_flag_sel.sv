//warning. this was a really dumb way of doing this 

module zf_flag_sel(
    input bool adc_zf,
    input bool add_zf,
    input bool and_zf,
    input bool bsf_zf,
    input bool cmp_zf,
    input bool cmpxchg_zf,
    input bool iretd_zf,
    input bool or_zf,
    input bool sal_zf,
    input bool sar_zf,
    input bool sbb_zf,

    input bool curr_z_flag,
	input exe_cs_operation_type_e op_type,
    output bool zf_flag_o
);


	always_comb begin
		case(op_type)
			ADC:      zf_flag_o = adc_zf;
			ADD:      zf_flag_o = add_zf;
			AND:      zf_flag_o = and_zf;
            BSF:      zf_flag_o = bsf_zf;
			CMP:      zf_flag_o = cmp_zf;
			CMPXCHG:  zf_flag_o = cmpxchg_zf;
			OR:       zf_flag_o = or_zf;
			SAL:      zf_flag_o = sal_zf;
			SAR:      zf_flag_o = sar_zf;
			SBB:      zf_flag_o = sbb_zf;
			default:  zf_flag_o = curr_zf_flag;
		endcase
	end


endmodule