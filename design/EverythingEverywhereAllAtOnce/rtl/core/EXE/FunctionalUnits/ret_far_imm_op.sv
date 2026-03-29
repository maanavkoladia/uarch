module ret_far_imm(
    input uint32_t cs, //from res buf
    input uint32_t stack_ptr, //from reg
    output uint64_t imm64, //stack pointer
    output uint64_t cs_o //cs
);

    assign cs_o = cs;
    assign stack_ptr_o = stack_ptr + 8 + imm64[15:0];


endmodule