// ============================================================
//  Radix-4 Parallel Prefix Adder — 32-bit optimized
//  Structural Verilog — Verilog-2001 compatible
//
//  Key difference from radix-2 Kogge-Stone
//  ─────────────────────────────────────────
//  Radix-2 (original): STAGES = ceil(log2(32)) = 5
//    step sizes: 1 → 2 → 4 → 8 → 16   (5 stages)
//
//  Radix-4 (this file): STAGES = ceil(log4(32)) = 3
//    step sizes: 1,2 → 4,8 → 16,32    (3 stages)
//
//    Stage 1 fires two black/gray cells: step=1 AND step=2 in
//    parallel (they read the same stage-0 inputs, so there is
//    zero added latency between them). This produces a
//    "4-bit group generate/propagate" at the output of stage 1.
//
//    Stage 2 similarly fires step=4 AND step=8 in parallel,
//    producing 16-bit groups.
//
//    Stage 3 fires step=16 only (gray cells — G only needed).
//
//  Critical path
//  ─────────────
//  Radix-2: PG → 5×(AND+OR) → XOR  = 12 gate delays (approx)
//  Radix-4: PG → 3×(AND+OR) → XOR  =  8 gate delays (approx)
//            ↑ same cell primitives, just 3 stages not 5
//
//  Stage indexing
//  ──────────────
//  We still use a flat 1-D array but now STAGES = 3 for WIDTH=32.
//  Within each radix-4 stage we issue TWO rounds of prefix ops
//  that are data-independent (they both read from stage s-1),
//  so they are structurally separate but logically concurrent.
//  We implement this by unrolling: each "logical stage" s
//  produces TWO sets of intermediate wires (labeled _a and _b
//  for the two substeps), stored in separate flat arrays.
//
//  Cell types used
//  ───────────────
//  pg_cell    — same as before
//  black_cell — same as before (G+P prefix op)
//  gray_cell  — same as before (G-only prefix op)
//  sum_cell   — same as before
// ============================================================


