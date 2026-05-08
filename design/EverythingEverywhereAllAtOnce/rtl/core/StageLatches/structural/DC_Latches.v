// =============================================================================
// DC_Latches  (pure Verilog-2005 structural stage latch)
//
//   Reference SV struct (kept for documentation):
//     typedef struct {
//         bool valid;
//         l_address_t br_eip;
//         bool br_xcl;
//         bool br_pred_taken;
//         l_address_t speculative_target;
//     } br_info_t;
//
//     typedef struct {
//         bool LD_OP;
//         bool ST_OP;
//         bool dr_upper8;
//         bool sr_upper8;
//         logic [1:0] datasize;
//     } dc_cs_t;
//
//     typedef struct {
//         bool ST_OP;
//         bool LD_OP;
//     } mem_cs_t;
//
//     typedef struct {
//         bool ST_OP;
//         exe_cs_operation_type_e OP_TYPE;
//         source_selector_e alu_inputA_sel;
//         source_selector_e alu_inputB_sel;
//         source_selector_e branch_target_sel;
//         bool shift_by_one;
//         bool br_ucond;
//         bool relative_branch;
//         bool special_br;
//         bool is_far;
//         bool is_call;
//         bool second_flag_needed;
//         bool rep_no_zf_update;
//     } exe_cs_t;
//
//     typedef struct {
//         bool ST_OP;
//         bool WB_DR;
//         bool WB_SR;
//         bool WB_EAX;
//     } wb_cs_t;
//
//     typedef struct {
//         bool valid;
//         dc_cs_t cs;
//         mem_cs_t mem_cs;
//         exe_cs_t exe_cs;
//         wb_cs_t wb_cs;
//         br_info_t br_info;
//         bool rr_gp;
//         v_address_t ld_vaddy;
//         uint32_t seg0_limit_w_datasize;
//         uint32_t seg0_limit_wo_datasize;
//         v_address_t next_ld_vaddy;
//         uint32_t ld_laddy;
//         bool ld_stack_access;
//         v_address_t st_vaddy;
//         uint32_t seg1_limit_w_datasize;
//         uint32_t seg1_limit_wo_datasize;
//         v_address_t next_st_vaddy;
//         uint32_t st_laddy;
//         bool st_stack_access;
//         l_address_t NEIP;
//         l_address_t EIP;
//         uint32_t EAX;
//         uint64_t imm64;
//         reg_ids_e sr_id;
//         uint64_t  sr_data;
//         reg_ids_e dr_id;
//         uint64_t  dr_data;
//     } dc_latches_t;
//
//   Flush behavior:
//     - !rst                           -> latches <= 0  (REG_RST_WE async reset)
//     - flush || exp_pipe_clear        -> latches <= 0  (regardless of write_enable_i)
//     - write_enable_i && !any_flush   -> latches <= nextLatches
//     - !write_enable_i && !any_flush  -> hold
//     Implementation:
//       combined_flush = flush OR exp_pipe_clear
//       effective_we   = write_enable_i OR combined_flush
//       per-field MUX_2 selects (combined_flush ? 0 : nextLatches), output
//       feeds REG_RST_WE.d, with we = effective_we.
//
//     NOTE: farFlush is a legacy port kept for interface compatibility but
//     is NOT used in the clear logic (matches the updated RR/MEM behavior).
//
//   - SV `import` removed; no struct/typedef/enum used.
//   - Every field is its own scalar/vector port (`.field` -> `_field`).
// =============================================================================

