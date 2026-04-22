module tb_Dec();
    // Testbench signals
    reg clk;
    reg rst; // active low
    reg [63:0][7:0] queue;

    wire [31:0] EIP;
    wire [3:0] inst_length;

    // Instantiate DUT
    predecode dut (
        .queue(queue),
        .clk(clk),
        .rst(rst),
        .EIP(EIP),
        .inst_length(inst_length)
    );

    // Clock generation (50ns period)
    initial begin
        clk = 0;
        forever #25 clk = ~clk; // 25ns high, 25ns low
    end

    // Reset sequence
    initial begin
        rst = 0;   // assert reset (active low)
        #100;
        rst = 1;   // deassert reset
    end

    // Queue initialization placeholder

    initial
        begin
            //$dumpfile ("d_latch.dump");
            //$dumpvars (0, TOP);
            $vcdplusfile("tb_dec.vpd");
            $vcdpluson(0, tb_Dec); 
		#1000;
		$finish;
        end // initial begin

    //`GEN_WAVEFORM_VCD("test.vcd", tb_ram, 2);
endmodule
