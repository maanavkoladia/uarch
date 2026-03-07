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
    initial begin
        // Initialize queue here
        // Example:
        queue[0]  = 8'h03; queue[1]  = 8'hC1; // add eax, ecx
        queue[2]  = 8'h03; queue[3]  = 8'hC8; // add ecx, eax
        queue[4]  = 8'h03; queue[5]  = 8'hD3; // add edx, ebx
        queue[6]  = 8'h03; queue[7]  = 8'hDA; // add ebx, edx
        queue[8]  = 8'h03; queue[9]  = 8'hC2; // add eax, edx
        queue[10] = 8'h03; queue[11] = 8'hCB; // add ecx, ebx
        queue[12] = 8'h01; queue[13] = 8'hD8; // add eax, ebx
        queue[14] = 8'h01; queue[15] = 8'hCA; // add edx, ecx


    end
endmodule
