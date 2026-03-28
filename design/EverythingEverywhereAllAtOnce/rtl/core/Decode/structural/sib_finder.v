module sib_finder (
    input [3:0] modrm_index,
    input [15:0][7:0] IR,
    output [7:0] sib_byte
);
    wire [3:0] sib_index;
    assign sib_index = modrm_index + 1;
    assign sib_byte = IR[sib_index];
endmodule
