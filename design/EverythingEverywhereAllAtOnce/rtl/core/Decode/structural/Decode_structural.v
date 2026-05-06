// =============================================================================
// Decode  (pure Verilog-2005 structural port of Decode_structural.sv)
//
//   - All SystemVerilog constructs (struct, typedef, enum, package import,
//     `bool`/`p_address_t`/`uint*_t`/`reg_ids_e`/struct literals) are
//     removed. Each struct field is exposed as a separate flat scalar/
//     vector port whose name follows the original `struct.field` path with
//     `.` replaced by `_`.
//
//   - idm_outputs_t.idm_slots[NUM_IDM_SLOTS=4] is unrolled per slot; each
//     slot's byte_t data[CACHE_LINES_SIZE_B=16] is exposed as a 128-bit
//     packed bus (slot0 is the LSB of the 512-bit predecode queue).
//
//   - rr_latches_t (output) is unrolled into 2 x rr_latches_general_t;
//     normal_latches is filled by Decode logic, rep_latches is driven
//     straight from rep_controller's flat outputs.
//
//   Type-to-width mapping used here:
//     bool                       -> 1 bit
//     l_address_t                -> 32 bits
//     uint32_t                   -> 32 bits
//     uint64_t                   -> 64 bits
//     reg_ids_e                  -> 5 bits  (`REG_ID_W = 5)
//     exe_cs_operation_type_e    -> 6 bits  (`EXE_OP_W = 6)
//     source_selector_e          -> 5 bits  (`SRC_SEL_W = 5)
//
//   Internal leaf modules already have flat Verilog-2005 ports:
//     predecode, control_store, decode_gp_gen, br_info_processing,
//     sib_processor, rr_valid_logic, rep_controller, pencoder8_3v$.
// =============================================================================

