// Structural Verilog 2005 port of EXE/FunctionalUnits/paddw.sv
// 4 lanes of 16-bit wrap-around add: dr_o[i*16+:16] = srA[i*16+:16] + srB[i*16+:16]

module paddw (
    input  wire [63:0] srA,
    input  wire [63:0] srB,
    output wire [63:0] dr_o
);

    wire [15:0] r0, r1, r2, r3;
    wire        c0, c1, c2, c3;

    `ADD_N(u_add0, 16, r0, c0, srA[15:0],  srB[15:0],  1'b0)
    `ADD_N(u_add1, 16, r1, c1, srA[31:16], srB[31:16], 1'b0)
    `ADD_N(u_add2, 16, r2, c2, srA[47:32], srB[47:32], 1'b0)
    `ADD_N(u_add3, 16, r3, c3, srA[63:48], srB[63:48], 1'b0)

    assign dr_o = {r3, r2, r1, r0};

endmodule