module DC_Latches (
    input wire clk,
    input wire rst,
    input wire write_enable_i,
    input wire flush,
    input wire farFlush,        // legacy, unused in clear logic
    input wire exp_pipe_clear,

    // ----- nextLatches_i (unrolled) -----
    input wire        nextLatches_valid_i,

    // dc_cs_t cs
    input wire        nextLatches_cs_LD_OP_i,
    input wire        nextLatches_cs_ST_OP_i,
    input wire        nextLatches_cs_dr_upper8_i,
    input wire        nextLatches_cs_sr_upper8_i,
    input wire [1:0]  nextLatches_cs_datasize_i,

    // mem_cs_t mem_cs
    input wire        nextLatches_mem_cs_ST_OP_i,
    input wire        nextLatches_mem_cs_LD_OP_i,

    // exe_cs_t exe_cs
    input wire        nextLatches_exe_cs_ST_OP_i,
    input wire [5:0]  nextLatches_exe_cs_OP_TYPE_i,
    input wire [4:0]  nextLatches_exe_cs_alu_inputA_sel_i,
    input wire [4:0]  nextLatches_exe_cs_alu_inputB_sel_i,
    input wire [4:0]  nextLatches_exe_cs_branch_target_sel_i,
    input wire        nextLatches_exe_cs_shift_by_one_i,
    input wire        nextLatches_exe_cs_br_ucond_i,
    input wire        nextLatches_exe_cs_relative_branch_i,
    input wire        nextLatches_exe_cs_special_br_i,
    input wire        nextLatches_exe_cs_is_far_i,
    input wire        nextLatches_exe_cs_is_call_i,
    input wire        nextLatches_exe_cs_second_flag_needed_i,
    input wire        nextLatches_exe_cs_rep_no_zf_update_i,

    // wb_cs_t wb_cs
    input wire        nextLatches_wb_cs_ST_OP_i,
    input wire        nextLatches_wb_cs_WB_DR_i,
    input wire        nextLatches_wb_cs_WB_SR_i,
    input wire        nextLatches_wb_cs_WB_EAX_i,

    // br_info_t br_info
    input wire        nextLatches_br_info_valid_i,
    input wire [31:0] nextLatches_br_info_br_eip_i,
    input wire        nextLatches_br_info_br_xcl_i,
    input wire        nextLatches_br_info_br_pred_taken_i,
    input wire [31:0] nextLatches_br_info_speculative_target_i,

    input wire        nextLatches_rr_gp_i,

    input wire [31:0] nextLatches_ld_vaddy_i,
    input wire [31:0] nextLatches_seg0_limit_w_datasize_i,
    input wire [31:0] nextLatches_seg0_limit_wo_datasize_i,
    input wire [31:0] nextLatches_next_ld_vaddy_i,
    input wire [31:0] nextLatches_ld_laddy_i,
    input wire        nextLatches_ld_stack_access_i,

    input wire [31:0] nextLatches_st_vaddy_i,
    input wire [31:0] nextLatches_seg1_limit_w_datasize_i,
    input wire [31:0] nextLatches_seg1_limit_wo_datasize_i,
    input wire [31:0] nextLatches_next_st_vaddy_i,
    input wire [31:0] nextLatches_st_laddy_i,
    input wire        nextLatches_st_stack_access_i,

    input wire [31:0] nextLatches_NEIP_i,
    input wire [31:0] nextLatches_EIP_i,
    input wire [31:0] nextLatches_EAX_i,

    input wire [63:0] nextLatches_imm64_i,

    input wire [4:0]  nextLatches_sr_id_i,
    input wire [63:0] nextLatches_sr_data_i,
    input wire [4:0]  nextLatches_dr_id_i,
    input wire [63:0] nextLatches_dr_data_i,

    // ----- duplicated copies for fanout reduction (CP control signals) -----
    // Each copy is an independent REG_RST_WE driven by the same nextLatches
    // data, but produces its own Q so DC can route disjoint subsets of
    // consumers per copy. Zero added CP delay (flop CLK->Q unchanged).

    // cs_datasize x3 (Fix E)
    //   _0 -> ld_neuralnet_part2 (CP)
    //   _1 -> st_neuralnet_part2 (CP)
    //   _2 -> push_addr_gen + data_vec_uint via bufferH16$ in DC (off-CP)
    input wire [1:0]  nextLatches_cs_datasize_0_i,
    input wire [1:0]  nextLatches_cs_datasize_1_i,
    input wire [1:0]  nextLatches_cs_datasize_2_i,

    // cs_LD_OP x4 (Fix G)
    //   _0 -> in_flight_dep_check + stq_dep_check (CP)
    //   _1 -> req_gen (CP)
    //   _2 -> ld_neuralnet_part2.mem_op (CP)
    //   _3 -> data_vec_uint + u_ld_exception via bufferH16$ in DC (off-CP)
    input wire        nextLatches_cs_LD_OP_0_i,
    input wire        nextLatches_cs_LD_OP_1_i,
    input wire        nextLatches_cs_LD_OP_2_i,
    input wire        nextLatches_cs_LD_OP_3_i,

    // cs_ST_OP x1 dedicated copy (Fix F addendum): st_neuralnet_part2's
    // write_intent + mem_op carry ~17 flattened internal loads through the
    // two TLBs. Even though st_npu is off the dep-check/TLB/req_gen CP, it
    // dominates cs_ST_OP's flattened fanout, so a dedicated latch copy
    // isolates that load from the off-CP buffered consumers.
    input wire        nextLatches_cs_ST_OP_0_i,

    // valid x3 (Fix H)
    //   _0 -> in_flight_dep_check + stq_dep_check (CP)
    //   _1 -> req_gen (CP)
    //   _2 -> u_exp_stall + dc_outs_valid output assign (off-CP)
    input wire        nextLatches_valid_0_i,
    input wire        nextLatches_valid_1_i,
    input wire        nextLatches_valid_2_i,

    // ----- latches_o (unrolled) -----
    output wire        latches_valid_o,

    output wire        latches_cs_LD_OP_o,
    output wire        latches_cs_ST_OP_o,
    output wire        latches_cs_dr_upper8_o,
    output wire        latches_cs_sr_upper8_o,
    output wire [1:0]  latches_cs_datasize_o,

    output wire        latches_mem_cs_ST_OP_o,
    output wire        latches_mem_cs_LD_OP_o,

    output wire        latches_exe_cs_ST_OP_o,
    output wire [5:0]  latches_exe_cs_OP_TYPE_o,
    output wire [4:0]  latches_exe_cs_alu_inputA_sel_o,
    output wire [4:0]  latches_exe_cs_alu_inputB_sel_o,
    output wire [4:0]  latches_exe_cs_branch_target_sel_o,
    output wire        latches_exe_cs_shift_by_one_o,
    output wire        latches_exe_cs_br_ucond_o,
    output wire        latches_exe_cs_relative_branch_o,
    output wire        latches_exe_cs_special_br_o,
    output wire        latches_exe_cs_is_far_o,
    output wire        latches_exe_cs_is_call_o,
    output wire        latches_exe_cs_second_flag_needed_o,
    output wire        latches_exe_cs_rep_no_zf_update_o,

    output wire        latches_wb_cs_ST_OP_o,
    output wire        latches_wb_cs_WB_DR_o,
    output wire        latches_wb_cs_WB_SR_o,
    output wire        latches_wb_cs_WB_EAX_o,

    output wire        latches_br_info_valid_o,
    output wire [31:0] latches_br_info_br_eip_o,
    output wire        latches_br_info_br_xcl_o,
    output wire        latches_br_info_br_pred_taken_o,
    output wire [31:0] latches_br_info_speculative_target_o,

    output wire        latches_rr_gp_o,

    output wire [31:0] latches_ld_vaddy_o,
    output wire [31:0] latches_seg0_limit_w_datasize_o,
    output wire [31:0] latches_seg0_limit_wo_datasize_o,
    output wire [31:0] latches_next_ld_vaddy_o,
    output wire [31:0] latches_ld_laddy_o,
    output wire        latches_ld_stack_access_o,

    output wire [31:0] latches_st_vaddy_o,
    output wire [31:0] latches_seg1_limit_w_datasize_o,
    output wire [31:0] latches_seg1_limit_wo_datasize_o,
    output wire [31:0] latches_next_st_vaddy_o,
    output wire [31:0] latches_st_laddy_o,
    output wire        latches_st_stack_access_o,

    output wire [31:0] latches_NEIP_o,
    output wire [31:0] latches_EIP_o,
    output wire [31:0] latches_EAX_o,

    output wire [63:0] latches_imm64_o,

    output wire [4:0]  latches_sr_id_o,
    output wire [63:0] latches_sr_data_o,
    output wire [4:0]  latches_dr_id_o,
    output wire [63:0] latches_dr_data_o,

    // ----- duplicated outputs (paired with the duplicated inputs above) -----
    output wire [1:0]  latches_cs_datasize_0_o,
    output wire [1:0]  latches_cs_datasize_1_o,
    output wire [1:0]  latches_cs_datasize_2_o,

    output wire        latches_cs_LD_OP_0_o,
    output wire        latches_cs_LD_OP_1_o,
    output wire        latches_cs_LD_OP_2_o,
    output wire        latches_cs_LD_OP_3_o,

    output wire        latches_cs_ST_OP_0_o,

    output wire        latches_valid_0_o,
    output wire        latches_valid_1_o,
    output wire        latches_valid_2_o
);

    // ============================================================
    // Combined flush + effective WE
    //   combined_flush = flush  OR exp_pipe_clear  (farFlush is legacy/unused)
    //   effective_we   = write_enable_i OR combined_flush
    // ============================================================

    wire combined_flush;
    wire effective_we;
    // fanout: staging wires for combined_flush (16) and effective_we (62)
    wire combined_flush_pre_buf;
    wire effective_we_pre_buf;

    `OR_2(u_dc_combined_flush, 1, combined_flush_pre_buf, flush,           exp_pipe_clear);
    `OR_2(u_dc_effective_we,   1, effective_we_pre_buf,   write_enable_i,  combined_flush);

    // fanout: attach buffers on OR_2 outputs
    bufferH16$ u_attach_combined_flush (.out(combined_flush), .in(combined_flush_pre_buf));
    bufferH64$ u_attach_effective_we   (.out(effective_we),   .in(effective_we_pre_buf));

    // ============================================================
    // Flush-gated data wires (input to each REG_RST_WE)
    //   <field>_d = (combined_flush) ? 0 : nextLatches_<field>_i
    // ============================================================

    wire        valid_d;

    wire        cs_LD_OP_d;
    wire        cs_ST_OP_d;
    wire        cs_dr_upper8_d;
    wire        cs_sr_upper8_d;
    wire [1:0]  cs_datasize_d;

    wire        mem_cs_ST_OP_d;
    wire        mem_cs_LD_OP_d;

    wire        exe_cs_ST_OP_d;
    wire [5:0]  exe_cs_OP_TYPE_d;
    wire [4:0]  exe_cs_alu_inputA_sel_d;
    wire [4:0]  exe_cs_alu_inputB_sel_d;
    wire [4:0]  exe_cs_branch_target_sel_d;
    wire        exe_cs_shift_by_one_d;
    wire        exe_cs_br_ucond_d;
    wire        exe_cs_relative_branch_d;
    wire        exe_cs_special_br_d;
    wire        exe_cs_is_far_d;
    wire        exe_cs_is_call_d;
    wire        exe_cs_second_flag_needed_d;
    wire        exe_cs_rep_no_zf_update_d;

    wire        wb_cs_ST_OP_d;
    wire        wb_cs_WB_DR_d;
    wire        wb_cs_WB_SR_d;
    wire        wb_cs_WB_EAX_d;

    wire        br_info_valid_d;
    wire [31:0] br_info_br_eip_d;
    wire        br_info_br_xcl_d;
    wire        br_info_br_pred_taken_d;
    wire [31:0] br_info_speculative_target_d;

    wire        rr_gp_d;

    wire [31:0] ld_vaddy_d;
    wire [31:0] seg0_limit_w_datasize_d;
    wire [31:0] seg0_limit_wo_datasize_d;
    wire [31:0] next_ld_vaddy_d;
    wire [31:0] ld_laddy_d;
    wire        ld_stack_access_d;

    wire [31:0] st_vaddy_d;
    wire [31:0] seg1_limit_w_datasize_d;
    wire [31:0] seg1_limit_wo_datasize_d;
    wire [31:0] next_st_vaddy_d;
    wire [31:0] st_laddy_d;
    wire        st_stack_access_d;

    wire [31:0] NEIP_d;
    wire [31:0] EIP_d;
    wire [31:0] EAX_d;

    wire [63:0] imm64_d;

    wire [4:0]  sr_id_d;
    wire [63:0] sr_data_d;
    wire [4:0]  dr_id_d;
    wire [63:0] dr_data_d;

    // -------- flush MUX per field (in1 = 0, sel = combined_flush) --------

    `MUX_2(u_dc_mux_valid,                          1,   valid_d,                          nextLatches_valid_i,                          1'b0,    combined_flush);

    assign cs_LD_OP_d = nextLatches_cs_LD_OP_i;
    assign cs_ST_OP_d = nextLatches_cs_ST_OP_i;
    assign cs_dr_upper8_d = nextLatches_cs_dr_upper8_i;
    assign cs_sr_upper8_d = nextLatches_cs_sr_upper8_i;
    assign cs_datasize_d = nextLatches_cs_datasize_i;
    assign mem_cs_ST_OP_d = nextLatches_mem_cs_ST_OP_i;
    assign mem_cs_LD_OP_d = nextLatches_mem_cs_LD_OP_i;
    assign exe_cs_ST_OP_d = nextLatches_exe_cs_ST_OP_i;
    assign exe_cs_OP_TYPE_d = nextLatches_exe_cs_OP_TYPE_i;
    assign exe_cs_alu_inputA_sel_d = nextLatches_exe_cs_alu_inputA_sel_i;
    assign exe_cs_alu_inputB_sel_d = nextLatches_exe_cs_alu_inputB_sel_i;
    assign exe_cs_branch_target_sel_d = nextLatches_exe_cs_branch_target_sel_i;
    assign exe_cs_shift_by_one_d = nextLatches_exe_cs_shift_by_one_i;
    assign exe_cs_br_ucond_d = nextLatches_exe_cs_br_ucond_i;
    assign exe_cs_relative_branch_d = nextLatches_exe_cs_relative_branch_i;
    assign exe_cs_special_br_d = nextLatches_exe_cs_special_br_i;
    assign exe_cs_is_far_d = nextLatches_exe_cs_is_far_i;
    assign exe_cs_is_call_d = nextLatches_exe_cs_is_call_i;
    assign exe_cs_second_flag_needed_d = nextLatches_exe_cs_second_flag_needed_i;
    assign exe_cs_rep_no_zf_update_d = nextLatches_exe_cs_rep_no_zf_update_i;
    assign wb_cs_ST_OP_d = nextLatches_wb_cs_ST_OP_i;
    assign wb_cs_WB_DR_d = nextLatches_wb_cs_WB_DR_i;
    assign wb_cs_WB_SR_d = nextLatches_wb_cs_WB_SR_i;
    assign wb_cs_WB_EAX_d = nextLatches_wb_cs_WB_EAX_i;
    assign br_info_valid_d = nextLatches_br_info_valid_i;
    assign br_info_br_eip_d = nextLatches_br_info_br_eip_i;
    assign br_info_br_xcl_d = nextLatches_br_info_br_xcl_i;
    assign br_info_br_pred_taken_d = nextLatches_br_info_br_pred_taken_i;
    assign br_info_speculative_target_d = nextLatches_br_info_speculative_target_i;
    assign rr_gp_d = nextLatches_rr_gp_i;
    assign ld_vaddy_d = nextLatches_ld_vaddy_i;
    assign seg0_limit_w_datasize_d = nextLatches_seg0_limit_w_datasize_i;
    assign seg0_limit_wo_datasize_d = nextLatches_seg0_limit_wo_datasize_i;
    assign next_ld_vaddy_d = nextLatches_next_ld_vaddy_i;
    assign ld_laddy_d = nextLatches_ld_laddy_i;
    assign ld_stack_access_d = nextLatches_ld_stack_access_i;
    assign st_vaddy_d = nextLatches_st_vaddy_i;
    assign seg1_limit_w_datasize_d = nextLatches_seg1_limit_w_datasize_i;
    assign seg1_limit_wo_datasize_d = nextLatches_seg1_limit_wo_datasize_i;
    assign next_st_vaddy_d = nextLatches_next_st_vaddy_i;
    assign st_laddy_d = nextLatches_st_laddy_i;
    assign st_stack_access_d = nextLatches_st_stack_access_i;
    assign NEIP_d = nextLatches_NEIP_i;
    assign EIP_d = nextLatches_EIP_i;
    assign EAX_d = nextLatches_EAX_i;
    assign imm64_d = nextLatches_imm64_i;
    assign sr_id_d = nextLatches_sr_id_i;
    assign sr_data_d = nextLatches_sr_data_i;
    assign dr_id_d = nextLatches_dr_id_i;
    assign dr_data_d = nextLatches_dr_data_i;

    // ============================================================
    // REG_RST_WE per field (we = effective_we)
    // `REG_RST_WE(__unitName__, __width__, __clk__, __rst__, __we__, __din__, __dout__)
    //   active async low rst
    // ============================================================

    `REG_RST_WE(dc_latches_valid,                          1,   clk, rst, effective_we, valid_d,                          latches_valid_o);

    `REG_RST_WE(dc_latches_cs_LD_OP,                       1,   clk, rst, effective_we, cs_LD_OP_d,                       latches_cs_LD_OP_o);
    `REG_RST_WE(dc_latches_cs_ST_OP,                       1,   clk, rst, effective_we, cs_ST_OP_d,                       latches_cs_ST_OP_o);
    `REG_RST_WE(dc_latches_cs_dr_upper8,                   1,   clk, rst, effective_we, cs_dr_upper8_d,                   latches_cs_dr_upper8_o);
    `REG_RST_WE(dc_latches_cs_sr_upper8,                   1,   clk, rst, effective_we, cs_sr_upper8_d,                   latches_cs_sr_upper8_o);
    `REG_RST_WE(dc_latches_cs_datasize,                    2,   clk, rst, effective_we, cs_datasize_d,                    latches_cs_datasize_o);

    `REG_RST_WE(dc_latches_mem_cs_ST_OP,                   1,   clk, rst, effective_we, mem_cs_ST_OP_d,                   latches_mem_cs_ST_OP_o);
    `REG_RST_WE(dc_latches_mem_cs_LD_OP,                   1,   clk, rst, effective_we, mem_cs_LD_OP_d,                   latches_mem_cs_LD_OP_o);

    `REG_RST_WE(dc_latches_exe_cs_ST_OP,                   1,   clk, rst, effective_we, exe_cs_ST_OP_d,                   latches_exe_cs_ST_OP_o);
    // fanout: redirect dc_latches_exe_cs_OP_TYPE q to staging bus. Every bit
    // has uniform fanout (~5-8) -> bulk-buffer all 6 bits with bufferH16$ to
    // avoid per-bit whack-a-mole as the checker reveals representatives.
    wire [5:0] latches_exe_cs_OP_TYPE_pre_buf;
    `REG_RST_WE(dc_latches_exe_cs_OP_TYPE,                 6,   clk, rst, effective_we, exe_cs_OP_TYPE_d,                 latches_exe_cs_OP_TYPE_pre_buf);
    genvar gi_op_type;
    generate
        for (gi_op_type = 0; gi_op_type <= 5; gi_op_type = gi_op_type + 1) begin : g_op_type_buf
            bufferH16$ u_attach_exe_cs_OP_TYPE (.out(latches_exe_cs_OP_TYPE_o[gi_op_type]), .in(latches_exe_cs_OP_TYPE_pre_buf[gi_op_type]));
        end
    endgenerate
    `REG_RST_WE(dc_latches_exe_cs_alu_inputA_sel,          5,   clk, rst, effective_we, exe_cs_alu_inputA_sel_d,          latches_exe_cs_alu_inputA_sel_o);
    `REG_RST_WE(dc_latches_exe_cs_alu_inputB_sel,          5,   clk, rst, effective_we, exe_cs_alu_inputB_sel_d,          latches_exe_cs_alu_inputB_sel_o);
    `REG_RST_WE(dc_latches_exe_cs_branch_target_sel,       5,   clk, rst, effective_we, exe_cs_branch_target_sel_d,       latches_exe_cs_branch_target_sel_o);
    `REG_RST_WE(dc_latches_exe_cs_shift_by_one,            1,   clk, rst, effective_we, exe_cs_shift_by_one_d,            latches_exe_cs_shift_by_one_o);
    `REG_RST_WE(dc_latches_exe_cs_br_ucond,                1,   clk, rst, effective_we, exe_cs_br_ucond_d,                latches_exe_cs_br_ucond_o);
    `REG_RST_WE(dc_latches_exe_cs_relative_branch,         1,   clk, rst, effective_we, exe_cs_relative_branch_d,         latches_exe_cs_relative_branch_o);
    `REG_RST_WE(dc_latches_exe_cs_special_br,              1,   clk, rst, effective_we, exe_cs_special_br_d,              latches_exe_cs_special_br_o);
    `REG_RST_WE(dc_latches_exe_cs_is_far,                  1,   clk, rst, effective_we, exe_cs_is_far_d,                  latches_exe_cs_is_far_o);
    `REG_RST_WE(dc_latches_exe_cs_is_call,                 1,   clk, rst, effective_we, exe_cs_is_call_d,                 latches_exe_cs_is_call_o);
    `REG_RST_WE(dc_latches_exe_cs_second_flag_needed,      1,   clk, rst, effective_we, exe_cs_second_flag_needed_d,      latches_exe_cs_second_flag_needed_o);
    `REG_RST_WE(dc_latches_exe_cs_rep_no_zf_update,        1,   clk, rst, effective_we, exe_cs_rep_no_zf_update_d,        latches_exe_cs_rep_no_zf_update_o);

    `REG_RST_WE(dc_latches_wb_cs_ST_OP,                    1,   clk, rst, effective_we, wb_cs_ST_OP_d,                    latches_wb_cs_ST_OP_o);
    `REG_RST_WE(dc_latches_wb_cs_WB_DR,                    1,   clk, rst, effective_we, wb_cs_WB_DR_d,                    latches_wb_cs_WB_DR_o);
    `REG_RST_WE(dc_latches_wb_cs_WB_SR,                    1,   clk, rst, effective_we, wb_cs_WB_SR_d,                    latches_wb_cs_WB_SR_o);
    `REG_RST_WE(dc_latches_wb_cs_WB_EAX,                   1,   clk, rst, effective_we, wb_cs_WB_EAX_d,                   latches_wb_cs_WB_EAX_o);

    `REG_RST_WE(dc_latches_br_info_valid,                  1,   clk, rst, effective_we, br_info_valid_d,                  latches_br_info_valid_o);
    `REG_RST_WE(dc_latches_br_info_br_eip,                 32,  clk, rst, effective_we, br_info_br_eip_d,                 latches_br_info_br_eip_o);
    `REG_RST_WE(dc_latches_br_info_br_xcl,                 1,   clk, rst, effective_we, br_info_br_xcl_d,                 latches_br_info_br_xcl_o);
    `REG_RST_WE(dc_latches_br_info_br_pred_taken,          1,   clk, rst, effective_we, br_info_br_pred_taken_d,          latches_br_info_br_pred_taken_o);
    `REG_RST_WE(dc_latches_br_info_speculative_target,     32,  clk, rst, effective_we, br_info_speculative_target_d,     latches_br_info_speculative_target_o);

    `REG_RST_WE(dc_latches_rr_gp,                          1,   clk, rst, effective_we, rr_gp_d,                          latches_rr_gp_o);

    // fanout: redirect dc_latches_ld_vaddy q to staging bus, attach buffers on
    // the high-fanout bits. After the in_flight_sb_logic offset/pfn refactor
    // and the PADDR0 buffer chain in npu_node2, ld_vaddy[10] direct fanout
    // drops to ~7 (vaddy_end adder, mem_latches LD_PADDR_0.Din, DCache_Arb
    // g_arb_block, plus the npu_node2 PADDR0 buffer input via TLB).
    // bufferH16$ rated 16, fits.
    wire [31:0] latches_ld_vaddy_pre_buf;
    `REG_RST_WE(dc_latches_ld_vaddy,                       32,  clk, rst, effective_we, ld_vaddy_d,                       latches_ld_vaddy_pre_buf);
    // Bits [9:0]: low cache-offset, low fanout, passthrough.
    // Bit  [10] : bufferH16$ (post-refactor fanout ~7-8).
    // Bit  [11] : bufferH64$ (high fanout from npu_node2 + adder).
    // Bits [31:12]: upper vaddy bits feed seg_limit / exception checks
    //               with uniform fanout ~8 -> bulk-buffer with bufferH16$.
    assign latches_ld_vaddy_o[9:0]   = latches_ld_vaddy_pre_buf[9:0];
    bufferH16$ u_attach_ld_vaddy_b10 (.out(latches_ld_vaddy_o[10]), .in(latches_ld_vaddy_pre_buf[10]));
    bufferH64$ u_attach_ld_vaddy_b11 (.out(latches_ld_vaddy_o[11]), .in(latches_ld_vaddy_pre_buf[11]));
    genvar gi_ldv;
    generate
        for (gi_ldv = 12; gi_ldv <= 31; gi_ldv = gi_ldv + 1) begin : g_ld_vaddy_buf
            bufferH16$ u_attach_ld_vaddy (.out(latches_ld_vaddy_o[gi_ldv]), .in(latches_ld_vaddy_pre_buf[gi_ldv]));
        end
    endgenerate
    `REG_RST_WE(dc_latches_seg0_limit_w_datasize,          32,  clk, rst, effective_we, seg0_limit_w_datasize_d,          latches_seg0_limit_w_datasize_o);
    `REG_RST_WE(dc_latches_seg0_limit_wo_datasize,         32,  clk, rst, effective_we, seg0_limit_wo_datasize_d,         latches_seg0_limit_wo_datasize_o);
    // fanout: redirect dc_latches_next_ld_vaddy q to staging bus. Upper bits
    // [31:12] feed cross-page calc + seg_limit checks uniformly -> bulk buffer.
    wire [31:0] latches_next_ld_vaddy_pre_buf;
    `REG_RST_WE(dc_latches_next_ld_vaddy,                  32,  clk, rst, effective_we, next_ld_vaddy_d,                  latches_next_ld_vaddy_pre_buf);
    assign latches_next_ld_vaddy_o[11:0] = latches_next_ld_vaddy_pre_buf[11:0];
    genvar gi_nldv;
    generate
        for (gi_nldv = 12; gi_nldv <= 31; gi_nldv = gi_nldv + 1) begin : g_next_ld_vaddy_buf
            bufferH16$ u_attach_next_ld_vaddy (.out(latches_next_ld_vaddy_o[gi_nldv]), .in(latches_next_ld_vaddy_pre_buf[gi_nldv]));
        end
    endgenerate
    `REG_RST_WE(dc_latches_ld_laddy,                       32,  clk, rst, effective_we, ld_laddy_d,                       latches_ld_laddy_o);
    `REG_RST_WE(dc_latches_ld_stack_access,                1,   clk, rst, effective_we, ld_stack_access_d,                latches_ld_stack_access_o);

    // fanout: redirect dc_latches_st_vaddy q to staging bus. Bulk-buffer all
    // 32 bits with bufferH16$ since both upper and lower bits show fanout >4
    // (st_vaddy feeds seg_limit checks + paddr formation).
    wire [31:0] latches_st_vaddy_pre_buf;
    `REG_RST_WE(dc_latches_st_vaddy,                       32,  clk, rst, effective_we, st_vaddy_d,                       latches_st_vaddy_pre_buf);
    genvar gi_stv;
    generate
        for (gi_stv = 0; gi_stv <= 31; gi_stv = gi_stv + 1) begin : g_st_vaddy_buf
            bufferH16$ u_attach_st_vaddy (.out(latches_st_vaddy_o[gi_stv]), .in(latches_st_vaddy_pre_buf[gi_stv]));
        end
    endgenerate
    `REG_RST_WE(dc_latches_seg1_limit_w_datasize,          32,  clk, rst, effective_we, seg1_limit_w_datasize_d,          latches_seg1_limit_w_datasize_o);
    `REG_RST_WE(dc_latches_seg1_limit_wo_datasize,         32,  clk, rst, effective_we, seg1_limit_wo_datasize_d,         latches_seg1_limit_wo_datasize_o);
    // fanout: redirect dc_latches_next_st_vaddy q to staging bus. Same pattern
    // as ld_vaddy -> bulk buffer upper bits [31:12].
    wire [31:0] latches_next_st_vaddy_pre_buf;
    `REG_RST_WE(dc_latches_next_st_vaddy,                  32,  clk, rst, effective_we, next_st_vaddy_d,                  latches_next_st_vaddy_pre_buf);
    assign latches_next_st_vaddy_o[11:0] = latches_next_st_vaddy_pre_buf[11:0];
    genvar gi_nstv;
    generate
        for (gi_nstv = 12; gi_nstv <= 31; gi_nstv = gi_nstv + 1) begin : g_next_st_vaddy_buf
            bufferH16$ u_attach_next_st_vaddy (.out(latches_next_st_vaddy_o[gi_nstv]), .in(latches_next_st_vaddy_pre_buf[gi_nstv]));
        end
    endgenerate
    `REG_RST_WE(dc_latches_st_laddy,                       32,  clk, rst, effective_we, st_laddy_d,                       latches_st_laddy_o);
    `REG_RST_WE(dc_latches_st_stack_access,                1,   clk, rst, effective_we, st_stack_access_d,                latches_st_stack_access_o);

    `REG_RST_WE(dc_latches_NEIP,                           32,  clk, rst, effective_we, NEIP_d,                           latches_NEIP_o);
    `REG_RST_WE(dc_latches_EIP,                            32,  clk, rst, effective_we, EIP_d,                            latches_EIP_o);
    `REG_RST_WE(dc_latches_EAX,                            32,  clk, rst, effective_we, EAX_d,                            latches_EAX_o);

    `REG_RST_WE(dc_latches_imm64,                          64,  clk, rst, effective_we, imm64_d,                          latches_imm64_o);

    `REG_RST_WE(dc_latches_sr_id,                          5,   clk, rst, effective_we, sr_id_d,                          latches_sr_id_o);
    `REG_RST_WE(dc_latches_sr_data,                        64,  clk, rst, effective_we, sr_data_d,                        latches_sr_data_o);
    `REG_RST_WE(dc_latches_dr_id,                          5,   clk, rst, effective_we, dr_id_d,                          latches_dr_id_o);
    `REG_RST_WE(dc_latches_dr_data,                        64,  clk, rst, effective_we, dr_data_d,                        latches_dr_data_o);

    // ============================================================
    // Duplicated copies for fanout reduction.  Each copy has its own
    // flush MUX_2 and REG_RST_WE so the Q outputs are physically
    // independent wires that DC can route to disjoint consumer subsets.
    // The shared `combined_flush` and `effective_we` are reused.
    // ============================================================

    // ---- cs_datasize x3 ----
    wire [1:0] cs_datasize_0_d, cs_datasize_1_d, cs_datasize_2_d;
    `MUX_2(u_dc_mux_cs_datasize_0, 2, cs_datasize_0_d, nextLatches_cs_datasize_0_i, 2'b0, combined_flush);
    `MUX_2(u_dc_mux_cs_datasize_1, 2, cs_datasize_1_d, nextLatches_cs_datasize_1_i, 2'b0, combined_flush);
    `MUX_2(u_dc_mux_cs_datasize_2, 2, cs_datasize_2_d, nextLatches_cs_datasize_2_i, 2'b0, combined_flush);
    // fanout: redirect dc_latches_cs_datasize_0 q to staging bus, attach bufferH16$ on both bits
    wire [1:0] latches_cs_datasize_0_pre_buf;
    `REG_RST_WE(dc_latches_cs_datasize_0, 2, clk, rst, effective_we, cs_datasize_0_d, latches_cs_datasize_0_pre_buf);
    bufferH16$ u_attach_cs_datasize_0_b0 (.out(latches_cs_datasize_0_o[0]), .in(latches_cs_datasize_0_pre_buf[0]));
    bufferH16$ u_attach_cs_datasize_0_b1 (.out(latches_cs_datasize_0_o[1]), .in(latches_cs_datasize_0_pre_buf[1]));
    // fanout: redirect dc_latches_cs_datasize_1 q to staging bus, attach bufferH16$ on both bits
    wire [1:0] latches_cs_datasize_1_pre_buf;
    `REG_RST_WE(dc_latches_cs_datasize_1, 2, clk, rst, effective_we, cs_datasize_1_d, latches_cs_datasize_1_pre_buf);
    bufferH16$ u_attach_cs_datasize_1_b0 (.out(latches_cs_datasize_1_o[0]), .in(latches_cs_datasize_1_pre_buf[0]));
    bufferH16$ u_attach_cs_datasize_1_b1 (.out(latches_cs_datasize_1_o[1]), .in(latches_cs_datasize_1_pre_buf[1]));
    `REG_RST_WE(dc_latches_cs_datasize_2, 2, clk, rst, effective_we, cs_datasize_2_d, latches_cs_datasize_2_o);

    // ---- cs_LD_OP x4 ----
    wire cs_LD_OP_0_d, cs_LD_OP_1_d, cs_LD_OP_2_d, cs_LD_OP_3_d;
    `MUX_2(u_dc_mux_cs_LD_OP_0, 1, cs_LD_OP_0_d, nextLatches_cs_LD_OP_0_i, 1'b0, combined_flush);
    `MUX_2(u_dc_mux_cs_LD_OP_1, 1, cs_LD_OP_1_d, nextLatches_cs_LD_OP_1_i, 1'b0, combined_flush);
    `MUX_2(u_dc_mux_cs_LD_OP_2, 1, cs_LD_OP_2_d, nextLatches_cs_LD_OP_2_i, 1'b0, combined_flush);
    `MUX_2(u_dc_mux_cs_LD_OP_3, 1, cs_LD_OP_3_d, nextLatches_cs_LD_OP_3_i, 1'b0, combined_flush);
    // fanout: redirect dc_latches_cs_LD_OP_0 q to staging wire, attach bufferH16$
    wire latches_cs_LD_OP_0_pre_buf;
    `REG_RST_WE(dc_latches_cs_LD_OP_0, 1, clk, rst, effective_we, cs_LD_OP_0_d, latches_cs_LD_OP_0_pre_buf);
    bufferH16$ u_attach_cs_LD_OP_0 (.out(latches_cs_LD_OP_0_o), .in(latches_cs_LD_OP_0_pre_buf));
    `REG_RST_WE(dc_latches_cs_LD_OP_1, 1, clk, rst, effective_we, cs_LD_OP_1_d, latches_cs_LD_OP_1_o);
    `REG_RST_WE(dc_latches_cs_LD_OP_2, 1, clk, rst, effective_we, cs_LD_OP_2_d, latches_cs_LD_OP_2_o);
    `REG_RST_WE(dc_latches_cs_LD_OP_3, 1, clk, rst, effective_we, cs_LD_OP_3_d, latches_cs_LD_OP_3_o);

    // ---- cs_ST_OP x1 (dedicated for st_neuralnet_part2) ----
    wire cs_ST_OP_0_d;
    `MUX_2(u_dc_mux_cs_ST_OP_0, 1, cs_ST_OP_0_d, nextLatches_cs_ST_OP_0_i, 1'b0, combined_flush);
    // fanout: redirect dc_latches_cs_ST_OP_0 q to staging wire, attach bufferH64$
    wire latches_cs_ST_OP_0_pre_buf;
    `REG_RST_WE(dc_latches_cs_ST_OP_0, 1, clk, rst, effective_we, cs_ST_OP_0_d, latches_cs_ST_OP_0_pre_buf);
    bufferH64$ u_attach_cs_ST_OP_0 (.out(latches_cs_ST_OP_0_o), .in(latches_cs_ST_OP_0_pre_buf));

    // ---- valid x3 ----
    wire valid_0_d, valid_1_d, valid_2_d;
    `MUX_2(u_dc_mux_valid_0, 1, valid_0_d, nextLatches_valid_0_i, 1'b0, combined_flush);
    `MUX_2(u_dc_mux_valid_1, 1, valid_1_d, nextLatches_valid_1_i, 1'b0, combined_flush);
    `MUX_2(u_dc_mux_valid_2, 1, valid_2_d, nextLatches_valid_2_i, 1'b0, combined_flush);
    `REG_RST_WE(dc_latches_valid_0, 1, clk, rst, effective_we, valid_0_d, latches_valid_0_o);
    // fanout: redirect dc_latches_valid_1 q to staging wire, attach bufferH16$
    wire latches_valid_1_pre_buf;
    `REG_RST_WE(dc_latches_valid_1, 1, clk, rst, effective_we, valid_1_d, latches_valid_1_pre_buf);
    bufferH16$ u_attach_valid_1 (.out(latches_valid_1_o), .in(latches_valid_1_pre_buf));
    // fanout: redirect dc_latches_valid_2 q to staging wire, attach bufferH16$
    wire latches_valid_2_pre_buf;
    `REG_RST_WE(dc_latches_valid_2, 1, clk, rst, effective_we, valid_2_d, latches_valid_2_pre_buf);
    bufferH16$ u_attach_valid_2 (.out(latches_valid_2_o), .in(latches_valid_2_pre_buf));

endmodule
