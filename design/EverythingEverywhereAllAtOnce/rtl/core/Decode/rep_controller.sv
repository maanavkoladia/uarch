import RegisterRead_pkg::*;
module rep_controller (
    input wire clk, rst,
    input bool rep_prefix,
    input bool mov_inst,
    input bool cmp_inst,
    input bool clear_zf, set_zf,
    input uint32_t ecx,
    input bool ecx_sb,
    input bool zf_flag,
    input bool stall,
    input bool flush,
    output rr_latches_general_t rep_latches,
    output bool clear_rep
);

    bool continue_mov, continue_cmp;
    assign continue_mov = !ecx_sb && ecx != 32'b0;
    assign continue_cmp = continue_mov && (zf_sb.counter == 0) && !zf_flag;

    regsb_entry_t zf_sb;

    logic [2:0] inst_select;
    bool s0, s1, s2, s3, set_rep;
    rep_fsm fsm_rep(.clk(clk), .rst(rst), .cont_mov_i(continue_mov), .cont_cmp_i(continue_cmp), 
        .rep_prefix_i(rep_prefix), .cs_mov_i(mov_inst), .cs_cmp_i(cmp_inst), .stall_i(stall),
        .S_0(s0), .S_1(s1), .S_2(s2), .S_3(s3), .set_rep_o(set_rep),
        .clear_rep_o(clear_rep), .select_line2_o(inst_select[2]),
        .select_line1_o(inst_select[1]), .select_line0_o(inst_select[0])
    );

    always_ff @(posedge clk) begin
        if(!rst) begin
            zf_sb.counter <= 8'b0;
        end
        else begin
            if(flush) zf_sb.counter <= 8'b0;
            else begin
                case ({set_zf, clear_zf})
                    2'b00: zf_sb <= zf_sb;
                    2'b01: zf_sb.counter <= (zf_sb.counter == 0) ? zf_sb.counter : zf_sb.counter - 1;
                    2'b10: zf_sb.counter <= (zf_sb.counter == 8'hFF) ? zf_sb.counter : zf_sb.counter + 1;
                    2'b11: zf_sb <= zf_sb;
                endcase
            end
        end
    end


    rr_latches_general_t idle_output;
    rr_latches_general_t movs_edi_esi;  //mov0
    rr_latches_general_t decrement_ecx; //mov1
    rr_latches_general_t add_df_edi;    //mov2/cmp3
    rr_latches_general_t add_df_esi;    //mov3/cmp4
    rr_latches_general_t mov_etr;       //cmp0
    rr_latches_general_t add_etr;       //cmp1
    rr_latches_general_t add_nf;        //cmp2

    always_comb begin
        case (inst_select)
            3'b000: rep_latches = idle_output;
            3'b001: rep_latches = movs_edi_esi;
            3'b010: rep_latches = decrement_ecx;
            3'b011: rep_latches = add_df_edi;
            3'b100: rep_latches = add_df_esi;
            3'b101: rep_latches = mov_etr;
            3'b110: rep_latches = add_etr;
            3'b111: rep_latches = add_nf;
        endcase
    end

        
    
    
    assign idle_output = '{
        valid : 1'b1,
        cs : '{
            ST_SEL         : 1'b0,
            MODRM_NEEDED   : 1'b0,
            RM_IS_DR       : 1'b0,
            LD_OP          : 1'b0,
            ST_OP          : 1'b0,
            dr_id          : NO_REG,
            sr_id          : NO_REG,
            dr_rd          : 1'b0,
            sr_rd          : 1'b0,
            dr_wr          : 1'b0,
            sr_wr          : 1'b0,
			eax_wr			: 1'b0,
			eax_rd			: 1'b0,
            datasize       : 2'b00,
            will_mod_zf    : 1'b0,
            seg_1_valid    : 1'b0,
            seg_0_id       : NO_REG,
            seg_1_id       : NO_REG
        },
        dc_cs : '{
            LD_OP     : 1'b0,
            ST_OP     : 1'b0,
            dr_upper8    : 1'b0,
            sr_upper8   : 1'b0,
            datasize  : 2'b00
        },
        mem_cs : '{
            ST_OP : 1'b0,
            LD_OP : 1'b0
        },
        exe_cs : '{
            ST_OP               : 1'b0,
            OP_TYPE             : ADD,
            alu_inputA_sel      : NO_EXE,
            alu_inputB_sel      : NO_EXE,
            branch_target_sel   : NO_EXE,
            shift_by_one        : 1'b0,
            br_ucond            : 1'b0,
            relative_branch     : 1'b0,
            special_br          : 1'b0,
            is_far              : 1'b0,
            second_flag_needed  : 1'b0
        },
        wb_cs : '{
            ST_OP : 1'b0,
            WB_DR : 1'b0,
            WB_SR : 1'b0,
			WB_EAX			: 1'b0
        },
        br_info      : '{default:'0},  // per your requirement
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





    assign movs_edi_esi = '{
        valid : 1'b1,
        cs : '{
            ST_SEL         : 1'b0,
            MODRM_NEEDED   : 1'b0,
            RM_IS_DR       : 1'b0,
            LD_OP          : 1'b0,
            ST_OP          : 1'b0,
            dr_id          : NO_REG,
            sr_id          : NO_REG,
            dr_rd          : 1'b0,
            sr_rd          : 1'b0,
            dr_wr          : 1'b0,
            sr_wr          : 1'b0,
			eax_wr			: 1'b0,
			eax_rd			: 1'b0,
            datasize       : 2'b00,
            will_mod_zf    : 1'b0,
            seg_1_valid    : 1'b0,
            seg_0_id       : NO_REG,
            seg_1_id       : NO_REG
        },
        dc_cs : '{
            LD_OP     : 1'b0,
            ST_OP     : 1'b0,
            dr_upper8    : 1'b0,
            sr_upper8 : 1'b0,
            datasize  : 2'b00
        },
        mem_cs : '{
            ST_OP : 1'b0,
            LD_OP : 1'b0
        },
        exe_cs : '{
            ST_OP               : 1'b0,
            OP_TYPE             : ADD,
            alu_inputA_sel      : NO_EXE,
            alu_inputB_sel      : NO_EXE,
            branch_target_sel   : NO_EXE,
            shift_by_one        : 1'b0,
            br_ucond            : 1'b0,
            relative_branch     : 1'b0,
            special_br          : 1'b0,
            is_far              : 1'b0,
            second_flag_needed  : 1'b0
        },
        wb_cs : '{
            ST_OP : 1'b0,
            WB_DR : 1'b0,
            WB_SR : 1'b0,
			WB_EAX			: 1'b0
        },
        br_info      : '{default:'0},  // per your requirement
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





    assign decrement_ecx = '{
        valid : 1'b1,
        cs : '{
            ST_SEL         : 1'b0,
            MODRM_NEEDED   : 1'b0,
            RM_IS_DR       : 1'b0,
            LD_OP          : 1'b0,
            ST_OP          : 1'b0,
            dr_id          : NO_REG,
            sr_id          : NO_REG,
            dr_rd          : 1'b0,
            sr_rd          : 1'b0,
            dr_wr          : 1'b0,
            sr_wr          : 1'b0,
			eax_wr			: 1'b0,
			eax_rd			: 1'b0,
            datasize       : 2'b00,
            will_mod_zf    : 1'b0,
            seg_1_valid    : 1'b0,
            seg_0_id       : NO_REG,
            seg_1_id       : NO_REG
        },
        dc_cs : '{
            LD_OP     : 1'b0,
            ST_OP     : 1'b0,
            dr_upper8    : 1'b0,
            sr_upper8   : 1'b0,
            datasize  : 2'b00
        },
        mem_cs : '{
            ST_OP : 1'b0,
            LD_OP : 1'b0
        },
        exe_cs : '{
            ST_OP               : 1'b0,
            OP_TYPE             : ADD,
            alu_inputA_sel      : NO_EXE,
            alu_inputB_sel      : NO_EXE,
            branch_target_sel   : NO_EXE,
            shift_by_one        : 1'b0,
            br_ucond            : 1'b0,
            relative_branch     : 1'b0,
            special_br          : 1'b0,
            is_far              : 1'b0,
            second_flag_needed  : 1'b0
        },
        wb_cs : '{
            ST_OP : 1'b0,
            WB_DR : 1'b0,
            WB_SR : 1'b0,
			WB_EAX			: 1'b0
        },
        br_info      : '{default:'0},  // per your requirement
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





    assign add_df_edi = '{
        valid : 1'b1,
        cs : '{
            ST_SEL         : 1'b0,
            MODRM_NEEDED   : 1'b0,
            RM_IS_DR       : 1'b0,
            LD_OP          : 1'b0,
            ST_OP          : 1'b0,
            dr_id          : NO_REG,
            sr_id          : NO_REG,
            dr_rd          : 1'b0,
            sr_rd          : 1'b0,
            dr_wr          : 1'b0,
            sr_wr          : 1'b0,
			eax_wr			: 1'b0,
			eax_rd			: 1'b0,
            datasize       : 2'b00,
            will_mod_zf    : 1'b0,
            seg_1_valid    : 1'b0,
            seg_0_id       : NO_REG,
            seg_1_id       : NO_REG
        },
        dc_cs : '{
            LD_OP     : 1'b0,
            ST_OP     : 1'b0,
            dr_upper8 	 : 1'b0,
			sr_upper8 	 : 1'b0,
            datasize  : 2'b00
        },
        mem_cs : '{
            ST_OP : 1'b0,
            LD_OP : 1'b0
        },
        exe_cs : '{
            ST_OP               : 1'b0,
            OP_TYPE             : ADD,
            alu_inputA_sel      : NO_EXE,
            alu_inputB_sel      : NO_EXE,
            branch_target_sel   : NO_EXE,
            shift_by_one        : 1'b0,
            br_ucond            : 1'b0,
            relative_branch     : 1'b0,
            special_br          : 1'b0,
            is_far              : 1'b0,
            second_flag_needed  : 1'b0
        },
        wb_cs : '{
            ST_OP : 1'b0,
            WB_DR : 1'b0,
            WB_SR : 1'b0,
			WB_EAX			: 1'b0
        },
        br_info      : '{default:'0},  // per your requirement
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





    assign add_df_esi = '{
        valid : 1'b1,
        cs : '{
            ST_SEL         : 1'b0,
            MODRM_NEEDED   : 1'b0,
            RM_IS_DR       : 1'b0,
            LD_OP          : 1'b0,
            ST_OP          : 1'b0,
            dr_id          : NO_REG,
            sr_id          : NO_REG,
            dr_rd          : 1'b0,
            sr_rd          : 1'b0,
            dr_wr          : 1'b0,
            sr_wr          : 1'b0,
			eax_wr			: 1'b0,
			eax_rd			: 1'b0,
            datasize       : 2'b00,
            will_mod_zf    : 1'b0,
            seg_1_valid    : 1'b0,
            seg_0_id       : NO_REG,
            seg_1_id       : NO_REG
        },
        dc_cs : '{
            LD_OP     : 1'b0,
            ST_OP     : 1'b0,
            dr_upper8 	 : 1'b0,
			sr_upper8 	 : 1'b0,
            datasize  : 2'b00
        },
        mem_cs : '{
            ST_OP : 1'b0,
            LD_OP : 1'b0
        },
        exe_cs : '{
            ST_OP               : 1'b0,
            OP_TYPE             : ADD,
            alu_inputA_sel      : NO_EXE,
            alu_inputB_sel      : NO_EXE,
            branch_target_sel   : NO_EXE,
            shift_by_one        : 1'b0,
            br_ucond            : 1'b0,
            relative_branch     : 1'b0,
            special_br          : 1'b0,
            is_far              : 1'b0,
            second_flag_needed  : 1'b0
        },
        wb_cs : '{
            ST_OP : 1'b0,
            WB_DR : 1'b0,
            WB_SR : 1'b0,
			WB_EAX			: 1'b0
        },
        br_info      : '{default:'0},  // per your requirement
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





    assign mov_etr = '{
        valid : 1'b1,
        cs : '{
            ST_SEL         : 1'b0,
            MODRM_NEEDED   : 1'b0,
            RM_IS_DR       : 1'b0,
            LD_OP          : 1'b0,
            ST_OP          : 1'b0,
            dr_id          : NO_REG,
            sr_id          : NO_REG,
            dr_rd          : 1'b0,
            sr_rd          : 1'b0,
            dr_wr          : 1'b0,
            sr_wr          : 1'b0,
			eax_wr			: 1'b0,
			eax_rd			: 1'b0,
            datasize       : 2'b00,
            will_mod_zf    : 1'b0,
            seg_1_valid    : 1'b0,
            seg_0_id       : NO_REG,
            seg_1_id       : NO_REG
        },
        dc_cs : '{
            LD_OP     : 1'b0,
            ST_OP     : 1'b0,
            dr_upper8 	 : 1'b0,
			sr_upper8 	 : 1'b0,
            datasize  : 2'b00
        },
        mem_cs : '{
            ST_OP : 1'b0,
            LD_OP : 1'b0
        },
        exe_cs : '{
            ST_OP               : 1'b0,
            OP_TYPE             : ADD,
            alu_inputA_sel      : NO_EXE,
            alu_inputB_sel      : NO_EXE,
            branch_target_sel   : NO_EXE,
            shift_by_one        : 1'b0,
            br_ucond            : 1'b0,
            relative_branch     : 1'b0,
            special_br          : 1'b0,
            is_far              : 1'b0,
            second_flag_needed  : 1'b0
        },
        wb_cs : '{
            ST_OP : 1'b0,
            WB_DR : 1'b0,
            WB_SR : 1'b0,
			WB_EAX			: 1'b0
        },
        br_info      : '{default:'0},  // per your requirement
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





    assign add_etr = '{
        valid : 1'b1,
        cs : '{
            ST_SEL         : 1'b0,
            MODRM_NEEDED   : 1'b0,
            RM_IS_DR       : 1'b0,
            LD_OP          : 1'b0,
            ST_OP          : 1'b0,
            dr_id          : NO_REG,
            sr_id          : NO_REG,
            dr_rd          : 1'b0,
            sr_rd          : 1'b0,
            dr_wr          : 1'b0,
            sr_wr          : 1'b0,
			eax_wr			: 1'b0,
			eax_rd			: 1'b0,
            datasize       : 2'b00,
            will_mod_zf    : 1'b0,
            seg_1_valid    : 1'b0,
            seg_0_id       : NO_REG,
            seg_1_id       : NO_REG
        },
        dc_cs : '{
            LD_OP     : 1'b0,
            ST_OP     : 1'b0,
            dr_upper8 	 : 1'b0,
			sr_upper8 	 : 1'b0,
            datasize  : 2'b00
        },
        mem_cs : '{
            ST_OP : 1'b0,
            LD_OP : 1'b0
        },
        exe_cs : '{
            ST_OP               : 1'b0,
            OP_TYPE             : ADD,
            alu_inputA_sel      : NO_EXE,
            alu_inputB_sel      : NO_EXE,
            branch_target_sel   : NO_EXE,
            shift_by_one        : 1'b0,
            br_ucond            : 1'b0,
            relative_branch     : 1'b0,
            special_br          : 1'b0,
            is_far              : 1'b0,
            second_flag_needed  : 1'b0
        },
        wb_cs : '{
            ST_OP : 1'b0,
            WB_DR : 1'b0,
            WB_SR : 1'b0,
			WB_EAX			: 1'b0
        },
        br_info      : '{default:'0},  // per your requirement
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





    assign add_nf = '{
        valid : 1'b1,
        cs : '{
            ST_SEL         : 1'b0,
            MODRM_NEEDED   : 1'b0,
            RM_IS_DR       : 1'b0,
            LD_OP          : 1'b0,
            ST_OP          : 1'b0,
            dr_id          : NO_REG,
            sr_id          : NO_REG,
            dr_rd          : 1'b0,
            sr_rd          : 1'b0,
            dr_wr          : 1'b0,
            sr_wr          : 1'b0,
			eax_wr			: 1'b0,
			eax_rd			: 1'b0,
            datasize       : 2'b00,
            will_mod_zf    : 1'b0,
            seg_1_valid    : 1'b0,
            seg_0_id       : NO_REG,
            seg_1_id       : NO_REG
        },
        dc_cs : '{
            LD_OP     : 1'b0,
            ST_OP     : 1'b0,
            dr_upper8 	 : 1'b0,
			sr_upper8 	 : 1'b0,
            datasize  : 2'b00
        },
        mem_cs : '{
            ST_OP : 1'b0,
            LD_OP : 1'b0
        },
        exe_cs : '{
            ST_OP               : 1'b0,
            OP_TYPE             : ADD,
            alu_inputA_sel      : NO_EXE,
            alu_inputB_sel      : NO_EXE,
            branch_target_sel   : NO_EXE,
            shift_by_one        : 1'b0,
            br_ucond            : 1'b0,
            relative_branch     : 1'b0,
            special_br          : 1'b0,
            is_far              : 1'b0,
            second_flag_needed  : 1'b0
        },
        wb_cs : '{
            ST_OP : 1'b0,
            WB_DR : 1'b0,
            WB_SR : 1'b0,
			WB_EAX			: 1'b0
        },
        br_info      : '{default:'0},  // per your requirement
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


endmodule