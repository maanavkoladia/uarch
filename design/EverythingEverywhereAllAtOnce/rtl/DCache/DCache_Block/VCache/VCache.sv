import common_pkg::*;
import DCache_common_pkg::*;

module VCache (
    input wire clk_i,
    input wire rst_i,  //active low

    input block_req_t blockReq_i,

    input eb_outputs_t eb_outs_i,
    input d_cache_bank_outputs_t dcache_outs_i,

    output v_cache_outputs_t outputs_o
);

    vcache_fsm_states_e vcache_fsm_state;
    logic [$clog2(NUM_VCACHE_STATES) - 1 : 0] vcache_fsm_state_bits;
    assign vcache_fsm_state = vcache_fsm_state_bits;

    p_addr_vcache_fields_t block_req_p_addr_fields = '{
        tag    : blockReq_i.p_addr[V_CACHE_TAG_UB : V_CACHE_TAG_LB],
        index  : blockReq_i.p_addr[V_CACHE_IDX_UB : V_CACHE_IDX_LB],
        bank   : blockReq_i.p_addr[V_CACHE_BANK_UB : V_CACHE_BANK_LB],
        offset : blockReq_i.p_addr[V_CACHE_OFFSET_UB : V_CACHE_OFFSET_LB]
    };

    typedef struct {
        bool LD_EB;
        bool CLR_D_SWAP_V;
        bool Read_DSWAP;
        bool Write_VSWAP;
        bool busy;
        bool blocked;
    } vcache_fsm_outputs_t;

    vcache_fsm_outputs_t fsmOuts;

    //these need to be correct from tagStore
    logic hit;
    logic miss;

    //this has to be correct tag on a write to v_swap, bbut
    //maybe not for a idle hit
    logic [V_CACHE_TAG_WIDTH - 1 : 0] currTag;

    byte_t vcache_dataStore_Line[CACHE_LINES_SIZE_B];

    logic writeSuccess2TagStore;  //needs to mark the line dirty, holy fuck, what have we created

    swap_buf_t vcache_swapBuf;

    //means that the currline is valid and dirty, so it cant be over written,
    //needs to be evicted
    logic V_Cache_needs_2_evict;
    logic V_Cache_TagStore_CurrLine_V;
    logic V_Cache_TagStore_CurrLine_Dirty;

    VCache_FSM vcache_fsm (
        .clk(clk_i),
        .rst(rst_i),
        .V_Hit_i(hit),  //out from vcache tagstore, not like bank
        .DC_will_evict_i(dcache_outs_i.D_will_evict),
        .VC_needs_2_evict_i(V_Cache_needs_2_evict),  //if the currline is valid and dirty, i think
        .EB_V_i(eb_outs_i.valid),
        .S_0(vcache_fsm_state_bits[0]),  // current-state bit 0 (LSB)
        .S_1(vcache_fsm_state_bits[1]),  // current-state bit 1 (1)
        .LD_EB_o(fsmOuts.LD_EB),
        .CLR_D_SWAP_V_o(fsmOuts.CLR_D_SWAP_V),
        .Read_DSWAP_o(fsmOuts.Read_DSWAP),
        .Write_VSWAP_o(fsmOuts.Write_VSWAP),
        .busy_o(fsmOuts.busy),
        .blocked_o(fsmOuts.blocked)
    );

    VCache_DataStore vcache_datastore_unit (
        .p_addr_i(blockReq_i.p_addr),
        .oe(blockReq_i.oe),
        .we(blockReq_i.we),
        .st_q_data(blockReq_i.st_q_data),
        .st_data_vec(blockReq_i.vec),
        //.DCache_SwapBuf_lineAddr(dcache_outs_i.dcache_swapBuf.lineAddr),
        .DCache_SwapBuf_Line_i(dcache_outs_i.dcache_swapBuf.line),
        .read_D_SWAP_i(fsmOuts.Read_DSWAP),
        .Write_VSWAP_i(fsmOuts.Write_VSWAP),
        .busy_i(fsmOuts.busy),
        .LD_EB_i(fsmOuts.LD_EB),
        .tagStore_hit_i(hit),
        .VCache_DataStore_LineOut_o(vcache_dataStore_Line)
    );

    VCache_TagStore vcache_tag_store_unit (
        .clk_i(clk_i),
        .rst(rst_i),  //active low
        .p_addr_i(blockReq_i.p_addr),
        .oe_i(blockReq_i.oe),
        .we_i(blockReq_i.we),
        .Read_DSWAP_i(fsmOuts.Read_DSWAP),
        .D_Cache_SwapBuf_Addr(dcache_outs_i.dcache_swapBuf.lineAddr),
        .D_Cache_SwapBuf_DirtyBit(dcache_outs_i.dcache_swapBuf.dirty),
        .bankControllerBusy_i(fsmOuts.busy),
        .LD_EB_i(fsmOuts.LD_EB),
        .Write_VSWAP_i(fsmOuts.Write_VSWAP),
        .writeSuccess(writeSuccess2TagStore),
        .tagOut_o(currTag),
        .currLine_V_o(V_Cache_TagStore_CurrLine_V),
        .currLine_Dirty_o(V_Cache_TagStore_CurrLine_Dirty)
    );

    //vcache_swapBuf LOGIC
    always_ff @(posedge clk_i) begin
        if (!rst_i) vcache_swapBuf <= '0;
        else begin
            unique case ({
                fsmOuts.Write_VSWAP, dcache_outs_i.V_Cache_swapBuf_valid_clr
            })
                2'b00: vcache_swapBuf.valid <= vcache_swapBuf.valid;
                2'b01: vcache_swapBuf.valid <= 0;
                2'b10: vcache_swapBuf.valid <= 1;
                2'b11: $fatal;
            endcase

            if (fsmOuts.Write_VSWAP) begin
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

    //need to do vcache outputs loogic
    always_comb begin

        miss = 0;
        hit = 0;
        writeSuccess2TagStore = 0;
        if(
            (currTag == block_req_p_addr_fields.tag)
            && V_Cache_TagStore_CurrLine_V
            && fsmOuts.busy
            && (blockReq_i.oe || blockReq_i.we)
            )
        begin
            hit = 1;
        end

        if(
            (currTag != block_req_p_addr_fields.tag || !V_Cache_TagStore_CurrLine_V)
            && (blockReq_i.oe || blockReq_i.we)
            //&& fsmOuts.busy
            ) begin
            miss = 1;
        end

        if (hit && miss) $fatal;

        if (hit && blockReq_i.we) begin
            writeSuccess2TagStore = 1;
        end
        V_Cache_needs_2_evict = V_Cache_TagStore_CurrLine_V && V_Cache_TagStore_CurrLine_Dirty;
    end

    //sassinging the outputs
    always_comb begin
        outputs_o.hit = hit;
        outputs_o.miss = miss;
        outputs_o.vcache_swapBuf = vcache_swapBuf;
        outputs_o.D_Cache_swapBuf_valid_clr = fsmOuts.CLR_D_SWAP_V;
        outputs_o.LD_EB = fsmOuts.LD_EB;
        outputs_o.busy = fsmOuts.busy;
        outputs_o.beingBlocked = fsmOuts.blocked;
        outputs_o.lineOut = vcache_dataStore_Line;
        outputs_o.addrOut = {
            currTag, block_req_p_addr_fields.index, block_req_p_addr_fields.bank, 4'b0000
        };
    end

endmodule
