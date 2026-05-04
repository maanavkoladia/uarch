//=============================================================================
// RegSB -- pure Verilog 2005 structural port of rtl/core/RR/RegSB.sv
//
// 26 8-bit counters (one per reg_ids_e slot) tracking pending writes.
// Each cycle: counter_next = counter + inc - dec   (mod 256), where
//   - inc comes from rename-stage writes (cs_dr_wr/cs_sr_wr/cs_eax_wr),
//     gated by updateSB = ~dep_stall & instructionforward
//   - dec comes from writeback (wb_dr0_we/wb_dr1_we), unconditional
//
// Reset / flush handling:
//   REG_RST_WE has an *async* active-low reset. Per project convention only
//   the rst input may drive that port. flush / callFlush / farFlush are
//   handled SYNCHRONOUSLY by muxing each slot's per-cycle update to 8'h00
//   when any flush is asserted; counters then clear on the next posedge.
//   Driving rst with a fold of these signals would clear the SB
//   asynchronously and break downstream stages that observe the SB on the
//   same edge as the flush.
//
// All SV struct/enum types are unrolled to bare wires:
//   bool      -> wire
//   reg_ids_e -> wire [4:0]   (NUM_REGS=26 -> $clog2(26)=5)
//
// Numeric reg_ids_e values used in CMP constants below:
//   CS=0  DS=1  SS=2  ES=3  FS=4  GS=5  EXPS=6
//   EAX=7 EBX=8 ECX=9 EDX=10 ESI=11 EDI=12 ESP=13 EBP=14
//   MM0=15 MM1=16 MM2=17 MM3=18 MM4=19 MM5=20 MM6=21 MM7=22
//   ETR=23 ERROR_REG=24 NO_REG=25
//=============================================================================
module RegSB (
    input  wire        clk,
    input  wire        rst,

    input  wire        instructionforward,

    input  wire [4:0]  dr_id,
    input  wire [4:0]  sr_id,
    input  wire [4:0]  sib_base_id,
    input  wire [4:0]  sib_idx_id,

    input  wire [4:0]  wb_dr0_id,
    input  wire        wb_dr0_we,
    input  wire [4:0]  wb_dr1_id,
    input  wire        wb_dr1_we,

    input  wire        cs_sib_size,

    input  wire        cs_dr_wr,
    input  wire        cs_sr_wr,
    input  wire        cs_dr_rd,
    input  wire        cs_sr_rd,

    input  wire        cs_eax_rd,
    input  wire        cs_eax_wr,

    input  wire [4:0]  Segment0_ID,
    input  wire [4:0]  Segment1_ID,
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

    //=========================================================================
    // Synchronous flush signal
    //   SV: if (flush || callFlush || farFlush) SCORE_BOARD <= '{default:'0};
    // Used to mux every slot's next-counter to 8'h00 (synchronous clear).
    // It does NOT feed any REG_RST_WE.rst port -- async reset is rst alone.
    //=========================================================================
    wire any_flush;
    `OR_3(or_any_flush, 1, any_flush, flush, callFlush, farFlush)             // SV: (flush || callFlush || farFlush)

    //=========================================================================
    // dep_stall output  (drives both module output and feedback for updateSB)
    //   SV: assign dep_stall = depStall_Internal;
    //=========================================================================
    wire dep_stall_internal;
    assign dep_stall = dep_stall_internal;                                    // SV: assign dep_stall = depStall_Internal;

    //=========================================================================
    // updateSB = ~depStall_Internal & instructionforward
    //   SV: assign updateSB = !depStall_Internal && instructionforward;
    //=========================================================================
    wire dep_stall_n;
    wire updateSB;
    `INV_N(inv_dep_stall, 1, dep_stall_internal, dep_stall_n)                 // SV: !depStall_Internal
    `AND_2(and_updateSB,  1, updateSB, dep_stall_n, instructionforward)       // SV: !depStall_Internal && instructionforward

    //=========================================================================
    // cs_wr_to_both = cs_dr_wr & cs_sr_wr & (dr_id == sr_id)
    //   SV: assign cs_wr_to_both = cs_dr_wr && cs_sr_wr && (dr_id == sr_id);
    //=========================================================================
    wire dr_eq_sr;
    wire cs_wr_to_both;
    wire not_cs_wr_to_both;
    `CMP_N(cmp_dr_eq_sr,         5, dr_eq_sr,          dr_id, sr_id)          // SV: (dr_id == sr_id)
    `AND_3(and_cs_wr_to_both,    1, cs_wr_to_both,     cs_dr_wr, cs_sr_wr, dr_eq_sr) // SV: cs_dr_wr && cs_sr_wr && (dr_id==sr_id)
    `INV_N(inv_not_cs_wr_to_both,1, cs_wr_to_both,     not_cs_wr_to_both)     // SV: !cs_wr_to_both

    //=========================================================================
    // wb_wr_to_both = wb_dr0_we & wb_dr1_we & (wb_dr0_id == wb_dr1_id)
    //   SV: assign wb_wr_to_both = wb_dr0_we && wb_dr1_we && (wb_dr0_id == wb_dr1_id);
    //=========================================================================
    wire wb0_eq_wb1;
    wire wb_wr_to_both;
    wire not_wb_wr_to_both;
    `CMP_N(cmp_wb0_eq_wb1,        5, wb0_eq_wb1,        wb_dr0_id, wb_dr1_id) // SV: (wb_dr0_id == wb_dr1_id)
    `AND_3(and_wb_wr_to_both,     1, wb_wr_to_both,     wb_dr0_we, wb_dr1_we, wb0_eq_wb1) // SV: wb_dr0_we && wb_dr1_we && (wb_dr0_id==wb_dr1_id)
    `INV_N(inv_not_wb_wr_to_both, 1, wb_wr_to_both,     not_wb_wr_to_both)    // SV: !wb_wr_to_both

    //=========================================================================
    // dr/sr stall gates
    //   SV: dr_stall = cs_dr_rd && (LD_OP || ST_OP || REP_OP) && (...);
    //   SV: sr_stall = cs_sr_rd && (LD_OP || ST_OP || REP_OP) && (...);
    //=========================================================================
    wire ld_or_st_or_rep;
    wire dr_rd_gate;
    wire sr_rd_gate;
    `OR_3 (or_ld_st_rep,    1, ld_or_st_or_rep, LD_OP, ST_OP, REP_OP)         // SV: (LD_OP || ST_OP || REP_OP)
    `AND_2(and_dr_rd_gate,  1, dr_rd_gate, cs_dr_rd, ld_or_st_or_rep)         // SV: cs_dr_rd && (LD_OP||ST_OP||REP_OP)
    `AND_2(and_sr_rd_gate,  1, sr_rd_gate, cs_sr_rd, ld_or_st_or_rep)         // SV: cs_sr_rd && (LD_OP||ST_OP||REP_OP)

    //=========================================================================
    // Per-register counter slot
    //
    // For each reg_ids_e slot R with numeric ID i (0..25):
    //   match_dr_R   = (dr_id     == i)
    //   match_sr_R   = (sr_id     == i)
    //   match_wb0_R  = (wb_dr0_id == i)
    //   match_wb1_R  = (wb_dr1_id == i)
    //   dr_inc_R     = updateSB & cs_dr_wr & match_dr_R
    //   sr_inc_R     = updateSB & cs_sr_wr & match_sr_R & ~cs_wr_to_both
    //   eax_inc_EAX  = updateSB & cs_eax_wr & ~cs_wr_to_both       (only at R=EAX)
    //   inc_R        = dr_inc_R | sr_inc_R [| eax_inc_EAX]         (capped at 1)
    //   wb0_dec_R    = wb_dr0_we & match_wb0_R
    //   wb1_dec_R    = wb_dr1_we & match_wb1_R & ~wb_wr_to_both
    //   dec_R        = wb0_dec_R | wb1_dec_R                       (capped at 1)
    //   inc8b_R[7:1] = 7'b0; inc8b_R[0] = inc_R                    (zero-extend)
    //   decN_R       = dec_R ? 8'hFF : 8'h00                       (two's-complement -dec_R)
    //   plus_R       = ADD_8(counter_R, inc8b_R, 1'b0)
    //   next_R       = ADD_8(plus_R,    decN_R,  1'b0)             (counter + inc - dec)
    //   cleared_R    = any_flush ? 8'h00 : next_R                  (sync flush clear)
    //   REG_R        = REG_RST_WE(8, clk, rst, 1'b1, cleared_R, counter_R)
    //
    // SV original (combined comb + ff):
    //   if (cs_wr_to_both) begin
    //     if (updateSB) next_SCORE_BOARD[dr_id].counter++;
    //   end else begin
    //     if (cs_dr_wr  && updateSB) next_SCORE_BOARD[dr_id].counter++;
    //     if (cs_sr_wr  && updateSB) next_SCORE_BOARD[sr_id].counter++;
    //     if (cs_eax_wr && updateSB) next_SCORE_BOARD[EAX].counter++;
    //   end
    //   if (wb_wr_to_both) next_SCORE_BOARD[wb_dr0_id].counter--;
    //   else begin
    //     if (wb_dr0_we) next_SCORE_BOARD[wb_dr0_id].counter--;
    //     if (wb_dr1_we) next_SCORE_BOARD[wb_dr1_id].counter--;
    //   end
    //   always_ff @(posedge clk):
    //     if (!rst)                                    SCORE_BOARD <= '0;   // async
    //     else if (flush || callFlush || farFlush)     SCORE_BOARD <= '0;   // sync
    //     else                                         SCORE_BOARD <= next_SCORE_BOARD;
    //=========================================================================

    // ---------- CS  (ID 0) ----------
    wire        match_dr_CS, match_sr_CS, match_wb0_CS, match_wb1_CS;
    wire        dr_inc_CS,  sr_inc_CS,  inc_CS;
    wire        wb0_dec_CS, wb1_dec_CS, dec_CS;
    wire [7:0]  inc8b_CS, decN_CS, plus_CS, next_CS, cleared_CS, counter_CS;
    wire        cout_p_CS, cout_n_CS;
    `CMP_N(cmp_dr_CS,      5, match_dr_CS,  dr_id,     5'd0)                  // SV: (dr_id == CS)
    `CMP_N(cmp_sr_CS,      5, match_sr_CS,  sr_id,     5'd0)                  // SV: (sr_id == CS)
    `CMP_N(cmp_wb0_CS,     5, match_wb0_CS, wb_dr0_id, 5'd0)                  // SV: (wb_dr0_id == CS)
    `CMP_N(cmp_wb1_CS,     5, match_wb1_CS, wb_dr1_id, 5'd0)                  // SV: (wb_dr1_id == CS)
    `AND_3(and_dr_inc_CS,  1, dr_inc_CS,    updateSB, cs_dr_wr, match_dr_CS)  // SV: (cs_dr_wr && updateSB) && (dr_id==CS)
    `AND_4(and_sr_inc_CS,  1, sr_inc_CS,    updateSB, cs_sr_wr, match_sr_CS, not_cs_wr_to_both) // SV: (cs_sr_wr && updateSB) && (sr_id==CS) in else-branch (~cs_wr_to_both)
    `OR_2 (or_inc_CS,      1, inc_CS,       dr_inc_CS, sr_inc_CS)             // SV: union of inc paths targeting CS
    `AND_2(and_wb0_dec_CS, 1, wb0_dec_CS,   wb_dr0_we, match_wb0_CS)          // SV: wb_dr0_we && (wb_dr0_id==CS)
    `AND_3(and_wb1_dec_CS, 1, wb1_dec_CS,   wb_dr1_we, match_wb1_CS, not_wb_wr_to_both) // SV: wb_dr1_we && (wb_dr1_id==CS) in else-branch (~wb_wr_to_both)
    `OR_2 (or_dec_CS,      1, dec_CS,       wb0_dec_CS, wb1_dec_CS)           // SV: union of dec paths targeting CS
    assign inc8b_CS[7:1] = 7'b0;                                              // SV: zero-extend inc to 8 bits (upper 7)
    assign inc8b_CS[0]   = inc_CS;                                            // SV: zero-extend inc to 8 bits (LSB)
    `MUX_2(mux_decN_CS,    8, decN_CS,      8'h00, 8'hFF, dec_CS)             // SV: dec ? 8'hFF : 8'h00  (two's-complement of dec)
    `ADD_N(add_p_CS,       8, plus_CS,    cout_p_CS, counter_CS, inc8b_CS, 1'b0) // SV: counter + inc
    `ADD_N(add_n_CS,       8, next_CS,    cout_n_CS, plus_CS,    decN_CS, 1'b0)  // SV: (counter + inc) + (-dec)  ==> counter++ / counter--
    `MUX_2(mux_clr_CS,     8, cleared_CS, next_CS, 8'h00, any_flush)          // SV: any_flush ? '0 : next  (sync flush clear)
    `REG_RST_WE(REG_CS,    8, clk, rst, 1'b1, cleared_CS, counter_CS)         // SV: SCORE_BOARD[CS].counter <= cleared (async rst only)

    // ---------- DS  (ID 1) ----------
    wire        match_dr_DS, match_sr_DS, match_wb0_DS, match_wb1_DS;
    wire        dr_inc_DS,  sr_inc_DS,  inc_DS;
    wire        wb0_dec_DS, wb1_dec_DS, dec_DS;
    wire [7:0]  inc8b_DS, decN_DS, plus_DS, next_DS, cleared_DS, counter_DS;
    wire        cout_p_DS, cout_n_DS;
    `CMP_N(cmp_dr_DS,      5, match_dr_DS,  dr_id,     5'd1)
    `CMP_N(cmp_sr_DS,      5, match_sr_DS,  sr_id,     5'd1)
    `CMP_N(cmp_wb0_DS,     5, match_wb0_DS, wb_dr0_id, 5'd1)
    `CMP_N(cmp_wb1_DS,     5, match_wb1_DS, wb_dr1_id, 5'd1)
    `AND_3(and_dr_inc_DS,  1, dr_inc_DS,    updateSB, cs_dr_wr, match_dr_DS)
    `AND_4(and_sr_inc_DS,  1, sr_inc_DS,    updateSB, cs_sr_wr, match_sr_DS, not_cs_wr_to_both)
    `OR_2 (or_inc_DS,      1, inc_DS,       dr_inc_DS, sr_inc_DS)
    `AND_2(and_wb0_dec_DS, 1, wb0_dec_DS,   wb_dr0_we, match_wb0_DS)
    `AND_3(and_wb1_dec_DS, 1, wb1_dec_DS,   wb_dr1_we, match_wb1_DS, not_wb_wr_to_both)
    `OR_2 (or_dec_DS,      1, dec_DS,       wb0_dec_DS, wb1_dec_DS)
    assign inc8b_DS[7:1] = 7'b0;
    assign inc8b_DS[0]   = inc_DS;
    `MUX_2(mux_decN_DS,    8, decN_DS,      8'h00, 8'hFF, dec_DS)
    `ADD_N(add_p_DS,       8, plus_DS,    cout_p_DS, counter_DS, inc8b_DS, 1'b0)
    `ADD_N(add_n_DS,       8, next_DS,    cout_n_DS, plus_DS,    decN_DS, 1'b0)
    `MUX_2(mux_clr_DS,     8, cleared_DS, next_DS, 8'h00, any_flush)          // SV: any_flush ? '0 : next
    `REG_RST_WE(REG_DS,    8, clk, rst, 1'b1, cleared_DS, counter_DS)         // SV: SCORE_BOARD[DS].counter <= cleared

    // ---------- SS  (ID 2) ----------
    wire        match_dr_SS, match_sr_SS, match_wb0_SS, match_wb1_SS;
    wire        dr_inc_SS,  sr_inc_SS,  inc_SS;
    wire        wb0_dec_SS, wb1_dec_SS, dec_SS;
    wire [7:0]  inc8b_SS, decN_SS, plus_SS, next_SS, cleared_SS, counter_SS;
    wire        cout_p_SS, cout_n_SS;
    `CMP_N(cmp_dr_SS,      5, match_dr_SS,  dr_id,     5'd2)
    `CMP_N(cmp_sr_SS,      5, match_sr_SS,  sr_id,     5'd2)
    `CMP_N(cmp_wb0_SS,     5, match_wb0_SS, wb_dr0_id, 5'd2)
    `CMP_N(cmp_wb1_SS,     5, match_wb1_SS, wb_dr1_id, 5'd2)
    `AND_3(and_dr_inc_SS,  1, dr_inc_SS,    updateSB, cs_dr_wr, match_dr_SS)
    `AND_4(and_sr_inc_SS,  1, sr_inc_SS,    updateSB, cs_sr_wr, match_sr_SS, not_cs_wr_to_both)
    `OR_2 (or_inc_SS,      1, inc_SS,       dr_inc_SS, sr_inc_SS)
    `AND_2(and_wb0_dec_SS, 1, wb0_dec_SS,   wb_dr0_we, match_wb0_SS)
    `AND_3(and_wb1_dec_SS, 1, wb1_dec_SS,   wb_dr1_we, match_wb1_SS, not_wb_wr_to_both)
    `OR_2 (or_dec_SS,      1, dec_SS,       wb0_dec_SS, wb1_dec_SS)
    assign inc8b_SS[7:1] = 7'b0;
    assign inc8b_SS[0]   = inc_SS;
    `MUX_2(mux_decN_SS,    8, decN_SS,      8'h00, 8'hFF, dec_SS)
    `ADD_N(add_p_SS,       8, plus_SS,    cout_p_SS, counter_SS, inc8b_SS, 1'b0)
    `ADD_N(add_n_SS,       8, next_SS,    cout_n_SS, plus_SS,    decN_SS, 1'b0)
    `MUX_2(mux_clr_SS,     8, cleared_SS, next_SS, 8'h00, any_flush)
    `REG_RST_WE(REG_SS,    8, clk, rst, 1'b1, cleared_SS, counter_SS)

    // ---------- ES  (ID 3) ----------
    wire        match_dr_ES, match_sr_ES, match_wb0_ES, match_wb1_ES;
    wire        dr_inc_ES,  sr_inc_ES,  inc_ES;
    wire        wb0_dec_ES, wb1_dec_ES, dec_ES;
    wire [7:0]  inc8b_ES, decN_ES, plus_ES, next_ES, cleared_ES, counter_ES;
    wire        cout_p_ES, cout_n_ES;
    `CMP_N(cmp_dr_ES,      5, match_dr_ES,  dr_id,     5'd3)
    `CMP_N(cmp_sr_ES,      5, match_sr_ES,  sr_id,     5'd3)
    `CMP_N(cmp_wb0_ES,     5, match_wb0_ES, wb_dr0_id, 5'd3)
    `CMP_N(cmp_wb1_ES,     5, match_wb1_ES, wb_dr1_id, 5'd3)
    `AND_3(and_dr_inc_ES,  1, dr_inc_ES,    updateSB, cs_dr_wr, match_dr_ES)
    `AND_4(and_sr_inc_ES,  1, sr_inc_ES,    updateSB, cs_sr_wr, match_sr_ES, not_cs_wr_to_both)
    `OR_2 (or_inc_ES,      1, inc_ES,       dr_inc_ES, sr_inc_ES)
    `AND_2(and_wb0_dec_ES, 1, wb0_dec_ES,   wb_dr0_we, match_wb0_ES)
    `AND_3(and_wb1_dec_ES, 1, wb1_dec_ES,   wb_dr1_we, match_wb1_ES, not_wb_wr_to_both)
    `OR_2 (or_dec_ES,      1, dec_ES,       wb0_dec_ES, wb1_dec_ES)
    assign inc8b_ES[7:1] = 7'b0;
    assign inc8b_ES[0]   = inc_ES;
    `MUX_2(mux_decN_ES,    8, decN_ES,      8'h00, 8'hFF, dec_ES)
    `ADD_N(add_p_ES,       8, plus_ES,    cout_p_ES, counter_ES, inc8b_ES, 1'b0)
    `ADD_N(add_n_ES,       8, next_ES,    cout_n_ES, plus_ES,    decN_ES, 1'b0)
    `MUX_2(mux_clr_ES,     8, cleared_ES, next_ES, 8'h00, any_flush)
    `REG_RST_WE(REG_ES,    8, clk, rst, 1'b1, cleared_ES, counter_ES)

    // ---------- FS  (ID 4) ----------
    wire        match_dr_FS, match_sr_FS, match_wb0_FS, match_wb1_FS;
    wire        dr_inc_FS,  sr_inc_FS,  inc_FS;
    wire        wb0_dec_FS, wb1_dec_FS, dec_FS;
    wire [7:0]  inc8b_FS, decN_FS, plus_FS, next_FS, cleared_FS, counter_FS;
    wire        cout_p_FS, cout_n_FS;
    `CMP_N(cmp_dr_FS,      5, match_dr_FS,  dr_id,     5'd4)
    `CMP_N(cmp_sr_FS,      5, match_sr_FS,  sr_id,     5'd4)
    `CMP_N(cmp_wb0_FS,     5, match_wb0_FS, wb_dr0_id, 5'd4)
    `CMP_N(cmp_wb1_FS,     5, match_wb1_FS, wb_dr1_id, 5'd4)
    `AND_3(and_dr_inc_FS,  1, dr_inc_FS,    updateSB, cs_dr_wr, match_dr_FS)
    `AND_4(and_sr_inc_FS,  1, sr_inc_FS,    updateSB, cs_sr_wr, match_sr_FS, not_cs_wr_to_both)
    `OR_2 (or_inc_FS,      1, inc_FS,       dr_inc_FS, sr_inc_FS)
    `AND_2(and_wb0_dec_FS, 1, wb0_dec_FS,   wb_dr0_we, match_wb0_FS)
    `AND_3(and_wb1_dec_FS, 1, wb1_dec_FS,   wb_dr1_we, match_wb1_FS, not_wb_wr_to_both)
    `OR_2 (or_dec_FS,      1, dec_FS,       wb0_dec_FS, wb1_dec_FS)
    assign inc8b_FS[7:1] = 7'b0;
    assign inc8b_FS[0]   = inc_FS;
    `MUX_2(mux_decN_FS,    8, decN_FS,      8'h00, 8'hFF, dec_FS)
    `ADD_N(add_p_FS,       8, plus_FS,    cout_p_FS, counter_FS, inc8b_FS, 1'b0)
    `ADD_N(add_n_FS,       8, next_FS,    cout_n_FS, plus_FS,    decN_FS, 1'b0)
    `MUX_2(mux_clr_FS,     8, cleared_FS, next_FS, 8'h00, any_flush)
    `REG_RST_WE(REG_FS,    8, clk, rst, 1'b1, cleared_FS, counter_FS)

    // ---------- GS  (ID 5) ----------
    wire        match_dr_GS, match_sr_GS, match_wb0_GS, match_wb1_GS;
    wire        dr_inc_GS,  sr_inc_GS,  inc_GS;
    wire        wb0_dec_GS, wb1_dec_GS, dec_GS;
    wire [7:0]  inc8b_GS, decN_GS, plus_GS, next_GS, cleared_GS, counter_GS;
    wire        cout_p_GS, cout_n_GS;
    `CMP_N(cmp_dr_GS,      5, match_dr_GS,  dr_id,     5'd5)
    `CMP_N(cmp_sr_GS,      5, match_sr_GS,  sr_id,     5'd5)
    `CMP_N(cmp_wb0_GS,     5, match_wb0_GS, wb_dr0_id, 5'd5)
    `CMP_N(cmp_wb1_GS,     5, match_wb1_GS, wb_dr1_id, 5'd5)
    `AND_3(and_dr_inc_GS,  1, dr_inc_GS,    updateSB, cs_dr_wr, match_dr_GS)
    `AND_4(and_sr_inc_GS,  1, sr_inc_GS,    updateSB, cs_sr_wr, match_sr_GS, not_cs_wr_to_both)
    `OR_2 (or_inc_GS,      1, inc_GS,       dr_inc_GS, sr_inc_GS)
    `AND_2(and_wb0_dec_GS, 1, wb0_dec_GS,   wb_dr0_we, match_wb0_GS)
    `AND_3(and_wb1_dec_GS, 1, wb1_dec_GS,   wb_dr1_we, match_wb1_GS, not_wb_wr_to_both)
    `OR_2 (or_dec_GS,      1, dec_GS,       wb0_dec_GS, wb1_dec_GS)
    assign inc8b_GS[7:1] = 7'b0;
    assign inc8b_GS[0]   = inc_GS;
    `MUX_2(mux_decN_GS,    8, decN_GS,      8'h00, 8'hFF, dec_GS)
    `ADD_N(add_p_GS,       8, plus_GS,    cout_p_GS, counter_GS, inc8b_GS, 1'b0)
    `ADD_N(add_n_GS,       8, next_GS,    cout_n_GS, plus_GS,    decN_GS, 1'b0)
    `MUX_2(mux_clr_GS,     8, cleared_GS, next_GS, 8'h00, any_flush)
    `REG_RST_WE(REG_GS,    8, clk, rst, 1'b1, cleared_GS, counter_GS)

    // ---------- EXPS (ID 6) ----------
    wire        match_dr_EXPS, match_sr_EXPS, match_wb0_EXPS, match_wb1_EXPS;
    wire        dr_inc_EXPS,  sr_inc_EXPS,  inc_EXPS;
    wire        wb0_dec_EXPS, wb1_dec_EXPS, dec_EXPS;
    wire [7:0]  inc8b_EXPS, decN_EXPS, plus_EXPS, next_EXPS, cleared_EXPS, counter_EXPS;
    wire        cout_p_EXPS, cout_n_EXPS;
    `CMP_N(cmp_dr_EXPS,      5, match_dr_EXPS,  dr_id,     5'd6)
    `CMP_N(cmp_sr_EXPS,      5, match_sr_EXPS,  sr_id,     5'd6)
    `CMP_N(cmp_wb0_EXPS,     5, match_wb0_EXPS, wb_dr0_id, 5'd6)
    `CMP_N(cmp_wb1_EXPS,     5, match_wb1_EXPS, wb_dr1_id, 5'd6)
    `AND_3(and_dr_inc_EXPS,  1, dr_inc_EXPS,    updateSB, cs_dr_wr, match_dr_EXPS)
    `AND_4(and_sr_inc_EXPS,  1, sr_inc_EXPS,    updateSB, cs_sr_wr, match_sr_EXPS, not_cs_wr_to_both)
    `OR_2 (or_inc_EXPS,      1, inc_EXPS,       dr_inc_EXPS, sr_inc_EXPS)
    `AND_2(and_wb0_dec_EXPS, 1, wb0_dec_EXPS,   wb_dr0_we, match_wb0_EXPS)
    `AND_3(and_wb1_dec_EXPS, 1, wb1_dec_EXPS,   wb_dr1_we, match_wb1_EXPS, not_wb_wr_to_both)
    `OR_2 (or_dec_EXPS,      1, dec_EXPS,       wb0_dec_EXPS, wb1_dec_EXPS)
    assign inc8b_EXPS[7:1] = 7'b0;
    assign inc8b_EXPS[0]   = inc_EXPS;
    `MUX_2(mux_decN_EXPS,    8, decN_EXPS,      8'h00, 8'hFF, dec_EXPS)
    `ADD_N(add_p_EXPS,       8, plus_EXPS,    cout_p_EXPS, counter_EXPS, inc8b_EXPS, 1'b0)
    `ADD_N(add_n_EXPS,       8, next_EXPS,    cout_n_EXPS, plus_EXPS,    decN_EXPS, 1'b0)
    `MUX_2(mux_clr_EXPS,     8, cleared_EXPS, next_EXPS, 8'h00, any_flush)
    `REG_RST_WE(REG_EXPS,    8, clk, rst, 1'b1, cleared_EXPS, counter_EXPS)

    // ---------- EAX (ID 7) -- adds eax_inc term -----
    //   SV: if (cs_eax_wr && updateSB) next_SCORE_BOARD[EAX].counter++;   (gated by ~cs_wr_to_both)
    wire        match_dr_EAX, match_sr_EAX, match_wb0_EAX, match_wb1_EAX;
    wire        dr_inc_EAX,  sr_inc_EAX,  eax_inc_EAX, inc_EAX;
    wire        wb0_dec_EAX, wb1_dec_EAX, dec_EAX;
    wire [7:0]  inc8b_EAX, decN_EAX, plus_EAX, next_EAX, cleared_EAX, counter_EAX;
    wire        cout_p_EAX, cout_n_EAX;
    `CMP_N(cmp_dr_EAX,      5, match_dr_EAX,  dr_id,     5'd7)                // SV: (dr_id == EAX)
    `CMP_N(cmp_sr_EAX,      5, match_sr_EAX,  sr_id,     5'd7)                // SV: (sr_id == EAX)
    `CMP_N(cmp_wb0_EAX,     5, match_wb0_EAX, wb_dr0_id, 5'd7)                // SV: (wb_dr0_id == EAX)
    `CMP_N(cmp_wb1_EAX,     5, match_wb1_EAX, wb_dr1_id, 5'd7)                // SV: (wb_dr1_id == EAX)
    `AND_3(and_dr_inc_EAX,  1, dr_inc_EAX,    updateSB, cs_dr_wr, match_dr_EAX)
    `AND_4(and_sr_inc_EAX,  1, sr_inc_EAX,    updateSB, cs_sr_wr, match_sr_EAX, not_cs_wr_to_both)
    `AND_3(and_eax_inc_EAX, 1, eax_inc_EAX,   updateSB, cs_eax_wr, not_cs_wr_to_both) // SV: cs_eax_wr && updateSB && ~cs_wr_to_both
    `OR_3 (or_inc_EAX,      1, inc_EAX,       dr_inc_EAX, sr_inc_EAX, eax_inc_EAX)
    `AND_2(and_wb0_dec_EAX, 1, wb0_dec_EAX,   wb_dr0_we, match_wb0_EAX)
    `AND_3(and_wb1_dec_EAX, 1, wb1_dec_EAX,   wb_dr1_we, match_wb1_EAX, not_wb_wr_to_both)
    `OR_2 (or_dec_EAX,      1, dec_EAX,       wb0_dec_EAX, wb1_dec_EAX)
    assign inc8b_EAX[7:1] = 7'b0;
    assign inc8b_EAX[0]   = inc_EAX;
    `MUX_2(mux_decN_EAX,    8, decN_EAX,      8'h00, 8'hFF, dec_EAX)
    `ADD_N(add_p_EAX,       8, plus_EAX,    cout_p_EAX, counter_EAX, inc8b_EAX, 1'b0)
    `ADD_N(add_n_EAX,       8, next_EAX,    cout_n_EAX, plus_EAX,    decN_EAX, 1'b0)
    `MUX_2(mux_clr_EAX,     8, cleared_EAX, next_EAX, 8'h00, any_flush)
    `REG_RST_WE(REG_EAX,    8, clk, rst, 1'b1, cleared_EAX, counter_EAX)

    // ---------- EBX (ID 8) ----------
    wire        match_dr_EBX, match_sr_EBX, match_wb0_EBX, match_wb1_EBX;
    wire        dr_inc_EBX,  sr_inc_EBX,  inc_EBX;
    wire        wb0_dec_EBX, wb1_dec_EBX, dec_EBX;
    wire [7:0]  inc8b_EBX, decN_EBX, plus_EBX, next_EBX, cleared_EBX, counter_EBX;
    wire        cout_p_EBX, cout_n_EBX;
    `CMP_N(cmp_dr_EBX,      5, match_dr_EBX,  dr_id,     5'd8)
    `CMP_N(cmp_sr_EBX,      5, match_sr_EBX,  sr_id,     5'd8)
    `CMP_N(cmp_wb0_EBX,     5, match_wb0_EBX, wb_dr0_id, 5'd8)
    `CMP_N(cmp_wb1_EBX,     5, match_wb1_EBX, wb_dr1_id, 5'd8)
    `AND_3(and_dr_inc_EBX,  1, dr_inc_EBX,    updateSB, cs_dr_wr, match_dr_EBX)
    `AND_4(and_sr_inc_EBX,  1, sr_inc_EBX,    updateSB, cs_sr_wr, match_sr_EBX, not_cs_wr_to_both)
    `OR_2 (or_inc_EBX,      1, inc_EBX,       dr_inc_EBX, sr_inc_EBX)
    `AND_2(and_wb0_dec_EBX, 1, wb0_dec_EBX,   wb_dr0_we, match_wb0_EBX)
    `AND_3(and_wb1_dec_EBX, 1, wb1_dec_EBX,   wb_dr1_we, match_wb1_EBX, not_wb_wr_to_both)
    `OR_2 (or_dec_EBX,      1, dec_EBX,       wb0_dec_EBX, wb1_dec_EBX)
    assign inc8b_EBX[7:1] = 7'b0;
    assign inc8b_EBX[0]   = inc_EBX;
    `MUX_2(mux_decN_EBX,    8, decN_EBX,      8'h00, 8'hFF, dec_EBX)
    `ADD_N(add_p_EBX,       8, plus_EBX,    cout_p_EBX, counter_EBX, inc8b_EBX, 1'b0)
    `ADD_N(add_n_EBX,       8, next_EBX,    cout_n_EBX, plus_EBX,    decN_EBX, 1'b0)
    `MUX_2(mux_clr_EBX,     8, cleared_EBX, next_EBX, 8'h00, any_flush)
    `REG_RST_WE(REG_EBX,    8, clk, rst, 1'b1, cleared_EBX, counter_EBX)

    // ---------- ECX (ID 9) ----------
    wire        match_dr_ECX, match_sr_ECX, match_wb0_ECX, match_wb1_ECX;
    wire        dr_inc_ECX,  sr_inc_ECX,  inc_ECX;
    wire        wb0_dec_ECX, wb1_dec_ECX, dec_ECX;
    wire [7:0]  inc8b_ECX, decN_ECX, plus_ECX, next_ECX, cleared_ECX, counter_ECX;
    wire        cout_p_ECX, cout_n_ECX;
    `CMP_N(cmp_dr_ECX,      5, match_dr_ECX,  dr_id,     5'd9)
    `CMP_N(cmp_sr_ECX,      5, match_sr_ECX,  sr_id,     5'd9)
    `CMP_N(cmp_wb0_ECX,     5, match_wb0_ECX, wb_dr0_id, 5'd9)
    `CMP_N(cmp_wb1_ECX,     5, match_wb1_ECX, wb_dr1_id, 5'd9)
    `AND_3(and_dr_inc_ECX,  1, dr_inc_ECX,    updateSB, cs_dr_wr, match_dr_ECX)
    `AND_4(and_sr_inc_ECX,  1, sr_inc_ECX,    updateSB, cs_sr_wr, match_sr_ECX, not_cs_wr_to_both)
    `OR_2 (or_inc_ECX,      1, inc_ECX,       dr_inc_ECX, sr_inc_ECX)
    `AND_2(and_wb0_dec_ECX, 1, wb0_dec_ECX,   wb_dr0_we, match_wb0_ECX)
    `AND_3(and_wb1_dec_ECX, 1, wb1_dec_ECX,   wb_dr1_we, match_wb1_ECX, not_wb_wr_to_both)
    `OR_2 (or_dec_ECX,      1, dec_ECX,       wb0_dec_ECX, wb1_dec_ECX)
    assign inc8b_ECX[7:1] = 7'b0;
    assign inc8b_ECX[0]   = inc_ECX;
    `MUX_2(mux_decN_ECX,    8, decN_ECX,      8'h00, 8'hFF, dec_ECX)
    `ADD_N(add_p_ECX,       8, plus_ECX,    cout_p_ECX, counter_ECX, inc8b_ECX, 1'b0)
    `ADD_N(add_n_ECX,       8, next_ECX,    cout_n_ECX, plus_ECX,    decN_ECX, 1'b0)
    `MUX_2(mux_clr_ECX,     8, cleared_ECX, next_ECX, 8'h00, any_flush)
    `REG_RST_WE(REG_ECX,    8, clk, rst, 1'b1, cleared_ECX, counter_ECX)

    // ---------- EDX (ID 10) ----------
    wire        match_dr_EDX, match_sr_EDX, match_wb0_EDX, match_wb1_EDX;
    wire        dr_inc_EDX,  sr_inc_EDX,  inc_EDX;
    wire        wb0_dec_EDX, wb1_dec_EDX, dec_EDX;
    wire [7:0]  inc8b_EDX, decN_EDX, plus_EDX, next_EDX, cleared_EDX, counter_EDX;
    wire        cout_p_EDX, cout_n_EDX;
    `CMP_N(cmp_dr_EDX,      5, match_dr_EDX,  dr_id,     5'd10)
    `CMP_N(cmp_sr_EDX,      5, match_sr_EDX,  sr_id,     5'd10)
    `CMP_N(cmp_wb0_EDX,     5, match_wb0_EDX, wb_dr0_id, 5'd10)
    `CMP_N(cmp_wb1_EDX,     5, match_wb1_EDX, wb_dr1_id, 5'd10)
    `AND_3(and_dr_inc_EDX,  1, dr_inc_EDX,    updateSB, cs_dr_wr, match_dr_EDX)
    `AND_4(and_sr_inc_EDX,  1, sr_inc_EDX,    updateSB, cs_sr_wr, match_sr_EDX, not_cs_wr_to_both)
    `OR_2 (or_inc_EDX,      1, inc_EDX,       dr_inc_EDX, sr_inc_EDX)
    `AND_2(and_wb0_dec_EDX, 1, wb0_dec_EDX,   wb_dr0_we, match_wb0_EDX)
    `AND_3(and_wb1_dec_EDX, 1, wb1_dec_EDX,   wb_dr1_we, match_wb1_EDX, not_wb_wr_to_both)
    `OR_2 (or_dec_EDX,      1, dec_EDX,       wb0_dec_EDX, wb1_dec_EDX)
    assign inc8b_EDX[7:1] = 7'b0;
    assign inc8b_EDX[0]   = inc_EDX;
    `MUX_2(mux_decN_EDX,    8, decN_EDX,      8'h00, 8'hFF, dec_EDX)
    `ADD_N(add_p_EDX,       8, plus_EDX,    cout_p_EDX, counter_EDX, inc8b_EDX, 1'b0)
    `ADD_N(add_n_EDX,       8, next_EDX,    cout_n_EDX, plus_EDX,    decN_EDX, 1'b0)
    `MUX_2(mux_clr_EDX,     8, cleared_EDX, next_EDX, 8'h00, any_flush)
    `REG_RST_WE(REG_EDX,    8, clk, rst, 1'b1, cleared_EDX, counter_EDX)

    // ---------- ESI (ID 11) ----------
    wire        match_dr_ESI, match_sr_ESI, match_wb0_ESI, match_wb1_ESI;
    wire        dr_inc_ESI,  sr_inc_ESI,  inc_ESI;
    wire        wb0_dec_ESI, wb1_dec_ESI, dec_ESI;
    wire [7:0]  inc8b_ESI, decN_ESI, plus_ESI, next_ESI, cleared_ESI, counter_ESI;
    wire        cout_p_ESI, cout_n_ESI;
    `CMP_N(cmp_dr_ESI,      5, match_dr_ESI,  dr_id,     5'd11)
    `CMP_N(cmp_sr_ESI,      5, match_sr_ESI,  sr_id,     5'd11)
    `CMP_N(cmp_wb0_ESI,     5, match_wb0_ESI, wb_dr0_id, 5'd11)
    `CMP_N(cmp_wb1_ESI,     5, match_wb1_ESI, wb_dr1_id, 5'd11)
    `AND_3(and_dr_inc_ESI,  1, dr_inc_ESI,    updateSB, cs_dr_wr, match_dr_ESI)
    `AND_4(and_sr_inc_ESI,  1, sr_inc_ESI,    updateSB, cs_sr_wr, match_sr_ESI, not_cs_wr_to_both)
    `OR_2 (or_inc_ESI,      1, inc_ESI,       dr_inc_ESI, sr_inc_ESI)
    `AND_2(and_wb0_dec_ESI, 1, wb0_dec_ESI,   wb_dr0_we, match_wb0_ESI)
    `AND_3(and_wb1_dec_ESI, 1, wb1_dec_ESI,   wb_dr1_we, match_wb1_ESI, not_wb_wr_to_both)
    `OR_2 (or_dec_ESI,      1, dec_ESI,       wb0_dec_ESI, wb1_dec_ESI)
    assign inc8b_ESI[7:1] = 7'b0;
    assign inc8b_ESI[0]   = inc_ESI;
    `MUX_2(mux_decN_ESI,    8, decN_ESI,      8'h00, 8'hFF, dec_ESI)
    `ADD_N(add_p_ESI,       8, plus_ESI,    cout_p_ESI, counter_ESI, inc8b_ESI, 1'b0)
    `ADD_N(add_n_ESI,       8, next_ESI,    cout_n_ESI, plus_ESI,    decN_ESI, 1'b0)
    `MUX_2(mux_clr_ESI,     8, cleared_ESI, next_ESI, 8'h00, any_flush)
    `REG_RST_WE(REG_ESI,    8, clk, rst, 1'b1, cleared_ESI, counter_ESI)

    // ---------- EDI (ID 12) ----------
    wire        match_dr_EDI, match_sr_EDI, match_wb0_EDI, match_wb1_EDI;
    wire        dr_inc_EDI,  sr_inc_EDI,  inc_EDI;
    wire        wb0_dec_EDI, wb1_dec_EDI, dec_EDI;
    wire [7:0]  inc8b_EDI, decN_EDI, plus_EDI, next_EDI, cleared_EDI, counter_EDI;
    wire        cout_p_EDI, cout_n_EDI;
    `CMP_N(cmp_dr_EDI,      5, match_dr_EDI,  dr_id,     5'd12)
    `CMP_N(cmp_sr_EDI,      5, match_sr_EDI,  sr_id,     5'd12)
    `CMP_N(cmp_wb0_EDI,     5, match_wb0_EDI, wb_dr0_id, 5'd12)
    `CMP_N(cmp_wb1_EDI,     5, match_wb1_EDI, wb_dr1_id, 5'd12)
    `AND_3(and_dr_inc_EDI,  1, dr_inc_EDI,    updateSB, cs_dr_wr, match_dr_EDI)
    `AND_4(and_sr_inc_EDI,  1, sr_inc_EDI,    updateSB, cs_sr_wr, match_sr_EDI, not_cs_wr_to_both)
    `OR_2 (or_inc_EDI,      1, inc_EDI,       dr_inc_EDI, sr_inc_EDI)
    `AND_2(and_wb0_dec_EDI, 1, wb0_dec_EDI,   wb_dr0_we, match_wb0_EDI)
    `AND_3(and_wb1_dec_EDI, 1, wb1_dec_EDI,   wb_dr1_we, match_wb1_EDI, not_wb_wr_to_both)
    `OR_2 (or_dec_EDI,      1, dec_EDI,       wb0_dec_EDI, wb1_dec_EDI)
    assign inc8b_EDI[7:1] = 7'b0;
    assign inc8b_EDI[0]   = inc_EDI;
    `MUX_2(mux_decN_EDI,    8, decN_EDI,      8'h00, 8'hFF, dec_EDI)
    `ADD_N(add_p_EDI,       8, plus_EDI,    cout_p_EDI, counter_EDI, inc8b_EDI, 1'b0)
    `ADD_N(add_n_EDI,       8, next_EDI,    cout_n_EDI, plus_EDI,    decN_EDI, 1'b0)
    `MUX_2(mux_clr_EDI,     8, cleared_EDI, next_EDI, 8'h00, any_flush)
    `REG_RST_WE(REG_EDI,    8, clk, rst, 1'b1, cleared_EDI, counter_EDI)

    // ---------- ESP (ID 13) ----------
    wire        match_dr_ESP, match_sr_ESP, match_wb0_ESP, match_wb1_ESP;
    wire        dr_inc_ESP,  sr_inc_ESP,  inc_ESP;
    wire        wb0_dec_ESP, wb1_dec_ESP, dec_ESP;
    wire [7:0]  inc8b_ESP, decN_ESP, plus_ESP, next_ESP, cleared_ESP, counter_ESP;
    wire        cout_p_ESP, cout_n_ESP;
    `CMP_N(cmp_dr_ESP,      5, match_dr_ESP,  dr_id,     5'd13)
    `CMP_N(cmp_sr_ESP,      5, match_sr_ESP,  sr_id,     5'd13)
    `CMP_N(cmp_wb0_ESP,     5, match_wb0_ESP, wb_dr0_id, 5'd13)
    `CMP_N(cmp_wb1_ESP,     5, match_wb1_ESP, wb_dr1_id, 5'd13)
    `AND_3(and_dr_inc_ESP,  1, dr_inc_ESP,    updateSB, cs_dr_wr, match_dr_ESP)
    `AND_4(and_sr_inc_ESP,  1, sr_inc_ESP,    updateSB, cs_sr_wr, match_sr_ESP, not_cs_wr_to_both)
    `OR_2 (or_inc_ESP,      1, inc_ESP,       dr_inc_ESP, sr_inc_ESP)
    `AND_2(and_wb0_dec_ESP, 1, wb0_dec_ESP,   wb_dr0_we, match_wb0_ESP)
    `AND_3(and_wb1_dec_ESP, 1, wb1_dec_ESP,   wb_dr1_we, match_wb1_ESP, not_wb_wr_to_both)
    `OR_2 (or_dec_ESP,      1, dec_ESP,       wb0_dec_ESP, wb1_dec_ESP)
    assign inc8b_ESP[7:1] = 7'b0;
    assign inc8b_ESP[0]   = inc_ESP;
    `MUX_2(mux_decN_ESP,    8, decN_ESP,      8'h00, 8'hFF, dec_ESP)
    `ADD_N(add_p_ESP,       8, plus_ESP,    cout_p_ESP, counter_ESP, inc8b_ESP, 1'b0)
    `ADD_N(add_n_ESP,       8, next_ESP,    cout_n_ESP, plus_ESP,    decN_ESP, 1'b0)
    `MUX_2(mux_clr_ESP,     8, cleared_ESP, next_ESP, 8'h00, any_flush)
    `REG_RST_WE(REG_ESP,    8, clk, rst, 1'b1, cleared_ESP, counter_ESP)

    // ---------- EBP (ID 14) ----------
    wire        match_dr_EBP, match_sr_EBP, match_wb0_EBP, match_wb1_EBP;
    wire        dr_inc_EBP,  sr_inc_EBP,  inc_EBP;
    wire        wb0_dec_EBP, wb1_dec_EBP, dec_EBP;
    wire [7:0]  inc8b_EBP, decN_EBP, plus_EBP, next_EBP, cleared_EBP, counter_EBP;
    wire        cout_p_EBP, cout_n_EBP;
    `CMP_N(cmp_dr_EBP,      5, match_dr_EBP,  dr_id,     5'd14)
    `CMP_N(cmp_sr_EBP,      5, match_sr_EBP,  sr_id,     5'd14)
    `CMP_N(cmp_wb0_EBP,     5, match_wb0_EBP, wb_dr0_id, 5'd14)
    `CMP_N(cmp_wb1_EBP,     5, match_wb1_EBP, wb_dr1_id, 5'd14)
    `AND_3(and_dr_inc_EBP,  1, dr_inc_EBP,    updateSB, cs_dr_wr, match_dr_EBP)
    `AND_4(and_sr_inc_EBP,  1, sr_inc_EBP,    updateSB, cs_sr_wr, match_sr_EBP, not_cs_wr_to_both)
    `OR_2 (or_inc_EBP,      1, inc_EBP,       dr_inc_EBP, sr_inc_EBP)
    `AND_2(and_wb0_dec_EBP, 1, wb0_dec_EBP,   wb_dr0_we, match_wb0_EBP)
    `AND_3(and_wb1_dec_EBP, 1, wb1_dec_EBP,   wb_dr1_we, match_wb1_EBP, not_wb_wr_to_both)
    `OR_2 (or_dec_EBP,      1, dec_EBP,       wb0_dec_EBP, wb1_dec_EBP)
    assign inc8b_EBP[7:1] = 7'b0;
    assign inc8b_EBP[0]   = inc_EBP;
    `MUX_2(mux_decN_EBP,    8, decN_EBP,      8'h00, 8'hFF, dec_EBP)
    `ADD_N(add_p_EBP,       8, plus_EBP,    cout_p_EBP, counter_EBP, inc8b_EBP, 1'b0)
    `ADD_N(add_n_EBP,       8, next_EBP,    cout_n_EBP, plus_EBP,    decN_EBP, 1'b0)
    `MUX_2(mux_clr_EBP,     8, cleared_EBP, next_EBP, 8'h00, any_flush)
    `REG_RST_WE(REG_EBP,    8, clk, rst, 1'b1, cleared_EBP, counter_EBP)

    // ---------- MM0 (ID 15) ----------
    wire        match_dr_MM0, match_sr_MM0, match_wb0_MM0, match_wb1_MM0;
    wire        dr_inc_MM0,  sr_inc_MM0,  inc_MM0;
    wire        wb0_dec_MM0, wb1_dec_MM0, dec_MM0;
    wire [7:0]  inc8b_MM0, decN_MM0, plus_MM0, next_MM0, cleared_MM0, counter_MM0;
    wire        cout_p_MM0, cout_n_MM0;
    `CMP_N(cmp_dr_MM0,      5, match_dr_MM0,  dr_id,     5'd15)
    `CMP_N(cmp_sr_MM0,      5, match_sr_MM0,  sr_id,     5'd15)
    `CMP_N(cmp_wb0_MM0,     5, match_wb0_MM0, wb_dr0_id, 5'd15)
    `CMP_N(cmp_wb1_MM0,     5, match_wb1_MM0, wb_dr1_id, 5'd15)
    `AND_3(and_dr_inc_MM0,  1, dr_inc_MM0,    updateSB, cs_dr_wr, match_dr_MM0)
    `AND_4(and_sr_inc_MM0,  1, sr_inc_MM0,    updateSB, cs_sr_wr, match_sr_MM0, not_cs_wr_to_both)
    `OR_2 (or_inc_MM0,      1, inc_MM0,       dr_inc_MM0, sr_inc_MM0)
    `AND_2(and_wb0_dec_MM0, 1, wb0_dec_MM0,   wb_dr0_we, match_wb0_MM0)
    `AND_3(and_wb1_dec_MM0, 1, wb1_dec_MM0,   wb_dr1_we, match_wb1_MM0, not_wb_wr_to_both)
    `OR_2 (or_dec_MM0,      1, dec_MM0,       wb0_dec_MM0, wb1_dec_MM0)
    assign inc8b_MM0[7:1] = 7'b0;
    assign inc8b_MM0[0]   = inc_MM0;
    `MUX_2(mux_decN_MM0,    8, decN_MM0,      8'h00, 8'hFF, dec_MM0)
    `ADD_N(add_p_MM0,       8, plus_MM0,    cout_p_MM0, counter_MM0, inc8b_MM0, 1'b0)
    `ADD_N(add_n_MM0,       8, next_MM0,    cout_n_MM0, plus_MM0,    decN_MM0, 1'b0)
    `MUX_2(mux_clr_MM0,     8, cleared_MM0, next_MM0, 8'h00, any_flush)
    `REG_RST_WE(REG_MM0,    8, clk, rst, 1'b1, cleared_MM0, counter_MM0)

    // ---------- MM1 (ID 16) ----------
    wire        match_dr_MM1, match_sr_MM1, match_wb0_MM1, match_wb1_MM1;
    wire        dr_inc_MM1,  sr_inc_MM1,  inc_MM1;
    wire        wb0_dec_MM1, wb1_dec_MM1, dec_MM1;
    wire [7:0]  inc8b_MM1, decN_MM1, plus_MM1, next_MM1, cleared_MM1, counter_MM1;
    wire        cout_p_MM1, cout_n_MM1;
    `CMP_N(cmp_dr_MM1,      5, match_dr_MM1,  dr_id,     5'd16)
    `CMP_N(cmp_sr_MM1,      5, match_sr_MM1,  sr_id,     5'd16)
    `CMP_N(cmp_wb0_MM1,     5, match_wb0_MM1, wb_dr0_id, 5'd16)
    `CMP_N(cmp_wb1_MM1,     5, match_wb1_MM1, wb_dr1_id, 5'd16)
    `AND_3(and_dr_inc_MM1,  1, dr_inc_MM1,    updateSB, cs_dr_wr, match_dr_MM1)
    `AND_4(and_sr_inc_MM1,  1, sr_inc_MM1,    updateSB, cs_sr_wr, match_sr_MM1, not_cs_wr_to_both)
    `OR_2 (or_inc_MM1,      1, inc_MM1,       dr_inc_MM1, sr_inc_MM1)
    `AND_2(and_wb0_dec_MM1, 1, wb0_dec_MM1,   wb_dr0_we, match_wb0_MM1)
    `AND_3(and_wb1_dec_MM1, 1, wb1_dec_MM1,   wb_dr1_we, match_wb1_MM1, not_wb_wr_to_both)
    `OR_2 (or_dec_MM1,      1, dec_MM1,       wb0_dec_MM1, wb1_dec_MM1)
    assign inc8b_MM1[7:1] = 7'b0;
    assign inc8b_MM1[0]   = inc_MM1;
    `MUX_2(mux_decN_MM1,    8, decN_MM1,      8'h00, 8'hFF, dec_MM1)
    `ADD_N(add_p_MM1,       8, plus_MM1,    cout_p_MM1, counter_MM1, inc8b_MM1, 1'b0)
    `ADD_N(add_n_MM1,       8, next_MM1,    cout_n_MM1, plus_MM1,    decN_MM1, 1'b0)
    `MUX_2(mux_clr_MM1,     8, cleared_MM1, next_MM1, 8'h00, any_flush)
    `REG_RST_WE(REG_MM1,    8, clk, rst, 1'b1, cleared_MM1, counter_MM1)

    // ---------- MM2 (ID 17) ----------
    wire        match_dr_MM2, match_sr_MM2, match_wb0_MM2, match_wb1_MM2;
    wire        dr_inc_MM2,  sr_inc_MM2,  inc_MM2;
    wire        wb0_dec_MM2, wb1_dec_MM2, dec_MM2;
    wire [7:0]  inc8b_MM2, decN_MM2, plus_MM2, next_MM2, cleared_MM2, counter_MM2;
    wire        cout_p_MM2, cout_n_MM2;
    `CMP_N(cmp_dr_MM2,      5, match_dr_MM2,  dr_id,     5'd17)
    `CMP_N(cmp_sr_MM2,      5, match_sr_MM2,  sr_id,     5'd17)
    `CMP_N(cmp_wb0_MM2,     5, match_wb0_MM2, wb_dr0_id, 5'd17)
    `CMP_N(cmp_wb1_MM2,     5, match_wb1_MM2, wb_dr1_id, 5'd17)
    `AND_3(and_dr_inc_MM2,  1, dr_inc_MM2,    updateSB, cs_dr_wr, match_dr_MM2)
    `AND_4(and_sr_inc_MM2,  1, sr_inc_MM2,    updateSB, cs_sr_wr, match_sr_MM2, not_cs_wr_to_both)
    `OR_2 (or_inc_MM2,      1, inc_MM2,       dr_inc_MM2, sr_inc_MM2)
    `AND_2(and_wb0_dec_MM2, 1, wb0_dec_MM2,   wb_dr0_we, match_wb0_MM2)
    `AND_3(and_wb1_dec_MM2, 1, wb1_dec_MM2,   wb_dr1_we, match_wb1_MM2, not_wb_wr_to_both)
    `OR_2 (or_dec_MM2,      1, dec_MM2,       wb0_dec_MM2, wb1_dec_MM2)
    assign inc8b_MM2[7:1] = 7'b0;
    assign inc8b_MM2[0]   = inc_MM2;
    `MUX_2(mux_decN_MM2,    8, decN_MM2,      8'h00, 8'hFF, dec_MM2)
    `ADD_N(add_p_MM2,       8, plus_MM2,    cout_p_MM2, counter_MM2, inc8b_MM2, 1'b0)
    `ADD_N(add_n_MM2,       8, next_MM2,    cout_n_MM2, plus_MM2,    decN_MM2, 1'b0)
    `MUX_2(mux_clr_MM2,     8, cleared_MM2, next_MM2, 8'h00, any_flush)
    `REG_RST_WE(REG_MM2,    8, clk, rst, 1'b1, cleared_MM2, counter_MM2)

    // ---------- MM3 (ID 18) ----------
    wire        match_dr_MM3, match_sr_MM3, match_wb0_MM3, match_wb1_MM3;
    wire        dr_inc_MM3,  sr_inc_MM3,  inc_MM3;
    wire        wb0_dec_MM3, wb1_dec_MM3, dec_MM3;
    wire [7:0]  inc8b_MM3, decN_MM3, plus_MM3, next_MM3, cleared_MM3, counter_MM3;
    wire        cout_p_MM3, cout_n_MM3;
    `CMP_N(cmp_dr_MM3,      5, match_dr_MM3,  dr_id,     5'd18)
    `CMP_N(cmp_sr_MM3,      5, match_sr_MM3,  sr_id,     5'd18)
    `CMP_N(cmp_wb0_MM3,     5, match_wb0_MM3, wb_dr0_id, 5'd18)
    `CMP_N(cmp_wb1_MM3,     5, match_wb1_MM3, wb_dr1_id, 5'd18)
    `AND_3(and_dr_inc_MM3,  1, dr_inc_MM3,    updateSB, cs_dr_wr, match_dr_MM3)
    `AND_4(and_sr_inc_MM3,  1, sr_inc_MM3,    updateSB, cs_sr_wr, match_sr_MM3, not_cs_wr_to_both)
    `OR_2 (or_inc_MM3,      1, inc_MM3,       dr_inc_MM3, sr_inc_MM3)
    `AND_2(and_wb0_dec_MM3, 1, wb0_dec_MM3,   wb_dr0_we, match_wb0_MM3)
    `AND_3(and_wb1_dec_MM3, 1, wb1_dec_MM3,   wb_dr1_we, match_wb1_MM3, not_wb_wr_to_both)
    `OR_2 (or_dec_MM3,      1, dec_MM3,       wb0_dec_MM3, wb1_dec_MM3)
    assign inc8b_MM3[7:1] = 7'b0;
    assign inc8b_MM3[0]   = inc_MM3;
    `MUX_2(mux_decN_MM3,    8, decN_MM3,      8'h00, 8'hFF, dec_MM3)
    `ADD_N(add_p_MM3,       8, plus_MM3,    cout_p_MM3, counter_MM3, inc8b_MM3, 1'b0)
    `ADD_N(add_n_MM3,       8, next_MM3,    cout_n_MM3, plus_MM3,    decN_MM3, 1'b0)
    `MUX_2(mux_clr_MM3,     8, cleared_MM3, next_MM3, 8'h00, any_flush)
    `REG_RST_WE(REG_MM3,    8, clk, rst, 1'b1, cleared_MM3, counter_MM3)

    // ---------- MM4 (ID 19) ----------
    wire        match_dr_MM4, match_sr_MM4, match_wb0_MM4, match_wb1_MM4;
    wire        dr_inc_MM4,  sr_inc_MM4,  inc_MM4;
    wire        wb0_dec_MM4, wb1_dec_MM4, dec_MM4;
    wire [7:0]  inc8b_MM4, decN_MM4, plus_MM4, next_MM4, cleared_MM4, counter_MM4;
    wire        cout_p_MM4, cout_n_MM4;
    `CMP_N(cmp_dr_MM4,      5, match_dr_MM4,  dr_id,     5'd19)
    `CMP_N(cmp_sr_MM4,      5, match_sr_MM4,  sr_id,     5'd19)
    `CMP_N(cmp_wb0_MM4,     5, match_wb0_MM4, wb_dr0_id, 5'd19)
    `CMP_N(cmp_wb1_MM4,     5, match_wb1_MM4, wb_dr1_id, 5'd19)
    `AND_3(and_dr_inc_MM4,  1, dr_inc_MM4,    updateSB, cs_dr_wr, match_dr_MM4)
    `AND_4(and_sr_inc_MM4,  1, sr_inc_MM4,    updateSB, cs_sr_wr, match_sr_MM4, not_cs_wr_to_both)
    `OR_2 (or_inc_MM4,      1, inc_MM4,       dr_inc_MM4, sr_inc_MM4)
    `AND_2(and_wb0_dec_MM4, 1, wb0_dec_MM4,   wb_dr0_we, match_wb0_MM4)
    `AND_3(and_wb1_dec_MM4, 1, wb1_dec_MM4,   wb_dr1_we, match_wb1_MM4, not_wb_wr_to_both)
    `OR_2 (or_dec_MM4,      1, dec_MM4,       wb0_dec_MM4, wb1_dec_MM4)
    assign inc8b_MM4[7:1] = 7'b0;
    assign inc8b_MM4[0]   = inc_MM4;
    `MUX_2(mux_decN_MM4,    8, decN_MM4,      8'h00, 8'hFF, dec_MM4)
    `ADD_N(add_p_MM4,       8, plus_MM4,    cout_p_MM4, counter_MM4, inc8b_MM4, 1'b0)
    `ADD_N(add_n_MM4,       8, next_MM4,    cout_n_MM4, plus_MM4,    decN_MM4, 1'b0)
    `MUX_2(mux_clr_MM4,     8, cleared_MM4, next_MM4, 8'h00, any_flush)
    `REG_RST_WE(REG_MM4,    8, clk, rst, 1'b1, cleared_MM4, counter_MM4)

    // ---------- MM5 (ID 20) ----------
    wire        match_dr_MM5, match_sr_MM5, match_wb0_MM5, match_wb1_MM5;
    wire        dr_inc_MM5,  sr_inc_MM5,  inc_MM5;
    wire        wb0_dec_MM5, wb1_dec_MM5, dec_MM5;
    wire [7:0]  inc8b_MM5, decN_MM5, plus_MM5, next_MM5, cleared_MM5, counter_MM5;
    wire        cout_p_MM5, cout_n_MM5;
    `CMP_N(cmp_dr_MM5,      5, match_dr_MM5,  dr_id,     5'd20)
    `CMP_N(cmp_sr_MM5,      5, match_sr_MM5,  sr_id,     5'd20)
    `CMP_N(cmp_wb0_MM5,     5, match_wb0_MM5, wb_dr0_id, 5'd20)
    `CMP_N(cmp_wb1_MM5,     5, match_wb1_MM5, wb_dr1_id, 5'd20)
    `AND_3(and_dr_inc_MM5,  1, dr_inc_MM5,    updateSB, cs_dr_wr, match_dr_MM5)
    `AND_4(and_sr_inc_MM5,  1, sr_inc_MM5,    updateSB, cs_sr_wr, match_sr_MM5, not_cs_wr_to_both)
    `OR_2 (or_inc_MM5,      1, inc_MM5,       dr_inc_MM5, sr_inc_MM5)
    `AND_2(and_wb0_dec_MM5, 1, wb0_dec_MM5,   wb_dr0_we, match_wb0_MM5)
    `AND_3(and_wb1_dec_MM5, 1, wb1_dec_MM5,   wb_dr1_we, match_wb1_MM5, not_wb_wr_to_both)
    `OR_2 (or_dec_MM5,      1, dec_MM5,       wb0_dec_MM5, wb1_dec_MM5)
    assign inc8b_MM5[7:1] = 7'b0;
    assign inc8b_MM5[0]   = inc_MM5;
    `MUX_2(mux_decN_MM5,    8, decN_MM5,      8'h00, 8'hFF, dec_MM5)
    `ADD_N(add_p_MM5,       8, plus_MM5,    cout_p_MM5, counter_MM5, inc8b_MM5, 1'b0)
    `ADD_N(add_n_MM5,       8, next_MM5,    cout_n_MM5, plus_MM5,    decN_MM5, 1'b0)
    `MUX_2(mux_clr_MM5,     8, cleared_MM5, next_MM5, 8'h00, any_flush)
    `REG_RST_WE(REG_MM5,    8, clk, rst, 1'b1, cleared_MM5, counter_MM5)

    // ---------- MM6 (ID 21) ----------
    wire        match_dr_MM6, match_sr_MM6, match_wb0_MM6, match_wb1_MM6;
    wire        dr_inc_MM6,  sr_inc_MM6,  inc_MM6;
    wire        wb0_dec_MM6, wb1_dec_MM6, dec_MM6;
    wire [7:0]  inc8b_MM6, decN_MM6, plus_MM6, next_MM6, cleared_MM6, counter_MM6;
    wire        cout_p_MM6, cout_n_MM6;
    `CMP_N(cmp_dr_MM6,      5, match_dr_MM6,  dr_id,     5'd21)
    `CMP_N(cmp_sr_MM6,      5, match_sr_MM6,  sr_id,     5'd21)
    `CMP_N(cmp_wb0_MM6,     5, match_wb0_MM6, wb_dr0_id, 5'd21)
    `CMP_N(cmp_wb1_MM6,     5, match_wb1_MM6, wb_dr1_id, 5'd21)
    `AND_3(and_dr_inc_MM6,  1, dr_inc_MM6,    updateSB, cs_dr_wr, match_dr_MM6)
    `AND_4(and_sr_inc_MM6,  1, sr_inc_MM6,    updateSB, cs_sr_wr, match_sr_MM6, not_cs_wr_to_both)
    `OR_2 (or_inc_MM6,      1, inc_MM6,       dr_inc_MM6, sr_inc_MM6)
    `AND_2(and_wb0_dec_MM6, 1, wb0_dec_MM6,   wb_dr0_we, match_wb0_MM6)
    `AND_3(and_wb1_dec_MM6, 1, wb1_dec_MM6,   wb_dr1_we, match_wb1_MM6, not_wb_wr_to_both)
    `OR_2 (or_dec_MM6,      1, dec_MM6,       wb0_dec_MM6, wb1_dec_MM6)
    assign inc8b_MM6[7:1] = 7'b0;
    assign inc8b_MM6[0]   = inc_MM6;
    `MUX_2(mux_decN_MM6,    8, decN_MM6,      8'h00, 8'hFF, dec_MM6)
    `ADD_N(add_p_MM6,       8, plus_MM6,    cout_p_MM6, counter_MM6, inc8b_MM6, 1'b0)
    `ADD_N(add_n_MM6,       8, next_MM6,    cout_n_MM6, plus_MM6,    decN_MM6, 1'b0)
    `MUX_2(mux_clr_MM6,     8, cleared_MM6, next_MM6, 8'h00, any_flush)
    `REG_RST_WE(REG_MM6,    8, clk, rst, 1'b1, cleared_MM6, counter_MM6)

    // ---------- MM7 (ID 22) ----------
    wire        match_dr_MM7, match_sr_MM7, match_wb0_MM7, match_wb1_MM7;
    wire        dr_inc_MM7,  sr_inc_MM7,  inc_MM7;
    wire        wb0_dec_MM7, wb1_dec_MM7, dec_MM7;
    wire [7:0]  inc8b_MM7, decN_MM7, plus_MM7, next_MM7, cleared_MM7, counter_MM7;
    wire        cout_p_MM7, cout_n_MM7;
    `CMP_N(cmp_dr_MM7,      5, match_dr_MM7,  dr_id,     5'd22)
    `CMP_N(cmp_sr_MM7,      5, match_sr_MM7,  sr_id,     5'd22)
    `CMP_N(cmp_wb0_MM7,     5, match_wb0_MM7, wb_dr0_id, 5'd22)
    `CMP_N(cmp_wb1_MM7,     5, match_wb1_MM7, wb_dr1_id, 5'd22)
    `AND_3(and_dr_inc_MM7,  1, dr_inc_MM7,    updateSB, cs_dr_wr, match_dr_MM7)
    `AND_4(and_sr_inc_MM7,  1, sr_inc_MM7,    updateSB, cs_sr_wr, match_sr_MM7, not_cs_wr_to_both)
    `OR_2 (or_inc_MM7,      1, inc_MM7,       dr_inc_MM7, sr_inc_MM7)
    `AND_2(and_wb0_dec_MM7, 1, wb0_dec_MM7,   wb_dr0_we, match_wb0_MM7)
    `AND_3(and_wb1_dec_MM7, 1, wb1_dec_MM7,   wb_dr1_we, match_wb1_MM7, not_wb_wr_to_both)
    `OR_2 (or_dec_MM7,      1, dec_MM7,       wb0_dec_MM7, wb1_dec_MM7)
    assign inc8b_MM7[7:1] = 7'b0;
    assign inc8b_MM7[0]   = inc_MM7;
    `MUX_2(mux_decN_MM7,    8, decN_MM7,      8'h00, 8'hFF, dec_MM7)
    `ADD_N(add_p_MM7,       8, plus_MM7,    cout_p_MM7, counter_MM7, inc8b_MM7, 1'b0)
    `ADD_N(add_n_MM7,       8, next_MM7,    cout_n_MM7, plus_MM7,    decN_MM7, 1'b0)
    `MUX_2(mux_clr_MM7,     8, cleared_MM7, next_MM7, 8'h00, any_flush)
    `REG_RST_WE(REG_MM7,    8, clk, rst, 1'b1, cleared_MM7, counter_MM7)

    // ---------- ETR (ID 23) ----------
    wire        match_dr_ETR, match_sr_ETR, match_wb0_ETR, match_wb1_ETR;
    wire        dr_inc_ETR,  sr_inc_ETR,  inc_ETR;
    wire        wb0_dec_ETR, wb1_dec_ETR, dec_ETR;
    wire [7:0]  inc8b_ETR, decN_ETR, plus_ETR, next_ETR, cleared_ETR, counter_ETR;
    wire        cout_p_ETR, cout_n_ETR;
    `CMP_N(cmp_dr_ETR,      5, match_dr_ETR,  dr_id,     5'd23)
    `CMP_N(cmp_sr_ETR,      5, match_sr_ETR,  sr_id,     5'd23)
    `CMP_N(cmp_wb0_ETR,     5, match_wb0_ETR, wb_dr0_id, 5'd23)
    `CMP_N(cmp_wb1_ETR,     5, match_wb1_ETR, wb_dr1_id, 5'd23)
    `AND_3(and_dr_inc_ETR,  1, dr_inc_ETR,    updateSB, cs_dr_wr, match_dr_ETR)
    `AND_4(and_sr_inc_ETR,  1, sr_inc_ETR,    updateSB, cs_sr_wr, match_sr_ETR, not_cs_wr_to_both)
    `OR_2 (or_inc_ETR,      1, inc_ETR,       dr_inc_ETR, sr_inc_ETR)
    `AND_2(and_wb0_dec_ETR, 1, wb0_dec_ETR,   wb_dr0_we, match_wb0_ETR)
    `AND_3(and_wb1_dec_ETR, 1, wb1_dec_ETR,   wb_dr1_we, match_wb1_ETR, not_wb_wr_to_both)
    `OR_2 (or_dec_ETR,      1, dec_ETR,       wb0_dec_ETR, wb1_dec_ETR)
    assign inc8b_ETR[7:1] = 7'b0;
    assign inc8b_ETR[0]   = inc_ETR;
    `MUX_2(mux_decN_ETR,    8, decN_ETR,      8'h00, 8'hFF, dec_ETR)
    `ADD_N(add_p_ETR,       8, plus_ETR,    cout_p_ETR, counter_ETR, inc8b_ETR, 1'b0)
    `ADD_N(add_n_ETR,       8, next_ETR,    cout_n_ETR, plus_ETR,    decN_ETR, 1'b0)
    `MUX_2(mux_clr_ETR,     8, cleared_ETR, next_ETR, 8'h00, any_flush)
    `REG_RST_WE(REG_ETR,    8, clk, rst, 1'b1, cleared_ETR, counter_ETR)

    // ---------- ERROR_REG (ID 24) ----------
    wire        match_dr_ERROR_REG, match_sr_ERROR_REG, match_wb0_ERROR_REG, match_wb1_ERROR_REG;
    wire        dr_inc_ERROR_REG,  sr_inc_ERROR_REG,  inc_ERROR_REG;
    wire        wb0_dec_ERROR_REG, wb1_dec_ERROR_REG, dec_ERROR_REG;
    wire [7:0]  inc8b_ERROR_REG, decN_ERROR_REG, plus_ERROR_REG, next_ERROR_REG, cleared_ERROR_REG, counter_ERROR_REG;
    wire        cout_p_ERROR_REG, cout_n_ERROR_REG;
    `CMP_N(cmp_dr_ERROR_REG,      5, match_dr_ERROR_REG,  dr_id,     5'd24)
    `CMP_N(cmp_sr_ERROR_REG,      5, match_sr_ERROR_REG,  sr_id,     5'd24)
    `CMP_N(cmp_wb0_ERROR_REG,     5, match_wb0_ERROR_REG, wb_dr0_id, 5'd24)
    `CMP_N(cmp_wb1_ERROR_REG,     5, match_wb1_ERROR_REG, wb_dr1_id, 5'd24)
    `AND_3(and_dr_inc_ERROR_REG,  1, dr_inc_ERROR_REG,    updateSB, cs_dr_wr, match_dr_ERROR_REG)
    `AND_4(and_sr_inc_ERROR_REG,  1, sr_inc_ERROR_REG,    updateSB, cs_sr_wr, match_sr_ERROR_REG, not_cs_wr_to_both)
    `OR_2 (or_inc_ERROR_REG,      1, inc_ERROR_REG,       dr_inc_ERROR_REG, sr_inc_ERROR_REG)
    `AND_2(and_wb0_dec_ERROR_REG, 1, wb0_dec_ERROR_REG,   wb_dr0_we, match_wb0_ERROR_REG)
    `AND_3(and_wb1_dec_ERROR_REG, 1, wb1_dec_ERROR_REG,   wb_dr1_we, match_wb1_ERROR_REG, not_wb_wr_to_both)
    `OR_2 (or_dec_ERROR_REG,      1, dec_ERROR_REG,       wb0_dec_ERROR_REG, wb1_dec_ERROR_REG)
    assign inc8b_ERROR_REG[7:1] = 7'b0;
    assign inc8b_ERROR_REG[0]   = inc_ERROR_REG;
    `MUX_2(mux_decN_ERROR_REG,    8, decN_ERROR_REG,      8'h00, 8'hFF, dec_ERROR_REG)
    `ADD_N(add_p_ERROR_REG,       8, plus_ERROR_REG,    cout_p_ERROR_REG, counter_ERROR_REG, inc8b_ERROR_REG, 1'b0)
    `ADD_N(add_n_ERROR_REG,       8, next_ERROR_REG,    cout_n_ERROR_REG, plus_ERROR_REG,    decN_ERROR_REG, 1'b0)
    `MUX_2(mux_clr_ERROR_REG,     8, cleared_ERROR_REG, next_ERROR_REG, 8'h00, any_flush)
    `REG_RST_WE(REG_ERROR_REG,    8, clk, rst, 1'b1, cleared_ERROR_REG, counter_ERROR_REG)

    // ---------- NO_REG (ID 25) ----------
    wire        match_dr_NO_REG, match_sr_NO_REG, match_wb0_NO_REG, match_wb1_NO_REG;
    wire        dr_inc_NO_REG,  sr_inc_NO_REG,  inc_NO_REG;
    wire        wb0_dec_NO_REG, wb1_dec_NO_REG, dec_NO_REG;
    wire [7:0]  inc8b_NO_REG, decN_NO_REG, plus_NO_REG, next_NO_REG, cleared_NO_REG, counter_NO_REG;
    wire        cout_p_NO_REG, cout_n_NO_REG;
    `CMP_N(cmp_dr_NO_REG,      5, match_dr_NO_REG,  dr_id,     5'd25)
    `CMP_N(cmp_sr_NO_REG,      5, match_sr_NO_REG,  sr_id,     5'd25)
    `CMP_N(cmp_wb0_NO_REG,     5, match_wb0_NO_REG, wb_dr0_id, 5'd25)
    `CMP_N(cmp_wb1_NO_REG,     5, match_wb1_NO_REG, wb_dr1_id, 5'd25)
    `AND_3(and_dr_inc_NO_REG,  1, dr_inc_NO_REG,    updateSB, cs_dr_wr, match_dr_NO_REG)
    `AND_4(and_sr_inc_NO_REG,  1, sr_inc_NO_REG,    updateSB, cs_sr_wr, match_sr_NO_REG, not_cs_wr_to_both)
    `OR_2 (or_inc_NO_REG,      1, inc_NO_REG,       dr_inc_NO_REG, sr_inc_NO_REG)
    `AND_2(and_wb0_dec_NO_REG, 1, wb0_dec_NO_REG,   wb_dr0_we, match_wb0_NO_REG)
    `AND_3(and_wb1_dec_NO_REG, 1, wb1_dec_NO_REG,   wb_dr1_we, match_wb1_NO_REG, not_wb_wr_to_both)
    `OR_2 (or_dec_NO_REG,      1, dec_NO_REG,       wb0_dec_NO_REG, wb1_dec_NO_REG)
    assign inc8b_NO_REG[7:1] = 7'b0;
    assign inc8b_NO_REG[0]   = inc_NO_REG;
    `MUX_2(mux_decN_NO_REG,    8, decN_NO_REG,      8'h00, 8'hFF, dec_NO_REG)
    `ADD_N(add_p_NO_REG,       8, plus_NO_REG,    cout_p_NO_REG, counter_NO_REG, inc8b_NO_REG, 1'b0)
    `ADD_N(add_n_NO_REG,       8, next_NO_REG,    cout_n_NO_REG, plus_NO_REG,    decN_NO_REG, 1'b0)
    `MUX_2(mux_clr_NO_REG,     8, cleared_NO_REG, next_NO_REG, 8'h00, any_flush)
    `REG_RST_WE(REG_NO_REG,    8, clk, rst, 1'b1, cleared_NO_REG, counter_NO_REG)


    //=========================================================================
    // Stall lookups: 32:1 MUX over the 26 counters (slots 26..31 tied to 0)
    //   SV: SCORE_BOARD[<id>].counter
    //=========================================================================
    wire [7:0] lookup_dr;
    wire [7:0] lookup_sr;
    wire [7:0] lookup_seg0;
    wire [7:0] lookup_seg1;
    wire [7:0] lookup_sib_base;
    wire [7:0] lookup_sib_idx;

    `MUX_32(mux_lookup_dr, 8, lookup_dr,
        counter_CS, counter_DS, counter_SS, counter_ES,
        counter_FS, counter_GS, counter_EXPS, counter_EAX,
        counter_EBX, counter_ECX, counter_EDX, counter_ESI,
        counter_EDI, counter_ESP, counter_EBP, counter_MM0,
        counter_MM1, counter_MM2, counter_MM3, counter_MM4,
        counter_MM5, counter_MM6, counter_MM7, counter_ETR,
        counter_ERROR_REG, counter_NO_REG, 8'h00, 8'h00,
        8'h00, 8'h00, 8'h00, 8'h00,
        dr_id)                                                                // SV: SCORE_BOARD[dr_id].counter

    `MUX_32(mux_lookup_sr, 8, lookup_sr,
        counter_CS, counter_DS, counter_SS, counter_ES,
        counter_FS, counter_GS, counter_EXPS, counter_EAX,
        counter_EBX, counter_ECX, counter_EDX, counter_ESI,
        counter_EDI, counter_ESP, counter_EBP, counter_MM0,
        counter_MM1, counter_MM2, counter_MM3, counter_MM4,
        counter_MM5, counter_MM6, counter_MM7, counter_ETR,
        counter_ERROR_REG, counter_NO_REG, 8'h00, 8'h00,
        8'h00, 8'h00, 8'h00, 8'h00,
        sr_id)                                                                // SV: SCORE_BOARD[sr_id].counter

    `MUX_32(mux_lookup_seg0, 8, lookup_seg0,
        counter_CS, counter_DS, counter_SS, counter_ES,
        counter_FS, counter_GS, counter_EXPS, counter_EAX,
        counter_EBX, counter_ECX, counter_EDX, counter_ESI,
        counter_EDI, counter_ESP, counter_EBP, counter_MM0,
        counter_MM1, counter_MM2, counter_MM3, counter_MM4,
        counter_MM5, counter_MM6, counter_MM7, counter_ETR,
        counter_ERROR_REG, counter_NO_REG, 8'h00, 8'h00,
        8'h00, 8'h00, 8'h00, 8'h00,
        Segment0_ID)                                                          // SV: SCORE_BOARD[Segment0_ID].counter

    `MUX_32(mux_lookup_seg1, 8, lookup_seg1,
        counter_CS, counter_DS, counter_SS, counter_ES,
        counter_FS, counter_GS, counter_EXPS, counter_EAX,
        counter_EBX, counter_ECX, counter_EDX, counter_ESI,
        counter_EDI, counter_ESP, counter_EBP, counter_MM0,
        counter_MM1, counter_MM2, counter_MM3, counter_MM4,
        counter_MM5, counter_MM6, counter_MM7, counter_ETR,
        counter_ERROR_REG, counter_NO_REG, 8'h00, 8'h00,
        8'h00, 8'h00, 8'h00, 8'h00,
        Segment1_ID)                                                          // SV: SCORE_BOARD[Segment1_ID].counter

    `MUX_32(mux_lookup_sib_base, 8, lookup_sib_base,
        counter_CS, counter_DS, counter_SS, counter_ES,
        counter_FS, counter_GS, counter_EXPS, counter_EAX,
        counter_EBX, counter_ECX, counter_EDX, counter_ESI,
        counter_EDI, counter_ESP, counter_EBP, counter_MM0,
        counter_MM1, counter_MM2, counter_MM3, counter_MM4,
        counter_MM5, counter_MM6, counter_MM7, counter_ETR,
        counter_ERROR_REG, counter_NO_REG, 8'h00, 8'h00,
        8'h00, 8'h00, 8'h00, 8'h00,
        sib_base_id)                                                          // SV: SCORE_BOARD[sib_base_id].counter

    `MUX_32(mux_lookup_sib_idx, 8, lookup_sib_idx,
        counter_CS, counter_DS, counter_SS, counter_ES,
        counter_FS, counter_GS, counter_EXPS, counter_EAX,
        counter_EBX, counter_ECX, counter_EDX, counter_ESI,
        counter_EDI, counter_ESP, counter_EBP, counter_MM0,
        counter_MM1, counter_MM2, counter_MM3, counter_MM4,
        counter_MM5, counter_MM6, counter_MM7, counter_ETR,
        counter_ERROR_REG, counter_NO_REG, 8'h00, 8'h00,
        8'h00, 8'h00, 8'h00, 8'h00,
        sib_idx_id)                                                           // SV: SCORE_BOARD[sib_idx_id].counter

    //=========================================================================
    // Per-path stall: nonzero(counter) AND gate
    //=========================================================================

    // dr_stall = (lookup_dr != 0) & dr_rd_gate
    //   SV: dr_stall = cs_dr_rd && (LD_OP || ST_OP || REP_OP) && (SCORE_BOARD[dr_id].counter != 0);
    wire dr_zero, dr_nonzero, dr_stall;
    `CMP_N(cmp_dr_zero,    8, dr_zero,   lookup_dr, 8'h00)                    // SV: (SCORE_BOARD[dr_id].counter == 0)
    `INV_N(inv_dr_nonzero, 1, dr_zero,   dr_nonzero)                          // SV: (SCORE_BOARD[dr_id].counter != 0)
    `AND_2(and_dr_stall,   1, dr_stall,  dr_nonzero, dr_rd_gate)              // SV: dr_stall = dr_rd_gate && (counter != 0)

    // sr_stall = (lookup_sr != 0) & sr_rd_gate
    //   SV: sr_stall = cs_sr_rd && (LD_OP || ST_OP || REP_OP) && (SCORE_BOARD[sr_id].counter != 0);
    wire sr_zero, sr_nonzero, sr_stall;
    `CMP_N(cmp_sr_zero,    8, sr_zero,   lookup_sr, 8'h00)
    `INV_N(inv_sr_nonzero, 1, sr_zero,   sr_nonzero)
    `AND_2(and_sr_stall,   1, sr_stall,  sr_nonzero, sr_rd_gate)

    // seg0_stall = (lookup_seg0 != 0)   (no gate)
    //   SV: seg0_stall = (SCORE_BOARD[Segment0_ID].counter != 0);
    wire seg0_zero, seg0_stall;
    `CMP_N(cmp_seg0_zero,  8, seg0_zero, lookup_seg0, 8'h00)
    `INV_N(inv_seg0_stall, 1, seg0_zero, seg0_stall)

    // seg1_stall = (lookup_seg1 != 0) & Segment1_valid
    //   SV: seg1_stall = Segment1_valid && (SCORE_BOARD[Segment1_ID].counter != 0);
    wire seg1_zero, seg1_nonzero, seg1_stall;
    `CMP_N(cmp_seg1_zero,    8, seg1_zero,    lookup_seg1, 8'h00)
    `INV_N(inv_seg1_nonzero, 1, seg1_zero,    seg1_nonzero)
    `AND_2(and_seg1_stall,   1, seg1_stall,   seg1_nonzero, Segment1_valid)

    // sib_base_stall = (lookup_sib_base != 0) & cs_sib_size
    //   SV: sib_base_stall = (cs_sib_size != 0) && (SCORE_BOARD[sib_base_id].counter != 0);
    wire sib_base_zero, sib_base_nonzero, sib_base_stall;
    `CMP_N(cmp_sib_base_zero,    8, sib_base_zero,    lookup_sib_base, 8'h00)
    `INV_N(inv_sib_base_nonzero, 1, sib_base_zero,    sib_base_nonzero)
    `AND_2(and_sib_base_stall,   1, sib_base_stall,   sib_base_nonzero, cs_sib_size)

    // sib_idx_stall = (lookup_sib_idx != 0) & cs_sib_size
    //   SV: sib_idx_stall = (cs_sib_size != 0) && (SCORE_BOARD[sib_idx_id].counter != 0);
    wire sib_idx_zero, sib_idx_nonzero, sib_idx_stall;
    `CMP_N(cmp_sib_idx_zero,    8, sib_idx_zero,    lookup_sib_idx, 8'h00)
    `INV_N(inv_sib_idx_nonzero, 1, sib_idx_zero,    sib_idx_nonzero)
    `AND_2(and_sib_idx_stall,   1, sib_idx_stall,   sib_idx_nonzero, cs_sib_size)

    //=========================================================================
    // depStall_Internal = OR of the six stall paths
    //   eax_stall is hardwired to 0 in the SV ('eax_stall = 0;'), so it's omitted.
    //   SV: depStall_Internal = dr_stall || sr_stall || seg0_stall || seg1_stall ||
    //                           sib_base_stall || sib_idx_stall || eax_stall;
    //=========================================================================
    `OR_6(or_dep_stall, 1, dep_stall_internal,
        dr_stall, sr_stall, seg0_stall, seg1_stall,
        sib_base_stall, sib_idx_stall)

    //=========================================================================
    // ecx_sb     = (counter_ECX != 0)
    // codeSeg_sb = (counter_CS  != 0)
    //   SV: assign ecx_sb     = SCORE_BOARD[ECX].counter != 0;
    //   SV: assign codeSeg_sb = SCORE_BOARD[CS].counter  != 0;
    //=========================================================================
    wire ecx_zero, cs_zero;
    `CMP_N(cmp_ecx_zero,   8, ecx_zero, counter_ECX, 8'h00)                   // SV: (counter_ECX == 0)
    `INV_N(inv_ecx_sb,     1, ecx_zero, ecx_sb)                               // SV: ecx_sb = (counter_ECX != 0)
    `CMP_N(cmp_cs_zero,    8, cs_zero,  counter_CS,  8'h00)                   // SV: (counter_CS == 0)
    `INV_N(inv_codeSeg_sb, 1, cs_zero,  codeSeg_sb)                           // SV: codeSeg_sb = (counter_CS != 0)

endmodule
