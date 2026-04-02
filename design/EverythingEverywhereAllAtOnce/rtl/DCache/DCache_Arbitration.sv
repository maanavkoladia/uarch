import common_pkg::*;
import interconnect_pkg::*;
import DCache_common_pkg::*;

module DCache_Arbitration (

    input wire clk_i,
    input wire rst,    // active low

    // contains store_q data from WB, and ld_reqs from MEM
    input core_2_dcache_t core_i,

    input bool block_hit_i[DCACHE_NUM_BLOCKS],

    //for req rejeced signales
    output bool req_rejected_0_o,
    output bool req_rejected_1_o,

    output block_req_t reqs_2_blocks_o[DCACHE_NUM_BLOCKS],
    output st_override_o[NUM_WB_ST_QS]
);

    localparam int LD_REQ_BANK_UB = DCACHE_BANK_BANK_UB;
    localparam int LD_REQ_BANK_LB = DCACHE_BANK_BANK_LB;
    localparam int LD_REQ_BANK_WIDTH = DCACHE_BANK_BANK_WIDTH;

    block_req_t reqs[DCACHE_NUM_BLOCKS];

    bool block_idleness[DCACHE_NUM_BLOCKS];

    bool readyForNewReq[DCACHE_NUM_BLOCKS];

    //bool ld_AlreadySceduled;

    logic [LD_REQ_BANK_WIDTH - 1 : 0] ld_req_0_bankNum;
    logic [LD_REQ_BANK_WIDTH - 1 : 0] ld_req_1_bankNum;

    // store override: prioritize stores when queue is full
    bool st_override[NUM_WB_ST_QS];

    bool ldReq_2_BankPresent[DCACHE_NUM_BLOCKS];

    assign ld_req_0_bankNum = core_i.ld_addr_0[LD_REQ_BANK_UB:LD_REQ_BANK_LB];
    assign ld_req_1_bankNum = core_i.ld_addr_1[LD_REQ_BANK_UB:LD_REQ_BANK_LB];
    //arb logic
    //
    always_ff @(posedge clk_i) begin
        if (!rst) reqs <= '{default: '0};
        else begin
            //bool ld_willScedule = 0;
            for (int i = 0; i < DCACHE_NUM_BLOCKS; i++) begin
                if (readyForNewReq[i]) begin

                    //store case
                    if (st_override[i] && !core_i.stq_heads[i].empty
                        || (!ldReq_2_BankPresent[i] && !core_i.stq_heads[i].empty)) begin

                        reqs[i] <= '{
                            oe: 0,
                            we: 1,
                            p_addr : core_i.stq_heads[i].address,
                            vec : core_i.stq_heads[i].bit_vec,
                            st_q_data : core_i.stq_heads[i].data
                        };

                    end else  //ld case
                    if (core_i.ld_addr_0_V && ld_req_0_bankNum == i) begin  //bank matches
                        reqs[i] <= '{
                            oe: 1,
                            we: 0,
                            p_addr : core_i.ld_addr_0_V,
                            vec: 0,
                            st_q_data : '{default: '0}
                        };
                    end else if (core_i.ld_addr_1_V && ld_req_1_bankNum == i) begin
                        reqs[i] <= '{
                            oe: 1,
                            we: 0,
                            p_addr : core_i.ld_addr_1_V,
                            vec: 0,
                            st_q_data : '{default: '0}
                        };
                    end else reqs[i] <= '{default: '0};
                end
            end
        end
    end

    // store override logic
    always_ff @(posedge clk_i) begin
        if (!rst) st_override <= '{default: '0};
        else begin
            for (int i = 0; i < NUM_WB_ST_QS; i++) begin
                if (core_i.stq_heads[i].full) st_override[i] <= 1'b1;
                else if (core_i.stq_heads[i].empty) st_override[i] <= 1'b0;
            end
        end
    end

    ////////////INTENRAL SIGNALS///////////////////////////
    // bank idleness: no active request
    always_comb begin
        for (int i = 0; i < DCACHE_NUM_BLOCKS; i++) begin
            block_idleness[i] = !reqs[i].we && !reqs[i].oe;
        end
    end

    //possible issues when MEM is not a MEMOP and it stall on down stream
    //instruction, and DC keeps making the same req
    /*
    This causes a long critical path for the next latch. Our path is now from arb latches thru dcache to hit/miss logic so basically look up time for vcache
    then that signal goes back to stq which the sends out new data which then goes through arbutration to get latched again


    reqs_2_blocks_o[i].oe && block_hit_i[i] && !core_i.memStalling --> we are currently doing a read. It is done and that hit signal has stopped the core from stalling.
    This means that mem was causing the stall and not something downstream

    reqs_2_blocks_o[i].we && block_hit_i[i] -> means that 

    */
    always_comb begin
        for (int i = 0; i < DCACHE_NUM_BLOCKS; i++) begin
            readyForNewReq[i] = (reqs_2_blocks_o[i].oe && block_hit_i[i] && !core_i.memStalling) //this case is if are currently doing a read that 
            || (reqs_2_blocks_o[i].we && block_hit_i[i])
            || block_idleness[i];
        end
    end

    always_comb begin
        if (core_i.ld_addr_0_V && core_i.ld_addr_1_V && ld_req_0_bankNum == ld_req_1_bankNum && rst) $fatal;
        for (int i = 0; i < DCACHE_NUM_BLOCKS; i++) begin
            ldReq_2_BankPresent[i] = (core_i.ld_addr_0_V && ld_req_0_bankNum == i) || (core_i.ld_addr_1_V && ld_req_1_bankNum == i);
        end
    end

    //always_comb begin
    //    ld_AlreadySceduled = 0;
    //    for (int i = 0; i < DCACHE_NUM_BLOCKS; i++)
    //    ld_AlreadySceduled = ld_AlreadySceduled || reqs[i].oe;
    //end


    // output assignment
    assign reqs_2_blocks_o = reqs;
    assign req_rejected_0_o = core_i.ld_addr_0_V && !readyForNewReq[ld_req_0_bankNum];
    assign req_rejected_1_o = core_i.ld_addr_1_V && !readyForNewReq[ld_req_1_bankNum];
    assign st_override_o = st_override;

endmodule
