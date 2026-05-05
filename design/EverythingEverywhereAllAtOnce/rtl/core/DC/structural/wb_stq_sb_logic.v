// ----------------------------------------------------------------
// wb_stq_sb_logic -- structural Verilog 2005 port.
//
// Reference: rtl/core/DC/wb_stq_sb_logic.sv
//
//   16 store-queue entries are organized as NUM_WB_ST_QS=4 banks,
//   each ST_Q_DEPTH=4 entries deep.  For each load (0 and 1):
//     bank_num = ld_paddr_X[5:4]
//     bank_hit_X = OR over i in 0..3 of
//                  ( entries[bank_num*4+i].address[14:4]
//                      == ld_paddr_X[14:4] )
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
//   - For each load, mux 16 -> 4 entries first using the 2-bit
//     bank_num, then 4x CMP_N on the muxed addresses.  This keeps the
//     compare width at 11 bits and the OR fan-in at 4 (vs. comparing
//     all 16 entries up front and OR-reducing 16 results).
//   - LD_OP and LD_XCL are factored as the final ANDs after bank_hit
//     so the bank_hit critical path sees only the per-bank reduction.
// ----------------------------------------------------------------


module wb_stq_sb_logic (
    input  wire        valid,                // unused
    input  wire [14:0] ld_paddr_0,
    input  wire [14:0] ld_paddr_1,
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
    assign ld0_bank_num = ld_paddr_0[5:4];
    assign ld1_bank_num = ld_paddr_1[5:4];

    // ----------------------------------------------------------------
    // Per-slot 16->4 mux for each load.
    //   slot i:  pick entries[bank_num*4 + i].address[14:4] and .valid
    //            from the 4 banks via MUX_4 selected by ld_bank_num.
    // Then compare and AND with valid.
    // ----------------------------------------------------------------
    wire [10:0] muxed_addr_0  [0:`ST_Q_DEPTH-1];
    wire [10:0] muxed_addr_1  [0:`ST_Q_DEPTH-1];
    wire        muxed_valid_0 [0:`ST_Q_DEPTH-1];
    wire        muxed_valid_1 [0:`ST_Q_DEPTH-1];
    wire        cmp_0         [0:`ST_Q_DEPTH-1];
    wire        cmp_1         [0:`ST_Q_DEPTH-1];
    wire        match_0       [0:`ST_Q_DEPTH-1];
    wire        match_1       [0:`ST_Q_DEPTH-1];

    genvar i;
    generate
        for (i = 0; i < `ST_Q_DEPTH; i = i + 1) begin : g_slot
            // Address slices [14:4] for the 4 entries at slot i, one per bank
            wire [10:0] a0_slot, a1_slot, a2_slot, a3_slot;
            assign a0_slot = stq_addr[0*`ST_Q_DEPTH + i][14:4];
            assign a1_slot = stq_addr[1*`ST_Q_DEPTH + i][14:4];
            assign a2_slot = stq_addr[2*`ST_Q_DEPTH + i][14:4];
            assign a3_slot = stq_addr[3*`ST_Q_DEPTH + i][14:4];

            // Valids for the 4 entries at slot i
            wire v0_slot, v1_slot, v2_slot, v3_slot;
            assign v0_slot = stq_valid[0*`ST_Q_DEPTH + i];
            assign v1_slot = stq_valid[1*`ST_Q_DEPTH + i];
            assign v2_slot = stq_valid[2*`ST_Q_DEPTH + i];
            assign v3_slot = stq_valid[3*`ST_Q_DEPTH + i];

            // Mux to the bank selected by ld0_bank_num / ld1_bank_num
            `MUX_4(u_mux_addr_0,  11, muxed_addr_0[i],
                   a0_slot, a1_slot, a2_slot, a3_slot, ld0_bank_num)
            `MUX_4(u_mux_addr_1,  11, muxed_addr_1[i],
                   a0_slot, a1_slot, a2_slot, a3_slot, ld1_bank_num)

            `MUX_4(u_mux_valid_0, 1, muxed_valid_0[i],
                   v0_slot, v1_slot, v2_slot, v3_slot, ld0_bank_num)
            `MUX_4(u_mux_valid_1, 1, muxed_valid_1[i],
                   v0_slot, v1_slot, v2_slot, v3_slot, ld1_bank_num)

            // Compare muxed entry address vs load address (bits [14:4])
            `CMP_N(u_cmp_0, 11, cmp_0[i], muxed_addr_0[i], ld_paddr_0[14:4])
            `CMP_N(u_cmp_1, 11, cmp_1[i], muxed_addr_1[i], ld_paddr_1[14:4])

            // Match = address-eq AND entry-valid
            `AND_2(u_match_0, 1, match_0[i], cmp_0[i], muxed_valid_0[i])
            `AND_2(u_match_1, 1, match_1[i], cmp_1[i], muxed_valid_1[i])
        end
    endgenerate

    // ----------------------------------------------------------------
    // OR_4 across the 4 slots in the selected bank
    // ----------------------------------------------------------------
    wire ld0_bank_hit;
    wire ld1_bank_hit;
    `OR_4(u_ld0_bank_hit, 1, ld0_bank_hit,
          match_0[0], match_0[1], match_0[2], match_0[3])
    `OR_4(u_ld1_bank_hit, 1, ld1_bank_hit,
          match_1[0], match_1[1], match_1[2], match_1[3])

    // ----------------------------------------------------------------
    // valid_dep0 = bank_hit_0 & LD_OP
    // valid_dep1 = bank_hit_1 & LD_OP & LD_XCL
    // stall      = valid_dep0 | valid_dep1
    // ----------------------------------------------------------------
    wire valid_dep0;
    wire valid_dep1;
    `AND_2(u_valid_dep0, 1, valid_dep0, ld0_bank_hit, LD_OP)
    `AND_3(u_valid_dep1, 1, valid_dep1, ld1_bank_hit, LD_OP, LD_XCL)
    `OR_2 (u_stall,      1, stall,      valid_dep0, valid_dep1)

endmodule
