module far_call_op(
    input uint32_t neip,
    input uint32_t segment, //should be the neip_segment thing 
    input uint64_t stack_ptr, //stack pointer 
    output uint64_t res_buf,
    output uint64_t sr_o
    
);

//call pusehs two things onto the stack and then the eip is updated via branch resolution
    assign res_buf = {16'd0, neip, segment[15:0]};
    assign sr_o = {32'd0, stack_ptr[31:0] - 6};

endmodule