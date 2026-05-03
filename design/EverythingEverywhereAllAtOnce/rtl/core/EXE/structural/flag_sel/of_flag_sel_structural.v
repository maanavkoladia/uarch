// Structural Verilog 2005 port of EXE/flag_sel/of_flag_sel.sv
// 10-source op_type-driven OF flag selector.
// Tristate-mux of matched ops + 2:1 MUX with NAND-NOR match_any.

`include "STDCell_Macros.vh"
`include "exe_structural_defines.vh"

module of_flag_sel (
    input  wire adc_of,
    input  wire add_of,
    input  wire and_of,
    input  wire cmp_of,
    input  wire cmpxchg_of,
    input  wire or_of,
    input  wire sal_of,
    input  wire sar_of,
    input  wire sbb_of,
    input  wire iretd_of,

    input  wire [`EXE_STRUCT_OP_W-1:0] op_type,
    input  wire curr_of_flag,
    output wire of_flag_o
);

    wire is_adc, is_add, is_and, is_cmp, is_cmpxchg;
    wire is_or, is_sal, is_sar, is_sbb, is_iretd;
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

    // match_any via NAND-NOR (10 = 4+3+3, 2 levels)
    wire grp_a_zero, grp_b_zero, grp_c_zero;
    `NOR_4(u_nor_grp_a, 1, grp_a_zero, is_adc, is_add, is_and, is_cmp)
    `NOR_3(u_nor_grp_b, 1, grp_b_zero, is_cmpxchg, is_or, is_sal)
    `NOR_3(u_nor_grp_c, 1, grp_c_zero, is_sar, is_sbb, is_iretd)
    wire match_any;
    `NAND_3(u_nand_match, 1, match_any, grp_a_zero, grp_b_zero, grp_c_zero)

    wire enbar_adc, enbar_add, enbar_and, enbar_cmp, enbar_cmpxchg;
    wire enbar_or, enbar_sal, enbar_sar, enbar_sbb, enbar_iretd;
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
    `TRISTATE_L(u_tri_adc,     1, enbar_adc,     adc_of,     tristated_bus)
    `TRISTATE_L(u_tri_add,     1, enbar_add,     add_of,     tristated_bus)
    `TRISTATE_L(u_tri_and,     1, enbar_and,     and_of,     tristated_bus)
    `TRISTATE_L(u_tri_cmp,     1, enbar_cmp,     cmp_of,     tristated_bus)
    `TRISTATE_L(u_tri_cmpxchg, 1, enbar_cmpxchg, cmpxchg_of, tristated_bus)
    `TRISTATE_L(u_tri_or,      1, enbar_or,      or_of,      tristated_bus)
    `TRISTATE_L(u_tri_sal,     1, enbar_sal,     sal_of,     tristated_bus)
    `TRISTATE_L(u_tri_sar,     1, enbar_sar,     sar_of,     tristated_bus)
    `TRISTATE_L(u_tri_sbb,     1, enbar_sbb,     sbb_of,     tristated_bus)
    `TRISTATE_L(u_tri_iretd,   1, enbar_iretd,   iretd_of,   tristated_bus)

    `MUX_2(u_mux_of_o, 1, of_flag_o, curr_of_flag, tristated_bus, match_any)

endmodule
