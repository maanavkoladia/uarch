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

    localparam int CLK_PERIOD = 10;
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
    p_address_t addrForBus;
    bool driveAddrBus;

    logic [31 : 0] data2Bus;
    bool driveDataBus;

    dte_2_mem_t fromDte;
    mem_2_dte_t mem2dte;
    mem_2_scheduler_t mem2Sch;

    //gate the bus
    assign dataBus = driveDataBus ? data2Bus : 'z;
    assign addrBus = driveAddrBus ? addrForBus : 'z;


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
    tb_memGen_InitRitual memLoader ();

    initial begin
        `LOG("Main Mem Tb Starting up");
        fromDte.ld_req = 0;
        fromDte.st_req = 0;
        //fromDte.start_transaction = 0;
        fromDte.permission2DriveBus[0] = 0;
        fromDte.permission2DriveBus[1] = 0;
        fromDte.permission2DriveBus[2] = 0;
        fromDte.permission2DriveBus[3] = 0;
        addrForBus = 32'h1000;
        //addrForBus = 32'h1290;
        driveAddrBus = 0;
        driveDataBus = 0;
        rst = 0;  //actve low

        DelayCLKs(5);
        rst = 1;  //actve low
        DelayCLKs(20);

        /////////////////////////////////////////////////////////////////////////////////////
        //LD_REQ logic//
        /////////////////////////////////////////////////////////////////////////////////////
        DelayCLKs(20);
        addrForBus = 32'h1000;
        driveAddrBus = 1;
        fromDte.ld_req = 1;
        @(posedge mem2dte.mem_Ready);
        @(posedge clk);
        fromDte.ld_req = 0;
        fromDte.permission2DriveBus[0] = 1;  //lsb onto bus
        @(posedge clk);
        fromDte.permission2DriveBus[0] = 0;
        fromDte.permission2DriveBus[1] = 1;
        @(posedge clk);
        fromDte.permission2DriveBus[1] = 0;
        fromDte.permission2DriveBus[2] = 1;
        @(posedge clk);
        fromDte.permission2DriveBus[2] = 0;
        fromDte.permission2DriveBus[3] = 1;  //msb onto bus
        @(posedge clk);
        fromDte.permission2DriveBus[3] = 0;
        @(posedge clk);
        driveAddrBus = 0;
        DelayCLKs(30);


        /////////////////////////////////////////////////////////////////////////////////////
        //ST_Req
        /////////////////////////////////////////////////////////////////////////////////////
        @(negedge clk);
        addrForBus = 32'h0400;
        data2Bus = 32'h33221100;  //lsb
        driveAddrBus = 1;
        driveDataBus = 1;
        fromDte.st_req = 1;
        @(posedge clk);
        fromDte.st_req = 0;
        data2Bus = 32'h77665544;  //lsb
        @(posedge clk);
        data2Bus = 32'hbbaa9988;  //lsb
        @(posedge clk);
        data2Bus = 32'hffeeddcc;  //lsb
        @(posedge clk);
        driveAddrBus = 0;
        driveDataBus = 0;

        /////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
        /////////////////////////////////////////////////////////////////////////////////////
        DelayCLKs(30);
        `LOG("Mem Bank Tb Complete");
        $finish;
    end
endmodule
