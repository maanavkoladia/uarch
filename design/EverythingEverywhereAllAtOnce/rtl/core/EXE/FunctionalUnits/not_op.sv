// NOT - Bitwise NOT Functional Unit
// Handles NOT8, NOT16, NOT32
// NOT does not affect any flags

import common_pkg::*;

module not_op(
    input  uint32_t srA,
    input logic[3:0] data_size,
    output uint32_t dr_o,
    output uintCL_t res_buf_o
); 


    uint32_t out_32;

    assign out_32 = ~srA;

    uint32_t merged_res;

    assign merged_res[7:0] =  data_size[0] ? out_32[7:0] : srA[7:0];
    assign merged_res[15:8] = data_size[1] ? out_32[15:7] : srA[15:8];
    assign merged_res[31:16] = data_size[2]? out_32[31:16] : srA[31:16];

    assign res_buf = {32'h0, merged_res};
    assign dr_o = {32'h0, merged_res};



endmodule
