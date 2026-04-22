module mov_op(
    input uint64_t srA,
    input uint64_t srB,

    input logic[3:0] data_size,
    input exe_cs_operation_type_e op_type,
    input bool curr_cf_flag,
    output uint64_t res_buf_o,
    output uint64_t dr_o
    //no flags
);

    logic [3:0] masked_data_size;
    //we only cancel a move if it is cmovc and the cf flag is not set
    assign masked_data_size = (op_type == CMOVC && ~curr_cf_flag) ? 4'b0000 : data_size;

    uint64_t merged_res;
    //mov srB into srA
    assign merged_res[7:0] = masked_data_size[0] ? srB[7:0] : srA[7:0];
    assign merged_res[15:8] = masked_data_size[1] ? srB[15:8] : srA[15:8];
    assign merged_res[31:16] = masked_data_size[2] ? srB[31:16] : srA[31:16];
    assign merged_res[63:32] = masked_data_size[3] ? srB[63:32] : srA[63:32];

    assign res_buf_o = merged_res;
    assign dr_o = merged_res;
    

endmodule

