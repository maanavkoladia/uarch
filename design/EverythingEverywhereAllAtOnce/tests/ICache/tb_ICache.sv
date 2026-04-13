import common_pkg::*;
import interconnect_pkg::*;

module tb_ICache ();

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

    dte_2_icache_t dte_2_icache;
    core_2_icache_t core_2_icache;
    icache_2_core_t icache_2_core;

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
        .dte_out_2_icache_o(dte_2_icache),
        .dCache_2_Sch_i(dcache_2_sch),
        .dte_out_2_dcache_o(dte_2_dcache),
        .mem_2_Sch_i(mem_2_sch),
        .mem_2_dte_i(mem_2_dte),
        .dte_2_mem_o(dte_2_mem),
        .dma_2_sch_i(dma_2_sch),
        .dte_2_dma_o(dte_2_dma),
        .dte_2_ddr5_o(dte_2_ddr5)
    );

    // mem_TOP u_mainMem (
    //     .clk(clk),
    //     .rst(rst),
    //     .address_bus(addrBus),
    //     .data_bus(dataBus),
    //     .inFromDte(dte_2_mem),
    //     .out2Dte(mem_2_dte),
    //     .out2Sch(mem_2_sch)
    // );

    mem_TOP u_mainMem (
        .clk(clk),
        .rst(rst),
        .address_bus(addrBus),
        .data_bus(dataBus),
        .inFromDte_ld_req(dte_2_mem.ld_req),
        .inFromDte_st_req(dte_2_mem.st_req),
        .inFromDte_permission2DriveBus(dte_2_mem.permission2DriveBus),
        .out2Dte_mem_Ready(mem_2_dte.mem_Ready),
        .out2Sch_writeBuf_V(mem_2_sch.writeBuf_V)
    );

    DMA_Controller u_dma (
        .clk(clk),
        .rst(rst),
        .inFromDTE_i(dte_2_dma),
        .out2Core_o(dma_2_core),
        .out2Sch_o(dma_2_sch),
        .dataBus(dataBus),
        .addrBus(addrBus)
    );

    ddr5 u_ddr5 (
        .clk(clk),
        .rst(rst),  //active low
        .inFromDTE_i(dte_2_ddr5),
        .dataBus(dataBus),
        .addrBus(addrBus)
    );
    

    ICache uut_icache (
        .clk(clk),
        .rst(rst),
        .inFromCore_i(core_2_icache),
        .out2Core_o(icache_2_core),
        .inFromDte_i(dte_2_icache),
        .out2Sch_o(icache_2_sch),
        .dataBus(dataBus),
        .addrBus(addrBus)
    );


    dcache_loader dcache_loader_unit ();
    tb_memGen_InitRitual mem_loader_unit ();
    diskLoader disk_loader_unit();
    icache_loader icache_loader_unit();

    initial begin
        rst = 0;
        core_2_icache = '{default: '0};
        core_2_dcache = '{default: '0};
        for (int i = 0; i < NUM_DCACHE_PORTS; i++) core_2_dcache.stq_heads[i].empty = 1;
        core_2_dcache.stq_info_mio.empty = 1;

        DelayCLKs(10);
        rst = 1;
        DelayCLKs(6);
        @(posedge clk);
        core_2_icache.icache_en = 1;
        core_2_icache.p_addr = 15'h10D0;
        core_2_icache.v_addr_i = 32'h123456C0;

        @(posedge icache_2_core.hit)
        @(posedge clk)
        #1
        core_2_icache.icache_en = 1;
        core_2_icache.p_addr = 15'h20D0;
        core_2_icache.v_addr_i = 32'h2d2d2dC0;
 
        @(posedge icache_2_core.hit)
        @(posedge clk)
        #1
        core_2_icache.icache_en = 1;
        core_2_icache.p_addr = 15'h10D0; //hit in victim 
        core_2_icache.v_addr_i = 32'h123456C0;

        //in cache h123456C0
        //in victim: 2d2d2dc0 //at index 3
        
        @(posedge icache_2_core.hit)
        @(posedge clk)
        #1
        core_2_icache.icache_en = 1;
        core_2_icache.p_addr = 15'h30D0;
        core_2_icache.v_addr_i = 32'h333333C0;
        //in cache 3333333c0
        //LRU MRU
                //3     1
        //in v$ 2d2d2d 123456c0 

        @(posedge icache_2_core.hit)
        @(posedge clk)
        #1
        core_2_icache.icache_en = 1;
        core_2_icache.p_addr = 15'h40D0;
        core_2_icache.v_addr_i = 32'h444444C0;
        //in cache 3333333c0
        //       3      1         2
        //in v$ 2d2d2d 123456c0  333333C0

        @(posedge icache_2_core.hit)
        @(posedge clk)
        #1
        core_2_icache.icache_en = 1;
        core_2_icache.p_addr = 15'h50D0;
        core_2_icache.v_addr_i = 32'h555555C0;
        //in cache 555555c0
                    // 3       1        2        0
        //in victim: 2d2d2d 123456c0 333333c0 444444c0

        @(posedge icache_2_core.hit)
        @(posedge clk)
        #1
        core_2_icache.icache_en = 1;
        core_2_icache.p_addr = 15'h60D0;
        core_2_icache.v_addr_i = 32'h666666C0;
        //in cache 555555c0
                     // 3       1        2        0
        //in victim: 555555c0 123456c0 333333c0 444444c0

        @(posedge icache_2_core.hit)
        @(posedge clk)
        #1
        core_2_icache.icache_en = 1;
        core_2_icache.p_addr = 15'h20D0;
        core_2_icache.v_addr_i = 32'h2d2d2dC0;



         
        /////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
        /////////////////////////////////////////////////////////////////////////////////////
        DelayCLKs(100);
        `LOG("DCache  Tb Complete");
        $finish;

    end

endmodule
