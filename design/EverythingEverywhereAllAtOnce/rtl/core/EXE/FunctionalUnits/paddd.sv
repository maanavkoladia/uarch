module paddd (
    input  uint64_t srA,
    input  uint64_t srB,
    output uint64_t dr_o
);

    // Extract 32-bit lanes
    logic [31:0] a0, a1;
    logic [31:0] b0, b1;

    assign a0 = srA[31:0];
    assign a1 = srA[63:32];

    assign b0 = srB[31:0];
    assign b1 = srB[63:32];

    // Lane-wise addition (wrap-around)
    logic [31:0] r0, r1;

    assign r0 = a0 + b0;
    assign r1 = a1 + b1;

    // Pack result
    assign dr_o = {
        r1, r0
    };

endmodule