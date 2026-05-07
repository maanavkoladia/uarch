// Structural Verilog 2005 port of EXE/dr_sel.sv
// Tristate-mux of all matched op_types, then a 2:1 MUX selects between the
// tristated bus and dr_data based on WB_DR. When WB_DR=0, dr_data passes
// through (no need to compute match_any from a wide OR tree).
//
// 28 op_type cases drive 26 unique data sources:
//   MOV and CMOVC share mov_dr_i;  FAR_JMP32 and FAR_JMP16 share far_jmp_dr_i.

module dr_sel (
    input  wire [`EXE_STRUCT_OP_W-1:0] op_type,
    input  wire                        WB_DR,    // mux select for final stage

    input  wire [63:0] aaa_dr_i,
    input  wire [63:0] adc_dr_i,
    input  wire [63:0] add_dr_i,
    input  wire [63:0] add_df_dr_i,
    input  wire [63:0] and_dr_i,
    input  wire [63:0] bsf_dr_i,
    input  wire [63:0] cmpxchg_dr_i,
    input  wire [63:0] mov_dr_i,        // shared by MOV and CMOVC
    input  wire [63:0] mov_s_dr_i,
    input  wire [63:0] not_dr_i,
    input  wire [63:0] or_dr_i,
    input  wire [63:0] packssdw_dr_i,
    input  wire [63:0] packsswb_dr_i,
    input  wire [63:0] paddd_dr_i,
    input  wire [63:0] paddw_dr_i,
    input  wire [63:0] pavgb_dr_i,
    input  wire [63:0] pavgw_dr_i,
    input  wire [63:0] pop_dr_i,
    input  wire [63:0] ret_far_dr_i,
    input  wire [63:0] ret_far_imm_dr_i,
    input  wire [63:0] far_call_dr_i,
    input  wire [63:0] far_jmp_dr_i,    // shared by FAR_JMP32/FAR_JMP16
    input  wire [63:0] sal_dr_i,
    input  wire [63:0] sar_dr_i,
    input  wire [63:0] sbb_dr_i,
    input  wire [63:0] xchg_dr_i,
    input  wire [63:0] exp_call_dr_i,
    input  wire [63:0] iretd_cs_dr_i,
    input  wire [63:0] dr_data,

    output wire [63:0] dr_o
);

    // ---- One-hot match per matched op_type ----
    wire is_aaa, is_adc, is_add, is_add_df, is_and, is_bsf, is_cmpxchg;
    wire is_mov, is_movs, is_cmovc, is_not, is_or;
    wire is_packssdw, is_packsswb, is_paddd, is_paddw, is_pavgb, is_pavgw;
    wire is_pop, is_ret_far, is_ret_far_imm, is_far_call;
    wire is_far_jmp32, is_far_jmp16;
    wire is_sal, is_sar, is_sbb, is_xchg, is_exp_call, is_iretd;

    `CMP_N(u_cmp_aaa,         `EXE_STRUCT_OP_W, is_aaa,         op_type, `EXE_OP_AAA)
    `CMP_N(u_cmp_adc,         `EXE_STRUCT_OP_W, is_adc,         op_type, `EXE_OP_ADC)
    `CMP_N(u_cmp_add,         `EXE_STRUCT_OP_W, is_add,         op_type, `EXE_OP_ADD)
    `CMP_N(u_cmp_add_df,      `EXE_STRUCT_OP_W, is_add_df,      op_type, `EXE_OP_ADD_DF)
    `CMP_N(u_cmp_and,         `EXE_STRUCT_OP_W, is_and,         op_type, `EXE_OP_AND)
    `CMP_N(u_cmp_bsf,         `EXE_STRUCT_OP_W, is_bsf,         op_type, `EXE_OP_BSF)
    `CMP_N(u_cmp_cmpxchg,     `EXE_STRUCT_OP_W, is_cmpxchg,     op_type, `EXE_OP_CMPXCHG)
    `CMP_N(u_cmp_mov,         `EXE_STRUCT_OP_W, is_mov,         op_type, `EXE_OP_MOV)
    `CMP_N(u_cmp_movs,        `EXE_STRUCT_OP_W, is_movs,        op_type, `EXE_OP_MOVS)
    `CMP_N(u_cmp_cmovc,       `EXE_STRUCT_OP_W, is_cmovc,       op_type, `EXE_OP_CMOVC)
    `CMP_N(u_cmp_not,         `EXE_STRUCT_OP_W, is_not,         op_type, `EXE_OP_NOT)
    `CMP_N(u_cmp_or,          `EXE_STRUCT_OP_W, is_or,          op_type, `EXE_OP_OR)
    `CMP_N(u_cmp_packssdw,    `EXE_STRUCT_OP_W, is_packssdw,    op_type, `EXE_OP_PACKSSDW)
    `CMP_N(u_cmp_packsswb,    `EXE_STRUCT_OP_W, is_packsswb,    op_type, `EXE_OP_PACKSSWB)
    `CMP_N(u_cmp_paddd,       `EXE_STRUCT_OP_W, is_paddd,       op_type, `EXE_OP_PADDD)
    `CMP_N(u_cmp_paddw,       `EXE_STRUCT_OP_W, is_paddw,       op_type, `EXE_OP_PADDW)
    `CMP_N(u_cmp_pavgb,       `EXE_STRUCT_OP_W, is_pavgb,       op_type, `EXE_OP_PAVGB)
    `CMP_N(u_cmp_pavgw,       `EXE_STRUCT_OP_W, is_pavgw,       op_type, `EXE_OP_PAVGW)
    `CMP_N(u_cmp_pop,         `EXE_STRUCT_OP_W, is_pop,         op_type, `EXE_OP_POP)
    `CMP_N(u_cmp_ret_far,     `EXE_STRUCT_OP_W, is_ret_far,     op_type, `EXE_OP_RET_FAR)
    `CMP_N(u_cmp_ret_far_imm, `EXE_STRUCT_OP_W, is_ret_far_imm, op_type, `EXE_OP_RET_FAR_IMM)
    `CMP_N(u_cmp_far_call,    `EXE_STRUCT_OP_W, is_far_call,    op_type, `EXE_OP_FAR_CALL)
    `CMP_N(u_cmp_far_jmp32,   `EXE_STRUCT_OP_W, is_far_jmp32,   op_type, `EXE_OP_FAR_JMP32)
    `CMP_N(u_cmp_far_jmp16,   `EXE_STRUCT_OP_W, is_far_jmp16,   op_type, `EXE_OP_FAR_JMP16)
    `CMP_N(u_cmp_sal,         `EXE_STRUCT_OP_W, is_sal,         op_type, `EXE_OP_SAL)
    `CMP_N(u_cmp_sar,         `EXE_STRUCT_OP_W, is_sar,         op_type, `EXE_OP_SAR)
    `CMP_N(u_cmp_sbb,         `EXE_STRUCT_OP_W, is_sbb,         op_type, `EXE_OP_SBB)
    `CMP_N(u_cmp_xchg,        `EXE_STRUCT_OP_W, is_xchg,        op_type, `EXE_OP_XCHG)
    `CMP_N(u_cmp_exp_call,    `EXE_STRUCT_OP_W, is_exp_call,    op_type, `EXE_OP_EXP_CALL)
    `CMP_N(u_cmp_iretd,    `EXE_STRUCT_OP_W, is_iretd,        op_type, `EXE_OP_IRETD)



    // ---- Shared-input enables (active high) for ops that drive same source ----
    wire en_mov, en_far_jmp;
    `OR_2(u_or_mov_cmovc, 1, en_mov,     is_mov,       is_cmovc)
    `OR_2(u_or_far_jmp,   1, en_far_jmp, is_far_jmp32, is_far_jmp16)

    // ---- Active-low enables (one inverter per unique data source) ----
    wire enbar_aaa, enbar_adc, enbar_add, enbar_add_df, enbar_and, enbar_bsf, enbar_cmpxchg;
    wire enbar_mov, enbar_movs, enbar_not, enbar_or;
    wire enbar_packssdw, enbar_packsswb, enbar_paddd, enbar_paddw, enbar_pavgb, enbar_pavgw;
    wire enbar_pop, enbar_ret_far, enbar_ret_far_imm, enbar_far_call, enbar_far_jmp;
    wire enbar_sal, enbar_sar, enbar_sbb, enbar_xchg, enbar_exp_call, enbar_iretd;

    // Each enbar_* drives a 64-bit TRISTATE_L's enable pin (fanout=64). INV_N
    // expands to bufferHInv16$ (rated 16) — too small. bufferHInv64$ is rated
    // 64 and 0.39 ns typ, faster than a 2-stage HInv16->H64 chain (~0.45 ns).
    // Logic preserved: bufferHInv64$ inverts the same way INV_N's HInv16 did.
    bufferHInv64$ u_inv_aaa         (.out(enbar_aaa),         .in(is_aaa));
    bufferHInv64$ u_inv_adc         (.out(enbar_adc),         .in(is_adc));
    bufferHInv64$ u_inv_add         (.out(enbar_add),         .in(is_add));
    bufferHInv64$ u_inv_add_df      (.out(enbar_add_df),      .in(is_add_df));
    bufferHInv64$ u_inv_and         (.out(enbar_and),         .in(is_and));
    bufferHInv64$ u_inv_bsf         (.out(enbar_bsf),         .in(is_bsf));
    bufferHInv64$ u_inv_cmpxchg     (.out(enbar_cmpxchg),     .in(is_cmpxchg));
    bufferHInv64$ u_inv_mov         (.out(enbar_mov),         .in(en_mov));
    bufferHInv64$ u_inv_movs        (.out(enbar_movs),        .in(is_movs));
    bufferHInv64$ u_inv_not         (.out(enbar_not),         .in(is_not));
    bufferHInv64$ u_inv_or          (.out(enbar_or),          .in(is_or));
    bufferHInv64$ u_inv_packssdw    (.out(enbar_packssdw),    .in(is_packssdw));
    bufferHInv64$ u_inv_packsswb    (.out(enbar_packsswb),    .in(is_packsswb));
    bufferHInv64$ u_inv_paddd       (.out(enbar_paddd),       .in(is_paddd));
    bufferHInv64$ u_inv_paddw       (.out(enbar_paddw),       .in(is_paddw));
    bufferHInv64$ u_inv_pavgb       (.out(enbar_pavgb),       .in(is_pavgb));
    bufferHInv64$ u_inv_pavgw       (.out(enbar_pavgw),       .in(is_pavgw));
    bufferHInv64$ u_inv_pop         (.out(enbar_pop),         .in(is_pop));
    bufferHInv64$ u_inv_ret_far     (.out(enbar_ret_far),     .in(is_ret_far));
    bufferHInv64$ u_inv_ret_far_imm (.out(enbar_ret_far_imm), .in(is_ret_far_imm));
    bufferHInv64$ u_inv_far_call    (.out(enbar_far_call),    .in(is_far_call));
    bufferHInv64$ u_inv_far_jmp     (.out(enbar_far_jmp),     .in(en_far_jmp));
    bufferHInv64$ u_inv_sal         (.out(enbar_sal),         .in(is_sal));
    bufferHInv64$ u_inv_sar         (.out(enbar_sar),         .in(is_sar));
    bufferHInv64$ u_inv_sbb         (.out(enbar_sbb),         .in(is_sbb));
    bufferHInv64$ u_inv_xchg        (.out(enbar_xchg),        .in(is_xchg));
    bufferHInv64$ u_inv_exp_call    (.out(enbar_exp_call),    .in(is_exp_call));
    bufferHInv64$ u_inv_iretd       (.out(enbar_iretd),       .in(is_iretd));

    // ---- Shared tristated bus, driven by exactly one of 26 tristateL$ when WB_DR=1 ----
    wire [63:0] tristated_bus;

    `TRISTATE_L(u_tri_aaa,         64, enbar_aaa,         aaa_dr_i,         tristated_bus)
    `TRISTATE_L(u_tri_adc,         64, enbar_adc,         adc_dr_i,         tristated_bus)
    `TRISTATE_L(u_tri_add,         64, enbar_add,         add_dr_i,         tristated_bus)
    `TRISTATE_L(u_tri_add_df,      64, enbar_add_df,      add_df_dr_i,      tristated_bus)
    `TRISTATE_L(u_tri_and,         64, enbar_and,         and_dr_i,         tristated_bus)
    `TRISTATE_L(u_tri_bsf,         64, enbar_bsf,         bsf_dr_i,         tristated_bus)
    `TRISTATE_L(u_tri_cmpxchg,     64, enbar_cmpxchg,     cmpxchg_dr_i,     tristated_bus)
    `TRISTATE_L(u_tri_mov,         64, enbar_mov,         mov_dr_i,         tristated_bus)
    `TRISTATE_L(u_tri_movs,        64, enbar_movs,        mov_s_dr_i,       tristated_bus)
    `TRISTATE_L(u_tri_not,         64, enbar_not,         not_dr_i,         tristated_bus)
    `TRISTATE_L(u_tri_or,          64, enbar_or,          or_dr_i,          tristated_bus)
    `TRISTATE_L(u_tri_packssdw,    64, enbar_packssdw,    packssdw_dr_i,    tristated_bus)
    `TRISTATE_L(u_tri_packsswb,    64, enbar_packsswb,    packsswb_dr_i,    tristated_bus)
    `TRISTATE_L(u_tri_paddd,       64, enbar_paddd,       paddd_dr_i,       tristated_bus)
    `TRISTATE_L(u_tri_paddw,       64, enbar_paddw,       paddw_dr_i,       tristated_bus)
    `TRISTATE_L(u_tri_pavgb,       64, enbar_pavgb,       pavgb_dr_i,       tristated_bus)
    `TRISTATE_L(u_tri_pavgw,       64, enbar_pavgw,       pavgw_dr_i,       tristated_bus)
    `TRISTATE_L(u_tri_pop,         64, enbar_pop,         pop_dr_i,         tristated_bus)
    `TRISTATE_L(u_tri_ret_far,     64, enbar_ret_far,     ret_far_dr_i,     tristated_bus)
    `TRISTATE_L(u_tri_ret_far_imm, 64, enbar_ret_far_imm, ret_far_imm_dr_i, tristated_bus)
    `TRISTATE_L(u_tri_far_call,    64, enbar_far_call,    far_call_dr_i,    tristated_bus)
    `TRISTATE_L(u_tri_far_jmp,     64, enbar_far_jmp,     far_jmp_dr_i,     tristated_bus)
    `TRISTATE_L(u_tri_sal,         64, enbar_sal,         sal_dr_i,         tristated_bus)
    `TRISTATE_L(u_tri_sar,         64, enbar_sar,         sar_dr_i,         tristated_bus)
    `TRISTATE_L(u_tri_sbb,         64, enbar_sbb,         sbb_dr_i,         tristated_bus)
    `TRISTATE_L(u_tri_xchg,        64, enbar_xchg,        xchg_dr_i,        tristated_bus)
    `TRISTATE_L(u_tri_exp_call,    64, enbar_exp_call,    exp_call_dr_i,    tristated_bus)
    `TRISTATE_L(u_tri_iretd,       64, enbar_iretd,       iretd_cs_dr_i,    tristated_bus)

    // ---- Final 2:1 mux: WB_DR ? tristated_bus : dr_data ----
    // The mux2$ output drives 27 cells/bit downstream (dr_data fwd to 3
    // alu_input_sel + reg_wb).  Wrap each output bit in bufferH64$ (0.30 ns).
    wire [63:0] dr_o_raw;
    `MUX_2(u_mux_dr_o, 64, dr_o_raw, dr_data, tristated_bus, WB_DR)

    genvar gi_dr_o;
    generate
        for (gi_dr_o = 0; gi_dr_o < 64; gi_dr_o = gi_dr_o + 1) begin : g_dr_o_buf
            bufferH64$ u_buf_dr_o (.out(dr_o[gi_dr_o]), .in(dr_o_raw[gi_dr_o]));
        end
    endgenerate

endmodule
