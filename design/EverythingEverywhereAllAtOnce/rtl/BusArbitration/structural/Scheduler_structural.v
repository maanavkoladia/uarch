// ============================================================================
// Scheduler.v  — phase-2 (latch-free)
// ============================================================================
// Structural Verilog-2005 port of Scheduler.sv.  Input latches deleted;
// picker driven directly from the input ports.  The only flop on the
// Scheduler→DTE path is `lat_best_pick` in BusArbitration_structural.v.
// (Non-fanout copy: matches structural/fanout/ except no bufferH16$ /
//  bufferH64$ driver cells.)
// ============================================================================

module Scheduler (
    input  wire         clk,
    input  wire         rst,  // active-low (unused in this latch-free variant)

    input  wire [3:0]   iCache_2_Sch_req_i,

    input  wire [3:0]   dCache_2_Sch_req_0_i,
    input  wire [3:0]   dCache_2_Sch_req_1_i,
    input  wire [3:0]   dCache_2_Sch_req_2_i,
    input  wire [3:0]   dCache_2_Sch_req_3_i,
    input  wire [14:0]  dCache_2_Sch_evictionBufAddr_0_i,
    input  wire [14:0]  dCache_2_Sch_evictionBufAddr_1_i,
    input  wire [14:0]  dCache_2_Sch_evictionBufAddr_2_i,
    input  wire [14:0]  dCache_2_Sch_evictionBufAddr_3_i,
    input  wire [3:0]   dCache_2_Sch_req_mio_i,

    input  wire [7:0]   mem_2_Sch_writeBuf_V_i,

    input  wire [3:0]   dma_2_sch_dma_req_i,
    input  wire [14:0]  dma_2_sch_writeBuf_Address_i,

    output wire [3:0]   bestPick_o,
    output wire [1:0]   bestPick_bk_id_o
);

    // ------------------------------------------------------------------
    // DMA clash bit: wbV_at_dma_bg = writeBuf_V[ dma_addr[6:4] ].
    // ------------------------------------------------------------------
    wire [2:0] dma_bg;
    assign dma_bg = dma_2_sch_writeBuf_Address_i[6:4];

    wire wbV_at_dma_bg;
    `MUX_8(u_wbv_dma_mux, 1, wbV_at_dma_bg,
           mem_2_Sch_writeBuf_V_i[0], mem_2_Sch_writeBuf_V_i[1],
           mem_2_Sch_writeBuf_V_i[2], mem_2_Sch_writeBuf_V_i[3],
           mem_2_Sch_writeBuf_V_i[4], mem_2_Sch_writeBuf_V_i[5],
           mem_2_Sch_writeBuf_V_i[6], mem_2_Sch_writeBuf_V_i[7],
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
        .d_cache_reqs_dirty_0_i (dCache_2_Sch_req_0_i),
        .d_cache_reqs_dirty_1_i (dCache_2_Sch_req_1_i),
        .d_cache_reqs_dirty_2_i (dCache_2_Sch_req_2_i),
        .d_cache_reqs_dirty_3_i (dCache_2_Sch_req_3_i),
        .i_cache_req_i          (iCache_2_Sch_req_i),
        .mio_req_i              (dCache_2_Sch_req_mio_i),
        .dma_req_i              (dma_2_sch_dma_req_i),
        .writeBuf_V_i           (mem_2_Sch_writeBuf_V_i),
        .dma_clash_i            (wbV_at_dma_bg),
        .bestPick_o             (bestPick_o),
        .bestPick_BK_ID_o       (bestPick_bk_id_o)
    );

endmodule
