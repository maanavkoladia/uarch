import common_pkg::*;
import interconnect_pkg::*;
import core_common_pkg::*;
import core_stage_latches_pkg::*;
import Fetch_pkg::*;
import reg_ids_pkg::*;
// ----------------------------------------------------------------
// Fetch — top-level structural port.
//
// Inputs / outputs are still SV structs (boundary unchanged: TLB,
// SegmentTranslation, and the rest of the core consume these structs).
// Inside the module everything is unrolled into flat wires and driven
// by structural cells / macros from STDCell_Macros.vh and the JK FF
// from lib/Gates/lib2.v.
//
// Mode latches (DMA_int_jk, exp_mode_jk[0/1], int_mode_jk) are
// implemented with REG_RST_WE rather than JK flops so that a "clear"
// strobe always wins over a coincident "set" — the JK toggle on
// J=K=1 was letting clr_exp_mode and a still-asserted int_pipe_clear
// fight, leaving int_mode_jk stuck high.
// ----------------------------------------------------------------
module Fetch (
    input wire clk,
    input wire rst,

    //en addr
    input icache_2_core_t icache_info_i,

    input idm_outputs_t idm_info_i,
    //invalid instruction for exp logic, also eip for prev eip invalidate
    //logic
    input decode_outputs_t decode_outs_i,

    //valid and exp logic
    input rr_outputs_t rr_outs_i,

    //valid and exp logic
    input dc_outputs_t dc_outs_i,

    //valid and exp logic
    input mem_outputs_t mem_outs_i,

    //valid, br.valid, br.target, br.eip, br.xcl, br.hit, br.taken, br.flush
    input exe_outputs_t exe_outs_i,

    //valid and exp logic
    input wb_outputs_t wb_outs_i,

    input wire dma_int,

    output fetch_outputs_t outs_o
);

    // ----------------------------------------------------------------
    // Internal storage outputs (driven by structural REG / JKFF cells)
    // ----------------------------------------------------------------
    wire [31:0] SPC;            // Structural Program Counter (32-bit reg)
    wire        DMA_int_jk;     // pending DMA interrupt JK
    wire        exp_mode_jk_0;  // generic exception mode JK (bit 0)
    wire        exp_mode_jk_1;  // DC-stage exception mode JK   (bit 1)
    wire [1:0]  exp_mode_jk;
    wire        int_mode_jk;    // interrupt servicing JK

    assign exp_mode_jk = {exp_mode_jk_1, exp_mode_jk_0};

    // ----------------------------------------------------------------
    // Combinational scalar / vector wires
    // ----------------------------------------------------------------
    wire        f_exp;
    wire        tlb_or_exp;
    wire        not_exp_mode_jk_0;
    wire        exp_or_int;                 // exp_mode_jk[0|1] | int_mode_jk
    wire        flush_and_valid;
    wire        outs_exp_pipe_clear;

    wire [31:0] seg_xlation_out;
    wire [7:0]  rom_data_out      [0:CACHE_LINES_SIZE_B-1];
    wire [7:0]  idm_ctrl_data_in  [0:CACHE_LINES_SIZE_B-1];
    wire [31:0] next_spc;
    wire [31:0] spc_16;
    wire        spc_16_cout;                // unused
    wire [31:0] br_restore_spc;
    wire [31:0] br_target;
    wire [31:0] spc_2_IDM_CTRL;
    wire [31:0] br_restore_spc_aligned;
    wire [31:0] br_target_aligned;

    // ----------------------------------------------------------------
    // Mode-latch set/clear/WE/D wires (REG_RST_WE based; clear-dominates).
    // ----------------------------------------------------------------
    wire        exp_clr;        // shared clear for exp_mode_jk[0] and [1]
    wire        not_exp_clr;
    wire        not_clr_exp_mode;
    wire        not_int_mode_jk;

    wire        exp0_we, exp0_d;
    wire        exp1_we, exp1_d;
    wire        int_we,  int_d;
    wire        dma_we,  dma_d;

    // ----------------------------------------------------------------
    // SV-side structs kept so sub-modules / TLB / SegmentTranslation
    // (still struct-port) connect unchanged.
    // ----------------------------------------------------------------
    tlb_inputs_t                  tlb_inputs;
    btb_output_t                  btb_outs;
    spc_sel_logic_output_t        spc_sel_logic_outs;
    predictor_output_t            predictor_outs;
    idm_ctrl_logic_output_t       idm_ctrl_logic_outs;
    idm_invalidate_logic_output_t idm_invalidate_logic_outs;
    tlb_outputs_t                 tlb_outs;
    exp_set_logic_output_t        exp_set_logic_outs;

    wire        en_icache;
    wire [1:0]  spc_sel_w;

    // ----------------------------------------------------------------
    // Adapter wires bridging the SV structs to flat sub-module ports.
    // ----------------------------------------------------------------
    wire        idm_slot_valid_w          [0:NUM_IDM_SLOTS-1];
    wire        idm_slot_br_valid_w       [0:NUM_IDM_SLOTS-1];
    wire [31:0] idm_slot_br_eip_w         [0:NUM_IDM_SLOTS-1];
    wire [31:0] idm_slot_br_btb_target_w  [0:NUM_IDM_SLOTS-1];
    wire        idm_slot_br_xcl_w         [0:NUM_IDM_SLOTS-1];

    wire        idmc_ld_meta_data_w [0:NUM_IDM_SLOTS-1];
    wire        idmc_ld_data_w      [0:NUM_IDM_SLOTS-1];
    wire        idmc_valid_w        [0:NUM_IDM_SLOTS-1];
    wire        idmc_br_valid_w     [0:NUM_IDM_SLOTS-1];
    wire [31:0] idmc_br_eip_w       [0:NUM_IDM_SLOTS-1];
    wire [31:0] idmc_br_target_w    [0:NUM_IDM_SLOTS-1];
    wire        idmc_br_xcl_w       [0:NUM_IDM_SLOTS-1];
    wire [7:0]  idmc_data_w         [0:NUM_IDM_SLOTS-1] [0:CACHE_LINES_SIZE_B-1];
    wire        idmc_push_success_w;

    genvar gs;
    generate
        for (gs = 0; gs < NUM_IDM_SLOTS; gs = gs + 1) begin : g_idm_slot_unpack
            assign idm_slot_valid_w[gs]         = idm_info_i.idm_slots[gs].valid;
            assign idm_slot_br_valid_w[gs]      = idm_info_i.idm_slots[gs].br_valid;
            assign idm_slot_br_eip_w[gs]        = idm_info_i.idm_slots[gs].br_eip;
            assign idm_slot_br_btb_target_w[gs] = idm_info_i.idm_slots[gs].br_btb_target;
            assign idm_slot_br_xcl_w[gs]        = idm_info_i.idm_slots[gs].br_xcl;
        end
    endgenerate

    genvar gs2, gk;
    generate
        for (gs2 = 0; gs2 < NUM_IDM_SLOTS; gs2 = gs2 + 1) begin : g_idmc_repack
            assign idm_ctrl_logic_outs.idm_input.req[gs2].ld_meta_data = idmc_ld_meta_data_w[gs2];
            assign idm_ctrl_logic_outs.idm_input.req[gs2].ld_data      = idmc_ld_data_w[gs2];
            assign idm_ctrl_logic_outs.idm_input.req[gs2].valid        = idmc_valid_w[gs2];
            assign idm_ctrl_logic_outs.idm_input.req[gs2].br_valid     = idmc_br_valid_w[gs2];
            assign idm_ctrl_logic_outs.idm_input.req[gs2].br_eip       = idmc_br_eip_w[gs2];
            assign idm_ctrl_logic_outs.idm_input.req[gs2].br_target    = idmc_br_target_w[gs2];
            assign idm_ctrl_logic_outs.idm_input.req[gs2].br_xcl       = idmc_br_xcl_w[gs2];

            for (gk = 0; gk < CACHE_LINES_SIZE_B; gk = gk + 1) begin : g_idmc_data_repack
                assign idm_ctrl_logic_outs.idm_input.req[gs2].data[gk] = idmc_data_w[gs2][gk];
            end
        end
    endgenerate
    assign idm_ctrl_logic_outs.push_success = idmc_push_success_w;
    assign spc_sel_logic_outs.sel = spc_sel_logic_output_options_e'(spc_sel_w);

    // ----------------------------------------------------------------
    // Output struct field assigns
    //   outs_o.exp_pipe_clear = exp_pipe_clear | int_pipe_clear  (OR_2)
    //   everything else is wire aliasing.
    // ----------------------------------------------------------------
    `OR_2(u_outs_exp_pipe_clear_or, 1, outs_exp_pipe_clear,
            exp_set_logic_outs.exp_pipe_clear, exp_set_logic_outs.int_pipe_clear)

    assign outs_o.idm_reqs                              = idm_ctrl_logic_outs.idm_input;
    assign outs_o.exp_pipe_clear                        = outs_exp_pipe_clear;
    assign outs_o.fetch_2_icache.icache_en              = en_icache;
    assign outs_o.fetch_2_icache.p_addr                 = tlb_outs.physical_addr;
    assign outs_o.fetch_2_icache.v_addr_i               = seg_xlation_out;
    assign outs_o.fetch_2_icache.num_valid_IDM_slots    = idm_info_i.valid_slots;
    assign outs_o.exp_present                           = f_exp;
    assign outs_o.exp_pf                                = tlb_outs.pageFault;
    assign outs_o.exp_mode_jk                           = exp_mode_jk;
    assign outs_o.int_mode_jk                           = int_mode_jk;

    // ----------------------------------------------------------------
    // f_exp = (gp_exp | pageFault) & ~exp_mode_jk[0]
    // ----------------------------------------------------------------
    `OR_2 (u_tlb_or_exp,         1, tlb_or_exp,        tlb_outs.gp_exp, tlb_outs.pageFault)
    `INV_N(u_inv_exp_mode_jk_0,  1, exp_mode_jk_0,     not_exp_mode_jk_0)
    `AND_2(u_f_exp,              1, f_exp,             tlb_or_exp, not_exp_mode_jk_0)

    // ----------------------------------------------------------------
    // exp_or_int = exp_mode_jk[0] | exp_mode_jk[1] | int_mode_jk
    //   (mirrors the SV ``(exp_mode_jk || int_mode_jk)`` reduce.)
    // ----------------------------------------------------------------
    `OR_3(u_exp_or_int, 1, exp_or_int, exp_mode_jk_0, exp_mode_jk_1, int_mode_jk)

    // ----------------------------------------------------------------
    // tlb_inputs — kept as a struct because TLB still has struct ports.
    // Field-level wire aliasing only (no logic).
    // ----------------------------------------------------------------
    assign tlb_inputs.virtual_addr    = seg_xlation_out;
    assign tlb_inputs.write_intention = 1'b0;

    // ----------------------------------------------------------------
    // idm_ctrl_data_in[i] = exp_or_int ? rom_data_out[i]
    //                                  : icache_info_i.instruction_line[i]
    // ----------------------------------------------------------------
    genvar gd;
    generate
        for (gd = 0; gd < CACHE_LINES_SIZE_B; gd = gd + 1) begin : g_idm_data_mux
            `MUX_2(u_idm_data_mux, 8, idm_ctrl_data_in[gd],
                    icache_info_i.instruction_line[gd], rom_data_out[gd], exp_or_int)
        end
    endgenerate

    // ----------------------------------------------------------------
    // br_restore_spc = taken ? br_target : neip
    // ----------------------------------------------------------------
    `MUX_2(u_br_restore_mux, 32, br_restore_spc,
            exe_outs_i.br_res_out.neip, exe_outs_i.br_res_out.br_target,
            exe_outs_i.br_res_out.taken)

    // ----------------------------------------------------------------
    // br_target = br_target_sel ? spc_sel_logic.br_target : btb.br_target
    // ----------------------------------------------------------------
    `MUX_2(u_br_target_mux, 32, br_target,
            btb_outs.br_target, spc_sel_logic_outs.br_target,
            spc_sel_logic_outs.br_target_sel)

    // ----------------------------------------------------------------
    // spc_2_IDM_CTRL = exp_or_int ? 32'h0 : SPC
    //   (forces slot-number address to 0 during exp/int routines)
    // ----------------------------------------------------------------
    `MUX_2(u_spc_2_idm_ctrl_mux, 32, spc_2_IDM_CTRL,
            SPC, 32'h00000000, exp_or_int)

    // ----------------------------------------------------------------
    // spc_16 = SPC + 16   (Kogge-Stone add, cin=0)
    // ----------------------------------------------------------------
    `ADD_N(u_spc_plus_16, 32, spc_16, spc_16_cout, SPC, 32'h00000010, 1'b0)

    // ----------------------------------------------------------------
    // next_spc 4-way mux on spc_sel_logic_outs.sel
    //   00 SPC        : SPC
    //   01 SPC_P16    : spc_16
    //   10 BR_RESTORE : {br_restore_spc[31:4], 4'b0}
    //   11 BTB_TARGET : {br_target[31:4], 4'b0}
    // ----------------------------------------------------------------
    assign br_restore_spc_aligned = {br_restore_spc[31:4], 4'b0000};
    assign br_target_aligned      = {br_target[31:4],      4'b0000};

    `MUX_4(u_next_spc_mux, 32, next_spc,
            SPC, spc_16, br_restore_spc_aligned, br_target_aligned,
            spc_sel_w)

    // ----------------------------------------------------------------
    // SPC register: 32-bit reg, async-low rst, always-WE.
    // ----------------------------------------------------------------
    `REG_RST(u_spc_reg, 32, clk, rst, next_spc, SPC)

    // ----------------------------------------------------------------
    // Mode latches (REG_RST_WE — async-low rst, sync WE).
    //
    // For each latch:  WE = set | clr;  D = set & ~clr.
    // → clr=0,set=0: WE=0, hold.
    // → clr=0,set=1: load 1.   clr=1,set=0/1: load 0 (clr always wins).
    //
    // exp_mode_jk[0]: set=exp_pipe_clear,    clr=clr_exp_mode | flush_and_valid
    // exp_mode_jk[1]: set=dc_exp_set,        clr=clr_exp_mode | flush_and_valid
    // int_mode_jk  : set=int_pipe_clear,     clr=clr_exp_mode
    // DMA_int_jk   : set=dma_int,            clr=int_mode_jk
    //
    // EXP_Set_logic already gates int_pipe_clear with ~int_mode_jk, so once
    // int_mode_jk is set the set-path stops asserting; the only way out is
    // clr_exp_mode from execute.
    // ----------------------------------------------------------------
    `AND_2(u_flush_and_valid, 1, flush_and_valid,
            exe_outs_i.br_res_out.flush, exe_outs_i.br_res_out.valid)

    // Shared clear for both exp latches.
    `OR_2 (u_exp_clr,         1, exp_clr,
            exe_outs_i.br_res_out.clr_exp_mode, flush_and_valid)
    `INV_N(u_n_exp_clr,       1, exp_clr,                            not_exp_clr)
    `INV_N(u_n_clr_exp_mode,  1, exe_outs_i.br_res_out.clr_exp_mode, not_clr_exp_mode)
    `INV_N(u_n_int_mode_jk,   1, int_mode_jk,                        not_int_mode_jk)

    // exp_mode_jk[0]
    `OR_2 (u_exp0_we, 1, exp0_we,
            exp_set_logic_outs.exp_pipe_clear, exp_clr)
    `AND_2(u_exp0_d,  1, exp0_d,
            exp_set_logic_outs.exp_pipe_clear, not_exp_clr)
    `REG_RST_WE(u_exp_mode_jk_0_reg, 1, clk, rst, exp0_we, exp0_d, exp_mode_jk_0)

    // exp_mode_jk[1]
    `OR_2 (u_exp1_we, 1, exp1_we,
            exp_set_logic_outs.dc_exp_set, exp_clr)
    `AND_2(u_exp1_d,  1, exp1_d,
            exp_set_logic_outs.dc_exp_set, not_exp_clr)
    `REG_RST_WE(u_exp_mode_jk_1_reg, 1, clk, rst, exp1_we, exp1_d, exp_mode_jk_1)

    // int_mode_jk
    `OR_2 (u_int_we, 1, int_we,
            exp_set_logic_outs.int_pipe_clear, exe_outs_i.br_res_out.clr_exp_mode)
    `AND_2(u_int_d,  1, int_d,
            exp_set_logic_outs.int_pipe_clear, not_clr_exp_mode)
    `REG_RST_WE(u_int_mode_jk_reg, 1, clk, rst, int_we, int_d, int_mode_jk)

    // DMA_int_jk
    `OR_2 (u_dma_we, 1, dma_we, dma_int, int_mode_jk)
    `AND_2(u_dma_d,  1, dma_d,  dma_int, not_int_mode_jk)
    `REG_RST_WE(u_dma_int_jk_reg, 1, clk, rst, dma_we, dma_d, DMA_int_jk)

    // ----------------------------------------------------------------
    // Sub-modules (already structural)
    // ----------------------------------------------------------------

    // BTB Training Note:
    // Special branches in exception/interrupt handlers (indicated by CS)
    // do not send training signals (exe_br_valid controlled by execute stage)
    // This prevents exception handler branches from polluting user BTB entries
    BTB btb(
        .clk(clk),
        .rst(rst),
        .spc(SPC),

        .exe_br_valid (exe_outs_i.br_res_out.valid),
        .exe_br_target(exe_outs_i.br_res_out.br_target),
        .exe_br_eip   (exe_outs_i.br_res_out.br_eip),
        .exe_br_XCL   (exe_outs_i.br_res_out.br_XCL),
        .exe_br_ucond (exe_outs_i.br_res_out.br_ucond),

        .hit       (btb_outs.hit),
        .br_target (btb_outs.br_target),
        .br_eip    (btb_outs.br_eip),
        .XCL       (btb_outs.XCL),
        .br_ucond  (btb_outs.br_ucond)
    );

    Predictor predictor(
        .clk          (clk),
        .rst          (rst),

        .spc          (SPC),
        .btb_hit      (btb_outs.hit),
        .exe_br_valid (exe_outs_i.br_res_out.valid),
        .exe_br_taken (exe_outs_i.br_res_out.taken),
        .exe_br_eip   (exe_outs_i.br_res_out.br_eip),
        .misprediction(exe_outs_i.br_res_out.miss_prediction),

        .taken        (predictor_outs.taken)
    );

    SPC_Sel_Logic spc_sel_logic(
        .clk          (clk),
        .rst          (rst),
        .spc          (SPC),
        .flush        (exe_outs_i.br_res_out.flush),
        .decode_stall (decode_outs_i.stall),

        .btb_hit       (btb_outs.hit),
        .btb_br_target (btb_outs.br_target),
        .btb_br_eip    (btb_outs.br_eip),
        .btb_XCL       (btb_outs.XCL),
        .btb_br_ucond  (btb_outs.br_ucond),

        .pred_taken            (predictor_outs.taken),
        .idm_ctrl_push_success (idm_ctrl_logic_outs.push_success),

        .sel           (spc_sel_w),
        .br_target_sel (spc_sel_logic_outs.br_target_sel),
        .br_target     (spc_sel_logic_outs.br_target),
        .flush_reg     (spc_sel_logic_outs.flush_reg)
    );

    IDM_Ctrl_Logic idm_ctrl_logic (
        .exp_mode (exp_mode_jk_0),
        .int_mode (int_mode_jk),
        .spc      (spc_2_IDM_CTRL),

        .idm_slot_valid (idm_slot_valid_w),

        .invalidate (idm_invalidate_logic_outs.invalidate),
        .no_writes  (idm_invalidate_logic_outs.no_writes),

        .btb_hit       (btb_outs.hit),
        .btb_br_target (btb_outs.br_target),
        .btb_br_eip    (btb_outs.br_eip),
        .btb_XCL       (btb_outs.XCL),

        .pred_taken    (predictor_outs.taken),
        .icache_hit    (icache_info_i.hit),

        .spc_sel_flush_reg (spc_sel_logic_outs.flush_reg),

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
        .eip            (decode_outs_i.eip),
        .flush          (exe_outs_i.br_res_out.flush),
        .exp_pipeclear  (exp_set_logic_outs.exp_pipe_clear),
        .int_pipe_clear (exp_set_logic_outs.int_pipe_clear),
        .decode_stall   (decode_outs_i.stall),

        .idm_slot_valid          (idm_slot_valid_w),
        .idm_slot_br_valid       (idm_slot_br_valid_w),
        .idm_slot_br_eip         (idm_slot_br_eip_w),
        .idm_slot_br_btb_target  (idm_slot_br_btb_target_w),
        .idm_slot_br_xcl         (idm_slot_br_xcl_w),

        .decode_forward (decode_outs_i.decode_forward),

        .invalidate     (idm_invalidate_logic_outs.invalidate),
        .no_writes      (idm_invalidate_logic_outs.no_writes)
    );

    EXP_Set_logic exp_set_logic(
        .invalid_instruction(decode_outs_i.invalid_instruction),
        .rr_valid (rr_outs_i.valid),
        .dc_valid (dc_outs_i.valid),
        .mem_valid(mem_outs_i.valid),
        .exe_valid(exe_outs_i.valid),
        .wb_valid (wb_outs_i.valid),
        .f_exp    (f_exp),
        .dc_exp   (dc_outs_i.exp_present),
        .int_set  (DMA_int_jk),
        .exp_mode_jk(exp_mode_jk_0),
        .int_mode_jk(int_mode_jk),

        .exp_pipe_clear(exp_set_logic_outs.exp_pipe_clear),
        .dc_exp_set    (exp_set_logic_outs.dc_exp_set),
        .int_pipe_clear(exp_set_logic_outs.int_pipe_clear)
    );

    EXP_Ctrl_ROMS exp_ctrl_roms(
        .clk           (clk),
        .rst           (rst),
        .exp_pipe_clear(exp_set_logic_outs.exp_pipe_clear),
        .int_pipe_clear(exp_set_logic_outs.int_pipe_clear),
        .DC_pf         (dc_outs_i.exp_pf),
        .DC_exp        (dc_outs_i.exp_present),
        .Fetch_pf      (tlb_outs.pageFault),
        .DMA_int       (DMA_int_jk),
        .exp_mode      (exp_mode_jk_0),
        .rom_data_out  (rom_data_out)
    );

    //spc to icache path
    ICache_En_Logic icache_en_logic(
        .rst(rst),
        .exp_mode(exp_mode_jk_0),
        .cs_sb(rr_outs_i.codeSeg_sb),
        .int_mode(int_mode_jk),
        .DMA_int(DMA_int_jk),
        .f_exp(f_exp),
        .out(en_icache)
    );

    TLB tlb(
        .virtual_addr(tlb_inputs.virtual_addr),
        .write_intention(tlb_inputs.write_intention),
        .physical_addr(tlb_outs.physical_addr),
        .physical_addr_valid(tlb_outs.physical_addr_valid),
        .gp_exp(tlb_outs.gp_exp),
        .pageFault(tlb_outs.pageFault),
        .MIO(tlb_outs.MIO)
    );

    SegmentTranslation seg_Xlation(
        .l_addr_i (SPC),
        .segValue (rr_outs_i.codeSeg_data),
        .segLimit (rr_outs_i.codeSeg_limit),
        .v_addr_o (seg_xlation_out),
        .gp_fault_o()
    );

endmodule
