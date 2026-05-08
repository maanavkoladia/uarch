/*

    typedef struct {
        bool valid;
        l_address_t br_eip;
        bool br_xcl;
        bool br_pred_taken;
        l_address_t speculative_target;
    } br_info_t;

    typedef struct {
        bool ST_SEL;
        bool MODRM_NEEDED;
        bool RM_IS_DR;
        bool SWITCH_LD_ADDY;
        bool LD_OP;
        bool ST_OP;
        reg_ids_e dr_id;
        reg_ids_e sr_id;
        bool dr_rd;
        bool sr_rd;
        bool eax_rd;
        bool dr_wr;
        bool sr_wr;
        bool eax_wr;
        bool MOVS_OP;
        logic [1:0] datasize;
        bool will_mod_zf;
        bool seg_1_valid;
        reg_ids_e seg_0_id;
        reg_ids_e seg_1_id;
        bool special_modrm_bs;
        bool special_br;
    } rr_cs_t;

    typedef struct {
        bool LD_OP;
        bool ST_OP;
        bool dr_upper8;
        bool sr_upper8;
        logic [1:0] datasize;
    } dc_cs_t;

    typedef struct {
        bool ST_OP;
        bool LD_OP;
    } mem_cs_t;

    typedef struct {
        bool ST_OP;
        exe_cs_operation_type_e OP_TYPE;
        source_selector_e alu_inputA_sel;
        source_selector_e alu_inputB_sel;
        source_selector_e branch_target_sel;
        bool shift_by_one;
        bool br_ucond;
        bool relative_branch;
        bool special_br;
        bool is_far;
        bool is_call;
        bool second_flag_needed;
        bool rep_no_zf_update;
    } exe_cs_t;

    typedef struct {
        bool ST_OP;
        bool WB_DR;
        bool WB_SR;
        bool WB_EAX;
    } wb_cs_t;

    typedef struct {
        bool valid;
        rr_cs_t cs;
        dc_cs_t dc_cs;
        mem_cs_t mem_cs;
        exe_cs_t exe_cs;
        wb_cs_t wb_cs;
        br_info_t br_info;
        l_address_t NEIP;
        l_address_t EIP;
        uint32_t EAX;
        uint64_t imm64;
        reg_ids_e sib_idx_id;
        reg_ids_e sib_base_id;
        bool sib_needed;
        uint8_t sib_scale;
        bool disp_needed;
        bool disp_size;
        uint32_t displacement;
    } rr_latches_general_t;

    typedef struct {
        rr_latches_general_t normal_latches;
        rr_latches_general_t rep_latches;
    } rr_latches_t;

    Flush behavior (matches non-structural reference):
      - !rst                                           -> latches <= 0  (REG_RST_WE async reset)
      - flush || farFlush || exp_pipe_clear            -> latches <= 0  (regardless of write_enable_i)
      - write_enable_i && !any_flush                   -> latches <= nextLatches
      - !write_enable_i && !any_flush                  -> hold
      Implementation:
        combined_flush = flush OR farFlush OR exp_pipe_clear
        effective_we   = write_enable_i OR combined_flush
        per-field MUX_2 selects (combined_flush ? 0 : nextLatches), output
        feeds REG_RST_WE.d, with we = effective_we.

    rr_latches_t carries TWO general latches (normal_latches + rep_latches),
    so every leaf field appears twice with prefixes  normal_  and  rep_.

  - SV `import` removed; no struct/typedef/enum used.
  - Every field is its own scalar/vector port (`.field` -> `_field`).

*/

