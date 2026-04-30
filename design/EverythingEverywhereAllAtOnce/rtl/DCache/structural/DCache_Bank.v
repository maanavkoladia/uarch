// Structural Verilog-2005 port of
//   rtl/DCache/DCache_Block/DCache_Bank/DCache_Bank.sv

`include "STDCell_Macros.vh"
`include "DCache_common_define.vh"

module DCache_Bank (
    input  wire                                       clk,
    input  wire                                       rst,
    input  wire [`VC_OUT_W                  - 1 : 0]  V_Cache_i,
    input  wire [`EB_OUT_W                  - 1 : 0]  eb_i,
    input  wire                                       mem_Valid_FromDte_i,
    input  wire [`BREQ_W                    - 1 : 0]  blockReq_i,
    input  wire                                       block_busy_i,
    input  wire [`DATA_BUS_WIDTH_BITS       - 1 : 0]  dataBus,
    output wire [`DCB_OUT_W                 - 1 : 0]  outputs_o
);

    // Field extraction
    wire        vc_miss;
    wire        vc_dswap_vclr;
    wire [`SWAP_W - 1 : 0]  vc_swap_buf;
    wire [`CL_W   - 1 : 0]  vc_swap_line;
    wire        vc_swap_dirty;
    assign vc_miss       = V_Cache_i[`VC_OUT_MISS];
    assign vc_dswap_vclr = V_Cache_i[`VC_OUT_DSWAP_VCLR];
    assign vc_swap_buf   = V_Cache_i[`VC_OUT_SWAP_UB:`VC_OUT_SWAP_LB];
    assign vc_swap_line  = vc_swap_buf[`SWAP_LINE_UB:`SWAP_LINE_LB];
    assign vc_swap_dirty = vc_swap_buf[`SWAP_DIRTY];

    wire eb_reqHit;
    assign eb_reqHit = eb_i[`EB_OUT_REQHIT];

    // FSM signals
    wire [3:0] fsm_state_bits;
    wire fsm_write_to_dswap;
    wire fsm_D_will_evict;
    wire fsm_ldFrom_V_swap;
    wire fsm_clr_v_swap;
    wire fsm_MakeReq;
    wire fsm_Blocked;
    wire fsm_busy;
    wire fsm_fill0;
    wire fsm_fill1;
    wire fsm_fill2;
    wire fsm_fill3;

    // saveReq / useSavedReq / reqInUse
    wire saveReq;
    wire useSavedReq;
    `INV_N(inv_busy_savereq, 1, fsm_busy, saveReq)
    assign useSavedReq = fsm_busy;

    wire [`BREQ_W - 1 : 0] savedReq_q;
    wire [`BREQ_W - 1 : 0] reqInUse;
    `REG_RST_WE(ff_savedReq, `BREQ_W, clk, rst, saveReq, blockReq_i, savedReq_q)
    `MUX_2(mux_reqInUse, `BREQ_W, reqInUse, blockReq_i, savedReq_q, useSavedReq)

    // reqInUse field views
    wire        riu_oe;
    wire        riu_we;
    wire [`P_ADDR_W            - 1 : 0] riu_paddr;
    wire [`VEC_W               - 1 : 0] riu_vec;
    wire [`CL_W                - 1 : 0] riu_data;
    wire [`DCACHE_BANK_TAG_W   - 1 : 0] riu_tag;
    wire [`DCACHE_BANK_INDEX_W - 1 : 0] riu_idx;
    wire [`DCACHE_BANK_BANK_W  - 1 : 0] riu_bank;
    assign riu_oe   = reqInUse[`BREQ_OE];
    assign riu_we   = reqInUse[`BREQ_WE];
    assign riu_paddr= reqInUse[`BREQ_PADDR_UB:`BREQ_PADDR_LB];
    assign riu_vec  = reqInUse[`BREQ_VEC_UB:`BREQ_VEC_LB];
    assign riu_data = reqInUse[`BREQ_DATA_UB:`BREQ_DATA_LB];
    assign riu_tag  = riu_paddr[`DCACHE_BANK_TAG_UB  :`DCACHE_BANK_TAG_LB];
    assign riu_idx  = riu_paddr[`DCACHE_BANK_INDEX_UB:`DCACHE_BANK_INDEX_LB];
    assign riu_bank = riu_paddr[`DCACHE_BANK_BANK_UB :`DCACHE_BANK_BANK_LB];

    // dcache_bank_swapBuf flop bank
    wire        dswap_valid_q;
    wire        dswap_dirty_q;
    wire [`P_ADDR_W - 1 : 0] dswap_addr_q;
    wire [`CL_W     - 1 : 0] dswap_line_q;

    wire [`P_ADDR_W - 1 : 0] swap_lineAddr;
    assign swap_lineAddr = {riu_tag, riu_idx, riu_bank, 4'b0000};

    // Tag/Data submodule fwd-decl
    wire [`DCACHE_BANK_TAG_W - 1 : 0] currTag;
    wire        currLineValid;
    wire        currLineDirty;
    wire [`CL_W - 1 : 0] dataStore_Line;

    // valid: D = write_to_dswap, WE = clr_v_swap | write_to_dswap
    wire dswap_valid_we;
    `OR_2(or_dswap_v_we, 1, dswap_valid_we, vc_dswap_vclr, fsm_write_to_dswap)
    `REG_RST_WE(ff_dswap_valid, 1,         clk, rst, dswap_valid_we,     fsm_write_to_dswap, dswap_valid_q)
    `REG_RST_WE(ff_dswap_dirty, 1,         clk, rst, fsm_write_to_dswap, currLineDirty,      dswap_dirty_q)
    `REG_RST_WE(ff_dswap_addr,  `P_ADDR_W, clk, rst, fsm_write_to_dswap, swap_lineAddr,      dswap_addr_q)
    `REG_RST_WE(ff_dswap_line,  `CL_W,     clk, rst, fsm_write_to_dswap, dataStore_Line,     dswap_line_q)

    // Hit / miss / writeSuccess (fwd refs)
    wire access_or;
    wire block_busy_inv;
    wire doAccess;
    wire tag_eq;
    wire valid_and_acc;
    wire hit;
    wire hit_inv;
    wire miss;
    wire writeSuccess2TagStore;

    `OR_2 (or_doaccess_a,   1, access_or,             riu_oe,        riu_we)
    `INV_N(inv_blockbusy,   1, block_busy_i,          block_busy_inv)
    `AND_2(and_doaccess,    1, doAccess,              access_or,     block_busy_inv)
    `CMP_N(cmp_tag,         `DCACHE_BANK_TAG_W, tag_eq, currTag,     riu_tag)
    `AND_2(and_valacc,      1, valid_and_acc,         currLineValid, doAccess)
    `AND_2(and_hit,         1, hit,                   tag_eq,        valid_and_acc)
    `INV_N(inv_hit,         1, hit,                   hit_inv)
    `AND_2(and_miss,        1, miss,                  doAccess,      hit_inv)
    `AND_2(and_writeSucc,   1, writeSuccess2TagStore, hit,           riu_we)

    // FSM
    DCache_Bank_FSM dcache_bank_fsm_unit (
        .clk(clk),
        .rst(rst),
        .D_Miss_i(miss),
        .V_Miss_i(vc_miss),
        .EB_Hit_i(eb_reqHit),
        .Line_valid_i(currLineValid),
        .DTE_Mem_valid_i(mem_Valid_FromDte_i),
        .D_Swap_valid_i(dswap_valid_q),
        .we_i(riu_we),
        .S_0(fsm_state_bits[0]),
        .S_1(fsm_state_bits[1]),
        .S_2(fsm_state_bits[2]),
        .S_3(fsm_state_bits[3]),
        .write_to_dswap_o(fsm_write_to_dswap),
        .D_will_evict_o(fsm_D_will_evict),
        .ldFrom_V_swap_o(fsm_ldFrom_V_swap),
        .clr_v_swap_o(fsm_clr_v_swap),
        .MakeReq_o(fsm_MakeReq),
        .Blocked_o(fsm_Blocked),
        .busy_o(fsm_busy),
        .fill0_o(fsm_fill0),
        .fill1_o(fsm_fill1),
        .fill2_o(fsm_fill2),
        .fill3_o(fsm_fill3)
    );

    // DataStore
    DCache_Bank_DataStore DCache_Bank_DataStore_unit (
        .clk(clk),
        .rst(rst),
        .p_addr_i(riu_paddr),
        .oe(riu_oe),
        .we(riu_we),
        .ld_From_V_Swap_i(fsm_ldFrom_V_swap),
        .fill0_i(fsm_fill0),
        .fill1_i(fsm_fill1),
        .fill2_i(fsm_fill2),
        .fill3_i(fsm_fill3),
        .write2_Dwap_i(fsm_write_to_dswap),
        .bankControllerBusy_i(block_busy_i),
        .st_q_data(riu_data),
        .st_data_vec(riu_vec),
        .VCache_SwapBuf_Line_i(vc_swap_line),
        .dataBus_i(dataBus),
        .tagStore_hit_i(hit),
        .lineOut_o(dataStore_Line)
    );

    // TagStore
    DCache_Bank_TagStore DCache_Bank_TagStore_unit (
        .clk(clk),
        .rst(rst),
        .p_addr_i(riu_paddr),
        .oe_i(riu_oe),
        .we_i(riu_we),
        .ld_From_V_Swap_i(fsm_ldFrom_V_swap),
        .V_Cache_SwapBuf_DirtyBit(vc_swap_dirty),
        .fill3_i(fsm_fill3),
        .write2_Dwap_i(fsm_write_to_dswap),
        .bankControllerBusy_i(block_busy_i),
        .writeSuccess(writeSuccess2TagStore),
        .tagOut_o(currTag),
        .currLine_V_o(currLineValid),
        .currLine_Dirty_o(currLineDirty)
    );

    // Output assembly
    wire [`SWAP_W - 1 : 0] dswap_packed;
    assign dswap_packed[`SWAP_VALID]                  = dswap_valid_q;
    assign dswap_packed[`SWAP_DIRTY]                  = dswap_dirty_q;
    assign dswap_packed[`SWAP_ADDR_UB:`SWAP_ADDR_LB]  = dswap_addr_q;
    assign dswap_packed[`SWAP_LINE_UB:`SWAP_LINE_LB]  = dswap_line_q;

    assign outputs_o[`DCB_OUT_HIT]                       = hit;
    assign outputs_o[`DCB_OUT_SWAP_UB:`DCB_OUT_SWAP_LB]  = dswap_packed;
    assign outputs_o[`DCB_OUT_VSWAP_VCLR]                = fsm_clr_v_swap;
    assign outputs_o[`DCB_OUT_DWILLEVICT]                = fsm_D_will_evict;
    assign outputs_o[`DCB_OUT_BUSY]                      = fsm_busy;
    assign outputs_o[`DCB_OUT_LINE_UB:`DCB_OUT_LINE_LB]  = dataStore_Line;
    assign outputs_o[`DCB_OUT_MAKEREQ]                   = fsm_MakeReq;
    assign outputs_o[`DCB_OUT_EBSTALL]                   = fsm_Blocked;

endmodule
