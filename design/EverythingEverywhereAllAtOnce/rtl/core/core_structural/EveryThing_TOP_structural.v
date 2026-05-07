
module EveryThing_TOP (
    input wire clk,
    input wire rst,

    //icache 2 core
    input wire         out_hit,
    input wire [127:0] out_instruction_line,

    //dma to core
    input wire inFromDMA_i

    //core 2 dcache
    input wire         dcache2Core_reqServed_0_o,
    input wire         dcache2Core_reqServed_1_o,
    input wire         dcache2Core_hit_0_o,
    input wire         dcache2Core_hit_1_o,
    input wire         dcache2Core_hit_2_o,
    input wire         dcache2Core_hit_3_o,
    input wire [127:0] dcache2Core_cacheline_0_o,
    input wire [127:0] dcache2Core_cacheline_1_o,
    input wire [127:0] dcache2Core_cacheline_2_o,
    input wire [127:0] dcache2Core_cacheline_3_o,
    input wire         dcache2Core_writeSuccess_0_o,
    input wire         dcache2Core_writeSuccess_1_o,
    input wire         dcache2Core_writeSuccess_2_o,
    input wire         dcache2Core_writeSuccess_3_o,
    input wire         dcache2Core_writeSuccess_MIO_o,
    input wire         dcache2Core_hit_MIO_o,
    input wire         dcache2Core_reqServed_MIO_o,
    input wire [127:0] dcache2Core_line_MIO_o,

    // ----- core_2_dcache_t inFromCore_i (unpacked) -----
    output  wire        core_ld_addr_0_V_i,
    output  wire [14:0] core_ld_addr_0_i,
    output  wire        core_ld_addr_1_V_i,
    output  wire [14:0] core_ld_addr_1_i,
    output  wire        core_stq_full_0_i,
    output  wire        core_stq_full_1_i,
    output  wire        core_stq_full_2_i,
    output  wire        core_stq_full_3_i,
    output  wire        core_stq_empty_0_i,
    output  wire        core_stq_empty_1_i,
    output  wire        core_stq_empty_2_i,
    output  wire        core_stq_empty_3_i,
    output  wire [14:0] core_stq_addr_0_i,
    output  wire [14:0] core_stq_addr_1_i,
    output  wire [14:0] core_stq_addr_2_i,
    output  wire [14:0] core_stq_addr_3_i,
    output  wire [15:0] core_stq_bitvec_0_i,
    output  wire [15:0] core_stq_bitvec_1_i,
    output  wire [15:0] core_stq_bitvec_2_i,
    output  wire [15:0] core_stq_bitvec_3_i,
    output  wire [127:0] core_stq_data_0_i,
    output  wire [127:0] core_stq_data_1_i,
    output  wire [127:0] core_stq_data_2_i,
    output  wire [127:0] core_stq_data_3_i,
    output  wire        core_ld_addr_MIO_V_i,
    output  wire [14:0] core_ld_addr_MIO_i,
    output  wire        core_stq_info_mio_empty_i,
    output  wire [14:0] core_stq_info_mio_addr_i,
    output  wire [127:0] core_stq_info_mio_data_i,
    output  wire        core_memStage_CLR_REQ_0_i,
    output  wire        core_memStage_CLR_REQ_1_i,
    output  wire        core_memStage_CLR_REQ_2_i,
    output  wire        core_memStage_CLR_REQ_3_i,
    output  wire        core_memStage_CLR_REQ_MIO_i,

    //core_2_icache
    output  wire         icache_en,
    output  wire [14:0]  p_addr,
    output  wire [31:0]  v_addr_i,
    output  wire [2:0]   num_valid_IDM_slots,
);

    `FETCH_OUTPUTS
    `IDM_OUTPUTS
    `DECODE_OUTPUTS
    `RR_LATCHES
    `RR_OUTPUTS
    `DC_OUTPUTS
    `MEM_OUTPUTS
    `EXE_OUTPUTS
    `WB_OUTPUTS

    // ---- top-level icache port drives (from Fetch.outs_fetch_2_icache_*) ----
    assign icache_en           = fetch_outputs_fetch_2_icache_icache_en;
    assign p_addr              = fetch_outputs_fetch_2_icache_p_addr;
    assign v_addr_i            = fetch_outputs_fetch_2_icache_v_addr_i;
    assign num_valid_IDM_slots = fetch_outputs_fetch_2_icache_num_valid_IDM_slots;

    // ---- top-level core_2_dcache port drives ----
    //   stq_heads[0..3]   (from WB.outputs.stq_heads[*])
    //   mio_head          (from WB.outputs.mio_head)
    //   memStage CLR_REQ  (from MEM.outputs.clr_dcache_arb_latches_*/clr_dcache_mio_latch)
    //   ld_addr_*         (from MEM/DC -- TODO: source wires not yet in macros)

    // stq_heads[0..3] -> core_stq_*_<n>_i
    assign core_stq_full_0_i   = wb_outputs_stq_heads_0_full;
    assign core_stq_empty_0_i  = wb_outputs_stq_heads_0_empty;
    assign core_stq_addr_0_i   = wb_outputs_stq_heads_0_address;
    assign core_stq_bitvec_0_i = wb_outputs_stq_heads_0_bit_vec;
    assign core_stq_data_0_i   = wb_outputs_stq_heads_0_data;

    assign core_stq_full_1_i   = wb_outputs_stq_heads_1_full;
    assign core_stq_empty_1_i  = wb_outputs_stq_heads_1_empty;
    assign core_stq_addr_1_i   = wb_outputs_stq_heads_1_address;
    assign core_stq_bitvec_1_i = wb_outputs_stq_heads_1_bit_vec;
    assign core_stq_data_1_i   = wb_outputs_stq_heads_1_data;

    assign core_stq_full_2_i   = wb_outputs_stq_heads_2_full;
    assign core_stq_empty_2_i  = wb_outputs_stq_heads_2_empty;
    assign core_stq_addr_2_i   = wb_outputs_stq_heads_2_address;
    assign core_stq_bitvec_2_i = wb_outputs_stq_heads_2_bit_vec;
    assign core_stq_data_2_i   = wb_outputs_stq_heads_2_data;

    assign core_stq_full_3_i   = wb_outputs_stq_heads_3_full;
    assign core_stq_empty_3_i  = wb_outputs_stq_heads_3_empty;
    assign core_stq_addr_3_i   = wb_outputs_stq_heads_3_address;
    assign core_stq_bitvec_3_i = wb_outputs_stq_heads_3_bit_vec;
    assign core_stq_data_3_i   = wb_outputs_stq_heads_3_data;

    // mio_head -> core_stq_info_mio_*_i
    assign core_stq_info_mio_empty_i = wb_outputs_mio_head_empty;
    assign core_stq_info_mio_addr_i  = wb_outputs_mio_head_address;
    assign core_stq_info_mio_data_i  = wb_outputs_mio_head_data;

    // mem-stage CLR_REQ -> core_memStage_CLR_REQ_*_i
    assign core_memStage_CLR_REQ_0_i   = mem_outputs_clr_dcache_arb_latches_0;
    assign core_memStage_CLR_REQ_1_i   = mem_outputs_clr_dcache_arb_latches_1;
    assign core_memStage_CLR_REQ_2_i   = mem_outputs_clr_dcache_arb_latches_2;
    assign core_memStage_CLR_REQ_3_i   = mem_outputs_clr_dcache_arb_latches_3;
    assign core_memStage_CLR_REQ_MIO_i = mem_outputs_clr_dcache_mio_latch;
    // =========================================================================
    // Fetch
    // =========================================================================
// =========================================================================
    // Fetch
    // =========================================================================
    Fetch fetch_unit (
        .clk(clk),
        .rst(rst),

        // ---- icache_info (icache_2_core_t) ----
        .icache_info_hit              (out_hit),
        .icache_info_instruction_line (out_instruction_line),

        // ---- idm_info (idm_outputs_t) -- only fields read by Fetch ----
        .idm_info_idm_slots_0_valid         (idm_outputs_idm_slots_0_valid),
        .idm_info_idm_slots_0_br_valid      (idm_outputs_idm_slots_0_br_valid),
        .idm_info_idm_slots_0_br_eip        (idm_outputs_idm_slots_0_br_eip),
        .idm_info_idm_slots_0_br_btb_target (idm_outputs_idm_slots_0_br_btb_target),
        .idm_info_idm_slots_0_br_xcl        (idm_outputs_idm_slots_0_br_xcl),
        .idm_info_idm_slots_1_valid         (idm_outputs_idm_slots_1_valid),
        .idm_info_idm_slots_1_br_valid      (idm_outputs_idm_slots_1_br_valid),
        .idm_info_idm_slots_1_br_eip        (idm_outputs_idm_slots_1_br_eip),
        .idm_info_idm_slots_1_br_btb_target (idm_outputs_idm_slots_1_br_btb_target),
        .idm_info_idm_slots_1_br_xcl        (idm_outputs_idm_slots_1_br_xcl),
        .idm_info_idm_slots_2_valid         (idm_outputs_idm_slots_2_valid),
        .idm_info_idm_slots_2_br_valid      (idm_outputs_idm_slots_2_br_valid),
        .idm_info_idm_slots_2_br_eip        (idm_outputs_idm_slots_2_br_eip),
        .idm_info_idm_slots_2_br_btb_target (idm_outputs_idm_slots_2_br_btb_target),
        .idm_info_idm_slots_2_br_xcl        (idm_outputs_idm_slots_2_br_xcl),
        .idm_info_idm_slots_3_valid         (idm_outputs_idm_slots_3_valid),
        .idm_info_idm_slots_3_br_valid      (idm_outputs_idm_slots_3_br_valid),
        .idm_info_idm_slots_3_br_eip        (idm_outputs_idm_slots_3_br_eip),
        .idm_info_idm_slots_3_br_btb_target (idm_outputs_idm_slots_3_br_btb_target),
        .idm_info_idm_slots_3_br_xcl        (idm_outputs_idm_slots_3_br_xcl),
        .idm_info_valid_slots               (idm_outputs_valid_slots),

        // ---- decode_outs ----
        .decode_outs_invalid_instruction (decode_outputs_invalid_instruction),
        .decode_outs_eip                 (decode_outputs_eip),
        .decode_outs_decode_forward      (decode_outputs_decode_forward),
        .decode_outs_stall               (decode_outputs_stall),

        // ---- rr_outs ----
        .rr_outs_valid          (rr_outputs_valid),
        .rr_outs_codeSeg_sb     (rr_outputs_codeSeg_sb),
        .rr_outs_codeSeg_data   (rr_outputs_codeSeg_data),
        .rr_outs_codeSeg_limit  (rr_outputs_codeSeg_limit),

        // ---- dc_outs ----
        .dc_outs_valid       (dc_outputs_valid),
        .dc_outs_exp_present (dc_outputs_exp_present),
        .dc_outs_exp_pf      (dc_outputs_exp_pf),

        // ---- mem_outs ----
        .mem_outs_valid (mem_outputs_valid),

        // ---- exe_outs ----
        .exe_outs_valid                   (exe_outputs_valid),
        .exe_outs_br_res_valid            (exe_outputs_br_res_valid),
        .exe_outs_br_res_flush            (exe_outputs_br_res_flush),
        .exe_outs_br_res_miss_prediction  (exe_outputs_br_res_miss_prediction),
        .exe_outs_br_res_br_eip           (exe_outputs_br_res_br_eip),
        .exe_outs_br_res_neip             (exe_outputs_br_res_neip),
        .exe_outs_br_res_br_target        (exe_outputs_br_res_br_target),
        .exe_outs_br_res_taken            (exe_outputs_br_res_taken),
        .exe_outs_br_res_br_XCL           (exe_outputs_br_res_br_XCL),
        .exe_outs_br_res_clr_exp_mode     (exe_outputs_br_res_clr_exp_mode),
        .exe_outs_br_res_br_ucond         (exe_outputs_br_res_br_ucond),

        // ---- wb_outs ----
        .wb_outs_valid (wb_outputs_valid),

        .dma_int (inFromDMA_i),

        // ---- fetch_2_icache (driven by Fetch) ----
        .outs_fetch_2_icache_icache_en           (fetch_outputs_fetch_2_icache_icache_en),
        .outs_fetch_2_icache_p_addr              (fetch_outputs_fetch_2_icache_p_addr),
        .outs_fetch_2_icache_v_addr_i            (fetch_outputs_fetch_2_icache_v_addr_i),
        .outs_fetch_2_icache_num_valid_IDM_slots (fetch_outputs_fetch_2_icache_num_valid_IDM_slots),

        // ---- idm_reqs.req[0..3] (driven by Fetch) ----
        .outs_idm_reqs_req_0_ld_meta_data (fetch_outputs_idm_reqs_req_0_ld_meta_data),
        .outs_idm_reqs_req_0_ld_data      (fetch_outputs_idm_reqs_req_0_ld_data),
        .outs_idm_reqs_req_0_valid        (fetch_outputs_idm_reqs_req_0_valid),
        .outs_idm_reqs_req_0_br_valid     (fetch_outputs_idm_reqs_req_0_br_valid),
        .outs_idm_reqs_req_0_br_eip       (fetch_outputs_idm_reqs_req_0_br_eip),
        .outs_idm_reqs_req_0_br_target    (fetch_outputs_idm_reqs_req_0_br_target),
        .outs_idm_reqs_req_0_br_xcl       (fetch_outputs_idm_reqs_req_0_br_xcl),
        .outs_idm_reqs_req_0_data         (fetch_outputs_idm_reqs_req_0_data),

        .outs_idm_reqs_req_1_ld_meta_data (fetch_outputs_idm_reqs_req_1_ld_meta_data),
        .outs_idm_reqs_req_1_ld_data      (fetch_outputs_idm_reqs_req_1_ld_data),
        .outs_idm_reqs_req_1_valid        (fetch_outputs_idm_reqs_req_1_valid),
        .outs_idm_reqs_req_1_br_valid     (fetch_outputs_idm_reqs_req_1_br_valid),
        .outs_idm_reqs_req_1_br_eip       (fetch_outputs_idm_reqs_req_1_br_eip),
        .outs_idm_reqs_req_1_br_target    (fetch_outputs_idm_reqs_req_1_br_target),
        .outs_idm_reqs_req_1_br_xcl       (fetch_outputs_idm_reqs_req_1_br_xcl),
        .outs_idm_reqs_req_1_data         (fetch_outputs_idm_reqs_req_1_data),

        .outs_idm_reqs_req_2_ld_meta_data (fetch_outputs_idm_reqs_req_2_ld_meta_data),
        .outs_idm_reqs_req_2_ld_data      (fetch_outputs_idm_reqs_req_2_ld_data),
        .outs_idm_reqs_req_2_valid        (fetch_outputs_idm_reqs_req_2_valid),
        .outs_idm_reqs_req_2_br_valid     (fetch_outputs_idm_reqs_req_2_br_valid),
        .outs_idm_reqs_req_2_br_eip       (fetch_outputs_idm_reqs_req_2_br_eip),
        .outs_idm_reqs_req_2_br_target    (fetch_outputs_idm_reqs_req_2_br_target),
        .outs_idm_reqs_req_2_br_xcl       (fetch_outputs_idm_reqs_req_2_br_xcl),
        .outs_idm_reqs_req_2_data         (fetch_outputs_idm_reqs_req_2_data),

        .outs_idm_reqs_req_3_ld_meta_data (fetch_outputs_idm_reqs_req_3_ld_meta_data),
        .outs_idm_reqs_req_3_ld_data      (fetch_outputs_idm_reqs_req_3_ld_data),
        .outs_idm_reqs_req_3_valid        (fetch_outputs_idm_reqs_req_3_valid),
        .outs_idm_reqs_req_3_br_valid     (fetch_outputs_idm_reqs_req_3_br_valid),
        .outs_idm_reqs_req_3_br_eip       (fetch_outputs_idm_reqs_req_3_br_eip),
        .outs_idm_reqs_req_3_br_target    (fetch_outputs_idm_reqs_req_3_br_target),
        .outs_idm_reqs_req_3_br_xcl       (fetch_outputs_idm_reqs_req_3_br_xcl),
        .outs_idm_reqs_req_3_data         (fetch_outputs_idm_reqs_req_3_data),

        // ---- exception / interrupt ----
        .outs_exp_pipe_clear (fetch_outputs_exp_pipe_clear),
        .outs_exp_present    (fetch_outputs_exp_present),
        .outs_exp_pf         (fetch_outputs_exp_pf),
        .outs_exp_mode_jk    (fetch_outputs_exp_mode_jk),
        .outs_int_mode_jk    (fetch_outputs_int_mode_jk)
    );

    // =========================================================================
    // IDM
    // =========================================================================
    IDM idm_unit (
        .clk(clk),
        .rst(rst),

        // ---- fetch_outs (consumed by IDM) ----
        .fetch_outs_exp_pipe_clear              (fetch_outputs_exp_pipe_clear),

        .fetch_outs_idm_reqs_req_0_ld_meta_data (fetch_outputs_idm_reqs_req_0_ld_meta_data),
        .fetch_outs_idm_reqs_req_0_ld_data      (fetch_outputs_idm_reqs_req_0_ld_data),
        .fetch_outs_idm_reqs_req_0_valid        (fetch_outputs_idm_reqs_req_0_valid),
        .fetch_outs_idm_reqs_req_0_br_valid     (fetch_outputs_idm_reqs_req_0_br_valid),
        .fetch_outs_idm_reqs_req_0_br_eip       (fetch_outputs_idm_reqs_req_0_br_eip),
        .fetch_outs_idm_reqs_req_0_br_target    (fetch_outputs_idm_reqs_req_0_br_target),
        .fetch_outs_idm_reqs_req_0_br_xcl       (fetch_outputs_idm_reqs_req_0_br_xcl),
        .fetch_outs_idm_reqs_req_0_data         (fetch_outputs_idm_reqs_req_0_data),

        .fetch_outs_idm_reqs_req_1_ld_meta_data (fetch_outputs_idm_reqs_req_1_ld_meta_data),
        .fetch_outs_idm_reqs_req_1_ld_data      (fetch_outputs_idm_reqs_req_1_ld_data),
        .fetch_outs_idm_reqs_req_1_valid        (fetch_outputs_idm_reqs_req_1_valid),
        .fetch_outs_idm_reqs_req_1_br_valid     (fetch_outputs_idm_reqs_req_1_br_valid),
        .fetch_outs_idm_reqs_req_1_br_eip       (fetch_outputs_idm_reqs_req_1_br_eip),
        .fetch_outs_idm_reqs_req_1_br_target    (fetch_outputs_idm_reqs_req_1_br_target),
        .fetch_outs_idm_reqs_req_1_br_xcl       (fetch_outputs_idm_reqs_req_1_br_xcl),
        .fetch_outs_idm_reqs_req_1_data         (fetch_outputs_idm_reqs_req_1_data),

        .fetch_outs_idm_reqs_req_2_ld_meta_data (fetch_outputs_idm_reqs_req_2_ld_meta_data),
        .fetch_outs_idm_reqs_req_2_ld_data      (fetch_outputs_idm_reqs_req_2_ld_data),
        .fetch_outs_idm_reqs_req_2_valid        (fetch_outputs_idm_reqs_req_2_valid),
        .fetch_outs_idm_reqs_req_2_br_valid     (fetch_outputs_idm_reqs_req_2_br_valid),
        .fetch_outs_idm_reqs_req_2_br_eip       (fetch_outputs_idm_reqs_req_2_br_eip),
        .fetch_outs_idm_reqs_req_2_br_target    (fetch_outputs_idm_reqs_req_2_br_target),
        .fetch_outs_idm_reqs_req_2_br_xcl       (fetch_outputs_idm_reqs_req_2_br_xcl),
        .fetch_outs_idm_reqs_req_2_data         (fetch_outputs_idm_reqs_req_2_data),

        .fetch_outs_idm_reqs_req_3_ld_meta_data (fetch_outputs_idm_reqs_req_3_ld_meta_data),
        .fetch_outs_idm_reqs_req_3_ld_data      (fetch_outputs_idm_reqs_req_3_ld_data),
        .fetch_outs_idm_reqs_req_3_valid        (fetch_outputs_idm_reqs_req_3_valid),
        .fetch_outs_idm_reqs_req_3_br_valid     (fetch_outputs_idm_reqs_req_3_br_valid),
        .fetch_outs_idm_reqs_req_3_br_eip       (fetch_outputs_idm_reqs_req_3_br_eip),
        .fetch_outs_idm_reqs_req_3_br_target    (fetch_outputs_idm_reqs_req_3_br_target),
        .fetch_outs_idm_reqs_req_3_br_xcl       (fetch_outputs_idm_reqs_req_3_br_xcl),
        .fetch_outs_idm_reqs_req_3_data         (fetch_outputs_idm_reqs_req_3_data),

        // ---- idm_outs (driven by IDM) ----
        .idm_outs_idm_slots_0_valid         (idm_outputs_idm_slots_0_valid),
        .idm_outs_idm_slots_0_br_valid      (idm_outputs_idm_slots_0_br_valid),
        .idm_outs_idm_slots_0_br_eip        (idm_outputs_idm_slots_0_br_eip),
        .idm_outs_idm_slots_0_br_btb_target (idm_outputs_idm_slots_0_br_btb_target),
        .idm_outs_idm_slots_0_br_xcl        (idm_outputs_idm_slots_0_br_xcl),
        .idm_outs_idm_slots_0_data          (idm_outputs_idm_slots_0_data),

        .idm_outs_idm_slots_1_valid         (idm_outputs_idm_slots_1_valid),
        .idm_outs_idm_slots_1_br_valid      (idm_outputs_idm_slots_1_br_valid),
        .idm_outs_idm_slots_1_br_eip        (idm_outputs_idm_slots_1_br_eip),
        .idm_outs_idm_slots_1_br_btb_target (idm_outputs_idm_slots_1_br_btb_target),
        .idm_outs_idm_slots_1_br_xcl        (idm_outputs_idm_slots_1_br_xcl),
        .idm_outs_idm_slots_1_data          (idm_outputs_idm_slots_1_data),

        .idm_outs_idm_slots_2_valid         (idm_outputs_idm_slots_2_valid),
        .idm_outs_idm_slots_2_br_valid      (idm_outputs_idm_slots_2_br_valid),
        .idm_outs_idm_slots_2_br_eip        (idm_outputs_idm_slots_2_br_eip),
        .idm_outs_idm_slots_2_br_btb_target (idm_outputs_idm_slots_2_br_btb_target),
        .idm_outs_idm_slots_2_br_xcl        (idm_outputs_idm_slots_2_br_xcl),
        .idm_outs_idm_slots_2_data          (idm_outputs_idm_slots_2_data),

        .idm_outs_idm_slots_3_valid         (idm_outputs_idm_slots_3_valid),
        .idm_outs_idm_slots_3_br_valid      (idm_outputs_idm_slots_3_br_valid),
        .idm_outs_idm_slots_3_br_eip        (idm_outputs_idm_slots_3_br_eip),
        .idm_outs_idm_slots_3_br_btb_target (idm_outputs_idm_slots_3_br_btb_target),
        .idm_outs_idm_slots_3_br_xcl        (idm_outputs_idm_slots_3_br_xcl),
        .idm_outs_idm_slots_3_data          (idm_outputs_idm_slots_3_data),

        .idm_outs_valid_slots (idm_outputs_valid_slots)
    );


    // =========================================================================
    // Decode
    // =========================================================================
    Decode decode_unit (
        .clk(clk),
        .rst(rst),

        // ---- idm_outs (idm_outputs_t) ----
        .idm_outs_idm_slots_0_valid         (idm_outputs_idm_slots_0_valid),
        .idm_outs_idm_slots_0_br_valid      (idm_outputs_idm_slots_0_br_valid),
        .idm_outs_idm_slots_0_br_eip        (idm_outputs_idm_slots_0_br_eip),
        .idm_outs_idm_slots_0_br_btb_target (idm_outputs_idm_slots_0_br_btb_target),
        .idm_outs_idm_slots_0_br_xcl        (idm_outputs_idm_slots_0_br_xcl),
        .idm_outs_idm_slots_0_data          (idm_outputs_idm_slots_0_data),
        .idm_outs_idm_slots_1_valid         (idm_outputs_idm_slots_1_valid),
        .idm_outs_idm_slots_1_br_valid      (idm_outputs_idm_slots_1_br_valid),
        .idm_outs_idm_slots_1_br_eip        (idm_outputs_idm_slots_1_br_eip),
        .idm_outs_idm_slots_1_br_btb_target (idm_outputs_idm_slots_1_br_btb_target),
        .idm_outs_idm_slots_1_br_xcl        (idm_outputs_idm_slots_1_br_xcl),
        .idm_outs_idm_slots_1_data          (idm_outputs_idm_slots_1_data),
        .idm_outs_idm_slots_2_valid         (idm_outputs_idm_slots_2_valid),
        .idm_outs_idm_slots_2_br_valid      (idm_outputs_idm_slots_2_br_valid),
        .idm_outs_idm_slots_2_br_eip        (idm_outputs_idm_slots_2_br_eip),
        .idm_outs_idm_slots_2_br_btb_target (idm_outputs_idm_slots_2_br_btb_target),
        .idm_outs_idm_slots_2_br_xcl        (idm_outputs_idm_slots_2_br_xcl),
        .idm_outs_idm_slots_2_data          (idm_outputs_idm_slots_2_data),
        .idm_outs_idm_slots_3_valid         (idm_outputs_idm_slots_3_valid),
        .idm_outs_idm_slots_3_br_valid      (idm_outputs_idm_slots_3_br_valid),
        .idm_outs_idm_slots_3_br_eip        (idm_outputs_idm_slots_3_br_eip),
        .idm_outs_idm_slots_3_br_btb_target (idm_outputs_idm_slots_3_br_btb_target),
        .idm_outs_idm_slots_3_br_xcl        (idm_outputs_idm_slots_3_br_xcl),
        .idm_outs_idm_slots_3_data          (idm_outputs_idm_slots_3_data),

        // ---- fetch_outs ----
        .fetch_outs_exp_pipe_clear (fetch_outputs_exp_pipe_clear),
        .fetch_outs_exp_mode_jk    (fetch_outputs_exp_mode_jk),
        .fetch_outs_int_mode_jk    (fetch_outputs_int_mode_jk),

        // ---- rr_outs ----
        .rr_outs_valid         (rr_outputs_valid),
        .rr_outs_stall         (rr_outputs_stall),
        .rr_outs_ecx_sb        (rr_outputs_ecx_sb),
        .rr_outs_ecx           (rr_outputs_ecx),
        .rr_outs_eax           (rr_outputs_eax),
        .rr_outs_codeSeg_limit (rr_outputs_codeSeg_limit),

        // ---- dc_outs ----
        .dc_outs_valid  (dc_outputs_valid),
        .dc_outs_stall  (dc_outputs_stall),
        .dc_outs_dc_eip (dc_outputs_dc_eip),

        // ---- mem_outs ----
        .mem_outs_valid (mem_outputs_valid),
        .mem_outs_stall (mem_outputs_stall),

        // ---- exe_outs ----
        .exe_outs_valid            (exe_outputs_valid),
        .exe_outs_br_res_valid     (exe_outputs_br_res_valid),
        .exe_outs_br_res_flush     (exe_outputs_br_res_flush),
        .exe_outs_br_res_br_target (exe_outputs_br_res_br_target),
        .exe_outs_clr_ZF_sb        (exe_outputs_clr_ZF_sb),
        .exe_outs_ZF               (exe_outputs_ZF),

        // ---- wb_outs ----
        .wb_outs_wb_stall (wb_outputs_wb_stall),

        // ---- outs_o (decode_outputs_t) ----
        .outs_valid               (decode_outputs_valid),
        .outs_stall               (decode_outputs_stall),
        .outs_eip                 (decode_outputs_eip),
        .outs_invalid_instruction (decode_outputs_invalid_instruction),
        .outs_decode_gp           (decode_outputs_decode_gp),
        .outs_rr_stage_latch_we   (decode_outputs_rr_stage_latch_we),
        .outs_rep_latch           (decode_outputs_rep_latch),
        .outs_decode_forward      (decode_outputs_decode_forward),

        // ---- rr_latches_next.normal_latches (driven by Decode) ----
        .rr_latches_next_normal_latches_valid                (rr_latches_next_normal_latches_valid),
        .rr_latches_next_normal_latches_cs_ST_SEL            (rr_latches_next_normal_latches_cs_ST_SEL),
        .rr_latches_next_normal_latches_cs_MODRM_NEEDED      (rr_latches_next_normal_latches_cs_MODRM_NEEDED),
        .rr_latches_next_normal_latches_cs_RM_IS_DR          (rr_latches_next_normal_latches_cs_RM_IS_DR),
        .rr_latches_next_normal_latches_cs_SWITCH_LD_ADDY    (rr_latches_next_normal_latches_cs_SWITCH_LD_ADDY),
        .rr_latches_next_normal_latches_cs_LD_OP             (rr_latches_next_normal_latches_cs_LD_OP),
        .rr_latches_next_normal_latches_cs_ST_OP             (rr_latches_next_normal_latches_cs_ST_OP),
        .rr_latches_next_normal_latches_cs_dr_id             (rr_latches_next_normal_latches_cs_dr_id),
        .rr_latches_next_normal_latches_cs_sr_id             (rr_latches_next_normal_latches_cs_sr_id),
        .rr_latches_next_normal_latches_cs_dr_rd             (rr_latches_next_normal_latches_cs_dr_rd),
        .rr_latches_next_normal_latches_cs_sr_rd             (rr_latches_next_normal_latches_cs_sr_rd),
        .rr_latches_next_normal_latches_cs_eax_rd            (rr_latches_next_normal_latches_cs_eax_rd),
        .rr_latches_next_normal_latches_cs_dr_wr             (rr_latches_next_normal_latches_cs_dr_wr),
        .rr_latches_next_normal_latches_cs_sr_wr             (rr_latches_next_normal_latches_cs_sr_wr),
        .rr_latches_next_normal_latches_cs_eax_wr            (rr_latches_next_normal_latches_cs_eax_wr),
        .rr_latches_next_normal_latches_cs_MOVS_OP           (rr_latches_next_normal_latches_cs_MOVS_OP),
        .rr_latches_next_normal_latches_cs_datasize          (rr_latches_next_normal_latches_cs_datasize),
        .rr_latches_next_normal_latches_cs_will_mod_zf       (rr_latches_next_normal_latches_cs_will_mod_zf),
        .rr_latches_next_normal_latches_cs_seg_1_valid       (rr_latches_next_normal_latches_cs_seg_1_valid),
        .rr_latches_next_normal_latches_cs_seg_0_id          (rr_latches_next_normal_latches_cs_seg_0_id),
        .rr_latches_next_normal_latches_cs_seg_1_id          (rr_latches_next_normal_latches_cs_seg_1_id),
        .rr_latches_next_normal_latches_cs_special_modrm_bs  (rr_latches_next_normal_latches_cs_special_modrm_bs),
        .rr_latches_next_normal_latches_cs_special_br        (rr_latches_next_normal_latches_cs_special_br),
        .rr_latches_next_normal_latches_dc_cs_LD_OP          (rr_latches_next_normal_latches_dc_cs_LD_OP),
        .rr_latches_next_normal_latches_dc_cs_ST_OP          (rr_latches_next_normal_latches_dc_cs_ST_OP),
        .rr_latches_next_normal_latches_dc_cs_dr_upper8      (rr_latches_next_normal_latches_dc_cs_dr_upper8),
        .rr_latches_next_normal_latches_dc_cs_sr_upper8      (rr_latches_next_normal_latches_dc_cs_sr_upper8),
        .rr_latches_next_normal_latches_dc_cs_datasize       (rr_latches_next_normal_latches_dc_cs_datasize),
        .rr_latches_next_normal_latches_mem_cs_ST_OP         (rr_latches_next_normal_latches_mem_cs_ST_OP),
        .rr_latches_next_normal_latches_mem_cs_LD_OP         (rr_latches_next_normal_latches_mem_cs_LD_OP),
        .rr_latches_next_normal_latches_exe_cs_ST_OP         (rr_latches_next_normal_latches_exe_cs_ST_OP),
        .rr_latches_next_normal_latches_exe_cs_OP_TYPE       (rr_latches_next_normal_latches_exe_cs_OP_TYPE),
        .rr_latches_next_normal_latches_exe_cs_alu_inputA_sel(rr_latches_next_normal_latches_exe_cs_alu_inputA_sel),
        .rr_latches_next_normal_latches_exe_cs_alu_inputB_sel(rr_latches_next_normal_latches_exe_cs_alu_inputB_sel),
        .rr_latches_next_normal_latches_exe_cs_branch_target_sel(rr_latches_next_normal_latches_exe_cs_branch_target_sel),
        .rr_latches_next_normal_latches_exe_cs_shift_by_one  (rr_latches_next_normal_latches_exe_cs_shift_by_one),
        .rr_latches_next_normal_latches_exe_cs_br_ucond      (rr_latches_next_normal_latches_exe_cs_br_ucond),
        .rr_latches_next_normal_latches_exe_cs_relative_branch(rr_latches_next_normal_latches_exe_cs_relative_branch),
        .rr_latches_next_normal_latches_exe_cs_special_br    (rr_latches_next_normal_latches_exe_cs_special_br),
        .rr_latches_next_normal_latches_exe_cs_is_far        (rr_latches_next_normal_latches_exe_cs_is_far),
        .rr_latches_next_normal_latches_exe_cs_is_call       (rr_latches_next_normal_latches_exe_cs_is_call),
        .rr_latches_next_normal_latches_exe_cs_second_flag_needed(rr_latches_next_normal_latches_exe_cs_second_flag_needed),
        .rr_latches_next_normal_latches_exe_cs_rep_no_zf_update(rr_latches_next_normal_latches_exe_cs_rep_no_zf_update),
        .rr_latches_next_normal_latches_wb_cs_ST_OP          (rr_latches_next_normal_latches_wb_cs_ST_OP),
        .rr_latches_next_normal_latches_wb_cs_WB_DR          (rr_latches_next_normal_latches_wb_cs_WB_DR),
        .rr_latches_next_normal_latches_wb_cs_WB_SR          (rr_latches_next_normal_latches_wb_cs_WB_SR),
        .rr_latches_next_normal_latches_wb_cs_WB_EAX         (rr_latches_next_normal_latches_wb_cs_WB_EAX),
        .rr_latches_next_normal_latches_br_info_valid        (rr_latches_next_normal_latches_br_info_valid),
        .rr_latches_next_normal_latches_br_info_br_eip       (rr_latches_next_normal_latches_br_info_br_eip),
        .rr_latches_next_normal_latches_br_info_br_xcl       (rr_latches_next_normal_latches_br_info_br_xcl),
        .rr_latches_next_normal_latches_br_info_br_pred_taken(rr_latches_next_normal_latches_br_info_br_pred_taken),
        .rr_latches_next_normal_latches_br_info_speculative_target(rr_latches_next_normal_latches_br_info_speculative_target),
        .rr_latches_next_normal_latches_NEIP                 (rr_latches_next_normal_latches_NEIP),
        .rr_latches_next_normal_latches_EIP                  (rr_latches_next_normal_latches_EIP),
        .rr_latches_next_normal_latches_EAX                  (rr_latches_next_normal_latches_EAX),
        .rr_latches_next_normal_latches_imm64                (rr_latches_next_normal_latches_imm64),
        .rr_latches_next_normal_latches_sib_idx_id           (rr_latches_next_normal_latches_sib_idx_id),
        .rr_latches_next_normal_latches_sib_base_id          (rr_latches_next_normal_latches_sib_base_id),
        .rr_latches_next_normal_latches_sib_needed           (rr_latches_next_normal_latches_sib_needed),
        .rr_latches_next_normal_latches_sib_scale            (rr_latches_next_normal_latches_sib_scale),
        .rr_latches_next_normal_latches_disp_needed          (rr_latches_next_normal_latches_disp_needed),
        .rr_latches_next_normal_latches_disp_size            (rr_latches_next_normal_latches_disp_size),
        .rr_latches_next_normal_latches_displacement         (rr_latches_next_normal_latches_displacement),

        // ---- rr_latches_next.rep_latches (driven by Decode) ----
        .rr_latches_next_rep_latches_valid                (rr_latches_next_rep_latches_valid),
        .rr_latches_next_rep_latches_cs_ST_SEL            (rr_latches_next_rep_latches_cs_ST_SEL),
        .rr_latches_next_rep_latches_cs_MODRM_NEEDED      (rr_latches_next_rep_latches_cs_MODRM_NEEDED),
        .rr_latches_next_rep_latches_cs_RM_IS_DR          (rr_latches_next_rep_latches_cs_RM_IS_DR),
        .rr_latches_next_rep_latches_cs_SWITCH_LD_ADDY    (rr_latches_next_rep_latches_cs_SWITCH_LD_ADDY),
        .rr_latches_next_rep_latches_cs_LD_OP             (rr_latches_next_rep_latches_cs_LD_OP),
        .rr_latches_next_rep_latches_cs_ST_OP             (rr_latches_next_rep_latches_cs_ST_OP),
        .rr_latches_next_rep_latches_cs_dr_id             (rr_latches_next_rep_latches_cs_dr_id),
        .rr_latches_next_rep_latches_cs_sr_id             (rr_latches_next_rep_latches_cs_sr_id),
        .rr_latches_next_rep_latches_cs_dr_rd             (rr_latches_next_rep_latches_cs_dr_rd),
        .rr_latches_next_rep_latches_cs_sr_rd             (rr_latches_next_rep_latches_cs_sr_rd),
        .rr_latches_next_rep_latches_cs_eax_rd            (rr_latches_next_rep_latches_cs_eax_rd),
        .rr_latches_next_rep_latches_cs_dr_wr             (rr_latches_next_rep_latches_cs_dr_wr),
        .rr_latches_next_rep_latches_cs_sr_wr             (rr_latches_next_rep_latches_cs_sr_wr),
        .rr_latches_next_rep_latches_cs_eax_wr            (rr_latches_next_rep_latches_cs_eax_wr),
        .rr_latches_next_rep_latches_cs_MOVS_OP           (rr_latches_next_rep_latches_cs_MOVS_OP),
        .rr_latches_next_rep_latches_cs_datasize          (rr_latches_next_rep_latches_cs_datasize),
        .rr_latches_next_rep_latches_cs_will_mod_zf       (rr_latches_next_rep_latches_cs_will_mod_zf),
        .rr_latches_next_rep_latches_cs_seg_1_valid       (rr_latches_next_rep_latches_cs_seg_1_valid),
        .rr_latches_next_rep_latches_cs_seg_0_id          (rr_latches_next_rep_latches_cs_seg_0_id),
        .rr_latches_next_rep_latches_cs_seg_1_id          (rr_latches_next_rep_latches_cs_seg_1_id),
        .rr_latches_next_rep_latches_cs_special_modrm_bs  (rr_latches_next_rep_latches_cs_special_modrm_bs),
        .rr_latches_next_rep_latches_cs_special_br        (rr_latches_next_rep_latches_cs_special_br),
        .rr_latches_next_rep_latches_dc_cs_LD_OP          (rr_latches_next_rep_latches_dc_cs_LD_OP),
        .rr_latches_next_rep_latches_dc_cs_ST_OP          (rr_latches_next_rep_latches_dc_cs_ST_OP),
        .rr_latches_next_rep_latches_dc_cs_dr_upper8      (rr_latches_next_rep_latches_dc_cs_dr_upper8),
        .rr_latches_next_rep_latches_dc_cs_sr_upper8      (rr_latches_next_rep_latches_dc_cs_sr_upper8),
        .rr_latches_next_rep_latches_dc_cs_datasize       (rr_latches_next_rep_latches_dc_cs_datasize),
        .rr_latches_next_rep_latches_mem_cs_ST_OP         (rr_latches_next_rep_latches_mem_cs_ST_OP),
        .rr_latches_next_rep_latches_mem_cs_LD_OP         (rr_latches_next_rep_latches_mem_cs_LD_OP),
        .rr_latches_next_rep_latches_exe_cs_ST_OP         (rr_latches_next_rep_latches_exe_cs_ST_OP),
        .rr_latches_next_rep_latches_exe_cs_OP_TYPE       (rr_latches_next_rep_latches_exe_cs_OP_TYPE),
        .rr_latches_next_rep_latches_exe_cs_alu_inputA_sel(rr_latches_next_rep_latches_exe_cs_alu_inputA_sel),
        .rr_latches_next_rep_latches_exe_cs_alu_inputB_sel(rr_latches_next_rep_latches_exe_cs_alu_inputB_sel),
        .rr_latches_next_rep_latches_exe_cs_branch_target_sel(rr_latches_next_rep_latches_exe_cs_branch_target_sel),
        .rr_latches_next_rep_latches_exe_cs_shift_by_one  (rr_latches_next_rep_latches_exe_cs_shift_by_one),
        .rr_latches_next_rep_latches_exe_cs_br_ucond      (rr_latches_next_rep_latches_exe_cs_br_ucond),
        .rr_latches_next_rep_latches_exe_cs_relative_branch(rr_latches_next_rep_latches_exe_cs_relative_branch),
        .rr_latches_next_rep_latches_exe_cs_special_br    (rr_latches_next_rep_latches_exe_cs_special_br),
        .rr_latches_next_rep_latches_exe_cs_is_far        (rr_latches_next_rep_latches_exe_cs_is_far),
        .rr_latches_next_rep_latches_exe_cs_is_call       (rr_latches_next_rep_latches_exe_cs_is_call),
        .rr_latches_next_rep_latches_exe_cs_second_flag_needed(rr_latches_next_rep_latches_exe_cs_second_flag_needed),
        .rr_latches_next_rep_latches_exe_cs_rep_no_zf_update(rr_latches_next_rep_latches_exe_cs_rep_no_zf_update),
        .rr_latches_next_rep_latches_wb_cs_ST_OP          (rr_latches_next_rep_latches_wb_cs_ST_OP),
        .rr_latches_next_rep_latches_wb_cs_WB_DR          (rr_latches_next_rep_latches_wb_cs_WB_DR),
        .rr_latches_next_rep_latches_wb_cs_WB_SR          (rr_latches_next_rep_latches_wb_cs_WB_SR),
        .rr_latches_next_rep_latches_wb_cs_WB_EAX         (rr_latches_next_rep_latches_wb_cs_WB_EAX),
        .rr_latches_next_rep_latches_br_info_valid        (rr_latches_next_rep_latches_br_info_valid),
        .rr_latches_next_rep_latches_br_info_br_eip       (rr_latches_next_rep_latches_br_info_br_eip),
        .rr_latches_next_rep_latches_br_info_br_xcl       (rr_latches_next_rep_latches_br_info_br_xcl),
        .rr_latches_next_rep_latches_br_info_br_pred_taken(rr_latches_next_rep_latches_br_info_br_pred_taken),
        .rr_latches_next_rep_latches_br_info_speculative_target(rr_latches_next_rep_latches_br_info_speculative_target),
        .rr_latches_next_rep_latches_NEIP                 (rr_latches_next_rep_latches_NEIP),
        .rr_latches_next_rep_latches_EIP                  (rr_latches_next_rep_latches_EIP),
        .rr_latches_next_rep_latches_EAX                  (rr_latches_next_rep_latches_EAX),
        .rr_latches_next_rep_latches_imm64                (rr_latches_next_rep_latches_imm64),
        .rr_latches_next_rep_latches_sib_idx_id           (rr_latches_next_rep_latches_sib_idx_id),
        .rr_latches_next_rep_latches_sib_base_id          (rr_latches_next_rep_latches_sib_base_id),
        .rr_latches_next_rep_latches_sib_needed           (rr_latches_next_rep_latches_sib_needed),
        .rr_latches_next_rep_latches_sib_scale            (rr_latches_next_rep_latches_sib_scale),
        .rr_latches_next_rep_latches_disp_needed          (rr_latches_next_rep_latches_disp_needed),
        .rr_latches_next_rep_latches_disp_size            (rr_latches_next_rep_latches_disp_size),
        .rr_latches_next_rep_latches_displacement         (rr_latches_next_rep_latches_displacement)
    );


    // =========================================================================
    // RR
    // =========================================================================
    RR rr_unit (
        .clk(clk),
        .rst(rst),

        // ---- latches.normal_latches (latched values from RR_Latches) ----
        .latches_normal_latches_valid                  (rr_latches_normal_valid),
        .latches_normal_latches_cs_ST_SEL              (rr_latches_normal_cs_ST_SEL),
        .latches_normal_latches_cs_MODRM_NEEDED        (rr_latches_normal_cs_MODRM_NEEDED),
        .latches_normal_latches_cs_RM_IS_DR            (rr_latches_normal_cs_RM_IS_DR),
        .latches_normal_latches_cs_SWITCH_LD_ADDY      (rr_latches_normal_cs_SWITCH_LD_ADDY),
        .latches_normal_latches_cs_LD_OP               (rr_latches_normal_cs_LD_OP),
        .latches_normal_latches_cs_ST_OP               (rr_latches_normal_cs_ST_OP),
        .latches_normal_latches_cs_dr_id               (rr_latches_normal_cs_dr_id),
        .latches_normal_latches_cs_sr_id               (rr_latches_normal_cs_sr_id),
        .latches_normal_latches_cs_dr_rd               (rr_latches_normal_cs_dr_rd),
        .latches_normal_latches_cs_sr_rd               (rr_latches_normal_cs_sr_rd),
        .latches_normal_latches_cs_eax_rd              (rr_latches_normal_cs_eax_rd),
        .latches_normal_latches_cs_dr_wr               (rr_latches_normal_cs_dr_wr),
        .latches_normal_latches_cs_sr_wr               (rr_latches_normal_cs_sr_wr),
        .latches_normal_latches_cs_eax_wr              (rr_latches_normal_cs_eax_wr),
        .latches_normal_latches_cs_MOVS_OP             (rr_latches_normal_cs_MOVS_OP),
        .latches_normal_latches_cs_datasize            (rr_latches_normal_cs_datasize),
        .latches_normal_latches_cs_will_mod_zf         (rr_latches_normal_cs_will_mod_zf),
        .latches_normal_latches_cs_seg_1_valid         (rr_latches_normal_cs_seg_1_valid),
        .latches_normal_latches_cs_seg_0_id            (rr_latches_normal_cs_seg_0_id),
        .latches_normal_latches_cs_seg_1_id            (rr_latches_normal_cs_seg_1_id),
        .latches_normal_latches_cs_special_modrm_bs    (rr_latches_normal_cs_special_modrm_bs),
        .latches_normal_latches_cs_special_br          (rr_latches_normal_cs_special_br),
        .latches_normal_latches_dc_cs_LD_OP            (rr_latches_normal_dc_cs_LD_OP),
        .latches_normal_latches_dc_cs_ST_OP            (rr_latches_normal_dc_cs_ST_OP),
        .latches_normal_latches_dc_cs_dr_upper8        (rr_latches_normal_dc_cs_dr_upper8),
        .latches_normal_latches_dc_cs_sr_upper8        (rr_latches_normal_dc_cs_sr_upper8),
        .latches_normal_latches_dc_cs_datasize         (rr_latches_normal_dc_cs_datasize),
        .latches_normal_latches_mem_cs_ST_OP           (rr_latches_normal_mem_cs_ST_OP),
        .latches_normal_latches_mem_cs_LD_OP           (rr_latches_normal_mem_cs_LD_OP),
        .latches_normal_latches_exe_cs_ST_OP           (rr_latches_normal_exe_cs_ST_OP),
        .latches_normal_latches_exe_cs_OP_TYPE         (rr_latches_normal_exe_cs_OP_TYPE),
        .latches_normal_latches_exe_cs_alu_inputA_sel  (rr_latches_normal_exe_cs_alu_inputA_sel),
        .latches_normal_latches_exe_cs_alu_inputB_sel  (rr_latches_normal_exe_cs_alu_inputB_sel),
        .latches_normal_latches_exe_cs_branch_target_sel(rr_latches_normal_exe_cs_branch_target_sel),
        .latches_normal_latches_exe_cs_shift_by_one    (rr_latches_normal_exe_cs_shift_by_one),
        .latches_normal_latches_exe_cs_br_ucond        (rr_latches_normal_exe_cs_br_ucond),
        .latches_normal_latches_exe_cs_relative_branch (rr_latches_normal_exe_cs_relative_branch),
        .latches_normal_latches_exe_cs_special_br      (rr_latches_normal_exe_cs_special_br),
        .latches_normal_latches_exe_cs_is_far          (rr_latches_normal_exe_cs_is_far),
        .latches_normal_latches_exe_cs_is_call         (rr_latches_normal_exe_cs_is_call),
        .latches_normal_latches_exe_cs_second_flag_needed(rr_latches_normal_exe_cs_second_flag_needed),
        .latches_normal_latches_exe_cs_rep_no_zf_update(rr_latches_normal_exe_cs_rep_no_zf_update),
        .latches_normal_latches_wb_cs_ST_OP            (rr_latches_normal_wb_cs_ST_OP),
        .latches_normal_latches_wb_cs_WB_DR            (rr_latches_normal_wb_cs_WB_DR),
        .latches_normal_latches_wb_cs_WB_SR            (rr_latches_normal_wb_cs_WB_SR),
        .latches_normal_latches_wb_cs_WB_EAX           (rr_latches_normal_wb_cs_WB_EAX),
        .latches_normal_latches_br_info_valid          (rr_latches_normal_br_info_valid),
        .latches_normal_latches_br_info_br_eip         (rr_latches_normal_br_info_br_eip),
        .latches_normal_latches_br_info_br_xcl         (rr_latches_normal_br_info_br_xcl),
        .latches_normal_latches_br_info_br_pred_taken  (rr_latches_normal_br_info_br_pred_taken),
        .latches_normal_latches_br_info_speculative_target(rr_latches_normal_br_info_speculative_target),
        .latches_normal_latches_NEIP                   (rr_latches_normal_NEIP),
        .latches_normal_latches_EIP                    (rr_latches_normal_EIP),
        .latches_normal_latches_EAX                    (rr_latches_normal_EAX),
        .latches_normal_latches_imm64                  (rr_latches_normal_imm64),
        .latches_normal_latches_sib_idx_id             (rr_latches_normal_sib_idx_id),
        .latches_normal_latches_sib_base_id            (rr_latches_normal_sib_base_id),
        .latches_normal_latches_sib_needed             (rr_latches_normal_sib_needed),
        .latches_normal_latches_sib_scale              (rr_latches_normal_sib_scale),
        .latches_normal_latches_disp_needed            (rr_latches_normal_disp_needed),
        .latches_normal_latches_disp_size              (rr_latches_normal_disp_size),
        .latches_normal_latches_displacement           (rr_latches_normal_displacement),

        // ---- latches.rep_latches (latched values from RR_Latches) ----
        .latches_rep_latches_valid                  (rr_latches_rep_valid),
        .latches_rep_latches_cs_ST_SEL              (rr_latches_rep_cs_ST_SEL),
        .latches_rep_latches_cs_MODRM_NEEDED        (rr_latches_rep_cs_MODRM_NEEDED),
        .latches_rep_latches_cs_RM_IS_DR            (rr_latches_rep_cs_RM_IS_DR),
        .latches_rep_latches_cs_SWITCH_LD_ADDY      (rr_latches_rep_cs_SWITCH_LD_ADDY),
        .latches_rep_latches_cs_LD_OP               (rr_latches_rep_cs_LD_OP),
        .latches_rep_latches_cs_ST_OP               (rr_latches_rep_cs_ST_OP),
        .latches_rep_latches_cs_dr_id               (rr_latches_rep_cs_dr_id),
        .latches_rep_latches_cs_sr_id               (rr_latches_rep_cs_sr_id),
        .latches_rep_latches_cs_dr_rd               (rr_latches_rep_cs_dr_rd),
        .latches_rep_latches_cs_sr_rd               (rr_latches_rep_cs_sr_rd),
        .latches_rep_latches_cs_eax_rd              (rr_latches_rep_cs_eax_rd),
        .latches_rep_latches_cs_dr_wr               (rr_latches_rep_cs_dr_wr),
        .latches_rep_latches_cs_sr_wr               (rr_latches_rep_cs_sr_wr),
        .latches_rep_latches_cs_eax_wr              (rr_latches_rep_cs_eax_wr),
        .latches_rep_latches_cs_MOVS_OP             (rr_latches_rep_cs_MOVS_OP),
        .latches_rep_latches_cs_datasize            (rr_latches_rep_cs_datasize),
        .latches_rep_latches_cs_will_mod_zf         (rr_latches_rep_cs_will_mod_zf),
        .latches_rep_latches_cs_seg_1_valid         (rr_latches_rep_cs_seg_1_valid),
        .latches_rep_latches_cs_seg_0_id            (rr_latches_rep_cs_seg_0_id),
        .latches_rep_latches_cs_seg_1_id            (rr_latches_rep_cs_seg_1_id),
        .latches_rep_latches_cs_special_modrm_bs    (rr_latches_rep_cs_special_modrm_bs),
        .latches_rep_latches_cs_special_br          (rr_latches_rep_cs_special_br),
        .latches_rep_latches_dc_cs_LD_OP            (rr_latches_rep_dc_cs_LD_OP),
        .latches_rep_latches_dc_cs_ST_OP            (rr_latches_rep_dc_cs_ST_OP),
        .latches_rep_latches_dc_cs_dr_upper8        (rr_latches_rep_dc_cs_dr_upper8),
        .latches_rep_latches_dc_cs_sr_upper8        (rr_latches_rep_dc_cs_sr_upper8),
        .latches_rep_latches_dc_cs_datasize         (rr_latches_rep_dc_cs_datasize),
        .latches_rep_latches_mem_cs_ST_OP           (rr_latches_rep_mem_cs_ST_OP),
        .latches_rep_latches_mem_cs_LD_OP           (rr_latches_rep_mem_cs_LD_OP),
        .latches_rep_latches_exe_cs_ST_OP           (rr_latches_rep_exe_cs_ST_OP),
        .latches_rep_latches_exe_cs_OP_TYPE         (rr_latches_rep_exe_cs_OP_TYPE),
        .latches_rep_latches_exe_cs_alu_inputA_sel  (rr_latches_rep_exe_cs_alu_inputA_sel),
        .latches_rep_latches_exe_cs_alu_inputB_sel  (rr_latches_rep_exe_cs_alu_inputB_sel),
        .latches_rep_latches_exe_cs_branch_target_sel(rr_latches_rep_exe_cs_branch_target_sel),
        .latches_rep_latches_exe_cs_shift_by_one    (rr_latches_rep_exe_cs_shift_by_one),
        .latches_rep_latches_exe_cs_br_ucond        (rr_latches_rep_exe_cs_br_ucond),
        .latches_rep_latches_exe_cs_relative_branch (rr_latches_rep_exe_cs_relative_branch),
        .latches_rep_latches_exe_cs_special_br      (rr_latches_rep_exe_cs_special_br),
        .latches_rep_latches_exe_cs_is_far          (rr_latches_rep_exe_cs_is_far),
        .latches_rep_latches_exe_cs_is_call         (rr_latches_rep_exe_cs_is_call),
        .latches_rep_latches_exe_cs_second_flag_needed(rr_latches_rep_exe_cs_second_flag_needed),
        .latches_rep_latches_exe_cs_rep_no_zf_update(rr_latches_rep_exe_cs_rep_no_zf_update),
        .latches_rep_latches_wb_cs_ST_OP            (rr_latches_rep_wb_cs_ST_OP),
        .latches_rep_latches_wb_cs_WB_DR            (rr_latches_rep_wb_cs_WB_DR),
        .latches_rep_latches_wb_cs_WB_SR            (rr_latches_rep_wb_cs_WB_SR),
        .latches_rep_latches_wb_cs_WB_EAX           (rr_latches_rep_wb_cs_WB_EAX),
        .latches_rep_latches_br_info_valid          (rr_latches_rep_br_info_valid),
        .latches_rep_latches_br_info_br_eip         (rr_latches_rep_br_info_br_eip),
        .latches_rep_latches_br_info_br_xcl         (rr_latches_rep_br_info_br_xcl),
        .latches_rep_latches_br_info_br_pred_taken  (rr_latches_rep_br_info_br_pred_taken),
        .latches_rep_latches_br_info_speculative_target(rr_latches_rep_br_info_speculative_target),
        .latches_rep_latches_NEIP                   (rr_latches_rep_NEIP),
        .latches_rep_latches_EIP                    (rr_latches_rep_EIP),
        .latches_rep_latches_EAX                    (rr_latches_rep_EAX),
        .latches_rep_latches_imm64                  (rr_latches_rep_imm64),
        .latches_rep_latches_sib_idx_id             (rr_latches_rep_sib_idx_id),
        .latches_rep_latches_sib_base_id            (rr_latches_rep_sib_base_id),
        .latches_rep_latches_sib_needed             (rr_latches_rep_sib_needed),
        .latches_rep_latches_sib_scale              (rr_latches_rep_sib_scale),
        .latches_rep_latches_disp_needed            (rr_latches_rep_disp_needed),
        .latches_rep_latches_disp_size              (rr_latches_rep_disp_size),
        .latches_rep_latches_displacement           (rr_latches_rep_displacement),

        // ---- fetch_outs ----
        .fetch_outs_exp_pipe_clear (fetch_outputs_exp_pipe_clear),

        // ---- decode_outs ----
        .decode_outs_rep_latch (decode_outputs_rep_latch),
        .decode_outs_decode_gp (decode_outputs_decode_gp),

        // ---- dc_outs ----
        .dc_outs_valid (dc_outputs_valid),
        .dc_outs_stall (dc_outputs_stall),

        // ---- mem_outs ----
        .mem_outs_valid (mem_outputs_valid),
        .mem_outs_stall (mem_outputs_stall),

        // ---- exe_outs ----
        .exe_outs_valid           (exe_outputs_valid),
        .exe_outs_br_res_flush    (exe_outputs_br_res_flush),
        .exe_outs_br_res_farFlush (exe_outputs_br_res_farFlush),
        .exe_outs_br_res_callFlush(exe_outputs_br_res_callFlush),
        .exe_outs_DR_0_we         (exe_outputs_DR_0_we),
        .exe_outs_DR_0_id         (exe_outputs_DR_0_id),
        .exe_outs_DR_0_data       (exe_outputs_DR_0_data),
        .exe_outs_DR_1_we         (exe_outputs_DR_1_we),
        .exe_outs_DR_1_id         (exe_outputs_DR_1_id),
        .exe_outs_DR_1_data       (exe_outputs_DR_1_data),

        // ---- wb_outs ----
        .wb_outs_wb_stall (wb_outputs_wb_stall),

        // ---- dc_latches_next (driven by RR -> DC_Latches) ----
        .dc_latches_next_valid                       (dc_latches_next_valid),
        .dc_latches_next_cs_LD_OP                    (dc_latches_next_cs_LD_OP),
        .dc_latches_next_cs_ST_OP                    (dc_latches_next_cs_ST_OP),
        .dc_latches_next_cs_dr_upper8                (dc_latches_next_cs_dr_upper8),
        .dc_latches_next_cs_sr_upper8                (dc_latches_next_cs_sr_upper8),
        .dc_latches_next_cs_datasize                 (dc_latches_next_cs_datasize),
        .dc_latches_next_mem_cs_ST_OP                (dc_latches_next_mem_cs_ST_OP),
        .dc_latches_next_mem_cs_LD_OP                (dc_latches_next_mem_cs_LD_OP),
        .dc_latches_next_exe_cs_ST_OP                (dc_latches_next_exe_cs_ST_OP),
        .dc_latches_next_exe_cs_OP_TYPE              (dc_latches_next_exe_cs_OP_TYPE),
        .dc_latches_next_exe_cs_alu_inputA_sel       (dc_latches_next_exe_cs_alu_inputA_sel),
        .dc_latches_next_exe_cs_alu_inputB_sel       (dc_latches_next_exe_cs_alu_inputB_sel),
        .dc_latches_next_exe_cs_branch_target_sel    (dc_latches_next_exe_cs_branch_target_sel),
        .dc_latches_next_exe_cs_shift_by_one         (dc_latches_next_exe_cs_shift_by_one),
        .dc_latches_next_exe_cs_br_ucond             (dc_latches_next_exe_cs_br_ucond),
        .dc_latches_next_exe_cs_relative_branch      (dc_latches_next_exe_cs_relative_branch),
        .dc_latches_next_exe_cs_special_br           (dc_latches_next_exe_cs_special_br),
        .dc_latches_next_exe_cs_is_far               (dc_latches_next_exe_cs_is_far),
        .dc_latches_next_exe_cs_is_call              (dc_latches_next_exe_cs_is_call),
        .dc_latches_next_exe_cs_second_flag_needed   (dc_latches_next_exe_cs_second_flag_needed),
        .dc_latches_next_exe_cs_rep_no_zf_update     (dc_latches_next_exe_cs_rep_no_zf_update),
        .dc_latches_next_wb_cs_ST_OP                 (dc_latches_next_wb_cs_ST_OP),
        .dc_latches_next_wb_cs_WB_DR                 (dc_latches_next_wb_cs_WB_DR),
        .dc_latches_next_wb_cs_WB_SR                 (dc_latches_next_wb_cs_WB_SR),
        .dc_latches_next_wb_cs_WB_EAX                (dc_latches_next_wb_cs_WB_EAX),
        .dc_latches_next_br_info_valid               (dc_latches_next_br_info_valid),
        .dc_latches_next_br_info_br_eip              (dc_latches_next_br_info_br_eip),
        .dc_latches_next_br_info_br_xcl              (dc_latches_next_br_info_br_xcl),
        .dc_latches_next_br_info_br_pred_taken       (dc_latches_next_br_info_br_pred_taken),
        .dc_latches_next_br_info_speculative_target  (dc_latches_next_br_info_speculative_target),
        .dc_latches_next_rr_gp                       (dc_latches_next_rr_gp),
        .dc_latches_next_ld_vaddy                    (dc_latches_next_ld_vaddy),
        .dc_latches_next_seg0_limit_w_datasize       (dc_latches_next_seg0_limit_w_datasize),
        .dc_latches_next_seg0_limit_wo_datasize      (dc_latches_next_seg0_limit_wo_datasize),
        .dc_latches_next_next_ld_vaddy               (dc_latches_next_next_ld_vaddy),
        .dc_latches_next_ld_laddy                    (dc_latches_next_ld_laddy),
        .dc_latches_next_ld_stack_access             (dc_latches_next_ld_stack_access),
        .dc_latches_next_st_vaddy                    (dc_latches_next_st_vaddy),
        .dc_latches_next_seg1_limit_w_datasize       (dc_latches_next_seg1_limit_w_datasize),
        .dc_latches_next_seg1_limit_wo_datasize      (dc_latches_next_seg1_limit_wo_datasize),
        .dc_latches_next_next_st_vaddy               (dc_latches_next_next_st_vaddy),
        .dc_latches_next_st_laddy                    (dc_latches_next_st_laddy),
        .dc_latches_next_st_stack_access             (dc_latches_next_st_stack_access),
        .dc_latches_next_NEIP                        (dc_latches_next_NEIP),
        .dc_latches_next_EIP                         (dc_latches_next_EIP),
        .dc_latches_next_EAX                         (dc_latches_next_EAX),
        .dc_latches_next_imm64                       (dc_latches_next_imm64),
        .dc_latches_next_sr_id                       (dc_latches_next_sr_id),
        .dc_latches_next_sr_data                     (dc_latches_next_sr_data),
        .dc_latches_next_dr_id                       (dc_latches_next_dr_id),
        .dc_latches_next_dr_data                     (dc_latches_next_dr_data),

        // ---- outs (rr_outputs_t) ----
        .outs_valid             (rr_outputs_valid),
        .outs_stall             (rr_outputs_stall),
        .outs_ecx_sb            (rr_outputs_ecx_sb),
        .outs_ecx               (rr_outputs_ecx),
        .outs_eax               (rr_outputs_eax),
        .outs_set_ZF_sb         (rr_outputs_set_ZF_sb),
        .outs_codeSeg_sb        (rr_outputs_codeSeg_sb),
        .outs_codeSeg_data      (rr_outputs_codeSeg_data),
        .outs_codeSeg_limit     (rr_outputs_codeSeg_limit),
        .outs_dc_stage_latch_we (rr_outputs_dc_stage_latch_we),

        .outs_regFileValues_0  (rr_outputs_regFileValues_0),
        .outs_regFileValues_1  (rr_outputs_regFileValues_1),
        .outs_regFileValues_2  (rr_outputs_regFileValues_2),
        .outs_regFileValues_3  (rr_outputs_regFileValues_3),
        .outs_regFileValues_4  (rr_outputs_regFileValues_4),
        .outs_regFileValues_5  (rr_outputs_regFileValues_5),
        .outs_regFileValues_6  (rr_outputs_regFileValues_6),
        .outs_regFileValues_7  (rr_outputs_regFileValues_7),
        .outs_regFileValues_8  (rr_outputs_regFileValues_8),
        .outs_regFileValues_9  (rr_outputs_regFileValues_9),
        .outs_regFileValues_10 (rr_outputs_regFileValues_10),
        .outs_regFileValues_11 (rr_outputs_regFileValues_11),
        .outs_regFileValues_12 (rr_outputs_regFileValues_12),
        .outs_regFileValues_13 (rr_outputs_regFileValues_13),
        .outs_regFileValues_14 (rr_outputs_regFileValues_14),
        .outs_regFileValues_15 (rr_outputs_regFileValues_15),
        .outs_regFileValues_16 (rr_outputs_regFileValues_16),
        .outs_regFileValues_17 (rr_outputs_regFileValues_17),
        .outs_regFileValues_18 (rr_outputs_regFileValues_18),
        .outs_regFileValues_19 (rr_outputs_regFileValues_19),
        .outs_regFileValues_20 (rr_outputs_regFileValues_20),
        .outs_regFileValues_21 (rr_outputs_regFileValues_21),
        .outs_regFileValues_22 (rr_outputs_regFileValues_22),
        .outs_regFileValues_23 (rr_outputs_regFileValues_23),
        .outs_regFileValues_24 (rr_outputs_regFileValues_24),
        .outs_regFileValues_25 (rr_outputs_regFileValues_25)
    );

endmodule
