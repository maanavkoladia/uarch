// ============================================================================
// Scheduler_DCachePicking.v  — phase-1 unified 7-way priority max
// ============================================================================
// Picks the global bestPick across all 7 request sources in a single
// GE-depth, in priority order (lower index wins on tie):
//
//   i=0..3 : DC bank 0..3
//   i=4    : ICache
//   i=5    : MIO
//   i=6    : DMA
//
//   - EB-clash front-end (per DC port) unchanged: produces eb_no_clash_0..3
//     (1 = port not clashing).  DMA clash bit (1 = DMA clashing) arrives
//     pre-computed on `dma_clash_i` from the parent's writeBuf_V[dma_bg]
//     mux.
//   - Clash bits are NOT pre-applied to the req values.  Instead they are
//     folded into the win-decoder so the EB front-end runs in parallel
//     with the GE compares (saves ~4 levels vs masking the req first).
//   - 21 parallel 4-bit GE compares (kogge_stone cout) cover every i<j.
//     gt_ji = ~ge_ij — single inverter, free.
//   - win_i = ~clash[i] AND AND_j ( clash[j] | beats(i,j) )
//        beats(i,j) = ge_ij  if j > i   (tie -> i, the lower index)
//                   = gt_ij  if j < i   (j has higher priority -> strict)
//     IC and MIO have no own-clash, so their win is plain AND_6 of terms.
//   - Output mux is one-hot AND-OR across the 7 win signals.
//
// (Non-fanout copy: matches structural/fanout/ except no bufferH16$ trees.
//  The fanout copy adds bufferH16$ on >4-fanout nets; logic is identical.)
// ============================================================================

