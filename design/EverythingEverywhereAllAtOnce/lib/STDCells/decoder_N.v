module MPS_decoder$ #(
    parameter INPUTS = 2
) (
    input  wire [INPUTS-1:0] in,
    output wire [(1 << INPUTS)-1:0] out
);

    // ============================================================
    // Base cases and cap at 8 inputs
    // ============================================================
    generate
        if (INPUTS > 8) begin : GEN_ERROR
            // Error: decoder limited to 8 inputs maximum (simulation-only)
            // synopsys translate_off
            initial begin
                $fatal(1, "MPS_decoder$: INPUTS=%0d exceeds maximum of 8", INPUTS);
            end
            // synopsys translate_on
        end else if (INPUTS == 1) begin : GEN_DEC1
            // 1-to-2 decoder: out[0] = ~in[0], out[1] = in[0]
            wire in_bar;
            
            inv1$ u_inv (
                .out(in_bar),
                .in(in[0])
            );
            
            assign out[0] = in_bar;
            assign out[1] = in[0];

        end else if (INPUTS == 2) begin : GEN_DEC2
            wire [3:0] y, ybar;

            decoder2_4$ u_dec (
                .SEL(in),
                .Y(y),
                .YBAR(ybar)
            );

            assign out = y;

        end else if (INPUTS == 3) begin : GEN_DEC3
            wire [7:0] y, ybar;

            decoder3_8$ u_dec (
                .SEL(in),
                .Y(y),
                .YBAR(ybar)
            );

            assign out = y;

        end else begin : GEN_DEC_N

            // ========================================================
            // Recursive split for 4-8 bits
            // Split into high and low portions, ensuring both >= 1 bit
            // ========================================================
            localparam integer LOW_BITS  = (INPUTS >= 6) ? 3 : (INPUTS / 2);
            localparam integer HIGH_BITS = INPUTS - LOW_BITS;

            // Each sub-decoder output bit feeds (1<<other_BITS) ANDs in the
            // combiner.  Sub-decoder cells (decoder2_4$ / decoder3_8$) are
            // rated for ~4 loads; bufferH16$ (rated 16) inserted between
            // sub-decoder output and combiner clears the violation.
            //
            //   high_out[i] -> (1<<LOW_BITS)  ANDs   -> always <=8 (LOW_BITS<=3)
            //   low_out[j]  -> (1<<HIGH_BITS) ANDs   -> 4..32  (HIGH_BITS in 2..5)
            //
            // 1-stage buffer covers fanout <= 16.  For INPUTS=8 the low_out
            // fanout reaches 32, so we use a 2-stage tree:
            //   low_out -> s1 (1 buffer) -> LOW_LEAVES s2 leaves
            // Each leaf drives <=16 combiner ANDs; combiner picks
            // leaf = i / LEAF_GROUP where LEAF_GROUP = (1<<HIGH_BITS)/LOW_LEAVES.
            localparam integer LOW_FANOUT  = (1 << HIGH_BITS);
            localparam integer LOW_LEAVES  = (LOW_FANOUT + 15) / 16;     // ceil(fanout/16)
            localparam integer LEAF_GROUP  = (1 << HIGH_BITS) / LOW_LEAVES;

            wire [(1<<HIGH_BITS)-1:0] high_out;
            wire [(1<<LOW_BITS)-1:0]  low_out;

            // Split input
            wire [HIGH_BITS-1:0] high_in = in[INPUTS-1:LOW_BITS];
            wire [LOW_BITS-1:0]  low_in  = in[LOW_BITS-1:0];

            // High-level decode (recursive)
            MPS_decoder$ #(.INPUTS(HIGH_BITS)) u_high (
                .in(high_in),
                .out(high_out)
            );

            // Low-level decode (recursive)
            MPS_decoder$ #(.INPUTS(LOW_BITS)) u_low (
                .in(low_in),
                .out(low_out)
            );

            // ----- Buffer high_out: 1-stage (HIGH_FANOUT = 1<<LOW_BITS <= 8) -----
            wire [(1<<HIGH_BITS)-1:0] high_out_buf;
            genvar bi;
            for (bi = 0; bi < (1<<HIGH_BITS); bi = bi + 1) begin : GEN_HIGH_BUF
                bufferH16$ u_b (.out(high_out_buf[bi]), .in(high_out[bi]));
            end

            // ----- Buffer low_out: 1- or 2-stage based on LOW_FANOUT -----
            // Flat layout: low_out_buf[j*LOW_LEAVES + l] = bit j, leaf l.
            wire [(1<<LOW_BITS)*LOW_LEAVES-1:0] low_out_buf;
            genvar bj, bl;
            if (LOW_LEAVES == 1) begin : GEN_LOW_BUF1
                for (bj = 0; bj < (1<<LOW_BITS); bj = bj + 1) begin : g
                    bufferH16$ u_b (.out(low_out_buf[bj]), .in(low_out[bj]));
                end
            end else begin : GEN_LOW_BUF2
                wire [(1<<LOW_BITS)-1:0] low_out_s1;
                for (bj = 0; bj < (1<<LOW_BITS); bj = bj + 1) begin : g_s1
                    bufferH16$ u_s1 (.out(low_out_s1[bj]), .in(low_out[bj]));
                    for (bl = 0; bl < LOW_LEAVES; bl = bl + 1) begin : g_s2
                        bufferH16$ u_s2 (
                            .out(low_out_buf[bj*LOW_LEAVES + bl]),
                            .in(low_out_s1[bj])
                        );
                    end
                end
            end

            // ========================================================
            // Combine high and low using AND gates (using buffered outputs)
            // ========================================================
            genvar i, j;

            for (i = 0; i < (1 << HIGH_BITS); i = i + 1) begin : GEN_HIGH
                for (j = 0; j < (1 << LOW_BITS); j = j + 1) begin : GEN_LOW

                    localparam integer OUT_IDX  = (i << LOW_BITS) + j;
                    // For LOW_LEAVES==1, LEAF_IDX is always 0.
                    localparam integer LEAF_IDX = i / LEAF_GROUP;

                    MPS_AND_IN2 u_and (
                        .in0(high_out_buf[i]),
                        .in1(low_out_buf[j*LOW_LEAVES + LEAF_IDX]),
                        .out(out[OUT_IDX])
                    );

                end
            end

        end
    endgenerate

endmodule
