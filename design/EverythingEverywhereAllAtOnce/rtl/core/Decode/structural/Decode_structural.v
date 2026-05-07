module Decode (
    input wire clk,
    input wire rst,

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

    wire [31:0] PrevEIP;
    wire [31:0] EIP;
    wire [31:0] NEIP;
    wire [3:0] inst_length;
    wire [3:0] PrevLength;
    wire [7:0] sib_byte;
    wire sib_size;
    wire disp_needed;
    wire [31:0] displacement;
    wire disp_size;
    wire [63:0] imm64;
    wire [9:0] total_pf_vector;  //MSB --> 2e, 36, 3e, 26, 64, 65, 66, 67, 0f, f3  <-- LSB vector
    wire invalid_inst;
    wire [7:0] opcode_byte, modrm_byte;
    // ----- decode_cs (flat) -----
    wire        decode_cs_REP;
    wire        decode_cs_REP_CMP;
    wire        decode_cs_HALT;
    wire        decode_cs_MODRM_NEEDED;
    wire        decode_cs_RM_IS_DR;
    wire        decode_cs_REG_IS_DR;
    wire        decode_cs_REG_IS_SEGMENT;
    wire        decode_cs_HARDCODED_DR_HIGH8;
    wire        decode_cs_MODRM_BUT_NO_SR;
    wire        decode_cs_HARDCODED_DR;
    wire [`REG_ID_W-1:0] decode_cs_HARDCODED_DR_ID;
    wire        decode_cs_HARDCODED_SR;
    wire [`REG_ID_W-1:0] decode_cs_HARDCODED_SR_ID;
    wire        decode_cs_HARDCODED_DR_RD;
    wire        decode_cs_HARDCODED_DR_WR;
    wire        decode_cs_HARDCODED_SR_RD;
    wire        decode_cs_HARDCODED_SR_WR;
    wire        decode_cs_HARDCODED_LD_OP;
    wire        decode_cs_HARDCODED_ST_OP;
    wire        decode_cs_LD_OP_CANCEL;
    wire        decode_cs_ST_OP_CANCEL;
    wire        decode_cs_OP_IN_MODRM;
    wire [1:0]  decode_cs_DATA_SIZE;

    // ----- rr_cs (flat) -----
    wire        rr_cs_ST_SEL;
    wire        rr_cs_MODRM_NEEDED;
    wire        rr_cs_RM_IS_DR;
    wire        rr_cs_SWITCH_LD_ADDY;
    wire        rr_cs_LD_OP;
    wire        rr_cs_ST_OP;
    wire [`REG_ID_W-1:0] rr_cs_dr_id;
    wire [`REG_ID_W-1:0] rr_cs_sr_id;
    wire        rr_cs_dr_rd;
    wire        rr_cs_sr_rd;
    wire        rr_cs_eax_rd;
    wire        rr_cs_dr_wr;
    wire        rr_cs_sr_wr;
    wire        rr_cs_eax_wr;
    wire        rr_cs_MOVS_OP;
    wire [1:0]  rr_cs_datasize;
    wire        rr_cs_will_mod_zf;
    wire        rr_cs_seg_1_valid;
    wire [`REG_ID_W-1:0] rr_cs_seg_0_id;
    wire [`REG_ID_W-1:0] rr_cs_seg_1_id;
    wire        rr_cs_special_modrm_bs;
    wire        rr_cs_special_br;

    // ----- dc_cs (flat) -----
    wire        dc_cs_LD_OP;
    wire        dc_cs_ST_OP;
    wire        dc_cs_dr_upper8;
    wire        dc_cs_sr_upper8;
    wire [1:0]  dc_cs_datasize;

    // ----- mem_cs (flat) -----
    wire        mem_cs_ST_OP;
    wire        mem_cs_LD_OP;

    // ----- exe_cs (flat) -----
    wire        exe_cs_ST_OP;
    wire [`EXE_OP_W-1:0]  exe_cs_OP_TYPE;
    wire [`SRC_SEL_W-1:0] exe_cs_alu_inputA_sel;
    wire [`SRC_SEL_W-1:0] exe_cs_alu_inputB_sel;
    wire [`SRC_SEL_W-1:0] exe_cs_branch_target_sel;
    wire        exe_cs_shift_by_one;
    wire        exe_cs_br_ucond;
    wire        exe_cs_relative_branch;
    wire        exe_cs_special_br;
    wire        exe_cs_is_far;
    wire        exe_cs_is_call;
    wire        exe_cs_second_flag_needed;
    wire        exe_cs_rep_no_zf_update;

    // ----- wb_cs (flat) -----
    wire        wb_cs_ST_OP;
    wire        wb_cs_WB_DR;
    wire        wb_cs_WB_SR;
    wire        wb_cs_WB_EAX;
    wire decode_gp;
    wire flush; //cpaddyx , i did not put ts here, whats this for
    wire REP_LATCH, REP_CMP_LATCH, REP_MOV_LATCH, HALT_REG;
    wire REP_CMP_LATCH_pre, REP_MOV_LATCH_pre;
    wire rr_latch_we_o;

    wire [31:0] DC_SAVED_EIP;
    wire [31:0] DECODE_SAVED_EIP;

    wire [`REG_ID_W-1:0] SAVED_SEGMENT0;
    wire SAVED_SEGMENT_OVERRIDE, SAVED_SEGMENT_OVERRIDE_pre;
    wire [31:0] SAVED_REP_EIP, SAVED_REP_EIP_pre;
    wire [1:0] SAVED_DATASIZE, SAVED_DATASIZE_pre;


    wire [`REG_ID_W-1:0] segment0, segment0_pre;
    wire seg_override, seg_override_pre;
    wire next_rr_valid;

    bufferH16$ buf_flush (.out(flush), .in(exe_outs_br_res_flush));

    // Input port fanout buffers
    wire idm_outs_idm_slots_0_valid_buf, idm_outs_idm_slots_1_valid_buf;
    wire idm_outs_idm_slots_2_valid_buf, idm_outs_idm_slots_3_valid_buf;
    wire fetch_outs_exp_pipe_clear_buf;
    wire rr_outs_ecx_sb_buf;
    bufferH16$ buf_idm0_valid (.out(idm_outs_idm_slots_0_valid_buf), .in(idm_outs_idm_slots_0_valid));
    bufferH16$ buf_idm1_valid (.out(idm_outs_idm_slots_1_valid_buf), .in(idm_outs_idm_slots_1_valid));
    bufferH16$ buf_idm2_valid (.out(idm_outs_idm_slots_2_valid_buf), .in(idm_outs_idm_slots_2_valid));
    bufferH16$ buf_idm3_valid (.out(idm_outs_idm_slots_3_valid_buf), .in(idm_outs_idm_slots_3_valid));
    bufferH64$ buf_exp_pipe_clear (.out(fetch_outs_exp_pipe_clear_buf), .in(fetch_outs_exp_pipe_clear));
    bufferH16$ buf_ecx_sb (.out(rr_outs_ecx_sb_buf), .in(rr_outs_ecx_sb));

    wire decode_forward;
    `AND_2 (decode_forward_u, 1, decode_forward, rr_latch_we_o, next_rr_valid)

    wire [511:0] flattened_queue;
    assign flattened_queue = {idm_outs_idm_slots_3_data, idm_outs_idm_slots_2_data, idm_outs_idm_slots_1_data, idm_outs_idm_slots_0_data};

    predecode inst_processing(
        .clk(clk), .rst(rst), .queue(flattened_queue),
        .queue_valid({idm_outs_idm_slots_3_valid_buf, idm_outs_idm_slots_2_valid_buf,
                    idm_outs_idm_slots_1_valid_buf, idm_outs_idm_slots_0_valid_buf}),
        .EIP(EIP), .NEIP(NEIP), .inst_length(inst_length), .sib_byte(sib_byte), .sib_size(sib_size),
        .opcode_byte(opcode_byte), .modrm_byte(modrm_byte), .disp(displacement), .disp_size(disp_size),
        .disp_needed(disp_needed), .imm64(imm64), .total_pf_vector_o(total_pf_vector), .invalid_inst(invalid_inst),

        .seg_override(seg_override),
        .seg0(segment0),

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

    decode_gp_gen gp_gen_decode(
        .prev_eip(PrevEIP), .prev_length(PrevLength),
        .segLimit(rr_outs_codeSeg_limit), .gp_fault_o(decode_gp)
    );

    wire predicted_taken, predicted_taken_pre;
    wire [31:0] predicted_target;    
    wire branch_info_valid;
    wire [31:0] branch_info_br_eip;
    wire branch_info_br_xcl;
    wire branch_info_br_pred_taken;
    wire [31:0] branch_info_speculative_target;
    wire br_eip_eq_EIP;
    wire branch_present;

    wire        current_idm_slots_valid;
    wire        current_idm_slots_br_valid;
    wire [31:0] current_idm_slots_br_eip;
    wire [31:0] current_idm_slots_br_btb_target;
    `MUX_4 (u_current_idm_valid, 1, current_idm_slots_valid, idm_outs_idm_slots_0_valid_buf, idm_outs_idm_slots_1_valid_buf, idm_outs_idm_slots_2_valid_buf, idm_outs_idm_slots_3_valid_buf, EIP[5:4])
    `MUX_4 (u_current_idm_br_valid, 1, current_idm_slots_br_valid, idm_outs_idm_slots_0_br_valid, idm_outs_idm_slots_1_br_valid, idm_outs_idm_slots_2_br_valid, idm_outs_idm_slots_3_br_valid, EIP[5:4])
    `MUX_4 (u_current_idm_br_eip, 32, current_idm_slots_br_eip, idm_outs_idm_slots_0_br_eip, idm_outs_idm_slots_1_br_eip, idm_outs_idm_slots_2_br_eip, idm_outs_idm_slots_3_br_eip, EIP[5:4])
    `MUX_4 (u_current_idm_br_btb_targ, 32, current_idm_slots_br_btb_target, idm_outs_idm_slots_0_br_btb_target, idm_outs_idm_slots_1_br_btb_target, idm_outs_idm_slots_2_br_btb_target, idm_outs_idm_slots_3_br_btb_target, EIP[5:4])


    `CMP_N(br_eip_cmp, 32, br_eip_eq_EIP, current_idm_slots_br_eip, EIP)
    `AND_3(predicted_taken_gate, 1, predicted_taken_pre, current_idm_slots_br_valid, current_idm_slots_br_valid, br_eip_eq_EIP)
    bufferH64$ buf_predicted_taken (.out(predicted_taken), .in(predicted_taken_pre));
    `MUX_2(predicted_target_mux, 32, predicted_target, 32'b0, current_idm_slots_br_btb_target, predicted_taken)
    `OR_3(branch_present_gate,    1, branch_present,   exe_cs_br_ucond, exe_cs_relative_branch, exe_cs_special_br)

    br_info_processing br_info_gen(
        .cs_branch(branch_present), .eip(EIP), .neip(NEIP),//.br_length(inst_length),
        .pred_taken(predicted_taken), .pred_target(predicted_target), 
        .branch_info_valid(branch_info_valid),
        .branch_info_br_eip(branch_info_br_eip),
        .branch_info_br_xcl(branch_info_br_xcl),
        .branch_info_br_pred_taken(branch_info_br_pred_taken),
        .branch_info_speculative_target(branch_info_speculative_target)
    );

    wire [`REG_ID_W-1:0] sibbase, sibidx;
    wire [7:0] sibscale;
    sib_processor sib_processing(.sib_byte(sib_byte), .sib_idx_id(sibidx), 
        .sib_base_id(sibbase), .sib_scale(sibscale)
    );

    wire clear_rep;

    wire external_set_zf;
    `AND_2(external_set_zf_gate, 1, external_set_zf, rr_cs_will_mod_zf, decode_forward)

    wire not_decode_forward;
    `INV_N(not_decode_forward_inv, 1, decode_forward, not_decode_forward)

    wire invalid_instruction_not;
    `INV_N(invalid_instruction_not_u, 1, invalid_inst, invalid_instruction_not)
  
    rr_valid_logic decode_2_RR_valid_logic(
        .RR_we_o(rr_latch_we_o),
        .N_RR_V_o(next_rr_valid),
        .DECODE_V_i(invalid_instruction_not),
        .RR_stall_i(rr_outs_stall),
        .RR_V_i(rr_outs_valid),
        .DC_stall_i(dc_outs_stall),
        .DC_V_i(dc_outs_valid),
        .MEM_V_i(mem_outs_valid),
        .MEM_stall_i(mem_outs_stall),
        .EXE_V_i(exe_outs_valid),
        .WB_stall_i(wb_outs_wb_stall)
    );

    // seg_override: any segment prefix bit [9:4] is active
    `OR_6(seg_override_gate, 1, seg_override_pre,
        total_pf_vector[9], total_pf_vector[8], total_pf_vector[7],
        total_pf_vector[6], total_pf_vector[5], total_pf_vector[4])
    bufferH256$ buf_seg_override (.out(seg_override), .in(seg_override_pre));

    // segment0: bits [9:4] are one-hot, so encode directly to 3-bit binary select
    // sel[2]=[9]|[8]  sel[1]=[9]|[6]|[5]  sel[0]=[8]|[6]|[4]
    // [7] encodes to 000 (same as default DS), so no special case needed
    // sel: 000->DS  001->GS  010->FS  011->ES  101->SS  110->CS
    wire seg_sel_2, seg_sel_1, seg_sel_0;
    wire seg_sel_2_pre, seg_sel_1_pre, seg_sel_0_pre;
    wire seg_sel_2_, seg_sel_1_, seg_sel_0_;
    `OR_2(seg_sel_2_gate, 1, seg_sel_2_pre, total_pf_vector[9], total_pf_vector[8])
    `OR_3(seg_sel_1_gate, 1, seg_sel_1_pre, total_pf_vector[9], total_pf_vector[6], total_pf_vector[5])
    `OR_3(seg_sel_0_gate, 1, seg_sel_0_pre, total_pf_vector[8], total_pf_vector[6], total_pf_vector[4])
    bufferH16$ buf_seg_sel_2 (.out(seg_sel_2), .in(seg_sel_2_pre));
    bufferH16$ buf_seg_sel_1 (.out(seg_sel_1), .in(seg_sel_1_pre));
    bufferH16$ buf_seg_sel_0 (.out(seg_sel_0), .in(seg_sel_0_pre));

    `OR_2(seg_sel_2_gate_, 1, seg_sel_2_, total_pf_vector[9], total_pf_vector[8])
    `OR_3(seg_sel_1_gate_, 1, seg_sel_1_, total_pf_vector[9], total_pf_vector[6], total_pf_vector[5])
    `OR_3(seg_sel_0_gate_, 1, seg_sel_0_, total_pf_vector[8], total_pf_vector[6], total_pf_vector[4])

    `MUX_8_H8(segment0_mux, `REG_ID_W, segment0_pre,
        `DS, `GS, `FS, `ES, `DS, `SS, `CS, `DS,
        {seg_sel_2, seg_sel_1, seg_sel_0}, {seg_sel_2_, seg_sel_1_, seg_sel_0_})
    bufferH64$ seg_buf0(.out(segment0[0]), .in(segment0_pre[0]));
    bufferH64$ seg_buf1(.out(segment0[1]), .in(segment0_pre[1]));
    bufferH64$ seg_buf2(.out(segment0[2]), .in(segment0_pre[2]));
    bufferH64$ seg_buf3(.out(segment0[3]), .in(segment0_pre[3]));
    bufferH64$ seg_buf4(.out(segment0[4]), .in(segment0_pre[4]));
    


    // // -----------------------------------------------------------------
    // // Structural register block (replaces the two always_ff blocks).
    // // -----------------------------------------------------------------
    // Registers have ASYNC reset, so only the true async `rst` (active-low)
    // feeds the rst port. exp_pipe_clear and flush are applied synchronously
    // via we/din overrides: when sync_clear_* is asserted we force we=1 and
    // mux din to 0, which matches the synchronous clears in Decode.sv.
    wire sync_clear_flush, sync_clear_flush_pre;
    `OR_2(u_sync_clear_flush, 1, sync_clear_flush_pre, fetch_outs_exp_pipe_clear_buf, flush)
    bufferH64$ buf_sync_clear_flush (.out(sync_clear_flush), .in(sync_clear_flush_pre));

    // ---- REP_LATCH and SAVED_* (gated by {REP, clear_rep}) ----
    //   00: hold; 01: 0; 10: capture; 11: 0
    //   => we = REP | clear_rep, set = REP & !clear_rep = NOR(!REP, clear_rep)
    wire rep_we;
    `OR_2(u_rep_we, 1, rep_we, decode_cs_REP, clear_rep)

    wire rep_n;
    wire rep_capture, rep_capture_pre;
    `INV_N(u_rep_inv, 1, decode_cs_REP, rep_n)
    `NOR_2(u_rep_capture, 1, rep_capture_pre, rep_n, clear_rep)
    bufferH64$ buf_rep_capture (.out(rep_capture), .in(rep_capture_pre));

    // Shared sync-clear gating: rep_we_g forces a write on sync_clear_flush so
    // every {REP_LATCH, SAVED_*} register can be muxed to 0 the same cycle.
    wire rep_we_g, rep_we_g_pre;
    `OR_2(u_rep_we_g, 1, rep_we_g_pre, rep_we, sync_clear_flush)
    bufferH16$ buf_rep_we_g (.out(rep_we_g), .in(rep_we_g_pre));

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
                rep_we_g, saved_segov_din_g, SAVED_SEGMENT_OVERRIDE_pre)
    bufferH16$ buf_saved_segov (.out(SAVED_SEGMENT_OVERRIDE), .in(SAVED_SEGMENT_OVERRIDE_pre));

    wire [31:0] saved_rep_eip_din;
    `MUX_2(u_saved_rep_eip_mux, 32, saved_rep_eip_din, 32'b0, EIP, rep_capture)
    wire [31:0] saved_rep_eip_din_g;
    `MUX_2(u_saved_rep_eip_din_g, 32, saved_rep_eip_din_g, saved_rep_eip_din, 32'b0, sync_clear_flush)
    `REG_RST_WE(u_saved_rep_eip, 32, clk, rst,
                rep_we_g, saved_rep_eip_din_g, SAVED_REP_EIP_pre)
    bufferH16$ buf_saved_rep_eip00 (.out(SAVED_REP_EIP[ 0]), .in(SAVED_REP_EIP_pre[ 0]));
    bufferH16$ buf_saved_rep_eip01 (.out(SAVED_REP_EIP[ 1]), .in(SAVED_REP_EIP_pre[ 1]));
    bufferH16$ buf_saved_rep_eip02 (.out(SAVED_REP_EIP[ 2]), .in(SAVED_REP_EIP_pre[ 2]));
    bufferH16$ buf_saved_rep_eip03 (.out(SAVED_REP_EIP[ 3]), .in(SAVED_REP_EIP_pre[ 3]));
    bufferH16$ buf_saved_rep_eip04 (.out(SAVED_REP_EIP[ 4]), .in(SAVED_REP_EIP_pre[ 4]));
    bufferH16$ buf_saved_rep_eip05 (.out(SAVED_REP_EIP[ 5]), .in(SAVED_REP_EIP_pre[ 5]));
    bufferH16$ buf_saved_rep_eip06 (.out(SAVED_REP_EIP[ 6]), .in(SAVED_REP_EIP_pre[ 6]));
    bufferH16$ buf_saved_rep_eip07 (.out(SAVED_REP_EIP[ 7]), .in(SAVED_REP_EIP_pre[ 7]));
    bufferH16$ buf_saved_rep_eip08 (.out(SAVED_REP_EIP[ 8]), .in(SAVED_REP_EIP_pre[ 8]));
    bufferH16$ buf_saved_rep_eip09 (.out(SAVED_REP_EIP[ 9]), .in(SAVED_REP_EIP_pre[ 9]));
    bufferH16$ buf_saved_rep_eip10 (.out(SAVED_REP_EIP[10]), .in(SAVED_REP_EIP_pre[10]));
    bufferH16$ buf_saved_rep_eip11 (.out(SAVED_REP_EIP[11]), .in(SAVED_REP_EIP_pre[11]));
    bufferH16$ buf_saved_rep_eip12 (.out(SAVED_REP_EIP[12]), .in(SAVED_REP_EIP_pre[12]));
    bufferH16$ buf_saved_rep_eip13 (.out(SAVED_REP_EIP[13]), .in(SAVED_REP_EIP_pre[13]));
    bufferH16$ buf_saved_rep_eip14 (.out(SAVED_REP_EIP[14]), .in(SAVED_REP_EIP_pre[14]));
    bufferH16$ buf_saved_rep_eip15 (.out(SAVED_REP_EIP[15]), .in(SAVED_REP_EIP_pre[15]));
    bufferH16$ buf_saved_rep_eip16 (.out(SAVED_REP_EIP[16]), .in(SAVED_REP_EIP_pre[16]));
    bufferH16$ buf_saved_rep_eip17 (.out(SAVED_REP_EIP[17]), .in(SAVED_REP_EIP_pre[17]));
    bufferH16$ buf_saved_rep_eip18 (.out(SAVED_REP_EIP[18]), .in(SAVED_REP_EIP_pre[18]));
    bufferH16$ buf_saved_rep_eip19 (.out(SAVED_REP_EIP[19]), .in(SAVED_REP_EIP_pre[19]));
    bufferH16$ buf_saved_rep_eip20 (.out(SAVED_REP_EIP[20]), .in(SAVED_REP_EIP_pre[20]));
    bufferH16$ buf_saved_rep_eip21 (.out(SAVED_REP_EIP[21]), .in(SAVED_REP_EIP_pre[21]));
    bufferH16$ buf_saved_rep_eip22 (.out(SAVED_REP_EIP[22]), .in(SAVED_REP_EIP_pre[22]));
    bufferH16$ buf_saved_rep_eip23 (.out(SAVED_REP_EIP[23]), .in(SAVED_REP_EIP_pre[23]));
    bufferH16$ buf_saved_rep_eip24 (.out(SAVED_REP_EIP[24]), .in(SAVED_REP_EIP_pre[24]));
    bufferH16$ buf_saved_rep_eip25 (.out(SAVED_REP_EIP[25]), .in(SAVED_REP_EIP_pre[25]));
    bufferH16$ buf_saved_rep_eip26 (.out(SAVED_REP_EIP[26]), .in(SAVED_REP_EIP_pre[26]));
    bufferH16$ buf_saved_rep_eip27 (.out(SAVED_REP_EIP[27]), .in(SAVED_REP_EIP_pre[27]));
    bufferH16$ buf_saved_rep_eip28 (.out(SAVED_REP_EIP[28]), .in(SAVED_REP_EIP_pre[28]));
    bufferH16$ buf_saved_rep_eip29 (.out(SAVED_REP_EIP[29]), .in(SAVED_REP_EIP_pre[29]));
    bufferH16$ buf_saved_rep_eip30 (.out(SAVED_REP_EIP[30]), .in(SAVED_REP_EIP_pre[30]));
    bufferH16$ buf_saved_rep_eip31 (.out(SAVED_REP_EIP[31]), .in(SAVED_REP_EIP_pre[31]));

    wire [1:0] saved_ds_din;
    `MUX_2(u_saved_ds_mux, 2, saved_ds_din, 2'b0, decode_cs_DATA_SIZE, rep_capture)
    wire [1:0] saved_ds_din_g;
    `MUX_2(u_saved_ds_din_g, 2, saved_ds_din_g, saved_ds_din, 2'b0, sync_clear_flush)
    `REG_RST_WE(u_saved_ds, 2, clk, rst,
                rep_we_g, saved_ds_din_g, SAVED_DATASIZE_pre)
    bufferH16$ buf_saved_ds0 (.out(SAVED_DATASIZE[0]), .in(SAVED_DATASIZE_pre[0]));
    bufferH16$ buf_saved_ds1 (.out(SAVED_DATASIZE[1]), .in(SAVED_DATASIZE_pre[1]));

    // ---- EIP / PrevEIP / PrevLength ----
    //   reset on rst | exp_pipe_clear (NOT flush -- flush feeds br_target).
    //   PrevEIP and PrevLength always update each cycle (we=1).
    //   EIP next-state priority:
    //     br_res.valid & flush  -> br_target
    //     idm-slot match & fwd  -> btb_target
    //     fwd & !HALT & !REP    -> NEIP
    //     else                  -> hold (self)

    wire cond3, cond2, cond1, cond0;
    assign cond3 = fetch_outs_exp_pipe_clear_buf;
    `AND_2(u_cond2, 1, cond2, exe_outs_br_res_valid, flush)
    assign cond1 = predicted_taken;     //minus decode forward, will have to get gated at end
    `NOR_2(u_cond0, 1, cond0, HALT_REG, REP_LATCH)

    wire penc_valid;
    wire [2:0] penc_out, penc_out_pre;
    pencoder8_3v$ eip_penc (1'b0, {4'b0, cond3, cond2, cond1, cond0}, penc_out_pre, penc_valid);
    bufferH64$ buf_penc_out0 (.out(penc_out[0]), .in(penc_out_pre[0]));
    bufferH64$ buf_penc_out1 (.out(penc_out[1]), .in(penc_out_pre[1]));
    bufferH64$ buf_penc_out2 (.out(penc_out[2]), .in(penc_out_pre[2]));
    wire [31:0] eip_next;
    `MUX_4(u_eip_next, 32, eip_next,
            NEIP, current_idm_slots_br_btb_target,
            exe_outs_br_res_br_target, 32'b0, penc_out[1:0])

    // we paths precomputed for decode_forward = 0 / 1, muxed at the end.
    //   df=0: we_i = {00->0, 01->0, 10->1, 11->1}[penc_out]
    //   df=1: we_i = {00->1, 01->1, 10->1, 11->1} = 1
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
    `MUX_2(u_prev_eip_din_g, 32, prev_eip_din_g, EIP, 32'b0, fetch_outs_exp_pipe_clear_buf)
    `REG_RST_WE(u_prev_eip, 32, clk, rst, 1'b1, prev_eip_din_g, PrevEIP)

    wire [3:0] prev_len_din_g;
    `MUX_2(u_prev_len_din_g, 4, prev_len_din_g, inst_length, 4'b0, fetch_outs_exp_pipe_clear_buf)
    `REG_RST_WE(u_prev_len, 4, clk, rst, 1'b1, prev_len_din_g, PrevLength)

    // ---- HALT_REG ----
    //   write iff (!HALT_REG && !invalid_inst); din = HALT
    //   reset on rst | exp_pipe_clear | flush
    wire halt_we;
    `NOR_2(u_halt_we, 1, halt_we, HALT_REG, invalid_inst)
    wire halt_we_g, halt_din_g;
    `OR_2(u_halt_we_g, 1, halt_we_g, halt_we, sync_clear_flush)
    `MUX_2(u_halt_din_g, 1, halt_din_g, decode_cs_HALT, 1'b0, sync_clear_flush)
    `REG_RST_WE(u_halt_reg, 1, clk, rst, halt_we_g, halt_din_g, HALT_REG)

    // ---- REP_CMP_LATCH ({REP_CMP, clear_rep}) ----
    // wire repcmp_we  = decode_cs_REP_CMP || clear_rep;
    // wire repcmp_din = decode_cs_REP_CMP && !clear_rep;
    wire repcmp_we, rep_cmp_n, repcmp_din;
    `OR_2(u_repcmp_we,    1, repcmp_we,  decode_cs_REP_CMP, clear_rep)
    `INV_N(u_rep_cmp_inv, 1, decode_cs_REP_CMP, rep_cmp_n)
    `NOR_2(u_repcmp_din,  1, repcmp_din, rep_cmp_n, clear_rep)
    wire repcmp_we_g, repcmp_din_g;
    `OR_2(u_repcmp_we_g,  1, repcmp_we_g,  repcmp_we, sync_clear_flush)
    `MUX_2(u_repcmp_din_g, 1, repcmp_din_g, repcmp_din, 1'b0, sync_clear_flush)
    `REG_RST_WE(u_rep_cmp, 1, clk, rst,
                repcmp_we_g, repcmp_din_g, REP_CMP_LATCH_pre)
    bufferH16$ buf_rep_cmp_latch (.out(REP_CMP_LATCH), .in(REP_CMP_LATCH_pre));

    // ---- REP_MOV_LATCH ({REP & !REP_CMP, clear_rep}) ----
    // mov_cond = REP & !REP_CMP = NOR(!REP, REP_CMP) -- reuses rep_n from above
    // wire mov_cond   = decode_cs_REP && !decode_cs_REP_CMP;
    // wire repmov_we  = mov_cond || clear_rep;
    // wire repmov_din = mov_cond && !clear_rep;
    wire mov_cond, repmov_we, mov_cond_n, repmov_din;
    `NOR_2(u_mov_cond,     1, mov_cond,   rep_n, decode_cs_REP_CMP)
    `OR_2(u_repmov_we,     1, repmov_we,  mov_cond, clear_rep)
    `INV_N(u_mov_cond_inv, 1, mov_cond,   mov_cond_n)
    `NOR_2(u_repmov_din,   1, repmov_din, mov_cond_n, clear_rep)
    wire repmov_we_g, repmov_din_g;
    `OR_2(u_repmov_we_g,   1, repmov_we_g,  repmov_we, sync_clear_flush)
    `MUX_2(u_repmov_din_g, 1, repmov_din_g, repmov_din, 1'b0, sync_clear_flush)
    `REG_RST_WE(u_rep_mov, 1, clk, rst,
                repmov_we_g, repmov_din_g, REP_MOV_LATCH_pre)
    bufferH16$ buf_rep_mov_latch (.out(REP_MOV_LATCH), .in(REP_MOV_LATCH_pre));

    // ---- DC_SAVED_EIP / DECODE_SAVED_EIP ----
    //   reset on rst only; write only on exp_pipe_clear.
    `REG_RST_WE(u_dc_saved_eip,     32, clk, rst,
                fetch_outs_exp_pipe_clear_buf, dc_outs_dc_eip, DC_SAVED_EIP)
    `REG_RST_WE(u_decode_saved_eip, 32, clk, rst,
                fetch_outs_exp_pipe_clear_buf, EIP,              DECODE_SAVED_EIP)

    // EXCEPTION_EIP: sel = !exp_mode_jk[1] | int_mode_jk = NAND(exp_mode_jk[1], !int_mode_jk)
    // assign EXCEPTION_EIP = (!fetch_outs_i.exp_mode_jk[1] || fetch_outs_i.int_mode_jk) ? DECODE_SAVED_EIP : DC_SAVED_EIP;
    wire int_mode_jk_n, exc_eip_sel, exc_eip_sel_pre;
    wire [31:0] EXCEPTION_EIP;
    `INV_N(u_int_mode_jk_inv,  1, fetch_outs_int_mode_jk, int_mode_jk_n)
    `NAND_2(u_exc_eip_sel, 1, exc_eip_sel_pre, fetch_outs_exp_mode_jk[1], int_mode_jk_n)
    bufferH64$ buf_exc_eip_sel (.out(exc_eip_sel), .in(exc_eip_sel_pre));
    `MUX_2(u_exception_eip, 32, EXCEPTION_EIP, DC_SAVED_EIP, DECODE_SAVED_EIP, exc_eip_sel)

    // bool going_to_halt; assign going_to_halt = (HALT_REG || decode_cs_HALT);
    // bool going_to_rep;  assign going_to_rep  = (REP_LATCH || decode_cs_REP);
    wire going_to_halt, going_to_rep;
    `OR_2(u_going_to_halt, 1, going_to_halt, HALT_REG, decode_cs_HALT)
    `OR_2(u_going_to_rep,  1, going_to_rep,  REP_LATCH, decode_cs_REP)

    // valid = next_rr_valid & !going_to_halt & !going_to_rep & !exp_pipe_clear
    //       = next_rr_valid & NOR3(going_to_halt, going_to_rep, exp_pipe_clear)
    wire valid_block, rr_latch_valid;
    `NOR_3(u_valid_block,    1, valid_block,    going_to_halt, going_to_rep, fetch_outs_exp_pipe_clear_buf)
    `AND_2(u_rr_latch_valid, 1, rr_latch_valid, next_rr_valid, valid_block)

    // latch EIP: (exp_mode_jk[0] | int_mode_jk) ? EXCEPTION_EIP : EIP
    wire latch_eip_sel, latch_eip_sel_pre;
    wire [31:0] latch_eip;
    `OR_2(u_latch_eip_sel, 1, latch_eip_sel_pre, fetch_outs_exp_mode_jk[0], fetch_outs_int_mode_jk)
    bufferH64$ buf_latch_eip_sel (.out(latch_eip_sel), .in(latch_eip_sel_pre));
    `MUX_2(u_latch_eip, 32, latch_eip, EIP, EXCEPTION_EIP, latch_eip_sel)

    // sib/disp gating: (MODRM_NEEDED) ? x : 0
    wire sib_needed_g, disp_needed_g, disp_size_g;
    `MUX_2(u_sib_needed_g,  1, sib_needed_g,  1'b0, sib_size,    rr_cs_MODRM_NEEDED)
    `MUX_2(u_disp_needed_g, 1, disp_needed_g, 1'b0, disp_needed, rr_cs_MODRM_NEEDED)
    `MUX_2(u_disp_size_g,   1, disp_size_g,   1'b0, disp_size,   rr_cs_MODRM_NEEDED)

    // ----- rr_latches_next.normal_latches (driven directly from source signals) -----
    assign rr_latches_next_normal_latches_valid                      = rr_latch_valid;

    assign rr_latches_next_normal_latches_cs_ST_SEL                  = rr_cs_ST_SEL;
    assign rr_latches_next_normal_latches_cs_MODRM_NEEDED            = rr_cs_MODRM_NEEDED;
    assign rr_latches_next_normal_latches_cs_RM_IS_DR                = rr_cs_RM_IS_DR;
    assign rr_latches_next_normal_latches_cs_SWITCH_LD_ADDY          = rr_cs_SWITCH_LD_ADDY;
    assign rr_latches_next_normal_latches_cs_LD_OP                   = rr_cs_LD_OP;
    assign rr_latches_next_normal_latches_cs_ST_OP                   = rr_cs_ST_OP;
    assign rr_latches_next_normal_latches_cs_dr_id                   = rr_cs_dr_id;
    assign rr_latches_next_normal_latches_cs_sr_id                   = rr_cs_sr_id;
    assign rr_latches_next_normal_latches_cs_dr_rd                   = rr_cs_dr_rd;
    assign rr_latches_next_normal_latches_cs_sr_rd                   = rr_cs_sr_rd;
    assign rr_latches_next_normal_latches_cs_eax_rd                  = rr_cs_eax_rd;
    assign rr_latches_next_normal_latches_cs_dr_wr                   = rr_cs_dr_wr;
    assign rr_latches_next_normal_latches_cs_sr_wr                   = rr_cs_sr_wr;
    assign rr_latches_next_normal_latches_cs_eax_wr                  = rr_cs_eax_wr;
    assign rr_latches_next_normal_latches_cs_MOVS_OP                 = rr_cs_MOVS_OP;
    assign rr_latches_next_normal_latches_cs_datasize                = rr_cs_datasize;
    assign rr_latches_next_normal_latches_cs_will_mod_zf             = rr_cs_will_mod_zf;
    assign rr_latches_next_normal_latches_cs_seg_1_valid             = rr_cs_seg_1_valid;
    assign rr_latches_next_normal_latches_cs_seg_0_id                = rr_cs_seg_0_id;
    assign rr_latches_next_normal_latches_cs_seg_1_id                = rr_cs_seg_1_id;
    assign rr_latches_next_normal_latches_cs_special_modrm_bs        = rr_cs_special_modrm_bs;
    assign rr_latches_next_normal_latches_cs_special_br              = rr_cs_special_br;

    assign rr_latches_next_normal_latches_dc_cs_LD_OP                = dc_cs_LD_OP;
    assign rr_latches_next_normal_latches_dc_cs_ST_OP                = dc_cs_ST_OP;
    assign rr_latches_next_normal_latches_dc_cs_dr_upper8            = dc_cs_dr_upper8;
    assign rr_latches_next_normal_latches_dc_cs_sr_upper8            = dc_cs_sr_upper8;
    assign rr_latches_next_normal_latches_dc_cs_datasize             = dc_cs_datasize;

    assign rr_latches_next_normal_latches_mem_cs_ST_OP               = mem_cs_ST_OP;
    assign rr_latches_next_normal_latches_mem_cs_LD_OP               = mem_cs_LD_OP;

    assign rr_latches_next_normal_latches_exe_cs_ST_OP               = exe_cs_ST_OP;
    assign rr_latches_next_normal_latches_exe_cs_OP_TYPE             = exe_cs_OP_TYPE[`EXE_OP_W-1:0];
    assign rr_latches_next_normal_latches_exe_cs_alu_inputA_sel      = exe_cs_alu_inputA_sel[`SRC_SEL_W-1:0];
    assign rr_latches_next_normal_latches_exe_cs_alu_inputB_sel      = exe_cs_alu_inputB_sel[`SRC_SEL_W-1:0];
    assign rr_latches_next_normal_latches_exe_cs_branch_target_sel   = exe_cs_branch_target_sel[`SRC_SEL_W-1:0];
    assign rr_latches_next_normal_latches_exe_cs_shift_by_one        = exe_cs_shift_by_one;
    assign rr_latches_next_normal_latches_exe_cs_br_ucond            = exe_cs_br_ucond;
    assign rr_latches_next_normal_latches_exe_cs_relative_branch     = exe_cs_relative_branch;
    assign rr_latches_next_normal_latches_exe_cs_special_br          = exe_cs_special_br;
    assign rr_latches_next_normal_latches_exe_cs_is_far              = exe_cs_is_far;
    assign rr_latches_next_normal_latches_exe_cs_is_call             = exe_cs_is_call;
    assign rr_latches_next_normal_latches_exe_cs_second_flag_needed  = exe_cs_second_flag_needed;
    assign rr_latches_next_normal_latches_exe_cs_rep_no_zf_update    = exe_cs_rep_no_zf_update;

    assign rr_latches_next_normal_latches_wb_cs_ST_OP                = wb_cs_ST_OP;
    assign rr_latches_next_normal_latches_wb_cs_WB_DR                = wb_cs_WB_DR;
    assign rr_latches_next_normal_latches_wb_cs_WB_SR                = wb_cs_WB_SR;
    assign rr_latches_next_normal_latches_wb_cs_WB_EAX               = wb_cs_WB_EAX;

    assign rr_latches_next_normal_latches_br_info_valid              = branch_info_valid;
    assign rr_latches_next_normal_latches_br_info_br_eip             = branch_info_br_eip;
    assign rr_latches_next_normal_latches_br_info_br_xcl             = branch_info_br_xcl;
    assign rr_latches_next_normal_latches_br_info_br_pred_taken      = branch_info_br_pred_taken;
    assign rr_latches_next_normal_latches_br_info_speculative_target = branch_info_speculative_target;

    assign rr_latches_next_normal_latches_NEIP                       = NEIP;
    assign rr_latches_next_normal_latches_EIP                        = latch_eip;
    assign rr_latches_next_normal_latches_EAX                        = rr_outs_eax;
    assign rr_latches_next_normal_latches_imm64                      = imm64;

    assign rr_latches_next_normal_latches_sib_idx_id                 = sibidx;
    assign rr_latches_next_normal_latches_sib_base_id                = sibbase;
    assign rr_latches_next_normal_latches_sib_needed                 = sib_needed_g;
    assign rr_latches_next_normal_latches_sib_scale                  = sibscale;
    assign rr_latches_next_normal_latches_disp_needed                = disp_needed_g;
    assign rr_latches_next_normal_latches_disp_size                  = disp_size_g;
    assign rr_latches_next_normal_latches_displacement               = displacement;

    // ----- outs_o (decode_outputs_t) flattened -----
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



    // rep_controller piece_of_shit_rep_controller (
    //     .clk(clk), .rst(rst), .rep_latch(REP_LATCH),
    //     .mov_inst(REP_MOV_LATCH), .cmp_inst(REP_CMP_LATCH), .clear_zf(exe_outs_i.clr_ZF_sb),
    //     .external_set_zf(external_set_zf), .ecx(rr_outs_i.ecx), .ecx_sb(rr_outs_i.ecx_sb),
    //     .zf_flag(exe_outs_i.ZF), .stall(!decode_forward), .flush(flush), .exp_pipe_clear(fetch_outs_i.exp_pipe_clear),
    //     .rep_latches(rep_latch_holder), .clear_rep(clear_rep), .saved_segment0(SAVED_SEGMENT0), 
    //     .saved_segment_override(SAVED_SEGMENT_OVERRIDE), .saved_rep_eip(SAVED_REP_EIP),
    //     .saved_datasize(SAVED_DATASIZE)
    // );

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
        .ecx_sb                                 (rr_outs_ecx_sb_buf),
        .zf_flag                                (exe_outs_ZF),
        .stall                                  (not_decode_forward),
        .flush                                  (flush),
        .exp_pipe_clear                         (fetch_outs_exp_pipe_clear_buf),
        .saved_segment0                         (SAVED_SEGMENT0),
        .saved_segment_override                 (SAVED_SEGMENT_OVERRIDE),
        .saved_rep_eip                          (SAVED_REP_EIP),
        .saved_datasize                         (SAVED_DATASIZE),
        // --- rep_latches outputs wired directly to module-level rep_latches output wires ---
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
