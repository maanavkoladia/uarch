// =============================================================================
// Fetch  (pure Verilog-2005 structural port of Fetch_structural.sv)
//
//   - All SystemVerilog constructs (struct, typedef, enum, package import,
//     `bool`/`p_address_t`/`v_address_t`/struct literals/SV-cast) are
//     removed. Each struct field is exposed as a separate flat scalar/
//     vector port whose name follows the original `struct.field` path
//     with `.` replaced by `_`.
//
//   - icache_2_core_t.instruction_line[16] (byte_t array) becomes a 128-bit
//     packed bus (byte 0 = bits [7:0]).
//   - idm_outputs_t.idm_slots[4] is unrolled per slot. Fetch only reads
//     {valid, br_valid, br_eip, br_btb_target, br_xcl} -- the per-slot
//     data[16] bytes are not consumed here.
//   - core_2_icache_t (output) and idm_slot_req_t per-slot (output) are
//     unrolled into individual flat ports; per-slot req.data[16] becomes
//     a 128-bit packed bus.
//
//   Type-to-width mapping:
//     bool                       -> 1 bit
//     p_address_t                -> 15 bits
//     v_address_t / l_address_t  -> 32 bits
//     uint32_t                   -> 32 bits
//     num_valid_IDM_slots        -> 3 bits  ($clog2(4)+1)
//
//   Internal leaf modules already have flat Verilog-2005 ports:
//     BTB, Predictor, SPC_Sel_Logic, IDM_Ctrl_Logic, IDM_Invalidate_Logic,
//     EXP_Set_logic, EXP_Ctrl_ROMS, ICache_En_Logic, TLB, SegmentTranslation.
// =============================================================================

import reg_ids_pkg::*;
import common_pkg::*;
import interconnect_pkg::*;
import control_store_pkg::*;
import core_common_pkg::*;
import core_stage_latches_pkg::*;
import reg_ids_pkg::*;

