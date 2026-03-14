import common::*;
import DCache_pkg::*;
import core_common_pkg::st_q_outputs_t;
import core_common_pkg::NUM_WB_ST_QS;

module DCache (
    input wire clk,
    input wire rst,

    //dc
    input core_2_dcache_t inFromCore_i,

    output dcache_2_core_t out2Core_o,

    //bus sarb stuff
    input dte_2_dcache_t inFromDTE_i,
    output dcache_2_scheduler_t out2Sch_o,


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
    //st overide needs to be set here
    //
    //create four banks
    //
    bank_req_t banks_reqs[NUM_BANKS];

    //not sure if valid are needed, leaving for now
    //if not XCL, then wait for line_0 to hit, if XCL, wait for both line_0
    //and line_1
    //note dache will send four block reqs to scheduler

endmodule
