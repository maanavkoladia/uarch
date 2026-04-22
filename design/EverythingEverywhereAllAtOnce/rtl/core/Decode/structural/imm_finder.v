module imm_finder (
    input [3:0] imm_index,
    input [15:0][7:0] IR,
    output [7:0][7:0] imm64
);
    wire [3:0] idx1, idx2, idx3, idx4, idx5, idx6, idx7;
    assign idx1 = imm_index + 4'd1;
    assign idx2 = imm_index + 4'd2;
    assign idx3 = imm_index + 4'd3;
    assign idx4 = imm_index + 4'd4;
    assign idx5 = imm_index + 4'd5;
    assign idx6 = imm_index + 4'd6;
    assign idx7 = imm_index + 4'd7;

assign imm64 = {IR[idx7], IR[idx6], IR[idx5], IR[idx4],
                IR[idx3], IR[idx2], IR[idx1], IR[imm_index]};

endmodule
