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

    uint64_t modrm_data, reg_data;
    uint32_t sib_idx_data, sib_base_data, ecx_data, cs_data, seg0_data, seg1_data;

    bool ld0_gp, ld1_gp, st0_gp, st1_gp, RR_GP;
    bool ld0_pf, ld1_pf, st0_pf, st1_pf, RR_PF;
    bool st0_v, ld0_v;
    p_address_t ld0_paddy, st0_paddy;
    p_address_t ld1_paddy_aligned, st1_paddy_aligned;
    bool ld_bank_hi, st_bank_hi;
    bool ld_xcl, st_xcl;

    uint32_t addygen_input_addy =
        (latches_i.normal_latches.cs.DR_SEL) ? modrm_data[31:0] : reg_data[31:0];
    
    l_address_t addygen_out;

    l_address staddyX_neuralnet_addy =
        (latches_i.normal_latches.cs.ST_SEL) ?
            ((latches_i.normal_latches.cs.ST_SEL) ? reg_data[31:0] : modrm_data[31:0]) :
            addygen_out;

    bool depstall;

    regfile_inputs_t reg_in = '{
        MODRM_ID       : latches_i.normal_latches.mod_rm_id,
        REG_ID         : latches_i.normal_latches.reg_id,
        SIB_IDX_ID     : latches_i.normal_latches.sib_idx_id,
        SIB_BASE_ID    : latches_i.normal_latches.sib_base_id,
        DR0_data       : wb_outs_i.DR_0_data,
        DR1_data       : wb_outs_i.DR_1_data,
        DR0_ID         : wb_outs_i.DR_0_id,
        DR1_ID         : wb_outs_i.DR_1_id,
        DR0_we         : wb_outs_i.DR_0_we,
        DR1_we         : wb_outs_i.DR_1_we,
        Segment0_ID    : latches_i.normal_latches.seg_0_id,
        Segment1_ID    : latches_i.normal_latches.seg_1_id
    };

    regsb_inputs_t regsb_in = '{
        reg_id          : latches_i.normal_latches.reg_id,
        modrm_id        : latches_i.normal_latches.mod_rm_id,
        sib_base_id     : latches_i.normal_latches.sib_base_id,
        sib_idx_id      : latches_i.normal_latches.sib_idx_id,
        wb_dr0_id       : wb_outs_i.DR_0_id,
        wb_dr0_we       : wb_outs_i.DR_0_we,
        wb_dr1_id       : wb_outs_i.DR_1_id,
        wb_dr1_we       : wb_outs_i.DR_1_id,
        cs_sib_size     : latches_i.normal_latches.cs.SIB_NEEDED,
        cs_reg_rd       : latches_i.normal_latches.cs.REG_RD,
        cs_modrm_rd     : latches_i.normal_latches.cs.MODRM_RD,
        cs_reg_wr       : latches_i.normal_latches.cs.WE_REG,
        cs_modrm_reg_wr : latches_i.normal_latches.cs.WE_MOD_RM
    };

    regfile_outputs_t reg_out = '{
        MODRM_data      : modrm_data,
        REG_data        : reg_data,
        SIB_IDX_data    : sib_idx_data,
        SIB_BASE_data   : sib_base_data,
        ECX_data        : ecx_data,
        CS_data         : cs_data,
        Segment0_data   : seg0_data,
        Segment1_data   : seg1_data
    };

    neuralnet_outputs_t ld_neuralnet =  '{
        gp0_exception   : ld0_gp,
        pf0_exception   : ld0_pf,
        gp1_exception   : ld1_gp,
        pf1_exception   : ld1_pf,
        valid_mem_op    : ld0_v,
        paddy_aligned   : ld1_paddy_aligned,
        bank_hi         : ld_bank_hi,
        xcl             : ld_xcl,
        paddy           : ld0_paddy
    };

    neuralnet_outputs_t st_neuralnet =  '{
        gp0_exception   : st0_gp,
        pf0_exception   : st0_pf,
        gp1_exception   : st1_gp,
        pf1_exception   : st1_pf,
        valid_mem_op    : st0_v,
        paddy_aligned   : st1_paddy_aligned,
        bank_hi         : st_bank_hi,
        xcl             : st_xcl,
        paddy           : st0_paddy
    };

    RegFile regfile(.clk(clk), .rst(rst), .inputs(reg_in), .outputs(reg_out));

    AddressGen_Logic addygen_logic (
        .register_data(addygen_input_addy),
        .SIB_IDX_data(sib_idx_data),
        .SIB_BASE_data(sib_base_data),
        .SIB_SCALE_val(latches_i.normal_latches.sib_scale),
        .rr_cs(latches_i.normal_latches.cs),
        .dispsize(latches_i.normal_latches.disp_size),
        .displacemnt(latches_i.normal_latches.displacement),
        .AddrGen_out(addygen_out)
    );

    AddyX_NeuralNet ld_addyX_neuralnet (
        .data_size(latches_i.normal_latches.cs.datasize),
        .addy0(addygen_out),
        .mem_op(latches_i.normal_latches.cs.LD_OP),
        .seg_data(seg0_data),
        .seg_limit(SEGMENT_LIMITS[latches_i.normal_latches.seg_0_id]),
        .write_intent(1'b0),
        .outputs(ld_neuralnet)
    );

    AddyX_NeuralNet st_addyX_neuralnet (
        .data_size(latches_i.normal_latches.cs.datasize),
        .addy0(staddyX_neuralnet_addy),
        .mem_op(latches_i.normal_latches.cs.ST_OP),
        .seg_data(seg1_data),
        .seg_limit(SEGMENT_LIMITS[latches_i.normal_latches.seg_1_id]),
        .write_intent(latches_i.normal_latches.cs.ST_OP),
        .outputs(st_neuralnet)
    );


    RegSB regsb(
        .clk(clk), .rst(rst), .inputs(regsb_in), .dep_stall(depstall)
    );

    assign RR_PF = ld0_pf || ld1_pf || st0_pf || st1_pf;
    assign RR_GP = ld0_gp || ld1_gp || st0_gp || st1_gp || decode_outs_i.decode_gp;
    assign outs_o.exp_present = RR_PF || RR_GP;
    assign outs_0.stall = outs_o.exp_present || depstall;

    initial begin
        SEGMENT_LIMITS = '1;
    end




    assign dc_latches_next = '{
        valid       : 1'b1, //need ot do valid logic
        cs          : inputs_i.normal_latches.dc_cs,
        mem_cs      : inputs_i.normal_latches.mem_cs,
        exe_cs      : inputs_i.normal_latches.exe_cs,
        wb_cs       : inputs_i.normal_latches.wb_cs,
        br_info     : inputs_i.normal_latches.br_info,
        ST_XCL      : st_xcl,
        ST_PADDR_0  : st0_paddy,
        ST_PADDR_1  : st1_paddy_aligned,
        MIO         : 1'b0,  //need to figure out where this signal comes from
        NEIP        : inputs_i.normal_latches.NEIP,
        imm64       : inputs_i.normal_latches.imm64,
        LD_XCL      : ld_xcl,
        LD_PADDR_0  : ld0_paddy,
        LD_PADDR_1  : ld1_paddy,
        swapLines   : ld_bank_hi,
        sr_id       : !(latches_i.normal_latches.cs.DR_SEL) ? reg_in.MODRM_ID : reg_in.REG_ID,
        sr_data     : !(latches_i.normal_latches.cs.DR_SEL) ? modrm_data[31:0] : reg_data[31:0],
        dr_id       : (latches_i.normal_latches.cs.DR_SEL) ? reg_in.MODRM_ID : reg_in.REG_ID,
        dr_data     : (latches_i.normal_latches.cs.DR_SEL) ? modrm_data[31:0] : reg_data[31:0]
    };

endmodule
