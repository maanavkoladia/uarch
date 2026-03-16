import common_pkg::*;
import interconnect_pkg::*;
import core_common_pkg::*;
import core_stage_latches_pkg::*;

module EXP_Set_logic(
    input  invalid_instruction,
    input rr_valid,
    input dc_valid,
    input mem_valid,
    input exe_valid,
    input wb_valid,
    input f_exp,
    input rr_exp,
    input int_set,

    output exp_set_logic_output_t outputs
);

/*
notes on logic 
There are two places where exceptions can be generated
- fetch
- register read 

The problem:
When an exeception is generated we need to take it only once it is certain it is not specualative.
Basically, we take the exception once all instructions downstream are finished

this logic block checks for that 

if there is an exception in fetch, we wait till all stages upstream are cleared (and_exp)
if there is an exceptio in RR we wait till mem, excecute and wb are cleared (and_rr)

if an RR exception and a fetch exception both happen at the same time the RR exception gets priority (mux)

an interrupt register lives in fetch. The same rules apply for interrupt - we wait for the downstream to clear

The registers that actually signal we are servicing the interrupt are in the fetch stage itself
*/

wire f_pipe_clear;
wire rr_pipe_clear;
wire int_pipe_clear;

wire not_rr_valid;
wire not_dc_valid;
wire not_mem_valid;
wire not_exe_valid;
wire not_wb_valid;


inv1$ not0 (.out(not_rr_valid), .in(rr_valid));
inv1$ not0 (.out(not_dc_valid), .in(dc_valid));
inv1$ not0 (.out(not_mem_valid), .in(mem_valid));
inv1$ not0 (.out(not_exe_valid), .in(exe_valid));
inv1$ not0 (.out(not_wb_valid), .in(wb_valid));

and7$ and_exp (.out(f_pipe_clear), .in0(invalid_instruction),
                .in1(not_rr_valid), .in2(not_dc_valid), .in3(not_mem_valid), 
                .in4(not_exe_valid), .in5(not_wb_valid), .in6(f_exp));


and4$ and_rr (.out(rr_pipe_clear), .in0(invalid_instruction),
                .in1(not_rr_valid), .in2(not_dc_valid), .in3(not_mem_valid));

mux2$ mux_exp_sel (.outb(exp_set_logic_output_t.exp_pipe_clear),
                    .in0(f_pipe_clear),
                    .in1(rr_pipe_clear),
                    .s0(rr_exp)
                );


and7$ and_int (.out(exp_set_logic_output_t.int_pipe_clear), .in0(invalid_instruction),
                .in1(not_rr_valid), .in2(not_dc_valid), .in3(not_mem_valid),
                .in4(not_exe_valid), .in5(not_wb_valid), .in6(int_set));


endmodule
