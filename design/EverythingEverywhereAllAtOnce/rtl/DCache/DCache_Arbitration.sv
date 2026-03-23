import common_pkg::*;
import DCache_pkg::*;
import interconnect_pkg::*;

module DCache_Arbitration (

    input wire clk_i,
    input wire rst,    // active low

    // contains store_q data from WB, and ld_reqs from MEM
    input core_2_dcache_t core_i,
    input bool hit[DCACHE_NUM_BLOCKS],

    output block_req_t reqs_2_blocks_o[DCACHE_NUM_BLOCKS]
);

    localparam int LD_REQ_BANK_UB = DCACHE_BANK_BANK_UB;
    localparam int LD_REQ_BANK_LB = DCACHE_BANK_BANK_LB;
    localparam int LD_REQ_BANK_WIDTH = DCACHE_BANK_BANK_WIDTH;

    block_req_t reqs[DCACHE_NUM_BLOCKS];
    bool bank_idleness[DCACHE_NUM_BLOCKS];

    logic [LD_REQ_BANK_WIDTH - 1 : 0] ld_req_0_bankNum;
    logic [LD_REQ_BANK_WIDTH - 1 : 0] ld_req_1_bankNum;

    // store override: prioritize stores when queue is full
    bool st_override[NUM_WB_ST_QS];

    assign ld_req_0_bankNum = core_i.ld_addr_0[LD_REQ_BANK_UB:LD_REQ_BANK_LB];
    assign ld_req_1_bankNum = core_i.ld_addr_1[LD_REQ_BANK_UB:LD_REQ_BANK_LB];

    // -----------------------------------------------------------------------------
    // Request Scheduling (when no request is currently being served)
    //
    // Idle State Definition:
    // - oe == 0 && we == 0
    //   → No request is being served in this cycle
    //
    // Scheduling Priority (highest → lowest):
    //
    // 1. Store Override Case:
    //    - If st_override == 1
    //    → Schedule store from st_q
    //
    // 2. Load Request:
    //    - If valid ld_req AND matches bank AND !memStalling
    //    → Schedule load request
    //
    // 3. Normal Store:
    //    - Else if st_q not empty
    //    → Schedule store from st_q
    //
    // 4. No-op:
    //    → No request scheduled
    //
    // Notes:
    // - oe and we are mutually exclusive
    // - default each cycle is cleared (no request)
    // - requests complete when hit[i] is observed
    // -----------------------------------------------------------------------------

    always_ff @(posedge clk_i) begin
        if (!rst) reqs <= '0;
        else begin
            for (int i = 0; i < DCACHE_NUM_BLOCKS; i++) begin

                // Default: clear request every cycle
                reqs[i].oe <= 1'b0;
                reqs[i].we <= 1'b0;

                if (bank_idleness[i]) begin

                    // 1. Store override
                    if (!core_i.stq_info[i].empty && st_override[i]) begin
                        reqs[i].we        <= 1'b1;
                        reqs[i].p_addr    <= core_i.stq_info[i].p_addr;
                        reqs[i].vec       <= core_i.stq_info[i].bit_vec;

                        reqs[i].st_q_data <= core_i.stq_info[i].dataLine;

                        // 2. Load req 0
                    end else if (!core_i.memStalling &&
                                 core_i.ld_addr_0_V &&
                                 (ld_req_0_bankNum == i)) begin

                        reqs[i].oe     <= 1'b1;
                        reqs[i].p_addr <= core_i.ld_addr_0;

                        // 3. Load req 1
                    end else if (!core_i.memStalling &&
                                 core_i.ld_addr_1_V &&
                                 (ld_req_1_bankNum == i)) begin

                        reqs[i].oe     <= 1'b1;
                        reqs[i].p_addr <= core_i.ld_addr_1;

                        // 4. Normal store
                    end else if (!core_i.stq_info[i].empty) begin
                        reqs[i].we     <= 1'b1;
                        reqs[i].p_addr <= core_i.stq_info[i].p_addr;
                        reqs[i].vec    <= core_i.stq_info[i].bit_vec;

                        for (int j = 0; j < CACHE_LINES_SIZE_B; j++) begin
                            reqs[i].st_q_data[j] <= core_i.stq_info[i].dataLine[j];
                        end
                    end
                end
                // else: not idle → request naturally cleared unless reissued
            end
        end
    end

    // store override logic
    always_ff @(posedge clk_i) begin
        if (!rst) begin
            for (int i = 0; i < NUM_WB_ST_QS; i++) begin
                st_override[i] <= 1'b0;
            end
        end else begin
            for (int i = 0; i < NUM_WB_ST_QS; i++) begin
                if (core_i.stq_info[i].full) st_override[i] <= 1'b1;
                else if (core_i.stq_info[i].empty) st_override[i] <= 1'b0;
            end
        end
    end

    // output assignment
    always_comb begin
        for (int i = 0; i < DCACHE_NUM_BLOCKS; i++) begin
            reqs_2_blocks_o[i] = reqs[i];
        end
    end

    // bank idleness: no active request
    always_comb begin
        for (int i = 0; i < DCACHE_NUM_BLOCKS; i++) begin
            bank_idleness[i] = !reqs[i].we && !reqs[i].oe;
        end
    end

endmodule
