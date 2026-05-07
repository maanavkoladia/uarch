module exp_call_op(
    input uint64_t idt, //wired directly in?
    input l_address_t eip, //alu input sel A SEGMENT_EIP
    input uint32_t curr_cs, //srA
    input uint64_t stack_ptr, //alu input sel B = SR_REGISTER
    output uint64_t res_buf, //old cs and old eip
    output uint64_t dr_o, //new cs
    output uint64_t sr_o, //stack pointer updated
    output uint32_t exp_eip //to br_res
);

    uint16_t new_cs;
    assign new_cs = idt[31:16];
    assign exp_eip = {idt[63:48], idt[15:0]};


//call pusehs two things onto the stack and then the eip is updated via branch resolution
    assign res_buf = {{16'd0, curr_cs[15:0]}, eip[31:0]};
    assign sr_o = {32'd0, stack_ptr[31:0] - 8};
    assign dr_o = {48'd0, new_cs};

endmodule