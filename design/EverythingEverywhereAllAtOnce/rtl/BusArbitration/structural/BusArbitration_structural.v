// ============================================================================
// BusArbitration.v  (structural Verilog-2005, flat external ports)
// ============================================================================
// All struct ports are unrolled to individual wire fields so this module
// can be instantiated from pure Verilog-2005 parents.
//
// Two ifdef toggles select which child implementation is compiled in:
//
//   `define SCHEDULER_STRUCTURAL  -> Scheduler.v  (structural, flat ports)
//   (else)                        -> Scheduler.sv (SV, struct ports) — uses
//                                    internal struct wires to adapt
//   `define DTE_STRUCTURAL        -> DTE.v        (structural, flat ports)
//   (else)                        -> DTE.sv       (SV, struct ports) — uses
//                                    internal struct wires to adapt
//
// The SV else-branches require package imports and SystemVerilog struct types
// internally — the parent sees only flat wires either way.
//
//   Port width reference (from pkgs):
//     req_2_sch_t  = [3:0]  (4-bit enum, max value 14)
//     p_address_t  = [14:0] ($clog2(PHY_MEM_SIZE=32768) = 15 bits)
//     writeBuf_V   = [7:0]  (numWriteBufsInMem = 8)
//     permission2DriveBus / permissionToDriveDataBus_evictionBuf
//                  = [3:0]  (MEM_BUS_SIZE/DATA_BUS_WIDTH_BITS = 128/32 = 4)
// ============================================================================

// ---- Toggle these to select structural vs SV child implementations ----
// `define SCHEDULER_STRUCTURAL
// `define DTE_STRUCTURAL
// -----------------------------------------------------------------------

