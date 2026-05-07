// ============================================================
//  Parameterized Kogge-Stone Parallel Prefix Adder
//  Structural Verilog — Verilog-2001 compatible
//
//  Architecture overview (example: WIDTH = 8, STAGES = 3)
//
//   a/b ──► [PG Cell × WIDTH] ──► Stage 1 ──► Stage 2 ──► Stage 3
//            (pre-process)      step=1     step=2     step=4
//                                Black      Black      Gray
//                                Cells      Cells      Cells
//                                                          │
//                                           [Sum Cells × WIDTH]
//                                                          │
//                                                       sum / cout
//
//  Cell types
//  ──────────
//  pg_cell    – computes G = A & B, P = A ^ B for each input bit
//  black_cell – prefix op producing both (G_out, P_out); used in
//               all intermediate prefix stages
//  gray_cell  – prefix op producing G_out only; used in the final
//               prefix stage (P no longer needed afterward)
//  sum_cell   – computes sum bit: S = P_orig ^ C_in
//
//  Signal indexing
//  ───────────────
//  Intermediate G and P are stored in flat 1-D wires:
//    stage s, bit i  →  index  s*WIDTH + i
//  Stage 0 holds the PG cell outputs.
//  Stage STAGES holds the final group-generate values used as
//  carry-in signals for the sum cells.
// ============================================================


