module ret_far_op(
    input uint32_t cs, //from resbuf
    input uint64_t stack_ptr, //stack pointer

    output uint64_t dr_o, //code segment
    output uint64_t sr_o //stack pointer

);

    assign dr_o = cs;
    assign sr_o = stack_ptr + 8;


endmodule