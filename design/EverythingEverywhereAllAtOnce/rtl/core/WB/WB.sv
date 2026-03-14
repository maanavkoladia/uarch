module WB (
    input wire clk,
    input wire rst,

    input wb_latches_t wb_latches,

    //D$ write success for st_qs
    input bool write_Success[NUM_WB_ST_QS],

    output wb_outputs_t outputs
);


    //need to write_Success from D$ to inputs into st_qs
    //
    //

endmodule
