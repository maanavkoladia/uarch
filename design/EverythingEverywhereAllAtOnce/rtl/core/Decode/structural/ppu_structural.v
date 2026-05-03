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
    output [63:0] imm64,
    output inst_valid
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


    //assign disp_index[0] = sib_index + sib_size;
    //assign disp_index[1] = sib_index + sib_size + 4'd1;
    //assign disp_index[2] = sib_index + sib_size + 4'd2;
    //assign disp_index[3] = sib_index + sib_size + 4'd3;
    `ADD_N(disp_index0_adder, 4, disp_index[0], disp_adder_cout[0], sib_index, {3'b0, sib_size}, 1'b0)
    `ADD_N(disp_index1_adder, 4, disp_index[1], disp_adder_cout[1], disp_index[0], 4'd1, 1'b0)
    `ADD_N(disp_index2_adder, 4, disp_index[2], disp_adder_cout[2], disp_index[0], 4'd2, 1'b0)
    `ADD_N(disp_index3_adder, 4, disp_index[3], disp_adder_cout[3], disp_index[0], 4'd3, 1'b0)


    //assign disp_valid[0] = disp_needed ? IR_valid_vect[disp_index[0]] : 1'b1;
    //assign disp_valid[1] = disp_needed && disp_size ? IR_valid_vect[disp_index[1]] : 1'b1;
    //assign disp_valid[2] = disp_needed && disp_size ? IR_valid_vect[disp_index[2]] : 1'b1;
    //assign disp_valid[3] = disp_needed && disp_size ? IR_valid_vect[disp_index[3]] : 1'b1;
    wire disp32_needed;
    `AND_2(disp32_needed_and, 1, disp32_needed, disp_needed, disp_size)
    `MUX_2(disp_valid0_mux, 1, disp_valid[0], 1'b1, IR_valid_vect[disp_index[0]], disp_needed)
    `MUX_2(disp_valid1_mux, 1, disp_valid[1], 1'b1, IR_valid_vect[disp_index[1]], disp32_needed)
    `MUX_2(disp_valid2_mux, 1, disp_valid[2], 1'b1, IR_valid_vect[disp_index[2]], disp32_needed)
    `MUX_2(disp_valid3_mux, 1, disp_valid[3], 1'b1, IR_valid_vect[disp_index[3]], disp32_needed)



// imm_valid_index[0..7] = imm_index + N
    `ADD_N(imm_valid_index0_adder, 4, imm_valid_index[0], imm_idx_cout[0], imm_index, 4'd0, 1'b0)
    `ADD_N(imm_valid_index1_adder, 4, imm_valid_index[1], imm_idx_cout[1], imm_index, 4'd1, 1'b0)
    `ADD_N(imm_valid_index2_adder, 4, imm_valid_index[2], imm_idx_cout[2], imm_index, 4'd2, 1'b0)
    `ADD_N(imm_valid_index3_adder, 4, imm_valid_index[3], imm_idx_cout[3], imm_index, 4'd3, 1'b0)
    `ADD_N(imm_valid_index4_adder, 4, imm_valid_index[4], imm_idx_cout[4], imm_index, 4'd4, 1'b0)
    `ADD_N(imm_valid_index5_adder, 4, imm_valid_index[5], imm_idx_cout[5], imm_index, 4'd5, 1'b0)
    `ADD_N(imm_valid_index6_adder, 4, imm_valid_index[6], imm_idx_cout[6], imm_index, 4'd6, 1'b0)
    `ADD_N(imm_valid_index7_adder, 4, imm_valid_index[7], imm_idx_cout[7], imm_index, 4'd7, 1'b0)

    // No GT macro exists, so implement imm_size > N with gate-level boolean reduction:
    //   > 0  =>  |imm_size           (any bit set)
    //   > 1  =>  imm_size[2:1] != 0  (bit1 or higher)
    //   > 2  =>  [2] | ([1] & [0])
    //   > 3  =>  [2] | [1]
    //   > 4  =>  [2] & ([1] | [0])
    //   > 5  =>  [2] & [1]

    wire imm_size_gt0, imm_size_gt1;
    wire imm_size_gt2, imm_size_gt2_and;
    wire imm_size_gt3;
    wire imm_size_gt4, imm_size_gt4_inner_or;
    wire imm_size_gt5;

    `OR_3(imm_gt0_or,          1, imm_size_gt0,          imm_size[0], imm_size[1], imm_size[2])
    `OR_2(imm_gt1_or,          1, imm_size_gt1,          imm_size[1], imm_size[2])
    `AND_2(imm_gt2_and,        1, imm_size_gt2_and,      imm_size[0], imm_size[1])
    `OR_2(imm_gt2_or,          1, imm_size_gt2,          imm_size_gt2_and, imm_size[2])
    `OR_2(imm_gt3_or,          1, imm_size_gt3,          imm_size[1], imm_size[2])
    `OR_2(imm_gt4_inner_or,    1, imm_size_gt4_inner_or, imm_size[0], imm_size[1])
    `AND_2(imm_gt4_and,        1, imm_size_gt4,          imm_size[2], imm_size_gt4_inner_or)
    `AND_2(imm_gt5_and,        1, imm_size_gt5,          imm_size[1], imm_size[2])

    `MUX_2(imm_valid0_mux, 1, imm_valid[0], 1'b1, IR_valid_vect[imm_valid_index[0]], imm_size_gt0)
    `MUX_2(imm_valid1_mux, 1, imm_valid[1], 1'b1, IR_valid_vect[imm_valid_index[1]], imm_size_gt1)
    `MUX_2(imm_valid2_mux, 1, imm_valid[2], 1'b1, IR_valid_vect[imm_valid_index[2]], imm_size_gt2)
    `MUX_2(imm_valid3_mux, 1, imm_valid[3], 1'b1, IR_valid_vect[imm_valid_index[3]], imm_size_gt3)
    `MUX_2(imm_valid4_mux, 1, imm_valid[4], 1'b1, IR_valid_vect[imm_valid_index[4]], imm_size_gt4)
    `MUX_2(imm_valid5_mux, 1, imm_valid[5], 1'b1, IR_valid_vect[imm_valid_index[5]], imm_size_gt5)
    assign imm_valid[6] = 1'b1;
    assign imm_valid[7] = 1'b1;

    // inst_valid = &disp_valid && &imm_valid && op_valid && mod_valid && sib_valid
    // imm_valid[6] and [7] are tied 1'b1 so excluded from AND reduction
    wire disp_valid_all, imm_valid_all;
    `AND_4(disp_valid_and, 1, disp_valid_all, disp_valid[0], disp_valid[1], disp_valid[2], disp_valid[3])
    `AND_6(imm_valid_and,  1, imm_valid_all,  imm_valid[0], imm_valid[1], imm_valid[2], imm_valid[3], imm_valid[4], imm_valid[5])
    `AND_5(inst_valid_and, 1, inst_valid,     disp_valid_all, imm_valid_all, op_valid, mod_valid, sib_valid)



endmodule
