// Structural Verilog 2005 port of EXE/FunctionalUnits/rep_cmp.sv
// ZF = (srA[31:0] == srB[31:0])

module rep_cmp (
    input  wire [63:0] srA,
    input  wire [63:0] srB,
    output wire        ZF
);

    `CMP_N(u_cmp, 32, ZF, srA[31:0], srB[31:0])

endmodule
