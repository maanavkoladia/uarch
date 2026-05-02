// ============================================================================
// Scheduler.v
// ============================================================================
// Structural Verilog-2005 port of Scheduler.sv
//   - 4 input structs flattened to per-field wire vectors
//   - input-latch always_ff replaced with REG_RST cells (always-write,
//     active-low rst -> 0 == NO_REQ)
//   - DMA clash-cleanup: if writeBuf_V[ dma_addr[6:4] ] = 1, mask the
//     latched dma_req to NO_REQ (== 4'b0). 4-bit AND mask.
//   - Pick logic restructured from a 3-deep serial GE chain into a 3-way
//     parallel max for {IC, MIO, DMA} followed by one GE vs dcache_Best_Pick.
//     Three small (4-bit) Kogge-Stone subtracts run in parallel; their
//     couts feed a tiny win-decoder + 2-level MUX_2 tree.
//   - Avoid mux3_N: the lib cell has a 1-bit `sel` port routed into
//     MPS_MUX_IN3's [1:0] sel — that width mismatch makes mux3_N unsafe.
// ============================================================================

module Scheduler (
    input  wire         clk,
    input  wire         rst,  // active-low

    // ICache (icache_2_scheduler_t.req) — req_2_sch_t is now 4-bit
    input  wire [3:0]   iCache_2_Sch_req_i,

    // DCache (dcache_2_scheduler_t flattened: req[4], evictionBufAddr[4], req_mio)
    input  wire [3:0]   dCache_2_Sch_req_0_i,
    input  wire [3:0]   dCache_2_Sch_req_1_i,
    input  wire [3:0]   dCache_2_Sch_req_2_i,
    input  wire [3:0]   dCache_2_Sch_req_3_i,
    input  wire [14:0]  dCache_2_Sch_evictionBufAddr_0_i,
    input  wire [14:0]  dCache_2_Sch_evictionBufAddr_1_i,
    input  wire [14:0]  dCache_2_Sch_evictionBufAddr_2_i,
    input  wire [14:0]  dCache_2_Sch_evictionBufAddr_3_i,
    input  wire [3:0]   dCache_2_Sch_req_mio_i,

    // Mem (mem_2_scheduler_t.writeBuf_V)
    input  wire [7:0]   mem_2_Sch_writeBuf_V_i,

    // DMA (dma_controller_2_scheduler_t flattened)
    input  wire [3:0]   dma_2_sch_dma_req_i,
    input  wire [14:0]  dma_2_sch_writeBuf_Address_i,

    output wire [3:0]   bestPick_o,
    output wire [1:0]   bestPick_bk_id_o
);

    // ------------------------------------------------------------------
    // Latched copies of every input (sch_latched_reqs_t).
    //
    //   REG_RST:  active-LOW sync rst (-> 0 == NO_REQ),
    //             we tied to 1'b1 internally so it captures every cycle.
    // ------------------------------------------------------------------
    wire [3:0] sch_lat_i_cache_req;
    `REG_RST(lat_ic_req, 4, clk, rst, iCache_2_Sch_req_i, sch_lat_i_cache_req)

    wire [3:0] sch_lat_d_cache_reqs_0;
    wire [3:0] sch_lat_d_cache_reqs_1;
    wire [3:0] sch_lat_d_cache_reqs_2;
    wire [3:0] sch_lat_d_cache_reqs_3;
    `REG_RST(lat_dc_req_0, 4, clk, rst, dCache_2_Sch_req_0_i, sch_lat_d_cache_reqs_0)
    `REG_RST(lat_dc_req_1, 4, clk, rst, dCache_2_Sch_req_1_i, sch_lat_d_cache_reqs_1)
    `REG_RST(lat_dc_req_2, 4, clk, rst, dCache_2_Sch_req_2_i, sch_lat_d_cache_reqs_2)
    `REG_RST(lat_dc_req_3, 4, clk, rst, dCache_2_Sch_req_3_i, sch_lat_d_cache_reqs_3)

    wire [14:0] sch_lat_eb_addr_0;
    wire [14:0] sch_lat_eb_addr_1;
    wire [14:0] sch_lat_eb_addr_2;
    wire [14:0] sch_lat_eb_addr_3;
    `REG_RST(lat_dc_eb_0, 15, clk, rst, dCache_2_Sch_evictionBufAddr_0_i, sch_lat_eb_addr_0)
    `REG_RST(lat_dc_eb_1, 15, clk, rst, dCache_2_Sch_evictionBufAddr_1_i, sch_lat_eb_addr_1)
    `REG_RST(lat_dc_eb_2, 15, clk, rst, dCache_2_Sch_evictionBufAddr_2_i, sch_lat_eb_addr_2)
    `REG_RST(lat_dc_eb_3, 15, clk, rst, dCache_2_Sch_evictionBufAddr_3_i, sch_lat_eb_addr_3)

    wire [3:0] sch_lat_mio_req;
    `REG_RST(lat_mio, 4, clk, rst, dCache_2_Sch_req_mio_i, sch_lat_mio_req)

    wire [3:0] sch_lat_dma_req;
    `REG_RST(lat_dma_req, 4, clk, rst, dma_2_sch_dma_req_i, sch_lat_dma_req)

    wire [14:0] sch_lat_dma_write_addr;
    `REG_RST(lat_dma_addr, 15, clk, rst, dma_2_sch_writeBuf_Address_i, sch_lat_dma_write_addr)

    wire [7:0]  sch_lat_writeBuf_V_List;
    `REG_RST(lat_wbV, 8, clk, rst, mem_2_Sch_writeBuf_V_i, sch_lat_writeBuf_V_List)

    // ------------------------------------------------------------------
    // DMA clash cleaning:
    //   if writeBuf_V[ dma_addr[6:4] ] == 1 -> dma_req_clean = NO_REQ
    //
    //   req_2_sch_t is now 4-bit, so the AND-mask is a clean 4-bit op.
    // ------------------------------------------------------------------
    wire [2:0] dma_bg;
    assign dma_bg = sch_lat_dma_write_addr[6:4];

    wire wbV_at_dma_bg;
    `MUX_8(u_wbv_dma_mux, 1, wbV_at_dma_bg,
           sch_lat_writeBuf_V_List[0], sch_lat_writeBuf_V_List[1],
           sch_lat_writeBuf_V_List[2], sch_lat_writeBuf_V_List[3],
           sch_lat_writeBuf_V_List[4], sch_lat_writeBuf_V_List[5],
           sch_lat_writeBuf_V_List[6], sch_lat_writeBuf_V_List[7],
           dma_bg)

    wire dma_no_clash;
    `INV_N(u_inv_dma_clash, 1, wbV_at_dma_bg, dma_no_clash)

    wire [3:0] dma_req_clean;
    `AND_2(u_dma_mask, 4, dma_req_clean,
           sch_lat_dma_req, {4{dma_no_clash}})

    // ------------------------------------------------------------------
    // DCache picking (combinational, in submodule)
    // ------------------------------------------------------------------
    wire [3:0] dcache_Best_Pick;
    wire [1:0] dcache_Best_Pick_BK_ID;

    Scheduler_DCachePicking dcache_picking_unit (
        .d_Cache_eb_addr_0_i        (sch_lat_eb_addr_0),
        .d_Cache_eb_addr_1_i        (sch_lat_eb_addr_1),
        .d_Cache_eb_addr_2_i        (sch_lat_eb_addr_2),
        .d_Cache_eb_addr_3_i        (sch_lat_eb_addr_3),
        .d_cache_reqs_dirty_0_i     (sch_lat_d_cache_reqs_0),
        .d_cache_reqs_dirty_1_i     (sch_lat_d_cache_reqs_1),
        .d_cache_reqs_dirty_2_i     (sch_lat_d_cache_reqs_2),
        .d_cache_reqs_dirty_3_i     (sch_lat_d_cache_reqs_3),
        .writeBuf_V_i               (sch_lat_writeBuf_V_List),
        .bestPick_o                 (dcache_Best_Pick),
        .bestPick_BK_ID_o           (dcache_Best_Pick_BK_ID)
    );

    // ==================================================================
    // 3-way max(IC, MIO, DMA) using parallel small Kogge-Stone subtracts
    //
    //   SV reference (Scheduler.sv lines 87-91):
    //     IC_MIO_Pick     = (ic >= mio)        ? ic       : mio;
    //     IC_MIO_DMA_PICK = (IC_MIO_Pick>=dma) ? IC_MIO_P : dma;
    //
    //   `>=` ties pick the left operand at every step, so the SV chain
    //   resolves equal values in priority order ic > mio > dma.
    //
    //   Equivalent parallel form (preserves the same tie order):
    //     ge_ic_mio  = (ic  >= mio)            // 4-bit kogge_stone, cout
    //     ge_ic_dma  = (ic  >= dma_clean)      // 4-bit kogge_stone, cout
    //     ge_mio_dma = (mio >= dma_clean)      // 4-bit kogge_stone, cout
    //     ic_wins    =  ge_ic_mio  & ge_ic_dma           // ic max (incl ties)
    //     mio_wins   = ~ge_ic_mio  & ge_mio_dma          // mio max after ic
    //     pick = ic_wins ? ic : (mio_wins ? mio : dma)
    //
    //   Tie-case checks vs. the SV chain:
    //     ic == mio == dma: ge_ic_mio=ge_ic_dma=1 -> ic_wins -> ic.
    //                       (SV: chain ties IC every step -> ic.)
    //     ic == mio  > dma: ic_wins=1 -> ic.   (SV: tie -> ic.)
    //     mio == dma > ic : ge_ic_mio=0, ge_mio_dma=1 -> mio_wins -> mio.
    //                       (SV: IC_MIO=mio, then mio>=dma tie -> mio.)
    //     ic == dma > mio : ge_ic_mio=1, ge_ic_dma=1 -> ic_wins -> ic.
    //                       (SV: IC_MIO=ic, then ic>=dma tie -> ic.)
    //
    //   ic_wins & mio_wins are mutually exclusive by construction
    //   (ge_ic_mio appears positive in one and negated in the other).
    //
    //   Critical-path: 3 kogge_stone(4) ADDs run in parallel (1 ADD-depth)
    //   instead of 2 serial ADDs (2 ADD-depths) in the original SV chain.
    //   ~Saves one full 4-bit Kogge-Stone delay before the final compare.
    // ==================================================================

    // 4-bit inversions. Reuse dma_inv4 across both DMA compares.
    wire [3:0] mio_inv4;
    wire [3:0] dma_inv4;
    `INV_N(u_inv_mio, 4, sch_lat_mio_req, mio_inv4)
    `INV_N(u_inv_dma, 4, dma_req_clean,   dma_inv4)

    // Three parallel small Kogge-Stone subtracts.
    //   A + ~B + 1 = A - B (mod 16);  cout == 1  iff  A >= B  (unsigned).
    wire [3:0] sub_ic_mio_sum_unused;
    wire [3:0] sub_ic_dma_sum_unused;
    wire [3:0] sub_mio_dma_sum_unused;
    wire ge_ic_mio, ge_ic_dma, ge_mio_dma;

    `ADD_N(u_sub_ic_mio,  4, sub_ic_mio_sum_unused,  ge_ic_mio,
           sch_lat_i_cache_req, mio_inv4, 1'b1)
    `ADD_N(u_sub_ic_dma,  4, sub_ic_dma_sum_unused,  ge_ic_dma,
           sch_lat_i_cache_req, dma_inv4, 1'b1)
    `ADD_N(u_sub_mio_dma, 4, sub_mio_dma_sum_unused, ge_mio_dma,
           sch_lat_mio_req,     dma_inv4, 1'b1)

    // Win-decoder.
    wire ic_wins;
    wire ge_ic_mio_n;
    wire mio_wins;   
    `AND_2(u_ic_wins,    1, ic_wins,    ge_ic_mio,   ge_ic_dma)
    `INV_N(u_inv_geicmi, 1, ge_ic_mio,  ge_ic_mio_n)
    `AND_2(u_mio_wins,   1, mio_wins,   ge_ic_mio_n, ge_mio_dma)

    // 3-way MUX tree built from MUX_2 (mux3_N is unsafe — see file header).
    //   step 1: pick mio if mio_wins, else dma  (don't-care if ic_wins=1).
    //   step 2: pick ic  if ic_wins,  else step1 result.
    wire [3:0] non_ic_pick;
    `MUX_2(u_pick_mio_dma, 4, non_ic_pick,
           dma_req_clean, sch_lat_mio_req, mio_wins)

    wire [3:0] IC_MIO_DMA_PICK;
    `MUX_2(u_pick_3way,    4, IC_MIO_DMA_PICK,
           non_ic_pick, sch_lat_i_cache_req, ic_wins)

    // ==================================================================
    // Final pick: dcache_Best_Pick vs IC_MIO_DMA_PICK
    //   bestPick = (dcache >= IC_MIO_DMA_PICK) ? dcache : IC_MIO_DMA_PICK
    // ==================================================================
    wire [3:0] ic_mio_dma_inv4;
    `INV_N(u_inv_icmd, 4, IC_MIO_DMA_PICK, ic_mio_dma_inv4)

    wire [3:0] sub_best_sum_unused;
    wire ge_best;
    `ADD_N(u_sub_best, 4, sub_best_sum_unused, ge_best,
           dcache_Best_Pick, ic_mio_dma_inv4, 1'b1)

    `MUX_2(u_pick_best, 4, bestPick_o,
           IC_MIO_DMA_PICK, dcache_Best_Pick, ge_best)

    // bestPick_bk_id passes through unconditionally (matches SV line 97).
    assign bestPick_bk_id_o = dcache_Best_Pick_BK_ID;

endmodule
