// Structural Verilog 2005 port of GShare.
// Reference SV: rtl/core/Fetch/structural/GShare.sv (original).
//
// GShare branch predictor:
//   - bhr_real : architectural global history (updated on exe_br_valid).
//   - bhr_spec : speculative history (updated on btb_hit, snapped to next_bhr_real on misprediction).
//   - PHT      : 2^BHR_SIZE 2-bit saturating counters.
//   - index    = BHR XOR pc[CACHE_LINE_OFF +: BHR_SIZE]   (folded PC bits)
//
//   Read:  taken = PHT[bhr_spec ^ spc[CACHE_LINE_OFF +: BHR_SIZE]].MSB
//   Train: PHT[bhr_real ^ exe_br_eip[CACHE_LINE_OFF +: BHR_SIZE]] inc/dec
//          on (exe_br_valid, exe_br_taken).
//
// Configurable BHR_SIZE via `define at the top of the file. PHT_SIZE = 1<<BHR_SIZE.
// BHR_SIZE must be a power-of-2-friendly index size (the binary mux tree
// below assumes PHT_SIZE is a power of 2, which it is by construction).

`ifndef GSHARE_BHR_SIZE
`define GSHARE_BHR_SIZE 8
`endif

module GShare (
    input  wire        clk,
    input  wire        rst,           // active low

    input  wire [31:0] spc,
    input  wire        btb_hit,

    input  wire        exe_br_valid,
    input  wire        exe_br_taken,
    input  wire [31:0] exe_br_eip,
    input  wire        misprediction,

    output wire        taken
);

    // ----------------------------------------------------------------
    // Sizing
    // ----------------------------------------------------------------
    localparam BHR_SIZE       = `GSHARE_BHR_SIZE;
    localparam PHT_SIZE       = 1 << BHR_SIZE;
    localparam CACHE_LINE_OFF = 4;       // $clog2(CACHE_LINES_SIZE_B), CACHE_LINES_SIZE_B = 16

    // ----------------------------------------------------------------
    // Port-input buffers for the EXE branch-resolution control signals.
    // exe_br_valid fans to 2 ANDs + BHR_SIZE reg en + BHR_SIZE mux sel ~= 18
    // -> bufferH64$. misprediction fans to 1 OR + BHR_SIZE mux sel ~= 9 ->
    // bufferH16$. Buffering at the port keeps the high-fanout net local to
    // GShare and off the upstream EXE driver.
    // ----------------------------------------------------------------
    wire exe_br_valid_int;
    wire misprediction_int;
    bufferH64$ u_buf_exe_br_valid  (.out(exe_br_valid_int),  .in(exe_br_valid));
    bufferH16$ u_buf_misprediction (.out(misprediction_int), .in(misprediction));

    // ----------------------------------------------------------------
    // History registers
    // ----------------------------------------------------------------
    wire [BHR_SIZE-1:0] bhr_spec;
    wire [BHR_SIZE-1:0] bhr_real;

    // ----------------------------------------------------------------
    // PHT entries: PHT_SIZE 2-bit saturating counters.
    // Each entry exposes a 1-bit "taken" output.
    // ----------------------------------------------------------------
    wire [PHT_SIZE-1:0] pht_taken;
    wire [PHT_SIZE-1:0] pht_inc;
    wire [PHT_SIZE-1:0] pht_dec;

    // ----------------------------------------------------------------
    // PHT indices
    //   pht_index_spec   = bhr_spec ^ spc[CACHE_LINE_OFF +: BHR_SIZE]
    //   pht_index_update = bhr_real ^ exe_br_eip[CACHE_LINE_OFF +: BHR_SIZE]
    // ----------------------------------------------------------------
    localparam NUM_LEAVES = 16;

    wire [BHR_SIZE-1:0] spc_pc_bits;
    wire [BHR_SIZE-1:0] eip_pc_bits;
    wire [BHR_SIZE-1:0] pht_index_spec [0:NUM_LEAVES-1];
    wire [BHR_SIZE-1:0] pht_index_update;

    assign spc_pc_bits = spc       [CACHE_LINE_OFF +: BHR_SIZE];
    assign eip_pc_bits = exe_br_eip[CACHE_LINE_OFF +: BHR_SIZE];

    // ----------------------------------------------------------------
    // pht_index_spec: 2-stage buffer tree with 16 stage-2 leaves per bit.
    //
    // The read mux tree's bottom-level bit (SEL_BIT=0) feeds 128 mux
    // selects.  bufferH16$ is rated for 16 loads -- a single stage-2
    // buffer cannot drive 128 (the cause of the previous violation).
    // The proper 2-stage tree:
    //
    //   xor2$ -> s1 (1 buffer)  -> 16x s2 (parallel leaves)
    //                                   each leaf drives <=16 mux selects
    //
    // Per-leaf, per-bit fanout in the read tree:
    //   bit 0: 128 / 16 = 8     (well within rated 16)
    //   bit 1: 64 / 16  = 4
    //   bit 2: 32 / 16  = 2
    //   bit 3: 16 / 16  = 1
    //   bit >=4: <=1
    //
    // Each pred_tree mux node p uses pht_index_spec[(p-1) % 16][SEL_BIT]
    // -- modular round-robin distributes the 255 mux nodes evenly.
    // ----------------------------------------------------------------
    wire [BHR_SIZE-1:0] pht_index_spec_raw;
    wire [BHR_SIZE-1:0] pht_index_spec_s1;

    `XOR_2(u_xor_spec, BHR_SIZE, pht_index_spec_raw, bhr_spec, spc_pc_bits)

    genvar gb;
    generate
        for (gb = 0; gb < BHR_SIZE; gb = gb + 1) begin : g_buf_spec_s1
            bufferH16$ u_s1 (.out(pht_index_spec_s1[gb]),
                             .in(pht_index_spec_raw[gb]));
        end
    endgenerate

    genvar lf;
    generate
        for (lf = 0; lf < NUM_LEAVES; lf = lf + 1) begin : g_buf_spec_s2
            for (gb = 0; gb < BHR_SIZE; gb = gb + 1) begin : g_per_bit
                bufferH16$ u_s2 (.out(pht_index_spec[lf][gb]),
                                 .in(pht_index_spec_s1[gb]));
            end
        end
    endgenerate

    // pht_index_update has only one downstream consumer (u_upd_dec input).
    // The decoder explodes internally to 256 outputs but that fanout is
    // INSIDE MPS_decoder$, not on this wire -- buffering pht_index_update
    // doesn't help the decoder's internal violations. Drive it raw.
    `XOR_2(u_xor_upd, BHR_SIZE, pht_index_update, bhr_real, eip_pc_bits)

    // ----------------------------------------------------------------
    // Train one-hot decode + per-entry inc / dec
    //   taken_train_en[i]    = update_oh[i] & exe_br_valid &  exe_br_taken
    //   nottaken_train_en[i] = update_oh[i] & exe_br_valid & ~exe_br_taken
    // ----------------------------------------------------------------
    wire [PHT_SIZE-1:0] update_oh;
    `DECODER_N(u_upd_dec, BHR_SIZE, pht_index_update, update_oh)

    wire not_exe_br_taken;
    `INV_N(u_inv_etk, 1, exe_br_taken, not_exe_br_taken)

    // ----------------------------------------------------------------
    // taken_global / nottaken_global: 2-stage tree with 16 stage-2 leaves.
    // Each fans out to 256 PHT entries; 16 leaves drive 16 entries each
    // (within bufferH16$ rated 16). g_pht uses (p / 16) to pick its leaf.
    // ----------------------------------------------------------------
    wire taken_global_raw,    taken_global_s1;
    wire nottaken_global_raw, nottaken_global_s1;
    wire [NUM_LEAVES-1:0] taken_global;
    wire [NUM_LEAVES-1:0] nottaken_global;

    `AND_2(u_tg,  1, taken_global_raw,    exe_br_valid_int, exe_br_taken)
    `AND_2(u_ntg, 1, nottaken_global_raw, exe_br_valid_int, not_exe_br_taken)
    bufferH16$ u_tg_s1  (.out(taken_global_s1),    .in(taken_global_raw));
    bufferH16$ u_ntg_s1 (.out(nottaken_global_s1), .in(nottaken_global_raw));

    generate
        for (lf = 0; lf < NUM_LEAVES; lf = lf + 1) begin : g_global_s2
            bufferH16$ u_tg_s2  (.out(taken_global[lf]),    .in(taken_global_s1));
            bufferH16$ u_ntg_s2 (.out(nottaken_global[lf]), .in(nottaken_global_s1));
        end
    endgenerate

    genvar p;
    generate
        for (p = 0; p < PHT_SIZE; p = p + 1) begin : g_pht
            localparam GRP = p / 16;     // 0..15, contiguous 16-entry chunks
            `AND_2(u_inc, 1, pht_inc[p], update_oh[p], taken_global[GRP])
            `AND_2(u_dec, 1, pht_dec[p], update_oh[p], nottaken_global[GRP])

            two_bit_sat_count u_cnt (
                .clk  (clk),
                .rst  (rst),
                .inc  (pht_inc[p]),
                .dec  (pht_dec[p]),
                .taken(pht_taken[p])
            );
        end
    endgenerate

    // ----------------------------------------------------------------
    // Read-side mux: PHT[pht_index_spec].taken
    // Implemented as a binary-tree mux of PHT_SIZE 1-bit values.
    //
    // Heap layout: pred_tree[1] is the root, pred_tree[PHT_SIZE..2*PHT_SIZE-1]
    // are leaves. Node i has children 2*i and 2*i+1. depth(i) = floor(log2(i))
    // = $clog2(i+1)-1. Selector for level d is pht_index_spec[BHR_SIZE-1-d].
    // ----------------------------------------------------------------
    wire [2*PHT_SIZE-1:0] pred_tree;

    generate
        for (p = 0; p < PHT_SIZE; p = p + 1) begin : g_pred_leaf
            assign pred_tree[PHT_SIZE + p] = pht_taken[p];
        end
        for (p = 1; p < PHT_SIZE; p = p + 1) begin : g_pred_node
            localparam DEPTH    = $clog2(p + 1) - 1;
            localparam SEL_BIT  = BHR_SIZE - 1 - DEPTH;
            // Distribute 255 mux nodes across 16 stage-2 buffer leaves.
            // Round-robin by node index keeps per-leaf-per-bit fanout <=8
            // for the worst bit (bit 0, 128 nodes / 16 leaves).
            localparam LEAF_IDX = (p - 1) % NUM_LEAVES;
            `MUX_2(u_mux, 1,
                   pred_tree[p],
                   pred_tree[2*p], pred_tree[2*p + 1],
                   pht_index_spec[LEAF_IDX][SEL_BIT])
        end
    endgenerate

    wire pht_taken_at_spec;
    assign pht_taken_at_spec = pred_tree[1];
    assign taken             = pht_taken_at_spec;

    // ----------------------------------------------------------------
    // bhr_real update
    //   bhr_real_next = exe_br_valid ? {bhr_real[BHR_SIZE-2:0], exe_br_taken}
    //                                : bhr_real
    //   -> use REG_RST_WE with we = exe_br_valid, d = shifted_real
    // ----------------------------------------------------------------
    wire [BHR_SIZE-1:0] shifted_real;
    assign shifted_real[0]            = exe_br_taken;
    assign shifted_real[BHR_SIZE-1:1] = bhr_real[BHR_SIZE-2:0];

    `REG_RST_WE(u_bhr_real, BHR_SIZE, clk, rst, exe_br_valid_int, shifted_real, bhr_real)

    // ----------------------------------------------------------------
    // bhr_spec update (priority: misprediction > btb_hit > hold)
    //
    //   if (misprediction)        spec_next = next_bhr_real (post-resolution real BHR)
    //   else if (btb_hit)         spec_next = {bhr_spec[BHR_SIZE-2:0], pht_taken_at_spec}
    //   else                      hold
    //
    //   we      = misprediction | btb_hit
    //   d_spec  = misprediction ? next_bhr_real : shifted_spec
    //
    // next_bhr_real mirrors what bhr_real becomes this cycle:
    //   next_bhr_real = exe_br_valid ? shifted_real : bhr_real
    // ----------------------------------------------------------------
    wire [BHR_SIZE-1:0] next_bhr_real;
    `MUX_2(u_nbr, BHR_SIZE, next_bhr_real, bhr_real, shifted_real, exe_br_valid_int)

    wire [BHR_SIZE-1:0] shifted_spec;
    assign shifted_spec[0]            = pht_taken_at_spec;
    assign shifted_spec[BHR_SIZE-1:1] = bhr_spec[BHR_SIZE-2:0];

    wire [BHR_SIZE-1:0] din_spec;
    `MUX_2(u_dspec, BHR_SIZE, din_spec, shifted_spec, next_bhr_real, misprediction_int)

    wire spec_we;
    `OR_2(u_swe, 1, spec_we, misprediction_int, btb_hit)

    `REG_RST_WE(u_bhr_spec, BHR_SIZE, clk, rst, spec_we, din_spec, bhr_spec)

endmodule
