import common_pkg::*;
import interconnect_pkg::*;
import core_common_pkg::*;
import core_stage_latches_pkg::*;

module EveryThing_TOP (
    input wire clk,
    input wire rst,

    //icache 2 core
    input  icache_2_core_t ICacheIn_i,
    output core_2_icache_t out2ICache_o,
    //core2 icache
    //
    //core 2 dcache
    input  dcache_2_core_t DCacheIn_i,

    //dcache 2 core these need to be assinged from dc outs and wb outs
    output core_2_dcache_t out2DCache_o,

    input dma_controller_2_core_t inFromDMA_i

);
    idm_outputs_t idm_outputs;
    fetch_outputs_t fetch_outputs;
    decode_outputs_t decode_outputs;
    rr_outputs_t rr_outputs;
    dc_outputs_t dc_outputs;
    mem_outputs_t mem_outputs;
    exe_outputs_t exe_outputs;
    wb_outputs_t wb_outputs;

    rr_latches_t rr_latches, rr_latches_next;
    dc_latches_t dc_latches, dc_latches_next;
    mem_latches_t mem_latches, mem_latches_next;
    exe_latches_t exe_latches, exe_latches_next;
    wb_latches_t wb_latches, wb_latches_next;

    // ---------------------------------------------------------------------
    // Struct <-> flat-bus bridge for the de-structified WB and EXE stages.
    // The new WB_structural.v / EXE_structural.v take flat Verilog-2005
    // ports. The other six stages still take SV struct ports, so this top
    // file owns the pack/unpack of byte arrays at the WB/EXE boundary.
    // ---------------------------------------------------------------------

    // -- inbound byte-array packs (struct unpacked array -> packed bus) ----
    logic [255:0] wb_latches_res_buf_w;
    logic [255:0] exe_latches_ld_buf_w;

    genvar gi_resbuf_in;
    generate
        for (gi_resbuf_in = 0; gi_resbuf_in < CACHE_LINES_SIZE_B*2; gi_resbuf_in = gi_resbuf_in + 1) begin : g_pack_wb_res_buf
            assign wb_latches_res_buf_w[gi_resbuf_in*8 +: 8] = wb_latches.res_buf[gi_resbuf_in];
        end
    endgenerate

    genvar gi_ldbuf_in;
    generate
        for (gi_ldbuf_in = 0; gi_ldbuf_in < EXE_BUFFER_SIZE; gi_ldbuf_in = gi_ldbuf_in + 1) begin : g_pack_exe_ld_buf
            assign exe_latches_ld_buf_w[gi_ldbuf_in*8 +: 8] = exe_latches.ld_buf[gi_ldbuf_in];
        end
    endgenerate

    // -- outbound byte-array unpacks (packed bus -> struct unpacked array) -
    logic [127:0] wb_stq_head_0_data_w, wb_stq_head_1_data_w, wb_stq_head_2_data_w, wb_stq_head_3_data_w;
    logic [127:0] wb_mio_head_data_w;
    logic [255:0] exe_wb_latches_next_res_buf_w;

    genvar gi_h0;
    generate
        for (gi_h0 = 0; gi_h0 < CACHE_LINES_SIZE_B; gi_h0 = gi_h0 + 1) begin : g_unpack_stq_h0
            assign wb_outputs.stq_heads[0].data[gi_h0] = wb_stq_head_0_data_w[gi_h0*8 +: 8];
        end
    endgenerate
    genvar gi_h1;
    generate
        for (gi_h1 = 0; gi_h1 < CACHE_LINES_SIZE_B; gi_h1 = gi_h1 + 1) begin : g_unpack_stq_h1
            assign wb_outputs.stq_heads[1].data[gi_h1] = wb_stq_head_1_data_w[gi_h1*8 +: 8];
        end
    endgenerate
    genvar gi_h2;
    generate
        for (gi_h2 = 0; gi_h2 < CACHE_LINES_SIZE_B; gi_h2 = gi_h2 + 1) begin : g_unpack_stq_h2
            assign wb_outputs.stq_heads[2].data[gi_h2] = wb_stq_head_2_data_w[gi_h2*8 +: 8];
        end
    endgenerate
    genvar gi_h3;
    generate
        for (gi_h3 = 0; gi_h3 < CACHE_LINES_SIZE_B; gi_h3 = gi_h3 + 1) begin : g_unpack_stq_h3
            assign wb_outputs.stq_heads[3].data[gi_h3] = wb_stq_head_3_data_w[gi_h3*8 +: 8];
        end
    endgenerate
    genvar gi_mio;
    generate
        for (gi_mio = 0; gi_mio < CACHE_LINES_SIZE_B; gi_mio = gi_mio + 1) begin : g_unpack_mio
            assign wb_outputs.mio_head.data[gi_mio] = wb_mio_head_data_w[gi_mio*8 +: 8];
        end
    endgenerate
    genvar gi_resbuf_out;
    generate
        for (gi_resbuf_out = 0; gi_resbuf_out < CACHE_LINES_SIZE_B*2; gi_resbuf_out = gi_resbuf_out + 1) begin : g_unpack_wb_next_res_buf
            assign wb_latches_next.res_buf[gi_resbuf_out] = exe_wb_latches_next_res_buf_w[gi_resbuf_out*8 +: 8];
        end
    endgenerate

    // ---------------------------------------------------------------------
    // RR enum-width bridge: RR_structural.v's flat outputs for the forwarded
    // exe_cs control signals are 6-bit OP_TYPE / 5-bit *_sel; the SV
    // `dc_latches_t.exe_cs` struct fields are 32-bit (default-int enum).
    // Capture the narrow flat outputs into bridge wires and zero-extend
    // into the struct fields.
    // ---------------------------------------------------------------------
    wire [5:0] dc_latches_next_exe_cs_OP_TYPE_w;
    wire [4:0] dc_latches_next_exe_cs_alu_inputA_sel_w;
    wire [4:0] dc_latches_next_exe_cs_alu_inputB_sel_w;
    wire [4:0] dc_latches_next_exe_cs_branch_target_sel_w;

    assign dc_latches_next.exe_cs.OP_TYPE            = {26'b0, dc_latches_next_exe_cs_OP_TYPE_w};
    assign dc_latches_next.exe_cs.alu_inputA_sel     = {27'b0, dc_latches_next_exe_cs_alu_inputA_sel_w};
    assign dc_latches_next.exe_cs.alu_inputB_sel     = {27'b0, dc_latches_next_exe_cs_alu_inputB_sel_w};
    assign dc_latches_next.exe_cs.branch_target_sel  = {27'b0, dc_latches_next_exe_cs_branch_target_sel_w};

    // ---------------------------------------------------------------------
    // Decode enum-width bridges: Decode_structural.v's flat outputs for
    // the forwarded exe_cs control signals are 6-bit OP_TYPE / 5-bit *_sel
    // for both normal_latches and rep_latches; the SV
    // `rr_latches_general_t.exe_cs` struct fields are 32-bit (default-int
    // enum). Zero-extend each into the corresponding struct field.
    // ---------------------------------------------------------------------
    wire [5:0] rr_latches_next_normal_latches_exe_cs_OP_TYPE_w;
    wire [4:0] rr_latches_next_normal_latches_exe_cs_alu_inputA_sel_w;
    wire [4:0] rr_latches_next_normal_latches_exe_cs_alu_inputB_sel_w;
    wire [4:0] rr_latches_next_normal_latches_exe_cs_branch_target_sel_w;

    wire [5:0] rr_latches_next_rep_latches_exe_cs_OP_TYPE_w;
    wire [4:0] rr_latches_next_rep_latches_exe_cs_alu_inputA_sel_w;
    wire [4:0] rr_latches_next_rep_latches_exe_cs_alu_inputB_sel_w;
    wire [4:0] rr_latches_next_rep_latches_exe_cs_branch_target_sel_w;

    assign rr_latches_next.normal_latches.exe_cs.OP_TYPE            = {26'b0, rr_latches_next_normal_latches_exe_cs_OP_TYPE_w};
    assign rr_latches_next.normal_latches.exe_cs.alu_inputA_sel     = {27'b0, rr_latches_next_normal_latches_exe_cs_alu_inputA_sel_w};
    assign rr_latches_next.normal_latches.exe_cs.alu_inputB_sel     = {27'b0, rr_latches_next_normal_latches_exe_cs_alu_inputB_sel_w};
    assign rr_latches_next.normal_latches.exe_cs.branch_target_sel  = {27'b0, rr_latches_next_normal_latches_exe_cs_branch_target_sel_w};

    assign rr_latches_next.rep_latches.exe_cs.OP_TYPE               = {26'b0, rr_latches_next_rep_latches_exe_cs_OP_TYPE_w};
    assign rr_latches_next.rep_latches.exe_cs.alu_inputA_sel        = {27'b0, rr_latches_next_rep_latches_exe_cs_alu_inputA_sel_w};
    assign rr_latches_next.rep_latches.exe_cs.alu_inputB_sel        = {27'b0, rr_latches_next_rep_latches_exe_cs_alu_inputB_sel_w};
    assign rr_latches_next.rep_latches.exe_cs.branch_target_sel     = {27'b0, rr_latches_next_rep_latches_exe_cs_branch_target_sel_w};

    // ---------------------------------------------------------------------
    // Decode IDM data pack: idm_outputs.idm_slots[i].data is byte_t[16].
    // Decode_structural.v takes 128-bit packed buses per slot.
    // ---------------------------------------------------------------------
    wire [127:0] idm_outs_idm_slots_0_data_w;
    wire [127:0] idm_outs_idm_slots_1_data_w;
    wire [127:0] idm_outs_idm_slots_2_data_w;
    wire [127:0] idm_outs_idm_slots_3_data_w;

    genvar gi_idm_data;
    generate
        for (gi_idm_data = 0; gi_idm_data < CACHE_LINES_SIZE_B; gi_idm_data = gi_idm_data + 1) begin : g_pack_idm_data
            assign idm_outs_idm_slots_0_data_w[gi_idm_data*8 +: 8] = idm_outputs.idm_slots[0].data[gi_idm_data];
            assign idm_outs_idm_slots_1_data_w[gi_idm_data*8 +: 8] = idm_outputs.idm_slots[1].data[gi_idm_data];
            assign idm_outs_idm_slots_2_data_w[gi_idm_data*8 +: 8] = idm_outputs.idm_slots[2].data[gi_idm_data];
            assign idm_outs_idm_slots_3_data_w[gi_idm_data*8 +: 8] = idm_outputs.idm_slots[3].data[gi_idm_data];
        end
    endgenerate

    // assign rr_outputs = '{default: '0};
    // assign dc_outputs = '{default: '0};
    // assign mem_outputs = '{default: '0};
    // assign exe_outputs = '{default: '0};
    // assign wb_outputs = '{default: '0};

    //assign icache out and dache out
    assign out2ICache_o = fetch_outputs.fetch_2_icache;

    //dealing with dc to dcache
    assign out2DCache_o = '{
            ld_addr_0_V : dc_outputs.ld_addr_0_V,
            ld_addr_0 : dc_outputs.ld_addr_0,
            ld_addr_1_V : dc_outputs.ld_addr_1_V,
            ld_addr_1 : dc_outputs.ld_addr_1,
            ld_addr_MIO_V : dc_outputs.ld_addr_MIO_V,
            ld_addr_MIO : dc_outputs.ld_addr_MIO,
            //memStalling : mem_outputs.stall,
            stq_heads : wb_outputs.stq_heads,
            stq_info_mio : wb_outputs.mio_head,
            memStage_CLR_REQ: mem_outputs.clr_dcache_arb_latches,
            memStage_CLR_REQ_MIO: mem_outputs.clr_dcache_mio_latch
        };


    Fetch fetch_unit (
        .clk(clk),
        .rst(rst),
        .icache_info_i(ICacheIn_i),
        .idm_info_i(idm_outputs),
        .decode_outs_i(decode_outputs),
        .rr_outs_i(rr_outputs),
        .dc_outs_i(dc_outputs),
        .mem_outs_i(mem_outputs),
        .exe_outs_i(exe_outputs),
        .dma_int(inFromDMA_i.intOut),
        .wb_outs_i(wb_outputs),
        .outs_o(fetch_outputs)
    );

    IDM idm_unit (
        .clk(clk),
        .rst(rst),
        .fetch_outs_i(fetch_outputs),
        .idm_outs_o(idm_outputs)
    );

    Decode decode_unit (
        .clk(clk),
        .rst(rst),

        // ---- idm_outputs_t (idm_outs_i) -- per-slot unroll ----
        .idm_outs_idm_slots_0_valid          (idm_outputs.idm_slots[0].valid),
        .idm_outs_idm_slots_0_br_valid       (idm_outputs.idm_slots[0].br_valid),
        .idm_outs_idm_slots_0_br_eip         (idm_outputs.idm_slots[0].br_eip),
        .idm_outs_idm_slots_0_br_btb_target  (idm_outputs.idm_slots[0].br_btb_target),
        .idm_outs_idm_slots_0_br_xcl         (idm_outputs.idm_slots[0].br_xcl),
        .idm_outs_idm_slots_0_data           (idm_outs_idm_slots_0_data_w),

        .idm_outs_idm_slots_1_valid          (idm_outputs.idm_slots[1].valid),
        .idm_outs_idm_slots_1_br_valid       (idm_outputs.idm_slots[1].br_valid),
        .idm_outs_idm_slots_1_br_eip         (idm_outputs.idm_slots[1].br_eip),
        .idm_outs_idm_slots_1_br_btb_target  (idm_outputs.idm_slots[1].br_btb_target),
        .idm_outs_idm_slots_1_br_xcl         (idm_outputs.idm_slots[1].br_xcl),
        .idm_outs_idm_slots_1_data           (idm_outs_idm_slots_1_data_w),

        .idm_outs_idm_slots_2_valid          (idm_outputs.idm_slots[2].valid),
        .idm_outs_idm_slots_2_br_valid       (idm_outputs.idm_slots[2].br_valid),
        .idm_outs_idm_slots_2_br_eip         (idm_outputs.idm_slots[2].br_eip),
        .idm_outs_idm_slots_2_br_btb_target  (idm_outputs.idm_slots[2].br_btb_target),
        .idm_outs_idm_slots_2_br_xcl         (idm_outputs.idm_slots[2].br_xcl),
        .idm_outs_idm_slots_2_data           (idm_outs_idm_slots_2_data_w),

        .idm_outs_idm_slots_3_valid          (idm_outputs.idm_slots[3].valid),
        .idm_outs_idm_slots_3_br_valid       (idm_outputs.idm_slots[3].br_valid),
        .idm_outs_idm_slots_3_br_eip         (idm_outputs.idm_slots[3].br_eip),
        .idm_outs_idm_slots_3_br_btb_target  (idm_outputs.idm_slots[3].br_btb_target),
        .idm_outs_idm_slots_3_br_xcl         (idm_outputs.idm_slots[3].br_xcl),
        .idm_outs_idm_slots_3_data           (idm_outs_idm_slots_3_data_w),

        // ---- fetch_outputs_t (fetch_outs_i) ----
        .fetch_outs_exp_pipe_clear           (fetch_outputs.exp_pipe_clear),
        .fetch_outs_exp_mode_jk              (fetch_outputs.exp_mode_jk),
        .fetch_outs_int_mode_jk              (fetch_outputs.int_mode_jk),

        // ---- rr_outputs_t (rr_outs_i) ----
        .rr_outs_valid                       (rr_outputs.valid),
        .rr_outs_stall                       (rr_outputs.stall),
        .rr_outs_ecx_sb                      (rr_outputs.ecx_sb),
        .rr_outs_ecx                         (rr_outputs.ecx),
        .rr_outs_eax                         (rr_outputs.eax),
        .rr_outs_codeSeg_limit               (rr_outputs.codeSeg_limit),

        // ---- dc_outputs_t (dc_outs_i) ----
        .dc_outs_valid                       (dc_outputs.valid),
        .dc_outs_stall                       (dc_outputs.stall),
        .dc_outs_dc_eip                      (dc_outputs.dc_eip),

        // ---- mem_outputs_t (mem_outs_i) ----
        .mem_outs_valid                      (mem_outputs.valid),
        .mem_outs_stall                      (mem_outputs.stall),

        // ---- exe_outputs_t (exe_outs_i) ----
        .exe_outs_valid                      (exe_outputs.valid),
        .exe_outs_br_res_valid               (exe_outputs.br_res_out.valid),
        .exe_outs_br_res_flush               (exe_outputs.br_res_out.flush),
        .exe_outs_br_res_br_target           (exe_outputs.br_res_out.br_target),
        .exe_outs_clr_ZF_sb                  (exe_outputs.clr_ZF_sb),
        .exe_outs_ZF                         (exe_outputs.ZF),

        // ---- wb_outputs_t (wb_outs_i) ----
        .wb_outs_wb_stall                    (wb_outputs.wb_stall),

        // ====================================================================
        // rr_latches_t (rr_latches_next) -- normal_latches
        // ====================================================================
        .rr_latches_next_normal_latches_valid                       (rr_latches_next.normal_latches.valid),

        // rr_cs_t
        .rr_latches_next_normal_latches_cs_ST_SEL                   (rr_latches_next.normal_latches.cs.ST_SEL),
        .rr_latches_next_normal_latches_cs_MODRM_NEEDED             (rr_latches_next.normal_latches.cs.MODRM_NEEDED),
        .rr_latches_next_normal_latches_cs_RM_IS_DR                 (rr_latches_next.normal_latches.cs.RM_IS_DR),
        .rr_latches_next_normal_latches_cs_SWITCH_LD_ADDY           (rr_latches_next.normal_latches.cs.SWITCH_LD_ADDY),
        .rr_latches_next_normal_latches_cs_LD_OP                    (rr_latches_next.normal_latches.cs.LD_OP),
        .rr_latches_next_normal_latches_cs_ST_OP                    (rr_latches_next.normal_latches.cs.ST_OP),
        .rr_latches_next_normal_latches_cs_dr_id                    (rr_latches_next.normal_latches.cs.dr_id),
        .rr_latches_next_normal_latches_cs_sr_id                    (rr_latches_next.normal_latches.cs.sr_id),
        .rr_latches_next_normal_latches_cs_dr_rd                    (rr_latches_next.normal_latches.cs.dr_rd),
        .rr_latches_next_normal_latches_cs_sr_rd                    (rr_latches_next.normal_latches.cs.sr_rd),
        .rr_latches_next_normal_latches_cs_eax_rd                   (rr_latches_next.normal_latches.cs.eax_rd),
        .rr_latches_next_normal_latches_cs_dr_wr                    (rr_latches_next.normal_latches.cs.dr_wr),
        .rr_latches_next_normal_latches_cs_sr_wr                    (rr_latches_next.normal_latches.cs.sr_wr),
        .rr_latches_next_normal_latches_cs_eax_wr                   (rr_latches_next.normal_latches.cs.eax_wr),
        .rr_latches_next_normal_latches_cs_MOVS_OP                  (rr_latches_next.normal_latches.cs.MOVS_OP),
        .rr_latches_next_normal_latches_cs_datasize                 (rr_latches_next.normal_latches.cs.datasize),
        .rr_latches_next_normal_latches_cs_will_mod_zf              (rr_latches_next.normal_latches.cs.will_mod_zf),
        .rr_latches_next_normal_latches_cs_seg_1_valid              (rr_latches_next.normal_latches.cs.seg_1_valid),
        .rr_latches_next_normal_latches_cs_seg_0_id                 (rr_latches_next.normal_latches.cs.seg_0_id),
        .rr_latches_next_normal_latches_cs_seg_1_id                 (rr_latches_next.normal_latches.cs.seg_1_id),
        .rr_latches_next_normal_latches_cs_special_modrm_bs         (rr_latches_next.normal_latches.cs.special_modrm_bs),
        .rr_latches_next_normal_latches_cs_special_br               (rr_latches_next.normal_latches.cs.special_br),

        // dc_cs_t
        .rr_latches_next_normal_latches_dc_cs_LD_OP                 (rr_latches_next.normal_latches.dc_cs.LD_OP),
        .rr_latches_next_normal_latches_dc_cs_ST_OP                 (rr_latches_next.normal_latches.dc_cs.ST_OP),
        .rr_latches_next_normal_latches_dc_cs_dr_upper8             (rr_latches_next.normal_latches.dc_cs.dr_upper8),
        .rr_latches_next_normal_latches_dc_cs_sr_upper8             (rr_latches_next.normal_latches.dc_cs.sr_upper8),
        .rr_latches_next_normal_latches_dc_cs_datasize              (rr_latches_next.normal_latches.dc_cs.datasize),

        // mem_cs_t
        .rr_latches_next_normal_latches_mem_cs_ST_OP                (rr_latches_next.normal_latches.mem_cs.ST_OP),
        .rr_latches_next_normal_latches_mem_cs_LD_OP                (rr_latches_next.normal_latches.mem_cs.LD_OP),

        // exe_cs_t (enum-width bridges for the four 32-bit struct fields)
        .rr_latches_next_normal_latches_exe_cs_ST_OP                (rr_latches_next.normal_latches.exe_cs.ST_OP),
        .rr_latches_next_normal_latches_exe_cs_OP_TYPE              (rr_latches_next_normal_latches_exe_cs_OP_TYPE_w),
        .rr_latches_next_normal_latches_exe_cs_alu_inputA_sel       (rr_latches_next_normal_latches_exe_cs_alu_inputA_sel_w),
        .rr_latches_next_normal_latches_exe_cs_alu_inputB_sel       (rr_latches_next_normal_latches_exe_cs_alu_inputB_sel_w),
        .rr_latches_next_normal_latches_exe_cs_branch_target_sel    (rr_latches_next_normal_latches_exe_cs_branch_target_sel_w),
        .rr_latches_next_normal_latches_exe_cs_shift_by_one         (rr_latches_next.normal_latches.exe_cs.shift_by_one),
        .rr_latches_next_normal_latches_exe_cs_br_ucond             (rr_latches_next.normal_latches.exe_cs.br_ucond),
        .rr_latches_next_normal_latches_exe_cs_relative_branch      (rr_latches_next.normal_latches.exe_cs.relative_branch),
        .rr_latches_next_normal_latches_exe_cs_special_br           (rr_latches_next.normal_latches.exe_cs.special_br),
        .rr_latches_next_normal_latches_exe_cs_is_far               (rr_latches_next.normal_latches.exe_cs.is_far),
        .rr_latches_next_normal_latches_exe_cs_is_call              (rr_latches_next.normal_latches.exe_cs.is_call),
        .rr_latches_next_normal_latches_exe_cs_second_flag_needed   (rr_latches_next.normal_latches.exe_cs.second_flag_needed),
        .rr_latches_next_normal_latches_exe_cs_rep_no_zf_update     (rr_latches_next.normal_latches.exe_cs.rep_no_zf_update),

        // wb_cs_t
        .rr_latches_next_normal_latches_wb_cs_ST_OP                 (rr_latches_next.normal_latches.wb_cs.ST_OP),
        .rr_latches_next_normal_latches_wb_cs_WB_DR                 (rr_latches_next.normal_latches.wb_cs.WB_DR),
        .rr_latches_next_normal_latches_wb_cs_WB_SR                 (rr_latches_next.normal_latches.wb_cs.WB_SR),
        .rr_latches_next_normal_latches_wb_cs_WB_EAX                (rr_latches_next.normal_latches.wb_cs.WB_EAX),

        // br_info_t
        .rr_latches_next_normal_latches_br_info_valid               (rr_latches_next.normal_latches.br_info.valid),
        .rr_latches_next_normal_latches_br_info_br_eip              (rr_latches_next.normal_latches.br_info.br_eip),
        .rr_latches_next_normal_latches_br_info_br_xcl              (rr_latches_next.normal_latches.br_info.br_xcl),
        .rr_latches_next_normal_latches_br_info_br_pred_taken       (rr_latches_next.normal_latches.br_info.br_pred_taken),
        .rr_latches_next_normal_latches_br_info_speculative_target  (rr_latches_next.normal_latches.br_info.speculative_target),

        .rr_latches_next_normal_latches_NEIP                        (rr_latches_next.normal_latches.NEIP),
        .rr_latches_next_normal_latches_EIP                         (rr_latches_next.normal_latches.EIP),
        .rr_latches_next_normal_latches_EAX                         (rr_latches_next.normal_latches.EAX),
        .rr_latches_next_normal_latches_imm64                       (rr_latches_next.normal_latches.imm64),

        .rr_latches_next_normal_latches_sib_idx_id                  (rr_latches_next.normal_latches.sib_idx_id),
        .rr_latches_next_normal_latches_sib_base_id                 (rr_latches_next.normal_latches.sib_base_id),
        .rr_latches_next_normal_latches_sib_needed                  (rr_latches_next.normal_latches.sib_needed),
        .rr_latches_next_normal_latches_sib_scale                   (rr_latches_next.normal_latches.sib_scale),
        .rr_latches_next_normal_latches_disp_needed                 (rr_latches_next.normal_latches.disp_needed),
        .rr_latches_next_normal_latches_disp_size                   (rr_latches_next.normal_latches.disp_size),
        .rr_latches_next_normal_latches_displacement                (rr_latches_next.normal_latches.displacement),

        // ====================================================================
        // rr_latches_t (rr_latches_next) -- rep_latches
        // ====================================================================
        .rr_latches_next_rep_latches_valid                       (rr_latches_next.rep_latches.valid),

        .rr_latches_next_rep_latches_cs_ST_SEL                   (rr_latches_next.rep_latches.cs.ST_SEL),
        .rr_latches_next_rep_latches_cs_MODRM_NEEDED             (rr_latches_next.rep_latches.cs.MODRM_NEEDED),
        .rr_latches_next_rep_latches_cs_RM_IS_DR                 (rr_latches_next.rep_latches.cs.RM_IS_DR),
        .rr_latches_next_rep_latches_cs_SWITCH_LD_ADDY           (rr_latches_next.rep_latches.cs.SWITCH_LD_ADDY),
        .rr_latches_next_rep_latches_cs_LD_OP                    (rr_latches_next.rep_latches.cs.LD_OP),
        .rr_latches_next_rep_latches_cs_ST_OP                    (rr_latches_next.rep_latches.cs.ST_OP),
        .rr_latches_next_rep_latches_cs_dr_id                    (rr_latches_next.rep_latches.cs.dr_id),
        .rr_latches_next_rep_latches_cs_sr_id                    (rr_latches_next.rep_latches.cs.sr_id),
        .rr_latches_next_rep_latches_cs_dr_rd                    (rr_latches_next.rep_latches.cs.dr_rd),
        .rr_latches_next_rep_latches_cs_sr_rd                    (rr_latches_next.rep_latches.cs.sr_rd),
        .rr_latches_next_rep_latches_cs_eax_rd                   (rr_latches_next.rep_latches.cs.eax_rd),
        .rr_latches_next_rep_latches_cs_dr_wr                    (rr_latches_next.rep_latches.cs.dr_wr),
        .rr_latches_next_rep_latches_cs_sr_wr                    (rr_latches_next.rep_latches.cs.sr_wr),
        .rr_latches_next_rep_latches_cs_eax_wr                   (rr_latches_next.rep_latches.cs.eax_wr),
        .rr_latches_next_rep_latches_cs_MOVS_OP                  (rr_latches_next.rep_latches.cs.MOVS_OP),
        .rr_latches_next_rep_latches_cs_datasize                 (rr_latches_next.rep_latches.cs.datasize),
        .rr_latches_next_rep_latches_cs_will_mod_zf              (rr_latches_next.rep_latches.cs.will_mod_zf),
        .rr_latches_next_rep_latches_cs_seg_1_valid              (rr_latches_next.rep_latches.cs.seg_1_valid),
        .rr_latches_next_rep_latches_cs_seg_0_id                 (rr_latches_next.rep_latches.cs.seg_0_id),
        .rr_latches_next_rep_latches_cs_seg_1_id                 (rr_latches_next.rep_latches.cs.seg_1_id),
        .rr_latches_next_rep_latches_cs_special_modrm_bs         (rr_latches_next.rep_latches.cs.special_modrm_bs),
        .rr_latches_next_rep_latches_cs_special_br               (rr_latches_next.rep_latches.cs.special_br),

        .rr_latches_next_rep_latches_dc_cs_LD_OP                 (rr_latches_next.rep_latches.dc_cs.LD_OP),
        .rr_latches_next_rep_latches_dc_cs_ST_OP                 (rr_latches_next.rep_latches.dc_cs.ST_OP),
        .rr_latches_next_rep_latches_dc_cs_dr_upper8             (rr_latches_next.rep_latches.dc_cs.dr_upper8),
        .rr_latches_next_rep_latches_dc_cs_sr_upper8             (rr_latches_next.rep_latches.dc_cs.sr_upper8),
        .rr_latches_next_rep_latches_dc_cs_datasize              (rr_latches_next.rep_latches.dc_cs.datasize),

        .rr_latches_next_rep_latches_mem_cs_ST_OP                (rr_latches_next.rep_latches.mem_cs.ST_OP),
        .rr_latches_next_rep_latches_mem_cs_LD_OP                (rr_latches_next.rep_latches.mem_cs.LD_OP),

        .rr_latches_next_rep_latches_exe_cs_ST_OP                (rr_latches_next.rep_latches.exe_cs.ST_OP),
        .rr_latches_next_rep_latches_exe_cs_OP_TYPE              (rr_latches_next_rep_latches_exe_cs_OP_TYPE_w),
        .rr_latches_next_rep_latches_exe_cs_alu_inputA_sel       (rr_latches_next_rep_latches_exe_cs_alu_inputA_sel_w),
        .rr_latches_next_rep_latches_exe_cs_alu_inputB_sel       (rr_latches_next_rep_latches_exe_cs_alu_inputB_sel_w),
        .rr_latches_next_rep_latches_exe_cs_branch_target_sel    (rr_latches_next_rep_latches_exe_cs_branch_target_sel_w),
        .rr_latches_next_rep_latches_exe_cs_shift_by_one         (rr_latches_next.rep_latches.exe_cs.shift_by_one),
        .rr_latches_next_rep_latches_exe_cs_br_ucond             (rr_latches_next.rep_latches.exe_cs.br_ucond),
        .rr_latches_next_rep_latches_exe_cs_relative_branch      (rr_latches_next.rep_latches.exe_cs.relative_branch),
        .rr_latches_next_rep_latches_exe_cs_special_br           (rr_latches_next.rep_latches.exe_cs.special_br),
        .rr_latches_next_rep_latches_exe_cs_is_far               (rr_latches_next.rep_latches.exe_cs.is_far),
        .rr_latches_next_rep_latches_exe_cs_is_call              (rr_latches_next.rep_latches.exe_cs.is_call),
        .rr_latches_next_rep_latches_exe_cs_second_flag_needed   (rr_latches_next.rep_latches.exe_cs.second_flag_needed),
        .rr_latches_next_rep_latches_exe_cs_rep_no_zf_update     (rr_latches_next.rep_latches.exe_cs.rep_no_zf_update),

        .rr_latches_next_rep_latches_wb_cs_ST_OP                 (rr_latches_next.rep_latches.wb_cs.ST_OP),
        .rr_latches_next_rep_latches_wb_cs_WB_DR                 (rr_latches_next.rep_latches.wb_cs.WB_DR),
        .rr_latches_next_rep_latches_wb_cs_WB_SR                 (rr_latches_next.rep_latches.wb_cs.WB_SR),
        .rr_latches_next_rep_latches_wb_cs_WB_EAX                (rr_latches_next.rep_latches.wb_cs.WB_EAX),

        .rr_latches_next_rep_latches_br_info_valid               (rr_latches_next.rep_latches.br_info.valid),
        .rr_latches_next_rep_latches_br_info_br_eip              (rr_latches_next.rep_latches.br_info.br_eip),
        .rr_latches_next_rep_latches_br_info_br_xcl              (rr_latches_next.rep_latches.br_info.br_xcl),
        .rr_latches_next_rep_latches_br_info_br_pred_taken       (rr_latches_next.rep_latches.br_info.br_pred_taken),
        .rr_latches_next_rep_latches_br_info_speculative_target  (rr_latches_next.rep_latches.br_info.speculative_target),

        .rr_latches_next_rep_latches_NEIP                        (rr_latches_next.rep_latches.NEIP),
        .rr_latches_next_rep_latches_EIP                         (rr_latches_next.rep_latches.EIP),
        .rr_latches_next_rep_latches_EAX                         (rr_latches_next.rep_latches.EAX),
        .rr_latches_next_rep_latches_imm64                       (rr_latches_next.rep_latches.imm64),

        .rr_latches_next_rep_latches_sib_idx_id                  (rr_latches_next.rep_latches.sib_idx_id),
        .rr_latches_next_rep_latches_sib_base_id                 (rr_latches_next.rep_latches.sib_base_id),
        .rr_latches_next_rep_latches_sib_needed                  (rr_latches_next.rep_latches.sib_needed),
        .rr_latches_next_rep_latches_sib_scale                   (rr_latches_next.rep_latches.sib_scale),
        .rr_latches_next_rep_latches_disp_needed                 (rr_latches_next.rep_latches.disp_needed),
        .rr_latches_next_rep_latches_disp_size                   (rr_latches_next.rep_latches.disp_size),
        .rr_latches_next_rep_latches_displacement                (rr_latches_next.rep_latches.displacement),

        // ---- decode_outputs_t (outs_o) ----
        .outs_valid                          (decode_outputs.valid),
        .outs_stall                          (decode_outputs.stall),
        .outs_eip                            (decode_outputs.eip),
        .outs_invalid_instruction            (decode_outputs.invalid_instruction),
        .outs_decode_gp                      (decode_outputs.decode_gp),
        .outs_rr_stage_latch_we              (decode_outputs.rr_stage_latch_we),
        .outs_rep_latch                      (decode_outputs.rep_latch),
        .outs_decode_forward                 (decode_outputs.decode_forward)
    );

    RR_Latches rr_latches_unit (
        .clk(clk),
        .rst(rst),
        .nextLatches_i(rr_latches_next),
        .latches_o(rr_latches),
        .write_enable_i(decode_outputs.rr_stage_latch_we),
        .flush(exe_outputs.br_res_out.flush),
        .farFlush(exe_outputs.br_res_out.farFlush),
        .exp_pipe_clear(fetch_outputs.exp_pipe_clear)
    );

    RR rr_unit (
        .clk(clk),
        .rst(rst),

        // ====================================================================
        // rr_latches_t (latches_i) -- normal_latches
        // ====================================================================
        .latches_normal_latches_valid                       (rr_latches.normal_latches.valid),

        // rr_cs_t
        .latches_normal_latches_cs_ST_SEL                   (rr_latches.normal_latches.cs.ST_SEL),
        .latches_normal_latches_cs_MODRM_NEEDED             (rr_latches.normal_latches.cs.MODRM_NEEDED),
        .latches_normal_latches_cs_RM_IS_DR                 (rr_latches.normal_latches.cs.RM_IS_DR),
        .latches_normal_latches_cs_SWITCH_LD_ADDY           (rr_latches.normal_latches.cs.SWITCH_LD_ADDY),
        .latches_normal_latches_cs_LD_OP                    (rr_latches.normal_latches.cs.LD_OP),
        .latches_normal_latches_cs_ST_OP                    (rr_latches.normal_latches.cs.ST_OP),
        .latches_normal_latches_cs_dr_id                    (rr_latches.normal_latches.cs.dr_id),
        .latches_normal_latches_cs_sr_id                    (rr_latches.normal_latches.cs.sr_id),
        .latches_normal_latches_cs_dr_rd                    (rr_latches.normal_latches.cs.dr_rd),
        .latches_normal_latches_cs_sr_rd                    (rr_latches.normal_latches.cs.sr_rd),
        .latches_normal_latches_cs_eax_rd                   (rr_latches.normal_latches.cs.eax_rd),
        .latches_normal_latches_cs_dr_wr                    (rr_latches.normal_latches.cs.dr_wr),
        .latches_normal_latches_cs_sr_wr                    (rr_latches.normal_latches.cs.sr_wr),
        .latches_normal_latches_cs_eax_wr                   (rr_latches.normal_latches.cs.eax_wr),
        .latches_normal_latches_cs_MOVS_OP                  (rr_latches.normal_latches.cs.MOVS_OP),
        .latches_normal_latches_cs_datasize                 (rr_latches.normal_latches.cs.datasize),
        .latches_normal_latches_cs_will_mod_zf              (rr_latches.normal_latches.cs.will_mod_zf),
        .latches_normal_latches_cs_seg_1_valid              (rr_latches.normal_latches.cs.seg_1_valid),
        .latches_normal_latches_cs_seg_0_id                 (rr_latches.normal_latches.cs.seg_0_id),
        .latches_normal_latches_cs_seg_1_id                 (rr_latches.normal_latches.cs.seg_1_id),
        .latches_normal_latches_cs_special_modrm_bs         (rr_latches.normal_latches.cs.special_modrm_bs),
        .latches_normal_latches_cs_special_br               (rr_latches.normal_latches.cs.special_br),

        // dc_cs_t
        .latches_normal_latches_dc_cs_LD_OP                 (rr_latches.normal_latches.dc_cs.LD_OP),
        .latches_normal_latches_dc_cs_ST_OP                 (rr_latches.normal_latches.dc_cs.ST_OP),
        .latches_normal_latches_dc_cs_dr_upper8             (rr_latches.normal_latches.dc_cs.dr_upper8),
        .latches_normal_latches_dc_cs_sr_upper8             (rr_latches.normal_latches.dc_cs.sr_upper8),
        .latches_normal_latches_dc_cs_datasize              (rr_latches.normal_latches.dc_cs.datasize),

        // mem_cs_t
        .latches_normal_latches_mem_cs_ST_OP                (rr_latches.normal_latches.mem_cs.ST_OP),
        .latches_normal_latches_mem_cs_LD_OP                (rr_latches.normal_latches.mem_cs.LD_OP),

        // exe_cs_t (slice enums down to flat-port widths)
        .latches_normal_latches_exe_cs_ST_OP                (rr_latches.normal_latches.exe_cs.ST_OP),
        .latches_normal_latches_exe_cs_OP_TYPE              (rr_latches.normal_latches.exe_cs.OP_TYPE[5:0]),
        .latches_normal_latches_exe_cs_alu_inputA_sel       (rr_latches.normal_latches.exe_cs.alu_inputA_sel[4:0]),
        .latches_normal_latches_exe_cs_alu_inputB_sel       (rr_latches.normal_latches.exe_cs.alu_inputB_sel[4:0]),
        .latches_normal_latches_exe_cs_branch_target_sel    (rr_latches.normal_latches.exe_cs.branch_target_sel[4:0]),
        .latches_normal_latches_exe_cs_shift_by_one         (rr_latches.normal_latches.exe_cs.shift_by_one),
        .latches_normal_latches_exe_cs_br_ucond             (rr_latches.normal_latches.exe_cs.br_ucond),
        .latches_normal_latches_exe_cs_relative_branch      (rr_latches.normal_latches.exe_cs.relative_branch),
        .latches_normal_latches_exe_cs_special_br           (rr_latches.normal_latches.exe_cs.special_br),
        .latches_normal_latches_exe_cs_is_far               (rr_latches.normal_latches.exe_cs.is_far),
        .latches_normal_latches_exe_cs_is_call              (rr_latches.normal_latches.exe_cs.is_call),
        .latches_normal_latches_exe_cs_second_flag_needed   (rr_latches.normal_latches.exe_cs.second_flag_needed),
        .latches_normal_latches_exe_cs_rep_no_zf_update     (rr_latches.normal_latches.exe_cs.rep_no_zf_update),

        // wb_cs_t
        .latches_normal_latches_wb_cs_ST_OP                 (rr_latches.normal_latches.wb_cs.ST_OP),
        .latches_normal_latches_wb_cs_WB_DR                 (rr_latches.normal_latches.wb_cs.WB_DR),
        .latches_normal_latches_wb_cs_WB_SR                 (rr_latches.normal_latches.wb_cs.WB_SR),
        .latches_normal_latches_wb_cs_WB_EAX                (rr_latches.normal_latches.wb_cs.WB_EAX),

        // br_info_t
        .latches_normal_latches_br_info_valid               (rr_latches.normal_latches.br_info.valid),
        .latches_normal_latches_br_info_br_eip              (rr_latches.normal_latches.br_info.br_eip),
        .latches_normal_latches_br_info_br_xcl              (rr_latches.normal_latches.br_info.br_xcl),
        .latches_normal_latches_br_info_br_pred_taken       (rr_latches.normal_latches.br_info.br_pred_taken),
        .latches_normal_latches_br_info_speculative_target  (rr_latches.normal_latches.br_info.speculative_target),

        .latches_normal_latches_NEIP                        (rr_latches.normal_latches.NEIP),
        .latches_normal_latches_EIP                         (rr_latches.normal_latches.EIP),
        .latches_normal_latches_EAX                         (rr_latches.normal_latches.EAX),
        .latches_normal_latches_imm64                       (rr_latches.normal_latches.imm64),

        .latches_normal_latches_sib_idx_id                  (rr_latches.normal_latches.sib_idx_id),
        .latches_normal_latches_sib_base_id                 (rr_latches.normal_latches.sib_base_id),
        .latches_normal_latches_sib_needed                  (rr_latches.normal_latches.sib_needed),
        .latches_normal_latches_sib_scale                   (rr_latches.normal_latches.sib_scale),
        .latches_normal_latches_disp_needed                 (rr_latches.normal_latches.disp_needed),
        .latches_normal_latches_disp_size                   (rr_latches.normal_latches.disp_size),
        .latches_normal_latches_displacement                (rr_latches.normal_latches.displacement),

        // ====================================================================
        // rr_latches_t (latches_i) -- rep_latches
        // ====================================================================
        .latches_rep_latches_valid                          (rr_latches.rep_latches.valid),

        // rr_cs_t
        .latches_rep_latches_cs_ST_SEL                      (rr_latches.rep_latches.cs.ST_SEL),
        .latches_rep_latches_cs_MODRM_NEEDED                (rr_latches.rep_latches.cs.MODRM_NEEDED),
        .latches_rep_latches_cs_RM_IS_DR                    (rr_latches.rep_latches.cs.RM_IS_DR),
        .latches_rep_latches_cs_SWITCH_LD_ADDY              (rr_latches.rep_latches.cs.SWITCH_LD_ADDY),
        .latches_rep_latches_cs_LD_OP                       (rr_latches.rep_latches.cs.LD_OP),
        .latches_rep_latches_cs_ST_OP                       (rr_latches.rep_latches.cs.ST_OP),
        .latches_rep_latches_cs_dr_id                       (rr_latches.rep_latches.cs.dr_id),
        .latches_rep_latches_cs_sr_id                       (rr_latches.rep_latches.cs.sr_id),
        .latches_rep_latches_cs_dr_rd                       (rr_latches.rep_latches.cs.dr_rd),
        .latches_rep_latches_cs_sr_rd                       (rr_latches.rep_latches.cs.sr_rd),
        .latches_rep_latches_cs_eax_rd                      (rr_latches.rep_latches.cs.eax_rd),
        .latches_rep_latches_cs_dr_wr                       (rr_latches.rep_latches.cs.dr_wr),
        .latches_rep_latches_cs_sr_wr                       (rr_latches.rep_latches.cs.sr_wr),
        .latches_rep_latches_cs_eax_wr                      (rr_latches.rep_latches.cs.eax_wr),
        .latches_rep_latches_cs_MOVS_OP                     (rr_latches.rep_latches.cs.MOVS_OP),
        .latches_rep_latches_cs_datasize                    (rr_latches.rep_latches.cs.datasize),
        .latches_rep_latches_cs_will_mod_zf                 (rr_latches.rep_latches.cs.will_mod_zf),
        .latches_rep_latches_cs_seg_1_valid                 (rr_latches.rep_latches.cs.seg_1_valid),
        .latches_rep_latches_cs_seg_0_id                    (rr_latches.rep_latches.cs.seg_0_id),
        .latches_rep_latches_cs_seg_1_id                    (rr_latches.rep_latches.cs.seg_1_id),
        .latches_rep_latches_cs_special_modrm_bs            (rr_latches.rep_latches.cs.special_modrm_bs),
        .latches_rep_latches_cs_special_br                  (rr_latches.rep_latches.cs.special_br),

        // dc_cs_t
        .latches_rep_latches_dc_cs_LD_OP                    (rr_latches.rep_latches.dc_cs.LD_OP),
        .latches_rep_latches_dc_cs_ST_OP                    (rr_latches.rep_latches.dc_cs.ST_OP),
        .latches_rep_latches_dc_cs_dr_upper8                (rr_latches.rep_latches.dc_cs.dr_upper8),
        .latches_rep_latches_dc_cs_sr_upper8                (rr_latches.rep_latches.dc_cs.sr_upper8),
        .latches_rep_latches_dc_cs_datasize                 (rr_latches.rep_latches.dc_cs.datasize),

        // mem_cs_t
        .latches_rep_latches_mem_cs_ST_OP                   (rr_latches.rep_latches.mem_cs.ST_OP),
        .latches_rep_latches_mem_cs_LD_OP                   (rr_latches.rep_latches.mem_cs.LD_OP),

        // exe_cs_t (slice)
        .latches_rep_latches_exe_cs_ST_OP                   (rr_latches.rep_latches.exe_cs.ST_OP),
        .latches_rep_latches_exe_cs_OP_TYPE                 (rr_latches.rep_latches.exe_cs.OP_TYPE[5:0]),
        .latches_rep_latches_exe_cs_alu_inputA_sel          (rr_latches.rep_latches.exe_cs.alu_inputA_sel[4:0]),
        .latches_rep_latches_exe_cs_alu_inputB_sel          (rr_latches.rep_latches.exe_cs.alu_inputB_sel[4:0]),
        .latches_rep_latches_exe_cs_branch_target_sel       (rr_latches.rep_latches.exe_cs.branch_target_sel[4:0]),
        .latches_rep_latches_exe_cs_shift_by_one            (rr_latches.rep_latches.exe_cs.shift_by_one),
        .latches_rep_latches_exe_cs_br_ucond                (rr_latches.rep_latches.exe_cs.br_ucond),
        .latches_rep_latches_exe_cs_relative_branch         (rr_latches.rep_latches.exe_cs.relative_branch),
        .latches_rep_latches_exe_cs_special_br              (rr_latches.rep_latches.exe_cs.special_br),
        .latches_rep_latches_exe_cs_is_far                  (rr_latches.rep_latches.exe_cs.is_far),
        .latches_rep_latches_exe_cs_is_call                 (rr_latches.rep_latches.exe_cs.is_call),
        .latches_rep_latches_exe_cs_second_flag_needed      (rr_latches.rep_latches.exe_cs.second_flag_needed),
        .latches_rep_latches_exe_cs_rep_no_zf_update        (rr_latches.rep_latches.exe_cs.rep_no_zf_update),

        // wb_cs_t
        .latches_rep_latches_wb_cs_ST_OP                    (rr_latches.rep_latches.wb_cs.ST_OP),
        .latches_rep_latches_wb_cs_WB_DR                    (rr_latches.rep_latches.wb_cs.WB_DR),
        .latches_rep_latches_wb_cs_WB_SR                    (rr_latches.rep_latches.wb_cs.WB_SR),
        .latches_rep_latches_wb_cs_WB_EAX                   (rr_latches.rep_latches.wb_cs.WB_EAX),

        // br_info_t
        .latches_rep_latches_br_info_valid                  (rr_latches.rep_latches.br_info.valid),
        .latches_rep_latches_br_info_br_eip                 (rr_latches.rep_latches.br_info.br_eip),
        .latches_rep_latches_br_info_br_xcl                 (rr_latches.rep_latches.br_info.br_xcl),
        .latches_rep_latches_br_info_br_pred_taken          (rr_latches.rep_latches.br_info.br_pred_taken),
        .latches_rep_latches_br_info_speculative_target     (rr_latches.rep_latches.br_info.speculative_target),

        .latches_rep_latches_NEIP                           (rr_latches.rep_latches.NEIP),
        .latches_rep_latches_EIP                            (rr_latches.rep_latches.EIP),
        .latches_rep_latches_EAX                            (rr_latches.rep_latches.EAX),
        .latches_rep_latches_imm64                          (rr_latches.rep_latches.imm64),

        .latches_rep_latches_sib_idx_id                     (rr_latches.rep_latches.sib_idx_id),
        .latches_rep_latches_sib_base_id                    (rr_latches.rep_latches.sib_base_id),
        .latches_rep_latches_sib_needed                     (rr_latches.rep_latches.sib_needed),
        .latches_rep_latches_sib_scale                      (rr_latches.rep_latches.sib_scale),
        .latches_rep_latches_disp_needed                    (rr_latches.rep_latches.disp_needed),
        .latches_rep_latches_disp_size                      (rr_latches.rep_latches.disp_size),
        .latches_rep_latches_displacement                   (rr_latches.rep_latches.displacement),

        // ====================================================================
        // fetch_outputs_t / decode_outputs_t / dc_outputs_t / mem_outputs_t /
        // exe_outputs_t / wb_outputs_t  (only the consumed fields)
        // ====================================================================
        .fetch_outs_exp_pipe_clear                          (fetch_outputs.exp_pipe_clear),
        .decode_outs_rep_latch                              (decode_outputs.rep_latch),
        .decode_outs_decode_gp                              (decode_outputs.decode_gp),
        .dc_outs_valid                                      (dc_outputs.valid),
        .dc_outs_stall                                      (dc_outputs.stall),
        .mem_outs_valid                                     (mem_outputs.valid),
        .mem_outs_stall                                     (mem_outputs.stall),
        .exe_outs_valid                                     (exe_outputs.valid),
        .exe_outs_br_res_flush                              (exe_outputs.br_res_out.flush),
        .exe_outs_br_res_farFlush                           (exe_outputs.br_res_out.farFlush),
        .exe_outs_br_res_callFlush                          (exe_outputs.br_res_out.callFlush),
        .exe_outs_DR_0_we                                   (exe_outputs.DR_0_we),
        .exe_outs_DR_0_id                                   (exe_outputs.DR_0_id),
        .exe_outs_DR_0_data                                 (exe_outputs.DR_0_data),
        .exe_outs_DR_1_we                                   (exe_outputs.DR_1_we),
        .exe_outs_DR_1_id                                   (exe_outputs.DR_1_id),
        .exe_outs_DR_1_data                                 (exe_outputs.DR_1_data),
        .wb_outs_wb_stall                                   (wb_outputs.wb_stall),

        // ====================================================================
        // dc_latches_t (dc_latches_next)
        // ====================================================================
        .dc_latches_next_valid                              (dc_latches_next.valid),

        // dc_cs_t
        .dc_latches_next_cs_LD_OP                           (dc_latches_next.cs.LD_OP),
        .dc_latches_next_cs_ST_OP                           (dc_latches_next.cs.ST_OP),
        .dc_latches_next_cs_dr_upper8                       (dc_latches_next.cs.dr_upper8),
        .dc_latches_next_cs_sr_upper8                       (dc_latches_next.cs.sr_upper8),
        .dc_latches_next_cs_datasize                        (dc_latches_next.cs.datasize),

        // mem_cs_t
        .dc_latches_next_mem_cs_ST_OP                       (dc_latches_next.mem_cs.ST_OP),
        .dc_latches_next_mem_cs_LD_OP                       (dc_latches_next.mem_cs.LD_OP),

        // exe_cs_t (enum-width bridges for the four 32-bit struct fields)
        .dc_latches_next_exe_cs_ST_OP                       (dc_latches_next.exe_cs.ST_OP),
        .dc_latches_next_exe_cs_OP_TYPE                     (dc_latches_next_exe_cs_OP_TYPE_w),
        .dc_latches_next_exe_cs_alu_inputA_sel              (dc_latches_next_exe_cs_alu_inputA_sel_w),
        .dc_latches_next_exe_cs_alu_inputB_sel              (dc_latches_next_exe_cs_alu_inputB_sel_w),
        .dc_latches_next_exe_cs_branch_target_sel           (dc_latches_next_exe_cs_branch_target_sel_w),
        .dc_latches_next_exe_cs_shift_by_one                (dc_latches_next.exe_cs.shift_by_one),
        .dc_latches_next_exe_cs_br_ucond                    (dc_latches_next.exe_cs.br_ucond),
        .dc_latches_next_exe_cs_relative_branch             (dc_latches_next.exe_cs.relative_branch),
        .dc_latches_next_exe_cs_special_br                  (dc_latches_next.exe_cs.special_br),
        .dc_latches_next_exe_cs_is_far                      (dc_latches_next.exe_cs.is_far),
        .dc_latches_next_exe_cs_is_call                     (dc_latches_next.exe_cs.is_call),
        .dc_latches_next_exe_cs_second_flag_needed          (dc_latches_next.exe_cs.second_flag_needed),
        .dc_latches_next_exe_cs_rep_no_zf_update            (dc_latches_next.exe_cs.rep_no_zf_update),

        // wb_cs_t
        .dc_latches_next_wb_cs_ST_OP                        (dc_latches_next.wb_cs.ST_OP),
        .dc_latches_next_wb_cs_WB_DR                        (dc_latches_next.wb_cs.WB_DR),
        .dc_latches_next_wb_cs_WB_SR                        (dc_latches_next.wb_cs.WB_SR),
        .dc_latches_next_wb_cs_WB_EAX                       (dc_latches_next.wb_cs.WB_EAX),

        // br_info_t
        .dc_latches_next_br_info_valid                      (dc_latches_next.br_info.valid),
        .dc_latches_next_br_info_br_eip                     (dc_latches_next.br_info.br_eip),
        .dc_latches_next_br_info_br_xcl                     (dc_latches_next.br_info.br_xcl),
        .dc_latches_next_br_info_br_pred_taken              (dc_latches_next.br_info.br_pred_taken),
        .dc_latches_next_br_info_speculative_target         (dc_latches_next.br_info.speculative_target),

        .dc_latches_next_rr_gp                              (dc_latches_next.rr_gp),

        .dc_latches_next_ld_vaddy                           (dc_latches_next.ld_vaddy),
        .dc_latches_next_seg0_limit_w_datasize              (dc_latches_next.seg0_limit_w_datasize),
        .dc_latches_next_seg0_limit_wo_datasize             (dc_latches_next.seg0_limit_wo_datasize),
        .dc_latches_next_next_ld_vaddy                      (dc_latches_next.next_ld_vaddy),
        .dc_latches_next_ld_laddy                           (dc_latches_next.ld_laddy),
        .dc_latches_next_ld_stack_access                    (dc_latches_next.ld_stack_access),

        .dc_latches_next_st_vaddy                           (dc_latches_next.st_vaddy),
        .dc_latches_next_seg1_limit_w_datasize              (dc_latches_next.seg1_limit_w_datasize),
        .dc_latches_next_seg1_limit_wo_datasize             (dc_latches_next.seg1_limit_wo_datasize),
        .dc_latches_next_next_st_vaddy                      (dc_latches_next.next_st_vaddy),
        .dc_latches_next_st_laddy                           (dc_latches_next.st_laddy),
        .dc_latches_next_st_stack_access                    (dc_latches_next.st_stack_access),

        .dc_latches_next_NEIP                               (dc_latches_next.NEIP),
        .dc_latches_next_EIP                                (dc_latches_next.EIP),
        .dc_latches_next_EAX                                (dc_latches_next.EAX),
        .dc_latches_next_imm64                              (dc_latches_next.imm64),

        .dc_latches_next_sr_id                              (dc_latches_next.sr_id),
        .dc_latches_next_sr_data                            (dc_latches_next.sr_data),
        .dc_latches_next_dr_id                              (dc_latches_next.dr_id),
        .dc_latches_next_dr_data                            (dc_latches_next.dr_data),

        // ====================================================================
        // rr_outputs_t (outs_o)
        // ====================================================================
        .outs_valid                                         (rr_outputs.valid),
        .outs_stall                                         (rr_outputs.stall),
        .outs_ecx_sb                                        (rr_outputs.ecx_sb),
        .outs_ecx                                           (rr_outputs.ecx),
        .outs_eax                                           (rr_outputs.eax),
        .outs_set_ZF_sb                                     (rr_outputs.set_ZF_sb),
        .outs_codeSeg_sb                                    (rr_outputs.codeSeg_sb),
        .outs_codeSeg_data                                  (rr_outputs.codeSeg_data),
        .outs_codeSeg_limit                                 (rr_outputs.codeSeg_limit),
        .outs_dc_stage_latch_we                             (rr_outputs.dc_stage_latch_we),

        // regFileValues_o[NUM_REGS=26] -- one 64-bit element per reg id
        .outs_regFileValues_0                               (rr_outputs.regFileValues[0]),
        .outs_regFileValues_1                               (rr_outputs.regFileValues[1]),
        .outs_regFileValues_2                               (rr_outputs.regFileValues[2]),
        .outs_regFileValues_3                               (rr_outputs.regFileValues[3]),
        .outs_regFileValues_4                               (rr_outputs.regFileValues[4]),
        .outs_regFileValues_5                               (rr_outputs.regFileValues[5]),
        .outs_regFileValues_6                               (rr_outputs.regFileValues[6]),
        .outs_regFileValues_7                               (rr_outputs.regFileValues[7]),
        .outs_regFileValues_8                               (rr_outputs.regFileValues[8]),
        .outs_regFileValues_9                               (rr_outputs.regFileValues[9]),
        .outs_regFileValues_10                              (rr_outputs.regFileValues[10]),
        .outs_regFileValues_11                              (rr_outputs.regFileValues[11]),
        .outs_regFileValues_12                              (rr_outputs.regFileValues[12]),
        .outs_regFileValues_13                              (rr_outputs.regFileValues[13]),
        .outs_regFileValues_14                              (rr_outputs.regFileValues[14]),
        .outs_regFileValues_15                              (rr_outputs.regFileValues[15]),
        .outs_regFileValues_16                              (rr_outputs.regFileValues[16]),
        .outs_regFileValues_17                              (rr_outputs.regFileValues[17]),
        .outs_regFileValues_18                              (rr_outputs.regFileValues[18]),
        .outs_regFileValues_19                              (rr_outputs.regFileValues[19]),
        .outs_regFileValues_20                              (rr_outputs.regFileValues[20]),
        .outs_regFileValues_21                              (rr_outputs.regFileValues[21]),
        .outs_regFileValues_22                              (rr_outputs.regFileValues[22]),
        .outs_regFileValues_23                              (rr_outputs.regFileValues[23]),
        .outs_regFileValues_24                              (rr_outputs.regFileValues[24]),
        .outs_regFileValues_25                              (rr_outputs.regFileValues[25])
    );

    DC_Latches dc_latches_unit (
        .clk(clk),
        .rst(rst),
        .nextLatches_i(dc_latches_next),
        .latches_o(dc_latches),
        .write_enable_i(rr_outputs.dc_stage_latch_we),
        .flush(exe_outputs.br_res_out.flush),
        .farFlush(exe_outputs.br_res_out.farFlush),
        .exp_pipe_clear(fetch_outputs.exp_pipe_clear)
    );

    DC dc_unit (
        .clk(clk),
        .rst(rst),
        .latches_i(dc_latches),
        .fetch_outs_i(fetch_outputs),
        .mem_outs_i(mem_outputs),
        .exe_outs_i(exe_outputs),
        .wb_outs_i(wb_outputs),
        .mem_latches_next_o(mem_latches_next),
        .req_served_mio(DCacheIn_i.reqServed_MIO),
        .req_served_0(DCacheIn_i.reqServed_0),
        .req_served_1(DCacheIn_i.reqServed_1),
        .dc_outs_o(dc_outputs)
    );



    MEM_Latches mem_latches_unit (
        .clk(clk),
        .rst(rst),
        .nextLatches_i(mem_latches_next),
        .write_enable_i(dc_outputs.mem_stage_latch_we),
        .flush(exe_outputs.br_res_out.flush),
        .farFlush(exe_outputs.br_res_out.farFlush),
        .latches_o(mem_latches)
    );


    MEM mem_unit (
        .clk(clk),
        .rst(rst),

        .latches_i (mem_latches),
        .exe_outs_i(exe_outputs),
        .wb_outs_i (wb_outputs),

        .hit(DCacheIn_i.hit),
        .cacheline(DCacheIn_i.cacheline),
        .exe_latches_next_o(exe_latches_next),
        .hit_MIO(DCacheIn_i.hit_MIO),
        .line_MIO(DCacheIn_i.line_MIO),
        .outs_o(mem_outputs)
    );


    EXE_Latches exe_latches_unit (
        .clk(clk),
        .rst(rst),
        .nextLatches_i(exe_latches_next),
        .write_enable_i(mem_outputs.exe_stage_latch_we),
        .flush(exe_outputs.br_res_out.flush),
        .latches_o(exe_latches)
    );


    EXE execute_unit (
        .clk(clk),
        .rst(rst),

        // ---- exe_latches_t (latches_i) ----
        // Enum-typed control fields default to 32-bit in SV; slice down to
        // the flat-port widths so the lint stays clean.
        //   exe_cs_operation_type_e : 6 bits  (40 ops)
        //   source_selector_e       : 5 bits  (20 sources)
        .latches_valid                     (exe_latches.valid),
        .latches_cs_ST_OP                  (exe_latches.cs.ST_OP),
        .latches_cs_OP_TYPE                (exe_latches.cs.OP_TYPE[5:0]),
        .latches_cs_alu_inputA_sel         (exe_latches.cs.alu_inputA_sel[4:0]),
        .latches_cs_alu_inputB_sel         (exe_latches.cs.alu_inputB_sel[4:0]),
        .latches_cs_branch_target_sel      (exe_latches.cs.branch_target_sel[4:0]),
        .latches_cs_shift_by_one           (exe_latches.cs.shift_by_one),
        .latches_cs_br_ucond               (exe_latches.cs.br_ucond),
        .latches_cs_relative_branch        (exe_latches.cs.relative_branch),
        .latches_cs_special_br             (exe_latches.cs.special_br),
        .latches_cs_is_far                 (exe_latches.cs.is_far),
        .latches_cs_is_call                (exe_latches.cs.is_call),
        .latches_cs_second_flag_needed     (exe_latches.cs.second_flag_needed),
        .latches_cs_rep_no_zf_update       (exe_latches.cs.rep_no_zf_update),
        .latches_wb_cs_ST_OP               (exe_latches.wb_cs.ST_OP),
        .latches_wb_cs_WB_DR               (exe_latches.wb_cs.WB_DR),
        .latches_wb_cs_WB_SR               (exe_latches.wb_cs.WB_SR),
        .latches_wb_cs_WB_EAX              (exe_latches.wb_cs.WB_EAX),
        .latches_data_size_vec             (exe_latches.data_size_vec),
        .latches_sr_data_size_vec          (exe_latches.sr_data_size_vec),
        .latches_shift_sr_up               (exe_latches.shift_sr_up),
        .latches_shift_sr_down             (exe_latches.shift_sr_down),
        .latches_ST_XCL                    (exe_latches.ST_XCL),
        .latches_ST_PADDR_0                (exe_latches.ST_PADDR_0),
        .latches_ST_PADDR_1                (exe_latches.ST_PADDR_1),
        .latches_MIO                       (exe_latches.MIO),
        .latches_br_info_valid             (exe_latches.br_info.valid),
        .latches_br_info_br_eip            (exe_latches.br_info.br_eip),
        .latches_br_info_br_xcl            (exe_latches.br_info.br_xcl),
        .latches_br_info_br_pred_taken    (exe_latches.br_info.br_pred_taken),
        .latches_br_info_speculative_target(exe_latches.br_info.speculative_target),
        .latches_br_rel_target             (exe_latches.br_rel_target),
        .latches_NEIP                      (exe_latches.NEIP),
        .latches_EIP                       (exe_latches.EIP),
        .latches_EAX                       (exe_latches.EAX),
        .latches_imm64                     (exe_latches.imm64),
        .latches_ld_buf                    (exe_latches_ld_buf_w),
        .latches_sr_id                     (exe_latches.sr_id),
        .latches_sr_data                   (exe_latches.sr_data),
        .latches_dr_id                     (exe_latches.dr_id),
        .latches_dr_data                   (exe_latches.dr_data),
        .latches_ld_addy                   (exe_latches.ld_addy),

        // ---- wb_outputs_t (wb_outs_i) ----
        .wb_outs_wb_stall                  (wb_outputs.wb_stall),

        // ---- rr_outputs_t (rr_outs_i) ----
        .rr_outs_codeSeg_data              (rr_outputs.codeSeg_data),
        .rr_outs_regFileValues_0           (rr_outputs.regFileValues[0]),
        .rr_outs_regFileValues_1           (rr_outputs.regFileValues[1]),
        .rr_outs_regFileValues_2           (rr_outputs.regFileValues[2]),
        .rr_outs_regFileValues_3           (rr_outputs.regFileValues[3]),
        .rr_outs_regFileValues_4           (rr_outputs.regFileValues[4]),
        .rr_outs_regFileValues_5           (rr_outputs.regFileValues[5]),
        .rr_outs_regFileValues_6           (rr_outputs.regFileValues[6]),
        .rr_outs_regFileValues_7           (rr_outputs.regFileValues[7]),
        .rr_outs_regFileValues_8           (rr_outputs.regFileValues[8]),
        .rr_outs_regFileValues_9           (rr_outputs.regFileValues[9]),
        .rr_outs_regFileValues_10          (rr_outputs.regFileValues[10]),
        .rr_outs_regFileValues_11          (rr_outputs.regFileValues[11]),
        .rr_outs_regFileValues_12          (rr_outputs.regFileValues[12]),
        .rr_outs_regFileValues_13          (rr_outputs.regFileValues[13]),
        .rr_outs_regFileValues_14          (rr_outputs.regFileValues[14]),
        .rr_outs_regFileValues_15          (rr_outputs.regFileValues[15]),
        .rr_outs_regFileValues_16          (rr_outputs.regFileValues[16]),
        .rr_outs_regFileValues_17          (rr_outputs.regFileValues[17]),
        .rr_outs_regFileValues_18          (rr_outputs.regFileValues[18]),
        .rr_outs_regFileValues_19          (rr_outputs.regFileValues[19]),
        .rr_outs_regFileValues_20          (rr_outputs.regFileValues[20]),
        .rr_outs_regFileValues_21          (rr_outputs.regFileValues[21]),
        .rr_outs_regFileValues_22          (rr_outputs.regFileValues[22]),
        .rr_outs_regFileValues_23          (rr_outputs.regFileValues[23]),
        .rr_outs_regFileValues_24          (rr_outputs.regFileValues[24]),
        .rr_outs_regFileValues_25          (rr_outputs.regFileValues[25]),

        // ---- wb_latches_t (wb_latches_next_o) ----
        .wb_latches_next_valid             (wb_latches_next.valid),
        .wb_latches_next_cs_ST_OP          (wb_latches_next.cs.ST_OP),
        .wb_latches_next_cs_WB_DR          (wb_latches_next.cs.WB_DR),
        .wb_latches_next_cs_WB_SR          (wb_latches_next.cs.WB_SR),
        .wb_latches_next_cs_WB_EAX         (wb_latches_next.cs.WB_EAX),
        .wb_latches_next_ST_XCL            (wb_latches_next.ST_XCL),
        .wb_latches_next_ST_PADDR_0        (wb_latches_next.ST_PADDR_0),
        .wb_latches_next_ST_BIT_VEC_0      (wb_latches_next.ST_BIT_VEC_0),
        .wb_latches_next_ST_PADDR_1        (wb_latches_next.ST_PADDR_1),
        .wb_latches_next_ST_BIT_VEC_1      (wb_latches_next.ST_BIT_VEC_1),
        .wb_latches_next_MIO               (wb_latches_next.MIO),
        .wb_latches_next_EIP               (wb_latches_next.EIP),
        .wb_latches_next_res_buf           (exe_wb_latches_next_res_buf_w),
        .wb_latches_next_sr_id             (wb_latches_next.sr_id),
        .wb_latches_next_sr_data           (wb_latches_next.sr_data),
        .wb_latches_next_dr_id             (wb_latches_next.dr_id),
        .wb_latches_next_dr_data           (wb_latches_next.dr_data),
        .wb_latches_next_EAX               (wb_latches_next.EAX),

        // ---- exe_outputs_t (outs_o) ----
        .outs_valid                        (exe_outputs.valid),
        .outs_br_res_valid                 (exe_outputs.br_res_out.valid),
        .outs_br_res_flush                 (exe_outputs.br_res_out.flush),
        .outs_br_res_farFlush              (exe_outputs.br_res_out.farFlush),
        .outs_br_res_callFlush             (exe_outputs.br_res_out.callFlush),
        .outs_br_res_miss_prediction       (exe_outputs.br_res_out.miss_prediction),
        .outs_br_res_br_eip                (exe_outputs.br_res_out.br_eip),
        .outs_br_res_neip                  (exe_outputs.br_res_out.neip),
        .outs_br_res_br_target             (exe_outputs.br_res_out.br_target),
        .outs_br_res_taken                 (exe_outputs.br_res_out.taken),
        .outs_br_res_br_XCL                (exe_outputs.br_res_out.br_XCL),
        .outs_br_res_clr_exp_mode          (exe_outputs.br_res_out.clr_exp_mode),
        .outs_br_res_br_ucond              (exe_outputs.br_res_out.br_ucond),
        .outs_DR_0_we                      (exe_outputs.DR_0_we),
        .outs_DR_0_id                      (exe_outputs.DR_0_id),
        .outs_DR_0_data                    (exe_outputs.DR_0_data),
        .outs_DR_1_we                      (exe_outputs.DR_1_we),
        .outs_DR_1_id                      (exe_outputs.DR_1_id),
        .outs_DR_1_data                    (exe_outputs.DR_1_data),
        .outs_clr_ZF_sb                    (exe_outputs.clr_ZF_sb),
        .outs_ZF                           (exe_outputs.ZF),
        .outs_ST_OP                        (exe_outputs.ST_OP),
        .outs_ST_XCL                       (exe_outputs.ST_XCL),
        .outs_ST_PADDR_0                   (exe_outputs.ST_PADDR_0),
        .outs_ST_PADDR_1                   (exe_outputs.ST_PADDR_1),
        .outs_wb_stage_latch_we            (exe_outputs.wb_stage_latch_we)
    );

    WB_Latches wb_latches_unit (
        .clk(clk),
        .rst(rst),
        .nextLatches_i(wb_latches_next),
        .write_enable_i(exe_outputs.wb_stage_latch_we),
        .latches_o(wb_latches)
    );

    WB write_back_unit (
        .clk(clk),
        .rst(rst),

        // ---- wb_latches_t ----
        .wb_latches_valid                  (wb_latches.valid),
        .wb_latches_cs_ST_OP               (wb_latches.cs.ST_OP),
        .wb_latches_cs_WB_DR               (wb_latches.cs.WB_DR),
        .wb_latches_cs_WB_SR               (wb_latches.cs.WB_SR),
        .wb_latches_cs_WB_EAX              (wb_latches.cs.WB_EAX),
        .wb_latches_ST_XCL                 (wb_latches.ST_XCL),
        .wb_latches_ST_PADDR_0             (wb_latches.ST_PADDR_0),
        .wb_latches_ST_BIT_VEC_0           (wb_latches.ST_BIT_VEC_0),
        .wb_latches_ST_PADDR_1             (wb_latches.ST_PADDR_1),
        .wb_latches_ST_BIT_VEC_1           (wb_latches.ST_BIT_VEC_1),
        .wb_latches_MIO                    (wb_latches.MIO),
        .wb_latches_EIP                    (wb_latches.EIP),
        .wb_latches_res_buf                (wb_latches_res_buf_w),
        .wb_latches_sr_id                  (wb_latches.sr_id),
        .wb_latches_sr_data                (wb_latches.sr_data),
        .wb_latches_dr_id                  (wb_latches.dr_id),
        .wb_latches_dr_data                (wb_latches.dr_data),
        .wb_latches_EAX                    (wb_latches.EAX),

        // ---- write_success[NUM_WB_ST_QS] ----
        .write_success_0                   (DCacheIn_i.writeSuccess[0]),
        .write_success_1                   (DCacheIn_i.writeSuccess[1]),
        .write_success_2                   (DCacheIn_i.writeSuccess[2]),
        .write_success_3                   (DCacheIn_i.writeSuccess[3]),
        .write_success_mio                 (DCacheIn_i.writeSuccess_MIO),

        // ---- wb_outputs_t scalars ----
        .outputs_valid                     (wb_outputs.valid),
        .outputs_wb_stall                  (wb_outputs.wb_stall),
        .outputs_ST_OP                     (wb_outputs.ST_OP),
        .outputs_ST_XCL                    (wb_outputs.ST_XCL),
        .outputs_ST_PADDR_0                (wb_outputs.ST_PADDR_0),
        .outputs_ST_PADDR_1                (wb_outputs.ST_PADDR_1),

        // ---- wb_outputs_t.stq_heads[0..3] ----
        .outputs_stq_head_0_full           (wb_outputs.stq_heads[0].full),
        .outputs_stq_head_0_empty          (wb_outputs.stq_heads[0].empty),
        .outputs_stq_head_0_address        (wb_outputs.stq_heads[0].address),
        .outputs_stq_head_0_bit_vec        (wb_outputs.stq_heads[0].bit_vec),
        .outputs_stq_head_0_data           (wb_stq_head_0_data_w),
        .outputs_stq_head_1_full           (wb_outputs.stq_heads[1].full),
        .outputs_stq_head_1_empty          (wb_outputs.stq_heads[1].empty),
        .outputs_stq_head_1_address        (wb_outputs.stq_heads[1].address),
        .outputs_stq_head_1_bit_vec        (wb_outputs.stq_heads[1].bit_vec),
        .outputs_stq_head_1_data           (wb_stq_head_1_data_w),
        .outputs_stq_head_2_full           (wb_outputs.stq_heads[2].full),
        .outputs_stq_head_2_empty          (wb_outputs.stq_heads[2].empty),
        .outputs_stq_head_2_address        (wb_outputs.stq_heads[2].address),
        .outputs_stq_head_2_bit_vec        (wb_outputs.stq_heads[2].bit_vec),
        .outputs_stq_head_2_data           (wb_stq_head_2_data_w),
        .outputs_stq_head_3_full           (wb_outputs.stq_heads[3].full),
        .outputs_stq_head_3_empty          (wb_outputs.stq_heads[3].empty),
        .outputs_stq_head_3_address        (wb_outputs.stq_heads[3].address),
        .outputs_stq_head_3_bit_vec        (wb_outputs.stq_heads[3].bit_vec),
        .outputs_stq_head_3_data           (wb_stq_head_3_data_w),

        // ---- wb_outputs_t.mio_head ----
        .outputs_mio_head_full             (wb_outputs.mio_head.full),
        .outputs_mio_head_empty            (wb_outputs.mio_head.empty),
        .outputs_mio_head_address          (wb_outputs.mio_head.address),
        .outputs_mio_head_bit_vec          (wb_outputs.mio_head.bit_vec),
        .outputs_mio_head_data             (wb_mio_head_data_w),

        // ---- wb_outputs_t.dep_check.entries[0..15] ----
        .outputs_dep_check_entry_0_valid   (wb_outputs.dep_check.entries[0].valid),
        .outputs_dep_check_entry_0_address (wb_outputs.dep_check.entries[0].address),
        .outputs_dep_check_entry_1_valid   (wb_outputs.dep_check.entries[1].valid),
        .outputs_dep_check_entry_1_address (wb_outputs.dep_check.entries[1].address),
        .outputs_dep_check_entry_2_valid   (wb_outputs.dep_check.entries[2].valid),
        .outputs_dep_check_entry_2_address (wb_outputs.dep_check.entries[2].address),
        .outputs_dep_check_entry_3_valid   (wb_outputs.dep_check.entries[3].valid),
        .outputs_dep_check_entry_3_address (wb_outputs.dep_check.entries[3].address),
        .outputs_dep_check_entry_4_valid   (wb_outputs.dep_check.entries[4].valid),
        .outputs_dep_check_entry_4_address (wb_outputs.dep_check.entries[4].address),
        .outputs_dep_check_entry_5_valid   (wb_outputs.dep_check.entries[5].valid),
        .outputs_dep_check_entry_5_address (wb_outputs.dep_check.entries[5].address),
        .outputs_dep_check_entry_6_valid   (wb_outputs.dep_check.entries[6].valid),
        .outputs_dep_check_entry_6_address (wb_outputs.dep_check.entries[6].address),
        .outputs_dep_check_entry_7_valid   (wb_outputs.dep_check.entries[7].valid),
        .outputs_dep_check_entry_7_address (wb_outputs.dep_check.entries[7].address),
        .outputs_dep_check_entry_8_valid   (wb_outputs.dep_check.entries[8].valid),
        .outputs_dep_check_entry_8_address (wb_outputs.dep_check.entries[8].address),
        .outputs_dep_check_entry_9_valid   (wb_outputs.dep_check.entries[9].valid),
        .outputs_dep_check_entry_9_address (wb_outputs.dep_check.entries[9].address),
        .outputs_dep_check_entry_10_valid  (wb_outputs.dep_check.entries[10].valid),
        .outputs_dep_check_entry_10_address(wb_outputs.dep_check.entries[10].address),
        .outputs_dep_check_entry_11_valid  (wb_outputs.dep_check.entries[11].valid),
        .outputs_dep_check_entry_11_address(wb_outputs.dep_check.entries[11].address),
        .outputs_dep_check_entry_12_valid  (wb_outputs.dep_check.entries[12].valid),
        .outputs_dep_check_entry_12_address(wb_outputs.dep_check.entries[12].address),
        .outputs_dep_check_entry_13_valid  (wb_outputs.dep_check.entries[13].valid),
        .outputs_dep_check_entry_13_address(wb_outputs.dep_check.entries[13].address),
        .outputs_dep_check_entry_14_valid  (wb_outputs.dep_check.entries[14].valid),
        .outputs_dep_check_entry_14_address(wb_outputs.dep_check.entries[14].address),
        .outputs_dep_check_entry_15_valid  (wb_outputs.dep_check.entries[15].valid),
        .outputs_dep_check_entry_15_address(wb_outputs.dep_check.entries[15].address)
    );



endmodule
