import common_pkg::*;
import interconnect_pkg::*;
import mem_common_pkg::*;

`define CLK_PERIOD   (7)
`define DELAY_CYCLES(cycles) #(`CLK_PERIOD * cycles)

module tb_ram ();

    localparam DATA_WIDTH_BITS = 32;
    localparam MEM_CELL_WORD   = 32;

    `CLK_INIT(`CLK_PERIOD);

    // -------------------------------------------------------------------
    // DUT signals
    // -------------------------------------------------------------------
    logic [$clog2(MEM_CELL_WORD) - 1 : 0] address;
    wire  [DATA_WIDTH_BITS - 1 : 0]        memCellBus;
    logic                                   oe, we;
    logic [DATA_WIDTH_BITS - 1 : 0]        writeBuf;

    // -------------------------------------------------------------------
    // Control / SVA support
    // -------------------------------------------------------------------
    logic rst;

    // A dedicated strobe that we pulse HIGH→LOW at an exact clock edge
    // so $fell() fires precisely when we want the SVA to trigger.
    logic sva_trigger;

    // -------------------------------------------------------------------
    // DUT
    // -------------------------------------------------------------------
    sram32x32$ uut0 (
        .A   (address),
        .DIO (memCellBus),
        .OE  (oe),
        .WR  (we),
        .CE  (1'b0)       // always enabled
    );

    // Drive the bus only during writes (we LOW = write)
    assign memCellBus = !we ? writeBuf : 'z;

    // -------------------------------------------------------------------
    // SVA: check_dataBus
    //
    // FIX 1 – use a dedicated sva_trigger instead of oe directly.
    //          We control exactly when $fell fires.
    //
    // FIX 2 – ##10 means 10 clock cycles (100 ns).  t_DOE = 25 ns so
    //          data is stable well before then — this is intentional.
    //          If you want to catch a setup violation reduce the delay.
    //
    // FIX 3 – the expected value must match what is actually in the hex
    //          file at the read address.  Using a wrong value will now
    //          genuinely fail.
    // -------------------------------------------------------------------
    property check_dataBus (
        logic                          trigger,
        logic [DATA_WIDTH_BITS - 1 : 0] expected,
        logic [DATA_WIDTH_BITS - 1 : 0] actual
    );
        @(posedge clk)
        disable iff (rst)
        $fell(trigger) |=> ##3 (actual == expected && !$isunknown(actual));
    endproperty

    // Cover: confirm the antecedent actually fires at least once.
    // If this cover is never hit the assertion was vacuously passing.
    cover property (@(posedge clk) disable iff (rst) $fell(sva_trigger))
        $display("[COVER] sva_trigger fell — SVA antecedent fired at time %0t", $realtime);

    // Assertion: expected value must match mem[8] from your hex file.
    // Replace 32'hDEADBEEF with the real expected value.
    assert property (check_dataBus(sva_trigger, 32'h ff777711, memCellBus))
        else $fatal(1, "[FAIL] check_dataBus SVA failed at time %0t — got %h",
                    $realtime, memCellBus);

    // -------------------------------------------------------------------
    // VCD
    // -------------------------------------------------------------------
    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    // -------------------------------------------------------------------
    // Memory pre-load  (must happen before the read)
    // -------------------------------------------------------------------
    initial begin
        `DELAY_CYCLES(5);
        $readmemh("fakeData/mem0.hex", uut0.mem);
        $display("[INFO] mem[0] = %h", uut0.mem[0]);
        $display("[INFO] mem[8] = %h", uut0.mem[8]);
    end

    // -------------------------------------------------------------------
    // Stimulus
    // -------------------------------------------------------------------
    initial begin
        // ---- reset / idle state ----------------------------------------
        rst        = 1;
        oe         = 1;   // output disabled
        we         = 1;   // write disabled
        address    = 0;
        writeBuf   = 32'h00112233;
        sva_trigger = 1;  // trigger starts HIGH; $fell fires when we drop it

        `DELAY_CYCLES(10);
        rst = 0;

        // ---- set up the read address BEFORE asserting OE ---------------

        // ---- arm the SVA trigger synchronously to a clock edge ---------
        // Drop sva_trigger and oe together so $fell(sva_trigger) is the
        // controlled event that launches the checker.
        @(posedge clk);
        #1;               // tiny delta so assignments are after the edge
        sva_trigger = 0;
        address = 8;   // read address (5 bits for 32-word SRAM)
        oe          = 0;  // enable output — SRAM begins driving memCellBus

        // ---- give the SVA checker enough time to complete --------------
        // After $fell we need >=11 clock edges for ##10 + the check cycle.
        // We also need t_DOE (25 ns = ~3 cycles) for data to appear.
        // 50 cycles is comfortable margin.
        `DELAY_CYCLES(50);

        // ---- de-assert OE, restore trigger for a potential second check -
        @(posedge clk);
        #1;
        oe          = 1;
        sva_trigger = 1;

        `DELAY_CYCLES(10);

        $display("[INFO] Simulation complete");
        $finish;
    end

endmodule
