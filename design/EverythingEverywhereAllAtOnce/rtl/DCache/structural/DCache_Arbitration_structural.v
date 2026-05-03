// Pure Verilog 2005 port of DCache_Arbitration.
// Reference: rtl/DCache/structural/DCache_Arbitration.sv
// All logic via STDCell macros. assign used only for wire aliasing /
// bit-replication / slicing. No package imports.

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

    wire        not_stq_empty  [`NUM_WB_ST_QS];
    wire        ld0_valid      [`DCACHE_NUM_BLOCKS];
    wire        ld1_valid      [`DCACHE_NUM_BLOCKS];
    wire        st_override_q  [`NUM_WB_ST_QS];
    wire        reqs_oe_q      [`DCACHE_NUM_BLOCKS];
    wire        reqs_we_q      [`DCACHE_NUM_BLOCKS];
    wire [14:0]  reqs_paddr_q  [`DCACHE_NUM_BLOCKS];
    wire [15:0]  reqs_vec_q    [`DCACHE_NUM_BLOCKS];
    wire [127:0] reqs_data_q   [`DCACHE_NUM_BLOCKS];

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

            wire block_idleness;
            `NOR_2(u_idle, 1, block_idleness, reqs_we_q[g_i], reqs_oe_q[g_i])

            wire clr_and_oe, we_and_hit, readyForNewReq;
            `AND_2(u_clr_and_oe, 1, clr_and_oe,    core_memClrReq_i[g_i], reqs_oe_q[g_i])
            `AND_2(u_we_and_hit, 1, we_and_hit,    reqs_we_q[g_i],        block_hit_i[g_i])
            `OR_3(u_rfnr,        1, readyForNewReq, clr_and_oe, we_and_hit, block_idleness)

            wire ld0_bank_match, ld1_bank_match;
            `CMP_N(u_ld0_match, 2, ld0_bank_match, ld_req_0_bankNum, g_bank_const)
            `CMP_N(u_ld1_match, 2, ld1_bank_match, ld_req_1_bankNum, g_bank_const)

            wire ld0_at_bank, ld1_at_bank, ldReq_2_BankPresent;
            `AND_2(u_ld0_at_bank, 1, ld0_at_bank,         core_ld_addr_0_V_i, ld0_bank_match)
            `AND_2(u_ld1_at_bank, 1, ld1_at_bank,         core_ld_addr_1_V_i, ld1_bank_match)
            `OR_2(u_ldPresent,    1, ldReq_2_BankPresent,  ld0_at_bank,        ld1_at_bank)

            wire st_override_sel, no_ld_present, no_ld_sel, st_sel;
            `AND_2(u_st_ov_sel,  1, st_override_sel, st_override_q[g_i],   not_stq_empty[g_i])
            `INV_N(u_no_ld_pres, 1, ldReq_2_BankPresent,                   no_ld_present)
            `AND_2(u_no_ld_sel,  1, no_ld_sel,        no_ld_present,       not_stq_empty[g_i])
            `OR_2(u_st_sel,      1, st_sel,            st_override_sel,     no_ld_sel)

            wire not_st_sel, not_ld0_at_bank, store_valid_w, keep_valid;
            `INV_N(u_not_st_sel,  1, st_sel,        not_st_sel)
            `INV_N(u_not_ld0,     1, ld0_at_bank,   not_ld0_at_bank)
            `AND_2(u_store_valid, 1, store_valid_w,   readyForNewReq, st_sel)
            `AND_3(u_ld0_valid,   1, ld0_valid[g_i],  readyForNewReq, not_st_sel,     ld0_at_bank)
            `AND_4(u_ld1_valid,   1, ld1_valid[g_i],  readyForNewReq, not_st_sel,     not_ld0_at_bank, ld1_at_bank)
            `INV_N(u_keep_valid,  1, readyForNewReq,  keep_valid)

            wire [14:0]  store_valid_15, ld0_valid_15, ld1_valid_15, keep_valid_15;
            wire [15:0]  store_valid_16, keep_valid_16;
            wire [127:0] store_valid_128, keep_valid_128;
            assign store_valid_15  = {15{store_valid_w}};
            assign ld0_valid_15    = {15{ld0_valid[g_i]}};
            assign ld1_valid_15    = {15{ld1_valid[g_i]}};
            assign keep_valid_15   = {15{keep_valid}};
            assign store_valid_16  = {16{store_valid_w}};
            assign keep_valid_16   = {16{keep_valid}};
            assign store_valid_128 = {128{store_valid_w}};
            assign keep_valid_128  = {128{keep_valid}};

            wire oe_new, oe_keep_gated, nextReqs_oe;
            `OR_2(u_oe_new,   1, oe_new,        ld0_valid[g_i], ld1_valid[g_i])
            `AND_2(u_oe_keep, 1, oe_keep_gated, keep_valid,     reqs_oe_q[g_i])
            `OR_2(u_next_oe,  1, nextReqs_oe,   oe_new,         oe_keep_gated)

            wire we_keep_gated, nextReqs_we;
            `AND_2(u_we_keep, 1, we_keep_gated, keep_valid,    reqs_we_q[g_i])
            `OR_2(u_next_we,  1, nextReqs_we,   store_valid_w, we_keep_gated)

            wire [14:0] paddr_st_gated, paddr_ld0_gated, paddr_ld1_gated, paddr_keep_gated, nextReqs_paddr;
            `AND_2(u_pa_st,   15, paddr_st_gated,   core_stq_addr_i[g_i], store_valid_15)
            `AND_2(u_pa_ld0,  15, paddr_ld0_gated,  core_ld_addr_0_i,     ld0_valid_15)
            `AND_2(u_pa_ld1,  15, paddr_ld1_gated,  core_ld_addr_1_i,     ld1_valid_15)
            `AND_2(u_pa_keep, 15, paddr_keep_gated, reqs_paddr_q[g_i],    keep_valid_15)
            `OR_4(u_next_pa,  15, nextReqs_paddr,   paddr_st_gated, paddr_ld0_gated, paddr_ld1_gated, paddr_keep_gated)

            wire [15:0] vec_st_gated, vec_keep_gated, nextReqs_vec;
            `AND_2(u_vec_st,   16, vec_st_gated,   core_stq_bitvec_i[g_i], store_valid_16)
            `AND_2(u_vec_keep, 16, vec_keep_gated, reqs_vec_q[g_i],        keep_valid_16)
            `OR_2(u_next_vec,  16, nextReqs_vec,   vec_st_gated,           vec_keep_gated)

            wire [127:0] data_st_gated, data_keep_gated, nextReqs_data;
            `AND_2(u_dat_st,   128, data_st_gated,   core_stq_data_i[g_i], store_valid_128)
            `AND_2(u_dat_keep, 128, data_keep_gated, reqs_data_q[g_i],     keep_valid_128)
            `OR_2(u_next_dat,  128, nextReqs_data,   data_st_gated,        data_keep_gated)

            `REG_RST(u_reg_oe,  1,   clk_i, rst, nextReqs_oe,    reqs_oe_q[g_i])
            `REG_RST(u_reg_we,  1,   clk_i, rst, nextReqs_we,    reqs_we_q[g_i])
            `REG_RST(u_reg_pa,  15,  clk_i, rst, nextReqs_paddr, reqs_paddr_q[g_i])
            `REG_RST(u_reg_vec, 16,  clk_i, rst, nextReqs_vec,   reqs_vec_q[g_i])
            `REG_RST(u_reg_dat, 128, clk_i, rst, nextReqs_data,  reqs_data_q[g_i])

            assign reqs_oe_o[g_i]    = reqs_oe_q[g_i];
            assign reqs_we_o[g_i]    = reqs_we_q[g_i];
            assign reqs_paddr_o[g_i] = reqs_paddr_q[g_i];
            assign reqs_vec_o[g_i]   = reqs_vec_q[g_i];
            assign reqs_data_o[g_i]  = reqs_data_q[g_i];

            assign writeSuccess_o[g_i] = store_valid_w;

        end
    endgenerate

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

    `OR_4(u_reqServed_0, 1, reqServed_0_o, ld0_valid[0], ld0_valid[1], ld0_valid[2], ld0_valid[3])
    `OR_4(u_reqServed_1, 1, reqServed_1_o, ld1_valid[0], ld1_valid[1], ld1_valid[2], ld1_valid[3])

endmodule
