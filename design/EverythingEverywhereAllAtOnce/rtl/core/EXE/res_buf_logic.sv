module res_buf_logic(
    input uint64_t res_info_i,
    input p_address_t st_addr_0,

    output byte_t res_buf[CACHE_LINES_SIZE_B*2];
);

//I think this will be a much bigger mess in structural so I kept its own module

logic [3:0] offset = st_addr_0[3:0];

always_comb begin
    //max could be moved to 12. will save us time in structural
    for(int i = 0; i < 8; i++)begin
        res_buf[i+offset] = res_info_i[i*8 +: 8]
    end

end



endmodule 