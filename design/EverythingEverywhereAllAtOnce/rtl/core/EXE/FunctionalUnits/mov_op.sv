module mov_op(
    input uint64_t srA,
    input uint64_t srB,
    
    input logic[3:0] data_size,

    output uint64_t res_buf_o,
    output uint64_t dr_o
    //no flags 
);

    uint64_t merged_res;
    //mov srB into srA
    assign merged_res[7:0] = data_size[0] ? srB[7:0] : srA[7:0];
    assign merged_res[15:8] = data_size[1] ? srB[15:8] : srA[15:8];
    assign merged_res[31:16] = data_size[2] ? srB[31:16] : srA[31:16];
    assign merged_res[63:32] = data_size[3] ? srB[63:32] : srA[63:32];

    assign res_buf_o = merged_res;
    assign dr_o = merged_res;
    

endmodule

