// Overflow Flag Selection Module
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
	output bool of_flag_o
);

	// Selection logic placeholder
	// of_flag_o = ...

endmodule
