import Fetch_pkg::*;
import Predictor_pkg::*;

module Predictor (
    input clk,
    input rst,
    input  predictor_input_t inputs,
    output predictor_output_t outputs
);

    // Instantiate BTFN predictor
    // BTFN btfn_inst (
    //     .inputs(inputs),
    //     .outputs(outputs)
    // );

    GShare gshare_inst(
        .clk(clk),
        .rst(rst),
        .inputs(inputs),
        .outputs(outputs)
    );

endmodule
