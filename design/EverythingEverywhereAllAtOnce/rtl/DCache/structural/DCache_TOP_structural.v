// Pure Verilog 2005 port of DCache_TOP.
// Reference: rtl/DCache/structural/DCache_TOP.sv
// All struct ports unpacked into individual flat wires.
// Cache lines packed LSB-first (byte i in bits [8i+7:8i]).
// Same module name and same generate-block labels as the .sv reference
// (g_dcache_block, g_hitvec, g_sch_out, g_dcache_top_taps) so internal
// hierarchical paths used for memory loading remain valid.


module DCache_TOP (
    input  wire clk,
    input  wire rst,                                              // active-low

    // ----- core_2_dcache_t inFromCore_i (unpacked) -----
    input  wire        core_ld_addr_0_V_i,
    input  wire [14:0] core_ld_addr_0_i,
    input  wire        core_ld_addr_1_V_i,
    input  wire [14:0] core_ld_addr_1_i,

    input  wire        core_stq_full_0_i,
    input  wire        core_stq_full_1_i,
    input  wire        core_stq_full_2_i,
    input  wire        core_stq_full_3_i,
    input  wire        core_stq_empty_0_i,
    input  wire        core_stq_empty_1_i,
    input  wire        core_stq_empty_2_i,
    input  wire        core_stq_empty_3_i,
    input  wire [14:0] core_stq_addr_0_i,
    input  wire [14:0] core_stq_addr_1_i,
    input  wire [14:0] core_stq_addr_2_i,
    input  wire [14:0] core_stq_addr_3_i,
    input  wire [15:0] core_stq_bitvec_0_i,
    input  wire [15:0] core_stq_bitvec_1_i,
    input  wire [15:0] core_stq_bitvec_2_i,
    input  wire [15:0] core_stq_bitvec_3_i,
    input  wire [127:0] core_stq_data_0_i,
    input  wire [127:0] core_stq_data_1_i,
    input  wire [127:0] core_stq_data_2_i,
    input  wire [127:0] core_stq_data_3_i,

    input  wire        core_ld_addr_MIO_V_i,
    input  wire [14:0] core_ld_addr_MIO_i,

    input  wire        core_stq_info_mio_empty_i,
    input  wire [14:0] core_stq_info_mio_addr_i,
    input  wire [127:0] core_stq_info_mio_data_i,

    input  wire        core_memStage_CLR_REQ_0_i,
    input  wire        core_memStage_CLR_REQ_1_i,
    input  wire        core_memStage_CLR_REQ_2_i,
    input  wire        core_memStage_CLR_REQ_3_i,
    input  wire        core_memStage_CLR_REQ_MIO_i,

    // ----- dte_2_dcache_t inFromDTE_i (unpacked) -----
    input  wire        dte_mem_valid_0_i,
    input  wire        dte_mem_valid_1_i,
    input  wire        dte_mem_valid_2_i,
    input  wire        dte_mem_valid_3_i,

    input  wire [3:0]  dte_permissionToDriveDataBus_evictionBuf_0_i,
    input  wire [3:0]  dte_permissionToDriveDataBus_evictionBuf_1_i,
    input  wire [3:0]  dte_permissionToDriveDataBus_evictionBuf_2_i,
    input  wire [3:0]  dte_permissionToDriveDataBus_evictionBuf_3_i,

    input  wire        dte_permissionToDriveAddrBus_Ld_0_i,
    input  wire        dte_permissionToDriveAddrBus_Ld_1_i,
    input  wire        dte_permissionToDriveAddrBus_Ld_2_i,
    input  wire        dte_permissionToDriveAddrBus_Ld_3_i,

    input  wire        dte_permissionToDriveAddrBus_eb_0_i,
    input  wire        dte_permissionToDriveAddrBus_eb_1_i,
    input  wire        dte_permissionToDriveAddrBus_eb_2_i,
    input  wire        dte_permissionToDriveAddrBus_eb_3_i,

    input  wire        dte_evictionBuf_clr_0_i,
    input  wire        dte_evictionBuf_clr_1_i,
    input  wire        dte_evictionBuf_clr_2_i,
    input  wire        dte_evictionBuf_clr_3_i,

    input  wire        dte_evictionBuf_setCommiting_0_i,
    input  wire        dte_evictionBuf_setCommiting_1_i,
    input  wire        dte_evictionBuf_setCommiting_2_i,
    input  wire        dte_evictionBuf_setCommiting_3_i,

    input  wire        dte_reqServed_mio_i,
    input  wire        dte_permissionToDriveAddrBus_mio_i,
    input  wire        dte_permission2DriveDataBus_mio_i,

    // ----- buses (inout) -----
    inout  wire [`DATA_BUS_WIDTH_BITS    - 1 : 0] dataBus,
    inout  wire [`ADDRESS_BUS_WIDTH_BITS - 1 : 0] address_bus,

    // ----- dcache_2_core_t out2Core_o (unpacked) -----
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

    // ----- dcache_2_scheduler_t out2Sch_o (unpacked) -----
    output wire [3:0]  out2Sch_req_0_o,
    output wire [3:0]  out2Sch_req_1_o,
    output wire [3:0]  out2Sch_req_2_o,
    output wire [3:0]  out2Sch_req_3_o,
    output wire [14:0] out2Sch_evictionBufAddr_0_o,
    output wire [14:0] out2Sch_evictionBufAddr_1_o,
    output wire [14:0] out2Sch_evictionBufAddr_2_o,
    output wire [14:0] out2Sch_evictionBufAddr_3_o,
    output wire [3:0]  out2Sch_req_mio_o
);

    // ---------------------------------------------------------------
    // Local unpacked-array wires that match the DCache_Arbitration ports
    // ---------------------------------------------------------------
    wire        s_arb_stq_full   [`NUM_WB_ST_QS];
    wire        s_arb_stq_empty  [`NUM_WB_ST_QS];
    wire [14:0] s_arb_stq_addr   [`NUM_WB_ST_QS];
    wire [15:0] s_arb_stq_vec    [`NUM_WB_ST_QS];
    wire [127:0] s_arb_stq_data  [`NUM_WB_ST_QS];
    wire        s_arb_clrReq     [`DCACHE_NUM_BLOCKS];
    wire        s_arb_block_hit  [`DCACHE_NUM_BLOCKS];

    wire        s_arb_reqs_oe    [`DCACHE_NUM_BLOCKS];
    wire        s_arb_reqs_we    [`DCACHE_NUM_BLOCKS];
    wire [14:0] s_arb_reqs_paddr [`DCACHE_NUM_BLOCKS];
    wire [15:0] s_arb_reqs_vec   [`DCACHE_NUM_BLOCKS];
    wire [127:0] s_arb_reqs_data [`DCACHE_NUM_BLOCKS];

    wire        arb_st_override_Out  [`NUM_WB_ST_QS];
    wire        arb_writeSuccess_Out [`NUM_WB_ST_QS];

    assign s_arb_stq_full[0]  = core_stq_full_0_i;
    assign s_arb_stq_full[1]  = core_stq_full_1_i;
    assign s_arb_stq_full[2]  = core_stq_full_2_i;
    assign s_arb_stq_full[3]  = core_stq_full_3_i;
    assign s_arb_stq_empty[0] = core_stq_empty_0_i;
    assign s_arb_stq_empty[1] = core_stq_empty_1_i;
    assign s_arb_stq_empty[2] = core_stq_empty_2_i;
    assign s_arb_stq_empty[3] = core_stq_empty_3_i;
    assign s_arb_stq_addr[0]  = core_stq_addr_0_i;
    assign s_arb_stq_addr[1]  = core_stq_addr_1_i;
    assign s_arb_stq_addr[2]  = core_stq_addr_2_i;
    assign s_arb_stq_addr[3]  = core_stq_addr_3_i;
    assign s_arb_stq_vec[0]   = core_stq_bitvec_0_i;
    assign s_arb_stq_vec[1]   = core_stq_bitvec_1_i;
    assign s_arb_stq_vec[2]   = core_stq_bitvec_2_i;
    assign s_arb_stq_vec[3]   = core_stq_bitvec_3_i;
    assign s_arb_stq_data[0]  = core_stq_data_0_i;
    assign s_arb_stq_data[1]  = core_stq_data_1_i;
    assign s_arb_stq_data[2]  = core_stq_data_2_i;
    assign s_arb_stq_data[3]  = core_stq_data_3_i;
    assign s_arb_clrReq[0]    = core_memStage_CLR_REQ_0_i;
    assign s_arb_clrReq[1]    = core_memStage_CLR_REQ_1_i;
    assign s_arb_clrReq[2]    = core_memStage_CLR_REQ_2_i;
    assign s_arb_clrReq[3]    = core_memStage_CLR_REQ_3_i;

    wire arb_req_served_0_out;
    wire arb_req_served_1_out;

    // ---------------------------------------------------------------
    // DCache_Arbitration instance
    // ---------------------------------------------------------------
    DCache_Arbitration dcache_arbitration (
        .clk_i              (clk),
        .rst                (rst),
        .core_ld_addr_0_V_i (core_ld_addr_0_V_i),
        .core_ld_addr_0_i   (core_ld_addr_0_i),
        .core_ld_addr_1_V_i (core_ld_addr_1_V_i),
        .core_ld_addr_1_i   (core_ld_addr_1_i),
        .core_stq_full_i    (s_arb_stq_full),
        .core_stq_empty_i   (s_arb_stq_empty),
        .core_stq_addr_i    (s_arb_stq_addr),
        .core_stq_bitvec_i  (s_arb_stq_vec),
        .core_stq_data_i    (s_arb_stq_data),
        .core_memClrReq_i   (s_arb_clrReq),
        .block_hit_i        (s_arb_block_hit),
        .reqServed_0_o      (arb_req_served_0_out),
        .reqServed_1_o      (arb_req_served_1_out),
        .reqs_oe_o          (s_arb_reqs_oe),
        .reqs_we_o          (s_arb_reqs_we),
        .reqs_paddr_o       (s_arb_reqs_paddr),
        .reqs_vec_o         (s_arb_reqs_vec),
        .reqs_data_o        (s_arb_reqs_data),
        .st_override_o      (arb_st_override_Out),
        .writeSuccess_o     (arb_writeSuccess_Out)
    );

    // ---------------------------------------------------------------
    // Per-block DTE inputs as unpacked arrays
    // (Each generate iteration consumes [g_i] indexed ports.)
    // ---------------------------------------------------------------
    wire        dte_mem_valid_arr  [`DCACHE_NUM_BLOCKS];
    wire [3:0]  dte_perm_eb_arr    [`DCACHE_NUM_BLOCKS];
    wire        dte_perm_ld_arr    [`DCACHE_NUM_BLOCKS];
    wire        dte_perm_eb1_arr   [`DCACHE_NUM_BLOCKS];
    wire        dte_eb_clr_arr     [`DCACHE_NUM_BLOCKS];
    wire        dte_eb_setCmt_arr  [`DCACHE_NUM_BLOCKS];

    assign dte_mem_valid_arr[0] = dte_mem_valid_0_i;
    assign dte_mem_valid_arr[1] = dte_mem_valid_1_i;
    assign dte_mem_valid_arr[2] = dte_mem_valid_2_i;
    assign dte_mem_valid_arr[3] = dte_mem_valid_3_i;
    assign dte_perm_eb_arr[0]   = dte_permissionToDriveDataBus_evictionBuf_0_i;
    assign dte_perm_eb_arr[1]   = dte_permissionToDriveDataBus_evictionBuf_1_i;
    assign dte_perm_eb_arr[2]   = dte_permissionToDriveDataBus_evictionBuf_2_i;
    assign dte_perm_eb_arr[3]   = dte_permissionToDriveDataBus_evictionBuf_3_i;
    assign dte_perm_ld_arr[0]   = dte_permissionToDriveAddrBus_Ld_0_i;
    assign dte_perm_ld_arr[1]   = dte_permissionToDriveAddrBus_Ld_1_i;
    assign dte_perm_ld_arr[2]   = dte_permissionToDriveAddrBus_Ld_2_i;
    assign dte_perm_ld_arr[3]   = dte_permissionToDriveAddrBus_Ld_3_i;
    assign dte_perm_eb1_arr[0]  = dte_permissionToDriveAddrBus_eb_0_i;
    assign dte_perm_eb1_arr[1]  = dte_permissionToDriveAddrBus_eb_1_i;
    assign dte_perm_eb1_arr[2]  = dte_permissionToDriveAddrBus_eb_2_i;
    assign dte_perm_eb1_arr[3]  = dte_permissionToDriveAddrBus_eb_3_i;
    assign dte_eb_clr_arr[0]    = dte_evictionBuf_clr_0_i;
    assign dte_eb_clr_arr[1]    = dte_evictionBuf_clr_1_i;
    assign dte_eb_clr_arr[2]    = dte_evictionBuf_clr_2_i;
    assign dte_eb_clr_arr[3]    = dte_evictionBuf_clr_3_i;
    assign dte_eb_setCmt_arr[0] = dte_evictionBuf_setCommiting_0_i;
    assign dte_eb_setCmt_arr[1] = dte_evictionBuf_setCommiting_1_i;
    assign dte_eb_setCmt_arr[2] = dte_evictionBuf_setCommiting_2_i;
    assign dte_eb_setCmt_arr[3] = dte_evictionBuf_setCommiting_3_i;

    // ---------------------------------------------------------------
    // Per-block DCache_Block outputs (flat per block)
    // ---------------------------------------------------------------
    wire [127:0] block_dataLineOut [`DCACHE_NUM_BLOCKS];
    wire         block_hit         [`DCACHE_NUM_BLOCKS];
    wire [14:0]  block_eb_addr     [`DCACHE_NUM_BLOCKS];
    wire [3:0]   block_req_2_sch   [`DCACHE_NUM_BLOCKS];

    // ---------------------------------------------------------------
    // 4 DCache_Block instances under the original generate label.
    // Block instance name "block" preserved.
    // ---------------------------------------------------------------
    genvar i;
    generate
        for (i = 0; i < `DCACHE_NUM_BLOCKS; i = i + 1) begin : g_dcache_block
            DCache_Block block (
                .clk_i  (clk),
                .rst_i  (rst),

                .blockReq_oe_i      (s_arb_reqs_oe[i]),
                .blockReq_we_i      (s_arb_reqs_we[i]),
                .blockReq_paddr_i   (s_arb_reqs_paddr[i]),
                .blockReq_vec_i     (s_arb_reqs_vec[i]),
                .blockReq_stq_data_i(s_arb_reqs_data[i]),

                .mem_Valid_FromDte_i                  (dte_mem_valid_arr[i]),
                .evictionBuf_clr_FromDTE_i            (dte_eb_clr_arr[i]),
                .evictionBuf_setCommiting_FromDTE_i   (dte_eb_setCmt_arr[i]),
                .permissionToDriveDataBus_evictionBuf_i(dte_perm_eb_arr[i]),
                .permissionToDriveAddrBus_Ld_i        (dte_perm_ld_arr[i]),
                .permissionToDriveAddrBus_eb_i        (dte_perm_eb1_arr[i]),

                .st_override_for_sch_req_i(arb_st_override_Out[i]),

                .dataBus    (dataBus),
                .address_bus(address_bus),

                .outputs_dataLineOut_o(block_dataLineOut[i]),
                .outputs_hit_o        (block_hit[i]),
                .outputs_eb_addr_o    (block_eb_addr[i]),
                .outputs_req_2_sch_o  (block_req_2_sch[i])
            );
        end
    endgenerate

    // hitVec → arbitration block_hit_i (per-bank feedback)
    generate
        for (i = 0; i < `DCACHE_NUM_BLOCKS; i = i + 1) begin : g_hitvec
            assign s_arb_block_hit[i] = block_hit[i];
        end
    endgenerate

    // ---------------------------------------------------------------
    // MIO_Block instance
    // ---------------------------------------------------------------
    wire        s_mio_writeSuccess;
    wire        s_mio_hit;
    wire        s_mio_reqServed;
    wire [127:0] s_mio_dataLineOut;
    wire [3:0]  s_mio_req_2_sch;

    MIO_Block mio_block_unit (
        .clk                      (clk),
        .rst                      (rst),
        .reqServed_FromDTE_i      (dte_reqServed_mio_i),
        .PermissionToDriveAddrBus (dte_permissionToDriveAddrBus_mio_i),
        .permission2DriveDataBus  (dte_permission2DriveDataBus_mio_i),
        .ld_addr_MIO_V            (core_ld_addr_MIO_V_i),
        .ld_addr_MIO              (core_ld_addr_MIO_i),
        .memStage_CLR_REQ_MIO     (core_memStage_CLR_REQ_MIO_i),
        .stq_info_mio_empty_i     (core_stq_info_mio_empty_i),
        .stq_info_mio_addr_i      (core_stq_info_mio_addr_i),
        .stq_info_mio_data_i      (core_stq_info_mio_data_i),
        .address_bus              (address_bus),
        .dataBus                  (dataBus),
        .writeSuccess_o           (s_mio_writeSuccess),
        .hit_o                    (s_mio_hit),
        .dataLineOut_o            (s_mio_dataLineOut),
        .req_2_sch_o              (s_mio_req_2_sch),
        .reqServed_o              (s_mio_reqServed)
    );

    // ---------------------------------------------------------------
    // out2Core / out2Sch wiring (flat outputs)
    // ---------------------------------------------------------------
    assign out2Core_reqServed_0_o = arb_req_served_0_out;
    assign out2Core_reqServed_1_o = arb_req_served_1_out;

    assign out2Core_hit_0_o = block_hit[0];
    assign out2Core_hit_1_o = block_hit[1];
    assign out2Core_hit_2_o = block_hit[2];
    assign out2Core_hit_3_o = block_hit[3];

    assign out2Core_cacheline_0_o = block_dataLineOut[0];
    assign out2Core_cacheline_1_o = block_dataLineOut[1];
    assign out2Core_cacheline_2_o = block_dataLineOut[2];
    assign out2Core_cacheline_3_o = block_dataLineOut[3];

    assign out2Core_writeSuccess_0_o = arb_writeSuccess_Out[0];
    assign out2Core_writeSuccess_1_o = arb_writeSuccess_Out[1];
    assign out2Core_writeSuccess_2_o = arb_writeSuccess_Out[2];
    assign out2Core_writeSuccess_3_o = arb_writeSuccess_Out[3];

    assign out2Core_writeSuccess_MIO_o = s_mio_writeSuccess;
    assign out2Core_hit_MIO_o          = s_mio_hit;
    assign out2Core_reqServed_MIO_o    = s_mio_reqServed;
    assign out2Core_line_MIO_o         = s_mio_dataLineOut;

    assign out2Sch_req_0_o = block_req_2_sch[0];
    assign out2Sch_req_1_o = block_req_2_sch[1];
    assign out2Sch_req_2_o = block_req_2_sch[2];
    assign out2Sch_req_3_o = block_req_2_sch[3];

    assign out2Sch_evictionBufAddr_0_o = block_eb_addr[0];
    assign out2Sch_evictionBufAddr_1_o = block_eb_addr[1];
    assign out2Sch_evictionBufAddr_2_o = block_eb_addr[2];
    assign out2Sch_evictionBufAddr_3_o = block_eb_addr[3];

    assign out2Sch_req_mio_o = s_mio_req_2_sch;

    // ---------------------------------------------------------------
    // Observer flat-wire taps (preserved from .sv reference, useful
    // for hierarchical wave probing). Same generate label as .sv.
    // ---------------------------------------------------------------
    wire [14:0] tap_eb_addr      [`DCACHE_NUM_BLOCKS];
    wire        tap_block_hit    [`DCACHE_NUM_BLOCKS];
    wire [3:0]  tap_block_req2sch[`DCACHE_NUM_BLOCKS];

    generate
        for (i = 0; i < `DCACHE_NUM_BLOCKS; i = i + 1) begin : g_dcache_top_taps
            assign tap_eb_addr[i]       = block_eb_addr[i];
            assign tap_block_hit[i]     = block_hit[i];
            assign tap_block_req2sch[i] = block_req_2_sch[i];
        end
    endgenerate

endmodule
