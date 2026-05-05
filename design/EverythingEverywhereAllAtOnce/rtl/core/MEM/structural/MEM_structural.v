// MEM_structural.v
//
// Pure Verilog-2005 top of the MEM stage. Same internal structure as
// MEM_structural.sv (kept on disk as the SV reference) but with all
// SV-only constructs removed:
//   * No `import` of any package.
//   * No struct or typedef ports -- mem_latches_t (input), exe_outputs_t
//     (only the two consumed fields), wb_outputs_t (only wb_stall),
//     exe_latches_t (output), mem_outputs_t (output) are unrolled into
//     individual flat wires whose widths match the field types.
//   * No unpacked-array ports -- cacheline byte arrays are passed as
//     packed 128-bit buses, ld_buf as a 256-bit bus,
//     clr_dcache_arb_latches as 4 named bits.
//   * `bool`/`logic`/`uint*_t` -> `wire [W-1:0]`.
//
// Hardcoded width constants (all from rtl/pkgs/common_pkg.sv):
//   CACHE_LINES_SIZE_B = 16    (byte_t[16] per cacheline)
//   EXE_BUFFER_SIZE    = 32    (byte_t[32] for ld_buf)
//   NUM_DCACHE_PORTS   = 4
//   p_address_t        = 15 bits ($clog2(PHY_MEM_SIZE=32768))
//
// Body is identical in shape to MEM_structural.sv; the only deletions are
// the per-byte cacheline pack and per-byte ld_buf unpack generates -- both
// arrays are now passed as packed buses on the port boundary.


