module pf_flag_sel(
	input bool adc_pf,
	input bool add_pf,
	input bool and_pf,
	input bool cmp_pf,
	input bool cmpxchg_pf,
	input bool or_pf,
	input bool sal_pf,
	input bool sar_pf,
	input bool sbb_pf,

	input exe_cs_operation_type_e op_type,
	input bool curr_pf_flag,
	output bool pf_flag_o

);

always_comb begin
	case(op_type)
        ADC:      pf_flag_o = adc_pf;
        ADD:      pf_flag_o = add_pf;
        AND:      pf_flag_o = and_pf;
        CMP:      pf_flag_o = cmp_pf;
        CMPXCHG:  pf_flag_o = cmpxchg_pf;
        OR:       pf_flag_o = or_pf;
        SAL:      pf_flag_o = sal_pf;
        SAR:      pf_flag_o = sar_pf;
        SBB:      pf_flag_o = sbb_pf;
        default:  pf_flag_o = curr_pf_flag;
    endcase
end


endmodule