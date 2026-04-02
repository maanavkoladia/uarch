module packssdw (
    input  uint64_t srA,
    input  uint64_t srB,
    output uint64_t dr_o
);

    // Extract 32-bit signed lanes
    logic signed [31:0] a0, a1;
    logic signed [31:0] b0, b1;

    assign a0 = srA[31:0];
    assign a1 = srA[63:32];

    assign b0 = srB[31:0];
    assign b1 = srB[63:32];

    // Saturated outputs
    logic [15:0] r0, r1, r2, r3;

    // ---- A lanes ----
    assign r0 = (a0 > 32'sd32767)   ? 16'sd32767  :
                (a0 < -32'sd32768)  ? -16'sd32768 :
                                      a0[15:0];

    assign r1 = (a1 > 32'sd32767)   ? 16'sd32767  :
                (a1 < -32'sd32768)  ? -16'sd32768 :
                                      a1[15:0];

    // ---- B lanes ----
    assign r2 = (b0 > 32'sd32767)   ? 16'sd32767  :
                (b0 < -32'sd32768)  ? -16'sd32768 :
                                      b0[15:0];

    assign r3 = (b1 > 32'sd32767)   ? 16'sd32767  :
                (b1 < -32'sd32768)  ? -16'sd32768 :
                                      b1[15:0];

    // Pack result
    assign dr_o = {
        r3, r2, r1, r0
    };

endmodule