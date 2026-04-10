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
            // Error: decoder limited to 8 inputs maximum
            initial begin
                $fatal(1, "MPS_decoder$: INPUTS=%0d exceeds maximum of 8", INPUTS);
            end
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

            // ========================================================
            // Combine high and low using AND gates
            // ========================================================
            genvar i, j;

            for (i = 0; i < (1 << HIGH_BITS); i = i + 1) begin : GEN_HIGH
                for (j = 0; j < (1 << LOW_BITS); j = j + 1) begin : GEN_LOW

                    localparam integer OUT_IDX = (i << LOW_BITS) + j;

                    MPS_AND_IN2 u_and (
                        .in0(high_out[i]),
                        .in1(low_out[j]),
                        .out(out[OUT_IDX])
                    );

                end
            end

        end
    endgenerate

endmodule
