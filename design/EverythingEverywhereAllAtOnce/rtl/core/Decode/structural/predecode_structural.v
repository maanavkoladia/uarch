module predecode(
    input clk, rst,
    input [511:0] queue,
    input [3:0] queue_valid,
    input [31:0] EIP,
    output [31:0] NEIP,
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
    output invalid_inst,

    input seg_override,
    input [`REG_ID_W-1:0] seg0,

    output wire decode_cs_REP,
    output wire decode_cs_REP_CMP,
    output wire decode_cs_HALT,
    output wire decode_cs_MODRM_NEEDED,
    output wire decode_cs_RM_IS_DR,
    output wire decode_cs_REG_IS_DR,
    output wire decode_cs_REG_IS_SEGMENT,
    output wire decode_cs_HARDCODED_DR_HIGH8,
    output wire decode_cs_MODRM_BUT_NO_SR,
    output wire decode_cs_HARDCODED_DR,
    output wire [`REG_ID_W-1:0] decode_cs_HARDCODED_DR_ID,
    output wire decode_cs_HARDCODED_SR,
    output wire [`REG_ID_W-1:0] decode_cs_HARDCODED_SR_ID,
    output wire decode_cs_HARDCODED_DR_RD,
    output wire decode_cs_HARDCODED_DR_WR,
    output wire decode_cs_HARDCODED_SR_RD,
    output wire decode_cs_HARDCODED_SR_WR,
    output wire decode_cs_HARDCODED_LD_OP,
    output wire decode_cs_HARDCODED_ST_OP,
    output wire decode_cs_LD_OP_CANCEL,
    output wire decode_cs_ST_OP_CANCEL,
    output wire decode_cs_OP_IN_MODRM,
    output wire [1:0] decode_cs_DATA_SIZE,
    output wire rr_cs_ST_SEL,
    output wire rr_cs_MODRM_NEEDED,
    output wire rr_cs_RM_IS_DR,
    output wire rr_cs_SWITCH_LD_ADDY,
    output wire rr_cs_LD_OP,
    output wire rr_cs_ST_OP,
    output wire [`REG_ID_W-1:0] rr_cs_dr_id,
    output wire [`REG_ID_W-1:0] rr_cs_sr_id,
    output wire rr_cs_dr_rd,
    output wire rr_cs_sr_rd,
    output wire rr_cs_eax_rd,
    output wire rr_cs_dr_wr,
    output wire rr_cs_sr_wr,
    output wire rr_cs_eax_wr,
    output wire rr_cs_MOVS_OP,
    output wire [1:0] rr_cs_datasize,
    output wire rr_cs_will_mod_zf,
    output wire rr_cs_seg_1_valid,
    output wire [`REG_ID_W-1:0] rr_cs_seg_0_id,
    output wire [`REG_ID_W-1:0] rr_cs_seg_1_id,
    output wire rr_cs_special_modrm_bs,
    output wire rr_cs_special_br,
    output wire dc_cs_LD_OP,
    output wire dc_cs_ST_OP,
    output wire dc_cs_dr_upper8,
    output wire dc_cs_sr_upper8,
    output wire [1:0] dc_cs_datasize,
    output wire mem_cs_ST_OP,
    output wire mem_cs_LD_OP,
    output wire exe_cs_ST_OP,
    output wire [`EXE_OP_W-1:0] exe_cs_OP_TYPE,
    output wire [`SRC_SEL_W-1:0] exe_cs_alu_inputA_sel,
    output wire [`SRC_SEL_W-1:0] exe_cs_alu_inputB_sel,
    output wire [`SRC_SEL_W-1:0] exe_cs_branch_target_sel,
    output wire exe_cs_shift_by_one,
    output wire exe_cs_br_ucond,
    output wire exe_cs_relative_branch,
    output wire exe_cs_special_br,
    output wire exe_cs_is_far,
    output wire exe_cs_is_call,
    output wire exe_cs_second_flag_needed,
    output wire exe_cs_rep_no_zf_update,
    output wire wb_cs_ST_OP,
    output wire wb_cs_WB_DR,
    output wire wb_cs_WB_SR,
    output wire wb_cs_WB_EAX
);


    wire [127:0] IR; //16 byte
    // per-pf-combo outputs (suffix _<pf1><pf3>) — driven by the parallel ppu instances pfs<i>_<bb>
    wire [3:0]  ppu_inst_length_00[0:3], ppu_inst_length_01[0:3], ppu_inst_length_10[0:3], ppu_inst_length_11[0:3];
    wire [2:0]  ppu_imm_size_00[0:3],    ppu_imm_size_01[0:3],    ppu_imm_size_10[0:3],    ppu_imm_size_11[0:3];
    wire [2:0]  ppu_msd_size_00[0:3],    ppu_msd_size_01[0:3],    ppu_msd_size_10[0:3],    ppu_msd_size_11[0:3];
    wire [7:0]  ppu_sib_byte_00[0:3],    ppu_sib_byte_01[0:3],    ppu_sib_byte_10[0:3],    ppu_sib_byte_11[0:3];
    wire [31:0] ppu_displacement_00[0:3],ppu_displacement_01[0:3],ppu_displacement_10[0:3],ppu_displacement_11[0:3];
    wire [63:0] ppu_imm_00[0:3],         ppu_imm_01[0:3],         ppu_imm_10[0:3],         ppu_imm_11[0:3];
    wire [3:0]  ppu_needrm_00,           ppu_needrm_01,           ppu_needrm_10,           ppu_needrm_11;
    wire [3:0]  ppu_disp_size_00,        ppu_disp_size_01,        ppu_disp_size_10,        ppu_disp_size_11;
    wire [3:0]  ppu_disp_needed_00,      ppu_disp_needed_01,      ppu_disp_needed_10,      ppu_disp_needed_11;
    wire [3:0]  ppu_sib_size_00,         ppu_sib_size_01,         ppu_sib_size_10,         ppu_sib_size_11;
    wire [1:0] num_pfs;
    wire [1:0] num_pfs_duplicate0, num_pfs_duplicate1, num_pfs_duplicate2;
    wire [9:0] pf_vector0, pf_vector1, pf_vector2;
    wire [9:0] total_pf_vector_duplicate0, total_pf_vector_duplicate1, total_pf_vector_duplicate2;
    wire [31:0] sext_inst_length;
    wire inst_length_cout;
    wire true_inst_valid;
    wire [15:0] adder_cout;
    wire [31:0] possible_neips[0:15];


    selection_logic sel_log1(.queue(queue), .EIP(EIP), .IR(IR));

    // 16 parallel ppu instances: pfs<i>_<b1><b3> with hardcoded {total_pf_vector_1, total_pf_vector_3} = bb
    // i is num_pfs_plusone-1 (also opcode_index)
    ppu pfs0_00(.modrm_index(4'd1), .sib_index(4'd2), .IR(IR), .opcode_byte(IR[0*8 +: 8]), .modrm_byte(IR[1*8 +: 8]),
        .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b0), .num_pfs_plusone(3'd1),
        .inst_length(ppu_inst_length_00[0]), .msd_size_o(ppu_msd_size_00[0]),
        .imm_size_o(ppu_imm_size_00[0]), .disp_size_o(ppu_disp_size_00[0]), .disp_needed_o(ppu_disp_needed_00[0]), .sib_size_o(ppu_sib_size_00[0]), .needrm_o(ppu_needrm_00[0]), .sib_byte(ppu_sib_byte_00[0]), .disp(ppu_displacement_00[0]), .imm64(ppu_imm_00[0]));

    ppu pfs0_01(.modrm_index(4'd1), .sib_index(4'd2), .IR(IR), .opcode_byte(IR[0*8 +: 8]), .modrm_byte(IR[1*8 +: 8]),
        .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b1), .num_pfs_plusone(3'd1),
        .inst_length(ppu_inst_length_01[0]), .msd_size_o(ppu_msd_size_01[0]),
        .imm_size_o(ppu_imm_size_01[0]), .disp_size_o(ppu_disp_size_01[0]), .disp_needed_o(ppu_disp_needed_01[0]), .sib_size_o(ppu_sib_size_01[0]), .needrm_o(ppu_needrm_01[0]), .sib_byte(ppu_sib_byte_01[0]), .disp(ppu_displacement_01[0]), .imm64(ppu_imm_01[0]));

    ppu pfs0_10(.modrm_index(4'd1), .sib_index(4'd2), .IR(IR), .opcode_byte(IR[0*8 +: 8]), .modrm_byte(IR[1*8 +: 8]),
        .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b0), .num_pfs_plusone(3'd1),
        .inst_length(ppu_inst_length_10[0]), .msd_size_o(ppu_msd_size_10[0]),
        .imm_size_o(ppu_imm_size_10[0]), .disp_size_o(ppu_disp_size_10[0]), .disp_needed_o(ppu_disp_needed_10[0]), .sib_size_o(ppu_sib_size_10[0]), .needrm_o(ppu_needrm_10[0]), .sib_byte(ppu_sib_byte_10[0]), .disp(ppu_displacement_10[0]), .imm64(ppu_imm_10[0]));

    ppu pfs0_11(.modrm_index(4'd1), .sib_index(4'd2), .IR(IR), .opcode_byte(IR[0*8 +: 8]), .modrm_byte(IR[1*8 +: 8]),
        .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b1), .num_pfs_plusone(3'd1),
        .inst_length(ppu_inst_length_11[0]), .msd_size_o(ppu_msd_size_11[0]),
        .imm_size_o(ppu_imm_size_11[0]), .disp_size_o(ppu_disp_size_11[0]), .disp_needed_o(ppu_disp_needed_11[0]), .sib_size_o(ppu_sib_size_11[0]), .needrm_o(ppu_needrm_11[0]), .sib_byte(ppu_sib_byte_11[0]), .disp(ppu_displacement_11[0]), .imm64(ppu_imm_11[0]));


    ppu pfs1_00(.modrm_index(4'd2), .sib_index(4'd3), .IR(IR), .opcode_byte(IR[1*8 +: 8]), .modrm_byte(IR[2*8 +: 8]),
        .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b0), .num_pfs_plusone(3'd2),
        .inst_length(ppu_inst_length_00[1]), .msd_size_o(ppu_msd_size_00[1]),
        .imm_size_o(ppu_imm_size_00[1]), .disp_size_o(ppu_disp_size_00[1]), .disp_needed_o(ppu_disp_needed_00[1]), .sib_size_o(ppu_sib_size_00[1]), .needrm_o(ppu_needrm_00[1]), .sib_byte(ppu_sib_byte_00[1]), .disp(ppu_displacement_00[1]), .imm64(ppu_imm_00[1]));

    ppu pfs1_01(.modrm_index(4'd2), .sib_index(4'd3), .IR(IR), .opcode_byte(IR[1*8 +: 8]), .modrm_byte(IR[2*8 +: 8]),
        .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b1), .num_pfs_plusone(3'd2),
        .inst_length(ppu_inst_length_01[1]), .msd_size_o(ppu_msd_size_01[1]),
        .imm_size_o(ppu_imm_size_01[1]), .disp_size_o(ppu_disp_size_01[1]), .disp_needed_o(ppu_disp_needed_01[1]), .sib_size_o(ppu_sib_size_01[1]), .needrm_o(ppu_needrm_01[1]), .sib_byte(ppu_sib_byte_01[1]), .disp(ppu_displacement_01[1]), .imm64(ppu_imm_01[1]));

    ppu pfs1_10(.modrm_index(4'd2), .sib_index(4'd3), .IR(IR), .opcode_byte(IR[1*8 +: 8]), .modrm_byte(IR[2*8 +: 8]),
        .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b0), .num_pfs_plusone(3'd2),
        .inst_length(ppu_inst_length_10[1]), .msd_size_o(ppu_msd_size_10[1]),
        .imm_size_o(ppu_imm_size_10[1]), .disp_size_o(ppu_disp_size_10[1]), .disp_needed_o(ppu_disp_needed_10[1]), .sib_size_o(ppu_sib_size_10[1]), .needrm_o(ppu_needrm_10[1]), .sib_byte(ppu_sib_byte_10[1]), .disp(ppu_displacement_10[1]), .imm64(ppu_imm_10[1]));

    ppu pfs1_11(.modrm_index(4'd2), .sib_index(4'd3), .IR(IR), .opcode_byte(IR[1*8 +: 8]), .modrm_byte(IR[2*8 +: 8]),
        .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b1), .num_pfs_plusone(3'd2),
        .inst_length(ppu_inst_length_11[1]), .msd_size_o(ppu_msd_size_11[1]),
        .imm_size_o(ppu_imm_size_11[1]), .disp_size_o(ppu_disp_size_11[1]), .disp_needed_o(ppu_disp_needed_11[1]), .sib_size_o(ppu_sib_size_11[1]), .needrm_o(ppu_needrm_11[1]), .sib_byte(ppu_sib_byte_11[1]), .disp(ppu_displacement_11[1]), .imm64(ppu_imm_11[1]));


    ppu pfs2_00(.modrm_index(4'd3), .sib_index(4'd4), .IR(IR), .opcode_byte(IR[2*8 +: 8]), .modrm_byte(IR[3*8 +: 8]),
        .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b0), .num_pfs_plusone(3'd3),
        .inst_length(ppu_inst_length_00[2]), .msd_size_o(ppu_msd_size_00[2]),
        .imm_size_o(ppu_imm_size_00[2]), .disp_size_o(ppu_disp_size_00[2]), .disp_needed_o(ppu_disp_needed_00[2]), .sib_size_o(ppu_sib_size_00[2]), .needrm_o(ppu_needrm_00[2]), .sib_byte(ppu_sib_byte_00[2]), .disp(ppu_displacement_00[2]), .imm64(ppu_imm_00[2]));

    ppu pfs2_01(.modrm_index(4'd3), .sib_index(4'd4), .IR(IR), .opcode_byte(IR[2*8 +: 8]), .modrm_byte(IR[3*8 +: 8]),
        .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b1), .num_pfs_plusone(3'd3),
        .inst_length(ppu_inst_length_01[2]), .msd_size_o(ppu_msd_size_01[2]),
        .imm_size_o(ppu_imm_size_01[2]), .disp_size_o(ppu_disp_size_01[2]), .disp_needed_o(ppu_disp_needed_01[2]), .sib_size_o(ppu_sib_size_01[2]), .needrm_o(ppu_needrm_01[2]), .sib_byte(ppu_sib_byte_01[2]), .disp(ppu_displacement_01[2]), .imm64(ppu_imm_01[2]));

    ppu pfs2_10(.modrm_index(4'd3), .sib_index(4'd4), .IR(IR), .opcode_byte(IR[2*8 +: 8]), .modrm_byte(IR[3*8 +: 8]),
        .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b0), .num_pfs_plusone(3'd3),
        .inst_length(ppu_inst_length_10[2]), .msd_size_o(ppu_msd_size_10[2]),
        .imm_size_o(ppu_imm_size_10[2]), .disp_size_o(ppu_disp_size_10[2]), .disp_needed_o(ppu_disp_needed_10[2]), .sib_size_o(ppu_sib_size_10[2]), .needrm_o(ppu_needrm_10[2]), .sib_byte(ppu_sib_byte_10[2]), .disp(ppu_displacement_10[2]), .imm64(ppu_imm_10[2]));

    ppu pfs2_11(.modrm_index(4'd3), .sib_index(4'd4), .IR(IR), .opcode_byte(IR[2*8 +: 8]), .modrm_byte(IR[3*8 +: 8]),
        .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b1), .num_pfs_plusone(3'd3),
        .inst_length(ppu_inst_length_11[2]), .msd_size_o(ppu_msd_size_11[2]),
        .imm_size_o(ppu_imm_size_11[2]), .disp_size_o(ppu_disp_size_11[2]), .disp_needed_o(ppu_disp_needed_11[2]), .sib_size_o(ppu_sib_size_11[2]), .needrm_o(ppu_needrm_11[2]), .sib_byte(ppu_sib_byte_11[2]), .disp(ppu_displacement_11[2]), .imm64(ppu_imm_11[2]));


    ppu pfs3_00(.modrm_index(4'd4), .sib_index(4'd5), .IR(IR), .opcode_byte(IR[3*8 +: 8]), .modrm_byte(IR[4*8 +: 8]),
        .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b0), .num_pfs_plusone(3'd4),
        .inst_length(ppu_inst_length_00[3]), .msd_size_o(ppu_msd_size_00[3]),
        .imm_size_o(ppu_imm_size_00[3]), .disp_size_o(ppu_disp_size_00[3]), .disp_needed_o(ppu_disp_needed_00[3]), .sib_size_o(ppu_sib_size_00[3]), .needrm_o(ppu_needrm_00[3]), .sib_byte(ppu_sib_byte_00[3]), .disp(ppu_displacement_00[3]), .imm64(ppu_imm_00[3]));

    ppu pfs3_01(.modrm_index(4'd4), .sib_index(4'd5), .IR(IR), .opcode_byte(IR[3*8 +: 8]), .modrm_byte(IR[4*8 +: 8]),
        .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b1), .num_pfs_plusone(3'd4),
        .inst_length(ppu_inst_length_01[3]), .msd_size_o(ppu_msd_size_01[3]),
        .imm_size_o(ppu_imm_size_01[3]), .disp_size_o(ppu_disp_size_01[3]), .disp_needed_o(ppu_disp_needed_01[3]), .sib_size_o(ppu_sib_size_01[3]), .needrm_o(ppu_needrm_01[3]), .sib_byte(ppu_sib_byte_01[3]), .disp(ppu_displacement_01[3]), .imm64(ppu_imm_01[3]));

    ppu pfs3_10(.modrm_index(4'd4), .sib_index(4'd5), .IR(IR), .opcode_byte(IR[3*8 +: 8]), .modrm_byte(IR[4*8 +: 8]),
        .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b0), .num_pfs_plusone(3'd4),
        .inst_length(ppu_inst_length_10[3]), .msd_size_o(ppu_msd_size_10[3]),
        .imm_size_o(ppu_imm_size_10[3]), .disp_size_o(ppu_disp_size_10[3]), .disp_needed_o(ppu_disp_needed_10[3]), .sib_size_o(ppu_sib_size_10[3]), .needrm_o(ppu_needrm_10[3]), .sib_byte(ppu_sib_byte_10[3]), .disp(ppu_displacement_10[3]), .imm64(ppu_imm_10[3]));

    ppu pfs3_11(.modrm_index(4'd4), .sib_index(4'd5), .IR(IR), .opcode_byte(IR[3*8 +: 8]), .modrm_byte(IR[4*8 +: 8]),
        .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b1), .num_pfs_plusone(3'd4),
        .inst_length(ppu_inst_length_11[3]), .msd_size_o(ppu_msd_size_11[3]),
        .imm_size_o(ppu_imm_size_11[3]), .disp_size_o(ppu_disp_size_11[3]), .disp_needed_o(ppu_disp_needed_11[3]), .sib_size_o(ppu_sib_size_11[3]), .needrm_o(ppu_needrm_11[3]), .sib_byte(ppu_sib_byte_11[3]), .disp(ppu_displacement_11[3]), .imm64(ppu_imm_11[3]));


    // per-pf-combo intermediate outputs — final mux across {_00,_01,_10,_11} happens next step
    wire [3:0]  inst_length_00,  inst_length_01,  inst_length_10,  inst_length_11;
    wire [7:0]  sib_byte_00,     sib_byte_01,     sib_byte_10,     sib_byte_11;
    wire [31:0] disp_00,         disp_01,         disp_10,         disp_11;
    wire        disp_size_00,    disp_size_01,    disp_size_10,    disp_size_11;
    wire        disp_needed_00,  disp_needed_01,  disp_needed_10,  disp_needed_11;
    wire [63:0] imm64_00,        imm64_01,        imm64_10,        imm64_11;
    wire        sib_size_00,     sib_size_01,     sib_size_10,     sib_size_11;

    `MUX_4(length_mux_00, 4, inst_length_00, ppu_inst_length_00[0], ppu_inst_length_00[1], ppu_inst_length_00[2],
        ppu_inst_length_00[3], {num_pfs[1], num_pfs[0]})
    `MUX_4(length_mux_01, 4, inst_length_01, ppu_inst_length_01[0], ppu_inst_length_01[1], ppu_inst_length_01[2],
        ppu_inst_length_01[3], {num_pfs[1], num_pfs[0]})
    `MUX_4(length_mux_10, 4, inst_length_10, ppu_inst_length_10[0], ppu_inst_length_10[1], ppu_inst_length_10[2],
        ppu_inst_length_10[3], {num_pfs[1], num_pfs[0]})
    `MUX_4(length_mux_11, 4, inst_length_11, ppu_inst_length_11[0], ppu_inst_length_11[1], ppu_inst_length_11[2],
        ppu_inst_length_11[3], {num_pfs[1], num_pfs[0]})

    `MUX_4(sib_mux_00, 8, sib_byte_00, ppu_sib_byte_00[0], ppu_sib_byte_00[1], ppu_sib_byte_00[2], ppu_sib_byte_00[3],
        {num_pfs[1], num_pfs[0]})
    `MUX_4(sib_mux_01, 8, sib_byte_01, ppu_sib_byte_01[0], ppu_sib_byte_01[1], ppu_sib_byte_01[2], ppu_sib_byte_01[3],
        {num_pfs[1], num_pfs[0]})
    `MUX_4(sib_mux_10, 8, sib_byte_10, ppu_sib_byte_10[0], ppu_sib_byte_10[1], ppu_sib_byte_10[2], ppu_sib_byte_10[3],
        {num_pfs[1], num_pfs[0]})
    `MUX_4(sib_mux_11, 8, sib_byte_11, ppu_sib_byte_11[0], ppu_sib_byte_11[1], ppu_sib_byte_11[2], ppu_sib_byte_11[3],
        {num_pfs[1], num_pfs[0]})

    `MUX_4(disp_mux_00, 32, disp_00, ppu_displacement_00[0], ppu_displacement_00[1], ppu_displacement_00[2],
        ppu_displacement_00[3], {num_pfs[1], num_pfs[0]})
    `MUX_4(disp_mux_01, 32, disp_01, ppu_displacement_01[0], ppu_displacement_01[1], ppu_displacement_01[2],
        ppu_displacement_01[3], {num_pfs[1], num_pfs[0]})
    `MUX_4(disp_mux_10, 32, disp_10, ppu_displacement_10[0], ppu_displacement_10[1], ppu_displacement_10[2],
        ppu_displacement_10[3], {num_pfs[1], num_pfs[0]})
    `MUX_4(disp_mux_11, 32, disp_11, ppu_displacement_11[0], ppu_displacement_11[1], ppu_displacement_11[2],
        ppu_displacement_11[3], {num_pfs[1], num_pfs[0]})

    `MUX_4(disp_size_mux_00, 1, disp_size_00, ppu_disp_size_00[0], ppu_disp_size_00[1], ppu_disp_size_00[2],
        ppu_disp_size_00[3], {num_pfs[1], num_pfs[0]})
    `MUX_4(disp_size_mux_01, 1, disp_size_01, ppu_disp_size_01[0], ppu_disp_size_01[1], ppu_disp_size_01[2],
        ppu_disp_size_01[3], {num_pfs[1], num_pfs[0]})
    `MUX_4(disp_size_mux_10, 1, disp_size_10, ppu_disp_size_10[0], ppu_disp_size_10[1], ppu_disp_size_10[2],
        ppu_disp_size_10[3], {num_pfs[1], num_pfs[0]})
    `MUX_4(disp_size_mux_11, 1, disp_size_11, ppu_disp_size_11[0], ppu_disp_size_11[1], ppu_disp_size_11[2],
        ppu_disp_size_11[3], {num_pfs[1], num_pfs[0]})

    `MUX_4(disp_needed_mux_00, 1, disp_needed_00, ppu_disp_needed_00[0], ppu_disp_needed_00[1], ppu_disp_needed_00[2],
        ppu_disp_needed_00[3], {num_pfs[1], num_pfs[0]})
    `MUX_4(disp_needed_mux_01, 1, disp_needed_01, ppu_disp_needed_01[0], ppu_disp_needed_01[1], ppu_disp_needed_01[2],
        ppu_disp_needed_01[3], {num_pfs[1], num_pfs[0]})
    `MUX_4(disp_needed_mux_10, 1, disp_needed_10, ppu_disp_needed_10[0], ppu_disp_needed_10[1], ppu_disp_needed_10[2],
        ppu_disp_needed_10[3], {num_pfs[1], num_pfs[0]})
    `MUX_4(disp_needed_mux_11, 1, disp_needed_11, ppu_disp_needed_11[0], ppu_disp_needed_11[1], ppu_disp_needed_11[2],
        ppu_disp_needed_11[3], {num_pfs[1], num_pfs[0]})

    `MUX_4(imm_mux_00, 64, imm64_00, ppu_imm_00[0], ppu_imm_00[1], ppu_imm_00[2],
        ppu_imm_00[3], {num_pfs[1], num_pfs[0]})
    `MUX_4(imm_mux_01, 64, imm64_01, ppu_imm_01[0], ppu_imm_01[1], ppu_imm_01[2],
        ppu_imm_01[3], {num_pfs[1], num_pfs[0]})
    `MUX_4(imm_mux_10, 64, imm64_10, ppu_imm_10[0], ppu_imm_10[1], ppu_imm_10[2],
        ppu_imm_10[3], {num_pfs[1], num_pfs[0]})
    `MUX_4(imm_mux_11, 64, imm64_11, ppu_imm_11[0], ppu_imm_11[1], ppu_imm_11[2],
        ppu_imm_11[3], {num_pfs[1], num_pfs[0]})

    `MUX_4(sib_size_mux_00, 1, sib_size_00, ppu_sib_size_00[0], ppu_sib_size_00[1], ppu_sib_size_00[2],
        ppu_sib_size_00[3], {num_pfs[1], num_pfs[0]})
    `MUX_4(sib_size_mux_01, 1, sib_size_01, ppu_sib_size_01[0], ppu_sib_size_01[1], ppu_sib_size_01[2],
        ppu_sib_size_01[3], {num_pfs[1], num_pfs[0]})
    `MUX_4(sib_size_mux_10, 1, sib_size_10, ppu_sib_size_10[0], ppu_sib_size_10[1], ppu_sib_size_10[2],
        ppu_sib_size_10[3], {num_pfs[1], num_pfs[0]})
    `MUX_4(sib_size_mux_11, 1, sib_size_11, ppu_sib_size_11[0], ppu_sib_size_11[1], ppu_sib_size_11[2],
        ppu_sib_size_11[3], {num_pfs[1], num_pfs[0]})

    `MUX_4_H8(opcode_mux, 8, opcode_byte, IR[0*8 +: 8], IR[1*8 +: 8], IR[2*8 +: 8],
        IR[3*8 +: 8], {num_pfs[1], num_pfs[0]}, {num_pfs_duplicate1[1], num_pfs_duplicate1[0]})
    `MUX_4_H8(modrm_mux, 8, modrm_byte, IR[1*8 +: 8], IR[2*8 +: 8], IR[3*8 +: 8],
        IR[4*8 +: 8], {num_pfs[1], num_pfs[0]}, {num_pfs_duplicate2[1], num_pfs_duplicate2[0]})


    wire [3:0] inst_length_temp;
    `MUX_4(length_mux, 4, inst_length_temp, inst_length_00, inst_length_01, inst_length_10,
        inst_length_11, {total_pf_vector[1], total_pf_vector[3]})
    bufferH256$ buf_length0(.out(inst_length[0]), .in(inst_length_temp[0]));
    bufferH256$ buf_length1(.out(inst_length[1]), .in(inst_length_temp[1]));
    bufferH256$ buf_length2(.out(inst_length[2]), .in(inst_length_temp[2]));
    bufferH256$ buf_length3(.out(inst_length[3]), .in(inst_length_temp[3]));

    `MUX_4_H8(sib_mux, 8, sib_byte, sib_byte_00, sib_byte_01, sib_byte_10,
        sib_byte_11, {total_pf_vector[1], total_pf_vector[3]}, {total_pf_vector_duplicate0[1], total_pf_vector_duplicate0[3]})
    `MUX_4(disp_mux, 32, disp, disp_00, disp_01, disp_10,
        disp_11, {total_pf_vector[1], total_pf_vector[3]})
    `MUX_4(disp_size_mux, 1, disp_size, disp_size_00, disp_size_01, disp_size_10,
        disp_size_11, {total_pf_vector[1], total_pf_vector[3]})
    `MUX_4(disp_needed_mux, 1, disp_needed, disp_needed_00, disp_needed_01, disp_needed_10,
        disp_needed_11, {total_pf_vector[1], total_pf_vector[3]})
    `MUX_4(imm_mux, 64, imm64, imm64_00, imm64_01, imm64_10,
        imm64_11, {total_pf_vector[1], total_pf_vector[3]})
    `MUX_4(sib_size_mux, 1, sib_size, sib_size_00, sib_size_01, sib_size_10,
        sib_size_11, {total_pf_vector[1], total_pf_vector[3]})


    wire pf0, pf1, pf2;
    pf_checker checker0(.IRbyte(IR[0*8 +: 8]), .pf(pf0), .pf_vector(pf_vector0));
    pf_checker checker1(.IRbyte(IR[1*8 +: 8]), .pf(pf1), .pf_vector(pf_vector1));
    pf_checker checker2(.IRbyte(IR[2*8 +: 8]), .pf(pf2), .pf_vector(pf_vector2));

    num_pf_gen num_pf_gen0(pf0, pf1 ,pf2, num_pfs);
    num_pf_gen num_pf_gen0_dup0(pf0, pf1, pf2, num_pfs_duplicate0);
    num_pf_gen num_pf_gen0_dup1(pf0, pf1, pf2, num_pfs_duplicate1);
    num_pf_gen num_pf_gen0_dup2(pf0, pf1, pf2, num_pfs_duplicate2);

    pf_vector_gen vec_gen(.pfs(num_pfs), .pf_vector0(pf_vector0), .pf_vector1(pf_vector1), .pf_vector2(pf_vector2),
        .total_pf_vector(total_pf_vector));
    pf_vector_gen vec_gen_dup0(.pfs(num_pfs), .pf_vector0(pf_vector0), .pf_vector1(pf_vector1), .pf_vector2(pf_vector2),
        .total_pf_vector(total_pf_vector_duplicate0));
    pf_vector_gen vec_gen_dup1(.pfs(num_pfs), .pf_vector0(pf_vector0), .pf_vector1(pf_vector1), .pf_vector2(pf_vector2),
        .total_pf_vector(total_pf_vector_duplicate1));
    pf_vector_gen vec_gen_dup2(.pfs(num_pfs), .pf_vector0(pf_vector0), .pf_vector1(pf_vector1), .pf_vector2(pf_vector2),
        .total_pf_vector(total_pf_vector_duplicate2));


    wire possible_invalid_inst [0:15];
    assign possible_neips[0] = EIP;
    genvar i;
    generate
        for (i = 1; i < 16; i=i+1) begin : possible_eip_adders
            kogge_stone_adder #(
                .WIDTH(32)
            ) IR_index_adder (
                .a   (EIP),
                .b   ({28'b0, i[3:0]}),       // cast loop index to 6-bit
                .cin (1'b0),
                .sum (possible_neips[i]),
                .cout(adder_cout[i])             // unused
            );
        end
    endgenerate 

    //mux16_32 neip_picker_mux(.in(possible_eips), .sel0(inst_length[0]), .sel1(inst_length[1]), .sel2(inst_length[2]), .sel3(inst_length[3]), .out(NEIP));
    `MUX_16_H32(neip_picker_mux, 32, NEIP,
        possible_neips[0], possible_neips[1], possible_neips[2], possible_neips[3],
        possible_neips[4], possible_neips[5], possible_neips[6], possible_neips[7],
        possible_neips[8], possible_neips[9], possible_neips[10], possible_neips[11],
        possible_neips[12], possible_neips[13], possible_neips[14], possible_neips[15],
        inst_length, inst_length, inst_length, inst_length,
        inst_length, inst_length, inst_length, inst_length)

    // generate
    //     for (i = 1; i < 16; i++) begin : possible_invalid_inst_g
    //         possible_invalid_inst[i] = !queue_valid[possible_neip[i][5:4]];
    //     end
    // endgenerate

    wire [15:0] selected_queue_valid;
    generate
        for (i = 1; i < 16; i=i+1) begin : possible_invalid_inst_g
            `MUX_4(qv_sel_mux, 1, selected_queue_valid[i],
                queue_valid[0], queue_valid[1], queue_valid[2], queue_valid[3],
                possible_neips[i][5:4])
            `INV_N(qv_inv, 1, selected_queue_valid[i], possible_invalid_inst[i])
        end
    endgenerate

    `MUX_16_H32(invalid_inst_picker_mux, 1, invalid_inst,
        possible_invalid_inst[0], possible_invalid_inst[1], possible_invalid_inst[2], possible_invalid_inst[3],
        possible_invalid_inst[4], possible_invalid_inst[5], possible_invalid_inst[6], possible_invalid_inst[7],
        possible_invalid_inst[8], possible_invalid_inst[9], possible_invalid_inst[10], possible_invalid_inst[11],
        possible_invalid_inst[12], possible_invalid_inst[13], possible_invalid_inst[14], possible_invalid_inst[15],
        inst_length, inst_length, inst_length, inst_length,
        inst_length, inst_length, inst_length, inst_length)





    control_store_top cs_top(
        .invalid_inst(invalid_inst),
        .total_pf_vector_0(total_pf_vector[0]),
        .total_pf_vector_1(total_pf_vector[1]),
        .total_pf_vector_3(total_pf_vector[3]),
        .num_pfs(num_pfs),
        .IR(IR),
        .seg_override(seg_override),
        .seg0(seg0),

        .decode_cs_REP(decode_cs_REP),
        .decode_cs_REP_CMP(decode_cs_REP_CMP),
        .decode_cs_HALT(decode_cs_HALT),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE),
        .rr_cs_ST_SEL(rr_cs_ST_SEL),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY),
        .rr_cs_LD_OP(rr_cs_LD_OP),
        .rr_cs_ST_OP(rr_cs_ST_OP),
        .rr_cs_dr_id(rr_cs_dr_id),
        .rr_cs_sr_id(rr_cs_sr_id),
        .rr_cs_dr_rd(rr_cs_dr_rd),
        .rr_cs_sr_rd(rr_cs_sr_rd),
        .rr_cs_eax_rd(rr_cs_eax_rd),
        .rr_cs_dr_wr(rr_cs_dr_wr),
        .rr_cs_sr_wr(rr_cs_sr_wr),
        .rr_cs_eax_wr(rr_cs_eax_wr),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP),
        .rr_cs_datasize(rr_cs_datasize),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid),
        .rr_cs_seg_0_id(rr_cs_seg_0_id),
        .rr_cs_seg_1_id(rr_cs_seg_1_id),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs),
        .rr_cs_special_br(rr_cs_special_br),
        .dc_cs_LD_OP(dc_cs_LD_OP),
        .dc_cs_ST_OP(dc_cs_ST_OP),
        .dc_cs_dr_upper8(dc_cs_dr_upper8),
        .dc_cs_sr_upper8(dc_cs_sr_upper8),
        .dc_cs_datasize(dc_cs_datasize),
        .mem_cs_ST_OP(mem_cs_ST_OP),
        .mem_cs_LD_OP(mem_cs_LD_OP),
        .exe_cs_ST_OP(exe_cs_ST_OP),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel),
        .exe_cs_shift_by_one(exe_cs_shift_by_one),
        .exe_cs_br_ucond(exe_cs_br_ucond),
        .exe_cs_relative_branch(exe_cs_relative_branch),
        .exe_cs_special_br(exe_cs_special_br),
        .exe_cs_is_far(exe_cs_is_far),
        .exe_cs_is_call(exe_cs_is_call),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update),
        .wb_cs_ST_OP(wb_cs_ST_OP),
        .wb_cs_WB_DR(wb_cs_WB_DR),
        .wb_cs_WB_SR(wb_cs_WB_SR),
        .wb_cs_WB_EAX(wb_cs_WB_EAX)
    );

    



endmodule
