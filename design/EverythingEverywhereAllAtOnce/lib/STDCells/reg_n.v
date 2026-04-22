//-----------------------------------------------------------
// Parameterized N-bit Register
// --------------------------------
// Built from dff$ primitives (lib1.v).
//
// Ports:
//   clk  - rising-edge clock
//   we   - write enable, ACTIVE LOW  (0 = latch din, 1 = hold)
//   din  - data input  [WIDTH-1:0]
//   dout - data output [WIDTH-1:0]  (always valid, registered)
//
// Write-enable is implemented by feeding dout back to D when we=1,
// so the FF simply re-captures its own value each cycle (holds).
// When we=0, D = din and the new value is captured on the next
// rising clock edge.
//
// s and r on dff$ are tied high (deasserted) so no async preset/reset.
//-----------------------------------------------------------

module reg_n #(
    parameter WIDTH = 8
) (
    input  wire             clk,
    input  wire             we,       // active low: 0 = write, 1 = hold
    input  wire [WIDTH-1:0] din,
    output wire [WIDTH-1:0] dout
);

    wire         we_b;              // active-high write enable (~we)
    wire [WIDTH-1:0] hold_val;     // dout[i] gated by we
    wire [WIDTH-1:0] new_val;      // din[i]  gated by we_b
    wire [WIDTH-1:0] d_mux;        // D input to each DFF

    // Invert we to get active-high enable
    inv1$ u_inv_we (
        .out(we_b),
        .in (we)
    );

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : g_bits

            // Hold path: when we=1, pass dout[i] back to D
            and2$ u_hold (
                .out(hold_val[i]),
                .in0(we),
                .in1(dout[i])
            );

            // Write path: when we=0 (we_b=1), pass din[i] to D
            and2$ u_new (
                .out(new_val[i]),
                .in0(we_b),
                .in1(din[i])
            );

            // Merge the two paths
            or2$ u_mux (
                .out(d_mux[i]),
                .in0(hold_val[i]),
                .in1(new_val[i])
            );

            // D flip-flop: s=1 r=1 = normal clocking mode (no async set/reset)
            dff$ u_dff (
                .clk (clk),
                .d   (d_mux[i]),
                .q   (dout[i]),
                .qbar(),          // unused
                .r   (1'b1),      // active low reset, tied high (deasserted)
                .s   (1'b1)       // active low preset, tied high (deasserted)
            );

        end
    endgenerate

endmodule
