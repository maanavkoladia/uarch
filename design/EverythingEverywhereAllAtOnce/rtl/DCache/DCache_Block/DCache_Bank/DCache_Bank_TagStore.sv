import common_pkg::*;
import DCache_common_pkg::*;

module DCache_Bank_TagStore (
    input wire clk,
    input wire rst,  //active low

    input p_address_t p_addr_i,
    input bool oe_i,
    input bool we_i,

    input bool ld_From_V_Swap_i,
    //input logic [V_CACHE_TAG_WIDTH - 1 : 0] V_Cache_SwapBuf_Tag,
    input bool V_Cache_SwapBuf_DirtyBit,

    input bool fill3_i,
    input bool write2_Dwap_i,

    input bool bankControllerBusy_i,

    //for dirty bit
    input bool writeSuccess,

    output logic [DCACHE_BANK_TAG_WIDTH - 1 : 0] tagOut_o,

    //both have to go out for fsm, and if writing to d$ swap buf, then it
    //needs to know if the line sitting there is dirty for later eviction to 
    //main mem
    output bool currLine_V_o,
    output bool currLine_Dirty_o
);

    typedef struct {
        bool valid;
        bool dirty;
    } tag_store_meta_data_t;

    //need to create the TagStore
    tag_store_meta_data_t tagMetaStore[DCACHE_BANK_NUM_LINES];

    //not an array on purpose, the datastore should not be bytes addressable
    //this shoudl just be the index bits from the the block req
    logic [DCACHE_BANK_INDEX_WIDTH - 1 : 0] ADDRESS_2_TagStore;

    //there are two cases that i can think of that would require a new tag be
    //written in.
    //case 1: ld_ing from the V$ swap buf,
    //case 2: new data from bus
    logic WR_2_TagStore;

    //din can come from bus, for a ld_req or wr_req and a miss, or from block_req we req st_q req, or v$ swapBuf
    //exact control will be dictacted by oe and we
    //din is basically means we are bringing in a new cacheline, so what are
    //the cases that we can do this. ie what are the ways that we can bring
    //a new $line in
    //Case 1: new line from mem during fill, so we can can grab it from the
    //bus, wait no, the bus is dumb, the address we want is in the bank req
    //Case 2: V$ got a hit and we need to do a swap, it that case, it will
    //come from th bank_req, din can always be from p_addr_i, fuck me,
    //i changed this now, where the address will come from
    //V_Cache_SwapBuf_Tag and not the req. ik this seems stupid, but its to be
    //consistent with the dirty bit logic. once your a dirty little bit, your
    //always a dirty little bit
    //
    logic [DCACHE_BANK_TAG_WIDTH - 1 : 0] DIN_2_TagStore;

    //I think that there are 2 cases where we need to drive the tag out
    //case 1: if we are doing a normal access oe or we, and we need to see if we got
    //a hit
    //case 2:swapping to D$ buf bc if V$ wont know the new tag if we dont,
    //also note that the V$ tag bits are different than the D$ bank's bits
    //so this means that we need to build the V$ in the top bank module before
    //writing it
    //this is not a vector bc there is only one module, and there isnt bit
    //addrewability
    logic OE_2_TagStore;

    logic [DCACHE_BANK_TAG_WIDTH - 1 : 0] DOUT_2_TagStore;
    logic [7:0] DOUT_2_TagStore_extended;
    assign DOUT_2_TagStore = DOUT_2_TagStore_extended[DCACHE_BANK_TAG_WIDTH - 1 : 0];

    p_addr_dcache_fields_t p_addr_fields;
    assign p_addr_fields = '{
        tag    : p_addr_i[DCACHE_BANK_TAG_UB : DCACHE_BANK_TAG_LB],
        index  : p_addr_i[DCACHE_BANK_INDEX_UB : DCACHE_BANK_INDEX_LB],
        bank   : p_addr_i[DCACHE_BANK_BANK_UB : DCACHE_BANK_BANK_LB],
        offset : p_addr_i[DCACHE_BANK_OFFSET_UB : DCACHE_BANK_OFFSET_LB]
    };

    //create the cell for the tag store, there are only 6 tag bits
    ram8b8w$ tag_store_ramCell (
        .A(ADDRESS_2_TagStore),
        .WR(WR_2_TagStore),
        .DIN({2'b00,DIN_2_TagStore}),
        .OE(OE_2_TagStore),
        .DOUT(DOUT_2_TagStore_extended)
    );

    //ADDRESS_2_DataStore logic
    always_comb begin
        ADDRESS_2_TagStore = p_addr_fields.index;
    end

    always_comb begin  //bc active low, chose fill3_i bc it lines up better with valid logic
        if(rst)WR_2_TagStore = ld_From_V_Swap_i || fill3_i ? 1'b0 : 1'b1;
        else WR_2_TagStore = 1;
    end

    //from the comments above, i shoudl always be able to drive this, wr logic
    //should handle when
    always_comb begin
        DIN_2_TagStore = p_addr_fields.tag;
    end

    always_comb begin  //bc active low
        if(rst)OE_2_TagStore = ((oe_i || we_i) && !bankControllerBusy_i) || write2_Dwap_i ? 1'b0 : 1'b1;
        else begin
            OE_2_TagStore <= 1;
        end
    end

    //now to deal with the tag meta store,
    //cases where we need to make change to the valid bit,
    //note valid bit starts out invalid, it soudl never in our machine go
    //invalid after becoming valid
    //case 1: make it valid everytime we write a new line in, so swap or mem,
    //i dont think we ever need to invalidate a line
    //
    //now the dirty logic, i htink that the only time that the dirty bit
    //needs to be set is when we do a write to it, and it did succeed, so some
    //kind of dirty success needs to come in, i choose the writeSuccess
    //signal that top bank needs to send back in, i fucking lied, once
    //a dirty little bit, always a dirty little bit
    //
    always_ff @(posedge clk) begin
        if (!rst) begin
            for(int i = 0; i < DCACHE_BANK_NUM_LINES; i++) begin
                tagMetaStore[i] <= '{default:'0};
            end
        end else begin
            if (fill3_i || ld_From_V_Swap_i) begin
                tagMetaStore[p_addr_fields.index].valid <= 1'b1;
                tagMetaStore[p_addr_fields.index].dirty <=
                    ld_From_V_Swap_i && V_Cache_SwapBuf_DirtyBit;
            end
            if (writeSuccess) begin
                tagMetaStore[p_addr_fields.index].dirty <= 1'b1;
            end
        end
    end

    assign currLine_V_o = tagMetaStore[p_addr_fields.index].valid;
    assign currLine_Dirty_o = tagMetaStore[p_addr_fields.index].dirty;
    assign tagOut_o = DOUT_2_TagStore;

endmodule
