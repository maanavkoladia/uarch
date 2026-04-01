import common_pkg::*;
import DCache_common_pkg::*;

module VCache_TagStore (
    input wire clk_i,
    input wire rst,    //active low

    //req related signals will always correct, top module will handle this
    //this deals with the case that arb moves on on a swap
    input p_address_t p_addr_i,
    input bool oe_i,
    input bool we_i,

    //fsm
    input bool Read_DSWAP_i,
    input p_address_t D_Cache_SwapBuf_Addr,
    input bool D_Cache_SwapBuf_DirtyBit,

    input bool saveSwapIDX,
    input bool clearSwap_IDX,

    input bool bankControllerBusy_i,

    input bool LD_EB_i,
    input bool Write_VSWAP_i,

    input bool Update_LRU,


    output logic [V_CACHE_TAG_WIDTH - 1 : 0] tagOut_o,
    output bool hit,
    output bool miss,

    output logic [$clog2(VCACHE_NUM_LINES ) - 1 : 0] hitIDX,  //for drving the datastore
    output logic [$clog2(VCACHE_NUM_LINES ) - 1 : 0] evictionIDX,  //for evivtions from vcach
    output logic [$clog2(VCACHE_NUM_LINES ) - 1 : 0] savedSwapIDX,  //for swapping

    //this is need for the fsm controller and for swaping with dcahche bank
    output bool currLine_V_o,
    output bool currLine_Dirty_o

);

    localparam int NUM_CELLS_NEEDED = 2;  //bc 9 tag bits wide
    localparam int CELL_WIDTH_bits = 8;

    localparam int NUM_LRU_BITS = 3;
    localparam int LRU_ROOT = 0;
    localparam int LRU_LEFT_LEAF = 1;
    localparam int LRU_RIGHT_LEAF = 2;


    typedef struct {
        bool valid;
        bool dirty;
        logic [$clog2(VCACHE_NUM_LINES)] idx;
    } tag_line_meta_store_info_t;

    typedef struct {
        tag_line_meta_store_info_t tag_line_metaStore[VCACHE_NUM_LINES];
        bool LRU[NUM_LRU_BITS];
    } tag_metastore_t;

    tag_metastore_t tagMetaStore;


    p_addr_vcache_fields_t p_addr_fields;
    assign p_addr_fields = '{
            tag    : p_addr_i[V_CACHE_TAG_UB : V_CACHE_TAG_LB],
            bank   : p_addr_i[V_CACHE_BANK_UB : V_CACHE_BANK_LB],
            offset : p_addr_i[V_CACHE_OFFSET_UB : V_CACHE_OFFSET_LB]
        };

    p_addr_vcache_fields_t DCache_SwapBuf_lineAddr_fields;
    assign DCache_SwapBuf_lineAddr_fields = '{
            tag    : D_Cache_SwapBuf_Addr[V_CACHE_TAG_UB : V_CACHE_TAG_LB],
            bank   : D_Cache_SwapBuf_Addr[V_CACHE_BANK_UB : V_CACHE_BANK_LB],
            offset : D_Cache_SwapBuf_Addr[V_CACHE_OFFSET_UB : V_CACHE_OFFSET_LB]
        };

    bool doAccess;
    assign doAccess = (we_i || oe_i) && bankControllerBusy_i;

    //hit logic, if there is a oe or we and we are not busy, then give the hit
    //miss logic opposite, write success logic
    bool hit, miss;
    logic [$clog2(VCACHE_NUM_LINES ) - 1 : 0] hitIdx;
    bool writeSuccess;
    bool noHit;

    always_comb begin
        hit = 0;
        miss = 0;
        noHit = 1;
        hitIdx = 0;
        if (doAccess) begin
            for (int i = 0; i < VCACHE_NUM_LINES; i++) begin
                if (DOUT_of_TagStore[i] == p_addr_fields.tag && tagMetaStore.tag_line_metaStore[i].valid) begin
                    noHit = 0;
                    hit = 1;
                    hitIdx = i;
                end
            end
        end
        if (doAccess && noHit) miss = 1;
    end

    //case 1: loading from dcache bank swapbuf, for a swap, use the
    //address that was saved, ie the lines that got the hit in the previous cycle
    //case 2: loading from dcache bank swapbuf, for an eviction, use lru
    logic WR_2_TagStore[VCACHE_NUM_LINES];
    logic [$clog2(VCACHE_NUM_LINES) - 1 : 0] WR_2_TagStore_idx;

    //WR_2_TagStore,
    always_comb begin
        WR_2_TagStore = '1;
        WR_2_TagStore_idx = saved_SwapIDX_V ? saved_SwapIDX : currLRU_IDX;
        WR_2_TagStore[WR_2_TagStore_idx] = Read_DSWAP_i ? 0 : 1;
    end

    //can onyl come from the D$ swap buf addr, bits need,
    //to strip out properly, however, the dcahce bank is repossible
    //for recontrcuting the address, when writng to the swapbuf
    //thus the swapbuf shoudl have everyhitn besides the offset bits
    logic [V_CACHE_TAG_WIDTH - 1 : 0] DIN_2_TagStore;
    logic [  CELL_WIDTH_BITS - 1 : 0] DIN_2_TagStore_net[NUM_CELLS_NEEDED];
    assign DIN_2_TagStore_net[0] = DIN_2_TagStore[7:0];
    assign DIN_2_TagStore_net[1] = {{(CELL_WIDTH_BITS - 1) {1'b0}}, DIN_2_TagStore[8]};

    //DIN_2_TagStore
    always_comb begin
        DIN_2_TagStore = DCache_SwapBuf_lineAddr_fields.tag;
    end

    //active low, intentioanlly made it 1 bit, and not a vecotr,
    //there is not bytes addressable st
    //case 1: not busy and oe or we, this case is now different with a vache,
    //all of them shoudl be driven for the comparison
    //Case 2: laading to eb, this one needs to drive out the LRU line that
    //needs to be evecited
    //Case 3: loading to v$ swap buf, this one needs to drive out the line
    //that got the hit, ie there needs to be a 4x1 mux that feeds into the the
    //vc swap buf
    logic OE_2_TagStore[VCACHE_NUM_LINES];

    always_comb begin
        OE_2_TagStore = '1;
        if (doAccess) OE_2_TagStore = '0;
        else if (LD_EB_i) begin  //use lru idx
            OE_2_TagStore[currLRU_IDX] = 0;
        end else if (Write_VSWAP_i) begin
            OE_2_TagStore[clearSwap_IDX] = 0;
        end
    end

    //assinged, routing handeled externally
    logic [V_CACHE_TAG_WIDTH - 1 : 0] DOUT_of_TagStore[VCACHE_NUM_LINES];
    logic [CELL_WIDTH_BITS - 1 : 0] DOUT_of_TagStore_Net[VCACHE_NUM_LINES][NUM_CELLS_NEEDED];

    always_comb begin
        for (int i = 0; i < VCACHE_NUM_LINES; i++) begin
            DOUT_of_TagStore[i] = {DOUT_of_TagStore_Net[1][0], DOUT_of_TagStore_Net[0][7 : 0]};
        end
    end

    //LRU logic, this is handled by the fsm, the idea is that when we write
    //into the the vcache, ie Read_DSWAP_i is high, we update the lru, if we
    //get a hit, the LRU bits need to be update, somethign interesting that
    //happens here is that if we get a hit here, we will go through a swap
    //mechanism, so im aussuming that the incoming line, which will be put
    //where
    //we got the hit, this line is no longer the lru, this shoudl become the
    //mru

    logic [$clog2(VCACHE_NUM_LINES ) - 1 : 0] currLRU_IDX;
    //i think that swap needs to save the idx to overwrite, bc this info will
    //be lost when swap is actully happening

    //ff block for saved addr
    always_ff @(posedge clk_i) begin
        if (!rst) begin
            saved_SwapIDX_V <= 0;
            saved_SwapIDX   <= 0;
        end else if (saveSwapIDX) begin
            saved_SwapIDX_V <= 1;
            saved_SwapIDX   <= hitIdx;  //come from the hitidx
        end else if (clearSwap_IDX) saved_SwapIDX_V <= 0;
    end

    //ff block for tagstore_meta_store, needs to deal wiht updating tagmeta
    //store and lru nonsense,
    bool newLRU[NUM_LRU_BITS];

    always_comb begin
        //update on hits: hit becomes mru
        //update on swaps: incomming becomes mru, hit shoudl handle this,
        //evictions, incoming becomes mru,
    end

    always_ff @(posedge clk_i) begin
        if (!rst) begin
            tagMetaStore <= '{default: '0};
            for (int i = 0; i < VCACHE_NUM_LINES; i++) begin
                tagMetaStore.tag_line_metaStore[i].idx <= i;
            end
        end else begin
            if (Read_DSWAP_i) begin
                tagMetaStore.tag_line_metaStore[WR_2_TagStore_idx].valid <= 0;
                tagMetaStore.tag_line_metaStore[WR_2_TagStore_idx].dirty <= D_Cache_SwapBuf_DirtyBit;
            end else if (Update_LRU) begin
                tagMetaStore.LRU <= newLRU;
            end else if (writeSuccess) begin
                tagMetaStore.tag_line_metaStore[hitIdx].dirty <= 1;
            end
        end
    end

    logic [$clog2(VCACHE_NUM_LINES ) - 1 : 0] saved_SwapIDX;
    logic saved_SwapIDX_V;

    //create the memcells for this
    generate
        for (genvar i = 0; i < VCACHE_NUM_LINES; i++) begin : g_tagStore_Entry
            for (genvar j = 0; j < NUM_CELLS_NEEDED; j++) begin : g_tagStoreCell
                ram8b4w tagStoreCell (
                    .A(2'b0),
                    .WR(WR_2_TagStore[i]),
                    .DIN(DIN_2_TagStore_net[j]),
                    .OE(OE_2_TagStore[i]),
                    .DOUT(DOUT_2_TagStore_extended)
                );
            end
        end
    endgenerate


    //comb outputs or valid and dirty
    assign tagOut_o = DOUT_2_TagStore;
    assign currLine_V_o = tagMetaStore[p_addr_fields.index].valid;
    assign currLine_Dirty_o = tagMetaStore[p_addr_fields.index].dirty;

endmodule
