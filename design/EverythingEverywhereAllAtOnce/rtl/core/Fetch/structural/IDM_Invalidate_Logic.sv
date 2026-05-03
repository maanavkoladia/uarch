// Structural Verilog 2005 port of IDM_Invalidate_Logic.
// Reference SV: rtl/core/Fetch/structural/IDM_Invalidate_Logic.sv (original).
//
// Computes which IDM slots to invalidate this cycle. Two reasons:
//   - "Slot in use changed" — eip moved to a new slot, the previous one is dead.
//   - "Will leave for branch" — decode hit a branch's eip and the branch
//     redirects out of the current line. Invalidate the branch slot
//     (and the next slot too if the branch was XCL crossing into it).
// On any global flush condition (flush / exp_pipeclear / int_pipe_clear /
// reset), all four invalidate bits + no_writes go high.
//
// Convention change vs. SV: this module now uses ACTIVE-LOW rst. Fetch.sv
// passes its top-level rst directly. The SV reference also reset prev_eip
// to the current eip; the structural port resets it to 0 instead — the
// global_flush term forces invalidate=all-1 + no_writes=1 during reset, so
// the slight prev_eip startup difference is benign (any spurious
// "slot_in_use_changed" on the first cycle out of reset is masked by the
// no_writes guard at the consumer).

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

    // idm_outputs_t — only the fields this module reads (cacheline data NOT used)
    input  wire        idm_slot_valid          [0:3],
    input  wire        idm_slot_br_valid       [0:3],
    input  wire [31:0] idm_slot_br_eip         [0:3],
    input  wire [31:0] idm_slot_br_btb_target  [0:3],
    input  wire        idm_slot_br_xcl         [0:3],

    input  wire        decode_forward,

    // idm_invalidate_logic_output_t fields
    output wire        invalidate              [0:3],
    output wire        no_writes
);

    localparam SLOT_BITS   = 2;              // $clog2(NUM_IDM_SLOTS), NUM_IDM_SLOTS=4
    localparam OFFSET_BITS = 4;              // $clog2(CACHE_LINES_SIZE_B), CLSZ=16

    // ----------------------------------------------------------------
    // Slot index extraction
    // ----------------------------------------------------------------
    wire [SLOT_BITS-1:0] eip_slot_num;
    wire [SLOT_BITS-1:0] prev_eip_slot_num;
    wire [31:0]          prev_eip;
    wire [31:0]          prev_eip_next;

    assign eip_slot_num      = eip      [OFFSET_BITS+SLOT_BITS-1 : OFFSET_BITS];
    assign prev_eip_slot_num = prev_eip [OFFSET_BITS+SLOT_BITS-1 : OFFSET_BITS];

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
    wire        eip_slot_br_xcl;

    `MUX_4(u_eip_brv,    1, eip_slot_br_valid,
           idm_slot_br_valid[0],       idm_slot_br_valid[1],
           idm_slot_br_valid[2],       idm_slot_br_valid[3],       eip_slot_num)

    `MUX_4(u_eip_breip, 32, eip_slot_br_eip,
           idm_slot_br_eip[0],         idm_slot_br_eip[1],
           idm_slot_br_eip[2],         idm_slot_br_eip[3],         eip_slot_num)

    `MUX_4(u_eip_brbt, 32, eip_slot_br_btb_target,
           idm_slot_br_btb_target[0],  idm_slot_br_btb_target[1],
           idm_slot_br_btb_target[2],  idm_slot_br_btb_target[3],  eip_slot_num)

    `MUX_4(u_eip_brxc,  1, eip_slot_br_xcl,
           idm_slot_br_xcl[0],         idm_slot_br_xcl[1],
           idm_slot_br_xcl[2],         idm_slot_br_xcl[3],         eip_slot_num)

    // ----------------------------------------------------------------
    // next_slot.valid via AND-OR over the one-hot
    // ----------------------------------------------------------------
    wire [3:0] next_valid_term;
    wire       next_slot_valid;

    `AND_2(u_nvt0, 1, next_valid_term[0], next_slot_oh[0], idm_slot_valid[0])
    `AND_2(u_nvt1, 1, next_valid_term[1], next_slot_oh[1], idm_slot_valid[1])
    `AND_2(u_nvt2, 1, next_valid_term[2], next_slot_oh[2], idm_slot_valid[2])
    `AND_2(u_nvt3, 1, next_valid_term[3], next_slot_oh[3], idm_slot_valid[3])
    `OR_4 (u_nvor, 1, next_slot_valid,
           next_valid_term[0], next_valid_term[1],
           next_valid_term[2], next_valid_term[3])

    // ----------------------------------------------------------------
    // will_leave_for_br =
    //     idm_slots[eip_slot_num].br_valid                       &
    //     (idm_slots[eip_slot_num].br_eip == eip)                &
    //     ~(idm_slots[eip_slot_num].br_btb_target[31:4] == eip[31:4]) &
    //     decode_forward
    // ----------------------------------------------------------------
    wire br_eip_match;
    wire br_target_line_match;
    wire br_target_line_diff;
    wire will_leave_for_br;

    `CMP_N(u_breip_cmp, 32, br_eip_match,
           eip_slot_br_eip, eip)
    `CMP_N(u_btgt_cmp,  28, br_target_line_match,
           eip_slot_br_btb_target[31:4], eip[31:4])
    `INV_N(u_btgt_inv,  1, br_target_line_match, br_target_line_diff)
    `AND_4(u_wlfb,      1, will_leave_for_br,
           eip_slot_br_valid, br_eip_match, br_target_line_diff, decode_forward)

    // ----------------------------------------------------------------
    // Branch-leave invalidate cases:
    //   case_a: ~xcl=0 (i.e. xcl) AND next_slot.valid       -> invalidate eip+next
    //   case_b: xcl AND ~next_slot.valid                    -> NOOP (asserted bad in SV)
    //   case_c: ~xcl                                        -> invalidate eip
    //
    //   eip_slot_invalidate_from_br  = case_a | case_c  =  ~case_b
    //   next_slot_invalidate_from_br = case_a            =  xcl & next_slot.valid
    // ----------------------------------------------------------------
    wire not_next_slot_valid;
    wire case_a;
    wire case_b;
    wire eip_slot_inv_from_br;       // ~case_b
    wire next_slot_inv_from_br;      // case_a

    `INV_N(u_invnv,  1, next_slot_valid, not_next_slot_valid)
    `AND_2(u_caseA, 1, case_a, eip_slot_br_xcl, next_slot_valid)
    `AND_2(u_caseB, 1, case_b, eip_slot_br_xcl, not_next_slot_valid)
    `INV_N(u_eifb,  1, case_b, eip_slot_inv_from_br)
    assign next_slot_inv_from_br = case_a;

    // ----------------------------------------------------------------
    // global_flush = flush | exp_pipeclear | int_pipe_clear | ~rst
    //   no_writes = global_flush
    // ----------------------------------------------------------------
    wire rst_active_high;
    wire global_flush;
    `INV_N(u_rstinv, 1, rst, rst_active_high)
    `OR_4 (u_gfl,    1, global_flush,
           flush, exp_pipeclear, int_pipe_clear, rst_active_high)

    assign no_writes = global_flush;

    // ----------------------------------------------------------------
    // Per-slot invalidate
    //   inv_local[i] = (slot_in_use_changed & prev_eip_slot_oh[i])
    //                | (will_leave_for_br &
    //                       (eip_slot_oh[i] & eip_slot_inv_from_br |
    //                        next_slot_oh[i] & next_slot_inv_from_br))
    //   invalidate[i] = global_flush | inv_local[i]
    // ----------------------------------------------------------------
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : g_inv
            wire inv_change;
            wire inv_eip_term;
            wire inv_next_term;
            wire inv_brleave_pre;
            wire inv_brleave;
            wire inv_local;

            `AND_2(u_chg,    1, inv_change,    slot_in_use_changed, prev_eip_slot_oh[i])
            `AND_2(u_iet,    1, inv_eip_term,  eip_slot_oh[i],      eip_slot_inv_from_br)
            `AND_2(u_int,    1, inv_next_term, next_slot_oh[i],     next_slot_inv_from_br)
            `OR_2 (u_blpre,  1, inv_brleave_pre, inv_eip_term,      inv_next_term)
            `AND_2(u_bl,     1, inv_brleave,   will_leave_for_br,   inv_brleave_pre)
            `OR_2 (u_loc,    1, inv_local,     inv_change,          inv_brleave)
            `OR_2 (u_glb,    1, invalidate[i], global_flush,        inv_local)
        end
    endgenerate

    // ----------------------------------------------------------------
    // prev_eip_next mux
    //   default: prev_eip_next = eip
    //   when (will_leave_for_br & ~case_b): prev_eip_next = eip_slot_br_btb_target
    // ----------------------------------------------------------------
    wire use_btb_target;
    `AND_2(u_ubt, 1, use_btb_target, will_leave_for_br, eip_slot_inv_from_br)
    `MUX_2(u_pep, 32, prev_eip_next,
           eip, eip_slot_br_btb_target, use_btb_target)

    // prev_eip register (resets to 0; see header comment for semantic note)
    `REG_RST_WE(u_prev_eip, 32, clk, rst, 1'b1, prev_eip_next, prev_eip)

endmodule
