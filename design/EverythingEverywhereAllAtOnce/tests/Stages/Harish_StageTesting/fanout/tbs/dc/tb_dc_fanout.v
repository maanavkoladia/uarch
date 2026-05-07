`timescale 1ns/1ps

module tb_dc_fanout;

    // ----------------------------------------------------------------
    // Clock / reset
    // ----------------------------------------------------------------
    reg clk;
    reg rst;

    // ----------------------------------------------------------------
    // dc_latches_t inputs
    // ----------------------------------------------------------------
    reg        latches_valid;

    // dc_cs_t
    reg        latches_cs_LD_OP;
    reg        latches_cs_ST_OP;
    reg        latches_cs_dr_upper8;
    reg        latches_cs_sr_upper8;
    reg [1:0]  latches_cs_datasize;

    // mem_cs_t
    reg        latches_mem_cs_ST_OP;
    reg        latches_mem_cs_LD_OP;

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

    reg        latches_rr_gp;

    // load-side address / segmentation
    reg [31:0] latches_ld_vaddy;
    reg [31:0] latches_seg0_limit_w_datasize;
    reg [31:0] latches_seg0_limit_wo_datasize;
    reg [31:0] latches_next_ld_vaddy;
    reg [31:0] latches_ld_laddy;
    reg        latches_ld_stack_access;

    // store-side address / segmentation
    reg [31:0] latches_st_vaddy;
    reg [31:0] latches_seg1_limit_w_datasize;
    reg [31:0] latches_seg1_limit_wo_datasize;
    reg [31:0] latches_next_st_vaddy;
    reg [31:0] latches_st_laddy;
    reg        latches_st_stack_access;

    reg [31:0] latches_NEIP;
    reg [31:0] latches_EIP;
    reg [31:0] latches_EAX;
    reg [63:0] latches_imm64;

    reg [4:0]  latches_sr_id;
    reg [63:0] latches_sr_data;
    reg [4:0]  latches_dr_id;
    reg [63:0] latches_dr_data;

    // ----------------------------------------------------------------
    // fetch_outputs_t inputs
    // ----------------------------------------------------------------
    reg        fetch_outs_exp_pipe_clear;

    // ----------------------------------------------------------------
    // mem_outputs_t inputs
    // ----------------------------------------------------------------
    reg        mem_outs_valid;
    reg        mem_outs_stall;
    reg        mem_outs_ST_OP;
    reg        mem_outs_ST_XCL;
    reg [14:0] mem_outs_ST_PADDR_0;
    reg [14:0] mem_outs_ST_PADDR_1;

    // ----------------------------------------------------------------
    // exe_outputs_t inputs
    // ----------------------------------------------------------------
    reg        exe_outs_valid;
    reg        exe_outs_ST_OP;
    reg        exe_outs_ST_XCL;
    reg [14:0] exe_outs_ST_PADDR_0;
    reg [14:0] exe_outs_ST_PADDR_1;
    reg        exe_outs_br_res_flush;

    // ----------------------------------------------------------------
    // wb_outputs_t inputs
    // ----------------------------------------------------------------
    reg        wb_outs_valid;
    reg        wb_outs_wb_stall;
    reg        wb_outs_ST_OP;
    reg        wb_outs_ST_XCL;
    reg [14:0] wb_outs_ST_PADDR_0;
    reg [14:0] wb_outs_ST_PADDR_1;

    // wb dep-check entries (16)
    reg        wb_outs_dep_check_entry_0_valid;
    reg [14:0] wb_outs_dep_check_entry_0_address;
    reg        wb_outs_dep_check_entry_1_valid;
    reg [14:0] wb_outs_dep_check_entry_1_address;
    reg        wb_outs_dep_check_entry_2_valid;
    reg [14:0] wb_outs_dep_check_entry_2_address;
    reg        wb_outs_dep_check_entry_3_valid;
    reg [14:0] wb_outs_dep_check_entry_3_address;
    reg        wb_outs_dep_check_entry_4_valid;
    reg [14:0] wb_outs_dep_check_entry_4_address;
    reg        wb_outs_dep_check_entry_5_valid;
    reg [14:0] wb_outs_dep_check_entry_5_address;
    reg        wb_outs_dep_check_entry_6_valid;
    reg [14:0] wb_outs_dep_check_entry_6_address;
    reg        wb_outs_dep_check_entry_7_valid;
    reg [14:0] wb_outs_dep_check_entry_7_address;
    reg        wb_outs_dep_check_entry_8_valid;
    reg [14:0] wb_outs_dep_check_entry_8_address;
    reg        wb_outs_dep_check_entry_9_valid;
    reg [14:0] wb_outs_dep_check_entry_9_address;
    reg        wb_outs_dep_check_entry_10_valid;
    reg [14:0] wb_outs_dep_check_entry_10_address;
    reg        wb_outs_dep_check_entry_11_valid;
    reg [14:0] wb_outs_dep_check_entry_11_address;
    reg        wb_outs_dep_check_entry_12_valid;
    reg [14:0] wb_outs_dep_check_entry_12_address;
    reg        wb_outs_dep_check_entry_13_valid;
    reg [14:0] wb_outs_dep_check_entry_13_address;
    reg        wb_outs_dep_check_entry_14_valid;
    reg [14:0] wb_outs_dep_check_entry_14_address;
    reg        wb_outs_dep_check_entry_15_valid;
    reg [14:0] wb_outs_dep_check_entry_15_address;

    // ----------------------------------------------------------------
    // dcache request-served handshakes
    // ----------------------------------------------------------------
    reg        req_served_mio;
    reg        req_served_0;
    reg        req_served_1;

    // ----------------------------------------------------------------
    // mem_latches_t outputs
    // ----------------------------------------------------------------
    wire        mem_latches_next_valid;

    wire        mem_latches_next_cs_ST_OP;
    wire        mem_latches_next_cs_LD_OP;

    wire        mem_latches_next_exe_cs_ST_OP;
    wire [5:0]  mem_latches_next_exe_cs_OP_TYPE;
    wire [4:0]  mem_latches_next_exe_cs_alu_inputA_sel;
    wire [4:0]  mem_latches_next_exe_cs_alu_inputB_sel;
    wire [4:0]  mem_latches_next_exe_cs_branch_target_sel;
    wire        mem_latches_next_exe_cs_shift_by_one;
    wire        mem_latches_next_exe_cs_br_ucond;
    wire        mem_latches_next_exe_cs_relative_branch;
    wire        mem_latches_next_exe_cs_special_br;
    wire        mem_latches_next_exe_cs_is_far;
    wire        mem_latches_next_exe_cs_is_call;
    wire        mem_latches_next_exe_cs_second_flag_needed;
    wire        mem_latches_next_exe_cs_rep_no_zf_update;

    wire        mem_latches_next_wb_cs_ST_OP;
    wire        mem_latches_next_wb_cs_WB_DR;
    wire        mem_latches_next_wb_cs_WB_SR;
    wire        mem_latches_next_wb_cs_WB_EAX;

    wire        mem_latches_next_br_info_valid;
    wire [31:0] mem_latches_next_br_info_br_eip;
    wire        mem_latches_next_br_info_br_xcl;
    wire        mem_latches_next_br_info_br_pred_taken;
    wire [31:0] mem_latches_next_br_info_speculative_target;

    wire [3:0]  mem_latches_next_data_size_vec;
    wire [3:0]  mem_latches_next_sr_data_size_vec;
    wire        mem_latches_next_shift_sr_up;
    wire        mem_latches_next_shift_sr_down;

    wire        mem_latches_next_ST_XCL;
    wire [14:0] mem_latches_next_ST_PADDR_0;
    wire [14:0] mem_latches_next_ST_PADDR_1;
    wire        mem_latches_next_MIO;

    wire [31:0] mem_latches_next_NEIP;
    wire [31:0] mem_latches_next_EIP;
    wire [31:0] mem_latches_next_EAX;
    wire [63:0] mem_latches_next_imm64;

    wire [4:0]  mem_latches_next_sr_id;
    wire [63:0] mem_latches_next_sr_data;
    wire [4:0]  mem_latches_next_dr_id;
    wire [63:0] mem_latches_next_dr_data;

    wire        mem_latches_next_LD_XCL;
    wire        mem_latches_next_swapLines;
    wire [14:0] mem_latches_next_LD_PADDR_0;
    wire [14:0] mem_latches_next_LD_PADDR_1;

    // ----------------------------------------------------------------
    // dc_outputs_t outputs
    // ----------------------------------------------------------------
    wire        dc_outs_valid;
    wire [31:0] dc_outs_dc_eip;
    wire        dc_outs_stall;
    wire        dc_outs_exp_pf;
    wire        dc_outs_exp_present;
    wire        dc_outs_ld_addr_0_V;
    wire [14:0] dc_outs_ld_addr_0;
    wire        dc_outs_ld_addr_1_V;
    wire [14:0] dc_outs_ld_addr_1;
    wire        dc_outs_ld_addr_MIO_V;
    wire [14:0] dc_outs_ld_addr_MIO;
    wire        dc_outs_mem_stage_latch_we;

    // ----------------------------------------------------------------
    // DUT instantiation
    // ----------------------------------------------------------------
    DC uut (
        .clk                                        (clk),
        .rst                                        (rst),

        .latches_valid                              (latches_valid),

        .latches_cs_LD_OP                           (latches_cs_LD_OP),
        .latches_cs_ST_OP                           (latches_cs_ST_OP),
        .latches_cs_dr_upper8                       (latches_cs_dr_upper8),
        .latches_cs_sr_upper8                       (latches_cs_sr_upper8),
        .latches_cs_datasize                        (latches_cs_datasize),

        .latches_mem_cs_ST_OP                       (latches_mem_cs_ST_OP),
        .latches_mem_cs_LD_OP                       (latches_mem_cs_LD_OP),

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

        .latches_rr_gp                              (latches_rr_gp),

        .latches_ld_vaddy                           (latches_ld_vaddy),
        .latches_seg0_limit_w_datasize              (latches_seg0_limit_w_datasize),
        .latches_seg0_limit_wo_datasize             (latches_seg0_limit_wo_datasize),
        .latches_next_ld_vaddy                      (latches_next_ld_vaddy),
        .latches_ld_laddy                           (latches_ld_laddy),
        .latches_ld_stack_access                    (latches_ld_stack_access),

        .latches_st_vaddy                           (latches_st_vaddy),
        .latches_seg1_limit_w_datasize              (latches_seg1_limit_w_datasize),
        .latches_seg1_limit_wo_datasize             (latches_seg1_limit_wo_datasize),
        .latches_next_st_vaddy                      (latches_next_st_vaddy),
        .latches_st_laddy                           (latches_st_laddy),
        .latches_st_stack_access                    (latches_st_stack_access),

        .latches_NEIP                               (latches_NEIP),
        .latches_EIP                                (latches_EIP),
        .latches_EAX                                (latches_EAX),
        .latches_imm64                              (latches_imm64),

        .latches_sr_id                              (latches_sr_id),
        .latches_sr_data                            (latches_sr_data),
        .latches_dr_id                              (latches_dr_id),
        .latches_dr_data                            (latches_dr_data),

        .fetch_outs_exp_pipe_clear                  (fetch_outs_exp_pipe_clear),

        .mem_outs_valid                             (mem_outs_valid),
        .mem_outs_stall                             (mem_outs_stall),
        .mem_outs_ST_OP                             (mem_outs_ST_OP),
        .mem_outs_ST_XCL                            (mem_outs_ST_XCL),
        .mem_outs_ST_PADDR_0                        (mem_outs_ST_PADDR_0),
        .mem_outs_ST_PADDR_1                        (mem_outs_ST_PADDR_1),

        .exe_outs_valid                             (exe_outs_valid),
        .exe_outs_ST_OP                             (exe_outs_ST_OP),
        .exe_outs_ST_XCL                            (exe_outs_ST_XCL),
        .exe_outs_ST_PADDR_0                        (exe_outs_ST_PADDR_0),
        .exe_outs_ST_PADDR_1                        (exe_outs_ST_PADDR_1),
        .exe_outs_br_res_flush                      (exe_outs_br_res_flush),

        .wb_outs_valid                              (wb_outs_valid),
        .wb_outs_wb_stall                           (wb_outs_wb_stall),
        .wb_outs_ST_OP                              (wb_outs_ST_OP),
        .wb_outs_ST_XCL                             (wb_outs_ST_XCL),
        .wb_outs_ST_PADDR_0                         (wb_outs_ST_PADDR_0),
        .wb_outs_ST_PADDR_1                         (wb_outs_ST_PADDR_1),

        .wb_outs_dep_check_entry_0_valid            (wb_outs_dep_check_entry_0_valid),
        .wb_outs_dep_check_entry_0_address          (wb_outs_dep_check_entry_0_address),
        .wb_outs_dep_check_entry_1_valid            (wb_outs_dep_check_entry_1_valid),
        .wb_outs_dep_check_entry_1_address          (wb_outs_dep_check_entry_1_address),
        .wb_outs_dep_check_entry_2_valid            (wb_outs_dep_check_entry_2_valid),
        .wb_outs_dep_check_entry_2_address          (wb_outs_dep_check_entry_2_address),
        .wb_outs_dep_check_entry_3_valid            (wb_outs_dep_check_entry_3_valid),
        .wb_outs_dep_check_entry_3_address          (wb_outs_dep_check_entry_3_address),
        .wb_outs_dep_check_entry_4_valid            (wb_outs_dep_check_entry_4_valid),
        .wb_outs_dep_check_entry_4_address          (wb_outs_dep_check_entry_4_address),
        .wb_outs_dep_check_entry_5_valid            (wb_outs_dep_check_entry_5_valid),
        .wb_outs_dep_check_entry_5_address          (wb_outs_dep_check_entry_5_address),
        .wb_outs_dep_check_entry_6_valid            (wb_outs_dep_check_entry_6_valid),
        .wb_outs_dep_check_entry_6_address          (wb_outs_dep_check_entry_6_address),
        .wb_outs_dep_check_entry_7_valid            (wb_outs_dep_check_entry_7_valid),
        .wb_outs_dep_check_entry_7_address          (wb_outs_dep_check_entry_7_address),
        .wb_outs_dep_check_entry_8_valid            (wb_outs_dep_check_entry_8_valid),
        .wb_outs_dep_check_entry_8_address          (wb_outs_dep_check_entry_8_address),
        .wb_outs_dep_check_entry_9_valid            (wb_outs_dep_check_entry_9_valid),
        .wb_outs_dep_check_entry_9_address          (wb_outs_dep_check_entry_9_address),
        .wb_outs_dep_check_entry_10_valid           (wb_outs_dep_check_entry_10_valid),
        .wb_outs_dep_check_entry_10_address         (wb_outs_dep_check_entry_10_address),
        .wb_outs_dep_check_entry_11_valid           (wb_outs_dep_check_entry_11_valid),
        .wb_outs_dep_check_entry_11_address         (wb_outs_dep_check_entry_11_address),
        .wb_outs_dep_check_entry_12_valid           (wb_outs_dep_check_entry_12_valid),
        .wb_outs_dep_check_entry_12_address         (wb_outs_dep_check_entry_12_address),
        .wb_outs_dep_check_entry_13_valid           (wb_outs_dep_check_entry_13_valid),
        .wb_outs_dep_check_entry_13_address         (wb_outs_dep_check_entry_13_address),
        .wb_outs_dep_check_entry_14_valid           (wb_outs_dep_check_entry_14_valid),
        .wb_outs_dep_check_entry_14_address         (wb_outs_dep_check_entry_14_address),
        .wb_outs_dep_check_entry_15_valid           (wb_outs_dep_check_entry_15_valid),
        .wb_outs_dep_check_entry_15_address         (wb_outs_dep_check_entry_15_address),

        .req_served_mio                             (req_served_mio),
        .req_served_0                               (req_served_0),
        .req_served_1                               (req_served_1),

        .mem_latches_next_valid                     (mem_latches_next_valid),
        .mem_latches_next_cs_ST_OP                  (mem_latches_next_cs_ST_OP),
        .mem_latches_next_cs_LD_OP                  (mem_latches_next_cs_LD_OP),
        .mem_latches_next_exe_cs_ST_OP              (mem_latches_next_exe_cs_ST_OP),
        .mem_latches_next_exe_cs_OP_TYPE            (mem_latches_next_exe_cs_OP_TYPE),
        .mem_latches_next_exe_cs_alu_inputA_sel     (mem_latches_next_exe_cs_alu_inputA_sel),
        .mem_latches_next_exe_cs_alu_inputB_sel     (mem_latches_next_exe_cs_alu_inputB_sel),
        .mem_latches_next_exe_cs_branch_target_sel  (mem_latches_next_exe_cs_branch_target_sel),
        .mem_latches_next_exe_cs_shift_by_one       (mem_latches_next_exe_cs_shift_by_one),
        .mem_latches_next_exe_cs_br_ucond           (mem_latches_next_exe_cs_br_ucond),
        .mem_latches_next_exe_cs_relative_branch    (mem_latches_next_exe_cs_relative_branch),
        .mem_latches_next_exe_cs_special_br         (mem_latches_next_exe_cs_special_br),
        .mem_latches_next_exe_cs_is_far             (mem_latches_next_exe_cs_is_far),
        .mem_latches_next_exe_cs_is_call            (mem_latches_next_exe_cs_is_call),
        .mem_latches_next_exe_cs_second_flag_needed (mem_latches_next_exe_cs_second_flag_needed),
        .mem_latches_next_exe_cs_rep_no_zf_update   (mem_latches_next_exe_cs_rep_no_zf_update),
        .mem_latches_next_wb_cs_ST_OP               (mem_latches_next_wb_cs_ST_OP),
        .mem_latches_next_wb_cs_WB_DR               (mem_latches_next_wb_cs_WB_DR),
        .mem_latches_next_wb_cs_WB_SR               (mem_latches_next_wb_cs_WB_SR),
        .mem_latches_next_wb_cs_WB_EAX              (mem_latches_next_wb_cs_WB_EAX),
        .mem_latches_next_br_info_valid             (mem_latches_next_br_info_valid),
        .mem_latches_next_br_info_br_eip            (mem_latches_next_br_info_br_eip),
        .mem_latches_next_br_info_br_xcl            (mem_latches_next_br_info_br_xcl),
        .mem_latches_next_br_info_br_pred_taken     (mem_latches_next_br_info_br_pred_taken),
        .mem_latches_next_br_info_speculative_target(mem_latches_next_br_info_speculative_target),
        .mem_latches_next_data_size_vec             (mem_latches_next_data_size_vec),
        .mem_latches_next_sr_data_size_vec          (mem_latches_next_sr_data_size_vec),
        .mem_latches_next_shift_sr_up               (mem_latches_next_shift_sr_up),
        .mem_latches_next_shift_sr_down             (mem_latches_next_shift_sr_down),
        .mem_latches_next_ST_XCL                    (mem_latches_next_ST_XCL),
        .mem_latches_next_ST_PADDR_0                (mem_latches_next_ST_PADDR_0),
        .mem_latches_next_ST_PADDR_1                (mem_latches_next_ST_PADDR_1),
        .mem_latches_next_MIO                       (mem_latches_next_MIO),
        .mem_latches_next_NEIP                      (mem_latches_next_NEIP),
        .mem_latches_next_EIP                       (mem_latches_next_EIP),
        .mem_latches_next_EAX                       (mem_latches_next_EAX),
        .mem_latches_next_imm64                     (mem_latches_next_imm64),
        .mem_latches_next_sr_id                     (mem_latches_next_sr_id),
        .mem_latches_next_sr_data                   (mem_latches_next_sr_data),
        .mem_latches_next_dr_id                     (mem_latches_next_dr_id),
        .mem_latches_next_dr_data                   (mem_latches_next_dr_data),
        .mem_latches_next_LD_XCL                    (mem_latches_next_LD_XCL),
        .mem_latches_next_swapLines                 (mem_latches_next_swapLines),
        .mem_latches_next_LD_PADDR_0                (mem_latches_next_LD_PADDR_0),
        .mem_latches_next_LD_PADDR_1                (mem_latches_next_LD_PADDR_1),

        .dc_outs_valid                              (dc_outs_valid),
        .dc_outs_dc_eip                             (dc_outs_dc_eip),
        .dc_outs_stall                              (dc_outs_stall),
        .dc_outs_exp_pf                             (dc_outs_exp_pf),
        .dc_outs_exp_present                        (dc_outs_exp_present),
        .dc_outs_ld_addr_0_V                        (dc_outs_ld_addr_0_V),
        .dc_outs_ld_addr_0                          (dc_outs_ld_addr_0),
        .dc_outs_ld_addr_1_V                        (dc_outs_ld_addr_1_V),
        .dc_outs_ld_addr_1                          (dc_outs_ld_addr_1),
        .dc_outs_ld_addr_MIO_V                      (dc_outs_ld_addr_MIO_V),
        .dc_outs_ld_addr_MIO                        (dc_outs_ld_addr_MIO),
        .dc_outs_mem_stage_latch_we                 (dc_outs_mem_stage_latch_we)
    );

endmodule
