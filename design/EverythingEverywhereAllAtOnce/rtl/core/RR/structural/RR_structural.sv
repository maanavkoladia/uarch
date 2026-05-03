import RegisterRead_pkg::*;
import core_common_pkg::*;
import core_stage_latches_pkg::*;
import control_store_pkg::*;

module RR (
    input wire clk,
    input wire rst,
    //actual stage latches needed
    input rr_latches_t latches_i,
    //for pipeclear when exp is about to be served and ROM loaded into IDM
    input fetch_outputs_t fetch_outs_i,
    //decode gp
    input decode_outputs_t decode_outs_i,
    //only used for valid
    input dc_outputs_t dc_outs_i,
    //only used for valid logic
    input mem_outputs_t mem_outs_i,
    //only use for valid logic
    input exe_outputs_t exe_outs_i,
    //used for sb clearing and for valid logic
    input wb_outputs_t wb_outs_i,

    //next latches
    output dc_latches_t dc_latches_next,
    output rr_outputs_t outs_o
);

    rr_latches_general_t latchesInUse;
    assign latchesInUse = decode_outs_i.rep_latch ? latches_i.rep_latches : latches_i.normal_latches;

    //6 bc 6 seg regs and their respctive limits
    segment_limit_reg_entry_t SEGMENT_LIMITS[NUM_SEG_REGS];  //CS, DS, ES, FS, GS, SS, EXPS


    //SB Oouts
    bool ecx_sb;
    bool cs_sb;
    bool depstall;

    bool dc_latches_we;
    bool next_dc_valid;
    bool rr_stall;
    assign rr_stall = latchesInUse.valid && depstall;

    //32 bit bc mmx sare the data areg
    uint32_t addygen_input_addy;
    assign addygen_input_addy =
        (latchesInUse.cs.MODRM_NEEDED && latchesInUse.cs.RM_IS_DR) ?
        reg_out.DR_data[31:0] : reg_out.SR_data[31:0];


    // Unrolled wires from the structural RegFile (matches the new .v port list).
    uint64_t DR_data_w, SR_data_w;
    uint32_t SIB_IDX_data_w, SIB_BASE_data_w;
    uint32_t ECX_data_w, EAX_data_w, CS_data_w;
    uint32_t Segment0_data_w, Segment1_data_w;

    uint64_t REG_CS_w, REG_DS_w, REG_SS_w, REG_ES_w;
    uint64_t REG_FS_w, REG_GS_w, REG_EXPS_w;
    uint64_t REG_EAX_w, REG_EBX_w, REG_ECX_w, REG_EDX_w;
    uint64_t REG_ESI_w, REG_EDI_w, REG_ESP_w, REG_EBP_w;
    uint64_t REG_MM0_w, REG_MM1_w, REG_MM2_w, REG_MM3_w;
    uint64_t REG_MM4_w, REG_MM5_w, REG_MM6_w, REG_MM7_w;
    uint64_t REG_ETR_w, REG_ERROR_REG_w, REG_NO_REG_w;

    RegFile RegisterFile_unit (
        .clk(clk),
        .rst(rst),

        .DR_ID(latchesInUse.cs.dr_id),
        .SR_ID(latchesInUse.cs.sr_id),
        .SIB_IDX_ID(latchesInUse.sib_idx_id),
        .SIB_BASE_ID(latchesInUse.sib_base_id),

        .WB_DR0_data(exe_outs_i.DR_0_data),
        .WB_DR1_data(exe_outs_i.DR_1_data),
        .WB_DR0_ID(exe_outs_i.DR_0_id),
        .WB_DR1_ID(exe_outs_i.DR_1_id),
        .WB_DR0_we(exe_outs_i.DR_0_we),
        .WB_DR1_we(exe_outs_i.DR_1_we),

        .Segment0_ID(latchesInUse.cs.seg_0_id),
        .Segment1_ID(latchesInUse.cs.seg_1_id),

        .DR_data(DR_data_w),
        .SR_data(SR_data_w),
        .SIB_IDX_data(SIB_IDX_data_w),
        .SIB_BASE_data(SIB_BASE_data_w),
        .ECX_data(ECX_data_w),
        .EAX_data(EAX_data_w),
        .CS_data(CS_data_w),
        .Segment0_data(Segment0_data_w),
        .Segment1_data(Segment1_data_w),

        .REG_CS_o(REG_CS_w),
        .REG_DS_o(REG_DS_w),
        .REG_SS_o(REG_SS_w),
        .REG_ES_o(REG_ES_w),
        .REG_FS_o(REG_FS_w),
        .REG_GS_o(REG_GS_w),
        .REG_EXPS_o(REG_EXPS_w),
        .REG_EAX_o(REG_EAX_w),
        .REG_EBX_o(REG_EBX_w),
        .REG_ECX_o(REG_ECX_w),
        .REG_EDX_o(REG_EDX_w),
        .REG_ESI_o(REG_ESI_w),
        .REG_EDI_o(REG_EDI_w),
        .REG_ESP_o(REG_ESP_w),
        .REG_EBP_o(REG_EBP_w),
        .REG_MM0_o(REG_MM0_w),
        .REG_MM1_o(REG_MM1_w),
        .REG_MM2_o(REG_MM2_w),
        .REG_MM3_o(REG_MM3_w),
        .REG_MM4_o(REG_MM4_w),
        .REG_MM5_o(REG_MM5_w),
        .REG_MM6_o(REG_MM6_w),
        .REG_MM7_o(REG_MM7_w),
        .REG_ETR_o(REG_ETR_w),
        .REG_ERROR_REG_o(REG_ERROR_REG_w),
        .REG_NO_REG_o(REG_NO_REG_w)
    );

    // Re-aggregate the unrolled RegFile outputs back into the regfile_output_t
    // struct so the rest of RR (addy-gen, dc_latches_next, outs_o) is unchanged.
    regfile_output_t reg_out;
    assign reg_out.DR_data        = DR_data_w;
    assign reg_out.SR_data        = SR_data_w;
    assign reg_out.SIB_IDX_data   = SIB_IDX_data_w;
    assign reg_out.SIB_BASE_data  = SIB_BASE_data_w;
    assign reg_out.ECX_data       = ECX_data_w;
    assign reg_out.EAX_data       = EAX_data_w;
    assign reg_out.CS_data        = CS_data_w;
    assign reg_out.Segment0_data  = Segment0_data_w;
    assign reg_out.Segment1_data  = Segment1_data_w;

    assign reg_out.regFileValues_o[CS]        = REG_CS_w;
    assign reg_out.regFileValues_o[DS]        = REG_DS_w;
    assign reg_out.regFileValues_o[SS]        = REG_SS_w;
    assign reg_out.regFileValues_o[ES]        = REG_ES_w;
    assign reg_out.regFileValues_o[FS]        = REG_FS_w;
    assign reg_out.regFileValues_o[GS]        = REG_GS_w;
    assign reg_out.regFileValues_o[EXPS]      = REG_EXPS_w;
    assign reg_out.regFileValues_o[EAX]       = REG_EAX_w;
    assign reg_out.regFileValues_o[EBX]       = REG_EBX_w;
    assign reg_out.regFileValues_o[ECX]       = REG_ECX_w;
    assign reg_out.regFileValues_o[EDX]       = REG_EDX_w;
    assign reg_out.regFileValues_o[ESI]       = REG_ESI_w;
    assign reg_out.regFileValues_o[EDI]       = REG_EDI_w;
    assign reg_out.regFileValues_o[ESP]       = REG_ESP_w;
    assign reg_out.regFileValues_o[EBP]       = REG_EBP_w;
    assign reg_out.regFileValues_o[MM0]       = REG_MM0_w;
    assign reg_out.regFileValues_o[MM1]       = REG_MM1_w;
    assign reg_out.regFileValues_o[MM2]       = REG_MM2_w;
    assign reg_out.regFileValues_o[MM3]       = REG_MM3_w;
    assign reg_out.regFileValues_o[MM4]       = REG_MM4_w;
    assign reg_out.regFileValues_o[MM5]       = REG_MM5_w;
    assign reg_out.regFileValues_o[MM6]       = REG_MM6_w;
    assign reg_out.regFileValues_o[MM7]       = REG_MM7_w;
    assign reg_out.regFileValues_o[ETR]       = REG_ETR_w;
    assign reg_out.regFileValues_o[ERROR_REG] = REG_ERROR_REG_w;
    assign reg_out.regFileValues_o[NO_REG]    = REG_NO_REG_w;

    v_address_t ld_vaddy;
    uint32_t seg0_limit_w_datasize;
    uint32_t seg0_limit_wo_datasize;
    v_address_t next_ld_vaddy;
    uint32_t ld_laddy;

    v_address_t actual_st_vaddy;
    uint32_t seg1_limit_w_datasize;
    uint32_t seg1_limit_wo_datasize;
    v_address_t actual_next_st_vaddy;
    uint32_t st_laddy;

    npu_node1 addygen_logic_unit (
        .register_data(addygen_input_addy),
        .SIB_IDX_data(reg_out.SIB_IDX_data),
        .SIB_BASE_data(reg_out.SIB_BASE_data),
        .SIB_SCALE_val(latchesInUse.sib_scale),
        .sib_needed(latchesInUse.sib_needed),
        .disp_needed(latchesInUse.disp_needed),
        .dispsize(latchesInUse.disp_size),
        .displacement(latchesInUse.displacement),
        .datasize(latchesInUse.cs.datasize),
        .seg0_data(reg_out.Segment0_data),
        .segment0_limit(SEGMENT_LIMITS[latchesInUse.cs.seg_0_id]),
        .seg1_data(reg_out.Segment1_data),
        .segment1_limit(SEGMENT_LIMITS[latchesInUse.cs.seg_1_id]),
        .seg1_valid(latchesInUse.cs.seg_1_valid),
        .modrm_needed(latchesInUse.cs.MODRM_NEEDED),
        .rm_is_dr(latchesInUse.cs.RM_IS_DR),
        .st_sel(latchesInUse.cs.ST_SEL),
        .movs_op(latchesInUse.cs.MOVS_OP),
        .switch_ld_addy(latchesInUse.cs.SWITCH_LD_ADDY),
        .special_br(latchesInUse.cs.special_br),
        .special_modrm_bs(latchesInUse.cs.special_modrm_bs),
        .regout_sr_data(reg_out.SR_data[31:0]),
        .regout_dr_data(reg_out.DR_data[31:0]),

        .ld_vaddy(ld_vaddy),
        .seg0_limit_w_datasize(seg0_limit_w_datasize),
        .seg0_limit_wo_datasize(seg0_limit_wo_datasize),
        .next_ld_vaddy(next_ld_vaddy),
        .ld_laddy(ld_laddy),

        .actual_st_vaddy(actual_st_vaddy),
        .seg1_limit_w_datasize(seg1_limit_w_datasize),
        .seg1_limit_wo_datasize(seg1_limit_wo_datasize),
        .actual_next_st_vaddy(actual_next_st_vaddy),
        .actual_st_laddy(st_laddy)
    );

    // AddyX_NeuralNet ld_addyX_neuralnet_unit (
    //     .data_size(latchesInUse.cs.datasize),
    //     .addy0(addygen_out),
    //     .mem_op(latchesInUse.cs.LD_OP),
    //     .seg_data(reg_out.Segment0_data),
    //     .seg_limit(SEGMENT_LIMITS[latchesInUse.seg_0_id]),
    //     .write_intent(1'b0),
    //     .outputs(ld_neuralnet_out)
    // );

    // AddyX_NeuralNet st_addyX_neuralnet_unit (
    //     .data_size(latchesInUse.cs.datasize),
    //     .addy0(staddyX_neuralnet_addy),
    //     .mem_op(latchesInUse.cs.ST_OP),
    //     .seg_data(reg_out.Segment1_data),
    //     .seg_limit(SEGMENT_LIMITS[latchesInUse.seg_1_id]),
    //     .write_intent(latchesInUse.cs.ST_OP),
    //     .outputs(st_neuralnet_out)
    // );

    bool instructionforward;
    assign instructionforward = dc_latches_we && next_dc_valid;

    RegSB reg_sb_unit (
        .clk           (clk),
        .rst           (rst),
        .instructionforward(instructionforward),
        .dr_id         (latchesInUse.cs.dr_id),
        .sr_id         (latchesInUse.cs.sr_id),
        .flush         (exe_outs_i.br_res_out.flush),
        .farFlush      (exe_outs_i.br_res_out.farFlush),
        .callFlush     (exe_outs_i.br_res_out.callFlush),
        .sib_base_id   (latchesInUse.sib_base_id),
        .sib_idx_id    (latchesInUse.sib_idx_id),
        .wb_dr0_id     (exe_outs_i.DR_0_id),
        .wb_dr0_we     (exe_outs_i.DR_0_we),
        .wb_dr1_id     (exe_outs_i.DR_1_id),
        .wb_dr1_we     (exe_outs_i.DR_1_we),
        .cs_sib_size   (latchesInUse.sib_needed),
        .cs_dr_wr      (latchesInUse.cs.dr_wr),
        .cs_sr_wr      (latchesInUse.cs.sr_wr),
        .cs_dr_rd      (latchesInUse.cs.dr_rd),
        .cs_sr_rd      (latchesInUse.cs.sr_rd),
        .cs_eax_rd     (latchesInUse.cs.eax_rd),
        .cs_eax_wr     (latchesInUse.cs.eax_wr),
        .Segment0_ID   (latchesInUse.cs.seg_0_id),
        .Segment1_ID   (latchesInUse.cs.seg_1_id),
        .Segment1_valid(latchesInUse.cs.seg_1_valid),
        .dep_stall     (depstall),
        .ecx_sb        (ecx_sb),
        .codeSeg_sb    (cs_sb),
        .LD_OP(latchesInUse.cs.LD_OP),
        .ST_OP(latchesInUse.cs.ST_OP),
        .REP_OP(decode_outs_i.rep_latch)
    );

    
    dc_valid_logic dc_valid_logic_unit(
        .DC_we_o(dc_latches_we),
        .N_DC_V_o(next_dc_valid),
        .RR_stall_i(rr_stall),
        .RR_V_i(latchesInUse.valid),
        .DC_stall_i(dc_outs_i.stall),
        .DC_V_i(dc_outs_i.valid),
        .MEM_V_i(mem_outs_i.valid),
        .MEM_stall_i(mem_outs_i.stall),
        .EXE_V_i(exe_outs_i.valid),
        .WB_stall_i(wb_outs_i.wb_stall)
    );
   

    //needed sb clear, we will use dep stall to mask out expcetions if there
    //a a dirty sb for the needed regs, we are p sure that thnis correct
    //bahrvior
    bool RR_GP;
    assign RR_GP = decode_outs_i.decode_gp && !(depstall);

    // assign dc_latches_next = '{
    //         valid       : next_dc_valid,
    //         cs          : latchesInUse.dc_cs,
    //         mem_cs      : latchesInUse.mem_cs,
    //         exe_cs      : latchesInUse.exe_cs,
    //         wb_cs       : latchesInUse.wb_cs,
    //         br_info     : latchesInUse.br_info,
    //         ST_XCL      : st_neuralnet_out.xcl,
    //         ST_PADDR_0  : st_neuralnet_out.paddy,
    //         ST_PADDR_1  : st_neuralnet_out.paddy_aligned,
    //         NEIP        : latchesInUse.NEIP,
    //         EIP         : latchesInUse.EIP,
    //         EAX         : latchesInUse.EAX,
    //         imm64       : latchesInUse.imm64,
    //         LD_XCL      : ld_neuralnet_out.xcl,
    //         LD_PADDR_0  : ld_neuralnet_out.paddy,
    //         LD_PADDR_1  : ld_neuralnet_out.paddy_aligned,
    //         MIO         : ld_neuralnet_out.mio,
    //         swapLines   : ld_neuralnet_out.bank_hi,
    //         sr_id       : latchesInUse.cs.sr_id,
    //         sr_data     : reg_out.SR_data[31:0],
    //         dr_id       : latchesInUse.cs.dr_id,
    //         dr_data     : reg_out.DR_data[31:0]
    //     };

    assign dc_latches_next = '{
        valid                   : next_dc_valid & ~fetch_outs_i.exp_pipe_clear,
        cs                      : latchesInUse.dc_cs,
        mem_cs                  : latchesInUse.mem_cs,
        exe_cs                  : latchesInUse.exe_cs,
        wb_cs                   : latchesInUse.wb_cs,
        br_info                 : latchesInUse.br_info,
        NEIP                    : latchesInUse.NEIP,
        EIP                     : latchesInUse.EIP,
        EAX                     : reg_out.EAX_data,
        imm64                   : latchesInUse.imm64,

        rr_gp                   : RR_GP,

        ld_vaddy                : ld_vaddy,
        seg0_limit_w_datasize   : seg0_limit_w_datasize,
        seg0_limit_wo_datasize  : seg0_limit_wo_datasize,
        next_ld_vaddy           : next_ld_vaddy,
        ld_laddy                : ld_laddy,
        ld_stack_access         : (latchesInUse.cs.seg_0_id == SS),

        st_vaddy                : actual_st_vaddy,
        seg1_limit_w_datasize   : seg1_limit_w_datasize,
        seg1_limit_wo_datasize  : seg1_limit_wo_datasize,
        next_st_vaddy           : actual_next_st_vaddy,
        st_laddy                : st_laddy,
        st_stack_access         : (latchesInUse.cs.seg_1_valid ? (latchesInUse.cs.seg_1_id == SS) :
                                                            (latchesInUse.cs.seg_0_id == SS)),

        sr_id                   : latchesInUse.cs.sr_id,
        sr_data                 : reg_out.SR_data,
        dr_id                   : latchesInUse.cs.dr_id,
        dr_data                 : reg_out.DR_data
    };

    assign outs_o = '{
            valid   : latchesInUse.valid,
            stall   : latchesInUse.valid && depstall,
            ecx_sb  : ecx_sb,
            ecx     : reg_out.ECX_data[31:0],
            eax     : reg_out.EAX_data,
            set_ZF_sb   : latchesInUse.cs.will_mod_zf,
            codeSeg_sb  : cs_sb,
            codeSeg_data  : reg_out.CS_data,
            codeSeg_limit  : SEGMENT_LIMITS[CS_LIMIT_ID].limit,
            dc_stage_latch_we : dc_latches_we,
            regFileValues : reg_out.regFileValues_o
        };

endmodule

