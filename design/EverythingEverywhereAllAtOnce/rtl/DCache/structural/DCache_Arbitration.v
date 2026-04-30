// Structural Verilog-2005 port of rtl/DCache/DCache_Arbitration.sv

`include "STDCell_Macros.vh"
`include "DCache_common_define.vh"

module DCache_Arbitration (
    input  wire                                         clk_i,
    input  wire                                         rst,                  // active-low
    input  wire [`C2D_W                       - 1 : 0]  core_i,
    input  wire [`DCACHE_NUM_BLOCKS           - 1 : 0]  block_hit_i,
    output wire                                         reqServed_0_o,
    output wire                                         reqServed_1_o,
    output wire [`DCACHE_NUM_BLOCKS*`BREQ_W   - 1 : 0]  reqs_2_blocks_o,
    output wire [`DCACHE_NUM_BLOCKS           - 1 : 0]  st_override_o,
    output wire [`DCACHE_NUM_BLOCKS           - 1 : 0]  writeSuccess_o
);

    //==================================================================
    // core_2_dcache_t field extraction
    //==================================================================
    wire        ld0_V;
    wire [`P_ADDR_W - 1 : 0]  ld0_addr;
    wire        ld1_V;
    wire [`P_ADDR_W - 1 : 0]  ld1_addr;
    assign ld0_V    = core_i[`C2D_LD0_V];
    assign ld0_addr = core_i[`C2D_LD0_UB:`C2D_LD0_LB];
    assign ld1_V    = core_i[`C2D_LD1_V];
    assign ld1_addr = core_i[`C2D_LD1_UB:`C2D_LD1_LB];

    wire [3:0] memStage_CLR_REQ;
    assign memStage_CLR_REQ = core_i[`C2D_CLR_REQ_UB:`C2D_CLR_REQ_LB];

    //   stq_heads[i] : 161 bits each
    wire [`STQ_W - 1 : 0] stq_h0;
    wire [`STQ_W - 1 : 0] stq_h1;
    wire [`STQ_W - 1 : 0] stq_h2;
    wire [`STQ_W - 1 : 0] stq_h3;
    assign stq_h0 = core_i[`C2D_STQ_UB(0):`C2D_STQ_LB(0)];
    assign stq_h1 = core_i[`C2D_STQ_UB(1):`C2D_STQ_LB(1)];
    assign stq_h2 = core_i[`C2D_STQ_UB(2):`C2D_STQ_LB(2)];
    assign stq_h3 = core_i[`C2D_STQ_UB(3):`C2D_STQ_LB(3)];

    //==================================================================
    // Per-block stq field views
    //==================================================================
    wire [3:0] stq_full;
    wire [3:0] stq_empty;
    assign stq_full[0]  = stq_h0[`STQ_FULL];
    assign stq_full[1]  = stq_h1[`STQ_FULL];
    assign stq_full[2]  = stq_h2[`STQ_FULL];
    assign stq_full[3]  = stq_h3[`STQ_FULL];
    assign stq_empty[0] = stq_h0[`STQ_EMPTY];
    assign stq_empty[1] = stq_h1[`STQ_EMPTY];
    assign stq_empty[2] = stq_h2[`STQ_EMPTY];
    assign stq_empty[3] = stq_h3[`STQ_EMPTY];

    //==================================================================
    // st_override flop : full sets, empty clears
    //   D = full ; WE = full | empty
    //==================================================================
    wire [3:0] stq_we;
    `OR_2(or_stq_we, 4, stq_we, stq_full, stq_empty)

    wire [3:0] st_override_q;
    //   Per-bit st_override flops (D=full, WE=full|empty) declared near
    //   bottom of module (ff_sov_b0..b3).

    //==================================================================
    // reqs[4] flops : 161 bits each, WE always (samples nextReqs)
    //==================================================================
    wire [`BREQ_W - 1 : 0] reqs_q[0:3];
    wire [`BREQ_W - 1 : 0] nextReqs[0:3];

    // ld_req bank decode (2-bit bank field of ld_addr_X is bits [5:4])
    wire [`DCACHE_BANK_BANK_W - 1 : 0] ld0_bank;
    wire [`DCACHE_BANK_BANK_W - 1 : 0] ld1_bank;
    assign ld0_bank = ld0_addr[`DCACHE_BANK_BANK_UB:`DCACHE_BANK_BANK_LB];
    assign ld1_bank = ld1_addr[`DCACHE_BANK_BANK_UB:`DCACHE_BANK_BANK_LB];

    wire [3:0] ld0_bank_dec;
    wire [3:0] ld1_bank_dec;
    `DECODER_N(u_dec_ld0, 2, ld0_bank, ld0_bank_dec)
    `DECODER_N(u_dec_ld1, 2, ld1_bank, ld1_bank_dec)

    wire [3:0] ld0_v_v;
    wire [3:0] ld1_v_v;
    assign ld0_v_v = {4{ld0_V}};
    assign ld1_v_v = {4{ld1_V}};

    wire [3:0] bank_match_0;
    wire [3:0] bank_match_1;
    `AND_2(and_bm0, 4, bank_match_0, ld0_v_v, ld0_bank_dec)
    `AND_2(and_bm1, 4, bank_match_1, ld1_v_v, ld1_bank_dec)

    wire [3:0] ldReq_2_BankPresent;
    `OR_2(or_ldreq, 4, ldReq_2_BankPresent, bank_match_0, bank_match_1)
    wire [3:0] ldReq_2_BankPresent_inv;
    `INV_N(inv_ldreq, 4, ldReq_2_BankPresent, ldReq_2_BankPresent_inv)

    //==================================================================
    // Per-block decode
    //==================================================================
    wire [3:0] reqs_oe;
    wire [3:0] reqs_we;
    assign reqs_oe[0] = reqs_q[0][`BREQ_OE];
    assign reqs_oe[1] = reqs_q[1][`BREQ_OE];
    assign reqs_oe[2] = reqs_q[2][`BREQ_OE];
    assign reqs_oe[3] = reqs_q[3][`BREQ_OE];
    assign reqs_we[0] = reqs_q[0][`BREQ_WE];
    assign reqs_we[1] = reqs_q[1][`BREQ_WE];
    assign reqs_we[2] = reqs_q[2][`BREQ_WE];
    assign reqs_we[3] = reqs_q[3][`BREQ_WE];

    //   block_idleness[i] = ~we & ~oe
    wire [3:0] reqs_oe_inv;
    wire [3:0] reqs_we_inv;
    `INV_N(inv_reqs_oe, 4, reqs_oe, reqs_oe_inv)
    `INV_N(inv_reqs_we, 4, reqs_we, reqs_we_inv)

    wire [3:0] block_idleness;
    `AND_2(and_idleness, 4, block_idleness, reqs_oe_inv, reqs_we_inv)

    //   readyForNewReq[i] = (clr_req[i] & oe[i]) | (we[i] & hit[i]) | idleness[i]
    wire [3:0] rdy_clr_term;
    wire [3:0] rdy_we_term;
    wire [3:0] rdy_pre;
    wire [3:0] readyForNewReq;
    `AND_2(and_rdy_clr, 4, rdy_clr_term, memStage_CLR_REQ, reqs_oe)
    `AND_2(and_rdy_we,  4, rdy_we_term,  reqs_we,          block_hit_i)
    `OR_2 (or_rdy_pre,  4, rdy_pre,      rdy_clr_term,     rdy_we_term)
    `OR_2 (or_rdy,      4, readyForNewReq, rdy_pre,        block_idleness)

    //==================================================================
    // store-fire / ld0-fire / ld1-fire conditions
    //   store_fire_cond[i] = ~empty[i] & (st_override[i] | ~ldReq_2_BankPresent[i])
    //   ld0_fire_cond[i]   = ~store_fire_cond[i] & bank_match_0[i]
    //   ld1_fire_cond[i]   = ~store_fire_cond[i] & ~bank_match_0[i] & bank_match_1[i]
    //==================================================================
    wire [3:0] stq_empty_inv;
    `INV_N(inv_stq_empty, 4, stq_empty, stq_empty_inv)

    wire [3:0] sov_or_noldreq;
    `OR_2(or_sov_noldreq, 4, sov_or_noldreq, st_override_q, ldReq_2_BankPresent_inv)

    wire [3:0] store_fire_cond;
    `AND_2(and_store_fire, 4, store_fire_cond, stq_empty_inv, sov_or_noldreq)
    wire [3:0] store_fire_cond_inv;
    `INV_N(inv_store_fire, 4, store_fire_cond, store_fire_cond_inv)

    wire [3:0] ld0_fire_cond;
    `AND_2(and_ld0_fire, 4, ld0_fire_cond, store_fire_cond_inv, bank_match_0)
    wire [3:0] bank_match_0_inv;
    `INV_N(inv_bm0, 4, bank_match_0, bank_match_0_inv)
    wire [3:0] ld1_pre;
    `AND_2(and_ld1_pre, 4, ld1_pre, store_fire_cond_inv, bank_match_0_inv)
    wire [3:0] ld1_fire_cond;
    `AND_2(and_ld1_fire, 4, ld1_fire_cond, ld1_pre, bank_match_1)

    //==================================================================
    // Build path values
    //==================================================================
    //   store_val[i] = {data, vec, p_addr, we=1, oe=0}
    wire [`BREQ_W - 1 : 0] store_val_0;
    wire [`BREQ_W - 1 : 0] store_val_1;
    wire [`BREQ_W - 1 : 0] store_val_2;
    wire [`BREQ_W - 1 : 0] store_val_3;
    assign store_val_0 = { stq_h0[`STQ_DATA_UB:`STQ_DATA_LB],
                           stq_h0[`STQ_VEC_UB:`STQ_VEC_LB],
                           stq_h0[`STQ_ADDR_UB:`STQ_ADDR_LB],
                           1'b1, 1'b0 };
    assign store_val_1 = { stq_h1[`STQ_DATA_UB:`STQ_DATA_LB],
                           stq_h1[`STQ_VEC_UB:`STQ_VEC_LB],
                           stq_h1[`STQ_ADDR_UB:`STQ_ADDR_LB],
                           1'b1, 1'b0 };
    assign store_val_2 = { stq_h2[`STQ_DATA_UB:`STQ_DATA_LB],
                           stq_h2[`STQ_VEC_UB:`STQ_VEC_LB],
                           stq_h2[`STQ_ADDR_UB:`STQ_ADDR_LB],
                           1'b1, 1'b0 };
    assign store_val_3 = { stq_h3[`STQ_DATA_UB:`STQ_DATA_LB],
                           stq_h3[`STQ_VEC_UB:`STQ_VEC_LB],
                           stq_h3[`STQ_ADDR_UB:`STQ_ADDR_LB],
                           1'b1, 1'b0 };

    //   ld0_val / ld1_val (same for every block; vec=0, data=0)
    wire [`BREQ_W - 1 : 0] ld0_val;
    wire [`BREQ_W - 1 : 0] ld1_val;
    assign ld0_val = { 128'b0, 16'b0, ld0_addr, 1'b0, 1'b1 };
    assign ld1_val = { 128'b0, 16'b0, ld1_addr, 1'b0, 1'b1 };

    //==================================================================
    // Build per-block nextReq via priority cascade:
    //   bottom = 0
    //   x = ld1_fire ? ld1_val : 0
    //   y = ld0_fire ? ld0_val : x
    //   z = store_fire ? store_val[i] : y
    //   nextReqs[i] = ready ? z : reqs[i]
    //==================================================================
    wire [`BREQ_W - 1 : 0] x_b0, x_b1, x_b2, x_b3;
    wire [`BREQ_W - 1 : 0] y_b0, y_b1, y_b2, y_b3;
    wire [`BREQ_W - 1 : 0] z_b0, z_b1, z_b2, z_b3;

    `MUX_2(mux_x_b0, `BREQ_W, x_b0, {`BREQ_W{1'b0}}, ld1_val,     ld1_fire_cond[0])
    `MUX_2(mux_x_b1, `BREQ_W, x_b1, {`BREQ_W{1'b0}}, ld1_val,     ld1_fire_cond[1])
    `MUX_2(mux_x_b2, `BREQ_W, x_b2, {`BREQ_W{1'b0}}, ld1_val,     ld1_fire_cond[2])
    `MUX_2(mux_x_b3, `BREQ_W, x_b3, {`BREQ_W{1'b0}}, ld1_val,     ld1_fire_cond[3])

    `MUX_2(mux_y_b0, `BREQ_W, y_b0, x_b0,            ld0_val,     ld0_fire_cond[0])
    `MUX_2(mux_y_b1, `BREQ_W, y_b1, x_b1,            ld0_val,     ld0_fire_cond[1])
    `MUX_2(mux_y_b2, `BREQ_W, y_b2, x_b2,            ld0_val,     ld0_fire_cond[2])
    `MUX_2(mux_y_b3, `BREQ_W, y_b3, x_b3,            ld0_val,     ld0_fire_cond[3])

    `MUX_2(mux_z_b0, `BREQ_W, z_b0, y_b0,            store_val_0, store_fire_cond[0])
    `MUX_2(mux_z_b1, `BREQ_W, z_b1, y_b1,            store_val_1, store_fire_cond[1])
    `MUX_2(mux_z_b2, `BREQ_W, z_b2, y_b2,            store_val_2, store_fire_cond[2])
    `MUX_2(mux_z_b3, `BREQ_W, z_b3, y_b3,            store_val_3, store_fire_cond[3])

    `MUX_2(mux_next_b0, `BREQ_W, nextReqs[0], reqs_q[0], z_b0, readyForNewReq[0])
    `MUX_2(mux_next_b1, `BREQ_W, nextReqs[1], reqs_q[1], z_b1, readyForNewReq[1])
    `MUX_2(mux_next_b2, `BREQ_W, nextReqs[2], reqs_q[2], z_b2, readyForNewReq[2])
    `MUX_2(mux_next_b3, `BREQ_W, nextReqs[3], reqs_q[3], z_b3, readyForNewReq[3])

    //==================================================================
    // reqs flops (always-WE, REG_RST suffices)
    //==================================================================
    `REG_RST(ff_reqs_b0, `BREQ_W, clk_i, rst, nextReqs[0], reqs_q[0])
    `REG_RST(ff_reqs_b1, `BREQ_W, clk_i, rst, nextReqs[1], reqs_q[1])
    `REG_RST(ff_reqs_b2, `BREQ_W, clk_i, rst, nextReqs[2], reqs_q[2])
    `REG_RST(ff_reqs_b3, `BREQ_W, clk_i, rst, nextReqs[3], reqs_q[3])

    //==================================================================
    // st_override flops : per-bit (D=full, WE=full|empty)
    //==================================================================
    `REG_RST_WE(ff_sov_b0, 1, clk_i, rst, stq_we[0], stq_full[0], st_override_q[0])
    `REG_RST_WE(ff_sov_b1, 1, clk_i, rst, stq_we[1], stq_full[1], st_override_q[1])
    `REG_RST_WE(ff_sov_b2, 1, clk_i, rst, stq_we[2], stq_full[2], st_override_q[2])
    `REG_RST_WE(ff_sov_b3, 1, clk_i, rst, stq_we[3], stq_full[3], st_override_q[3])

    //==================================================================
    // writeSuccess_o[i] = readyForNewReq[i] & store_fire_cond[i]
    //==================================================================
    `AND_2(and_writesucc, 4, writeSuccess_o, readyForNewReq, store_fire_cond)

    //==================================================================
    // reqServed_X_o = OR over blocks of (readyForNewReq[i] & ldX_fire_cond[i])
    //==================================================================
    wire [3:0] rs0_per_block;
    wire [3:0] rs1_per_block;
    `AND_2(and_rs0, 4, rs0_per_block, readyForNewReq, ld0_fire_cond)
    `AND_2(and_rs1, 4, rs1_per_block, readyForNewReq, ld1_fire_cond)

    wire rs0_a, rs0_b;
    wire rs1_a, rs1_b;
    `OR_2(or_rs0_a, 1, rs0_a, rs0_per_block[0], rs0_per_block[1])
    `OR_2(or_rs0_b, 1, rs0_b, rs0_per_block[2], rs0_per_block[3])
    `OR_2(or_rs0,   1, reqServed_0_o, rs0_a, rs0_b)
    `OR_2(or_rs1_a, 1, rs1_a, rs1_per_block[0], rs1_per_block[1])
    `OR_2(or_rs1_b, 1, rs1_b, rs1_per_block[2], rs1_per_block[3])
    `OR_2(or_rs1,   1, reqServed_1_o, rs1_a, rs1_b)

    //==================================================================
    // Output bus assembly
    //==================================================================
    assign reqs_2_blocks_o[`BREQ_W*1-1:`BREQ_W*0] = reqs_q[0];
    assign reqs_2_blocks_o[`BREQ_W*2-1:`BREQ_W*1] = reqs_q[1];
    assign reqs_2_blocks_o[`BREQ_W*3-1:`BREQ_W*2] = reqs_q[2];
    assign reqs_2_blocks_o[`BREQ_W*4-1:`BREQ_W*3] = reqs_q[3];

    assign st_override_o = st_override_q;

endmodule
