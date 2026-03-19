import common_pkg::*;
import interconnect_pkg::*;
import mem_common_pkg::*;
import tb_mainMem_pkg::*;

/*
typedef struct {
    bool ld_req;
    bool st_req;
    bool start_transaction;
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

    `CLK_INIT(CLK_PERIOD)
    //`GEN_WAVEFORM_VCD("wave.vcd", tb_memBanks, 10);
    //`GEN_WAVEFORM_VPD("wave.vpd", tb_memBanks, 10);

    logic rst;
    wire [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus;
    wire [ADDRESS_BUS_WIDTH_BITS - 1 : 0] addrBus;
    dte_2_mem_t fromDte;
    mem_2_dte_t mem2dte;
    mem_2_scheduler_t mem2Sch;

    //gate the bus
    assign dataBus = 'z;
    assign addrBus = 'z;


    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    mem_TOP uut0 (
        .clk(clk),
        .rst(rst),
        .address_bus(addrBus),
        .data_bus(dataBus),
        .inFromDte(fromDte),
        .out2Dte(mem2dte),
        .out2Sch(mem2Sch)
    );
    
    //init module to initMem
    tb_memGen_InitRitual memLoader();
    initial begin
        `LOG("Main Mem Tb Starting up");
        fromDte.ld_req = 0;
        fromDte.st_req = 0;
        fromDte.start_transaction = 0;
        fromDte.permission2DriveBus[0] = 0;
        fromDte.permission2DriveBus[1] = 0;
        fromDte.permission2DriveBus[2] = 0;
        fromDte.permission2DriveBus[3] = 0;
        rst = 0;//actve low
        DelayCLKs(5);
        rst = 1;//actve low
        /////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
        /////////////////////////////////////////////////////////////////////////////////////
        DelayCLKs(30);
        `LOG("Mem Bank Tb Complete");
        $finish;
    end
endmodule
