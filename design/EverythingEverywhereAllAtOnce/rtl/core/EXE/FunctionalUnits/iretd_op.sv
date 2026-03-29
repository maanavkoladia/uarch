module iretd_op(
    //eip gets taken care of in branch resolution 
    input uint32_t cs, //coming from the mem buffer 
    input uint32_t flags, //from mem buffer
    input uint64_t stack_ptr, //ESP

    output uint32_t cs_o,
    output uint32_t stack_ptr_o,
    output uint32_t flags_o;
);

    assign cs_o = cs;
    assign stack_ptr_o = stack_ptr + 12;
    assign flags_o = flags;




endmodule