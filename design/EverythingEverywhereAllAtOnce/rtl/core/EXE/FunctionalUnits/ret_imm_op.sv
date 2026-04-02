module ret_imm_op(
    input uint64_t imm64,
    input uint64_t stack_ptr,
    
    //eip is sent to branch
    output uint64_t sr_o
);

    assign sr_o = stack_ptr + 4 + imm64[15:0];


endmodule