module decode_gp_gen (
    input uint32_t prev_eip,
    input logic [3:0] prev_length,
    input uint32_t segLimit,

    output bool gp_fault_o
);
    uint32_t l_addr_o;
    assign l_addr_o = prev_eip + prev_length - 1;     //to check if the inst is out of bounds
    //-1 to find end of inst vs start of next
    
    assign gp_fault_o = l_addr_o > segLimit;

endmodule

