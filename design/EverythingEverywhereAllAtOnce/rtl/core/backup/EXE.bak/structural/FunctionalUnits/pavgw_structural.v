// Structural Verilog 2005 port of EXE/FunctionalUnits/pavgw.sv
// Per word: result = (a + b + 1) >> 1   (rounded average)
// Implemented as a 17-bit add with cin=1; output is bits [16:1] of each sum.

module pavgw (
    input  wire [63:0] srA,
    input  wire [63:0] srB,
    output wire [63:0] dr_o
);

    wire [16:0] s0, s1, s2, s3;
    wire        c0, c1, c2, c3;

    `ADD_N(u_add0, 17, s0, c0, {1'b0, srA[15:0]},  {1'b0, srB[15:0]},  1'b1)
    `ADD_N(u_add1, 17, s1, c1, {1'b0, srA[31:16]}, {1'b0, srB[31:16]}, 1'b1)
    `ADD_N(u_add2, 17, s2, c2, {1'b0, srA[47:32]}, {1'b0, srB[47:32]}, 1'b1)
    `ADD_N(u_add3, 17, s3, c3, {1'b0, srA[63:48]}, {1'b0, srB[63:48]}, 1'b1)

    assign dr_o = {s3[16:1], s2[16:1], s1[16:1], s0[16:1]};

endmodule
