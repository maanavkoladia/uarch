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

    uint32_t PrevEIP;
    uint32_t EIP;
    uint32_t NEIP;
    logic [3:0] inst_length;
    logic [3:0] PrevLength;
    uint8_t sib_byte;
    bool sib_size;
    bool disp_needed;
    uint32_t displacement;
    bool disp_size;
    uint64_t imm64;
    logic [9:0] total_pf_vector;  //MSB --> 2e, 36, 3e, 26, 64, 65, 66, 67, 0f, f3  <-- LSB vector
    bool invalid_inst;
    uint8_t opcode_byte, modrm_byte;
    decode_cs_t temp_decode_cs;
    rr_cs_t temp_rr_cs;
    dc_cs_t temp_dc_cs;
    mem_cs_t temp_mem_cs;
    exe_cs_t temp_exe_cs;
    wb_cs_t temp_wb_cs;
    bool decode_gp;
    rr_latches_general_t temp_rr_latch;
    bool flush; //cpaddyx , i did not put ts here, whats this for
    logic REP_LATCH, REP_CMP_LATCH, REP_MOV_LATCH, HALT_REG;
    wire rr_latch_we_o;

    uint32_t DC_SAVED_EIP;
    uint32_t DECODE_SAVED_EIP;

    reg_ids_e SAVED_SEGMENT0;
    bool SAVED_SEGMENT_OVERRIDE;
    uint32_t SAVED_REP_EIP;
    logic [1:0] SAVED_DATASIZE;


    reg_ids_e segment0;
    bool seg_override;

    bool next_rr_valid;

    assign flush = exe_outs_i.br_res_out.flush;


    bool decode_forward;
    assign decode_forward = rr_latch_we_o && next_rr_valid;


    wire [63:0][7:0] queue;
    genvar i;
    generate
        for (i = 0; i < 4; i++) begin   : idm_to_queue_nonsense
            assign queue[i*16 +: 16] = '{
                idm_outs_i.idm_slots[i].data[15], idm_outs_i.idm_slots[i].data[14], idm_outs_i.idm_slots[i].data[13], idm_outs_i.idm_slots[i].data[12],
                idm_outs_i.idm_slots[i].data[11], idm_outs_i.idm_slots[i].data[10], idm_outs_i.idm_slots[i].data[9], idm_outs_i.idm_slots[i].data[8],
                idm_outs_i.idm_slots[i].data[7], idm_outs_i.idm_slots[i].data[6], idm_outs_i.idm_slots[i].data[5], idm_outs_i.idm_slots[i].data[4],
                idm_outs_i.idm_slots[i].data[3], idm_outs_i.idm_slots[i].data[2], idm_outs_i.idm_slots[i].data[1], idm_outs_i.idm_slots[i].data[0]
            };
        end
    endgenerate

    wire [511:0] flattened_queue;

    generate
        for (i = 0; i < 64; i++) begin : queue_flattening
            assign flattened_queue[i*8 +: 8] = queue[i];
        end
    endgenerate

    predecode inst_processing(
        .clk(clk), .rst(rst), .queue(flattened_queue),
        .queue_valid({idm_outs_i.idm_slots[3].valid, idm_outs_i.idm_slots[2].valid,
                    idm_outs_i.idm_slots[1].valid, idm_outs_i.idm_slots[0].valid}),
        .EIP(EIP), .NEIP(NEIP), .inst_length(inst_length), .sib_byte(sib_byte), .sib_size(sib_size),
        .opcode_byte(opcode_byte), .modrm_byte(modrm_byte), .disp(displacement), .disp_size(disp_size),
        .disp_needed(disp_needed), .imm64(imm64), .total_pf_vector(total_pf_vector), .invalid_inst(invalid_inst)
    );

    control_store cs (
        .invalid_inst(invalid_inst),
        .total_pf_vector(total_pf_vector),
        .opcode(opcode_byte),
        .modrm(modrm_byte),
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
        .rr_cs_seg_0_id(temp_rr_cs.seg_0_id),
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
        .wb_cs_WB_EAX(temp_wb_cs.WB_EAX)
    );

    decode_gp_gen gp_gen_decode(
        .prev_eip(PrevEIP), .prev_length(PrevLength),
        .segLimit(rr_outs_i.codeSeg_limit), .gp_fault_o(decode_gp)
    );

    wire predicted_taken;
    wire [31:0] pred_target;
    wire branch_info_valid;
    wire [31:0] branch_info_br_eip;
    wire branch_info_br_xcl;
    wire branch_info_br_pred_taken;
    wire branch_info_speculative_target;

    br_info_t br_info_for_latches;
    assign br_info_for_latches = '{
        valid : branch_info_valid,
        br_eip : branch_info_br_eip,
        br_xcl : branch_info_br_xcl,
        br_pred_taken : branch_info_br_pred_taken,
        speculative_target : branch_info_speculative_target
    };

    assign predicted_taken = (idm_outs_i.idm_slots[EIP[5:4]].valid &&
                            idm_outs_i.idm_slots[EIP[5:4]].br_valid &&
                            idm_outs_i.idm_slots[EIP[5:4]].br_eip == EIP);
    l_address_t predicted_target;
    assign predicted_target = predicted_taken ? idm_outs_i.idm_slots[EIP[5:4]].br_btb_target : 32'b0;
    bool branch_present;
    assign branch_present = temp_exe_cs.br_ucond || temp_exe_cs.relative_branch || temp_exe_cs.special_br;
    br_info_processing br_info_gen(
        .cs_branch(branch_present), .eip(EIP), .br_length(inst_length),
        .pred_taken(predicted_taken), .pred_target(predicted_target), 
        .branch_info_valid(branch_info_valid),
        .branch_info_br_eip(branch_info_br_eip),
        .branch_info_br_xcl(branch_info_br_xcl),
        .branch_info_br_pred_taken(branch_info_br_pred_taken),
        .branch_info_speculative_target(branch_info_speculative_target)
    );
    //need to add if branch or not to cs excel sheet

    reg_ids_e sibbase, sibidx;
    uint8_t sibscale;
    sib_processor sib_processing(.sib_byte(sib_byte), .sib_idx_id(sibidx), 
        .sib_base_id(sibbase), .sib_scale(sibscale)
    );

    rr_latches_general_t rep_latch_holder;
    bool clear_rep;

    bool external_set_zf;
    assign external_set_zf = temp_rr_cs.will_mod_zf && decode_forward;


    rep_controller piece_of_shit_rep_controller (
        .clk(clk), .rst(rst), .rep_latch(REP_LATCH),
        .mov_inst(REP_MOV_LATCH), .cmp_inst(REP_CMP_LATCH), .clear_zf(exe_outs_i.clr_ZF_sb),
        .external_set_zf(external_set_zf), .ecx(rr_outs_i.ecx), .ecx_sb(rr_outs_i.ecx_sb),
        .zf_flag(exe_outs_i.ZF), .stall(!decode_forward), .flush(flush), .exp_pipe_clear(fetch_outs_i.exp_pipe_clear),
        .rep_latches(rep_latch_holder), .clear_rep(clear_rep), .saved_segment0(SAVED_SEGMENT0), 
        .saved_segment_override(SAVED_SEGMENT_OVERRIDE), .saved_rep_eip(SAVED_REP_EIP),
        .saved_datasize(SAVED_DATASIZE)
    );

  
    rr_valid_logic decode_2_RR_valid_logic(
        .RR_we_o(rr_latch_we_o),
        .N_RR_V_o(next_rr_valid),
        .DECODE_V_i(!invalid_inst),
        .RR_stall_i(rr_outs_i.stall),
        .RR_V_i(rr_outs_i.valid),
        .DC_stall_i(dc_outs_i.stall),
        .DC_V_i(dc_outs_i.valid),
        .MEM_V_i(mem_outs_i.valid),
        .MEM_stall_i(mem_outs_i.stall),
        .EXE_V_i(exe_outs_i.valid),
        .WB_stall_i(wb_outs_i.wb_stall)
    );


    always_comb begin
        if(total_pf_vector[9]) begin
            segment0 = CS; //2e
            seg_override = 1'b1;
        end
        else if (total_pf_vector[8]) begin
            segment0 = SS;   //36
            seg_override = 1'b1;
        end
        else if (total_pf_vector[7]) begin
            segment0 = DS;   //3e
            seg_override = 1'b1;
        end
        else if (total_pf_vector[6]) begin
            segment0 = ES;   //26
            seg_override = 1'b1;
        end
        else if (total_pf_vector[5]) begin
            segment0 = FS;   //64
            seg_override = 1'b1;
        end
        else if (total_pf_vector[4]) begin
            segment0 = GS;   //65
            seg_override = 1'b1;
        end
        else begin
            segment0 = DS;
            seg_override = 1'b0;
        end
    end

    // // -----------------------------------------------------------------
    // // Structural register block (replaces the two always_ff blocks).
    // // MPS_reg_rst_we$ is treated as an active-high synchronous-reset
    // // register: if rst==1 -> q<=0; else if we==1 -> q<=d.
    // // Top-level `rst` is active-low, so we invert it locally.
    // // -----------------------------------------------------------------
    // wire rst_high           = !rst;
    // wire eff_rst_full       = rst_high || fetch_outs_i.exp_pipe_clear;
    // wire eff_rst_with_flush = eff_rst_full || flush;

    // // ---- HALT_REG ----
    // //   write iff (!HALT_REG && !invalid_inst); din = HALT
    // //   reset on rst | exp_pipe_clear | flush
    // wire halt_we  = (!HALT_REG) && (!invalid_inst);
    // wire halt_din = temp_decode_cs.HALT;
    // `REG_RST_WE(u_halt_reg, 1, clk, eff_rst_with_flush, halt_we, halt_din, HALT_REG)

    // // ---- REP_LATCH and SAVED_* (gated by {REP, clear_rep}) ----
    // //   00: hold; 01: 0; 10: capture; 11: 0
    // //   => we = REP | clear_rep, set = REP & !clear_rep
    // wire rep_set_or_clr = temp_decode_cs.REP || clear_rep;
    // wire rep_capture    = temp_decode_cs.REP && !clear_rep;

    // `REG_RST_WE(u_rep_latch, 1, clk, eff_rst_with_flush,
    //             rep_set_or_clr, rep_capture, REP_LATCH)

    // wire [$bits(reg_ids_e)-1:0] saved_seg0_din = rep_capture ? segment0 : '0;
    // `REG_RST_WE(u_saved_seg0, $bits(reg_ids_e), clk, eff_rst_with_flush,
    //             rep_set_or_clr, saved_seg0_din, SAVED_SEGMENT0)

    // wire saved_segov_din = rep_capture ? seg_override : 1'b0;
    // `REG_RST_WE(u_saved_segov, 1, clk, eff_rst_with_flush,
    //             rep_set_or_clr, saved_segov_din, SAVED_SEGMENT_OVERRIDE)

    // wire [31:0] saved_rep_eip_din = rep_capture ? EIP : 32'b0;
    // `REG_RST_WE(u_saved_rep_eip, 32, clk, eff_rst_with_flush,
    //             rep_set_or_clr, saved_rep_eip_din, SAVED_REP_EIP)

    // wire [1:0] saved_ds_din = rep_capture ? temp_decode_cs.DATA_SIZE : 2'b0;
    // `REG_RST_WE(u_saved_ds, 2, clk, eff_rst_with_flush,
    //             rep_set_or_clr, saved_ds_din, SAVED_DATASIZE)

    // // ---- REP_CMP_LATCH ({REP_CMP, clear_rep}) ----
    // wire repcmp_we  = temp_decode_cs.REP_CMP || clear_rep;
    // wire repcmp_din = temp_decode_cs.REP_CMP && !clear_rep;
    // `REG_RST_WE(u_rep_cmp, 1, clk, eff_rst_with_flush,
    //             repcmp_we, repcmp_din, REP_CMP_LATCH)

    // // ---- REP_MOV_LATCH ({REP & !REP_CMP, clear_rep}) ----
    // wire mov_cond   = temp_decode_cs.REP && !temp_decode_cs.REP_CMP;
    // wire repmov_we  = mov_cond || clear_rep;
    // wire repmov_din = mov_cond && !clear_rep;
    // `REG_RST_WE(u_rep_mov, 1, clk, eff_rst_with_flush,
    //             repmov_we, repmov_din, REP_MOV_LATCH)

    // // ---- EIP / PrevEIP / PrevLength ----
    // //   reset on rst | exp_pipe_clear (NOT flush -- flush feeds br_target).
    // //   PrevEIP and PrevLength always update each cycle (we=1).
    // //   EIP next-state priority:
    // //     br_res.valid & flush  -> br_target
    // //     idm-slot match & fwd  -> btb_target
    // //     fwd & !HALT & !REP    -> NEIP
    // //     else                  -> hold (self)
    // wire idm_br_match = (idm_outs_i.idm_slots[EIP[5:4]].br_eip == EIP)
    //                  && (idm_outs_i.idm_slots[EIP[5:4]].valid)
    //                  && (idm_outs_i.idm_slots[EIP[5:4]].br_valid)
    //                  && decode_forward;
    // wire brres_take   = exe_outs_i.br_res_out.valid && flush;
    // wire fwd_advance  = decode_forward && !HALT_REG && !REP_LATCH;

    // wire [31:0] eip_next;
    // assign eip_next = brres_take   ? exe_outs_i.br_res_out.br_target              :
    //                   idm_br_match ? idm_outs_i.idm_slots[EIP[5:4]].br_btb_target :
    //                   fwd_advance  ? NEIP                                         :
    //                                  EIP;

    // `REG_RST_WE(u_eip,        32, clk, eff_rst_full, 1'b1, eip_next,    EIP)
    // `REG_RST_WE(u_prev_eip,   32, clk, eff_rst_full, 1'b1, EIP,         PrevEIP)
    // `REG_RST_WE(u_prev_len,    4, clk, eff_rst_full, 1'b1, inst_length, PrevLength)

    // // ---- DC_SAVED_EIP / DECODE_SAVED_EIP ----
    // //   reset on rst only; write only on exp_pipe_clear.
    // `REG_RST_WE(u_dc_saved_eip,     32, clk, rst_high,
    //             fetch_outs_i.exp_pipe_clear, dc_outs_i.dc_eip, DC_SAVED_EIP)
    // `REG_RST_WE(u_decode_saved_eip, 32, clk, rst_high,
    //             fetch_outs_i.exp_pipe_clear, EIP,              DECODE_SAVED_EIP)

    always_ff @(posedge clk) begin
        if(!rst || fetch_outs_i.exp_pipe_clear) begin
            EIP <= 32'b0;
            PrevEIP <= 32'b0;
            PrevLength <= 32'b0;
            REP_LATCH <= 1'b0;    //need to save if its mov or cmp so can process next cylce, doing this to save crit path time
            REP_CMP_LATCH <= 1'b0;
            REP_MOV_LATCH <= 1'b0;
            HALT_REG <= 1'b0;
            SAVED_SEGMENT0 <= 1'b0;
            SAVED_SEGMENT_OVERRIDE <= 1'b0;
            SAVED_REP_EIP <= 1'b0;
            SAVED_DATASIZE <= 1'b0;
        end
        else begin
            if(flush) begin
                HALT_REG <= 1'b0;
                REP_LATCH <= 1'b0;
                REP_CMP_LATCH <= 1'b0;
                REP_MOV_LATCH <= 1'b0;
                SAVED_SEGMENT0 <= 1'b0;
                SAVED_SEGMENT_OVERRIDE <= 1'b0;
                SAVED_REP_EIP <= 1'b0;
                SAVED_DATASIZE <= 1'b0;
            end
            else begin
                HALT_REG <= (!HALT_REG && !invalid_inst) ? temp_decode_cs.HALT : HALT_REG;
                case ({temp_decode_cs.REP, clear_rep})
                    2'b00: begin
                        REP_LATCH <= REP_LATCH;
                        SAVED_SEGMENT0 <= SAVED_SEGMENT0;
                        SAVED_SEGMENT_OVERRIDE <= SAVED_SEGMENT_OVERRIDE;
                        SAVED_REP_EIP <= SAVED_REP_EIP;
                        SAVED_DATASIZE <= SAVED_DATASIZE;
                    end
                    2'b01: begin
                        REP_LATCH <= 1'b0;
                        SAVED_SEGMENT0 <= 1'b0;
                        SAVED_SEGMENT_OVERRIDE <= 1'b0;
                        SAVED_REP_EIP <= 1'b0;
                        SAVED_DATASIZE <= 1'b0;
                    end
                    2'b10: begin
                        REP_LATCH <= 1'b1;
                        SAVED_SEGMENT0 <= segment0;
                        SAVED_SEGMENT_OVERRIDE <= seg_override;
                        SAVED_REP_EIP <= EIP;
                        SAVED_DATASIZE <= temp_decode_cs.DATA_SIZE;
                    end
                    2'b11: begin
                        REP_LATCH <= 1'b0;
                        SAVED_SEGMENT0 <= 1'b0;
                        SAVED_SEGMENT_OVERRIDE <= 1'b0;
                        SAVED_REP_EIP <= 1'b0;
                        SAVED_DATASIZE <= 1'b0;
                    end
                endcase
                case ({temp_decode_cs.REP_CMP, clear_rep})
                    2'b00: REP_CMP_LATCH <= REP_CMP_LATCH;
                    2'b01: REP_CMP_LATCH <= 1'b0;
                    2'b10: REP_CMP_LATCH <= 1'b1;
                    2'b11: REP_CMP_LATCH <= 1'b0;
                endcase
                case ({(temp_decode_cs.REP && !temp_decode_cs.REP_CMP), clear_rep})
                    2'b00: REP_MOV_LATCH <= REP_MOV_LATCH;
                    2'b01: REP_MOV_LATCH <= 1'b0;
                    2'b10: REP_MOV_LATCH <= 1'b1;
                    2'b11: REP_MOV_LATCH <= 1'b0;
                endcase
            end

            if(exe_outs_i.br_res_out.valid && flush) begin
                EIP <= exe_outs_i.br_res_out.br_target;
                PrevEIP <= EIP;
                PrevLength <= inst_length;
            end
            else begin
                if((idm_outs_i.idm_slots[EIP[5:4]].br_eip == EIP)
                        && (idm_outs_i.idm_slots[EIP[5:4]].valid)
                        && (idm_outs_i.idm_slots[EIP[5:4]].br_valid)
                        && decode_forward) begin
                    EIP <= idm_outs_i.idm_slots[EIP[5:4]].br_btb_target;
                    PrevEIP <= EIP;
                    PrevLength <= inst_length;
                end
                else begin
                    if(decode_forward && !HALT_REG && !REP_LATCH) begin
                        EIP <= NEIP;
                        PrevEIP <= EIP;
                        PrevLength <= inst_length;
                    end
                    else begin
                        EIP <= EIP;
                        PrevEIP <= EIP;
                        PrevLength <= inst_length;
                    end
                end
            end
        end
    end

    always_ff @(posedge clk) begin
        if(!rst) begin
            DC_SAVED_EIP <= 0;
            DECODE_SAVED_EIP <= 0;
        end
        else begin
            if(fetch_outs_i.exp_pipe_clear) begin
                DC_SAVED_EIP <= dc_outs_i.dc_eip;
                DECODE_SAVED_EIP <= EIP;
            end
        end
    end

    uint32_t EXCEPTION_EIP;
    assign EXCEPTION_EIP = (!fetch_outs_i.exp_mode_jk[1] || fetch_outs_i.int_mode_jk) ? DECODE_SAVED_EIP : DC_SAVED_EIP;


    bool going_to_halt;
    assign going_to_halt = (HALT_REG || temp_decode_cs.HALT);

    bool going_to_rep;
    assign going_to_rep = (REP_LATCH || temp_decode_cs.REP);


    assign temp_rr_latch = '{
        valid           : next_rr_valid && !going_to_halt && !going_to_rep && !fetch_outs_i.exp_pipe_clear,
        cs              : temp_rr_cs,

        dc_cs           : temp_dc_cs,
        mem_cs          : temp_mem_cs,
        exe_cs          : temp_exe_cs,
        wb_cs           : temp_wb_cs,

        br_info         : br_info_for_latches,
        NEIP            : NEIP,
        EIP             : (fetch_outs_i.exp_mode_jk[0] || fetch_outs_i.int_mode_jk) ? EXCEPTION_EIP : EIP,
        EAX             : rr_outs_i.eax,

        imm64           : imm64,
        sib_idx_id      : sibidx,
        sib_base_id     : sibbase,
        sib_needed      : (temp_rr_cs.MODRM_NEEDED) ? sib_size : 1'b0,
        sib_scale       : sibscale,
        disp_needed     : (temp_rr_cs.MODRM_NEEDED) ? disp_needed : 1'b0,
        disp_size       : (temp_rr_cs.MODRM_NEEDED) ? disp_size : 1'b0,
        displacement    : displacement
    };

    assign rr_latches_next = '{
        normal_latches : temp_rr_latch,
        rep_latches : rep_latch_holder
    };

    assign outs_o = '{
        valid : !invalid_inst,
        stall : invalid_inst,
        eip : EIP,
        invalid_instruction : invalid_inst,
        decode_gp : decode_gp && rr_outs_i.valid,
        rr_stage_latch_we : rr_latch_we_o,
        rep_latch : REP_LATCH,
        decode_forward : decode_forward
    };


endmodule


    //prefix stuff(ppu s), 
    //invalid instruciton logic (i think we dciessed that this needs a bit to redcue critaoth back into exp logic in fetch),
    //modrm LUT, 
    //opcode LUT (CS stuff)
    //instuciton len adding
    //sib logic
    //displacment logic
    //immedatite logic
    //segment id gen ()
    //all regs use internal reg_Id_t in the core pkgs
    //
    //rep controller (takes ecx, set/clr zf_sb, zf flag, ecx sb, CS_signal for
    //rep(sthild not be apassed forward is internal to decode)
    //
    //needs to send a gp to rr (eip, preveip, prev instruciton len logic to
    //gen a gp and send it forward to rr to tell it that its corrent
    //isntrucitoni s invlaid and it needs to throw a gp, ie gp not thrown here,
    //it is intdicated to rr that it needs to throw one)
    //
    //br logic so taken info comes from idm not taken still needs to populate
    //the br info because exe needs it for br resolution
    //
    //loigc needed for reading from the idm slots, ie invalid stuff, etc