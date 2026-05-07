module cmpxchg_op (
    input  uint32_t EAX, //passed in from EAX latch
    input  uint64_t rm,  //passed in from DR/BUF
    input  uint32_t r,  //passed in through SR
    input  logic [3:0] data_size,  // 2'b00=8b, 2'b01=16b, 2'b10=32b
    input logic [3:0] sr_data_size_vec,
    output uint64_t dr_o,
    output uint64_t EAX_o,
    output uint64_t res_buf,
    output bool ZF,
    output bool SF,
    output bool PF,
    output bool CF,
    output bool OF,
    output bool AF
);

    // Flags from CMP module
    logic cmp_ZF, cmp_SF, cmp_PF, cmp_CF, cmp_OF, cmp_AF;

    // Instantiate CMP for flag calculation
    cmp u_cmp (
        .srA({32'd0, EAX}),
        .srB({32'd0,rm[31:0]}),
        .data_size(data_size),
        .CF(cmp_CF),
        .AF(cmp_AF),
        .ZF(cmp_ZF),
        .SF(cmp_SF),
        .PF(cmp_PF),
        .OF(cmp_OF)
    );


    uint32_t next_dr_o;

    byte_t rm_low;
    assign rm_low = data_size[0] ? rm[7:0] : rm[15:8];  //04
 
    //AH will only change on 16 never on 8 bit size
    uint32_t next_EAX;
    assign next_EAX[7:0] = rm_low;
    assign next_EAX[15:8] = (data_size[1]  && data_size[0]) ? rm[15:8] : EAX[15:8];
    assign next_EAX[31:16] =  data_size[2] ? rm[31:16]: EAX[31:16];



    byte_t r_low;
    byte_t r_upper;
    assign r_low = sr_data_size_vec[0] ? r[7:0] : r[15:8];
    assign r_upper = sr_data_size_vec[1] ? r[15:8] : r[7:0];
    //AH and AL can both  be swapped on 8 bit size 
    assign next_dr_o[7:0] = data_size[0] ? r_low : rm[7:0];
    assign next_dr_o[15:8] = data_size[1] ? r_upper : rm[15:8];
    assign next_dr_o[31:16] = data_size[2] ? r[31:16] : rm[31:16];

    assign EAX_o = ~cmp_ZF ? next_EAX : EAX;
    assign dr_o = cmp_ZF ? next_dr_o : rm;
    assign res_buf = cmp_ZF ? next_dr_o : rm;


    assign ZF = cmp_ZF;
    assign SF = cmp_SF;
    assign PF = cmp_PF;
    assign CF = cmp_CF;
    assign OF = cmp_OF;
    assign AF = cmp_AF;
  
endmodule