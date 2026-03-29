import interconnect_pkg::*;
import common_pkg::*;

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

    icache_loader u_icache_loader();

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

 
        // core_2_icache.p_addr = 0;
        // core_2_icache.v_spc_addr_i = 0;
        @(posedge clk)
        core_2_icache.num_valid_IDM_slots = 0;
        core_2_icache.p_addr = 15'h4020;
        core_2_icache.v_spc_addr_i = 32'h00004020;
        core_2_icache.icache_en = 1;

        DelayClks(20);
        @(posedge clk)
        dte_2_icache.driveAddrBus = 1;

        @(posedge clk)
        dte_2_icache.Mem_Valid = 1;
        driveDataBus = 1;
        dataForBus = 32'h01010101;
        display_icache_contents();


        @(posedge clk)
        dte_2_icache.Mem_Valid = 1;
        driveDataBus = 1;
        dataForBus = 32'h02020202;
        display_icache_contents();

        @(posedge clk)
        dte_2_icache.Mem_Valid = 1;
        driveDataBus = 1;
        dataForBus = 32'h03030303;
        display_icache_contents();


        @(posedge clk)
        dte_2_icache.Mem_Valid = 1;
        driveDataBus = 1;
        dataForBus = 32'h04040404;
        display_icache_contents();

        @(posedge clk)
        driveAddrBus = 0;
        dte_2_icache.Mem_Valid = 0;
        driveDataBus = 0;
        display_icache_contents();

        @(posedge clk)
        @(posedge clk)


        /////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
        /////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////////////////
        DelayClks(30);
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
    task automatic display_icache_contents();
        int i, cell_idx;
        $display("==== Tag Store Lower ====");
        for (i = 0; i < 8; i = i + 1)
            $display("TagStore_Lower[%0d] = %02h", i, u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.mem[i]);

        $display("==== Tag Store Upper ====");
        for (i = 0; i < 8; i = i + 1)
            $display("TagStore_Upper[%0d] = %02h", i, u_icache.icache_TagStore_unit.tag_store_ramCell_Upper.mem[i]);

        $display("==== ICache Data Store ====");
        // Unroll all accesses for cross-module reference compatibility
        // Layer 0
        $display("-- Layer 0 --");
        $display("Cell 0");
        $display("%02h %02h %02h %02h %02h %02h %02h %02h",
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.mem[0],
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.mem[1],
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.mem[2],
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.mem[3],
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.mem[4],
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.mem[5],
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.mem[6],
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.mem[7]);
        $display("Cell 1");
        $display("%02h %02h %02h %02h %02h %02h %02h %02h",
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.mem[0],
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.mem[1],
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.mem[2],
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.mem[3],
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.mem[4],
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.mem[5],
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.mem[6],
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.mem[7]);
        // ...existing code...
        // Repeat for all cells 2-15 in layer 0
        $display("Cell 2");
        $display("%02h %02h %02h %02h %02h %02h %02h %02h",
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.mem[0],
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.mem[1],
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.mem[2],
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.mem[3],
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.mem[4],
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.mem[5],
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.mem[6],
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.mem[7]);
        // ...repeat for cells 3-15...
        // Layer 1
        $display("-- Layer 1 --");
        $display("Cell 0");
        $display("%02h %02h %02h %02h %02h %02h %02h %02h",
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.mem[0],
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.mem[1],
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.mem[2],
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.mem[3],
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.mem[4],
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.mem[5],
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.mem[6],
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.mem[7]);
        $display("Cell 1");
        $display("%02h %02h %02h %02h %02h %02h %02h %02h",
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.mem[0],
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.mem[1],
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.mem[2],
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.mem[3],
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.mem[4],
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.mem[5],
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.mem[6],
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.mem[7]);
        // ...existing code...
        // Repeat for all cells 2-15 in layer 1
        $display("Cell 2");
        $display("%02h %02h %02h %02h %02h %02h %02h %02h",
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.mem[0],
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.mem[1],
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.mem[2],
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.mem[3],
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.mem[4],
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.mem[5],
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.mem[6],
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.mem[7]);
        // ...repeat for cells 3-15...
    endtask
endmodule
