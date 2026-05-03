//=============================================================================
// RegSB - structural Verilog 2005 port of RegSB.sv
//
// 26 8-bit scoreboard counters, one per arch register (reg_ids_e):
//   CS=0, DS=1, SS=2, ES=3, FS=4, GS=5, EXPS=6,
//   EAX=7, EBX=8, ECX=9, EDX=10, ESI=11, EDI=12, ESP=13, EBP=14,
//   MM0=15..MM7=22, ETR=23, ERROR_REG=24, NO_REG=25.
//
// Per cycle each counter does
//   counter_next_R = counter_R + inc_R - dec_R     (mod 256)
// where inc_R / dec_R are derived per-slot from the decoded ID one-hots.
//
// Increment path (gated by updateSB = ~dep_stall & instructionforward):
//   dr_inc_R       = updateSB & cs_dr_wr & dr_decoded[R]
//   sr_inc_R       = updateSB & cs_sr_wr & sr_decoded[R] & ~cs_wr_to_both
//   eax_inc        = updateSB & cs_eax_wr & ~cs_wr_to_both        (only on R==EAX)
//   inc_R (non-EAX)= dr_inc_R | sr_inc_R                          (naturally <=1)
//   inc_EAX        = dr_inc_EAX | sr_inc_EAX  (low contribution, naturally <=1)
//                  + eax_inc                  (additional +1 to match SV semantics)
//
// Decrement path (no updateSB gate; writeback always retires):
//   wb0_dec_R = wb_dr0_we & wb0_decoded[R]
//   wb1_dec_R = wb_dr1_we & wb1_decoded[R] & ~wb_wr_to_both
//   dec_R     = wb0_dec_R | wb1_dec_R                             (naturally <=1)
//
// Reset (sync, all counters -> 0): !rst | flush | callFlush | farFlush.
// Folded into a single active-low reset feeding REG_RST_WE; we is tied 1'b1.
//
// IDs are decoded once via four 5-bit DECODER_N units; each register slot
// just consumes the matching bit out of each decoder rather than running its
// own 5-bit equality comparator. The six stall lookups use a MUX_32 over
// the 26 counters (slots 26..31 tied to 0).
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
    // Reset folding
    //   combined_rst_n = rst & ~(flush | callFlush | farFlush)
    //   active-LOW into REG_RST_WE
    //=========================================================================
    wire flushes_none, combined_rst_n;
    `NOR_3(nor_flushes,    1, flushes_none,   flush, callFlush, farFlush)
    `AND_2(and_combined,   1, combined_rst_n, rst,   flushes_none)

    //=========================================================================
    // Same-id detectors (used to collapse simultaneous dr/sr or wb0/wb1 ops)
    //=========================================================================
    wire dr_eq_sr;
    `CMP_N(cmp_drsr_id, 5, dr_eq_sr, dr_id, sr_id)

    wire cs_drsr_wr, cs_wr_to_both, cs_wr_to_both_n;
    `AND_2(and_drsr_wr,    1, cs_drsr_wr,      cs_dr_wr,  cs_sr_wr)
    `AND_2(and_wr_to_both, 1, cs_wr_to_both,   cs_drsr_wr, dr_eq_sr)
    `INV_N(inv_wr_to_both, 1, cs_wr_to_both,   cs_wr_to_both_n)

    wire wb_dr0_eq_dr1;
    `CMP_N(cmp_wb_drs_id, 5, wb_dr0_eq_dr1, wb_dr0_id, wb_dr1_id)

    wire wb_drs_we, wb_wr_to_both, wb_wr_to_both_n;
    `AND_2(and_wb_drs_we,    1, wb_drs_we,        wb_dr0_we, wb_dr1_we)
    `AND_2(and_wb_wr_to_both,1, wb_wr_to_both,    wb_drs_we, wb_dr0_eq_dr1)
    `INV_N(inv_wb_wr_to_both,1, wb_wr_to_both,    wb_wr_to_both_n)

    //=========================================================================
    // updateSB = ~dep_stall & instructionforward
    //=========================================================================
    wire dep_stall_n, updateSB;
    `INV_N(inv_dep_stall, 1, dep_stall, dep_stall_n)
    `AND_2(and_updateSB,  1, updateSB,  dep_stall_n, instructionforward)

    //=========================================================================
    // ID decoders: turn each 5-bit ID into a 32-bit one-hot.
    // bit[i] of <name>_decoded == 1 iff <id> == i.
    //=========================================================================
    wire [31:0] dr_decoded, sr_decoded, wb0_decoded, wb1_decoded;
    `DECODER_N(u_dr_dec,  5, dr_id,     dr_decoded)
    `DECODER_N(u_sr_dec,  5, sr_id,     sr_decoded)
    `DECODER_N(u_wb0_dec, 5, wb_dr0_id, wb0_decoded)
    `DECODER_N(u_wb1_dec, 5, wb_dr1_id, wb1_decoded)

    //=========================================================================
    // Per-instruction shared (low fanout: each used 26x, computed once)
    //=========================================================================
    // dr_gate = updateSB & cs_dr_wr  (no ~cs_wr_to_both: dr fires in both
    //                                 SV branches because cs_wr_to_both => cs_dr_wr)
    wire dr_gate;
    `AND_2(and_dr_gate, 1, dr_gate, updateSB, cs_dr_wr)

    // sr_gate = updateSB & cs_sr_wr & ~cs_wr_to_both
    wire sr_gate_pre, sr_gate;
    `AND_2(and_sr_gate_pre, 1, sr_gate_pre, updateSB,    cs_sr_wr)
    `AND_2(and_sr_gate,     1, sr_gate,     sr_gate_pre, cs_wr_to_both_n)

    // eax_gate = updateSB & cs_eax_wr & ~cs_wr_to_both  (only consumed by EAX slot)
    wire eax_gate_pre, eax_gate;
    `AND_2(and_eax_gate_pre, 1, eax_gate_pre, updateSB,     cs_eax_wr)
    `AND_2(and_eax_gate,     1, eax_gate,     eax_gate_pre, cs_wr_to_both_n)

    // wb1_dec_gate = wb_dr1_we & ~wb_wr_to_both
    wire wb1_dec_gate;
    `AND_2(and_wb1_dec_gate, 1, wb1_dec_gate, wb_dr1_we, wb_wr_to_both_n)

    // memOrRep = LD_OP | ST_OP | REP_OP
    wire memOrRep;
    `OR_3(or_memOrRep, 1, memOrRep, LD_OP, ST_OP, REP_OP)

    //=========================================================================
    // 8-bit "+1 if eax_gate" wire used only by the EAX slot.
    //   eax_inc_8b = eax_gate ? 8'h01 : 8'h00
    //=========================================================================
    wire [7:0] eax_inc_8b;
    `MUX_2(mux_eax_inc, 8, eax_inc_8b, 8'h00, 8'h01, eax_gate)

    //=========================================================================
    // Per-register slot pattern (non-EAX):
    //   inc_R   = (dr_gate & dr_decoded[R]) | (sr_gate & sr_decoded[R])
    //   dec_R   = (wb_dr0_we & wb0_decoded[R]) | (wb1_dec_gate & wb1_decoded[R])
    //   delta_R = MUX_4 over {inc_R, dec_R}:
    //       {0,0} -> 8'h00     (no change)
    //       {0,1} -> 8'hFF     (-1)
    //       {1,0} -> 8'h01     (+1)
    //       {1,1} -> 8'h00     (+1 -1 = 0)
    //   counter_next_R = counter_R + delta_R
    //
    // EAX slot is identical except a second ADD adds eax_inc_8b on top of
    // the delta, so the EAX counter can take +2 in one cycle (matches SV
    // when both a dr/sr increment AND the implicit eax_wr fire on EAX).
    //=========================================================================

    // ----- CS  (ID 0) -----
    wire dr_inc_CS, sr_inc_CS, inc_CS, wb0_dec_CS, wb1_dec_CS, dec_CS;
    wire [7:0] counter_CS, delta_CS, counter_next_CS;
    wire cout_CS;
    `AND_2(and_dr_inc_CS,  1, dr_inc_CS,  dr_gate,      dr_decoded[0])
    `AND_2(and_sr_inc_CS,  1, sr_inc_CS,  sr_gate,      sr_decoded[0])
    `OR_2 (or_inc_CS,      1, inc_CS,     dr_inc_CS,    sr_inc_CS)
    `AND_2(and_wb0_dec_CS, 1, wb0_dec_CS, wb_dr0_we,    wb0_decoded[0])
    `AND_2(and_wb1_dec_CS, 1, wb1_dec_CS, wb1_dec_gate, wb1_decoded[0])
    `OR_2 (or_dec_CS,      1, dec_CS,     wb0_dec_CS,   wb1_dec_CS)
    `MUX_4(mux_delta_CS,   8, delta_CS, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_CS, dec_CS})
    `ADD_N(add_CS,         8, counter_next_CS, cout_CS, counter_CS, delta_CS, 1'b0)
    `REG_RST_WE(REG_CS,    8, clk, combined_rst_n, 1'b1, counter_next_CS, counter_CS)

    // ----- DS  (ID 1) -----
    wire dr_inc_DS, sr_inc_DS, inc_DS, wb0_dec_DS, wb1_dec_DS, dec_DS;
    wire [7:0] counter_DS, delta_DS, counter_next_DS;
    wire cout_DS;
    `AND_2(and_dr_inc_DS,  1, dr_inc_DS,  dr_gate,      dr_decoded[1])
    `AND_2(and_sr_inc_DS,  1, sr_inc_DS,  sr_gate,      sr_decoded[1])
    `OR_2 (or_inc_DS,      1, inc_DS,     dr_inc_DS,    sr_inc_DS)
    `AND_2(and_wb0_dec_DS, 1, wb0_dec_DS, wb_dr0_we,    wb0_decoded[1])
    `AND_2(and_wb1_dec_DS, 1, wb1_dec_DS, wb1_dec_gate, wb1_decoded[1])
    `OR_2 (or_dec_DS,      1, dec_DS,     wb0_dec_DS,   wb1_dec_DS)
    `MUX_4(mux_delta_DS,   8, delta_DS, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_DS, dec_DS})
    `ADD_N(add_DS,         8, counter_next_DS, cout_DS, counter_DS, delta_DS, 1'b0)
    `REG_RST_WE(REG_DS,    8, clk, combined_rst_n, 1'b1, counter_next_DS, counter_DS)

    // ----- SS  (ID 2) -----
    wire dr_inc_SS, sr_inc_SS, inc_SS, wb0_dec_SS, wb1_dec_SS, dec_SS;
    wire [7:0] counter_SS, delta_SS, counter_next_SS;
    wire cout_SS;
    `AND_2(and_dr_inc_SS,  1, dr_inc_SS,  dr_gate,      dr_decoded[2])
    `AND_2(and_sr_inc_SS,  1, sr_inc_SS,  sr_gate,      sr_decoded[2])
    `OR_2 (or_inc_SS,      1, inc_SS,     dr_inc_SS,    sr_inc_SS)
    `AND_2(and_wb0_dec_SS, 1, wb0_dec_SS, wb_dr0_we,    wb0_decoded[2])
    `AND_2(and_wb1_dec_SS, 1, wb1_dec_SS, wb1_dec_gate, wb1_decoded[2])
    `OR_2 (or_dec_SS,      1, dec_SS,     wb0_dec_SS,   wb1_dec_SS)
    `MUX_4(mux_delta_SS,   8, delta_SS, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_SS, dec_SS})
    `ADD_N(add_SS,         8, counter_next_SS, cout_SS, counter_SS, delta_SS, 1'b0)
    `REG_RST_WE(REG_SS,    8, clk, combined_rst_n, 1'b1, counter_next_SS, counter_SS)

    // ----- ES  (ID 3) -----
    wire dr_inc_ES, sr_inc_ES, inc_ES, wb0_dec_ES, wb1_dec_ES, dec_ES;
    wire [7:0] counter_ES, delta_ES, counter_next_ES;
    wire cout_ES;
    `AND_2(and_dr_inc_ES,  1, dr_inc_ES,  dr_gate,      dr_decoded[3])
    `AND_2(and_sr_inc_ES,  1, sr_inc_ES,  sr_gate,      sr_decoded[3])
    `OR_2 (or_inc_ES,      1, inc_ES,     dr_inc_ES,    sr_inc_ES)
    `AND_2(and_wb0_dec_ES, 1, wb0_dec_ES, wb_dr0_we,    wb0_decoded[3])
    `AND_2(and_wb1_dec_ES, 1, wb1_dec_ES, wb1_dec_gate, wb1_decoded[3])
    `OR_2 (or_dec_ES,      1, dec_ES,     wb0_dec_ES,   wb1_dec_ES)
    `MUX_4(mux_delta_ES,   8, delta_ES, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_ES, dec_ES})
    `ADD_N(add_ES,         8, counter_next_ES, cout_ES, counter_ES, delta_ES, 1'b0)
    `REG_RST_WE(REG_ES,    8, clk, combined_rst_n, 1'b1, counter_next_ES, counter_ES)

    // ----- FS  (ID 4) -----
    wire dr_inc_FS, sr_inc_FS, inc_FS, wb0_dec_FS, wb1_dec_FS, dec_FS;
    wire [7:0] counter_FS, delta_FS, counter_next_FS;
    wire cout_FS;
    `AND_2(and_dr_inc_FS,  1, dr_inc_FS,  dr_gate,      dr_decoded[4])
    `AND_2(and_sr_inc_FS,  1, sr_inc_FS,  sr_gate,      sr_decoded[4])
    `OR_2 (or_inc_FS,      1, inc_FS,     dr_inc_FS,    sr_inc_FS)
    `AND_2(and_wb0_dec_FS, 1, wb0_dec_FS, wb_dr0_we,    wb0_decoded[4])
    `AND_2(and_wb1_dec_FS, 1, wb1_dec_FS, wb1_dec_gate, wb1_decoded[4])
    `OR_2 (or_dec_FS,      1, dec_FS,     wb0_dec_FS,   wb1_dec_FS)
    `MUX_4(mux_delta_FS,   8, delta_FS, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_FS, dec_FS})
    `ADD_N(add_FS,         8, counter_next_FS, cout_FS, counter_FS, delta_FS, 1'b0)
    `REG_RST_WE(REG_FS,    8, clk, combined_rst_n, 1'b1, counter_next_FS, counter_FS)

    // ----- GS  (ID 5) -----
    wire dr_inc_GS, sr_inc_GS, inc_GS, wb0_dec_GS, wb1_dec_GS, dec_GS;
    wire [7:0] counter_GS, delta_GS, counter_next_GS;
    wire cout_GS;
    `AND_2(and_dr_inc_GS,  1, dr_inc_GS,  dr_gate,      dr_decoded[5])
    `AND_2(and_sr_inc_GS,  1, sr_inc_GS,  sr_gate,      sr_decoded[5])
    `OR_2 (or_inc_GS,      1, inc_GS,     dr_inc_GS,    sr_inc_GS)
    `AND_2(and_wb0_dec_GS, 1, wb0_dec_GS, wb_dr0_we,    wb0_decoded[5])
    `AND_2(and_wb1_dec_GS, 1, wb1_dec_GS, wb1_dec_gate, wb1_decoded[5])
    `OR_2 (or_dec_GS,      1, dec_GS,     wb0_dec_GS,   wb1_dec_GS)
    `MUX_4(mux_delta_GS,   8, delta_GS, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_GS, dec_GS})
    `ADD_N(add_GS,         8, counter_next_GS, cout_GS, counter_GS, delta_GS, 1'b0)
    `REG_RST_WE(REG_GS,    8, clk, combined_rst_n, 1'b1, counter_next_GS, counter_GS)

    // ----- EXPS  (ID 6) -----
    wire dr_inc_EXPS, sr_inc_EXPS, inc_EXPS, wb0_dec_EXPS, wb1_dec_EXPS, dec_EXPS;
    wire [7:0] counter_EXPS, delta_EXPS, counter_next_EXPS;
    wire cout_EXPS;
    `AND_2(and_dr_inc_EXPS,  1, dr_inc_EXPS,  dr_gate,      dr_decoded[6])
    `AND_2(and_sr_inc_EXPS,  1, sr_inc_EXPS,  sr_gate,      sr_decoded[6])
    `OR_2 (or_inc_EXPS,      1, inc_EXPS,     dr_inc_EXPS,  sr_inc_EXPS)
    `AND_2(and_wb0_dec_EXPS, 1, wb0_dec_EXPS, wb_dr0_we,    wb0_decoded[6])
    `AND_2(and_wb1_dec_EXPS, 1, wb1_dec_EXPS, wb1_dec_gate, wb1_decoded[6])
    `OR_2 (or_dec_EXPS,      1, dec_EXPS,     wb0_dec_EXPS, wb1_dec_EXPS)
    `MUX_4(mux_delta_EXPS,   8, delta_EXPS, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_EXPS, dec_EXPS})
    `ADD_N(add_EXPS,         8, counter_next_EXPS, cout_EXPS, counter_EXPS, delta_EXPS, 1'b0)
    `REG_RST_WE(REG_EXPS,    8, clk, combined_rst_n, 1'b1, counter_next_EXPS, counter_EXPS)

    // ----- EAX  (ID 7) -- additionally adds eax_inc_8b for the implicit-eax-wr path -----
    wire dr_inc_EAX, sr_inc_EAX, inc_EAX, wb0_dec_EAX, wb1_dec_EAX, dec_EAX;
    wire [7:0] counter_EAX, delta_EAX, counter_after_delta_EAX, counter_next_EAX;
    wire cout_d_EAX, cout_e_EAX;
    `AND_2(and_dr_inc_EAX,  1, dr_inc_EAX,  dr_gate,      dr_decoded[7])
    `AND_2(and_sr_inc_EAX,  1, sr_inc_EAX,  sr_gate,      sr_decoded[7])
    `OR_2 (or_inc_EAX,      1, inc_EAX,     dr_inc_EAX,   sr_inc_EAX)
    `AND_2(and_wb0_dec_EAX, 1, wb0_dec_EAX, wb_dr0_we,    wb0_decoded[7])
    `AND_2(and_wb1_dec_EAX, 1, wb1_dec_EAX, wb1_dec_gate, wb1_decoded[7])
    `OR_2 (or_dec_EAX,      1, dec_EAX,     wb0_dec_EAX,  wb1_dec_EAX)
    `MUX_4(mux_delta_EAX,   8, delta_EAX, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_EAX, dec_EAX})
    `ADD_N(add_d_EAX,       8, counter_after_delta_EAX, cout_d_EAX, counter_EAX, delta_EAX, 1'b0)
    `ADD_N(add_e_EAX,       8, counter_next_EAX,        cout_e_EAX, counter_after_delta_EAX, eax_inc_8b, 1'b0)
    `REG_RST_WE(REG_EAX,    8, clk, combined_rst_n, 1'b1, counter_next_EAX, counter_EAX)

    // ----- EBX  (ID 8) -----
    wire dr_inc_EBX, sr_inc_EBX, inc_EBX, wb0_dec_EBX, wb1_dec_EBX, dec_EBX;
    wire [7:0] counter_EBX, delta_EBX, counter_next_EBX;
    wire cout_EBX;
    `AND_2(and_dr_inc_EBX,  1, dr_inc_EBX,  dr_gate,      dr_decoded[8])
    `AND_2(and_sr_inc_EBX,  1, sr_inc_EBX,  sr_gate,      sr_decoded[8])
    `OR_2 (or_inc_EBX,      1, inc_EBX,     dr_inc_EBX,   sr_inc_EBX)
    `AND_2(and_wb0_dec_EBX, 1, wb0_dec_EBX, wb_dr0_we,    wb0_decoded[8])
    `AND_2(and_wb1_dec_EBX, 1, wb1_dec_EBX, wb1_dec_gate, wb1_decoded[8])
    `OR_2 (or_dec_EBX,      1, dec_EBX,     wb0_dec_EBX,  wb1_dec_EBX)
    `MUX_4(mux_delta_EBX,   8, delta_EBX, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_EBX, dec_EBX})
    `ADD_N(add_EBX,         8, counter_next_EBX, cout_EBX, counter_EBX, delta_EBX, 1'b0)
    `REG_RST_WE(REG_EBX,    8, clk, combined_rst_n, 1'b1, counter_next_EBX, counter_EBX)

    // ----- ECX  (ID 9) -----
    wire dr_inc_ECX, sr_inc_ECX, inc_ECX, wb0_dec_ECX, wb1_dec_ECX, dec_ECX;
    wire [7:0] counter_ECX, delta_ECX, counter_next_ECX;
    wire cout_ECX;
    `AND_2(and_dr_inc_ECX,  1, dr_inc_ECX,  dr_gate,      dr_decoded[9])
    `AND_2(and_sr_inc_ECX,  1, sr_inc_ECX,  sr_gate,      sr_decoded[9])
    `OR_2 (or_inc_ECX,      1, inc_ECX,     dr_inc_ECX,   sr_inc_ECX)
    `AND_2(and_wb0_dec_ECX, 1, wb0_dec_ECX, wb_dr0_we,    wb0_decoded[9])
    `AND_2(and_wb1_dec_ECX, 1, wb1_dec_ECX, wb1_dec_gate, wb1_decoded[9])
    `OR_2 (or_dec_ECX,      1, dec_ECX,     wb0_dec_ECX,  wb1_dec_ECX)
    `MUX_4(mux_delta_ECX,   8, delta_ECX, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_ECX, dec_ECX})
    `ADD_N(add_ECX,         8, counter_next_ECX, cout_ECX, counter_ECX, delta_ECX, 1'b0)
    `REG_RST_WE(REG_ECX,    8, clk, combined_rst_n, 1'b1, counter_next_ECX, counter_ECX)

    // ----- EDX  (ID 10) -----
    wire dr_inc_EDX, sr_inc_EDX, inc_EDX, wb0_dec_EDX, wb1_dec_EDX, dec_EDX;
    wire [7:0] counter_EDX, delta_EDX, counter_next_EDX;
    wire cout_EDX;
    `AND_2(and_dr_inc_EDX,  1, dr_inc_EDX,  dr_gate,      dr_decoded[10])
    `AND_2(and_sr_inc_EDX,  1, sr_inc_EDX,  sr_gate,      sr_decoded[10])
    `OR_2 (or_inc_EDX,      1, inc_EDX,     dr_inc_EDX,   sr_inc_EDX)
    `AND_2(and_wb0_dec_EDX, 1, wb0_dec_EDX, wb_dr0_we,    wb0_decoded[10])
    `AND_2(and_wb1_dec_EDX, 1, wb1_dec_EDX, wb1_dec_gate, wb1_decoded[10])
    `OR_2 (or_dec_EDX,      1, dec_EDX,     wb0_dec_EDX,  wb1_dec_EDX)
    `MUX_4(mux_delta_EDX,   8, delta_EDX, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_EDX, dec_EDX})
    `ADD_N(add_EDX,         8, counter_next_EDX, cout_EDX, counter_EDX, delta_EDX, 1'b0)
    `REG_RST_WE(REG_EDX,    8, clk, combined_rst_n, 1'b1, counter_next_EDX, counter_EDX)

    // ----- ESI  (ID 11) -----
    wire dr_inc_ESI, sr_inc_ESI, inc_ESI, wb0_dec_ESI, wb1_dec_ESI, dec_ESI;
    wire [7:0] counter_ESI, delta_ESI, counter_next_ESI;
    wire cout_ESI;
    `AND_2(and_dr_inc_ESI,  1, dr_inc_ESI,  dr_gate,      dr_decoded[11])
    `AND_2(and_sr_inc_ESI,  1, sr_inc_ESI,  sr_gate,      sr_decoded[11])
    `OR_2 (or_inc_ESI,      1, inc_ESI,     dr_inc_ESI,   sr_inc_ESI)
    `AND_2(and_wb0_dec_ESI, 1, wb0_dec_ESI, wb_dr0_we,    wb0_decoded[11])
    `AND_2(and_wb1_dec_ESI, 1, wb1_dec_ESI, wb1_dec_gate, wb1_decoded[11])
    `OR_2 (or_dec_ESI,      1, dec_ESI,     wb0_dec_ESI,  wb1_dec_ESI)
    `MUX_4(mux_delta_ESI,   8, delta_ESI, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_ESI, dec_ESI})
    `ADD_N(add_ESI,         8, counter_next_ESI, cout_ESI, counter_ESI, delta_ESI, 1'b0)
    `REG_RST_WE(REG_ESI,    8, clk, combined_rst_n, 1'b1, counter_next_ESI, counter_ESI)

    // ----- EDI  (ID 12) -----
    wire dr_inc_EDI, sr_inc_EDI, inc_EDI, wb0_dec_EDI, wb1_dec_EDI, dec_EDI;
    wire [7:0] counter_EDI, delta_EDI, counter_next_EDI;
    wire cout_EDI;
    `AND_2(and_dr_inc_EDI,  1, dr_inc_EDI,  dr_gate,      dr_decoded[12])
    `AND_2(and_sr_inc_EDI,  1, sr_inc_EDI,  sr_gate,      sr_decoded[12])
    `OR_2 (or_inc_EDI,      1, inc_EDI,     dr_inc_EDI,   sr_inc_EDI)
    `AND_2(and_wb0_dec_EDI, 1, wb0_dec_EDI, wb_dr0_we,    wb0_decoded[12])
    `AND_2(and_wb1_dec_EDI, 1, wb1_dec_EDI, wb1_dec_gate, wb1_decoded[12])
    `OR_2 (or_dec_EDI,      1, dec_EDI,     wb0_dec_EDI,  wb1_dec_EDI)
    `MUX_4(mux_delta_EDI,   8, delta_EDI, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_EDI, dec_EDI})
    `ADD_N(add_EDI,         8, counter_next_EDI, cout_EDI, counter_EDI, delta_EDI, 1'b0)
    `REG_RST_WE(REG_EDI,    8, clk, combined_rst_n, 1'b1, counter_next_EDI, counter_EDI)

    // ----- ESP  (ID 13) -----
    wire dr_inc_ESP, sr_inc_ESP, inc_ESP, wb0_dec_ESP, wb1_dec_ESP, dec_ESP;
    wire [7:0] counter_ESP, delta_ESP, counter_next_ESP;
    wire cout_ESP;
    `AND_2(and_dr_inc_ESP,  1, dr_inc_ESP,  dr_gate,      dr_decoded[13])
    `AND_2(and_sr_inc_ESP,  1, sr_inc_ESP,  sr_gate,      sr_decoded[13])
    `OR_2 (or_inc_ESP,      1, inc_ESP,     dr_inc_ESP,   sr_inc_ESP)
    `AND_2(and_wb0_dec_ESP, 1, wb0_dec_ESP, wb_dr0_we,    wb0_decoded[13])
    `AND_2(and_wb1_dec_ESP, 1, wb1_dec_ESP, wb1_dec_gate, wb1_decoded[13])
    `OR_2 (or_dec_ESP,      1, dec_ESP,     wb0_dec_ESP,  wb1_dec_ESP)
    `MUX_4(mux_delta_ESP,   8, delta_ESP, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_ESP, dec_ESP})
    `ADD_N(add_ESP,         8, counter_next_ESP, cout_ESP, counter_ESP, delta_ESP, 1'b0)
    `REG_RST_WE(REG_ESP,    8, clk, combined_rst_n, 1'b1, counter_next_ESP, counter_ESP)

    // ----- EBP  (ID 14) -----
    wire dr_inc_EBP, sr_inc_EBP, inc_EBP, wb0_dec_EBP, wb1_dec_EBP, dec_EBP;
    wire [7:0] counter_EBP, delta_EBP, counter_next_EBP;
    wire cout_EBP;
    `AND_2(and_dr_inc_EBP,  1, dr_inc_EBP,  dr_gate,      dr_decoded[14])
    `AND_2(and_sr_inc_EBP,  1, sr_inc_EBP,  sr_gate,      sr_decoded[14])
    `OR_2 (or_inc_EBP,      1, inc_EBP,     dr_inc_EBP,   sr_inc_EBP)
    `AND_2(and_wb0_dec_EBP, 1, wb0_dec_EBP, wb_dr0_we,    wb0_decoded[14])
    `AND_2(and_wb1_dec_EBP, 1, wb1_dec_EBP, wb1_dec_gate, wb1_decoded[14])
    `OR_2 (or_dec_EBP,      1, dec_EBP,     wb0_dec_EBP,  wb1_dec_EBP)
    `MUX_4(mux_delta_EBP,   8, delta_EBP, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_EBP, dec_EBP})
    `ADD_N(add_EBP,         8, counter_next_EBP, cout_EBP, counter_EBP, delta_EBP, 1'b0)
    `REG_RST_WE(REG_EBP,    8, clk, combined_rst_n, 1'b1, counter_next_EBP, counter_EBP)

    // ----- MM0  (ID 15) -----
    wire dr_inc_MM0, sr_inc_MM0, inc_MM0, wb0_dec_MM0, wb1_dec_MM0, dec_MM0;
    wire [7:0] counter_MM0, delta_MM0, counter_next_MM0;
    wire cout_MM0;
    `AND_2(and_dr_inc_MM0,  1, dr_inc_MM0,  dr_gate,      dr_decoded[15])
    `AND_2(and_sr_inc_MM0,  1, sr_inc_MM0,  sr_gate,      sr_decoded[15])
    `OR_2 (or_inc_MM0,      1, inc_MM0,     dr_inc_MM0,   sr_inc_MM0)
    `AND_2(and_wb0_dec_MM0, 1, wb0_dec_MM0, wb_dr0_we,    wb0_decoded[15])
    `AND_2(and_wb1_dec_MM0, 1, wb1_dec_MM0, wb1_dec_gate, wb1_decoded[15])
    `OR_2 (or_dec_MM0,      1, dec_MM0,     wb0_dec_MM0,  wb1_dec_MM0)
    `MUX_4(mux_delta_MM0,   8, delta_MM0, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_MM0, dec_MM0})
    `ADD_N(add_MM0,         8, counter_next_MM0, cout_MM0, counter_MM0, delta_MM0, 1'b0)
    `REG_RST_WE(REG_MM0,    8, clk, combined_rst_n, 1'b1, counter_next_MM0, counter_MM0)

    // ----- MM1  (ID 16) -----
    wire dr_inc_MM1, sr_inc_MM1, inc_MM1, wb0_dec_MM1, wb1_dec_MM1, dec_MM1;
    wire [7:0] counter_MM1, delta_MM1, counter_next_MM1;
    wire cout_MM1;
    `AND_2(and_dr_inc_MM1,  1, dr_inc_MM1,  dr_gate,      dr_decoded[16])
    `AND_2(and_sr_inc_MM1,  1, sr_inc_MM1,  sr_gate,      sr_decoded[16])
    `OR_2 (or_inc_MM1,      1, inc_MM1,     dr_inc_MM1,   sr_inc_MM1)
    `AND_2(and_wb0_dec_MM1, 1, wb0_dec_MM1, wb_dr0_we,    wb0_decoded[16])
    `AND_2(and_wb1_dec_MM1, 1, wb1_dec_MM1, wb1_dec_gate, wb1_decoded[16])
    `OR_2 (or_dec_MM1,      1, dec_MM1,     wb0_dec_MM1,  wb1_dec_MM1)
    `MUX_4(mux_delta_MM1,   8, delta_MM1, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_MM1, dec_MM1})
    `ADD_N(add_MM1,         8, counter_next_MM1, cout_MM1, counter_MM1, delta_MM1, 1'b0)
    `REG_RST_WE(REG_MM1,    8, clk, combined_rst_n, 1'b1, counter_next_MM1, counter_MM1)

    // ----- MM2  (ID 17) -----
    wire dr_inc_MM2, sr_inc_MM2, inc_MM2, wb0_dec_MM2, wb1_dec_MM2, dec_MM2;
    wire [7:0] counter_MM2, delta_MM2, counter_next_MM2;
    wire cout_MM2;
    `AND_2(and_dr_inc_MM2,  1, dr_inc_MM2,  dr_gate,      dr_decoded[17])
    `AND_2(and_sr_inc_MM2,  1, sr_inc_MM2,  sr_gate,      sr_decoded[17])
    `OR_2 (or_inc_MM2,      1, inc_MM2,     dr_inc_MM2,   sr_inc_MM2)
    `AND_2(and_wb0_dec_MM2, 1, wb0_dec_MM2, wb_dr0_we,    wb0_decoded[17])
    `AND_2(and_wb1_dec_MM2, 1, wb1_dec_MM2, wb1_dec_gate, wb1_decoded[17])
    `OR_2 (or_dec_MM2,      1, dec_MM2,     wb0_dec_MM2,  wb1_dec_MM2)
    `MUX_4(mux_delta_MM2,   8, delta_MM2, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_MM2, dec_MM2})
    `ADD_N(add_MM2,         8, counter_next_MM2, cout_MM2, counter_MM2, delta_MM2, 1'b0)
    `REG_RST_WE(REG_MM2,    8, clk, combined_rst_n, 1'b1, counter_next_MM2, counter_MM2)

    // ----- MM3  (ID 18) -----
    wire dr_inc_MM3, sr_inc_MM3, inc_MM3, wb0_dec_MM3, wb1_dec_MM3, dec_MM3;
    wire [7:0] counter_MM3, delta_MM3, counter_next_MM3;
    wire cout_MM3;
    `AND_2(and_dr_inc_MM3,  1, dr_inc_MM3,  dr_gate,      dr_decoded[18])
    `AND_2(and_sr_inc_MM3,  1, sr_inc_MM3,  sr_gate,      sr_decoded[18])
    `OR_2 (or_inc_MM3,      1, inc_MM3,     dr_inc_MM3,   sr_inc_MM3)
    `AND_2(and_wb0_dec_MM3, 1, wb0_dec_MM3, wb_dr0_we,    wb0_decoded[18])
    `AND_2(and_wb1_dec_MM3, 1, wb1_dec_MM3, wb1_dec_gate, wb1_decoded[18])
    `OR_2 (or_dec_MM3,      1, dec_MM3,     wb0_dec_MM3,  wb1_dec_MM3)
    `MUX_4(mux_delta_MM3,   8, delta_MM3, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_MM3, dec_MM3})
    `ADD_N(add_MM3,         8, counter_next_MM3, cout_MM3, counter_MM3, delta_MM3, 1'b0)
    `REG_RST_WE(REG_MM3,    8, clk, combined_rst_n, 1'b1, counter_next_MM3, counter_MM3)

    // ----- MM4  (ID 19) -----
    wire dr_inc_MM4, sr_inc_MM4, inc_MM4, wb0_dec_MM4, wb1_dec_MM4, dec_MM4;
    wire [7:0] counter_MM4, delta_MM4, counter_next_MM4;
    wire cout_MM4;
    `AND_2(and_dr_inc_MM4,  1, dr_inc_MM4,  dr_gate,      dr_decoded[19])
    `AND_2(and_sr_inc_MM4,  1, sr_inc_MM4,  sr_gate,      sr_decoded[19])
    `OR_2 (or_inc_MM4,      1, inc_MM4,     dr_inc_MM4,   sr_inc_MM4)
    `AND_2(and_wb0_dec_MM4, 1, wb0_dec_MM4, wb_dr0_we,    wb0_decoded[19])
    `AND_2(and_wb1_dec_MM4, 1, wb1_dec_MM4, wb1_dec_gate, wb1_decoded[19])
    `OR_2 (or_dec_MM4,      1, dec_MM4,     wb0_dec_MM4,  wb1_dec_MM4)
    `MUX_4(mux_delta_MM4,   8, delta_MM4, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_MM4, dec_MM4})
    `ADD_N(add_MM4,         8, counter_next_MM4, cout_MM4, counter_MM4, delta_MM4, 1'b0)
    `REG_RST_WE(REG_MM4,    8, clk, combined_rst_n, 1'b1, counter_next_MM4, counter_MM4)

    // ----- MM5  (ID 20) -----
    wire dr_inc_MM5, sr_inc_MM5, inc_MM5, wb0_dec_MM5, wb1_dec_MM5, dec_MM5;
    wire [7:0] counter_MM5, delta_MM5, counter_next_MM5;
    wire cout_MM5;
    `AND_2(and_dr_inc_MM5,  1, dr_inc_MM5,  dr_gate,      dr_decoded[20])
    `AND_2(and_sr_inc_MM5,  1, sr_inc_MM5,  sr_gate,      sr_decoded[20])
    `OR_2 (or_inc_MM5,      1, inc_MM5,     dr_inc_MM5,   sr_inc_MM5)
    `AND_2(and_wb0_dec_MM5, 1, wb0_dec_MM5, wb_dr0_we,    wb0_decoded[20])
    `AND_2(and_wb1_dec_MM5, 1, wb1_dec_MM5, wb1_dec_gate, wb1_decoded[20])
    `OR_2 (or_dec_MM5,      1, dec_MM5,     wb0_dec_MM5,  wb1_dec_MM5)
    `MUX_4(mux_delta_MM5,   8, delta_MM5, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_MM5, dec_MM5})
    `ADD_N(add_MM5,         8, counter_next_MM5, cout_MM5, counter_MM5, delta_MM5, 1'b0)
    `REG_RST_WE(REG_MM5,    8, clk, combined_rst_n, 1'b1, counter_next_MM5, counter_MM5)

    // ----- MM6  (ID 21) -----
    wire dr_inc_MM6, sr_inc_MM6, inc_MM6, wb0_dec_MM6, wb1_dec_MM6, dec_MM6;
    wire [7:0] counter_MM6, delta_MM6, counter_next_MM6;
    wire cout_MM6;
    `AND_2(and_dr_inc_MM6,  1, dr_inc_MM6,  dr_gate,      dr_decoded[21])
    `AND_2(and_sr_inc_MM6,  1, sr_inc_MM6,  sr_gate,      sr_decoded[21])
    `OR_2 (or_inc_MM6,      1, inc_MM6,     dr_inc_MM6,   sr_inc_MM6)
    `AND_2(and_wb0_dec_MM6, 1, wb0_dec_MM6, wb_dr0_we,    wb0_decoded[21])
    `AND_2(and_wb1_dec_MM6, 1, wb1_dec_MM6, wb1_dec_gate, wb1_decoded[21])
    `OR_2 (or_dec_MM6,      1, dec_MM6,     wb0_dec_MM6,  wb1_dec_MM6)
    `MUX_4(mux_delta_MM6,   8, delta_MM6, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_MM6, dec_MM6})
    `ADD_N(add_MM6,         8, counter_next_MM6, cout_MM6, counter_MM6, delta_MM6, 1'b0)
    `REG_RST_WE(REG_MM6,    8, clk, combined_rst_n, 1'b1, counter_next_MM6, counter_MM6)

    // ----- MM7  (ID 22) -----
    wire dr_inc_MM7, sr_inc_MM7, inc_MM7, wb0_dec_MM7, wb1_dec_MM7, dec_MM7;
    wire [7:0] counter_MM7, delta_MM7, counter_next_MM7;
    wire cout_MM7;
    `AND_2(and_dr_inc_MM7,  1, dr_inc_MM7,  dr_gate,      dr_decoded[22])
    `AND_2(and_sr_inc_MM7,  1, sr_inc_MM7,  sr_gate,      sr_decoded[22])
    `OR_2 (or_inc_MM7,      1, inc_MM7,     dr_inc_MM7,   sr_inc_MM7)
    `AND_2(and_wb0_dec_MM7, 1, wb0_dec_MM7, wb_dr0_we,    wb0_decoded[22])
    `AND_2(and_wb1_dec_MM7, 1, wb1_dec_MM7, wb1_dec_gate, wb1_decoded[22])
    `OR_2 (or_dec_MM7,      1, dec_MM7,     wb0_dec_MM7,  wb1_dec_MM7)
    `MUX_4(mux_delta_MM7,   8, delta_MM7, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_MM7, dec_MM7})
    `ADD_N(add_MM7,         8, counter_next_MM7, cout_MM7, counter_MM7, delta_MM7, 1'b0)
    `REG_RST_WE(REG_MM7,    8, clk, combined_rst_n, 1'b1, counter_next_MM7, counter_MM7)

    // ----- ETR  (ID 23) -----
    wire dr_inc_ETR, sr_inc_ETR, inc_ETR, wb0_dec_ETR, wb1_dec_ETR, dec_ETR;
    wire [7:0] counter_ETR, delta_ETR, counter_next_ETR;
    wire cout_ETR;
    `AND_2(and_dr_inc_ETR,  1, dr_inc_ETR,  dr_gate,      dr_decoded[23])
    `AND_2(and_sr_inc_ETR,  1, sr_inc_ETR,  sr_gate,      sr_decoded[23])
    `OR_2 (or_inc_ETR,      1, inc_ETR,     dr_inc_ETR,   sr_inc_ETR)
    `AND_2(and_wb0_dec_ETR, 1, wb0_dec_ETR, wb_dr0_we,    wb0_decoded[23])
    `AND_2(and_wb1_dec_ETR, 1, wb1_dec_ETR, wb1_dec_gate, wb1_decoded[23])
    `OR_2 (or_dec_ETR,      1, dec_ETR,     wb0_dec_ETR,  wb1_dec_ETR)
    `MUX_4(mux_delta_ETR,   8, delta_ETR, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_ETR, dec_ETR})
    `ADD_N(add_ETR,         8, counter_next_ETR, cout_ETR, counter_ETR, delta_ETR, 1'b0)
    `REG_RST_WE(REG_ETR,    8, clk, combined_rst_n, 1'b1, counter_next_ETR, counter_ETR)

    // ----- ERROR_REG  (ID 24) -----
    wire dr_inc_ERR, sr_inc_ERR, inc_ERR, wb0_dec_ERR, wb1_dec_ERR, dec_ERR;
    wire [7:0] counter_ERR, delta_ERR, counter_next_ERR;
    wire cout_ERR;
    `AND_2(and_dr_inc_ERR,  1, dr_inc_ERR,  dr_gate,      dr_decoded[24])
    `AND_2(and_sr_inc_ERR,  1, sr_inc_ERR,  sr_gate,      sr_decoded[24])
    `OR_2 (or_inc_ERR,      1, inc_ERR,     dr_inc_ERR,   sr_inc_ERR)
    `AND_2(and_wb0_dec_ERR, 1, wb0_dec_ERR, wb_dr0_we,    wb0_decoded[24])
    `AND_2(and_wb1_dec_ERR, 1, wb1_dec_ERR, wb1_dec_gate, wb1_decoded[24])
    `OR_2 (or_dec_ERR,      1, dec_ERR,     wb0_dec_ERR,  wb1_dec_ERR)
    `MUX_4(mux_delta_ERR,   8, delta_ERR, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_ERR, dec_ERR})
    `ADD_N(add_ERR,         8, counter_next_ERR, cout_ERR, counter_ERR, delta_ERR, 1'b0)
    `REG_RST_WE(REG_ERR,    8, clk, combined_rst_n, 1'b1, counter_next_ERR, counter_ERR)

    // ----- NO_REG  (ID 25) -----
    wire dr_inc_NO, sr_inc_NO, inc_NO, wb0_dec_NO, wb1_dec_NO, dec_NO;
    wire [7:0] counter_NO, delta_NO, counter_next_NO;
    wire cout_NO;
    `AND_2(and_dr_inc_NO,  1, dr_inc_NO,  dr_gate,      dr_decoded[25])
    `AND_2(and_sr_inc_NO,  1, sr_inc_NO,  sr_gate,      sr_decoded[25])
    `OR_2 (or_inc_NO,      1, inc_NO,     dr_inc_NO,    sr_inc_NO)
    `AND_2(and_wb0_dec_NO, 1, wb0_dec_NO, wb_dr0_we,    wb0_decoded[25])
    `AND_2(and_wb1_dec_NO, 1, wb1_dec_NO, wb1_dec_gate, wb1_decoded[25])
    `OR_2 (or_dec_NO,      1, dec_NO,     wb0_dec_NO,   wb1_dec_NO)
    `MUX_4(mux_delta_NO,   8, delta_NO, 8'h00, 8'hFF, 8'h01, 8'h00, {inc_NO, dec_NO})
    `ADD_N(add_NO,         8, counter_next_NO, cout_NO, counter_NO, delta_NO, 1'b0)
    `REG_RST_WE(REG_NO,    8, clk, combined_rst_n, 1'b1, counter_next_NO, counter_NO)

    //=========================================================================
    // Stall paths
    //
    // For each stall source, look up the relevant counter via a MUX_32 over
    // the 26 counters (slots 26..31 tied to 0). Compare to 0, invert to get
    // "nonzero", then AND with the corresponding gate.
    //=========================================================================

    // dr/sr stall enables (cs_*_rd & memOrRep)
    wire gate_dr_rd, gate_sr_rd;
    `AND_2(and_gate_dr_rd, 1, gate_dr_rd, cs_dr_rd, memOrRep)
    `AND_2(and_gate_sr_rd, 1, gate_sr_rd, cs_sr_rd, memOrRep)

    // ----- dr_stall -----
    wire [7:0] counter_dr_lookup;
    wire eq_zero_dr, nonzero_dr, dr_stall;
    `MUX_32(mux_dr_lookup, 8, counter_dr_lookup,
        counter_CS, counter_DS, counter_SS, counter_ES,
        counter_FS, counter_GS, counter_EXPS, counter_EAX,
        counter_EBX, counter_ECX, counter_EDX, counter_ESI,
        counter_EDI, counter_ESP, counter_EBP, counter_MM0,
        counter_MM1, counter_MM2, counter_MM3, counter_MM4,
        counter_MM5, counter_MM6, counter_MM7, counter_ETR,
        counter_ERR, counter_NO, 8'h00, 8'h00,
        8'h00, 8'h00, 8'h00, 8'h00,
        dr_id)
    `CMP_N(cmp_zero_dr,   8, eq_zero_dr,  counter_dr_lookup, 8'h00)
    `INV_N(inv_zero_dr,   1, eq_zero_dr,  nonzero_dr)
    `AND_2(and_dr_stall,  1, dr_stall,    gate_dr_rd, nonzero_dr)

    // ----- sr_stall -----
    wire [7:0] counter_sr_lookup;
    wire eq_zero_sr, nonzero_sr, sr_stall;
    `MUX_32(mux_sr_lookup, 8, counter_sr_lookup,
        counter_CS, counter_DS, counter_SS, counter_ES,
        counter_FS, counter_GS, counter_EXPS, counter_EAX,
        counter_EBX, counter_ECX, counter_EDX, counter_ESI,
        counter_EDI, counter_ESP, counter_EBP, counter_MM0,
        counter_MM1, counter_MM2, counter_MM3, counter_MM4,
        counter_MM5, counter_MM6, counter_MM7, counter_ETR,
        counter_ERR, counter_NO, 8'h00, 8'h00,
        8'h00, 8'h00, 8'h00, 8'h00,
        sr_id)
    `CMP_N(cmp_zero_sr,   8, eq_zero_sr,  counter_sr_lookup, 8'h00)
    `INV_N(inv_zero_sr,   1, eq_zero_sr,  nonzero_sr)
    `AND_2(and_sr_stall,  1, sr_stall,    gate_sr_rd, nonzero_sr)

    // ----- seg0_stall (no gate) -----
    wire [7:0] counter_seg0_lookup;
    wire eq_zero_seg0, seg0_stall;
    `MUX_32(mux_seg0_lookup, 8, counter_seg0_lookup,
        counter_CS, counter_DS, counter_SS, counter_ES,
        counter_FS, counter_GS, counter_EXPS, counter_EAX,
        counter_EBX, counter_ECX, counter_EDX, counter_ESI,
        counter_EDI, counter_ESP, counter_EBP, counter_MM0,
        counter_MM1, counter_MM2, counter_MM3, counter_MM4,
        counter_MM5, counter_MM6, counter_MM7, counter_ETR,
        counter_ERR, counter_NO, 8'h00, 8'h00,
        8'h00, 8'h00, 8'h00, 8'h00,
        Segment0_ID)
    `CMP_N(cmp_zero_seg0, 8, eq_zero_seg0, counter_seg0_lookup, 8'h00)
    `INV_N(inv_zero_seg0, 1, eq_zero_seg0, seg0_stall)

    // ----- seg1_stall (gated by Segment1_valid) -----
    wire [7:0] counter_seg1_lookup;
    wire eq_zero_seg1, nonzero_seg1, seg1_stall;
    `MUX_32(mux_seg1_lookup, 8, counter_seg1_lookup,
        counter_CS, counter_DS, counter_SS, counter_ES,
        counter_FS, counter_GS, counter_EXPS, counter_EAX,
        counter_EBX, counter_ECX, counter_EDX, counter_ESI,
        counter_EDI, counter_ESP, counter_EBP, counter_MM0,
        counter_MM1, counter_MM2, counter_MM3, counter_MM4,
        counter_MM5, counter_MM6, counter_MM7, counter_ETR,
        counter_ERR, counter_NO, 8'h00, 8'h00,
        8'h00, 8'h00, 8'h00, 8'h00,
        Segment1_ID)
    `CMP_N(cmp_zero_seg1,   8, eq_zero_seg1,  counter_seg1_lookup, 8'h00)
    `INV_N(inv_zero_seg1,   1, eq_zero_seg1,  nonzero_seg1)
    `AND_2(and_seg1_stall,  1, seg1_stall,    Segment1_valid, nonzero_seg1)

    // ----- sib_base_stall (gated by cs_sib_size) -----
    wire [7:0] counter_sib_base_lookup;
    wire eq_zero_sib_base, nonzero_sib_base, sib_base_stall;
    `MUX_32(mux_sib_base_lookup, 8, counter_sib_base_lookup,
        counter_CS, counter_DS, counter_SS, counter_ES,
        counter_FS, counter_GS, counter_EXPS, counter_EAX,
        counter_EBX, counter_ECX, counter_EDX, counter_ESI,
        counter_EDI, counter_ESP, counter_EBP, counter_MM0,
        counter_MM1, counter_MM2, counter_MM3, counter_MM4,
        counter_MM5, counter_MM6, counter_MM7, counter_ETR,
        counter_ERR, counter_NO, 8'h00, 8'h00,
        8'h00, 8'h00, 8'h00, 8'h00,
        sib_base_id)
    `CMP_N(cmp_zero_sib_base, 8, eq_zero_sib_base, counter_sib_base_lookup, 8'h00)
    `INV_N(inv_zero_sib_base, 1, eq_zero_sib_base, nonzero_sib_base)
    `AND_2(and_sib_base_stall,1, sib_base_stall,   cs_sib_size, nonzero_sib_base)

    // ----- sib_idx_stall (gated by cs_sib_size) -----
    wire [7:0] counter_sib_idx_lookup;
    wire eq_zero_sib_idx, nonzero_sib_idx, sib_idx_stall;
    `MUX_32(mux_sib_idx_lookup, 8, counter_sib_idx_lookup,
        counter_CS, counter_DS, counter_SS, counter_ES,
        counter_FS, counter_GS, counter_EXPS, counter_EAX,
        counter_EBX, counter_ECX, counter_EDX, counter_ESI,
        counter_EDI, counter_ESP, counter_EBP, counter_MM0,
        counter_MM1, counter_MM2, counter_MM3, counter_MM4,
        counter_MM5, counter_MM6, counter_MM7, counter_ETR,
        counter_ERR, counter_NO, 8'h00, 8'h00,
        8'h00, 8'h00, 8'h00, 8'h00,
        sib_idx_id)
    `CMP_N(cmp_zero_sib_idx, 8, eq_zero_sib_idx, counter_sib_idx_lookup, 8'h00)
    `INV_N(inv_zero_sib_idx, 1, eq_zero_sib_idx, nonzero_sib_idx)
    `AND_2(and_sib_idx_stall,1, sib_idx_stall,   cs_sib_size, nonzero_sib_idx)

    // ----- dep_stall = OR of 6 stall sources (eax_stall is hardcoded 0 in SV) -----
    `OR_6(or_dep_stall, 1, dep_stall,
        dr_stall, sr_stall, seg0_stall, seg1_stall, sib_base_stall, sib_idx_stall)

    //=========================================================================
    // Constant-id status outputs: ecx_sb (counter_ECX != 0), codeSeg_sb (CS != 0)
    //=========================================================================
    wire eq_zero_ecx;
    `CMP_N(cmp_zero_ecx, 8, eq_zero_ecx, counter_ECX, 8'h00)
    `INV_N(inv_zero_ecx, 1, eq_zero_ecx, ecx_sb)

    wire eq_zero_cs;
    `CMP_N(cmp_zero_cs,  8, eq_zero_cs,  counter_CS,  8'h00)
    `INV_N(inv_zero_cs,  1, eq_zero_cs,  codeSeg_sb)

endmodule
