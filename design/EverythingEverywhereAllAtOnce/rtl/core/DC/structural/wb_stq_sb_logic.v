// ----------------------------------------------------------------
// wb_stq_sb_logic -- structural Verilog 2005 port.
//
// Reference: rtl/core/DC/wb_stq_sb_logic.sv
//
//   Physical address split:
//     ld_paddr_X_offset[7:0]  = paddr[11:4]  (8-bit page offset, pre-TLB)
//     ld_paddr_X_pfn[2:0]     = paddr[14:12] (3-bit PFN, post-TLB)
//
//   16 store-queue entries are organized as NUM_WB_ST_QS=4 banks,
//   each ST_Q_DEPTH=4 entries deep.  For each load (0 and 1):
//     bank_num = ld_paddr_X_offset[1:0]   (paddr[5:4])
//     bank_hit_X = OR over i in 0..3 of
//                  ( entries[bank_num*4+i].address[11:4] == ld_paddr_X_offset
//                    AND entries[bank_num*4+i].address[14:12] == ld_paddr_X_pfn )
//                  & entries[bank_num*4+i].valid
//
//   valid_dep0 = bank_hit_0 & LD_OP
//   valid_dep1 = bank_hit_1 & LD_OP & LD_XCL
//   stall      = valid_dep0 | valid_dep1
//
// `valid` is on the port list to match the .sv reference but is not
// used in the original body and is unused here too.
//
// Critical-path notes:
//   - Pre-TLB phase A: all 16x CMP_N(8) offset comparisons start
//     immediately in parallel.  bank_num resolves from offset[1:0].
//   - Pre-TLB phase B: MUX_4(1) bank-selects the 4 offset_eq results
//     and the 4 valid bits per slot.  AND_2 pre-computes
//     pre_hit[i] = sel_off_eq[i] & sel_valid[i] before PFN arrives.
//     MUX_4(3) bank-selects the 3-bit PFN from STQ entries per slot
//     so the PFN mux fanout is resolved before the TLB finishes.
//   - Post-TLB: only 4x CMP_N(3) run (not 16), then a single
//     nand2$(pre_hit, cmp_pfn) per slot + nand4$ across the 4 slots
//     gives bank_hit (active-high).  NAND-only back end avoids the
//     implicit inverter inside and2_N$/or4_N$.
//     Post-TLB CP = CMP_N(3) -> nand2$ -> nand4$ -> nand2$ -> nand2$
//                 (4 NAND levels, all at ~0.20-0.25 ns each).
//   - LD_OP and LD_XCL are factored as the final ANDs after bank_hit
//     so the bank_hit critical path sees only the per-bank reduction.
// ----------------------------------------------------------------


