module iretd_op(
    //eip gets taken care of in branch resolution 
    input uint32_t cs, //coming from the mem buffer 
    input uint32_t flags,     //from mem buffer
    input uint64_t stack_ptr, //ESP in SR

    output uint32_t dr_o,
    output uint32_t sr_o,
    output uint32_t flags_o;
);

    assign dr_o = cs;
    assign sr_o = stack_ptr + 12;
    assign flags_o = flags;




endmodule