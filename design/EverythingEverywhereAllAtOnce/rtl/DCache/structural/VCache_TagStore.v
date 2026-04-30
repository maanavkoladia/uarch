// Structural Verilog-2005 port of
//   rtl/DCache/DCache_Block/VCache/VCache_TagStore.sv
//
// Fully-associative 4-way tag store. 4 lines x 2 ram8b4w$ cells (tag is 9
// bits -> low byte + bit-8). Address tied 2'b00 (single location). Per-line
// metadata: valid + dirty (idx[1:0] is initialised to i but never mutated;
// no runtime use, omitted).
//
// Output: hit, miss, hitIdx, savedIdx, evictionIdx, currLine_Dirty,
//         VC_Will_Need_ToEvict, tagOut.
// Embeds the LRU module.

`include "STDCell_Macros.vh"
`include "DCache_common_define.vh"

module VCache_TagStore (
    input  wire                                       clk,
    input  wire                                       rst,                    // active-low
    input  wire [`P_ADDR_W                  - 1 : 0]  p_addr_i,
    input  wire                                       oe_i,
    input  wire                                       we_i,
    input  wire                                       Read_DSWAP_i,
    input  wire [`P_ADDR_W                  - 1 : 0]  D_Cache_SwapBuf_Addr,   // unused (kept for parity)
    input  wire                                       D_Cache_SwapBuf_DirtyBit,
    input  wire                                       DCache_Will_Evict_i,
    input  wire                                       saveIDX,
    input  wire                                       use_savedIDX,
    input  wire                                       busy_i,
    input  wire                                       WR_2_EB_i,
    input  wire                                       Write_VSWAP_i,
    input  wire                                       Update_LRU,
    output wire [`V_CACHE_TAG_W             - 1 : 0]  tagOut_o,
    output wire                                       hit_o,
    output wire                                       miss_o,
    output wire [`VCACHE_LINE_IDX_W         - 1 : 0]  hitIDX_o,
    output wire [`VCACHE_LINE_IDX_W         - 1 : 0]  evictionIDX_o,
    output wire [`VCACHE_LINE_IDX_W         - 1 : 0]  savedIDX_o,
    output wire                                       currLine_Dirty_o,
    output wire                                       VC_Will_Need_ToEvict_o
);

    //==================================================================
    // Address slice
    //==================================================================
    wire [`V_CACHE_TAG_W - 1 : 0] paddr_tag;
    assign paddr_tag = p_addr_i[`V_CACHE_TAG_UB:`V_CACHE_TAG_LB];

    //==================================================================
    // Phased clock
    //==================================================================
    wire clk_phase_45;
    `BUFFER_DELAY(u_clk_phase, `CLK_PHASE_BUFFER_STAGES, 1, clk, clk_phase_45)

    //==================================================================
    // savedIDX flop, currLRU_IDX from LRU module
    //==================================================================
    wire [1:0] savedIDX_q;
    wire [1:0] savedIDX_d;
    wire [1:0] currLRU_IDX;
    wire [1:0] hitIdx;

    //   savedIDX_d = DCache_Will_Evict ? currLRU_IDX : hitIdx
    `MUX_2(mux_savedIDX_d, 2, savedIDX_d, hitIdx, currLRU_IDX, DCache_Will_Evict_i)
    `REG_RST_WE(ff_savedIDX, 2, clk, rst, saveIDX, savedIDX_d, savedIDX_q)

    //   1-of-4 decodes for savedIDX, hitIdx, currLRU_IDX
    wire [3:0] savedIDX_dec;
    wire [3:0] hitIdx_dec;
    wire [3:0] currLRU_dec;
    `DECODER_N(u_dec_saved, 2, savedIDX_q,  savedIDX_dec)
    `DECODER_N(u_dec_hit,   2, hitIdx,      hitIdx_dec)
    `DECODER_N(u_dec_lru,   2, currLRU_IDX, currLRU_dec)

    //==================================================================
    // Per-line WR (active-low to ram cells)
    //   WR_actual[i] = ~(savedIDX_dec[i] & Read_DSWAP_i & clk_phase_45 & rst)
    //==================================================================
    wire        rd_phase_rst;
    wire        rd_phase_rst_a;
    `AND_2(and_rd_phase,    1, rd_phase_rst_a, Read_DSWAP_i, clk_phase_45)
    `AND_2(and_rd_phase_r,  1, rd_phase_rst,   rd_phase_rst_a, rst)
    wire [3:0] rd_phase_rst_v;
    assign rd_phase_rst_v = {4{rd_phase_rst}};

    wire [3:0] wr_active;
    wire [3:0] WR_actual;
    `AND_2(and_wractive, 4, wr_active, savedIDX_dec, rd_phase_rst_v)
    `INV_N(inv_wractual, 4, wr_active, WR_actual)

    //==================================================================
    // Per-line OE (active-low)
    //   doAccess = (oe|we) & ~busy
    //   OE_idx_dec : if use_savedIDX -> savedIDX_dec else currLRU_dec
    //   write_eb_or_vswap = WR_2_EB | Write_VSWAP
    //   line_active[i] = doAccess | (write_eb_or_vswap & OE_idx_dec[i])
    //   OE[i] = ~line_active[i]
    //==================================================================
    wire access_or;
    wire busy_inv;
    wire doAccess;
    `OR_2 (or_doaccess_v, 1, access_or, oe_i,            we_i)
    `INV_N(inv_busy_v,    1, busy_i,    busy_inv)
    `AND_2(and_doaccess_v,1, doAccess,  access_or,       busy_inv)

    wire [3:0] OE_idx_dec;
    `MUX_2(mux_oe_idx, 4, OE_idx_dec, currLRU_dec, savedIDX_dec, use_savedIDX)

    wire write_eb_or_vswap;
    `OR_2(or_write_eb_vs, 1, write_eb_or_vswap, WR_2_EB_i, Write_VSWAP_i)

    wire [3:0] write_eb_or_vswap_v;
    assign write_eb_or_vswap_v = {4{write_eb_or_vswap}};

    wire [3:0] write_target_active;
    `AND_2(and_wt_active, 4, write_target_active, write_eb_or_vswap_v, OE_idx_dec)

    wire [3:0] doAccess_v;
    assign doAccess_v = {4{doAccess}};

    wire [3:0] line_active;
    wire [3:0] OE_per_line;
    `OR_2 (or_line_active, 4, line_active, doAccess_v, write_target_active)
    `INV_N(inv_oe_perline, 4, line_active, OE_per_line)

    //==================================================================
    // DIN: tag is 9 bits, sourced from D_Cache_SwapBuf_Addr's tag field.
    // Split: low byte -> cell 0, bit-8 zero-extended -> cell 1.
    //==================================================================
    wire [`V_CACHE_TAG_W - 1 : 0] dswap_tag;
    assign dswap_tag = D_Cache_SwapBuf_Addr[`V_CACHE_TAG_UB:`V_CACHE_TAG_LB];

    wire [7:0] DIN_low;
    wire [7:0] DIN_high;
    assign DIN_low  = dswap_tag[7:0];
    assign DIN_high = {7'b0, dswap_tag[8]};

    //==================================================================
    // 4 lines x 2 ram cells
    //==================================================================
    wire [7:0] cell_dout_lo[0:3];
    wire [7:0] cell_dout_hi[0:3];

    genvar gi;
    generate
        for (gi = 0; gi < 4; gi = gi + 1) begin : g_tag_lines
            ram8b4w$ tagStoreCell_lo (
                .A   (2'b00),
                .DIN (DIN_low),
                .OE  (OE_per_line[gi]),
                .WR  (WR_actual[gi]),
                .DOUT(cell_dout_lo[gi])
            );
            ram8b4w$ tagStoreCell_hi (
                .A   (2'b00),
                .DIN (DIN_high),
                .OE  (OE_per_line[gi]),
                .WR  (WR_actual[gi]),
                .DOUT(cell_dout_hi[gi])
            );
        end
    endgenerate

    //   Reassemble each line's 9-bit tag: bit-8 from cell_hi[0], rest from cell_lo
    wire [`V_CACHE_TAG_W - 1 : 0] line_tag [0:3];
    assign line_tag[0] = {cell_dout_hi[0][0], cell_dout_lo[0]};
    assign line_tag[1] = {cell_dout_hi[1][0], cell_dout_lo[1]};
    assign line_tag[2] = {cell_dout_hi[2][0], cell_dout_lo[2]};
    assign line_tag[3] = {cell_dout_hi[3][0], cell_dout_lo[3]};

    //==================================================================
    // Per-line metadata flops (valid, dirty)
    //==================================================================
    wire [3:0] valid_q;
    wire [3:0] dirty_q;

    //   valid: WE = (Read_DSWAP & savedIDX_dec[i]); D=1
    wire [3:0] valid_we_arr;
    wire [3:0] read_dswap_v;
    assign read_dswap_v = {4{Read_DSWAP_i}};
    `AND_2(and_v_we_vt, 4, valid_we_arr, read_dswap_v, savedIDX_dec)

    `REG_RST_WE(ff_valid_v0, 1, clk, rst, valid_we_arr[0], 1'b1, valid_q[0])
    `REG_RST_WE(ff_valid_v1, 1, clk, rst, valid_we_arr[1], 1'b1, valid_q[1])
    `REG_RST_WE(ff_valid_v2, 1, clk, rst, valid_we_arr[2], 1'b1, valid_q[2])
    `REG_RST_WE(ff_valid_v3, 1, clk, rst, valid_we_arr[3], 1'b1, valid_q[3])

    //   dirty:
    //     dswap path: WE_dswap[i] = Read_DSWAP & savedIDX_dec[i] ; D = D_Cache_SwapBuf_DirtyBit
    //     ws    path: WE_ws[i]    = writeSuccess & hitIdx_dec[i]; D = 1
    //     combined: D = ws_active ? 1 : dswap_dirty
    //               WE = WE_dswap | WE_ws
    wire [3:0] line_hit;
    wire        hit_any;
    wire        miss;
    wire        writeSuccess;
    // (computed below; forward decl here.)

    wire [3:0] ws_we_arr;
    wire [3:0] ws_v;
    wire [3:0] dirty_we_arr;
    wire [3:0] dirty_d_arr;
    wire [3:0] dswap_dirty_v;
    assign ws_v          = {4{writeSuccess}};
    assign dswap_dirty_v = {4{D_Cache_SwapBuf_DirtyBit}};

    `AND_2(and_d_we_ws, 4, ws_we_arr,    ws_v,         hitIdx_dec)
    `OR_2 (or_d_we,     4, dirty_we_arr, valid_we_arr, ws_we_arr)

    //   D per line: ws_we_arr[i] ? 1 : D_Cache_SwapBuf_DirtyBit
    `MUX_2(mux_dirty_d_l0, 1, dirty_d_arr[0], dswap_dirty_v[0], 1'b1, ws_we_arr[0])
    `MUX_2(mux_dirty_d_l1, 1, dirty_d_arr[1], dswap_dirty_v[1], 1'b1, ws_we_arr[1])
    `MUX_2(mux_dirty_d_l2, 1, dirty_d_arr[2], dswap_dirty_v[2], 1'b1, ws_we_arr[2])
    `MUX_2(mux_dirty_d_l3, 1, dirty_d_arr[3], dswap_dirty_v[3], 1'b1, ws_we_arr[3])

    `REG_RST_WE(ff_dirty_v0, 1, clk, rst, dirty_we_arr[0], dirty_d_arr[0], dirty_q[0])
    `REG_RST_WE(ff_dirty_v1, 1, clk, rst, dirty_we_arr[1], dirty_d_arr[1], dirty_q[1])
    `REG_RST_WE(ff_dirty_v2, 1, clk, rst, dirty_we_arr[2], dirty_d_arr[2], dirty_q[2])
    `REG_RST_WE(ff_dirty_v3, 1, clk, rst, dirty_we_arr[3], dirty_d_arr[3], dirty_q[3])

    //==================================================================
    // 4-way tag compare
    //==================================================================
    wire [3:0] tag_eq;
    `CMP_N(cmp_tag_l0, `V_CACHE_TAG_W, tag_eq[0], line_tag[0], paddr_tag)
    `CMP_N(cmp_tag_l1, `V_CACHE_TAG_W, tag_eq[1], line_tag[1], paddr_tag)
    `CMP_N(cmp_tag_l2, `V_CACHE_TAG_W, tag_eq[2], line_tag[2], paddr_tag)
    `CMP_N(cmp_tag_l3, `V_CACHE_TAG_W, tag_eq[3], line_tag[3], paddr_tag)

    `AND_2(and_lh, 4, line_hit, tag_eq, valid_q)

    //   hit_any = OR(line_hit), gated by doAccess
    wire        hit_or01, hit_or23, hit_or_full;
    `OR_2(or_lh01, 1, hit_or01,    line_hit[0], line_hit[1])
    `OR_2(or_lh23, 1, hit_or23,    line_hit[2], line_hit[3])
    `OR_2(or_lh,   1, hit_or_full, hit_or01,    hit_or23)

    `AND_2(and_hit_v, 1, hit_any, hit_or_full, doAccess)

    //   hitIdx: line_hit is one-hot (cache invariant)
    //     hitIdx[1] = OR(line_hit[2], line_hit[3])
    //     hitIdx[0] = OR(line_hit[1], line_hit[3])
    `OR_2(or_hidx1, 1, hitIdx[1], line_hit[2], line_hit[3])
    `OR_2(or_hidx0, 1, hitIdx[0], line_hit[1], line_hit[3])

    //   miss = doAccess & ~hit
    wire hit_inv_v;
    `INV_N(inv_hit_v, 1, hit_any, hit_inv_v)
    `AND_2(and_miss_v, 1, miss,   doAccess, hit_inv_v)

    //   writeSuccess = hit & we
    `AND_2(and_ws, 1, writeSuccess, hit_any, we_i)

    //==================================================================
    // tagOut_o : driven by Write_VSWAP (use vswap idx) or WR_2_EB (use eb idx)
    //   tag_out_write_to_vswap_idx = use_savedIDX ? savedIDX : hitIdx
    //   tag_out_write_to_eb_idx    = use_savedIDX ? savedIDX : currLRU_IDX
    //   In source, WR_2_EB overrides Write_VSWAP if both fire.
    //==================================================================
    wire [1:0] vswap_idx;
    wire [1:0] eb_idx;
    `MUX_2(mux_vswap_idx, 2, vswap_idx, hitIdx,      savedIDX_q, use_savedIDX)
    `MUX_2(mux_eb_idx,    2, eb_idx,    currLRU_IDX, savedIDX_q, use_savedIDX)

    wire [1:0] tag_out_idx;
    `MUX_2(mux_tag_out_idx, 2, tag_out_idx, vswap_idx, eb_idx, WR_2_EB_i)

    //   tagOut_o = mux of line_tag[0..3] indexed by tag_out_idx
    `MUX_4(mux_tag_out, `V_CACHE_TAG_W, tagOut_o,
           line_tag[0], line_tag[1], line_tag[2], line_tag[3], tag_out_idx)

    //==================================================================
    // currLine_Dirty_o : mux dirty_q indexed by (use_savedIDX ? savedIDX : hitIdx)
    //==================================================================
    wire [1:0] currLine_Dirty_idx;
    `MUX_2(mux_cld_idx, 2, currLine_Dirty_idx, hitIdx, savedIDX_q, use_savedIDX)
    `MUX_4(mux_cld, 1, currLine_Dirty_o,
           dirty_q[0], dirty_q[1], dirty_q[2], dirty_q[3], currLine_Dirty_idx)

    //==================================================================
    // VC_Will_Need_ToEvict_o = dirty[currLRU_IDX] & valid[currLRU_IDX]
    //==================================================================
    wire dirty_at_lru;
    wire valid_at_lru;
    `MUX_4(mux_dirty_lru, 1, dirty_at_lru,
           dirty_q[0], dirty_q[1], dirty_q[2], dirty_q[3], currLRU_IDX)
    `MUX_4(mux_valid_lru, 1, valid_at_lru,
           valid_q[0], valid_q[1], valid_q[2], valid_q[3], currLRU_IDX)
    `AND_2(and_vc_evict, 1, VC_Will_Need_ToEvict_o, dirty_at_lru, valid_at_lru)

    //==================================================================
    // evictionIDX_o = use_savedIDX ? savedIDX : currLRU_IDX
    //==================================================================
    `MUX_2(mux_evict_idx, 2, evictionIDX_o, currLRU_IDX, savedIDX_q, use_savedIDX)

    //==================================================================
    // LRU module
    //==================================================================
    LRU LRU_unit (
        .clk(clk),
        .rst(rst),
        .updateLRU(Update_LRU),
        .savedIDX(savedIDX_q),
        .currLRU_IDX(currLRU_IDX)
    );

    //==================================================================
    // Direct outputs
    //==================================================================
    assign hit_o      = hit_any;
    assign miss_o     = miss;
    assign hitIDX_o   = hitIdx;
    assign savedIDX_o = savedIDX_q;

endmodule
