// Fetch.v
//
// Pure Verilog-2005 top of the fetch stage. Same internal structure as
// Fetch.sv (kept on disk as the SV reference) but with all SV-only
// constructs removed:
//   * No `import` of any package.
//   * No struct or typedef ports -- icache_2_core_t, idm_outputs_t,
//     decode_outputs_t, rr_outputs_t, dc_outputs_t, mem_outputs_t,
//     exe_outputs_t, wb_outputs_t, fetch_outputs_t are unrolled into
//     individual flat wires whose widths come from the field types.
//   * Internal Fetch_pkg structs (btb_output_t, predictor_output_t,
//     spc_sel_logic_output_t, idm_ctrl_logic_output_t,
//     idm_invalidate_logic_output_t, exp_set_logic_output_t,
//     tlb_inputs_t, tlb_outputs_t) replaced with individual wires.
//   * No unpacked-array ports at the top level -- byte arrays
//     (icache instruction_line, idm_req data) are packed into 128-bit
//     buses on the boundary; per-slot fields are individual wires.
//   * No struct literals; no enum casts; no `bool`/`byte_t`/`logic`
//     keywords -- all `wire [W-1:0]`.
//
// Submodule instances and their unpacked-array ports are kept as-is
// (those submodules already declare wire-typed unpacked arrays, which
// are valid Verilog-2005).

