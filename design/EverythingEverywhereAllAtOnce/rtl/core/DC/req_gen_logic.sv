module req_gen_logic(
    input bool valid,
    input bool LD_OP,
    input bool XCL,
    input bool dep_stall,

    input p_address_t ld_addr0,
    input p_address_t ld_addr1,

    output bool ld_addr_0_V,
    output bool ld_addr_1_V,

    output p_address_t ld_addr_0,
    output p_address_t ld_addr_1

);

    //pretty trivial.. keeping this file structure like this for when we convert to structural
    assign ld_addr_0 = ld_addr0;
    assign ld_addr_1 = ld_addr1;

    assign ld_addr_1_V = ~dep_stall & LD_OP & XCL & valid;
    assign ld_addr_0_V = ~dep_stall & LD_OP & valid;





endmodule