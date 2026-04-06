module req_gen_logic(
    input bool valid,
    input bool LD_OP,
    input bool XCL,
    input bool dep_stall,
    input bool MIO,

    input p_address_t ld_addr0,
    input p_address_t ld_addr1,

    output bool ld_addr_0_V,
    output bool ld_addr_1_V,

    output p_address_t ld_addr_0,
    output p_address_t ld_addr_1

);

    //if there is a dep stall then we dont want to send any requests 

    //pretty trivial.. keeping this file structure like this for when we convert to structural
    assign ld_addr_0 = ld_addr0 & 32'hFFFFFFF0;
    //load address cache aligned
    assign ld_addr_1 = ld_addr1 & 32'hFFFFFFF0; 
    assign ld_addr_1_V = ~dep_stall & LD_OP & XCL & valid & ~MIO; 
    assign ld_addr_0_V = ~dep_stall & LD_OP & valid & ~MIO;





endmodule