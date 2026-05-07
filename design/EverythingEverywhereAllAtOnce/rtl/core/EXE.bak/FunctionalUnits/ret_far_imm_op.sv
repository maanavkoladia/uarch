module ret_far_imm(
    input uint32_t cs, //from res buf
    input uint64_t stack_ptr, //from sr reg
    input uint64_t imm64, 
    output uint64_t dr_o, //cs value into dr
    output uint64_t sr_o //stack pointer into sr
);

    assign dr_o = cs;
    assign sr_o = stack_ptr + 8 + imm64[15:0];


endmodule   