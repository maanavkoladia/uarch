
/* ---------------- nand2_N ---------------- */
module nand2_N$ #(
    parameter WIDTH = 1
) (
    output wire [WIDTH-1:0] out,
    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1
);

    generate
        genvar i;
        for (i = 0; i < WIDTH; i = i + 1) begin : g_nand_N
            nand2$ u0 (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i])
            );
        end
    endgenerate

endmodule

/* ---------------- nand3_N ---------------- */
module nand3_N$ #(
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
            nand3$ u0 (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .in2(in2[i])
            );
        end
    endgenerate
endmodule

/* ---------------- and4_N ---------------- */
module nand4_N$ #(
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
            nand4$ u (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .in2(in2[i]),
                .in3(in3[i])
            );
        end
    endgenerate
endmodule

/* ---------------- nor2_N ---------------- */
module nor2_N$ #(
    parameter WIDTH = 1
) (
    output wire [WIDTH-1:0] out,
    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1
);

    generate
        genvar i;
        for (i = 0; i < WIDTH; i = i + 1) begin : g_nor_n
            nor2$ u0 (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i])
            );
        end
    endgenerate

endmodule

/* ---------------- nor3_N ---------------- */
module nor3_N$ #(
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
            nor3$ u0 (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .in2(in2[i])
            );
        end
    endgenerate
endmodule


/* ---------------- nor4_N ---------------- */
module nor4_N$ #(
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
            nor4$ u (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .in2(in2[i]),
                .in3(in3[i])
            );
        end
    endgenerate
endmodule
