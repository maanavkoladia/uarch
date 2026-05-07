// =============================================================================
// RR  (pure Verilog-2005 structural port of RR_structural.sv)
//
//   - All SystemVerilog constructs (struct, typedef, enum, package import,
//     `bool`/`p_address_t`/`uint*_t`/`reg_ids_e`/`source_selector_e`/
//     `exe_cs_operation_type_e`/`regfile_output_t`/`segment_limit_reg_entry_t`)
//     are removed. Each struct field is exposed as a separate flat
//     scalar/vector port whose name follows the original `struct.field`
//     path with `.` replaced by `_`.
//
//   - rr_latches_t has two rr_latches_general_t sub-structs (normal_latches
//     and rep_latches). Both are flattened on the boundary; the
//     `decode_outs_rep_latch`-driven pick (the SV `latchesInUse` mux) is
//     reproduced internally with MUX_2 instances.
//
//   - rr_outputs_t.regFileValues_o[NUM_REGS] is unrolled into 26 individual
//     64-bit output ports (matches the EXE flat-port consumer).
//
//   Type-to-width mapping used here:
//     bool                       -> 1 bit
//     p_address_t                -> 15 bits
//     v_address_t / l_address_t  -> 32 bits
//     uint8_t                    -> 8 bits
//     uint32_t                   -> 32 bits
//     uint64_t                   -> 64 bits
//     reg_ids_e                  -> 5 bits
//     exe_cs_operation_type_e    -> 6 bits
//     source_selector_e          -> 5 bits
//
//   Internal leaf modules already have flat Verilog-2005 ports:
//   RegFile, npu_node1, RegSB, dc_valid_logic.
//
//   Note on SEGMENT_LIMITS: the original SV declares
//   `segment_limit_reg_entry_t SEGMENT_LIMITS[NUM_SEG_REGS]` but never
//   drives it (defaults to X). To match this synthesizably, the seven
//   per-segment-id limit wires are declared but undriven here as well.
// =============================================================================

