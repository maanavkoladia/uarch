module res_buf_logic(
    input uint64_t res_info_i,
    input p_address_t st_addr_0,
    input uint16_t bit_vec_0,
    input uint16_t bit_vec_1,
    input byte_t ld_buf[CACHE_LINES_SIZE_B*2],

    output byte_t res_buf[CACHE_LINES_SIZE_B*2]
);

//I think this will be a much bigger mess in structural so I kept its own module

uint32_t bit_vect;
assign bit_vect = {bit_vec_1, bit_vec_0};

logic [3:0] offset;
assign offset = st_addr_0[3:0];

logic [7:0] offset_shifted;

logic [255:0] shifted_res_info;
always_comb begin
    shifted_res_info = 0;
    offset_shifted = 0;
    offset_shifted = offset << 3;
    shifted_res_info = res_info_i << offset_shifted;
end

always_comb begin
    res_buf = '{default: '0};
    //max could be moved to 12. will save us time in structural
    for(int i = 0; i < 32; i++)begin
        res_buf[i] = (bit_vect[i]) ? shifted_res_info[i*8 +: 8] : ld_buf[i];
    end
end




endmodule 