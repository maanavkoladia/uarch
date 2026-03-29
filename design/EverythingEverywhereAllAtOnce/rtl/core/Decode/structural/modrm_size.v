module modrm_size (
    input [7:0] mod_byte,
    output [2:0] msd_size,
    output sib_needed,
    output disp_needed,
    output disp_size
);

    MOD_LUT modlut(
        .msd_size_2_o(msd_size[2]),
        .msd_size_1_o(msd_size[1]),
        .msd_size_0_o(msd_size[0]),
        .input_7_i(mod_byte[7]),
        .input_6_i(mod_byte[6]),
        .input_5_i(mod_byte[5]),
        .input_4_i(mod_byte[4]),
        .input_3_i(mod_byte[3]),
        .input_2_i(mod_byte[2]),
        .input_1_i(mod_byte[1]),
        .input_0_i(mod_byte[0]),
    );

endmodule
