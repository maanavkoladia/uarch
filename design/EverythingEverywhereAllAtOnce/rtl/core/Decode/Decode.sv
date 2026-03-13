module Decode (

    input wire clk,
    input wire rst,

    //for decoding instructions
    input idm_outputs_t idm_outs_i,
    input rr_outputs_t  rr_outs_i,


    output rr_latches_t rr_latches_next,
    output decode_outputs_t outs_o

);

endmodule
