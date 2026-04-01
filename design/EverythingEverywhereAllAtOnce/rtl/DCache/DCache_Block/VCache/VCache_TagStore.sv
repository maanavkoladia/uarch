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
    input bool DCache_Will_Evict_i,
    input bool saveSwapIDX,
    input bool use_savedSwapIDX,

    input bool bankControllerBusy_i,

    input bool LD_EB_i,
    input bool Write_VSWAP_i,

    input bool Update_LRU,

    //for external fsm logic
    output logic [V_CACHE_TAG_WIDTH - 1 : 0] tagOut_o,
    output bool hit_o,
    output bool miss_o,

    //for data store
    output logic [$clog2(VCACHE_NUM_LINES ) - 1 : 0] hitIDX_o,  //for drving the datastore
    output logic [$clog2(VCACHE_NUM_LINES ) - 1 : 0] evictionIDX_o,  //for evivtions from vcach
    output logic [$clog2(VCACHE_NUM_LINES ) - 1 : 0] savedSwapIDX_o,  //for swapping

    //this is need for the fsm controller and for swaping with dcahche bank
    output bool currLine_Dirty_o,  //will be the hit idx for the swap buf
    output bool VC_Will_Need_ToEvict_o  //for the fsm, based off the curr LRU

);

    localparam int NUM_CELLS_NEEDED = 2;  //bc 9 tag bits wide
    localparam int CELL_WIDTH_BITS = 8;

    localparam int NUM_LRU_BITS = 3;
    localparam int LRU_ROOT = 0;
    localparam int LRU_LEFT_LEAF = 1;
    localparam int LRU_RIGHT_LEAF = 2;

    typedef struct {
        bool valid;
        bool dirty;
        logic [$clog2(VCACHE_NUM_LINES) - 1 : 0] idx;
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
    assign doAccess = (we_i || oe_i) && !bankControllerBusy_i;

    //hit logic, if there is a oe or we and we are not busy, then give the hit
    //miss logic opposite, write success logic
    bool hit, miss;
    logic [$clog2(VCACHE_NUM_LINES ) - 1 : 0] hitIdx;
    logic [VCACHE_NUM_LINES - 1 : 0] hitIdx_onehot;
    bool writeSuccess;
    bool noHit;

    always_comb begin
        hit = 0;
        miss = 0;
        hitIdx = 0;

        if (doAccess) begin
            for (int i = 0; i < VCACHE_NUM_LINES; i++) begin
                if (DOUT_of_TagStore[i] == p_addr_fields.tag && tagMetaStore.tag_line_metaStore[i].valid) begin
                    hit = 1;
                    hitIdx = i;
                    hitIdx_onehot = 1 << hitidx;
                end
            end
        end
        if (doAccess && !hit) miss = 1;
        if (hit && we_i) writeSuccess = 1;
    end

    //i think that swap needs to save the idx to overwrite, bc this info will
    //be lost when swap is actully happening
    //ff block for saved addr
    logic [$clog2(VCACHE_NUM_LINES ) - 1 : 0] saved_SwapIDX;
    logic [VCACHE_NUM_LINES - 1 : 0] saved_SwapIDX_oneHot;

    always_ff @(posedge clk_i) begin
        if (!rst) begin
            saved_SwapIDX_oneHot <= 0;
            saved_SwapIDX <= 0;
        end else if (saveSwapIDX) begin
            saved_SwapIDX_oneHot <= hitIdx_onehot;  //come from the hitidx
            saved_SwapIDX <= hitIdx;
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
    assign currLRU_IDX[1] = !tagMetaStore.LRU[LRU_ROOT];
    assign currLRU_IDX[0] = !tagMetaStore.LRU[LRU_ROOT] ? !tagMetaStore.LRU[LRU_RIGHT_LEAF] : !tagMetaStore.LRU[LRU_LEFT_LEAF];

    bool newLRU[NUM_LRU_BITS];
    //mru 0 left, lru 0 right
    always_comb begin
        //no latches, update on hit, not on swap bc redudant with hit, this
        //comes from hit idx
        //update if loading eb, means that a new lines is goig to be written
        //to the LRU, so LRU  is new MRU
        //cant rely on LD_EB_i signal because dont always needs to evict
        newLRU = tagMetaStore.LRU;  //do copy
        update_idx = DCache_Will_Evict_i ? currLRU_IDX : hitIdx;
        // Update LRU tree to mark accessed way as MRU (bits point toward MRU)
        unique case (update_idx)
            2'b00: begin  // Way 0 accessed - point to left/left
                newLRU[LRU_ROOT]      = 1'b0;  // Point to left subtree
                newLRU[LRU_LEFT_LEAF] = 1'b0;  // Point to way 0
            end
            2'b01: begin  // Way 1 accessed - point to left/right
                newLRU[LRU_ROOT]      = 1'b0;  // Point to left subtree
                newLRU[LRU_LEFT_LEAF] = 1'b1;  // Point to way 1
            end
            2'b10: begin  // Way 2 accessed - point to right/left
                newLRU[LRU_ROOT]       = 1'b1;  // Point to right subtree
                newLRU[LRU_RIGHT_LEAF] = 1'b0;  // Point to way 2
            end
            2'b11: begin  // Way 3 accessed - point to right/right
                newLRU[LRU_ROOT]       = 1'b1;  // Point to right subtree
                newLRU[LRU_RIGHT_LEAF] = 1'b1;  // Point to way 3
            end
        endcase

    end

    //case 1: loading from dcache bank swapbuf, for a swap, use the
    //address that was saved, ie the lines that got the hit in the previous cycle
    //case 2: loading from dcache bank swapbuf, for an eviction, use lru
    logic WR_2_TagStore[VCACHE_NUM_LINES];
    //logic WR_2_TagStore_net;
    logic [$clog2(VCACHE_NUM_LINES) - 1 : 0] WR_2_TagStore_idx;

    //assign WR_2_TagStore_net[0] = WR_2_TagStore[7 : 0];
    //assign WR_2_TagStore_net[1] = {{(CELL_WIDTH_BITS - 1) {1'b1}}, WR_2_TagStore[8]};

    //WR_2_TagStore,
    always_comb begin
        WR_2_TagStore = '1;
        WR_2_TagStore_idx = use_savedSwapIDX ? saved_SwapIDX : currLRU_IDX;
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
    logic [$clog2(VCACHE_NUM_LINES) - 1 : 0] OE_2_TagStore_idx;
    always_comb begin
        OE_2_TagStore = '1;
        OE_2_TagStore_idx = use_savedSwapIDX ? saved_SwapIDX : currLRU_IDX;
        if (doAccess) OE_2_TagStore = '0;
        else if (LD_EB_i) begin  //use lru idx
            OE_2_TagStore[currLRU_IDX] = 0;
        end else if (Write_VSWAP_i) begin
            OE_2_TagStore[OE_2_TagStore_idx] = 0;
        end
    end

    //assinged, routing handeled externally
    logic [V_CACHE_TAG_WIDTH - 1 : 0] DOUT_of_TagStore[VCACHE_NUM_LINES];
    logic [CELL_WIDTH_BITS - 1 : 0] DOUT_of_TagStore_Net[VCACHE_NUM_LINES][NUM_CELLS_NEEDED];

    always_comb begin
        for (int i = 0; i < VCACHE_NUM_LINES; i++) begin
            DOUT_of_TagStore[i] = {DOUT_of_TagStore_Net[i][1][8], DOUT_of_TagStore_Net[i][0]};
        end
    end

    //ff block for tagstore_meta_store, needs to deal wiht updating tagmeta
    //store and lru nonsense,
    always_ff @(posedge clk_i) begin
        if (!rst) begin
            tagMetaStore <= '{default: '0};
            for (int i = 0; i < VCACHE_NUM_LINES; i++) begin
                tagMetaStore.tag_line_metaStore[i].idx <= i;
            end
        end else begin
            if (Read_DSWAP_i) begin
                tagMetaStore.tag_line_metaStore[WR_2_TagStore_idx].valid <= 1;
                tagMetaStore.tag_line_metaStore[WR_2_TagStore_idx].dirty <= D_Cache_SwapBuf_DirtyBit;
            end
            if (writeSuccess) begin
                tagMetaStore.tag_line_metaStore[hitIdx].dirty <= 1;
            end
            if (Update_LRU) begin
                tagMetaStore.LRU <= newLRU;
            end
        end
    end

    //create the memcells for this
    generate
        for (genvar i = 0; i < VCACHE_NUM_LINES; i++) begin : g_tagStore_Entry
            for (genvar j = 0; j < NUM_CELLS_NEEDED; j++) begin : g_tagStoreCell
                ram8b4w tagStoreCell (
                    .A(2'b0),
                    .WR(WR_2_TagStore[i]),
                    .DIN(DIN_2_TagStore_net[j]),
                    .OE(OE_2_TagStore[i]),
                    .DOUT(DOUT_of_TagStore_Net[i][j])
                );
            end
        end
    endgenerate


    //comb outputs or valid and dirty
    ///////////////////////////////???MODULE OUTPUTS///////////////////////////////

    always_comb begin
        tagOut_o = '0;  //zeroing for now, shoudl stop zs from going out
        if (hit) tagOut_o = DOUT_of_TagStore[hitIdx];
    end
    assign hit_o = hit;
    assign miss_o = miss;

    assign hitIDX_o = hitIdx;
    assign evictionIDX_o = currLRU_IDX;
    assign savedSwapIDX_o = saved_SwapIDX;

    assign currLine_Dirty_o = tagMetaStore[use_savedSwapIDX?saved_SwapIDX : hitIdx].dirty;//for swapping, so hit idx or swap idx
    assign VC_Will_Need_ToEvict_o = tagMetaStore[currLRU_IDX].dirty && tagMetaStore[currLRU_IDX].valid;//for evciton so lru

endmodule