// ============================================================
//  Top-Level: Parameterized Kogge-Stone Adder
//
//  Parameters
//  ──────────
//  WIDTH  – operand width in bits (any positive integer; the
//            prefix tree depth auto-adjusts to ceil(log2(WIDTH)))
//
//  Ports
//  ─────
//  a, b   – WIDTH-bit addends
//  cin    – carry-in (e.g. for chaining or subtraction)
//  sum    – WIDTH-bit result
//  cout   – carry-out
// ============================================================
module kogge_stone_adder #(
    parameter WIDTH = 8
) (
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire             cin,
    output wire [WIDTH-1:0] sum,
    output wire             cout
);

    localparam STAGES = $clog2(WIDTH);

    // ----------------------------------------------------------
    //  Flat intermediate arrays for generate (G) and propagate (P)
    //
    //  Total depth  : STAGES + 1  (index 0 = PG stage output)
    //  Total entries: WIDTH × (STAGES + 1)
    //
    //  Access:  stage s, bit i  →  [s*WIDTH + i]
    // ----------------------------------------------------------
    wire [WIDTH*(STAGES+1)-1:0] g_arr;
    wire [WIDTH*(STAGES+1)-1:0] p_arr;

    genvar i, s;

    // ----------------------------------------------------------
    //  Stage 0 — Pre-processing
    //  Instantiate one PG cell per input bit.
    //
    //  Bit 0 is special-cased to fold `cin` into its generate
    //  signal so the prefix tree correctly delivers the carry into
    //  bits 1..WIDTH-1:
    //     g_eff[0] = (a[0] & b[0]) | ((a[0] ^ b[0]) & cin)
    //  p[0] stays as the raw propagate (a[0] ^ b[0]); the bit-0
    //  sum_cell still uses the external `cin` directly so sum[0]
    //  is unchanged. Without this, sum[i>0] is wrong whenever
    //  cin=1 and bits 0..i-1 form a propagate chain past bit 0.
    // ----------------------------------------------------------
    wire p0_raw, g0_raw, p0_and_cin, g_arr0_raw;
    `XOR_2(u_p0_xor, 1, p0_raw,     a[0], b[0])
    `AND_2(u_g0_and, 1, g0_raw,     a[0], b[0])
    `AND_2(u_p0_cin, 1, p0_and_cin, p0_raw, cin)
    `OR_2 (u_g0_or,  1, g_arr0_raw, g0_raw, p0_and_cin)
    // g_arr[0] is read by every stage's prefix-tree boundary bit (via the
    // passthrough chain) plus the bit-1 sum cell, fanout ~ STAGES+1.
    // Drive the high-fanout net with bufferH16$ per the structural rule.
    bufferH16$ u_buf_g0 (.out(g_arr[0]), .in(g_arr0_raw));
    assign p_arr[0] = p0_raw;

    generate
        for (i = 1; i < WIDTH; i = i + 1) begin : gen_pg
            pg_cell u_pg (
                .a(a[i]),
                .b(b[i]),
                .g(g_arr[i]),  // stage-0, bit-i generate
                .p(p_arr[i])   // stage-0, bit-i propagate
            );
        end
    endgenerate

    // ----------------------------------------------------------
    //  Stages 1 .. STAGES — Parallel Prefix Tree
    //
    //  At stage s the "reach" (step distance) is 2^(s-1).
    //
    //  For each bit i:
    //    i >= step  →  active cell
    //                    • s < STAGES : black_cell (outputs G + P)
    //                    • s == STAGES: gray_cell  (output G only)
    //    i <  step  →  pass-through wire (bit not yet combined)
    // ----------------------------------------------------------
    generate
        for (s = 1; s <= STAGES; s = s + 1) begin : gen_stage
            for (i = 0; i < WIDTH; i = i + 1) begin : gen_bit

                if (i >= (1 << (s - 1))) begin : g_active

                    //if (s < STAGES) begin : g_black ///// bug here, s will never be stages until end of loop, need to build this part myself
                    if (i >= (1 << s)) begin : g_black
                        // ---- Black Cell ----------------------------------------
                        black_cell u_black (
                            .g_hi (g_arr[(s-1)*WIDTH+i]),
                            .p_hi (p_arr[(s-1)*WIDTH+i]),
                            .g_lo (g_arr[(s-1)*WIDTH+i-(1<<(s-1))]),
                            .p_lo (p_arr[(s-1)*WIDTH+i-(1<<(s-1))]),
                            .g_out(g_arr[s*WIDTH+i]),
                            .p_out(p_arr[s*WIDTH+i])
                        );
                    end else begin : g_gray
                        // ---- Gray Cell (final stage — G only) ------------------
                        gray_cell u_gray (
                            .g_hi (g_arr[(s-1)*WIDTH+i]),
                            .p_hi (p_arr[(s-1)*WIDTH+i]),
                            .g_lo (g_arr[(s-1)*WIDTH+i-(1<<(s-1))]),
                            .g_out(g_arr[s*WIDTH+i])
                        );
                        // P is not consumed after the last stage; tie off to
                        // avoid undriven-wire warnings in simulation.
                        assign p_arr[s*WIDTH+i] = 1'b0;
                    end

                end else begin : g_passthrough
                    // ---- Wire pass-through (bit not yet reached by this step) --
                    assign g_arr[s*WIDTH+i] = g_arr[(s-1)*WIDTH+i];
                    assign p_arr[s*WIDTH+i] = p_arr[(s-1)*WIDTH+i];
                end

            end  // gen_bit
        end  // gen_stage
    endgenerate

    // ----------------------------------------------------------
    //  Post-processing — Sum Cells
    //
    //  sum[0]   : carry-in is cin
    //  sum[i>0] : carry-in is the prefix-tree group-generate for
    //             bits 0..(i-1), i.e.  g_arr[STAGES*WIDTH + i-1]
    //
    //  The original propagate used here is always from stage 0
    //  (p_arr[i]), which equals a[i] ^ b[i].
    // ----------------------------------------------------------
    // ----------------------------------------------------------
    //  Post-processing — Sum bits (flattened, no sum_cell wrapper)
    //
    //  xor2$.out drives sum[i] directly inside this module, so the
    //  fanout tool sees the parent's load cells as real loads on that
    //  net — no buffer needed, saves 0.24 ns on the sum path.
    // ----------------------------------------------------------
    // Bit 0 — carry-in is cin
    xor2$ u_sum_lsb (
        .out(sum[0]),
        .in0(p_arr[0]),
        .in1(cin)
    );

    generate
        // Bits 1 .. WIDTH-1 — carry-in is prefix-tree group-generate
        for (i = 1; i < WIDTH; i = i + 1) begin : gen_sum
            xor2$ u_sum (
                .out(sum[i]),
                .in0(p_arr[i]),
                .in1(g_arr[STAGES*WIDTH+i-1])
            );
        end
    endgenerate

    // ----------------------------------------------------------
    //  Carry-out — group generate spanning all WIDTH bits
    // ----------------------------------------------------------
    assign cout = g_arr[STAGES*WIDTH+WIDTH-1];

endmodule


