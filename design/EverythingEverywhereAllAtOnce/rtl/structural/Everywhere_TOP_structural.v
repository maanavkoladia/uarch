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
    //mem_TOP mem_unit (
    //    .clk(clk),
    //    .rst(rst),
    //    .address_bus(addressBus),
    //    .data_bus(dataBus),
    //    .inFromDte(dte2mem),
    //    .out2Dte(mem2dte),
    //    .out2Sch(mem2sched)
    //);

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
    // DCache_TOP dcache_unit (
    //     .clk(clk),
    //     .rst(rst),
    //     .inFromCore_i(core2dcache_i),
    //     .out2Core_o(dcache2core_o),
    //     .inFromDTE_i(dte2dcache),
    //     .out2Sch_o(dcache2sched),
    //     .address_bus(addressBus),
    //     .dataBus(dataBus)
    // );
    wire [`C2D_W - 1 : 0]  core2dcache_i_unrolled;
    wire [`D2C_W - 1 : 0]  dcache2core_o_unrolled;
    wire [`DTE_W - 1 : 0]  dte2dcache_unrolled;
    wire [`D2S_W - 1 : 0]  dcache2sched_unrolled;

    DCache_TOP dcache_unit (
        .clk(clk),
        .rst(rst),
        .inFromCore_i(core2dcache_i_unrolled),
        .out2Core_o(dcache2core_o_unrolled),
        .inFromDTE_i(dte2dcache_unrolled),
        .out2Sch_o(dcache2sched_unrolled),
        .dataBus(dataBus),
        .address_bus(addressBus)
    );

    //icache
    ICache icache_unit (
        .clk(clk),
        .rst(rst),
        .inFromCore_i(core2icache_i),
        .out2Core_o(icache2core_o),
        .inFromDte_i(dte2icache),
        .out2Sch_o(icache2sched),
        .addrBus(addressBus),
        .dataBus(dataBus)
    );

    //busarb
    BusArbitration bus_arbitration_unit (
        .clk(clk),
        .rst(rst),
        .iCache_2_Sch_i(icache2sched),
        .dte_out_2_icache_o(dte2icache),
        .dCache_2_Sch_i(dcache2sched),
        .dte_out_2_dcache_o(dte2dcache),
        .mem_2_Sch_i(mem2sched),
        .mem_2_dte_i(mem2dte),
        .dte_2_mem_o(dte2mem),
        .dma_2_sch_i(dma2sched),
        .dte_2_dma_o(dte2dma),
        .dte_2_ddr5_o(dte2ddr5)
    );

    //dma
    DMA_Controller dma_controller_unit (
        .clk(clk),
        .rst(rst),
        .inFromDTE_i(dte2dma),
        .out2Core_o(dma2core_o),
        .out2Sch_o(dma2sched),
        .dataBus(dataBus),
        .addrBus(addressBus)
    );

    //ddr5
    ddr5 ddr5_unit (
        .clk(clk),
        .rst(rst),
        .inFromDTE_i(dte2ddr5),
        .dataBus(dataBus),
        .addrBus(addressBus)

    );

    assign core2dcache_i_unrolled = {

        core2dcache_i.stq_info_mio.data[15], core2dcache_i.stq_info_mio.data[14], core2dcache_i.stq_info_mio.data[13], core2dcache_i.stq_info_mio.data[12],
        core2dcache_i.stq_info_mio.data[11], core2dcache_i.stq_info_mio.data[10], core2dcache_i.stq_info_mio.data[9],  core2dcache_i.stq_info_mio.data[8],
        core2dcache_i.stq_info_mio.data[7],  core2dcache_i.stq_info_mio.data[6],  core2dcache_i.stq_info_mio.data[5],  core2dcache_i.stq_info_mio.data[4],
        core2dcache_i.stq_info_mio.data[3],  core2dcache_i.stq_info_mio.data[2],  core2dcache_i.stq_info_mio.data[1],  core2dcache_i.stq_info_mio.data[0],
        core2dcache_i.stq_info_mio.bit_vec,
        core2dcache_i.stq_info_mio.address,
        core2dcache_i.stq_info_mio.empty,
        core2dcache_i.stq_info_mio.full,
        core2dcache_i.memStage_CLR_REQ_MIO,
        core2dcache_i.memStage_CLR_REQ[3],
        core2dcache_i.memStage_CLR_REQ[2],
        core2dcache_i.memStage_CLR_REQ[1],
        core2dcache_i.memStage_CLR_REQ[0],
        core2dcache_i.ld_addr_MIO,
        core2dcache_i.ld_addr_MIO_V,
        core2dcache_i.stq_heads[3].data[15], core2dcache_i.stq_heads[3].data[14], core2dcache_i.stq_heads[3].data[13], core2dcache_i.stq_heads[3].data[12],
        core2dcache_i.stq_heads[3].data[11], core2dcache_i.stq_heads[3].data[10], core2dcache_i.stq_heads[3].data[9],  core2dcache_i.stq_heads[3].data[8],
        core2dcache_i.stq_heads[3].data[7],  core2dcache_i.stq_heads[3].data[6],  core2dcache_i.stq_heads[3].data[5],  core2dcache_i.stq_heads[3].data[4],
        core2dcache_i.stq_heads[3].data[3],  core2dcache_i.stq_heads[3].data[2],  core2dcache_i.stq_heads[3].data[1],  core2dcache_i.stq_heads[3].data[0],
        core2dcache_i.stq_heads[3].bit_vec,
        core2dcache_i.stq_heads[3].address,
        core2dcache_i.stq_heads[3].empty,
        core2dcache_i.stq_heads[3].full,
        core2dcache_i.stq_heads[2].data[15], core2dcache_i.stq_heads[2].data[14], core2dcache_i.stq_heads[2].data[13], core2dcache_i.stq_heads[2].data[12],
        core2dcache_i.stq_heads[2].data[11], core2dcache_i.stq_heads[2].data[10], core2dcache_i.stq_heads[2].data[9],  core2dcache_i.stq_heads[2].data[8],
        core2dcache_i.stq_heads[2].data[7],  core2dcache_i.stq_heads[2].data[6],  core2dcache_i.stq_heads[2].data[5],  core2dcache_i.stq_heads[2].data[4],
        core2dcache_i.stq_heads[2].data[3],  core2dcache_i.stq_heads[2].data[2],  core2dcache_i.stq_heads[2].data[1],  core2dcache_i.stq_heads[2].data[0],
        core2dcache_i.stq_heads[2].bit_vec,
        core2dcache_i.stq_heads[2].address,
        core2dcache_i.stq_heads[2].empty,
        core2dcache_i.stq_heads[2].full,
        core2dcache_i.stq_heads[1].data[15], core2dcache_i.stq_heads[1].data[14], core2dcache_i.stq_heads[1].data[13], core2dcache_i.stq_heads[1].data[12],
        core2dcache_i.stq_heads[1].data[11], core2dcache_i.stq_heads[1].data[10], core2dcache_i.stq_heads[1].data[9],  core2dcache_i.stq_heads[1].data[8],
        core2dcache_i.stq_heads[1].data[7],  core2dcache_i.stq_heads[1].data[6],  core2dcache_i.stq_heads[1].data[5],  core2dcache_i.stq_heads[1].data[4],
        core2dcache_i.stq_heads[1].data[3],  core2dcache_i.stq_heads[1].data[2],  core2dcache_i.stq_heads[1].data[1],  core2dcache_i.stq_heads[1].data[0],
        core2dcache_i.stq_heads[1].bit_vec,
        core2dcache_i.stq_heads[1].address,
        core2dcache_i.stq_heads[1].empty,
        core2dcache_i.stq_heads[1].full,
        core2dcache_i.stq_heads[0].data[15], core2dcache_i.stq_heads[0].data[14], core2dcache_i.stq_heads[0].data[13], core2dcache_i.stq_heads[0].data[12],
        core2dcache_i.stq_heads[0].data[11], core2dcache_i.stq_heads[0].data[10], core2dcache_i.stq_heads[0].data[9],  core2dcache_i.stq_heads[0].data[8],
        core2dcache_i.stq_heads[0].data[7],  core2dcache_i.stq_heads[0].data[6],  core2dcache_i.stq_heads[0].data[5],  core2dcache_i.stq_heads[0].data[4],
        core2dcache_i.stq_heads[0].data[3],  core2dcache_i.stq_heads[0].data[2],  core2dcache_i.stq_heads[0].data[1],  core2dcache_i.stq_heads[0].data[0],
        core2dcache_i.stq_heads[0].bit_vec,
        core2dcache_i.stq_heads[0].address,
        core2dcache_i.stq_heads[0].empty,
        core2dcache_i.stq_heads[0].full,
        core2dcache_i.ld_addr_1,
        core2dcache_i.ld_addr_1_V,
        core2dcache_i.ld_addr_0,
        core2dcache_i.ld_addr_0_V
    };

    // ─── dcache_2_core_t ───────────────────────────────────────────────
    // struct field order (first=LSB, last=MSB):
    //   reqServed_0, reqServed_1,
    //   hit[0..3], cacheline[0..3][0..15],
    //   writeSuccess[0..3],
    //   writeSuccess_MIO, hit_MIO, reqServed_MIO,
    //   line_MIO[0..15]

    assign {
        // line_MIO  (last field = MSB)
        dcache2core_o.line_MIO[15], dcache2core_o.line_MIO[14],
        dcache2core_o.line_MIO[13], dcache2core_o.line_MIO[12],
        dcache2core_o.line_MIO[11], dcache2core_o.line_MIO[10],
        dcache2core_o.line_MIO[9],  dcache2core_o.line_MIO[8],
        dcache2core_o.line_MIO[7],  dcache2core_o.line_MIO[6],
        dcache2core_o.line_MIO[5],  dcache2core_o.line_MIO[4],
        dcache2core_o.line_MIO[3],  dcache2core_o.line_MIO[2],
        dcache2core_o.line_MIO[1],  dcache2core_o.line_MIO[0],

        // reqServed_MIO
        dcache2core_o.reqServed_MIO,

        // hit_MIO
        dcache2core_o.hit_MIO,

        // writeSuccess_MIO
        dcache2core_o.writeSuccess_MIO,

        // writeSuccess[3..0]
        dcache2core_o.writeSuccess[3],
        dcache2core_o.writeSuccess[2],
        dcache2core_o.writeSuccess[1],
        dcache2core_o.writeSuccess[0],

        // cacheline[3][15..0] .. cacheline[0][15..0]
        dcache2core_o.cacheline[3][15], dcache2core_o.cacheline[3][14],
        dcache2core_o.cacheline[3][13], dcache2core_o.cacheline[3][12],
        dcache2core_o.cacheline[3][11], dcache2core_o.cacheline[3][10],
        dcache2core_o.cacheline[3][9],  dcache2core_o.cacheline[3][8],
        dcache2core_o.cacheline[3][7],  dcache2core_o.cacheline[3][6],
        dcache2core_o.cacheline[3][5],  dcache2core_o.cacheline[3][4],
        dcache2core_o.cacheline[3][3],  dcache2core_o.cacheline[3][2],
        dcache2core_o.cacheline[3][1],  dcache2core_o.cacheline[3][0],

        dcache2core_o.cacheline[2][15], dcache2core_o.cacheline[2][14],
        dcache2core_o.cacheline[2][13], dcache2core_o.cacheline[2][12],
        dcache2core_o.cacheline[2][11], dcache2core_o.cacheline[2][10],
        dcache2core_o.cacheline[2][9],  dcache2core_o.cacheline[2][8],
        dcache2core_o.cacheline[2][7],  dcache2core_o.cacheline[2][6],
        dcache2core_o.cacheline[2][5],  dcache2core_o.cacheline[2][4],
        dcache2core_o.cacheline[2][3],  dcache2core_o.cacheline[2][2],
        dcache2core_o.cacheline[2][1],  dcache2core_o.cacheline[2][0],

        dcache2core_o.cacheline[1][15], dcache2core_o.cacheline[1][14],
        dcache2core_o.cacheline[1][13], dcache2core_o.cacheline[1][12],
        dcache2core_o.cacheline[1][11], dcache2core_o.cacheline[1][10],
        dcache2core_o.cacheline[1][9],  dcache2core_o.cacheline[1][8],
        dcache2core_o.cacheline[1][7],  dcache2core_o.cacheline[1][6],
        dcache2core_o.cacheline[1][5],  dcache2core_o.cacheline[1][4],
        dcache2core_o.cacheline[1][3],  dcache2core_o.cacheline[1][2],
        dcache2core_o.cacheline[1][1],  dcache2core_o.cacheline[1][0],

        dcache2core_o.cacheline[0][15], dcache2core_o.cacheline[0][14],
        dcache2core_o.cacheline[0][13], dcache2core_o.cacheline[0][12],
        dcache2core_o.cacheline[0][11], dcache2core_o.cacheline[0][10],
        dcache2core_o.cacheline[0][9],  dcache2core_o.cacheline[0][8],
        dcache2core_o.cacheline[0][7],  dcache2core_o.cacheline[0][6],
        dcache2core_o.cacheline[0][5],  dcache2core_o.cacheline[0][4],
        dcache2core_o.cacheline[0][3],  dcache2core_o.cacheline[0][2],
        dcache2core_o.cacheline[0][1],  dcache2core_o.cacheline[0][0],

        // hit[3..0]
        dcache2core_o.hit[3],
        dcache2core_o.hit[2],
        dcache2core_o.hit[1],
        dcache2core_o.hit[0],

        // reqServed_1
        dcache2core_o.reqServed_1,

        // reqServed_0  (first field = LSB)
        dcache2core_o.reqServed_0

    } = dcache2core_o_unrolled;


    // ─── dte_2_dcache_t ────────────────────────────────────────────────
    // struct field order (first=LSB, last=MSB):
    //   mem_valid[0..3],
    //   permissionToDriveDataBus_evictionBuf[0..3][0..3],
    //   permissionToDriveAddrBus_Ld[0..3],
    //   permissionToDriveAddrBus_eb[0..3],
    //   evictionBuf_clr[0..3],
    //   evictionBuf_setCommiting[0..3],
    //   reqServed_mio,
    //   permissionToDriveAddrBus_mio,
    //   permission2DriveDataBus_mio

    assign dte2dcache_unrolled = {
        // permission2DriveDataBus_mio  (last field = MSB)
        dte2dcache.permission2DriveDataBus_mio,

        // permissionToDriveAddrBus_mio
        dte2dcache.permissionToDriveAddrBus_mio,

        // reqServed_mio
        dte2dcache.reqServed_mio,

        dte2dcache.evictionBuf_setCommiting[3],
        dte2dcache.evictionBuf_clr[3],
        dte2dcache.permissionToDriveAddrBus_eb[3],
        dte2dcache.permissionToDriveAddrBus_Ld[3],
        dte2dcache.permissionToDriveDataBus_evictionBuf[3][3],
        dte2dcache.permissionToDriveDataBus_evictionBuf[3][2],
        dte2dcache.permissionToDriveDataBus_evictionBuf[3][1],
        dte2dcache.permissionToDriveDataBus_evictionBuf[3][0],
        dte2dcache.mem_valid[3],

        dte2dcache.evictionBuf_setCommiting[2],
        dte2dcache.evictionBuf_clr[2],
        dte2dcache.permissionToDriveAddrBus_eb[2],
        dte2dcache.permissionToDriveAddrBus_Ld[2],
        dte2dcache.permissionToDriveDataBus_evictionBuf[2][3],
        dte2dcache.permissionToDriveDataBus_evictionBuf[2][2],
        dte2dcache.permissionToDriveDataBus_evictionBuf[2][1],
        dte2dcache.permissionToDriveDataBus_evictionBuf[2][0],
        dte2dcache.mem_valid[2],

        dte2dcache.evictionBuf_setCommiting[1],
        dte2dcache.evictionBuf_clr[1],
        dte2dcache.permissionToDriveAddrBus_eb[1],
        dte2dcache.permissionToDriveAddrBus_Ld[1],
        dte2dcache.permissionToDriveDataBus_evictionBuf[1][3],
        dte2dcache.permissionToDriveDataBus_evictionBuf[1][2],
        dte2dcache.permissionToDriveDataBus_evictionBuf[1][1],
        dte2dcache.permissionToDriveDataBus_evictionBuf[1][0],
        dte2dcache.mem_valid[1],
        
        dte2dcache.evictionBuf_setCommiting[0],
        dte2dcache.evictionBuf_clr[0],
        dte2dcache.permissionToDriveAddrBus_eb[0],
        dte2dcache.permissionToDriveAddrBus_Ld[0],
        dte2dcache.permissionToDriveDataBus_evictionBuf[0][3],
        dte2dcache.permissionToDriveDataBus_evictionBuf[0][2],
        dte2dcache.permissionToDriveDataBus_evictionBuf[0][1],
        dte2dcache.permissionToDriveDataBus_evictionBuf[0][0],
        dte2dcache.mem_valid[0]

    };


    // ─── dcache_2_scheduler_t ──────────────────────────────────────────
    // struct field order (first=LSB, last=MSB):
    //   req[0..3], evictionBufAddr[0..3], req_mio

    assign {
        // req_mio  (last field = MSB)
        dcache2sched.req_mio,

        // req[3..0]  (first field = LSB)
        dcache2sched.evictionBufAddr[3],
        dcache2sched.req[3],

        dcache2sched.evictionBufAddr[2],
        dcache2sched.req[2],

        dcache2sched.evictionBufAddr[1],
        dcache2sched.req[1],

        dcache2sched.evictionBufAddr[0],
        dcache2sched.req[0]
    } = dcache2sched_unrolled;

endmodule
