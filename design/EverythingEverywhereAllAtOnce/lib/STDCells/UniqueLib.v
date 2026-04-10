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
            xnor2$ u_xnor (.out(b[i]), .in0(in0[i]), .in1(in1[i]));
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

        if (WIDTH == 2) begin : EQ_2
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
            and3$ u0 (.out(l0), .in0(b[0]), .in1(b[1]), .in2(b[2]));
            and2$ u1 (.out(l1), .in0(b[3]), .in1(b[4]));
            and2$ u2 (.out(eq), .in0(l0),   .in1(l1));

        end else if (WIDTH == 6) begin : EQ_6
            // Level 1 (parallel): and3$[0:2] || and3$[3:5]  → 0.35 ns
            // Level 2           : and2$(l0, l1)              → 0.35 ns
            // Critical path: 0.25 + 0.35 + 0.35 = 0.95 ns
            wire l0, l1;
            and3$ u0 (.out(l0), .in0(b[0]), .in1(b[1]), .in2(b[2]));
            and3$ u1 (.out(l1), .in0(b[3]), .in1(b[4]), .in2(b[5]));
            and2$ u2 (.out(eq), .in0(l0),   .in1(l1));

        end else if (WIDTH == 8) begin : EQ_8
            // Level 1 (parallel): and4$[0:3] || and4$[4:7]  → 0.40 ns
            // Level 2           : and2$(l0, l1)              → 0.35 ns
            // Critical path: 0.25 + 0.40 + 0.35 = 1.00 ns
            wire l0, l1;
            and4$ u0 (.out(l0), .in0(b[0]), .in1(b[1]), .in2(b[2]), .in3(b[3]));
            and4$ u1 (.out(l1), .in0(b[4]), .in1(b[5]), .in2(b[6]), .in3(b[7]));
            and2$ u2 (.out(eq), .in0(l0),   .in1(l1));

        end else if (WIDTH == 9) begin : EQ_9
            // Level 1 (parallel): and3$[0:2] || and3$[3:5] || and3$[6:8]  → 0.35 ns
            // Level 2           : and3$(l0, l1, l2)                         → 0.35 ns
            // Critical path: 0.25 + 0.35 + 0.35 = 0.95 ns
            wire l0, l1, l2;
            and3$ u0 (.out(l0), .in0(b[0]), .in1(b[1]), .in2(b[2]));
            and3$ u1 (.out(l1), .in0(b[3]), .in1(b[4]), .in2(b[5]));
            and3$ u2 (.out(l2), .in0(b[6]), .in1(b[7]), .in2(b[8]));
            and3$ u3 (.out(eq), .in0(l0),   .in1(l1),   .in2(l2));

        end else begin : EQ_UNSUPPORTED
            initial begin
                $fatal(1, "MPS_COMP_EQ: WIDTH=%0d not supported. Allowed: 2,3,4,5,6,8,9.", WIDTH);
            end
        end

    endgenerate

endmodule