module BusArbitration (
    input  wire         clk,
    input  wire         rst,   // active-low

    // icache_2_scheduler_t (in)
    input  wire [3:0]   iCache_2_Sch_req_i,

    // dte_2_icache_t (out)
    output wire         dte_out_2_icache_Mem_Valid_o,
    output wire         dte_out_2_icache_driveAddrBus_o,

    // dcache_2_scheduler_t (in) — req[4], evictionBufAddr[4], req_mio
    input  wire [3:0]   dCache_2_Sch_req_0_i,
    input  wire [3:0]   dCache_2_Sch_req_1_i,
    input  wire [3:0]   dCache_2_Sch_req_2_i,
    input  wire [3:0]   dCache_2_Sch_req_3_i,
    input  wire [14:0]  dCache_2_Sch_evictionBufAddr_0_i,
    input  wire [14:0]  dCache_2_Sch_evictionBufAddr_1_i,
    input  wire [14:0]  dCache_2_Sch_evictionBufAddr_2_i,
    input  wire [14:0]  dCache_2_Sch_evictionBufAddr_3_i,
    input  wire [3:0]   dCache_2_Sch_req_mio_i,

    // dte_2_dcache_t (out) — per-bank fields expanded
    output wire         dte_out_2_dcache_mem_valid_0_o,
    output wire         dte_out_2_dcache_mem_valid_1_o,
    output wire         dte_out_2_dcache_mem_valid_2_o,
    output wire         dte_out_2_dcache_mem_valid_3_o,
    output wire [3:0]   dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_0_o,
    output wire [3:0]   dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_1_o,
    output wire [3:0]   dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_2_o,
    output wire [3:0]   dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_3_o,
    output wire         dte_out_2_dcache_permissionToDriveAddrBus_Ld_0_o,
    output wire         dte_out_2_dcache_permissionToDriveAddrBus_Ld_1_o,
    output wire         dte_out_2_dcache_permissionToDriveAddrBus_Ld_2_o,
    output wire         dte_out_2_dcache_permissionToDriveAddrBus_Ld_3_o,
    output wire         dte_out_2_dcache_permissionToDriveAddrBus_eb_0_o,
    output wire         dte_out_2_dcache_permissionToDriveAddrBus_eb_1_o,
    output wire         dte_out_2_dcache_permissionToDriveAddrBus_eb_2_o,
    output wire         dte_out_2_dcache_permissionToDriveAddrBus_eb_3_o,
    output wire         dte_out_2_dcache_evictionBuf_clr_0_o,
    output wire         dte_out_2_dcache_evictionBuf_clr_1_o,
    output wire         dte_out_2_dcache_evictionBuf_clr_2_o,
    output wire         dte_out_2_dcache_evictionBuf_clr_3_o,
    output wire         dte_out_2_dcache_evictionBuf_setCommiting_0_o,
    output wire         dte_out_2_dcache_evictionBuf_setCommiting_1_o,
    output wire         dte_out_2_dcache_evictionBuf_setCommiting_2_o,
    output wire         dte_out_2_dcache_evictionBuf_setCommiting_3_o,
    output wire         dte_out_2_dcache_reqServed_mio_o,
    output wire         dte_out_2_dcache_permissionToDriveAddrBus_mio_o,
    output wire         dte_out_2_dcache_permission2DriveDataBus_mio_o,

    // mem_2_scheduler_t (in)
    input  wire [7:0]   mem_2_Sch_writeBuf_V_i,

    // mem_2_dte_t (in)
    input  wire         mem_2_dte_mem_Ready_i,

    // dte_2_mem_t (out)
    output wire         dte_2_mem_ld_req_o,
    output wire         dte_2_mem_st_req_o,
    output wire [3:0]   dte_2_mem_permission2DriveBus_o,

    // dma_controller_2_scheduler_t (in)
    input  wire [3:0]   dma_2_sch_dma_req_i,
    input  wire [14:0]  dma_2_sch_writeBuf_Address_i,

    // dte_2_dma_controller_t (out)
    output wire [3:0]   dte_2_dma_permission2DriveDataBus_o,
    output wire         dte_2_dma_permission2DriveADDRBus_o,
    output wire         dte_2_dma_commiting_o,
    output wire         dte_2_dma_writeComplete_o,
    output wire         dte_2_dma_coreValOnBus_o,

    // dte_2_ddr5_t (out)
    output wire         dte_2_ddr5_newPowerGateValueFromCore_o,
    output wire         dte_2_ddr5_driveDataBus_o
);

    // ====================================================================
    // Scheduler -> DTE pipeline register  (always present)
    // ====================================================================
    wire [3:0] sch_best_pick;
    wire [1:0] sch_best_pick_bk_id;

    wire [3:0] sch_best_pick_ff;
    wire [1:0] sch_best_pick_bk_id_ff;

    `REG_RST(lat_best_pick,       4, clk, rst, sch_best_pick,       sch_best_pick_ff)
    `REG_RST(lat_best_pick_bk_id, 2, clk, rst, sch_best_pick_bk_id, sch_best_pick_bk_id_ff)

    // ====================================================================
    // Scheduler
    // ====================================================================
//`ifdef SCHEDULER_STRUCTURAL
    // -- Structural Scheduler.v (flat ports) --
    Scheduler scheduler_unit (
        .clk                              (clk),
        .rst                              (rst),
        .iCache_2_Sch_req_i               (iCache_2_Sch_req_i),
        .dCache_2_Sch_req_0_i             (dCache_2_Sch_req_0_i),
        .dCache_2_Sch_req_1_i             (dCache_2_Sch_req_1_i),
        .dCache_2_Sch_req_2_i             (dCache_2_Sch_req_2_i),
        .dCache_2_Sch_req_3_i             (dCache_2_Sch_req_3_i),
        .dCache_2_Sch_evictionBufAddr_0_i (dCache_2_Sch_evictionBufAddr_0_i),
        .dCache_2_Sch_evictionBufAddr_1_i (dCache_2_Sch_evictionBufAddr_1_i),
        .dCache_2_Sch_evictionBufAddr_2_i (dCache_2_Sch_evictionBufAddr_2_i),
        .dCache_2_Sch_evictionBufAddr_3_i (dCache_2_Sch_evictionBufAddr_3_i),
        .dCache_2_Sch_req_mio_i           (dCache_2_Sch_req_mio_i),
        .mem_2_Sch_writeBuf_V_i           (mem_2_Sch_writeBuf_V_i),
        .dma_2_sch_dma_req_i              (dma_2_sch_dma_req_i),
        .dma_2_sch_writeBuf_Address_i     (dma_2_sch_writeBuf_Address_i),
        .bestPick_o                       (sch_best_pick),
        .bestPick_bk_id_o                 (sch_best_pick_bk_id)
    );
