import core_stage_latches_pkg::*;

module WB_Latches (
    input wire clk,
    input wire rst,
    input wb_latches_t nextLatches_i,
    input wire write_enable_i,
    output wb_latches_t latches_o
);

    wb_latches_t latches;

    assign latches_o = latches;
    always_ff @(posedge clk) begin
        if (!rst) latches <= ('{default: 0});
        else if (write_enable_i) latches <= nextLatches_i;
    end

endmodule