// ------------------------------------------------------------
//  Cell 1 — Pre-processing (PG) Cell
//  Computes the initial generate and propagate for one bit pair.
//    G = A & B   (carry is generated here)
//    P = A ^ B   (carry from below can propagate through)
// ------------------------------------------------------------
module pg_cell (
    input  wire a,
    input  wire b,
    output wire g,
    output wire p
);
    // and2$ u_gen (
    //     g,
    //     a,
    //     b
    // );
    // xor2$ u_prop (
    //     p,
    //     a,
    //     b
    // );
    `AND_2(u_gen, 1, 
        g, 
        a, 
        b
    )
     `XOR_2 (u_prop, 1,
        p,
        a,
        b
    );


endmodule


// ------------------------------------------------------------
//  Cell 2 — Black Cell
//  Merges two (G, P) pairs in the prefix tree.
//  Used in every intermediate stage; outputs both G and P so
//  downstream stages can continue combining.
//
//    G_out = G_hi | (P_hi & G_lo)
//    P_out = P_hi & P_lo
//
//  (hi = closer to MSB / higher index; lo = farther from MSB)
// ------------------------------------------------------------
module black_cell (
    input  wire g_hi,
    input  wire p_hi,
    input  wire g_lo,
    input  wire p_lo,
    output wire g_out,
    output wire p_out
);
    wire p_and_g;
    // and2$ u_and1 (
    //     p_and_g,
    //     p_hi,
    //     g_lo
    // );  // P_hi & G_lo
    // or2$ u_or (
    //     g_out,
    //     g_hi,
    //     p_and_g
    // );  // G_hi | (P_hi & G_lo)
    // and2$ u_and2 (
    //     p_out,
    //     p_hi,
    //     p_lo
    // );  // P_hi & P_lo

    `AND_2(u_and1, 1, 
        p_and_g, 
        p_hi, 
        g_lo
    )
    `OR_2(u_or, 1, 
        g_out, 
        g_hi, 
        p_and_g
    )
    `AND_2(u_and2, 1, 
        p_out, 
        p_hi, 
        p_lo
    )
endmodule


// ------------------------------------------------------------
//  Cell 3 — Gray Cell
//  Merges (G_hi, P_hi) with G_lo from a lower-index group.
//  Used only in the final prefix stage; only G_out is produced
//  because P is not consumed after the last prefix stage.
//
//    G_out = G_hi | (P_hi & G_lo)
// ------------------------------------------------------------
module gray_cell (
    input  wire g_hi,
    input  wire p_hi,
    input  wire g_lo,
    output wire g_out
);
    wire p_and_g, g_out_raw;
    // and2$ u_and (
    //     p_and_g,
    //     p_hi,
    //     g_lo
    // );  // P_hi & G_lo
    // or2$ u_or (
    //     g_out,
    //     g_hi,
    //     p_and_g
    // );  // G_hi | (P_hi & G_lo)

    `AND_2(u_and, 1,
        p_and_g,
        p_hi,
        g_lo
    )
    `OR_2(u_or, 1,
        g_out_raw,
        g_hi,
        p_and_g
    )
    // Gray cells sit at the prefix-tree boundary bit, so g_out feeds every
    // higher stage's boundary cell via the passthrough chain plus the next
    // sum bit — fanout ~ (STAGES - s + 1). Buffer per the structural rule.
    bufferH16$ u_buf_g_out (.out(g_out), .in(g_out_raw));
endmodule


// ------------------------------------------------------------
//  Cell 4 — Sum Cell
//  Computes one final sum bit from the original propagate and
//  the incoming carry (= group-generate of all lower bits).
//
//    Sum = P_orig ^ C_in
// ------------------------------------------------------------
module sum_cell (
    input  wire p,
    input  wire c_in,
    output wire sum
);
    // xor2$ cannot drive the output port directly: the fanout tool stops
    // tracing at the port boundary and records fanout=0 on xor2$.out.
    // bufferH16$ is the expected driver type at module outputs per the
    // fanout checker rules (bufferH16$ or bufferHInv16$ only).
    // It also adds 0.24 ns min-path delay on every sum bit.
    wire sum_raw;
    `XOR_2(u_xor, 1, sum_raw, p, c_in);
    bufferH16$ u_buf_sum (.out(sum), .in(sum_raw));
endmodule
