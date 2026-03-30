

import common_pkg::*;
import interconnect_pkg::*;
import DTE_FSM_gen_pkg::*;
//import print_icache_pkg::*;
   
    // LOWER (layer 0)
    `define ICACHE_PRINT_LINE_LOWER(ROW) \
        $display("Lower Idx: %0d, Tag: %02h | %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h", \
            ROW, \
            /*u_icache.icache_TagStore_unit.validStore[ROW]*/ \
            tb_DTE.uut1_icache.icache_TagStore_unit.tag_store_ramCell_Lower.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.mem[ROW] \
        );

    // UPPER (layer 1)
    `define ICACHE_PRINT_LINE_UPPER(ROW) \
        $display("Upper Idx: %0d, Tag: %02h | %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h", \
            ROW, \
            tb_DTE.uut1_icache.icache_TagStore_unit.tag_store_ramCell_Upper.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.mem[ROW] \
        );


    task automatic display_icache_contents();

        $display("==== ICache Contents ====");
        $display("Valid Bits:");
        for(int i = 0; i < 16; i++ ) $display("IDX: %2d, V: %0d", i, tb_DTE.uut1_icache.icache_TagStore_unit.validStore[i]);
        $display("==========================================================");
            

        // Lower (0–7)
        `ICACHE_PRINT_LINE_LOWER(0)
        `ICACHE_PRINT_LINE_LOWER(1)
        `ICACHE_PRINT_LINE_LOWER(2)
        `ICACHE_PRINT_LINE_LOWER(3)
        `ICACHE_PRINT_LINE_LOWER(4)
        `ICACHE_PRINT_LINE_LOWER(5)
        `ICACHE_PRINT_LINE_LOWER(6)
        `ICACHE_PRINT_LINE_LOWER(7)

        // Upper (0–7)
        `ICACHE_PRINT_LINE_UPPER(0)
        `ICACHE_PRINT_LINE_UPPER(1)
        `ICACHE_PRINT_LINE_UPPER(2)
        `ICACHE_PRINT_LINE_UPPER(3)
        `ICACHE_PRINT_LINE_UPPER(4)
        `ICACHE_PRINT_LINE_UPPER(5)
        `ICACHE_PRINT_LINE_UPPER(6)
        `ICACHE_PRINT_LINE_UPPER(7)

    endtask