// `else
//     // -- SV Scheduler.sv (struct ports) — adapt flat inputs into structs --
//     icache_2_scheduler_t      iCache_2_Sch_w;
//     assign iCache_2_Sch_w.req = iCache_2_Sch_req_i;

//     dcache_2_scheduler_t      dCache_2_Sch_w;
//     assign dCache_2_Sch_w.req[0]            = dCache_2_Sch_req_0_i;
//     assign dCache_2_Sch_w.req[1]            = dCache_2_Sch_req_1_i;
//     assign dCache_2_Sch_w.req[2]            = dCache_2_Sch_req_2_i;
//     assign dCache_2_Sch_w.req[3]            = dCache_2_Sch_req_3_i;
//     assign dCache_2_Sch_w.evictionBufAddr[0]= dCache_2_Sch_evictionBufAddr_0_i;
//     assign dCache_2_Sch_w.evictionBufAddr[1]= dCache_2_Sch_evictionBufAddr_1_i;
//     assign dCache_2_Sch_w.evictionBufAddr[2]= dCache_2_Sch_evictionBufAddr_2_i;
//     assign dCache_2_Sch_w.evictionBufAddr[3]= dCache_2_Sch_evictionBufAddr_3_i;
//     assign dCache_2_Sch_w.req_mio           = dCache_2_Sch_req_mio_i;

//     mem_2_scheduler_t         mem_2_Sch_w;
//     assign mem_2_Sch_w.writeBuf_V = mem_2_Sch_writeBuf_V_i;

//     dma_controller_2_scheduler_t dma_2_sch_w;
//     assign dma_2_sch_w.dma_req          = dma_2_sch_dma_req_i;
//     assign dma_2_sch_w.writeBuf_Address = dma_2_sch_writeBuf_Address_i;

//     Scheduler scheduler_unit (
//         .clk              (clk),
//         .rst              (rst),
//         .iCache_2_Sch_i   (iCache_2_Sch_w),
//         .dCache_2_Sch_i   (dCache_2_Sch_w),
//         .mem_2_Sch_i      (mem_2_Sch_w),
//         .dma_2_sch_i      (dma_2_sch_w),
//         .bestPick_o       (sch_best_pick),
//         .bestPick_bk_id_o (sch_best_pick_bk_id)
//     );
// `endif

    // ====================================================================
    // DTE
    // ====================================================================
