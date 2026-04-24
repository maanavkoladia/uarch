module I_VCache (
    input  wire         clk,
    input  wire         rst,
    input  wire         busy_i,
    input  wire         en_i,
    input  wire [31:0]  v_addr_i,

    // IC_SwapBuf_i (decomposed)
    input  wire         IC_SwapBuf_i_valid,
    input  wire [31:0]  IC_SwapBuf_i_lineAddr,
    input  wire [127:0] IC_SwapBuf_i_line,

    // I_VC_SwapBuf_o (decomposed)
    output wire         I_VC_SwapBuf_o_valid,
    output wire [31:0]  I_VC_SwapBuf_o_lineAddr,
    output wire [127:0] I_VC_SwapBuf_o_line,

    output wire         hit_o,
    output wire         miss_o,
    output wire [127:0] dataLineOut_o,
    output wire         IC_SwapBuf_V_clr_o
);

    // ------------------------------------------------------------------
    // Address decomposition (pure wire slices)
    // ------------------------------------------------------------------
    wire [27:0] v_addr_i_tag;
    wire [27:0] IC_swapBuf_v_addr_tag;

    assign v_addr_i_tag          = v_addr_i[31:4];
    assign IC_swapBuf_v_addr_tag = IC_SwapBuf_i_lineAddr[31:4];

    // ------------------------------------------------------------------
    // Register state (driven by REG_RST_WE / REG_RST outputs)
    // ------------------------------------------------------------------
    wire         entry_valid_0, entry_valid_1, entry_valid_2, entry_valid_3;
    wire [27:0]  entry_tag_0,   entry_tag_1,   entry_tag_2,   entry_tag_3;
    wire [127:0] dataLine_0,    dataLine_1,    dataLine_2,    dataLine_3;

    wire         lru_root, lru_left, lru_right;
    wire         hitHappened;

    wire [31:0]  vcswap_lineAddr;
    wire [127:0] vcswap_line;

    // ------------------------------------------------------------------
    // Tag match per entry
    // ------------------------------------------------------------------
    wire tag_eq_raw_0, tag_eq_raw_1, tag_eq_raw_2, tag_eq_raw_3;

    `CMP_N(u_tagcmp_0, 28, tag_eq_raw_0, entry_tag_0, v_addr_i_tag)
    `CMP_N(u_tagcmp_1, 28, tag_eq_raw_1, entry_tag_1, v_addr_i_tag)
    `CMP_N(u_tagcmp_2, 28, tag_eq_raw_2, entry_tag_2, v_addr_i_tag)
    `CMP_N(u_tagcmp_3, 28, tag_eq_raw_3, entry_tag_3, v_addr_i_tag)

    wire match_0, match_1, match_2, match_3;

    `AND_2(u_match_0, 1, match_0, tag_eq_raw_0, entry_valid_0)
    `AND_2(u_match_1, 1, match_1, tag_eq_raw_1, entry_valid_1)
    `AND_2(u_match_2, 1, match_2, tag_eq_raw_2, entry_valid_2)
    `AND_2(u_match_3, 1, match_3, tag_eq_raw_3, entry_valid_3)

    // ------------------------------------------------------------------
    // Hit aggregation (OR-based, assumes at-most-one match)
    // ------------------------------------------------------------------
    wire currTagHit;
    wire hit_idx_0, hit_idx_1;

    `OR_4(u_currTagHit, 1, currTagHit, match_0, match_1, match_2, match_3)
    `OR_2(u_hit_idx_0, 1, hit_idx_0, match_1, match_3)
    `OR_2(u_hit_idx_1, 1, hit_idx_1, match_2, match_3)

    // Packed hit_idx for mux sels
    wire [1:0] hit_idx;
    assign hit_idx = {hit_idx_1, hit_idx_0};

    // ------------------------------------------------------------------
    // currTag (28b) and currDataLine (128b) 4-way muxes
    // ------------------------------------------------------------------
    wire [27:0]  currTag;
    wire [127:0] currDataLine;

    `MUX_4(u_currTag_mux,  28, currTag,      entry_tag_0, entry_tag_1, entry_tag_2, entry_tag_3, hit_idx)
    `MUX_4(u_currData_mux, 128, currDataLine, dataLine_0,  dataLine_1,  dataLine_2,  dataLine_3,  hit_idx)

    // ------------------------------------------------------------------
    // Hit / miss outputs
    // ------------------------------------------------------------------
    wire busy_bar, currTagHit_bar;
    wire hit, miss;

    `INV_N(u_busy_bar,       1, busy_i,     busy_bar)
    `INV_N(u_currTagHit_bar, 1, currTagHit, currTagHit_bar)
    `AND_3(u_hit,            1, hit,  busy_bar, en_i, currTagHit)
    `AND_3(u_miss,           1, miss, busy_bar, en_i, currTagHit_bar)

    assign hit_o         = hit;
    assign miss_o        = miss;
    assign dataLineOut_o = currDataLine;

    // ------------------------------------------------------------------
    // I_VC swap buffer output (latched on hit)
    // ------------------------------------------------------------------
    wire [31:0] vcswap_lineAddr_d;
    assign vcswap_lineAddr_d = {currTag, 4'b0000};

    `REG_RST_WE(u_vcswap_la,   32, clk, rst, hit, vcswap_lineAddr_d, vcswap_lineAddr)
    `REG_RST_WE(u_vcswap_line, 128, clk, rst, hit, currDataLine,     vcswap_line)

    assign I_VC_SwapBuf_o_valid    = 1'b0;
    assign I_VC_SwapBuf_o_lineAddr = vcswap_lineAddr;
    assign I_VC_SwapBuf_o_line     = vcswap_line;

    // ------------------------------------------------------------------
    // hitHappened (1-cycle-latched hit, always-WE)
    // ------------------------------------------------------------------
    `REG_RST(u_hitHappened, 1, clk, rst, hit, hitHappened)

    // ------------------------------------------------------------------
    // LRU decode (combinational)
    //   currLRU_IDX[1] = !lru_root
    //   currLRU_IDX[0] = (!lru_root) ? !lru_right : !lru_left
    //   currMRU_IDX[1] =  lru_root
    //   currMRU_IDX[0] =  lru_root  ?  lru_right :  lru_left
    // ------------------------------------------------------------------
    wire lru_root_bar, lru_left_bar, lru_right_bar;

    `INV_N(u_lru_root_bar,  1, lru_root,  lru_root_bar)
    `INV_N(u_lru_left_bar,  1, lru_left,  lru_left_bar)
    `INV_N(u_lru_right_bar, 1, lru_right, lru_right_bar)

    wire currLRU_IDX_0, currLRU_IDX_1;
    wire currMRU_IDX_0, currMRU_IDX_1;

    assign currLRU_IDX_1 = lru_root_bar;
    assign currMRU_IDX_1 = lru_root;

    `MUX_2(u_lru_idx0, 1, currLRU_IDX_0, lru_left_bar, lru_right_bar, lru_root_bar)
    `MUX_2(u_mru_idx0, 1, currMRU_IDX_0, lru_left,     lru_right,     lru_root)

    wire [1:0] currLRU_IDX, currMRU_IDX;
    assign currLRU_IDX = {currLRU_IDX_1, currLRU_IDX_0};
    assign currMRU_IDX = {currMRU_IDX_1, currMRU_IDX_0};

    // ------------------------------------------------------------------
    // IDX_2_Write = hitHappened ? currMRU_IDX : currLRU_IDX
    // ------------------------------------------------------------------
    wire [1:0] IDX_2_Write;
    `MUX_2(u_idx2wr, 2, IDX_2_Write, currLRU_IDX, currMRU_IDX, hitHappened)

    // ------------------------------------------------------------------
    // updateLRU / update_idx
    //   RD_IC_SWAP_BUF = IC_SwapBuf_i.valid
    //   updateLRU      = hit | RD_IC_SWAP_BUF
    //   update_idx     = hit ? hit_idx : currLRU_IDX
    // ------------------------------------------------------------------
    wire RD_IC_SWAP_BUF;
    assign RD_IC_SWAP_BUF = IC_SwapBuf_i_valid;

    wire updateLRU;
    `OR_2(u_updateLRU, 1, updateLRU, hit, RD_IC_SWAP_BUF)

    wire [1:0] update_idx;
    `MUX_2(u_updidx, 2, update_idx, currLRU_IDX, hit_idx, hit)

    // ------------------------------------------------------------------
    // LRU register updates
    //   root  D=update_idx[1], WE=updateLRU
    //   left  D=update_idx[0], WE=updateLRU & !update_idx[1]
    //   right D=update_idx[0], WE=updateLRU &  update_idx[1]
    // ------------------------------------------------------------------
    wire we_root, we_left, we_right;
    wire update_idx_1_bar;

    `INV_N(u_updidx1_bar, 1, update_idx[1], update_idx_1_bar)

    assign we_root = updateLRU;
    `AND_2(u_we_left,  1, we_left,  updateLRU, update_idx_1_bar)
    `AND_2(u_we_right, 1, we_right, updateLRU, update_idx[1])

    `REG_RST_WE(u_lru_root,  1, clk, rst, we_root,  update_idx[1], lru_root)
    `REG_RST_WE(u_lru_left,  1, clk, rst, we_left,  update_idx[0], lru_left)
    `REG_RST_WE(u_lru_right, 1, clk, rst, we_right, update_idx[0], lru_right)

    // ------------------------------------------------------------------
    // Entry write (fill from IC swap buffer) — on updateLRU & RD_IC_SWAP_BUF
    // ------------------------------------------------------------------
    wire [3:0] idx_oh;
    wire we_entry_base;
    wire we_entry_0, we_entry_1, we_entry_2, we_entry_3;

    `DECODER_N(u_entry_dec, 2, IDX_2_Write, idx_oh)
    `AND_2(u_we_entry_base, 1, we_entry_base, updateLRU, RD_IC_SWAP_BUF)

    `AND_2(u_we_entry_0, 1, we_entry_0, idx_oh[0], we_entry_base)
    `AND_2(u_we_entry_1, 1, we_entry_1, idx_oh[1], we_entry_base)
    `AND_2(u_we_entry_2, 1, we_entry_2, idx_oh[2], we_entry_base)
    `AND_2(u_we_entry_3, 1, we_entry_3, idx_oh[3], we_entry_base)

    `REG_RST_WE(u_ev_0, 1, clk, rst, we_entry_0, 1'b1, entry_valid_0)
    `REG_RST_WE(u_ev_1, 1, clk, rst, we_entry_1, 1'b1, entry_valid_1)
    `REG_RST_WE(u_ev_2, 1, clk, rst, we_entry_2, 1'b1, entry_valid_2)
    `REG_RST_WE(u_ev_3, 1, clk, rst, we_entry_3, 1'b1, entry_valid_3)

    `REG_RST_WE(u_et_0, 28, clk, rst, we_entry_0, IC_swapBuf_v_addr_tag, entry_tag_0)
    `REG_RST_WE(u_et_1, 28, clk, rst, we_entry_1, IC_swapBuf_v_addr_tag, entry_tag_1)
    `REG_RST_WE(u_et_2, 28, clk, rst, we_entry_2, IC_swapBuf_v_addr_tag, entry_tag_2)
    `REG_RST_WE(u_et_3, 28, clk, rst, we_entry_3, IC_swapBuf_v_addr_tag, entry_tag_3)

    `REG_RST_WE(u_ed_0, 128, clk, rst, we_entry_0, IC_SwapBuf_i_line, dataLine_0)
    `REG_RST_WE(u_ed_1, 128, clk, rst, we_entry_1, IC_SwapBuf_i_line, dataLine_1)
    `REG_RST_WE(u_ed_2, 128, clk, rst, we_entry_2, IC_SwapBuf_i_line, dataLine_2)
    `REG_RST_WE(u_ed_3, 128, clk, rst, we_entry_3, IC_SwapBuf_i_line, dataLine_3)

    // ------------------------------------------------------------------
    // IC swap buffer clear flag (matches source: = RD_IC_SWAP_BUF)
    // ------------------------------------------------------------------
    assign IC_SwapBuf_V_clr_o = IC_SwapBuf_i_valid;

endmodule