module wb_stq_sb_logic (
    input  wire        valid,                // unused
    // Load 0: offset = paddr[11:4] (pre-TLB), pfn = paddr[14:12] (post-TLB)
    input  wire [7:0]  ld_paddr_0_offset,
    input  wire [2:0]  ld_paddr_0_pfn,
    // Load 1: offset = paddr[11:4] (pre-TLB), pfn = paddr[14:12] (post-TLB)
    input  wire [7:0]  ld_paddr_1_offset,
    input  wire [2:0]  ld_paddr_1_pfn,
    input  wire        LD_OP,
    input  wire        LD_XCL,

    // st_q_2_dep_check_outputs_t.entries[NUM_WB_ST_QS*ST_Q_DEPTH] flattened
    // into 16 individual scalar ports per field.
    // Convention: entry index e = bank b * ST_Q_DEPTH + slot i, so e in
    // 0..3   are bank 0 slots 0..3
    // 4..7   are bank 1 slots 0..3
    // 8..11  are bank 2 slots 0..3
    // 12..15 are bank 3 slots 0..3
    input  wire [14:0] stq_addr_0,
    input  wire [14:0] stq_addr_1,
    input  wire [14:0] stq_addr_2,
    input  wire [14:0] stq_addr_3,
    input  wire [14:0] stq_addr_4,
    input  wire [14:0] stq_addr_5,
    input  wire [14:0] stq_addr_6,
    input  wire [14:0] stq_addr_7,
    input  wire [14:0] stq_addr_8,
    input  wire [14:0] stq_addr_9,
    input  wire [14:0] stq_addr_10,
    input  wire [14:0] stq_addr_11,
    input  wire [14:0] stq_addr_12,
    input  wire [14:0] stq_addr_13,
    input  wire [14:0] stq_addr_14,
    input  wire [14:0] stq_addr_15,

    input  wire        stq_valid_0,
    input  wire        stq_valid_1,
    input  wire        stq_valid_2,
    input  wire        stq_valid_3,
    input  wire        stq_valid_4,
    input  wire        stq_valid_5,
    input  wire        stq_valid_6,
    input  wire        stq_valid_7,
    input  wire        stq_valid_8,
    input  wire        stq_valid_9,
    input  wire        stq_valid_10,
    input  wire        stq_valid_11,
    input  wire        stq_valid_12,
    input  wire        stq_valid_13,
    input  wire        stq_valid_14,
    input  wire        stq_valid_15,

    output wire        stall
);

    // ----------------------------------------------------------------
    // Gather the 16 scalar ports into internal arrays so the generate
    // loop can index them.  These are local wires, not port arrays.
    // V2005 unpacked-array form: [0:N-1] (the SV-only single-value
    // form [N] is not accepted).
    // ----------------------------------------------------------------
    wire [14:0] stq_addr  [0:`NUM_WB_ST_QS*`ST_Q_DEPTH-1];
    wire        stq_valid [0:`NUM_WB_ST_QS*`ST_Q_DEPTH-1];

    assign stq_addr[0]  = stq_addr_0;
    assign stq_addr[1]  = stq_addr_1;
    assign stq_addr[2]  = stq_addr_2;
    assign stq_addr[3]  = stq_addr_3;
    assign stq_addr[4]  = stq_addr_4;
    assign stq_addr[5]  = stq_addr_5;
    assign stq_addr[6]  = stq_addr_6;
    assign stq_addr[7]  = stq_addr_7;
    assign stq_addr[8]  = stq_addr_8;
    assign stq_addr[9]  = stq_addr_9;
    assign stq_addr[10] = stq_addr_10;
    assign stq_addr[11] = stq_addr_11;
    assign stq_addr[12] = stq_addr_12;
    assign stq_addr[13] = stq_addr_13;
    assign stq_addr[14] = stq_addr_14;
    assign stq_addr[15] = stq_addr_15;

    assign stq_valid[0]  = stq_valid_0;
    assign stq_valid[1]  = stq_valid_1;
    assign stq_valid[2]  = stq_valid_2;
    assign stq_valid[3]  = stq_valid_3;
    assign stq_valid[4]  = stq_valid_4;
    assign stq_valid[5]  = stq_valid_5;
    assign stq_valid[6]  = stq_valid_6;
    assign stq_valid[7]  = stq_valid_7;
    assign stq_valid[8]  = stq_valid_8;
    assign stq_valid[9]  = stq_valid_9;
    assign stq_valid[10] = stq_valid_10;
    assign stq_valid[11] = stq_valid_11;
    assign stq_valid[12] = stq_valid_12;
    assign stq_valid[13] = stq_valid_13;
    assign stq_valid[14] = stq_valid_14;
    assign stq_valid[15] = stq_valid_15;

    // ----------------------------------------------------------------
    // Bank num for each load
    //   $clog2(CACHE_LINES_SIZE_B)=4 (offset bits), $clog2(NUM_WB_ST_QS)=2
    //   so the bank-num slice is bits [5:4] of the physical address.
    // ----------------------------------------------------------------
    wire [1:0] ld0_bank_num;
    wire [1:0] ld1_bank_num;
    assign ld0_bank_num = ld_paddr_0_offset[1:0];
    assign ld1_bank_num = ld_paddr_1_offset[1:0];

    // ----------------------------------------------------------------
    // Pre-TLB phase A: 16x 8-bit offset comparisons, all in parallel.
    // ----------------------------------------------------------------
    wire cmp_off_0 [0:`NUM_WB_ST_QS*`ST_Q_DEPTH-1];
    wire cmp_off_1 [0:`NUM_WB_ST_QS*`ST_Q_DEPTH-1];

    // Pre-TLB phase B (per slot): bank-select offset_eq, valid, and the
    // 3-bit PFN field from STQ.  pre_hit[i] = sel_off_eq & sel_valid is
    // fully ready before TLB completes.
    wire [2:0] muxed_pfn_0  [0:`ST_Q_DEPTH-1];  // 3-bit PFN of selected bank
    wire [2:0] muxed_pfn_1  [0:`ST_Q_DEPTH-1];
    wire       sel_off_eq_0 [0:`ST_Q_DEPTH-1];  // bank-selected offset eq
    wire       sel_off_eq_1 [0:`ST_Q_DEPTH-1];
    wire       sel_valid_0  [0:`ST_Q_DEPTH-1];  // bank-selected entry valid
    wire       sel_valid_1  [0:`ST_Q_DEPTH-1];
    wire       pre_hit_0    [0:`ST_Q_DEPTH-1];  // sel_off_eq & sel_valid
    wire       pre_hit_1    [0:`ST_Q_DEPTH-1];

    // Post-TLB: only 4x 3-bit PFN comparisons (one per slot).
    // nand_match_n_X[i] = NAND2(pre_hit, cmp_pfn) -- active-low slot match.
    // bank_hit = NAND4(nand_match_n_0..3) -- active-high any-slot hit.
    wire       cmp_pfn_0       [0:`ST_Q_DEPTH-1];
    wire       cmp_pfn_1       [0:`ST_Q_DEPTH-1];
    wire       nand_match_n_0  [0:`ST_Q_DEPTH-1];
    wire       nand_match_n_1  [0:`ST_Q_DEPTH-1];

    genvar e, i;

    // ----------------------------------------------------------------
    // Pre-TLB phase A: 16x CMP_N(8) directly on all STQ entries.
    // ----------------------------------------------------------------
    generate
        for (e = 0; e < `NUM_WB_ST_QS*`ST_Q_DEPTH; e = e + 1) begin : g_off
            `CMP_N(u_cmp_off_0, 8, cmp_off_0[e], stq_addr[e][11:4], ld_paddr_0_offset)
            `CMP_N(u_cmp_off_1, 8, cmp_off_1[e], stq_addr[e][11:4], ld_paddr_1_offset)
        end
    endgenerate

    // ----------------------------------------------------------------
    // Pre-TLB phase B: per slot, bank-select offset_eq, valid, and the
    // 3-bit PFN candidate.  pre_hit[i] ready before TLB completes.
    // ----------------------------------------------------------------
    generate
        for (i = 0; i < `ST_Q_DEPTH; i = i + 1) begin : g_sel
            // 1-bit MUX_4: pick the offset_eq result from the correct bank
            `MUX_4(u_sel_off_0, 1, sel_off_eq_0[i],
                   cmp_off_0[0*`ST_Q_DEPTH+i], cmp_off_0[1*`ST_Q_DEPTH+i],
                   cmp_off_0[2*`ST_Q_DEPTH+i], cmp_off_0[3*`ST_Q_DEPTH+i],
                   ld0_bank_num)
            `MUX_4(u_sel_off_1, 1, sel_off_eq_1[i],
                   cmp_off_1[0*`ST_Q_DEPTH+i], cmp_off_1[1*`ST_Q_DEPTH+i],
                   cmp_off_1[2*`ST_Q_DEPTH+i], cmp_off_1[3*`ST_Q_DEPTH+i],
                   ld1_bank_num)

            // 1-bit MUX_4: pick the entry valid from the correct bank
            `MUX_4(u_sel_v0, 1, sel_valid_0[i],
                   stq_valid[0*`ST_Q_DEPTH+i], stq_valid[1*`ST_Q_DEPTH+i],
                   stq_valid[2*`ST_Q_DEPTH+i], stq_valid[3*`ST_Q_DEPTH+i],
                   ld0_bank_num)
            `MUX_4(u_sel_v1, 1, sel_valid_1[i],
                   stq_valid[0*`ST_Q_DEPTH+i], stq_valid[1*`ST_Q_DEPTH+i],
                   stq_valid[2*`ST_Q_DEPTH+i], stq_valid[3*`ST_Q_DEPTH+i],
                   ld1_bank_num)

            // 3-bit MUX_4: pick the PFN of the correct bank entry so only
            // 4 CMP_N(3) are needed post-TLB instead of 16.
            `MUX_4(u_sel_pfn_0, 3, muxed_pfn_0[i],
                   stq_addr[0*`ST_Q_DEPTH+i][14:12], stq_addr[1*`ST_Q_DEPTH+i][14:12],
                   stq_addr[2*`ST_Q_DEPTH+i][14:12], stq_addr[3*`ST_Q_DEPTH+i][14:12],
                   ld0_bank_num)
            `MUX_4(u_sel_pfn_1, 3, muxed_pfn_1[i],
                   stq_addr[0*`ST_Q_DEPTH+i][14:12], stq_addr[1*`ST_Q_DEPTH+i][14:12],
                   stq_addr[2*`ST_Q_DEPTH+i][14:12], stq_addr[3*`ST_Q_DEPTH+i][14:12],
                   ld1_bank_num)

            // Pre-combine offset_eq & valid before TLB finishes.
            `AND_2(u_pre_hit_0, 1, pre_hit_0[i], sel_off_eq_0[i], sel_valid_0[i])
            `AND_2(u_pre_hit_1, 1, pre_hit_1[i], sel_off_eq_1[i], sel_valid_1[i])

            // Post-TLB: 3-bit PFN compare then NAND2 with pre_hit.
            // nand_match_n = 0 when slot is a full address + valid hit.
            `CMP_N(u_cmp_pfn_0, 3, cmp_pfn_0[i], muxed_pfn_0[i], ld_paddr_0_pfn)
            `CMP_N(u_cmp_pfn_1, 3, cmp_pfn_1[i], muxed_pfn_1[i], ld_paddr_1_pfn)
            nand2$ u_nand_m0 (.out(nand_match_n_0[i]), .in0(pre_hit_0[i]), .in1(cmp_pfn_0[i]));
            nand2$ u_nand_m1 (.out(nand_match_n_1[i]), .in0(pre_hit_1[i]), .in1(cmp_pfn_1[i]));
        end
    endgenerate

    // ----------------------------------------------------------------
    // NAND4 across the 4 slots: bank_hit (active-high) =
    //   NAND4(nand_match_n[0..3]) = 1 when any slot's nand_match_n is 0
    //   = OR of all per-slot matches, implemented NAND-only.
    // ----------------------------------------------------------------
    wire ld0_bank_hit;
    wire ld1_bank_hit;
    nand4$ u_ld0_bank_hit (.out(ld0_bank_hit),
        .in0(nand_match_n_0[0]), .in1(nand_match_n_0[1]),
        .in2(nand_match_n_0[2]), .in3(nand_match_n_0[3]));
    nand4$ u_ld1_bank_hit (.out(ld1_bank_hit),
        .in0(nand_match_n_1[0]), .in1(nand_match_n_1[1]),
        .in2(nand_match_n_1[2]), .in3(nand_match_n_1[3]));

    // ----------------------------------------------------------------
    // valid_dep0 = bank_hit_0 & LD_OP
    // valid_dep1 = bank_hit_1 & LD_OP & LD_XCL
    // stall      = valid_dep0 | valid_dep1
    //
    // CP back-end uses NAND-NAND DeMorgan (and2$+or2$ chain = 0.70 ns
    // vs nand2$+nand2$ chain = 0.40 ns).  ld1_gate = LD_OP & LD_XCL is
    // computed off the bank_hit CP since LD_OP/LD_XCL are flop outputs
    // ready at clock edge.  The CP path is bank_hit -> nand2$ -> nand2$
    // -> stall (2 levels of nand2$ instead of and2$/and3$ + or2$).
    // ----------------------------------------------------------------
    wire ld1_gate;
    `AND_2(u_ld1_gate, 1, ld1_gate, LD_OP, LD_XCL)

    wire valid_dep0_n;
    wire valid_dep1_n;
    nand2$ u_valid_dep0_n (.out(valid_dep0_n), .in0(ld0_bank_hit), .in1(LD_OP));
    nand2$ u_valid_dep1_n (.out(valid_dep1_n), .in0(ld1_bank_hit), .in1(ld1_gate));
    nand2$ u_stall        (.out(stall),        .in0(valid_dep0_n), .in1(valid_dep1_n));

endmodule
