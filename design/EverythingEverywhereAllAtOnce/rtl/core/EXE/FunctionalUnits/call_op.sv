module call_op(
    input uint64_t EIP,
    input uint64_t stack_ptr,
    output uint64_t sr_o,
    output uint64_t res_buf
);

    assign res_buf = {32'd0, EIP[31:0]};
    assign sr_o = {32'd0, (stack_ptr[31:0]-4)}; 



endmodule