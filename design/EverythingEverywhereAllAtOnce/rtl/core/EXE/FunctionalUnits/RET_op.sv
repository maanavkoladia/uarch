module RET_op{
    input uint64_t stack_ptr,
    output uint64_t stack_ptr_o
};

    assign stack_ptr_o = stack_ptr + 4;


endmodule