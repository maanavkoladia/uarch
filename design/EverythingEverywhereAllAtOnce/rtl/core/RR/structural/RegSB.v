// 5-bit equality comparator against a compile-time constant K, using
// caller-supplied pre-inverted bits (in_n) for the K[i]=0 positions.
// This avoids the DC-introduced GTECH_NOT shared inverters that would
// otherwise appear when CMP_N's xnor2$(a, 1'b0) is constant-folded — by
// providing an explicit bufferHInv16$-driven inverted bus, every per-iter
// comparator selects from the same pre-buffered net rather than having
// DC create one anonymous inverter per ID bit.
module eq5_with_inv #(
    parameter [4:0] K = 5'd0
) (
    input  wire [4:0] in,
    input  wire [4:0] in_n,
    output wire       eq
);
    wire [4:0] b;
    //assign b[0] = K[0] ? in[0] : in_n[0];
    //assign b[1] = K[1] ? in[1] : in_n[1];
    //assign b[2] = K[2] ? in[2] : in_n[2];
    //assign b[3] = K[3] ? in[3] : in_n[3];
    //assign b[4] = K[4] ? in[4] : in_n[4];
    `MUX_2(__another_mux__0, 1, b[0], in_n[0], in[0], K[0]);
    `MUX_2(__another_mux__1, 1, b[1], in_n[1], in[1], K[1]);
    `MUX_2(__another_mux__2, 1, b[2], in_n[2], in[2], K[2]);
    `MUX_2(__another_mux__3, 1, b[3], in_n[3], in[3], K[3]);
    `MUX_2(__another_mux__4, 1, b[4], in_n[4], in[4], K[4]);
    // Same NAND3/NAND2/NOR2 reduction tree that MPS_COMP_EQ uses for WIDTH=5.
    wire l0, l1;
    nand3$ u0 (.out(l0), .in0(b[0]), .in1(b[1]), .in2(b[2]));
    nand2$ u1 (.out(l1), .in0(b[3]), .in1(b[4]));
    nor2$  u2 (.out(eq), .in0(l0), .in1(l1));
endmodule

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

    // Port-input flush replication: with NUM_REGS=26 each generate loop below
    // drives 5 loads per iter (1 OR_3 + 4 mux sels) = 130 loads. Two parallel
    // bufferH256$ split the EXE-stage flush net so neither replica exceeds
    // the cell's rated fanout. The producer (EXE/branch_res) already gives us
    // a dedicated cluster wire with no other consumers, so the input here
    // carries exactly two loads.
    wire flush_for_g0, flush_for_g1;
    bufferH256$ u_buf_flush_g0 (.out(flush_for_g0), .in(flush));
    bufferH256$ u_buf_flush_g1 (.out(flush_for_g1), .in(flush));

    //lowkey don't want to use reg ids, nvm might have to
    //nv, maybe not since just use segnment0/1 id since if needed here we will wait.
    //write back will send clear signal in dr0_id, must be able to clear segreg through that

    // bool updateSB;
    // assign updateSB = !depStall_Internal && instructionforward;
    wire depStall_Internal;
    wire depStall_Internal_n;
    `INV_N(u_depStall_Internal_inv, 1, depStall_Internal, depStall_Internal_n)

    // Pre-inverted ID buses for use by eq5_with_inv comparators below.
    // Each bit of *_id_n drives ~26-32 per-iter selectors (one per generate
    // iteration whose constant K[i]=0), so we use bufferHInv64$ per bit
    // (rated drive 64 fanout, delay 0.39ns) instead of INV_N's bufferHInv16$.
    wire [`REG_ID_W-1:0] dr_id_n;
    wire [`REG_ID_W-1:0] sr_id_n;
    wire [`REG_ID_W-1:0] wb_dr0_id_n;
    wire [`REG_ID_W-1:0] wb_dr1_id_n;
    bufferHInv64$ u_inv_dr_id_0 (.out(dr_id_n[0]), .in(dr_id[0]));
    bufferHInv64$ u_inv_dr_id_1 (.out(dr_id_n[1]), .in(dr_id[1]));
    bufferHInv64$ u_inv_dr_id_2 (.out(dr_id_n[2]), .in(dr_id[2]));
    bufferHInv64$ u_inv_dr_id_3 (.out(dr_id_n[3]), .in(dr_id[3]));
    bufferHInv64$ u_inv_dr_id_4 (.out(dr_id_n[4]), .in(dr_id[4]));
    bufferHInv64$ u_inv_sr_id_0 (.out(sr_id_n[0]), .in(sr_id[0]));
    bufferHInv64$ u_inv_sr_id_1 (.out(sr_id_n[1]), .in(sr_id[1]));
    bufferHInv64$ u_inv_sr_id_2 (.out(sr_id_n[2]), .in(sr_id[2]));
    bufferHInv64$ u_inv_sr_id_3 (.out(sr_id_n[3]), .in(sr_id[3]));
    bufferHInv64$ u_inv_sr_id_4 (.out(sr_id_n[4]), .in(sr_id[4]));
    bufferHInv64$ u_inv_wb_dr0_id_0 (.out(wb_dr0_id_n[0]), .in(wb_dr0_id[0]));
    bufferHInv64$ u_inv_wb_dr0_id_1 (.out(wb_dr0_id_n[1]), .in(wb_dr0_id[1]));
    bufferHInv64$ u_inv_wb_dr0_id_2 (.out(wb_dr0_id_n[2]), .in(wb_dr0_id[2]));
    bufferHInv64$ u_inv_wb_dr0_id_3 (.out(wb_dr0_id_n[3]), .in(wb_dr0_id[3]));
    bufferHInv64$ u_inv_wb_dr0_id_4 (.out(wb_dr0_id_n[4]), .in(wb_dr0_id[4]));
    bufferHInv64$ u_inv_wb_dr1_id_0 (.out(wb_dr1_id_n[0]), .in(wb_dr1_id[0]));
    bufferHInv64$ u_inv_wb_dr1_id_1 (.out(wb_dr1_id_n[1]), .in(wb_dr1_id[1]));
    bufferHInv64$ u_inv_wb_dr1_id_2 (.out(wb_dr1_id_n[2]), .in(wb_dr1_id[2]));
    bufferHInv64$ u_inv_wb_dr1_id_3 (.out(wb_dr1_id_n[3]), .in(wb_dr1_id[3]));
    bufferHInv64$ u_inv_wb_dr1_id_4 (.out(wb_dr1_id_n[4]), .in(wb_dr1_id[4]));

    // updateSB replicated: one AND drives the 26 we_SB_mux selects; another drives
    // the 4-bit din_SB_mux selects (104 loads). Splitting lets the lighter we copy
    // sit on a faster bufferH64$ instead of the bufferH256$ needed for din.
    wire updateSB_we;
    wire updateSB_din;
    `AND_2(u_updateSB_and_we,  1, updateSB_we,  depStall_Internal_n, instructionforward)
    `AND_2(u_updateSB_and_din, 1, updateSB_din, depStall_Internal_n, instructionforward)

    wire updateSB_we_buf, updateSB_din_buf;
    bufferH64$  u_buf_updateSB_we  (.out(updateSB_we_buf),  .in(updateSB_we));
    bufferH256$ u_buf_updateSB_din (.out(updateSB_din_buf), .in(updateSB_din));

    // flush enters from EXE.u_br_res with very high external fanout (~285).
    // Inside RegSB it drives 104 loads (g_we_0/g_we_1 generates: OR_3 + MUX_2
    // sel per iteration x 26 regs x 2 phases). Buffering at module entry drops
    // RegSB's contribution to the upstream and3$ fanout from 104 to 1.
    wire flush_buf;
    bufferH1024$ u_buf_flush (.out(flush_buf), .in(flush));

    // 2D arrays indexed by reg id (see reg_ids_define.vh: CS=0 ... NO_REG=25)
    // SB regs duplicated: SB_o_a drives local inc/dec consumers + ECX/CS outputs;
    // SB_o_b drives the 6 wide stall-mux comparators. Both clocked identically.
    // Each Q output is then buffered (per bit) to drop the fanout-6-7 violation.
    wire [3:0] SB_o_a_pre [0:`NUM_REGS-1];
    wire [3:0] SB_o_b_pre [0:`NUM_REGS-1];
    wire [3:0] SB_o_a     [0:`NUM_REGS-1];
    wire [3:0] SB_o_b     [0:`NUM_REGS-1];

    wire       we_SB_0  [0:`NUM_REGS-1];
    wire [3:0] din_SB_0 [0:`NUM_REGS-1];
    wire [3:0] din_SB_gated_0 [0:`NUM_REGS-1];

    wire       we_SB_1  [0:`NUM_REGS-1];
    wire [3:0] din_SB_1 [0:`NUM_REGS-1];
    wire [3:0] din_SB_gated_1 [0:`NUM_REGS-1];

    wire       we_SB  [0:`NUM_REGS-1];
    wire [3:0] din_SB [0:`NUM_REGS-1];

    genvar gi_sb_reg;
    generate
        for (gi_sb_reg = 0; gi_sb_reg < `NUM_REGS; gi_sb_reg = gi_sb_reg + 1) begin : g_sb_reg
            `REG_RST_WE(u_sb_reg_a, 4, clk, rst, we_SB[gi_sb_reg], din_SB[gi_sb_reg], SB_o_a_pre[gi_sb_reg])
            `REG_RST_WE(u_sb_reg_b, 4, clk, rst, we_SB[gi_sb_reg], din_SB[gi_sb_reg], SB_o_b_pre[gi_sb_reg])
            bufferH16$ u_buf_SB_o_a_0 (.out(SB_o_a[gi_sb_reg][0]), .in(SB_o_a_pre[gi_sb_reg][0]));
            bufferH16$ u_buf_SB_o_a_1 (.out(SB_o_a[gi_sb_reg][1]), .in(SB_o_a_pre[gi_sb_reg][1]));
            bufferH16$ u_buf_SB_o_a_2 (.out(SB_o_a[gi_sb_reg][2]), .in(SB_o_a_pre[gi_sb_reg][2]));
            bufferH16$ u_buf_SB_o_a_3 (.out(SB_o_a[gi_sb_reg][3]), .in(SB_o_a_pre[gi_sb_reg][3]));
            bufferH16$ u_buf_SB_o_b_0 (.out(SB_o_b[gi_sb_reg][0]), .in(SB_o_b_pre[gi_sb_reg][0]));
            bufferH16$ u_buf_SB_o_b_1 (.out(SB_o_b[gi_sb_reg][1]), .in(SB_o_b_pre[gi_sb_reg][1]));
            bufferH16$ u_buf_SB_o_b_2 (.out(SB_o_b[gi_sb_reg][2]), .in(SB_o_b_pre[gi_sb_reg][2]));
            bufferH16$ u_buf_SB_o_b_3 (.out(SB_o_b[gi_sb_reg][3]), .in(SB_o_b_pre[gi_sb_reg][3]));
            `MUX_2(u_sb_we_mux,  1, we_SB[gi_sb_reg],  we_SB_0[gi_sb_reg],  we_SB_1[gi_sb_reg],  updateSB_we_buf)
            `MUX_2(u_sb_din_mux, 4, din_SB[gi_sb_reg], din_SB_gated_0[gi_sb_reg], din_SB_gated_1[gi_sb_reg], updateSB_din_buf)
        end
    endgenerate

    // busy_b[i] = (SB_o_b[i] != 0). Computed once at the SB Q outputs so the
    // OR_4 reduction runs in parallel with the per-bit Q buffers above instead
    // of sitting on the dep_stall critical path. All six stall consumers
    // (dr/sr/seg0/seg1/sib_base/sib_idx) read 1-bit busy flags.
    //
    // Duplicated into two parallel copies so the or4_N$ nand4$ drive stays in
    // spec without inserting a buffer (which would put a gate level back on
    // dep_stall and undo the precollapse gain):
    //   busy_b_mux[i] -> u_dr_sb_mux + u_sr_sb_mux                 (fanout 2)
    //   busy_b_idx[i] -> seg0 / seg1 / sib_base / sib_idx decoders (fanout 4)
    wire busy_b_mux [0:`NUM_REGS-1];
    wire busy_b_idx [0:`NUM_REGS-1];
    genvar gi_busy;
    generate
        for (gi_busy = 0; gi_busy < `NUM_REGS; gi_busy = gi_busy + 1) begin : g_busy_b
            `OR_4(u_busy_b_mux_or, 1, busy_b_mux[gi_busy],
                  SB_o_b[gi_busy][0], SB_o_b[gi_busy][1],
                  SB_o_b[gi_busy][2], SB_o_b[gi_busy][3])
            `OR_4(u_busy_b_idx_or, 1, busy_b_idx[gi_busy],
                  SB_o_b[gi_busy][0], SB_o_b[gi_busy][1],
                  SB_o_b[gi_busy][2], SB_o_b[gi_busy][3])
        end
    endgenerate

    // bool cs_wr_to_both;
    // assign cs_wr_to_both = (cs_dr_wr && cs_sr_wr && (dr_id == sr_id))
    //                     || (cs_dr_wr && cs_eax_wr && (dr_id == EAX));
    wire cs_wr_to_both;
    wire cs_dr_eq_sr;
    wire cs_dr_eq_eax;
    wire cs_wr_dr_sr;
    wire cs_wr_dr_eax;
    `CMP_N(u_cs_dr_eq_sr_cmp,  `REG_ID_W, cs_dr_eq_sr,  dr_id[`REG_ID_W-1:0], sr_id[`REG_ID_W-1:0])
    // (dr_id == EAX) — use eq5_with_inv with K=7 so DC consumes the dr_id_n
    // bits (bufferHInv64$) we already pre-buffered, instead of inserting its own
    // GTECH_NOT inverter for the K[3]=K[4]=0 bit positions.
    eq5_with_inv #(.K(`EAX)) u_cs_dr_eq_eax_cmp (.in(dr_id), .in_n(dr_id_n), .eq(cs_dr_eq_eax));
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
    // ecx_sb / codeSeg_sb are "is the SB nibble non-zero?" — equivalent to a 4-bit
    // OR. Computing the OR directly avoids `CMP_N(X, 4'b0)` whose internal
    // xnor2$(X[i], 1'b0) DC constant-folds into a shared GTECH_NOT inverter.
    `OR_4(u_ecx_sb_or,     1, ecx_sb,     SB_o_a[`ECX][0], SB_o_a[`ECX][1], SB_o_a[`ECX][2], SB_o_a[`ECX][3])
    `OR_4(u_codeseg_sb_or, 1, codeSeg_sb, SB_o_a[`CS][0],  SB_o_a[`CS][1],  SB_o_a[`CS][2],  SB_o_a[`CS][3])


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
    // cs_wr_to_both_n / wb_wr_to_both_n replicated to feed each path-term twin
    // independently and avoid a fanout pinch on the shared inverter.
    wire cs_wr_to_both_n_a, cs_wr_to_both_n_b;
    `INV_N(u_cs_wr_to_both_inv_a, 1, cs_wr_to_both, cs_wr_to_both_n_a)
    `INV_N(u_cs_wr_to_both_inv_b, 1, cs_wr_to_both, cs_wr_to_both_n_b)

    wire wb_wr_to_both_n_a, wb_wr_to_both_n_b;
    `INV_N(u_wb_wr_to_both_inv_a, 1, wb_wr_to_both, wb_wr_to_both_n_a)
    `INV_N(u_wb_wr_to_both_inv_b, 1, wb_wr_to_both, wb_wr_to_both_n_b)

    // path_term signals replicated _a (g_sel_inc_0 / g_sel_dec_0) and
    // _b (g_sel_inc_1 / g_sel_dec_1) so each copy fans out to only 26 loads.
    // Each copy is wrapped in bufferH64$ to drive the 26-wide generate.

    // dr_path_term_{a,b} = (cs_dr_wr && !cs_wr_to_both) || cs_wr_to_both
    wire dr_path_t1_a, dr_path_term_a, dr_path_term_a_buf;
    wire dr_path_t1_b, dr_path_term_b, dr_path_term_b_buf;
    `AND_2(u_dr_path_t1_a_and,  1, dr_path_t1_a,   cs_dr_wr,  cs_wr_to_both_n_a)
    `OR_2 (u_dr_path_term_a_or, 1, dr_path_term_a, dr_path_t1_a, cs_wr_to_both)
    bufferH64$ u_buf_dr_path_term_a (.out(dr_path_term_a_buf), .in(dr_path_term_a));
    `AND_2(u_dr_path_t1_b_and,  1, dr_path_t1_b,   cs_dr_wr,  cs_wr_to_both_n_b)
    `OR_2 (u_dr_path_term_b_or, 1, dr_path_term_b, dr_path_t1_b, cs_wr_to_both)
    bufferH64$ u_buf_dr_path_term_b (.out(dr_path_term_b_buf), .in(dr_path_term_b));

    // sr_path_term_{a,b} = cs_sr_wr && !cs_wr_to_both
    wire sr_path_term_a, sr_path_term_a_buf;
    wire sr_path_term_b, sr_path_term_b_buf;
    `AND_2(u_sr_path_term_a_and, 1, sr_path_term_a, cs_sr_wr, cs_wr_to_both_n_a)
    bufferH64$ u_buf_sr_path_term_a (.out(sr_path_term_a_buf), .in(sr_path_term_a));
    `AND_2(u_sr_path_term_b_and, 1, sr_path_term_b, cs_sr_wr, cs_wr_to_both_n_b)
    bufferH64$ u_buf_sr_path_term_b (.out(sr_path_term_b_buf), .in(sr_path_term_b));

    // eax_path_term_{a,b} = cs_eax_wr && !cs_wr_to_both
    wire eax_path_term_a, eax_path_term_a_buf;
    wire eax_path_term_b, eax_path_term_b_buf;
    `AND_2(u_eax_path_term_a_and, 1, eax_path_term_a, cs_eax_wr, cs_wr_to_both_n_a)
    bufferH64$ u_buf_eax_path_term_a (.out(eax_path_term_a_buf), .in(eax_path_term_a));
    `AND_2(u_eax_path_term_b_and, 1, eax_path_term_b, cs_eax_wr, cs_wr_to_both_n_b)
    bufferH64$ u_buf_eax_path_term_b (.out(eax_path_term_b_buf), .in(eax_path_term_b));

    // wb_dr0_or_both_{a,b} = wb_dr0_we || wb_wr_to_both
    wire wb_dr0_or_both_a, wb_dr0_or_both_a_buf;
    wire wb_dr0_or_both_b, wb_dr0_or_both_b_buf;
    `OR_2(u_wb_dr0_or_both_a_or, 1, wb_dr0_or_both_a, wb_dr0_we, wb_wr_to_both)
    bufferH64$ u_buf_wb_dr0_or_both_a (.out(wb_dr0_or_both_a_buf), .in(wb_dr0_or_both_a));
    `OR_2(u_wb_dr0_or_both_b_or, 1, wb_dr0_or_both_b, wb_dr0_we, wb_wr_to_both)
    bufferH64$ u_buf_wb_dr0_or_both_b (.out(wb_dr0_or_both_b_buf), .in(wb_dr0_or_both_b));

    // wb_dr1_we_n_both_{a,b} = wb_dr1_we && !wb_wr_to_both
    wire wb_dr1_we_n_both_a, wb_dr1_we_n_both_a_buf;
    wire wb_dr1_we_n_both_b, wb_dr1_we_n_both_b_buf;
    `AND_2(u_wb_dr1_we_n_both_a_and, 1, wb_dr1_we_n_both_a, wb_dr1_we, wb_wr_to_both_n_a)
    bufferH64$ u_buf_wb_dr1_we_n_both_a (.out(wb_dr1_we_n_both_a_buf), .in(wb_dr1_we_n_both_a));
    `AND_2(u_wb_dr1_we_n_both_b_and, 1, wb_dr1_we_n_both_b, wb_dr1_we, wb_wr_to_both_n_b)
    bufferH64$ u_buf_wb_dr1_we_n_both_b (.out(wb_dr1_we_n_both_b_buf), .in(wb_dr1_we_n_both_b));

    // ld_st_rep_op = LD_OP || ST_OP || REP_OP
    wire ld_st_rep_op;
    `OR_3(u_ld_st_rep_op_or, 1, ld_st_rep_op, LD_OP, ST_OP, REP_OP)



    //////////////////////////////////////////// increment phase updateSB = 0 //////////////////////////
    wire [3:0] SB_post_inc0_o [0:`NUM_REGS-1];
    wire [3:0] SB_incd0_o     [0:`NUM_REGS-1];

    wire [`NUM_REGS-1:0] inc_cout_0;

    genvar gi_sb_inc_0;
    generate
        for (gi_sb_inc_0 = 0; gi_sb_inc_0 < `NUM_REGS; gi_sb_inc_0 = gi_sb_inc_0 + 1) begin : g_sb_inc_0
            `ADD_N(u_sb_inc, 4, SB_incd0_o[gi_sb_inc_0], inc_cout_0[gi_sb_inc_0], SB_o_a[gi_sb_inc_0], 4'b1, 1'b0)
        end
    endgenerate

    // ---------------- sel_inc_0 ----------------
    wire [`NUM_REGS-1:0] sel_inc_0_pre;
    wire [`NUM_REGS-1:0] sel_inc_0;

    genvar gi_sel_inc_0;
    generate
        for (gi_sel_inc_0 = 0; gi_sel_inc_0 < `NUM_REGS; gi_sel_inc_0 = gi_sel_inc_0 + 1) begin : g_sel_inc_0
            wire dr_eq_id, sr_eq_id, eax_eq_id;
            eq5_with_inv #(.K(gi_sel_inc_0)) u_dr_eq_id_cmp (.in(dr_id), .in_n(dr_id_n), .eq(dr_eq_id));
            eq5_with_inv #(.K(gi_sel_inc_0)) u_sr_eq_id_cmp (.in(sr_id), .in_n(sr_id_n), .eq(sr_eq_id));
            `CMP_N(u_eax_eq_id_cmp, `REG_ID_W, eax_eq_id, `EAX,  sb_id_wire[gi_sel_inc_0])

            wire dr_term, sr_term, eax_term;
            `AND_2(u_dr_term_and,  1, dr_term,  dr_path_term_a_buf,  dr_eq_id)
            `AND_2(u_sr_term_and,  1, sr_term,  sr_path_term_a_buf,  sr_eq_id)
            `AND_2(u_eax_term_and, 1, eax_term, eax_path_term_a_buf, eax_eq_id)

            wire sel_inc_ungated;
            `OR_3 (u_sel_inc_or,    1, sel_inc_ungated, dr_term, sr_term, eax_term)
            `AND_2 (u_sel_updatesb, 1, sel_inc_0_pre[gi_sel_inc_0], sel_inc_ungated, 1'b0)          //updateSB = 0
            bufferH16$ u_buf_sel_inc_0 (.out(sel_inc_0[gi_sel_inc_0]), .in(sel_inc_0_pre[gi_sel_inc_0]));
            `MUX_2(u_post_inc_mux,  4, SB_post_inc0_o[gi_sel_inc_0], SB_o_a[gi_sel_inc_0], SB_incd0_o[gi_sel_inc_0], sel_inc_0[gi_sel_inc_0])
        end
    endgenerate



    /////////////////////////////////////////// dec phase , updateSB = 0 ///////////////////////////
    wire [3:0] SB_decd0_o     [0:`NUM_REGS-1];

    wire [`NUM_REGS-1:0] dec_cout_0;

    genvar gi_sb_dec_0;
    generate
        for (gi_sb_dec_0 = 0; gi_sb_dec_0 < `NUM_REGS; gi_sb_dec_0 = gi_sb_dec_0 + 1) begin : g_sb_dec_0
            `ADD_N(u_sb_dec, 4, SB_decd0_o[gi_sb_dec_0], dec_cout_0[gi_sb_dec_0], SB_post_inc0_o[gi_sb_dec_0], 4'hF, 1'b0)
        end
    endgenerate

    wire [`NUM_REGS-1:0] sel_dec_0_pre;
    wire [`NUM_REGS-1:0] sel_dec_0;

    genvar gi_sel_dec_0;
    generate
        for (gi_sel_dec_0 = 0; gi_sel_dec_0 < `NUM_REGS; gi_sel_dec_0 = gi_sel_dec_0 + 1) begin : g_sel_dec_0
            wire wb_dr0_eq_id, wb_dr1_eq_id;
            eq5_with_inv #(.K(gi_sel_dec_0)) u_wb_dr0_eq_id_cmp (.in(wb_dr0_id), .in_n(wb_dr0_id_n), .eq(wb_dr0_eq_id));
            eq5_with_inv #(.K(gi_sel_dec_0)) u_wb_dr1_eq_id_cmp (.in(wb_dr1_id), .in_n(wb_dr1_id_n), .eq(wb_dr1_eq_id));

            wire dec_term0, dec_term1;
            `AND_2(u_dec_term0_and, 1, dec_term0, wb_dr0_or_both_a_buf,    wb_dr0_eq_id)
            `AND_2(u_dec_term1_and, 1, dec_term1, wb_dr1_we_n_both_a_buf,  wb_dr1_eq_id)

            `OR_2 (u_sel_dec_or,   1, sel_dec_0_pre[gi_sel_dec_0], dec_term0, dec_term1)
            bufferH16$ u_buf_sel_dec_0 (.out(sel_dec_0[gi_sel_dec_0]), .in(sel_dec_0_pre[gi_sel_dec_0]));
            `MUX_2(u_din_sb_mux,   4, din_SB_0[gi_sel_dec_0],  SB_post_inc0_o[gi_sel_dec_0], SB_decd0_o[gi_sel_dec_0], sel_dec_0[gi_sel_dec_0])
        end
    endgenerate

    genvar gi_we_0;
    generate
        for (gi_we_0 = 0; gi_we_0 < `NUM_REGS; gi_we_0 = gi_we_0 + 1) begin : g_we_0
            `OR_3 (u_we_sb_or,       1, we_SB_0[gi_we_0],        sel_inc_0[gi_we_0], sel_dec_0[gi_we_0], flush_for_g0)
            `MUX_2(u_din_gated_mux,  4, din_SB_gated_0[gi_we_0], din_SB_0[gi_we_0],  4'b0, flush_for_g0)
        end
    endgenerate


        //////////////////////////////////////////// increment phase updateSB = 1 //////////////////////////
    wire [3:0] SB_post_inc1_o [0:`NUM_REGS-1];
    wire [3:0] SB_incd1_o     [0:`NUM_REGS-1];

    wire [`NUM_REGS-1:0] inc_cout_1;

    genvar gi_sb_inc_1;
    generate
        for (gi_sb_inc_1 = 0; gi_sb_inc_1 < `NUM_REGS; gi_sb_inc_1 = gi_sb_inc_1 + 1) begin : g_sb_inc_1
            `ADD_N(u_sb_inc, 4, SB_incd1_o[gi_sb_inc_1], inc_cout_1[gi_sb_inc_1], SB_o_a[gi_sb_inc_1], 4'b1, 1'b0)
        end
    endgenerate

    // ---------------- sel_inc_1 ----------------
    wire [`NUM_REGS-1:0] sel_inc_1_pre;
    wire [`NUM_REGS-1:0] sel_inc_1;

    genvar gi_sel_inc_1;
    generate
        for (gi_sel_inc_1 = 0; gi_sel_inc_1 < `NUM_REGS; gi_sel_inc_1 = gi_sel_inc_1 + 1) begin : g_sel_inc_1
            wire dr_eq_id, sr_eq_id, eax_eq_id;
            eq5_with_inv #(.K(gi_sel_inc_1)) u_dr_eq_id_cmp (.in(dr_id), .in_n(dr_id_n), .eq(dr_eq_id));
            eq5_with_inv #(.K(gi_sel_inc_1)) u_sr_eq_id_cmp (.in(sr_id), .in_n(sr_id_n), .eq(sr_eq_id));
            `CMP_N(u_eax_eq_id_cmp, `REG_ID_W, eax_eq_id, `EAX,  sb_id_wire[gi_sel_inc_1])

            wire dr_term, sr_term, eax_term;
            `AND_2(u_dr_term_and,  1, dr_term,  dr_path_term_b_buf,  dr_eq_id)
            `AND_2(u_sr_term_and,  1, sr_term,  sr_path_term_b_buf,  sr_eq_id)
            `AND_2(u_eax_term_and, 1, eax_term, eax_path_term_b_buf, eax_eq_id)

            wire sel_inc_ungated;
            `OR_3 (u_sel_inc_or,    1, sel_inc_ungated, dr_term, sr_term, eax_term)
            `AND_2 (u_sel_updatesb, 1, sel_inc_1_pre[gi_sel_inc_1], sel_inc_ungated, 1'b1)          //updateSB = 1
            bufferH16$ u_buf_sel_inc_1 (.out(sel_inc_1[gi_sel_inc_1]), .in(sel_inc_1_pre[gi_sel_inc_1]));
            `MUX_2(u_post_inc_mux,  4, SB_post_inc1_o[gi_sel_inc_1], SB_o_a[gi_sel_inc_1], SB_incd1_o[gi_sel_inc_1], sel_inc_1[gi_sel_inc_1])
        end
    endgenerate



    /////////////////////////////////////////// dec phase , updateSB = 1 ///////////////////////////
    wire [3:0] SB_decd1_o     [0:`NUM_REGS-1];

    wire [`NUM_REGS-1:0] dec_cout_1;

    genvar gi_sb_dec_1;
    generate
        for (gi_sb_dec_1 = 0; gi_sb_dec_1 < `NUM_REGS; gi_sb_dec_1 = gi_sb_dec_1 + 1) begin : g_sb_dec_1
            `ADD_N(u_sb_dec, 4, SB_decd1_o[gi_sb_dec_1], dec_cout_1[gi_sb_dec_1], SB_post_inc1_o[gi_sb_dec_1], 4'hF, 1'b0)
        end
    endgenerate

    wire [`NUM_REGS-1:0] sel_dec_1_pre;
    wire [`NUM_REGS-1:0] sel_dec_1;

    genvar gi_sel_dec_1;
    generate
        for (gi_sel_dec_1 = 0; gi_sel_dec_1 < `NUM_REGS; gi_sel_dec_1 = gi_sel_dec_1 + 1) begin : g_sel_dec_1
            wire wb_dr0_eq_id, wb_dr1_eq_id;
            eq5_with_inv #(.K(gi_sel_dec_1)) u_wb_dr0_eq_id_cmp (.in(wb_dr0_id), .in_n(wb_dr0_id_n), .eq(wb_dr0_eq_id));
            eq5_with_inv #(.K(gi_sel_dec_1)) u_wb_dr1_eq_id_cmp (.in(wb_dr1_id), .in_n(wb_dr1_id_n), .eq(wb_dr1_eq_id));

            wire dec_term0, dec_term1;
            `AND_2(u_dec_term0_and, 1, dec_term0, wb_dr0_or_both_b_buf,   wb_dr0_eq_id)
            `AND_2(u_dec_term1_and, 1, dec_term1, wb_dr1_we_n_both_b_buf, wb_dr1_eq_id)

            `OR_2 (u_sel_dec_or,   1, sel_dec_1_pre[gi_sel_dec_1], dec_term0, dec_term1)
            bufferH16$ u_buf_sel_dec_1 (.out(sel_dec_1[gi_sel_dec_1]), .in(sel_dec_1_pre[gi_sel_dec_1]));
            `MUX_2(u_din_sb_mux,   4, din_SB_1[gi_sel_dec_1],  SB_post_inc1_o[gi_sel_dec_1], SB_decd1_o[gi_sel_dec_1], sel_dec_1[gi_sel_dec_1])
        end
    endgenerate

    genvar gi_we_1;
    generate
        for (gi_we_1 = 0; gi_we_1 < `NUM_REGS; gi_we_1 = gi_we_1 + 1) begin : g_we_1
            `OR_3 (u_we_sb_or,       1, we_SB_1[gi_we_1],        sel_inc_1[gi_we_1], sel_dec_1[gi_we_1], flush_for_g1)
            `MUX_2(u_din_gated_mux,  4, din_SB_gated_1[gi_we_1], din_SB_1[gi_we_1],  4'b0, flush_for_g1)
        end
    endgenerate




    // ---------------- stall logic ----------------
    wire dr_stall, sr_stall, seg0_stall, seg1_stall, sib_base_stall, sib_idx_stall, eax_stall;

    // Each stall check is "(SB_o_b[X] != 0)". The OR_4 reduction has been
    // hoisted to the busy_b[] generate above (runs in parallel with the SB Q
    // buffers), so every consumer now reads a 1-bit busy flag.

    // dr_stall / sr_stall: explicit MUX_32 instead of `assign w = busy_b[X]`
    // — DC's auto-decoder for the array index was emitting GTECH_NOT inverters
    // on bits 3 and 4 of dr_id / sr_id (fanouts 8 and 16). MUX_32 elaborates to
    // an MPS_MUX_IN32 tree of mux4$ cells whose select bits are consumed directly,
    // no GTECH_NOT inserted. Mux is now 1-bit wide; trailing OR_4 deleted.

    // dr_stall = cs_dr_rd && (LD||ST||REP) && busy_b_mux[dr_id]
    wire dr_sb_nz;
    `MUX_32(u_dr_sb_mux, 1, dr_sb_nz,
        busy_b_mux[ 0], busy_b_mux[ 1], busy_b_mux[ 2], busy_b_mux[ 3],
        busy_b_mux[ 4], busy_b_mux[ 5], busy_b_mux[ 6], busy_b_mux[ 7],
        busy_b_mux[ 8], busy_b_mux[ 9], busy_b_mux[10], busy_b_mux[11],
        busy_b_mux[12], busy_b_mux[13], busy_b_mux[14], busy_b_mux[15],
        busy_b_mux[16], busy_b_mux[17], busy_b_mux[18], busy_b_mux[19],
        busy_b_mux[20], busy_b_mux[21], busy_b_mux[22], busy_b_mux[23],
        busy_b_mux[24], busy_b_mux[25],           1'b0,           1'b0,
                  1'b0,           1'b0,           1'b0,           1'b0,
        dr_id)
    `AND_3(u_dr_stall_and, 1, dr_stall, cs_dr_rd, ld_st_rep_op, dr_sb_nz)

    // sr_stall = cs_sr_rd && (LD||ST||REP) && busy_b_mux[sr_id]
    wire sr_sb_nz;
    `MUX_32(u_sr_sb_mux, 1, sr_sb_nz,
        busy_b_mux[ 0], busy_b_mux[ 1], busy_b_mux[ 2], busy_b_mux[ 3],
        busy_b_mux[ 4], busy_b_mux[ 5], busy_b_mux[ 6], busy_b_mux[ 7],
        busy_b_mux[ 8], busy_b_mux[ 9], busy_b_mux[10], busy_b_mux[11],
        busy_b_mux[12], busy_b_mux[13], busy_b_mux[14], busy_b_mux[15],
        busy_b_mux[16], busy_b_mux[17], busy_b_mux[18], busy_b_mux[19],
        busy_b_mux[20], busy_b_mux[21], busy_b_mux[22], busy_b_mux[23],
        busy_b_mux[24], busy_b_mux[25],           1'b0,           1'b0,
                  1'b0,           1'b0,           1'b0,           1'b0,
        sr_id)
    `AND_3(u_sr_stall_and, 1, sr_stall, cs_sr_rd, ld_st_rep_op, sr_sb_nz)

    assign eax_stall = 1'b0;

    // seg0_stall    = busy_b_idx[Segment0_ID]
    // seg1_stall    = Segment1_valid && busy_b_idx[Segment1_ID]
    // sib_base_stall= cs_sib_size    && busy_b_idx[sib_base_id]
    // sib_idx_stall = cs_sib_size    && busy_b_idx[sib_idx_id]
    //
    // Variable-indexed reads into the busy_b_idx[] unpacked array were letting
    // DC infer its own one-hot decode (AND-OR tree) for each consumer. Replaced
    // with explicit MUX_32 instances — same pattern as u_dr_sb_mux / u_sr_sb_mux
    // — so the index bits drive a structural MPS_MUX_IN32 (mux4$ tree) directly
    // and no decode logic is inferred.
    wire seg0_sb_nz, seg1_sb_nz, sib_base_sb_nz, sib_idx_sb_nz;

    `MUX_32(u_seg0_sb_mux, 1, seg0_sb_nz,
        busy_b_idx[ 0], busy_b_idx[ 1], busy_b_idx[ 2], busy_b_idx[ 3],
        busy_b_idx[ 4], busy_b_idx[ 5], busy_b_idx[ 6], busy_b_idx[ 7],
        busy_b_idx[ 8], busy_b_idx[ 9], busy_b_idx[10], busy_b_idx[11],
        busy_b_idx[12], busy_b_idx[13], busy_b_idx[14], busy_b_idx[15],
        busy_b_idx[16], busy_b_idx[17], busy_b_idx[18], busy_b_idx[19],
        busy_b_idx[20], busy_b_idx[21], busy_b_idx[22], busy_b_idx[23],
        busy_b_idx[24], busy_b_idx[25],           1'b0,           1'b0,
                  1'b0,           1'b0,           1'b0,           1'b0,
        Segment0_ID)
    assign seg0_stall = seg0_sb_nz;

    `MUX_32(u_seg1_sb_mux, 1, seg1_sb_nz,
        busy_b_idx[ 0], busy_b_idx[ 1], busy_b_idx[ 2], busy_b_idx[ 3],
        busy_b_idx[ 4], busy_b_idx[ 5], busy_b_idx[ 6], busy_b_idx[ 7],
        busy_b_idx[ 8], busy_b_idx[ 9], busy_b_idx[10], busy_b_idx[11],
        busy_b_idx[12], busy_b_idx[13], busy_b_idx[14], busy_b_idx[15],
        busy_b_idx[16], busy_b_idx[17], busy_b_idx[18], busy_b_idx[19],
        busy_b_idx[20], busy_b_idx[21], busy_b_idx[22], busy_b_idx[23],
        busy_b_idx[24], busy_b_idx[25],           1'b0,           1'b0,
                  1'b0,           1'b0,           1'b0,           1'b0,
        Segment1_ID)
    `AND_2(u_seg1_stall_and, 1, seg1_stall, Segment1_valid, seg1_sb_nz)

    `MUX_32(u_sib_base_sb_mux, 1, sib_base_sb_nz,
        busy_b_idx[ 0], busy_b_idx[ 1], busy_b_idx[ 2], busy_b_idx[ 3],
        busy_b_idx[ 4], busy_b_idx[ 5], busy_b_idx[ 6], busy_b_idx[ 7],
        busy_b_idx[ 8], busy_b_idx[ 9], busy_b_idx[10], busy_b_idx[11],
        busy_b_idx[12], busy_b_idx[13], busy_b_idx[14], busy_b_idx[15],
        busy_b_idx[16], busy_b_idx[17], busy_b_idx[18], busy_b_idx[19],
        busy_b_idx[20], busy_b_idx[21], busy_b_idx[22], busy_b_idx[23],
        busy_b_idx[24], busy_b_idx[25],           1'b0,           1'b0,
                  1'b0,           1'b0,           1'b0,           1'b0,
        sib_base_id)
    `AND_2(u_sib_base_stall_and, 1, sib_base_stall, cs_sib_size, sib_base_sb_nz)

    `MUX_32(u_sib_idx_sb_mux, 1, sib_idx_sb_nz,
        busy_b_idx[ 0], busy_b_idx[ 1], busy_b_idx[ 2], busy_b_idx[ 3],
        busy_b_idx[ 4], busy_b_idx[ 5], busy_b_idx[ 6], busy_b_idx[ 7],
        busy_b_idx[ 8], busy_b_idx[ 9], busy_b_idx[10], busy_b_idx[11],
        busy_b_idx[12], busy_b_idx[13], busy_b_idx[14], busy_b_idx[15],
        busy_b_idx[16], busy_b_idx[17], busy_b_idx[18], busy_b_idx[19],
        busy_b_idx[20], busy_b_idx[21], busy_b_idx[22], busy_b_idx[23],
        busy_b_idx[24], busy_b_idx[25],           1'b0,           1'b0,
                  1'b0,           1'b0,           1'b0,           1'b0,
        sib_idx_id)
    `AND_2(u_sib_idx_stall_and, 1, sib_idx_stall, cs_sib_size, sib_idx_sb_nz)

    `OR_7(u_dep_stall_or, 1, depStall_Internal,
          dr_stall, sr_stall, seg0_stall, seg1_stall,
          sib_base_stall, sib_idx_stall, eax_stall)

endmodule
