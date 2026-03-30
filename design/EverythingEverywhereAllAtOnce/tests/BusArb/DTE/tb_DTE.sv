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



module tb_DTE ();

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

    mem_TOP uut1_mem (
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



// import common_pkg::*;
// import interconnect_pkg::*;
// import DTE_FSM_gen_pkg::*;

// module tb_DTE ();
//     localparam int Clk_PERIOD = 50;

//     initial begin
//         $vcdpluson;
//         $vcdplusmemon;
//     end

//     task automatic DelayClks(input int cycles);
//         #(Clk_PERIOD * cycles);
//     endtask


//     // ================= CLOCK / RESET =================
//     `CLK_INIT(Clk_PERIOD);
//     logic                                                     rst;
//     wire                   [   ADDRESS_BUS_WIDTH_BITS -1 : 0] address_bus;
//     wire                   [     DATA_BUS_WIDTH_BITS - 1 : 0] data_bus;
//     logic [31:0] addres_bus_drv;
//     logic [31:0] data_bus_drv;

//     // ================= ICACHE =================
//     dte_2_icache_t                                            dte_2_icache;

//     // ================= DCACHE =================
//     dte_2_dcache_t                                            dte_2_dcache;

//     // ================= MEMORY =================
//     mem_2_dte_t                                               mem_2_dte;
//     dte_2_mem_t                                               dte_2_mem;

//     // ================= DMA =================
//     dte_2_dma_controller_t                                    dte_2_dma;

//     // ================= DDR5 =================
//     dte_2_ddr5_t                                              dte_2_ddr5;
//     mem_2_scheduler_t                                         mem_2_sch;

//     //sch pick signals
//     req_2_sch_t                                               bestPick_req_2_dte;
//     logic                  [$clog2(NUM_DCACHE_PORTS) - 1 : 0] bestPick_bk_id_2_dte;


//     /*DTE uut0_DTE (
//         .clk(clk),
//         .rst(rst),
//         .bestPick_i(bestPick_req_2_dte),
//         .bestPick_bk_id_i(bestPick_bk_id_2_dte),
//         .dte_out_2_icache_o(dte_2_icache),
//         .dte_out_2_dcache_o(dte_2_dcache),
//         .mem_2_dte_i(mem_2_dte),
//         .dte_2_mem_o(dte_2_mem),
//         .dte_2_dma_o(dte_2_dma),
//         .dte_2_ddr5_o(dte_2_ddr5)
//     );*/

//     mem_TOP uut1_mem (
//         .clk(clk),
//         .rst(rst),
//         //adress and data bus
//         .address_bus(address_bus),
//         .data_bus(data_bus),
//         //arb stuff
//         .inFromDte(dte_2_mem),
//         .out2Dte(mem_2_dte),
//         .out2Sch(mem_2_sch)
//     );
//     assign data_bus = data_bus_drv;
//     assign data_bus_drv = 'z;
//     assign address_bus = dte_2_icache.driveAddrBus ? addres_bus_drv :'z;
   

//     initial begin
//         `LOG("Starting mem System TB");
//         //drive all signals going into dte to 0, shoudl just be memvalid right?
//         //also need to give it a scheudler pick, no_req in this case
//         rst = 0;  //active low
//         dte_2_mem = '{default :'0};
       
//         bestPick_req_2_dte = NO_REQ;
//         bestPick_bk_id_2_dte = 0;
//         addres_bus_drv = 32'h1000;
//         DelayClks(20);
//         rst = 1;
//         DelayClks(10);
//         @(posedge clk)
//         bestPick_req_2_dte   = ICACHE_HIGH_PRI;
        
//         @(posedge clk)
//         bestPick_req_2_dte   = NO_REQ;

//         // @(posedge clk) 
//         // bestPick_req_2_dte   = ICACHE_HIGH_PRI;
//         // bestPick_bk_id_2_dte = 0;
//         // @(posedge clk) bestPick_req_2_dte = NO_REQ;
//         // mem_2_dte.mem_Ready = 1;  //ld0 - MEMREQ
        
//         // @(posedge clk)  //ICACHE_LD0
//         // @(posedge clk)  //ICACHE_LD1
//         // @(posedge clk)  //ICACHE_LD2
//         // @(posedge clk)
//         // @(negedge clk)
//         // assert (uut0_DTE.dte_mem_2_icache_fsm_state == DTE_MEM_2_ICACHE_IDLE)
//         // else $error("Assert fail: Icache transation should be complete: should be IDLE \
//         //              GOT: %d ", uut0_DTE.dte_mem_2_icache_fsm_state);

//         // mem_2_dte.mem_Ready  = 0;
//         // bestPick_req_2_dte   = DCACHE_FILL_LD;
//         // bestPick_bk_id_2_dte = 1;
//         // @(posedge clk) bestPick_req_2_dte = ICACHE_LOW_PRI_REQ;
//         // @(posedge clk) @(posedge clk) @(posedge clk) bestPick_req_2_dte = DCACHE_EB_BLOCKING_LD;
//         // bestPick_bk_id_2_dte = 3;
//         // mem_2_dte.mem_Ready  = 1;
//         // @(posedge clk)
//         // @(posedge clk)
//         // @(posedge clk)
//         // @(posedge clk)
//         // @(negedge clk)
//         // assert (uut0_DTE.dte_mem_2_dcache_fsm_state[1] == DTE_MEM_2_DCACHE_IDLE)
//         // else $error("Assert fail: dcache_2_mem should be IDLE");

//         // @(posedge clk)
//         // //should see store req
//         // @(posedge clk)
//         // @(posedge clk)
//         // @(posedge clk)


//         // let it idle for a bit, shoudl countinues to rx no_reqs from
//         // sceduler
//         DelayClks(
//             20);
//         //now give it a pick ...
//         //need to test all the picks and getting new picks while one fsm is
//         //running to enure that another dte fsm doesnt startup
//         /////////////////////////////////////////////////////////////////////////////////////
//         //Extra completion time
//         /////////////////////////////////////////////////////////////////////////////////////
//         /////////////////////////////////////////////////////////////////////////////////////
//         DelayClks(100);
//         $finish;
//         `LOG("Finishing mem System TB");
//     end
// endmodule
