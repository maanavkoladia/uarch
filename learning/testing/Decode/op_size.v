module op_size (
    input [7:0] opcode_byte,
    output needr_m,
    output [2:0] imm_size
);

    OP_LUT oplut(
        .needrm_o(needr_m),
        .imm_size_2_o(imm_size[2]),
        .imm_size_1_o(imm_size[1]),
        .imm_size_0_o(imm_size[0]),
        .input_7_i(opcode_byte[7]),
        .input_6_i(opcode_byte[6]),
        .input_5_i(opcode_byte[5]),
        .input_4_i(opcode_byte[4]),
        .input_3_i(opcode_byte[3]),
        .input_2_i(opcode_byte[2]),
        .input_1_i(opcode_byte[1]),
        .input_0_i(opcode_byte[0])
    );
    
endmodule