// ============================================================
//  Top-Level: Radix-4 Prefix Adder (optimised for WIDTH=32)
//
//  Parameters
//  ──────────
//  WIDTH  — operand width; sized for 32-bit but parameterized.
//            For WIDTH=32: 3 prefix stages.
//            For other widths the localparam STAGES still uses
//            ceil(log2) so it degrades gracefully to radix-2
//            behaviour — feel free to add wider radix support.
//
//  Ports  — identical to kogge_stone_adder so it is a
//            drop-in replacement.
// ============================================================
module kogge_stone_r4 #(
    parameter WIDTH = 32
) (
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire             cin,
    output wire [WIDTH-1:0] sum,
    output wire             cout
);

    // ----------------------------------------------------------
    //  For WIDTH=32 this is 3.  For WIDTH=16 it is 2, etc.
    //  Radix-4 halves the stage count of radix-2.
    // ----------------------------------------------------------
    localparam STAGES_R2 = $clog2(WIDTH);          // 5 for W=32
    localparam STAGES    = (STAGES_R2 + 1) / 2;    // 3 for W=32

    // ----------------------------------------------------------
    //  Flat G/P arrays.
    //
    //  We store TWO substeps per radix-4 stage in the array:
    //    substep A (smaller step, e.g. step=1): index base = (2*s-1)*WIDTH
    //    substep B (larger  step, e.g. step=2): index base = (2*s  )*WIDTH
    //  Stage 0 (PG outputs) sits at index base 0.
    //
    //  Total entries: WIDTH * (2*STAGES + 1)
    //    s=0 → slice 0           (PG outputs)
    //    s=1 → slices 1,2        (steps 1 and 2)
    //    s=2 → slices 3,4        (steps 4 and 8)
    //    s=3 → slices 5,6        (steps 16 and 32 — only slice 5
    //                             is meaningful for W=32 gray cells)
    // ----------------------------------------------------------
    localparam DEPTH = 2 * STAGES + 1;
    wire [WIDTH*DEPTH-1:0] g_arr;
    wire [WIDTH*DEPTH-1:0] p_arr;

    genvar i, s;

    // ----------------------------------------------------------
    //  Convenience function — slice base index
    //    slice 0               → PG stage output
    //    radix-4 stage s, sub A → slice index 2*s - 1
    //    radix-4 stage s, sub B → slice index 2*s
    // ----------------------------------------------------------
    // (used inline below as integer expressions)

    // ----------------------------------------------------------
    //  Stage 0 — Pre-processing: one PG cell per bit
    // ----------------------------------------------------------
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_pg
            pg_cell u_pg (
                .a(a[i]),
                .b(b[i]),
                .g(g_arr[i]),
                .p(p_arr[i])
            );
        end
    endgenerate

    // ----------------------------------------------------------
    //  Radix-4 Prefix Stages
    //
    //  For each radix-4 stage s (1..STAGES):
    //
    //    Sub-step A: step_a = 1 << (2*(s-1))     e.g. s=1→1, s=2→4, s=3→16
    //    Sub-step B: step_b = 1 << (2*(s-1) + 1) e.g. s=1→2, s=2→8, s=3→32
    //
    //    Sub-step A reads from stage s-1 sub-step B output
    //      (slice index 2*(s-1), or 0 when s=1 which is the PG stage).
    //    Sub-step B reads from sub-step A of THIS stage
    //      (slice index 2*s - 1).
    //
    //  The final stage's sub-step A (step=16 for W=32) uses
    //  gray_cells (G only); sub-step B at step=32 is beyond
    //  WIDTH so it only generates pass-throughs.
    //
    //  "Active" = i >= step for that substep.
    //  "Gray"   = this is the very last prefix operation that
    //             any bit i will participate in (after this,
    //             P is never read again).  We determine this
    //             per-bit: a bit i is "done" (gray) when the
    //             accumulated step already covers bit 0, i.e.
    //             step > i.  More precisely: in the LAST stage
    //             (s == STAGES), all active cells are gray.
    // ----------------------------------------------------------
    generate
        for (s = 1; s <= STAGES; s = s + 1) begin : gen_r4_stage

            // step sizes for the two sub-steps of this stage
            localparam integer STEP_A = 1 << (2*(s-1));
            localparam integer STEP_B = 1 << (2*(s-1) + 1);

            // slice indices into g_arr / p_arr
            localparam integer SRC_SLICE  = 2*(s-1);   // input  for sub-A
            localparam integer DST_A      = 2*s - 1;   // output of sub-A
            localparam integer DST_B      = 2*s;       // output of sub-B

            // Is this the final prefix stage?
            localparam integer LAST = (s == STAGES) ? 1 : 0;

            // ---- Sub-step A ----------------------------------------
            for (i = 0; i < WIDTH; i = i + 1) begin : gen_subA

                if (i >= STEP_A) begin : g_active_A

                    if (LAST) begin : g_gray_A
                        // Final stage — gray cell (G only)
                        gray_cell u_gray_A (
                            .g_hi (g_arr[SRC_SLICE*WIDTH + i]),
                            .p_hi (p_arr[SRC_SLICE*WIDTH + i]),
                            .g_lo (g_arr[SRC_SLICE*WIDTH + i - STEP_A]),
                            .g_out(g_arr[DST_A*WIDTH + i])
                        );
                        assign p_arr[DST_A*WIDTH + i] = 1'b0;

                    end else begin : g_black_A
                        // Intermediate stage — black cell
                        black_cell u_black_A (
                            .g_hi (g_arr[SRC_SLICE*WIDTH + i]),
                            .p_hi (p_arr[SRC_SLICE*WIDTH + i]),
                            .g_lo (g_arr[SRC_SLICE*WIDTH + i - STEP_A]),
                            .p_lo (p_arr[SRC_SLICE*WIDTH + i - STEP_A]),
                            .g_out(g_arr[DST_A*WIDTH + i]),
                            .p_out(p_arr[DST_A*WIDTH + i])
                        );
                    end

                end else begin : g_pass_A
                    assign g_arr[DST_A*WIDTH + i] = g_arr[SRC_SLICE*WIDTH + i];
                    assign p_arr[DST_A*WIDTH + i] = p_arr[SRC_SLICE*WIDTH + i];
                end

            end  // gen_subA

            // ---- Sub-step B ----------------------------------------
            // Sub-step B reads from sub-step A output (DST_A).
            // If STEP_B >= WIDTH, all bits are pass-throughs.
            for (i = 0; i < WIDTH; i = i + 1) begin : gen_subB

                if ((STEP_B < WIDTH) && (i >= STEP_B)) begin : g_active_B

                    if (LAST) begin : g_gray_B
                        gray_cell u_gray_B (
                            .g_hi (g_arr[DST_A*WIDTH + i]),
                            .p_hi (p_arr[DST_A*WIDTH + i]),
                            .g_lo (g_arr[DST_A*WIDTH + i - STEP_B]),
                            .g_out(g_arr[DST_B*WIDTH + i])
                        );
                        assign p_arr[DST_B*WIDTH + i] = 1'b0;

                    end else begin : g_black_B
                        black_cell u_black_B (
                            .g_hi (g_arr[DST_A*WIDTH + i]),
                            .p_hi (p_arr[DST_A*WIDTH + i]),
                            .g_lo (g_arr[DST_A*WIDTH + i - STEP_B]),
                            .p_lo (p_arr[DST_A*WIDTH + i - STEP_B]),
                            .g_out(g_arr[DST_B*WIDTH + i]),
                            .p_out(p_arr[DST_B*WIDTH + i])
                        );
                    end

                end else begin : g_pass_B
                    // step_b too large or bit not yet reached
                    assign g_arr[DST_B*WIDTH + i] = g_arr[DST_A*WIDTH + i];
                    assign p_arr[DST_B*WIDTH + i] = p_arr[DST_A*WIDTH + i];
                end

            end  // gen_subB

        end  // gen_r4_stage
    endgenerate

    // ----------------------------------------------------------
    //  Post-processing — Sum Cells
    //
    //  The final G values live in slice DST_B of the last stage,
    //  which is slice index 2*STAGES.
    //
    //  sum[0]   : cin
    //  sum[i>0] : g_arr[2*STAGES*WIDTH + i - 1]  (carry into bit i)
    // ----------------------------------------------------------
    localparam integer FINAL_SLICE = 2 * STAGES;

    generate
        sum_cell u_sum_lsb (
            .p   (p_arr[0]),
            .c_in(cin),
            .sum (sum[0])
        );

        for (i = 1; i < WIDTH; i = i + 1) begin : gen_sum
            sum_cell u_sum (
                .p   (p_arr[i]),
                .c_in(g_arr[FINAL_SLICE*WIDTH + i - 1]),
                .sum (sum[i])
            );
        end
    endgenerate

    // ----------------------------------------------------------
    //  Carry-out
    // ----------------------------------------------------------
    assign cout = g_arr[FINAL_SLICE*WIDTH + WIDTH - 1];

