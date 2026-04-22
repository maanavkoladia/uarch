import common_pkg::*;
import interconnect_pkg::*;

module Everywhere_TOP (
    input wire clk,
    input wire rst,
    input core_2_icache_t core2icache_i,
    output icache_2_core_t icache2core_o,
    input core_2_dcache_t core2dcache_i,
    output dcache_2_core_t dcache2core_o,
    output dma_controller_2_core_t dma2core_o
);

    icache_2_scheduler_t                                          icache_2_sched;
    dte_2_icache_t                                                dte_2_icache;

    dcache_2_scheduler_t                                          dcache_2_sched;
    dte_2_dcache_t                                                dte_2_dcache;

    mem_2_scheduler_t                                             mem_2_sched;
    mem_2_dte_t                                                   mem_2_dte;
    dte_2_mem_t                                                   dte_2_mem;

    dma_controller_2_scheduler_t                                  dma_2_sched;
    dte_2_dma_controller_t                                        dte_2_dma;

    dte_2_ddr5_t                                                  dte_2_ddr5;

    wire                         [   DATA_BUS_WIDTH_BITS - 1 : 0] dataBus;
    wire                         [ADDRESS_BUS_WIDTH_BITS - 1 : 0] addressBus;

    //mem
    mem_TOP mem_unit (
        .clk(clk),
        .rst(rst),
        .address_bus(addressBus),
        .data_bus(dataBus),
        .inFromDte(dte_2_mem),
        .out2Dte(mem_2_dte),
        .out2Sch(mem_2_sched)
    );

    //dcache
    DCache_TOP dcache_unit (
        .clk(clk),
        .rst(rst),
        .inFromCore_i(core2dcache_i),
        .out2Core_o(dcache2core_o),
        .inFromDTE_i(dte_2_dcache),
        .out2Sch_o(dcache_2_sched),
        .address_bus(addressBus),
        .dataBus(dataBus)
    );

    //icache
    ICache icache_unit (
        .clk(clk),
        .rst(rst),
        .inFromCore_i(core2icache_i),
        .out2Core_o(icache2core_o),
        .inFromDte_i(dte_2_icache),
        .out2Sch_o(icache_2_sched),
        .addrBus(addressBus),
        .dataBus(dataBus)
    );

    //busarb
    BusArbitration bus_arbitration_unit (
        .clk(clk),
        .rst(rst),
        .iCache_2_Sch_i(icache_2_sched),
        .dte_out_2_icache_o(dte_2_icache),
        .dCache_2_Sch_i(dcache_2_sched),
        .dte_out_2_dcache_o(dte_2_dcache),
        .mem_2_Sch_i(mem_2_sched),
        .mem_2_dte_i(mem_2_dte),
        .dte_2_mem_o(dte_2_mem),
        .dma_2_sch_i(dma_2_sched),
        .dte_2_dma_o(dte_2_dma),
        .dte_2_ddr5_o(dte_2_ddr5)
    );

    //dma
    DMA_Controller dma_controller_unit (
        .clk(clk),
        .rst(rst),
        .inFromDTE_i(dte_2_dma),
        .out2Core_o(dma2core_o),
        .out2Sch_o(dma_2_sched),
        .dataBus(dataBus),
        .addrBus(addressBus)
    );

    //ddr5
    ddr5 ddr5_unit (
        .clk(clk),
        .rst(rst),
        .inFromDTE_i(dte_2_ddr5),
        .dataBus(dataBus),
        .addrBus(addressBus)

    );

endmodule