module Fetch (
    input  wire         clk,
    input  wire         rst,

    // ====================================================================
    // icache_2_core_t (icache_info_i)
    //   instruction_line[0..15] packed as one 128-bit bus, byte 0 in [7:0]
    // ====================================================================
    input  wire         icache_info_hit,
    input  wire [127:0] icache_info_instruction_line,

    // ====================================================================
    // idm_outputs_t (idm_info_i)
    //   per-slot {valid, br_valid, br_eip, br_btb_target, br_xcl} + valid_slots.
    //   data is not consumed in Fetch and is not exposed.
    // ====================================================================
    input  wire         idm_info_idm_slots_0_valid,
    input  wire         idm_info_idm_slots_0_br_valid,
    input  wire [31:0]  idm_info_idm_slots_0_br_eip,
    input  wire [31:0]  idm_info_idm_slots_0_br_btb_target,
    input  wire         idm_info_idm_slots_0_br_xcl,

    input  wire         idm_info_idm_slots_1_valid,
    input  wire         idm_info_idm_slots_1_br_valid,
    input  wire [31:0]  idm_info_idm_slots_1_br_eip,
    input  wire [31:0]  idm_info_idm_slots_1_br_btb_target,
    input  wire         idm_info_idm_slots_1_br_xcl,

    input  wire         idm_info_idm_slots_2_valid,
    input  wire         idm_info_idm_slots_2_br_valid,
    input  wire [31:0]  idm_info_idm_slots_2_br_eip,
    input  wire [31:0]  idm_info_idm_slots_2_br_btb_target,
    input  wire         idm_info_idm_slots_2_br_xcl,

    input  wire         idm_info_idm_slots_3_valid,
    input  wire         idm_info_idm_slots_3_br_valid,
    input  wire [31:0]  idm_info_idm_slots_3_br_eip,
    input  wire [31:0]  idm_info_idm_slots_3_br_btb_target,
    input  wire         idm_info_idm_slots_3_br_xcl,

    input  wire [2:0]   idm_info_valid_slots,

    // ====================================================================
    // decode_outputs_t (decode_outs_i) -- only fields actually consumed
    // ====================================================================
    input  wire [31:0]  decode_outs_eip,
    input  wire         decode_outs_stall,
    input  wire         decode_outs_decode_forward,
    input  wire         decode_outs_invalid_instruction,

    // ====================================================================
    // rr_outputs_t (rr_outs_i) -- only fields actually consumed
    // ====================================================================
    input  wire         rr_outs_valid,
    input  wire         rr_outs_codeSeg_sb,
    input  wire [31:0]  rr_outs_codeSeg_data,
    input  wire [31:0]  rr_outs_codeSeg_limit,

    // ====================================================================
    // dc_outputs_t (dc_outs_i) -- only fields actually consumed
    // ====================================================================
    input  wire         dc_outs_valid,
    input  wire         dc_outs_exp_present,
    input  wire         dc_outs_exp_pf,

    // ====================================================================
    // mem_outputs_t (mem_outs_i) -- only valid consumed
    // ====================================================================
    input  wire         mem_outs_valid,

    // ====================================================================
    // exe_outputs_t (exe_outs_i) -- exe_br_resolution_outputs_t fields
    // ====================================================================
    input  wire         exe_outs_valid,
    input  wire         exe_outs_br_res_out_valid,
    input  wire         exe_outs_br_res_out_flush,
    input  wire         exe_outs_br_res_out_miss_prediction,
    input  wire [31:0]  exe_outs_br_res_out_br_eip,
    input  wire [31:0]  exe_outs_br_res_out_neip,
    input  wire [31:0]  exe_outs_br_res_out_br_target,
    input  wire         exe_outs_br_res_out_taken,
    input  wire         exe_outs_br_res_out_br_XCL,
    input  wire         exe_outs_br_res_out_clr_exp_mode,
    input  wire         exe_outs_br_res_out_br_ucond,

    // ====================================================================
    // wb_outputs_t (wb_outs_i) -- only valid consumed
    // ====================================================================
    input  wire         wb_outs_valid,

    input  wire         dma_int,

    // ====================================================================
    // fetch_outputs_t (outs_o) -- fully unrolled
    //   core_2_icache_t (fetch_2_icache):
    //     icache_en, p_addr (15-bit), v_addr_i (32-bit), num_valid_IDM_slots (3-bit)
    //   fetch_idm_ctrl_2_idm_t (idm_reqs):
    //     req[0..3] of idm_slot_req_t (data field packed 128-bit per slot)
    // ====================================================================
    output wire         outs_fetch_2_icache_icache_en,
    output wire [14:0]  outs_fetch_2_icache_p_addr,
    output wire [31:0]  outs_fetch_2_icache_v_addr_i,
    output wire [2:0]   outs_fetch_2_icache_num_valid_IDM_slots,

    output wire         outs_idm_reqs_req_0_ld_meta_data,
    output wire         outs_idm_reqs_req_0_ld_data,
    output wire         outs_idm_reqs_req_0_valid,
    output wire         outs_idm_reqs_req_0_br_valid,
    output wire [31:0]  outs_idm_reqs_req_0_br_eip,
    output wire [31:0]  outs_idm_reqs_req_0_br_target,
    output wire         outs_idm_reqs_req_0_br_xcl,
    output wire [127:0] outs_idm_reqs_req_0_data,

    output wire         outs_idm_reqs_req_1_ld_meta_data,
    output wire         outs_idm_reqs_req_1_ld_data,
    output wire         outs_idm_reqs_req_1_valid,
    output wire         outs_idm_reqs_req_1_br_valid,
    output wire [31:0]  outs_idm_reqs_req_1_br_eip,
    output wire [31:0]  outs_idm_reqs_req_1_br_target,
    output wire         outs_idm_reqs_req_1_br_xcl,
    output wire [127:0] outs_idm_reqs_req_1_data,

    output wire         outs_idm_reqs_req_2_ld_meta_data,
    output wire         outs_idm_reqs_req_2_ld_data,
    output wire         outs_idm_reqs_req_2_valid,
    output wire         outs_idm_reqs_req_2_br_valid,
    output wire [31:0]  outs_idm_reqs_req_2_br_eip,
    output wire [31:0]  outs_idm_reqs_req_2_br_target,
    output wire         outs_idm_reqs_req_2_br_xcl,
    output wire [127:0] outs_idm_reqs_req_2_data,

    output wire         outs_idm_reqs_req_3_ld_meta_data,
    output wire         outs_idm_reqs_req_3_ld_data,
    output wire         outs_idm_reqs_req_3_valid,
    output wire         outs_idm_reqs_req_3_br_valid,
    output wire [31:0]  outs_idm_reqs_req_3_br_eip,
    output wire [31:0]  outs_idm_reqs_req_3_br_target,
    output wire         outs_idm_reqs_req_3_br_xcl,
    output wire [127:0] outs_idm_reqs_req_3_data,

    output wire         outs_exp_pipe_clear,
    output wire         outs_exp_present,
    output wire         outs_exp_pf,
    output wire [1:0]   outs_exp_mode_jk,
    output wire         outs_int_mode_jk
);

    // ----------------------------------------------------------------
    // Internal storage outputs (driven by structural REG / JKFF cells)
    // ----------------------------------------------------------------
    wire [31:0] SPC;
    wire        DMA_int_jk;
    wire        exp_mode_jk_0;
    wire        exp_mode_jk_1;
    wire [1:0]  exp_mode_jk;
    wire        int_mode_jk;

    assign exp_mode_jk = {exp_mode_jk_1, exp_mode_jk_0};

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
    wire        spc_16_cout;
    wire [31:0] br_restore_spc;
    wire [31:0] br_target;
    wire [31:0] spc_2_IDM_CTRL;
    wire [31:0] br_restore_spc_aligned;
    wire [31:0] br_target_aligned;

    // ----------------------------------------------------------------
    // Mode-latch set/clear/WE/D wires.
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
    // tlb_inputs_t -- unrolled
    // ----------------------------------------------------------------
    wire [31:0] tlb_inputs_virtual_addr;
    wire        tlb_inputs_write_intention;
    assign tlb_inputs_virtual_addr    = seg_xlation_out;
    assign tlb_inputs_write_intention = 1'b0;

    // ----------------------------------------------------------------
    // tlb_outputs_t -- unrolled
    // ----------------------------------------------------------------
    wire [14:0] tlb_outs_physical_addr;
    wire        tlb_outs_physical_addr_valid;
    wire        tlb_outs_gp_exp;
    wire        tlb_outs_pageFault;
    wire        tlb_outs_MIO;

    // ----------------------------------------------------------------
    // btb_output_t -- unrolled
    // ----------------------------------------------------------------
    wire        btb_outs_hit;
    wire [31:0] btb_outs_br_target;
    wire [31:0] btb_outs_br_eip;
    wire        btb_outs_XCL;
    wire        btb_outs_br_ucond;

    // ----------------------------------------------------------------
    // predictor_output_t -- unrolled
    // ----------------------------------------------------------------
    wire        predictor_outs_taken;

    // ----------------------------------------------------------------
    // spc_sel_logic_output_t -- unrolled (sel kept as a 2-bit wire,
    // direct from SPC_Sel_Logic.sel; no SV enum cast needed).
    // ----------------------------------------------------------------
    wire [1:0]  spc_sel_logic_outs_sel;
    wire        spc_sel_logic_outs_br_target_sel;
    wire [31:0] spc_sel_logic_outs_br_target;
    wire        spc_sel_logic_outs_flush_reg;

    // ----------------------------------------------------------------
    // idm_invalidate_logic_output_t -- unrolled (invalidate is a 4-slot
    // unpacked array of nets, kept that way to drive submodule ports).
    // ----------------------------------------------------------------
    wire        idm_invalidate_logic_outs_invalidate [0:3];
    wire        idm_invalidate_logic_outs_no_writes;

    // ----------------------------------------------------------------
    // idm_ctrl_logic_output_t -- unrolled
    //   idm_input.req[0..3] of idm_slot_req_t ; data flattened to packed bus.
    // ----------------------------------------------------------------
    wire        idm_ctrl_logic_outs_idm_input_req_0_ld_meta_data;
    wire        idm_ctrl_logic_outs_idm_input_req_0_ld_data;
    wire        idm_ctrl_logic_outs_idm_input_req_0_valid;
    wire        idm_ctrl_logic_outs_idm_input_req_0_br_valid;
    wire [31:0] idm_ctrl_logic_outs_idm_input_req_0_br_eip;
    wire [31:0] idm_ctrl_logic_outs_idm_input_req_0_br_target;
    wire        idm_ctrl_logic_outs_idm_input_req_0_br_xcl;
    wire [127:0] idm_ctrl_logic_outs_idm_input_req_0_data;

    wire        idm_ctrl_logic_outs_idm_input_req_1_ld_meta_data;
    wire        idm_ctrl_logic_outs_idm_input_req_1_ld_data;
    wire        idm_ctrl_logic_outs_idm_input_req_1_valid;
    wire        idm_ctrl_logic_outs_idm_input_req_1_br_valid;
    wire [31:0] idm_ctrl_logic_outs_idm_input_req_1_br_eip;
    wire [31:0] idm_ctrl_logic_outs_idm_input_req_1_br_target;
    wire        idm_ctrl_logic_outs_idm_input_req_1_br_xcl;
    wire [127:0] idm_ctrl_logic_outs_idm_input_req_1_data;

    wire        idm_ctrl_logic_outs_idm_input_req_2_ld_meta_data;
    wire        idm_ctrl_logic_outs_idm_input_req_2_ld_data;
    wire        idm_ctrl_logic_outs_idm_input_req_2_valid;
    wire        idm_ctrl_logic_outs_idm_input_req_2_br_valid;
    wire [31:0] idm_ctrl_logic_outs_idm_input_req_2_br_eip;
    wire [31:0] idm_ctrl_logic_outs_idm_input_req_2_br_target;
    wire        idm_ctrl_logic_outs_idm_input_req_2_br_xcl;
    wire [127:0] idm_ctrl_logic_outs_idm_input_req_2_data;

    wire        idm_ctrl_logic_outs_idm_input_req_3_ld_meta_data;
    wire        idm_ctrl_logic_outs_idm_input_req_3_ld_data;
    wire        idm_ctrl_logic_outs_idm_input_req_3_valid;
    wire        idm_ctrl_logic_outs_idm_input_req_3_br_valid;
    wire [31:0] idm_ctrl_logic_outs_idm_input_req_3_br_eip;
    wire [31:0] idm_ctrl_logic_outs_idm_input_req_3_br_target;
    wire        idm_ctrl_logic_outs_idm_input_req_3_br_xcl;
    wire [127:0] idm_ctrl_logic_outs_idm_input_req_3_data;

    wire        idm_ctrl_logic_outs_push_success;

    // ----------------------------------------------------------------
    // exp_set_logic_output_t -- unrolled
    // ----------------------------------------------------------------
    wire        exp_set_logic_outs_exp_pipe_clear;
    wire        exp_set_logic_outs_dc_exp_set;
    wire        exp_set_logic_outs_int_pipe_clear;

    wire        en_icache;

    // ----------------------------------------------------------------
    // Adapter wires bridging the flat input/output ports to the
    // existing structural sub-modules whose ports use unpacked nets.
    // ----------------------------------------------------------------
    wire        idm_slot_valid_w          [0:3];
    wire        idm_slot_br_valid_w       [0:3];
    wire [31:0] idm_slot_br_eip_w         [0:3];
    wire [31:0] idm_slot_br_btb_target_w  [0:3];
    wire        idm_slot_br_xcl_w         [0:3];

    assign idm_slot_valid_w[0]         = idm_info_idm_slots_0_valid;
    assign idm_slot_valid_w[1]         = idm_info_idm_slots_1_valid;
    assign idm_slot_valid_w[2]         = idm_info_idm_slots_2_valid;
    assign idm_slot_valid_w[3]         = idm_info_idm_slots_3_valid;

    assign idm_slot_br_valid_w[0]      = idm_info_idm_slots_0_br_valid;
    assign idm_slot_br_valid_w[1]      = idm_info_idm_slots_1_br_valid;
    assign idm_slot_br_valid_w[2]      = idm_info_idm_slots_2_br_valid;
    assign idm_slot_br_valid_w[3]      = idm_info_idm_slots_3_br_valid;

    assign idm_slot_br_eip_w[0]        = idm_info_idm_slots_0_br_eip;
    assign idm_slot_br_eip_w[1]        = idm_info_idm_slots_1_br_eip;
    assign idm_slot_br_eip_w[2]        = idm_info_idm_slots_2_br_eip;
    assign idm_slot_br_eip_w[3]        = idm_info_idm_slots_3_br_eip;

    assign idm_slot_br_btb_target_w[0] = idm_info_idm_slots_0_br_btb_target;
    assign idm_slot_br_btb_target_w[1] = idm_info_idm_slots_1_br_btb_target;
    assign idm_slot_br_btb_target_w[2] = idm_info_idm_slots_2_br_btb_target;
    assign idm_slot_br_btb_target_w[3] = idm_info_idm_slots_3_br_btb_target;

    assign idm_slot_br_xcl_w[0]        = idm_info_idm_slots_0_br_xcl;
    assign idm_slot_br_xcl_w[1]        = idm_info_idm_slots_1_br_xcl;
    assign idm_slot_br_xcl_w[2]        = idm_info_idm_slots_2_br_xcl;
    assign idm_slot_br_xcl_w[3]        = idm_info_idm_slots_3_br_xcl;

    // IDM_Ctrl_Logic submodule scratch wires (unpacked) -> repacked outward.
    wire        idmc_ld_meta_data_w [0:3];
    wire        idmc_ld_data_w      [0:3];
    wire        idmc_valid_w        [0:3];
    wire        idmc_br_valid_w     [0:3];
    wire [31:0] idmc_br_eip_w       [0:3];
    wire [31:0] idmc_br_target_w    [0:3];
    wire        idmc_br_xcl_w       [0:3];
    wire [7:0]  idmc_data_w         [0:3] [0:15];
    wire        idmc_push_success_w;

    // Fan in from the per-slot unpacked submodule outputs to the
    // flattened idm_ctrl_logic_outs_* wires.
    assign idm_ctrl_logic_outs_idm_input_req_0_ld_meta_data = idmc_ld_meta_data_w[0];
    assign idm_ctrl_logic_outs_idm_input_req_0_ld_data      = idmc_ld_data_w[0];
    assign idm_ctrl_logic_outs_idm_input_req_0_valid        = idmc_valid_w[0];
    assign idm_ctrl_logic_outs_idm_input_req_0_br_valid     = idmc_br_valid_w[0];
    assign idm_ctrl_logic_outs_idm_input_req_0_br_eip       = idmc_br_eip_w[0];
    assign idm_ctrl_logic_outs_idm_input_req_0_br_target    = idmc_br_target_w[0];
    assign idm_ctrl_logic_outs_idm_input_req_0_br_xcl       = idmc_br_xcl_w[0];

    assign idm_ctrl_logic_outs_idm_input_req_1_ld_meta_data = idmc_ld_meta_data_w[1];
    assign idm_ctrl_logic_outs_idm_input_req_1_ld_data      = idmc_ld_data_w[1];
    assign idm_ctrl_logic_outs_idm_input_req_1_valid        = idmc_valid_w[1];
    assign idm_ctrl_logic_outs_idm_input_req_1_br_valid     = idmc_br_valid_w[1];
    assign idm_ctrl_logic_outs_idm_input_req_1_br_eip       = idmc_br_eip_w[1];
    assign idm_ctrl_logic_outs_idm_input_req_1_br_target    = idmc_br_target_w[1];
    assign idm_ctrl_logic_outs_idm_input_req_1_br_xcl       = idmc_br_xcl_w[1];

    assign idm_ctrl_logic_outs_idm_input_req_2_ld_meta_data = idmc_ld_meta_data_w[2];
    assign idm_ctrl_logic_outs_idm_input_req_2_ld_data      = idmc_ld_data_w[2];
    assign idm_ctrl_logic_outs_idm_input_req_2_valid        = idmc_valid_w[2];
    assign idm_ctrl_logic_outs_idm_input_req_2_br_valid     = idmc_br_valid_w[2];
    assign idm_ctrl_logic_outs_idm_input_req_2_br_eip       = idmc_br_eip_w[2];
    assign idm_ctrl_logic_outs_idm_input_req_2_br_target    = idmc_br_target_w[2];
    assign idm_ctrl_logic_outs_idm_input_req_2_br_xcl       = idmc_br_xcl_w[2];

    assign idm_ctrl_logic_outs_idm_input_req_3_ld_meta_data = idmc_ld_meta_data_w[3];
    assign idm_ctrl_logic_outs_idm_input_req_3_ld_data      = idmc_ld_data_w[3];
    assign idm_ctrl_logic_outs_idm_input_req_3_valid        = idmc_valid_w[3];
    assign idm_ctrl_logic_outs_idm_input_req_3_br_valid     = idmc_br_valid_w[3];
    assign idm_ctrl_logic_outs_idm_input_req_3_br_eip       = idmc_br_eip_w[3];
    assign idm_ctrl_logic_outs_idm_input_req_3_br_target    = idmc_br_target_w[3];
    assign idm_ctrl_logic_outs_idm_input_req_3_br_xcl       = idmc_br_xcl_w[3];

    // Pack the per-slot unpacked byte arrays (16 bytes each) into 128-bit buses.
    genvar gpi;
    generate
        for (gpi = 0; gpi < 16; gpi = gpi + 1) begin : g_idmc_pack
            assign idm_ctrl_logic_outs_idm_input_req_0_data[gpi*8 +: 8] = idmc_data_w[0][gpi];
            assign idm_ctrl_logic_outs_idm_input_req_1_data[gpi*8 +: 8] = idmc_data_w[1][gpi];
            assign idm_ctrl_logic_outs_idm_input_req_2_data[gpi*8 +: 8] = idmc_data_w[2][gpi];
            assign idm_ctrl_logic_outs_idm_input_req_3_data[gpi*8 +: 8] = idmc_data_w[3][gpi];
        end
    endgenerate

    assign idm_ctrl_logic_outs_push_success = idmc_push_success_w;

    // ----------------------------------------------------------------
    // Output port assigns
    // ----------------------------------------------------------------
    `OR_2(u_outs_exp_pipe_clear_or, 1, outs_exp_pipe_clear_w,
            exp_set_logic_outs_exp_pipe_clear, exp_set_logic_outs_int_pipe_clear)

    // fetch_2_icache.* and exp/mode top-level outputs
    assign outs_fetch_2_icache_icache_en           = en_icache;
    assign outs_fetch_2_icache_p_addr              = tlb_outs_physical_addr;
    assign outs_fetch_2_icache_v_addr_i            = seg_xlation_out;
    assign outs_fetch_2_icache_num_valid_IDM_slots = idm_info_valid_slots;
    assign outs_exp_pipe_clear                     = outs_exp_pipe_clear_w;
    assign outs_exp_present                        = f_exp;
    assign outs_exp_pf                             = tlb_outs_pageFault;
    assign outs_exp_mode_jk                        = exp_mode_jk;
    assign outs_int_mode_jk                        = int_mode_jk;

    // idm_reqs.req[0..3] outputs -- pass-through from idm_ctrl_logic_outs_*
    assign outs_idm_reqs_req_0_ld_meta_data = idm_ctrl_logic_outs_idm_input_req_0_ld_meta_data;
    assign outs_idm_reqs_req_0_ld_data      = idm_ctrl_logic_outs_idm_input_req_0_ld_data;
    assign outs_idm_reqs_req_0_valid        = idm_ctrl_logic_outs_idm_input_req_0_valid;
    assign outs_idm_reqs_req_0_br_valid     = idm_ctrl_logic_outs_idm_input_req_0_br_valid;
    assign outs_idm_reqs_req_0_br_eip       = idm_ctrl_logic_outs_idm_input_req_0_br_eip;
    assign outs_idm_reqs_req_0_br_target    = idm_ctrl_logic_outs_idm_input_req_0_br_target;
    assign outs_idm_reqs_req_0_br_xcl       = idm_ctrl_logic_outs_idm_input_req_0_br_xcl;
    assign outs_idm_reqs_req_0_data         = idm_ctrl_logic_outs_idm_input_req_0_data;

    assign outs_idm_reqs_req_1_ld_meta_data = idm_ctrl_logic_outs_idm_input_req_1_ld_meta_data;
    assign outs_idm_reqs_req_1_ld_data      = idm_ctrl_logic_outs_idm_input_req_1_ld_data;
    assign outs_idm_reqs_req_1_valid        = idm_ctrl_logic_outs_idm_input_req_1_valid;
    assign outs_idm_reqs_req_1_br_valid     = idm_ctrl_logic_outs_idm_input_req_1_br_valid;
    assign outs_idm_reqs_req_1_br_eip       = idm_ctrl_logic_outs_idm_input_req_1_br_eip;
    assign outs_idm_reqs_req_1_br_target    = idm_ctrl_logic_outs_idm_input_req_1_br_target;
    assign outs_idm_reqs_req_1_br_xcl       = idm_ctrl_logic_outs_idm_input_req_1_br_xcl;
    assign outs_idm_reqs_req_1_data         = idm_ctrl_logic_outs_idm_input_req_1_data;

    assign outs_idm_reqs_req_2_ld_meta_data = idm_ctrl_logic_outs_idm_input_req_2_ld_meta_data;
    assign outs_idm_reqs_req_2_ld_data      = idm_ctrl_logic_outs_idm_input_req_2_ld_data;
    assign outs_idm_reqs_req_2_valid        = idm_ctrl_logic_outs_idm_input_req_2_valid;
    assign outs_idm_reqs_req_2_br_valid     = idm_ctrl_logic_outs_idm_input_req_2_br_valid;
    assign outs_idm_reqs_req_2_br_eip       = idm_ctrl_logic_outs_idm_input_req_2_br_eip;
    assign outs_idm_reqs_req_2_br_target    = idm_ctrl_logic_outs_idm_input_req_2_br_target;
    assign outs_idm_reqs_req_2_br_xcl       = idm_ctrl_logic_outs_idm_input_req_2_br_xcl;
    assign outs_idm_reqs_req_2_data         = idm_ctrl_logic_outs_idm_input_req_2_data;

    assign outs_idm_reqs_req_3_ld_meta_data = idm_ctrl_logic_outs_idm_input_req_3_ld_meta_data;
    assign outs_idm_reqs_req_3_ld_data      = idm_ctrl_logic_outs_idm_input_req_3_ld_data;
    assign outs_idm_reqs_req_3_valid        = idm_ctrl_logic_outs_idm_input_req_3_valid;
    assign outs_idm_reqs_req_3_br_valid     = idm_ctrl_logic_outs_idm_input_req_3_br_valid;
    assign outs_idm_reqs_req_3_br_eip       = idm_ctrl_logic_outs_idm_input_req_3_br_eip;
    assign outs_idm_reqs_req_3_br_target    = idm_ctrl_logic_outs_idm_input_req_3_br_target;
    assign outs_idm_reqs_req_3_br_xcl       = idm_ctrl_logic_outs_idm_input_req_3_br_xcl;
    assign outs_idm_reqs_req_3_data         = idm_ctrl_logic_outs_idm_input_req_3_data;

    // ----------------------------------------------------------------
    // f_exp = (gp_exp | pageFault) & ~exp_mode_jk[0]
    // ----------------------------------------------------------------
    `OR_2 (u_tlb_or_exp,         1, tlb_or_exp,        tlb_outs_gp_exp, tlb_outs_pageFault)
    `INV_N(u_inv_exp_mode_jk_0,  1, exp_mode_jk_0,     not_exp_mode_jk_0)
    `AND_2(u_f_exp,              1, f_exp,             tlb_or_exp, not_exp_mode_jk_0)

    // ----------------------------------------------------------------
    // exp_or_int = exp_mode_jk[0] | exp_mode_jk[1] | int_mode_jk
    // ----------------------------------------------------------------
    `OR_3(u_exp_or_int, 1, exp_or_int, exp_mode_jk_0, exp_mode_jk_1, int_mode_jk)

    // ----------------------------------------------------------------
    // idm_ctrl_data_in[i] = exp_or_int ? rom_data_out[i]
    //                                  : icache_info_instruction_line[i*8 +: 8]
    // ----------------------------------------------------------------
    genvar gd;
    generate
        for (gd = 0; gd < 16; gd = gd + 1) begin : g_idm_data_mux
            `MUX_2(u_idm_data_mux, 8, idm_ctrl_data_in[gd],
                    icache_info_instruction_line[gd*8 +: 8], rom_data_out[gd], exp_or_int)
        end
    endgenerate

    // ----------------------------------------------------------------
    // br_restore_spc = taken ? br_target : neip
    // ----------------------------------------------------------------
    `MUX_2(u_br_restore_mux, 32, br_restore_spc,
            exe_outs_br_res_out_neip, exe_outs_br_res_out_br_target,
            exe_outs_br_res_out_taken)

    // ----------------------------------------------------------------
    // br_target = br_target_sel ? spc_sel_logic.br_target : btb.br_target
    // ----------------------------------------------------------------
    `MUX_2(u_br_target_mux, 32, br_target,
            btb_outs_br_target, spc_sel_logic_outs_br_target,
            spc_sel_logic_outs_br_target_sel)

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
    // next_spc 4-way mux on spc_sel_logic_outs_sel
    // ----------------------------------------------------------------
    assign br_restore_spc_aligned = {br_restore_spc[31:4], 4'b0000};
    assign br_target_aligned      = {br_target[31:4],      4'b0000};

    `MUX_4(u_next_spc_mux, 32, next_spc,
            SPC, spc_16, br_restore_spc_aligned, br_target_aligned,
            spc_sel_logic_outs_sel)

    // ----------------------------------------------------------------
    // SPC register: 32-bit reg, async-low rst, always-WE.
    // ----------------------------------------------------------------
    `REG_RST(u_spc_reg, 32, clk, rst, next_spc, SPC)

    // ----------------------------------------------------------------
    // Mode latches (REG_RST_WE -- async-low rst, sync WE).
    // ----------------------------------------------------------------
    `AND_2(u_flush_and_valid, 1, flush_and_valid,
            exe_outs_br_res_out_flush, exe_outs_br_res_out_valid)

    `OR_2 (u_exp_clr,         1, exp_clr,
            exe_outs_br_res_out_clr_exp_mode, flush_and_valid)
    `INV_N(u_n_exp_clr,       1, exp_clr,                          not_exp_clr)
    `INV_N(u_n_clr_exp_mode,  1, exe_outs_br_res_out_clr_exp_mode, not_clr_exp_mode)
    `INV_N(u_n_int_mode_jk,   1, int_mode_jk,                      not_int_mode_jk)

    // exp_mode_jk[0]
    `OR_2 (u_exp0_we, 1, exp0_we,
            exp_set_logic_outs_exp_pipe_clear, exp_clr)
    `AND_2(u_exp0_d,  1, exp0_d,
            exp_set_logic_outs_exp_pipe_clear, not_exp_clr)
    `REG_RST_WE(u_exp_mode_jk_0_reg, 1, clk, rst, exp0_we, exp0_d, exp_mode_jk_0)

    // exp_mode_jk[1]
    `OR_2 (u_exp1_we, 1, exp1_we,
            exp_set_logic_outs_dc_exp_set, exp_clr)
    `AND_2(u_exp1_d,  1, exp1_d,
            exp_set_logic_outs_dc_exp_set, not_exp_clr)
    `REG_RST_WE(u_exp_mode_jk_1_reg, 1, clk, rst, exp1_we, exp1_d, exp_mode_jk_1)

    // int_mode_jk
    `OR_2 (u_int_we, 1, int_we,
            exp_set_logic_outs_int_pipe_clear, exe_outs_br_res_out_clr_exp_mode)
    `AND_2(u_int_d,  1, int_d,
            exp_set_logic_outs_int_pipe_clear, not_clr_exp_mode)
    `REG_RST_WE(u_int_mode_jk_reg, 1, clk, rst, int_we, int_d, int_mode_jk)

    // DMA_int_jk
    `OR_2 (u_dma_we, 1, dma_we, dma_int, int_mode_jk)
    `AND_2(u_dma_d,  1, dma_d,  dma_int, not_int_mode_jk)
    `REG_RST_WE(u_dma_int_jk_reg, 1, clk, rst, dma_we, dma_d, DMA_int_jk)

    // ----------------------------------------------------------------
    // Sub-modules (already structural)
    // ----------------------------------------------------------------
    BTB btb(
        .clk(clk),
        .rst(rst),
        .spc(SPC),

        .exe_br_valid (exe_outs_br_res_out_valid),
        .exe_br_target(exe_outs_br_res_out_br_target),
        .exe_br_eip   (exe_outs_br_res_out_br_eip),
        .exe_br_XCL   (exe_outs_br_res_out_br_XCL),
        .exe_br_ucond (exe_outs_br_res_out_br_ucond),

        .hit       (btb_outs_hit),
        .br_target (btb_outs_br_target),
        .br_eip    (btb_outs_br_eip),
        .XCL       (btb_outs_XCL),
        .br_ucond  (btb_outs_br_ucond)
    );

    Predictor predictor(
        .clk          (clk),
        .rst          (rst),

        .spc          (SPC),
        .btb_hit      (btb_outs_hit),
        .exe_br_valid (exe_outs_br_res_out_valid),
        .exe_br_taken (exe_outs_br_res_out_taken),
        .exe_br_eip   (exe_outs_br_res_out_br_eip),
        .misprediction(exe_outs_br_res_out_miss_prediction),

        .taken        (predictor_outs_taken)
    );

    SPC_Sel_Logic spc_sel_logic(
        .clk          (clk),
        .rst          (rst),
        .spc          (SPC),
        .flush        (exe_outs_br_res_out_flush),
        .decode_stall (decode_outs_stall),

        .btb_hit       (btb_outs_hit),
        .btb_br_target (btb_outs_br_target),
        .btb_br_eip    (btb_outs_br_eip),
        .btb_XCL       (btb_outs_XCL),
        .btb_br_ucond  (btb_outs_br_ucond),

        .pred_taken            (predictor_outs_taken),
        .idm_ctrl_push_success (idm_ctrl_logic_outs_push_success),

        .sel           (spc_sel_logic_outs_sel),
        .br_target_sel (spc_sel_logic_outs_br_target_sel),
        .br_target     (spc_sel_logic_outs_br_target),
        .flush_reg     (spc_sel_logic_outs_flush_reg)
    );

    IDM_Ctrl_Logic idm_ctrl_logic (
        .exp_mode (exp_mode_jk_0),
        .int_mode (int_mode_jk),
        .spc      (spc_2_IDM_CTRL),

        .idm_slot_valid (idm_slot_valid_w),

        .invalidate (idm_invalidate_logic_outs_invalidate),
        .no_writes  (idm_invalidate_logic_outs_no_writes),

        .btb_hit       (btb_outs_hit),
        .btb_br_target (btb_outs_br_target),
        .btb_br_eip    (btb_outs_br_eip),
        .btb_XCL       (btb_outs_XCL),

        .pred_taken    (predictor_outs_taken),
        .icache_hit    (icache_info_hit),

        .spc_sel_flush_reg (spc_sel_logic_outs_flush_reg),

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

    IDM_Invalidate_Logic idm_invalidate_logic(
        .clk            (clk),
        .rst            (rst),
        .eip            (decode_outs_eip),
        .flush          (exe_outs_br_res_out_flush),
        .exp_pipeclear  (exp_set_logic_outs_exp_pipe_clear),
        .int_pipe_clear (exp_set_logic_outs_int_pipe_clear),
        .decode_stall   (decode_outs_stall),

        .idm_slot_valid          (idm_slot_valid_w),
        .idm_slot_br_valid       (idm_slot_br_valid_w),
        .idm_slot_br_eip         (idm_slot_br_eip_w),
        .idm_slot_br_btb_target  (idm_slot_br_btb_target_w),
        .idm_slot_br_xcl         (idm_slot_br_xcl_w),

        .decode_forward (decode_outs_decode_forward),

        .invalidate     (idm_invalidate_logic_outs_invalidate),
        .no_writes      (idm_invalidate_logic_outs_no_writes)
    );

    EXP_Set_logic exp_set_logic(
        .invalid_instruction(decode_outs_invalid_instruction),
        .rr_valid (rr_outs_valid),
        .dc_valid (dc_outs_valid),
        .mem_valid(mem_outs_valid),
        .exe_valid(exe_outs_valid),
        .wb_valid (wb_outs_valid),
        .f_exp    (f_exp),
        .dc_exp   (dc_outs_exp_present),
        .int_set  (DMA_int_jk),
        .exp_mode_jk(exp_mode_jk_0),
        .int_mode_jk(int_mode_jk),

        .exp_pipe_clear(exp_set_logic_outs_exp_pipe_clear),
        .dc_exp_set    (exp_set_logic_outs_dc_exp_set),
        .int_pipe_clear(exp_set_logic_outs_int_pipe_clear)
    );

    EXP_Ctrl_ROMS exp_ctrl_roms(
        .clk           (clk),
        .rst           (rst),
        .exp_pipe_clear(exp_set_logic_outs_exp_pipe_clear),
        .int_pipe_clear(exp_set_logic_outs_int_pipe_clear),
        .DC_pf         (dc_outs_exp_pf),
        .DC_exp        (dc_outs_exp_present),
        .Fetch_pf      (tlb_outs_pageFault),
        .DMA_int       (DMA_int_jk),
        .exp_mode      (exp_mode_jk_0),
        .rom_data_out  (rom_data_out)
    );

    ICache_En_Logic icache_en_logic(
        .rst(rst),
        .exp_mode(exp_mode_jk_0),
        .cs_sb(rr_outs_codeSeg_sb),
        .int_mode(int_mode_jk),
        .DMA_int(DMA_int_jk),
        .f_exp(f_exp),
        .out(en_icache)
    );

    TLB tlb(
        .virtual_addr       (tlb_inputs_virtual_addr),
        .write_intention    (tlb_inputs_write_intention),
        .physical_addr      (tlb_outs_physical_addr),
        .physical_addr_valid(tlb_outs_physical_addr_valid),
        .gp_exp             (tlb_outs_gp_exp),
        .pageFault          (tlb_outs_pageFault),
        .MIO                (tlb_outs_MIO)
    );

    SegmentTranslation seg_Xlation(
        .l_addr_i (SPC),
        .segValue (rr_outs_codeSeg_data),
        .segLimit (rr_outs_codeSeg_limit),
        .v_addr_o (seg_xlation_out),
        .gp_fault_o()
    );

endmodule
