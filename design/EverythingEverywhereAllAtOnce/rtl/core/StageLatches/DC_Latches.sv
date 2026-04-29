import core_stage_latches_pkg::*;

module DC_Latches (
    input  wire clk,
    input  wire rst,
    input  dc_latches_t nextLatches_i,
    input wire write_enable_i,
    input wire flush,
    input wire farFlush,
    input wire exp_pipe_clear,
    output dc_latches_t latches_o
);
    dc_latches_t latches;

    assign latches_o = latches;
    always_ff @(posedge clk) begin
        if (!rst) latches <= ('{default:0});
        else if(flush || farFlush || exp_pipe_clear) latches <= '{default:0};
        else if(write_enable_i) latches <= nextLatches_i;
        else latches <= latches;
    end
    
endmodule
