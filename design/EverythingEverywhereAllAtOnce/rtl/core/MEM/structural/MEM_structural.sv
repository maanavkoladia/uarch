// =============================================================================
// MEM  (structural Verilog port of MEM.sv)
//
//   - Outer interface keeps SystemVerilog struct typedefs (latches_i,
//     exe_outs_i, wb_outs_i, exe_latches_next_o, outs_o) so it drops in
//     for the existing instantiation in the core top-level.
//   - The cache-side arrays (hit[], cacheline[][], line_MIO, etc.) are
//     unrolled into one port per dcache port for readability.
//   - All combinational logic is expressed with INV_N / AND_N / OR_N /
//     MUX_N / CMP_N / ADD_N from lib/STDCells/STDCell_Macros.vh.
//   - All sequential storage uses the REG_RST_WE macro -- no always_ff.
//   - assign is used only for wire renaming, slicing, concatenation,
//     replication, and zero-logic struct-literal aliasing of the SV-typed
//     output ports.
// =============================================================================

import core_common_pkg::*;
import core_stage_latches_pkg::*;
import common_pkg::*;
import control_store_pkg::*;

module MEM (
    input  wire             clk,
    input  wire             rst,

    input  mem_latches_t    latches_i,

    // For valid-bit shift / flush
    input  exe_outputs_t    exe_outs_i,

    // Only the wb_stall field is consumed
    input  wb_outputs_t     wb_outs_i,

    // From dcache -- one port per dcache port (was hit[NUM_DCACHE_PORTS] /
    //                                          cacheline[NUM_DCACHE_PORTS][CL_B])
    input  wire             hit_0_i,
    input  wire             hit_1_i,
    input  wire             hit_2_i,
    input  wire             hit_3_i,

    input  byte_t           cacheline_0_i [CACHE_LINES_SIZE_B],
    input  byte_t           cacheline_1_i [CACHE_LINES_SIZE_B],
    input  byte_t           cacheline_2_i [CACHE_LINES_SIZE_B],
    input  byte_t           cacheline_3_i [CACHE_LINES_SIZE_B],

    input  wire             hit_MIO_i,
    input  byte_t           line_MIO_i    [CACHE_LINES_SIZE_B],

    output exe_latches_t    exe_latches_next_o,
    output mem_outputs_t    outs_o
);

    // -------------------------------------------------------------------------
    // Local widths
    // -------------------------------------------------------------------------
    localparam int CL_BITS = CACHE_LINES_SIZE_B * 8;            // 128
    localparam int LD_BITS = EXE_BUFFER_SIZE     * 8;           // 256
    localparam int BTS_W   = $bits(source_selector_e);          // enum width

    // =========================================================================
    // Pack the unpacked-byte-array cache inputs into 128-bit buses
    // (pure wire restructuring -- no logic).
    // =========================================================================
    wire [CL_BITS-1:0] cacheline_0_packed;
    wire [CL_BITS-1:0] cacheline_1_packed;
    wire [CL_BITS-1:0] cacheline_2_packed;
    wire [CL_BITS-1:0] cacheline_3_packed;
    wire [CL_BITS-1:0] line_MIO_packed;

    genvar gi;
    generate
        for (gi = 0; gi < CACHE_LINES_SIZE_B; gi = gi + 1) begin : pack_cl
            assign cacheline_0_packed[gi*8 +: 8] = cacheline_0_i[gi];
            assign cacheline_1_packed[gi*8 +: 8] = cacheline_1_i[gi];
            assign cacheline_2_packed[gi*8 +: 8] = cacheline_2_i[gi];
            assign cacheline_3_packed[gi*8 +: 8] = cacheline_3_i[gi];
            assign line_MIO_packed   [gi*8 +: 8] = line_MIO_i   [gi];
        end
    endgenerate

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

    assign valid_w    = latches_i.valid;
    assign LD_OP_w    = latches_i.cs.LD_OP;
    assign ST_OP_w    = latches_i.cs.ST_OP;
    assign LD_XCL_w   = latches_i.LD_XCL;
    assign MIO_w      = latches_i.MIO;
    assign ST_XCL_w   = latches_i.ST_XCL;
    assign bts_w      = latches_i.exe_cs.branch_target_sel;
    assign imm64_w    = latches_i.imm64;
    assign NEIP_w     = latches_i.NEIP;
    assign bank_num_0 = latches_i.LD_PADDR_0[$clog2(CACHE_LINES_SIZE_B) +: 2];
    assign bank_num_1 = latches_i.LD_PADDR_1[$clog2(CACHE_LINES_SIZE_B) +: 2];
    assign flush_w    = exe_outs_i.br_res_out.flush;

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

    `CMP_N(cmp_bts_zext8,  BTS_W, eq_zext8,  bts_w, source_selector_e'(ZEXT_IMM8))
    `CMP_N(cmp_bts_zext16, BTS_W, eq_zext16, bts_w, source_selector_e'(ZEXT_IMM16))
    `CMP_N(cmp_bts_imm32,  BTS_W, eq_imm32,  bts_w, source_selector_e'(IMM32))

    // Encode one-hot into a 2-bit select:
    //   sel = 00 -> default (0)
    //   sel = 01 -> ZEXT_IMM8
    //   sel = 10 -> ZEXT_IMM16
    //   sel = 11 -> IMM32
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
    wire        br_rel_cout;   // ignored
    `ADD_N(add_br_rel, 32, br_rel_target, br_rel_cout, rel_offset, NEIP_w, 1'b0)

    // =========================================================================
    // EXE_valid_logic  (already-ported flat module from MEM/gen/)
    //   Drives forward_valid (used by hit_buf storage) and outs.
    // =========================================================================
    wire exe_we_o_w;          // exe_stage_latch_we
    wire next_exe_v_o_w;      // exe_stage_next_vaild
    wire miss_stall_w;        // produced by mem_miss_stall_logic below

    EXE_valid_logic exe_valid_logic_unit (
        .EXE_we_o   (exe_we_o_w),
        .N_EXE_V_o  (next_exe_v_o_w),
        .MEM_V_i    (valid_w),
        .MEM_stall_i(miss_stall_w),
        .EXE_V_i    (exe_outs_i.valid),
        .WB_stall_i (wb_outs_i.wb_stall)
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
    //       D  = cacheline_i_packed
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
    `AND_2(and_vcap_0,   1, vcap_0,   hit_0_i,   valid_w)
    `AND_2(and_vcap_1,   1, vcap_1,   hit_1_i,   valid_w)
    `AND_2(and_vcap_2,   1, vcap_2,   hit_2_i,   valid_w)
    `AND_2(and_vcap_3,   1, vcap_3,   hit_3_i,   valid_w)
    `AND_2(and_vcap_mio, 1, vcap_mio, hit_MIO_i, valid_w)

    // ---------- WE for valid bit registers ----------
    wire we_v_0;
    wire we_v_1;
    wire we_v_2;
    wire we_v_3;
    wire we_v_mio;
    `OR_2(or_wev_0,   1, we_v_0,   forward_valid_w, vcap_0)
    `OR_2(or_wev_1,   1, we_v_1,   forward_valid_w, vcap_1)
    `OR_2(or_wev_2,   1, we_v_2,   forward_valid_w, vcap_2)
    `OR_2(or_wev_3,   1, we_v_3,   forward_valid_w, vcap_3)
    `OR_2(or_wev_mio, 1, we_v_mio, forward_valid_w, vcap_mio)

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

    `REG_RST_WE(reg_hb_0,   CL_BITS, clk, rst, we_d_0,   cacheline_0_packed, hit_buf_0_packed)
    `REG_RST_WE(reg_hb_1,   CL_BITS, clk, rst, we_d_1,   cacheline_1_packed, hit_buf_1_packed)
    `REG_RST_WE(reg_hb_2,   CL_BITS, clk, rst, we_d_2,   cacheline_2_packed, hit_buf_2_packed)
    `REG_RST_WE(reg_hb_3,   CL_BITS, clk, rst, we_d_3,   cacheline_3_packed, hit_buf_3_packed)
    `REG_RST_WE(reg_hb_mio, CL_BITS, clk, rst, we_d_mio, line_MIO_packed,    hit_buf_mio_packed)

    // =========================================================================
    // MISS-STALL  (instantiate the structural mem_miss_stall_logic)
    // =========================================================================
    mem_miss_stall_logic mem_stall (
        .valid         (valid_w),
        .LD_XCL        (LD_XCL_w),
        .LD_OP         (LD_OP_w),
        .MIO           (MIO_w),
        .hit_0         (hit_0_i),
        .hit_1         (hit_1_i),
        .hit_2         (hit_2_i),
        .hit_3         (hit_3_i),
        .hit_MIO       (hit_MIO_i),
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
           cacheline_0_packed, cacheline_1_packed, cacheline_2_packed, cacheline_3_packed,
           bank_num_0)

    `MUX_4(mux_hbv_sel0, 1, hit_buf_v_sel0,
           hit_buf_v_0, hit_buf_v_1, hit_buf_v_2, hit_buf_v_3,
           bank_num_0)

    `MUX_2(mux_line_in_0, CL_BITS, line_in_0,
           cacheline_sel0, hit_buf_sel0, hit_buf_v_sel0)

    // ---- bank-1 path ----
    wire [CL_BITS-1:0] hit_buf_sel1;
    wire [CL_BITS-1:0] cacheline_sel1;
    wire               hit_buf_v_sel1;
    wire [CL_BITS-1:0] line_in_1;

    `MUX_4(mux_hb_sel1, CL_BITS, hit_buf_sel1,
           hit_buf_0_packed, hit_buf_1_packed, hit_buf_2_packed, hit_buf_3_packed,
           bank_num_1)

    `MUX_4(mux_cl_sel1, CL_BITS, cacheline_sel1,
           cacheline_0_packed, cacheline_1_packed, cacheline_2_packed, cacheline_3_packed,
           bank_num_1)

    `MUX_4(mux_hbv_sel1, 1, hit_buf_v_sel1,
           hit_buf_v_0, hit_buf_v_1, hit_buf_v_2, hit_buf_v_3,
           bank_num_1)

    `MUX_2(mux_line_in_1, CL_BITS, line_in_1,
           cacheline_sel1, hit_buf_sel1, hit_buf_v_sel1)

    // ---- MIO path ----
    wire [CL_BITS-1:0] line_in_mio;
    `MUX_2(mux_line_in_mio, CL_BITS, line_in_mio,
           line_MIO_packed, hit_buf_mio_packed, hit_buf_mio_v)

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

    wire [LD_BITS-1:0] ld_buf_packed;
    `MUX_2(mux_ldbuf, LD_BITS, ld_buf_packed,
           {LD_BITS{1'b0}}, ld_buf_unmasked, forward_valid_w)

    // Unpack ld_buf_packed back into a byte_t[EXE_BUFFER_SIZE] for the
    // exe_latches struct field.
    byte_t ld_buf [EXE_BUFFER_SIZE];
    genvar lb;
    generate
        for (lb = 0; lb < EXE_BUFFER_SIZE; lb = lb + 1) begin : unpack_ldbuf
            assign ld_buf[lb] = ld_buf_packed[lb*8 +: 8];
        end
    endgenerate

    // =========================================================================
    // CLR_DCACHE_ARB_LATCHES  (per port)  &  CLR_DCACHE_MIO_LATCH
    //   (replaces MEM.sv:131-153)
    //
    //   per port i (when ~MIO):
    //     cond0_i = (bank_num_0 == i) & LD_OP & (hit_i & ~hit_buf_v_i | flush)
    //               & valid & ~MIO
    //     cond1_i = (bank_num_1 == i) & LD_OP & LD_XCL
    //               & (hit_i & ~hit_buf_v_i | flush) & valid & ~MIO
    //     clr_arb_i = cond0_i | cond1_i
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
    `AND_2(and_hnb_0, 1, hit_no_buf_0, hit_0_i, hit_buf_v_0_n)
    `AND_2(and_hnb_1, 1, hit_no_buf_1, hit_1_i, hit_buf_v_1_n)
    `AND_2(and_hnb_2, 1, hit_no_buf_2, hit_2_i, hit_buf_v_2_n)
    `AND_2(and_hnb_3, 1, hit_no_buf_3, hit_3_i, hit_buf_v_3_n)

    // (hit_i & ~hit_buf_v_i) | flush   -- per port
    wire hit_or_flush_0, hit_or_flush_1, hit_or_flush_2, hit_or_flush_3;
    `OR_2(or_hof_0, 1, hit_or_flush_0, hit_no_buf_0, flush_w)
    `OR_2(or_hof_1, 1, hit_or_flush_1, hit_no_buf_1, flush_w)
    `OR_2(or_hof_2, 1, hit_or_flush_2, hit_no_buf_2, flush_w)
    `OR_2(or_hof_3, 1, hit_or_flush_3, hit_no_buf_3, flush_w)

    // cond0_i  (5-input AND)
    wire cond0_0, cond0_1, cond0_2, cond0_3;
    `AND_5(and_c0_0, 1, cond0_0, bnk0_eq_0, LD_OP_w, hit_or_flush_0, valid_w, MIO_n_w)
    `AND_5(and_c0_1, 1, cond0_1, bnk0_eq_1, LD_OP_w, hit_or_flush_1, valid_w, MIO_n_w)
    `AND_5(and_c0_2, 1, cond0_2, bnk0_eq_2, LD_OP_w, hit_or_flush_2, valid_w, MIO_n_w)
    `AND_5(and_c0_3, 1, cond0_3, bnk0_eq_3, LD_OP_w, hit_or_flush_3, valid_w, MIO_n_w)

    // cond1_i  (6-input AND, also requires LD_XCL)
    wire cond1_0, cond1_1, cond1_2, cond1_3;
    `AND_6(and_c1_0, 1, cond1_0, bnk1_eq_0, LD_OP_w, LD_XCL_w, hit_or_flush_0, valid_w, MIO_n_w)
    `AND_6(and_c1_1, 1, cond1_1, bnk1_eq_1, LD_OP_w, LD_XCL_w, hit_or_flush_1, valid_w, MIO_n_w)
    `AND_6(and_c1_2, 1, cond1_2, bnk1_eq_2, LD_OP_w, LD_XCL_w, hit_or_flush_2, valid_w, MIO_n_w)
    `AND_6(and_c1_3, 1, cond1_3, bnk1_eq_3, LD_OP_w, LD_XCL_w, hit_or_flush_3, valid_w, MIO_n_w)

    // Final clr_arb per port
    wire clr_arb_0, clr_arb_1, clr_arb_2, clr_arb_3;
    `OR_2(or_clrarb_0, 1, clr_arb_0, cond0_0, cond1_0)
    `OR_2(or_clrarb_1, 1, clr_arb_1, cond0_1, cond1_1)
    `OR_2(or_clrarb_2, 1, clr_arb_2, cond0_2, cond1_2)
    `OR_2(or_clrarb_3, 1, clr_arb_3, cond0_3, cond1_3)

    // Pack into the unpacked-bool array used by the mem_outputs_t struct
    bool clr_dcache_arb_latches_w [NUM_DCACHE_PORTS];
    assign clr_dcache_arb_latches_w[0] = clr_arb_0;
    assign clr_dcache_arb_latches_w[1] = clr_arb_1;
    assign clr_dcache_arb_latches_w[2] = clr_arb_2;
    assign clr_dcache_arb_latches_w[3] = clr_arb_3;

    // MIO clear : (hit_MIO & ~hit_buf_mio_v | flush) & MIO & LD_OP & valid
    wire hit_buf_mio_v_n;
    wire hit_MIO_no_buf;
    wire hit_MIO_or_flush;
    wire clr_dcache_mio_latch_w;

    `INV_N(inv_hbmiov,    1, hit_buf_mio_v,   hit_buf_mio_v_n)
    `AND_2(and_hMIOnb,    1, hit_MIO_no_buf,  hit_MIO_i, hit_buf_mio_v_n)
    `OR_2 (or_hMIOoflush, 1, hit_MIO_or_flush, hit_MIO_no_buf, flush_w)
    `AND_4(and_clrmio,    1, clr_dcache_mio_latch_w,
           MIO_w, LD_OP_w, hit_MIO_or_flush, valid_w)

    // =========================================================================
    // OUTPUT STRUCT ASSEMBLY  (zero-logic field aliasing)
    // =========================================================================
    assign exe_latches_next_o = '{
            valid           : next_exe_v_o_w,
            cs              : latches_i.exe_cs,
            wb_cs           : latches_i.wb_cs,
            data_size_vec   : latches_i.data_size_vec,
            sr_data_size_vec: latches_i.sr_data_size_vec,
            shift_sr_up     : latches_i.shift_sr_up,
            shift_sr_down   : latches_i.shift_sr_down,
            ST_XCL          : latches_i.ST_XCL,
            ST_PADDR_0      : latches_i.ST_PADDR_0,
            ST_PADDR_1      : latches_i.ST_PADDR_1,
            MIO             : latches_i.MIO,
            br_info         : latches_i.br_info,
            br_rel_target   : br_rel_target,
            NEIP            : latches_i.NEIP,
            EIP             : latches_i.EIP,
            EAX             : latches_i.EAX,
            imm64           : latches_i.imm64,
            ld_buf          : ld_buf,
            sr_id           : latches_i.sr_id,
            sr_data         : latches_i.sr_data,
            dr_id           : latches_i.dr_id,
            dr_data         : latches_i.dr_data,
            ld_addy         : latches_i.LD_PADDR_0
        };

    assign outs_o = '{
            valid                  : valid_w,
            stall                  : miss_stall_w,
            ST_XCL                 : ST_XCL_w,
            ST_PADDR_0             : latches_i.ST_PADDR_0,
            ST_PADDR_1             : latches_i.ST_PADDR_1,
            ST_OP                  : ST_OP_w,
            exe_stage_latch_we     : exe_we_o_w,
            clr_dcache_arb_latches : clr_dcache_arb_latches_w,
            clr_dcache_mio_latch   : clr_dcache_mio_latch_w
        };

endmodule
