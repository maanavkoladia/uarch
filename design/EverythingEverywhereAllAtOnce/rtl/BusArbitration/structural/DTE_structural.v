// ============================================================================
// DTE.v
// ============================================================================
// Structural Verilog-2005 port of DTE.sv
//   - 6 struct ports flattened to per-field wire vectors / per-bank wires
//   - 7 generated FSM modules (.sv, already structural) instantiated as-is
//   - bestPick_i ENUM checks: direct bit-pattern AND/OR matching on the
//                              4-bit bestPick_i — every req_hit lands in
//                              1-2 gate levels. 4 shared inverters fan
//                              out across all 7 req_hit signals.
//                              (Old version used DECODER_N(4) -> 16 one-hots
//                              -> OR-reduce: ~3 + 1-2 = 4-5 levels.)
//   - bk_id        : 1x DECODER_N(2) -> 4-bit one-hot
//   - DTE_Busy     : NAND_4(NOR_4, NOR_4, NOR_4, INV) DeMorgan tree
//                    replaces OR_4 + OR_4 + OR_7 (5 cells, 2 levels)
//   - per-bank FSMs unrolled (4 instances each)
// ============================================================================

module DTE (
    input  wire         clk,
    input  wire         rst,                                     // active-low

    // From scheduler (req_2_sch_t winner + dcache bank id)
    // req_2_sch_t is now 4-bit (max enum value 14 fits in 4 bits).
    input  wire [3:0]   bestPick_i,
    input  wire [1:0]   bestPick_bk_id_i,

    // dte_2_icache_t (out)
    output wire         dte_out_2_icache_Mem_Valid_o,
    output wire         dte_out_2_icache_driveAddrBus_o,

    // dte_2_dcache_t (out): per-bank arrays expanded
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

    // mem_2_dte_t (in)
    input  wire         mem_2_dte_mem_Ready_i,

    // dte_2_mem_t (out)
    output wire         dte_2_mem_ld_req_o,
    output wire         dte_2_mem_st_req_o,
    output wire [3:0]   dte_2_mem_permission2DriveBus_o,

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
    // Per-FSM req_hit signals — DIRECT bit-pattern matching on bestPick_i.
    //
    //   Earlier version went through a 4-input decoder (16-bit one-hot)
    //   then OR-reduced subsets. That added 3 levels (decoder) + 1-2
    //   (OR-reduce). Here we land every req_hit in 1-2 levels by matching
    //   bit patterns directly. Shared inverters give ~bp[i] for free.
    //
    //   Enum encoding (4-bit binary):
    //     ICACHE_HIGH_PRI                 = 14 = 1110
    //     DCACHE_EB_BLOCKING_BANK         = 13 = 1101
    //     DCACHE_EB_BLOCKING_ST_OVERRIDE  = 12 = 1100
    //     DCACHE_EB_BLOCKING_LD           = 11 = 1011
    //     DCACHE_EB_BLOCK_ST              = 10 = 1010
    //     DCACHE_FILL_ST_OVERRIDE         =  9 = 1001
    //     DCACHE_FILL_LD                  =  8 = 1000
    //     DCACHE_FILL_ST                  =  7 = 0111
    //     DCACHE_EB_WR                    =  6 = 0110
    //     DCACHE_MIO_LD_FROM_SIMPLE       =  5 = 0101
    //     DCACHE_MIO_WR_COMPLEX           =  4 = 0100
    //     DCACHE_MIO_WR_SIMPLE            =  3 = 0011
    //     ICACHE_LOW_PRI_REQ              =  2 = 0010
    //     DMA_WRITE_REQ                   =  1 = 0001
    //     NO_REQ                          =  0 = 0000
    // ====================================================================

    // Inverters of bestPick bits — kept active; shared by structural blocks below.
    wire bp_n0, bp_n1, bp_n2, bp_n3;
    `INV_N(u_bp_n0, 1, bestPick_i[0], bp_n0)
    `INV_N(u_bp_n1, 1, bestPick_i[1], bp_n1)
    `INV_N(u_bp_n2, 1, bestPick_i[2], bp_n2)
    `INV_N(u_bp_n3, 1, bestPick_i[3], bp_n3)

    // ----- MEM -> ICache: bp ∈ { 14 (ICACHE_HIGH_PRI), 2 (ICACHE_LOW_PRI_REQ) } -----
    // SV equivalent:
    // logic mem_2_icache_req_hit;
    // assign mem_2_icache_req_hit = (bestPick_i == ICACHE_HIGH_PRI) ||
    //                               (bestPick_i == ICACHE_LOW_PRI_REQ);
    // structural (commented out):
    //   eq 14 : bp[3] & bp[2] & bp[1] & ~bp[0]
    //   eq  2 : ~bp[3] & ~bp[2] & bp[1] & ~bp[0]
    //   Common factor (bp[1] & ~bp[0]) lets us share. Skip sharing here —
    //   the AND_4's are flat and balanced, and one OR_2 closes it.
    wire mem_2_icache_eq14, mem_2_icache_eq2;
    `AND_4(u_eq14, 1, mem_2_icache_eq14,
           bestPick_i[3], bestPick_i[2], bestPick_i[1], bp_n0)
    `AND_4(u_eq2,  1, mem_2_icache_eq2,
           bp_n3,         bp_n2,         bestPick_i[1], bp_n0)
    wire mem_2_icache_req_hit;
    `OR_2(u_ic_req_hit, 1, mem_2_icache_req_hit,
          mem_2_icache_eq14, mem_2_icache_eq2)
    

    // ----- MEM -> DCache: bp ∈ { 7 (DCACHE_FILL_ST), 8 (DCACHE_FILL_LD), 9 (DCACHE_FILL_ST_OVERRIDE) } -----
    // SV equivalent:
    // logic mem_2_dcache_req_hit;
    // assign mem_2_dcache_req_hit = (bestPick_i == DCACHE_FILL_ST_OVERRIDE) ||
    //                               (bestPick_i == DCACHE_FILL_LD)          ||
    //                               (bestPick_i == DCACHE_FILL_ST);
    //structural (commented out):
    //   eq 7    : ~bp[3] & bp[2] & bp[1] & bp[0]
    //   eq 8|9  : bp[3] & ~bp[2] & ~bp[1]            (bp[0] don't-care)
    wire mem_2_dcache_eq7, mem_2_dcache_eq89;
    `AND_4(u_eq7,  1, mem_2_dcache_eq7,
           bp_n3, bestPick_i[2], bestPick_i[1], bestPick_i[0])
    `AND_3(u_eq89, 1, mem_2_dcache_eq89,
           bestPick_i[3], bp_n2, bp_n1)
    wire mem_2_dcache_req_hit;
    `OR_2(u_md_req_hit, 1, mem_2_dcache_req_hit,
          mem_2_dcache_eq7, mem_2_dcache_eq89)
    

    // ----- DCache -> MEM: bp ∈ { 6 (DCACHE_EB_WR), 10 (DCACHE_EB_BLOCK_ST), 11 (DCACHE_EB_BLOCKING_LD),
    //                              12 (DCACHE_EB_BLOCKING_ST_OVERRIDE), 13 (DCACHE_EB_BLOCKING_BANK) } -----
    // SV equivalent:
    // logic dcache_2_mem_req_hit;
    // assign dcache_2_mem_req_hit = (bestPick_i == DCACHE_EB_BLOCKING_ST_OVERRIDE) ||
    //                               (bestPick_i == DCACHE_EB_BLOCKING_LD)          ||
    //                               (bestPick_i == DCACHE_EB_BLOCK_ST)             ||
    //                               (bestPick_i == DCACHE_EB_BLOCKING_BANK)        ||
    //                               (bestPick_i == DCACHE_EB_WR);
    // structural (commented out):
    //   eq 6      : ~bp[3] & bp[2] & bp[1] & ~bp[0]
    //   eq 10|11  : bp[3] & ~bp[2] & bp[1]            (bp[0] don't-care)
    //   eq 12|13  : bp[3] & bp[2] & ~bp[1]            (bp[0] don't-care)
    wire dm_eq6, dm_eq1011, dm_eq1213;
    `AND_4(u_eq6,    1, dm_eq6,
           bp_n3, bestPick_i[2], bestPick_i[1], bp_n0)
    `AND_3(u_eq1011, 1, dm_eq1011,
           bestPick_i[3], bp_n2, bestPick_i[1])
    `AND_3(u_eq1213, 1, dm_eq1213,
           bestPick_i[3], bestPick_i[2], bp_n1)
    wire dcache_2_mem_req_hit;
    `OR_3(u_dm_req_hit, 1, dcache_2_mem_req_hit,
          dm_eq6, dm_eq1011, dm_eq1213)
    

    // ----- Single-enum req_hits — one per enum value -----
    //   bp ==  5 (DCACHE_MIO_LD_FROM_SIMPLE): ddr5 -> core
    //   bp ==  3 (DCACHE_MIO_WR_SIMPLE):      core -> ddr5
    //   bp ==  4 (DCACHE_MIO_WR_COMPLEX):     core -> dma
    //   bp ==  1 (DMA_WRITE_REQ):             dma  -> mem
    // SV equivalent:
    // logic ddr5_2_core_req_hit, core_2_ddr5_req_hit, core_2_dma_req_hit, dma_2_mem_req_hit;
    // assign ddr5_2_core_req_hit = (bestPick_i == DCACHE_MIO_LD_FROM_SIMPLE);
    // assign core_2_ddr5_req_hit = (bestPick_i == DCACHE_MIO_WR_SIMPLE);
    // assign core_2_dma_req_hit  = (bestPick_i == DCACHE_MIO_WR_COMPLEX);
    // assign dma_2_mem_req_hit   = (bestPick_i == DMA_WRITE_REQ);
    //structural (commented out):
    wire ddr5_2_core_req_hit, core_2_ddr5_req_hit, core_2_dma_req_hit, dma_2_mem_req_hit;
    `AND_4(u_eq5, 1, ddr5_2_core_req_hit,
           bp_n3,         bestPick_i[2], bp_n1,         bestPick_i[0])
    `AND_4(u_eq3, 1, core_2_ddr5_req_hit,
           bp_n3,         bp_n2,         bestPick_i[1], bestPick_i[0])
    `AND_4(u_eq4, 1, core_2_dma_req_hit,
           bp_n3,         bestPick_i[2], bp_n1,         bp_n0)
    `AND_4(u_eq1, 1, dma_2_mem_req_hit,
           bp_n3,         bp_n2,         bp_n1,         bestPick_i[0])
    

    // ====================================================================
    // bk_id one-hot: which dcache bank does bestPick_bk_id_i select?
    // ====================================================================
    // SV equivalent:
    // logic [3:0] bk_hit;
    // always_comb begin
    //     for (int i = 0; i < 4; i++) bk_hit[i] = (bestPick_bk_id_i == i);
    // end
     //structural (commented out):
    wire [3:0] bk_hit;
    `DECODER_N(u_bk_dec, 2, bestPick_bk_id_i, bk_hit)
    

    // ====================================================================
    // Per-FSM busy wires (driven by FSMs below; aggregated into DTE_Busy)
    // ====================================================================
    wire        mem_2_icache_busy;
    wire [3:0]  mem_2_dcache_busy_per;
    wire [3:0]  dcache_2_mem_busy_per;
    wire        ddr5_2_core_busy;
    wire        core_2_ddr5_busy;
    wire        core_2_dma_busy;
    wire        dma_2_mem_busy;

    // ====================================================================
    // DTE_Busy = OR of all 13 individual busy signals (Moore sources only,
    //           so no combo loop with others_busy_i fan-in).
    //
    //   Group the 13 inputs into four sets of <=4 and apply DeMorgan:
    //     A = mem_2_dcache_busy_per[0..3]            (4)
    //     B = dcache_2_mem_busy_per[0..3]            (4)
    //     C = mem_2_icache, ddr5_2_core, core_2_ddr5, core_2_dma  (4)
    //     D = dma_2_mem                              (1)
    //   DTE_Busy = A|B|C|D
    //            = ~(~A & ~B & ~C & ~D)
    //            = NAND_4( NOR_4(A), NOR_4(B), NOR_4(C), INV(D) )
    //
    //   Replaces the previous OR_4 + OR_4 + OR_7 chain. NOR/NAND are the
    //   native CMOS gates (single PMOS/NMOS stack each), and OR_7 was an
    //   internal tree of 4 OR_2 + 1 OR_3.
    // ====================================================================
    // SV equivalent:
    // logic DTE_Busy;
    // assign DTE_Busy = |mem_2_dcache_busy_per |
    //                   |dcache_2_mem_busy_per |
    //                   mem_2_icache_busy      |
    //                   ddr5_2_core_busy       |
    //                   core_2_ddr5_busy       |
    //                   core_2_dma_busy        |
    //                   dma_2_mem_busy;
    // structural (commented out):
    wire nor_md_busy, nor_dm_busy, nor_misc_busy, dma_2_mem_busy_n;
    `NOR_4(u_nor_md_busy,   1, nor_md_busy,
           mem_2_dcache_busy_per[0], mem_2_dcache_busy_per[1],
           mem_2_dcache_busy_per[2], mem_2_dcache_busy_per[3])
    `NOR_4(u_nor_dm_busy,   1, nor_dm_busy,
           dcache_2_mem_busy_per[0], dcache_2_mem_busy_per[1],
           dcache_2_mem_busy_per[2], dcache_2_mem_busy_per[3])
    `NOR_4(u_nor_misc_busy, 1, nor_misc_busy,
           mem_2_icache_busy, ddr5_2_core_busy,
           core_2_ddr5_busy,  core_2_dma_busy)
    `INV_N(u_inv_dma_busy,  1, dma_2_mem_busy, dma_2_mem_busy_n)
    wire DTE_Busy;
    `NAND_4(u_nand_dte_busy, 1, DTE_Busy,
            nor_md_busy, nor_dm_busy, nor_misc_busy, dma_2_mem_busy_n)
    

    // ====================================================================
    // Per-bank FSM output collection vectors
    //   <name>_b<DBIDX>[BANKIDX] = bank BANKIDX's Drv_DB_<DBIDX> output
    // ====================================================================
    wire [3:0] mem_2_dcache_ld_req;       // per-bank ld_req
    wire [3:0] mem_2_dcache_drv_db_b0;    // per-bank Drv_DB_0
    wire [3:0] mem_2_dcache_drv_db_b1;
    wire [3:0] mem_2_dcache_drv_db_b2;
    wire [3:0] mem_2_dcache_drv_db_b3;

    wire [3:0] dcache_2_mem_st_req;       // per-bank st_req

    // ====================================================================
    // FSM 1: MEM -> ICache (single instance)
    // ====================================================================
    wire mem_2_icache_S_0_unused, mem_2_icache_S_1_unused, mem_2_icache_S_2_unused;
    wire mem_2_icache_drv_db_b0, mem_2_icache_drv_db_b1;
    wire mem_2_icache_drv_db_b2, mem_2_icache_drv_db_b3;
    wire mem_2_icache_ld_req;

    DTE_MEM_2_ICache_FSM DTE_MEM_2_ICache (
        .clk             (clk),
        .rst             (rst),
        .req_hit_i       (mem_2_icache_req_hit),
        .others_busy_i   (DTE_Busy),
        .mem_ready_i     (mem_2_dte_mem_Ready_i),
        .S_0             (mem_2_icache_S_0_unused),
        .S_1             (mem_2_icache_S_1_unused),
        .S_2             (mem_2_icache_S_2_unused),
        .busy_o          (mem_2_icache_busy),
        .mem_valid_o     (dte_out_2_icache_Mem_Valid_o),
        .ld_req_o        (mem_2_icache_ld_req),
        .Drive_Addr_Bus_o(dte_out_2_icache_driveAddrBus_o),
        .Drv_DB_0_o      (mem_2_icache_drv_db_b0),
        .Drv_DB_1_o      (mem_2_icache_drv_db_b1),
        .Drv_DB_2_o      (mem_2_icache_drv_db_b2),
        .Drv_DB_3_o      (mem_2_icache_drv_db_b3)
    );

    // ====================================================================
    // FSM 2: MEM -> DCache (per-bank, 4 instances)
    // ====================================================================
    // bank 0
    wire md_S_0_0_u, md_S_1_0_u, md_S_2_0_u;
    DTE_MEM_2_DCache_FSM mem_2_dcache_fsm_0 (
        .clk             (clk),
        .rst             (rst),
        .req_hit_i       (mem_2_dcache_req_hit),
        .bank_hit_i      (bk_hit[0]),
        .others_busy_i   (DTE_Busy),
        .mem_ready_i     (mem_2_dte_mem_Ready_i),
        .S_0             (md_S_0_0_u),
        .S_1             (md_S_1_0_u),
        .S_2             (md_S_2_0_u),
        .busy_o          (mem_2_dcache_busy_per[0]),
        .mem_valid_o     (dte_out_2_dcache_mem_valid_0_o),
        .ld_req_o        (mem_2_dcache_ld_req[0]),
        .Drive_Addr_Bus_o(dte_out_2_dcache_permissionToDriveAddrBus_Ld_0_o),
        .Drv_DB_0_o      (mem_2_dcache_drv_db_b0[0]),
        .Drv_DB_1_o      (mem_2_dcache_drv_db_b1[0]),
        .Drv_DB_2_o      (mem_2_dcache_drv_db_b2[0]),
        .Drv_DB_3_o      (mem_2_dcache_drv_db_b3[0])
    );
    // bank 1
    wire md_S_0_1_u, md_S_1_1_u, md_S_2_1_u;
    DTE_MEM_2_DCache_FSM mem_2_dcache_fsm_1 (
        .clk             (clk),
        .rst             (rst),
        .req_hit_i       (mem_2_dcache_req_hit),
        .bank_hit_i      (bk_hit[1]),
        .others_busy_i   (DTE_Busy),
        .mem_ready_i     (mem_2_dte_mem_Ready_i),
        .S_0             (md_S_0_1_u),
        .S_1             (md_S_1_1_u),
        .S_2             (md_S_2_1_u),
        .busy_o          (mem_2_dcache_busy_per[1]),
        .mem_valid_o     (dte_out_2_dcache_mem_valid_1_o),
        .ld_req_o        (mem_2_dcache_ld_req[1]),
        .Drive_Addr_Bus_o(dte_out_2_dcache_permissionToDriveAddrBus_Ld_1_o),
        .Drv_DB_0_o      (mem_2_dcache_drv_db_b0[1]),
        .Drv_DB_1_o      (mem_2_dcache_drv_db_b1[1]),
        .Drv_DB_2_o      (mem_2_dcache_drv_db_b2[1]),
        .Drv_DB_3_o      (mem_2_dcache_drv_db_b3[1])
    );
    // bank 2
    wire md_S_0_2_u, md_S_1_2_u, md_S_2_2_u;
    DTE_MEM_2_DCache_FSM mem_2_dcache_fsm_2 (
        .clk             (clk),
        .rst             (rst),
        .req_hit_i       (mem_2_dcache_req_hit),
        .bank_hit_i      (bk_hit[2]),
        .others_busy_i   (DTE_Busy),
        .mem_ready_i     (mem_2_dte_mem_Ready_i),
        .S_0             (md_S_0_2_u),
        .S_1             (md_S_1_2_u),
        .S_2             (md_S_2_2_u),
        .busy_o          (mem_2_dcache_busy_per[2]),
        .mem_valid_o     (dte_out_2_dcache_mem_valid_2_o),
        .ld_req_o        (mem_2_dcache_ld_req[2]),
        .Drive_Addr_Bus_o(dte_out_2_dcache_permissionToDriveAddrBus_Ld_2_o),
        .Drv_DB_0_o      (mem_2_dcache_drv_db_b0[2]),
        .Drv_DB_1_o      (mem_2_dcache_drv_db_b1[2]),
        .Drv_DB_2_o      (mem_2_dcache_drv_db_b2[2]),
        .Drv_DB_3_o      (mem_2_dcache_drv_db_b3[2])
    );
    // bank 3
    wire md_S_0_3_u, md_S_1_3_u, md_S_2_3_u;
    DTE_MEM_2_DCache_FSM mem_2_dcache_fsm_3 (
        .clk             (clk),
        .rst             (rst),
        .req_hit_i       (mem_2_dcache_req_hit),
        .bank_hit_i      (bk_hit[3]),
        .others_busy_i   (DTE_Busy),
        .mem_ready_i     (mem_2_dte_mem_Ready_i),
        .S_0             (md_S_0_3_u),
        .S_1             (md_S_1_3_u),
        .S_2             (md_S_2_3_u),
        .busy_o          (mem_2_dcache_busy_per[3]),
        .mem_valid_o     (dte_out_2_dcache_mem_valid_3_o),
        .ld_req_o        (mem_2_dcache_ld_req[3]),
        .Drive_Addr_Bus_o(dte_out_2_dcache_permissionToDriveAddrBus_Ld_3_o),
        .Drv_DB_0_o      (mem_2_dcache_drv_db_b0[3]),
        .Drv_DB_1_o      (mem_2_dcache_drv_db_b1[3]),
        .Drv_DB_2_o      (mem_2_dcache_drv_db_b2[3]),
        .Drv_DB_3_o      (mem_2_dcache_drv_db_b3[3])
    );

    // ====================================================================
    // FSM 3: DCache -> MEM (per-bank, 4 instances)
    // ====================================================================
    // bank 0
    wire dm_S_0_0_u, dm_S_1_0_u, dm_S_2_0_u;
    DTE_DCache_2_MEM_FSM dcache_2_mem_fsm_0 (
        .clk             (clk),
        .rst             (rst),
        .req_hit_i       (dcache_2_mem_req_hit),
        .bank_hit_i      (bk_hit[0]),
        .others_busy_i   (DTE_Busy),
        .S_0             (dm_S_0_0_u),
        .S_1             (dm_S_1_0_u),
        .S_2             (dm_S_2_0_u),
        .busy_o          (dcache_2_mem_busy_per[0]),
        .st_req_o        (dcache_2_mem_st_req[0]),
        .eb_clear_o      (dte_out_2_dcache_evictionBuf_clr_0_o),
        .set_eb_commit_o (dte_out_2_dcache_evictionBuf_setCommiting_0_o),
        .Drive_Addr_Bus_o(dte_out_2_dcache_permissionToDriveAddrBus_eb_0_o),
        .Drv_DB_0_o      (dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_0_o[0]),
        .Drv_DB_1_o      (dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_0_o[1]),
        .Drv_DB_2_o      (dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_0_o[2]),
        .Drv_DB_3_o      (dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_0_o[3])
    );
    // bank 1
    wire dm_S_0_1_u, dm_S_1_1_u, dm_S_2_1_u;
    DTE_DCache_2_MEM_FSM dcache_2_mem_fsm_1 (
        .clk             (clk),
        .rst             (rst),
        .req_hit_i       (dcache_2_mem_req_hit),
        .bank_hit_i      (bk_hit[1]),
        .others_busy_i   (DTE_Busy),
        .S_0             (dm_S_0_1_u),
        .S_1             (dm_S_1_1_u),
        .S_2             (dm_S_2_1_u),
        .busy_o          (dcache_2_mem_busy_per[1]),
        .st_req_o        (dcache_2_mem_st_req[1]),
        .eb_clear_o      (dte_out_2_dcache_evictionBuf_clr_1_o),
        .set_eb_commit_o (dte_out_2_dcache_evictionBuf_setCommiting_1_o),
        .Drive_Addr_Bus_o(dte_out_2_dcache_permissionToDriveAddrBus_eb_1_o),
        .Drv_DB_0_o      (dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_1_o[0]),
        .Drv_DB_1_o      (dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_1_o[1]),
        .Drv_DB_2_o      (dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_1_o[2]),
        .Drv_DB_3_o      (dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_1_o[3])
    );
    // bank 2
    wire dm_S_0_2_u, dm_S_1_2_u, dm_S_2_2_u;
    DTE_DCache_2_MEM_FSM dcache_2_mem_fsm_2 (
        .clk             (clk),
        .rst             (rst),
        .req_hit_i       (dcache_2_mem_req_hit),
        .bank_hit_i      (bk_hit[2]),
        .others_busy_i   (DTE_Busy),
        .S_0             (dm_S_0_2_u),
        .S_1             (dm_S_1_2_u),
        .S_2             (dm_S_2_2_u),
        .busy_o          (dcache_2_mem_busy_per[2]),
        .st_req_o        (dcache_2_mem_st_req[2]),
        .eb_clear_o      (dte_out_2_dcache_evictionBuf_clr_2_o),
        .set_eb_commit_o (dte_out_2_dcache_evictionBuf_setCommiting_2_o),
        .Drive_Addr_Bus_o(dte_out_2_dcache_permissionToDriveAddrBus_eb_2_o),
        .Drv_DB_0_o      (dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_2_o[0]),
        .Drv_DB_1_o      (dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_2_o[1]),
        .Drv_DB_2_o      (dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_2_o[2]),
        .Drv_DB_3_o      (dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_2_o[3])
    );
    // bank 3
    wire dm_S_0_3_u, dm_S_1_3_u, dm_S_2_3_u;
    DTE_DCache_2_MEM_FSM dcache_2_mem_fsm_3 (
        .clk             (clk),
        .rst             (rst),
        .req_hit_i       (dcache_2_mem_req_hit),
        .bank_hit_i      (bk_hit[3]),
        .others_busy_i   (DTE_Busy),
        .S_0             (dm_S_0_3_u),
        .S_1             (dm_S_1_3_u),
        .S_2             (dm_S_2_3_u),
        .busy_o          (dcache_2_mem_busy_per[3]),
        .st_req_o        (dcache_2_mem_st_req[3]),
        .eb_clear_o      (dte_out_2_dcache_evictionBuf_clr_3_o),
        .set_eb_commit_o (dte_out_2_dcache_evictionBuf_setCommiting_3_o),
        .Drive_Addr_Bus_o(dte_out_2_dcache_permissionToDriveAddrBus_eb_3_o),
        .Drv_DB_0_o      (dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_3_o[0]),
        .Drv_DB_1_o      (dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_3_o[1]),
        .Drv_DB_2_o      (dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_3_o[2]),
        .Drv_DB_3_o      (dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_3_o[3])
    );

    // ====================================================================
    // FSM 4: DDR5 -> Core
    // ====================================================================
    wire ddr5_2_core_S_0_u, ddr5_2_core_S_1_u;
    wire ddr5_2_core_reqServed;
    wire ddr5_2_core_drvAddrBus;
    DTE_DDR5_2_Core_FSM ddr5_2_core_fsm (
        .clk             (clk),
        .rst             (rst),
        .req_hit_i       (ddr5_2_core_req_hit),
        .others_busy_i   (DTE_Busy),
        .S_0             (ddr5_2_core_S_0_u),
        .S_1             (ddr5_2_core_S_1_u),
        .busy_o          (ddr5_2_core_busy),
        .reqServed_o     (ddr5_2_core_reqServed),
        .Drive_Addr_Bus_o(ddr5_2_core_drvAddrBus),
        .Drv_DB_o        (dte_2_ddr5_driveDataBus_o)
    );

    // ====================================================================
    // FSM 5: Core -> DDR5
    // ====================================================================
    wire core_2_ddr5_S_0_u, core_2_ddr5_S_1_u;
    wire core_2_ddr5_reqServed;
    wire core_2_ddr5_drvAddrBus;
    wire core_2_ddr5_drvDB;
    DTE_Core_2_DDR5_FSM core_2_ddr5_fsm (
        .clk             (clk),
        .rst             (rst),
        .req_hit_i       (core_2_ddr5_req_hit),
        .others_busy_i   (DTE_Busy),
        .S_0             (core_2_ddr5_S_0_u),
        .S_1             (core_2_ddr5_S_1_u),
        .busy_o                     (core_2_ddr5_busy),
        .reqServed_o                (core_2_ddr5_reqServed),
        .Drive_Addr_Bus_o           (core_2_ddr5_drvAddrBus),
        .Drv_DB_o                   (core_2_ddr5_drvDB),
        .newPowerGateValueFromCore_o(dte_2_ddr5_newPowerGateValueFromCore_o)
    );

    // ====================================================================
    // FSM 6: Core -> DMA
    // ====================================================================
    wire core_2_dma_S_0_u, core_2_dma_S_1_u;
    wire core_2_dma_reqServed;
    wire core_2_dma_drvAddrBus;
    wire core_2_dma_drvDB;
    DTE_Core_2_DMA_FSM core_2_dma_fsm (
        .clk             (clk),
        .rst             (rst),
        .req_hit_i       (core_2_dma_req_hit),
        .others_busy_i   (DTE_Busy),
        .S_0             (core_2_dma_S_0_u),
        .S_1             (core_2_dma_S_1_u),
        .busy_o          (core_2_dma_busy),
        .reqServed_o     (core_2_dma_reqServed),
        .Drive_Addr_Bus_o(core_2_dma_drvAddrBus),
        .Drv_DB_o        (core_2_dma_drvDB),
        .coreValOnBus_o  (dte_2_dma_coreValOnBus_o)
    );

    // ====================================================================
    // FSM 7: DMA -> MEM
    // ====================================================================
    wire dm2m_S_0_u, dm2m_S_1_u, dm2m_S_2_u;
    wire dma_2_mem_st_req_single;
    DTE_DMA_2_MEM_FSM dma_2_mem_fsm (
        .clk             (clk),
        .rst             (rst),
        .req_hit_i       (dma_2_mem_req_hit),
        .others_busy_i   (DTE_Busy),
        .S_0             (dm2m_S_0_u),
        .S_1             (dm2m_S_1_u),
        .S_2             (dm2m_S_2_u),
        .busy_o          (dma_2_mem_busy),
        .st_req_o        (dma_2_mem_st_req_single),
        .WriteComplete_o (dte_2_dma_writeComplete_o),
        .Commiting_o     (dte_2_dma_commiting_o),
        .Drive_Addr_Bus_o(dte_2_dma_permission2DriveADDRBus_o),
        .Drv_DB_0_o      (dte_2_dma_permission2DriveDataBus_o[0]),
        .Drv_DB_1_o      (dte_2_dma_permission2DriveDataBus_o[1]),
        .Drv_DB_2_o      (dte_2_dma_permission2DriveDataBus_o[2]),
        .Drv_DB_3_o      (dte_2_dma_permission2DriveDataBus_o[3])
    );

    // ====================================================================
    // OR-reduce glue (multi-driver merges of FSM outputs)
    // ====================================================================

    // dte_2_mem.ld_req = mem_2_icache.ld_req | OR(mem_2_dcache.ld_req[i])
    `OR_5(u_or_ld_req, 1, dte_2_mem_ld_req_o,
          mem_2_icache_ld_req,
          mem_2_dcache_ld_req[0], mem_2_dcache_ld_req[1],
          mem_2_dcache_ld_req[2], mem_2_dcache_ld_req[3])

    // dte_2_mem.permission2DriveBus[b] (b=0..3) = OR over all FSMs that
    // drive bus byte b into MEM (icache fill source + per-bank dcache fill)
    `OR_5(u_or_drv_db_b0, 1, dte_2_mem_permission2DriveBus_o[0],
          mem_2_icache_drv_db_b0,
          mem_2_dcache_drv_db_b0[0], mem_2_dcache_drv_db_b0[1],
          mem_2_dcache_drv_db_b0[2], mem_2_dcache_drv_db_b0[3])
    `OR_5(u_or_drv_db_b1, 1, dte_2_mem_permission2DriveBus_o[1],
          mem_2_icache_drv_db_b1,
          mem_2_dcache_drv_db_b1[0], mem_2_dcache_drv_db_b1[1],
          mem_2_dcache_drv_db_b1[2], mem_2_dcache_drv_db_b1[3])
    `OR_5(u_or_drv_db_b2, 1, dte_2_mem_permission2DriveBus_o[2],
          mem_2_icache_drv_db_b2,
          mem_2_dcache_drv_db_b2[0], mem_2_dcache_drv_db_b2[1],
          mem_2_dcache_drv_db_b2[2], mem_2_dcache_drv_db_b2[3])
    `OR_5(u_or_drv_db_b3, 1, dte_2_mem_permission2DriveBus_o[3],
          mem_2_icache_drv_db_b3,
          mem_2_dcache_drv_db_b3[0], mem_2_dcache_drv_db_b3[1],
          mem_2_dcache_drv_db_b3[2], mem_2_dcache_drv_db_b3[3])

    // dte_2_mem.st_req = dma_2_mem.st_req | OR(dcache_2_mem.st_req[i])
    `OR_5(u_or_st_req, 1, dte_2_mem_st_req_o,
          dma_2_mem_st_req_single,
          dcache_2_mem_st_req[0], dcache_2_mem_st_req[1],
          dcache_2_mem_st_req[2], dcache_2_mem_st_req[3])

    // dte_out_2_dcache.reqServed_mio = ddr5_2_core | core_2_ddr5 | core_2_dma
    `OR_3(u_or_req_served_mio, 1, dte_out_2_dcache_reqServed_mio_o,
          ddr5_2_core_reqServed, core_2_ddr5_reqServed, core_2_dma_reqServed)

    // dte_out_2_dcache.permissionToDriveAddrBus_mio = same triple
    `OR_3(u_or_drv_addr_mio, 1, dte_out_2_dcache_permissionToDriveAddrBus_mio_o,
          ddr5_2_core_drvAddrBus, core_2_ddr5_drvAddrBus, core_2_dma_drvAddrBus)

    // dte_out_2_dcache.permission2DriveDataBus_mio = core_2_ddr5 | core_2_dma
    //   (matches DTE.sv line 170; the commented line 171 includes ddr5_2_core
    //    but is dead code in the SV)
    `OR_2(u_or_drv_db_mio, 1, dte_out_2_dcache_permission2DriveDataBus_mio_o,
          core_2_ddr5_drvDB, core_2_dma_drvDB)

endmodule
