module ret_op(
    input uint64_t stack_ptr,
    output uint64_t sr_o
);

    assign sr_o = stack_ptr + 4;


endmodule   