module Decode (
    input  wire        clk,
    input  wire        rst,

    // ====================================================================
    // idm_outputs_t (idm_outs_i)
    //   idm_slots[0..3] : idm_slot_info_t per slot, each with a 128-bit
    //                     packed data bus (16 bytes, byte 0 is bits [7:0])
    //   valid_slots[2:0]: declared on the source struct but unused here
    // ====================================================================
    input  wire        idm_outs_idm_slots_0_valid,
    input  wire        idm_outs_idm_slots_0_br_valid,
    input  wire [31:0] idm_outs_idm_slots_0_br_eip,
    input  wire [31:0] idm_outs_idm_slots_0_br_btb_target,
    input  wire        idm_outs_idm_slots_0_br_xcl,           // unused
    input  wire [127:0] idm_outs_idm_slots_0_data,

    input  wire        idm_outs_idm_slots_1_valid,
    input  wire        idm_outs_idm_slots_1_br_valid,
    input  wire [31:0] idm_outs_idm_slots_1_br_eip,
    input  wire [31:0] idm_outs_idm_slots_1_br_btb_target,
    input  wire        idm_outs_idm_slots_1_br_xcl,           // unused
    input  wire [127:0] idm_outs_idm_slots_1_data,

    input  wire        idm_outs_idm_slots_2_valid,
    input  wire        idm_outs_idm_slots_2_br_valid,
    input  wire [31:0] idm_outs_idm_slots_2_br_eip,
    input  wire [31:0] idm_outs_idm_slots_2_br_btb_target,
    input  wire        idm_outs_idm_slots_2_br_xcl,           // unused
    input  wire [127:0] idm_outs_idm_slots_2_data,

    input  wire        idm_outs_idm_slots_3_valid,
    input  wire        idm_outs_idm_slots_3_br_valid,
    input  wire [31:0] idm_outs_idm_slots_3_br_eip,
    input  wire [31:0] idm_outs_idm_slots_3_br_btb_target,
    input  wire        idm_outs_idm_slots_3_br_xcl,           // unused
    input  wire [127:0] idm_outs_idm_slots_3_data,

    // ====================================================================
    // fetch_outputs_t (fetch_outs_i) -- consumed fields only
    // ====================================================================
    input  wire        fetch_outs_exp_pipe_clear,
    input  wire [1:0]  fetch_outs_exp_mode_jk,
    input  wire        fetch_outs_int_mode_jk,

    // ====================================================================
    // rr_outputs_t (rr_outs_i) -- consumed fields only
    // ====================================================================
    input  wire        rr_outs_valid,
    input  wire        rr_outs_stall,
    input  wire        rr_outs_ecx_sb,
    input  wire [31:0] rr_outs_ecx,
    input  wire [31:0] rr_outs_eax,
    input  wire [31:0] rr_outs_codeSeg_limit,

    // ====================================================================
    // dc_outputs_t (dc_outs_i) -- valid + stall + dc_eip consumed
    // ====================================================================
    input  wire        dc_outs_valid,
    input  wire        dc_outs_stall,
    input  wire [31:0] dc_outs_dc_eip,

    // ====================================================================
    // mem_outputs_t (mem_outs_i) -- valid + stall consumed
    // ====================================================================
    input  wire        mem_outs_valid,
    input  wire        mem_outs_stall,

    // ====================================================================
    // exe_outputs_t (exe_outs_i)
    // ====================================================================
    input  wire        exe_outs_valid,
    input  wire        exe_outs_br_res_valid,
    input  wire        exe_outs_br_res_flush,
    input  wire [31:0] exe_outs_br_res_br_target,
    input  wire        exe_outs_clr_ZF_sb,
    input  wire        exe_outs_ZF,

    // ====================================================================
    // wb_outputs_t (wb_outs_i) -- only wb_stall consumed
    // ====================================================================
    input  wire        wb_outs_wb_stall,

    // ====================================================================
    // rr_latches_t (rr_latches_next) -- normal_latches  (Decode-driven)
    // ====================================================================
    output wire        rr_latches_next_normal_latches_valid,

    // rr_cs_t
    output wire        rr_latches_next_normal_latches_cs_ST_SEL,
    output wire        rr_latches_next_normal_latches_cs_MODRM_NEEDED,
    output wire        rr_latches_next_normal_latches_cs_RM_IS_DR,
    output wire        rr_latches_next_normal_latches_cs_SWITCH_LD_ADDY,
    output wire        rr_latches_next_normal_latches_cs_LD_OP,
    output wire        rr_latches_next_normal_latches_cs_ST_OP,
    output wire [`REG_ID_W-1:0] rr_latches_next_normal_latches_cs_dr_id,
    output wire [`REG_ID_W-1:0] rr_latches_next_normal_latches_cs_sr_id,
    output wire        rr_latches_next_normal_latches_cs_dr_rd,
    output wire        rr_latches_next_normal_latches_cs_sr_rd,
    output wire        rr_latches_next_normal_latches_cs_eax_rd,
    output wire        rr_latches_next_normal_latches_cs_dr_wr,
    output wire        rr_latches_next_normal_latches_cs_sr_wr,
    output wire        rr_latches_next_normal_latches_cs_eax_wr,
    output wire        rr_latches_next_normal_latches_cs_MOVS_OP,
    output wire [1:0]  rr_latches_next_normal_latches_cs_datasize,
    output wire        rr_latches_next_normal_latches_cs_will_mod_zf,
    output wire        rr_latches_next_normal_latches_cs_seg_1_valid,
    output wire [`REG_ID_W-1:0] rr_latches_next_normal_latches_cs_seg_0_id,
    output wire [`REG_ID_W-1:0] rr_latches_next_normal_latches_cs_seg_1_id,
    output wire        rr_latches_next_normal_latches_cs_special_modrm_bs,
    output wire        rr_latches_next_normal_latches_cs_special_br,

    // dc_cs_t
    output wire        rr_latches_next_normal_latches_dc_cs_LD_OP,
    output wire        rr_latches_next_normal_latches_dc_cs_ST_OP,
    output wire        rr_latches_next_normal_latches_dc_cs_dr_upper8,
    output wire        rr_latches_next_normal_latches_dc_cs_sr_upper8,
    output wire [1:0]  rr_latches_next_normal_latches_dc_cs_datasize,

    // mem_cs_t
    output wire        rr_latches_next_normal_latches_mem_cs_ST_OP,
    output wire        rr_latches_next_normal_latches_mem_cs_LD_OP,

    // exe_cs_t
    output wire        rr_latches_next_normal_latches_exe_cs_ST_OP,
    output wire [`EXE_OP_W-1:0]  rr_latches_next_normal_latches_exe_cs_OP_TYPE,
    output wire [`SRC_SEL_W-1:0] rr_latches_next_normal_latches_exe_cs_alu_inputA_sel,
    output wire [`SRC_SEL_W-1:0] rr_latches_next_normal_latches_exe_cs_alu_inputB_sel,
    output wire [`SRC_SEL_W-1:0] rr_latches_next_normal_latches_exe_cs_branch_target_sel,
    output wire        rr_latches_next_normal_latches_exe_cs_shift_by_one,
    output wire        rr_latches_next_normal_latches_exe_cs_br_ucond,
    output wire        rr_latches_next_normal_latches_exe_cs_relative_branch,
    output wire        rr_latches_next_normal_latches_exe_cs_special_br,
    output wire        rr_latches_next_normal_latches_exe_cs_is_far,
    output wire        rr_latches_next_normal_latches_exe_cs_is_call,
    output wire        rr_latches_next_normal_latches_exe_cs_second_flag_needed,
    output wire        rr_latches_next_normal_latches_exe_cs_rep_no_zf_update,

    // wb_cs_t
    output wire        rr_latches_next_normal_latches_wb_cs_ST_OP,
    output wire        rr_latches_next_normal_latches_wb_cs_WB_DR,
    output wire        rr_latches_next_normal_latches_wb_cs_WB_SR,
    output wire        rr_latches_next_normal_latches_wb_cs_WB_EAX,

    // br_info_t
    output wire        rr_latches_next_normal_latches_br_info_valid,
    output wire [31:0] rr_latches_next_normal_latches_br_info_br_eip,
    output wire        rr_latches_next_normal_latches_br_info_br_xcl,
    output wire        rr_latches_next_normal_latches_br_info_br_pred_taken,
    output wire [31:0] rr_latches_next_normal_latches_br_info_speculative_target,

    output wire [31:0] rr_latches_next_normal_latches_NEIP,
    output wire [31:0] rr_latches_next_normal_latches_EIP,
    output wire [31:0] rr_latches_next_normal_latches_EAX,
    output wire [63:0] rr_latches_next_normal_latches_imm64,

    output wire [`REG_ID_W-1:0] rr_latches_next_normal_latches_sib_idx_id,
    output wire [`REG_ID_W-1:0] rr_latches_next_normal_latches_sib_base_id,
    output wire        rr_latches_next_normal_latches_sib_needed,
    output wire [7:0]  rr_latches_next_normal_latches_sib_scale,
    output wire        rr_latches_next_normal_latches_disp_needed,
    output wire        rr_latches_next_normal_latches_disp_size,
    output wire [31:0] rr_latches_next_normal_latches_displacement,

    // ====================================================================
    // rr_latches_t (rr_latches_next) -- rep_latches (rep_controller-driven)
    // ====================================================================
    output wire        rr_latches_next_rep_latches_valid,

    output wire        rr_latches_next_rep_latches_cs_ST_SEL,
    output wire        rr_latches_next_rep_latches_cs_MODRM_NEEDED,
    output wire        rr_latches_next_rep_latches_cs_RM_IS_DR,
    output wire        rr_latches_next_rep_latches_cs_SWITCH_LD_ADDY,
    output wire        rr_latches_next_rep_latches_cs_LD_OP,
    output wire        rr_latches_next_rep_latches_cs_ST_OP,
    output wire [`REG_ID_W-1:0] rr_latches_next_rep_latches_cs_dr_id,
    output wire [`REG_ID_W-1:0] rr_latches_next_rep_latches_cs_sr_id,
    output wire        rr_latches_next_rep_latches_cs_dr_rd,
    output wire        rr_latches_next_rep_latches_cs_sr_rd,
    output wire        rr_latches_next_rep_latches_cs_eax_rd,
    output wire        rr_latches_next_rep_latches_cs_dr_wr,
    output wire        rr_latches_next_rep_latches_cs_sr_wr,
    output wire        rr_latches_next_rep_latches_cs_eax_wr,
    output wire        rr_latches_next_rep_latches_cs_MOVS_OP,
    output wire [1:0]  rr_latches_next_rep_latches_cs_datasize,
    output wire        rr_latches_next_rep_latches_cs_will_mod_zf,
    output wire        rr_latches_next_rep_latches_cs_seg_1_valid,
    output wire [`REG_ID_W-1:0] rr_latches_next_rep_latches_cs_seg_0_id,
    output wire [`REG_ID_W-1:0] rr_latches_next_rep_latches_cs_seg_1_id,
    output wire        rr_latches_next_rep_latches_cs_special_modrm_bs,
    output wire        rr_latches_next_rep_latches_cs_special_br,

    output wire        rr_latches_next_rep_latches_dc_cs_LD_OP,
    output wire        rr_latches_next_rep_latches_dc_cs_ST_OP,
    output wire        rr_latches_next_rep_latches_dc_cs_dr_upper8,
    output wire        rr_latches_next_rep_latches_dc_cs_sr_upper8,
    output wire [1:0]  rr_latches_next_rep_latches_dc_cs_datasize,

    output wire        rr_latches_next_rep_latches_mem_cs_ST_OP,
    output wire        rr_latches_next_rep_latches_mem_cs_LD_OP,

    output wire        rr_latches_next_rep_latches_exe_cs_ST_OP,
    output wire [`EXE_OP_W-1:0]  rr_latches_next_rep_latches_exe_cs_OP_TYPE,
    output wire [`SRC_SEL_W-1:0] rr_latches_next_rep_latches_exe_cs_alu_inputA_sel,
    output wire [`SRC_SEL_W-1:0] rr_latches_next_rep_latches_exe_cs_alu_inputB_sel,
    output wire [`SRC_SEL_W-1:0] rr_latches_next_rep_latches_exe_cs_branch_target_sel,
    output wire        rr_latches_next_rep_latches_exe_cs_shift_by_one,
    output wire        rr_latches_next_rep_latches_exe_cs_br_ucond,
    output wire        rr_latches_next_rep_latches_exe_cs_relative_branch,
    output wire        rr_latches_next_rep_latches_exe_cs_special_br,
    output wire        rr_latches_next_rep_latches_exe_cs_is_far,
    output wire        rr_latches_next_rep_latches_exe_cs_is_call,
    output wire        rr_latches_next_rep_latches_exe_cs_second_flag_needed,
    output wire        rr_latches_next_rep_latches_exe_cs_rep_no_zf_update,

    output wire        rr_latches_next_rep_latches_wb_cs_ST_OP,
    output wire        rr_latches_next_rep_latches_wb_cs_WB_DR,
    output wire        rr_latches_next_rep_latches_wb_cs_WB_SR,
    output wire        rr_latches_next_rep_latches_wb_cs_WB_EAX,

    output wire        rr_latches_next_rep_latches_br_info_valid,
    output wire [31:0] rr_latches_next_rep_latches_br_info_br_eip,
    output wire        rr_latches_next_rep_latches_br_info_br_xcl,
    output wire        rr_latches_next_rep_latches_br_info_br_pred_taken,
    output wire [31:0] rr_latches_next_rep_latches_br_info_speculative_target,

    output wire [31:0] rr_latches_next_rep_latches_NEIP,
    output wire [31:0] rr_latches_next_rep_latches_EIP,
    output wire [31:0] rr_latches_next_rep_latches_EAX,
    output wire [63:0] rr_latches_next_rep_latches_imm64,

    output wire [`REG_ID_W-1:0] rr_latches_next_rep_latches_sib_idx_id,
    output wire [`REG_ID_W-1:0] rr_latches_next_rep_latches_sib_base_id,
    output wire        rr_latches_next_rep_latches_sib_needed,
    output wire [7:0]  rr_latches_next_rep_latches_sib_scale,
    output wire        rr_latches_next_rep_latches_disp_needed,
    output wire        rr_latches_next_rep_latches_disp_size,
    output wire [31:0] rr_latches_next_rep_latches_displacement,

    // ====================================================================
    // decode_outputs_t (outs_o)
    // ====================================================================
    output wire        outs_valid,
    output wire        outs_stall,
    output wire [31:0] outs_eip,
    output wire        outs_invalid_instruction,
    output wire        outs_decode_gp,
    output wire        outs_rr_stage_latch_we,
    output wire        outs_rep_latch,
    output wire        outs_decode_forward
);

    // -------------------------------------------------------------------------
    // Local nets that were SV `wire`/`logic` declarations
    // -------------------------------------------------------------------------
    wire [31:0] PrevEIP;
    wire [31:0] EIP;
    wire [31:0] NEIP;
    wire [3:0]  inst_length;
    wire [3:0]  PrevLength;
    wire [7:0]  sib_byte;
    wire        sib_size;
    wire        disp_needed;
    wire [31:0] displacement;
    wire        disp_size;
    wire [63:0] imm64;
    wire [9:0]  total_pf_vector;
    wire        invalid_inst;
    wire [7:0]  opcode_byte, modrm_byte;
    wire        decode_gp;
    wire        flush;
    wire        REP_LATCH, REP_CMP_LATCH, REP_MOV_LATCH, HALT_REG;
    wire        rr_latch_we_o;

    wire [31:0] DC_SAVED_EIP;
    wire [31:0] DECODE_SAVED_EIP;

    wire [`REG_ID_W-1:0] SAVED_SEGMENT0;
    wire                 SAVED_SEGMENT_OVERRIDE;
    wire [31:0]          SAVED_REP_EIP;
    wire [1:0]           SAVED_DATASIZE;

    wire [`REG_ID_W-1:0] segment0;
    wire                 seg_override;
    wire                 next_rr_valid;

    assign flush = exe_outs_br_res_flush;

    wire decode_forward;
    `AND_2 (decode_forward_u, 1, decode_forward, rr_latch_we_o, next_rr_valid)

    // -------------------------------------------------------------------------
    // control_store flat-port outputs replace the SV `temp_<X>_cs` struct vars.
    //   temp_decode_cs, temp_rr_cs, temp_dc_cs, temp_mem_cs, temp_exe_cs,
    //   temp_wb_cs are unrolled into one wire per former struct field.
    // -------------------------------------------------------------------------
    // decode_cs_t fields
    wire        temp_decode_cs_REP;
    wire        temp_decode_cs_REP_CMP;
    wire        temp_decode_cs_HALT;
    wire        temp_decode_cs_MODRM_NEEDED;
    wire        temp_decode_cs_RM_IS_DR;
    wire        temp_decode_cs_REG_IS_DR;
    wire        temp_decode_cs_REG_IS_SEGMENT;
    wire        temp_decode_cs_HARDCODED_DR_HIGH8;
    wire        temp_decode_cs_MODRM_BUT_NO_SR;
    wire        temp_decode_cs_HARDCODED_DR;
    wire [`REG_ID_W-1:0] temp_decode_cs_HARDCODED_DR_ID;
    wire        temp_decode_cs_HARDCODED_SR;
    wire [`REG_ID_W-1:0] temp_decode_cs_HARDCODED_SR_ID;
    wire        temp_decode_cs_HARDCODED_DR_RD;
    wire        temp_decode_cs_HARDCODED_DR_WR;
    wire        temp_decode_cs_HARDCODED_SR_RD;
    wire        temp_decode_cs_HARDCODED_SR_WR;
    wire        temp_decode_cs_HARDCODED_LD_OP;
    wire        temp_decode_cs_HARDCODED_ST_OP;
    wire        temp_decode_cs_LD_OP_CANCEL;
    wire        temp_decode_cs_ST_OP_CANCEL;
    wire        temp_decode_cs_OP_IN_MODRM;
    wire [1:0]  temp_decode_cs_DATA_SIZE;

    // rr_cs_t fields
    wire        temp_rr_cs_ST_SEL;
    wire        temp_rr_cs_MODRM_NEEDED;
    wire        temp_rr_cs_RM_IS_DR;
    wire        temp_rr_cs_SWITCH_LD_ADDY;
    wire        temp_rr_cs_LD_OP;
    wire        temp_rr_cs_ST_OP;
    wire [`REG_ID_W-1:0] temp_rr_cs_dr_id;
    wire [`REG_ID_W-1:0] temp_rr_cs_sr_id;
    wire        temp_rr_cs_dr_rd;
    wire        temp_rr_cs_sr_rd;
    wire        temp_rr_cs_eax_rd;
    wire        temp_rr_cs_dr_wr;
    wire        temp_rr_cs_sr_wr;
    wire        temp_rr_cs_eax_wr;
    wire        temp_rr_cs_MOVS_OP;
    wire [1:0]  temp_rr_cs_datasize;
    wire        temp_rr_cs_will_mod_zf;
    wire        temp_rr_cs_seg_1_valid;
    wire [`REG_ID_W-1:0] temp_rr_cs_seg_0_id;
    wire [`REG_ID_W-1:0] temp_rr_cs_seg_1_id;
    wire        temp_rr_cs_special_modrm_bs;
    wire        temp_rr_cs_special_br;

    // dc_cs_t fields
    wire        temp_dc_cs_LD_OP;
    wire        temp_dc_cs_ST_OP;
    wire        temp_dc_cs_dr_upper8;
    wire        temp_dc_cs_sr_upper8;
    wire [1:0]  temp_dc_cs_datasize;

    // mem_cs_t fields
    wire        temp_mem_cs_ST_OP;
    wire        temp_mem_cs_LD_OP;

    // exe_cs_t fields (enum-typed widths match flat-port convention)
    wire        temp_exe_cs_ST_OP;
    wire [`EXE_OP_W-1:0]  temp_exe_cs_OP_TYPE;
    wire [`SRC_SEL_W-1:0] temp_exe_cs_alu_inputA_sel;
    wire [`SRC_SEL_W-1:0] temp_exe_cs_alu_inputB_sel;
    wire [`SRC_SEL_W-1:0] temp_exe_cs_branch_target_sel;
    wire        temp_exe_cs_shift_by_one;
    wire        temp_exe_cs_br_ucond;
    wire        temp_exe_cs_relative_branch;
    wire        temp_exe_cs_special_br;
    wire        temp_exe_cs_is_far;
    wire        temp_exe_cs_is_call;
    wire        temp_exe_cs_second_flag_needed;
    wire        temp_exe_cs_rep_no_zf_update;

    // wb_cs_t fields
    wire        temp_wb_cs_ST_OP;
    wire        temp_wb_cs_WB_DR;
    wire        temp_wb_cs_WB_SR;
    wire        temp_wb_cs_WB_EAX;

    // -------------------------------------------------------------------------
    // Predecode / control_store: flatten the IDM queue (4 x 128-bit packed
    // bus -> 512-bit concatenation, slot0 in LSBs to match the original
    // {slot[i].data[j]} byte-ordering of `flattened_queue[i*8 +: 8]`).
    // -------------------------------------------------------------------------
    wire [511:0] flattened_queue;
    assign flattened_queue = {idm_outs_idm_slots_3_data,
                              idm_outs_idm_slots_2_data,
                              idm_outs_idm_slots_1_data,
                              idm_outs_idm_slots_0_data};

    predecode inst_processing (
        .clk          (clk),
        .rst          (rst),
        .queue        (flattened_queue),
        .queue_valid  ({idm_outs_idm_slots_3_valid, idm_outs_idm_slots_2_valid,
                        idm_outs_idm_slots_1_valid, idm_outs_idm_slots_0_valid}),
        .EIP          (EIP),
        .NEIP         (NEIP),
        .inst_length  (inst_length),
        .sib_byte     (sib_byte),
        .sib_size     (sib_size),
        .opcode_byte  (opcode_byte),
        .modrm_byte   (modrm_byte),
        .disp         (displacement),
        .disp_size    (disp_size),
        .disp_needed  (disp_needed),
        .imm64        (imm64),
        .total_pf_vector(total_pf_vector),
        .invalid_inst (invalid_inst)
    );

    control_store cs (
        .invalid_inst    (invalid_inst),
        .total_pf_vector (total_pf_vector),
        .opcode          (opcode_byte),
        .modrm           (modrm_byte),
        .seg_override    (seg_override),
        .seg0            (segment0),

        .decode_cs_REP                (temp_decode_cs_REP),
        .decode_cs_REP_CMP            (temp_decode_cs_REP_CMP),
        .decode_cs_HALT               (temp_decode_cs_HALT),
        .decode_cs_MODRM_NEEDED       (temp_decode_cs_MODRM_NEEDED),
        .decode_cs_RM_IS_DR           (temp_decode_cs_RM_IS_DR),
        .decode_cs_REG_IS_DR          (temp_decode_cs_REG_IS_DR),
        .decode_cs_REG_IS_SEGMENT     (temp_decode_cs_REG_IS_SEGMENT),
        .decode_cs_HARDCODED_DR_HIGH8 (temp_decode_cs_HARDCODED_DR_HIGH8),
        .decode_cs_MODRM_BUT_NO_SR    (temp_decode_cs_MODRM_BUT_NO_SR),
        .decode_cs_HARDCODED_DR       (temp_decode_cs_HARDCODED_DR),
        .decode_cs_HARDCODED_DR_ID    (temp_decode_cs_HARDCODED_DR_ID),
        .decode_cs_HARDCODED_SR       (temp_decode_cs_HARDCODED_SR),
        .decode_cs_HARDCODED_SR_ID    (temp_decode_cs_HARDCODED_SR_ID),
        .decode_cs_HARDCODED_DR_RD    (temp_decode_cs_HARDCODED_DR_RD),
        .decode_cs_HARDCODED_DR_WR    (temp_decode_cs_HARDCODED_DR_WR),
        .decode_cs_HARDCODED_SR_RD    (temp_decode_cs_HARDCODED_SR_RD),
        .decode_cs_HARDCODED_SR_WR    (temp_decode_cs_HARDCODED_SR_WR),
        .decode_cs_HARDCODED_LD_OP    (temp_decode_cs_HARDCODED_LD_OP),
        .decode_cs_HARDCODED_ST_OP    (temp_decode_cs_HARDCODED_ST_OP),
        .decode_cs_LD_OP_CANCEL       (temp_decode_cs_LD_OP_CANCEL),
        .decode_cs_ST_OP_CANCEL       (temp_decode_cs_ST_OP_CANCEL),
        .decode_cs_OP_IN_MODRM        (temp_decode_cs_OP_IN_MODRM),
        .decode_cs_DATA_SIZE          (temp_decode_cs_DATA_SIZE),

        .rr_cs_ST_SEL          (temp_rr_cs_ST_SEL),
        .rr_cs_MODRM_NEEDED    (temp_rr_cs_MODRM_NEEDED),
        .rr_cs_RM_IS_DR        (temp_rr_cs_RM_IS_DR),
        .rr_cs_SWITCH_LD_ADDY  (temp_rr_cs_SWITCH_LD_ADDY),
        .rr_cs_LD_OP           (temp_rr_cs_LD_OP),
        .rr_cs_ST_OP           (temp_rr_cs_ST_OP),
        .rr_cs_dr_id           (temp_rr_cs_dr_id),
        .rr_cs_sr_id           (temp_rr_cs_sr_id),
        .rr_cs_dr_rd           (temp_rr_cs_dr_rd),
        .rr_cs_sr_rd           (temp_rr_cs_sr_rd),
        .rr_cs_eax_rd          (temp_rr_cs_eax_rd),
        .rr_cs_dr_wr           (temp_rr_cs_dr_wr),
        .rr_cs_sr_wr           (temp_rr_cs_sr_wr),
        .rr_cs_eax_wr          (temp_rr_cs_eax_wr),
        .rr_cs_MOVS_OP         (temp_rr_cs_MOVS_OP),
        .rr_cs_datasize        (temp_rr_cs_datasize),
        .rr_cs_will_mod_zf     (temp_rr_cs_will_mod_zf),
        .rr_cs_seg_1_valid     (temp_rr_cs_seg_1_valid),
        .rr_cs_seg_0_id        (temp_rr_cs_seg_0_id),
        .rr_cs_seg_1_id        (temp_rr_cs_seg_1_id),
        .rr_cs_special_modrm_bs(temp_rr_cs_special_modrm_bs),
        .rr_cs_special_br      (temp_rr_cs_special_br),

        .dc_cs_LD_OP    (temp_dc_cs_LD_OP),
        .dc_cs_ST_OP    (temp_dc_cs_ST_OP),
        .dc_cs_dr_upper8(temp_dc_cs_dr_upper8),
        .dc_cs_sr_upper8(temp_dc_cs_sr_upper8),
        .dc_cs_datasize (temp_dc_cs_datasize),

        .mem_cs_ST_OP   (temp_mem_cs_ST_OP),
        .mem_cs_LD_OP   (temp_mem_cs_LD_OP),

        .exe_cs_ST_OP             (temp_exe_cs_ST_OP),
        .exe_cs_OP_TYPE           (temp_exe_cs_OP_TYPE),
        .exe_cs_alu_inputA_sel    (temp_exe_cs_alu_inputA_sel),
        .exe_cs_alu_inputB_sel    (temp_exe_cs_alu_inputB_sel),
        .exe_cs_branch_target_sel (temp_exe_cs_branch_target_sel),
        .exe_cs_shift_by_one      (temp_exe_cs_shift_by_one),
        .exe_cs_br_ucond          (temp_exe_cs_br_ucond),
        .exe_cs_relative_branch   (temp_exe_cs_relative_branch),
        .exe_cs_special_br        (temp_exe_cs_special_br),
        .exe_cs_is_far            (temp_exe_cs_is_far),
        .exe_cs_is_call           (temp_exe_cs_is_call),
        .exe_cs_second_flag_needed(temp_exe_cs_second_flag_needed),
        .exe_cs_rep_no_zf_update  (temp_exe_cs_rep_no_zf_update),

        .wb_cs_ST_OP    (temp_wb_cs_ST_OP),
        .wb_cs_WB_DR    (temp_wb_cs_WB_DR),
        .wb_cs_WB_SR    (temp_wb_cs_WB_SR),
        .wb_cs_WB_EAX   (temp_wb_cs_WB_EAX)
    );

    decode_gp_gen gp_gen_decode (
        .prev_eip    (PrevEIP),
        .prev_length (PrevLength),
        .segLimit    (rr_outs_codeSeg_limit),
        .gp_fault_o  (decode_gp)
    );

    // -------------------------------------------------------------------------
    // idm_outs.idm_slots[EIP[5:4]] dynamic-index reads:
    //   br_eip, valid, br_valid, br_btb_target.  Replace with MUX_4 over the
    //   four flat per-slot inputs.
    // -------------------------------------------------------------------------
    wire [31:0] idm_slot_at_eip_br_eip;
    wire        idm_slot_at_eip_valid;
    wire        idm_slot_at_eip_br_valid;
    wire [31:0] idm_slot_at_eip_br_btb_target;

    `MUX_4(u_mx_idm_br_eip, 32, idm_slot_at_eip_br_eip,
           idm_outs_idm_slots_0_br_eip,        idm_outs_idm_slots_1_br_eip,
           idm_outs_idm_slots_2_br_eip,        idm_outs_idm_slots_3_br_eip,
           EIP[5:4])
    `MUX_4(u_mx_idm_valid, 1, idm_slot_at_eip_valid,
           idm_outs_idm_slots_0_valid,         idm_outs_idm_slots_1_valid,
           idm_outs_idm_slots_2_valid,         idm_outs_idm_slots_3_valid,
           EIP[5:4])
    `MUX_4(u_mx_idm_br_valid, 1, idm_slot_at_eip_br_valid,
           idm_outs_idm_slots_0_br_valid,      idm_outs_idm_slots_1_br_valid,
           idm_outs_idm_slots_2_br_valid,      idm_outs_idm_slots_3_br_valid,
           EIP[5:4])
    `MUX_4(u_mx_idm_btb_target, 32, idm_slot_at_eip_br_btb_target,
           idm_outs_idm_slots_0_br_btb_target, idm_outs_idm_slots_1_br_btb_target,
           idm_outs_idm_slots_2_br_btb_target, idm_outs_idm_slots_3_br_btb_target,
           EIP[5:4])

    // -------------------------------------------------------------------------
    // Branch info generation
    // -------------------------------------------------------------------------
    wire        predicted_taken;
    wire [31:0] predicted_target;
    wire        branch_info_valid;
    wire [31:0] branch_info_br_eip;
    wire        branch_info_br_xcl;
    wire        branch_info_br_pred_taken;
    wire [31:0] branch_info_speculative_target;
    wire        br_eip_eq_EIP;
    wire        branch_present;

    `CMP_N(br_eip_cmp,            32, br_eip_eq_EIP, idm_slot_at_eip_br_eip, EIP)
    `AND_3(predicted_taken_gate,   1, predicted_taken,
           idm_slot_at_eip_valid, idm_slot_at_eip_br_valid, br_eip_eq_EIP)
    `MUX_2(predicted_target_mux,  32, predicted_target,
           32'b0, idm_slot_at_eip_br_btb_target, predicted_taken)
    `OR_3 (branch_present_gate,    1, branch_present,
           temp_exe_cs_br_ucond, temp_exe_cs_relative_branch, temp_exe_cs_special_br)

    br_info_processing br_info_gen (
        .cs_branch                     (branch_present),
        .eip                           (EIP),
        .br_length                     (inst_length),
        .pred_taken                    (predicted_taken),
        .pred_target                   (predicted_target),
        .branch_info_valid             (branch_info_valid),
        .branch_info_br_eip            (branch_info_br_eip),
        .branch_info_br_xcl            (branch_info_br_xcl),
        .branch_info_br_pred_taken     (branch_info_br_pred_taken),
        .branch_info_speculative_target(branch_info_speculative_target)
    );

    // -------------------------------------------------------------------------
    // SIB processor
    // -------------------------------------------------------------------------
    wire [`REG_ID_W-1:0] sibbase, sibidx;
    wire [7:0]           sibscale;
    sib_processor sib_processing (
        .sib_byte    (sib_byte),
        .sib_idx_id  (sibidx),
        .sib_base_id (sibbase),
        .sib_scale   (sibscale)
    );

    // -------------------------------------------------------------------------
    // External-set-zf gate: only valid when the Decode forwards an inst that
    // mods ZF (drives rep_controller).
    // -------------------------------------------------------------------------
    wire external_set_zf;
    `AND_2(external_set_zf_gate, 1, external_set_zf,
           temp_rr_cs_will_mod_zf, decode_forward)

    wire not_decode_forward;
    `INV_N(not_decode_forward_inv, 1, decode_forward, not_decode_forward)

    wire invalid_instruction_not;
    `INV_N(invalid_instruction_not_u, 1, invalid_inst, invalid_instruction_not)

    rr_valid_logic decode_2_RR_valid_logic (
        .RR_we_o    (rr_latch_we_o),
        .N_RR_V_o   (next_rr_valid),
        .DECODE_V_i (invalid_instruction_not),
        .RR_stall_i (rr_outs_stall),
        .RR_V_i     (rr_outs_valid),
        .DC_stall_i (dc_outs_stall),
        .DC_V_i     (dc_outs_valid),
        .MEM_V_i    (mem_outs_valid),
        .MEM_stall_i(mem_outs_stall),
        .EXE_V_i    (exe_outs_valid),
        .WB_stall_i (wb_outs_wb_stall)
    );

    // -------------------------------------------------------------------------
    // Segment-override decode (one-hot prefix bits -> 5-bit reg id select)
    // -------------------------------------------------------------------------
    `OR_6(seg_override_gate, 1, seg_override,
        total_pf_vector[9], total_pf_vector[8], total_pf_vector[7],
        total_pf_vector[6], total_pf_vector[5], total_pf_vector[4])

    wire seg_sel_2, seg_sel_1, seg_sel_0;
    `OR_2(seg_sel_2_gate, 1, seg_sel_2, total_pf_vector[9], total_pf_vector[8])
    `OR_3(seg_sel_1_gate, 1, seg_sel_1, total_pf_vector[9], total_pf_vector[6], total_pf_vector[5])
    `OR_3(seg_sel_0_gate, 1, seg_sel_0, total_pf_vector[8], total_pf_vector[6], total_pf_vector[4])
    `MUX_8(segment0_mux, `REG_ID_W, segment0,
        `DS, `GS, `FS, `ES, `DS, `SS, `CS, `DS,
        {seg_sel_2, seg_sel_1, seg_sel_0})

    // -------------------------------------------------------------------------
    // Structural register block (replaces the always_ff blocks in Decode.sv)
    // -------------------------------------------------------------------------
    wire sync_clear_flush;
    `OR_2(u_sync_clear_flush, 1, sync_clear_flush, fetch_outs_exp_pipe_clear, flush)

    // ---- REP_LATCH and SAVED_* (gated by {REP, clear_rep}) ----
    wire clear_rep;
    wire rep_we;
    `OR_2(u_rep_we, 1, rep_we, temp_decode_cs_REP, clear_rep)

    wire rep_n;
    wire rep_capture;
    `INV_N(u_rep_inv,     1, temp_decode_cs_REP, rep_n)
    `NOR_2(u_rep_capture, 1, rep_capture, rep_n, clear_rep)

    wire rep_we_g;
    `OR_2(u_rep_we_g, 1, rep_we_g, rep_we, sync_clear_flush)

    wire rep_din_g;
    `MUX_2(u_rep_din_g, 1, rep_din_g, rep_capture, 1'b0, sync_clear_flush)
    `REG_RST_WE(u_rep_latch, 1, clk, rst,
                rep_we_g, rep_din_g, REP_LATCH)

    wire [`REG_ID_W-1:0] saved_seg0_din;
    `MUX_2(u_saved_seg0_mux, `REG_ID_W, saved_seg0_din, `REG_ID_W'b0, segment0, rep_capture)
    wire [`REG_ID_W-1:0] saved_seg0_din_g;
    `MUX_2(u_saved_seg0_din_g, `REG_ID_W, saved_seg0_din_g, saved_seg0_din, `REG_ID_W'b0, sync_clear_flush)
    `REG_RST_WE(u_saved_seg0, `REG_ID_W, clk, rst,
                rep_we_g, saved_seg0_din_g, SAVED_SEGMENT0)

    wire saved_segov_din;
    `MUX_2(u_saved_segov_mux, 1, saved_segov_din, 1'b0, seg_override, rep_capture)
    wire saved_segov_din_g;
    `MUX_2(u_saved_segov_din_g, 1, saved_segov_din_g, saved_segov_din, 1'b0, sync_clear_flush)
    `REG_RST_WE(u_saved_segov, 1, clk, rst,
                rep_we_g, saved_segov_din_g, SAVED_SEGMENT_OVERRIDE)

    wire [31:0] saved_rep_eip_din;
    `MUX_2(u_saved_rep_eip_mux, 32, saved_rep_eip_din, 32'b0, EIP, rep_capture)
    wire [31:0] saved_rep_eip_din_g;
    `MUX_2(u_saved_rep_eip_din_g, 32, saved_rep_eip_din_g, saved_rep_eip_din, 32'b0, sync_clear_flush)
    `REG_RST_WE(u_saved_rep_eip, 32, clk, rst,
                rep_we_g, saved_rep_eip_din_g, SAVED_REP_EIP)

    wire [1:0] saved_ds_din;
    `MUX_2(u_saved_ds_mux, 2, saved_ds_din, 2'b0, temp_decode_cs_DATA_SIZE, rep_capture)
    wire [1:0] saved_ds_din_g;
    `MUX_2(u_saved_ds_din_g, 2, saved_ds_din_g, saved_ds_din, 2'b0, sync_clear_flush)
    `REG_RST_WE(u_saved_ds, 2, clk, rst,
                rep_we_g, saved_ds_din_g, SAVED_DATASIZE)

    // ---- EIP / PrevEIP / PrevLength ----
    wire cond3, cond2, cond1, cond0;
    assign cond3 = fetch_outs_exp_pipe_clear;
    `AND_2(u_cond2, 1, cond2, exe_outs_br_res_valid, flush)
    assign cond1 = predicted_taken;
    `NOR_2(u_cond0, 1, cond0, HALT_REG, REP_LATCH)

    wire penc_valid;
    wire [2:0] penc_out;
    pencoder8_3v$ eip_penc (1'b0, {4'b0, cond3, cond2, cond1, cond0}, penc_out, penc_valid);
    wire [31:0] eip_next;
    `MUX_4(u_eip_next, 32, eip_next,
            NEIP, idm_slot_at_eip_br_btb_target,
            exe_outs_br_res_br_target, 32'b0, penc_out[1:0])

    wire eip_next_we_i_df0;
    wire eip_next_we_df0;
    `MUX_4(u_eip_next_we_mux_df0, 1, eip_next_we_i_df0,
            1'b0, 1'b0, 1'b1, 1'b1, penc_out[1:0])
    `AND_2(u_eip_next_we_df0, 1, eip_next_we_df0, eip_next_we_i_df0, penc_valid)

    wire eip_next_we_df1;
    assign eip_next_we_df1 = penc_valid;

    wire eip_next_we;
    `MUX_2(u_eip_next_we, 1, eip_next_we, eip_next_we_df0, eip_next_we_df1, decode_forward)

    `REG_RST_WE(u_eip, 32, clk, rst, eip_next_we, eip_next, EIP)

    wire [31:0] prev_eip_din_g;
    `MUX_2(u_prev_eip_din_g, 32, prev_eip_din_g, EIP, 32'b0, fetch_outs_exp_pipe_clear)
    `REG_RST_WE(u_prev_eip, 32, clk, rst, 1'b1, prev_eip_din_g, PrevEIP)

    wire [3:0] prev_len_din_g;
    `MUX_2(u_prev_len_din_g, 4, prev_len_din_g, inst_length, 4'b0, fetch_outs_exp_pipe_clear)
    `REG_RST_WE(u_prev_len, 4, clk, rst, 1'b1, prev_len_din_g, PrevLength)

    // ---- HALT_REG ----
    wire halt_we;
    `NOR_2(u_halt_we, 1, halt_we, HALT_REG, invalid_inst)
    wire halt_we_g, halt_din_g;
    `OR_2(u_halt_we_g, 1, halt_we_g, halt_we, sync_clear_flush)
    `MUX_2(u_halt_din_g, 1, halt_din_g, temp_decode_cs_HALT, 1'b0, sync_clear_flush)
    `REG_RST_WE(u_halt_reg, 1, clk, rst, halt_we_g, halt_din_g, HALT_REG)

    // ---- REP_CMP_LATCH ----
    wire repcmp_we, rep_cmp_n, repcmp_din;
    `OR_2(u_repcmp_we,    1, repcmp_we,  temp_decode_cs_REP_CMP, clear_rep)
    `INV_N(u_rep_cmp_inv, 1, temp_decode_cs_REP_CMP, rep_cmp_n)
    `NOR_2(u_repcmp_din,  1, repcmp_din, rep_cmp_n, clear_rep)
    wire repcmp_we_g, repcmp_din_g;
    `OR_2(u_repcmp_we_g,  1, repcmp_we_g,  repcmp_we, sync_clear_flush)
    `MUX_2(u_repcmp_din_g, 1, repcmp_din_g, repcmp_din, 1'b0, sync_clear_flush)
    `REG_RST_WE(u_rep_cmp, 1, clk, rst,
                repcmp_we_g, repcmp_din_g, REP_CMP_LATCH)

    // ---- REP_MOV_LATCH ----
    wire mov_cond, repmov_we, mov_cond_n, repmov_din;
    `NOR_2(u_mov_cond,     1, mov_cond,   rep_n, temp_decode_cs_REP_CMP)
    `OR_2(u_repmov_we,     1, repmov_we,  mov_cond, clear_rep)
    `INV_N(u_mov_cond_inv, 1, mov_cond,   mov_cond_n)
    `NOR_2(u_repmov_din,   1, repmov_din, mov_cond_n, clear_rep)
    wire repmov_we_g, repmov_din_g;
    `OR_2(u_repmov_we_g,   1, repmov_we_g,  repmov_we, sync_clear_flush)
    `MUX_2(u_repmov_din_g, 1, repmov_din_g, repmov_din, 1'b0, sync_clear_flush)
    `REG_RST_WE(u_rep_mov, 1, clk, rst,
                repmov_we_g, repmov_din_g, REP_MOV_LATCH)

    // ---- DC_SAVED_EIP / DECODE_SAVED_EIP ----
    `REG_RST_WE(u_dc_saved_eip,     32, clk, rst,
                fetch_outs_exp_pipe_clear, dc_outs_dc_eip, DC_SAVED_EIP)
    `REG_RST_WE(u_decode_saved_eip, 32, clk, rst,
                fetch_outs_exp_pipe_clear, EIP,            DECODE_SAVED_EIP)

    // EXCEPTION_EIP select
    wire int_mode_jk_n, exc_eip_sel;
    wire [31:0] EXCEPTION_EIP;
    `INV_N(u_int_mode_jk_inv, 1, fetch_outs_int_mode_jk, int_mode_jk_n)
    `NAND_2(u_exc_eip_sel,    1, exc_eip_sel,
            fetch_outs_exp_mode_jk[1], int_mode_jk_n)
    `MUX_2(u_exception_eip,  32, EXCEPTION_EIP,
           DC_SAVED_EIP, DECODE_SAVED_EIP, exc_eip_sel)

    // valid block: !going_to_halt & !going_to_rep & !exp_pipe_clear
    wire going_to_halt, going_to_rep;
    `OR_2(u_going_to_halt, 1, going_to_halt, HALT_REG,  temp_decode_cs_HALT)
    `OR_2(u_going_to_rep,  1, going_to_rep,  REP_LATCH, temp_decode_cs_REP)

    wire valid_block, rr_latch_valid;
    `NOR_3(u_valid_block,    1, valid_block,
           going_to_halt, going_to_rep, fetch_outs_exp_pipe_clear)
    `AND_2(u_rr_latch_valid, 1, rr_latch_valid, next_rr_valid, valid_block)

    // latch EIP select
    wire latch_eip_sel;
    wire [31:0] latch_eip;
    `OR_2(u_latch_eip_sel, 1, latch_eip_sel,
          fetch_outs_exp_mode_jk[0], fetch_outs_int_mode_jk)
    `MUX_2(u_latch_eip, 32, latch_eip, EIP, EXCEPTION_EIP, latch_eip_sel)

    // sib/disp gating: (MODRM_NEEDED) ? x : 0
    wire sib_needed_g, disp_needed_g, disp_size_g;
    `MUX_2(u_sib_needed_g,  1, sib_needed_g,  1'b0, sib_size,    temp_rr_cs_MODRM_NEEDED)
    `MUX_2(u_disp_needed_g, 1, disp_needed_g, 1'b0, disp_needed, temp_rr_cs_MODRM_NEEDED)
    `MUX_2(u_disp_size_g,   1, disp_size_g,   1'b0, disp_size,   temp_rr_cs_MODRM_NEEDED)

    // -------------------------------------------------------------------------
    // rr_latches_next.normal_latches output drivers
    // (replaces the SV `assign temp_rr_latch = '{...}` struct literal)
    // -------------------------------------------------------------------------
    assign rr_latches_next_normal_latches_valid                  = rr_latch_valid;

    // rr_cs_t pass-through from control_store outputs
    assign rr_latches_next_normal_latches_cs_ST_SEL              = temp_rr_cs_ST_SEL;
    assign rr_latches_next_normal_latches_cs_MODRM_NEEDED        = temp_rr_cs_MODRM_NEEDED;
    assign rr_latches_next_normal_latches_cs_RM_IS_DR            = temp_rr_cs_RM_IS_DR;
    assign rr_latches_next_normal_latches_cs_SWITCH_LD_ADDY      = temp_rr_cs_SWITCH_LD_ADDY;
    assign rr_latches_next_normal_latches_cs_LD_OP               = temp_rr_cs_LD_OP;
    assign rr_latches_next_normal_latches_cs_ST_OP               = temp_rr_cs_ST_OP;
    assign rr_latches_next_normal_latches_cs_dr_id               = temp_rr_cs_dr_id;
    assign rr_latches_next_normal_latches_cs_sr_id               = temp_rr_cs_sr_id;
    assign rr_latches_next_normal_latches_cs_dr_rd               = temp_rr_cs_dr_rd;
    assign rr_latches_next_normal_latches_cs_sr_rd               = temp_rr_cs_sr_rd;
    assign rr_latches_next_normal_latches_cs_eax_rd              = temp_rr_cs_eax_rd;
    assign rr_latches_next_normal_latches_cs_dr_wr               = temp_rr_cs_dr_wr;
    assign rr_latches_next_normal_latches_cs_sr_wr               = temp_rr_cs_sr_wr;
    assign rr_latches_next_normal_latches_cs_eax_wr              = temp_rr_cs_eax_wr;
    assign rr_latches_next_normal_latches_cs_MOVS_OP             = temp_rr_cs_MOVS_OP;
    assign rr_latches_next_normal_latches_cs_datasize            = temp_rr_cs_datasize;
    assign rr_latches_next_normal_latches_cs_will_mod_zf         = temp_rr_cs_will_mod_zf;
    assign rr_latches_next_normal_latches_cs_seg_1_valid         = temp_rr_cs_seg_1_valid;
    assign rr_latches_next_normal_latches_cs_seg_0_id            = temp_rr_cs_seg_0_id;
    assign rr_latches_next_normal_latches_cs_seg_1_id            = temp_rr_cs_seg_1_id;
    assign rr_latches_next_normal_latches_cs_special_modrm_bs    = temp_rr_cs_special_modrm_bs;
    assign rr_latches_next_normal_latches_cs_special_br          = temp_rr_cs_special_br;

    // dc_cs_t pass-through
    assign rr_latches_next_normal_latches_dc_cs_LD_OP            = temp_dc_cs_LD_OP;
    assign rr_latches_next_normal_latches_dc_cs_ST_OP            = temp_dc_cs_ST_OP;
    assign rr_latches_next_normal_latches_dc_cs_dr_upper8        = temp_dc_cs_dr_upper8;
    assign rr_latches_next_normal_latches_dc_cs_sr_upper8        = temp_dc_cs_sr_upper8;
    assign rr_latches_next_normal_latches_dc_cs_datasize         = temp_dc_cs_datasize;

    // mem_cs_t pass-through
    assign rr_latches_next_normal_latches_mem_cs_ST_OP           = temp_mem_cs_ST_OP;
    assign rr_latches_next_normal_latches_mem_cs_LD_OP           = temp_mem_cs_LD_OP;

    // exe_cs_t pass-through
    assign rr_latches_next_normal_latches_exe_cs_ST_OP           = temp_exe_cs_ST_OP;
    assign rr_latches_next_normal_latches_exe_cs_OP_TYPE         = temp_exe_cs_OP_TYPE;
    assign rr_latches_next_normal_latches_exe_cs_alu_inputA_sel  = temp_exe_cs_alu_inputA_sel;
    assign rr_latches_next_normal_latches_exe_cs_alu_inputB_sel  = temp_exe_cs_alu_inputB_sel;
    assign rr_latches_next_normal_latches_exe_cs_branch_target_sel = temp_exe_cs_branch_target_sel;
    assign rr_latches_next_normal_latches_exe_cs_shift_by_one    = temp_exe_cs_shift_by_one;
    assign rr_latches_next_normal_latches_exe_cs_br_ucond        = temp_exe_cs_br_ucond;
    assign rr_latches_next_normal_latches_exe_cs_relative_branch = temp_exe_cs_relative_branch;
    assign rr_latches_next_normal_latches_exe_cs_special_br      = temp_exe_cs_special_br;
    assign rr_latches_next_normal_latches_exe_cs_is_far          = temp_exe_cs_is_far;
    assign rr_latches_next_normal_latches_exe_cs_is_call         = temp_exe_cs_is_call;
    assign rr_latches_next_normal_latches_exe_cs_second_flag_needed = temp_exe_cs_second_flag_needed;
    assign rr_latches_next_normal_latches_exe_cs_rep_no_zf_update = temp_exe_cs_rep_no_zf_update;

    // wb_cs_t pass-through
    assign rr_latches_next_normal_latches_wb_cs_ST_OP            = temp_wb_cs_ST_OP;
    assign rr_latches_next_normal_latches_wb_cs_WB_DR            = temp_wb_cs_WB_DR;
    assign rr_latches_next_normal_latches_wb_cs_WB_SR            = temp_wb_cs_WB_SR;
    assign rr_latches_next_normal_latches_wb_cs_WB_EAX           = temp_wb_cs_WB_EAX;

    // br_info_t (from br_info_processing flat outputs)
    assign rr_latches_next_normal_latches_br_info_valid               = branch_info_valid;
    assign rr_latches_next_normal_latches_br_info_br_eip              = branch_info_br_eip;
    assign rr_latches_next_normal_latches_br_info_br_xcl              = branch_info_br_xcl;
    assign rr_latches_next_normal_latches_br_info_br_pred_taken       = branch_info_br_pred_taken;
    assign rr_latches_next_normal_latches_br_info_speculative_target  = branch_info_speculative_target;

    assign rr_latches_next_normal_latches_NEIP                   = NEIP;
    assign rr_latches_next_normal_latches_EIP                    = latch_eip;
    assign rr_latches_next_normal_latches_EAX                    = rr_outs_eax;
    assign rr_latches_next_normal_latches_imm64                  = imm64;

    assign rr_latches_next_normal_latches_sib_idx_id             = sibidx;
    assign rr_latches_next_normal_latches_sib_base_id            = sibbase;
    assign rr_latches_next_normal_latches_sib_needed             = sib_needed_g;
    assign rr_latches_next_normal_latches_sib_scale              = sibscale;
    assign rr_latches_next_normal_latches_disp_needed            = disp_needed_g;
    assign rr_latches_next_normal_latches_disp_size              = disp_size_g;
    assign rr_latches_next_normal_latches_displacement           = displacement;

    // -------------------------------------------------------------------------
    // outs_o assignments (replaces SV `assign outs_o = '{...}` struct literal)
    // -------------------------------------------------------------------------
    wire decode_gp_out;
    `AND_2(decode_gp_u, 1, decode_gp_out, decode_gp, rr_outs_valid)

    assign outs_valid               = invalid_instruction_not;
    assign outs_stall               = invalid_inst;
    assign outs_eip                 = EIP;
    assign outs_invalid_instruction = invalid_inst;
    assign outs_decode_gp           = decode_gp_out;
    assign outs_rr_stage_latch_we   = rr_latch_we_o;
    assign outs_rep_latch           = REP_LATCH;
    assign outs_decode_forward      = decode_forward;

    // -------------------------------------------------------------------------
    // rep_controller drives rr_latches_next.rep_latches directly: hook each
    // flat output port of the controller to the matching Decode output port.
    // -------------------------------------------------------------------------
    rep_controller piece_of_shit_rep_controller (
        // --- inputs ---
        .clk                                    (clk),
        .rst                                    (rst),
        .rep_latch                              (REP_LATCH),
        .mov_inst                               (REP_MOV_LATCH),
        .cmp_inst                               (REP_CMP_LATCH),
        .clear_zf                               (exe_outs_clr_ZF_sb),
        .external_set_zf                        (external_set_zf),
        .ecx                                    (rr_outs_ecx),
        .ecx_sb                                 (rr_outs_ecx_sb),
        .zf_flag                                (exe_outs_ZF),
        .stall                                  (not_decode_forward),
        .flush                                  (flush),
        .exp_pipe_clear                         (fetch_outs_exp_pipe_clear),
        .saved_segment0                         (SAVED_SEGMENT0),
        .saved_segment_override                 (SAVED_SEGMENT_OVERRIDE),
        .saved_rep_eip                          (SAVED_REP_EIP),
        .saved_datasize                         (SAVED_DATASIZE),

        // --- rep_latches outputs ---
        .rep_latches_valid                      (rr_latches_next_rep_latches_valid),
        .rep_latches_cs_ST_SEL                  (rr_latches_next_rep_latches_cs_ST_SEL),
        .rep_latches_cs_MODRM_NEEDED            (rr_latches_next_rep_latches_cs_MODRM_NEEDED),
        .rep_latches_cs_RM_IS_DR                (rr_latches_next_rep_latches_cs_RM_IS_DR),
        .rep_latches_cs_SWITCH_LD_ADDY          (rr_latches_next_rep_latches_cs_SWITCH_LD_ADDY),
        .rep_latches_cs_LD_OP                   (rr_latches_next_rep_latches_cs_LD_OP),
        .rep_latches_cs_ST_OP                   (rr_latches_next_rep_latches_cs_ST_OP),
        .rep_latches_cs_dr_id                   (rr_latches_next_rep_latches_cs_dr_id),
        .rep_latches_cs_sr_id                   (rr_latches_next_rep_latches_cs_sr_id),
        .rep_latches_cs_dr_rd                   (rr_latches_next_rep_latches_cs_dr_rd),
        .rep_latches_cs_sr_rd                   (rr_latches_next_rep_latches_cs_sr_rd),
        .rep_latches_cs_eax_rd                  (rr_latches_next_rep_latches_cs_eax_rd),
        .rep_latches_cs_dr_wr                   (rr_latches_next_rep_latches_cs_dr_wr),
        .rep_latches_cs_sr_wr                   (rr_latches_next_rep_latches_cs_sr_wr),
        .rep_latches_cs_eax_wr                  (rr_latches_next_rep_latches_cs_eax_wr),
        .rep_latches_cs_MOVS_OP                 (rr_latches_next_rep_latches_cs_MOVS_OP),
        .rep_latches_cs_datasize                (rr_latches_next_rep_latches_cs_datasize),
        .rep_latches_cs_will_mod_zf             (rr_latches_next_rep_latches_cs_will_mod_zf),
        .rep_latches_cs_seg_1_valid             (rr_latches_next_rep_latches_cs_seg_1_valid),
        .rep_latches_cs_seg_0_id                (rr_latches_next_rep_latches_cs_seg_0_id),
        .rep_latches_cs_seg_1_id                (rr_latches_next_rep_latches_cs_seg_1_id),
        .rep_latches_cs_special_modrm_bs        (rr_latches_next_rep_latches_cs_special_modrm_bs),
        .rep_latches_cs_special_br              (rr_latches_next_rep_latches_cs_special_br),
        .rep_latches_dc_cs_LD_OP                (rr_latches_next_rep_latches_dc_cs_LD_OP),
        .rep_latches_dc_cs_ST_OP                (rr_latches_next_rep_latches_dc_cs_ST_OP),
        .rep_latches_dc_cs_dr_upper8            (rr_latches_next_rep_latches_dc_cs_dr_upper8),
        .rep_latches_dc_cs_sr_upper8            (rr_latches_next_rep_latches_dc_cs_sr_upper8),
        .rep_latches_dc_cs_datasize             (rr_latches_next_rep_latches_dc_cs_datasize),
        .rep_latches_mem_cs_ST_OP               (rr_latches_next_rep_latches_mem_cs_ST_OP),
        .rep_latches_mem_cs_LD_OP               (rr_latches_next_rep_latches_mem_cs_LD_OP),
        .rep_latches_exe_cs_ST_OP               (rr_latches_next_rep_latches_exe_cs_ST_OP),
        .rep_latches_exe_cs_OP_TYPE             (rr_latches_next_rep_latches_exe_cs_OP_TYPE),
        .rep_latches_exe_cs_alu_inputA_sel      (rr_latches_next_rep_latches_exe_cs_alu_inputA_sel),
        .rep_latches_exe_cs_alu_inputB_sel      (rr_latches_next_rep_latches_exe_cs_alu_inputB_sel),
        .rep_latches_exe_cs_branch_target_sel   (rr_latches_next_rep_latches_exe_cs_branch_target_sel),
        .rep_latches_exe_cs_shift_by_one        (rr_latches_next_rep_latches_exe_cs_shift_by_one),
        .rep_latches_exe_cs_br_ucond            (rr_latches_next_rep_latches_exe_cs_br_ucond),
        .rep_latches_exe_cs_relative_branch     (rr_latches_next_rep_latches_exe_cs_relative_branch),
        .rep_latches_exe_cs_special_br          (rr_latches_next_rep_latches_exe_cs_special_br),
        .rep_latches_exe_cs_is_far              (rr_latches_next_rep_latches_exe_cs_is_far),
        .rep_latches_exe_cs_is_call             (rr_latches_next_rep_latches_exe_cs_is_call),
        .rep_latches_exe_cs_second_flag_needed  (rr_latches_next_rep_latches_exe_cs_second_flag_needed),
        .rep_latches_exe_cs_rep_no_zf_update    (rr_latches_next_rep_latches_exe_cs_rep_no_zf_update),
        .rep_latches_wb_cs_ST_OP                (rr_latches_next_rep_latches_wb_cs_ST_OP),
        .rep_latches_wb_cs_WB_DR                (rr_latches_next_rep_latches_wb_cs_WB_DR),
        .rep_latches_wb_cs_WB_SR                (rr_latches_next_rep_latches_wb_cs_WB_SR),
        .rep_latches_wb_cs_WB_EAX               (rr_latches_next_rep_latches_wb_cs_WB_EAX),
        .rep_latches_br_info_valid              (rr_latches_next_rep_latches_br_info_valid),
        .rep_latches_br_info_br_eip             (rr_latches_next_rep_latches_br_info_br_eip),
        .rep_latches_br_info_br_xcl             (rr_latches_next_rep_latches_br_info_br_xcl),
        .rep_latches_br_info_br_pred_taken      (rr_latches_next_rep_latches_br_info_br_pred_taken),
        .rep_latches_br_info_speculative_target (rr_latches_next_rep_latches_br_info_speculative_target),
        .rep_latches_NEIP                       (rr_latches_next_rep_latches_NEIP),
        .rep_latches_EIP                        (rr_latches_next_rep_latches_EIP),
        .rep_latches_EAX                        (rr_latches_next_rep_latches_EAX),
        .rep_latches_imm64                      (rr_latches_next_rep_latches_imm64),
        .rep_latches_sib_idx_id                 (rr_latches_next_rep_latches_sib_idx_id),
        .rep_latches_sib_base_id                (rr_latches_next_rep_latches_sib_base_id),
        .rep_latches_sib_needed                 (rr_latches_next_rep_latches_sib_needed),
        .rep_latches_sib_scale                  (rr_latches_next_rep_latches_sib_scale),
        .rep_latches_disp_needed                (rr_latches_next_rep_latches_disp_needed),
        .rep_latches_disp_size                  (rr_latches_next_rep_latches_disp_size),
        .rep_latches_displacement               (rr_latches_next_rep_latches_displacement),

        .clear_rep                              (clear_rep)
    );

endmodule
