import common_pkg::*;
import interconnect_pkg::*;
import DCache_common_pkg::*;

// =====================================================================
// Structural-port swap flags
//
// Uncomment a flag below to substitute the structural Verilog 2005 port
// of the named module for its SystemVerilog reference. Each flag is
// consumed by the parent that instantiates that module (NOT by this
// file directly). The SV reference remains compiled in the otherwise
// path so we can A/B test by toggling the flag.
//
// USE_STRUCTURAL_EB     -> structural/EvictionBuf.v            (parent: DCache_Block.sv)
// USE_STRUCTURAL_BANK   -> structural/DCache_Bank.v + _TagStore.v + _DataStore.v
//                                                              (parent: DCache_Block.sv)
// USE_STRUCTURAL_VCACHE -> structural/VCache.v + _TagStore.v + _DataStore.v + LRU.v
//                                                              (parent: DCache_Block.sv)
// USE_STRUCTURAL_ARB    -> structural/DCache_Arbitration.sv   (parent: DCache_TOP.sv)
// USE_STRUCTURAL_MIO    -> structural/MIO_Block.v             (parent: DCache_TOP.sv)
// =====================================================================
//`define USE_STRUCTURAL_EB
//`define USE_STRUCTURAL_BANK
//`define USE_STRUCTURAL_VCACHE
`define USE_STRUCTURAL_ARB
`define USE_STRUCTURAL_MIO

