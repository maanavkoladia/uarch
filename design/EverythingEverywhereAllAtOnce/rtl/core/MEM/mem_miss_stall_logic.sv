module mem_miss_stall_logic(
    input valid,
    input bool LD_XCL,
    input bool LD_OP,
    input bool hit0,
    input bool hit1,
    input bool hit_MIO,
    input MIO,

    output miss_stall
);


    bool xcl_miss;
    bool ld_miss;
    bool mio_miss;

    assign mio_miss = MIO & ~hit_MIO;
    assign ld_miss =  LD_OP & ~hit0;
    assign xcl_miss = LD_OP & LD_XCL & ~hit1;

    assign miss_stall = (mio_miss | ld_miss | xcl_miss) & valid; 


endmodule