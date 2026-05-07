// Structural Verilog 2005 port of IDM_Invalidate_Logic.
// All ports are packed buses (no unpacked-array ports).
//
// Multi-element layouts:
//   idm_slot_valid          : bit i        = slot i valid                  (4 bits)
//   idm_slot_br_valid       : bit i        = slot i br_valid               (4 bits)
//   idm_slot_br_eip         : [i*32 +: 32] = slot i br_eip                  (128 bits)
//   idm_slot_br_btb_target  : [i*32 +: 32] = slot i br_btb_target           (128 bits)
//   idm_slot_br_xcl         : bit i        = slot i br_xcl                 (4 bits)
//   invalidate              : bit i        = invalidate request for slot i (4 bits)

`ifndef NUM_IDM_SLOTS_LOCAL
`define NUM_IDM_SLOTS_LOCAL 4
`endif

module IDM_Invalidate_Logic (
    input  wire        clk,
    input  wire        rst,                  // active low
    input  wire [31:0] eip,
    input  wire        flush,
    input  wire        exp_pipeclear,
    input  wire        int_pipe_clear,
    input  wire        decode_stall,         // unused — kept for parity with SV port

    input  wire [3:0]   idm_slot_valid,
    input  wire [3:0]   idm_slot_br_valid,
    input  wire [127:0] idm_slot_br_eip,
    input  wire [127:0] idm_slot_br_btb_target,
    input  wire [3:0]   idm_slot_br_xcl,

    input  wire        decode_forward,

    output wire [3:0]   invalidate,
    output wire        no_writes
);

    localparam SLOT_BITS   = 2;              // $clog2(NUM_IDM_SLOTS), NUM_IDM_SLOTS=4
    localparam OFFSET_BITS = 4;              // $clog2(CACHE_LINES_SIZE_B), CLSZ=16

    // ----------------------------------------------------------------
    // Slot index extraction
    //
    // prev_eip register shrunk from 32-bit -> 2-bit: only the slot_num
    // bits [5:4] were ever read (used to detect slot rotation).  This
    // saves 30 flops and 30 mux2$ cells in the prev_eip_next mux, AND
    // collapses the use_btb_target fanout from 32 (32-bit mux selector)
    // down to 2 (2-bit mux selector) -- clearing the u_ubt fanout
    // violation entirely without buffering.
    // ----------------------------------------------------------------
    wire [SLOT_BITS-1:0] eip_slot_num;
    wire [SLOT_BITS-1:0] prev_eip_slot_num;
    wire [SLOT_BITS-1:0] prev_eip_slot_num_next;

    assign eip_slot_num = eip[OFFSET_BITS+SLOT_BITS-1 : OFFSET_BITS];

    // One-hot decoded slot indices
    wire [3:0] eip_slot_oh;
    wire [3:0] prev_eip_slot_oh;
    `DECODER_N(u_eip_dec,  SLOT_BITS, eip_slot_num,      eip_slot_oh)
    `DECODER_N(u_prev_dec, SLOT_BITS, prev_eip_slot_num, prev_eip_slot_oh)

    // next_slot one-hot = eip_slot_oh rotated by 1 (mod 4)
    wire [3:0] next_slot_oh;
    assign next_slot_oh[0] = eip_slot_oh[3];
    assign next_slot_oh[1] = eip_slot_oh[0];
    assign next_slot_oh[2] = eip_slot_oh[1];
    assign next_slot_oh[3] = eip_slot_oh[2];

    // ----------------------------------------------------------------
    // slot_in_use_changed = (eip_slot_num != prev_eip_slot_num)
    // ----------------------------------------------------------------
    wire slots_match;
    wire slot_in_use_changed;
    `CMP_N(u_slot_cmp,    SLOT_BITS, slots_match,         eip_slot_num, prev_eip_slot_num)
    `INV_N(u_slot_chg, 1, slots_match, slot_in_use_changed)

    // ----------------------------------------------------------------
    // Read the per-slot fields at eip_slot_num via 4:1 muxes
    // ----------------------------------------------------------------
    wire        eip_slot_br_valid;
    wire [31:0] eip_slot_br_eip;
    wire [31:0] eip_slot_br_btb_target;
    // eip_slot_br_xcl singleton replaced by duplicated [1:0] array below.

    `MUX_4(u_eip_brv,    1, eip_slot_br_valid,
           idm_slot_br_valid[0],            idm_slot_br_valid[1],
           idm_slot_br_valid[2],            idm_slot_br_valid[3],            eip_slot_num)

    `MUX_4(u_eip_breip, 32, eip_slot_br_eip,
           idm_slot_br_eip[0*32 +: 32],     idm_slot_br_eip[1*32 +: 32],
           idm_slot_br_eip[2*32 +: 32],     idm_slot_br_eip[3*32 +: 32],     eip_slot_num)

    `MUX_4(u_eip_brbt, 32, eip_slot_br_btb_target,
           idm_slot_br_btb_target[0*32 +: 32], idm_slot_br_btb_target[1*32 +: 32],
           idm_slot_br_btb_target[2*32 +: 32], idm_slot_br_btb_target[3*32 +: 32], eip_slot_num)

    // eip_slot_br_xcl duplicated _a (slots 0-1 + u_eifb_a) / _b (slots 2-3 + u_eifb_b)
    // The MUX_4 cells take the same inputs and produce the same value; the
    // duplication just drops per-cell fanout from 5 to 3 (each within rated
    // mux4$ load) without buffering.
    wire [1:0] eip_slot_br_xcl_dup;
    `MUX_4(u_eip_brxc_a, 1, eip_slot_br_xcl_dup[0],
           idm_slot_br_xcl[0], idm_slot_br_xcl[1],
           idm_slot_br_xcl[2], idm_slot_br_xcl[3], eip_slot_num)
    `MUX_4(u_eip_brxc_b, 1, eip_slot_br_xcl_dup[1],
           idm_slot_br_xcl[0], idm_slot_br_xcl[1],
           idm_slot_br_xcl[2], idm_slot_br_xcl[3], eip_slot_num)

    // ----------------------------------------------------------------
    // next_slot.valid via NAND-NAND (AND-OR equivalent, 2 NAND levels)
    // Duplicate the final NAND_4 to clear the 5-fanout violation.
    // ----------------------------------------------------------------
    wire [3:0] next_valid_nand;
    wire [1:0] next_slot_valid_dup;

    `NAND_2(u_nvn0, 1, next_valid_nand[0], next_slot_oh[0], idm_slot_valid[0])
    `NAND_2(u_nvn1, 1, next_valid_nand[1], next_slot_oh[1], idm_slot_valid[1])
    `NAND_2(u_nvn2, 1, next_valid_nand[2], next_slot_oh[2], idm_slot_valid[2])
    `NAND_2(u_nvn3, 1, next_valid_nand[3], next_slot_oh[3], idm_slot_valid[3])
    `NAND_4(u_nv_a, 1, next_slot_valid_dup[0],
            next_valid_nand[0], next_valid_nand[1],
            next_valid_nand[2], next_valid_nand[3])
    `NAND_4(u_nv_b, 1, next_slot_valid_dup[1],
            next_valid_nand[0], next_valid_nand[1],
            next_valid_nand[2], next_valid_nand[3])

    // ----------------------------------------------------------------
    // will_leave_for_br -- duplicated AND_4 (slots 0-1+u_ubt / slots 2-3)
    // ----------------------------------------------------------------
    wire br_eip_match;
    wire br_target_line_match;
    wire br_target_line_diff;
    wire [1:0] will_leave_for_br_dup;

    `CMP_N(u_breip_cmp, 32, br_eip_match,
           eip_slot_br_eip, eip)
    `CMP_N(u_btgt_cmp,  28, br_target_line_match,
           eip_slot_br_btb_target[31:4], eip[31:4])
    `INV_N(u_btgt_inv,  1, br_target_line_match, br_target_line_diff)
    `AND_4(u_wlfb_a, 1, will_leave_for_br_dup[0],
           eip_slot_br_valid, br_eip_match, br_target_line_diff, decode_forward)
    `AND_4(u_wlfb_b, 1, will_leave_for_br_dup[1],
           eip_slot_br_valid, br_eip_match, br_target_line_diff, decode_forward)

    // ----------------------------------------------------------------
    // Branch-leave invalidate cases
    // eip_slot_inv_from_br = ~xcl | next_slot.valid -- duplicated NAND_2
    // not_next_slot_valid driven from next_slot_valid_dup[0] (the "_a"
    // copy that also feeds slots 0-1); u_eifb_a/_b each consume one of
    // the eip_slot_br_xcl dup copies.
    // ----------------------------------------------------------------
    wire not_next_slot_valid;
    wire [1:0] eip_slot_inv_from_br_dup;

    `INV_N (u_invnv, 1, next_slot_valid_dup[0],   not_next_slot_valid)
    `NAND_2(u_eifb_a, 1, eip_slot_inv_from_br_dup[0],
            eip_slot_br_xcl_dup[0], not_next_slot_valid)
    `NAND_2(u_eifb_b, 1, eip_slot_inv_from_br_dup[1],
            eip_slot_br_xcl_dup[1], not_next_slot_valid)

    // ----------------------------------------------------------------
    // global_flush = flush | exp_pipeclear | int_pipe_clear | ~rst
    // Duplicate NOR_4 so per-cell fanout drops to 3 (was 5).
    // The "_a" copy drives slots 0-1 + u_gfl_inv (the no_writes INV);
    // "_b" copy drives slots 2-3.
    // ----------------------------------------------------------------
    wire rst_active_high;
    wire [1:0] global_flush_n_dup;
    `INV_N(u_rstinv, 1, rst, rst_active_high)
    `NOR_4(u_gfl_a, 1, global_flush_n_dup[0],
           flush, exp_pipeclear, int_pipe_clear, rst_active_high)
    `NOR_4(u_gfl_b, 1, global_flush_n_dup[1],
           flush, exp_pipeclear, int_pipe_clear, rst_active_high)
    `INV_N(u_gfl_inv, 1, global_flush_n_dup[0], no_writes)

    // ----------------------------------------------------------------
    // Per-slot invalidate -- each generate iteration uses [i/2] of the
    // duplicated shared signals, halving every per-cell fanout.
    // ----------------------------------------------------------------
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : g_inv
            wire inv_change_n;
            wire inv_eip_n;
            wire inv_next_n;
            wire inv_brleave_pre;   // active-high AND-OR result via NAND-NAND
            wire inv_brleave_n;

            `NAND_2(u_chg_n,  1, inv_change_n,    slot_in_use_changed, prev_eip_slot_oh[i])
            `NAND_2(u_iet_n,  1, inv_eip_n,       eip_slot_oh[i],
                    eip_slot_inv_from_br_dup[i/2])
            `NAND_3(u_int_n,  1, inv_next_n,      next_slot_oh[i],
                    eip_slot_br_xcl_dup[i/2], next_slot_valid_dup[i/2])
            `NAND_2(u_blpre,  1, inv_brleave_pre, inv_eip_n, inv_next_n)
            `NAND_2(u_bl_n,   1, inv_brleave_n,   will_leave_for_br_dup[i/2],
                    inv_brleave_pre)
            `NAND_3(u_glb,    1, invalidate[i],   global_flush_n_dup[i/2],
                    inv_change_n, inv_brleave_n)
        end
    endgenerate

    // ----------------------------------------------------------------
    // prev_eip_slot_num_next mux + register (2-bit, shrunk from 32-bit)
    //
    // The full 32-bit prev_eip was only ever sliced to [5:4] for
    // prev_eip_slot_num, so we shrink the entire data path to that
    // 2-bit slot index.  use_btb_target now drives a 2-bit mux selector
    // (fanout 2, well within rated) instead of 32-bit (fanout 32).
    // ----------------------------------------------------------------
    // u_ubt drives the 2-bit prev_eip_slot_num mux's selector (fanout 2,
    // within rated). Consumes the "_a" copies of the duplicated signals
    // -- those copies' fanout already accounts for u_ubt (3 each).
    wire use_btb_target;
    `AND_2(u_ubt, 1, use_btb_target,
           will_leave_for_br_dup[0], eip_slot_inv_from_br_dup[0])

    `MUX_2(u_pep, SLOT_BITS, prev_eip_slot_num_next,
           eip[OFFSET_BITS+SLOT_BITS-1 : OFFSET_BITS],
           eip_slot_br_btb_target[OFFSET_BITS+SLOT_BITS-1 : OFFSET_BITS],
           use_btb_target)

    `REG_RST_WE(u_prev_eip_slot_num, SLOT_BITS, clk, rst, 1'b1,
                prev_eip_slot_num_next, prev_eip_slot_num)

endmodule
