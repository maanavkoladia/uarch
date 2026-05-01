
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
