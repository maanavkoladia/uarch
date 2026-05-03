// Structural Verilog 2005 port of SPC_Sel_Logic.
// Reference SV: rtl/core/Fetch/structural/SPC_Sel_Logic.sv (original).
//
// Picks the SPC update source for next cycle and tracks two pieces of state:
//   - XCL_stall : "currently servicing a delayed XCL redirect"
//   - flush_reg : one-shot mask after a flush/restore (forces SPC+16 next cycle)
// Plus a registered branch target (BR_target_reg) so an XCL-stall redirect
// uses the saved target even after BTB outputs change.
//
// SPC select encoding (matches Fetch_pkg::spc_sel_logic_output_options_e):
//   00 = SPC          (hold)
//   01 = SPC_P16      (linear advance)
//   10 = BR_RESTORE   (execute mispredict)
//   11 = BTB_TARGET   (predicted taken)
//
// Convention change vs. SV: this module now uses ACTIVE-LOW rst. Fetch.sv
// passes its top-level rst directly (no `!rst` inversion).

module SPC_Sel_Logic (
    input  wire        clk,
    input  wire        rst,                  // active low

    input  wire [31:0] spc,
    input  wire        flush,
    input  wire        decode_stall,         // unused — kept for parity with SV port

    // btb_output_t fields (br_eip, br_ucond unused here)
    input  wire        btb_hit,
    input  wire [31:0] btb_br_target,
    input  wire [31:0] btb_br_eip,
    input  wire        btb_XCL,
    input  wire        btb_br_ucond,

    // predictor_output_t
    input  wire        pred_taken,

    // idm_ctrl_logic_output_t — only push_success consumed
    input  wire        idm_ctrl_push_success,

    // spc_sel_logic_output_t fields
    output wire [1:0]  sel,                  // enum encoded as 2 bits
    output wire        br_target_sel,
    output wire [31:0] br_target,
    output wire        flush_reg
);

    localparam [1:0] SEL_SPC        = 2'b00;
    localparam [1:0] SEL_SPC_P16    = 2'b01;
    localparam [1:0] SEL_BR_RESTORE = 2'b10;
    localparam [1:0] SEL_BTB_TARGET = 2'b11;

    // ----------------------------------------------------------------
    // Aliases for readability
    // ----------------------------------------------------------------
    wire push_success;
    wire btb_xcl;
    assign push_success = idm_ctrl_push_success;
    assign btb_xcl      = btb_XCL;

    // ----------------------------------------------------------------
    // br_taken = btb_hit & pred_taken
    // ----------------------------------------------------------------
    wire br_taken;
    `AND_2(u_brt, 1, br_taken, btb_hit, pred_taken)

    // ----------------------------------------------------------------
    // target_same_line = ({btb_br_target[31:4], 4'b0} == spc)
    // (Fetch.sv only ever assigns line-aligned values to SPC, so the
    // bottom 4 bits of spc are 0 in practice. We still do the masked
    // compare to mirror the SV exactly.)
    // ----------------------------------------------------------------
    wire [31:0] btb_target_line_aligned;
    assign btb_target_line_aligned = {btb_br_target[31:4], 4'b0};

    wire target_same_line;
    `CMP_N(u_tsl_cmp, 32, target_same_line, btb_target_line_aligned, spc)

    // ----------------------------------------------------------------
    // State registers (XCL_stall, BR_target_reg, flush_reg) — declared
    // up front so combinational logic below can refer to their q nets.
    // ----------------------------------------------------------------
    wire        XCL_stall;
    wire [31:0] BR_target_reg;
    wire        flush_reg_q;

    assign flush_reg = flush_reg_q;        // republish to port

    // ----------------------------------------------------------------
    // br_info_we = ~XCL_stall | (XCL_stall & push_success)
    //            = ~XCL_stall | push_success    (consensus simplification)
    // BR_target_reg captures btb_br_target on br_info_we.
    // ----------------------------------------------------------------
    wire not_XCL_stall;
    wire br_info_we;
    `INV_N(u_inv_xs, 1, XCL_stall,    not_XCL_stall)
    `OR_2 (u_brwe,   1, br_info_we,   not_XCL_stall, push_success)

    `REG_RST_WE(u_brt_reg, 32, clk, rst, br_info_we, btb_br_target, BR_target_reg)

    // ----------------------------------------------------------------
    // outputs.br_target_sel = XCL_stall
    // outputs.br_target     = XCL_stall ? BR_target_reg : btb_br_target
    // ----------------------------------------------------------------
    assign br_target_sel = XCL_stall;
    `MUX_2(u_brt_mux, 32, br_target, btb_br_target, BR_target_reg, XCL_stall)

    // ----------------------------------------------------------------
    // SPC sel (4-way) — encoded as a chained MUX_2 tree mirroring the
    // SV if/else priorities:
    //
    //   if (flush)               BR_RESTORE
    //   else if (push_success):
    //       if (flush_reg)       SPC_P16
    //       else if (cond_btb)   BTB_TARGET
    //       else                 SPC_P16
    //   else                     SPC                  (default = hold)
    //
    //   cond_btb = ((br_taken & ~btb_xcl) | XCL_stall) & ~target_same_line
    // ----------------------------------------------------------------
    wire not_btb_xcl;
    wire not_target_same_line;
    wire br_taken_non_xcl;
    wire br_or_xcl_stall;
    wire cond_btb;

    `INV_N(u_inv_bx,  1, btb_xcl,           not_btb_xcl)
    `INV_N(u_inv_tsl, 1, target_same_line,  not_target_same_line)
    `AND_2(u_btnxcl,  1, br_taken_non_xcl,  br_taken,         not_btb_xcl)
    `OR_2 (u_bxorxs,  1, br_or_xcl_stall,   br_taken_non_xcl, XCL_stall)
    `AND_2(u_cbtb,    1, cond_btb,          br_or_xcl_stall,  not_target_same_line)

    // Inner-most: cond_btb ? BTB_TARGET : SPC_P16
    wire [1:0] sel_inner;
    `MUX_2(u_sel_inner,  2, sel_inner,  SEL_SPC_P16, SEL_BTB_TARGET, cond_btb)

    // Middle: flush_reg ? SPC_P16 : sel_inner
    wire [1:0] sel_middle;
    `MUX_2(u_sel_middle, 2, sel_middle, sel_inner,   SEL_SPC_P16,    flush_reg_q)

    // Outer1: push_success ? sel_middle : SPC
    wire [1:0] sel_outer1;
    `MUX_2(u_sel_outer1, 2, sel_outer1, SEL_SPC,     sel_middle,     push_success)

    // Outer2: flush ? BR_RESTORE : sel_outer1
    `MUX_2(u_sel_outer2, 2, sel,        sel_outer1,  SEL_BR_RESTORE, flush)

    // ----------------------------------------------------------------
    // XCL_stall update (priority encoded with REG_RST_WE)
    //
    //   if (flush || flush_reg)                              -> 0
    //   else if (~XCL_stall & br_taken & btb_xcl & push_success) -> 1
    //   else if (XCL_stall & push_success)                   -> 0
    //   else                                                 hold
    //
    //   case1 = flush | flush_reg
    //   case2 = ~XCL_stall & br_taken & btb_xcl & push_success
    //   case3 =  XCL_stall & push_success
    //
    //   we = case1 | case2 | case3
    //   d  = case2 & ~case1     (only path that loads 1; case1/case3 load 0)
    // ----------------------------------------------------------------
    wire xcl_case1;
    wire xcl_case2;
    wire xcl_case3;
    wire xcl_we;
    wire xcl_d;
    wire not_case1;
    wire xcl_case23;

    `OR_2 (u_xc1,     1, xcl_case1, flush, flush_reg_q)
    `AND_4(u_xc2,     1, xcl_case2,
           not_XCL_stall, br_taken, btb_xcl, push_success)
    `AND_2(u_xc3,     1, xcl_case3, XCL_stall, push_success)
    `OR_2 (u_xc23,    1, xcl_case23, xcl_case2, xcl_case3)
    `OR_2 (u_xcwe,    1, xcl_we,     xcl_case1, xcl_case23)
    `INV_N(u_inv_c1,  1, xcl_case1,  not_case1)
    `AND_2(u_xcd,     1, xcl_d,      xcl_case2, not_case1)

    `REG_RST_WE(u_xcl_reg, 1, clk, rst, xcl_we, xcl_d, XCL_stall)

    // ----------------------------------------------------------------
    // flush_reg update (set-dominant on flush; clear on flush_reg & push_success)
    //
    //   if (flush)                          -> 1
    //   else if (flush_reg & push_success)  -> 0
    //   else                                hold
    //
    //   we = flush | (flush_reg & push_success)
    //   d  = flush                                        (both code paths drive d=flush)
    // ----------------------------------------------------------------
    wire fr_clear;
    wire fr_we;

    `AND_2(u_frclr, 1, fr_clear, flush_reg_q, push_success)
    `OR_2 (u_frwe,  1, fr_we,    flush,       fr_clear)

    `REG_RST_WE(u_fr_reg, 1, clk, rst, fr_we, flush, flush_reg_q)

endmodule
