module packsswb (
    input  uint64_t srA,
    input  uint64_t srB,
    output uint64_t dr_o
);

    // Extract 16-bit signed lanes
    logic signed [15:0] a0, a1, a2, a3;
    logic signed [15:0] b0, b1, b2, b3;

    assign a0 = srA[15:0];
    assign a1 = srA[31:16];
    assign a2 = srA[47:32];
    assign a3 = srA[63:48];

    assign b0 = srB[15:0];
    assign b1 = srB[31:16];
    assign b2 = srB[47:32];
    assign b3 = srB[63:48];

    // Saturated outputs
    logic [7:0] r0, r1, r2, r3, r4, r5, r6, r7;

    // ---- A lanes ----
    assign r0 = (a0 > 16'sd127)  ? 8'h7F  :
                (a0 < -16'sd128) ? 8'h80 :
                                   a0[7:0];

    assign r1 = (a1 > 16'sd127)  ? 8'h7F  :
                (a1 < -16'sd128) ? 8'h80 :
                                   a1[7:0];

    assign r2 = (a2 > 16'sd127)  ? 8'h7F  :
                (a2 < -16'sd128) ? 8'h80 :
                                   a2[7:0];

    assign r3 = (a3 > 16'sd127)  ? 8'h7F  :
                (a3 < -16'sd128) ? 8'h80 :
                                   a3[7:0];

    // ---- B lanes ----
    assign r4 = (b0 > 16'sd127)  ? 8'h7F  :
                (b0 < -16'sd128) ? 8'h80 :
                                   b0[7:0];

    assign r5 = (b1 > 16'sd127)  ? 8'h7F  :
                (b1 < -16'sd128) ? 8'h80 :
                                   b1[7:0];

    assign r6 = (b2 > 16'sd127)  ? 8'h7F  :
                (b2 < -16'sd128) ? 8'h80 :
                                   b2[7:0];

    assign r7 = (b3 > 16'sd127)  ? 8'h7F  :
                (b3 < -16'sd128) ? 8'h80 :
                                   b3[7:0];

    // Pack result
    assign dr_o = {
        r7, r6, r5, r4,
        r3, r2, r1, r0
    };

endmodule