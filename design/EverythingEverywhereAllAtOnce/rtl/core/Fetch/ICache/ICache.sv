module ICache (
    input wire clk,
    input wire rst,

    //need the tlb input
    //need the Arb input
    input dte_2_icache_t dte_in,
    input tlb_outputs_t  tlb_in,

    //will not need out because $lines in icache can not be modified
    input bus_data_in,



    output icache_fetch_output_t outputs_fetch,
    output logic address_req,
    //need to add req out to scheduler
    output icache_2_scheduler_t req_2_sch
);

    //output logic for the hit

    //instatiate the FSM MODULE, state needs to be exposed for the req_2_sch

endmodule


