create_clock -name clk -period 10.0 [get_ports clk]

set_input_delay 0.1 -clock clk [all_inputs]
set_output_delay 0.1 -clock clk [all_outputs]
