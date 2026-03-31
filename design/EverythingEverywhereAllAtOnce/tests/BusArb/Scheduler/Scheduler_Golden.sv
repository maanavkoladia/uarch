import common_pkg::*;
import interconnect_pkg::*;
import BusArbitration_common_pkg::*;

module Scheduler_Golden (
    input wire clk,
    input wire rst,  // active low

    input icache_2_scheduler_t         iCache_2_Sch_i,
    input dcache_2_scheduler_t         dCache_2_Sch_i,
    input mem_2_scheduler_t            mem_2_Sch_i,
    input dma_controller_2_scheduler_t dma_2_sch_i,

    output req_2_sch_t bestPick_o,
    output logic [$clog2(NUM_DCACHE_PORTS)-1:0] bestPick_bk_id_o
);

    // =========================
    // Latched inputs
    // =========================
    sch_latched_reqs_t sch_latches;

    always_ff @(posedge clk) begin
        if (!rst) begin
            sch_latches.i_cache_req <= NO_REQ;

            for (int i = 0; i < NUM_DCACHE_PORTS; i++) begin
                sch_latches.d_cache_reqs[i] <= NO_REQ;
                sch_latches.eb_addr[i]      <= '0;
            end

            sch_latches.mio_req <= NO_REQ;
            sch_latches.dma_req <= NO_REQ;
            sch_latches.dma_write_addr <= '0;
            sch_latches.writeBuf_V_List <= '{default: '0};

        end else begin
            sch_latches.i_cache_req <= iCache_2_Sch_i.req;

            for (int i = 0; i < NUM_DCACHE_PORTS; i++) begin
                sch_latches.d_cache_reqs[i] <= dCache_2_Sch_i.req[i];
                sch_latches.eb_addr[i]      <= dCache_2_Sch_i.evictionBufAddr[i];
            end

            sch_latches.mio_req         <= dCache_2_Sch_i.req_mio;

            sch_latches.dma_req         <= dma_2_sch_i.dma_req;
            sch_latches.dma_write_addr  <= dma_2_sch_i.writeBuf_Address;

            sch_latches.writeBuf_V_List <= mem_2_Sch_i.writeBuf_V;
        end
    end


    // =========================
    // Detect DCache write requests
    // =========================
    logic dcacheMakingWriteReq[NUM_DCACHE_PORTS];

    always_comb begin
        for (int i = 0; i < NUM_DCACHE_PORTS; i++) begin
            dcacheMakingWriteReq[i] = (
                sch_latches.d_cache_reqs[i] == DCACHE_EB_BLOCKING_ST_OVERRIDE ||
                sch_latches.d_cache_reqs[i] == DCACHE_EB_BLOCKING_BANK       ||
                sch_latches.d_cache_reqs[i] == DCACHE_EB_BLOCKING_LD         ||
                sch_latches.d_cache_reqs[i] == DCACHE_EB_BLOCK_ST            ||
                sch_latches.d_cache_reqs[i] == DCACHE_EB_WR
            );
        end
    end


    // =========================
    // Cleaned requests
    // =========================
    req_2_sch_t dcache_reqs_clean[NUM_DCACHE_PORTS];
    req_2_sch_t dma_req_clean;

    always_comb begin
        for (int i = 0; i < NUM_DCACHE_PORTS; i++) begin
            dcache_reqs_clean[i] = sch_latches.d_cache_reqs[i];

            if (dcacheMakingWriteReq[i] &&
                sch_latches.writeBuf_V_List[
                    sch_latches.eb_addr[i][MEM_BANKGROUP_BITS_UB:MEM_BANKGROUP_BITS_LD]
                ]) begin
                dcache_reqs_clean[i] = NO_REQ;
            end
        end

        dma_req_clean = sch_latches.dma_req;

        if ((sch_latches.dma_req == DMA_WRITE_REQ) &&
            sch_latches.writeBuf_V_List[
                sch_latches.dma_write_addr[MEM_BANKGROUP_BITS_UB:MEM_BANKGROUP_BITS_LD]
            ]) begin
            dma_req_clean = NO_REQ;
        end
    end


    // =========================
    // DCache Tree Arbiter (4 ports)
    // =========================
    req_2_sch_t bestDcachePick;
    logic [$clog2(NUM_DCACHE_PORTS)-1:0] bestDcachePort;

    always_comb begin
        req_2_sch_t win01, win23;
        logic [1:0] port01, port23;

        // 0 vs 1 (prefer 0)
        if (dcache_reqs_clean[0] >= dcache_reqs_clean[1]) begin
            win01  = dcache_reqs_clean[0];
            port01 = 0;
        end else begin
            win01  = dcache_reqs_clean[1];
            port01 = 1;
        end

        // 2 vs 3 (prefer 2)
        if (dcache_reqs_clean[2] >= dcache_reqs_clean[3]) begin
            win23  = dcache_reqs_clean[2];
            port23 = 2;
        end else begin
            win23  = dcache_reqs_clean[3];
            port23 = 3;
        end

        // final (prefer left side)
        if (win01 >= win23) begin
            bestDcachePick = win01;
            bestDcachePort = port01;
        end else begin
            bestDcachePick = win23;
            bestDcachePort = port23;
        end
    end


    // =========================
    // Final Arbitration
    // =========================
    always_comb begin
        req_2_sch_t best_req;

        best_req = NO_REQ;
        bestPick_bk_id_o = '0;

        // ICache
        if (sch_latches.i_cache_req > best_req) begin
            best_req = sch_latches.i_cache_req;
        end

        // MIO
        if (sch_latches.mio_req > best_req) begin
            best_req = sch_latches.mio_req;
        end

        // DMA
        if (dma_req_clean > best_req) begin
            best_req = dma_req_clean;
        end

        // DCache (tree result)
        if (bestDcachePick > best_req) begin
            best_req = bestDcachePick;
            bestPick_bk_id_o = bestDcachePort;
        end

        bestPick_o = best_req;
    end

endmodule
