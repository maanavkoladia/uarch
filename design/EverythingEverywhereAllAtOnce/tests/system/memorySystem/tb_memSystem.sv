import interconnect_pkg::*;
import common_pkg::*;

module tb_memSystem ();
    localparam int Clk_PERIOD = 10;

    // ================= CLOCK / RESET =================
    `CLK_INIT(Clk_PERIOD);
    logic rst;

    // ================= BUSSES =================
    wire [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus;
    wire [ADDRESS_BUS_WIDTH_BITS - 1 : 0] addrBus;

    //to give the memmodule and addr
    p_address_t addrForBus;
    bool driveAddrBus;

    logic [31 : 0] dataForBus;
    bool driveDataBus;

    //gate the bus
    assign dataBus = driveDataBus ? dataForBus : 'z;
    assign addrBus = driveAddrBus ? addrForBus : 'z;


    // ================= ICACHE =================
    icache_2_scheduler_t icache_2_sched;
    dte_2_icache_t       dte_2_icache;

    core_2_icache_t      core_2_icache;
    icache_2_core_t      icache_2_core;

    //// ================= DCACHE =================
    //dcache_2_scheduler_t         dcache_2_sched;
    //dte_2_dcache_t               dte_2_dcache;

    //core_2_dcache_t              core_2_dcache;
    //dcache_2_core_t              dcache_2_core;

    //// ================= MEMORY =================
    mem_2_scheduler_t    mem_2_sched;
    mem_2_dte_t          mem_2_dte;
    dte_2_mem_t          dte_2_mem;

    //// ================= DMA =================
    //dma_controller_2_scheduler_t dma_2_sched;
    //dte_2_dma_controller_t       dte_2_dma;
    //dma_controller_2_core_t      dma_2_core;

    //// ================= DDR5 =================
    //dte_2_ddr5_t                 dte_2_ddr5;

    // ================= (Optional) MEM LOADER =================
    // You didn’t define a struct, so placeholder:
    // logic mem_loader_done;

    task automatic DelayClks(input int cycles);
        #(Clk_PERIOD * cycles);
    endtask

    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    // // ================= ICACHE =================
    // ICache u_icache (
    //     .clk(clk),
    //     .rst(rst),
    //     .inFromCore_i(core_2_icache),
    //     .out2Core_o(icache_2_core),
    //     .dte_out_i(dte_2_icache),
    //     .out2Sch_o(icache_2_sched),
    //     .dataBus(dataBus),
    //     .addrBus(addrBus)
    // );

    // // ================= DCACHE =================
    // DCache_TOP u_dcache (
    //     .clk(clk),
    //     .rst(rst),
    //     .inFromCore_i(core_2_dcache),
    //     .out2Core_o(dcache_2_core),
    //     .inFromDTE_i(dte_2_dcache),
    //     .out2Sch_o(dcache_2_sched),
    //     .dataBus(dataBus),
    //     .address_bus(addrBus)
    // );




    // ================= MEMORY =================
    //mem_TOP u_mem (
    //    .clk(clk),
    //    .rst(rst),
    //    .address_bus(addrBus),
    //    .data_bus(dataBus),
    //    .inFromDte(dte_2_mem),
    //    .out2Dte(mem_2_dte),
    //    .out2Sch(mem_2_sched)
    //);

    //tb_memGen_InitRitual u_memLoader ();


    // // ================= BUS ARBITER =================
    // BusArbitration u_arb (
    //     .clk(clk),
    //     .rst(rst),
    //     .iCache_2_Sch_i(icache_2_sched),
    //     .dte_out_2_icache_o(dte_2_icache),
    //     .dCache_2_Sch_i(dcache_2_sched),
    //     .dte_out_2_dcache_o(dte_2_dcache),
    //     .mem_2_Sch_i(mem_2_sched),
    //     .mem_2_dte_i(mem_2_dte),
    //     .dte_2_mem_o(dte_2_mem),
    //     .dma_2_sch_i(dma_2_sched),
    //     .dte_2_dma_o(dte_2_dma),
    //     .dte_2_ddr5_o(dte_2_ddr5)
    // );

    // // ================= DMA =================
    // DMA_Controller u_dma (
    //     .clk(clk),
    //     .rst(rst),
    //     .inFromDTE_i(dte_2_dma),
    //     .out2Core_o(dma_2_core),
    //     .out2Sch_o(dma_2_sched),
    //     .dataBus(dataBus),
    //     .addrBus(addrBus)
    // );


    // ================= DDR5 =================
    // ddr5 u_ddr5 (
    //     .clk(clk),
    //     .rst(rst),
    //     .inFromDTE_i(dte_2_ddr5),
    //     .dataBus(dataBus),
    //     .addrBus(addrBus)
    // );  //create mem loader

    initial begin
        `LOG("Starting mem System TB");
        dte_2_mem.ld_req = 0;
        dte_2_mem.st_req = 0;

        //dte_2_mem.start_transaction = 0;
        dte_2_mem.permission2DriveBus[0] = 0;
        dte_2_mem.permission2DriveBus[1] = 0;
        dte_2_mem.permission2DriveBus[2] = 0;
        dte_2_mem.permission2DriveBus[3] = 0;
        addrForBus = 32'h1000;
        dataForBus = 0;
        //addrForBus = 32'h1290;
        driveAddrBus = 0;
        driveDataBus = 0;
        rst = 0;  //actve low

        DelayClks(5);
        rst = 1;  //actve low

        /////////////////////////////////////////////////////////////////////////////////////
        //LD_REQ logic//
        /////////////////////////////////////////////////////////////////////////////////////

        DelayClks(20);
        addrForBus = 32'h1000;
        driveAddrBus = 1;
        dte_2_mem.ld_req = 1;
        @(posedge mem_2_dte.mem_Ready);
        @(posedge clk);
        dte_2_mem.ld_req = 0;
        dte_2_mem.permission2DriveBus[0] = 1;  //lsb onto bus
        @(posedge clk);
        dte_2_mem.permission2DriveBus[0] = 0;
        dte_2_mem.permission2DriveBus[1] = 1;
        @(posedge clk);
        dte_2_mem.permission2DriveBus[1] = 0;
        dte_2_mem.permission2DriveBus[2] = 1;
        @(posedge clk);
        dte_2_mem.permission2DriveBus[2] = 0;
        dte_2_mem.permission2DriveBus[3] = 1;  //msb onto bus
        @(posedge clk);
        dte_2_mem.permission2DriveBus[3] = 0;
        @(posedge clk);
        driveAddrBus = 0;
        DelayClks(30);


        /////////////////////////////////////////////////////////////////////////////////////
        //ST_Req
        /////////////////////////////////////////////////////////////////////////////////////
        @(negedge clk);
        addrForBus = 32'h0400;
        dataForBus = 32'h33221100;  //lsb
        driveAddrBus = 1;
        driveDataBus = 1;
        dte_2_mem.st_req = 1;
        @(posedge clk);
        dte_2_mem.st_req = 0;
        dataForBus = 32'h77665544;  //lsb
        @(posedge clk);
        dataForBus = 32'hbbaa9988;  //lsb
        @(posedge clk);
        dataForBus = 32'hffeeddcc;  //lsb
        @(posedge clk);
        driveAddrBus = 0;
        driveDataBus = 0;

        /////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
        /////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////////////////
        DelayClks(30);
        $finish;
        `LOG("Finishing mem System TB");
    end
endmodule
