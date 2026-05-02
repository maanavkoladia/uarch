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
// =====================================================================
//`define USE_STRUCTURAL_EB
//`define USE_STRUCTURAL_BANK
//`define USE_STRUCTURAL_VCACHE

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

    DCache_Arbitration dcache_arbitration (
        .clk_i(clk),
        .rst(rst),  // active low
        .core_i(inFromCore_i),
        .block_hit_i(hitVec),
        .reqServed_0_o(arb_req_served_0_out),
        .reqServed_1_o(arb_req_served_1_out),
        .reqs_2_blocks_o(req_2_blocks),
        .st_override_o(arb_st_override_Out),
        .writeSuccess_o(out2Core_o.writeSuccess)
    );

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

