module op_size (
    input [7:0] opcode_byte,
    input zero_f_prefix,
    output needr_m,
    output [2:0] imm_size
);
    wire [2:0] imm_size_regular, other_imm_size;
    wire needrm_regular, needrm_other;

    OP_LUT oplut(
        .needr_m_o(needrm_regular),
        .imm_size2_o(imm_size_regular[2]),
        .imm_size1_o(imm_size_regular[1]),
        .imm_size0_o(imm_size_regular[0]),
        .needr_m_other_o(needrm_other),
        .other_imm_size2_o(other_imm_size[2]),
        .other_imm_size1_o(other_imm_size[1]),
        .other_imm_size0_o(other_imm_size[0]),
        .input7_i(opcode_byte[7]),
        .input6_i(opcode_byte[6]),
        .input5_i(opcode_byte[5]),
        .input4_i(opcode_byte[4]),
        .input3_i(opcode_byte[3]),
        .input2_i(opcode_byte[2]),
        .input1_i(opcode_byte[1]),
        .input0_i(opcode_byte[0])
    );

    assign imm_size = (zero_f_prefix) ? other_imm_size : imm_size_regular;
    assign needr_m = (zero_f_prefix) ? needrm_other : needrm_regular;

endmodule