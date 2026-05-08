// =============================================================================
// MEM  (pure Verilog-2005 structural port of MEM.sv)
//
//   - All SystemVerilog constructs (struct, typedef, enum, package import,
//     `bool`/`p_address_t`/`uint*_t`/`reg_ids_e`/`source_selector_e`) are
//     removed.  Each struct field is exposed as a separate flat scalar/
//     vector port whose name follows the original `struct.field` path with
//     `.` replaced by `_` (e.g. `latches_i.cs.LD_OP` -> `latches_cs_LD_OP`).
//   - 2-D cache-side byte arrays (cacheline[NUM_DCACHE_PORTS][16],
//     line_MIO[16]) are flattened to per-port 128-bit packed buses; the
//     ld_buf output is a 256-bit packed bus.
//   - Per-port bool array `clr_dcache_arb_latches[NUM_DCACHE_PORTS]` is
//     unrolled into 4 individual scalar outputs.
//
//   Type-to-width mapping used here:
//     bool                       -> 1 bit
//     p_address_t                -> 15 bits
//     v_address_t / l_address_t  -> 32 bits
//     uint32_t                   -> 32 bits
//     uint64_t                   -> 64 bits
//     reg_ids_e                  -> 5 bits
//     exe_cs_operation_type_e    -> 6 bits (matches EXE flat-port convention)
//     source_selector_e          -> 5 bits (matches EXE flat-port convention)
//     CACHE_LINES_SIZE_B         -> 16  (so per-line packed bus is 128 bits)
//     EXE_BUFFER_SIZE            -> 32  (so ld_buf packed bus is 256 bits)
//
//   Internal logic identical in shape to MEM_structural.sv:
//   gates use INV_N / AND_N / OR_N / MUX_N / CMP_N / ADD_N from
//   lib/STDCells/STDCell_Macros.vh, sequential storage uses REG_RST_WE.
// =============================================================================

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

    // exe_cs_t (latches_i.exe_cs) -- forwarded to exe_latches_next.cs;
    //   branch_target_sel additionally consumed by branch-target add.
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
    // exe_outputs_t (exe_outs_i) -- only valid + br_res_out.flush consumed
    // ====================================================================
    input  wire        exe_outs_valid,
    input  wire        exe_outs_br_res_flush,

    // ====================================================================
    // wb_outputs_t (wb_outs_i) -- only wb_stall consumed
    // ====================================================================
    input  wire        wb_outs_wb_stall,

    // ====================================================================
    // dcache-side inputs (per-port unroll)
    //   hit[NUM_DCACHE_PORTS]                -> hit_0..hit_3
    //   cacheline[NUM_DCACHE_PORTS][16]      -> cacheline_0..cacheline_3 (128 bits each)
    //   line_MIO[16]                         -> line_MIO (128 bits)
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

    // exe_cs_t (exe_latches_next_o.cs)  -- pass-through from latches_exe_cs_*
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

    // wb_cs_t (exe_latches_next_o.wb_cs)
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

    // br_info_t (exe_latches_next_o.br_info)
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

    // ld_buf : byte_t [EXE_BUFFER_SIZE=32]  -> 256-bit packed bus
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
    output wire        outs_exe_stage_latch_we,
    // active-low version of the same signal; consumed by EXE_Latches whose
    // port-input inverting-buffer tree absorbs the inversion (faster than
    // bufferH64$ at low per-driver fanout).
    output wire        outs_exe_stage_latch_we_n,

    // clr_dcache_arb_latches[NUM_DCACHE_PORTS]  -- per-port unroll
    output wire        outs_clr_dcache_arb_latches_0,
    output wire        outs_clr_dcache_arb_latches_1,
    output wire        outs_clr_dcache_arb_latches_2,
    output wire        outs_clr_dcache_arb_latches_3,

    output wire        outs_clr_dcache_mio_latch
);

    // -------------------------------------------------------------------------
    // Local widths (no `localparam int` -- pure Verilog-2005)
    // -------------------------------------------------------------------------
    localparam CL_BITS = 128;     // CACHE_LINES_SIZE_B * 8 = 16 * 8
    localparam LD_BITS = 256;     // EXE_BUFFER_SIZE     * 8 = 32 * 8
    localparam BTS_W   = 5;       // source_selector_e flat-port width

    // source_selector_e literal values used for the branch-target compares.
    //   IMM32      = 9
    //   ZEXT_IMM8  = 10
    //   ZEXT_IMM16 = 13
    localparam [BTS_W-1:0] SRC_SEL_IMM32      = 5'd9;
    localparam [BTS_W-1:0] SRC_SEL_ZEXT_IMM8  = 5'd10;
    localparam [BTS_W-1:0] SRC_SEL_ZEXT_IMM16 = 5'd13;

    // =========================================================================
    // Convenient local wires aliasing struct-field reads (wire renaming only)
    // =========================================================================
    wire             valid_w;
    wire             LD_OP_w;       // mem_cs.LD_OP
    wire             ST_OP_w;       // mem_cs.ST_OP
    wire             LD_XCL_w;
    wire             MIO_w;
    wire             ST_XCL_w;
    wire [BTS_W-1:0] bts_w;
    wire [63:0]      imm64_w;
    wire [31:0]      NEIP_w;
    wire [1:0]       bank_num_0;
    wire [1:0]       bank_num_1;
    wire             flush_w;       // exe_outs_i.br_res_out.flush

    assign valid_w    = latches_valid;
    assign LD_OP_w    = latches_cs_LD_OP;
    assign ST_OP_w    = latches_cs_ST_OP;
    assign LD_XCL_w   = latches_LD_XCL;
    assign MIO_w      = latches_MIO;
    assign ST_XCL_w   = latches_ST_XCL;
    assign bts_w      = latches_exe_cs_branch_target_sel;
    assign imm64_w    = latches_imm64;
    assign NEIP_w     = latches_NEIP;
    // p_address_t = 15 bits, $clog2(CACHE_LINES_SIZE_B)=4 -> bits [5:4]
    assign bank_num_0 = latches_LD_PADDR_0[5:4];
    assign bank_num_1 = latches_LD_PADDR_1[5:4];
    assign flush_w    = exe_outs_br_res_flush;

    // =========================================================================
    // BRANCH TARGET GENERATOR  (replaces MEM.sv:65-75 case + add)
    //
    //   case (branch_target_sel)
    //       ZEXT_IMM8 : rel_offset = sign_ext(imm64[7:0])
    //       ZEXT_IMM16: rel_offset = sign_ext(imm64[15:0])
    //       IMM32     : rel_offset = imm64[31:0]
    //       default   : rel_offset = 0
    //   br_rel_target = rel_offset + NEIP
    // =========================================================================
    wire [31:0] sext_imm8;
    wire [31:0] sext_imm16;
    wire [31:0] imm32_val;

    assign sext_imm8  = {{24{imm64_w[7]}},  imm64_w[7:0]};
    assign sext_imm16 = {{16{imm64_w[15]}}, imm64_w[15:0]};
    assign imm32_val  = imm64_w[31:0];

    // CMP against each enum literal -> per-case one-hot
    wire eq_zext8;
    wire eq_zext16;
    wire eq_imm32;

    `CMP_N(cmp_bts_zext8,  BTS_W, eq_zext8,  bts_w, SRC_SEL_ZEXT_IMM8)
    `CMP_N(cmp_bts_zext16, BTS_W, eq_zext16, bts_w, SRC_SEL_ZEXT_IMM16)
    `CMP_N(cmp_bts_imm32,  BTS_W, eq_imm32,  bts_w, SRC_SEL_IMM32)

    // Encode one-hot into a 2-bit select:
    //   sel = 00 -> default (0)
    //   sel = 01 -> ZEXT_IMM8
    //   sel = 10 -> ZEXT_IMM16
    //   sel = 11 -> IMM32
    wire bts_sel_lo, bts_sel_lo_buffered;
    wire bts_sel_hi, bts_sel_hi_buffered;
    wire [1:0] bts_sel;


    `OR_2(or_bts_sel_lo, 1, bts_sel_lo, eq_zext8,  eq_imm32)
    `OR_2(or_bts_sel_hi, 1, bts_sel_hi, eq_zext16, eq_imm32)

    bufferH64$ u_bts_sel_lo_buffer(bts_sel_lo_buffered, bts_sel_lo);
    bufferH64$ u_bts_sel_hi_buffer(bts_sel_hi_buffered, bts_sel_hi);

    assign bts_sel = {bts_sel_hi_buffered, bts_sel_lo_buffered};

    wire [31:0] rel_offset;
    `MUX_4(mux_rel_offset, 32, rel_offset,
           32'd0, sext_imm8, sext_imm16, imm32_val,
           bts_sel)

    wire [31:0] br_rel_target_w;
    wire        br_rel_cout;   // ignored
    `ADD_N(add_br_rel, 32, br_rel_target_w, br_rel_cout, rel_offset, NEIP_w, 1'b0)

    // =========================================================================
    // EXE_valid_logic  (already-ported flat module from MEM/gen/)
    //   Drives forward_valid (used by hit_buf storage) and outs.
    // =========================================================================
    wire exe_we_o_w;          // exe_stage_latch_we (active-high, local consumers)
    wire exe_we_n_o_w;        // active-low; routed to EXE_Latches port (inverter absorbed there)
    wire next_exe_v_o_w;      // exe_stage_next_vaild
    wire miss_stall_w;        // produced by mem_miss_stall_logic below

    EXE_valid_logic exe_valid_logic_unit (
        .EXE_we_o   (exe_we_o_w),
        .EXE_we_n_o (exe_we_n_o_w),
        .N_EXE_V_o  (next_exe_v_o_w),
        .MEM_V_i    (valid_w),
        .MEM_stall_i(miss_stall_w),
        .EXE_V_i    (exe_outs_valid),
        .WB_stall_i (wb_outs_wb_stall)
    );

    // forward_valid = exe_we_o & next_exe_v_o
    wire forward_valid_w;
    `AND_2(and_forward_valid, 1, forward_valid_w, exe_we_o_w, next_exe_v_o_w)

    // =========================================================================
    // PER-PORT HIT-BUF STORAGE  (replaces always_ff at MEM.sv:84-107)
    //
    //   hit_buf_v[i] register :
    //       WE = forward_valid | (hit_i & valid)
    //       D  = ~forward_valid                          // captures 1 on hit,
    //                                                       0 on forward
    //       (rst clears via REG_RST_WE)
    //
    //   hit_buf[i] (128 bit data) register :
    //       WE = (hit_i & valid) & ~forward_valid        // hold on forward
    //       D  = cacheline_i
    //
    //   MIO versions identical with hit_MIO / line_MIO.
    // =========================================================================
    wire forward_valid_inv;
    `INV_N(inv_fwdv, 1, forward_valid_w, forward_valid_inv)

    // ---------- per-port valid_capture = hit_i & valid ----------
    wire vcap_0;
    wire vcap_1;
    wire vcap_2;
    wire vcap_3;
    wire vcap_mio;
    `AND_2(and_vcap_0,   1, vcap_0,   hit_0,    valid_w)
    `AND_2(and_vcap_1,   1, vcap_1,   hit_1,    valid_w)
    `AND_2(and_vcap_2,   1, vcap_2,   hit_2,    valid_w)
    `AND_2(and_vcap_3,   1, vcap_3,   hit_3,    valid_w)
    `AND_2(and_vcap_mio, 1, vcap_mio, hit_MIO,  valid_w)

    // ---------- WE for valid bit registers ----------
    wire we_v_0;
    wire we_v_1;
    wire we_v_2;
    wire we_v_3;
    wire we_v_mio;
    
    wire forward_valid_w_for_we_v_0__;
    bufferH16$ u_forward_valid_w_for_we_v_0 (forward_valid_w_for_we_v_0__, forward_valid_w);
    `OR_2(or_wev_0,   1, we_v_0,   forward_valid_w_for_we_v_0__, vcap_0)
    `OR_2(or_wev_1,   1, we_v_1,   forward_valid_w_for_we_v_0__, vcap_1)
    `OR_2(or_wev_2,   1, we_v_2,   forward_valid_w_for_we_v_0__, vcap_2)
    `OR_2(or_wev_3,   1, we_v_3,   forward_valid_w_for_we_v_0__, vcap_3)
    `OR_2(or_wev_mio, 1, we_v_mio, forward_valid_w_for_we_v_0__, vcap_mio)

    // ---------- WE for data registers : vcap & ~forward_valid ----------
    wire we_d_0;
    wire we_d_1;
    wire we_d_2;
    wire we_d_3;
    wire we_d_mio;
    `AND_2(and_wed_0,   1, we_d_0,   vcap_0,   forward_valid_inv)
    `AND_2(and_wed_1,   1, we_d_1,   vcap_1,   forward_valid_inv)
    `AND_2(and_wed_2,   1, we_d_2,   vcap_2,   forward_valid_inv)
    `AND_2(and_wed_3,   1, we_d_3,   vcap_3,   forward_valid_inv)
    `AND_2(and_wed_mio, 1, we_d_mio, vcap_mio, forward_valid_inv)

    // ---------- valid-bit registers ----------
    wire hit_buf_v_0;
    wire hit_buf_v_1;
    wire hit_buf_v_2;
    wire hit_buf_v_3;


    wire hit_buf_mio_v;
    
    `REG_RST_WE(reg_hbv_0,   1, clk, rst, we_v_0,   forward_valid_inv, hit_buf_v_0)
    `REG_RST_WE(reg_hbv_1,   1, clk, rst, we_v_1,   forward_valid_inv, hit_buf_v_1)
    `REG_RST_WE(reg_hbv_2,   1, clk, rst, we_v_2,   forward_valid_inv, hit_buf_v_2)
    `REG_RST_WE(reg_hbv_3,   1, clk, rst, we_v_3,   forward_valid_inv, hit_buf_v_3)
    `REG_RST_WE(reg_hbv_mio, 1, clk, rst, we_v_mio, forward_valid_inv, hit_buf_mio_v)

    // ---------- 128-bit data registers ----------
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
    // MISS-STALL  (instantiate the structural mem_miss_stall_logic)
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
    // LINE SELECT MUXES  (replaces MEM.sv:110-129)
    //
    //   line_in_0 = hit_buf_v[bank_num_0] ? hit_buf[bank_num_0]
    //                                     : cacheline[bank_num_0]
    //   line_in_1 = hit_buf_v[bank_num_1] ? hit_buf[bank_num_1]
    //                                     : cacheline[bank_num_1]
    //   line_in_mio = hit_buf_mio_v       ? hit_buf_mio : line_MIO
    // =========================================================================
    // ---- bank-0 path ----
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

    wire hit_buf_v_sel0_buffered;
    bufferH256$ u_hit_buf_v_sel0_buffer (hit_buf_v_sel0_buffered, hit_buf_v_sel0);
    `MUX_2(mux_line_in_0, CL_BITS, line_in_0,
           cacheline_sel0, hit_buf_sel0, hit_buf_v_sel0_buffered)

    // ---- bank-1 path ----
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
    
    wire hit_buf_v_sel1_buffered;
    bufferH256$ u_hit_buf_v_sel1_buffer (hit_buf_v_sel1_buffered, hit_buf_v_sel1);
    `MUX_2(mux_line_in_1, CL_BITS, line_in_1,
           cacheline_sel1, hit_buf_sel1, hit_buf_v_sel1_buffered)

    // ---- MIO path ----
    wire [CL_BITS-1:0] line_in_mio;
    wire hit_buf_mio_v_buffered;
    bufferH1024$ u_hit_buf_mio_v_buffer(hit_buf_mio_v_buffered, hit_buf_mio_v);
    `MUX_2(mux_line_in_mio, CL_BITS, line_in_mio,
           line_MIO, hit_buf_mio_packed, hit_buf_mio_v_buffered)

    // =========================================================================
    // MASKING + CL ASSEMBLY  (MEM.sv:119-129, 181-188)
    //
    //   line_in_0_masked = LD_OP  ? line_in_0 : 0
    //   line_in_1_masked = LD_XCL ? line_in_1 : 0
    //   C0               = MIO    ? line_in_mio : line_in_0_masked
    //   ld_buf (256b)    = forward_valid ? {line_in_1_masked, C0} : 0
    // =========================================================================
    wire [CL_BITS-1:0] line_in_0_masked;
    wire [CL_BITS-1:0] line_in_1_masked;
    wire [CL_BITS-1:0] C0_w;

    `MUX_2(mux_l0_mask, CL_BITS, line_in_0_masked, {CL_BITS{1'b0}}, line_in_0, LD_OP_w)
    `MUX_2(mux_l1_mask, CL_BITS, line_in_1_masked, {CL_BITS{1'b0}}, line_in_1, LD_XCL_w)
    `MUX_2(mux_C0,      CL_BITS, C0_w,             line_in_0_masked, line_in_mio, MIO_w)

    // ld_buf_unmasked = {up_buf, low_buf} where low_buf=C0, up_buf=line_in_1_masked
    wire [LD_BITS-1:0] ld_buf_unmasked;
    assign ld_buf_unmasked = {line_in_1_masked, C0_w};

    wire [LD_BITS-1:0] ld_buf_packed = ld_buf_unmasked;
    //`MUX_2(mux_ldbuf, LD_BITS, ld_buf_packed,
    //       {LD_BITS{1'b0}}, ld_buf_unmasked, forward_valid_w)

    // =========================================================================
    // CLR_DCACHE_ARB_LATCHES  (per port)  &  CLR_DCACHE_MIO_LATCH
    //   (replaces MEM.sv:131-153)
    //
    //   per port i (when ~MIO):
    //     cond0_i = (bank_num_0 == i) & LD_OP & (hit_i & ~hit_buf_v_i)
    //               & valid & ~MIO
    //     cond1_i = (bank_num_1 == i) & LD_OP & LD_XCL
    //               & (hit_i & ~hit_buf_v_i) & valid & ~MIO
    //     clr_arb_i = cond0_i | cond1_i | flush     // flush forces all ports
    //
    //   mio :
    //     clr_mio = MIO & LD_OP & (hit_MIO & ~hit_buf_mio_v | flush) & valid
    // =========================================================================
    wire MIO_n_w;
    `INV_N(inv_MIO_w, 1, MIO_w, MIO_n_w)

    // Per-port equality of bank_num_0 / bank_num_1 against literal i
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

    // Per-port hit_i & ~hit_buf_v_i
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

    // cond0_i  (5-input AND) -- no flush; flush is OR'd in at the end
    wire cond0_0, cond0_1, cond0_2, cond0_3;
    `AND_5(and_c0_0, 1, cond0_0, bnk0_eq_0, LD_OP_w, hit_no_buf_0, valid_w, MIO_n_w)
    `AND_5(and_c0_1, 1, cond0_1, bnk0_eq_1, LD_OP_w, hit_no_buf_1, valid_w, MIO_n_w)
    `AND_5(and_c0_2, 1, cond0_2, bnk0_eq_2, LD_OP_w, hit_no_buf_2, valid_w, MIO_n_w)
    `AND_5(and_c0_3, 1, cond0_3, bnk0_eq_3, LD_OP_w, hit_no_buf_3, valid_w, MIO_n_w)

    // cond1_i  (6-input AND, also requires LD_XCL) -- no flush
    wire cond1_0, cond1_1, cond1_2, cond1_3;
    `AND_6(and_c1_0, 1, cond1_0, bnk1_eq_0, LD_OP_w, LD_XCL_w, hit_no_buf_0, valid_w, MIO_n_w)
    `AND_6(and_c1_1, 1, cond1_1, bnk1_eq_1, LD_OP_w, LD_XCL_w, hit_no_buf_1, valid_w, MIO_n_w)
    `AND_6(and_c1_2, 1, cond1_2, bnk1_eq_2, LD_OP_w, LD_XCL_w, hit_no_buf_2, valid_w, MIO_n_w)
    `AND_6(and_c1_3, 1, cond1_3, bnk1_eq_3, LD_OP_w, LD_XCL_w, hit_no_buf_3, valid_w, MIO_n_w)

    // Final clr_arb per port : cond0_i | cond1_i | flush
    //   (flush unconditionally forces every port to 1, matching MEM.sv:152
    //    "if(flush) clr_dcache_arb_latches = '{default: '1};")
    wire clr_arb_0, clr_arb_1, clr_arb_2, clr_arb_3;
    `OR_3(or_clrarb_0, 1, clr_arb_0, cond0_0, cond1_0, flush_w)
    `OR_3(or_clrarb_1, 1, clr_arb_1, cond0_1, cond1_1, flush_w)
    `OR_3(or_clrarb_2, 1, clr_arb_2, cond0_2, cond1_2, flush_w)
    `OR_3(or_clrarb_3, 1, clr_arb_3, cond0_3, cond1_3, flush_w)

    // MIO clear : (hit_MIO & ~hit_buf_mio_v | flush) & MIO & LD_OP & valid
    wire hit_buf_mio_v_n;
    wire hit_MIO_no_buf;
    wire hit_MIO_or_flush;
    wire clr_dcache_mio_latch_w;

    `INV_N(inv_hbmiov,    1, hit_buf_mio_v,   hit_buf_mio_v_n)
    `AND_2(and_hMIOnb,    1, hit_MIO_no_buf,  hit_MIO, hit_buf_mio_v_n)
    `OR_2 (or_hMIOoflush, 1, hit_MIO_or_flush, hit_MIO_no_buf, flush_w)
    `AND_4(and_clrmio,    1, clr_dcache_mio_latch_w,
           MIO_w, LD_OP_w, hit_MIO_or_flush, valid_w)

    // =========================================================================
    // OUTPUT ASSIGNMENTS  (flat, one per former struct field)
    // =========================================================================

    // ---- exe_latches_next_o ----
    assign exe_latches_next_valid                       = next_exe_v_o_w;

    // exe_cs_t pass-through
    assign exe_latches_next_cs_ST_OP                    = latches_exe_cs_ST_OP;
    assign exe_latches_next_cs_OP_TYPE                  = latches_exe_cs_OP_TYPE;
    // bufferH64$ on the 3 high-fanout selects -- they fan out to 3 replicated
    // EXE_Latches flops apiece, plus internal MEM wiring; H64 gives clean
    // edges into the latch D-pins at 0.30 ns.
    genvar gi_buf_sel;
    generate
        for (gi_buf_sel = 0; gi_buf_sel < 5; gi_buf_sel = gi_buf_sel + 1) begin : g_mem_sel_buf
            bufferH64$ u_buf_inA (
                .out(exe_latches_next_cs_alu_inputA_sel[gi_buf_sel]),
                .in (latches_exe_cs_alu_inputA_sel[gi_buf_sel]));
            bufferH64$ u_buf_inB (
                .out(exe_latches_next_cs_alu_inputB_sel[gi_buf_sel]),
                .in (latches_exe_cs_alu_inputB_sel[gi_buf_sel]));
            bufferH64$ u_buf_brT (
                .out(exe_latches_next_cs_branch_target_sel[gi_buf_sel]),
                .in (latches_exe_cs_branch_target_sel[gi_buf_sel]));
        end
    endgenerate
    assign exe_latches_next_cs_shift_by_one             = latches_exe_cs_shift_by_one;
    assign exe_latches_next_cs_br_ucond                 = latches_exe_cs_br_ucond;
    assign exe_latches_next_cs_relative_branch          = latches_exe_cs_relative_branch;
    assign exe_latches_next_cs_special_br               = latches_exe_cs_special_br;
    assign exe_latches_next_cs_is_far                   = latches_exe_cs_is_far;
    assign exe_latches_next_cs_is_call                  = latches_exe_cs_is_call;
    assign exe_latches_next_cs_second_flag_needed       = latches_exe_cs_second_flag_needed;
    assign exe_latches_next_cs_rep_no_zf_update         = latches_exe_cs_rep_no_zf_update;

    // wb_cs_t pass-through
    assign exe_latches_next_wb_cs_ST_OP                 = latches_wb_cs_ST_OP;
    assign exe_latches_next_wb_cs_WB_DR                 = latches_wb_cs_WB_DR;
    assign exe_latches_next_wb_cs_WB_SR                 = latches_wb_cs_WB_SR;
    assign exe_latches_next_wb_cs_WB_EAX                = latches_wb_cs_WB_EAX;

    assign exe_latches_next_data_size_vec               = latches_data_size_vec;
    assign exe_latches_next_sr_data_size_vec            = latches_sr_data_size_vec;
    assign exe_latches_next_shift_sr_up                 = latches_shift_sr_up;
    assign exe_latches_next_shift_sr_down               = latches_shift_sr_down;

    assign exe_latches_next_ST_XCL                      = latches_ST_XCL;
    assign exe_latches_next_ST_PADDR_0                  = latches_ST_PADDR_0;
    assign exe_latches_next_ST_PADDR_1                  = latches_ST_PADDR_1;
    assign exe_latches_next_MIO                         = latches_MIO;

    // br_info_t pass-through
    assign exe_latches_next_br_info_valid               = latches_br_info_valid;
    assign exe_latches_next_br_info_br_eip              = latches_br_info_br_eip;
    assign exe_latches_next_br_info_br_xcl              = latches_br_info_br_xcl;
    assign exe_latches_next_br_info_br_pred_taken       = latches_br_info_br_pred_taken;
    assign exe_latches_next_br_info_speculative_target  = latches_br_info_speculative_target;

    assign exe_latches_next_br_rel_target               = br_rel_target_w;

    assign exe_latches_next_NEIP                        = latches_NEIP;
    assign exe_latches_next_EIP                         = latches_EIP;
    assign exe_latches_next_EAX                         = latches_EAX;
    assign exe_latches_next_imm64                       = latches_imm64;

    assign exe_latches_next_ld_buf                      = ld_buf_packed;

    assign exe_latches_next_sr_id                       = latches_sr_id;
    assign exe_latches_next_sr_data                     = latches_sr_data;
    assign exe_latches_next_dr_id                       = latches_dr_id;
    assign exe_latches_next_dr_data                     = latches_dr_data;

    assign exe_latches_next_ld_addy                     = latches_LD_PADDR_0;

    // ---- outs_o ----
    assign outs_valid                    = valid_w;
    assign outs_stall                    = miss_stall_w;
    assign outs_ST_XCL                   = ST_XCL_w;
    assign outs_ST_PADDR_0               = latches_ST_PADDR_0;
    assign outs_ST_PADDR_1               = latches_ST_PADDR_1;
    assign outs_ST_OP                    = ST_OP_w;
    assign outs_exe_stage_latch_we       = exe_we_o_w;
    assign outs_exe_stage_latch_we_n     = exe_we_n_o_w;

    assign outs_clr_dcache_arb_latches_0 = clr_arb_0;
    assign outs_clr_dcache_arb_latches_1 = clr_arb_1;
    assign outs_clr_dcache_arb_latches_2 = clr_arb_2;
    assign outs_clr_dcache_arb_latches_3 = clr_arb_3;

    assign outs_clr_dcache_mio_latch     = clr_dcache_mio_latch_w;

endmodule
