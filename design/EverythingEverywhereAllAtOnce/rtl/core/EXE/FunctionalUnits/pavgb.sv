module pavgb (
    input  logic [63:0] srA,
    input  logic [63:0] srB,
    output logic [63:0] dr_o
);

    // Extract bytes
    logic [7:0] a0,a1,a2,a3,a4,a5,a6,a7;
    logic [7:0] b0,b1,b2,b3,b4,b5,b6,b7;

    assign a0 = srA[7:0];
    assign a1 = srA[15:8];
    assign a2 = srA[23:16];
    assign a3 = srA[31:24];
    assign a4 = srA[39:32];
    assign a5 = srA[47:40];
    assign a6 = srA[55:48];
    assign a7 = srA[63:56];

    assign b0 = srB[7:0];
    assign b1 = srB[15:8];
    assign b2 = srB[23:16];
    assign b3 = srB[31:24];
    assign b4 = srB[39:32];
    assign b5 = srB[47:40];
    assign b6 = srB[55:48];
    assign b7 = srB[63:56];

    // 9-bit sums (to avoid overflow)
    logic [8:0] s0,s1,s2,s3,s4,s5,s6,s7;

    assign s0 = a0 + b0 + 1;
    assign s1 = a1 + b1 + 1;
    assign s2 = a2 + b2 + 1;
    assign s3 = a3 + b3 + 1;
    assign s4 = a4 + b4 + 1;
    assign s5 = a5 + b5 + 1;
    assign s6 = a6 + b6 + 1;
    assign s7 = a7 + b7 + 1;

    // Divide by 2 (shift right)
    logic [7:0] r0,r1,r2,r3,r4,r5,r6,r7;

    assign r0 = s0[8:1];
    assign r1 = s1[8:1];
    assign r2 = s2[8:1];
    assign r3 = s3[8:1];
    assign r4 = s4[8:1];
    assign r5 = s5[8:1];
    assign r6 = s6[8:1];
    assign r7 = s7[8:1];

    // Pack result
    assign dr_o = {
        r7, r6, r5, r4,
        r3, r2, r1, r0
    };

endmodule