// ============================================================================
// Structural helper cells for mem_controller_structural.v
// ============================================================================
// These modules implement the macro interfaces from mem_controller_macros.vh
// using only gate-level primitives (lib1-lib6) and reg_n / reg1b.
// ============================================================================

// ----------------------------------------------------------------------------
// mux2_1b : 1-bit 2:1 mux (true output)
// sel=0 -> out=in0, sel=1 -> out=in1
// mux2$ gives outb (inverted), so we invert.
// ----------------------------------------------------------------------------
module mux2_1b (
    output wire out,
    input  wire in0,
    input  wire in1,
    input  wire sel
);
    wire outb;
    mux2$ u_mux (.outb(outb), .in0(in0), .in1(in1), .s0(sel));
    inv1$ u_inv (.out(out), .in(outb));
endmodule

// ----------------------------------------------------------------------------
// mux_n : N-bit 2:1 mux
// sel=0 -> out=in0, sel=1 -> out=in1
// ----------------------------------------------------------------------------
module mux_n #(
    parameter WIDTH = 1
) (
    output wire [WIDTH-1:0] out,
    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1,
    input  wire             sel
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : g_mux
            mux2_1b u_mux (
                .out(out[i]), .in0(in0[i]), .in1(in1[i]), .sel(sel)
            );
        end
    endgenerate
endmodule

// ----------------------------------------------------------------------------
// reg_rst_we : N-bit register, active-low sync reset to 0, active-high WE
// Priority: rst (active low) overrides we.
//   !rst          -> q <= 0
//   rst & we      -> q <= din
//   rst & !we     -> q <= q (hold)
// 
// Implementation:
//   d_we   = we ? din : q       (write-enable mux)
//   d_final= rst ? d_we : 0     (reset mux, rst active low so !rst -> 0)
//   reg_n always captures d_final (we tied low = always write)
// ----------------------------------------------------------------------------
module reg_rst_we #(
    parameter WIDTH = 1
) (
    input  wire             clk,
    input  wire             rst,   // active low
    input  wire             we,    // active high
    input  wire [WIDTH-1:0] din,
    output wire [WIDTH-1:0] dout
);
    wire [WIDTH-1:0] d_we;
    wire [WIDTH-1:0] d_final;

    // we mux: we=1 -> din, we=0 -> dout (hold)
    mux_n #(.WIDTH(WIDTH)) u_we_mux (
        .out(d_we), .in0(dout), .in1(din), .sel(we)
    );

    // rst mux: rst=1 -> d_we (normal), rst=0 -> 0 (reset)
    mux_n #(.WIDTH(WIDTH)) u_rst_mux (
        .out(d_final), .in0({WIDTH{1'b0}}), .in1(d_we), .sel(rst)
    );

    // reg_n with we=0 (active low = always write)
    reg_n #(.WIDTH(WIDTH)) u_reg (
        .clk(clk), .we(1'b0), .din(d_final), .dout(dout)
    );
endmodule

// ----------------------------------------------------------------------------
// reg_rst_we_val : N-bit register, active-low sync reset to RSTVAL, active-high WE
// Same as reg_rst_we but resets to RSTVAL instead of 0.
// ----------------------------------------------------------------------------
module reg_rst_we_val #(
    parameter WIDTH  = 1,
    parameter [WIDTH-1:0] RSTVAL = {WIDTH{1'b0}}
) (
    input  wire             clk,
    input  wire             rst,   // active low
    input  wire             we,    // active high
    input  wire [WIDTH-1:0] din,
    output wire [WIDTH-1:0] dout
);
    wire [WIDTH-1:0] d_we;
    wire [WIDTH-1:0] d_final;

    mux_n #(.WIDTH(WIDTH)) u_we_mux (
        .out(d_we), .in0(dout), .in1(din), .sel(we)
    );

    mux_n #(.WIDTH(WIDTH)) u_rst_mux (
        .out(d_final), .in0(RSTVAL), .in1(d_we), .sel(rst)
    );

    reg_n #(.WIDTH(WIDTH)) u_reg (
        .clk(clk), .we(1'b0), .din(d_final), .dout(dout)
    );
endmodule

// ----------------------------------------------------------------------------
// bit_compare_n : N-bit equality comparator
// eq = 1 when a == b
// Built from XNOR per-bit + AND reduction tree.
// ----------------------------------------------------------------------------
module bit_compare_n #(
    parameter WIDTH = 1
) (
    output wire eq,
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b
);
    wire [WIDTH-1:0] match;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : g_xnor
            xnor2$ u_xnor (.out(match[i]), .in0(a[i]), .in1(b[i]));
        end
    endgenerate

    // AND reduction tree
    // For simplicity, use a generate-based cascaded AND chain.
    wire [WIDTH:0] and_chain;
    assign and_chain[0] = 1'b1;

    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : g_and
            and2$ u_and (.out(and_chain[i+1]), .in0(and_chain[i]), .in1(match[i]));
        end
    endgenerate

    assign eq = and_chain[WIDTH];
endmodule

// ----------------------------------------------------------------------------
// decoder_onehot : one-hot decoder
// out[sel] = 1, all other bits = 0
// SELW = $clog2(WIDTH)
// 
// Uses nested AND/INV tree. For our use cases (WIDTH=16 chips, 8 groups, 64 banks)
// this builds a proper decoder.
// ----------------------------------------------------------------------------
module decoder_onehot #(
    parameter WIDTH = 4
) (
    input  wire [$clog2(WIDTH)-1:0] sel,
    output wire [WIDTH-1:0]         out
);
    localparam SELW = $clog2(WIDTH);

    // Generate inverted sel bits
    wire [SELW-1:0] sel_inv;
    genvar s;
    generate
        for (s = 0; s < SELW; s = s + 1) begin : g_inv_sel
            inv1$ u_inv (.out(sel_inv[s]), .in(sel[s]));
        end
    endgenerate

    // For each output bit, AND together the appropriate sel/sel_inv
    // When bit k of output index j is 1, we need sel[k]; when 0, sel_inv[k].
    // Since j is a genvar (elaboration-time constant), we use generate-if
    // to select the correct wire structurally.
    genvar j;
    generate
        for (j = 0; j < WIDTH; j = j + 1) begin : g_decode
            wire [SELW:0] bit_chain;
            assign bit_chain[0] = 1'b1;

            genvar k;
            for (k = 0; k < SELW; k = k + 1) begin : g_bit
                wire match_bit;
                if (((j >> k) & 1) == 1) begin : g_use_sel
                    assign match_bit = sel[k];
                end else begin : g_use_inv
                    assign match_bit = sel_inv[k];
                end
                and2$ u_and (.out(bit_chain[k+1]), .in0(bit_chain[k]), .in1(match_bit));
            end

            assign out[j] = bit_chain[SELW];
        end
    endgenerate
endmodule
