import common_pkg::*;
import interconnect_pkg::*;
import BusArbitration_common_pkg::*;

module DTE (
    input wire clk,
    input wire rst,

    input reqs_pri_t bestPick_i,
    input logic [$clog2(NUM_DCACHE_PORTS) - 1 : 0] bestPick_bk_id_i,

    output dte_2_icache_t dte_out_2_icache_o,
    output dte_2_dcache_t dte_out_2_dcache_o,
    input  mem_2_dte_t    mem_2_dte_i,
    output dte_2_mem_t    dte_2_mem_o,
    output dte_2_dma_controller_t dte_2_dma_o,
    output dte_2_ddr5_t   dte_2_ddr5_o
);

    // ----------------------------------------------------------------
    // FSM state registers
    // ----------------------------------------------------------------

    DTE_MEM_2_ICache_FSM_State_e dte_mem_2_icache_fsm_state;
    logic [$clog2(DTE_MEM_2_ICACHE_FSM_NUM_STATES)-1:0] dte_mem_2_icache_fsm_state_bits;
    assign dte_mem_2_icache_fsm_state = dte_mem_2_icache_fsm_state_bits;

    DTE_MEM_2_DCache_FSM_State_e dte_mem_2_dcache_fsm_state[NUM_DCACHE_PORTS];
    logic [$clog2(
DTE_MEM_2_DCACHE_FSM_NUM_STATES
)-1:0] dte_mem_2_dcache_fsm_state_bits[NUM_DCACHE_PORTS];
    assign dte_mem_2_dcache_fsm_state = dte_mem_2_dcache_fsm_state_bits;

    DTE_DCache_2_MEM_FSM_State_e dte_dcache_2_mem_fsm_state[NUM_DCACHE_PORTS];
    logic [$clog2(
DTE_DCACHE_2_MEM_FSM_NUM_STATES
)-1:0] dte_dcache_2_mem_fsm_state_bits[NUM_DCACHE_PORTS];
    assign dte_dcache_2_mem_fsm_state = dte_dcache_2_mem_fsm_state_bits;

    DTE_DDR5_2_Core_FSM_State_e dte_ddr5_2_core_fsm_state;
    logic [$clog2(DTE_DDR5_2_CORE_FSM_NUM_STATES)-1:0] dte_ddr5_2_core_fsm_state_bits;
    assign dte_ddr5_2_core_fsm_state = dte_ddr5_2_core_fsm_state_bits;

    DTE_Core_2_DDR5_FSM_State_e dte_core_2_ddr5_fsm_state;
    logic [$clog2(DTE_CORE_2_DDR5_FSM_NUM_STATES)-1:0] dte_core_2_ddr5_fsm_state_bits;
    assign dte_core_2_ddr5_fsm_state = dte_core_2_ddr5_fsm_state_bits;

    DTE_Core_2_DMA_FSM_State_e dte_core_2_dma_fsm_state;
    logic [$clog2(DTE_CORE_2_DMA_FSM_NUM_STATES)-1:0] dte_core_2_dma_fsm_state_bits;
    assign dte_core_2_dma_fsm_state = dte_core_2_dma_fsm_state_bits;

    DTE_DMA_2_MEM_FSM_State_e dte_dma_2_mem_fsm_state;
    logic [$clog2(DTE_DMA_2_MEM_FSM_NUM_STATES)-1:0] dte_dma_2_mem_fsm_state_bits;
    assign dte_dma_2_mem_fsm_state = dte_dma_2_mem_fsm_state_bits;

    // ----------------------------------------------------------------
    // Per-FSM busy outputs  (one signal per FSM/instance)
    // ----------------------------------------------------------------

    bool mem_2_icache_fsmout_busy;

    // FIX 7: one busy wire per bank instance, OR-reduced to a single flag
    bool mem_2_dcache_fsmout_busy_per[NUM_DCACHE_PORTS];
    bool mem_2_dcache_fsmout_busy;
    always_comb begin
        mem_2_dcache_fsmout_busy = '0;
        for (int i = 0; i < NUM_DCACHE_PORTS; i++)
        mem_2_dcache_fsmout_busy |= mem_2_dcache_fsmout_busy_per[i];
    end

    bool dcache_2_mem_fsmout_busy_per[NUM_DCACHE_PORTS];
    bool dcache_2_mem_fsmout_busy;
    always_comb begin
        dcache_2_mem_fsmout_busy = '0;
        for (int i = 0; i < NUM_DCACHE_PORTS; i++)
        dcache_2_mem_fsmout_busy |= dcache_2_mem_fsmout_busy_per[i];
    end

    bool ddr5_2_core_fsmout_busy;
    bool core_2_ddr5_fsmout_busy;
    bool core_2_dma_fsmout_busy;
    bool dma_2_mem_fsmout_busy;

    bool DTE_Busy =
        mem_2_icache_fsmout_busy  ||
        mem_2_dcache_fsmout_busy  ||
        dcache_2_mem_fsmout_busy  ||
        ddr5_2_core_fsmout_busy   ||
        core_2_ddr5_fsmout_busy   ||
        core_2_dma_fsmout_busy    ||
        dma_2_mem_fsmout_busy;

    // ----------------------------------------------------------------
    // FIX 1 & 3 – ld_req / permission2DriveBus: collect per-FSM outputs,
    //             then OR-reduce so there is exactly one driver per signal.
    // ----------------------------------------------------------------

    // ld_req
    bool mem_2_icache_ld_req_fsmOut;
    bool mem_2_dcache_ld_req_fsmOut[NUM_DCACHE_PORTS];

    always_comb begin
        dte_2_mem_o.ld_req = mem_2_icache_ld_req_fsmOut;
        for (int i = 0; i < NUM_DCACHE_PORTS; i++)
        dte_2_mem_o.ld_req |= mem_2_dcache_ld_req_fsmOut[i];
    end

    // permission2DriveBus[0:3]
    bool mem_2_icache_drv_db_fsmOut[4];
    bool mem_2_dcache_drv_db_fsmOut[NUM_DCACHE_PORTS][4];

    always_comb begin
        for (int b = 0; b < 4; b++) begin
            dte_2_mem_o.permission2DriveBus[b] = mem_2_icache_drv_db_fsmOut[b];
            for (int i = 0; i < NUM_DCACHE_PORTS; i++)
            dte_2_mem_o.permission2DriveBus[b] |= mem_2_dcache_drv_db_fsmOut[i][b];
        end
    end

    // ----------------------------------------------------------------
    // FIX 2 – st_req: driven by dcache_2_mem (per-bank) AND dma_2_mem
    // ----------------------------------------------------------------

    bool dcache_2_mem_st_req_fsmOut[NUM_DCACHE_PORTS];
    bool dma_2_mem_st_req_fsmOut;

    always_comb begin
        dte_2_mem_o.st_req = dma_2_mem_st_req_fsmOut;
        for (int i = 0; i < NUM_DCACHE_PORTS; i++)
        dte_2_mem_o.st_req |= dcache_2_mem_st_req_fsmOut[i];
    end

    // ----------------------------------------------------------------
    // FIX 4 – reqServed_mio: driven by ddr5_2_core, core_2_ddr5, core_2_dma
    // ----------------------------------------------------------------

    bool ddr5_2_core_reqServed_fsmOut;
    bool core_2_ddr5_reqServed_fsmOut;
    bool core_2_dma_reqServed_fsmOut;

    assign dte_out_2_dcache_o.reqServed_mio =
        ddr5_2_core_reqServed_fsmOut |
        core_2_ddr5_reqServed_fsmOut |
        core_2_dma_reqServed_fsmOut;

    // ----------------------------------------------------------------
    // FIX 5 – permissionToDriveAddrBus_mio: driven by ddr5_2_core AND core_2_ddr5
    // ----------------------------------------------------------------

    bool ddr5_2_core_driveAddrBus_fsmOut;
    bool core_2_ddr5_driveAddrBus_fsmOut;

    assign dte_out_2_dcache_o.permissionToDriveAddrBus_mio =
        ddr5_2_core_driveAddrBus_fsmOut |
        core_2_ddr5_driveAddrBus_fsmOut;

    // ----------------------------------------------------------------
    // FIX 6 – driveDataBus (DDR5): driven by ddr5_2_core AND core_2_dma
    // ----------------------------------------------------------------

    bool ddr5_2_core_drvDB_fsmOut;
    bool core_2_dma_drvDB_fsmOut;

    assign dte_2_ddr5_o.driveDataBus = ddr5_2_core_drvDB_fsmOut | core_2_dma_drvDB_fsmOut;

    // ================================================================
    // FSM instantiations
    // ================================================================

    // ----------------------------------------------------------------
    // MEM -> ICache
    // ----------------------------------------------------------------

    bool mem_2_icache_req_hit =
        (bestPick_i == ICACHE_HIGH_PRI) ||
        (bestPick_i == ICACHE_LOW_PRI_REQ);

    DTE_MEM_2_ICache_FSM DTE_MEM_2_ICache (
        .clk             (clk),
        .rst             (rst),
        .req_hit_i       (mem_2_icache_req_hit),
        .others_busy_i   (DTE_Busy),
        .mem_ready_i     (mem_2_dte_i.mem_Ready),
        .S_0             (dte_mem_2_icache_fsm_state_bits[0]),
        .S_1             (dte_mem_2_icache_fsm_state_bits[1]),
        .S_2             (dte_mem_2_icache_fsm_state_bits[2]),
        .busy_o          (mem_2_icache_fsmout_busy),
        // FIX 8: mem_valid goes to icache (not dcache)
        .mem_valid_o     (dte_out_2_icache_o.Mem_Valid),
        .ld_req_o        (mem_2_icache_ld_req_fsmOut),
        // FIX 8: icache drives addr bus
        .Drive_Addr_Bus_o(dte_out_2_icache_o.driveAddrBus),
        // FIX 3: route to intermediate wires, OR-reduced above
        .Drv_DB_0_o      (mem_2_icache_drv_db_fsmOut[0]),
        .Drv_DB_1_o      (mem_2_icache_drv_db_fsmOut[1]),
        .Drv_DB_2_o      (mem_2_icache_drv_db_fsmOut[2]),
        .Drv_DB_3_o      (mem_2_icache_drv_db_fsmOut[3])
    );

    // ----------------------------------------------------------------
    // MEM -> DCache (per-bank)
    // ----------------------------------------------------------------

    bool mem_2_dcache_req_hit =
        (bestPick_i == DCACHE_FILL_ST_OVERRIDE) ||
        (bestPick_i == DCACHE_FILL_LD)          ||
        (bestPick_i == DCACHE_FILL_ST);

    bool mem_2_dcache_bk_hit[NUM_DCACHE_PORTS];
    always_comb begin
        for (int i = 0; i < NUM_DCACHE_PORTS; i++) mem_2_dcache_bk_hit[i] = (bestPick_bk_id_i == i);
    end

    generate
        for (genvar i = 0; i < NUM_DCACHE_PORTS; i++) begin : g_mem_2_dcache_bank_fsms

            DTE_MEM_2_DCache_FSM mem_2_dcache_fsm (
                .clk             (clk),
                .rst             (rst),
                .req_hit_i       (mem_2_dcache_req_hit),
                .bank_hit_i      (mem_2_dcache_bk_hit[i]),
                .others_busy_i   (DTE_Busy),
                .mem_ready_i     (mem_2_dte_i.mem_Ready),
                .S_0             (dte_mem_2_dcache_fsm_state_bits[i][0]),
                .S_1             (dte_mem_2_dcache_fsm_state_bits[i][1]),
                .S_2             (dte_mem_2_dcache_fsm_state_bits[i][2]),
                // FIX 7: per-instance busy
                .busy_o          (mem_2_dcache_fsmout_busy_per[i]),
                // FIX 8: mem_valid goes to dcache bank i (not icache)
                .mem_valid_o     (dte_out_2_dcache_o.Mem_Valid[i]),
                // FIX 1: per-instance ld_req wire, OR-reduced above
                .ld_req_o        (mem_2_dcache_ld_req_fsmOut[i]),
                .Drive_Addr_Bus_o(dte_out_2_dcache_o.permissionToDriveAddrBus_Ld[i]),
                // FIX 3: per-instance drive-bus wires, OR-reduced above
                .Drv_DB_0_o      (mem_2_dcache_drv_db_fsmOut[i][0]),
                .Drv_DB_1_o      (mem_2_dcache_drv_db_fsmOut[i][1]),
                .Drv_DB_2_o      (mem_2_dcache_drv_db_fsmOut[i][2]),
                .Drv_DB_3_o      (mem_2_dcache_drv_db_fsmOut[i][3])
            );

        end
    endgenerate

    // ----------------------------------------------------------------
    // DCache -> MEM (per-bank)
    // ----------------------------------------------------------------

    bool dcache_2_mem_req_hit =
        (bestPick_i == DCACHE_EB_BLOCKING_ST_OVERRIDE) ||
        (bestPick_i == DCACHE_EB_BLOCKING_LD)          ||
        (bestPick_i == DCACHE_EB_BLOCK_ST)             ||
        (bestPick_i == DCACHE_EB_WR);

    bool dcache_2_mem_bk_hit[NUM_DCACHE_PORTS];
    always_comb begin
        for (int i = 0; i < NUM_DCACHE_PORTS; i++) dcache_2_mem_bk_hit[i] = (bestPick_bk_id_i == i);
    end

    generate
        for (genvar i = 0; i < NUM_DCACHE_PORTS; i++) begin : g_dcache_2_mem_bank_fsms

            DTE_DCACHE_2_MEM_FSM dcache_2_mem_fsm (
                .clk             (clk),
                .rst             (rst),
                .req_hit_i       (dcache_2_mem_req_hit),
                .bank_hit_i      (dcache_2_mem_bk_hit[i]),
                .others_busy_i   (DTE_Busy),
                .s_0             (dte_dcache_2_mem_fsm_state_bits[i][0]),
                .s_1             (dte_dcache_2_mem_fsm_state_bits[i][1]),
                .s_2             (dte_dcache_2_mem_fsm_state_bits[i][2]),
                // FIX 7: per-instance busy
                .busy_o          (dcache_2_mem_fsmout_busy_per[i]),
                // FIX 2: per-instance st_req wire, OR-reduced above
                .st_req_o        (dcache_2_mem_st_req_fsmOut[i]),
                .drive_addr_bus_o(dte_out_2_dcache_o.permissionToDriveAddrBus_eb[i]),
                .drv_db_0_o      (dte_out_2_dcache_o.permissionToDriveDataBus_evictionBuf[i][0]),
                .drv_db_1_o      (dte_out_2_dcache_o.permissionToDriveDataBus_evictionBuf[i][1]),
                .drv_db_2_o      (dte_out_2_dcache_o.permissionToDriveDataBus_evictionBuf[i][2]),
                .drv_db_3_o      (dte_out_2_dcache_o.permissionToDriveDataBus_evictionBuf[i][3])
            );

        end
    endgenerate

    // ----------------------------------------------------------------
    // DDR5 -> Core
    // ----------------------------------------------------------------

    bool ddr5_2_core_req_hit = (bestPick_i == DCACHE_MIO_LD_FROM_SIMPLE);

    DTE_DDR5_2_Core_FSM ddr5_2_core_fsm (
        .clk             (clk),
        .rst             (rst),
        .req_hit_i       (ddr5_2_core_req_hit),
        .others_busy_i   (DTE_Busy),
        .S_0             (dte_ddr5_2_core_fsm_state_bits[0]),
        .S_1             (dte_ddr5_2_core_fsm_state_bits[1]),
        .busy_o          (ddr5_2_core_fsmout_busy),
        // FIX 4: intermediate wire, OR-reduced above
        .reqServed_o     (ddr5_2_core_reqServed_fsmOut),
        // FIX 5: intermediate wire, OR-reduced above
        .Drive_Addr_Bus_o(ddr5_2_core_driveAddrBus_fsmOut),
        // FIX 6: intermediate wire, OR-reduced above
        .Drv_DB_o        (ddr5_2_core_drvDB_fsmOut)
    );

    // ----------------------------------------------------------------
    // Core -> DDR5
    // ----------------------------------------------------------------

    bool core_2_ddr5_req_hit = (bestPick_i == DCACHE_MIO_WR_SIMPLE);

    DTE_Core_2_DDR5_FSM core_2_ddr5_fsm (
        .clk                        (clk),
        .rst                        (rst),
        .req_hit_i                  (core_2_ddr5_req_hit),
        .others_busy_i              (DTE_Busy),
        .S_0                        (dte_core_2_ddr5_fsm_state_bits[0]),
        .S_1                        (dte_core_2_ddr5_fsm_state_bits[1]),
        .busy_o                     (core_2_ddr5_fsmout_busy),
        // FIX 4: intermediate wire, OR-reduced above
        .reqServed_o                (core_2_ddr5_reqServed_fsmOut),
        // FIX 5: intermediate wire, OR-reduced above
        .Drive_Addr_Bus_o           (core_2_ddr5_driveAddrBus_fsmOut),
        .Drv_DB_o                   (dte_out_2_dcache_o.permission2DriveDataBus_mio),
        .newPowerGateValueFromCore_o(dte_2_ddr5_o.newPowerGateValueFromCore)
    );

    // ----------------------------------------------------------------
    // Core -> DMA
    // ----------------------------------------------------------------

    bool core_2_dma_req_hit = (bestPick_i == DCACHE_MIO_WR_COMPLEX);

    DTE_Core_2_DMA_FSM core_2_dma_fsm (
        .clk             (clk),
        .rst             (rst),
        .req_hit_i       (core_2_dma_req_hit),
        .others_busy_i   (DTE_Busy),
        .S_0             (dte_core_2_dma_fsm_state_bits[0]),
        .S_1             (dte_core_2_dma_fsm_state_bits[1]),
        .busy_o          (core_2_dma_fsmout_busy),
        // FIX 4: intermediate wire, OR-reduced above
        .reqServed_o     (core_2_dma_reqServed_fsmOut),
        .Drive_Addr_Bus_o(dte_out_2_dcache_o.permissionToDriveAddrBus_mio),
        // FIX 6: intermediate wire, OR-reduced above
        .Drv_DB_o        (core_2_dma_drvDB_fsmOut),
        .coreValOnBus_o  (dte_2_dma_o.coreValOnBus)
    );

    // ----------------------------------------------------------------
    // DMA -> MEM
    // ----------------------------------------------------------------

    bool dma_2_mem_req_hit = (bestPick_i == DMA_WRITE_REQ);

    // FIX 9: Drv_DB_* outputs should target permissionToDriveDataBus (not ADDR bus)
    DTE_DMA_2_MEM_FSM dma_2_mem_fsm (
        .clk             (clk),
        .rst             (rst),
        .req_hit_i       (dma_2_mem_req_hit),
        .others_busy_i   (DTE_Busy),
        .S_0             (dte_dma_2_mem_fsm_state_bits[0]),
        .S_1             (dte_dma_2_mem_fsm_state_bits[1]),
        .S_2             (dte_dma_2_mem_fsm_state_bits[2]),
        .busy_o          (dma_2_mem_fsmout_busy),
        // FIX 2: intermediate wire, OR-reduced above
        .st_req_o        (dma_2_mem_st_req_fsmOut),
        .WriteComplete_o (dte_2_dma_o.writeComplete),
        .Drive_Addr_Bus_o(dte_2_dma_o.permission2DriveADDRBus),
        // FIX 9: DMA data-bus permissions are separate from ADDR bus
        .Drv_DB_0_o      (dte_2_dma_o.permission2DriveDataBus[0]),
        .Drv_DB_1_o      (dte_2_dma_o.permission2DriveDataBus[1]),
        .Drv_DB_2_o      (dte_2_dma_o.permission2DriveDataBus[2]),
        .Drv_DB_3_o      (dte_2_dma_o.permission2DriveDataBus[3])
    );

endmodule
