module Execute (
    input wire clk,
    input wire rst,

    input mem_outputs_t latches_i
    
    //only used for valid logic and stall (no flags)
    input wb_outputs_t wb_outs_i,

    output wb_stage_latches_t wb_latches_next_o;
    output exe_outputs_t outs_o;


);


// select from buffer, imm, src
//if needed align buffer data
//execute unit
//branch resolution unit
//flag update logic
//bit vector gen for WB.STQ
//conditional CS for conditional instructions (i.e CMOVC)
//ALU reorder logic 
//valid logic 
//XCHG unit 



endmodule
