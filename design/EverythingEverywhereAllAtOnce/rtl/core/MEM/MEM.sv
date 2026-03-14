module MEM (
    input wire clk,
    input wire rst,

    input mem_stage_latches_t latches_i,

    //not sure if valid are needed, leaving for now
    //if not XCL, then wait for line_0 to hit, if XCL, wait for both line_0
    //and line_1
    input bool valid_0,
    input bool hit_line_0,  //this onyl goes high if valid
    input byte_t line_0[CACHE_LINES_SIZE_B],
    input bool valid_1,
    input bool hit_line_1,
    input byte_t line_1[CACHE_LINES_SIZE_B],


    output execute_stage_latches_t exe_latches_next_o,
    output mem_outputs_t outs_o
);

endmodule
