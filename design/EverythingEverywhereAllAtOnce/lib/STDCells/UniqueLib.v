module inv_N$ #(
    parameter WIDTH = 1
) (
    input  wire [WIDTH-1:0] in,
    output wire [WIDTH-1:0] out
);

    genvar i;

    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : GEN_INV
            inv1$ u_inv (
                .out(out[i]),
                .in (in[i])
            );
        end
    endgenerate

endmodule

module MPS_buffer_delay$ #(
    parameter integer STAGES = 1,
    parameter integer WIDTH  = 1
) (
    input  wire [WIDTH-1:0] in,
    output wire [WIDTH-1:0] out
);

    // chain[stage][bit]
    wire [WIDTH-1:0] chain [0:STAGES];

    // First stage
    assign chain[0] = in;

    genvar s, i;

    // Buffer stages
    generate
        for (s = 0; s < STAGES; s = s + 1) begin : GEN_STAGE
            for (i = 0; i < WIDTH; i = i + 1) begin : GEN_BIT
                buffer$ u_buf (
                    .out(chain[s+1][i]),
                    .in (chain[s][i])
                );
            end
        end
    endgenerate

    // Output
    assign out = chain[STAGES];

endmodule

module MPS_tristateL #(
    parameter WIDTH = 1
) (
    input              enbar,
    input  [WIDTH-1:0] in,
    output [WIDTH-1:0] out
);

    genvar i;

    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_tri
            tristateL$ u_tristate (
                .enbar(enbar),
                .in   (in[i]),
                .out  (out[i])
            );
        end
    endgenerate

endmodule

module MPS_bus_tristate #(
    parameter WIDTH = 1
) (
    input              enbar,
    input  [WIDTH-1:0] in,
    output [WIDTH-1:0] out
);

    genvar i;

    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_tri
            tristate_bus_driver1$ u_tristate (
                .enbar(enbar),
                .in   (in[i]),
                .out  (out[i])
            );
        end
    endgenerate

endmodule

module MPS_COMP_EQ #(
    parameter WIDTH = 1
) (
    input  [WIDTH-1:0] in0,
    input  [WIDTH-1:0] in1,
    output             eq
);

    // ============================================================
    // Step 1: Bitwise XNOR comparison
    // ============================================================
    wire [WIDTH-1:0] bitCmp;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : GEN_XNOR
            xnor2$ u_xnor (
                .out(bitCmp[i]),
                .in0(in0[i]),
                .in1(in1[i])
            );
        end
    endgenerate

    // ============================================================
    // Step 2: Reduction using multi-input AND gates (tree)
    // ============================================================
    // First reduction layer: collapse groups of up to 8
    localparam integer L1 = (WIDTH + 7) / 8;
    wire [L1-1:0] level1;

    generate
        for (i = 0; i < L1; i = i + 1) begin : GEN_L1
            localparam integer BASE = i * 8;
            localparam integer REM  = WIDTH - BASE;

            if (REM >= 8) begin
                and8_N$ u_and (
                    .out(level1[i]),
                    .in0(bitCmp[BASE+0]),
                    .in1(bitCmp[BASE+1]),
                    .in2(bitCmp[BASE+2]),
                    .in3(bitCmp[BASE+3]),
                    .in4(bitCmp[BASE+4]),
                    .in5(bitCmp[BASE+5]),
                    .in6(bitCmp[BASE+6]),
                    .in7(bitCmp[BASE+7])
                );
            end else begin
                case (REM)
                    1: assign level1[i] = bitCmp[BASE+0];
                    2: and2_N$ u_and2 (
                        .out(level1[i]),
                        .in0(bitCmp[BASE+0]),
                        .in1(bitCmp[BASE+1])
                    );
                    3: and3_N$ u_and3 (
                        .out(level1[i]),
                        .in0(bitCmp[BASE+0]),
                        .in1(bitCmp[BASE+1]),
                        .in2(bitCmp[BASE+2])
                    );
                    4: and4_N$ u_and4 (
                        .out(level1[i]),
                        .in0(bitCmp[BASE+0]),
                        .in1(bitCmp[BASE+1]),
                        .in2(bitCmp[BASE+2]),
                        .in3(bitCmp[BASE+3])
                    );
                    5: and5_N$ u_and5 (
                        .out(level1[i]),
                        .in0(bitCmp[BASE+0]),
                        .in1(bitCmp[BASE+1]),
                        .in2(bitCmp[BASE+2]),
                        .in3(bitCmp[BASE+3]),
                        .in4(bitCmp[BASE+4])
                    );
                    6: and6_N$ u_and6 (
                        .out(level1[i]),
                        .in0(bitCmp[BASE+0]),
                        .in1(bitCmp[BASE+1]),
                        .in2(bitCmp[BASE+2]),
                        .in3(bitCmp[BASE+3]),
                        .in4(bitCmp[BASE+4]),
                        .in5(bitCmp[BASE+5])
                    );
                    7: and7_N$ u_and7 (
                        .out(level1[i]),
                        .in0(bitCmp[BASE+0]),
                        .in1(bitCmp[BASE+1]),
                        .in2(bitCmp[BASE+2]),
                        .in3(bitCmp[BASE+3]),
                        .in4(bitCmp[BASE+4]),
                        .in5(bitCmp[BASE+5]),
                        .in6(bitCmp[BASE+6])
                    );
                    default: assign level1[i] = 1'b1;
                endcase
            end
        end
    endgenerate

    // ============================================================
    // Step 3: Final reduction (if needed)
    // ============================================================
    generate
        if (L1 == 1) begin
            assign eq = level1[0];
        end else begin : FINAL_REDUCE
            and8_N$ u_final (
                .out(eq),
                .in0(level1[0]),
                .in1(L1 > 1 ? level1[1] : 1'b1),
                .in2(L1 > 2 ? level1[2] : 1'b1),
                .in3(L1 > 3 ? level1[3] : 1'b1),
                .in4(L1 > 4 ? level1[4] : 1'b1),
                .in5(L1 > 5 ? level1[5] : 1'b1),
                .in6(L1 > 6 ? level1[6] : 1'b1),
                .in7(L1 > 7 ? level1[7] : 1'b1)
            );
        end
    endgenerate

endmodule
