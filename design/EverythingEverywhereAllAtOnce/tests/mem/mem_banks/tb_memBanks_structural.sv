//`define CYCLE_TIME 10
//`define DELAY_CYCLES(cycles) #(`CYCLE_TIME * cycles)
//
//module tb_memBanks ();
//
//    // Clock
//    reg clk;
//
//    // Clock generation
//    initial begin
//        clk = 0;
//        forever #(`CYCLE_TIME/2) clk = ~clk;
//    end
//
//    initial begin
//        $vcdpluson;
//        $vcdplusmemon;
//    end
//
//    // Reset
//    reg rst;
//
//    // Signals
//    reg [`NUM_SRAM_ADDRESS_BITS-1:0] ld_address;
//    reg [`NUM_SRAM_ADDRESS_BITS-1:0] st_address;
//    reg startStore;
//    reg ld_address_change;
//    reg driveMemBus;
//    reg [`CACHE_LINES_SIZE_BITS-1:0] writeBuf;
//
//    wire [`MEM_BUS_SIZE-1:0] memBus;
//
//    // Dump waveform
//    // Instantiate DUT
//    mem_bank uut0 (
//        .clk(clk),
//        .rst(rst),
//        .ld_address_i(ld_address),
//        .st_address_i(st_address),
//        .start_store_i(startStore),
//        .ld_address_change_i(ld_address_change),
//        .driveMemBus_i(driveMemBus),
//        .writeBuf_i(writeBuf),
//        .mem_bus(memBus),
//        .precharged_o(),
//        .clear_writebufV_o()
//    );
//
//    // Test sequence
//    initial begin
//        rst = 0;
//        ld_address = 0;
//        st_address = 0;
//        startStore = 0;
//        ld_address_change = 0;
//        driveMemBus = 0;
//        writeBuf = 0;
//
//        `DELAY_CYCLES(3);
//
//        // Release reset
//        rst = 1;
//
//        `DELAY_CYCLES(10);
//
//        // Example stimulus (you can expand this)
//        //ld_address = 20;
//        //ld_address_change = 1;
//        //`DELAY_CYCLES(1);
//        //ld_address_change = 0;
//
//        //`DELAY_CYCLES(10);
//
//        //st_address = 3;
//        //startStore = 1;
//        //`DELAY_CYCLES(1);
//        //startStore = 0;
//
//        //`DELAY_CYCLES(20);
//
//        $finish;
//    end
//
//endmodule
