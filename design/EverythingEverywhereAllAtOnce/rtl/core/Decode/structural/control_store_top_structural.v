module control_store_top (
    input wire invalid_inst,
    input wire total_pf_vector_0,
    input wire total_pf_vector_1,
    input wire total_pf_vector_3,
    input wire [1:0] num_pfs,
    input wire [127:0] IR,
    input wire seg_override,
    input wire [`REG_ID_W-1:0] seg0,

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


    // === Wire declarations for 32 parallel control_store lookups ===
    // Naming: <port>_<yza>; index by x via _<yza>[x]
    //   x   ∈ {0,1,2,3} = opcode index in IR (opcode = IR[x*8 +: 8], modrm = IR[(x+1)*8 +: 8])
    //   y/z/a = hardcoded total_pf_vector_3 / total_pf_vector_1 / total_pf_vector_0
    // 1-bit ports use packed [3:0]; multi-bit ports use unpacked [3:0] arrays.

    // -- decode_cs 1-bit outputs --
    wire [3:0] decode_cs_REP_000_x, decode_cs_REP_001_x, decode_cs_REP_010_x, decode_cs_REP_011_x, decode_cs_REP_100_x, decode_cs_REP_101_x, decode_cs_REP_110_x, decode_cs_REP_111_x;
    wire [3:0] decode_cs_REP_CMP_000_x, decode_cs_REP_CMP_001_x, decode_cs_REP_CMP_010_x, decode_cs_REP_CMP_011_x, decode_cs_REP_CMP_100_x, decode_cs_REP_CMP_101_x, decode_cs_REP_CMP_110_x, decode_cs_REP_CMP_111_x;
    wire [3:0] decode_cs_HALT_000_x, decode_cs_HALT_001_x, decode_cs_HALT_010_x, decode_cs_HALT_011_x, decode_cs_HALT_100_x, decode_cs_HALT_101_x, decode_cs_HALT_110_x, decode_cs_HALT_111_x;
    wire [3:0] decode_cs_MODRM_NEEDED_000_x, decode_cs_MODRM_NEEDED_001_x, decode_cs_MODRM_NEEDED_010_x, decode_cs_MODRM_NEEDED_011_x, decode_cs_MODRM_NEEDED_100_x, decode_cs_MODRM_NEEDED_101_x, decode_cs_MODRM_NEEDED_110_x, decode_cs_MODRM_NEEDED_111_x;
    wire [3:0] decode_cs_RM_IS_DR_000_x, decode_cs_RM_IS_DR_001_x, decode_cs_RM_IS_DR_010_x, decode_cs_RM_IS_DR_011_x, decode_cs_RM_IS_DR_100_x, decode_cs_RM_IS_DR_101_x, decode_cs_RM_IS_DR_110_x, decode_cs_RM_IS_DR_111_x;
    wire [3:0] decode_cs_REG_IS_DR_000_x, decode_cs_REG_IS_DR_001_x, decode_cs_REG_IS_DR_010_x, decode_cs_REG_IS_DR_011_x, decode_cs_REG_IS_DR_100_x, decode_cs_REG_IS_DR_101_x, decode_cs_REG_IS_DR_110_x, decode_cs_REG_IS_DR_111_x;
    wire [3:0] decode_cs_REG_IS_SEGMENT_000_x, decode_cs_REG_IS_SEGMENT_001_x, decode_cs_REG_IS_SEGMENT_010_x, decode_cs_REG_IS_SEGMENT_011_x, decode_cs_REG_IS_SEGMENT_100_x, decode_cs_REG_IS_SEGMENT_101_x, decode_cs_REG_IS_SEGMENT_110_x, decode_cs_REG_IS_SEGMENT_111_x;
    wire [3:0] decode_cs_HARDCODED_DR_HIGH8_000_x, decode_cs_HARDCODED_DR_HIGH8_001_x, decode_cs_HARDCODED_DR_HIGH8_010_x, decode_cs_HARDCODED_DR_HIGH8_011_x, decode_cs_HARDCODED_DR_HIGH8_100_x, decode_cs_HARDCODED_DR_HIGH8_101_x, decode_cs_HARDCODED_DR_HIGH8_110_x, decode_cs_HARDCODED_DR_HIGH8_111_x;
    wire [3:0] decode_cs_MODRM_BUT_NO_SR_000_x, decode_cs_MODRM_BUT_NO_SR_001_x, decode_cs_MODRM_BUT_NO_SR_010_x, decode_cs_MODRM_BUT_NO_SR_011_x, decode_cs_MODRM_BUT_NO_SR_100_x, decode_cs_MODRM_BUT_NO_SR_101_x, decode_cs_MODRM_BUT_NO_SR_110_x, decode_cs_MODRM_BUT_NO_SR_111_x;
    wire [3:0] decode_cs_HARDCODED_DR_000_x, decode_cs_HARDCODED_DR_001_x, decode_cs_HARDCODED_DR_010_x, decode_cs_HARDCODED_DR_011_x, decode_cs_HARDCODED_DR_100_x, decode_cs_HARDCODED_DR_101_x, decode_cs_HARDCODED_DR_110_x, decode_cs_HARDCODED_DR_111_x;
    wire [3:0] decode_cs_HARDCODED_SR_000_x, decode_cs_HARDCODED_SR_001_x, decode_cs_HARDCODED_SR_010_x, decode_cs_HARDCODED_SR_011_x, decode_cs_HARDCODED_SR_100_x, decode_cs_HARDCODED_SR_101_x, decode_cs_HARDCODED_SR_110_x, decode_cs_HARDCODED_SR_111_x;
    wire [3:0] decode_cs_HARDCODED_DR_RD_000_x, decode_cs_HARDCODED_DR_RD_001_x, decode_cs_HARDCODED_DR_RD_010_x, decode_cs_HARDCODED_DR_RD_011_x, decode_cs_HARDCODED_DR_RD_100_x, decode_cs_HARDCODED_DR_RD_101_x, decode_cs_HARDCODED_DR_RD_110_x, decode_cs_HARDCODED_DR_RD_111_x;
    wire [3:0] decode_cs_HARDCODED_DR_WR_000_x, decode_cs_HARDCODED_DR_WR_001_x, decode_cs_HARDCODED_DR_WR_010_x, decode_cs_HARDCODED_DR_WR_011_x, decode_cs_HARDCODED_DR_WR_100_x, decode_cs_HARDCODED_DR_WR_101_x, decode_cs_HARDCODED_DR_WR_110_x, decode_cs_HARDCODED_DR_WR_111_x;
    wire [3:0] decode_cs_HARDCODED_SR_RD_000_x, decode_cs_HARDCODED_SR_RD_001_x, decode_cs_HARDCODED_SR_RD_010_x, decode_cs_HARDCODED_SR_RD_011_x, decode_cs_HARDCODED_SR_RD_100_x, decode_cs_HARDCODED_SR_RD_101_x, decode_cs_HARDCODED_SR_RD_110_x, decode_cs_HARDCODED_SR_RD_111_x;
    wire [3:0] decode_cs_HARDCODED_SR_WR_000_x, decode_cs_HARDCODED_SR_WR_001_x, decode_cs_HARDCODED_SR_WR_010_x, decode_cs_HARDCODED_SR_WR_011_x, decode_cs_HARDCODED_SR_WR_100_x, decode_cs_HARDCODED_SR_WR_101_x, decode_cs_HARDCODED_SR_WR_110_x, decode_cs_HARDCODED_SR_WR_111_x;
    wire [3:0] decode_cs_HARDCODED_LD_OP_000_x, decode_cs_HARDCODED_LD_OP_001_x, decode_cs_HARDCODED_LD_OP_010_x, decode_cs_HARDCODED_LD_OP_011_x, decode_cs_HARDCODED_LD_OP_100_x, decode_cs_HARDCODED_LD_OP_101_x, decode_cs_HARDCODED_LD_OP_110_x, decode_cs_HARDCODED_LD_OP_111_x;
    wire [3:0] decode_cs_HARDCODED_ST_OP_000_x, decode_cs_HARDCODED_ST_OP_001_x, decode_cs_HARDCODED_ST_OP_010_x, decode_cs_HARDCODED_ST_OP_011_x, decode_cs_HARDCODED_ST_OP_100_x, decode_cs_HARDCODED_ST_OP_101_x, decode_cs_HARDCODED_ST_OP_110_x, decode_cs_HARDCODED_ST_OP_111_x;
    wire [3:0] decode_cs_LD_OP_CANCEL_000_x, decode_cs_LD_OP_CANCEL_001_x, decode_cs_LD_OP_CANCEL_010_x, decode_cs_LD_OP_CANCEL_011_x, decode_cs_LD_OP_CANCEL_100_x, decode_cs_LD_OP_CANCEL_101_x, decode_cs_LD_OP_CANCEL_110_x, decode_cs_LD_OP_CANCEL_111_x;
    wire [3:0] decode_cs_ST_OP_CANCEL_000_x, decode_cs_ST_OP_CANCEL_001_x, decode_cs_ST_OP_CANCEL_010_x, decode_cs_ST_OP_CANCEL_011_x, decode_cs_ST_OP_CANCEL_100_x, decode_cs_ST_OP_CANCEL_101_x, decode_cs_ST_OP_CANCEL_110_x, decode_cs_ST_OP_CANCEL_111_x;
    wire [3:0] decode_cs_OP_IN_MODRM_000_x, decode_cs_OP_IN_MODRM_001_x, decode_cs_OP_IN_MODRM_010_x, decode_cs_OP_IN_MODRM_011_x, decode_cs_OP_IN_MODRM_100_x, decode_cs_OP_IN_MODRM_101_x, decode_cs_OP_IN_MODRM_110_x, decode_cs_OP_IN_MODRM_111_x;

    // -- decode_cs multi-bit outputs --
    wire [`REG_ID_W-1:0] decode_cs_HARDCODED_DR_ID_000_x [3:0], decode_cs_HARDCODED_DR_ID_001_x [3:0], decode_cs_HARDCODED_DR_ID_010_x [3:0], decode_cs_HARDCODED_DR_ID_011_x [3:0], decode_cs_HARDCODED_DR_ID_100_x [3:0], decode_cs_HARDCODED_DR_ID_101_x [3:0], decode_cs_HARDCODED_DR_ID_110_x [3:0], decode_cs_HARDCODED_DR_ID_111_x [3:0];
    wire [`REG_ID_W-1:0] decode_cs_HARDCODED_SR_ID_000_x [3:0], decode_cs_HARDCODED_SR_ID_001_x [3:0], decode_cs_HARDCODED_SR_ID_010_x [3:0], decode_cs_HARDCODED_SR_ID_011_x [3:0], decode_cs_HARDCODED_SR_ID_100_x [3:0], decode_cs_HARDCODED_SR_ID_101_x [3:0], decode_cs_HARDCODED_SR_ID_110_x [3:0], decode_cs_HARDCODED_SR_ID_111_x [3:0];
    wire [1:0] decode_cs_DATA_SIZE_000_x [3:0], decode_cs_DATA_SIZE_001_x [3:0], decode_cs_DATA_SIZE_010_x [3:0], decode_cs_DATA_SIZE_011_x [3:0], decode_cs_DATA_SIZE_100_x [3:0], decode_cs_DATA_SIZE_101_x [3:0], decode_cs_DATA_SIZE_110_x [3:0], decode_cs_DATA_SIZE_111_x [3:0];

    // -- rr_cs 1-bit outputs --
    wire [3:0] rr_cs_ST_SEL_000_x, rr_cs_ST_SEL_001_x, rr_cs_ST_SEL_010_x, rr_cs_ST_SEL_011_x, rr_cs_ST_SEL_100_x, rr_cs_ST_SEL_101_x, rr_cs_ST_SEL_110_x, rr_cs_ST_SEL_111_x;
    wire [3:0] rr_cs_MODRM_NEEDED_000_x, rr_cs_MODRM_NEEDED_001_x, rr_cs_MODRM_NEEDED_010_x, rr_cs_MODRM_NEEDED_011_x, rr_cs_MODRM_NEEDED_100_x, rr_cs_MODRM_NEEDED_101_x, rr_cs_MODRM_NEEDED_110_x, rr_cs_MODRM_NEEDED_111_x;
    wire [3:0] rr_cs_RM_IS_DR_000_x, rr_cs_RM_IS_DR_001_x, rr_cs_RM_IS_DR_010_x, rr_cs_RM_IS_DR_011_x, rr_cs_RM_IS_DR_100_x, rr_cs_RM_IS_DR_101_x, rr_cs_RM_IS_DR_110_x, rr_cs_RM_IS_DR_111_x;
    wire [3:0] rr_cs_SWITCH_LD_ADDY_000_x, rr_cs_SWITCH_LD_ADDY_001_x, rr_cs_SWITCH_LD_ADDY_010_x, rr_cs_SWITCH_LD_ADDY_011_x, rr_cs_SWITCH_LD_ADDY_100_x, rr_cs_SWITCH_LD_ADDY_101_x, rr_cs_SWITCH_LD_ADDY_110_x, rr_cs_SWITCH_LD_ADDY_111_x;
    wire [3:0] rr_cs_LD_OP_000_x, rr_cs_LD_OP_001_x, rr_cs_LD_OP_010_x, rr_cs_LD_OP_011_x, rr_cs_LD_OP_100_x, rr_cs_LD_OP_101_x, rr_cs_LD_OP_110_x, rr_cs_LD_OP_111_x;
    wire [3:0] rr_cs_ST_OP_000_x, rr_cs_ST_OP_001_x, rr_cs_ST_OP_010_x, rr_cs_ST_OP_011_x, rr_cs_ST_OP_100_x, rr_cs_ST_OP_101_x, rr_cs_ST_OP_110_x, rr_cs_ST_OP_111_x;
    wire [3:0] rr_cs_dr_rd_000_x, rr_cs_dr_rd_001_x, rr_cs_dr_rd_010_x, rr_cs_dr_rd_011_x, rr_cs_dr_rd_100_x, rr_cs_dr_rd_101_x, rr_cs_dr_rd_110_x, rr_cs_dr_rd_111_x;
    wire [3:0] rr_cs_sr_rd_000_x, rr_cs_sr_rd_001_x, rr_cs_sr_rd_010_x, rr_cs_sr_rd_011_x, rr_cs_sr_rd_100_x, rr_cs_sr_rd_101_x, rr_cs_sr_rd_110_x, rr_cs_sr_rd_111_x;
    wire [3:0] rr_cs_eax_rd_000_x, rr_cs_eax_rd_001_x, rr_cs_eax_rd_010_x, rr_cs_eax_rd_011_x, rr_cs_eax_rd_100_x, rr_cs_eax_rd_101_x, rr_cs_eax_rd_110_x, rr_cs_eax_rd_111_x;
    wire [3:0] rr_cs_dr_wr_000_x, rr_cs_dr_wr_001_x, rr_cs_dr_wr_010_x, rr_cs_dr_wr_011_x, rr_cs_dr_wr_100_x, rr_cs_dr_wr_101_x, rr_cs_dr_wr_110_x, rr_cs_dr_wr_111_x;
    wire [3:0] rr_cs_sr_wr_000_x, rr_cs_sr_wr_001_x, rr_cs_sr_wr_010_x, rr_cs_sr_wr_011_x, rr_cs_sr_wr_100_x, rr_cs_sr_wr_101_x, rr_cs_sr_wr_110_x, rr_cs_sr_wr_111_x;
    wire [3:0] rr_cs_eax_wr_000_x, rr_cs_eax_wr_001_x, rr_cs_eax_wr_010_x, rr_cs_eax_wr_011_x, rr_cs_eax_wr_100_x, rr_cs_eax_wr_101_x, rr_cs_eax_wr_110_x, rr_cs_eax_wr_111_x;
    wire [3:0] rr_cs_MOVS_OP_000_x, rr_cs_MOVS_OP_001_x, rr_cs_MOVS_OP_010_x, rr_cs_MOVS_OP_011_x, rr_cs_MOVS_OP_100_x, rr_cs_MOVS_OP_101_x, rr_cs_MOVS_OP_110_x, rr_cs_MOVS_OP_111_x;
    wire [3:0] rr_cs_will_mod_zf_000_x, rr_cs_will_mod_zf_001_x, rr_cs_will_mod_zf_010_x, rr_cs_will_mod_zf_011_x, rr_cs_will_mod_zf_100_x, rr_cs_will_mod_zf_101_x, rr_cs_will_mod_zf_110_x, rr_cs_will_mod_zf_111_x;
    wire [3:0] rr_cs_seg_1_valid_000_x, rr_cs_seg_1_valid_001_x, rr_cs_seg_1_valid_010_x, rr_cs_seg_1_valid_011_x, rr_cs_seg_1_valid_100_x, rr_cs_seg_1_valid_101_x, rr_cs_seg_1_valid_110_x, rr_cs_seg_1_valid_111_x;
    wire [3:0] rr_cs_special_modrm_bs_000_x, rr_cs_special_modrm_bs_001_x, rr_cs_special_modrm_bs_010_x, rr_cs_special_modrm_bs_011_x, rr_cs_special_modrm_bs_100_x, rr_cs_special_modrm_bs_101_x, rr_cs_special_modrm_bs_110_x, rr_cs_special_modrm_bs_111_x;
    wire [3:0] rr_cs_special_br_000_x, rr_cs_special_br_001_x, rr_cs_special_br_010_x, rr_cs_special_br_011_x, rr_cs_special_br_100_x, rr_cs_special_br_101_x, rr_cs_special_br_110_x, rr_cs_special_br_111_x;

    // -- rr_cs multi-bit outputs --
    wire [`REG_ID_W-1:0] rr_cs_dr_id_000_x [3:0], rr_cs_dr_id_001_x [3:0], rr_cs_dr_id_010_x [3:0], rr_cs_dr_id_011_x [3:0], rr_cs_dr_id_100_x [3:0], rr_cs_dr_id_101_x [3:0], rr_cs_dr_id_110_x [3:0], rr_cs_dr_id_111_x [3:0];
    wire [`REG_ID_W-1:0] rr_cs_sr_id_000_x [3:0], rr_cs_sr_id_001_x [3:0], rr_cs_sr_id_010_x [3:0], rr_cs_sr_id_011_x [3:0], rr_cs_sr_id_100_x [3:0], rr_cs_sr_id_101_x [3:0], rr_cs_sr_id_110_x [3:0], rr_cs_sr_id_111_x [3:0];
    wire [`REG_ID_W-1:0] rr_cs_seg_0_id_000_x [3:0], rr_cs_seg_0_id_001_x [3:0], rr_cs_seg_0_id_010_x [3:0], rr_cs_seg_0_id_011_x [3:0], rr_cs_seg_0_id_100_x [3:0], rr_cs_seg_0_id_101_x [3:0], rr_cs_seg_0_id_110_x [3:0], rr_cs_seg_0_id_111_x [3:0];
    wire [`REG_ID_W-1:0] rr_cs_seg_1_id_000_x [3:0], rr_cs_seg_1_id_001_x [3:0], rr_cs_seg_1_id_010_x [3:0], rr_cs_seg_1_id_011_x [3:0], rr_cs_seg_1_id_100_x [3:0], rr_cs_seg_1_id_101_x [3:0], rr_cs_seg_1_id_110_x [3:0], rr_cs_seg_1_id_111_x [3:0];
    wire [1:0] rr_cs_datasize_000_x [3:0], rr_cs_datasize_001_x [3:0], rr_cs_datasize_010_x [3:0], rr_cs_datasize_011_x [3:0], rr_cs_datasize_100_x [3:0], rr_cs_datasize_101_x [3:0], rr_cs_datasize_110_x [3:0], rr_cs_datasize_111_x [3:0];

    // -- dc_cs outputs --
    wire [3:0] dc_cs_LD_OP_000_x, dc_cs_LD_OP_001_x, dc_cs_LD_OP_010_x, dc_cs_LD_OP_011_x, dc_cs_LD_OP_100_x, dc_cs_LD_OP_101_x, dc_cs_LD_OP_110_x, dc_cs_LD_OP_111_x;
    wire [3:0] dc_cs_ST_OP_000_x, dc_cs_ST_OP_001_x, dc_cs_ST_OP_010_x, dc_cs_ST_OP_011_x, dc_cs_ST_OP_100_x, dc_cs_ST_OP_101_x, dc_cs_ST_OP_110_x, dc_cs_ST_OP_111_x;
    wire [3:0] dc_cs_dr_upper8_000_x, dc_cs_dr_upper8_001_x, dc_cs_dr_upper8_010_x, dc_cs_dr_upper8_011_x, dc_cs_dr_upper8_100_x, dc_cs_dr_upper8_101_x, dc_cs_dr_upper8_110_x, dc_cs_dr_upper8_111_x;
    wire [3:0] dc_cs_sr_upper8_000_x, dc_cs_sr_upper8_001_x, dc_cs_sr_upper8_010_x, dc_cs_sr_upper8_011_x, dc_cs_sr_upper8_100_x, dc_cs_sr_upper8_101_x, dc_cs_sr_upper8_110_x, dc_cs_sr_upper8_111_x;
    wire [1:0] dc_cs_datasize_000_x [3:0], dc_cs_datasize_001_x [3:0], dc_cs_datasize_010_x [3:0], dc_cs_datasize_011_x [3:0], dc_cs_datasize_100_x [3:0], dc_cs_datasize_101_x [3:0], dc_cs_datasize_110_x [3:0], dc_cs_datasize_111_x [3:0];

    // -- mem_cs outputs --
    wire [3:0] mem_cs_ST_OP_000_x, mem_cs_ST_OP_001_x, mem_cs_ST_OP_010_x, mem_cs_ST_OP_011_x, mem_cs_ST_OP_100_x, mem_cs_ST_OP_101_x, mem_cs_ST_OP_110_x, mem_cs_ST_OP_111_x;
    wire [3:0] mem_cs_LD_OP_000_x, mem_cs_LD_OP_001_x, mem_cs_LD_OP_010_x, mem_cs_LD_OP_011_x, mem_cs_LD_OP_100_x, mem_cs_LD_OP_101_x, mem_cs_LD_OP_110_x, mem_cs_LD_OP_111_x;

    // -- exe_cs 1-bit outputs --
    wire [3:0] exe_cs_ST_OP_000_x, exe_cs_ST_OP_001_x, exe_cs_ST_OP_010_x, exe_cs_ST_OP_011_x, exe_cs_ST_OP_100_x, exe_cs_ST_OP_101_x, exe_cs_ST_OP_110_x, exe_cs_ST_OP_111_x;
    wire [3:0] exe_cs_shift_by_one_000_x, exe_cs_shift_by_one_001_x, exe_cs_shift_by_one_010_x, exe_cs_shift_by_one_011_x, exe_cs_shift_by_one_100_x, exe_cs_shift_by_one_101_x, exe_cs_shift_by_one_110_x, exe_cs_shift_by_one_111_x;
    wire [3:0] exe_cs_br_ucond_000_x, exe_cs_br_ucond_001_x, exe_cs_br_ucond_010_x, exe_cs_br_ucond_011_x, exe_cs_br_ucond_100_x, exe_cs_br_ucond_101_x, exe_cs_br_ucond_110_x, exe_cs_br_ucond_111_x;
    wire [3:0] exe_cs_relative_branch_000_x, exe_cs_relative_branch_001_x, exe_cs_relative_branch_010_x, exe_cs_relative_branch_011_x, exe_cs_relative_branch_100_x, exe_cs_relative_branch_101_x, exe_cs_relative_branch_110_x, exe_cs_relative_branch_111_x;
    wire [3:0] exe_cs_special_br_000_x, exe_cs_special_br_001_x, exe_cs_special_br_010_x, exe_cs_special_br_011_x, exe_cs_special_br_100_x, exe_cs_special_br_101_x, exe_cs_special_br_110_x, exe_cs_special_br_111_x;
    wire [3:0] exe_cs_is_far_000_x, exe_cs_is_far_001_x, exe_cs_is_far_010_x, exe_cs_is_far_011_x, exe_cs_is_far_100_x, exe_cs_is_far_101_x, exe_cs_is_far_110_x, exe_cs_is_far_111_x;
    wire [3:0] exe_cs_is_call_000_x, exe_cs_is_call_001_x, exe_cs_is_call_010_x, exe_cs_is_call_011_x, exe_cs_is_call_100_x, exe_cs_is_call_101_x, exe_cs_is_call_110_x, exe_cs_is_call_111_x;
    wire [3:0] exe_cs_second_flag_needed_000_x, exe_cs_second_flag_needed_001_x, exe_cs_second_flag_needed_010_x, exe_cs_second_flag_needed_011_x, exe_cs_second_flag_needed_100_x, exe_cs_second_flag_needed_101_x, exe_cs_second_flag_needed_110_x, exe_cs_second_flag_needed_111_x;
    wire [3:0] exe_cs_rep_no_zf_update_000_x, exe_cs_rep_no_zf_update_001_x, exe_cs_rep_no_zf_update_010_x, exe_cs_rep_no_zf_update_011_x, exe_cs_rep_no_zf_update_100_x, exe_cs_rep_no_zf_update_101_x, exe_cs_rep_no_zf_update_110_x, exe_cs_rep_no_zf_update_111_x;

    // -- exe_cs multi-bit outputs --
    wire [`EXE_OP_W-1:0] exe_cs_OP_TYPE_000_x [3:0], exe_cs_OP_TYPE_001_x [3:0], exe_cs_OP_TYPE_010_x [3:0], exe_cs_OP_TYPE_011_x [3:0], exe_cs_OP_TYPE_100_x [3:0], exe_cs_OP_TYPE_101_x [3:0], exe_cs_OP_TYPE_110_x [3:0], exe_cs_OP_TYPE_111_x [3:0];
    wire [`SRC_SEL_W-1:0] exe_cs_alu_inputA_sel_000_x [3:0], exe_cs_alu_inputA_sel_001_x [3:0], exe_cs_alu_inputA_sel_010_x [3:0], exe_cs_alu_inputA_sel_011_x [3:0], exe_cs_alu_inputA_sel_100_x [3:0], exe_cs_alu_inputA_sel_101_x [3:0], exe_cs_alu_inputA_sel_110_x [3:0], exe_cs_alu_inputA_sel_111_x [3:0];
    wire [`SRC_SEL_W-1:0] exe_cs_alu_inputB_sel_000_x [3:0], exe_cs_alu_inputB_sel_001_x [3:0], exe_cs_alu_inputB_sel_010_x [3:0], exe_cs_alu_inputB_sel_011_x [3:0], exe_cs_alu_inputB_sel_100_x [3:0], exe_cs_alu_inputB_sel_101_x [3:0], exe_cs_alu_inputB_sel_110_x [3:0], exe_cs_alu_inputB_sel_111_x [3:0];
    wire [`SRC_SEL_W-1:0] exe_cs_branch_target_sel_000_x [3:0], exe_cs_branch_target_sel_001_x [3:0], exe_cs_branch_target_sel_010_x [3:0], exe_cs_branch_target_sel_011_x [3:0], exe_cs_branch_target_sel_100_x [3:0], exe_cs_branch_target_sel_101_x [3:0], exe_cs_branch_target_sel_110_x [3:0], exe_cs_branch_target_sel_111_x [3:0];

    // -- wb_cs outputs --
    wire [3:0] wb_cs_ST_OP_000_x, wb_cs_ST_OP_001_x, wb_cs_ST_OP_010_x, wb_cs_ST_OP_011_x, wb_cs_ST_OP_100_x, wb_cs_ST_OP_101_x, wb_cs_ST_OP_110_x, wb_cs_ST_OP_111_x;
    wire [3:0] wb_cs_WB_DR_000_x, wb_cs_WB_DR_001_x, wb_cs_WB_DR_010_x, wb_cs_WB_DR_011_x, wb_cs_WB_DR_100_x, wb_cs_WB_DR_101_x, wb_cs_WB_DR_110_x, wb_cs_WB_DR_111_x;
    wire [3:0] wb_cs_WB_SR_000_x, wb_cs_WB_SR_001_x, wb_cs_WB_SR_010_x, wb_cs_WB_SR_011_x, wb_cs_WB_SR_100_x, wb_cs_WB_SR_101_x, wb_cs_WB_SR_110_x, wb_cs_WB_SR_111_x;
    wire [3:0] wb_cs_WB_EAX_000_x, wb_cs_WB_EAX_001_x, wb_cs_WB_EAX_010_x, wb_cs_WB_EAX_011_x, wb_cs_WB_EAX_100_x, wb_cs_WB_EAX_101_x, wb_cs_WB_EAX_110_x, wb_cs_WB_EAX_111_x;

    // === Stage-1 muxed outputs (one per yza, picked from x via num_pfs) ===
    // <port>_<yza> = MUX_4 across <port>_<yza>_x[0..3] with sel=num_pfs.

    // -- decode_cs 1-bit muxed --
    wire decode_cs_REP_000, decode_cs_REP_001, decode_cs_REP_010, decode_cs_REP_011, decode_cs_REP_100, decode_cs_REP_101, decode_cs_REP_110, decode_cs_REP_111;
    wire decode_cs_REP_CMP_000, decode_cs_REP_CMP_001, decode_cs_REP_CMP_010, decode_cs_REP_CMP_011, decode_cs_REP_CMP_100, decode_cs_REP_CMP_101, decode_cs_REP_CMP_110, decode_cs_REP_CMP_111;
    wire decode_cs_HALT_000, decode_cs_HALT_001, decode_cs_HALT_010, decode_cs_HALT_011, decode_cs_HALT_100, decode_cs_HALT_101, decode_cs_HALT_110, decode_cs_HALT_111;
    wire decode_cs_MODRM_NEEDED_000, decode_cs_MODRM_NEEDED_001, decode_cs_MODRM_NEEDED_010, decode_cs_MODRM_NEEDED_011, decode_cs_MODRM_NEEDED_100, decode_cs_MODRM_NEEDED_101, decode_cs_MODRM_NEEDED_110, decode_cs_MODRM_NEEDED_111;
    wire decode_cs_RM_IS_DR_000, decode_cs_RM_IS_DR_001, decode_cs_RM_IS_DR_010, decode_cs_RM_IS_DR_011, decode_cs_RM_IS_DR_100, decode_cs_RM_IS_DR_101, decode_cs_RM_IS_DR_110, decode_cs_RM_IS_DR_111;
    wire decode_cs_REG_IS_DR_000, decode_cs_REG_IS_DR_001, decode_cs_REG_IS_DR_010, decode_cs_REG_IS_DR_011, decode_cs_REG_IS_DR_100, decode_cs_REG_IS_DR_101, decode_cs_REG_IS_DR_110, decode_cs_REG_IS_DR_111;
    wire decode_cs_REG_IS_SEGMENT_000, decode_cs_REG_IS_SEGMENT_001, decode_cs_REG_IS_SEGMENT_010, decode_cs_REG_IS_SEGMENT_011, decode_cs_REG_IS_SEGMENT_100, decode_cs_REG_IS_SEGMENT_101, decode_cs_REG_IS_SEGMENT_110, decode_cs_REG_IS_SEGMENT_111;
    wire decode_cs_HARDCODED_DR_HIGH8_000, decode_cs_HARDCODED_DR_HIGH8_001, decode_cs_HARDCODED_DR_HIGH8_010, decode_cs_HARDCODED_DR_HIGH8_011, decode_cs_HARDCODED_DR_HIGH8_100, decode_cs_HARDCODED_DR_HIGH8_101, decode_cs_HARDCODED_DR_HIGH8_110, decode_cs_HARDCODED_DR_HIGH8_111;
    wire decode_cs_MODRM_BUT_NO_SR_000, decode_cs_MODRM_BUT_NO_SR_001, decode_cs_MODRM_BUT_NO_SR_010, decode_cs_MODRM_BUT_NO_SR_011, decode_cs_MODRM_BUT_NO_SR_100, decode_cs_MODRM_BUT_NO_SR_101, decode_cs_MODRM_BUT_NO_SR_110, decode_cs_MODRM_BUT_NO_SR_111;
    wire decode_cs_HARDCODED_DR_000, decode_cs_HARDCODED_DR_001, decode_cs_HARDCODED_DR_010, decode_cs_HARDCODED_DR_011, decode_cs_HARDCODED_DR_100, decode_cs_HARDCODED_DR_101, decode_cs_HARDCODED_DR_110, decode_cs_HARDCODED_DR_111;
    wire decode_cs_HARDCODED_SR_000, decode_cs_HARDCODED_SR_001, decode_cs_HARDCODED_SR_010, decode_cs_HARDCODED_SR_011, decode_cs_HARDCODED_SR_100, decode_cs_HARDCODED_SR_101, decode_cs_HARDCODED_SR_110, decode_cs_HARDCODED_SR_111;
    wire decode_cs_HARDCODED_DR_RD_000, decode_cs_HARDCODED_DR_RD_001, decode_cs_HARDCODED_DR_RD_010, decode_cs_HARDCODED_DR_RD_011, decode_cs_HARDCODED_DR_RD_100, decode_cs_HARDCODED_DR_RD_101, decode_cs_HARDCODED_DR_RD_110, decode_cs_HARDCODED_DR_RD_111;
    wire decode_cs_HARDCODED_DR_WR_000, decode_cs_HARDCODED_DR_WR_001, decode_cs_HARDCODED_DR_WR_010, decode_cs_HARDCODED_DR_WR_011, decode_cs_HARDCODED_DR_WR_100, decode_cs_HARDCODED_DR_WR_101, decode_cs_HARDCODED_DR_WR_110, decode_cs_HARDCODED_DR_WR_111;
    wire decode_cs_HARDCODED_SR_RD_000, decode_cs_HARDCODED_SR_RD_001, decode_cs_HARDCODED_SR_RD_010, decode_cs_HARDCODED_SR_RD_011, decode_cs_HARDCODED_SR_RD_100, decode_cs_HARDCODED_SR_RD_101, decode_cs_HARDCODED_SR_RD_110, decode_cs_HARDCODED_SR_RD_111;
    wire decode_cs_HARDCODED_SR_WR_000, decode_cs_HARDCODED_SR_WR_001, decode_cs_HARDCODED_SR_WR_010, decode_cs_HARDCODED_SR_WR_011, decode_cs_HARDCODED_SR_WR_100, decode_cs_HARDCODED_SR_WR_101, decode_cs_HARDCODED_SR_WR_110, decode_cs_HARDCODED_SR_WR_111;
    wire decode_cs_HARDCODED_LD_OP_000, decode_cs_HARDCODED_LD_OP_001, decode_cs_HARDCODED_LD_OP_010, decode_cs_HARDCODED_LD_OP_011, decode_cs_HARDCODED_LD_OP_100, decode_cs_HARDCODED_LD_OP_101, decode_cs_HARDCODED_LD_OP_110, decode_cs_HARDCODED_LD_OP_111;
    wire decode_cs_HARDCODED_ST_OP_000, decode_cs_HARDCODED_ST_OP_001, decode_cs_HARDCODED_ST_OP_010, decode_cs_HARDCODED_ST_OP_011, decode_cs_HARDCODED_ST_OP_100, decode_cs_HARDCODED_ST_OP_101, decode_cs_HARDCODED_ST_OP_110, decode_cs_HARDCODED_ST_OP_111;
    wire decode_cs_LD_OP_CANCEL_000, decode_cs_LD_OP_CANCEL_001, decode_cs_LD_OP_CANCEL_010, decode_cs_LD_OP_CANCEL_011, decode_cs_LD_OP_CANCEL_100, decode_cs_LD_OP_CANCEL_101, decode_cs_LD_OP_CANCEL_110, decode_cs_LD_OP_CANCEL_111;
    wire decode_cs_ST_OP_CANCEL_000, decode_cs_ST_OP_CANCEL_001, decode_cs_ST_OP_CANCEL_010, decode_cs_ST_OP_CANCEL_011, decode_cs_ST_OP_CANCEL_100, decode_cs_ST_OP_CANCEL_101, decode_cs_ST_OP_CANCEL_110, decode_cs_ST_OP_CANCEL_111;
    wire decode_cs_OP_IN_MODRM_000, decode_cs_OP_IN_MODRM_001, decode_cs_OP_IN_MODRM_010, decode_cs_OP_IN_MODRM_011, decode_cs_OP_IN_MODRM_100, decode_cs_OP_IN_MODRM_101, decode_cs_OP_IN_MODRM_110, decode_cs_OP_IN_MODRM_111;

    // -- decode_cs multi-bit muxed --
    wire [`REG_ID_W-1:0] decode_cs_HARDCODED_DR_ID_000, decode_cs_HARDCODED_DR_ID_001, decode_cs_HARDCODED_DR_ID_010, decode_cs_HARDCODED_DR_ID_011, decode_cs_HARDCODED_DR_ID_100, decode_cs_HARDCODED_DR_ID_101, decode_cs_HARDCODED_DR_ID_110, decode_cs_HARDCODED_DR_ID_111;
    wire [`REG_ID_W-1:0] decode_cs_HARDCODED_SR_ID_000, decode_cs_HARDCODED_SR_ID_001, decode_cs_HARDCODED_SR_ID_010, decode_cs_HARDCODED_SR_ID_011, decode_cs_HARDCODED_SR_ID_100, decode_cs_HARDCODED_SR_ID_101, decode_cs_HARDCODED_SR_ID_110, decode_cs_HARDCODED_SR_ID_111;
    wire [1:0] decode_cs_DATA_SIZE_000, decode_cs_DATA_SIZE_001, decode_cs_DATA_SIZE_010, decode_cs_DATA_SIZE_011, decode_cs_DATA_SIZE_100, decode_cs_DATA_SIZE_101, decode_cs_DATA_SIZE_110, decode_cs_DATA_SIZE_111;

    // -- rr_cs 1-bit muxed --
    wire rr_cs_ST_SEL_000, rr_cs_ST_SEL_001, rr_cs_ST_SEL_010, rr_cs_ST_SEL_011, rr_cs_ST_SEL_100, rr_cs_ST_SEL_101, rr_cs_ST_SEL_110, rr_cs_ST_SEL_111;
    wire rr_cs_MODRM_NEEDED_000, rr_cs_MODRM_NEEDED_001, rr_cs_MODRM_NEEDED_010, rr_cs_MODRM_NEEDED_011, rr_cs_MODRM_NEEDED_100, rr_cs_MODRM_NEEDED_101, rr_cs_MODRM_NEEDED_110, rr_cs_MODRM_NEEDED_111;
    wire rr_cs_RM_IS_DR_000, rr_cs_RM_IS_DR_001, rr_cs_RM_IS_DR_010, rr_cs_RM_IS_DR_011, rr_cs_RM_IS_DR_100, rr_cs_RM_IS_DR_101, rr_cs_RM_IS_DR_110, rr_cs_RM_IS_DR_111;
    wire rr_cs_SWITCH_LD_ADDY_000, rr_cs_SWITCH_LD_ADDY_001, rr_cs_SWITCH_LD_ADDY_010, rr_cs_SWITCH_LD_ADDY_011, rr_cs_SWITCH_LD_ADDY_100, rr_cs_SWITCH_LD_ADDY_101, rr_cs_SWITCH_LD_ADDY_110, rr_cs_SWITCH_LD_ADDY_111;
    wire rr_cs_LD_OP_000, rr_cs_LD_OP_001, rr_cs_LD_OP_010, rr_cs_LD_OP_011, rr_cs_LD_OP_100, rr_cs_LD_OP_101, rr_cs_LD_OP_110, rr_cs_LD_OP_111;
    wire rr_cs_ST_OP_000, rr_cs_ST_OP_001, rr_cs_ST_OP_010, rr_cs_ST_OP_011, rr_cs_ST_OP_100, rr_cs_ST_OP_101, rr_cs_ST_OP_110, rr_cs_ST_OP_111;
    wire rr_cs_dr_rd_000, rr_cs_dr_rd_001, rr_cs_dr_rd_010, rr_cs_dr_rd_011, rr_cs_dr_rd_100, rr_cs_dr_rd_101, rr_cs_dr_rd_110, rr_cs_dr_rd_111;
    wire rr_cs_sr_rd_000, rr_cs_sr_rd_001, rr_cs_sr_rd_010, rr_cs_sr_rd_011, rr_cs_sr_rd_100, rr_cs_sr_rd_101, rr_cs_sr_rd_110, rr_cs_sr_rd_111;
    wire rr_cs_eax_rd_000, rr_cs_eax_rd_001, rr_cs_eax_rd_010, rr_cs_eax_rd_011, rr_cs_eax_rd_100, rr_cs_eax_rd_101, rr_cs_eax_rd_110, rr_cs_eax_rd_111;
    wire rr_cs_dr_wr_000, rr_cs_dr_wr_001, rr_cs_dr_wr_010, rr_cs_dr_wr_011, rr_cs_dr_wr_100, rr_cs_dr_wr_101, rr_cs_dr_wr_110, rr_cs_dr_wr_111;
    wire rr_cs_sr_wr_000, rr_cs_sr_wr_001, rr_cs_sr_wr_010, rr_cs_sr_wr_011, rr_cs_sr_wr_100, rr_cs_sr_wr_101, rr_cs_sr_wr_110, rr_cs_sr_wr_111;
    wire rr_cs_eax_wr_000, rr_cs_eax_wr_001, rr_cs_eax_wr_010, rr_cs_eax_wr_011, rr_cs_eax_wr_100, rr_cs_eax_wr_101, rr_cs_eax_wr_110, rr_cs_eax_wr_111;
    wire rr_cs_MOVS_OP_000, rr_cs_MOVS_OP_001, rr_cs_MOVS_OP_010, rr_cs_MOVS_OP_011, rr_cs_MOVS_OP_100, rr_cs_MOVS_OP_101, rr_cs_MOVS_OP_110, rr_cs_MOVS_OP_111;
    wire rr_cs_will_mod_zf_000, rr_cs_will_mod_zf_001, rr_cs_will_mod_zf_010, rr_cs_will_mod_zf_011, rr_cs_will_mod_zf_100, rr_cs_will_mod_zf_101, rr_cs_will_mod_zf_110, rr_cs_will_mod_zf_111;
    wire rr_cs_seg_1_valid_000, rr_cs_seg_1_valid_001, rr_cs_seg_1_valid_010, rr_cs_seg_1_valid_011, rr_cs_seg_1_valid_100, rr_cs_seg_1_valid_101, rr_cs_seg_1_valid_110, rr_cs_seg_1_valid_111;
    wire rr_cs_special_modrm_bs_000, rr_cs_special_modrm_bs_001, rr_cs_special_modrm_bs_010, rr_cs_special_modrm_bs_011, rr_cs_special_modrm_bs_100, rr_cs_special_modrm_bs_101, rr_cs_special_modrm_bs_110, rr_cs_special_modrm_bs_111;
    wire rr_cs_special_br_000, rr_cs_special_br_001, rr_cs_special_br_010, rr_cs_special_br_011, rr_cs_special_br_100, rr_cs_special_br_101, rr_cs_special_br_110, rr_cs_special_br_111;

    // -- rr_cs multi-bit muxed --
    wire [`REG_ID_W-1:0] rr_cs_dr_id_000, rr_cs_dr_id_001, rr_cs_dr_id_010, rr_cs_dr_id_011, rr_cs_dr_id_100, rr_cs_dr_id_101, rr_cs_dr_id_110, rr_cs_dr_id_111;
    wire [`REG_ID_W-1:0] rr_cs_sr_id_000, rr_cs_sr_id_001, rr_cs_sr_id_010, rr_cs_sr_id_011, rr_cs_sr_id_100, rr_cs_sr_id_101, rr_cs_sr_id_110, rr_cs_sr_id_111;
    wire [`REG_ID_W-1:0] rr_cs_seg_0_id_000, rr_cs_seg_0_id_001, rr_cs_seg_0_id_010, rr_cs_seg_0_id_011, rr_cs_seg_0_id_100, rr_cs_seg_0_id_101, rr_cs_seg_0_id_110, rr_cs_seg_0_id_111;
    wire [`REG_ID_W-1:0] rr_cs_seg_1_id_000, rr_cs_seg_1_id_001, rr_cs_seg_1_id_010, rr_cs_seg_1_id_011, rr_cs_seg_1_id_100, rr_cs_seg_1_id_101, rr_cs_seg_1_id_110, rr_cs_seg_1_id_111;
    wire [1:0] rr_cs_datasize_000, rr_cs_datasize_001, rr_cs_datasize_010, rr_cs_datasize_011, rr_cs_datasize_100, rr_cs_datasize_101, rr_cs_datasize_110, rr_cs_datasize_111;

    // -- dc_cs muxed --
    wire dc_cs_LD_OP_000, dc_cs_LD_OP_001, dc_cs_LD_OP_010, dc_cs_LD_OP_011, dc_cs_LD_OP_100, dc_cs_LD_OP_101, dc_cs_LD_OP_110, dc_cs_LD_OP_111;
    wire dc_cs_ST_OP_000, dc_cs_ST_OP_001, dc_cs_ST_OP_010, dc_cs_ST_OP_011, dc_cs_ST_OP_100, dc_cs_ST_OP_101, dc_cs_ST_OP_110, dc_cs_ST_OP_111;
    wire dc_cs_dr_upper8_000, dc_cs_dr_upper8_001, dc_cs_dr_upper8_010, dc_cs_dr_upper8_011, dc_cs_dr_upper8_100, dc_cs_dr_upper8_101, dc_cs_dr_upper8_110, dc_cs_dr_upper8_111;
    wire dc_cs_sr_upper8_000, dc_cs_sr_upper8_001, dc_cs_sr_upper8_010, dc_cs_sr_upper8_011, dc_cs_sr_upper8_100, dc_cs_sr_upper8_101, dc_cs_sr_upper8_110, dc_cs_sr_upper8_111;
    wire [1:0] dc_cs_datasize_000, dc_cs_datasize_001, dc_cs_datasize_010, dc_cs_datasize_011, dc_cs_datasize_100, dc_cs_datasize_101, dc_cs_datasize_110, dc_cs_datasize_111;

    // -- mem_cs muxed --
    wire mem_cs_ST_OP_000, mem_cs_ST_OP_001, mem_cs_ST_OP_010, mem_cs_ST_OP_011, mem_cs_ST_OP_100, mem_cs_ST_OP_101, mem_cs_ST_OP_110, mem_cs_ST_OP_111;
    wire mem_cs_LD_OP_000, mem_cs_LD_OP_001, mem_cs_LD_OP_010, mem_cs_LD_OP_011, mem_cs_LD_OP_100, mem_cs_LD_OP_101, mem_cs_LD_OP_110, mem_cs_LD_OP_111;

    // -- exe_cs 1-bit muxed --
    wire exe_cs_ST_OP_000, exe_cs_ST_OP_001, exe_cs_ST_OP_010, exe_cs_ST_OP_011, exe_cs_ST_OP_100, exe_cs_ST_OP_101, exe_cs_ST_OP_110, exe_cs_ST_OP_111;
    wire exe_cs_shift_by_one_000, exe_cs_shift_by_one_001, exe_cs_shift_by_one_010, exe_cs_shift_by_one_011, exe_cs_shift_by_one_100, exe_cs_shift_by_one_101, exe_cs_shift_by_one_110, exe_cs_shift_by_one_111;
    wire exe_cs_br_ucond_000, exe_cs_br_ucond_001, exe_cs_br_ucond_010, exe_cs_br_ucond_011, exe_cs_br_ucond_100, exe_cs_br_ucond_101, exe_cs_br_ucond_110, exe_cs_br_ucond_111;
    wire exe_cs_relative_branch_000, exe_cs_relative_branch_001, exe_cs_relative_branch_010, exe_cs_relative_branch_011, exe_cs_relative_branch_100, exe_cs_relative_branch_101, exe_cs_relative_branch_110, exe_cs_relative_branch_111;
    wire exe_cs_special_br_000, exe_cs_special_br_001, exe_cs_special_br_010, exe_cs_special_br_011, exe_cs_special_br_100, exe_cs_special_br_101, exe_cs_special_br_110, exe_cs_special_br_111;
    wire exe_cs_is_far_000, exe_cs_is_far_001, exe_cs_is_far_010, exe_cs_is_far_011, exe_cs_is_far_100, exe_cs_is_far_101, exe_cs_is_far_110, exe_cs_is_far_111;
    wire exe_cs_is_call_000, exe_cs_is_call_001, exe_cs_is_call_010, exe_cs_is_call_011, exe_cs_is_call_100, exe_cs_is_call_101, exe_cs_is_call_110, exe_cs_is_call_111;
    wire exe_cs_second_flag_needed_000, exe_cs_second_flag_needed_001, exe_cs_second_flag_needed_010, exe_cs_second_flag_needed_011, exe_cs_second_flag_needed_100, exe_cs_second_flag_needed_101, exe_cs_second_flag_needed_110, exe_cs_second_flag_needed_111;
    wire exe_cs_rep_no_zf_update_000, exe_cs_rep_no_zf_update_001, exe_cs_rep_no_zf_update_010, exe_cs_rep_no_zf_update_011, exe_cs_rep_no_zf_update_100, exe_cs_rep_no_zf_update_101, exe_cs_rep_no_zf_update_110, exe_cs_rep_no_zf_update_111;

    // -- exe_cs multi-bit muxed --
    wire [`EXE_OP_W-1:0] exe_cs_OP_TYPE_000, exe_cs_OP_TYPE_001, exe_cs_OP_TYPE_010, exe_cs_OP_TYPE_011, exe_cs_OP_TYPE_100, exe_cs_OP_TYPE_101, exe_cs_OP_TYPE_110, exe_cs_OP_TYPE_111;
    wire [`SRC_SEL_W-1:0] exe_cs_alu_inputA_sel_000, exe_cs_alu_inputA_sel_001, exe_cs_alu_inputA_sel_010, exe_cs_alu_inputA_sel_011, exe_cs_alu_inputA_sel_100, exe_cs_alu_inputA_sel_101, exe_cs_alu_inputA_sel_110, exe_cs_alu_inputA_sel_111;
    wire [`SRC_SEL_W-1:0] exe_cs_alu_inputB_sel_000, exe_cs_alu_inputB_sel_001, exe_cs_alu_inputB_sel_010, exe_cs_alu_inputB_sel_011, exe_cs_alu_inputB_sel_100, exe_cs_alu_inputB_sel_101, exe_cs_alu_inputB_sel_110, exe_cs_alu_inputB_sel_111;
    wire [`SRC_SEL_W-1:0] exe_cs_branch_target_sel_000, exe_cs_branch_target_sel_001, exe_cs_branch_target_sel_010, exe_cs_branch_target_sel_011, exe_cs_branch_target_sel_100, exe_cs_branch_target_sel_101, exe_cs_branch_target_sel_110, exe_cs_branch_target_sel_111;

    // -- wb_cs muxed --
    wire wb_cs_ST_OP_000, wb_cs_ST_OP_001, wb_cs_ST_OP_010, wb_cs_ST_OP_011, wb_cs_ST_OP_100, wb_cs_ST_OP_101, wb_cs_ST_OP_110, wb_cs_ST_OP_111;
    wire wb_cs_WB_DR_000, wb_cs_WB_DR_001, wb_cs_WB_DR_010, wb_cs_WB_DR_011, wb_cs_WB_DR_100, wb_cs_WB_DR_101, wb_cs_WB_DR_110, wb_cs_WB_DR_111;
    wire wb_cs_WB_SR_000, wb_cs_WB_SR_001, wb_cs_WB_SR_010, wb_cs_WB_SR_011, wb_cs_WB_SR_100, wb_cs_WB_SR_101, wb_cs_WB_SR_110, wb_cs_WB_SR_111;
    wire wb_cs_WB_EAX_000, wb_cs_WB_EAX_001, wb_cs_WB_EAX_010, wb_cs_WB_EAX_011, wb_cs_WB_EAX_100, wb_cs_WB_EAX_101, wb_cs_WB_EAX_110, wb_cs_WB_EAX_111;

    // === 32 parallel control_store instantiations ===

    control_store cs0_000 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b0), .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b0),
        .opcode(IR[0*8 +: 8]), .modrm(IR[1*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_000_x[0]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_000_x[0]),
        .decode_cs_HALT(decode_cs_HALT_000_x[0]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_000_x[0]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_000_x[0]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_000_x[0]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_000_x[0]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_000_x[0]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_000_x[0]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_000_x[0]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_000_x[0]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_000_x[0]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_000_x[0]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_000_x[0]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_000_x[0]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_000_x[0]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_000_x[0]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_000_x[0]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_000_x[0]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_000_x[0]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_000_x[0]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_000_x[0]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_000_x[0]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_000_x[0]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_000_x[0]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_000_x[0]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_000_x[0]),
        .rr_cs_LD_OP(rr_cs_LD_OP_000_x[0]),
        .rr_cs_ST_OP(rr_cs_ST_OP_000_x[0]),
        .rr_cs_dr_id(rr_cs_dr_id_000_x[0]),
        .rr_cs_sr_id(rr_cs_sr_id_000_x[0]),
        .rr_cs_dr_rd(rr_cs_dr_rd_000_x[0]),
        .rr_cs_sr_rd(rr_cs_sr_rd_000_x[0]),
        .rr_cs_eax_rd(rr_cs_eax_rd_000_x[0]),
        .rr_cs_dr_wr(rr_cs_dr_wr_000_x[0]),
        .rr_cs_sr_wr(rr_cs_sr_wr_000_x[0]),
        .rr_cs_eax_wr(rr_cs_eax_wr_000_x[0]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_000_x[0]),
        .rr_cs_datasize(rr_cs_datasize_000_x[0]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_000_x[0]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_000_x[0]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_000_x[0]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_000_x[0]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_000_x[0]),
        .rr_cs_special_br(rr_cs_special_br_000_x[0]),
        .dc_cs_LD_OP(dc_cs_LD_OP_000_x[0]),
        .dc_cs_ST_OP(dc_cs_ST_OP_000_x[0]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_000_x[0]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_000_x[0]),
        .dc_cs_datasize(dc_cs_datasize_000_x[0]),
        .mem_cs_ST_OP(mem_cs_ST_OP_000_x[0]),
        .mem_cs_LD_OP(mem_cs_LD_OP_000_x[0]),
        .exe_cs_ST_OP(exe_cs_ST_OP_000_x[0]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_000_x[0]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_000_x[0]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_000_x[0]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_000_x[0]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_000_x[0]),
        .exe_cs_br_ucond(exe_cs_br_ucond_000_x[0]),
        .exe_cs_relative_branch(exe_cs_relative_branch_000_x[0]),
        .exe_cs_special_br(exe_cs_special_br_000_x[0]),
        .exe_cs_is_far(exe_cs_is_far_000_x[0]),
        .exe_cs_is_call(exe_cs_is_call_000_x[0]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_000_x[0]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_000_x[0]),
        .wb_cs_ST_OP(wb_cs_ST_OP_000_x[0]),
        .wb_cs_WB_DR(wb_cs_WB_DR_000_x[0]),
        .wb_cs_WB_SR(wb_cs_WB_SR_000_x[0]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_000_x[0])
    );
    control_store cs0_001 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b1), .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b0),
        .opcode(IR[0*8 +: 8]), .modrm(IR[1*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_001_x[0]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_001_x[0]),
        .decode_cs_HALT(decode_cs_HALT_001_x[0]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_001_x[0]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_001_x[0]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_001_x[0]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_001_x[0]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_001_x[0]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_001_x[0]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_001_x[0]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_001_x[0]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_001_x[0]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_001_x[0]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_001_x[0]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_001_x[0]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_001_x[0]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_001_x[0]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_001_x[0]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_001_x[0]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_001_x[0]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_001_x[0]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_001_x[0]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_001_x[0]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_001_x[0]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_001_x[0]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_001_x[0]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_001_x[0]),
        .rr_cs_LD_OP(rr_cs_LD_OP_001_x[0]),
        .rr_cs_ST_OP(rr_cs_ST_OP_001_x[0]),
        .rr_cs_dr_id(rr_cs_dr_id_001_x[0]),
        .rr_cs_sr_id(rr_cs_sr_id_001_x[0]),
        .rr_cs_dr_rd(rr_cs_dr_rd_001_x[0]),
        .rr_cs_sr_rd(rr_cs_sr_rd_001_x[0]),
        .rr_cs_eax_rd(rr_cs_eax_rd_001_x[0]),
        .rr_cs_dr_wr(rr_cs_dr_wr_001_x[0]),
        .rr_cs_sr_wr(rr_cs_sr_wr_001_x[0]),
        .rr_cs_eax_wr(rr_cs_eax_wr_001_x[0]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_001_x[0]),
        .rr_cs_datasize(rr_cs_datasize_001_x[0]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_001_x[0]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_001_x[0]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_001_x[0]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_001_x[0]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_001_x[0]),
        .rr_cs_special_br(rr_cs_special_br_001_x[0]),
        .dc_cs_LD_OP(dc_cs_LD_OP_001_x[0]),
        .dc_cs_ST_OP(dc_cs_ST_OP_001_x[0]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_001_x[0]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_001_x[0]),
        .dc_cs_datasize(dc_cs_datasize_001_x[0]),
        .mem_cs_ST_OP(mem_cs_ST_OP_001_x[0]),
        .mem_cs_LD_OP(mem_cs_LD_OP_001_x[0]),
        .exe_cs_ST_OP(exe_cs_ST_OP_001_x[0]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_001_x[0]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_001_x[0]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_001_x[0]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_001_x[0]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_001_x[0]),
        .exe_cs_br_ucond(exe_cs_br_ucond_001_x[0]),
        .exe_cs_relative_branch(exe_cs_relative_branch_001_x[0]),
        .exe_cs_special_br(exe_cs_special_br_001_x[0]),
        .exe_cs_is_far(exe_cs_is_far_001_x[0]),
        .exe_cs_is_call(exe_cs_is_call_001_x[0]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_001_x[0]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_001_x[0]),
        .wb_cs_ST_OP(wb_cs_ST_OP_001_x[0]),
        .wb_cs_WB_DR(wb_cs_WB_DR_001_x[0]),
        .wb_cs_WB_SR(wb_cs_WB_SR_001_x[0]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_001_x[0])
    );
    control_store cs0_010 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b0), .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b0),
        .opcode(IR[0*8 +: 8]), .modrm(IR[1*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_010_x[0]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_010_x[0]),
        .decode_cs_HALT(decode_cs_HALT_010_x[0]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_010_x[0]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_010_x[0]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_010_x[0]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_010_x[0]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_010_x[0]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_010_x[0]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_010_x[0]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_010_x[0]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_010_x[0]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_010_x[0]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_010_x[0]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_010_x[0]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_010_x[0]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_010_x[0]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_010_x[0]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_010_x[0]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_010_x[0]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_010_x[0]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_010_x[0]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_010_x[0]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_010_x[0]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_010_x[0]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_010_x[0]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_010_x[0]),
        .rr_cs_LD_OP(rr_cs_LD_OP_010_x[0]),
        .rr_cs_ST_OP(rr_cs_ST_OP_010_x[0]),
        .rr_cs_dr_id(rr_cs_dr_id_010_x[0]),
        .rr_cs_sr_id(rr_cs_sr_id_010_x[0]),
        .rr_cs_dr_rd(rr_cs_dr_rd_010_x[0]),
        .rr_cs_sr_rd(rr_cs_sr_rd_010_x[0]),
        .rr_cs_eax_rd(rr_cs_eax_rd_010_x[0]),
        .rr_cs_dr_wr(rr_cs_dr_wr_010_x[0]),
        .rr_cs_sr_wr(rr_cs_sr_wr_010_x[0]),
        .rr_cs_eax_wr(rr_cs_eax_wr_010_x[0]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_010_x[0]),
        .rr_cs_datasize(rr_cs_datasize_010_x[0]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_010_x[0]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_010_x[0]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_010_x[0]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_010_x[0]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_010_x[0]),
        .rr_cs_special_br(rr_cs_special_br_010_x[0]),
        .dc_cs_LD_OP(dc_cs_LD_OP_010_x[0]),
        .dc_cs_ST_OP(dc_cs_ST_OP_010_x[0]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_010_x[0]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_010_x[0]),
        .dc_cs_datasize(dc_cs_datasize_010_x[0]),
        .mem_cs_ST_OP(mem_cs_ST_OP_010_x[0]),
        .mem_cs_LD_OP(mem_cs_LD_OP_010_x[0]),
        .exe_cs_ST_OP(exe_cs_ST_OP_010_x[0]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_010_x[0]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_010_x[0]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_010_x[0]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_010_x[0]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_010_x[0]),
        .exe_cs_br_ucond(exe_cs_br_ucond_010_x[0]),
        .exe_cs_relative_branch(exe_cs_relative_branch_010_x[0]),
        .exe_cs_special_br(exe_cs_special_br_010_x[0]),
        .exe_cs_is_far(exe_cs_is_far_010_x[0]),
        .exe_cs_is_call(exe_cs_is_call_010_x[0]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_010_x[0]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_010_x[0]),
        .wb_cs_ST_OP(wb_cs_ST_OP_010_x[0]),
        .wb_cs_WB_DR(wb_cs_WB_DR_010_x[0]),
        .wb_cs_WB_SR(wb_cs_WB_SR_010_x[0]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_010_x[0])
    );
    control_store cs0_011 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b1), .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b0),
        .opcode(IR[0*8 +: 8]), .modrm(IR[1*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_011_x[0]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_011_x[0]),
        .decode_cs_HALT(decode_cs_HALT_011_x[0]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_011_x[0]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_011_x[0]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_011_x[0]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_011_x[0]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_011_x[0]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_011_x[0]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_011_x[0]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_011_x[0]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_011_x[0]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_011_x[0]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_011_x[0]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_011_x[0]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_011_x[0]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_011_x[0]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_011_x[0]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_011_x[0]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_011_x[0]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_011_x[0]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_011_x[0]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_011_x[0]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_011_x[0]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_011_x[0]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_011_x[0]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_011_x[0]),
        .rr_cs_LD_OP(rr_cs_LD_OP_011_x[0]),
        .rr_cs_ST_OP(rr_cs_ST_OP_011_x[0]),
        .rr_cs_dr_id(rr_cs_dr_id_011_x[0]),
        .rr_cs_sr_id(rr_cs_sr_id_011_x[0]),
        .rr_cs_dr_rd(rr_cs_dr_rd_011_x[0]),
        .rr_cs_sr_rd(rr_cs_sr_rd_011_x[0]),
        .rr_cs_eax_rd(rr_cs_eax_rd_011_x[0]),
        .rr_cs_dr_wr(rr_cs_dr_wr_011_x[0]),
        .rr_cs_sr_wr(rr_cs_sr_wr_011_x[0]),
        .rr_cs_eax_wr(rr_cs_eax_wr_011_x[0]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_011_x[0]),
        .rr_cs_datasize(rr_cs_datasize_011_x[0]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_011_x[0]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_011_x[0]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_011_x[0]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_011_x[0]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_011_x[0]),
        .rr_cs_special_br(rr_cs_special_br_011_x[0]),
        .dc_cs_LD_OP(dc_cs_LD_OP_011_x[0]),
        .dc_cs_ST_OP(dc_cs_ST_OP_011_x[0]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_011_x[0]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_011_x[0]),
        .dc_cs_datasize(dc_cs_datasize_011_x[0]),
        .mem_cs_ST_OP(mem_cs_ST_OP_011_x[0]),
        .mem_cs_LD_OP(mem_cs_LD_OP_011_x[0]),
        .exe_cs_ST_OP(exe_cs_ST_OP_011_x[0]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_011_x[0]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_011_x[0]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_011_x[0]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_011_x[0]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_011_x[0]),
        .exe_cs_br_ucond(exe_cs_br_ucond_011_x[0]),
        .exe_cs_relative_branch(exe_cs_relative_branch_011_x[0]),
        .exe_cs_special_br(exe_cs_special_br_011_x[0]),
        .exe_cs_is_far(exe_cs_is_far_011_x[0]),
        .exe_cs_is_call(exe_cs_is_call_011_x[0]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_011_x[0]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_011_x[0]),
        .wb_cs_ST_OP(wb_cs_ST_OP_011_x[0]),
        .wb_cs_WB_DR(wb_cs_WB_DR_011_x[0]),
        .wb_cs_WB_SR(wb_cs_WB_SR_011_x[0]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_011_x[0])
    );
    control_store cs0_100 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b0), .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b1),
        .opcode(IR[0*8 +: 8]), .modrm(IR[1*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_100_x[0]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_100_x[0]),
        .decode_cs_HALT(decode_cs_HALT_100_x[0]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_100_x[0]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_100_x[0]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_100_x[0]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_100_x[0]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_100_x[0]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_100_x[0]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_100_x[0]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_100_x[0]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_100_x[0]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_100_x[0]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_100_x[0]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_100_x[0]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_100_x[0]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_100_x[0]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_100_x[0]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_100_x[0]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_100_x[0]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_100_x[0]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_100_x[0]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_100_x[0]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_100_x[0]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_100_x[0]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_100_x[0]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_100_x[0]),
        .rr_cs_LD_OP(rr_cs_LD_OP_100_x[0]),
        .rr_cs_ST_OP(rr_cs_ST_OP_100_x[0]),
        .rr_cs_dr_id(rr_cs_dr_id_100_x[0]),
        .rr_cs_sr_id(rr_cs_sr_id_100_x[0]),
        .rr_cs_dr_rd(rr_cs_dr_rd_100_x[0]),
        .rr_cs_sr_rd(rr_cs_sr_rd_100_x[0]),
        .rr_cs_eax_rd(rr_cs_eax_rd_100_x[0]),
        .rr_cs_dr_wr(rr_cs_dr_wr_100_x[0]),
        .rr_cs_sr_wr(rr_cs_sr_wr_100_x[0]),
        .rr_cs_eax_wr(rr_cs_eax_wr_100_x[0]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_100_x[0]),
        .rr_cs_datasize(rr_cs_datasize_100_x[0]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_100_x[0]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_100_x[0]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_100_x[0]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_100_x[0]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_100_x[0]),
        .rr_cs_special_br(rr_cs_special_br_100_x[0]),
        .dc_cs_LD_OP(dc_cs_LD_OP_100_x[0]),
        .dc_cs_ST_OP(dc_cs_ST_OP_100_x[0]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_100_x[0]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_100_x[0]),
        .dc_cs_datasize(dc_cs_datasize_100_x[0]),
        .mem_cs_ST_OP(mem_cs_ST_OP_100_x[0]),
        .mem_cs_LD_OP(mem_cs_LD_OP_100_x[0]),
        .exe_cs_ST_OP(exe_cs_ST_OP_100_x[0]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_100_x[0]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_100_x[0]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_100_x[0]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_100_x[0]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_100_x[0]),
        .exe_cs_br_ucond(exe_cs_br_ucond_100_x[0]),
        .exe_cs_relative_branch(exe_cs_relative_branch_100_x[0]),
        .exe_cs_special_br(exe_cs_special_br_100_x[0]),
        .exe_cs_is_far(exe_cs_is_far_100_x[0]),
        .exe_cs_is_call(exe_cs_is_call_100_x[0]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_100_x[0]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_100_x[0]),
        .wb_cs_ST_OP(wb_cs_ST_OP_100_x[0]),
        .wb_cs_WB_DR(wb_cs_WB_DR_100_x[0]),
        .wb_cs_WB_SR(wb_cs_WB_SR_100_x[0]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_100_x[0])
    );
    control_store cs0_101 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b1), .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b1),
        .opcode(IR[0*8 +: 8]), .modrm(IR[1*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_101_x[0]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_101_x[0]),
        .decode_cs_HALT(decode_cs_HALT_101_x[0]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_101_x[0]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_101_x[0]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_101_x[0]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_101_x[0]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_101_x[0]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_101_x[0]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_101_x[0]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_101_x[0]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_101_x[0]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_101_x[0]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_101_x[0]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_101_x[0]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_101_x[0]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_101_x[0]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_101_x[0]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_101_x[0]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_101_x[0]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_101_x[0]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_101_x[0]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_101_x[0]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_101_x[0]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_101_x[0]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_101_x[0]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_101_x[0]),
        .rr_cs_LD_OP(rr_cs_LD_OP_101_x[0]),
        .rr_cs_ST_OP(rr_cs_ST_OP_101_x[0]),
        .rr_cs_dr_id(rr_cs_dr_id_101_x[0]),
        .rr_cs_sr_id(rr_cs_sr_id_101_x[0]),
        .rr_cs_dr_rd(rr_cs_dr_rd_101_x[0]),
        .rr_cs_sr_rd(rr_cs_sr_rd_101_x[0]),
        .rr_cs_eax_rd(rr_cs_eax_rd_101_x[0]),
        .rr_cs_dr_wr(rr_cs_dr_wr_101_x[0]),
        .rr_cs_sr_wr(rr_cs_sr_wr_101_x[0]),
        .rr_cs_eax_wr(rr_cs_eax_wr_101_x[0]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_101_x[0]),
        .rr_cs_datasize(rr_cs_datasize_101_x[0]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_101_x[0]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_101_x[0]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_101_x[0]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_101_x[0]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_101_x[0]),
        .rr_cs_special_br(rr_cs_special_br_101_x[0]),
        .dc_cs_LD_OP(dc_cs_LD_OP_101_x[0]),
        .dc_cs_ST_OP(dc_cs_ST_OP_101_x[0]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_101_x[0]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_101_x[0]),
        .dc_cs_datasize(dc_cs_datasize_101_x[0]),
        .mem_cs_ST_OP(mem_cs_ST_OP_101_x[0]),
        .mem_cs_LD_OP(mem_cs_LD_OP_101_x[0]),
        .exe_cs_ST_OP(exe_cs_ST_OP_101_x[0]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_101_x[0]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_101_x[0]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_101_x[0]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_101_x[0]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_101_x[0]),
        .exe_cs_br_ucond(exe_cs_br_ucond_101_x[0]),
        .exe_cs_relative_branch(exe_cs_relative_branch_101_x[0]),
        .exe_cs_special_br(exe_cs_special_br_101_x[0]),
        .exe_cs_is_far(exe_cs_is_far_101_x[0]),
        .exe_cs_is_call(exe_cs_is_call_101_x[0]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_101_x[0]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_101_x[0]),
        .wb_cs_ST_OP(wb_cs_ST_OP_101_x[0]),
        .wb_cs_WB_DR(wb_cs_WB_DR_101_x[0]),
        .wb_cs_WB_SR(wb_cs_WB_SR_101_x[0]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_101_x[0])
    );
    control_store cs0_110 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b0), .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b1),
        .opcode(IR[0*8 +: 8]), .modrm(IR[1*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_110_x[0]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_110_x[0]),
        .decode_cs_HALT(decode_cs_HALT_110_x[0]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_110_x[0]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_110_x[0]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_110_x[0]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_110_x[0]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_110_x[0]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_110_x[0]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_110_x[0]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_110_x[0]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_110_x[0]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_110_x[0]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_110_x[0]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_110_x[0]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_110_x[0]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_110_x[0]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_110_x[0]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_110_x[0]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_110_x[0]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_110_x[0]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_110_x[0]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_110_x[0]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_110_x[0]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_110_x[0]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_110_x[0]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_110_x[0]),
        .rr_cs_LD_OP(rr_cs_LD_OP_110_x[0]),
        .rr_cs_ST_OP(rr_cs_ST_OP_110_x[0]),
        .rr_cs_dr_id(rr_cs_dr_id_110_x[0]),
        .rr_cs_sr_id(rr_cs_sr_id_110_x[0]),
        .rr_cs_dr_rd(rr_cs_dr_rd_110_x[0]),
        .rr_cs_sr_rd(rr_cs_sr_rd_110_x[0]),
        .rr_cs_eax_rd(rr_cs_eax_rd_110_x[0]),
        .rr_cs_dr_wr(rr_cs_dr_wr_110_x[0]),
        .rr_cs_sr_wr(rr_cs_sr_wr_110_x[0]),
        .rr_cs_eax_wr(rr_cs_eax_wr_110_x[0]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_110_x[0]),
        .rr_cs_datasize(rr_cs_datasize_110_x[0]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_110_x[0]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_110_x[0]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_110_x[0]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_110_x[0]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_110_x[0]),
        .rr_cs_special_br(rr_cs_special_br_110_x[0]),
        .dc_cs_LD_OP(dc_cs_LD_OP_110_x[0]),
        .dc_cs_ST_OP(dc_cs_ST_OP_110_x[0]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_110_x[0]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_110_x[0]),
        .dc_cs_datasize(dc_cs_datasize_110_x[0]),
        .mem_cs_ST_OP(mem_cs_ST_OP_110_x[0]),
        .mem_cs_LD_OP(mem_cs_LD_OP_110_x[0]),
        .exe_cs_ST_OP(exe_cs_ST_OP_110_x[0]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_110_x[0]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_110_x[0]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_110_x[0]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_110_x[0]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_110_x[0]),
        .exe_cs_br_ucond(exe_cs_br_ucond_110_x[0]),
        .exe_cs_relative_branch(exe_cs_relative_branch_110_x[0]),
        .exe_cs_special_br(exe_cs_special_br_110_x[0]),
        .exe_cs_is_far(exe_cs_is_far_110_x[0]),
        .exe_cs_is_call(exe_cs_is_call_110_x[0]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_110_x[0]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_110_x[0]),
        .wb_cs_ST_OP(wb_cs_ST_OP_110_x[0]),
        .wb_cs_WB_DR(wb_cs_WB_DR_110_x[0]),
        .wb_cs_WB_SR(wb_cs_WB_SR_110_x[0]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_110_x[0])
    );
    control_store cs0_111 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b1), .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b1),
        .opcode(IR[0*8 +: 8]), .modrm(IR[1*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_111_x[0]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_111_x[0]),
        .decode_cs_HALT(decode_cs_HALT_111_x[0]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_111_x[0]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_111_x[0]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_111_x[0]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_111_x[0]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_111_x[0]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_111_x[0]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_111_x[0]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_111_x[0]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_111_x[0]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_111_x[0]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_111_x[0]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_111_x[0]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_111_x[0]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_111_x[0]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_111_x[0]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_111_x[0]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_111_x[0]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_111_x[0]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_111_x[0]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_111_x[0]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_111_x[0]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_111_x[0]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_111_x[0]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_111_x[0]),
        .rr_cs_LD_OP(rr_cs_LD_OP_111_x[0]),
        .rr_cs_ST_OP(rr_cs_ST_OP_111_x[0]),
        .rr_cs_dr_id(rr_cs_dr_id_111_x[0]),
        .rr_cs_sr_id(rr_cs_sr_id_111_x[0]),
        .rr_cs_dr_rd(rr_cs_dr_rd_111_x[0]),
        .rr_cs_sr_rd(rr_cs_sr_rd_111_x[0]),
        .rr_cs_eax_rd(rr_cs_eax_rd_111_x[0]),
        .rr_cs_dr_wr(rr_cs_dr_wr_111_x[0]),
        .rr_cs_sr_wr(rr_cs_sr_wr_111_x[0]),
        .rr_cs_eax_wr(rr_cs_eax_wr_111_x[0]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_111_x[0]),
        .rr_cs_datasize(rr_cs_datasize_111_x[0]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_111_x[0]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_111_x[0]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_111_x[0]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_111_x[0]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_111_x[0]),
        .rr_cs_special_br(rr_cs_special_br_111_x[0]),
        .dc_cs_LD_OP(dc_cs_LD_OP_111_x[0]),
        .dc_cs_ST_OP(dc_cs_ST_OP_111_x[0]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_111_x[0]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_111_x[0]),
        .dc_cs_datasize(dc_cs_datasize_111_x[0]),
        .mem_cs_ST_OP(mem_cs_ST_OP_111_x[0]),
        .mem_cs_LD_OP(mem_cs_LD_OP_111_x[0]),
        .exe_cs_ST_OP(exe_cs_ST_OP_111_x[0]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_111_x[0]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_111_x[0]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_111_x[0]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_111_x[0]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_111_x[0]),
        .exe_cs_br_ucond(exe_cs_br_ucond_111_x[0]),
        .exe_cs_relative_branch(exe_cs_relative_branch_111_x[0]),
        .exe_cs_special_br(exe_cs_special_br_111_x[0]),
        .exe_cs_is_far(exe_cs_is_far_111_x[0]),
        .exe_cs_is_call(exe_cs_is_call_111_x[0]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_111_x[0]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_111_x[0]),
        .wb_cs_ST_OP(wb_cs_ST_OP_111_x[0]),
        .wb_cs_WB_DR(wb_cs_WB_DR_111_x[0]),
        .wb_cs_WB_SR(wb_cs_WB_SR_111_x[0]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_111_x[0])
    );
    control_store cs1_000 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b0), .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b0),
        .opcode(IR[1*8 +: 8]), .modrm(IR[2*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_000_x[1]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_000_x[1]),
        .decode_cs_HALT(decode_cs_HALT_000_x[1]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_000_x[1]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_000_x[1]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_000_x[1]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_000_x[1]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_000_x[1]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_000_x[1]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_000_x[1]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_000_x[1]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_000_x[1]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_000_x[1]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_000_x[1]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_000_x[1]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_000_x[1]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_000_x[1]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_000_x[1]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_000_x[1]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_000_x[1]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_000_x[1]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_000_x[1]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_000_x[1]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_000_x[1]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_000_x[1]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_000_x[1]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_000_x[1]),
        .rr_cs_LD_OP(rr_cs_LD_OP_000_x[1]),
        .rr_cs_ST_OP(rr_cs_ST_OP_000_x[1]),
        .rr_cs_dr_id(rr_cs_dr_id_000_x[1]),
        .rr_cs_sr_id(rr_cs_sr_id_000_x[1]),
        .rr_cs_dr_rd(rr_cs_dr_rd_000_x[1]),
        .rr_cs_sr_rd(rr_cs_sr_rd_000_x[1]),
        .rr_cs_eax_rd(rr_cs_eax_rd_000_x[1]),
        .rr_cs_dr_wr(rr_cs_dr_wr_000_x[1]),
        .rr_cs_sr_wr(rr_cs_sr_wr_000_x[1]),
        .rr_cs_eax_wr(rr_cs_eax_wr_000_x[1]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_000_x[1]),
        .rr_cs_datasize(rr_cs_datasize_000_x[1]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_000_x[1]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_000_x[1]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_000_x[1]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_000_x[1]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_000_x[1]),
        .rr_cs_special_br(rr_cs_special_br_000_x[1]),
        .dc_cs_LD_OP(dc_cs_LD_OP_000_x[1]),
        .dc_cs_ST_OP(dc_cs_ST_OP_000_x[1]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_000_x[1]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_000_x[1]),
        .dc_cs_datasize(dc_cs_datasize_000_x[1]),
        .mem_cs_ST_OP(mem_cs_ST_OP_000_x[1]),
        .mem_cs_LD_OP(mem_cs_LD_OP_000_x[1]),
        .exe_cs_ST_OP(exe_cs_ST_OP_000_x[1]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_000_x[1]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_000_x[1]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_000_x[1]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_000_x[1]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_000_x[1]),
        .exe_cs_br_ucond(exe_cs_br_ucond_000_x[1]),
        .exe_cs_relative_branch(exe_cs_relative_branch_000_x[1]),
        .exe_cs_special_br(exe_cs_special_br_000_x[1]),
        .exe_cs_is_far(exe_cs_is_far_000_x[1]),
        .exe_cs_is_call(exe_cs_is_call_000_x[1]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_000_x[1]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_000_x[1]),
        .wb_cs_ST_OP(wb_cs_ST_OP_000_x[1]),
        .wb_cs_WB_DR(wb_cs_WB_DR_000_x[1]),
        .wb_cs_WB_SR(wb_cs_WB_SR_000_x[1]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_000_x[1])
    );
    control_store cs1_001 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b1), .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b0),
        .opcode(IR[1*8 +: 8]), .modrm(IR[2*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_001_x[1]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_001_x[1]),
        .decode_cs_HALT(decode_cs_HALT_001_x[1]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_001_x[1]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_001_x[1]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_001_x[1]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_001_x[1]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_001_x[1]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_001_x[1]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_001_x[1]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_001_x[1]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_001_x[1]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_001_x[1]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_001_x[1]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_001_x[1]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_001_x[1]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_001_x[1]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_001_x[1]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_001_x[1]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_001_x[1]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_001_x[1]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_001_x[1]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_001_x[1]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_001_x[1]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_001_x[1]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_001_x[1]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_001_x[1]),
        .rr_cs_LD_OP(rr_cs_LD_OP_001_x[1]),
        .rr_cs_ST_OP(rr_cs_ST_OP_001_x[1]),
        .rr_cs_dr_id(rr_cs_dr_id_001_x[1]),
        .rr_cs_sr_id(rr_cs_sr_id_001_x[1]),
        .rr_cs_dr_rd(rr_cs_dr_rd_001_x[1]),
        .rr_cs_sr_rd(rr_cs_sr_rd_001_x[1]),
        .rr_cs_eax_rd(rr_cs_eax_rd_001_x[1]),
        .rr_cs_dr_wr(rr_cs_dr_wr_001_x[1]),
        .rr_cs_sr_wr(rr_cs_sr_wr_001_x[1]),
        .rr_cs_eax_wr(rr_cs_eax_wr_001_x[1]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_001_x[1]),
        .rr_cs_datasize(rr_cs_datasize_001_x[1]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_001_x[1]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_001_x[1]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_001_x[1]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_001_x[1]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_001_x[1]),
        .rr_cs_special_br(rr_cs_special_br_001_x[1]),
        .dc_cs_LD_OP(dc_cs_LD_OP_001_x[1]),
        .dc_cs_ST_OP(dc_cs_ST_OP_001_x[1]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_001_x[1]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_001_x[1]),
        .dc_cs_datasize(dc_cs_datasize_001_x[1]),
        .mem_cs_ST_OP(mem_cs_ST_OP_001_x[1]),
        .mem_cs_LD_OP(mem_cs_LD_OP_001_x[1]),
        .exe_cs_ST_OP(exe_cs_ST_OP_001_x[1]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_001_x[1]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_001_x[1]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_001_x[1]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_001_x[1]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_001_x[1]),
        .exe_cs_br_ucond(exe_cs_br_ucond_001_x[1]),
        .exe_cs_relative_branch(exe_cs_relative_branch_001_x[1]),
        .exe_cs_special_br(exe_cs_special_br_001_x[1]),
        .exe_cs_is_far(exe_cs_is_far_001_x[1]),
        .exe_cs_is_call(exe_cs_is_call_001_x[1]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_001_x[1]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_001_x[1]),
        .wb_cs_ST_OP(wb_cs_ST_OP_001_x[1]),
        .wb_cs_WB_DR(wb_cs_WB_DR_001_x[1]),
        .wb_cs_WB_SR(wb_cs_WB_SR_001_x[1]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_001_x[1])
    );
    control_store cs1_010 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b0), .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b0),
        .opcode(IR[1*8 +: 8]), .modrm(IR[2*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_010_x[1]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_010_x[1]),
        .decode_cs_HALT(decode_cs_HALT_010_x[1]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_010_x[1]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_010_x[1]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_010_x[1]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_010_x[1]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_010_x[1]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_010_x[1]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_010_x[1]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_010_x[1]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_010_x[1]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_010_x[1]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_010_x[1]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_010_x[1]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_010_x[1]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_010_x[1]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_010_x[1]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_010_x[1]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_010_x[1]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_010_x[1]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_010_x[1]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_010_x[1]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_010_x[1]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_010_x[1]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_010_x[1]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_010_x[1]),
        .rr_cs_LD_OP(rr_cs_LD_OP_010_x[1]),
        .rr_cs_ST_OP(rr_cs_ST_OP_010_x[1]),
        .rr_cs_dr_id(rr_cs_dr_id_010_x[1]),
        .rr_cs_sr_id(rr_cs_sr_id_010_x[1]),
        .rr_cs_dr_rd(rr_cs_dr_rd_010_x[1]),
        .rr_cs_sr_rd(rr_cs_sr_rd_010_x[1]),
        .rr_cs_eax_rd(rr_cs_eax_rd_010_x[1]),
        .rr_cs_dr_wr(rr_cs_dr_wr_010_x[1]),
        .rr_cs_sr_wr(rr_cs_sr_wr_010_x[1]),
        .rr_cs_eax_wr(rr_cs_eax_wr_010_x[1]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_010_x[1]),
        .rr_cs_datasize(rr_cs_datasize_010_x[1]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_010_x[1]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_010_x[1]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_010_x[1]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_010_x[1]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_010_x[1]),
        .rr_cs_special_br(rr_cs_special_br_010_x[1]),
        .dc_cs_LD_OP(dc_cs_LD_OP_010_x[1]),
        .dc_cs_ST_OP(dc_cs_ST_OP_010_x[1]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_010_x[1]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_010_x[1]),
        .dc_cs_datasize(dc_cs_datasize_010_x[1]),
        .mem_cs_ST_OP(mem_cs_ST_OP_010_x[1]),
        .mem_cs_LD_OP(mem_cs_LD_OP_010_x[1]),
        .exe_cs_ST_OP(exe_cs_ST_OP_010_x[1]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_010_x[1]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_010_x[1]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_010_x[1]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_010_x[1]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_010_x[1]),
        .exe_cs_br_ucond(exe_cs_br_ucond_010_x[1]),
        .exe_cs_relative_branch(exe_cs_relative_branch_010_x[1]),
        .exe_cs_special_br(exe_cs_special_br_010_x[1]),
        .exe_cs_is_far(exe_cs_is_far_010_x[1]),
        .exe_cs_is_call(exe_cs_is_call_010_x[1]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_010_x[1]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_010_x[1]),
        .wb_cs_ST_OP(wb_cs_ST_OP_010_x[1]),
        .wb_cs_WB_DR(wb_cs_WB_DR_010_x[1]),
        .wb_cs_WB_SR(wb_cs_WB_SR_010_x[1]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_010_x[1])
    );
    control_store cs1_011 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b1), .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b0),
        .opcode(IR[1*8 +: 8]), .modrm(IR[2*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_011_x[1]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_011_x[1]),
        .decode_cs_HALT(decode_cs_HALT_011_x[1]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_011_x[1]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_011_x[1]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_011_x[1]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_011_x[1]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_011_x[1]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_011_x[1]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_011_x[1]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_011_x[1]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_011_x[1]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_011_x[1]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_011_x[1]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_011_x[1]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_011_x[1]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_011_x[1]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_011_x[1]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_011_x[1]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_011_x[1]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_011_x[1]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_011_x[1]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_011_x[1]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_011_x[1]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_011_x[1]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_011_x[1]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_011_x[1]),
        .rr_cs_LD_OP(rr_cs_LD_OP_011_x[1]),
        .rr_cs_ST_OP(rr_cs_ST_OP_011_x[1]),
        .rr_cs_dr_id(rr_cs_dr_id_011_x[1]),
        .rr_cs_sr_id(rr_cs_sr_id_011_x[1]),
        .rr_cs_dr_rd(rr_cs_dr_rd_011_x[1]),
        .rr_cs_sr_rd(rr_cs_sr_rd_011_x[1]),
        .rr_cs_eax_rd(rr_cs_eax_rd_011_x[1]),
        .rr_cs_dr_wr(rr_cs_dr_wr_011_x[1]),
        .rr_cs_sr_wr(rr_cs_sr_wr_011_x[1]),
        .rr_cs_eax_wr(rr_cs_eax_wr_011_x[1]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_011_x[1]),
        .rr_cs_datasize(rr_cs_datasize_011_x[1]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_011_x[1]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_011_x[1]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_011_x[1]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_011_x[1]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_011_x[1]),
        .rr_cs_special_br(rr_cs_special_br_011_x[1]),
        .dc_cs_LD_OP(dc_cs_LD_OP_011_x[1]),
        .dc_cs_ST_OP(dc_cs_ST_OP_011_x[1]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_011_x[1]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_011_x[1]),
        .dc_cs_datasize(dc_cs_datasize_011_x[1]),
        .mem_cs_ST_OP(mem_cs_ST_OP_011_x[1]),
        .mem_cs_LD_OP(mem_cs_LD_OP_011_x[1]),
        .exe_cs_ST_OP(exe_cs_ST_OP_011_x[1]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_011_x[1]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_011_x[1]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_011_x[1]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_011_x[1]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_011_x[1]),
        .exe_cs_br_ucond(exe_cs_br_ucond_011_x[1]),
        .exe_cs_relative_branch(exe_cs_relative_branch_011_x[1]),
        .exe_cs_special_br(exe_cs_special_br_011_x[1]),
        .exe_cs_is_far(exe_cs_is_far_011_x[1]),
        .exe_cs_is_call(exe_cs_is_call_011_x[1]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_011_x[1]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_011_x[1]),
        .wb_cs_ST_OP(wb_cs_ST_OP_011_x[1]),
        .wb_cs_WB_DR(wb_cs_WB_DR_011_x[1]),
        .wb_cs_WB_SR(wb_cs_WB_SR_011_x[1]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_011_x[1])
    );
    control_store cs1_100 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b0), .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b1),
        .opcode(IR[1*8 +: 8]), .modrm(IR[2*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_100_x[1]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_100_x[1]),
        .decode_cs_HALT(decode_cs_HALT_100_x[1]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_100_x[1]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_100_x[1]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_100_x[1]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_100_x[1]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_100_x[1]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_100_x[1]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_100_x[1]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_100_x[1]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_100_x[1]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_100_x[1]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_100_x[1]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_100_x[1]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_100_x[1]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_100_x[1]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_100_x[1]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_100_x[1]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_100_x[1]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_100_x[1]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_100_x[1]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_100_x[1]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_100_x[1]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_100_x[1]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_100_x[1]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_100_x[1]),
        .rr_cs_LD_OP(rr_cs_LD_OP_100_x[1]),
        .rr_cs_ST_OP(rr_cs_ST_OP_100_x[1]),
        .rr_cs_dr_id(rr_cs_dr_id_100_x[1]),
        .rr_cs_sr_id(rr_cs_sr_id_100_x[1]),
        .rr_cs_dr_rd(rr_cs_dr_rd_100_x[1]),
        .rr_cs_sr_rd(rr_cs_sr_rd_100_x[1]),
        .rr_cs_eax_rd(rr_cs_eax_rd_100_x[1]),
        .rr_cs_dr_wr(rr_cs_dr_wr_100_x[1]),
        .rr_cs_sr_wr(rr_cs_sr_wr_100_x[1]),
        .rr_cs_eax_wr(rr_cs_eax_wr_100_x[1]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_100_x[1]),
        .rr_cs_datasize(rr_cs_datasize_100_x[1]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_100_x[1]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_100_x[1]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_100_x[1]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_100_x[1]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_100_x[1]),
        .rr_cs_special_br(rr_cs_special_br_100_x[1]),
        .dc_cs_LD_OP(dc_cs_LD_OP_100_x[1]),
        .dc_cs_ST_OP(dc_cs_ST_OP_100_x[1]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_100_x[1]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_100_x[1]),
        .dc_cs_datasize(dc_cs_datasize_100_x[1]),
        .mem_cs_ST_OP(mem_cs_ST_OP_100_x[1]),
        .mem_cs_LD_OP(mem_cs_LD_OP_100_x[1]),
        .exe_cs_ST_OP(exe_cs_ST_OP_100_x[1]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_100_x[1]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_100_x[1]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_100_x[1]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_100_x[1]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_100_x[1]),
        .exe_cs_br_ucond(exe_cs_br_ucond_100_x[1]),
        .exe_cs_relative_branch(exe_cs_relative_branch_100_x[1]),
        .exe_cs_special_br(exe_cs_special_br_100_x[1]),
        .exe_cs_is_far(exe_cs_is_far_100_x[1]),
        .exe_cs_is_call(exe_cs_is_call_100_x[1]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_100_x[1]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_100_x[1]),
        .wb_cs_ST_OP(wb_cs_ST_OP_100_x[1]),
        .wb_cs_WB_DR(wb_cs_WB_DR_100_x[1]),
        .wb_cs_WB_SR(wb_cs_WB_SR_100_x[1]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_100_x[1])
    );
    control_store cs1_101 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b1), .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b1),
        .opcode(IR[1*8 +: 8]), .modrm(IR[2*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_101_x[1]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_101_x[1]),
        .decode_cs_HALT(decode_cs_HALT_101_x[1]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_101_x[1]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_101_x[1]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_101_x[1]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_101_x[1]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_101_x[1]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_101_x[1]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_101_x[1]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_101_x[1]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_101_x[1]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_101_x[1]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_101_x[1]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_101_x[1]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_101_x[1]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_101_x[1]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_101_x[1]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_101_x[1]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_101_x[1]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_101_x[1]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_101_x[1]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_101_x[1]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_101_x[1]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_101_x[1]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_101_x[1]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_101_x[1]),
        .rr_cs_LD_OP(rr_cs_LD_OP_101_x[1]),
        .rr_cs_ST_OP(rr_cs_ST_OP_101_x[1]),
        .rr_cs_dr_id(rr_cs_dr_id_101_x[1]),
        .rr_cs_sr_id(rr_cs_sr_id_101_x[1]),
        .rr_cs_dr_rd(rr_cs_dr_rd_101_x[1]),
        .rr_cs_sr_rd(rr_cs_sr_rd_101_x[1]),
        .rr_cs_eax_rd(rr_cs_eax_rd_101_x[1]),
        .rr_cs_dr_wr(rr_cs_dr_wr_101_x[1]),
        .rr_cs_sr_wr(rr_cs_sr_wr_101_x[1]),
        .rr_cs_eax_wr(rr_cs_eax_wr_101_x[1]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_101_x[1]),
        .rr_cs_datasize(rr_cs_datasize_101_x[1]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_101_x[1]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_101_x[1]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_101_x[1]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_101_x[1]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_101_x[1]),
        .rr_cs_special_br(rr_cs_special_br_101_x[1]),
        .dc_cs_LD_OP(dc_cs_LD_OP_101_x[1]),
        .dc_cs_ST_OP(dc_cs_ST_OP_101_x[1]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_101_x[1]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_101_x[1]),
        .dc_cs_datasize(dc_cs_datasize_101_x[1]),
        .mem_cs_ST_OP(mem_cs_ST_OP_101_x[1]),
        .mem_cs_LD_OP(mem_cs_LD_OP_101_x[1]),
        .exe_cs_ST_OP(exe_cs_ST_OP_101_x[1]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_101_x[1]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_101_x[1]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_101_x[1]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_101_x[1]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_101_x[1]),
        .exe_cs_br_ucond(exe_cs_br_ucond_101_x[1]),
        .exe_cs_relative_branch(exe_cs_relative_branch_101_x[1]),
        .exe_cs_special_br(exe_cs_special_br_101_x[1]),
        .exe_cs_is_far(exe_cs_is_far_101_x[1]),
        .exe_cs_is_call(exe_cs_is_call_101_x[1]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_101_x[1]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_101_x[1]),
        .wb_cs_ST_OP(wb_cs_ST_OP_101_x[1]),
        .wb_cs_WB_DR(wb_cs_WB_DR_101_x[1]),
        .wb_cs_WB_SR(wb_cs_WB_SR_101_x[1]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_101_x[1])
    );
    control_store cs1_110 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b0), .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b1),
        .opcode(IR[1*8 +: 8]), .modrm(IR[2*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_110_x[1]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_110_x[1]),
        .decode_cs_HALT(decode_cs_HALT_110_x[1]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_110_x[1]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_110_x[1]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_110_x[1]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_110_x[1]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_110_x[1]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_110_x[1]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_110_x[1]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_110_x[1]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_110_x[1]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_110_x[1]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_110_x[1]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_110_x[1]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_110_x[1]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_110_x[1]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_110_x[1]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_110_x[1]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_110_x[1]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_110_x[1]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_110_x[1]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_110_x[1]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_110_x[1]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_110_x[1]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_110_x[1]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_110_x[1]),
        .rr_cs_LD_OP(rr_cs_LD_OP_110_x[1]),
        .rr_cs_ST_OP(rr_cs_ST_OP_110_x[1]),
        .rr_cs_dr_id(rr_cs_dr_id_110_x[1]),
        .rr_cs_sr_id(rr_cs_sr_id_110_x[1]),
        .rr_cs_dr_rd(rr_cs_dr_rd_110_x[1]),
        .rr_cs_sr_rd(rr_cs_sr_rd_110_x[1]),
        .rr_cs_eax_rd(rr_cs_eax_rd_110_x[1]),
        .rr_cs_dr_wr(rr_cs_dr_wr_110_x[1]),
        .rr_cs_sr_wr(rr_cs_sr_wr_110_x[1]),
        .rr_cs_eax_wr(rr_cs_eax_wr_110_x[1]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_110_x[1]),
        .rr_cs_datasize(rr_cs_datasize_110_x[1]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_110_x[1]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_110_x[1]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_110_x[1]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_110_x[1]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_110_x[1]),
        .rr_cs_special_br(rr_cs_special_br_110_x[1]),
        .dc_cs_LD_OP(dc_cs_LD_OP_110_x[1]),
        .dc_cs_ST_OP(dc_cs_ST_OP_110_x[1]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_110_x[1]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_110_x[1]),
        .dc_cs_datasize(dc_cs_datasize_110_x[1]),
        .mem_cs_ST_OP(mem_cs_ST_OP_110_x[1]),
        .mem_cs_LD_OP(mem_cs_LD_OP_110_x[1]),
        .exe_cs_ST_OP(exe_cs_ST_OP_110_x[1]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_110_x[1]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_110_x[1]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_110_x[1]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_110_x[1]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_110_x[1]),
        .exe_cs_br_ucond(exe_cs_br_ucond_110_x[1]),
        .exe_cs_relative_branch(exe_cs_relative_branch_110_x[1]),
        .exe_cs_special_br(exe_cs_special_br_110_x[1]),
        .exe_cs_is_far(exe_cs_is_far_110_x[1]),
        .exe_cs_is_call(exe_cs_is_call_110_x[1]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_110_x[1]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_110_x[1]),
        .wb_cs_ST_OP(wb_cs_ST_OP_110_x[1]),
        .wb_cs_WB_DR(wb_cs_WB_DR_110_x[1]),
        .wb_cs_WB_SR(wb_cs_WB_SR_110_x[1]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_110_x[1])
    );
    control_store cs1_111 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b1), .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b1),
        .opcode(IR[1*8 +: 8]), .modrm(IR[2*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_111_x[1]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_111_x[1]),
        .decode_cs_HALT(decode_cs_HALT_111_x[1]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_111_x[1]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_111_x[1]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_111_x[1]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_111_x[1]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_111_x[1]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_111_x[1]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_111_x[1]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_111_x[1]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_111_x[1]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_111_x[1]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_111_x[1]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_111_x[1]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_111_x[1]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_111_x[1]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_111_x[1]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_111_x[1]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_111_x[1]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_111_x[1]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_111_x[1]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_111_x[1]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_111_x[1]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_111_x[1]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_111_x[1]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_111_x[1]),
        .rr_cs_LD_OP(rr_cs_LD_OP_111_x[1]),
        .rr_cs_ST_OP(rr_cs_ST_OP_111_x[1]),
        .rr_cs_dr_id(rr_cs_dr_id_111_x[1]),
        .rr_cs_sr_id(rr_cs_sr_id_111_x[1]),
        .rr_cs_dr_rd(rr_cs_dr_rd_111_x[1]),
        .rr_cs_sr_rd(rr_cs_sr_rd_111_x[1]),
        .rr_cs_eax_rd(rr_cs_eax_rd_111_x[1]),
        .rr_cs_dr_wr(rr_cs_dr_wr_111_x[1]),
        .rr_cs_sr_wr(rr_cs_sr_wr_111_x[1]),
        .rr_cs_eax_wr(rr_cs_eax_wr_111_x[1]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_111_x[1]),
        .rr_cs_datasize(rr_cs_datasize_111_x[1]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_111_x[1]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_111_x[1]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_111_x[1]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_111_x[1]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_111_x[1]),
        .rr_cs_special_br(rr_cs_special_br_111_x[1]),
        .dc_cs_LD_OP(dc_cs_LD_OP_111_x[1]),
        .dc_cs_ST_OP(dc_cs_ST_OP_111_x[1]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_111_x[1]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_111_x[1]),
        .dc_cs_datasize(dc_cs_datasize_111_x[1]),
        .mem_cs_ST_OP(mem_cs_ST_OP_111_x[1]),
        .mem_cs_LD_OP(mem_cs_LD_OP_111_x[1]),
        .exe_cs_ST_OP(exe_cs_ST_OP_111_x[1]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_111_x[1]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_111_x[1]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_111_x[1]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_111_x[1]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_111_x[1]),
        .exe_cs_br_ucond(exe_cs_br_ucond_111_x[1]),
        .exe_cs_relative_branch(exe_cs_relative_branch_111_x[1]),
        .exe_cs_special_br(exe_cs_special_br_111_x[1]),
        .exe_cs_is_far(exe_cs_is_far_111_x[1]),
        .exe_cs_is_call(exe_cs_is_call_111_x[1]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_111_x[1]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_111_x[1]),
        .wb_cs_ST_OP(wb_cs_ST_OP_111_x[1]),
        .wb_cs_WB_DR(wb_cs_WB_DR_111_x[1]),
        .wb_cs_WB_SR(wb_cs_WB_SR_111_x[1]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_111_x[1])
    );
    control_store cs2_000 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b0), .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b0),
        .opcode(IR[2*8 +: 8]), .modrm(IR[3*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_000_x[2]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_000_x[2]),
        .decode_cs_HALT(decode_cs_HALT_000_x[2]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_000_x[2]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_000_x[2]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_000_x[2]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_000_x[2]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_000_x[2]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_000_x[2]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_000_x[2]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_000_x[2]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_000_x[2]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_000_x[2]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_000_x[2]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_000_x[2]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_000_x[2]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_000_x[2]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_000_x[2]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_000_x[2]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_000_x[2]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_000_x[2]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_000_x[2]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_000_x[2]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_000_x[2]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_000_x[2]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_000_x[2]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_000_x[2]),
        .rr_cs_LD_OP(rr_cs_LD_OP_000_x[2]),
        .rr_cs_ST_OP(rr_cs_ST_OP_000_x[2]),
        .rr_cs_dr_id(rr_cs_dr_id_000_x[2]),
        .rr_cs_sr_id(rr_cs_sr_id_000_x[2]),
        .rr_cs_dr_rd(rr_cs_dr_rd_000_x[2]),
        .rr_cs_sr_rd(rr_cs_sr_rd_000_x[2]),
        .rr_cs_eax_rd(rr_cs_eax_rd_000_x[2]),
        .rr_cs_dr_wr(rr_cs_dr_wr_000_x[2]),
        .rr_cs_sr_wr(rr_cs_sr_wr_000_x[2]),
        .rr_cs_eax_wr(rr_cs_eax_wr_000_x[2]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_000_x[2]),
        .rr_cs_datasize(rr_cs_datasize_000_x[2]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_000_x[2]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_000_x[2]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_000_x[2]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_000_x[2]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_000_x[2]),
        .rr_cs_special_br(rr_cs_special_br_000_x[2]),
        .dc_cs_LD_OP(dc_cs_LD_OP_000_x[2]),
        .dc_cs_ST_OP(dc_cs_ST_OP_000_x[2]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_000_x[2]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_000_x[2]),
        .dc_cs_datasize(dc_cs_datasize_000_x[2]),
        .mem_cs_ST_OP(mem_cs_ST_OP_000_x[2]),
        .mem_cs_LD_OP(mem_cs_LD_OP_000_x[2]),
        .exe_cs_ST_OP(exe_cs_ST_OP_000_x[2]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_000_x[2]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_000_x[2]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_000_x[2]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_000_x[2]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_000_x[2]),
        .exe_cs_br_ucond(exe_cs_br_ucond_000_x[2]),
        .exe_cs_relative_branch(exe_cs_relative_branch_000_x[2]),
        .exe_cs_special_br(exe_cs_special_br_000_x[2]),
        .exe_cs_is_far(exe_cs_is_far_000_x[2]),
        .exe_cs_is_call(exe_cs_is_call_000_x[2]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_000_x[2]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_000_x[2]),
        .wb_cs_ST_OP(wb_cs_ST_OP_000_x[2]),
        .wb_cs_WB_DR(wb_cs_WB_DR_000_x[2]),
        .wb_cs_WB_SR(wb_cs_WB_SR_000_x[2]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_000_x[2])
    );
    control_store cs2_001 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b1), .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b0),
        .opcode(IR[2*8 +: 8]), .modrm(IR[3*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_001_x[2]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_001_x[2]),
        .decode_cs_HALT(decode_cs_HALT_001_x[2]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_001_x[2]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_001_x[2]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_001_x[2]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_001_x[2]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_001_x[2]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_001_x[2]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_001_x[2]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_001_x[2]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_001_x[2]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_001_x[2]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_001_x[2]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_001_x[2]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_001_x[2]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_001_x[2]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_001_x[2]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_001_x[2]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_001_x[2]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_001_x[2]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_001_x[2]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_001_x[2]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_001_x[2]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_001_x[2]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_001_x[2]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_001_x[2]),
        .rr_cs_LD_OP(rr_cs_LD_OP_001_x[2]),
        .rr_cs_ST_OP(rr_cs_ST_OP_001_x[2]),
        .rr_cs_dr_id(rr_cs_dr_id_001_x[2]),
        .rr_cs_sr_id(rr_cs_sr_id_001_x[2]),
        .rr_cs_dr_rd(rr_cs_dr_rd_001_x[2]),
        .rr_cs_sr_rd(rr_cs_sr_rd_001_x[2]),
        .rr_cs_eax_rd(rr_cs_eax_rd_001_x[2]),
        .rr_cs_dr_wr(rr_cs_dr_wr_001_x[2]),
        .rr_cs_sr_wr(rr_cs_sr_wr_001_x[2]),
        .rr_cs_eax_wr(rr_cs_eax_wr_001_x[2]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_001_x[2]),
        .rr_cs_datasize(rr_cs_datasize_001_x[2]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_001_x[2]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_001_x[2]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_001_x[2]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_001_x[2]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_001_x[2]),
        .rr_cs_special_br(rr_cs_special_br_001_x[2]),
        .dc_cs_LD_OP(dc_cs_LD_OP_001_x[2]),
        .dc_cs_ST_OP(dc_cs_ST_OP_001_x[2]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_001_x[2]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_001_x[2]),
        .dc_cs_datasize(dc_cs_datasize_001_x[2]),
        .mem_cs_ST_OP(mem_cs_ST_OP_001_x[2]),
        .mem_cs_LD_OP(mem_cs_LD_OP_001_x[2]),
        .exe_cs_ST_OP(exe_cs_ST_OP_001_x[2]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_001_x[2]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_001_x[2]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_001_x[2]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_001_x[2]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_001_x[2]),
        .exe_cs_br_ucond(exe_cs_br_ucond_001_x[2]),
        .exe_cs_relative_branch(exe_cs_relative_branch_001_x[2]),
        .exe_cs_special_br(exe_cs_special_br_001_x[2]),
        .exe_cs_is_far(exe_cs_is_far_001_x[2]),
        .exe_cs_is_call(exe_cs_is_call_001_x[2]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_001_x[2]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_001_x[2]),
        .wb_cs_ST_OP(wb_cs_ST_OP_001_x[2]),
        .wb_cs_WB_DR(wb_cs_WB_DR_001_x[2]),
        .wb_cs_WB_SR(wb_cs_WB_SR_001_x[2]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_001_x[2])
    );
    control_store cs2_010 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b0), .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b0),
        .opcode(IR[2*8 +: 8]), .modrm(IR[3*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_010_x[2]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_010_x[2]),
        .decode_cs_HALT(decode_cs_HALT_010_x[2]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_010_x[2]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_010_x[2]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_010_x[2]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_010_x[2]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_010_x[2]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_010_x[2]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_010_x[2]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_010_x[2]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_010_x[2]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_010_x[2]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_010_x[2]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_010_x[2]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_010_x[2]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_010_x[2]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_010_x[2]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_010_x[2]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_010_x[2]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_010_x[2]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_010_x[2]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_010_x[2]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_010_x[2]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_010_x[2]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_010_x[2]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_010_x[2]),
        .rr_cs_LD_OP(rr_cs_LD_OP_010_x[2]),
        .rr_cs_ST_OP(rr_cs_ST_OP_010_x[2]),
        .rr_cs_dr_id(rr_cs_dr_id_010_x[2]),
        .rr_cs_sr_id(rr_cs_sr_id_010_x[2]),
        .rr_cs_dr_rd(rr_cs_dr_rd_010_x[2]),
        .rr_cs_sr_rd(rr_cs_sr_rd_010_x[2]),
        .rr_cs_eax_rd(rr_cs_eax_rd_010_x[2]),
        .rr_cs_dr_wr(rr_cs_dr_wr_010_x[2]),
        .rr_cs_sr_wr(rr_cs_sr_wr_010_x[2]),
        .rr_cs_eax_wr(rr_cs_eax_wr_010_x[2]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_010_x[2]),
        .rr_cs_datasize(rr_cs_datasize_010_x[2]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_010_x[2]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_010_x[2]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_010_x[2]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_010_x[2]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_010_x[2]),
        .rr_cs_special_br(rr_cs_special_br_010_x[2]),
        .dc_cs_LD_OP(dc_cs_LD_OP_010_x[2]),
        .dc_cs_ST_OP(dc_cs_ST_OP_010_x[2]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_010_x[2]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_010_x[2]),
        .dc_cs_datasize(dc_cs_datasize_010_x[2]),
        .mem_cs_ST_OP(mem_cs_ST_OP_010_x[2]),
        .mem_cs_LD_OP(mem_cs_LD_OP_010_x[2]),
        .exe_cs_ST_OP(exe_cs_ST_OP_010_x[2]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_010_x[2]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_010_x[2]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_010_x[2]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_010_x[2]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_010_x[2]),
        .exe_cs_br_ucond(exe_cs_br_ucond_010_x[2]),
        .exe_cs_relative_branch(exe_cs_relative_branch_010_x[2]),
        .exe_cs_special_br(exe_cs_special_br_010_x[2]),
        .exe_cs_is_far(exe_cs_is_far_010_x[2]),
        .exe_cs_is_call(exe_cs_is_call_010_x[2]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_010_x[2]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_010_x[2]),
        .wb_cs_ST_OP(wb_cs_ST_OP_010_x[2]),
        .wb_cs_WB_DR(wb_cs_WB_DR_010_x[2]),
        .wb_cs_WB_SR(wb_cs_WB_SR_010_x[2]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_010_x[2])
    );
    control_store cs2_011 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b1), .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b0),
        .opcode(IR[2*8 +: 8]), .modrm(IR[3*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_011_x[2]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_011_x[2]),
        .decode_cs_HALT(decode_cs_HALT_011_x[2]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_011_x[2]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_011_x[2]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_011_x[2]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_011_x[2]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_011_x[2]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_011_x[2]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_011_x[2]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_011_x[2]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_011_x[2]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_011_x[2]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_011_x[2]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_011_x[2]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_011_x[2]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_011_x[2]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_011_x[2]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_011_x[2]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_011_x[2]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_011_x[2]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_011_x[2]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_011_x[2]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_011_x[2]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_011_x[2]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_011_x[2]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_011_x[2]),
        .rr_cs_LD_OP(rr_cs_LD_OP_011_x[2]),
        .rr_cs_ST_OP(rr_cs_ST_OP_011_x[2]),
        .rr_cs_dr_id(rr_cs_dr_id_011_x[2]),
        .rr_cs_sr_id(rr_cs_sr_id_011_x[2]),
        .rr_cs_dr_rd(rr_cs_dr_rd_011_x[2]),
        .rr_cs_sr_rd(rr_cs_sr_rd_011_x[2]),
        .rr_cs_eax_rd(rr_cs_eax_rd_011_x[2]),
        .rr_cs_dr_wr(rr_cs_dr_wr_011_x[2]),
        .rr_cs_sr_wr(rr_cs_sr_wr_011_x[2]),
        .rr_cs_eax_wr(rr_cs_eax_wr_011_x[2]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_011_x[2]),
        .rr_cs_datasize(rr_cs_datasize_011_x[2]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_011_x[2]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_011_x[2]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_011_x[2]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_011_x[2]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_011_x[2]),
        .rr_cs_special_br(rr_cs_special_br_011_x[2]),
        .dc_cs_LD_OP(dc_cs_LD_OP_011_x[2]),
        .dc_cs_ST_OP(dc_cs_ST_OP_011_x[2]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_011_x[2]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_011_x[2]),
        .dc_cs_datasize(dc_cs_datasize_011_x[2]),
        .mem_cs_ST_OP(mem_cs_ST_OP_011_x[2]),
        .mem_cs_LD_OP(mem_cs_LD_OP_011_x[2]),
        .exe_cs_ST_OP(exe_cs_ST_OP_011_x[2]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_011_x[2]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_011_x[2]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_011_x[2]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_011_x[2]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_011_x[2]),
        .exe_cs_br_ucond(exe_cs_br_ucond_011_x[2]),
        .exe_cs_relative_branch(exe_cs_relative_branch_011_x[2]),
        .exe_cs_special_br(exe_cs_special_br_011_x[2]),
        .exe_cs_is_far(exe_cs_is_far_011_x[2]),
        .exe_cs_is_call(exe_cs_is_call_011_x[2]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_011_x[2]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_011_x[2]),
        .wb_cs_ST_OP(wb_cs_ST_OP_011_x[2]),
        .wb_cs_WB_DR(wb_cs_WB_DR_011_x[2]),
        .wb_cs_WB_SR(wb_cs_WB_SR_011_x[2]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_011_x[2])
    );
    control_store cs2_100 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b0), .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b1),
        .opcode(IR[2*8 +: 8]), .modrm(IR[3*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_100_x[2]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_100_x[2]),
        .decode_cs_HALT(decode_cs_HALT_100_x[2]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_100_x[2]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_100_x[2]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_100_x[2]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_100_x[2]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_100_x[2]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_100_x[2]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_100_x[2]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_100_x[2]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_100_x[2]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_100_x[2]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_100_x[2]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_100_x[2]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_100_x[2]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_100_x[2]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_100_x[2]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_100_x[2]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_100_x[2]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_100_x[2]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_100_x[2]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_100_x[2]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_100_x[2]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_100_x[2]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_100_x[2]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_100_x[2]),
        .rr_cs_LD_OP(rr_cs_LD_OP_100_x[2]),
        .rr_cs_ST_OP(rr_cs_ST_OP_100_x[2]),
        .rr_cs_dr_id(rr_cs_dr_id_100_x[2]),
        .rr_cs_sr_id(rr_cs_sr_id_100_x[2]),
        .rr_cs_dr_rd(rr_cs_dr_rd_100_x[2]),
        .rr_cs_sr_rd(rr_cs_sr_rd_100_x[2]),
        .rr_cs_eax_rd(rr_cs_eax_rd_100_x[2]),
        .rr_cs_dr_wr(rr_cs_dr_wr_100_x[2]),
        .rr_cs_sr_wr(rr_cs_sr_wr_100_x[2]),
        .rr_cs_eax_wr(rr_cs_eax_wr_100_x[2]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_100_x[2]),
        .rr_cs_datasize(rr_cs_datasize_100_x[2]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_100_x[2]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_100_x[2]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_100_x[2]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_100_x[2]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_100_x[2]),
        .rr_cs_special_br(rr_cs_special_br_100_x[2]),
        .dc_cs_LD_OP(dc_cs_LD_OP_100_x[2]),
        .dc_cs_ST_OP(dc_cs_ST_OP_100_x[2]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_100_x[2]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_100_x[2]),
        .dc_cs_datasize(dc_cs_datasize_100_x[2]),
        .mem_cs_ST_OP(mem_cs_ST_OP_100_x[2]),
        .mem_cs_LD_OP(mem_cs_LD_OP_100_x[2]),
        .exe_cs_ST_OP(exe_cs_ST_OP_100_x[2]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_100_x[2]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_100_x[2]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_100_x[2]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_100_x[2]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_100_x[2]),
        .exe_cs_br_ucond(exe_cs_br_ucond_100_x[2]),
        .exe_cs_relative_branch(exe_cs_relative_branch_100_x[2]),
        .exe_cs_special_br(exe_cs_special_br_100_x[2]),
        .exe_cs_is_far(exe_cs_is_far_100_x[2]),
        .exe_cs_is_call(exe_cs_is_call_100_x[2]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_100_x[2]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_100_x[2]),
        .wb_cs_ST_OP(wb_cs_ST_OP_100_x[2]),
        .wb_cs_WB_DR(wb_cs_WB_DR_100_x[2]),
        .wb_cs_WB_SR(wb_cs_WB_SR_100_x[2]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_100_x[2])
    );
    control_store cs2_101 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b1), .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b1),
        .opcode(IR[2*8 +: 8]), .modrm(IR[3*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_101_x[2]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_101_x[2]),
        .decode_cs_HALT(decode_cs_HALT_101_x[2]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_101_x[2]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_101_x[2]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_101_x[2]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_101_x[2]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_101_x[2]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_101_x[2]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_101_x[2]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_101_x[2]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_101_x[2]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_101_x[2]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_101_x[2]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_101_x[2]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_101_x[2]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_101_x[2]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_101_x[2]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_101_x[2]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_101_x[2]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_101_x[2]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_101_x[2]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_101_x[2]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_101_x[2]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_101_x[2]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_101_x[2]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_101_x[2]),
        .rr_cs_LD_OP(rr_cs_LD_OP_101_x[2]),
        .rr_cs_ST_OP(rr_cs_ST_OP_101_x[2]),
        .rr_cs_dr_id(rr_cs_dr_id_101_x[2]),
        .rr_cs_sr_id(rr_cs_sr_id_101_x[2]),
        .rr_cs_dr_rd(rr_cs_dr_rd_101_x[2]),
        .rr_cs_sr_rd(rr_cs_sr_rd_101_x[2]),
        .rr_cs_eax_rd(rr_cs_eax_rd_101_x[2]),
        .rr_cs_dr_wr(rr_cs_dr_wr_101_x[2]),
        .rr_cs_sr_wr(rr_cs_sr_wr_101_x[2]),
        .rr_cs_eax_wr(rr_cs_eax_wr_101_x[2]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_101_x[2]),
        .rr_cs_datasize(rr_cs_datasize_101_x[2]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_101_x[2]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_101_x[2]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_101_x[2]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_101_x[2]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_101_x[2]),
        .rr_cs_special_br(rr_cs_special_br_101_x[2]),
        .dc_cs_LD_OP(dc_cs_LD_OP_101_x[2]),
        .dc_cs_ST_OP(dc_cs_ST_OP_101_x[2]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_101_x[2]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_101_x[2]),
        .dc_cs_datasize(dc_cs_datasize_101_x[2]),
        .mem_cs_ST_OP(mem_cs_ST_OP_101_x[2]),
        .mem_cs_LD_OP(mem_cs_LD_OP_101_x[2]),
        .exe_cs_ST_OP(exe_cs_ST_OP_101_x[2]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_101_x[2]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_101_x[2]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_101_x[2]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_101_x[2]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_101_x[2]),
        .exe_cs_br_ucond(exe_cs_br_ucond_101_x[2]),
        .exe_cs_relative_branch(exe_cs_relative_branch_101_x[2]),
        .exe_cs_special_br(exe_cs_special_br_101_x[2]),
        .exe_cs_is_far(exe_cs_is_far_101_x[2]),
        .exe_cs_is_call(exe_cs_is_call_101_x[2]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_101_x[2]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_101_x[2]),
        .wb_cs_ST_OP(wb_cs_ST_OP_101_x[2]),
        .wb_cs_WB_DR(wb_cs_WB_DR_101_x[2]),
        .wb_cs_WB_SR(wb_cs_WB_SR_101_x[2]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_101_x[2])
    );
    control_store cs2_110 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b0), .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b1),
        .opcode(IR[2*8 +: 8]), .modrm(IR[3*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_110_x[2]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_110_x[2]),
        .decode_cs_HALT(decode_cs_HALT_110_x[2]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_110_x[2]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_110_x[2]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_110_x[2]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_110_x[2]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_110_x[2]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_110_x[2]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_110_x[2]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_110_x[2]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_110_x[2]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_110_x[2]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_110_x[2]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_110_x[2]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_110_x[2]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_110_x[2]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_110_x[2]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_110_x[2]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_110_x[2]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_110_x[2]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_110_x[2]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_110_x[2]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_110_x[2]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_110_x[2]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_110_x[2]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_110_x[2]),
        .rr_cs_LD_OP(rr_cs_LD_OP_110_x[2]),
        .rr_cs_ST_OP(rr_cs_ST_OP_110_x[2]),
        .rr_cs_dr_id(rr_cs_dr_id_110_x[2]),
        .rr_cs_sr_id(rr_cs_sr_id_110_x[2]),
        .rr_cs_dr_rd(rr_cs_dr_rd_110_x[2]),
        .rr_cs_sr_rd(rr_cs_sr_rd_110_x[2]),
        .rr_cs_eax_rd(rr_cs_eax_rd_110_x[2]),
        .rr_cs_dr_wr(rr_cs_dr_wr_110_x[2]),
        .rr_cs_sr_wr(rr_cs_sr_wr_110_x[2]),
        .rr_cs_eax_wr(rr_cs_eax_wr_110_x[2]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_110_x[2]),
        .rr_cs_datasize(rr_cs_datasize_110_x[2]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_110_x[2]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_110_x[2]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_110_x[2]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_110_x[2]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_110_x[2]),
        .rr_cs_special_br(rr_cs_special_br_110_x[2]),
        .dc_cs_LD_OP(dc_cs_LD_OP_110_x[2]),
        .dc_cs_ST_OP(dc_cs_ST_OP_110_x[2]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_110_x[2]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_110_x[2]),
        .dc_cs_datasize(dc_cs_datasize_110_x[2]),
        .mem_cs_ST_OP(mem_cs_ST_OP_110_x[2]),
        .mem_cs_LD_OP(mem_cs_LD_OP_110_x[2]),
        .exe_cs_ST_OP(exe_cs_ST_OP_110_x[2]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_110_x[2]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_110_x[2]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_110_x[2]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_110_x[2]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_110_x[2]),
        .exe_cs_br_ucond(exe_cs_br_ucond_110_x[2]),
        .exe_cs_relative_branch(exe_cs_relative_branch_110_x[2]),
        .exe_cs_special_br(exe_cs_special_br_110_x[2]),
        .exe_cs_is_far(exe_cs_is_far_110_x[2]),
        .exe_cs_is_call(exe_cs_is_call_110_x[2]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_110_x[2]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_110_x[2]),
        .wb_cs_ST_OP(wb_cs_ST_OP_110_x[2]),
        .wb_cs_WB_DR(wb_cs_WB_DR_110_x[2]),
        .wb_cs_WB_SR(wb_cs_WB_SR_110_x[2]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_110_x[2])
    );
    control_store cs2_111 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b1), .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b1),
        .opcode(IR[2*8 +: 8]), .modrm(IR[3*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_111_x[2]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_111_x[2]),
        .decode_cs_HALT(decode_cs_HALT_111_x[2]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_111_x[2]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_111_x[2]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_111_x[2]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_111_x[2]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_111_x[2]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_111_x[2]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_111_x[2]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_111_x[2]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_111_x[2]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_111_x[2]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_111_x[2]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_111_x[2]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_111_x[2]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_111_x[2]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_111_x[2]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_111_x[2]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_111_x[2]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_111_x[2]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_111_x[2]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_111_x[2]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_111_x[2]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_111_x[2]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_111_x[2]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_111_x[2]),
        .rr_cs_LD_OP(rr_cs_LD_OP_111_x[2]),
        .rr_cs_ST_OP(rr_cs_ST_OP_111_x[2]),
        .rr_cs_dr_id(rr_cs_dr_id_111_x[2]),
        .rr_cs_sr_id(rr_cs_sr_id_111_x[2]),
        .rr_cs_dr_rd(rr_cs_dr_rd_111_x[2]),
        .rr_cs_sr_rd(rr_cs_sr_rd_111_x[2]),
        .rr_cs_eax_rd(rr_cs_eax_rd_111_x[2]),
        .rr_cs_dr_wr(rr_cs_dr_wr_111_x[2]),
        .rr_cs_sr_wr(rr_cs_sr_wr_111_x[2]),
        .rr_cs_eax_wr(rr_cs_eax_wr_111_x[2]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_111_x[2]),
        .rr_cs_datasize(rr_cs_datasize_111_x[2]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_111_x[2]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_111_x[2]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_111_x[2]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_111_x[2]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_111_x[2]),
        .rr_cs_special_br(rr_cs_special_br_111_x[2]),
        .dc_cs_LD_OP(dc_cs_LD_OP_111_x[2]),
        .dc_cs_ST_OP(dc_cs_ST_OP_111_x[2]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_111_x[2]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_111_x[2]),
        .dc_cs_datasize(dc_cs_datasize_111_x[2]),
        .mem_cs_ST_OP(mem_cs_ST_OP_111_x[2]),
        .mem_cs_LD_OP(mem_cs_LD_OP_111_x[2]),
        .exe_cs_ST_OP(exe_cs_ST_OP_111_x[2]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_111_x[2]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_111_x[2]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_111_x[2]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_111_x[2]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_111_x[2]),
        .exe_cs_br_ucond(exe_cs_br_ucond_111_x[2]),
        .exe_cs_relative_branch(exe_cs_relative_branch_111_x[2]),
        .exe_cs_special_br(exe_cs_special_br_111_x[2]),
        .exe_cs_is_far(exe_cs_is_far_111_x[2]),
        .exe_cs_is_call(exe_cs_is_call_111_x[2]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_111_x[2]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_111_x[2]),
        .wb_cs_ST_OP(wb_cs_ST_OP_111_x[2]),
        .wb_cs_WB_DR(wb_cs_WB_DR_111_x[2]),
        .wb_cs_WB_SR(wb_cs_WB_SR_111_x[2]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_111_x[2])
    );
    control_store cs3_000 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b0), .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b0),
        .opcode(IR[3*8 +: 8]), .modrm(IR[4*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_000_x[3]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_000_x[3]),
        .decode_cs_HALT(decode_cs_HALT_000_x[3]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_000_x[3]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_000_x[3]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_000_x[3]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_000_x[3]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_000_x[3]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_000_x[3]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_000_x[3]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_000_x[3]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_000_x[3]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_000_x[3]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_000_x[3]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_000_x[3]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_000_x[3]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_000_x[3]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_000_x[3]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_000_x[3]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_000_x[3]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_000_x[3]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_000_x[3]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_000_x[3]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_000_x[3]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_000_x[3]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_000_x[3]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_000_x[3]),
        .rr_cs_LD_OP(rr_cs_LD_OP_000_x[3]),
        .rr_cs_ST_OP(rr_cs_ST_OP_000_x[3]),
        .rr_cs_dr_id(rr_cs_dr_id_000_x[3]),
        .rr_cs_sr_id(rr_cs_sr_id_000_x[3]),
        .rr_cs_dr_rd(rr_cs_dr_rd_000_x[3]),
        .rr_cs_sr_rd(rr_cs_sr_rd_000_x[3]),
        .rr_cs_eax_rd(rr_cs_eax_rd_000_x[3]),
        .rr_cs_dr_wr(rr_cs_dr_wr_000_x[3]),
        .rr_cs_sr_wr(rr_cs_sr_wr_000_x[3]),
        .rr_cs_eax_wr(rr_cs_eax_wr_000_x[3]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_000_x[3]),
        .rr_cs_datasize(rr_cs_datasize_000_x[3]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_000_x[3]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_000_x[3]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_000_x[3]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_000_x[3]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_000_x[3]),
        .rr_cs_special_br(rr_cs_special_br_000_x[3]),
        .dc_cs_LD_OP(dc_cs_LD_OP_000_x[3]),
        .dc_cs_ST_OP(dc_cs_ST_OP_000_x[3]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_000_x[3]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_000_x[3]),
        .dc_cs_datasize(dc_cs_datasize_000_x[3]),
        .mem_cs_ST_OP(mem_cs_ST_OP_000_x[3]),
        .mem_cs_LD_OP(mem_cs_LD_OP_000_x[3]),
        .exe_cs_ST_OP(exe_cs_ST_OP_000_x[3]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_000_x[3]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_000_x[3]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_000_x[3]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_000_x[3]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_000_x[3]),
        .exe_cs_br_ucond(exe_cs_br_ucond_000_x[3]),
        .exe_cs_relative_branch(exe_cs_relative_branch_000_x[3]),
        .exe_cs_special_br(exe_cs_special_br_000_x[3]),
        .exe_cs_is_far(exe_cs_is_far_000_x[3]),
        .exe_cs_is_call(exe_cs_is_call_000_x[3]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_000_x[3]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_000_x[3]),
        .wb_cs_ST_OP(wb_cs_ST_OP_000_x[3]),
        .wb_cs_WB_DR(wb_cs_WB_DR_000_x[3]),
        .wb_cs_WB_SR(wb_cs_WB_SR_000_x[3]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_000_x[3])
    );
    control_store cs3_001 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b1), .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b0),
        .opcode(IR[3*8 +: 8]), .modrm(IR[4*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_001_x[3]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_001_x[3]),
        .decode_cs_HALT(decode_cs_HALT_001_x[3]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_001_x[3]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_001_x[3]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_001_x[3]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_001_x[3]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_001_x[3]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_001_x[3]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_001_x[3]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_001_x[3]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_001_x[3]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_001_x[3]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_001_x[3]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_001_x[3]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_001_x[3]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_001_x[3]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_001_x[3]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_001_x[3]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_001_x[3]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_001_x[3]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_001_x[3]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_001_x[3]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_001_x[3]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_001_x[3]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_001_x[3]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_001_x[3]),
        .rr_cs_LD_OP(rr_cs_LD_OP_001_x[3]),
        .rr_cs_ST_OP(rr_cs_ST_OP_001_x[3]),
        .rr_cs_dr_id(rr_cs_dr_id_001_x[3]),
        .rr_cs_sr_id(rr_cs_sr_id_001_x[3]),
        .rr_cs_dr_rd(rr_cs_dr_rd_001_x[3]),
        .rr_cs_sr_rd(rr_cs_sr_rd_001_x[3]),
        .rr_cs_eax_rd(rr_cs_eax_rd_001_x[3]),
        .rr_cs_dr_wr(rr_cs_dr_wr_001_x[3]),
        .rr_cs_sr_wr(rr_cs_sr_wr_001_x[3]),
        .rr_cs_eax_wr(rr_cs_eax_wr_001_x[3]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_001_x[3]),
        .rr_cs_datasize(rr_cs_datasize_001_x[3]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_001_x[3]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_001_x[3]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_001_x[3]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_001_x[3]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_001_x[3]),
        .rr_cs_special_br(rr_cs_special_br_001_x[3]),
        .dc_cs_LD_OP(dc_cs_LD_OP_001_x[3]),
        .dc_cs_ST_OP(dc_cs_ST_OP_001_x[3]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_001_x[3]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_001_x[3]),
        .dc_cs_datasize(dc_cs_datasize_001_x[3]),
        .mem_cs_ST_OP(mem_cs_ST_OP_001_x[3]),
        .mem_cs_LD_OP(mem_cs_LD_OP_001_x[3]),
        .exe_cs_ST_OP(exe_cs_ST_OP_001_x[3]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_001_x[3]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_001_x[3]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_001_x[3]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_001_x[3]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_001_x[3]),
        .exe_cs_br_ucond(exe_cs_br_ucond_001_x[3]),
        .exe_cs_relative_branch(exe_cs_relative_branch_001_x[3]),
        .exe_cs_special_br(exe_cs_special_br_001_x[3]),
        .exe_cs_is_far(exe_cs_is_far_001_x[3]),
        .exe_cs_is_call(exe_cs_is_call_001_x[3]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_001_x[3]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_001_x[3]),
        .wb_cs_ST_OP(wb_cs_ST_OP_001_x[3]),
        .wb_cs_WB_DR(wb_cs_WB_DR_001_x[3]),
        .wb_cs_WB_SR(wb_cs_WB_SR_001_x[3]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_001_x[3])
    );
    control_store cs3_010 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b0), .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b0),
        .opcode(IR[3*8 +: 8]), .modrm(IR[4*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_010_x[3]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_010_x[3]),
        .decode_cs_HALT(decode_cs_HALT_010_x[3]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_010_x[3]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_010_x[3]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_010_x[3]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_010_x[3]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_010_x[3]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_010_x[3]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_010_x[3]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_010_x[3]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_010_x[3]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_010_x[3]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_010_x[3]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_010_x[3]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_010_x[3]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_010_x[3]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_010_x[3]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_010_x[3]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_010_x[3]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_010_x[3]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_010_x[3]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_010_x[3]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_010_x[3]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_010_x[3]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_010_x[3]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_010_x[3]),
        .rr_cs_LD_OP(rr_cs_LD_OP_010_x[3]),
        .rr_cs_ST_OP(rr_cs_ST_OP_010_x[3]),
        .rr_cs_dr_id(rr_cs_dr_id_010_x[3]),
        .rr_cs_sr_id(rr_cs_sr_id_010_x[3]),
        .rr_cs_dr_rd(rr_cs_dr_rd_010_x[3]),
        .rr_cs_sr_rd(rr_cs_sr_rd_010_x[3]),
        .rr_cs_eax_rd(rr_cs_eax_rd_010_x[3]),
        .rr_cs_dr_wr(rr_cs_dr_wr_010_x[3]),
        .rr_cs_sr_wr(rr_cs_sr_wr_010_x[3]),
        .rr_cs_eax_wr(rr_cs_eax_wr_010_x[3]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_010_x[3]),
        .rr_cs_datasize(rr_cs_datasize_010_x[3]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_010_x[3]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_010_x[3]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_010_x[3]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_010_x[3]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_010_x[3]),
        .rr_cs_special_br(rr_cs_special_br_010_x[3]),
        .dc_cs_LD_OP(dc_cs_LD_OP_010_x[3]),
        .dc_cs_ST_OP(dc_cs_ST_OP_010_x[3]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_010_x[3]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_010_x[3]),
        .dc_cs_datasize(dc_cs_datasize_010_x[3]),
        .mem_cs_ST_OP(mem_cs_ST_OP_010_x[3]),
        .mem_cs_LD_OP(mem_cs_LD_OP_010_x[3]),
        .exe_cs_ST_OP(exe_cs_ST_OP_010_x[3]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_010_x[3]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_010_x[3]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_010_x[3]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_010_x[3]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_010_x[3]),
        .exe_cs_br_ucond(exe_cs_br_ucond_010_x[3]),
        .exe_cs_relative_branch(exe_cs_relative_branch_010_x[3]),
        .exe_cs_special_br(exe_cs_special_br_010_x[3]),
        .exe_cs_is_far(exe_cs_is_far_010_x[3]),
        .exe_cs_is_call(exe_cs_is_call_010_x[3]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_010_x[3]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_010_x[3]),
        .wb_cs_ST_OP(wb_cs_ST_OP_010_x[3]),
        .wb_cs_WB_DR(wb_cs_WB_DR_010_x[3]),
        .wb_cs_WB_SR(wb_cs_WB_SR_010_x[3]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_010_x[3])
    );
    control_store cs3_011 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b1), .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b0),
        .opcode(IR[3*8 +: 8]), .modrm(IR[4*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_011_x[3]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_011_x[3]),
        .decode_cs_HALT(decode_cs_HALT_011_x[3]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_011_x[3]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_011_x[3]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_011_x[3]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_011_x[3]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_011_x[3]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_011_x[3]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_011_x[3]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_011_x[3]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_011_x[3]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_011_x[3]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_011_x[3]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_011_x[3]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_011_x[3]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_011_x[3]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_011_x[3]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_011_x[3]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_011_x[3]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_011_x[3]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_011_x[3]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_011_x[3]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_011_x[3]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_011_x[3]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_011_x[3]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_011_x[3]),
        .rr_cs_LD_OP(rr_cs_LD_OP_011_x[3]),
        .rr_cs_ST_OP(rr_cs_ST_OP_011_x[3]),
        .rr_cs_dr_id(rr_cs_dr_id_011_x[3]),
        .rr_cs_sr_id(rr_cs_sr_id_011_x[3]),
        .rr_cs_dr_rd(rr_cs_dr_rd_011_x[3]),
        .rr_cs_sr_rd(rr_cs_sr_rd_011_x[3]),
        .rr_cs_eax_rd(rr_cs_eax_rd_011_x[3]),
        .rr_cs_dr_wr(rr_cs_dr_wr_011_x[3]),
        .rr_cs_sr_wr(rr_cs_sr_wr_011_x[3]),
        .rr_cs_eax_wr(rr_cs_eax_wr_011_x[3]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_011_x[3]),
        .rr_cs_datasize(rr_cs_datasize_011_x[3]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_011_x[3]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_011_x[3]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_011_x[3]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_011_x[3]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_011_x[3]),
        .rr_cs_special_br(rr_cs_special_br_011_x[3]),
        .dc_cs_LD_OP(dc_cs_LD_OP_011_x[3]),
        .dc_cs_ST_OP(dc_cs_ST_OP_011_x[3]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_011_x[3]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_011_x[3]),
        .dc_cs_datasize(dc_cs_datasize_011_x[3]),
        .mem_cs_ST_OP(mem_cs_ST_OP_011_x[3]),
        .mem_cs_LD_OP(mem_cs_LD_OP_011_x[3]),
        .exe_cs_ST_OP(exe_cs_ST_OP_011_x[3]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_011_x[3]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_011_x[3]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_011_x[3]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_011_x[3]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_011_x[3]),
        .exe_cs_br_ucond(exe_cs_br_ucond_011_x[3]),
        .exe_cs_relative_branch(exe_cs_relative_branch_011_x[3]),
        .exe_cs_special_br(exe_cs_special_br_011_x[3]),
        .exe_cs_is_far(exe_cs_is_far_011_x[3]),
        .exe_cs_is_call(exe_cs_is_call_011_x[3]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_011_x[3]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_011_x[3]),
        .wb_cs_ST_OP(wb_cs_ST_OP_011_x[3]),
        .wb_cs_WB_DR(wb_cs_WB_DR_011_x[3]),
        .wb_cs_WB_SR(wb_cs_WB_SR_011_x[3]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_011_x[3])
    );
    control_store cs3_100 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b0), .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b1),
        .opcode(IR[3*8 +: 8]), .modrm(IR[4*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_100_x[3]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_100_x[3]),
        .decode_cs_HALT(decode_cs_HALT_100_x[3]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_100_x[3]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_100_x[3]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_100_x[3]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_100_x[3]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_100_x[3]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_100_x[3]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_100_x[3]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_100_x[3]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_100_x[3]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_100_x[3]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_100_x[3]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_100_x[3]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_100_x[3]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_100_x[3]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_100_x[3]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_100_x[3]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_100_x[3]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_100_x[3]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_100_x[3]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_100_x[3]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_100_x[3]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_100_x[3]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_100_x[3]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_100_x[3]),
        .rr_cs_LD_OP(rr_cs_LD_OP_100_x[3]),
        .rr_cs_ST_OP(rr_cs_ST_OP_100_x[3]),
        .rr_cs_dr_id(rr_cs_dr_id_100_x[3]),
        .rr_cs_sr_id(rr_cs_sr_id_100_x[3]),
        .rr_cs_dr_rd(rr_cs_dr_rd_100_x[3]),
        .rr_cs_sr_rd(rr_cs_sr_rd_100_x[3]),
        .rr_cs_eax_rd(rr_cs_eax_rd_100_x[3]),
        .rr_cs_dr_wr(rr_cs_dr_wr_100_x[3]),
        .rr_cs_sr_wr(rr_cs_sr_wr_100_x[3]),
        .rr_cs_eax_wr(rr_cs_eax_wr_100_x[3]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_100_x[3]),
        .rr_cs_datasize(rr_cs_datasize_100_x[3]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_100_x[3]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_100_x[3]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_100_x[3]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_100_x[3]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_100_x[3]),
        .rr_cs_special_br(rr_cs_special_br_100_x[3]),
        .dc_cs_LD_OP(dc_cs_LD_OP_100_x[3]),
        .dc_cs_ST_OP(dc_cs_ST_OP_100_x[3]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_100_x[3]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_100_x[3]),
        .dc_cs_datasize(dc_cs_datasize_100_x[3]),
        .mem_cs_ST_OP(mem_cs_ST_OP_100_x[3]),
        .mem_cs_LD_OP(mem_cs_LD_OP_100_x[3]),
        .exe_cs_ST_OP(exe_cs_ST_OP_100_x[3]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_100_x[3]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_100_x[3]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_100_x[3]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_100_x[3]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_100_x[3]),
        .exe_cs_br_ucond(exe_cs_br_ucond_100_x[3]),
        .exe_cs_relative_branch(exe_cs_relative_branch_100_x[3]),
        .exe_cs_special_br(exe_cs_special_br_100_x[3]),
        .exe_cs_is_far(exe_cs_is_far_100_x[3]),
        .exe_cs_is_call(exe_cs_is_call_100_x[3]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_100_x[3]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_100_x[3]),
        .wb_cs_ST_OP(wb_cs_ST_OP_100_x[3]),
        .wb_cs_WB_DR(wb_cs_WB_DR_100_x[3]),
        .wb_cs_WB_SR(wb_cs_WB_SR_100_x[3]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_100_x[3])
    );
    control_store cs3_101 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b1), .total_pf_vector_1(1'b0), .total_pf_vector_3(1'b1),
        .opcode(IR[3*8 +: 8]), .modrm(IR[4*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_101_x[3]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_101_x[3]),
        .decode_cs_HALT(decode_cs_HALT_101_x[3]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_101_x[3]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_101_x[3]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_101_x[3]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_101_x[3]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_101_x[3]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_101_x[3]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_101_x[3]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_101_x[3]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_101_x[3]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_101_x[3]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_101_x[3]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_101_x[3]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_101_x[3]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_101_x[3]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_101_x[3]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_101_x[3]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_101_x[3]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_101_x[3]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_101_x[3]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_101_x[3]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_101_x[3]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_101_x[3]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_101_x[3]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_101_x[3]),
        .rr_cs_LD_OP(rr_cs_LD_OP_101_x[3]),
        .rr_cs_ST_OP(rr_cs_ST_OP_101_x[3]),
        .rr_cs_dr_id(rr_cs_dr_id_101_x[3]),
        .rr_cs_sr_id(rr_cs_sr_id_101_x[3]),
        .rr_cs_dr_rd(rr_cs_dr_rd_101_x[3]),
        .rr_cs_sr_rd(rr_cs_sr_rd_101_x[3]),
        .rr_cs_eax_rd(rr_cs_eax_rd_101_x[3]),
        .rr_cs_dr_wr(rr_cs_dr_wr_101_x[3]),
        .rr_cs_sr_wr(rr_cs_sr_wr_101_x[3]),
        .rr_cs_eax_wr(rr_cs_eax_wr_101_x[3]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_101_x[3]),
        .rr_cs_datasize(rr_cs_datasize_101_x[3]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_101_x[3]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_101_x[3]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_101_x[3]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_101_x[3]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_101_x[3]),
        .rr_cs_special_br(rr_cs_special_br_101_x[3]),
        .dc_cs_LD_OP(dc_cs_LD_OP_101_x[3]),
        .dc_cs_ST_OP(dc_cs_ST_OP_101_x[3]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_101_x[3]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_101_x[3]),
        .dc_cs_datasize(dc_cs_datasize_101_x[3]),
        .mem_cs_ST_OP(mem_cs_ST_OP_101_x[3]),
        .mem_cs_LD_OP(mem_cs_LD_OP_101_x[3]),
        .exe_cs_ST_OP(exe_cs_ST_OP_101_x[3]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_101_x[3]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_101_x[3]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_101_x[3]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_101_x[3]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_101_x[3]),
        .exe_cs_br_ucond(exe_cs_br_ucond_101_x[3]),
        .exe_cs_relative_branch(exe_cs_relative_branch_101_x[3]),
        .exe_cs_special_br(exe_cs_special_br_101_x[3]),
        .exe_cs_is_far(exe_cs_is_far_101_x[3]),
        .exe_cs_is_call(exe_cs_is_call_101_x[3]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_101_x[3]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_101_x[3]),
        .wb_cs_ST_OP(wb_cs_ST_OP_101_x[3]),
        .wb_cs_WB_DR(wb_cs_WB_DR_101_x[3]),
        .wb_cs_WB_SR(wb_cs_WB_SR_101_x[3]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_101_x[3])
    );
    control_store cs3_110 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b0), .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b1),
        .opcode(IR[3*8 +: 8]), .modrm(IR[4*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_110_x[3]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_110_x[3]),
        .decode_cs_HALT(decode_cs_HALT_110_x[3]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_110_x[3]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_110_x[3]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_110_x[3]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_110_x[3]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_110_x[3]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_110_x[3]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_110_x[3]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_110_x[3]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_110_x[3]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_110_x[3]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_110_x[3]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_110_x[3]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_110_x[3]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_110_x[3]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_110_x[3]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_110_x[3]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_110_x[3]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_110_x[3]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_110_x[3]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_110_x[3]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_110_x[3]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_110_x[3]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_110_x[3]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_110_x[3]),
        .rr_cs_LD_OP(rr_cs_LD_OP_110_x[3]),
        .rr_cs_ST_OP(rr_cs_ST_OP_110_x[3]),
        .rr_cs_dr_id(rr_cs_dr_id_110_x[3]),
        .rr_cs_sr_id(rr_cs_sr_id_110_x[3]),
        .rr_cs_dr_rd(rr_cs_dr_rd_110_x[3]),
        .rr_cs_sr_rd(rr_cs_sr_rd_110_x[3]),
        .rr_cs_eax_rd(rr_cs_eax_rd_110_x[3]),
        .rr_cs_dr_wr(rr_cs_dr_wr_110_x[3]),
        .rr_cs_sr_wr(rr_cs_sr_wr_110_x[3]),
        .rr_cs_eax_wr(rr_cs_eax_wr_110_x[3]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_110_x[3]),
        .rr_cs_datasize(rr_cs_datasize_110_x[3]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_110_x[3]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_110_x[3]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_110_x[3]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_110_x[3]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_110_x[3]),
        .rr_cs_special_br(rr_cs_special_br_110_x[3]),
        .dc_cs_LD_OP(dc_cs_LD_OP_110_x[3]),
        .dc_cs_ST_OP(dc_cs_ST_OP_110_x[3]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_110_x[3]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_110_x[3]),
        .dc_cs_datasize(dc_cs_datasize_110_x[3]),
        .mem_cs_ST_OP(mem_cs_ST_OP_110_x[3]),
        .mem_cs_LD_OP(mem_cs_LD_OP_110_x[3]),
        .exe_cs_ST_OP(exe_cs_ST_OP_110_x[3]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_110_x[3]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_110_x[3]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_110_x[3]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_110_x[3]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_110_x[3]),
        .exe_cs_br_ucond(exe_cs_br_ucond_110_x[3]),
        .exe_cs_relative_branch(exe_cs_relative_branch_110_x[3]),
        .exe_cs_special_br(exe_cs_special_br_110_x[3]),
        .exe_cs_is_far(exe_cs_is_far_110_x[3]),
        .exe_cs_is_call(exe_cs_is_call_110_x[3]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_110_x[3]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_110_x[3]),
        .wb_cs_ST_OP(wb_cs_ST_OP_110_x[3]),
        .wb_cs_WB_DR(wb_cs_WB_DR_110_x[3]),
        .wb_cs_WB_SR(wb_cs_WB_SR_110_x[3]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_110_x[3])
    );
    control_store cs3_111 (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b1), .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b1),
        .opcode(IR[3*8 +: 8]), .modrm(IR[4*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_111_x[3]),
        .decode_cs_REP_CMP(decode_cs_REP_CMP_111_x[3]),
        .decode_cs_HALT(decode_cs_HALT_111_x[3]),
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_111_x[3]),
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_111_x[3]),
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_111_x[3]),
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_111_x[3]),
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_111_x[3]),
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_111_x[3]),
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_111_x[3]),
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_111_x[3]),
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_111_x[3]),
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_111_x[3]),
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_111_x[3]),
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_111_x[3]),
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_111_x[3]),
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_111_x[3]),
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_111_x[3]),
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_111_x[3]),
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_111_x[3]),
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_111_x[3]),
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_111_x[3]),
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_111_x[3]),
        .rr_cs_ST_SEL(rr_cs_ST_SEL_111_x[3]),
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_111_x[3]),
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_111_x[3]),
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_111_x[3]),
        .rr_cs_LD_OP(rr_cs_LD_OP_111_x[3]),
        .rr_cs_ST_OP(rr_cs_ST_OP_111_x[3]),
        .rr_cs_dr_id(rr_cs_dr_id_111_x[3]),
        .rr_cs_sr_id(rr_cs_sr_id_111_x[3]),
        .rr_cs_dr_rd(rr_cs_dr_rd_111_x[3]),
        .rr_cs_sr_rd(rr_cs_sr_rd_111_x[3]),
        .rr_cs_eax_rd(rr_cs_eax_rd_111_x[3]),
        .rr_cs_dr_wr(rr_cs_dr_wr_111_x[3]),
        .rr_cs_sr_wr(rr_cs_sr_wr_111_x[3]),
        .rr_cs_eax_wr(rr_cs_eax_wr_111_x[3]),
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_111_x[3]),
        .rr_cs_datasize(rr_cs_datasize_111_x[3]),
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_111_x[3]),
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_111_x[3]),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_111_x[3]),
        .rr_cs_seg_1_id(rr_cs_seg_1_id_111_x[3]),
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_111_x[3]),
        .rr_cs_special_br(rr_cs_special_br_111_x[3]),
        .dc_cs_LD_OP(dc_cs_LD_OP_111_x[3]),
        .dc_cs_ST_OP(dc_cs_ST_OP_111_x[3]),
        .dc_cs_dr_upper8(dc_cs_dr_upper8_111_x[3]),
        .dc_cs_sr_upper8(dc_cs_sr_upper8_111_x[3]),
        .dc_cs_datasize(dc_cs_datasize_111_x[3]),
        .mem_cs_ST_OP(mem_cs_ST_OP_111_x[3]),
        .mem_cs_LD_OP(mem_cs_LD_OP_111_x[3]),
        .exe_cs_ST_OP(exe_cs_ST_OP_111_x[3]),
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_111_x[3]),
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_111_x[3]),
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_111_x[3]),
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_111_x[3]),
        .exe_cs_shift_by_one(exe_cs_shift_by_one_111_x[3]),
        .exe_cs_br_ucond(exe_cs_br_ucond_111_x[3]),
        .exe_cs_relative_branch(exe_cs_relative_branch_111_x[3]),
        .exe_cs_special_br(exe_cs_special_br_111_x[3]),
        .exe_cs_is_far(exe_cs_is_far_111_x[3]),
        .exe_cs_is_call(exe_cs_is_call_111_x[3]),
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_111_x[3]),
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_111_x[3]),
        .wb_cs_ST_OP(wb_cs_ST_OP_111_x[3]),
        .wb_cs_WB_DR(wb_cs_WB_DR_111_x[3]),
        .wb_cs_WB_SR(wb_cs_WB_SR_111_x[3]),
        .wb_cs_WB_EAX(wb_cs_WB_EAX_111_x[3])
    );

    // === Stage-1 mux: pick across x ∈ {0,1,2,3} via num_pfs, per yza ===

    `MUX_4(decode_cs_REP_000_mux,                 1,             decode_cs_REP_000,                 decode_cs_REP_000_x[0],                 decode_cs_REP_000_x[1],                 decode_cs_REP_000_x[2],                 decode_cs_REP_000_x[3],                 num_pfs)
    `MUX_4(decode_cs_REP_CMP_000_mux,             1,             decode_cs_REP_CMP_000,             decode_cs_REP_CMP_000_x[0],             decode_cs_REP_CMP_000_x[1],             decode_cs_REP_CMP_000_x[2],             decode_cs_REP_CMP_000_x[3],             num_pfs)
    `MUX_4(decode_cs_HALT_000_mux,                1,             decode_cs_HALT_000,                decode_cs_HALT_000_x[0],                decode_cs_HALT_000_x[1],                decode_cs_HALT_000_x[2],                decode_cs_HALT_000_x[3],                num_pfs)
    `MUX_4(decode_cs_MODRM_NEEDED_000_mux,        1,             decode_cs_MODRM_NEEDED_000,        decode_cs_MODRM_NEEDED_000_x[0],        decode_cs_MODRM_NEEDED_000_x[1],        decode_cs_MODRM_NEEDED_000_x[2],        decode_cs_MODRM_NEEDED_000_x[3],        num_pfs)
    `MUX_4(decode_cs_RM_IS_DR_000_mux,            1,             decode_cs_RM_IS_DR_000,            decode_cs_RM_IS_DR_000_x[0],            decode_cs_RM_IS_DR_000_x[1],            decode_cs_RM_IS_DR_000_x[2],            decode_cs_RM_IS_DR_000_x[3],            num_pfs)
    `MUX_4(decode_cs_REG_IS_DR_000_mux,           1,             decode_cs_REG_IS_DR_000,           decode_cs_REG_IS_DR_000_x[0],           decode_cs_REG_IS_DR_000_x[1],           decode_cs_REG_IS_DR_000_x[2],           decode_cs_REG_IS_DR_000_x[3],           num_pfs)
    `MUX_4(decode_cs_REG_IS_SEGMENT_000_mux,      1,             decode_cs_REG_IS_SEGMENT_000,      decode_cs_REG_IS_SEGMENT_000_x[0],      decode_cs_REG_IS_SEGMENT_000_x[1],      decode_cs_REG_IS_SEGMENT_000_x[2],      decode_cs_REG_IS_SEGMENT_000_x[3],      num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_HIGH8_000_mux,  1,             decode_cs_HARDCODED_DR_HIGH8_000,  decode_cs_HARDCODED_DR_HIGH8_000_x[0],  decode_cs_HARDCODED_DR_HIGH8_000_x[1],  decode_cs_HARDCODED_DR_HIGH8_000_x[2],  decode_cs_HARDCODED_DR_HIGH8_000_x[3],  num_pfs)
    `MUX_4(decode_cs_MODRM_BUT_NO_SR_000_mux,     1,             decode_cs_MODRM_BUT_NO_SR_000,     decode_cs_MODRM_BUT_NO_SR_000_x[0],     decode_cs_MODRM_BUT_NO_SR_000_x[1],     decode_cs_MODRM_BUT_NO_SR_000_x[2],     decode_cs_MODRM_BUT_NO_SR_000_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_000_mux,        1,             decode_cs_HARDCODED_DR_000,        decode_cs_HARDCODED_DR_000_x[0],        decode_cs_HARDCODED_DR_000_x[1],        decode_cs_HARDCODED_DR_000_x[2],        decode_cs_HARDCODED_DR_000_x[3],        num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_ID_000_mux,     `REG_ID_W,     decode_cs_HARDCODED_DR_ID_000,     decode_cs_HARDCODED_DR_ID_000_x[0],     decode_cs_HARDCODED_DR_ID_000_x[1],     decode_cs_HARDCODED_DR_ID_000_x[2],     decode_cs_HARDCODED_DR_ID_000_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_000_mux,        1,             decode_cs_HARDCODED_SR_000,        decode_cs_HARDCODED_SR_000_x[0],        decode_cs_HARDCODED_SR_000_x[1],        decode_cs_HARDCODED_SR_000_x[2],        decode_cs_HARDCODED_SR_000_x[3],        num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_ID_000_mux,     `REG_ID_W,     decode_cs_HARDCODED_SR_ID_000,     decode_cs_HARDCODED_SR_ID_000_x[0],     decode_cs_HARDCODED_SR_ID_000_x[1],     decode_cs_HARDCODED_SR_ID_000_x[2],     decode_cs_HARDCODED_SR_ID_000_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_RD_000_mux,     1,             decode_cs_HARDCODED_DR_RD_000,     decode_cs_HARDCODED_DR_RD_000_x[0],     decode_cs_HARDCODED_DR_RD_000_x[1],     decode_cs_HARDCODED_DR_RD_000_x[2],     decode_cs_HARDCODED_DR_RD_000_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_WR_000_mux,     1,             decode_cs_HARDCODED_DR_WR_000,     decode_cs_HARDCODED_DR_WR_000_x[0],     decode_cs_HARDCODED_DR_WR_000_x[1],     decode_cs_HARDCODED_DR_WR_000_x[2],     decode_cs_HARDCODED_DR_WR_000_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_RD_000_mux,     1,             decode_cs_HARDCODED_SR_RD_000,     decode_cs_HARDCODED_SR_RD_000_x[0],     decode_cs_HARDCODED_SR_RD_000_x[1],     decode_cs_HARDCODED_SR_RD_000_x[2],     decode_cs_HARDCODED_SR_RD_000_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_WR_000_mux,     1,             decode_cs_HARDCODED_SR_WR_000,     decode_cs_HARDCODED_SR_WR_000_x[0],     decode_cs_HARDCODED_SR_WR_000_x[1],     decode_cs_HARDCODED_SR_WR_000_x[2],     decode_cs_HARDCODED_SR_WR_000_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_LD_OP_000_mux,     1,             decode_cs_HARDCODED_LD_OP_000,     decode_cs_HARDCODED_LD_OP_000_x[0],     decode_cs_HARDCODED_LD_OP_000_x[1],     decode_cs_HARDCODED_LD_OP_000_x[2],     decode_cs_HARDCODED_LD_OP_000_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_ST_OP_000_mux,     1,             decode_cs_HARDCODED_ST_OP_000,     decode_cs_HARDCODED_ST_OP_000_x[0],     decode_cs_HARDCODED_ST_OP_000_x[1],     decode_cs_HARDCODED_ST_OP_000_x[2],     decode_cs_HARDCODED_ST_OP_000_x[3],     num_pfs)
    `MUX_4(decode_cs_LD_OP_CANCEL_000_mux,        1,             decode_cs_LD_OP_CANCEL_000,        decode_cs_LD_OP_CANCEL_000_x[0],        decode_cs_LD_OP_CANCEL_000_x[1],        decode_cs_LD_OP_CANCEL_000_x[2],        decode_cs_LD_OP_CANCEL_000_x[3],        num_pfs)
    `MUX_4(decode_cs_ST_OP_CANCEL_000_mux,        1,             decode_cs_ST_OP_CANCEL_000,        decode_cs_ST_OP_CANCEL_000_x[0],        decode_cs_ST_OP_CANCEL_000_x[1],        decode_cs_ST_OP_CANCEL_000_x[2],        decode_cs_ST_OP_CANCEL_000_x[3],        num_pfs)
    `MUX_4(decode_cs_OP_IN_MODRM_000_mux,         1,             decode_cs_OP_IN_MODRM_000,         decode_cs_OP_IN_MODRM_000_x[0],         decode_cs_OP_IN_MODRM_000_x[1],         decode_cs_OP_IN_MODRM_000_x[2],         decode_cs_OP_IN_MODRM_000_x[3],         num_pfs)
    `MUX_4(decode_cs_DATA_SIZE_000_mux,           2,             decode_cs_DATA_SIZE_000,           decode_cs_DATA_SIZE_000_x[0],           decode_cs_DATA_SIZE_000_x[1],           decode_cs_DATA_SIZE_000_x[2],           decode_cs_DATA_SIZE_000_x[3],           num_pfs)
    `MUX_4(rr_cs_ST_SEL_000_mux,                  1,             rr_cs_ST_SEL_000,                  rr_cs_ST_SEL_000_x[0],                  rr_cs_ST_SEL_000_x[1],                  rr_cs_ST_SEL_000_x[2],                  rr_cs_ST_SEL_000_x[3],                  num_pfs)
    `MUX_4(rr_cs_MODRM_NEEDED_000_mux,            1,             rr_cs_MODRM_NEEDED_000,            rr_cs_MODRM_NEEDED_000_x[0],            rr_cs_MODRM_NEEDED_000_x[1],            rr_cs_MODRM_NEEDED_000_x[2],            rr_cs_MODRM_NEEDED_000_x[3],            num_pfs)
    `MUX_4(rr_cs_RM_IS_DR_000_mux,                1,             rr_cs_RM_IS_DR_000,                rr_cs_RM_IS_DR_000_x[0],                rr_cs_RM_IS_DR_000_x[1],                rr_cs_RM_IS_DR_000_x[2],                rr_cs_RM_IS_DR_000_x[3],                num_pfs)
    `MUX_4(rr_cs_SWITCH_LD_ADDY_000_mux,          1,             rr_cs_SWITCH_LD_ADDY_000,          rr_cs_SWITCH_LD_ADDY_000_x[0],          rr_cs_SWITCH_LD_ADDY_000_x[1],          rr_cs_SWITCH_LD_ADDY_000_x[2],          rr_cs_SWITCH_LD_ADDY_000_x[3],          num_pfs)
    `MUX_4(rr_cs_LD_OP_000_mux,                   1,             rr_cs_LD_OP_000,                   rr_cs_LD_OP_000_x[0],                   rr_cs_LD_OP_000_x[1],                   rr_cs_LD_OP_000_x[2],                   rr_cs_LD_OP_000_x[3],                   num_pfs)
    `MUX_4(rr_cs_ST_OP_000_mux,                   1,             rr_cs_ST_OP_000,                   rr_cs_ST_OP_000_x[0],                   rr_cs_ST_OP_000_x[1],                   rr_cs_ST_OP_000_x[2],                   rr_cs_ST_OP_000_x[3],                   num_pfs)
    `MUX_4(rr_cs_dr_id_000_mux,                   `REG_ID_W,     rr_cs_dr_id_000,                   rr_cs_dr_id_000_x[0],                   rr_cs_dr_id_000_x[1],                   rr_cs_dr_id_000_x[2],                   rr_cs_dr_id_000_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_id_000_mux,                   `REG_ID_W,     rr_cs_sr_id_000,                   rr_cs_sr_id_000_x[0],                   rr_cs_sr_id_000_x[1],                   rr_cs_sr_id_000_x[2],                   rr_cs_sr_id_000_x[3],                   num_pfs)
    `MUX_4(rr_cs_dr_rd_000_mux,                   1,             rr_cs_dr_rd_000,                   rr_cs_dr_rd_000_x[0],                   rr_cs_dr_rd_000_x[1],                   rr_cs_dr_rd_000_x[2],                   rr_cs_dr_rd_000_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_rd_000_mux,                   1,             rr_cs_sr_rd_000,                   rr_cs_sr_rd_000_x[0],                   rr_cs_sr_rd_000_x[1],                   rr_cs_sr_rd_000_x[2],                   rr_cs_sr_rd_000_x[3],                   num_pfs)
    `MUX_4(rr_cs_eax_rd_000_mux,                  1,             rr_cs_eax_rd_000,                  rr_cs_eax_rd_000_x[0],                  rr_cs_eax_rd_000_x[1],                  rr_cs_eax_rd_000_x[2],                  rr_cs_eax_rd_000_x[3],                  num_pfs)
    `MUX_4(rr_cs_dr_wr_000_mux,                   1,             rr_cs_dr_wr_000,                   rr_cs_dr_wr_000_x[0],                   rr_cs_dr_wr_000_x[1],                   rr_cs_dr_wr_000_x[2],                   rr_cs_dr_wr_000_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_wr_000_mux,                   1,             rr_cs_sr_wr_000,                   rr_cs_sr_wr_000_x[0],                   rr_cs_sr_wr_000_x[1],                   rr_cs_sr_wr_000_x[2],                   rr_cs_sr_wr_000_x[3],                   num_pfs)
    `MUX_4(rr_cs_eax_wr_000_mux,                  1,             rr_cs_eax_wr_000,                  rr_cs_eax_wr_000_x[0],                  rr_cs_eax_wr_000_x[1],                  rr_cs_eax_wr_000_x[2],                  rr_cs_eax_wr_000_x[3],                  num_pfs)
    `MUX_4(rr_cs_MOVS_OP_000_mux,                 1,             rr_cs_MOVS_OP_000,                 rr_cs_MOVS_OP_000_x[0],                 rr_cs_MOVS_OP_000_x[1],                 rr_cs_MOVS_OP_000_x[2],                 rr_cs_MOVS_OP_000_x[3],                 num_pfs)
    `MUX_4(rr_cs_datasize_000_mux,                2,             rr_cs_datasize_000,                rr_cs_datasize_000_x[0],                rr_cs_datasize_000_x[1],                rr_cs_datasize_000_x[2],                rr_cs_datasize_000_x[3],                num_pfs)
    `MUX_4(rr_cs_will_mod_zf_000_mux,             1,             rr_cs_will_mod_zf_000,             rr_cs_will_mod_zf_000_x[0],             rr_cs_will_mod_zf_000_x[1],             rr_cs_will_mod_zf_000_x[2],             rr_cs_will_mod_zf_000_x[3],             num_pfs)
    `MUX_4(rr_cs_seg_1_valid_000_mux,             1,             rr_cs_seg_1_valid_000,             rr_cs_seg_1_valid_000_x[0],             rr_cs_seg_1_valid_000_x[1],             rr_cs_seg_1_valid_000_x[2],             rr_cs_seg_1_valid_000_x[3],             num_pfs)
    `MUX_4(rr_cs_seg_0_id_000_mux,                `REG_ID_W,     rr_cs_seg_0_id_000,                rr_cs_seg_0_id_000_x[0],                rr_cs_seg_0_id_000_x[1],                rr_cs_seg_0_id_000_x[2],                rr_cs_seg_0_id_000_x[3],                num_pfs)
    `MUX_4(rr_cs_seg_1_id_000_mux,                `REG_ID_W,     rr_cs_seg_1_id_000,                rr_cs_seg_1_id_000_x[0],                rr_cs_seg_1_id_000_x[1],                rr_cs_seg_1_id_000_x[2],                rr_cs_seg_1_id_000_x[3],                num_pfs)
    `MUX_4(rr_cs_special_modrm_bs_000_mux,        1,             rr_cs_special_modrm_bs_000,        rr_cs_special_modrm_bs_000_x[0],        rr_cs_special_modrm_bs_000_x[1],        rr_cs_special_modrm_bs_000_x[2],        rr_cs_special_modrm_bs_000_x[3],        num_pfs)
    `MUX_4(rr_cs_special_br_000_mux,              1,             rr_cs_special_br_000,              rr_cs_special_br_000_x[0],              rr_cs_special_br_000_x[1],              rr_cs_special_br_000_x[2],              rr_cs_special_br_000_x[3],              num_pfs)
    `MUX_4(dc_cs_LD_OP_000_mux,                   1,             dc_cs_LD_OP_000,                   dc_cs_LD_OP_000_x[0],                   dc_cs_LD_OP_000_x[1],                   dc_cs_LD_OP_000_x[2],                   dc_cs_LD_OP_000_x[3],                   num_pfs)
    `MUX_4(dc_cs_ST_OP_000_mux,                   1,             dc_cs_ST_OP_000,                   dc_cs_ST_OP_000_x[0],                   dc_cs_ST_OP_000_x[1],                   dc_cs_ST_OP_000_x[2],                   dc_cs_ST_OP_000_x[3],                   num_pfs)
    `MUX_4(dc_cs_dr_upper8_000_mux,               1,             dc_cs_dr_upper8_000,               dc_cs_dr_upper8_000_x[0],               dc_cs_dr_upper8_000_x[1],               dc_cs_dr_upper8_000_x[2],               dc_cs_dr_upper8_000_x[3],               num_pfs)
    `MUX_4(dc_cs_sr_upper8_000_mux,               1,             dc_cs_sr_upper8_000,               dc_cs_sr_upper8_000_x[0],               dc_cs_sr_upper8_000_x[1],               dc_cs_sr_upper8_000_x[2],               dc_cs_sr_upper8_000_x[3],               num_pfs)
    `MUX_4(dc_cs_datasize_000_mux,                2,             dc_cs_datasize_000,                dc_cs_datasize_000_x[0],                dc_cs_datasize_000_x[1],                dc_cs_datasize_000_x[2],                dc_cs_datasize_000_x[3],                num_pfs)
    `MUX_4(mem_cs_ST_OP_000_mux,                  1,             mem_cs_ST_OP_000,                  mem_cs_ST_OP_000_x[0],                  mem_cs_ST_OP_000_x[1],                  mem_cs_ST_OP_000_x[2],                  mem_cs_ST_OP_000_x[3],                  num_pfs)
    `MUX_4(mem_cs_LD_OP_000_mux,                  1,             mem_cs_LD_OP_000,                  mem_cs_LD_OP_000_x[0],                  mem_cs_LD_OP_000_x[1],                  mem_cs_LD_OP_000_x[2],                  mem_cs_LD_OP_000_x[3],                  num_pfs)
    `MUX_4(exe_cs_ST_OP_000_mux,                  1,             exe_cs_ST_OP_000,                  exe_cs_ST_OP_000_x[0],                  exe_cs_ST_OP_000_x[1],                  exe_cs_ST_OP_000_x[2],                  exe_cs_ST_OP_000_x[3],                  num_pfs)
    `MUX_4(exe_cs_OP_TYPE_000_mux,                `EXE_OP_W,     exe_cs_OP_TYPE_000,                exe_cs_OP_TYPE_000_x[0],                exe_cs_OP_TYPE_000_x[1],                exe_cs_OP_TYPE_000_x[2],                exe_cs_OP_TYPE_000_x[3],                num_pfs)
    `MUX_4(exe_cs_alu_inputA_sel_000_mux,         `SRC_SEL_W,    exe_cs_alu_inputA_sel_000,         exe_cs_alu_inputA_sel_000_x[0],         exe_cs_alu_inputA_sel_000_x[1],         exe_cs_alu_inputA_sel_000_x[2],         exe_cs_alu_inputA_sel_000_x[3],         num_pfs)
    `MUX_4(exe_cs_alu_inputB_sel_000_mux,         `SRC_SEL_W,    exe_cs_alu_inputB_sel_000,         exe_cs_alu_inputB_sel_000_x[0],         exe_cs_alu_inputB_sel_000_x[1],         exe_cs_alu_inputB_sel_000_x[2],         exe_cs_alu_inputB_sel_000_x[3],         num_pfs)
    `MUX_4(exe_cs_branch_target_sel_000_mux,      `SRC_SEL_W,    exe_cs_branch_target_sel_000,      exe_cs_branch_target_sel_000_x[0],      exe_cs_branch_target_sel_000_x[1],      exe_cs_branch_target_sel_000_x[2],      exe_cs_branch_target_sel_000_x[3],      num_pfs)
    `MUX_4(exe_cs_shift_by_one_000_mux,           1,             exe_cs_shift_by_one_000,           exe_cs_shift_by_one_000_x[0],           exe_cs_shift_by_one_000_x[1],           exe_cs_shift_by_one_000_x[2],           exe_cs_shift_by_one_000_x[3],           num_pfs)
    `MUX_4(exe_cs_br_ucond_000_mux,               1,             exe_cs_br_ucond_000,               exe_cs_br_ucond_000_x[0],               exe_cs_br_ucond_000_x[1],               exe_cs_br_ucond_000_x[2],               exe_cs_br_ucond_000_x[3],               num_pfs)
    `MUX_4(exe_cs_relative_branch_000_mux,        1,             exe_cs_relative_branch_000,        exe_cs_relative_branch_000_x[0],        exe_cs_relative_branch_000_x[1],        exe_cs_relative_branch_000_x[2],        exe_cs_relative_branch_000_x[3],        num_pfs)
    `MUX_4(exe_cs_special_br_000_mux,             1,             exe_cs_special_br_000,             exe_cs_special_br_000_x[0],             exe_cs_special_br_000_x[1],             exe_cs_special_br_000_x[2],             exe_cs_special_br_000_x[3],             num_pfs)
    `MUX_4(exe_cs_is_far_000_mux,                 1,             exe_cs_is_far_000,                 exe_cs_is_far_000_x[0],                 exe_cs_is_far_000_x[1],                 exe_cs_is_far_000_x[2],                 exe_cs_is_far_000_x[3],                 num_pfs)
    `MUX_4(exe_cs_is_call_000_mux,                1,             exe_cs_is_call_000,                exe_cs_is_call_000_x[0],                exe_cs_is_call_000_x[1],                exe_cs_is_call_000_x[2],                exe_cs_is_call_000_x[3],                num_pfs)
    `MUX_4(exe_cs_second_flag_needed_000_mux,     1,             exe_cs_second_flag_needed_000,     exe_cs_second_flag_needed_000_x[0],     exe_cs_second_flag_needed_000_x[1],     exe_cs_second_flag_needed_000_x[2],     exe_cs_second_flag_needed_000_x[3],     num_pfs)
    `MUX_4(exe_cs_rep_no_zf_update_000_mux,       1,             exe_cs_rep_no_zf_update_000,       exe_cs_rep_no_zf_update_000_x[0],       exe_cs_rep_no_zf_update_000_x[1],       exe_cs_rep_no_zf_update_000_x[2],       exe_cs_rep_no_zf_update_000_x[3],       num_pfs)
    `MUX_4(wb_cs_ST_OP_000_mux,                   1,             wb_cs_ST_OP_000,                   wb_cs_ST_OP_000_x[0],                   wb_cs_ST_OP_000_x[1],                   wb_cs_ST_OP_000_x[2],                   wb_cs_ST_OP_000_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_DR_000_mux,                   1,             wb_cs_WB_DR_000,                   wb_cs_WB_DR_000_x[0],                   wb_cs_WB_DR_000_x[1],                   wb_cs_WB_DR_000_x[2],                   wb_cs_WB_DR_000_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_SR_000_mux,                   1,             wb_cs_WB_SR_000,                   wb_cs_WB_SR_000_x[0],                   wb_cs_WB_SR_000_x[1],                   wb_cs_WB_SR_000_x[2],                   wb_cs_WB_SR_000_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_EAX_000_mux,                  1,             wb_cs_WB_EAX_000,                  wb_cs_WB_EAX_000_x[0],                  wb_cs_WB_EAX_000_x[1],                  wb_cs_WB_EAX_000_x[2],                  wb_cs_WB_EAX_000_x[3],                  num_pfs)
    `MUX_4(decode_cs_REP_001_mux,                 1,             decode_cs_REP_001,                 decode_cs_REP_001_x[0],                 decode_cs_REP_001_x[1],                 decode_cs_REP_001_x[2],                 decode_cs_REP_001_x[3],                 num_pfs)
    `MUX_4(decode_cs_REP_CMP_001_mux,             1,             decode_cs_REP_CMP_001,             decode_cs_REP_CMP_001_x[0],             decode_cs_REP_CMP_001_x[1],             decode_cs_REP_CMP_001_x[2],             decode_cs_REP_CMP_001_x[3],             num_pfs)
    `MUX_4(decode_cs_HALT_001_mux,                1,             decode_cs_HALT_001,                decode_cs_HALT_001_x[0],                decode_cs_HALT_001_x[1],                decode_cs_HALT_001_x[2],                decode_cs_HALT_001_x[3],                num_pfs)
    `MUX_4(decode_cs_MODRM_NEEDED_001_mux,        1,             decode_cs_MODRM_NEEDED_001,        decode_cs_MODRM_NEEDED_001_x[0],        decode_cs_MODRM_NEEDED_001_x[1],        decode_cs_MODRM_NEEDED_001_x[2],        decode_cs_MODRM_NEEDED_001_x[3],        num_pfs)
    `MUX_4(decode_cs_RM_IS_DR_001_mux,            1,             decode_cs_RM_IS_DR_001,            decode_cs_RM_IS_DR_001_x[0],            decode_cs_RM_IS_DR_001_x[1],            decode_cs_RM_IS_DR_001_x[2],            decode_cs_RM_IS_DR_001_x[3],            num_pfs)
    `MUX_4(decode_cs_REG_IS_DR_001_mux,           1,             decode_cs_REG_IS_DR_001,           decode_cs_REG_IS_DR_001_x[0],           decode_cs_REG_IS_DR_001_x[1],           decode_cs_REG_IS_DR_001_x[2],           decode_cs_REG_IS_DR_001_x[3],           num_pfs)
    `MUX_4(decode_cs_REG_IS_SEGMENT_001_mux,      1,             decode_cs_REG_IS_SEGMENT_001,      decode_cs_REG_IS_SEGMENT_001_x[0],      decode_cs_REG_IS_SEGMENT_001_x[1],      decode_cs_REG_IS_SEGMENT_001_x[2],      decode_cs_REG_IS_SEGMENT_001_x[3],      num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_HIGH8_001_mux,  1,             decode_cs_HARDCODED_DR_HIGH8_001,  decode_cs_HARDCODED_DR_HIGH8_001_x[0],  decode_cs_HARDCODED_DR_HIGH8_001_x[1],  decode_cs_HARDCODED_DR_HIGH8_001_x[2],  decode_cs_HARDCODED_DR_HIGH8_001_x[3],  num_pfs)
    `MUX_4(decode_cs_MODRM_BUT_NO_SR_001_mux,     1,             decode_cs_MODRM_BUT_NO_SR_001,     decode_cs_MODRM_BUT_NO_SR_001_x[0],     decode_cs_MODRM_BUT_NO_SR_001_x[1],     decode_cs_MODRM_BUT_NO_SR_001_x[2],     decode_cs_MODRM_BUT_NO_SR_001_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_001_mux,        1,             decode_cs_HARDCODED_DR_001,        decode_cs_HARDCODED_DR_001_x[0],        decode_cs_HARDCODED_DR_001_x[1],        decode_cs_HARDCODED_DR_001_x[2],        decode_cs_HARDCODED_DR_001_x[3],        num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_ID_001_mux,     `REG_ID_W,     decode_cs_HARDCODED_DR_ID_001,     decode_cs_HARDCODED_DR_ID_001_x[0],     decode_cs_HARDCODED_DR_ID_001_x[1],     decode_cs_HARDCODED_DR_ID_001_x[2],     decode_cs_HARDCODED_DR_ID_001_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_001_mux,        1,             decode_cs_HARDCODED_SR_001,        decode_cs_HARDCODED_SR_001_x[0],        decode_cs_HARDCODED_SR_001_x[1],        decode_cs_HARDCODED_SR_001_x[2],        decode_cs_HARDCODED_SR_001_x[3],        num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_ID_001_mux,     `REG_ID_W,     decode_cs_HARDCODED_SR_ID_001,     decode_cs_HARDCODED_SR_ID_001_x[0],     decode_cs_HARDCODED_SR_ID_001_x[1],     decode_cs_HARDCODED_SR_ID_001_x[2],     decode_cs_HARDCODED_SR_ID_001_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_RD_001_mux,     1,             decode_cs_HARDCODED_DR_RD_001,     decode_cs_HARDCODED_DR_RD_001_x[0],     decode_cs_HARDCODED_DR_RD_001_x[1],     decode_cs_HARDCODED_DR_RD_001_x[2],     decode_cs_HARDCODED_DR_RD_001_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_WR_001_mux,     1,             decode_cs_HARDCODED_DR_WR_001,     decode_cs_HARDCODED_DR_WR_001_x[0],     decode_cs_HARDCODED_DR_WR_001_x[1],     decode_cs_HARDCODED_DR_WR_001_x[2],     decode_cs_HARDCODED_DR_WR_001_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_RD_001_mux,     1,             decode_cs_HARDCODED_SR_RD_001,     decode_cs_HARDCODED_SR_RD_001_x[0],     decode_cs_HARDCODED_SR_RD_001_x[1],     decode_cs_HARDCODED_SR_RD_001_x[2],     decode_cs_HARDCODED_SR_RD_001_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_WR_001_mux,     1,             decode_cs_HARDCODED_SR_WR_001,     decode_cs_HARDCODED_SR_WR_001_x[0],     decode_cs_HARDCODED_SR_WR_001_x[1],     decode_cs_HARDCODED_SR_WR_001_x[2],     decode_cs_HARDCODED_SR_WR_001_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_LD_OP_001_mux,     1,             decode_cs_HARDCODED_LD_OP_001,     decode_cs_HARDCODED_LD_OP_001_x[0],     decode_cs_HARDCODED_LD_OP_001_x[1],     decode_cs_HARDCODED_LD_OP_001_x[2],     decode_cs_HARDCODED_LD_OP_001_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_ST_OP_001_mux,     1,             decode_cs_HARDCODED_ST_OP_001,     decode_cs_HARDCODED_ST_OP_001_x[0],     decode_cs_HARDCODED_ST_OP_001_x[1],     decode_cs_HARDCODED_ST_OP_001_x[2],     decode_cs_HARDCODED_ST_OP_001_x[3],     num_pfs)
    `MUX_4(decode_cs_LD_OP_CANCEL_001_mux,        1,             decode_cs_LD_OP_CANCEL_001,        decode_cs_LD_OP_CANCEL_001_x[0],        decode_cs_LD_OP_CANCEL_001_x[1],        decode_cs_LD_OP_CANCEL_001_x[2],        decode_cs_LD_OP_CANCEL_001_x[3],        num_pfs)
    `MUX_4(decode_cs_ST_OP_CANCEL_001_mux,        1,             decode_cs_ST_OP_CANCEL_001,        decode_cs_ST_OP_CANCEL_001_x[0],        decode_cs_ST_OP_CANCEL_001_x[1],        decode_cs_ST_OP_CANCEL_001_x[2],        decode_cs_ST_OP_CANCEL_001_x[3],        num_pfs)
    `MUX_4(decode_cs_OP_IN_MODRM_001_mux,         1,             decode_cs_OP_IN_MODRM_001,         decode_cs_OP_IN_MODRM_001_x[0],         decode_cs_OP_IN_MODRM_001_x[1],         decode_cs_OP_IN_MODRM_001_x[2],         decode_cs_OP_IN_MODRM_001_x[3],         num_pfs)
    `MUX_4(decode_cs_DATA_SIZE_001_mux,           2,             decode_cs_DATA_SIZE_001,           decode_cs_DATA_SIZE_001_x[0],           decode_cs_DATA_SIZE_001_x[1],           decode_cs_DATA_SIZE_001_x[2],           decode_cs_DATA_SIZE_001_x[3],           num_pfs)
    `MUX_4(rr_cs_ST_SEL_001_mux,                  1,             rr_cs_ST_SEL_001,                  rr_cs_ST_SEL_001_x[0],                  rr_cs_ST_SEL_001_x[1],                  rr_cs_ST_SEL_001_x[2],                  rr_cs_ST_SEL_001_x[3],                  num_pfs)
    `MUX_4(rr_cs_MODRM_NEEDED_001_mux,            1,             rr_cs_MODRM_NEEDED_001,            rr_cs_MODRM_NEEDED_001_x[0],            rr_cs_MODRM_NEEDED_001_x[1],            rr_cs_MODRM_NEEDED_001_x[2],            rr_cs_MODRM_NEEDED_001_x[3],            num_pfs)
    `MUX_4(rr_cs_RM_IS_DR_001_mux,                1,             rr_cs_RM_IS_DR_001,                rr_cs_RM_IS_DR_001_x[0],                rr_cs_RM_IS_DR_001_x[1],                rr_cs_RM_IS_DR_001_x[2],                rr_cs_RM_IS_DR_001_x[3],                num_pfs)
    `MUX_4(rr_cs_SWITCH_LD_ADDY_001_mux,          1,             rr_cs_SWITCH_LD_ADDY_001,          rr_cs_SWITCH_LD_ADDY_001_x[0],          rr_cs_SWITCH_LD_ADDY_001_x[1],          rr_cs_SWITCH_LD_ADDY_001_x[2],          rr_cs_SWITCH_LD_ADDY_001_x[3],          num_pfs)
    `MUX_4(rr_cs_LD_OP_001_mux,                   1,             rr_cs_LD_OP_001,                   rr_cs_LD_OP_001_x[0],                   rr_cs_LD_OP_001_x[1],                   rr_cs_LD_OP_001_x[2],                   rr_cs_LD_OP_001_x[3],                   num_pfs)
    `MUX_4(rr_cs_ST_OP_001_mux,                   1,             rr_cs_ST_OP_001,                   rr_cs_ST_OP_001_x[0],                   rr_cs_ST_OP_001_x[1],                   rr_cs_ST_OP_001_x[2],                   rr_cs_ST_OP_001_x[3],                   num_pfs)
    `MUX_4(rr_cs_dr_id_001_mux,                   `REG_ID_W,     rr_cs_dr_id_001,                   rr_cs_dr_id_001_x[0],                   rr_cs_dr_id_001_x[1],                   rr_cs_dr_id_001_x[2],                   rr_cs_dr_id_001_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_id_001_mux,                   `REG_ID_W,     rr_cs_sr_id_001,                   rr_cs_sr_id_001_x[0],                   rr_cs_sr_id_001_x[1],                   rr_cs_sr_id_001_x[2],                   rr_cs_sr_id_001_x[3],                   num_pfs)
    `MUX_4(rr_cs_dr_rd_001_mux,                   1,             rr_cs_dr_rd_001,                   rr_cs_dr_rd_001_x[0],                   rr_cs_dr_rd_001_x[1],                   rr_cs_dr_rd_001_x[2],                   rr_cs_dr_rd_001_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_rd_001_mux,                   1,             rr_cs_sr_rd_001,                   rr_cs_sr_rd_001_x[0],                   rr_cs_sr_rd_001_x[1],                   rr_cs_sr_rd_001_x[2],                   rr_cs_sr_rd_001_x[3],                   num_pfs)
    `MUX_4(rr_cs_eax_rd_001_mux,                  1,             rr_cs_eax_rd_001,                  rr_cs_eax_rd_001_x[0],                  rr_cs_eax_rd_001_x[1],                  rr_cs_eax_rd_001_x[2],                  rr_cs_eax_rd_001_x[3],                  num_pfs)
    `MUX_4(rr_cs_dr_wr_001_mux,                   1,             rr_cs_dr_wr_001,                   rr_cs_dr_wr_001_x[0],                   rr_cs_dr_wr_001_x[1],                   rr_cs_dr_wr_001_x[2],                   rr_cs_dr_wr_001_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_wr_001_mux,                   1,             rr_cs_sr_wr_001,                   rr_cs_sr_wr_001_x[0],                   rr_cs_sr_wr_001_x[1],                   rr_cs_sr_wr_001_x[2],                   rr_cs_sr_wr_001_x[3],                   num_pfs)
    `MUX_4(rr_cs_eax_wr_001_mux,                  1,             rr_cs_eax_wr_001,                  rr_cs_eax_wr_001_x[0],                  rr_cs_eax_wr_001_x[1],                  rr_cs_eax_wr_001_x[2],                  rr_cs_eax_wr_001_x[3],                  num_pfs)
    `MUX_4(rr_cs_MOVS_OP_001_mux,                 1,             rr_cs_MOVS_OP_001,                 rr_cs_MOVS_OP_001_x[0],                 rr_cs_MOVS_OP_001_x[1],                 rr_cs_MOVS_OP_001_x[2],                 rr_cs_MOVS_OP_001_x[3],                 num_pfs)
    `MUX_4(rr_cs_datasize_001_mux,                2,             rr_cs_datasize_001,                rr_cs_datasize_001_x[0],                rr_cs_datasize_001_x[1],                rr_cs_datasize_001_x[2],                rr_cs_datasize_001_x[3],                num_pfs)
    `MUX_4(rr_cs_will_mod_zf_001_mux,             1,             rr_cs_will_mod_zf_001,             rr_cs_will_mod_zf_001_x[0],             rr_cs_will_mod_zf_001_x[1],             rr_cs_will_mod_zf_001_x[2],             rr_cs_will_mod_zf_001_x[3],             num_pfs)
    `MUX_4(rr_cs_seg_1_valid_001_mux,             1,             rr_cs_seg_1_valid_001,             rr_cs_seg_1_valid_001_x[0],             rr_cs_seg_1_valid_001_x[1],             rr_cs_seg_1_valid_001_x[2],             rr_cs_seg_1_valid_001_x[3],             num_pfs)
    `MUX_4(rr_cs_seg_0_id_001_mux,                `REG_ID_W,     rr_cs_seg_0_id_001,                rr_cs_seg_0_id_001_x[0],                rr_cs_seg_0_id_001_x[1],                rr_cs_seg_0_id_001_x[2],                rr_cs_seg_0_id_001_x[3],                num_pfs)
    `MUX_4(rr_cs_seg_1_id_001_mux,                `REG_ID_W,     rr_cs_seg_1_id_001,                rr_cs_seg_1_id_001_x[0],                rr_cs_seg_1_id_001_x[1],                rr_cs_seg_1_id_001_x[2],                rr_cs_seg_1_id_001_x[3],                num_pfs)
    `MUX_4(rr_cs_special_modrm_bs_001_mux,        1,             rr_cs_special_modrm_bs_001,        rr_cs_special_modrm_bs_001_x[0],        rr_cs_special_modrm_bs_001_x[1],        rr_cs_special_modrm_bs_001_x[2],        rr_cs_special_modrm_bs_001_x[3],        num_pfs)
    `MUX_4(rr_cs_special_br_001_mux,              1,             rr_cs_special_br_001,              rr_cs_special_br_001_x[0],              rr_cs_special_br_001_x[1],              rr_cs_special_br_001_x[2],              rr_cs_special_br_001_x[3],              num_pfs)
    `MUX_4(dc_cs_LD_OP_001_mux,                   1,             dc_cs_LD_OP_001,                   dc_cs_LD_OP_001_x[0],                   dc_cs_LD_OP_001_x[1],                   dc_cs_LD_OP_001_x[2],                   dc_cs_LD_OP_001_x[3],                   num_pfs)
    `MUX_4(dc_cs_ST_OP_001_mux,                   1,             dc_cs_ST_OP_001,                   dc_cs_ST_OP_001_x[0],                   dc_cs_ST_OP_001_x[1],                   dc_cs_ST_OP_001_x[2],                   dc_cs_ST_OP_001_x[3],                   num_pfs)
    `MUX_4(dc_cs_dr_upper8_001_mux,               1,             dc_cs_dr_upper8_001,               dc_cs_dr_upper8_001_x[0],               dc_cs_dr_upper8_001_x[1],               dc_cs_dr_upper8_001_x[2],               dc_cs_dr_upper8_001_x[3],               num_pfs)
    `MUX_4(dc_cs_sr_upper8_001_mux,               1,             dc_cs_sr_upper8_001,               dc_cs_sr_upper8_001_x[0],               dc_cs_sr_upper8_001_x[1],               dc_cs_sr_upper8_001_x[2],               dc_cs_sr_upper8_001_x[3],               num_pfs)
    `MUX_4(dc_cs_datasize_001_mux,                2,             dc_cs_datasize_001,                dc_cs_datasize_001_x[0],                dc_cs_datasize_001_x[1],                dc_cs_datasize_001_x[2],                dc_cs_datasize_001_x[3],                num_pfs)
    `MUX_4(mem_cs_ST_OP_001_mux,                  1,             mem_cs_ST_OP_001,                  mem_cs_ST_OP_001_x[0],                  mem_cs_ST_OP_001_x[1],                  mem_cs_ST_OP_001_x[2],                  mem_cs_ST_OP_001_x[3],                  num_pfs)
    `MUX_4(mem_cs_LD_OP_001_mux,                  1,             mem_cs_LD_OP_001,                  mem_cs_LD_OP_001_x[0],                  mem_cs_LD_OP_001_x[1],                  mem_cs_LD_OP_001_x[2],                  mem_cs_LD_OP_001_x[3],                  num_pfs)
    `MUX_4(exe_cs_ST_OP_001_mux,                  1,             exe_cs_ST_OP_001,                  exe_cs_ST_OP_001_x[0],                  exe_cs_ST_OP_001_x[1],                  exe_cs_ST_OP_001_x[2],                  exe_cs_ST_OP_001_x[3],                  num_pfs)
    `MUX_4(exe_cs_OP_TYPE_001_mux,                `EXE_OP_W,     exe_cs_OP_TYPE_001,                exe_cs_OP_TYPE_001_x[0],                exe_cs_OP_TYPE_001_x[1],                exe_cs_OP_TYPE_001_x[2],                exe_cs_OP_TYPE_001_x[3],                num_pfs)
    `MUX_4(exe_cs_alu_inputA_sel_001_mux,         `SRC_SEL_W,    exe_cs_alu_inputA_sel_001,         exe_cs_alu_inputA_sel_001_x[0],         exe_cs_alu_inputA_sel_001_x[1],         exe_cs_alu_inputA_sel_001_x[2],         exe_cs_alu_inputA_sel_001_x[3],         num_pfs)
    `MUX_4(exe_cs_alu_inputB_sel_001_mux,         `SRC_SEL_W,    exe_cs_alu_inputB_sel_001,         exe_cs_alu_inputB_sel_001_x[0],         exe_cs_alu_inputB_sel_001_x[1],         exe_cs_alu_inputB_sel_001_x[2],         exe_cs_alu_inputB_sel_001_x[3],         num_pfs)
    `MUX_4(exe_cs_branch_target_sel_001_mux,      `SRC_SEL_W,    exe_cs_branch_target_sel_001,      exe_cs_branch_target_sel_001_x[0],      exe_cs_branch_target_sel_001_x[1],      exe_cs_branch_target_sel_001_x[2],      exe_cs_branch_target_sel_001_x[3],      num_pfs)
    `MUX_4(exe_cs_shift_by_one_001_mux,           1,             exe_cs_shift_by_one_001,           exe_cs_shift_by_one_001_x[0],           exe_cs_shift_by_one_001_x[1],           exe_cs_shift_by_one_001_x[2],           exe_cs_shift_by_one_001_x[3],           num_pfs)
    `MUX_4(exe_cs_br_ucond_001_mux,               1,             exe_cs_br_ucond_001,               exe_cs_br_ucond_001_x[0],               exe_cs_br_ucond_001_x[1],               exe_cs_br_ucond_001_x[2],               exe_cs_br_ucond_001_x[3],               num_pfs)
    `MUX_4(exe_cs_relative_branch_001_mux,        1,             exe_cs_relative_branch_001,        exe_cs_relative_branch_001_x[0],        exe_cs_relative_branch_001_x[1],        exe_cs_relative_branch_001_x[2],        exe_cs_relative_branch_001_x[3],        num_pfs)
    `MUX_4(exe_cs_special_br_001_mux,             1,             exe_cs_special_br_001,             exe_cs_special_br_001_x[0],             exe_cs_special_br_001_x[1],             exe_cs_special_br_001_x[2],             exe_cs_special_br_001_x[3],             num_pfs)
    `MUX_4(exe_cs_is_far_001_mux,                 1,             exe_cs_is_far_001,                 exe_cs_is_far_001_x[0],                 exe_cs_is_far_001_x[1],                 exe_cs_is_far_001_x[2],                 exe_cs_is_far_001_x[3],                 num_pfs)
    `MUX_4(exe_cs_is_call_001_mux,                1,             exe_cs_is_call_001,                exe_cs_is_call_001_x[0],                exe_cs_is_call_001_x[1],                exe_cs_is_call_001_x[2],                exe_cs_is_call_001_x[3],                num_pfs)
    `MUX_4(exe_cs_second_flag_needed_001_mux,     1,             exe_cs_second_flag_needed_001,     exe_cs_second_flag_needed_001_x[0],     exe_cs_second_flag_needed_001_x[1],     exe_cs_second_flag_needed_001_x[2],     exe_cs_second_flag_needed_001_x[3],     num_pfs)
    `MUX_4(exe_cs_rep_no_zf_update_001_mux,       1,             exe_cs_rep_no_zf_update_001,       exe_cs_rep_no_zf_update_001_x[0],       exe_cs_rep_no_zf_update_001_x[1],       exe_cs_rep_no_zf_update_001_x[2],       exe_cs_rep_no_zf_update_001_x[3],       num_pfs)
    `MUX_4(wb_cs_ST_OP_001_mux,                   1,             wb_cs_ST_OP_001,                   wb_cs_ST_OP_001_x[0],                   wb_cs_ST_OP_001_x[1],                   wb_cs_ST_OP_001_x[2],                   wb_cs_ST_OP_001_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_DR_001_mux,                   1,             wb_cs_WB_DR_001,                   wb_cs_WB_DR_001_x[0],                   wb_cs_WB_DR_001_x[1],                   wb_cs_WB_DR_001_x[2],                   wb_cs_WB_DR_001_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_SR_001_mux,                   1,             wb_cs_WB_SR_001,                   wb_cs_WB_SR_001_x[0],                   wb_cs_WB_SR_001_x[1],                   wb_cs_WB_SR_001_x[2],                   wb_cs_WB_SR_001_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_EAX_001_mux,                  1,             wb_cs_WB_EAX_001,                  wb_cs_WB_EAX_001_x[0],                  wb_cs_WB_EAX_001_x[1],                  wb_cs_WB_EAX_001_x[2],                  wb_cs_WB_EAX_001_x[3],                  num_pfs)
    `MUX_4(decode_cs_REP_010_mux,                 1,             decode_cs_REP_010,                 decode_cs_REP_010_x[0],                 decode_cs_REP_010_x[1],                 decode_cs_REP_010_x[2],                 decode_cs_REP_010_x[3],                 num_pfs)
    `MUX_4(decode_cs_REP_CMP_010_mux,             1,             decode_cs_REP_CMP_010,             decode_cs_REP_CMP_010_x[0],             decode_cs_REP_CMP_010_x[1],             decode_cs_REP_CMP_010_x[2],             decode_cs_REP_CMP_010_x[3],             num_pfs)
    `MUX_4(decode_cs_HALT_010_mux,                1,             decode_cs_HALT_010,                decode_cs_HALT_010_x[0],                decode_cs_HALT_010_x[1],                decode_cs_HALT_010_x[2],                decode_cs_HALT_010_x[3],                num_pfs)
    `MUX_4(decode_cs_MODRM_NEEDED_010_mux,        1,             decode_cs_MODRM_NEEDED_010,        decode_cs_MODRM_NEEDED_010_x[0],        decode_cs_MODRM_NEEDED_010_x[1],        decode_cs_MODRM_NEEDED_010_x[2],        decode_cs_MODRM_NEEDED_010_x[3],        num_pfs)
    `MUX_4(decode_cs_RM_IS_DR_010_mux,            1,             decode_cs_RM_IS_DR_010,            decode_cs_RM_IS_DR_010_x[0],            decode_cs_RM_IS_DR_010_x[1],            decode_cs_RM_IS_DR_010_x[2],            decode_cs_RM_IS_DR_010_x[3],            num_pfs)
    `MUX_4(decode_cs_REG_IS_DR_010_mux,           1,             decode_cs_REG_IS_DR_010,           decode_cs_REG_IS_DR_010_x[0],           decode_cs_REG_IS_DR_010_x[1],           decode_cs_REG_IS_DR_010_x[2],           decode_cs_REG_IS_DR_010_x[3],           num_pfs)
    `MUX_4(decode_cs_REG_IS_SEGMENT_010_mux,      1,             decode_cs_REG_IS_SEGMENT_010,      decode_cs_REG_IS_SEGMENT_010_x[0],      decode_cs_REG_IS_SEGMENT_010_x[1],      decode_cs_REG_IS_SEGMENT_010_x[2],      decode_cs_REG_IS_SEGMENT_010_x[3],      num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_HIGH8_010_mux,  1,             decode_cs_HARDCODED_DR_HIGH8_010,  decode_cs_HARDCODED_DR_HIGH8_010_x[0],  decode_cs_HARDCODED_DR_HIGH8_010_x[1],  decode_cs_HARDCODED_DR_HIGH8_010_x[2],  decode_cs_HARDCODED_DR_HIGH8_010_x[3],  num_pfs)
    `MUX_4(decode_cs_MODRM_BUT_NO_SR_010_mux,     1,             decode_cs_MODRM_BUT_NO_SR_010,     decode_cs_MODRM_BUT_NO_SR_010_x[0],     decode_cs_MODRM_BUT_NO_SR_010_x[1],     decode_cs_MODRM_BUT_NO_SR_010_x[2],     decode_cs_MODRM_BUT_NO_SR_010_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_010_mux,        1,             decode_cs_HARDCODED_DR_010,        decode_cs_HARDCODED_DR_010_x[0],        decode_cs_HARDCODED_DR_010_x[1],        decode_cs_HARDCODED_DR_010_x[2],        decode_cs_HARDCODED_DR_010_x[3],        num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_ID_010_mux,     `REG_ID_W,     decode_cs_HARDCODED_DR_ID_010,     decode_cs_HARDCODED_DR_ID_010_x[0],     decode_cs_HARDCODED_DR_ID_010_x[1],     decode_cs_HARDCODED_DR_ID_010_x[2],     decode_cs_HARDCODED_DR_ID_010_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_010_mux,        1,             decode_cs_HARDCODED_SR_010,        decode_cs_HARDCODED_SR_010_x[0],        decode_cs_HARDCODED_SR_010_x[1],        decode_cs_HARDCODED_SR_010_x[2],        decode_cs_HARDCODED_SR_010_x[3],        num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_ID_010_mux,     `REG_ID_W,     decode_cs_HARDCODED_SR_ID_010,     decode_cs_HARDCODED_SR_ID_010_x[0],     decode_cs_HARDCODED_SR_ID_010_x[1],     decode_cs_HARDCODED_SR_ID_010_x[2],     decode_cs_HARDCODED_SR_ID_010_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_RD_010_mux,     1,             decode_cs_HARDCODED_DR_RD_010,     decode_cs_HARDCODED_DR_RD_010_x[0],     decode_cs_HARDCODED_DR_RD_010_x[1],     decode_cs_HARDCODED_DR_RD_010_x[2],     decode_cs_HARDCODED_DR_RD_010_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_WR_010_mux,     1,             decode_cs_HARDCODED_DR_WR_010,     decode_cs_HARDCODED_DR_WR_010_x[0],     decode_cs_HARDCODED_DR_WR_010_x[1],     decode_cs_HARDCODED_DR_WR_010_x[2],     decode_cs_HARDCODED_DR_WR_010_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_RD_010_mux,     1,             decode_cs_HARDCODED_SR_RD_010,     decode_cs_HARDCODED_SR_RD_010_x[0],     decode_cs_HARDCODED_SR_RD_010_x[1],     decode_cs_HARDCODED_SR_RD_010_x[2],     decode_cs_HARDCODED_SR_RD_010_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_WR_010_mux,     1,             decode_cs_HARDCODED_SR_WR_010,     decode_cs_HARDCODED_SR_WR_010_x[0],     decode_cs_HARDCODED_SR_WR_010_x[1],     decode_cs_HARDCODED_SR_WR_010_x[2],     decode_cs_HARDCODED_SR_WR_010_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_LD_OP_010_mux,     1,             decode_cs_HARDCODED_LD_OP_010,     decode_cs_HARDCODED_LD_OP_010_x[0],     decode_cs_HARDCODED_LD_OP_010_x[1],     decode_cs_HARDCODED_LD_OP_010_x[2],     decode_cs_HARDCODED_LD_OP_010_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_ST_OP_010_mux,     1,             decode_cs_HARDCODED_ST_OP_010,     decode_cs_HARDCODED_ST_OP_010_x[0],     decode_cs_HARDCODED_ST_OP_010_x[1],     decode_cs_HARDCODED_ST_OP_010_x[2],     decode_cs_HARDCODED_ST_OP_010_x[3],     num_pfs)
    `MUX_4(decode_cs_LD_OP_CANCEL_010_mux,        1,             decode_cs_LD_OP_CANCEL_010,        decode_cs_LD_OP_CANCEL_010_x[0],        decode_cs_LD_OP_CANCEL_010_x[1],        decode_cs_LD_OP_CANCEL_010_x[2],        decode_cs_LD_OP_CANCEL_010_x[3],        num_pfs)
    `MUX_4(decode_cs_ST_OP_CANCEL_010_mux,        1,             decode_cs_ST_OP_CANCEL_010,        decode_cs_ST_OP_CANCEL_010_x[0],        decode_cs_ST_OP_CANCEL_010_x[1],        decode_cs_ST_OP_CANCEL_010_x[2],        decode_cs_ST_OP_CANCEL_010_x[3],        num_pfs)
    `MUX_4(decode_cs_OP_IN_MODRM_010_mux,         1,             decode_cs_OP_IN_MODRM_010,         decode_cs_OP_IN_MODRM_010_x[0],         decode_cs_OP_IN_MODRM_010_x[1],         decode_cs_OP_IN_MODRM_010_x[2],         decode_cs_OP_IN_MODRM_010_x[3],         num_pfs)
    `MUX_4(decode_cs_DATA_SIZE_010_mux,           2,             decode_cs_DATA_SIZE_010,           decode_cs_DATA_SIZE_010_x[0],           decode_cs_DATA_SIZE_010_x[1],           decode_cs_DATA_SIZE_010_x[2],           decode_cs_DATA_SIZE_010_x[3],           num_pfs)
    `MUX_4(rr_cs_ST_SEL_010_mux,                  1,             rr_cs_ST_SEL_010,                  rr_cs_ST_SEL_010_x[0],                  rr_cs_ST_SEL_010_x[1],                  rr_cs_ST_SEL_010_x[2],                  rr_cs_ST_SEL_010_x[3],                  num_pfs)
    `MUX_4(rr_cs_MODRM_NEEDED_010_mux,            1,             rr_cs_MODRM_NEEDED_010,            rr_cs_MODRM_NEEDED_010_x[0],            rr_cs_MODRM_NEEDED_010_x[1],            rr_cs_MODRM_NEEDED_010_x[2],            rr_cs_MODRM_NEEDED_010_x[3],            num_pfs)
    `MUX_4(rr_cs_RM_IS_DR_010_mux,                1,             rr_cs_RM_IS_DR_010,                rr_cs_RM_IS_DR_010_x[0],                rr_cs_RM_IS_DR_010_x[1],                rr_cs_RM_IS_DR_010_x[2],                rr_cs_RM_IS_DR_010_x[3],                num_pfs)
    `MUX_4(rr_cs_SWITCH_LD_ADDY_010_mux,          1,             rr_cs_SWITCH_LD_ADDY_010,          rr_cs_SWITCH_LD_ADDY_010_x[0],          rr_cs_SWITCH_LD_ADDY_010_x[1],          rr_cs_SWITCH_LD_ADDY_010_x[2],          rr_cs_SWITCH_LD_ADDY_010_x[3],          num_pfs)
    `MUX_4(rr_cs_LD_OP_010_mux,                   1,             rr_cs_LD_OP_010,                   rr_cs_LD_OP_010_x[0],                   rr_cs_LD_OP_010_x[1],                   rr_cs_LD_OP_010_x[2],                   rr_cs_LD_OP_010_x[3],                   num_pfs)
    `MUX_4(rr_cs_ST_OP_010_mux,                   1,             rr_cs_ST_OP_010,                   rr_cs_ST_OP_010_x[0],                   rr_cs_ST_OP_010_x[1],                   rr_cs_ST_OP_010_x[2],                   rr_cs_ST_OP_010_x[3],                   num_pfs)
    `MUX_4(rr_cs_dr_id_010_mux,                   `REG_ID_W,     rr_cs_dr_id_010,                   rr_cs_dr_id_010_x[0],                   rr_cs_dr_id_010_x[1],                   rr_cs_dr_id_010_x[2],                   rr_cs_dr_id_010_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_id_010_mux,                   `REG_ID_W,     rr_cs_sr_id_010,                   rr_cs_sr_id_010_x[0],                   rr_cs_sr_id_010_x[1],                   rr_cs_sr_id_010_x[2],                   rr_cs_sr_id_010_x[3],                   num_pfs)
    `MUX_4(rr_cs_dr_rd_010_mux,                   1,             rr_cs_dr_rd_010,                   rr_cs_dr_rd_010_x[0],                   rr_cs_dr_rd_010_x[1],                   rr_cs_dr_rd_010_x[2],                   rr_cs_dr_rd_010_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_rd_010_mux,                   1,             rr_cs_sr_rd_010,                   rr_cs_sr_rd_010_x[0],                   rr_cs_sr_rd_010_x[1],                   rr_cs_sr_rd_010_x[2],                   rr_cs_sr_rd_010_x[3],                   num_pfs)
    `MUX_4(rr_cs_eax_rd_010_mux,                  1,             rr_cs_eax_rd_010,                  rr_cs_eax_rd_010_x[0],                  rr_cs_eax_rd_010_x[1],                  rr_cs_eax_rd_010_x[2],                  rr_cs_eax_rd_010_x[3],                  num_pfs)
    `MUX_4(rr_cs_dr_wr_010_mux,                   1,             rr_cs_dr_wr_010,                   rr_cs_dr_wr_010_x[0],                   rr_cs_dr_wr_010_x[1],                   rr_cs_dr_wr_010_x[2],                   rr_cs_dr_wr_010_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_wr_010_mux,                   1,             rr_cs_sr_wr_010,                   rr_cs_sr_wr_010_x[0],                   rr_cs_sr_wr_010_x[1],                   rr_cs_sr_wr_010_x[2],                   rr_cs_sr_wr_010_x[3],                   num_pfs)
    `MUX_4(rr_cs_eax_wr_010_mux,                  1,             rr_cs_eax_wr_010,                  rr_cs_eax_wr_010_x[0],                  rr_cs_eax_wr_010_x[1],                  rr_cs_eax_wr_010_x[2],                  rr_cs_eax_wr_010_x[3],                  num_pfs)
    `MUX_4(rr_cs_MOVS_OP_010_mux,                 1,             rr_cs_MOVS_OP_010,                 rr_cs_MOVS_OP_010_x[0],                 rr_cs_MOVS_OP_010_x[1],                 rr_cs_MOVS_OP_010_x[2],                 rr_cs_MOVS_OP_010_x[3],                 num_pfs)
    `MUX_4(rr_cs_datasize_010_mux,                2,             rr_cs_datasize_010,                rr_cs_datasize_010_x[0],                rr_cs_datasize_010_x[1],                rr_cs_datasize_010_x[2],                rr_cs_datasize_010_x[3],                num_pfs)
    `MUX_4(rr_cs_will_mod_zf_010_mux,             1,             rr_cs_will_mod_zf_010,             rr_cs_will_mod_zf_010_x[0],             rr_cs_will_mod_zf_010_x[1],             rr_cs_will_mod_zf_010_x[2],             rr_cs_will_mod_zf_010_x[3],             num_pfs)
    `MUX_4(rr_cs_seg_1_valid_010_mux,             1,             rr_cs_seg_1_valid_010,             rr_cs_seg_1_valid_010_x[0],             rr_cs_seg_1_valid_010_x[1],             rr_cs_seg_1_valid_010_x[2],             rr_cs_seg_1_valid_010_x[3],             num_pfs)
    `MUX_4(rr_cs_seg_0_id_010_mux,                `REG_ID_W,     rr_cs_seg_0_id_010,                rr_cs_seg_0_id_010_x[0],                rr_cs_seg_0_id_010_x[1],                rr_cs_seg_0_id_010_x[2],                rr_cs_seg_0_id_010_x[3],                num_pfs)
    `MUX_4(rr_cs_seg_1_id_010_mux,                `REG_ID_W,     rr_cs_seg_1_id_010,                rr_cs_seg_1_id_010_x[0],                rr_cs_seg_1_id_010_x[1],                rr_cs_seg_1_id_010_x[2],                rr_cs_seg_1_id_010_x[3],                num_pfs)
    `MUX_4(rr_cs_special_modrm_bs_010_mux,        1,             rr_cs_special_modrm_bs_010,        rr_cs_special_modrm_bs_010_x[0],        rr_cs_special_modrm_bs_010_x[1],        rr_cs_special_modrm_bs_010_x[2],        rr_cs_special_modrm_bs_010_x[3],        num_pfs)
    `MUX_4(rr_cs_special_br_010_mux,              1,             rr_cs_special_br_010,              rr_cs_special_br_010_x[0],              rr_cs_special_br_010_x[1],              rr_cs_special_br_010_x[2],              rr_cs_special_br_010_x[3],              num_pfs)
    `MUX_4(dc_cs_LD_OP_010_mux,                   1,             dc_cs_LD_OP_010,                   dc_cs_LD_OP_010_x[0],                   dc_cs_LD_OP_010_x[1],                   dc_cs_LD_OP_010_x[2],                   dc_cs_LD_OP_010_x[3],                   num_pfs)
    `MUX_4(dc_cs_ST_OP_010_mux,                   1,             dc_cs_ST_OP_010,                   dc_cs_ST_OP_010_x[0],                   dc_cs_ST_OP_010_x[1],                   dc_cs_ST_OP_010_x[2],                   dc_cs_ST_OP_010_x[3],                   num_pfs)
    `MUX_4(dc_cs_dr_upper8_010_mux,               1,             dc_cs_dr_upper8_010,               dc_cs_dr_upper8_010_x[0],               dc_cs_dr_upper8_010_x[1],               dc_cs_dr_upper8_010_x[2],               dc_cs_dr_upper8_010_x[3],               num_pfs)
    `MUX_4(dc_cs_sr_upper8_010_mux,               1,             dc_cs_sr_upper8_010,               dc_cs_sr_upper8_010_x[0],               dc_cs_sr_upper8_010_x[1],               dc_cs_sr_upper8_010_x[2],               dc_cs_sr_upper8_010_x[3],               num_pfs)
    `MUX_4(dc_cs_datasize_010_mux,                2,             dc_cs_datasize_010,                dc_cs_datasize_010_x[0],                dc_cs_datasize_010_x[1],                dc_cs_datasize_010_x[2],                dc_cs_datasize_010_x[3],                num_pfs)
    `MUX_4(mem_cs_ST_OP_010_mux,                  1,             mem_cs_ST_OP_010,                  mem_cs_ST_OP_010_x[0],                  mem_cs_ST_OP_010_x[1],                  mem_cs_ST_OP_010_x[2],                  mem_cs_ST_OP_010_x[3],                  num_pfs)
    `MUX_4(mem_cs_LD_OP_010_mux,                  1,             mem_cs_LD_OP_010,                  mem_cs_LD_OP_010_x[0],                  mem_cs_LD_OP_010_x[1],                  mem_cs_LD_OP_010_x[2],                  mem_cs_LD_OP_010_x[3],                  num_pfs)
    `MUX_4(exe_cs_ST_OP_010_mux,                  1,             exe_cs_ST_OP_010,                  exe_cs_ST_OP_010_x[0],                  exe_cs_ST_OP_010_x[1],                  exe_cs_ST_OP_010_x[2],                  exe_cs_ST_OP_010_x[3],                  num_pfs)
    `MUX_4(exe_cs_OP_TYPE_010_mux,                `EXE_OP_W,     exe_cs_OP_TYPE_010,                exe_cs_OP_TYPE_010_x[0],                exe_cs_OP_TYPE_010_x[1],                exe_cs_OP_TYPE_010_x[2],                exe_cs_OP_TYPE_010_x[3],                num_pfs)
    `MUX_4(exe_cs_alu_inputA_sel_010_mux,         `SRC_SEL_W,    exe_cs_alu_inputA_sel_010,         exe_cs_alu_inputA_sel_010_x[0],         exe_cs_alu_inputA_sel_010_x[1],         exe_cs_alu_inputA_sel_010_x[2],         exe_cs_alu_inputA_sel_010_x[3],         num_pfs)
    `MUX_4(exe_cs_alu_inputB_sel_010_mux,         `SRC_SEL_W,    exe_cs_alu_inputB_sel_010,         exe_cs_alu_inputB_sel_010_x[0],         exe_cs_alu_inputB_sel_010_x[1],         exe_cs_alu_inputB_sel_010_x[2],         exe_cs_alu_inputB_sel_010_x[3],         num_pfs)
    `MUX_4(exe_cs_branch_target_sel_010_mux,      `SRC_SEL_W,    exe_cs_branch_target_sel_010,      exe_cs_branch_target_sel_010_x[0],      exe_cs_branch_target_sel_010_x[1],      exe_cs_branch_target_sel_010_x[2],      exe_cs_branch_target_sel_010_x[3],      num_pfs)
    `MUX_4(exe_cs_shift_by_one_010_mux,           1,             exe_cs_shift_by_one_010,           exe_cs_shift_by_one_010_x[0],           exe_cs_shift_by_one_010_x[1],           exe_cs_shift_by_one_010_x[2],           exe_cs_shift_by_one_010_x[3],           num_pfs)
    `MUX_4(exe_cs_br_ucond_010_mux,               1,             exe_cs_br_ucond_010,               exe_cs_br_ucond_010_x[0],               exe_cs_br_ucond_010_x[1],               exe_cs_br_ucond_010_x[2],               exe_cs_br_ucond_010_x[3],               num_pfs)
    `MUX_4(exe_cs_relative_branch_010_mux,        1,             exe_cs_relative_branch_010,        exe_cs_relative_branch_010_x[0],        exe_cs_relative_branch_010_x[1],        exe_cs_relative_branch_010_x[2],        exe_cs_relative_branch_010_x[3],        num_pfs)
    `MUX_4(exe_cs_special_br_010_mux,             1,             exe_cs_special_br_010,             exe_cs_special_br_010_x[0],             exe_cs_special_br_010_x[1],             exe_cs_special_br_010_x[2],             exe_cs_special_br_010_x[3],             num_pfs)
    `MUX_4(exe_cs_is_far_010_mux,                 1,             exe_cs_is_far_010,                 exe_cs_is_far_010_x[0],                 exe_cs_is_far_010_x[1],                 exe_cs_is_far_010_x[2],                 exe_cs_is_far_010_x[3],                 num_pfs)
    `MUX_4(exe_cs_is_call_010_mux,                1,             exe_cs_is_call_010,                exe_cs_is_call_010_x[0],                exe_cs_is_call_010_x[1],                exe_cs_is_call_010_x[2],                exe_cs_is_call_010_x[3],                num_pfs)
    `MUX_4(exe_cs_second_flag_needed_010_mux,     1,             exe_cs_second_flag_needed_010,     exe_cs_second_flag_needed_010_x[0],     exe_cs_second_flag_needed_010_x[1],     exe_cs_second_flag_needed_010_x[2],     exe_cs_second_flag_needed_010_x[3],     num_pfs)
    `MUX_4(exe_cs_rep_no_zf_update_010_mux,       1,             exe_cs_rep_no_zf_update_010,       exe_cs_rep_no_zf_update_010_x[0],       exe_cs_rep_no_zf_update_010_x[1],       exe_cs_rep_no_zf_update_010_x[2],       exe_cs_rep_no_zf_update_010_x[3],       num_pfs)
    `MUX_4(wb_cs_ST_OP_010_mux,                   1,             wb_cs_ST_OP_010,                   wb_cs_ST_OP_010_x[0],                   wb_cs_ST_OP_010_x[1],                   wb_cs_ST_OP_010_x[2],                   wb_cs_ST_OP_010_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_DR_010_mux,                   1,             wb_cs_WB_DR_010,                   wb_cs_WB_DR_010_x[0],                   wb_cs_WB_DR_010_x[1],                   wb_cs_WB_DR_010_x[2],                   wb_cs_WB_DR_010_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_SR_010_mux,                   1,             wb_cs_WB_SR_010,                   wb_cs_WB_SR_010_x[0],                   wb_cs_WB_SR_010_x[1],                   wb_cs_WB_SR_010_x[2],                   wb_cs_WB_SR_010_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_EAX_010_mux,                  1,             wb_cs_WB_EAX_010,                  wb_cs_WB_EAX_010_x[0],                  wb_cs_WB_EAX_010_x[1],                  wb_cs_WB_EAX_010_x[2],                  wb_cs_WB_EAX_010_x[3],                  num_pfs)
    `MUX_4(decode_cs_REP_011_mux,                 1,             decode_cs_REP_011,                 decode_cs_REP_011_x[0],                 decode_cs_REP_011_x[1],                 decode_cs_REP_011_x[2],                 decode_cs_REP_011_x[3],                 num_pfs)
    `MUX_4(decode_cs_REP_CMP_011_mux,             1,             decode_cs_REP_CMP_011,             decode_cs_REP_CMP_011_x[0],             decode_cs_REP_CMP_011_x[1],             decode_cs_REP_CMP_011_x[2],             decode_cs_REP_CMP_011_x[3],             num_pfs)
    `MUX_4(decode_cs_HALT_011_mux,                1,             decode_cs_HALT_011,                decode_cs_HALT_011_x[0],                decode_cs_HALT_011_x[1],                decode_cs_HALT_011_x[2],                decode_cs_HALT_011_x[3],                num_pfs)
    `MUX_4(decode_cs_MODRM_NEEDED_011_mux,        1,             decode_cs_MODRM_NEEDED_011,        decode_cs_MODRM_NEEDED_011_x[0],        decode_cs_MODRM_NEEDED_011_x[1],        decode_cs_MODRM_NEEDED_011_x[2],        decode_cs_MODRM_NEEDED_011_x[3],        num_pfs)
    `MUX_4(decode_cs_RM_IS_DR_011_mux,            1,             decode_cs_RM_IS_DR_011,            decode_cs_RM_IS_DR_011_x[0],            decode_cs_RM_IS_DR_011_x[1],            decode_cs_RM_IS_DR_011_x[2],            decode_cs_RM_IS_DR_011_x[3],            num_pfs)
    `MUX_4(decode_cs_REG_IS_DR_011_mux,           1,             decode_cs_REG_IS_DR_011,           decode_cs_REG_IS_DR_011_x[0],           decode_cs_REG_IS_DR_011_x[1],           decode_cs_REG_IS_DR_011_x[2],           decode_cs_REG_IS_DR_011_x[3],           num_pfs)
    `MUX_4(decode_cs_REG_IS_SEGMENT_011_mux,      1,             decode_cs_REG_IS_SEGMENT_011,      decode_cs_REG_IS_SEGMENT_011_x[0],      decode_cs_REG_IS_SEGMENT_011_x[1],      decode_cs_REG_IS_SEGMENT_011_x[2],      decode_cs_REG_IS_SEGMENT_011_x[3],      num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_HIGH8_011_mux,  1,             decode_cs_HARDCODED_DR_HIGH8_011,  decode_cs_HARDCODED_DR_HIGH8_011_x[0],  decode_cs_HARDCODED_DR_HIGH8_011_x[1],  decode_cs_HARDCODED_DR_HIGH8_011_x[2],  decode_cs_HARDCODED_DR_HIGH8_011_x[3],  num_pfs)
    `MUX_4(decode_cs_MODRM_BUT_NO_SR_011_mux,     1,             decode_cs_MODRM_BUT_NO_SR_011,     decode_cs_MODRM_BUT_NO_SR_011_x[0],     decode_cs_MODRM_BUT_NO_SR_011_x[1],     decode_cs_MODRM_BUT_NO_SR_011_x[2],     decode_cs_MODRM_BUT_NO_SR_011_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_011_mux,        1,             decode_cs_HARDCODED_DR_011,        decode_cs_HARDCODED_DR_011_x[0],        decode_cs_HARDCODED_DR_011_x[1],        decode_cs_HARDCODED_DR_011_x[2],        decode_cs_HARDCODED_DR_011_x[3],        num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_ID_011_mux,     `REG_ID_W,     decode_cs_HARDCODED_DR_ID_011,     decode_cs_HARDCODED_DR_ID_011_x[0],     decode_cs_HARDCODED_DR_ID_011_x[1],     decode_cs_HARDCODED_DR_ID_011_x[2],     decode_cs_HARDCODED_DR_ID_011_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_011_mux,        1,             decode_cs_HARDCODED_SR_011,        decode_cs_HARDCODED_SR_011_x[0],        decode_cs_HARDCODED_SR_011_x[1],        decode_cs_HARDCODED_SR_011_x[2],        decode_cs_HARDCODED_SR_011_x[3],        num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_ID_011_mux,     `REG_ID_W,     decode_cs_HARDCODED_SR_ID_011,     decode_cs_HARDCODED_SR_ID_011_x[0],     decode_cs_HARDCODED_SR_ID_011_x[1],     decode_cs_HARDCODED_SR_ID_011_x[2],     decode_cs_HARDCODED_SR_ID_011_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_RD_011_mux,     1,             decode_cs_HARDCODED_DR_RD_011,     decode_cs_HARDCODED_DR_RD_011_x[0],     decode_cs_HARDCODED_DR_RD_011_x[1],     decode_cs_HARDCODED_DR_RD_011_x[2],     decode_cs_HARDCODED_DR_RD_011_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_WR_011_mux,     1,             decode_cs_HARDCODED_DR_WR_011,     decode_cs_HARDCODED_DR_WR_011_x[0],     decode_cs_HARDCODED_DR_WR_011_x[1],     decode_cs_HARDCODED_DR_WR_011_x[2],     decode_cs_HARDCODED_DR_WR_011_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_RD_011_mux,     1,             decode_cs_HARDCODED_SR_RD_011,     decode_cs_HARDCODED_SR_RD_011_x[0],     decode_cs_HARDCODED_SR_RD_011_x[1],     decode_cs_HARDCODED_SR_RD_011_x[2],     decode_cs_HARDCODED_SR_RD_011_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_WR_011_mux,     1,             decode_cs_HARDCODED_SR_WR_011,     decode_cs_HARDCODED_SR_WR_011_x[0],     decode_cs_HARDCODED_SR_WR_011_x[1],     decode_cs_HARDCODED_SR_WR_011_x[2],     decode_cs_HARDCODED_SR_WR_011_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_LD_OP_011_mux,     1,             decode_cs_HARDCODED_LD_OP_011,     decode_cs_HARDCODED_LD_OP_011_x[0],     decode_cs_HARDCODED_LD_OP_011_x[1],     decode_cs_HARDCODED_LD_OP_011_x[2],     decode_cs_HARDCODED_LD_OP_011_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_ST_OP_011_mux,     1,             decode_cs_HARDCODED_ST_OP_011,     decode_cs_HARDCODED_ST_OP_011_x[0],     decode_cs_HARDCODED_ST_OP_011_x[1],     decode_cs_HARDCODED_ST_OP_011_x[2],     decode_cs_HARDCODED_ST_OP_011_x[3],     num_pfs)
    `MUX_4(decode_cs_LD_OP_CANCEL_011_mux,        1,             decode_cs_LD_OP_CANCEL_011,        decode_cs_LD_OP_CANCEL_011_x[0],        decode_cs_LD_OP_CANCEL_011_x[1],        decode_cs_LD_OP_CANCEL_011_x[2],        decode_cs_LD_OP_CANCEL_011_x[3],        num_pfs)
    `MUX_4(decode_cs_ST_OP_CANCEL_011_mux,        1,             decode_cs_ST_OP_CANCEL_011,        decode_cs_ST_OP_CANCEL_011_x[0],        decode_cs_ST_OP_CANCEL_011_x[1],        decode_cs_ST_OP_CANCEL_011_x[2],        decode_cs_ST_OP_CANCEL_011_x[3],        num_pfs)
    `MUX_4(decode_cs_OP_IN_MODRM_011_mux,         1,             decode_cs_OP_IN_MODRM_011,         decode_cs_OP_IN_MODRM_011_x[0],         decode_cs_OP_IN_MODRM_011_x[1],         decode_cs_OP_IN_MODRM_011_x[2],         decode_cs_OP_IN_MODRM_011_x[3],         num_pfs)
    `MUX_4(decode_cs_DATA_SIZE_011_mux,           2,             decode_cs_DATA_SIZE_011,           decode_cs_DATA_SIZE_011_x[0],           decode_cs_DATA_SIZE_011_x[1],           decode_cs_DATA_SIZE_011_x[2],           decode_cs_DATA_SIZE_011_x[3],           num_pfs)
    `MUX_4(rr_cs_ST_SEL_011_mux,                  1,             rr_cs_ST_SEL_011,                  rr_cs_ST_SEL_011_x[0],                  rr_cs_ST_SEL_011_x[1],                  rr_cs_ST_SEL_011_x[2],                  rr_cs_ST_SEL_011_x[3],                  num_pfs)
    `MUX_4(rr_cs_MODRM_NEEDED_011_mux,            1,             rr_cs_MODRM_NEEDED_011,            rr_cs_MODRM_NEEDED_011_x[0],            rr_cs_MODRM_NEEDED_011_x[1],            rr_cs_MODRM_NEEDED_011_x[2],            rr_cs_MODRM_NEEDED_011_x[3],            num_pfs)
    `MUX_4(rr_cs_RM_IS_DR_011_mux,                1,             rr_cs_RM_IS_DR_011,                rr_cs_RM_IS_DR_011_x[0],                rr_cs_RM_IS_DR_011_x[1],                rr_cs_RM_IS_DR_011_x[2],                rr_cs_RM_IS_DR_011_x[3],                num_pfs)
    `MUX_4(rr_cs_SWITCH_LD_ADDY_011_mux,          1,             rr_cs_SWITCH_LD_ADDY_011,          rr_cs_SWITCH_LD_ADDY_011_x[0],          rr_cs_SWITCH_LD_ADDY_011_x[1],          rr_cs_SWITCH_LD_ADDY_011_x[2],          rr_cs_SWITCH_LD_ADDY_011_x[3],          num_pfs)
    `MUX_4(rr_cs_LD_OP_011_mux,                   1,             rr_cs_LD_OP_011,                   rr_cs_LD_OP_011_x[0],                   rr_cs_LD_OP_011_x[1],                   rr_cs_LD_OP_011_x[2],                   rr_cs_LD_OP_011_x[3],                   num_pfs)
    `MUX_4(rr_cs_ST_OP_011_mux,                   1,             rr_cs_ST_OP_011,                   rr_cs_ST_OP_011_x[0],                   rr_cs_ST_OP_011_x[1],                   rr_cs_ST_OP_011_x[2],                   rr_cs_ST_OP_011_x[3],                   num_pfs)
    `MUX_4(rr_cs_dr_id_011_mux,                   `REG_ID_W,     rr_cs_dr_id_011,                   rr_cs_dr_id_011_x[0],                   rr_cs_dr_id_011_x[1],                   rr_cs_dr_id_011_x[2],                   rr_cs_dr_id_011_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_id_011_mux,                   `REG_ID_W,     rr_cs_sr_id_011,                   rr_cs_sr_id_011_x[0],                   rr_cs_sr_id_011_x[1],                   rr_cs_sr_id_011_x[2],                   rr_cs_sr_id_011_x[3],                   num_pfs)
    `MUX_4(rr_cs_dr_rd_011_mux,                   1,             rr_cs_dr_rd_011,                   rr_cs_dr_rd_011_x[0],                   rr_cs_dr_rd_011_x[1],                   rr_cs_dr_rd_011_x[2],                   rr_cs_dr_rd_011_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_rd_011_mux,                   1,             rr_cs_sr_rd_011,                   rr_cs_sr_rd_011_x[0],                   rr_cs_sr_rd_011_x[1],                   rr_cs_sr_rd_011_x[2],                   rr_cs_sr_rd_011_x[3],                   num_pfs)
    `MUX_4(rr_cs_eax_rd_011_mux,                  1,             rr_cs_eax_rd_011,                  rr_cs_eax_rd_011_x[0],                  rr_cs_eax_rd_011_x[1],                  rr_cs_eax_rd_011_x[2],                  rr_cs_eax_rd_011_x[3],                  num_pfs)
    `MUX_4(rr_cs_dr_wr_011_mux,                   1,             rr_cs_dr_wr_011,                   rr_cs_dr_wr_011_x[0],                   rr_cs_dr_wr_011_x[1],                   rr_cs_dr_wr_011_x[2],                   rr_cs_dr_wr_011_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_wr_011_mux,                   1,             rr_cs_sr_wr_011,                   rr_cs_sr_wr_011_x[0],                   rr_cs_sr_wr_011_x[1],                   rr_cs_sr_wr_011_x[2],                   rr_cs_sr_wr_011_x[3],                   num_pfs)
    `MUX_4(rr_cs_eax_wr_011_mux,                  1,             rr_cs_eax_wr_011,                  rr_cs_eax_wr_011_x[0],                  rr_cs_eax_wr_011_x[1],                  rr_cs_eax_wr_011_x[2],                  rr_cs_eax_wr_011_x[3],                  num_pfs)
    `MUX_4(rr_cs_MOVS_OP_011_mux,                 1,             rr_cs_MOVS_OP_011,                 rr_cs_MOVS_OP_011_x[0],                 rr_cs_MOVS_OP_011_x[1],                 rr_cs_MOVS_OP_011_x[2],                 rr_cs_MOVS_OP_011_x[3],                 num_pfs)
    `MUX_4(rr_cs_datasize_011_mux,                2,             rr_cs_datasize_011,                rr_cs_datasize_011_x[0],                rr_cs_datasize_011_x[1],                rr_cs_datasize_011_x[2],                rr_cs_datasize_011_x[3],                num_pfs)
    `MUX_4(rr_cs_will_mod_zf_011_mux,             1,             rr_cs_will_mod_zf_011,             rr_cs_will_mod_zf_011_x[0],             rr_cs_will_mod_zf_011_x[1],             rr_cs_will_mod_zf_011_x[2],             rr_cs_will_mod_zf_011_x[3],             num_pfs)
    `MUX_4(rr_cs_seg_1_valid_011_mux,             1,             rr_cs_seg_1_valid_011,             rr_cs_seg_1_valid_011_x[0],             rr_cs_seg_1_valid_011_x[1],             rr_cs_seg_1_valid_011_x[2],             rr_cs_seg_1_valid_011_x[3],             num_pfs)
    `MUX_4(rr_cs_seg_0_id_011_mux,                `REG_ID_W,     rr_cs_seg_0_id_011,                rr_cs_seg_0_id_011_x[0],                rr_cs_seg_0_id_011_x[1],                rr_cs_seg_0_id_011_x[2],                rr_cs_seg_0_id_011_x[3],                num_pfs)
    `MUX_4(rr_cs_seg_1_id_011_mux,                `REG_ID_W,     rr_cs_seg_1_id_011,                rr_cs_seg_1_id_011_x[0],                rr_cs_seg_1_id_011_x[1],                rr_cs_seg_1_id_011_x[2],                rr_cs_seg_1_id_011_x[3],                num_pfs)
    `MUX_4(rr_cs_special_modrm_bs_011_mux,        1,             rr_cs_special_modrm_bs_011,        rr_cs_special_modrm_bs_011_x[0],        rr_cs_special_modrm_bs_011_x[1],        rr_cs_special_modrm_bs_011_x[2],        rr_cs_special_modrm_bs_011_x[3],        num_pfs)
    `MUX_4(rr_cs_special_br_011_mux,              1,             rr_cs_special_br_011,              rr_cs_special_br_011_x[0],              rr_cs_special_br_011_x[1],              rr_cs_special_br_011_x[2],              rr_cs_special_br_011_x[3],              num_pfs)
    `MUX_4(dc_cs_LD_OP_011_mux,                   1,             dc_cs_LD_OP_011,                   dc_cs_LD_OP_011_x[0],                   dc_cs_LD_OP_011_x[1],                   dc_cs_LD_OP_011_x[2],                   dc_cs_LD_OP_011_x[3],                   num_pfs)
    `MUX_4(dc_cs_ST_OP_011_mux,                   1,             dc_cs_ST_OP_011,                   dc_cs_ST_OP_011_x[0],                   dc_cs_ST_OP_011_x[1],                   dc_cs_ST_OP_011_x[2],                   dc_cs_ST_OP_011_x[3],                   num_pfs)
    `MUX_4(dc_cs_dr_upper8_011_mux,               1,             dc_cs_dr_upper8_011,               dc_cs_dr_upper8_011_x[0],               dc_cs_dr_upper8_011_x[1],               dc_cs_dr_upper8_011_x[2],               dc_cs_dr_upper8_011_x[3],               num_pfs)
    `MUX_4(dc_cs_sr_upper8_011_mux,               1,             dc_cs_sr_upper8_011,               dc_cs_sr_upper8_011_x[0],               dc_cs_sr_upper8_011_x[1],               dc_cs_sr_upper8_011_x[2],               dc_cs_sr_upper8_011_x[3],               num_pfs)
    `MUX_4(dc_cs_datasize_011_mux,                2,             dc_cs_datasize_011,                dc_cs_datasize_011_x[0],                dc_cs_datasize_011_x[1],                dc_cs_datasize_011_x[2],                dc_cs_datasize_011_x[3],                num_pfs)
    `MUX_4(mem_cs_ST_OP_011_mux,                  1,             mem_cs_ST_OP_011,                  mem_cs_ST_OP_011_x[0],                  mem_cs_ST_OP_011_x[1],                  mem_cs_ST_OP_011_x[2],                  mem_cs_ST_OP_011_x[3],                  num_pfs)
    `MUX_4(mem_cs_LD_OP_011_mux,                  1,             mem_cs_LD_OP_011,                  mem_cs_LD_OP_011_x[0],                  mem_cs_LD_OP_011_x[1],                  mem_cs_LD_OP_011_x[2],                  mem_cs_LD_OP_011_x[3],                  num_pfs)
    `MUX_4(exe_cs_ST_OP_011_mux,                  1,             exe_cs_ST_OP_011,                  exe_cs_ST_OP_011_x[0],                  exe_cs_ST_OP_011_x[1],                  exe_cs_ST_OP_011_x[2],                  exe_cs_ST_OP_011_x[3],                  num_pfs)
    `MUX_4(exe_cs_OP_TYPE_011_mux,                `EXE_OP_W,     exe_cs_OP_TYPE_011,                exe_cs_OP_TYPE_011_x[0],                exe_cs_OP_TYPE_011_x[1],                exe_cs_OP_TYPE_011_x[2],                exe_cs_OP_TYPE_011_x[3],                num_pfs)
    `MUX_4(exe_cs_alu_inputA_sel_011_mux,         `SRC_SEL_W,    exe_cs_alu_inputA_sel_011,         exe_cs_alu_inputA_sel_011_x[0],         exe_cs_alu_inputA_sel_011_x[1],         exe_cs_alu_inputA_sel_011_x[2],         exe_cs_alu_inputA_sel_011_x[3],         num_pfs)
    `MUX_4(exe_cs_alu_inputB_sel_011_mux,         `SRC_SEL_W,    exe_cs_alu_inputB_sel_011,         exe_cs_alu_inputB_sel_011_x[0],         exe_cs_alu_inputB_sel_011_x[1],         exe_cs_alu_inputB_sel_011_x[2],         exe_cs_alu_inputB_sel_011_x[3],         num_pfs)
    `MUX_4(exe_cs_branch_target_sel_011_mux,      `SRC_SEL_W,    exe_cs_branch_target_sel_011,      exe_cs_branch_target_sel_011_x[0],      exe_cs_branch_target_sel_011_x[1],      exe_cs_branch_target_sel_011_x[2],      exe_cs_branch_target_sel_011_x[3],      num_pfs)
    `MUX_4(exe_cs_shift_by_one_011_mux,           1,             exe_cs_shift_by_one_011,           exe_cs_shift_by_one_011_x[0],           exe_cs_shift_by_one_011_x[1],           exe_cs_shift_by_one_011_x[2],           exe_cs_shift_by_one_011_x[3],           num_pfs)
    `MUX_4(exe_cs_br_ucond_011_mux,               1,             exe_cs_br_ucond_011,               exe_cs_br_ucond_011_x[0],               exe_cs_br_ucond_011_x[1],               exe_cs_br_ucond_011_x[2],               exe_cs_br_ucond_011_x[3],               num_pfs)
    `MUX_4(exe_cs_relative_branch_011_mux,        1,             exe_cs_relative_branch_011,        exe_cs_relative_branch_011_x[0],        exe_cs_relative_branch_011_x[1],        exe_cs_relative_branch_011_x[2],        exe_cs_relative_branch_011_x[3],        num_pfs)
    `MUX_4(exe_cs_special_br_011_mux,             1,             exe_cs_special_br_011,             exe_cs_special_br_011_x[0],             exe_cs_special_br_011_x[1],             exe_cs_special_br_011_x[2],             exe_cs_special_br_011_x[3],             num_pfs)
    `MUX_4(exe_cs_is_far_011_mux,                 1,             exe_cs_is_far_011,                 exe_cs_is_far_011_x[0],                 exe_cs_is_far_011_x[1],                 exe_cs_is_far_011_x[2],                 exe_cs_is_far_011_x[3],                 num_pfs)
    `MUX_4(exe_cs_is_call_011_mux,                1,             exe_cs_is_call_011,                exe_cs_is_call_011_x[0],                exe_cs_is_call_011_x[1],                exe_cs_is_call_011_x[2],                exe_cs_is_call_011_x[3],                num_pfs)
    `MUX_4(exe_cs_second_flag_needed_011_mux,     1,             exe_cs_second_flag_needed_011,     exe_cs_second_flag_needed_011_x[0],     exe_cs_second_flag_needed_011_x[1],     exe_cs_second_flag_needed_011_x[2],     exe_cs_second_flag_needed_011_x[3],     num_pfs)
    `MUX_4(exe_cs_rep_no_zf_update_011_mux,       1,             exe_cs_rep_no_zf_update_011,       exe_cs_rep_no_zf_update_011_x[0],       exe_cs_rep_no_zf_update_011_x[1],       exe_cs_rep_no_zf_update_011_x[2],       exe_cs_rep_no_zf_update_011_x[3],       num_pfs)
    `MUX_4(wb_cs_ST_OP_011_mux,                   1,             wb_cs_ST_OP_011,                   wb_cs_ST_OP_011_x[0],                   wb_cs_ST_OP_011_x[1],                   wb_cs_ST_OP_011_x[2],                   wb_cs_ST_OP_011_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_DR_011_mux,                   1,             wb_cs_WB_DR_011,                   wb_cs_WB_DR_011_x[0],                   wb_cs_WB_DR_011_x[1],                   wb_cs_WB_DR_011_x[2],                   wb_cs_WB_DR_011_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_SR_011_mux,                   1,             wb_cs_WB_SR_011,                   wb_cs_WB_SR_011_x[0],                   wb_cs_WB_SR_011_x[1],                   wb_cs_WB_SR_011_x[2],                   wb_cs_WB_SR_011_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_EAX_011_mux,                  1,             wb_cs_WB_EAX_011,                  wb_cs_WB_EAX_011_x[0],                  wb_cs_WB_EAX_011_x[1],                  wb_cs_WB_EAX_011_x[2],                  wb_cs_WB_EAX_011_x[3],                  num_pfs)
    `MUX_4(decode_cs_REP_100_mux,                 1,             decode_cs_REP_100,                 decode_cs_REP_100_x[0],                 decode_cs_REP_100_x[1],                 decode_cs_REP_100_x[2],                 decode_cs_REP_100_x[3],                 num_pfs)
    `MUX_4(decode_cs_REP_CMP_100_mux,             1,             decode_cs_REP_CMP_100,             decode_cs_REP_CMP_100_x[0],             decode_cs_REP_CMP_100_x[1],             decode_cs_REP_CMP_100_x[2],             decode_cs_REP_CMP_100_x[3],             num_pfs)
    `MUX_4(decode_cs_HALT_100_mux,                1,             decode_cs_HALT_100,                decode_cs_HALT_100_x[0],                decode_cs_HALT_100_x[1],                decode_cs_HALT_100_x[2],                decode_cs_HALT_100_x[3],                num_pfs)
    `MUX_4(decode_cs_MODRM_NEEDED_100_mux,        1,             decode_cs_MODRM_NEEDED_100,        decode_cs_MODRM_NEEDED_100_x[0],        decode_cs_MODRM_NEEDED_100_x[1],        decode_cs_MODRM_NEEDED_100_x[2],        decode_cs_MODRM_NEEDED_100_x[3],        num_pfs)
    `MUX_4(decode_cs_RM_IS_DR_100_mux,            1,             decode_cs_RM_IS_DR_100,            decode_cs_RM_IS_DR_100_x[0],            decode_cs_RM_IS_DR_100_x[1],            decode_cs_RM_IS_DR_100_x[2],            decode_cs_RM_IS_DR_100_x[3],            num_pfs)
    `MUX_4(decode_cs_REG_IS_DR_100_mux,           1,             decode_cs_REG_IS_DR_100,           decode_cs_REG_IS_DR_100_x[0],           decode_cs_REG_IS_DR_100_x[1],           decode_cs_REG_IS_DR_100_x[2],           decode_cs_REG_IS_DR_100_x[3],           num_pfs)
    `MUX_4(decode_cs_REG_IS_SEGMENT_100_mux,      1,             decode_cs_REG_IS_SEGMENT_100,      decode_cs_REG_IS_SEGMENT_100_x[0],      decode_cs_REG_IS_SEGMENT_100_x[1],      decode_cs_REG_IS_SEGMENT_100_x[2],      decode_cs_REG_IS_SEGMENT_100_x[3],      num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_HIGH8_100_mux,  1,             decode_cs_HARDCODED_DR_HIGH8_100,  decode_cs_HARDCODED_DR_HIGH8_100_x[0],  decode_cs_HARDCODED_DR_HIGH8_100_x[1],  decode_cs_HARDCODED_DR_HIGH8_100_x[2],  decode_cs_HARDCODED_DR_HIGH8_100_x[3],  num_pfs)
    `MUX_4(decode_cs_MODRM_BUT_NO_SR_100_mux,     1,             decode_cs_MODRM_BUT_NO_SR_100,     decode_cs_MODRM_BUT_NO_SR_100_x[0],     decode_cs_MODRM_BUT_NO_SR_100_x[1],     decode_cs_MODRM_BUT_NO_SR_100_x[2],     decode_cs_MODRM_BUT_NO_SR_100_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_100_mux,        1,             decode_cs_HARDCODED_DR_100,        decode_cs_HARDCODED_DR_100_x[0],        decode_cs_HARDCODED_DR_100_x[1],        decode_cs_HARDCODED_DR_100_x[2],        decode_cs_HARDCODED_DR_100_x[3],        num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_ID_100_mux,     `REG_ID_W,     decode_cs_HARDCODED_DR_ID_100,     decode_cs_HARDCODED_DR_ID_100_x[0],     decode_cs_HARDCODED_DR_ID_100_x[1],     decode_cs_HARDCODED_DR_ID_100_x[2],     decode_cs_HARDCODED_DR_ID_100_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_100_mux,        1,             decode_cs_HARDCODED_SR_100,        decode_cs_HARDCODED_SR_100_x[0],        decode_cs_HARDCODED_SR_100_x[1],        decode_cs_HARDCODED_SR_100_x[2],        decode_cs_HARDCODED_SR_100_x[3],        num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_ID_100_mux,     `REG_ID_W,     decode_cs_HARDCODED_SR_ID_100,     decode_cs_HARDCODED_SR_ID_100_x[0],     decode_cs_HARDCODED_SR_ID_100_x[1],     decode_cs_HARDCODED_SR_ID_100_x[2],     decode_cs_HARDCODED_SR_ID_100_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_RD_100_mux,     1,             decode_cs_HARDCODED_DR_RD_100,     decode_cs_HARDCODED_DR_RD_100_x[0],     decode_cs_HARDCODED_DR_RD_100_x[1],     decode_cs_HARDCODED_DR_RD_100_x[2],     decode_cs_HARDCODED_DR_RD_100_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_WR_100_mux,     1,             decode_cs_HARDCODED_DR_WR_100,     decode_cs_HARDCODED_DR_WR_100_x[0],     decode_cs_HARDCODED_DR_WR_100_x[1],     decode_cs_HARDCODED_DR_WR_100_x[2],     decode_cs_HARDCODED_DR_WR_100_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_RD_100_mux,     1,             decode_cs_HARDCODED_SR_RD_100,     decode_cs_HARDCODED_SR_RD_100_x[0],     decode_cs_HARDCODED_SR_RD_100_x[1],     decode_cs_HARDCODED_SR_RD_100_x[2],     decode_cs_HARDCODED_SR_RD_100_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_WR_100_mux,     1,             decode_cs_HARDCODED_SR_WR_100,     decode_cs_HARDCODED_SR_WR_100_x[0],     decode_cs_HARDCODED_SR_WR_100_x[1],     decode_cs_HARDCODED_SR_WR_100_x[2],     decode_cs_HARDCODED_SR_WR_100_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_LD_OP_100_mux,     1,             decode_cs_HARDCODED_LD_OP_100,     decode_cs_HARDCODED_LD_OP_100_x[0],     decode_cs_HARDCODED_LD_OP_100_x[1],     decode_cs_HARDCODED_LD_OP_100_x[2],     decode_cs_HARDCODED_LD_OP_100_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_ST_OP_100_mux,     1,             decode_cs_HARDCODED_ST_OP_100,     decode_cs_HARDCODED_ST_OP_100_x[0],     decode_cs_HARDCODED_ST_OP_100_x[1],     decode_cs_HARDCODED_ST_OP_100_x[2],     decode_cs_HARDCODED_ST_OP_100_x[3],     num_pfs)
    `MUX_4(decode_cs_LD_OP_CANCEL_100_mux,        1,             decode_cs_LD_OP_CANCEL_100,        decode_cs_LD_OP_CANCEL_100_x[0],        decode_cs_LD_OP_CANCEL_100_x[1],        decode_cs_LD_OP_CANCEL_100_x[2],        decode_cs_LD_OP_CANCEL_100_x[3],        num_pfs)
    `MUX_4(decode_cs_ST_OP_CANCEL_100_mux,        1,             decode_cs_ST_OP_CANCEL_100,        decode_cs_ST_OP_CANCEL_100_x[0],        decode_cs_ST_OP_CANCEL_100_x[1],        decode_cs_ST_OP_CANCEL_100_x[2],        decode_cs_ST_OP_CANCEL_100_x[3],        num_pfs)
    `MUX_4(decode_cs_OP_IN_MODRM_100_mux,         1,             decode_cs_OP_IN_MODRM_100,         decode_cs_OP_IN_MODRM_100_x[0],         decode_cs_OP_IN_MODRM_100_x[1],         decode_cs_OP_IN_MODRM_100_x[2],         decode_cs_OP_IN_MODRM_100_x[3],         num_pfs)
    `MUX_4(decode_cs_DATA_SIZE_100_mux,           2,             decode_cs_DATA_SIZE_100,           decode_cs_DATA_SIZE_100_x[0],           decode_cs_DATA_SIZE_100_x[1],           decode_cs_DATA_SIZE_100_x[2],           decode_cs_DATA_SIZE_100_x[3],           num_pfs)
    `MUX_4(rr_cs_ST_SEL_100_mux,                  1,             rr_cs_ST_SEL_100,                  rr_cs_ST_SEL_100_x[0],                  rr_cs_ST_SEL_100_x[1],                  rr_cs_ST_SEL_100_x[2],                  rr_cs_ST_SEL_100_x[3],                  num_pfs)
    `MUX_4(rr_cs_MODRM_NEEDED_100_mux,            1,             rr_cs_MODRM_NEEDED_100,            rr_cs_MODRM_NEEDED_100_x[0],            rr_cs_MODRM_NEEDED_100_x[1],            rr_cs_MODRM_NEEDED_100_x[2],            rr_cs_MODRM_NEEDED_100_x[3],            num_pfs)
    `MUX_4(rr_cs_RM_IS_DR_100_mux,                1,             rr_cs_RM_IS_DR_100,                rr_cs_RM_IS_DR_100_x[0],                rr_cs_RM_IS_DR_100_x[1],                rr_cs_RM_IS_DR_100_x[2],                rr_cs_RM_IS_DR_100_x[3],                num_pfs)
    `MUX_4(rr_cs_SWITCH_LD_ADDY_100_mux,          1,             rr_cs_SWITCH_LD_ADDY_100,          rr_cs_SWITCH_LD_ADDY_100_x[0],          rr_cs_SWITCH_LD_ADDY_100_x[1],          rr_cs_SWITCH_LD_ADDY_100_x[2],          rr_cs_SWITCH_LD_ADDY_100_x[3],          num_pfs)
    `MUX_4(rr_cs_LD_OP_100_mux,                   1,             rr_cs_LD_OP_100,                   rr_cs_LD_OP_100_x[0],                   rr_cs_LD_OP_100_x[1],                   rr_cs_LD_OP_100_x[2],                   rr_cs_LD_OP_100_x[3],                   num_pfs)
    `MUX_4(rr_cs_ST_OP_100_mux,                   1,             rr_cs_ST_OP_100,                   rr_cs_ST_OP_100_x[0],                   rr_cs_ST_OP_100_x[1],                   rr_cs_ST_OP_100_x[2],                   rr_cs_ST_OP_100_x[3],                   num_pfs)
    `MUX_4(rr_cs_dr_id_100_mux,                   `REG_ID_W,     rr_cs_dr_id_100,                   rr_cs_dr_id_100_x[0],                   rr_cs_dr_id_100_x[1],                   rr_cs_dr_id_100_x[2],                   rr_cs_dr_id_100_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_id_100_mux,                   `REG_ID_W,     rr_cs_sr_id_100,                   rr_cs_sr_id_100_x[0],                   rr_cs_sr_id_100_x[1],                   rr_cs_sr_id_100_x[2],                   rr_cs_sr_id_100_x[3],                   num_pfs)
    `MUX_4(rr_cs_dr_rd_100_mux,                   1,             rr_cs_dr_rd_100,                   rr_cs_dr_rd_100_x[0],                   rr_cs_dr_rd_100_x[1],                   rr_cs_dr_rd_100_x[2],                   rr_cs_dr_rd_100_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_rd_100_mux,                   1,             rr_cs_sr_rd_100,                   rr_cs_sr_rd_100_x[0],                   rr_cs_sr_rd_100_x[1],                   rr_cs_sr_rd_100_x[2],                   rr_cs_sr_rd_100_x[3],                   num_pfs)
    `MUX_4(rr_cs_eax_rd_100_mux,                  1,             rr_cs_eax_rd_100,                  rr_cs_eax_rd_100_x[0],                  rr_cs_eax_rd_100_x[1],                  rr_cs_eax_rd_100_x[2],                  rr_cs_eax_rd_100_x[3],                  num_pfs)
    `MUX_4(rr_cs_dr_wr_100_mux,                   1,             rr_cs_dr_wr_100,                   rr_cs_dr_wr_100_x[0],                   rr_cs_dr_wr_100_x[1],                   rr_cs_dr_wr_100_x[2],                   rr_cs_dr_wr_100_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_wr_100_mux,                   1,             rr_cs_sr_wr_100,                   rr_cs_sr_wr_100_x[0],                   rr_cs_sr_wr_100_x[1],                   rr_cs_sr_wr_100_x[2],                   rr_cs_sr_wr_100_x[3],                   num_pfs)
    `MUX_4(rr_cs_eax_wr_100_mux,                  1,             rr_cs_eax_wr_100,                  rr_cs_eax_wr_100_x[0],                  rr_cs_eax_wr_100_x[1],                  rr_cs_eax_wr_100_x[2],                  rr_cs_eax_wr_100_x[3],                  num_pfs)
    `MUX_4(rr_cs_MOVS_OP_100_mux,                 1,             rr_cs_MOVS_OP_100,                 rr_cs_MOVS_OP_100_x[0],                 rr_cs_MOVS_OP_100_x[1],                 rr_cs_MOVS_OP_100_x[2],                 rr_cs_MOVS_OP_100_x[3],                 num_pfs)
    `MUX_4(rr_cs_datasize_100_mux,                2,             rr_cs_datasize_100,                rr_cs_datasize_100_x[0],                rr_cs_datasize_100_x[1],                rr_cs_datasize_100_x[2],                rr_cs_datasize_100_x[3],                num_pfs)
    `MUX_4(rr_cs_will_mod_zf_100_mux,             1,             rr_cs_will_mod_zf_100,             rr_cs_will_mod_zf_100_x[0],             rr_cs_will_mod_zf_100_x[1],             rr_cs_will_mod_zf_100_x[2],             rr_cs_will_mod_zf_100_x[3],             num_pfs)
    `MUX_4(rr_cs_seg_1_valid_100_mux,             1,             rr_cs_seg_1_valid_100,             rr_cs_seg_1_valid_100_x[0],             rr_cs_seg_1_valid_100_x[1],             rr_cs_seg_1_valid_100_x[2],             rr_cs_seg_1_valid_100_x[3],             num_pfs)
    `MUX_4(rr_cs_seg_0_id_100_mux,                `REG_ID_W,     rr_cs_seg_0_id_100,                rr_cs_seg_0_id_100_x[0],                rr_cs_seg_0_id_100_x[1],                rr_cs_seg_0_id_100_x[2],                rr_cs_seg_0_id_100_x[3],                num_pfs)
    `MUX_4(rr_cs_seg_1_id_100_mux,                `REG_ID_W,     rr_cs_seg_1_id_100,                rr_cs_seg_1_id_100_x[0],                rr_cs_seg_1_id_100_x[1],                rr_cs_seg_1_id_100_x[2],                rr_cs_seg_1_id_100_x[3],                num_pfs)
    `MUX_4(rr_cs_special_modrm_bs_100_mux,        1,             rr_cs_special_modrm_bs_100,        rr_cs_special_modrm_bs_100_x[0],        rr_cs_special_modrm_bs_100_x[1],        rr_cs_special_modrm_bs_100_x[2],        rr_cs_special_modrm_bs_100_x[3],        num_pfs)
    `MUX_4(rr_cs_special_br_100_mux,              1,             rr_cs_special_br_100,              rr_cs_special_br_100_x[0],              rr_cs_special_br_100_x[1],              rr_cs_special_br_100_x[2],              rr_cs_special_br_100_x[3],              num_pfs)
    `MUX_4(dc_cs_LD_OP_100_mux,                   1,             dc_cs_LD_OP_100,                   dc_cs_LD_OP_100_x[0],                   dc_cs_LD_OP_100_x[1],                   dc_cs_LD_OP_100_x[2],                   dc_cs_LD_OP_100_x[3],                   num_pfs)
    `MUX_4(dc_cs_ST_OP_100_mux,                   1,             dc_cs_ST_OP_100,                   dc_cs_ST_OP_100_x[0],                   dc_cs_ST_OP_100_x[1],                   dc_cs_ST_OP_100_x[2],                   dc_cs_ST_OP_100_x[3],                   num_pfs)
    `MUX_4(dc_cs_dr_upper8_100_mux,               1,             dc_cs_dr_upper8_100,               dc_cs_dr_upper8_100_x[0],               dc_cs_dr_upper8_100_x[1],               dc_cs_dr_upper8_100_x[2],               dc_cs_dr_upper8_100_x[3],               num_pfs)
    `MUX_4(dc_cs_sr_upper8_100_mux,               1,             dc_cs_sr_upper8_100,               dc_cs_sr_upper8_100_x[0],               dc_cs_sr_upper8_100_x[1],               dc_cs_sr_upper8_100_x[2],               dc_cs_sr_upper8_100_x[3],               num_pfs)
    `MUX_4(dc_cs_datasize_100_mux,                2,             dc_cs_datasize_100,                dc_cs_datasize_100_x[0],                dc_cs_datasize_100_x[1],                dc_cs_datasize_100_x[2],                dc_cs_datasize_100_x[3],                num_pfs)
    `MUX_4(mem_cs_ST_OP_100_mux,                  1,             mem_cs_ST_OP_100,                  mem_cs_ST_OP_100_x[0],                  mem_cs_ST_OP_100_x[1],                  mem_cs_ST_OP_100_x[2],                  mem_cs_ST_OP_100_x[3],                  num_pfs)
    `MUX_4(mem_cs_LD_OP_100_mux,                  1,             mem_cs_LD_OP_100,                  mem_cs_LD_OP_100_x[0],                  mem_cs_LD_OP_100_x[1],                  mem_cs_LD_OP_100_x[2],                  mem_cs_LD_OP_100_x[3],                  num_pfs)
    `MUX_4(exe_cs_ST_OP_100_mux,                  1,             exe_cs_ST_OP_100,                  exe_cs_ST_OP_100_x[0],                  exe_cs_ST_OP_100_x[1],                  exe_cs_ST_OP_100_x[2],                  exe_cs_ST_OP_100_x[3],                  num_pfs)
    `MUX_4(exe_cs_OP_TYPE_100_mux,                `EXE_OP_W,     exe_cs_OP_TYPE_100,                exe_cs_OP_TYPE_100_x[0],                exe_cs_OP_TYPE_100_x[1],                exe_cs_OP_TYPE_100_x[2],                exe_cs_OP_TYPE_100_x[3],                num_pfs)
    `MUX_4(exe_cs_alu_inputA_sel_100_mux,         `SRC_SEL_W,    exe_cs_alu_inputA_sel_100,         exe_cs_alu_inputA_sel_100_x[0],         exe_cs_alu_inputA_sel_100_x[1],         exe_cs_alu_inputA_sel_100_x[2],         exe_cs_alu_inputA_sel_100_x[3],         num_pfs)
    `MUX_4(exe_cs_alu_inputB_sel_100_mux,         `SRC_SEL_W,    exe_cs_alu_inputB_sel_100,         exe_cs_alu_inputB_sel_100_x[0],         exe_cs_alu_inputB_sel_100_x[1],         exe_cs_alu_inputB_sel_100_x[2],         exe_cs_alu_inputB_sel_100_x[3],         num_pfs)
    `MUX_4(exe_cs_branch_target_sel_100_mux,      `SRC_SEL_W,    exe_cs_branch_target_sel_100,      exe_cs_branch_target_sel_100_x[0],      exe_cs_branch_target_sel_100_x[1],      exe_cs_branch_target_sel_100_x[2],      exe_cs_branch_target_sel_100_x[3],      num_pfs)
    `MUX_4(exe_cs_shift_by_one_100_mux,           1,             exe_cs_shift_by_one_100,           exe_cs_shift_by_one_100_x[0],           exe_cs_shift_by_one_100_x[1],           exe_cs_shift_by_one_100_x[2],           exe_cs_shift_by_one_100_x[3],           num_pfs)
    `MUX_4(exe_cs_br_ucond_100_mux,               1,             exe_cs_br_ucond_100,               exe_cs_br_ucond_100_x[0],               exe_cs_br_ucond_100_x[1],               exe_cs_br_ucond_100_x[2],               exe_cs_br_ucond_100_x[3],               num_pfs)
    `MUX_4(exe_cs_relative_branch_100_mux,        1,             exe_cs_relative_branch_100,        exe_cs_relative_branch_100_x[0],        exe_cs_relative_branch_100_x[1],        exe_cs_relative_branch_100_x[2],        exe_cs_relative_branch_100_x[3],        num_pfs)
    `MUX_4(exe_cs_special_br_100_mux,             1,             exe_cs_special_br_100,             exe_cs_special_br_100_x[0],             exe_cs_special_br_100_x[1],             exe_cs_special_br_100_x[2],             exe_cs_special_br_100_x[3],             num_pfs)
    `MUX_4(exe_cs_is_far_100_mux,                 1,             exe_cs_is_far_100,                 exe_cs_is_far_100_x[0],                 exe_cs_is_far_100_x[1],                 exe_cs_is_far_100_x[2],                 exe_cs_is_far_100_x[3],                 num_pfs)
    `MUX_4(exe_cs_is_call_100_mux,                1,             exe_cs_is_call_100,                exe_cs_is_call_100_x[0],                exe_cs_is_call_100_x[1],                exe_cs_is_call_100_x[2],                exe_cs_is_call_100_x[3],                num_pfs)
    `MUX_4(exe_cs_second_flag_needed_100_mux,     1,             exe_cs_second_flag_needed_100,     exe_cs_second_flag_needed_100_x[0],     exe_cs_second_flag_needed_100_x[1],     exe_cs_second_flag_needed_100_x[2],     exe_cs_second_flag_needed_100_x[3],     num_pfs)
    `MUX_4(exe_cs_rep_no_zf_update_100_mux,       1,             exe_cs_rep_no_zf_update_100,       exe_cs_rep_no_zf_update_100_x[0],       exe_cs_rep_no_zf_update_100_x[1],       exe_cs_rep_no_zf_update_100_x[2],       exe_cs_rep_no_zf_update_100_x[3],       num_pfs)
    `MUX_4(wb_cs_ST_OP_100_mux,                   1,             wb_cs_ST_OP_100,                   wb_cs_ST_OP_100_x[0],                   wb_cs_ST_OP_100_x[1],                   wb_cs_ST_OP_100_x[2],                   wb_cs_ST_OP_100_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_DR_100_mux,                   1,             wb_cs_WB_DR_100,                   wb_cs_WB_DR_100_x[0],                   wb_cs_WB_DR_100_x[1],                   wb_cs_WB_DR_100_x[2],                   wb_cs_WB_DR_100_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_SR_100_mux,                   1,             wb_cs_WB_SR_100,                   wb_cs_WB_SR_100_x[0],                   wb_cs_WB_SR_100_x[1],                   wb_cs_WB_SR_100_x[2],                   wb_cs_WB_SR_100_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_EAX_100_mux,                  1,             wb_cs_WB_EAX_100,                  wb_cs_WB_EAX_100_x[0],                  wb_cs_WB_EAX_100_x[1],                  wb_cs_WB_EAX_100_x[2],                  wb_cs_WB_EAX_100_x[3],                  num_pfs)
    `MUX_4(decode_cs_REP_101_mux,                 1,             decode_cs_REP_101,                 decode_cs_REP_101_x[0],                 decode_cs_REP_101_x[1],                 decode_cs_REP_101_x[2],                 decode_cs_REP_101_x[3],                 num_pfs)
    `MUX_4(decode_cs_REP_CMP_101_mux,             1,             decode_cs_REP_CMP_101,             decode_cs_REP_CMP_101_x[0],             decode_cs_REP_CMP_101_x[1],             decode_cs_REP_CMP_101_x[2],             decode_cs_REP_CMP_101_x[3],             num_pfs)
    `MUX_4(decode_cs_HALT_101_mux,                1,             decode_cs_HALT_101,                decode_cs_HALT_101_x[0],                decode_cs_HALT_101_x[1],                decode_cs_HALT_101_x[2],                decode_cs_HALT_101_x[3],                num_pfs)
    `MUX_4(decode_cs_MODRM_NEEDED_101_mux,        1,             decode_cs_MODRM_NEEDED_101,        decode_cs_MODRM_NEEDED_101_x[0],        decode_cs_MODRM_NEEDED_101_x[1],        decode_cs_MODRM_NEEDED_101_x[2],        decode_cs_MODRM_NEEDED_101_x[3],        num_pfs)
    `MUX_4(decode_cs_RM_IS_DR_101_mux,            1,             decode_cs_RM_IS_DR_101,            decode_cs_RM_IS_DR_101_x[0],            decode_cs_RM_IS_DR_101_x[1],            decode_cs_RM_IS_DR_101_x[2],            decode_cs_RM_IS_DR_101_x[3],            num_pfs)
    `MUX_4(decode_cs_REG_IS_DR_101_mux,           1,             decode_cs_REG_IS_DR_101,           decode_cs_REG_IS_DR_101_x[0],           decode_cs_REG_IS_DR_101_x[1],           decode_cs_REG_IS_DR_101_x[2],           decode_cs_REG_IS_DR_101_x[3],           num_pfs)
    `MUX_4(decode_cs_REG_IS_SEGMENT_101_mux,      1,             decode_cs_REG_IS_SEGMENT_101,      decode_cs_REG_IS_SEGMENT_101_x[0],      decode_cs_REG_IS_SEGMENT_101_x[1],      decode_cs_REG_IS_SEGMENT_101_x[2],      decode_cs_REG_IS_SEGMENT_101_x[3],      num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_HIGH8_101_mux,  1,             decode_cs_HARDCODED_DR_HIGH8_101,  decode_cs_HARDCODED_DR_HIGH8_101_x[0],  decode_cs_HARDCODED_DR_HIGH8_101_x[1],  decode_cs_HARDCODED_DR_HIGH8_101_x[2],  decode_cs_HARDCODED_DR_HIGH8_101_x[3],  num_pfs)
    `MUX_4(decode_cs_MODRM_BUT_NO_SR_101_mux,     1,             decode_cs_MODRM_BUT_NO_SR_101,     decode_cs_MODRM_BUT_NO_SR_101_x[0],     decode_cs_MODRM_BUT_NO_SR_101_x[1],     decode_cs_MODRM_BUT_NO_SR_101_x[2],     decode_cs_MODRM_BUT_NO_SR_101_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_101_mux,        1,             decode_cs_HARDCODED_DR_101,        decode_cs_HARDCODED_DR_101_x[0],        decode_cs_HARDCODED_DR_101_x[1],        decode_cs_HARDCODED_DR_101_x[2],        decode_cs_HARDCODED_DR_101_x[3],        num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_ID_101_mux,     `REG_ID_W,     decode_cs_HARDCODED_DR_ID_101,     decode_cs_HARDCODED_DR_ID_101_x[0],     decode_cs_HARDCODED_DR_ID_101_x[1],     decode_cs_HARDCODED_DR_ID_101_x[2],     decode_cs_HARDCODED_DR_ID_101_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_101_mux,        1,             decode_cs_HARDCODED_SR_101,        decode_cs_HARDCODED_SR_101_x[0],        decode_cs_HARDCODED_SR_101_x[1],        decode_cs_HARDCODED_SR_101_x[2],        decode_cs_HARDCODED_SR_101_x[3],        num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_ID_101_mux,     `REG_ID_W,     decode_cs_HARDCODED_SR_ID_101,     decode_cs_HARDCODED_SR_ID_101_x[0],     decode_cs_HARDCODED_SR_ID_101_x[1],     decode_cs_HARDCODED_SR_ID_101_x[2],     decode_cs_HARDCODED_SR_ID_101_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_RD_101_mux,     1,             decode_cs_HARDCODED_DR_RD_101,     decode_cs_HARDCODED_DR_RD_101_x[0],     decode_cs_HARDCODED_DR_RD_101_x[1],     decode_cs_HARDCODED_DR_RD_101_x[2],     decode_cs_HARDCODED_DR_RD_101_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_WR_101_mux,     1,             decode_cs_HARDCODED_DR_WR_101,     decode_cs_HARDCODED_DR_WR_101_x[0],     decode_cs_HARDCODED_DR_WR_101_x[1],     decode_cs_HARDCODED_DR_WR_101_x[2],     decode_cs_HARDCODED_DR_WR_101_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_RD_101_mux,     1,             decode_cs_HARDCODED_SR_RD_101,     decode_cs_HARDCODED_SR_RD_101_x[0],     decode_cs_HARDCODED_SR_RD_101_x[1],     decode_cs_HARDCODED_SR_RD_101_x[2],     decode_cs_HARDCODED_SR_RD_101_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_WR_101_mux,     1,             decode_cs_HARDCODED_SR_WR_101,     decode_cs_HARDCODED_SR_WR_101_x[0],     decode_cs_HARDCODED_SR_WR_101_x[1],     decode_cs_HARDCODED_SR_WR_101_x[2],     decode_cs_HARDCODED_SR_WR_101_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_LD_OP_101_mux,     1,             decode_cs_HARDCODED_LD_OP_101,     decode_cs_HARDCODED_LD_OP_101_x[0],     decode_cs_HARDCODED_LD_OP_101_x[1],     decode_cs_HARDCODED_LD_OP_101_x[2],     decode_cs_HARDCODED_LD_OP_101_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_ST_OP_101_mux,     1,             decode_cs_HARDCODED_ST_OP_101,     decode_cs_HARDCODED_ST_OP_101_x[0],     decode_cs_HARDCODED_ST_OP_101_x[1],     decode_cs_HARDCODED_ST_OP_101_x[2],     decode_cs_HARDCODED_ST_OP_101_x[3],     num_pfs)
    `MUX_4(decode_cs_LD_OP_CANCEL_101_mux,        1,             decode_cs_LD_OP_CANCEL_101,        decode_cs_LD_OP_CANCEL_101_x[0],        decode_cs_LD_OP_CANCEL_101_x[1],        decode_cs_LD_OP_CANCEL_101_x[2],        decode_cs_LD_OP_CANCEL_101_x[3],        num_pfs)
    `MUX_4(decode_cs_ST_OP_CANCEL_101_mux,        1,             decode_cs_ST_OP_CANCEL_101,        decode_cs_ST_OP_CANCEL_101_x[0],        decode_cs_ST_OP_CANCEL_101_x[1],        decode_cs_ST_OP_CANCEL_101_x[2],        decode_cs_ST_OP_CANCEL_101_x[3],        num_pfs)
    `MUX_4(decode_cs_OP_IN_MODRM_101_mux,         1,             decode_cs_OP_IN_MODRM_101,         decode_cs_OP_IN_MODRM_101_x[0],         decode_cs_OP_IN_MODRM_101_x[1],         decode_cs_OP_IN_MODRM_101_x[2],         decode_cs_OP_IN_MODRM_101_x[3],         num_pfs)
    `MUX_4(decode_cs_DATA_SIZE_101_mux,           2,             decode_cs_DATA_SIZE_101,           decode_cs_DATA_SIZE_101_x[0],           decode_cs_DATA_SIZE_101_x[1],           decode_cs_DATA_SIZE_101_x[2],           decode_cs_DATA_SIZE_101_x[3],           num_pfs)
    `MUX_4(rr_cs_ST_SEL_101_mux,                  1,             rr_cs_ST_SEL_101,                  rr_cs_ST_SEL_101_x[0],                  rr_cs_ST_SEL_101_x[1],                  rr_cs_ST_SEL_101_x[2],                  rr_cs_ST_SEL_101_x[3],                  num_pfs)
    `MUX_4(rr_cs_MODRM_NEEDED_101_mux,            1,             rr_cs_MODRM_NEEDED_101,            rr_cs_MODRM_NEEDED_101_x[0],            rr_cs_MODRM_NEEDED_101_x[1],            rr_cs_MODRM_NEEDED_101_x[2],            rr_cs_MODRM_NEEDED_101_x[3],            num_pfs)
    `MUX_4(rr_cs_RM_IS_DR_101_mux,                1,             rr_cs_RM_IS_DR_101,                rr_cs_RM_IS_DR_101_x[0],                rr_cs_RM_IS_DR_101_x[1],                rr_cs_RM_IS_DR_101_x[2],                rr_cs_RM_IS_DR_101_x[3],                num_pfs)
    `MUX_4(rr_cs_SWITCH_LD_ADDY_101_mux,          1,             rr_cs_SWITCH_LD_ADDY_101,          rr_cs_SWITCH_LD_ADDY_101_x[0],          rr_cs_SWITCH_LD_ADDY_101_x[1],          rr_cs_SWITCH_LD_ADDY_101_x[2],          rr_cs_SWITCH_LD_ADDY_101_x[3],          num_pfs)
    `MUX_4(rr_cs_LD_OP_101_mux,                   1,             rr_cs_LD_OP_101,                   rr_cs_LD_OP_101_x[0],                   rr_cs_LD_OP_101_x[1],                   rr_cs_LD_OP_101_x[2],                   rr_cs_LD_OP_101_x[3],                   num_pfs)
    `MUX_4(rr_cs_ST_OP_101_mux,                   1,             rr_cs_ST_OP_101,                   rr_cs_ST_OP_101_x[0],                   rr_cs_ST_OP_101_x[1],                   rr_cs_ST_OP_101_x[2],                   rr_cs_ST_OP_101_x[3],                   num_pfs)
    `MUX_4(rr_cs_dr_id_101_mux,                   `REG_ID_W,     rr_cs_dr_id_101,                   rr_cs_dr_id_101_x[0],                   rr_cs_dr_id_101_x[1],                   rr_cs_dr_id_101_x[2],                   rr_cs_dr_id_101_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_id_101_mux,                   `REG_ID_W,     rr_cs_sr_id_101,                   rr_cs_sr_id_101_x[0],                   rr_cs_sr_id_101_x[1],                   rr_cs_sr_id_101_x[2],                   rr_cs_sr_id_101_x[3],                   num_pfs)
    `MUX_4(rr_cs_dr_rd_101_mux,                   1,             rr_cs_dr_rd_101,                   rr_cs_dr_rd_101_x[0],                   rr_cs_dr_rd_101_x[1],                   rr_cs_dr_rd_101_x[2],                   rr_cs_dr_rd_101_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_rd_101_mux,                   1,             rr_cs_sr_rd_101,                   rr_cs_sr_rd_101_x[0],                   rr_cs_sr_rd_101_x[1],                   rr_cs_sr_rd_101_x[2],                   rr_cs_sr_rd_101_x[3],                   num_pfs)
    `MUX_4(rr_cs_eax_rd_101_mux,                  1,             rr_cs_eax_rd_101,                  rr_cs_eax_rd_101_x[0],                  rr_cs_eax_rd_101_x[1],                  rr_cs_eax_rd_101_x[2],                  rr_cs_eax_rd_101_x[3],                  num_pfs)
    `MUX_4(rr_cs_dr_wr_101_mux,                   1,             rr_cs_dr_wr_101,                   rr_cs_dr_wr_101_x[0],                   rr_cs_dr_wr_101_x[1],                   rr_cs_dr_wr_101_x[2],                   rr_cs_dr_wr_101_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_wr_101_mux,                   1,             rr_cs_sr_wr_101,                   rr_cs_sr_wr_101_x[0],                   rr_cs_sr_wr_101_x[1],                   rr_cs_sr_wr_101_x[2],                   rr_cs_sr_wr_101_x[3],                   num_pfs)
    `MUX_4(rr_cs_eax_wr_101_mux,                  1,             rr_cs_eax_wr_101,                  rr_cs_eax_wr_101_x[0],                  rr_cs_eax_wr_101_x[1],                  rr_cs_eax_wr_101_x[2],                  rr_cs_eax_wr_101_x[3],                  num_pfs)
    `MUX_4(rr_cs_MOVS_OP_101_mux,                 1,             rr_cs_MOVS_OP_101,                 rr_cs_MOVS_OP_101_x[0],                 rr_cs_MOVS_OP_101_x[1],                 rr_cs_MOVS_OP_101_x[2],                 rr_cs_MOVS_OP_101_x[3],                 num_pfs)
    `MUX_4(rr_cs_datasize_101_mux,                2,             rr_cs_datasize_101,                rr_cs_datasize_101_x[0],                rr_cs_datasize_101_x[1],                rr_cs_datasize_101_x[2],                rr_cs_datasize_101_x[3],                num_pfs)
    `MUX_4(rr_cs_will_mod_zf_101_mux,             1,             rr_cs_will_mod_zf_101,             rr_cs_will_mod_zf_101_x[0],             rr_cs_will_mod_zf_101_x[1],             rr_cs_will_mod_zf_101_x[2],             rr_cs_will_mod_zf_101_x[3],             num_pfs)
    `MUX_4(rr_cs_seg_1_valid_101_mux,             1,             rr_cs_seg_1_valid_101,             rr_cs_seg_1_valid_101_x[0],             rr_cs_seg_1_valid_101_x[1],             rr_cs_seg_1_valid_101_x[2],             rr_cs_seg_1_valid_101_x[3],             num_pfs)
    `MUX_4(rr_cs_seg_0_id_101_mux,                `REG_ID_W,     rr_cs_seg_0_id_101,                rr_cs_seg_0_id_101_x[0],                rr_cs_seg_0_id_101_x[1],                rr_cs_seg_0_id_101_x[2],                rr_cs_seg_0_id_101_x[3],                num_pfs)
    `MUX_4(rr_cs_seg_1_id_101_mux,                `REG_ID_W,     rr_cs_seg_1_id_101,                rr_cs_seg_1_id_101_x[0],                rr_cs_seg_1_id_101_x[1],                rr_cs_seg_1_id_101_x[2],                rr_cs_seg_1_id_101_x[3],                num_pfs)
    `MUX_4(rr_cs_special_modrm_bs_101_mux,        1,             rr_cs_special_modrm_bs_101,        rr_cs_special_modrm_bs_101_x[0],        rr_cs_special_modrm_bs_101_x[1],        rr_cs_special_modrm_bs_101_x[2],        rr_cs_special_modrm_bs_101_x[3],        num_pfs)
    `MUX_4(rr_cs_special_br_101_mux,              1,             rr_cs_special_br_101,              rr_cs_special_br_101_x[0],              rr_cs_special_br_101_x[1],              rr_cs_special_br_101_x[2],              rr_cs_special_br_101_x[3],              num_pfs)
    `MUX_4(dc_cs_LD_OP_101_mux,                   1,             dc_cs_LD_OP_101,                   dc_cs_LD_OP_101_x[0],                   dc_cs_LD_OP_101_x[1],                   dc_cs_LD_OP_101_x[2],                   dc_cs_LD_OP_101_x[3],                   num_pfs)
    `MUX_4(dc_cs_ST_OP_101_mux,                   1,             dc_cs_ST_OP_101,                   dc_cs_ST_OP_101_x[0],                   dc_cs_ST_OP_101_x[1],                   dc_cs_ST_OP_101_x[2],                   dc_cs_ST_OP_101_x[3],                   num_pfs)
    `MUX_4(dc_cs_dr_upper8_101_mux,               1,             dc_cs_dr_upper8_101,               dc_cs_dr_upper8_101_x[0],               dc_cs_dr_upper8_101_x[1],               dc_cs_dr_upper8_101_x[2],               dc_cs_dr_upper8_101_x[3],               num_pfs)
    `MUX_4(dc_cs_sr_upper8_101_mux,               1,             dc_cs_sr_upper8_101,               dc_cs_sr_upper8_101_x[0],               dc_cs_sr_upper8_101_x[1],               dc_cs_sr_upper8_101_x[2],               dc_cs_sr_upper8_101_x[3],               num_pfs)
    `MUX_4(dc_cs_datasize_101_mux,                2,             dc_cs_datasize_101,                dc_cs_datasize_101_x[0],                dc_cs_datasize_101_x[1],                dc_cs_datasize_101_x[2],                dc_cs_datasize_101_x[3],                num_pfs)
    `MUX_4(mem_cs_ST_OP_101_mux,                  1,             mem_cs_ST_OP_101,                  mem_cs_ST_OP_101_x[0],                  mem_cs_ST_OP_101_x[1],                  mem_cs_ST_OP_101_x[2],                  mem_cs_ST_OP_101_x[3],                  num_pfs)
    `MUX_4(mem_cs_LD_OP_101_mux,                  1,             mem_cs_LD_OP_101,                  mem_cs_LD_OP_101_x[0],                  mem_cs_LD_OP_101_x[1],                  mem_cs_LD_OP_101_x[2],                  mem_cs_LD_OP_101_x[3],                  num_pfs)
    `MUX_4(exe_cs_ST_OP_101_mux,                  1,             exe_cs_ST_OP_101,                  exe_cs_ST_OP_101_x[0],                  exe_cs_ST_OP_101_x[1],                  exe_cs_ST_OP_101_x[2],                  exe_cs_ST_OP_101_x[3],                  num_pfs)
    `MUX_4(exe_cs_OP_TYPE_101_mux,                `EXE_OP_W,     exe_cs_OP_TYPE_101,                exe_cs_OP_TYPE_101_x[0],                exe_cs_OP_TYPE_101_x[1],                exe_cs_OP_TYPE_101_x[2],                exe_cs_OP_TYPE_101_x[3],                num_pfs)
    `MUX_4(exe_cs_alu_inputA_sel_101_mux,         `SRC_SEL_W,    exe_cs_alu_inputA_sel_101,         exe_cs_alu_inputA_sel_101_x[0],         exe_cs_alu_inputA_sel_101_x[1],         exe_cs_alu_inputA_sel_101_x[2],         exe_cs_alu_inputA_sel_101_x[3],         num_pfs)
    `MUX_4(exe_cs_alu_inputB_sel_101_mux,         `SRC_SEL_W,    exe_cs_alu_inputB_sel_101,         exe_cs_alu_inputB_sel_101_x[0],         exe_cs_alu_inputB_sel_101_x[1],         exe_cs_alu_inputB_sel_101_x[2],         exe_cs_alu_inputB_sel_101_x[3],         num_pfs)
    `MUX_4(exe_cs_branch_target_sel_101_mux,      `SRC_SEL_W,    exe_cs_branch_target_sel_101,      exe_cs_branch_target_sel_101_x[0],      exe_cs_branch_target_sel_101_x[1],      exe_cs_branch_target_sel_101_x[2],      exe_cs_branch_target_sel_101_x[3],      num_pfs)
    `MUX_4(exe_cs_shift_by_one_101_mux,           1,             exe_cs_shift_by_one_101,           exe_cs_shift_by_one_101_x[0],           exe_cs_shift_by_one_101_x[1],           exe_cs_shift_by_one_101_x[2],           exe_cs_shift_by_one_101_x[3],           num_pfs)
    `MUX_4(exe_cs_br_ucond_101_mux,               1,             exe_cs_br_ucond_101,               exe_cs_br_ucond_101_x[0],               exe_cs_br_ucond_101_x[1],               exe_cs_br_ucond_101_x[2],               exe_cs_br_ucond_101_x[3],               num_pfs)
    `MUX_4(exe_cs_relative_branch_101_mux,        1,             exe_cs_relative_branch_101,        exe_cs_relative_branch_101_x[0],        exe_cs_relative_branch_101_x[1],        exe_cs_relative_branch_101_x[2],        exe_cs_relative_branch_101_x[3],        num_pfs)
    `MUX_4(exe_cs_special_br_101_mux,             1,             exe_cs_special_br_101,             exe_cs_special_br_101_x[0],             exe_cs_special_br_101_x[1],             exe_cs_special_br_101_x[2],             exe_cs_special_br_101_x[3],             num_pfs)
    `MUX_4(exe_cs_is_far_101_mux,                 1,             exe_cs_is_far_101,                 exe_cs_is_far_101_x[0],                 exe_cs_is_far_101_x[1],                 exe_cs_is_far_101_x[2],                 exe_cs_is_far_101_x[3],                 num_pfs)
    `MUX_4(exe_cs_is_call_101_mux,                1,             exe_cs_is_call_101,                exe_cs_is_call_101_x[0],                exe_cs_is_call_101_x[1],                exe_cs_is_call_101_x[2],                exe_cs_is_call_101_x[3],                num_pfs)
    `MUX_4(exe_cs_second_flag_needed_101_mux,     1,             exe_cs_second_flag_needed_101,     exe_cs_second_flag_needed_101_x[0],     exe_cs_second_flag_needed_101_x[1],     exe_cs_second_flag_needed_101_x[2],     exe_cs_second_flag_needed_101_x[3],     num_pfs)
    `MUX_4(exe_cs_rep_no_zf_update_101_mux,       1,             exe_cs_rep_no_zf_update_101,       exe_cs_rep_no_zf_update_101_x[0],       exe_cs_rep_no_zf_update_101_x[1],       exe_cs_rep_no_zf_update_101_x[2],       exe_cs_rep_no_zf_update_101_x[3],       num_pfs)
    `MUX_4(wb_cs_ST_OP_101_mux,                   1,             wb_cs_ST_OP_101,                   wb_cs_ST_OP_101_x[0],                   wb_cs_ST_OP_101_x[1],                   wb_cs_ST_OP_101_x[2],                   wb_cs_ST_OP_101_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_DR_101_mux,                   1,             wb_cs_WB_DR_101,                   wb_cs_WB_DR_101_x[0],                   wb_cs_WB_DR_101_x[1],                   wb_cs_WB_DR_101_x[2],                   wb_cs_WB_DR_101_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_SR_101_mux,                   1,             wb_cs_WB_SR_101,                   wb_cs_WB_SR_101_x[0],                   wb_cs_WB_SR_101_x[1],                   wb_cs_WB_SR_101_x[2],                   wb_cs_WB_SR_101_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_EAX_101_mux,                  1,             wb_cs_WB_EAX_101,                  wb_cs_WB_EAX_101_x[0],                  wb_cs_WB_EAX_101_x[1],                  wb_cs_WB_EAX_101_x[2],                  wb_cs_WB_EAX_101_x[3],                  num_pfs)
    `MUX_4(decode_cs_REP_110_mux,                 1,             decode_cs_REP_110,                 decode_cs_REP_110_x[0],                 decode_cs_REP_110_x[1],                 decode_cs_REP_110_x[2],                 decode_cs_REP_110_x[3],                 num_pfs)
    `MUX_4(decode_cs_REP_CMP_110_mux,             1,             decode_cs_REP_CMP_110,             decode_cs_REP_CMP_110_x[0],             decode_cs_REP_CMP_110_x[1],             decode_cs_REP_CMP_110_x[2],             decode_cs_REP_CMP_110_x[3],             num_pfs)
    `MUX_4(decode_cs_HALT_110_mux,                1,             decode_cs_HALT_110,                decode_cs_HALT_110_x[0],                decode_cs_HALT_110_x[1],                decode_cs_HALT_110_x[2],                decode_cs_HALT_110_x[3],                num_pfs)
    `MUX_4(decode_cs_MODRM_NEEDED_110_mux,        1,             decode_cs_MODRM_NEEDED_110,        decode_cs_MODRM_NEEDED_110_x[0],        decode_cs_MODRM_NEEDED_110_x[1],        decode_cs_MODRM_NEEDED_110_x[2],        decode_cs_MODRM_NEEDED_110_x[3],        num_pfs)
    `MUX_4(decode_cs_RM_IS_DR_110_mux,            1,             decode_cs_RM_IS_DR_110,            decode_cs_RM_IS_DR_110_x[0],            decode_cs_RM_IS_DR_110_x[1],            decode_cs_RM_IS_DR_110_x[2],            decode_cs_RM_IS_DR_110_x[3],            num_pfs)
    `MUX_4(decode_cs_REG_IS_DR_110_mux,           1,             decode_cs_REG_IS_DR_110,           decode_cs_REG_IS_DR_110_x[0],           decode_cs_REG_IS_DR_110_x[1],           decode_cs_REG_IS_DR_110_x[2],           decode_cs_REG_IS_DR_110_x[3],           num_pfs)
    `MUX_4(decode_cs_REG_IS_SEGMENT_110_mux,      1,             decode_cs_REG_IS_SEGMENT_110,      decode_cs_REG_IS_SEGMENT_110_x[0],      decode_cs_REG_IS_SEGMENT_110_x[1],      decode_cs_REG_IS_SEGMENT_110_x[2],      decode_cs_REG_IS_SEGMENT_110_x[3],      num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_HIGH8_110_mux,  1,             decode_cs_HARDCODED_DR_HIGH8_110,  decode_cs_HARDCODED_DR_HIGH8_110_x[0],  decode_cs_HARDCODED_DR_HIGH8_110_x[1],  decode_cs_HARDCODED_DR_HIGH8_110_x[2],  decode_cs_HARDCODED_DR_HIGH8_110_x[3],  num_pfs)
    `MUX_4(decode_cs_MODRM_BUT_NO_SR_110_mux,     1,             decode_cs_MODRM_BUT_NO_SR_110,     decode_cs_MODRM_BUT_NO_SR_110_x[0],     decode_cs_MODRM_BUT_NO_SR_110_x[1],     decode_cs_MODRM_BUT_NO_SR_110_x[2],     decode_cs_MODRM_BUT_NO_SR_110_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_110_mux,        1,             decode_cs_HARDCODED_DR_110,        decode_cs_HARDCODED_DR_110_x[0],        decode_cs_HARDCODED_DR_110_x[1],        decode_cs_HARDCODED_DR_110_x[2],        decode_cs_HARDCODED_DR_110_x[3],        num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_ID_110_mux,     `REG_ID_W,     decode_cs_HARDCODED_DR_ID_110,     decode_cs_HARDCODED_DR_ID_110_x[0],     decode_cs_HARDCODED_DR_ID_110_x[1],     decode_cs_HARDCODED_DR_ID_110_x[2],     decode_cs_HARDCODED_DR_ID_110_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_110_mux,        1,             decode_cs_HARDCODED_SR_110,        decode_cs_HARDCODED_SR_110_x[0],        decode_cs_HARDCODED_SR_110_x[1],        decode_cs_HARDCODED_SR_110_x[2],        decode_cs_HARDCODED_SR_110_x[3],        num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_ID_110_mux,     `REG_ID_W,     decode_cs_HARDCODED_SR_ID_110,     decode_cs_HARDCODED_SR_ID_110_x[0],     decode_cs_HARDCODED_SR_ID_110_x[1],     decode_cs_HARDCODED_SR_ID_110_x[2],     decode_cs_HARDCODED_SR_ID_110_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_RD_110_mux,     1,             decode_cs_HARDCODED_DR_RD_110,     decode_cs_HARDCODED_DR_RD_110_x[0],     decode_cs_HARDCODED_DR_RD_110_x[1],     decode_cs_HARDCODED_DR_RD_110_x[2],     decode_cs_HARDCODED_DR_RD_110_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_WR_110_mux,     1,             decode_cs_HARDCODED_DR_WR_110,     decode_cs_HARDCODED_DR_WR_110_x[0],     decode_cs_HARDCODED_DR_WR_110_x[1],     decode_cs_HARDCODED_DR_WR_110_x[2],     decode_cs_HARDCODED_DR_WR_110_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_RD_110_mux,     1,             decode_cs_HARDCODED_SR_RD_110,     decode_cs_HARDCODED_SR_RD_110_x[0],     decode_cs_HARDCODED_SR_RD_110_x[1],     decode_cs_HARDCODED_SR_RD_110_x[2],     decode_cs_HARDCODED_SR_RD_110_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_WR_110_mux,     1,             decode_cs_HARDCODED_SR_WR_110,     decode_cs_HARDCODED_SR_WR_110_x[0],     decode_cs_HARDCODED_SR_WR_110_x[1],     decode_cs_HARDCODED_SR_WR_110_x[2],     decode_cs_HARDCODED_SR_WR_110_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_LD_OP_110_mux,     1,             decode_cs_HARDCODED_LD_OP_110,     decode_cs_HARDCODED_LD_OP_110_x[0],     decode_cs_HARDCODED_LD_OP_110_x[1],     decode_cs_HARDCODED_LD_OP_110_x[2],     decode_cs_HARDCODED_LD_OP_110_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_ST_OP_110_mux,     1,             decode_cs_HARDCODED_ST_OP_110,     decode_cs_HARDCODED_ST_OP_110_x[0],     decode_cs_HARDCODED_ST_OP_110_x[1],     decode_cs_HARDCODED_ST_OP_110_x[2],     decode_cs_HARDCODED_ST_OP_110_x[3],     num_pfs)
    `MUX_4(decode_cs_LD_OP_CANCEL_110_mux,        1,             decode_cs_LD_OP_CANCEL_110,        decode_cs_LD_OP_CANCEL_110_x[0],        decode_cs_LD_OP_CANCEL_110_x[1],        decode_cs_LD_OP_CANCEL_110_x[2],        decode_cs_LD_OP_CANCEL_110_x[3],        num_pfs)
    `MUX_4(decode_cs_ST_OP_CANCEL_110_mux,        1,             decode_cs_ST_OP_CANCEL_110,        decode_cs_ST_OP_CANCEL_110_x[0],        decode_cs_ST_OP_CANCEL_110_x[1],        decode_cs_ST_OP_CANCEL_110_x[2],        decode_cs_ST_OP_CANCEL_110_x[3],        num_pfs)
    `MUX_4(decode_cs_OP_IN_MODRM_110_mux,         1,             decode_cs_OP_IN_MODRM_110,         decode_cs_OP_IN_MODRM_110_x[0],         decode_cs_OP_IN_MODRM_110_x[1],         decode_cs_OP_IN_MODRM_110_x[2],         decode_cs_OP_IN_MODRM_110_x[3],         num_pfs)
    `MUX_4(decode_cs_DATA_SIZE_110_mux,           2,             decode_cs_DATA_SIZE_110,           decode_cs_DATA_SIZE_110_x[0],           decode_cs_DATA_SIZE_110_x[1],           decode_cs_DATA_SIZE_110_x[2],           decode_cs_DATA_SIZE_110_x[3],           num_pfs)
    `MUX_4(rr_cs_ST_SEL_110_mux,                  1,             rr_cs_ST_SEL_110,                  rr_cs_ST_SEL_110_x[0],                  rr_cs_ST_SEL_110_x[1],                  rr_cs_ST_SEL_110_x[2],                  rr_cs_ST_SEL_110_x[3],                  num_pfs)
    `MUX_4(rr_cs_MODRM_NEEDED_110_mux,            1,             rr_cs_MODRM_NEEDED_110,            rr_cs_MODRM_NEEDED_110_x[0],            rr_cs_MODRM_NEEDED_110_x[1],            rr_cs_MODRM_NEEDED_110_x[2],            rr_cs_MODRM_NEEDED_110_x[3],            num_pfs)
    `MUX_4(rr_cs_RM_IS_DR_110_mux,                1,             rr_cs_RM_IS_DR_110,                rr_cs_RM_IS_DR_110_x[0],                rr_cs_RM_IS_DR_110_x[1],                rr_cs_RM_IS_DR_110_x[2],                rr_cs_RM_IS_DR_110_x[3],                num_pfs)
    `MUX_4(rr_cs_SWITCH_LD_ADDY_110_mux,          1,             rr_cs_SWITCH_LD_ADDY_110,          rr_cs_SWITCH_LD_ADDY_110_x[0],          rr_cs_SWITCH_LD_ADDY_110_x[1],          rr_cs_SWITCH_LD_ADDY_110_x[2],          rr_cs_SWITCH_LD_ADDY_110_x[3],          num_pfs)
    `MUX_4(rr_cs_LD_OP_110_mux,                   1,             rr_cs_LD_OP_110,                   rr_cs_LD_OP_110_x[0],                   rr_cs_LD_OP_110_x[1],                   rr_cs_LD_OP_110_x[2],                   rr_cs_LD_OP_110_x[3],                   num_pfs)
    `MUX_4(rr_cs_ST_OP_110_mux,                   1,             rr_cs_ST_OP_110,                   rr_cs_ST_OP_110_x[0],                   rr_cs_ST_OP_110_x[1],                   rr_cs_ST_OP_110_x[2],                   rr_cs_ST_OP_110_x[3],                   num_pfs)
    `MUX_4(rr_cs_dr_id_110_mux,                   `REG_ID_W,     rr_cs_dr_id_110,                   rr_cs_dr_id_110_x[0],                   rr_cs_dr_id_110_x[1],                   rr_cs_dr_id_110_x[2],                   rr_cs_dr_id_110_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_id_110_mux,                   `REG_ID_W,     rr_cs_sr_id_110,                   rr_cs_sr_id_110_x[0],                   rr_cs_sr_id_110_x[1],                   rr_cs_sr_id_110_x[2],                   rr_cs_sr_id_110_x[3],                   num_pfs)
    `MUX_4(rr_cs_dr_rd_110_mux,                   1,             rr_cs_dr_rd_110,                   rr_cs_dr_rd_110_x[0],                   rr_cs_dr_rd_110_x[1],                   rr_cs_dr_rd_110_x[2],                   rr_cs_dr_rd_110_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_rd_110_mux,                   1,             rr_cs_sr_rd_110,                   rr_cs_sr_rd_110_x[0],                   rr_cs_sr_rd_110_x[1],                   rr_cs_sr_rd_110_x[2],                   rr_cs_sr_rd_110_x[3],                   num_pfs)
    `MUX_4(rr_cs_eax_rd_110_mux,                  1,             rr_cs_eax_rd_110,                  rr_cs_eax_rd_110_x[0],                  rr_cs_eax_rd_110_x[1],                  rr_cs_eax_rd_110_x[2],                  rr_cs_eax_rd_110_x[3],                  num_pfs)
    `MUX_4(rr_cs_dr_wr_110_mux,                   1,             rr_cs_dr_wr_110,                   rr_cs_dr_wr_110_x[0],                   rr_cs_dr_wr_110_x[1],                   rr_cs_dr_wr_110_x[2],                   rr_cs_dr_wr_110_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_wr_110_mux,                   1,             rr_cs_sr_wr_110,                   rr_cs_sr_wr_110_x[0],                   rr_cs_sr_wr_110_x[1],                   rr_cs_sr_wr_110_x[2],                   rr_cs_sr_wr_110_x[3],                   num_pfs)
    `MUX_4(rr_cs_eax_wr_110_mux,                  1,             rr_cs_eax_wr_110,                  rr_cs_eax_wr_110_x[0],                  rr_cs_eax_wr_110_x[1],                  rr_cs_eax_wr_110_x[2],                  rr_cs_eax_wr_110_x[3],                  num_pfs)
    `MUX_4(rr_cs_MOVS_OP_110_mux,                 1,             rr_cs_MOVS_OP_110,                 rr_cs_MOVS_OP_110_x[0],                 rr_cs_MOVS_OP_110_x[1],                 rr_cs_MOVS_OP_110_x[2],                 rr_cs_MOVS_OP_110_x[3],                 num_pfs)
    `MUX_4(rr_cs_datasize_110_mux,                2,             rr_cs_datasize_110,                rr_cs_datasize_110_x[0],                rr_cs_datasize_110_x[1],                rr_cs_datasize_110_x[2],                rr_cs_datasize_110_x[3],                num_pfs)
    `MUX_4(rr_cs_will_mod_zf_110_mux,             1,             rr_cs_will_mod_zf_110,             rr_cs_will_mod_zf_110_x[0],             rr_cs_will_mod_zf_110_x[1],             rr_cs_will_mod_zf_110_x[2],             rr_cs_will_mod_zf_110_x[3],             num_pfs)
    `MUX_4(rr_cs_seg_1_valid_110_mux,             1,             rr_cs_seg_1_valid_110,             rr_cs_seg_1_valid_110_x[0],             rr_cs_seg_1_valid_110_x[1],             rr_cs_seg_1_valid_110_x[2],             rr_cs_seg_1_valid_110_x[3],             num_pfs)
    `MUX_4(rr_cs_seg_0_id_110_mux,                `REG_ID_W,     rr_cs_seg_0_id_110,                rr_cs_seg_0_id_110_x[0],                rr_cs_seg_0_id_110_x[1],                rr_cs_seg_0_id_110_x[2],                rr_cs_seg_0_id_110_x[3],                num_pfs)
    `MUX_4(rr_cs_seg_1_id_110_mux,                `REG_ID_W,     rr_cs_seg_1_id_110,                rr_cs_seg_1_id_110_x[0],                rr_cs_seg_1_id_110_x[1],                rr_cs_seg_1_id_110_x[2],                rr_cs_seg_1_id_110_x[3],                num_pfs)
    `MUX_4(rr_cs_special_modrm_bs_110_mux,        1,             rr_cs_special_modrm_bs_110,        rr_cs_special_modrm_bs_110_x[0],        rr_cs_special_modrm_bs_110_x[1],        rr_cs_special_modrm_bs_110_x[2],        rr_cs_special_modrm_bs_110_x[3],        num_pfs)
    `MUX_4(rr_cs_special_br_110_mux,              1,             rr_cs_special_br_110,              rr_cs_special_br_110_x[0],              rr_cs_special_br_110_x[1],              rr_cs_special_br_110_x[2],              rr_cs_special_br_110_x[3],              num_pfs)
    `MUX_4(dc_cs_LD_OP_110_mux,                   1,             dc_cs_LD_OP_110,                   dc_cs_LD_OP_110_x[0],                   dc_cs_LD_OP_110_x[1],                   dc_cs_LD_OP_110_x[2],                   dc_cs_LD_OP_110_x[3],                   num_pfs)
    `MUX_4(dc_cs_ST_OP_110_mux,                   1,             dc_cs_ST_OP_110,                   dc_cs_ST_OP_110_x[0],                   dc_cs_ST_OP_110_x[1],                   dc_cs_ST_OP_110_x[2],                   dc_cs_ST_OP_110_x[3],                   num_pfs)
    `MUX_4(dc_cs_dr_upper8_110_mux,               1,             dc_cs_dr_upper8_110,               dc_cs_dr_upper8_110_x[0],               dc_cs_dr_upper8_110_x[1],               dc_cs_dr_upper8_110_x[2],               dc_cs_dr_upper8_110_x[3],               num_pfs)
    `MUX_4(dc_cs_sr_upper8_110_mux,               1,             dc_cs_sr_upper8_110,               dc_cs_sr_upper8_110_x[0],               dc_cs_sr_upper8_110_x[1],               dc_cs_sr_upper8_110_x[2],               dc_cs_sr_upper8_110_x[3],               num_pfs)
    `MUX_4(dc_cs_datasize_110_mux,                2,             dc_cs_datasize_110,                dc_cs_datasize_110_x[0],                dc_cs_datasize_110_x[1],                dc_cs_datasize_110_x[2],                dc_cs_datasize_110_x[3],                num_pfs)
    `MUX_4(mem_cs_ST_OP_110_mux,                  1,             mem_cs_ST_OP_110,                  mem_cs_ST_OP_110_x[0],                  mem_cs_ST_OP_110_x[1],                  mem_cs_ST_OP_110_x[2],                  mem_cs_ST_OP_110_x[3],                  num_pfs)
    `MUX_4(mem_cs_LD_OP_110_mux,                  1,             mem_cs_LD_OP_110,                  mem_cs_LD_OP_110_x[0],                  mem_cs_LD_OP_110_x[1],                  mem_cs_LD_OP_110_x[2],                  mem_cs_LD_OP_110_x[3],                  num_pfs)
    `MUX_4(exe_cs_ST_OP_110_mux,                  1,             exe_cs_ST_OP_110,                  exe_cs_ST_OP_110_x[0],                  exe_cs_ST_OP_110_x[1],                  exe_cs_ST_OP_110_x[2],                  exe_cs_ST_OP_110_x[3],                  num_pfs)
    `MUX_4(exe_cs_OP_TYPE_110_mux,                `EXE_OP_W,     exe_cs_OP_TYPE_110,                exe_cs_OP_TYPE_110_x[0],                exe_cs_OP_TYPE_110_x[1],                exe_cs_OP_TYPE_110_x[2],                exe_cs_OP_TYPE_110_x[3],                num_pfs)
    `MUX_4(exe_cs_alu_inputA_sel_110_mux,         `SRC_SEL_W,    exe_cs_alu_inputA_sel_110,         exe_cs_alu_inputA_sel_110_x[0],         exe_cs_alu_inputA_sel_110_x[1],         exe_cs_alu_inputA_sel_110_x[2],         exe_cs_alu_inputA_sel_110_x[3],         num_pfs)
    `MUX_4(exe_cs_alu_inputB_sel_110_mux,         `SRC_SEL_W,    exe_cs_alu_inputB_sel_110,         exe_cs_alu_inputB_sel_110_x[0],         exe_cs_alu_inputB_sel_110_x[1],         exe_cs_alu_inputB_sel_110_x[2],         exe_cs_alu_inputB_sel_110_x[3],         num_pfs)
    `MUX_4(exe_cs_branch_target_sel_110_mux,      `SRC_SEL_W,    exe_cs_branch_target_sel_110,      exe_cs_branch_target_sel_110_x[0],      exe_cs_branch_target_sel_110_x[1],      exe_cs_branch_target_sel_110_x[2],      exe_cs_branch_target_sel_110_x[3],      num_pfs)
    `MUX_4(exe_cs_shift_by_one_110_mux,           1,             exe_cs_shift_by_one_110,           exe_cs_shift_by_one_110_x[0],           exe_cs_shift_by_one_110_x[1],           exe_cs_shift_by_one_110_x[2],           exe_cs_shift_by_one_110_x[3],           num_pfs)
    `MUX_4(exe_cs_br_ucond_110_mux,               1,             exe_cs_br_ucond_110,               exe_cs_br_ucond_110_x[0],               exe_cs_br_ucond_110_x[1],               exe_cs_br_ucond_110_x[2],               exe_cs_br_ucond_110_x[3],               num_pfs)
    `MUX_4(exe_cs_relative_branch_110_mux,        1,             exe_cs_relative_branch_110,        exe_cs_relative_branch_110_x[0],        exe_cs_relative_branch_110_x[1],        exe_cs_relative_branch_110_x[2],        exe_cs_relative_branch_110_x[3],        num_pfs)
    `MUX_4(exe_cs_special_br_110_mux,             1,             exe_cs_special_br_110,             exe_cs_special_br_110_x[0],             exe_cs_special_br_110_x[1],             exe_cs_special_br_110_x[2],             exe_cs_special_br_110_x[3],             num_pfs)
    `MUX_4(exe_cs_is_far_110_mux,                 1,             exe_cs_is_far_110,                 exe_cs_is_far_110_x[0],                 exe_cs_is_far_110_x[1],                 exe_cs_is_far_110_x[2],                 exe_cs_is_far_110_x[3],                 num_pfs)
    `MUX_4(exe_cs_is_call_110_mux,                1,             exe_cs_is_call_110,                exe_cs_is_call_110_x[0],                exe_cs_is_call_110_x[1],                exe_cs_is_call_110_x[2],                exe_cs_is_call_110_x[3],                num_pfs)
    `MUX_4(exe_cs_second_flag_needed_110_mux,     1,             exe_cs_second_flag_needed_110,     exe_cs_second_flag_needed_110_x[0],     exe_cs_second_flag_needed_110_x[1],     exe_cs_second_flag_needed_110_x[2],     exe_cs_second_flag_needed_110_x[3],     num_pfs)
    `MUX_4(exe_cs_rep_no_zf_update_110_mux,       1,             exe_cs_rep_no_zf_update_110,       exe_cs_rep_no_zf_update_110_x[0],       exe_cs_rep_no_zf_update_110_x[1],       exe_cs_rep_no_zf_update_110_x[2],       exe_cs_rep_no_zf_update_110_x[3],       num_pfs)
    `MUX_4(wb_cs_ST_OP_110_mux,                   1,             wb_cs_ST_OP_110,                   wb_cs_ST_OP_110_x[0],                   wb_cs_ST_OP_110_x[1],                   wb_cs_ST_OP_110_x[2],                   wb_cs_ST_OP_110_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_DR_110_mux,                   1,             wb_cs_WB_DR_110,                   wb_cs_WB_DR_110_x[0],                   wb_cs_WB_DR_110_x[1],                   wb_cs_WB_DR_110_x[2],                   wb_cs_WB_DR_110_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_SR_110_mux,                   1,             wb_cs_WB_SR_110,                   wb_cs_WB_SR_110_x[0],                   wb_cs_WB_SR_110_x[1],                   wb_cs_WB_SR_110_x[2],                   wb_cs_WB_SR_110_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_EAX_110_mux,                  1,             wb_cs_WB_EAX_110,                  wb_cs_WB_EAX_110_x[0],                  wb_cs_WB_EAX_110_x[1],                  wb_cs_WB_EAX_110_x[2],                  wb_cs_WB_EAX_110_x[3],                  num_pfs)
    `MUX_4(decode_cs_REP_111_mux,                 1,             decode_cs_REP_111,                 decode_cs_REP_111_x[0],                 decode_cs_REP_111_x[1],                 decode_cs_REP_111_x[2],                 decode_cs_REP_111_x[3],                 num_pfs)
    `MUX_4(decode_cs_REP_CMP_111_mux,             1,             decode_cs_REP_CMP_111,             decode_cs_REP_CMP_111_x[0],             decode_cs_REP_CMP_111_x[1],             decode_cs_REP_CMP_111_x[2],             decode_cs_REP_CMP_111_x[3],             num_pfs)
    `MUX_4(decode_cs_HALT_111_mux,                1,             decode_cs_HALT_111,                decode_cs_HALT_111_x[0],                decode_cs_HALT_111_x[1],                decode_cs_HALT_111_x[2],                decode_cs_HALT_111_x[3],                num_pfs)
    `MUX_4(decode_cs_MODRM_NEEDED_111_mux,        1,             decode_cs_MODRM_NEEDED_111,        decode_cs_MODRM_NEEDED_111_x[0],        decode_cs_MODRM_NEEDED_111_x[1],        decode_cs_MODRM_NEEDED_111_x[2],        decode_cs_MODRM_NEEDED_111_x[3],        num_pfs)
    `MUX_4(decode_cs_RM_IS_DR_111_mux,            1,             decode_cs_RM_IS_DR_111,            decode_cs_RM_IS_DR_111_x[0],            decode_cs_RM_IS_DR_111_x[1],            decode_cs_RM_IS_DR_111_x[2],            decode_cs_RM_IS_DR_111_x[3],            num_pfs)
    `MUX_4(decode_cs_REG_IS_DR_111_mux,           1,             decode_cs_REG_IS_DR_111,           decode_cs_REG_IS_DR_111_x[0],           decode_cs_REG_IS_DR_111_x[1],           decode_cs_REG_IS_DR_111_x[2],           decode_cs_REG_IS_DR_111_x[3],           num_pfs)
    `MUX_4(decode_cs_REG_IS_SEGMENT_111_mux,      1,             decode_cs_REG_IS_SEGMENT_111,      decode_cs_REG_IS_SEGMENT_111_x[0],      decode_cs_REG_IS_SEGMENT_111_x[1],      decode_cs_REG_IS_SEGMENT_111_x[2],      decode_cs_REG_IS_SEGMENT_111_x[3],      num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_HIGH8_111_mux,  1,             decode_cs_HARDCODED_DR_HIGH8_111,  decode_cs_HARDCODED_DR_HIGH8_111_x[0],  decode_cs_HARDCODED_DR_HIGH8_111_x[1],  decode_cs_HARDCODED_DR_HIGH8_111_x[2],  decode_cs_HARDCODED_DR_HIGH8_111_x[3],  num_pfs)
    `MUX_4(decode_cs_MODRM_BUT_NO_SR_111_mux,     1,             decode_cs_MODRM_BUT_NO_SR_111,     decode_cs_MODRM_BUT_NO_SR_111_x[0],     decode_cs_MODRM_BUT_NO_SR_111_x[1],     decode_cs_MODRM_BUT_NO_SR_111_x[2],     decode_cs_MODRM_BUT_NO_SR_111_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_111_mux,        1,             decode_cs_HARDCODED_DR_111,        decode_cs_HARDCODED_DR_111_x[0],        decode_cs_HARDCODED_DR_111_x[1],        decode_cs_HARDCODED_DR_111_x[2],        decode_cs_HARDCODED_DR_111_x[3],        num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_ID_111_mux,     `REG_ID_W,     decode_cs_HARDCODED_DR_ID_111,     decode_cs_HARDCODED_DR_ID_111_x[0],     decode_cs_HARDCODED_DR_ID_111_x[1],     decode_cs_HARDCODED_DR_ID_111_x[2],     decode_cs_HARDCODED_DR_ID_111_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_111_mux,        1,             decode_cs_HARDCODED_SR_111,        decode_cs_HARDCODED_SR_111_x[0],        decode_cs_HARDCODED_SR_111_x[1],        decode_cs_HARDCODED_SR_111_x[2],        decode_cs_HARDCODED_SR_111_x[3],        num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_ID_111_mux,     `REG_ID_W,     decode_cs_HARDCODED_SR_ID_111,     decode_cs_HARDCODED_SR_ID_111_x[0],     decode_cs_HARDCODED_SR_ID_111_x[1],     decode_cs_HARDCODED_SR_ID_111_x[2],     decode_cs_HARDCODED_SR_ID_111_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_RD_111_mux,     1,             decode_cs_HARDCODED_DR_RD_111,     decode_cs_HARDCODED_DR_RD_111_x[0],     decode_cs_HARDCODED_DR_RD_111_x[1],     decode_cs_HARDCODED_DR_RD_111_x[2],     decode_cs_HARDCODED_DR_RD_111_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_DR_WR_111_mux,     1,             decode_cs_HARDCODED_DR_WR_111,     decode_cs_HARDCODED_DR_WR_111_x[0],     decode_cs_HARDCODED_DR_WR_111_x[1],     decode_cs_HARDCODED_DR_WR_111_x[2],     decode_cs_HARDCODED_DR_WR_111_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_RD_111_mux,     1,             decode_cs_HARDCODED_SR_RD_111,     decode_cs_HARDCODED_SR_RD_111_x[0],     decode_cs_HARDCODED_SR_RD_111_x[1],     decode_cs_HARDCODED_SR_RD_111_x[2],     decode_cs_HARDCODED_SR_RD_111_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_SR_WR_111_mux,     1,             decode_cs_HARDCODED_SR_WR_111,     decode_cs_HARDCODED_SR_WR_111_x[0],     decode_cs_HARDCODED_SR_WR_111_x[1],     decode_cs_HARDCODED_SR_WR_111_x[2],     decode_cs_HARDCODED_SR_WR_111_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_LD_OP_111_mux,     1,             decode_cs_HARDCODED_LD_OP_111,     decode_cs_HARDCODED_LD_OP_111_x[0],     decode_cs_HARDCODED_LD_OP_111_x[1],     decode_cs_HARDCODED_LD_OP_111_x[2],     decode_cs_HARDCODED_LD_OP_111_x[3],     num_pfs)
    `MUX_4(decode_cs_HARDCODED_ST_OP_111_mux,     1,             decode_cs_HARDCODED_ST_OP_111,     decode_cs_HARDCODED_ST_OP_111_x[0],     decode_cs_HARDCODED_ST_OP_111_x[1],     decode_cs_HARDCODED_ST_OP_111_x[2],     decode_cs_HARDCODED_ST_OP_111_x[3],     num_pfs)
    `MUX_4(decode_cs_LD_OP_CANCEL_111_mux,        1,             decode_cs_LD_OP_CANCEL_111,        decode_cs_LD_OP_CANCEL_111_x[0],        decode_cs_LD_OP_CANCEL_111_x[1],        decode_cs_LD_OP_CANCEL_111_x[2],        decode_cs_LD_OP_CANCEL_111_x[3],        num_pfs)
    `MUX_4(decode_cs_ST_OP_CANCEL_111_mux,        1,             decode_cs_ST_OP_CANCEL_111,        decode_cs_ST_OP_CANCEL_111_x[0],        decode_cs_ST_OP_CANCEL_111_x[1],        decode_cs_ST_OP_CANCEL_111_x[2],        decode_cs_ST_OP_CANCEL_111_x[3],        num_pfs)
    `MUX_4(decode_cs_OP_IN_MODRM_111_mux,         1,             decode_cs_OP_IN_MODRM_111,         decode_cs_OP_IN_MODRM_111_x[0],         decode_cs_OP_IN_MODRM_111_x[1],         decode_cs_OP_IN_MODRM_111_x[2],         decode_cs_OP_IN_MODRM_111_x[3],         num_pfs)
    `MUX_4(decode_cs_DATA_SIZE_111_mux,           2,             decode_cs_DATA_SIZE_111,           decode_cs_DATA_SIZE_111_x[0],           decode_cs_DATA_SIZE_111_x[1],           decode_cs_DATA_SIZE_111_x[2],           decode_cs_DATA_SIZE_111_x[3],           num_pfs)
    `MUX_4(rr_cs_ST_SEL_111_mux,                  1,             rr_cs_ST_SEL_111,                  rr_cs_ST_SEL_111_x[0],                  rr_cs_ST_SEL_111_x[1],                  rr_cs_ST_SEL_111_x[2],                  rr_cs_ST_SEL_111_x[3],                  num_pfs)
    `MUX_4(rr_cs_MODRM_NEEDED_111_mux,            1,             rr_cs_MODRM_NEEDED_111,            rr_cs_MODRM_NEEDED_111_x[0],            rr_cs_MODRM_NEEDED_111_x[1],            rr_cs_MODRM_NEEDED_111_x[2],            rr_cs_MODRM_NEEDED_111_x[3],            num_pfs)
    `MUX_4(rr_cs_RM_IS_DR_111_mux,                1,             rr_cs_RM_IS_DR_111,                rr_cs_RM_IS_DR_111_x[0],                rr_cs_RM_IS_DR_111_x[1],                rr_cs_RM_IS_DR_111_x[2],                rr_cs_RM_IS_DR_111_x[3],                num_pfs)
    `MUX_4(rr_cs_SWITCH_LD_ADDY_111_mux,          1,             rr_cs_SWITCH_LD_ADDY_111,          rr_cs_SWITCH_LD_ADDY_111_x[0],          rr_cs_SWITCH_LD_ADDY_111_x[1],          rr_cs_SWITCH_LD_ADDY_111_x[2],          rr_cs_SWITCH_LD_ADDY_111_x[3],          num_pfs)
    `MUX_4(rr_cs_LD_OP_111_mux,                   1,             rr_cs_LD_OP_111,                   rr_cs_LD_OP_111_x[0],                   rr_cs_LD_OP_111_x[1],                   rr_cs_LD_OP_111_x[2],                   rr_cs_LD_OP_111_x[3],                   num_pfs)
    `MUX_4(rr_cs_ST_OP_111_mux,                   1,             rr_cs_ST_OP_111,                   rr_cs_ST_OP_111_x[0],                   rr_cs_ST_OP_111_x[1],                   rr_cs_ST_OP_111_x[2],                   rr_cs_ST_OP_111_x[3],                   num_pfs)
    `MUX_4(rr_cs_dr_id_111_mux,                   `REG_ID_W,     rr_cs_dr_id_111,                   rr_cs_dr_id_111_x[0],                   rr_cs_dr_id_111_x[1],                   rr_cs_dr_id_111_x[2],                   rr_cs_dr_id_111_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_id_111_mux,                   `REG_ID_W,     rr_cs_sr_id_111,                   rr_cs_sr_id_111_x[0],                   rr_cs_sr_id_111_x[1],                   rr_cs_sr_id_111_x[2],                   rr_cs_sr_id_111_x[3],                   num_pfs)
    `MUX_4(rr_cs_dr_rd_111_mux,                   1,             rr_cs_dr_rd_111,                   rr_cs_dr_rd_111_x[0],                   rr_cs_dr_rd_111_x[1],                   rr_cs_dr_rd_111_x[2],                   rr_cs_dr_rd_111_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_rd_111_mux,                   1,             rr_cs_sr_rd_111,                   rr_cs_sr_rd_111_x[0],                   rr_cs_sr_rd_111_x[1],                   rr_cs_sr_rd_111_x[2],                   rr_cs_sr_rd_111_x[3],                   num_pfs)
    `MUX_4(rr_cs_eax_rd_111_mux,                  1,             rr_cs_eax_rd_111,                  rr_cs_eax_rd_111_x[0],                  rr_cs_eax_rd_111_x[1],                  rr_cs_eax_rd_111_x[2],                  rr_cs_eax_rd_111_x[3],                  num_pfs)
    `MUX_4(rr_cs_dr_wr_111_mux,                   1,             rr_cs_dr_wr_111,                   rr_cs_dr_wr_111_x[0],                   rr_cs_dr_wr_111_x[1],                   rr_cs_dr_wr_111_x[2],                   rr_cs_dr_wr_111_x[3],                   num_pfs)
    `MUX_4(rr_cs_sr_wr_111_mux,                   1,             rr_cs_sr_wr_111,                   rr_cs_sr_wr_111_x[0],                   rr_cs_sr_wr_111_x[1],                   rr_cs_sr_wr_111_x[2],                   rr_cs_sr_wr_111_x[3],                   num_pfs)
    `MUX_4(rr_cs_eax_wr_111_mux,                  1,             rr_cs_eax_wr_111,                  rr_cs_eax_wr_111_x[0],                  rr_cs_eax_wr_111_x[1],                  rr_cs_eax_wr_111_x[2],                  rr_cs_eax_wr_111_x[3],                  num_pfs)
    `MUX_4(rr_cs_MOVS_OP_111_mux,                 1,             rr_cs_MOVS_OP_111,                 rr_cs_MOVS_OP_111_x[0],                 rr_cs_MOVS_OP_111_x[1],                 rr_cs_MOVS_OP_111_x[2],                 rr_cs_MOVS_OP_111_x[3],                 num_pfs)
    `MUX_4(rr_cs_datasize_111_mux,                2,             rr_cs_datasize_111,                rr_cs_datasize_111_x[0],                rr_cs_datasize_111_x[1],                rr_cs_datasize_111_x[2],                rr_cs_datasize_111_x[3],                num_pfs)
    `MUX_4(rr_cs_will_mod_zf_111_mux,             1,             rr_cs_will_mod_zf_111,             rr_cs_will_mod_zf_111_x[0],             rr_cs_will_mod_zf_111_x[1],             rr_cs_will_mod_zf_111_x[2],             rr_cs_will_mod_zf_111_x[3],             num_pfs)
    `MUX_4(rr_cs_seg_1_valid_111_mux,             1,             rr_cs_seg_1_valid_111,             rr_cs_seg_1_valid_111_x[0],             rr_cs_seg_1_valid_111_x[1],             rr_cs_seg_1_valid_111_x[2],             rr_cs_seg_1_valid_111_x[3],             num_pfs)
    `MUX_4(rr_cs_seg_0_id_111_mux,                `REG_ID_W,     rr_cs_seg_0_id_111,                rr_cs_seg_0_id_111_x[0],                rr_cs_seg_0_id_111_x[1],                rr_cs_seg_0_id_111_x[2],                rr_cs_seg_0_id_111_x[3],                num_pfs)
    `MUX_4(rr_cs_seg_1_id_111_mux,                `REG_ID_W,     rr_cs_seg_1_id_111,                rr_cs_seg_1_id_111_x[0],                rr_cs_seg_1_id_111_x[1],                rr_cs_seg_1_id_111_x[2],                rr_cs_seg_1_id_111_x[3],                num_pfs)
    `MUX_4(rr_cs_special_modrm_bs_111_mux,        1,             rr_cs_special_modrm_bs_111,        rr_cs_special_modrm_bs_111_x[0],        rr_cs_special_modrm_bs_111_x[1],        rr_cs_special_modrm_bs_111_x[2],        rr_cs_special_modrm_bs_111_x[3],        num_pfs)
    `MUX_4(rr_cs_special_br_111_mux,              1,             rr_cs_special_br_111,              rr_cs_special_br_111_x[0],              rr_cs_special_br_111_x[1],              rr_cs_special_br_111_x[2],              rr_cs_special_br_111_x[3],              num_pfs)
    `MUX_4(dc_cs_LD_OP_111_mux,                   1,             dc_cs_LD_OP_111,                   dc_cs_LD_OP_111_x[0],                   dc_cs_LD_OP_111_x[1],                   dc_cs_LD_OP_111_x[2],                   dc_cs_LD_OP_111_x[3],                   num_pfs)
    `MUX_4(dc_cs_ST_OP_111_mux,                   1,             dc_cs_ST_OP_111,                   dc_cs_ST_OP_111_x[0],                   dc_cs_ST_OP_111_x[1],                   dc_cs_ST_OP_111_x[2],                   dc_cs_ST_OP_111_x[3],                   num_pfs)
    `MUX_4(dc_cs_dr_upper8_111_mux,               1,             dc_cs_dr_upper8_111,               dc_cs_dr_upper8_111_x[0],               dc_cs_dr_upper8_111_x[1],               dc_cs_dr_upper8_111_x[2],               dc_cs_dr_upper8_111_x[3],               num_pfs)
    `MUX_4(dc_cs_sr_upper8_111_mux,               1,             dc_cs_sr_upper8_111,               dc_cs_sr_upper8_111_x[0],               dc_cs_sr_upper8_111_x[1],               dc_cs_sr_upper8_111_x[2],               dc_cs_sr_upper8_111_x[3],               num_pfs)
    `MUX_4(dc_cs_datasize_111_mux,                2,             dc_cs_datasize_111,                dc_cs_datasize_111_x[0],                dc_cs_datasize_111_x[1],                dc_cs_datasize_111_x[2],                dc_cs_datasize_111_x[3],                num_pfs)
    `MUX_4(mem_cs_ST_OP_111_mux,                  1,             mem_cs_ST_OP_111,                  mem_cs_ST_OP_111_x[0],                  mem_cs_ST_OP_111_x[1],                  mem_cs_ST_OP_111_x[2],                  mem_cs_ST_OP_111_x[3],                  num_pfs)
    `MUX_4(mem_cs_LD_OP_111_mux,                  1,             mem_cs_LD_OP_111,                  mem_cs_LD_OP_111_x[0],                  mem_cs_LD_OP_111_x[1],                  mem_cs_LD_OP_111_x[2],                  mem_cs_LD_OP_111_x[3],                  num_pfs)
    `MUX_4(exe_cs_ST_OP_111_mux,                  1,             exe_cs_ST_OP_111,                  exe_cs_ST_OP_111_x[0],                  exe_cs_ST_OP_111_x[1],                  exe_cs_ST_OP_111_x[2],                  exe_cs_ST_OP_111_x[3],                  num_pfs)
    `MUX_4(exe_cs_OP_TYPE_111_mux,                `EXE_OP_W,     exe_cs_OP_TYPE_111,                exe_cs_OP_TYPE_111_x[0],                exe_cs_OP_TYPE_111_x[1],                exe_cs_OP_TYPE_111_x[2],                exe_cs_OP_TYPE_111_x[3],                num_pfs)
    `MUX_4(exe_cs_alu_inputA_sel_111_mux,         `SRC_SEL_W,    exe_cs_alu_inputA_sel_111,         exe_cs_alu_inputA_sel_111_x[0],         exe_cs_alu_inputA_sel_111_x[1],         exe_cs_alu_inputA_sel_111_x[2],         exe_cs_alu_inputA_sel_111_x[3],         num_pfs)
    `MUX_4(exe_cs_alu_inputB_sel_111_mux,         `SRC_SEL_W,    exe_cs_alu_inputB_sel_111,         exe_cs_alu_inputB_sel_111_x[0],         exe_cs_alu_inputB_sel_111_x[1],         exe_cs_alu_inputB_sel_111_x[2],         exe_cs_alu_inputB_sel_111_x[3],         num_pfs)
    `MUX_4(exe_cs_branch_target_sel_111_mux,      `SRC_SEL_W,    exe_cs_branch_target_sel_111,      exe_cs_branch_target_sel_111_x[0],      exe_cs_branch_target_sel_111_x[1],      exe_cs_branch_target_sel_111_x[2],      exe_cs_branch_target_sel_111_x[3],      num_pfs)
    `MUX_4(exe_cs_shift_by_one_111_mux,           1,             exe_cs_shift_by_one_111,           exe_cs_shift_by_one_111_x[0],           exe_cs_shift_by_one_111_x[1],           exe_cs_shift_by_one_111_x[2],           exe_cs_shift_by_one_111_x[3],           num_pfs)
    `MUX_4(exe_cs_br_ucond_111_mux,               1,             exe_cs_br_ucond_111,               exe_cs_br_ucond_111_x[0],               exe_cs_br_ucond_111_x[1],               exe_cs_br_ucond_111_x[2],               exe_cs_br_ucond_111_x[3],               num_pfs)
    `MUX_4(exe_cs_relative_branch_111_mux,        1,             exe_cs_relative_branch_111,        exe_cs_relative_branch_111_x[0],        exe_cs_relative_branch_111_x[1],        exe_cs_relative_branch_111_x[2],        exe_cs_relative_branch_111_x[3],        num_pfs)
    `MUX_4(exe_cs_special_br_111_mux,             1,             exe_cs_special_br_111,             exe_cs_special_br_111_x[0],             exe_cs_special_br_111_x[1],             exe_cs_special_br_111_x[2],             exe_cs_special_br_111_x[3],             num_pfs)
    `MUX_4(exe_cs_is_far_111_mux,                 1,             exe_cs_is_far_111,                 exe_cs_is_far_111_x[0],                 exe_cs_is_far_111_x[1],                 exe_cs_is_far_111_x[2],                 exe_cs_is_far_111_x[3],                 num_pfs)
    `MUX_4(exe_cs_is_call_111_mux,                1,             exe_cs_is_call_111,                exe_cs_is_call_111_x[0],                exe_cs_is_call_111_x[1],                exe_cs_is_call_111_x[2],                exe_cs_is_call_111_x[3],                num_pfs)
    `MUX_4(exe_cs_second_flag_needed_111_mux,     1,             exe_cs_second_flag_needed_111,     exe_cs_second_flag_needed_111_x[0],     exe_cs_second_flag_needed_111_x[1],     exe_cs_second_flag_needed_111_x[2],     exe_cs_second_flag_needed_111_x[3],     num_pfs)
    `MUX_4(exe_cs_rep_no_zf_update_111_mux,       1,             exe_cs_rep_no_zf_update_111,       exe_cs_rep_no_zf_update_111_x[0],       exe_cs_rep_no_zf_update_111_x[1],       exe_cs_rep_no_zf_update_111_x[2],       exe_cs_rep_no_zf_update_111_x[3],       num_pfs)
    `MUX_4(wb_cs_ST_OP_111_mux,                   1,             wb_cs_ST_OP_111,                   wb_cs_ST_OP_111_x[0],                   wb_cs_ST_OP_111_x[1],                   wb_cs_ST_OP_111_x[2],                   wb_cs_ST_OP_111_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_DR_111_mux,                   1,             wb_cs_WB_DR_111,                   wb_cs_WB_DR_111_x[0],                   wb_cs_WB_DR_111_x[1],                   wb_cs_WB_DR_111_x[2],                   wb_cs_WB_DR_111_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_SR_111_mux,                   1,             wb_cs_WB_SR_111,                   wb_cs_WB_SR_111_x[0],                   wb_cs_WB_SR_111_x[1],                   wb_cs_WB_SR_111_x[2],                   wb_cs_WB_SR_111_x[3],                   num_pfs)
    `MUX_4(wb_cs_WB_EAX_111_mux,                  1,             wb_cs_WB_EAX_111,                  wb_cs_WB_EAX_111_x[0],                  wb_cs_WB_EAX_111_x[1],                  wb_cs_WB_EAX_111_x[2],                  wb_cs_WB_EAX_111_x[3],                  num_pfs)


    // === Stage-2 mux: pick across yza ∈ {000..111} via {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0} ===

    `MUX_8(decode_cs_REP_final_mux,                  1,             decode_cs_REP,                  decode_cs_REP_000,                  decode_cs_REP_001,                  decode_cs_REP_010,                  decode_cs_REP_011,                  decode_cs_REP_100,                  decode_cs_REP_101,                  decode_cs_REP_110,                  decode_cs_REP_111,                  {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(decode_cs_REP_CMP_final_mux,              1,             decode_cs_REP_CMP,              decode_cs_REP_CMP_000,              decode_cs_REP_CMP_001,              decode_cs_REP_CMP_010,              decode_cs_REP_CMP_011,              decode_cs_REP_CMP_100,              decode_cs_REP_CMP_101,              decode_cs_REP_CMP_110,              decode_cs_REP_CMP_111,              {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(decode_cs_HALT_final_mux,                 1,             decode_cs_HALT,                 decode_cs_HALT_000,                 decode_cs_HALT_001,                 decode_cs_HALT_010,                 decode_cs_HALT_011,                 decode_cs_HALT_100,                 decode_cs_HALT_101,                 decode_cs_HALT_110,                 decode_cs_HALT_111,                 {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(decode_cs_MODRM_NEEDED_final_mux,         1,             decode_cs_MODRM_NEEDED,         decode_cs_MODRM_NEEDED_000,         decode_cs_MODRM_NEEDED_001,         decode_cs_MODRM_NEEDED_010,         decode_cs_MODRM_NEEDED_011,         decode_cs_MODRM_NEEDED_100,         decode_cs_MODRM_NEEDED_101,         decode_cs_MODRM_NEEDED_110,         decode_cs_MODRM_NEEDED_111,         {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(decode_cs_RM_IS_DR_final_mux,             1,             decode_cs_RM_IS_DR,             decode_cs_RM_IS_DR_000,             decode_cs_RM_IS_DR_001,             decode_cs_RM_IS_DR_010,             decode_cs_RM_IS_DR_011,             decode_cs_RM_IS_DR_100,             decode_cs_RM_IS_DR_101,             decode_cs_RM_IS_DR_110,             decode_cs_RM_IS_DR_111,             {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(decode_cs_REG_IS_DR_final_mux,            1,             decode_cs_REG_IS_DR,            decode_cs_REG_IS_DR_000,            decode_cs_REG_IS_DR_001,            decode_cs_REG_IS_DR_010,            decode_cs_REG_IS_DR_011,            decode_cs_REG_IS_DR_100,            decode_cs_REG_IS_DR_101,            decode_cs_REG_IS_DR_110,            decode_cs_REG_IS_DR_111,            {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(decode_cs_REG_IS_SEGMENT_final_mux,       1,             decode_cs_REG_IS_SEGMENT,       decode_cs_REG_IS_SEGMENT_000,       decode_cs_REG_IS_SEGMENT_001,       decode_cs_REG_IS_SEGMENT_010,       decode_cs_REG_IS_SEGMENT_011,       decode_cs_REG_IS_SEGMENT_100,       decode_cs_REG_IS_SEGMENT_101,       decode_cs_REG_IS_SEGMENT_110,       decode_cs_REG_IS_SEGMENT_111,       {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(decode_cs_HARDCODED_DR_HIGH8_final_mux,   1,             decode_cs_HARDCODED_DR_HIGH8,   decode_cs_HARDCODED_DR_HIGH8_000,   decode_cs_HARDCODED_DR_HIGH8_001,   decode_cs_HARDCODED_DR_HIGH8_010,   decode_cs_HARDCODED_DR_HIGH8_011,   decode_cs_HARDCODED_DR_HIGH8_100,   decode_cs_HARDCODED_DR_HIGH8_101,   decode_cs_HARDCODED_DR_HIGH8_110,   decode_cs_HARDCODED_DR_HIGH8_111,   {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(decode_cs_MODRM_BUT_NO_SR_final_mux,      1,             decode_cs_MODRM_BUT_NO_SR,      decode_cs_MODRM_BUT_NO_SR_000,      decode_cs_MODRM_BUT_NO_SR_001,      decode_cs_MODRM_BUT_NO_SR_010,      decode_cs_MODRM_BUT_NO_SR_011,      decode_cs_MODRM_BUT_NO_SR_100,      decode_cs_MODRM_BUT_NO_SR_101,      decode_cs_MODRM_BUT_NO_SR_110,      decode_cs_MODRM_BUT_NO_SR_111,      {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(decode_cs_HARDCODED_DR_final_mux,         1,             decode_cs_HARDCODED_DR,         decode_cs_HARDCODED_DR_000,         decode_cs_HARDCODED_DR_001,         decode_cs_HARDCODED_DR_010,         decode_cs_HARDCODED_DR_011,         decode_cs_HARDCODED_DR_100,         decode_cs_HARDCODED_DR_101,         decode_cs_HARDCODED_DR_110,         decode_cs_HARDCODED_DR_111,         {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(decode_cs_HARDCODED_DR_ID_final_mux,      `REG_ID_W,     decode_cs_HARDCODED_DR_ID,      decode_cs_HARDCODED_DR_ID_000,      decode_cs_HARDCODED_DR_ID_001,      decode_cs_HARDCODED_DR_ID_010,      decode_cs_HARDCODED_DR_ID_011,      decode_cs_HARDCODED_DR_ID_100,      decode_cs_HARDCODED_DR_ID_101,      decode_cs_HARDCODED_DR_ID_110,      decode_cs_HARDCODED_DR_ID_111,      {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(decode_cs_HARDCODED_SR_final_mux,         1,             decode_cs_HARDCODED_SR,         decode_cs_HARDCODED_SR_000,         decode_cs_HARDCODED_SR_001,         decode_cs_HARDCODED_SR_010,         decode_cs_HARDCODED_SR_011,         decode_cs_HARDCODED_SR_100,         decode_cs_HARDCODED_SR_101,         decode_cs_HARDCODED_SR_110,         decode_cs_HARDCODED_SR_111,         {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(decode_cs_HARDCODED_SR_ID_final_mux,      `REG_ID_W,     decode_cs_HARDCODED_SR_ID,      decode_cs_HARDCODED_SR_ID_000,      decode_cs_HARDCODED_SR_ID_001,      decode_cs_HARDCODED_SR_ID_010,      decode_cs_HARDCODED_SR_ID_011,      decode_cs_HARDCODED_SR_ID_100,      decode_cs_HARDCODED_SR_ID_101,      decode_cs_HARDCODED_SR_ID_110,      decode_cs_HARDCODED_SR_ID_111,      {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(decode_cs_HARDCODED_DR_RD_final_mux,      1,             decode_cs_HARDCODED_DR_RD,      decode_cs_HARDCODED_DR_RD_000,      decode_cs_HARDCODED_DR_RD_001,      decode_cs_HARDCODED_DR_RD_010,      decode_cs_HARDCODED_DR_RD_011,      decode_cs_HARDCODED_DR_RD_100,      decode_cs_HARDCODED_DR_RD_101,      decode_cs_HARDCODED_DR_RD_110,      decode_cs_HARDCODED_DR_RD_111,      {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(decode_cs_HARDCODED_DR_WR_final_mux,      1,             decode_cs_HARDCODED_DR_WR,      decode_cs_HARDCODED_DR_WR_000,      decode_cs_HARDCODED_DR_WR_001,      decode_cs_HARDCODED_DR_WR_010,      decode_cs_HARDCODED_DR_WR_011,      decode_cs_HARDCODED_DR_WR_100,      decode_cs_HARDCODED_DR_WR_101,      decode_cs_HARDCODED_DR_WR_110,      decode_cs_HARDCODED_DR_WR_111,      {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(decode_cs_HARDCODED_SR_RD_final_mux,      1,             decode_cs_HARDCODED_SR_RD,      decode_cs_HARDCODED_SR_RD_000,      decode_cs_HARDCODED_SR_RD_001,      decode_cs_HARDCODED_SR_RD_010,      decode_cs_HARDCODED_SR_RD_011,      decode_cs_HARDCODED_SR_RD_100,      decode_cs_HARDCODED_SR_RD_101,      decode_cs_HARDCODED_SR_RD_110,      decode_cs_HARDCODED_SR_RD_111,      {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(decode_cs_HARDCODED_SR_WR_final_mux,      1,             decode_cs_HARDCODED_SR_WR,      decode_cs_HARDCODED_SR_WR_000,      decode_cs_HARDCODED_SR_WR_001,      decode_cs_HARDCODED_SR_WR_010,      decode_cs_HARDCODED_SR_WR_011,      decode_cs_HARDCODED_SR_WR_100,      decode_cs_HARDCODED_SR_WR_101,      decode_cs_HARDCODED_SR_WR_110,      decode_cs_HARDCODED_SR_WR_111,      {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(decode_cs_HARDCODED_LD_OP_final_mux,      1,             decode_cs_HARDCODED_LD_OP,      decode_cs_HARDCODED_LD_OP_000,      decode_cs_HARDCODED_LD_OP_001,      decode_cs_HARDCODED_LD_OP_010,      decode_cs_HARDCODED_LD_OP_011,      decode_cs_HARDCODED_LD_OP_100,      decode_cs_HARDCODED_LD_OP_101,      decode_cs_HARDCODED_LD_OP_110,      decode_cs_HARDCODED_LD_OP_111,      {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(decode_cs_HARDCODED_ST_OP_final_mux,      1,             decode_cs_HARDCODED_ST_OP,      decode_cs_HARDCODED_ST_OP_000,      decode_cs_HARDCODED_ST_OP_001,      decode_cs_HARDCODED_ST_OP_010,      decode_cs_HARDCODED_ST_OP_011,      decode_cs_HARDCODED_ST_OP_100,      decode_cs_HARDCODED_ST_OP_101,      decode_cs_HARDCODED_ST_OP_110,      decode_cs_HARDCODED_ST_OP_111,      {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(decode_cs_LD_OP_CANCEL_final_mux,         1,             decode_cs_LD_OP_CANCEL,         decode_cs_LD_OP_CANCEL_000,         decode_cs_LD_OP_CANCEL_001,         decode_cs_LD_OP_CANCEL_010,         decode_cs_LD_OP_CANCEL_011,         decode_cs_LD_OP_CANCEL_100,         decode_cs_LD_OP_CANCEL_101,         decode_cs_LD_OP_CANCEL_110,         decode_cs_LD_OP_CANCEL_111,         {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(decode_cs_ST_OP_CANCEL_final_mux,         1,             decode_cs_ST_OP_CANCEL,         decode_cs_ST_OP_CANCEL_000,         decode_cs_ST_OP_CANCEL_001,         decode_cs_ST_OP_CANCEL_010,         decode_cs_ST_OP_CANCEL_011,         decode_cs_ST_OP_CANCEL_100,         decode_cs_ST_OP_CANCEL_101,         decode_cs_ST_OP_CANCEL_110,         decode_cs_ST_OP_CANCEL_111,         {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(decode_cs_OP_IN_MODRM_final_mux,          1,             decode_cs_OP_IN_MODRM,          decode_cs_OP_IN_MODRM_000,          decode_cs_OP_IN_MODRM_001,          decode_cs_OP_IN_MODRM_010,          decode_cs_OP_IN_MODRM_011,          decode_cs_OP_IN_MODRM_100,          decode_cs_OP_IN_MODRM_101,          decode_cs_OP_IN_MODRM_110,          decode_cs_OP_IN_MODRM_111,          {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(decode_cs_DATA_SIZE_final_mux,            2,             decode_cs_DATA_SIZE,            decode_cs_DATA_SIZE_000,            decode_cs_DATA_SIZE_001,            decode_cs_DATA_SIZE_010,            decode_cs_DATA_SIZE_011,            decode_cs_DATA_SIZE_100,            decode_cs_DATA_SIZE_101,            decode_cs_DATA_SIZE_110,            decode_cs_DATA_SIZE_111,            {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})

    `MUX_8(rr_cs_ST_SEL_final_mux,                   1,             rr_cs_ST_SEL,                   rr_cs_ST_SEL_000,                   rr_cs_ST_SEL_001,                   rr_cs_ST_SEL_010,                   rr_cs_ST_SEL_011,                   rr_cs_ST_SEL_100,                   rr_cs_ST_SEL_101,                   rr_cs_ST_SEL_110,                   rr_cs_ST_SEL_111,                   {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(rr_cs_MODRM_NEEDED_final_mux,             1,             rr_cs_MODRM_NEEDED,             rr_cs_MODRM_NEEDED_000,             rr_cs_MODRM_NEEDED_001,             rr_cs_MODRM_NEEDED_010,             rr_cs_MODRM_NEEDED_011,             rr_cs_MODRM_NEEDED_100,             rr_cs_MODRM_NEEDED_101,             rr_cs_MODRM_NEEDED_110,             rr_cs_MODRM_NEEDED_111,             {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(rr_cs_RM_IS_DR_final_mux,                 1,             rr_cs_RM_IS_DR,                 rr_cs_RM_IS_DR_000,                 rr_cs_RM_IS_DR_001,                 rr_cs_RM_IS_DR_010,                 rr_cs_RM_IS_DR_011,                 rr_cs_RM_IS_DR_100,                 rr_cs_RM_IS_DR_101,                 rr_cs_RM_IS_DR_110,                 rr_cs_RM_IS_DR_111,                 {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(rr_cs_SWITCH_LD_ADDY_final_mux,           1,             rr_cs_SWITCH_LD_ADDY,           rr_cs_SWITCH_LD_ADDY_000,           rr_cs_SWITCH_LD_ADDY_001,           rr_cs_SWITCH_LD_ADDY_010,           rr_cs_SWITCH_LD_ADDY_011,           rr_cs_SWITCH_LD_ADDY_100,           rr_cs_SWITCH_LD_ADDY_101,           rr_cs_SWITCH_LD_ADDY_110,           rr_cs_SWITCH_LD_ADDY_111,           {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(rr_cs_LD_OP_final_mux,                    1,             rr_cs_LD_OP,                    rr_cs_LD_OP_000,                    rr_cs_LD_OP_001,                    rr_cs_LD_OP_010,                    rr_cs_LD_OP_011,                    rr_cs_LD_OP_100,                    rr_cs_LD_OP_101,                    rr_cs_LD_OP_110,                    rr_cs_LD_OP_111,                    {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(rr_cs_ST_OP_final_mux,                    1,             rr_cs_ST_OP,                    rr_cs_ST_OP_000,                    rr_cs_ST_OP_001,                    rr_cs_ST_OP_010,                    rr_cs_ST_OP_011,                    rr_cs_ST_OP_100,                    rr_cs_ST_OP_101,                    rr_cs_ST_OP_110,                    rr_cs_ST_OP_111,                    {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(rr_cs_dr_id_final_mux,                    `REG_ID_W,     rr_cs_dr_id,                    rr_cs_dr_id_000,                    rr_cs_dr_id_001,                    rr_cs_dr_id_010,                    rr_cs_dr_id_011,                    rr_cs_dr_id_100,                    rr_cs_dr_id_101,                    rr_cs_dr_id_110,                    rr_cs_dr_id_111,                    {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(rr_cs_sr_id_final_mux,                    `REG_ID_W,     rr_cs_sr_id,                    rr_cs_sr_id_000,                    rr_cs_sr_id_001,                    rr_cs_sr_id_010,                    rr_cs_sr_id_011,                    rr_cs_sr_id_100,                    rr_cs_sr_id_101,                    rr_cs_sr_id_110,                    rr_cs_sr_id_111,                    {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(rr_cs_dr_rd_final_mux,                    1,             rr_cs_dr_rd,                    rr_cs_dr_rd_000,                    rr_cs_dr_rd_001,                    rr_cs_dr_rd_010,                    rr_cs_dr_rd_011,                    rr_cs_dr_rd_100,                    rr_cs_dr_rd_101,                    rr_cs_dr_rd_110,                    rr_cs_dr_rd_111,                    {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(rr_cs_sr_rd_final_mux,                    1,             rr_cs_sr_rd,                    rr_cs_sr_rd_000,                    rr_cs_sr_rd_001,                    rr_cs_sr_rd_010,                    rr_cs_sr_rd_011,                    rr_cs_sr_rd_100,                    rr_cs_sr_rd_101,                    rr_cs_sr_rd_110,                    rr_cs_sr_rd_111,                    {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(rr_cs_eax_rd_final_mux,                   1,             rr_cs_eax_rd,                   rr_cs_eax_rd_000,                   rr_cs_eax_rd_001,                   rr_cs_eax_rd_010,                   rr_cs_eax_rd_011,                   rr_cs_eax_rd_100,                   rr_cs_eax_rd_101,                   rr_cs_eax_rd_110,                   rr_cs_eax_rd_111,                   {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(rr_cs_dr_wr_final_mux,                    1,             rr_cs_dr_wr,                    rr_cs_dr_wr_000,                    rr_cs_dr_wr_001,                    rr_cs_dr_wr_010,                    rr_cs_dr_wr_011,                    rr_cs_dr_wr_100,                    rr_cs_dr_wr_101,                    rr_cs_dr_wr_110,                    rr_cs_dr_wr_111,                    {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(rr_cs_sr_wr_final_mux,                    1,             rr_cs_sr_wr,                    rr_cs_sr_wr_000,                    rr_cs_sr_wr_001,                    rr_cs_sr_wr_010,                    rr_cs_sr_wr_011,                    rr_cs_sr_wr_100,                    rr_cs_sr_wr_101,                    rr_cs_sr_wr_110,                    rr_cs_sr_wr_111,                    {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(rr_cs_eax_wr_final_mux,                   1,             rr_cs_eax_wr,                   rr_cs_eax_wr_000,                   rr_cs_eax_wr_001,                   rr_cs_eax_wr_010,                   rr_cs_eax_wr_011,                   rr_cs_eax_wr_100,                   rr_cs_eax_wr_101,                   rr_cs_eax_wr_110,                   rr_cs_eax_wr_111,                   {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(rr_cs_MOVS_OP_final_mux,                  1,             rr_cs_MOVS_OP,                  rr_cs_MOVS_OP_000,                  rr_cs_MOVS_OP_001,                  rr_cs_MOVS_OP_010,                  rr_cs_MOVS_OP_011,                  rr_cs_MOVS_OP_100,                  rr_cs_MOVS_OP_101,                  rr_cs_MOVS_OP_110,                  rr_cs_MOVS_OP_111,                  {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(rr_cs_datasize_final_mux,                 2,             rr_cs_datasize,                 rr_cs_datasize_000,                 rr_cs_datasize_001,                 rr_cs_datasize_010,                 rr_cs_datasize_011,                 rr_cs_datasize_100,                 rr_cs_datasize_101,                 rr_cs_datasize_110,                 rr_cs_datasize_111,                 {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(rr_cs_will_mod_zf_final_mux,              1,             rr_cs_will_mod_zf,              rr_cs_will_mod_zf_000,              rr_cs_will_mod_zf_001,              rr_cs_will_mod_zf_010,              rr_cs_will_mod_zf_011,              rr_cs_will_mod_zf_100,              rr_cs_will_mod_zf_101,              rr_cs_will_mod_zf_110,              rr_cs_will_mod_zf_111,              {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(rr_cs_seg_1_valid_final_mux,              1,             rr_cs_seg_1_valid,              rr_cs_seg_1_valid_000,              rr_cs_seg_1_valid_001,              rr_cs_seg_1_valid_010,              rr_cs_seg_1_valid_011,              rr_cs_seg_1_valid_100,              rr_cs_seg_1_valid_101,              rr_cs_seg_1_valid_110,              rr_cs_seg_1_valid_111,              {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(rr_cs_seg_0_id_final_mux,                 `REG_ID_W,     rr_cs_seg_0_id,                 rr_cs_seg_0_id_000,                 rr_cs_seg_0_id_001,                 rr_cs_seg_0_id_010,                 rr_cs_seg_0_id_011,                 rr_cs_seg_0_id_100,                 rr_cs_seg_0_id_101,                 rr_cs_seg_0_id_110,                 rr_cs_seg_0_id_111,                 {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(rr_cs_seg_1_id_final_mux,                 `REG_ID_W,     rr_cs_seg_1_id,                 rr_cs_seg_1_id_000,                 rr_cs_seg_1_id_001,                 rr_cs_seg_1_id_010,                 rr_cs_seg_1_id_011,                 rr_cs_seg_1_id_100,                 rr_cs_seg_1_id_101,                 rr_cs_seg_1_id_110,                 rr_cs_seg_1_id_111,                 {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(rr_cs_special_modrm_bs_final_mux,         1,             rr_cs_special_modrm_bs,         rr_cs_special_modrm_bs_000,         rr_cs_special_modrm_bs_001,         rr_cs_special_modrm_bs_010,         rr_cs_special_modrm_bs_011,         rr_cs_special_modrm_bs_100,         rr_cs_special_modrm_bs_101,         rr_cs_special_modrm_bs_110,         rr_cs_special_modrm_bs_111,         {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(rr_cs_special_br_final_mux,               1,             rr_cs_special_br,               rr_cs_special_br_000,               rr_cs_special_br_001,               rr_cs_special_br_010,               rr_cs_special_br_011,               rr_cs_special_br_100,               rr_cs_special_br_101,               rr_cs_special_br_110,               rr_cs_special_br_111,               {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})

    `MUX_8(dc_cs_LD_OP_final_mux,                    1,             dc_cs_LD_OP,                    dc_cs_LD_OP_000,                    dc_cs_LD_OP_001,                    dc_cs_LD_OP_010,                    dc_cs_LD_OP_011,                    dc_cs_LD_OP_100,                    dc_cs_LD_OP_101,                    dc_cs_LD_OP_110,                    dc_cs_LD_OP_111,                    {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(dc_cs_ST_OP_final_mux,                    1,             dc_cs_ST_OP,                    dc_cs_ST_OP_000,                    dc_cs_ST_OP_001,                    dc_cs_ST_OP_010,                    dc_cs_ST_OP_011,                    dc_cs_ST_OP_100,                    dc_cs_ST_OP_101,                    dc_cs_ST_OP_110,                    dc_cs_ST_OP_111,                    {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(dc_cs_dr_upper8_final_mux,                1,             dc_cs_dr_upper8,                dc_cs_dr_upper8_000,                dc_cs_dr_upper8_001,                dc_cs_dr_upper8_010,                dc_cs_dr_upper8_011,                dc_cs_dr_upper8_100,                dc_cs_dr_upper8_101,                dc_cs_dr_upper8_110,                dc_cs_dr_upper8_111,                {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(dc_cs_sr_upper8_final_mux,                1,             dc_cs_sr_upper8,                dc_cs_sr_upper8_000,                dc_cs_sr_upper8_001,                dc_cs_sr_upper8_010,                dc_cs_sr_upper8_011,                dc_cs_sr_upper8_100,                dc_cs_sr_upper8_101,                dc_cs_sr_upper8_110,                dc_cs_sr_upper8_111,                {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(dc_cs_datasize_final_mux,                 2,             dc_cs_datasize,                 dc_cs_datasize_000,                 dc_cs_datasize_001,                 dc_cs_datasize_010,                 dc_cs_datasize_011,                 dc_cs_datasize_100,                 dc_cs_datasize_101,                 dc_cs_datasize_110,                 dc_cs_datasize_111,                 {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})

    `MUX_8(mem_cs_ST_OP_final_mux,                   1,             mem_cs_ST_OP,                   mem_cs_ST_OP_000,                   mem_cs_ST_OP_001,                   mem_cs_ST_OP_010,                   mem_cs_ST_OP_011,                   mem_cs_ST_OP_100,                   mem_cs_ST_OP_101,                   mem_cs_ST_OP_110,                   mem_cs_ST_OP_111,                   {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(mem_cs_LD_OP_final_mux,                   1,             mem_cs_LD_OP,                   mem_cs_LD_OP_000,                   mem_cs_LD_OP_001,                   mem_cs_LD_OP_010,                   mem_cs_LD_OP_011,                   mem_cs_LD_OP_100,                   mem_cs_LD_OP_101,                   mem_cs_LD_OP_110,                   mem_cs_LD_OP_111,                   {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})

    `MUX_8(exe_cs_ST_OP_final_mux,                   1,             exe_cs_ST_OP,                   exe_cs_ST_OP_000,                   exe_cs_ST_OP_001,                   exe_cs_ST_OP_010,                   exe_cs_ST_OP_011,                   exe_cs_ST_OP_100,                   exe_cs_ST_OP_101,                   exe_cs_ST_OP_110,                   exe_cs_ST_OP_111,                   {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(exe_cs_OP_TYPE_final_mux,                 `EXE_OP_W,     exe_cs_OP_TYPE,                 exe_cs_OP_TYPE_000,                 exe_cs_OP_TYPE_001,                 exe_cs_OP_TYPE_010,                 exe_cs_OP_TYPE_011,                 exe_cs_OP_TYPE_100,                 exe_cs_OP_TYPE_101,                 exe_cs_OP_TYPE_110,                 exe_cs_OP_TYPE_111,                 {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(exe_cs_alu_inputA_sel_final_mux,          `SRC_SEL_W,    exe_cs_alu_inputA_sel,          exe_cs_alu_inputA_sel_000,          exe_cs_alu_inputA_sel_001,          exe_cs_alu_inputA_sel_010,          exe_cs_alu_inputA_sel_011,          exe_cs_alu_inputA_sel_100,          exe_cs_alu_inputA_sel_101,          exe_cs_alu_inputA_sel_110,          exe_cs_alu_inputA_sel_111,          {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(exe_cs_alu_inputB_sel_final_mux,          `SRC_SEL_W,    exe_cs_alu_inputB_sel,          exe_cs_alu_inputB_sel_000,          exe_cs_alu_inputB_sel_001,          exe_cs_alu_inputB_sel_010,          exe_cs_alu_inputB_sel_011,          exe_cs_alu_inputB_sel_100,          exe_cs_alu_inputB_sel_101,          exe_cs_alu_inputB_sel_110,          exe_cs_alu_inputB_sel_111,          {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(exe_cs_branch_target_sel_final_mux,       `SRC_SEL_W,    exe_cs_branch_target_sel,       exe_cs_branch_target_sel_000,       exe_cs_branch_target_sel_001,       exe_cs_branch_target_sel_010,       exe_cs_branch_target_sel_011,       exe_cs_branch_target_sel_100,       exe_cs_branch_target_sel_101,       exe_cs_branch_target_sel_110,       exe_cs_branch_target_sel_111,       {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(exe_cs_shift_by_one_final_mux,            1,             exe_cs_shift_by_one,            exe_cs_shift_by_one_000,            exe_cs_shift_by_one_001,            exe_cs_shift_by_one_010,            exe_cs_shift_by_one_011,            exe_cs_shift_by_one_100,            exe_cs_shift_by_one_101,            exe_cs_shift_by_one_110,            exe_cs_shift_by_one_111,            {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(exe_cs_br_ucond_final_mux,                1,             exe_cs_br_ucond,                exe_cs_br_ucond_000,                exe_cs_br_ucond_001,                exe_cs_br_ucond_010,                exe_cs_br_ucond_011,                exe_cs_br_ucond_100,                exe_cs_br_ucond_101,                exe_cs_br_ucond_110,                exe_cs_br_ucond_111,                {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(exe_cs_relative_branch_final_mux,         1,             exe_cs_relative_branch,         exe_cs_relative_branch_000,         exe_cs_relative_branch_001,         exe_cs_relative_branch_010,         exe_cs_relative_branch_011,         exe_cs_relative_branch_100,         exe_cs_relative_branch_101,         exe_cs_relative_branch_110,         exe_cs_relative_branch_111,         {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(exe_cs_special_br_final_mux,              1,             exe_cs_special_br,              exe_cs_special_br_000,              exe_cs_special_br_001,              exe_cs_special_br_010,              exe_cs_special_br_011,              exe_cs_special_br_100,              exe_cs_special_br_101,              exe_cs_special_br_110,              exe_cs_special_br_111,              {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(exe_cs_is_far_final_mux,                  1,             exe_cs_is_far,                  exe_cs_is_far_000,                  exe_cs_is_far_001,                  exe_cs_is_far_010,                  exe_cs_is_far_011,                  exe_cs_is_far_100,                  exe_cs_is_far_101,                  exe_cs_is_far_110,                  exe_cs_is_far_111,                  {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(exe_cs_is_call_final_mux,                 1,             exe_cs_is_call,                 exe_cs_is_call_000,                 exe_cs_is_call_001,                 exe_cs_is_call_010,                 exe_cs_is_call_011,                 exe_cs_is_call_100,                 exe_cs_is_call_101,                 exe_cs_is_call_110,                 exe_cs_is_call_111,                 {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(exe_cs_second_flag_needed_final_mux,      1,             exe_cs_second_flag_needed,      exe_cs_second_flag_needed_000,      exe_cs_second_flag_needed_001,      exe_cs_second_flag_needed_010,      exe_cs_second_flag_needed_011,      exe_cs_second_flag_needed_100,      exe_cs_second_flag_needed_101,      exe_cs_second_flag_needed_110,      exe_cs_second_flag_needed_111,      {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(exe_cs_rep_no_zf_update_final_mux,        1,             exe_cs_rep_no_zf_update,        exe_cs_rep_no_zf_update_000,        exe_cs_rep_no_zf_update_001,        exe_cs_rep_no_zf_update_010,        exe_cs_rep_no_zf_update_011,        exe_cs_rep_no_zf_update_100,        exe_cs_rep_no_zf_update_101,        exe_cs_rep_no_zf_update_110,        exe_cs_rep_no_zf_update_111,        {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})

    `MUX_8(wb_cs_ST_OP_final_mux,                    1,             wb_cs_ST_OP,                    wb_cs_ST_OP_000,                    wb_cs_ST_OP_001,                    wb_cs_ST_OP_010,                    wb_cs_ST_OP_011,                    wb_cs_ST_OP_100,                    wb_cs_ST_OP_101,                    wb_cs_ST_OP_110,                    wb_cs_ST_OP_111,                    {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(wb_cs_WB_DR_final_mux,                    1,             wb_cs_WB_DR,                    wb_cs_WB_DR_000,                    wb_cs_WB_DR_001,                    wb_cs_WB_DR_010,                    wb_cs_WB_DR_011,                    wb_cs_WB_DR_100,                    wb_cs_WB_DR_101,                    wb_cs_WB_DR_110,                    wb_cs_WB_DR_111,                    {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(wb_cs_WB_SR_final_mux,                    1,             wb_cs_WB_SR,                    wb_cs_WB_SR_000,                    wb_cs_WB_SR_001,                    wb_cs_WB_SR_010,                    wb_cs_WB_SR_011,                    wb_cs_WB_SR_100,                    wb_cs_WB_SR_101,                    wb_cs_WB_SR_110,                    wb_cs_WB_SR_111,                    {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})
    `MUX_8(wb_cs_WB_EAX_final_mux,                   1,             wb_cs_WB_EAX,                   wb_cs_WB_EAX_000,                   wb_cs_WB_EAX_001,                   wb_cs_WB_EAX_010,                   wb_cs_WB_EAX_011,                   wb_cs_WB_EAX_100,                   wb_cs_WB_EAX_101,                   wb_cs_WB_EAX_110,                   wb_cs_WB_EAX_111,                   {total_pf_vector_3, total_pf_vector_1, total_pf_vector_0})

endmodule
