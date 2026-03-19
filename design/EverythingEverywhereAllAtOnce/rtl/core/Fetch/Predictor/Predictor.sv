import Fetch_pkg::*;
import Predictor_pkg::*;

module Predictor (
    input  predictor_input_t inputs,
    output predictor_output_t outputs
);

    // Instantiate BTFN predictor
    BTFN btfn_inst (
        .inputs(inputs),
        .outputs(outputs)
    );

endmodule