module tb_DTE ();
    localparam int Clk_PERIOD = 10;

    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    task automatic DelayClks(input int cycles);
        #(Clk_PERIOD * cycles);
    endtask


    // ================= CLOCK / RESET =================
    `CLK_INIT(Clk_PERIOD);
    logic                                                     rst;
    wire                   [   ADDRESS_BUS_WIDTH_BITS -1 : 0] address_bus;
    wire                   [     DATA_BUS_WIDTH_BITS - 1 : 0] data_bus;
    logic [31:0] addres_bus_drv;
    logic [31:0] data_bus_drv;

    //================== CORE ==================
    icache_2_core_t                                           icache_2_core;
    core_2_icache_t core_2_icache;
    icache_2_scheduler_t icache_2_scheduler;
    // ================= ICACHE =================
    dte_2_icache_t                                            dte_2_icache;

    // ================= DCACHE =================
    dte_2_dcache_t                                            dte_2_dcache;

    // ================= MEMORY =================
    mem_2_dte_t                                               mem_2_dte;
    dte_2_mem_t                                               dte_2_mem;

    // ================= DMA =================
    dte_2_dma_controller_t                                    dte_2_dma;

    // ================= DDR5 =================
    dte_2_ddr5_t                                              dte_2_ddr5;
    mem_2_scheduler_t                                         mem_2_sch;

    //sch pick signals
    req_2_sch_t                                               bestPick_req_2_dte;
    logic                  [$clog2(NUM_DCACHE_PORTS) - 1 : 0] bestPick_bk_id_2_dte;


    DTE uut0_DTE (
        .clk(clk),
        .rst(rst),
        .bestPick_i(bestPick_req_2_dte),
        .bestPick_bk_id_i(bestPick_bk_id_2_dte),
        .dte_out_2_icache_o(dte_2_icache),
        .dte_out_2_dcache_o(dte_2_dcache),
        .mem_2_dte_i(mem_2_dte),
        .dte_2_mem_o(dte_2_mem),
        .dte_2_dma_o(dte_2_dma),
        .dte_2_ddr5_o(dte_2_ddr5)
    );

    mem_TOP uut1_mem (
        .clk(clk),
        .rst(rst),
        //adress and data bus
        .address_bus(address_bus),
        .data_bus(data_bus),
        //arb stuff
        .inFromDte(dte_2_mem),
        .out2Dte(mem_2_dte),
        .out2Sch(mem_2_sch)
    );

    ICache uut1_icache(
      .clk(clk),
      .rst(rst),
      .inFromCore_i(core_2_icache),
      .out2Core_o(icache_2_core),
// from dte drive bus tristate, and memvalid for fsm control
      .inFromDte_i(dte_2_icache),
      .out2Sch_o(icache_2_scheduler),
//okay mankey
     .dataBus(data_bus),
     .addrBus(address_bus)
    );



    icache_loader icacheLoader();
    tb_memGen_InitRitual memLoader();

    // assign data_bus = data_bus_drv;
    // assign data_bus_drv = 'z;
    // assign address_bus = dte_2_icache.driveAddrBus ? 32'h1000 : 'z;
    assign bestPick_req_2_dte   =  icache_2_scheduler.req;

    initial begin
        `LOG("Starting mem System TB");
        $display("%m");
        //drive all signals going into dte to 0, shoudl just be memvalid right?
        //also need to give it a scheudler pick, no_req in this case
        rst = 0;  //active low

        core_2_icache = '{default : '0};
        // bestPick_req_2_dte = NO_REQ;
        bestPick_bk_id_2_dte = 0;
        DelayClks(20);
        rst = 1;
        DelayClks(10);
        @(posedge clk)
       // bestPick_req_2_dte   = ICACHE_HIGH_PRI;
        
        @(posedge clk)
        core_2_icache.icache_en = 1;
        core_2_icache.p_addr = 15'h1000;
        core_2_icache.v_spc_addr_i = 32'h1000;
        core_2_icache.num_valid_IDM_slots = 0;


        

        // @(posedge clk) 
        // bestPick_req_2_dte   = ICACHE_HIGH_PRI;
        // bestPick_bk_id_2_dte = 0;
        // @(posedge clk) bestPick_req_2_dte = NO_REQ;
  
        
        // @(posedge clk)  //ICACHE_LD0
        // @(posedge clk)  //ICACHE_LD1
        // @(posedge clk)  //ICACHE_LD2
        // @(posedge clk)
        // @(negedge clk)
        // assert (uut0_DTE.dte_mem_2_icache_fsm_state == DTE_MEM_2_ICACHE_IDLE)
        // else $error("Assert fail: Icache transation should be complete: should be IDLE \
        //              GOT: %d ", uut0_DTE.dte_mem_2_icache_fsm_state);

   
        // bestPick_req_2_dte   = DCACHE_FILL_LD;
        // bestPick_bk_id_2_dte = 1;
        // @(posedge clk) bestPick_req_2_dte = ICACHE_LOW_PRI_REQ;
        // @(posedge clk) @(posedge clk) @(posedge clk) bestPick_req_2_dte = DCACHE_EB_BLOCKING_LD;
        // bestPick_bk_id_2_dte = 3;
   
        // @(posedge clk)
        // @(posedge clk)
        // @(posedge clk)
        // @(posedge clk)
        // @(negedge clk)
        // assert (uut0_DTE.dte_mem_2_dcache_fsm_state[1] == DTE_MEM_2_DCACHE_IDLE)
        // else $error("Assert fail: dcache_2_mem should be IDLE");

        // @(posedge clk)
        // //should see store req
        // @(posedge clk)
        // @(posedge clk)
        // @(posedge clk)


        // let it idle for a bit, shoudl countinues to rx no_reqs from
        // sceduler
        DelayClks(20);
        display_icache_contents();
        //now give it a pick ...
        //need to test all the picks and getting new picks while one fsm is
        //running to enure that another dte fsm doesnt startup
        /////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
        /////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////////////////
        DelayClks(100);
        $finish;
        `LOG("Finishing mem System TB");
    end
endmodule
