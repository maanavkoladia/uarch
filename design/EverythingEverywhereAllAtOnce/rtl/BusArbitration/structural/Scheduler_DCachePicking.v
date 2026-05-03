// ============================================================================
// Scheduler_DCachePicking.v
// ============================================================================
// Structural Verilog-2005 port of Scheduler_DCachePicking.sv
//   - all struct ports flattened to per-bank wire vectors
//   - all `always_comb` replaced with `assign` + STDCell macro instances
//   - GE comparators built from INV_N + ADD_N + MUX_2 (cout = A>=B)
//   - 4-bit comparators on req[3:0] (req_2_sch_t values 0..14 fit in 4 bits)
// ============================================================================

module Scheduler_DCachePicking (
    // EB addresses (15-bit p_address_t per port)
    input  wire [14:0] d_Cache_eb_addr_0_i,
    input  wire [14:0] d_Cache_eb_addr_1_i,
    input  wire [14:0] d_Cache_eb_addr_2_i,
    input  wire [14:0] d_Cache_eb_addr_3_i,

    // DCache requests (4-bit req_2_sch_t per port, pre EB-clash filter)
    input  wire [3:0]  d_cache_reqs_dirty_0_i,
    input  wire [3:0]  d_cache_reqs_dirty_1_i,
    input  wire [3:0]  d_cache_reqs_dirty_2_i,
    input  wire [3:0]  d_cache_reqs_dirty_3_i,

    input  wire [7:0]  writeBuf_V_i,

    output wire [3:0]  bestPick_o,
    output wire [1:0]  bestPick_BK_ID_o
);

    // ------------------------------------------------------------------
    // EB bankgroup index = eb_addr[MEM_BANKGROUP_BITS_UB:MEM_BANKGROUP_BITS_LD]
    //   = eb_addr[6:4]   (3 bits, selects 1-of-8 writeBuf_V bits)
    // ------------------------------------------------------------------
    wire [2:0] eb_bg_0;  assign eb_bg_0 = d_Cache_eb_addr_0_i[6:4];
    wire [2:0] eb_bg_1;  assign eb_bg_1 = d_Cache_eb_addr_1_i[6:4];
    wire [2:0] eb_bg_2;  assign eb_bg_2 = d_Cache_eb_addr_2_i[6:4];
    wire [2:0] eb_bg_3;  assign eb_bg_3 = d_Cache_eb_addr_3_i[6:4];

    // ------------------------------------------------------------------
    // Per-bank: lookup writeBuf_V at this bank's EB bankgroup index
    // ------------------------------------------------------------------
    wire wbV_at_eb_bg_0, wbV_at_eb_bg_1, wbV_at_eb_bg_2, wbV_at_eb_bg_3;

    `MUX_8(u_wbv_eb_mux_0, 1, wbV_at_eb_bg_0,
           writeBuf_V_i[0], writeBuf_V_i[1], writeBuf_V_i[2], writeBuf_V_i[3],
           writeBuf_V_i[4], writeBuf_V_i[5], writeBuf_V_i[6], writeBuf_V_i[7],
           eb_bg_0)

    `MUX_8(u_wbv_eb_mux_1, 1, wbV_at_eb_bg_1,
           writeBuf_V_i[0], writeBuf_V_i[1], writeBuf_V_i[2], writeBuf_V_i[3],
           writeBuf_V_i[4], writeBuf_V_i[5], writeBuf_V_i[6], writeBuf_V_i[7],
           eb_bg_1)

    `MUX_8(u_wbv_eb_mux_2, 1, wbV_at_eb_bg_2,
           writeBuf_V_i[0], writeBuf_V_i[1], writeBuf_V_i[2], writeBuf_V_i[3],
           writeBuf_V_i[4], writeBuf_V_i[5], writeBuf_V_i[6], writeBuf_V_i[7],
           eb_bg_2)

    `MUX_8(u_wbv_eb_mux_3, 1, wbV_at_eb_bg_3,
           writeBuf_V_i[0], writeBuf_V_i[1], writeBuf_V_i[2], writeBuf_V_i[3],
           writeBuf_V_i[4], writeBuf_V_i[5], writeBuf_V_i[6], writeBuf_V_i[7],
           eb_bg_3)

    // ------------------------------------------------------------------
    // Per-bank: blocking-enum detect (5 enum values, 4-bit equality)
    //   13 = DCACHE_EB_BLOCKING_BANK
    //   12 = DCACHE_EB_BLOCKING_ST_OVERRIDE
    //   11 = DCACHE_EB_BLOCKING_LD
    //   10 = DCACHE_EB_BLOCK_ST
    //    6 = DCACHE_EB_WR
    // ------------------------------------------------------------------
    wire eq_blk_bank_0,   eq_blk_bank_1,   eq_blk_bank_2,   eq_blk_bank_3;
    wire eq_blk_st_ovr_0, eq_blk_st_ovr_1, eq_blk_st_ovr_2, eq_blk_st_ovr_3;
    wire eq_blk_ld_0,     eq_blk_ld_1,     eq_blk_ld_2,     eq_blk_ld_3;
    wire eq_blk_st_0,     eq_blk_st_1,     eq_blk_st_2,     eq_blk_st_3;
    wire eq_eb_wr_0,      eq_eb_wr_1,      eq_eb_wr_2,      eq_eb_wr_3;

    `CMP_N(u_eq_blkbank_0, 4, eq_blk_bank_0,   d_cache_reqs_dirty_0_i, 4'd13)
    `CMP_N(u_eq_blkstov_0, 4, eq_blk_st_ovr_0, d_cache_reqs_dirty_0_i, 4'd12)
    `CMP_N(u_eq_blkld_0,   4, eq_blk_ld_0,     d_cache_reqs_dirty_0_i, 4'd11)
    `CMP_N(u_eq_blkst_0,   4, eq_blk_st_0,     d_cache_reqs_dirty_0_i, 4'd10)
    `CMP_N(u_eq_ebwr_0,    4, eq_eb_wr_0,      d_cache_reqs_dirty_0_i, 4'd6)

    `CMP_N(u_eq_blkbank_1, 4, eq_blk_bank_1,   d_cache_reqs_dirty_1_i, 4'd13)
    `CMP_N(u_eq_blkstov_1, 4, eq_blk_st_ovr_1, d_cache_reqs_dirty_1_i, 4'd12)
    `CMP_N(u_eq_blkld_1,   4, eq_blk_ld_1,     d_cache_reqs_dirty_1_i, 4'd11)
    `CMP_N(u_eq_blkst_1,   4, eq_blk_st_1,     d_cache_reqs_dirty_1_i, 4'd10)
    `CMP_N(u_eq_ebwr_1,    4, eq_eb_wr_1,      d_cache_reqs_dirty_1_i, 4'd6)

    `CMP_N(u_eq_blkbank_2, 4, eq_blk_bank_2,   d_cache_reqs_dirty_2_i, 4'd13)
    `CMP_N(u_eq_blkstov_2, 4, eq_blk_st_ovr_2, d_cache_reqs_dirty_2_i, 4'd12)
    `CMP_N(u_eq_blkld_2,   4, eq_blk_ld_2,     d_cache_reqs_dirty_2_i, 4'd11)
    `CMP_N(u_eq_blkst_2,   4, eq_blk_st_2,     d_cache_reqs_dirty_2_i, 4'd10)
    `CMP_N(u_eq_ebwr_2,    4, eq_eb_wr_2,      d_cache_reqs_dirty_2_i, 4'd6)

    `CMP_N(u_eq_blkbank_3, 4, eq_blk_bank_3,   d_cache_reqs_dirty_3_i, 4'd13)
    `CMP_N(u_eq_blkstov_3, 4, eq_blk_st_ovr_3, d_cache_reqs_dirty_3_i, 4'd12)
    `CMP_N(u_eq_blkld_3,   4, eq_blk_ld_3,     d_cache_reqs_dirty_3_i, 4'd11)
    `CMP_N(u_eq_blkst_3,   4, eq_blk_st_3,     d_cache_reqs_dirty_3_i, 4'd10)
    `CMP_N(u_eq_ebwr_3,    4, eq_eb_wr_3,      d_cache_reqs_dirty_3_i, 4'd6)

    wire any_blk_0, any_blk_1, any_blk_2, any_blk_3;
    `OR_5(u_any_blk_0, 1, any_blk_0,
          eq_blk_bank_0, eq_blk_st_ovr_0, eq_blk_ld_0, eq_blk_st_0, eq_eb_wr_0)
    `OR_5(u_any_blk_1, 1, any_blk_1,
          eq_blk_bank_1, eq_blk_st_ovr_1, eq_blk_ld_1, eq_blk_st_1, eq_eb_wr_1)
    `OR_5(u_any_blk_2, 1, any_blk_2,
          eq_blk_bank_2, eq_blk_st_ovr_2, eq_blk_ld_2, eq_blk_st_2, eq_eb_wr_2)
    `OR_5(u_any_blk_3, 1, any_blk_3,
          eq_blk_bank_3, eq_blk_st_ovr_3, eq_blk_ld_3, eq_blk_st_3, eq_eb_wr_3)

    // ------------------------------------------------------------------
    // Per-bank: EB clash = blocking AND wbV[bg] -> clears req to NO_REQ (0)
    // ------------------------------------------------------------------
//     wire eb_clash_0, eb_clash_1, eb_clash_2, eb_clash_3;
    wire eb_no_clash_0, eb_no_clash_1, eb_no_clash_2, eb_no_clash_3;

    `NAND_2(u_clash_0, 1, eb_no_clash_0, any_blk_0, wbV_at_eb_bg_0)
    `NAND_2(u_clash_1, 1, eb_no_clash_1, any_blk_1, wbV_at_eb_bg_1)
    `NAND_2(u_clash_2, 1, eb_no_clash_2, any_blk_2, wbV_at_eb_bg_2)
    `NAND_2(u_clash_3, 1, eb_no_clash_3, any_blk_3, wbV_at_eb_bg_3)

    //wire eb_no_clash_0, eb_no_clash_1, eb_no_clash_2, eb_no_clash_3;
//     `INV_N(u_inv_clash_0, 1, eb_clash_0, eb_no_clash_0)
//     `INV_N(u_inv_clash_1, 1, eb_clash_1, eb_no_clash_1)
//     `INV_N(u_inv_clash_2, 1, eb_clash_2, eb_no_clash_2)
//     `INV_N(u_inv_clash_3, 1, eb_clash_3, eb_no_clash_3)

    wire [3:0] mask_0, mask_1, mask_2, mask_3;
    assign mask_0 = {4{eb_no_clash_0}};
    assign mask_1 = {4{eb_no_clash_1}};
    assign mask_2 = {4{eb_no_clash_2}};
    assign mask_3 = {4{eb_no_clash_3}};

    wire [3:0] req_clean_0, req_clean_1, req_clean_2, req_clean_3;
    `AND_2(u_mask_0, 4, req_clean_0, d_cache_reqs_dirty_0_i, mask_0)
    `AND_2(u_mask_1, 4, req_clean_1, d_cache_reqs_dirty_1_i, mask_1)
    `AND_2(u_mask_2, 4, req_clean_2, d_cache_reqs_dirty_2_i, mask_2)
    `AND_2(u_mask_3, 4, req_clean_3, d_cache_reqs_dirty_3_i, mask_3)

    // ------------------------------------------------------------------
    // GE comparator macro pattern (4-bit, A,B):
    //   ~B  -> ADD A + ~B + 1  -> cout = (A >= B)
    //   MUX selects A on ge=1, B on ge=0
    // ------------------------------------------------------------------

    // Pair pick: bank 0 vs bank 1
    wire [3:0] req_clean_1_inv4;
    `INV_N(u_inv_b01, 4, req_clean_1, req_clean_1_inv4)
    wire [3:0] sub01_sum_unused;
    wire ge_01;
    `ADD_N(u_sub_01, 4, sub01_sum_unused, ge_01,
           req_clean_0, req_clean_1_inv4, 1'b1)

    wire [3:0] pick_01;
    `MUX_2(u_pick_01_val, 4, pick_01, req_clean_1, req_clean_0, ge_01)
    wire [1:0] pick_01_id;
    `MUX_2(u_pick_01_id, 2, pick_01_id, 2'd1, 2'd0, ge_01)

    // Pair pick: bank 2 vs bank 3
    wire [3:0] req_clean_3_inv4;
    `INV_N(u_inv_b23, 4, req_clean_3, req_clean_3_inv4)
    wire [3:0] sub23_sum_unused;
    wire ge_23;
    `ADD_N(u_sub_23, 4, sub23_sum_unused, ge_23,
           req_clean_2, req_clean_3_inv4, 1'b1)

    wire [3:0] pick_23;
    `MUX_2(u_pick_23_val, 4, pick_23, req_clean_3, req_clean_2, ge_23)
    wire [1:0] pick_23_id;
    `MUX_2(u_pick_23_id, 2, pick_23_id, 2'd3, 2'd2, ge_23)

    // Final pick: pair-01 winner vs pair-23 winner
    wire [3:0] pick_23_inv4;
    `INV_N(u_inv_pickf, 4, pick_23, pick_23_inv4)
    wire [3:0] sub_final_sum_unused;
    wire ge_final;
    `ADD_N(u_sub_final, 4, sub_final_sum_unused, ge_final,
           pick_01, pick_23_inv4, 1'b1)

    `MUX_2(u_pick_final_val, 4, bestPick_o,       pick_23,    pick_01,    ge_final)
    `MUX_2(u_pick_final_id, 2,  bestPick_BK_ID_o, pick_23_id, pick_01_id, ge_final)

endmodule
