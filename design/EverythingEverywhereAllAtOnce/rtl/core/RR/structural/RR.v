// RR.v
//
// Pure Verilog-2005 top of the register-read stage. Same internal
// structure as RR.sv (kept on disk as the SV reference) but with all
// SV-only constructs removed:
//   * No `import` of any package.
//   * No struct or typedef ports -- rr_latches_t (normal_latches and
//     rep_latches), fetch_outputs_t, decode_outputs_t, dc_outputs_t,
//     mem_outputs_t, exe_outputs_t, wb_outputs_t, dc_latches_t,
//     rr_outputs_t are all unrolled into individual flat wires whose
//     widths come from the field types.
//   * regFileValues[NUM_REGS] is split into 26 named 64-bit wires.
//   * No struct literals; no enum casts.
//   * `bool`/`logic`/`uint*_t` -> `wire [W-1:0]`.
//   * Internal regfile_output_t replaced with the unrolled RegFile
//     wires that the structural RegFile already exposes.
//
// SEGMENT_LIMITS[NUM_SEG_REGS] kept as 7 individual undriven 32-bit
// wires (one per seg-limit-id) -- matches the SV's behavior, where
// SEGMENT_LIMITS is declared but never assigned in the body.

module RR (
    input  wire         clk,
    input  wire         rst,

    // ====================================================================
    // rr_latches_t (latches_i) -- normal_latches and rep_latches fully
    // unrolled (rr_latches_general_t).
    // ====================================================================
    input  wire         latches_normal_latches_valid,

    input  wire         latches_normal_latches_cs_ST_SEL,
    input  wire         latches_normal_latches_cs_MODRM_NEEDED,
    input  wire         latches_normal_latches_cs_RM_IS_DR,
    input  wire         latches_normal_latches_cs_SWITCH_LD_ADDY,
    input  wire         latches_normal_latches_cs_LD_OP,
    input  wire         latches_normal_latches_cs_ST_OP,
    input  wire [`REG_ID_W-1:0] latches_normal_latches_cs_dr_id,
    input  wire [`REG_ID_W-1:0] latches_normal_latches_cs_sr_id,
    input  wire         latches_normal_latches_cs_dr_rd,
    input  wire         latches_normal_latches_cs_sr_rd,
    input  wire         latches_normal_latches_cs_eax_rd,
    input  wire         latches_normal_latches_cs_dr_wr,
    input  wire         latches_normal_latches_cs_sr_wr,
    input  wire         latches_normal_latches_cs_eax_wr,
    input  wire         latches_normal_latches_cs_MOVS_OP,
    input  wire [1:0]   latches_normal_latches_cs_datasize,
    input  wire         latches_normal_latches_cs_will_mod_zf,
    input  wire         latches_normal_latches_cs_seg_1_valid,
    input  wire [`REG_ID_W-1:0] latches_normal_latches_cs_seg_0_id,
    input  wire [`REG_ID_W-1:0] latches_normal_latches_cs_seg_1_id,
    input  wire         latches_normal_latches_cs_special_modrm_bs,
    input  wire         latches_normal_latches_cs_special_br,

    input  wire         latches_normal_latches_dc_cs_LD_OP,
    input  wire         latches_normal_latches_dc_cs_ST_OP,
    input  wire         latches_normal_latches_dc_cs_dr_upper8,
    input  wire         latches_normal_latches_dc_cs_sr_upper8,
    input  wire [1:0]   latches_normal_latches_dc_cs_datasize,

    input  wire         latches_normal_latches_mem_cs_ST_OP,
    input  wire         latches_normal_latches_mem_cs_LD_OP,

    input  wire         latches_normal_latches_exe_cs_ST_OP,
    input  wire [`EXE_OP_W-1:0]  latches_normal_latches_exe_cs_OP_TYPE,
    input  wire [`SRC_SEL_W-1:0] latches_normal_latches_exe_cs_alu_inputA_sel,
    input  wire [`SRC_SEL_W-1:0] latches_normal_latches_exe_cs_alu_inputB_sel,
    input  wire [`SRC_SEL_W-1:0] latches_normal_latches_exe_cs_branch_target_sel,
    input  wire         latches_normal_latches_exe_cs_shift_by_one,
    input  wire         latches_normal_latches_exe_cs_br_ucond,
    input  wire         latches_normal_latches_exe_cs_relative_branch,
    input  wire         latches_normal_latches_exe_cs_special_br,
    input  wire         latches_normal_latches_exe_cs_is_far,
    input  wire         latches_normal_latches_exe_cs_is_call,
    input  wire         latches_normal_latches_exe_cs_second_flag_needed,
    input  wire         latches_normal_latches_exe_cs_rep_no_zf_update,

    input  wire         latches_normal_latches_wb_cs_ST_OP,
    input  wire         latches_normal_latches_wb_cs_WB_DR,
    input  wire         latches_normal_latches_wb_cs_WB_SR,
    input  wire         latches_normal_latches_wb_cs_WB_EAX,

    input  wire         latches_normal_latches_br_info_valid,
    input  wire [31:0]  latches_normal_latches_br_info_br_eip,
    input  wire         latches_normal_latches_br_info_br_xcl,
    input  wire         latches_normal_latches_br_info_br_pred_taken,
    input  wire [31:0]  latches_normal_latches_br_info_speculative_target,

    input  wire [31:0]  latches_normal_latches_NEIP,
    input  wire [31:0]  latches_normal_latches_EIP,
    input  wire [31:0]  latches_normal_latches_EAX,
    input  wire [63:0]  latches_normal_latches_imm64,
    input  wire [`REG_ID_W-1:0] latches_normal_latches_sib_idx_id,
    input  wire [`REG_ID_W-1:0] latches_normal_latches_sib_base_id,
    input  wire         latches_normal_latches_sib_needed,
    input  wire [7:0]   latches_normal_latches_sib_scale,
    input  wire         latches_normal_latches_disp_needed,
    input  wire         latches_normal_latches_disp_size,
    input  wire [31:0]  latches_normal_latches_displacement,

    input  wire         latches_rep_latches_valid,

    input  wire         latches_rep_latches_cs_ST_SEL,
    input  wire         latches_rep_latches_cs_MODRM_NEEDED,
    input  wire         latches_rep_latches_cs_RM_IS_DR,
    input  wire         latches_rep_latches_cs_SWITCH_LD_ADDY,
    input  wire         latches_rep_latches_cs_LD_OP,
    input  wire         latches_rep_latches_cs_ST_OP,
    input  wire [`REG_ID_W-1:0] latches_rep_latches_cs_dr_id,
    input  wire [`REG_ID_W-1:0] latches_rep_latches_cs_sr_id,
    input  wire         latches_rep_latches_cs_dr_rd,
    input  wire         latches_rep_latches_cs_sr_rd,
    input  wire         latches_rep_latches_cs_eax_rd,
    input  wire         latches_rep_latches_cs_dr_wr,
    input  wire         latches_rep_latches_cs_sr_wr,
    input  wire         latches_rep_latches_cs_eax_wr,
    input  wire         latches_rep_latches_cs_MOVS_OP,
    input  wire [1:0]   latches_rep_latches_cs_datasize,
    input  wire         latches_rep_latches_cs_will_mod_zf,
    input  wire         latches_rep_latches_cs_seg_1_valid,
    input  wire [`REG_ID_W-1:0] latches_rep_latches_cs_seg_0_id,
    input  wire [`REG_ID_W-1:0] latches_rep_latches_cs_seg_1_id,
    input  wire         latches_rep_latches_cs_special_modrm_bs,
    input  wire         latches_rep_latches_cs_special_br,

    input  wire         latches_rep_latches_dc_cs_LD_OP,
    input  wire         latches_rep_latches_dc_cs_ST_OP,
    input  wire         latches_rep_latches_dc_cs_dr_upper8,
    input  wire         latches_rep_latches_dc_cs_sr_upper8,
    input  wire [1:0]   latches_rep_latches_dc_cs_datasize,

    input  wire         latches_rep_latches_mem_cs_ST_OP,
    input  wire         latches_rep_latches_mem_cs_LD_OP,

    input  wire         latches_rep_latches_exe_cs_ST_OP,
    input  wire [`EXE_OP_W-1:0]  latches_rep_latches_exe_cs_OP_TYPE,
    input  wire [`SRC_SEL_W-1:0] latches_rep_latches_exe_cs_alu_inputA_sel,
    input  wire [`SRC_SEL_W-1:0] latches_rep_latches_exe_cs_alu_inputB_sel,
    input  wire [`SRC_SEL_W-1:0] latches_rep_latches_exe_cs_branch_target_sel,
    input  wire         latches_rep_latches_exe_cs_shift_by_one,
    input  wire         latches_rep_latches_exe_cs_br_ucond,
    input  wire         latches_rep_latches_exe_cs_relative_branch,
    input  wire         latches_rep_latches_exe_cs_special_br,
    input  wire         latches_rep_latches_exe_cs_is_far,
    input  wire         latches_rep_latches_exe_cs_is_call,
    input  wire         latches_rep_latches_exe_cs_second_flag_needed,
    input  wire         latches_rep_latches_exe_cs_rep_no_zf_update,

    input  wire         latches_rep_latches_wb_cs_ST_OP,
    input  wire         latches_rep_latches_wb_cs_WB_DR,
    input  wire         latches_rep_latches_wb_cs_WB_SR,
    input  wire         latches_rep_latches_wb_cs_WB_EAX,

    input  wire         latches_rep_latches_br_info_valid,
    input  wire [31:0]  latches_rep_latches_br_info_br_eip,
    input  wire         latches_rep_latches_br_info_br_xcl,
    input  wire         latches_rep_latches_br_info_br_pred_taken,
    input  wire [31:0]  latches_rep_latches_br_info_speculative_target,

    input  wire [31:0]  latches_rep_latches_NEIP,
    input  wire [31:0]  latches_rep_latches_EIP,
    input  wire [31:0]  latches_rep_latches_EAX,
    input  wire [63:0]  latches_rep_latches_imm64,
    input  wire [`REG_ID_W-1:0] latches_rep_latches_sib_idx_id,
    input  wire [`REG_ID_W-1:0] latches_rep_latches_sib_base_id,
    input  wire         latches_rep_latches_sib_needed,
    input  wire [7:0]   latches_rep_latches_sib_scale,
    input  wire         latches_rep_latches_disp_needed,
    input  wire         latches_rep_latches_disp_size,
    input  wire [31:0]  latches_rep_latches_displacement,

    // ====================================================================
    // fetch_outputs_t (fetch_outs_i) -- only exp_pipe_clear consumed
    // ====================================================================
    input  wire         fetch_outs_exp_pipe_clear,

    // ====================================================================
    // decode_outputs_t (decode_outs_i) -- only consumed fields exposed
    // ====================================================================
    input  wire         decode_outs_decode_gp,
    input  wire         decode_outs_rep_latch,

    // ====================================================================
    // dc_outputs_t (dc_outs_i)
    // ====================================================================
    input  wire         dc_outs_valid,
    input  wire         dc_outs_stall,

    // ====================================================================
    // mem_outputs_t (mem_outs_i)
    // ====================================================================
    input  wire         mem_outs_valid,
    input  wire         mem_outs_stall,

    // ====================================================================
    // exe_outputs_t (exe_outs_i)
    //   exe_br_resolution_outputs_t (br_res_out) flattened.
    // ====================================================================
    input  wire         exe_outs_valid,
    input  wire         exe_outs_br_res_out_flush,
    input  wire         exe_outs_br_res_out_farFlush,
    input  wire         exe_outs_br_res_out_callFlush,
    input  wire         exe_outs_DR_0_we,
    input  wire [`REG_ID_W-1:0] exe_outs_DR_0_id,
    input  wire [63:0]  exe_outs_DR_0_data,
    input  wire         exe_outs_DR_1_we,
    input  wire [`REG_ID_W-1:0] exe_outs_DR_1_id,
    input  wire [63:0]  exe_outs_DR_1_data,

    // ====================================================================
    // wb_outputs_t (wb_outs_i) -- only wb_stall consumed
    // ====================================================================
    input  wire         wb_outs_wb_stall,

    // ====================================================================
    // dc_latches_t (dc_latches_next) -- fully unrolled
    // ====================================================================
    output wire         dc_latches_next_valid,

    output wire         dc_latches_next_cs_LD_OP,
    output wire         dc_latches_next_cs_ST_OP,
    output wire         dc_latches_next_cs_dr_upper8,
    output wire         dc_latches_next_cs_sr_upper8,
    output wire [1:0]   dc_latches_next_cs_datasize,

    output wire         dc_latches_next_mem_cs_ST_OP,
    output wire         dc_latches_next_mem_cs_LD_OP,

    output wire         dc_latches_next_exe_cs_ST_OP,
    output wire [`EXE_OP_W-1:0]  dc_latches_next_exe_cs_OP_TYPE,
    output wire [`SRC_SEL_W-1:0] dc_latches_next_exe_cs_alu_inputA_sel,
    output wire [`SRC_SEL_W-1:0] dc_latches_next_exe_cs_alu_inputB_sel,
    output wire [`SRC_SEL_W-1:0] dc_latches_next_exe_cs_branch_target_sel,
    output wire         dc_latches_next_exe_cs_shift_by_one,
    output wire         dc_latches_next_exe_cs_br_ucond,
    output wire         dc_latches_next_exe_cs_relative_branch,
    output wire         dc_latches_next_exe_cs_special_br,
    output wire         dc_latches_next_exe_cs_is_far,
    output wire         dc_latches_next_exe_cs_is_call,
    output wire         dc_latches_next_exe_cs_second_flag_needed,
    output wire         dc_latches_next_exe_cs_rep_no_zf_update,

    output wire         dc_latches_next_wb_cs_ST_OP,
    output wire         dc_latches_next_wb_cs_WB_DR,
    output wire         dc_latches_next_wb_cs_WB_SR,
    output wire         dc_latches_next_wb_cs_WB_EAX,

    output wire         dc_latches_next_br_info_valid,
    output wire [31:0]  dc_latches_next_br_info_br_eip,
    output wire         dc_latches_next_br_info_br_xcl,
    output wire         dc_latches_next_br_info_br_pred_taken,
    output wire [31:0]  dc_latches_next_br_info_speculative_target,

    output wire         dc_latches_next_rr_gp,

    output wire [31:0]  dc_latches_next_ld_vaddy,
    output wire [31:0]  dc_latches_next_seg0_limit_w_datasize,
    output wire [31:0]  dc_latches_next_seg0_limit_wo_datasize,
    output wire [31:0]  dc_latches_next_next_ld_vaddy,
    output wire [31:0]  dc_latches_next_ld_laddy,
    output wire         dc_latches_next_ld_stack_access,

    output wire [31:0]  dc_latches_next_st_vaddy,
    output wire [31:0]  dc_latches_next_seg1_limit_w_datasize,
    output wire [31:0]  dc_latches_next_seg1_limit_wo_datasize,
    output wire [31:0]  dc_latches_next_next_st_vaddy,
    output wire [31:0]  dc_latches_next_st_laddy,
    output wire         dc_latches_next_st_stack_access,

    output wire [31:0]  dc_latches_next_NEIP,
    output wire [31:0]  dc_latches_next_EIP,
    output wire [31:0]  dc_latches_next_EAX,
    output wire [63:0]  dc_latches_next_imm64,

    output wire [`REG_ID_W-1:0] dc_latches_next_sr_id,
    output wire [63:0]  dc_latches_next_sr_data,
    output wire [`REG_ID_W-1:0] dc_latches_next_dr_id,
    output wire [63:0]  dc_latches_next_dr_data,

    // ====================================================================
    // rr_outputs_t (outs_o) -- regFileValues split into 26 named wires
    // ====================================================================
    output wire         outs_valid,
    output wire         outs_stall,
    output wire         outs_ecx_sb,
    output wire [31:0]  outs_ecx,
    output wire [31:0]  outs_eax,
    output wire         outs_set_ZF_sb,
    output wire         outs_codeSeg_sb,
    output wire [31:0]  outs_codeSeg_data,
    output wire [31:0]  outs_codeSeg_limit,
    output wire         outs_dc_stage_latch_we,

    output wire [63:0]  outs_regFileValues_0,
    output wire [63:0]  outs_regFileValues_1,
    output wire [63:0]  outs_regFileValues_2,
    output wire [63:0]  outs_regFileValues_3,
    output wire [63:0]  outs_regFileValues_4,
    output wire [63:0]  outs_regFileValues_5,
    output wire [63:0]  outs_regFileValues_6,
    output wire [63:0]  outs_regFileValues_7,
    output wire [63:0]  outs_regFileValues_8,
    output wire [63:0]  outs_regFileValues_9,
    output wire [63:0]  outs_regFileValues_10,
    output wire [63:0]  outs_regFileValues_11,
    output wire [63:0]  outs_regFileValues_12,
    output wire [63:0]  outs_regFileValues_13,
    output wire [63:0]  outs_regFileValues_14,
    output wire [63:0]  outs_regFileValues_15,
    output wire [63:0]  outs_regFileValues_16,
    output wire [63:0]  outs_regFileValues_17,
    output wire [63:0]  outs_regFileValues_18,
    output wire [63:0]  outs_regFileValues_19,
    output wire [63:0]  outs_regFileValues_20,
    output wire [63:0]  outs_regFileValues_21,
    output wire [63:0]  outs_regFileValues_22,
    output wire [63:0]  outs_regFileValues_23,
    output wire [63:0]  outs_regFileValues_24,
    output wire [63:0]  outs_regFileValues_25
);

    // ----------------------------------------------------------------
    // latchesInUse = decode_outs_rep_latch ? rep_latches : normal_latches
    //   one MUX_2 per leaf field.
    // ----------------------------------------------------------------
    wire        latchesInUse_valid;

    wire        latchesInUse_cs_ST_SEL;
    wire        latchesInUse_cs_MODRM_NEEDED;
    wire        latchesInUse_cs_RM_IS_DR;
    wire        latchesInUse_cs_SWITCH_LD_ADDY;
    wire        latchesInUse_cs_LD_OP;
    wire        latchesInUse_cs_ST_OP;
    wire [`REG_ID_W-1:0] latchesInUse_cs_dr_id;
    wire [`REG_ID_W-1:0] latchesInUse_cs_sr_id;
    wire        latchesInUse_cs_dr_rd;
    wire        latchesInUse_cs_sr_rd;
    wire        latchesInUse_cs_eax_rd;
    wire        latchesInUse_cs_dr_wr;
    wire        latchesInUse_cs_sr_wr;
    wire        latchesInUse_cs_eax_wr;
    wire        latchesInUse_cs_MOVS_OP;
    wire [1:0]  latchesInUse_cs_datasize;
    wire        latchesInUse_cs_will_mod_zf;
    wire        latchesInUse_cs_seg_1_valid;
    wire [`REG_ID_W-1:0] latchesInUse_cs_seg_0_id;
    wire [`REG_ID_W-1:0] latchesInUse_cs_seg_1_id;
    wire        latchesInUse_cs_special_modrm_bs;
    wire        latchesInUse_cs_special_br;

    wire        latchesInUse_dc_cs_LD_OP;
    wire        latchesInUse_dc_cs_ST_OP;
    wire        latchesInUse_dc_cs_dr_upper8;
    wire        latchesInUse_dc_cs_sr_upper8;
    wire [1:0]  latchesInUse_dc_cs_datasize;

    wire        latchesInUse_mem_cs_ST_OP;
    wire        latchesInUse_mem_cs_LD_OP;

    wire        latchesInUse_exe_cs_ST_OP;
    wire [`EXE_OP_W-1:0]  latchesInUse_exe_cs_OP_TYPE;
    wire [`SRC_SEL_W-1:0] latchesInUse_exe_cs_alu_inputA_sel;
    wire [`SRC_SEL_W-1:0] latchesInUse_exe_cs_alu_inputB_sel;
    wire [`SRC_SEL_W-1:0] latchesInUse_exe_cs_branch_target_sel;
    wire        latchesInUse_exe_cs_shift_by_one;
    wire        latchesInUse_exe_cs_br_ucond;
    wire        latchesInUse_exe_cs_relative_branch;
    wire        latchesInUse_exe_cs_special_br;
    wire        latchesInUse_exe_cs_is_far;
    wire        latchesInUse_exe_cs_is_call;
    wire        latchesInUse_exe_cs_second_flag_needed;
    wire        latchesInUse_exe_cs_rep_no_zf_update;

    wire        latchesInUse_wb_cs_ST_OP;
    wire        latchesInUse_wb_cs_WB_DR;
    wire        latchesInUse_wb_cs_WB_SR;
    wire        latchesInUse_wb_cs_WB_EAX;

    wire        latchesInUse_br_info_valid;
    wire [31:0] latchesInUse_br_info_br_eip;
    wire        latchesInUse_br_info_br_xcl;
    wire        latchesInUse_br_info_br_pred_taken;
    wire [31:0] latchesInUse_br_info_speculative_target;

    wire [31:0] latchesInUse_NEIP;
    wire [31:0] latchesInUse_EIP;
    wire [31:0] latchesInUse_EAX;
    wire [63:0] latchesInUse_imm64;
    wire [`REG_ID_W-1:0] latchesInUse_sib_idx_id;
    wire [`REG_ID_W-1:0] latchesInUse_sib_base_id;
    wire        latchesInUse_sib_needed;
    wire [7:0]  latchesInUse_sib_scale;
    wire        latchesInUse_disp_needed;
    wire        latchesInUse_disp_size;
    wire [31:0] latchesInUse_displacement;

    `MUX_2(u_lI_valid,                  1, latchesInUse_valid,
            latches_normal_latches_valid, latches_rep_latches_valid,
            decode_outs_rep_latch)

    `MUX_2(u_lI_cs_ST_SEL,              1, latchesInUse_cs_ST_SEL,
            latches_normal_latches_cs_ST_SEL, latches_rep_latches_cs_ST_SEL, decode_outs_rep_latch)
    `MUX_2(u_lI_cs_MODRM_NEEDED,        1, latchesInUse_cs_MODRM_NEEDED,
            latches_normal_latches_cs_MODRM_NEEDED, latches_rep_latches_cs_MODRM_NEEDED, decode_outs_rep_latch)
    `MUX_2(u_lI_cs_RM_IS_DR,            1, latchesInUse_cs_RM_IS_DR,
            latches_normal_latches_cs_RM_IS_DR, latches_rep_latches_cs_RM_IS_DR, decode_outs_rep_latch)
    `MUX_2(u_lI_cs_SWITCH_LD_ADDY,      1, latchesInUse_cs_SWITCH_LD_ADDY,
            latches_normal_latches_cs_SWITCH_LD_ADDY, latches_rep_latches_cs_SWITCH_LD_ADDY, decode_outs_rep_latch)
    `MUX_2(u_lI_cs_LD_OP,               1, latchesInUse_cs_LD_OP,
            latches_normal_latches_cs_LD_OP, latches_rep_latches_cs_LD_OP, decode_outs_rep_latch)
    `MUX_2(u_lI_cs_ST_OP,               1, latchesInUse_cs_ST_OP,
            latches_normal_latches_cs_ST_OP, latches_rep_latches_cs_ST_OP, decode_outs_rep_latch)
    `MUX_2(u_lI_cs_dr_id,        `REG_ID_W, latchesInUse_cs_dr_id,
            latches_normal_latches_cs_dr_id, latches_rep_latches_cs_dr_id, decode_outs_rep_latch)
    `MUX_2(u_lI_cs_sr_id,        `REG_ID_W, latchesInUse_cs_sr_id,
            latches_normal_latches_cs_sr_id, latches_rep_latches_cs_sr_id, decode_outs_rep_latch)
    `MUX_2(u_lI_cs_dr_rd,               1, latchesInUse_cs_dr_rd,
            latches_normal_latches_cs_dr_rd, latches_rep_latches_cs_dr_rd, decode_outs_rep_latch)
    `MUX_2(u_lI_cs_sr_rd,               1, latchesInUse_cs_sr_rd,
            latches_normal_latches_cs_sr_rd, latches_rep_latches_cs_sr_rd, decode_outs_rep_latch)
    `MUX_2(u_lI_cs_eax_rd,              1, latchesInUse_cs_eax_rd,
            latches_normal_latches_cs_eax_rd, latches_rep_latches_cs_eax_rd, decode_outs_rep_latch)
    `MUX_2(u_lI_cs_dr_wr,               1, latchesInUse_cs_dr_wr,
            latches_normal_latches_cs_dr_wr, latches_rep_latches_cs_dr_wr, decode_outs_rep_latch)
    `MUX_2(u_lI_cs_sr_wr,               1, latchesInUse_cs_sr_wr,
            latches_normal_latches_cs_sr_wr, latches_rep_latches_cs_sr_wr, decode_outs_rep_latch)
    `MUX_2(u_lI_cs_eax_wr,              1, latchesInUse_cs_eax_wr,
            latches_normal_latches_cs_eax_wr, latches_rep_latches_cs_eax_wr, decode_outs_rep_latch)
    `MUX_2(u_lI_cs_MOVS_OP,             1, latchesInUse_cs_MOVS_OP,
            latches_normal_latches_cs_MOVS_OP, latches_rep_latches_cs_MOVS_OP, decode_outs_rep_latch)
    `MUX_2(u_lI_cs_datasize,            2, latchesInUse_cs_datasize,
            latches_normal_latches_cs_datasize, latches_rep_latches_cs_datasize, decode_outs_rep_latch)
    `MUX_2(u_lI_cs_will_mod_zf,         1, latchesInUse_cs_will_mod_zf,
            latches_normal_latches_cs_will_mod_zf, latches_rep_latches_cs_will_mod_zf, decode_outs_rep_latch)
    `MUX_2(u_lI_cs_seg_1_valid,         1, latchesInUse_cs_seg_1_valid,
            latches_normal_latches_cs_seg_1_valid, latches_rep_latches_cs_seg_1_valid, decode_outs_rep_latch)
    `MUX_2(u_lI_cs_seg_0_id,     `REG_ID_W, latchesInUse_cs_seg_0_id,
            latches_normal_latches_cs_seg_0_id, latches_rep_latches_cs_seg_0_id, decode_outs_rep_latch)
    `MUX_2(u_lI_cs_seg_1_id,     `REG_ID_W, latchesInUse_cs_seg_1_id,
            latches_normal_latches_cs_seg_1_id, latches_rep_latches_cs_seg_1_id, decode_outs_rep_latch)
    `MUX_2(u_lI_cs_special_modrm_bs,    1, latchesInUse_cs_special_modrm_bs,
            latches_normal_latches_cs_special_modrm_bs, latches_rep_latches_cs_special_modrm_bs, decode_outs_rep_latch)
    `MUX_2(u_lI_cs_special_br,          1, latchesInUse_cs_special_br,
            latches_normal_latches_cs_special_br, latches_rep_latches_cs_special_br, decode_outs_rep_latch)

    `MUX_2(u_lI_dc_cs_LD_OP,            1, latchesInUse_dc_cs_LD_OP,
            latches_normal_latches_dc_cs_LD_OP, latches_rep_latches_dc_cs_LD_OP, decode_outs_rep_latch)
    `MUX_2(u_lI_dc_cs_ST_OP,            1, latchesInUse_dc_cs_ST_OP,
            latches_normal_latches_dc_cs_ST_OP, latches_rep_latches_dc_cs_ST_OP, decode_outs_rep_latch)
    `MUX_2(u_lI_dc_cs_dr_upper8,        1, latchesInUse_dc_cs_dr_upper8,
            latches_normal_latches_dc_cs_dr_upper8, latches_rep_latches_dc_cs_dr_upper8, decode_outs_rep_latch)
    `MUX_2(u_lI_dc_cs_sr_upper8,        1, latchesInUse_dc_cs_sr_upper8,
            latches_normal_latches_dc_cs_sr_upper8, latches_rep_latches_dc_cs_sr_upper8, decode_outs_rep_latch)
    `MUX_2(u_lI_dc_cs_datasize,         2, latchesInUse_dc_cs_datasize,
            latches_normal_latches_dc_cs_datasize, latches_rep_latches_dc_cs_datasize, decode_outs_rep_latch)

    `MUX_2(u_lI_mem_cs_ST_OP,           1, latchesInUse_mem_cs_ST_OP,
            latches_normal_latches_mem_cs_ST_OP, latches_rep_latches_mem_cs_ST_OP, decode_outs_rep_latch)
    `MUX_2(u_lI_mem_cs_LD_OP,           1, latchesInUse_mem_cs_LD_OP,
            latches_normal_latches_mem_cs_LD_OP, latches_rep_latches_mem_cs_LD_OP, decode_outs_rep_latch)

    `MUX_2(u_lI_exe_cs_ST_OP,           1, latchesInUse_exe_cs_ST_OP,
            latches_normal_latches_exe_cs_ST_OP, latches_rep_latches_exe_cs_ST_OP, decode_outs_rep_latch)
    `MUX_2(u_lI_exe_cs_OP_TYPE,  `EXE_OP_W,  latchesInUse_exe_cs_OP_TYPE,
            latches_normal_latches_exe_cs_OP_TYPE, latches_rep_latches_exe_cs_OP_TYPE, decode_outs_rep_latch)
    `MUX_2(u_lI_exe_cs_alu_inputA_sel, `SRC_SEL_W, latchesInUse_exe_cs_alu_inputA_sel,
            latches_normal_latches_exe_cs_alu_inputA_sel, latches_rep_latches_exe_cs_alu_inputA_sel, decode_outs_rep_latch)
    `MUX_2(u_lI_exe_cs_alu_inputB_sel, `SRC_SEL_W, latchesInUse_exe_cs_alu_inputB_sel,
            latches_normal_latches_exe_cs_alu_inputB_sel, latches_rep_latches_exe_cs_alu_inputB_sel, decode_outs_rep_latch)
    `MUX_2(u_lI_exe_cs_branch_target_sel, `SRC_SEL_W, latchesInUse_exe_cs_branch_target_sel,
            latches_normal_latches_exe_cs_branch_target_sel, latches_rep_latches_exe_cs_branch_target_sel, decode_outs_rep_latch)
    `MUX_2(u_lI_exe_cs_shift_by_one,    1, latchesInUse_exe_cs_shift_by_one,
            latches_normal_latches_exe_cs_shift_by_one, latches_rep_latches_exe_cs_shift_by_one, decode_outs_rep_latch)
    `MUX_2(u_lI_exe_cs_br_ucond,        1, latchesInUse_exe_cs_br_ucond,
            latches_normal_latches_exe_cs_br_ucond, latches_rep_latches_exe_cs_br_ucond, decode_outs_rep_latch)
    `MUX_2(u_lI_exe_cs_relative_branch, 1, latchesInUse_exe_cs_relative_branch,
            latches_normal_latches_exe_cs_relative_branch, latches_rep_latches_exe_cs_relative_branch, decode_outs_rep_latch)
    `MUX_2(u_lI_exe_cs_special_br,      1, latchesInUse_exe_cs_special_br,
            latches_normal_latches_exe_cs_special_br, latches_rep_latches_exe_cs_special_br, decode_outs_rep_latch)
    `MUX_2(u_lI_exe_cs_is_far,          1, latchesInUse_exe_cs_is_far,
            latches_normal_latches_exe_cs_is_far, latches_rep_latches_exe_cs_is_far, decode_outs_rep_latch)
    `MUX_2(u_lI_exe_cs_is_call,         1, latchesInUse_exe_cs_is_call,
            latches_normal_latches_exe_cs_is_call, latches_rep_latches_exe_cs_is_call, decode_outs_rep_latch)
    `MUX_2(u_lI_exe_cs_second_flag_needed, 1, latchesInUse_exe_cs_second_flag_needed,
            latches_normal_latches_exe_cs_second_flag_needed, latches_rep_latches_exe_cs_second_flag_needed, decode_outs_rep_latch)
    `MUX_2(u_lI_exe_cs_rep_no_zf_update, 1, latchesInUse_exe_cs_rep_no_zf_update,
            latches_normal_latches_exe_cs_rep_no_zf_update, latches_rep_latches_exe_cs_rep_no_zf_update, decode_outs_rep_latch)

    `MUX_2(u_lI_wb_cs_ST_OP,            1, latchesInUse_wb_cs_ST_OP,
            latches_normal_latches_wb_cs_ST_OP, latches_rep_latches_wb_cs_ST_OP, decode_outs_rep_latch)
    `MUX_2(u_lI_wb_cs_WB_DR,            1, latchesInUse_wb_cs_WB_DR,
            latches_normal_latches_wb_cs_WB_DR, latches_rep_latches_wb_cs_WB_DR, decode_outs_rep_latch)
    `MUX_2(u_lI_wb_cs_WB_SR,            1, latchesInUse_wb_cs_WB_SR,
            latches_normal_latches_wb_cs_WB_SR, latches_rep_latches_wb_cs_WB_SR, decode_outs_rep_latch)
    `MUX_2(u_lI_wb_cs_WB_EAX,           1, latchesInUse_wb_cs_WB_EAX,
            latches_normal_latches_wb_cs_WB_EAX, latches_rep_latches_wb_cs_WB_EAX, decode_outs_rep_latch)

    `MUX_2(u_lI_br_info_valid,          1, latchesInUse_br_info_valid,
            latches_normal_latches_br_info_valid, latches_rep_latches_br_info_valid, decode_outs_rep_latch)
    `MUX_2(u_lI_br_info_br_eip,        32, latchesInUse_br_info_br_eip,
            latches_normal_latches_br_info_br_eip, latches_rep_latches_br_info_br_eip, decode_outs_rep_latch)
    `MUX_2(u_lI_br_info_br_xcl,         1, latchesInUse_br_info_br_xcl,
            latches_normal_latches_br_info_br_xcl, latches_rep_latches_br_info_br_xcl, decode_outs_rep_latch)
    `MUX_2(u_lI_br_info_br_pred_taken,  1, latchesInUse_br_info_br_pred_taken,
            latches_normal_latches_br_info_br_pred_taken, latches_rep_latches_br_info_br_pred_taken, decode_outs_rep_latch)
    `MUX_2(u_lI_br_info_speculative_target, 32, latchesInUse_br_info_speculative_target,
            latches_normal_latches_br_info_speculative_target, latches_rep_latches_br_info_speculative_target, decode_outs_rep_latch)

    `MUX_2(u_lI_NEIP,                  32, latchesInUse_NEIP,
            latches_normal_latches_NEIP, latches_rep_latches_NEIP, decode_outs_rep_latch)
    `MUX_2(u_lI_EIP,                   32, latchesInUse_EIP,
            latches_normal_latches_EIP, latches_rep_latches_EIP, decode_outs_rep_latch)
    `MUX_2(u_lI_EAX,                   32, latchesInUse_EAX,
            latches_normal_latches_EAX, latches_rep_latches_EAX, decode_outs_rep_latch)
    `MUX_2(u_lI_imm64,                 64, latchesInUse_imm64,
            latches_normal_latches_imm64, latches_rep_latches_imm64, decode_outs_rep_latch)
    `MUX_2(u_lI_sib_idx_id,      `REG_ID_W, latchesInUse_sib_idx_id,
            latches_normal_latches_sib_idx_id, latches_rep_latches_sib_idx_id, decode_outs_rep_latch)
    `MUX_2(u_lI_sib_base_id,     `REG_ID_W, latchesInUse_sib_base_id,
            latches_normal_latches_sib_base_id, latches_rep_latches_sib_base_id, decode_outs_rep_latch)
    `MUX_2(u_lI_sib_needed,             1, latchesInUse_sib_needed,
            latches_normal_latches_sib_needed, latches_rep_latches_sib_needed, decode_outs_rep_latch)
    `MUX_2(u_lI_sib_scale,              8, latchesInUse_sib_scale,
            latches_normal_latches_sib_scale, latches_rep_latches_sib_scale, decode_outs_rep_latch)
    `MUX_2(u_lI_disp_needed,            1, latchesInUse_disp_needed,
            latches_normal_latches_disp_needed, latches_rep_latches_disp_needed, decode_outs_rep_latch)
    `MUX_2(u_lI_disp_size,              1, latchesInUse_disp_size,
            latches_normal_latches_disp_size, latches_rep_latches_disp_size, decode_outs_rep_latch)
    `MUX_2(u_lI_displacement,          32, latchesInUse_displacement,
            latches_normal_latches_displacement, latches_rep_latches_displacement, decode_outs_rep_latch)

    // ----------------------------------------------------------------
    // SEGMENT_LIMITS -- 7 individual undriven 32-bit wires.
    //   The SV declares `segment_limit_reg_entry_t SEGMENT_LIMITS[7]`
    //   and never assigns it; we mirror that here.
    // ----------------------------------------------------------------
    wire [31:0] SEGMENT_LIMIT_CS;
    wire [31:0] SEGMENT_LIMIT_DS;
    wire [31:0] SEGMENT_LIMIT_SS;
    wire [31:0] SEGMENT_LIMIT_ES;
    wire [31:0] SEGMENT_LIMIT_FS;
    wire [31:0] SEGMENT_LIMIT_GS;
    wire [31:0] SEGMENT_LIMIT_EXPS;

    // SB outputs / dep-stall plumbing
    wire        ecx_sb;
    wire        cs_sb;
    wire        depstall;
    wire        dc_latches_we;
    wire        next_dc_valid;
    wire        rr_stall;
    `AND_2(u_rr_stall, 1, rr_stall, latchesInUse_valid, depstall)

    // ----------------------------------------------------------------
    // RegFile structural unit (already flat-port .v).
    // ----------------------------------------------------------------
    wire [63:0] DR_data_w;
    wire [63:0] SR_data_w;
    wire [31:0] SIB_IDX_data_w;
    wire [31:0] SIB_BASE_data_w;
    wire [31:0] ECX_data_w;
    wire [31:0] EAX_data_w;
    wire [31:0] CS_data_w;
    wire [31:0] Segment0_data_w;
    wire [31:0] Segment1_data_w;

    wire [63:0] REG_CS_w, REG_DS_w, REG_SS_w, REG_ES_w;
    wire [63:0] REG_FS_w, REG_GS_w, REG_EXPS_w;
    wire [63:0] REG_EAX_w, REG_EBX_w, REG_ECX_w, REG_EDX_w;
    wire [63:0] REG_ESI_w, REG_EDI_w, REG_ESP_w, REG_EBP_w;
    wire [63:0] REG_MM0_w, REG_MM1_w, REG_MM2_w, REG_MM3_w;
    wire [63:0] REG_MM4_w, REG_MM5_w, REG_MM6_w, REG_MM7_w;
    wire [63:0] REG_ETR_w, REG_ERROR_REG_w, REG_NO_REG_w;

    RegFile RegisterFile_unit (
        .clk(clk),
        .rst(rst),

        .DR_ID(latchesInUse_cs_dr_id),
        .SR_ID(latchesInUse_cs_sr_id),
        .SIB_IDX_ID(latchesInUse_sib_idx_id),
        .SIB_BASE_ID(latchesInUse_sib_base_id),

        .WB_DR0_data(exe_outs_DR_0_data),
        .WB_DR1_data(exe_outs_DR_1_data),
        .WB_DR0_ID(exe_outs_DR_0_id),
        .WB_DR1_ID(exe_outs_DR_1_id),
        .WB_DR0_we(exe_outs_DR_0_we),
        .WB_DR1_we(exe_outs_DR_1_we),

        .Segment0_ID(latchesInUse_cs_seg_0_id),
        .Segment1_ID(latchesInUse_cs_seg_1_id),

        .DR_data(DR_data_w),
        .SR_data(SR_data_w),
        .SIB_IDX_data(SIB_IDX_data_w),
        .SIB_BASE_data(SIB_BASE_data_w),
        .ECX_data(ECX_data_w),
        .EAX_data(EAX_data_w),
        .CS_data(CS_data_w),
        .Segment0_data(Segment0_data_w),
        .Segment1_data(Segment1_data_w),

        .REG_CS_o(REG_CS_w),
        .REG_DS_o(REG_DS_w),
        .REG_SS_o(REG_SS_w),
        .REG_ES_o(REG_ES_w),
        .REG_FS_o(REG_FS_w),
        .REG_GS_o(REG_GS_w),
        .REG_EXPS_o(REG_EXPS_w),
        .REG_EAX_o(REG_EAX_w),
        .REG_EBX_o(REG_EBX_w),
        .REG_ECX_o(REG_ECX_w),
        .REG_EDX_o(REG_EDX_w),
        .REG_ESI_o(REG_ESI_w),
        .REG_EDI_o(REG_EDI_w),
        .REG_ESP_o(REG_ESP_w),
        .REG_EBP_o(REG_EBP_w),
        .REG_MM0_o(REG_MM0_w),
        .REG_MM1_o(REG_MM1_w),
        .REG_MM2_o(REG_MM2_w),
        .REG_MM3_o(REG_MM3_w),
        .REG_MM4_o(REG_MM4_w),
        .REG_MM5_o(REG_MM5_w),
        .REG_MM6_o(REG_MM6_w),
        .REG_MM7_o(REG_MM7_w),
        .REG_ETR_o(REG_ETR_w),
        .REG_ERROR_REG_o(REG_ERROR_REG_w),
        .REG_NO_REG_o(REG_NO_REG_w)
    );

    // ----------------------------------------------------------------
    // addygen_input_addy = (MODRM_NEEDED & RM_IS_DR) ? DR[31:0] : SR[31:0]
    // ----------------------------------------------------------------
    wire        modrm_and_rm_is_dr;
    wire [31:0] addygen_input_addy;
    `AND_2(u_modrm_and_rm_is_dr, 1, modrm_and_rm_is_dr,
            latchesInUse_cs_MODRM_NEEDED, latchesInUse_cs_RM_IS_DR)
    `MUX_2(u_addygen_input_addy, 32, addygen_input_addy,
            SR_data_w[31:0], DR_data_w[31:0], modrm_and_rm_is_dr)

    // ----------------------------------------------------------------
    // Segment-limit lookup: 8-way mux on lower 3 bits of seg_X_id.
    //   seg-limit-id encoding (CS=0, DS=1, SS=2, ES=3, FS=4, GS=5, EXPS=6).
    // ----------------------------------------------------------------
    wire [31:0] segment0_limit_data_w;
    wire [31:0] segment1_limit_data_w;
    `MUX_8(u_seg_lim_0, 32, segment0_limit_data_w,
            SEGMENT_LIMIT_CS, SEGMENT_LIMIT_DS, SEGMENT_LIMIT_SS, SEGMENT_LIMIT_ES,
            SEGMENT_LIMIT_FS, SEGMENT_LIMIT_GS, SEGMENT_LIMIT_EXPS, 32'h0,
            latchesInUse_cs_seg_0_id[2:0])
    `MUX_8(u_seg_lim_1, 32, segment1_limit_data_w,
            SEGMENT_LIMIT_CS, SEGMENT_LIMIT_DS, SEGMENT_LIMIT_SS, SEGMENT_LIMIT_ES,
            SEGMENT_LIMIT_FS, SEGMENT_LIMIT_GS, SEGMENT_LIMIT_EXPS, 32'h0,
            latchesInUse_cs_seg_1_id[2:0])

    // ----------------------------------------------------------------
    // Address generator
    // ----------------------------------------------------------------
    wire [31:0] ld_vaddy;
    wire [31:0] seg0_limit_w_datasize;
    wire [31:0] seg0_limit_wo_datasize;
    wire [31:0] next_ld_vaddy;
    wire [31:0] ld_laddy;

    wire [31:0] actual_st_vaddy;
    wire [31:0] seg1_limit_w_datasize;
    wire [31:0] seg1_limit_wo_datasize;
    wire [31:0] actual_next_st_vaddy;
    wire [31:0] st_laddy;

    npu_node1 addygen_logic_unit (
        .register_data       (addygen_input_addy),
        .SIB_IDX_data        (SIB_IDX_data_w),
        .SIB_BASE_data       (SIB_BASE_data_w),
        .SIB_SCALE_val       (latchesInUse_sib_scale),
        .sib_needed          (latchesInUse_sib_needed),
        .disp_needed         (latchesInUse_disp_needed),
        .dispsize            (latchesInUse_disp_size),
        .displacement        (latchesInUse_displacement),
        .datasize            (latchesInUse_cs_datasize),
        .seg0_data           (Segment0_data_w),
        .segment0_limit_data (segment0_limit_data_w),
        .seg1_data           (Segment1_data_w),
        .segment1_limit_data (segment1_limit_data_w),
        .seg1_valid          (latchesInUse_cs_seg_1_valid),
        .modrm_needed        (latchesInUse_cs_MODRM_NEEDED),
        .rm_is_dr            (latchesInUse_cs_RM_IS_DR),
        .st_sel              (latchesInUse_cs_ST_SEL),
        .movs_op             (latchesInUse_cs_MOVS_OP),
        .switch_ld_addy      (latchesInUse_cs_SWITCH_LD_ADDY),
        .special_br          (latchesInUse_cs_special_br),
        .special_modrm_bs    (latchesInUse_cs_special_modrm_bs),
        .regout_sr_data      (SR_data_w[31:0]),
        .regout_dr_data      (DR_data_w[31:0]),

        .ld_vaddy             (ld_vaddy),
        .seg0_limit_w_datasize (seg0_limit_w_datasize),
        .seg0_limit_wo_datasize(seg0_limit_wo_datasize),
        .next_ld_vaddy        (next_ld_vaddy),
        .ld_laddy             (ld_laddy),

        .actual_st_vaddy      (actual_st_vaddy),
        .seg1_limit_w_datasize (seg1_limit_w_datasize),
        .seg1_limit_wo_datasize(seg1_limit_wo_datasize),
        .actual_next_st_vaddy (actual_next_st_vaddy),
        .actual_st_laddy      (st_laddy)
    );

    // ----------------------------------------------------------------
    // RegSB
    // ----------------------------------------------------------------
    wire instructionforward;
    `AND_2(u_instructionforward, 1, instructionforward, dc_latches_we, next_dc_valid)

    RegSB reg_sb_unit (
        .clk           (clk),
        .rst           (rst),
        .instructionforward(instructionforward),
        .dr_id         (latchesInUse_cs_dr_id),
        .sr_id         (latchesInUse_cs_sr_id),
        .flush         (exe_outs_br_res_out_flush),
        .farFlush      (exe_outs_br_res_out_farFlush),
        .callFlush     (exe_outs_br_res_out_callFlush),
        .sib_base_id   (latchesInUse_sib_base_id),
        .sib_idx_id    (latchesInUse_sib_idx_id),
        .wb_dr0_id     (exe_outs_DR_0_id),
        .wb_dr0_we     (exe_outs_DR_0_we),
        .wb_dr1_id     (exe_outs_DR_1_id),
        .wb_dr1_we     (exe_outs_DR_1_we),
        .cs_sib_size   (latchesInUse_sib_needed),
        .cs_dr_wr      (latchesInUse_cs_dr_wr),
        .cs_sr_wr      (latchesInUse_cs_sr_wr),
        .cs_dr_rd      (latchesInUse_cs_dr_rd),
        .cs_sr_rd      (latchesInUse_cs_sr_rd),
        .cs_eax_rd     (latchesInUse_cs_eax_rd),
        .cs_eax_wr     (latchesInUse_cs_eax_wr),
        .Segment0_ID   (latchesInUse_cs_seg_0_id),
        .Segment1_ID   (latchesInUse_cs_seg_1_id),
        .Segment1_valid(latchesInUse_cs_seg_1_valid),
        .dep_stall     (depstall),
        .ecx_sb        (ecx_sb),
        .codeSeg_sb    (cs_sb),
        .LD_OP         (latchesInUse_cs_LD_OP),
        .ST_OP         (latchesInUse_cs_ST_OP),
        .REP_OP        (decode_outs_rep_latch)
    );

    // ----------------------------------------------------------------
    // dc_valid_logic
    // ----------------------------------------------------------------
    dc_valid_logic dc_valid_logic_unit(
        .DC_we_o    (dc_latches_we),
        .N_DC_V_o   (next_dc_valid),
        .RR_stall_i (rr_stall),
        .RR_V_i     (latchesInUse_valid),
        .DC_stall_i (dc_outs_stall),
        .DC_V_i     (dc_outs_valid),
        .MEM_V_i    (mem_outs_valid),
        .MEM_stall_i(mem_outs_stall),
        .EXE_V_i    (exe_outs_valid),
        .WB_stall_i (wb_outs_wb_stall)
    );

    // ----------------------------------------------------------------
    // RR_GP = decode_gp & ~depstall
    // ----------------------------------------------------------------
    wire RR_GP;
    wire not_depstall;
    `INV_N(u_not_depstall, 1, depstall, not_depstall)
    `AND_2(u_RR_GP, 1, RR_GP, decode_outs_decode_gp, not_depstall)

    // ----------------------------------------------------------------
    // ld_stack_access = (seg_0_id == SS)
    // st_stack_access = seg_1_valid ? (seg_1_id == SS) : (seg_0_id == SS)
    // ----------------------------------------------------------------
    wire seg_0_eq_SS, seg_1_eq_SS, st_stack_access_w;
    `CMP_N(u_cmp_seg_0_SS, `REG_ID_W, seg_0_eq_SS, latchesInUse_cs_seg_0_id, `SS)
    `CMP_N(u_cmp_seg_1_SS, `REG_ID_W, seg_1_eq_SS, latchesInUse_cs_seg_1_id, `SS)
    `MUX_2(u_st_stack_access, 1, st_stack_access_w,
            seg_0_eq_SS, seg_1_eq_SS, latchesInUse_cs_seg_1_valid)

    // ----------------------------------------------------------------
    // dc_latches_next.valid = next_dc_valid & ~exp_pipe_clear
    // ----------------------------------------------------------------
    wire not_exp_pipe_clear, dc_latches_next_valid_w;
    `INV_N(u_not_exp_pipe_clear, 1, fetch_outs_exp_pipe_clear, not_exp_pipe_clear)
    `AND_2(u_dc_latches_valid,   1, dc_latches_next_valid_w, next_dc_valid, not_exp_pipe_clear)

    // ----------------------------------------------------------------
    // dc_latches_next field assigns
    // ----------------------------------------------------------------
    assign dc_latches_next_valid                       = dc_latches_next_valid_w;

    assign dc_latches_next_cs_LD_OP                    = latchesInUse_dc_cs_LD_OP;
    assign dc_latches_next_cs_ST_OP                    = latchesInUse_dc_cs_ST_OP;
    assign dc_latches_next_cs_dr_upper8                = latchesInUse_dc_cs_dr_upper8;
    assign dc_latches_next_cs_sr_upper8                = latchesInUse_dc_cs_sr_upper8;
    assign dc_latches_next_cs_datasize                 = latchesInUse_dc_cs_datasize;

    assign dc_latches_next_mem_cs_ST_OP                = latchesInUse_mem_cs_ST_OP;
    assign dc_latches_next_mem_cs_LD_OP                = latchesInUse_mem_cs_LD_OP;

    assign dc_latches_next_exe_cs_ST_OP                = latchesInUse_exe_cs_ST_OP;
    assign dc_latches_next_exe_cs_OP_TYPE              = latchesInUse_exe_cs_OP_TYPE;
    assign dc_latches_next_exe_cs_alu_inputA_sel       = latchesInUse_exe_cs_alu_inputA_sel;
    assign dc_latches_next_exe_cs_alu_inputB_sel       = latchesInUse_exe_cs_alu_inputB_sel;
    assign dc_latches_next_exe_cs_branch_target_sel    = latchesInUse_exe_cs_branch_target_sel;
    assign dc_latches_next_exe_cs_shift_by_one         = latchesInUse_exe_cs_shift_by_one;
    assign dc_latches_next_exe_cs_br_ucond             = latchesInUse_exe_cs_br_ucond;
    assign dc_latches_next_exe_cs_relative_branch      = latchesInUse_exe_cs_relative_branch;
    assign dc_latches_next_exe_cs_special_br           = latchesInUse_exe_cs_special_br;
    assign dc_latches_next_exe_cs_is_far               = latchesInUse_exe_cs_is_far;
    assign dc_latches_next_exe_cs_is_call              = latchesInUse_exe_cs_is_call;
    assign dc_latches_next_exe_cs_second_flag_needed   = latchesInUse_exe_cs_second_flag_needed;
    assign dc_latches_next_exe_cs_rep_no_zf_update     = latchesInUse_exe_cs_rep_no_zf_update;

    assign dc_latches_next_wb_cs_ST_OP                 = latchesInUse_wb_cs_ST_OP;
    assign dc_latches_next_wb_cs_WB_DR                 = latchesInUse_wb_cs_WB_DR;
    assign dc_latches_next_wb_cs_WB_SR                 = latchesInUse_wb_cs_WB_SR;
    assign dc_latches_next_wb_cs_WB_EAX                = latchesInUse_wb_cs_WB_EAX;

    assign dc_latches_next_br_info_valid               = latchesInUse_br_info_valid;
    assign dc_latches_next_br_info_br_eip              = latchesInUse_br_info_br_eip;
    assign dc_latches_next_br_info_br_xcl              = latchesInUse_br_info_br_xcl;
    assign dc_latches_next_br_info_br_pred_taken       = latchesInUse_br_info_br_pred_taken;
    assign dc_latches_next_br_info_speculative_target  = latchesInUse_br_info_speculative_target;

    assign dc_latches_next_rr_gp                       = RR_GP;

    assign dc_latches_next_ld_vaddy                    = ld_vaddy;
    assign dc_latches_next_seg0_limit_w_datasize       = seg0_limit_w_datasize;
    assign dc_latches_next_seg0_limit_wo_datasize      = seg0_limit_wo_datasize;
    assign dc_latches_next_next_ld_vaddy               = next_ld_vaddy;
    assign dc_latches_next_ld_laddy                    = ld_laddy;
    assign dc_latches_next_ld_stack_access             = seg_0_eq_SS;

    assign dc_latches_next_st_vaddy                    = actual_st_vaddy;
    assign dc_latches_next_seg1_limit_w_datasize       = seg1_limit_w_datasize;
    assign dc_latches_next_seg1_limit_wo_datasize      = seg1_limit_wo_datasize;
    assign dc_latches_next_next_st_vaddy               = actual_next_st_vaddy;
    assign dc_latches_next_st_laddy                    = st_laddy;
    assign dc_latches_next_st_stack_access             = st_stack_access_w;

    assign dc_latches_next_NEIP                        = latchesInUse_NEIP;
    assign dc_latches_next_EIP                         = latchesInUse_EIP;
    assign dc_latches_next_EAX                         = EAX_data_w;
    assign dc_latches_next_imm64                       = latchesInUse_imm64;

    assign dc_latches_next_sr_id                       = latchesInUse_cs_sr_id;
    assign dc_latches_next_sr_data                     = SR_data_w;
    assign dc_latches_next_dr_id                       = latchesInUse_cs_dr_id;
    assign dc_latches_next_dr_data                     = DR_data_w;

    // ----------------------------------------------------------------
    // outs_o (rr_outputs_t)
    //   stall = latchesInUse.valid && depstall == rr_stall (already computed)
    // ----------------------------------------------------------------
    assign outs_valid                = latchesInUse_valid;
    assign outs_stall                = rr_stall;
    assign outs_ecx_sb               = ecx_sb;
    assign outs_ecx                  = ECX_data_w;
    assign outs_eax                  = EAX_data_w;
    assign outs_set_ZF_sb            = latchesInUse_cs_will_mod_zf;
    assign outs_codeSeg_sb           = cs_sb;
    assign outs_codeSeg_data         = CS_data_w;
    assign outs_codeSeg_limit        = SEGMENT_LIMIT_CS;        // CS_LIMIT_ID = 0
    assign outs_dc_stage_latch_we    = dc_latches_we;

    // regFileValues -- map reg_ids_e enum positions to outputs.
    //   CS=0, DS=1, SS=2, ES=3, FS=4, GS=5, EXPS=6,
    //   EAX=7, EBX=8, ECX=9, EDX=10, ESI=11, EDI=12, ESP=13, EBP=14,
    //   MM0=15..MM7=22, ETR=23, ERROR_REG=24, NO_REG=25
    assign outs_regFileValues_0   = REG_CS_w;
    assign outs_regFileValues_1   = REG_DS_w;
    assign outs_regFileValues_2   = REG_SS_w;
    assign outs_regFileValues_3   = REG_ES_w;
    assign outs_regFileValues_4   = REG_FS_w;
    assign outs_regFileValues_5   = REG_GS_w;
    assign outs_regFileValues_6   = REG_EXPS_w;
    assign outs_regFileValues_7   = REG_EAX_w;
    assign outs_regFileValues_8   = REG_EBX_w;
    assign outs_regFileValues_9   = REG_ECX_w;
    assign outs_regFileValues_10  = REG_EDX_w;
    assign outs_regFileValues_11  = REG_ESI_w;
    assign outs_regFileValues_12  = REG_EDI_w;
    assign outs_regFileValues_13  = REG_ESP_w;
    assign outs_regFileValues_14  = REG_EBP_w;
    assign outs_regFileValues_15  = REG_MM0_w;
    assign outs_regFileValues_16  = REG_MM1_w;
    assign outs_regFileValues_17  = REG_MM2_w;
    assign outs_regFileValues_18  = REG_MM3_w;
    assign outs_regFileValues_19  = REG_MM4_w;
    assign outs_regFileValues_20  = REG_MM5_w;
    assign outs_regFileValues_21  = REG_MM6_w;
    assign outs_regFileValues_22  = REG_MM7_w;
    assign outs_regFileValues_23  = REG_ETR_w;
    assign outs_regFileValues_24  = REG_ERROR_REG_w;
    assign outs_regFileValues_25  = REG_NO_REG_w;

endmodule
