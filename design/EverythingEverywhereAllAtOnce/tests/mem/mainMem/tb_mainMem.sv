import common_pkg::*;
import interconnect_pkg::*;
import mem_common_pkg::*;


/*
typedef struct {
    bool ld_req;
    bool st_req;
    //bool start_transaction;
    bool permission2DriveBus[MEM_BUS_SIZE/DATA_BUS_WIDTH_BITS];
} dte_2_mem_t;

typedef struct {
    logic writeBuf_V[numWriteBufsInMem];
} mem_2_scheduler_t;

typedef struct {
    bool mem_Ready;
} mem_2_dte_t;

*/



module tb_mainMem ();

    localparam int CLK_PERIOD = 8;
    `CLK_INIT(CLK_PERIOD)
    //`GEN_WAVEFORM_VCD("wave.vcd", tb_memBanks, 10);
    //`GEN_WAVEFORM_VPD("wave.vpd", tb_memBanks, 10);

    task automatic DelayCLKs(input int cycles);
        #(CLK_PERIOD * cycles);
    endtask

    logic rst;
    wire [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus;
    wire [ADDRESS_BUS_WIDTH_BITS - 1 : 0] addrBus;

    //to give the memmodule and addr
   


    dte_2_mem_t fromDte;
    mem_2_dte_t mem2dte;
    mem_2_scheduler_t mem2Sch;
    req_2_sch_t bestPick_i;
    core_2_icache_t core_2_icache;

    dte_2_icache_t dte_2_icache;





    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    mem_TOP uut0 (
        .clk(clk),
        .rst(rst),
        .address_bus(addrBus),
        .data_bus(dataBus),
        .inFromDte_ld_req(fromDte.ld_req),
        .inFromDte_st_req(fromDte.st_req),
        .inFromDte_permission2DriveBus(fromDte.permission2DriveBus),
        .out2Dte_mem_Ready(mem2dte.mem_Ready),
        .out2Sch_writeBuf_V(mem2Sch.writeBuf_V)
    );

    ICache uut_icache(
        .clk(clk),
        .rst(rst),
        .inFromCore_i(core_2_icache),
        .out2Core_o(),
        .inFromDte_i(dte_2_icache),
        .out2Sch_o(),
        .dataBus(dataBus),
        .addrBus(addrBus)
    );

    DTE dte(
        .clk(clk),
        .rst(rst),
        .bestPick_i(bestPick_i),
        .bestPick_bk_id_i(0),
        .dte_out_2_icache_o(dte_2_icache),
        .dte_out_2_dcache_o(),
        .mem_2_dte_i(mem2dte),
        .dte_2_mem_o(fromDte),
        .dte_2_dma_o(),
        .dte_2_ddr5_o()
    );
    
    //init module to initMem
    tb_memGen_InitRitual memLoader ();

    initial begin
        `LOG("Main Mem Tb Starting up");
        rst = 0;
        core_2_icache = '{default: '0};
        bestPick_i = NO_REQ;
        DelayCLKs(10);
        @(posedge clk)
        rst = 1;
        DelayCLKs(5);
        @(posedge clk)
        bestPick_i = ICACHE_HIGH_PRI;
        core_2_icache.icache_en = 1;
        core_2_icache.p_addr = 15'h1000;
        core_2_icache.v_addr_i = 32'h1000;
        @(posedge clk)
        bestPick_i = NO_REQ;

        /////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
        /////////////////////////////////////////////////////////////////////////////////////
        DelayCLKs(30);
        `LOG("Mem Bank Tb Complete");
        $finish;
    end
endmodule
