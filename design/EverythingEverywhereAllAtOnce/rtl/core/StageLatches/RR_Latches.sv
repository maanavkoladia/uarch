import core_stage_latches_pkg::*;

module RR_Latches (
    input wire clk,
    input wire rst,
    input rr_latches_t nextLatches_i,
    output rr_latches_t latches_o
);
    always_ff @(posedge clk) begin
        if (rst) latches_o <= '0;
        else latches_o <= nextLatches_i;
    end


endmodule
