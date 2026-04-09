

import common_pkg::*;
import interconnect_pkg::*;
import DTE_FSM_gen_pkg::*;
import core_common_pkg::*;

//import print_icache_pkg::*;
   
//    // LOWER (layer 0)
//    `define ICACHE_PRINT_LINE_LOWER(ROW) \
//        $display("Lower Idx: %0d, Tag: %02h | %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h", \
//            ROW, \
//            /*u_icache.icache_TagStore_unit.validStore[ROW]*/ \
//            tb_DTE.uut1_icache.icache_TagStore_unit.tag_store_ramCell_Lower.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.mem[ROW] \
//        );
//
//    // UPPER (layer 1)
//    `define ICACHE_PRINT_LINE_UPPER(ROW) \
//        $display("Upper Idx: %0d, Tag: %02h | %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h", \
//            ROW, \
//            tb_DTE.uut1_icache.icache_TagStore_unit.tag_store_ramCell_Upper.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.mem[ROW], \
//            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.mem[ROW] \
//        );


    //task automatic display_icache_contents();

    //    $display("==== ICache Contents ====");
    //    $display("Valid Bits:");
    //    for(int i = 0; i < 16; i++ ) $display("IDX: %2d, V: %0d", i, tb_DTE.uut1_icache.icache_TagStore_unit.validStore[i]);
    //    $display("==========================================================");
    //        

    //    // Lower (0–7)
    //    `ICACHE_PRINT_LINE_LOWER(0)
    //    `ICACHE_PRINT_LINE_LOWER(1)
    //    `ICACHE_PRINT_LINE_LOWER(2)
    //    `ICACHE_PRINT_LINE_LOWER(3)
    //    `ICACHE_PRINT_LINE_LOWER(4)
    //    `ICACHE_PRINT_LINE_LOWER(5)
    //    `ICACHE_PRINT_LINE_LOWER(6)
    //    `ICACHE_PRINT_LINE_LOWER(7)

    //    // Upper (0–7)
    //    `ICACHE_PRINT_LINE_UPPER(0)
    //    `ICACHE_PRINT_LINE_UPPER(1)
    //    `ICACHE_PRINT_LINE_UPPER(2)
    //    `ICACHE_PRINT_LINE_UPPER(3)
    //    `ICACHE_PRINT_LINE_UPPER(4)
    //    `ICACHE_PRINT_LINE_UPPER(5)
    //    `ICACHE_PRINT_LINE_UPPER(6)
    //    `ICACHE_PRINT_LINE_UPPER(7)

    //endtask


