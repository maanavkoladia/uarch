import common_pkg::*;
import control_store_pkg::*;

module EXE (
    input wire clk,
    input wire rst,

    input exe_latches_t latches_i,

    //only used for valid logic and stall (no flags)
    input wb_outputs_t wb_outs_i,

    output wb_latches_t  wb_latches_next_o,
    output exe_outputs_t outs_o

);

    uint32_t flags_reg;

    //============================ALU,BR RES, REODER LOGIC======================
    alu_input_sel u_alu_input_sel (
    .ld_addr_0      (),
    .res_buf        (),
    .imm64          (),
    .sr_data        (),
    .dr_data        (),
    .segment        (),
    .NEIP           (),
    .alu_inputA_sel (),
    .alu_inputB_sel (),
    .br_input_sel   (),

    .srA_64         (),
    .srB_64         (),
    .br_sel         ()
);
    //==============================FLAG UPDATE AND WIRES =======================

    logic af_flag_o;
    logic cf_flag_o;
    logic df_flag_o;
    logic of_flag_o;
    logic pf_flag_o;
    logic sf_flag_o;
    logic zf_flag_o;

    always_ff @(posedge clk) begin 
        if(!rst) flags_reg <= 0;
        else begin
            flags_reg[CF_IDX] <= cf_flag_o;
            flags_reg[PF_IDX] <= df_flag_o;
            flags_reg[AF_IDX] <= af_flag_o;
            flags_reg[ZF_IDX] <= zf_flag_o;
            flags_reg[SF_IDX] <= sf_flag_o;
            flags_reg[DF_IDX] <= df_flag_o;
            flags_reg[OF_IDX] <= of_flag_o;
        end        
    end

logic bsf_zf_o;

// CMP
logic cmp_cf_o,cmp_pf_o, cmp_af_o, cmp_zf_o, cmp_sf_o, cmp_of_o;

// CMPXCHG
logic cmpxchg_cf_o, cmpxchg_pf_o, cmpxchg_af_o, cmpxchg_zf_o, cmpxchg_sf_o, cmpxchg_of_o;

// OR
logic or_cf_o, or_pf_o, or_zf_o, or_sf_o, or_of_o;

// SAL
logic sal_cf_o, sal_pf_o, sal_zf_o, sal_sf_o, sal_of_o;

// SAR
logic sar_cf_o, sar_pf_o, sar_zf_o, sar_sf_o, sar_of_o;

// SBB
logic sbb_cf_o, sbb_pf_o, sbb_af_o, sbb_zf_o, sbb_sf_o, sbb_of_o;

// IRETD
logic iretd_cf_o, iretd_pf_o, iretd_af_o, iretd_zf_o, iretd_sf_o, iretd_of_o;


