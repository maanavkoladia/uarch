`timescale 1ns/1ps

module tb_fanout_MEM;

    // =========================================================================
    // Clock & Reset
    // =========================================================================
    reg clk;
    reg rst;

    initial clk = 0;
    always #5 clk = ~clk;

    // =========================================================================
    // INPUT REGS
    // =========================================================================

    // mem_latches_t (latches_i)
    reg        latches_valid;

    // mem_cs_t
    reg        latches_cs_ST_OP;
    reg        latches_cs_LD_OP;

    // exe_cs_t
    reg        latches_exe_cs_ST_OP;
    reg [5:0]  latches_exe_cs_OP_TYPE;
    reg [4:0]  latches_exe_cs_alu_inputA_sel;
    reg [4:0]  latches_exe_cs_alu_inputB_sel;
    reg [4:0]  latches_exe_cs_branch_target_sel;
    reg        latches_exe_cs_shift_by_one;
    reg        latches_exe_cs_br_ucond;
    reg        latches_exe_cs_relative_branch;
    reg        latches_exe_cs_special_br;
    reg        latches_exe_cs_is_far;
    reg        latches_exe_cs_is_call;
    reg        latches_exe_cs_second_flag_needed;
    reg        latches_exe_cs_rep_no_zf_update;

    // wb_cs_t
    reg        latches_wb_cs_ST_OP;
    reg        latches_wb_cs_WB_DR;
    reg        latches_wb_cs_WB_SR;
    reg        latches_wb_cs_WB_EAX;

    // br_info_t
    reg        latches_br_info_valid;
    reg [31:0] latches_br_info_br_eip;
    reg        latches_br_info_br_xcl;
    reg        latches_br_info_br_pred_taken;
    reg [31:0] latches_br_info_speculative_target;

    reg [3:0]  latches_data_size_vec;
    reg [3:0]  latches_sr_data_size_vec;
    reg        latches_shift_sr_up;
    reg        latches_shift_sr_down;

    reg        latches_ST_XCL;
    reg [14:0] latches_ST_PADDR_0;
    reg [14:0] latches_ST_PADDR_1;
    reg        latches_MIO;

    reg [31:0] latches_NEIP;
    reg [31:0] latches_EIP;
    reg [31:0] latches_EAX;
    reg [63:0] latches_imm64;

    reg [4:0]  latches_sr_id;
    reg [63:0] latches_sr_data;
    reg [4:0]  latches_dr_id;
    reg [63:0] latches_dr_data;

    reg        latches_LD_XCL;
    reg        latches_swapLines;
    reg [14:0] latches_LD_PADDR_0;
    reg [14:0] latches_LD_PADDR_1;

    // exe_outputs_t (exe_outs_i)
    reg        exe_outs_valid;
    reg        exe_outs_br_res_flush;

    // wb_outputs_t (wb_outs_i)
    reg        wb_outs_wb_stall;

    // dcache-side inputs
    reg        hit_0;
    reg        hit_1;
    reg        hit_2;
    reg        hit_3;
    reg [127:0] cacheline_0;
    reg [127:0] cacheline_1;
    reg [127:0] cacheline_2;
    reg [127:0] cacheline_3;

    reg        hit_MIO;
    reg [127:0] line_MIO;

    // =========================================================================
    // OUTPUT WIRES
    // =========================================================================

    // exe_latches_next_o
    wire        exe_latches_next_valid;

    // exe_cs_t
    wire        exe_latches_next_cs_ST_OP;
    wire [5:0]  exe_latches_next_cs_OP_TYPE;
    wire [4:0]  exe_latches_next_cs_alu_inputA_sel;
    wire [4:0]  exe_latches_next_cs_alu_inputB_sel;
    wire [4:0]  exe_latches_next_cs_branch_target_sel;
    wire        exe_latches_next_cs_shift_by_one;
    wire        exe_latches_next_cs_br_ucond;
    wire        exe_latches_next_cs_relative_branch;
    wire        exe_latches_next_cs_special_br;
    wire        exe_latches_next_cs_is_far;
    wire        exe_latches_next_cs_is_call;
    wire        exe_latches_next_cs_second_flag_needed;
    wire        exe_latches_next_cs_rep_no_zf_update;

    // wb_cs_t
    wire        exe_latches_next_wb_cs_ST_OP;
    wire        exe_latches_next_wb_cs_WB_DR;
    wire        exe_latches_next_wb_cs_WB_SR;
    wire        exe_latches_next_wb_cs_WB_EAX;

    wire [3:0]  exe_latches_next_data_size_vec;
    wire [3:0]  exe_latches_next_sr_data_size_vec;
    wire        exe_latches_next_shift_sr_up;
    wire        exe_latches_next_shift_sr_down;

    wire        exe_latches_next_ST_XCL;
    wire [14:0] exe_latches_next_ST_PADDR_0;
    wire [14:0] exe_latches_next_ST_PADDR_1;
    wire        exe_latches_next_MIO;

    // br_info_t
    wire        exe_latches_next_br_info_valid;
    wire [31:0] exe_latches_next_br_info_br_eip;
    wire        exe_latches_next_br_info_br_xcl;
    wire        exe_latches_next_br_info_br_pred_taken;
    wire [31:0] exe_latches_next_br_info_speculative_target;

    wire [31:0] exe_latches_next_br_rel_target;

    wire [31:0] exe_latches_next_NEIP;
    wire [31:0] exe_latches_next_EIP;
    wire [31:0] exe_latches_next_EAX;
    wire [63:0] exe_latches_next_imm64;

    wire [255:0] exe_latches_next_ld_buf;

    wire [4:0]  exe_latches_next_sr_id;
    wire [63:0] exe_latches_next_sr_data;
    wire [4:0]  exe_latches_next_dr_id;
    wire [63:0] exe_latches_next_dr_data;

    wire [14:0] exe_latches_next_ld_addy;

    // mem_outputs_t (outs_o)
    wire        outs_valid;
    wire        outs_stall;
    wire        outs_ST_XCL;
    wire [14:0] outs_ST_PADDR_0;
    wire [14:0] outs_ST_PADDR_1;
    wire        outs_ST_OP;
    wire        outs_exe_stage_latch_we;

    wire        outs_clr_dcache_arb_latches_0;
    wire        outs_clr_dcache_arb_latches_1;
    wire        outs_clr_dcache_arb_latches_2;
    wire        outs_clr_dcache_arb_latches_3;

    wire        outs_clr_dcache_mio_latch;

    // =========================================================================
    // DUT INSTANTIATION
    // =========================================================================
    MEM dut (
        .clk                                        (clk),
        .rst                                        (rst),

        // latches_i
        .latches_valid                              (latches_valid),

        .latches_cs_ST_OP                           (latches_cs_ST_OP),
        .latches_cs_LD_OP                           (latches_cs_LD_OP),

        .latches_exe_cs_ST_OP                       (latches_exe_cs_ST_OP),
        .latches_exe_cs_OP_TYPE                     (latches_exe_cs_OP_TYPE),
        .latches_exe_cs_alu_inputA_sel              (latches_exe_cs_alu_inputA_sel),
        .latches_exe_cs_alu_inputB_sel              (latches_exe_cs_alu_inputB_sel),
        .latches_exe_cs_branch_target_sel           (latches_exe_cs_branch_target_sel),
        .latches_exe_cs_shift_by_one                (latches_exe_cs_shift_by_one),
        .latches_exe_cs_br_ucond                    (latches_exe_cs_br_ucond),
        .latches_exe_cs_relative_branch             (latches_exe_cs_relative_branch),
        .latches_exe_cs_special_br                  (latches_exe_cs_special_br),
        .latches_exe_cs_is_far                      (latches_exe_cs_is_far),
        .latches_exe_cs_is_call                     (latches_exe_cs_is_call),
        .latches_exe_cs_second_flag_needed          (latches_exe_cs_second_flag_needed),
        .latches_exe_cs_rep_no_zf_update            (latches_exe_cs_rep_no_zf_update),

        .latches_wb_cs_ST_OP                        (latches_wb_cs_ST_OP),
        .latches_wb_cs_WB_DR                        (latches_wb_cs_WB_DR),
        .latches_wb_cs_WB_SR                        (latches_wb_cs_WB_SR),
        .latches_wb_cs_WB_EAX                       (latches_wb_cs_WB_EAX),

        .latches_br_info_valid                      (latches_br_info_valid),
        .latches_br_info_br_eip                     (latches_br_info_br_eip),
        .latches_br_info_br_xcl                     (latches_br_info_br_xcl),
        .latches_br_info_br_pred_taken              (latches_br_info_br_pred_taken),
        .latches_br_info_speculative_target         (latches_br_info_speculative_target),

        .latches_data_size_vec                      (latches_data_size_vec),
        .latches_sr_data_size_vec                   (latches_sr_data_size_vec),
        .latches_shift_sr_up                        (latches_shift_sr_up),
        .latches_shift_sr_down                      (latches_shift_sr_down),

        .latches_ST_XCL                             (latches_ST_XCL),
        .latches_ST_PADDR_0                         (latches_ST_PADDR_0),
        .latches_ST_PADDR_1                         (latches_ST_PADDR_1),
        .latches_MIO                                (latches_MIO),

        .latches_NEIP                               (latches_NEIP),
        .latches_EIP                                (latches_EIP),
        .latches_EAX                                (latches_EAX),
        .latches_imm64                              (latches_imm64),

        .latches_sr_id                              (latches_sr_id),
        .latches_sr_data                            (latches_sr_data),
        .latches_dr_id                              (latches_dr_id),
        .latches_dr_data                            (latches_dr_data),

        .latches_LD_XCL                             (latches_LD_XCL),
        .latches_swapLines                          (latches_swapLines),
        .latches_LD_PADDR_0                         (latches_LD_PADDR_0),
        .latches_LD_PADDR_1                         (latches_LD_PADDR_1),

        // exe_outs_i
        .exe_outs_valid                             (exe_outs_valid),
        .exe_outs_br_res_flush                      (exe_outs_br_res_flush),

        // wb_outs_i
        .wb_outs_wb_stall                           (wb_outs_wb_stall),

        // dcache inputs
        .hit_0                                      (hit_0),
        .hit_1                                      (hit_1),
        .hit_2                                      (hit_2),
        .hit_3                                      (hit_3),
        .cacheline_0                                (cacheline_0),
        .cacheline_1                                (cacheline_1),
        .cacheline_2                                (cacheline_2),
        .cacheline_3                                (cacheline_3),

        .hit_MIO                                    (hit_MIO),
        .line_MIO                                   (line_MIO),

        // exe_latches_next_o
        .exe_latches_next_valid                     (exe_latches_next_valid),

        .exe_latches_next_cs_ST_OP                  (exe_latches_next_cs_ST_OP),
        .exe_latches_next_cs_OP_TYPE                (exe_latches_next_cs_OP_TYPE),
        .exe_latches_next_cs_alu_inputA_sel         (exe_latches_next_cs_alu_inputA_sel),
        .exe_latches_next_cs_alu_inputB_sel         (exe_latches_next_cs_alu_inputB_sel),
        .exe_latches_next_cs_branch_target_sel      (exe_latches_next_cs_branch_target_sel),
        .exe_latches_next_cs_shift_by_one           (exe_latches_next_cs_shift_by_one),
        .exe_latches_next_cs_br_ucond               (exe_latches_next_cs_br_ucond),
        .exe_latches_next_cs_relative_branch        (exe_latches_next_cs_relative_branch),
        .exe_latches_next_cs_special_br             (exe_latches_next_cs_special_br),
        .exe_latches_next_cs_is_far                 (exe_latches_next_cs_is_far),
        .exe_latches_next_cs_is_call                (exe_latches_next_cs_is_call),
        .exe_latches_next_cs_second_flag_needed     (exe_latches_next_cs_second_flag_needed),
        .exe_latches_next_cs_rep_no_zf_update       (exe_latches_next_cs_rep_no_zf_update),

        .exe_latches_next_wb_cs_ST_OP               (exe_latches_next_wb_cs_ST_OP),
        .exe_latches_next_wb_cs_WB_DR               (exe_latches_next_wb_cs_WB_DR),
        .exe_latches_next_wb_cs_WB_SR               (exe_latches_next_wb_cs_WB_SR),
        .exe_latches_next_wb_cs_WB_EAX              (exe_latches_next_wb_cs_WB_EAX),

        .exe_latches_next_data_size_vec             (exe_latches_next_data_size_vec),
        .exe_latches_next_sr_data_size_vec          (exe_latches_next_sr_data_size_vec),
        .exe_latches_next_shift_sr_up               (exe_latches_next_shift_sr_up),
        .exe_latches_next_shift_sr_down             (exe_latches_next_shift_sr_down),

        .exe_latches_next_ST_XCL                    (exe_latches_next_ST_XCL),
        .exe_latches_next_ST_PADDR_0                (exe_latches_next_ST_PADDR_0),
        .exe_latches_next_ST_PADDR_1                (exe_latches_next_ST_PADDR_1),
        .exe_latches_next_MIO                       (exe_latches_next_MIO),

        .exe_latches_next_br_info_valid             (exe_latches_next_br_info_valid),
        .exe_latches_next_br_info_br_eip            (exe_latches_next_br_info_br_eip),
        .exe_latches_next_br_info_br_xcl            (exe_latches_next_br_info_br_xcl),
        .exe_latches_next_br_info_br_pred_taken     (exe_latches_next_br_info_br_pred_taken),
        .exe_latches_next_br_info_speculative_target(exe_latches_next_br_info_speculative_target),

        .exe_latches_next_br_rel_target             (exe_latches_next_br_rel_target),

        .exe_latches_next_NEIP                      (exe_latches_next_NEIP),
        .exe_latches_next_EIP                       (exe_latches_next_EIP),
        .exe_latches_next_EAX                       (exe_latches_next_EAX),
        .exe_latches_next_imm64                     (exe_latches_next_imm64),

        .exe_latches_next_ld_buf                    (exe_latches_next_ld_buf),

        .exe_latches_next_sr_id                     (exe_latches_next_sr_id),
        .exe_latches_next_sr_data                   (exe_latches_next_sr_data),
        .exe_latches_next_dr_id                     (exe_latches_next_dr_id),
        .exe_latches_next_dr_data                   (exe_latches_next_dr_data),

        .exe_latches_next_ld_addy                   (exe_latches_next_ld_addy),

        // outs_o
        .outs_valid                                 (outs_valid),
        .outs_stall                                 (outs_stall),
        .outs_ST_XCL                                (outs_ST_XCL),
        .outs_ST_PADDR_0                            (outs_ST_PADDR_0),
        .outs_ST_PADDR_1                            (outs_ST_PADDR_1),
        .outs_ST_OP                                 (outs_ST_OP),
        .outs_exe_stage_latch_we                    (outs_exe_stage_latch_we),

        .outs_clr_dcache_arb_latches_0              (outs_clr_dcache_arb_latches_0),
        .outs_clr_dcache_arb_latches_1              (outs_clr_dcache_arb_latches_1),
        .outs_clr_dcache_arb_latches_2              (outs_clr_dcache_arb_latches_2),
        .outs_clr_dcache_arb_latches_3              (outs_clr_dcache_arb_latches_3),

        .outs_clr_dcache_mio_latch                  (outs_clr_dcache_mio_latch)
    );

    // =========================================================================
    // STIMULUS
    // =========================================================================
    initial begin
        // zero all inputs
        rst                                  = 1;
        latches_valid                        = 0;
        latches_cs_ST_OP                     = 0;
        latches_cs_LD_OP                     = 0;
        latches_exe_cs_ST_OP                 = 0;
        latches_exe_cs_OP_TYPE               = 0;
        latches_exe_cs_alu_inputA_sel        = 0;
        latches_exe_cs_alu_inputB_sel        = 0;
        latches_exe_cs_branch_target_sel     = 0;
        latches_exe_cs_shift_by_one          = 0;
        latches_exe_cs_br_ucond              = 0;
        latches_exe_cs_relative_branch       = 0;
        latches_exe_cs_special_br            = 0;
        latches_exe_cs_is_far                = 0;
        latches_exe_cs_is_call               = 0;
        latches_exe_cs_second_flag_needed    = 0;
        latches_exe_cs_rep_no_zf_update      = 0;
        latches_wb_cs_ST_OP                  = 0;
        latches_wb_cs_WB_DR                  = 0;
        latches_wb_cs_WB_SR                  = 0;
        latches_wb_cs_WB_EAX                 = 0;
        latches_br_info_valid                = 0;
        latches_br_info_br_eip               = 0;
        latches_br_info_br_xcl               = 0;
        latches_br_info_br_pred_taken        = 0;
        latches_br_info_speculative_target   = 0;
        latches_data_size_vec                = 0;
        latches_sr_data_size_vec             = 0;
        latches_shift_sr_up                  = 0;
        latches_shift_sr_down                = 0;
        latches_ST_XCL                       = 0;
        latches_ST_PADDR_0                   = 0;
        latches_ST_PADDR_1                   = 0;
        latches_MIO                          = 0;
        latches_NEIP                         = 0;
        latches_EIP                          = 0;
        latches_EAX                          = 0;
        latches_imm64                        = 0;
        latches_sr_id                        = 0;
        latches_sr_data                      = 0;
        latches_dr_id                        = 0;
        latches_dr_data                      = 0;
        latches_LD_XCL                       = 0;
        latches_swapLines                    = 0;
        latches_LD_PADDR_0                   = 0;
        latches_LD_PADDR_1                   = 0;
        exe_outs_valid                       = 0;
        exe_outs_br_res_flush                = 0;
        wb_outs_wb_stall                     = 0;
        hit_0                                = 0;
        hit_1                                = 0;
        hit_2                                = 0;
        hit_3                                = 0;
        cacheline_0                          = 0;
        cacheline_1                          = 0;
        cacheline_2                          = 0;
        cacheline_3                          = 0;
        hit_MIO                              = 0;
        line_MIO                             = 0;

        @(posedge clk); #1;
        rst = 0;

        $finish;
    end

endmodule
