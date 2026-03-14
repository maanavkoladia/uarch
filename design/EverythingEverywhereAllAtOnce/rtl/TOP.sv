import common_pkg::*;

module TOP (
    input wire clk,
    input wire rst
);


    icache_2_scheduler_t                                          icache2sched;
    dte_2_icache_t                                                dte2icache;

    dcache_2_scheduler_t                                          dcache2sched;
    dte_2_dcache_t                                                dte2dcache;

    mem_2_scheduler_t                                             mem2sched;
    mem_2_dte_t                                                   mem2dte;
    dte_2_mem_t                                                   dte2mem;

    dma_controller_2_scheduler_t                                  dma2sched;
    dte_2_dma_controller_t                                        dte2dma;

    dte_2_ddr5_t                                                  dte2ddr5;

    icache_2_core_t                                               icache2core;
    core_2_icache_t                                               core2icache;

    st_q_2_dcache_t                                               stq2dcache;
    core_2_dcache_t                                               core2dcache;
    dcache_2_core_t                                               dcache2core;

    dma_controller_2_core_t                                       dma2core;
    
    wire                        [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus;
    wire                        [ADDRESS_BUS_WIDTH_BITS - 1 : 0] addressBus;
    
    //core
    CoreTop core_unit (
        .clk(clk),
        .rst(rst),
        .ICacheIn_i(icache2core),
        .out2ICache_o(core2icache),
        .DCacheIn_i(dcache2core),
        .out2DCache_o(core2dcache),
        .inFromDMA_i(dma2core)
    );

    //mem
    mem_TOP mem_unit (
        .clk(clk),
        .rst(rst),
        .address_bus(addressBus),
        .data_bus(dataBus),
        .inFromDte(dte2mem),
        .out2Dte(mem2dte),
        .out2Sch(mem2sched)
    );

    //dcache
    DCache dcache_unit (
        .clk(clk),
        .rst(rst),
        .inFromCore_i(core2dcache),
        .out2Core_o(dcache2core),
        .inFromDTE_i(dte2dcache),
        .out2Sch_o(dcache2sched),
        .address_bus(addressBus),
        .dataBus(dataBus)
    );

    //icache
    ICache icache_unit (
        .clk(clk),
        .rst(rst),
        .inFromCore_i(core2icache),
        .out2Core_o(icache2core),
        .dte_out_i(dte2icache),
        .out2Sch_o(icache2sched),
        .addrBus(addressBus),
        .dataBus(dataBus)
    );

    //busarb
    BusArbitration bus_arbitration_unit (
        .clk(clk),
        .rst(rst),
        .iCache_2_Sch_i(icache2sched),
        .dte_out_2_icache_o(dte2icache),
        .dCache_2_Sch_i(dcache2sched),
        .dte_out_2_dcache_o(dte2dcache),
        .mem_2_Sch_i(mem2sched),
        .mem_2_dte_i(mem2dte),
        .dte_2_mem_o(dte2mem),
        .dma_2_sch_i(dma2sched),
        .dte_2_dma_o(dte2dma),
        .dte_2_ddr5_i(dte2ddr5)
    );

    //dma
    DMA_Controller dma_controller_unit (
        .clk(clk),
        .rst(rst),
        .inFromDTE_i(dte2dma),
        .out2Core_o(dma2core),
        .out2Sch_o(dma2sched),
        .dataBus(dataBus),
        .addrBus(addressBus)
    );

    //ddr5
    ddr5 ddr5_unit (
        .clk(clk),
        .rst(rst),
        .inFromDTE_i(dte2ddr5),
        .dataBus(dataBus),
        .addrBus(addressBus)

    );

    initial begin
        //for init rituals
    end
endmodule
