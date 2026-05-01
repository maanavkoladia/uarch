// Structural Verilog 2005 port of VCache.
// Reference SV: rtl/DCache/DCache_Block/VCache/VCache.sv
// Top-level shell: instantiates VCache_FSM (already structural in gen/),
// VCache_TagStore (structural), VCache_DataStore (structural). Holds the
// vcache_swapBuf register set, savedReq snapshot, and the addrOut output
// reconstruction.

module VCache (
    input  wire         clk,
    input  wire         rst,                                   // active-low

    // ---- block_req_t (unpacked) ----
    input  wire         blockReq_oe_i,
    input  wire         blockReq_we_i,
    input  wire [14:0]  blockReq_paddr_i,
    input  wire [127:0] blockReq_stq_data_i,                   // cache line
    input  wire [15:0]  blockReq_vec_i,

    // ---- eb_outputs_t (only fields VCache uses) ----
    input  wire         eb_valid_i,
    input  wire         eb_reqHit_i,                           // unused by VCache, kept for parity

    // ---- d_cache_bank_outputs_t (only fields VCache uses) ----
    input  wire         dcache_D_will_evict_i,
    input  wire         dcache_V_Cache_swapBuf_valid_clr_i,
    input  wire         dcache_swapBuf_dirty_i,
    input  wire [14:0]  dcache_swapBuf_lineAddr_i,
    input  wire [127:0] dcache_swapBuf_line_i,                 // cache line

    input  wire         block_busy_i,

    // ---- v_cache_outputs_t (unpacked) ----
    output wire         outputs_hit_o,
    output wire         outputs_miss_o,
    output wire         outputs_swapBuf_valid_o,
    output wire         outputs_swapBuf_dirty_o,
    output wire [14:0]  outputs_swapBuf_lineAddr_o,
    output wire [127:0] outputs_swapBuf_line_o,
    output wire         outputs_D_Cache_swapBuf_valid_clr_o,
    output wire         outputs_LD_EB_o,
    output wire         outputs_busy_o,
    output wire         outputs_beingBlocked_o,
    output wire [127:0] outputs_lineOut_o,
    output wire [14:0]  outputs_addrOut_o
);

    // ===============================================================
    // FSM output nets (computed below by the FSM instance)
    // ===============================================================
    wire fsm_S_0, fsm_S_1, fsm_S_2;
    wire fsm_WR_2_EB;
    wire fsm_CLR_D_SWAP_V;
    wire fsm_Read_DSWAP;
    wire fsm_Write_VSWAP;
    wire fsm_Update_LRU;
    wire fsm_busy;
    wire fsm_blocked;

    // ===============================================================
    // savedReq register set (mirror SV lines 157-160)
    //   we = saveReq = ~fsm_busy
    //   d  = corresponding blockReq_*_i field
    // ===============================================================
    wire        saveReq;
    wire        useSavedReq;
    wire        saveIDX;
    wire        useSavedIDX;
    wire        savedReq_oe_q;
    wire        savedReq_we_q;
    wire [14:0] savedReq_paddr_q;
    wire [127:0] savedReq_stq_data_q;
    wire [15:0] savedReq_vec_q;

    // saveReq / useSavedReq (mirror SV lines 39-43)
    `INV_N(u_saveReq, 1, fsm_busy, saveReq)
    assign useSavedReq = fsm_busy;
    assign saveIDX     = saveReq;        // matches SV line 42 (!fsm_busy)
    assign useSavedIDX = useSavedReq;    // matches SV line 43 (fsm_busy)

    `REG_RST_WE(u_savedReq_oe,    1,   clk, rst, saveReq, blockReq_oe_i,       savedReq_oe_q)
    `REG_RST_WE(u_savedReq_we,    1,   clk, rst, saveReq, blockReq_we_i,       savedReq_we_q)
    `REG_RST_WE(u_savedReq_paddr, 15,  clk, rst, saveReq, blockReq_paddr_i,    savedReq_paddr_q)
    `REG_RST_WE(u_savedReq_stq,   128, clk, rst, saveReq, blockReq_stq_data_i, savedReq_stq_data_q)
    `REG_RST_WE(u_savedReq_vec,   16,  clk, rst, saveReq, blockReq_vec_i,      savedReq_vec_q)

    // ===============================================================
    // reqInUse mux (mirror SV line 45)
    // ===============================================================
    wire        reqInUse_oe;
    wire        reqInUse_we;
    wire [14:0] reqInUse_paddr;
    wire [127:0] reqInUse_stq_data;
    wire [15:0] reqInUse_vec;

    `MUX_2(u_reqInUse_oe,    1,   reqInUse_oe,       blockReq_oe_i,       savedReq_oe_q,       useSavedReq)
    `MUX_2(u_reqInUse_we,    1,   reqInUse_we,       blockReq_we_i,       savedReq_we_q,       useSavedReq)
    `MUX_2(u_reqInUse_paddr, 15,  reqInUse_paddr,    blockReq_paddr_i,    savedReq_paddr_q,    useSavedReq)
    `MUX_2(u_reqInUse_stq,   128, reqInUse_stq_data, blockReq_stq_data_i, savedReq_stq_data_q, useSavedReq)
    `MUX_2(u_reqInUse_vec,   16,  reqInUse_vec,      blockReq_vec_i,      savedReq_vec_q,      useSavedReq)

    // ===============================================================
    // TagStore + DataStore output nets (forward declared)
    // ===============================================================
    wire [8:0]  currTag;
    wire        hit;
    wire        miss;
    wire [1:0]  hitIDX;
    wire [1:0]  evictionIDX;
    wire [1:0]  savedIDX;
    wire        V_Cache_TagStore_CurrLine_Dirty;
    wire        V_Cache_needs_2_evict;
    wire [127:0] vcache_dataStore_Line;

    // ===============================================================
    // vcache_swapBuf register set (mirror SV lines 140-155)
    //
    // Critical SV semantics: Write_VSWAP self-assigns valid (`valid <= valid`).
    // With two non-blocking `if`s in one always_ff, the LATER write wins.
    //   clr=0, Write_VSWAP=0 -> hold
    //   clr=1, Write_VSWAP=0 -> valid <= 0
    //   clr=0, Write_VSWAP=1 -> hold (self-assign)
    //   clr=1, Write_VSWAP=1 -> hold (second write wins)
    // So valid only transitions on (clr & ~Write_VSWAP), to 0.
    // ===============================================================
    wire swapBuf_valid_we;
    wire Write_VSWAP_bar;
    `INV_N(u_Write_VSWAP_bar, 1, fsm_Write_VSWAP, Write_VSWAP_bar)
    `AND_2(u_swapBuf_valid_we, 1, swapBuf_valid_we,
           dcache_V_Cache_swapBuf_valid_clr_i, Write_VSWAP_bar)

    wire        swapBuf_valid_q;
    wire        swapBuf_dirty_q;
    wire [14:0] swapBuf_lineAddr_q;
    wire [127:0] swapBuf_line_q;

    `REG_RST_WE(u_swapBuf_valid,   1,   clk, rst, swapBuf_valid_we,  1'b0,                              swapBuf_valid_q)
    `REG_RST_WE(u_swapBuf_dirty,   1,   clk, rst, fsm_Write_VSWAP,   V_Cache_TagStore_CurrLine_Dirty,   swapBuf_dirty_q)
    `REG_RST_WE(u_swapBuf_addr,    15,  clk, rst, fsm_Write_VSWAP,   reqInUse_paddr,                    swapBuf_lineAddr_q)
    `REG_RST_WE(u_swapBuf_line,    128, clk, rst, fsm_Write_VSWAP,   vcache_dataStore_Line,             swapBuf_line_q)

    // ===============================================================
    // FSM instance (already structural in gen/VCache_FSM.sv)
    // ===============================================================
    VCache_FSM vcache_fsm_unit (
        .clk              (clk),
        .rst              (rst),
        .V_Hit_i          (hit),
        .DC_will_evict_i  (dcache_D_will_evict_i),
        .VC_needs_2_evict_i(V_Cache_needs_2_evict),
        .EB_V_i           (eb_valid_i),
        .we_i             (reqInUse_we),

        .S_0(fsm_S_0),
        .S_1(fsm_S_1),
        .S_2(fsm_S_2),

        .WR_2_EB_o     (fsm_WR_2_EB),
        .CLR_D_SWAP_V_o(fsm_CLR_D_SWAP_V),
        .Read_DSWAP_o  (fsm_Read_DSWAP),
        .Write_VSWAP_o (fsm_Write_VSWAP),
        .Update_LRU_o  (fsm_Update_LRU),
        .busy_o        (fsm_busy),
        .blocked_o     (fsm_blocked)
    );

    // ===============================================================
    // TagStore instance (mirror SV lines 92-116)
    // ===============================================================
    VCache_TagStore vcache_tag_store_unit (
        .clk                     (clk),
        .rst                     (rst),
        .p_addr_i                (reqInUse_paddr),
        .oe_i                    (reqInUse_oe),
        .we_i                    (reqInUse_we),
        .Read_DSWAP_i            (fsm_Read_DSWAP),
        .D_Cache_SwapBuf_Addr    (dcache_swapBuf_lineAddr_i),
        .D_Cache_SwapBuf_DirtyBit(dcache_swapBuf_dirty_i),
        .DCache_Will_Evict_i     (dcache_D_will_evict_i),
        .saveIDX                 (saveIDX),
        .use_savedIDX            (useSavedIDX),
        .busy_i                  (block_busy_i),
        .WR_2_EB_i               (fsm_WR_2_EB),
        .Write_VSWAP_i           (fsm_Write_VSWAP),
        .Update_LRU              (fsm_Update_LRU),
        .tagOut_o                (currTag),
        .hit_o                   (hit),
        .miss_o                  (miss),
        .hitIDX_o                (hitIDX),
        .evictionIDX_o           (evictionIDX),
        .savedIDX_o              (savedIDX),
        .currLine_Dirty_o        (V_Cache_TagStore_CurrLine_Dirty),
        .VC_Will_Need_ToEvict_o  (V_Cache_needs_2_evict)
    );

    // ===============================================================
    // DataStore instance (mirror SV lines 118-137)
    // ===============================================================
    VCache_DataStore vcache_datastore_unit (
        .clk_i                     (clk),
        .rst_i                     (rst),
        .p_addr_i                  (reqInUse_paddr),
        .oe_i                      (reqInUse_oe),
        .we_i                      (reqInUse_we),
        .st_q_data_i               (reqInUse_stq_data),
        .st_data_vec_i             (reqInUse_vec),
        .DCache_SwapBuf_Line_i     (dcache_swapBuf_line_i),
        .read_D_SWAP_i             (fsm_Read_DSWAP),
        .Write_VSWAP_i             (fsm_Write_VSWAP),
        .busy_i                    (block_busy_i),
        .WR_2_EB                   (fsm_WR_2_EB),
        .tagStore_hit_i            (hit),
        .useSavedIDX               (useSavedIDX),
        .hitIDX_i                  (hitIDX),
        .evictionIDX_i             (evictionIDX),
        .savedIDX_i                (savedIDX),
        .VCache_DataStore_LineOut_o(vcache_dataStore_Line)
    );

    // ===============================================================
    // Output assignments (mirror SV lines 163-173)
    //
    // CRITICAL (mirror SV lines 47-52, 172): block_req_p_addr_fields uses
    // CURRENT blockReq_i.p_addr (NOT reqInUse). The bank field of addrOut
    // is sliced from blockReq_paddr_i, not reqInUse_paddr. This is a
    // direct, faithful translation of the SV - do NOT switch to reqInUse.
    // ===============================================================
    assign outputs_hit_o                       = hit;
    assign outputs_miss_o                      = miss;
    assign outputs_swapBuf_valid_o             = swapBuf_valid_q;
    assign outputs_swapBuf_dirty_o             = swapBuf_dirty_q;
    assign outputs_swapBuf_lineAddr_o          = swapBuf_lineAddr_q;
    assign outputs_swapBuf_line_o              = swapBuf_line_q;
    assign outputs_D_Cache_swapBuf_valid_clr_o = fsm_CLR_D_SWAP_V;
    assign outputs_LD_EB_o                     = fsm_WR_2_EB;
    assign outputs_busy_o                      = fsm_busy;
    assign outputs_beingBlocked_o              = fsm_blocked;
    assign outputs_lineOut_o                   = vcache_dataStore_Line;

    // addrOut = {currTag (9b), blockReq_i.p_addr[5:4] (2b), 4'b0000}
    //   note: blockReq_i (NOT reqInUse) per SV line 50
    assign outputs_addrOut_o = {currTag, blockReq_paddr_i[5:4], 4'b0000};

endmodule
