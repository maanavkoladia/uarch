module push_address_gen(
    input p_address_t ST_PADDR_0,
    input p_address_t ST_PADDR_1,
    input bool ST_XCL,
    input logic [3:0] data_size_vec,
    input exe_cs_operation_type_e OP_TYPE,
    
    output ST_PADDR_0_o,
    output ST_PADDR_1_o,
    output ST_XCL_o
);

    //Stack grows down so input address is the "high address"
    //we need to find the low address using the data size
    //then we need to see if we now crossing cache line
    //this all only necessary if we are doing a push
    logic [2:0] num_bytes;
    p_address_t low_address;

    always_comb begin
        // Map data_size to byte count
        case (data_size_vec)
            4'b0001: num_bytes = 4'd2; // AL
            4'b0010: num_bytes = 4'd2; // AH
            4'b0011: num_bytes = 4'd2; // AX
            4'b0111: num_bytes = 4'd4; // EAX
            4'b1111: num_bytes = 4'd8; // RAX
            default: num_bytes = 4'd0;
        endcase
    end
    assign low_address  = ST_PADDR_0 - num_bytes;

    assign ST_PADDR_0_o = (OP_TYPE == PUSH) ? low_address : ST_PADDR_0;
    assign ST_PADDR_1_o = (OP_TYPE == PUSH) ? ST_PADDR_0 & 15'h000F : ST_PADDR_1;
    assign ST_XCL       = (OP_TYPE == PUSH) ? (low_address[4] ^ ST_PADDR_0[4]) : ST_XCL;


endmodule