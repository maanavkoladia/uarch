module ICache_DataStore (

    input wire en,  //active high
    input v_address_t v_addr_i,
    input p_address_t p_addr_i,


    //output the line evition line to write to IC_SWAP_BUF
    input bool LD_IC_SWAP_BUF,

    input bool fill0_i,
    input bool fill1_i,
    input bool fill2_i,
    input bool fill3_i,

    input bool busy,

    //rd in ld_From_I_VC_Swap
    input bool ld_From_I_VC_Swap,
    input swap_buf_t I_VC_SwapBuf_i,

    output byte_t currLines[CACHE_LINES_SIZE_B]

);

    logic [ICACHE_INDEX_WIDTH - 1 : 0] v_addr_i_index = v_addr_i[ICACHE_INDEX_UB : ICACHE_INDEX_LB];



endmodule
