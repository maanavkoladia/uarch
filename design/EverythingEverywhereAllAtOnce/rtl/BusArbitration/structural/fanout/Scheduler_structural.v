// ============================================================================
// Scheduler.v  — phase-2 (latch-free)
// ============================================================================
// Structural Verilog-2005 port of Scheduler.sv.
//   - Phase 2: input-side latches DELETED.  The Scheduler is now a pure
//     combinational shell that drives the unified picker; the only flop
//     in the Scheduler→DTE path is `lat_best_pick` in
//     BusArbitration_structural.v.  This drops one cycle of arbiter
//     latency vs the SV reference.
//   - DMA clash bit (writeBuf_V[ dma_addr[6:4] ]) is computed locally
//     via a MUX_8 and forwarded RAW to the picker.
//   - All pick logic is in Scheduler_DCachePicking — single-GE-depth
//     7-way priority max with clash applied in the win-decoder.
//   - Buffering: parent-level driver cells on every signal entering the
//     picker that fans out to >4 internal sinks.  DC reqs use bufferH64$
//     (fanout up to 19 per bit after the SV-tie-on-zero NOR_4 fix);
//     writeBuf_V uses bufferH16$ (fanout 5).  IC/MIO/DMA reqs are buffered
//     inside the picker (their internal bufferH16$ stays in place).
//   - clk/rst are kept in the port list for symmetry with the SV
//     scheduler module (BusArbitration_structural.v passes them through
//     unconditionally) and are intentionally unused in this latch-free
//     variant.
// ============================================================================

module Scheduler (
    input  wire         clk,
    input  wire         rst,  // active-low (unused in this latch-free variant)

    // ICache (icache_2_scheduler_t.req) — 4-bit req_2_sch_t
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
    // Parent-level driver buffers for high-fanout picker inputs.
    //
    //   DC reqs (fanout per bit ≈ 19/18/17/16 inside the picker after
    //     the SV-tie-on-zero correction): bufferH64$.
    //   writeBuf_V (fanout 5: 4 picker MUX_8s + 1 local DMA-clash MUX_8):
    //     bufferH16$.
    //   IC/MIO/DMA reqs: no parent buffer; the picker has a local
    //     bufferH16$ on each (fanout 7..9 internal).
    //   eb_addr / dma_write_addr: only bits [6:4] are consumed (one
    //     MUX_8 select each) → no buffer needed.
    // ------------------------------------------------------------------
    wire [3:0] dc_req_0_buf, dc_req_1_buf, dc_req_2_buf, dc_req_3_buf;
    genvar gb;
    generate
        for (gb = 0; gb < 4; gb = gb + 1) begin : g_dc_req_buf
            bufferH64$ u_buf_d0 (.out(dc_req_0_buf[gb]), .in(dCache_2_Sch_req_0_i[gb]));
            bufferH64$ u_buf_d1 (.out(dc_req_1_buf[gb]), .in(dCache_2_Sch_req_1_i[gb]));
            bufferH64$ u_buf_d2 (.out(dc_req_2_buf[gb]), .in(dCache_2_Sch_req_2_i[gb]));
            bufferH64$ u_buf_d3 (.out(dc_req_3_buf[gb]), .in(dCache_2_Sch_req_3_i[gb]));
        end
    endgenerate

    wire [7:0] wbV_buf;
    genvar wb_i;
    generate
        for (wb_i = 0; wb_i < 8; wb_i = wb_i + 1) begin : g_wbV_buf
            bufferH16$ u_buf (.out(wbV_buf[wb_i]), .in(mem_2_Sch_writeBuf_V_i[wb_i]));
        end
    endgenerate

    // ------------------------------------------------------------------
    // DMA clash bit:  wbV_at_dma_bg = writeBuf_V[ dma_addr[6:4] ].
    //   Forwarded RAW to the picker (no AND-mask of dma_req).
    // ------------------------------------------------------------------
    wire [2:0] dma_bg;
    assign dma_bg = dma_2_sch_writeBuf_Address_i[6:4];

    wire wbV_at_dma_bg;
    `MUX_8(u_wbv_dma_mux, 1, wbV_at_dma_bg,
           wbV_buf[0], wbV_buf[1], wbV_buf[2], wbV_buf[3],
           wbV_buf[4], wbV_buf[5], wbV_buf[6], wbV_buf[7],
           dma_bg)

    // ==================================================================
    // Unified 7-way priority max (combinational, in submodule).
    //   Tie-priority: dc[0] > dc[1] > dc[2] > dc[3] > ic > mio > dma.
    //   Clash bits applied inside the win-decoder (parallel with GE).
    // ==================================================================
    Scheduler_DCachePicking unified_picking_unit (
        .d_Cache_eb_addr_0_i    (dCache_2_Sch_evictionBufAddr_0_i),
        .d_Cache_eb_addr_1_i    (dCache_2_Sch_evictionBufAddr_1_i),
        .d_Cache_eb_addr_2_i    (dCache_2_Sch_evictionBufAddr_2_i),
        .d_Cache_eb_addr_3_i    (dCache_2_Sch_evictionBufAddr_3_i),
        .d_cache_reqs_dirty_0_i (dc_req_0_buf),
        .d_cache_reqs_dirty_1_i (dc_req_1_buf),
        .d_cache_reqs_dirty_2_i (dc_req_2_buf),
        .d_cache_reqs_dirty_3_i (dc_req_3_buf),
        .i_cache_req_i          (iCache_2_Sch_req_i),
        .mio_req_i              (dCache_2_Sch_req_mio_i),
        .dma_req_i              (dma_2_sch_dma_req_i),
        .writeBuf_V_i           (wbV_buf),
        .dma_clash_i            (wbV_at_dma_bg),
        .bestPick_o             (bestPick_o),
        .bestPick_BK_ID_o       (bestPick_bk_id_o)
    );

endmodule
