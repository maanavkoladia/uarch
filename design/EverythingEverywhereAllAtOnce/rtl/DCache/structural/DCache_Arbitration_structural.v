// Pure Verilog 2005 port of DCache_Arbitration.
// Reference: rtl/DCache/structural/DCache_Arbitration.sv
// All logic via STDCell macros. assign used only for wire aliasing /
// bit-replication / slicing. No package imports.
//
// Behavior (matches updated DCache_Arbitration.sv):
//   - If (memClrReq & reqs.oe) | (block_hit & reqs.we): the per-block
//     req latch is forced to 0 next cycle.
//   - Else if block_idleness (reqs.oe == 0 && reqs.we == 0): a new
//     req may be loaded (store priority via st_override / no-ld-present,
//     otherwise ld0 then ld1).
//   - Else: latch holds.
//
// Optimization notes:
//   - readyForNewReq == block_idleness only -> reqServed_0/1 do NOT
//     depend combinationally on block_hit_i or core_memClrReq_i.
//     (Old version OR'd those terms into readyForNewReq, putting hit
//      on the reqServed path.)
//   - block_idleness is a single NOR of the two registered req bits.
//   - clear_latch = OR of two AND-of-registered terms => one AND + one
//     OR from hit/memClr to the register WE pin. WE timing runs in
//     parallel with data-mux timing (REG_RST_WE).
//   - no_ld_present and not_st_sel are computed via direct NORs to
//     skip an extra inverter.
//   - clear_latch and any_new_req are mutually exclusive: clear_latch
//     requires reqs.oe|reqs.we==1; new-load requires block_idleness
//     (==NOR(oe,we)). So the latch sees a clean WE pulse with no
//     conflict, and the input data only needs to encode the new-req
//     case (clear case naturally produces 0 on oe/we).

