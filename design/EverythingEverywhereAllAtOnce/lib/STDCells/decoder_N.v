module MPS_decoder$ #(
    parameter INPUTS = 2
) (
    input  wire [INPUTS-1:0] in,
    output wire [(1 << INPUTS)-1:0] out
);

    // ============================================================
    // Base cases
    // ============================================================
    generate
        if (INPUTS == 2) begin : GEN_DEC2
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
            // Recursive split: use a 3-bit decoder as building block
            // ========================================================
            localparam integer HIGH_BITS = INPUTS - 3;
            localparam integer LOW_BITS  = 3;

            wire [(1<<HIGH_BITS)-1:0] high_out;
            wire [(1<<LOW_BITS)-1:0]  low_out;

            // Split input
            wire [HIGH_BITS-1:0] high_in = in[INPUTS-1:3];
            wire [LOW_BITS-1:0]  low_in  = in[2:0];

            // High-level decode (recursive)
            MPS_decoder$ #(.INPUTS(HIGH_BITS)) u_high (
                .in(high_in),
                .out(high_out)
            );

            // Low-level decode (3 → 8)
            decoder3_8$ u_low (
                .SEL(low_in),
                .Y(low_out),
                .YBAR()
            );

            // ========================================================
            // Combine high and low using AND gates
            // ========================================================
            genvar i, j;

            for (i = 0; i < (1 << HIGH_BITS); i = i + 1) begin : GEN_HIGH
                for (j = 0; j < 8; j = j + 1) begin : GEN_LOW

                    localparam integer OUT_IDX = (i << 3) + j;

                    if (OUT_IDX < (1 << INPUTS)) begin : VALID

                        MPS_AND_IN2 u_and (
                            .in0(high_out[i]),
                            .in1(low_out[j]),
                            .out(out[OUT_IDX])
                        );

                    end

                end
            end

        end
    endgenerate

endmodule
