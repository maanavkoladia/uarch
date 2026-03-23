module Scheduler(
    input wire clk_i,
    input wire rst_i,//active low

    input icache_2_scheduler_t iCache_2_Sch_i,
    output dte_2_icache_t dte_out_2_icache_o,
    input dcache_2_scheduler_t dCache_2_Sch_i,
    input mem_2_scheduler_t mem_2_Sch_i,
    input dma_controller_2_scheduler_t dma_2_sch_i,


);

endmodule
