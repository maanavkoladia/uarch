import control_store_pkg::*;
module iretd_op(
    //eip gets taken care of in branch resolution 
    input uint32_t cs, //coming from the mem buffer 
    input uint32_t flags,     //from mem buffer
    input uint64_t stack_ptr, //ESP in SR

    output uint32_t dr_o,
    output uint32_t sr_o,
    //output uint32_t flags_o; I dont really know how other flags will change other than the main 6..
    output bool CF,
    output bool PF,
    output bool AF,
    output bool ZF,
    output bool SF,
    output bool OF
    
);

    assign dr_o = cs;
    assign sr_o = stack_ptr + 12;
    assign CF = flags[CF_IDX];
    assign PF = flags[PF_IDX];
    assign AF = flags[AF_IDX];
    assign ZF = flags[ZF_IDX];
    assign SF = flags[SF_IDX];
    assign OF = flags[OF_IDX];



endmodule