module Scheduler_DCachePicking (
    // EB addresses (15-bit p_address_t per port)
    input  wire [14:0] d_Cache_eb_addr_0_i,
    input  wire [14:0] d_Cache_eb_addr_1_i,
    input  wire [14:0] d_Cache_eb_addr_2_i,
    input  wire [14:0] d_Cache_eb_addr_3_i,

    // DCache requests (4-bit req_2_sch_t per port; raw, NOT pre-masked)
    input  wire [3:0]  d_cache_reqs_dirty_0_i,
    input  wire [3:0]  d_cache_reqs_dirty_1_i,
    input  wire [3:0]  d_cache_reqs_dirty_2_i,
    input  wire [3:0]  d_cache_reqs_dirty_3_i,

    // ICache, MIO, DMA reqs (raw, NOT pre-masked)
    input  wire [3:0]  i_cache_req_i,
    input  wire [3:0]  mio_req_i,
    input  wire [3:0]  dma_req_i,

    // writeBuf_V[8] for the per-DC EB-clash front-end
    input  wire [7:0]  writeBuf_V_i,
    // DMA clash bit from parent: 1 = wbV[dma_addr[6:4]] == 1 (treat as NO_REQ)
    input  wire        dma_clash_i,

    output wire [3:0]  bestPick_o,
    output wire [1:0]  bestPick_BK_ID_o
);

    // =============================================================
    // EB-clash front-end (per DC port) — unchanged in spirit.
    //   Produces eb_no_clash_0..3 (1 = port i is NOT clashing).
    // =============================================================
    wire [2:0] eb_bg_0;  assign eb_bg_0 = d_Cache_eb_addr_0_i[6:4];
    wire [2:0] eb_bg_1;  assign eb_bg_1 = d_Cache_eb_addr_1_i[6:4];
    wire [2:0] eb_bg_2;  assign eb_bg_2 = d_Cache_eb_addr_2_i[6:4];
    wire [2:0] eb_bg_3;  assign eb_bg_3 = d_Cache_eb_addr_3_i[6:4];

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

    //   13 = DCACHE_EB_BLOCKING_BANK
    //   12 = DCACHE_EB_BLOCKING_ST_OVERRIDE
    //   11 = DCACHE_EB_BLOCKING_LD
    //   10 = DCACHE_EB_BLOCK_ST
    //    6 = DCACHE_EB_WR
    wire eq_blk_bank_0, eq_blk_bank_1, eq_blk_bank_2, eq_blk_bank_3;
    wire eq_blk_st_ovr_0, eq_blk_st_ovr_1, eq_blk_st_ovr_2, eq_blk_st_ovr_3;
    wire eq_blk_ld_0, eq_blk_ld_1, eq_blk_ld_2, eq_blk_ld_3;
    wire eq_blk_st_0, eq_blk_st_1, eq_blk_st_2, eq_blk_st_3;
    wire eq_eb_wr_0, eq_eb_wr_1, eq_eb_wr_2, eq_eb_wr_3;
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

    wire eb_no_clash_0, eb_no_clash_1, eb_no_clash_2, eb_no_clash_3;
    `NAND_2(u_clash_0, 1, eb_no_clash_0, any_blk_0, wbV_at_eb_bg_0)
    `NAND_2(u_clash_1, 1, eb_no_clash_1, any_blk_1, wbV_at_eb_bg_1)
    `NAND_2(u_clash_2, 1, eb_no_clash_2, any_blk_2, wbV_at_eb_bg_2)
    `NAND_2(u_clash_3, 1, eb_no_clash_3, any_blk_3, wbV_at_eb_bg_3)

    // =============================================================
    // clash_0..3 = ~eb_no_clash_0..3.  clash_6 alias for dma_clash_i.
    // dma_no_clash = ~clash_6 (used in win_6's AND_7).
    // =============================================================
    wire clash_0, clash_1, clash_2, clash_3, clash_6;
    `INV_N(u_inv_clash_0, 1, eb_no_clash_0, clash_0)
    `INV_N(u_inv_clash_1, 1, eb_no_clash_1, clash_1)
    `INV_N(u_inv_clash_2, 1, eb_no_clash_2, clash_2)
    `INV_N(u_inv_clash_3, 1, eb_no_clash_3, clash_3)
    assign clash_6 = dma_clash_i;

    wire dma_no_clash;
    `INV_N(u_inv_dma_no_clash, 1, clash_6, dma_no_clash)

    // =============================================================
    // Raw req aliases.
    // =============================================================
    wire [3:0] r0;  assign r0 = d_cache_reqs_dirty_0_i;
    wire [3:0] r1;  assign r1 = d_cache_reqs_dirty_1_i;
    wire [3:0] r2;  assign r2 = d_cache_reqs_dirty_2_i;
    wire [3:0] r3;  assign r3 = d_cache_reqs_dirty_3_i;
    wire [3:0] r4;  assign r4 = i_cache_req_i;
    wire [3:0] r5;  assign r5 = mio_req_i;
    wire [3:0] r6;  assign r6 = dma_req_i;

    // =============================================================
    // 21 parallel 4-bit GE compares (kogge_stone cout).
    //   ge_ij = (r_i >= r_j) = cout( r_i + ~r_j + 1 )
    // =============================================================
    wire [3:0] r1_inv4_for_01;  `INV_N(u_inv_b01, 4, r1, r1_inv4_for_01)
    wire [3:0] s_01;  wire ge_01;
    `ADD_N(u_sub_01, 4, s_01, ge_01, r0, r1_inv4_for_01, 1'b1)

    wire [3:0] r2_inv4_for_02;  `INV_N(u_inv_b02, 4, r2, r2_inv4_for_02)
    wire [3:0] s_02;  wire ge_02;
    `ADD_N(u_sub_02, 4, s_02, ge_02, r0, r2_inv4_for_02, 1'b1)

    wire [3:0] r3_inv4_for_03;  `INV_N(u_inv_b03, 4, r3, r3_inv4_for_03)
    wire [3:0] s_03;  wire ge_03;
    `ADD_N(u_sub_03, 4, s_03, ge_03, r0, r3_inv4_for_03, 1'b1)

    wire [3:0] r4_inv4_for_04;  `INV_N(u_inv_b04, 4, r4, r4_inv4_for_04)
    wire [3:0] s_04;  wire ge_04;
    `ADD_N(u_sub_04, 4, s_04, ge_04, r0, r4_inv4_for_04, 1'b1)

    wire [3:0] r5_inv4_for_05;  `INV_N(u_inv_b05, 4, r5, r5_inv4_for_05)
    wire [3:0] s_05;  wire ge_05;
    `ADD_N(u_sub_05, 4, s_05, ge_05, r0, r5_inv4_for_05, 1'b1)

    wire [3:0] r6_inv4_for_06;  `INV_N(u_inv_b06, 4, r6, r6_inv4_for_06)
    wire [3:0] s_06;  wire ge_06;
    `ADD_N(u_sub_06, 4, s_06, ge_06, r0, r6_inv4_for_06, 1'b1)

    wire [3:0] r2_inv4_for_12;  `INV_N(u_inv_b12, 4, r2, r2_inv4_for_12)
    wire [3:0] s_12;  wire ge_12;
    `ADD_N(u_sub_12, 4, s_12, ge_12, r1, r2_inv4_for_12, 1'b1)

    wire [3:0] r3_inv4_for_13;  `INV_N(u_inv_b13, 4, r3, r3_inv4_for_13)
    wire [3:0] s_13;  wire ge_13;
    `ADD_N(u_sub_13, 4, s_13, ge_13, r1, r3_inv4_for_13, 1'b1)

    wire [3:0] r4_inv4_for_14;  `INV_N(u_inv_b14, 4, r4, r4_inv4_for_14)
    wire [3:0] s_14;  wire ge_14;
    `ADD_N(u_sub_14, 4, s_14, ge_14, r1, r4_inv4_for_14, 1'b1)

    wire [3:0] r5_inv4_for_15;  `INV_N(u_inv_b15, 4, r5, r5_inv4_for_15)
    wire [3:0] s_15;  wire ge_15;
    `ADD_N(u_sub_15, 4, s_15, ge_15, r1, r5_inv4_for_15, 1'b1)

    wire [3:0] r6_inv4_for_16;  `INV_N(u_inv_b16, 4, r6, r6_inv4_for_16)
    wire [3:0] s_16;  wire ge_16;
    `ADD_N(u_sub_16, 4, s_16, ge_16, r1, r6_inv4_for_16, 1'b1)

    wire [3:0] r3_inv4_for_23;  `INV_N(u_inv_b23, 4, r3, r3_inv4_for_23)
    wire [3:0] s_23;  wire ge_23;
    `ADD_N(u_sub_23, 4, s_23, ge_23, r2, r3_inv4_for_23, 1'b1)

    wire [3:0] r4_inv4_for_24;  `INV_N(u_inv_b24, 4, r4, r4_inv4_for_24)
    wire [3:0] s_24;  wire ge_24;
    `ADD_N(u_sub_24, 4, s_24, ge_24, r2, r4_inv4_for_24, 1'b1)

    wire [3:0] r5_inv4_for_25;  `INV_N(u_inv_b25, 4, r5, r5_inv4_for_25)
    wire [3:0] s_25;  wire ge_25;
    `ADD_N(u_sub_25, 4, s_25, ge_25, r2, r5_inv4_for_25, 1'b1)

    wire [3:0] r6_inv4_for_26;  `INV_N(u_inv_b26, 4, r6, r6_inv4_for_26)
    wire [3:0] s_26;  wire ge_26;
    `ADD_N(u_sub_26, 4, s_26, ge_26, r2, r6_inv4_for_26, 1'b1)

    wire [3:0] r4_inv4_for_34;  `INV_N(u_inv_b34, 4, r4, r4_inv4_for_34)
    wire [3:0] s_34;  wire ge_34;
    `ADD_N(u_sub_34, 4, s_34, ge_34, r3, r4_inv4_for_34, 1'b1)

    wire [3:0] r5_inv4_for_35;  `INV_N(u_inv_b35, 4, r5, r5_inv4_for_35)
    wire [3:0] s_35;  wire ge_35;
    `ADD_N(u_sub_35, 4, s_35, ge_35, r3, r5_inv4_for_35, 1'b1)

    wire [3:0] r6_inv4_for_36;  `INV_N(u_inv_b36, 4, r6, r6_inv4_for_36)
    wire [3:0] s_36;  wire ge_36;
    `ADD_N(u_sub_36, 4, s_36, ge_36, r3, r6_inv4_for_36, 1'b1)

    wire [3:0] r5_inv4_for_45;  `INV_N(u_inv_b45, 4, r5, r5_inv4_for_45)
    wire [3:0] s_45;  wire ge_45;
    `ADD_N(u_sub_45, 4, s_45, ge_45, r4, r5_inv4_for_45, 1'b1)

    wire [3:0] r6_inv4_for_46;  `INV_N(u_inv_b46, 4, r6, r6_inv4_for_46)
    wire [3:0] s_46;  wire ge_46;
    `ADD_N(u_sub_46, 4, s_46, ge_46, r4, r6_inv4_for_46, 1'b1)

    wire [3:0] r6_inv4_for_56;  `INV_N(u_inv_b56, 4, r6, r6_inv4_for_56)
    wire [3:0] s_56;  wire ge_56;
    `ADD_N(u_sub_56, 4, s_56, ge_56, r5, r6_inv4_for_56, 1'b1)

    // gt_ji = ~ge_ij — strict-greater for the priority direction where
    // j has higher priority on tie.  Each gt is a single 1-bit INV.
    wire gt_10, gt_20, gt_30, gt_40, gt_50, gt_60;
    wire gt_21, gt_31, gt_41, gt_51, gt_61;
    wire gt_32, gt_42, gt_52, gt_62;
    wire gt_43, gt_53, gt_63;
    wire gt_54, gt_64, gt_65;
    `INV_N(u_inv_gt_10, 1, ge_01, gt_10)
    `INV_N(u_inv_gt_20, 1, ge_02, gt_20)
    `INV_N(u_inv_gt_30, 1, ge_03, gt_30)
    `INV_N(u_inv_gt_40, 1, ge_04, gt_40)
    `INV_N(u_inv_gt_50, 1, ge_05, gt_50)
    `INV_N(u_inv_gt_60, 1, ge_06, gt_60)
    `INV_N(u_inv_gt_21, 1, ge_12, gt_21)
    `INV_N(u_inv_gt_31, 1, ge_13, gt_31)
    `INV_N(u_inv_gt_41, 1, ge_14, gt_41)
    `INV_N(u_inv_gt_51, 1, ge_15, gt_51)
    `INV_N(u_inv_gt_61, 1, ge_16, gt_61)
    `INV_N(u_inv_gt_32, 1, ge_23, gt_32)
    `INV_N(u_inv_gt_42, 1, ge_24, gt_42)
    `INV_N(u_inv_gt_52, 1, ge_25, gt_52)
    `INV_N(u_inv_gt_62, 1, ge_26, gt_62)
    `INV_N(u_inv_gt_43, 1, ge_34, gt_43)
    `INV_N(u_inv_gt_53, 1, ge_35, gt_53)
    `INV_N(u_inv_gt_63, 1, ge_36, gt_63)
    `INV_N(u_inv_gt_54, 1, ge_45, gt_54)
    `INV_N(u_inv_gt_64, 1, ge_46, gt_64)
    `INV_N(u_inv_gt_65, 1, ge_56, gt_65)

    // =============================================================
    // win_i term wires.  t_ij = clash[j] | beats(i,j) when j has clash;
    // beats(i,j) directly otherwise (j ∈ {4=IC, 5=MIO}).
    // =============================================================
    wire t_01, t_02, t_03, t_06;
    `OR_2(u_t_01, 1, t_01, clash_1, ge_01)
    `OR_2(u_t_02, 1, t_02, clash_2, ge_02)
    `OR_2(u_t_03, 1, t_03, clash_3, ge_03)
    `OR_2(u_t_06, 1, t_06, clash_6, ge_06)

    wire t_10, t_12, t_13, t_16;
    `OR_2(u_t_10, 1, t_10, clash_0, gt_10)
    `OR_2(u_t_12, 1, t_12, clash_2, ge_12)
    `OR_2(u_t_13, 1, t_13, clash_3, ge_13)
    `OR_2(u_t_16, 1, t_16, clash_6, ge_16)

    wire t_20, t_21, t_23, t_26;
    `OR_2(u_t_20, 1, t_20, clash_0, gt_20)
    `OR_2(u_t_21, 1, t_21, clash_1, gt_21)
    `OR_2(u_t_23, 1, t_23, clash_3, ge_23)
    `OR_2(u_t_26, 1, t_26, clash_6, ge_26)

    wire t_30, t_31, t_32, t_36;
    `OR_2(u_t_30, 1, t_30, clash_0, gt_30)
    `OR_2(u_t_31, 1, t_31, clash_1, gt_31)
    `OR_2(u_t_32, 1, t_32, clash_2, gt_32)
    `OR_2(u_t_36, 1, t_36, clash_6, ge_36)

    wire t_40, t_41, t_42, t_43, t_46;
    `OR_2(u_t_40, 1, t_40, clash_0, gt_40)
    `OR_2(u_t_41, 1, t_41, clash_1, gt_41)
    `OR_2(u_t_42, 1, t_42, clash_2, gt_42)
    `OR_2(u_t_43, 1, t_43, clash_3, gt_43)
    `OR_2(u_t_46, 1, t_46, clash_6, ge_46)

    wire t_50, t_51, t_52, t_53, t_56;
    `OR_2(u_t_50, 1, t_50, clash_0, gt_50)
    `OR_2(u_t_51, 1, t_51, clash_1, gt_51)
    `OR_2(u_t_52, 1, t_52, clash_2, gt_52)
    `OR_2(u_t_53, 1, t_53, clash_3, gt_53)
    `OR_2(u_t_56, 1, t_56, clash_6, ge_56)

    wire t_60, t_61, t_62, t_63;
    `OR_2(u_t_60, 1, t_60, clash_0, gt_60)
    `OR_2(u_t_61, 1, t_61, clash_1, gt_61)
    `OR_2(u_t_62, 1, t_62, clash_2, gt_62)
    `OR_2(u_t_63, 1, t_63, clash_3, gt_63)

    // =============================================================
    // win_i = ~clash[i] AND (6 term wires).  Drives the bestPick mux.
    // =============================================================
    wire win_0, win_1, win_2, win_3, win_4, win_5, win_6;
    `AND_7(u_win_0, 1, win_0,
           eb_no_clash_0, t_01, t_02, t_03, ge_04, ge_05, t_06)
    `AND_7(u_win_1, 1, win_1,
           eb_no_clash_1, t_10, t_12, t_13, ge_14, ge_15, t_16)
    `AND_7(u_win_2, 1, win_2,
           eb_no_clash_2, t_20, t_21, t_23, ge_24, ge_25, t_26)
    `AND_7(u_win_3, 1, win_3,
           eb_no_clash_3, t_30, t_31, t_32, ge_34, ge_35, t_36)
    `AND_6(u_win_4, 1, win_4,
           t_40, t_41, t_42, t_43, ge_45, t_46)
    `AND_6(u_win_5, 1, win_5,
           t_50, t_51, t_52, t_53, gt_54, t_56)
    `AND_7(u_win_6, 1, win_6,
           dma_no_clash, t_60, t_61, t_62, t_63, gt_64, gt_65)

    // =============================================================
    // dc_win_1..3: DC-only one-hot winners.  Drives bk_id.
    //   dc_win_i = ~clash[i] AND AND_{j∈DC, j≠i}( clash[j] | beats(i,j) )
    // Reuses the DC-vs-DC term wires (t_ij) from above.
    // (dc_win_0 is implicit — bk_id = 2'b00 when none of dc_win_1..3 = 1.)
    // =============================================================
    wire dc_win_1, dc_win_2, dc_win_3;
    `AND_4(u_dc_win_1, 1, dc_win_1, eb_no_clash_1, t_10, t_12, t_13)
    `AND_4(u_dc_win_2, 1, dc_win_2, eb_no_clash_2, t_20, t_21, t_23)
    `AND_4(u_dc_win_3, 1, dc_win_3, eb_no_clash_3, t_30, t_31, t_32)

    // =============================================================
    // SV tie-on-zero correction.
    //   When every DC port has effective value == 0 (clash[i] OR raw==0),
    //   the SV `>=` tournament resolves all ties to the lowest index
    //   (bk_id = 0) — even if DC0 itself is clashing.  Force bk_id = 0
    //   in that case so the output matches the SV reference bit-exact.
    // =============================================================
    wire dc_zero_0, dc_zero_1, dc_zero_2, dc_zero_3;
    `NOR_4(u_dc_zero_0, 1, dc_zero_0, r0[0], r0[1], r0[2], r0[3])
    `NOR_4(u_dc_zero_1, 1, dc_zero_1, r1[0], r1[1], r1[2], r1[3])
    `NOR_4(u_dc_zero_2, 1, dc_zero_2, r2[0], r2[1], r2[2], r2[3])
    `NOR_4(u_dc_zero_3, 1, dc_zero_3, r3[0], r3[1], r3[2], r3[3])

    wire t_eff_zero_0, t_eff_zero_1, t_eff_zero_2, t_eff_zero_3;
    `OR_2(u_eff_zero_0, 1, t_eff_zero_0, clash_0, dc_zero_0)
    `OR_2(u_eff_zero_1, 1, t_eff_zero_1, clash_1, dc_zero_1)
    `OR_2(u_eff_zero_2, 1, t_eff_zero_2, clash_2, dc_zero_2)
    `OR_2(u_eff_zero_3, 1, t_eff_zero_3, clash_3, dc_zero_3)

    wire all_dc_eff_zero, all_dc_eff_zero_n;
    `AND_4(u_all_dc_eff_zero, 1, all_dc_eff_zero,
           t_eff_zero_0, t_eff_zero_1, t_eff_zero_2, t_eff_zero_3)
    `INV_N(u_inv_all_dc_eff_zero, 1, all_dc_eff_zero, all_dc_eff_zero_n)

    // =============================================================
    // One-hot AND-OR mux producing bestPick_o[3:0].
    // =============================================================
    wire [3:0] aw_0, aw_1, aw_2, aw_3, aw_4, aw_5, aw_6;
    `AND_2(u_aw_0, 4, aw_0, {4{win_0}}, r0)
    `AND_2(u_aw_1, 4, aw_1, {4{win_1}}, r1)
    `AND_2(u_aw_2, 4, aw_2, {4{win_2}}, r2)
    `AND_2(u_aw_3, 4, aw_3, {4{win_3}}, r3)
    `AND_2(u_aw_4, 4, aw_4, {4{win_4}}, r4)
    `AND_2(u_aw_5, 4, aw_5, {4{win_5}}, r5)
    `AND_2(u_aw_6, 4, aw_6, {4{win_6}}, r6)

    `OR_7(u_or_b0, 1, bestPick_o[0],
          aw_0[0], aw_1[0], aw_2[0], aw_3[0], aw_4[0], aw_5[0], aw_6[0])
    `OR_7(u_or_b1, 1, bestPick_o[1],
          aw_0[1], aw_1[1], aw_2[1], aw_3[1], aw_4[1], aw_5[1], aw_6[1])
    `OR_7(u_or_b2, 1, bestPick_o[2],
          aw_0[2], aw_1[2], aw_2[2], aw_3[2], aw_4[2], aw_5[2], aw_6[2])
    `OR_7(u_or_b3, 1, bestPick_o[3],
          aw_0[3], aw_1[3], aw_2[3], aw_3[3], aw_4[3], aw_5[3], aw_6[3])

    // =============================================================
    // bestPick_BK_ID_o = ~all_dc_eff_zero AND (DC-only one-hot encoding):
    //   bk_id_pre[0] = dc_win_1 | dc_win_3
    //   bk_id_pre[1] = dc_win_2 | dc_win_3
    //   bk_id[b]     = ~all_dc_eff_zero AND bk_id_pre[b]
    // =============================================================
    wire bk_id_pre_0, bk_id_pre_1;
    `OR_2(u_bk_id_pre_0, 1, bk_id_pre_0, dc_win_1, dc_win_3)
    `OR_2(u_bk_id_pre_1, 1, bk_id_pre_1, dc_win_2, dc_win_3)
    `AND_2(u_bk_id_0, 1, bestPick_BK_ID_o[0], all_dc_eff_zero_n, bk_id_pre_0)
    `AND_2(u_bk_id_1, 1, bestPick_BK_ID_o[1], all_dc_eff_zero_n, bk_id_pre_1)

endmodule
