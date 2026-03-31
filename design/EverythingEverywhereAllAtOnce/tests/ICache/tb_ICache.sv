import interconnect_pkg::*;
import common_pkg::*;

// LOWER (layer 0)
`define ICACHE_PRINT_LINE_LOWER(ROW) \
$display("Lower Idx: %0d, Tag: %02h | %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h", \
    ROW, \
    /*u_icache.icache_TagStore_unit.validStore[ROW]*/ \
    u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.mem[ROW] \
);

// UPPER (layer 1)
`define ICACHE_PRINT_LINE_UPPER(ROW) \
$display("Upper Idx: %0d, Tag: %02h | %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h", \
    ROW, \
    u_icache.icache_TagStore_unit.tag_store_ramCell_Upper.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.mem[ROW], \
    u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.mem[ROW] \
);

module tb_ICache ();
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

    task automatic DelayClks(input int cycles);
        #(Clk_PERIOD * cycles);
    endtask

    task automatic display_icache_contents();

        $display("==== ICache Contents ====");
        $display("Valid Bits:");
        for (int i = 0; i < 16; i++)
            $display("IDX: %2d, V: %0d", i, u_icache.icache_TagStore_unit.validStore[i]);
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

    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    // ================= ICACHE =================
    ICache u_icache (
        .clk(clk),
        .rst(rst),
        .inFromCore_i(core_2_icache),
        .out2Core_o(icache_2_core),
        .inFromDte_i(dte_2_icache),
        .out2Sch_o(icache_2_sched),
        .dataBus(dataBus),
        .addrBus(addrBus)
    );

    icache_loader u_icache_loader ();

    initial begin
        `LOG("Starting mem System TB");
        dte_2_icache = '{default: '0};
        core_2_icache = '{default: '0};  //en is low icache should idle

        addrForBus = 32'h1000;
        dataForBus = 0;
        //addrForBus = 32'h1290;
        driveAddrBus = 0;
        driveDataBus = 0;
        rst = 0;  //actve low

        DelayClks(20);
        rst = 1;  //actve low
        DelayClks(20);

        display_icache_contents();


        // core_2_icache.p_addr = 0;
        // core_2_icache.v_spc_addr_i = 0;
        @(posedge clk) core_2_icache.num_valid_IDM_slots = 0;
        core_2_icache.p_addr = 15'h4020;
        core_2_icache.v_spc_addr_i = 32'h00004020;
        core_2_icache.icache_en = 1;

        DelayClks(20);
        display_icache_contents();
        @(posedge clk) dte_2_icache.driveAddrBus = 1;

        @(posedge clk) dte_2_icache.Mem_Valid = 1;
        #5 driveDataBus = 1;
        dataForBus = 32'h01010101;
        #5 driveDataBus = 0;


        @(posedge clk) dte_2_icache.Mem_Valid = 1;
        driveDataBus = 1;
        dataForBus   = 32'h02020202;
        // display_icache_contents();

        @(posedge clk) dte_2_icache.Mem_Valid = 1;
        driveDataBus = 1;
        dataForBus   = 32'h03030303;
        // display_icache_contents();


        @(posedge clk) dte_2_icache.Mem_Valid = 1;
        driveDataBus = 1;
        dataForBus   = 32'h04040404;

        @(posedge clk) driveAddrBus = 0;
        dte_2_icache.Mem_Valid = 0;
        driveDataBus = 0;
        display_icache_contents();

        @(posedge clk)
        @(posedge clk)



        /////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
        /////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////////////////
        DelayClks(
            30);
        $finish;
        `LOG("Finishing mem System TB");
    end


    // core_2_icache.numValidIDMSlots = 0;
    // Task to display ICache and Tag Store contents in hex
    // change this so that it looks like a i cache picture, ie realy easy
    // for me to look at
    // so there are 16 lines, split between upper and lower, do lower
    // first then upper
    // <index> <tag> <dataline>
endmodule
