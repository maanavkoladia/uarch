// Structural Verilog 2005 port of IDM_Ctrl_Logic.
// Reference SV: rtl/core/Fetch/IDM_Ctrl_Logic.sv
//
// Builds per-slot IDM write requests. Behavior matches the SV after the
// invalidate-priority change: Block A unconditionally drives ld_meta_data=1
// and forces valid=0 / br_valid=0 when invalidate[i]=1; Block B (when
// ~slot_valid[i]) may then overwrite valid/br_valid/data through the usual
// sel/br_cond path. Case analysis collapses to:
//
//   ld_meta_data[i] = invalidate[i] | ~slot_valid[i]
//   wr_en[i]        = ~slot_valid[i]
//                   & (i == slot_num)
//                   & (icache_hit | exp_mode | int_mode)
//                   & ~no_writes
//   valid[i]        = wr_en[i]
//   ld_data[i]      = wr_en[i]
//   data[i]         = wr_en[i]      ? data_in        : 0
//   br_active[i]    = wr_en[i] & btb_hit & pred_taken & ~spc_sel_flush_reg
//   br_valid[i]     = br_active[i]
//   br_eip[i]       = br_active[i]  ? btb_br_eip     : 0
//   br_target[i]    = br_active[i]  ? btb_br_target  : 0
//   br_xcl[i]       = br_active[i] & btb_XCL
//   push_success    = OR over slots of wr_en[i]
//
// Critical: wr_en[i] does NOT depend on invalidate[i]. invalidate is a
// late-arriving signal (it falls out of the invalidate logic AND-OR
// network), so removing it from the wr_en cone shaves the worst path on
// the wide data MUX selector and the br_eip/br_target MUX selectors.
// invalidate[i] now only feeds ld_meta_data[i] (a single NAND_2).
//
// Gate-level optimizations:
//   - wr_en_n[i] is one NAND_4. The active-low form is consumed twice
//     without an extra inverter:
//       (a) push_success = NAND_4(wr_en_n[0..3])      -- NAND of NANDs = OR
//       (b) br_active[i] = NOR_2(wr_en_n[i], br_cond_n) -- NOR of actv-low = AND
//     wr_en[i] (active-high) is only needed by the data-MUX selector and
//     the scalar valid/ld_data outputs, so we pay just one INV per slot.
//   - br_cond_n = NAND_3(btb_hit, pred_taken, ~spc_sel_flush_reg) -- a
//     single stage, no INV before the NOR_2 above.
//   - ld_meta_data[i] = NAND_2(~invalidate[i], slot_valid[i]) -- the only
//     consumer of invalidate[i] in this module.

