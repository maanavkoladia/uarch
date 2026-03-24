import common_pkg::*;
import interconnect_pkg::*;
import DCache_common_pkg::*;

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

    DCache_Arbitration dcache_arbitration (
        .clk_i(clk),
        .rst(rst),  // active low
        .core_i(inFromCore_i),
        .block_hit_i(hitVec),
        .out2Core_o(out2Core_o),
        .reqs_2_blocks_o(req_2_blocks),
        .st_override_o(arb_st_override_Out)
    );

    generate
        for (genvar i = 0; i < DCACHE_NUM_BLOCKS; i++) begin : g_dcache_block
            DCache_Block block (
                .clk_i(clk),
                .rst_i(rst),  //active low
                .block_req_i(req_2_blocks[i]),
                .mem_Valid_FromDte_i(inFromDTE_i.mem_valid[i]),
                .evictionBuf_V_clr_FromDTE_i(inFromDTE_i.evictionBuf_V_clr[i]),
                .permissionToDriveDataBus_evictionBuf(permissionToDriveDataBus_evictionBuf[i]),
                .permissionToDriveAddrBus_Ld(permissionToDriveAddrBus_Ld),
                .permissionToDriveAddrBus_eb(permissionToDriveAddrBus_eb),
                .st_override_for_sch_req(arb_st_override_Out),
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
        .memStalling_FromCore(inFromCore_i.memStalling),
        .address_bus(address_bus),
        .dataBus(dataBus),
        .outputs_o(mio_block_outputs)
    );

    //need to add bus arb stuff
    always_comb begin
        for (int i = 0; i < DCACHE_NUM_BLOCKS; i++) hitVec[i] = blockOutputs[i].hit_o;
    end

    //deal w the outputs
    //st_q write uccess logic
    always_comb begin
        for (int i = 0; i < DCACHE_NUM_BLOCKS; i++) begin
            if (req_2_blocks[i].we && blockOutputs[i].hit_o) out2Core_o.writeSuccess[i] = 1;
        end
    end

    //line0 line 1 logic
    always_comb begin
        bool usedLine0 = 0;
        out2Core_o.line_0 = 0;
        out2Core_o.hit_line_0 = 0;
        out2Core_o.line_1 = 0;
        out2Core_o.hit_line_1 = 0;

        for (int i = 0; i < DCACHE_NUM_BLOCKS; i++) begin
            if (req_2_blocks[i].oe && blockOutputs[i].hit_o) begin
                if (!usedLine0) begin
                    out2Core_o.hit_line_0 = 1;
                    out2Core_o.line_0 = blockOutputs[i].dataLineOut;
                    usedLine0 = 1;
                end else begin
                    out2Core_o.hit_line_1 = 1;
                    out2Core_o.line_1 = blockOutputs[i].dataLineOut;
                end

            end
        end
    end

    //out 2 sch stuff
    always_comb begin
        for (int i = 0; i < DCACHE_NUM_BLOCKS; i++) begin
            out2Sch_o.req[i] = blockOutputs[i].req_2_sch;
            out2Sch_o.evictionBufAddr[i] = blockOutputs[i].eb_addr;
        end
    end

    wire [ADDRESS_BUS_WIDTH_BITS - 1 : 0] address_bus_fake;
    wire driveAddrBus;
    assign address_bus = driveAddrBus ? address_bus_fake : 'z;

    //driving bus logic
    always_comb begin
        driveAddrBus = 0;
        address_bus_fake = 0;
        for (int i = 0; i < NUM_DCACHE_PORTS; i++) begin
            for (int j = 0; j < MEM_BUS_SIZE / DATA_BUS_WIDTH_BITS; j++) begin
                if (inFromDTE_i.evictionBuf_PermissionToDriveBus[i][j]) begin
                    driveAddrBus = 1;
                    address_bus_fake = blockOutputs[i].eb_addr;
                end
            end
        end
    end

    //mio block out wiring
    assign out2Core_o.writeSuccess_MIO = mio_block_outputs.writeSuccess;
    assign out2Core_o.hit_line_MIO = mio_block_outputs.hit_o;
    assign out2Core_o.writeSuccess_MIO = mio_block_outputs.writeSuccess;
    assign out2Core_o.req_rejected_mio = mio_block_outputs.req_rejected;
    assign out2Sch_o.req_mio = mio_block_outputs.req_2_sch;

endmodule

