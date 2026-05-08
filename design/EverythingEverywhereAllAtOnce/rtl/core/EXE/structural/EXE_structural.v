// EXE_structural.v
//
// Pure Verilog-2005 top of the execute stage. Same internal structure as
// EXE_structural.sv (kept on disk as the SV reference) but with all SV-only
// constructs removed:
//   * No `import` of any package.
//   * No struct or typedef ports -- exe_latches_t, wb_outputs_t (the one
//     field consumed: wb_stall), rr_outputs_t, wb_latches_t, exe_outputs_t
//     are unrolled into individual flat wires whose widths come from the
//     field types.
//   * No unpacked-array ports -- byte arrays (ld_buf, res_buf) are passed
//     as packed buses; regFileValues[NUM_REGS] is split into 26 named wires.
//   * `bool`/`logic`/`uint*_t` -> `wire [W-1:0]`.
//
// Body is identical in shape to EXE_structural.sv; the only deletions are
// the per-byte ld_buf pack and per-byte res_buf unpack generates (now
// pass-through, since both are packed buses on the port boundary).

module EXE (
    input  wire         clk,
    input  wire         rst,

    // ====================================================================
    // exe_latches_t (latches_i)
    // ====================================================================
    input  wire         latches_valid,

    // exe_cs_t (latches_i.cs)
    input  wire         latches_cs_ST_OP,
    input  wire [5:0]   latches_cs_OP_TYPE,
    // 3-way replicated select inputs from EXE_Latches replicas:
    //   _ (no suffix) -> alu_input_sel_crit  (cmp/cmpxchg/xchg/sal/sar/rep_cmp)
    //   _b           -> alu_input_sel_arith (adc/add/and/or/sbb/.../mov/movs)
    //   _c           -> alu_input_sel_ctrl  (aaa/call/ret/pop/push/simd/...)
    input  wire [4:0]   latches_cs_alu_inputA_sel,
    input  wire [4:0]   latches_cs_alu_inputA_sel_b,
    input  wire [4:0]   latches_cs_alu_inputA_sel_c,
    input  wire [4:0]   latches_cs_alu_inputB_sel,
    input  wire [4:0]   latches_cs_alu_inputB_sel_b,
    input  wire [4:0]   latches_cs_alu_inputB_sel_c,
    input  wire [4:0]   latches_cs_branch_target_sel,
    input  wire [4:0]   latches_cs_branch_target_sel_b,
    input  wire [4:0]   latches_cs_branch_target_sel_c,
    input  wire         latches_cs_shift_by_one,
    input  wire         latches_cs_br_ucond,
    input  wire         latches_cs_relative_branch,
    input  wire         latches_cs_special_br,
    input  wire         latches_cs_is_far,
    input  wire         latches_cs_is_call,
    input  wire         latches_cs_second_flag_needed,
    input  wire         latches_cs_rep_no_zf_update,

    // wb_cs_t (latches_i.wb_cs)
    input  wire         latches_wb_cs_ST_OP,
    input  wire         latches_wb_cs_WB_DR,
    input  wire         latches_wb_cs_WB_SR,
    input  wire         latches_wb_cs_WB_EAX,

    input  wire [3:0]   latches_data_size_vec,
    input  wire [3:0]   latches_sr_data_size_vec,
    // 3-way replicated shift selects (one per alu_input_sel cluster)
    input  wire         latches_shift_sr_up,
    input  wire         latches_shift_sr_up_b,
    input  wire         latches_shift_sr_up_c,
    input  wire         latches_shift_sr_down,
    input  wire         latches_shift_sr_down_b,
    input  wire         latches_shift_sr_down_c,
    input  wire         latches_ST_XCL,
    // 3-way replicated ST_PADDR_0 (a -> bit_vec, b -> res_buf, c -> outputs)
    input  wire [14:0]  latches_ST_PADDR_0,
    input  wire [14:0]  latches_ST_PADDR_0_b,
    input  wire [14:0]  latches_ST_PADDR_0_c,
    input  wire [14:0]  latches_ST_PADDR_1,
    input  wire         latches_MIO,

    // br_info_t (latches_i.br_info)
    input  wire         latches_br_info_valid,
    input  wire [31:0]  latches_br_info_br_eip,
    input  wire         latches_br_info_br_xcl,
    input  wire         latches_br_info_br_pred_taken,
    input  wire [31:0]  latches_br_info_speculative_target,

    input  wire [31:0]  latches_br_rel_target,
    input  wire [31:0]  latches_NEIP,
    input  wire [31:0]  latches_EIP,
    input  wire [31:0]  latches_EAX,
    input  wire [63:0]  latches_imm64,
    // 3-way replicated ld_buf (primary=crit, b=arith, c=ctrl)
    input  wire [255:0] latches_ld_buf,         // EXE_BUFFER_SIZE = 32 bytes
    input  wire [255:0] latches_ld_buf_b,
    input  wire [255:0] latches_ld_buf_c,
    // 3-way replicated sr_id (a -> sr_data MUX, b -> xchg, c -> reg_wb)
    input  wire [4:0]   latches_sr_id,
    input  wire [4:0]   latches_sr_id_b,
    input  wire [4:0]   latches_sr_id_c,
    input  wire [63:0]  latches_sr_data,
    // 3-way replicated dr_id (a -> dr_data MUX, b -> xchg, c -> reg_wb)
    input  wire [4:0]   latches_dr_id,
    input  wire [4:0]   latches_dr_id_b,
    input  wire [4:0]   latches_dr_id_c,
    input  wire [63:0]  latches_dr_data,
    // 3-way replicated ld_addy (a/b/c -> alu_input_sel_crit/arith/ctrl)
    input  wire [14:0]  latches_ld_addy,
    input  wire [14:0]  latches_ld_addy_b,
    input  wire [14:0]  latches_ld_addy_c,

    // ====================================================================
    // wb_outputs_t (wb_outs_i) -- only wb_stall is consumed
    // ====================================================================
    input  wire         wb_outs_wb_stall,

    // ====================================================================
    // rr_outputs_t (rr_outs_i)
    // ====================================================================
    input  wire [31:0]  rr_outs_codeSeg_data,
    input  wire [63:0]  rr_outs_regFileValues_0,
    input  wire [63:0]  rr_outs_regFileValues_1,
    input  wire [63:0]  rr_outs_regFileValues_2,
    input  wire [63:0]  rr_outs_regFileValues_3,
    input  wire [63:0]  rr_outs_regFileValues_4,
    input  wire [63:0]  rr_outs_regFileValues_5,
    input  wire [63:0]  rr_outs_regFileValues_6,
    input  wire [63:0]  rr_outs_regFileValues_7,
    input  wire [63:0]  rr_outs_regFileValues_8,
    input  wire [63:0]  rr_outs_regFileValues_9,
    input  wire [63:0]  rr_outs_regFileValues_10,
    input  wire [63:0]  rr_outs_regFileValues_11,
    input  wire [63:0]  rr_outs_regFileValues_12,
    input  wire [63:0]  rr_outs_regFileValues_13,
    input  wire [63:0]  rr_outs_regFileValues_14,
    input  wire [63:0]  rr_outs_regFileValues_15,
    input  wire [63:0]  rr_outs_regFileValues_16,
    input  wire [63:0]  rr_outs_regFileValues_17,
    input  wire [63:0]  rr_outs_regFileValues_18,
    input  wire [63:0]  rr_outs_regFileValues_19,
    input  wire [63:0]  rr_outs_regFileValues_20,
    input  wire [63:0]  rr_outs_regFileValues_21,
    input  wire [63:0]  rr_outs_regFileValues_22,
    input  wire [63:0]  rr_outs_regFileValues_23,
    input  wire [63:0]  rr_outs_regFileValues_24,
    input  wire [63:0]  rr_outs_regFileValues_25,

    // ====================================================================
    // wb_latches_t (wb_latches_next_o)
    // ====================================================================
    output wire         wb_latches_next_valid,
    output wire         wb_latches_next_cs_ST_OP,
    output wire         wb_latches_next_cs_WB_DR,
    output wire         wb_latches_next_cs_WB_SR,
    output wire         wb_latches_next_cs_WB_EAX,
    output wire         wb_latches_next_ST_XCL,
    output wire [14:0]  wb_latches_next_ST_PADDR_0,
    output wire [15:0]  wb_latches_next_ST_BIT_VEC_0,
    output wire [14:0]  wb_latches_next_ST_PADDR_1,
    output wire [15:0]  wb_latches_next_ST_BIT_VEC_1,
    output wire         wb_latches_next_MIO,
    output wire [31:0]  wb_latches_next_EIP,
    output wire [255:0] wb_latches_next_res_buf,
    output wire [4:0]   wb_latches_next_sr_id,
    output wire [63:0]  wb_latches_next_sr_data,
    output wire [4:0]   wb_latches_next_dr_id,
    output wire [63:0]  wb_latches_next_dr_data,
    output wire [31:0]  wb_latches_next_EAX,

    // ====================================================================
    // exe_outputs_t (outs_o)
    // ====================================================================
    output wire         outs_valid,

    // exe_br_resolution_outputs_t (outs_o.br_res_out)
    // outs_br_res_valid replicated 4-way to break the 77-load fanout: each
    // copy has its own AND_2 driver in branch_res and goes to one consumer
    // cluster.
    output wire         outs_br_res_valid_decode,
    output wire         outs_br_res_valid_btb,
    output wire         outs_br_res_valid_pred,
    output wire         outs_br_res_valid_fetch,
    // outs_br_res_flush replicated 6-way to break the 285-load fanout. Each
    // cluster gets its own dedicated AND_3 in branch_res and routes to a
    // single downstream consumer module via core_structural .vh files.
    output wire         outs_br_res_flush_decode,
    output wire         outs_br_res_flush_fetch,
    output wire         outs_br_res_flush_dc,
    output wire         outs_br_res_flush_mem,
    output wire         outs_br_res_flush_rr,
    output wire         outs_br_res_flush_exe_latches,
    output wire         outs_br_res_farFlush,
    output wire         outs_br_res_callFlush,
    // miss_prediction replicated: external port goes only to Predictor/GShare;
    // the internal copy stays inside branch_res for u_and_outs_flush.
    output wire         outs_br_res_miss_prediction_pred,
    output wire [31:0]  outs_br_res_br_eip,
    output wire [31:0]  outs_br_res_neip,
    output wire [31:0]  outs_br_res_br_target,
    output wire         outs_br_res_taken,
    output wire         outs_br_res_br_XCL,
    output wire         outs_br_res_clr_exp_mode,
    output wire         outs_br_res_br_ucond,

    output wire         outs_DR_0_we,
    output wire [4:0]   outs_DR_0_id,
    output wire [63:0]  outs_DR_0_data,
    output wire         outs_DR_1_we,
    output wire [4:0]   outs_DR_1_id,
    output wire [63:0]  outs_DR_1_data,
    output wire         outs_clr_ZF_sb,
    output wire         outs_ZF,
    output wire         outs_ST_OP,
    output wire         outs_ST_XCL,
    output wire [14:0]  outs_ST_PADDR_0,
    output wire [14:0]  outs_ST_PADDR_1,
    output wire         outs_wb_stage_latch_we
);

    wire [31:0] flags_reg;

    //==========================================================================
    // INPUT-PORT BUFFER NOTES
    //
    // The 3 high-fanout selects (alu_inputA_sel / alu_inputB_sel /
    // branch_target_sel) are now replicated 3-way upstream in EXE_Latches:
    // each replica drives its own EXE input port (`_` / `_b` / `_c`) feeding
    // ONE alu_input_sel instance.  Per-port transitive fanout drops from
    // 1536 to ~512.  MEM_structural.v additionally inserts a bufferH64$ on
    // each select before it reaches the latch flop's D pin.  No per-port
    // buffer tree is needed inside EXE.
    //==========================================================================


    //==========================================================================
    // VALID-LOGIC + STALL FLOP
    //==========================================================================
    wire wb_stage_we_valid_unit_o;
    wire wb_stage_next_vaild_o;
    wb_valid_logic wb_valid_logic_unit (
        .WB_we_o    (wb_stage_we_valid_unit_o),
        .N_WB_V_o   (wb_stage_next_vaild_o),
        .EXE_V_i    (latches_valid),
        .WB_stall_i (wb_outs_wb_stall)
    );

    wire stall_flop;
    `REG_RST(u_stall_flop, 1, clk, rst, wb_outs_wb_stall, stall_flop)


    //==========================================================================
    // REGFILE-VALUE FORWARDING MUX
    //==========================================================================
    // 4-way replicated dr_data / sr_data buffer outputs.  Originally a single
    // bufferH64$ per bit (0.30 ns) drove ~25 transitive loads.  With four
    // dedicated nets a/b/c/d, each replica handles one consumer and uses
    // bufferH16$ (0.24 ns) -- saves 0.06 ns on the RegFile -> ALU/res_buf path.
    //   _a -> u_alu_input_sel_crit / u_res_buf_sel
    //   _b -> u_alu_input_sel_arith
    //   _c -> u_alu_input_sel_ctrl
    //   _d -> u_sr_sel  (sr_data only -- dr_data has u_res_buf_sel here)
    wire [63:0] dr_data_a, dr_data_b, dr_data_c, dr_data_d;
    wire [63:0] sr_data_a, sr_data_b, sr_data_c, sr_data_d;
    wire [31:0] eax_data;

    // Pre-buffer wires; dr_data / sr_data are driven by bufferH16$ below
    // to absorb their fanout (~9 / ~6) into a single H-buffer driver.
    wire [63:0] dr_data_raw;
    wire [63:0] sr_data_raw;

    `MUX_32(u_mux_dr_data, 64, dr_data_raw,
        rr_outs_regFileValues_0,  rr_outs_regFileValues_1,
        rr_outs_regFileValues_2,  rr_outs_regFileValues_3,
        rr_outs_regFileValues_4,  rr_outs_regFileValues_5,
        rr_outs_regFileValues_6,  rr_outs_regFileValues_7,
        rr_outs_regFileValues_8,  rr_outs_regFileValues_9,
        rr_outs_regFileValues_10, rr_outs_regFileValues_11,
        rr_outs_regFileValues_12, rr_outs_regFileValues_13,
        rr_outs_regFileValues_14, rr_outs_regFileValues_15,
        rr_outs_regFileValues_16, rr_outs_regFileValues_17,
        rr_outs_regFileValues_18, rr_outs_regFileValues_19,
        rr_outs_regFileValues_20, rr_outs_regFileValues_21,
        rr_outs_regFileValues_22, rr_outs_regFileValues_23,
        rr_outs_regFileValues_24, rr_outs_regFileValues_25,
        64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0,
        latches_dr_id)

    `MUX_32(u_mux_sr_data, 64, sr_data_raw,
        rr_outs_regFileValues_0,  rr_outs_regFileValues_1,
        rr_outs_regFileValues_2,  rr_outs_regFileValues_3,
        rr_outs_regFileValues_4,  rr_outs_regFileValues_5,
        rr_outs_regFileValues_6,  rr_outs_regFileValues_7,
        rr_outs_regFileValues_8,  rr_outs_regFileValues_9,
        rr_outs_regFileValues_10, rr_outs_regFileValues_11,
        rr_outs_regFileValues_12, rr_outs_regFileValues_13,
        rr_outs_regFileValues_14, rr_outs_regFileValues_15,
        rr_outs_regFileValues_16, rr_outs_regFileValues_17,
        rr_outs_regFileValues_18, rr_outs_regFileValues_19,
        rr_outs_regFileValues_20, rr_outs_regFileValues_21,
        rr_outs_regFileValues_22, rr_outs_regFileValues_23,
        rr_outs_regFileValues_24, rr_outs_regFileValues_25,
        64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0,
        latches_sr_id)

    // 4-way replication: each *_raw[bit] now drives 4 parallel bufferH16$
    // cells (one per consumer cluster).  Source-side fanout per bit is 4
    // (well within rating of any sane upstream cell).  Each replica wire
    // sees ~6-8 pin loads transitively, comfortably within bufferH16$.
    genvar gi_buf_rf;
    generate
        for (gi_buf_rf = 0; gi_buf_rf < 64; gi_buf_rf = gi_buf_rf + 1) begin : g_rf_buf
            bufferH16$ u_buf_dr_a (.out(dr_data_a[gi_buf_rf]), .in(dr_data_raw[gi_buf_rf]));
            bufferH16$ u_buf_dr_b (.out(dr_data_b[gi_buf_rf]), .in(dr_data_raw[gi_buf_rf]));
            bufferH16$ u_buf_dr_c (.out(dr_data_c[gi_buf_rf]), .in(dr_data_raw[gi_buf_rf]));
            bufferH16$ u_buf_dr_d (.out(dr_data_d[gi_buf_rf]), .in(dr_data_raw[gi_buf_rf]));
            bufferH16$ u_buf_sr_a (.out(sr_data_a[gi_buf_rf]), .in(sr_data_raw[gi_buf_rf]));
            bufferH16$ u_buf_sr_b (.out(sr_data_b[gi_buf_rf]), .in(sr_data_raw[gi_buf_rf]));
            bufferH16$ u_buf_sr_c (.out(sr_data_c[gi_buf_rf]), .in(sr_data_raw[gi_buf_rf]));
            bufferH16$ u_buf_sr_d (.out(sr_data_d[gi_buf_rf]), .in(sr_data_raw[gi_buf_rf]));
        end
    endgenerate

    assign eax_data = rr_outs_regFileValues_7[31:0];   // EAX register id = 7


    //==========================================================================
    // CONTROL-NET FANOUT TAPS
    //
    // Replaces the previous BUFFER_DELAY (which uses weak `buffer$`) with
    // explicit bufferH-class cells.  Heavy fanouts are split into sub-taps so
    // each driver lands at <=64 loads (bufferH64$, 0.30 ns) rather than
    // bufferH256$ (0.54 ns), keeping the flag/datapath CP minimal.
    //
    //   op_type:   flagsel (7 sels, ~66 fanout/bit) -> split into _a (4) + _b (3)
    //              datasel (4 mods, ~61 fanout/bit) -> single bufferH64
    //              fu      (2 mods,  low fanout)    -> single bufferH16
    //   data_size: arith   (12 FUs, up to 135/bit)  -> split into _a/_b/_c (4 each)
    //              shift   (sal, sar, ~18/bit)      -> single bufferH64
    //              mem     (4 FUs, up to 149/bit)   -> split: xchg (heavy) / other
    //==========================================================================

    // op_type sub-taps
    wire [5:0] op_type_flagsel_a; // af, cf, df, of flag-sel
    wire [5:0] op_type_flagsel_b; // pf, sf, zf flag-sel
    wire [5:0] op_type_datasel;   // res_buf_sel, dr_sel, sr_sel, reg_wb_logic
    wire [5:0] op_type_fu;        // mov_op, far_jmp_op
    genvar gi_op;
    generate
        for (gi_op = 0; gi_op < 6; gi_op = gi_op + 1) begin : g_op_type_buf
            bufferH64$ u_buf_op_flagsel_a (
                .out(op_type_flagsel_a[gi_op]),
                .in (latches_cs_OP_TYPE[gi_op]));
            bufferH64$ u_buf_op_flagsel_b (
                .out(op_type_flagsel_b[gi_op]),
                .in (latches_cs_OP_TYPE[gi_op]));
            bufferH64$ u_buf_op_datasel (
                .out(op_type_datasel[gi_op]),
                .in (latches_cs_OP_TYPE[gi_op]));
            bufferH16$ u_buf_op_fu (
                .out(op_type_fu[gi_op]),
                .in (latches_cs_OP_TYPE[gi_op]));
        end
    endgenerate

    // data_size sub-taps
    wire [3:0] data_size_arith_a; // adc, add, and, or
    wire [3:0] data_size_arith_b; // sbb, cmp, cmpxchg, not
    wire [3:0] data_size_arith_c; // bsf, mov, movs, add_df
    wire [3:0] data_size_shift;   // sal, sar
    wire [3:0] data_size_mem_xchg;// xchg only (heavy: ~149/bit internal)
    wire [3:0] data_size_mem_oth; // pop, push, bit_vec_logic
    genvar gi_dsz;
    generate
        for (gi_dsz = 0; gi_dsz < 4; gi_dsz = gi_dsz + 1) begin : g_dsz_buf
            bufferH64$ u_buf_dsz_arith_a (
                .out(data_size_arith_a[gi_dsz]),
                .in (latches_data_size_vec[gi_dsz]));
            bufferH64$ u_buf_dsz_arith_b (
                .out(data_size_arith_b[gi_dsz]),
                .in (latches_data_size_vec[gi_dsz]));
            bufferH64$ u_buf_dsz_arith_c (
                .out(data_size_arith_c[gi_dsz]),
                .in (latches_data_size_vec[gi_dsz]));
            bufferH64$ u_buf_dsz_shift (
                .out(data_size_shift[gi_dsz]),
                .in (latches_data_size_vec[gi_dsz]));
            bufferH256$ u_buf_dsz_mem_xchg (
                .out(data_size_mem_xchg[gi_dsz]),
                .in (latches_data_size_vec[gi_dsz]));
            // _oth bit 2 has 117 fanout (mostly bit_vec_logic).  A series
            // pair of bufferH16$ doesn't help -- the final cell still drives
            // 117 leaves.  Single bufferH256$ (0.54 ns) cleanly covers 117.
            // (mem path, not on the cmp/flag critical loop.)
            bufferH256$ u_buf_dsz_mem_oth (
                .out(data_size_mem_oth[gi_dsz]),
                .in (latches_data_size_vec[gi_dsz]));
        end
    endgenerate


    //==========================================================================
    // ALU INPUT SELECTION  --  3-way replication for srA/srB fanout split
    //
    //   srA / srB  (CRIT)  : cmp, cmpxchg, xchg, sal, sar, rep_cmp
    //   srA_arith / srB_arith : adc, add, add_df, and, or, sbb, not, bsf,
    //                           mov, movs
    //   srA_ctrl  / srB_ctrl  : aaa, call*, ret*, pop, push, far_jmp, iretd,
    //                           packssdw/wb, paddd/w, pavgb/w
    //
    //  All three instances are identical combinational copies of alu_input_sel,
    //  driven from the same upstream wires.  Replicating only splits load --
    //  no functional change.  br_sel and exp_ld_buf_o are taken from the
    //  ctrl-cluster instance (single low-fanout consumers each).
    //==========================================================================
    // 4-way sub-ports per alu_input_sel instance.  Each bit was previously
    // buffered by bufferH256$ (0.54 ns) covering up to ~178 transitive loads;
    // splitting to 4 bufferH64$-driven sub-ports drops per-port fanout to
    // ~45/bit and shaves ~0.24 ns off the alu_input_sel -> FU CP.
    //
    //   crit  cluster: cmp,rep_cmp / cmpxchg / sal,sar / xchg
    //   arith cluster: adc,bsf,mov / add,not,movs / add_df,or / and,sbb
    //   ctrl  cluster: aaa,call,far_call,exp_call,far_jmp /
    //                  iretd,ret,ret_imm,ret_far,ret_far_imm /
    //                  pop,push,packssdw,packsswb /
    //                  paddd,paddw,pavgb,pavgw
    wire [63:0] srA_0, srA_1, srA_2, srA_3;
    wire [63:0] srB_0, srB_1, srB_2, srB_3;
    wire [63:0] srA_arith_0, srA_arith_1, srA_arith_2, srA_arith_3;
    wire [63:0] srB_arith_0, srB_arith_1, srB_arith_2, srB_arith_3;
    wire [63:0] srA_ctrl_0,  srA_ctrl_1,  srA_ctrl_2,  srA_ctrl_3;
    wire [63:0] srB_ctrl_0,  srB_ctrl_1,  srB_ctrl_2,  srB_ctrl_3;
    wire [31:0] br_sel;
    wire [63:0] exp_ld_buf_o;
    // unconnected sinks for the unused secondary outputs of the arith/ctrl copies
    wire [31:0] br_sel_arith_unused, br_sel_ctrl_unused;
    wire [63:0] exp_ld_buf_arith_unused;

    alu_input_sel u_alu_input_sel_crit (
        .ld_addr_0      (latches_ld_addy),
        .res_buf_in     (latches_ld_buf),
        .imm64          (latches_imm64),
        .sr_data        (sr_data_a),
        .dr_data        (dr_data_a),
        .EAX            (eax_data),
        .NEIP           (latches_NEIP),
        .EIP            (latches_EIP),
        .flags          (flags_reg),
        .alu_inputA_sel (latches_cs_alu_inputA_sel),
        .alu_inputB_sel (latches_cs_alu_inputB_sel),
        .shift_sr_down  (latches_shift_sr_down),
        .shift_sr_up    (latches_shift_sr_up),
        .br_input_sel   (latches_cs_branch_target_sel),
        .exp_ld_buf_o   (exp_ld_buf_o),
        .srA_64_0       (srA_0),
        .srA_64_1       (srA_1),
        .srA_64_2       (srA_2),
        .srA_64_3       (srA_3),
        .srB_64_0       (srB_0),
        .srB_64_1       (srB_1),
        .srB_64_2       (srB_2),
        .srB_64_3       (srB_3),
        .br_sel         (br_sel)
    );

    alu_input_sel u_alu_input_sel_arith (
        .ld_addr_0      (latches_ld_addy_b),
        .res_buf_in     (latches_ld_buf_b),
        .imm64          (latches_imm64),
        .sr_data        (sr_data_b),
        .dr_data        (dr_data_b),
        .EAX            (eax_data),
        .NEIP           (latches_NEIP),
        .EIP            (latches_EIP),
        .flags          (flags_reg),
        .alu_inputA_sel (latches_cs_alu_inputA_sel_b),
        .alu_inputB_sel (latches_cs_alu_inputB_sel_b),
        .shift_sr_down  (latches_shift_sr_down_b),
        .shift_sr_up    (latches_shift_sr_up_b),
        .br_input_sel   (latches_cs_branch_target_sel_b),
        .exp_ld_buf_o   (exp_ld_buf_arith_unused),
        .srA_64_0       (srA_arith_0),
        .srA_64_1       (srA_arith_1),
        .srA_64_2       (srA_arith_2),
        .srA_64_3       (srA_arith_3),
        .srB_64_0       (srB_arith_0),
        .srB_64_1       (srB_arith_1),
        .srB_64_2       (srB_arith_2),
        .srB_64_3       (srB_arith_3),
        .br_sel         (br_sel_arith_unused)
    );

    alu_input_sel u_alu_input_sel_ctrl (
        .ld_addr_0      (latches_ld_addy_c),
        .res_buf_in     (latches_ld_buf_c),
        .imm64          (latches_imm64),
        .sr_data        (sr_data_c),
        .dr_data        (dr_data_c),
        .EAX            (eax_data),
        .NEIP           (latches_NEIP),
        .EIP            (latches_EIP),
        .flags          (flags_reg),
        .alu_inputA_sel (latches_cs_alu_inputA_sel_c),
        .alu_inputB_sel (latches_cs_alu_inputB_sel_c),
        .shift_sr_down  (latches_shift_sr_down_c),
        .shift_sr_up    (latches_shift_sr_up_c),
        .br_input_sel   (latches_cs_branch_target_sel_c),
        .exp_ld_buf_o   (), // unused: exp_call_op uses ctrl srA but exp_ld_buf from crit
        .srA_64_0       (srA_ctrl_0),
        .srA_64_1       (srA_ctrl_1),
        .srA_64_2       (srA_ctrl_2),
        .srA_64_3       (srA_ctrl_3),
        .srB_64_0       (srB_ctrl_0),
        .srB_64_1       (srB_ctrl_1),
        .srB_64_2       (srB_ctrl_2),
        .srB_64_3       (srB_ctrl_3),
        .br_sel         (br_sel_ctrl_unused)
    );


    //==========================================================================
    // FUNCTIONAL UNIT OUTPUT WIRES
    //==========================================================================
    wire [63:0] aaa_dr_o;
    wire [63:0] adc_dr_o, adc_res_buf_o;
    wire [63:0] add_dr_o, add_res_buf_o;
    wire [63:0] add_df_dr_o, add_df_sr_o;
    wire [63:0] and_dr_o, and_res_buf_o;
    wire [63:0] bsf_dr_o, bsf_res_buf_o;
    wire [63:0] call_sr_o, call_res_buf;
    wire [63:0] cmpxchg_EAX_o, cmpxchg_dr_o, cmpxchg_buf_o;
    wire [63:0] far_call_sr_o, far_call_res_buf, far_call_dr_o;
    wire [63:0] exp_call_sr_o, exp_call_res_buf, exp_call_dr_o;
    wire [31:0] exp_call_eip;
    wire [63:0] iretd_cs_o, iretd_stack_ptr_o;
    wire [63:0] mov_dr_o, mov_res_buf_o;
    wire [63:0] mov_s_dr_o, mov_s_sr_o, mov_s_res_buf_o;
    wire [63:0] not_dr_o, not_res_buf_o;
    wire [63:0] or_dr_o, or_res_buf_o;
    wire [63:0] packssdw_dr_o, packsswb_dr_o;
    wire [63:0] paddd_dr_o, paddw_dr_o;
    wire [63:0] pavgb_dr_o, pavgw_dr_o;
    wire [63:0] pop_dr_o, pop_sr_o, pop_res_buf;
    wire [63:0] push_res_buf, push_sr_o;
    wire [63:0] ret_far_imm_dr_o, ret_far_imm_sr_o;
    wire [63:0] ret_far_cs_o, ret_far_next_ptr_o;
    wire [63:0] ret_imm_sr_o, ret_sr_o;
    wire [63:0] sal_dr_o, sal_res_buf_o;
    wire [63:0] sar_dr_o, sar_res_buf_o;
    wire [63:0] sbb_dr_o, sbb_res_buf_o;
    wire [63:0] xchg_dr_o, xchg_sr_o, xchg_res_buf;
    wire [63:0] far_jmp_dr_o;

    wire aaa_af_o, aaa_cf_o;
    wire adc_af_o, adc_cf_o, adc_of_o, adc_pf_o, adc_sf_o, adc_zf_o;
    wire add_af_o, add_cf_o, add_of_o, add_pf_o, add_sf_o, add_zf_o;
    wire and_of_o, and_pf_o, and_sf_o, and_zf_o, and_cf_o, and_af_o;
    wire bsf_zf_o;
    wire cmp_cf_o, cmp_pf_o, cmp_af_o, cmp_zf_o, cmp_sf_o, cmp_of_o;
    wire cmpxchg_cf_o, cmpxchg_pf_o, cmpxchg_af_o, cmpxchg_zf_o, cmpxchg_sf_o, cmpxchg_of_o;
    wire or_cf_o, or_pf_o, or_zf_o, or_sf_o, or_of_o, or_af_o;
    wire sal_cf_o, sal_pf_o, sal_zf_o, sal_sf_o, sal_of_o, sal_af_o;
    wire sar_cf_o, sar_pf_o, sar_zf_o, sar_sf_o, sar_of_o, sar_af_o;
    wire sbb_cf_o, sbb_pf_o, sbb_af_o, sbb_zf_o, sbb_sf_o, sbb_of_o;
    wire iretd_cf_o, iretd_pf_o, iretd_af_o, iretd_zf_o, iretd_sf_o, iretd_of_o;
    wire rep_cmp_zf_o;


    //==========================================================================
    // RESULT-BUFFER SELECT + LOGIC + BIT-VECTOR
    //==========================================================================
    wire [63:0] res_buf_selected;
    res_buf_sel u_res_buf_sel (
        .op_type            (op_type_datasel),
        .adc_res_buf_i      (adc_res_buf_o),
        .add_res_buf_i      (add_res_buf_o),
        .and_res_buf_i      (and_res_buf_o),
        .call_res_buf_i     (call_res_buf),
        .cmpxchg_buf_i      (cmpxchg_buf_o),
        .far_call_res_buf_i (far_call_res_buf),
        .mov_res_buf_i      (mov_res_buf_o),
        .mov_s_res_buf_i    (mov_s_res_buf_o),
        .not_res_buf_i      (not_res_buf_o),
        .or_res_buf_i       (or_res_buf_o),
        .push_res_buf_i     (push_res_buf),
        .pop_res_buf_i      (pop_res_buf),
        .sar_res_buf_i      (sar_res_buf_o),
        .sal_res_buf_i      (sal_res_buf_o),
        .sbb_res_buf_i      (sbb_res_buf_o),
        .xchg_res_buf_i     (xchg_res_buf),
        .exp_call_res_buf_i (exp_call_res_buf),
        .res_buf_o          (res_buf_selected)
    );

    // res_buf_logic uses ST_PADDR_0 replica _b (dedicated)
    res_buf_logic u_res_buf_logic (
        .res_info_i (res_buf_selected),
        .st_addr_0  (latches_ST_PADDR_0_b),
        .res_buf    (wb_latches_next_res_buf)
    );

    // bit_vec_logic uses ST_PADDR_0 replica _a (default port)
    wire [15:0] bit_vec_0_next;
    wire [15:0] bit_vec_1_next;
    bit_vec_logic u_bit_vec_logic (
        .st_addr_0 (latches_ST_PADDR_0),
        .ST_XCL    (latches_ST_XCL),
        .data_size (data_size_mem_oth),
        .st_vec0   (bit_vec_0_next),
        .st_vec1   (bit_vec_1_next)
    );


    //==========================================================================
    // DR / SR SELECT
    //==========================================================================
    wire [63:0] dr_next;
    dr_sel u_dr_sel (
        .op_type          (op_type_datasel),
        .WB_DR            (latches_wb_cs_WB_DR),
        .aaa_dr_i         (aaa_dr_o),
        .adc_dr_i         (adc_dr_o),
        .add_dr_i         (add_dr_o),
        .add_df_dr_i      (add_df_dr_o),
        .and_dr_i         (and_dr_o),
        .bsf_dr_i         (bsf_dr_o),
        .cmpxchg_dr_i     (cmpxchg_dr_o),
        .mov_dr_i         (mov_dr_o),
        .mov_s_dr_i       (mov_s_dr_o),
        .not_dr_i         (not_dr_o),
        .or_dr_i          (or_dr_o),
        .packssdw_dr_i    (packssdw_dr_o),
        .packsswb_dr_i    (packsswb_dr_o),
        .paddd_dr_i       (paddd_dr_o),
        .paddw_dr_i       (paddw_dr_o),
        .pavgb_dr_i       (pavgb_dr_o),
        .pavgw_dr_i       (pavgw_dr_o),
        .pop_dr_i         (pop_dr_o),
        .ret_far_dr_i     (ret_far_cs_o),
        .ret_far_imm_dr_i (ret_far_imm_dr_o),
        .far_call_dr_i    (far_call_dr_o),
        .far_jmp_dr_i     (far_jmp_dr_o),
        .sal_dr_i         (sal_dr_o),
        .sar_dr_i         (sar_dr_o),
        .sbb_dr_i         (sbb_dr_o),
        .xchg_dr_i        (xchg_dr_o),
        .exp_call_dr_i    (exp_call_dr_o),
        .iretd_cs_dr_i    (iretd_cs_o),
        .dr_data          (dr_data_d),
        .dr_o             (dr_next)
    );

    wire [63:0] sr_next;
    sr_sel u_sr_sel (
        .op_type          (op_type_datasel),
        .WB_SR            (latches_wb_cs_WB_SR),
        .sr_data          (sr_data_d),
        .add_df_sr_i      (add_df_sr_o),
        .mov_s_sr_i       (mov_s_sr_o),
        .pop_sr_i         (pop_sr_o),
        .push_sr_i        (push_sr_o),
        .ret_far_sr_i     (ret_far_next_ptr_o),
        .ret_far_imm_sr_i (ret_far_imm_sr_o),
        .ret_imm_sr_i     (ret_imm_sr_o),
        .ret_sr_i         (ret_sr_o),
        .xchg_sr_i        (xchg_sr_o),
        .call_sr_i        (call_sr_o),
        .far_call_sr_i    (far_call_sr_o),
        .exp_call_sr_i    (exp_call_sr_o),
        .iretd_sr_i       (iretd_stack_ptr_o),
        .sr_o             (sr_next)
    );


    //==========================================================================
    // REGISTER WRITEBACK CONTROL
    //==========================================================================
    wire [4:0]  dr0_id_o, dr1_id_o;
    wire        dr0_we_o, dr1_we_o;
    wire [63:0] dr0_data_o, dr1_data_o;

    wire [63:0] next_EAX;
    `MUX_2(u_next_eax_mux, 64, next_EAX, {32'd0, eax_data}, cmpxchg_EAX_o, latches_wb_cs_WB_EAX)

    // reg_wb uses sr_id / dr_id replica _c (dedicated)
    reg_wb_logic u_reg_wb (
        .op_type      (op_type_datasel),
        .next_dr_data (dr_next),
        .dr_id        (latches_dr_id_c),
        .WB_DR        (latches_wb_cs_WB_DR),
        .next_EAX     (next_EAX),
        .next_sr_data (sr_next),
        .sr_id        (latches_sr_id_c),
        .WB_EAX       (latches_wb_cs_WB_EAX),
        .WB_SR        (latches_wb_cs_WB_SR),
        .valid        (latches_valid),
        .stall_flop   (stall_flop),
        .dr0_id_o     (dr0_id_o),
        .dr0_we_o     (dr0_we_o),
        .dr0_data_o   (dr0_data_o),
        .dr1_id_o     (dr1_id_o),
        .dr1_we_o     (dr1_we_o),
        .dr1_data_o   (dr1_data_o)
    );


    //==========================================================================
    // BRANCH RESOLUTION
    //==========================================================================
    // 4-way replicated valid + 1 external miss_prediction (see branch_res header)
    wire        br_outs_valid_decode_w;
    wire        br_outs_valid_btb_w;
    wire        br_outs_valid_pred_w;
    wire        br_outs_valid_fetch_w;
    wire        br_outs_flush_decode_w;
    wire        br_outs_flush_fetch_w;
    wire        br_outs_flush_dc_w;
    wire        br_outs_flush_mem_w;
    wire        br_outs_flush_rr_w;
    wire        br_outs_flush_exe_latches_w;
    wire        br_outs_farFlush_w;
    wire        br_outs_callFlush_w;
    wire        br_outs_miss_prediction_pred_w;
    wire [31:0] br_outs_br_eip_w;
    wire [31:0] br_outs_neip_w;
    wire [31:0] br_outs_br_target_w;
    wire        br_outs_taken_w;
    wire        br_outs_br_XCL_w;
    wire        br_outs_clr_exp_mode_w;
    wire        br_outs_br_ucond_w;

    branch_res u_br_res (
        .stage_valid_i        (latches_valid),
        .br_info_valid_i      (latches_br_info_valid),
        .flush_mask           (stall_flop),
        .br_eip_i             (latches_br_info_br_eip),
        .br_xcl_i             (latches_br_info_br_xcl),
        .br_pred_taken_i      (latches_br_info_br_pred_taken),
        .speculative_target_i (latches_br_info_speculative_target),
        .br_ucond_i           (latches_cs_br_ucond),
        .relative_branch_i    (latches_cs_relative_branch),
        .special_br_i         (latches_cs_special_br),
        .is_far_i             (latches_cs_is_far),
        .is_call_i            (latches_cs_is_call),
        .second_flag_needed_i (latches_cs_second_flag_needed),
        .br_source_i          (br_sel),
        .NEIP_i               (latches_NEIP),
        .br_rel_target        (latches_br_rel_target),
        .exp_target           (exp_call_eip),
        .CF                   (flags_reg[`EXE_FLAG_CF_IDX]),
        .ZF                   (flags_reg[`EXE_FLAG_ZF_IDX]),
        .outs_valid_to_decode_o          (br_outs_valid_decode_w),
        .outs_valid_to_btb_o             (br_outs_valid_btb_w),
        .outs_valid_to_pred_o            (br_outs_valid_pred_w),
        .outs_valid_to_fetch_o           (br_outs_valid_fetch_w),
        .outs_flush_to_decode_o          (br_outs_flush_decode_w),
        .outs_flush_to_fetch_o           (br_outs_flush_fetch_w),
        .outs_flush_to_dc_o              (br_outs_flush_dc_w),
        .outs_flush_to_mem_o             (br_outs_flush_mem_w),
        .outs_flush_to_rr_o              (br_outs_flush_rr_w),
        .outs_flush_to_exe_latches_o     (br_outs_flush_exe_latches_w),
        .outs_farFlush_o                 (br_outs_farFlush_w),
        .outs_callFlush_o                (br_outs_callFlush_w),
        .outs_miss_prediction_to_pred_o  (br_outs_miss_prediction_pred_w),
        .outs_br_eip_o           (br_outs_br_eip_w),
        .outs_neip_o             (br_outs_neip_w),
        .outs_br_target_o        (br_outs_br_target_w),
        .outs_taken_o            (br_outs_taken_w),
        .outs_br_XCL_o           (br_outs_br_XCL_w),
        .outs_clr_exp_mode_o     (br_outs_clr_exp_mode_w),
        .outs_br_ucond_o         (br_outs_br_ucond_w)
    );


    //==========================================================================
    // FLAGS REGISTER  (REG_RST_WE 32-bit, gated by latches_valid)
    //==========================================================================
    wire af_flag_o;
    wire cf_flag_o;
    wire df_flag_o;
    wire of_flag_o;
    wire pf_flag_o;
    wire sf_flag_o;
    wire zf_flag_o;
    wire clr_ZF_sb;

    wire [31:0] flags_din;
    assign flags_din = {20'b0,
                        of_flag_o,
                        df_flag_o,
                        1'b0, 1'b0,
                        sf_flag_o,
                        zf_flag_o,
                        1'b0,
                        af_flag_o,
                        1'b0,
                        pf_flag_o,
                        1'b0,
                        cf_flag_o};

    // Three identical replicas of the flags register, all driven by the same
    // flags_din / latches_valid / clk / rst.  Splitting fanout per-cluster
    // lets each Q output use a smaller, faster bufferH16$ (0.24 ns typ)
    // instead of one shared bufferH256$ (0.54 ns typ) -- saving ~0.30 ns
    // off every flag read on the critical path.
    //
    //   flags_reg          : 7 flag selectors + branch_res + outs_ZF
    //                        + alu_input_sel x3                  (~13 loads)
    //   flags_reg_alu      : aaa(AF), adc(CF), sbb(CF), mov(CF),
    //                        add_df(DF), movs(DF)                (6 loads)
    //   flags_reg_shift    : sal(6 bits) + sar(6 bits)           (12 loads)
    wire [31:0] flags_reg_raw;
    wire [31:0] flags_reg_alu, flags_reg_alu_raw;
    wire [31:0] flags_reg_shift, flags_reg_shift_raw;

    `REG_RST_WE(u_flags_reg,       32, clk, rst, latches_valid, flags_din, flags_reg_raw)
    `REG_RST_WE(u_flags_reg_alu,   32, clk, rst, latches_valid, flags_din, flags_reg_alu_raw)
    `REG_RST_WE(u_flags_reg_shift, 32, clk, rst, latches_valid, flags_din, flags_reg_shift_raw)

    // bit 10 of flags_reg_alu is DF, consumed only by add_df_op and movs_op,
    // but each of those internally fans DF out to ~64 single-bit MUX_2 selects
    // (gating positive vs negative-step lanes), so transitive fanout is ~192.
    // Upsize JUST that bit to bufferH256$ (0.54 ns).  All other bits (CF, AF,
    // unused) keep bufferH16$ (0.24 ns).  DF is set/cleared only by STD/CLD
    // and is NOT on the cycle-time flag-loop, so the +0.30 ns is non-critical.
    genvar gi_fl;
    generate
        for (gi_fl = 0; gi_fl < 32; gi_fl = gi_fl + 1) begin : g_flags_buf
            bufferH16$ u_buf_fl_main (
                .out(flags_reg[gi_fl]),
                .in (flags_reg_raw[gi_fl]));
            if (gi_fl == `EXE_FLAG_DF_IDX) begin : g_alu_df
                bufferH256$ u_buf_fl_alu (
                    .out(flags_reg_alu[gi_fl]),
                    .in (flags_reg_alu_raw[gi_fl]));
            end else begin : g_alu_other
                bufferH16$ u_buf_fl_alu (
                    .out(flags_reg_alu[gi_fl]),
                    .in (flags_reg_alu_raw[gi_fl]));
            end
            bufferH16$ u_buf_fl_shift (
                .out(flags_reg_shift[gi_fl]),
                .in (flags_reg_shift_raw[gi_fl]));
        end
    endgenerate


    //==========================================================================
    // FLAG SELECTORS
    //==========================================================================
    af_flag_sel u_af_flag_sel (
        .and_af       (and_af_o),
        .or_af        (or_af_o),
        .aaa_af       (aaa_af_o),
        .adc_af       (adc_af_o),
        .add_op_af    (add_af_o),
        .sal_op_af    (sal_af_o),
        .sar_op_af    (sar_af_o),
        .cmp_af       (cmp_af_o),
        .cmpxchg_af   (cmpxchg_af_o),
        .sbb_af       (sbb_af_o),
        .iretd_af     (iretd_af_o),
        .curr_af_flag (flags_reg[`EXE_FLAG_AF_IDX]),
        .op_type      (op_type_flagsel_a),
        .af_flag_o    (af_flag_o)
    );

    cf_flag_sel u_cf_flag_sel (
        .aaa_cf       (aaa_cf_o),
        .adc_cf       (adc_cf_o),
        .add_cf       (add_cf_o),
        .and_cf       (and_cf_o),
        .cmp_cf       (cmp_cf_o),
        .cmpxchg_cf   (cmpxchg_cf_o),
        .or_cf        (or_cf_o),
        .sal_cf       (sal_cf_o),
        .sar_cf       (sar_cf_o),
        .sbb_cf       (sbb_cf_o),
        .iretd_cf     (iretd_cf_o),
        .curr_cf_flag (flags_reg[`EXE_FLAG_CF_IDX]),
        .op_type      (op_type_flagsel_a),
        .cf_flag_o    (cf_flag_o)
    );

    df_flag_sel u_df_flag_sel (
        .curr_df_flag (flags_reg[`EXE_FLAG_DF_IDX]),
        .op_type      (op_type_flagsel_a),
        .df_flag_o    (df_flag_o)
    );

    of_flag_sel u_of_flag_sel (
        .adc_of       (adc_of_o),
        .add_of       (add_of_o),
        .and_of       (and_of_o),
        .cmp_of       (cmp_of_o),
        .cmpxchg_of   (cmpxchg_of_o),
        .or_of        (or_of_o),
        .sal_of       (sal_of_o),
        .sar_of       (sar_of_o),
        .sbb_of       (sbb_of_o),
        .iretd_of     (iretd_of_o),
        .op_type      (op_type_flagsel_a),
        .curr_of_flag (flags_reg[`EXE_FLAG_OF_IDX]),
        .of_flag_o    (of_flag_o)
    );

    pf_flag_sel u_pf_flag_sel (
        .adc_pf       (adc_pf_o),
        .add_pf       (add_pf_o),
        .and_pf       (and_pf_o),
        .cmp_pf       (cmp_pf_o),
        .cmpxchg_pf   (cmpxchg_pf_o),
        .or_pf        (or_pf_o),
        .sal_pf       (sal_pf_o),
        .sar_pf       (sar_pf_o),
        .sbb_pf       (sbb_pf_o),
        .iretd_pf     (iretd_pf_o),
        .op_type      (op_type_flagsel_b),
        .curr_pf_flag (flags_reg[`EXE_FLAG_PF_IDX]),
        .pf_flag_o    (pf_flag_o)
    );

    sf_flag_sel u_sf_flag_sel (
        .add_sf       (add_sf_o),
        .adc_sf       (adc_sf_o),
        .and_sf       (and_sf_o),
        .cmp_sf       (cmp_sf_o),
        .cmpxchg_sf   (cmpxchg_sf_o),
        .or_sf        (or_sf_o),
        .sal_sf       (sal_sf_o),
        .sar_sf       (sar_sf_o),
        .sbb_sf       (sbb_sf_o),
        .iretd_sf     (iretd_sf_o),
        .op_type      (op_type_flagsel_b),
        .curr_sf_flag (flags_reg[`EXE_FLAG_SF_IDX]),
        .sf_flag_o    (sf_flag_o)
    );

    zf_flag_sel u_zf_flag_sel (
        .rep_no_zf_update (latches_cs_rep_no_zf_update),
        .adc_zf           (adc_zf_o),
        .add_zf           (add_zf_o),
        .and_zf           (and_zf_o),
        .bsf_zf           (bsf_zf_o),
        .cmp_zf           (cmp_zf_o),
        .cmpxchg_zf       (cmpxchg_zf_o),
        .iretd_zf         (iretd_zf_o),
        .or_zf            (or_zf_o),
        .sal_zf           (sal_zf_o),
        .sar_zf           (sar_zf_o),
        .sbb_zf           (sbb_zf_o),
        .rep_cmp_zf       (rep_cmp_zf_o),
        .curr_zf_flag     (flags_reg[`EXE_FLAG_ZF_IDX]),
        .op_type          (op_type_flagsel_b),
        .zf_flag_o        (zf_flag_o),
        .clr_ZF_sb        (clr_ZF_sb)
    );


    //==========================================================================
    // NEXT-LATCH ASSIGNMENTS
    //==========================================================================
    assign wb_latches_next_valid        = wb_stage_next_vaild_o;
    assign wb_latches_next_cs_ST_OP     = latches_wb_cs_ST_OP;
    assign wb_latches_next_cs_WB_DR     = latches_wb_cs_WB_DR;
    assign wb_latches_next_cs_WB_SR     = latches_wb_cs_WB_SR;
    assign wb_latches_next_cs_WB_EAX    = latches_wb_cs_WB_EAX;
    assign wb_latches_next_ST_XCL       = latches_ST_XCL;
    assign wb_latches_next_ST_PADDR_0   = latches_ST_PADDR_0_c;
    assign wb_latches_next_ST_BIT_VEC_0 = bit_vec_0_next;
    assign wb_latches_next_ST_PADDR_1   = latches_ST_PADDR_1;
    assign wb_latches_next_ST_BIT_VEC_1 = bit_vec_1_next;
    assign wb_latches_next_MIO          = latches_MIO;
    assign wb_latches_next_EIP          = latches_EIP;
    assign wb_latches_next_sr_id        = latches_sr_id;
    assign wb_latches_next_sr_data      = sr_next;
    assign wb_latches_next_dr_id        = latches_dr_id;
    assign wb_latches_next_dr_data      = dr_next;
    assign wb_latches_next_EAX          = latches_wb_cs_WB_EAX ? cmpxchg_EAX_o[31:0] : eax_data;
    // wb_latches_next_res_buf is driven by res_buf_logic above.

    // outs_o assembly (per-field).
    assign outs_valid               = latches_valid;
    assign outs_br_res_valid_decode = br_outs_valid_decode_w;
    assign outs_br_res_valid_btb    = br_outs_valid_btb_w;
    assign outs_br_res_valid_pred   = br_outs_valid_pred_w;
    assign outs_br_res_valid_fetch  = br_outs_valid_fetch_w;
    assign outs_br_res_flush_decode      = br_outs_flush_decode_w;
    assign outs_br_res_flush_fetch       = br_outs_flush_fetch_w;
    assign outs_br_res_flush_dc          = br_outs_flush_dc_w;
    assign outs_br_res_flush_mem         = br_outs_flush_mem_w;
    assign outs_br_res_flush_rr          = br_outs_flush_rr_w;
    assign outs_br_res_flush_exe_latches = br_outs_flush_exe_latches_w;
    assign outs_br_res_farFlush     = br_outs_farFlush_w;
    assign outs_br_res_callFlush    = br_outs_callFlush_w;
    assign outs_br_res_miss_prediction_pred = br_outs_miss_prediction_pred_w;
    assign outs_br_res_br_eip       = br_outs_br_eip_w;
    assign outs_br_res_neip         = br_outs_neip_w;
    assign outs_br_res_br_target    = br_outs_br_target_w;
    assign outs_br_res_taken        = br_outs_taken_w;
    assign outs_br_res_br_XCL       = br_outs_br_XCL_w;
    assign outs_br_res_clr_exp_mode = br_outs_clr_exp_mode_w;
    assign outs_br_res_br_ucond     = br_outs_br_ucond_w;
    assign outs_DR_0_we             = dr0_we_o;
    assign outs_DR_0_id             = dr0_id_o;
    assign outs_DR_0_data           = dr0_data_o;
    assign outs_DR_1_we             = dr1_we_o;
    assign outs_DR_1_id             = dr1_id_o;
    assign outs_DR_1_data           = dr1_data_o;
    assign outs_ZF                  = flags_reg[`EXE_FLAG_ZF_IDX];
    assign outs_clr_ZF_sb           = clr_ZF_sb && latches_valid;
    assign outs_ST_OP               = latches_cs_ST_OP;
    assign outs_ST_XCL              = latches_ST_XCL;
    assign outs_ST_PADDR_0          = latches_ST_PADDR_0_c;
    assign outs_ST_PADDR_1          = latches_ST_PADDR_1;
    assign outs_wb_stage_latch_we   = wb_stage_we_valid_unit_o;


    //==========================================================================
    // FUNCTIONAL UNITS
    //==========================================================================
    // ---- CTRL cluster: srA_ctrl / srB_ctrl ----
    aaa_op u_aaa (
        .EAX_in    (srA_ctrl_0),
        .AF_flag_in(flags_reg_alu[`EXE_FLAG_AF_IDX]),
        .dr_o      (aaa_dr_o),
        .CF        (aaa_cf_o),
        .AF        (aaa_af_o)
    );

    // ---- ARITH cluster: srA_arith / srB_arith ----
    // ---- ARITH cluster A: adc, add, and, or use data_size_arith_a ----
    adc_op u_adc_op (
        .srA(srA_arith_0), .srB(srB_arith_0),
        .CF_in(flags_reg_alu[`EXE_FLAG_CF_IDX]),
        .data_size(data_size_arith_a),
        .dr_o(adc_dr_o), .res_buf_o(adc_res_buf_o),
        .CF(adc_cf_o), .PF(adc_pf_o), .AF(adc_af_o),
        .ZF(adc_zf_o), .SF(adc_sf_o), .OF(adc_of_o)
    );

    add_op u_add_op (
        .srA(srA_arith_0), .srB(srB_arith_0), .data_size(data_size_arith_a),
        .dr_o(add_dr_o), .res_buf_o(add_res_buf_o),
        .ZF(add_zf_o), .SF(add_sf_o), .PF(add_pf_o),
        .OF(add_of_o), .CF(add_cf_o), .AF(add_af_o)
    );

    // ---- CRIT cluster: srA / srB ----
    rep_cmp u_rep_cmp_op (
        .srA(srA_0), .srB(srB_0),
        .ZF(rep_cmp_zf_o)
    );

    // ---- ARITH cluster C: bsf, mov, movs, add_df use data_size_arith_c ----
    add_df_op u_add_df_op (
        .srA(srA_arith_3), .srB(srB_arith_3),
        .curr_df_flag(flags_reg_alu[`EXE_FLAG_DF_IDX]),
        .data_size(data_size_arith_c),
        .dr_o(add_df_dr_o), .sr_o(add_df_sr_o)
    );

    // ---- ARITH cluster A: and, or use data_size_arith_a ----
    and_op u_and_op (
        .srA(srA_arith_0), .srB(srB_arith_0), .data_size(data_size_arith_a),
        .dr_o(and_dr_o), .res_buf_o(and_res_buf_o),
        .ZF(and_zf_o), .SF(and_sf_o), .PF(and_pf_o),
        .OF(and_of_o), .CF(and_cf_o), .AF(and_af_o)
    );

    // ---- ARITH cluster C: bsf uses data_size_arith_c ----
    bsf_op u_bsf (
        .srA(srA_arith_2), .srB(srB_arith_2), .data_size(data_size_arith_c),
        .dr_o(bsf_dr_o), .res_buf_o(bsf_res_buf_o),
        .ZF(bsf_zf_o)
    );

    // ---- ARITH cluster B: sbb, cmp, cmpxchg, not use data_size_arith_b ----
    cmp u_cmp (
        .srA(srA_0), .srB(srB_0), .data_size(data_size_arith_b),
        .CF(cmp_cf_o), .OF(cmp_of_o), .SF(cmp_sf_o),
        .ZF(cmp_zf_o), .AF(cmp_af_o), .PF(cmp_pf_o)
    );

    cmpxchg_op u_cmpxchg_op (
        .EAX(srB_1[31:0]), .rm(srA_1), .r(srB_1[63:32]),
        .data_size(data_size_arith_b), .sr_data_size_vec(latches_sr_data_size_vec),
        .dr_o(cmpxchg_dr_o), .EAX_o(cmpxchg_EAX_o), .res_buf(cmpxchg_buf_o),
        .ZF(cmpxchg_zf_o), .SF(cmpxchg_sf_o), .PF(cmpxchg_pf_o),
        .CF(cmpxchg_cf_o), .OF(cmpxchg_of_o), .AF(cmpxchg_af_o)
    );

    not_op u_not_op (
        .srA(srA_arith_1), .data_size(data_size_arith_b),
        .dr_o(not_dr_o), .res_buf_o(not_res_buf_o)
    );

    or_op u_or_op (
        .srA(srA_arith_1), .srB(srB_arith_1), .data_size(data_size_arith_a),
        .dr_o(or_dr_o), .res_buf_o(or_res_buf_o),
        .ZF(or_zf_o), .SF(or_sf_o), .PF(or_pf_o),
        .OF(or_of_o), .CF(or_cf_o), .AF(or_af_o)
    );

    // ---- CRIT cluster: shift ops use the dedicated flags_reg_shift replica ----
    sal_op u_sal_op (
        .value_i(srA_2), .shift_amt_i(srB_2),
        .data_size(data_size_shift), .sr_data_size_vec(latches_sr_data_size_vec),
        .shift_by_one(latches_cs_shift_by_one),
        .curr_zf_flag(flags_reg_shift[`EXE_FLAG_ZF_IDX]),
        .curr_sf_flag(flags_reg_shift[`EXE_FLAG_SF_IDX]),
        .curr_pf_flag(flags_reg_shift[`EXE_FLAG_PF_IDX]),
        .curr_of_flag(flags_reg_shift[`EXE_FLAG_OF_IDX]),
        .curr_cf_flag(flags_reg_shift[`EXE_FLAG_CF_IDX]),
        .curr_af_flag(flags_reg_shift[`EXE_FLAG_AF_IDX]),
        .dr_o(sal_dr_o), .res_buf_o(sal_res_buf_o),
        .ZF(sal_zf_o), .SF(sal_sf_o), .PF(sal_pf_o),
        .OF(sal_of_o), .AF(sal_af_o), .CF(sal_cf_o)
    );

    sar_op u_sar_op (
        .value_i(srA_3), .shift_amt_i(srB_3),
        .data_size(data_size_shift), .shift_by_one(latches_cs_shift_by_one),
        .sr_data_size_vec(latches_sr_data_size_vec),
        .curr_zf_flag(flags_reg_shift[`EXE_FLAG_ZF_IDX]),
        .curr_sf_flag(flags_reg_shift[`EXE_FLAG_SF_IDX]),
        .curr_pf_flag(flags_reg_shift[`EXE_FLAG_PF_IDX]),
        .curr_of_flag(flags_reg_shift[`EXE_FLAG_OF_IDX]),
        .curr_cf_flag(flags_reg_shift[`EXE_FLAG_CF_IDX]),
        .curr_af_flag(flags_reg_shift[`EXE_FLAG_AF_IDX]),
        .dr_o(sar_dr_o), .res_buf_o(sar_res_buf_o),
        .ZF(sar_zf_o), .SF(sar_sf_o), .PF(sar_pf_o),
        .OF(sar_of_o), .CF(sar_cf_o), .AF(sar_af_o)
    );

    sbb_op u_sbb_op (
        .srA(srA_arith_1), .srB(srB_arith_1),
        .CF_in(flags_reg_alu[`EXE_FLAG_CF_IDX]),
        .data_size(data_size_arith_b),
        .dr_o(sbb_dr_o), .res_buf_o(sbb_res_buf_o),
        .CF(sbb_cf_o), .PF(sbb_pf_o), .AF(sbb_af_o),
        .ZF(sbb_zf_o), .SF(sbb_sf_o), .OF(sbb_of_o)
    );

    // ---- ARITH cluster C: mov, movs use data_size_arith_c ----
    mov_op u_mov_op (
        .srA(srA_arith_2), .srB(srB_arith_2), .data_size(data_size_arith_c),
        .op_type(op_type_fu),
        .curr_cf_flag(flags_reg_alu[`EXE_FLAG_CF_IDX]),
        .res_buf_o(mov_res_buf_o), .dr_o(mov_dr_o)
    );

    movs_op u_movs_op (
        .srA(srA_arith_2), .srB(srB_arith_2), .data_size(data_size_arith_c),
        .curr_df_flag(flags_reg_alu[`EXE_FLAG_DF_IDX]),
        .res_buf_o(mov_s_res_buf_o), .dr_o(mov_s_dr_o), .sr_o(mov_s_sr_o)
    );

    // ---- CRIT cluster: xchg uses dedicated data_size_mem_xchg (~149 fanout) ----
    // xchg_op uses sr_id / dr_id replica _b (dedicated)
    xchg_op u_xchg_op(
        .srA(srA_1),
        .srB(srB_1),
        .srA_id(latches_dr_id_b),
        .srB_id(latches_sr_id_b),
        .st_op(latches_cs_ST_OP),
        .data_size(data_size_mem_xchg),
        .sr_data_size_vec(latches_sr_data_size_vec),
        .res_buf(xchg_res_buf),
        .dr_o(xchg_dr_o),
        .sr_o(xchg_sr_o)
    );

    // ---- CTRL cluster ----
    call_op u_call_op (
        .NEIP(srA_ctrl_0), .stack_ptr(srB_ctrl_0),
        .sr_o(call_sr_o), .res_buf(call_res_buf)
    );

    far_call_op u_far_op (
        .neip(srA_ctrl_0[31:0]), .segment(srA_ctrl_0[63:32]),
        .stack_ptr(srB_ctrl_0), .new_cs({16'd0, latches_imm64[47:32]}),
        .res_buf(far_call_res_buf), .sr_o(far_call_sr_o), .dr_o(far_call_dr_o)
    );

    exp_call_op u_exp_call_op (
        .idt(exp_ld_buf_o), .eip(srA_ctrl_0[63:32]),
        .curr_cs(rr_outs_codeSeg_data), .stack_ptr(srB_ctrl_0),
        .res_buf(exp_call_res_buf), .dr_o(exp_call_dr_o),
        .sr_o(exp_call_sr_o), .exp_eip(exp_call_eip)
    );

    far_jmp_op u_far_jmp_op (
        .op_type(op_type_fu), .srA(srA_ctrl_0), .dr_o(far_jmp_dr_o)
    );

    iretd_op u_iretd_op (
        .cs(srA_ctrl_1[31:0]), .flags(srA_ctrl_1[63:32]), .stack_ptr(srB_ctrl_1),
        .dr_o(iretd_cs_o), .sr_o(iretd_stack_ptr_o),
        .CF(iretd_cf_o), .PF(iretd_pf_o), .AF(iretd_af_o),
        .ZF(iretd_zf_o), .SF(iretd_sf_o), .OF(iretd_of_o)
    );

    ret_op u_ret_op (.stack_ptr(srB_ctrl_1), .sr_o(ret_sr_o));
    ret_imm_op u_ret_imm_op (.imm64(srA_ctrl_1), .stack_ptr(srB_ctrl_1), .sr_o(ret_imm_sr_o));

    ret_far_op u_ret_far_op (
        .cs(srA_ctrl_1[63:32]), .stack_ptr(srB_ctrl_1),
        .dr_o(ret_far_cs_o), .sr_o(ret_far_next_ptr_o)
    );

    ret_far_imm u_ret_far_imm (
        .cs(srA_ctrl_1[63:32]), .stack_ptr(srB_ctrl_1), .imm64(latches_imm64),
        .dr_o(ret_far_imm_dr_o), .sr_o(ret_far_imm_sr_o)
    );

    pop_op u_pop_op (
        .value_i(srA_ctrl_2), .sp_i(srB_ctrl_2), .curr_dr(latches_dr_data),
        .data_size(data_size_mem_oth),
        .dr_o(pop_dr_o), .sr_o(pop_sr_o), .res_buf(pop_res_buf)
    );

    push_op u_push_op (
        .value(srA_ctrl_2), .sp(srB_ctrl_2), .data_size_vec(data_size_mem_oth),
        .res_buf(push_res_buf), .sr_o(push_sr_o)
    );

    packssdw u_packssdw (.srA(srA_ctrl_2), .srB(srB_ctrl_2), .dr_o(packssdw_dr_o));
    packsswb u_packsswb (.srA(srA_ctrl_2), .srB(srB_ctrl_2), .dr_o(packsswb_dr_o));
    paddd    u_paddd    (.srA(srA_ctrl_3), .srB(srB_ctrl_3), .dr_o(paddd_dr_o));
    paddw    u_paddw    (.srA(srA_ctrl_3), .srB(srB_ctrl_3), .dr_o(paddw_dr_o));
    pavgb    u_pavgb    (.srA(srA_ctrl_3), .srB(srB_ctrl_3), .dr_o(pavgb_dr_o));
    pavgw    u_pavgw    (.srA(srA_ctrl_3), .srB(srB_ctrl_3), .dr_o(pavgw_dr_o));

endmodule
