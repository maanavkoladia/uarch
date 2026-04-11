import common_pkg::*;
import interconnect_pkg::*;

module tb_ddr5 ();

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
    icache_2_scheduler_t icache_2_sch;
    dcache_2_scheduler_t dcache_2_sch;
    mem_2_scheduler_t mem_2_sch;
    dma_controller_2_scheduler_t dma_2_sch;

    core_2_dcache_t core_2_dcache;
    dcache_2_core_t dcache_2_core;
    dte_2_dcache_t dte_2_dcache;

    dte_2_ddr5_t dte_2_ddr5;

    // ================= MEMORY =================
    mem_2_dte_t mem_2_dte;
    dte_2_mem_t dte_2_mem;

    DCache_TOP uut_dcache (
        .clk(clk),
        .rst(rst),
        .inFromCore_i(core_2_dcache),
        .out2Core_o(dcache_2_core),
        .inFromDTE_i(dte_2_dcache),
        .out2Sch_o(dcache_2_sch),
        .dataBus(dataBus),
        .address_bus(addrBus)
    );

    BusArbitration busArb (
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
        .dte_2_ddr5_o(dte_2_ddr5)
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

    initial begin
        rst = 0;
        icache_2_sch = '{default: '0};
        dma_2_sch = '{default: '0};
        core_2_dcache = '{default: '0};
        for (int i = 0; i < NUM_DCACHE_PORTS; i++) core_2_dcache.stq_heads[i].empty = 1;
        core_2_dcache.stq_info_mio.empty = 1;

        rst = 1;

        /////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
        /////////////////////////////////////////////////////////////////////////////////////
        DelayCLKs(30);
        `LOG("DCache  Tb Complete");
        $finish;

    end

endmodule
