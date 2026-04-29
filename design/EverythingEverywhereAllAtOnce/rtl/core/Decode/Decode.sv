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


    reg_ids_e segment0;
    bool seg_override;

    bool next_rr_valid;

    assign flush = exe_outs_i.br_res_out.flush;


    bool decode_forward;
    assign decode_forward = rr_latch_we_o && next_rr_valid;


    logic [63:0][7:0] queue;
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

    predecode inst_processing(
        .clk(clk), .rst(rst), .queue(queue),
        .queue_valid({idm_outs_i.idm_slots[3].valid, idm_outs_i.idm_slots[2].valid,
                    idm_outs_i.idm_slots[1].valid, idm_outs_i.idm_slots[0].valid}),
        .EIP(EIP), .NEIP(NEIP), .inst_length(inst_length), .sib_byte(sib_byte), .sib_size(sib_size),
        .opcode_byte(opcode_byte), .modrm_byte(modrm_byte), .disp(displacement), .disp_size(disp_size),
        .disp_needed(disp_needed), .imm64(imm64), .total_pf_vector(total_pf_vector), .invalid_inst(invalid_inst)
    );

    control_store cs(
        .invalid_inst(invalid_inst), //can aparellize this if needed
        .opcode(opcode_byte), .total_pf_vector(total_pf_vector), .modrm(modrm_byte), .seg_override(seg_override), .seg0(segment0), .decode_cs(temp_decode_cs),
        .rr_cs(temp_rr_cs), .dc_cs(temp_dc_cs), .mem_cs(temp_mem_cs), .exe_cs(temp_exe_cs), .wb_cs(temp_wb_cs)
    );

    decode_gp_gen gp_gen_decode(
        .prev_eip(PrevEIP), .prev_length(PrevLength),
        .segLimit(rr_outs_i.codeSeg_limit), .gp_fault_o(decode_gp)
    );

    br_info_t br_info_for_latches;
    bool predicted_taken;
    assign predicted_taken = (idm_outs_i.idm_slots[EIP[5:4]].valid &&
                            idm_outs_i.idm_slots[EIP[5:4]].br_valid &&
                            idm_outs_i.idm_slots[EIP[5:4]].br_eip == EIP);
    l_address_t predicted_target;
    assign predicted_target = predicted_taken ? idm_outs_i.idm_slots[EIP[5:4]].br_btb_target : 32'b0;
    bool branch_present;
    assign branch_present = temp_exe_cs.br_ucond || temp_exe_cs.relative_branch || temp_exe_cs.special_br;
    br_info_processing br_info_gen(
        .cs_branch(branch_present), .eip(EIP), .br_length(inst_length),
        .pred_taken(predicted_taken), .pred_target(predicted_target), .branch_output(br_info_for_latches)
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
        .clk(clk), .rst(rst), .rep_prefix(total_pf_vector[0]),
        .mov_inst(REP_MOV_LATCH), .cmp_inst(REP_CMP_LATCH), .clear_zf(exe_outs_i.clr_ZF_sb),
        .external_set_zf(external_set_zf), .ecx(rr_outs_i.ecx), .ecx_sb(rr_outs_i.ecx_sb),
        .zf_flag(exe_outs_i.ZF), .stall(!decode_forward), .flush(flush), .exp_pipe_clear(fetch_outs_i.exp_pipe_clear),
        .rep_latches(rep_latch_holder), .clear_rep(clear_rep)
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

    always_ff @(posedge clk) begin
        if(!rst || fetch_outs_i.exp_pipe_clear) begin
            EIP <= 32'b0;
            PrevEIP <= 32'b0;
            PrevLength <= 32'b0;
            REP_LATCH <= 1'b0;    //need to save if its mov or cmp so can process next cylce, doing this to save crit path time
            REP_CMP_LATCH <= 1'b0;
            REP_MOV_LATCH <= 1'b0;
            HALT_REG <= 1'b0;
        end
        else begin
            if(flush) begin
                HALT_REG <= 1'b0;
                REP_LATCH <= 1'b0;
                REP_CMP_LATCH <= 1'b0;
                REP_MOV_LATCH <= 1'b0;
            end
            else begin
                HALT_REG <= (!HALT_REG) ? temp_decode_cs.HALT : HALT_REG;
                case ({temp_decode_cs.REP, clear_rep})
                    2'b00: REP_LATCH <= REP_LATCH;
                    2'b01: REP_LATCH <= 1'b0;
                    2'b10: REP_LATCH <= 1'b1;
                    2'b11: REP_LATCH <= 1'b0;
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
                    //if(!invalid_inst && !stall && !rep_reg_value) EIP <= NEIP;
                    if(decode_forward && !HALT_REG && !REP_LATCH) begin
                        EIP <= NEIP;    //need to integrate rep
                        PrevEIP <= EIP;
                        PrevLength <= inst_length;
                    end
                    //if(!invalid_inst && !HALT_REG) EIP <= NEIP;
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
    assign EXCEPTION_EIP = (fetch_outs_i.exp_mode_jk[1]) ? DC_SAVED_EIP : DECODE_SAVED_EIP;


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
        EIP             : (fetch_outs_i.exp_mode_jk[0]) ? EXCEPTION_EIP : EIP,
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
        rep_latch : REP_LATCH
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