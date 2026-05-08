// ============================================================================
// Scheduler.v  — phase-1 unified picker
// ============================================================================
// Structural Verilog-2005 port of Scheduler.sv.
//   - 4 input structs flattened to per-field wire vectors.
//   - Input-latch always_ff replaced with REG_RST cells (active-low sync rst,
//     we tied to 1'b1 → captures every cycle).  Latch 1 is RETAINED in
//     phase 1 — only the picker is flattened.  Phase 2 will revisit
//     deleting these latches once the new picker is verified.
//   - DMA clash bit is computed locally (writeBuf_V[ dma_addr[6:4] ]) and
//     forwarded RAW to the unified picker; the picker applies it inside
//     its win-decoder so the clash front-end runs in parallel with the
//     GE compares.  No more pre-masked dma_req_clean.
//   - All pick logic (DC 4-way pairwise tree, IC/MIO/DMA 3-way max, and
//     the final GE against dcache_Best_Pick) is now folded into
//     Scheduler_DCachePicking — a single-GE-depth 7-way priority max.
//     Tie-priority preserved: dc[0] > dc[1] > dc[2] > dc[3] > ic > mio > dma.
//   - Output flop (lat_best_pick) lives in BusArbitration_structural.v
//     and is unchanged.
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
    // bufferH16$ on every output bit of these 4-bit latched-request registers --
    // their q[3] fanouts hit 5-6 (>4 tier).  +0.24 ns on the latched-req paths.
    wire [3:0] sch_lat_i_cache_req;
    wire [3:0] sch_lat_i_cache_req_pre;
    `REG_RST(lat_ic_req, 4, clk, rst, iCache_2_Sch_req_i, sch_lat_i_cache_req_pre)

    wire [3:0] sch_lat_d_cache_reqs_0;
    wire [3:0] sch_lat_d_cache_reqs_1;
    wire [3:0] sch_lat_d_cache_reqs_2;
    wire [3:0] sch_lat_d_cache_reqs_3;
    wire [3:0] sch_lat_d_cache_reqs_0_pre;
    wire [3:0] sch_lat_d_cache_reqs_1_pre;
    wire [3:0] sch_lat_d_cache_reqs_2_pre;
    wire [3:0] sch_lat_d_cache_reqs_3_pre;
    `REG_RST(lat_dc_req_0, 4, clk, rst, dCache_2_Sch_req_0_i, sch_lat_d_cache_reqs_0_pre)
    `REG_RST(lat_dc_req_1, 4, clk, rst, dCache_2_Sch_req_1_i, sch_lat_d_cache_reqs_1_pre)
    `REG_RST(lat_dc_req_2, 4, clk, rst, dCache_2_Sch_req_2_i, sch_lat_d_cache_reqs_2_pre)
    `REG_RST(lat_dc_req_3, 4, clk, rst, dCache_2_Sch_req_3_i, sch_lat_d_cache_reqs_3_pre)
    genvar dc_i;
    generate
        for (dc_i = 0; dc_i < 4; dc_i = dc_i + 1) begin : g_lat_req_buf
            bufferH16$ u_buf_ic (.out(sch_lat_i_cache_req[dc_i]),       .in(sch_lat_i_cache_req_pre[dc_i]));
            // d0/d1/d2 each fan out 17-19 inside Scheduler_DCachePicking's
            // per-iter loads (compares + 6 kogge_stone sub adders + and/nor),
            // just over bufferH16$ rated 16. Step up to bufferH64$ rather than
            // restructure the consumer's interleaved generate loop. d3 was
            // under cap.
            bufferH64$ u_buf_d0 (.out(sch_lat_d_cache_reqs_0[dc_i]),    .in(sch_lat_d_cache_reqs_0_pre[dc_i]));
            bufferH64$ u_buf_d1 (.out(sch_lat_d_cache_reqs_1[dc_i]),    .in(sch_lat_d_cache_reqs_1_pre[dc_i]));
            bufferH64$ u_buf_d2 (.out(sch_lat_d_cache_reqs_2[dc_i]),    .in(sch_lat_d_cache_reqs_2_pre[dc_i]));
            bufferH16$ u_buf_d3 (.out(sch_lat_d_cache_reqs_3[dc_i]),    .in(sch_lat_d_cache_reqs_3_pre[dc_i]));
        end
    endgenerate

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

     // lat_wbV q[7] fanout 5 -> bufferH16$ on every bit (+0.24 ns).
     wire [7:0]  sch_lat_writeBuf_V_List;
     wire [7:0]  sch_lat_writeBuf_V_List_pre;
     `REG_RST(lat_wbV, 8, clk, rst, mem_2_Sch_writeBuf_V_i, sch_lat_writeBuf_V_List_pre)
     genvar wbV_i;
     generate
         for (wbV_i = 0; wbV_i < 8; wbV_i = wbV_i + 1) begin : g_lat_wbV_buf
             bufferH16$ u_buf (.out(sch_lat_writeBuf_V_List[wbV_i]), .in(sch_lat_writeBuf_V_List_pre[wbV_i]));
         end
     endgenerate
       // assign sch_lat_mio_req = dCache_2_Sch_req_mio_i;
       // assign sch_lat_dma_req = dma_2_sch_dma_req_i;
       // assign sch_lat_dma_write_addr = sch_lat_dma_write_addr;
       // assign sch_lat_writeBuf_V_List = sch_lat_writeBuf_V_List;
    // ------------------------------------------------------------------
    // DMA clash bit:  wbV_at_dma_bg = writeBuf_V[ dma_addr[6:4] ].
    //   Forwarded RAW to the unified picker (no AND-mask of dma_req).
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

    // ==================================================================
    // Unified 7-way priority max (combinational, in submodule).
    //   Tie-priority: dc[0] > dc[1] > dc[2] > dc[3] > ic > mio > dma.
    //   Clash bits applied inside the win-decoder (parallel with GE).
    // ==================================================================
    Scheduler_DCachePicking unified_picking_unit (
        .d_Cache_eb_addr_0_i    (sch_lat_eb_addr_0),
        .d_Cache_eb_addr_1_i    (sch_lat_eb_addr_1),
        .d_Cache_eb_addr_2_i    (sch_lat_eb_addr_2),
        .d_Cache_eb_addr_3_i    (sch_lat_eb_addr_3),
        .d_cache_reqs_dirty_0_i (sch_lat_d_cache_reqs_0),
        .d_cache_reqs_dirty_1_i (sch_lat_d_cache_reqs_1),
        .d_cache_reqs_dirty_2_i (sch_lat_d_cache_reqs_2),
        .d_cache_reqs_dirty_3_i (sch_lat_d_cache_reqs_3),
        .i_cache_req_i          (sch_lat_i_cache_req),
        .mio_req_i              (sch_lat_mio_req),
        .dma_req_i              (sch_lat_dma_req),
        .writeBuf_V_i           (sch_lat_writeBuf_V_List),
        .dma_clash_i            (wbV_at_dma_bg),
        .bestPick_o             (bestPick_o),
        .bestPick_BK_ID_o       (bestPick_bk_id_o)
    );

endmodule
