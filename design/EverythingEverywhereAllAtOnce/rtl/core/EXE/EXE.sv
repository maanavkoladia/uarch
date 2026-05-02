import core_common_pkg::*;
import core_stage_latches_pkg::*;
import common_pkg::*;
import control_store_pkg::*;

module EXE (
    input wire clk,
    input wire rst,

    input exe_latches_t latches_i,
    input wb_outputs_t  wb_outs_i,
    input rr_outputs_t rr_outs_i,

    output wb_latches_t  wb_latches_next_o,
    output exe_outputs_t outs_o
);


    //==========================================================================
    // SIGNAL DECLARATIONS
    //==========================================================================
    bool clr_ZF_sb;
    bool wb_stage_we_valid_unit_o;
    bool wb_stage_next_vaild_o;
    wb_valid_logic wb_valid_logic_unit (
        .WB_we_o(wb_stage_we_valid_unit_o),
        .N_WB_V_o(wb_stage_next_vaild_o),
        .EXE_V_i(latches_i.valid),
        .WB_stall_i(wb_outs_i.wb_stall)
    );



    // --- Control Signals ---
    exe_cs_operation_type_e           op_type;
    logic                       [3:0] data_size;
    logic                       [3:0] sr_data_size_vec;
    uint32_t                          flags_reg;
    bool                              stall_flop;

    // --- ALU Input Buffers ---
    uint64_t                          sr_data;
    uint64_t                          dr_data;
    uint32_t                          eax_data;
    uint64_t                          srA;  // ALU input A (DR/MEM/IMM)
    uint64_t                          srB;  // ALU input B (SR/MEM/IMM)
    uint32_t                          br_sel;  // Branch source selection

    // --- Next Latch Signals ---
    byte_t                            res_buf_next                       [CACHE_LINES_SIZE_B*2];
    uint16_t                          bit_vec_0_next;
    uint16_t                          bit_vec_1_next;
    uint64_t                          dr_next;
    uint64_t                          sr_next;

    // --- Branch Resolution Outputs ---
    exe_br_resolution_outputs_t       branch_resolution_o;

    // --- Result Selection Outputs ---
    uint64_t                          res_buf_selected;


    //==========================================================================
    // FUNCTIONAL UNIT OUTPUT WIRES
    //==========================================================================

    // AAA Outputs
    uint64_t                          aaa_dr_o;

    // ADC Outputs
    uint64_t                          adc_dr_o;
    uint64_t                          adc_res_buf_o;

    // ADD Outputs
    uint64_t                          add_dr_o;
    uint64_t                          add_res_buf_o;

    //ADD_DF Outputs
    uint64_t                          add_df_dr_o;
    uint64_t                          add_df_sr_o;

    // AND Outputs
    uint64_t                          and_dr_o;
    uint64_t                          and_res_buf_o;

    // BSF Outputs
    uint64_t                          bsf_dr_o;
    uint64_t                          bsf_res_buf_o;

    // CALL Outputs
    uint64_t                          call_sr_o;
    uint64_t                          call_res_buf;

    // CMPXCHG Outputs
    uint64_t                          cmpxchg_EAX_o;
    uint64_t                          cmpxchg_dr_o;
    uint64_t                          cmpxchg_buf_o;

    // FAR_CALL Outputs
    uint64_t                          far_call_sr_o;
    uint64_t                          far_call_res_buf;
    uint64_t                          far_call_dr_o;

    //EXP_CALL Outputs
    uint64_t                          exp_call_sr_o;
    uint64_t                          exp_call_res_buf;
    uint64_t                          exp_call_dr_o;
    uint32_t                          exp_call_eip;
    uint64_t                          exp_ld_buf_o;



    // IRETD Outputs
    uint64_t                          iretd_cs_o;
    uint64_t                          iretd_stack_ptr_o;

    // MOV Outputs
    uint64_t                          mov_dr_o;
    uint64_t                          mov_res_buf_o;

    //MOVS Outputs
    uint64_t                          mov_s_dr_o;
    uint64_t                          mov_s_sr_o;
    uint64_t                          mov_s_res_buf_o;

    // NOT Outputs
    uint64_t                          not_dr_o;
    uint64_t                          not_res_buf_o;

    // OR Outputs
    uint64_t                          or_dr_o;
    uint64_t                          or_res_buf_o;

    // PACKSSDW Outputs
    uint64_t                          packssdw_dr_o;

    // PACKSSWB Outputs
    uint64_t                          packsswb_dr_o;

    // PADDD Outputs
    uint64_t                          paddd_dr_o;

    // PADDW Outputs
    uint64_t                          paddw_dr_o;

    // PAVGB Outputs
    uint64_t                          pavgb_dr_o;

    // PAVGW Outputs
    uint64_t                          pavgw_dr_o;

    // POP Outputs
    uint64_t                          pop_dr_o;
    uint64_t                          pop_sr_o;
    uint64_t                          pop_res_buf;

    // PUSH Outputs
    uint64_t                          push_res_buf;
    uint64_t                          push_sr_o;

    // RET_FAR_IMM Outputs
    uint64_t                          ret_far_imm_dr_o;
    uint64_t                          ret_far_imm_sr_o;

    // RET_FAR Outputs
    uint64_t                          ret_far_cs_o;
    uint64_t                          ret_far_next_ptr_o;

    // RET_IMM Outputs
    uint64_t                          ret_imm_sr_o;

    // RET Outputs
    uint64_t                          ret_sr_o;

    // SAL Outputs
    uint64_t                          sal_dr_o;
    uint64_t                          sal_res_buf_o;

    // SAR Outputs
    uint64_t                          sar_dr_o;
    uint64_t                          sar_res_buf_o;

    // SBB Outputs
    uint64_t                          sbb_dr_o;
    uint64_t                          sbb_res_buf_o;

    // XCHG Outputs
    uint64_t                          xchg_dr_o;
    uint64_t                          xchg_sr_o;
    uint64_t                          xchg_res_buf;

    //==========================================================================
    // FUNCTIONAL UNIT FLAG OUTPUTS
    //==========================================================================

    // AAA Flags
    logic aaa_af_o, aaa_cf_o;

    // ADC Flags
    logic adc_af_o, adc_cf_o, adc_of_o, adc_pf_o, adc_sf_o, adc_zf_o;

    // ADD Flags
    logic add_af_o, add_cf_o, add_of_o, add_pf_o, add_sf_o, add_zf_o;

    // AND Flags
    logic and_of_o, and_pf_o, and_sf_o, and_zf_o, and_cf_o, and_af_o;

    // BSF Flags
    logic bsf_zf_o;

    // CMP Flags
    logic cmp_cf_o, cmp_pf_o, cmp_af_o, cmp_zf_o, cmp_sf_o, cmp_of_o;

    // CMPXCHG Flags
    logic cmpxchg_cf_o, cmpxchg_pf_o, cmpxchg_af_o, cmpxchg_zf_o, cmpxchg_sf_o, cmpxchg_of_o;

    // OR Flags
    logic or_cf_o, or_pf_o, or_zf_o, or_sf_o, or_of_o, or_af_o;

    // SAL Flags
    logic sal_cf_o, sal_pf_o, sal_zf_o, sal_sf_o, sal_of_o, sal_af_o;

    // SAR Flags
    logic sar_cf_o, sar_pf_o, sar_zf_o, sar_sf_o, sar_of_o, sar_af_o;

    // SBB Flags
    logic sbb_cf_o, sbb_pf_o, sbb_af_o, sbb_zf_o, sbb_sf_o, sbb_of_o;

    // IRETD Flags
    logic iretd_cf_o, iretd_pf_o, iretd_af_o, iretd_zf_o, iretd_sf_o, iretd_of_o;

    // REP_CMP
    logic rep_cmp_zf_o;

    //reg writeback to rr logic outputs
    reg_ids_e dr0_id_o;
    bool dr0_we_o;
    uint64_t dr0_data_o;
    reg_ids_e dr1_id_o;
    bool dr1_we_o;
    uint64_t dr1_data_o;

    //jump far new cs
    uint64_t far_jmp_dr_o;

    //==========================================================================
    // CONTROL SIGNAL ASSIGNMENTS
    //==========================================================================

    assign op_type = latches_i.cs.OP_TYPE;
    assign data_size = latches_i.data_size_vec;
    assign sr_data_size_vec = latches_i.sr_data_size_vec;

    assign dr_data = rr_outs_i.regFileValues[latches_i.dr_id];
    assign sr_data = rr_outs_i.regFileValues[latches_i.sr_id];
    assign eax_data = rr_outs_i.regFileValues[EAX];
    //assign dr_data = latches_i.dr_data;
    //assign sr_data = latches_i.sr_data;
    //assign eax_data = latches_i.EAX;

    //==========================================================================
    // NEXT LATCH ASSIGNMENT
    //==========================================================================

    assign wb_latches_next_o = '{
            valid: wb_stage_next_vaild_o,
            cs: latches_i.wb_cs,
            ST_XCL: latches_i.ST_XCL,
            ST_PADDR_0: latches_i.ST_PADDR_0,
            ST_BIT_VEC_0: bit_vec_0_next,
            ST_PADDR_1: latches_i.ST_PADDR_1,
            ST_BIT_VEC_1: bit_vec_1_next,
            MIO: latches_i.MIO,
            EIP: latches_i.EIP,
            res_buf: res_buf_next,
            sr_id: latches_i.sr_id,
            sr_data: sr_next,
            dr_id: latches_i.dr_id,
            dr_data: dr_next,
            EAX: latches_i.wb_cs.WB_EAX ? cmpxchg_EAX_o : eax_data
    };

    assign outs_o = '{
        valid: latches_i.valid,
        br_res_out: branch_resolution_o,

        //new reg writeback in execute
        DR_0_we: dr0_we_o,
        DR_0_id: dr0_id_o,
        DR_0_data: dr0_data_o,
        DR_1_we: dr1_we_o,
        DR_1_id: dr1_id_o,
        DR_1_data: dr1_data_o,

        ZF: flags_reg[ZF_IDX],
        clr_ZF_sb: clr_ZF_sb && latches_i.valid,
        ST_OP: latches_i.cs.ST_OP,
        ST_XCL: latches_i.ST_XCL,
        ST_PADDR_0: latches_i.ST_PADDR_0,
        ST_PADDR_1: latches_i.ST_PADDR_1,
        wb_stage_latch_we: wb_stage_we_valid_unit_o
    };

    //==========================================================================
    // ALU INPUT SELECTION
    //==========================================================================

    alu_input_sel u_alu_input_sel (
        .ld_addr_0     (latches_i.ld_addy),
        .res_buf       (latches_i.ld_buf),
        .imm64         (latches_i.imm64),
        .sr_data       (sr_data),
        .dr_data       (dr_data),
        .EAX           (eax_data),
        .EIP           (latches_i.EIP),
        .NEIP          (latches_i.NEIP),
        .flags         (flags_reg),
        .alu_inputA_sel(latches_i.cs.alu_inputA_sel),
        .alu_inputB_sel(latches_i.cs.alu_inputB_sel),
        .shift_sr_up   (latches_i.shift_sr_up),
        .shift_sr_down (latches_i.shift_sr_down),
        .br_input_sel  (latches_i.cs.branch_target_sel),
        .exp_ld_buf_o  (exp_ld_buf_o),
        .srA_64        (srA),
        .srB_64        (srB),
        .br_sel        (br_sel)
    );


    //==========================================================================
    // RESULT BUFFER SELECTION & LOGIC
    //==========================================================================

    res_buf_sel u_res_buf_sel (
        .op_type           (op_type),
        .adc_res_buf_i     (adc_res_buf_o),
        .add_res_buf_i     (add_res_buf_o),
        .and_res_buf_i     (and_res_buf_o),
        .call_res_buf_i    (call_res_buf),
        .cmpxchg_buf_i     (cmpxchg_buf_o),
        .far_call_res_buf_i(far_call_res_buf),
        .mov_res_buf_i     (mov_res_buf_o),
        .mov_s_res_buf_i   (mov_s_res_buf_o),
        .not_res_buf_i     (not_res_buf_o),
        .or_res_buf_i      (or_res_buf_o),
        .push_res_buf_i    (push_res_buf),
        .pop_res_buf_i     (pop_res_buf),
        .sar_res_buf_i     (sar_res_buf_o),
        .sal_res_buf_i     (sal_res_buf_o),
        .sbb_res_buf_i     (sbb_res_buf_o),
        .xchg_res_buf_i    (xchg_res_buf),
        .exp_call_res_buf_i(exp_call_res_buf),

        .res_buf_o         (res_buf_selected)
    );

    res_buf_logic u_res_buf_logic (
        .res_info_i(res_buf_selected),
        .st_addr_0 (latches_i.ST_PADDR_0),
        .bit_vec_0 (bit_vec_0_next),
        .bit_vec_1 (bit_vec_1_next),
        .ld_buf (latches_i.ld_buf),
        .res_buf   (res_buf_next)
    );

    bit_vec_logic u_bit_vec_logic (
        .st_addr_0(latches_i.ST_PADDR_0),
        .ST_XCL   (latches_i.ST_XCL),
        .data_size(data_size),
        .st_vec0  (bit_vec_0_next),
        .st_vec1  (bit_vec_1_next)
    );


    //==========================================================================
    // DESTINATION & SOURCE REGISTER SELECTION
    //==========================================================================

    dr_sel u_dr_sel (
        .op_type         (op_type),
        .aaa_dr_i        (aaa_dr_o),
        .adc_dr_i        (adc_dr_o),
        .add_dr_i        (add_dr_o),
        .add_df_dr_i     (add_df_dr_o),
        .and_dr_i        (and_dr_o),
        .bsf_dr_i        (bsf_dr_o),
        .cmpxchg_dr_i    (cmpxchg_dr_o),
        .mov_dr_i        (mov_dr_o),
        .mov_s_dr_i      (mov_s_dr_o),
        .not_dr_i        (not_dr_o),
        .or_dr_i         (or_dr_o),
        .packssdw_dr_i   (packssdw_dr_o),
        .packsswb_dr_i   (packsswb_dr_o),
        .paddd_dr_i      (paddd_dr_o),
        .paddw_dr_i      (paddw_dr_o),
        .pavgb_dr_i      (pavgb_dr_o),
        .pavgw_dr_i      (pavgw_dr_o),
        .pop_dr_i        (pop_dr_o),
        .ret_far_dr_i    (ret_far_cs_o),
        .ret_far_imm_dr_i(ret_far_imm_dr_o),
        .far_call_dr_i   (far_call_dr_o),
        .far_jmp_dr_i    (far_jmp_dr_o),
        .sal_dr_i        (sal_dr_o),
        .sar_dr_i        (sar_dr_o),
        .sbb_dr_i        (sbb_dr_o),
        .xchg_dr_i       (xchg_dr_o),
        .exp_call_dr_i   (exp_call_dr_o),
        .dr_data         (dr_data),
        .dr_o            (dr_next)
    );

    sr_sel u_sr_sel (
        .op_type         (op_type),
        .sr_data         (sr_data),
        .add_df_sr_i     (add_df_sr_o),
        .mov_s_sr_i       (mov_s_sr_o),
        .pop_sr_i        (pop_sr_o),
        .push_sr_i       (push_sr_o),
        .ret_far_sr_i    (ret_far_next_ptr_o),
        .ret_far_imm_sr_i(ret_far_imm_sr_o),
        .ret_imm_sr_i    (ret_imm_sr_o),
        .ret_sr_i        (ret_sr_o),
        .xchg_sr_i       (xchg_sr_o),
        .call_sr_i       (call_sr_o),
        .far_call_sr_i   (far_call_sr_o),
        .exp_call_sr_i   (exp_call_sr_o),
        .iretd_sr_i      (iretd_stack_ptr_o),
        .sr_o            (sr_next)
    );

    uint64_t next_EAX;
    assign next_EAX =  latches_i.wb_cs.WB_EAX ? cmpxchg_EAX_o : {32'd0, eax_data};
    reg_wb_logic reg_wb(
         .op_type(op_type),
         .next_dr_data(dr_next),
         .dr_id(latches_i.dr_id),
         .WB_DR(latches_i.wb_cs.WB_DR),
         .next_EAX(next_EAX),
         .next_sr_data(sr_next),
         .sr_id(latches_i.sr_id),
         .WB_EAX(latches_i.wb_cs.WB_EAX),
         .WB_SR(latches_i.wb_cs.WB_SR),
         .valid(latches_i.valid),
         .stall_flop(stall_flop),
         .dr0_id_o(dr0_id_o),
         .dr0_we_o(dr0_we_o),
         .dr0_data_o(dr0_data_o),
         .dr1_id_o(dr1_id_o),
         .dr1_we_o(dr1_we_o),
         .dr1_data_o(dr1_data_o)
    );


    //==========================================================================
    // BRANCH RESOLUTION
    //==========================================================================

    branch_res u_br_res (
        .stage_valid_i       (latches_i.valid),
        .br_info_valid_i     (latches_i.br_info.valid),
        .flush_mask          (stall_flop),
        .br_eip_i            (latches_i.br_info.br_eip),
        .br_xcl_i            (latches_i.br_info.br_xcl),
        .br_pred_taken_i     (latches_i.br_info.br_pred_taken),
        .speculative_target_i(latches_i.br_info.speculative_target),
        .br_ucond_i          (latches_i.cs.br_ucond),
        .relative_branch_i   (latches_i.cs.relative_branch),
        .special_br_i        (latches_i.cs.special_br),
        .is_far_i            (latches_i.cs.is_far),
        .is_call_i           (latches_i.cs.is_call),
        .second_flag_needed_i(latches_i.cs.second_flag_needed),
        .br_source_i         (br_sel),
        .NEIP_i              (latches_i.NEIP),
        .br_rel_target       (latches_i.br_rel_target),
        .exp_target          (exp_call_eip),
        .CF                  (flags_reg[CF_IDX]),
        .ZF                  (flags_reg[ZF_IDX]),
        .outs_o              (branch_resolution_o)
    );


    //==========================================================================
    // CONTROL STORE CHANGE LOGIC
    //==========================================================================


    //==========================================================================
    // FLAGS REGISTER & FLAG OUTPUTS
    //==========================================================================

    // --- Flag Output Signals ---
    logic af_flag_o;
    logic cf_flag_o;
    logic df_flag_o;
    logic of_flag_o;
    logic pf_flag_o;
    logic sf_flag_o;
    logic zf_flag_o;

    // --- Flags Register (Sequential Logic) ---
    always_ff @(posedge clk) begin
        if (!rst) begin
            flags_reg <= 32'h0;
        end else begin
            if(latches_i.valid)begin
                flags_reg[CF_IDX] <= cf_flag_o;
                flags_reg[PF_IDX] <= pf_flag_o;
                flags_reg[AF_IDX] <= af_flag_o;
                flags_reg[ZF_IDX] <= zf_flag_o;
                flags_reg[SF_IDX] <= sf_flag_o;
                flags_reg[DF_IDX] <= df_flag_o;
                flags_reg[OF_IDX] <= of_flag_o;
            end
        end
    end


    //the logic here is that if writeback is stall we dont want to spam flushes. we only want to send out flush signals once
    //now also if wb is stalling we only want to write to the reg file once, so we need to gate the write enable with the stall signal as well.
    always_ff @(posedge clk)begin
        if(!rst)
            stall_flop <= 0;
        else
            stall_flop <= wb_outs_i.wb_stall;
    end


    //==========================================================================
    // FLAG SELECTION LOGIC
    //==========================================================================

    af_flag_sel u_af_flag_sel (
        .and_af      (and_af_o),
        .or_af       (or_af_o),
        .aaa_af      (aaa_af_o),
        .adc_af      (adc_af_o),
        .add_op_af   (add_af_o),
        .sal_op_af   (sal_af_o),
        .sar_op_af   (sar_af_o),
        .cmp_af      (cmp_af_o),
        .cmpxchg_af  (cmpxchg_af_o),
        .sbb_af      (sbb_af_o),
        .iretd_af    (iretd_af_o),
        .curr_af_flag(flags_reg[AF_IDX]),
        .op_type     (op_type),
        .af_flag_o   (af_flag_o)
    );

    cf_flag_sel u_cf_flag_sel (
        .aaa_cf      (aaa_cf_o),
        .adc_cf      (adc_cf_o),
        .add_cf      (add_cf_o),
        .and_cf      (and_cf_o),
        .cmp_cf      (cmp_cf_o),
        .cmpxchg_cf  (cmpxchg_cf_o),
        .or_cf       (or_cf_o),
        .sal_cf      (sal_cf_o),
        .sar_cf      (sar_cf_o),
        .sbb_cf      (sbb_cf_o),
        .iretd_cf    (iretd_cf_o),
        .curr_cf_flag(flags_reg[CF_IDX]),
        .op_type     (op_type),
        .cf_flag_o   (cf_flag_o)
    );

    df_flag_sel u_df_flag_sel (
        .curr_df_flag(flags_reg[DF_IDX]),
        .op_type     (op_type),
        .df_flag_o   (df_flag_o)
    );

    of_flag_sel u_of_flag_sel (
        .adc_of      (adc_of_o),
        .add_of      (add_of_o),
        .and_of      (and_of_o),
        .cmp_of      (cmp_of_o),
        .cmpxchg_of  (cmpxchg_of_o),
        .or_of       (or_of_o),
        .sal_of      (sal_of_o),
        .sar_of      (sar_of_o),
        .sbb_of      (sbb_of_o),
        .iretd_of    (iretd_of_o),
        .op_type     (op_type),
        .curr_of_flag(flags_reg[OF_IDX]),
        .of_flag_o   (of_flag_o)
    );

    pf_flag_sel u_pf_flag_sel (
        .adc_pf      (adc_pf_o),
        .add_pf      (add_pf_o),
        .and_pf      (and_pf_o),
        .cmp_pf      (cmp_pf_o),
        .cmpxchg_pf  (cmpxchg_pf_o),
        .or_pf       (or_pf_o),
        .sal_pf      (sal_pf_o),
        .sar_pf      (sar_pf_o),
        .sbb_pf      (sbb_pf_o),
        .iretd_pf    (iretd_pf_o),
        .op_type     (op_type),
        .curr_pf_flag(flags_reg[PF_IDX]),
        .pf_flag_o   (pf_flag_o)
    );

    sf_flag_sel u_sf_flag_sel (
        .add_sf      (add_sf_o),
        .adc_sf      (adc_sf_o),
        .and_sf      (and_sf_o),
        .cmp_sf      (cmp_sf_o),
        .cmpxchg_sf  (cmpxchg_sf_o),
        .or_sf       (or_sf_o),
        .sal_sf      (sal_sf_o),
        .sar_sf      (sar_sf_o),
        .sbb_sf      (sbb_sf_o),
        .iretd_sf    (iretd_sf_o),
        .op_type     (op_type),
        .curr_sf_flag(flags_reg[SF_IDX]),
        .sf_flag_o   (sf_flag_o)
    );

    zf_flag_sel u_zf_flag_sel (
        .rep_no_zf_update(latches_i.cs.rep_no_zf_update),
        .adc_zf      (adc_zf_o),
        .add_zf      (add_zf_o),
        .and_zf      (and_zf_o),
        .bsf_zf      (bsf_zf_o),
        .cmp_zf      (cmp_zf_o),
        .cmpxchg_zf  (cmpxchg_zf_o),
        .iretd_zf    (iretd_zf_o),
        .or_zf       (or_zf_o),
        .sal_zf      (sal_zf_o),
        .sar_zf      (sar_zf_o),
        .sbb_zf      (sbb_zf_o),
        .rep_cmp_zf  (rep_cmp_zf_o),
        .curr_zf_flag(flags_reg[ZF_IDX]),
        .op_type     (op_type),
        .zf_flag_o   (zf_flag_o),
        .clr_ZF_sb   (clr_ZF_sb)
    );



    //==========================================================================
    // FUNCTIONAL UNITS - ARITHMETIC & LOGIC
    //==========================================================================

    // --- AAA: ASCII Adjust After Addition ---
    aaa_op u_aaa (
        .EAX_in    (srA),
        .AF_flag_in(flags_reg[AF_IDX]),
        .dr_o      (aaa_dr_o),
        .CF        (aaa_cf_o),
        .AF        (aaa_af_o)
    );

    // --- ADC: Add with Carry ---
    adc_op u_adc_op (
        .srA(srA),  //dr_reg / MEM
        .srB(srB),  //sr_reg /MEM / IMM
        .CF_in(flags_reg[CF_IDX]),
        .data_size(data_size),

        .dr_o(adc_dr_o),
        .res_buf_o(adc_res_buf_o),
        .CF(adc_cf_o),
        .PF(adc_pf_o),
        .AF(adc_af_o),
        .ZF(adc_zf_o),
        .SF(adc_sf_o),
        .OF(adc_of_o)
    );

    // --- ADD: Addition ---
    add_op u_add_op (
        .srA      (srA),       //DR_REG/MEM
        .srB      (srB),       //SR_REG/MEM/IMM
        .data_size(data_size),

        .dr_o     (add_dr_o),
        .res_buf_o(add_res_buf_o),
        .ZF       (add_zf_o),
        .SF       (add_sf_o),
        .PF       (add_pf_o),
        .OF       (add_of_o),
        .CF       (add_cf_o),
        .AF       (add_af_o)
    );

    rep_cmp u_rep_cmp_op (
        .srA      (srA),       //DR_REG/MEM
        .srB      (srB),       //SR_REG/MEM/IMM
        .ZF       (rep_cmp_zf_o)
    );

    add_df_op u_add_df_op(
        .srA(srA),
        .srB(srB),
        .curr_df_flag(flags_reg[DF_IDX]),
        .data_size(data_size),
        .dr_o(add_df_dr_o),
        .sr_o(add_df_sr_o)
    );

    // --- AND: Bitwise AND ---
    and_op u_and_op (
        .srA      (srA),       //DR_REG/MEM
        .srB      (srB),       //SR_REG/MEM/IMM
        .data_size(data_size),

        .dr_o     (and_dr_o),
        .res_buf_o(and_res_buf_o),
        .ZF       (and_zf_o),
        .SF       (and_sf_o),
        .PF       (and_pf_o),
        .OF       (and_of_o),
        .CF       (and_cf_o),
        .AF       (and_af_o)
    );

    // --- BSF: Bit Scan Forward ---
    bsf_op u_bsf (
        .srA      (srB),            //SR_REG/MEM
        .data_size(data_size),
        .dr_o     (bsf_dr_o),
        .res_buf_o(bsf_res_buf_o),
        .ZF       (bsf_zf_o)
    );

    // --- CMP: Compare ---
    cmp u_cmp (
        .srA      (srA),
        .srB      (srB),
        .data_size(data_size),
        .CF       (cmp_cf_o),
        .OF       (cmp_of_o),
        .SF       (cmp_sf_o),
        .ZF       (cmp_zf_o),
        .AF       (cmp_af_o),
        .PF       (cmp_pf_o)
    );

    // --- CMPXCHG: Compare and Exchange ---
    cmpxchg_op u_cmpxchg_op (
        .EAX(srB[31:0]),  //srB <- CMPXCHG
        .rm(srA),  //srA <- Buffer or DR
        .r(srB[63:32]), //srB <- CMPXCHG
        .data_size(data_size),
        .sr_data_size_vec(sr_data_size_vec),
        .dr_o(cmpxchg_dr_o),
        .EAX_o(cmpxchg_EAX_o),
        .res_buf(cmpxchg_buf_o),
        .ZF          (cmpxchg_zf_o),
        .SF          (cmpxchg_sf_o),
        .PF          (cmpxchg_pf_o),
        .CF          (cmpxchg_cf_o),
        .OF          (cmpxchg_of_o),
        .AF          (cmpxchg_af_o)
    );

    // --- NOT: Bitwise NOT ---
    not_op u_not_op (
        .srA      (srA),           //SRA <- DR/MEM
        .data_size(data_size),
        .dr_o     (not_dr_o),
        .res_buf_o(not_res_buf_o)
    );

    // --- OR: Bitwise OR ---
    or_op u_or_op (
        .srA      (srA),           //SRA <- DR/MEM
        .srB      (srB),           //SRB <- SR/MEM/IMM
        .data_size(data_size),
        .dr_o     (or_dr_o),
        .res_buf_o(or_res_buf_o),
        .ZF       (or_zf_o),
        .SF       (or_sf_o),
        .PF       (or_pf_o),
        .OF       (or_of_o),
        .CF       (or_cf_o),
        .AF       (or_af_o)
    );

    // --- SAL: Shift Arithmetic Left ---
    sal_op u_sal_op (
        .value_i     (srA),
        .shift_amt_i (srB),
        .data_size   (data_size),
        .sr_data_size_vec(sr_data_size_vec),
        .shift_by_one (latches_i.cs.shift_by_one),
        .curr_zf_flag (flags_reg[ZF_IDX]),
        .curr_sf_flag (flags_reg[SF_IDX]),
        .curr_pf_flag (flags_reg[PF_IDX]),
        .curr_of_flag (flags_reg[OF_IDX]),
        .curr_cf_flag (flags_reg[CF_IDX]),
        .curr_af_flag (flags_reg[AF_IDX]),
        .dr_o        (sal_dr_o),
        .res_buf_o   (sal_res_buf_o),
        .ZF          (sal_zf_o),
        .SF          (sal_sf_o),
        .PF          (sal_pf_o),
        .OF          (sal_of_o),
        .AF          (sal_af_o),
        .CF          (sal_cf_o)
    );

    // --- SAR: Shift Arithmetic Right ---
    sar_op u_sar_op (
        .value_i     (srA),
        .shift_amt_i (srB),
        .data_size   (data_size),
        .shift_by_one (latches_i.cs.shift_by_one),
        .sr_data_size_vec(sr_data_size_vec),
        .curr_zf_flag (flags_reg[ZF_IDX]),
        .curr_sf_flag (flags_reg[SF_IDX]),
        .curr_pf_flag (flags_reg[PF_IDX]),
        .curr_of_flag (flags_reg[OF_IDX]),
        .curr_cf_flag (flags_reg[CF_IDX]),
        .curr_af_flag (flags_reg[AF_IDX]),
        .dr_o        (sar_dr_o),
        .res_buf_o   (sar_res_buf_o),
        .ZF          (sar_zf_o),
        .SF          (sar_sf_o),
        .PF          (sar_pf_o),
        .OF          (sar_of_o),
        .CF          (sar_cf_o),
        .AF          (sar_af_o)
    );

    // --- SBB: Subtract with Borrow ---
    sbb_op u_sbb_op (
        .srA      (srA),
        .srB      (srB),
        .CF_in    (flags_reg[CF_IDX]),
        .data_size(data_size),
        .dr_o     (sbb_dr_o),
        .res_buf_o(sbb_res_buf_o),
        .CF       (sbb_cf_o),
        .PF       (sbb_pf_o),
        .AF       (sbb_af_o),
        .ZF       (sbb_zf_o),
        .SF       (sbb_sf_o),
        .OF       (sbb_of_o)
    );


    //==========================================================================
    // FUNCTIONAL UNITS - DATA MOVEMENT
    //==========================================================================

    // --- MOV: Move Data ---
    mov_op u_mov_op (
        .srA      (srA),
        .srB      (srB),
        .data_size(data_size),
        .op_type  (op_type),
        .curr_cf_flag(flags_reg[CF_IDX]),
        .res_buf_o(mov_res_buf_o),
        .dr_o     (mov_dr_o)
    );

    movs_op u_movs_op (
        .srA      (srA),
        .srB      (srB),
        .data_size(data_size),
        .curr_df_flag(flags_reg[DF_IDX]),
        .res_buf_o(mov_s_res_buf_o),
        .dr_o     (mov_s_dr_o),
        .sr_o     (mov_s_sr_o)
    );

    // --- XCHG: Exchange ---
    xchg_op u_xchg_op (
        .srA      (srA),
        .srB      (srB),
        .data_size(data_size),
        .sr_data_size_vec(sr_data_size_vec),
        .res_buf  (xchg_res_buf),
        .dr_o     (xchg_dr_o),
        .sr_o     (xchg_sr_o)
    );


    //==========================================================================
    // FUNCTIONAL UNITS - CONTROL FLOW
    //==========================================================================

    // --- CALL: Call Procedure ---
    call_op u_call_op (
        .NEIP      (srA),
        .stack_ptr(srB),
        .sr_o     (call_sr_o),
        .res_buf  (call_res_buf)
    );

    // --- FAR_CALL: Far Call ---
    far_call_op u_far_op (
        .neip     (srA[31:0]),
        .segment  (srA[63:32]),
        .stack_ptr(srB),
        .new_cs   ({16'd0,latches_i.imm64[47:32]}),
        .res_buf  (far_call_res_buf),
        .sr_o     (far_call_sr_o),
        .dr_o     (far_call_dr_o)
    );

    exp_call_op u_exp_call_op(
        .idt(exp_ld_buf_o), //harded coded wired in
        .eip(srA[63:32]), // SEGMENT_EIP
        .curr_cs(rr_outs_i.codeSeg_data), // SEGMENT
        .stack_ptr(srB),
        .res_buf(exp_call_res_buf), //old cs and old eip
        .dr_o(exp_call_dr_o), //new cs
        .sr_o(exp_call_sr_o), //stack pointer updated
        .exp_eip(exp_call_eip) //to br_res
    );


    far_jmp_op u_far_jmp_op (
        .op_type  (op_type),
        .srA     (srA),
        .dr_o(far_jmp_dr_o)
    );

    // --- IRETD: Interrupt Return ---
    iretd_op u_iretd_op (
        .cs       (srA[31:0]),
        .flags    (srA[63:32]),
        .stack_ptr(srB),
        .dr_o     (iretd_cs_o),
        .sr_o     (iretd_stack_ptr_o),
        .CF       (iretd_cf_o),
        .PF       (iretd_pf_o),
        .AF       (iretd_af_o),
        .ZF       (iretd_zf_o),
        .SF       (iretd_sf_o),
        .OF       (iretd_of_o)
    );

    // --- RET: Return from Procedure ---
    ret_op u_ret_op (
        .stack_ptr(srB),
        .sr_o     (ret_sr_o)
    );

    // --- RET_IMM: Return with Immediate ---
    ret_imm_op u_ret_imm_op (
        .imm64    (srA),
        .stack_ptr(srB),
        .sr_o     (ret_imm_sr_o)
    );

    // --- RET_FAR: Far Return ---
    ret_far_op u_ret_far_op (
        .cs       (srA[63:32]),
        .stack_ptr(srB),
        .dr_o     (ret_far_cs_o),
        .sr_o     (ret_far_next_ptr_o)
    );

    // --- RET_FAR_IMM: Far Return with Immediate ---
    ret_far_imm u_ret_far_imm (
        .cs       (srA[63:32]),
        .stack_ptr(srB),
        .imm64    (latches_i.imm64),
        .dr_o     (ret_far_imm_dr_o),
        .sr_o     (ret_far_imm_sr_o)
    );


    //==========================================================================
    // FUNCTIONAL UNITS - STACK OPERATIONS
    //==========================================================================

    // --- POP: Pop from Stack ---
    pop_op u_pop_op (
        .value_i(srA),
        .sp_i   (srB),
        .dr_o   (pop_dr_o),
        .sr_o   (pop_sr_o),
        .res_buf(pop_res_buf)
    );

    // --- PUSH: Push to Stack ---
    push_op u_push_op (
        .value  (srA),
        .sp     (srB),
        .data_size_vec(data_size),
        .res_buf(push_res_buf),
        .sr_o   (push_sr_o)
    );


    //==========================================================================
    // FUNCTIONAL UNITS - SIMD/MMX OPERATIONS
    //==========================================================================

    // --- PACKSSDW: Pack with Signed Saturation (Dword to Word) ---
    packssdw u_packssdw (
        .srA (srA),
        .srB (srB),
        .dr_o(packssdw_dr_o)
    );

    // --- PACKSSWB: Pack with Signed Saturation (Word to Byte) ---
    packsswb u_packsswb (
        .srA (srA),
        .srB (srB),
        .dr_o(packsswb_dr_o)
    );

    // --- PADDD: Packed Add Doubleword ---
    paddd u_paddd (
        .srA (srA),
        .srB (srB),
        .dr_o(paddd_dr_o)
    );

    // --- PADDW: Packed Add Word ---
    paddw u_paddw (
        .srA (srA),
        .srB (srB),
        .dr_o(paddw_dr_o)
    );

    // --- PAVGB: Packed Average Byte ---
    pavgb u_pavgb (
        .srA (srA),
        .srB (srB),
        .dr_o(pavgb_dr_o)
    );

    // --- PAVGW: Packed Average Word ---
    pavgw u_pavgw (
        .srA (srA),
        .srB (srB),
        .dr_o(pavgw_dr_o)
    );

endmodule
