// Structural Verilog 2005 port of Predictor.
// Reference SV: rtl/core/Fetch/structural/Predictor.sv (original).
//
// Wraps the active predictor (currently GShare; BTFN is left commented out
// in the SV reference). The btfn_target / exe_br_target fields of the
// original predictor_input_t are not consumed by GShare and are dropped here.
// If you swap the body to BTFN, plumb btfn_target back through.

module Predictor (
    input  wire        clk,
    input  wire        rst,           // active low

    input  wire [31:0] spc,
    input  wire        btb_hit,

    input  wire        exe_br_valid,
    input  wire        exe_br_taken,
    input  wire [31:0] exe_br_eip,
    input  wire        misprediction,

    output wire        taken
);

    GShare gshare_inst (
        .clk          (clk),
        .rst          (rst),
        .spc          (spc),
        .btb_hit      (btb_hit),
        .exe_br_valid (exe_br_valid),
        .exe_br_taken (exe_br_taken),
        .exe_br_eip   (exe_br_eip),
        .misprediction(misprediction),
        .taken        (taken)
    );

endmodule
