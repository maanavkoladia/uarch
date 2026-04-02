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

    uint32_t SEGMENT_LIMITS[6]; //CS, DS, ES, FS, GS, SS

    bool RR_GP, RR_PF;

    uint32_t addygen_input_addy =
        (latches_i.normal_latches.cs.MODRM_NEEDED && latches_i.normal_latches.cs.RM_IS_DR) ? reg_out.DR_data[31:0] : reg_out.SR_data[31:0];

    l_address_t addygen_out;

    l_address_t staddyX_neuralnet_addy;
    assign staddyX_neuralnet_addy =
        (latches_i.normal_latches.cs.ST_SEL) ?
            ((latches_i.normal_latches.cs.ST_SEL) ? reg_out.SR_data[31:0] : reg_out.DR_data[31:0]) :
            addygen_out;

    bool depstall;

    regfile_output_t reg_out;
    neuralnet_outputs_t ld_neuralnet;
    neuralnet_outputs_t st_neuralnet;
    regfile_input_t reg_in = '{
        DR_ID       : latches_i.normal_latches.cs.dr_id,
        SR_ID         : latches_i.normal_latches.cs.sr_id,
        SIB_IDX_ID     : latches_i.normal_latches.sib_idx_id,
        SIB_BASE_ID    : latches_i.normal_latches.sib_base_id,
        WB_DR0_data       : wb_outs_i.DR_0_data,
        WB_DR1_data       : wb_outs_i.DR_1_data,
        WB_DR0_ID         : wb_outs_i.DR_0_id,
        WB_DR1_ID         : wb_outs_i.DR_1_id,
        WB_DR0_we         : wb_outs_i.DR_0_we,
        WB_DR1_we         : wb_outs_i.DR_1_we,
        Segment0_ID    : latches_i.normal_latches.seg_0_id,
        Segment1_ID    : latches_i.normal_latches.seg_1_id
    };
    regsb_inputs_t regsb_in = '{
        sr_id           : latches_i.normal_latches.cs.sr_id,
        dr_id           : latches_i.normal_latches.cs.dr_id,
        sib_base_id     : latches_i.normal_latches.sib_base_id,
        sib_idx_id      : latches_i.normal_latches.sib_idx_id,
        wb_dr0_id       : wb_outs_i.DR_0_id,
        wb_dr0_we       : wb_outs_i.DR_0_we,
        wb_dr1_id       : wb_outs_i.DR_1_id,
        wb_dr1_we       : wb_outs_i.DR_1_id,
        cs_sib_size     : latches_i.normal_latches.sib_needed,
        cs_sr_rd        : latches_i.normal_latches.cs.sr_rd,
        cs_dr_rd        : latches_i.normal_latches.cs.dr_rd,
        cs_sr_wr        : latches_i.normal_latches.cs.sr_wr,
        cs_dr_wr        : latches_i.normal_latches.cs.dr_wr,
        Segment0_ID     : latches_i.normal_latches.seg_0_id,
        Segment1_ID     : latches_i.normal_latches.seg_1_id,
        Segment1_valid  : 1'b0
    };

    RegFile regfile(.clk(clk), .rst(rst), .inputs(reg_in), .outputs(reg_out));

    AddressGen_Logic addygen_logic (
        .register_data(addygen_input_addy),
        .SIB_IDX_data(reg_out.SIB_IDX_data),
        .SIB_BASE_data(reg_out.SIB_BASE_data),
        .SIB_SCALE_val(latches_i.normal_latches.sib_scale),
        .rr_cs(latches_i.normal_latches.cs),
        .dispsize(latches_i.normal_latches.disp_size),
        .displacement(latches_i.normal_latches.displacement),
        .AddrGen_out(addygen_out)
    );

    AddyX_NeuralNet ld_addyX_neuralnet (
        .data_size(latches_i.normal_latches.cs.datasize),
        .addy0(addygen_out),
        .mem_op(latches_i.normal_latches.cs.LD_OP),
        .seg_data(reg_out.Segment0_data),
        .seg_limit(SEGMENT_LIMITS[latches_i.normal_latches.seg_0_id]),
        .write_intent(1'b0),
        .outputs(ld_neuralnet)
    );

    AddyX_NeuralNet st_addyX_neuralnet (
        .data_size(latches_i.normal_latches.cs.datasize),
        .addy0(staddyX_neuralnet_addy),
        .mem_op(latches_i.normal_latches.cs.ST_OP),
        .seg_data(reg_out.Segment1_data),
        .seg_limit(SEGMENT_LIMITS[latches_i.normal_latches.seg_1_id]),
        .write_intent(latches_i.normal_latches.cs.ST_OP),
        .outputs(st_neuralnet)
    );

    bool ecx_sb;
    bool cs_sb;
    RegSB regsb(
        .clk(clk), .rst(rst), .inputs(regsb_in), .dep_stall(depstall), .ecx_sb(ecx_sb), .codeSeg_sb(cs_sb)
    );

    assign RR_PF = ld_neuralnet.pf0_exception || ld_neuralnet.pf1_exception || st_neuralnet.pf0_exception || st_neuralnet.pf1_exception;
    assign RR_GP = ld_neuralnet.gp0_exception || ld_neuralnet.gp1_exception || st_neuralnet.gp0_exception || st_neuralnet.gp1_exception || decode_outs_i.decode_gp;

    initial begin
        SEGMENT_LIMITS = '{6{'1}};
    end

    assign dc_latches_next = '{
        valid       : 1'b1, //need ot do valid logic
        cs          : latches_i.normal_latches.dc_cs,
        mem_cs      : latches_i.normal_latches.mem_cs,
        exe_cs      : latches_i.normal_latches.exe_cs,
        wb_cs       : latches_i.normal_latches.wb_cs,
        br_info     : latches_i.normal_latches.br_info,
        ST_XCL      : st_neuralnet.xcl,
        ST_PADDR_0  : st_neuralnet.paddy,
        ST_PADDR_1  : st_neuralnet.paddy_aligned,
        MIO         : 1'b0,  //need to figure out where this signal comes from
        NEIP        : latches_i.normal_latches.NEIP,
        EIP         : latches_i.normal_latches.EIP,
        imm64       : latches_i.normal_latches.imm64,
        LD_XCL      : ld_neuralnet.xcl,
        LD_PADDR_0  : ld_neuralnet.paddy,
        LD_PADDR_1  : ld_neuralnet.paddy_aligned,
        swapLines   : ld_neuralnet.bank_hi,
        sr_id       : reg_in.SR_ID,
        sr_data     : reg_out.SR_data[31:0],
        dr_id       : reg_in.DR_ID,
        dr_data     : reg_out.DR_data[31:0]
    };


    bool set_zf_scoreboard;
    assign outs_o = '{
        valid   :   1'b1,
        stall   :   latches_i.normal_latches.valid && (depstall || (RR_PF || RR_GP)),
        exp_present : RR_PF || RR_GP,
        exp_pf  : RR_PF,
        ecx_sb : ecx_sb,
        ecx     : reg_out.ECX_data,
        set_ZF_sb   : latches_i.normal_latches.cs.will_mod_ZF,
        codeSeg_sb  : cs_sb,
        codeSeg_data  : reg_out.CS_data,
        codeSeg_limit  : '1
    };

endmodule