module DCache_TOP (
    input wire clk,
    input wire rst,

    //dc
    input core_2_dcache_t inFromCore_i,

    output dcache_2_core_t out2Core_o,

    //bus sarb stuff
    input dte_2_dcache_t inFromDTE_i,
    output dcache_2_scheduler_t out2Sch_o,

    //buses for filling the dcache banks
    //and for evicting
    inout [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus,

    //for driving the eviction buf address on the the bus
    inout [ADDRESS_BUS_WIDTH_BITS - 1 : 0] address_bus

);

    dcache_block_outputs_t blockOutputs[DCACHE_NUM_BLOCKS];
    bool hitVec[DCACHE_NUM_BLOCKS];
    block_req_t req_2_blocks[DCACHE_NUM_BLOCKS];
    mio_block_outputs_t mio_block_outputs;
    bool arb_st_override_Out[NUM_WB_ST_QS];
    bool arb_req_served_0_out;
    bool arb_req_served_1_out;

    // ── Flat wires for structural DCache_Arbitration ─────────────────────────
    // Always present — functionally inert when USE_STRUCTURAL_ARB is not defined.
    wire        s_arb_ld0V, s_arb_ld1V;
    wire [14:0] s_arb_ld0,  s_arb_ld1;
    wire        s_arb_stq_full   [NUM_WB_ST_QS];
    wire        s_arb_stq_empty  [NUM_WB_ST_QS];
    wire [14:0] s_arb_stq_addr   [NUM_WB_ST_QS];
    wire [15:0] s_arb_stq_vec    [NUM_WB_ST_QS];
    wire [127:0] s_arb_stq_data  [NUM_WB_ST_QS];
    wire        s_arb_clrReq     [DCACHE_NUM_BLOCKS];
    wire        s_arb_reqs_oe    [DCACHE_NUM_BLOCKS];
    wire        s_arb_reqs_we    [DCACHE_NUM_BLOCKS];
    wire [14:0] s_arb_reqs_paddr [DCACHE_NUM_BLOCKS];
    wire [15:0] s_arb_reqs_vec   [DCACHE_NUM_BLOCKS];
    wire [127:0] s_arb_reqs_data [DCACHE_NUM_BLOCKS];

    // struct → flat taps (always present — inert when USE_STRUCTURAL_ARB is off)
    assign s_arb_ld0V = inFromCore_i.ld_addr_0_V;
    assign s_arb_ld0  = inFromCore_i.ld_addr_0;
    assign s_arb_ld1V = inFromCore_i.ld_addr_1_V;
    assign s_arb_ld1  = inFromCore_i.ld_addr_1;

    generate
        for (genvar gs = 0; gs < NUM_WB_ST_QS; gs = gs + 1) begin : g_arb_core_taps
            assign s_arb_stq_full[gs]  = inFromCore_i.stq_heads[gs].full;
            assign s_arb_stq_empty[gs] = inFromCore_i.stq_heads[gs].empty;
            assign s_arb_stq_addr[gs]  = inFromCore_i.stq_heads[gs].address;
            assign s_arb_stq_vec[gs]   = inFromCore_i.stq_heads[gs].bit_vec;
            // byte_t[16] → 128-bit flat: data[15] at MSB, data[0] at LSB
            assign s_arb_stq_data[gs]  = {
                inFromCore_i.stq_heads[gs].data[15],
                inFromCore_i.stq_heads[gs].data[14],
                inFromCore_i.stq_heads[gs].data[13],
                inFromCore_i.stq_heads[gs].data[12],
                inFromCore_i.stq_heads[gs].data[11],
                inFromCore_i.stq_heads[gs].data[10],
                inFromCore_i.stq_heads[gs].data[9],
                inFromCore_i.stq_heads[gs].data[8],
                inFromCore_i.stq_heads[gs].data[7],
                inFromCore_i.stq_heads[gs].data[6],
                inFromCore_i.stq_heads[gs].data[5],
                inFromCore_i.stq_heads[gs].data[4],
                inFromCore_i.stq_heads[gs].data[3],
                inFromCore_i.stq_heads[gs].data[2],
                inFromCore_i.stq_heads[gs].data[1],
                inFromCore_i.stq_heads[gs].data[0]
            };
            assign s_arb_clrReq[gs] = inFromCore_i.memStage_CLR_REQ[gs];
        end
    endgenerate

`ifdef USE_STRUCTURAL_ARB
        initial $display("using STRUCTURAL arb");

    // flat → struct repacking: connect s_arb_reqs_* back into req_2_blocks
    generate
        for (genvar gp = 0; gp < DCACHE_NUM_BLOCKS; gp = gp + 1) begin : g_arb_pack_out
            assign req_2_blocks[gp].oe     = s_arb_reqs_oe[gp];
            assign req_2_blocks[gp].we     = s_arb_reqs_we[gp];
            assign req_2_blocks[gp].p_addr = s_arb_reqs_paddr[gp];
            assign req_2_blocks[gp].vec    = s_arb_reqs_vec[gp];
            for (genvar gb = 0; gb < CACHE_LINES_SIZE_B; gb = gb + 1) begin : g_arb_data_unpack
                assign req_2_blocks[gp].st_q_data[gb] = s_arb_reqs_data[gp][gb*8 +: 8];
            end
        end
    endgenerate

    DCache_Arbitration dcache_arbitration (
        .clk_i              (clk),
        .rst                (rst),
        .core_ld_addr_0_V_i (s_arb_ld0V),
        .core_ld_addr_0_i   (s_arb_ld0),
        .core_ld_addr_1_V_i (s_arb_ld1V),
        .core_ld_addr_1_i   (s_arb_ld1),
        .core_stq_full_i    (s_arb_stq_full),
        .core_stq_empty_i   (s_arb_stq_empty),
        .core_stq_addr_i    (s_arb_stq_addr),
        .core_stq_bitvec_i  (s_arb_stq_vec),
        .core_stq_data_i    (s_arb_stq_data),
        .core_memClrReq_i   (s_arb_clrReq),
        .block_hit_i        (hitVec),
        .reqServed_0_o      (arb_req_served_0_out),
        .reqServed_1_o      (arb_req_served_1_out),
        .reqs_oe_o          (s_arb_reqs_oe),
        .reqs_we_o          (s_arb_reqs_we),
        .reqs_paddr_o       (s_arb_reqs_paddr),
        .reqs_vec_o         (s_arb_reqs_vec),
        .reqs_data_o        (s_arb_reqs_data),
        .st_override_o      (arb_st_override_Out),
        .writeSuccess_o     (out2Core_o.writeSuccess)
    );
`else
    initial $display("using SYSTEM arb");

    DCache_Arbitration dcache_arbitration (
        .clk_i           (clk),
        .rst             (rst),  // active low
        .core_i          (inFromCore_i),
        .block_hit_i     (hitVec),
        .reqServed_0_o   (arb_req_served_0_out),
        .reqServed_1_o   (arb_req_served_1_out),
        .reqs_2_blocks_o (req_2_blocks),
        .st_override_o   (arb_st_override_Out),
        .writeSuccess_o  (out2Core_o.writeSuccess)
    );
`endif

    generate
        for (genvar i = 0; i < DCACHE_NUM_BLOCKS; i++) begin : g_dcache_block
            DCache_Block block (
                .clk_i(clk),
                .rst_i(rst),  //active low
                .block_req_i(req_2_blocks[i]),
                .mem_Valid_FromDte_i(inFromDTE_i.mem_valid[i]),
                .evictionBuf_clr_FromDTE_i(inFromDTE_i.evictionBuf_clr[i]),
                .evictionBuf_setCommiting_FromDTE_i(inFromDTE_i.evictionBuf_setCommiting[i]),
                .permissionToDriveDataBus_evictionBuf(inFromDTE_i.permissionToDriveDataBus_evictionBuf[i]),
                .permissionToDriveAddrBus_Ld(inFromDTE_i.permissionToDriveAddrBus_Ld[i]),
                .permissionToDriveAddrBus_eb(inFromDTE_i.permissionToDriveAddrBus_eb[i]),
                .st_override_for_sch_req(arb_st_override_Out[i]),
                .dataBus(dataBus),
                .address_bus(address_bus),
                .outputs_o(blockOutputs[i])
            );
        end
    endgenerate

    // ── Flat wires for structural MIO_Block ────────────────────────────────
    // Always present — functionally inert when USE_STRUCTURAL_MIO is not defined.
    wire        s_mio_stq_empty;
    wire [14:0] s_mio_stq_addr;
    wire [127:0] s_mio_stq_data;
    wire        s_mio_writeSuccess;
    wire        s_mio_hit;
    wire        s_mio_reqServed;
    wire [127:0] s_mio_dataLineOut;
    wire [13:0]  s_mio_req_2_sch;

    // struct → flat taps (always present — inert when USE_STRUCTURAL_MIO is off)
    assign s_mio_stq_empty = inFromCore_i.stq_info_mio.empty;
    assign s_mio_stq_addr  = inFromCore_i.stq_info_mio.address;
    assign s_mio_stq_data  = {
        inFromCore_i.stq_info_mio.data[15],
        inFromCore_i.stq_info_mio.data[14],
        inFromCore_i.stq_info_mio.data[13],
        inFromCore_i.stq_info_mio.data[12],
        inFromCore_i.stq_info_mio.data[11],
        inFromCore_i.stq_info_mio.data[10],
        inFromCore_i.stq_info_mio.data[9],
        inFromCore_i.stq_info_mio.data[8],
        inFromCore_i.stq_info_mio.data[7],
        inFromCore_i.stq_info_mio.data[6],
        inFromCore_i.stq_info_mio.data[5],
        inFromCore_i.stq_info_mio.data[4],
        inFromCore_i.stq_info_mio.data[3],
        inFromCore_i.stq_info_mio.data[2],
        inFromCore_i.stq_info_mio.data[1],
        inFromCore_i.stq_info_mio.data[0]
    };

`ifdef USE_STRUCTURAL_MIO
    initial $display("using STRUCTURAL MIO");

    // flat → struct repacking: drive mio_block_outputs from s_mio_* wires
    assign mio_block_outputs.writeSuccess = s_mio_writeSuccess;
    assign mio_block_outputs.hit_o        = s_mio_hit;
    assign mio_block_outputs.reqServed    = s_mio_reqServed;
    assign mio_block_outputs.req_2_sch    = s_mio_req_2_sch;
    generate
        for (genvar gm = 0; gm < CACHE_LINES_SIZE_B; gm = gm + 1) begin : g_mio_line_unpack
            assign mio_block_outputs.dataLineOut[gm] = s_mio_dataLineOut[gm*8 +: 8];
        end
    endgenerate

    MIO_Block mio_block_unit (
        .clk                      (clk),
        .rst                      (rst),
        .reqServed_FromDTE_i      (inFromDTE_i.reqServed_mio),
        .PermissionToDriveAddrBus (inFromDTE_i.permissionToDriveAddrBus_mio),
        .permission2DriveDataBus  (inFromDTE_i.permission2DriveDataBus_mio),
        .ld_addr_MIO_V            (inFromCore_i.ld_addr_MIO_V),
        .ld_addr_MIO              (inFromCore_i.ld_addr_MIO),
        .memStage_CLR_REQ_MIO     (inFromCore_i.memStage_CLR_REQ_MIO),
        .stq_info_mio_empty_i     (s_mio_stq_empty),
        .stq_info_mio_addr_i      (s_mio_stq_addr),
        .stq_info_mio_data_i      (s_mio_stq_data),
        .address_bus              (address_bus),
        .dataBus                  (dataBus),
        .writeSuccess_o           (s_mio_writeSuccess),
        .hit_o                    (s_mio_hit),
        .dataLineOut_o            (s_mio_dataLineOut),
        .req_2_sch_o              (s_mio_req_2_sch),
        .reqServed_o              (s_mio_reqServed)
    );
`else
    initial $display("using SYSTEM MIO");
    MIO_Block mio_block_unit (
        .clk(clk),
        .rst(rst),  //active low
        .reqServed_FromDTE_i(inFromDTE_i.reqServed_mio),
        .PermissionToDriveAddrBus(inFromDTE_i.permissionToDriveAddrBus_mio),
        .permission2DriveDataBus(inFromDTE_i.permission2DriveDataBus_mio),
        .ld_addr_MIO_V(inFromCore_i.ld_addr_MIO_V),
        .ld_addr_MIO(inFromCore_i.ld_addr_MIO),
        .stq_info_mio(inFromCore_i.stq_info_mio),
        .memStage_CLR_REQ_MIO(inFromCore_i.memStage_CLR_REQ_MIO),
        .address_bus(address_bus),
        .dataBus(dataBus),
        .outputs_o(mio_block_outputs)
    );
`endif

    //D$ arb hit signals for req clearing business from the blocks hit signals
    //second for loop is jsut wiring hit signals out to memStage
    always_comb begin
        for (int i = 0; i < DCACHE_NUM_BLOCKS; i++) hitVec[i] = blockOutputs[i].hit_o;
        for (int i = 0; i < DCACHE_NUM_BLOCKS; i++) out2Core_o.hit[i] = blockOutputs[i].hit_o;
        for (int i = 0; i < DCACHE_NUM_BLOCKS; i++) out2Core_o.cacheline[i] = blockOutputs[i].dataLineOut;

    end

    assign out2Core_o.reqServed_0 = arb_req_served_0_out;
    assign out2Core_o.reqServed_1  = arb_req_served_1_out;

    //out 2 sch stuff
    always_comb begin
        for (int i = 0; i < DCACHE_NUM_BLOCKS; i++) begin
            out2Sch_o.req[i] = blockOutputs[i].req_2_sch;
            out2Sch_o.evictionBufAddr[i] = blockOutputs[i].eb_addr;
        end
    end

    //mio block out wiring
    assign out2Core_o.writeSuccess_MIO = mio_block_outputs.writeSuccess;
    assign out2Core_o.hit_MIO = mio_block_outputs.hit_o;
    assign out2Core_o.line_MIO = mio_block_outputs.dataLineOut;
    assign out2Core_o.reqServed_MIO = mio_block_outputs.reqServed;
    assign out2Sch_o.req_mio = mio_block_outputs.req_2_sch;

    // ================================================================
    // Observer flat-wire taps (purely informational)
    //
    // These wires are driven by `assign` from existing struct fields and
    // are consumed by NO logic in this module. They exist as a stable
    // flat-wire surface for incremental structural ports of upcoming
    // modules (DCache_Block, DCache_Bank, VCache, MIO_Block, ...). Adding
    // / removing taps here is functionally inert.
    // ================================================================
    wire [14:0]            tap_eb_addr      [DCACHE_NUM_BLOCKS];
    wire                   tap_block_hit    [DCACHE_NUM_BLOCKS];
    wire [NUM_REQS-1:0]    tap_block_req2sch[DCACHE_NUM_BLOCKS];

    generate
        for (genvar gt = 0; gt < DCACHE_NUM_BLOCKS; gt++) begin : g_dcache_top_taps
            assign tap_eb_addr[gt]      = blockOutputs[gt].eb_addr;
            assign tap_block_hit[gt]    = blockOutputs[gt].hit_o;
            assign tap_block_req2sch[gt] = blockOutputs[gt].req_2_sch;
        end
    endgenerate

endmodule