//=============FLAG SEL CONNECTIONS=================
    af_flag_sel u_af_flag_sel (
        .aaa_af        (aaa_af_o),
        .adc_af        (adc_af_o),
        .add_op_af     (add_af_o),
        .cmp_af        (cmp_af_o),
        .cmpxchg_af    (cmpxchg_af_o),
        .sbb_af        (sbb_af_o),
        .iretd_af      (iretd_af_o),
        .curr_af_flag  (flags_reg[AF_IDX]),
        .op_type       (latches_i.op_type),
        .af_flag_o     (af_flag_o)
    );

    cf_flag_sel u_cf_flag_sel (
        .aaa_cf        (aaa_cf_o),
        .adc_cf        (adc_cf_o),
        .add_cf        (add_cf_o),
        .cmp_cf        (cmp_cf_o),
        .cmpxchg_cf    (cmpxchg_cf_o),
        .or_cf         (or_cf_o),
        .sal_cf        (sal_cf_o),
        .sar_cf        (sar_cf_o),
        .sbb_cf        (sbb_cf_o),
        .iretd_cf      (iretd_cf_o),
        .curr_cf_flag  (flags_reg[CF_IDX]),
        .op_type       (latches_i.op_type),
        .cf_flag_o     (cf_flag_o)
    );


    df_flag_sel u_df_flag_sel (
        .std_df        (),
        .curr_df_flag  (),
        .op_type       (),
        .df_flag_o     (df_flag_o)
    );

    of_flag_sel u_of_flag_sel (
        .adc_of        (adc_of_o),
        .add_of        (add_of_o),
        .and_of        (and_of_o),
        .cmp_of        (cmp_of_o),
        .cmpxchg_of    (cmpxchg_of_o),
        .or_of         (or_of_o),
        .sal_of        (sal_of_o),
        .sar_of        (sar_of_o),
        .sbb_of        (sbb_of_o),
        .iretd_of      (iretd_of_o),
        .op_type       (latches_i.op_type),
        .curr_of_flag  (flags_reg[OF_IDX]),
        .of_flag_o     (of_flag_o)
    );

    pf_flag_sel u_pf_flag_sel (
        .adc_pf        (adc_pf_o),
        .add_pf        (add_pf_o),
        .and_pf        (and_pf_o),
        .cmp_pf        (cmp_pf_o),
        .cmpxchg_pf    (cmpxchg_pf_o),
        .or_pf         (or_pf_o),
        .sal_pf        (sal_pf_o),
        .sar_pf        (sar_pf_o),
        .sbb_pf        (sbb_pf_o),
        .iretd_pf      (iretd_pf_o),
        .op_type       (latches_i.op_type),
        .curr_pf_flag  (flags_reg[PF_IDX]),
        .pf_flag_o     (pf_flag_o)
    );

    sf_flag_sel u_sf_flag_sel (
        .add_sf        (add_sf_o),
        .adc_sf        (adc_sf_o),
        .and_sf        (and_sf_o),
        .cmp_sf        (cmp_sf_o),
        .cmpxchg_sf    (cmpxchg_sf_o),
        .or_sf         (or_sf_o),
        .sal_sf        (sal_sf_o),
        .sar_sf        (sar_sf_o),
        .sbb_sf        (sbb_sf_o),
        .iretd_sf      (iretd_sf_o),
        .op_type       (latches_i.op_type),
        .curr_sf_flag  (flags_reg[SF_IDX]),
        .sf_flag_o     (sf_flag_o)
    );


    zf_flag_sel u_zf_flag_sel (
        .adc_zf        (adc_zf_o),
        .add_zf        (add_zf_o),
        .and_zf        (and_zf_o),
        .bsf_zf        (bsf_zf_o),
        .cmp_zf        (cmp_zf_o),
        .cmpxchg_zf    (cmpxchg_zf_o),
        .iretd_zf      (iretd_zf_o),
        .or_zf         (or_zf_o),
        .sal_zf        (sal_zf_o),
        .sar_zf        (sar_zf_o),
        .sbb_zf        (sbb_zf_o),
        .curr_z_flag   (flags_reg[ZF_IDX]),
        .op_type       (latches_i.op_type),
        .zf_flag_o     (zf_flag_o)
    );



    //=============================FUNCTIONAL UNITS===================

    aaa u_aaa (
        .EAX_in (),
        .AF_in (),

        .EAX_out(),    // 64-bit output (ready to write to EAX)
        .CF(),         // Carry flag
        .AF()          // Auxiliary flag
    );

    adc_op u_adc_op (
        .operand1 (),
        .operand2 (),
        .CF_in    (),
        .data_size(),

        .result   (),
        .CF       (),
        .PF       (),
        .AF       (),
        .ZF       (),
        .SF       (),
        .OF       ()
    );


    add_op u_add_op (
        .srA      (), //Always written to 
        .srB      (), //other reg or mem
        .data_size(),

        .dr_o     (),
        .res_buf_o(),
        .ZF       (),
        .SF       (),
        .PF       (),
        .OF       (),
        .CF       (),
        .AF       ()
    );

    and_op u_and_op (
        .srA      (),
        .srB      (),
        .data_size(),

        .dr_o     (),
        .res_buf_o(),
        .ZF       (),
        .SF       (),
        .PF       (),
        .OF       ()
    );

    bsf u_bsf (
        .operand (),
        .data_size(),
        .dr_o    (),
        .ZF      ()
    );

    call_op u_call_op (
        .EIP      (),
        .stack_ptr(),
        .dr_o     (),
        .res_bus  ()
    );

    cmp u_cmp (
        .operand1 (),
        .operand2 (),
        .data_size(),

        .CF (),
        .OF (),
        .SF (),
        .ZF (),
        .AF (),
        .PF ()
    );

    cmpxchg_op u_cmpxchg_op (
        .lock_i        (),
        .new_lock_i    (),
        .compare_val_i (),
        .data_size     (),

        .lock_result_o (),
        .acc_result_o  (),
        .ZF            (),
        .SF            (),
        .PF            (),
        .CF            (),
        .OF            (),
        .AF            ()
    );

    far_op u_far_op (
        .neip      (),
        .segment   (),
        .stack_ptr (),

        .res_buf (),
        .dr_o    ()
    );

    iretd_op u_iretd_op (
        .cs        (),
        .flags     (),
        .stack_ptr (),

        .cs_o         (),
        .stack_ptr_o  (),
        .flags_o      ()
    );

    mov_op u_mov_op (
        .srA       (),
        .srB       (),
        .data_size (),

        .res_buf_o (),
        .dr_o      ()
    );

    not_op u_not_op (
        .srA       (),
        .data_size (),
        .dr_o      (),
        .res_buf_o ()
    );

    or_op u_or_op (
        .srA       (), //SRA <- DR/MEM
        .srB       (), //SRB <- SR/MEM/IMM
        .data_size (),

        .dr_o      (), //output to r 
        .res_buf_o (), //output to mem
        .ZF        (),
        .SF        (),
        .PF        (),
        .OF        (),
        .CF        ()
    );

    packssdw u_packssdw (
        .srA (),
        .srB (),
        .dr_o()
    );

    packsswb u_packsswb (
        .srA (),
        .srB (),
        .dr_o()
    );

    paddd u_paddd (
        .srA (),
        .srB (),
        .dr_o()
    );

    paddw u_paddw (
        .srA (),
        .srB (),
        .dr_o()
    );

    pavgb u_pavgb (
        .srA (),
        .srB (),
        .dr_o()
    );

    pavgw u_pavgw (
        .srA (),
        .srB (),
        .dr_o()
    );

    pop_op u_pop_op (
        .value_i (), //res buf
        .sp_i    (), //sr latch

        .dr_o (), //popped value
        .sr_o   () //stack pointer
    );

    push_op u_push_op (
        .sp    (), //SRB selects SR
        .value (), //SRA sel DR
        .res_buf (), //value to push
        .sr_o    () //updated stack
    );

    ret_far_imm u_ret_far_imm (
        .cs        (),
        .stack_ptr (),

        .imm64 (),
        .cs_o  ()
    );

    ret_far_op u_ret_far_op (
        .cs        (),
        .stack_ptr (),

        .cs_o       (),
        .next_ptr_o ()
    );

    ret_imm_op u_ret_imm_op (
        .stack_ptr (),
        .imm64     (),

        .stack_ptr_o ()
    );

    ret_op u_ret_op (
        .stack_ptr (),
        .stack_ptr_o ()
    );

    sal_op u_sal_op (
        .value_i    (),
        .shift_amt_i(),
        .data_size  (),
        .shift_by_one(),

        .prev_ZF (),
        .prev_SF (),
        .prev_PF (),
        .prev_CF (),
        .prev_OF (),

        .dr_o (),
        .ZF   (),
        .SF   (),
        .PF   (),
        .OF   (),
        .CF   ()
    );

    sar_op u_sar_op (
        .value_i     (),
        .shift_amt_i (),
        .data_size   (),
        .shift_by_one(),

        .dr_o      (),
        .res_buf_o (),
        .ZF        (),
        .SF        (),
        .PF        (),
        .OF        (),
        .CF        ()
    );

    sbb_op u_sbb_op (
        .operand1 (),
        .operand2 (),
        .CF_in    (),
        .data_size(),

        .result    (),
        .res_buf_o (),
        .CF        (),
        .PF        (),
        .AF        (),
        .ZF        (),
        .SF        (),
        .OF        ()
    );

    xchg_op u_xchg_op (
        .srA      (),
        .srB      (),
        .data_size(),

        .res_buf (),
        .dr_o    (),
        .sr_o    ()
    );

    //making the assumption that a write to the buffer will either line up with the r/m value. so ST offset of the SS offset. 
    // select from buffer, imm, src
    //if needed align buffer data
    //execute unit
    //branch resolution unit
    //flag update logic
    //bit vector gen for WB.STQ
    //conditional CS for conditional instructions (i.e CMOVC)
    //ALU reorder logic 
    //valid logic 
   



endmodule
