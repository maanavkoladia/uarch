module RegSB (
    input  wire        clk,
    input  wire        rst,

    input  wire        instructionforward,

    input  wire [`REG_ID_W-1:0]  dr_id,
    input  wire [`REG_ID_W-1:0]  sr_id,
    input  wire [`REG_ID_W-1:0]  sib_base_id,
    input  wire [`REG_ID_W-1:0]  sib_idx_id,

    input  wire [`REG_ID_W-1:0]  wb_dr0_id,
    input  wire        wb_dr0_we,
    input  wire [`REG_ID_W-1:0]  wb_dr1_id,
    input  wire        wb_dr1_we,

    input  wire        cs_sib_size,

    input  wire        cs_dr_wr,
    input  wire        cs_sr_wr,
    input  wire        cs_dr_rd,
    input  wire        cs_sr_rd,

    input  wire        cs_eax_rd,
    input  wire        cs_eax_wr,

    input  wire [`REG_ID_W-1:0]  Segment0_ID,
    input  wire [`REG_ID_W-1:0]  Segment1_ID,
    input  wire        Segment1_valid,

    input  wire        LD_OP,
    input  wire        ST_OP,
    input  wire        REP_OP,

    input  wire        flush,
    input  wire        farFlush,
    input  wire        callFlush,

    output wire        dep_stall,
    output wire        ecx_sb,
    output wire        codeSeg_sb
);


    //lowkey don't want to use reg ids, nvm might have to
    //nv, maybe not since just use segnment0/1 id since if needed here we will wait.
    //write back will send clear signal in dr0_id, must be able to clear segreg through that

    wire depStall_Internal;

    // 2D arrays indexed by reg id (see reg_ids_define.vh: CS=0 ... NO_REG=25)
    wire [3:0] SB_o   [0:`NUM_REGS-1];
    wire       we_SB  [0:`NUM_REGS-1];
    wire [3:0] din_SB [0:`NUM_REGS-1];
    wire [3:0] din_SB_gated [0:`NUM_REGS-1];

    genvar gi_sb_reg;
    generate
        for (gi_sb_reg = 0; gi_sb_reg < `NUM_REGS; gi_sb_reg = gi_sb_reg + 1) begin : g_sb_reg
            `REG_RST_WE(u_sb_reg, 4, clk, rst, we_SB[gi_sb_reg], din_SB_gated[gi_sb_reg], SB_o[gi_sb_reg])
        end
    endgenerate

    // bool updateSB;
    // assign updateSB = !depStall_Internal && instructionforward;
    wire updateSB;
    wire depStall_Internal_n;
    `INV_N(u_depStall_Internal_inv, 1, depStall_Internal, depStall_Internal_n)
    `AND_2(u_updateSB_and, 1, updateSB, depStall_Internal_n, instructionforward)

    // bool cs_wr_to_both;
    // assign cs_wr_to_both = (cs_dr_wr && cs_sr_wr && (dr_id == sr_id))
    //                     || (cs_dr_wr && cs_eax_wr && (dr_id == EAX));
    wire cs_wr_to_both;
    wire cs_dr_eq_sr;
    wire cs_dr_eq_eax;
    wire cs_wr_dr_sr;
    wire cs_wr_dr_eax;
    `CMP_N(u_cs_dr_eq_sr_cmp,  `REG_ID_W, cs_dr_eq_sr,  dr_id[`REG_ID_W-1:0], sr_id[`REG_ID_W-1:0])
    `CMP_N(u_cs_dr_eq_eax_cmp, `REG_ID_W, cs_dr_eq_eax, dr_id[`REG_ID_W-1:0], `EAX)
    `AND_3(u_cs_wr_dr_sr_and,  1, cs_wr_dr_sr,  cs_dr_wr, cs_sr_wr,  cs_dr_eq_sr)
    `AND_3(u_cs_wr_dr_eax_and, 1, cs_wr_dr_eax, cs_dr_wr, cs_eax_wr, cs_dr_eq_eax)
    `OR_2 (u_cs_wr_to_both_or, 1, cs_wr_to_both, cs_wr_dr_sr, cs_wr_dr_eax)

    // bool wb_wr_to_both;
    // assign wb_wr_to_both = wb_dr0_we && wb_dr1_we && (wb_dr0_id == wb_dr1_id);
    wire wb_wr_to_both;
    wire wb_dr0_eq_wb_dr1;
    `CMP_N(u_wb_dr0_eq_wb_dr1_cmp, `REG_ID_W, wb_dr0_eq_wb_dr1, wb_dr0_id[`REG_ID_W-1:0], wb_dr1_id[`REG_ID_W-1:0])
    `AND_3(u_wb_wr_to_both_and, 1, wb_wr_to_both, wb_dr0_we, wb_dr1_we, wb_dr0_eq_wb_dr1)



    assign dep_stall = depStall_Internal;
    wire ecx_sb_inv;
    `CMP_N(u_ecx_sb_cmp, 4, ecx_sb_inv, SB_o[`ECX], 4'b0)
    `INV_N(u_ecx_sb_inv, 1, ecx_sb_inv, ecx_sb)
    wire codeseg_sb_inv;
    `CMP_N(u_codeseg_sb_cmp, 4, codeseg_sb_inv, SB_o[`CS], 4'b0)
    `INV_N(u_codeseg_sb_inv, 1, codeseg_sb_inv, codeSeg_sb)


    //////////////////////////////////////////// increment phase //////////////////////////
    wire [3:0] SB_post_inc_o [0:`NUM_REGS-1];
    wire [3:0] SB_incd_o     [0:`NUM_REGS-1];

    wire [`NUM_REGS-1:0] inc_cout;

    genvar gi_sb_inc;
    generate
        for (gi_sb_inc = 0; gi_sb_inc < `NUM_REGS; gi_sb_inc = gi_sb_inc + 1) begin : g_sb_inc
            `ADD_N(u_sb_inc, 4, SB_incd_o[gi_sb_inc], inc_cout[gi_sb_inc], SB_o[gi_sb_inc], 4'b1, 1'b0)
        end
    endgenerate

    wire [`REG_ID_W-1:0] sb_id_wire [0:`NUM_REGS-1];
    assign sb_id_wire[0]  = `CS;
    assign sb_id_wire[1]  = `DS;
    assign sb_id_wire[2]  = `SS;
    assign sb_id_wire[3]  = `ES;
    assign sb_id_wire[4]  = `FS;
    assign sb_id_wire[5]  = `GS;
    assign sb_id_wire[6]  = `EXPS;
    assign sb_id_wire[7]  = `EAX;
    assign sb_id_wire[8]  = `EBX;
    assign sb_id_wire[9]  = `ECX;
    assign sb_id_wire[10] = `EDX;
    assign sb_id_wire[11] = `ESI;
    assign sb_id_wire[12] = `EDI;
    assign sb_id_wire[13] = `ESP;
    assign sb_id_wire[14] = `EBP;
    assign sb_id_wire[15] = `MM0;
    assign sb_id_wire[16] = `MM1;
    assign sb_id_wire[17] = `MM2;
    assign sb_id_wire[18] = `MM3;
    assign sb_id_wire[19] = `MM4;
    assign sb_id_wire[20] = `MM5;
    assign sb_id_wire[21] = `MM6;
    assign sb_id_wire[22] = `MM7;
    assign sb_id_wire[23] = `ETR;
    assign sb_id_wire[24] = `ERROR_REG;
    assign sb_id_wire[25] = `NO_REG;

    // ---------------- shared precomputed signals (driven once) ----------------
    wire cs_wr_to_both_n;
    `INV_N(u_cs_wr_to_both_inv, 1, cs_wr_to_both, cs_wr_to_both_n)

    // dr_path_term = (cs_dr_wr && updateSB && !cs_wr_to_both) || (cs_wr_to_both && updateSB)
    wire dr_path_t1, dr_path_t2, dr_path_term;
    `AND_3(u_dr_path_t1_and,  1, dr_path_t1,   cs_dr_wr,      updateSB, cs_wr_to_both_n)
    `AND_2(u_dr_path_t2_and,  1, dr_path_t2,   cs_wr_to_both, updateSB)
    `OR_2 (u_dr_path_term_or, 1, dr_path_term, dr_path_t1,    dr_path_t2)

    // sr_path_term = cs_sr_wr && updateSB && !cs_wr_to_both
    wire sr_path_term;
    `AND_3(u_sr_path_term_and, 1, sr_path_term, cs_sr_wr, updateSB, cs_wr_to_both_n)

    // eax_path_term = cs_eax_wr && updateSB && !cs_wr_to_both
    wire eax_path_term;
    `AND_3(u_eax_path_term_and, 1, eax_path_term, cs_eax_wr, updateSB, cs_wr_to_both_n)

    wire wb_wr_to_both_n;
    `INV_N(u_wb_wr_to_both_inv, 1, wb_wr_to_both, wb_wr_to_both_n)

    // wb_dr0_or_both = wb_dr0_we || wb_wr_to_both
    wire wb_dr0_or_both;
    `OR_2(u_wb_dr0_or_both_or, 1, wb_dr0_or_both, wb_dr0_we, wb_wr_to_both)

    // wb_dr1_we_n_both = wb_dr1_we && !wb_wr_to_both
    wire wb_dr1_we_n_both;
    `AND_2(u_wb_dr1_we_n_both_and, 1, wb_dr1_we_n_both, wb_dr1_we, wb_wr_to_both_n)

    // ld_st_rep_op = LD_OP || ST_OP || REP_OP
    wire ld_st_rep_op;
    `OR_3(u_ld_st_rep_op_or, 1, ld_st_rep_op, LD_OP, ST_OP, REP_OP)


    // ---------------- sel_inc ----------------
    wire [`NUM_REGS-1:0] sel_inc;

    genvar gi_sel_inc;
    generate
        for (gi_sel_inc = 0; gi_sel_inc < `NUM_REGS; gi_sel_inc = gi_sel_inc + 1) begin : g_sel_inc
            wire dr_eq_id, sr_eq_id, eax_eq_id;
            `CMP_N(u_dr_eq_id_cmp,  `REG_ID_W, dr_eq_id,  dr_id, sb_id_wire[gi_sel_inc])
            `CMP_N(u_sr_eq_id_cmp,  `REG_ID_W, sr_eq_id,  sr_id, sb_id_wire[gi_sel_inc])
            `CMP_N(u_eax_eq_id_cmp, `REG_ID_W, eax_eq_id, `EAX,  sb_id_wire[gi_sel_inc])

            wire dr_term, sr_term, eax_term;
            `AND_2(u_dr_term_and,  1, dr_term,  dr_path_term,  dr_eq_id)
            `AND_2(u_sr_term_and,  1, sr_term,  sr_path_term,  sr_eq_id)
            `AND_2(u_eax_term_and, 1, eax_term, eax_path_term, eax_eq_id)

            `OR_3 (u_sel_inc_or,    1, sel_inc[gi_sel_inc], dr_term, sr_term, eax_term)
            `MUX_2(u_post_inc_mux,  4, SB_post_inc_o[gi_sel_inc], SB_o[gi_sel_inc], SB_incd_o[gi_sel_inc], sel_inc[gi_sel_inc])
        end
    endgenerate



    /////////////////////////////////////////// dec phase ///////////////////////////
    wire [3:0] SB_decd_o     [0:`NUM_REGS-1];

    wire [`NUM_REGS-1:0] dec_cout;

    genvar gi_sb_dec;
    generate
        for (gi_sb_dec = 0; gi_sb_dec < `NUM_REGS; gi_sb_dec = gi_sb_dec + 1) begin : g_sb_dec
            `ADD_N(u_sb_dec, 4, SB_decd_o[gi_sb_dec], dec_cout[gi_sb_dec], SB_post_inc_o[gi_sb_dec], 4'hF, 1'b0)
        end
    endgenerate

    wire [`NUM_REGS-1:0] sel_dec;

    genvar gi_sel_dec;
    generate
        for (gi_sel_dec = 0; gi_sel_dec < `NUM_REGS; gi_sel_dec = gi_sel_dec + 1) begin : g_sel_dec
            wire wb_dr0_eq_id, wb_dr1_eq_id;
            `CMP_N(u_wb_dr0_eq_id_cmp, `REG_ID_W, wb_dr0_eq_id, wb_dr0_id, sb_id_wire[gi_sel_dec])
            `CMP_N(u_wb_dr1_eq_id_cmp, `REG_ID_W, wb_dr1_eq_id, wb_dr1_id, sb_id_wire[gi_sel_dec])

            wire dec_term0, dec_term1;
            `AND_2(u_dec_term0_and, 1, dec_term0, wb_dr0_or_both,   wb_dr0_eq_id)
            `AND_2(u_dec_term1_and, 1, dec_term1, wb_dr1_we_n_both, wb_dr1_eq_id)

            `OR_2 (u_sel_dec_or,   1, sel_dec[gi_sel_dec], dec_term0, dec_term1)
            `MUX_2(u_din_sb_mux,   4, din_SB[gi_sel_dec],  SB_post_inc_o[gi_sel_dec], SB_decd_o[gi_sel_dec], sel_dec[gi_sel_dec])
        end
    endgenerate

    genvar gi_we;
    generate
        for (gi_we = 0; gi_we < `NUM_REGS; gi_we = gi_we + 1) begin : g_we
            `OR_3 (u_we_sb_or,       1, we_SB[gi_we],        sel_inc[gi_we], sel_dec[gi_we], flush)
            `MUX_2(u_din_gated_mux,  4, din_SB_gated[gi_we], din_SB[gi_we],  4'b0, flush)
        end
    endgenerate

    // ---------------- stall logic ----------------
    wire dr_stall, sr_stall, seg0_stall, seg1_stall, sib_base_stall, sib_idx_stall, eax_stall;

    // dr_stall = cs_dr_rd && (LD||ST||REP) && (SB_o[dr_id] != 0)
    wire dr_sb_eq_zero, dr_sb_nz;
    `CMP_N(u_dr_sb_eq_zero_cmp, 4, dr_sb_eq_zero, SB_o[dr_id], 4'b0)
    `INV_N(u_dr_sb_nz_inv,      1, dr_sb_eq_zero, dr_sb_nz)
    `AND_3(u_dr_stall_and,      1, dr_stall, cs_dr_rd, ld_st_rep_op, dr_sb_nz)

    // sr_stall = cs_sr_rd && (LD||ST||REP) && (SB_o[sr_id] != 0)
    wire sr_sb_eq_zero, sr_sb_nz;
    `CMP_N(u_sr_sb_eq_zero_cmp, 4, sr_sb_eq_zero, SB_o[sr_id], 4'b0)
    `INV_N(u_sr_sb_nz_inv,      1, sr_sb_eq_zero, sr_sb_nz)
    `AND_3(u_sr_stall_and,      1, sr_stall, cs_sr_rd, ld_st_rep_op, sr_sb_nz)

    assign eax_stall = 1'b0;

    // seg0_stall = (SB_o[Segment0_ID] != 0)
    wire seg0_sb_eq_zero;
    `CMP_N(u_seg0_sb_eq_zero_cmp, 4, seg0_sb_eq_zero, SB_o[Segment0_ID], 4'b0)
    `INV_N(u_seg0_stall_inv,      1, seg0_sb_eq_zero, seg0_stall)

    // seg1_stall = Segment1_valid && (SB_o[Segment1_ID] != 0)
    wire seg1_sb_eq_zero, seg1_sb_nz;
    `CMP_N(u_seg1_sb_eq_zero_cmp, 4, seg1_sb_eq_zero, SB_o[Segment1_ID], 4'b0)
    `INV_N(u_seg1_sb_nz_inv,      1, seg1_sb_eq_zero, seg1_sb_nz)
    `AND_2(u_seg1_stall_and,      1, seg1_stall, Segment1_valid, seg1_sb_nz)

    // sib_base_stall = cs_sib_size && (SB_o[sib_base_id] != 0)   (cs_sib_size is 1-bit)
    wire sib_base_sb_eq_zero, sib_base_sb_nz;
    `CMP_N(u_sib_base_sb_eq_zero_cmp, 4, sib_base_sb_eq_zero, SB_o[sib_base_id], 4'b0)
    `INV_N(u_sib_base_sb_nz_inv,      1, sib_base_sb_eq_zero, sib_base_sb_nz)
    `AND_2(u_sib_base_stall_and,      1, sib_base_stall, cs_sib_size, sib_base_sb_nz)

    // sib_idx_stall = cs_sib_size && (SB_o[sib_idx_id] != 0)
    wire sib_idx_sb_eq_zero, sib_idx_sb_nz;
    `CMP_N(u_sib_idx_sb_eq_zero_cmp, 4, sib_idx_sb_eq_zero, SB_o[sib_idx_id], 4'b0)
    `INV_N(u_sib_idx_sb_nz_inv,      1, sib_idx_sb_eq_zero, sib_idx_sb_nz)
    `AND_2(u_sib_idx_stall_and,      1, sib_idx_stall, cs_sib_size, sib_idx_sb_nz)

    `OR_7(u_dep_stall_or, 1, depStall_Internal,
          dr_stall, sr_stall, seg0_stall, seg1_stall,
          sib_base_stall, sib_idx_stall, eax_stall)

endmodule
