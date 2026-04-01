import common_pkg::*;
import ICache_common_pkg::*;

module I_VCache (
    input wire clk,
    input wire rst,  //active low
    input icache_controller_fsm_states_e controller_fsmState,


    //for updaing LRU
    input bool req_V_i,

    input p_address_t p_addr_i,
    input ICache_swap_buf_t IC_SwapBuf_i,

    output ICache_swap_buf_t I_VC_SwapBuf_o,
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

    typedef struct {byte_t dataLines[NUM_LINES][CACHE_LINES_SIZE_B];} datastore_t;

    logic LD_I_VC_SWAP_BUF;
    logic RD_IC_SWAP_BUF;

    tagstore_t tagStore;
    datastore_t dataStore;
    ICache_swap_buf_t I_VC_swapBuf;

    logic [$clog2(NUM_LINES) - 1 : 0] hit_idx;
    logic [I_VCACHE_TAG_WIDTH -1 : 0] currTag;
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
    assign hit = req_V_i && currTagHit && (controller_fsmState == ICACHE_IDLE);

    assign miss = req_V_i && !(currTagHit) && (controller_fsmState == ICACHE_IDLE);

    //swapBuf Logic
    always_ff @(posedge clk) begin
        if (!rst) I_VC_swapBuf <= '{default: 0};
        else if (LD_I_VC_SWAP_BUF) begin
            I_VC_swapBuf.valid <= 1;
            I_VC_swapBuf.lineAddr <= {currTag, 4'b0000};
            I_VC_swapBuf.line <= currDataLine;
        end
    end

    bool updateLRU;
    assign updateLRU = (hit) || (RD_IC_SWAP_BUF);
    logic [$clog2(NUM_LINES) - 1 : 0] currLRU_IDX;

    always_comb begin
        currLRU_IDX[1] = !tagStore.LRU[LRU_ROOT];
        currLRU_IDX[0] = !tagStore.LRU[LRU_ROOT] ? !tagStore.LRU[LRU_LEFT_LEAF] : !tagStore.LRU[LRU_RIGHT_LEAF];
    end

    //update LRU logic
    //if reading from IC swap buf, then write to LRU and update LRU, to the
    //eviction idx
    //if just doing a regular access, then just update lru to the access index
    logic [$clog2(NUM_LINES) - 1 : 0] update_idx;
    always_ff @(posedge clk) begin
        if (!rst) begin
            tagStore.entries <= '{default: '0};
            tagStore.LRU <= '{default: '0};
            dataStore <= '{default: '0};
        end else begin
            if (updateLRU) begin
                update_idx = hit ? hit_idx : currLRU_IDX;
                // Update LRU tree to mark accessed way as MRU (bits point toward MRU)
                unique case (update_idx)
                    2'b00: begin  // Way 0 accessed - point to left/left
                        tagStore.LRU[LRU_ROOT]      <= 1'b0;  // Point to left subtree
                        tagStore.LRU[LRU_LEFT_LEAF] <= 1'b0;  // Point to way 0
                    end
                    2'b01: begin  // Way 1 accessed - point to left/right
                        tagStore.LRU[LRU_ROOT]      <= 1'b0;  // Point to left subtree
                        tagStore.LRU[LRU_LEFT_LEAF] <= 1'b1;  // Point to way 1
                    end
                    2'b10: begin  // Way 2 accessed - point to right/left
                        tagStore.LRU[LRU_ROOT]       <= 1'b1;  // Point to right subtree
                        tagStore.LRU[LRU_RIGHT_LEAF] <= 1'b0;  // Point to way 2
                    end
                    2'b11: begin  // Way 3 accessed - point to right/right
                        tagStore.LRU[LRU_ROOT]       <= 1'b1;  // Point to right subtree
                        tagStore.LRU[LRU_RIGHT_LEAF] <= 1'b1;  // Point to way 3
                    end
                endcase

                // If loading from IC swap buffer, update the evicted line's tag
                if (RD_IC_SWAP_BUF) begin
                    tagStore.entries[currLRU_IDX].valid <= 1'b1;
                    tagStore.entries[currLRU_IDX].tag <= IC_SwapBuf_i.lineAddr[I_VCACHE_TAG_UB : I_VCACHE_TAG_LB];
                    dataStore.dataLines[currLRU_IDX] <= IC_SwapBuf_i.line;
                end
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
