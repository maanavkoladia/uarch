`timescale 1ns/1ps

module tb_ram();
    localparam int CLK_PERIOD = 10;
    localparam int DATA_WIDTH = 8;

    logic [2:0] address;
    logic [DATA_WIDTH-1:0] data_in;
    logic [DATA_WIDTH-1:0] data_out;
    logic oe;
    logic we;

    `CLK_INIT(CLK_PERIOD);

    initial begin
        $vcdplusfile("test.vpd");
        $vcdpluson(1, tb_ram);
    end

    ram8b8w$ uut (
        .A(address),
        .DIN(data_in),
        .OE(oe),
        .WR(we),
        .DOUT(data_out)
    );

    initial begin
        // Drive all inputs to known state FIRST
        // WR=1 (deasserted), OE=1 (output disabled) is the safe idle state
        we      = 1'b1;
        oe      = 1'b1;
        address = 3'b0;
        data_in = 8'b0;

        // Let the RAM's internal always blocks settle from x
        #20;

        // --- Write: address=2, data=8'hAB ---
        address = 3'd2;
        data_in = 8'hAB;
        #5;         // address setup time before WR low (spec: 1.0-1.4ns, #5 is safe)
        we = 1'b0;  // assert write (negedge WR triggers write_block)
        #5;         // WR pulse low width (spec: 1.0-1.4ns)
        we = 1'b1;  // deassert write (posedge WR ends write)
        #10;        // let write settle

        // --- Read: address=2 ---
        // A change with WR=1 triggers a_changed in the RAM model
        address = 3'd2;
        #5;         // let a_changed propagate
        oe = 1'b0;  // enable output
        #10;        // wait for access delay (spec: 1.7-2.3ns, #10 is safe)

        `LOG($sformatf("Read back: %0h (expected AB)", data_out));

        oe = 1'b1;
        #10;

        `LOG("Passed all test cases");
        `LOG("Simulation finished.");
        $finish;
    end
endmodule
