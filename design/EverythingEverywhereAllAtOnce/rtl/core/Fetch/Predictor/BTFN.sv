module BTFN (
    input  predictor_inputs_t inputs,
    output predictor_output_t outputs
);
    import Predictor_pkg::*;

    assign outputs.taken = inputs.btfn_target < inputs.spc;
endmodule
