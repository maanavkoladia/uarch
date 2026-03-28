module imm_finder (
    input [3:0] imm_index,
    input [15:0][7:0] IR,
    output [7:0][7:0] imm64
);
    wire [3:0] idx1, idx2, idx3, idx4, idx5, idx6, idx7;

assign imm64 = {
    IR[imm_index], IR[idx1], IR[idx2], IR[idx3],
    IR[idx4], IR[idx5], IR[idx6], IR[idx7]};

endmodule
