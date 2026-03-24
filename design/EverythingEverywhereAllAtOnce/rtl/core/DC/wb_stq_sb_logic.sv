import core_common_pkg::st_q_2_dep_check_outputs_t;
import common_pkg::*;

module wb_stq_sb_logic(
    input bool valid,
    input p_address_t st_paddr_0,
    input p_address_t st_paddr_1,
    input bool ST_XCL,
    input bool ST_OP,
    input st_q_2_dep_check_outputs_t stq_info,
    output bool stall
    //probably need to send MIO queue back once I make it
);


    logic [$clog2(NUM_WB_ST_QS)-1:0] st0_bank_num;
    logic [$clog2(NUM_WB_ST_QS)-1:0] st1_bank_num;
    
    //[5:4]
    assign st0_bank_num = st_paddr_0[$clog2(CACHE_LINES_SIZE_B)+$clog2(NUM_WB_ST_QS)-1 : $clog2(CACHE_LINES_SIZE_B)];
    assign st1_bank_num = st_paddr_1[$clog2(CACHE_LINES_SIZE_B)+$clog2(NUM_WB_ST_QS)-1 : $clog2(CACHE_LINES_SIZE_B)];

    bool st0_bank_hit[NUM_WB_ST_QS];
    bool st1_bank_hit[NUM_WB_ST_QS];

    bool valid_dep0;
    bool valid_dep1;

    // Check each bank's store queue for address matches
    always_comb begin
        // Initialize hit arrays
        for(int num_stqs = 0; num_stqs < NUM_WB_ST_QS; num_stqs++) begin
            st0_bank_hit[num_stqs] = 1'b0;
            st1_bank_hit[num_stqs] = 1'b0;
        end

        // Check all entries in each bank's queue
        for(int num_stqs = 0; num_stqs < NUM_WB_ST_QS; num_stqs++) begin
            for(int i = 0; i < ST_Q_DEPTH; i++) begin
                st0_bank_hit[num_stqs] |= ((stq_info.entries[num_stqs*ST_Q_DEPTH + i].address == st_paddr_0)
                                            & stq_info.entries[num_stqs*ST_Q_DEPTH + i].valid);
                
                st1_bank_hit[num_stqs] |= ((stq_info.entries[num_stqs*ST_Q_DEPTH + i].address == st_paddr_1)
                                            & stq_info.entries[num_stqs*ST_Q_DEPTH + i].valid);
            end
        end
    end

    assign valid_dep0 = st0_bank_hit[st0_bank_num] & ST_OP;
    assign valid_dep1 = st1_bank_hit[st1_bank_num] & ST_OP & ST_XCL;

    assign stall = valid_dep0 | valid_dep1;

    /* Dependency Check Structure:
     * For each of 4 banks (selected by address bits [5:4]):
     * - 16 comparators per incoming store address (4 comparators × 4 queues)
     * - Each bank's queue (4 entries) checks for address match
     * 
     * Layout per address:
     * [bank0: 4 comps] [bank1: 4 comps] [bank2: 4 comps] [bank3: 4 comps]
     *        |                |                |                |
     *       hit0            hit1             hit2             hit3
     * ________________________________________________________________
     * |_______________________mux (4:1)_______________________________|  <-- select using addr[5:4]
     *                              |
     *                         hit result
     *                              & ST_OP
     *                              = dependency stall
     */

endmodule