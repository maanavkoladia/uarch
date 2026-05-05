// Structural Verilog 2005 port of DCache_Bank.
// Reference SV: rtl/DCache/DCache_Block/DCache_Bank/DCache_Bank.sv
// This is the bank "shell": it instantiates the FSM (already structural,
// in gen/DCache_Bank_FSM.sv), the structural TagStore, and the
// structural DataStore. It holds the dcache_swapBuf register set, the
// savedReq snapshot register set, and the hit/miss combinational logic.

module DCache_Bank(
    input  wire         clk,
    input  wire         rst,                                   // active-low

    // ---- v_cache_outputs_t (only fields the bank uses) ----
    input  wire         vcache_miss_i,
    input  wire         vcache_DCache_swapBuf_valid_clr_i,
    input  wire         vcache_swapBuf_dirty_i,
    input  wire [127:0] vcache_swapBuf_line_i,                 // cache line OK as one wire

    // ---- eb_outputs_t ----
    input  wire         eb_reqHit_i,

    // ---- DTE ----
    input  wire         mem_Valid_FromDte_i,

    // ---- block_req_t ----
    input  wire         blockReq_oe_i,
    input  wire         blockReq_we_i,
    input  wire [14:0]  blockReq_paddr_i,
    input  wire [127:0] blockReq_stq_data_i,                   // cache line
    input  wire [15:0]  blockReq_vec_i,

    // ---- block-busy from DCache_Block ----
    input  wire         block_busy_i,

    // ---- 32-bit fill bus ----
    input  wire [31:0]  dataBus,

    // ---- d_cache_bank_outputs_t (unpacked) ----
    output wire         dcacheBankOut_hit_o,
    output wire         dcacheBankOut_swapBuf_valid_o,
    output wire         dcacheBankOut_swapBuf_dirty_o,
    output wire [14:0]  dcacheBankOut_swapBuf_addr_o,
    output wire [127:0] dcacheBankOut_swapBuf_line_o,
    output wire         dcacheBankOut_VCache_swapBuf_valid_clr_o,
    output wire         dcacheBankOut_D_will_evict_o,
    output wire         dcacheBankOut_busy_o,
    output wire [127:0] dcacheBankOut_data_lineOut_o,
    output wire         dcacheBankOut_MakeReq_o,
    output wire         dcacheBankOut_eb_stalling_o
);

    // ===============================================================
    // savedReq register set (snapshot of blockReq_i taken when the FSM
    // is idle, used while the FSM is busy serving a fill / swap)
    //   we = saveReq = ~fsm_busy
    //   d  = corresponding blockReq_*_i field
    // ===============================================================
    wire        saveReq;                       // = ~fsm_busy
    wire        savedReq_oe_q;
    wire        savedReq_we_q;
    wire [14:0] savedReq_paddr_q;
    wire [127:0] savedReq_stq_data_q;
    wire [15:0] savedReq_vec_q;

    

    // ===============================================================
    // FSM output wires (computed below by the FSM instance)
    // ===============================================================
    wire fsm_S_0, fsm_S_1, fsm_S_2, fsm_S_3;          // current state
    wire fsm_write_to_dswap;
    wire fsm_D_will_evict;
    wire fsm_ldFrom_V_swap;
    wire fsm_clr_v_swap;
    wire fsm_MakeReq;
    wire fsm_Blocked;
    wire fsm_busy;
    wire fsm_fill0, fsm_fill1, fsm_fill2, fsm_fill3;

    // saveReq derives from fsm_busy
    `INV_N(u_saveReq, 1, fsm_busy, saveReq)

    // wire         blockReq_oe_i_delay;
    // wire         blockReq_we_i_delay;
    // wire [14:0]  blockReq_paddr_i_delay;
    // wire [127:0] blockReq_stq_data_i_delay;                   // cache line
    // wire [15:0]  blockReq_vec_i_delay;

    // assign #2 blockReq_oe_i_delay = blockReq_oe_i;
    // assign #2 blockReq_we_i_delay = blockReq_we_i;
    // assign #2 blockReq_paddr_i_delay = blockReq_paddr_i;
    // assign #2 blockReq_stq_data_i_delay = blockReq_stq_data_i;
    // assign #2 blockReq_vec_i_delay = blockReq_vec_i;





    `REG_RST_WE(u_savedReq_oe,    1,   clk, rst, saveReq, blockReq_oe_i,       savedReq_oe_q)
    `REG_RST_WE(u_savedReq_we,    1,   clk, rst, saveReq, blockReq_we_i,       savedReq_we_q)
    `REG_RST_WE(u_savedReq_paddr, 15,  clk, rst, saveReq, blockReq_paddr_i,    savedReq_paddr_q)
    `REG_RST_WE(u_savedReq_stq,   128, clk, rst, saveReq, blockReq_stq_data_i, savedReq_stq_data_q)
    `REG_RST_WE(u_savedReq_vec,   16,  clk, rst, saveReq, blockReq_vec_i,      savedReq_vec_q)

    // ===============================================================
    // reqInUse mux:  fsm_busy ? savedReq : blockReq_i
    //   sel = useSavedReq = fsm_busy
    // ===============================================================
    wire        useSavedReq;
    assign useSavedReq = fsm_busy;

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
    // p_addr field slices (wire aliases — matches DCACHE_BANK_*_UB/LB
    // in DCache_common_pkg)
    //   tag    : [14:9]   (6 bits)
    //   index  : [8:6]    (3 bits)
    //   bank   : [5:4]    (2 bits)
    //   offset : [3:0]    (4 bits)
    // ===============================================================
    wire [5:0] paddr_tag;
    wire [2:0] paddr_index;
    wire [1:0] paddr_bank;
    assign paddr_tag   = reqInUse_paddr[14:9];
    assign paddr_index = reqInUse_paddr[8:6];
    assign paddr_bank  = reqInUse_paddr[5:4];

    // ===============================================================
    // TagStore + DataStore output nets
    // ===============================================================
    wire [5:0]  currTag;
    wire        currLineValid;
    wire        currLineDirty;
    wire [127:0] dataStore_line;

    // ===============================================================
    // Hit / miss / writeSuccess combinational logic
    //   doAccess = ~block_busy & (oe | we)
    //   hit      = (currTag == paddr_tag) & currLineValid & doAccess
    //   miss     = doAccess & ~hit
    //   writeSuccess = hit & we
    // ===============================================================
    wire doAccess;
    wire oe_or_we;
    wire not_block_busy;
    wire tag_eq;
    wire tag_eq_and_v;
    wire hit;
    wire not_hit;
    wire miss;
    wire writeSuccess2TagStore;

    `OR_2 (u_oe_or_we,      1, oe_or_we,       reqInUse_oe, reqInUse_we)
    `INV_N(u_not_block_busy,1, block_busy_i,   not_block_busy)
    `AND_2(u_doAccess,      1, doAccess,       not_block_busy, oe_or_we)
    `CMP_N(u_tag_eq,        6, tag_eq,         currTag, paddr_tag)
    `AND_2(u_tag_eq_and_v,  1, tag_eq_and_v,   tag_eq, currLineValid)
    `AND_2(u_hit,           1, hit,            tag_eq_and_v, doAccess)
    `INV_N(u_not_hit,       1, hit,            not_hit)
    `AND_2(u_miss,          1, miss,           doAccess, not_hit)
    `AND_2(u_wr_success,    1, writeSuccess2TagStore, hit, reqInUse_we)

    // ===============================================================
    // dcache_bank_swapBuf register set
    //   valid    : we = clr | write_to_dswap; d = MUX(sel=clr, in0=write_to_dswap, in1=0)
    //              (clr wins; the mutually-mostly-exclusive case of clr+write
    //               resolves to clr-priority just like the SV)
    //   dirty    : we = write_to_dswap; d = currLineDirty
    //   lineAddr : we = write_to_dswap; d = {currTag, index, bank, 4'b0000}  (15 bits)
    //   line     : we = write_to_dswap; d = dataStore_line
    // ===============================================================
    wire        swapBuf_valid_we;
    wire        swapBuf_valid_d;
    wire        swapBuf_valid_q;
    wire        swapBuf_dirty_q;
    wire [14:0] swapBuf_addr_q;
    wire [127:0] swapBuf_line_q;

    `OR_2 (u_swapBuf_v_we, 1, swapBuf_valid_we,
           vcache_DCache_swapBuf_valid_clr_i, fsm_write_to_dswap)
    `MUX_2(u_swapBuf_v_d,  1, swapBuf_valid_d,
           fsm_write_to_dswap, 1'b0, vcache_DCache_swapBuf_valid_clr_i)

    `REG_RST_WE(u_swapBuf_valid, 1,   clk, rst, swapBuf_valid_we,   swapBuf_valid_d,   swapBuf_valid_q)
    `REG_RST_WE(u_swapBuf_dirty, 1,   clk, rst, fsm_write_to_dswap, currLineDirty,     swapBuf_dirty_q)

    // Eviction-address reconstruction (BUG FIX):
    //   tag    = currTag     (OLD tag at this slot, read from TagStore RAM
    //                         — NOT paddr_tag, which is the NEW request's tag)
    //   index  = paddr_index (current request's index — same as the OLD line's
    //                         index, since they conflict in the same slot)
    //   bank   = paddr_bank  (same reasoning)
    //   offset = 4'b0000     (offset bits don't matter for a line address)
    // Using paddr_tag here was the bug that latched the NEW address with
    // the OLD line's data (e.g. evicting 0x7000 to fit 0x7200 was storing
    // 0x7200 instead of 0x7000). Matches SV DCache_Bank.sv:171-173.
    wire [14:0] swapBuf_addr_d;
    assign swapBuf_addr_d = {currTag, paddr_index, paddr_bank, 4'b0000};
    `REG_RST_WE(u_swapBuf_addr,  15,  clk, rst, fsm_write_to_dswap, swapBuf_addr_d,    swapBuf_addr_q)
    `REG_RST_WE(u_swapBuf_line,  128, clk, rst, fsm_write_to_dswap, dataStore_line,    swapBuf_line_q)

    // ===============================================================
    // FSM instance  (already structural in gen/DCache_Bank_FSM.sv)
    // ===============================================================
    DCache_Bank_FSM dcache_bank_fsm_unit (
        .clk            (clk),
        .rst            (rst),
        .D_Miss_i       (miss),
        .V_Miss_i       (vcache_miss_i),
        .EB_Hit_i       (eb_reqHit_i),
        .Line_valid_i   (currLineValid),
        .DTE_Mem_valid_i(mem_Valid_FromDte_i),
        .D_Swap_valid_i (swapBuf_valid_q),
        .we_i           (reqInUse_we),

        .S_0(fsm_S_0),
        .S_1(fsm_S_1),
        .S_2(fsm_S_2),
        .S_3(fsm_S_3),

        .write_to_dswap_o(fsm_write_to_dswap),
        .D_will_evict_o  (fsm_D_will_evict),
        .ldFrom_V_swap_o (fsm_ldFrom_V_swap),
        .clr_v_swap_o    (fsm_clr_v_swap),
        .MakeReq_o       (fsm_MakeReq),
        .Blocked_o       (fsm_Blocked),
        .busy_o          (fsm_busy),
        .fill0_o         (fsm_fill0),
        .fill1_o         (fsm_fill1),
        .fill2_o         (fsm_fill2),
        .fill3_o         (fsm_fill3)
    );

    // ===============================================================
    // TagStore (structural)
    // ===============================================================
    DCache_Bank_TagStore DCache_Bank_TagStore_unit (
        .clk                     (clk),
        .rst                     (rst),
        .p_addr_i                (reqInUse_paddr),
        .oe_i                    (reqInUse_oe),
        .we_i                    (reqInUse_we),
        .ld_From_V_Swap_i        (fsm_ldFrom_V_swap),
        .V_Cache_SwapBuf_DirtyBit(vcache_swapBuf_dirty_i),
        .fill3_i                 (fsm_fill3),
        .write2_Dwap_i           (fsm_write_to_dswap),
        .bankControllerBusy_i    (block_busy_i),
        .writeSuccess            (writeSuccess2TagStore),
        .tagOut_o                (currTag),
        .currLine_V_o            (currLineValid),
        .currLine_Dirty_o        (currLineDirty)
    );

    // ===============================================================
    // DataStore (structural)
    // ===============================================================
    DCache_Bank_DataStore DCache_Bank_DataStore_unit (
        .clk                  (clk),
        .rst                  (rst),
        .p_addr_i             (reqInUse_paddr),
        .oe                   (reqInUse_oe),
        .we                   (reqInUse_we),
        .ld_From_V_Swap_i     (fsm_ldFrom_V_swap),
        .fill0_i              (fsm_fill0),
        .fill1_i              (fsm_fill1),
        .fill2_i              (fsm_fill2),
        .fill3_i              (fsm_fill3),
        .write2_Dwap_i        (fsm_write_to_dswap),
        .bankControllerBusy_i (block_busy_i),
        .stq_data_i           (reqInUse_stq_data),
        .st_data_vec          (reqInUse_vec),
        .vcache_swapBuf_line_i(vcache_swapBuf_line_i),
        .dataBus_i            (dataBus),
        .tagStore_hit_i       (hit),
        .lineOut_o            (dataStore_line)
    );

    // ===============================================================
    // Output assignments (wire aliasing only)
    // ===============================================================
    assign dcacheBankOut_hit_o                      = hit;
    assign dcacheBankOut_swapBuf_valid_o            = swapBuf_valid_q;
    assign dcacheBankOut_swapBuf_dirty_o            = swapBuf_dirty_q;
    assign dcacheBankOut_swapBuf_addr_o             = swapBuf_addr_q;
    assign dcacheBankOut_swapBuf_line_o             = swapBuf_line_q;
    assign dcacheBankOut_VCache_swapBuf_valid_clr_o = fsm_clr_v_swap;
    assign dcacheBankOut_D_will_evict_o             = fsm_D_will_evict;
    assign dcacheBankOut_busy_o                     = fsm_busy;
    assign dcacheBankOut_data_lineOut_o             = dataStore_line;
    assign dcacheBankOut_MakeReq_o                  = fsm_MakeReq;
    assign dcacheBankOut_eb_stalling_o              = fsm_Blocked;

endmodule
