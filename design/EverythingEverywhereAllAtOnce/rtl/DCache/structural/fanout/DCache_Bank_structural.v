// Pure Verilog 2005 port of DCache_Bank.
// Reference: rtl/DCache/structural/DCache_Bank.sv
// Bank "shell": instantiates the FSM (DCache_Bank_FSM, lives outside the
// structural folder), the structural TagStore, and the structural DataStore.
// Holds the dcache_swapBuf register set, the savedReq snapshot register set,
// and the hit/miss combinational logic.

module DCache_Bank(
    input  wire         clk,
    input  wire         rst,                                   // active-low

    input  wire         vcache_miss_i,
    input  wire         vcache_DCache_swapBuf_valid_clr_i,
    input  wire         vcache_swapBuf_dirty_i,
    input  wire [127:0] vcache_swapBuf_line_i,

    input  wire         eb_reqHit_i,

    input  wire         mem_Valid_FromDte_i,

    input  wire         blockReq_oe_i,
    input  wire         blockReq_we_i,
    input  wire [14:0]  blockReq_paddr_i,
    input  wire [127:0] blockReq_stq_data_i,
    input  wire [15:0]  blockReq_vec_i,

    input  wire         block_busy_i,

    input  wire [31:0]  dataBus,

    output wire         dcacheBankOut_hit_o,
    // 32 replicated copies of `hit` for DCache_Block's MUX_4(128) split into
    // 32 chunks of MUX_4(4). Each bit feeds 4 mux4 cells -> per-net fanout=4.
    output wire [31:0]  dcacheBankOut_hit_for_mux_o,
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

    wire        saveReq;
    wire        savedReq_oe_q;
    wire        savedReq_we_q;
    wire [14:0] savedReq_paddr_q;
    wire [127:0] savedReq_stq_data_q;
    wire [15:0] savedReq_vec_q;

    wire fsm_S_0, fsm_S_1, fsm_S_2, fsm_S_3;
    wire fsm_write_to_dswap;
    wire fsm_D_will_evict;
    wire fsm_ldFrom_V_swap;
    wire fsm_clr_v_swap;
    wire fsm_MakeReq;
    wire fsm_Blocked;
    wire fsm_busy;
    wire fsm_fill0, fsm_fill1, fsm_fill2, fsm_fill3;

    `INV_N(u_saveReq, 1, fsm_busy, saveReq)

    `REG_RST_WE(u_savedReq_oe,    1,   clk, rst, saveReq, blockReq_oe_i,       savedReq_oe_q)
    `REG_RST_WE(u_savedReq_we,    1,   clk, rst, saveReq, blockReq_we_i,       savedReq_we_q)
    `REG_RST_WE(u_savedReq_paddr, 15,  clk, rst, saveReq, blockReq_paddr_i,    savedReq_paddr_q)
    `REG_RST_WE(u_savedReq_stq,   128, clk, rst, saveReq, blockReq_stq_data_i, savedReq_stq_data_q)
    `REG_RST_WE(u_savedReq_vec,   16,  clk, rst, saveReq, blockReq_vec_i,      savedReq_vec_q)

    wire        useSavedReq;
    assign useSavedReq = fsm_busy;

    wire        reqInUse_oe;
    wire        reqInUse_we;
    wire [14:0] reqInUse_paddr;
    wire [127:0] reqInUse_stq_data;
    wire [15:0] reqInUse_vec;

    `MUX_2(u_reqInUse_oe,    1,   reqInUse_oe,       blockReq_oe_i,       savedReq_oe_q,       useSavedReq)
    // u_reqInUse_we fanout=12 (drives we_i in TagStore + DataStore + FSM input + flat).
    // bufferH16$ +0.24 ns, off cache read-hit critical path (we gates write events
    // and FSM transitions; reads don't depend on we).
    wire reqInUse_we_pre;
    `MUX_2(u_reqInUse_we,    1,   reqInUse_we_pre,   blockReq_we_i,       savedReq_we_q,       useSavedReq)
    bufferH16$ u_reqInUse_we_buf (.out(reqInUse_we), .in(reqInUse_we_pre));
    `MUX_2(u_reqInUse_paddr, 15,  reqInUse_paddr,    blockReq_paddr_i,    savedReq_paddr_q,    useSavedReq)
    `MUX_2(u_reqInUse_stq,   128, reqInUse_stq_data, blockReq_stq_data_i, savedReq_stq_data_q, useSavedReq)
    `MUX_2(u_reqInUse_vec,   16,  reqInUse_vec,      blockReq_vec_i,      savedReq_vec_q,      useSavedReq)

    wire [5:0] paddr_tag;
    wire [2:0] paddr_index;
    wire [1:0] paddr_bank;
    assign paddr_tag   = reqInUse_paddr[14:9];
    assign paddr_index = reqInUse_paddr[8:6];
    assign paddr_bank  = reqInUse_paddr[5:4];

    wire [5:0]  currTag;
    wire        currLineValid;
    wire        currLineDirty;
    wire [127:0] dataStore_line;

    wire doAccess;
    wire oe_or_we;
    wire not_block_busy;
    wire tag_eq;
    wire tag_eq_and_v;
    wire hit;
    wire not_hit;
    wire miss;
    wire writeSuccess2TagStore;
    wire currLineValid_for_fsm;     // 2nd copy of currLineValid for FSM only

    // ================================================================
    // CASCADE-FIXED `hit` CHAIN (was fanout 147 single AND_2)
    //
    // Goal: every wire has <=4 fanout, EXCEPT one bufferH16$ at the
    // currLineValid / not_block_busy / oe_or_we cascade-termination
    // points (each handles 10 loads through one bufferH16$ tier).
    // Net hit critical-path delay added: +0.24 ns (single buffer in
    // series). Replicated cells where cascade was clean (no buffer).
    //
    // Layer 1 (37 u_hit copies): hit, hit_for_DS[3:0], hit_for_mux[31:0]
    // Layer 2 (10 each):         u_tag_eq_and_v, u_doAccess
    // Layer 3 (3 each):          u_tag_eq    (no buffer needed)
    //                            buffered:  currLineValid, not_block_busy, oe_or_we
    // ================================================================

    // ---- Layer 3 (cascade roots) ----
    // tag_eq replicated x3 (no buffer): currTag/paddr_tag fanout was 1, now 3 (<=4 ok)
    wire [2:0] tag_eq_dup;
    `CMP_N(u_tag_eq_0, 6, tag_eq_dup[0], currTag, paddr_tag)
    `CMP_N(u_tag_eq_1, 6, tag_eq_dup[1], currTag, paddr_tag)
    `CMP_N(u_tag_eq_2, 6, tag_eq_dup[2], currTag, paddr_tag)
    // alias for legacy single-use sites that still want `tag_eq`
    assign tag_eq = tag_eq_dup[0];

    // currLineValid is consumed by FSM (.Line_valid_i, fanout 1) AND the 10
    // tag_eq_and_v copies. Buffer ONLY for the 10 copies; FSM gets the raw
    // signal so it doesn't pay the +0.24 ns.
    wire currLineValid_buf;
    bufferH16$ u_clv_buf (.out(currLineValid_buf), .in(currLineValid));

    // u_not_block_busy: still 1 INV; buffer its output for 10 doAccess copies
    `INV_N(u_not_block_busy,1, block_busy_i,   not_block_busy)
    wire not_block_busy_buf;
    bufferH16$ u_nbb_buf (.out(not_block_busy_buf), .in(not_block_busy));

    // u_oe_or_we: still 1 OR_2; buffer its output for 10 doAccess copies
    `OR_2 (u_oe_or_we,      1, oe_or_we,       reqInUse_oe, reqInUse_we)
    wire oe_or_we_buf;
    bufferH16$ u_oow_buf (.out(oe_or_we_buf), .in(oe_or_we));

    // ---- Layer 2 ----
    // 10 u_tag_eq_and_v copies (each fanout 4 to u_hit dups)
    wire [9:0] tag_eq_and_v_dup;
    genvar tev;
    generate
        for (tev = 0; tev < 10; tev = tev + 1) begin : g_tev
            `AND_2(u_taeqv, 1, tag_eq_and_v_dup[tev], tag_eq_dup[tev/4], currLineValid_buf)
        end
    endgenerate
    assign tag_eq_and_v = tag_eq_and_v_dup[0];  // alias for any legacy usage

    // 10 u_doAccess copies (each fanout 4 to u_hit dups)
    wire [9:0] doAccess_dup;
    genvar da;
    generate
        for (da = 0; da < 10; da = da + 1) begin : g_da
            `AND_2(u_doAccess_dup, 1, doAccess_dup[da], not_block_busy_buf, oe_or_we_buf)
        end
    endgenerate
    // doAccess_dup[9] has spare capacity (only hit_dup[36] uses it = 1 load).
    // Hand u_miss the same dup so doAccess_dup[9] = 1 (hit) + 1 (miss) = 2 loads.
    assign doAccess = doAccess_dup[9];

    // ---- Layer 1: 37 u_hit copies ----
    //   hit_dup[0]    -> 1 misc (3 internal + the ext load via dcacheBankOut_hit_o)
    //   hit_dup[1..4] -> 4 copies for DataStore byte groups (tagStore_hit_i[3:0])
    //   hit_dup[5..36]-> 32 copies for DCache_Block MUX_4 chunks (dcacheBankOut_hit_for_mux_o[31:0])
    //   Each hit_dup[k] consumes (tag_eq_and_v_dup[k/4], doAccess_dup[k/4]) -> per-input fanout 4.
    wire [36:0] hit_dup;
    genvar hk;
    generate
        for (hk = 0; hk < 37; hk = hk + 1) begin : g_hit
            `AND_2(u_hit_dup, 1, hit_dup[hk], tag_eq_and_v_dup[hk/4], doAccess_dup[hk/4])
        end
    endgenerate

    // The misc `hit` wire used by u_not_hit, u_wr_success, dcacheBankOut_hit_o.
    assign hit = hit_dup[0];

    // 4 hit copies for DataStore (byte groups 0-3, 4-7, 8-11, 12-15)
    wire [3:0] hit_for_DS;
    assign hit_for_DS = hit_dup[4:1];

    // 32 hit copies for the MUX_4 chunks in DCache_Block
    assign dcacheBankOut_hit_for_mux_o = hit_dup[36:5];

    // ---- Misc: not_hit, miss, writeSuccess2TagStore (use hit_dup[0]) ----
    `INV_N(u_not_hit,       1, hit,            not_hit)
    // u_miss fanout=5 (drives FSM D_Miss_i input + flat). bufferH16$ +0.24 ns,
    // off cache read-hit path (FSM transitions only).
    wire miss_pre;
    `AND_2(u_miss,          1, miss_pre,       doAccess, not_hit)
    bufferH16$ u_miss_buf (.out(miss), .in(miss_pre));
    // u_wr_success fanout=8 (drives writeSuccess into TagStore for 8 dirty_d
    // gates per line). bufferH16$ +0.24 ns, off read-hit (write success sets
    // dirty bit, parallel with the read result).
    wire writeSuccess2TagStore_pre;
    `AND_2(u_wr_success,    1, writeSuccess2TagStore_pre, hit, reqInUse_we)
    bufferH16$ u_wr_success_buf (.out(writeSuccess2TagStore), .in(writeSuccess2TagStore_pre));

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

    wire [14:0] swapBuf_addr_d;
    assign swapBuf_addr_d = {currTag, paddr_index, paddr_bank, 4'b0000};
    `REG_RST_WE(u_swapBuf_addr,  15,  clk, rst, fsm_write_to_dswap, swapBuf_addr_d,    swapBuf_addr_q)
    `REG_RST_WE(u_swapBuf_line,  128, clk, rst, fsm_write_to_dswap, dataStore_line,    swapBuf_line_q)

    DCache_Bank_FSM dcache_bank_fsm_unit (
        .clk            (clk),
        .rst            (rst),
        .D_Miss_i       (miss),
        .V_Miss_i       (vcache_miss_i),
        .EB_Hit_i       (eb_reqHit_i),
        .Line_valid_i   (currLineValid_for_fsm),
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
        .currLine_V_for_fsm_o    (currLineValid_for_fsm),
        .currLine_Dirty_o        (currLineDirty)
    );

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
        .tagStore_hit_i       (hit_for_DS),
        .lineOut_o            (dataStore_line)
    );

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
