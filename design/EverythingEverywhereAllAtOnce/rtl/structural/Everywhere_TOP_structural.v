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

    wire                         [   DATA_BUS_WIDTH_BITS - 1 : 0] dataBus;
    wire                         [ADDRESS_BUS_WIDTH_BITS - 1 : 0] addressBus;

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

    // mem_TOP mem_unit (
    //     .clk(clk),
    //     .rst(rst),
    //     .address_bus(addressBus),
    //     .data_bus(dataBus),
    //     .inFromDte_ld_req(dte2mem.ld_req),
    //     .inFromDte_st_req(dte2mem.st_req),
    //     .inFromDte_permission2DriveBus(dte2mem.permission2DriveBus),
    //     .out2Dte_mem_Ready(mem2dte.mem_Ready),
    //     .out2Sch_writeBuf_V(mem2sched.writeBuf_V)
    // );

    //dcache
    DCache_TOP dcache_unit (
        .clk(clk),
        .rst(rst),
        .inFromCore_i(core2dcache_i),
        .out2Core_o(dcache2core_o),
        .inFromDTE_i(dte2dcache),
        .out2Sch_o(dcache2sched),
        .address_bus(addressBus),
        .dataBus(dataBus)
    );

    //icache
    // ICache icache_unit (
    //     .clk(clk),
    //     .rst(rst),
    //     .inFromCore_i(core2icache_i),
    //     .out2Core_o(icache2core_o),
    //     .inFromDte_i(dte2icache),
    //     .out2Sch_o(icache2sched),
    //     .addrBus(addressBus),
    //     .dataBus(dataBus)
    // );

    uintCL_t icache_instruction_line_flat;

    always_comb begin
        for(int i = 0; i < CACHE_LINES_SIZE_B; i++)begin
            icache2core_o.instruction_line[i] = icache_instruction_line_flat[i*8 +: 8];
        end
    end

    ICache icache_unit (
        .clk(clk),
        .rst(rst),
        .icache_en(core2icache_i.icache_en),
        .p_addr(core2icache_i.p_addr),
        .v_addr_i(core2icache_i.v_addr_i),
        .num_valid_IDM_slots(core2icache_i.num_valid_IDM_slots),
        .out_hit(icache2core_o.hit),
        .out_instruction_line(icache_instruction_line_flat),
        .Mem_Valid(dte2icache.Mem_Valid),
        .driveAddrBus(dte2icache.driveAddrBus),
        .out_req(icache2sched.req),
        .dataBus(dataBus),
        .addrBus(addressBus)
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
        .dte_2_ddr5_o(dte2ddr5)
    );

    //dma
    DMA_Controller dma_controller_unit (
        .clk(clk),
        .rst(rst),
        .inFromDTE_i(dte2dma),
        .out2Core_o(dma2core_o),
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

endmodule
