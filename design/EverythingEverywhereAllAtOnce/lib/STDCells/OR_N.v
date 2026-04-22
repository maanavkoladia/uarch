/* ---------------- or2_N$ ---------------- */
module or2_N$ #(
    parameter WIDTH = 1
) (
    output wire [WIDTH-1:0] out,
    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1
);

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : g_or2
            MPS_OR_IN2$ u0 (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i])
            );
        end
    endgenerate

endmodule


/* ---------------- or3_N$ ---------------- */
module or3_N$ #(
    parameter WIDTH = 1
) (
    output wire [WIDTH-1:0] out,
    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1,
    input  wire [WIDTH-1:0] in2
);

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : g_or3
            MPS_OR_IN3$ u0 (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .in2(in2[i])
            );
        end
    endgenerate

endmodule


/* ---------------- or4_N$ ---------------- */
module or4_N$ #(
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
        for (i = 0; i < WIDTH; i = i + 1) begin : g_or4
            MPS_OR_IN4$ u0 (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .in2(in2[i]),
                .in3(in3[i])
            );
        end
    endgenerate

endmodule

/* ---------------- or5_N$ ---------------- */
module or5_N$ #(
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
        for (i = 0; i < WIDTH; i = i + 1) begin : g_or5
            MPS_OR_IN5$ u0 (
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


/* ---------------- or6_N$ ---------------- */
module or6_N$ #(
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
        for (i = 0; i < WIDTH; i = i + 1) begin : g_or6
            MPS_OR_IN6$ u0 (
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


/* ---------------- or7_N$ ---------------- */
module or7_N$ #(
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
        for (i = 0; i < WIDTH; i = i + 1) begin : g_or7
            MPS_OR_IN7$ u0 (
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


/* ---------------- or8_N$ ---------------- */
module or8_N$ #(
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
        for (i = 0; i < WIDTH; i = i + 1) begin : g_or8
            MPS_OR_IN8$ u0 (
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


/* ---------------- or9_N$ ---------------- */
module or9_N$ #(
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
        for (i = 0; i < WIDTH; i = i + 1) begin : g_or9
            MPS_OR_IN9$ u0 (
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


/* ---------------- or10_N$ ---------------- */
module or10_N$ #(
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
        for (i = 0; i < WIDTH; i = i + 1) begin : g_or10
            MPS_OR_IN10$ u0 (
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


/* ---------------- or11_N$ ---------------- */
module or11_N$ #(
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
        for (i = 0; i < WIDTH; i = i + 1) begin : g_or11
            MPS_OR_IN11$ u0 (
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
                .in9(in9[i]),
                .in10(in10[i])
            );
        end
    endgenerate

endmodule


/* ---------------- or12_N$ ---------------- */
module or12_N$ #(
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
        for (i = 0; i < WIDTH; i = i + 1) begin : g_or12
            MPS_OR_IN12$ u0 (
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
                .in9(in9[i]),
                .in10(in10[i]),
                .in11(in11[i])
            );
        end
    endgenerate

endmodule


