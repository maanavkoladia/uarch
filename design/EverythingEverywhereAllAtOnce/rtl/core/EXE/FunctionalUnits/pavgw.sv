module pavgw (
    input  uint64_t srA,
    input  uint64_t srB,
    output uint64_t dr_o
);

    // Extract 16-bit lanes
    logic [15:0] a0, a1, a2, a3;
    logic [15:0] b0, b1, b2, b3;

    assign a0 = srA[15:0];
    assign a1 = srA[31:16];
    assign a2 = srA[47:32];
    assign a3 = srA[63:48];

    assign b0 = srB[15:0];
    assign b1 = srB[31:16];
    assign b2 = srB[47:32];
    assign b3 = srB[63:48];

    // 17-bit sums (avoid overflow)
    logic [16:0] s0, s1, s2, s3;

    assign s0 = a0 + b0 + 1;
    assign s1 = a1 + b1 + 1;
    assign s2 = a2 + b2 + 1;
    assign s3 = a3 + b3 + 1;

    // Divide by 2 (shift right)
    logic [15:0] r0, r1, r2, r3;

    assign r0 = s0[16:1];
    assign r1 = s1[16:1];
    assign r2 = s2[16:1];
    assign r3 = s3[16:1];

    // Pack result
    assign dr_o = {
        r3, r2, r1, r0
    };

endmodule