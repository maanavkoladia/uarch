module EXE (
    input wire clk,
    input wire rst,

    input exe_latches_t latches_i,

    //only used for valid logic and stall (no flags)
    input wb_outputs_t wb_outs_i,

    output wb_latches_t  wb_latches_next_o,
    output exe_outputs_t outs_o

);

    

    //making the assumption that a write to the buffer will either line up with the r/m value. so ST offset of the SS offset. 
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
