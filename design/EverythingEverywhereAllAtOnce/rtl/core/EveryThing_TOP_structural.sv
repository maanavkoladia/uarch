
// EveryThing_TOP_structural.sv
//
// Top-level core wrapper. Stages (Fetch, Decode, RR, DC, MEM, EXE, WB) and
// IDM are now flat-port Verilog-2005 modules. The stage latches (RR/DC/MEM/
// EXE/WB Latches) are still SV with struct ports, so this file owns the
// pack/unpack between flat buses and the SV struct fields at the few
// remaining V/SV boundaries.
//
// The block-level boundary (icache, dcache, dma) is now also fully flat:
// the icache_2_core_t / core_2_icache_t / dcache_2_core_t / core_2_dcache_t /
// dma_controller_2_core_t structs from the original SV port have been
// unrolled into individual flat ports below. Per-slot byte arrays
// (instruction_line, cacheline, line_MIO, stq_data) are LSB-first packed
// 128-bit buses on the boundary.
//
// All inter-stage struct buses have been flattened into individual wire
// declarations below (one wire per leaf field). No SystemVerilog struct
// types or `import` statements are used in this file.

module EveryThing_TOP (
    input  wire                  clk,
    input  wire                  rst,

    // -------------------- icache_2_core_t (ICacheIn) --------------------
    input  wire         ICacheIn_hit,
    input  wire [127:0] ICacheIn_instruction_line,

    // -------------------- core_2_icache_t (out2ICache) ------------------
    output wire         out2ICache_icache_en,
    output wire [14:0]  out2ICache_p_addr,
    output wire [31:0]  out2ICache_v_addr_i,
    output wire [2:0]   out2ICache_num_valid_IDM_slots,

    // -------------------- dcache_2_core_t (DCacheIn) --------------------
    input  wire         DCacheIn_reqServed_0,
    input  wire         DCacheIn_reqServed_1,
    input  wire         DCacheIn_hit_0,
    input  wire         DCacheIn_hit_1,
    input  wire         DCacheIn_hit_2,
    input  wire         DCacheIn_hit_3,
    input  wire [127:0] DCacheIn_cacheline_0,
    input  wire [127:0] DCacheIn_cacheline_1,
    input  wire [127:0] DCacheIn_cacheline_2,
    input  wire [127:0] DCacheIn_cacheline_3,
    input  wire         DCacheIn_writeSuccess_0,
    input  wire         DCacheIn_writeSuccess_1,
    input  wire         DCacheIn_writeSuccess_2,
    input  wire         DCacheIn_writeSuccess_3,
    input  wire         DCacheIn_writeSuccess_MIO,
    input  wire         DCacheIn_hit_MIO,
    input  wire         DCacheIn_reqServed_MIO,
    input  wire [127:0] DCacheIn_line_MIO,

    // -------------------- core_2_dcache_t (out2DCache) ------------------
    output wire         out2DCache_ld_addr_0_V,
    output wire [14:0]  out2DCache_ld_addr_0,
    output wire         out2DCache_ld_addr_1_V,
    output wire [14:0]  out2DCache_ld_addr_1,
    output wire         out2DCache_ld_addr_MIO_V,
    output wire [14:0]  out2DCache_ld_addr_MIO,

    output wire         out2DCache_stq_heads_0_full,
    output wire         out2DCache_stq_heads_0_empty,
    output wire [14:0]  out2DCache_stq_heads_0_address,
    output wire [15:0]  out2DCache_stq_heads_0_bit_vec,
    output wire [127:0] out2DCache_stq_heads_0_data,
    output wire         out2DCache_stq_heads_1_full,
    output wire         out2DCache_stq_heads_1_empty,
    output wire [14:0]  out2DCache_stq_heads_1_address,
    output wire [15:0]  out2DCache_stq_heads_1_bit_vec,
    output wire [127:0] out2DCache_stq_heads_1_data,
    output wire         out2DCache_stq_heads_2_full,
    output wire         out2DCache_stq_heads_2_empty,
    output wire [14:0]  out2DCache_stq_heads_2_address,
    output wire [15:0]  out2DCache_stq_heads_2_bit_vec,
    output wire [127:0] out2DCache_stq_heads_2_data,
    output wire         out2DCache_stq_heads_3_full,
    output wire         out2DCache_stq_heads_3_empty,
    output wire [14:0]  out2DCache_stq_heads_3_address,
    output wire [15:0]  out2DCache_stq_heads_3_bit_vec,
    output wire [127:0] out2DCache_stq_heads_3_data,

    output wire         out2DCache_stq_info_mio_full,
    output wire         out2DCache_stq_info_mio_empty,
    output wire [14:0]  out2DCache_stq_info_mio_address,
    output wire [15:0]  out2DCache_stq_info_mio_bit_vec,
    output wire [127:0] out2DCache_stq_info_mio_data,

    output wire         out2DCache_memStage_CLR_REQ_0,
    output wire         out2DCache_memStage_CLR_REQ_1,
    output wire         out2DCache_memStage_CLR_REQ_2,
    output wire         out2DCache_memStage_CLR_REQ_3,
    output wire         out2DCache_memStage_CLR_REQ_MIO,

    // -------------------- dma_controller_2_core_t (inFromDMA) -----------
    input  wire         inFromDMA_intOut
);
   

    // ====================================================================
    // WB / EXE byte-array bridges (same as the original SV top file).
    // ====================================================================
    wire [255:0] wb_latches_res_buf_w;
    wire [255:0] exe_latches_ld_buf_w;
    wire [127:0] wb_stq_head_0_data_w, wb_stq_head_1_data_w;
    wire [127:0] wb_stq_head_2_data_w, wb_stq_head_3_data_w;
    wire [127:0] wb_mio_head_data_w;
    wire [255:0] exe_wb_latches_next_res_buf_w;

    // MEM (flat-port .v) drives a 256-bit packed exe_latches_next_ld_buf;
    // unpack into the byte_t ld_buf[EXE_BUFFER_SIZE] field of the SV struct.
    wire [255:0] exe_latches_next_ld_buf_w;

    // (The flat-port WB_Latches drives wb_latches_res_buf_w directly via
    // its latches_res_buf_o output, and the flat-port EXE_Latches drives
    // exe_latches_ld_buf_w via latches_ld_buf_o. The previous pack-from-
    // struct-byte-array generate loops have been removed; the boundary
    // is fully flat now.)

    // ====================================================================
    // Flat wire declarations replacing the original SV struct internal
    // buses (idm_outputs / fetch_outputs / decode_outputs / rr_outputs /
    // dc_outputs / mem_outputs / exe_outputs / wb_outputs and the five
    // stage-latch buses, each with a _next sibling). Each leaf field of
    // the original SV typedef becomes its own flat wire here.
    // ====================================================================
    wire        idm_outputs_idm_slots_0_valid;
    wire        idm_outputs_idm_slots_0_br_valid;
    wire [31:0] idm_outputs_idm_slots_0_br_eip;
    wire [31:0] idm_outputs_idm_slots_0_br_btb_target;
    wire        idm_outputs_idm_slots_0_br_xcl;
    wire        idm_outputs_idm_slots_1_valid;
    wire        idm_outputs_idm_slots_1_br_valid;
    wire [31:0] idm_outputs_idm_slots_1_br_eip;
    wire [31:0] idm_outputs_idm_slots_1_br_btb_target;
    wire        idm_outputs_idm_slots_1_br_xcl;
    wire        idm_outputs_idm_slots_2_valid;
    wire        idm_outputs_idm_slots_2_br_valid;
    wire [31:0] idm_outputs_idm_slots_2_br_eip;
    wire [31:0] idm_outputs_idm_slots_2_br_btb_target;
    wire        idm_outputs_idm_slots_2_br_xcl;
    wire        idm_outputs_idm_slots_3_valid;
    wire        idm_outputs_idm_slots_3_br_valid;
    wire [31:0] idm_outputs_idm_slots_3_br_eip;
    wire [31:0] idm_outputs_idm_slots_3_br_btb_target;
    wire        idm_outputs_idm_slots_3_br_xcl;
    wire [2:0] idm_outputs_valid_slots;
    wire        fetch_outputs_fetch_2_icache_icache_en;
    wire [14:0] fetch_outputs_fetch_2_icache_p_addr;
    wire [31:0] fetch_outputs_fetch_2_icache_v_addr_i;
    wire [2:0] fetch_outputs_fetch_2_icache_num_valid_IDM_slots;
    wire        fetch_outputs_idm_reqs_req_0_ld_meta_data;
    wire        fetch_outputs_idm_reqs_req_0_ld_data;
    wire        fetch_outputs_idm_reqs_req_0_valid;
    wire        fetch_outputs_idm_reqs_req_0_br_valid;
    wire [31:0] fetch_outputs_idm_reqs_req_0_br_eip;
    wire [31:0] fetch_outputs_idm_reqs_req_0_br_target;
    wire        fetch_outputs_idm_reqs_req_0_br_xcl;
    wire        fetch_outputs_idm_reqs_req_1_ld_meta_data;
    wire        fetch_outputs_idm_reqs_req_1_ld_data;
    wire        fetch_outputs_idm_reqs_req_1_valid;
    wire        fetch_outputs_idm_reqs_req_1_br_valid;
    wire [31:0] fetch_outputs_idm_reqs_req_1_br_eip;
    wire [31:0] fetch_outputs_idm_reqs_req_1_br_target;
    wire        fetch_outputs_idm_reqs_req_1_br_xcl;
    wire        fetch_outputs_idm_reqs_req_2_ld_meta_data;
    wire        fetch_outputs_idm_reqs_req_2_ld_data;
    wire        fetch_outputs_idm_reqs_req_2_valid;
    wire        fetch_outputs_idm_reqs_req_2_br_valid;
    wire [31:0] fetch_outputs_idm_reqs_req_2_br_eip;
    wire [31:0] fetch_outputs_idm_reqs_req_2_br_target;
    wire        fetch_outputs_idm_reqs_req_2_br_xcl;
    wire        fetch_outputs_idm_reqs_req_3_ld_meta_data;
    wire        fetch_outputs_idm_reqs_req_3_ld_data;
    wire        fetch_outputs_idm_reqs_req_3_valid;
    wire        fetch_outputs_idm_reqs_req_3_br_valid;
    wire [31:0] fetch_outputs_idm_reqs_req_3_br_eip;
    wire [31:0] fetch_outputs_idm_reqs_req_3_br_target;
    wire        fetch_outputs_idm_reqs_req_3_br_xcl;
    wire        fetch_outputs_exp_pipe_clear;
    wire        fetch_outputs_exp_present;
    wire        fetch_outputs_exp_pf;
    wire [1:0] fetch_outputs_exp_mode_jk;
    wire        fetch_outputs_int_mode_jk;
    wire        decode_outputs_valid;
    wire        decode_outputs_stall;
    wire [31:0] decode_outputs_eip;
    wire        decode_outputs_invalid_instruction;
    wire        decode_outputs_decode_gp;
    wire        decode_outputs_rr_stage_latch_we;
    wire        decode_outputs_rep_latch;
    wire        decode_outputs_decode_forward;
    wire        rr_outputs_valid;
    wire        rr_outputs_stall;
    wire        rr_outputs_ecx_sb;
    wire [31:0] rr_outputs_ecx;
    wire [31:0] rr_outputs_eax;
    wire        rr_outputs_set_ZF_sb;
    wire        rr_outputs_codeSeg_sb;
    wire [31:0] rr_outputs_codeSeg_data;
    wire [31:0] rr_outputs_codeSeg_limit;
    wire        rr_outputs_dc_stage_latch_we;
    wire [63:0] rr_outputs_regFileValues_0;
    wire [63:0] rr_outputs_regFileValues_1;
    wire [63:0] rr_outputs_regFileValues_2;
    wire [63:0] rr_outputs_regFileValues_3;
    wire [63:0] rr_outputs_regFileValues_4;
    wire [63:0] rr_outputs_regFileValues_5;
    wire [63:0] rr_outputs_regFileValues_6;
    wire [63:0] rr_outputs_regFileValues_7;
    wire [63:0] rr_outputs_regFileValues_8;
    wire [63:0] rr_outputs_regFileValues_9;
    wire [63:0] rr_outputs_regFileValues_10;
    wire [63:0] rr_outputs_regFileValues_11;
    wire [63:0] rr_outputs_regFileValues_12;
    wire [63:0] rr_outputs_regFileValues_13;
    wire [63:0] rr_outputs_regFileValues_14;
    wire [63:0] rr_outputs_regFileValues_15;
    wire [63:0] rr_outputs_regFileValues_16;
    wire [63:0] rr_outputs_regFileValues_17;
    wire [63:0] rr_outputs_regFileValues_18;
    wire [63:0] rr_outputs_regFileValues_19;
    wire [63:0] rr_outputs_regFileValues_20;
    wire [63:0] rr_outputs_regFileValues_21;
    wire [63:0] rr_outputs_regFileValues_22;
    wire [63:0] rr_outputs_regFileValues_23;
    wire [63:0] rr_outputs_regFileValues_24;
    wire [63:0] rr_outputs_regFileValues_25;
    wire        dc_outputs_valid;
    wire [31:0] dc_outputs_dc_eip;
    wire        dc_outputs_stall;
    wire        dc_outputs_exp_present;
    wire        dc_outputs_exp_pf;
    wire        dc_outputs_ld_addr_0_V;
    wire [14:0] dc_outputs_ld_addr_0;
    wire        dc_outputs_ld_addr_1_V;
    wire [14:0] dc_outputs_ld_addr_1;
    wire        dc_outputs_ld_addr_MIO_V;
    wire [14:0] dc_outputs_ld_addr_MIO;
    wire        dc_outputs_mem_stage_latch_we;
    wire        mem_outputs_valid;
    wire        mem_outputs_stall;
    wire        mem_outputs_ST_XCL;
    wire [14:0] mem_outputs_ST_PADDR_0;
    wire [14:0] mem_outputs_ST_PADDR_1;
    wire        mem_outputs_ST_OP;
    wire        mem_outputs_clr_dcache_arb_latches_0;
    wire        mem_outputs_clr_dcache_arb_latches_1;
    wire        mem_outputs_clr_dcache_arb_latches_2;
    wire        mem_outputs_clr_dcache_arb_latches_3;
    wire        mem_outputs_clr_dcache_mio_latch;
    wire        mem_outputs_exe_stage_latch_we;
    wire        exe_outputs_valid;
    wire        exe_outputs_br_res_out_valid;
    wire        exe_outputs_br_res_out_flush;
    wire        exe_outputs_br_res_out_farFlush;
    wire        exe_outputs_br_res_out_callFlush;
    wire        exe_outputs_br_res_out_miss_prediction;
    wire [31:0] exe_outputs_br_res_out_br_eip;
    wire [31:0] exe_outputs_br_res_out_neip;
    wire [31:0] exe_outputs_br_res_out_br_target;
    wire        exe_outputs_br_res_out_taken;
    wire        exe_outputs_br_res_out_br_XCL;
    wire        exe_outputs_br_res_out_clr_exp_mode;
    wire        exe_outputs_br_res_out_br_ucond;
    wire        exe_outputs_DR_0_we;
    wire [4:0] exe_outputs_DR_0_id;
    wire [63:0] exe_outputs_DR_0_data;
    wire        exe_outputs_DR_1_we;
    wire [4:0] exe_outputs_DR_1_id;
    wire [63:0] exe_outputs_DR_1_data;
    wire        exe_outputs_clr_ZF_sb;
    wire        exe_outputs_ZF;
    wire        exe_outputs_ST_OP;
    wire        exe_outputs_ST_XCL;
    wire [14:0] exe_outputs_ST_PADDR_0;
    wire [14:0] exe_outputs_ST_PADDR_1;
    wire        exe_outputs_wb_stage_latch_we;
    wire        wb_outputs_valid;
    wire        wb_outputs_wb_stall;
    wire        wb_outputs_stq_heads_0_full;
    wire        wb_outputs_stq_heads_0_empty;
    wire [14:0] wb_outputs_stq_heads_0_address;
    wire [15:0] wb_outputs_stq_heads_0_bit_vec;
    wire        wb_outputs_stq_heads_1_full;
    wire        wb_outputs_stq_heads_1_empty;
    wire [14:0] wb_outputs_stq_heads_1_address;
    wire [15:0] wb_outputs_stq_heads_1_bit_vec;
    wire        wb_outputs_stq_heads_2_full;
    wire        wb_outputs_stq_heads_2_empty;
    wire [14:0] wb_outputs_stq_heads_2_address;
    wire [15:0] wb_outputs_stq_heads_2_bit_vec;
    wire        wb_outputs_stq_heads_3_full;
    wire        wb_outputs_stq_heads_3_empty;
    wire [14:0] wb_outputs_stq_heads_3_address;
    wire [15:0] wb_outputs_stq_heads_3_bit_vec;
    wire        wb_outputs_mio_head_full;
    wire        wb_outputs_mio_head_empty;
    wire [14:0] wb_outputs_mio_head_address;
    wire [15:0] wb_outputs_mio_head_bit_vec;
    wire        wb_outputs_dep_check_entries_0_valid;
    wire [14:0] wb_outputs_dep_check_entries_0_address;
    wire        wb_outputs_dep_check_entries_1_valid;
    wire [14:0] wb_outputs_dep_check_entries_1_address;
    wire        wb_outputs_dep_check_entries_2_valid;
    wire [14:0] wb_outputs_dep_check_entries_2_address;
    wire        wb_outputs_dep_check_entries_3_valid;
    wire [14:0] wb_outputs_dep_check_entries_3_address;
    wire        wb_outputs_dep_check_entries_4_valid;
    wire [14:0] wb_outputs_dep_check_entries_4_address;
    wire        wb_outputs_dep_check_entries_5_valid;
    wire [14:0] wb_outputs_dep_check_entries_5_address;
    wire        wb_outputs_dep_check_entries_6_valid;
    wire [14:0] wb_outputs_dep_check_entries_6_address;
    wire        wb_outputs_dep_check_entries_7_valid;
    wire [14:0] wb_outputs_dep_check_entries_7_address;
    wire        wb_outputs_dep_check_entries_8_valid;
    wire [14:0] wb_outputs_dep_check_entries_8_address;
    wire        wb_outputs_dep_check_entries_9_valid;
    wire [14:0] wb_outputs_dep_check_entries_9_address;
    wire        wb_outputs_dep_check_entries_10_valid;
    wire [14:0] wb_outputs_dep_check_entries_10_address;
    wire        wb_outputs_dep_check_entries_11_valid;
    wire [14:0] wb_outputs_dep_check_entries_11_address;
    wire        wb_outputs_dep_check_entries_12_valid;
    wire [14:0] wb_outputs_dep_check_entries_12_address;
    wire        wb_outputs_dep_check_entries_13_valid;
    wire [14:0] wb_outputs_dep_check_entries_13_address;
    wire        wb_outputs_dep_check_entries_14_valid;
    wire [14:0] wb_outputs_dep_check_entries_14_address;
    wire        wb_outputs_dep_check_entries_15_valid;
    wire [14:0] wb_outputs_dep_check_entries_15_address;
    wire        wb_outputs_ST_OP;
    wire        wb_outputs_ST_XCL;
    wire [14:0] wb_outputs_ST_PADDR_0;
    wire [14:0] wb_outputs_ST_PADDR_1;
    wire        rr_latches_normal_latches_valid;
    wire        rr_latches_normal_latches_cs_ST_SEL;
    wire        rr_latches_normal_latches_cs_MODRM_NEEDED;
    wire        rr_latches_normal_latches_cs_RM_IS_DR;
    wire        rr_latches_normal_latches_cs_SWITCH_LD_ADDY;
    wire        rr_latches_normal_latches_cs_LD_OP;
    wire        rr_latches_normal_latches_cs_ST_OP;
    wire [4:0] rr_latches_normal_latches_cs_dr_id;
    wire [4:0] rr_latches_normal_latches_cs_sr_id;
    wire        rr_latches_normal_latches_cs_dr_rd;
    wire        rr_latches_normal_latches_cs_sr_rd;
    wire        rr_latches_normal_latches_cs_eax_rd;
    wire        rr_latches_normal_latches_cs_dr_wr;
    wire        rr_latches_normal_latches_cs_sr_wr;
    wire        rr_latches_normal_latches_cs_eax_wr;
    wire        rr_latches_normal_latches_cs_MOVS_OP;
    wire [1:0] rr_latches_normal_latches_cs_datasize;
    wire        rr_latches_normal_latches_cs_will_mod_zf;
    wire        rr_latches_normal_latches_cs_seg_1_valid;
    wire [4:0] rr_latches_normal_latches_cs_seg_0_id;
    wire [4:0] rr_latches_normal_latches_cs_seg_1_id;
    wire        rr_latches_normal_latches_cs_special_modrm_bs;
    wire        rr_latches_normal_latches_cs_special_br;
    wire        rr_latches_normal_latches_dc_cs_LD_OP;
    wire        rr_latches_normal_latches_dc_cs_ST_OP;
    wire        rr_latches_normal_latches_dc_cs_dr_upper8;
    wire        rr_latches_normal_latches_dc_cs_sr_upper8;
    wire [1:0] rr_latches_normal_latches_dc_cs_datasize;
    wire        rr_latches_normal_latches_mem_cs_ST_OP;
    wire        rr_latches_normal_latches_mem_cs_LD_OP;
    wire        rr_latches_normal_latches_exe_cs_ST_OP;
    wire [31:0] rr_latches_normal_latches_exe_cs_OP_TYPE;
    wire [31:0] rr_latches_normal_latches_exe_cs_alu_inputA_sel;
    wire [31:0] rr_latches_normal_latches_exe_cs_alu_inputB_sel;
    wire [31:0] rr_latches_normal_latches_exe_cs_branch_target_sel;
    wire        rr_latches_normal_latches_exe_cs_shift_by_one;
    wire        rr_latches_normal_latches_exe_cs_br_ucond;
    wire        rr_latches_normal_latches_exe_cs_relative_branch;
    wire        rr_latches_normal_latches_exe_cs_special_br;
    wire        rr_latches_normal_latches_exe_cs_is_far;
    wire        rr_latches_normal_latches_exe_cs_is_call;
    wire        rr_latches_normal_latches_exe_cs_second_flag_needed;
    wire        rr_latches_normal_latches_exe_cs_rep_no_zf_update;
    wire        rr_latches_normal_latches_wb_cs_ST_OP;
    wire        rr_latches_normal_latches_wb_cs_WB_DR;
    wire        rr_latches_normal_latches_wb_cs_WB_SR;
    wire        rr_latches_normal_latches_wb_cs_WB_EAX;
    wire        rr_latches_normal_latches_br_info_valid;
    wire [31:0] rr_latches_normal_latches_br_info_br_eip;
    wire        rr_latches_normal_latches_br_info_br_xcl;
    wire        rr_latches_normal_latches_br_info_br_pred_taken;
    wire [31:0] rr_latches_normal_latches_br_info_speculative_target;
    wire [31:0] rr_latches_normal_latches_NEIP;
    wire [31:0] rr_latches_normal_latches_EIP;
    wire [31:0] rr_latches_normal_latches_EAX;
    wire [63:0] rr_latches_normal_latches_imm64;
    wire [4:0] rr_latches_normal_latches_sib_idx_id;
    wire [4:0] rr_latches_normal_latches_sib_base_id;
    wire        rr_latches_normal_latches_sib_needed;
    wire [7:0] rr_latches_normal_latches_sib_scale;
    wire        rr_latches_normal_latches_disp_needed;
    wire        rr_latches_normal_latches_disp_size;
    wire [31:0] rr_latches_normal_latches_displacement;
    wire        rr_latches_rep_latches_valid;
    wire        rr_latches_rep_latches_cs_ST_SEL;
    wire        rr_latches_rep_latches_cs_MODRM_NEEDED;
    wire        rr_latches_rep_latches_cs_RM_IS_DR;
    wire        rr_latches_rep_latches_cs_SWITCH_LD_ADDY;
    wire        rr_latches_rep_latches_cs_LD_OP;
    wire        rr_latches_rep_latches_cs_ST_OP;
    wire [4:0] rr_latches_rep_latches_cs_dr_id;
    wire [4:0] rr_latches_rep_latches_cs_sr_id;
    wire        rr_latches_rep_latches_cs_dr_rd;
    wire        rr_latches_rep_latches_cs_sr_rd;
    wire        rr_latches_rep_latches_cs_eax_rd;
    wire        rr_latches_rep_latches_cs_dr_wr;
    wire        rr_latches_rep_latches_cs_sr_wr;
    wire        rr_latches_rep_latches_cs_eax_wr;
    wire        rr_latches_rep_latches_cs_MOVS_OP;
    wire [1:0] rr_latches_rep_latches_cs_datasize;
    wire        rr_latches_rep_latches_cs_will_mod_zf;
    wire        rr_latches_rep_latches_cs_seg_1_valid;
    wire [4:0] rr_latches_rep_latches_cs_seg_0_id;
    wire [4:0] rr_latches_rep_latches_cs_seg_1_id;
    wire        rr_latches_rep_latches_cs_special_modrm_bs;
    wire        rr_latches_rep_latches_cs_special_br;
    wire        rr_latches_rep_latches_dc_cs_LD_OP;
    wire        rr_latches_rep_latches_dc_cs_ST_OP;
    wire        rr_latches_rep_latches_dc_cs_dr_upper8;
    wire        rr_latches_rep_latches_dc_cs_sr_upper8;
    wire [1:0] rr_latches_rep_latches_dc_cs_datasize;
    wire        rr_latches_rep_latches_mem_cs_ST_OP;
    wire        rr_latches_rep_latches_mem_cs_LD_OP;
    wire        rr_latches_rep_latches_exe_cs_ST_OP;
    wire [31:0] rr_latches_rep_latches_exe_cs_OP_TYPE;
    wire [31:0] rr_latches_rep_latches_exe_cs_alu_inputA_sel;
    wire [31:0] rr_latches_rep_latches_exe_cs_alu_inputB_sel;
    wire [31:0] rr_latches_rep_latches_exe_cs_branch_target_sel;
    wire        rr_latches_rep_latches_exe_cs_shift_by_one;
    wire        rr_latches_rep_latches_exe_cs_br_ucond;
    wire        rr_latches_rep_latches_exe_cs_relative_branch;
    wire        rr_latches_rep_latches_exe_cs_special_br;
    wire        rr_latches_rep_latches_exe_cs_is_far;
    wire        rr_latches_rep_latches_exe_cs_is_call;
    wire        rr_latches_rep_latches_exe_cs_second_flag_needed;
    wire        rr_latches_rep_latches_exe_cs_rep_no_zf_update;
    wire        rr_latches_rep_latches_wb_cs_ST_OP;
    wire        rr_latches_rep_latches_wb_cs_WB_DR;
    wire        rr_latches_rep_latches_wb_cs_WB_SR;
    wire        rr_latches_rep_latches_wb_cs_WB_EAX;
    wire        rr_latches_rep_latches_br_info_valid;
    wire [31:0] rr_latches_rep_latches_br_info_br_eip;
    wire        rr_latches_rep_latches_br_info_br_xcl;
    wire        rr_latches_rep_latches_br_info_br_pred_taken;
    wire [31:0] rr_latches_rep_latches_br_info_speculative_target;
    wire [31:0] rr_latches_rep_latches_NEIP;
    wire [31:0] rr_latches_rep_latches_EIP;
    wire [31:0] rr_latches_rep_latches_EAX;
    wire [63:0] rr_latches_rep_latches_imm64;
    wire [4:0] rr_latches_rep_latches_sib_idx_id;
    wire [4:0] rr_latches_rep_latches_sib_base_id;
    wire        rr_latches_rep_latches_sib_needed;
    wire [7:0] rr_latches_rep_latches_sib_scale;
    wire        rr_latches_rep_latches_disp_needed;
    wire        rr_latches_rep_latches_disp_size;
    wire [31:0] rr_latches_rep_latches_displacement;
    wire        rr_latches_next_normal_latches_valid;
    wire        rr_latches_next_normal_latches_cs_ST_SEL;
    wire        rr_latches_next_normal_latches_cs_MODRM_NEEDED;
    wire        rr_latches_next_normal_latches_cs_RM_IS_DR;
    wire        rr_latches_next_normal_latches_cs_SWITCH_LD_ADDY;
    wire        rr_latches_next_normal_latches_cs_LD_OP;
    wire        rr_latches_next_normal_latches_cs_ST_OP;
    wire [4:0] rr_latches_next_normal_latches_cs_dr_id;
    wire [4:0] rr_latches_next_normal_latches_cs_sr_id;
    wire        rr_latches_next_normal_latches_cs_dr_rd;
    wire        rr_latches_next_normal_latches_cs_sr_rd;
    wire        rr_latches_next_normal_latches_cs_eax_rd;
    wire        rr_latches_next_normal_latches_cs_dr_wr;
    wire        rr_latches_next_normal_latches_cs_sr_wr;
    wire        rr_latches_next_normal_latches_cs_eax_wr;
    wire        rr_latches_next_normal_latches_cs_MOVS_OP;
    wire [1:0] rr_latches_next_normal_latches_cs_datasize;
    wire        rr_latches_next_normal_latches_cs_will_mod_zf;
    wire        rr_latches_next_normal_latches_cs_seg_1_valid;
    wire [4:0] rr_latches_next_normal_latches_cs_seg_0_id;
    wire [4:0] rr_latches_next_normal_latches_cs_seg_1_id;
    wire        rr_latches_next_normal_latches_cs_special_modrm_bs;
    wire        rr_latches_next_normal_latches_cs_special_br;
    wire        rr_latches_next_normal_latches_dc_cs_LD_OP;
    wire        rr_latches_next_normal_latches_dc_cs_ST_OP;
    wire        rr_latches_next_normal_latches_dc_cs_dr_upper8;
    wire        rr_latches_next_normal_latches_dc_cs_sr_upper8;
    wire [1:0] rr_latches_next_normal_latches_dc_cs_datasize;
    wire        rr_latches_next_normal_latches_mem_cs_ST_OP;
    wire        rr_latches_next_normal_latches_mem_cs_LD_OP;
    wire        rr_latches_next_normal_latches_exe_cs_ST_OP;
    wire [31:0] rr_latches_next_normal_latches_exe_cs_OP_TYPE;
    wire [31:0] rr_latches_next_normal_latches_exe_cs_alu_inputA_sel;
    wire [31:0] rr_latches_next_normal_latches_exe_cs_alu_inputB_sel;
    wire [31:0] rr_latches_next_normal_latches_exe_cs_branch_target_sel;
    wire        rr_latches_next_normal_latches_exe_cs_shift_by_one;
    wire        rr_latches_next_normal_latches_exe_cs_br_ucond;
    wire        rr_latches_next_normal_latches_exe_cs_relative_branch;
    wire        rr_latches_next_normal_latches_exe_cs_special_br;
    wire        rr_latches_next_normal_latches_exe_cs_is_far;
    wire        rr_latches_next_normal_latches_exe_cs_is_call;
    wire        rr_latches_next_normal_latches_exe_cs_second_flag_needed;
    wire        rr_latches_next_normal_latches_exe_cs_rep_no_zf_update;
    wire        rr_latches_next_normal_latches_wb_cs_ST_OP;
    wire        rr_latches_next_normal_latches_wb_cs_WB_DR;
    wire        rr_latches_next_normal_latches_wb_cs_WB_SR;
    wire        rr_latches_next_normal_latches_wb_cs_WB_EAX;
    wire        rr_latches_next_normal_latches_br_info_valid;
    wire [31:0] rr_latches_next_normal_latches_br_info_br_eip;
    wire        rr_latches_next_normal_latches_br_info_br_xcl;
    wire        rr_latches_next_normal_latches_br_info_br_pred_taken;
    wire [31:0] rr_latches_next_normal_latches_br_info_speculative_target;
    wire [31:0] rr_latches_next_normal_latches_NEIP;
    wire [31:0] rr_latches_next_normal_latches_EIP;
    wire [31:0] rr_latches_next_normal_latches_EAX;
    wire [63:0] rr_latches_next_normal_latches_imm64;
    wire [4:0] rr_latches_next_normal_latches_sib_idx_id;
    wire [4:0] rr_latches_next_normal_latches_sib_base_id;
    wire        rr_latches_next_normal_latches_sib_needed;
    wire [7:0] rr_latches_next_normal_latches_sib_scale;
    wire        rr_latches_next_normal_latches_disp_needed;
    wire        rr_latches_next_normal_latches_disp_size;
    wire [31:0] rr_latches_next_normal_latches_displacement;
    wire        rr_latches_next_rep_latches_valid;
    wire        rr_latches_next_rep_latches_cs_ST_SEL;
    wire        rr_latches_next_rep_latches_cs_MODRM_NEEDED;
    wire        rr_latches_next_rep_latches_cs_RM_IS_DR;
    wire        rr_latches_next_rep_latches_cs_SWITCH_LD_ADDY;
    wire        rr_latches_next_rep_latches_cs_LD_OP;
    wire        rr_latches_next_rep_latches_cs_ST_OP;
    wire [4:0] rr_latches_next_rep_latches_cs_dr_id;
    wire [4:0] rr_latches_next_rep_latches_cs_sr_id;
    wire        rr_latches_next_rep_latches_cs_dr_rd;
    wire        rr_latches_next_rep_latches_cs_sr_rd;
    wire        rr_latches_next_rep_latches_cs_eax_rd;
    wire        rr_latches_next_rep_latches_cs_dr_wr;
    wire        rr_latches_next_rep_latches_cs_sr_wr;
    wire        rr_latches_next_rep_latches_cs_eax_wr;
    wire        rr_latches_next_rep_latches_cs_MOVS_OP;
    wire [1:0] rr_latches_next_rep_latches_cs_datasize;
    wire        rr_latches_next_rep_latches_cs_will_mod_zf;
    wire        rr_latches_next_rep_latches_cs_seg_1_valid;
    wire [4:0] rr_latches_next_rep_latches_cs_seg_0_id;
    wire [4:0] rr_latches_next_rep_latches_cs_seg_1_id;
    wire        rr_latches_next_rep_latches_cs_special_modrm_bs;
    wire        rr_latches_next_rep_latches_cs_special_br;
    wire        rr_latches_next_rep_latches_dc_cs_LD_OP;
    wire        rr_latches_next_rep_latches_dc_cs_ST_OP;
    wire        rr_latches_next_rep_latches_dc_cs_dr_upper8;
    wire        rr_latches_next_rep_latches_dc_cs_sr_upper8;
    wire [1:0] rr_latches_next_rep_latches_dc_cs_datasize;
    wire        rr_latches_next_rep_latches_mem_cs_ST_OP;
    wire        rr_latches_next_rep_latches_mem_cs_LD_OP;
    wire        rr_latches_next_rep_latches_exe_cs_ST_OP;
    wire [31:0] rr_latches_next_rep_latches_exe_cs_OP_TYPE;
    wire [31:0] rr_latches_next_rep_latches_exe_cs_alu_inputA_sel;
    wire [31:0] rr_latches_next_rep_latches_exe_cs_alu_inputB_sel;
    wire [31:0] rr_latches_next_rep_latches_exe_cs_branch_target_sel;
    wire        rr_latches_next_rep_latches_exe_cs_shift_by_one;
    wire        rr_latches_next_rep_latches_exe_cs_br_ucond;
    wire        rr_latches_next_rep_latches_exe_cs_relative_branch;
    wire        rr_latches_next_rep_latches_exe_cs_special_br;
    wire        rr_latches_next_rep_latches_exe_cs_is_far;
    wire        rr_latches_next_rep_latches_exe_cs_is_call;
    wire        rr_latches_next_rep_latches_exe_cs_second_flag_needed;
    wire        rr_latches_next_rep_latches_exe_cs_rep_no_zf_update;
    wire        rr_latches_next_rep_latches_wb_cs_ST_OP;
    wire        rr_latches_next_rep_latches_wb_cs_WB_DR;
    wire        rr_latches_next_rep_latches_wb_cs_WB_SR;
    wire        rr_latches_next_rep_latches_wb_cs_WB_EAX;
    wire        rr_latches_next_rep_latches_br_info_valid;
    wire [31:0] rr_latches_next_rep_latches_br_info_br_eip;
    wire        rr_latches_next_rep_latches_br_info_br_xcl;
    wire        rr_latches_next_rep_latches_br_info_br_pred_taken;
    wire [31:0] rr_latches_next_rep_latches_br_info_speculative_target;
    wire [31:0] rr_latches_next_rep_latches_NEIP;
    wire [31:0] rr_latches_next_rep_latches_EIP;
    wire [31:0] rr_latches_next_rep_latches_EAX;
    wire [63:0] rr_latches_next_rep_latches_imm64;
    wire [4:0] rr_latches_next_rep_latches_sib_idx_id;
    wire [4:0] rr_latches_next_rep_latches_sib_base_id;
    wire        rr_latches_next_rep_latches_sib_needed;
    wire [7:0] rr_latches_next_rep_latches_sib_scale;
    wire        rr_latches_next_rep_latches_disp_needed;
    wire        rr_latches_next_rep_latches_disp_size;
    wire [31:0] rr_latches_next_rep_latches_displacement;
    wire        dc_latches_valid;
    wire        dc_latches_cs_LD_OP;
    wire        dc_latches_cs_ST_OP;
    wire        dc_latches_cs_dr_upper8;
    wire        dc_latches_cs_sr_upper8;
    wire [1:0] dc_latches_cs_datasize;
    wire        dc_latches_mem_cs_ST_OP;
    wire        dc_latches_mem_cs_LD_OP;
    wire        dc_latches_exe_cs_ST_OP;
    wire [31:0] dc_latches_exe_cs_OP_TYPE;
    wire [31:0] dc_latches_exe_cs_alu_inputA_sel;
    wire [31:0] dc_latches_exe_cs_alu_inputB_sel;
    wire [31:0] dc_latches_exe_cs_branch_target_sel;
    wire        dc_latches_exe_cs_shift_by_one;
    wire        dc_latches_exe_cs_br_ucond;
    wire        dc_latches_exe_cs_relative_branch;
    wire        dc_latches_exe_cs_special_br;
    wire        dc_latches_exe_cs_is_far;
    wire        dc_latches_exe_cs_is_call;
    wire        dc_latches_exe_cs_second_flag_needed;
    wire        dc_latches_exe_cs_rep_no_zf_update;
    wire        dc_latches_wb_cs_ST_OP;
    wire        dc_latches_wb_cs_WB_DR;
    wire        dc_latches_wb_cs_WB_SR;
    wire        dc_latches_wb_cs_WB_EAX;
    wire        dc_latches_br_info_valid;
    wire [31:0] dc_latches_br_info_br_eip;
    wire        dc_latches_br_info_br_xcl;
    wire        dc_latches_br_info_br_pred_taken;
    wire [31:0] dc_latches_br_info_speculative_target;
    wire        dc_latches_rr_gp;
    wire [31:0] dc_latches_ld_vaddy;
    wire [31:0] dc_latches_seg0_limit_w_datasize;
    wire [31:0] dc_latches_seg0_limit_wo_datasize;
    wire [31:0] dc_latches_next_ld_vaddy;
    wire [31:0] dc_latches_ld_laddy;
    wire        dc_latches_ld_stack_access;
    wire [31:0] dc_latches_st_vaddy;
    wire [31:0] dc_latches_seg1_limit_w_datasize;
    wire [31:0] dc_latches_seg1_limit_wo_datasize;
    wire [31:0] dc_latches_next_st_vaddy;
    wire [31:0] dc_latches_st_laddy;
    wire        dc_latches_st_stack_access;
    wire [31:0] dc_latches_NEIP;
    wire [31:0] dc_latches_EIP;
    wire [31:0] dc_latches_EAX;
    wire [63:0] dc_latches_imm64;
    wire [4:0] dc_latches_sr_id;
    wire [63:0] dc_latches_sr_data;
    wire [4:0] dc_latches_dr_id;
    wire [63:0] dc_latches_dr_data;
    wire        dc_latches_next_valid;
    wire        dc_latches_next_cs_LD_OP;
    wire        dc_latches_next_cs_ST_OP;
    wire        dc_latches_next_cs_dr_upper8;
    wire        dc_latches_next_cs_sr_upper8;
    wire [1:0] dc_latches_next_cs_datasize;
    wire        dc_latches_next_mem_cs_ST_OP;
    wire        dc_latches_next_mem_cs_LD_OP;
    wire        dc_latches_next_exe_cs_ST_OP;
    wire [31:0] dc_latches_next_exe_cs_OP_TYPE;
    wire [31:0] dc_latches_next_exe_cs_alu_inputA_sel;
    wire [31:0] dc_latches_next_exe_cs_alu_inputB_sel;
    wire [31:0] dc_latches_next_exe_cs_branch_target_sel;
    wire        dc_latches_next_exe_cs_shift_by_one;
    wire        dc_latches_next_exe_cs_br_ucond;
    wire        dc_latches_next_exe_cs_relative_branch;
    wire        dc_latches_next_exe_cs_special_br;
    wire        dc_latches_next_exe_cs_is_far;
    wire        dc_latches_next_exe_cs_is_call;
    wire        dc_latches_next_exe_cs_second_flag_needed;
    wire        dc_latches_next_exe_cs_rep_no_zf_update;
    wire        dc_latches_next_wb_cs_ST_OP;
    wire        dc_latches_next_wb_cs_WB_DR;
    wire        dc_latches_next_wb_cs_WB_SR;
    wire        dc_latches_next_wb_cs_WB_EAX;
    wire        dc_latches_next_br_info_valid;
    wire [31:0] dc_latches_next_br_info_br_eip;
    wire        dc_latches_next_br_info_br_xcl;
    wire        dc_latches_next_br_info_br_pred_taken;
    wire [31:0] dc_latches_next_br_info_speculative_target;
    wire        dc_latches_next_rr_gp;
    //wire [31:0] dc_latches_next_ld_vaddy;duplicate
    wire [31:0] dc_latches_next_seg0_limit_w_datasize;
    wire [31:0] dc_latches_next_seg0_limit_wo_datasize;
    wire [31:0] dc_latches_next_next_ld_vaddy;
    wire [31:0] dc_latches_next_ld_laddy;
    wire        dc_latches_next_ld_stack_access;
    //wire [31:0] dc_latches_next_st_vaddy;duplicate
    wire [31:0] dc_latches_next_seg1_limit_w_datasize;
    wire [31:0] dc_latches_next_seg1_limit_wo_datasize;
    wire [31:0] dc_latches_next_next_st_vaddy;
    wire [31:0] dc_latches_next_st_laddy;
    wire        dc_latches_next_st_stack_access;
    wire [31:0] dc_latches_next_NEIP;
    wire [31:0] dc_latches_next_EIP;
    wire [31:0] dc_latches_next_EAX;
    wire [63:0] dc_latches_next_imm64;
    wire [4:0] dc_latches_next_sr_id;
    wire [63:0] dc_latches_next_sr_data;
    wire [4:0] dc_latches_next_dr_id;
    wire [63:0] dc_latches_next_dr_data;
    wire        mem_latches_valid;
    wire        mem_latches_cs_ST_OP;
    wire        mem_latches_cs_LD_OP;
    wire        mem_latches_exe_cs_ST_OP;
    wire [31:0] mem_latches_exe_cs_OP_TYPE;
    wire [31:0] mem_latches_exe_cs_alu_inputA_sel;
    wire [31:0] mem_latches_exe_cs_alu_inputB_sel;
    wire [31:0] mem_latches_exe_cs_branch_target_sel;
    wire        mem_latches_exe_cs_shift_by_one;
    wire        mem_latches_exe_cs_br_ucond;
    wire        mem_latches_exe_cs_relative_branch;
    wire        mem_latches_exe_cs_special_br;
    wire        mem_latches_exe_cs_is_far;
    wire        mem_latches_exe_cs_is_call;
    wire        mem_latches_exe_cs_second_flag_needed;
    wire        mem_latches_exe_cs_rep_no_zf_update;
    wire        mem_latches_wb_cs_ST_OP;
    wire        mem_latches_wb_cs_WB_DR;
    wire        mem_latches_wb_cs_WB_SR;
    wire        mem_latches_wb_cs_WB_EAX;
    wire        mem_latches_br_info_valid;
    wire [31:0] mem_latches_br_info_br_eip;
    wire        mem_latches_br_info_br_xcl;
    wire        mem_latches_br_info_br_pred_taken;
    wire [31:0] mem_latches_br_info_speculative_target;
    wire [3:0] mem_latches_data_size_vec;
    wire [3:0] mem_latches_sr_data_size_vec;
    wire        mem_latches_shift_sr_up;
    wire        mem_latches_shift_sr_down;
    wire        mem_latches_ST_XCL;
    wire [14:0] mem_latches_ST_PADDR_0;
    wire [14:0] mem_latches_ST_PADDR_1;
    wire        mem_latches_MIO;
    wire [31:0] mem_latches_NEIP;
    wire [31:0] mem_latches_EIP;
    wire [31:0] mem_latches_EAX;
    wire [63:0] mem_latches_imm64;
    wire [4:0] mem_latches_sr_id;
    wire [63:0] mem_latches_sr_data;
    wire [4:0] mem_latches_dr_id;
    wire [63:0] mem_latches_dr_data;
    wire        mem_latches_LD_XCL;
    wire        mem_latches_swapLines;
    wire [14:0] mem_latches_LD_PADDR_0;
    wire [14:0] mem_latches_LD_PADDR_1;
    wire        mem_latches_next_valid;
    wire        mem_latches_next_cs_ST_OP;
    wire        mem_latches_next_cs_LD_OP;
    wire        mem_latches_next_exe_cs_ST_OP;
    wire [31:0] mem_latches_next_exe_cs_OP_TYPE;
    wire [31:0] mem_latches_next_exe_cs_alu_inputA_sel;
    wire [31:0] mem_latches_next_exe_cs_alu_inputB_sel;
    wire [31:0] mem_latches_next_exe_cs_branch_target_sel;
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
    wire [3:0] mem_latches_next_data_size_vec;
    wire [3:0] mem_latches_next_sr_data_size_vec;
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
    wire [4:0] mem_latches_next_sr_id;
    wire [63:0] mem_latches_next_sr_data;
    wire [4:0] mem_latches_next_dr_id;
    wire [63:0] mem_latches_next_dr_data;
    wire        mem_latches_next_LD_XCL;
    wire        mem_latches_next_swapLines;
    wire [14:0] mem_latches_next_LD_PADDR_0;
    wire [14:0] mem_latches_next_LD_PADDR_1;
    wire        exe_latches_valid;
    wire        exe_latches_cs_ST_OP;
    wire [31:0] exe_latches_cs_OP_TYPE;
    wire [31:0] exe_latches_cs_alu_inputA_sel;
    wire [31:0] exe_latches_cs_alu_inputB_sel;
    wire [31:0] exe_latches_cs_branch_target_sel;
    wire        exe_latches_cs_shift_by_one;
    wire        exe_latches_cs_br_ucond;
    wire        exe_latches_cs_relative_branch;
    wire        exe_latches_cs_special_br;
    wire        exe_latches_cs_is_far;
    wire        exe_latches_cs_is_call;
    wire        exe_latches_cs_second_flag_needed;
    wire        exe_latches_cs_rep_no_zf_update;
    wire        exe_latches_wb_cs_ST_OP;
    wire        exe_latches_wb_cs_WB_DR;
    wire        exe_latches_wb_cs_WB_SR;
    wire        exe_latches_wb_cs_WB_EAX;
    wire [3:0] exe_latches_data_size_vec;
    wire [3:0] exe_latches_sr_data_size_vec;
    wire        exe_latches_shift_sr_up;
    wire        exe_latches_shift_sr_down;
    wire        exe_latches_ST_XCL;
    wire [14:0] exe_latches_ST_PADDR_0;
    wire [14:0] exe_latches_ST_PADDR_1;
    wire        exe_latches_MIO;
    wire        exe_latches_br_info_valid;
    wire [31:0] exe_latches_br_info_br_eip;
    wire        exe_latches_br_info_br_xcl;
    wire        exe_latches_br_info_br_pred_taken;
    wire [31:0] exe_latches_br_info_speculative_target;
    wire [31:0] exe_latches_br_rel_target;
    wire [31:0] exe_latches_NEIP;
    wire [31:0] exe_latches_EIP;
    wire [31:0] exe_latches_EAX;
    wire [63:0] exe_latches_imm64;
    wire [4:0] exe_latches_sr_id;
    wire [63:0] exe_latches_sr_data;
    wire [4:0] exe_latches_dr_id;
    wire [63:0] exe_latches_dr_data;
    wire [14:0] exe_latches_ld_addy;
    wire        exe_latches_next_valid;
    wire        exe_latches_next_cs_ST_OP;
    wire [31:0] exe_latches_next_cs_OP_TYPE;
    wire [31:0] exe_latches_next_cs_alu_inputA_sel;
    wire [31:0] exe_latches_next_cs_alu_inputB_sel;
    wire [31:0] exe_latches_next_cs_branch_target_sel;
    wire        exe_latches_next_cs_shift_by_one;
    wire        exe_latches_next_cs_br_ucond;
    wire        exe_latches_next_cs_relative_branch;
    wire        exe_latches_next_cs_special_br;
    wire        exe_latches_next_cs_is_far;
    wire        exe_latches_next_cs_is_call;
    wire        exe_latches_next_cs_second_flag_needed;
    wire        exe_latches_next_cs_rep_no_zf_update;
    wire        exe_latches_next_wb_cs_ST_OP;
    wire        exe_latches_next_wb_cs_WB_DR;
    wire        exe_latches_next_wb_cs_WB_SR;
    wire        exe_latches_next_wb_cs_WB_EAX;
    wire [3:0] exe_latches_next_data_size_vec;
    wire [3:0] exe_latches_next_sr_data_size_vec;
    wire        exe_latches_next_shift_sr_up;
    wire        exe_latches_next_shift_sr_down;
    wire        exe_latches_next_ST_XCL;
    wire [14:0] exe_latches_next_ST_PADDR_0;
    wire [14:0] exe_latches_next_ST_PADDR_1;
    wire        exe_latches_next_MIO;
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
    wire [4:0] exe_latches_next_sr_id;
    wire [63:0] exe_latches_next_sr_data;
    wire [4:0] exe_latches_next_dr_id;
    wire [63:0] exe_latches_next_dr_data;
    wire [14:0] exe_latches_next_ld_addy;
    wire        wb_latches_valid;
    wire        wb_latches_cs_ST_OP;
    wire        wb_latches_cs_WB_DR;
    wire        wb_latches_cs_WB_SR;
    wire        wb_latches_cs_WB_EAX;
    wire        wb_latches_ST_XCL;
    wire [14:0] wb_latches_ST_PADDR_0;
    wire [15:0] wb_latches_ST_BIT_VEC_0;
    wire [14:0] wb_latches_ST_PADDR_1;
    wire [15:0] wb_latches_ST_BIT_VEC_1;
    wire        wb_latches_MIO;
    wire [31:0] wb_latches_EIP;
    wire [4:0] wb_latches_sr_id;
    wire [63:0] wb_latches_sr_data;
    wire [4:0] wb_latches_dr_id;
    wire [63:0] wb_latches_dr_data;
    wire [31:0] wb_latches_EAX;
    wire        wb_latches_next_valid;
    wire        wb_latches_next_cs_ST_OP;
    wire        wb_latches_next_cs_WB_DR;
    wire        wb_latches_next_cs_WB_SR;
    wire        wb_latches_next_cs_WB_EAX;
    wire        wb_latches_next_ST_XCL;
    wire [14:0] wb_latches_next_ST_PADDR_0;
    wire [15:0] wb_latches_next_ST_BIT_VEC_0;
    wire [14:0] wb_latches_next_ST_PADDR_1;
    wire [15:0] wb_latches_next_ST_BIT_VEC_1;
    wire        wb_latches_next_MIO;
    wire [31:0] wb_latches_next_EIP;
    wire [4:0] wb_latches_next_sr_id;
    wire [63:0] wb_latches_next_sr_data;
    wire [4:0] wb_latches_next_dr_id;
    wire [63:0] wb_latches_next_dr_data;
    wire [31:0] wb_latches_next_EAX;

    // ====================================================================
    // Fetch byte-array bridges
    //   - in : ICacheIn_instruction_line is already a packed 128-bit bus
    //          on the new flat-port boundary, just alias it.
    //   - out: per-slot idm_reqs.req[].data[16] <- packed [127:0] bus
    //          driven directly by the flat-port IDM.
    // ====================================================================
    wire [127:0] icache_instruction_line_w;
    assign icache_instruction_line_w = ICacheIn_instruction_line;

    // Flat-port Fetch drives 128-bit packed buses directly into IDM; no
    // struct byte-array bridge is needed since the new IDM also has
    // flat (packed) data ports.
    wire [127:0] fetch_idm_req_0_data_w, fetch_idm_req_1_data_w;
    wire [127:0] fetch_idm_req_2_data_w, fetch_idm_req_3_data_w;

    // Flat-port IDM drives 128-bit packed slot data directly into Decode;
    // again, no struct byte-array bridge needed.
    wire [127:0] idm_slot_0_data_w, idm_slot_1_data_w;
    wire [127:0] idm_slot_2_data_w, idm_slot_3_data_w;

    // ====================================================================
    // DCache cacheline / line_MIO buses are already packed 128-bit on
    // the new flat-port boundary -- alias the per-port flat inputs into
    // the array indexed by MEM's flat-port instantiation below.
    // ====================================================================
    wire [127:0] dcache_cacheline_w [0:3];
    wire [127:0] dcache_line_MIO_w;

    assign dcache_cacheline_w[0] = DCacheIn_cacheline_0;
    assign dcache_cacheline_w[1] = DCacheIn_cacheline_1;
    assign dcache_cacheline_w[2] = DCacheIn_cacheline_2;
    assign dcache_cacheline_w[3] = DCacheIn_cacheline_3;
    assign dcache_line_MIO_w     = DCacheIn_line_MIO;

    // ====================================================================
    // out2ICache / out2DCache flat output assigns
    //   - The original SV used struct literals; here every field is its
    //     own flat output port and is driven individually.
    //   - Per-slot byte arrays in wb_outputs_stq_heads[*].data and
    //     mio_head.data are already pre-packed in the WB byte-array
    //     bridges (wb_stq_head_*_data_w / wb_mio_head_data_w) above.
    // ====================================================================
    assign out2ICache_icache_en           = fetch_outputs_fetch_2_icache_icache_en;
    assign out2ICache_p_addr              = fetch_outputs_fetch_2_icache_p_addr;
    assign out2ICache_v_addr_i            = fetch_outputs_fetch_2_icache_v_addr_i;
    assign out2ICache_num_valid_IDM_slots = fetch_outputs_fetch_2_icache_num_valid_IDM_slots;

    assign out2DCache_ld_addr_0_V    = dc_outputs_ld_addr_0_V;
    assign out2DCache_ld_addr_0      = dc_outputs_ld_addr_0;
    assign out2DCache_ld_addr_1_V    = dc_outputs_ld_addr_1_V;
    assign out2DCache_ld_addr_1      = dc_outputs_ld_addr_1;
    assign out2DCache_ld_addr_MIO_V  = dc_outputs_ld_addr_MIO_V;
    assign out2DCache_ld_addr_MIO    = dc_outputs_ld_addr_MIO;

    assign out2DCache_stq_heads_0_full    = wb_outputs_stq_heads_0_full;
    assign out2DCache_stq_heads_0_empty   = wb_outputs_stq_heads_0_empty;
    assign out2DCache_stq_heads_0_address = wb_outputs_stq_heads_0_address;
    assign out2DCache_stq_heads_0_bit_vec = wb_outputs_stq_heads_0_bit_vec;
    assign out2DCache_stq_heads_0_data    = wb_stq_head_0_data_w;

    assign out2DCache_stq_heads_1_full    = wb_outputs_stq_heads_1_full;
    assign out2DCache_stq_heads_1_empty   = wb_outputs_stq_heads_1_empty;
    assign out2DCache_stq_heads_1_address = wb_outputs_stq_heads_1_address;
    assign out2DCache_stq_heads_1_bit_vec = wb_outputs_stq_heads_1_bit_vec;
    assign out2DCache_stq_heads_1_data    = wb_stq_head_1_data_w;

    assign out2DCache_stq_heads_2_full    = wb_outputs_stq_heads_2_full;
    assign out2DCache_stq_heads_2_empty   = wb_outputs_stq_heads_2_empty;
    assign out2DCache_stq_heads_2_address = wb_outputs_stq_heads_2_address;
    assign out2DCache_stq_heads_2_bit_vec = wb_outputs_stq_heads_2_bit_vec;
    assign out2DCache_stq_heads_2_data    = wb_stq_head_2_data_w;

    assign out2DCache_stq_heads_3_full    = wb_outputs_stq_heads_3_full;
    assign out2DCache_stq_heads_3_empty   = wb_outputs_stq_heads_3_empty;
    assign out2DCache_stq_heads_3_address = wb_outputs_stq_heads_3_address;
    assign out2DCache_stq_heads_3_bit_vec = wb_outputs_stq_heads_3_bit_vec;
    assign out2DCache_stq_heads_3_data    = wb_stq_head_3_data_w;

    assign out2DCache_stq_info_mio_full    = wb_outputs_mio_head_full;
    assign out2DCache_stq_info_mio_empty   = wb_outputs_mio_head_empty;
    assign out2DCache_stq_info_mio_address = wb_outputs_mio_head_address;
    assign out2DCache_stq_info_mio_bit_vec = wb_outputs_mio_head_bit_vec;
    assign out2DCache_stq_info_mio_data    = wb_mio_head_data_w;

    assign out2DCache_memStage_CLR_REQ_0   = mem_outputs_clr_dcache_arb_latches_0;
    assign out2DCache_memStage_CLR_REQ_1   = mem_outputs_clr_dcache_arb_latches_1;
    assign out2DCache_memStage_CLR_REQ_2   = mem_outputs_clr_dcache_arb_latches_2;
    assign out2DCache_memStage_CLR_REQ_3   = mem_outputs_clr_dcache_arb_latches_3;
    assign out2DCache_memStage_CLR_REQ_MIO = mem_outputs_clr_dcache_mio_latch;

    // ====================================================================
    // Fetch (flat-port .v)
    // ====================================================================
    Fetch fetch_unit (
        .clk(clk),
        .rst(rst),

        .icache_info_hit              (ICacheIn_hit),
        .icache_info_instruction_line (icache_instruction_line_w),

        .idm_info_idm_slots_0_valid          (idm_outputs_idm_slots_0_valid),
        .idm_info_idm_slots_0_br_valid       (idm_outputs_idm_slots_0_br_valid),
        .idm_info_idm_slots_0_br_eip         (idm_outputs_idm_slots_0_br_eip),
        .idm_info_idm_slots_0_br_btb_target  (idm_outputs_idm_slots_0_br_btb_target),
        .idm_info_idm_slots_0_br_xcl         (idm_outputs_idm_slots_0_br_xcl),
        .idm_info_idm_slots_1_valid          (idm_outputs_idm_slots_1_valid),
        .idm_info_idm_slots_1_br_valid       (idm_outputs_idm_slots_1_br_valid),
        .idm_info_idm_slots_1_br_eip         (idm_outputs_idm_slots_1_br_eip),
        .idm_info_idm_slots_1_br_btb_target  (idm_outputs_idm_slots_1_br_btb_target),
        .idm_info_idm_slots_1_br_xcl         (idm_outputs_idm_slots_1_br_xcl),
        .idm_info_idm_slots_2_valid          (idm_outputs_idm_slots_2_valid),
        .idm_info_idm_slots_2_br_valid       (idm_outputs_idm_slots_2_br_valid),
        .idm_info_idm_slots_2_br_eip         (idm_outputs_idm_slots_2_br_eip),
        .idm_info_idm_slots_2_br_btb_target  (idm_outputs_idm_slots_2_br_btb_target),
        .idm_info_idm_slots_2_br_xcl         (idm_outputs_idm_slots_2_br_xcl),
        .idm_info_idm_slots_3_valid          (idm_outputs_idm_slots_3_valid),
        .idm_info_idm_slots_3_br_valid       (idm_outputs_idm_slots_3_br_valid),
        .idm_info_idm_slots_3_br_eip         (idm_outputs_idm_slots_3_br_eip),
        .idm_info_idm_slots_3_br_btb_target  (idm_outputs_idm_slots_3_br_btb_target),
        .idm_info_idm_slots_3_br_xcl         (idm_outputs_idm_slots_3_br_xcl),
        .idm_info_valid_slots                (idm_outputs_valid_slots),

        .decode_outs_eip                 (decode_outputs_eip),
        .decode_outs_stall               (decode_outputs_stall),
        .decode_outs_decode_forward      (decode_outputs_decode_forward),
        .decode_outs_invalid_instruction (decode_outputs_invalid_instruction),

        .rr_outs_valid          (rr_outputs_valid),
        .rr_outs_codeSeg_sb     (rr_outputs_codeSeg_sb),
        .rr_outs_codeSeg_data   (rr_outputs_codeSeg_data),
        .rr_outs_codeSeg_limit  (rr_outputs_codeSeg_limit),

        .dc_outs_valid       (dc_outputs_valid),
        .dc_outs_exp_present (dc_outputs_exp_present),
        .dc_outs_exp_pf      (dc_outputs_exp_pf),

        .mem_outs_valid (mem_outputs_valid),

        .exe_outs_valid                       (exe_outputs_valid),
        .exe_outs_br_res_out_valid            (exe_outputs_br_res_out_valid),
        .exe_outs_br_res_out_flush            (exe_outputs_br_res_out_flush),
        .exe_outs_br_res_out_miss_prediction  (exe_outputs_br_res_out_miss_prediction),
        .exe_outs_br_res_out_br_eip           (exe_outputs_br_res_out_br_eip),
        .exe_outs_br_res_out_neip             (exe_outputs_br_res_out_neip),
        .exe_outs_br_res_out_br_target        (exe_outputs_br_res_out_br_target),
        .exe_outs_br_res_out_taken            (exe_outputs_br_res_out_taken),
        .exe_outs_br_res_out_br_XCL           (exe_outputs_br_res_out_br_XCL),
        .exe_outs_br_res_out_clr_exp_mode     (exe_outputs_br_res_out_clr_exp_mode),
        .exe_outs_br_res_out_br_ucond         (exe_outputs_br_res_out_br_ucond),

        .wb_outs_valid (wb_outputs_valid),

        .dma_int (inFromDMA_intOut),

        // ---- fetch_outputs_t outputs (driven into the SV struct) ----
        .outs_fetch_2_icache_icache_en           (fetch_outputs_fetch_2_icache_icache_en),
        .outs_fetch_2_icache_p_addr              (fetch_outputs_fetch_2_icache_p_addr),
        .outs_fetch_2_icache_v_addr_i            (fetch_outputs_fetch_2_icache_v_addr_i),
        .outs_fetch_2_icache_num_valid_IDM_slots (fetch_outputs_fetch_2_icache_num_valid_IDM_slots),

        .outs_idm_reqs_req_0_ld_meta_data (fetch_outputs_idm_reqs_req_0_ld_meta_data),
        .outs_idm_reqs_req_0_ld_data      (fetch_outputs_idm_reqs_req_0_ld_data),
        .outs_idm_reqs_req_0_valid        (fetch_outputs_idm_reqs_req_0_valid),
        .outs_idm_reqs_req_0_br_valid     (fetch_outputs_idm_reqs_req_0_br_valid),
        .outs_idm_reqs_req_0_br_eip       (fetch_outputs_idm_reqs_req_0_br_eip),
        .outs_idm_reqs_req_0_br_target    (fetch_outputs_idm_reqs_req_0_br_target),
        .outs_idm_reqs_req_0_br_xcl       (fetch_outputs_idm_reqs_req_0_br_xcl),
        .outs_idm_reqs_req_0_data         (fetch_idm_req_0_data_w),

        .outs_idm_reqs_req_1_ld_meta_data (fetch_outputs_idm_reqs_req_1_ld_meta_data),
        .outs_idm_reqs_req_1_ld_data      (fetch_outputs_idm_reqs_req_1_ld_data),
        .outs_idm_reqs_req_1_valid        (fetch_outputs_idm_reqs_req_1_valid),
        .outs_idm_reqs_req_1_br_valid     (fetch_outputs_idm_reqs_req_1_br_valid),
        .outs_idm_reqs_req_1_br_eip       (fetch_outputs_idm_reqs_req_1_br_eip),
        .outs_idm_reqs_req_1_br_target    (fetch_outputs_idm_reqs_req_1_br_target),
        .outs_idm_reqs_req_1_br_xcl       (fetch_outputs_idm_reqs_req_1_br_xcl),
        .outs_idm_reqs_req_1_data         (fetch_idm_req_1_data_w),

        .outs_idm_reqs_req_2_ld_meta_data (fetch_outputs_idm_reqs_req_2_ld_meta_data),
        .outs_idm_reqs_req_2_ld_data      (fetch_outputs_idm_reqs_req_2_ld_data),
        .outs_idm_reqs_req_2_valid        (fetch_outputs_idm_reqs_req_2_valid),
        .outs_idm_reqs_req_2_br_valid     (fetch_outputs_idm_reqs_req_2_br_valid),
        .outs_idm_reqs_req_2_br_eip       (fetch_outputs_idm_reqs_req_2_br_eip),
        .outs_idm_reqs_req_2_br_target    (fetch_outputs_idm_reqs_req_2_br_target),
        .outs_idm_reqs_req_2_br_xcl       (fetch_outputs_idm_reqs_req_2_br_xcl),
        .outs_idm_reqs_req_2_data         (fetch_idm_req_2_data_w),

        .outs_idm_reqs_req_3_ld_meta_data (fetch_outputs_idm_reqs_req_3_ld_meta_data),
        .outs_idm_reqs_req_3_ld_data      (fetch_outputs_idm_reqs_req_3_ld_data),
        .outs_idm_reqs_req_3_valid        (fetch_outputs_idm_reqs_req_3_valid),
        .outs_idm_reqs_req_3_br_valid     (fetch_outputs_idm_reqs_req_3_br_valid),
        .outs_idm_reqs_req_3_br_eip       (fetch_outputs_idm_reqs_req_3_br_eip),
        .outs_idm_reqs_req_3_br_target    (fetch_outputs_idm_reqs_req_3_br_target),
        .outs_idm_reqs_req_3_br_xcl       (fetch_outputs_idm_reqs_req_3_br_xcl),
        .outs_idm_reqs_req_3_data         (fetch_idm_req_3_data_w),

        .outs_exp_pipe_clear (fetch_outputs_exp_pipe_clear),
        .outs_exp_present    (fetch_outputs_exp_present),
        .outs_exp_pf         (fetch_outputs_exp_pf),
        .outs_exp_mode_jk    (fetch_outputs_exp_mode_jk),
        .outs_int_mode_jk    (fetch_outputs_int_mode_jk)
    );

    // ====================================================================
    // IDM (flat-port .v)
    //   Inputs come from flat-port Fetch's outputs (struct fields of
    //   fetch_outputs, plus the per-slot 128-bit packed data buses).
    //   Outputs drive the SV struct fields of idm_outputs (still struct
    //   so RR_Latches and downstream consumers see one signal name) and
    //   directly drive the 128-bit packed slot-data buses for Decode.
    // ====================================================================
    IDM idm_unit (
        .clk(clk),
        .rst(rst),

        .fetch_outs_exp_pipe_clear (fetch_outputs_exp_pipe_clear),

        .fetch_outs_idm_reqs_req_0_ld_meta_data (fetch_outputs_idm_reqs_req_0_ld_meta_data),
        .fetch_outs_idm_reqs_req_0_ld_data      (fetch_outputs_idm_reqs_req_0_ld_data),
        .fetch_outs_idm_reqs_req_0_valid        (fetch_outputs_idm_reqs_req_0_valid),
        .fetch_outs_idm_reqs_req_0_br_valid     (fetch_outputs_idm_reqs_req_0_br_valid),
        .fetch_outs_idm_reqs_req_0_br_eip       (fetch_outputs_idm_reqs_req_0_br_eip),
        .fetch_outs_idm_reqs_req_0_br_target    (fetch_outputs_idm_reqs_req_0_br_target),
        .fetch_outs_idm_reqs_req_0_br_xcl       (fetch_outputs_idm_reqs_req_0_br_xcl),
        .fetch_outs_idm_reqs_req_0_data         (fetch_idm_req_0_data_w),

        .fetch_outs_idm_reqs_req_1_ld_meta_data (fetch_outputs_idm_reqs_req_1_ld_meta_data),
        .fetch_outs_idm_reqs_req_1_ld_data      (fetch_outputs_idm_reqs_req_1_ld_data),
        .fetch_outs_idm_reqs_req_1_valid        (fetch_outputs_idm_reqs_req_1_valid),
        .fetch_outs_idm_reqs_req_1_br_valid     (fetch_outputs_idm_reqs_req_1_br_valid),
        .fetch_outs_idm_reqs_req_1_br_eip       (fetch_outputs_idm_reqs_req_1_br_eip),
        .fetch_outs_idm_reqs_req_1_br_target    (fetch_outputs_idm_reqs_req_1_br_target),
        .fetch_outs_idm_reqs_req_1_br_xcl       (fetch_outputs_idm_reqs_req_1_br_xcl),
        .fetch_outs_idm_reqs_req_1_data         (fetch_idm_req_1_data_w),

        .fetch_outs_idm_reqs_req_2_ld_meta_data (fetch_outputs_idm_reqs_req_2_ld_meta_data),
        .fetch_outs_idm_reqs_req_2_ld_data      (fetch_outputs_idm_reqs_req_2_ld_data),
        .fetch_outs_idm_reqs_req_2_valid        (fetch_outputs_idm_reqs_req_2_valid),
        .fetch_outs_idm_reqs_req_2_br_valid     (fetch_outputs_idm_reqs_req_2_br_valid),
        .fetch_outs_idm_reqs_req_2_br_eip       (fetch_outputs_idm_reqs_req_2_br_eip),
        .fetch_outs_idm_reqs_req_2_br_target    (fetch_outputs_idm_reqs_req_2_br_target),
        .fetch_outs_idm_reqs_req_2_br_xcl       (fetch_outputs_idm_reqs_req_2_br_xcl),
        .fetch_outs_idm_reqs_req_2_data         (fetch_idm_req_2_data_w),

        .fetch_outs_idm_reqs_req_3_ld_meta_data (fetch_outputs_idm_reqs_req_3_ld_meta_data),
        .fetch_outs_idm_reqs_req_3_ld_data      (fetch_outputs_idm_reqs_req_3_ld_data),
        .fetch_outs_idm_reqs_req_3_valid        (fetch_outputs_idm_reqs_req_3_valid),
        .fetch_outs_idm_reqs_req_3_br_valid     (fetch_outputs_idm_reqs_req_3_br_valid),
        .fetch_outs_idm_reqs_req_3_br_eip       (fetch_outputs_idm_reqs_req_3_br_eip),
        .fetch_outs_idm_reqs_req_3_br_target    (fetch_outputs_idm_reqs_req_3_br_target),
        .fetch_outs_idm_reqs_req_3_br_xcl       (fetch_outputs_idm_reqs_req_3_br_xcl),
        .fetch_outs_idm_reqs_req_3_data         (fetch_idm_req_3_data_w),

        .idm_outs_valid_slots                  (idm_outputs_valid_slots),

        .idm_outs_idm_slots_0_valid            (idm_outputs_idm_slots_0_valid),
        .idm_outs_idm_slots_0_br_valid         (idm_outputs_idm_slots_0_br_valid),
        .idm_outs_idm_slots_0_br_eip           (idm_outputs_idm_slots_0_br_eip),
        .idm_outs_idm_slots_0_br_btb_target    (idm_outputs_idm_slots_0_br_btb_target),
        .idm_outs_idm_slots_0_br_xcl           (idm_outputs_idm_slots_0_br_xcl),
        .idm_outs_idm_slots_0_data             (idm_slot_0_data_w),

        .idm_outs_idm_slots_1_valid            (idm_outputs_idm_slots_1_valid),
        .idm_outs_idm_slots_1_br_valid         (idm_outputs_idm_slots_1_br_valid),
        .idm_outs_idm_slots_1_br_eip           (idm_outputs_idm_slots_1_br_eip),
        .idm_outs_idm_slots_1_br_btb_target    (idm_outputs_idm_slots_1_br_btb_target),
        .idm_outs_idm_slots_1_br_xcl           (idm_outputs_idm_slots_1_br_xcl),
        .idm_outs_idm_slots_1_data             (idm_slot_1_data_w),

        .idm_outs_idm_slots_2_valid            (idm_outputs_idm_slots_2_valid),
        .idm_outs_idm_slots_2_br_valid         (idm_outputs_idm_slots_2_br_valid),
        .idm_outs_idm_slots_2_br_eip           (idm_outputs_idm_slots_2_br_eip),
        .idm_outs_idm_slots_2_br_btb_target    (idm_outputs_idm_slots_2_br_btb_target),
        .idm_outs_idm_slots_2_br_xcl           (idm_outputs_idm_slots_2_br_xcl),
        .idm_outs_idm_slots_2_data             (idm_slot_2_data_w),

        .idm_outs_idm_slots_3_valid            (idm_outputs_idm_slots_3_valid),
        .idm_outs_idm_slots_3_br_valid         (idm_outputs_idm_slots_3_br_valid),
        .idm_outs_idm_slots_3_br_eip           (idm_outputs_idm_slots_3_br_eip),
        .idm_outs_idm_slots_3_br_btb_target    (idm_outputs_idm_slots_3_br_btb_target),
        .idm_outs_idm_slots_3_br_xcl           (idm_outputs_idm_slots_3_br_xcl),
        .idm_outs_idm_slots_3_data             (idm_slot_3_data_w)
    );

    // ====================================================================
    // Decode (flat-port .v)
    // ====================================================================
    Decode decode_unit (
        .clk(clk),
        .rst(rst),

        // idm_outputs_t
        .idm_outs_idm_slots_0_valid          (idm_outputs_idm_slots_0_valid),
        .idm_outs_idm_slots_0_br_valid       (idm_outputs_idm_slots_0_br_valid),
        .idm_outs_idm_slots_0_br_eip         (idm_outputs_idm_slots_0_br_eip),
        .idm_outs_idm_slots_0_br_btb_target  (idm_outputs_idm_slots_0_br_btb_target),
        .idm_outs_idm_slots_0_data           (idm_slot_0_data_w),
        .idm_outs_idm_slots_1_valid          (idm_outputs_idm_slots_1_valid),
        .idm_outs_idm_slots_1_br_valid       (idm_outputs_idm_slots_1_br_valid),
        .idm_outs_idm_slots_1_br_eip         (idm_outputs_idm_slots_1_br_eip),
        .idm_outs_idm_slots_1_br_btb_target  (idm_outputs_idm_slots_1_br_btb_target),
        .idm_outs_idm_slots_1_data           (idm_slot_1_data_w),
        .idm_outs_idm_slots_2_valid          (idm_outputs_idm_slots_2_valid),
        .idm_outs_idm_slots_2_br_valid       (idm_outputs_idm_slots_2_br_valid),
        .idm_outs_idm_slots_2_br_eip         (idm_outputs_idm_slots_2_br_eip),
        .idm_outs_idm_slots_2_br_btb_target  (idm_outputs_idm_slots_2_br_btb_target),
        .idm_outs_idm_slots_2_data           (idm_slot_2_data_w),
        .idm_outs_idm_slots_3_valid          (idm_outputs_idm_slots_3_valid),
        .idm_outs_idm_slots_3_br_valid       (idm_outputs_idm_slots_3_br_valid),
        .idm_outs_idm_slots_3_br_eip         (idm_outputs_idm_slots_3_br_eip),
        .idm_outs_idm_slots_3_br_btb_target  (idm_outputs_idm_slots_3_br_btb_target),
        .idm_outs_idm_slots_3_data           (idm_slot_3_data_w),

        .fetch_outs_exp_pipe_clear (fetch_outputs_exp_pipe_clear),
        .fetch_outs_exp_mode_jk    (fetch_outputs_exp_mode_jk),
        .fetch_outs_int_mode_jk    (fetch_outputs_int_mode_jk),

        .rr_outs_valid          (rr_outputs_valid),
        .rr_outs_stall          (rr_outputs_stall),
        .rr_outs_ecx_sb         (rr_outputs_ecx_sb),
        .rr_outs_ecx            (rr_outputs_ecx),
        .rr_outs_eax            (rr_outputs_eax),
        .rr_outs_codeSeg_limit  (rr_outputs_codeSeg_limit),

        .dc_outs_valid  (dc_outputs_valid),
        .dc_outs_dc_eip (dc_outputs_dc_eip),
        .dc_outs_stall  (dc_outputs_stall),

        .mem_outs_valid (mem_outputs_valid),
        .mem_outs_stall (mem_outputs_stall),

        .exe_outs_valid                  (exe_outputs_valid),
        .exe_outs_br_res_out_valid       (exe_outputs_br_res_out_valid),
        .exe_outs_br_res_out_flush       (exe_outputs_br_res_out_flush),
        .exe_outs_br_res_out_br_target   (exe_outputs_br_res_out_br_target),
        .exe_outs_clr_ZF_sb              (exe_outputs_clr_ZF_sb),
        .exe_outs_ZF                     (exe_outputs_ZF),

        .wb_outs_wb_stall (wb_outputs_wb_stall),

        // ---- rr_latches_next (rr_latches_t) outputs into the SV struct ----
        .rr_latches_next_normal_latches_valid                     (rr_latches_next_normal_latches_valid),
        .rr_latches_next_normal_latches_cs_ST_SEL                 (rr_latches_next_normal_latches_cs_ST_SEL),
        .rr_latches_next_normal_latches_cs_MODRM_NEEDED           (rr_latches_next_normal_latches_cs_MODRM_NEEDED),
        .rr_latches_next_normal_latches_cs_RM_IS_DR               (rr_latches_next_normal_latches_cs_RM_IS_DR),
        .rr_latches_next_normal_latches_cs_SWITCH_LD_ADDY         (rr_latches_next_normal_latches_cs_SWITCH_LD_ADDY),
        .rr_latches_next_normal_latches_cs_LD_OP                  (rr_latches_next_normal_latches_cs_LD_OP),
        .rr_latches_next_normal_latches_cs_ST_OP                  (rr_latches_next_normal_latches_cs_ST_OP),
        .rr_latches_next_normal_latches_cs_dr_id                  (rr_latches_next_normal_latches_cs_dr_id),
        .rr_latches_next_normal_latches_cs_sr_id                  (rr_latches_next_normal_latches_cs_sr_id),
        .rr_latches_next_normal_latches_cs_dr_rd                  (rr_latches_next_normal_latches_cs_dr_rd),
        .rr_latches_next_normal_latches_cs_sr_rd                  (rr_latches_next_normal_latches_cs_sr_rd),
        .rr_latches_next_normal_latches_cs_eax_rd                 (rr_latches_next_normal_latches_cs_eax_rd),
        .rr_latches_next_normal_latches_cs_dr_wr                  (rr_latches_next_normal_latches_cs_dr_wr),
        .rr_latches_next_normal_latches_cs_sr_wr                  (rr_latches_next_normal_latches_cs_sr_wr),
        .rr_latches_next_normal_latches_cs_eax_wr                 (rr_latches_next_normal_latches_cs_eax_wr),
        .rr_latches_next_normal_latches_cs_MOVS_OP                (rr_latches_next_normal_latches_cs_MOVS_OP),
        .rr_latches_next_normal_latches_cs_datasize               (rr_latches_next_normal_latches_cs_datasize),
        .rr_latches_next_normal_latches_cs_will_mod_zf            (rr_latches_next_normal_latches_cs_will_mod_zf),
        .rr_latches_next_normal_latches_cs_seg_1_valid            (rr_latches_next_normal_latches_cs_seg_1_valid),
        .rr_latches_next_normal_latches_cs_seg_0_id               (rr_latches_next_normal_latches_cs_seg_0_id),
        .rr_latches_next_normal_latches_cs_seg_1_id               (rr_latches_next_normal_latches_cs_seg_1_id),
        .rr_latches_next_normal_latches_cs_special_modrm_bs       (rr_latches_next_normal_latches_cs_special_modrm_bs),
        .rr_latches_next_normal_latches_cs_special_br             (rr_latches_next_normal_latches_cs_special_br),
        .rr_latches_next_normal_latches_dc_cs_LD_OP               (rr_latches_next_normal_latches_dc_cs_LD_OP),
        .rr_latches_next_normal_latches_dc_cs_ST_OP               (rr_latches_next_normal_latches_dc_cs_ST_OP),
        .rr_latches_next_normal_latches_dc_cs_dr_upper8           (rr_latches_next_normal_latches_dc_cs_dr_upper8),
        .rr_latches_next_normal_latches_dc_cs_sr_upper8           (rr_latches_next_normal_latches_dc_cs_sr_upper8),
        .rr_latches_next_normal_latches_dc_cs_datasize            (rr_latches_next_normal_latches_dc_cs_datasize),
        .rr_latches_next_normal_latches_mem_cs_ST_OP              (rr_latches_next_normal_latches_mem_cs_ST_OP),
        .rr_latches_next_normal_latches_mem_cs_LD_OP              (rr_latches_next_normal_latches_mem_cs_LD_OP),
        .rr_latches_next_normal_latches_exe_cs_ST_OP              (rr_latches_next_normal_latches_exe_cs_ST_OP),
        .rr_latches_next_normal_latches_exe_cs_OP_TYPE            (rr_latches_next_normal_latches_exe_cs_OP_TYPE[5:0]),
        .rr_latches_next_normal_latches_exe_cs_alu_inputA_sel     (rr_latches_next_normal_latches_exe_cs_alu_inputA_sel[4:0]),
        .rr_latches_next_normal_latches_exe_cs_alu_inputB_sel     (rr_latches_next_normal_latches_exe_cs_alu_inputB_sel[4:0]),
        .rr_latches_next_normal_latches_exe_cs_branch_target_sel  (rr_latches_next_normal_latches_exe_cs_branch_target_sel[4:0]),
        .rr_latches_next_normal_latches_exe_cs_shift_by_one       (rr_latches_next_normal_latches_exe_cs_shift_by_one),
        .rr_latches_next_normal_latches_exe_cs_br_ucond           (rr_latches_next_normal_latches_exe_cs_br_ucond),
        .rr_latches_next_normal_latches_exe_cs_relative_branch    (rr_latches_next_normal_latches_exe_cs_relative_branch),
        .rr_latches_next_normal_latches_exe_cs_special_br         (rr_latches_next_normal_latches_exe_cs_special_br),
        .rr_latches_next_normal_latches_exe_cs_is_far             (rr_latches_next_normal_latches_exe_cs_is_far),
        .rr_latches_next_normal_latches_exe_cs_is_call            (rr_latches_next_normal_latches_exe_cs_is_call),
        .rr_latches_next_normal_latches_exe_cs_second_flag_needed (rr_latches_next_normal_latches_exe_cs_second_flag_needed),
        .rr_latches_next_normal_latches_exe_cs_rep_no_zf_update   (rr_latches_next_normal_latches_exe_cs_rep_no_zf_update),
        .rr_latches_next_normal_latches_wb_cs_ST_OP               (rr_latches_next_normal_latches_wb_cs_ST_OP),
        .rr_latches_next_normal_latches_wb_cs_WB_DR               (rr_latches_next_normal_latches_wb_cs_WB_DR),
        .rr_latches_next_normal_latches_wb_cs_WB_SR               (rr_latches_next_normal_latches_wb_cs_WB_SR),
        .rr_latches_next_normal_latches_wb_cs_WB_EAX              (rr_latches_next_normal_latches_wb_cs_WB_EAX),
        .rr_latches_next_normal_latches_br_info_valid             (rr_latches_next_normal_latches_br_info_valid),
        .rr_latches_next_normal_latches_br_info_br_eip            (rr_latches_next_normal_latches_br_info_br_eip),
        .rr_latches_next_normal_latches_br_info_br_xcl            (rr_latches_next_normal_latches_br_info_br_xcl),
        .rr_latches_next_normal_latches_br_info_br_pred_taken     (rr_latches_next_normal_latches_br_info_br_pred_taken),
        .rr_latches_next_normal_latches_br_info_speculative_target(rr_latches_next_normal_latches_br_info_speculative_target),
        .rr_latches_next_normal_latches_NEIP                      (rr_latches_next_normal_latches_NEIP),
        .rr_latches_next_normal_latches_EIP                       (rr_latches_next_normal_latches_EIP),
        .rr_latches_next_normal_latches_EAX                       (rr_latches_next_normal_latches_EAX),
        .rr_latches_next_normal_latches_imm64                     (rr_latches_next_normal_latches_imm64),
        .rr_latches_next_normal_latches_sib_idx_id                (rr_latches_next_normal_latches_sib_idx_id),
        .rr_latches_next_normal_latches_sib_base_id               (rr_latches_next_normal_latches_sib_base_id),
        .rr_latches_next_normal_latches_sib_needed                (rr_latches_next_normal_latches_sib_needed),
        .rr_latches_next_normal_latches_sib_scale                 (rr_latches_next_normal_latches_sib_scale),
        .rr_latches_next_normal_latches_disp_needed               (rr_latches_next_normal_latches_disp_needed),
        .rr_latches_next_normal_latches_disp_size                 (rr_latches_next_normal_latches_disp_size),
        .rr_latches_next_normal_latches_displacement              (rr_latches_next_normal_latches_displacement),

        .rr_latches_next_rep_latches_valid                     (rr_latches_next_rep_latches_valid),
        .rr_latches_next_rep_latches_cs_ST_SEL                 (rr_latches_next_rep_latches_cs_ST_SEL),
        .rr_latches_next_rep_latches_cs_MODRM_NEEDED           (rr_latches_next_rep_latches_cs_MODRM_NEEDED),
        .rr_latches_next_rep_latches_cs_RM_IS_DR               (rr_latches_next_rep_latches_cs_RM_IS_DR),
        .rr_latches_next_rep_latches_cs_SWITCH_LD_ADDY         (rr_latches_next_rep_latches_cs_SWITCH_LD_ADDY),
        .rr_latches_next_rep_latches_cs_LD_OP                  (rr_latches_next_rep_latches_cs_LD_OP),
        .rr_latches_next_rep_latches_cs_ST_OP                  (rr_latches_next_rep_latches_cs_ST_OP),
        .rr_latches_next_rep_latches_cs_dr_id                  (rr_latches_next_rep_latches_cs_dr_id),
        .rr_latches_next_rep_latches_cs_sr_id                  (rr_latches_next_rep_latches_cs_sr_id),
        .rr_latches_next_rep_latches_cs_dr_rd                  (rr_latches_next_rep_latches_cs_dr_rd),
        .rr_latches_next_rep_latches_cs_sr_rd                  (rr_latches_next_rep_latches_cs_sr_rd),
        .rr_latches_next_rep_latches_cs_eax_rd                 (rr_latches_next_rep_latches_cs_eax_rd),
        .rr_latches_next_rep_latches_cs_dr_wr                  (rr_latches_next_rep_latches_cs_dr_wr),
        .rr_latches_next_rep_latches_cs_sr_wr                  (rr_latches_next_rep_latches_cs_sr_wr),
        .rr_latches_next_rep_latches_cs_eax_wr                 (rr_latches_next_rep_latches_cs_eax_wr),
        .rr_latches_next_rep_latches_cs_MOVS_OP                (rr_latches_next_rep_latches_cs_MOVS_OP),
        .rr_latches_next_rep_latches_cs_datasize               (rr_latches_next_rep_latches_cs_datasize),
        .rr_latches_next_rep_latches_cs_will_mod_zf            (rr_latches_next_rep_latches_cs_will_mod_zf),
        .rr_latches_next_rep_latches_cs_seg_1_valid            (rr_latches_next_rep_latches_cs_seg_1_valid),
        .rr_latches_next_rep_latches_cs_seg_0_id               (rr_latches_next_rep_latches_cs_seg_0_id),
        .rr_latches_next_rep_latches_cs_seg_1_id               (rr_latches_next_rep_latches_cs_seg_1_id),
        .rr_latches_next_rep_latches_cs_special_modrm_bs       (rr_latches_next_rep_latches_cs_special_modrm_bs),
        .rr_latches_next_rep_latches_cs_special_br             (rr_latches_next_rep_latches_cs_special_br),
        .rr_latches_next_rep_latches_dc_cs_LD_OP               (rr_latches_next_rep_latches_dc_cs_LD_OP),
        .rr_latches_next_rep_latches_dc_cs_ST_OP               (rr_latches_next_rep_latches_dc_cs_ST_OP),
        .rr_latches_next_rep_latches_dc_cs_dr_upper8           (rr_latches_next_rep_latches_dc_cs_dr_upper8),
        .rr_latches_next_rep_latches_dc_cs_sr_upper8           (rr_latches_next_rep_latches_dc_cs_sr_upper8),
        .rr_latches_next_rep_latches_dc_cs_datasize            (rr_latches_next_rep_latches_dc_cs_datasize),
        .rr_latches_next_rep_latches_mem_cs_ST_OP              (rr_latches_next_rep_latches_mem_cs_ST_OP),
        .rr_latches_next_rep_latches_mem_cs_LD_OP              (rr_latches_next_rep_latches_mem_cs_LD_OP),
        .rr_latches_next_rep_latches_exe_cs_ST_OP              (rr_latches_next_rep_latches_exe_cs_ST_OP),
        .rr_latches_next_rep_latches_exe_cs_OP_TYPE            (rr_latches_next_rep_latches_exe_cs_OP_TYPE[5:0]),
        .rr_latches_next_rep_latches_exe_cs_alu_inputA_sel     (rr_latches_next_rep_latches_exe_cs_alu_inputA_sel[4:0]),
        .rr_latches_next_rep_latches_exe_cs_alu_inputB_sel     (rr_latches_next_rep_latches_exe_cs_alu_inputB_sel[4:0]),
        .rr_latches_next_rep_latches_exe_cs_branch_target_sel  (rr_latches_next_rep_latches_exe_cs_branch_target_sel[4:0]),
        .rr_latches_next_rep_latches_exe_cs_shift_by_one       (rr_latches_next_rep_latches_exe_cs_shift_by_one),
        .rr_latches_next_rep_latches_exe_cs_br_ucond           (rr_latches_next_rep_latches_exe_cs_br_ucond),
        .rr_latches_next_rep_latches_exe_cs_relative_branch    (rr_latches_next_rep_latches_exe_cs_relative_branch),
        .rr_latches_next_rep_latches_exe_cs_special_br         (rr_latches_next_rep_latches_exe_cs_special_br),
        .rr_latches_next_rep_latches_exe_cs_is_far             (rr_latches_next_rep_latches_exe_cs_is_far),
        .rr_latches_next_rep_latches_exe_cs_is_call            (rr_latches_next_rep_latches_exe_cs_is_call),
        .rr_latches_next_rep_latches_exe_cs_second_flag_needed (rr_latches_next_rep_latches_exe_cs_second_flag_needed),
        .rr_latches_next_rep_latches_exe_cs_rep_no_zf_update   (rr_latches_next_rep_latches_exe_cs_rep_no_zf_update),
        .rr_latches_next_rep_latches_wb_cs_ST_OP               (rr_latches_next_rep_latches_wb_cs_ST_OP),
        .rr_latches_next_rep_latches_wb_cs_WB_DR               (rr_latches_next_rep_latches_wb_cs_WB_DR),
        .rr_latches_next_rep_latches_wb_cs_WB_SR               (rr_latches_next_rep_latches_wb_cs_WB_SR),
        .rr_latches_next_rep_latches_wb_cs_WB_EAX              (rr_latches_next_rep_latches_wb_cs_WB_EAX),
        .rr_latches_next_rep_latches_br_info_valid             (rr_latches_next_rep_latches_br_info_valid),
        .rr_latches_next_rep_latches_br_info_br_eip            (rr_latches_next_rep_latches_br_info_br_eip),
        .rr_latches_next_rep_latches_br_info_br_xcl            (rr_latches_next_rep_latches_br_info_br_xcl),
        .rr_latches_next_rep_latches_br_info_br_pred_taken     (rr_latches_next_rep_latches_br_info_br_pred_taken),
        .rr_latches_next_rep_latches_br_info_speculative_target(rr_latches_next_rep_latches_br_info_speculative_target),
        .rr_latches_next_rep_latches_NEIP                      (rr_latches_next_rep_latches_NEIP),
        .rr_latches_next_rep_latches_EIP                       (rr_latches_next_rep_latches_EIP),
        .rr_latches_next_rep_latches_EAX                       (rr_latches_next_rep_latches_EAX),
        .rr_latches_next_rep_latches_imm64                     (rr_latches_next_rep_latches_imm64),
        .rr_latches_next_rep_latches_sib_idx_id                (rr_latches_next_rep_latches_sib_idx_id),
        .rr_latches_next_rep_latches_sib_base_id               (rr_latches_next_rep_latches_sib_base_id),
        .rr_latches_next_rep_latches_sib_needed                (rr_latches_next_rep_latches_sib_needed),
        .rr_latches_next_rep_latches_sib_scale                 (rr_latches_next_rep_latches_sib_scale),
        .rr_latches_next_rep_latches_disp_needed               (rr_latches_next_rep_latches_disp_needed),
        .rr_latches_next_rep_latches_disp_size                 (rr_latches_next_rep_latches_disp_size),
        .rr_latches_next_rep_latches_displacement              (rr_latches_next_rep_latches_displacement),

        // ---- decode_outputs_t ----
        .outs_valid               (decode_outputs_valid),
        .outs_stall               (decode_outputs_stall),
        .outs_eip                 (decode_outputs_eip),
        .outs_invalid_instruction (decode_outputs_invalid_instruction),
        .outs_decode_gp           (decode_outputs_decode_gp),
        .outs_rr_stage_latch_we   (decode_outputs_rr_stage_latch_we),
        .outs_rep_latch           (decode_outputs_rep_latch),
        .outs_decode_forward      (decode_outputs_decode_forward)
    );

    // ====================================================================
    // RR_Latches (still SV struct ports)
    // ====================================================================
    RR_Latches rr_latches_unit (
        .clk(clk),
        .rst(rst),
        .write_enable_i(decode_outputs_rr_stage_latch_we),
        .flush         (exe_outputs_br_res_out_flush),
        .farFlush      (exe_outputs_br_res_out_farFlush),
        .exp_pipe_clear(fetch_outputs_exp_pipe_clear),

        // ---- nextLatches.normal_latches inputs ----
        .nextLatches_normal_valid_i                     (rr_latches_next_normal_latches_valid),
        .nextLatches_normal_cs_ST_SEL_i                 (rr_latches_next_normal_latches_cs_ST_SEL),
        .nextLatches_normal_cs_MODRM_NEEDED_i           (rr_latches_next_normal_latches_cs_MODRM_NEEDED),
        .nextLatches_normal_cs_RM_IS_DR_i               (rr_latches_next_normal_latches_cs_RM_IS_DR),
        .nextLatches_normal_cs_SWITCH_LD_ADDY_i         (rr_latches_next_normal_latches_cs_SWITCH_LD_ADDY),
        .nextLatches_normal_cs_LD_OP_i                  (rr_latches_next_normal_latches_cs_LD_OP),
        .nextLatches_normal_cs_ST_OP_i                  (rr_latches_next_normal_latches_cs_ST_OP),
        .nextLatches_normal_cs_dr_id_i                  (rr_latches_next_normal_latches_cs_dr_id),
        .nextLatches_normal_cs_sr_id_i                  (rr_latches_next_normal_latches_cs_sr_id),
        .nextLatches_normal_cs_dr_rd_i                  (rr_latches_next_normal_latches_cs_dr_rd),
        .nextLatches_normal_cs_sr_rd_i                  (rr_latches_next_normal_latches_cs_sr_rd),
        .nextLatches_normal_cs_eax_rd_i                 (rr_latches_next_normal_latches_cs_eax_rd),
        .nextLatches_normal_cs_dr_wr_i                  (rr_latches_next_normal_latches_cs_dr_wr),
        .nextLatches_normal_cs_sr_wr_i                  (rr_latches_next_normal_latches_cs_sr_wr),
        .nextLatches_normal_cs_eax_wr_i                 (rr_latches_next_normal_latches_cs_eax_wr),
        .nextLatches_normal_cs_MOVS_OP_i                (rr_latches_next_normal_latches_cs_MOVS_OP),
        .nextLatches_normal_cs_datasize_i               (rr_latches_next_normal_latches_cs_datasize),
        .nextLatches_normal_cs_will_mod_zf_i            (rr_latches_next_normal_latches_cs_will_mod_zf),
        .nextLatches_normal_cs_seg_1_valid_i            (rr_latches_next_normal_latches_cs_seg_1_valid),
        .nextLatches_normal_cs_seg_0_id_i               (rr_latches_next_normal_latches_cs_seg_0_id),
        .nextLatches_normal_cs_seg_1_id_i               (rr_latches_next_normal_latches_cs_seg_1_id),
        .nextLatches_normal_cs_special_modrm_bs_i       (rr_latches_next_normal_latches_cs_special_modrm_bs),
        .nextLatches_normal_cs_special_br_i             (rr_latches_next_normal_latches_cs_special_br),
        .nextLatches_normal_dc_cs_LD_OP_i               (rr_latches_next_normal_latches_dc_cs_LD_OP),
        .nextLatches_normal_dc_cs_ST_OP_i               (rr_latches_next_normal_latches_dc_cs_ST_OP),
        .nextLatches_normal_dc_cs_dr_upper8_i           (rr_latches_next_normal_latches_dc_cs_dr_upper8),
        .nextLatches_normal_dc_cs_sr_upper8_i           (rr_latches_next_normal_latches_dc_cs_sr_upper8),
        .nextLatches_normal_dc_cs_datasize_i            (rr_latches_next_normal_latches_dc_cs_datasize),
        .nextLatches_normal_mem_cs_ST_OP_i              (rr_latches_next_normal_latches_mem_cs_ST_OP),
        .nextLatches_normal_mem_cs_LD_OP_i              (rr_latches_next_normal_latches_mem_cs_LD_OP),
        .nextLatches_normal_exe_cs_ST_OP_i              (rr_latches_next_normal_latches_exe_cs_ST_OP),
        .nextLatches_normal_exe_cs_OP_TYPE_i            (rr_latches_next_normal_latches_exe_cs_OP_TYPE),
        .nextLatches_normal_exe_cs_alu_inputA_sel_i     (rr_latches_next_normal_latches_exe_cs_alu_inputA_sel),
        .nextLatches_normal_exe_cs_alu_inputB_sel_i     (rr_latches_next_normal_latches_exe_cs_alu_inputB_sel),
        .nextLatches_normal_exe_cs_branch_target_sel_i  (rr_latches_next_normal_latches_exe_cs_branch_target_sel),
        .nextLatches_normal_exe_cs_shift_by_one_i       (rr_latches_next_normal_latches_exe_cs_shift_by_one),
        .nextLatches_normal_exe_cs_br_ucond_i           (rr_latches_next_normal_latches_exe_cs_br_ucond),
        .nextLatches_normal_exe_cs_relative_branch_i    (rr_latches_next_normal_latches_exe_cs_relative_branch),
        .nextLatches_normal_exe_cs_special_br_i         (rr_latches_next_normal_latches_exe_cs_special_br),
        .nextLatches_normal_exe_cs_is_far_i             (rr_latches_next_normal_latches_exe_cs_is_far),
        .nextLatches_normal_exe_cs_is_call_i            (rr_latches_next_normal_latches_exe_cs_is_call),
        .nextLatches_normal_exe_cs_second_flag_needed_i (rr_latches_next_normal_latches_exe_cs_second_flag_needed),
        .nextLatches_normal_exe_cs_rep_no_zf_update_i   (rr_latches_next_normal_latches_exe_cs_rep_no_zf_update),
        .nextLatches_normal_wb_cs_ST_OP_i               (rr_latches_next_normal_latches_wb_cs_ST_OP),
        .nextLatches_normal_wb_cs_WB_DR_i               (rr_latches_next_normal_latches_wb_cs_WB_DR),
        .nextLatches_normal_wb_cs_WB_SR_i               (rr_latches_next_normal_latches_wb_cs_WB_SR),
        .nextLatches_normal_wb_cs_WB_EAX_i              (rr_latches_next_normal_latches_wb_cs_WB_EAX),
        .nextLatches_normal_br_info_valid_i             (rr_latches_next_normal_latches_br_info_valid),
        .nextLatches_normal_br_info_br_eip_i            (rr_latches_next_normal_latches_br_info_br_eip),
        .nextLatches_normal_br_info_br_xcl_i            (rr_latches_next_normal_latches_br_info_br_xcl),
        .nextLatches_normal_br_info_br_pred_taken_i     (rr_latches_next_normal_latches_br_info_br_pred_taken),
        .nextLatches_normal_br_info_speculative_target_i(rr_latches_next_normal_latches_br_info_speculative_target),
        .nextLatches_normal_NEIP_i                      (rr_latches_next_normal_latches_NEIP),
        .nextLatches_normal_EIP_i                       (rr_latches_next_normal_latches_EIP),
        .nextLatches_normal_EAX_i                       (rr_latches_next_normal_latches_EAX),
        .nextLatches_normal_imm64_i                     (rr_latches_next_normal_latches_imm64),
        .nextLatches_normal_sib_idx_id_i                (rr_latches_next_normal_latches_sib_idx_id),
        .nextLatches_normal_sib_base_id_i               (rr_latches_next_normal_latches_sib_base_id),
        .nextLatches_normal_sib_needed_i                (rr_latches_next_normal_latches_sib_needed),
        .nextLatches_normal_sib_scale_i                 (rr_latches_next_normal_latches_sib_scale),
        .nextLatches_normal_disp_needed_i               (rr_latches_next_normal_latches_disp_needed),
        .nextLatches_normal_disp_size_i                 (rr_latches_next_normal_latches_disp_size),
        .nextLatches_normal_displacement_i              (rr_latches_next_normal_latches_displacement),

        // ---- nextLatches.rep_latches inputs ----
        .nextLatches_rep_valid_i                     (rr_latches_next_rep_latches_valid),
        .nextLatches_rep_cs_ST_SEL_i                 (rr_latches_next_rep_latches_cs_ST_SEL),
        .nextLatches_rep_cs_MODRM_NEEDED_i           (rr_latches_next_rep_latches_cs_MODRM_NEEDED),
        .nextLatches_rep_cs_RM_IS_DR_i               (rr_latches_next_rep_latches_cs_RM_IS_DR),
        .nextLatches_rep_cs_SWITCH_LD_ADDY_i         (rr_latches_next_rep_latches_cs_SWITCH_LD_ADDY),
        .nextLatches_rep_cs_LD_OP_i                  (rr_latches_next_rep_latches_cs_LD_OP),
        .nextLatches_rep_cs_ST_OP_i                  (rr_latches_next_rep_latches_cs_ST_OP),
        .nextLatches_rep_cs_dr_id_i                  (rr_latches_next_rep_latches_cs_dr_id),
        .nextLatches_rep_cs_sr_id_i                  (rr_latches_next_rep_latches_cs_sr_id),
        .nextLatches_rep_cs_dr_rd_i                  (rr_latches_next_rep_latches_cs_dr_rd),
        .nextLatches_rep_cs_sr_rd_i                  (rr_latches_next_rep_latches_cs_sr_rd),
        .nextLatches_rep_cs_eax_rd_i                 (rr_latches_next_rep_latches_cs_eax_rd),
        .nextLatches_rep_cs_dr_wr_i                  (rr_latches_next_rep_latches_cs_dr_wr),
        .nextLatches_rep_cs_sr_wr_i                  (rr_latches_next_rep_latches_cs_sr_wr),
        .nextLatches_rep_cs_eax_wr_i                 (rr_latches_next_rep_latches_cs_eax_wr),
        .nextLatches_rep_cs_MOVS_OP_i                (rr_latches_next_rep_latches_cs_MOVS_OP),
        .nextLatches_rep_cs_datasize_i               (rr_latches_next_rep_latches_cs_datasize),
        .nextLatches_rep_cs_will_mod_zf_i            (rr_latches_next_rep_latches_cs_will_mod_zf),
        .nextLatches_rep_cs_seg_1_valid_i            (rr_latches_next_rep_latches_cs_seg_1_valid),
        .nextLatches_rep_cs_seg_0_id_i               (rr_latches_next_rep_latches_cs_seg_0_id),
        .nextLatches_rep_cs_seg_1_id_i               (rr_latches_next_rep_latches_cs_seg_1_id),
        .nextLatches_rep_cs_special_modrm_bs_i       (rr_latches_next_rep_latches_cs_special_modrm_bs),
        .nextLatches_rep_cs_special_br_i             (rr_latches_next_rep_latches_cs_special_br),
        .nextLatches_rep_dc_cs_LD_OP_i               (rr_latches_next_rep_latches_dc_cs_LD_OP),
        .nextLatches_rep_dc_cs_ST_OP_i               (rr_latches_next_rep_latches_dc_cs_ST_OP),
        .nextLatches_rep_dc_cs_dr_upper8_i           (rr_latches_next_rep_latches_dc_cs_dr_upper8),
        .nextLatches_rep_dc_cs_sr_upper8_i           (rr_latches_next_rep_latches_dc_cs_sr_upper8),
        .nextLatches_rep_dc_cs_datasize_i            (rr_latches_next_rep_latches_dc_cs_datasize),
        .nextLatches_rep_mem_cs_ST_OP_i              (rr_latches_next_rep_latches_mem_cs_ST_OP),
        .nextLatches_rep_mem_cs_LD_OP_i              (rr_latches_next_rep_latches_mem_cs_LD_OP),
        .nextLatches_rep_exe_cs_ST_OP_i              (rr_latches_next_rep_latches_exe_cs_ST_OP),
        .nextLatches_rep_exe_cs_OP_TYPE_i            (rr_latches_next_rep_latches_exe_cs_OP_TYPE),
        .nextLatches_rep_exe_cs_alu_inputA_sel_i     (rr_latches_next_rep_latches_exe_cs_alu_inputA_sel),
        .nextLatches_rep_exe_cs_alu_inputB_sel_i     (rr_latches_next_rep_latches_exe_cs_alu_inputB_sel),
        .nextLatches_rep_exe_cs_branch_target_sel_i  (rr_latches_next_rep_latches_exe_cs_branch_target_sel),
        .nextLatches_rep_exe_cs_shift_by_one_i       (rr_latches_next_rep_latches_exe_cs_shift_by_one),
        .nextLatches_rep_exe_cs_br_ucond_i           (rr_latches_next_rep_latches_exe_cs_br_ucond),
        .nextLatches_rep_exe_cs_relative_branch_i    (rr_latches_next_rep_latches_exe_cs_relative_branch),
        .nextLatches_rep_exe_cs_special_br_i         (rr_latches_next_rep_latches_exe_cs_special_br),
        .nextLatches_rep_exe_cs_is_far_i             (rr_latches_next_rep_latches_exe_cs_is_far),
        .nextLatches_rep_exe_cs_is_call_i            (rr_latches_next_rep_latches_exe_cs_is_call),
        .nextLatches_rep_exe_cs_second_flag_needed_i (rr_latches_next_rep_latches_exe_cs_second_flag_needed),
        .nextLatches_rep_exe_cs_rep_no_zf_update_i   (rr_latches_next_rep_latches_exe_cs_rep_no_zf_update),
        .nextLatches_rep_wb_cs_ST_OP_i               (rr_latches_next_rep_latches_wb_cs_ST_OP),
        .nextLatches_rep_wb_cs_WB_DR_i               (rr_latches_next_rep_latches_wb_cs_WB_DR),
        .nextLatches_rep_wb_cs_WB_SR_i               (rr_latches_next_rep_latches_wb_cs_WB_SR),
        .nextLatches_rep_wb_cs_WB_EAX_i              (rr_latches_next_rep_latches_wb_cs_WB_EAX),
        .nextLatches_rep_br_info_valid_i             (rr_latches_next_rep_latches_br_info_valid),
        .nextLatches_rep_br_info_br_eip_i            (rr_latches_next_rep_latches_br_info_br_eip),
        .nextLatches_rep_br_info_br_xcl_i            (rr_latches_next_rep_latches_br_info_br_xcl),
        .nextLatches_rep_br_info_br_pred_taken_i     (rr_latches_next_rep_latches_br_info_br_pred_taken),
        .nextLatches_rep_br_info_speculative_target_i(rr_latches_next_rep_latches_br_info_speculative_target),
        .nextLatches_rep_NEIP_i                      (rr_latches_next_rep_latches_NEIP),
        .nextLatches_rep_EIP_i                       (rr_latches_next_rep_latches_EIP),
        .nextLatches_rep_EAX_i                       (rr_latches_next_rep_latches_EAX),
        .nextLatches_rep_imm64_i                     (rr_latches_next_rep_latches_imm64),
        .nextLatches_rep_sib_idx_id_i                (rr_latches_next_rep_latches_sib_idx_id),
        .nextLatches_rep_sib_base_id_i               (rr_latches_next_rep_latches_sib_base_id),
        .nextLatches_rep_sib_needed_i                (rr_latches_next_rep_latches_sib_needed),
        .nextLatches_rep_sib_scale_i                 (rr_latches_next_rep_latches_sib_scale),
        .nextLatches_rep_disp_needed_i               (rr_latches_next_rep_latches_disp_needed),
        .nextLatches_rep_disp_size_i                 (rr_latches_next_rep_latches_disp_size),
        .nextLatches_rep_displacement_i              (rr_latches_next_rep_latches_displacement),

        // ---- latches.normal_latches outputs ----
        .latches_normal_valid_o                     (rr_latches_normal_latches_valid),
        .latches_normal_cs_ST_SEL_o                 (rr_latches_normal_latches_cs_ST_SEL),
        .latches_normal_cs_MODRM_NEEDED_o           (rr_latches_normal_latches_cs_MODRM_NEEDED),
        .latches_normal_cs_RM_IS_DR_o               (rr_latches_normal_latches_cs_RM_IS_DR),
        .latches_normal_cs_SWITCH_LD_ADDY_o         (rr_latches_normal_latches_cs_SWITCH_LD_ADDY),
        .latches_normal_cs_LD_OP_o                  (rr_latches_normal_latches_cs_LD_OP),
        .latches_normal_cs_ST_OP_o                  (rr_latches_normal_latches_cs_ST_OP),
        .latches_normal_cs_dr_id_o                  (rr_latches_normal_latches_cs_dr_id),
        .latches_normal_cs_sr_id_o                  (rr_latches_normal_latches_cs_sr_id),
        .latches_normal_cs_dr_rd_o                  (rr_latches_normal_latches_cs_dr_rd),
        .latches_normal_cs_sr_rd_o                  (rr_latches_normal_latches_cs_sr_rd),
        .latches_normal_cs_eax_rd_o                 (rr_latches_normal_latches_cs_eax_rd),
        .latches_normal_cs_dr_wr_o                  (rr_latches_normal_latches_cs_dr_wr),
        .latches_normal_cs_sr_wr_o                  (rr_latches_normal_latches_cs_sr_wr),
        .latches_normal_cs_eax_wr_o                 (rr_latches_normal_latches_cs_eax_wr),
        .latches_normal_cs_MOVS_OP_o                (rr_latches_normal_latches_cs_MOVS_OP),
        .latches_normal_cs_datasize_o               (rr_latches_normal_latches_cs_datasize),
        .latches_normal_cs_will_mod_zf_o            (rr_latches_normal_latches_cs_will_mod_zf),
        .latches_normal_cs_seg_1_valid_o            (rr_latches_normal_latches_cs_seg_1_valid),
        .latches_normal_cs_seg_0_id_o               (rr_latches_normal_latches_cs_seg_0_id),
        .latches_normal_cs_seg_1_id_o               (rr_latches_normal_latches_cs_seg_1_id),
        .latches_normal_cs_special_modrm_bs_o       (rr_latches_normal_latches_cs_special_modrm_bs),
        .latches_normal_cs_special_br_o             (rr_latches_normal_latches_cs_special_br),
        .latches_normal_dc_cs_LD_OP_o               (rr_latches_normal_latches_dc_cs_LD_OP),
        .latches_normal_dc_cs_ST_OP_o               (rr_latches_normal_latches_dc_cs_ST_OP),
        .latches_normal_dc_cs_dr_upper8_o           (rr_latches_normal_latches_dc_cs_dr_upper8),
        .latches_normal_dc_cs_sr_upper8_o           (rr_latches_normal_latches_dc_cs_sr_upper8),
        .latches_normal_dc_cs_datasize_o            (rr_latches_normal_latches_dc_cs_datasize),
        .latches_normal_mem_cs_ST_OP_o              (rr_latches_normal_latches_mem_cs_ST_OP),
        .latches_normal_mem_cs_LD_OP_o              (rr_latches_normal_latches_mem_cs_LD_OP),
        .latches_normal_exe_cs_ST_OP_o              (rr_latches_normal_latches_exe_cs_ST_OP),
        .latches_normal_exe_cs_OP_TYPE_o            (rr_latches_normal_latches_exe_cs_OP_TYPE),
        .latches_normal_exe_cs_alu_inputA_sel_o     (rr_latches_normal_latches_exe_cs_alu_inputA_sel),
        .latches_normal_exe_cs_alu_inputB_sel_o     (rr_latches_normal_latches_exe_cs_alu_inputB_sel),
        .latches_normal_exe_cs_branch_target_sel_o  (rr_latches_normal_latches_exe_cs_branch_target_sel),
        .latches_normal_exe_cs_shift_by_one_o       (rr_latches_normal_latches_exe_cs_shift_by_one),
        .latches_normal_exe_cs_br_ucond_o           (rr_latches_normal_latches_exe_cs_br_ucond),
        .latches_normal_exe_cs_relative_branch_o    (rr_latches_normal_latches_exe_cs_relative_branch),
        .latches_normal_exe_cs_special_br_o         (rr_latches_normal_latches_exe_cs_special_br),
        .latches_normal_exe_cs_is_far_o             (rr_latches_normal_latches_exe_cs_is_far),
        .latches_normal_exe_cs_is_call_o            (rr_latches_normal_latches_exe_cs_is_call),
        .latches_normal_exe_cs_second_flag_needed_o (rr_latches_normal_latches_exe_cs_second_flag_needed),
        .latches_normal_exe_cs_rep_no_zf_update_o   (rr_latches_normal_latches_exe_cs_rep_no_zf_update),
        .latches_normal_wb_cs_ST_OP_o               (rr_latches_normal_latches_wb_cs_ST_OP),
        .latches_normal_wb_cs_WB_DR_o               (rr_latches_normal_latches_wb_cs_WB_DR),
        .latches_normal_wb_cs_WB_SR_o               (rr_latches_normal_latches_wb_cs_WB_SR),
        .latches_normal_wb_cs_WB_EAX_o              (rr_latches_normal_latches_wb_cs_WB_EAX),
        .latches_normal_br_info_valid_o             (rr_latches_normal_latches_br_info_valid),
        .latches_normal_br_info_br_eip_o            (rr_latches_normal_latches_br_info_br_eip),
        .latches_normal_br_info_br_xcl_o            (rr_latches_normal_latches_br_info_br_xcl),
        .latches_normal_br_info_br_pred_taken_o     (rr_latches_normal_latches_br_info_br_pred_taken),
        .latches_normal_br_info_speculative_target_o(rr_latches_normal_latches_br_info_speculative_target),
        .latches_normal_NEIP_o                      (rr_latches_normal_latches_NEIP),
        .latches_normal_EIP_o                       (rr_latches_normal_latches_EIP),
        .latches_normal_EAX_o                       (rr_latches_normal_latches_EAX),
        .latches_normal_imm64_o                     (rr_latches_normal_latches_imm64),
        .latches_normal_sib_idx_id_o                (rr_latches_normal_latches_sib_idx_id),
        .latches_normal_sib_base_id_o               (rr_latches_normal_latches_sib_base_id),
        .latches_normal_sib_needed_o                (rr_latches_normal_latches_sib_needed),
        .latches_normal_sib_scale_o                 (rr_latches_normal_latches_sib_scale),
        .latches_normal_disp_needed_o               (rr_latches_normal_latches_disp_needed),
        .latches_normal_disp_size_o                 (rr_latches_normal_latches_disp_size),
        .latches_normal_displacement_o              (rr_latches_normal_latches_displacement),

        // ---- latches.rep_latches outputs ----
        .latches_rep_valid_o                     (rr_latches_rep_latches_valid),
        .latches_rep_cs_ST_SEL_o                 (rr_latches_rep_latches_cs_ST_SEL),
        .latches_rep_cs_MODRM_NEEDED_o           (rr_latches_rep_latches_cs_MODRM_NEEDED),
        .latches_rep_cs_RM_IS_DR_o               (rr_latches_rep_latches_cs_RM_IS_DR),
        .latches_rep_cs_SWITCH_LD_ADDY_o         (rr_latches_rep_latches_cs_SWITCH_LD_ADDY),
        .latches_rep_cs_LD_OP_o                  (rr_latches_rep_latches_cs_LD_OP),
        .latches_rep_cs_ST_OP_o                  (rr_latches_rep_latches_cs_ST_OP),
        .latches_rep_cs_dr_id_o                  (rr_latches_rep_latches_cs_dr_id),
        .latches_rep_cs_sr_id_o                  (rr_latches_rep_latches_cs_sr_id),
        .latches_rep_cs_dr_rd_o                  (rr_latches_rep_latches_cs_dr_rd),
        .latches_rep_cs_sr_rd_o                  (rr_latches_rep_latches_cs_sr_rd),
        .latches_rep_cs_eax_rd_o                 (rr_latches_rep_latches_cs_eax_rd),
        .latches_rep_cs_dr_wr_o                  (rr_latches_rep_latches_cs_dr_wr),
        .latches_rep_cs_sr_wr_o                  (rr_latches_rep_latches_cs_sr_wr),
        .latches_rep_cs_eax_wr_o                 (rr_latches_rep_latches_cs_eax_wr),
        .latches_rep_cs_MOVS_OP_o                (rr_latches_rep_latches_cs_MOVS_OP),
        .latches_rep_cs_datasize_o               (rr_latches_rep_latches_cs_datasize),
        .latches_rep_cs_will_mod_zf_o            (rr_latches_rep_latches_cs_will_mod_zf),
        .latches_rep_cs_seg_1_valid_o            (rr_latches_rep_latches_cs_seg_1_valid),
        .latches_rep_cs_seg_0_id_o               (rr_latches_rep_latches_cs_seg_0_id),
        .latches_rep_cs_seg_1_id_o               (rr_latches_rep_latches_cs_seg_1_id),
        .latches_rep_cs_special_modrm_bs_o       (rr_latches_rep_latches_cs_special_modrm_bs),
        .latches_rep_cs_special_br_o             (rr_latches_rep_latches_cs_special_br),
        .latches_rep_dc_cs_LD_OP_o               (rr_latches_rep_latches_dc_cs_LD_OP),
        .latches_rep_dc_cs_ST_OP_o               (rr_latches_rep_latches_dc_cs_ST_OP),
        .latches_rep_dc_cs_dr_upper8_o           (rr_latches_rep_latches_dc_cs_dr_upper8),
        .latches_rep_dc_cs_sr_upper8_o           (rr_latches_rep_latches_dc_cs_sr_upper8),
        .latches_rep_dc_cs_datasize_o            (rr_latches_rep_latches_dc_cs_datasize),
        .latches_rep_mem_cs_ST_OP_o              (rr_latches_rep_latches_mem_cs_ST_OP),
        .latches_rep_mem_cs_LD_OP_o              (rr_latches_rep_latches_mem_cs_LD_OP),
        .latches_rep_exe_cs_ST_OP_o              (rr_latches_rep_latches_exe_cs_ST_OP),
        .latches_rep_exe_cs_OP_TYPE_o            (rr_latches_rep_latches_exe_cs_OP_TYPE),
        .latches_rep_exe_cs_alu_inputA_sel_o     (rr_latches_rep_latches_exe_cs_alu_inputA_sel),
        .latches_rep_exe_cs_alu_inputB_sel_o     (rr_latches_rep_latches_exe_cs_alu_inputB_sel),
        .latches_rep_exe_cs_branch_target_sel_o  (rr_latches_rep_latches_exe_cs_branch_target_sel),
        .latches_rep_exe_cs_shift_by_one_o       (rr_latches_rep_latches_exe_cs_shift_by_one),
        .latches_rep_exe_cs_br_ucond_o           (rr_latches_rep_latches_exe_cs_br_ucond),
        .latches_rep_exe_cs_relative_branch_o    (rr_latches_rep_latches_exe_cs_relative_branch),
        .latches_rep_exe_cs_special_br_o         (rr_latches_rep_latches_exe_cs_special_br),
        .latches_rep_exe_cs_is_far_o             (rr_latches_rep_latches_exe_cs_is_far),
        .latches_rep_exe_cs_is_call_o            (rr_latches_rep_latches_exe_cs_is_call),
        .latches_rep_exe_cs_second_flag_needed_o (rr_latches_rep_latches_exe_cs_second_flag_needed),
        .latches_rep_exe_cs_rep_no_zf_update_o   (rr_latches_rep_latches_exe_cs_rep_no_zf_update),
        .latches_rep_wb_cs_ST_OP_o               (rr_latches_rep_latches_wb_cs_ST_OP),
        .latches_rep_wb_cs_WB_DR_o               (rr_latches_rep_latches_wb_cs_WB_DR),
        .latches_rep_wb_cs_WB_SR_o               (rr_latches_rep_latches_wb_cs_WB_SR),
        .latches_rep_wb_cs_WB_EAX_o              (rr_latches_rep_latches_wb_cs_WB_EAX),
        .latches_rep_br_info_valid_o             (rr_latches_rep_latches_br_info_valid),
        .latches_rep_br_info_br_eip_o            (rr_latches_rep_latches_br_info_br_eip),
        .latches_rep_br_info_br_xcl_o            (rr_latches_rep_latches_br_info_br_xcl),
        .latches_rep_br_info_br_pred_taken_o     (rr_latches_rep_latches_br_info_br_pred_taken),
        .latches_rep_br_info_speculative_target_o(rr_latches_rep_latches_br_info_speculative_target),
        .latches_rep_NEIP_o                      (rr_latches_rep_latches_NEIP),
        .latches_rep_EIP_o                       (rr_latches_rep_latches_EIP),
        .latches_rep_EAX_o                       (rr_latches_rep_latches_EAX),
        .latches_rep_imm64_o                     (rr_latches_rep_latches_imm64),
        .latches_rep_sib_idx_id_o                (rr_latches_rep_latches_sib_idx_id),
        .latches_rep_sib_base_id_o               (rr_latches_rep_latches_sib_base_id),
        .latches_rep_sib_needed_o                (rr_latches_rep_latches_sib_needed),
        .latches_rep_sib_scale_o                 (rr_latches_rep_latches_sib_scale),
        .latches_rep_disp_needed_o               (rr_latches_rep_latches_disp_needed),
        .latches_rep_disp_size_o                 (rr_latches_rep_latches_disp_size),
        .latches_rep_displacement_o              (rr_latches_rep_latches_displacement)
    );

    // ====================================================================
    // RR (flat-port .v)
    // ====================================================================
    RR rr_unit (
        .clk(clk),
        .rst(rst),

        // ---- latches_i (rr_latches_t) ----
        .latches_normal_latches_valid                     (rr_latches_normal_latches_valid),
        .latches_normal_latches_cs_ST_SEL                 (rr_latches_normal_latches_cs_ST_SEL),
        .latches_normal_latches_cs_MODRM_NEEDED           (rr_latches_normal_latches_cs_MODRM_NEEDED),
        .latches_normal_latches_cs_RM_IS_DR               (rr_latches_normal_latches_cs_RM_IS_DR),
        .latches_normal_latches_cs_SWITCH_LD_ADDY         (rr_latches_normal_latches_cs_SWITCH_LD_ADDY),
        .latches_normal_latches_cs_LD_OP                  (rr_latches_normal_latches_cs_LD_OP),
        .latches_normal_latches_cs_ST_OP                  (rr_latches_normal_latches_cs_ST_OP),
        .latches_normal_latches_cs_dr_id                  (rr_latches_normal_latches_cs_dr_id),
        .latches_normal_latches_cs_sr_id                  (rr_latches_normal_latches_cs_sr_id),
        .latches_normal_latches_cs_dr_rd                  (rr_latches_normal_latches_cs_dr_rd),
        .latches_normal_latches_cs_sr_rd                  (rr_latches_normal_latches_cs_sr_rd),
        .latches_normal_latches_cs_eax_rd                 (rr_latches_normal_latches_cs_eax_rd),
        .latches_normal_latches_cs_dr_wr                  (rr_latches_normal_latches_cs_dr_wr),
        .latches_normal_latches_cs_sr_wr                  (rr_latches_normal_latches_cs_sr_wr),
        .latches_normal_latches_cs_eax_wr                 (rr_latches_normal_latches_cs_eax_wr),
        .latches_normal_latches_cs_MOVS_OP                (rr_latches_normal_latches_cs_MOVS_OP),
        .latches_normal_latches_cs_datasize               (rr_latches_normal_latches_cs_datasize),
        .latches_normal_latches_cs_will_mod_zf            (rr_latches_normal_latches_cs_will_mod_zf),
        .latches_normal_latches_cs_seg_1_valid            (rr_latches_normal_latches_cs_seg_1_valid),
        .latches_normal_latches_cs_seg_0_id               (rr_latches_normal_latches_cs_seg_0_id),
        .latches_normal_latches_cs_seg_1_id               (rr_latches_normal_latches_cs_seg_1_id),
        .latches_normal_latches_cs_special_modrm_bs       (rr_latches_normal_latches_cs_special_modrm_bs),
        .latches_normal_latches_cs_special_br             (rr_latches_normal_latches_cs_special_br),
        .latches_normal_latches_dc_cs_LD_OP               (rr_latches_normal_latches_dc_cs_LD_OP),
        .latches_normal_latches_dc_cs_ST_OP               (rr_latches_normal_latches_dc_cs_ST_OP),
        .latches_normal_latches_dc_cs_dr_upper8           (rr_latches_normal_latches_dc_cs_dr_upper8),
        .latches_normal_latches_dc_cs_sr_upper8           (rr_latches_normal_latches_dc_cs_sr_upper8),
        .latches_normal_latches_dc_cs_datasize            (rr_latches_normal_latches_dc_cs_datasize),
        .latches_normal_latches_mem_cs_ST_OP              (rr_latches_normal_latches_mem_cs_ST_OP),
        .latches_normal_latches_mem_cs_LD_OP              (rr_latches_normal_latches_mem_cs_LD_OP),
        .latches_normal_latches_exe_cs_ST_OP              (rr_latches_normal_latches_exe_cs_ST_OP),
        .latches_normal_latches_exe_cs_OP_TYPE            (rr_latches_normal_latches_exe_cs_OP_TYPE[5:0]),
        .latches_normal_latches_exe_cs_alu_inputA_sel     (rr_latches_normal_latches_exe_cs_alu_inputA_sel[4:0]),
        .latches_normal_latches_exe_cs_alu_inputB_sel     (rr_latches_normal_latches_exe_cs_alu_inputB_sel[4:0]),
        .latches_normal_latches_exe_cs_branch_target_sel  (rr_latches_normal_latches_exe_cs_branch_target_sel[4:0]),
        .latches_normal_latches_exe_cs_shift_by_one       (rr_latches_normal_latches_exe_cs_shift_by_one),
        .latches_normal_latches_exe_cs_br_ucond           (rr_latches_normal_latches_exe_cs_br_ucond),
        .latches_normal_latches_exe_cs_relative_branch    (rr_latches_normal_latches_exe_cs_relative_branch),
        .latches_normal_latches_exe_cs_special_br         (rr_latches_normal_latches_exe_cs_special_br),
        .latches_normal_latches_exe_cs_is_far             (rr_latches_normal_latches_exe_cs_is_far),
        .latches_normal_latches_exe_cs_is_call            (rr_latches_normal_latches_exe_cs_is_call),
        .latches_normal_latches_exe_cs_second_flag_needed (rr_latches_normal_latches_exe_cs_second_flag_needed),
        .latches_normal_latches_exe_cs_rep_no_zf_update   (rr_latches_normal_latches_exe_cs_rep_no_zf_update),
        .latches_normal_latches_wb_cs_ST_OP               (rr_latches_normal_latches_wb_cs_ST_OP),
        .latches_normal_latches_wb_cs_WB_DR               (rr_latches_normal_latches_wb_cs_WB_DR),
        .latches_normal_latches_wb_cs_WB_SR               (rr_latches_normal_latches_wb_cs_WB_SR),
        .latches_normal_latches_wb_cs_WB_EAX              (rr_latches_normal_latches_wb_cs_WB_EAX),
        .latches_normal_latches_br_info_valid             (rr_latches_normal_latches_br_info_valid),
        .latches_normal_latches_br_info_br_eip            (rr_latches_normal_latches_br_info_br_eip),
        .latches_normal_latches_br_info_br_xcl            (rr_latches_normal_latches_br_info_br_xcl),
        .latches_normal_latches_br_info_br_pred_taken     (rr_latches_normal_latches_br_info_br_pred_taken),
        .latches_normal_latches_br_info_speculative_target(rr_latches_normal_latches_br_info_speculative_target),
        .latches_normal_latches_NEIP                      (rr_latches_normal_latches_NEIP),
        .latches_normal_latches_EIP                       (rr_latches_normal_latches_EIP),
        .latches_normal_latches_EAX                       (rr_latches_normal_latches_EAX),
        .latches_normal_latches_imm64                     (rr_latches_normal_latches_imm64),
        .latches_normal_latches_sib_idx_id                (rr_latches_normal_latches_sib_idx_id),
        .latches_normal_latches_sib_base_id               (rr_latches_normal_latches_sib_base_id),
        .latches_normal_latches_sib_needed                (rr_latches_normal_latches_sib_needed),
        .latches_normal_latches_sib_scale                 (rr_latches_normal_latches_sib_scale),
        .latches_normal_latches_disp_needed               (rr_latches_normal_latches_disp_needed),
        .latches_normal_latches_disp_size                 (rr_latches_normal_latches_disp_size),
        .latches_normal_latches_displacement              (rr_latches_normal_latches_displacement),

        .latches_rep_latches_valid                     (rr_latches_rep_latches_valid),
        .latches_rep_latches_cs_ST_SEL                 (rr_latches_rep_latches_cs_ST_SEL),
        .latches_rep_latches_cs_MODRM_NEEDED           (rr_latches_rep_latches_cs_MODRM_NEEDED),
        .latches_rep_latches_cs_RM_IS_DR               (rr_latches_rep_latches_cs_RM_IS_DR),
        .latches_rep_latches_cs_SWITCH_LD_ADDY         (rr_latches_rep_latches_cs_SWITCH_LD_ADDY),
        .latches_rep_latches_cs_LD_OP                  (rr_latches_rep_latches_cs_LD_OP),
        .latches_rep_latches_cs_ST_OP                  (rr_latches_rep_latches_cs_ST_OP),
        .latches_rep_latches_cs_dr_id                  (rr_latches_rep_latches_cs_dr_id),
        .latches_rep_latches_cs_sr_id                  (rr_latches_rep_latches_cs_sr_id),
        .latches_rep_latches_cs_dr_rd                  (rr_latches_rep_latches_cs_dr_rd),
        .latches_rep_latches_cs_sr_rd                  (rr_latches_rep_latches_cs_sr_rd),
        .latches_rep_latches_cs_eax_rd                 (rr_latches_rep_latches_cs_eax_rd),
        .latches_rep_latches_cs_dr_wr                  (rr_latches_rep_latches_cs_dr_wr),
        .latches_rep_latches_cs_sr_wr                  (rr_latches_rep_latches_cs_sr_wr),
        .latches_rep_latches_cs_eax_wr                 (rr_latches_rep_latches_cs_eax_wr),
        .latches_rep_latches_cs_MOVS_OP                (rr_latches_rep_latches_cs_MOVS_OP),
        .latches_rep_latches_cs_datasize               (rr_latches_rep_latches_cs_datasize),
        .latches_rep_latches_cs_will_mod_zf            (rr_latches_rep_latches_cs_will_mod_zf),
        .latches_rep_latches_cs_seg_1_valid            (rr_latches_rep_latches_cs_seg_1_valid),
        .latches_rep_latches_cs_seg_0_id               (rr_latches_rep_latches_cs_seg_0_id),
        .latches_rep_latches_cs_seg_1_id               (rr_latches_rep_latches_cs_seg_1_id),
        .latches_rep_latches_cs_special_modrm_bs       (rr_latches_rep_latches_cs_special_modrm_bs),
        .latches_rep_latches_cs_special_br             (rr_latches_rep_latches_cs_special_br),
        .latches_rep_latches_dc_cs_LD_OP               (rr_latches_rep_latches_dc_cs_LD_OP),
        .latches_rep_latches_dc_cs_ST_OP               (rr_latches_rep_latches_dc_cs_ST_OP),
        .latches_rep_latches_dc_cs_dr_upper8           (rr_latches_rep_latches_dc_cs_dr_upper8),
        .latches_rep_latches_dc_cs_sr_upper8           (rr_latches_rep_latches_dc_cs_sr_upper8),
        .latches_rep_latches_dc_cs_datasize            (rr_latches_rep_latches_dc_cs_datasize),
        .latches_rep_latches_mem_cs_ST_OP              (rr_latches_rep_latches_mem_cs_ST_OP),
        .latches_rep_latches_mem_cs_LD_OP              (rr_latches_rep_latches_mem_cs_LD_OP),
        .latches_rep_latches_exe_cs_ST_OP              (rr_latches_rep_latches_exe_cs_ST_OP),
        .latches_rep_latches_exe_cs_OP_TYPE            (rr_latches_rep_latches_exe_cs_OP_TYPE[5:0]),
        .latches_rep_latches_exe_cs_alu_inputA_sel     (rr_latches_rep_latches_exe_cs_alu_inputA_sel[4:0]),
        .latches_rep_latches_exe_cs_alu_inputB_sel     (rr_latches_rep_latches_exe_cs_alu_inputB_sel[4:0]),
        .latches_rep_latches_exe_cs_branch_target_sel  (rr_latches_rep_latches_exe_cs_branch_target_sel[4:0]),
        .latches_rep_latches_exe_cs_shift_by_one       (rr_latches_rep_latches_exe_cs_shift_by_one),
        .latches_rep_latches_exe_cs_br_ucond           (rr_latches_rep_latches_exe_cs_br_ucond),
        .latches_rep_latches_exe_cs_relative_branch    (rr_latches_rep_latches_exe_cs_relative_branch),
        .latches_rep_latches_exe_cs_special_br         (rr_latches_rep_latches_exe_cs_special_br),
        .latches_rep_latches_exe_cs_is_far             (rr_latches_rep_latches_exe_cs_is_far),
        .latches_rep_latches_exe_cs_is_call            (rr_latches_rep_latches_exe_cs_is_call),
        .latches_rep_latches_exe_cs_second_flag_needed (rr_latches_rep_latches_exe_cs_second_flag_needed),
        .latches_rep_latches_exe_cs_rep_no_zf_update   (rr_latches_rep_latches_exe_cs_rep_no_zf_update),
        .latches_rep_latches_wb_cs_ST_OP               (rr_latches_rep_latches_wb_cs_ST_OP),
        .latches_rep_latches_wb_cs_WB_DR               (rr_latches_rep_latches_wb_cs_WB_DR),
        .latches_rep_latches_wb_cs_WB_SR               (rr_latches_rep_latches_wb_cs_WB_SR),
        .latches_rep_latches_wb_cs_WB_EAX              (rr_latches_rep_latches_wb_cs_WB_EAX),
        .latches_rep_latches_br_info_valid             (rr_latches_rep_latches_br_info_valid),
        .latches_rep_latches_br_info_br_eip            (rr_latches_rep_latches_br_info_br_eip),
        .latches_rep_latches_br_info_br_xcl            (rr_latches_rep_latches_br_info_br_xcl),
        .latches_rep_latches_br_info_br_pred_taken     (rr_latches_rep_latches_br_info_br_pred_taken),
        .latches_rep_latches_br_info_speculative_target(rr_latches_rep_latches_br_info_speculative_target),
        .latches_rep_latches_NEIP                      (rr_latches_rep_latches_NEIP),
        .latches_rep_latches_EIP                       (rr_latches_rep_latches_EIP),
        .latches_rep_latches_EAX                       (rr_latches_rep_latches_EAX),
        .latches_rep_latches_imm64                     (rr_latches_rep_latches_imm64),
        .latches_rep_latches_sib_idx_id                (rr_latches_rep_latches_sib_idx_id),
        .latches_rep_latches_sib_base_id               (rr_latches_rep_latches_sib_base_id),
        .latches_rep_latches_sib_needed                (rr_latches_rep_latches_sib_needed),
        .latches_rep_latches_sib_scale                 (rr_latches_rep_latches_sib_scale),
        .latches_rep_latches_disp_needed               (rr_latches_rep_latches_disp_needed),
        .latches_rep_latches_disp_size                 (rr_latches_rep_latches_disp_size),
        .latches_rep_latches_displacement              (rr_latches_rep_latches_displacement),

        // ---- fetch / decode / dc / mem / exe / wb scalar inputs ----
        .fetch_outs_exp_pipe_clear (fetch_outputs_exp_pipe_clear),

        .decode_outs_decode_gp (decode_outputs_decode_gp),
        .decode_outs_rep_latch (decode_outputs_rep_latch),

        .dc_outs_valid (dc_outputs_valid),
        .dc_outs_stall (dc_outputs_stall),

        .mem_outs_valid (mem_outputs_valid),
        .mem_outs_stall (mem_outputs_stall),

        .exe_outs_valid                  (exe_outputs_valid),
        .exe_outs_br_res_out_flush       (exe_outputs_br_res_out_flush),
        .exe_outs_br_res_out_farFlush    (exe_outputs_br_res_out_farFlush),
        .exe_outs_br_res_out_callFlush   (exe_outputs_br_res_out_callFlush),
        .exe_outs_DR_0_we                (exe_outputs_DR_0_we),
        .exe_outs_DR_0_id                (exe_outputs_DR_0_id),
        .exe_outs_DR_0_data              (exe_outputs_DR_0_data),
        .exe_outs_DR_1_we                (exe_outputs_DR_1_we),
        .exe_outs_DR_1_id                (exe_outputs_DR_1_id),
        .exe_outs_DR_1_data              (exe_outputs_DR_1_data),

        .wb_outs_wb_stall (wb_outputs_wb_stall),

        // ---- dc_latches_next (dc_latches_t) outputs ----
        .dc_latches_next_valid                       (dc_latches_next_valid),
        .dc_latches_next_cs_LD_OP                    (dc_latches_next_cs_LD_OP),
        .dc_latches_next_cs_ST_OP                    (dc_latches_next_cs_ST_OP),
        .dc_latches_next_cs_dr_upper8                (dc_latches_next_cs_dr_upper8),
        .dc_latches_next_cs_sr_upper8                (dc_latches_next_cs_sr_upper8),
        .dc_latches_next_cs_datasize                 (dc_latches_next_cs_datasize),
        .dc_latches_next_mem_cs_ST_OP                (dc_latches_next_mem_cs_ST_OP),
        .dc_latches_next_mem_cs_LD_OP                (dc_latches_next_mem_cs_LD_OP),
        .dc_latches_next_exe_cs_ST_OP                (dc_latches_next_exe_cs_ST_OP),
        .dc_latches_next_exe_cs_OP_TYPE              (dc_latches_next_exe_cs_OP_TYPE[5:0]),
        .dc_latches_next_exe_cs_alu_inputA_sel       (dc_latches_next_exe_cs_alu_inputA_sel[4:0]),
        .dc_latches_next_exe_cs_alu_inputB_sel       (dc_latches_next_exe_cs_alu_inputB_sel[4:0]),
        .dc_latches_next_exe_cs_branch_target_sel    (dc_latches_next_exe_cs_branch_target_sel[4:0]),
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

        // ---- outs_o (rr_outputs_t) ----
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

        .outs_regFileValues_0   (rr_outputs_regFileValues_0),
        .outs_regFileValues_1   (rr_outputs_regFileValues_1),
        .outs_regFileValues_2   (rr_outputs_regFileValues_2),
        .outs_regFileValues_3   (rr_outputs_regFileValues_3),
        .outs_regFileValues_4   (rr_outputs_regFileValues_4),
        .outs_regFileValues_5   (rr_outputs_regFileValues_5),
        .outs_regFileValues_6   (rr_outputs_regFileValues_6),
        .outs_regFileValues_7   (rr_outputs_regFileValues_7),
        .outs_regFileValues_8   (rr_outputs_regFileValues_8),
        .outs_regFileValues_9   (rr_outputs_regFileValues_9),
        .outs_regFileValues_10  (rr_outputs_regFileValues_10),
        .outs_regFileValues_11  (rr_outputs_regFileValues_11),
        .outs_regFileValues_12  (rr_outputs_regFileValues_12),
        .outs_regFileValues_13  (rr_outputs_regFileValues_13),
        .outs_regFileValues_14  (rr_outputs_regFileValues_14),
        .outs_regFileValues_15  (rr_outputs_regFileValues_15),
        .outs_regFileValues_16  (rr_outputs_regFileValues_16),
        .outs_regFileValues_17  (rr_outputs_regFileValues_17),
        .outs_regFileValues_18  (rr_outputs_regFileValues_18),
        .outs_regFileValues_19  (rr_outputs_regFileValues_19),
        .outs_regFileValues_20  (rr_outputs_regFileValues_20),
        .outs_regFileValues_21  (rr_outputs_regFileValues_21),
        .outs_regFileValues_22  (rr_outputs_regFileValues_22),
        .outs_regFileValues_23  (rr_outputs_regFileValues_23),
        .outs_regFileValues_24  (rr_outputs_regFileValues_24),
        .outs_regFileValues_25  (rr_outputs_regFileValues_25)
    );

    // ====================================================================
    // DC_Latches / DC / MEM_Latches / MEM / EXE_Latches / WB_Latches /
    // EXE / WB instances are unchanged from the original SV top file.
    // ====================================================================
    DC_Latches dc_latches_unit (
        .clk(clk),
        .rst(rst),
        .write_enable_i(rr_outputs_dc_stage_latch_we),
        .flush         (exe_outputs_br_res_out_flush),
        .farFlush      (exe_outputs_br_res_out_farFlush),
        .exp_pipe_clear(fetch_outputs_exp_pipe_clear),

        // ---- nextLatches inputs ----
        .nextLatches_valid_i                       (dc_latches_next_valid),
        .nextLatches_cs_LD_OP_i                    (dc_latches_next_cs_LD_OP),
        .nextLatches_cs_ST_OP_i                    (dc_latches_next_cs_ST_OP),
        .nextLatches_cs_dr_upper8_i                (dc_latches_next_cs_dr_upper8),
        .nextLatches_cs_sr_upper8_i                (dc_latches_next_cs_sr_upper8),
        .nextLatches_cs_datasize_i                 (dc_latches_next_cs_datasize),
        .nextLatches_mem_cs_ST_OP_i                (dc_latches_next_mem_cs_ST_OP),
        .nextLatches_mem_cs_LD_OP_i                (dc_latches_next_mem_cs_LD_OP),
        .nextLatches_exe_cs_ST_OP_i                (dc_latches_next_exe_cs_ST_OP),
        .nextLatches_exe_cs_OP_TYPE_i              (dc_latches_next_exe_cs_OP_TYPE),
        .nextLatches_exe_cs_alu_inputA_sel_i       (dc_latches_next_exe_cs_alu_inputA_sel),
        .nextLatches_exe_cs_alu_inputB_sel_i       (dc_latches_next_exe_cs_alu_inputB_sel),
        .nextLatches_exe_cs_branch_target_sel_i    (dc_latches_next_exe_cs_branch_target_sel),
        .nextLatches_exe_cs_shift_by_one_i         (dc_latches_next_exe_cs_shift_by_one),
        .nextLatches_exe_cs_br_ucond_i             (dc_latches_next_exe_cs_br_ucond),
        .nextLatches_exe_cs_relative_branch_i      (dc_latches_next_exe_cs_relative_branch),
        .nextLatches_exe_cs_special_br_i           (dc_latches_next_exe_cs_special_br),
        .nextLatches_exe_cs_is_far_i               (dc_latches_next_exe_cs_is_far),
        .nextLatches_exe_cs_is_call_i              (dc_latches_next_exe_cs_is_call),
        .nextLatches_exe_cs_second_flag_needed_i   (dc_latches_next_exe_cs_second_flag_needed),
        .nextLatches_exe_cs_rep_no_zf_update_i     (dc_latches_next_exe_cs_rep_no_zf_update),
        .nextLatches_wb_cs_ST_OP_i                 (dc_latches_next_wb_cs_ST_OP),
        .nextLatches_wb_cs_WB_DR_i                 (dc_latches_next_wb_cs_WB_DR),
        .nextLatches_wb_cs_WB_SR_i                 (dc_latches_next_wb_cs_WB_SR),
        .nextLatches_wb_cs_WB_EAX_i                (dc_latches_next_wb_cs_WB_EAX),
        .nextLatches_br_info_valid_i               (dc_latches_next_br_info_valid),
        .nextLatches_br_info_br_eip_i              (dc_latches_next_br_info_br_eip),
        .nextLatches_br_info_br_xcl_i              (dc_latches_next_br_info_br_xcl),
        .nextLatches_br_info_br_pred_taken_i       (dc_latches_next_br_info_br_pred_taken),
        .nextLatches_br_info_speculative_target_i  (dc_latches_next_br_info_speculative_target),
        .nextLatches_rr_gp_i                       (dc_latches_next_rr_gp),
        .nextLatches_ld_vaddy_i                    (dc_latches_next_ld_vaddy),
        .nextLatches_seg0_limit_w_datasize_i       (dc_latches_next_seg0_limit_w_datasize),
        .nextLatches_seg0_limit_wo_datasize_i      (dc_latches_next_seg0_limit_wo_datasize),
        .nextLatches_next_ld_vaddy_i               (dc_latches_next_next_ld_vaddy),
        .nextLatches_ld_laddy_i                    (dc_latches_next_ld_laddy),
        .nextLatches_ld_stack_access_i             (dc_latches_next_ld_stack_access),
        .nextLatches_st_vaddy_i                    (dc_latches_next_st_vaddy),
        .nextLatches_seg1_limit_w_datasize_i       (dc_latches_next_seg1_limit_w_datasize),
        .nextLatches_seg1_limit_wo_datasize_i      (dc_latches_next_seg1_limit_wo_datasize),
        .nextLatches_next_st_vaddy_i               (dc_latches_next_next_st_vaddy),
        .nextLatches_st_laddy_i                    (dc_latches_next_st_laddy),
        .nextLatches_st_stack_access_i             (dc_latches_next_st_stack_access),
        .nextLatches_NEIP_i                        (dc_latches_next_NEIP),
        .nextLatches_EIP_i                         (dc_latches_next_EIP),
        .nextLatches_EAX_i                         (dc_latches_next_EAX),
        .nextLatches_imm64_i                       (dc_latches_next_imm64),
        .nextLatches_sr_id_i                       (dc_latches_next_sr_id),
        .nextLatches_sr_data_i                     (dc_latches_next_sr_data),
        .nextLatches_dr_id_i                       (dc_latches_next_dr_id),
        .nextLatches_dr_data_i                     (dc_latches_next_dr_data),

        // ---- latches outputs ----
        .latches_valid_o                       (dc_latches_valid),
        .latches_cs_LD_OP_o                    (dc_latches_cs_LD_OP),
        .latches_cs_ST_OP_o                    (dc_latches_cs_ST_OP),
        .latches_cs_dr_upper8_o                (dc_latches_cs_dr_upper8),
        .latches_cs_sr_upper8_o                (dc_latches_cs_sr_upper8),
        .latches_cs_datasize_o                 (dc_latches_cs_datasize),
        .latches_mem_cs_ST_OP_o                (dc_latches_mem_cs_ST_OP),
        .latches_mem_cs_LD_OP_o                (dc_latches_mem_cs_LD_OP),
        .latches_exe_cs_ST_OP_o                (dc_latches_exe_cs_ST_OP),
        .latches_exe_cs_OP_TYPE_o              (dc_latches_exe_cs_OP_TYPE),
        .latches_exe_cs_alu_inputA_sel_o       (dc_latches_exe_cs_alu_inputA_sel),
        .latches_exe_cs_alu_inputB_sel_o       (dc_latches_exe_cs_alu_inputB_sel),
        .latches_exe_cs_branch_target_sel_o    (dc_latches_exe_cs_branch_target_sel),
        .latches_exe_cs_shift_by_one_o         (dc_latches_exe_cs_shift_by_one),
        .latches_exe_cs_br_ucond_o             (dc_latches_exe_cs_br_ucond),
        .latches_exe_cs_relative_branch_o      (dc_latches_exe_cs_relative_branch),
        .latches_exe_cs_special_br_o           (dc_latches_exe_cs_special_br),
        .latches_exe_cs_is_far_o               (dc_latches_exe_cs_is_far),
        .latches_exe_cs_is_call_o              (dc_latches_exe_cs_is_call),
        .latches_exe_cs_second_flag_needed_o   (dc_latches_exe_cs_second_flag_needed),
        .latches_exe_cs_rep_no_zf_update_o     (dc_latches_exe_cs_rep_no_zf_update),
        .latches_wb_cs_ST_OP_o                 (dc_latches_wb_cs_ST_OP),
        .latches_wb_cs_WB_DR_o                 (dc_latches_wb_cs_WB_DR),
        .latches_wb_cs_WB_SR_o                 (dc_latches_wb_cs_WB_SR),
        .latches_wb_cs_WB_EAX_o                (dc_latches_wb_cs_WB_EAX),
        .latches_br_info_valid_o               (dc_latches_br_info_valid),
        .latches_br_info_br_eip_o              (dc_latches_br_info_br_eip),
        .latches_br_info_br_xcl_o              (dc_latches_br_info_br_xcl),
        .latches_br_info_br_pred_taken_o       (dc_latches_br_info_br_pred_taken),
        .latches_br_info_speculative_target_o  (dc_latches_br_info_speculative_target),
        .latches_rr_gp_o                       (dc_latches_rr_gp),
        .latches_ld_vaddy_o                    (dc_latches_ld_vaddy),
        .latches_seg0_limit_w_datasize_o       (dc_latches_seg0_limit_w_datasize),
        .latches_seg0_limit_wo_datasize_o      (dc_latches_seg0_limit_wo_datasize),
        .latches_next_ld_vaddy_o               (dc_latches_next_ld_vaddy),
        .latches_ld_laddy_o                    (dc_latches_ld_laddy),
        .latches_ld_stack_access_o             (dc_latches_ld_stack_access),
        .latches_st_vaddy_o                    (dc_latches_st_vaddy),
        .latches_seg1_limit_w_datasize_o       (dc_latches_seg1_limit_w_datasize),
        .latches_seg1_limit_wo_datasize_o      (dc_latches_seg1_limit_wo_datasize),
        .latches_next_st_vaddy_o               (dc_latches_next_st_vaddy),
        .latches_st_laddy_o                    (dc_latches_st_laddy),
        .latches_st_stack_access_o             (dc_latches_st_stack_access),
        .latches_NEIP_o                        (dc_latches_NEIP),
        .latches_EIP_o                         (dc_latches_EIP),
        .latches_EAX_o                         (dc_latches_EAX),
        .latches_imm64_o                       (dc_latches_imm64),
        .latches_sr_id_o                       (dc_latches_sr_id),
        .latches_sr_data_o                     (dc_latches_sr_data),
        .latches_dr_id_o                       (dc_latches_dr_id),
        .latches_dr_data_o                     (dc_latches_dr_data)
    );

    DC dc_unit (
        .clk(clk),
        .rst(rst),

        // ---- dc_latches_t (latches_i) ----
        .latches_valid                       (dc_latches_valid),
        .latches_cs_LD_OP                    (dc_latches_cs_LD_OP),
        .latches_cs_ST_OP                    (dc_latches_cs_ST_OP),
        .latches_cs_dr_upper8                (dc_latches_cs_dr_upper8),
        .latches_cs_sr_upper8                (dc_latches_cs_sr_upper8),
        .latches_cs_datasize                 (dc_latches_cs_datasize),
        .latches_mem_cs_ST_OP                (dc_latches_mem_cs_ST_OP),
        .latches_mem_cs_LD_OP                (dc_latches_mem_cs_LD_OP),
        .latches_exe_cs_ST_OP                (dc_latches_exe_cs_ST_OP),
        .latches_exe_cs_OP_TYPE              (dc_latches_exe_cs_OP_TYPE),
        .latches_exe_cs_alu_inputA_sel       (dc_latches_exe_cs_alu_inputA_sel[4:0]),
        .latches_exe_cs_alu_inputB_sel       (dc_latches_exe_cs_alu_inputB_sel[4:0]),
        .latches_exe_cs_branch_target_sel    (dc_latches_exe_cs_branch_target_sel[4:0]),
        .latches_exe_cs_shift_by_one         (dc_latches_exe_cs_shift_by_one),
        .latches_exe_cs_br_ucond             (dc_latches_exe_cs_br_ucond),
        .latches_exe_cs_relative_branch      (dc_latches_exe_cs_relative_branch),
        .latches_exe_cs_special_br           (dc_latches_exe_cs_special_br),
        .latches_exe_cs_is_far               (dc_latches_exe_cs_is_far),
        .latches_exe_cs_is_call              (dc_latches_exe_cs_is_call),
        .latches_exe_cs_second_flag_needed   (dc_latches_exe_cs_second_flag_needed),
        .latches_exe_cs_rep_no_zf_update     (dc_latches_exe_cs_rep_no_zf_update),
        .latches_wb_cs_ST_OP                 (dc_latches_wb_cs_ST_OP),
        .latches_wb_cs_WB_DR                 (dc_latches_wb_cs_WB_DR),
        .latches_wb_cs_WB_SR                 (dc_latches_wb_cs_WB_SR),
        .latches_wb_cs_WB_EAX                (dc_latches_wb_cs_WB_EAX),
        .latches_br_info_valid               (dc_latches_br_info_valid),
        .latches_br_info_br_eip              (dc_latches_br_info_br_eip),
        .latches_br_info_br_xcl              (dc_latches_br_info_br_xcl),
        .latches_br_info_br_pred_taken       (dc_latches_br_info_br_pred_taken),
        .latches_br_info_speculative_target  (dc_latches_br_info_speculative_target),
        .latches_rr_gp                       (dc_latches_rr_gp),
        .latches_ld_vaddy                    (dc_latches_ld_vaddy),
        .latches_seg0_limit_w_datasize       (dc_latches_seg0_limit_w_datasize),
        .latches_seg0_limit_wo_datasize      (dc_latches_seg0_limit_wo_datasize),
        .latches_next_ld_vaddy               (dc_latches_next_ld_vaddy),
        .latches_ld_laddy                    (dc_latches_ld_laddy),
        .latches_ld_stack_access             (dc_latches_ld_stack_access),
        .latches_st_vaddy                    (dc_latches_st_vaddy),
        .latches_seg1_limit_w_datasize       (dc_latches_seg1_limit_w_datasize),
        .latches_seg1_limit_wo_datasize      (dc_latches_seg1_limit_wo_datasize),
        .latches_next_st_vaddy               (dc_latches_next_st_vaddy),
        .latches_st_laddy                    (dc_latches_st_laddy),
        .latches_st_stack_access             (dc_latches_st_stack_access),
        .latches_NEIP                        (dc_latches_NEIP),
        .latches_EIP                         (dc_latches_EIP),
        .latches_EAX                         (dc_latches_EAX),
        .latches_imm64                       (dc_latches_imm64),
        .latches_sr_id                       (dc_latches_sr_id),
        .latches_sr_data                     (dc_latches_sr_data),
        .latches_dr_id                       (dc_latches_dr_id),
        .latches_dr_data                     (dc_latches_dr_data),

        // ---- fetch_outputs_t (fetch_outs_i) ----
        .fetch_outs_exp_pipe_clear           (fetch_outputs_exp_pipe_clear),

        // ---- mem_outputs_t (mem_outs_i) ----
        .mem_outs_valid                      (mem_outputs_valid),
        .mem_outs_stall                      (mem_outputs_stall),
        .mem_outs_ST_OP                      (mem_outputs_ST_OP),
        .mem_outs_ST_XCL                     (mem_outputs_ST_XCL),
        .mem_outs_ST_PADDR_0                 (mem_outputs_ST_PADDR_0),
        .mem_outs_ST_PADDR_1                 (mem_outputs_ST_PADDR_1),

        // ---- exe_outputs_t (exe_outs_i) ----
        .exe_outs_valid                      (exe_outputs_valid),
        .exe_outs_ST_OP                      (exe_outputs_ST_OP),
        .exe_outs_ST_XCL                     (exe_outputs_ST_XCL),
        .exe_outs_ST_PADDR_0                 (exe_outputs_ST_PADDR_0),
        .exe_outs_ST_PADDR_1                 (exe_outputs_ST_PADDR_1),
        .exe_outs_br_res_flush               (exe_outputs_br_res_out_flush),

        // ---- wb_outputs_t (wb_outs_i) ----
        .wb_outs_valid                       (wb_outputs_valid),
        .wb_outs_wb_stall                    (wb_outputs_wb_stall),
        .wb_outs_ST_OP                       (wb_outputs_ST_OP),
        .wb_outs_ST_XCL                      (wb_outputs_ST_XCL),
        .wb_outs_ST_PADDR_0                  (wb_outputs_ST_PADDR_0),
        .wb_outs_ST_PADDR_1                  (wb_outputs_ST_PADDR_1),
        .wb_outs_dep_check_entry_0_valid     (wb_outputs_dep_check_entries_0_valid),
        .wb_outs_dep_check_entry_0_address   (wb_outputs_dep_check_entries_0_address),
        .wb_outs_dep_check_entry_1_valid     (wb_outputs_dep_check_entries_1_valid),
        .wb_outs_dep_check_entry_1_address   (wb_outputs_dep_check_entries_1_address),
        .wb_outs_dep_check_entry_2_valid     (wb_outputs_dep_check_entries_2_valid),
        .wb_outs_dep_check_entry_2_address   (wb_outputs_dep_check_entries_2_address),
        .wb_outs_dep_check_entry_3_valid     (wb_outputs_dep_check_entries_3_valid),
        .wb_outs_dep_check_entry_3_address   (wb_outputs_dep_check_entries_3_address),
        .wb_outs_dep_check_entry_4_valid     (wb_outputs_dep_check_entries_4_valid),
        .wb_outs_dep_check_entry_4_address   (wb_outputs_dep_check_entries_4_address),
        .wb_outs_dep_check_entry_5_valid     (wb_outputs_dep_check_entries_5_valid),
        .wb_outs_dep_check_entry_5_address   (wb_outputs_dep_check_entries_5_address),
        .wb_outs_dep_check_entry_6_valid     (wb_outputs_dep_check_entries_6_valid),
        .wb_outs_dep_check_entry_6_address   (wb_outputs_dep_check_entries_6_address),
        .wb_outs_dep_check_entry_7_valid     (wb_outputs_dep_check_entries_7_valid),
        .wb_outs_dep_check_entry_7_address   (wb_outputs_dep_check_entries_7_address),
        .wb_outs_dep_check_entry_8_valid     (wb_outputs_dep_check_entries_8_valid),
        .wb_outs_dep_check_entry_8_address   (wb_outputs_dep_check_entries_8_address),
        .wb_outs_dep_check_entry_9_valid     (wb_outputs_dep_check_entries_9_valid),
        .wb_outs_dep_check_entry_9_address   (wb_outputs_dep_check_entries_9_address),
        .wb_outs_dep_check_entry_10_valid    (wb_outputs_dep_check_entries_10_valid),
        .wb_outs_dep_check_entry_10_address  (wb_outputs_dep_check_entries_10_address),
        .wb_outs_dep_check_entry_11_valid    (wb_outputs_dep_check_entries_11_valid),
        .wb_outs_dep_check_entry_11_address  (wb_outputs_dep_check_entries_11_address),
        .wb_outs_dep_check_entry_12_valid    (wb_outputs_dep_check_entries_12_valid),
        .wb_outs_dep_check_entry_12_address  (wb_outputs_dep_check_entries_12_address),
        .wb_outs_dep_check_entry_13_valid    (wb_outputs_dep_check_entries_13_valid),
        .wb_outs_dep_check_entry_13_address  (wb_outputs_dep_check_entries_13_address),
        .wb_outs_dep_check_entry_14_valid    (wb_outputs_dep_check_entries_14_valid),
        .wb_outs_dep_check_entry_14_address  (wb_outputs_dep_check_entries_14_address),
        .wb_outs_dep_check_entry_15_valid    (wb_outputs_dep_check_entries_15_valid),
        .wb_outs_dep_check_entry_15_address  (wb_outputs_dep_check_entries_15_address),

        // ---- DCache reqServed scalars ----
        .req_served_mio                      (DCacheIn_reqServed_MIO),
        .req_served_0                        (DCacheIn_reqServed_0),
        .req_served_1                        (DCacheIn_reqServed_1),

        // ---- mem_latches_next_o (mem_latches_t) outputs ----
        .mem_latches_next_valid                       (mem_latches_next_valid),
        .mem_latches_next_cs_ST_OP                    (mem_latches_next_cs_ST_OP),
        .mem_latches_next_cs_LD_OP                    (mem_latches_next_cs_LD_OP),
        .mem_latches_next_exe_cs_ST_OP                (mem_latches_next_exe_cs_ST_OP),
        .mem_latches_next_exe_cs_OP_TYPE              (mem_latches_next_exe_cs_OP_TYPE),
        .mem_latches_next_exe_cs_alu_inputA_sel       (mem_latches_next_exe_cs_alu_inputA_sel[4:0]),
        .mem_latches_next_exe_cs_alu_inputB_sel       (mem_latches_next_exe_cs_alu_inputB_sel[4:0]),
        .mem_latches_next_exe_cs_branch_target_sel    (mem_latches_next_exe_cs_branch_target_sel[4:0]),
        .mem_latches_next_exe_cs_shift_by_one         (mem_latches_next_exe_cs_shift_by_one),
        .mem_latches_next_exe_cs_br_ucond             (mem_latches_next_exe_cs_br_ucond),
        .mem_latches_next_exe_cs_relative_branch      (mem_latches_next_exe_cs_relative_branch),
        .mem_latches_next_exe_cs_special_br           (mem_latches_next_exe_cs_special_br),
        .mem_latches_next_exe_cs_is_far               (mem_latches_next_exe_cs_is_far),
        .mem_latches_next_exe_cs_is_call              (mem_latches_next_exe_cs_is_call),
        .mem_latches_next_exe_cs_second_flag_needed   (mem_latches_next_exe_cs_second_flag_needed),
        .mem_latches_next_exe_cs_rep_no_zf_update     (mem_latches_next_exe_cs_rep_no_zf_update),
        .mem_latches_next_wb_cs_ST_OP                 (mem_latches_next_wb_cs_ST_OP),
        .mem_latches_next_wb_cs_WB_DR                 (mem_latches_next_wb_cs_WB_DR),
        .mem_latches_next_wb_cs_WB_SR                 (mem_latches_next_wb_cs_WB_SR),
        .mem_latches_next_wb_cs_WB_EAX                (mem_latches_next_wb_cs_WB_EAX),
        .mem_latches_next_br_info_valid               (mem_latches_next_br_info_valid),
        .mem_latches_next_br_info_br_eip              (mem_latches_next_br_info_br_eip),
        .mem_latches_next_br_info_br_xcl              (mem_latches_next_br_info_br_xcl),
        .mem_latches_next_br_info_br_pred_taken       (mem_latches_next_br_info_br_pred_taken),
        .mem_latches_next_br_info_speculative_target  (mem_latches_next_br_info_speculative_target),
        .mem_latches_next_data_size_vec               (mem_latches_next_data_size_vec),
        .mem_latches_next_sr_data_size_vec            (mem_latches_next_sr_data_size_vec),
        .mem_latches_next_shift_sr_up                 (mem_latches_next_shift_sr_up),
        .mem_latches_next_shift_sr_down               (mem_latches_next_shift_sr_down),
        .mem_latches_next_ST_XCL                      (mem_latches_next_ST_XCL),
        .mem_latches_next_ST_PADDR_0                  (mem_latches_next_ST_PADDR_0),
        .mem_latches_next_ST_PADDR_1                  (mem_latches_next_ST_PADDR_1),
        .mem_latches_next_MIO                         (mem_latches_next_MIO),
        .mem_latches_next_NEIP                        (mem_latches_next_NEIP),
        .mem_latches_next_EIP                         (mem_latches_next_EIP),
        .mem_latches_next_EAX                         (mem_latches_next_EAX),
        .mem_latches_next_imm64                       (mem_latches_next_imm64),
        .mem_latches_next_sr_id                       (mem_latches_next_sr_id),
        .mem_latches_next_sr_data                     (mem_latches_next_sr_data),
        .mem_latches_next_dr_id                       (mem_latches_next_dr_id),
        .mem_latches_next_dr_data                     (mem_latches_next_dr_data),
        .mem_latches_next_LD_XCL                      (mem_latches_next_LD_XCL),
        .mem_latches_next_swapLines                   (mem_latches_next_swapLines),
        .mem_latches_next_LD_PADDR_0                  (mem_latches_next_LD_PADDR_0),
        .mem_latches_next_LD_PADDR_1                  (mem_latches_next_LD_PADDR_1),

        // ---- dc_outs_o (dc_outputs_t) outputs ----
        .dc_outs_valid              (dc_outputs_valid),
        .dc_outs_dc_eip             (dc_outputs_dc_eip),
        .dc_outs_stall              (dc_outputs_stall),
        .dc_outs_exp_present        (dc_outputs_exp_present),
        .dc_outs_exp_pf             (dc_outputs_exp_pf),
        .dc_outs_ld_addr_0_V        (dc_outputs_ld_addr_0_V),
        .dc_outs_ld_addr_0          (dc_outputs_ld_addr_0),
        .dc_outs_ld_addr_1_V        (dc_outputs_ld_addr_1_V),
        .dc_outs_ld_addr_1          (dc_outputs_ld_addr_1),
        .dc_outs_ld_addr_MIO_V      (dc_outputs_ld_addr_MIO_V),
        .dc_outs_ld_addr_MIO        (dc_outputs_ld_addr_MIO),
        .dc_outs_mem_stage_latch_we (dc_outputs_mem_stage_latch_we)
    );

    MEM_Latches mem_latches_unit (
        .clk(clk),
        .rst(rst),
        .write_enable_i(dc_outputs_mem_stage_latch_we),
        .flush         (exe_outputs_br_res_out_flush),
        .farFlush      (exe_outputs_br_res_out_farFlush),

        // ---- nextLatches inputs ----
        .nextLatches_valid_i                       (mem_latches_next_valid),
        .nextLatches_cs_ST_OP_i                    (mem_latches_next_cs_ST_OP),
        .nextLatches_cs_LD_OP_i                    (mem_latches_next_cs_LD_OP),
        .nextLatches_exe_cs_ST_OP_i                (mem_latches_next_exe_cs_ST_OP),
        .nextLatches_exe_cs_OP_TYPE_i              (mem_latches_next_exe_cs_OP_TYPE),
        .nextLatches_exe_cs_alu_inputA_sel_i       (mem_latches_next_exe_cs_alu_inputA_sel),
        .nextLatches_exe_cs_alu_inputB_sel_i       (mem_latches_next_exe_cs_alu_inputB_sel),
        .nextLatches_exe_cs_branch_target_sel_i    (mem_latches_next_exe_cs_branch_target_sel),
        .nextLatches_exe_cs_shift_by_one_i         (mem_latches_next_exe_cs_shift_by_one),
        .nextLatches_exe_cs_br_ucond_i             (mem_latches_next_exe_cs_br_ucond),
        .nextLatches_exe_cs_relative_branch_i      (mem_latches_next_exe_cs_relative_branch),
        .nextLatches_exe_cs_special_br_i           (mem_latches_next_exe_cs_special_br),
        .nextLatches_exe_cs_is_far_i               (mem_latches_next_exe_cs_is_far),
        .nextLatches_exe_cs_is_call_i              (mem_latches_next_exe_cs_is_call),
        .nextLatches_exe_cs_second_flag_needed_i   (mem_latches_next_exe_cs_second_flag_needed),
        .nextLatches_exe_cs_rep_no_zf_update_i     (mem_latches_next_exe_cs_rep_no_zf_update),
        .nextLatches_wb_cs_ST_OP_i                 (mem_latches_next_wb_cs_ST_OP),
        .nextLatches_wb_cs_WB_DR_i                 (mem_latches_next_wb_cs_WB_DR),
        .nextLatches_wb_cs_WB_SR_i                 (mem_latches_next_wb_cs_WB_SR),
        .nextLatches_wb_cs_WB_EAX_i                (mem_latches_next_wb_cs_WB_EAX),
        .nextLatches_br_info_valid_i               (mem_latches_next_br_info_valid),
        .nextLatches_br_info_br_eip_i              (mem_latches_next_br_info_br_eip),
        .nextLatches_br_info_br_xcl_i              (mem_latches_next_br_info_br_xcl),
        .nextLatches_br_info_br_pred_taken_i       (mem_latches_next_br_info_br_pred_taken),
        .nextLatches_br_info_speculative_target_i  (mem_latches_next_br_info_speculative_target),
        .nextLatches_data_size_vec_i               (mem_latches_next_data_size_vec),
        .nextLatches_sr_data_size_vec_i            (mem_latches_next_sr_data_size_vec),
        .nextLatches_shift_sr_up_i                 (mem_latches_next_shift_sr_up),
        .nextLatches_shift_sr_down_i               (mem_latches_next_shift_sr_down),
        .nextLatches_ST_XCL_i                      (mem_latches_next_ST_XCL),
        .nextLatches_ST_PADDR_0_i                  (mem_latches_next_ST_PADDR_0),
        .nextLatches_ST_PADDR_1_i                  (mem_latches_next_ST_PADDR_1),
        .nextLatches_MIO_i                         (mem_latches_next_MIO),
        .nextLatches_NEIP_i                        (mem_latches_next_NEIP),
        .nextLatches_EIP_i                         (mem_latches_next_EIP),
        .nextLatches_EAX_i                         (mem_latches_next_EAX),
        .nextLatches_imm64_i                       (mem_latches_next_imm64),
        .nextLatches_sr_id_i                       (mem_latches_next_sr_id),
        .nextLatches_sr_data_i                     (mem_latches_next_sr_data),
        .nextLatches_dr_id_i                       (mem_latches_next_dr_id),
        .nextLatches_dr_data_i                     (mem_latches_next_dr_data),
        .nextLatches_LD_XCL_i                      (mem_latches_next_LD_XCL),
        .nextLatches_swapLines_i                   (mem_latches_next_swapLines),
        .nextLatches_LD_PADDR_0_i                  (mem_latches_next_LD_PADDR_0),
        .nextLatches_LD_PADDR_1_i                  (mem_latches_next_LD_PADDR_1),

        // ---- latches outputs ----
        .latches_valid_o                       (mem_latches_valid),
        .latches_cs_ST_OP_o                    (mem_latches_cs_ST_OP),
        .latches_cs_LD_OP_o                    (mem_latches_cs_LD_OP),
        .latches_exe_cs_ST_OP_o                (mem_latches_exe_cs_ST_OP),
        .latches_exe_cs_OP_TYPE_o              (mem_latches_exe_cs_OP_TYPE),
        .latches_exe_cs_alu_inputA_sel_o       (mem_latches_exe_cs_alu_inputA_sel),
        .latches_exe_cs_alu_inputB_sel_o       (mem_latches_exe_cs_alu_inputB_sel),
        .latches_exe_cs_branch_target_sel_o    (mem_latches_exe_cs_branch_target_sel),
        .latches_exe_cs_shift_by_one_o         (mem_latches_exe_cs_shift_by_one),
        .latches_exe_cs_br_ucond_o             (mem_latches_exe_cs_br_ucond),
        .latches_exe_cs_relative_branch_o      (mem_latches_exe_cs_relative_branch),
        .latches_exe_cs_special_br_o           (mem_latches_exe_cs_special_br),
        .latches_exe_cs_is_far_o               (mem_latches_exe_cs_is_far),
        .latches_exe_cs_is_call_o              (mem_latches_exe_cs_is_call),
        .latches_exe_cs_second_flag_needed_o   (mem_latches_exe_cs_second_flag_needed),
        .latches_exe_cs_rep_no_zf_update_o     (mem_latches_exe_cs_rep_no_zf_update),
        .latches_wb_cs_ST_OP_o                 (mem_latches_wb_cs_ST_OP),
        .latches_wb_cs_WB_DR_o                 (mem_latches_wb_cs_WB_DR),
        .latches_wb_cs_WB_SR_o                 (mem_latches_wb_cs_WB_SR),
        .latches_wb_cs_WB_EAX_o                (mem_latches_wb_cs_WB_EAX),
        .latches_br_info_valid_o               (mem_latches_br_info_valid),
        .latches_br_info_br_eip_o              (mem_latches_br_info_br_eip),
        .latches_br_info_br_xcl_o              (mem_latches_br_info_br_xcl),
        .latches_br_info_br_pred_taken_o       (mem_latches_br_info_br_pred_taken),
        .latches_br_info_speculative_target_o  (mem_latches_br_info_speculative_target),
        .latches_data_size_vec_o               (mem_latches_data_size_vec),
        .latches_sr_data_size_vec_o            (mem_latches_sr_data_size_vec),
        .latches_shift_sr_up_o                 (mem_latches_shift_sr_up),
        .latches_shift_sr_down_o               (mem_latches_shift_sr_down),
        .latches_ST_XCL_o                      (mem_latches_ST_XCL),
        .latches_ST_PADDR_0_o                  (mem_latches_ST_PADDR_0),
        .latches_ST_PADDR_1_o                  (mem_latches_ST_PADDR_1),
        .latches_MIO_o                         (mem_latches_MIO),
        .latches_NEIP_o                        (mem_latches_NEIP),
        .latches_EIP_o                         (mem_latches_EIP),
        .latches_EAX_o                         (mem_latches_EAX),
        .latches_imm64_o                       (mem_latches_imm64),
        .latches_sr_id_o                       (mem_latches_sr_id),
        .latches_sr_data_o                     (mem_latches_sr_data),
        .latches_dr_id_o                       (mem_latches_dr_id),
        .latches_dr_data_o                     (mem_latches_dr_data),
        .latches_LD_XCL_o                      (mem_latches_LD_XCL),
        .latches_swapLines_o                   (mem_latches_swapLines),
        .latches_LD_PADDR_0_o                  (mem_latches_LD_PADDR_0),
        .latches_LD_PADDR_1_o                  (mem_latches_LD_PADDR_1)
    );

    MEM mem_unit (
        .clk(clk),
        .rst(rst),

        // ---- mem_latches_t (latches_i) ----
        .latches_valid                       (mem_latches_valid),
        .latches_cs_ST_OP                    (mem_latches_cs_ST_OP),
        .latches_cs_LD_OP                    (mem_latches_cs_LD_OP),
        .latches_exe_cs_ST_OP                (mem_latches_exe_cs_ST_OP),
        .latches_exe_cs_OP_TYPE              (mem_latches_exe_cs_OP_TYPE[5:0]),
        .latches_exe_cs_alu_inputA_sel       (mem_latches_exe_cs_alu_inputA_sel[4:0]),
        .latches_exe_cs_alu_inputB_sel       (mem_latches_exe_cs_alu_inputB_sel[4:0]),
        .latches_exe_cs_branch_target_sel    (mem_latches_exe_cs_branch_target_sel[4:0]),
        .latches_exe_cs_shift_by_one         (mem_latches_exe_cs_shift_by_one),
        .latches_exe_cs_br_ucond             (mem_latches_exe_cs_br_ucond),
        .latches_exe_cs_relative_branch      (mem_latches_exe_cs_relative_branch),
        .latches_exe_cs_special_br           (mem_latches_exe_cs_special_br),
        .latches_exe_cs_is_far               (mem_latches_exe_cs_is_far),
        .latches_exe_cs_is_call              (mem_latches_exe_cs_is_call),
        .latches_exe_cs_second_flag_needed   (mem_latches_exe_cs_second_flag_needed),
        .latches_exe_cs_rep_no_zf_update     (mem_latches_exe_cs_rep_no_zf_update),
        .latches_wb_cs_ST_OP                 (mem_latches_wb_cs_ST_OP),
        .latches_wb_cs_WB_DR                 (mem_latches_wb_cs_WB_DR),
        .latches_wb_cs_WB_SR                 (mem_latches_wb_cs_WB_SR),
        .latches_wb_cs_WB_EAX                (mem_latches_wb_cs_WB_EAX),
        .latches_br_info_valid               (mem_latches_br_info_valid),
        .latches_br_info_br_eip              (mem_latches_br_info_br_eip),
        .latches_br_info_br_xcl              (mem_latches_br_info_br_xcl),
        .latches_br_info_br_pred_taken       (mem_latches_br_info_br_pred_taken),
        .latches_br_info_speculative_target  (mem_latches_br_info_speculative_target),
        .latches_data_size_vec               (mem_latches_data_size_vec),
        .latches_sr_data_size_vec            (mem_latches_sr_data_size_vec),
        .latches_shift_sr_up                 (mem_latches_shift_sr_up),
        .latches_shift_sr_down               (mem_latches_shift_sr_down),
        .latches_ST_XCL                      (mem_latches_ST_XCL),
        .latches_ST_PADDR_0                  (mem_latches_ST_PADDR_0),
        .latches_ST_PADDR_1                  (mem_latches_ST_PADDR_1),
        .latches_MIO                         (mem_latches_MIO),
        .latches_NEIP                        (mem_latches_NEIP),
        .latches_EIP                         (mem_latches_EIP),
        .latches_EAX                         (mem_latches_EAX),
        .latches_imm64                       (mem_latches_imm64),
        .latches_sr_id                       (mem_latches_sr_id),
        .latches_sr_data                     (mem_latches_sr_data),
        .latches_dr_id                       (mem_latches_dr_id),
        .latches_dr_data                     (mem_latches_dr_data),
        .latches_LD_XCL                      (mem_latches_LD_XCL),
        .latches_swapLines                   (mem_latches_swapLines),
        .latches_LD_PADDR_0                  (mem_latches_LD_PADDR_0),
        .latches_LD_PADDR_1                  (mem_latches_LD_PADDR_1),

        // ---- exe_outputs_t (exe_outs_i) ----
        .exe_outs_valid                      (exe_outputs_valid),
        .exe_outs_br_res_flush               (exe_outputs_br_res_out_flush),

        // ---- wb_outputs_t (wb_outs_i) ----
        .wb_outs_wb_stall                    (wb_outputs_wb_stall),

        // ---- DCache scalar / packed inputs ----
        .hit_0                               (DCacheIn_hit_0),
        .hit_1                               (DCacheIn_hit_1),
        .hit_2                               (DCacheIn_hit_2),
        .hit_3                               (DCacheIn_hit_3),
        .cacheline_0                         (dcache_cacheline_w[0]),
        .cacheline_1                         (dcache_cacheline_w[1]),
        .cacheline_2                         (dcache_cacheline_w[2]),
        .cacheline_3                         (dcache_cacheline_w[3]),
        .hit_MIO                             (DCacheIn_hit_MIO),
        .line_MIO                            (dcache_line_MIO_w),

        // ---- exe_latches_next_o (exe_latches_t) outputs ----
        .exe_latches_next_valid                       (exe_latches_next_valid),
        .exe_latches_next_cs_ST_OP                    (exe_latches_next_cs_ST_OP),
        .exe_latches_next_cs_OP_TYPE                  (exe_latches_next_cs_OP_TYPE[5:0]),
        .exe_latches_next_cs_alu_inputA_sel           (exe_latches_next_cs_alu_inputA_sel[4:0]),
        .exe_latches_next_cs_alu_inputB_sel           (exe_latches_next_cs_alu_inputB_sel[4:0]),
        .exe_latches_next_cs_branch_target_sel        (exe_latches_next_cs_branch_target_sel[4:0]),
        .exe_latches_next_cs_shift_by_one             (exe_latches_next_cs_shift_by_one),
        .exe_latches_next_cs_br_ucond                 (exe_latches_next_cs_br_ucond),
        .exe_latches_next_cs_relative_branch          (exe_latches_next_cs_relative_branch),
        .exe_latches_next_cs_special_br               (exe_latches_next_cs_special_br),
        .exe_latches_next_cs_is_far                   (exe_latches_next_cs_is_far),
        .exe_latches_next_cs_is_call                  (exe_latches_next_cs_is_call),
        .exe_latches_next_cs_second_flag_needed       (exe_latches_next_cs_second_flag_needed),
        .exe_latches_next_cs_rep_no_zf_update         (exe_latches_next_cs_rep_no_zf_update),
        .exe_latches_next_wb_cs_ST_OP                 (exe_latches_next_wb_cs_ST_OP),
        .exe_latches_next_wb_cs_WB_DR                 (exe_latches_next_wb_cs_WB_DR),
        .exe_latches_next_wb_cs_WB_SR                 (exe_latches_next_wb_cs_WB_SR),
        .exe_latches_next_wb_cs_WB_EAX                (exe_latches_next_wb_cs_WB_EAX),
        .exe_latches_next_data_size_vec               (exe_latches_next_data_size_vec),
        .exe_latches_next_sr_data_size_vec            (exe_latches_next_sr_data_size_vec),
        .exe_latches_next_shift_sr_up                 (exe_latches_next_shift_sr_up),
        .exe_latches_next_shift_sr_down               (exe_latches_next_shift_sr_down),
        .exe_latches_next_ST_XCL                      (exe_latches_next_ST_XCL),
        .exe_latches_next_ST_PADDR_0                  (exe_latches_next_ST_PADDR_0),
        .exe_latches_next_ST_PADDR_1                  (exe_latches_next_ST_PADDR_1),
        .exe_latches_next_MIO                         (exe_latches_next_MIO),
        .exe_latches_next_br_info_valid               (exe_latches_next_br_info_valid),
        .exe_latches_next_br_info_br_eip              (exe_latches_next_br_info_br_eip),
        .exe_latches_next_br_info_br_xcl              (exe_latches_next_br_info_br_xcl),
        .exe_latches_next_br_info_br_pred_taken       (exe_latches_next_br_info_br_pred_taken),
        .exe_latches_next_br_info_speculative_target  (exe_latches_next_br_info_speculative_target),
        .exe_latches_next_br_rel_target               (exe_latches_next_br_rel_target),
        .exe_latches_next_NEIP                        (exe_latches_next_NEIP),
        .exe_latches_next_EIP                         (exe_latches_next_EIP),
        .exe_latches_next_EAX                         (exe_latches_next_EAX),
        .exe_latches_next_imm64                       (exe_latches_next_imm64),
        .exe_latches_next_ld_buf                      (exe_latches_next_ld_buf_w),
        .exe_latches_next_sr_id                       (exe_latches_next_sr_id),
        .exe_latches_next_sr_data                     (exe_latches_next_sr_data),
        .exe_latches_next_dr_id                       (exe_latches_next_dr_id),
        .exe_latches_next_dr_data                     (exe_latches_next_dr_data),
        .exe_latches_next_ld_addy                     (exe_latches_next_ld_addy),

        // ---- mem_outputs_t (outs_o) outputs ----
        .outs_valid                          (mem_outputs_valid),
        .outs_stall                          (mem_outputs_stall),
        .outs_ST_XCL                         (mem_outputs_ST_XCL),
        .outs_ST_PADDR_0                     (mem_outputs_ST_PADDR_0),
        .outs_ST_PADDR_1                     (mem_outputs_ST_PADDR_1),
        .outs_ST_OP                          (mem_outputs_ST_OP),
        .outs_clr_dcache_arb_latches_0       (mem_outputs_clr_dcache_arb_latches_0),
        .outs_clr_dcache_arb_latches_1       (mem_outputs_clr_dcache_arb_latches_1),
        .outs_clr_dcache_arb_latches_2       (mem_outputs_clr_dcache_arb_latches_2),
        .outs_clr_dcache_arb_latches_3       (mem_outputs_clr_dcache_arb_latches_3),
        .outs_clr_dcache_mio_latch           (mem_outputs_clr_dcache_mio_latch),
        .outs_exe_stage_latch_we             (mem_outputs_exe_stage_latch_we)
    );

    EXE_Latches exe_latches_unit (
        .clk(clk),
        .rst(rst),
        .write_enable_i(mem_outputs_exe_stage_latch_we),
        .flush         (exe_outputs_br_res_out_flush),

        // ---- nextLatches inputs ----
        .nextLatches_valid_i                       (exe_latches_next_valid),
        .nextLatches_cs_ST_OP_i                    (exe_latches_next_cs_ST_OP),
        .nextLatches_cs_OP_TYPE_i                  (exe_latches_next_cs_OP_TYPE),
        .nextLatches_cs_alu_inputA_sel_i           (exe_latches_next_cs_alu_inputA_sel),
        .nextLatches_cs_alu_inputB_sel_i           (exe_latches_next_cs_alu_inputB_sel),
        .nextLatches_cs_branch_target_sel_i        (exe_latches_next_cs_branch_target_sel),
        .nextLatches_cs_shift_by_one_i             (exe_latches_next_cs_shift_by_one),
        .nextLatches_cs_br_ucond_i                 (exe_latches_next_cs_br_ucond),
        .nextLatches_cs_relative_branch_i          (exe_latches_next_cs_relative_branch),
        .nextLatches_cs_special_br_i               (exe_latches_next_cs_special_br),
        .nextLatches_cs_is_far_i                   (exe_latches_next_cs_is_far),
        .nextLatches_cs_is_call_i                  (exe_latches_next_cs_is_call),
        .nextLatches_cs_second_flag_needed_i       (exe_latches_next_cs_second_flag_needed),
        .nextLatches_cs_rep_no_zf_update_i         (exe_latches_next_cs_rep_no_zf_update),
        .nextLatches_wb_cs_ST_OP_i                 (exe_latches_next_wb_cs_ST_OP),
        .nextLatches_wb_cs_WB_DR_i                 (exe_latches_next_wb_cs_WB_DR),
        .nextLatches_wb_cs_WB_SR_i                 (exe_latches_next_wb_cs_WB_SR),
        .nextLatches_wb_cs_WB_EAX_i                (exe_latches_next_wb_cs_WB_EAX),
        .nextLatches_data_size_vec_i               (exe_latches_next_data_size_vec),
        .nextLatches_sr_data_size_vec_i            (exe_latches_next_sr_data_size_vec),
        .nextLatches_shift_sr_up_i                 (exe_latches_next_shift_sr_up),
        .nextLatches_shift_sr_down_i               (exe_latches_next_shift_sr_down),
        .nextLatches_ST_XCL_i                      (exe_latches_next_ST_XCL),
        .nextLatches_ST_PADDR_0_i                  (exe_latches_next_ST_PADDR_0),
        .nextLatches_ST_PADDR_1_i                  (exe_latches_next_ST_PADDR_1),
        .nextLatches_MIO_i                         (exe_latches_next_MIO),
        .nextLatches_br_info_valid_i               (exe_latches_next_br_info_valid),
        .nextLatches_br_info_br_eip_i              (exe_latches_next_br_info_br_eip),
        .nextLatches_br_info_br_xcl_i              (exe_latches_next_br_info_br_xcl),
        .nextLatches_br_info_br_pred_taken_i       (exe_latches_next_br_info_br_pred_taken),
        .nextLatches_br_info_speculative_target_i  (exe_latches_next_br_info_speculative_target),
        .nextLatches_br_rel_target_i               (exe_latches_next_br_rel_target),
        .nextLatches_NEIP_i                        (exe_latches_next_NEIP),
        .nextLatches_EIP_i                         (exe_latches_next_EIP),
        .nextLatches_EAX_i                         (exe_latches_next_EAX),
        .nextLatches_imm64_i                       (exe_latches_next_imm64),
        .nextLatches_ld_buf_i                      (exe_latches_next_ld_buf_w),
        .nextLatches_sr_id_i                       (exe_latches_next_sr_id),
        .nextLatches_sr_data_i                     (exe_latches_next_sr_data),
        .nextLatches_dr_id_i                       (exe_latches_next_dr_id),
        .nextLatches_dr_data_i                     (exe_latches_next_dr_data),
        .nextLatches_ld_addy_i                     (exe_latches_next_ld_addy),

        // ---- latches outputs ----
        .latches_valid_o                       (exe_latches_valid),
        .latches_cs_ST_OP_o                    (exe_latches_cs_ST_OP),
        .latches_cs_OP_TYPE_o                  (exe_latches_cs_OP_TYPE),
        .latches_cs_alu_inputA_sel_o           (exe_latches_cs_alu_inputA_sel),
        .latches_cs_alu_inputB_sel_o           (exe_latches_cs_alu_inputB_sel),
        .latches_cs_branch_target_sel_o        (exe_latches_cs_branch_target_sel),
        .latches_cs_shift_by_one_o             (exe_latches_cs_shift_by_one),
        .latches_cs_br_ucond_o                 (exe_latches_cs_br_ucond),
        .latches_cs_relative_branch_o          (exe_latches_cs_relative_branch),
        .latches_cs_special_br_o               (exe_latches_cs_special_br),
        .latches_cs_is_far_o                   (exe_latches_cs_is_far),
        .latches_cs_is_call_o                  (exe_latches_cs_is_call),
        .latches_cs_second_flag_needed_o       (exe_latches_cs_second_flag_needed),
        .latches_cs_rep_no_zf_update_o         (exe_latches_cs_rep_no_zf_update),
        .latches_wb_cs_ST_OP_o                 (exe_latches_wb_cs_ST_OP),
        .latches_wb_cs_WB_DR_o                 (exe_latches_wb_cs_WB_DR),
        .latches_wb_cs_WB_SR_o                 (exe_latches_wb_cs_WB_SR),
        .latches_wb_cs_WB_EAX_o                (exe_latches_wb_cs_WB_EAX),
        .latches_data_size_vec_o               (exe_latches_data_size_vec),
        .latches_sr_data_size_vec_o            (exe_latches_sr_data_size_vec),
        .latches_shift_sr_up_o                 (exe_latches_shift_sr_up),
        .latches_shift_sr_down_o               (exe_latches_shift_sr_down),
        .latches_ST_XCL_o                      (exe_latches_ST_XCL),
        .latches_ST_PADDR_0_o                  (exe_latches_ST_PADDR_0),
        .latches_ST_PADDR_1_o                  (exe_latches_ST_PADDR_1),
        .latches_MIO_o                         (exe_latches_MIO),
        .latches_br_info_valid_o               (exe_latches_br_info_valid),
        .latches_br_info_br_eip_o              (exe_latches_br_info_br_eip),
        .latches_br_info_br_xcl_o              (exe_latches_br_info_br_xcl),
        .latches_br_info_br_pred_taken_o       (exe_latches_br_info_br_pred_taken),
        .latches_br_info_speculative_target_o  (exe_latches_br_info_speculative_target),
        .latches_br_rel_target_o               (exe_latches_br_rel_target),
        .latches_NEIP_o                        (exe_latches_NEIP),
        .latches_EIP_o                         (exe_latches_EIP),
        .latches_EAX_o                         (exe_latches_EAX),
        .latches_imm64_o                       (exe_latches_imm64),
        .latches_ld_buf_o                      (exe_latches_ld_buf_w),
        .latches_sr_id_o                       (exe_latches_sr_id),
        .latches_sr_data_o                     (exe_latches_sr_data),
        .latches_dr_id_o                       (exe_latches_dr_id),
        .latches_dr_data_o                     (exe_latches_dr_data),
        .latches_ld_addy_o                     (exe_latches_ld_addy)
    );

    EXE execute_unit (
        .clk(clk),
        .rst(rst),

        .latches_valid                     (exe_latches_valid),
        .latches_cs_ST_OP                  (exe_latches_cs_ST_OP),
        .latches_cs_OP_TYPE                (exe_latches_cs_OP_TYPE[5:0]),
        .latches_cs_alu_inputA_sel         (exe_latches_cs_alu_inputA_sel[4:0]),
        .latches_cs_alu_inputB_sel         (exe_latches_cs_alu_inputB_sel[4:0]),
        .latches_cs_branch_target_sel      (exe_latches_cs_branch_target_sel[4:0]),
        .latches_cs_shift_by_one           (exe_latches_cs_shift_by_one),
        .latches_cs_br_ucond               (exe_latches_cs_br_ucond),
        .latches_cs_relative_branch        (exe_latches_cs_relative_branch),
        .latches_cs_special_br             (exe_latches_cs_special_br),
        .latches_cs_is_far                 (exe_latches_cs_is_far),
        .latches_cs_is_call                (exe_latches_cs_is_call),
        .latches_cs_second_flag_needed     (exe_latches_cs_second_flag_needed),
        .latches_cs_rep_no_zf_update       (exe_latches_cs_rep_no_zf_update),
        .latches_wb_cs_ST_OP               (exe_latches_wb_cs_ST_OP),
        .latches_wb_cs_WB_DR               (exe_latches_wb_cs_WB_DR),
        .latches_wb_cs_WB_SR               (exe_latches_wb_cs_WB_SR),
        .latches_wb_cs_WB_EAX              (exe_latches_wb_cs_WB_EAX),
        .latches_data_size_vec             (exe_latches_data_size_vec),
        .latches_sr_data_size_vec          (exe_latches_sr_data_size_vec),
        .latches_shift_sr_up               (exe_latches_shift_sr_up),
        .latches_shift_sr_down             (exe_latches_shift_sr_down),
        .latches_ST_XCL                    (exe_latches_ST_XCL),
        .latches_ST_PADDR_0                (exe_latches_ST_PADDR_0),
        .latches_ST_PADDR_1                (exe_latches_ST_PADDR_1),
        .latches_MIO                       (exe_latches_MIO),
        .latches_br_info_valid             (exe_latches_br_info_valid),
        .latches_br_info_br_eip            (exe_latches_br_info_br_eip),
        .latches_br_info_br_xcl            (exe_latches_br_info_br_xcl),
        .latches_br_info_br_pred_taken     (exe_latches_br_info_br_pred_taken),
        .latches_br_info_speculative_target(exe_latches_br_info_speculative_target),
        .latches_br_rel_target             (exe_latches_br_rel_target),
        .latches_NEIP                      (exe_latches_NEIP),
        .latches_EIP                       (exe_latches_EIP),
        .latches_EAX                       (exe_latches_EAX),
        .latches_imm64                     (exe_latches_imm64),
        .latches_ld_buf                    (exe_latches_ld_buf_w),
        .latches_sr_id                     (exe_latches_sr_id),
        .latches_sr_data                   (exe_latches_sr_data),
        .latches_dr_id                     (exe_latches_dr_id),
        .latches_dr_data                   (exe_latches_dr_data),
        .latches_ld_addy                   (exe_latches_ld_addy),

        .wb_outs_wb_stall                  (wb_outputs_wb_stall),

        .rr_outs_codeSeg_data              (rr_outputs_codeSeg_data),
        .rr_outs_regFileValues_0           (rr_outputs_regFileValues_0),
        .rr_outs_regFileValues_1           (rr_outputs_regFileValues_1),
        .rr_outs_regFileValues_2           (rr_outputs_regFileValues_2),
        .rr_outs_regFileValues_3           (rr_outputs_regFileValues_3),
        .rr_outs_regFileValues_4           (rr_outputs_regFileValues_4),
        .rr_outs_regFileValues_5           (rr_outputs_regFileValues_5),
        .rr_outs_regFileValues_6           (rr_outputs_regFileValues_6),
        .rr_outs_regFileValues_7           (rr_outputs_regFileValues_7),
        .rr_outs_regFileValues_8           (rr_outputs_regFileValues_8),
        .rr_outs_regFileValues_9           (rr_outputs_regFileValues_9),
        .rr_outs_regFileValues_10          (rr_outputs_regFileValues_10),
        .rr_outs_regFileValues_11          (rr_outputs_regFileValues_11),
        .rr_outs_regFileValues_12          (rr_outputs_regFileValues_12),
        .rr_outs_regFileValues_13          (rr_outputs_regFileValues_13),
        .rr_outs_regFileValues_14          (rr_outputs_regFileValues_14),
        .rr_outs_regFileValues_15          (rr_outputs_regFileValues_15),
        .rr_outs_regFileValues_16          (rr_outputs_regFileValues_16),
        .rr_outs_regFileValues_17          (rr_outputs_regFileValues_17),
        .rr_outs_regFileValues_18          (rr_outputs_regFileValues_18),
        .rr_outs_regFileValues_19          (rr_outputs_regFileValues_19),
        .rr_outs_regFileValues_20          (rr_outputs_regFileValues_20),
        .rr_outs_regFileValues_21          (rr_outputs_regFileValues_21),
        .rr_outs_regFileValues_22          (rr_outputs_regFileValues_22),
        .rr_outs_regFileValues_23          (rr_outputs_regFileValues_23),
        .rr_outs_regFileValues_24          (rr_outputs_regFileValues_24),
        .rr_outs_regFileValues_25          (rr_outputs_regFileValues_25),

        .wb_latches_next_valid             (wb_latches_next_valid),
        .wb_latches_next_cs_ST_OP          (wb_latches_next_cs_ST_OP),
        .wb_latches_next_cs_WB_DR          (wb_latches_next_cs_WB_DR),
        .wb_latches_next_cs_WB_SR          (wb_latches_next_cs_WB_SR),
        .wb_latches_next_cs_WB_EAX         (wb_latches_next_cs_WB_EAX),
        .wb_latches_next_ST_XCL            (wb_latches_next_ST_XCL),
        .wb_latches_next_ST_PADDR_0        (wb_latches_next_ST_PADDR_0),
        .wb_latches_next_ST_BIT_VEC_0      (wb_latches_next_ST_BIT_VEC_0),
        .wb_latches_next_ST_PADDR_1        (wb_latches_next_ST_PADDR_1),
        .wb_latches_next_ST_BIT_VEC_1      (wb_latches_next_ST_BIT_VEC_1),
        .wb_latches_next_MIO               (wb_latches_next_MIO),
        .wb_latches_next_EIP               (wb_latches_next_EIP),
        .wb_latches_next_res_buf           (exe_wb_latches_next_res_buf_w),
        .wb_latches_next_sr_id             (wb_latches_next_sr_id),
        .wb_latches_next_sr_data           (wb_latches_next_sr_data),
        .wb_latches_next_dr_id             (wb_latches_next_dr_id),
        .wb_latches_next_dr_data           (wb_latches_next_dr_data),
        .wb_latches_next_EAX               (wb_latches_next_EAX),

        .outs_valid                        (exe_outputs_valid),
        .outs_br_res_valid                 (exe_outputs_br_res_out_valid),
        .outs_br_res_flush                 (exe_outputs_br_res_out_flush),
        .outs_br_res_farFlush              (exe_outputs_br_res_out_farFlush),
        .outs_br_res_callFlush             (exe_outputs_br_res_out_callFlush),
        .outs_br_res_miss_prediction       (exe_outputs_br_res_out_miss_prediction),
        .outs_br_res_br_eip                (exe_outputs_br_res_out_br_eip),
        .outs_br_res_neip                  (exe_outputs_br_res_out_neip),
        .outs_br_res_br_target             (exe_outputs_br_res_out_br_target),
        .outs_br_res_taken                 (exe_outputs_br_res_out_taken),
        .outs_br_res_br_XCL                (exe_outputs_br_res_out_br_XCL),
        .outs_br_res_clr_exp_mode          (exe_outputs_br_res_out_clr_exp_mode),
        .outs_br_res_br_ucond              (exe_outputs_br_res_out_br_ucond),
        .outs_DR_0_we                      (exe_outputs_DR_0_we),
        .outs_DR_0_id                      (exe_outputs_DR_0_id),
        .outs_DR_0_data                    (exe_outputs_DR_0_data),
        .outs_DR_1_we                      (exe_outputs_DR_1_we),
        .outs_DR_1_id                      (exe_outputs_DR_1_id),
        .outs_DR_1_data                    (exe_outputs_DR_1_data),
        .outs_clr_ZF_sb                    (exe_outputs_clr_ZF_sb),
        .outs_ZF                           (exe_outputs_ZF),
        .outs_ST_OP                        (exe_outputs_ST_OP),
        .outs_ST_XCL                       (exe_outputs_ST_XCL),
        .outs_ST_PADDR_0                   (exe_outputs_ST_PADDR_0),
        .outs_ST_PADDR_1                   (exe_outputs_ST_PADDR_1),
        .outs_wb_stage_latch_we            (exe_outputs_wb_stage_latch_we)
    );

    WB_Latches wb_latches_unit (
        .clk(clk),
        .rst(rst),
        .write_enable_i(exe_outputs_wb_stage_latch_we),

        // ---- nextLatches inputs ----
        .nextLatches_valid_i        (wb_latches_next_valid),
        .nextLatches_cs_ST_OP_i     (wb_latches_next_cs_ST_OP),
        .nextLatches_cs_WB_DR_i     (wb_latches_next_cs_WB_DR),
        .nextLatches_cs_WB_SR_i     (wb_latches_next_cs_WB_SR),
        .nextLatches_cs_WB_EAX_i    (wb_latches_next_cs_WB_EAX),
        .nextLatches_ST_XCL_i       (wb_latches_next_ST_XCL),
        .nextLatches_ST_PADDR_0_i   (wb_latches_next_ST_PADDR_0),
        .nextLatches_ST_BIT_VEC_0_i (wb_latches_next_ST_BIT_VEC_0),
        .nextLatches_ST_PADDR_1_i   (wb_latches_next_ST_PADDR_1),
        .nextLatches_ST_BIT_VEC_1_i (wb_latches_next_ST_BIT_VEC_1),
        .nextLatches_MIO_i          (wb_latches_next_MIO),
        .nextLatches_EIP_i          (wb_latches_next_EIP),
        .nextLatches_res_buf_i      (exe_wb_latches_next_res_buf_w),
        .nextLatches_sr_id_i        (wb_latches_next_sr_id),
        .nextLatches_sr_data_i      (wb_latches_next_sr_data),
        .nextLatches_dr_id_i        (wb_latches_next_dr_id),
        .nextLatches_dr_data_i      (wb_latches_next_dr_data),
        .nextLatches_EAX_i          (wb_latches_next_EAX),

        // ---- latches outputs ----
        .latches_valid_o            (wb_latches_valid),
        .latches_cs_ST_OP_o         (wb_latches_cs_ST_OP),
        .latches_cs_WB_DR_o         (wb_latches_cs_WB_DR),
        .latches_cs_WB_SR_o         (wb_latches_cs_WB_SR),
        .latches_cs_WB_EAX_o        (wb_latches_cs_WB_EAX),
        .latches_ST_XCL_o           (wb_latches_ST_XCL),
        .latches_ST_PADDR_0_o       (wb_latches_ST_PADDR_0),
        .latches_ST_BIT_VEC_0_o     (wb_latches_ST_BIT_VEC_0),
        .latches_ST_PADDR_1_o       (wb_latches_ST_PADDR_1),
        .latches_ST_BIT_VEC_1_o     (wb_latches_ST_BIT_VEC_1),
        .latches_MIO_o              (wb_latches_MIO),
        .latches_EIP_o              (wb_latches_EIP),
        .latches_res_buf_o          (wb_latches_res_buf_w),
        .latches_sr_id_o            (wb_latches_sr_id),
        .latches_sr_data_o          (wb_latches_sr_data),
        .latches_dr_id_o            (wb_latches_dr_id),
        .latches_dr_data_o          (wb_latches_dr_data),
        .latches_EAX_o              (wb_latches_EAX)
    );

    WB write_back_unit (
        .clk(clk),
        .rst(rst),

        .wb_latches_valid                  (wb_latches_valid),
        .wb_latches_cs_ST_OP               (wb_latches_cs_ST_OP),
        .wb_latches_cs_WB_DR               (wb_latches_cs_WB_DR),
        .wb_latches_cs_WB_SR               (wb_latches_cs_WB_SR),
        .wb_latches_cs_WB_EAX              (wb_latches_cs_WB_EAX),
        .wb_latches_ST_XCL                 (wb_latches_ST_XCL),
        .wb_latches_ST_PADDR_0             (wb_latches_ST_PADDR_0),
        .wb_latches_ST_BIT_VEC_0           (wb_latches_ST_BIT_VEC_0),
        .wb_latches_ST_PADDR_1             (wb_latches_ST_PADDR_1),
        .wb_latches_ST_BIT_VEC_1           (wb_latches_ST_BIT_VEC_1),
        .wb_latches_MIO                    (wb_latches_MIO),
        .wb_latches_EIP                    (wb_latches_EIP),
        .wb_latches_res_buf                (wb_latches_res_buf_w),
        .wb_latches_sr_id                  (wb_latches_sr_id),
        .wb_latches_sr_data                (wb_latches_sr_data),
        .wb_latches_dr_id                  (wb_latches_dr_id),
        .wb_latches_dr_data                (wb_latches_dr_data),
        .wb_latches_EAX                    (wb_latches_EAX),

        .write_success_0                   (DCacheIn_writeSuccess_0),
        .write_success_1                   (DCacheIn_writeSuccess_1),
        .write_success_2                   (DCacheIn_writeSuccess_2),
        .write_success_3                   (DCacheIn_writeSuccess_3),
        .write_success_mio                 (DCacheIn_writeSuccess_MIO),

        .outputs_valid                     (wb_outputs_valid),
        .outputs_wb_stall                  (wb_outputs_wb_stall),
        .outputs_ST_OP                     (wb_outputs_ST_OP),
        .outputs_ST_XCL                    (wb_outputs_ST_XCL),
        .outputs_ST_PADDR_0                (wb_outputs_ST_PADDR_0),
        .outputs_ST_PADDR_1                (wb_outputs_ST_PADDR_1),

        .outputs_stq_head_0_full           (wb_outputs_stq_heads_0_full),
        .outputs_stq_head_0_empty          (wb_outputs_stq_heads_0_empty),
        .outputs_stq_head_0_address        (wb_outputs_stq_heads_0_address),
        .outputs_stq_head_0_bit_vec        (wb_outputs_stq_heads_0_bit_vec),
        .outputs_stq_head_0_data           (wb_stq_head_0_data_w),
        .outputs_stq_head_1_full           (wb_outputs_stq_heads_1_full),
        .outputs_stq_head_1_empty          (wb_outputs_stq_heads_1_empty),
        .outputs_stq_head_1_address        (wb_outputs_stq_heads_1_address),
        .outputs_stq_head_1_bit_vec        (wb_outputs_stq_heads_1_bit_vec),
        .outputs_stq_head_1_data           (wb_stq_head_1_data_w),
        .outputs_stq_head_2_full           (wb_outputs_stq_heads_2_full),
        .outputs_stq_head_2_empty          (wb_outputs_stq_heads_2_empty),
        .outputs_stq_head_2_address        (wb_outputs_stq_heads_2_address),
        .outputs_stq_head_2_bit_vec        (wb_outputs_stq_heads_2_bit_vec),
        .outputs_stq_head_2_data           (wb_stq_head_2_data_w),
        .outputs_stq_head_3_full           (wb_outputs_stq_heads_3_full),
        .outputs_stq_head_3_empty          (wb_outputs_stq_heads_3_empty),
        .outputs_stq_head_3_address        (wb_outputs_stq_heads_3_address),
        .outputs_stq_head_3_bit_vec        (wb_outputs_stq_heads_3_bit_vec),
        .outputs_stq_head_3_data           (wb_stq_head_3_data_w),

        .outputs_mio_head_full             (wb_outputs_mio_head_full),
        .outputs_mio_head_empty            (wb_outputs_mio_head_empty),
        .outputs_mio_head_address          (wb_outputs_mio_head_address),
        .outputs_mio_head_bit_vec          (wb_outputs_mio_head_bit_vec),
        .outputs_mio_head_data             (wb_mio_head_data_w),

        .outputs_dep_check_entry_0_valid   (wb_outputs_dep_check_entries_0_valid),
        .outputs_dep_check_entry_0_address (wb_outputs_dep_check_entries_0_address),
        .outputs_dep_check_entry_1_valid   (wb_outputs_dep_check_entries_1_valid),
        .outputs_dep_check_entry_1_address (wb_outputs_dep_check_entries_1_address),
        .outputs_dep_check_entry_2_valid   (wb_outputs_dep_check_entries_2_valid),
        .outputs_dep_check_entry_2_address (wb_outputs_dep_check_entries_2_address),
        .outputs_dep_check_entry_3_valid   (wb_outputs_dep_check_entries_3_valid),
        .outputs_dep_check_entry_3_address (wb_outputs_dep_check_entries_3_address),
        .outputs_dep_check_entry_4_valid   (wb_outputs_dep_check_entries_4_valid),
        .outputs_dep_check_entry_4_address (wb_outputs_dep_check_entries_4_address),
        .outputs_dep_check_entry_5_valid   (wb_outputs_dep_check_entries_5_valid),
        .outputs_dep_check_entry_5_address (wb_outputs_dep_check_entries_5_address),
        .outputs_dep_check_entry_6_valid   (wb_outputs_dep_check_entries_6_valid),
        .outputs_dep_check_entry_6_address (wb_outputs_dep_check_entries_6_address),
        .outputs_dep_check_entry_7_valid   (wb_outputs_dep_check_entries_7_valid),
        .outputs_dep_check_entry_7_address (wb_outputs_dep_check_entries_7_address),
        .outputs_dep_check_entry_8_valid   (wb_outputs_dep_check_entries_8_valid),
        .outputs_dep_check_entry_8_address (wb_outputs_dep_check_entries_8_address),
        .outputs_dep_check_entry_9_valid   (wb_outputs_dep_check_entries_9_valid),
        .outputs_dep_check_entry_9_address (wb_outputs_dep_check_entries_9_address),
        .outputs_dep_check_entry_10_valid  (wb_outputs_dep_check_entries_10_valid),
        .outputs_dep_check_entry_10_address(wb_outputs_dep_check_entries_10_address),
        .outputs_dep_check_entry_11_valid  (wb_outputs_dep_check_entries_11_valid),
        .outputs_dep_check_entry_11_address(wb_outputs_dep_check_entries_11_address),
        .outputs_dep_check_entry_12_valid  (wb_outputs_dep_check_entries_12_valid),
        .outputs_dep_check_entry_12_address(wb_outputs_dep_check_entries_12_address),
        .outputs_dep_check_entry_13_valid  (wb_outputs_dep_check_entries_13_valid),
        .outputs_dep_check_entry_13_address(wb_outputs_dep_check_entries_13_address),
        .outputs_dep_check_entry_14_valid  (wb_outputs_dep_check_entries_14_valid),
        .outputs_dep_check_entry_14_address(wb_outputs_dep_check_entries_14_address),
        .outputs_dep_check_entry_15_valid  (wb_outputs_dep_check_entries_15_valid),
        .outputs_dep_check_entry_15_address(wb_outputs_dep_check_entries_15_address)
    );

endmodule
