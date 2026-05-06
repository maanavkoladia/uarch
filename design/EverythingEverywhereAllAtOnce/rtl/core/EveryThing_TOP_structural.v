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
    // DC enum-width bridge: DC_structural's flat ports for exe_cs control
    // signals are sized to their architectural widths (6-bit OP_TYPE,
    // 5-bit *_sel) while the SV `mem_latches_t.exe_cs` struct fields are
    // 32-bit (default-int enum). Capture the narrow flat outputs into
    // bridge wires and zero-extend into the struct fields.
    // ---------------------------------------------------------------------
    wire [5:0] mem_latches_next_exe_cs_OP_TYPE_w;
    wire [4:0] mem_latches_next_exe_cs_alu_inputA_sel_w;
    wire [4:0] mem_latches_next_exe_cs_alu_inputB_sel_w;
    wire [4:0] mem_latches_next_exe_cs_branch_target_sel_w;

    assign mem_latches_next.exe_cs.OP_TYPE            = {26'b0, mem_latches_next_exe_cs_OP_TYPE_w};
    assign mem_latches_next.exe_cs.alu_inputA_sel     = {27'b0, mem_latches_next_exe_cs_alu_inputA_sel_w};
    assign mem_latches_next.exe_cs.alu_inputB_sel     = {27'b0, mem_latches_next_exe_cs_alu_inputB_sel_w};
    assign mem_latches_next.exe_cs.branch_target_sel  = {27'b0, mem_latches_next_exe_cs_branch_target_sel_w};

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
        .idm_outs_i(idm_outputs),
        .fetch_outs_i(fetch_outputs),
        .rr_outs_i(rr_outputs),
        .dc_outs_i(dc_outputs),
        .mem_outs_i(mem_outputs),
        .exe_outs_i(exe_outputs),
        .wb_outs_i(wb_outputs),
        .rr_latches_next(rr_latches_next),
        .outs_o(decode_outputs)
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
        .latches_i(rr_latches),
        .fetch_outs_i(fetch_outputs),
        .decode_outs_i(decode_outputs),
        .dc_outs_i(dc_outputs),
        .mem_outs_i(mem_outputs),
        .exe_outs_i(exe_outputs),
        .wb_outs_i(wb_outputs),
        .dc_latches_next(dc_latches_next),
        .outs_o(rr_outputs)
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

        // ---- dc_latches_t (latches_i) ----
        .latches_valid                          (dc_latches.valid),

        // dc_cs_t
        .latches_cs_LD_OP                       (dc_latches.cs.LD_OP),
        .latches_cs_ST_OP                       (dc_latches.cs.ST_OP),
        .latches_cs_dr_upper8                   (dc_latches.cs.dr_upper8),
        .latches_cs_sr_upper8                   (dc_latches.cs.sr_upper8),
        .latches_cs_datasize                    (dc_latches.cs.datasize),

        // mem_cs_t
        .latches_mem_cs_ST_OP                   (dc_latches.mem_cs.ST_OP),
        .latches_mem_cs_LD_OP                   (dc_latches.mem_cs.LD_OP),

        // exe_cs_t (slice enums down to flat-port widths)
        .latches_exe_cs_ST_OP                   (dc_latches.exe_cs.ST_OP),
        .latches_exe_cs_OP_TYPE                 (dc_latches.exe_cs.OP_TYPE[5:0]),
        .latches_exe_cs_alu_inputA_sel          (dc_latches.exe_cs.alu_inputA_sel[4:0]),
        .latches_exe_cs_alu_inputB_sel          (dc_latches.exe_cs.alu_inputB_sel[4:0]),
        .latches_exe_cs_branch_target_sel       (dc_latches.exe_cs.branch_target_sel[4:0]),
        .latches_exe_cs_shift_by_one            (dc_latches.exe_cs.shift_by_one),
        .latches_exe_cs_br_ucond                (dc_latches.exe_cs.br_ucond),
        .latches_exe_cs_relative_branch         (dc_latches.exe_cs.relative_branch),
        .latches_exe_cs_special_br              (dc_latches.exe_cs.special_br),
        .latches_exe_cs_is_far                  (dc_latches.exe_cs.is_far),
        .latches_exe_cs_is_call                 (dc_latches.exe_cs.is_call),
        .latches_exe_cs_second_flag_needed      (dc_latches.exe_cs.second_flag_needed),
        .latches_exe_cs_rep_no_zf_update        (dc_latches.exe_cs.rep_no_zf_update),

        // wb_cs_t
        .latches_wb_cs_ST_OP                    (dc_latches.wb_cs.ST_OP),
        .latches_wb_cs_WB_DR                    (dc_latches.wb_cs.WB_DR),
        .latches_wb_cs_WB_SR                    (dc_latches.wb_cs.WB_SR),
        .latches_wb_cs_WB_EAX                   (dc_latches.wb_cs.WB_EAX),

        // br_info_t
        .latches_br_info_valid                  (dc_latches.br_info.valid),
        .latches_br_info_br_eip                 (dc_latches.br_info.br_eip),
        .latches_br_info_br_xcl                 (dc_latches.br_info.br_xcl),
        .latches_br_info_br_pred_taken          (dc_latches.br_info.br_pred_taken),
        .latches_br_info_speculative_target     (dc_latches.br_info.speculative_target),

        .latches_rr_gp                          (dc_latches.rr_gp),

        // load-side address / segmentation
        .latches_ld_vaddy                       (dc_latches.ld_vaddy),
        .latches_seg0_limit_w_datasize          (dc_latches.seg0_limit_w_datasize),
        .latches_seg0_limit_wo_datasize         (dc_latches.seg0_limit_wo_datasize),
        .latches_next_ld_vaddy                  (dc_latches.next_ld_vaddy),
        .latches_ld_laddy                       (dc_latches.ld_laddy),
        .latches_ld_stack_access                (dc_latches.ld_stack_access),

        // store-side address / segmentation
        .latches_st_vaddy                       (dc_latches.st_vaddy),
        .latches_seg1_limit_w_datasize          (dc_latches.seg1_limit_w_datasize),
        .latches_seg1_limit_wo_datasize         (dc_latches.seg1_limit_wo_datasize),
        .latches_next_st_vaddy                  (dc_latches.next_st_vaddy),
        .latches_st_laddy                       (dc_latches.st_laddy),
        .latches_st_stack_access                (dc_latches.st_stack_access),

        .latches_NEIP                           (dc_latches.NEIP),
        .latches_EIP                            (dc_latches.EIP),
        .latches_EAX                            (dc_latches.EAX),
        .latches_imm64                          (dc_latches.imm64),

        .latches_sr_id                          (dc_latches.sr_id),
        .latches_sr_data                        (dc_latches.sr_data),
        .latches_dr_id                          (dc_latches.dr_id),
        .latches_dr_data                        (dc_latches.dr_data),

        // ---- fetch_outputs_t (fetch_outs_i) ----
        .fetch_outs_exp_pipe_clear              (fetch_outputs.exp_pipe_clear),

        // ---- mem_outputs_t (mem_outs_i) ----
        .mem_outs_valid                         (mem_outputs.valid),
        .mem_outs_stall                         (mem_outputs.stall),
        .mem_outs_ST_OP                         (mem_outputs.ST_OP),
        .mem_outs_ST_XCL                        (mem_outputs.ST_XCL),
        .mem_outs_ST_PADDR_0                    (mem_outputs.ST_PADDR_0),
        .mem_outs_ST_PADDR_1                    (mem_outputs.ST_PADDR_1),

        // ---- exe_outputs_t (exe_outs_i) ----
        .exe_outs_valid                         (exe_outputs.valid),
        .exe_outs_ST_OP                         (exe_outputs.ST_OP),
        .exe_outs_ST_XCL                        (exe_outputs.ST_XCL),
        .exe_outs_ST_PADDR_0                    (exe_outputs.ST_PADDR_0),
        .exe_outs_ST_PADDR_1                    (exe_outputs.ST_PADDR_1),
        .exe_outs_br_res_flush                  (exe_outputs.br_res_out.flush),

        // ---- wb_outputs_t (wb_outs_i) ----
        .wb_outs_valid                          (wb_outputs.valid),
        .wb_outs_wb_stall                       (wb_outputs.wb_stall),
        .wb_outs_ST_OP                          (wb_outputs.ST_OP),
        .wb_outs_ST_XCL                         (wb_outputs.ST_XCL),
        .wb_outs_ST_PADDR_0                     (wb_outputs.ST_PADDR_0),
        .wb_outs_ST_PADDR_1                     (wb_outputs.ST_PADDR_1),

        // ---- wb_outputs_t.dep_check.entries[0..15] ----
        .wb_outs_dep_check_entry_0_valid        (wb_outputs.dep_check.entries[0].valid),
        .wb_outs_dep_check_entry_0_address      (wb_outputs.dep_check.entries[0].address),
        .wb_outs_dep_check_entry_1_valid        (wb_outputs.dep_check.entries[1].valid),
        .wb_outs_dep_check_entry_1_address      (wb_outputs.dep_check.entries[1].address),
        .wb_outs_dep_check_entry_2_valid        (wb_outputs.dep_check.entries[2].valid),
        .wb_outs_dep_check_entry_2_address      (wb_outputs.dep_check.entries[2].address),
        .wb_outs_dep_check_entry_3_valid        (wb_outputs.dep_check.entries[3].valid),
        .wb_outs_dep_check_entry_3_address      (wb_outputs.dep_check.entries[3].address),
        .wb_outs_dep_check_entry_4_valid        (wb_outputs.dep_check.entries[4].valid),
        .wb_outs_dep_check_entry_4_address      (wb_outputs.dep_check.entries[4].address),
        .wb_outs_dep_check_entry_5_valid        (wb_outputs.dep_check.entries[5].valid),
        .wb_outs_dep_check_entry_5_address      (wb_outputs.dep_check.entries[5].address),
        .wb_outs_dep_check_entry_6_valid        (wb_outputs.dep_check.entries[6].valid),
        .wb_outs_dep_check_entry_6_address      (wb_outputs.dep_check.entries[6].address),
        .wb_outs_dep_check_entry_7_valid        (wb_outputs.dep_check.entries[7].valid),
        .wb_outs_dep_check_entry_7_address      (wb_outputs.dep_check.entries[7].address),
        .wb_outs_dep_check_entry_8_valid        (wb_outputs.dep_check.entries[8].valid),
        .wb_outs_dep_check_entry_8_address      (wb_outputs.dep_check.entries[8].address),
        .wb_outs_dep_check_entry_9_valid        (wb_outputs.dep_check.entries[9].valid),
        .wb_outs_dep_check_entry_9_address      (wb_outputs.dep_check.entries[9].address),
        .wb_outs_dep_check_entry_10_valid       (wb_outputs.dep_check.entries[10].valid),
        .wb_outs_dep_check_entry_10_address     (wb_outputs.dep_check.entries[10].address),
        .wb_outs_dep_check_entry_11_valid       (wb_outputs.dep_check.entries[11].valid),
        .wb_outs_dep_check_entry_11_address     (wb_outputs.dep_check.entries[11].address),
        .wb_outs_dep_check_entry_12_valid       (wb_outputs.dep_check.entries[12].valid),
        .wb_outs_dep_check_entry_12_address     (wb_outputs.dep_check.entries[12].address),
        .wb_outs_dep_check_entry_13_valid       (wb_outputs.dep_check.entries[13].valid),
        .wb_outs_dep_check_entry_13_address     (wb_outputs.dep_check.entries[13].address),
        .wb_outs_dep_check_entry_14_valid       (wb_outputs.dep_check.entries[14].valid),
        .wb_outs_dep_check_entry_14_address     (wb_outputs.dep_check.entries[14].address),
        .wb_outs_dep_check_entry_15_valid       (wb_outputs.dep_check.entries[15].valid),
        .wb_outs_dep_check_entry_15_address     (wb_outputs.dep_check.entries[15].address),

        // ---- dcache request-served handshakes ----
        .req_served_mio                         (DCacheIn_i.reqServed_MIO),
        .req_served_0                           (DCacheIn_i.reqServed_0),
        .req_served_1                           (DCacheIn_i.reqServed_1),

        // ---- mem_latches_t (mem_latches_next_o) ----
        .mem_latches_next_valid                         (mem_latches_next.valid),

        .mem_latches_next_cs_ST_OP                      (mem_latches_next.cs.ST_OP),
        .mem_latches_next_cs_LD_OP                      (mem_latches_next.cs.LD_OP),

        .mem_latches_next_exe_cs_ST_OP                  (mem_latches_next.exe_cs.ST_OP),
        .mem_latches_next_exe_cs_OP_TYPE                (mem_latches_next_exe_cs_OP_TYPE_w),
        .mem_latches_next_exe_cs_alu_inputA_sel         (mem_latches_next_exe_cs_alu_inputA_sel_w),
        .mem_latches_next_exe_cs_alu_inputB_sel         (mem_latches_next_exe_cs_alu_inputB_sel_w),
        .mem_latches_next_exe_cs_branch_target_sel      (mem_latches_next_exe_cs_branch_target_sel_w),
        .mem_latches_next_exe_cs_shift_by_one           (mem_latches_next.exe_cs.shift_by_one),
        .mem_latches_next_exe_cs_br_ucond               (mem_latches_next.exe_cs.br_ucond),
        .mem_latches_next_exe_cs_relative_branch        (mem_latches_next.exe_cs.relative_branch),
        .mem_latches_next_exe_cs_special_br             (mem_latches_next.exe_cs.special_br),
        .mem_latches_next_exe_cs_is_far                 (mem_latches_next.exe_cs.is_far),
        .mem_latches_next_exe_cs_is_call                (mem_latches_next.exe_cs.is_call),
        .mem_latches_next_exe_cs_second_flag_needed     (mem_latches_next.exe_cs.second_flag_needed),
        .mem_latches_next_exe_cs_rep_no_zf_update       (mem_latches_next.exe_cs.rep_no_zf_update),

        .mem_latches_next_wb_cs_ST_OP                   (mem_latches_next.wb_cs.ST_OP),
        .mem_latches_next_wb_cs_WB_DR                   (mem_latches_next.wb_cs.WB_DR),
        .mem_latches_next_wb_cs_WB_SR                   (mem_latches_next.wb_cs.WB_SR),
        .mem_latches_next_wb_cs_WB_EAX                  (mem_latches_next.wb_cs.WB_EAX),

        .mem_latches_next_br_info_valid                 (mem_latches_next.br_info.valid),
        .mem_latches_next_br_info_br_eip                (mem_latches_next.br_info.br_eip),
        .mem_latches_next_br_info_br_xcl                (mem_latches_next.br_info.br_xcl),
        .mem_latches_next_br_info_br_pred_taken         (mem_latches_next.br_info.br_pred_taken),
        .mem_latches_next_br_info_speculative_target    (mem_latches_next.br_info.speculative_target),

        .mem_latches_next_data_size_vec                 (mem_latches_next.data_size_vec),
        .mem_latches_next_sr_data_size_vec              (mem_latches_next.sr_data_size_vec),
        .mem_latches_next_shift_sr_up                   (mem_latches_next.shift_sr_up),
        .mem_latches_next_shift_sr_down                 (mem_latches_next.shift_sr_down),

        .mem_latches_next_ST_XCL                        (mem_latches_next.ST_XCL),
        .mem_latches_next_ST_PADDR_0                    (mem_latches_next.ST_PADDR_0),
        .mem_latches_next_ST_PADDR_1                    (mem_latches_next.ST_PADDR_1),
        .mem_latches_next_MIO                           (mem_latches_next.MIO),

        .mem_latches_next_NEIP                          (mem_latches_next.NEIP),
        .mem_latches_next_EIP                           (mem_latches_next.EIP),
        .mem_latches_next_EAX                           (mem_latches_next.EAX),
        .mem_latches_next_imm64                         (mem_latches_next.imm64),

        .mem_latches_next_sr_id                         (mem_latches_next.sr_id),
        .mem_latches_next_sr_data                       (mem_latches_next.sr_data),
        .mem_latches_next_dr_id                         (mem_latches_next.dr_id),
        .mem_latches_next_dr_data                       (mem_latches_next.dr_data),

        .mem_latches_next_LD_XCL                        (mem_latches_next.LD_XCL),
        .mem_latches_next_swapLines                     (mem_latches_next.swapLines),
        .mem_latches_next_LD_PADDR_0                    (mem_latches_next.LD_PADDR_0),
        .mem_latches_next_LD_PADDR_1                    (mem_latches_next.LD_PADDR_1),

        // ---- dc_outputs_t (dc_outs_o) ----
        .dc_outs_valid                                  (dc_outputs.valid),
        .dc_outs_dc_eip                                 (dc_outputs.dc_eip),
        .dc_outs_stall                                  (dc_outputs.stall),
        .dc_outs_exp_pf                                 (dc_outputs.exp_pf),
        .dc_outs_exp_present                            (dc_outputs.exp_present),
        .dc_outs_ld_addr_0_V                            (dc_outputs.ld_addr_0_V),
        .dc_outs_ld_addr_0                              (dc_outputs.ld_addr_0),
        .dc_outs_ld_addr_1_V                            (dc_outputs.ld_addr_1_V),
        .dc_outs_ld_addr_1                              (dc_outputs.ld_addr_1),
        .dc_outs_ld_addr_MIO_V                          (dc_outputs.ld_addr_MIO_V),
        .dc_outs_ld_addr_MIO                            (dc_outputs.ld_addr_MIO),
        .dc_outs_mem_stage_latch_we                     (dc_outputs.mem_stage_latch_we)
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
