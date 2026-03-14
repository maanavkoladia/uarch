import common_pkg::*;
import ICache_pkg::*;
import interconnect_pkg::*;

module ICache (
    input wire clk,
    input wire rst,

    //
    input  core_2_icache_t inFromCore_i,
    output icache_2_core_t out2Core_o,

    //input from dte drive bus tristate, and memvalid for fsm control
    input dte_2_icache_t dte_out_i,
    output icache_2_scheduler_t out2Sch_o,

    //okay mankey
    inout [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus,
    inout [ADDRESS_BUS_WIDTH_BITS - 1 : 0] addrBus
);

    //output logic for the hit

    //instatiate the FSM MODULE, state needs to be exposed for the req_2_sch


    //need schduler req gen logic, idle means no req

endmodule


