module imm_finder (
    input [3:0] imm_index,
    input [127:0] IR,
    output [63:0] imm64
);
    assign imm64 = IR[imm_index*8 +: 64];

endmodule
