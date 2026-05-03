// Structural Verilog 2005 port of EXE/flag_sel/cf_flag_sel.sv
// 11-source op_type-driven CF flag selector.
// Tristate-mux of matched ops + 2:1 MUX with NAND-NOR match_any.

`include "STDCell_Macros.vh"
`include "exe_structural_defines.vh"

module cf_flag_sel (
    input  wire aaa_cf,
    input  wire adc_cf,
    input  wire add_cf,
    input  wire and_cf,
    input  wire cmp_cf,
    input  wire cmpxchg_cf,
    input  wire or_cf,
    input  wire sal_cf,
    input  wire sar_cf,
    input  wire sbb_cf,
    input  wire iretd_cf,

    input  wire curr_cf_flag,
    input  wire [`EXE_STRUCT_OP_W-1:0] op_type,
    output wire cf_flag_o
);

    wire is_aaa, is_adc, is_add, is_and, is_cmp, is_cmpxchg;
    wire is_or, is_sal, is_sar, is_sbb, is_iretd;
    `CMP_N(u_cmp_aaa,     `EXE_STRUCT_OP_W, is_aaa,     op_type, `EXE_OP_AAA)
    `CMP_N(u_cmp_adc,     `EXE_STRUCT_OP_W, is_adc,     op_type, `EXE_OP_ADC)
    `CMP_N(u_cmp_add,     `EXE_STRUCT_OP_W, is_add,     op_type, `EXE_OP_ADD)
    `CMP_N(u_cmp_and,     `EXE_STRUCT_OP_W, is_and,     op_type, `EXE_OP_AND)
    `CMP_N(u_cmp_cmp,     `EXE_STRUCT_OP_W, is_cmp,     op_type, `EXE_OP_CMP)
    `CMP_N(u_cmp_cmpxchg, `EXE_STRUCT_OP_W, is_cmpxchg, op_type, `EXE_OP_CMPXCHG)
    `CMP_N(u_cmp_or,      `EXE_STRUCT_OP_W, is_or,      op_type, `EXE_OP_OR)
    `CMP_N(u_cmp_sal,     `EXE_STRUCT_OP_W, is_sal,     op_type, `EXE_OP_SAL)
    `CMP_N(u_cmp_sar,     `EXE_STRUCT_OP_W, is_sar,     op_type, `EXE_OP_SAR)
    `CMP_N(u_cmp_sbb,     `EXE_STRUCT_OP_W, is_sbb,     op_type, `EXE_OP_SBB)
    `CMP_N(u_cmp_iretd,   `EXE_STRUCT_OP_W, is_iretd,   op_type, `EXE_OP_IRETD)

    // match_any via NAND-NOR (11 = 4+4+3, 2 levels)
    wire grp_a_zero, grp_b_zero, grp_c_zero;
    `NOR_4(u_nor_grp_a, 1, grp_a_zero, is_aaa, is_adc, is_add, is_and)
    `NOR_4(u_nor_grp_b, 1, grp_b_zero, is_cmp, is_cmpxchg, is_or, is_sal)
    `NOR_3(u_nor_grp_c, 1, grp_c_zero, is_sar, is_sbb, is_iretd)
    wire match_any;
    `NAND_3(u_nand_match, 1, match_any, grp_a_zero, grp_b_zero, grp_c_zero)

    wire enbar_aaa, enbar_adc, enbar_add, enbar_and, enbar_cmp, enbar_cmpxchg;
    wire enbar_or, enbar_sal, enbar_sar, enbar_sbb, enbar_iretd;
    `INV_N(u_inv_aaa,     1, is_aaa,     enbar_aaa)
    `INV_N(u_inv_adc,     1, is_adc,     enbar_adc)
    `INV_N(u_inv_add,     1, is_add,     enbar_add)
    `INV_N(u_inv_and,     1, is_and,     enbar_and)
    `INV_N(u_inv_cmp,     1, is_cmp,     enbar_cmp)
    `INV_N(u_inv_cmpxchg, 1, is_cmpxchg, enbar_cmpxchg)
    `INV_N(u_inv_or,      1, is_or,      enbar_or)
    `INV_N(u_inv_sal,     1, is_sal,     enbar_sal)
    `INV_N(u_inv_sar,     1, is_sar,     enbar_sar)
    `INV_N(u_inv_sbb,     1, is_sbb,     enbar_sbb)
    `INV_N(u_inv_iretd,   1, is_iretd,   enbar_iretd)

    wire tristated_bus;
    `TRISTATE_L(u_tri_aaa,     1, enbar_aaa,     aaa_cf,     tristated_bus)
    `TRISTATE_L(u_tri_adc,     1, enbar_adc,     adc_cf,     tristated_bus)
    `TRISTATE_L(u_tri_add,     1, enbar_add,     add_cf,     tristated_bus)
    `TRISTATE_L(u_tri_and,     1, enbar_and,     and_cf,     tristated_bus)
    `TRISTATE_L(u_tri_cmp,     1, enbar_cmp,     cmp_cf,     tristated_bus)
    `TRISTATE_L(u_tri_cmpxchg, 1, enbar_cmpxchg, cmpxchg_cf, tristated_bus)
    `TRISTATE_L(u_tri_or,      1, enbar_or,      or_cf,      tristated_bus)
    `TRISTATE_L(u_tri_sal,     1, enbar_sal,     sal_cf,     tristated_bus)
    `TRISTATE_L(u_tri_sar,     1, enbar_sar,     sar_cf,     tristated_bus)
    `TRISTATE_L(u_tri_sbb,     1, enbar_sbb,     sbb_cf,     tristated_bus)
    `TRISTATE_L(u_tri_iretd,   1, enbar_iretd,   iretd_cf,   tristated_bus)

    `MUX_2(u_mux_cf_o, 1, cf_flag_o, curr_cf_flag, tristated_bus, match_any)

endmodule