module DCache_Arbitration (

    input wire clk_i,
    input wire rst,    // active low

    // flat expansion of core_2_dcache_t core_i
    input wire         core_ld_addr_0_V_i,
    input wire  [14:0] core_ld_addr_0_i,
    input wire         core_ld_addr_1_V_i,
    input wire  [14:0] core_ld_addr_1_i,
    input wire         core_stq_full_i   [`NUM_WB_ST_QS],
    input wire         core_stq_empty_i  [`NUM_WB_ST_QS],
    input wire  [14:0] core_stq_addr_i   [`NUM_WB_ST_QS],
    input wire  [15:0] core_stq_bitvec_i [`NUM_WB_ST_QS],
    input wire  [127:0] core_stq_data_i  [`NUM_WB_ST_QS],
    input wire         core_memClrReq_i  [`DCACHE_NUM_BLOCKS],

    input wire  block_hit_i [`DCACHE_NUM_BLOCKS],

    output wire reqServed_0_o,
    output wire reqServed_1_o,

    output wire         reqs_oe_o    [`DCACHE_NUM_BLOCKS],
    output wire         reqs_we_o    [`DCACHE_NUM_BLOCKS],
    output wire  [14:0] reqs_paddr_o [`DCACHE_NUM_BLOCKS],
    output wire  [15:0] reqs_vec_o   [`DCACHE_NUM_BLOCKS],
    output wire  [127:0] reqs_data_o [`DCACHE_NUM_BLOCKS],

    output wire st_override_o  [`NUM_WB_ST_QS],
    output wire writeSuccess_o [`NUM_WB_ST_QS]

);

    localparam LD_REQ_BANK_UB    = `DCACHE_BANK_BANK_UB;
    localparam LD_REQ_BANK_LB    = `DCACHE_BANK_BANK_LB;
    localparam LD_REQ_BANK_WIDTH = `DCACHE_BANK_BANK_WIDTH;

    wire [LD_REQ_BANK_WIDTH-1:0] ld_req_0_bankNum;
    wire [LD_REQ_BANK_WIDTH-1:0] ld_req_1_bankNum;
    assign ld_req_0_bankNum = core_ld_addr_0_i[LD_REQ_BANK_UB:LD_REQ_BANK_LB];
    assign ld_req_1_bankNum = core_ld_addr_1_i[LD_REQ_BANK_UB:LD_REQ_BANK_LB];

    wire        not_stq_empty   [`NUM_WB_ST_QS];
    wire        ld0_valid       [`DCACHE_NUM_BLOCKS];
    wire        ld1_valid       [`DCACHE_NUM_BLOCKS];
    wire        st_override_q   [`NUM_WB_ST_QS];
    wire        reqs_oe_q       [`DCACHE_NUM_BLOCKS];
    wire        reqs_we_q       [`DCACHE_NUM_BLOCKS];
    wire [14:0]  reqs_paddr_q   [`DCACHE_NUM_BLOCKS];
    wire [15:0]  reqs_vec_q     [`DCACHE_NUM_BLOCKS];
    wire [127:0] reqs_data_q    [`DCACHE_NUM_BLOCKS];

    genvar g_ne;
    generate
        for (g_ne = 0; g_ne < `NUM_WB_ST_QS; g_ne = g_ne + 1) begin : g_not_empty
            `INV_N(u_not_empty, 1, core_stq_empty_i[g_ne], not_stq_empty[g_ne])
        end
    endgenerate

    genvar g_i;
    generate
        for (g_i = 0; g_i < `DCACHE_NUM_BLOCKS; g_i = g_i + 1) begin : g_arb_block

            wire [LD_REQ_BANK_WIDTH-1:0] g_bank_const;
            assign g_bank_const = g_i;

            // ---------- bank match (ld inputs -> this bank?) ----------
            wire ld0_bank_match, ld1_bank_match;
            `CMP_N(u_ld0_match, 2, ld0_bank_match, ld_req_0_bankNum, g_bank_const)
            `CMP_N(u_ld1_match, 2, ld1_bank_match, ld_req_1_bankNum, g_bank_const)

            wire ld0_at_bank, ld1_at_bank;
            `AND_2(u_ld0_at_bank, 1, ld0_at_bank, core_ld_addr_0_V_i, ld0_bank_match)
            `AND_2(u_ld1_at_bank, 1, ld1_at_bank, core_ld_addr_1_V_i, ld1_bank_match)

            // no_ld_present = ~(ld0_at_bank | ld1_at_bank) -- single NOR
            wire no_ld_present;
            `NOR_2(u_no_ld_pres, 1, no_ld_present, ld0_at_bank, ld1_at_bank)

            // ---------- store-priority select ----------
            // Factored: st_sel = not_stq_empty & (st_override_q | no_ld_present)
            // Computing not_st_sel directly via NOR of the two component
            // AND-terms would need both to be available; the factored
            // form is one OR + one AND + one INV. We expose both st_sel
            // (for store_valid) and not_st_sel (for ld_valid).
            wire st_or_no_ld;
            `OR_2(u_st_or_no_ld, 1, st_or_no_ld, st_override_q[g_i], no_ld_present)
            wire st_sel;
            `AND_2(u_st_sel, 1, st_sel, not_stq_empty[g_i], st_or_no_ld)
            wire not_st_sel;
            `INV_N(u_not_st_sel, 1, st_sel, not_st_sel)

            // ---------- block_idleness (registered) ----------
            // = ~(reqs.oe | reqs.we) -- single NOR. This is the single
            // gate from the two req-latch outputs that gates everything.
            wire block_idleness;
            `NOR_2(u_idle, 1, block_idleness, reqs_oe_q[g_i], reqs_we_q[g_i])

            // ---------- valids (decide which new req fires this cycle)
            // These do NOT depend on block_hit_i / core_memClrReq_i.
            wire not_ld0_at_bank, store_valid_w;
            `INV_N(u_not_ld0,     1, ld0_at_bank,    not_ld0_at_bank)
            `AND_2(u_store_valid, 1, store_valid_w,  block_idleness, st_sel)
            `AND_3(u_ld0_valid,   1, ld0_valid[g_i], block_idleness, not_st_sel, ld0_at_bank)
            `AND_4(u_ld1_valid, 1, ld1_valid[g_i],
                   block_idleness, not_st_sel, not_ld0_at_bank, ld1_at_bank)

            // ---------- clear-latch (memClr/hit kill an active req) ----
            // Only one AND-gate from the late hit/memClr signals.
            wire clr_oe, clr_we, clear_latch;
            `AND_2(u_clr_oe, 1, clr_oe, core_memClrReq_i[g_i], reqs_oe_q[g_i])
            `AND_2(u_clr_we, 1, clr_we, block_hit_i[g_i],      reqs_we_q[g_i])
            `OR_2(u_clr,     1, clear_latch, clr_oe, clr_we)

            // ---------- WE pulse to req latches ----------
            // clear_latch and any_new_req are mutually exclusive:
            //   clear_latch ==> (reqs.oe | reqs.we) == 1 ==> block_idleness == 0
            //                   ==> store_valid_w/ld0_valid/ld1_valid all 0
            // So the WE pulse cleanly distinguishes the two cases by
            // which input data evaluates to non-zero -- no need to gate
            // the data path with clear_latch.
            wire any_new_req, latch_we;
            `OR_3(u_any_new, 1, any_new_req, store_valid_w, ld0_valid[g_i], ld1_valid[g_i])
            `OR_2(u_latch_we, 1, latch_we, clear_latch, any_new_req)

            // ---------- next-state data into the req latches ----------
            // oe: high only on a new ld; clear case yields 0 naturally.
            // we: high only on a new store; clear case yields 0 naturally.
            wire nextReqs_oe;
            `OR_2(u_next_oe, 1, nextReqs_oe, ld0_valid[g_i], ld1_valid[g_i])
            wire nextReqs_we;
            assign nextReqs_we = store_valid_w;

            // paddr: pick the live source via per-source mask + OR.
            // Only one of {store_valid_w, ld0_valid, ld1_valid} can be
            // high at a time, so the OR is a real one-hot mux.
            wire [14:0] paddr_st_g, paddr_ld0_g, paddr_ld1_g, nextReqs_paddr;
            wire [14:0] store_valid_15, ld0_valid_15, ld1_valid_15;
            assign store_valid_15 = {15{store_valid_w}};
            assign ld0_valid_15   = {15{ld0_valid[g_i]}};
            assign ld1_valid_15   = {15{ld1_valid[g_i]}};
            `AND_2(u_pa_st,  15, paddr_st_g,  core_stq_addr_i[g_i], store_valid_15)
            `AND_2(u_pa_ld0, 15, paddr_ld0_g, core_ld_addr_0_i,     ld0_valid_15)
            `AND_2(u_pa_ld1, 15, paddr_ld1_g, core_ld_addr_1_i,     ld1_valid_15)
            `OR_3(u_next_pa, 15, nextReqs_paddr, paddr_st_g, paddr_ld0_g, paddr_ld1_g)

            // vec/data: only the store path contributes; ld carries 0s.
            wire [15:0]  nextReqs_vec, store_valid_16;
            wire [127:0] nextReqs_data, store_valid_128;
            assign store_valid_16  = {16{store_valid_w}};
            assign store_valid_128 = {128{store_valid_w}};
            `AND_2(u_next_vec, 16,  nextReqs_vec,  core_stq_bitvec_i[g_i], store_valid_16)
            `AND_2(u_next_dat, 128, nextReqs_data, core_stq_data_i[g_i],   store_valid_128)

            // ---------- registers: WE-gated REG_RST_WE ----------
            `REG_RST_WE(u_reg_oe,  1,   clk_i, rst, latch_we, nextReqs_oe,    reqs_oe_q[g_i])
            `REG_RST_WE(u_reg_we,  1,   clk_i, rst, latch_we, nextReqs_we,    reqs_we_q[g_i])
            `REG_RST_WE(u_reg_pa,  15,  clk_i, rst, latch_we, nextReqs_paddr, reqs_paddr_q[g_i])
            `REG_RST_WE(u_reg_vec, 16,  clk_i, rst, latch_we, nextReqs_vec,   reqs_vec_q[g_i])
            `REG_RST_WE(u_reg_dat, 128, clk_i, rst, latch_we, nextReqs_data,  reqs_data_q[g_i])

            assign reqs_oe_o[g_i]      = reqs_oe_q[g_i];
            assign reqs_we_o[g_i]      = reqs_we_q[g_i];
            assign reqs_paddr_o[g_i]   = reqs_paddr_q[g_i];
            assign reqs_vec_o[g_i]     = reqs_vec_q[g_i];
            assign reqs_data_o[g_i]    = reqs_data_q[g_i];

            assign writeSuccess_o[g_i] = store_valid_w;

        end
    endgenerate

    // ---------- store-override per st_q ----------
    // st_override sticks high on full, clears on empty, holds otherwise.
    // d = stq_full | (not_stq_empty & st_override_q)
    genvar g_st;
    generate
        for (g_st = 0; g_st < `NUM_WB_ST_QS; g_st = g_st + 1) begin : g_st_override
            wire keep_ov, st_override_d;
            `AND_2(u_keep_ov, 1, keep_ov,       not_stq_empty[g_st], st_override_q[g_st])
            `OR_2(u_ov_d,     1, st_override_d, core_stq_full_i[g_st], keep_ov)
            `REG_RST(u_ov_reg, 1, clk_i, rst, st_override_d, st_override_q[g_st])
            assign st_override_o[g_st] = st_override_q[g_st];
        end
    endgenerate

    // ---------- aggregate reqServed ----------
    // Per the new behavior these depend ONLY on registered block_idleness,
    // registered st_override_q, the load-V/bank-match inputs, and stq_empty.
    // They are independent of block_hit_i and core_memClrReq_i.
    `OR_4(u_reqServed_0, 1, reqServed_0_o, ld0_valid[0], ld0_valid[1], ld0_valid[2], ld0_valid[3])
    `OR_4(u_reqServed_1, 1, reqServed_1_o, ld1_valid[0], ld1_valid[1], ld1_valid[2], ld1_valid[3])

endmodule
