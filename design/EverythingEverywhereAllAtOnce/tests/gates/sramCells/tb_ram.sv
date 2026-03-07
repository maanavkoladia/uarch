//`include "../../Common/LOG.v"
//`include "../../Common/utils.v"

module tb_ram();

    // Parameters
    localparam int clk_period = 10;
    localparam int num_words = 8;
    localparam int num_words_bits = $clog2(num_words);
    localparam int DATA_WIDTH = 8;

    // Clock
    //logic clk = 0;
    //always #(clk_period / 2) clk = ~clk;


    // RAM signals
    logic [num_words_bits-1:0] address;
    logic [DATA_WIDTH-1:0] data_in;
    logic [DATA_WIDTH-1:0] data_out;
    logic oe;
    logic we;

    `CLK_INIT(clk_period);
    `GEN_WAVEFORM_VCD("test.vcd", tb_ram, 2);

    // Instantiate DUT
    ram8b8w$ uut (
        .A(address),
        .DIN(data_in),
        .OE(oe),
        .WR(we),
        .DOUT(data_out)
    );

    // Simulation sequence
    initial begin
        // Initialize signals
        address = 0;
        data_in = 0;
        we = 1;
        oe = 1;

        // Write a single value
        address = 7;
        data_in = 90;
        #10;
        we = 0;  // perform write
        #10;
        we = 1;  // disable write

        // Verify that write succeeded (one-shot check)
        oe = 0;  // enable output
        #15;  // wait for output to stabilize

        `ERR_CHECK(data_out == 90, "Single R/W", "Failed first write");

        oe = 1;  // disable output

        // Write multiple values into RAM
        for (int i = 0; i < num_words; i++) begin
            we = 1;
            address = i;
            data_in = i * 10;
            #20;
            we = 0;
            #20;
        end

        we = 1;
        #100;

        // Read and verify multiple values
        for (int i = 0; i < num_words; i++) begin
            oe = 1;
            address = i;
            oe = 0;
            #20;
            `ERR_CHECK(data_out == i * 10, "Multi R/W", "not correct");

        end

        $display("Passed all test cases");
        #100;
        $display("Simulation finished.");
        $finish;
    end
endmodule
