// Pure structural Verilog 2005 top-level for the memory subsystem.
// No package imports, no SV structs, no always blocks, no `logic`.
// All struct interfaces are unpacked into individual flat wires at the
// module boundary; struct ↔ flat conversion lives in AllAtOnce_TOP.sv.


module Everywhere_TOP (
    input wire clk,
    input wire rst,

    // ===== core_2_icache_t inputs (unpacked) =====
    input wire        icache_icache_en_i,
    input wire [14:0] icache_p_addr_i,                // p_address_t
    input wire [31:0] icache_v_addr_i,                // v_address_t = address_t
    input wire [2:0]  icache_num_valid_IDM_slots_i,   // [$clog2(NUM_IDM_SLOTS):0]

    // ===== icache_2_core_t outputs (unpacked) =====
    output wire        icache_hit_o,
    output wire [127:0] icache_instruction_line_o,    // 16-byte cache line, LSB-first

    // ===== core_2_dcache_t inputs (unpacked, mirrors DCache_TOP.v ports) =====
    input wire        core_ld_addr_0_V_i,
    input wire [14:0] core_ld_addr_0_i,
    input wire        core_ld_addr_1_V_i,
    input wire [14:0] core_ld_addr_1_i,

    input wire        core_stq_full_0_i,
    input wire        core_stq_full_1_i,
    input wire        core_stq_full_2_i,
    input wire        core_stq_full_3_i,
    input wire        core_stq_empty_0_i,
    input wire        core_stq_empty_1_i,
    input wire        core_stq_empty_2_i,
    input wire        core_stq_empty_3_i,
    input wire [14:0] core_stq_addr_0_i,
    input wire [14:0] core_stq_addr_1_i,
    input wire [14:0] core_stq_addr_2_i,
    input wire [14:0] core_stq_addr_3_i,
    input wire [15:0] core_stq_bitvec_0_i,
    input wire [15:0] core_stq_bitvec_1_i,
    input wire [15:0] core_stq_bitvec_2_i,
    input wire [15:0] core_stq_bitvec_3_i,
    input wire [127:0] core_stq_data_0_i,
    input wire [127:0] core_stq_data_1_i,
    input wire [127:0] core_stq_data_2_i,
    input wire [127:0] core_stq_data_3_i,

    input wire        core_ld_addr_MIO_V_i,
    input wire [14:0] core_ld_addr_MIO_i,

    input wire        core_stq_info_mio_empty_i,
    input wire [14:0] core_stq_info_mio_addr_i,
    input wire [127:0] core_stq_info_mio_data_i,

    input wire        core_memStage_CLR_REQ_0_i,
    input wire        core_memStage_CLR_REQ_1_i,
    input wire        core_memStage_CLR_REQ_2_i,
    input wire        core_memStage_CLR_REQ_3_i,
    input wire        core_memStage_CLR_REQ_MIO_i,

    // ===== dcache_2_core_t outputs (unpacked, mirrors DCache_TOP.v ports) =====
    output wire        out2Core_reqServed_0_o,
    output wire        out2Core_reqServed_1_o,
    output wire        out2Core_hit_0_o,
    output wire        out2Core_hit_1_o,
    output wire        out2Core_hit_2_o,
    output wire        out2Core_hit_3_o,
    output wire [127:0] out2Core_cacheline_0_o,
    output wire [127:0] out2Core_cacheline_1_o,
    output wire [127:0] out2Core_cacheline_2_o,
    output wire [127:0] out2Core_cacheline_3_o,
    output wire        out2Core_writeSuccess_0_o,
    output wire        out2Core_writeSuccess_1_o,
    output wire        out2Core_writeSuccess_2_o,
    output wire        out2Core_writeSuccess_3_o,
    output wire        out2Core_writeSuccess_MIO_o,
    output wire        out2Core_hit_MIO_o,
    output wire        out2Core_reqServed_MIO_o,
    output wire [127:0] out2Core_line_MIO_o,

    // ===== dma_controller_2_core_t outputs (unpacked) =====
    output wire        dma_intOut_o
);

    // ---------------------------------------------------------------
    // Internal flat wires (replace what used to be struct typed wires).
    // Naming: <source>2<dest>_<field>(_<idx>) following the existing
    // BusArbitration / DCache_TOP flat-port convention.
    // ---------------------------------------------------------------

    // Shared buses
    wire [`DATA_BUS_WIDTH_BITS    - 1 : 0] dataBus;
    wire [`ADDRESS_BUS_WIDTH_BITS - 1 : 0] addressBus;

    // icache_2_scheduler_t
    wire [3:0] icache2sched_req;

    // dte_2_icache_t
    wire dte2icache_Mem_Valid;
    wire dte2icache_driveAddrBus;

    // dcache_2_scheduler_t
    wire [3:0]  dcache2sched_req_0;
    wire [3:0]  dcache2sched_req_1;
    wire [3:0]  dcache2sched_req_2;
    wire [3:0]  dcache2sched_req_3;
    wire [14:0] dcache2sched_evictionBufAddr_0;
    wire [14:0] dcache2sched_evictionBufAddr_1;
    wire [14:0] dcache2sched_evictionBufAddr_2;
    wire [14:0] dcache2sched_evictionBufAddr_3;
    wire [3:0]  dcache2sched_req_mio;

    // dte_2_dcache_t
    wire        dte2dcache_mem_valid_0;
    wire        dte2dcache_mem_valid_1;
    wire        dte2dcache_mem_valid_2;
    wire        dte2dcache_mem_valid_3;
    wire [3:0]  dte2dcache_perm2DriveDataBus_eb_0;
    wire [3:0]  dte2dcache_perm2DriveDataBus_eb_1;
    wire [3:0]  dte2dcache_perm2DriveDataBus_eb_2;
    wire [3:0]  dte2dcache_perm2DriveDataBus_eb_3;
    wire        dte2dcache_perm2DriveAddrBus_Ld_0;
    wire        dte2dcache_perm2DriveAddrBus_Ld_1;
    wire        dte2dcache_perm2DriveAddrBus_Ld_2;
    wire        dte2dcache_perm2DriveAddrBus_Ld_3;
    wire        dte2dcache_perm2DriveAddrBus_eb_0;
    wire        dte2dcache_perm2DriveAddrBus_eb_1;
    wire        dte2dcache_perm2DriveAddrBus_eb_2;
    wire        dte2dcache_perm2DriveAddrBus_eb_3;
    wire        dte2dcache_evictionBuf_clr_0;
    wire        dte2dcache_evictionBuf_clr_1;
    wire        dte2dcache_evictionBuf_clr_2;
    wire        dte2dcache_evictionBuf_clr_3;
    wire        dte2dcache_evictionBuf_setCommiting_0;
    wire        dte2dcache_evictionBuf_setCommiting_1;
    wire        dte2dcache_evictionBuf_setCommiting_2;
    wire        dte2dcache_evictionBuf_setCommiting_3;
    wire        dte2dcache_reqServed_mio;
    wire        dte2dcache_perm2DriveAddrBus_mio;
    wire        dte2dcache_perm2DriveDataBus_mio;

    // mem_2_scheduler_t
    wire [7:0]  mem2sched_writeBuf_V;       // numWriteBufsInMem = 8

    // mem_2_dte_t
    wire        mem2dte_mem_Ready;

    // dte_2_mem_t
    wire        dte2mem_ld_req;
    wire        dte2mem_st_req;
    wire [3:0]  dte2mem_permission2DriveBus; // CACHE_LINES_SIZE_BITS / DATA_BUS_WIDTH_BITS = 4

    // dma_controller_2_scheduler_t
    wire [3:0]  dma2sched_dma_req;
    wire [14:0] dma2sched_writeBuf_Address;

    // dte_2_dma_controller_t
    wire [3:0]  dte2dma_permission2DriveDataBus;
    wire        dte2dma_permission2DriveADDRBus;
    wire        dte2dma_commiting;
    wire        dte2dma_writeComplete;
    wire        dte2dma_coreValOnBus;

    // dte_2_ddr5_t
    wire        dte2ddr5_newPowerGateValueFromCore;
    wire        dte2ddr5_driveDataBus;

    // ---------------------------------------------------------------
    // mem_TOP
    // ---------------------------------------------------------------
    mem_TOP mem_unit (
        .clk(clk),
        .rst(rst),
        .address_bus(addressBus),
        .data_bus(dataBus),
        .inFromDte_ld_req(dte2mem_ld_req),
        .inFromDte_st_req(dte2mem_st_req),
        .inFromDte_permission2DriveBus(dte2mem_permission2DriveBus),
        .out2Dte_mem_Ready(mem2dte_mem_Ready),
        .out2Sch_writeBuf_V(mem2sched_writeBuf_V)
    );

    // ---------------------------------------------------------------
    // DCache_TOP (already pure flat-port)
    // ---------------------------------------------------------------
    DCache_TOP dcache_unit (
        .clk(clk),
        .rst(rst),

        .core_ld_addr_0_V_i (core_ld_addr_0_V_i),
        .core_ld_addr_0_i   (core_ld_addr_0_i),
        .core_ld_addr_1_V_i (core_ld_addr_1_V_i),
        .core_ld_addr_1_i   (core_ld_addr_1_i),

        .core_stq_full_0_i  (core_stq_full_0_i),
        .core_stq_full_1_i  (core_stq_full_1_i),
        .core_stq_full_2_i  (core_stq_full_2_i),
        .core_stq_full_3_i  (core_stq_full_3_i),
        .core_stq_empty_0_i (core_stq_empty_0_i),
        .core_stq_empty_1_i (core_stq_empty_1_i),
        .core_stq_empty_2_i (core_stq_empty_2_i),
        .core_stq_empty_3_i (core_stq_empty_3_i),
        .core_stq_addr_0_i  (core_stq_addr_0_i),
        .core_stq_addr_1_i  (core_stq_addr_1_i),
        .core_stq_addr_2_i  (core_stq_addr_2_i),
        .core_stq_addr_3_i  (core_stq_addr_3_i),
        .core_stq_bitvec_0_i(core_stq_bitvec_0_i),
        .core_stq_bitvec_1_i(core_stq_bitvec_1_i),
        .core_stq_bitvec_2_i(core_stq_bitvec_2_i),
        .core_stq_bitvec_3_i(core_stq_bitvec_3_i),
        .core_stq_data_0_i  (core_stq_data_0_i),
        .core_stq_data_1_i  (core_stq_data_1_i),
        .core_stq_data_2_i  (core_stq_data_2_i),
        .core_stq_data_3_i  (core_stq_data_3_i),

        .core_ld_addr_MIO_V_i(core_ld_addr_MIO_V_i),
        .core_ld_addr_MIO_i  (core_ld_addr_MIO_i),

        .core_stq_info_mio_empty_i(core_stq_info_mio_empty_i),
        .core_stq_info_mio_addr_i (core_stq_info_mio_addr_i),
        .core_stq_info_mio_data_i (core_stq_info_mio_data_i),

        .core_memStage_CLR_REQ_0_i  (core_memStage_CLR_REQ_0_i),
        .core_memStage_CLR_REQ_1_i  (core_memStage_CLR_REQ_1_i),
        .core_memStage_CLR_REQ_2_i  (core_memStage_CLR_REQ_2_i),
        .core_memStage_CLR_REQ_3_i  (core_memStage_CLR_REQ_3_i),
        .core_memStage_CLR_REQ_MIO_i(core_memStage_CLR_REQ_MIO_i),

        .dte_mem_valid_0_i(dte2dcache_mem_valid_0),
        .dte_mem_valid_1_i(dte2dcache_mem_valid_1),
        .dte_mem_valid_2_i(dte2dcache_mem_valid_2),
        .dte_mem_valid_3_i(dte2dcache_mem_valid_3),

        .dte_permissionToDriveDataBus_evictionBuf_0_i(dte2dcache_perm2DriveDataBus_eb_0),
        .dte_permissionToDriveDataBus_evictionBuf_1_i(dte2dcache_perm2DriveDataBus_eb_1),
        .dte_permissionToDriveDataBus_evictionBuf_2_i(dte2dcache_perm2DriveDataBus_eb_2),
        .dte_permissionToDriveDataBus_evictionBuf_3_i(dte2dcache_perm2DriveDataBus_eb_3),

        .dte_permissionToDriveAddrBus_Ld_0_i(dte2dcache_perm2DriveAddrBus_Ld_0),
        .dte_permissionToDriveAddrBus_Ld_1_i(dte2dcache_perm2DriveAddrBus_Ld_1),
        .dte_permissionToDriveAddrBus_Ld_2_i(dte2dcache_perm2DriveAddrBus_Ld_2),
        .dte_permissionToDriveAddrBus_Ld_3_i(dte2dcache_perm2DriveAddrBus_Ld_3),

        .dte_permissionToDriveAddrBus_eb_0_i(dte2dcache_perm2DriveAddrBus_eb_0),
        .dte_permissionToDriveAddrBus_eb_1_i(dte2dcache_perm2DriveAddrBus_eb_1),
        .dte_permissionToDriveAddrBus_eb_2_i(dte2dcache_perm2DriveAddrBus_eb_2),
        .dte_permissionToDriveAddrBus_eb_3_i(dte2dcache_perm2DriveAddrBus_eb_3),

        .dte_evictionBuf_clr_0_i(dte2dcache_evictionBuf_clr_0),
        .dte_evictionBuf_clr_1_i(dte2dcache_evictionBuf_clr_1),
        .dte_evictionBuf_clr_2_i(dte2dcache_evictionBuf_clr_2),
        .dte_evictionBuf_clr_3_i(dte2dcache_evictionBuf_clr_3),

        .dte_evictionBuf_setCommiting_0_i(dte2dcache_evictionBuf_setCommiting_0),
        .dte_evictionBuf_setCommiting_1_i(dte2dcache_evictionBuf_setCommiting_1),
        .dte_evictionBuf_setCommiting_2_i(dte2dcache_evictionBuf_setCommiting_2),
        .dte_evictionBuf_setCommiting_3_i(dte2dcache_evictionBuf_setCommiting_3),

        .dte_reqServed_mio_i              (dte2dcache_reqServed_mio),
        .dte_permissionToDriveAddrBus_mio_i(dte2dcache_perm2DriveAddrBus_mio),
        .dte_permission2DriveDataBus_mio_i(dte2dcache_perm2DriveDataBus_mio),

        .dataBus    (dataBus),
        .address_bus(addressBus),

        .out2Core_reqServed_0_o    (out2Core_reqServed_0_o),
        .out2Core_reqServed_1_o    (out2Core_reqServed_1_o),
        .out2Core_hit_0_o          (out2Core_hit_0_o),
        .out2Core_hit_1_o          (out2Core_hit_1_o),
        .out2Core_hit_2_o          (out2Core_hit_2_o),
        .out2Core_hit_3_o          (out2Core_hit_3_o),
        .out2Core_cacheline_0_o    (out2Core_cacheline_0_o),
        .out2Core_cacheline_1_o    (out2Core_cacheline_1_o),
        .out2Core_cacheline_2_o    (out2Core_cacheline_2_o),
        .out2Core_cacheline_3_o    (out2Core_cacheline_3_o),
        .out2Core_writeSuccess_0_o (out2Core_writeSuccess_0_o),
        .out2Core_writeSuccess_1_o (out2Core_writeSuccess_1_o),
        .out2Core_writeSuccess_2_o (out2Core_writeSuccess_2_o),
        .out2Core_writeSuccess_3_o (out2Core_writeSuccess_3_o),
        .out2Core_writeSuccess_MIO_o(out2Core_writeSuccess_MIO_o),
        .out2Core_hit_MIO_o         (out2Core_hit_MIO_o),
        .out2Core_reqServed_MIO_o   (out2Core_reqServed_MIO_o),
        .out2Core_line_MIO_o        (out2Core_line_MIO_o),

        .out2Sch_req_0_o            (dcache2sched_req_0),
        .out2Sch_req_1_o            (dcache2sched_req_1),
        .out2Sch_req_2_o            (dcache2sched_req_2),
        .out2Sch_req_3_o            (dcache2sched_req_3),
        .out2Sch_evictionBufAddr_0_o(dcache2sched_evictionBufAddr_0),
        .out2Sch_evictionBufAddr_1_o(dcache2sched_evictionBufAddr_1),
        .out2Sch_evictionBufAddr_2_o(dcache2sched_evictionBufAddr_2),
        .out2Sch_evictionBufAddr_3_o(dcache2sched_evictionBufAddr_3),
        .out2Sch_req_mio_o          (dcache2sched_req_mio)
    );

    // ---------------------------------------------------------------
    // ICache (already exposes flat ports)
    // ---------------------------------------------------------------
    ICache icache_unit (
        .clk(clk),
        .rst(rst),
        .icache_en(icache_icache_en_i),
        .p_addr(icache_p_addr_i),
        .v_addr_i(icache_v_addr_i),
        .num_valid_IDM_slots(icache_num_valid_IDM_slots_i),
        .out_hit(icache_hit_o),
        .out_instruction_line(icache_instruction_line_o),
        .Mem_Valid(dte2icache_Mem_Valid),
        .driveAddrBus(dte2icache_driveAddrBus),
        .out_req(icache2sched_req),
        .dataBus(dataBus),
        .addrBus(addressBus)
    );

    // ---------------------------------------------------------------
    // BusArbitration (already exposes flat ports)
    // ---------------------------------------------------------------
    BusArbitration bus_arbitration_unit (
        .clk(clk),
        .rst(rst),

        // icache_2_scheduler_t
        .iCache_2_Sch_req_i(icache2sched_req),

        // dte_2_icache_t
        .dte_out_2_icache_Mem_Valid_o(dte2icache_Mem_Valid),
        .dte_out_2_icache_driveAddrBus_o(dte2icache_driveAddrBus),

        // dcache_2_scheduler_t
        .dCache_2_Sch_req_0_i(dcache2sched_req_0),
        .dCache_2_Sch_req_1_i(dcache2sched_req_1),
        .dCache_2_Sch_req_2_i(dcache2sched_req_2),
        .dCache_2_Sch_req_3_i(dcache2sched_req_3),
        .dCache_2_Sch_evictionBufAddr_0_i(dcache2sched_evictionBufAddr_0),
        .dCache_2_Sch_evictionBufAddr_1_i(dcache2sched_evictionBufAddr_1),
        .dCache_2_Sch_evictionBufAddr_2_i(dcache2sched_evictionBufAddr_2),
        .dCache_2_Sch_evictionBufAddr_3_i(dcache2sched_evictionBufAddr_3),
        .dCache_2_Sch_req_mio_i(dcache2sched_req_mio),

        // dte_2_dcache_t
        .dte_out_2_dcache_mem_valid_0_o(dte2dcache_mem_valid_0),
        .dte_out_2_dcache_mem_valid_1_o(dte2dcache_mem_valid_1),
        .dte_out_2_dcache_mem_valid_2_o(dte2dcache_mem_valid_2),
        .dte_out_2_dcache_mem_valid_3_o(dte2dcache_mem_valid_3),
        .dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_0_o(
            dte2dcache_perm2DriveDataBus_eb_0),
        .dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_1_o(
            dte2dcache_perm2DriveDataBus_eb_1),
        .dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_2_o(
            dte2dcache_perm2DriveDataBus_eb_2),
        .dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_3_o(
            dte2dcache_perm2DriveDataBus_eb_3),
        .dte_out_2_dcache_permissionToDriveAddrBus_Ld_0_o(dte2dcache_perm2DriveAddrBus_Ld_0),
        .dte_out_2_dcache_permissionToDriveAddrBus_Ld_1_o(dte2dcache_perm2DriveAddrBus_Ld_1),
        .dte_out_2_dcache_permissionToDriveAddrBus_Ld_2_o(dte2dcache_perm2DriveAddrBus_Ld_2),
        .dte_out_2_dcache_permissionToDriveAddrBus_Ld_3_o(dte2dcache_perm2DriveAddrBus_Ld_3),
        .dte_out_2_dcache_permissionToDriveAddrBus_eb_0_o(dte2dcache_perm2DriveAddrBus_eb_0),
        .dte_out_2_dcache_permissionToDriveAddrBus_eb_1_o(dte2dcache_perm2DriveAddrBus_eb_1),
        .dte_out_2_dcache_permissionToDriveAddrBus_eb_2_o(dte2dcache_perm2DriveAddrBus_eb_2),
        .dte_out_2_dcache_permissionToDriveAddrBus_eb_3_o(dte2dcache_perm2DriveAddrBus_eb_3),
        .dte_out_2_dcache_evictionBuf_clr_0_o(dte2dcache_evictionBuf_clr_0),
        .dte_out_2_dcache_evictionBuf_clr_1_o(dte2dcache_evictionBuf_clr_1),
        .dte_out_2_dcache_evictionBuf_clr_2_o(dte2dcache_evictionBuf_clr_2),
        .dte_out_2_dcache_evictionBuf_clr_3_o(dte2dcache_evictionBuf_clr_3),
        .dte_out_2_dcache_evictionBuf_setCommiting_0_o(dte2dcache_evictionBuf_setCommiting_0),
        .dte_out_2_dcache_evictionBuf_setCommiting_1_o(dte2dcache_evictionBuf_setCommiting_1),
        .dte_out_2_dcache_evictionBuf_setCommiting_2_o(dte2dcache_evictionBuf_setCommiting_2),
        .dte_out_2_dcache_evictionBuf_setCommiting_3_o(dte2dcache_evictionBuf_setCommiting_3),
        .dte_out_2_dcache_reqServed_mio_o(dte2dcache_reqServed_mio),
        .dte_out_2_dcache_permissionToDriveAddrBus_mio_o(dte2dcache_perm2DriveAddrBus_mio),
        .dte_out_2_dcache_permission2DriveDataBus_mio_o(dte2dcache_perm2DriveDataBus_mio),

        // mem_2_scheduler_t
        .mem_2_Sch_writeBuf_V_i(mem2sched_writeBuf_V),

        // mem_2_dte_t
        .mem_2_dte_mem_Ready_i(mem2dte_mem_Ready),

        // dte_2_mem_t
        .dte_2_mem_ld_req_o(dte2mem_ld_req),
        .dte_2_mem_st_req_o(dte2mem_st_req),
        .dte_2_mem_permission2DriveBus_o(dte2mem_permission2DriveBus),

        // dma_controller_2_scheduler_t
        .dma_2_sch_dma_req_i(dma2sched_dma_req),
        .dma_2_sch_writeBuf_Address_i(dma2sched_writeBuf_Address),

        // dte_2_dma_controller_t
        .dte_2_dma_permission2DriveDataBus_o(dte2dma_permission2DriveDataBus),
        .dte_2_dma_permission2DriveADDRBus_o(dte2dma_permission2DriveADDRBus),
        .dte_2_dma_commiting_o(dte2dma_commiting),
        .dte_2_dma_writeComplete_o(dte2dma_writeComplete),
        .dte_2_dma_coreValOnBus_o(dte2dma_coreValOnBus),

        // dte_2_ddr5_t
        .dte_2_ddr5_newPowerGateValueFromCore_o(dte2ddr5_newPowerGateValueFromCore),
        .dte_2_ddr5_driveDataBus_o(dte2ddr5_driveDataBus)
    );

    // ---------------------------------------------------------------
    // DMA_Controller (already exposes flat ports)
    // ---------------------------------------------------------------
    DMA_Controller dma_controller_unit (
        .clk(clk),
        .rst(rst),
        .dte_permission2DriveDataBus(dte2dma_permission2DriveDataBus),
        .dte_permission2DriveADDRBus(dte2dma_permission2DriveADDRBus),
        .dte_commiting              (dte2dma_commiting),
        .dte_writeComplete          (dte2dma_writeComplete),
        .dte_coreValOnBus           (dte2dma_coreValOnBus),
        .core_intOut                (dma_intOut_o),
        .sch_dma_req                (dma2sched_dma_req),
        .sch_writeBuf_Address       (dma2sched_writeBuf_Address),
        .dataBus                    (dataBus),
        .addrBus                    (addressBus)
    );

    // ---------------------------------------------------------------
    // ddr5
    // ---------------------------------------------------------------
    ddr5 ddr5_unit (
        .clk(clk),
        .rst(rst),
        .newPowerGateValueFromCore_i(dte2ddr5_newPowerGateValueFromCore),
        .driveDataBus_i(dte2ddr5_driveDataBus),
        .dataBus(dataBus),
        .addrBus(addressBus)
    );

endmodule
