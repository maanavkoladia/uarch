import common_pkg::*;
import DCache_common_pkg::*;

module VCache_DataStore (

    input rst_i,
    //from block req
    input p_address_t p_addr_i,
    input bool oe_i,
    input bool we_i,

    //from block req
    input byte_t   st_q_data_i  [CACHE_LINES_SIZE_B],
    input uint16_t st_data_vec_i,

    input byte_t DCache_SwapBuf_Line_i[CACHE_LINES_SIZE_B],

    //fsm
    input bool read_D_SWAP_i,  //for writing
    input bool Write_VSWAP_i,  //for reading
    input bool busy_i,  //do access logic
    input bool LD_EB_i,  //oe logic

    input bool tagStore_hit_i,
    input bool use_savedSwapIDX_i,

    input logic [$clog2(VCACHE_NUM_LINES ) - 1 : 0] hitIDX_i,  //for drving the datastore
    input logic [$clog2(VCACHE_NUM_LINES ) - 1 : 0] evictionIDX_i,  //for evivtions from vcach
    input logic [$clog2(VCACHE_NUM_LINES ) - 1 : 0] savedSwapIDX_i,  //for swapping

    output byte_t VCache_DataStore_LineOut_o[CACHE_LINES_SIZE_B]
);

    localparam int NUM_CELL_IN_DATA_STORE = CACHE_LINES_SIZE_B;

    //address can come from 2 places i think
    //case 1: state is idle, ie not busy, drive the mapped line out
    //case 2: we are doing a swap from the dcache swap buf, so the address will be in
    //case 3, were doing an eviction, then we need to use the dcache swapbuf, addr,
    //there, 
    //
    //i think that there is somethig to be metioned st 
    //now vcache is Drect mapped, i can jsut use the addr in 
    //the block_req, but just to be consistent, ill use the 
    //swapbuf addr
    //
    logic [$clog2(VCACHE_NUM_LINES ) - 1 : 0] ADDRESS_2_DataStore;

    //there is not bytes addressable st
    //case 1: when loading from D$ swabuf
    //case 2:  not busy doing a write, use the vector
    logic WR_2_DataStore_clk[NUM_CELL_IN_DATA_STORE];
    logic WR_2_DataStore_delay[NUM_CELL_IN_DATA_STORE];
    logic WR_2_DataStore_actual[NUM_CELL_IN_DATA_STORE];

    assign #6 WR_2_DataStore_delay = !rst_i ? '{default: '1} : WR_2_DataStore_clk;

    //data can only come from the D$ swap buf
    //i lied
    //can also come from a write
    byte_t DIN_2_DataStore[NUM_CELL_IN_DATA_STORE];

    //active low, intentioanlly made it 1 bit, and not a vecotr,
    //there is not bytes addressable ld
    //case 1: !busy and oe
    //case 2: need to output to eb
    //case 3: write to V$ swapBuf
    logic OE_2_DataStore;

    //assigned, handled enternally 
    byte_t DOUT_DataStore[NUM_CELL_IN_DATA_STORE];

    generate
        for (genvar i = 0; i < NUM_CELL_IN_DATA_STORE; i++) begin : g_vcache_data_store_ram_cells
            ram8b4w$ v_cache_data_store_ramCell (
                .A(ADDRESS_2_DataStore),
                .WR(WR_2_DataStore_actual[i]),
                .DIN(DIN_2_DataStore[i]),
                .OE(OE_2_DataStore),
                .DOUT(DOUT_DataStore[i])
            );
        end
    endgenerate

    //ADDRESS_2_DataStore logic, comes from either the saved swapBuf idx,
    //hitidx, or eviction lru idx
    always_comb begin
        ADDRESS_2_DataStore = hitIDX_i;
        if (use_savedSwapIDX_i) ADDRESS_2_DataStore = savedSwapIDX_i;
        if (LD_EB_i) ADDRESS_2_DataStore = evictionIDX_i;
    end

    always_comb begin
        if(!rst_i) WR_2_DataStore_actual = '{default: '1};
        else begin
            for(int i = 0; i < NUM_CELL_IN_DATA_STORE; i++)
                WR_2_DataStore_actual[i] = ((WR_2_DataStore_delay[i] == 0) && (WR_2_DataStore_clk[i] == 0)) ? 0 : 1;

        end
    end
    //WR_2_DataStore, active low
    always_comb begin
        //comb completness
        WR_2_DataStore_clk = '{default: '1};
        if (read_D_SWAP_i) begin
            WR_2_DataStore_clk = '{default: '0};
        end

        if (!busy_i && we_i) begin
            for (int i = 0; i < NUM_CELL_IN_DATA_STORE; i++) begin
                WR_2_DataStore_clk[i] = st_data_vec_i[i] && tagStore_hit_i ? 1'b0 : 1'b1;
            end
        end
    end

    //DIN_2_DataStore lgoic
    always_comb begin
        DIN_2_DataStore = read_D_SWAP_i ? DCache_SwapBuf_Line_i : st_q_data_i;
    end

    //OE_2_DataStore logic
    always_comb begin
        OE_2_DataStore = LD_EB_i || Write_VSWAP_i || (!busy_i && oe_i) ? 1'b0 : 1'b1;
    end

    //deal w outputs
    always_comb begin
        VCache_DataStore_LineOut_o = DOUT_DataStore;
    end

endmodule
