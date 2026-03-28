module mov_op(
    input uint64_t srA,
    input uint64_t srB,
    
    input logic[1:0] data_size,

    output uint64_t res_buf_o,
    output uint64_t dr_o
    //no flags 
);

    uint64_t merged_res;
    bool ld_16;
    bool ld_32;
    bool ld_64;
    assign ld_16 = data_size[0] | data_size[1];
    assign ld_32 = data_size[1];
    assign ld_64 = data_size[1] & data_size[0];


    assign merged_res[7:0] = srB[7:0];
    assign merged_res[15:8] = ld_16 ? srB[15:8] : srA[15:8];
    assign merged_res[31:16] = ld_32 ? srB[31:16] : srA[31:16];
    assign merged_res[63:32] = ld_64 ? srB[63:32] : srB[63:32];

    assign res_buf_o = srA;
    

endmodule

