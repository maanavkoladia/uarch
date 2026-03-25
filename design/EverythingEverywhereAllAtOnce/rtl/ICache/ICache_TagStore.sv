module ICache_TagStore (
    input wire clk,
    input wire rst,

    input wire en,  //active high
    input v_address_t v_addr_i,
    input p_address_t p_addr_i,
    input bool ld_From_I_VC_Swap,
    input bool LD_IC_SWAP_BUF,
    input bool fill3_i,
    input bool busy,
    input swap_buf_t I_VC_SwapBuf_i,

    output [ICACHE_TAG_WIDTH - 1:0] currTag_o,
    output bool currLine_V
);

    localparam int NUM_CELLS = 2;

    // VIPT: Virtual address for INDEX, Physical address for TAG
    logic [ICACHE_INDEX_WIDTH - 1 : 0] v_addr_i_index = v_addr_i[ICACHE_INDEX_UB : ICACHE_INDEX_LB];
    logic [ICACHE_TAG_WIDTH - 1 : 0] p_addr_i_tag = p_addr_i[ICACHE_TAG_UB : ICACHE_TAG_LB];

    bool validStore[NUM_ICACHE_LINES];

    // Use virtual address for indexing into tag store (VIPT)
    // Lower bits select the RAM cell address, MSB selects which of the 2 RAM cells
    logic [ICACHE_INDEX_WIDTH - 1 - 1 : 0] ADDRESS_2_TagStore;
    assign ADDRESS_2_TagStore = v_addr_i_index[ICACHE_INDEX_WIDTH-1-1 : 0];
    logic tagCellOutSel = v_addr_i_index[ICACHE_INDEX_WIDTH-1];

    //comes from p_addr upper index bit

    //index with upper idx bit from p_addr and use if fill0
    //cases to write is
    //reading from swap buf,
    //or from bus, in which case the
    //address comes from p_addr
    logic WR_2_TagStore[NUM_CELLS];
    assign WR_2_TagStore[0] = !tagCellOutSel && (fill3_i || ld_From_I_VC_Swap) && en ? 0 : 1;
    assign WR_2_TagStore[1] = tagCellOutSel && (fill3_i || ld_From_I_VC_Swap) && en ? 0 : 1;

    // Tag input: always use physical address tag (VIPT)
    // Swap buffer only provides data, not the tag - tag comes from current p_addr_i
    logic [ICACHE_TAG_WIDTH -1 : 0] DIN_2_TagStore;
    assign DIN_2_TagStore = p_addr_i_tag;

    logic OE_2_TagStore = !busy || LD_IC_SWAP_BUF;

    logic [7 : 0] DOUT_2_TagStore_extended[2];
    logic [ICACHE_TAG_WIDTH - 1 : 0] DOUT_2_TagStore = DOUT_2_TagStore_extended[tagCellOutSel][ICACHE_TAG_WIDTH - 1: 0];

    // Output assignments
    assign currTag_o = DOUT_2_TagStore;
    assign currLine_V = validStore[v_addr_i_index];

    ram8b8w$ tag_store_ramCell_Lower (
        .A(ADDRESS_2_TagStore),
        .WR(WR_2_TagStore[0]),
        .DIN({1'b0, DIN_2_TagStore}),
        .OE(OE_2_TagStore),
        .DOUT(DOUT_2_TagStore_extended[0])
    );

    ram8b8w$ tag_store_ramCell_Upper (
        .A(ADDRESS_2_TagStore),
        .WR(WR_2_TagStore[1]),
        .DIN({1'b0, DIN_2_TagStore}),
        .OE(OE_2_TagStore),
        .DOUT(DOUT_2_TagStore_extended[1])
    );

    // Valid bit storage - reset when rst is active high
    always_ff @(posedge clk) begin
        if (rst)
            validStore <= '0;
        else if (fill3_i || ld_From_I_VC_Swap)
            validStore[v_addr_i_index] <= 1;
    end

endmodule

