// Structural Verilog 2005 port of IDM_Ctrl_Logic.
// Reference SV: rtl/core/Fetch/structural/IDM_Ctrl_Logic.sv (original).
//
// Builds per-slot IDM write requests. For each of the 4 IDM slots:
//
//   wc[i]  = invalidate[i] | ~idm_slot_valid[i]
//          - "this slot is currently empty or being invalidated"
//   sel[i] = (i == slot_num) & (icache_hit | exp_mode | int_mode) & ~no_writes
//          - "this is the slot the new fetch lands in, and we are allowed to write"
//
//   ld_meta_data[i] = wc[i]                      (always update meta on a write)
//   valid[i]        = wc[i] & sel[i]             (set valid only on the chosen slot)
//   ld_data[i]      = wc[i] & sel[i]
//   data[i]         = (wc & sel) ? data_in : 0
//
//   br_active[i] = (wc & sel) & btb_hit & pred_taken & ~spc_sel_flush_reg
//   br_valid[i]  = br_active[i]
//   br_eip[i]    = br_active ? btb_br_eip    : 0
//   br_target[i] = br_active ? btb_br_target : 0
//   br_xcl[i]    = br_active & btb_XCL
//
//   push_success = OR over slots of (wc[i] & sel[i])
//
// All other fields default to 0 when wc[i]=0.

module IDM_Ctrl_Logic (
    input  wire        exp_mode,
    input  wire        int_mode,
    input  wire [31:0] spc,

    // idm_outputs_t — only per-slot valid bits used here
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

    // icache_2_core_t — only hit used (cacheline data arrives via data_in,
    // selected by the parent between icache and the EXP ROM)
    input  wire        icache_hit,

    // spc_sel_logic_output_t — only flush_reg consumed
    input  wire        spc_sel_flush_reg,

    // Cacheline data going into the IDM
    input  wire [7:0]  data_in           [0:15],

    // idm_ctrl_logic_output_t — flat per-slot fields
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
    // slot_oh = one-hot of slot_num
    // ----------------------------------------------------------------
    wire [SLOT_BITS-1:0] slot_num;
    wire [3:0]           slot_oh;

    assign slot_num = spc[OFFSET_BITS+SLOT_BITS-1 : OFFSET_BITS];
    `DECODER_N(u_slot_dec, SLOT_BITS, slot_num, slot_oh)

    // ----------------------------------------------------------------
    // Common combinational signals
    //   activation = icache_hit | exp_mode | int_mode
    //   not_no_writes = ~no_writes
    //   br_cond = btb_hit & pred_taken & ~spc_sel_flush_reg
    // ----------------------------------------------------------------
    wire activation;
    wire not_no_writes;
    wire not_flush_reg;
    wire btb_hit_and_pred;
    wire br_cond;

    `OR_3 (u_act,     1, activation,        icache_hit, exp_mode, int_mode)
    `INV_N(u_nnw,     1, no_writes,         not_no_writes)
    `INV_N(u_nfr,     1, spc_sel_flush_reg, not_flush_reg)
    `AND_2(u_bhp,     1, btb_hit_and_pred,  btb_hit,    pred_taken)
    `AND_2(u_brc,     1, br_cond,           btb_hit_and_pred, not_flush_reg)

    // ----------------------------------------------------------------
    // Per-slot wc / sel / wc_and_sel / br_active
    // ----------------------------------------------------------------
    wire wc          [0:3];
    wire sel         [0:3];
    wire wc_and_sel  [0:3];
    wire br_active   [0:3];

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : g_slot_ctl
            wire not_slot_valid;

            `INV_N(u_nsv, 1, idm_slot_valid[i], not_slot_valid)
            `OR_2 (u_wc,  1, wc[i],             invalidate[i],     not_slot_valid)

            `AND_3(u_sel, 1, sel[i],            slot_oh[i],        activation, not_no_writes)
            `AND_2(u_was, 1, wc_and_sel[i],     wc[i],             sel[i])
            `AND_2(u_bra, 1, br_active[i],      wc_and_sel[i],     br_cond)
        end
    endgenerate

    // ----------------------------------------------------------------
    // Per-slot scalar outputs
    //   ld_meta_data[i] = wc[i]
    //   valid[i]        = wc_and_sel[i]
    //   ld_data[i]      = wc_and_sel[i]
    //   br_valid[i]     = br_active[i]
    //   br_xcl[i]       = br_active[i] & btb_XCL
    // ----------------------------------------------------------------
    generate
        for (i = 0; i < 4; i = i + 1) begin : g_slot_scalar_out
            assign idm_req_ld_meta_data[i] = wc[i];
            assign idm_req_valid[i]        = wc_and_sel[i];
            assign idm_req_ld_data[i]      = wc_and_sel[i];
            assign idm_req_br_valid[i]     = br_active[i];

            `AND_2(u_brxcl, 1, idm_req_br_xcl[i], br_active[i], btb_XCL)
        end
    endgenerate

    // ----------------------------------------------------------------
    // Per-slot wide outputs
    //   br_eip[i]    = br_active[i] ? btb_br_eip    : 0
    //   br_target[i] = br_active[i] ? btb_br_target : 0
    //   data[i]      = wc_and_sel[i] ? data_in      : 0
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
            // br_eip mux
            `MUX_2(u_be, 32, idm_req_br_eip[i],
                   32'h0, btb_br_eip, br_active[i])
            // br_target mux
            `MUX_2(u_bt, 32, idm_req_br_target[i],
                   32'h0, btb_br_target, br_active[i])
            // data mux (zero when not selected)
            `MUX_2(u_dm, 128, slot_data_packed,
                   128'h0, data_in_packed, wc_and_sel[i])

            // Unpack slot_data_packed back into the unpacked data array
            genvar k;
            for (k = 0; k < 16; k = k + 1) begin : g_unpack_data
                assign idm_req_data[i][k] = slot_data_packed[k*8 +: 8];
            end
        end
    endgenerate

    // ----------------------------------------------------------------
    // push_success = OR over slots of wc_and_sel[i]
    // ----------------------------------------------------------------
    `OR_4(u_psucc, 1, push_success,
          wc_and_sel[0], wc_and_sel[1], wc_and_sel[2], wc_and_sel[3])

endmodule
