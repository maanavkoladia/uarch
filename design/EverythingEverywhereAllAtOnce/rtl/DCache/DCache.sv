import common_pkg::*;
import DCache_pkg::*;
import interconnect_pkg::*;

module DCache (
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

    DCache_Arbitration dcache_arbitration (
        .clk_i(clk),
        .rst(rst),  // active low
        .core_i(inFromCore_i),
        .hit(hitVec),
        .reqs_2_blocks_o(req_2_blocks)
    );
    generate
        for (genvar i = 0; i < DCACHE_NUM_BLOCKS; i++) begin : g_dcachc_block
            DCache_Block block (
                .clk_i(clk),
                .rst_i(rst),  //active low
                .block_req_i(req_2_blocks[i]),
                .mem_Valid_FromDte_i(inFromDTE_i[i]),
                .dataBus(dataBus),
                .outputs_o(blockOutputs[i])
            );
        end
    endgenerate

    //need to add bus arb stuff
    always_comb begin
        for (int i = 0; i < DCACHE_NUM_BLOCKS; i++) hitVec[i] = blockOutputs[i].hit_o;
    end

    //deal w the outputs
    //st_q write uccess logic
    always_comb begin
        for (int i = 0; i < DCACHE_NUM_BLOCKS; i++) begin
            if (req_2_blocks[i].we && blockOutputs.hit_o) out2Core_o.writeSuccess[i] = 1;
        end
    end

    //line0 line 1 logic
    always_comb begin
        bool usedLine0 = false;
        for (int j = 0; j < CACHE_LINES_SIZE_B; j++) begin
            out2Core_o.line_0[j] = 0;
            out2Core_o.line_1[j] = 0;
        end
        for (int i = 0; i < DCACHE_NUM_BLOCKS; i++) begin
            if (req_2_blocks[i].oe && blockOutputs.hit_o) begin
                if (!usedLine0) begin
                    out2Core_o.hit_line_0 = 1;
                    for (int j = 0; j < CACHE_LINES_SIZE_B; j++)
                    out2Core_o.line_0[j] = blockOutputs[i].dataLineOut[j];
                end else begin
                    out2Core_o.hit_line_1 = 1;
                    for (int j = 0; j < CACHE_LINES_SIZE_B; j++)
                    out2Core_o.line_1[j] = blockOutputs[i].dataLineOut[j];
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

    //driving data bus
    wire [DATA_BUS_WIDTH_BITS - 1 : 0] data_bus_fake;
    wire driveDataBus;
    assign dataBus = driveDataBus ? data_bus_fake : 'z;

    //driving bus logic
    always_comb begin
        driveDataBus  = 1'b0;
        data_bus_fake = '0;

        for (int i = 0; i < NUM_DCACHE_PORTS; i++) begin
            for (int j = 0; j < MEM_BUS_SIZE / DATA_BUS_WIDTH_BITS; j++) begin
                if (dte_i.evictionBuf_PermissionToDriveBus[i][j]) begin

                    driveDataBus = 1'b1;

                    data_bus_fake = {
                        blockOutputs.eb_line_O[i][4*j+3],
                        blockOutputs.eb_line_O[i][4*j+2],
                        blockOutputs.eb_line_O[i][4*j+1],
                        blockOutputs.eb_line_O[i][4*j+0]
                    };

                end
            end
        end
    end

endmodule