//fully unrolled stage latch, every leaf field (x2 banks: normal/rep) gets its own port.
module RR_Latches (
    input wire clk,
    input wire rst,
    input wire write_enable_i,
    input wire flush,
    input wire farFlush,
    input wire exp_pipe_clear,

    // ===================================================================
    // ----- nextLatches_i.normal_latches (unrolled) -----
    // ===================================================================
    input wire        nextLatches_normal_valid_i,

    // rr_cs_t cs
    input wire        nextLatches_normal_cs_ST_SEL_i,
    input wire        nextLatches_normal_cs_MODRM_NEEDED_i,
    input wire        nextLatches_normal_cs_RM_IS_DR_i,
    input wire        nextLatches_normal_cs_SWITCH_LD_ADDY_i,
    input wire        nextLatches_normal_cs_LD_OP_i,
    input wire        nextLatches_normal_cs_ST_OP_i,
    input wire [4:0]  nextLatches_normal_cs_dr_id_i,
    input wire [4:0]  nextLatches_normal_cs_sr_id_i,
    input wire        nextLatches_normal_cs_dr_rd_i,
    input wire        nextLatches_normal_cs_sr_rd_i,
    input wire        nextLatches_normal_cs_eax_rd_i,
    input wire        nextLatches_normal_cs_dr_wr_i,
    input wire        nextLatches_normal_cs_sr_wr_i,
    input wire        nextLatches_normal_cs_eax_wr_i,
    input wire        nextLatches_normal_cs_MOVS_OP_i,
    input wire [1:0]  nextLatches_normal_cs_datasize_i,
    input wire        nextLatches_normal_cs_will_mod_zf_i,
    input wire        nextLatches_normal_cs_seg_1_valid_i,
    input wire [4:0]  nextLatches_normal_cs_seg_0_id_i,
    input wire [4:0]  nextLatches_normal_cs_seg_1_id_i,
    input wire        nextLatches_normal_cs_special_modrm_bs_i,
    input wire        nextLatches_normal_cs_special_br_i,

    // dc_cs_t dc_cs
    input wire        nextLatches_normal_dc_cs_LD_OP_i,
    input wire        nextLatches_normal_dc_cs_ST_OP_i,
    input wire        nextLatches_normal_dc_cs_dr_upper8_i,
    input wire        nextLatches_normal_dc_cs_sr_upper8_i,
    input wire [1:0]  nextLatches_normal_dc_cs_datasize_i,

    // mem_cs_t mem_cs
    input wire        nextLatches_normal_mem_cs_ST_OP_i,
    input wire        nextLatches_normal_mem_cs_LD_OP_i,

    // exe_cs_t exe_cs
    input wire        nextLatches_normal_exe_cs_ST_OP_i,
    input wire [5:0]  nextLatches_normal_exe_cs_OP_TYPE_i,
    input wire [4:0]  nextLatches_normal_exe_cs_alu_inputA_sel_i,
    input wire [4:0]  nextLatches_normal_exe_cs_alu_inputB_sel_i,
    input wire [4:0]  nextLatches_normal_exe_cs_branch_target_sel_i,
    input wire        nextLatches_normal_exe_cs_shift_by_one_i,
    input wire        nextLatches_normal_exe_cs_br_ucond_i,
    input wire        nextLatches_normal_exe_cs_relative_branch_i,
    input wire        nextLatches_normal_exe_cs_special_br_i,
    input wire        nextLatches_normal_exe_cs_is_far_i,
    input wire        nextLatches_normal_exe_cs_is_call_i,
    input wire        nextLatches_normal_exe_cs_second_flag_needed_i,
    input wire        nextLatches_normal_exe_cs_rep_no_zf_update_i,

    // wb_cs_t wb_cs
    input wire        nextLatches_normal_wb_cs_ST_OP_i,
    input wire        nextLatches_normal_wb_cs_WB_DR_i,
    input wire        nextLatches_normal_wb_cs_WB_SR_i,
    input wire        nextLatches_normal_wb_cs_WB_EAX_i,

    // br_info_t br_info
    input wire        nextLatches_normal_br_info_valid_i,
    input wire [31:0] nextLatches_normal_br_info_br_eip_i,
    input wire        nextLatches_normal_br_info_br_xcl_i,
    input wire        nextLatches_normal_br_info_br_pred_taken_i,
    input wire [31:0] nextLatches_normal_br_info_speculative_target_i,

    input wire [31:0] nextLatches_normal_NEIP_i,
    input wire [31:0] nextLatches_normal_EIP_i,
    input wire [31:0] nextLatches_normal_EAX_i,
    input wire [63:0] nextLatches_normal_imm64_i,
    input wire [4:0]  nextLatches_normal_sib_idx_id_i,
    input wire [4:0]  nextLatches_normal_sib_base_id_i,
    input wire        nextLatches_normal_sib_needed_i,
    input wire [7:0]  nextLatches_normal_sib_scale_i,
    input wire        nextLatches_normal_disp_needed_i,
    input wire        nextLatches_normal_disp_size_i,
    input wire [31:0] nextLatches_normal_displacement_i,

    // ===================================================================
    // ----- nextLatches_i.rep_latches (unrolled) -----
    // ===================================================================
    input wire        nextLatches_rep_valid_i,

    input wire        nextLatches_rep_cs_ST_SEL_i,
    input wire        nextLatches_rep_cs_MODRM_NEEDED_i,
    input wire        nextLatches_rep_cs_RM_IS_DR_i,
    input wire        nextLatches_rep_cs_SWITCH_LD_ADDY_i,
    input wire        nextLatches_rep_cs_LD_OP_i,
    input wire        nextLatches_rep_cs_ST_OP_i,
    input wire [4:0]  nextLatches_rep_cs_dr_id_i,
    input wire [4:0]  nextLatches_rep_cs_sr_id_i,
    input wire        nextLatches_rep_cs_dr_rd_i,
    input wire        nextLatches_rep_cs_sr_rd_i,
    input wire        nextLatches_rep_cs_eax_rd_i,
    input wire        nextLatches_rep_cs_dr_wr_i,
    input wire        nextLatches_rep_cs_sr_wr_i,
    input wire        nextLatches_rep_cs_eax_wr_i,
    input wire        nextLatches_rep_cs_MOVS_OP_i,
    input wire [1:0]  nextLatches_rep_cs_datasize_i,
    input wire        nextLatches_rep_cs_will_mod_zf_i,
    input wire        nextLatches_rep_cs_seg_1_valid_i,
    input wire [4:0]  nextLatches_rep_cs_seg_0_id_i,
    input wire [4:0]  nextLatches_rep_cs_seg_1_id_i,
    input wire        nextLatches_rep_cs_special_modrm_bs_i,
    input wire        nextLatches_rep_cs_special_br_i,

    input wire        nextLatches_rep_dc_cs_LD_OP_i,
    input wire        nextLatches_rep_dc_cs_ST_OP_i,
    input wire        nextLatches_rep_dc_cs_dr_upper8_i,
    input wire        nextLatches_rep_dc_cs_sr_upper8_i,
    input wire [1:0]  nextLatches_rep_dc_cs_datasize_i,

    input wire        nextLatches_rep_mem_cs_ST_OP_i,
    input wire        nextLatches_rep_mem_cs_LD_OP_i,

    input wire        nextLatches_rep_exe_cs_ST_OP_i,
    input wire [5:0]  nextLatches_rep_exe_cs_OP_TYPE_i,
    input wire [4:0]  nextLatches_rep_exe_cs_alu_inputA_sel_i,
    input wire [4:0]  nextLatches_rep_exe_cs_alu_inputB_sel_i,
    input wire [4:0]  nextLatches_rep_exe_cs_branch_target_sel_i,
    input wire        nextLatches_rep_exe_cs_shift_by_one_i,
    input wire        nextLatches_rep_exe_cs_br_ucond_i,
    input wire        nextLatches_rep_exe_cs_relative_branch_i,
    input wire        nextLatches_rep_exe_cs_special_br_i,
    input wire        nextLatches_rep_exe_cs_is_far_i,
    input wire        nextLatches_rep_exe_cs_is_call_i,
    input wire        nextLatches_rep_exe_cs_second_flag_needed_i,
    input wire        nextLatches_rep_exe_cs_rep_no_zf_update_i,

    input wire        nextLatches_rep_wb_cs_ST_OP_i,
    input wire        nextLatches_rep_wb_cs_WB_DR_i,
    input wire        nextLatches_rep_wb_cs_WB_SR_i,
    input wire        nextLatches_rep_wb_cs_WB_EAX_i,

    input wire        nextLatches_rep_br_info_valid_i,
    input wire [31:0] nextLatches_rep_br_info_br_eip_i,
    input wire        nextLatches_rep_br_info_br_xcl_i,
    input wire        nextLatches_rep_br_info_br_pred_taken_i,
    input wire [31:0] nextLatches_rep_br_info_speculative_target_i,

    input wire [31:0] nextLatches_rep_NEIP_i,
    input wire [31:0] nextLatches_rep_EIP_i,
    input wire [31:0] nextLatches_rep_EAX_i,
    input wire [63:0] nextLatches_rep_imm64_i,
    input wire [4:0]  nextLatches_rep_sib_idx_id_i,
    input wire [4:0]  nextLatches_rep_sib_base_id_i,
    input wire        nextLatches_rep_sib_needed_i,
    input wire [7:0]  nextLatches_rep_sib_scale_i,
    input wire        nextLatches_rep_disp_needed_i,
    input wire        nextLatches_rep_disp_size_i,
    input wire [31:0] nextLatches_rep_displacement_i,

    // ===================================================================
    // ----- latches_o.normal_latches (unrolled) -----
    // ===================================================================
    output wire        latches_normal_valid_o,

    output wire        latches_normal_cs_ST_SEL_o,
    output wire        latches_normal_cs_MODRM_NEEDED_o,
    output wire        latches_normal_cs_RM_IS_DR_o,
    output wire        latches_normal_cs_SWITCH_LD_ADDY_o,
    output wire        latches_normal_cs_LD_OP_o,
    output wire        latches_normal_cs_ST_OP_o,
    output wire [4:0]  latches_normal_cs_dr_id_o,
    output wire [4:0]  latches_normal_cs_sr_id_o,
    output wire        latches_normal_cs_dr_rd_o,
    output wire        latches_normal_cs_sr_rd_o,
    output wire        latches_normal_cs_eax_rd_o,
    output wire        latches_normal_cs_dr_wr_o,
    output wire        latches_normal_cs_sr_wr_o,
    output wire        latches_normal_cs_eax_wr_o,
    output wire        latches_normal_cs_MOVS_OP_o,
    output wire [1:0]  latches_normal_cs_datasize_o,
    output wire        latches_normal_cs_will_mod_zf_o,
    output wire        latches_normal_cs_seg_1_valid_o,
    output wire [4:0]  latches_normal_cs_seg_0_id_o,
    output wire [4:0]  latches_normal_cs_seg_1_id_o,
    output wire        latches_normal_cs_special_modrm_bs_o,
    output wire        latches_normal_cs_special_br_o,

    output wire        latches_normal_dc_cs_LD_OP_o,
    output wire        latches_normal_dc_cs_ST_OP_o,
    output wire        latches_normal_dc_cs_dr_upper8_o,
    output wire        latches_normal_dc_cs_sr_upper8_o,
    output wire [1:0]  latches_normal_dc_cs_datasize_o,

    output wire        latches_normal_mem_cs_ST_OP_o,
    output wire        latches_normal_mem_cs_LD_OP_o,

    output wire        latches_normal_exe_cs_ST_OP_o,
    output wire [5:0]  latches_normal_exe_cs_OP_TYPE_o,
    output wire [4:0]  latches_normal_exe_cs_alu_inputA_sel_o,
    output wire [4:0]  latches_normal_exe_cs_alu_inputB_sel_o,
    output wire [4:0]  latches_normal_exe_cs_branch_target_sel_o,
    output wire        latches_normal_exe_cs_shift_by_one_o,
    output wire        latches_normal_exe_cs_br_ucond_o,
    output wire        latches_normal_exe_cs_relative_branch_o,
    output wire        latches_normal_exe_cs_special_br_o,
    output wire        latches_normal_exe_cs_is_far_o,
    output wire        latches_normal_exe_cs_is_call_o,
    output wire        latches_normal_exe_cs_second_flag_needed_o,
    output wire        latches_normal_exe_cs_rep_no_zf_update_o,

    output wire        latches_normal_wb_cs_ST_OP_o,
    output wire        latches_normal_wb_cs_WB_DR_o,
    output wire        latches_normal_wb_cs_WB_SR_o,
    output wire        latches_normal_wb_cs_WB_EAX_o,

    output wire        latches_normal_br_info_valid_o,
    output wire [31:0] latches_normal_br_info_br_eip_o,
    output wire        latches_normal_br_info_br_xcl_o,
    output wire        latches_normal_br_info_br_pred_taken_o,
    output wire [31:0] latches_normal_br_info_speculative_target_o,

    output wire [31:0] latches_normal_NEIP_o,
    output wire [31:0] latches_normal_EIP_o,
    output wire [31:0] latches_normal_EAX_o,
    output wire [63:0] latches_normal_imm64_o,
    output wire [4:0]  latches_normal_sib_idx_id_o,
    output wire [4:0]  latches_normal_sib_base_id_o,
    output wire        latches_normal_sib_needed_o,
    output wire [7:0]  latches_normal_sib_scale_o,
    output wire        latches_normal_disp_needed_o,
    output wire        latches_normal_disp_size_o,
    output wire [31:0] latches_normal_displacement_o,

    // ===================================================================
    // ----- latches_o.rep_latches (unrolled) -----
    // ===================================================================
    output wire        latches_rep_valid_o,

    output wire        latches_rep_cs_ST_SEL_o,
    output wire        latches_rep_cs_MODRM_NEEDED_o,
    output wire        latches_rep_cs_RM_IS_DR_o,
    output wire        latches_rep_cs_SWITCH_LD_ADDY_o,
    output wire        latches_rep_cs_LD_OP_o,
    output wire        latches_rep_cs_ST_OP_o,
    output wire [4:0]  latches_rep_cs_dr_id_o,
    output wire [4:0]  latches_rep_cs_sr_id_o,
    output wire        latches_rep_cs_dr_rd_o,
    output wire        latches_rep_cs_sr_rd_o,
    output wire        latches_rep_cs_eax_rd_o,
    output wire        latches_rep_cs_dr_wr_o,
    output wire        latches_rep_cs_sr_wr_o,
    output wire        latches_rep_cs_eax_wr_o,
    output wire        latches_rep_cs_MOVS_OP_o,
    output wire [1:0]  latches_rep_cs_datasize_o,
    output wire        latches_rep_cs_will_mod_zf_o,
    output wire        latches_rep_cs_seg_1_valid_o,
    output wire [4:0]  latches_rep_cs_seg_0_id_o,
    output wire [4:0]  latches_rep_cs_seg_1_id_o,
    output wire        latches_rep_cs_special_modrm_bs_o,
    output wire        latches_rep_cs_special_br_o,

    output wire        latches_rep_dc_cs_LD_OP_o,
    output wire        latches_rep_dc_cs_ST_OP_o,
    output wire        latches_rep_dc_cs_dr_upper8_o,
    output wire        latches_rep_dc_cs_sr_upper8_o,
    output wire [1:0]  latches_rep_dc_cs_datasize_o,

    output wire        latches_rep_mem_cs_ST_OP_o,
    output wire        latches_rep_mem_cs_LD_OP_o,

    output wire        latches_rep_exe_cs_ST_OP_o,
    output wire [5:0]  latches_rep_exe_cs_OP_TYPE_o,
    output wire [4:0]  latches_rep_exe_cs_alu_inputA_sel_o,
    output wire [4:0]  latches_rep_exe_cs_alu_inputB_sel_o,
    output wire [4:0]  latches_rep_exe_cs_branch_target_sel_o,
    output wire        latches_rep_exe_cs_shift_by_one_o,
    output wire        latches_rep_exe_cs_br_ucond_o,
    output wire        latches_rep_exe_cs_relative_branch_o,
    output wire        latches_rep_exe_cs_special_br_o,
    output wire        latches_rep_exe_cs_is_far_o,
    output wire        latches_rep_exe_cs_is_call_o,
    output wire        latches_rep_exe_cs_second_flag_needed_o,
    output wire        latches_rep_exe_cs_rep_no_zf_update_o,

    output wire        latches_rep_wb_cs_ST_OP_o,
    output wire        latches_rep_wb_cs_WB_DR_o,
    output wire        latches_rep_wb_cs_WB_SR_o,
    output wire        latches_rep_wb_cs_WB_EAX_o,

    output wire        latches_rep_br_info_valid_o,
    output wire [31:0] latches_rep_br_info_br_eip_o,
    output wire        latches_rep_br_info_br_xcl_o,
    output wire        latches_rep_br_info_br_pred_taken_o,
    output wire [31:0] latches_rep_br_info_speculative_target_o,

    output wire [31:0] latches_rep_NEIP_o,
    output wire [31:0] latches_rep_EIP_o,
    output wire [31:0] latches_rep_EAX_o,
    output wire [63:0] latches_rep_imm64_o,
    output wire [4:0]  latches_rep_sib_idx_id_o,
    output wire [4:0]  latches_rep_sib_base_id_o,
    output wire        latches_rep_sib_needed_o,
    output wire [7:0]  latches_rep_sib_scale_o,
    output wire        latches_rep_disp_needed_o,
    output wire        latches_rep_disp_size_o,
    output wire [31:0] latches_rep_displacement_o
);

    // ============================================================
    // Combined flush + effective WE
    //   combined_flush = flush  OR farFlush  OR exp_pipe_clear
    //   effective_we   = write_enable_i OR combined_flush
    // ============================================================

    wire combined_flush;
    wire effective_we;
    // fanout: staging wire for u_rr_effective_we OR_2 output (126)
    wire effective_we_pre_buf;

    `OR_2(u_rr_combined_flush, 1, combined_flush, flush, exp_pipe_clear);
    `OR_2(u_rr_effective_we,   1, effective_we_pre_buf,  write_enable_i,   combined_flush);

    // fanout: attach buffer on u_rr_effective_we OR_2 output
    bufferH16$ u_attach_effective_we (.out(effective_we), .in(effective_we_pre_buf));

    // ============================================================
    // Flush-gated data wires (input to each REG_RST_WE)
    //   <field>_d = (combined_flush) ? 0 : nextLatches_<field>_i
    // ============================================================

    // -------- normal_ gated wires --------
    wire        normal_valid_d;
    wire        normal_cs_ST_SEL_d;
    wire        normal_cs_MODRM_NEEDED_d;
    wire        normal_cs_RM_IS_DR_d;
    wire        normal_cs_SWITCH_LD_ADDY_d;
    wire        normal_cs_LD_OP_d;
    wire        normal_cs_ST_OP_d;
    wire [4:0]  normal_cs_dr_id_d;
    wire [4:0]  normal_cs_sr_id_d;
    wire        normal_cs_dr_rd_d;
    wire        normal_cs_sr_rd_d;
    wire        normal_cs_eax_rd_d;
    wire        normal_cs_dr_wr_d;
    wire        normal_cs_sr_wr_d;
    wire        normal_cs_eax_wr_d;
    wire        normal_cs_MOVS_OP_d;
    wire [1:0]  normal_cs_datasize_d;
    wire        normal_cs_will_mod_zf_d;
    wire        normal_cs_seg_1_valid_d;
    wire [4:0]  normal_cs_seg_0_id_d;
    wire [4:0]  normal_cs_seg_1_id_d;
    wire        normal_cs_special_modrm_bs_d;
    wire        normal_cs_special_br_d;
    wire        normal_dc_cs_LD_OP_d;
    wire        normal_dc_cs_ST_OP_d;
    wire        normal_dc_cs_dr_upper8_d;
    wire        normal_dc_cs_sr_upper8_d;
    wire [1:0]  normal_dc_cs_datasize_d;
    wire        normal_mem_cs_ST_OP_d;
    wire        normal_mem_cs_LD_OP_d;
    wire        normal_exe_cs_ST_OP_d;
    wire [5:0]  normal_exe_cs_OP_TYPE_d;
    wire [4:0]  normal_exe_cs_alu_inputA_sel_d;
    wire [4:0]  normal_exe_cs_alu_inputB_sel_d;
    wire [4:0]  normal_exe_cs_branch_target_sel_d;
    wire        normal_exe_cs_shift_by_one_d;
    wire        normal_exe_cs_br_ucond_d;
    wire        normal_exe_cs_relative_branch_d;
    wire        normal_exe_cs_special_br_d;
    wire        normal_exe_cs_is_far_d;
    wire        normal_exe_cs_is_call_d;
    wire        normal_exe_cs_second_flag_needed_d;
    wire        normal_exe_cs_rep_no_zf_update_d;
    wire        normal_wb_cs_ST_OP_d;
    wire        normal_wb_cs_WB_DR_d;
    wire        normal_wb_cs_WB_SR_d;
    wire        normal_wb_cs_WB_EAX_d;
    wire        normal_br_info_valid_d;
    wire [31:0] normal_br_info_br_eip_d;
    wire        normal_br_info_br_xcl_d;
    wire        normal_br_info_br_pred_taken_d;
    wire [31:0] normal_br_info_speculative_target_d;
    wire [31:0] normal_NEIP_d;
    wire [31:0] normal_EIP_d;
    wire [31:0] normal_EAX_d;
    wire [63:0] normal_imm64_d;
    wire [4:0]  normal_sib_idx_id_d;
    wire [4:0]  normal_sib_base_id_d;
    wire        normal_sib_needed_d;
    wire [7:0]  normal_sib_scale_d;
    wire        normal_disp_needed_d;
    wire        normal_disp_size_d;
    wire [31:0] normal_displacement_d;

    // -------- rep_ gated wires --------
    wire        rep_valid_d;
    wire        rep_cs_ST_SEL_d;
    wire        rep_cs_MODRM_NEEDED_d;
    wire        rep_cs_RM_IS_DR_d;
    wire        rep_cs_SWITCH_LD_ADDY_d;
    wire        rep_cs_LD_OP_d;
    wire        rep_cs_ST_OP_d;
    wire [4:0]  rep_cs_dr_id_d;
    wire [4:0]  rep_cs_sr_id_d;
    wire        rep_cs_dr_rd_d;
    wire        rep_cs_sr_rd_d;
    wire        rep_cs_eax_rd_d;
    wire        rep_cs_dr_wr_d;
    wire        rep_cs_sr_wr_d;
    wire        rep_cs_eax_wr_d;
    wire        rep_cs_MOVS_OP_d;
    wire [1:0]  rep_cs_datasize_d;
    wire        rep_cs_will_mod_zf_d;
    wire        rep_cs_seg_1_valid_d;
    wire [4:0]  rep_cs_seg_0_id_d;
    wire [4:0]  rep_cs_seg_1_id_d;
    wire        rep_cs_special_modrm_bs_d;
    wire        rep_cs_special_br_d;
    wire        rep_dc_cs_LD_OP_d;
    wire        rep_dc_cs_ST_OP_d;
    wire        rep_dc_cs_dr_upper8_d;
    wire        rep_dc_cs_sr_upper8_d;
    wire [1:0]  rep_dc_cs_datasize_d;
    wire        rep_mem_cs_ST_OP_d;
    wire        rep_mem_cs_LD_OP_d;
    wire        rep_exe_cs_ST_OP_d;
    wire [5:0]  rep_exe_cs_OP_TYPE_d;
    wire [4:0]  rep_exe_cs_alu_inputA_sel_d;
    wire [4:0]  rep_exe_cs_alu_inputB_sel_d;
    wire [4:0]  rep_exe_cs_branch_target_sel_d;
    wire        rep_exe_cs_shift_by_one_d;
    wire        rep_exe_cs_br_ucond_d;
    wire        rep_exe_cs_relative_branch_d;
    wire        rep_exe_cs_special_br_d;
    wire        rep_exe_cs_is_far_d;
    wire        rep_exe_cs_is_call_d;
    wire        rep_exe_cs_second_flag_needed_d;
    wire        rep_exe_cs_rep_no_zf_update_d;
    wire        rep_wb_cs_ST_OP_d;
    wire        rep_wb_cs_WB_DR_d;
    wire        rep_wb_cs_WB_SR_d;
    wire        rep_wb_cs_WB_EAX_d;
    wire        rep_br_info_valid_d;
    wire [31:0] rep_br_info_br_eip_d;
    wire        rep_br_info_br_xcl_d;
    wire        rep_br_info_br_pred_taken_d;
    wire [31:0] rep_br_info_speculative_target_d;
    wire [31:0] rep_NEIP_d;
    wire [31:0] rep_EIP_d;
    wire [31:0] rep_EAX_d;
    wire [63:0] rep_imm64_d;
    wire [4:0]  rep_sib_idx_id_d;
    wire [4:0]  rep_sib_base_id_d;
    wire        rep_sib_needed_d;
    wire [7:0]  rep_sib_scale_d;
    wire        rep_disp_needed_d;
    wire        rep_disp_size_d;
    wire [31:0] rep_displacement_d;

    // ============================================================
    // -------- normal_ flush MUXes (sel = combined_flush) --------
    // ============================================================

    `MUX_2(u_rr_mux_normal_valid,                          1,   normal_valid_d,                    nextLatches_normal_valid_i,                    1'b0,    combined_flush);

    assign normal_cs_ST_SEL_d = nextLatches_normal_cs_ST_SEL_i;
    assign normal_cs_MODRM_NEEDED_d = nextLatches_normal_cs_MODRM_NEEDED_i;
    assign normal_cs_RM_IS_DR_d = nextLatches_normal_cs_RM_IS_DR_i;
    assign normal_cs_SWITCH_LD_ADDY_d = nextLatches_normal_cs_SWITCH_LD_ADDY_i;
    assign normal_cs_LD_OP_d = nextLatches_normal_cs_LD_OP_i;
    assign normal_cs_ST_OP_d = nextLatches_normal_cs_ST_OP_i;
    assign normal_cs_dr_id_d = nextLatches_normal_cs_dr_id_i;
    assign normal_cs_sr_id_d = nextLatches_normal_cs_sr_id_i;
    assign normal_cs_dr_rd_d = nextLatches_normal_cs_dr_rd_i;
    assign normal_cs_sr_rd_d = nextLatches_normal_cs_sr_rd_i;
    assign normal_cs_eax_rd_d = nextLatches_normal_cs_eax_rd_i;
    assign normal_cs_dr_wr_d = nextLatches_normal_cs_dr_wr_i;
    assign normal_cs_sr_wr_d = nextLatches_normal_cs_sr_wr_i;
    assign normal_cs_eax_wr_d = nextLatches_normal_cs_eax_wr_i;
    assign normal_cs_MOVS_OP_d = nextLatches_normal_cs_MOVS_OP_i;
    assign normal_cs_datasize_d = nextLatches_normal_cs_datasize_i;
    assign normal_cs_will_mod_zf_d = nextLatches_normal_cs_will_mod_zf_i;
    assign normal_cs_seg_1_valid_d = nextLatches_normal_cs_seg_1_valid_i;
    assign normal_cs_seg_0_id_d = nextLatches_normal_cs_seg_0_id_i;
    assign normal_cs_seg_1_id_d = nextLatches_normal_cs_seg_1_id_i;
    assign normal_cs_special_modrm_bs_d = nextLatches_normal_cs_special_modrm_bs_i;
    assign normal_cs_special_br_d = nextLatches_normal_cs_special_br_i;

    assign normal_dc_cs_LD_OP_d = nextLatches_normal_dc_cs_LD_OP_i;
    assign normal_dc_cs_ST_OP_d = nextLatches_normal_dc_cs_ST_OP_i;
    assign normal_dc_cs_dr_upper8_d = nextLatches_normal_dc_cs_dr_upper8_i;
    assign normal_dc_cs_sr_upper8_d = nextLatches_normal_dc_cs_sr_upper8_i;
    assign normal_dc_cs_datasize_d = nextLatches_normal_dc_cs_datasize_i;

    assign normal_mem_cs_ST_OP_d = nextLatches_normal_mem_cs_ST_OP_i;
    assign normal_mem_cs_LD_OP_d = nextLatches_normal_mem_cs_LD_OP_i;

    assign normal_exe_cs_ST_OP_d = nextLatches_normal_exe_cs_ST_OP_i;
    assign normal_exe_cs_OP_TYPE_d = nextLatches_normal_exe_cs_OP_TYPE_i;
    assign normal_exe_cs_alu_inputA_sel_d = nextLatches_normal_exe_cs_alu_inputA_sel_i;
    assign normal_exe_cs_alu_inputB_sel_d = nextLatches_normal_exe_cs_alu_inputB_sel_i;
    assign normal_exe_cs_branch_target_sel_d = nextLatches_normal_exe_cs_branch_target_sel_i;
    assign normal_exe_cs_shift_by_one_d = nextLatches_normal_exe_cs_shift_by_one_i;
    assign normal_exe_cs_br_ucond_d = nextLatches_normal_exe_cs_br_ucond_i;
    assign normal_exe_cs_relative_branch_d = nextLatches_normal_exe_cs_relative_branch_i;
    assign normal_exe_cs_special_br_d = nextLatches_normal_exe_cs_special_br_i;
    assign normal_exe_cs_is_far_d = nextLatches_normal_exe_cs_is_far_i;
    assign normal_exe_cs_is_call_d = nextLatches_normal_exe_cs_is_call_i;
    assign normal_exe_cs_second_flag_needed_d = nextLatches_normal_exe_cs_second_flag_needed_i;
    assign normal_exe_cs_rep_no_zf_update_d = nextLatches_normal_exe_cs_rep_no_zf_update_i;

    assign normal_wb_cs_ST_OP_d = nextLatches_normal_wb_cs_ST_OP_i;
    assign normal_wb_cs_WB_DR_d = nextLatches_normal_wb_cs_WB_DR_i;
    assign normal_wb_cs_WB_SR_d = nextLatches_normal_wb_cs_WB_SR_i;
    assign normal_wb_cs_WB_EAX_d = nextLatches_normal_wb_cs_WB_EAX_i;

    assign normal_br_info_valid_d = nextLatches_normal_br_info_valid_i;
    assign normal_br_info_br_eip_d = nextLatches_normal_br_info_br_eip_i;
    assign normal_br_info_br_xcl_d = nextLatches_normal_br_info_br_xcl_i;
    assign normal_br_info_br_pred_taken_d = nextLatches_normal_br_info_br_pred_taken_i;
    assign normal_br_info_speculative_target_d = nextLatches_normal_br_info_speculative_target_i;

    assign normal_NEIP_d = nextLatches_normal_NEIP_i;
    assign normal_EIP_d = nextLatches_normal_EIP_i;
    assign normal_EAX_d = nextLatches_normal_EAX_i;
    assign normal_imm64_d = nextLatches_normal_imm64_i;
    assign normal_sib_idx_id_d = nextLatches_normal_sib_idx_id_i;
    assign normal_sib_base_id_d = nextLatches_normal_sib_base_id_i;
    assign normal_sib_needed_d = nextLatches_normal_sib_needed_i;
    assign normal_sib_scale_d = nextLatches_normal_sib_scale_i;
    assign normal_disp_needed_d = nextLatches_normal_disp_needed_i;
    assign normal_disp_size_d = nextLatches_normal_disp_size_i;
    assign normal_displacement_d = nextLatches_normal_displacement_i;

    // ============================================================
    // -------- rep_ flush MUXes (sel = combined_flush) --------
    // ============================================================

    `MUX_2(u_rr_mux_rep_valid,                             1,   rep_valid_d,                       nextLatches_rep_valid_i,                       1'b0,    combined_flush);

    assign rep_cs_ST_SEL_d = nextLatches_rep_cs_ST_SEL_i;
    assign rep_cs_MODRM_NEEDED_d = nextLatches_rep_cs_MODRM_NEEDED_i;
    assign rep_cs_RM_IS_DR_d = nextLatches_rep_cs_RM_IS_DR_i;
    assign rep_cs_SWITCH_LD_ADDY_d = nextLatches_rep_cs_SWITCH_LD_ADDY_i;
    assign rep_cs_LD_OP_d = nextLatches_rep_cs_LD_OP_i;
    assign rep_cs_ST_OP_d = nextLatches_rep_cs_ST_OP_i;
    assign rep_cs_dr_id_d = nextLatches_rep_cs_dr_id_i;
    assign rep_cs_sr_id_d = nextLatches_rep_cs_sr_id_i;
    assign rep_cs_dr_rd_d = nextLatches_rep_cs_dr_rd_i;
    assign rep_cs_sr_rd_d = nextLatches_rep_cs_sr_rd_i;
    assign rep_cs_eax_rd_d = nextLatches_rep_cs_eax_rd_i;
    assign rep_cs_dr_wr_d = nextLatches_rep_cs_dr_wr_i;
    assign rep_cs_sr_wr_d = nextLatches_rep_cs_sr_wr_i;
    assign rep_cs_eax_wr_d = nextLatches_rep_cs_eax_wr_i;
    assign rep_cs_MOVS_OP_d = nextLatches_rep_cs_MOVS_OP_i;
    assign rep_cs_datasize_d = nextLatches_rep_cs_datasize_i;
    assign rep_cs_will_mod_zf_d = nextLatches_rep_cs_will_mod_zf_i;
    assign rep_cs_seg_1_valid_d = nextLatches_rep_cs_seg_1_valid_i;
    assign rep_cs_seg_0_id_d = nextLatches_rep_cs_seg_0_id_i;
    assign rep_cs_seg_1_id_d = nextLatches_rep_cs_seg_1_id_i;
    assign rep_cs_special_modrm_bs_d = nextLatches_rep_cs_special_modrm_bs_i;
    assign rep_cs_special_br_d = nextLatches_rep_cs_special_br_i;

    assign rep_dc_cs_LD_OP_d = nextLatches_rep_dc_cs_LD_OP_i;
    assign rep_dc_cs_ST_OP_d = nextLatches_rep_dc_cs_ST_OP_i;
    assign rep_dc_cs_dr_upper8_d = nextLatches_rep_dc_cs_dr_upper8_i;
    assign rep_dc_cs_sr_upper8_d = nextLatches_rep_dc_cs_sr_upper8_i;
    assign rep_dc_cs_datasize_d = nextLatches_rep_dc_cs_datasize_i;

    assign rep_mem_cs_ST_OP_d = nextLatches_rep_mem_cs_ST_OP_i;
    assign rep_mem_cs_LD_OP_d = nextLatches_rep_mem_cs_LD_OP_i;

    assign rep_exe_cs_ST_OP_d = nextLatches_rep_exe_cs_ST_OP_i;
    assign rep_exe_cs_OP_TYPE_d = nextLatches_rep_exe_cs_OP_TYPE_i;
    assign rep_exe_cs_alu_inputA_sel_d = nextLatches_rep_exe_cs_alu_inputA_sel_i;
    assign rep_exe_cs_alu_inputB_sel_d = nextLatches_rep_exe_cs_alu_inputB_sel_i;
    assign rep_exe_cs_branch_target_sel_d = nextLatches_rep_exe_cs_branch_target_sel_i;
    assign rep_exe_cs_shift_by_one_d = nextLatches_rep_exe_cs_shift_by_one_i;
    assign rep_exe_cs_br_ucond_d = nextLatches_rep_exe_cs_br_ucond_i;
    assign rep_exe_cs_relative_branch_d = nextLatches_rep_exe_cs_relative_branch_i;
    assign rep_exe_cs_special_br_d = nextLatches_rep_exe_cs_special_br_i;
    assign rep_exe_cs_is_far_d = nextLatches_rep_exe_cs_is_far_i;
    assign rep_exe_cs_is_call_d = nextLatches_rep_exe_cs_is_call_i;
    assign rep_exe_cs_second_flag_needed_d = nextLatches_rep_exe_cs_second_flag_needed_i;
    assign rep_exe_cs_rep_no_zf_update_d = nextLatches_rep_exe_cs_rep_no_zf_update_i;

    assign rep_wb_cs_ST_OP_d = nextLatches_rep_wb_cs_ST_OP_i;
    assign rep_wb_cs_WB_DR_d = nextLatches_rep_wb_cs_WB_DR_i;
    assign rep_wb_cs_WB_SR_d = nextLatches_rep_wb_cs_WB_SR_i;
    assign rep_wb_cs_WB_EAX_d = nextLatches_rep_wb_cs_WB_EAX_i;

    assign rep_br_info_valid_d = nextLatches_rep_br_info_valid_i;
    assign rep_br_info_br_eip_d = nextLatches_rep_br_info_br_eip_i;
    assign rep_br_info_br_xcl_d = nextLatches_rep_br_info_br_xcl_i;
    assign rep_br_info_br_pred_taken_d = nextLatches_rep_br_info_br_pred_taken_i;
    assign rep_br_info_speculative_target_d = nextLatches_rep_br_info_speculative_target_i;

    assign rep_NEIP_d = nextLatches_rep_NEIP_i;
    assign rep_EIP_d = nextLatches_rep_EIP_i;
    assign rep_EAX_d = nextLatches_rep_EAX_i;
    assign rep_imm64_d = nextLatches_rep_imm64_i;
    assign rep_sib_idx_id_d = nextLatches_rep_sib_idx_id_i;
    assign rep_sib_base_id_d = nextLatches_rep_sib_base_id_i;
    assign rep_sib_needed_d = nextLatches_rep_sib_needed_i;
    assign rep_sib_scale_d = nextLatches_rep_sib_scale_i;
    assign rep_disp_needed_d = nextLatches_rep_disp_needed_i;
    assign rep_disp_size_d = nextLatches_rep_disp_size_i;
    assign rep_displacement_d = nextLatches_rep_displacement_i;

    // ============================================================
    // Grouped packed wires (greedy 64-bit packing in declaration order).
    //   Each group is one REG_RST_WE so effective_we drives 12 cells
    //   (6 normal + 6 rep) instead of one per field.
    //   Wires use [0:N] direction so the first-declared field maps to
    //   index 0 and reads top-to-bottom in declaration order.
    //
    //   Group widths: 60, 57, 64, 64, 64, 53.
    // ============================================================

    // -------- normal_ packed wires --------
    wire [0:59] normal_g1_d;  wire [0:59] normal_g1_q;
    wire [0:56] normal_g2_d;  wire [0:56] normal_g2_q;
    wire [0:63] normal_g3_d;  wire [0:63] normal_g3_q;
    wire [0:63] normal_g4_d;  wire [0:63] normal_g4_q;
    wire [0:63] normal_g5_d;  wire [0:63] normal_g5_q;
    wire [0:52] normal_g6_d;  wire [0:52] normal_g6_q;

    // -------- rep_ packed wires --------
    wire [0:59] rep_g1_d;     wire [0:59] rep_g1_q;
    wire [0:56] rep_g2_d;     wire [0:56] rep_g2_q;
    wire [0:63] rep_g3_d;     wire [0:63] rep_g3_q;
    wire [0:63] rep_g4_d;     wire [0:63] rep_g4_q;
    wire [0:63] rep_g5_d;     wire [0:63] rep_g5_q;
    wire [0:52] rep_g6_d;     wire [0:52] rep_g6_q;

    // ------------------------------------------------------------
    // Pack: concat fields into each group in declaration order
    //   (first-listed item -> index 0)
    // ------------------------------------------------------------

    // ---- normal_g1 [0:59] : valid + cs_t + dc_cs_t + mem_cs_t + exe_cs head ----
    assign normal_g1_d = {
        normal_valid_d,                    // [0]
        normal_cs_ST_SEL_d,                // [1]
        normal_cs_MODRM_NEEDED_d,          // [2]
        normal_cs_RM_IS_DR_d,              // [3]
        normal_cs_SWITCH_LD_ADDY_d,        // [4]
        normal_cs_LD_OP_d,                 // [5]
        normal_cs_ST_OP_d,                 // [6]
        normal_cs_dr_id_d,                 // [7:11]
        normal_cs_sr_id_d,                 // [12:16]
        normal_cs_dr_rd_d,                 // [17]
        normal_cs_sr_rd_d,                 // [18]
        normal_cs_eax_rd_d,                // [19]
        normal_cs_dr_wr_d,                 // [20]
        normal_cs_sr_wr_d,                 // [21]
        normal_cs_eax_wr_d,                // [22]
        normal_cs_MOVS_OP_d,               // [23]
        normal_cs_datasize_d,              // [24:25]
        normal_cs_will_mod_zf_d,           // [26]
        normal_cs_seg_1_valid_d,           // [27]
        normal_cs_seg_0_id_d,              // [28:32]
        normal_cs_seg_1_id_d,              // [33:37]
        normal_cs_special_modrm_bs_d,      // [38]
        normal_cs_special_br_d,            // [39]
        normal_dc_cs_LD_OP_d,              // [40]
        normal_dc_cs_ST_OP_d,              // [41]
        normal_dc_cs_dr_upper8_d,          // [42]
        normal_dc_cs_sr_upper8_d,          // [43]
        normal_dc_cs_datasize_d,           // [44:45]
        normal_mem_cs_ST_OP_d,             // [46]
        normal_mem_cs_LD_OP_d,             // [47]
        normal_exe_cs_ST_OP_d,             // [48]
        normal_exe_cs_OP_TYPE_d,           // [49:54]
        normal_exe_cs_alu_inputA_sel_d     // [55:59]
    };

    // ---- normal_g2 [0:56] : exe_cs tail + wb_cs_t + br_info head ----
    assign normal_g2_d = {
        normal_exe_cs_alu_inputB_sel_d,    // [0:4]
        normal_exe_cs_branch_target_sel_d, // [5:9]
        normal_exe_cs_shift_by_one_d,      // [10]
        normal_exe_cs_br_ucond_d,          // [11]
        normal_exe_cs_relative_branch_d,   // [12]
        normal_exe_cs_special_br_d,        // [13]
        normal_exe_cs_is_far_d,            // [14]
        normal_exe_cs_is_call_d,           // [15]
        normal_exe_cs_second_flag_needed_d,// [16]
        normal_exe_cs_rep_no_zf_update_d,  // [17]
        normal_wb_cs_ST_OP_d,              // [18]
        normal_wb_cs_WB_DR_d,              // [19]
        normal_wb_cs_WB_SR_d,              // [20]
        normal_wb_cs_WB_EAX_d,             // [21]
        normal_br_info_valid_d,            // [22]
        normal_br_info_br_eip_d,           // [23:54]
        normal_br_info_br_xcl_d,           // [55]
        normal_br_info_br_pred_taken_d     // [56]
    };

    // ---- normal_g3 [0:63] : br_info_speculative_target + NEIP ----
    assign normal_g3_d = {
        normal_br_info_speculative_target_d, // [0:31]
        normal_NEIP_d                        // [32:63]
    };

    // ---- normal_g4 [0:63] : EIP + EAX ----
    assign normal_g4_d = {
        normal_EIP_d,                        // [0:31]
        normal_EAX_d                         // [32:63]
    };

    // ---- normal_g5 [0:63] : imm64 ----
    assign normal_g5_d = normal_imm64_d;     // [0:63]

    // ---- normal_g6 [0:52] : sib_* + disp_* + displacement ----
    assign normal_g6_d = {
        normal_sib_idx_id_d,                 // [0:4]
        normal_sib_base_id_d,                // [5:9]
        normal_sib_needed_d,                 // [10]
        normal_sib_scale_d,                  // [11:18]
        normal_disp_needed_d,                // [19]
        normal_disp_size_d,                  // [20]
        normal_displacement_d                // [21:52]
    };

    // ---- rep_g1 [0:59] ----
    assign rep_g1_d = {
        rep_valid_d,                       // [0]
        rep_cs_ST_SEL_d,                   // [1]
        rep_cs_MODRM_NEEDED_d,             // [2]
        rep_cs_RM_IS_DR_d,                 // [3]
        rep_cs_SWITCH_LD_ADDY_d,           // [4]
        rep_cs_LD_OP_d,                    // [5]
        rep_cs_ST_OP_d,                    // [6]
        rep_cs_dr_id_d,                    // [7:11]
        rep_cs_sr_id_d,                    // [12:16]
        rep_cs_dr_rd_d,                    // [17]
        rep_cs_sr_rd_d,                    // [18]
        rep_cs_eax_rd_d,                   // [19]
        rep_cs_dr_wr_d,                    // [20]
        rep_cs_sr_wr_d,                    // [21]
        rep_cs_eax_wr_d,                   // [22]
        rep_cs_MOVS_OP_d,                  // [23]
        rep_cs_datasize_d,                 // [24:25]
        rep_cs_will_mod_zf_d,              // [26]
        rep_cs_seg_1_valid_d,              // [27]
        rep_cs_seg_0_id_d,                 // [28:32]
        rep_cs_seg_1_id_d,                 // [33:37]
        rep_cs_special_modrm_bs_d,         // [38]
        rep_cs_special_br_d,               // [39]
        rep_dc_cs_LD_OP_d,                 // [40]
        rep_dc_cs_ST_OP_d,                 // [41]
        rep_dc_cs_dr_upper8_d,             // [42]
        rep_dc_cs_sr_upper8_d,             // [43]
        rep_dc_cs_datasize_d,              // [44:45]
        rep_mem_cs_ST_OP_d,                // [46]
        rep_mem_cs_LD_OP_d,                // [47]
        rep_exe_cs_ST_OP_d,                // [48]
        rep_exe_cs_OP_TYPE_d,              // [49:54]
        rep_exe_cs_alu_inputA_sel_d        // [55:59]
    };

    // ---- rep_g2 [0:56] ----
    assign rep_g2_d = {
        rep_exe_cs_alu_inputB_sel_d,       // [0:4]
        rep_exe_cs_branch_target_sel_d,    // [5:9]
        rep_exe_cs_shift_by_one_d,         // [10]
        rep_exe_cs_br_ucond_d,             // [11]
        rep_exe_cs_relative_branch_d,      // [12]
        rep_exe_cs_special_br_d,           // [13]
        rep_exe_cs_is_far_d,               // [14]
        rep_exe_cs_is_call_d,              // [15]
        rep_exe_cs_second_flag_needed_d,   // [16]
        rep_exe_cs_rep_no_zf_update_d,     // [17]
        rep_wb_cs_ST_OP_d,                 // [18]
        rep_wb_cs_WB_DR_d,                 // [19]
        rep_wb_cs_WB_SR_d,                 // [20]
        rep_wb_cs_WB_EAX_d,                // [21]
        rep_br_info_valid_d,               // [22]
        rep_br_info_br_eip_d,              // [23:54]
        rep_br_info_br_xcl_d,              // [55]
        rep_br_info_br_pred_taken_d        // [56]
    };

    // ---- rep_g3 [0:63] ----
    assign rep_g3_d = {
        rep_br_info_speculative_target_d,  // [0:31]
        rep_NEIP_d                         // [32:63]
    };

    // ---- rep_g4 [0:63] ----
    assign rep_g4_d = {
        rep_EIP_d,                         // [0:31]
        rep_EAX_d                          // [32:63]
    };

    // ---- rep_g5 [0:63] ----
    assign rep_g5_d = rep_imm64_d;         // [0:63]

    // ---- rep_g6 [0:52] ----
    assign rep_g6_d = {
        rep_sib_idx_id_d,                  // [0:4]
        rep_sib_base_id_d,                 // [5:9]
        rep_sib_needed_d,                  // [10]
        rep_sib_scale_d,                   // [11:18]
        rep_disp_needed_d,                 // [19]
        rep_disp_size_d,                   // [20]
        rep_displacement_d                 // [21:52]
    };

    // ------------------------------------------------------------
    // Splay: drive each per-field output port from its slice of _q
    //   (top-to-bottom matches original declaration order)
    // ------------------------------------------------------------

    // ---- normal_g1 outputs ----
    assign latches_normal_valid_o                 = normal_g1_q[0];
    assign latches_normal_cs_ST_SEL_o             = normal_g1_q[1];
    assign latches_normal_cs_MODRM_NEEDED_o       = normal_g1_q[2];
    assign latches_normal_cs_RM_IS_DR_o           = normal_g1_q[3];
    assign latches_normal_cs_SWITCH_LD_ADDY_o     = normal_g1_q[4];
    assign latches_normal_cs_LD_OP_o              = normal_g1_q[5];
    assign latches_normal_cs_ST_OP_o              = normal_g1_q[6];
    assign latches_normal_cs_dr_id_o              = normal_g1_q[7:11];
    assign latches_normal_cs_sr_id_o              = normal_g1_q[12:16];
    assign latches_normal_cs_dr_rd_o              = normal_g1_q[17];
    assign latches_normal_cs_sr_rd_o              = normal_g1_q[18];
    assign latches_normal_cs_eax_rd_o             = normal_g1_q[19];
    assign latches_normal_cs_dr_wr_o              = normal_g1_q[20];
    assign latches_normal_cs_sr_wr_o              = normal_g1_q[21];
    assign latches_normal_cs_eax_wr_o             = normal_g1_q[22];
    assign latches_normal_cs_MOVS_OP_o            = normal_g1_q[23];
    assign latches_normal_cs_datasize_o           = normal_g1_q[24:25];
    assign latches_normal_cs_will_mod_zf_o        = normal_g1_q[26];
    assign latches_normal_cs_seg_1_valid_o        = normal_g1_q[27];
    assign latches_normal_cs_seg_0_id_o           = normal_g1_q[28:32];
    assign latches_normal_cs_seg_1_id_o           = normal_g1_q[33:37];
    assign latches_normal_cs_special_modrm_bs_o   = normal_g1_q[38];
    assign latches_normal_cs_special_br_o         = normal_g1_q[39];
    assign latches_normal_dc_cs_LD_OP_o           = normal_g1_q[40];
    assign latches_normal_dc_cs_ST_OP_o           = normal_g1_q[41];
    assign latches_normal_dc_cs_dr_upper8_o       = normal_g1_q[42];
    assign latches_normal_dc_cs_sr_upper8_o       = normal_g1_q[43];
    assign latches_normal_dc_cs_datasize_o        = normal_g1_q[44:45];
    assign latches_normal_mem_cs_ST_OP_o          = normal_g1_q[46];
    assign latches_normal_mem_cs_LD_OP_o          = normal_g1_q[47];
    assign latches_normal_exe_cs_ST_OP_o          = normal_g1_q[48];
    assign latches_normal_exe_cs_OP_TYPE_o        = normal_g1_q[49:54];
    assign latches_normal_exe_cs_alu_inputA_sel_o = normal_g1_q[55:59];

    // ---- normal_g2 outputs ----
    assign latches_normal_exe_cs_alu_inputB_sel_o    = normal_g2_q[0:4];
    assign latches_normal_exe_cs_branch_target_sel_o = normal_g2_q[5:9];
    assign latches_normal_exe_cs_shift_by_one_o      = normal_g2_q[10];
    assign latches_normal_exe_cs_br_ucond_o          = normal_g2_q[11];
    assign latches_normal_exe_cs_relative_branch_o   = normal_g2_q[12];
    assign latches_normal_exe_cs_special_br_o        = normal_g2_q[13];
    assign latches_normal_exe_cs_is_far_o            = normal_g2_q[14];
    assign latches_normal_exe_cs_is_call_o           = normal_g2_q[15];
    assign latches_normal_exe_cs_second_flag_needed_o= normal_g2_q[16];
    assign latches_normal_exe_cs_rep_no_zf_update_o  = normal_g2_q[17];
    assign latches_normal_wb_cs_ST_OP_o              = normal_g2_q[18];
    assign latches_normal_wb_cs_WB_DR_o              = normal_g2_q[19];
    assign latches_normal_wb_cs_WB_SR_o              = normal_g2_q[20];
    assign latches_normal_wb_cs_WB_EAX_o             = normal_g2_q[21];
    assign latches_normal_br_info_valid_o            = normal_g2_q[22];
    assign latches_normal_br_info_br_eip_o           = normal_g2_q[23:54];
    assign latches_normal_br_info_br_xcl_o           = normal_g2_q[55];
    assign latches_normal_br_info_br_pred_taken_o    = normal_g2_q[56];

    // ---- normal_g3 outputs ----
    assign latches_normal_br_info_speculative_target_o = normal_g3_q[0:31];
    assign latches_normal_NEIP_o                       = normal_g3_q[32:63];

    // ---- normal_g4 outputs ----
    assign latches_normal_EIP_o = normal_g4_q[0:31];
    assign latches_normal_EAX_o = normal_g4_q[32:63];

    // ---- normal_g5 outputs ----
    assign latches_normal_imm64_o = normal_g5_q[0:63];

    // ---- normal_g6 outputs ----
    assign latches_normal_sib_idx_id_o   = normal_g6_q[0:4];
    assign latches_normal_sib_base_id_o  = normal_g6_q[5:9];
    assign latches_normal_sib_needed_o   = normal_g6_q[10];
    assign latches_normal_sib_scale_o    = normal_g6_q[11:18];
    assign latches_normal_disp_needed_o  = normal_g6_q[19];
    assign latches_normal_disp_size_o    = normal_g6_q[20];
    assign latches_normal_displacement_o = normal_g6_q[21:52];

    // ---- rep_g1 outputs ----
    assign latches_rep_valid_o                 = rep_g1_q[0];
    assign latches_rep_cs_ST_SEL_o             = rep_g1_q[1];
    assign latches_rep_cs_MODRM_NEEDED_o       = rep_g1_q[2];
    assign latches_rep_cs_RM_IS_DR_o           = rep_g1_q[3];
    assign latches_rep_cs_SWITCH_LD_ADDY_o     = rep_g1_q[4];
    assign latches_rep_cs_LD_OP_o              = rep_g1_q[5];
    assign latches_rep_cs_ST_OP_o              = rep_g1_q[6];
    assign latches_rep_cs_dr_id_o              = rep_g1_q[7:11];
    assign latches_rep_cs_sr_id_o              = rep_g1_q[12:16];
    assign latches_rep_cs_dr_rd_o              = rep_g1_q[17];
    assign latches_rep_cs_sr_rd_o              = rep_g1_q[18];
    assign latches_rep_cs_eax_rd_o             = rep_g1_q[19];
    assign latches_rep_cs_dr_wr_o              = rep_g1_q[20];
    assign latches_rep_cs_sr_wr_o              = rep_g1_q[21];
    assign latches_rep_cs_eax_wr_o             = rep_g1_q[22];
    assign latches_rep_cs_MOVS_OP_o            = rep_g1_q[23];
    assign latches_rep_cs_datasize_o           = rep_g1_q[24:25];
    assign latches_rep_cs_will_mod_zf_o        = rep_g1_q[26];
    assign latches_rep_cs_seg_1_valid_o        = rep_g1_q[27];
    assign latches_rep_cs_seg_0_id_o           = rep_g1_q[28:32];
    assign latches_rep_cs_seg_1_id_o           = rep_g1_q[33:37];
    assign latches_rep_cs_special_modrm_bs_o   = rep_g1_q[38];
    assign latches_rep_cs_special_br_o         = rep_g1_q[39];
    assign latches_rep_dc_cs_LD_OP_o           = rep_g1_q[40];
    assign latches_rep_dc_cs_ST_OP_o           = rep_g1_q[41];
    assign latches_rep_dc_cs_dr_upper8_o       = rep_g1_q[42];
    assign latches_rep_dc_cs_sr_upper8_o       = rep_g1_q[43];
    assign latches_rep_dc_cs_datasize_o        = rep_g1_q[44:45];
    assign latches_rep_mem_cs_ST_OP_o          = rep_g1_q[46];
    assign latches_rep_mem_cs_LD_OP_o          = rep_g1_q[47];
    assign latches_rep_exe_cs_ST_OP_o          = rep_g1_q[48];
    assign latches_rep_exe_cs_OP_TYPE_o        = rep_g1_q[49:54];
    assign latches_rep_exe_cs_alu_inputA_sel_o = rep_g1_q[55:59];

    // ---- rep_g2 outputs ----
    assign latches_rep_exe_cs_alu_inputB_sel_o    = rep_g2_q[0:4];
    assign latches_rep_exe_cs_branch_target_sel_o = rep_g2_q[5:9];
    assign latches_rep_exe_cs_shift_by_one_o      = rep_g2_q[10];
    assign latches_rep_exe_cs_br_ucond_o          = rep_g2_q[11];
    assign latches_rep_exe_cs_relative_branch_o   = rep_g2_q[12];
    assign latches_rep_exe_cs_special_br_o        = rep_g2_q[13];
    assign latches_rep_exe_cs_is_far_o            = rep_g2_q[14];
    assign latches_rep_exe_cs_is_call_o           = rep_g2_q[15];
    assign latches_rep_exe_cs_second_flag_needed_o= rep_g2_q[16];
    assign latches_rep_exe_cs_rep_no_zf_update_o  = rep_g2_q[17];
    assign latches_rep_wb_cs_ST_OP_o              = rep_g2_q[18];
    assign latches_rep_wb_cs_WB_DR_o              = rep_g2_q[19];
    assign latches_rep_wb_cs_WB_SR_o              = rep_g2_q[20];
    assign latches_rep_wb_cs_WB_EAX_o             = rep_g2_q[21];
    assign latches_rep_br_info_valid_o            = rep_g2_q[22];
    assign latches_rep_br_info_br_eip_o           = rep_g2_q[23:54];
    assign latches_rep_br_info_br_xcl_o           = rep_g2_q[55];
    assign latches_rep_br_info_br_pred_taken_o    = rep_g2_q[56];

    // ---- rep_g3 outputs ----
    assign latches_rep_br_info_speculative_target_o = rep_g3_q[0:31];
    assign latches_rep_NEIP_o                       = rep_g3_q[32:63];

    // ---- rep_g4 outputs ----
    assign latches_rep_EIP_o = rep_g4_q[0:31];
    assign latches_rep_EAX_o = rep_g4_q[32:63];

    // ---- rep_g5 outputs ----
    assign latches_rep_imm64_o = rep_g5_q[0:63];

    // ---- rep_g6 outputs ----
    assign latches_rep_sib_idx_id_o   = rep_g6_q[0:4];
    assign latches_rep_sib_base_id_o  = rep_g6_q[5:9];
    assign latches_rep_sib_needed_o   = rep_g6_q[10];
    assign latches_rep_sib_scale_o    = rep_g6_q[11:18];
    assign latches_rep_disp_needed_o  = rep_g6_q[19];
    assign latches_rep_disp_size_o    = rep_g6_q[20];
    assign latches_rep_displacement_o = rep_g6_q[21:52];

    // ============================================================
    // Grouped REG_RST_WE instantiations (12 total: 6 normal + 6 rep)
    // ============================================================

    `REG_RST_WE(rr_latches_normal_g1, 60, clk, rst, effective_we, normal_g1_d, normal_g1_q);
    `REG_RST_WE(rr_latches_normal_g2, 57, clk, rst, effective_we, normal_g2_d, normal_g2_q);
    `REG_RST_WE(rr_latches_normal_g3, 64, clk, rst, effective_we, normal_g3_d, normal_g3_q);
    `REG_RST_WE(rr_latches_normal_g4, 64, clk, rst, effective_we, normal_g4_d, normal_g4_q);
    `REG_RST_WE(rr_latches_normal_g5, 64, clk, rst, effective_we, normal_g5_d, normal_g5_q);
    `REG_RST_WE(rr_latches_normal_g6, 53, clk, rst, effective_we, normal_g6_d, normal_g6_q);

    `REG_RST_WE(rr_latches_rep_g1,    60, clk, rst, effective_we, rep_g1_d,    rep_g1_q);
    `REG_RST_WE(rr_latches_rep_g2,    57, clk, rst, effective_we, rep_g2_d,    rep_g2_q);
    `REG_RST_WE(rr_latches_rep_g3,    64, clk, rst, effective_we, rep_g3_d,    rep_g3_q);
    `REG_RST_WE(rr_latches_rep_g4,    64, clk, rst, effective_we, rep_g4_d,    rep_g4_q);
    `REG_RST_WE(rr_latches_rep_g5,    64, clk, rst, effective_we, rep_g5_d,    rep_g5_q);
    `REG_RST_WE(rr_latches_rep_g6,    53, clk, rst, effective_we, rep_g6_d,    rep_g6_q);

endmodule