//`ifdef DTE_STRUCTURAL
    // -- Structural DTE.v (flat ports) --
    DTE dte_unit (
        .clk                                                      (clk),
        .rst                                                      (rst),
        .bestPick_i                                               (sch_best_pick_ff),
        .bestPick_bk_id_i                                         (sch_best_pick_bk_id_ff),
        .dte_out_2_icache_Mem_Valid_o                             (dte_out_2_icache_Mem_Valid_o),
        .dte_out_2_icache_driveAddrBus_o                          (dte_out_2_icache_driveAddrBus_o),
        .dte_out_2_dcache_mem_valid_0_o                           (dte_out_2_dcache_mem_valid_0_o),
        .dte_out_2_dcache_mem_valid_1_o                           (dte_out_2_dcache_mem_valid_1_o),
        .dte_out_2_dcache_mem_valid_2_o                           (dte_out_2_dcache_mem_valid_2_o),
        .dte_out_2_dcache_mem_valid_3_o                           (dte_out_2_dcache_mem_valid_3_o),
        .dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_0_o(dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_0_o),
        .dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_1_o(dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_1_o),
        .dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_2_o(dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_2_o),
        .dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_3_o(dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_3_o),
        .dte_out_2_dcache_permissionToDriveAddrBus_Ld_0_o         (dte_out_2_dcache_permissionToDriveAddrBus_Ld_0_o),
        .dte_out_2_dcache_permissionToDriveAddrBus_Ld_1_o         (dte_out_2_dcache_permissionToDriveAddrBus_Ld_1_o),
        .dte_out_2_dcache_permissionToDriveAddrBus_Ld_2_o         (dte_out_2_dcache_permissionToDriveAddrBus_Ld_2_o),
        .dte_out_2_dcache_permissionToDriveAddrBus_Ld_3_o         (dte_out_2_dcache_permissionToDriveAddrBus_Ld_3_o),
        .dte_out_2_dcache_permissionToDriveAddrBus_eb_0_o         (dte_out_2_dcache_permissionToDriveAddrBus_eb_0_o),
        .dte_out_2_dcache_permissionToDriveAddrBus_eb_1_o         (dte_out_2_dcache_permissionToDriveAddrBus_eb_1_o),
        .dte_out_2_dcache_permissionToDriveAddrBus_eb_2_o         (dte_out_2_dcache_permissionToDriveAddrBus_eb_2_o),
        .dte_out_2_dcache_permissionToDriveAddrBus_eb_3_o         (dte_out_2_dcache_permissionToDriveAddrBus_eb_3_o),
        .dte_out_2_dcache_evictionBuf_clr_0_o                     (dte_out_2_dcache_evictionBuf_clr_0_o),
        .dte_out_2_dcache_evictionBuf_clr_1_o                     (dte_out_2_dcache_evictionBuf_clr_1_o),
        .dte_out_2_dcache_evictionBuf_clr_2_o                     (dte_out_2_dcache_evictionBuf_clr_2_o),
        .dte_out_2_dcache_evictionBuf_clr_3_o                     (dte_out_2_dcache_evictionBuf_clr_3_o),
        .dte_out_2_dcache_evictionBuf_setCommiting_0_o            (dte_out_2_dcache_evictionBuf_setCommiting_0_o),
        .dte_out_2_dcache_evictionBuf_setCommiting_1_o            (dte_out_2_dcache_evictionBuf_setCommiting_1_o),
        .dte_out_2_dcache_evictionBuf_setCommiting_2_o            (dte_out_2_dcache_evictionBuf_setCommiting_2_o),
        .dte_out_2_dcache_evictionBuf_setCommiting_3_o            (dte_out_2_dcache_evictionBuf_setCommiting_3_o),
        .dte_out_2_dcache_reqServed_mio_o                         (dte_out_2_dcache_reqServed_mio_o),
        .dte_out_2_dcache_permissionToDriveAddrBus_mio_o          (dte_out_2_dcache_permissionToDriveAddrBus_mio_o),
        .dte_out_2_dcache_permission2DriveDataBus_mio_o           (dte_out_2_dcache_permission2DriveDataBus_mio_o),
        .mem_2_dte_mem_Ready_i                                    (mem_2_dte_mem_Ready_i),
        .dte_2_mem_ld_req_o                                       (dte_2_mem_ld_req_o),
        .dte_2_mem_st_req_o                                       (dte_2_mem_st_req_o),
        .dte_2_mem_permission2DriveBus_o                          (dte_2_mem_permission2DriveBus_o),
        .dte_2_dma_permission2DriveDataBus_o                      (dte_2_dma_permission2DriveDataBus_o),
        .dte_2_dma_permission2DriveADDRBus_o                      (dte_2_dma_permission2DriveADDRBus_o),
        .dte_2_dma_commiting_o                                    (dte_2_dma_commiting_o),
        .dte_2_dma_writeComplete_o                                (dte_2_dma_writeComplete_o),
        .dte_2_dma_coreValOnBus_o                                 (dte_2_dma_coreValOnBus_o),
        .dte_2_ddr5_newPowerGateValueFromCore_o                   (dte_2_ddr5_newPowerGateValueFromCore_o),
        .dte_2_ddr5_driveDataBus_o                                (dte_2_ddr5_driveDataBus_o)
    );
