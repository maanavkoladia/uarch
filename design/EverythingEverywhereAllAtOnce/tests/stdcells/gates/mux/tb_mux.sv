module tb_mux();
    localparam int CLK_PERIOD = 10;

    `CLK_INIT(CLK_PERIOD);

    initial begin
        $vcdplusfile("test.vpd");
        $vcdpluson(1, tb_mux);
    end

    logic [15:0] A = 10;
    logic [15:0] B = 5 ;
    logic [15:0] Out;
    logic sel = 0;

    mux2_16$ uut(
        .Y(Out),
        .IN0(A),
        .IN1(B),
        .S0(sel)
    );

    initial begin
        // Drive all inputs to known state FIRST
        // WR=1 (deasserted), OE=1 (output disabled) is the safe idle state
        `LOG("Sim Starting Up");
        sel = 0;
        #100;

        sel = 1;
        #100;

        sel = 0;
        #100

        `LOG("Simulation finished.");
        $finish;
    end
endmodule
