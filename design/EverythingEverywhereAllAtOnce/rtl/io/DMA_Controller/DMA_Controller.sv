module DMA_Controller (

    input wire clk,
    input wire rst,

    input dte_2_dma_controller_t inFromDTE_i,

    output dma_controller_2_core_t out2Core_o,
    output dma_controller_2_scheduler_t out2Sch_o,

    inout [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus,
    inout [ADDRESS_BUS_WIDTH_BITS - 1 : 0] addrBus
);



endmodule
