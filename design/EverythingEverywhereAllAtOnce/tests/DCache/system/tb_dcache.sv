import common_pkg::*;
import interconnect_pkg::*;

module tb_dcache ();

    localparam CLK_PERIOD = 10;

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
    p_address_t addrForBus;
    bool driveAddrBus;

    logic [31 : 0] dataForBus;
    bool driveDataBus;

    core_2_dcache_t inFromCore;
    dcache_2_core_t out2Core;
    dte_2_dcache_t inFromDTE;
    dcache_2_scheduler_t out2Sch;

    // ================= MEMORY =================
    mem_2_dte_t mem_2_dte;
    dte_2_mem_t dte_2_mem;

    req_2_sch_t bestPick_req_2_dte;
    logic [$clog2(NUM_DCACHE_PORTS) - 1 : 0] bestPick_bk_id_2_dte;


    DCache_TOP uut0_DCache (
        .clk(clk),
        .rst(rst),
        .inFromCore_i(inFromCore),
        .out2Core_o(out2Core),
        .inFromDTE_i(inFromDTE),
        .out2Sch_o(out2Sch),
        .dataBus(dataBus),
        .address_bus(addrBus)
    );

    mem_TOP uut1_mem (
        .clk(clk),
        .rst(rst),
        .address_bus(addrBus),
        .data_bus(dataBus),
        .inFromDte(inFromDTE),
        .out2Dte(mem_2_dte),
        .out2Sch()
    );

    DTE uut2_DTE (
        .clk(clk),
        .rst(rst),
        .bestPick_i(bestPick_req_2_dte),
        .bestPick_bk_id_i(bestPick_bk_id_2_dte),
        .dte_out_2_icache_o(),
        .dte_out_2_dcache_o(),
        .mem_2_dte_i(mem_2_dte),
        .dte_2_mem_o(dte_2_mem),
        .dte_2_dma_o(),
        .dte_2_ddr5_o()
    );

    dcache_loader dcache_loader_unit ();
    tb_memGen_InitRitual mem_loader_unit ();

    assign dataBus = driveDataBus ? dataForBus : 'z;
    assign addrBus = driveAddrBus ? addrForBus : 'z;

    initial begin
        rst = 0;
        addrForBus = 0;
        driveAddrBus = 0;
        dataForBus = 0;
        driveDataBus = 0;
        inFromCore = '{default: '0};
        for (int i = 0; i < NUM_DCACHE_PORTS; i++) inFromCore.stq_heads[i].empty = 1;
        inFromCore.stq_info_mio[i].empty = 1;
        bestPick_req_2_dte = NO_REQ;
        bestPick_bk_id_2_dte = 0;
        DelayCLKs(10);

        rst = 1;

        /////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
        /////////////////////////////////////////////////////////////////////////////////////
        DelayCLKs(30);
        `LOG("DCache  Tb Complete");
        $finish;

    end

endmodule
