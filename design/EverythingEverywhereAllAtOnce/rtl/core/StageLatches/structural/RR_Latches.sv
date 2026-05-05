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

*/

`define STRUCTURAL_RR_STAGE_LATCHES

`ifdef STRUCTURAL_RR_STAGE_LATCHES
//fully unrolled stage latch, every leaf field (×2 banks: normal/rep) gets its own port.
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
    input wire [31:0] nextLatches_normal_exe_cs_OP_TYPE_i,
    input wire [31:0] nextLatches_normal_exe_cs_alu_inputA_sel_i,
    input wire [31:0] nextLatches_normal_exe_cs_alu_inputB_sel_i,
    input wire [31:0] nextLatches_normal_exe_cs_branch_target_sel_i,
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
    input wire [31:0] nextLatches_rep_exe_cs_OP_TYPE_i,
    input wire [31:0] nextLatches_rep_exe_cs_alu_inputA_sel_i,
    input wire [31:0] nextLatches_rep_exe_cs_alu_inputB_sel_i,
    input wire [31:0] nextLatches_rep_exe_cs_branch_target_sel_i,
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
    output wire [31:0] latches_normal_exe_cs_OP_TYPE_o,
    output wire [31:0] latches_normal_exe_cs_alu_inputA_sel_o,
    output wire [31:0] latches_normal_exe_cs_alu_inputB_sel_o,
    output wire [31:0] latches_normal_exe_cs_branch_target_sel_o,
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
    output wire [31:0] latches_rep_exe_cs_OP_TYPE_o,
    output wire [31:0] latches_rep_exe_cs_alu_inputA_sel_o,
    output wire [31:0] latches_rep_exe_cs_alu_inputB_sel_o,
    output wire [31:0] latches_rep_exe_cs_branch_target_sel_o,
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
`else
module RR_Latches (
    input wire clk,
    input wire rst,
    input rr_latches_t nextLatches_i,
    input wire write_enable_i,
    input wire flush,
    input wire farFlush,
    input wire exp_pipe_clear,
    output rr_latches_t latches_o
);

    // =====================================================================
    // ---- alias wires (same names as the unrolled-port version) ----
    // =====================================================================

    // -------- normal_latches inputs --------
    wire        nextLatches_normal_valid_i;
    wire        nextLatches_normal_cs_ST_SEL_i;
    wire        nextLatches_normal_cs_MODRM_NEEDED_i;
    wire        nextLatches_normal_cs_RM_IS_DR_i;
    wire        nextLatches_normal_cs_SWITCH_LD_ADDY_i;
    wire        nextLatches_normal_cs_LD_OP_i;
    wire        nextLatches_normal_cs_ST_OP_i;
    wire [4:0]  nextLatches_normal_cs_dr_id_i;
    wire [4:0]  nextLatches_normal_cs_sr_id_i;
    wire        nextLatches_normal_cs_dr_rd_i;
    wire        nextLatches_normal_cs_sr_rd_i;
    wire        nextLatches_normal_cs_eax_rd_i;
    wire        nextLatches_normal_cs_dr_wr_i;
    wire        nextLatches_normal_cs_sr_wr_i;
    wire        nextLatches_normal_cs_eax_wr_i;
    wire        nextLatches_normal_cs_MOVS_OP_i;
    wire [1:0]  nextLatches_normal_cs_datasize_i;
    wire        nextLatches_normal_cs_will_mod_zf_i;
    wire        nextLatches_normal_cs_seg_1_valid_i;
    wire [4:0]  nextLatches_normal_cs_seg_0_id_i;
    wire [4:0]  nextLatches_normal_cs_seg_1_id_i;
    wire        nextLatches_normal_cs_special_modrm_bs_i;
    wire        nextLatches_normal_cs_special_br_i;
    wire        nextLatches_normal_dc_cs_LD_OP_i;
    wire        nextLatches_normal_dc_cs_ST_OP_i;
    wire        nextLatches_normal_dc_cs_dr_upper8_i;
    wire        nextLatches_normal_dc_cs_sr_upper8_i;
    wire [1:0]  nextLatches_normal_dc_cs_datasize_i;
    wire        nextLatches_normal_mem_cs_ST_OP_i;
    wire        nextLatches_normal_mem_cs_LD_OP_i;
    wire        nextLatches_normal_exe_cs_ST_OP_i;
    wire [31:0] nextLatches_normal_exe_cs_OP_TYPE_i;
    wire [31:0] nextLatches_normal_exe_cs_alu_inputA_sel_i;
    wire [31:0] nextLatches_normal_exe_cs_alu_inputB_sel_i;
    wire [31:0] nextLatches_normal_exe_cs_branch_target_sel_i;
    wire        nextLatches_normal_exe_cs_shift_by_one_i;
    wire        nextLatches_normal_exe_cs_br_ucond_i;
    wire        nextLatches_normal_exe_cs_relative_branch_i;
    wire        nextLatches_normal_exe_cs_special_br_i;
    wire        nextLatches_normal_exe_cs_is_far_i;
    wire        nextLatches_normal_exe_cs_is_call_i;
    wire        nextLatches_normal_exe_cs_second_flag_needed_i;
    wire        nextLatches_normal_exe_cs_rep_no_zf_update_i;
    wire        nextLatches_normal_wb_cs_ST_OP_i;
    wire        nextLatches_normal_wb_cs_WB_DR_i;
    wire        nextLatches_normal_wb_cs_WB_SR_i;
    wire        nextLatches_normal_wb_cs_WB_EAX_i;
    wire        nextLatches_normal_br_info_valid_i;
    wire [31:0] nextLatches_normal_br_info_br_eip_i;
    wire        nextLatches_normal_br_info_br_xcl_i;
    wire        nextLatches_normal_br_info_br_pred_taken_i;
    wire [31:0] nextLatches_normal_br_info_speculative_target_i;
    wire [31:0] nextLatches_normal_NEIP_i;
    wire [31:0] nextLatches_normal_EIP_i;
    wire [31:0] nextLatches_normal_EAX_i;
    wire [63:0] nextLatches_normal_imm64_i;
    wire [4:0]  nextLatches_normal_sib_idx_id_i;
    wire [4:0]  nextLatches_normal_sib_base_id_i;
    wire        nextLatches_normal_sib_needed_i;
    wire [7:0]  nextLatches_normal_sib_scale_i;
    wire        nextLatches_normal_disp_needed_i;
    wire        nextLatches_normal_disp_size_i;
    wire [31:0] nextLatches_normal_displacement_i;

    // -------- rep_latches inputs --------
    wire        nextLatches_rep_valid_i;
    wire        nextLatches_rep_cs_ST_SEL_i;
    wire        nextLatches_rep_cs_MODRM_NEEDED_i;
    wire        nextLatches_rep_cs_RM_IS_DR_i;
    wire        nextLatches_rep_cs_SWITCH_LD_ADDY_i;
    wire        nextLatches_rep_cs_LD_OP_i;
    wire        nextLatches_rep_cs_ST_OP_i;
    wire [4:0]  nextLatches_rep_cs_dr_id_i;
    wire [4:0]  nextLatches_rep_cs_sr_id_i;
    wire        nextLatches_rep_cs_dr_rd_i;
    wire        nextLatches_rep_cs_sr_rd_i;
    wire        nextLatches_rep_cs_eax_rd_i;
    wire        nextLatches_rep_cs_dr_wr_i;
    wire        nextLatches_rep_cs_sr_wr_i;
    wire        nextLatches_rep_cs_eax_wr_i;
    wire        nextLatches_rep_cs_MOVS_OP_i;
    wire [1:0]  nextLatches_rep_cs_datasize_i;
    wire        nextLatches_rep_cs_will_mod_zf_i;
    wire        nextLatches_rep_cs_seg_1_valid_i;
    wire [4:0]  nextLatches_rep_cs_seg_0_id_i;
    wire [4:0]  nextLatches_rep_cs_seg_1_id_i;
    wire        nextLatches_rep_cs_special_modrm_bs_i;
    wire        nextLatches_rep_cs_special_br_i;
    wire        nextLatches_rep_dc_cs_LD_OP_i;
    wire        nextLatches_rep_dc_cs_ST_OP_i;
    wire        nextLatches_rep_dc_cs_dr_upper8_i;
    wire        nextLatches_rep_dc_cs_sr_upper8_i;
    wire [1:0]  nextLatches_rep_dc_cs_datasize_i;
    wire        nextLatches_rep_mem_cs_ST_OP_i;
    wire        nextLatches_rep_mem_cs_LD_OP_i;
    wire        nextLatches_rep_exe_cs_ST_OP_i;
    wire [31:0] nextLatches_rep_exe_cs_OP_TYPE_i;
    wire [31:0] nextLatches_rep_exe_cs_alu_inputA_sel_i;
    wire [31:0] nextLatches_rep_exe_cs_alu_inputB_sel_i;
    wire [31:0] nextLatches_rep_exe_cs_branch_target_sel_i;
    wire        nextLatches_rep_exe_cs_shift_by_one_i;
    wire        nextLatches_rep_exe_cs_br_ucond_i;
    wire        nextLatches_rep_exe_cs_relative_branch_i;
    wire        nextLatches_rep_exe_cs_special_br_i;
    wire        nextLatches_rep_exe_cs_is_far_i;
    wire        nextLatches_rep_exe_cs_is_call_i;
    wire        nextLatches_rep_exe_cs_second_flag_needed_i;
    wire        nextLatches_rep_exe_cs_rep_no_zf_update_i;
    wire        nextLatches_rep_wb_cs_ST_OP_i;
    wire        nextLatches_rep_wb_cs_WB_DR_i;
    wire        nextLatches_rep_wb_cs_WB_SR_i;
    wire        nextLatches_rep_wb_cs_WB_EAX_i;
    wire        nextLatches_rep_br_info_valid_i;
    wire [31:0] nextLatches_rep_br_info_br_eip_i;
    wire        nextLatches_rep_br_info_br_xcl_i;
    wire        nextLatches_rep_br_info_br_pred_taken_i;
    wire [31:0] nextLatches_rep_br_info_speculative_target_i;
    wire [31:0] nextLatches_rep_NEIP_i;
    wire [31:0] nextLatches_rep_EIP_i;
    wire [31:0] nextLatches_rep_EAX_i;
    wire [63:0] nextLatches_rep_imm64_i;
    wire [4:0]  nextLatches_rep_sib_idx_id_i;
    wire [4:0]  nextLatches_rep_sib_base_id_i;
    wire        nextLatches_rep_sib_needed_i;
    wire [7:0]  nextLatches_rep_sib_scale_i;
    wire        nextLatches_rep_disp_needed_i;
    wire        nextLatches_rep_disp_size_i;
    wire [31:0] nextLatches_rep_displacement_i;

    // -------- normal_latches outputs --------
    wire        latches_normal_valid_o;
    wire        latches_normal_cs_ST_SEL_o;
    wire        latches_normal_cs_MODRM_NEEDED_o;
    wire        latches_normal_cs_RM_IS_DR_o;
    wire        latches_normal_cs_SWITCH_LD_ADDY_o;
    wire        latches_normal_cs_LD_OP_o;
    wire        latches_normal_cs_ST_OP_o;
    wire [4:0]  latches_normal_cs_dr_id_o;
    wire [4:0]  latches_normal_cs_sr_id_o;
    wire        latches_normal_cs_dr_rd_o;
    wire        latches_normal_cs_sr_rd_o;
    wire        latches_normal_cs_eax_rd_o;
    wire        latches_normal_cs_dr_wr_o;
    wire        latches_normal_cs_sr_wr_o;
    wire        latches_normal_cs_eax_wr_o;
    wire        latches_normal_cs_MOVS_OP_o;
    wire [1:0]  latches_normal_cs_datasize_o;
    wire        latches_normal_cs_will_mod_zf_o;
    wire        latches_normal_cs_seg_1_valid_o;
    wire [4:0]  latches_normal_cs_seg_0_id_o;
    wire [4:0]  latches_normal_cs_seg_1_id_o;
    wire        latches_normal_cs_special_modrm_bs_o;
    wire        latches_normal_cs_special_br_o;
    wire        latches_normal_dc_cs_LD_OP_o;
    wire        latches_normal_dc_cs_ST_OP_o;
    wire        latches_normal_dc_cs_dr_upper8_o;
    wire        latches_normal_dc_cs_sr_upper8_o;
    wire [1:0]  latches_normal_dc_cs_datasize_o;
    wire        latches_normal_mem_cs_ST_OP_o;
    wire        latches_normal_mem_cs_LD_OP_o;
    wire        latches_normal_exe_cs_ST_OP_o;
    wire [31:0] latches_normal_exe_cs_OP_TYPE_o;
    wire [31:0] latches_normal_exe_cs_alu_inputA_sel_o;
    wire [31:0] latches_normal_exe_cs_alu_inputB_sel_o;
    wire [31:0] latches_normal_exe_cs_branch_target_sel_o;
    wire        latches_normal_exe_cs_shift_by_one_o;
    wire        latches_normal_exe_cs_br_ucond_o;
    wire        latches_normal_exe_cs_relative_branch_o;
    wire        latches_normal_exe_cs_special_br_o;
    wire        latches_normal_exe_cs_is_far_o;
    wire        latches_normal_exe_cs_is_call_o;
    wire        latches_normal_exe_cs_second_flag_needed_o;
    wire        latches_normal_exe_cs_rep_no_zf_update_o;
    wire        latches_normal_wb_cs_ST_OP_o;
    wire        latches_normal_wb_cs_WB_DR_o;
    wire        latches_normal_wb_cs_WB_SR_o;
    wire        latches_normal_wb_cs_WB_EAX_o;
    wire        latches_normal_br_info_valid_o;
    wire [31:0] latches_normal_br_info_br_eip_o;
    wire        latches_normal_br_info_br_xcl_o;
    wire        latches_normal_br_info_br_pred_taken_o;
    wire [31:0] latches_normal_br_info_speculative_target_o;
    wire [31:0] latches_normal_NEIP_o;
    wire [31:0] latches_normal_EIP_o;
    wire [31:0] latches_normal_EAX_o;
    wire [63:0] latches_normal_imm64_o;
    wire [4:0]  latches_normal_sib_idx_id_o;
    wire [4:0]  latches_normal_sib_base_id_o;
    wire        latches_normal_sib_needed_o;
    wire [7:0]  latches_normal_sib_scale_o;
    wire        latches_normal_disp_needed_o;
    wire        latches_normal_disp_size_o;
    wire [31:0] latches_normal_displacement_o;

    // -------- rep_latches outputs --------
    wire        latches_rep_valid_o;
    wire        latches_rep_cs_ST_SEL_o;
    wire        latches_rep_cs_MODRM_NEEDED_o;
    wire        latches_rep_cs_RM_IS_DR_o;
    wire        latches_rep_cs_SWITCH_LD_ADDY_o;
    wire        latches_rep_cs_LD_OP_o;
    wire        latches_rep_cs_ST_OP_o;
    wire [4:0]  latches_rep_cs_dr_id_o;
    wire [4:0]  latches_rep_cs_sr_id_o;
    wire        latches_rep_cs_dr_rd_o;
    wire        latches_rep_cs_sr_rd_o;
    wire        latches_rep_cs_eax_rd_o;
    wire        latches_rep_cs_dr_wr_o;
    wire        latches_rep_cs_sr_wr_o;
    wire        latches_rep_cs_eax_wr_o;
    wire        latches_rep_cs_MOVS_OP_o;
    wire [1:0]  latches_rep_cs_datasize_o;
    wire        latches_rep_cs_will_mod_zf_o;
    wire        latches_rep_cs_seg_1_valid_o;
    wire [4:0]  latches_rep_cs_seg_0_id_o;
    wire [4:0]  latches_rep_cs_seg_1_id_o;
    wire        latches_rep_cs_special_modrm_bs_o;
    wire        latches_rep_cs_special_br_o;
    wire        latches_rep_dc_cs_LD_OP_o;
    wire        latches_rep_dc_cs_ST_OP_o;
    wire        latches_rep_dc_cs_dr_upper8_o;
    wire        latches_rep_dc_cs_sr_upper8_o;
    wire [1:0]  latches_rep_dc_cs_datasize_o;
    wire        latches_rep_mem_cs_ST_OP_o;
    wire        latches_rep_mem_cs_LD_OP_o;
    wire        latches_rep_exe_cs_ST_OP_o;
    wire [31:0] latches_rep_exe_cs_OP_TYPE_o;
    wire [31:0] latches_rep_exe_cs_alu_inputA_sel_o;
    wire [31:0] latches_rep_exe_cs_alu_inputB_sel_o;
    wire [31:0] latches_rep_exe_cs_branch_target_sel_o;
    wire        latches_rep_exe_cs_shift_by_one_o;
    wire        latches_rep_exe_cs_br_ucond_o;
    wire        latches_rep_exe_cs_relative_branch_o;
    wire        latches_rep_exe_cs_special_br_o;
    wire        latches_rep_exe_cs_is_far_o;
    wire        latches_rep_exe_cs_is_call_o;
    wire        latches_rep_exe_cs_second_flag_needed_o;
    wire        latches_rep_exe_cs_rep_no_zf_update_o;
    wire        latches_rep_wb_cs_ST_OP_o;
    wire        latches_rep_wb_cs_WB_DR_o;
    wire        latches_rep_wb_cs_WB_SR_o;
    wire        latches_rep_wb_cs_WB_EAX_o;
    wire        latches_rep_br_info_valid_o;
    wire [31:0] latches_rep_br_info_br_eip_o;
    wire        latches_rep_br_info_br_xcl_o;
    wire        latches_rep_br_info_br_pred_taken_o;
    wire [31:0] latches_rep_br_info_speculative_target_o;
    wire [31:0] latches_rep_NEIP_o;
    wire [31:0] latches_rep_EIP_o;
    wire [31:0] latches_rep_EAX_o;
    wire [63:0] latches_rep_imm64_o;
    wire [4:0]  latches_rep_sib_idx_id_o;
    wire [4:0]  latches_rep_sib_base_id_o;
    wire        latches_rep_sib_needed_o;
    wire [7:0]  latches_rep_sib_scale_o;
    wire        latches_rep_disp_needed_o;
    wire        latches_rep_disp_size_o;
    wire [31:0] latches_rep_displacement_o;

    // =====================================================================
    // ---- bridge SV struct fields -> alias wires (normal_latches) ----
    // =====================================================================
    assign nextLatches_normal_valid_i                    = nextLatches_i.normal_latches.valid;
    assign nextLatches_normal_cs_ST_SEL_i                = nextLatches_i.normal_latches.cs.ST_SEL;
    assign nextLatches_normal_cs_MODRM_NEEDED_i          = nextLatches_i.normal_latches.cs.MODRM_NEEDED;
    assign nextLatches_normal_cs_RM_IS_DR_i              = nextLatches_i.normal_latches.cs.RM_IS_DR;
    assign nextLatches_normal_cs_SWITCH_LD_ADDY_i        = nextLatches_i.normal_latches.cs.SWITCH_LD_ADDY;
    assign nextLatches_normal_cs_LD_OP_i                 = nextLatches_i.normal_latches.cs.LD_OP;
    assign nextLatches_normal_cs_ST_OP_i                 = nextLatches_i.normal_latches.cs.ST_OP;
    assign nextLatches_normal_cs_dr_id_i                 = nextLatches_i.normal_latches.cs.dr_id;
    assign nextLatches_normal_cs_sr_id_i                 = nextLatches_i.normal_latches.cs.sr_id;
    assign nextLatches_normal_cs_dr_rd_i                 = nextLatches_i.normal_latches.cs.dr_rd;
    assign nextLatches_normal_cs_sr_rd_i                 = nextLatches_i.normal_latches.cs.sr_rd;
    assign nextLatches_normal_cs_eax_rd_i                = nextLatches_i.normal_latches.cs.eax_rd;
    assign nextLatches_normal_cs_dr_wr_i                 = nextLatches_i.normal_latches.cs.dr_wr;
    assign nextLatches_normal_cs_sr_wr_i                 = nextLatches_i.normal_latches.cs.sr_wr;
    assign nextLatches_normal_cs_eax_wr_i                = nextLatches_i.normal_latches.cs.eax_wr;
    assign nextLatches_normal_cs_MOVS_OP_i               = nextLatches_i.normal_latches.cs.MOVS_OP;
    assign nextLatches_normal_cs_datasize_i              = nextLatches_i.normal_latches.cs.datasize;
    assign nextLatches_normal_cs_will_mod_zf_i           = nextLatches_i.normal_latches.cs.will_mod_zf;
    assign nextLatches_normal_cs_seg_1_valid_i           = nextLatches_i.normal_latches.cs.seg_1_valid;
    assign nextLatches_normal_cs_seg_0_id_i              = nextLatches_i.normal_latches.cs.seg_0_id;
    assign nextLatches_normal_cs_seg_1_id_i              = nextLatches_i.normal_latches.cs.seg_1_id;
    assign nextLatches_normal_cs_special_modrm_bs_i      = nextLatches_i.normal_latches.cs.special_modrm_bs;
    assign nextLatches_normal_cs_special_br_i            = nextLatches_i.normal_latches.cs.special_br;
    assign nextLatches_normal_dc_cs_LD_OP_i              = nextLatches_i.normal_latches.dc_cs.LD_OP;
    assign nextLatches_normal_dc_cs_ST_OP_i              = nextLatches_i.normal_latches.dc_cs.ST_OP;
    assign nextLatches_normal_dc_cs_dr_upper8_i          = nextLatches_i.normal_latches.dc_cs.dr_upper8;
    assign nextLatches_normal_dc_cs_sr_upper8_i          = nextLatches_i.normal_latches.dc_cs.sr_upper8;
    assign nextLatches_normal_dc_cs_datasize_i           = nextLatches_i.normal_latches.dc_cs.datasize;
    assign nextLatches_normal_mem_cs_ST_OP_i             = nextLatches_i.normal_latches.mem_cs.ST_OP;
    assign nextLatches_normal_mem_cs_LD_OP_i             = nextLatches_i.normal_latches.mem_cs.LD_OP;
    assign nextLatches_normal_exe_cs_ST_OP_i             = nextLatches_i.normal_latches.exe_cs.ST_OP;
    assign nextLatches_normal_exe_cs_OP_TYPE_i           = nextLatches_i.normal_latches.exe_cs.OP_TYPE;
    assign nextLatches_normal_exe_cs_alu_inputA_sel_i    = nextLatches_i.normal_latches.exe_cs.alu_inputA_sel;
    assign nextLatches_normal_exe_cs_alu_inputB_sel_i    = nextLatches_i.normal_latches.exe_cs.alu_inputB_sel;
    assign nextLatches_normal_exe_cs_branch_target_sel_i = nextLatches_i.normal_latches.exe_cs.branch_target_sel;
    assign nextLatches_normal_exe_cs_shift_by_one_i      = nextLatches_i.normal_latches.exe_cs.shift_by_one;
    assign nextLatches_normal_exe_cs_br_ucond_i          = nextLatches_i.normal_latches.exe_cs.br_ucond;
    assign nextLatches_normal_exe_cs_relative_branch_i   = nextLatches_i.normal_latches.exe_cs.relative_branch;
    assign nextLatches_normal_exe_cs_special_br_i        = nextLatches_i.normal_latches.exe_cs.special_br;
    assign nextLatches_normal_exe_cs_is_far_i            = nextLatches_i.normal_latches.exe_cs.is_far;
    assign nextLatches_normal_exe_cs_is_call_i           = nextLatches_i.normal_latches.exe_cs.is_call;
    assign nextLatches_normal_exe_cs_second_flag_needed_i= nextLatches_i.normal_latches.exe_cs.second_flag_needed;
    assign nextLatches_normal_exe_cs_rep_no_zf_update_i  = nextLatches_i.normal_latches.exe_cs.rep_no_zf_update;
    assign nextLatches_normal_wb_cs_ST_OP_i              = nextLatches_i.normal_latches.wb_cs.ST_OP;
    assign nextLatches_normal_wb_cs_WB_DR_i              = nextLatches_i.normal_latches.wb_cs.WB_DR;
    assign nextLatches_normal_wb_cs_WB_SR_i              = nextLatches_i.normal_latches.wb_cs.WB_SR;
    assign nextLatches_normal_wb_cs_WB_EAX_i             = nextLatches_i.normal_latches.wb_cs.WB_EAX;
    assign nextLatches_normal_br_info_valid_i            = nextLatches_i.normal_latches.br_info.valid;
    assign nextLatches_normal_br_info_br_eip_i           = nextLatches_i.normal_latches.br_info.br_eip;
    assign nextLatches_normal_br_info_br_xcl_i           = nextLatches_i.normal_latches.br_info.br_xcl;
    assign nextLatches_normal_br_info_br_pred_taken_i    = nextLatches_i.normal_latches.br_info.br_pred_taken;
    assign nextLatches_normal_br_info_speculative_target_i = nextLatches_i.normal_latches.br_info.speculative_target;
    assign nextLatches_normal_NEIP_i                     = nextLatches_i.normal_latches.NEIP;
    assign nextLatches_normal_EIP_i                      = nextLatches_i.normal_latches.EIP;
    assign nextLatches_normal_EAX_i                      = nextLatches_i.normal_latches.EAX;
    assign nextLatches_normal_imm64_i                    = nextLatches_i.normal_latches.imm64;
    assign nextLatches_normal_sib_idx_id_i               = nextLatches_i.normal_latches.sib_idx_id;
    assign nextLatches_normal_sib_base_id_i              = nextLatches_i.normal_latches.sib_base_id;
    assign nextLatches_normal_sib_needed_i               = nextLatches_i.normal_latches.sib_needed;
    assign nextLatches_normal_sib_scale_i                = nextLatches_i.normal_latches.sib_scale;
    assign nextLatches_normal_disp_needed_i              = nextLatches_i.normal_latches.disp_needed;
    assign nextLatches_normal_disp_size_i                = nextLatches_i.normal_latches.disp_size;
    assign nextLatches_normal_displacement_i             = nextLatches_i.normal_latches.displacement;

    // =====================================================================
    // ---- bridge SV struct fields -> alias wires (rep_latches) ----
    // =====================================================================
    assign nextLatches_rep_valid_i                       = nextLatches_i.rep_latches.valid;
    assign nextLatches_rep_cs_ST_SEL_i                   = nextLatches_i.rep_latches.cs.ST_SEL;
    assign nextLatches_rep_cs_MODRM_NEEDED_i             = nextLatches_i.rep_latches.cs.MODRM_NEEDED;
    assign nextLatches_rep_cs_RM_IS_DR_i                 = nextLatches_i.rep_latches.cs.RM_IS_DR;
    assign nextLatches_rep_cs_SWITCH_LD_ADDY_i           = nextLatches_i.rep_latches.cs.SWITCH_LD_ADDY;
    assign nextLatches_rep_cs_LD_OP_i                    = nextLatches_i.rep_latches.cs.LD_OP;
    assign nextLatches_rep_cs_ST_OP_i                    = nextLatches_i.rep_latches.cs.ST_OP;
    assign nextLatches_rep_cs_dr_id_i                    = nextLatches_i.rep_latches.cs.dr_id;
    assign nextLatches_rep_cs_sr_id_i                    = nextLatches_i.rep_latches.cs.sr_id;
    assign nextLatches_rep_cs_dr_rd_i                    = nextLatches_i.rep_latches.cs.dr_rd;
    assign nextLatches_rep_cs_sr_rd_i                    = nextLatches_i.rep_latches.cs.sr_rd;
    assign nextLatches_rep_cs_eax_rd_i                   = nextLatches_i.rep_latches.cs.eax_rd;
    assign nextLatches_rep_cs_dr_wr_i                    = nextLatches_i.rep_latches.cs.dr_wr;
    assign nextLatches_rep_cs_sr_wr_i                    = nextLatches_i.rep_latches.cs.sr_wr;
    assign nextLatches_rep_cs_eax_wr_i                   = nextLatches_i.rep_latches.cs.eax_wr;
    assign nextLatches_rep_cs_MOVS_OP_i                  = nextLatches_i.rep_latches.cs.MOVS_OP;
    assign nextLatches_rep_cs_datasize_i                 = nextLatches_i.rep_latches.cs.datasize;
    assign nextLatches_rep_cs_will_mod_zf_i              = nextLatches_i.rep_latches.cs.will_mod_zf;
    assign nextLatches_rep_cs_seg_1_valid_i              = nextLatches_i.rep_latches.cs.seg_1_valid;
    assign nextLatches_rep_cs_seg_0_id_i                 = nextLatches_i.rep_latches.cs.seg_0_id;
    assign nextLatches_rep_cs_seg_1_id_i                 = nextLatches_i.rep_latches.cs.seg_1_id;
    assign nextLatches_rep_cs_special_modrm_bs_i         = nextLatches_i.rep_latches.cs.special_modrm_bs;
    assign nextLatches_rep_cs_special_br_i               = nextLatches_i.rep_latches.cs.special_br;
    assign nextLatches_rep_dc_cs_LD_OP_i                 = nextLatches_i.rep_latches.dc_cs.LD_OP;
    assign nextLatches_rep_dc_cs_ST_OP_i                 = nextLatches_i.rep_latches.dc_cs.ST_OP;
    assign nextLatches_rep_dc_cs_dr_upper8_i             = nextLatches_i.rep_latches.dc_cs.dr_upper8;
    assign nextLatches_rep_dc_cs_sr_upper8_i             = nextLatches_i.rep_latches.dc_cs.sr_upper8;
    assign nextLatches_rep_dc_cs_datasize_i              = nextLatches_i.rep_latches.dc_cs.datasize;
    assign nextLatches_rep_mem_cs_ST_OP_i                = nextLatches_i.rep_latches.mem_cs.ST_OP;
    assign nextLatches_rep_mem_cs_LD_OP_i                = nextLatches_i.rep_latches.mem_cs.LD_OP;
    assign nextLatches_rep_exe_cs_ST_OP_i                = nextLatches_i.rep_latches.exe_cs.ST_OP;
    assign nextLatches_rep_exe_cs_OP_TYPE_i              = nextLatches_i.rep_latches.exe_cs.OP_TYPE;
    assign nextLatches_rep_exe_cs_alu_inputA_sel_i       = nextLatches_i.rep_latches.exe_cs.alu_inputA_sel;
    assign nextLatches_rep_exe_cs_alu_inputB_sel_i       = nextLatches_i.rep_latches.exe_cs.alu_inputB_sel;
    assign nextLatches_rep_exe_cs_branch_target_sel_i    = nextLatches_i.rep_latches.exe_cs.branch_target_sel;
    assign nextLatches_rep_exe_cs_shift_by_one_i         = nextLatches_i.rep_latches.exe_cs.shift_by_one;
    assign nextLatches_rep_exe_cs_br_ucond_i             = nextLatches_i.rep_latches.exe_cs.br_ucond;
    assign nextLatches_rep_exe_cs_relative_branch_i      = nextLatches_i.rep_latches.exe_cs.relative_branch;
    assign nextLatches_rep_exe_cs_special_br_i           = nextLatches_i.rep_latches.exe_cs.special_br;
    assign nextLatches_rep_exe_cs_is_far_i               = nextLatches_i.rep_latches.exe_cs.is_far;
    assign nextLatches_rep_exe_cs_is_call_i              = nextLatches_i.rep_latches.exe_cs.is_call;
    assign nextLatches_rep_exe_cs_second_flag_needed_i   = nextLatches_i.rep_latches.exe_cs.second_flag_needed;
    assign nextLatches_rep_exe_cs_rep_no_zf_update_i     = nextLatches_i.rep_latches.exe_cs.rep_no_zf_update;
    assign nextLatches_rep_wb_cs_ST_OP_i                 = nextLatches_i.rep_latches.wb_cs.ST_OP;
    assign nextLatches_rep_wb_cs_WB_DR_i                 = nextLatches_i.rep_latches.wb_cs.WB_DR;
    assign nextLatches_rep_wb_cs_WB_SR_i                 = nextLatches_i.rep_latches.wb_cs.WB_SR;
    assign nextLatches_rep_wb_cs_WB_EAX_i                = nextLatches_i.rep_latches.wb_cs.WB_EAX;
    assign nextLatches_rep_br_info_valid_i               = nextLatches_i.rep_latches.br_info.valid;
    assign nextLatches_rep_br_info_br_eip_i              = nextLatches_i.rep_latches.br_info.br_eip;
    assign nextLatches_rep_br_info_br_xcl_i              = nextLatches_i.rep_latches.br_info.br_xcl;
    assign nextLatches_rep_br_info_br_pred_taken_i       = nextLatches_i.rep_latches.br_info.br_pred_taken;
    assign nextLatches_rep_br_info_speculative_target_i  = nextLatches_i.rep_latches.br_info.speculative_target;
    assign nextLatches_rep_NEIP_i                        = nextLatches_i.rep_latches.NEIP;
    assign nextLatches_rep_EIP_i                         = nextLatches_i.rep_latches.EIP;
    assign nextLatches_rep_EAX_i                         = nextLatches_i.rep_latches.EAX;
    assign nextLatches_rep_imm64_i                       = nextLatches_i.rep_latches.imm64;
    assign nextLatches_rep_sib_idx_id_i                  = nextLatches_i.rep_latches.sib_idx_id;
    assign nextLatches_rep_sib_base_id_i                 = nextLatches_i.rep_latches.sib_base_id;
    assign nextLatches_rep_sib_needed_i                  = nextLatches_i.rep_latches.sib_needed;
    assign nextLatches_rep_sib_scale_i                   = nextLatches_i.rep_latches.sib_scale;
    assign nextLatches_rep_disp_needed_i                 = nextLatches_i.rep_latches.disp_needed;
    assign nextLatches_rep_disp_size_i                   = nextLatches_i.rep_latches.disp_size;
    assign nextLatches_rep_displacement_i                = nextLatches_i.rep_latches.displacement;

    // =====================================================================
    // ---- bridge alias wires -> SV struct fields (normal_latches) ----
    // =====================================================================
    assign latches_o.normal_latches.valid                    = latches_normal_valid_o;
    assign latches_o.normal_latches.cs.ST_SEL                = latches_normal_cs_ST_SEL_o;
    assign latches_o.normal_latches.cs.MODRM_NEEDED          = latches_normal_cs_MODRM_NEEDED_o;
    assign latches_o.normal_latches.cs.RM_IS_DR              = latches_normal_cs_RM_IS_DR_o;
    assign latches_o.normal_latches.cs.SWITCH_LD_ADDY        = latches_normal_cs_SWITCH_LD_ADDY_o;
    assign latches_o.normal_latches.cs.LD_OP                 = latches_normal_cs_LD_OP_o;
    assign latches_o.normal_latches.cs.ST_OP                 = latches_normal_cs_ST_OP_o;
    assign latches_o.normal_latches.cs.dr_id                 = reg_ids_e'(latches_normal_cs_dr_id_o);
    assign latches_o.normal_latches.cs.sr_id                 = reg_ids_e'(latches_normal_cs_sr_id_o);
    assign latches_o.normal_latches.cs.dr_rd                 = latches_normal_cs_dr_rd_o;
    assign latches_o.normal_latches.cs.sr_rd                 = latches_normal_cs_sr_rd_o;
    assign latches_o.normal_latches.cs.eax_rd                = latches_normal_cs_eax_rd_o;
    assign latches_o.normal_latches.cs.dr_wr                 = latches_normal_cs_dr_wr_o;
    assign latches_o.normal_latches.cs.sr_wr                 = latches_normal_cs_sr_wr_o;
    assign latches_o.normal_latches.cs.eax_wr                = latches_normal_cs_eax_wr_o;
    assign latches_o.normal_latches.cs.MOVS_OP               = latches_normal_cs_MOVS_OP_o;
    assign latches_o.normal_latches.cs.datasize              = latches_normal_cs_datasize_o;
    assign latches_o.normal_latches.cs.will_mod_zf           = latches_normal_cs_will_mod_zf_o;
    assign latches_o.normal_latches.cs.seg_1_valid           = latches_normal_cs_seg_1_valid_o;
    assign latches_o.normal_latches.cs.seg_0_id              = reg_ids_e'(latches_normal_cs_seg_0_id_o);
    assign latches_o.normal_latches.cs.seg_1_id              = reg_ids_e'(latches_normal_cs_seg_1_id_o);
    assign latches_o.normal_latches.cs.special_modrm_bs      = latches_normal_cs_special_modrm_bs_o;
    assign latches_o.normal_latches.cs.special_br            = latches_normal_cs_special_br_o;
    assign latches_o.normal_latches.dc_cs.LD_OP              = latches_normal_dc_cs_LD_OP_o;
    assign latches_o.normal_latches.dc_cs.ST_OP              = latches_normal_dc_cs_ST_OP_o;
    assign latches_o.normal_latches.dc_cs.dr_upper8          = latches_normal_dc_cs_dr_upper8_o;
    assign latches_o.normal_latches.dc_cs.sr_upper8          = latches_normal_dc_cs_sr_upper8_o;
    assign latches_o.normal_latches.dc_cs.datasize           = latches_normal_dc_cs_datasize_o;
    assign latches_o.normal_latches.mem_cs.ST_OP             = latches_normal_mem_cs_ST_OP_o;
    assign latches_o.normal_latches.mem_cs.LD_OP             = latches_normal_mem_cs_LD_OP_o;
    assign latches_o.normal_latches.exe_cs.ST_OP             = latches_normal_exe_cs_ST_OP_o;
    assign latches_o.normal_latches.exe_cs.OP_TYPE           = exe_cs_operation_type_e'(latches_normal_exe_cs_OP_TYPE_o);
    assign latches_o.normal_latches.exe_cs.alu_inputA_sel    = source_selector_e'(latches_normal_exe_cs_alu_inputA_sel_o);
    assign latches_o.normal_latches.exe_cs.alu_inputB_sel    = source_selector_e'(latches_normal_exe_cs_alu_inputB_sel_o);
    assign latches_o.normal_latches.exe_cs.branch_target_sel = source_selector_e'(latches_normal_exe_cs_branch_target_sel_o);
    assign latches_o.normal_latches.exe_cs.shift_by_one      = latches_normal_exe_cs_shift_by_one_o;
    assign latches_o.normal_latches.exe_cs.br_ucond          = latches_normal_exe_cs_br_ucond_o;
    assign latches_o.normal_latches.exe_cs.relative_branch   = latches_normal_exe_cs_relative_branch_o;
    assign latches_o.normal_latches.exe_cs.special_br        = latches_normal_exe_cs_special_br_o;
    assign latches_o.normal_latches.exe_cs.is_far            = latches_normal_exe_cs_is_far_o;
    assign latches_o.normal_latches.exe_cs.is_call           = latches_normal_exe_cs_is_call_o;
    assign latches_o.normal_latches.exe_cs.second_flag_needed= latches_normal_exe_cs_second_flag_needed_o;
    assign latches_o.normal_latches.exe_cs.rep_no_zf_update  = latches_normal_exe_cs_rep_no_zf_update_o;
    assign latches_o.normal_latches.wb_cs.ST_OP              = latches_normal_wb_cs_ST_OP_o;
    assign latches_o.normal_latches.wb_cs.WB_DR              = latches_normal_wb_cs_WB_DR_o;
    assign latches_o.normal_latches.wb_cs.WB_SR              = latches_normal_wb_cs_WB_SR_o;
    assign latches_o.normal_latches.wb_cs.WB_EAX             = latches_normal_wb_cs_WB_EAX_o;
    assign latches_o.normal_latches.br_info.valid            = latches_normal_br_info_valid_o;
    assign latches_o.normal_latches.br_info.br_eip           = latches_normal_br_info_br_eip_o;
    assign latches_o.normal_latches.br_info.br_xcl           = latches_normal_br_info_br_xcl_o;
    assign latches_o.normal_latches.br_info.br_pred_taken    = latches_normal_br_info_br_pred_taken_o;
    assign latches_o.normal_latches.br_info.speculative_target = latches_normal_br_info_speculative_target_o;
    assign latches_o.normal_latches.NEIP                     = latches_normal_NEIP_o;
    assign latches_o.normal_latches.EIP                      = latches_normal_EIP_o;
    assign latches_o.normal_latches.EAX                      = latches_normal_EAX_o;
    assign latches_o.normal_latches.imm64                    = latches_normal_imm64_o;
    assign latches_o.normal_latches.sib_idx_id               = reg_ids_e'(latches_normal_sib_idx_id_o);
    assign latches_o.normal_latches.sib_base_id              = reg_ids_e'(latches_normal_sib_base_id_o);
    assign latches_o.normal_latches.sib_needed               = latches_normal_sib_needed_o;
    assign latches_o.normal_latches.sib_scale                = latches_normal_sib_scale_o;
    assign latches_o.normal_latches.disp_needed              = latches_normal_disp_needed_o;
    assign latches_o.normal_latches.disp_size                = latches_normal_disp_size_o;
    assign latches_o.normal_latches.displacement             = latches_normal_displacement_o;

    // =====================================================================
    // ---- bridge alias wires -> SV struct fields (rep_latches) ----
    // =====================================================================
    assign latches_o.rep_latches.valid                       = latches_rep_valid_o;
    assign latches_o.rep_latches.cs.ST_SEL                   = latches_rep_cs_ST_SEL_o;
    assign latches_o.rep_latches.cs.MODRM_NEEDED             = latches_rep_cs_MODRM_NEEDED_o;
    assign latches_o.rep_latches.cs.RM_IS_DR                 = latches_rep_cs_RM_IS_DR_o;
    assign latches_o.rep_latches.cs.SWITCH_LD_ADDY           = latches_rep_cs_SWITCH_LD_ADDY_o;
    assign latches_o.rep_latches.cs.LD_OP                    = latches_rep_cs_LD_OP_o;
    assign latches_o.rep_latches.cs.ST_OP                    = latches_rep_cs_ST_OP_o;
    assign latches_o.rep_latches.cs.dr_id                    = reg_ids_e'(latches_rep_cs_dr_id_o);
    assign latches_o.rep_latches.cs.sr_id                    = reg_ids_e'(latches_rep_cs_sr_id_o);
    assign latches_o.rep_latches.cs.dr_rd                    = latches_rep_cs_dr_rd_o;
    assign latches_o.rep_latches.cs.sr_rd                    = latches_rep_cs_sr_rd_o;
    assign latches_o.rep_latches.cs.eax_rd                   = latches_rep_cs_eax_rd_o;
    assign latches_o.rep_latches.cs.dr_wr                    = latches_rep_cs_dr_wr_o;
    assign latches_o.rep_latches.cs.sr_wr                    = latches_rep_cs_sr_wr_o;
    assign latches_o.rep_latches.cs.eax_wr                   = latches_rep_cs_eax_wr_o;
    assign latches_o.rep_latches.cs.MOVS_OP                  = latches_rep_cs_MOVS_OP_o;
    assign latches_o.rep_latches.cs.datasize                 = latches_rep_cs_datasize_o;
    assign latches_o.rep_latches.cs.will_mod_zf              = latches_rep_cs_will_mod_zf_o;
    assign latches_o.rep_latches.cs.seg_1_valid              = latches_rep_cs_seg_1_valid_o;
    assign latches_o.rep_latches.cs.seg_0_id                 = reg_ids_e'(latches_rep_cs_seg_0_id_o);
    assign latches_o.rep_latches.cs.seg_1_id                 = reg_ids_e'(latches_rep_cs_seg_1_id_o);
    assign latches_o.rep_latches.cs.special_modrm_bs         = latches_rep_cs_special_modrm_bs_o;
    assign latches_o.rep_latches.cs.special_br               = latches_rep_cs_special_br_o;
    assign latches_o.rep_latches.dc_cs.LD_OP                 = latches_rep_dc_cs_LD_OP_o;
    assign latches_o.rep_latches.dc_cs.ST_OP                 = latches_rep_dc_cs_ST_OP_o;
    assign latches_o.rep_latches.dc_cs.dr_upper8             = latches_rep_dc_cs_dr_upper8_o;
    assign latches_o.rep_latches.dc_cs.sr_upper8             = latches_rep_dc_cs_sr_upper8_o;
    assign latches_o.rep_latches.dc_cs.datasize              = latches_rep_dc_cs_datasize_o;
    assign latches_o.rep_latches.mem_cs.ST_OP                = latches_rep_mem_cs_ST_OP_o;
    assign latches_o.rep_latches.mem_cs.LD_OP                = latches_rep_mem_cs_LD_OP_o;
    assign latches_o.rep_latches.exe_cs.ST_OP                = latches_rep_exe_cs_ST_OP_o;
    assign latches_o.rep_latches.exe_cs.OP_TYPE              = exe_cs_operation_type_e'(latches_rep_exe_cs_OP_TYPE_o);
    assign latches_o.rep_latches.exe_cs.alu_inputA_sel       = source_selector_e'(latches_rep_exe_cs_alu_inputA_sel_o);
    assign latches_o.rep_latches.exe_cs.alu_inputB_sel       = source_selector_e'(latches_rep_exe_cs_alu_inputB_sel_o);
    assign latches_o.rep_latches.exe_cs.branch_target_sel    = source_selector_e'(latches_rep_exe_cs_branch_target_sel_o);
    assign latches_o.rep_latches.exe_cs.shift_by_one         = latches_rep_exe_cs_shift_by_one_o;
    assign latches_o.rep_latches.exe_cs.br_ucond             = latches_rep_exe_cs_br_ucond_o;
    assign latches_o.rep_latches.exe_cs.relative_branch      = latches_rep_exe_cs_relative_branch_o;
    assign latches_o.rep_latches.exe_cs.special_br           = latches_rep_exe_cs_special_br_o;
    assign latches_o.rep_latches.exe_cs.is_far               = latches_rep_exe_cs_is_far_o;
    assign latches_o.rep_latches.exe_cs.is_call              = latches_rep_exe_cs_is_call_o;
    assign latches_o.rep_latches.exe_cs.second_flag_needed   = latches_rep_exe_cs_second_flag_needed_o;
    assign latches_o.rep_latches.exe_cs.rep_no_zf_update     = latches_rep_exe_cs_rep_no_zf_update_o;
    assign latches_o.rep_latches.wb_cs.ST_OP                 = latches_rep_wb_cs_ST_OP_o;
    assign latches_o.rep_latches.wb_cs.WB_DR                 = latches_rep_wb_cs_WB_DR_o;
    assign latches_o.rep_latches.wb_cs.WB_SR                 = latches_rep_wb_cs_WB_SR_o;
    assign latches_o.rep_latches.wb_cs.WB_EAX                = latches_rep_wb_cs_WB_EAX_o;
    assign latches_o.rep_latches.br_info.valid               = latches_rep_br_info_valid_o;
    assign latches_o.rep_latches.br_info.br_eip              = latches_rep_br_info_br_eip_o;
    assign latches_o.rep_latches.br_info.br_xcl              = latches_rep_br_info_br_xcl_o;
    assign latches_o.rep_latches.br_info.br_pred_taken       = latches_rep_br_info_br_pred_taken_o;
    assign latches_o.rep_latches.br_info.speculative_target  = latches_rep_br_info_speculative_target_o;
    assign latches_o.rep_latches.NEIP                        = latches_rep_NEIP_o;
    assign latches_o.rep_latches.EIP                         = latches_rep_EIP_o;
    assign latches_o.rep_latches.EAX                         = latches_rep_EAX_o;
    assign latches_o.rep_latches.imm64                       = latches_rep_imm64_o;
    assign latches_o.rep_latches.sib_idx_id                  = reg_ids_e'(latches_rep_sib_idx_id_o);
    assign latches_o.rep_latches.sib_base_id                 = reg_ids_e'(latches_rep_sib_base_id_o);
    assign latches_o.rep_latches.sib_needed                  = latches_rep_sib_needed_o;
    assign latches_o.rep_latches.sib_scale                   = latches_rep_sib_scale_o;
    assign latches_o.rep_latches.disp_needed                 = latches_rep_disp_needed_o;
    assign latches_o.rep_latches.disp_size                   = latches_rep_disp_size_o;
    assign latches_o.rep_latches.displacement                = latches_rep_displacement_o;

`endif

    // ============================================================
    // Combined flush + effective WE
    //   combined_flush = flush  OR farFlush  OR exp_pipe_clear
    //   effective_we   = write_enable_i OR combined_flush
    // ============================================================

    wire combined_flush;
    wire effective_we;

    `OR_2(u_rr_combined_flush, 1, combined_flush, flush, exp_pipe_clear);
    `OR_2(u_rr_effective_we,   1, effective_we,  write_enable_i,   combined_flush);

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
    wire [31:0] normal_exe_cs_OP_TYPE_d;
    wire [31:0] normal_exe_cs_alu_inputA_sel_d;
    wire [31:0] normal_exe_cs_alu_inputB_sel_d;
    wire [31:0] normal_exe_cs_branch_target_sel_d;
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
    wire [31:0] rep_exe_cs_OP_TYPE_d;
    wire [31:0] rep_exe_cs_alu_inputA_sel_d;
    wire [31:0] rep_exe_cs_alu_inputB_sel_d;
    wire [31:0] rep_exe_cs_branch_target_sel_d;
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

    `MUX_2(u_rr_mux_normal_cs_ST_SEL,                      1,   normal_cs_ST_SEL_d,                nextLatches_normal_cs_ST_SEL_i,                1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_cs_MODRM_NEEDED,                1,   normal_cs_MODRM_NEEDED_d,          nextLatches_normal_cs_MODRM_NEEDED_i,          1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_cs_RM_IS_DR,                    1,   normal_cs_RM_IS_DR_d,              nextLatches_normal_cs_RM_IS_DR_i,              1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_cs_SWITCH_LD_ADDY,              1,   normal_cs_SWITCH_LD_ADDY_d,        nextLatches_normal_cs_SWITCH_LD_ADDY_i,        1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_cs_LD_OP,                       1,   normal_cs_LD_OP_d,                 nextLatches_normal_cs_LD_OP_i,                 1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_cs_ST_OP,                       1,   normal_cs_ST_OP_d,                 nextLatches_normal_cs_ST_OP_i,                 1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_cs_dr_id,                       5,   normal_cs_dr_id_d,                 nextLatches_normal_cs_dr_id_i,                 5'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_cs_sr_id,                       5,   normal_cs_sr_id_d,                 nextLatches_normal_cs_sr_id_i,                 5'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_cs_dr_rd,                       1,   normal_cs_dr_rd_d,                 nextLatches_normal_cs_dr_rd_i,                 1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_cs_sr_rd,                       1,   normal_cs_sr_rd_d,                 nextLatches_normal_cs_sr_rd_i,                 1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_cs_eax_rd,                      1,   normal_cs_eax_rd_d,                nextLatches_normal_cs_eax_rd_i,                1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_cs_dr_wr,                       1,   normal_cs_dr_wr_d,                 nextLatches_normal_cs_dr_wr_i,                 1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_cs_sr_wr,                       1,   normal_cs_sr_wr_d,                 nextLatches_normal_cs_sr_wr_i,                 1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_cs_eax_wr,                      1,   normal_cs_eax_wr_d,                nextLatches_normal_cs_eax_wr_i,                1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_cs_MOVS_OP,                     1,   normal_cs_MOVS_OP_d,               nextLatches_normal_cs_MOVS_OP_i,               1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_cs_datasize,                    2,   normal_cs_datasize_d,              nextLatches_normal_cs_datasize_i,              2'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_cs_will_mod_zf,                 1,   normal_cs_will_mod_zf_d,           nextLatches_normal_cs_will_mod_zf_i,           1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_cs_seg_1_valid,                 1,   normal_cs_seg_1_valid_d,           nextLatches_normal_cs_seg_1_valid_i,           1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_cs_seg_0_id,                    5,   normal_cs_seg_0_id_d,              nextLatches_normal_cs_seg_0_id_i,              5'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_cs_seg_1_id,                    5,   normal_cs_seg_1_id_d,              nextLatches_normal_cs_seg_1_id_i,              5'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_cs_special_modrm_bs,            1,   normal_cs_special_modrm_bs_d,      nextLatches_normal_cs_special_modrm_bs_i,      1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_cs_special_br,                  1,   normal_cs_special_br_d,            nextLatches_normal_cs_special_br_i,            1'b0,    combined_flush);

    `MUX_2(u_rr_mux_normal_dc_cs_LD_OP,                    1,   normal_dc_cs_LD_OP_d,              nextLatches_normal_dc_cs_LD_OP_i,              1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_dc_cs_ST_OP,                    1,   normal_dc_cs_ST_OP_d,              nextLatches_normal_dc_cs_ST_OP_i,              1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_dc_cs_dr_upper8,                1,   normal_dc_cs_dr_upper8_d,          nextLatches_normal_dc_cs_dr_upper8_i,          1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_dc_cs_sr_upper8,                1,   normal_dc_cs_sr_upper8_d,          nextLatches_normal_dc_cs_sr_upper8_i,          1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_dc_cs_datasize,                 2,   normal_dc_cs_datasize_d,           nextLatches_normal_dc_cs_datasize_i,           2'b0,    combined_flush);

    `MUX_2(u_rr_mux_normal_mem_cs_ST_OP,                   1,   normal_mem_cs_ST_OP_d,             nextLatches_normal_mem_cs_ST_OP_i,             1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_mem_cs_LD_OP,                   1,   normal_mem_cs_LD_OP_d,             nextLatches_normal_mem_cs_LD_OP_i,             1'b0,    combined_flush);

    `MUX_2(u_rr_mux_normal_exe_cs_ST_OP,                   1,   normal_exe_cs_ST_OP_d,             nextLatches_normal_exe_cs_ST_OP_i,             1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_exe_cs_OP_TYPE,                 32,  normal_exe_cs_OP_TYPE_d,           nextLatches_normal_exe_cs_OP_TYPE_i,           32'b0,   combined_flush);
    `MUX_2(u_rr_mux_normal_exe_cs_alu_inputA_sel,          32,  normal_exe_cs_alu_inputA_sel_d,    nextLatches_normal_exe_cs_alu_inputA_sel_i,    32'b0,   combined_flush);
    `MUX_2(u_rr_mux_normal_exe_cs_alu_inputB_sel,          32,  normal_exe_cs_alu_inputB_sel_d,    nextLatches_normal_exe_cs_alu_inputB_sel_i,    32'b0,   combined_flush);
    `MUX_2(u_rr_mux_normal_exe_cs_branch_target_sel,       32,  normal_exe_cs_branch_target_sel_d, nextLatches_normal_exe_cs_branch_target_sel_i, 32'b0,   combined_flush);
    `MUX_2(u_rr_mux_normal_exe_cs_shift_by_one,            1,   normal_exe_cs_shift_by_one_d,      nextLatches_normal_exe_cs_shift_by_one_i,      1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_exe_cs_br_ucond,                1,   normal_exe_cs_br_ucond_d,          nextLatches_normal_exe_cs_br_ucond_i,          1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_exe_cs_relative_branch,         1,   normal_exe_cs_relative_branch_d,   nextLatches_normal_exe_cs_relative_branch_i,   1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_exe_cs_special_br,              1,   normal_exe_cs_special_br_d,        nextLatches_normal_exe_cs_special_br_i,        1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_exe_cs_is_far,                  1,   normal_exe_cs_is_far_d,            nextLatches_normal_exe_cs_is_far_i,            1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_exe_cs_is_call,                 1,   normal_exe_cs_is_call_d,           nextLatches_normal_exe_cs_is_call_i,           1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_exe_cs_second_flag_needed,      1,   normal_exe_cs_second_flag_needed_d,nextLatches_normal_exe_cs_second_flag_needed_i,1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_exe_cs_rep_no_zf_update,        1,   normal_exe_cs_rep_no_zf_update_d,  nextLatches_normal_exe_cs_rep_no_zf_update_i,  1'b0,    combined_flush);

    `MUX_2(u_rr_mux_normal_wb_cs_ST_OP,                    1,   normal_wb_cs_ST_OP_d,              nextLatches_normal_wb_cs_ST_OP_i,              1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_wb_cs_WB_DR,                    1,   normal_wb_cs_WB_DR_d,              nextLatches_normal_wb_cs_WB_DR_i,              1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_wb_cs_WB_SR,                    1,   normal_wb_cs_WB_SR_d,              nextLatches_normal_wb_cs_WB_SR_i,              1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_wb_cs_WB_EAX,                   1,   normal_wb_cs_WB_EAX_d,             nextLatches_normal_wb_cs_WB_EAX_i,             1'b0,    combined_flush);

    `MUX_2(u_rr_mux_normal_br_info_valid,                  1,   normal_br_info_valid_d,            nextLatches_normal_br_info_valid_i,            1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_br_info_br_eip,                 32,  normal_br_info_br_eip_d,           nextLatches_normal_br_info_br_eip_i,           32'b0,   combined_flush);
    `MUX_2(u_rr_mux_normal_br_info_br_xcl,                 1,   normal_br_info_br_xcl_d,           nextLatches_normal_br_info_br_xcl_i,           1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_br_info_br_pred_taken,          1,   normal_br_info_br_pred_taken_d,    nextLatches_normal_br_info_br_pred_taken_i,    1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_br_info_speculative_target,     32,  normal_br_info_speculative_target_d, nextLatches_normal_br_info_speculative_target_i, 32'b0, combined_flush);

    `MUX_2(u_rr_mux_normal_NEIP,                           32,  normal_NEIP_d,                     nextLatches_normal_NEIP_i,                     32'b0,   combined_flush);
    `MUX_2(u_rr_mux_normal_EIP,                            32,  normal_EIP_d,                      nextLatches_normal_EIP_i,                      32'b0,   combined_flush);
    `MUX_2(u_rr_mux_normal_EAX,                            32,  normal_EAX_d,                      nextLatches_normal_EAX_i,                      32'b0,   combined_flush);
    `MUX_2(u_rr_mux_normal_imm64,                          64,  normal_imm64_d,                    nextLatches_normal_imm64_i,                    64'b0,   combined_flush);
    `MUX_2(u_rr_mux_normal_sib_idx_id,                     5,   normal_sib_idx_id_d,               nextLatches_normal_sib_idx_id_i,               5'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_sib_base_id,                    5,   normal_sib_base_id_d,              nextLatches_normal_sib_base_id_i,              5'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_sib_needed,                     1,   normal_sib_needed_d,               nextLatches_normal_sib_needed_i,               1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_sib_scale,                      8,   normal_sib_scale_d,                nextLatches_normal_sib_scale_i,                8'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_disp_needed,                    1,   normal_disp_needed_d,              nextLatches_normal_disp_needed_i,              1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_disp_size,                      1,   normal_disp_size_d,                nextLatches_normal_disp_size_i,                1'b0,    combined_flush);
    `MUX_2(u_rr_mux_normal_displacement,                   32,  normal_displacement_d,             nextLatches_normal_displacement_i,             32'b0,   combined_flush);

    // ============================================================
    // -------- rep_ flush MUXes (sel = combined_flush) --------
    // ============================================================

    `MUX_2(u_rr_mux_rep_valid,                             1,   rep_valid_d,                       nextLatches_rep_valid_i,                       1'b0,    combined_flush);

    `MUX_2(u_rr_mux_rep_cs_ST_SEL,                         1,   rep_cs_ST_SEL_d,                   nextLatches_rep_cs_ST_SEL_i,                   1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_cs_MODRM_NEEDED,                   1,   rep_cs_MODRM_NEEDED_d,             nextLatches_rep_cs_MODRM_NEEDED_i,             1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_cs_RM_IS_DR,                       1,   rep_cs_RM_IS_DR_d,                 nextLatches_rep_cs_RM_IS_DR_i,                 1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_cs_SWITCH_LD_ADDY,                 1,   rep_cs_SWITCH_LD_ADDY_d,           nextLatches_rep_cs_SWITCH_LD_ADDY_i,           1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_cs_LD_OP,                          1,   rep_cs_LD_OP_d,                    nextLatches_rep_cs_LD_OP_i,                    1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_cs_ST_OP,                          1,   rep_cs_ST_OP_d,                    nextLatches_rep_cs_ST_OP_i,                    1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_cs_dr_id,                          5,   rep_cs_dr_id_d,                    nextLatches_rep_cs_dr_id_i,                    5'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_cs_sr_id,                          5,   rep_cs_sr_id_d,                    nextLatches_rep_cs_sr_id_i,                    5'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_cs_dr_rd,                          1,   rep_cs_dr_rd_d,                    nextLatches_rep_cs_dr_rd_i,                    1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_cs_sr_rd,                          1,   rep_cs_sr_rd_d,                    nextLatches_rep_cs_sr_rd_i,                    1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_cs_eax_rd,                         1,   rep_cs_eax_rd_d,                   nextLatches_rep_cs_eax_rd_i,                   1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_cs_dr_wr,                          1,   rep_cs_dr_wr_d,                    nextLatches_rep_cs_dr_wr_i,                    1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_cs_sr_wr,                          1,   rep_cs_sr_wr_d,                    nextLatches_rep_cs_sr_wr_i,                    1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_cs_eax_wr,                         1,   rep_cs_eax_wr_d,                   nextLatches_rep_cs_eax_wr_i,                   1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_cs_MOVS_OP,                        1,   rep_cs_MOVS_OP_d,                  nextLatches_rep_cs_MOVS_OP_i,                  1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_cs_datasize,                       2,   rep_cs_datasize_d,                 nextLatches_rep_cs_datasize_i,                 2'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_cs_will_mod_zf,                    1,   rep_cs_will_mod_zf_d,              nextLatches_rep_cs_will_mod_zf_i,              1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_cs_seg_1_valid,                    1,   rep_cs_seg_1_valid_d,              nextLatches_rep_cs_seg_1_valid_i,              1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_cs_seg_0_id,                       5,   rep_cs_seg_0_id_d,                 nextLatches_rep_cs_seg_0_id_i,                 5'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_cs_seg_1_id,                       5,   rep_cs_seg_1_id_d,                 nextLatches_rep_cs_seg_1_id_i,                 5'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_cs_special_modrm_bs,               1,   rep_cs_special_modrm_bs_d,         nextLatches_rep_cs_special_modrm_bs_i,         1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_cs_special_br,                     1,   rep_cs_special_br_d,               nextLatches_rep_cs_special_br_i,               1'b0,    combined_flush);

    `MUX_2(u_rr_mux_rep_dc_cs_LD_OP,                       1,   rep_dc_cs_LD_OP_d,                 nextLatches_rep_dc_cs_LD_OP_i,                 1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_dc_cs_ST_OP,                       1,   rep_dc_cs_ST_OP_d,                 nextLatches_rep_dc_cs_ST_OP_i,                 1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_dc_cs_dr_upper8,                   1,   rep_dc_cs_dr_upper8_d,             nextLatches_rep_dc_cs_dr_upper8_i,             1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_dc_cs_sr_upper8,                   1,   rep_dc_cs_sr_upper8_d,             nextLatches_rep_dc_cs_sr_upper8_i,             1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_dc_cs_datasize,                    2,   rep_dc_cs_datasize_d,              nextLatches_rep_dc_cs_datasize_i,              2'b0,    combined_flush);

    `MUX_2(u_rr_mux_rep_mem_cs_ST_OP,                      1,   rep_mem_cs_ST_OP_d,                nextLatches_rep_mem_cs_ST_OP_i,                1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_mem_cs_LD_OP,                      1,   rep_mem_cs_LD_OP_d,                nextLatches_rep_mem_cs_LD_OP_i,                1'b0,    combined_flush);

    `MUX_2(u_rr_mux_rep_exe_cs_ST_OP,                      1,   rep_exe_cs_ST_OP_d,                nextLatches_rep_exe_cs_ST_OP_i,                1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_exe_cs_OP_TYPE,                    32,  rep_exe_cs_OP_TYPE_d,              nextLatches_rep_exe_cs_OP_TYPE_i,              32'b0,   combined_flush);
    `MUX_2(u_rr_mux_rep_exe_cs_alu_inputA_sel,             32,  rep_exe_cs_alu_inputA_sel_d,       nextLatches_rep_exe_cs_alu_inputA_sel_i,       32'b0,   combined_flush);
    `MUX_2(u_rr_mux_rep_exe_cs_alu_inputB_sel,             32,  rep_exe_cs_alu_inputB_sel_d,       nextLatches_rep_exe_cs_alu_inputB_sel_i,       32'b0,   combined_flush);
    `MUX_2(u_rr_mux_rep_exe_cs_branch_target_sel,          32,  rep_exe_cs_branch_target_sel_d,    nextLatches_rep_exe_cs_branch_target_sel_i,    32'b0,   combined_flush);
    `MUX_2(u_rr_mux_rep_exe_cs_shift_by_one,               1,   rep_exe_cs_shift_by_one_d,         nextLatches_rep_exe_cs_shift_by_one_i,         1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_exe_cs_br_ucond,                   1,   rep_exe_cs_br_ucond_d,             nextLatches_rep_exe_cs_br_ucond_i,             1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_exe_cs_relative_branch,            1,   rep_exe_cs_relative_branch_d,      nextLatches_rep_exe_cs_relative_branch_i,      1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_exe_cs_special_br,                 1,   rep_exe_cs_special_br_d,           nextLatches_rep_exe_cs_special_br_i,           1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_exe_cs_is_far,                     1,   rep_exe_cs_is_far_d,               nextLatches_rep_exe_cs_is_far_i,               1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_exe_cs_is_call,                    1,   rep_exe_cs_is_call_d,              nextLatches_rep_exe_cs_is_call_i,              1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_exe_cs_second_flag_needed,         1,   rep_exe_cs_second_flag_needed_d,   nextLatches_rep_exe_cs_second_flag_needed_i,   1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_exe_cs_rep_no_zf_update,           1,   rep_exe_cs_rep_no_zf_update_d,     nextLatches_rep_exe_cs_rep_no_zf_update_i,     1'b0,    combined_flush);

    `MUX_2(u_rr_mux_rep_wb_cs_ST_OP,                       1,   rep_wb_cs_ST_OP_d,                 nextLatches_rep_wb_cs_ST_OP_i,                 1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_wb_cs_WB_DR,                       1,   rep_wb_cs_WB_DR_d,                 nextLatches_rep_wb_cs_WB_DR_i,                 1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_wb_cs_WB_SR,                       1,   rep_wb_cs_WB_SR_d,                 nextLatches_rep_wb_cs_WB_SR_i,                 1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_wb_cs_WB_EAX,                      1,   rep_wb_cs_WB_EAX_d,                nextLatches_rep_wb_cs_WB_EAX_i,                1'b0,    combined_flush);

    `MUX_2(u_rr_mux_rep_br_info_valid,                     1,   rep_br_info_valid_d,               nextLatches_rep_br_info_valid_i,               1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_br_info_br_eip,                    32,  rep_br_info_br_eip_d,              nextLatches_rep_br_info_br_eip_i,              32'b0,   combined_flush);
    `MUX_2(u_rr_mux_rep_br_info_br_xcl,                    1,   rep_br_info_br_xcl_d,              nextLatches_rep_br_info_br_xcl_i,              1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_br_info_br_pred_taken,             1,   rep_br_info_br_pred_taken_d,       nextLatches_rep_br_info_br_pred_taken_i,       1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_br_info_speculative_target,        32,  rep_br_info_speculative_target_d,  nextLatches_rep_br_info_speculative_target_i,  32'b0,   combined_flush);

    `MUX_2(u_rr_mux_rep_NEIP,                              32,  rep_NEIP_d,                        nextLatches_rep_NEIP_i,                        32'b0,   combined_flush);
    `MUX_2(u_rr_mux_rep_EIP,                               32,  rep_EIP_d,                         nextLatches_rep_EIP_i,                         32'b0,   combined_flush);
    `MUX_2(u_rr_mux_rep_EAX,                               32,  rep_EAX_d,                         nextLatches_rep_EAX_i,                         32'b0,   combined_flush);
    `MUX_2(u_rr_mux_rep_imm64,                             64,  rep_imm64_d,                       nextLatches_rep_imm64_i,                       64'b0,   combined_flush);
    `MUX_2(u_rr_mux_rep_sib_idx_id,                        5,   rep_sib_idx_id_d,                  nextLatches_rep_sib_idx_id_i,                  5'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_sib_base_id,                       5,   rep_sib_base_id_d,                 nextLatches_rep_sib_base_id_i,                 5'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_sib_needed,                        1,   rep_sib_needed_d,                  nextLatches_rep_sib_needed_i,                  1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_sib_scale,                         8,   rep_sib_scale_d,                   nextLatches_rep_sib_scale_i,                   8'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_disp_needed,                       1,   rep_disp_needed_d,                 nextLatches_rep_disp_needed_i,                 1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_disp_size,                         1,   rep_disp_size_d,                   nextLatches_rep_disp_size_i,                   1'b0,    combined_flush);
    `MUX_2(u_rr_mux_rep_displacement,                      32,  rep_displacement_d,                nextLatches_rep_displacement_i,                32'b0,   combined_flush);

    // ============================================================
    // REG_RST_WE per field (we = effective_we)
    // ============================================================

    // -------- normal_ registers --------
    `REG_RST_WE(rr_latches_normal_valid,                          1,   clk, rst, effective_we, normal_valid_d,                          latches_normal_valid_o);

    `REG_RST_WE(rr_latches_normal_cs_ST_SEL,                      1,   clk, rst, effective_we, normal_cs_ST_SEL_d,                      latches_normal_cs_ST_SEL_o);
    `REG_RST_WE(rr_latches_normal_cs_MODRM_NEEDED,                1,   clk, rst, effective_we, normal_cs_MODRM_NEEDED_d,                latches_normal_cs_MODRM_NEEDED_o);
    `REG_RST_WE(rr_latches_normal_cs_RM_IS_DR,                    1,   clk, rst, effective_we, normal_cs_RM_IS_DR_d,                    latches_normal_cs_RM_IS_DR_o);
    `REG_RST_WE(rr_latches_normal_cs_SWITCH_LD_ADDY,              1,   clk, rst, effective_we, normal_cs_SWITCH_LD_ADDY_d,              latches_normal_cs_SWITCH_LD_ADDY_o);
    `REG_RST_WE(rr_latches_normal_cs_LD_OP,                       1,   clk, rst, effective_we, normal_cs_LD_OP_d,                       latches_normal_cs_LD_OP_o);
    `REG_RST_WE(rr_latches_normal_cs_ST_OP,                       1,   clk, rst, effective_we, normal_cs_ST_OP_d,                       latches_normal_cs_ST_OP_o);
    `REG_RST_WE(rr_latches_normal_cs_dr_id,                       5,   clk, rst, effective_we, normal_cs_dr_id_d,                       latches_normal_cs_dr_id_o);
    `REG_RST_WE(rr_latches_normal_cs_sr_id,                       5,   clk, rst, effective_we, normal_cs_sr_id_d,                       latches_normal_cs_sr_id_o);
    `REG_RST_WE(rr_latches_normal_cs_dr_rd,                       1,   clk, rst, effective_we, normal_cs_dr_rd_d,                       latches_normal_cs_dr_rd_o);
    `REG_RST_WE(rr_latches_normal_cs_sr_rd,                       1,   clk, rst, effective_we, normal_cs_sr_rd_d,                       latches_normal_cs_sr_rd_o);
    `REG_RST_WE(rr_latches_normal_cs_eax_rd,                      1,   clk, rst, effective_we, normal_cs_eax_rd_d,                      latches_normal_cs_eax_rd_o);
    `REG_RST_WE(rr_latches_normal_cs_dr_wr,                       1,   clk, rst, effective_we, normal_cs_dr_wr_d,                       latches_normal_cs_dr_wr_o);
    `REG_RST_WE(rr_latches_normal_cs_sr_wr,                       1,   clk, rst, effective_we, normal_cs_sr_wr_d,                       latches_normal_cs_sr_wr_o);
    `REG_RST_WE(rr_latches_normal_cs_eax_wr,                      1,   clk, rst, effective_we, normal_cs_eax_wr_d,                      latches_normal_cs_eax_wr_o);
    `REG_RST_WE(rr_latches_normal_cs_MOVS_OP,                     1,   clk, rst, effective_we, normal_cs_MOVS_OP_d,                     latches_normal_cs_MOVS_OP_o);
    `REG_RST_WE(rr_latches_normal_cs_datasize,                    2,   clk, rst, effective_we, normal_cs_datasize_d,                    latches_normal_cs_datasize_o);
    `REG_RST_WE(rr_latches_normal_cs_will_mod_zf,                 1,   clk, rst, effective_we, normal_cs_will_mod_zf_d,                 latches_normal_cs_will_mod_zf_o);
    `REG_RST_WE(rr_latches_normal_cs_seg_1_valid,                 1,   clk, rst, effective_we, normal_cs_seg_1_valid_d,                 latches_normal_cs_seg_1_valid_o);
    `REG_RST_WE(rr_latches_normal_cs_seg_0_id,                    5,   clk, rst, effective_we, normal_cs_seg_0_id_d,                    latches_normal_cs_seg_0_id_o);
    `REG_RST_WE(rr_latches_normal_cs_seg_1_id,                    5,   clk, rst, effective_we, normal_cs_seg_1_id_d,                    latches_normal_cs_seg_1_id_o);
    `REG_RST_WE(rr_latches_normal_cs_special_modrm_bs,            1,   clk, rst, effective_we, normal_cs_special_modrm_bs_d,            latches_normal_cs_special_modrm_bs_o);
    `REG_RST_WE(rr_latches_normal_cs_special_br,                  1,   clk, rst, effective_we, normal_cs_special_br_d,                  latches_normal_cs_special_br_o);

    `REG_RST_WE(rr_latches_normal_dc_cs_LD_OP,                    1,   clk, rst, effective_we, normal_dc_cs_LD_OP_d,                    latches_normal_dc_cs_LD_OP_o);
    `REG_RST_WE(rr_latches_normal_dc_cs_ST_OP,                    1,   clk, rst, effective_we, normal_dc_cs_ST_OP_d,                    latches_normal_dc_cs_ST_OP_o);
    `REG_RST_WE(rr_latches_normal_dc_cs_dr_upper8,                1,   clk, rst, effective_we, normal_dc_cs_dr_upper8_d,                latches_normal_dc_cs_dr_upper8_o);
    `REG_RST_WE(rr_latches_normal_dc_cs_sr_upper8,                1,   clk, rst, effective_we, normal_dc_cs_sr_upper8_d,                latches_normal_dc_cs_sr_upper8_o);
    `REG_RST_WE(rr_latches_normal_dc_cs_datasize,                 2,   clk, rst, effective_we, normal_dc_cs_datasize_d,                 latches_normal_dc_cs_datasize_o);

    `REG_RST_WE(rr_latches_normal_mem_cs_ST_OP,                   1,   clk, rst, effective_we, normal_mem_cs_ST_OP_d,                   latches_normal_mem_cs_ST_OP_o);
    `REG_RST_WE(rr_latches_normal_mem_cs_LD_OP,                   1,   clk, rst, effective_we, normal_mem_cs_LD_OP_d,                   latches_normal_mem_cs_LD_OP_o);

    `REG_RST_WE(rr_latches_normal_exe_cs_ST_OP,                   1,   clk, rst, effective_we, normal_exe_cs_ST_OP_d,                   latches_normal_exe_cs_ST_OP_o);
    `REG_RST_WE(rr_latches_normal_exe_cs_OP_TYPE,                 32,  clk, rst, effective_we, normal_exe_cs_OP_TYPE_d,                 latches_normal_exe_cs_OP_TYPE_o);
    `REG_RST_WE(rr_latches_normal_exe_cs_alu_inputA_sel,          32,  clk, rst, effective_we, normal_exe_cs_alu_inputA_sel_d,          latches_normal_exe_cs_alu_inputA_sel_o);
    `REG_RST_WE(rr_latches_normal_exe_cs_alu_inputB_sel,          32,  clk, rst, effective_we, normal_exe_cs_alu_inputB_sel_d,          latches_normal_exe_cs_alu_inputB_sel_o);
    `REG_RST_WE(rr_latches_normal_exe_cs_branch_target_sel,       32,  clk, rst, effective_we, normal_exe_cs_branch_target_sel_d,       latches_normal_exe_cs_branch_target_sel_o);
    `REG_RST_WE(rr_latches_normal_exe_cs_shift_by_one,            1,   clk, rst, effective_we, normal_exe_cs_shift_by_one_d,            latches_normal_exe_cs_shift_by_one_o);
    `REG_RST_WE(rr_latches_normal_exe_cs_br_ucond,                1,   clk, rst, effective_we, normal_exe_cs_br_ucond_d,                latches_normal_exe_cs_br_ucond_o);
    `REG_RST_WE(rr_latches_normal_exe_cs_relative_branch,         1,   clk, rst, effective_we, normal_exe_cs_relative_branch_d,         latches_normal_exe_cs_relative_branch_o);
    `REG_RST_WE(rr_latches_normal_exe_cs_special_br,              1,   clk, rst, effective_we, normal_exe_cs_special_br_d,              latches_normal_exe_cs_special_br_o);
    `REG_RST_WE(rr_latches_normal_exe_cs_is_far,                  1,   clk, rst, effective_we, normal_exe_cs_is_far_d,                  latches_normal_exe_cs_is_far_o);
    `REG_RST_WE(rr_latches_normal_exe_cs_is_call,                 1,   clk, rst, effective_we, normal_exe_cs_is_call_d,                 latches_normal_exe_cs_is_call_o);
    `REG_RST_WE(rr_latches_normal_exe_cs_second_flag_needed,      1,   clk, rst, effective_we, normal_exe_cs_second_flag_needed_d,      latches_normal_exe_cs_second_flag_needed_o);
    `REG_RST_WE(rr_latches_normal_exe_cs_rep_no_zf_update,        1,   clk, rst, effective_we, normal_exe_cs_rep_no_zf_update_d,        latches_normal_exe_cs_rep_no_zf_update_o);

    `REG_RST_WE(rr_latches_normal_wb_cs_ST_OP,                    1,   clk, rst, effective_we, normal_wb_cs_ST_OP_d,                    latches_normal_wb_cs_ST_OP_o);
    `REG_RST_WE(rr_latches_normal_wb_cs_WB_DR,                    1,   clk, rst, effective_we, normal_wb_cs_WB_DR_d,                    latches_normal_wb_cs_WB_DR_o);
    `REG_RST_WE(rr_latches_normal_wb_cs_WB_SR,                    1,   clk, rst, effective_we, normal_wb_cs_WB_SR_d,                    latches_normal_wb_cs_WB_SR_o);
    `REG_RST_WE(rr_latches_normal_wb_cs_WB_EAX,                   1,   clk, rst, effective_we, normal_wb_cs_WB_EAX_d,                   latches_normal_wb_cs_WB_EAX_o);

    `REG_RST_WE(rr_latches_normal_br_info_valid,                  1,   clk, rst, effective_we, normal_br_info_valid_d,                  latches_normal_br_info_valid_o);
    `REG_RST_WE(rr_latches_normal_br_info_br_eip,                 32,  clk, rst, effective_we, normal_br_info_br_eip_d,                 latches_normal_br_info_br_eip_o);
    `REG_RST_WE(rr_latches_normal_br_info_br_xcl,                 1,   clk, rst, effective_we, normal_br_info_br_xcl_d,                 latches_normal_br_info_br_xcl_o);
    `REG_RST_WE(rr_latches_normal_br_info_br_pred_taken,          1,   clk, rst, effective_we, normal_br_info_br_pred_taken_d,          latches_normal_br_info_br_pred_taken_o);
    `REG_RST_WE(rr_latches_normal_br_info_speculative_target,     32,  clk, rst, effective_we, normal_br_info_speculative_target_d,     latches_normal_br_info_speculative_target_o);

    `REG_RST_WE(rr_latches_normal_NEIP,                           32,  clk, rst, effective_we, normal_NEIP_d,                           latches_normal_NEIP_o);
    `REG_RST_WE(rr_latches_normal_EIP,                            32,  clk, rst, effective_we, normal_EIP_d,                            latches_normal_EIP_o);
    `REG_RST_WE(rr_latches_normal_EAX,                            32,  clk, rst, effective_we, normal_EAX_d,                            latches_normal_EAX_o);
    `REG_RST_WE(rr_latches_normal_imm64,                          64,  clk, rst, effective_we, normal_imm64_d,                          latches_normal_imm64_o);
    `REG_RST_WE(rr_latches_normal_sib_idx_id,                     5,   clk, rst, effective_we, normal_sib_idx_id_d,                     latches_normal_sib_idx_id_o);
    `REG_RST_WE(rr_latches_normal_sib_base_id,                    5,   clk, rst, effective_we, normal_sib_base_id_d,                    latches_normal_sib_base_id_o);
    `REG_RST_WE(rr_latches_normal_sib_needed,                     1,   clk, rst, effective_we, normal_sib_needed_d,                     latches_normal_sib_needed_o);
    `REG_RST_WE(rr_latches_normal_sib_scale,                      8,   clk, rst, effective_we, normal_sib_scale_d,                      latches_normal_sib_scale_o);
    `REG_RST_WE(rr_latches_normal_disp_needed,                    1,   clk, rst, effective_we, normal_disp_needed_d,                    latches_normal_disp_needed_o);
    `REG_RST_WE(rr_latches_normal_disp_size,                      1,   clk, rst, effective_we, normal_disp_size_d,                      latches_normal_disp_size_o);
    `REG_RST_WE(rr_latches_normal_displacement,                   32,  clk, rst, effective_we, normal_displacement_d,                   latches_normal_displacement_o);

    // -------- rep_ registers --------
    `REG_RST_WE(rr_latches_rep_valid,                             1,   clk, rst, effective_we, rep_valid_d,                             latches_rep_valid_o);

    `REG_RST_WE(rr_latches_rep_cs_ST_SEL,                         1,   clk, rst, effective_we, rep_cs_ST_SEL_d,                         latches_rep_cs_ST_SEL_o);
    `REG_RST_WE(rr_latches_rep_cs_MODRM_NEEDED,                   1,   clk, rst, effective_we, rep_cs_MODRM_NEEDED_d,                   latches_rep_cs_MODRM_NEEDED_o);
    `REG_RST_WE(rr_latches_rep_cs_RM_IS_DR,                       1,   clk, rst, effective_we, rep_cs_RM_IS_DR_d,                       latches_rep_cs_RM_IS_DR_o);
    `REG_RST_WE(rr_latches_rep_cs_SWITCH_LD_ADDY,                 1,   clk, rst, effective_we, rep_cs_SWITCH_LD_ADDY_d,                 latches_rep_cs_SWITCH_LD_ADDY_o);
    `REG_RST_WE(rr_latches_rep_cs_LD_OP,                          1,   clk, rst, effective_we, rep_cs_LD_OP_d,                          latches_rep_cs_LD_OP_o);
    `REG_RST_WE(rr_latches_rep_cs_ST_OP,                          1,   clk, rst, effective_we, rep_cs_ST_OP_d,                          latches_rep_cs_ST_OP_o);
    `REG_RST_WE(rr_latches_rep_cs_dr_id,                          5,   clk, rst, effective_we, rep_cs_dr_id_d,                          latches_rep_cs_dr_id_o);
    `REG_RST_WE(rr_latches_rep_cs_sr_id,                          5,   clk, rst, effective_we, rep_cs_sr_id_d,                          latches_rep_cs_sr_id_o);
    `REG_RST_WE(rr_latches_rep_cs_dr_rd,                          1,   clk, rst, effective_we, rep_cs_dr_rd_d,                          latches_rep_cs_dr_rd_o);
    `REG_RST_WE(rr_latches_rep_cs_sr_rd,                          1,   clk, rst, effective_we, rep_cs_sr_rd_d,                          latches_rep_cs_sr_rd_o);
    `REG_RST_WE(rr_latches_rep_cs_eax_rd,                         1,   clk, rst, effective_we, rep_cs_eax_rd_d,                         latches_rep_cs_eax_rd_o);
    `REG_RST_WE(rr_latches_rep_cs_dr_wr,                          1,   clk, rst, effective_we, rep_cs_dr_wr_d,                          latches_rep_cs_dr_wr_o);
    `REG_RST_WE(rr_latches_rep_cs_sr_wr,                          1,   clk, rst, effective_we, rep_cs_sr_wr_d,                          latches_rep_cs_sr_wr_o);
    `REG_RST_WE(rr_latches_rep_cs_eax_wr,                         1,   clk, rst, effective_we, rep_cs_eax_wr_d,                         latches_rep_cs_eax_wr_o);
    `REG_RST_WE(rr_latches_rep_cs_MOVS_OP,                        1,   clk, rst, effective_we, rep_cs_MOVS_OP_d,                        latches_rep_cs_MOVS_OP_o);
    `REG_RST_WE(rr_latches_rep_cs_datasize,                       2,   clk, rst, effective_we, rep_cs_datasize_d,                       latches_rep_cs_datasize_o);
    `REG_RST_WE(rr_latches_rep_cs_will_mod_zf,                    1,   clk, rst, effective_we, rep_cs_will_mod_zf_d,                    latches_rep_cs_will_mod_zf_o);
    `REG_RST_WE(rr_latches_rep_cs_seg_1_valid,                    1,   clk, rst, effective_we, rep_cs_seg_1_valid_d,                    latches_rep_cs_seg_1_valid_o);
    `REG_RST_WE(rr_latches_rep_cs_seg_0_id,                       5,   clk, rst, effective_we, rep_cs_seg_0_id_d,                       latches_rep_cs_seg_0_id_o);
    `REG_RST_WE(rr_latches_rep_cs_seg_1_id,                       5,   clk, rst, effective_we, rep_cs_seg_1_id_d,                       latches_rep_cs_seg_1_id_o);
    `REG_RST_WE(rr_latches_rep_cs_special_modrm_bs,               1,   clk, rst, effective_we, rep_cs_special_modrm_bs_d,               latches_rep_cs_special_modrm_bs_o);
    `REG_RST_WE(rr_latches_rep_cs_special_br,                     1,   clk, rst, effective_we, rep_cs_special_br_d,                     latches_rep_cs_special_br_o);

    `REG_RST_WE(rr_latches_rep_dc_cs_LD_OP,                       1,   clk, rst, effective_we, rep_dc_cs_LD_OP_d,                       latches_rep_dc_cs_LD_OP_o);
    `REG_RST_WE(rr_latches_rep_dc_cs_ST_OP,                       1,   clk, rst, effective_we, rep_dc_cs_ST_OP_d,                       latches_rep_dc_cs_ST_OP_o);
    `REG_RST_WE(rr_latches_rep_dc_cs_dr_upper8,                   1,   clk, rst, effective_we, rep_dc_cs_dr_upper8_d,                   latches_rep_dc_cs_dr_upper8_o);
    `REG_RST_WE(rr_latches_rep_dc_cs_sr_upper8,                   1,   clk, rst, effective_we, rep_dc_cs_sr_upper8_d,                   latches_rep_dc_cs_sr_upper8_o);
    `REG_RST_WE(rr_latches_rep_dc_cs_datasize,                    2,   clk, rst, effective_we, rep_dc_cs_datasize_d,                    latches_rep_dc_cs_datasize_o);

    `REG_RST_WE(rr_latches_rep_mem_cs_ST_OP,                      1,   clk, rst, effective_we, rep_mem_cs_ST_OP_d,                      latches_rep_mem_cs_ST_OP_o);
    `REG_RST_WE(rr_latches_rep_mem_cs_LD_OP,                      1,   clk, rst, effective_we, rep_mem_cs_LD_OP_d,                      latches_rep_mem_cs_LD_OP_o);

    `REG_RST_WE(rr_latches_rep_exe_cs_ST_OP,                      1,   clk, rst, effective_we, rep_exe_cs_ST_OP_d,                      latches_rep_exe_cs_ST_OP_o);
    `REG_RST_WE(rr_latches_rep_exe_cs_OP_TYPE,                    32,  clk, rst, effective_we, rep_exe_cs_OP_TYPE_d,                    latches_rep_exe_cs_OP_TYPE_o);
    `REG_RST_WE(rr_latches_rep_exe_cs_alu_inputA_sel,             32,  clk, rst, effective_we, rep_exe_cs_alu_inputA_sel_d,             latches_rep_exe_cs_alu_inputA_sel_o);
    `REG_RST_WE(rr_latches_rep_exe_cs_alu_inputB_sel,             32,  clk, rst, effective_we, rep_exe_cs_alu_inputB_sel_d,             latches_rep_exe_cs_alu_inputB_sel_o);
    `REG_RST_WE(rr_latches_rep_exe_cs_branch_target_sel,          32,  clk, rst, effective_we, rep_exe_cs_branch_target_sel_d,          latches_rep_exe_cs_branch_target_sel_o);
    `REG_RST_WE(rr_latches_rep_exe_cs_shift_by_one,               1,   clk, rst, effective_we, rep_exe_cs_shift_by_one_d,               latches_rep_exe_cs_shift_by_one_o);
    `REG_RST_WE(rr_latches_rep_exe_cs_br_ucond,                   1,   clk, rst, effective_we, rep_exe_cs_br_ucond_d,                   latches_rep_exe_cs_br_ucond_o);
    `REG_RST_WE(rr_latches_rep_exe_cs_relative_branch,            1,   clk, rst, effective_we, rep_exe_cs_relative_branch_d,            latches_rep_exe_cs_relative_branch_o);
    `REG_RST_WE(rr_latches_rep_exe_cs_special_br,                 1,   clk, rst, effective_we, rep_exe_cs_special_br_d,                 latches_rep_exe_cs_special_br_o);
    `REG_RST_WE(rr_latches_rep_exe_cs_is_far,                     1,   clk, rst, effective_we, rep_exe_cs_is_far_d,                     latches_rep_exe_cs_is_far_o);
    `REG_RST_WE(rr_latches_rep_exe_cs_is_call,                    1,   clk, rst, effective_we, rep_exe_cs_is_call_d,                    latches_rep_exe_cs_is_call_o);
    `REG_RST_WE(rr_latches_rep_exe_cs_second_flag_needed,         1,   clk, rst, effective_we, rep_exe_cs_second_flag_needed_d,         latches_rep_exe_cs_second_flag_needed_o);
    `REG_RST_WE(rr_latches_rep_exe_cs_rep_no_zf_update,           1,   clk, rst, effective_we, rep_exe_cs_rep_no_zf_update_d,           latches_rep_exe_cs_rep_no_zf_update_o);

    `REG_RST_WE(rr_latches_rep_wb_cs_ST_OP,                       1,   clk, rst, effective_we, rep_wb_cs_ST_OP_d,                       latches_rep_wb_cs_ST_OP_o);
    `REG_RST_WE(rr_latches_rep_wb_cs_WB_DR,                       1,   clk, rst, effective_we, rep_wb_cs_WB_DR_d,                       latches_rep_wb_cs_WB_DR_o);
    `REG_RST_WE(rr_latches_rep_wb_cs_WB_SR,                       1,   clk, rst, effective_we, rep_wb_cs_WB_SR_d,                       latches_rep_wb_cs_WB_SR_o);
    `REG_RST_WE(rr_latches_rep_wb_cs_WB_EAX,                      1,   clk, rst, effective_we, rep_wb_cs_WB_EAX_d,                      latches_rep_wb_cs_WB_EAX_o);

    `REG_RST_WE(rr_latches_rep_br_info_valid,                     1,   clk, rst, effective_we, rep_br_info_valid_d,                     latches_rep_br_info_valid_o);
    `REG_RST_WE(rr_latches_rep_br_info_br_eip,                    32,  clk, rst, effective_we, rep_br_info_br_eip_d,                    latches_rep_br_info_br_eip_o);
    `REG_RST_WE(rr_latches_rep_br_info_br_xcl,                    1,   clk, rst, effective_we, rep_br_info_br_xcl_d,                    latches_rep_br_info_br_xcl_o);
    `REG_RST_WE(rr_latches_rep_br_info_br_pred_taken,             1,   clk, rst, effective_we, rep_br_info_br_pred_taken_d,             latches_rep_br_info_br_pred_taken_o);
    `REG_RST_WE(rr_latches_rep_br_info_speculative_target,        32,  clk, rst, effective_we, rep_br_info_speculative_target_d,        latches_rep_br_info_speculative_target_o);

    `REG_RST_WE(rr_latches_rep_NEIP,                              32,  clk, rst, effective_we, rep_NEIP_d,                              latches_rep_NEIP_o);
    `REG_RST_WE(rr_latches_rep_EIP,                               32,  clk, rst, effective_we, rep_EIP_d,                               latches_rep_EIP_o);
    `REG_RST_WE(rr_latches_rep_EAX,                               32,  clk, rst, effective_we, rep_EAX_d,                               latches_rep_EAX_o);
    `REG_RST_WE(rr_latches_rep_imm64,                             64,  clk, rst, effective_we, rep_imm64_d,                             latches_rep_imm64_o);
    `REG_RST_WE(rr_latches_rep_sib_idx_id,                        5,   clk, rst, effective_we, rep_sib_idx_id_d,                        latches_rep_sib_idx_id_o);
    `REG_RST_WE(rr_latches_rep_sib_base_id,                       5,   clk, rst, effective_we, rep_sib_base_id_d,                       latches_rep_sib_base_id_o);
    `REG_RST_WE(rr_latches_rep_sib_needed,                        1,   clk, rst, effective_we, rep_sib_needed_d,                        latches_rep_sib_needed_o);
    `REG_RST_WE(rr_latches_rep_sib_scale,                         8,   clk, rst, effective_we, rep_sib_scale_d,                         latches_rep_sib_scale_o);
    `REG_RST_WE(rr_latches_rep_disp_needed,                       1,   clk, rst, effective_we, rep_disp_needed_d,                       latches_rep_disp_needed_o);
    `REG_RST_WE(rr_latches_rep_disp_size,                         1,   clk, rst, effective_we, rep_disp_size_d,                         latches_rep_disp_size_o);
    `REG_RST_WE(rr_latches_rep_displacement,                      32,  clk, rst, effective_we, rep_displacement_d,                      latches_rep_displacement_o);

endmodule
