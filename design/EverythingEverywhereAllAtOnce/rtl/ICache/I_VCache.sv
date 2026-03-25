module I_VCache (
    input wire clk,
    input wire rst,  //active low

    //for updaing LRU
    input bool req_V_i,

    input p_address_t p_addr_i,
    input swap_buf_t  IC_SwapBuf_i,

    output swap_buf_t I_VC_SwapBuf_o,
    output bool hit_o,
    output bool miss_o,
    output bool busy_o,
    output bool IC_SwapBuf_V_clr_o,
    output byte_t dataLineOut_o[CACHE_LINES_SIZE_B]

);
    localparam int NUM_LINES = 4;
    localparam int NUM_LRU_BITS = 3;
    localparam int LRU_ROOT = 0;
    localparam int LRU_LEFT_LEAF = 1;
    localparam int LRU_RIGHT_LEAF = 2;

    typedef struct {
        bool valid;
        logic [I_VCACHE_TAG_WIDTH - 1 : 0] tag;
    } tagstore_entry_t;

    typedef struct {
        bool LRU[NUM_LRU_BITS];
        tagstore_entry_t entries[NUM_LINES];
    } tagstore_t;

    typedef struct {byte_t dataLines[NUM_LINES];} datastore_t;

    logic LD_I_VC_SWAP_BUF;
    logic RD_IC_SWAP_BUF;

    tagstore_t tagStore;
    datastore_t dataStore;
    swap_buf_t I_VC_swapBuf;

    logic [$clog2(NUM_LINES) - 1 : 0] hit_idx;
    logic [I_VCACHE_TAG_WIDTH -1 : 0] currTag[CACHE_LINES_SIZE_B];
    bool currTagHit;
    byte_t currDataLine[CACHE_LINES_SIZE_B];


    bool hit;
    bool miss;

    //deal with internal signals
    assign RD_IC_SWAP_BUF   = IC_SwapBuf_i.valid;
    assign LD_I_VC_SWAP_BUF = hit;

    //tag store "access"
    always_comb begin
        hit_idx = 0;
        currTag = 0;
        currTagHit = 0;
        for (int i = 0; i < NUM_LINES; i++) begin
            if(tagStore.entries[i].valid && tagStore.entries[i].tag == p_addr_i[I_VCACHE_TAG_UB : I_VCACHE_TAG_LB]) begin
                currTagHit = 1;
                currTag = tagStore.entries[i].tag;
                hit_idx = i;
            end
        end
    end

    //dataStore access
    assign currDataLine = dataStore.dataLines[hit_idx];

    //hit miss logic
    assign hit = req_V_i && currTagHit;
    assign miss = req_V_i && !(currTagHit);

    //swapBuf Logic
    always_ff @(posedge clk) begin
        if (!rst) I_VC_swapBuf <= '{default: 0};
        else if (LD_I_VC_SWAP_BUF) begin
            I_VC_swapBuf.valid <= 1;
            I_VC_swapBuf.lineAddr <= {currTag, 4'b0000};
            I_VC_swapBuf.lines <= currDataLine;
        end
    end

    bool updateLRU = (hit) || (RD_IC_SWAP_BUF);
    logic [$clog2(NUM_LINES) - 1 : 0] currLRU_IDX;

    always_comb begin
        currLRU_IDX[1] = !tagStore.LRU[LRU_ROOT];
        currLRU_IDX[0] = !tagStore.LRU[LRU_ROOT] ? !tagStore.LRU[LRU_LEFT_LEAF] : !tagStore.LRU[LRU_RIGHT_LEAF];
    end

    //update LRU logic
    //if reading from IC swap buf, then write to LRU and update LRU, to the
    //eviction idx
    //if just doing a regular access, then just update lru to the access index
    always_ff @(posedge clk) begin
        if (!rst) begin
            tagStore.entries <= '{default: '0};
        end else begin
            if (RD_IC_SWAP_BUF) begin
                tagStore.entries[currLRU_IDX].valid <= 1;
                tagStore.entries[currLRU_IDX].tag <= IC_SwapBuf_i.lineAddr[I_VCACHE_TAG_UB : I_VCACHE_TAG_LB];
                //update lru
                tagStore.LRU[LRU_ROOT] <= currLRU_IDX[1];
                tagStore.LRU[LRU_LEFT_LEAF] = !currLRU_IDX[1] ? currLRU_IDX[0] : tagStore.LRU[LRU_LEFT_LEAF];
                tagStore.LRU[LRU_RIGHT_LEAF] = currLRU_IDX[1] ? currLRU_IDX[0] : tagStore.LRU[LRU_RIGHT_LEAF];
            end else if (hit) begin
                tagStore.LRU[LRU_ROOT] <= hit_idx[1];
                tagStore.LRU[LRU_LEFT_LEAF] = !hit_idx[1] ? hit_idx[0] : tagStore.LRU[LRU_LEFT_LEAF];
                tagStore.LRU[LRU_RIGHT_LEAF] = hit_idx[1] ? hit_idx[0] : tagStore.LRU[LRU_RIGHT_LEAF];
                //update lru
            end
        end
    end

    //deal with module outputs
    assign I_VC_SwapBuf_o = I_VC_swapBuf;
    assign hit_o = hit;
    assign miss_o = miss;
    assign busy_o = hit || IC_SwapBuf_i.valid;
    assign dataLineOut_o = currDataLine;
    assign IC_SwapBuf_V_clr_o = RD_IC_SWAP_BUF;

endmodule
