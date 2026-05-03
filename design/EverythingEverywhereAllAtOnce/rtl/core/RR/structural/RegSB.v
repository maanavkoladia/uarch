`include "STDCell_Macros.vh"

//=============================================================================
// RegSB - structural Verilog 2005 port of RegSB.sv
//
// 26 8-bit scoreboard counters, one per arch register (reg_ids_e):
//   CS=0, DS=1, SS=2, ES=3, FS=4, GS=5, EXPS=6,
//   EAX=7, EBX=8, ECX=9, EDX=10, ESI=11, EDI=12, ESP=13, EBP=14,
//   MM0=15..MM7=22, ETR=23, ERROR_REG=24, NO_REG=25.
//
// Per cycle each counter does counter_next = counter + inc - dec, where
//   inc and dec are each 0 or 1 (capped per user direction).
//
// Increment path (gated by updateSB = ~dep_stall & instructionforward):
//   dr-path : cs_dr_wr & (dr_id == i)
//   sr-path : cs_sr_wr & (sr_id == i) & ~cs_wr_to_both
//   eax-path: only on i==EAX, cs_eax_wr & ~cs_wr_to_both
//   inc[i]  = OR of the three (capped at 1)
//
// Decrement path (always, no updateSB gating):
//   wb0-path: wb_dr0_we & (wb_dr0_id == i)
//   wb1-path: wb_dr1_we & (wb_dr1_id == i) & ~wb_wr_to_both
//   dec[i]  = OR of the two (naturally at most 1)
//
// Reset (sync, all counters -> 0): !rst | flush | callFlush | farFlush.
// Folded into a single active-low reset feeding REG_RST_WE; we is tied 1'b1.
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
    // Shared signals
    //=========================================================================

    // combined_rst_n = rst & ~(flush | callFlush | farFlush)
    wire flushes_none, combined_rst_n;
    `NOR_3(nor_flushes, 1, flushes_none, flush, callFlush, farFlush)
    `AND_2(and_combined_rst, 1, combined_rst_n, rst, flushes_none)

    // cs_wr_to_both = cs_dr_wr & cs_sr_wr & (dr_id == sr_id)
    wire dr_eq_sr, cs_drsr_wr, cs_wr_to_both, cs_wr_to_both_n;
    `CMP_N(cmp_drsr_id, 5, dr_eq_sr, dr_id, sr_id)
    `AND_2(and_cs_drsr_wr, 1, cs_drsr_wr, cs_dr_wr, cs_sr_wr)
    `AND_2(and_cs_wr_to_both, 1, cs_wr_to_both, cs_drsr_wr, dr_eq_sr)
    `INV_N(inv_cs_wr_to_both, 1, cs_wr_to_both, cs_wr_to_both_n)

    // wb_wr_to_both = wb_dr0_we & wb_dr1_we & (wb_dr0_id == wb_dr1_id)
    wire wb_dr0_eq_dr1, wb_drs_we, wb_wr_to_both, wb_wr_to_both_n;
    `CMP_N(cmp_wb_drs_id, 5, wb_dr0_eq_dr1, wb_dr0_id, wb_dr1_id)
    `AND_2(and_wb_drs_we, 1, wb_drs_we, wb_dr0_we, wb_dr1_we)
    `AND_2(and_wb_wr_to_both, 1, wb_wr_to_both, wb_drs_we, wb_dr0_eq_dr1)
    `INV_N(inv_wb_wr_to_both, 1, wb_wr_to_both, wb_wr_to_both_n)

    // memOrRep = LD_OP | ST_OP | REP_OP
    wire memOrRep;
    `OR_3(or_memOrRep, 1, memOrRep, LD_OP, ST_OP, REP_OP)

    // updateSB = ~dep_stall & instructionforward
    wire dep_stall_n, updateSB;
    `INV_N(inv_dep_stall, 1, dep_stall, dep_stall_n)
    `AND_2(and_updateSB, 1, updateSB, dep_stall_n, instructionforward)

    // Per-instruction shared eax-path increment bit (constant target = EAX).
    // eax_inc_global = updateSB & cs_eax_wr & ~cs_wr_to_both.
    // For all registers other than EAX this is masked to 1'b0 inside the slot.
    wire eax_inc_global_pre, eax_inc_global;
    `AND_2(and_eax_inc_pre, 1, eax_inc_global_pre, updateSB, cs_eax_wr)
    `AND_2(and_eax_inc, 1, eax_inc_global, eax_inc_global_pre, cs_wr_to_both_n)

    //=========================================================================
    // Per-register slot
    //
    //   match_dr_R   = (dr_id      == i)
    //   match_sr_R   = (sr_id      == i)
    //   match_wb0_R  = (wb_dr0_id  == i)
    //   match_wb1_R  = (wb_dr1_id  == i)
    //
    //   dr_inc_R   = updateSB & cs_dr_wr & match_dr_R
    //   sr_inc_R   = updateSB & cs_sr_wr & match_sr_R & ~cs_wr_to_both
    //   eax_inc_R  = (i==EAX) ? eax_inc_global : 1'b0
    //   inc_R      = dr_inc_R | sr_inc_R | eax_inc_R       (capped at 1)
    //
    //   wb0_dec_R  = wb_dr0_we & match_wb0_R
    //   wb1_dec_R  = wb_dr1_we & match_wb1_R & ~wb_wr_to_both
    //   dec_R      = wb0_dec_R | wb1_dec_R                  (naturally <= 1)
    //
    //   counter_R          = REG_RST_WE(8) state
    //   inc_8b_R           = {7'b0, inc_R}
    //   dec_neg_8b_R       = dec_R ? 8'hFF : 8'h00          (-dec sign-extended)
    //   counter_plus_inc_R = ADD_N(counter_R, inc_8b_R)
    //   counter_next_R     = ADD_N(counter_plus_inc_R, dec_neg_8b_R)
    //=========================================================================

    // ----- CS  (ID 0) -----
    wire match_dr_CS, match_sr_CS, match_wb0_CS, match_wb1_CS;
    wire dr_inc_CS, sr_inc_pre_CS, sr_inc_CS, inc_CS;
    wire wb0_dec_CS, wb1_dec_pre_CS, wb1_dec_CS, dec_CS;
    wire [7:0] counter_CS, inc_8b_CS, dec_neg_8b_CS;
    wire [7:0] counter_plus_inc_CS, counter_next_CS;
    wire cout_inc_CS, cout_next_CS;
    `CMP_N(cmp_dr_CS,  5, match_dr_CS,  dr_id,     5'd0)
    `CMP_N(cmp_sr_CS,  5, match_sr_CS,  sr_id,     5'd0)
    `CMP_N(cmp_wb0_CS, 5, match_wb0_CS, wb_dr0_id, 5'd0)
    `CMP_N(cmp_wb1_CS, 5, match_wb1_CS, wb_dr1_id, 5'd0)
    `AND_3(and_dr_inc_CS,     1, dr_inc_CS,     updateSB, cs_dr_wr, match_dr_CS)
    `AND_3(and_sr_inc_pre_CS, 1, sr_inc_pre_CS, updateSB, cs_sr_wr, match_sr_CS)
    `AND_2(and_sr_inc_CS,     1, sr_inc_CS,     sr_inc_pre_CS, cs_wr_to_both_n)
    `OR_3 (or_inc_CS,         1, inc_CS,        dr_inc_CS, sr_inc_CS, 1'b0)
    `AND_2(and_wb0_dec_CS,     1, wb0_dec_CS,     wb_dr0_we, match_wb0_CS)
    `AND_2(and_wb1_dec_pre_CS, 1, wb1_dec_pre_CS, wb_dr1_we, match_wb1_CS)
    `AND_2(and_wb1_dec_CS,     1, wb1_dec_CS,     wb1_dec_pre_CS, wb_wr_to_both_n)
    `OR_2 (or_dec_CS,          1, dec_CS,         wb0_dec_CS, wb1_dec_CS)
    assign inc_8b_CS[7:1] = 7'b0;
    assign inc_8b_CS[0]   = inc_CS;
    `MUX_2(mux_decneg_CS, 8, dec_neg_8b_CS, 8'h00, 8'hFF, dec_CS)
    `ADD_N(add_inc_CS,  8, counter_plus_inc_CS, cout_inc_CS,  counter_CS,          inc_8b_CS,     1'b0)
    `ADD_N(add_next_CS, 8, counter_next_CS,     cout_next_CS, counter_plus_inc_CS, dec_neg_8b_CS, 1'b0)
    `REG_RST_WE(REG_CS, 8, clk, combined_rst_n, 1'b1, counter_next_CS, counter_CS)

    // ----- DS  (ID 1) -----
    wire match_dr_DS, match_sr_DS, match_wb0_DS, match_wb1_DS;
    wire dr_inc_DS, sr_inc_pre_DS, sr_inc_DS, inc_DS;
    wire wb0_dec_DS, wb1_dec_pre_DS, wb1_dec_DS, dec_DS;
    wire [7:0] counter_DS, inc_8b_DS, dec_neg_8b_DS;
    wire [7:0] counter_plus_inc_DS, counter_next_DS;
    wire cout_inc_DS, cout_next_DS;
    `CMP_N(cmp_dr_DS,  5, match_dr_DS,  dr_id,     5'd1)
    `CMP_N(cmp_sr_DS,  5, match_sr_DS,  sr_id,     5'd1)
    `CMP_N(cmp_wb0_DS, 5, match_wb0_DS, wb_dr0_id, 5'd1)
    `CMP_N(cmp_wb1_DS, 5, match_wb1_DS, wb_dr1_id, 5'd1)
    `AND_3(and_dr_inc_DS,     1, dr_inc_DS,     updateSB, cs_dr_wr, match_dr_DS)
    `AND_3(and_sr_inc_pre_DS, 1, sr_inc_pre_DS, updateSB, cs_sr_wr, match_sr_DS)
    `AND_2(and_sr_inc_DS,     1, sr_inc_DS,     sr_inc_pre_DS, cs_wr_to_both_n)
    `OR_3 (or_inc_DS,         1, inc_DS,        dr_inc_DS, sr_inc_DS, 1'b0)
    `AND_2(and_wb0_dec_DS,     1, wb0_dec_DS,     wb_dr0_we, match_wb0_DS)
    `AND_2(and_wb1_dec_pre_DS, 1, wb1_dec_pre_DS, wb_dr1_we, match_wb1_DS)
    `AND_2(and_wb1_dec_DS,     1, wb1_dec_DS,     wb1_dec_pre_DS, wb_wr_to_both_n)
    `OR_2 (or_dec_DS,          1, dec_DS,         wb0_dec_DS, wb1_dec_DS)
    assign inc_8b_DS[7:1] = 7'b0;
    assign inc_8b_DS[0]   = inc_DS;
    `MUX_2(mux_decneg_DS, 8, dec_neg_8b_DS, 8'h00, 8'hFF, dec_DS)
    `ADD_N(add_inc_DS,  8, counter_plus_inc_DS, cout_inc_DS,  counter_DS,          inc_8b_DS,     1'b0)
    `ADD_N(add_next_DS, 8, counter_next_DS,     cout_next_DS, counter_plus_inc_DS, dec_neg_8b_DS, 1'b0)
    `REG_RST_WE(REG_DS, 8, clk, combined_rst_n, 1'b1, counter_next_DS, counter_DS)

    // ----- SS  (ID 2) -----
    wire match_dr_SS, match_sr_SS, match_wb0_SS, match_wb1_SS;
    wire dr_inc_SS, sr_inc_pre_SS, sr_inc_SS, inc_SS;
    wire wb0_dec_SS, wb1_dec_pre_SS, wb1_dec_SS, dec_SS;
    wire [7:0] counter_SS, inc_8b_SS, dec_neg_8b_SS;
    wire [7:0] counter_plus_inc_SS, counter_next_SS;
    wire cout_inc_SS, cout_next_SS;
    `CMP_N(cmp_dr_SS,  5, match_dr_SS,  dr_id,     5'd2)
    `CMP_N(cmp_sr_SS,  5, match_sr_SS,  sr_id,     5'd2)
    `CMP_N(cmp_wb0_SS, 5, match_wb0_SS, wb_dr0_id, 5'd2)
    `CMP_N(cmp_wb1_SS, 5, match_wb1_SS, wb_dr1_id, 5'd2)
    `AND_3(and_dr_inc_SS,     1, dr_inc_SS,     updateSB, cs_dr_wr, match_dr_SS)
    `AND_3(and_sr_inc_pre_SS, 1, sr_inc_pre_SS, updateSB, cs_sr_wr, match_sr_SS)
    `AND_2(and_sr_inc_SS,     1, sr_inc_SS,     sr_inc_pre_SS, cs_wr_to_both_n)
    `OR_3 (or_inc_SS,         1, inc_SS,        dr_inc_SS, sr_inc_SS, 1'b0)
    `AND_2(and_wb0_dec_SS,     1, wb0_dec_SS,     wb_dr0_we, match_wb0_SS)
    `AND_2(and_wb1_dec_pre_SS, 1, wb1_dec_pre_SS, wb_dr1_we, match_wb1_SS)
    `AND_2(and_wb1_dec_SS,     1, wb1_dec_SS,     wb1_dec_pre_SS, wb_wr_to_both_n)
    `OR_2 (or_dec_SS,          1, dec_SS,         wb0_dec_SS, wb1_dec_SS)
    assign inc_8b_SS[7:1] = 7'b0;
    assign inc_8b_SS[0]   = inc_SS;
    `MUX_2(mux_decneg_SS, 8, dec_neg_8b_SS, 8'h00, 8'hFF, dec_SS)
    `ADD_N(add_inc_SS,  8, counter_plus_inc_SS, cout_inc_SS,  counter_SS,          inc_8b_SS,     1'b0)
    `ADD_N(add_next_SS, 8, counter_next_SS,     cout_next_SS, counter_plus_inc_SS, dec_neg_8b_SS, 1'b0)
    `REG_RST_WE(REG_SS, 8, clk, combined_rst_n, 1'b1, counter_next_SS, counter_SS)

    // ----- ES  (ID 3) -----
    wire match_dr_ES, match_sr_ES, match_wb0_ES, match_wb1_ES;
    wire dr_inc_ES, sr_inc_pre_ES, sr_inc_ES, inc_ES;
    wire wb0_dec_ES, wb1_dec_pre_ES, wb1_dec_ES, dec_ES;
    wire [7:0] counter_ES, inc_8b_ES, dec_neg_8b_ES;
    wire [7:0] counter_plus_inc_ES, counter_next_ES;
    wire cout_inc_ES, cout_next_ES;
    `CMP_N(cmp_dr_ES,  5, match_dr_ES,  dr_id,     5'd3)
    `CMP_N(cmp_sr_ES,  5, match_sr_ES,  sr_id,     5'd3)
    `CMP_N(cmp_wb0_ES, 5, match_wb0_ES, wb_dr0_id, 5'd3)
    `CMP_N(cmp_wb1_ES, 5, match_wb1_ES, wb_dr1_id, 5'd3)
    `AND_3(and_dr_inc_ES,     1, dr_inc_ES,     updateSB, cs_dr_wr, match_dr_ES)
    `AND_3(and_sr_inc_pre_ES, 1, sr_inc_pre_ES, updateSB, cs_sr_wr, match_sr_ES)
    `AND_2(and_sr_inc_ES,     1, sr_inc_ES,     sr_inc_pre_ES, cs_wr_to_both_n)
    `OR_3 (or_inc_ES,         1, inc_ES,        dr_inc_ES, sr_inc_ES, 1'b0)
    `AND_2(and_wb0_dec_ES,     1, wb0_dec_ES,     wb_dr0_we, match_wb0_ES)
    `AND_2(and_wb1_dec_pre_ES, 1, wb1_dec_pre_ES, wb_dr1_we, match_wb1_ES)
    `AND_2(and_wb1_dec_ES,     1, wb1_dec_ES,     wb1_dec_pre_ES, wb_wr_to_both_n)
    `OR_2 (or_dec_ES,          1, dec_ES,         wb0_dec_ES, wb1_dec_ES)
    assign inc_8b_ES[7:1] = 7'b0;
    assign inc_8b_ES[0]   = inc_ES;
    `MUX_2(mux_decneg_ES, 8, dec_neg_8b_ES, 8'h00, 8'hFF, dec_ES)
    `ADD_N(add_inc_ES,  8, counter_plus_inc_ES, cout_inc_ES,  counter_ES,          inc_8b_ES,     1'b0)
    `ADD_N(add_next_ES, 8, counter_next_ES,     cout_next_ES, counter_plus_inc_ES, dec_neg_8b_ES, 1'b0)
    `REG_RST_WE(REG_ES, 8, clk, combined_rst_n, 1'b1, counter_next_ES, counter_ES)

    // ----- FS  (ID 4) -----
    wire match_dr_FS, match_sr_FS, match_wb0_FS, match_wb1_FS;
    wire dr_inc_FS, sr_inc_pre_FS, sr_inc_FS, inc_FS;
    wire wb0_dec_FS, wb1_dec_pre_FS, wb1_dec_FS, dec_FS;
    wire [7:0] counter_FS, inc_8b_FS, dec_neg_8b_FS;
    wire [7:0] counter_plus_inc_FS, counter_next_FS;
    wire cout_inc_FS, cout_next_FS;
    `CMP_N(cmp_dr_FS,  5, match_dr_FS,  dr_id,     5'd4)
    `CMP_N(cmp_sr_FS,  5, match_sr_FS,  sr_id,     5'd4)
    `CMP_N(cmp_wb0_FS, 5, match_wb0_FS, wb_dr0_id, 5'd4)
    `CMP_N(cmp_wb1_FS, 5, match_wb1_FS, wb_dr1_id, 5'd4)
    `AND_3(and_dr_inc_FS,     1, dr_inc_FS,     updateSB, cs_dr_wr, match_dr_FS)
    `AND_3(and_sr_inc_pre_FS, 1, sr_inc_pre_FS, updateSB, cs_sr_wr, match_sr_FS)
    `AND_2(and_sr_inc_FS,     1, sr_inc_FS,     sr_inc_pre_FS, cs_wr_to_both_n)
    `OR_3 (or_inc_FS,         1, inc_FS,        dr_inc_FS, sr_inc_FS, 1'b0)
    `AND_2(and_wb0_dec_FS,     1, wb0_dec_FS,     wb_dr0_we, match_wb0_FS)
    `AND_2(and_wb1_dec_pre_FS, 1, wb1_dec_pre_FS, wb_dr1_we, match_wb1_FS)
    `AND_2(and_wb1_dec_FS,     1, wb1_dec_FS,     wb1_dec_pre_FS, wb_wr_to_both_n)
    `OR_2 (or_dec_FS,          1, dec_FS,         wb0_dec_FS, wb1_dec_FS)
    assign inc_8b_FS[7:1] = 7'b0;
    assign inc_8b_FS[0]   = inc_FS;
    `MUX_2(mux_decneg_FS, 8, dec_neg_8b_FS, 8'h00, 8'hFF, dec_FS)
    `ADD_N(add_inc_FS,  8, counter_plus_inc_FS, cout_inc_FS,  counter_FS,          inc_8b_FS,     1'b0)
    `ADD_N(add_next_FS, 8, counter_next_FS,     cout_next_FS, counter_plus_inc_FS, dec_neg_8b_FS, 1'b0)
    `REG_RST_WE(REG_FS, 8, clk, combined_rst_n, 1'b1, counter_next_FS, counter_FS)

    // ----- GS  (ID 5) -----
    wire match_dr_GS, match_sr_GS, match_wb0_GS, match_wb1_GS;
    wire dr_inc_GS, sr_inc_pre_GS, sr_inc_GS, inc_GS;
    wire wb0_dec_GS, wb1_dec_pre_GS, wb1_dec_GS, dec_GS;
    wire [7:0] counter_GS, inc_8b_GS, dec_neg_8b_GS;
    wire [7:0] counter_plus_inc_GS, counter_next_GS;
    wire cout_inc_GS, cout_next_GS;
    `CMP_N(cmp_dr_GS,  5, match_dr_GS,  dr_id,     5'd5)
    `CMP_N(cmp_sr_GS,  5, match_sr_GS,  sr_id,     5'd5)
    `CMP_N(cmp_wb0_GS, 5, match_wb0_GS, wb_dr0_id, 5'd5)
    `CMP_N(cmp_wb1_GS, 5, match_wb1_GS, wb_dr1_id, 5'd5)
    `AND_3(and_dr_inc_GS,     1, dr_inc_GS,     updateSB, cs_dr_wr, match_dr_GS)
    `AND_3(and_sr_inc_pre_GS, 1, sr_inc_pre_GS, updateSB, cs_sr_wr, match_sr_GS)
    `AND_2(and_sr_inc_GS,     1, sr_inc_GS,     sr_inc_pre_GS, cs_wr_to_both_n)
    `OR_3 (or_inc_GS,         1, inc_GS,        dr_inc_GS, sr_inc_GS, 1'b0)
    `AND_2(and_wb0_dec_GS,     1, wb0_dec_GS,     wb_dr0_we, match_wb0_GS)
    `AND_2(and_wb1_dec_pre_GS, 1, wb1_dec_pre_GS, wb_dr1_we, match_wb1_GS)
    `AND_2(and_wb1_dec_GS,     1, wb1_dec_GS,     wb1_dec_pre_GS, wb_wr_to_both_n)
    `OR_2 (or_dec_GS,          1, dec_GS,         wb0_dec_GS, wb1_dec_GS)
    assign inc_8b_GS[7:1] = 7'b0;
    assign inc_8b_GS[0]   = inc_GS;
    `MUX_2(mux_decneg_GS, 8, dec_neg_8b_GS, 8'h00, 8'hFF, dec_GS)
    `ADD_N(add_inc_GS,  8, counter_plus_inc_GS, cout_inc_GS,  counter_GS,          inc_8b_GS,     1'b0)
    `ADD_N(add_next_GS, 8, counter_next_GS,     cout_next_GS, counter_plus_inc_GS, dec_neg_8b_GS, 1'b0)
    `REG_RST_WE(REG_GS, 8, clk, combined_rst_n, 1'b1, counter_next_GS, counter_GS)

    // ----- EXPS  (ID 6) -----
    wire match_dr_EXPS, match_sr_EXPS, match_wb0_EXPS, match_wb1_EXPS;
    wire dr_inc_EXPS, sr_inc_pre_EXPS, sr_inc_EXPS, inc_EXPS;
    wire wb0_dec_EXPS, wb1_dec_pre_EXPS, wb1_dec_EXPS, dec_EXPS;
    wire [7:0] counter_EXPS, inc_8b_EXPS, dec_neg_8b_EXPS;
    wire [7:0] counter_plus_inc_EXPS, counter_next_EXPS;
    wire cout_inc_EXPS, cout_next_EXPS;
    `CMP_N(cmp_dr_EXPS,  5, match_dr_EXPS,  dr_id,     5'd6)
    `CMP_N(cmp_sr_EXPS,  5, match_sr_EXPS,  sr_id,     5'd6)
    `CMP_N(cmp_wb0_EXPS, 5, match_wb0_EXPS, wb_dr0_id, 5'd6)
    `CMP_N(cmp_wb1_EXPS, 5, match_wb1_EXPS, wb_dr1_id, 5'd6)
    `AND_3(and_dr_inc_EXPS,     1, dr_inc_EXPS,     updateSB, cs_dr_wr, match_dr_EXPS)
    `AND_3(and_sr_inc_pre_EXPS, 1, sr_inc_pre_EXPS, updateSB, cs_sr_wr, match_sr_EXPS)
    `AND_2(and_sr_inc_EXPS,     1, sr_inc_EXPS,     sr_inc_pre_EXPS, cs_wr_to_both_n)
    `OR_3 (or_inc_EXPS,         1, inc_EXPS,        dr_inc_EXPS, sr_inc_EXPS, 1'b0)
    `AND_2(and_wb0_dec_EXPS,     1, wb0_dec_EXPS,     wb_dr0_we, match_wb0_EXPS)
    `AND_2(and_wb1_dec_pre_EXPS, 1, wb1_dec_pre_EXPS, wb_dr1_we, match_wb1_EXPS)
    `AND_2(and_wb1_dec_EXPS,     1, wb1_dec_EXPS,     wb1_dec_pre_EXPS, wb_wr_to_both_n)
    `OR_2 (or_dec_EXPS,          1, dec_EXPS,         wb0_dec_EXPS, wb1_dec_EXPS)
    assign inc_8b_EXPS[7:1] = 7'b0;
    assign inc_8b_EXPS[0]   = inc_EXPS;
    `MUX_2(mux_decneg_EXPS, 8, dec_neg_8b_EXPS, 8'h00, 8'hFF, dec_EXPS)
    `ADD_N(add_inc_EXPS,  8, counter_plus_inc_EXPS, cout_inc_EXPS,  counter_EXPS,          inc_8b_EXPS,     1'b0)
    `ADD_N(add_next_EXPS, 8, counter_next_EXPS,     cout_next_EXPS, counter_plus_inc_EXPS, dec_neg_8b_EXPS, 1'b0)
    `REG_RST_WE(REG_EXPS, 8, clk, combined_rst_n, 1'b1, counter_next_EXPS, counter_EXPS)

    // ----- EAX  (ID 7) -- ONLY register that takes the eax-path increment -----
    wire match_dr_EAX, match_sr_EAX, match_wb0_EAX, match_wb1_EAX;
    wire dr_inc_EAX, sr_inc_pre_EAX, sr_inc_EAX, inc_EAX;
    wire wb0_dec_EAX, wb1_dec_pre_EAX, wb1_dec_EAX, dec_EAX;
    wire [7:0] counter_EAX, inc_8b_EAX, dec_neg_8b_EAX;
    wire [7:0] counter_plus_inc_EAX, counter_next_EAX;
    wire cout_inc_EAX, cout_next_EAX;
    `CMP_N(cmp_dr_EAX,  5, match_dr_EAX,  dr_id,     5'd7)
    `CMP_N(cmp_sr_EAX,  5, match_sr_EAX,  sr_id,     5'd7)
    `CMP_N(cmp_wb0_EAX, 5, match_wb0_EAX, wb_dr0_id, 5'd7)
    `CMP_N(cmp_wb1_EAX, 5, match_wb1_EAX, wb_dr1_id, 5'd7)
    `AND_3(and_dr_inc_EAX,     1, dr_inc_EAX,     updateSB, cs_dr_wr, match_dr_EAX)
    `AND_3(and_sr_inc_pre_EAX, 1, sr_inc_pre_EAX, updateSB, cs_sr_wr, match_sr_EAX)
    `AND_2(and_sr_inc_EAX,     1, sr_inc_EAX,     sr_inc_pre_EAX, cs_wr_to_both_n)
    `OR_3 (or_inc_EAX,         1, inc_EAX,        dr_inc_EAX, sr_inc_EAX, eax_inc_global)
    `AND_2(and_wb0_dec_EAX,     1, wb0_dec_EAX,     wb_dr0_we, match_wb0_EAX)
    `AND_2(and_wb1_dec_pre_EAX, 1, wb1_dec_pre_EAX, wb_dr1_we, match_wb1_EAX)
    `AND_2(and_wb1_dec_EAX,     1, wb1_dec_EAX,     wb1_dec_pre_EAX, wb_wr_to_both_n)
    `OR_2 (or_dec_EAX,          1, dec_EAX,         wb0_dec_EAX, wb1_dec_EAX)
    assign inc_8b_EAX[7:1] = 7'b0;
    assign inc_8b_EAX[0]   = inc_EAX;
    `MUX_2(mux_decneg_EAX, 8, dec_neg_8b_EAX, 8'h00, 8'hFF, dec_EAX)
    `ADD_N(add_inc_EAX,  8, counter_plus_inc_EAX, cout_inc_EAX,  counter_EAX,          inc_8b_EAX,     1'b0)
    `ADD_N(add_next_EAX, 8, counter_next_EAX,     cout_next_EAX, counter_plus_inc_EAX, dec_neg_8b_EAX, 1'b0)
    `REG_RST_WE(REG_EAX, 8, clk, combined_rst_n, 1'b1, counter_next_EAX, counter_EAX)

    // ----- EBX  (ID 8) -----
    wire match_dr_EBX, match_sr_EBX, match_wb0_EBX, match_wb1_EBX;
    wire dr_inc_EBX, sr_inc_pre_EBX, sr_inc_EBX, inc_EBX;
    wire wb0_dec_EBX, wb1_dec_pre_EBX, wb1_dec_EBX, dec_EBX;
    wire [7:0] counter_EBX, inc_8b_EBX, dec_neg_8b_EBX;
    wire [7:0] counter_plus_inc_EBX, counter_next_EBX;
    wire cout_inc_EBX, cout_next_EBX;
    `CMP_N(cmp_dr_EBX,  5, match_dr_EBX,  dr_id,     5'd8)
    `CMP_N(cmp_sr_EBX,  5, match_sr_EBX,  sr_id,     5'd8)
    `CMP_N(cmp_wb0_EBX, 5, match_wb0_EBX, wb_dr0_id, 5'd8)
    `CMP_N(cmp_wb1_EBX, 5, match_wb1_EBX, wb_dr1_id, 5'd8)
    `AND_3(and_dr_inc_EBX,     1, dr_inc_EBX,     updateSB, cs_dr_wr, match_dr_EBX)
    `AND_3(and_sr_inc_pre_EBX, 1, sr_inc_pre_EBX, updateSB, cs_sr_wr, match_sr_EBX)
    `AND_2(and_sr_inc_EBX,     1, sr_inc_EBX,     sr_inc_pre_EBX, cs_wr_to_both_n)
    `OR_3 (or_inc_EBX,         1, inc_EBX,        dr_inc_EBX, sr_inc_EBX, 1'b0)
    `AND_2(and_wb0_dec_EBX,     1, wb0_dec_EBX,     wb_dr0_we, match_wb0_EBX)
    `AND_2(and_wb1_dec_pre_EBX, 1, wb1_dec_pre_EBX, wb_dr1_we, match_wb1_EBX)
    `AND_2(and_wb1_dec_EBX,     1, wb1_dec_EBX,     wb1_dec_pre_EBX, wb_wr_to_both_n)
    `OR_2 (or_dec_EBX,          1, dec_EBX,         wb0_dec_EBX, wb1_dec_EBX)
    assign inc_8b_EBX[7:1] = 7'b0;
    assign inc_8b_EBX[0]   = inc_EBX;
    `MUX_2(mux_decneg_EBX, 8, dec_neg_8b_EBX, 8'h00, 8'hFF, dec_EBX)
    `ADD_N(add_inc_EBX,  8, counter_plus_inc_EBX, cout_inc_EBX,  counter_EBX,          inc_8b_EBX,     1'b0)
    `ADD_N(add_next_EBX, 8, counter_next_EBX,     cout_next_EBX, counter_plus_inc_EBX, dec_neg_8b_EBX, 1'b0)
    `REG_RST_WE(REG_EBX, 8, clk, combined_rst_n, 1'b1, counter_next_EBX, counter_EBX)

    // ----- ECX  (ID 9) -----
    wire match_dr_ECX, match_sr_ECX, match_wb0_ECX, match_wb1_ECX;
    wire dr_inc_ECX, sr_inc_pre_ECX, sr_inc_ECX, inc_ECX;
    wire wb0_dec_ECX, wb1_dec_pre_ECX, wb1_dec_ECX, dec_ECX;
    wire [7:0] counter_ECX, inc_8b_ECX, dec_neg_8b_ECX;
    wire [7:0] counter_plus_inc_ECX, counter_next_ECX;
    wire cout_inc_ECX, cout_next_ECX;
    `CMP_N(cmp_dr_ECX,  5, match_dr_ECX,  dr_id,     5'd9)
    `CMP_N(cmp_sr_ECX,  5, match_sr_ECX,  sr_id,     5'd9)
    `CMP_N(cmp_wb0_ECX, 5, match_wb0_ECX, wb_dr0_id, 5'd9)
    `CMP_N(cmp_wb1_ECX, 5, match_wb1_ECX, wb_dr1_id, 5'd9)
    `AND_3(and_dr_inc_ECX,     1, dr_inc_ECX,     updateSB, cs_dr_wr, match_dr_ECX)
    `AND_3(and_sr_inc_pre_ECX, 1, sr_inc_pre_ECX, updateSB, cs_sr_wr, match_sr_ECX)
    `AND_2(and_sr_inc_ECX,     1, sr_inc_ECX,     sr_inc_pre_ECX, cs_wr_to_both_n)
    `OR_3 (or_inc_ECX,         1, inc_ECX,        dr_inc_ECX, sr_inc_ECX, 1'b0)
    `AND_2(and_wb0_dec_ECX,     1, wb0_dec_ECX,     wb_dr0_we, match_wb0_ECX)
    `AND_2(and_wb1_dec_pre_ECX, 1, wb1_dec_pre_ECX, wb_dr1_we, match_wb1_ECX)
    `AND_2(and_wb1_dec_ECX,     1, wb1_dec_ECX,     wb1_dec_pre_ECX, wb_wr_to_both_n)
    `OR_2 (or_dec_ECX,          1, dec_ECX,         wb0_dec_ECX, wb1_dec_ECX)
    assign inc_8b_ECX[7:1] = 7'b0;
    assign inc_8b_ECX[0]   = inc_ECX;
    `MUX_2(mux_decneg_ECX, 8, dec_neg_8b_ECX, 8'h00, 8'hFF, dec_ECX)
    `ADD_N(add_inc_ECX,  8, counter_plus_inc_ECX, cout_inc_ECX,  counter_ECX,          inc_8b_ECX,     1'b0)
    `ADD_N(add_next_ECX, 8, counter_next_ECX,     cout_next_ECX, counter_plus_inc_ECX, dec_neg_8b_ECX, 1'b0)
    `REG_RST_WE(REG_ECX, 8, clk, combined_rst_n, 1'b1, counter_next_ECX, counter_ECX)

    // ----- EDX  (ID 10) -----
    wire match_dr_EDX, match_sr_EDX, match_wb0_EDX, match_wb1_EDX;
    wire dr_inc_EDX, sr_inc_pre_EDX, sr_inc_EDX, inc_EDX;
    wire wb0_dec_EDX, wb1_dec_pre_EDX, wb1_dec_EDX, dec_EDX;
    wire [7:0] counter_EDX, inc_8b_EDX, dec_neg_8b_EDX;
    wire [7:0] counter_plus_inc_EDX, counter_next_EDX;
    wire cout_inc_EDX, cout_next_EDX;
    `CMP_N(cmp_dr_EDX,  5, match_dr_EDX,  dr_id,     5'd10)
    `CMP_N(cmp_sr_EDX,  5, match_sr_EDX,  sr_id,     5'd10)
    `CMP_N(cmp_wb0_EDX, 5, match_wb0_EDX, wb_dr0_id, 5'd10)
    `CMP_N(cmp_wb1_EDX, 5, match_wb1_EDX, wb_dr1_id, 5'd10)
    `AND_3(and_dr_inc_EDX,     1, dr_inc_EDX,     updateSB, cs_dr_wr, match_dr_EDX)
    `AND_3(and_sr_inc_pre_EDX, 1, sr_inc_pre_EDX, updateSB, cs_sr_wr, match_sr_EDX)
    `AND_2(and_sr_inc_EDX,     1, sr_inc_EDX,     sr_inc_pre_EDX, cs_wr_to_both_n)
    `OR_3 (or_inc_EDX,         1, inc_EDX,        dr_inc_EDX, sr_inc_EDX, 1'b0)
    `AND_2(and_wb0_dec_EDX,     1, wb0_dec_EDX,     wb_dr0_we, match_wb0_EDX)
    `AND_2(and_wb1_dec_pre_EDX, 1, wb1_dec_pre_EDX, wb_dr1_we, match_wb1_EDX)
    `AND_2(and_wb1_dec_EDX,     1, wb1_dec_EDX,     wb1_dec_pre_EDX, wb_wr_to_both_n)
    `OR_2 (or_dec_EDX,          1, dec_EDX,         wb0_dec_EDX, wb1_dec_EDX)
    assign inc_8b_EDX[7:1] = 7'b0;
    assign inc_8b_EDX[0]   = inc_EDX;
    `MUX_2(mux_decneg_EDX, 8, dec_neg_8b_EDX, 8'h00, 8'hFF, dec_EDX)
    `ADD_N(add_inc_EDX,  8, counter_plus_inc_EDX, cout_inc_EDX,  counter_EDX,          inc_8b_EDX,     1'b0)
    `ADD_N(add_next_EDX, 8, counter_next_EDX,     cout_next_EDX, counter_plus_inc_EDX, dec_neg_8b_EDX, 1'b0)
    `REG_RST_WE(REG_EDX, 8, clk, combined_rst_n, 1'b1, counter_next_EDX, counter_EDX)

    // ----- ESI  (ID 11) -----
    wire match_dr_ESI, match_sr_ESI, match_wb0_ESI, match_wb1_ESI;
    wire dr_inc_ESI, sr_inc_pre_ESI, sr_inc_ESI, inc_ESI;
    wire wb0_dec_ESI, wb1_dec_pre_ESI, wb1_dec_ESI, dec_ESI;
    wire [7:0] counter_ESI, inc_8b_ESI, dec_neg_8b_ESI;
    wire [7:0] counter_plus_inc_ESI, counter_next_ESI;
    wire cout_inc_ESI, cout_next_ESI;
    `CMP_N(cmp_dr_ESI,  5, match_dr_ESI,  dr_id,     5'd11)
    `CMP_N(cmp_sr_ESI,  5, match_sr_ESI,  sr_id,     5'd11)
    `CMP_N(cmp_wb0_ESI, 5, match_wb0_ESI, wb_dr0_id, 5'd11)
    `CMP_N(cmp_wb1_ESI, 5, match_wb1_ESI, wb_dr1_id, 5'd11)
    `AND_3(and_dr_inc_ESI,     1, dr_inc_ESI,     updateSB, cs_dr_wr, match_dr_ESI)
    `AND_3(and_sr_inc_pre_ESI, 1, sr_inc_pre_ESI, updateSB, cs_sr_wr, match_sr_ESI)
    `AND_2(and_sr_inc_ESI,     1, sr_inc_ESI,     sr_inc_pre_ESI, cs_wr_to_both_n)
    `OR_3 (or_inc_ESI,         1, inc_ESI,        dr_inc_ESI, sr_inc_ESI, 1'b0)
    `AND_2(and_wb0_dec_ESI,     1, wb0_dec_ESI,     wb_dr0_we, match_wb0_ESI)
    `AND_2(and_wb1_dec_pre_ESI, 1, wb1_dec_pre_ESI, wb_dr1_we, match_wb1_ESI)
    `AND_2(and_wb1_dec_ESI,     1, wb1_dec_ESI,     wb1_dec_pre_ESI, wb_wr_to_both_n)
    `OR_2 (or_dec_ESI,          1, dec_ESI,         wb0_dec_ESI, wb1_dec_ESI)
    assign inc_8b_ESI[7:1] = 7'b0;
    assign inc_8b_ESI[0]   = inc_ESI;
    `MUX_2(mux_decneg_ESI, 8, dec_neg_8b_ESI, 8'h00, 8'hFF, dec_ESI)
    `ADD_N(add_inc_ESI,  8, counter_plus_inc_ESI, cout_inc_ESI,  counter_ESI,          inc_8b_ESI,     1'b0)
    `ADD_N(add_next_ESI, 8, counter_next_ESI,     cout_next_ESI, counter_plus_inc_ESI, dec_neg_8b_ESI, 1'b0)
    `REG_RST_WE(REG_ESI, 8, clk, combined_rst_n, 1'b1, counter_next_ESI, counter_ESI)

    // ----- EDI  (ID 12) -----
    wire match_dr_EDI, match_sr_EDI, match_wb0_EDI, match_wb1_EDI;
    wire dr_inc_EDI, sr_inc_pre_EDI, sr_inc_EDI, inc_EDI;
    wire wb0_dec_EDI, wb1_dec_pre_EDI, wb1_dec_EDI, dec_EDI;
    wire [7:0] counter_EDI, inc_8b_EDI, dec_neg_8b_EDI;
    wire [7:0] counter_plus_inc_EDI, counter_next_EDI;
    wire cout_inc_EDI, cout_next_EDI;
    `CMP_N(cmp_dr_EDI,  5, match_dr_EDI,  dr_id,     5'd12)
    `CMP_N(cmp_sr_EDI,  5, match_sr_EDI,  sr_id,     5'd12)
    `CMP_N(cmp_wb0_EDI, 5, match_wb0_EDI, wb_dr0_id, 5'd12)
    `CMP_N(cmp_wb1_EDI, 5, match_wb1_EDI, wb_dr1_id, 5'd12)
    `AND_3(and_dr_inc_EDI,     1, dr_inc_EDI,     updateSB, cs_dr_wr, match_dr_EDI)
    `AND_3(and_sr_inc_pre_EDI, 1, sr_inc_pre_EDI, updateSB, cs_sr_wr, match_sr_EDI)
    `AND_2(and_sr_inc_EDI,     1, sr_inc_EDI,     sr_inc_pre_EDI, cs_wr_to_both_n)
    `OR_3 (or_inc_EDI,         1, inc_EDI,        dr_inc_EDI, sr_inc_EDI, 1'b0)
    `AND_2(and_wb0_dec_EDI,     1, wb0_dec_EDI,     wb_dr0_we, match_wb0_EDI)
    `AND_2(and_wb1_dec_pre_EDI, 1, wb1_dec_pre_EDI, wb_dr1_we, match_wb1_EDI)
    `AND_2(and_wb1_dec_EDI,     1, wb1_dec_EDI,     wb1_dec_pre_EDI, wb_wr_to_both_n)
    `OR_2 (or_dec_EDI,          1, dec_EDI,         wb0_dec_EDI, wb1_dec_EDI)
    assign inc_8b_EDI[7:1] = 7'b0;
    assign inc_8b_EDI[0]   = inc_EDI;
    `MUX_2(mux_decneg_EDI, 8, dec_neg_8b_EDI, 8'h00, 8'hFF, dec_EDI)
    `ADD_N(add_inc_EDI,  8, counter_plus_inc_EDI, cout_inc_EDI,  counter_EDI,          inc_8b_EDI,     1'b0)
    `ADD_N(add_next_EDI, 8, counter_next_EDI,     cout_next_EDI, counter_plus_inc_EDI, dec_neg_8b_EDI, 1'b0)
    `REG_RST_WE(REG_EDI, 8, clk, combined_rst_n, 1'b1, counter_next_EDI, counter_EDI)

    // ----- ESP  (ID 13) -----
    wire match_dr_ESP, match_sr_ESP, match_wb0_ESP, match_wb1_ESP;
    wire dr_inc_ESP, sr_inc_pre_ESP, sr_inc_ESP, inc_ESP;
    wire wb0_dec_ESP, wb1_dec_pre_ESP, wb1_dec_ESP, dec_ESP;
    wire [7:0] counter_ESP, inc_8b_ESP, dec_neg_8b_ESP;
    wire [7:0] counter_plus_inc_ESP, counter_next_ESP;
    wire cout_inc_ESP, cout_next_ESP;
    `CMP_N(cmp_dr_ESP,  5, match_dr_ESP,  dr_id,     5'd13)
    `CMP_N(cmp_sr_ESP,  5, match_sr_ESP,  sr_id,     5'd13)
    `CMP_N(cmp_wb0_ESP, 5, match_wb0_ESP, wb_dr0_id, 5'd13)
    `CMP_N(cmp_wb1_ESP, 5, match_wb1_ESP, wb_dr1_id, 5'd13)
    `AND_3(and_dr_inc_ESP,     1, dr_inc_ESP,     updateSB, cs_dr_wr, match_dr_ESP)
    `AND_3(and_sr_inc_pre_ESP, 1, sr_inc_pre_ESP, updateSB, cs_sr_wr, match_sr_ESP)
    `AND_2(and_sr_inc_ESP,     1, sr_inc_ESP,     sr_inc_pre_ESP, cs_wr_to_both_n)
    `OR_3 (or_inc_ESP,         1, inc_ESP,        dr_inc_ESP, sr_inc_ESP, 1'b0)
    `AND_2(and_wb0_dec_ESP,     1, wb0_dec_ESP,     wb_dr0_we, match_wb0_ESP)
    `AND_2(and_wb1_dec_pre_ESP, 1, wb1_dec_pre_ESP, wb_dr1_we, match_wb1_ESP)
    `AND_2(and_wb1_dec_ESP,     1, wb1_dec_ESP,     wb1_dec_pre_ESP, wb_wr_to_both_n)
    `OR_2 (or_dec_ESP,          1, dec_ESP,         wb0_dec_ESP, wb1_dec_ESP)
    assign inc_8b_ESP[7:1] = 7'b0;
    assign inc_8b_ESP[0]   = inc_ESP;
    `MUX_2(mux_decneg_ESP, 8, dec_neg_8b_ESP, 8'h00, 8'hFF, dec_ESP)
    `ADD_N(add_inc_ESP,  8, counter_plus_inc_ESP, cout_inc_ESP,  counter_ESP,          inc_8b_ESP,     1'b0)
    `ADD_N(add_next_ESP, 8, counter_next_ESP,     cout_next_ESP, counter_plus_inc_ESP, dec_neg_8b_ESP, 1'b0)
    `REG_RST_WE(REG_ESP, 8, clk, combined_rst_n, 1'b1, counter_next_ESP, counter_ESP)

    // ----- EBP  (ID 14) -----
    wire match_dr_EBP, match_sr_EBP, match_wb0_EBP, match_wb1_EBP;
    wire dr_inc_EBP, sr_inc_pre_EBP, sr_inc_EBP, inc_EBP;
    wire wb0_dec_EBP, wb1_dec_pre_EBP, wb1_dec_EBP, dec_EBP;
    wire [7:0] counter_EBP, inc_8b_EBP, dec_neg_8b_EBP;
    wire [7:0] counter_plus_inc_EBP, counter_next_EBP;
    wire cout_inc_EBP, cout_next_EBP;
    `CMP_N(cmp_dr_EBP,  5, match_dr_EBP,  dr_id,     5'd14)
    `CMP_N(cmp_sr_EBP,  5, match_sr_EBP,  sr_id,     5'd14)
    `CMP_N(cmp_wb0_EBP, 5, match_wb0_EBP, wb_dr0_id, 5'd14)
    `CMP_N(cmp_wb1_EBP, 5, match_wb1_EBP, wb_dr1_id, 5'd14)
    `AND_3(and_dr_inc_EBP,     1, dr_inc_EBP,     updateSB, cs_dr_wr, match_dr_EBP)
    `AND_3(and_sr_inc_pre_EBP, 1, sr_inc_pre_EBP, updateSB, cs_sr_wr, match_sr_EBP)
    `AND_2(and_sr_inc_EBP,     1, sr_inc_EBP,     sr_inc_pre_EBP, cs_wr_to_both_n)
    `OR_3 (or_inc_EBP,         1, inc_EBP,        dr_inc_EBP, sr_inc_EBP, 1'b0)
    `AND_2(and_wb0_dec_EBP,     1, wb0_dec_EBP,     wb_dr0_we, match_wb0_EBP)
    `AND_2(and_wb1_dec_pre_EBP, 1, wb1_dec_pre_EBP, wb_dr1_we, match_wb1_EBP)
    `AND_2(and_wb1_dec_EBP,     1, wb1_dec_EBP,     wb1_dec_pre_EBP, wb_wr_to_both_n)
    `OR_2 (or_dec_EBP,          1, dec_EBP,         wb0_dec_EBP, wb1_dec_EBP)
    assign inc_8b_EBP[7:1] = 7'b0;
    assign inc_8b_EBP[0]   = inc_EBP;
    `MUX_2(mux_decneg_EBP, 8, dec_neg_8b_EBP, 8'h00, 8'hFF, dec_EBP)
    `ADD_N(add_inc_EBP,  8, counter_plus_inc_EBP, cout_inc_EBP,  counter_EBP,          inc_8b_EBP,     1'b0)
    `ADD_N(add_next_EBP, 8, counter_next_EBP,     cout_next_EBP, counter_plus_inc_EBP, dec_neg_8b_EBP, 1'b0)
    `REG_RST_WE(REG_EBP, 8, clk, combined_rst_n, 1'b1, counter_next_EBP, counter_EBP)

    // ----- MM0  (ID 15) -----
    wire match_dr_MM0, match_sr_MM0, match_wb0_MM0, match_wb1_MM0;
    wire dr_inc_MM0, sr_inc_pre_MM0, sr_inc_MM0, inc_MM0;
    wire wb0_dec_MM0, wb1_dec_pre_MM0, wb1_dec_MM0, dec_MM0;
    wire [7:0] counter_MM0, inc_8b_MM0, dec_neg_8b_MM0;
    wire [7:0] counter_plus_inc_MM0, counter_next_MM0;
    wire cout_inc_MM0, cout_next_MM0;
    `CMP_N(cmp_dr_MM0,  5, match_dr_MM0,  dr_id,     5'd15)
    `CMP_N(cmp_sr_MM0,  5, match_sr_MM0,  sr_id,     5'd15)
    `CMP_N(cmp_wb0_MM0, 5, match_wb0_MM0, wb_dr0_id, 5'd15)
    `CMP_N(cmp_wb1_MM0, 5, match_wb1_MM0, wb_dr1_id, 5'd15)
    `AND_3(and_dr_inc_MM0,     1, dr_inc_MM0,     updateSB, cs_dr_wr, match_dr_MM0)
    `AND_3(and_sr_inc_pre_MM0, 1, sr_inc_pre_MM0, updateSB, cs_sr_wr, match_sr_MM0)
    `AND_2(and_sr_inc_MM0,     1, sr_inc_MM0,     sr_inc_pre_MM0, cs_wr_to_both_n)
    `OR_3 (or_inc_MM0,         1, inc_MM0,        dr_inc_MM0, sr_inc_MM0, 1'b0)
    `AND_2(and_wb0_dec_MM0,     1, wb0_dec_MM0,     wb_dr0_we, match_wb0_MM0)
    `AND_2(and_wb1_dec_pre_MM0, 1, wb1_dec_pre_MM0, wb_dr1_we, match_wb1_MM0)
    `AND_2(and_wb1_dec_MM0,     1, wb1_dec_MM0,     wb1_dec_pre_MM0, wb_wr_to_both_n)
    `OR_2 (or_dec_MM0,          1, dec_MM0,         wb0_dec_MM0, wb1_dec_MM0)
    assign inc_8b_MM0[7:1] = 7'b0;
    assign inc_8b_MM0[0]   = inc_MM0;
    `MUX_2(mux_decneg_MM0, 8, dec_neg_8b_MM0, 8'h00, 8'hFF, dec_MM0)
    `ADD_N(add_inc_MM0,  8, counter_plus_inc_MM0, cout_inc_MM0,  counter_MM0,          inc_8b_MM0,     1'b0)
    `ADD_N(add_next_MM0, 8, counter_next_MM0,     cout_next_MM0, counter_plus_inc_MM0, dec_neg_8b_MM0, 1'b0)
    `REG_RST_WE(REG_MM0, 8, clk, combined_rst_n, 1'b1, counter_next_MM0, counter_MM0)

    // ----- MM1  (ID 16) -----
    wire match_dr_MM1, match_sr_MM1, match_wb0_MM1, match_wb1_MM1;
    wire dr_inc_MM1, sr_inc_pre_MM1, sr_inc_MM1, inc_MM1;
    wire wb0_dec_MM1, wb1_dec_pre_MM1, wb1_dec_MM1, dec_MM1;
    wire [7:0] counter_MM1, inc_8b_MM1, dec_neg_8b_MM1;
    wire [7:0] counter_plus_inc_MM1, counter_next_MM1;
    wire cout_inc_MM1, cout_next_MM1;
    `CMP_N(cmp_dr_MM1,  5, match_dr_MM1,  dr_id,     5'd16)
    `CMP_N(cmp_sr_MM1,  5, match_sr_MM1,  sr_id,     5'd16)
    `CMP_N(cmp_wb0_MM1, 5, match_wb0_MM1, wb_dr0_id, 5'd16)
    `CMP_N(cmp_wb1_MM1, 5, match_wb1_MM1, wb_dr1_id, 5'd16)
    `AND_3(and_dr_inc_MM1,     1, dr_inc_MM1,     updateSB, cs_dr_wr, match_dr_MM1)
    `AND_3(and_sr_inc_pre_MM1, 1, sr_inc_pre_MM1, updateSB, cs_sr_wr, match_sr_MM1)
    `AND_2(and_sr_inc_MM1,     1, sr_inc_MM1,     sr_inc_pre_MM1, cs_wr_to_both_n)
    `OR_3 (or_inc_MM1,         1, inc_MM1,        dr_inc_MM1, sr_inc_MM1, 1'b0)
    `AND_2(and_wb0_dec_MM1,     1, wb0_dec_MM1,     wb_dr0_we, match_wb0_MM1)
    `AND_2(and_wb1_dec_pre_MM1, 1, wb1_dec_pre_MM1, wb_dr1_we, match_wb1_MM1)
    `AND_2(and_wb1_dec_MM1,     1, wb1_dec_MM1,     wb1_dec_pre_MM1, wb_wr_to_both_n)
    `OR_2 (or_dec_MM1,          1, dec_MM1,         wb0_dec_MM1, wb1_dec_MM1)
    assign inc_8b_MM1[7:1] = 7'b0;
    assign inc_8b_MM1[0]   = inc_MM1;
    `MUX_2(mux_decneg_MM1, 8, dec_neg_8b_MM1, 8'h00, 8'hFF, dec_MM1)
    `ADD_N(add_inc_MM1,  8, counter_plus_inc_MM1, cout_inc_MM1,  counter_MM1,          inc_8b_MM1,     1'b0)
    `ADD_N(add_next_MM1, 8, counter_next_MM1,     cout_next_MM1, counter_plus_inc_MM1, dec_neg_8b_MM1, 1'b0)
    `REG_RST_WE(REG_MM1, 8, clk, combined_rst_n, 1'b1, counter_next_MM1, counter_MM1)

    // ----- MM2  (ID 17) -----
    wire match_dr_MM2, match_sr_MM2, match_wb0_MM2, match_wb1_MM2;
    wire dr_inc_MM2, sr_inc_pre_MM2, sr_inc_MM2, inc_MM2;
    wire wb0_dec_MM2, wb1_dec_pre_MM2, wb1_dec_MM2, dec_MM2;
    wire [7:0] counter_MM2, inc_8b_MM2, dec_neg_8b_MM2;
    wire [7:0] counter_plus_inc_MM2, counter_next_MM2;
    wire cout_inc_MM2, cout_next_MM2;
    `CMP_N(cmp_dr_MM2,  5, match_dr_MM2,  dr_id,     5'd17)
    `CMP_N(cmp_sr_MM2,  5, match_sr_MM2,  sr_id,     5'd17)
    `CMP_N(cmp_wb0_MM2, 5, match_wb0_MM2, wb_dr0_id, 5'd17)
    `CMP_N(cmp_wb1_MM2, 5, match_wb1_MM2, wb_dr1_id, 5'd17)
    `AND_3(and_dr_inc_MM2,     1, dr_inc_MM2,     updateSB, cs_dr_wr, match_dr_MM2)
    `AND_3(and_sr_inc_pre_MM2, 1, sr_inc_pre_MM2, updateSB, cs_sr_wr, match_sr_MM2)
    `AND_2(and_sr_inc_MM2,     1, sr_inc_MM2,     sr_inc_pre_MM2, cs_wr_to_both_n)
    `OR_3 (or_inc_MM2,         1, inc_MM2,        dr_inc_MM2, sr_inc_MM2, 1'b0)
    `AND_2(and_wb0_dec_MM2,     1, wb0_dec_MM2,     wb_dr0_we, match_wb0_MM2)
    `AND_2(and_wb1_dec_pre_MM2, 1, wb1_dec_pre_MM2, wb_dr1_we, match_wb1_MM2)
    `AND_2(and_wb1_dec_MM2,     1, wb1_dec_MM2,     wb1_dec_pre_MM2, wb_wr_to_both_n)
    `OR_2 (or_dec_MM2,          1, dec_MM2,         wb0_dec_MM2, wb1_dec_MM2)
    assign inc_8b_MM2[7:1] = 7'b0;
    assign inc_8b_MM2[0]   = inc_MM2;
    `MUX_2(mux_decneg_MM2, 8, dec_neg_8b_MM2, 8'h00, 8'hFF, dec_MM2)
    `ADD_N(add_inc_MM2,  8, counter_plus_inc_MM2, cout_inc_MM2,  counter_MM2,          inc_8b_MM2,     1'b0)
    `ADD_N(add_next_MM2, 8, counter_next_MM2,     cout_next_MM2, counter_plus_inc_MM2, dec_neg_8b_MM2, 1'b0)
    `REG_RST_WE(REG_MM2, 8, clk, combined_rst_n, 1'b1, counter_next_MM2, counter_MM2)

    // ----- MM3  (ID 18) -----
    wire match_dr_MM3, match_sr_MM3, match_wb0_MM3, match_wb1_MM3;
    wire dr_inc_MM3, sr_inc_pre_MM3, sr_inc_MM3, inc_MM3;
    wire wb0_dec_MM3, wb1_dec_pre_MM3, wb1_dec_MM3, dec_MM3;
    wire [7:0] counter_MM3, inc_8b_MM3, dec_neg_8b_MM3;
    wire [7:0] counter_plus_inc_MM3, counter_next_MM3;
    wire cout_inc_MM3, cout_next_MM3;
    `CMP_N(cmp_dr_MM3,  5, match_dr_MM3,  dr_id,     5'd18)
    `CMP_N(cmp_sr_MM3,  5, match_sr_MM3,  sr_id,     5'd18)
    `CMP_N(cmp_wb0_MM3, 5, match_wb0_MM3, wb_dr0_id, 5'd18)
    `CMP_N(cmp_wb1_MM3, 5, match_wb1_MM3, wb_dr1_id, 5'd18)
    `AND_3(and_dr_inc_MM3,     1, dr_inc_MM3,     updateSB, cs_dr_wr, match_dr_MM3)
    `AND_3(and_sr_inc_pre_MM3, 1, sr_inc_pre_MM3, updateSB, cs_sr_wr, match_sr_MM3)
    `AND_2(and_sr_inc_MM3,     1, sr_inc_MM3,     sr_inc_pre_MM3, cs_wr_to_both_n)
    `OR_3 (or_inc_MM3,         1, inc_MM3,        dr_inc_MM3, sr_inc_MM3, 1'b0)
    `AND_2(and_wb0_dec_MM3,     1, wb0_dec_MM3,     wb_dr0_we, match_wb0_MM3)
    `AND_2(and_wb1_dec_pre_MM3, 1, wb1_dec_pre_MM3, wb_dr1_we, match_wb1_MM3)
    `AND_2(and_wb1_dec_MM3,     1, wb1_dec_MM3,     wb1_dec_pre_MM3, wb_wr_to_both_n)
    `OR_2 (or_dec_MM3,          1, dec_MM3,         wb0_dec_MM3, wb1_dec_MM3)
    assign inc_8b_MM3[7:1] = 7'b0;
    assign inc_8b_MM3[0]   = inc_MM3;
    `MUX_2(mux_decneg_MM3, 8, dec_neg_8b_MM3, 8'h00, 8'hFF, dec_MM3)
    `ADD_N(add_inc_MM3,  8, counter_plus_inc_MM3, cout_inc_MM3,  counter_MM3,          inc_8b_MM3,     1'b0)
    `ADD_N(add_next_MM3, 8, counter_next_MM3,     cout_next_MM3, counter_plus_inc_MM3, dec_neg_8b_MM3, 1'b0)
    `REG_RST_WE(REG_MM3, 8, clk, combined_rst_n, 1'b1, counter_next_MM3, counter_MM3)

    // ----- MM4  (ID 19) -----
    wire match_dr_MM4, match_sr_MM4, match_wb0_MM4, match_wb1_MM4;
    wire dr_inc_MM4, sr_inc_pre_MM4, sr_inc_MM4, inc_MM4;
    wire wb0_dec_MM4, wb1_dec_pre_MM4, wb1_dec_MM4, dec_MM4;
    wire [7:0] counter_MM4, inc_8b_MM4, dec_neg_8b_MM4;
    wire [7:0] counter_plus_inc_MM4, counter_next_MM4;
    wire cout_inc_MM4, cout_next_MM4;
    `CMP_N(cmp_dr_MM4,  5, match_dr_MM4,  dr_id,     5'd19)
    `CMP_N(cmp_sr_MM4,  5, match_sr_MM4,  sr_id,     5'd19)
    `CMP_N(cmp_wb0_MM4, 5, match_wb0_MM4, wb_dr0_id, 5'd19)
    `CMP_N(cmp_wb1_MM4, 5, match_wb1_MM4, wb_dr1_id, 5'd19)
    `AND_3(and_dr_inc_MM4,     1, dr_inc_MM4,     updateSB, cs_dr_wr, match_dr_MM4)
    `AND_3(and_sr_inc_pre_MM4, 1, sr_inc_pre_MM4, updateSB, cs_sr_wr, match_sr_MM4)
    `AND_2(and_sr_inc_MM4,     1, sr_inc_MM4,     sr_inc_pre_MM4, cs_wr_to_both_n)
    `OR_3 (or_inc_MM4,         1, inc_MM4,        dr_inc_MM4, sr_inc_MM4, 1'b0)
    `AND_2(and_wb0_dec_MM4,     1, wb0_dec_MM4,     wb_dr0_we, match_wb0_MM4)
    `AND_2(and_wb1_dec_pre_MM4, 1, wb1_dec_pre_MM4, wb_dr1_we, match_wb1_MM4)
    `AND_2(and_wb1_dec_MM4,     1, wb1_dec_MM4,     wb1_dec_pre_MM4, wb_wr_to_both_n)
    `OR_2 (or_dec_MM4,          1, dec_MM4,         wb0_dec_MM4, wb1_dec_MM4)
    assign inc_8b_MM4[7:1] = 7'b0;
    assign inc_8b_MM4[0]   = inc_MM4;
    `MUX_2(mux_decneg_MM4, 8, dec_neg_8b_MM4, 8'h00, 8'hFF, dec_MM4)
    `ADD_N(add_inc_MM4,  8, counter_plus_inc_MM4, cout_inc_MM4,  counter_MM4,          inc_8b_MM4,     1'b0)
    `ADD_N(add_next_MM4, 8, counter_next_MM4,     cout_next_MM4, counter_plus_inc_MM4, dec_neg_8b_MM4, 1'b0)
    `REG_RST_WE(REG_MM4, 8, clk, combined_rst_n, 1'b1, counter_next_MM4, counter_MM4)

    // ----- MM5  (ID 20) -----
    wire match_dr_MM5, match_sr_MM5, match_wb0_MM5, match_wb1_MM5;
    wire dr_inc_MM5, sr_inc_pre_MM5, sr_inc_MM5, inc_MM5;
    wire wb0_dec_MM5, wb1_dec_pre_MM5, wb1_dec_MM5, dec_MM5;
    wire [7:0] counter_MM5, inc_8b_MM5, dec_neg_8b_MM5;
    wire [7:0] counter_plus_inc_MM5, counter_next_MM5;
    wire cout_inc_MM5, cout_next_MM5;
    `CMP_N(cmp_dr_MM5,  5, match_dr_MM5,  dr_id,     5'd20)
    `CMP_N(cmp_sr_MM5,  5, match_sr_MM5,  sr_id,     5'd20)
    `CMP_N(cmp_wb0_MM5, 5, match_wb0_MM5, wb_dr0_id, 5'd20)
    `CMP_N(cmp_wb1_MM5, 5, match_wb1_MM5, wb_dr1_id, 5'd20)
    `AND_3(and_dr_inc_MM5,     1, dr_inc_MM5,     updateSB, cs_dr_wr, match_dr_MM5)
    `AND_3(and_sr_inc_pre_MM5, 1, sr_inc_pre_MM5, updateSB, cs_sr_wr, match_sr_MM5)
    `AND_2(and_sr_inc_MM5,     1, sr_inc_MM5,     sr_inc_pre_MM5, cs_wr_to_both_n)
    `OR_3 (or_inc_MM5,         1, inc_MM5,        dr_inc_MM5, sr_inc_MM5, 1'b0)
    `AND_2(and_wb0_dec_MM5,     1, wb0_dec_MM5,     wb_dr0_we, match_wb0_MM5)
    `AND_2(and_wb1_dec_pre_MM5, 1, wb1_dec_pre_MM5, wb_dr1_we, match_wb1_MM5)
    `AND_2(and_wb1_dec_MM5,     1, wb1_dec_MM5,     wb1_dec_pre_MM5, wb_wr_to_both_n)
    `OR_2 (or_dec_MM5,          1, dec_MM5,         wb0_dec_MM5, wb1_dec_MM5)
    assign inc_8b_MM5[7:1] = 7'b0;
    assign inc_8b_MM5[0]   = inc_MM5;
    `MUX_2(mux_decneg_MM5, 8, dec_neg_8b_MM5, 8'h00, 8'hFF, dec_MM5)
    `ADD_N(add_inc_MM5,  8, counter_plus_inc_MM5, cout_inc_MM5,  counter_MM5,          inc_8b_MM5,     1'b0)
    `ADD_N(add_next_MM5, 8, counter_next_MM5,     cout_next_MM5, counter_plus_inc_MM5, dec_neg_8b_MM5, 1'b0)
    `REG_RST_WE(REG_MM5, 8, clk, combined_rst_n, 1'b1, counter_next_MM5, counter_MM5)

    // ----- MM6  (ID 21) -----
    wire match_dr_MM6, match_sr_MM6, match_wb0_MM6, match_wb1_MM6;
    wire dr_inc_MM6, sr_inc_pre_MM6, sr_inc_MM6, inc_MM6;
    wire wb0_dec_MM6, wb1_dec_pre_MM6, wb1_dec_MM6, dec_MM6;
    wire [7:0] counter_MM6, inc_8b_MM6, dec_neg_8b_MM6;
    wire [7:0] counter_plus_inc_MM6, counter_next_MM6;
    wire cout_inc_MM6, cout_next_MM6;
    `CMP_N(cmp_dr_MM6,  5, match_dr_MM6,  dr_id,     5'd21)
    `CMP_N(cmp_sr_MM6,  5, match_sr_MM6,  sr_id,     5'd21)
    `CMP_N(cmp_wb0_MM6, 5, match_wb0_MM6, wb_dr0_id, 5'd21)
    `CMP_N(cmp_wb1_MM6, 5, match_wb1_MM6, wb_dr1_id, 5'd21)
    `AND_3(and_dr_inc_MM6,     1, dr_inc_MM6,     updateSB, cs_dr_wr, match_dr_MM6)
    `AND_3(and_sr_inc_pre_MM6, 1, sr_inc_pre_MM6, updateSB, cs_sr_wr, match_sr_MM6)
    `AND_2(and_sr_inc_MM6,     1, sr_inc_MM6,     sr_inc_pre_MM6, cs_wr_to_both_n)
    `OR_3 (or_inc_MM6,         1, inc_MM6,        dr_inc_MM6, sr_inc_MM6, 1'b0)
    `AND_2(and_wb0_dec_MM6,     1, wb0_dec_MM6,     wb_dr0_we, match_wb0_MM6)
    `AND_2(and_wb1_dec_pre_MM6, 1, wb1_dec_pre_MM6, wb_dr1_we, match_wb1_MM6)
    `AND_2(and_wb1_dec_MM6,     1, wb1_dec_MM6,     wb1_dec_pre_MM6, wb_wr_to_both_n)
    `OR_2 (or_dec_MM6,          1, dec_MM6,         wb0_dec_MM6, wb1_dec_MM6)
    assign inc_8b_MM6[7:1] = 7'b0;
    assign inc_8b_MM6[0]   = inc_MM6;
    `MUX_2(mux_decneg_MM6, 8, dec_neg_8b_MM6, 8'h00, 8'hFF, dec_MM6)
    `ADD_N(add_inc_MM6,  8, counter_plus_inc_MM6, cout_inc_MM6,  counter_MM6,          inc_8b_MM6,     1'b0)
    `ADD_N(add_next_MM6, 8, counter_next_MM6,     cout_next_MM6, counter_plus_inc_MM6, dec_neg_8b_MM6, 1'b0)
    `REG_RST_WE(REG_MM6, 8, clk, combined_rst_n, 1'b1, counter_next_MM6, counter_MM6)

    // ----- MM7  (ID 22) -----
    wire match_dr_MM7, match_sr_MM7, match_wb0_MM7, match_wb1_MM7;
    wire dr_inc_MM7, sr_inc_pre_MM7, sr_inc_MM7, inc_MM7;
    wire wb0_dec_MM7, wb1_dec_pre_MM7, wb1_dec_MM7, dec_MM7;
    wire [7:0] counter_MM7, inc_8b_MM7, dec_neg_8b_MM7;
    wire [7:0] counter_plus_inc_MM7, counter_next_MM7;
    wire cout_inc_MM7, cout_next_MM7;
    `CMP_N(cmp_dr_MM7,  5, match_dr_MM7,  dr_id,     5'd22)
    `CMP_N(cmp_sr_MM7,  5, match_sr_MM7,  sr_id,     5'd22)
    `CMP_N(cmp_wb0_MM7, 5, match_wb0_MM7, wb_dr0_id, 5'd22)
    `CMP_N(cmp_wb1_MM7, 5, match_wb1_MM7, wb_dr1_id, 5'd22)
    `AND_3(and_dr_inc_MM7,     1, dr_inc_MM7,     updateSB, cs_dr_wr, match_dr_MM7)
    `AND_3(and_sr_inc_pre_MM7, 1, sr_inc_pre_MM7, updateSB, cs_sr_wr, match_sr_MM7)
    `AND_2(and_sr_inc_MM7,     1, sr_inc_MM7,     sr_inc_pre_MM7, cs_wr_to_both_n)
    `OR_3 (or_inc_MM7,         1, inc_MM7,        dr_inc_MM7, sr_inc_MM7, 1'b0)
    `AND_2(and_wb0_dec_MM7,     1, wb0_dec_MM7,     wb_dr0_we, match_wb0_MM7)
    `AND_2(and_wb1_dec_pre_MM7, 1, wb1_dec_pre_MM7, wb_dr1_we, match_wb1_MM7)
    `AND_2(and_wb1_dec_MM7,     1, wb1_dec_MM7,     wb1_dec_pre_MM7, wb_wr_to_both_n)
    `OR_2 (or_dec_MM7,          1, dec_MM7,         wb0_dec_MM7, wb1_dec_MM7)
    assign inc_8b_MM7[7:1] = 7'b0;
    assign inc_8b_MM7[0]   = inc_MM7;
    `MUX_2(mux_decneg_MM7, 8, dec_neg_8b_MM7, 8'h00, 8'hFF, dec_MM7)
    `ADD_N(add_inc_MM7,  8, counter_plus_inc_MM7, cout_inc_MM7,  counter_MM7,          inc_8b_MM7,     1'b0)
    `ADD_N(add_next_MM7, 8, counter_next_MM7,     cout_next_MM7, counter_plus_inc_MM7, dec_neg_8b_MM7, 1'b0)
    `REG_RST_WE(REG_MM7, 8, clk, combined_rst_n, 1'b1, counter_next_MM7, counter_MM7)

    // ----- ETR  (ID 23) -----
    wire match_dr_ETR, match_sr_ETR, match_wb0_ETR, match_wb1_ETR;
    wire dr_inc_ETR, sr_inc_pre_ETR, sr_inc_ETR, inc_ETR;
    wire wb0_dec_ETR, wb1_dec_pre_ETR, wb1_dec_ETR, dec_ETR;
    wire [7:0] counter_ETR, inc_8b_ETR, dec_neg_8b_ETR;
    wire [7:0] counter_plus_inc_ETR, counter_next_ETR;
    wire cout_inc_ETR, cout_next_ETR;
    `CMP_N(cmp_dr_ETR,  5, match_dr_ETR,  dr_id,     5'd23)
    `CMP_N(cmp_sr_ETR,  5, match_sr_ETR,  sr_id,     5'd23)
    `CMP_N(cmp_wb0_ETR, 5, match_wb0_ETR, wb_dr0_id, 5'd23)
    `CMP_N(cmp_wb1_ETR, 5, match_wb1_ETR, wb_dr1_id, 5'd23)
    `AND_3(and_dr_inc_ETR,     1, dr_inc_ETR,     updateSB, cs_dr_wr, match_dr_ETR)
    `AND_3(and_sr_inc_pre_ETR, 1, sr_inc_pre_ETR, updateSB, cs_sr_wr, match_sr_ETR)
    `AND_2(and_sr_inc_ETR,     1, sr_inc_ETR,     sr_inc_pre_ETR, cs_wr_to_both_n)
    `OR_3 (or_inc_ETR,         1, inc_ETR,        dr_inc_ETR, sr_inc_ETR, 1'b0)
    `AND_2(and_wb0_dec_ETR,     1, wb0_dec_ETR,     wb_dr0_we, match_wb0_ETR)
    `AND_2(and_wb1_dec_pre_ETR, 1, wb1_dec_pre_ETR, wb_dr1_we, match_wb1_ETR)
    `AND_2(and_wb1_dec_ETR,     1, wb1_dec_ETR,     wb1_dec_pre_ETR, wb_wr_to_both_n)
    `OR_2 (or_dec_ETR,          1, dec_ETR,         wb0_dec_ETR, wb1_dec_ETR)
    assign inc_8b_ETR[7:1] = 7'b0;
    assign inc_8b_ETR[0]   = inc_ETR;
    `MUX_2(mux_decneg_ETR, 8, dec_neg_8b_ETR, 8'h00, 8'hFF, dec_ETR)
    `ADD_N(add_inc_ETR,  8, counter_plus_inc_ETR, cout_inc_ETR,  counter_ETR,          inc_8b_ETR,     1'b0)
    `ADD_N(add_next_ETR, 8, counter_next_ETR,     cout_next_ETR, counter_plus_inc_ETR, dec_neg_8b_ETR, 1'b0)
    `REG_RST_WE(REG_ETR, 8, clk, combined_rst_n, 1'b1, counter_next_ETR, counter_ETR)

    // ----- ERROR_REG  (ID 24) -----
    wire match_dr_ERROR_REG, match_sr_ERROR_REG, match_wb0_ERROR_REG, match_wb1_ERROR_REG;
    wire dr_inc_ERROR_REG, sr_inc_pre_ERROR_REG, sr_inc_ERROR_REG, inc_ERROR_REG;
    wire wb0_dec_ERROR_REG, wb1_dec_pre_ERROR_REG, wb1_dec_ERROR_REG, dec_ERROR_REG;
    wire [7:0] counter_ERROR_REG, inc_8b_ERROR_REG, dec_neg_8b_ERROR_REG;
    wire [7:0] counter_plus_inc_ERROR_REG, counter_next_ERROR_REG;
    wire cout_inc_ERROR_REG, cout_next_ERROR_REG;
    `CMP_N(cmp_dr_ERROR_REG,  5, match_dr_ERROR_REG,  dr_id,     5'd24)
    `CMP_N(cmp_sr_ERROR_REG,  5, match_sr_ERROR_REG,  sr_id,     5'd24)
    `CMP_N(cmp_wb0_ERROR_REG, 5, match_wb0_ERROR_REG, wb_dr0_id, 5'd24)
    `CMP_N(cmp_wb1_ERROR_REG, 5, match_wb1_ERROR_REG, wb_dr1_id, 5'd24)
    `AND_3(and_dr_inc_ERROR_REG,     1, dr_inc_ERROR_REG,     updateSB, cs_dr_wr, match_dr_ERROR_REG)
    `AND_3(and_sr_inc_pre_ERROR_REG, 1, sr_inc_pre_ERROR_REG, updateSB, cs_sr_wr, match_sr_ERROR_REG)
    `AND_2(and_sr_inc_ERROR_REG,     1, sr_inc_ERROR_REG,     sr_inc_pre_ERROR_REG, cs_wr_to_both_n)
    `OR_3 (or_inc_ERROR_REG,         1, inc_ERROR_REG,        dr_inc_ERROR_REG, sr_inc_ERROR_REG, 1'b0)
    `AND_2(and_wb0_dec_ERROR_REG,     1, wb0_dec_ERROR_REG,     wb_dr0_we, match_wb0_ERROR_REG)
    `AND_2(and_wb1_dec_pre_ERROR_REG, 1, wb1_dec_pre_ERROR_REG, wb_dr1_we, match_wb1_ERROR_REG)
    `AND_2(and_wb1_dec_ERROR_REG,     1, wb1_dec_ERROR_REG,     wb1_dec_pre_ERROR_REG, wb_wr_to_both_n)
    `OR_2 (or_dec_ERROR_REG,          1, dec_ERROR_REG,         wb0_dec_ERROR_REG, wb1_dec_ERROR_REG)
    assign inc_8b_ERROR_REG[7:1] = 7'b0;
    assign inc_8b_ERROR_REG[0]   = inc_ERROR_REG;
    `MUX_2(mux_decneg_ERROR_REG, 8, dec_neg_8b_ERROR_REG, 8'h00, 8'hFF, dec_ERROR_REG)
    `ADD_N(add_inc_ERROR_REG,  8, counter_plus_inc_ERROR_REG, cout_inc_ERROR_REG,  counter_ERROR_REG,          inc_8b_ERROR_REG,     1'b0)
    `ADD_N(add_next_ERROR_REG, 8, counter_next_ERROR_REG,     cout_next_ERROR_REG, counter_plus_inc_ERROR_REG, dec_neg_8b_ERROR_REG, 1'b0)
    `REG_RST_WE(REG_ERROR_REG, 8, clk, combined_rst_n, 1'b1, counter_next_ERROR_REG, counter_ERROR_REG)

    // ----- NO_REG  (ID 25) -----
    wire match_dr_NO_REG, match_sr_NO_REG, match_wb0_NO_REG, match_wb1_NO_REG;
    wire dr_inc_NO_REG, sr_inc_pre_NO_REG, sr_inc_NO_REG, inc_NO_REG;
    wire wb0_dec_NO_REG, wb1_dec_pre_NO_REG, wb1_dec_NO_REG, dec_NO_REG;
    wire [7:0] counter_NO_REG, inc_8b_NO_REG, dec_neg_8b_NO_REG;
    wire [7:0] counter_plus_inc_NO_REG, counter_next_NO_REG;
    wire cout_inc_NO_REG, cout_next_NO_REG;
    `CMP_N(cmp_dr_NO_REG,  5, match_dr_NO_REG,  dr_id,     5'd25)
    `CMP_N(cmp_sr_NO_REG,  5, match_sr_NO_REG,  sr_id,     5'd25)
    `CMP_N(cmp_wb0_NO_REG, 5, match_wb0_NO_REG, wb_dr0_id, 5'd25)
    `CMP_N(cmp_wb1_NO_REG, 5, match_wb1_NO_REG, wb_dr1_id, 5'd25)
    `AND_3(and_dr_inc_NO_REG,     1, dr_inc_NO_REG,     updateSB, cs_dr_wr, match_dr_NO_REG)
    `AND_3(and_sr_inc_pre_NO_REG, 1, sr_inc_pre_NO_REG, updateSB, cs_sr_wr, match_sr_NO_REG)
    `AND_2(and_sr_inc_NO_REG,     1, sr_inc_NO_REG,     sr_inc_pre_NO_REG, cs_wr_to_both_n)
    `OR_3 (or_inc_NO_REG,         1, inc_NO_REG,        dr_inc_NO_REG, sr_inc_NO_REG, 1'b0)
    `AND_2(and_wb0_dec_NO_REG,     1, wb0_dec_NO_REG,     wb_dr0_we, match_wb0_NO_REG)
    `AND_2(and_wb1_dec_pre_NO_REG, 1, wb1_dec_pre_NO_REG, wb_dr1_we, match_wb1_NO_REG)
    `AND_2(and_wb1_dec_NO_REG,     1, wb1_dec_NO_REG,     wb1_dec_pre_NO_REG, wb_wr_to_both_n)
    `OR_2 (or_dec_NO_REG,          1, dec_NO_REG,         wb0_dec_NO_REG, wb1_dec_NO_REG)
    assign inc_8b_NO_REG[7:1] = 7'b0;
    assign inc_8b_NO_REG[0]   = inc_NO_REG;
    `MUX_2(mux_decneg_NO_REG, 8, dec_neg_8b_NO_REG, 8'h00, 8'hFF, dec_NO_REG)
    `ADD_N(add_inc_NO_REG,  8, counter_plus_inc_NO_REG, cout_inc_NO_REG,  counter_NO_REG,          inc_8b_NO_REG,     1'b0)
    `ADD_N(add_next_NO_REG, 8, counter_next_NO_REG,     cout_next_NO_REG, counter_plus_inc_NO_REG, dec_neg_8b_NO_REG, 1'b0)
    `REG_RST_WE(REG_NO_REG, 8, clk, combined_rst_n, 1'b1, counter_next_NO_REG, counter_NO_REG)


    //=========================================================================
    // Stall logic
    //
    // For each stall path, mux the relevant counter from all 26 registers using
    // MUX_32 (5-bit select, inputs 26..31 tied to 0). Then check counter != 0
    // by comparing to 8'h00 and inverting. Then gate by the corresponding
    // condition. dep_stall = OR of all six stall paths (eax_stall is 0).
    //=========================================================================

    // memOrRep gate inputs for dr/sr stalls
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
        counter_ERROR_REG, counter_NO_REG, 8'h00, 8'h00,
        8'h00, 8'h00, 8'h00, 8'h00,
        dr_id)
    `CMP_N(cmp_zero_dr, 8, eq_zero_dr, counter_dr_lookup, 8'h00)
    `INV_N(inv_zero_dr, 1, eq_zero_dr, nonzero_dr)
    `AND_2(and_dr_stall, 1, dr_stall, gate_dr_rd, nonzero_dr)

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
        counter_ERROR_REG, counter_NO_REG, 8'h00, 8'h00,
        8'h00, 8'h00, 8'h00, 8'h00,
        sr_id)
    `CMP_N(cmp_zero_sr, 8, eq_zero_sr, counter_sr_lookup, 8'h00)
    `INV_N(inv_zero_sr, 1, eq_zero_sr, nonzero_sr)
    `AND_2(and_sr_stall, 1, sr_stall, gate_sr_rd, nonzero_sr)

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
        counter_ERROR_REG, counter_NO_REG, 8'h00, 8'h00,
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
        counter_ERROR_REG, counter_NO_REG, 8'h00, 8'h00,
        8'h00, 8'h00, 8'h00, 8'h00,
        Segment1_ID)
    `CMP_N(cmp_zero_seg1, 8, eq_zero_seg1, counter_seg1_lookup, 8'h00)
    `INV_N(inv_zero_seg1, 1, eq_zero_seg1, nonzero_seg1)
    `AND_2(and_seg1_stall, 1, seg1_stall, Segment1_valid, nonzero_seg1)

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
        counter_ERROR_REG, counter_NO_REG, 8'h00, 8'h00,
        8'h00, 8'h00, 8'h00, 8'h00,
        sib_base_id)
    `CMP_N(cmp_zero_sib_base, 8, eq_zero_sib_base, counter_sib_base_lookup, 8'h00)
    `INV_N(inv_zero_sib_base, 1, eq_zero_sib_base, nonzero_sib_base)
    `AND_2(and_sib_base_stall, 1, sib_base_stall, cs_sib_size, nonzero_sib_base)

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
        counter_ERROR_REG, counter_NO_REG, 8'h00, 8'h00,
        8'h00, 8'h00, 8'h00, 8'h00,
        sib_idx_id)
    `CMP_N(cmp_zero_sib_idx, 8, eq_zero_sib_idx, counter_sib_idx_lookup, 8'h00)
    `INV_N(inv_zero_sib_idx, 1, eq_zero_sib_idx, nonzero_sib_idx)
    `AND_2(and_sib_idx_stall, 1, sib_idx_stall, cs_sib_size, nonzero_sib_idx)

    // ----- dep_stall = OR of 6 stall sources (eax_stall is hardcoded 0) -----
    `OR_6(or_dep_stall, 1, dep_stall,
        dr_stall, sr_stall, seg0_stall, seg1_stall, sib_base_stall, sib_idx_stall)

    //=========================================================================
    // Direct (constant-id) status outputs: ecx_sb, codeSeg_sb
    //=========================================================================
    wire eq_zero_ecx;
    `CMP_N(cmp_zero_ecx, 8, eq_zero_ecx, counter_ECX, 8'h00)
    `INV_N(inv_zero_ecx, 1, eq_zero_ecx, ecx_sb)

    wire eq_zero_cs;
    `CMP_N(cmp_zero_cs, 8, eq_zero_cs, counter_CS, 8'h00)
    `INV_N(inv_zero_cs, 1, eq_zero_cs, codeSeg_sb)

endmodule
