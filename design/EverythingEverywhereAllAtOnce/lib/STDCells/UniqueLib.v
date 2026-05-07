module inv_N$ #(
    parameter WIDTH = 1
) (
    input  wire [WIDTH-1:0] in,
    output wire [WIDTH-1:0] out
);

    genvar i;

    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : GEN_INV
            bufferHInv16$ u_inv (
                .out(out[i]),
                .in (in[i])
            );
        end
    endgenerate

endmodule

module MPS_XOR_IN2 #(
    parameter WIDTH = 1
)(
    output [WIDTH-1:0] out,
    input  [WIDTH-1:0] in0,
    input  [WIDTH-1:0] in1
);

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : GEN_XOR
            xor2$ u_xor_g (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i])
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
    wire [WIDTH-1:0] chain[0:STAGES];

    // First stage
    assign chain[0] = in;

    genvar s, i;

    // Buffer stages
    generate
        for (s = 0; s < STAGES; s = s + 1) begin : GEN_STAGE
            for (i = 0; i < WIDTH; i = i + 1) begin : GEN_BIT
                bufferH16$ u_buf (
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
    parameter WIDTH = 2
) (
    input  [WIDTH-1:0] in0,
    input  [WIDTH-1:0] in1,
    output             eq
);

    // ============================================================
    // Step 1: Bitwise XNOR  (0.25 ns typ per bit)
    //   b[i] = 1  iff  in0[i] == in1[i]
    // ============================================================
    wire [WIDTH-1:0] b;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : GEN_XNOR
            xnor2$ u_xnor (
                .out(b[i]),
                .in0(in0[i]),
                .in1(in1[i])
            );
        end
    endgenerate

    // ============================================================
    // Step 2: Hardcoded AND reduction tree, optimised per width
    //
    //  Cells used and their typical delays (from lib1.v):
    //    and2$  0.35 ns
    //    and3$  0.35 ns
    //    and4$  0.40 ns
    //
    //  Strategy: maximise gate fan-in to minimise levels.
    //  Widths not listed below cause a compile-time $fatal.
    // ============================================================
    generate
        if (WIDTH == 1) begin : EQ_1
            assign eq = b;
        end
        else if (WIDTH == 2) begin : EQ_2
            // 1 level: and2$
            // Critical path: 0.25 + 0.35 = 0.60 ns
            and2$ u0 (
                .out(eq),
                .in0(b[0]),
                .in1(b[1])
            );

        end else if (WIDTH == 3) begin : EQ_3
            // 1 level: and3$
            // Critical path: 0.25 + 0.35 = 0.60 ns
            and3$ u0 (
                .out(eq),
                .in0(b[0]),
                .in1(b[1]),
                .in2(b[2])
            );

        end else if (WIDTH == 4) begin : EQ_4
            // 1 level: and4$
            // Critical path: 0.25 + 0.40 = 0.65 ns
            and4$ u0 (
                .out(eq),
                .in0(b[0]),
                .in1(b[1]),
                .in2(b[2]),
                .in3(b[3])
            );

        end else if (WIDTH == 5) begin : EQ_5
            // Level 1 (parallel): and3$[0:2] || and2$[3:4]  → 0.35 ns
            // Level 2           : and2$(l0, l1)              → 0.35 ns
            // Critical path: 0.25 + 0.35 + 0.35 = 0.95 ns
            wire l0, l1;
            nand3$ u0 (
                .out(l0),
                .in0(b[0]),
                .in1(b[1]),
                .in2(b[2])
            );
            nand2$ u1 (
                .out(l1),
                .in0(b[3]),
                .in1(b[4])
            );
            nor2$ u2 (
                .out(eq),
                .in0(l0),
                .in1(l1)
            );

        end else if (WIDTH == 6) begin : EQ_6
            // Level 1 (parallel): and3$[0:2] || and3$[3:5]  → 0.35 ns
            // Level 2           : and2$(l0, l1)              → 0.35 ns
            // Critical path: 0.25 + 0.35 + 0.35 = 0.95 ns
            wire l0, l1;
            nand3$ u0 (
                .out(l0),
                .in0(b[0]),
                .in1(b[1]),
                .in2(b[2])
            );
            nand3$ u1 (
                .out(l1),
                .in0(b[3]),
                .in1(b[4]),
                .in2(b[5])
            );
            nor2$ u2 (
                .out(eq),
                .in0(l0),
                .in1(l1)
            );

        end else if (WIDTH == 8) begin : EQ_8
            // Level 1 (parallel): and4$[0:3] || and4$[4:7]  → 0.40 ns
            // Level 2           : and2$(l0, l1)              → 0.35 ns
            // Critical path: 0.25 + 0.40 + 0.35 = 1.00 ns
            wire l0, l1;
            nand4$ u0 (
                .out(l0),
                .in0(b[0]),
                .in1(b[1]),
                .in2(b[2]),
                .in3(b[3])
            );
            nand4$ u1 (
                .out(l1),
                .in0(b[4]),
                .in1(b[5]),
                .in2(b[6]),
                .in3(b[7])
            );
            nor2$ u2 (
                .out(eq),
                .in0(l0),
                .in1(l1)
            );

        end else if (WIDTH == 9) begin : EQ_9
            // Level 1 (parallel): and3$[0:2] || and3$[3:5] || and3$[6:8]  → 0.35 ns
            // Level 2           : and3$(l0, l1, l2)                         → 0.35 ns
            // Critical path: 0.25 + 0.35 + 0.35 = 0.95 ns
            wire l0, l1, l2;
            nand3$ u0 (
                .out(l0),
                .in0(b[0]),
                .in1(b[1]),
                .in2(b[2])
            );
            nand3$ u1 (
                .out(l1),
                .in0(b[3]),
                .in1(b[4]),
                .in2(b[5])
            );
            nand3$ u2 (
                .out(l2),
                .in0(b[6]),
                .in1(b[7]),
                .in2(b[8])
            );
            nor3$ u3 (
                .out(eq),
                .in0(l0),
                .in1(l1),
                .in2(l2)
            );

        end else if (WIDTH == 11) begin : EQ_11
            wire l0, l1, l2;
            nand4$ u0 (
                .out(l0),
                .in0(b[0]),
                .in1(b[1]),
                .in2(b[2]),
                .in3(b[3])
            );
            nand4$ u1 (
                .out(l1),
                .in0(b[4]),
                .in1(b[5]),
                .in2(b[6]),
                .in3(b[7])
            );
            nand3$ u2 (
                .out(l2),
                .in0(b[8]),
                .in1(b[9]),
                .in2(b[10])
            );
            nor3$ u3 (
                .out(eq),
                .in0(l0),
                .in1(l1),
                .in2(l2)
            );

        end else if (WIDTH == 22) begin : EQ_22
            // Level 1 (parallel): 7× nand3$, one per triple of b[0:20]     → 0.35 ns
            // Level 2 (parallel): 2× nor3$ + 1× nor2$                      → 0.35 ns
            // Level 3           : and4$(m[0], m[1], m[2], b[21])           → 0.40 ns
            // Critical path: 0.25 + 0.35 + 0.35 + 0.40 = 1.35 ns

            wire [6:0] n;  // nand3$ layer
            wire [2:0] m;  // nor layer

            // ---- Level 1: nand3$ ----
            nand3$ u_n0 (.out(n[0]), .in0(b[ 0]), .in1(b[ 1]), .in2(b[ 2]));
            nand3$ u_n1 (.out(n[1]), .in0(b[ 3]), .in1(b[ 4]), .in2(b[ 5]));
            nand3$ u_n2 (.out(n[2]), .in0(b[ 6]), .in1(b[ 7]), .in2(b[ 8]));
            nand3$ u_n3 (.out(n[3]), .in0(b[ 9]), .in1(b[10]), .in2(b[11]));
            nand3$ u_n4 (.out(n[4]), .in0(b[12]), .in1(b[13]), .in2(b[14]));
            nand3$ u_n5 (.out(n[5]), .in0(b[15]), .in1(b[16]), .in2(b[17]));
            nand3$ u_n6 (.out(n[6]), .in0(b[18]), .in1(b[19]), .in2(b[20]));

            // ---- Level 2: nor3$ / nor2$ ----
            nor3$ u_m0 (.out(m[0]), .in0(n[0]), .in1(n[1]), .in2(n[2])); // bits  0-8
            nor3$ u_m1 (.out(m[1]), .in0(n[3]), .in1(n[4]), .in2(n[5])); // bits  9-17
            nor2$ u_m2 (.out(m[2]), .in0(n[6]), .in1(n[6]));             // bits 18-20 (self-NOR trick → invert)

            // ---- Level 3: and4$ ----
            and4$ u_eq (
                .out(eq),
                .in0(m[0]),
                .in1(m[1]),
                .in2(m[2]),
                .in3(b[21])
            );


        end else if (WIDTH == 24) begin : EQ_24
            // Level 1 (parallel): 8× nand3$, one per triple of b[0:23]     → 0.35 ns
            //   n[i] = 0  iff  all three bits in the group match
            // Level 2 (parallel): 2× nor3$ + 1× nor2$                       → 0.35 ns
            //   m[0] = nor3$(n[0:2]) = 1 iff bits  0-8  all match
            //   m[1] = nor3$(n[3:5]) = 1 iff bits  9-17 all match
            //   m[2] = nor2$(n[6:7]) = 1 iff bits 18-23 all match
            // Level 3           : and3$(m[0], m[1], m[2])                   → 0.35 ns
            // Critical path: 0.25 + 0.35 + 0.35 + 0.35 = 1.30 ns
            wire [7:0] n;  // nand3$ layer
            wire [2:0] m;  // nor layer

            // ---- Level 1: nand3$ ----
            nand3$ u_n0 (
                .out(n[0]),
                .in0(b[0]),
                .in1(b[1]),
                .in2(b[2])
            );
            nand3$ u_n1 (
                .out(n[1]),
                .in0(b[3]),
                .in1(b[4]),
                .in2(b[5])
            );
            nand3$ u_n2 (
                .out(n[2]),
                .in0(b[6]),
                .in1(b[7]),
                .in2(b[8])
            );
            nand3$ u_n3 (
                .out(n[3]),
                .in0(b[9]),
                .in1(b[10]),
                .in2(b[11])
            );
            nand3$ u_n4 (
                .out(n[4]),
                .in0(b[12]),
                .in1(b[13]),
                .in2(b[14])
            );
            nand3$ u_n5 (
                .out(n[5]),
                .in0(b[15]),
                .in1(b[16]),
                .in2(b[17])
            );
            nand3$ u_n6 (
                .out(n[6]),
                .in0(b[18]),
                .in1(b[19]),
                .in2(b[20])
            );
            nand3$ u_n7 (
                .out(n[7]),
                .in0(b[21]),
                .in1(b[22]),
                .in2(b[23])
            );

            // ---- Level 2: nor3$ / nor2$ ----
            nor3$ u_m0 (
                .out(m[0]),
                .in0(n[0]),
                .in1(n[1]),
                .in2(n[2])
            );  // bits  0-8
            nor3$ u_m1 (
                .out(m[1]),
                .in0(n[3]),
                .in1(n[4]),
                .in2(n[5])
            );  // bits  9-17
            nor2$ u_m2 (
                .out(m[2]),
                .in0(n[6]),
                .in1(n[7])
            );  // bits 18-23

            // ---- Level 3: and3$ ----
            and3$ u_eq (
                .out(eq),
                .in0(m[0]),
                .in1(m[1]),
                .in2(m[2])
            );

        end else if (WIDTH == 28) begin : EQ_28
            // Level 1 (parallel): 9× nand3$, one per triple of b[0:26]     → 0.35 ns
            //   n[i] = 0  iff  all three bits in the group match
            // Level 2 (parallel): 3× nor3$, each folding 3 nand3$ outputs  → 0.35 ns
            //   m[k] = 1  iff  all 9 bits in the group match
            //   NOR(NAND,NAND,NAND) = ~(~a|~b|~c) = a&b&c  (De Morgan)
            // Level 3           : and4$(m[0], m[1], m[2], b[27])            → 0.40 ns
            // Critical path: 0.25 + 0.35 + 0.35 + 0.40 = 1.35 ns
            wire [8:0] n;  // nand3$ layer — covers b[0:26]
            wire [2:0] m;  // nor3$  layer

            // ---- Level 1: nand3$ ----
            nand3$ u_n0 (
                .out(n[0]),
                .in0(b[0]),
                .in1(b[1]),
                .in2(b[2])
            );
            nand3$ u_n1 (
                .out(n[1]),
                .in0(b[3]),
                .in1(b[4]),
                .in2(b[5])
            );
            nand3$ u_n2 (
                .out(n[2]),
                .in0(b[6]),
                .in1(b[7]),
                .in2(b[8])
            );
            nand3$ u_n3 (
                .out(n[3]),
                .in0(b[9]),
                .in1(b[10]),
                .in2(b[11])
            );
            nand3$ u_n4 (
                .out(n[4]),
                .in0(b[12]),
                .in1(b[13]),
                .in2(b[14])
            );
            nand3$ u_n5 (
                .out(n[5]),
                .in0(b[15]),
                .in1(b[16]),
                .in2(b[17])
            );
            nand3$ u_n6 (
                .out(n[6]),
                .in0(b[18]),
                .in1(b[19]),
                .in2(b[20])
            );
            nand3$ u_n7 (
                .out(n[7]),
                .in0(b[21]),
                .in1(b[22]),
                .in2(b[23])
            );
            nand3$ u_n8 (
                .out(n[8]),
                .in0(b[24]),
                .in1(b[25]),
                .in2(b[26])
            );

            // ---- Level 2: nor3$ (NAND→NOR = AND semantics) ----
            nor3$ u_m0 (
                .out(m[0]),
                .in0(n[0]),
                .in1(n[1]),
                .in2(n[2])
            );  // bits  0-8
            nor3$ u_m1 (
                .out(m[1]),
                .in0(n[3]),
                .in1(n[4]),
                .in2(n[5])
            );  // bits  9-17
            nor3$ u_m2 (
                .out(m[2]),
                .in0(n[6]),
                .in1(n[7]),
                .in2(n[8])
            );  // bits 18-26

            // ---- Level 3: and4$ to fold in bit 27 ----
            and4$ u_eq (
                .out(eq),
                .in0(m[0]),
                .in1(m[1]),
                .in2(m[2]),
                .in3(b[27])
            );

        end else if (WIDTH == 32) begin : EQ_32
            // Level 1: 10× nand3$  (bits 0–29)
            // Level 2: 4× nor3$    (reduce 10 → 4)
            // Level 3: and4$       (final reduction including bits 30,31)

            wire [10:0] n;  // nand3$ layer (0–29)
            wire [ 3:0] m;  // nor3$ layer

            // ---- Level 1: nand3$ ----
            nand3$ u_n0 (
                .out(n[0]),
                .in0(b[0]),
                .in1(b[1]),
                .in2(b[2])
            );
            nand3$ u_n1 (
                .out(n[1]),
                .in0(b[3]),
                .in1(b[4]),
                .in2(b[5])
            );
            nand3$ u_n2 (
                .out(n[2]),
                .in0(b[6]),
                .in1(b[7]),
                .in2(b[8])
            );
            nand3$ u_n3 (
                .out(n[3]),
                .in0(b[9]),
                .in1(b[10]),
                .in2(b[11])
            );
            nand3$ u_n4 (
                .out(n[4]),
                .in0(b[12]),
                .in1(b[13]),
                .in2(b[14])
            );
            nand3$ u_n5 (
                .out(n[5]),
                .in0(b[15]),
                .in1(b[16]),
                .in2(b[17])
            );
            nand3$ u_n6 (
                .out(n[6]),
                .in0(b[18]),
                .in1(b[19]),
                .in2(b[20])
            );
            nand3$ u_n7 (
                .out(n[7]),
                .in0(b[21]),
                .in1(b[22]),
                .in2(b[23])
            );
            nand3$ u_n8 (
                .out(n[8]),
                .in0(b[24]),
                .in1(b[25]),
                .in2(b[26])
            );
            nand3$ u_n9 (
                .out(n[9]),
                .in0(b[27]),
                .in1(b[28]),
                .in2(b[29])
            );
            nand2$ u_n10 (
                .out(n[10]),
                .in0(b[30]),
                .in1(b[31])
            );

            // ---- Level 2: nor3$ ----
            nor3$ u_m0 (
                .out(m[0]),
                .in0(n[0]),
                .in1(n[1]),
                .in2(n[2])
            );  // 0–8
            nor3$ u_m1 (
                .out(m[1]),
                .in0(n[3]),
                .in1(n[4]),
                .in2(n[5])
            );  // 9–17
            nor3$ u_m2 (
                .out(m[2]),
                .in0(n[6]),
                .in1(n[7]),
                .in2(n[8])
            );  // 18–26

            // leftover n[9] folded with constant-true behavior via NOR trick
            // m[3] = n[9] inverted back to AND-equivalent using NOR with itself
            nor3$ u_m3 (
                .out(m[3]),
                .in0(n[9]),
                .in1(n[10]),
                .in2(n[9])
            );

            // ---- Level 3: final AND ----
            and4$ u_eq (
                .out(eq),
                .in0(m[0]),
                .in1(m[1]),
                .in2(m[2]),
                .in3(m[3] & b[30] & b[31])  // fold remaining bits
            );

        end else begin : EQ_UNSUPPORTED
            // synopsys translate_off
            initial begin
                $fatal(1, "MPS_COMP_EQ: WIDTH=%0d not supported. Aldulowed: 2,3,4,5,6,8,9,24,28.",
                       WIDTH);
            end
            // synopsys translate_on
        end

    endgenerate

endmodule