module RR (
    input  wire        clk,
    input  wire        rst,

    // ====================================================================
    // rr_latches_t (latches_i)
    //   normal_latches : rr_latches_general_t
    //   rep_latches    : rr_latches_general_t
    // ====================================================================

    // -------- normal_latches ------------------------------------------------
    input  wire        latches_normal_latches_valid,

    // rr_cs_t (normal_latches.cs)
    input  wire        latches_normal_latches_cs_ST_SEL,
    input  wire        latches_normal_latches_cs_MODRM_NEEDED,
    input  wire        latches_normal_latches_cs_RM_IS_DR,
    input  wire        latches_normal_latches_cs_SWITCH_LD_ADDY,
    input  wire        latches_normal_latches_cs_LD_OP,
    input  wire        latches_normal_latches_cs_ST_OP,
    input  wire [4:0]  latches_normal_latches_cs_dr_id,
    input  wire [4:0]  latches_normal_latches_cs_sr_id,
    input  wire        latches_normal_latches_cs_dr_rd,
    input  wire        latches_normal_latches_cs_sr_rd,
    input  wire        latches_normal_latches_cs_eax_rd,
    input  wire        latches_normal_latches_cs_dr_wr,
    input  wire        latches_normal_latches_cs_sr_wr,
    input  wire        latches_normal_latches_cs_eax_wr,
    input  wire        latches_normal_latches_cs_MOVS_OP,
    input  wire [1:0]  latches_normal_latches_cs_datasize,
    input  wire        latches_normal_latches_cs_will_mod_zf,
    input  wire        latches_normal_latches_cs_seg_1_valid,
    input  wire [4:0]  latches_normal_latches_cs_seg_0_id,
    input  wire [4:0]  latches_normal_latches_cs_seg_1_id,
    input  wire        latches_normal_latches_cs_special_modrm_bs,
    input  wire        latches_normal_latches_cs_special_br,

    // dc_cs_t (normal_latches.dc_cs) -- pass-through to dc_latches_next.cs
    input  wire        latches_normal_latches_dc_cs_LD_OP,
    input  wire        latches_normal_latches_dc_cs_ST_OP,
    input  wire        latches_normal_latches_dc_cs_dr_upper8,
    input  wire        latches_normal_latches_dc_cs_sr_upper8,
    input  wire [1:0]  latches_normal_latches_dc_cs_datasize,

    // mem_cs_t (normal_latches.mem_cs)
    input  wire        latches_normal_latches_mem_cs_ST_OP,
    input  wire        latches_normal_latches_mem_cs_LD_OP,

    // exe_cs_t (normal_latches.exe_cs)
    input  wire        latches_normal_latches_exe_cs_ST_OP,
    input  wire [5:0]  latches_normal_latches_exe_cs_OP_TYPE,
    input  wire [4:0]  latches_normal_latches_exe_cs_alu_inputA_sel,
    input  wire [4:0]  latches_normal_latches_exe_cs_alu_inputB_sel,
    input  wire [4:0]  latches_normal_latches_exe_cs_branch_target_sel,
    input  wire        latches_normal_latches_exe_cs_shift_by_one,
    input  wire        latches_normal_latches_exe_cs_br_ucond,
    input  wire        latches_normal_latches_exe_cs_relative_branch,
    input  wire        latches_normal_latches_exe_cs_special_br,
    input  wire        latches_normal_latches_exe_cs_is_far,
    input  wire        latches_normal_latches_exe_cs_is_call,
    input  wire        latches_normal_latches_exe_cs_second_flag_needed,
    input  wire        latches_normal_latches_exe_cs_rep_no_zf_update,

    // wb_cs_t (normal_latches.wb_cs)
    input  wire        latches_normal_latches_wb_cs_ST_OP,
    input  wire        latches_normal_latches_wb_cs_WB_DR,
    input  wire        latches_normal_latches_wb_cs_WB_SR,
    input  wire        latches_normal_latches_wb_cs_WB_EAX,

    // br_info_t (normal_latches.br_info)
    input  wire        latches_normal_latches_br_info_valid,
    input  wire [31:0] latches_normal_latches_br_info_br_eip,
    input  wire        latches_normal_latches_br_info_br_xcl,
    input  wire        latches_normal_latches_br_info_br_pred_taken,
    input  wire [31:0] latches_normal_latches_br_info_speculative_target,

    input  wire [31:0] latches_normal_latches_NEIP,
    input  wire [31:0] latches_normal_latches_EIP,
    input  wire [31:0] latches_normal_latches_EAX,
    input  wire [63:0] latches_normal_latches_imm64,

    input  wire [4:0]  latches_normal_latches_sib_idx_id,
    input  wire [4:0]  latches_normal_latches_sib_base_id,
    input  wire        latches_normal_latches_sib_needed,
    input  wire [7:0]  latches_normal_latches_sib_scale,
    input  wire        latches_normal_latches_disp_needed,
    input  wire        latches_normal_latches_disp_size,
    input  wire [31:0] latches_normal_latches_displacement,

    // -------- rep_latches ---------------------------------------------------
    input  wire        latches_rep_latches_valid,

    // rr_cs_t (rep_latches.cs)
    input  wire        latches_rep_latches_cs_ST_SEL,
    input  wire        latches_rep_latches_cs_MODRM_NEEDED,
    input  wire        latches_rep_latches_cs_RM_IS_DR,
    input  wire        latches_rep_latches_cs_SWITCH_LD_ADDY,
    input  wire        latches_rep_latches_cs_LD_OP,
    input  wire        latches_rep_latches_cs_ST_OP,
    input  wire [4:0]  latches_rep_latches_cs_dr_id,
    input  wire [4:0]  latches_rep_latches_cs_sr_id,
    input  wire        latches_rep_latches_cs_dr_rd,
    input  wire        latches_rep_latches_cs_sr_rd,
    input  wire        latches_rep_latches_cs_eax_rd,
    input  wire        latches_rep_latches_cs_dr_wr,
    input  wire        latches_rep_latches_cs_sr_wr,
    input  wire        latches_rep_latches_cs_eax_wr,
    input  wire        latches_rep_latches_cs_MOVS_OP,
    input  wire [1:0]  latches_rep_latches_cs_datasize,
    input  wire        latches_rep_latches_cs_will_mod_zf,
    input  wire        latches_rep_latches_cs_seg_1_valid,
    input  wire [4:0]  latches_rep_latches_cs_seg_0_id,
    input  wire [4:0]  latches_rep_latches_cs_seg_1_id,
    input  wire        latches_rep_latches_cs_special_modrm_bs,
    input  wire        latches_rep_latches_cs_special_br,

    // dc_cs_t (rep_latches.dc_cs)
    input  wire        latches_rep_latches_dc_cs_LD_OP,
    input  wire        latches_rep_latches_dc_cs_ST_OP,
    input  wire        latches_rep_latches_dc_cs_dr_upper8,
    input  wire        latches_rep_latches_dc_cs_sr_upper8,
    input  wire [1:0]  latches_rep_latches_dc_cs_datasize,

    // mem_cs_t (rep_latches.mem_cs)
    input  wire        latches_rep_latches_mem_cs_ST_OP,
    input  wire        latches_rep_latches_mem_cs_LD_OP,

    // exe_cs_t (rep_latches.exe_cs)
    input  wire        latches_rep_latches_exe_cs_ST_OP,
    input  wire [5:0]  latches_rep_latches_exe_cs_OP_TYPE,
    input  wire [4:0]  latches_rep_latches_exe_cs_alu_inputA_sel,
    input  wire [4:0]  latches_rep_latches_exe_cs_alu_inputB_sel,
    input  wire [4:0]  latches_rep_latches_exe_cs_branch_target_sel,
    input  wire        latches_rep_latches_exe_cs_shift_by_one,
    input  wire        latches_rep_latches_exe_cs_br_ucond,
    input  wire        latches_rep_latches_exe_cs_relative_branch,
    input  wire        latches_rep_latches_exe_cs_special_br,
    input  wire        latches_rep_latches_exe_cs_is_far,
    input  wire        latches_rep_latches_exe_cs_is_call,
    input  wire        latches_rep_latches_exe_cs_second_flag_needed,
    input  wire        latches_rep_latches_exe_cs_rep_no_zf_update,

    // wb_cs_t (rep_latches.wb_cs)
    input  wire        latches_rep_latches_wb_cs_ST_OP,
    input  wire        latches_rep_latches_wb_cs_WB_DR,
    input  wire        latches_rep_latches_wb_cs_WB_SR,
    input  wire        latches_rep_latches_wb_cs_WB_EAX,

    // br_info_t (rep_latches.br_info)
    input  wire        latches_rep_latches_br_info_valid,
    input  wire [31:0] latches_rep_latches_br_info_br_eip,
    input  wire        latches_rep_latches_br_info_br_xcl,
    input  wire        latches_rep_latches_br_info_br_pred_taken,
    input  wire [31:0] latches_rep_latches_br_info_speculative_target,

    input  wire [31:0] latches_rep_latches_NEIP,
    input  wire [31:0] latches_rep_latches_EIP,
    input  wire [31:0] latches_rep_latches_EAX,
    input  wire [63:0] latches_rep_latches_imm64,

    input  wire [4:0]  latches_rep_latches_sib_idx_id,
    input  wire [4:0]  latches_rep_latches_sib_base_id,
    input  wire        latches_rep_latches_sib_needed,
    input  wire [7:0]  latches_rep_latches_sib_scale,
    input  wire        latches_rep_latches_disp_needed,
    input  wire        latches_rep_latches_disp_size,
    input  wire [31:0] latches_rep_latches_displacement,

    // ====================================================================
    // fetch_outputs_t (fetch_outs_i) -- only exp_pipe_clear consumed
    // ====================================================================
    input  wire        fetch_outs_exp_pipe_clear,

    // ====================================================================
    // decode_outputs_t (decode_outs_i) -- rep_latch + decode_gp consumed
    // ====================================================================
    input  wire        decode_outs_rep_latch,
    input  wire        decode_outs_decode_gp,

    // ====================================================================
    // dc_outputs_t (dc_outs_i) -- valid + stall consumed
    // ====================================================================
    input  wire        dc_outs_valid,
    input  wire        dc_outs_stall,

    // ====================================================================
    // mem_outputs_t (mem_outs_i) -- valid + stall consumed
    // ====================================================================
    input  wire        mem_outs_valid,
    input  wire        mem_outs_stall,

    // ====================================================================
    // exe_outputs_t (exe_outs_i)
    // ====================================================================
    input  wire        exe_outs_valid,
    input  wire        exe_outs_br_res_flush,
    input  wire        exe_outs_br_res_farFlush,
    input  wire        exe_outs_br_res_callFlush,
    input  wire        exe_outs_DR_0_we,
    input  wire [4:0]  exe_outs_DR_0_id,
    input  wire [63:0] exe_outs_DR_0_data,
    input  wire        exe_outs_DR_1_we,
    input  wire [4:0]  exe_outs_DR_1_id,
    input  wire [63:0] exe_outs_DR_1_data,

    // ====================================================================
    // wb_outputs_t (wb_outs_i) -- only wb_stall consumed
    // ====================================================================
    input  wire        wb_outs_wb_stall,

    // ====================================================================
    // dc_latches_t (dc_latches_next)
    // ====================================================================
    output wire        dc_latches_next_valid,

    // dc_cs_t (dc_latches_next.cs)
    output wire        dc_latches_next_cs_LD_OP,
    output wire        dc_latches_next_cs_ST_OP,
    output wire        dc_latches_next_cs_dr_upper8,
    output wire        dc_latches_next_cs_sr_upper8,
    output wire [1:0]  dc_latches_next_cs_datasize,

    // mem_cs_t (dc_latches_next.mem_cs)
    output wire        dc_latches_next_mem_cs_ST_OP,
    output wire        dc_latches_next_mem_cs_LD_OP,

    // exe_cs_t (dc_latches_next.exe_cs)
    output wire        dc_latches_next_exe_cs_ST_OP,
    output wire [5:0]  dc_latches_next_exe_cs_OP_TYPE,
    output wire [4:0]  dc_latches_next_exe_cs_alu_inputA_sel,
    output wire [4:0]  dc_latches_next_exe_cs_alu_inputB_sel,
    output wire [4:0]  dc_latches_next_exe_cs_branch_target_sel,
    output wire        dc_latches_next_exe_cs_shift_by_one,
    output wire        dc_latches_next_exe_cs_br_ucond,
    output wire        dc_latches_next_exe_cs_relative_branch,
    output wire        dc_latches_next_exe_cs_special_br,
    output wire        dc_latches_next_exe_cs_is_far,
    output wire        dc_latches_next_exe_cs_is_call,
    output wire        dc_latches_next_exe_cs_second_flag_needed,
    output wire        dc_latches_next_exe_cs_rep_no_zf_update,

    // wb_cs_t (dc_latches_next.wb_cs)
    output wire        dc_latches_next_wb_cs_ST_OP,
    output wire        dc_latches_next_wb_cs_WB_DR,
    output wire        dc_latches_next_wb_cs_WB_SR,
    output wire        dc_latches_next_wb_cs_WB_EAX,

    // br_info_t (dc_latches_next.br_info)
    output wire        dc_latches_next_br_info_valid,
    output wire [31:0] dc_latches_next_br_info_br_eip,
    output wire        dc_latches_next_br_info_br_xcl,
    output wire        dc_latches_next_br_info_br_pred_taken,
    output wire [31:0] dc_latches_next_br_info_speculative_target,

    output wire        dc_latches_next_rr_gp,

    // load-side address / segmentation
    output wire [31:0] dc_latches_next_ld_vaddy,
    output wire [31:0] dc_latches_next_seg0_limit_w_datasize,
    output wire [31:0] dc_latches_next_seg0_limit_wo_datasize,
    output wire [31:0] dc_latches_next_next_ld_vaddy,
    output wire [31:0] dc_latches_next_ld_laddy,
    output wire        dc_latches_next_ld_stack_access,

    // store-side address / segmentation
    output wire [31:0] dc_latches_next_st_vaddy,
    output wire [31:0] dc_latches_next_seg1_limit_w_datasize,
    output wire [31:0] dc_latches_next_seg1_limit_wo_datasize,
    output wire [31:0] dc_latches_next_next_st_vaddy,
    output wire [31:0] dc_latches_next_st_laddy,
    output wire        dc_latches_next_st_stack_access,

    output wire [31:0] dc_latches_next_NEIP,
    output wire [31:0] dc_latches_next_EIP,
    output wire [31:0] dc_latches_next_EAX,
    output wire [63:0] dc_latches_next_imm64,

    output wire [4:0]  dc_latches_next_sr_id,
    output wire [63:0] dc_latches_next_sr_data,
    output wire [4:0]  dc_latches_next_dr_id,
    output wire [63:0] dc_latches_next_dr_data,

    // ====================================================================
    // rr_outputs_t (outs_o)
    // ====================================================================
    output wire        outs_valid,
    output wire        outs_stall,
    output wire        outs_ecx_sb,
    output wire [31:0] outs_ecx,
    output wire [31:0] outs_eax,
    output wire        outs_set_ZF_sb,
    output wire        outs_codeSeg_sb,
    output wire [31:0] outs_codeSeg_data,
    output wire [31:0] outs_codeSeg_limit,
    output wire        outs_dc_stage_latch_we,

    // regFileValues_o[NUM_REGS=26] -- one 64-bit port per reg id
    output wire [63:0] outs_regFileValues_0,    // CS
    output wire [63:0] outs_regFileValues_1,    // DS
    output wire [63:0] outs_regFileValues_2,    // SS
    output wire [63:0] outs_regFileValues_3,    // ES
    output wire [63:0] outs_regFileValues_4,    // FS
    output wire [63:0] outs_regFileValues_5,    // GS
    output wire [63:0] outs_regFileValues_6,    // EXPS
    output wire [63:0] outs_regFileValues_7,    // EAX
    output wire [63:0] outs_regFileValues_8,    // EBX
    output wire [63:0] outs_regFileValues_9,    // ECX
    output wire [63:0] outs_regFileValues_10,   // EDX
    output wire [63:0] outs_regFileValues_11,   // ESI
    output wire [63:0] outs_regFileValues_12,   // EDI
    output wire [63:0] outs_regFileValues_13,   // ESP
    output wire [63:0] outs_regFileValues_14,   // EBP
    output wire [63:0] outs_regFileValues_15,   // MM0
    output wire [63:0] outs_regFileValues_16,   // MM1
    output wire [63:0] outs_regFileValues_17,   // MM2
    output wire [63:0] outs_regFileValues_18,   // MM3
    output wire [63:0] outs_regFileValues_19,   // MM4
    output wire [63:0] outs_regFileValues_20,   // MM5
    output wire [63:0] outs_regFileValues_21,   // MM6
    output wire [63:0] outs_regFileValues_22,   // MM7
    output wire [63:0] outs_regFileValues_23,   // ETR
    output wire [63:0] outs_regFileValues_24,   // ERROR_REG
    output wire [63:0] outs_regFileValues_25    // NO_REG
);

    // -------------------------------------------------------------------------
    // reg_ids_e literal helpers (kept readable; widths match reg_ids_e = 5)
    // -------------------------------------------------------------------------
    localparam [4:0] REG_ID_CS = 5'd0;
    localparam [4:0] REG_ID_SS = 5'd2;

    // =========================================================================
    // latchesInUse mux: pick rep_latches when decode_outs_rep_latch is high,
    // else normal_latches. One MUX_2 per used field.  Naming convention
    // mirrors the original SV `latchesInUse.<path>` (with `.` -> `_`).
    // =========================================================================
    wire        latchesInUse_valid;

    // rr_cs_t
    wire        latchesInUse_cs_ST_SEL;
    wire        latchesInUse_cs_MODRM_NEEDED;
    wire        latchesInUse_cs_RM_IS_DR;
    wire        latchesInUse_cs_SWITCH_LD_ADDY;
    wire        latchesInUse_cs_LD_OP;
    wire        latchesInUse_cs_ST_OP;
    wire [4:0]  latchesInUse_cs_dr_id;
    wire [4:0]  latchesInUse_cs_sr_id;
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
    wire [4:0]  latchesInUse_cs_seg_0_id;
    wire [4:0]  latchesInUse_cs_seg_1_id;
    wire        latchesInUse_cs_special_modrm_bs;
    wire        latchesInUse_cs_special_br;

    // dc_cs_t
    wire        latchesInUse_dc_cs_LD_OP;
    wire        latchesInUse_dc_cs_ST_OP;
    wire        latchesInUse_dc_cs_dr_upper8;
    wire        latchesInUse_dc_cs_sr_upper8;
    wire [1:0]  latchesInUse_dc_cs_datasize;

    // mem_cs_t
    wire        latchesInUse_mem_cs_ST_OP;
    wire        latchesInUse_mem_cs_LD_OP;

    // exe_cs_t
    wire        latchesInUse_exe_cs_ST_OP;
    wire [5:0]  latchesInUse_exe_cs_OP_TYPE;
    wire [4:0]  latchesInUse_exe_cs_alu_inputA_sel;
    wire [4:0]  latchesInUse_exe_cs_alu_inputB_sel;
    wire [4:0]  latchesInUse_exe_cs_branch_target_sel;
    wire        latchesInUse_exe_cs_shift_by_one;
    wire        latchesInUse_exe_cs_br_ucond;
    wire        latchesInUse_exe_cs_relative_branch;
    wire        latchesInUse_exe_cs_special_br;
    wire        latchesInUse_exe_cs_is_far;
    wire        latchesInUse_exe_cs_is_call;
    wire        latchesInUse_exe_cs_second_flag_needed;
    wire        latchesInUse_exe_cs_rep_no_zf_update;

    // wb_cs_t
    wire        latchesInUse_wb_cs_ST_OP;
    wire        latchesInUse_wb_cs_WB_DR;
    wire        latchesInUse_wb_cs_WB_SR;
    wire        latchesInUse_wb_cs_WB_EAX;

    // br_info_t
    wire        latchesInUse_br_info_valid;
    wire [31:0] latchesInUse_br_info_br_eip;
    wire        latchesInUse_br_info_br_xcl;
    wire        latchesInUse_br_info_br_pred_taken;
    wire [31:0] latchesInUse_br_info_speculative_target;

    wire [31:0] latchesInUse_NEIP;
    wire [31:0] latchesInUse_EIP;
    wire [31:0] latchesInUse_EAX;       // unused -- dc_latches.EAX comes from RegFile
    wire [63:0] latchesInUse_imm64;

    wire [4:0]  latchesInUse_sib_idx_id;
    wire [4:0]  latchesInUse_sib_base_id;
    wire        latchesInUse_sib_needed;
    wire [7:0]  latchesInUse_sib_scale;
    wire        latchesInUse_disp_needed;
    wire        latchesInUse_disp_size;
    wire [31:0] latchesInUse_displacement;

    // -- MUX_2 instances (sel=0 -> normal_latches, sel=1 -> rep_latches) ----
    `MUX_2(u_mx_valid,                  1, latchesInUse_valid,
        latches_normal_latches_valid,   latches_rep_latches_valid, decode_outs_rep_latch)

    // rr_cs_t
    wire latchesInUse_cs_ST_SEL_pre;
    `MUX_2(u_mx_cs_ST_SEL,              1, latchesInUse_cs_ST_SEL_pre,
        latches_normal_latches_cs_ST_SEL,         latches_rep_latches_cs_ST_SEL,         decode_outs_rep_latch)
    bufferH256$ u_buf_cs_ST_SEL (.out(latchesInUse_cs_ST_SEL), .in(latchesInUse_cs_ST_SEL_pre));
    `MUX_2(u_mx_cs_MODRM_NEEDED,        1, latchesInUse_cs_MODRM_NEEDED,
        latches_normal_latches_cs_MODRM_NEEDED,   latches_rep_latches_cs_MODRM_NEEDED,   decode_outs_rep_latch)
    `MUX_2(u_mx_cs_RM_IS_DR,            1, latchesInUse_cs_RM_IS_DR,
        latches_normal_latches_cs_RM_IS_DR,       latches_rep_latches_cs_RM_IS_DR,       decode_outs_rep_latch)
    wire latchesInUse_cs_SWITCH_LD_ADDY_pre;
    `MUX_2(u_mx_cs_SWITCH_LD_ADDY,      1, latchesInUse_cs_SWITCH_LD_ADDY_pre,
        latches_normal_latches_cs_SWITCH_LD_ADDY, latches_rep_latches_cs_SWITCH_LD_ADDY, decode_outs_rep_latch)
    bufferH256$ u_buf_cs_SWITCH_LD_ADDY (.out(latchesInUse_cs_SWITCH_LD_ADDY), .in(latchesInUse_cs_SWITCH_LD_ADDY_pre));
    `MUX_2(u_mx_cs_LD_OP,               1, latchesInUse_cs_LD_OP,
        latches_normal_latches_cs_LD_OP,          latches_rep_latches_cs_LD_OP,          decode_outs_rep_latch)
    `MUX_2(u_mx_cs_ST_OP,               1, latchesInUse_cs_ST_OP,
        latches_normal_latches_cs_ST_OP,          latches_rep_latches_cs_ST_OP,          decode_outs_rep_latch)
    `MUX_2(u_mx_cs_dr_id,               5, latchesInUse_cs_dr_id,
        latches_normal_latches_cs_dr_id,          latches_rep_latches_cs_dr_id,          decode_outs_rep_latch)
    `MUX_2(u_mx_cs_sr_id,               5, latchesInUse_cs_sr_id,
        latches_normal_latches_cs_sr_id,          latches_rep_latches_cs_sr_id,          decode_outs_rep_latch)
    `MUX_2(u_mx_cs_dr_rd,               1, latchesInUse_cs_dr_rd,
        latches_normal_latches_cs_dr_rd,          latches_rep_latches_cs_dr_rd,          decode_outs_rep_latch)
    `MUX_2(u_mx_cs_sr_rd,               1, latchesInUse_cs_sr_rd,
        latches_normal_latches_cs_sr_rd,          latches_rep_latches_cs_sr_rd,          decode_outs_rep_latch)
    `MUX_2(u_mx_cs_eax_rd,              1, latchesInUse_cs_eax_rd,
        latches_normal_latches_cs_eax_rd,         latches_rep_latches_cs_eax_rd,         decode_outs_rep_latch)
    `MUX_2(u_mx_cs_dr_wr,               1, latchesInUse_cs_dr_wr,
        latches_normal_latches_cs_dr_wr,          latches_rep_latches_cs_dr_wr,          decode_outs_rep_latch)
    `MUX_2(u_mx_cs_sr_wr,               1, latchesInUse_cs_sr_wr,
        latches_normal_latches_cs_sr_wr,          latches_rep_latches_cs_sr_wr,          decode_outs_rep_latch)
    `MUX_2(u_mx_cs_eax_wr,              1, latchesInUse_cs_eax_wr,
        latches_normal_latches_cs_eax_wr,         latches_rep_latches_cs_eax_wr,         decode_outs_rep_latch)
    wire latchesInUse_cs_MOVS_OP_pre;
    `MUX_2(u_mx_cs_MOVS_OP,             1, latchesInUse_cs_MOVS_OP_pre,
        latches_normal_latches_cs_MOVS_OP,        latches_rep_latches_cs_MOVS_OP,        decode_outs_rep_latch)
    bufferH256$ u_buf_cs_MOVS_OP (.out(latchesInUse_cs_MOVS_OP), .in(latchesInUse_cs_MOVS_OP_pre));

    wire [1:0] latchesInUse_cs_datasize_pre;
    `MUX_2(u_mx_cs_datasize,            2, latchesInUse_cs_datasize_pre,
        latches_normal_latches_cs_datasize,       latches_rep_latches_cs_datasize,       decode_outs_rep_latch)
    bufferH256$ u_buf_cs_datasize_0 (.out(latchesInUse_cs_datasize[0]), .in(latchesInUse_cs_datasize_pre[0]));
    bufferH256$ u_buf_cs_datasize_1 (.out(latchesInUse_cs_datasize[1]), .in(latchesInUse_cs_datasize_pre[1]));
    `MUX_2(u_mx_cs_will_mod_zf,         1, latchesInUse_cs_will_mod_zf,
        latches_normal_latches_cs_will_mod_zf,    latches_rep_latches_cs_will_mod_zf,    decode_outs_rep_latch)
    wire latchesInUse_cs_seg_1_valid_pre;
    `MUX_2(u_mx_cs_seg_1_valid,         1, latchesInUse_cs_seg_1_valid_pre,
        latches_normal_latches_cs_seg_1_valid,    latches_rep_latches_cs_seg_1_valid,    decode_outs_rep_latch)
    bufferH256$ u_buf_cs_seg_1_valid (.out(latchesInUse_cs_seg_1_valid), .in(latchesInUse_cs_seg_1_valid_pre));
    // 5-bit ID broadcasts feed RegFile read-mux selects + RegSB equality comparators
    // — fanout 282-347 per bit. bufferH1024$ per bit (rated 1024, delay 0.60ns).
    wire [4:0] latchesInUse_cs_seg_0_id_pre;
    `MUX_2(u_mx_cs_seg_0_id,            5, latchesInUse_cs_seg_0_id_pre,
        latches_normal_latches_cs_seg_0_id,       latches_rep_latches_cs_seg_0_id,       decode_outs_rep_latch)
    bufferH1024$ u_buf_cs_seg_0_id_0 (.out(latchesInUse_cs_seg_0_id[0]), .in(latchesInUse_cs_seg_0_id_pre[0]));
    bufferH1024$ u_buf_cs_seg_0_id_1 (.out(latchesInUse_cs_seg_0_id[1]), .in(latchesInUse_cs_seg_0_id_pre[1]));
    bufferH1024$ u_buf_cs_seg_0_id_2 (.out(latchesInUse_cs_seg_0_id[2]), .in(latchesInUse_cs_seg_0_id_pre[2]));
    bufferH1024$ u_buf_cs_seg_0_id_3 (.out(latchesInUse_cs_seg_0_id[3]), .in(latchesInUse_cs_seg_0_id_pre[3]));
    bufferH1024$ u_buf_cs_seg_0_id_4 (.out(latchesInUse_cs_seg_0_id[4]), .in(latchesInUse_cs_seg_0_id_pre[4]));

    wire [4:0] latchesInUse_cs_seg_1_id_pre;
    `MUX_2(u_mx_cs_seg_1_id,            5, latchesInUse_cs_seg_1_id_pre,
        latches_normal_latches_cs_seg_1_id,       latches_rep_latches_cs_seg_1_id,       decode_outs_rep_latch)
    bufferH1024$ u_buf_cs_seg_1_id_0 (.out(latchesInUse_cs_seg_1_id[0]), .in(latchesInUse_cs_seg_1_id_pre[0]));
    bufferH1024$ u_buf_cs_seg_1_id_1 (.out(latchesInUse_cs_seg_1_id[1]), .in(latchesInUse_cs_seg_1_id_pre[1]));
    bufferH1024$ u_buf_cs_seg_1_id_2 (.out(latchesInUse_cs_seg_1_id[2]), .in(latchesInUse_cs_seg_1_id_pre[2]));
    bufferH1024$ u_buf_cs_seg_1_id_3 (.out(latchesInUse_cs_seg_1_id[3]), .in(latchesInUse_cs_seg_1_id_pre[3]));
    bufferH1024$ u_buf_cs_seg_1_id_4 (.out(latchesInUse_cs_seg_1_id[4]), .in(latchesInUse_cs_seg_1_id_pre[4]));
    wire latchesInUse_cs_special_modrm_bs_pre;
    `MUX_2(u_mx_cs_special_modrm_bs,    1, latchesInUse_cs_special_modrm_bs_pre,
        latches_normal_latches_cs_special_modrm_bs, latches_rep_latches_cs_special_modrm_bs, decode_outs_rep_latch)
    bufferH64$ u_buf_cs_special_modrm_bs (.out(latchesInUse_cs_special_modrm_bs), .in(latchesInUse_cs_special_modrm_bs_pre));

    wire latchesInUse_cs_special_br_pre;
    `MUX_2(u_mx_cs_special_br,          1, latchesInUse_cs_special_br_pre,
        latches_normal_latches_cs_special_br,     latches_rep_latches_cs_special_br,     decode_outs_rep_latch)
    bufferH64$ u_buf_cs_special_br (.out(latchesInUse_cs_special_br), .in(latchesInUse_cs_special_br_pre));

    // dc_cs_t
    `MUX_2(u_mx_dc_cs_LD_OP,            1, latchesInUse_dc_cs_LD_OP,
        latches_normal_latches_dc_cs_LD_OP,       latches_rep_latches_dc_cs_LD_OP,       decode_outs_rep_latch)
    `MUX_2(u_mx_dc_cs_ST_OP,            1, latchesInUse_dc_cs_ST_OP,
        latches_normal_latches_dc_cs_ST_OP,       latches_rep_latches_dc_cs_ST_OP,       decode_outs_rep_latch)
    `MUX_2(u_mx_dc_cs_dr_upper8,        1, latchesInUse_dc_cs_dr_upper8,
        latches_normal_latches_dc_cs_dr_upper8,   latches_rep_latches_dc_cs_dr_upper8,   decode_outs_rep_latch)
    `MUX_2(u_mx_dc_cs_sr_upper8,        1, latchesInUse_dc_cs_sr_upper8,
        latches_normal_latches_dc_cs_sr_upper8,   latches_rep_latches_dc_cs_sr_upper8,   decode_outs_rep_latch)
    `MUX_2(u_mx_dc_cs_datasize,         2, latchesInUse_dc_cs_datasize,
        latches_normal_latches_dc_cs_datasize,    latches_rep_latches_dc_cs_datasize,    decode_outs_rep_latch)

    // mem_cs_t
    `MUX_2(u_mx_mem_cs_ST_OP,           1, latchesInUse_mem_cs_ST_OP,
        latches_normal_latches_mem_cs_ST_OP,      latches_rep_latches_mem_cs_ST_OP,      decode_outs_rep_latch)
    `MUX_2(u_mx_mem_cs_LD_OP,           1, latchesInUse_mem_cs_LD_OP,
        latches_normal_latches_mem_cs_LD_OP,      latches_rep_latches_mem_cs_LD_OP,      decode_outs_rep_latch)

    // exe_cs_t
    `MUX_2(u_mx_exe_cs_ST_OP,                1, latchesInUse_exe_cs_ST_OP,
        latches_normal_latches_exe_cs_ST_OP,             latches_rep_latches_exe_cs_ST_OP,             decode_outs_rep_latch)
    `MUX_2(u_mx_exe_cs_OP_TYPE,              6, latchesInUse_exe_cs_OP_TYPE,
        latches_normal_latches_exe_cs_OP_TYPE,           latches_rep_latches_exe_cs_OP_TYPE,           decode_outs_rep_latch)
    `MUX_2(u_mx_exe_cs_alu_inputA_sel,       5, latchesInUse_exe_cs_alu_inputA_sel,
        latches_normal_latches_exe_cs_alu_inputA_sel,    latches_rep_latches_exe_cs_alu_inputA_sel,    decode_outs_rep_latch)
    `MUX_2(u_mx_exe_cs_alu_inputB_sel,       5, latchesInUse_exe_cs_alu_inputB_sel,
        latches_normal_latches_exe_cs_alu_inputB_sel,    latches_rep_latches_exe_cs_alu_inputB_sel,    decode_outs_rep_latch)
    `MUX_2(u_mx_exe_cs_branch_target_sel,    5, latchesInUse_exe_cs_branch_target_sel,
        latches_normal_latches_exe_cs_branch_target_sel, latches_rep_latches_exe_cs_branch_target_sel, decode_outs_rep_latch)
    `MUX_2(u_mx_exe_cs_shift_by_one,         1, latchesInUse_exe_cs_shift_by_one,
        latches_normal_latches_exe_cs_shift_by_one,      latches_rep_latches_exe_cs_shift_by_one,      decode_outs_rep_latch)
    `MUX_2(u_mx_exe_cs_br_ucond,             1, latchesInUse_exe_cs_br_ucond,
        latches_normal_latches_exe_cs_br_ucond,          latches_rep_latches_exe_cs_br_ucond,          decode_outs_rep_latch)
    `MUX_2(u_mx_exe_cs_relative_branch,      1, latchesInUse_exe_cs_relative_branch,
        latches_normal_latches_exe_cs_relative_branch,   latches_rep_latches_exe_cs_relative_branch,   decode_outs_rep_latch)
    `MUX_2(u_mx_exe_cs_special_br,           1, latchesInUse_exe_cs_special_br,
        latches_normal_latches_exe_cs_special_br,        latches_rep_latches_exe_cs_special_br,        decode_outs_rep_latch)
    `MUX_2(u_mx_exe_cs_is_far,               1, latchesInUse_exe_cs_is_far,
        latches_normal_latches_exe_cs_is_far,            latches_rep_latches_exe_cs_is_far,            decode_outs_rep_latch)
    `MUX_2(u_mx_exe_cs_is_call,              1, latchesInUse_exe_cs_is_call,
        latches_normal_latches_exe_cs_is_call,           latches_rep_latches_exe_cs_is_call,           decode_outs_rep_latch)
    `MUX_2(u_mx_exe_cs_second_flag_needed,   1, latchesInUse_exe_cs_second_flag_needed,
        latches_normal_latches_exe_cs_second_flag_needed, latches_rep_latches_exe_cs_second_flag_needed, decode_outs_rep_latch)
    `MUX_2(u_mx_exe_cs_rep_no_zf_update,     1, latchesInUse_exe_cs_rep_no_zf_update,
        latches_normal_latches_exe_cs_rep_no_zf_update,  latches_rep_latches_exe_cs_rep_no_zf_update,  decode_outs_rep_latch)

    // wb_cs_t
    `MUX_2(u_mx_wb_cs_ST_OP,            1, latchesInUse_wb_cs_ST_OP,
        latches_normal_latches_wb_cs_ST_OP,       latches_rep_latches_wb_cs_ST_OP,       decode_outs_rep_latch)
    `MUX_2(u_mx_wb_cs_WB_DR,            1, latchesInUse_wb_cs_WB_DR,
        latches_normal_latches_wb_cs_WB_DR,       latches_rep_latches_wb_cs_WB_DR,       decode_outs_rep_latch)
    `MUX_2(u_mx_wb_cs_WB_SR,            1, latchesInUse_wb_cs_WB_SR,
        latches_normal_latches_wb_cs_WB_SR,       latches_rep_latches_wb_cs_WB_SR,       decode_outs_rep_latch)
    `MUX_2(u_mx_wb_cs_WB_EAX,           1, latchesInUse_wb_cs_WB_EAX,
        latches_normal_latches_wb_cs_WB_EAX,      latches_rep_latches_wb_cs_WB_EAX,      decode_outs_rep_latch)

    // br_info_t
    `MUX_2(u_mx_br_info_valid,                1, latchesInUse_br_info_valid,
        latches_normal_latches_br_info_valid,             latches_rep_latches_br_info_valid,             decode_outs_rep_latch)
    `MUX_2(u_mx_br_info_br_eip,              32, latchesInUse_br_info_br_eip,
        latches_normal_latches_br_info_br_eip,            latches_rep_latches_br_info_br_eip,            decode_outs_rep_latch)
    `MUX_2(u_mx_br_info_br_xcl,               1, latchesInUse_br_info_br_xcl,
        latches_normal_latches_br_info_br_xcl,            latches_rep_latches_br_info_br_xcl,            decode_outs_rep_latch)
    `MUX_2(u_mx_br_info_br_pred_taken,        1, latchesInUse_br_info_br_pred_taken,
        latches_normal_latches_br_info_br_pred_taken,     latches_rep_latches_br_info_br_pred_taken,     decode_outs_rep_latch)
    `MUX_2(u_mx_br_info_speculative_target,  32, latchesInUse_br_info_speculative_target,
        latches_normal_latches_br_info_speculative_target, latches_rep_latches_br_info_speculative_target, decode_outs_rep_latch)

    // scalars
    `MUX_2(u_mx_NEIP,        32, latchesInUse_NEIP,
        latches_normal_latches_NEIP,         latches_rep_latches_NEIP,         decode_outs_rep_latch)
    `MUX_2(u_mx_EIP,         32, latchesInUse_EIP,
        latches_normal_latches_EIP,          latches_rep_latches_EIP,          decode_outs_rep_latch)
    `MUX_2(u_mx_EAX,         32, latchesInUse_EAX,
        latches_normal_latches_EAX,          latches_rep_latches_EAX,          decode_outs_rep_latch)
    `MUX_2(u_mx_imm64,       64, latchesInUse_imm64,
        latches_normal_latches_imm64,        latches_rep_latches_imm64,        decode_outs_rep_latch)
    wire [4:0] latchesInUse_sib_idx_id_pre;
    `MUX_2(u_mx_sib_idx_id,   5, latchesInUse_sib_idx_id_pre,
        latches_normal_latches_sib_idx_id,   latches_rep_latches_sib_idx_id,   decode_outs_rep_latch)
    bufferH1024$ u_buf_sib_idx_id_0 (.out(latchesInUse_sib_idx_id[0]), .in(latchesInUse_sib_idx_id_pre[0]));
    bufferH1024$ u_buf_sib_idx_id_1 (.out(latchesInUse_sib_idx_id[1]), .in(latchesInUse_sib_idx_id_pre[1]));
    bufferH1024$ u_buf_sib_idx_id_2 (.out(latchesInUse_sib_idx_id[2]), .in(latchesInUse_sib_idx_id_pre[2]));
    bufferH1024$ u_buf_sib_idx_id_3 (.out(latchesInUse_sib_idx_id[3]), .in(latchesInUse_sib_idx_id_pre[3]));
    bufferH1024$ u_buf_sib_idx_id_4 (.out(latchesInUse_sib_idx_id[4]), .in(latchesInUse_sib_idx_id_pre[4]));

    wire [4:0] latchesInUse_sib_base_id_pre;
    `MUX_2(u_mx_sib_base_id,  5, latchesInUse_sib_base_id_pre,
        latches_normal_latches_sib_base_id,  latches_rep_latches_sib_base_id,  decode_outs_rep_latch)
    bufferH1024$ u_buf_sib_base_id_0 (.out(latchesInUse_sib_base_id[0]), .in(latchesInUse_sib_base_id_pre[0]));
    bufferH1024$ u_buf_sib_base_id_1 (.out(latchesInUse_sib_base_id[1]), .in(latchesInUse_sib_base_id_pre[1]));
    bufferH1024$ u_buf_sib_base_id_2 (.out(latchesInUse_sib_base_id[2]), .in(latchesInUse_sib_base_id_pre[2]));
    bufferH1024$ u_buf_sib_base_id_3 (.out(latchesInUse_sib_base_id[3]), .in(latchesInUse_sib_base_id_pre[3]));
    bufferH1024$ u_buf_sib_base_id_4 (.out(latchesInUse_sib_base_id[4]), .in(latchesInUse_sib_base_id_pre[4]));
    wire latchesInUse_sib_needed_pre;
    `MUX_2(u_mx_sib_needed,   1, latchesInUse_sib_needed_pre,
        latches_normal_latches_sib_needed,   latches_rep_latches_sib_needed,   decode_outs_rep_latch)
    bufferH64$ u_buf_sib_needed (.out(latchesInUse_sib_needed), .in(latchesInUse_sib_needed_pre));

    wire [7:0] latchesInUse_sib_scale_pre;
    `MUX_2(u_mx_sib_scale,    8, latchesInUse_sib_scale_pre,
        latches_normal_latches_sib_scale,    latches_rep_latches_sib_scale,    decode_outs_rep_latch)
    bufferH64$ u_buf_sib_scale_0 (.out(latchesInUse_sib_scale[0]), .in(latchesInUse_sib_scale_pre[0]));
    bufferH64$ u_buf_sib_scale_1 (.out(latchesInUse_sib_scale[1]), .in(latchesInUse_sib_scale_pre[1]));
    bufferH64$ u_buf_sib_scale_2 (.out(latchesInUse_sib_scale[2]), .in(latchesInUse_sib_scale_pre[2]));
    bufferH64$ u_buf_sib_scale_3 (.out(latchesInUse_sib_scale[3]), .in(latchesInUse_sib_scale_pre[3]));
    bufferH64$ u_buf_sib_scale_4 (.out(latchesInUse_sib_scale[4]), .in(latchesInUse_sib_scale_pre[4]));
    bufferH64$ u_buf_sib_scale_5 (.out(latchesInUse_sib_scale[5]), .in(latchesInUse_sib_scale_pre[5]));
    bufferH64$ u_buf_sib_scale_6 (.out(latchesInUse_sib_scale[6]), .in(latchesInUse_sib_scale_pre[6]));
    bufferH64$ u_buf_sib_scale_7 (.out(latchesInUse_sib_scale[7]), .in(latchesInUse_sib_scale_pre[7]));

    wire latchesInUse_disp_needed_pre;
    `MUX_2(u_mx_disp_needed,  1, latchesInUse_disp_needed_pre,
        latches_normal_latches_disp_needed,  latches_rep_latches_disp_needed,  decode_outs_rep_latch)
    bufferH64$ u_buf_disp_needed (.out(latchesInUse_disp_needed), .in(latchesInUse_disp_needed_pre));
    wire latchesInUse_disp_size_pre;
    `MUX_2(u_mx_disp_size,    1, latchesInUse_disp_size_pre,
        latches_normal_latches_disp_size,    latches_rep_latches_disp_size,    decode_outs_rep_latch)
    bufferH64$ u_buf_disp_size (.out(latchesInUse_disp_size), .in(latchesInUse_disp_size_pre));

    wire [31:0] latchesInUse_displacement_pre;
    `MUX_2(u_mx_displacement,32, latchesInUse_displacement_pre,
        latches_normal_latches_displacement, latches_rep_latches_displacement, decode_outs_rep_latch)
    bufferH64$ u_buf_displacement_0  (.out(latchesInUse_displacement[0]),  .in(latchesInUse_displacement_pre[0]));
    bufferH64$ u_buf_displacement_1  (.out(latchesInUse_displacement[1]),  .in(latchesInUse_displacement_pre[1]));
    bufferH64$ u_buf_displacement_2  (.out(latchesInUse_displacement[2]),  .in(latchesInUse_displacement_pre[2]));
    bufferH64$ u_buf_displacement_3  (.out(latchesInUse_displacement[3]),  .in(latchesInUse_displacement_pre[3]));
    bufferH64$ u_buf_displacement_4  (.out(latchesInUse_displacement[4]),  .in(latchesInUse_displacement_pre[4]));
    bufferH64$ u_buf_displacement_5  (.out(latchesInUse_displacement[5]),  .in(latchesInUse_displacement_pre[5]));
    bufferH64$ u_buf_displacement_6  (.out(latchesInUse_displacement[6]),  .in(latchesInUse_displacement_pre[6]));
    bufferH64$ u_buf_displacement_7  (.out(latchesInUse_displacement[7]),  .in(latchesInUse_displacement_pre[7]));
    bufferH64$ u_buf_displacement_8  (.out(latchesInUse_displacement[8]),  .in(latchesInUse_displacement_pre[8]));
    bufferH64$ u_buf_displacement_9  (.out(latchesInUse_displacement[9]),  .in(latchesInUse_displacement_pre[9]));
    bufferH64$ u_buf_displacement_10 (.out(latchesInUse_displacement[10]), .in(latchesInUse_displacement_pre[10]));
    bufferH64$ u_buf_displacement_11 (.out(latchesInUse_displacement[11]), .in(latchesInUse_displacement_pre[11]));
    bufferH64$ u_buf_displacement_12 (.out(latchesInUse_displacement[12]), .in(latchesInUse_displacement_pre[12]));
    bufferH64$ u_buf_displacement_13 (.out(latchesInUse_displacement[13]), .in(latchesInUse_displacement_pre[13]));
    bufferH64$ u_buf_displacement_14 (.out(latchesInUse_displacement[14]), .in(latchesInUse_displacement_pre[14]));
    bufferH64$ u_buf_displacement_15 (.out(latchesInUse_displacement[15]), .in(latchesInUse_displacement_pre[15]));
    bufferH64$ u_buf_displacement_16 (.out(latchesInUse_displacement[16]), .in(latchesInUse_displacement_pre[16]));
    bufferH64$ u_buf_displacement_17 (.out(latchesInUse_displacement[17]), .in(latchesInUse_displacement_pre[17]));
    bufferH64$ u_buf_displacement_18 (.out(latchesInUse_displacement[18]), .in(latchesInUse_displacement_pre[18]));
    bufferH64$ u_buf_displacement_19 (.out(latchesInUse_displacement[19]), .in(latchesInUse_displacement_pre[19]));
    bufferH64$ u_buf_displacement_20 (.out(latchesInUse_displacement[20]), .in(latchesInUse_displacement_pre[20]));
    bufferH64$ u_buf_displacement_21 (.out(latchesInUse_displacement[21]), .in(latchesInUse_displacement_pre[21]));
    bufferH64$ u_buf_displacement_22 (.out(latchesInUse_displacement[22]), .in(latchesInUse_displacement_pre[22]));
    bufferH64$ u_buf_displacement_23 (.out(latchesInUse_displacement[23]), .in(latchesInUse_displacement_pre[23]));
    bufferH64$ u_buf_displacement_24 (.out(latchesInUse_displacement[24]), .in(latchesInUse_displacement_pre[24]));
    bufferH64$ u_buf_displacement_25 (.out(latchesInUse_displacement[25]), .in(latchesInUse_displacement_pre[25]));
    bufferH64$ u_buf_displacement_26 (.out(latchesInUse_displacement[26]), .in(latchesInUse_displacement_pre[26]));
    bufferH64$ u_buf_displacement_27 (.out(latchesInUse_displacement[27]), .in(latchesInUse_displacement_pre[27]));
    bufferH64$ u_buf_displacement_28 (.out(latchesInUse_displacement[28]), .in(latchesInUse_displacement_pre[28]));
    bufferH64$ u_buf_displacement_29 (.out(latchesInUse_displacement[29]), .in(latchesInUse_displacement_pre[29]));
    bufferH64$ u_buf_displacement_30 (.out(latchesInUse_displacement[30]), .in(latchesInUse_displacement_pre[30]));
    bufferH64$ u_buf_displacement_31 (.out(latchesInUse_displacement[31]), .in(latchesInUse_displacement_pre[31]));


    // =========================================================================
    // SEGMENT_LIMITS[NUM_SEG_REGS=7]: undriven in the original SV (defaults
    // to X). Declared here as undriven 32-bit wires to preserve the same
    // synthesizable shape; downstream consumers will see whatever the build
    // ties them to (typically 0 in synthesis, X in simulation if `reg`).
    // Indexed by reg_ids_e: CS=0, DS=1, SS=2, ES=3, FS=4, GS=5, EXPS=6.
    // =========================================================================
    reg [31:0] SEGMENT_LIMITS [0:6];
    
    wire [31:0] SEGMENT_LIMIT_CS;
    wire [31:0] SEGMENT_LIMIT_DS;
    wire [31:0] SEGMENT_LIMIT_SS;
    wire [31:0] SEGMENT_LIMIT_ES;
    wire [31:0] SEGMENT_LIMIT_FS;
    wire [31:0] SEGMENT_LIMIT_GS;
    wire [31:0] SEGMENT_LIMIT_EXPS;

    assign SEGMENT_LIMIT_CS = SEGMENT_LIMITS[0];
    assign SEGMENT_LIMIT_DS = SEGMENT_LIMITS[1];
    assign SEGMENT_LIMIT_SS = SEGMENT_LIMITS[2];
    assign SEGMENT_LIMIT_ES = SEGMENT_LIMITS[3];
    assign SEGMENT_LIMIT_FS = SEGMENT_LIMITS[4];
    assign SEGMENT_LIMIT_GS = SEGMENT_LIMITS[5];
    assign SEGMENT_LIMIT_EXPS = SEGMENT_LIMITS[6];

    // 8-way mux on seg_*_id[2:0] -- CS..EXPS occupy ids 0..6; entry 7 unused.
    wire [31:0] segment0_limit_data_w;
    wire [31:0] segment1_limit_data_w;
    `MUX_8(u_mx_seg0_lim, 32, segment0_limit_data_w,
           SEGMENT_LIMIT_CS, SEGMENT_LIMIT_DS, SEGMENT_LIMIT_SS, SEGMENT_LIMIT_ES,
           SEGMENT_LIMIT_FS, SEGMENT_LIMIT_GS, SEGMENT_LIMIT_EXPS, 32'd0,
           latchesInUse_cs_seg_0_id[2:0])
    `MUX_8(u_mx_seg1_lim, 32, segment1_limit_data_w,
           SEGMENT_LIMIT_CS, SEGMENT_LIMIT_DS, SEGMENT_LIMIT_SS, SEGMENT_LIMIT_ES,
           SEGMENT_LIMIT_FS, SEGMENT_LIMIT_GS, SEGMENT_LIMIT_EXPS, 32'd0,
           latchesInUse_cs_seg_1_id[2:0])

    // =========================================================================
    // RegFile  (already-flat structural module)
    // =========================================================================
    wire [63:0] DR_data_w, SR_data_w;
    wire [31:0] SIB_IDX_data_w, SIB_BASE_data_w;
    wire [31:0] ECX_data_w, EAX_data_w, CS_data_w;
    wire [31:0] Segment0_data_w, Segment1_data_w;

    wire [63:0] REG_CS_w,  REG_DS_w,  REG_SS_w,  REG_ES_w;
    wire [63:0] REG_FS_w,  REG_GS_w,  REG_EXPS_w;
    wire [63:0] REG_EAX_w, REG_EBX_w, REG_ECX_w, REG_EDX_w;
    wire [63:0] REG_ESI_w, REG_EDI_w, REG_ESP_w, REG_EBP_w;
    wire [63:0] REG_MM0_w, REG_MM1_w, REG_MM2_w, REG_MM3_w;
    wire [63:0] REG_MM4_w, REG_MM5_w, REG_MM6_w, REG_MM7_w;
    wire [63:0] REG_ETR_w, REG_ERROR_REG_w, REG_NO_REG_w;

    RegFile RegisterFile_unit (
        .clk(clk),
        .rst(rst),

        .DR_ID       (latchesInUse_cs_dr_id),
        .SR_ID       (latchesInUse_cs_sr_id),
        .SIB_IDX_ID  (latchesInUse_sib_idx_id),
        .SIB_BASE_ID (latchesInUse_sib_base_id),

        .WB_DR0_data (exe_outs_DR_0_data),
        .WB_DR1_data (exe_outs_DR_1_data),
        .WB_DR0_ID   (exe_outs_DR_0_id),
        .WB_DR1_ID   (exe_outs_DR_1_id),
        .WB_DR0_we   (exe_outs_DR_0_we),
        .WB_DR1_we   (exe_outs_DR_1_we),

        .Segment0_ID (latchesInUse_cs_seg_0_id),
        .Segment1_ID (latchesInUse_cs_seg_1_id),

        .DR_data       (DR_data_w),
        .SR_data       (SR_data_w),
        .SIB_IDX_data  (SIB_IDX_data_w),
        .SIB_BASE_data (SIB_BASE_data_w),
        .ECX_data      (ECX_data_w),
        .EAX_data      (EAX_data_w),
        .CS_data       (CS_data_w),
        .Segment0_data (Segment0_data_w),
        .Segment1_data (Segment1_data_w),

        .REG_CS_o        (REG_CS_w),
        .REG_DS_o        (REG_DS_w),
        .REG_SS_o        (REG_SS_w),
        .REG_ES_o        (REG_ES_w),
        .REG_FS_o        (REG_FS_w),
        .REG_GS_o        (REG_GS_w),
        .REG_EXPS_o      (REG_EXPS_w),
        .REG_EAX_o       (REG_EAX_w),
        .REG_EBX_o       (REG_EBX_w),
        .REG_ECX_o       (REG_ECX_w),
        .REG_EDX_o       (REG_EDX_w),
        .REG_ESI_o       (REG_ESI_w),
        .REG_EDI_o       (REG_EDI_w),
        .REG_ESP_o       (REG_ESP_w),
        .REG_EBP_o       (REG_EBP_w),
        .REG_MM0_o       (REG_MM0_w),
        .REG_MM1_o       (REG_MM1_w),
        .REG_MM2_o       (REG_MM2_w),
        .REG_MM3_o       (REG_MM3_w),
        .REG_MM4_o       (REG_MM4_w),
        .REG_MM5_o       (REG_MM5_w),
        .REG_MM6_o       (REG_MM6_w),
        .REG_MM7_o       (REG_MM7_w),
        .REG_ETR_o       (REG_ETR_w),
        .REG_ERROR_REG_o (REG_ERROR_REG_w),
        .REG_NO_REG_o    (REG_NO_REG_w)
    );

    // =========================================================================
    // addygen_input_addy = (MODRM_NEEDED && RM_IS_DR) ? DR_data[31:0]
    //                                                : SR_data[31:0]
    // =========================================================================
    wire        modrm_and_rmdr_pre, modrm_and_rmdr;
    wire [31:0] addygen_input_addy_w;

    `AND_2(u_modrm_and_rmdr, 1, modrm_and_rmdr_pre,
           latchesInUse_cs_MODRM_NEEDED, latchesInUse_cs_RM_IS_DR)
    bufferH64$ u_buf_modrm_and_rmdr (.out(modrm_and_rmdr), .in(modrm_and_rmdr_pre));

    `MUX_2(u_mx_addygen_in, 32, addygen_input_addy_w,
           SR_data_w[31:0], DR_data_w[31:0], modrm_and_rmdr)

    // =========================================================================
    // npu_node1 (address-gen logic)
    // =========================================================================
    wire [31:0] ld_vaddy_w;
    wire [31:0] seg0_limit_w_datasize_w;
    wire [31:0] seg0_limit_wo_datasize_w;
    wire [31:0] next_ld_vaddy_w;
    wire [31:0] ld_laddy_w;

    wire [31:0] actual_st_vaddy_w;
    wire [31:0] seg1_limit_w_datasize_w;
    wire [31:0] seg1_limit_wo_datasize_w;
    wire [31:0] actual_next_st_vaddy_w;
    wire [31:0] st_laddy_w;

    npu_node1 addygen_logic_unit (
        .register_data       (addygen_input_addy_w),
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

        .ld_vaddy               (ld_vaddy_w),
        .seg0_limit_w_datasize  (seg0_limit_w_datasize_w),
        .seg0_limit_wo_datasize (seg0_limit_wo_datasize_w),
        .next_ld_vaddy          (next_ld_vaddy_w),
        .ld_laddy               (ld_laddy_w),

        .actual_st_vaddy        (actual_st_vaddy_w),
        .seg1_limit_w_datasize  (seg1_limit_w_datasize_w),
        .seg1_limit_wo_datasize (seg1_limit_wo_datasize_w),
        .actual_next_st_vaddy   (actual_next_st_vaddy_w),
        .actual_st_laddy        (st_laddy_w)
    );

    // =========================================================================
    // RegSB
    // =========================================================================
    wire ecx_sb_w;
    wire cs_sb_w;
    wire depstall_w;
    wire dc_latches_we_w;
    wire next_dc_valid_w;
    wire instructionforward_w;
    wire rr_stall_w;

    `AND_2(u_instructionforward, 1, instructionforward_w,
           dc_latches_we_w, next_dc_valid_w)

    RegSB reg_sb_unit (
        .clk           (clk),
        .rst           (rst),
        .instructionforward (instructionforward_w),
        .dr_id         (latchesInUse_cs_dr_id),
        .sr_id         (latchesInUse_cs_sr_id),
        .flush         (exe_outs_br_res_flush),
        .farFlush      (exe_outs_br_res_farFlush),
        .callFlush     (exe_outs_br_res_callFlush),
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
        .dep_stall     (depstall_w),
        .ecx_sb        (ecx_sb_w),
        .codeSeg_sb    (cs_sb_w),
        .LD_OP         (latchesInUse_cs_LD_OP),
        .ST_OP         (latchesInUse_cs_ST_OP),
        .REP_OP        (decode_outs_rep_latch)
    );

    // rr_stall = latchesInUse.valid && depstall
    `AND_2(u_rr_stall, 1, rr_stall_w, latchesInUse_valid, depstall_w)

    // =========================================================================
    // dc_valid_logic (auto-generated flat module)
    // =========================================================================
    dc_valid_logic dc_valid_logic_unit (
        .DC_we_o    (dc_latches_we_w),
        .N_DC_V_o   (next_dc_valid_w),
        .RR_stall_i (rr_stall_w),
        .RR_V_i     (latchesInUse_valid),
        .DC_stall_i (dc_outs_stall),
        .DC_V_i     (dc_outs_valid),
        .MEM_V_i    (mem_outs_valid),
        .MEM_stall_i(mem_outs_stall),
        .EXE_V_i    (exe_outs_valid),
        .WB_stall_i (wb_outs_wb_stall)
    );

    // =========================================================================
    // RR_GP = decode_gp && !depstall
    // =========================================================================
    wire RR_GP_w;
    wire depstall_n;
    `INV_N(u_inv_depstall, 1, depstall_w, depstall_n)
    `AND_2(u_rr_gp,        1, RR_GP_w, decode_outs_decode_gp, depstall_n)

    // =========================================================================
    // dc_latches_next.valid = next_dc_valid & ~exp_pipe_clear
    // =========================================================================
    wire dc_latches_next_valid_w;
    wire not_exp_pipe_clear;
    `INV_N(u_inv_exp_pc,    1, fetch_outs_exp_pipe_clear, not_exp_pipe_clear)
    `AND_2(u_dc_lat_valid,  1, dc_latches_next_valid_w,
           next_dc_valid_w, not_exp_pipe_clear)

    // =========================================================================
    // ld_stack_access = (seg_0_id == SS)
    // st_stack_access = seg_1_valid ? (seg_1_id == SS) : (seg_0_id == SS)
    // =========================================================================
    wire seg0_is_SS_w;
    wire seg1_is_SS_w;
    wire st_stack_access_w;

    `CMP_N(u_cmp_seg0_SS, 5, seg0_is_SS_w, latchesInUse_cs_seg_0_id, REG_ID_SS)
    `CMP_N(u_cmp_seg1_SS, 5, seg1_is_SS_w, latchesInUse_cs_seg_1_id, REG_ID_SS)

    `MUX_2(u_mx_st_stack, 1, st_stack_access_w,
           seg0_is_SS_w, seg1_is_SS_w, latchesInUse_cs_seg_1_valid)

    // =========================================================================
    // OUTPUT ASSIGNMENTS  (flat, one per former struct field)
    // =========================================================================

    // ---- dc_latches_next ----
    assign dc_latches_next_valid                       = dc_latches_next_valid_w;

    // dc_cs_t pass-through
    assign dc_latches_next_cs_LD_OP                    = latchesInUse_dc_cs_LD_OP;
    assign dc_latches_next_cs_ST_OP                    = latchesInUse_dc_cs_ST_OP;
    assign dc_latches_next_cs_dr_upper8                = latchesInUse_dc_cs_dr_upper8;
    assign dc_latches_next_cs_sr_upper8                = latchesInUse_dc_cs_sr_upper8;
    assign dc_latches_next_cs_datasize                 = latchesInUse_dc_cs_datasize;

    // mem_cs_t pass-through
    assign dc_latches_next_mem_cs_ST_OP                = latchesInUse_mem_cs_ST_OP;
    assign dc_latches_next_mem_cs_LD_OP                = latchesInUse_mem_cs_LD_OP;

    // exe_cs_t pass-through
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

    // wb_cs_t pass-through
    assign dc_latches_next_wb_cs_ST_OP                 = latchesInUse_wb_cs_ST_OP;
    assign dc_latches_next_wb_cs_WB_DR                 = latchesInUse_wb_cs_WB_DR;
    assign dc_latches_next_wb_cs_WB_SR                 = latchesInUse_wb_cs_WB_SR;
    assign dc_latches_next_wb_cs_WB_EAX                = latchesInUse_wb_cs_WB_EAX;

    // br_info_t pass-through
    assign dc_latches_next_br_info_valid               = latchesInUse_br_info_valid;
    assign dc_latches_next_br_info_br_eip              = latchesInUse_br_info_br_eip;
    assign dc_latches_next_br_info_br_xcl              = latchesInUse_br_info_br_xcl;
    assign dc_latches_next_br_info_br_pred_taken       = latchesInUse_br_info_br_pred_taken;
    assign dc_latches_next_br_info_speculative_target  = latchesInUse_br_info_speculative_target;

    assign dc_latches_next_rr_gp                       = RR_GP_w;

    assign dc_latches_next_ld_vaddy                    = ld_vaddy_w;
    assign dc_latches_next_seg0_limit_w_datasize       = seg0_limit_w_datasize_w;
    assign dc_latches_next_seg0_limit_wo_datasize      = seg0_limit_wo_datasize_w;
    assign dc_latches_next_next_ld_vaddy               = next_ld_vaddy_w;
    assign dc_latches_next_ld_laddy                    = ld_laddy_w;
    assign dc_latches_next_ld_stack_access             = seg0_is_SS_w;

    assign dc_latches_next_st_vaddy                    = actual_st_vaddy_w;
    assign dc_latches_next_seg1_limit_w_datasize       = seg1_limit_w_datasize_w;
    assign dc_latches_next_seg1_limit_wo_datasize      = seg1_limit_wo_datasize_w;
    assign dc_latches_next_next_st_vaddy               = actual_next_st_vaddy_w;
    assign dc_latches_next_st_laddy                    = st_laddy_w;
    assign dc_latches_next_st_stack_access             = st_stack_access_w;

    assign dc_latches_next_NEIP                        = latchesInUse_NEIP;
    assign dc_latches_next_EIP                         = latchesInUse_EIP;
    assign dc_latches_next_EAX                         = EAX_data_w;     // from RegFile, not latch
    assign dc_latches_next_imm64                       = latchesInUse_imm64;

    assign dc_latches_next_sr_id                       = latchesInUse_cs_sr_id;
    assign dc_latches_next_sr_data                     = SR_data_w;
    assign dc_latches_next_dr_id                       = latchesInUse_cs_dr_id;
    assign dc_latches_next_dr_data                     = DR_data_w;

    // ---- outs_o ----
    assign outs_valid              = latchesInUse_valid;
    assign outs_stall              = rr_stall_w;       // latchesInUse.valid && depstall
    assign outs_ecx_sb             = ecx_sb_w;
    assign outs_ecx                = ECX_data_w;
    assign outs_eax                = EAX_data_w;
    assign outs_set_ZF_sb          = latchesInUse_cs_will_mod_zf;
    assign outs_codeSeg_sb         = cs_sb_w;
    assign outs_codeSeg_data       = CS_data_w;
    assign outs_codeSeg_limit      = SEGMENT_LIMIT_CS;   // SEGMENT_LIMITS[CS_LIMIT_ID].limit
    assign outs_dc_stage_latch_we  = dc_latches_we_w;

    assign outs_regFileValues_0    = REG_CS_w;
    assign outs_regFileValues_1    = REG_DS_w;
    assign outs_regFileValues_2    = REG_SS_w;
    assign outs_regFileValues_3    = REG_ES_w;
    assign outs_regFileValues_4    = REG_FS_w;
    assign outs_regFileValues_5    = REG_GS_w;
    assign outs_regFileValues_6    = REG_EXPS_w;
    assign outs_regFileValues_7    = REG_EAX_w;
    assign outs_regFileValues_8    = REG_EBX_w;
    assign outs_regFileValues_9    = REG_ECX_w;
    assign outs_regFileValues_10   = REG_EDX_w;
    assign outs_regFileValues_11   = REG_ESI_w;
    assign outs_regFileValues_12   = REG_EDI_w;
    assign outs_regFileValues_13   = REG_ESP_w;
    assign outs_regFileValues_14   = REG_EBP_w;
    assign outs_regFileValues_15   = REG_MM0_w;
    assign outs_regFileValues_16   = REG_MM1_w;
    assign outs_regFileValues_17   = REG_MM2_w;
    assign outs_regFileValues_18   = REG_MM3_w;
    assign outs_regFileValues_19   = REG_MM4_w;
    assign outs_regFileValues_20   = REG_MM5_w;
    assign outs_regFileValues_21   = REG_MM6_w;
    assign outs_regFileValues_22   = REG_MM7_w;
    assign outs_regFileValues_23   = REG_ETR_w;
    assign outs_regFileValues_24   = REG_ERROR_REG_w;
    assign outs_regFileValues_25   = REG_NO_REG_w;

endmodule
