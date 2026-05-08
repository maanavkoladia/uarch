import reg_ids_pkg::*;

module Decode (
    input wire clk,
    input wire rst,

    //for decoding instructions coming in from fetch
    input idm_outputs_t idm_outs_i,

    //for pipeclear when exp is about to be served and ROM loaded into IDM
    input fetch_outputs_t fetch_outs_i,

    //exc/sb and ZF/sb and valid , and needed for stage latch valid signal
    input rr_outputs_t rr_outs_i,

    //only used for valid logic
    input dc_outputs_t dc_outs_i,

    //only used for valid logic
    input mem_outputs_t mem_outs_i,

    //these are for valid bit shit and exe br res for eip changes and flushing
    input exe_outputs_t exe_outs_i,

    //only used for valid logic
    input wb_outputs_t wb_outs_i,

    //these are the next rr latches harish
    output rr_latches_t rr_latches_next,

    //actual stage bundled outputs
    output decode_outputs_t outs_o
);

    wire seg_0_overriden_final;

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
    decode_cs_t temp_decode_cs;
    rr_cs_t temp_rr_cs;
    dc_cs_t temp_dc_cs;
    mem_cs_t temp_mem_cs;
    exe_cs_t temp_exe_cs;
    wb_cs_t temp_wb_cs;
    wire decode_gp;
    rr_latches_general_t temp_rr_latch;
    wire flush; //cpaddyx , i did not put ts here, whats this for
    wire REP_LATCH, REP_CMP_LATCH, REP_MOV_LATCH, HALT_REG;
    wire rr_latch_we_o;

    wire [31:0] DC_SAVED_EIP;
    wire [31:0] DECODE_SAVED_EIP;

    wire [`REG_ID_W-1:0] SAVED_SEGMENT0;
    wire SAVED_SEGMENT_OVERRIDE;
    wire [31:0] SAVED_REP_EIP;
    wire [1:0] SAVED_DATASIZE;


    wire [`REG_ID_W-1:0] segment0;
    wire seg_override;
    wire next_rr_valid;

    assign flush = exe_outs_i.br_res_out.flush;

    wire decode_forward;
    `AND_2 (decode_forward_u, 1, decode_forward, rr_latch_we_o, next_rr_valid)

    wire [511:0] flattened_queue;
    genvar i;
    generate
        for (i = 0; i < 64; i++) begin : flat_assign
            assign flattened_queue[i*8 +: 8] = idm_outs_i.idm_slots[i/16].data[i%16];
        end
    endgenerate

    wire modrm_seg_override;

    wire sib_segment_override;

    wire [`REG_ID_W-1:0] rr_cs_seg_0_id_pre;
    assign temp_rr_cs.seg_0_id = ((sib_size && sib_segment_override) || modrm_seg_override) ? `SS : rr_cs_seg_0_id_pre;

    predecode inst_processing(
        .clk(clk), .rst(rst), .queue(flattened_queue),
        .queue_valid({idm_outs_i.idm_slots[3].valid, idm_outs_i.idm_slots[2].valid,
                    idm_outs_i.idm_slots[1].valid, idm_outs_i.idm_slots[0].valid}),
        .EIP(EIP), .NEIP(NEIP), .inst_length(inst_length), .sib_byte(sib_byte), .sib_size(sib_size),
        .opcode_byte(opcode_byte), .modrm_byte(modrm_byte), .disp(displacement), .disp_size(disp_size),
        .disp_needed(disp_needed), .imm64(imm64), .total_pf_vector_o(total_pf_vector), .invalid_inst(invalid_inst),

        .seg_override(seg_override),
        .seg0(segment0),

        .decode_cs_REP(temp_decode_cs.REP),
        .decode_cs_REP_CMP(temp_decode_cs.REP_CMP),
        .decode_cs_HALT(temp_decode_cs.HALT),
        .decode_cs_MODRM_NEEDED(temp_decode_cs.MODRM_NEEDED),
        .decode_cs_RM_IS_DR(temp_decode_cs.RM_IS_DR),
        .decode_cs_REG_IS_DR(temp_decode_cs.REG_IS_DR),
        .decode_cs_REG_IS_SEGMENT(temp_decode_cs.REG_IS_SEGMENT),
        .decode_cs_HARDCODED_DR_HIGH8(temp_decode_cs.HARDCODED_DR_HIGH8),
        .decode_cs_MODRM_BUT_NO_SR(temp_decode_cs.MODRM_BUT_NO_SR),
        .decode_cs_HARDCODED_DR(temp_decode_cs.HARDCODED_DR),
        .decode_cs_HARDCODED_DR_ID(temp_decode_cs.HARDCODED_DR_ID),
        .decode_cs_HARDCODED_SR(temp_decode_cs.HARDCODED_SR),
        .decode_cs_HARDCODED_SR_ID(temp_decode_cs.HARDCODED_SR_ID),
        .decode_cs_HARDCODED_DR_RD(temp_decode_cs.HARDCODED_DR_RD),
        .decode_cs_HARDCODED_DR_WR(temp_decode_cs.HARDCODED_DR_WR),
        .decode_cs_HARDCODED_SR_RD(temp_decode_cs.HARDCODED_SR_RD),
        .decode_cs_HARDCODED_SR_WR(temp_decode_cs.HARDCODED_SR_WR),
        .decode_cs_HARDCODED_LD_OP(temp_decode_cs.HARDCODED_LD_OP),
        .decode_cs_HARDCODED_ST_OP(temp_decode_cs.HARDCODED_ST_OP),
        .decode_cs_LD_OP_CANCEL(temp_decode_cs.LD_OP_CANCEL),
        .decode_cs_ST_OP_CANCEL(temp_decode_cs.ST_OP_CANCEL),
        .decode_cs_OP_IN_MODRM(temp_decode_cs.OP_IN_MODRM),
        .decode_cs_DATA_SIZE(temp_decode_cs.DATA_SIZE),

        .rr_cs_ST_SEL(temp_rr_cs.ST_SEL),
        .rr_cs_MODRM_NEEDED(temp_rr_cs.MODRM_NEEDED),
        .rr_cs_RM_IS_DR(temp_rr_cs.RM_IS_DR),
        .rr_cs_SWITCH_LD_ADDY(temp_rr_cs.SWITCH_LD_ADDY),
        .rr_cs_LD_OP(temp_rr_cs.LD_OP),
        .rr_cs_ST_OP(temp_rr_cs.ST_OP),
        .rr_cs_dr_id(temp_rr_cs.dr_id),
        .rr_cs_sr_id(temp_rr_cs.sr_id),
        .rr_cs_dr_rd(temp_rr_cs.dr_rd),
        .rr_cs_sr_rd(temp_rr_cs.sr_rd),
        .rr_cs_eax_rd(temp_rr_cs.eax_rd),
        .rr_cs_dr_wr(temp_rr_cs.dr_wr),
        .rr_cs_sr_wr(temp_rr_cs.sr_wr),
        .rr_cs_eax_wr(temp_rr_cs.eax_wr),
        .rr_cs_MOVS_OP(temp_rr_cs.MOVS_OP),
        .rr_cs_datasize(temp_rr_cs.datasize),
        .rr_cs_will_mod_zf(temp_rr_cs.will_mod_zf),
        .rr_cs_seg_1_valid(temp_rr_cs.seg_1_valid),
        .rr_cs_seg_0_id(rr_cs_seg_0_id_pre),
        .rr_cs_seg_1_id(temp_rr_cs.seg_1_id),
        .rr_cs_special_modrm_bs(temp_rr_cs.special_modrm_bs),
        .rr_cs_special_br(temp_rr_cs.special_br),

        .dc_cs_LD_OP(temp_dc_cs.LD_OP),
        .dc_cs_ST_OP(temp_dc_cs.ST_OP),
        .dc_cs_dr_upper8(temp_dc_cs.dr_upper8),
        .dc_cs_sr_upper8(temp_dc_cs.sr_upper8),
        .dc_cs_datasize(temp_dc_cs.datasize),

        .mem_cs_ST_OP(temp_mem_cs.ST_OP),
        .mem_cs_LD_OP(temp_mem_cs.LD_OP),

        .exe_cs_ST_OP(temp_exe_cs.ST_OP),
        .exe_cs_OP_TYPE(temp_exe_cs.OP_TYPE[`EXE_OP_W-1:0]),
        .exe_cs_alu_inputA_sel(temp_exe_cs.alu_inputA_sel[`SRC_SEL_W-1:0]),
        .exe_cs_alu_inputB_sel(temp_exe_cs.alu_inputB_sel[`SRC_SEL_W-1:0]),
        .exe_cs_branch_target_sel(temp_exe_cs.branch_target_sel[`SRC_SEL_W-1:0]),
        .exe_cs_shift_by_one(temp_exe_cs.shift_by_one),
        .exe_cs_br_ucond(temp_exe_cs.br_ucond),
        .exe_cs_relative_branch(temp_exe_cs.relative_branch),
        .exe_cs_special_br(temp_exe_cs.special_br),
        .exe_cs_is_far(temp_exe_cs.is_far),
        .exe_cs_is_call(temp_exe_cs.is_call),
        .exe_cs_second_flag_needed(temp_exe_cs.second_flag_needed),
        .exe_cs_rep_no_zf_update(temp_exe_cs.rep_no_zf_update),

        .wb_cs_ST_OP(temp_wb_cs.ST_OP),
        .wb_cs_WB_DR(temp_wb_cs.WB_DR),
        .wb_cs_WB_SR(temp_wb_cs.WB_SR),
        .wb_cs_WB_EAX(temp_wb_cs.WB_EAX),

        .modrm_seg_override(modrm_seg_override)
    );

    decode_gp_gen gp_gen_decode(
        .prev_eip(PrevEIP), .prev_length(PrevLength),
        .segLimit(rr_outs_i.codeSeg_limit), .gp_fault_o(decode_gp)
    );

    wire predicted_taken;
    wire [31:0] predicted_target;    
    wire branch_info_valid;
    wire [31:0] branch_info_br_eip;
    wire branch_info_br_xcl;
    wire branch_info_br_pred_taken;
    wire [31:0] branch_info_speculative_target;
    wire br_eip_eq_EIP;
    wire branch_present;

    br_info_t br_info_for_latches;
    assign br_info_for_latches = '{
        valid : branch_info_valid,
        br_eip : branch_info_br_eip,
        br_xcl : branch_info_br_xcl,
        br_pred_taken : branch_info_br_pred_taken,
        speculative_target : branch_info_speculative_target
    };

    `CMP_N(br_eip_cmp, 32, br_eip_eq_EIP, idm_outs_i.idm_slots[EIP[5:4]].br_eip, EIP)
    `AND_3(predicted_taken_gate, 1, predicted_taken, idm_outs_i.idm_slots[EIP[5:4]].valid, idm_outs_i.idm_slots[EIP[5:4]].br_valid, br_eip_eq_EIP)
    `MUX_2(predicted_target_mux, 32, predicted_target, 32'b0, idm_outs_i.idm_slots[EIP[5:4]].br_btb_target, predicted_taken)
    `OR_3(branch_present_gate,    1, branch_present,   temp_exe_cs.br_ucond, temp_exe_cs.relative_branch, temp_exe_cs.special_br)

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
        .sib_base_id(sibbase), .sib_scale(sibscale), .sib_segment_override(sib_segment_override)
    );

    rr_latches_general_t rep_latch_holder;
    wire clear_rep;

    wire external_set_zf;
    `AND_2(external_set_zf_gate, 1, external_set_zf, temp_rr_cs.will_mod_zf, decode_forward)

    wire not_decode_forward;
    `INV_N(not_decode_forward_inv, 1, decode_forward, not_decode_forward)

    wire invalid_instruction_not;
    `INV_N(invalid_instruction_not_u, 1, invalid_inst, invalid_instruction_not)
  
    rr_valid_logic decode_2_RR_valid_logic(
        .RR_we_o(rr_latch_we_o),
        .N_RR_V_o(next_rr_valid),
        .DECODE_V_i(invalid_instruction_not),
        .RR_stall_i(rr_outs_i.stall),
        .RR_V_i(rr_outs_i.valid),
        .DC_stall_i(dc_outs_i.stall),
        .DC_V_i(dc_outs_i.valid),
        .MEM_V_i(mem_outs_i.valid),
        .MEM_stall_i(mem_outs_i.stall),
        .EXE_V_i(exe_outs_i.valid),
        .WB_stall_i(wb_outs_i.wb_stall)
    );

    // seg_override: any segment prefix bit [9:4] is active
    `OR_6(seg_override_gate, 1, seg_override,
        total_pf_vector[9], total_pf_vector[8], total_pf_vector[7],
        total_pf_vector[6], total_pf_vector[5], total_pf_vector[4])

    // segment0: bits [9:4] are one-hot, so encode directly to 3-bit binary select
    // sel[2]=[9]|[8]  sel[1]=[9]|[6]|[5]  sel[0]=[8]|[6]|[4]
    // [7] encodes to 000 (same as default DS), so no special case needed
    // sel: 000->DS  001->GS  010->FS  011->ES  101->SS  110->CS
    wire seg_sel_2, seg_sel_1, seg_sel_0;
    `OR_2(seg_sel_2_gate, 1, seg_sel_2, total_pf_vector[9], total_pf_vector[8])
    `OR_3(seg_sel_1_gate, 1, seg_sel_1, total_pf_vector[9], total_pf_vector[6], total_pf_vector[5])
    `OR_3(seg_sel_0_gate, 1, seg_sel_0, total_pf_vector[8], total_pf_vector[6], total_pf_vector[4])
    `MUX_8(segment0_mux, `REG_ID_W, segment0,
        `DS, `GS, `FS, `ES, `DS, `SS, `CS, `DS,
        {seg_sel_2, seg_sel_1, seg_sel_0})


    // // -----------------------------------------------------------------
    // // Structural register block (replaces the two always_ff blocks).
    // // -----------------------------------------------------------------
    // Registers have ASYNC reset, so only the true async `rst` (active-low)
    // feeds the rst port. exp_pipe_clear and flush are applied synchronously
    // via we/din overrides: when sync_clear_* is asserted we force we=1 and
    // mux din to 0, which matches the synchronous clears in Decode.sv.
    wire sync_clear_flush;
    `OR_2(u_sync_clear_flush, 1, sync_clear_flush, fetch_outs_i.exp_pipe_clear, flush)

    // ---- REP_LATCH and SAVED_* (gated by {REP, clear_rep}) ----
    //   00: hold; 01: 0; 10: capture; 11: 0
    //   => we = REP | clear_rep, set = REP & !clear_rep = NOR(!REP, clear_rep)
    wire rep_we;
    wire rep_we_with_decode_forward;
    assign rep_we_with_decode_forward = temp_decode_cs.REP && decode_forward;
    `OR_2(u_rep_we, 1, rep_we, rep_we_with_decode_forward, clear_rep)

    wire rep_n;
    wire rep_capture;
    `INV_N(u_rep_inv, 1, temp_decode_cs.REP, rep_n)
    `NOR_2(u_rep_capture, 1, rep_capture, rep_n, clear_rep)

    // Shared sync-clear gating: rep_we_g forces a write on sync_clear_flush so
    // every {REP_LATCH, SAVED_*} register can be muxed to 0 the same cycle.
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
    `MUX_2(u_saved_ds_mux, 2, saved_ds_din, 2'b0, temp_decode_cs.DATA_SIZE, rep_capture)
    wire [1:0] saved_ds_din_g;
    `MUX_2(u_saved_ds_din_g, 2, saved_ds_din_g, saved_ds_din, 2'b0, sync_clear_flush)
    `REG_RST_WE(u_saved_ds, 2, clk, rst,
                rep_we_g, saved_ds_din_g, SAVED_DATASIZE)

    // ---- EIP / PrevEIP / PrevLength ----
    //   reset on rst | exp_pipe_clear (NOT flush -- flush feeds br_target).
    //   PrevEIP and PrevLength always update each cycle (we=1).
    //   EIP next-state priority:
    //     br_res.valid & flush  -> br_target
    //     idm-slot match & fwd  -> btb_target
    //     fwd & !HALT & !REP    -> NEIP
    //     else                  -> hold (self)

    wire cond3, cond2, cond1, cond0;
    assign cond3 = fetch_outs_i.exp_pipe_clear;
    `AND_2(u_cond2, 1, cond2, exe_outs_i.br_res_out.valid, flush)
    assign cond1 = predicted_taken;     //minus decode forward, will have to get gated at end
    `NOR_2(u_cond0, 1, cond0, HALT_REG, REP_LATCH)

    wire penc_valid;
    wire [2:0] penc_out;
    pencoder8_3v$ eip_penc (1'b0, {4'b0, cond3, cond2, cond1, cond0}, penc_out, penc_valid);
    wire [31:0] eip_next;
    `MUX_4(u_eip_next, 32, eip_next,
            NEIP, idm_outs_i.idm_slots[EIP[5:4]].br_btb_target,
            exe_outs_i.br_res_out.br_target, 32'b0, penc_out[1:0])

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
    `MUX_2(u_prev_eip_din_g, 32, prev_eip_din_g, EIP, 32'b0, fetch_outs_i.exp_pipe_clear)
    `REG_RST_WE(u_prev_eip, 32, clk, rst, 1'b1, prev_eip_din_g, PrevEIP)

    wire [3:0] prev_len_din_g;
    `MUX_2(u_prev_len_din_g, 4, prev_len_din_g, inst_length, 4'b0, fetch_outs_i.exp_pipe_clear)
    `REG_RST_WE(u_prev_len, 4, clk, rst, 1'b1, prev_len_din_g, PrevLength)

    // ---- HALT_REG ----
    //   write iff (!HALT_REG && !invalid_inst); din = HALT
    //   reset on rst | exp_pipe_clear | flush
    wire halt_we;
    `NOR_2(u_halt_we, 1, halt_we, HALT_REG, invalid_inst)
    wire halt_we_g, halt_din_g;
    `OR_2(u_halt_we_g, 1, halt_we_g, halt_we, sync_clear_flush)
    `MUX_2(u_halt_din_g, 1, halt_din_g, temp_decode_cs.HALT, 1'b0, sync_clear_flush)
    `REG_RST_WE(u_halt_reg, 1, clk, rst, halt_we_g, halt_din_g, HALT_REG)

    // ---- REP_CMP_LATCH ({REP_CMP, clear_rep}) ----
    // wire repcmp_we  = temp_decode_cs.REP_CMP || clear_rep;
    // wire repcmp_din = temp_decode_cs.REP_CMP && !clear_rep;
    wire repcmp_we, rep_cmp_n, repcmp_din;
    wire rep_cmp_with_decode_forward;
    assign rep_cmp_with_decode_forward = temp_decode_cs.REP_CMP && decode_forward;
    `OR_2(u_repcmp_we,    1, repcmp_we,  rep_cmp_with_decode_forward, clear_rep)
    `INV_N(u_rep_cmp_inv, 1, temp_decode_cs.REP_CMP, rep_cmp_n)
    `NOR_2(u_repcmp_din,  1, repcmp_din, rep_cmp_n, clear_rep)
    wire repcmp_we_g, repcmp_din_g;
    `OR_2(u_repcmp_we_g,  1, repcmp_we_g,  repcmp_we, sync_clear_flush)
    `MUX_2(u_repcmp_din_g, 1, repcmp_din_g, repcmp_din, 1'b0, sync_clear_flush)
    `REG_RST_WE(u_rep_cmp, 1, clk, rst,
                repcmp_we_g, repcmp_din_g, REP_CMP_LATCH)

    // ---- REP_MOV_LATCH ({REP & !REP_CMP, clear_rep}) ----
    // mov_cond = REP & !REP_CMP = NOR(!REP, REP_CMP) -- reuses rep_n from above
    // wire mov_cond   = temp_decode_cs.REP && !temp_decode_cs.REP_CMP;
    // wire repmov_we  = (mov_cond && decode_forward) || clear_rep;
    // wire repmov_din = mov_cond && !clear_rep;
    wire mov_cond, repmov_we, mov_cond_n, repmov_din;
    wire mov_cond_with_decode_forward;
    `NOR_2(u_mov_cond,     1, mov_cond,   rep_n, temp_decode_cs.REP_CMP)
    assign mov_cond_with_decode_forward = mov_cond && decode_forward;
    `OR_2(u_repmov_we,     1, repmov_we,  mov_cond_with_decode_forward, clear_rep)
    `INV_N(u_mov_cond_inv, 1, mov_cond,   mov_cond_n)
    `NOR_2(u_repmov_din,   1, repmov_din, mov_cond_n, clear_rep)
    wire repmov_we_g, repmov_din_g;
    `OR_2(u_repmov_we_g,   1, repmov_we_g,  repmov_we, sync_clear_flush)
    `MUX_2(u_repmov_din_g, 1, repmov_din_g, repmov_din, 1'b0, sync_clear_flush)
    `REG_RST_WE(u_rep_mov, 1, clk, rst,
                repmov_we_g, repmov_din_g, REP_MOV_LATCH)

    // ---- DC_SAVED_EIP / DECODE_SAVED_EIP ----
    //   reset on rst only; write only on exp_pipe_clear.
    `REG_RST_WE(u_dc_saved_eip,     32, clk, rst,
                fetch_outs_i.exp_pipe_clear, dc_outs_i.dc_eip, DC_SAVED_EIP)
    `REG_RST_WE(u_decode_saved_eip, 32, clk, rst,
                fetch_outs_i.exp_pipe_clear, EIP,              DECODE_SAVED_EIP)

    // EXCEPTION_EIP: sel = !exp_mode_jk[1] | int_mode_jk = NAND(exp_mode_jk[1], !int_mode_jk)
    // assign EXCEPTION_EIP = (!fetch_outs_i.exp_mode_jk[1] || fetch_outs_i.int_mode_jk) ? DECODE_SAVED_EIP : DC_SAVED_EIP;
    wire int_mode_jk_n, exc_eip_sel;
    wire [31:0] EXCEPTION_EIP;
    `INV_N(u_int_mode_jk_inv,  1, fetch_outs_i.int_mode_jk, int_mode_jk_n)
    `NAND_2(u_exc_eip_sel, 1, exc_eip_sel, fetch_outs_i.exp_mode_jk[1], int_mode_jk_n)
    `MUX_2(u_exception_eip, 32, EXCEPTION_EIP, DC_SAVED_EIP, DECODE_SAVED_EIP, exc_eip_sel)

    // bool going_to_halt; assign going_to_halt = (HALT_REG || temp_decode_cs.HALT);
    // bool going_to_rep;  assign going_to_rep  = (REP_LATCH || temp_decode_cs.REP);
    wire going_to_halt, going_to_rep;
    `OR_2(u_going_to_halt, 1, going_to_halt, HALT_REG, temp_decode_cs.HALT)
    `OR_2(u_going_to_rep,  1, going_to_rep,  REP_LATCH, temp_decode_cs.REP)

    // valid = next_rr_valid & !going_to_halt & !going_to_rep & !exp_pipe_clear
    //       = next_rr_valid & NOR3(going_to_halt, going_to_rep, exp_pipe_clear)
    wire valid_block, rr_latch_valid;
    `NOR_3(u_valid_block,    1, valid_block,    going_to_halt, going_to_rep, fetch_outs_i.exp_pipe_clear)
    `AND_2(u_rr_latch_valid, 1, rr_latch_valid, next_rr_valid, valid_block)

    // latch EIP: (exp_mode_jk[0] | int_mode_jk) ? EXCEPTION_EIP : EIP
    wire latch_eip_sel;
    wire [31:0] latch_eip;
    `OR_2(u_latch_eip_sel, 1, latch_eip_sel, fetch_outs_i.exp_mode_jk[0], fetch_outs_i.int_mode_jk)
    `MUX_2(u_latch_eip, 32, latch_eip, EIP, EXCEPTION_EIP, latch_eip_sel)

    // sib/disp gating: (MODRM_NEEDED) ? x : 0
    wire sib_needed_g, disp_needed_g, disp_size_g;
    `MUX_2(u_sib_needed_g,  1, sib_needed_g,  1'b0, sib_size,    temp_rr_cs.MODRM_NEEDED)
    `MUX_2(u_disp_needed_g, 1, disp_needed_g, 1'b0, disp_needed, temp_rr_cs.MODRM_NEEDED)
    `MUX_2(u_disp_size_g,   1, disp_size_g,   1'b0, disp_size,   temp_rr_cs.MODRM_NEEDED)

    assign temp_rr_latch = '{
        valid           : rr_latch_valid,
        cs              : temp_rr_cs,

        dc_cs           : temp_dc_cs,
        mem_cs          : temp_mem_cs,
        exe_cs          : temp_exe_cs,
        wb_cs           : temp_wb_cs,

        br_info         : br_info_for_latches,
        NEIP            : NEIP,
        EIP             : latch_eip,
        EAX             : rr_outs_i.eax,

        imm64           : imm64,
        sib_idx_id      : sibidx,
        sib_base_id     : sibbase,
        sib_needed      : sib_needed_g,
        sib_scale       : sibscale,
        disp_needed     : disp_needed_g,
        disp_size       : disp_size_g,
        displacement    : displacement
    };

    assign rr_latches_next = '{
        normal_latches : temp_rr_latch,
        rep_latches : rep_latch_holder
    };

    wire decode_gp_out;
    `AND_2(decode_gp_u, 1, decode_gp_out, decode_gp, rr_outs_i.valid)
    assign outs_o = '{
        valid : invalid_instruction_not,
        stall : invalid_inst,
        eip : EIP,
        invalid_instruction : invalid_inst,
        decode_gp : decode_gp_out,
        rr_stage_latch_we : rr_latch_we_o,
        rep_latch : REP_LATCH,
        decode_forward : decode_forward
    };



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
        .clear_zf                               (exe_outs_i.clr_ZF_sb),
        .external_set_zf                        (external_set_zf),
        .ecx                                    (rr_outs_i.ecx),
        .ecx_sb                                 (rr_outs_i.ecx_sb),
        .zf_flag                                (exe_outs_i.ZF),
        .stall                                  (not_decode_forward),
        .flush                                  (flush),
        .exp_pipe_clear                         (fetch_outs_i.exp_pipe_clear),
        .saved_segment0                         (SAVED_SEGMENT0),
        .saved_segment_override                 (SAVED_SEGMENT_OVERRIDE),
        .saved_rep_eip                          (SAVED_REP_EIP),
        .saved_datasize                         (SAVED_DATASIZE),
        // --- rep_latches outputs (rr_latches_general_t unrolled) ---
        .rep_latches_valid                      (rep_latch_holder.valid),
        .rep_latches_cs_ST_SEL                  (rep_latch_holder.cs.ST_SEL),
        .rep_latches_cs_MODRM_NEEDED            (rep_latch_holder.cs.MODRM_NEEDED),
        .rep_latches_cs_RM_IS_DR                (rep_latch_holder.cs.RM_IS_DR),
        .rep_latches_cs_SWITCH_LD_ADDY          (rep_latch_holder.cs.SWITCH_LD_ADDY),
        .rep_latches_cs_LD_OP                   (rep_latch_holder.cs.LD_OP),
        .rep_latches_cs_ST_OP                   (rep_latch_holder.cs.ST_OP),
        .rep_latches_cs_dr_id                   (rep_latch_holder.cs.dr_id),
        .rep_latches_cs_sr_id                   (rep_latch_holder.cs.sr_id),
        .rep_latches_cs_dr_rd                   (rep_latch_holder.cs.dr_rd),
        .rep_latches_cs_sr_rd                   (rep_latch_holder.cs.sr_rd),
        .rep_latches_cs_eax_rd                  (rep_latch_holder.cs.eax_rd),
        .rep_latches_cs_dr_wr                   (rep_latch_holder.cs.dr_wr),
        .rep_latches_cs_sr_wr                   (rep_latch_holder.cs.sr_wr),
        .rep_latches_cs_eax_wr                  (rep_latch_holder.cs.eax_wr),
        .rep_latches_cs_MOVS_OP                 (rep_latch_holder.cs.MOVS_OP),
        .rep_latches_cs_datasize                (rep_latch_holder.cs.datasize),
        .rep_latches_cs_will_mod_zf             (rep_latch_holder.cs.will_mod_zf),
        .rep_latches_cs_seg_1_valid             (rep_latch_holder.cs.seg_1_valid),
        .rep_latches_cs_seg_0_id                (rep_latch_holder.cs.seg_0_id),
        .rep_latches_cs_seg_1_id                (rep_latch_holder.cs.seg_1_id),
        .rep_latches_cs_special_modrm_bs        (rep_latch_holder.cs.special_modrm_bs),
        .rep_latches_cs_special_br              (rep_latch_holder.cs.special_br),
        .rep_latches_dc_cs_LD_OP                (rep_latch_holder.dc_cs.LD_OP),
        .rep_latches_dc_cs_ST_OP                (rep_latch_holder.dc_cs.ST_OP),
        .rep_latches_dc_cs_dr_upper8            (rep_latch_holder.dc_cs.dr_upper8),
        .rep_latches_dc_cs_sr_upper8            (rep_latch_holder.dc_cs.sr_upper8),
        .rep_latches_dc_cs_datasize             (rep_latch_holder.dc_cs.datasize),
        .rep_latches_mem_cs_ST_OP               (rep_latch_holder.mem_cs.ST_OP),
        .rep_latches_mem_cs_LD_OP               (rep_latch_holder.mem_cs.LD_OP),
        .rep_latches_exe_cs_ST_OP               (rep_latch_holder.exe_cs.ST_OP),
        .rep_latches_exe_cs_OP_TYPE             (rep_latch_holder.exe_cs.OP_TYPE[`EXE_OP_W-1:0]),
        .rep_latches_exe_cs_alu_inputA_sel      (rep_latch_holder.exe_cs.alu_inputA_sel[`SRC_SEL_W-1:0]),
        .rep_latches_exe_cs_alu_inputB_sel      (rep_latch_holder.exe_cs.alu_inputB_sel[`SRC_SEL_W-1:0]),
        .rep_latches_exe_cs_branch_target_sel   (rep_latch_holder.exe_cs.branch_target_sel[`SRC_SEL_W-1:0]),
        .rep_latches_exe_cs_shift_by_one        (rep_latch_holder.exe_cs.shift_by_one),
        .rep_latches_exe_cs_br_ucond            (rep_latch_holder.exe_cs.br_ucond),
        .rep_latches_exe_cs_relative_branch     (rep_latch_holder.exe_cs.relative_branch),
        .rep_latches_exe_cs_special_br          (rep_latch_holder.exe_cs.special_br),
        .rep_latches_exe_cs_is_far              (rep_latch_holder.exe_cs.is_far),
        .rep_latches_exe_cs_is_call             (rep_latch_holder.exe_cs.is_call),
        .rep_latches_exe_cs_second_flag_needed  (rep_latch_holder.exe_cs.second_flag_needed),
        .rep_latches_exe_cs_rep_no_zf_update    (rep_latch_holder.exe_cs.rep_no_zf_update),
        .rep_latches_wb_cs_ST_OP                (rep_latch_holder.wb_cs.ST_OP),
        .rep_latches_wb_cs_WB_DR                (rep_latch_holder.wb_cs.WB_DR),
        .rep_latches_wb_cs_WB_SR                (rep_latch_holder.wb_cs.WB_SR),
        .rep_latches_wb_cs_WB_EAX               (rep_latch_holder.wb_cs.WB_EAX),
        .rep_latches_br_info_valid              (rep_latch_holder.br_info.valid),
        .rep_latches_br_info_br_eip             (rep_latch_holder.br_info.br_eip),
        .rep_latches_br_info_br_xcl             (rep_latch_holder.br_info.br_xcl),
        .rep_latches_br_info_br_pred_taken      (rep_latch_holder.br_info.br_pred_taken),
        .rep_latches_br_info_speculative_target (rep_latch_holder.br_info.speculative_target),
        .rep_latches_NEIP                       (rep_latch_holder.NEIP),
        .rep_latches_EIP                        (rep_latch_holder.EIP),
        .rep_latches_EAX                        (rep_latch_holder.EAX),
        .rep_latches_imm64                      (rep_latch_holder.imm64),
        .rep_latches_sib_idx_id                 (rep_latch_holder.sib_idx_id),
        .rep_latches_sib_base_id                (rep_latch_holder.sib_base_id),
        .rep_latches_sib_needed                 (rep_latch_holder.sib_needed),
        .rep_latches_sib_scale                  (rep_latch_holder.sib_scale),
        .rep_latches_disp_needed                (rep_latch_holder.disp_needed),
        .rep_latches_disp_size                  (rep_latch_holder.disp_size),
        .rep_latches_displacement               (rep_latch_holder.displacement),
        .clear_rep                              (clear_rep)
    );

endmodule