module IDM_Ctrl_Logic (
    input  wire        exp_mode,
    input  wire        int_mode,
    input  wire [31:0] spc,

    // idm_outputs_t -- only per-slot valid bits used here
    input  wire        idm_slot_valid    [0:3],

    // idm_invalidate_logic_output_t fields
    input  wire        invalidate        [0:3],
    input  wire        no_writes,

    // btb_output_t fields (br_ucond unused)
    input  wire        btb_hit,
    input  wire [31:0] btb_br_target,
    input  wire [31:0] btb_br_eip,
    input  wire        btb_XCL,

    // predictor_output_t
    input  wire        pred_taken,

    // icache_2_core_t -- only hit used (cacheline data arrives via data_in,
    // selected by the parent between icache and the EXP ROM)
    input  wire        icache_hit,

    // spc_sel_logic_output_t -- only flush_reg consumed
    input  wire        spc_sel_flush_reg,

    // Cacheline data going into the IDM
    input  wire [7:0]  data_in           [0:15],

    // idm_ctrl_logic_output_t -- flat per-slot fields
    output wire        idm_req_ld_meta_data [0:3],
    output wire        idm_req_ld_data      [0:3],
    output wire        idm_req_valid        [0:3],
    output wire        idm_req_br_valid     [0:3],
    output wire [31:0] idm_req_br_eip       [0:3],
    output wire [31:0] idm_req_br_target    [0:3],
    output wire        idm_req_br_xcl       [0:3],
    output wire [7:0]  idm_req_data         [0:3] [0:15],

    output wire        push_success
);

    localparam SLOT_BITS   = 2;       // $clog2(NUM_IDM_SLOTS)
    localparam OFFSET_BITS = 4;       // $clog2(CACHE_LINES_SIZE_B)

    // ----------------------------------------------------------------
    // slot_num = spc[OFFSET_BITS+SLOT_BITS-1 : OFFSET_BITS]   (= spc[5:4])
    // slot_oh  = one-hot of slot_num
    // ----------------------------------------------------------------
    wire [SLOT_BITS-1:0] slot_num;
    wire [3:0]           slot_oh;

    assign slot_num = spc[OFFSET_BITS+SLOT_BITS-1 : OFFSET_BITS];
    `DECODER_N(u_slot_dec, SLOT_BITS, slot_num, slot_oh)

    // ----------------------------------------------------------------
    // Shared combinational signals
    //   activation  = icache_hit | exp_mode | int_mode
    //   no_writes_n = ~no_writes
    //   flush_reg_n = ~spc_sel_flush_reg
    //   br_cond_n   = ~(btb_hit & pred_taken & flush_reg_n)
    //               -- single NAND_3, kept active-low for the per-slot NOR_2
    // ----------------------------------------------------------------
    wire activation;
    wire no_writes_n;
    wire flush_reg_n;
    wire br_cond_n;

    `OR_3  (u_act,  1, activation,        icache_hit, exp_mode, int_mode)
    `INV_N (u_nnw,  1, no_writes,         no_writes_n)
    `INV_N (u_nfr,  1, spc_sel_flush_reg, flush_reg_n)
    `NAND_3(u_brcn, 1, br_cond_n,         btb_hit, pred_taken, flush_reg_n)

    // ----------------------------------------------------------------
    // Per-slot core signals
    // ----------------------------------------------------------------
    wire invalidate_n [0:3];
    wire slot_valid_n [0:3];
    wire wr_en_n      [0:3];   // active-low write enable (NAND_4 output)
    wire wr_en        [0:3];   // active-high write enable (after one INV)
    wire br_active    [0:3];

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : g_slot
            // ld_meta_data[i] = invalidate[i] | ~slot_valid[i]
            //                 = ~(~invalidate[i] & slot_valid[i])
            `INV_N (u_invn, 1, invalidate[i],     invalidate_n[i])
            `NAND_2(u_ldm,  1, idm_req_ld_meta_data[i],
                    invalidate_n[i], idm_slot_valid[i])

            // wr_en_n[i] = ~(~slot_valid[i] & slot_oh[i] & activation & ~no_writes)
            // wr_en[i]   = INV(wr_en_n[i])
            `INV_N (u_svn,  1, idm_slot_valid[i], slot_valid_n[i])
            `NAND_4(u_wen,  1, wr_en_n[i],
                    slot_valid_n[i], slot_oh[i], activation, no_writes_n)
            `INV_N (u_we,   1, wr_en_n[i],        wr_en[i])

            // br_active[i] = wr_en[i] & btb_hit & pred_taken & flush_reg_n
            //              = ~wr_en_n[i] & ~br_cond_n
            //              = NOR_2(wr_en_n[i], br_cond_n)
            `NOR_2 (u_bra,  1, br_active[i],      wr_en_n[i], br_cond_n)
        end
    endgenerate

    // ----------------------------------------------------------------
    // Per-slot scalar outputs
    //   valid[i]    = wr_en[i]
    //   ld_data[i]  = wr_en[i]
    //   br_valid[i] = br_active[i]
    //   br_xcl[i]   = br_active[i] & btb_XCL
    // ----------------------------------------------------------------
    generate
        for (i = 0; i < 4; i = i + 1) begin : g_slot_scalar_out
            assign idm_req_valid[i]    = wr_en[i];
            assign idm_req_ld_data[i]  = wr_en[i];
            assign idm_req_br_valid[i] = br_active[i];

            `AND_2(u_brxcl, 1, idm_req_br_xcl[i], br_active[i], btb_XCL)
        end
    endgenerate

    // ----------------------------------------------------------------
    // Per-slot wide outputs
    //   br_eip[i]    = br_active[i] ? btb_br_eip    : 0
    //   br_target[i] = br_active[i] ? btb_br_target : 0
    //   data[i]      = wr_en[i]     ? data_in       : 0
    //
    // The cacheline data is an unpacked 16-byte array. Pack it into a
    // 128-bit wire for one wide MUX_2 per slot, then unpack back into
    // the unpacked output array.
    // ----------------------------------------------------------------
    wire [127:0] data_in_packed;
    generate
        for (i = 0; i < 16; i = i + 1) begin : g_pack_data_in
            assign data_in_packed[i*8 +: 8] = data_in[i];
        end
    endgenerate

    generate
        for (i = 0; i < 4; i = i + 1) begin : g_slot_wide_out
            wire [127:0] slot_data_packed;

            `MUX_2(u_be, 32,  idm_req_br_eip[i],
                   32'h0,  btb_br_eip,    br_active[i])
            `MUX_2(u_bt, 32,  idm_req_br_target[i],
                   32'h0,  btb_br_target, br_active[i])
            `MUX_2(u_dm, 128, slot_data_packed,
                   128'h0, data_in_packed, wr_en[i])

            genvar k;
            for (k = 0; k < 16; k = k + 1) begin : g_unpack_data
                assign idm_req_data[i][k] = slot_data_packed[k*8 +: 8];
            end
        end
    endgenerate

    // ----------------------------------------------------------------
    // push_success = OR over slots of wr_en[i]
    //              = NAND_4 of wr_en_n[i]   (NAND-of-NANDs = OR)
    // One NAND level from the per-slot NAND_4s; no INVs in this cone.
    // ----------------------------------------------------------------
    `NAND_4(u_psucc, 1, push_success,
            wr_en_n[0], wr_en_n[1], wr_en_n[2], wr_en_n[3])

endmodule
