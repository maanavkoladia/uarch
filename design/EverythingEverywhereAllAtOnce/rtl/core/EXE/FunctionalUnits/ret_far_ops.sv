module ret_far_op(
    input uint32_t cs, //from resbuf
    input uint64_t stack_ptr, //stack pointer

    output uint64_t cs_o,
    output uint64_t next_ptr_o

);

    assign cs_o = cs;
    assign next_ptr_o = stack_ptr + 8;


endmodule