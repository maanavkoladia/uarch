import common_pkg::*;
import interconnect_pkg::*;

module tb_dcache ();

    localparam CLK_PERIOD = 8;

    task automatic DelayCLKs(input int cycles);
        #(CLK_PERIOD * cycles);
    endtask

    `CLK_INIT(CLK_PERIOD)
    //`GEN_WAVEFORM_VCD("wave.vcd", tb_memBanks, 10);
    //`GEN_WAVEFORM_VPD("wave.vpd", tb_memBanks, 10);

    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    logic rst;
    wire [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus;
    wire [ADDRESS_BUS_WIDTH_BITS - 1 : 0] addrBus;

    //to give the memmodule and addr

    icache_2_scheduler_t icache_2_sch;
    dcache_2_scheduler_t dcache_2_sch;
    mem_2_scheduler_t mem_2_sch;
    dma_controller_2_scheduler_t dma_2_sch;

    core_2_dcache_t core_2_dcache;
    dcache_2_core_t dcache_2_core;
    dte_2_dcache_t dte_2_dcache;

    // ================= MEMORY =================
    mem_2_dte_t mem_2_dte;
    dte_2_mem_t dte_2_mem;




    DCache_TOP uut0_dcache (
        .clk(clk),
        .rst(rst),
        .inFromCore_i(core_2_dcache),
        .out2Core_o(dcache_2_core),
        .inFromDTE_i(dte_2_dcache),
        .out2Sch_o(dcache_2_sch),
        .dataBus(dataBus),
        .address_bus(addrBus)
    );


    mem_TOP uut1_mem (
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

 

    BusArbitration busArb(
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
        .dte_2_dma_o(),
        .dte_2_ddr5_o()
    );



    dcache_loader dcache_loader_unit ();
    tb_memGen_InitRitual mem_loader_unit ();


    initial begin
        rst = 0;

        core_2_dcache = '{default: '0};
        for (int i = 0; i < NUM_DCACHE_PORTS; i++) core_2_dcache.stq_heads[i].empty = 1;
        core_2_dcache.stq_info_mio.empty = 1;
        dma_2_sch = '{default: '0};
        icache_2_sch = '{default: '0};

        DelayCLKs(10);

    
        rst = 1;
        DelayCLKs(5);
        @(posedge clk)
        //miss to x2000
        core_2_dcache.ld_addr_0_V = 1;
        core_2_dcache.ld_addr_0 = 15'h2400;
        @(posedge clk)
        core_2_dcache.ld_addr_0_V = 0;


        @(posedge dcache_2_core.hit[0])
        core_2_dcache.memStage_CLR_REQ[0] = 1;
        //hit and write to x2000
        core_2_dcache.stq_heads[0].empty = 0;
        core_2_dcache.stq_heads[0].address = 15'h2400;
        core_2_dcache.stq_heads[0].bit_vec = 16'hFF00;
        core_2_dcache.stq_heads[0].data = '{default: 8'hDE};
        @(posedge clk)
        core_2_dcache.ld_addr_0_V = 1;
        core_2_dcache.ld_addr_0 = 15'h2400;
        core_2_dcache.stq_heads[0].empty = 1;
        @(posedge clk)
        core_2_dcache.memStage_CLR_REQ[0] = 1;
        core_2_dcache.ld_addr_0_V = 0;
        @(posedge clk)
        core_2_dcache.memStage_CLR_REQ[0] = 0;

        DelayCLKs(20);
        @(posedge clk)
        core_2_dcache.ld_addr_0_V = 1;
        core_2_dcache.ld_addr_0 = 15'h2800;
        @(posedge clk)
        core_2_dcache.ld_addr_0_V = 0; //arb has latched in dcache req
        core_2_dcache.memStage_CLR_REQ[0] = 0;


        @(posedge dcache_2_core.hit[0])
        core_2_dcache.memStage_CLR_REQ[0] = 1;
        core_2_dcache.ld_addr_0_V = 1;
        core_2_dcache.ld_addr_0 = 15'h2C00;

        @(posedge clk)
        core_2_dcache.ld_addr_0_V = 0; //arb has latched in dcache req
        core_2_dcache.memStage_CLR_REQ[0] = 0;
        @(posedge dcache_2_core.hit[0])
        core_2_dcache.memStage_CLR_REQ[0] = 1;
        core_2_dcache.ld_addr_0_V = 1;
        core_2_dcache.ld_addr_0 = 15'h3000;

        @(posedge clk)
        core_2_dcache.ld_addr_0_V = 0; //arb has latched in dcache req
        core_2_dcache.memStage_CLR_REQ[0] = 0;
        @(posedge dcache_2_core.hit[0])
        core_2_dcache.memStage_CLR_REQ[0] = 1;
        core_2_dcache.ld_addr_0_V = 1;
        core_2_dcache.ld_addr_0 = 15'h3400;

        @(posedge clk)
        core_2_dcache.ld_addr_0_V = 0; //arb has latched in dcache req
        core_2_dcache.memStage_CLR_REQ[0] = 0;
        @(posedge dcache_2_core.hit[0])
        core_2_dcache.memStage_CLR_REQ[0] = 1;
        core_2_dcache.ld_addr_0_V = 1;
        core_2_dcache.ld_addr_0 = 15'h3800;

        @(posedge clk)
        core_2_dcache.ld_addr_0_V = 0; //arb has latched in dcache req
        core_2_dcache.memStage_CLR_REQ[0] = 0;
        @(posedge dcache_2_core.hit[0])
        core_2_dcache.memStage_CLR_REQ[0] = 1;
        core_2_dcache.ld_addr_0_V = 1;
        core_2_dcache.ld_addr_0 = 15'h2400;

        @(posedge clk)
        core_2_dcache.ld_addr_0_V = 0;
        core_2_dcache.memStage_CLR_REQ[0] = 0;
        @(posedge dcache_2_core.hit[0])
        core_2_dcache.memStage_CLR_REQ[0] = 1;
        core_2_dcache.ld_addr_0_V = 1;
        core_2_dcache.ld_addr_0 = 15'h2C00;


        @(posedge clk)
        core_2_dcache.ld_addr_0_V = 0;
        core_2_dcache.memStage_CLR_REQ[0] = 1;








        /////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
        /////////////////////////////////////////////////////////////////////////////////////
        DelayCLKs(30);
        `LOG("DCache  Tb Complete");
        $finish;

    end

endmodule
