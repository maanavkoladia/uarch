import common_pkg::*;
import DCache_common_pkg::*;

module VCache_TagStore (
    input wire clk,
    input wire rst,  //active low

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

    input bool saveIDX,
    input bool use_savedIDX,

    input bool busy_i,

    input bool WR_2_EB_i,
    input bool Write_VSWAP_i,

    input bool Update_LRU,

    //for external fsm logic
    output logic [V_CACHE_TAG_WIDTH - 1 : 0] tagOut_o,
    output bool hit_o,
    output bool miss_o,

    //for data store
    output logic [$clog2(VCACHE_NUM_LINES ) - 1 : 0] hitIDX_o,  //for drving the datastore
    output logic [$clog2(VCACHE_NUM_LINES ) - 1 : 0] evictionIDX_o,  //for drving the datastore
    output logic [$clog2(VCACHE_NUM_LINES ) - 1 : 0] savedIDX_o,  //for swapping

    //this is need for the fsm controller and for swaping with dcahche bank
    output bool currLine_Dirty_o,  //will be the hit idx for the swap buf
    output bool VC_Will_Need_ToEvict_o  //for the fsm, based off the curr LRU

);

    localparam int NUM_CELLS_NEEDED = 2;  //bc 9 tag bits wide
    localparam int CELL_WIDTH_BITS = 8;
    wire clk_phase_45;
    assign #2.5 clk_phase_45 = clk;

    typedef struct {
        bool valid;
        bool dirty;
        logic [$clog2(VCACHE_NUM_LINES) - 1 : 0] idx;
    } tag_line_meta_store_info_t;

    tag_line_meta_store_info_t tagMetaStore[VCACHE_NUM_LINES];

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
    bool hit, miss;
    bool writeSuccess;

    logic [$clog2(VCACHE_NUM_LINES ) - 1 : 0] hitIdx;
    logic [VCACHE_NUM_LINES - 1 : 0] hitIdx_onehot;

    //i think that swap needs to save the idx to overwrite, bc this info will
    //be lost when swap is actully happening
    //ff block for saved addr
    logic [$clog2(VCACHE_NUM_LINES ) - 1 : 0] savedIDX;
    logic [VCACHE_NUM_LINES - 1 : 0] savedIDX_oneHot;


    logic [$clog2(VCACHE_NUM_LINES) - 1 : 0] currLRU_IDX;

    //case 1: loading from dcache bank swapbuf, for a swap, use the
    //address that was saved, ie the lines that got the hit in the previous cycle
    //case 2: loading from dcache bank swapbuf, for an eviction, use lru
    logic WR_2_TagStore_clk[VCACHE_NUM_LINES];
    //logic WR_2_TagStore_delay[VCACHE_NUM_LINES];
    logic WR_2_TagStore_actual[VCACHE_NUM_LINES];

   // assign #2 WR_2_TagStore_delay = !rst ? '{default: '1} : WR_2_TagStore_clk;

    //WR_2_TagStore,
    always_comb begin
        WR_2_TagStore_clk = '{default: '1};
        WR_2_TagStore_clk[savedIDX] = Read_DSWAP_i ? 0 : 1;
    end

    always_comb begin
        if (!rst) WR_2_TagStore_actual = '{default: '1};
        else begin
            for (int i = 0; i < VCACHE_NUM_LINES; i++) begin
                WR_2_TagStore_actual[i] = ((WR_2_TagStore_clk[i] == 0) && (clk_phase_45)) ? 0 :1;
            end
        end
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
        OE_2_TagStore = '{default: '1};
        OE_2_TagStore_idx = use_savedIDX ? savedIDX : currLRU_IDX;
        if (doAccess) OE_2_TagStore = '{default: '0};
        else if (WR_2_EB_i || Write_VSWAP_i) begin  //use lru idx
            OE_2_TagStore[OE_2_TagStore_idx] = 0;
        end
    end

    //assinged, routing handeled externally
    logic [V_CACHE_TAG_WIDTH - 1 : 0] DOUT_of_TagStore[VCACHE_NUM_LINES];
    logic [CELL_WIDTH_BITS - 1 : 0] DOUT_of_TagStore_Net[VCACHE_NUM_LINES][NUM_CELLS_NEEDED];

    always_comb begin
        for (int i = 0; i < VCACHE_NUM_LINES; i++) begin
            DOUT_of_TagStore[i] = {DOUT_of_TagStore_Net[i][1][0], DOUT_of_TagStore_Net[i][0]};
        end
    end

    //ff block for tagstore_meta_store, needs to deal wiht updating tagmeta
    //store and lru nonsense,
    always_ff @(posedge clk) begin
        if (!rst) begin
            tagMetaStore <= '{default: '0};
            for (int i = 0; i < VCACHE_NUM_LINES; i++) begin
                tagMetaStore[i].idx <= i;
            end
        end else begin
            if (Read_DSWAP_i) begin
                tagMetaStore[savedIDX].valid <= 1;
                tagMetaStore[savedIDX].dirty <= D_Cache_SwapBuf_DirtyBit;
            end
            if (writeSuccess) begin
                tagMetaStore[hitIdx].dirty <= 1;
            end
        end
    end

    
    always_ff @(posedge clk) begin
        if (!rst) begin
            savedIDX_oneHot <= 0;
            savedIDX <= 0;
        end else if (saveIDX) begin
            //saved_SwapIDX_oneHot <= DCache_Will_Evict_i ? : hitIdx_onehot;  //come from the hitidx
            savedIDX <= DCache_Will_Evict_i ? currLRU_IDX : hitIdx;
        end
    end

    //hit logic, if there is a oe or we and we are not busy, then give the hit
    //miss logic opposite, write success logic

    assign doAccess = (we_i || oe_i) && !busy_i;

    assign hitIdx_onehot = 1 << hitIdx;

    always_comb begin
        hit = 0;
        miss = 0;
        hitIdx = 0;
        writeSuccess = 0;
        if (doAccess) begin
            for (int i = 0; i < VCACHE_NUM_LINES; i++) begin
                if ( tagMetaStore[i].valid && DOUT_of_TagStore[i] == p_addr_fields.tag) begin
                    hit = 1;
                    hitIdx = i;
                end
            end
        end
        if (doAccess && !hit) miss = 1;
        if (hit && we_i) writeSuccess = 1;
    end


    //this singal si used for the write to vache 1 cycel delay problem
    //when i write comes in we wait one cycle before writing to the vswap and
    //we lose the hit idx for the line we are swapping
    logic [$clog2(VCACHE_NUM_LINES) - 1 : 0] currLine_Dirty_idx;
    assign currLine_Dirty_idx = use_savedIDX ? savedIDX : hitIdx;

    //create the memcells for this
    generate
        for (genvar i = 0; i < VCACHE_NUM_LINES; i++) begin : g_tagStore_Entry
            for (genvar j = 0; j < NUM_CELLS_NEEDED; j++) begin : g_tagStoreCell
                ram8b4w$ tagStoreCell (
                    .A(2'b0),
                    .WR(WR_2_TagStore_actual[i]),
                    .DIN(DIN_2_TagStore_net[j]),
                    .OE(OE_2_TagStore[i]),
                    .DOUT(DOUT_of_TagStore_Net[i][j])
                );
            end
        end
    endgenerate

    //LRU MODULE

    LRU LRU_unit (
        .clk(clk),
        .rst(rst),
        .updateLRU(Update_LRU),
        .savedIDX(savedIDX),
        .currLRU_IDX(currLRU_IDX)
    );

    //comb outputs or valid and dirty
    ///////////////////////////////???MODULE OUTPUTS///////////////////////////////

    //cases that we need ot output the tag out
    //case 1, WR_2_EB
    //case 2, Write_VSWAP_i
    logic [$clog2(VCACHE_NUM_LINES) - 1 : 0] tag_out_write_to_vswap_idx;
    assign tag_out_write_to_vswap_idx = use_savedIDX ? savedIDX : hitIdx;
    //write to vswap when we got the hit right away. 

    logic [$clog2(VCACHE_NUM_LINES) - 1 : 0] tag_out_write_to_eb_idx;
    assign tag_out_write_to_eb_idx = use_savedIDX ? savedIDX : currLRU_IDX;


    bool tag_assigned;
    always_comb begin
        tag_assigned = 0;
        tagOut_o = '0;  //zeroing for now, shoudl stop zs from going out
        if (Write_VSWAP_i) begin
            tagOut_o = DOUT_of_TagStore[tag_out_write_to_vswap_idx];
        end
        if(WR_2_EB_i)begin
            tagOut_o = DOUT_of_TagStore[tag_out_write_to_eb_idx];
        end
    end

    assign hit_o = hit;
    assign miss_o = miss;

    assign hitIDX_o = hitIdx;
    assign savedIDX_o = savedIDX;
    assign evictionIDX_o = use_savedIDX ? savedIDX : hitIdx;

    assign currLine_Dirty_o = tagMetaStore[currLine_Dirty_idx].dirty;//for loading swap buf one cytcle late or curr idle cycle
    assign VC_Will_Need_ToEvict_o = tagMetaStore[currLRU_IDX].dirty && tagMetaStore[currLRU_IDX].valid;//for evciton so lru

endmodule
