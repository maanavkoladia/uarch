// ======================================================================
// Structural SV : counter
// Tool          : sv2rtl.py  (auto-generated)
// Source        : counter.sv
// ======================================================================

module counter (
    input   wire        clk_i,
    input   wire        rst_i,
    input   wire [9:0] interrupt_val_i,
    input   wire        interrupt_clr_i,
    output  wire [9:0] timerVal_o,
    output  wire        interrupt_o
);

// Internal wires
wire [9:0] _add_4;
wire        _const_12;
wire        _const_15;
wire [9:0] _const_2;
wire        _const_20;
wire [9:0] _const_8;
wire        _cout_3;
wire        _eq_0;
wire        _inv_18;
wire        _inv_6;
wire        _mux_13;
wire        _mux_16;
wire        _mux_21;
wire [9:0] _mux_9;
wire        conditionMet;
wire        interrupt_bit;
wire [9:0] timerVal;

// Logic signals (driven by reg primitives or assign)

// ── Combinational primitives & FF logic ─────────────────────────────

assign timerVal_o = timerVal;
assign interrupt_o = interrupt_bit;
eq_10$ _eq10_1 (.a(timerVal), .b(interrupt_val_i), .eq(_eq_0));
assign conditionMet = _eq_0;
assign _const_2 = 10'h001;  // 1
add_10$ _add10_5 (.a(timerVal), .b(_const_2), .s(_add_4), .cout(_cout_3));
inv_1$ _inv1_7 (.a(rst_i), .y(_inv_6));
assign _const_8 = 10'h000;  // 0
mux_10$ _mux10_10 (.sel(_inv_6), .a(_const_8), .b(_add_4), .y(_mux_9));
reg_10$ _reg10_11 (.clk(clk_i), .rst(1'b1), .d(_mux_9), .q(timerVal));
assign _const_12 = 1'h0;  // 0
mux_1$ _mux1_14 (.sel(interrupt_clr_i), .a(_const_12), .b(interrupt_bit), .y(_mux_13));
assign _const_15 = 1'h1;  // 1
mux_1$ _mux1_17 (.sel(conditionMet), .a(_const_15), .b(_mux_13), .y(_mux_16));
inv_1$ _inv1_19 (.a(rst_i), .y(_inv_18));
assign _const_20 = 1'h0;  // 0
mux_1$ _mux1_22 (.sel(_inv_18), .a(_const_20), .b(_mux_16), .y(_mux_21));
reg_1$ _reg1_23 (.clk(clk_i), .rst(1'b1), .d(_mux_21), .q(interrupt_bit));

endmodule
