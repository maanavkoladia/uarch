import common_pkg::*;
import interconnect_pkg::*;
import BusArbitration_common_pkg::*;
import mem_common_pkg::*;

module Scheduler_DCachePicking (
    // For EB addresses
    input p_address_t d_Cache_eb_addr[NUM_DCACHE_PORTS],

    input req_2_sch_t d_cache_reqs_dirty_i[NUM_DCACHE_PORTS],
    input logic [numWriteBufsInMem-1: 0] writeBuf_V,

    output req_2_sch_t bestPick_o,
    output logic [$clog2(NUM_DCACHE_PORTS)-1:0] bestPick_BK_ID_o
);

    // Cleaning
    req_2_sch_t d_cache_req[NUM_DCACHE_PORTS];
    bool eb_clashing[NUM_DCACHE_PORTS];

    always_comb begin
        eb_clashing = '{default : 0};
        for (int i = 0; i < NUM_DCACHE_PORTS; i++) begin
            // Default assignment to avoid latches
            d_cache_req[i] = d_cache_reqs_dirty_i[i];

            if (
                ((d_cache_reqs_dirty_i[i] == DCACHE_EB_BLOCKING_BANK )
                 || (d_cache_reqs_dirty_i[i] == DCACHE_EB_BLOCKING_ST_OVERRIDE)
                 || (d_cache_reqs_dirty_i[i] == DCACHE_EB_BLOCKING_LD)
                 || (d_cache_reqs_dirty_i[i] == DCACHE_EB_BLOCK_ST)
                 || (d_cache_reqs_dirty_i[i] == DCACHE_EB_WR))
                && writeBuf_V[d_Cache_eb_addr[i][MEM_BANKGROUP_BITS_UB : MEM_BANKGROUP_BITS_LD]]
            ) begin
                d_cache_req[i] = NO_REQ;
                eb_clashing[i] = 1;
            end
        end
    end

    // Pick logic
    req_2_sch_t d_cache_req_pick_0, d_cache_req_pick_1;
    logic [$clog2(NUM_DCACHE_PORTS)-1:0] d_cache_req_pick_bk_0, d_cache_req_pick_bk_1;

    assign d_cache_req_pick_0   = (d_cache_req[0] >= d_cache_req[1]) ? d_cache_req[0] : d_cache_req[1];
    assign d_cache_req_pick_bk_0 = (d_cache_req[0] >= d_cache_req[1]) ? 0 : 1;

    assign d_cache_req_pick_1   = (d_cache_req[2] >= d_cache_req[3]) ? d_cache_req[2] : d_cache_req[3];
    assign d_cache_req_pick_bk_1 = (d_cache_req[2] >= d_cache_req[3]) ? 2 : 3;

    assign bestPick_o        = (d_cache_req_pick_0 >= d_cache_req_pick_1) ? d_cache_req_pick_0 : d_cache_req_pick_1;
    assign bestPick_BK_ID_o  = (d_cache_req_pick_0 >= d_cache_req_pick_1) ? d_cache_req_pick_bk_0 : d_cache_req_pick_bk_1;

endmodule
