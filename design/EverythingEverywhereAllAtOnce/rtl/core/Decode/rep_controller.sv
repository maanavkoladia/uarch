import RegisterRead_pkg::*;
import Decode_pkg::*;

module rep_controller (
    input wire clk, rst,
    input bool rep_latch,
    input bool mov_inst,
    input bool cmp_inst,
    input bool clear_zf, external_set_zf,
    input uint32_t ecx,
    input bool ecx_sb,
    input bool zf_flag,
    input bool stall,
    input bool flush,
    input bool exp_pipe_clear,
    output rr_latches_general_t rep_latches,
    output bool clear_rep
);

    bool continue_mov, continue_cmp, wait_mov, wait_cmp, exit_mov, exit_cmp;
    assign continue_mov = !ecx_sb && ecx != 32'b0;
    assign wait_mov = ecx_sb;
    assign exit_mov = !ecx_sb && ecx == 32'b0;

    assign continue_cmp = (!ecx_sb && ecx != 32'b0) && (zf_sb.counter == 0 && zf_flag);
    assign wait_cmp = ecx_sb || zf_sb.counter != 0;
    assign exit_cmp = (!ecx_sb && ecx == 32'b0) || ((zf_sb.counter == 0) && !zf_flag);

    regsb_entry_t zf_sb;

    rep_fsm_states_e rep_fsm_state;
    logic [$clog2(REP_FSM_NUM_STATES) - 1 : 0] rep_fsm_state_bits;
    assign rep_fsm_state = rep_fsm_state_bits;

    rep_cmp_fsm_states_e rep_cmp_fsm_state;
    logic [$clog2(REP_CMP_FSM_NUM_STATES) - 1 : 0] rep_cmp_fsm_state_bits;
    assign rep_cmp_fsm_state = rep_cmp_fsm_state_bits;

    rep_movs_fsm_states_e rep_movs_fsm_state;
    logic [$clog2(REP_MOVS_FSM_NUM_STATES) - 1 : 0] rep_movs_fsm_state_bits;
    assign rep_movs_fsm_state = rep_movs_fsm_state_bits;

    bool movs_clear, cmp_clear;
    bool movs_start, cmp_start;

    logic [2:0] inst_select;
    logic [2:0] cmp_inst_select;
    logic [2:0] movs_inst_select;
    assign inst_select = (cmp_inst) ? cmp_inst_select : movs_inst_select;
    assign clear_rep = (cmp_inst) ? cmp_clear : movs_clear;

    bool fsm_reset;
    assign fsm_reset = rst && !exp_pipe_clear && !flush;

    rep_fsm fsm_rep(
        .clk(clk),
        .rst(fsm_reset),
        .rep_prefix_i(rep_latch),
        .cs_mov_i(mov_inst),
        .cs_cmp_i(cmp_inst),
        .mov_clear_i(movs_clear),
        .cmp_clear_i(cmp_clear),
        .stall_i(stall || wait_mov || wait_cmp),
        .S_0(rep_fsm_state_bits[0]),  // current-state bit 0 (LSB)
        .S_1(rep_fsm_state_bits[1]),  // current-state bit 1 (1)
        .S_2(rep_fsm_state_bits[2]),  // current-state bit 2 (MSB)
        .movs_start_o(movs_start),
        .cmp_start_o(cmp_start)
    );
    rep_cmp_fsm cmp_fsm(
        .clk(clk),
        .rst(fsm_reset),
        .start_i(cmp_start),
        .exit_mov_i(exit_mov),
        .cont_cmp_i(continue_cmp),
        .exit_cmp_i(exit_cmp),
        .wait_i(stall || wait_cmp),
        .S_0(rep_cmp_fsm_state_bits[0]),  // current-state bit 0 (LSB)
        .S_1(rep_cmp_fsm_state_bits[1]),  // current-state bit 1 (1)
        .S_2(rep_cmp_fsm_state_bits[2]),  // current-state bit 2 (MSB)
        .clear_rep_o(cmp_clear),
        .select_line2_o(cmp_inst_select[2]),
        .select_line1_o(cmp_inst_select[1]),
        .select_line0_o(cmp_inst_select[0])
    );
    rep_movs_fsm movs_fsm(
        .clk(clk),
        .rst(fsm_reset),
        .start_i(movs_start),
        .cont_mov_i(continue_mov),
        .wait_mov_i(wait_mov),
        .exit_mov_i(exit_mov),
        .stall_i(stall),
        .S_0(rep_movs_fsm_state_bits[0]),  // current-state bit 0 (LSB)
        .S_1(rep_movs_fsm_state_bits[1]),  // current-state bit 1 (1)
        .S_2(rep_movs_fsm_state_bits[2]),  // current-state bit 2 (MSB)
        .clear_rep_o(movs_clear),
        .select_line2_o(movs_inst_select[2]),
        .select_line1_o(movs_inst_select[1]),
        .select_line0_o(movs_inst_select[0])
    );

    bool updateSB;
    assign updateSB = !stall;

    bool internal_set_zf;
    assign internal_set_zf = rep_latches.cs.will_mod_zf && updateSB;

    bool set_zf;
    assign set_zf = (external_set_zf || internal_set_zf);

    always_ff @(posedge clk) begin
        if(!rst) begin
            zf_sb.counter <= 8'b0;
        end
        else begin
            if(flush) zf_sb.counter <= 8'b0;
            else begin
                // if(set_zf && updateSB) zf_sb.counter++;
                // if(clear_zf) zf_sb.counter--;
                case({set_zf, clear_zf})
                    2'b00: begin
                        zf_sb.counter <= zf_sb.counter;
                    end
                    2'b01: begin
                        zf_sb.counter--;
                    end
                    2'b10: begin
                        if(updateSB) zf_sb.counter++;
                    end
                    2'b11: begin
                        if(!updateSB) zf_sb.counter--;
                    end
                endcase
            end
        end
    end

    rr_latches_general_t idle_output;
    rr_latches_general_t movs_instruction; //mov0
    rr_latches_general_t dec_ecx; //mov1
    rr_latches_general_t cmp0;       //cmp0
    rr_latches_general_t cmp1;       //cmp1
    rr_latches_general_t cmp2;       //cmp2

    always_comb begin
        case (inst_select)
            3'b000: rep_latches = idle_output;
            3'b001: rep_latches = movs_instruction;
            3'b010: rep_latches = dec_ecx;
            3'b011: rep_latches = cmp0;
            3'b100: rep_latches = cmp1;
            3'b101: rep_latches = cmp2;
            default: rep_latches = idle_output;
        endcase
    end


    assign idle_output = '{
        valid : 1'b1,
        exe_cs : '{
            OP_TYPE : control_store_pkg::NOP,
            rep_no_zf_update : 1'b1,
            default : '0
        },
        default : '0
    };

    //will need to override datasize for these?

    //////////////////////////////// MOVS ///////////////////////////////
    assign movs_instruction = '{
        valid : 1'b1,
        cs : '{
            ST_SEL         : 1'b1,
            MODRM_NEEDED   : 1'b0,
            RM_IS_DR       : 1'b0,
            LD_OP          : 1'b1,
            ST_OP          : 1'b1,
            SWITCH_LD_ADDY : 1'b0,
            dr_id          : EDI,
            sr_id          : ESI,
            dr_rd          : 1'b1,
            sr_rd          : 1'b1,
            dr_wr          : 1'b1,
            sr_wr          : 1'b1,
			eax_wr			: 1'b0,
			eax_rd			: 1'b0,
			MOVS_OP			: 1'b1,
            datasize       : 2'b10,
            will_mod_zf    : 1'b0,
            seg_1_valid    : 1'b1,
            seg_0_id       : DS,
            seg_1_id       : ES,
            special_modrm_bs: 1'b0,
            special_br      : 1'b0
        },
        dc_cs : '{
            LD_OP     : 1'b1,
            ST_OP     : 1'b1,
            dr_upper8 	 : 1'b0,
			sr_upper8 	 : 1'b0,
            datasize  : 2'b10
        },
        mem_cs : '{
            ST_OP : 1'b1,
            LD_OP : 1'b1
        },
        exe_cs : '{
            ST_OP               : 1'b1,
            OP_TYPE             : control_store_pkg::MOVS,
            alu_inputA_sel      : SR_DR_SEL,
            alu_inputB_sel      : BUFFER,
            branch_target_sel   : NO_EXE,
            shift_by_one        : 1'b0,
            br_ucond            : 1'b0,
            relative_branch     : 1'b0,
            special_br          : 1'b0,
            is_far              : 1'b0,
            is_call             : 1'b0,
            second_flag_needed  : 1'b0,
            rep_no_zf_update    : 1
        },
        wb_cs : '{
            ST_OP : 1'b1,
            WB_DR : 1'b1,
            WB_SR : 1'b1,
			WB_EAX: 1'b0
        },
        br_info      : '{default:'0},  // no branch so zero?
        NEIP         : 32'h0,
        EIP          : 32'h0,
        EAX          : 32'h0,
        imm64        : 64'h0,
        sib_idx_id   : NO_REG,
        sib_base_id  : NO_REG,
        sib_needed   : 1'b0,
        sib_scale    : 8'h0,
        disp_needed  : 1'b0,
        disp_size    : 1'b0,
        displacement : 32'h0
    };

    assign dec_ecx = '{
        valid : 1'b1,
        cs : '{
            ST_SEL         : 1'b0,
            MODRM_NEEDED   : 1'b1,
            RM_IS_DR       : 1'b1,
            LD_OP          : 1'b0,
            ST_OP          : 1'b0,
            SWITCH_LD_ADDY : 1'b0,
            dr_id          : ECX,
            sr_id          : NO_REG,
            dr_rd          : 1'b1,
            sr_rd          : 1'b0,
            dr_wr          : 1'b1,
            sr_wr          : 1'b0,
			eax_wr			: 1'b0,
			eax_rd			: 1'b0,
			MOVS_OP			: 1'b0,
            datasize       : 2'b10,
            will_mod_zf    : 1'b0,
            seg_1_valid    : 1'b0,
            seg_0_id       : DS,
            seg_1_id       : DS,
            special_modrm_bs: 1'b0,
            special_br      : 1'b0
        },
        dc_cs : '{
            LD_OP     : 1'b0,
            ST_OP     : 1'b0,
            dr_upper8    : 1'b0,
            sr_upper8   : 1'b0,
            datasize  : 2'b10
        },
        mem_cs : '{
            ST_OP : 1'b0,
            LD_OP : 1'b0
        },
        exe_cs : '{
            ST_OP               : 1'b0,
            OP_TYPE             : ADD,
            alu_inputA_sel      : DR_REGISTER,
            alu_inputB_sel      : SEXT8,
            branch_target_sel   : NO_EXE,
            shift_by_one        : 1'b0,
            br_ucond            : 1'b0,
            relative_branch     : 1'b0,
            special_br          : 1'b0,
            is_far              : 1'b0,
            is_call             : 1'b0,
            second_flag_needed  : 1'b0,
            rep_no_zf_update    : 1

        },
        wb_cs : '{
            ST_OP : 1'b0,
            WB_DR : 1'b1,
            WB_SR : 1'b0,
			WB_EAX: 1'b0
        },
        br_info      : '{default:'0},  
        NEIP         : 32'h0,
        EIP          : 32'h0,
        EAX          : 32'h0,
        imm64        : 64'hff,
        sib_idx_id   : NO_REG,
        sib_base_id  : NO_REG,
        sib_needed   : 1'b0,
        sib_scale    : 8'h0,
        disp_needed  : 1'b0,
        disp_size    : 1'b0,
        displacement : 32'h0
    };




    ////////////////////////////// CMP ///////////////////////////////////
    //mov ds:(%esi), %etr
    assign cmp0 = '{
        valid : 1'b1,
        cs : '{
            ST_SEL         : 1'b0,
            MODRM_NEEDED   : 1'b1,
            RM_IS_DR       : 1'b0,
            LD_OP          : 1'b1,
            ST_OP          : 1'b0,
            SWITCH_LD_ADDY : 1'b0,
            dr_id          : ETR,
            sr_id          : ESI,
            dr_rd          : 1'b1,
            sr_rd          : 1'b1,
            dr_wr          : 1'b1,
            sr_wr          : 1'b0,
			eax_wr			: 1'b0,
			eax_rd			: 1'b0,
			MOVS_OP			: 1'b0,
            datasize       : 2'b10,
            will_mod_zf    : 1'b0,
            seg_1_valid    : 1'b0,
            seg_0_id       : DS,
            seg_1_id       : DS,
            special_modrm_bs: 1'b0,
            special_br      : 1'b0
        },
        dc_cs : '{
            LD_OP     : 1'b1,
            ST_OP     : 1'b0,
            dr_upper8    : 1'b0,
            sr_upper8   : 1'b0,
            datasize  : 2'b10
        },
        mem_cs : '{
            ST_OP : 1'b0,
            LD_OP : 1'b1
        },
        exe_cs : '{
            ST_OP               : 1'b0,
            OP_TYPE             : MOV,
            alu_inputA_sel      : DR_REGISTER,
            alu_inputB_sel      : BUFFER,
            branch_target_sel   : NO_EXE,
            shift_by_one        : 1'b0,
            br_ucond            : 1'b0,
            relative_branch     : 1'b0,
            special_br          : 1'b0,
            is_far              : 1'b0,
            is_call             : 1'b0,
            second_flag_needed  : 1'b0,
            rep_no_zf_update    : 0

        },
        wb_cs : '{
            ST_OP : 1'b0,
            WB_DR : 1'b1,
            WB_SR : 1'b0,
			WB_EAX: 1'b0
        },
        br_info      : '{default:'0},  
        NEIP         : 32'h0,
        EIP          : 32'h0,
        EAX          : 32'h0,
        imm64        : 64'h00,
        sib_idx_id   : NO_REG,
        sib_base_id  : NO_REG,
        sib_needed   : 1'b0,
        sib_scale    : 8'h0,
        disp_needed  : 1'b0,
        disp_size    : 1'b0,
        displacement : 32'h0
    };









    //add es:(%edi), %etr
    assign cmp1 = '{
        valid : 1'b1,
        cs : '{
            ST_SEL         : 1'b0,
            MODRM_NEEDED   : 1'b1,
            RM_IS_DR       : 1'b0,
            LD_OP          : 1'b1,
            ST_OP          : 1'b0,
            SWITCH_LD_ADDY : 1'b0,
            dr_id          : ETR,
            sr_id          : EDI,
            dr_rd          : 1'b1,
            sr_rd          : 1'b1,
            dr_wr          : 1'b1,
            sr_wr          : 1'b0,
			eax_wr			: 1'b0,
			eax_rd			: 1'b0,
			MOVS_OP			: 1'b0,
            datasize       : 2'b10,
            will_mod_zf    : 1'b1,
            seg_1_valid    : 1'b0,
            seg_0_id       : ES,
            seg_1_id       : DS,
            special_modrm_bs: 1'b0,
            special_br      : 1'b0
        },
        dc_cs : '{
            LD_OP     : 1'b1,
            ST_OP     : 1'b0,
            dr_upper8    : 1'b0,
            sr_upper8   : 1'b0,
            datasize  : 2'b10
        },
        mem_cs : '{
            ST_OP : 1'b0,
            LD_OP : 1'b1
        },
        exe_cs : '{
            ST_OP               : 1'b0,
            OP_TYPE             : control_store_pkg::REP_CMP,
            alu_inputA_sel      : DR_REGISTER,
            alu_inputB_sel      : BUFFER,
            branch_target_sel   : NO_EXE,
            shift_by_one        : 1'b0,
            br_ucond            : 1'b0,
            relative_branch     : 1'b0,
            special_br          : 1'b0,
            is_far              : 1'b0,
            is_call             : 1'b0,
            second_flag_needed  : 1'b0,
            rep_no_zf_update    : 1'b0
        },
        wb_cs : '{
            ST_OP : 1'b0,
            WB_DR : 1'b1,
            WB_SR : 1'b0,
			WB_EAX: 1'b0
        },
        br_info      : '{default:'0},  
        NEIP         : 32'h0,
        EIP          : 32'h0,
        EAX          : 32'h0,
        imm64        : 64'h00,
        sib_idx_id   : NO_REG,
        sib_base_id  : NO_REG,
        sib_needed   : 1'b0,
        sib_scale    : 8'h0,
        disp_needed  : 1'b0,
        disp_size    : 1'b0,
        displacement : 32'h0
    };








    //add_df %edi, %esi
    assign cmp2 = '{
        valid : 1'b1,
        cs : '{
            ST_SEL         : 1'b0,
            MODRM_NEEDED   : 1'b1,
            RM_IS_DR       : 1'b1,
            LD_OP          : 1'b0,
            ST_OP          : 1'b0,
            SWITCH_LD_ADDY : 1'b0,
            dr_id          : ESI,
            sr_id          : EDI,
            dr_rd          : 1'b1,
            sr_rd          : 1'b1,
            dr_wr          : 1'b1,
            sr_wr          : 1'b1,
			eax_wr			: 1'b0,
			eax_rd			: 1'b0,
			MOVS_OP			: 1'b0,
            datasize       : 2'b10,
            will_mod_zf    : 1'b0,
            seg_1_valid    : 1'b0,
            seg_0_id       : DS,
            seg_1_id       : DS,
            special_modrm_bs: 1'b0,
            special_br      : 1'b0
        },
        dc_cs : '{
            LD_OP     : 1'b1,
            ST_OP     : 1'b0,
            dr_upper8    : 1'b0,
            sr_upper8   : 1'b0,
            datasize  : 2'b10
        },
        mem_cs : '{
            ST_OP : 1'b0,
            LD_OP : 1'b1
        },
        exe_cs : '{
            ST_OP               : 1'b0,
            OP_TYPE             : ADD_DF,
            alu_inputA_sel      : DR_REGISTER,
            alu_inputB_sel      : SR_REGISTER,
            branch_target_sel   : NO_EXE,
            shift_by_one        : 1'b0,
            br_ucond            : 1'b0,
            relative_branch     : 1'b0,
            special_br          : 1'b0,
            is_far              : 1'b0,
            is_call             : 1'b0,
            second_flag_needed  : 1'b0,
            rep_no_zf_update    : 0
        },
        wb_cs : '{
            ST_OP : 1'b0,
            WB_DR : 1'b1,
            WB_SR : 1'b1,
    		WB_EAX: 1'b0
        },
        br_info      : '{default:'0},  
        NEIP         : 32'h0,
        EIP          : 32'h0,
        EAX          : 32'h0,
        imm64        : 64'h00,
        sib_idx_id   : NO_REG,
        sib_base_id  : NO_REG,
        sib_needed   : 1'b0,
        sib_scale    : 8'h0,
        disp_needed  : 1'b0,
        disp_size    : 1'b0,
        displacement : 32'h0
    };


endmodule