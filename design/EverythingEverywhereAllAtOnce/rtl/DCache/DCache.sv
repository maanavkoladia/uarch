import common::*;
import DCache_pkg::*;
import core_common_pkg::st_q_outputs_t;
import core_common_pkg::NUM_WB_ST_QS;

module DCache (
    input wire clk,
    input wire rst,

    //dc
    input bool valid_ld_req,
    input bool XCL,
    input p_address_t p_addy0,
    input p_address_t p_addy1,

    //st_q stuff
    input st_q_outputs_t st_q_req[NUM_WB_ST_QS],
    output bool pop_st_q[NUM_WB_ST_QS],

    //out to mem
    output bool   valid_0,
    output bool   hit_0,
    output byte_t d_cache_line_0[CACHE_LINES_SIZE_B],

    output bool   valid_1,
    output bool   hit_1,
    output byte_t d_cache_line_1[CACHE_LINES_SIZE_B],


    //bus sarb stuff
    output dcache_2_scheduler_t out2Sch,
    input dte_2_dcache_t inFromDTE,


    //buses
    inout [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus,
    inout [ADDRESS_BUS_WIDTH_BITS - 1 : 0] address_bus

);

    //NOTE: While dealing witht eh bank fsm we decided that 
    //hit miss singals will be anded with req_valid signal for the 
    //fsm state machines
    //
    //dcache arb
    //dache blocks
    //need to add bus arb stuff
    //dache bank fsms
    //victim cache
    //eviction bufs

    //
    //create four banks
    //
    bank_req_t banks_reqs[NUM_BANKS];

    //not sure if valid are needed, leaving for now
    //if not XCL, then wait for line_0 to hit, if XCL, wait for both line_0
    //and line_1


endmodule
