import common_pkg::*;
import interconnect_pkg::*;

module tb_dma ();

    localparam int CLK_PERIOD = 8;

    task automatic DelayCLKs(input int cycles);
        #(CLK_PERIOD * cycles);
    endtask

    `CLK_INIT(CLK_PERIOD)

    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    logic rst;
    wire [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus;
    wire [ADDRESS_BUS_WIDTH_BITS - 1 : 0] addrBus;

    //to give the memmodule and addr
    mem_2_dte_t mem_2_dte;
    dte_2_mem_t dte_2_mem;
    mem_2_scheduler_t mem_2_sch;

    icache_2_scheduler_t icache_2_sch;
    dma_controller_2_scheduler_t dma_2_sch;

    core_2_dcache_t core_2_dcache;
    dcache_2_core_t dcache_2_core;
    dcache_2_scheduler_t dcache_2_sch;
    dte_2_dcache_t dte_2_dcache;

    dte_2_dma_controller_t dte_2_dma;
    dma_controller_2_core_t dma_2_core;
    dte_2_ddr5_t dte_2_ddr5;

    DCache_TOP u_dcache (
        .clk(clk),
        .rst(rst),
        .inFromCore_i(core_2_dcache),
        .out2Core_o(dcache_2_core),
        .inFromDTE_i(dte_2_dcache),
        .out2Sch_o(dcache_2_sch),
        .dataBus(dataBus),
        .address_bus(addrBus)
    );

    BusArbitration u_BusArb (
        .clk(clk),
        .rst(rst),
        .iCache_2_Sch_i(icache_2_sch),
        .dte_out_2_icache_o(),
        .dCache_2_Sch_i(dcache_2_sch),
        .dte_out_2_dcache_o(dte_2_dcache),
        .mem_2_Sch_i(mem_2_sch),
        .mem_2_dte_i(mem_2_dte),
        .dte_2_mem_o(dte_2_mem),
        .dma_2_sch_i(dma_2_sch),
        .dte_2_dma_o(dte_2_dma),
        .dte_2_ddr5_o(dte_2_ddr5)
    );

    mem_TOP u_mainMem (
        .clk(clk),
        .rst(rst),
        .address_bus(addrBus),
        .data_bus(dataBus),
        .inFromDte(dte_2_mem),
        .out2Dte(mem_2_dte),
        .out2Sch(mem_2_sch)
    );

    //mem_TOP u_mainMem (
    //    .clk(clk),
    //    .rst(rst),
    //    .address_bus(addrBus),
    //    .data_bus(dataBus),
    //    .inFromDte_ld_req(dte_2_mem.ld_req),
    //    .inFromDte_st_req(dte_2_mem.st_req),
    //    .inFromDte_permission2DriveBus(dte_2_mem.permission2DriveBus),
    //    .out2Dte_mem_Ready(mem_2_dte.mem_Ready),
    //    .out2Sch_writeBuf_V(mem_2_sch.writeBuf_V)
    //);

    DMA_Controller uut_dma (
        .clk(clk),
        .rst(rst),
        .inFromDTE_i(dte_2_dma),
        .out2Core_o(dma_2_core),
        .out2Sch_o(dma_2_sch),
        .dataBus(dataBus),
        .addrBus(addrBus)
    );

    ddr5 uut_ddr5 (
        .clk(clk),
        .rst(rst),  //active low
        .inFromDTE_i(dte_2_ddr5),
        .dataBus(dataBus),
        .addrBus(dataBus)
    );

    dcache_loader dcache_loader_unit ();
    tb_memGen_InitRitual mem_loader_unit ();
    diskLoader disk_loader_unit();

    initial begin
        rst = 0;
        icache_2_sch = '{default: '0};
        core_2_dcache = '{default: '0};
        for (int i = 0; i < NUM_DCACHE_PORTS; i++) core_2_dcache.stq_heads[i].empty = 1;
        core_2_dcache.stq_info_mio.empty = 1;
        DelayCLKs(10);
        rst = 1;

        //writing disk src addr
        @(posedge clk);
        core_2_dcache.stq_info_mio.address = 32'h0000;
        core_2_dcache.stq_info_mio.data = '{default: 8'h00};
        core_2_dcache.stq_info_mio.empty = 0;
        @(posedge clk);
        core_2_dcache.stq_info_mio.empty = 1;
        DelayCLKs(10);
        
        //writing mem destination addr
        @(posedge clk);
        core_2_dcache.stq_info_mio.address = 32'h0010;
        core_2_dcache.stq_info_mio.data = {8'h00, 8'h20,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00};
        core_2_dcache.stq_info_mio.empty = 0;
        @(posedge clk);
        core_2_dcache.stq_info_mio.empty = 1;
        DelayCLKs(10);

        //writing num bytes
        @(posedge clk);
        core_2_dcache.stq_info_mio.address = 32'h0020;
        core_2_dcache.stq_info_mio.data = {8'h10, 8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00};
        core_2_dcache.stq_info_mio.empty = 0;
        @(posedge clk);
        core_2_dcache.stq_info_mio.empty = 1;
        DelayCLKs(10);
        
        //starting the dma transfer
        @(posedge clk);
        core_2_dcache.stq_info_mio.address = 32'h0030;
        core_2_dcache.stq_info_mio.data = {default : '1};
        core_2_dcache.stq_info_mio.empty = 0;
        @(posedge clk);
        core_2_dcache.stq_info_mio.empty = 1;
        
        @(posedge dma_2_core.intOut);

        /////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
        /////////////////////////////////////////////////////////////////////////////////////
        DelayCLKs(500);
        `LOG("DCache  Tb Complete");
        $finish;

    end

endmodule
