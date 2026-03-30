import common_pkg::*;

module tb_KoggeStone ();
    localparam int Clk_PERIOD = 100;
    localparam int KS_WIDTH = 32;

    `CLK_INIT(Clk_PERIOD);

    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    task automatic DelayClks(input int cycles);
        #(Clk_PERIOD * cycles);
    endtask

    // ================= CLOCK / RESET =================

    logic rst;

    logic [KS_WIDTH - 1 : 0] a_i;
    logic [KS_WIDTH - 1 : 0] b_i;
    logic cin_i;
    logic [KS_WIDTH - 1 : 0] sum_o;
    logic cout_o;


<<<<<<< HEAD
    kogge_stone_adder  uut_KS #(
        .WIDTH(KS_WIDTH)
    ) uut_KS (
        .a(a_i),
        .b(b_i),
        .cin(cin_i),
        .sum(sum_o),
        .cout(cout_o)
    );

    logic [KS_WIDTH:0] expected;

    initial begin
        `LOG("Starting mem System TB");
        DelayClks(20);
        //timing test case
        a_i = 0;
        b_i = 0;
        cin_i = 0;

        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        a_i = 32'h11111111;
        b_i = 32'h23232323;
        DelayClks(20);
        `LOG("Expected: 0x%08X, Actual: 0x%08X\n\n", a_i + b_i, sum_o);

        //correctness testcase
         //correctness testcase

        for (int i = 0; i < 1000; i++) begin
            a_i   = i;
            b_i   = i * 10;
            //cin_i = $urandom_range(0, 0);

            @(posedge clk); // wait for outputs to settle

            expected = a_i + b_i + cin_i;

            if ({cout_o, sum_o} !== expected) begin
                $error("Mismatch! a=%0d b=%0d cin=%0d | sum=%0d cout=%0d | expected=%0d",
                        a_i, b_i, cin_i, sum_o, cout_o, expected);
            end
            @(posedge clk); // wait for outputs to settle
        end

        $display("Correctness test completed");

        /////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
        /////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////////////////
        DelayClks(30);
        $finish;
        `LOG("Finishing mem System TB");
    end
endmodule
