module BTFN (
    input  btfn_inputs_t inputs,
    output btfn_output_t outputs
);
    import BTFN_Types::*;
    assign outputs.taken = inputs.btfn_target < inputs.spc;
endmodule
