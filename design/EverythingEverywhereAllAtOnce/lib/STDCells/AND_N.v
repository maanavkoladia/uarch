/* ============================================================
 * Parameterized Multi-Input AND Modules (Bitwise)
 * ============================================================
 *
 * Description:
 * These modules implement bitwise N-input AND operations using
 * the corresponding MPS_AND_INX gate-level cells.
 *
 * Each module is parameterized by WIDTH and performs:
 *     out[i] = AND of all inputs at bit i
 *
 * for i in [0, WIDTH-1]
 *
 * ------------------------------------------------------------
 * Modules:
 *
 * and2_N$  (out, in0, in1)
 * and3_N$  (out, in0, in1, in2)
 * and4_N$  (out, in0, in1, in2, in3)
 * and5_N$  (out, in0, in1, in2, in3, in4)
 * and6_N$  (out, in0, in1, in2, in3, in4, in5)
 * and7_N$  (out, in0, in1, in2, in3, in4, in5, in6)
 * and8_N$  (out, in0, in1, in2, in3, in4, in5, in6, in7)
 * and9_N$  (out, in0, in1, in2, in3, in4, in5, in6, in7, in8)
 * and10_N$ (out, in0, in1, in2, in3, in4, in5, in6, in7, in8, in9)
 * and11_N$ (out, in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10)
 * and12_N$ (out, in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11)
 *
 * ------------------------------------------------------------
 * Notes:
 * - WIDTH defaults to 1 (scalar behavior)
 * - Uses generate loops for scalable bitwise replication
 * - Internally maps to MPS_AND_INX standard cells
 *
 * ============================================================
 */

/* ---------------- and2_N ---------------- */
module and2_N$ #(
    parameter WIDTH = 1
) (
    output wire [WIDTH-1:0] out,
    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1
);

    generate
        genvar i;
        for (i = 0; i < WIDTH; i = i + 1) begin : g_and_N
            MPS_AND_IN2 u0 (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i])
            );
        end
    endgenerate

endmodule

