module ppu (
    input [3:0] opcode_index, modrm_index,
    input [15:0][7:0] IR,
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
    output [3:0][7:0] disp,
    output [7:0][7:0] imm64,
    output inst_valid
);
    wire [2:0] msd_size;
    wire [2:0] imm_size;
    wire disp_size;
    wire disp_needed;
    wire sib_size;
    wire needrm;

    wire sib_size_unmasked;
    wire disp_needed_unmasked;

    assign sib_size = sib_size_unmasked && needrm;
    assign disp_needed = disp_needed_unmasked && needrm;
    
    assign msd_size_o = msd_size;
    assign imm_size_o = imm_size;
    assign disp_size_o = disp_size;
    assign disp_needed_o = disp_needed;
    assign sib_size_o = sib_size;
    assign needrm_o = needrm;

    wire [2:0] imm_size_fake, msd_size_fake;

    wire [3:0] sib_index, imm_index;
    assign sib_index = modrm_index + 1;
    assign imm_index = modrm_index + msd_size;

    wire op_valid, mod_valid, sib_valid;
    wire [3:0] disp_valid;
    wire [3:0][3:0] disp_index;
    wire [7:0] imm_valid;
    wire [7:0][3:0] imm_valid_index;

    op_size opcode_size(.opcode_byte(IR[opcode_index]), .zero_f_prefix(total_pf_vector[1]), .needr_m(needrm), .imm_size(imm_size_fake));
    assign op_valid = IR_valid_vect[opcode_index];

    modrm_size mod_size(.mod_byte(IR[modrm_index]), .msd_size(msd_size_fake), .sib_needed(sib_size_unmasked), .disp_needed(disp_needed_unmasked), .disp_size(disp_size));
    assign mod_valid = needrm ? IR_valid_vect[modrm_index] : 1'b1;

    //mux2_3 immmux(.in0(imm_size_fake), .in1(3'b010), .sel(total_pf_vector[3]), .out(imm_size));
    wire [2:0] imm_size_override;
    `MUX_2(immmux, 3, imm_size_override, imm_size_fake, 3'b010, total_pf_vector[3] && (imm_size_fake == 3'b100))
    `MUX_2(immmux2, 3, imm_size, imm_size_override, 3'b100, total_pf_vector[3] && (imm_size_fake == 3'b110))
    
    //mux2_3 msdmux(.in0(3'b000), .in1(msd_size_fake), .sel(needrm), .out(msd_size));
    `MUX_2(msdmux, 3, msd_size, 3'b000, msd_size_fake, needrm)

    triple_adder adder0 (.in0(num_pfs_plusone), .in1(msd_size), .in2(imm_size), .result(inst_length));

    //8 bit output mut default to valid if not needed for easier bitwise OR
    sib_finder sibfinder0 (.modrm_index(modrm_index), .IR(IR), .sib_byte(sib_byte));
    assign sib_valid = sib_size ? IR_valid_vect[modrm_index + 1'b1] : 1'b1;

    //32 bit output
    disp_finder dispfinder0(.sib_index(sib_index), .sib_size(sib_size), .IR(IR), .disp(disp));

    assign disp_index[0] = sib_index + sib_size;
    assign disp_index[1] = sib_index + sib_size + 4'd1;
    assign disp_index[2] = sib_index + sib_size + 4'd2;
    assign disp_index[3] = sib_index + sib_size + 4'd3;

    assign disp_valid[0] = disp_needed ? IR_valid_vect[disp_index[0]] : 1'b1;
    assign disp_valid[1] = disp_needed && disp_size ? IR_valid_vect[disp_index[1]] : 1'b1;
    assign disp_valid[2] = disp_needed && disp_size ? IR_valid_vect[disp_index[2]] : 1'b1;
    assign disp_valid[3] = disp_needed && disp_size ? IR_valid_vect[disp_index[3]] : 1'b1;

    //64 bit output
    imm_finder immfinder0(.imm_index(imm_index), .IR(IR), .imm64(imm64));

    assign imm_valid_index[0] = imm_index;
    assign imm_valid_index[1] = imm_index + 4'd1;
    assign imm_valid_index[2] = imm_index + 4'd2;
    assign imm_valid_index[3] = imm_index + 4'd3;
    assign imm_valid_index[4] = imm_index + 4'd4;
    assign imm_valid_index[5] = imm_index + 4'd5;
    assign imm_valid_index[6] = imm_index + 4'd6;
    assign imm_valid_index[7] = imm_index + 4'd7;

    assign imm_valid[0] = imm_size > 4'd0 ? IR_valid_vect[imm_valid_index[0]] : 1'b1;
    assign imm_valid[1] = imm_size > 4'd1 ? IR_valid_vect[imm_valid_index[1]] : 1'b1;
    assign imm_valid[2] = imm_size > 4'd2 ? IR_valid_vect[imm_valid_index[2]] : 1'b1;
    assign imm_valid[3] = imm_size > 4'd3 ? IR_valid_vect[imm_valid_index[3]] : 1'b1;
    assign imm_valid[4] = imm_size > 4'd4 ? IR_valid_vect[imm_valid_index[4]] : 1'b1;
    assign imm_valid[5] = imm_size > 4'd5 ? IR_valid_vect[imm_valid_index[5]] : 1'b1;
    assign imm_valid[6] = 1'b1; //never gonna have imm of 7 or 8 bytes so set this valid since its technically not wrong
    assign imm_valid[7] = 1'b1;


    assign inst_valid = &disp_valid && &imm_valid && op_valid && mod_valid && sib_valid;



endmodule
