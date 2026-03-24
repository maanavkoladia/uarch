import Fetch_pkg::*;
import Predictor_pkg::*;

module BTFN (
    input  predictor_input_t inputs,
    output predictor_output_t outputs
);

    assign outputs.taken = inputs.btfn_target < inputs.spc;
endmodule
