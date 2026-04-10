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
uut0.mem[0]  = 64'h00000000;
uut0.mem[1]  = 64'h11111111;
uut0.mem[2]  = 64'h22222222;
uut0.mem[3]  = 64'h33333333;
uut0.mem[4]  = 64'h44444444;
uut0.mem[5]  = 64'h55555555;
uut0.mem[6]  = 64'h66666666;
uut0.mem[7]  = 64'h77777777;
uut0.mem[8]  = 64'h88888888;
uut0.mem[9]  = 64'h99999999;
uut0.mem[10] = 64'hAAAAAAAA;
uut0.mem[11] = 64'hBBBBBBBB;
uut0.mem[12] = 64'hCCCCCCCC;
uut0.mem[13] = 64'hDDDDDDDD;
uut0.mem[14] = 64'hEEEEEEEE;
uut0.mem[15] = 64'hFFFFFFFF;
uut0.mem[16] = 64'h00000000;
uut0.mem[17] = 64'h11111111;
uut0.mem[18] = 64'h22222222;
uut0.mem[19] = 64'h33333333;
uut0.mem[20] = 64'h44444444;
uut0.mem[21] = 64'h55555555;
uut0.mem[22] = 64'h66666666;
uut0.mem[23] = 64'h77777777;
uut0.mem[24] = 64'h88888888;
uut0.mem[25] = 64'h99999999;
uut0.mem[26] = 64'hAAAAAAAA;
uut0.mem[27] = 64'hBBBBBBBB;
uut0.mem[28] = 64'hCCCCCCCC;
uut0.mem[29] = 64'hDDDDDDDD;
uut0.mem[30] = 64'hEEEEEEEE;
uut0.mem[31] = 64'hFFFFFFFF;
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