/* ---------------- and3_N ---------------- */
module and3_N$ #(
    parameter WIDTH = 1
) (
    output wire [WIDTH-1:0] out,
    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1,
    input  wire [WIDTH-1:0] in2
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : g
            MPS_AND_IN3 u (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .in2(in2[i])
            );
        end
    endgenerate
endmodule

/* ---------------- and4_N ---------------- */
module and4_N$ #(
    parameter WIDTH = 1
) (
    output wire [WIDTH-1:0] out,
    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1,
    input  wire [WIDTH-1:0] in2,
    input  wire [WIDTH-1:0] in3
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : g
            MPS_AND_IN4 u (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .in2(in2[i]),
                .in3(in3[i])
            );
        end
    endgenerate
endmodule

/* ---------------- and5_N ---------------- */
module and5_N$ #(
    parameter WIDTH = 1
) (
    output wire [WIDTH-1:0] out,
    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1,
    input  wire [WIDTH-1:0] in2,
    input  wire [WIDTH-1:0] in3,
    input  wire [WIDTH-1:0] in4
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : g
            MPS_AND_IN5$ u (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .in2(in2[i]),
                .in3(in3[i]),
                .in4(in4[i])
            );
        end
    endgenerate
endmodule

/* ---------------- and6_N ---------------- */
module and6_N$ #(
    parameter WIDTH = 1
) (
    output wire [WIDTH-1:0] out,
    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1,
    input  wire [WIDTH-1:0] in2,
    input  wire [WIDTH-1:0] in3,
    input  wire [WIDTH-1:0] in4,
    input  wire [WIDTH-1:0] in5
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : g
            MPS_AND_IN6$ u (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .in2(in2[i]),
                .in3(in3[i]),
                .in4(in4[i]),
                .in5(in5[i])
            );
        end
    endgenerate
endmodule

/* ---------------- and7_N ---------------- */
module and7_N$ #(
    parameter WIDTH = 1
) (
    output wire [WIDTH-1:0] out,
    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1,
    input  wire [WIDTH-1:0] in2,
    input  wire [WIDTH-1:0] in3,
    input  wire [WIDTH-1:0] in4,
    input  wire [WIDTH-1:0] in5,
    input  wire [WIDTH-1:0] in6
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : g
            MPS_AND_IN7$ u (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .in2(in2[i]),
                .in3(in3[i]),
                .in4(in4[i]),
                .in5(in5[i]),
                .in6(in6[i])
            );
        end
    endgenerate
endmodule

/* ---------------- and8_N ---------------- */
module and8_N$ #(
    parameter WIDTH = 1
) (
    output wire [WIDTH-1:0] out,
    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1,
    input  wire [WIDTH-1:0] in2,
    input  wire [WIDTH-1:0] in3,
    input  wire [WIDTH-1:0] in4,
    input  wire [WIDTH-1:0] in5,
    input  wire [WIDTH-1:0] in6,
    input  wire [WIDTH-1:0] in7
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : g
            MPS_AND_IN8$ u (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .in2(in2[i]),
                .in3(in3[i]),
                .in4(in4[i]),
                .in5(in5[i]),
                .in6(in6[i]),
                .in7(in7[i])
            );
        end
    endgenerate
endmodule

/* ---------------- and9_N ---------------- */
module and9_N$ #(
    parameter WIDTH = 1
) (
    output wire [WIDTH-1:0] out,
    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1,
    input  wire [WIDTH-1:0] in2,
    input  wire [WIDTH-1:0] in3,
    input  wire [WIDTH-1:0] in4,
    input  wire [WIDTH-1:0] in5,
    input  wire [WIDTH-1:0] in6,
    input  wire [WIDTH-1:0] in7,
    input  wire [WIDTH-1:0] in8
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : g
            MPS_AND_IN9$ u (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .in2(in2[i]),
                .in3(in3[i]),
                .in4(in4[i]),
                .in5(in5[i]),
                .in6(in6[i]),
                .in7(in7[i]),
                .in8(in8[i])
            );
        end
    endgenerate
endmodule

/* ---------------- and10_N ---------------- */
module and10_N$ #(
    parameter WIDTH = 1
) (
    output wire [WIDTH-1:0] out,
    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1,
    input  wire [WIDTH-1:0] in2,
    input  wire [WIDTH-1:0] in3,
    input  wire [WIDTH-1:0] in4,
    input  wire [WIDTH-1:0] in5,
    input  wire [WIDTH-1:0] in6,
    input  wire [WIDTH-1:0] in7,
    input  wire [WIDTH-1:0] in8,
    input  wire [WIDTH-1:0] in9
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : g
            MPS_AND_IN10$ u (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .in2(in2[i]),
                .in3(in3[i]),
                .in4(in4[i]),
                .in5(in5[i]),
                .in6(in6[i]),
                .in7(in7[i]),
                .in8(in8[i]),
                .in9(in9[i])
            );
        end
    endgenerate
endmodule

/* ---------------- and11_N ---------------- */
module and11_N$ #(
    parameter WIDTH = 1
) (
    output wire [WIDTH-1:0] out,
    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1,
    input  wire [WIDTH-1:0] in2,
    input  wire [WIDTH-1:0] in3,
    input  wire [WIDTH-1:0] in4,
    input  wire [WIDTH-1:0] in5,
    input  wire [WIDTH-1:0] in6,
    input  wire [WIDTH-1:0] in7,
    input  wire [WIDTH-1:0] in8,
    input  wire [WIDTH-1:0] in9,
    input  wire [WIDTH-1:0] in10
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : g
            MPS_AND_IN11$ u (
                .out (out[i]),
                .in0 (in0[i]),
                .in1 (in1[i]),
                .in2 (in2[i]),
                .in3 (in3[i]),
                .in4 (in4[i]),
                .in5 (in5[i]),
                .in6 (in6[i]),
                .in7 (in7[i]),
                .in8 (in8[i]),
                .in9 (in9[i]),
                .in10(in10[i])
            );
        end
    endgenerate
endmodule

/* ---------------- and12_N ---------------- */
module and12_N$ #(
    parameter WIDTH = 1
) (
    output wire [WIDTH-1:0] out,
    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1,
    input  wire [WIDTH-1:0] in2,
    input  wire [WIDTH-1:0] in3,
    input  wire [WIDTH-1:0] in4,
    input  wire [WIDTH-1:0] in5,
    input  wire [WIDTH-1:0] in6,
    input  wire [WIDTH-1:0] in7,
    input  wire [WIDTH-1:0] in8,
    input  wire [WIDTH-1:0] in9,
    input  wire [WIDTH-1:0] in10,
    input  wire [WIDTH-1:0] in11
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : g
            MPS_AND_IN12$ u (
                .out (out[i]),
                .in0 (in0[i]),
                .in1 (in1[i]),
                .in2 (in2[i]),
                .in3 (in3[i]),
                .in4 (in4[i]),
                .in5 (in5[i]),
                .in6 (in6[i]),
                .in7 (in7[i]),
                .in8 (in8[i]),
                .in9 (in9[i]),
                .in10(in10[i]),
                .in11(in11[i])
            );
        end
    endgenerate
endmodule
