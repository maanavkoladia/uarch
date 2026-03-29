module ret_imm_op(
    input uint32_t stack_ptr,
    input uint32_t imm64
    //eip is sent to branch
    output uint64_t stack_ptr_o
);

    assign stack_ptr_o = stack_ptr + 4 + imm64[15:0];


endmodule