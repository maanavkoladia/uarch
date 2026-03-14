import core_stage_latches_pkg::*;

module EXE_Latches (
    input wire clk,
    input wire rst,
    input exe_latches_t nextLatches_i,
    output exe_latches_t latches_o
);

    exe_latches_t latches;

    assign latches_o = latches;
    always_ff @(posedge clk) begin
        if (rst) latches <= ('{default:0});
        else     latches <= nextLatches_i;
    end


endmodule
