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
           idm_slot_br_valid[0],            idm_slot_br_valid[1],
           idm_slot_br_valid[2],            idm_slot_br_valid[3],            eip_slot_num)

    `MUX_4(u_eip_breip, 32, eip_slot_br_eip,
           idm_slot_br_eip[0*32 +: 32],     idm_slot_br_eip[1*32 +: 32],
           idm_slot_br_eip[2*32 +: 32],     idm_slot_br_eip[3*32 +: 32],     eip_slot_num)

    `MUX_4(u_eip_brbt, 32, eip_slot_br_btb_target,
           idm_slot_br_btb_target[0*32 +: 32], idm_slot_br_btb_target[1*32 +: 32],
           idm_slot_br_btb_target[2*32 +: 32], idm_slot_br_btb_target[3*32 +: 32], eip_slot_num)

    `MUX_4(u_eip_brxc,  1, eip_slot_br_xcl,
           idm_slot_br_xcl[0],              idm_slot_br_xcl[1],
           idm_slot_br_xcl[2],              idm_slot_br_xcl[3],              eip_slot_num)

    // ----------------------------------------------------------------
    // next_slot.valid via NAND-NAND (AND-OR equivalent, 2 NAND levels)
    // ----------------------------------------------------------------
    wire [3:0] next_valid_nand;
    wire       next_slot_valid;

    `NAND_2(u_nvn0, 1, next_valid_nand[0], next_slot_oh[0], idm_slot_valid[0])
    `NAND_2(u_nvn1, 1, next_valid_nand[1], next_slot_oh[1], idm_slot_valid[1])
    `NAND_2(u_nvn2, 1, next_valid_nand[2], next_slot_oh[2], idm_slot_valid[2])
    `NAND_2(u_nvn3, 1, next_valid_nand[3], next_slot_oh[3], idm_slot_valid[3])
    `NAND_4(u_nv,   1, next_slot_valid,
            next_valid_nand[0], next_valid_nand[1],
            next_valid_nand[2], next_valid_nand[3])

    // ----------------------------------------------------------------
    // will_leave_for_br
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
    // Branch-leave invalidate cases
    // ----------------------------------------------------------------
    wire not_next_slot_valid;
    wire eip_slot_inv_from_br;       // = ~xcl | next_slot.valid

    `INV_N (u_invnv, 1, next_slot_valid,      not_next_slot_valid)
    `NAND_2(u_eifb,  1, eip_slot_inv_from_br, eip_slot_br_xcl, not_next_slot_valid)

    // ----------------------------------------------------------------
    // global_flush = flush | exp_pipeclear | int_pipe_clear | ~rst
    // ----------------------------------------------------------------
    wire rst_active_high;
    wire global_flush_n;
    `INV_N(u_rstinv, 1, rst,            rst_active_high)
    `NOR_4(u_gfl,    1, global_flush_n,
           flush, exp_pipeclear, int_pipe_clear, rst_active_high)
    `INV_N(u_gfl_inv, 1, global_flush_n, no_writes)

    // ----------------------------------------------------------------
    // Per-slot invalidate
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
            `NAND_2(u_iet_n,  1, inv_eip_n,       eip_slot_oh[i],      eip_slot_inv_from_br)
            `NAND_3(u_int_n,  1, inv_next_n,      next_slot_oh[i],
                    eip_slot_br_xcl, next_slot_valid)
            `NAND_2(u_blpre,  1, inv_brleave_pre, inv_eip_n,           inv_next_n)
            `NAND_2(u_bl_n,   1, inv_brleave_n,   will_leave_for_br,   inv_brleave_pre)
            `NAND_3(u_glb,    1, invalidate[i],   global_flush_n,      inv_change_n, inv_brleave_n)
        end
    endgenerate

    // ----------------------------------------------------------------
    // prev_eip_next mux
    // ----------------------------------------------------------------
    wire use_btb_target;
    `AND_2(u_ubt, 1, use_btb_target, will_leave_for_br, eip_slot_inv_from_br)
    `MUX_2(u_pep, 32, prev_eip_next,
           eip, eip_slot_br_btb_target, use_btb_target)

    // prev_eip register
    `REG_RST_WE(u_prev_eip, 32, clk, rst, 1'b1, prev_eip_next, prev_eip)

endmodule