// `else
//     // -- SV DTE.sv (struct ports) — adapt flat ports into struct wires --
//     mem_2_dte_t      mem_2_dte_w;
//     assign mem_2_dte_w.mem_Ready = mem_2_dte_mem_Ready_i;

//     dte_2_icache_t   dte_out_2_icache_w;
//     assign dte_out_2_icache_Mem_Valid_o    = dte_out_2_icache_w.Mem_Valid;
//     assign dte_out_2_icache_driveAddrBus_o = dte_out_2_icache_w.driveAddrBus;

//     dte_2_dcache_t   dte_out_2_dcache_w;
//     assign dte_out_2_dcache_mem_valid_0_o = dte_out_2_dcache_w.mem_valid[0];
//     assign dte_out_2_dcache_mem_valid_1_o = dte_out_2_dcache_w.mem_valid[1];
//     assign dte_out_2_dcache_mem_valid_2_o = dte_out_2_dcache_w.mem_valid[2];
//     assign dte_out_2_dcache_mem_valid_3_o = dte_out_2_dcache_w.mem_valid[3];
//     assign dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_0_o =
//         {dte_out_2_dcache_w.permissionToDriveDataBus_evictionBuf[0][3],
//          dte_out_2_dcache_w.permissionToDriveDataBus_evictionBuf[0][2],
//          dte_out_2_dcache_w.permissionToDriveDataBus_evictionBuf[0][1],
//          dte_out_2_dcache_w.permissionToDriveDataBus_evictionBuf[0][0]};
//     assign dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_1_o =
//         {dte_out_2_dcache_w.permissionToDriveDataBus_evictionBuf[1][3],
//          dte_out_2_dcache_w.permissionToDriveDataBus_evictionBuf[1][2],
//          dte_out_2_dcache_w.permissionToDriveDataBus_evictionBuf[1][1],
//          dte_out_2_dcache_w.permissionToDriveDataBus_evictionBuf[1][0]};
//     assign dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_2_o =
//         {dte_out_2_dcache_w.permissionToDriveDataBus_evictionBuf[2][3],
//          dte_out_2_dcache_w.permissionToDriveDataBus_evictionBuf[2][2],
//          dte_out_2_dcache_w.permissionToDriveDataBus_evictionBuf[2][1],
//          dte_out_2_dcache_w.permissionToDriveDataBus_evictionBuf[2][0]};
//     assign dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_3_o =
//         {dte_out_2_dcache_w.permissionToDriveDataBus_evictionBuf[3][3],
//          dte_out_2_dcache_w.permissionToDriveDataBus_evictionBuf[3][2],
//          dte_out_2_dcache_w.permissionToDriveDataBus_evictionBuf[3][1],
//          dte_out_2_dcache_w.permissionToDriveDataBus_evictionBuf[3][0]};
//     assign dte_out_2_dcache_permissionToDriveAddrBus_Ld_0_o = dte_out_2_dcache_w.permissionToDriveAddrBus_Ld[0];
//     assign dte_out_2_dcache_permissionToDriveAddrBus_Ld_1_o = dte_out_2_dcache_w.permissionToDriveAddrBus_Ld[1];
//     assign dte_out_2_dcache_permissionToDriveAddrBus_Ld_2_o = dte_out_2_dcache_w.permissionToDriveAddrBus_Ld[2];
//     assign dte_out_2_dcache_permissionToDriveAddrBus_Ld_3_o = dte_out_2_dcache_w.permissionToDriveAddrBus_Ld[3];
//     assign dte_out_2_dcache_permissionToDriveAddrBus_eb_0_o = dte_out_2_dcache_w.permissionToDriveAddrBus_eb[0];
//     assign dte_out_2_dcache_permissionToDriveAddrBus_eb_1_o = dte_out_2_dcache_w.permissionToDriveAddrBus_eb[1];
//     assign dte_out_2_dcache_permissionToDriveAddrBus_eb_2_o = dte_out_2_dcache_w.permissionToDriveAddrBus_eb[2];
//     assign dte_out_2_dcache_permissionToDriveAddrBus_eb_3_o = dte_out_2_dcache_w.permissionToDriveAddrBus_eb[3];
//     assign dte_out_2_dcache_evictionBuf_clr_0_o             = dte_out_2_dcache_w.evictionBuf_clr[0];
//     assign dte_out_2_dcache_evictionBuf_clr_1_o             = dte_out_2_dcache_w.evictionBuf_clr[1];
//     assign dte_out_2_dcache_evictionBuf_clr_2_o             = dte_out_2_dcache_w.evictionBuf_clr[2];
//     assign dte_out_2_dcache_evictionBuf_clr_3_o             = dte_out_2_dcache_w.evictionBuf_clr[3];
//     assign dte_out_2_dcache_evictionBuf_setCommiting_0_o    = dte_out_2_dcache_w.evictionBuf_setCommiting[0];
//     assign dte_out_2_dcache_evictionBuf_setCommiting_1_o    = dte_out_2_dcache_w.evictionBuf_setCommiting[1];
//     assign dte_out_2_dcache_evictionBuf_setCommiting_2_o    = dte_out_2_dcache_w.evictionBuf_setCommiting[2];
//     assign dte_out_2_dcache_evictionBuf_setCommiting_3_o    = dte_out_2_dcache_w.evictionBuf_setCommiting[3];
//     assign dte_out_2_dcache_reqServed_mio_o                 = dte_out_2_dcache_w.reqServed_mio;
//     assign dte_out_2_dcache_permissionToDriveAddrBus_mio_o  = dte_out_2_dcache_w.permissionToDriveAddrBus_mio;
//     assign dte_out_2_dcache_permission2DriveDataBus_mio_o   = dte_out_2_dcache_w.permission2DriveDataBus_mio;

