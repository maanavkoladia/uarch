module tb_sramcell;

    reg  [4:0]  A;
    reg  [31:0] DIO_reg;
    reg         OE, WR, CE;
    wire [31:0] DIO;

    // Drive DIO only during writes
    assign DIO = (!WR && !CE) ? DIO_reg : 32'bz;

    sram32x32$ uut (
        .A   (A),
        .DIO (DIO),
        .OE  (OE),
        .WR  (WR),
        .CE  (CE)
    );

    // 75 ns cycle clock (t_RC = 75)
    reg clk = 0;
    always #37.5 clk = ~clk;

    reg [31:0] rdata;
    integer i;

    initial begin
        $vcdplusfile("tb_sramcell.vpd");
        $vcdpluson(0, tb_sramcell);

        // Init signals
        A = 0; DIO_reg = 0;
        WR = 1; OE = 1; CE = 1;
        #100;

        // --- Write phase ---
        $display("=== Write Phase ===");
        for (i = 0; i < 32; i = i + 1)
            write_word(i[4:0], i * 32'hDEAD_0001);

        #50;

        // --- Read phase & verify ---
        $display("=== Read Phase ===");
        for (i = 0; i < 32; i = i + 1) begin
            read_word(i[4:0], rdata);
            if (rdata === i * 32'hDEAD_0001)
                $display("PASS addr=%0d  data=0x%08h", i, rdata);
            else
                $display("FAIL addr=%0d  expected=0x%08h  got=0x%08h",
                          i, i * 32'hDEAD_0001, rdata);
        end

        // --- Read while WR low (should warn) ---
        $display("=== Address-change-during-write warning test ===");
        CE = 0; WR = 0; OE = 1;
        A = 5'h01;  DIO_reg = 32'hAAAA_BBBB;
        #30;
        A = 5'h02;  // triggers $display warning in DUT
        #30;
        WR = 1; CE = 1;

        #200;
        $display("=== Done ===");
        $finish;
    end

        task write_word;
        input [4:0]  addr;
        input [31:0] data;
        begin
            @(posedge clk);
            A       = addr;
            DIO_reg = data;
            CE      = 0;
            OE      = 1;
            #25;        // t_AW / t_SD address+data setup
            WR      = 0;
            #30;        // t_PWE = 25, stay low a bit longer
            WR      = 1;
            #10;        // hold
            CE      = 1;
        end
    endtask

    task read_word;
        input  [4:0]  addr;
        output [31:0] data;
        begin
            @(posedge clk);
            A   = addr;
            CE  = 0;
            OE  = 0;
            WR  = 1;
            #120;       // t_ACE = 70 + t_DOE = 25 => ~120 ns total
            data = DIO;
            CE  = 1;
            OE  = 1;
            #10;
        end
    endtask

endmodule