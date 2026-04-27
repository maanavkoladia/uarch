module res_buf_logic(
    input uint64_t res_info_i,
    input byte_t ld_buf[EXE_BUFFER_SIZE],
    input uint16_t bit_vec_0,
    input uint16_t bit_vec_1,
    input p_address_t st_addr_0,

    output byte_t res_buf[CACHE_LINES_SIZE_B*2]
);

    //the input bit vectors are were data neesd to be written in the cache line
    logic [31:0] bit_vec_32;
    assign bit_vec_32 = {bit_vec_1, bit_vec_0};

    //where does our data we want to write to belong in the res buf
    logic [3:0] offset;
    assign offset = st_addr_0[3:0];

    logic [255:0] shifted_res_buf;

    //shift the input resbuf by the offset * byte size so it is aligned to where it needs to write
    always_comb begin
        shifted_res_buf = 256'(res_info_i) << (offset*8);
    end

    always_comb begin
        res_buf = '{default: '0};
        //now everythig is aligned and we know where we need to write and we know how many bytes of the resbuf we want to write.
        for(int i = 0; i < CACHE_LINES_SIZE_B*2 ; i++)begin
            res_buf[i] = bit_vec_32[i] ? shifted_res_buf[i*8 +: 8] : ld_buf[i];
        end
    end



endmodule