//     dte_2_mem_t      dte_2_mem_w;
//     assign dte_2_mem_ld_req_o              = dte_2_mem_w.ld_req;
//     assign dte_2_mem_st_req_o              = dte_2_mem_w.st_req;
//     assign dte_2_mem_permission2DriveBus_o = dte_2_mem_w.permission2DriveBus;

//     dte_2_dma_controller_t dte_2_dma_w;
//     assign dte_2_dma_permission2DriveDataBus_o = {dte_2_dma_w.permission2DriveDataBus[3],
//                                                    dte_2_dma_w.permission2DriveDataBus[2],
//                                                    dte_2_dma_w.permission2DriveDataBus[1],
//                                                    dte_2_dma_w.permission2DriveDataBus[0]};
//     assign dte_2_dma_permission2DriveADDRBus_o = dte_2_dma_w.permission2DriveADDRBus;
//     assign dte_2_dma_commiting_o               = dte_2_dma_w.commiting;
//     assign dte_2_dma_writeComplete_o           = dte_2_dma_w.writeComplete;
//     assign dte_2_dma_coreValOnBus_o            = dte_2_dma_w.coreValOnBus;

//     dte_2_ddr5_t     dte_2_ddr5_w;
//     assign dte_2_ddr5_newPowerGateValueFromCore_o = dte_2_ddr5_w.newPowerGateValueFromCore;
//     assign dte_2_ddr5_driveDataBus_o              = dte_2_ddr5_w.driveDataBus;

//     DTE dte_unit (
//         .clk              (clk),
//         .rst              (rst),
//         .bestPick_i       (sch_best_pick_ff),
//         .bestPick_bk_id_i (sch_best_pick_bk_id_ff),
//         .dte_out_2_icache_o(dte_out_2_icache_w),
//         .dte_out_2_dcache_o(dte_out_2_dcache_w),
//         .mem_2_dte_i       (mem_2_dte_w),
//         .dte_2_mem_o       (dte_2_mem_w),
//         .dte_2_dma_o       (dte_2_dma_w),
//         .dte_2_ddr5_o      (dte_2_ddr5_w)
//     );
// `endif

endmodule
