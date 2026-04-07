module bit_vec_logic(
    input  p_address_t st_addr_0,
    input  logic       ST_XCL,
    input  logic [3:0] data_size, 
    
    output uint16_t    st_vec0,
    output uint16_t    st_vec1
);

    logic [3:0] num_bytes;
    logic [3:0] start_offset;
    assign start_offset = st_addr_0[3:0];

    //currently wrong does not account for the shift by AH right now
    always_comb begin
        // Map data_size to byte count
        case (data_size)
            4'b0001: num_bytes = 4'd1; // AL
            4'b0010: num_bytes = 4'd1; // AH
            4'b0011: num_bytes = 4'd2; // AX
            4'b0111: num_bytes = 4'd4; // EAX
            4'b1111: num_bytes = 4'd8; // RAX
            default: num_bytes = 4'd0;
        endcase

        st_vec0 = 0;
        st_vec1 = 0;

        if (ST_XCL) begin
            // Crosses boundary: 
            // vec0 sets all bits from start_offset to the end of line (index 15)
            st_vec0 = 16'hFFFF << start_offset;
            // vec1 sets the remaining bits starting from index 0
            // (Total bytes - bytes already in vec0)
            st_vec1 = (16'h1 << (num_bytes - (16 - start_offset))) - 1;
        end 
        else begin
            // Stays in one line: Shift a mask of 'num_bytes' length to start_offset
            st_vec0 = ((16'h1 << num_bytes) - 1) << start_offset;
        end
    end

endmodule
