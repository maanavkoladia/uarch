import common_pkg::*;
import interconnect_pkg::*;
import mem_common_pkg::*;

`define CLK_PERIOD (100)
`define DELAY_CYCLES(cycles) #(`CLK_PERIOD  * cycles)

module tb_ram ();

    localparam DATA_WIDTH_BITS = 32;
    localparam MEM_CELL_WORD = 32;
    `CLK_INIT(`CLK_PERIOD);

    logic [$clog2(MEM_CELL_WORD) - 1 : 0] address;
    wire [DATA_WIDTH_BITS - 1 : 0] memCellBus;
    logic oe, we;

    assign memCellBus = 'z;

    sram32x32$ uut0 (
        .A(address),
        .DIO(memCellBus),
        .OE(oe),
        .WR(we),
        .CE(1'b0)  //always on
    );

    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    initial begin
        oe = 1;
        we = 1;
        address = 0;

        `DELAY_CYCLES(30);
        $finish;
    end

    initial begin
        `DELAY_CYCLES(5);
        $readmemh("fakeData/mem0.hex", uut0.mem);
    end

    initial begin
        `DELAY_CYCLES(7);
        $display("mem[0] = %h", uut0.mem[0]);
    end

endmodule
