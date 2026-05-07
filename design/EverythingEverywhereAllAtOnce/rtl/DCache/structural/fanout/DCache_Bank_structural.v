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
    //pass this through a buf, should be fine
    wire [14:0] reqInUse_paddr;
    wire [127:0] reqInUse_stq_data;
    wire [15:0] reqInUse_vec;

    `MUX_2(u_reqInUse_oe,    1,   reqInUse_oe,       blockReq_oe_i,       savedReq_oe_q,       useSavedReq)
    // u_reqInUse_we external fanout 21 -> bufferH64$. u_reqInUse_paddr fanout 23/bit -> bufferH64$ per bit.
    wire        reqInUse_we_pre;
    wire [14:0] reqInUse_paddr_pre;
    `MUX_2(u_reqInUse_we,    1,   reqInUse_we_pre,    blockReq_we_i,       savedReq_we_q,       useSavedReq)
    `MUX_2(u_reqInUse_paddr, 15,  reqInUse_paddr_pre, blockReq_paddr_i,    savedReq_paddr_q,    useSavedReq)
    bufferH64$ u_reqInUse_we_buf (.out(reqInUse_we), .in(reqInUse_we_pre));
    genvar bp_i;
    generate
        for (bp_i = 0; bp_i < 15; bp_i = bp_i + 1) begin : g_buf_reqInUse_paddr
            bufferH64$ u_buf (.out(reqInUse_paddr[bp_i]), .in(reqInUse_paddr_pre[bp_i]));
        end
    endgenerate
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

    `OR_2 (u_oe_or_we,      1, oe_or_we,       reqInUse_oe, reqInUse_we)
    `INV_N(u_not_block_busy,1, block_busy_i,   not_block_busy)
    `AND_2(u_doAccess,      1, doAccess,       not_block_busy, oe_or_we)
    `CMP_N(u_tag_eq,        6, tag_eq,         currTag, paddr_tag)
    `AND_2(u_tag_eq_and_v,  1, tag_eq_and_v,   tag_eq, currLineValid)
    // u_hit external fanout 147 -> bufferH256$.  miss (13) -> bufferH16$.  writeSuccess2TagStore (8) -> bufferH16$.
    wire hit_pre;
    wire miss_pre;
    wire writeSuccess2TagStore_pre;
    `AND_2(u_hit,           1, hit_pre,        tag_eq_and_v, doAccess)
    bufferH256$ u_hit_buf (.out(hit), .in(hit_pre));
    `INV_N(u_not_hit,       1, hit,            not_hit)
    `AND_2(u_miss,          1, miss_pre,       doAccess, not_hit)
    bufferH16$  u_miss_buf (.out(miss), .in(miss_pre));
    `AND_2(u_wr_success,    1, writeSuccess2TagStore_pre, hit, reqInUse_we)
    bufferH16$  u_wr_success_buf (.out(writeSuccess2TagStore), .in(writeSuccess2TagStore_pre));

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
