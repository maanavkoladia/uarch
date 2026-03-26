import common_pkg::*;
import interconnect_pkg::*;
import BusArbitration_common_pkg::*;

module Scheduler (
    input wire clk,
    input wire rst,  //active low

    input icache_2_scheduler_t iCache_2_Sch_i,

    input dcache_2_scheduler_t dCache_2_Sch_i,

    input mem_2_scheduler_t mem_2_Sch_i,

    input dma_controller_2_scheduler_t dma_2_sch_i,

    output req_2_sch_t bestPick_o,
    output logic [$clog2(NUM_DCACHE_PORTS) - 1 : 0] bestPick_bk_id_o
);

    sch_latched_reqs_t sch_latches;

    //make the dcache scheduler
    req_2_sch_t dcache_Best_Pick;
    logic [$clog2(NUM_DCACHE_PORTS) - 1 :0] dcache_Best_Pick_BK_ID;


    Scheduler_DCachePicking dcache_picking_unit (
        .d_Cache_eb_addr(sch_latches.eb_addr),
        .writeBuf_V(sch_latches.writeBuf_V_List),
        .d_cache_reqs_dirty_i(sch_latches.d_cache_reqs),
        .bestPick_o(dcache_Best_Pick),
        .bestPick_BK_ID_o(dcache_Best_Pick_BK_ID)
    );

    always_ff @(posedge clk) begin
        if (!rst) begin
            sch_latches.i_cache_req <= NO_REQ;
            for(int i = 0; i < NUM_DCACHE_PORTS; i++) sch_latches.d_cache_reqs[i] <= NO_REQ;
            sch_latches.mio_req <= NO_REQ;
            sch_latches.dma_req <= NO_REQ;
            sch_latches.eb_addr <= '{default : '0};
            sch_latches.writeBuf_V_List <= '{default : '0};
        end else begin
            // ICache
            sch_latches.i_cache_req <= iCache_2_Sch_i.req;

            // DCache (per port)
            for (int i = 0; i < NUM_DCACHE_PORTS; i++) begin
                sch_latches.d_cache_reqs[i] <= dCache_2_Sch_i.req[i];
                sch_latches.eb_addr[i]      <= dCache_2_Sch_i.evictionBufAddr[i];
            end

            // MIO (comes from dcache struct)
            sch_latches.mio_req <= dCache_2_Sch_i.req_mio;

            // DMA
            sch_latches.dma_req <= dma_2_sch_i.dma_req;

            // MEM write buffer valid list
            sch_latches.writeBuf_V_List <= mem_2_Sch_i.writeBuf_V;
        end
    end

    //dma write to mem cleaning
    req_2_sch_t dma_req;
    assign dma_req = mem_2_Sch_i.writeBuf_V[dma_2_sch_i.writeBuf_Address[6 : 4]] ? NO_REQ : dma_2_sch_i.dma_req;

    //now doing the final picking
    //I$ and MIO

    req_2_sch_t IC_MIO_Pick;
    assign IC_MIO_Pick = sch_latches.i_cache_req >= sch_latches.mio_req ? sch_latches.i_cache_req : sch_latches.mio_req;

    req_2_sch_t IC_MIO_DMA_PICK;
    assign IC_MIO_DMA_PICK = IC_MIO_Pick >= dma_req ? IC_MIO_Pick : dma_req;

    req_2_sch_t bestPick;
    assign bestPick = dcache_Best_Pick >= IC_MIO_DMA_PICK ? dcache_Best_Pick : IC_MIO_DMA_PICK;

    assign bestPick_o = bestPick;
    assign bestPick_bk_id_o = dcache_Best_Pick_BK_ID;

endmodule