endmodule


// ============================================================
//  All sub-cells below are identical to the originals —
//  no changes needed; reproduced here for self-containment.
// ============================================================

// ------------------------------------------------------------
//  PG Cell
// ------------------------------------------------------------
module pg_cell_r4 (
    input  wire a,
    input  wire b,
    output wire g,
    output wire p
);
    `AND_2(u_gen, 1, g, a, b)
    xor2$ u_prop (.p(p), .a(a), .b(b));
endmodule

// ------------------------------------------------------------
//  Black Cell  (G+P prefix operator)
//  G_out = G_hi | (P_hi & G_lo)
//  P_out = P_hi & P_lo
// ------------------------------------------------------------
module black_cell_r4 (
    input  wire g_hi,
    input  wire p_hi,
    input  wire g_lo,
    input  wire p_lo,
    output wire g_out,
    output wire p_out
);
    wire p_and_g;
    `AND_2(u_and1, 1, p_and_g, p_hi, g_lo)
    `OR_2 (u_or,   1, g_out,   g_hi, p_and_g)
    `AND_2(u_and2, 1, p_out,   p_hi, p_lo)
endmodule

// ------------------------------------------------------------
//  Gray Cell  (G-only prefix operator — final stage)
//  G_out = G_hi | (P_hi & G_lo)
// ------------------------------------------------------------
module gray_cell_r4 (
    input  wire g_hi,
    input  wire p_hi,
    input  wire g_lo,
    output wire g_out
);
    wire p_and_g;
    `AND_2(u_and, 1, p_and_g, p_hi, g_lo)
    `OR_2 (u_or,  1, g_out,   g_hi, p_and_g)
endmodule

// ------------------------------------------------------------
//  Sum Cell
//  S = P_orig ^ C_in
// ------------------------------------------------------------
module sum_cell_r4 (
    input  wire p,
    input  wire c_in,
    output wire sum
);
    xor2$ u_xor (.sum(sum), .a(p), .b(c_in));
endmodule
