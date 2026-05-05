module ppu (
    input [3:0] opcode_index, modrm_index, sib_index,
    input [127:0] IR,
    input [15:0] IR_valid_vect,
    input [9:0] total_pf_vector,     //MSB --> 2e, 36, 3e, 26, 64, 65, 66, 67, 0f, f3  <-- LSB vector
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


    wire op_valid, mod_valid, sib_valid;
    wire [3:0] disp_valid;
    wire [3:0] disp_index [0:3];
    wire [7:0] imm_valid;
    wire [3:0] imm_valid_index[0:7];
    wire [7:0] imm_idx_cout;

    op_size opcode_size(.opcode_byte(IR[opcode_index*8 +: 8]), .zero_f_prefix(total_pf_vector[1]), .needr_m(needrm), .imm_size(imm_size_fake));
    assign op_valid = IR_valid_vect[opcode_index];

    modrm_size mod_size(.mod_byte(IR[modrm_index*8 +: 8]), .msd_size(msd_size_fake), .sib_needed(sib_size_unmasked), .disp_needed(disp_needed_unmasked), .disp_size(disp_size));
    `MUX_2(mod_valid_mux, 1, mod_valid, 1'b1, IR_valid_vect[modrm_index], needrm)


    //mux2_3 immmux(.in0(imm_size_fake), .in1(3'b010), .sel(total_pf_vector[3]), .out(imm_size));
    wire [2:0] imm_size_override;
    `MUX_2(immmux, 3, imm_size_override, imm_size_fake, 3'b010, total_pf_vector[3] && (imm_size_fake == 3'b100))
    `MUX_2(immmux2, 3, imm_size, imm_size_override, 3'b100, total_pf_vector[3] && (imm_size_fake == 3'b110))
    
    //mux2_3 msdmux(.in0(3'b000), .in1(msd_size_fake), .sel(needrm), .out(msd_size));
    `MUX_2(msdmux, 3, msd_size, 3'b000, msd_size_fake, needrm)

    triple_adder adder0 (.pfs_plus_one(num_pfs_plusone), .msd_size(msd_size), .imm_size(imm_size), .result(inst_length));

    //8 bit output mut default to valid if not needed for easier bitwise OR
    sib_finder sibfinder0 (.modrm_index(modrm_index), .IR(IR), .sib_byte(sib_byte));
    `MUX_2(sib_valid_mux, 1, sib_valid, 1'b1, IR_valid_vect[sib_index], sib_size)



    //32 bit output
    disp_finder dispfinder0(.sib_index(sib_index), .sib_size(sib_size), .IR(IR), .disp(disp));
    wire [3:0] disp_adder_cout;

    imm_finder immfinder0(.imm_index(imm_index), .IR(IR), .imm64(imm64));

endmodule
