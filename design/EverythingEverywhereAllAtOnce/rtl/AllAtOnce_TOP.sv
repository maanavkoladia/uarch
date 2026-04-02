import common_pkg::*;
import interconnect_pkg::*;

module AllAtOnce_TOP (
    input wire clk,
    input wire rst
);


    //    icache_2_scheduler_t                                          icache2sched;
    //    dte_2_icache_t                                                dte2icache;
    //
    //    dcache_2_scheduler_t                                          dcache2sched;
    //    dte_2_dcache_t                                                dte2dcache;
    //
    //    mem_2_scheduler_t                                             mem2sched;
    //    mem_2_dte_t                                                   mem2dte;
    //    dte_2_mem_t                                                   dte2mem;
    //
    //    dma_controller_2_scheduler_t                                  dma2sched;
    //    dte_2_dma_controller_t                                        dte2dma;
    //
    //    dte_2_ddr5_t                                                  dte2ddr5;

    icache_2_core_t         icache2core;
    core_2_icache_t         core2icache;

    st_q_2_dcache_t         stq2dcache;
    core_2_dcache_t         core2dcache;
    dcache_2_core_t         dcache2core;

    dma_controller_2_core_t dma2core;

    //wire                         [   DATA_BUS_WIDTH_BITS - 1 : 0] dataBus;
    //wire                         [ADDRESS_BUS_WIDTH_BITS - 1 : 0] addressBus;

    //core
    EveryThing_TOP core_unit (
        .clk(clk),
        .rst(rst),
        .ICacheIn_i(icache2core),
        .out2ICache_o(core2icache),
        .DCacheIn_i(dcache2core),
        .out2DCache_o(core2dcache),
        .inFromDMA_i(dma2core)
    );

    Everywhere_TOP mem_sys_unit (
        .clk(clk),
        .rst(rst),
        .core2icache_i(core2icache),
        .icache2core_o(icache2core),
        .core2dcache_i(core2dcache),
        .dcache2core_o(dcache2core),
        .dma2core_o(dma2core)
    );

    initial begin
        //for init rituals
    end
endmodule
