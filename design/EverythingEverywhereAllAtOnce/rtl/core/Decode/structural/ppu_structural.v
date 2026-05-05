module ppu (
    input [3:0] modrm_index, sib_index,
    input [127:0] IR,
    input [7:0] opcode_byte,         // pre-selected IR byte at opcode_index
    input [7:0] modrm_byte,          // pre-selected IR byte at modrm_index
    input total_pf_vector_1,         //total_pf_vector[1] (0f prefix)
    input total_pf_vector_3,         //total_pf_vector[3] (66 prefix)
    input [2:0] num_pfs_plusone,
    output [3:0] inst_length,
    output [2:0] msd_size_o,
    output [2:0] imm_size_o,
    output disp_size_o,
    output disp_needed_o,
    output sib_size_o,
    output needrm_o,
    output [7:0] sib_byte,
    output [31:0] disp,
    output [63:0] imm64
);
    wire [2:0] msd_size;
    wire [2:0] imm_size;
    wire disp_size;
    wire disp_needed;
    wire sib_size;
    wire needrm;

    assign msd_size_o = msd_size;
    assign imm_size_o = imm_size;
    assign disp_size_o = disp_size;
    assign disp_needed_o = disp_needed;
    assign sib_size_o = sib_size;
    assign needrm_o = needrm;

    wire sib_size_unmasked;
    wire disp_needed_unmasked;

    `AND_2(sib_size_and, 1, sib_size, sib_size_unmasked, needrm)
    `AND_2(disp_needed_and, 1, disp_needed, disp_needed_unmasked, needrm)
    
    

    wire [2:0] imm_size_fake, msd_size_fake;

    wire [3:0] imm_index;
    wire imm_index_cout;
    //assign imm_index = modrm_index + msd_size;
    `ADD_N(imm_index_adder, 4, imm_index, imm_index_cout, modrm_index, {1'b0, msd_size}, 1'b0)


    op_size opcode_size(.opcode_byte(opcode_byte), .zero_f_prefix(total_pf_vector_1), .needr_m(needrm), .imm_size(imm_size_fake));

    modrm_size mod_size(.mod_byte(modrm_byte), .msd_size(msd_size_fake), .sib_needed(sib_size_unmasked), .disp_needed(disp_needed_unmasked), .disp_size(disp_size));

    //mux2_3 immmux(.in0(imm_size_fake), .in1(3'b010), .sel(total_pf_vector_3), .out(imm_size));
    wire [2:0] imm_size_override;
    wire imm_size_eq_100, imm_size_eq_110;
    wire immmux_sel, immmux2_sel;
    `CMP_N(imm_size_eq_100_cmp, 3, imm_size_eq_100, imm_size_fake, 3'b100)
    `CMP_N(imm_size_eq_110_cmp, 3, imm_size_eq_110, imm_size_fake, 3'b110)
    `AND_2(immmux_sel_and,  1, immmux_sel,  total_pf_vector_3, imm_size_eq_100)
    `AND_2(immmux2_sel_and, 1, immmux2_sel, total_pf_vector_3, imm_size_eq_110)
    `MUX_2(immmux,  3, imm_size_override, imm_size_fake,     3'b010, immmux_sel)
    `MUX_2(immmux2, 3, imm_size,          imm_size_override, 3'b100, immmux2_sel)
    
    //mux2_3 msdmux(.in0(3'b000), .in1(msd_size_fake), .sel(needrm), .out(msd_size));
    `MUX_2(msdmux, 3, msd_size, 3'b000, msd_size_fake, needrm)

    triple_adder adder0 (.pfs_plus_one(num_pfs_plusone), .msd_size(msd_size), .imm_size(imm_size), .result(inst_length));

    sib_finder sibfinder0 (.modrm_index(modrm_index), .IR(IR), .sib_byte(sib_byte));

    //32 bit output
    disp_finder dispfinder0(.sib_index(sib_index), .sib_size(sib_size), .IR(IR), .disp(disp));
    wire [3:0] disp_adder_cout;

    imm_finder immfinder0(.imm_index(imm_index), .IR(IR), .imm64(imm64));

endmodule
