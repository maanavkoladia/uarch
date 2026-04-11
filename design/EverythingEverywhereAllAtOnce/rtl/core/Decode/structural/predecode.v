module predecode(
    input clk, rst,
    input [63:0][7:0] queue,
    input [3:0] queue_valid,
    input reg [31:0] EIP,
    output reg [31:0] NEIP,
    output [3:0] inst_length,
    output [7:0] sib_byte,
    output sib_size,
    output [7:0] opcode_byte,
    output [7:0] modrm_byte,
    output [31:0] disp,
    output disp_size,
    output disp_needed,
    output [63:0] imm64,
    output [9:0] total_pf_vector,
    output invalid_inst
);

    wire [15:0][7:0] IR; //16 different IR bytes
    wire [15:0] IR_valid_vect;
    wire [3:0][3:0] ppu_inst_length;
    wire [3:0][2:0] ppu_imm_size, ppu_msd_size;
    wire [3:0][7:0] ppu_sib_byte;
    wire [3:0][31:0] ppu_displacement;
    wire [3:0][63:0] ppu_imm;
    wire [3:0] ppu_needrm;
    wire [3:0] ppu_disp_size;
    wire [3:0] ppu_disp_needed;
    wire [3:0] ppu_sib_size;
    wire [1:0] num_pfs;
    wire [9:0] pf_vector0, pf_vector1, pf_vector2;
    wire [31:0] sext_inst_length;
    wire inst_length_cout;
    wire [3:0] inst_valid;
    wire true_inst_valid;
    wire [15:0] adder_cout;
    wire [15:0][31:0] possible_eips;

    assign sext_inst_length = {28'b0, inst_length};

    selection_logic sel_log1(.queue(queue), .queue_valid(queue_valid), .EIP(EIP), .IR(IR), .IR_valid_vect(IR_valid_vect));

    ppu pfs0(.opcode_index(4'd0), .modrm_index(4'd1), .IR(IR), .IR_valid_vect(IR_valid_vect),
        .total_pf_vector(total_pf_vector), .num_pfs_plusone(3'd1),
        .inst_length(ppu_inst_length[0]), .msd_size(ppu_msd_size[0]),
        .imm_size(ppu_imm_size[0]), .disp_size(ppu_disp_size[0]), .disp_needed(ppu_disp_needed[0]), .sib_size(ppu_sib_size[0]), .needrm(ppu_needrm[0]), .sib_byte(ppu_sib_byte[0]), .disp(ppu_displacement[0]), .imm64(ppu_imm[0]),
        .inst_valid(inst_valid[0]));

    ppu pfs1(.opcode_index(4'd1), .modrm_index(4'd2), .IR(IR), .IR_valid_vect(IR_valid_vect),
        .total_pf_vector(total_pf_vector), .num_pfs_plusone(3'd2),
        .inst_length(ppu_inst_length[1]), .msd_size(ppu_msd_size[1]),
        .imm_size(ppu_imm_size[1]), .disp_size(ppu_disp_size[1]), .disp_needed(ppu_disp_needed[1]), .sib_size(ppu_sib_size[1]), .needrm(ppu_needrm[1]), .sib_byte(ppu_sib_byte[1]), .disp(ppu_displacement[1]), .imm64(ppu_imm[1]),
        .inst_valid(inst_valid[1]));

    ppu pfs2(.opcode_index(4'd2), .modrm_index(4'd3), .IR(IR), .IR_valid_vect(IR_valid_vect),
        .total_pf_vector(total_pf_vector), .num_pfs_plusone(3'd3),
        .inst_length(ppu_inst_length[2]), .msd_size(ppu_msd_size[2]),
        .imm_size(ppu_imm_size[2]), .disp_size(ppu_disp_size[2]), .disp_needed(ppu_disp_needed[2]), .sib_size(ppu_sib_size[2]), .needrm(ppu_needrm[2]), .sib_byte(ppu_sib_byte[2]), .disp(ppu_displacement[2]), .imm64(ppu_imm[2]),
        .inst_valid(inst_valid[2]));

    ppu pfs3(.opcode_index(4'd3), .modrm_index(4'd4), .IR(IR), .IR_valid_vect(IR_valid_vect),
        .total_pf_vector(total_pf_vector), .num_pfs_plusone(3'd4),
        .inst_length(ppu_inst_length[3]), .msd_size(ppu_msd_size[3]),
        .imm_size(ppu_imm_size[3]), .disp_size(ppu_disp_size[3]), .disp_needed(ppu_disp_needed[3]), .sib_size(ppu_sib_size[3]), .needrm(ppu_needrm[3]), .sib_byte(ppu_sib_byte[3]), .disp(ppu_displacement[3]), .imm64(ppu_imm[3]),
        .inst_valid(inst_valid[3]));

    // mux4_4 length_mux(.in0(ppu_inst_length[0]), .in1(ppu_inst_length[1]), .in2(ppu_inst_length[2]), .in3(ppu_inst_length[3]), 
    //     .sel0(num_pfs[0]), .sel1(num_pfs[1]), .out(inst_length));
    // mux4_8$ sib_mux(.IN0(ppu_sib_byte[0]), .IN1(ppu_sib_byte[1]), .IN2(ppu_sib_byte[2]), .IN3(ppu_sib_byte[3]), 
    //     .S0(num_pfs[0]), .S1(num_pfs[1]), .Y(sib_byte));
    // mux4_8$ opcode_mux(.IN0(IR[0]), .IN1(IR[1]), .IN2(IR[2]), .IN3(IR[3]), 
    //     .S0(num_pfs[0]), .S1(num_pfs[1]), .Y(opcode_byte));
    // mux4_8$ modrm_mux(.IN0(IR[1]), .IN1(IR[2]), .IN2(IR[3]), .IN3(IR[4]), 
    //     .S0(num_pfs[0]), .S1(num_pfs[1]), .Y(modrm_byte));
    // mux4_32 disp_mux(.in0(ppu_displacement[0]), .in1(ppu_displacement[1]), .in2(ppu_displacement[2]), .in3(ppu_displacement[3]), 
    //     .sel0(num_pfs[0]), .sel1(num_pfs[1]), .out(disp));
    // mux4$ disp_size_mux(.in0(ppu_disp_size[0]), .in1(ppu_disp_size[1]), .in2(ppu_disp_size[2]), .in3(ppu_disp_size[3]), 
    //     .s0(num_pfs[0]), .s1(num_pfs[1]), .outb(disp_size));
    // mux4$ disp_needed_mux(.in0(ppu_disp_needed[0]), .in1(ppu_disp_needed[1]), .in2(ppu_disp_needed[2]), .in3(ppu_disp_needed[3]), 
    //     .s0(num_pfs[0]), .s1(num_pfs[1]), .outb(disp_needed));
    // mux4_64 imm_mux(.in0(ppu_imm[0]), .in1(ppu_imm[1]), .in2(ppu_imm[2]), .in3(ppu_imm[3]),
    //     .sel0(num_pfs[0]), .sel1(num_pfs[1]), .out(imm64));
    // mux4$ valid_inst_mux(.in0(inst_valid[0]), .in1(inst_valid[1]), .in2(inst_valid[2]),
    //     .in3(inst_valid[3]), .s0(num_pfs[0]), .s1(num_pfs[1]), .outb(true_inst_valid));
    // mux4$ sib_size_mux(.in0(ppu_sib_size[0]), .in1(ppu_sib_size[1]), .in2(ppu_sib_size[2]), .in3(ppu_sib_size[3]), 
    //     .s0(num_pfs[0]), .s1(num_pfs[1]), .outb(sib_size));

    // =====================
    // Instruction length (4-bit)
    // =====================
    `MUX_4(length_mux, 4, inst_length, ppu_inst_length[0], ppu_inst_length[1], ppu_inst_length[2],
        ppu_inst_length[3], {num_pfs[1], num_pfs[0]})

    // =====================
    // SIB byte (8-bit)
    // =====================
    `MUX_4(sib_mux, 8, sib_byte, ppu_sib_byte[0], ppu_sib_byte[1], ppu_sib_byte[2], ppu_sib_byte[3],
        {num_pfs[1], num_pfs[0]})

    // =====================
    // Opcode byte (8-bit)
    // =====================
    `MUX_4(opcode_mux, 8, opcode_byte, IR[0], IR[1], IR[2],
        IR[3], {num_pfs[1], num_pfs[0]})

    // =====================
    // ModRM byte (8-bit)
    // =====================
    `MUX_4(modrm_mux, 8, modrm_byte, IR[1], IR[2], IR[3],
        IR[4], {num_pfs[1], num_pfs[0]})

    // =====================
    // Displacement (32-bit)
    // =====================
    `MUX_4(disp_mux, 32, disp, ppu_displacement[0], ppu_displacement[1], ppu_displacement[2],
        ppu_displacement[3], {num_pfs[1], num_pfs[0]})

    // =====================
    // Displacement size (1-bit)
    // =====================
    `MUX_4(disp_size_mux, 1, disp_size, ppu_disp_size[0], ppu_disp_size[1], ppu_disp_size[2],
        ppu_disp_size[3], {num_pfs[1], num_pfs[0]})

    // =====================
    // Displacement needed (1-bit)
    // =====================
    `MUX_4(disp_needed_mux, 1, disp_needed, ppu_disp_needed[0], ppu_disp_needed[1], ppu_disp_needed[2],
        ppu_disp_needed[3], {num_pfs[1], num_pfs[0]})

    // =====================
    // Immediate (64-bit)
    // =====================
    `MUX_4(imm_mux, 64, imm64, ppu_imm[0], ppu_imm[1], ppu_imm[2],
        ppu_imm[3], {num_pfs[1], num_pfs[0]})

    // =====================
    // Valid instruction (1-bit)
    // =====================
    `MUX_4(valid_inst_mux, 1, true_inst_valid, inst_valid[0], inst_valid[1], inst_valid[2],
        inst_valid[3], {num_pfs[1], num_pfs[0]})

    // =====================
    // SIB size (1-bit)
    // =====================
    `MUX_4(sib_size_mux, 1, sib_size, ppu_sib_size[0], ppu_sib_size[1], ppu_sib_size[2],
        ppu_sib_size[3], {num_pfs[1], num_pfs[0]})

    assign invalid_inst = !true_inst_valid;

    wire pf0, pf1, pf2;
    pf_checker checker0(.IRbyte(IR[0]), .pf(pf0), .pf_vector(pf_vector0));
    pf_checker checker1(.IRbyte(IR[1]), .pf(pf1), .pf_vector(pf_vector1));
    pf_checker checker2(.IRbyte(IR[2]), .pf(pf2), .pf_vector(pf_vector2));
    num_pf_gen num_pf_gen0(pf0, pf1 ,pf2, num_pfs);
    pf_vector_gen vec_gen(.pfs(num_pfs), .pf_vector0(pf_vector0), .pf_vector1(pf_vector1), .pf_vector2(pf_vector2), 
        .total_pf_vector(total_pf_vector));

    //kogge_stone_adder #(.WIDTH(32)) neip_adder (.a(EIP), .b(sext_inst_length), .cin(1'b0), .sum(NEIP), .cout(inst_length_cout));
    
    assign possible_eips[0] = EIP;
    genvar i;
    generate
        for (i = 1; i < 16; i++) begin : possible_eip_adders
            kogge_stone_adder #(
                .WIDTH(32)
            ) IR_index_adder (
                .a   (EIP),
                .b   (32'(i)),       // cast loop index to 6-bit
                .cin (1'b0),
                .sum (possible_eips[i]),
                .cout(adder_cout[i])             // unused
            );
        end
    endgenerate 

    //mux16_32 neip_picker_mux(.in(possible_eips), .sel0(inst_length[0]), .sel1(inst_length[1]), .sel2(inst_length[2]), .sel3(inst_length[3]), .out(NEIP));
    `MUX_16(neip_picker_mux, 32, NEIP, 
        possible_eips[0], possible_eips[1], possible_eips[2], possible_eips[3], 
        possible_eips[4], possible_eips[5], possible_eips[6], possible_eips[7], 
        possible_eips[8], possible_eips[9], possible_eips[10], possible_eips[11], 
        possible_eips[12], possible_eips[13], possible_eips[14], possible_eips[15], 
        {inst_length[3], inst_length[2], inst_length[1], inst_length[0]})

endmodule