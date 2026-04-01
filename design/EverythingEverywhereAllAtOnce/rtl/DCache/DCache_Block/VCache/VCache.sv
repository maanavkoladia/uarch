import common_pkg::*;
import DCache_common_pkg::*;

module VCache (
    input wire clk,
    input wire rst,  //active low

    input block_req_t blockReq_i,

    input eb_outputs_t eb_outs_i,

    input d_cache_bank_outputs_t dcache_outs_i,

    output v_cache_outputs_t outputs_o
);

    vcache_fsm_states_e vcache_fsm_state;
    logic [$clog2(NUM_VCACHE_STATES) - 1 : 0] vcache_fsm_state_bits;
    assign vcache_fsm_state = vcache_fsm_state_bits;

    p_addr_vcache_fields_t block_req_p_addr_fields;
    assign block_req_p_addr_fields = '{
            tag    : blockReq_i.p_addr[V_CACHE_TAG_UB : V_CACHE_TAG_LB],
            bank   : blockReq_i.p_addr[V_CACHE_BANK_UB : V_CACHE_BANK_LB],
            offset : blockReq_i.p_addr[V_CACHE_OFFSET_UB : V_CACHE_OFFSET_LB]
        };

    typedef struct {
        logic WR_2_EB_o;
        logic CLR_D_SWAP_V_o;
        logic Read_DSWAP_o;
        logic Write_VSWAP_o;
        logic Update_LRU_o;
        logic saveSwapIDX_o;
        logic use_savedSwapIDX_o;
        logic blocked_o;
        logic busy_o;
        logic saveReq_o;
        logic useSavedReq_o;
    } vcache_fsm_outputs_t;

    vcache_fsm_outputs_t fsmOuts;

    //this has to be correct tag on a write to v_swap, bbut
    //maybe not for a idle hit

    swap_buf_t vcache_swapBuf;

    block_req_t savedReq;
    block_req_t reqInUse = fsmOuts.useSavedReq_o ? savedReq : blockReq_i;

    //means that the currline is valid and dirty, so it cant be over written,
    //needs to be evicted

    logic [V_CACHE_TAG_WIDTH - 1 : 0] currTag;
    logic hit;
    logic miss;
    logic [$clog2(VCACHE_NUM_LINES) - 1 : 0] hitIDX, evictionIDX, savedSwapIDX;

    logic V_Cache_needs_2_evict;  //out of tagstore
    logic V_Cache_TagStore_CurrLine_Dirty;
    //logic writeSuccess2TagStore;  //needs to mark the line dirty, holy fuck, what have we created


    byte_t vcache_dataStore_Line[CACHE_LINES_SIZE_B];
    VCache_FSM vcache_fsm_unit (
        .clk(clk),
        .rst(rst),
        .V_Hit_i(hit),
        .DC_will_evict_i(dcache_outs_i.D_will_evict),
        .VC_needs_2_evict_i(V_Cache_needs_2_evict),
        .EB_V_i(eb_outs_i.valid),
        .we_i(reqInUse.we),
        .S_0(vcache_fsm_state_bits[0]),  // current-state bit 0 (LSB)
        .S_1(vcache_fsm_state_bits[1]),  // current-state bit 1 (1)
        .S_2(vcache_fsm_state_bits[2]),  // current-state bit 2 (MSB)
        .WR_2_EB_o(fsmOuts.WR_2_EB_o),
        .CLR_D_SWAP_V_o(fsmOuts.CLR_D_SWAP_V),
        .Read_DSWAP_o(fsmOuts.Read_DSWAP),
        .Write_VSWAP_o(fsmOuts.Write_VSWAP),
        .Update_LRU_o(fsmOuts.Update_LRU),
        .saveSwapIDX_o(fsmOuts.saveSwapIDX),
        .use_savedSwapIDX_o(fsmOuts.use_savedSwapIDX),
        .blocked_o(fsmOuts.blocked),
        .busy_o(fsmOuts.busy),
        .saveReq_o(fsmOuts.saveReq),
        .useSavedReq_o(fsmOuts.useSavedReq)
    );

    VCache_TagStore vcache_tagstore_unit (
        .clk_i(clk),
        .rst(rst),  //active low
        .p_addr_i(reqInUse.p_addr),
        .oe_i(reqInUse.oe),
        .we_i(reqInUse.we),
        .Read_DSWAP_i(fsmOuts.Read_DSWAP_o),
        .D_Cache_SwapBuf_Addr(dcache_outs_i.dcache_swapBuf.lineAddr),
        .D_Cache_SwapBuf_DirtyBit(dcache_outs_i.dcache_swapBuf.dirty),
        .DCache_Will_Evict_i(dcache_outs_i.D_will_evict),
        .saveSwapIDX(fsmOuts.saveSwapIDX_o),
        .use_savedSwapIDX(fsmOuts.use_savedSwapIDX_o),
        .bankControllerBusy_i(fsmOuts.busy),
        .LD_EB_i(fsmOuts.WR_2_EB_o),
        .Write_VSWAP_i(fsmOuts.Write_VSWAP_o),
        .Update_LRU(fsmOuts.Update_LRU_o),
        .tagOut_o(currTag),
        .hit_o(hit),
        .miss_o(miss),
        .hitIDX_o(hitIDX),  //for drving the datastore
        .evictionIDX_o(evictionIDX),  //for evivtions from vcach
        .savedSwapIDX_o(savedSwapIDX),  //for swapping
        .currLine_Dirty_o(V_Cache_TagStore_CurrLine_Dirty),  //will be the hit idx for the swap buf
        .VC_Will_Need_ToEvict_o(V_Cache_needs_2_evict)  //for the fsm, based off the curr LRU
    );

    //vcache_swapBuf LOGIC
    always_ff @(posedge clk) begin
        if (!rst) vcache_swapBuf <= '{default: '0};
        else begin
            if (dcache_outs_i.V_Cache_swapBuf_valid_clr) begin
                vcache_swapBuf.valid <= 0;
            end
            if (fsmOuts.Write_VSWAP) begin
                vcache_swapBuf.valid <= vcache_swapBuf.valid;
                vcache_swapBuf.dirty <= V_Cache_TagStore_CurrLine_Dirty;
                //bits from tagstore, idx bits, banks bits, then zero out rest,
                //they dont matter
                vcache_swapBuf.lineAddr <= {
                    currTag, block_req_p_addr_fields.index, block_req_p_addr_fields.bank, 4'b0000
                };
                vcache_swapBuf.line <= vcache_dataStore_Line;
            end
        end
    end


    //sassinging the outputs
    always_comb begin
        outputs_o.hit = hit;
        outputs_o.miss = miss;
        outputs_o.vcache_swapBuf = vcache_swapBuf;
        outputs_o.D_Cache_swapBuf_valid_clr = fsmOuts.CLR_D_SWAP_V;
        outputs_o.LD_EB = fsmOuts.WR_2_EB_o;
        outputs_o.busy = fsmOuts.busy;
        outputs_o.beingBlocked = fsmOuts.blocked;
        outputs_o.lineOut = vcache_dataStore_Line;
        outputs_o.addrOut = {
            currTag, block_req_p_addr_fields.index, block_req_p_addr_fields.bank, 4'b0000
        };
    end

endmodule