module tb_ICache ();
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
    icache_2_core_t icache_2_core;
    core_2_icache_t core_2_icache;
    icache_2_scheduler_t icache_2_scheduler;
    icache_2_core_t icache_info_i;
    wire dma_int;


    // ================= ICACHE =================
    dte_2_icache_t dte_2_icache;

    // ================= MEMORY =================
    mem_2_dte_t mem_2_dte;
    dte_2_mem_t dte_2_mem;

    // ================= DMA =================
    dte_2_dma_controller_t dte_2_dma;

    // ================= DDR5 =================
    dte_2_ddr5_t dte_2_ddr5;
    mem_2_scheduler_t mem_2_sch;

    //sch pick signals
    req_2_sch_t bestPick_req_2_dte;
    logic [$clog2(NUM_DCACHE_PORTS) - 1 : 0] bestPick_bk_id_2_dte;

    dcache_2_core_t DCacheIn_i;
    assign DCacheIn_i = '{default: 0};

    wire RR_we;


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
        .address_bus(address_bus),
        .data_bus(data_bus),
        .inFromDte(dte_2_mem),
        .out2Dte(mem_2_dte),
        .out2Sch(mem_2_sch)
    );

    ICache uut1_icache(
      .clk(clk),
      .rst(rst),
      .inFromCore_i(fetch_outs_o.fetch_2_icache),
      .out2Core_o(icache_2_core),
      .inFromDte_i(dte_2_icache),
      .out2Sch_o(icache_2_scheduler),
     .dataBus(data_bus),
     .addrBus(address_bus)
    );


    Scheduler uut0_scheduler (
        .clk(clk),
        .rst(rst),  //active low
        .iCache_2_Sch_i(icache_2_scheduler),
        .dCache_2_Sch_i('{default : '0}),
        .mem_2_Sch_i(mem_2_sch),
        .dma_2_sch_i('{default : '0}),
        .bestPick_o(bestPick_req_2_dte),
        .bestPick_bk_id_o(bestPick_bk_id_2_dte)
    );

    // assign decode_outs_i = '{
    //     valid: 0,
    //     stall:  0,
    //     eip: 32'h1000,
    //     invalid_instruction:  0,
    //     decode_gp: 0
    // };

    assign decode_outs_i = '{default: '0};

    
    //code segment is at 0
    assign rr_outs_i = '{default: '0};
    //decode worked fine when I had this above line uncommented
    //need to check how the rr_outs_i is being set or initialized
    assign dc_outs_i = '{default: '0};
    assign mem_outs_i = '{default: '0};
    assign exe_outs_i = '{default: '0};
    assign wb_outs_i = '{default: '0};




    icache_loader icacheLoader();
    tb_memGen_InitRitual memLoader();



    assign data_bus = data_bus_drv;
    assign data_bus_drv = 'z;


    initial begin
        `LOG("Starting mem System TB");
        $display("%m");
        //drive all signals going into dte to 0, shoudl just be memvalid right?
        //also need to give it a scheudler pick, no_req in this case
        rst = 0;  //active low


        //bestPick_req_2_dte = NO_REQ;
        DelayClks(20);
        @(posedge clk)
        //bestPick_req_2_dte   = ICACHE_HIGH_PRI;
        @(posedge clk)
        force fetch_uut.SPC = 32'h1000;
        @(posedge clk)
        rst = 1;
        release fetch_uut.SPC;
        @(posedge clk)

        @(posedge clk)
        //bestPick_req_2_dte   = ICACHE_HIGH_PRI;
        //bestPick_bk_id_2_dte = 0;
        //@(posedge clk) bestPick_req_2_dte = NO_REQ;

        @(posedge clk)  //ICACHE_LD0
        @(posedge clk)  //ICACHE_LD1
        @(posedge clk)  //ICACHE_LD2
        @(posedge clk)
        @(negedge clk)


        // bestPick_req_2_dte   = DCACHE_FILL_LD;
        // bestPick_bk_id_2_dte = 1;
        // @(posedge clk) bestPick_req_2_dte = ICACHE_LOW_PRI_REQ;
        // @(posedge clk) @(posedge clk) @(posedge clk) bestPick_req_2_dte = DCACHE_EB_BLOCKING_LD;
        // bestPick_bk_id_2_dte = 3;
        //set_limit_regs();   //task to set segment limit
        DelayClks(9);
        @(posedge clk)
        //force decode_uut.EIP = 32'h1000;
        @(posedge clk)
        //release decode_uut.EIP;

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
        //display_icache_contents();
        //display_state();
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


    // Helper to convert SPC_SEL enum to string
    function automatic string get_spc_sel_name(spc_sel_logic_output_options_e sel);
        case (sel)
            Fetch_pkg::SPC: return "SPC     ";
            Fetch_pkg::SPC_P16: return "SPC_P16 ";
            Fetch_pkg::BR_RESTORE: return "BR_RST  ";
            Fetch_pkg::BTB_TARGET: return "BTB_TGT ";
            default: return "UNKNOWN ";
        endcase
    endfunction

    //task to set limit regs
    // task automatic set_limit_regs();
    //         rr_uut.SEGMENT_LIMITS[CS_LIMIT_ID] = 32'h0000_4FFF;
    //         rr_uut.SEGMENT_LIMITS[DS_LIMIT_ID] = 32'h0000_11FF;
    //         rr_uut.SEGMENT_LIMITS[SS_LIMIT_ID] = 32'h0000_4000;
    //         rr_uut.SEGMENT_LIMITS[ES_LIMIT_ID] = 32'h0000_03FF;
    //         rr_uut.SEGMENT_LIMITS[FS_LIMIT_ID] = 32'h0000_03FF;
    //         rr_uut.SEGMENT_LIMITS[GS_LIMIT_ID] = 32'h0000_07FF;
    // endtask

endmodule
