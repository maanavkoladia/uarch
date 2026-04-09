`timescale 1ns / 1ps

module tb_rom ();

    localparam int Clk_PERIOD = 11;

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

    // read in mem
    initial begin
        readmemh("tb_rom.uut0.mem",uut0);
    end

    initial begin
        `LOG("Starting ROM tb");

     rom64b32w$ uut0 (
         .A(addr),
         .OE(OE),
         .DOUT(dout)
     );

        DelayClks(30);
        `LOG("Done with ROM tb");
    end
    // Test signals

endmodule
