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
    assign latchesInUse = latches_i.useRep ? latches_i.rep_latches : latches_i.normal_latches;

    //6 bc 6 seg regs and their respctive limits
    segment_limit_reg_entry_t SEGMENT_LIMITS[NUM_SEG_REGS];  //CS, DS, ES, FS, GS, SS


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

    l_address_t staddyX_neuralnet_addy;
    assign staddyX_neuralnet_addy =
        (latchesInUse.cs.ST_SEL) ?
            ((latchesInUse.cs.MODRM_NEEDED && latchesInUse.cs.RM_IS_DR) ? reg_out.SR_data[31:0] : reg_out.DR_data[31:0]) :
            addygen_out;


    regfile_output_t reg_out;
    neuralnet_outputs_t ld_neuralnet_out;
    neuralnet_outputs_t st_neuralnet_out;

    RegFile RegisterFile_unit (
        .clk(clk),
        .rst(rst),

        .DR_ID(latchesInUse.cs.dr_id),
        .SR_ID(latchesInUse.cs.sr_id),
        .SIB_IDX_ID(latchesInUse.sib_idx_id),
        .SIB_BASE_ID(latchesInUse.sib_base_id),

        .WB_DR0_data(wb_outs_i.DR_0_data),
        .WB_DR1_data(wb_outs_i.DR_1_data),
        .WB_DR0_ID(wb_outs_i.DR_0_id),
        .WB_DR1_ID(wb_outs_i.DR_1_id),
        .WB_DR0_we(wb_outs_i.DR_0_we),
        .WB_DR1_we(wb_outs_i.DR_1_we),

        .Segment0_ID(latchesInUse.seg_0_id),
        .Segment1_ID(latchesInUse.seg_1_id),

        .outputs(reg_out)
    );

    //this is final sib addy gen logic
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
        .segment0_limit(SEGMENT_LIMITS[latchesInUse.seg_0_id]),
        .seg1_data(reg_out.Segment1_data),
        .segment1_limit(SEGMENT_LIMITS[latchesInUse.seg_1_id]),
        .seg1_valid(1'b0),
        .modrm_needed(),
        .rm_is_dr(),
        .st_sel()
        .outputs(st_neuralnet_out)
    );


    input uint32_t seg1_data,
    input segment_limit_reg_entry_t segment1_limit;
    input bool seg1_valid

    input bool modrm_needed;
    input bool rm_is_dr;
    input bool st_sel;

    output v_address_t ld_vaddy;
    output uint32_t seg0_limit_w_datasize;
    output v_address_t actual_st_vaddy;
    output uint32_t seg1_limit_w_datasize;

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

    RegSB reg_sb_unit (
        .clk           (clk),
        .rst           (rst),
        .dr_id         (latchesInUse.cs.dr_id),
        .sr_id         (latchesInUse.cs.sr_id),
        .flush         (exe_outs_i.br_res_out.flush),
        .farFlush      (exe_outs_i.br_res_out.farFlush),
        .sib_base_id   (latchesInUse.sib_base_id),
        .sib_idx_id    (latchesInUse.sib_idx_id),
        .wb_dr0_id     (wb_outs_i.DR_0_id),
        .wb_dr0_we     (wb_outs_i.DR_0_we),
        .wb_dr1_id     (wb_outs_i.DR_1_id),
        .wb_dr1_we     (wb_outs_i.DR_1_we),
        .cs_sib_size   (latchesInUse.sib_needed),
        .cs_dr_wr      (latchesInUse.cs.dr_wr),
        .cs_sr_wr      (latchesInUse.cs.sr_wr),
        .cs_dr_rd      (latchesInUse.cs.dr_rd),
        .cs_sr_rd      (latchesInUse.cs.sr_rd),
        .Segment0_ID   (latchesInUse.seg_0_id),
        .Segment1_ID   (latchesInUse.seg_1_id),
        .Segment1_valid(1'b0),
        .dep_stall     (depstall),
        .ecx_sb        (ecx_sb),
        .codeSeg_sb    (cs_sb)
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
    //bahrvioru
    assign RR_PF =
        (ld_neuralnet_out.pf0_exception
        || ld_neuralnet_out.pf1_exception
        || st_neuralnet_out.pf0_exception
        || st_neuralnet_out.pf1_exception)
        && !(depstall);

    assign RR_GP =
            (ld_neuralnet_out.gp0_exception
        || ld_neuralnet_out.gp1_exception
        || st_neuralnet_out.gp0_exception
        || st_neuralnet_out.gp1_exception
        || decode_outs_i.decode_gp)
        && !(depstall);

    assign dc_latches_next = '{
            valid       : next_dc_valid,
            cs          : latchesInUse.dc_cs,
            mem_cs      : latchesInUse.mem_cs,
            exe_cs      : latchesInUse.exe_cs,
            wb_cs       : latchesInUse.wb_cs,
            br_info     : latchesInUse.br_info,
            ST_XCL      : st_neuralnet_out.xcl,
            ST_PADDR_0  : st_neuralnet_out.paddy,
            ST_PADDR_1  : st_neuralnet_out.paddy_aligned,
            NEIP        : latchesInUse.NEIP,
            EIP         : latchesInUse.EIP,
            EAX         : latchesInUse.EAX,
            imm64       : latchesInUse.imm64,
            LD_XCL      : ld_neuralnet_out.xcl,
            LD_PADDR_0  : ld_neuralnet_out.paddy,
            LD_PADDR_1  : ld_neuralnet_out.paddy_aligned,
            MIO         : ld_neuralnet_out.mio,
            swapLines   : ld_neuralnet_out.bank_hi,
            sr_id       : latchesInUse.cs.sr_id,
            sr_data     : reg_out.SR_data[31:0],
            dr_id       : latchesInUse.cs.dr_id,
            dr_data     : reg_out.DR_data[31:0]
        };

    assign outs_o = '{
            valid   : latchesInUse.valid,
            stall   : latchesInUse.valid && depstall,
            ecx_sb  : ecx_sb,
            ecx     : reg_out.ECX_data,
            eax     : reg_out.EAX_data,
            set_ZF_sb   : latchesInUse.cs.will_mod_zf,
            codeSeg_sb  : cs_sb,
            codeSeg_data  : reg_out.CS_data,
            codeSeg_limit  : SEGMENT_LIMITS[CS_LIMIT_ID],
            dc_stage_latch_we : dc_latches_we
        };

endmodule

