module DTE (
    input wire clk_i,
    input wire rst_i,  //active low

    output dte_2_icache_t dte_out_2_icache_o,
    output dte_2_dcache_t dte_out_2_dcache_o,
    input mem_2_dte_t mem_2_dte_i,
    output dte_2_mem_t dte_2_mem_o,
    output dte_2_dma_controller_t dte_2_dma_o,
    input dte_2_ddr5_t dte_2_ddr5_i
);

    //needs to run the fsm, there really shouldnt be anyhting else here



endmodule
