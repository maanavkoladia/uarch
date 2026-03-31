module modrm_size (
    input [7:0] mod_byte,
    output [2:0] msd_size,
    output sib_needed,
    output disp_needed,
    output disp_size
);

    MOD_LUT modlut(
        .msd_size2_o(msd_size[2]),
        .msd_size1_o(msd_size[1]),
        .msd_size0_o(msd_size[0]),
        .sib_needed_o(sib_needed),
        .disp_needed_o(disp_needed),
        .disp_size_o(disp_size),
        .input7_i(mod_byte[7]),
        .input6_i(mod_byte[6]),
        .input5_i(mod_byte[5]),
        .input4_i(mod_byte[4]),
        .input3_i(mod_byte[3]),
        .input2_i(mod_byte[2]),
        .input1_i(mod_byte[1]),
        .input0_i(mod_byte[0])
    );

endmodule
