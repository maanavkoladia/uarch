module reg1b (
    input wire clk,
    input wire rst,  //active low

    input wire d,

    output wire q

);
    dff$ ff0 (
        .clk(clk),
        .d(d),
        .q(q),
        .r(rst),
        .s(1'b1),
        .qbar()  //not needed, probably
    );

endmodule
