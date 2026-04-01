import common_pkg::*;
import DCache_common_pkg::*;

module DCache_Bank (
    input wire clk,
    input wire rst,  //active low

    //dont think this is needed, added another later of
    //logic, probaly best to handle this in arb
    //input bool DCache_En,

    //for the miss signals and swap buf
    input v_cache_outputs_t V_Cache_i,

    //for the miss signals, not needed naymore,
    //no forwarding from EB, bc writes proably
    //get hairy
    input eb_outputs_t eb_i,

    //for memvalid for the fsm, from dte
    input bool mem_Valid_FromDte_i,

    input block_req_t blockReq_i,

    //data bus is only an input here, outputs go to V$
    input wire [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus,

    //for driving a line out on a ld_req
    output d_cache_bank_outputs_t outputs_o
);

    typedef struct {
        logic write_to_dswap;
        logic D_will_evict;
        logic ldFrom_V_swap;
        logic clr_v_swap;
        logic MakeReq;
        logic saveReq;
        logic useSaved_Req;
        logic Blocked;
        logic busy;
        logic fill0;
        logic fill1;
        logic fill2;
        logic fill3;
    } dcache_fsm_outputs_t;
    dcache_fsm_outputs_t fsmOuts;

    dcache_bank_fsm_states_e dcache_bank_State;
    logic [$clog2(NUM_DCACHE_BANK_FSM_STATES) - 1 : 0] dcache_bank_State_bits;
    assign dcache_bank_State = dcache_bank_State_bits;

    //nned to create the dcache swap buffer
    swap_buf_t dcache_bank_swapBuf;

    block_req_t savedReq;
    block_req_t reqInUse = fsmOuts.useSaved_Req ? savedReq : blockReq_i;

    p_addr_dcache_fields_t blockReq_p_addr_fields;
    assign blockReq_p_addr_fields = '{
            tag    : reqInUse.p_addr[DCACHE_BANK_TAG_UB : DCACHE_BANK_TAG_LB],
            index  : reqInUse.p_addr[DCACHE_BANK_INDEX_UB : DCACHE_BANK_INDEX_LB],
            bank   : reqInUse.p_addr[DCACHE_BANK_BANK_UB : DCACHE_BANK_BANK_LB],
            offset : reqInUse.p_addr[DCACHE_BANK_OFFSET_UB : DCACHE_BANK_OFFSET_LB]
        };

    //need to create the hit and miss signals,
    //need to create the tagstore hit signal, same as hit
    logic hit, miss;
    //need to create the tagOutPut signal for the comparsion
    logic [DCACHE_BANK_TAG_WIDTH - 1 : 0] currTag;

    //need to create the line valid signal from the tagstore
    logic currLineValid, currLineDirty;

    byte_t dataStore_Line[CACHE_LINES_SIZE_B];

    //need to create the tagstore writeSuccess signal
    logic writeSuccess2TagStore;



    DCache_Bank_FSM dcache_bank_fsm_unit (
        .clk(clk),
        .rst(rst),
        .D_Miss_i(miss),
        .V_Miss_i(V_Cache_i.miss),
        .EB_Hit_i(eb_i.reqHit),
        .Line_valid_i(currLineValid),
        .DTE_Mem_valid_i(mem_Valid_FromDte_i),
        .D_Swap_valid_i(),
        .we_i(reqInUse.we),

        .S_0(dcache_bank_State_bits[0]),  // current-state bit 0 (LSB)
        .S_1(dcache_bank_State_bits[1]),  // current-state bit 1 (1)
        .S_2(dcache_bank_State_bits[2]),  // current-state bit 2 (2)
        .S_3(dcache_bank_State_bits[3]),  // current-state bit 3 (MSB)

        .write_to_dswap_o(fsmOuts.write_to_dswap),
        .D_will_evict_o(fsmOuts.D_will_evict),
        .ldFrom_V_swap_o(fsmOuts.ldFrom_V_swap),
        .clr_v_swap_o(fsmOuts.clr_v_swap),
        .MakeReq_o(fsmOuts.MakeReq),
        .saveReq_o(fsmOuts.saveReq),
        .useSaved_Req_o(fsmOuts.useSaved_Req),
        .Blocked_o(fsmOuts.Blocked),
        .busy_o(fsmOuts.busy),
        .fill0_o(fsmOuts.fill0),
        .fill1_o(fsmOuts.fill1),
        .fill2_o(fsmOuts.fill2),
        .fill3_o(fsmOuts.fill3)
    );

    DCache_Bank_DataStore DCache_Bank_DataStore_unit (
        .rst(rst),
        .p_addr_i(reqInUse.p_addr),
        .oe(reqInUse.oe),
        .we(reqInUse.we),
        .ld_From_V_Swap_i(fsmOuts.ldFrom_V_swap),

        .fill0_i(fsmOuts.fill0),
        .fill1_i(fsmOuts.fill1),
        .fill2_i(fsmOuts.fill2),
        .fill3_i(fsmOuts.fill3),

        .write2_Dwap_i(fsmOuts.write_to_dswap),
        .bankControllerBusy_i(fsmOuts.busy),
        .st_q_data(reqInUse.st_q_data),
        .st_data_vec(reqInUse.vec),
        .VCache_SwapBuf_Line_i(V_Cache_i.vcache_swapBuf.line),
        .dataBus_i(dataBus),
        .tagStore_hit_i(hit),

        .lineOut_o(dataStore_Line)
    );

    DCache_Bank_TagStore DCache_Bank_TagStore_unit (
        .clk(clk),
        .rst(rst),  //active low
        .p_addr_i(reqInUse.p_addr),
        .oe_i(reqInUse.oe),
        .we_i(reqInUse.we),
        .ld_From_V_Swap_i(fsmOuts.ldFrom_V_swap),
        //.V_Cache_SwapBuf_Tag(V_Cache_i.vcache_swapBuf.lineAddr[V_CACHE_TAG_UB : V_CACHE_TAG_LB]),
        .V_Cache_SwapBuf_DirtyBit(V_Cache_i.vcache_swapBuf.dirty),
        .fill3_i(fsmOuts.fill3),
        .write2_Dwap_i(fsmOuts.write_to_dswap),
        .bankControllerBusy_i(fsmOuts.busy),
        .writeSuccess(writeSuccess2TagStore),  //
        .tagOut_o(currTag),
        .currLine_V_o(currLineValid),
        .currLine_Dirty_o(currLineDirty)
    );

    //need to handle dcache swap buf logic
    always_ff @(posedge clk) begin
        if (!rst) begin
            dcache_bank_swapBuf <= '{default: '0};
        end else begin
            //valid bit logic
            //unique case ({
            //    fsmOuts.write_to_dswap_o, V_Cache_i.D_Cache_swapBuf_valid_clr
            //})
            //    2'b00: dcache_bank_swapBuf.valid <= dcache_bank_swapBuf.valid;
            //    2'b01: dcache_bank_swapBuf.valid <= 0;
            //    2'b10: dcache_bank_swapBuf.valid <= 1;
            //    2'b11: if (rst) $fatal;
            //endcase

            if (V_Cache_i.D_Cache_swapBuf_valid_clr) dcache_bank_swapBuf.valid <= 0;
            if (fsmOuts.write_to_dswap) begin
                dcache_bank_swapBuf.valid <= 1;
                dcache_bank_swapBuf.dirty <= currLineDirty;
                //bits from tagstore, idx bits, banks bits, then zero out rest,
                //they dont matter
                dcache_bank_swapBuf.lineAddr <= {
                    currTag, blockReq_p_addr_fields.index, blockReq_p_addr_fields.bank, 4'b0000
                };
                dcache_bank_swapBuf.line <= dataStore_Line;
            end

        end
    end

    //address feeding logic

    always_ff @(posedge clk) begin
        if (!rst) savedReq <= '{default: '0};
        else if (fsmOuts.saveReq) savedReq <= blockReq_i;
    end


    bool doAccess;
    assign doAccess = !fsmOuts.busy && (reqInUse.oe || reqInUse.we);
    //need to do hit/miss logic
    always_comb begin
        miss = 0;
        hit = 0;
        writeSuccess2TagStore = 0;

        if (currTag == blockReq_p_addr_fields.tag && currLineValid && doAccess) begin
            hit = 1;
        end

        if (doAccess && !hit) miss = 1;

        if (hit && miss && rst) $fatal;

        if (hit && reqInUse.we) begin  //dirty bit business
            writeSuccess2TagStore = 1;
        end
    end

    //need to write to the dache outputs
    always_comb begin
        outputs_o.hit = hit;
        //outputs.miss = miss;
        outputs_o.dcache_swapBuf = dcache_bank_swapBuf;
        outputs_o.V_Cache_swapBuf_valid_clr = fsmOuts.clr_v_swap;
        outputs_o.D_will_evict = fsmOuts.D_will_evict;
        outputs_o.busy = fsmOuts.busy;
        outputs_o.data_lineOut = dataStore_Line;
        outputs_o.MakeReq = fsmOuts.MakeReq;
        outputs_o.eb_stalling = fsmOuts.Blocked;
    end

endmodule


