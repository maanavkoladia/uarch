module BusArbitration (
    input wire clk,
    input wire rst,

    //icache
    input icache_2_scheduler_t iCache_2_Sch_i,
    output dte_2_icache_t dte_out_2_icache_o,

    //dcache
    input dcache_2_scheduler_t dCache_2_Sch_i,
    output dte_2_dcache_t dte_out_2_dcache_o,
    //mem

    input mem_2_scheduler_t mem_2_Sch_i,
    input mem_2_dte_t mem_2_dte_i,
    output dte_2_mem_t dte_2_mem_o,

    //dma
    input dma_controller_2_scheduler_t dma_2_sch_i,
    output dte_2_dma_controller_t dte_2_dma_o,

    //ddr5
    input dte_2_ddr5_t dte_2_ddr5_i
);


endmodule

