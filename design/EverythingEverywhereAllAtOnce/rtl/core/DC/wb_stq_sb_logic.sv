import core_common_pkg::st_q_2_dep_check_outputs_t;
import common_pkg::*;

module wb_stq_sb_logic(
    input bool valid,
    input logic [7:0] ld_paddr_0_offset,
    input logic [7:0] ld_paddr_1_offset,
    input logic [2:0] ld_addr_0_pfn,
    input logic [2:0] ld_addr_1_pfn,
    input bool LD_OP,
    input bool LD_XCL,
    input st_q_2_dep_check_outputs_t stq_info,
    output bool stall
    //probably need to send MIO queue back once I make it
);


    logic [$clog2(NUM_WB_ST_QS)-1:0] ld0_bank_num;
    logic [$clog2(NUM_WB_ST_QS)-1:0] ld1_bank_num;

    //[5:4] --> bank number of each load address
    assign ld0_bank_num = ld_paddr_0_offset[1:0];
    assign ld1_bank_num = ld_paddr_1_offset[1:0];

    bool ld0_bank_hit;
    bool ld1_bank_hit;

    bool valid_dep0;
    bool valid_dep1;

    // Check each bank's store queue for address matches
    always_comb begin    
        ld0_bank_hit = 0;
        ld1_bank_hit = 0;
    // Check all entries in each bank's queue
        for(int i = 0; i < ST_Q_DEPTH; i++) begin
            ld0_bank_hit |= ((stq_info.entries[ld0_bank_num*ST_Q_DEPTH + i].address[11:4] == ld_paddr_0_offset)
                            && (stq_info.entries[ld0_bank_num*ST_Q_DEPTH + i].address[14:12] == ld_addr_0_pfn)
                            & stq_info.entries[ld0_bank_num*ST_Q_DEPTH + i].valid);
            
            ld1_bank_hit |= ((stq_info.entries[ld1_bank_num*ST_Q_DEPTH + i].address[14:4] == ld_paddr_1[14:4])
                                        & stq_info.entries[ld1_bank_num*ST_Q_DEPTH + i].valid);
        end
    end

    assign valid_dep0 = ld0_bank_hit & LD_OP;
    assign valid_dep1 = ld1_bank_hit & LD_OP & LD_XCL;

    assign stall = valid_dep0 | valid_dep1;


endmodule