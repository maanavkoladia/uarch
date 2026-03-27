module bit_vec_logic(
    input p_address_t st_addr_0,
    input bool ST_XCL,
    input logic[1:0] data_size,
    
    output uint16_t st_vec0,
    output uint16_t st_vec1
);

    uint16_t st_end;
    logic [3:0] num_bytes;
    assign num_bytes = 1<<data_size;
    //00 --> 1 byte
    //01 --> 2 bytes
    //10 --> 4 bytes
    //11 --> 8 bytes

    always_comb begin
        st_end = st_addr_0 + (8<<data_size);
        st_vec1 = 0;
        if(ST_XCL)begin
            st_vec1 = (1 << st_end[3:0]) - 1;
            st_vec0 = ((1 << (16-st_addr_0[3:0])) - 1)<<st_addr_0[3:0];
        end
        else begin
            st_vec0 = ((1<<num_bytes) - 1)<<st_addr_0[3:0];
        end

    end


endmodule