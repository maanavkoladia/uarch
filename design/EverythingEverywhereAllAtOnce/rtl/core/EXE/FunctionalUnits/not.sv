// NOT - Bitwise NOT Functional Unit
// Handles NOT8, NOT16, NOT32
// NOT does not affect any flags

import common_pkg::*;

module not(
    input  uint32_t srA,
    input logic[1:0] data_size,
    output uint32_t dr_o,
    output uint32_t res_buf_o,
    output uint32_t flags
); 

    bool ld_16;
    bool ld_32; 

    uint32_t out_32;

    assign out_32 = ~srA;
    assign ld_16 = data_size[0] | data_size[1];
    assign ld_32 = data_size[1];


    assign dr_o[7:0] = out_32[7:0];
    assign dr_o[15:8] = ld_16 ? out_32[15:7] : srA[15:8];
    assign dr_o[31:16] = ld_32 ? out_32[31:16] : srA[31:16];

    assign flags = '0;



endmodule
