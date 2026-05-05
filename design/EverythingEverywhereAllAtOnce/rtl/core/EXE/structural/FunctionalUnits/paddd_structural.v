// Structural Verilog 2005 port of EXE/FunctionalUnits/paddd.sv
// 2 lanes of 32-bit wrap-around add

module paddd (
    input  wire [63:0] srA,
    input  wire [63:0] srB,
    output wire [63:0] dr_o
);

    wire [31:0] r0, r1;
    wire        c0, c1;

    `ADD_N(u_add0, 32, r0, c0, srA[31:0],  srB[31:0],  1'b0)
    `ADD_N(u_add1, 32, r1, c1, srA[63:32], srB[63:32], 1'b0)

    assign dr_o = {r1, r0};

endmodule
