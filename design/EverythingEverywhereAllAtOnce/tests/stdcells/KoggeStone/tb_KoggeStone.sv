import common_pkg::*;

module tb_KoggeStone ();
    localparam int Clk_PERIOD = 100;
    localparam int KS_WIDTH = 16;

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


    kogge_stone_adder  uut_KS #(
        .WIDTH(KS_WIDTH)
    ) (
        .a(a_i),
        .b(b_i),
        .cin(cin_i),
        .sum(sum_o),
        .cout(cout_o)
    );


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
        a_i = 2500;
        b_i = 2345;

        DelayClks(20);

        //correctness testcase
         //correctness testcase

        logic [KS_WIDTH:0] expected;
        for (int i = 0; i < 1000; i++) begin
            a_i   = $urandom_range(0, 2**KS_WIDTH - 1);
            b_i   = $urandom_range(0, 2**KS_WIDTH - 1);
            cin_i = $urandom_range(0, 1);

            @(posedge clk); // wait for outputs to settle

            expected = a_i + b_i + cin_i;

            if ({cout_o, sum_o} !== expected) begin
                $error("Mismatch! a=%0d b=%0d cin=%0d | sum=%0d cout=%0d | expected=%0d",
                        a_i, b_i, cin_i, sum_o, cout_o, expected);
            end
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
