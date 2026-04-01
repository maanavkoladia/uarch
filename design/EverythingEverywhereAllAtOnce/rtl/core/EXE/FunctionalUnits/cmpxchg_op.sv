module cmpxchg_op (
    input  uint32_t EAX, //passed in from EAX latch
    input  uint32_t rm,  //passed in from DR/BUF
    input  uint32_t r,  //passed in through SR
    input  logic [3:0] data_size,  // 2'b00=8b, 2'b01=16b, 2'b10=32b
    output uint64_t dr_o, 
    output uint64_t sr_o,  
    output uint64_t res_buf,
    output bool cancel_sr_we,
    output bool cancel_store,
    output bool cancel_dr_we,
    output bool ZF,
    output bool SF,
    output bool PF,
    output bool CF,
    output bool OF,
    output bool AF
);

    // Flags from CMP module
    logic cmp_ZF, cmp_SF, cmp_PF, cmp_CF, cmp_OF, cmp_AF;
    logic [63:0] lock_res, acc_res;

    // Instantiate CMP for flag calculation
    cmp u_cmp (
        .operand1(EAX),
        .operand2(rm),
        .data_size(data_size),
        .CF(cmp_CF),
        .AF(cmp_AF),
        .ZF(cmp_ZF),
        .SF(cmp_SF),
        .PF(cmp_PF),
        .OF(cmp_OF)
    );

    assign cancel_sr_we = cmp_ZF;
    assign cancel_store = ~cmp_ZF;
    assign cancel_dr_we = ~cmp_ZF;

    uint32_t next_EAX;
    assign next_EAX[7:0] = data_size[0] ? rm[7:0] : EAX[7:0];
    assign next_EAX[15:8] = data_size[1] ? rm[15:8] : EAX[15:8];
    assign next_EAX[31:16] = data_size[2] ? rm[31:16]: EAX[31:16];
    assign next_EAX[63:32] = 32'0;

    assign dr_o = r; //write to RM
    assign sr_o = next_EAX; //EAX write back
    // CMPXCHG semantics

    assign ZF = cmp_ZF;
    assign SF = cmp_SF;
    assign PF = cmp_PF;
    assign CF = cmp_CF;
    assign OF = cmp_OF;
    assign AF = cmp_AF; 
  
endmodule