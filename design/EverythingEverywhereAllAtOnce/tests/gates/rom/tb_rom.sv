`timescale 1ns / 1ps

module tb_rom ();

    localparam int Clk_PERIOD = 10;

    task automatic DelayClks(input int cycles);
        #(Clk_PERIOD * cycles);
    endtask

    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    `CLK_INIT(Clk_PERIOD);
    logic [4 : 0] addr;
    logic OE;
    logic [63 : 0] dout;

     rom64b32w$ uut0 (
         .A(addr),
         .OE(OE),
         .DOUT(dout)
     );

    // read in mem
    initial begin
        $readmemh("fakeData.hex", tb_rom.uut0.mem,);
    end

    initial begin
        `LOG("Starting ROM tb");
        addr = 6;
        OE = 0;

        DelayClks(3);
        @(posedge clk);
        OE = 1;
        @(posedge clk);
        OE = 0;
        DelayClks(30);
        `LOG("Done with ROM tb");
        $finish;
    end
    // Test signals

endmodule
