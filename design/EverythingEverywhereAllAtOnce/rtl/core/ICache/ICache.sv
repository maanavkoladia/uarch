import common_pkg::*;
import ICache_pkg::*;
import core_common_pkg::tlb_outputs_t;
import core_common_pkg::tlb_outputs_t;

module ICache (
    input wire clk,
    input wire rst,

    input bool en_i,
    input tlb_outputs_t tlb_addr_outs_i,
    input v_address_t v_spc_addr_i,

    //input from dte drive bus tristate, and memvalid for fsm control
    input dte_2_icache_t dte_out_i,

    //if only >= 1 lines valid
    input uint8_t numLinesValidInQ,


    //okay mankey
    inout [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus,
    inout [ADDRESS_BUS_WIDTH_BITS - 1 : 0] addrBus,
    output icache_output_t icache_o
);

    //output logic for the hit

    //instatiate the FSM MODULE, state needs to be exposed for the req_2_sch


    //need schduler req gen logic, idle means no req

endmodule


