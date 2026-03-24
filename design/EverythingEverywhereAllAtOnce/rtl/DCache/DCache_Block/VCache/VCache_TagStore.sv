import common_pkg::*;
import DCache_common_pkg::*;

module VCache_TagStore (
    input wire clk_i,
    input wire rst,    //active low


    input p_address_t p_addr_i,
    input bool oe_i,
    input bool we_i,

    input bool Read_DSWAP_i,
    input p_address_t D_Cache_SwapBuf_Addr,
    input bool D_Cache_SwapBuf_DirtyBit,

    input bool bankControllerBusy_i,

    input bool LD_EB_i,
    input bool Write_VSWAP_i,

    input bool writeSuccess,


    output logic [V_CACHE_TAG_WIDTH - 1 : 0] tagOut_o,

    //this is need for the fsm controller and for swaping with dcahche bank
    output bool currLine_V_o,
    output bool currLine_Dirty_o

);

    typedef struct {
        bool valid;
        bool dirty;
    } tag_store_meta_data_t;

    tag_store_meta_data_t tagMetaStore[VCACHE_NUM_LINES];

    p_addr_vcache_fields_t p_addr_fields = '{
        tag    : p_addr_i[V_CACHE_TAG_UB : V_CACHE_TAG_LB],
        index  : p_addr_i[V_CACHE_IDX_UB : V_CACHE_IDX_LB],
        bank   : p_addr_i[V_CACHE_BANK_UB : V_CACHE_BANK_LB],
        offset : p_addr_i[V_CACHE_OFFSET_UB : V_CACHE_OFFSET_LB]
    };

    p_addr_vcache_fields_t DCache_SwapBuf_lineAddr_fields = '{
        tag    : D_Cache_SwapBuf_Addr[V_CACHE_TAG_UB : V_CACHE_TAG_LB],
        index  : D_Cache_SwapBuf_Addr[V_CACHE_IDX_UB : V_CACHE_IDX_LB],
        bank   : D_Cache_SwapBuf_Addr[V_CACHE_BANK_UB : V_CACHE_BANK_LB],
        offset : D_Cache_SwapBuf_Addr[V_CACHE_OFFSET_UB : V_CACHE_OFFSET_LB]
    };

    //address can come from 2 places i think
    //case 1: state is idle, ie not busy, drive the mapped line out
    //case 2: we are doing a swap from the dcache swap buf, so the address will be in
    //case 3, were doing an eviction, then we need to use the dcache  swapbuf, addr,
    //becase that i swhats coming in
    //there, 
    //
    //i think that there is somethig to be metioned st 
    //now vcache is Drect mapped, i can jsut use the addr in 
    //the block_req, but just to be consistent, ill use the 
    //swapbuf addr just to be consistent
    //
    logic [V_CACHE_IDX_WIDTH - 1 : 0] ADDRESS_2_TagStore;

    //active low, intentioanlly made it 1 bit, and not a vecotr,
    //there is not bytes addressable st
    //case 1: when loading from dcache swapbuf
    //i dont theres any other cases
    logic WR_2_TagStore;

    //can onyl come from the D$ swap buf addr, bits need,
    //to strip out properly, however, the dcahce bank is repossible
    //for recontrcuting the address, when writng to the swapbuf
    //thus the swapbuf shoudl have everyhitn besides the offset bits
    logic [V_CACHE_TAG_WIDTH - 1 : 0] DIN_2_TagStore;

    //active low, intentioanlly made it 1 bit, and not a vecotr,
    //there is not bytes addressable st
    //case 1: not busy and oe or we
    //Case 2: laading to eb,
    //Case 3: loading to v$ swap buf
    logic OE_2_TagStore;

    //assinged, routing handeled externally
    logic [V_CACHE_TAG_WIDTH - 1 : 0] DOUT_2_TagStore;

    //create the memcells for this
    ram8b8w$ tag_store_ramCell (
        .A(ADDRESS_2_TagStore),
        .DIN(DIN_2_TagStore),
        .OE(OE_2_TagStore),
        .WR(WR_2_TagStore),
        .DOUT(DOUT_2_TagStore)
    );

    //ADDRESS_2_TagStore
    always_comb begin
        //ADDRESS_2_TagStore = (read_D_SWAP_i  || LD_EB_i) ?
        //    DCache_SwapBuf_lineAddr_fields.idx
        //    : p_addr_fields.idx;
        ADDRESS_2_TagStore = p_addr_fields.index;
    end

    //WR_2_TagStore
    always_comb begin
        WR_2_TagStore = Read_DSWAP_i ? 1'b0 : 1'b1;
    end

    //DIN_2_TagStore
    always_comb begin
        DIN_2_TagStore = DCache_SwapBuf_lineAddr_fields.tag;
    end

    //OE_2_TagStore
    always_comb begin
        OE_2_TagStore = (!bankControllerBusy_i && (oe_i || we_i))
        || LD_EB_i
        || Write_VSWAP_i
        ? 1'b0 : 1'b1;
    end

    //ff block for tagstore_meta_store
    always_ff @(posedge clk_i) begin
        if (!rst) begin
            tagMetaStore <= '0;
        end
        begin  //only needs to change when i new line is coming in
            if (Read_DSWAP_i) begin
                tagMetaStore [p_addr_fields.index].valid <= 1;
                tagMetaStore [p_addr_fields.index].dirty <= D_Cache_SwapBuf_DirtyBit;
            end
            if (writeSuccess) begin
                tagMetaStore [p_addr_fields.index].dirty <= 1;
            end
        end
    end

    //comb outputs or valid and dirty
    assign tagOut_o = DOUT_2_TagStore;
    assign currLine_V_o = tagMetaStore [p_addr_fields.index].valid;
    assign currLine_Dirty_o = tagMetaStore [p_addr_fields.index].dirty;

endmodule
