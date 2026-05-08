// ============================================================================
// Scheduler.v  — phase-1 unified picker
// ============================================================================
// Structural Verilog-2005 port of Scheduler.sv.  Latch 1 retained;
// picker flattened to a single-GE-depth 7-way priority max (see
// Scheduler_DCachePicking).  DMA clash bit forwarded raw to the picker
// (no pre-applied AND-mask).
// (Non-fanout copy: matches structural/fanout/ except no bufferH16$ trees.)
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
