module xchg_op(
    input  uint64_t srA, //AX or EAX or RM
    input uint64_t srB,   //r32
    input logic[3:0] data_size,
    output uint64_t res_buf,
    output uint64_t dr_o, //AX EAX RM
    output uint64_t sr_o //R32
);


    uint64_t new_eax_rm_val;
    uint64_t new_r32_val;

    assign new_eax_rm_val[7:0] = data_size[0] ? srB[7:0] : srA[7:0];
    assign new_eax_rm_val[15:8] = data_size[1] ? srB[15:8] : srA[15:8];
    assign new_eax_rm_val[31:16] = data_size[2] ? srB[31:16] : srA[31:16];

    assign new_r32_val[7:0] = data_size[0] ? srA[7:0] : srB[7:0];
    assign new_r32_val[15:8] = data_size[1] ? srA[15:8] : srB[15:8];
    assign new_r32_val[32:16] = data_size[2] ? srA[31:16] : srB[31:16];


    assign res_buf = {32'd0, new_eax_rm_val};
    assign dr_o = {32'd0, new_eax_rm_val};
    assign sr_o = {32'd0, new_r32_val};



endmodule
