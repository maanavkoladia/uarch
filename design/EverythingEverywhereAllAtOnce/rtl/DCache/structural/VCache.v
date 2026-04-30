// Structural Verilog-2005 port of rtl/DCache/DCache_Block/VCache/VCache.sv

`include "STDCell_Macros.vh"
`include "DCache_common_define.vh"

module VCache (
    input  wire                                       clk,
    input  wire                                       rst,                  // active-low
    input  wire [`BREQ_W                    - 1 : 0]  blockReq_i,
    input  wire [`EB_OUT_W                  - 1 : 0]  eb_outs_i,
    input  wire [`DCB_OUT_W                 - 1 : 0]  dcache_outs_i,
    input  wire                                       block_busy_i,
    output wire [`VC_OUT_W                  - 1 : 0]  outputs_o
);

    //==================================================================
    // Field extraction
    //==================================================================
    // EB inputs
    wire eb_valid;
    assign eb_valid = eb_outs_i[`EB_OUT_VALID];

    // DCache inputs
    wire        dc_dwillevict;
    wire        dc_vswap_vclr;
    wire [`SWAP_W - 1 : 0] dc_swap;
    wire [`P_ADDR_W - 1 : 0] dc_swap_addr;
    wire        dc_swap_dirty;
    wire [`CL_W - 1 : 0] dc_swap_line;
    assign dc_dwillevict = dcache_outs_i[`DCB_OUT_DWILLEVICT];
    assign dc_vswap_vclr = dcache_outs_i[`DCB_OUT_VSWAP_VCLR];
    assign dc_swap       = dcache_outs_i[`DCB_OUT_SWAP_UB:`DCB_OUT_SWAP_LB];
    assign dc_swap_addr  = dc_swap[`SWAP_ADDR_UB:`SWAP_ADDR_LB];
    assign dc_swap_dirty = dc_swap[`SWAP_DIRTY];
    assign dc_swap_line  = dc_swap[`SWAP_LINE_UB:`SWAP_LINE_LB];

    //==================================================================
    // FSM signals
    //==================================================================
    wire [2:0] fsm_state_bits;
    wire fsm_WR_2_EB;
    wire fsm_CLR_D_SWAP_V;
    wire fsm_Read_DSWAP;
    wire fsm_Write_VSWAP;
    wire fsm_Update_LRU;
    wire fsm_busy;
    wire fsm_blocked;

    //==================================================================
    // saveReq / useSavedReq / saveIDX / useSavedIDX
    //==================================================================
    wire saveReq;
    wire useSavedReq;
    wire saveIDX;
    wire useSavedIDX;
    `INV_N(inv_busy_v_sr, 1, fsm_busy, saveReq)
    assign useSavedReq = fsm_busy;
    assign saveIDX     = saveReq;
    assign useSavedIDX = fsm_busy;

    //==================================================================
    // savedReq / reqInUse
    //==================================================================
    wire [`BREQ_W - 1 : 0] savedReq_q;
    wire [`BREQ_W - 1 : 0] reqInUse;
    `REG_RST_WE(ff_savedReq_v, `BREQ_W, clk, rst, saveReq, blockReq_i, savedReq_q)
    `MUX_2(mux_reqInUse_v, `BREQ_W, reqInUse, blockReq_i, savedReq_q, useSavedReq)

    wire        riu_oe;
    wire        riu_we;
    wire [`P_ADDR_W - 1 : 0]  riu_paddr;
    wire [`VEC_W    - 1 : 0]  riu_vec;
    wire [`CL_W     - 1 : 0]  riu_data;
    assign riu_oe   = reqInUse[`BREQ_OE];
    assign riu_we   = reqInUse[`BREQ_WE];
    assign riu_paddr= reqInUse[`BREQ_PADDR_UB:`BREQ_PADDR_LB];
    assign riu_vec  = reqInUse[`BREQ_VEC_UB:`BREQ_VEC_LB];
    assign riu_data = reqInUse[`BREQ_DATA_UB:`BREQ_DATA_LB];

    //==================================================================
    // TagStore + DataStore signals
    //==================================================================
    wire [`V_CACHE_TAG_W     - 1 : 0]  currTag;
    wire        hit;
    wire        miss;
    wire [`VCACHE_LINE_IDX_W - 1 : 0]  hitIDX;
    wire [`VCACHE_LINE_IDX_W - 1 : 0]  evictionIDX;
    wire [`VCACHE_LINE_IDX_W - 1 : 0]  savedIDX;
    wire        V_Cache_needs_2_evict;
    wire        V_Cache_TagStore_CurrLine_Dirty;
    wire [`CL_W - 1 : 0] vcache_dataStore_Line;

    //==================================================================
    // FSM
    //==================================================================
    VCache_FSM vcache_fsm_unit (
        .clk(clk),
        .rst(rst),
        .V_Hit_i(hit),
        .DC_will_evict_i(dc_dwillevict),
        .VC_needs_2_evict_i(V_Cache_needs_2_evict),
        .EB_V_i(eb_valid),
        .we_i(riu_we),
        .S_0(fsm_state_bits[0]),
        .S_1(fsm_state_bits[1]),
        .S_2(fsm_state_bits[2]),
        .WR_2_EB_o(fsm_WR_2_EB),
        .CLR_D_SWAP_V_o(fsm_CLR_D_SWAP_V),
        .Read_DSWAP_o(fsm_Read_DSWAP),
        .Write_VSWAP_o(fsm_Write_VSWAP),
        .Update_LRU_o(fsm_Update_LRU),
        .busy_o(fsm_busy),
        .blocked_o(fsm_blocked)
    );

    //==================================================================
    // TagStore (instantiates LRU internally)
    //==================================================================
    VCache_TagStore vcache_tag_store_unit (
        .clk(clk),
        .rst(rst),
        .p_addr_i(riu_paddr),
        .oe_i(riu_oe),
        .we_i(riu_we),
        .Read_DSWAP_i(fsm_Read_DSWAP),
        .D_Cache_SwapBuf_Addr(dc_swap_addr),
        .D_Cache_SwapBuf_DirtyBit(dc_swap_dirty),
        .DCache_Will_Evict_i(dc_dwillevict),
        .saveIDX(saveIDX),
        .use_savedIDX(useSavedIDX),
        .busy_i(block_busy_i),
        .WR_2_EB_i(fsm_WR_2_EB),
        .Write_VSWAP_i(fsm_Write_VSWAP),
        .Update_LRU(fsm_Update_LRU),
        .tagOut_o(currTag),
        .hit_o(hit),
        .miss_o(miss),
        .hitIDX_o(hitIDX),
        .evictionIDX_o(evictionIDX),
        .savedIDX_o(savedIDX),
        .currLine_Dirty_o(V_Cache_TagStore_CurrLine_Dirty),
        .VC_Will_Need_ToEvict_o(V_Cache_needs_2_evict)
    );

    //==================================================================
    // DataStore
    //==================================================================
    VCache_DataStore vcache_datastore_unit (
        .clk_i(clk),
        .rst_i(rst),
        .p_addr_i(riu_paddr),
        .oe_i(riu_oe),
        .we_i(riu_we),
        .st_q_data_i(riu_data),
        .st_data_vec_i(riu_vec),
        .DCache_SwapBuf_Line_i(dc_swap_line),
        .read_D_SWAP_i(fsm_Read_DSWAP),
        .Write_VSWAP_i(fsm_Write_VSWAP),
        .busy_i(block_busy_i),
        .WR_2_EB(fsm_WR_2_EB),
        .tagStore_hit_i(hit),
        .useSavedIDX(useSavedIDX),
        .hitIDX_i(hitIDX),
        .evictionIDX_i(evictionIDX),
        .savedIDX_i(savedIDX),
        .VCache_DataStore_LineOut_o(vcache_dataStore_Line)
    );

    //==================================================================
    // vcache_swapBuf flop bank
    //==================================================================
    wire        vswap_valid_q;
    wire        vswap_dirty_q;
    wire [`P_ADDR_W - 1 : 0]  vswap_addr_q;
    wire [`CL_W     - 1 : 0]  vswap_line_q;

    //   valid: WE = dc_vswap_vclr | Write_VSWAP ; D = Write_VSWAP ? valid_q : 0
    //   (the source's `valid <= valid` under Write_VSWAP keeps it; only clear path drives 0.
    //    With both true, second non-blocking assign wins -> valid_q (held).)
    wire vswap_valid_we;
    wire vswap_valid_d;
    `OR_2 (or_vswap_v_we, 1, vswap_valid_we, dc_vswap_vclr, fsm_Write_VSWAP)
    //   D: under Write_VSWAP -> valid_q (hold) ; under clr-only -> 0 ; mux:
    //     d = Write_VSWAP ? valid_q : 0
    `MUX_2(mux_vswap_v_d, 1, vswap_valid_d, 1'b0, vswap_valid_q, fsm_Write_VSWAP)
    `REG_RST_WE(ff_vswap_valid, 1,         clk, rst, vswap_valid_we,  vswap_valid_d, vswap_valid_q)

    //   dirty / addr / line : WE = Write_VSWAP
    `REG_RST_WE(ff_vswap_dirty, 1,         clk, rst, fsm_Write_VSWAP, V_Cache_TagStore_CurrLine_Dirty, vswap_dirty_q)
    `REG_RST_WE(ff_vswap_addr,  `P_ADDR_W, clk, rst, fsm_Write_VSWAP, riu_paddr,                       vswap_addr_q)
    `REG_RST_WE(ff_vswap_line,  `CL_W,     clk, rst, fsm_Write_VSWAP, vcache_dataStore_Line,           vswap_line_q)

    //==================================================================
    // addrOut = {currTag (9), bank (2), 4'b0000}    (15 bits)
    //==================================================================
    wire [`P_ADDR_W - 1 : 0] addrOut;
    wire [`V_CACHE_BANK_W - 1 : 0] blkreq_bank;
    assign blkreq_bank = blockReq_i[`BREQ_PADDR_LB + `V_CACHE_BANK_LB +: `V_CACHE_BANK_W];
    assign addrOut = {currTag, blkreq_bank, 4'b0000};

    //==================================================================
    // Output bus assembly (v_cache_outputs_t flat layout)
    //==================================================================
    wire [`SWAP_W - 1 : 0] vswap_packed;
    assign vswap_packed[`SWAP_VALID]                  = vswap_valid_q;
    assign vswap_packed[`SWAP_DIRTY]                  = vswap_dirty_q;
    assign vswap_packed[`SWAP_ADDR_UB:`SWAP_ADDR_LB]  = vswap_addr_q;
    assign vswap_packed[`SWAP_LINE_UB:`SWAP_LINE_LB]  = vswap_line_q;

    assign outputs_o[`VC_OUT_HIT]                       = hit;
    assign outputs_o[`VC_OUT_MISS]                      = miss;
    assign outputs_o[`VC_OUT_SWAP_UB:`VC_OUT_SWAP_LB]   = vswap_packed;
    assign outputs_o[`VC_OUT_DSWAP_VCLR]                = fsm_CLR_D_SWAP_V;
    assign outputs_o[`VC_OUT_LD_EB]                     = fsm_WR_2_EB;
    assign outputs_o[`VC_OUT_BUSY]                      = fsm_busy;
    assign outputs_o[`VC_OUT_BEINGBLOCKED]              = fsm_blocked;
    assign outputs_o[`VC_OUT_LINE_UB:`VC_OUT_LINE_LB]   = vcache_dataStore_Line;
    assign outputs_o[`VC_OUT_ADDR_UB:`VC_OUT_ADDR_LB]   = addrOut;

endmodule
