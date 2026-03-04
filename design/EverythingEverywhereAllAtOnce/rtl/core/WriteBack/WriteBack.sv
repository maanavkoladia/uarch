module WriteBack (
    input wire clk,
    input wire rst,

    input wb_stage_latches_t WB_Latches,


    //D$ write success
    input write_Success[NUM_WB_ST_QS],

    output wb_outputs_t outputs

);


    //need to write_Success from D$ to inputs into st_qs


endmodule
