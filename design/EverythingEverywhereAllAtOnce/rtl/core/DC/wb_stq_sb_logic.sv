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
    
    //[5:4] --> bank number of each store address 
    assign st0_bank_num = st_paddr_0[$clog2(CACHE_LINES_SIZE_B)+$clog2(NUM_WB_ST_QS)-1 : $clog2(CACHE_LINES_SIZE_B)];
    assign st1_bank_num = st_paddr_1[$clog2(CACHE_LINES_SIZE_B)+$clog2(NUM_WB_ST_QS)-1 : $clog2(CACHE_LINES_SIZE_B)];

    bool st0_bank_hit;
    bool st1_bank_hit;

    bool valid_dep0;
    bool valid_dep1;

    // Check each bank's store queue for address matches
    always_comb begin    
    st0_bank_hit = 0;
    st1_bank_hit = 0;
    // Check all entries in each bank's queue
        for(int i = 0; i < ST_Q_DEPTH; i++) begin
            st0_bank_hit |= ((stq_info.entries[st0_bank_num*ST_Q_DEPTH + i].address == st_paddr_0)
                                        & stq_info.entries[st0_bank_num*ST_Q_DEPTH + i].valid);
            
            st1_bank_hit |= ((stq_info.entries[st1_bank_num*ST_Q_DEPTH + i].address == st_paddr_1)
                                        & stq_info.entries[st1_bank_num*ST_Q_DEPTH + i].valid);
        end
    end

    assign valid_dep0 = st0_bank_hit & ST_OP;
    assign valid_dep1 = st1_bank_hit & ST_OP & ST_XCL;

    assign stall = valid_dep0 | valid_dep1;

/*
    structurally this woudl look like the following. 
    We have 16 data addresses and valid bits. 
    We have to mux which ones we want to use based off the bank bits 
    We feed those into 4 comparators. And the comparator outputs of each comparator with the valid bit of the entry
    Or the results together to get the st0_bank hit.

    then duplicate the logic for the eother entry

*/ 

endmodule