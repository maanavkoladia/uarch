import common_pkg::*;
import interconnect_pkg::*;

module Everywhere_TOP (
    input wire clk,
    input wire rst,
    input core_2_icache_t core2icache_i,
    output icache_2_core_t icache2core_o,
    input core_2_dcache_t core2dcache_i,
    output dcache_2_core_t dcache2core_o,
    output dma_controller_2_core_t dma2core_o
);

    icache_2_scheduler_t                                          icache2sched;
    dte_2_icache_t                                                dte2icache;

    dcache_2_scheduler_t                                          dcache2sched;
    dte_2_dcache_t                                                dte2dcache;

    mem_2_scheduler_t                                             mem2sched;
    mem_2_dte_t                                                   mem2dte;
    dte_2_mem_t                                                   dte2mem;

    dma_controller_2_scheduler_t                                  dma2sched;
    dte_2_dma_controller_t                                        dte2dma;

    dte_2_ddr5_t                                                  dte2ddr5;

    wire                         [   DATA_BUS_WIDTH_BITS - 1 : 0] dataBus;
    wire                         [ADDRESS_BUS_WIDTH_BITS - 1 : 0] addressBus;

    //mem
    // mem_TOP mem_unit (
    //    .clk(clk),
    //    .rst(rst),
    //    .address_bus(addressBus),
    //    .data_bus(dataBus),
    //    .inFromDte(dte2mem),
    //    .out2Dte(mem2dte),
    //    .out2Sch(mem2sched)
    // );

    mem_TOP mem_unit (
        .clk(clk),
        .rst(rst),
        .address_bus(addressBus),
        .data_bus(dataBus),
        .inFromDte_ld_req(dte2mem.ld_req),
        .inFromDte_st_req(dte2mem.st_req),
        .inFromDte_permission2DriveBus(dte2mem.permission2DriveBus),
        .out2Dte_mem_Ready(mem2dte.mem_Ready),
        .out2Sch_writeBuf_V(mem2sched.writeBuf_V)
    );

    //dcache
    DCache_TOP dcache_unit (
        .clk(clk),
        .rst(rst),
        .inFromCore_i(core2dcache_i),
        .out2Core_o(dcache2core_o),
        .inFromDTE_i(dte2dcache),
        .out2Sch_o(dcache2sched),
        .address_bus(addressBus),
        .dataBus(dataBus)
    );

    //icache
    // ICache icache_unit (
    //     .clk(clk),
    //     .rst(rst),
    //     .inFromCore_i(core2icache_i),
    //     .out2Core_o(icache2core_o),
    //     .inFromDte_i(dte2icache),
    //     .out2Sch_o(icache2sched),
    //     .addrBus(addressBus),
    //     .dataBus(dataBus)
    // );

    uintCL_t icache_instruction_line_flat;

    always_comb begin
        for(int i = 0; i < CACHE_LINES_SIZE_B; i++)begin
            icache2core_o.instruction_line[i] = icache_instruction_line_flat[i*8 +: 8];
        end
    end

    ICache icache_unit (
        .clk(clk),
        .rst(rst),
        .icache_en(core2icache_i.icache_en),
        .p_addr(core2icache_i.p_addr),
        .v_addr_i(core2icache_i.v_addr_i),
        .num_valid_IDM_slots(core2icache_i.num_valid_IDM_slots),
        .out_hit(icache2core_o.hit),
        .out_instruction_line(icache_instruction_line_flat),
        .Mem_Valid(dte2icache.Mem_Valid),
        .driveAddrBus(dte2icache.driveAddrBus),
        .out_req(icache2sched.req),
        .dataBus(dataBus),
        .addrBus(addressBus)
    );

    //busarb
    BusArbitration bus_arbitration_unit (
        .clk                                                       (clk),
        .rst                                                       (rst),

        // icache_2_scheduler_t
        .iCache_2_Sch_req_i                                        (icache2sched.req),

        // dte_2_icache_t
        .dte_out_2_icache_Mem_Valid_o                              (dte2icache.Mem_Valid),
        .dte_out_2_icache_driveAddrBus_o                           (dte2icache.driveAddrBus),

        // dcache_2_scheduler_t
        .dCache_2_Sch_req_0_i                                      (dcache2sched.req[0]),
        .dCache_2_Sch_req_1_i                                      (dcache2sched.req[1]),
        .dCache_2_Sch_req_2_i                                      (dcache2sched.req[2]),
        .dCache_2_Sch_req_3_i                                      (dcache2sched.req[3]),
        .dCache_2_Sch_evictionBufAddr_0_i                          (dcache2sched.evictionBufAddr[0]),
        .dCache_2_Sch_evictionBufAddr_1_i                          (dcache2sched.evictionBufAddr[1]),
        .dCache_2_Sch_evictionBufAddr_2_i                          (dcache2sched.evictionBufAddr[2]),
        .dCache_2_Sch_evictionBufAddr_3_i                          (dcache2sched.evictionBufAddr[3]),
        .dCache_2_Sch_req_mio_i                                    (dcache2sched.req_mio),

        // dte_2_dcache_t
        .dte_out_2_dcache_mem_valid_0_o                            (dte2dcache.mem_valid[0]),
        .dte_out_2_dcache_mem_valid_1_o                            (dte2dcache.mem_valid[1]),
        .dte_out_2_dcache_mem_valid_2_o                            (dte2dcache.mem_valid[2]),
        .dte_out_2_dcache_mem_valid_3_o                            (dte2dcache.mem_valid[3]),
        .dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_0_o ({dte2dcache.permissionToDriveDataBus_evictionBuf[0][3],
                                                                      dte2dcache.permissionToDriveDataBus_evictionBuf[0][2],
                                                                      dte2dcache.permissionToDriveDataBus_evictionBuf[0][1],
                                                                      dte2dcache.permissionToDriveDataBus_evictionBuf[0][0]}),
        .dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_1_o ({dte2dcache.permissionToDriveDataBus_evictionBuf[1][3],
                                                                      dte2dcache.permissionToDriveDataBus_evictionBuf[1][2],
                                                                      dte2dcache.permissionToDriveDataBus_evictionBuf[1][1],
                                                                      dte2dcache.permissionToDriveDataBus_evictionBuf[1][0]}),
        .dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_2_o ({dte2dcache.permissionToDriveDataBus_evictionBuf[2][3],
                                                                      dte2dcache.permissionToDriveDataBus_evictionBuf[2][2],
                                                                      dte2dcache.permissionToDriveDataBus_evictionBuf[2][1],
                                                                      dte2dcache.permissionToDriveDataBus_evictionBuf[2][0]}),
        .dte_out_2_dcache_permissionToDriveDataBus_evictionBuf_3_o ({dte2dcache.permissionToDriveDataBus_evictionBuf[3][3],
                                                                      dte2dcache.permissionToDriveDataBus_evictionBuf[3][2],
                                                                      dte2dcache.permissionToDriveDataBus_evictionBuf[3][1],
                                                                      dte2dcache.permissionToDriveDataBus_evictionBuf[3][0]}),
        .dte_out_2_dcache_permissionToDriveAddrBus_Ld_0_o          (dte2dcache.permissionToDriveAddrBus_Ld[0]),
        .dte_out_2_dcache_permissionToDriveAddrBus_Ld_1_o          (dte2dcache.permissionToDriveAddrBus_Ld[1]),
        .dte_out_2_dcache_permissionToDriveAddrBus_Ld_2_o          (dte2dcache.permissionToDriveAddrBus_Ld[2]),
        .dte_out_2_dcache_permissionToDriveAddrBus_Ld_3_o          (dte2dcache.permissionToDriveAddrBus_Ld[3]),
        .dte_out_2_dcache_permissionToDriveAddrBus_eb_0_o          (dte2dcache.permissionToDriveAddrBus_eb[0]),
        .dte_out_2_dcache_permissionToDriveAddrBus_eb_1_o          (dte2dcache.permissionToDriveAddrBus_eb[1]),
        .dte_out_2_dcache_permissionToDriveAddrBus_eb_2_o          (dte2dcache.permissionToDriveAddrBus_eb[2]),
        .dte_out_2_dcache_permissionToDriveAddrBus_eb_3_o          (dte2dcache.permissionToDriveAddrBus_eb[3]),
        .dte_out_2_dcache_evictionBuf_clr_0_o                      (dte2dcache.evictionBuf_clr[0]),
        .dte_out_2_dcache_evictionBuf_clr_1_o                      (dte2dcache.evictionBuf_clr[1]),
        .dte_out_2_dcache_evictionBuf_clr_2_o                      (dte2dcache.evictionBuf_clr[2]),
        .dte_out_2_dcache_evictionBuf_clr_3_o                      (dte2dcache.evictionBuf_clr[3]),
        .dte_out_2_dcache_evictionBuf_setCommiting_0_o             (dte2dcache.evictionBuf_setCommiting[0]),
        .dte_out_2_dcache_evictionBuf_setCommiting_1_o             (dte2dcache.evictionBuf_setCommiting[1]),
        .dte_out_2_dcache_evictionBuf_setCommiting_2_o             (dte2dcache.evictionBuf_setCommiting[2]),
        .dte_out_2_dcache_evictionBuf_setCommiting_3_o             (dte2dcache.evictionBuf_setCommiting[3]),
        .dte_out_2_dcache_reqServed_mio_o                          (dte2dcache.reqServed_mio),
        .dte_out_2_dcache_permissionToDriveAddrBus_mio_o           (dte2dcache.permissionToDriveAddrBus_mio),
        .dte_out_2_dcache_permission2DriveDataBus_mio_o            (dte2dcache.permission2DriveDataBus_mio),

        // mem_2_scheduler_t
        .mem_2_Sch_writeBuf_V_i                                    (mem2sched.writeBuf_V),

        // mem_2_dte_t
        .mem_2_dte_mem_Ready_i                                     (mem2dte.mem_Ready),

        // dte_2_mem_t
        .dte_2_mem_ld_req_o                                        (dte2mem.ld_req),
        .dte_2_mem_st_req_o                                        (dte2mem.st_req),
        .dte_2_mem_permission2DriveBus_o                           (dte2mem.permission2DriveBus),

        // dma_controller_2_scheduler_t
        .dma_2_sch_dma_req_i                                       (dma2sched.dma_req),
        .dma_2_sch_writeBuf_Address_i                              (dma2sched.writeBuf_Address),

        // dte_2_dma_controller_t
        .dte_2_dma_permission2DriveDataBus_o                       ({dte2dma.permission2DriveDataBus[3],
                                                                      dte2dma.permission2DriveDataBus[2],
                                                                      dte2dma.permission2DriveDataBus[1],
                                                                      dte2dma.permission2DriveDataBus[0]}),
        .dte_2_dma_permission2DriveADDRBus_o                       (dte2dma.permission2DriveADDRBus),
        .dte_2_dma_commiting_o                                     (dte2dma.commiting),
        .dte_2_dma_writeComplete_o                                 (dte2dma.writeComplete),
        .dte_2_dma_coreValOnBus_o                                  (dte2dma.coreValOnBus),

        // dte_2_ddr5_t
        .dte_2_ddr5_newPowerGateValueFromCore_o                    (dte2ddr5.newPowerGateValueFromCore),
        .dte_2_ddr5_driveDataBus_o                                 (dte2ddr5.driveDataBus)
    );

    //dma
    DMA_Controller dma_controller_unit (
        .clk(clk),
        .rst(rst),
        // dte_2_dma_controller_t flattened
        .dte_permission2DriveDataBus({dte2dma.permission2DriveDataBus[3],
                                      dte2dma.permission2DriveDataBus[2],
                                      dte2dma.permission2DriveDataBus[1],
                                      dte2dma.permission2DriveDataBus[0]}),
        .dte_permission2DriveADDRBus(dte2dma.permission2DriveADDRBus),
        .dte_commiting              (dte2dma.commiting),
        .dte_writeComplete          (dte2dma.writeComplete),
        .dte_coreValOnBus           (dte2dma.coreValOnBus),
        // dma_controller_2_core_t flattened
        .core_intOut                (dma2core_o.intOut),
        // dma_controller_2_scheduler_t flattened
        .sch_dma_req                (dma2sched.dma_req),
        .sch_writeBuf_Address       (dma2sched.writeBuf_Address),
        .dataBus                    (dataBus),
        .addrBus                    (addressBus)
    );

    //ddr5
    //ddr5 ddr5_unit (
    //    .clk(clk),
    //    .rst(rst),
    //    .inFromDTE_i(dte2ddr5),
    //    .dataBus(dataBus),
    //    .addrBus(addressBus)

    //);

    ddr5 ddr5_unit (
        .clk(clk),
        .rst(rst),
        .newPowerGateValueFromCore_i(dte2ddr5.newPowerGateValueFromCore),
        .driveDataBus_i(dte2ddr5.driveDataBus),
        .dataBus(dataBus),
        .addrBus(addressBus)
    );

endmodule