module Fetch (
    input  wire        clk,
    input  wire        rst,

    // ====================================================================
    // icache_2_core_t (icache_info_i)
    // ====================================================================
    input  wire        icache_info_hit,
    input  wire [127:0] icache_info_instruction_line,

    // ====================================================================
    // idm_outputs_t (idm_info_i) -- only fields read by Fetch
    // ====================================================================
    input  wire        idm_info_idm_slots_0_valid,
    input  wire        idm_info_idm_slots_0_br_valid,
    input  wire [31:0] idm_info_idm_slots_0_br_eip,
    input  wire [31:0] idm_info_idm_slots_0_br_btb_target,
    input  wire        idm_info_idm_slots_0_br_xcl,

    input  wire        idm_info_idm_slots_1_valid,
    input  wire        idm_info_idm_slots_1_br_valid,
    input  wire [31:0] idm_info_idm_slots_1_br_eip,
    input  wire [31:0] idm_info_idm_slots_1_br_btb_target,
    input  wire        idm_info_idm_slots_1_br_xcl,

    input  wire        idm_info_idm_slots_2_valid,
    input  wire        idm_info_idm_slots_2_br_valid,
    input  wire [31:0] idm_info_idm_slots_2_br_eip,
    input  wire [31:0] idm_info_idm_slots_2_br_btb_target,
    input  wire        idm_info_idm_slots_2_br_xcl,

    input  wire        idm_info_idm_slots_3_valid,
    input  wire        idm_info_idm_slots_3_br_valid,
    input  wire [31:0] idm_info_idm_slots_3_br_eip,
    input  wire [31:0] idm_info_idm_slots_3_br_btb_target,
    input  wire        idm_info_idm_slots_3_br_xcl,

    input  wire [2:0]  idm_info_valid_slots,

    // ====================================================================
    // decode_outputs_t (decode_outs_i) -- consumed fields
    // ====================================================================
    input  wire        decode_outs_invalid_instruction,
    input  wire [31:0] decode_outs_eip,
    input  wire        decode_outs_decode_forward,
    input  wire        decode_outs_stall,

    // ====================================================================
    // rr_outputs_t (rr_outs_i) -- consumed fields
    // ====================================================================
    input  wire        rr_outs_valid,
    input  wire        rr_outs_codeSeg_sb,
    input  wire [31:0] rr_outs_codeSeg_data,
    input  wire [31:0] rr_outs_codeSeg_limit,

    // ====================================================================
    // dc_outputs_t (dc_outs_i)
    // ====================================================================
    input  wire        dc_outs_valid,
    input  wire        dc_outs_exp_present,
    input  wire        dc_outs_exp_pf,

    // ====================================================================
    // mem_outputs_t (mem_outs_i)
    // ====================================================================
    input  wire        mem_outs_valid,

    // ====================================================================
    // exe_outputs_t (exe_outs_i)
    // ====================================================================
    input  wire        exe_outs_valid,
    input  wire        exe_outs_br_res_valid,
    input  wire        exe_outs_br_res_flush,
    input  wire        exe_outs_br_res_miss_prediction,
    input  wire [31:0] exe_outs_br_res_br_eip,
    input  wire [31:0] exe_outs_br_res_neip,
    input  wire [31:0] exe_outs_br_res_br_target,
    input  wire        exe_outs_br_res_taken,
    input  wire        exe_outs_br_res_br_XCL,
    input  wire        exe_outs_br_res_clr_exp_mode,
    input  wire        exe_outs_br_res_br_ucond,

    // ====================================================================
    // wb_outputs_t (wb_outs_i)
    // ====================================================================
    input  wire        wb_outs_valid,

    input  wire        dma_int,

    // ====================================================================
    // fetch_outputs_t (outs_o)
    // ====================================================================
    // core_2_icache_t (outs_o.fetch_2_icache)
    output wire        outs_fetch_2_icache_icache_en,
    output wire [14:0] outs_fetch_2_icache_p_addr,
    output wire [31:0] outs_fetch_2_icache_v_addr_i,
    output wire [2:0]  outs_fetch_2_icache_num_valid_IDM_slots,

    // fetch_idm_ctrl_2_idm_t (outs_o.idm_reqs) -- per-slot unroll
    output wire        outs_idm_reqs_req_0_ld_meta_data,
    output wire        outs_idm_reqs_req_0_ld_data,
    output wire        outs_idm_reqs_req_0_valid,
    output wire        outs_idm_reqs_req_0_br_valid,
    output wire [31:0] outs_idm_reqs_req_0_br_eip,
    output wire [31:0] outs_idm_reqs_req_0_br_target,
    output wire        outs_idm_reqs_req_0_br_xcl,
    output wire [127:0] outs_idm_reqs_req_0_data,

    output wire        outs_idm_reqs_req_1_ld_meta_data,
    output wire        outs_idm_reqs_req_1_ld_data,
    output wire        outs_idm_reqs_req_1_valid,
    output wire        outs_idm_reqs_req_1_br_valid,
    output wire [31:0] outs_idm_reqs_req_1_br_eip,
    output wire [31:0] outs_idm_reqs_req_1_br_target,
    output wire        outs_idm_reqs_req_1_br_xcl,
    output wire [127:0] outs_idm_reqs_req_1_data,

    output wire        outs_idm_reqs_req_2_ld_meta_data,
    output wire        outs_idm_reqs_req_2_ld_data,
    output wire        outs_idm_reqs_req_2_valid,
    output wire        outs_idm_reqs_req_2_br_valid,
    output wire [31:0] outs_idm_reqs_req_2_br_eip,
    output wire [31:0] outs_idm_reqs_req_2_br_target,
    output wire        outs_idm_reqs_req_2_br_xcl,
    output wire [127:0] outs_idm_reqs_req_2_data,

    output wire        outs_idm_reqs_req_3_ld_meta_data,
    output wire        outs_idm_reqs_req_3_ld_data,
    output wire        outs_idm_reqs_req_3_valid,
    output wire        outs_idm_reqs_req_3_br_valid,
    output wire [31:0] outs_idm_reqs_req_3_br_eip,
    output wire [31:0] outs_idm_reqs_req_3_br_target,
    output wire        outs_idm_reqs_req_3_br_xcl,
    output wire [127:0] outs_idm_reqs_req_3_data,

    output wire        outs_exp_pipe_clear,
    output wire        outs_exp_present,
    output wire        outs_exp_pf,
    output wire [1:0]  outs_exp_mode_jk,
    output wire        outs_int_mode_jk
);

    // ----------------------------------------------------------------
    // Internal storage outputs (driven by structural REG cells)
    // ----------------------------------------------------------------
    wire [31:0] SPC;
    wire        DMA_int_jk;
    wire        exp_mode_jk_0;
    wire        exp_mode_jk_1;
    wire        int_mode_jk;

    // ----------------------------------------------------------------
    // Combinational scalar / vector wires
    // ----------------------------------------------------------------
    wire        f_exp;
    wire        tlb_or_exp;
    wire        not_exp_mode_jk_0;
    wire        exp_or_int;
    wire        flush_and_valid;
    wire        outs_exp_pipe_clear_w;

    wire [31:0] seg_xlation_out;
    wire [7:0]  rom_data_out      [0:15];
    wire [7:0]  idm_ctrl_data_in  [0:15];
    wire [31:0] next_spc;
    wire [31:0] spc_16;
    wire        spc_16_cout;        // unused
    wire [31:0] br_restore_spc;
    wire [31:0] br_target;
    wire [31:0] spc_2_IDM_CTRL;
    wire [31:0] br_restore_spc_aligned;
    wire [31:0] br_target_aligned;

    // ----------------------------------------------------------------
    // Mode-latch set/clear/WE/D wires
    // ----------------------------------------------------------------
    wire        exp_clr;
    wire        not_exp_clr;
    wire        not_clr_exp_mode;
    wire        not_int_mode_jk;

    wire        exp0_we, exp0_d;
    wire        exp1_we, exp1_d;
    wire        int_we,  int_d;
    wire        dma_we,  dma_d;

    // ----------------------------------------------------------------
    // Submodule-output wires (replace SV `<X>_t` struct vars).
    // Each struct field becomes an individual wire.
    // ----------------------------------------------------------------
    // BTB outputs (btb_output_t)
    wire        btb_hit;
    wire [31:0] btb_br_target;
    wire [31:0] btb_br_eip;
    wire        btb_XCL;
    wire        btb_br_ucond;

    // SPC_Sel_Logic outputs (spc_sel_logic_output_t)
    wire [1:0]  spc_sel_w;
    wire        spc_sel_br_target_sel;
    wire [31:0] spc_sel_br_target;
    wire        spc_sel_flush_reg;

    // Predictor outputs (predictor_output_t)
    wire        predictor_taken;

    // IDM_Invalidate_Logic outputs
    wire        idm_invalidate_w  [0:3];
    wire        idm_invalidate_no_writes;

    // TLB outputs (tlb_outputs_t)
    wire [14:0] tlb_physical_addr;
    wire        tlb_physical_addr_valid;        // unused
    wire        tlb_gp_exp;
    wire        tlb_pageFault;
    wire        tlb_MIO;                        // unused

    // EXP_Set_logic outputs (exp_set_logic_output_t)
    wire        exp_set_exp_pipe_clear;
    wire        exp_set_dc_exp_set;
    wire        exp_set_int_pipe_clear;

    // ICache enable
    wire        en_icache;

    // ----------------------------------------------------------------
    // Per-slot adapter wires for sub-modules that take unpacked arrays.
    // ----------------------------------------------------------------
    wire        idm_slot_valid_w          [0:3];
    wire        idm_slot_br_valid_w       [0:3];
    wire [31:0] idm_slot_br_eip_w         [0:3];
    wire [31:0] idm_slot_br_btb_target_w  [0:3];
    wire        idm_slot_br_xcl_w         [0:3];

    wire        idmc_ld_meta_data_w [0:3];
    wire        idmc_ld_data_w      [0:3];
    wire        idmc_valid_w        [0:3];
    wire        idmc_br_valid_w     [0:3];
    wire [31:0] idmc_br_eip_w       [0:3];
    wire [31:0] idmc_br_target_w    [0:3];
    wire        idmc_br_xcl_w       [0:3];
    wire [7:0]  idmc_data_w         [0:3] [0:15];
    wire        idmc_push_success_w;

    // Pack flat per-slot inputs into the unpacked arrays the sub-modules
    // consume.
    assign idm_slot_valid_w[0]         = idm_info_idm_slots_0_valid;
    assign idm_slot_br_valid_w[0]      = idm_info_idm_slots_0_br_valid;
    assign idm_slot_br_eip_w[0]        = idm_info_idm_slots_0_br_eip;
    assign idm_slot_br_btb_target_w[0] = idm_info_idm_slots_0_br_btb_target;
    assign idm_slot_br_xcl_w[0]        = idm_info_idm_slots_0_br_xcl;
    assign idm_slot_valid_w[1]         = idm_info_idm_slots_1_valid;
    assign idm_slot_br_valid_w[1]      = idm_info_idm_slots_1_br_valid;
    assign idm_slot_br_eip_w[1]        = idm_info_idm_slots_1_br_eip;
    assign idm_slot_br_btb_target_w[1] = idm_info_idm_slots_1_br_btb_target;
    assign idm_slot_br_xcl_w[1]        = idm_info_idm_slots_1_br_xcl;
    assign idm_slot_valid_w[2]         = idm_info_idm_slots_2_valid;
    assign idm_slot_br_valid_w[2]      = idm_info_idm_slots_2_br_valid;
    assign idm_slot_br_eip_w[2]        = idm_info_idm_slots_2_br_eip;
    assign idm_slot_br_btb_target_w[2] = idm_info_idm_slots_2_br_btb_target;
    assign idm_slot_br_xcl_w[2]        = idm_info_idm_slots_2_br_xcl;
    assign idm_slot_valid_w[3]         = idm_info_idm_slots_3_valid;
    assign idm_slot_br_valid_w[3]      = idm_info_idm_slots_3_br_valid;
    assign idm_slot_br_eip_w[3]        = idm_info_idm_slots_3_br_eip;
    assign idm_slot_br_btb_target_w[3] = idm_info_idm_slots_3_br_btb_target;
    assign idm_slot_br_xcl_w[3]        = idm_info_idm_slots_3_br_xcl;

    // Pack the icache instruction_line (128-bit packed bus) into the
    // unpacked byte array for the per-byte rom/icache mux.
    wire [7:0] icache_instruction_line_unpacked [0:15];
    genvar gi_il;
    generate
        for (gi_il = 0; gi_il < 16; gi_il = gi_il + 1) begin : g_unpack_icache_line
            assign icache_instruction_line_unpacked[gi_il] = icache_info_instruction_line[gi_il*8 +: 8];
        end
    endgenerate

    // ----------------------------------------------------------------
    // outs_o.idm_reqs : drive flat output ports from per-slot adapter.
    //   data per slot is packed back into a 128-bit bus on the boundary.
    // ----------------------------------------------------------------
    assign outs_idm_reqs_req_0_ld_meta_data = idmc_ld_meta_data_w[0];
    assign outs_idm_reqs_req_0_ld_data      = idmc_ld_data_w[0];
    assign outs_idm_reqs_req_0_valid        = idmc_valid_w[0];
    assign outs_idm_reqs_req_0_br_valid     = idmc_br_valid_w[0];
    assign outs_idm_reqs_req_0_br_eip       = idmc_br_eip_w[0];
    assign outs_idm_reqs_req_0_br_target    = idmc_br_target_w[0];
    assign outs_idm_reqs_req_0_br_xcl       = idmc_br_xcl_w[0];

    assign outs_idm_reqs_req_1_ld_meta_data = idmc_ld_meta_data_w[1];
    assign outs_idm_reqs_req_1_ld_data      = idmc_ld_data_w[1];
    assign outs_idm_reqs_req_1_valid        = idmc_valid_w[1];
    assign outs_idm_reqs_req_1_br_valid     = idmc_br_valid_w[1];
    assign outs_idm_reqs_req_1_br_eip       = idmc_br_eip_w[1];
    assign outs_idm_reqs_req_1_br_target    = idmc_br_target_w[1];
    assign outs_idm_reqs_req_1_br_xcl       = idmc_br_xcl_w[1];

    assign outs_idm_reqs_req_2_ld_meta_data = idmc_ld_meta_data_w[2];
    assign outs_idm_reqs_req_2_ld_data      = idmc_ld_data_w[2];
    assign outs_idm_reqs_req_2_valid        = idmc_valid_w[2];
    assign outs_idm_reqs_req_2_br_valid     = idmc_br_valid_w[2];
    assign outs_idm_reqs_req_2_br_eip       = idmc_br_eip_w[2];
    assign outs_idm_reqs_req_2_br_target    = idmc_br_target_w[2];
    assign outs_idm_reqs_req_2_br_xcl       = idmc_br_xcl_w[2];

    assign outs_idm_reqs_req_3_ld_meta_data = idmc_ld_meta_data_w[3];
    assign outs_idm_reqs_req_3_ld_data      = idmc_ld_data_w[3];
    assign outs_idm_reqs_req_3_valid        = idmc_valid_w[3];
    assign outs_idm_reqs_req_3_br_valid     = idmc_br_valid_w[3];
    assign outs_idm_reqs_req_3_br_eip       = idmc_br_eip_w[3];
    assign outs_idm_reqs_req_3_br_target    = idmc_br_target_w[3];
    assign outs_idm_reqs_req_3_br_xcl       = idmc_br_xcl_w[3];

    genvar gi_dp;
    generate
        for (gi_dp = 0; gi_dp < 16; gi_dp = gi_dp + 1) begin : g_pack_idmc_data
            assign outs_idm_reqs_req_0_data[gi_dp*8 +: 8] = idmc_data_w[0][gi_dp];
            assign outs_idm_reqs_req_1_data[gi_dp*8 +: 8] = idmc_data_w[1][gi_dp];
            assign outs_idm_reqs_req_2_data[gi_dp*8 +: 8] = idmc_data_w[2][gi_dp];
            assign outs_idm_reqs_req_3_data[gi_dp*8 +: 8] = idmc_data_w[3][gi_dp];
        end
    endgenerate

    // ----------------------------------------------------------------
    // exp_mode_jk vector + flat output assignments
    //   outs_o.exp_pipe_clear = exp_pipe_clear | int_pipe_clear
    // ----------------------------------------------------------------
    `OR_2(u_outs_exp_pipe_clear_or, 1, outs_exp_pipe_clear_w,
          exp_set_exp_pipe_clear, exp_set_int_pipe_clear)

    assign outs_fetch_2_icache_icache_en           = en_icache;
    assign outs_fetch_2_icache_p_addr              = tlb_physical_addr;
    assign outs_fetch_2_icache_v_addr_i            = seg_xlation_out;
    assign outs_fetch_2_icache_num_valid_IDM_slots = idm_info_valid_slots;

    assign outs_exp_pipe_clear = outs_exp_pipe_clear_w;
    assign outs_exp_present    = f_exp;
    assign outs_exp_pf         = tlb_pageFault;
    assign outs_exp_mode_jk    = {exp_mode_jk_1, exp_mode_jk_0};
    assign outs_int_mode_jk    = int_mode_jk;

    // ----------------------------------------------------------------
    // f_exp = (gp_exp | pageFault) & ~exp_mode_jk[0]
    // ----------------------------------------------------------------
    `OR_2 (u_tlb_or_exp,         1, tlb_or_exp,        tlb_gp_exp, tlb_pageFault)
    `INV_N(u_inv_exp_mode_jk_0,  1, exp_mode_jk_0,     not_exp_mode_jk_0)
    `AND_2(u_f_exp,              1, f_exp,             tlb_or_exp, not_exp_mode_jk_0)

    // ----------------------------------------------------------------
    // exp_or_int = exp_mode_jk[0] | exp_mode_jk[1] | int_mode_jk
    // ----------------------------------------------------------------
    `OR_3(u_exp_or_int, 1, exp_or_int, exp_mode_jk_0, exp_mode_jk_1, int_mode_jk)

    // ----------------------------------------------------------------
    // idm_ctrl_data_in[i] = exp_or_int ? rom_data_out[i]
    //                                  : icache_info_i.instruction_line[i]
    // ----------------------------------------------------------------
    genvar gd;
    generate
        for (gd = 0; gd < 16; gd = gd + 1) begin : g_idm_data_mux
            `MUX_2(u_idm_data_mux, 8, idm_ctrl_data_in[gd],
                    icache_instruction_line_unpacked[gd], rom_data_out[gd], exp_or_int)
        end
    endgenerate

    // ----------------------------------------------------------------
    // br_restore_spc = taken ? br_target : neip
    // ----------------------------------------------------------------
    `MUX_2(u_br_restore_mux, 32, br_restore_spc,
            exe_outs_br_res_neip, exe_outs_br_res_br_target,
            exe_outs_br_res_taken)

    // ----------------------------------------------------------------
    // br_target = br_target_sel ? spc_sel.br_target : btb.br_target
    // ----------------------------------------------------------------
    `MUX_2(u_br_target_mux, 32, br_target,
            btb_br_target, spc_sel_br_target,
            spc_sel_br_target_sel)

    // ----------------------------------------------------------------
    // spc_2_IDM_CTRL = exp_or_int ? 32'h0 : SPC
    // ----------------------------------------------------------------
    `MUX_2(u_spc_2_idm_ctrl_mux, 32, spc_2_IDM_CTRL,
            SPC, 32'h00000000, exp_or_int)

    // ----------------------------------------------------------------
    // spc_16 = SPC + 16
    // ----------------------------------------------------------------
    `ADD_N(u_spc_plus_16, 32, spc_16, spc_16_cout, SPC, 32'h00000010, 1'b0)

    // ----------------------------------------------------------------
    // next_spc 4-way mux on spc_sel_w
    //   00 SPC  | 01 SPC_P16 | 10 BR_RESTORE_aligned | 11 BTB_TARGET_aligned
    // ----------------------------------------------------------------
    assign br_restore_spc_aligned = {br_restore_spc[31:4], 4'b0000};
    assign br_target_aligned      = {br_target[31:4],      4'b0000};

    `MUX_4(u_next_spc_mux, 32, next_spc,
            SPC, spc_16, br_restore_spc_aligned, br_target_aligned,
            spc_sel_w)

    // ----------------------------------------------------------------
    // SPC register
    // ----------------------------------------------------------------
    `REG_RST(u_spc_reg, 32, clk, rst, next_spc, SPC)

    // ----------------------------------------------------------------
    // Mode latches (clear-dominates):
    //   exp_mode_jk[0]: set=exp_pipe_clear,    clr=clr_exp_mode | flush_and_valid
    //   exp_mode_jk[1]: set=dc_exp_set,        clr=clr_exp_mode | flush_and_valid
    //   int_mode_jk  : set=int_pipe_clear,     clr=clr_exp_mode
    //   DMA_int_jk   : set=dma_int,            clr=int_mode_jk
    // ----------------------------------------------------------------
    `AND_2(u_flush_and_valid, 1, flush_and_valid,
            exe_outs_br_res_flush, exe_outs_br_res_valid)

    `OR_2 (u_exp_clr,         1, exp_clr,
            exe_outs_br_res_clr_exp_mode, flush_and_valid)
    `INV_N(u_n_exp_clr,       1, exp_clr,                       not_exp_clr)
    `INV_N(u_n_clr_exp_mode,  1, exe_outs_br_res_clr_exp_mode,  not_clr_exp_mode)
    `INV_N(u_n_int_mode_jk,   1, int_mode_jk,                   not_int_mode_jk)

    // exp_mode_jk[0]
    `OR_2 (u_exp0_we, 1, exp0_we,
            exp_set_exp_pipe_clear, exp_clr)
    `AND_2(u_exp0_d,  1, exp0_d,
            exp_set_exp_pipe_clear, not_exp_clr)
    `REG_RST_WE(u_exp_mode_jk_0_reg, 1, clk, rst, exp0_we, exp0_d, exp_mode_jk_0)

    // exp_mode_jk[1]
    `OR_2 (u_exp1_we, 1, exp1_we,
            exp_set_dc_exp_set, exp_clr)
    `AND_2(u_exp1_d,  1, exp1_d,
            exp_set_dc_exp_set, not_exp_clr)
    `REG_RST_WE(u_exp_mode_jk_1_reg, 1, clk, rst, exp1_we, exp1_d, exp_mode_jk_1)

    // int_mode_jk
    `OR_2 (u_int_we, 1, int_we,
            exp_set_int_pipe_clear, exe_outs_br_res_clr_exp_mode)
    `AND_2(u_int_d,  1, int_d,
            exp_set_int_pipe_clear, not_clr_exp_mode)
    `REG_RST_WE(u_int_mode_jk_reg, 1, clk, rst, int_we, int_d, int_mode_jk)

    // DMA_int_jk
    `OR_2 (u_dma_we, 1, dma_we, dma_int, int_mode_jk)
    `AND_2(u_dma_d,  1, dma_d,  dma_int, not_int_mode_jk)
    `REG_RST_WE(u_dma_int_jk_reg, 1, clk, rst, dma_we, dma_d, DMA_int_jk)

    // ----------------------------------------------------------------
    // Sub-modules
    // ----------------------------------------------------------------
    BTB btb (
        .clk          (clk),
        .rst          (rst),
        .spc          (SPC),

        .exe_br_valid (exe_outs_br_res_valid),
        .exe_br_target(exe_outs_br_res_br_target),
        .exe_br_eip   (exe_outs_br_res_br_eip),
        .exe_br_XCL   (exe_outs_br_res_br_XCL),
        .exe_br_ucond (exe_outs_br_res_br_ucond),

        .hit          (btb_hit),
        .br_target    (btb_br_target),
        .br_eip       (btb_br_eip),
        .XCL          (btb_XCL),
        .br_ucond     (btb_br_ucond)
    );

    Predictor predictor (
        .clk          (clk),
        .rst          (rst),

        .spc          (SPC),
        .btb_hit      (btb_hit),
        .exe_br_valid (exe_outs_br_res_valid),
        .exe_br_taken (exe_outs_br_res_taken),
        .exe_br_eip   (exe_outs_br_res_br_eip),
        .misprediction(exe_outs_br_res_miss_prediction),

        .taken        (predictor_taken)
    );

    SPC_Sel_Logic spc_sel_logic (
        .clk          (clk),
        .rst          (rst),
        .spc          (SPC),
        .flush        (exe_outs_br_res_flush),
        .decode_stall (decode_outs_stall),

        .btb_hit       (btb_hit),
        .btb_br_target (btb_br_target),
        .btb_br_eip    (btb_br_eip),
        .btb_XCL       (btb_XCL),
        .btb_br_ucond  (btb_br_ucond),

        .pred_taken            (predictor_taken),
        .idm_ctrl_push_success (idmc_push_success_w),

        .sel           (spc_sel_w),
        .br_target_sel (spc_sel_br_target_sel),
        .br_target     (spc_sel_br_target),
        .flush_reg     (spc_sel_flush_reg)
    );

    IDM_Ctrl_Logic idm_ctrl_logic (
        .exp_mode (exp_mode_jk_0),
        .int_mode (int_mode_jk),
        .spc      (spc_2_IDM_CTRL),

        .idm_slot_valid (idm_slot_valid_w),

        .invalidate (idm_invalidate_w),
        .no_writes  (idm_invalidate_no_writes),

        .btb_hit       (btb_hit),
        .btb_br_target (btb_br_target),
        .btb_br_eip    (btb_br_eip),
        .btb_XCL       (btb_XCL),

        .pred_taken    (predictor_taken),
        .icache_hit    (icache_info_hit),

        .spc_sel_flush_reg (spc_sel_flush_reg),

        .data_in (idm_ctrl_data_in),

        .idm_req_ld_meta_data (idmc_ld_meta_data_w),
        .idm_req_ld_data      (idmc_ld_data_w),
        .idm_req_valid        (idmc_valid_w),
        .idm_req_br_valid     (idmc_br_valid_w),
        .idm_req_br_eip       (idmc_br_eip_w),
        .idm_req_br_target    (idmc_br_target_w),
        .idm_req_br_xcl       (idmc_br_xcl_w),
        .idm_req_data         (idmc_data_w),
        .push_success         (idmc_push_success_w)
    );

    IDM_Invalidate_Logic idm_invalidate_logic (
        .clk            (clk),
        .rst            (rst),
        .eip            (decode_outs_eip),
        .flush          (exe_outs_br_res_flush),
        .exp_pipeclear  (exp_set_exp_pipe_clear),
        .int_pipe_clear (exp_set_int_pipe_clear),
        .decode_stall   (decode_outs_stall),

        .idm_slot_valid          (idm_slot_valid_w),
        .idm_slot_br_valid       (idm_slot_br_valid_w),
        .idm_slot_br_eip         (idm_slot_br_eip_w),
        .idm_slot_br_btb_target  (idm_slot_br_btb_target_w),
        .idm_slot_br_xcl         (idm_slot_br_xcl_w),

        .decode_forward (decode_outs_decode_forward),

        .invalidate     (idm_invalidate_w),
        .no_writes      (idm_invalidate_no_writes)
    );

    EXP_Set_logic exp_set_logic (
        .invalid_instruction(decode_outs_invalid_instruction),
        .rr_valid           (rr_outs_valid),
        .dc_valid           (dc_outs_valid),
        .mem_valid          (mem_outs_valid),
        .exe_valid          (exe_outs_valid),
        .wb_valid           (wb_outs_valid),
        .f_exp              (f_exp),
        .dc_exp             (dc_outs_exp_present),
        .int_set            (DMA_int_jk),
        .exp_mode_jk        (exp_mode_jk_0),
        .int_mode_jk        (int_mode_jk),

        .exp_pipe_clear     (exp_set_exp_pipe_clear),
        .dc_exp_set         (exp_set_dc_exp_set),
        .int_pipe_clear     (exp_set_int_pipe_clear)
    );

    EXP_Ctrl_ROMS exp_ctrl_roms (
        .clk           (clk),
        .rst           (rst),
        .exp_pipe_clear(exp_set_exp_pipe_clear),
        .int_pipe_clear(exp_set_int_pipe_clear),
        .DC_pf         (dc_outs_exp_pf),
        .DC_exp        (dc_outs_exp_present),
        .Fetch_pf      (tlb_pageFault),
        .DMA_int       (DMA_int_jk),
        .exp_mode      (exp_mode_jk_0),
        .rom_data_out  (rom_data_out)
    );

    ICache_En_Logic icache_en_logic (
        .rst      (rst),
        .exp_mode (exp_mode_jk_0),
        .cs_sb    (rr_outs_codeSeg_sb),
        .int_mode (int_mode_jk),
        .DMA_int  (DMA_int_jk),
        .f_exp    (f_exp),
        .out      (en_icache)
    );

    TLB tlb (
        .virtual_addr        (seg_xlation_out),
        .write_intention     (1'b0),
        .physical_addr       (tlb_physical_addr),
        .physical_addr_valid (tlb_physical_addr_valid),
        .gp_exp              (tlb_gp_exp),
        .pageFault           (tlb_pageFault),
        .MIO                 (tlb_MIO)
    );

    SegmentTranslation seg_Xlation (
        .l_addr_i  (SPC),
        .segValue  (rr_outs_codeSeg_data),
        .segLimit  (rr_outs_codeSeg_limit),
        .v_addr_o  (seg_xlation_out),
        .gp_fault_o()
    );

endmodule
