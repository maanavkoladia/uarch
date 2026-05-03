// Structural Verilog 2005 port of EXE/dr_sel.sv
// Tristate-mux of all matched op_types, then a 2:1 MUX selects between the
// tristated bus and dr_data based on WB_DR. When WB_DR=0, dr_data passes
// through (no need to compute match_any from a wide OR tree).
//
// 28 op_type cases drive 26 unique data sources:
//   MOV and CMOVC share mov_dr_i;  FAR_JMP32 and FAR_JMP16 share far_jmp_dr_i.

`include "STDCell_Macros.vh"
`include "exe_structural_defines.vh"

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
    input  wire [63:0] dr_data,

    output wire [63:0] dr_o
);

    // ---- One-hot match per matched op_type ----
    wire is_aaa, is_adc, is_add, is_add_df, is_and, is_bsf, is_cmpxchg;
    wire is_mov, is_movs, is_cmovc, is_not, is_or;
    wire is_packssdw, is_packsswb, is_paddd, is_paddw, is_pavgb, is_pavgw;
    wire is_pop, is_ret_far, is_ret_far_imm, is_far_call;
    wire is_far_jmp32, is_far_jmp16;
    wire is_sal, is_sar, is_sbb, is_xchg, is_exp_call;

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

    // ---- Shared-input enables (active high) for ops that drive same source ----
    wire en_mov, en_far_jmp;
    `OR_2(u_or_mov_cmovc, 1, en_mov,     is_mov,       is_cmovc)
    `OR_2(u_or_far_jmp,   1, en_far_jmp, is_far_jmp32, is_far_jmp16)

    // ---- Active-low enables (one inverter per unique data source) ----
    wire enbar_aaa, enbar_adc, enbar_add, enbar_add_df, enbar_and, enbar_bsf, enbar_cmpxchg;
    wire enbar_mov, enbar_movs, enbar_not, enbar_or;
    wire enbar_packssdw, enbar_packsswb, enbar_paddd, enbar_paddw, enbar_pavgb, enbar_pavgw;
    wire enbar_pop, enbar_ret_far, enbar_ret_far_imm, enbar_far_call, enbar_far_jmp;
    wire enbar_sal, enbar_sar, enbar_sbb, enbar_xchg, enbar_exp_call;

    `INV_N(u_inv_aaa,         1, is_aaa,         enbar_aaa)
    `INV_N(u_inv_adc,         1, is_adc,         enbar_adc)
    `INV_N(u_inv_add,         1, is_add,         enbar_add)
    `INV_N(u_inv_add_df,      1, is_add_df,      enbar_add_df)
    `INV_N(u_inv_and,         1, is_and,         enbar_and)
    `INV_N(u_inv_bsf,         1, is_bsf,         enbar_bsf)
    `INV_N(u_inv_cmpxchg,     1, is_cmpxchg,     enbar_cmpxchg)
    `INV_N(u_inv_mov,         1, en_mov,         enbar_mov)
    `INV_N(u_inv_movs,        1, is_movs,        enbar_movs)
    `INV_N(u_inv_not,         1, is_not,         enbar_not)
    `INV_N(u_inv_or,          1, is_or,          enbar_or)
    `INV_N(u_inv_packssdw,    1, is_packssdw,    enbar_packssdw)
    `INV_N(u_inv_packsswb,    1, is_packsswb,    enbar_packsswb)
    `INV_N(u_inv_paddd,       1, is_paddd,       enbar_paddd)
    `INV_N(u_inv_paddw,       1, is_paddw,       enbar_paddw)
    `INV_N(u_inv_pavgb,       1, is_pavgb,       enbar_pavgb)
    `INV_N(u_inv_pavgw,       1, is_pavgw,       enbar_pavgw)
    `INV_N(u_inv_pop,         1, is_pop,         enbar_pop)
    `INV_N(u_inv_ret_far,     1, is_ret_far,     enbar_ret_far)
    `INV_N(u_inv_ret_far_imm, 1, is_ret_far_imm, enbar_ret_far_imm)
    `INV_N(u_inv_far_call,    1, is_far_call,    enbar_far_call)
    `INV_N(u_inv_far_jmp,     1, en_far_jmp,     enbar_far_jmp)
    `INV_N(u_inv_sal,         1, is_sal,         enbar_sal)
    `INV_N(u_inv_sar,         1, is_sar,         enbar_sar)
    `INV_N(u_inv_sbb,         1, is_sbb,         enbar_sbb)
    `INV_N(u_inv_xchg,        1, is_xchg,        enbar_xchg)
    `INV_N(u_inv_exp_call,    1, is_exp_call,    enbar_exp_call)

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

    // ---- Final 2:1 mux: WB_DR ? tristated_bus : dr_data ----
    `MUX_2(u_mux_dr_o, 64, dr_o, dr_data, tristated_bus, WB_DR)

endmodule
