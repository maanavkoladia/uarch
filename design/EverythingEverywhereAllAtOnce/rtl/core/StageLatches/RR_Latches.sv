import core_stage_latches_pkg::*;

module RR_Latches (
    input wire clk,
    input wire rst,
    input rr_latches_t nextLatches_i,
    input wire write_enable_i,
    input wire flush,
    input wire farFlush,
    output rr_latches_t latches_o
);
    rr_latches_t latches;


    assign latches_o = latches;
    always_ff @(posedge clk) begin
        if (!rst) latches <= ('{default:0});
        else if(flush || farFlush) latches <= '{default:0};
        else if(write_enable_i) latches <= nextLatches_i;
        else latches <= latches;
    end

endmodule