module MEM (
    input  wire        clk,
    input  wire        rst,

    // ====================================================================
    // mem_latches_t (latches_i)
    // ====================================================================
    input  wire        latches_valid,

    // mem_cs_t (latches_i.cs)
    input  wire        latches_cs_ST_OP,
    input  wire        latches_cs_LD_OP,

    // exe_cs_t (latches_i.exe_cs) -- propagated to exe_latches_next_o.cs
    input  wire        latches_exe_cs_ST_OP,
    input  wire [5:0]  latches_exe_cs_OP_TYPE,
    input  wire [4:0]  latches_exe_cs_alu_inputA_sel,
    input  wire [4:0]  latches_exe_cs_alu_inputB_sel,
    input  wire [4:0]  latches_exe_cs_branch_target_sel,
    input  wire        latches_exe_cs_shift_by_one,
    input  wire        latches_exe_cs_br_ucond,
    input  wire        latches_exe_cs_relative_branch,
    input  wire        latches_exe_cs_special_br,
    input  wire        latches_exe_cs_is_far,
    input  wire        latches_exe_cs_is_call,
    input  wire        latches_exe_cs_second_flag_needed,
    input  wire        latches_exe_cs_rep_no_zf_update,

    // wb_cs_t (latches_i.wb_cs)
    input  wire        latches_wb_cs_ST_OP,
    input  wire        latches_wb_cs_WB_DR,
    input  wire        latches_wb_cs_WB_SR,
    input  wire        latches_wb_cs_WB_EAX,

    // br_info_t (latches_i.br_info)
    input  wire        latches_br_info_valid,
    input  wire [31:0] latches_br_info_br_eip,
    input  wire        latches_br_info_br_xcl,
    input  wire        latches_br_info_br_pred_taken,
    input  wire [31:0] latches_br_info_speculative_target,

    // remaining mem_latches_t scalars
    input  wire [3:0]  latches_data_size_vec,
    input  wire [3:0]  latches_sr_data_size_vec,
    input  wire        latches_shift_sr_up,
    input  wire        latches_shift_sr_down,
    input  wire        latches_ST_XCL,
    input  wire [14:0] latches_ST_PADDR_0,
    input  wire [14:0] latches_ST_PADDR_1,
    input  wire        latches_MIO,
    input  wire [31:0] latches_NEIP,
    input  wire [31:0] latches_EIP,
    input  wire [31:0] latches_EAX,
    input  wire [63:0] latches_imm64,
    input  wire [4:0]  latches_sr_id,
    input  wire [63:0] latches_sr_data,
    input  wire [4:0]  latches_dr_id,
    input  wire [63:0] latches_dr_data,
    input  wire        latches_LD_XCL,
    input  wire        latches_swapLines,
    input  wire [14:0] latches_LD_PADDR_0,
    input  wire [14:0] latches_LD_PADDR_1,

    // ====================================================================
    // exe_outputs_t (exe_outs_i) -- only the two consumed fields
    // ====================================================================
    input  wire        exe_outs_valid,
    input  wire        exe_outs_br_res_flush,

    // ====================================================================
    // wb_outputs_t (wb_outs_i) -- only wb_stall consumed
    // ====================================================================
    input  wire        wb_outs_wb_stall,

    // ====================================================================
    // From dcache: hit[4], cacheline[4][16], hit_MIO, line_MIO[16]
    // ====================================================================
    input  wire        hit_0,
    input  wire        hit_1,
    input  wire        hit_2,
    input  wire        hit_3,
    input  wire [127:0] cacheline_0,
    input  wire [127:0] cacheline_1,
    input  wire [127:0] cacheline_2,
    input  wire [127:0] cacheline_3,
    input  wire        hit_MIO,
    input  wire [127:0] line_MIO,

    // ====================================================================
    // exe_latches_t (exe_latches_next_o)
    // ====================================================================
    output wire        exe_latches_next_valid,

    // exe_cs_t (cs)
    output wire        exe_latches_next_cs_ST_OP,
    output wire [5:0]  exe_latches_next_cs_OP_TYPE,
    output wire [4:0]  exe_latches_next_cs_alu_inputA_sel,
    output wire [4:0]  exe_latches_next_cs_alu_inputB_sel,
    output wire [4:0]  exe_latches_next_cs_branch_target_sel,
    output wire        exe_latches_next_cs_shift_by_one,
    output wire        exe_latches_next_cs_br_ucond,
    output wire        exe_latches_next_cs_relative_branch,
    output wire        exe_latches_next_cs_special_br,
    output wire        exe_latches_next_cs_is_far,
    output wire        exe_latches_next_cs_is_call,
    output wire        exe_latches_next_cs_second_flag_needed,
    output wire        exe_latches_next_cs_rep_no_zf_update,

    // wb_cs_t (wb_cs)
    output wire        exe_latches_next_wb_cs_ST_OP,
    output wire        exe_latches_next_wb_cs_WB_DR,
    output wire        exe_latches_next_wb_cs_WB_SR,
    output wire        exe_latches_next_wb_cs_WB_EAX,

    output wire [3:0]  exe_latches_next_data_size_vec,
    output wire [3:0]  exe_latches_next_sr_data_size_vec,
    output wire        exe_latches_next_shift_sr_up,
    output wire        exe_latches_next_shift_sr_down,
    output wire        exe_latches_next_ST_XCL,
    output wire [14:0] exe_latches_next_ST_PADDR_0,
    output wire [14:0] exe_latches_next_ST_PADDR_1,
    output wire        exe_latches_next_MIO,

    // br_info_t (br_info)
    output wire        exe_latches_next_br_info_valid,
    output wire [31:0] exe_latches_next_br_info_br_eip,
    output wire        exe_latches_next_br_info_br_xcl,
    output wire        exe_latches_next_br_info_br_pred_taken,
    output wire [31:0] exe_latches_next_br_info_speculative_target,

    output wire [31:0] exe_latches_next_br_rel_target,
    output wire [31:0] exe_latches_next_NEIP,
    output wire [31:0] exe_latches_next_EIP,
    output wire [31:0] exe_latches_next_EAX,
    output wire [63:0] exe_latches_next_imm64,
    output wire [255:0] exe_latches_next_ld_buf,
    output wire [4:0]  exe_latches_next_sr_id,
    output wire [63:0] exe_latches_next_sr_data,
    output wire [4:0]  exe_latches_next_dr_id,
    output wire [63:0] exe_latches_next_dr_data,
    output wire [14:0] exe_latches_next_ld_addy,

    // ====================================================================
    // mem_outputs_t (outs_o)
    // ====================================================================
    output wire        outs_valid,
    output wire        outs_stall,
    output wire        outs_ST_XCL,
    output wire [14:0] outs_ST_PADDR_0,
    output wire [14:0] outs_ST_PADDR_1,
    output wire        outs_ST_OP,
    output wire        outs_clr_dcache_arb_latches_0,
    output wire        outs_clr_dcache_arb_latches_1,
    output wire        outs_clr_dcache_arb_latches_2,
    output wire        outs_clr_dcache_arb_latches_3,
    output wire        outs_clr_dcache_mio_latch,
    output wire        outs_exe_stage_latch_we
);

    // -------------------------------------------------------------------------
    // Local widths
    // -------------------------------------------------------------------------
    localparam CL_BITS = 128;       // CACHE_LINES_SIZE_B*8
    localparam LD_BITS = 256;       // EXE_BUFFER_SIZE*8
    localparam BTS_W   = 5;         // source_selector_e width on the port

    // =========================================================================
    // Convenient local wire aliases (renaming only)
    // =========================================================================
    wire             valid_w;
    wire             LD_OP_w;
    wire             ST_OP_w;
    wire             LD_XCL_w;
    wire             MIO_w;
    wire             ST_XCL_w;
    wire [BTS_W-1:0] bts_w;
    wire [63:0]      imm64_w;
    wire [31:0]      NEIP_w;
    wire [1:0]       bank_num_0;
    wire [1:0]       bank_num_1;
    wire             flush_w;

    assign valid_w    = latches_valid;
    assign LD_OP_w    = latches_cs_LD_OP;
    assign ST_OP_w    = latches_cs_ST_OP;
    assign LD_XCL_w   = latches_LD_XCL;
    assign MIO_w      = latches_MIO;
    assign ST_XCL_w   = latches_ST_XCL;
    assign bts_w      = latches_exe_cs_branch_target_sel;
    assign imm64_w    = latches_imm64;
    assign NEIP_w     = latches_NEIP;
    // bank_num = LD_PADDR[$clog2(CACHE_LINES_SIZE_B) +: 2] = LD_PADDR[5:4]
    assign bank_num_0 = latches_LD_PADDR_0[5:4];
    assign bank_num_1 = latches_LD_PADDR_1[5:4];
    assign flush_w    = exe_outs_br_res_flush;

    // =========================================================================
    // BRANCH TARGET GENERATOR
    // =========================================================================
    wire [31:0] sext_imm8;
    wire [31:0] sext_imm16;
    wire [31:0] imm32_val;

    assign sext_imm8  = {{24{imm64_w[7]}},  imm64_w[7:0]};
    assign sext_imm16 = {{16{imm64_w[15]}}, imm64_w[15:0]};
    assign imm32_val  = imm64_w[31:0];

    wire eq_zext8;
    wire eq_zext16;
    wire eq_imm32;

    `CMP_N(cmp_bts_zext8,  BTS_W, eq_zext8,  bts_w, `EXE_SRC_ZEXT_IMM8)
    `CMP_N(cmp_bts_zext16, BTS_W, eq_zext16, bts_w, `EXE_SRC_ZEXT_IMM16)
    `CMP_N(cmp_bts_imm32,  BTS_W, eq_imm32,  bts_w, `EXE_SRC_IMM32)

    wire bts_sel_lo;
    wire bts_sel_hi;
    wire [1:0] bts_sel;

    `OR_2(or_bts_sel_lo, 1, bts_sel_lo, eq_zext8,  eq_imm32)
    `OR_2(or_bts_sel_hi, 1, bts_sel_hi, eq_zext16, eq_imm32)
    assign bts_sel = {bts_sel_hi, bts_sel_lo};

    wire [31:0] rel_offset;
    `MUX_4(mux_rel_offset, 32, rel_offset,
           32'd0, sext_imm8, sext_imm16, imm32_val,
           bts_sel)

    wire [31:0] br_rel_target;
    wire        br_rel_cout;
    `ADD_N(add_br_rel, 32, br_rel_target, br_rel_cout, rel_offset, NEIP_w, 1'b0)

    // =========================================================================
    // EXE_valid_logic
    // =========================================================================
    wire exe_we_o_w;
    wire next_exe_v_o_w;
    wire miss_stall_w;

    EXE_valid_logic exe_valid_logic_unit (
        .EXE_we_o   (exe_we_o_w),
        .N_EXE_V_o  (next_exe_v_o_w),
        .MEM_V_i    (valid_w),
        .MEM_stall_i(miss_stall_w),
        .EXE_V_i    (exe_outs_valid),
        .WB_stall_i (wb_outs_wb_stall)
    );

    wire forward_valid_w;
    `AND_2(and_forward_valid, 1, forward_valid_w, exe_we_o_w, next_exe_v_o_w)

    // =========================================================================
    // PER-PORT HIT-BUF STORAGE
    // =========================================================================
    wire forward_valid_inv;
    `INV_N(inv_fwdv, 1, forward_valid_w, forward_valid_inv)

    wire vcap_0, vcap_1, vcap_2, vcap_3, vcap_mio;
    `AND_2(and_vcap_0,   1, vcap_0,   hit_0,   valid_w)
    `AND_2(and_vcap_1,   1, vcap_1,   hit_1,   valid_w)
    `AND_2(and_vcap_2,   1, vcap_2,   hit_2,   valid_w)
    `AND_2(and_vcap_3,   1, vcap_3,   hit_3,   valid_w)
    `AND_2(and_vcap_mio, 1, vcap_mio, hit_MIO, valid_w)

    wire we_v_0, we_v_1, we_v_2, we_v_3, we_v_mio;
    `OR_2(or_wev_0,   1, we_v_0,   forward_valid_w, vcap_0)
    `OR_2(or_wev_1,   1, we_v_1,   forward_valid_w, vcap_1)
    `OR_2(or_wev_2,   1, we_v_2,   forward_valid_w, vcap_2)
    `OR_2(or_wev_3,   1, we_v_3,   forward_valid_w, vcap_3)
    `OR_2(or_wev_mio, 1, we_v_mio, forward_valid_w, vcap_mio)

    wire we_d_0, we_d_1, we_d_2, we_d_3, we_d_mio;
    `AND_2(and_wed_0,   1, we_d_0,   vcap_0,   forward_valid_inv)
    `AND_2(and_wed_1,   1, we_d_1,   vcap_1,   forward_valid_inv)
    `AND_2(and_wed_2,   1, we_d_2,   vcap_2,   forward_valid_inv)
    `AND_2(and_wed_3,   1, we_d_3,   vcap_3,   forward_valid_inv)
    `AND_2(and_wed_mio, 1, we_d_mio, vcap_mio, forward_valid_inv)

    wire hit_buf_v_0, hit_buf_v_1, hit_buf_v_2, hit_buf_v_3, hit_buf_mio_v;
    `REG_RST_WE(reg_hbv_0,   1, clk, rst, we_v_0,   forward_valid_inv, hit_buf_v_0)
    `REG_RST_WE(reg_hbv_1,   1, clk, rst, we_v_1,   forward_valid_inv, hit_buf_v_1)
    `REG_RST_WE(reg_hbv_2,   1, clk, rst, we_v_2,   forward_valid_inv, hit_buf_v_2)
    `REG_RST_WE(reg_hbv_3,   1, clk, rst, we_v_3,   forward_valid_inv, hit_buf_v_3)
    `REG_RST_WE(reg_hbv_mio, 1, clk, rst, we_v_mio, forward_valid_inv, hit_buf_mio_v)

    wire [CL_BITS-1:0] hit_buf_0_packed;
    wire [CL_BITS-1:0] hit_buf_1_packed;
    wire [CL_BITS-1:0] hit_buf_2_packed;
    wire [CL_BITS-1:0] hit_buf_3_packed;
    wire [CL_BITS-1:0] hit_buf_mio_packed;

    `REG_RST_WE(reg_hb_0,   CL_BITS, clk, rst, we_d_0,   cacheline_0, hit_buf_0_packed)
    `REG_RST_WE(reg_hb_1,   CL_BITS, clk, rst, we_d_1,   cacheline_1, hit_buf_1_packed)
    `REG_RST_WE(reg_hb_2,   CL_BITS, clk, rst, we_d_2,   cacheline_2, hit_buf_2_packed)
    `REG_RST_WE(reg_hb_3,   CL_BITS, clk, rst, we_d_3,   cacheline_3, hit_buf_3_packed)
    `REG_RST_WE(reg_hb_mio, CL_BITS, clk, rst, we_d_mio, line_MIO,    hit_buf_mio_packed)

    // =========================================================================
    // MISS-STALL
    // =========================================================================
    mem_miss_stall_logic mem_stall (
        .valid         (valid_w),
        .LD_XCL        (LD_XCL_w),
        .LD_OP         (LD_OP_w),
        .MIO           (MIO_w),
        .hit_0         (hit_0),
        .hit_1         (hit_1),
        .hit_2         (hit_2),
        .hit_3         (hit_3),
        .hit_MIO       (hit_MIO),
        .hit_buf_v_0   (hit_buf_v_0),
        .hit_buf_v_1   (hit_buf_v_1),
        .hit_buf_v_2   (hit_buf_v_2),
        .hit_buf_v_3   (hit_buf_v_3),
        .hit_buf_mio_v (hit_buf_mio_v),
        .bank_num_0    (bank_num_0),
        .bank_num_1    (bank_num_1),
        .miss_stall    (miss_stall_w)
    );

    // =========================================================================
    // LINE SELECT MUXES
    // =========================================================================
    wire [CL_BITS-1:0] hit_buf_sel0;
    wire [CL_BITS-1:0] cacheline_sel0;
    wire               hit_buf_v_sel0;
    wire [CL_BITS-1:0] line_in_0;

    `MUX_4(mux_hb_sel0, CL_BITS, hit_buf_sel0,
           hit_buf_0_packed, hit_buf_1_packed, hit_buf_2_packed, hit_buf_3_packed,
           bank_num_0)

    `MUX_4(mux_cl_sel0, CL_BITS, cacheline_sel0,
           cacheline_0, cacheline_1, cacheline_2, cacheline_3,
           bank_num_0)

    `MUX_4(mux_hbv_sel0, 1, hit_buf_v_sel0,
           hit_buf_v_0, hit_buf_v_1, hit_buf_v_2, hit_buf_v_3,
           bank_num_0)

    `MUX_2(mux_line_in_0, CL_BITS, line_in_0,
           cacheline_sel0, hit_buf_sel0, hit_buf_v_sel0)

    wire [CL_BITS-1:0] hit_buf_sel1;
    wire [CL_BITS-1:0] cacheline_sel1;
    wire               hit_buf_v_sel1;
    wire [CL_BITS-1:0] line_in_1;

    `MUX_4(mux_hb_sel1, CL_BITS, hit_buf_sel1,
           hit_buf_0_packed, hit_buf_1_packed, hit_buf_2_packed, hit_buf_3_packed,
           bank_num_1)

    `MUX_4(mux_cl_sel1, CL_BITS, cacheline_sel1,
           cacheline_0, cacheline_1, cacheline_2, cacheline_3,
           bank_num_1)

    `MUX_4(mux_hbv_sel1, 1, hit_buf_v_sel1,
           hit_buf_v_0, hit_buf_v_1, hit_buf_v_2, hit_buf_v_3,
           bank_num_1)

    `MUX_2(mux_line_in_1, CL_BITS, line_in_1,
           cacheline_sel1, hit_buf_sel1, hit_buf_v_sel1)

    wire [CL_BITS-1:0] line_in_mio;
    `MUX_2(mux_line_in_mio, CL_BITS, line_in_mio,
           line_MIO, hit_buf_mio_packed, hit_buf_mio_v)

    // =========================================================================
    // MASKING + CL ASSEMBLY
    // =========================================================================
    wire [CL_BITS-1:0] line_in_0_masked;
    wire [CL_BITS-1:0] line_in_1_masked;
    wire [CL_BITS-1:0] C0_w;

    `MUX_2(mux_l0_mask, CL_BITS, line_in_0_masked, {CL_BITS{1'b0}}, line_in_0, LD_OP_w)
    `MUX_2(mux_l1_mask, CL_BITS, line_in_1_masked, {CL_BITS{1'b0}}, line_in_1, LD_XCL_w)
    `MUX_2(mux_C0,      CL_BITS, C0_w,             line_in_0_masked, line_in_mio, MIO_w)

    wire [LD_BITS-1:0] ld_buf_unmasked;
    assign ld_buf_unmasked = {line_in_1_masked, C0_w};

    wire [LD_BITS-1:0] ld_buf_packed;
    `MUX_2(mux_ldbuf, LD_BITS, ld_buf_packed,
           {LD_BITS{1'b0}}, ld_buf_unmasked, forward_valid_w)

    // ld_buf goes straight out as a packed bus (no per-byte unpack needed).
    assign exe_latches_next_ld_buf = ld_buf_packed;

    // =========================================================================
    // CLR_DCACHE_ARB_LATCHES + CLR_DCACHE_MIO_LATCH
    // =========================================================================
    wire MIO_n_w;
    `INV_N(inv_MIO_w, 1, MIO_w, MIO_n_w)

    wire bnk0_eq_0, bnk0_eq_1, bnk0_eq_2, bnk0_eq_3;
    wire bnk1_eq_0, bnk1_eq_1, bnk1_eq_2, bnk1_eq_3;
    `CMP_N(cmp_bnk0_0_clr, 2, bnk0_eq_0, bank_num_0, 2'd0)
    `CMP_N(cmp_bnk0_1_clr, 2, bnk0_eq_1, bank_num_0, 2'd1)
    `CMP_N(cmp_bnk0_2_clr, 2, bnk0_eq_2, bank_num_0, 2'd2)
    `CMP_N(cmp_bnk0_3_clr, 2, bnk0_eq_3, bank_num_0, 2'd3)
    `CMP_N(cmp_bnk1_0_clr, 2, bnk1_eq_0, bank_num_1, 2'd0)
    `CMP_N(cmp_bnk1_1_clr, 2, bnk1_eq_1, bank_num_1, 2'd1)
    `CMP_N(cmp_bnk1_2_clr, 2, bnk1_eq_2, bank_num_1, 2'd2)
    `CMP_N(cmp_bnk1_3_clr, 2, bnk1_eq_3, bank_num_1, 2'd3)

    wire hit_buf_v_0_n, hit_buf_v_1_n, hit_buf_v_2_n, hit_buf_v_3_n;
    `INV_N(inv_hbv_0, 1, hit_buf_v_0, hit_buf_v_0_n)
    `INV_N(inv_hbv_1, 1, hit_buf_v_1, hit_buf_v_1_n)
    `INV_N(inv_hbv_2, 1, hit_buf_v_2, hit_buf_v_2_n)
    `INV_N(inv_hbv_3, 1, hit_buf_v_3, hit_buf_v_3_n)

    wire hit_no_buf_0, hit_no_buf_1, hit_no_buf_2, hit_no_buf_3;
    `AND_2(and_hnb_0, 1, hit_no_buf_0, hit_0, hit_buf_v_0_n)
    `AND_2(and_hnb_1, 1, hit_no_buf_1, hit_1, hit_buf_v_1_n)
    `AND_2(and_hnb_2, 1, hit_no_buf_2, hit_2, hit_buf_v_2_n)
    `AND_2(and_hnb_3, 1, hit_no_buf_3, hit_3, hit_buf_v_3_n)

    wire cond0_0, cond0_1, cond0_2, cond0_3;
    `AND_5(and_c0_0, 1, cond0_0, bnk0_eq_0, LD_OP_w, hit_no_buf_0, valid_w, MIO_n_w)
    `AND_5(and_c0_1, 1, cond0_1, bnk0_eq_1, LD_OP_w, hit_no_buf_1, valid_w, MIO_n_w)
    `AND_5(and_c0_2, 1, cond0_2, bnk0_eq_2, LD_OP_w, hit_no_buf_2, valid_w, MIO_n_w)
    `AND_5(and_c0_3, 1, cond0_3, bnk0_eq_3, LD_OP_w, hit_no_buf_3, valid_w, MIO_n_w)

    wire cond1_0, cond1_1, cond1_2, cond1_3;
    `AND_6(and_c1_0, 1, cond1_0, bnk1_eq_0, LD_OP_w, LD_XCL_w, hit_no_buf_0, valid_w, MIO_n_w)
    `AND_6(and_c1_1, 1, cond1_1, bnk1_eq_1, LD_OP_w, LD_XCL_w, hit_no_buf_1, valid_w, MIO_n_w)
    `AND_6(and_c1_2, 1, cond1_2, bnk1_eq_2, LD_OP_w, LD_XCL_w, hit_no_buf_2, valid_w, MIO_n_w)
    `AND_6(and_c1_3, 1, cond1_3, bnk1_eq_3, LD_OP_w, LD_XCL_w, hit_no_buf_3, valid_w, MIO_n_w)

    wire clr_arb_0, clr_arb_1, clr_arb_2, clr_arb_3;
    `OR_3(or_clrarb_0, 1, clr_arb_0, cond0_0, cond1_0, flush_w)
    `OR_3(or_clrarb_1, 1, clr_arb_1, cond0_1, cond1_1, flush_w)
    `OR_3(or_clrarb_2, 1, clr_arb_2, cond0_2, cond1_2, flush_w)
    `OR_3(or_clrarb_3, 1, clr_arb_3, cond0_3, cond1_3, flush_w)

    assign outs_clr_dcache_arb_latches_0 = clr_arb_0;
    assign outs_clr_dcache_arb_latches_1 = clr_arb_1;
    assign outs_clr_dcache_arb_latches_2 = clr_arb_2;
    assign outs_clr_dcache_arb_latches_3 = clr_arb_3;

    wire hit_buf_mio_v_n;
    wire hit_MIO_no_buf;
    wire hit_MIO_or_flush;
    wire clr_dcache_mio_latch_w;

    `INV_N(inv_hbmiov,    1, hit_buf_mio_v,   hit_buf_mio_v_n)
    `AND_2(and_hMIOnb,    1, hit_MIO_no_buf,  hit_MIO, hit_buf_mio_v_n)
    `OR_2 (or_hMIOoflush, 1, hit_MIO_or_flush, hit_MIO_no_buf, flush_w)
    `AND_4(and_clrmio,    1, clr_dcache_mio_latch_w,
           MIO_w, LD_OP_w, hit_MIO_or_flush, valid_w)

    assign outs_clr_dcache_mio_latch = clr_dcache_mio_latch_w;

    // =========================================================================
    // OUTPUT ASSIGNMENTS (per-field)
    // =========================================================================
    // exe_latches_next_o
    assign exe_latches_next_valid                       = next_exe_v_o_w;
    // cs (exe_cs propagated from latches.exe_cs)
    assign exe_latches_next_cs_ST_OP                    = latches_exe_cs_ST_OP;
    assign exe_latches_next_cs_OP_TYPE                  = latches_exe_cs_OP_TYPE;
    assign exe_latches_next_cs_alu_inputA_sel           = latches_exe_cs_alu_inputA_sel;
    assign exe_latches_next_cs_alu_inputB_sel           = latches_exe_cs_alu_inputB_sel;
    assign exe_latches_next_cs_branch_target_sel        = latches_exe_cs_branch_target_sel;
    assign exe_latches_next_cs_shift_by_one             = latches_exe_cs_shift_by_one;
    assign exe_latches_next_cs_br_ucond                 = latches_exe_cs_br_ucond;
    assign exe_latches_next_cs_relative_branch          = latches_exe_cs_relative_branch;
    assign exe_latches_next_cs_special_br               = latches_exe_cs_special_br;
    assign exe_latches_next_cs_is_far                   = latches_exe_cs_is_far;
    assign exe_latches_next_cs_is_call                  = latches_exe_cs_is_call;
    assign exe_latches_next_cs_second_flag_needed       = latches_exe_cs_second_flag_needed;
    assign exe_latches_next_cs_rep_no_zf_update         = latches_exe_cs_rep_no_zf_update;
    // wb_cs
    assign exe_latches_next_wb_cs_ST_OP                 = latches_wb_cs_ST_OP;
    assign exe_latches_next_wb_cs_WB_DR                 = latches_wb_cs_WB_DR;
    assign exe_latches_next_wb_cs_WB_SR                 = latches_wb_cs_WB_SR;
    assign exe_latches_next_wb_cs_WB_EAX                = latches_wb_cs_WB_EAX;
    // remaining scalars
    assign exe_latches_next_data_size_vec               = latches_data_size_vec;
    assign exe_latches_next_sr_data_size_vec            = latches_sr_data_size_vec;
    assign exe_latches_next_shift_sr_up                 = latches_shift_sr_up;
    assign exe_latches_next_shift_sr_down               = latches_shift_sr_down;
    assign exe_latches_next_ST_XCL                      = latches_ST_XCL;
    assign exe_latches_next_ST_PADDR_0                  = latches_ST_PADDR_0;
    assign exe_latches_next_ST_PADDR_1                  = latches_ST_PADDR_1;
    assign exe_latches_next_MIO                         = latches_MIO;
    // br_info
    assign exe_latches_next_br_info_valid               = latches_br_info_valid;
    assign exe_latches_next_br_info_br_eip              = latches_br_info_br_eip;
    assign exe_latches_next_br_info_br_xcl              = latches_br_info_br_xcl;
    assign exe_latches_next_br_info_br_pred_taken       = latches_br_info_br_pred_taken;
    assign exe_latches_next_br_info_speculative_target  = latches_br_info_speculative_target;
    // computed / passed-through
    assign exe_latches_next_br_rel_target               = br_rel_target;
    assign exe_latches_next_NEIP                        = latches_NEIP;
    assign exe_latches_next_EIP                         = latches_EIP;
    assign exe_latches_next_EAX                         = latches_EAX;
    assign exe_latches_next_imm64                       = latches_imm64;
    // exe_latches_next_ld_buf is driven above (assign exe_latches_next_ld_buf = ld_buf_packed;)
    assign exe_latches_next_sr_id                       = latches_sr_id;
    assign exe_latches_next_sr_data                     = latches_sr_data;
    assign exe_latches_next_dr_id                       = latches_dr_id;
    assign exe_latches_next_dr_data                     = latches_dr_data;
    assign exe_latches_next_ld_addy                     = latches_LD_PADDR_0;

    // outs_o
    assign outs_valid              = valid_w;
    assign outs_stall              = miss_stall_w;
    assign outs_ST_XCL             = ST_XCL_w;
    assign outs_ST_PADDR_0         = latches_ST_PADDR_0;
    assign outs_ST_PADDR_1         = latches_ST_PADDR_1;
    assign outs_ST_OP              = ST_OP_w;
    assign outs_exe_stage_latch_we = exe_we_o_w;

endmodule
