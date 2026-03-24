module RR (
    input wire clk,
    input wire rst,
    //actual stage latches needed
    input rr_latches_t latches_i,
    //for pipeclear when exp is about to be served and ROM loaded into IDM
    input fetch_outputs_t fetch_outs_i,
    //decode gp
    input decode_outputs_t decode_outs_i,
    //only used for valid
    input dc_outputs_t dc_outs_i,
    //only used for valid logic
    input mem_outputs_t mem_outs_i,
    //only use for valid logic
    input exe_outputs_t exe_outs_i,
    //used for sb clearing and for valid logic
    input wb_outputs_t wb_outs_i,

    //next latches
    output dc_latches_t dc_latches_next,
    output rr_outputs_t outs_o
);

    //regfile_inputs_t reg_in;
    //regfile_outputs_t reg_out;

endmodule

