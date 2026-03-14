import core_stage_latches_pkg::*;

module EXE_Latches (
    input wire clk,
    input wire rst,
    input exe_latches_t nextLatches_i,
    output exe_latches_t latches_o
);
    always_ff @(posedge clk) begin
        if (rst) latches_o <= '0;
        else latches_o <= nextLatches_i;
    end


endmodule
