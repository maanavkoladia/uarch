module call_op(
    input uint64_t EIP,
    input uint64_t stack_ptr,
    output uint64_t dr_o,
    output uint64_t res_bus
);

    assign res_bus = {32'd0, EIP[31:0]};
    assign dr_o = {32'd0, (stack_ptr[31:0]-4)}; 



endmodule