// Structural Verilog 2005 port of EXE/FunctionalUnits/pavgb.sv
// Per byte: result = (a + b + 1) >> 1   (rounded average)
// Implemented as a 9-bit add with cin=1; output is bits [8:1] of each sum.

module pavgb (
    input  wire [63:0] srA,
    input  wire [63:0] srB,
    output wire [63:0] dr_o
);

    wire [8:0] s0, s1, s2, s3, s4, s5, s6, s7;
    wire       c0, c1, c2, c3, c4, c5, c6, c7;

    `ADD_N(u_add0, 9, s0, c0, {1'b0, srA[7:0]},   {1'b0, srB[7:0]},   1'b1)
    `ADD_N(u_add1, 9, s1, c1, {1'b0, srA[15:8]},  {1'b0, srB[15:8]},  1'b1)
    `ADD_N(u_add2, 9, s2, c2, {1'b0, srA[23:16]}, {1'b0, srB[23:16]}, 1'b1)
    `ADD_N(u_add3, 9, s3, c3, {1'b0, srA[31:24]}, {1'b0, srB[31:24]}, 1'b1)
    `ADD_N(u_add4, 9, s4, c4, {1'b0, srA[39:32]}, {1'b0, srB[39:32]}, 1'b1)
    `ADD_N(u_add5, 9, s5, c5, {1'b0, srA[47:40]}, {1'b0, srB[47:40]}, 1'b1)
    `ADD_N(u_add6, 9, s6, c6, {1'b0, srA[55:48]}, {1'b0, srB[55:48]}, 1'b1)
    `ADD_N(u_add7, 9, s7, c7, {1'b0, srA[63:56]}, {1'b0, srB[63:56]}, 1'b1)

    assign dr_o = {
        s7[8:1], s6[8:1], s5[8:1], s4[8:1],
        s3[8:1], s2[8:1], s1[8:1], s0[8:1]
    };

endmodule
