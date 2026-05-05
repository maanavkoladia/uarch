// Structural Verilog 2005 port of rtl/core/IDM/IDM.sv.
// Struct ports preserved (file is .sv); body uses only STDCell macros and
// assign-aliasing -- no always_*, no &/|/~/^/?:/== operators.
//
// Reset model:
//   * rst (active low) drives every REG_RST_WE.rst pin -- async, per the
//     macro's contract (STDCell_Macros.vh:233-234: "do not use signals
//     other than rst for the rst input").
//   * exp_pipe_clear is treated as a SYNCHRONOUS clear of just the .valid
//     bit of every slot. The br_* / data fields are not touched -- consumers
//     gate on valid, so leaving stale metadata is harmless and saves a
//     200+ bit MUX per slot. This is a deliberate divergence from the
//     behavioral SV (which clears everything to 0 in the same path).

import common_pkg::*;
import core_common_pkg::fetch_outputs_t;
import core_common_pkg::fetch_idm_ctrl_2_idm_t;
import core_common_pkg::idm_slot_req_t;
import core_stage_latches_pkg::idm_outputs_t;
import IDM_pkg::*;

module IDM (
    input  wire             clk,
    input  wire             rst,           // active low, async
    input  fetch_outputs_t  fetch_outs_i,
    output idm_outputs_t    idm_outs_o
);

    // ----------------------------------------------------------------
    // Unpack fetch_outs_i into flat per-slot wires (assigns are pure
    // aliasing / slicing -- no operators).
    // ----------------------------------------------------------------
    wire        ld_meta_w  [0:NUM_IDM_SLOTS-1];
    wire        ld_data_w  [0:NUM_IDM_SLOTS-1];
    wire        in_valid_w [0:NUM_IDM_SLOTS-1];
    wire        in_brval_w [0:NUM_IDM_SLOTS-1];
    wire [31:0] in_breip_w [0:NUM_IDM_SLOTS-1];
    wire [31:0] in_brtgt_w [0:NUM_IDM_SLOTS-1];
    wire        in_brxcl_w [0:NUM_IDM_SLOTS-1];
    wire [127:0] in_data_w [0:NUM_IDM_SLOTS-1];   // packed LSB-first
    wire        exp_pipe_clear_w;

    assign exp_pipe_clear_w = fetch_outs_i.exp_pipe_clear;

    genvar gi, gj;
    generate
        for (gi = 0; gi < NUM_IDM_SLOTS; gi = gi + 1) begin: g_unpack_in
            assign ld_meta_w[gi]  = fetch_outs_i.idm_reqs.req[gi].ld_meta_data;
            assign ld_data_w[gi]  = fetch_outs_i.idm_reqs.req[gi].ld_data;
            assign in_valid_w[gi] = fetch_outs_i.idm_reqs.req[gi].valid;
            assign in_brval_w[gi] = fetch_outs_i.idm_reqs.req[gi].br_valid;
            assign in_breip_w[gi] = fetch_outs_i.idm_reqs.req[gi].br_eip;
            assign in_brtgt_w[gi] = fetch_outs_i.idm_reqs.req[gi].br_target;
            assign in_brxcl_w[gi] = fetch_outs_i.idm_reqs.req[gi].br_xcl;
            for (gj = 0; gj < CACHE_LINES_SIZE_B; gj = gj + 1) begin: g_pack_data
                assign in_data_w[gi][gj*8 +: 8] =
                    fetch_outs_i.idm_reqs.req[gi].data[gj];
            end
        end
    endgenerate

    // ----------------------------------------------------------------
    // valid-bit gating
    //   we_valid = ld_meta_data | exp_pipe_clear   (so clear takes effect)
    //   d_valid  = exp_pipe_clear ? 1'b0 : req.valid
    // br_* / data have no clear semantics in this port: their WE is the
    // raw load enable and their D is the raw req field.
    // ----------------------------------------------------------------
    wire we_valid_w [0:NUM_IDM_SLOTS-1];
    wire d_valid_w  [0:NUM_IDM_SLOTS-1];
    generate
        for (gi = 0; gi < NUM_IDM_SLOTS; gi = gi + 1) begin: g_valid_in
            `OR_2 (u_we_valid, 1, we_valid_w[gi], ld_meta_w[gi], exp_pipe_clear_w)
            `MUX_2(u_dm_valid, 1, d_valid_w[gi],  in_valid_w[gi], 1'b0, exp_pipe_clear_w)
        end
    endgenerate

    // ----------------------------------------------------------------
    // Storage. One REG_RST_WE per (slot, field). rst (active low, async)
    // drives every .rst pin per macro contract.
    //   valid : we = we_valid_w (OR with clear), d = d_valid_w (mux'd to 0)
    //   br_*  : we = ld_meta_w, d = raw req field
    //   data  : we = ld_data_w, d = raw req data
    // ----------------------------------------------------------------
    wire        valid_q  [0:NUM_IDM_SLOTS-1];
    wire        brval_q  [0:NUM_IDM_SLOTS-1];
    wire [31:0] breip_q  [0:NUM_IDM_SLOTS-1];
    wire [31:0] brtgt_q  [0:NUM_IDM_SLOTS-1];
    wire        brxcl_q  [0:NUM_IDM_SLOTS-1];
    wire [127:0] data_q  [0:NUM_IDM_SLOTS-1];

    generate
        for (gi = 0; gi < NUM_IDM_SLOTS; gi = gi + 1) begin: g_reg
            `REG_RST_WE(u_r_valid, 1,   clk, rst, we_valid_w[gi], d_valid_w[gi],  valid_q[gi])
            `REG_RST_WE(u_r_brval, 1,   clk, rst, ld_meta_w[gi],  in_brval_w[gi], brval_q[gi])
            `REG_RST_WE(u_r_breip, 32,  clk, rst, ld_meta_w[gi],  in_breip_w[gi], breip_q[gi])
            `REG_RST_WE(u_r_brtgt, 32,  clk, rst, ld_meta_w[gi],  in_brtgt_w[gi], brtgt_q[gi])
            `REG_RST_WE(u_r_brxcl, 1,   clk, rst, ld_meta_w[gi],  in_brxcl_w[gi], brxcl_q[gi])
            `REG_RST_WE(u_r_data,  128, clk, rst, ld_data_w[gi],  in_data_w[gi],  data_q[gi])
        end
    endgenerate

    // ----------------------------------------------------------------
    // valid_slots = popcount(valid_q[3:0])  (4 -> 3 bits)
    // Two half-adders compress 4 bits -> two 2-bit pop counts, then
    // ADD_N(width=2) sums them into a 3-bit total {cout, sum[1:0]}.
    // ----------------------------------------------------------------
    wire pc01_xor_w, pc01_and_w;
    wire pc23_xor_w, pc23_and_w;
    `XOR_2(u_xor01, 1, pc01_xor_w, valid_q[0], valid_q[1])
    `XOR_2(u_xor23, 1, pc23_xor_w, valid_q[2], valid_q[3])
    `AND_2(u_and01, 1, pc01_and_w, valid_q[0], valid_q[1])
    `AND_2(u_and23, 1, pc23_and_w, valid_q[2], valid_q[3])

    wire [1:0] pc01_w, pc23_w;
    assign pc01_w = {pc01_and_w, pc01_xor_w};
    assign pc23_w = {pc23_and_w, pc23_xor_w};

    wire [1:0] sum_lo_w;
    wire       sum_hi_w;
    `ADD_N(u_count_add, 2, sum_lo_w, sum_hi_w, pc01_w, pc23_w, 1'b0)

    assign idm_outs_o.valid_slots = {sum_hi_w, sum_lo_w};

    // ----------------------------------------------------------------
    // Pack register q's into the output struct (pure aliasing).
    // ----------------------------------------------------------------
    generate
        for (gi = 0; gi < NUM_IDM_SLOTS; gi = gi + 1) begin: g_pack_out
            assign idm_outs_o.idm_slots[gi].valid         = valid_q[gi];
            assign idm_outs_o.idm_slots[gi].br_valid      = brval_q[gi];
            assign idm_outs_o.idm_slots[gi].br_eip        = breip_q[gi];
            assign idm_outs_o.idm_slots[gi].br_btb_target = brtgt_q[gi];
            assign idm_outs_o.idm_slots[gi].br_xcl        = brxcl_q[gi];
            for (gj = 0; gj < CACHE_LINES_SIZE_B; gj = gj + 1) begin: g_unp_data
                assign idm_outs_o.idm_slots[gi].data[gj] =
                    data_q[gi][gj*8 +: 8];
            end
        end
    endgenerate

endmodule
