// Structural Verilog-2005 port of rtl/DCache/DCache_TOP.sv
//
// Pure wiring: 4x DCache_Block, 1x DCache_Arbitration, 1x MIO_Block. Slices
// flat-bus inputs out by field offsets defined in DCache_common_define.vh.

`include "STDCell_Macros.vh"
`include "DCache_common_define.vh"

module DCache_TOP (
    input  wire                                       clk,
    input  wire                                       rst,
    input  wire [`C2D_W                     - 1 : 0]  inFromCore_i,
    output wire [`D2C_W                     - 1 : 0]  out2Core_o,
    input  wire [`DTE_W                     - 1 : 0]  inFromDTE_i,
    output wire [`D2S_W                     - 1 : 0]  out2Sch_o,
    inout  wire [`DATA_BUS_WIDTH_BITS       - 1 : 0]  dataBus,
    inout  wire [`ADDRESS_BUS_WIDTH_BITS    - 1 : 0]  address_bus
);

    //==================================================================
    // dte_2_dcache_t per-block field views
    //   Each block PB(i): mem_valid, perm_data[3:0], perm_addr_Ld,
    //                     perm_addr_eb, eb_clr, eb_setCommiting (9 bits)
    //==================================================================
    wire [3:0] dte_mem_valid;
    wire [3:0] dte_perm_addr_Ld;
    wire [3:0] dte_perm_addr_eb;
    wire [3:0] dte_eb_clr;
    wire [3:0] dte_eb_setCommiting;
    wire [3:0] dte_perm_data_block0;
    wire [3:0] dte_perm_data_block1;
    wire [3:0] dte_perm_data_block2;
    wire [3:0] dte_perm_data_block3;
    wire       dte_reqServed_mio;
    wire       dte_perm_addr_mio;
    wire       dte_perm_data_mio;

    assign dte_mem_valid[0]      = inFromDTE_i[`DTE_PB_LB(0) + `DTE_PB_MEM_VALID];
    assign dte_mem_valid[1]      = inFromDTE_i[`DTE_PB_LB(1) + `DTE_PB_MEM_VALID];
    assign dte_mem_valid[2]      = inFromDTE_i[`DTE_PB_LB(2) + `DTE_PB_MEM_VALID];
    assign dte_mem_valid[3]      = inFromDTE_i[`DTE_PB_LB(3) + `DTE_PB_MEM_VALID];

    assign dte_perm_addr_Ld[0]   = inFromDTE_i[`DTE_PB_LB(0) + `DTE_PB_PERM_ADDR_LD];
    assign dte_perm_addr_Ld[1]   = inFromDTE_i[`DTE_PB_LB(1) + `DTE_PB_PERM_ADDR_LD];
    assign dte_perm_addr_Ld[2]   = inFromDTE_i[`DTE_PB_LB(2) + `DTE_PB_PERM_ADDR_LD];
    assign dte_perm_addr_Ld[3]   = inFromDTE_i[`DTE_PB_LB(3) + `DTE_PB_PERM_ADDR_LD];

    assign dte_perm_addr_eb[0]   = inFromDTE_i[`DTE_PB_LB(0) + `DTE_PB_PERM_ADDR_EB];
    assign dte_perm_addr_eb[1]   = inFromDTE_i[`DTE_PB_LB(1) + `DTE_PB_PERM_ADDR_EB];
    assign dte_perm_addr_eb[2]   = inFromDTE_i[`DTE_PB_LB(2) + `DTE_PB_PERM_ADDR_EB];
    assign dte_perm_addr_eb[3]   = inFromDTE_i[`DTE_PB_LB(3) + `DTE_PB_PERM_ADDR_EB];

    assign dte_eb_clr[0]         = inFromDTE_i[`DTE_PB_LB(0) + `DTE_PB_EB_CLR];
    assign dte_eb_clr[1]         = inFromDTE_i[`DTE_PB_LB(1) + `DTE_PB_EB_CLR];
    assign dte_eb_clr[2]         = inFromDTE_i[`DTE_PB_LB(2) + `DTE_PB_EB_CLR];
    assign dte_eb_clr[3]         = inFromDTE_i[`DTE_PB_LB(3) + `DTE_PB_EB_CLR];

    assign dte_eb_setCommiting[0]= inFromDTE_i[`DTE_PB_LB(0) + `DTE_PB_EB_SETCOMMITING];
    assign dte_eb_setCommiting[1]= inFromDTE_i[`DTE_PB_LB(1) + `DTE_PB_EB_SETCOMMITING];
    assign dte_eb_setCommiting[2]= inFromDTE_i[`DTE_PB_LB(2) + `DTE_PB_EB_SETCOMMITING];
    assign dte_eb_setCommiting[3]= inFromDTE_i[`DTE_PB_LB(3) + `DTE_PB_EB_SETCOMMITING];

    assign dte_perm_data_block0  = inFromDTE_i[`DTE_PB_LB(0) + `DTE_PB_PERM_DATA_UB :
                                                `DTE_PB_LB(0) + `DTE_PB_PERM_DATA_LB];
    assign dte_perm_data_block1  = inFromDTE_i[`DTE_PB_LB(1) + `DTE_PB_PERM_DATA_UB :
                                                `DTE_PB_LB(1) + `DTE_PB_PERM_DATA_LB];
    assign dte_perm_data_block2  = inFromDTE_i[`DTE_PB_LB(2) + `DTE_PB_PERM_DATA_UB :
                                                `DTE_PB_LB(2) + `DTE_PB_PERM_DATA_LB];
    assign dte_perm_data_block3  = inFromDTE_i[`DTE_PB_LB(3) + `DTE_PB_PERM_DATA_UB :
                                                `DTE_PB_LB(3) + `DTE_PB_PERM_DATA_LB];

    assign dte_reqServed_mio = inFromDTE_i[`DTE_REQSERVED_MIO];
    assign dte_perm_addr_mio = inFromDTE_i[`DTE_PERM_ADDR_MIO];
    assign dte_perm_data_mio = inFromDTE_i[`DTE_PERM_DATA_MIO];

    //==================================================================
    // core_2_dcache_t : MIO-related slices (the rest goes straight to arb)
    //==================================================================
    wire                       core_ld_mio_V;
    wire [`P_ADDR_W - 1 : 0]   core_ld_mio_addr;
    wire [`STQ_W    - 1 : 0]   core_stq_mio;
    wire                       core_clr_req_mio;
    assign core_ld_mio_V    = inFromCore_i[`C2D_LD_MIO_V];
    assign core_ld_mio_addr = inFromCore_i[`C2D_LD_MIO_UB:`C2D_LD_MIO_LB];
    assign core_stq_mio     = inFromCore_i[`C2D_STQ_MIO_UB:`C2D_STQ_MIO_LB];
    assign core_clr_req_mio = inFromCore_i[`C2D_CLR_REQ_MIO];

    //==================================================================
    // Arbitration
    //==================================================================
    wire                                          arb_reqServed_0;
    wire                                          arb_reqServed_1;
    wire [`DCACHE_NUM_BLOCKS*`BREQ_W      - 1 : 0] req_2_blocks;
    wire [`DCACHE_NUM_BLOCKS              - 1 : 0] arb_st_override;
    wire [`DCACHE_NUM_BLOCKS              - 1 : 0] arb_writeSuccess;
    wire [`DCACHE_NUM_BLOCKS              - 1 : 0] block_hit;

    DCache_Arbitration dcache_arbitration (
        .clk_i(clk),
        .rst(rst),
        .core_i(inFromCore_i),
        .block_hit_i(block_hit),
        .reqServed_0_o(arb_reqServed_0),
        .reqServed_1_o(arb_reqServed_1),
        .reqs_2_blocks_o(req_2_blocks),
        .st_override_o(arb_st_override),
        .writeSuccess_o(arb_writeSuccess)
    );

    //==================================================================
    // 4x DCache_Block
    //==================================================================
    wire [`DCBLK_OUT_W - 1 : 0] block_outs_0;
    wire [`DCBLK_OUT_W - 1 : 0] block_outs_1;
    wire [`DCBLK_OUT_W - 1 : 0] block_outs_2;
    wire [`DCBLK_OUT_W - 1 : 0] block_outs_3;

    DCache_Block block_0 (
        .clk_i(clk),
        .rst_i(rst),
        .block_req_i(req_2_blocks[`BREQ_W*1-1:`BREQ_W*0]),
        .mem_Valid_FromDte_i(dte_mem_valid[0]),
        .evictionBuf_clr_FromDTE_i(dte_eb_clr[0]),
        .evictionBuf_setCommiting_FromDTE_i(dte_eb_setCommiting[0]),
        .permissionToDriveDataBus_evictionBuf(dte_perm_data_block0),
        .permissionToDriveAddrBus_Ld(dte_perm_addr_Ld[0]),
        .permissionToDriveAddrBus_eb(dte_perm_addr_eb[0]),
        .st_override_for_sch_req(arb_st_override[0]),
        .dataBus(dataBus),
        .address_bus(address_bus),
        .outputs_o(block_outs_0)
    );
    DCache_Block block_1 (
        .clk_i(clk),
        .rst_i(rst),
        .block_req_i(req_2_blocks[`BREQ_W*2-1:`BREQ_W*1]),
        .mem_Valid_FromDte_i(dte_mem_valid[1]),
        .evictionBuf_clr_FromDTE_i(dte_eb_clr[1]),
        .evictionBuf_setCommiting_FromDTE_i(dte_eb_setCommiting[1]),
        .permissionToDriveDataBus_evictionBuf(dte_perm_data_block1),
        .permissionToDriveAddrBus_Ld(dte_perm_addr_Ld[1]),
        .permissionToDriveAddrBus_eb(dte_perm_addr_eb[1]),
        .st_override_for_sch_req(arb_st_override[1]),
        .dataBus(dataBus),
        .address_bus(address_bus),
        .outputs_o(block_outs_1)
    );
    DCache_Block block_2 (
        .clk_i(clk),
        .rst_i(rst),
        .block_req_i(req_2_blocks[`BREQ_W*3-1:`BREQ_W*2]),
        .mem_Valid_FromDte_i(dte_mem_valid[2]),
        .evictionBuf_clr_FromDTE_i(dte_eb_clr[2]),
        .evictionBuf_setCommiting_FromDTE_i(dte_eb_setCommiting[2]),
        .permissionToDriveDataBus_evictionBuf(dte_perm_data_block2),
        .permissionToDriveAddrBus_Ld(dte_perm_addr_Ld[2]),
        .permissionToDriveAddrBus_eb(dte_perm_addr_eb[2]),
        .st_override_for_sch_req(arb_st_override[2]),
        .dataBus(dataBus),
        .address_bus(address_bus),
        .outputs_o(block_outs_2)
    );
    DCache_Block block_3 (
        .clk_i(clk),
        .rst_i(rst),
        .block_req_i(req_2_blocks[`BREQ_W*4-1:`BREQ_W*3]),
        .mem_Valid_FromDte_i(dte_mem_valid[3]),
        .evictionBuf_clr_FromDTE_i(dte_eb_clr[3]),
        .evictionBuf_setCommiting_FromDTE_i(dte_eb_setCommiting[3]),
        .permissionToDriveDataBus_evictionBuf(dte_perm_data_block3),
        .permissionToDriveAddrBus_Ld(dte_perm_addr_Ld[3]),
        .permissionToDriveAddrBus_eb(dte_perm_addr_eb[3]),
        .st_override_for_sch_req(arb_st_override[3]),
        .dataBus(dataBus),
        .address_bus(address_bus),
        .outputs_o(block_outs_3)
    );

    //==================================================================
    // MIO Block
    //==================================================================
    wire [`MIO_OUT_W - 1 : 0] mio_outs;

    MIO_Block mio_block_unit (
        .clk(clk),
        .rst(rst),
        .reqServed_FromDTE_i(dte_reqServed_mio),
        .PermissionToDriveAddrBus(dte_perm_addr_mio),
        .permission2DriveDataBus(dte_perm_data_mio),
        .ld_addr_MIO_V(core_ld_mio_V),
        .ld_addr_MIO(core_ld_mio_addr),
        .stq_info_mio(core_stq_mio),
        .memStage_CLR_REQ_MIO(core_clr_req_mio),
        .address_bus(address_bus),
        .dataBus(dataBus),
        .outputs_o(mio_outs)
    );

    //==================================================================
    // Block-level field extracts (for hit feedback to arbitration and
    // for output assembly).
    //==================================================================
    wire [`CL_W - 1 : 0] block_line_0;
    wire [`CL_W - 1 : 0] block_line_1;
    wire [`CL_W - 1 : 0] block_line_2;
    wire [`CL_W - 1 : 0] block_line_3;
    wire        block_hit_0;
    wire        block_hit_1;
    wire        block_hit_2;
    wire        block_hit_3;
    wire [`P_ADDR_W - 1 : 0] block_eb_addr_0;
    wire [`P_ADDR_W - 1 : 0] block_eb_addr_1;
    wire [`P_ADDR_W - 1 : 0] block_eb_addr_2;
    wire [`P_ADDR_W - 1 : 0] block_eb_addr_3;
    wire [`REQ_2_SCH_W - 1 : 0] block_req_0;
    wire [`REQ_2_SCH_W - 1 : 0] block_req_1;
    wire [`REQ_2_SCH_W - 1 : 0] block_req_2;
    wire [`REQ_2_SCH_W - 1 : 0] block_req_3;

    assign block_line_0     = block_outs_0[`DCBLK_OUT_LINE_UB:`DCBLK_OUT_LINE_LB];
    assign block_line_1     = block_outs_1[`DCBLK_OUT_LINE_UB:`DCBLK_OUT_LINE_LB];
    assign block_line_2     = block_outs_2[`DCBLK_OUT_LINE_UB:`DCBLK_OUT_LINE_LB];
    assign block_line_3     = block_outs_3[`DCBLK_OUT_LINE_UB:`DCBLK_OUT_LINE_LB];
    assign block_hit_0      = block_outs_0[`DCBLK_OUT_HIT];
    assign block_hit_1      = block_outs_1[`DCBLK_OUT_HIT];
    assign block_hit_2      = block_outs_2[`DCBLK_OUT_HIT];
    assign block_hit_3      = block_outs_3[`DCBLK_OUT_HIT];
    assign block_eb_addr_0  = block_outs_0[`DCBLK_OUT_EBADDR_UB:`DCBLK_OUT_EBADDR_LB];
    assign block_eb_addr_1  = block_outs_1[`DCBLK_OUT_EBADDR_UB:`DCBLK_OUT_EBADDR_LB];
    assign block_eb_addr_2  = block_outs_2[`DCBLK_OUT_EBADDR_UB:`DCBLK_OUT_EBADDR_LB];
    assign block_eb_addr_3  = block_outs_3[`DCBLK_OUT_EBADDR_UB:`DCBLK_OUT_EBADDR_LB];
    assign block_req_0      = block_outs_0[`DCBLK_OUT_REQ_UB:`DCBLK_OUT_REQ_LB];
    assign block_req_1      = block_outs_1[`DCBLK_OUT_REQ_UB:`DCBLK_OUT_REQ_LB];
    assign block_req_2      = block_outs_2[`DCBLK_OUT_REQ_UB:`DCBLK_OUT_REQ_LB];
    assign block_req_3      = block_outs_3[`DCBLK_OUT_REQ_UB:`DCBLK_OUT_REQ_LB];

    //   block_hit feeds back to arbitration
    assign block_hit = {block_hit_3, block_hit_2, block_hit_1, block_hit_0};

    //==================================================================
    // MIO field views
    //==================================================================
    wire        mio_writeSuccess;
    wire        mio_hit;
    wire [`CL_W - 1 : 0] mio_line;
    wire [`REQ_2_SCH_W - 1 : 0] mio_req;
    wire        mio_reqServed;
    assign mio_writeSuccess = mio_outs[`MIO_OUT_WRSUCCESS];
    assign mio_hit          = mio_outs[`MIO_OUT_HIT];
    assign mio_line         = mio_outs[`MIO_OUT_LINE_UB:`MIO_OUT_LINE_LB];
    assign mio_req          = mio_outs[`MIO_OUT_REQ_UB:`MIO_OUT_REQ_LB];
    assign mio_reqServed    = mio_outs[`MIO_OUT_REQSERVED];

    //==================================================================
    // out2Core_o assembly
    //==================================================================
    assign out2Core_o[`D2C_REQSERVED_0]                      = arb_reqServed_0;
    assign out2Core_o[`D2C_REQSERVED_1]                      = arb_reqServed_1;
    assign out2Core_o[`D2C_HIT_LB + 0]                       = block_hit_0;
    assign out2Core_o[`D2C_HIT_LB + 1]                       = block_hit_1;
    assign out2Core_o[`D2C_HIT_LB + 2]                       = block_hit_2;
    assign out2Core_o[`D2C_HIT_LB + 3]                       = block_hit_3;
    assign out2Core_o[`D2C_LINE_UB(0):`D2C_LINE_LB(0)]       = block_line_0;
    assign out2Core_o[`D2C_LINE_UB(1):`D2C_LINE_LB(1)]       = block_line_1;
    assign out2Core_o[`D2C_LINE_UB(2):`D2C_LINE_LB(2)]       = block_line_2;
    assign out2Core_o[`D2C_LINE_UB(3):`D2C_LINE_LB(3)]       = block_line_3;
    assign out2Core_o[`D2C_WRSUCC_UB:`D2C_WRSUCC_LB]         = arb_writeSuccess;
    assign out2Core_o[`D2C_WRSUCC_MIO]                       = mio_writeSuccess;
    assign out2Core_o[`D2C_HIT_MIO]                          = mio_hit;
    assign out2Core_o[`D2C_REQSERVED_MIO]                    = mio_reqServed;
    assign out2Core_o[`D2C_LINE_MIO_UB:`D2C_LINE_MIO_LB]     = mio_line;

    //==================================================================
    // out2Sch_o assembly
    //==================================================================
    assign out2Sch_o[`D2S_PB_LB(0) + `D2S_PB_REQ_UB:    `D2S_PB_LB(0) + `D2S_PB_REQ_LB]    = block_req_0;
    assign out2Sch_o[`D2S_PB_LB(1) + `D2S_PB_REQ_UB:    `D2S_PB_LB(1) + `D2S_PB_REQ_LB]    = block_req_1;
    assign out2Sch_o[`D2S_PB_LB(2) + `D2S_PB_REQ_UB:    `D2S_PB_LB(2) + `D2S_PB_REQ_LB]    = block_req_2;
    assign out2Sch_o[`D2S_PB_LB(3) + `D2S_PB_REQ_UB:    `D2S_PB_LB(3) + `D2S_PB_REQ_LB]    = block_req_3;
    assign out2Sch_o[`D2S_PB_LB(0) + `D2S_PB_EBADDR_UB: `D2S_PB_LB(0) + `D2S_PB_EBADDR_LB] = block_eb_addr_0;
    assign out2Sch_o[`D2S_PB_LB(1) + `D2S_PB_EBADDR_UB: `D2S_PB_LB(1) + `D2S_PB_EBADDR_LB] = block_eb_addr_1;
    assign out2Sch_o[`D2S_PB_LB(2) + `D2S_PB_EBADDR_UB: `D2S_PB_LB(2) + `D2S_PB_EBADDR_LB] = block_eb_addr_2;
    assign out2Sch_o[`D2S_PB_LB(3) + `D2S_PB_EBADDR_UB: `D2S_PB_LB(3) + `D2S_PB_EBADDR_LB] = block_eb_addr_3;
    assign out2Sch_o[`D2S_REQ_MIO_UB:`D2S_REQ_MIO_LB]                                       = mio_req;

endmodule
