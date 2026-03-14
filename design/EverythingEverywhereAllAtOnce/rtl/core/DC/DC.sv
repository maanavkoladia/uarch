module DC (
    input wire clk,
    input wire rst,

    //stage latches
    input dc_latches_t latches_i,

    //miss stall and valid, inflight store addys
    input mem_outputs_t mem_outs_i,

    //br flush and valid, infligh store addy
    input exe_outputs_t exe_outs_i,

    //in flight store addys and stq addys/entries 
    input wb_outputs_t wb_outs_i,

    output mem_latches_t mem_latches_next_o,

    output dc_outputs_t dc_outs_o

);

endmodule
