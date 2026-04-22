`ifndef MEM_CONTROLLER_MACROS_VH
`define MEM_CONTROLLER_MACROS_VH

// ============================================================================
// Structural Conversion Macros for mem_controller_structural.v
// ============================================================================
//
// These macros abstract away behavioral constructs (always_ff, always_comb)
// into parameterized structural building blocks. Each macro will eventually
// be replaced by a module instantiation or expanded into gate-level logic.
//
// Naming conventions:
//   REG_*        = sequential (flip-flop) macros
//   MUX_*        = multiplexer macros
//   DECODER_*    = decoder/selector macros
//   COMPARE_*    = comparator macros
// ============================================================================

// ----------------------------------------------------------------------------
// REG_RST_WE(inst, clk, rst, we, d, q, WIDTH)
// ----------------------------------------------------------------------------
// N-bit register with synchronous-reset and write-enable.
//   - On !rst: q <= 0
//   - On posedge clk when we=1: q <= d
//   - Otherwise: q holds
//
// Implementation: a mux selects between hold value (q), reset value (0),
// and new value (d) feeding into reg_n.  Priority: rst > we > hold.
//
// rst is active low. we is active high.
//
// Will be expanded into:
//   - inv1$ for rst inversion
//   - N-bit 2:1 mux (we ? d : q) -> d_we
//   - N-bit 2:1 mux (rst ? d_we : 0) -> d_final
//   - reg_n (WIDTH) with we tied low (always write) capturing d_final
// ----------------------------------------------------------------------------
`define REG_RST_WE(inst, clk, rst, we, d, q, WIDTH) \
    reg_rst_we #(.WIDTH(WIDTH)) inst ( \
        .clk(clk), .rst(rst), .we(we), .din(d), .dout(q) \
    )

// ----------------------------------------------------------------------------
// REG_RST(inst, clk, rst, d, q, WIDTH)
// ----------------------------------------------------------------------------
// N-bit register with synchronous-reset, always captures d.
//   - On !rst: q <= 0
//   - On posedge clk: q <= d
//
// Equivalent to REG_RST_WE with we permanently asserted.
// ----------------------------------------------------------------------------
`define REG_RST(inst, clk, rst, d, q, WIDTH) \
    reg_rst_we #(.WIDTH(WIDTH)) inst ( \
        .clk(clk), .rst(rst), .we(1'b1), .din(d), .dout(q) \
    )

// ----------------------------------------------------------------------------
// REG_RST_WE_RSTVAL(inst, clk, rst, we, d, q, WIDTH, RSTVAL)
// ----------------------------------------------------------------------------
// N-bit register with synchronous-reset to a specific value and write-enable.
//   - On !rst: q <= RSTVAL
//   - On posedge clk when we=1: q <= d
//   - Otherwise: q holds
// ----------------------------------------------------------------------------
`define REG_RST_WE_RSTVAL(inst, clk, rst, we, d, q, WIDTH, RSTVAL) \
    reg_rst_we_val #(.WIDTH(WIDTH), .RSTVAL(RSTVAL)) inst ( \
        .clk(clk), .rst(rst), .we(we), .din(d), .dout(q) \
    )

// ----------------------------------------------------------------------------
// MUX2_1B(inst, out, in0, in1, sel)
// ----------------------------------------------------------------------------
// 1-bit 2:1 mux. sel=0 -> in0, sel=1 -> in1
// Uses mux2$ from lib4.  Note: mux2$ outputs inverted (outb).
// We add an inverter to get true output.
// ----------------------------------------------------------------------------
`define MUX2_1B(inst, out, in0, in1, sel) \
    mux2_1b inst ( \
        .out(out), .in0(in0), .in1(in1), .sel(sel) \
    )

// ----------------------------------------------------------------------------
// MUX_N(inst, out, in0, in1, sel, WIDTH)
// ----------------------------------------------------------------------------
// N-bit 2:1 mux. sel=0 -> in0, sel=1 -> in1
// Built from WIDTH mux2_1b instances.
// ----------------------------------------------------------------------------
`define MUX_N(inst, out, in0, in1, sel, WIDTH) \
    mux_n #(.WIDTH(WIDTH)) inst ( \
        .out(out), .in0(in0), .in1(in1), .sel(sel) \
    )

// ----------------------------------------------------------------------------
// BIT_COMPARE_N(inst, eq, a, b, WIDTH)
// ----------------------------------------------------------------------------
// N-bit equality comparator. eq=1 when a == b.
// Built from XNOR + AND tree.
// ----------------------------------------------------------------------------
`define BIT_COMPARE_N(inst, eq, a, b, WIDTH) \
    bit_compare_n #(.WIDTH(WIDTH)) inst ( \
        .eq(eq), .a(a), .b(b) \
    )

// ----------------------------------------------------------------------------
// DECODER_ACTIVE(inst, sel, out, WIDTH)
// ----------------------------------------------------------------------------
// One-hot decoder: out[sel] = 1, all others = 0.
// WIDTH = number of output bits, sel is $clog2(WIDTH) bits.
// Used for bank selection from chipNum/bankGroup indices.
// ----------------------------------------------------------------------------
`define DECODER_ACTIVE(inst, sel, out, WIDTH) \
    decoder_onehot #(.WIDTH(WIDTH)) inst ( \
        .sel(sel), .out(out) \
    )

`endif
