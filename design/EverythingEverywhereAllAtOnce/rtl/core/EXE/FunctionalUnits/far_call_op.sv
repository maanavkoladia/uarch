module far_call_op(
    input uint32_t neip,
    input uint32_t segment, //should be the neip_segment thing 
    input uint64_t stack_ptr, //stack pointer
    input uint32_t new_cs,
    output uint64_t res_buf,
    output uint64_t dr_o,
    output uint64_t sr_o
);

//call pusehs two things onto the stack and then the eip is updated via branch resolution
    assign res_buf = {{16'd0, segment[15:0]}, neip};
    assign sr_o = {32'd0, stack_ptr[31:0] - 8};
    assign dr_o = {32'd0, new_cs};

endmodule