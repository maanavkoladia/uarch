import core_stage_latches_pkg::*;

module DC_Latches (
    input  wire clk,
    input  wire rst,
    input  dc_latches_t nextLatches_i,
    output dc_latches_t latches_o
);
    dc_latches_t latches;

    assign latches_o = latches;
    always_ff @(posedge clk) begin
        if (rst) latches <= ('{default:0});
        else     latches <= nextLatches_i;
    end
    
endmodule
