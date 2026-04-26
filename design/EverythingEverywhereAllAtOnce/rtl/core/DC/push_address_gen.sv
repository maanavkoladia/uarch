module push_address_gen(
    input p_address_t ST_PADDR_0,
    input p_address_t ST_PADDR_1,
    input bool ST_XCL,
    input logic [1:0] data_size,
    input exe_cs_operation_type_e OP_TYPE,
    
    output p_address_t ST_PADDR_0_o,
    output p_address_t ST_PADDR_1_o,
    output bool ST_XCL_o
);

    //Stack grows down so input address is the "high address"
    //we need to find the low address using the data size
    //then we need to see if we now crossing cache line
    //this all only necessary if we are doing a push
    logic [3:0] num_bytes;
    p_address_t start_address;
    p_address_t end_address;
    assign end_address = ST_PADDR_0 - 1;

    always_comb begin
        // Map data_size to byte count
        if(OP_TYPE == FAR_CALL) num_bytes = 8;
        else num_bytes = (data_size[1]) ? 4 : 2;
    end
    assign start_address  = ST_PADDR_0 - num_bytes;

    assign ST_PADDR_0_o = (OP_TYPE == PUSH || OP_TYPE == FAR_CALL || OP_TYPE == CALL) ? start_address : ST_PADDR_0;
    assign ST_PADDR_1_o = (OP_TYPE == PUSH || OP_TYPE == FAR_CALL || OP_TYPE == CALL) ? (end_address & 15'h7FF0) : ST_PADDR_1;
    assign ST_XCL_o     = (OP_TYPE == PUSH || OP_TYPE == FAR_CALL || OP_TYPE == CALL) ? (start_address[4] ^ end_address[4]) : ST_XCL;


endmodule