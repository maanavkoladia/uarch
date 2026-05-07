// Structural Verilog 2005 port of EXE/flag_sel/af_flag_sel.sv
// 11-source op_type-driven AF flag selector.
// Tristate-mux of matched ops + 2:1 MUX with match_any (NAND-NOR tree) selecting
// between curr_af_flag (passthrough) and the tristated bus.

module af_flag_sel (
    input  wire and_af,
    input  wire or_af,
    input  wire aaa_af,
    input  wire adc_af,
    input  wire add_op_af,
    input  wire sal_op_af,
    input  wire sar_op_af,
    input  wire cmp_af,
    input  wire cmpxchg_af,
    input  wire sbb_af,
    input  wire iretd_af,

    input  wire curr_af_flag,
    input  wire [`EXE_STRUCT_OP_W-1:0] op_type,
    output wire af_flag_o
);

    // ---- One-hot match per matched op_type ----
    wire is_or, is_and, is_sal, is_sar, is_aaa, is_adc, is_add;
    wire is_cmp, is_cmpxchg, is_sbb, is_iretd;
    `CMP_N(u_cmp_or,      `EXE_STRUCT_OP_W, is_or,      op_type, `EXE_OP_OR)
    `CMP_N(u_cmp_and,     `EXE_STRUCT_OP_W, is_and,     op_type, `EXE_OP_AND)
    `CMP_N(u_cmp_sal,     `EXE_STRUCT_OP_W, is_sal,     op_type, `EXE_OP_SAL)
    `CMP_N(u_cmp_sar,     `EXE_STRUCT_OP_W, is_sar,     op_type, `EXE_OP_SAR)
    `CMP_N(u_cmp_aaa,     `EXE_STRUCT_OP_W, is_aaa,     op_type, `EXE_OP_AAA)
    `CMP_N(u_cmp_adc,     `EXE_STRUCT_OP_W, is_adc,     op_type, `EXE_OP_ADC)
    `CMP_N(u_cmp_add,     `EXE_STRUCT_OP_W, is_add,     op_type, `EXE_OP_ADD)
    `CMP_N(u_cmp_cmp,     `EXE_STRUCT_OP_W, is_cmp,     op_type, `EXE_OP_CMP)
    `CMP_N(u_cmp_cmpxchg, `EXE_STRUCT_OP_W, is_cmpxchg, op_type, `EXE_OP_CMPXCHG)
    `CMP_N(u_cmp_sbb,     `EXE_STRUCT_OP_W, is_sbb,     op_type, `EXE_OP_SBB)
    `CMP_N(u_cmp_iretd,   `EXE_STRUCT_OP_W, is_iretd,   op_type, `EXE_OP_IRETD)

    // ---- match_any via NAND-NOR tree (11 = 4 + 4 + 3) ----
    //   group_X_zero = NOR(is_X1..is_X4)  → 1 iff all are 0 (no match in group)
    //   match_any    = NAND(group0_zero, group1_zero, group2_zero)
    //                = 0 iff every group is all-zero (no match)
    //                = 1 iff any group has a 1   (matched)
    wire grp_a_zero, grp_b_zero, grp_c_zero;
    `NOR_4(u_nor_grp_a, 1, grp_a_zero, is_or, is_and, is_sal, is_sar)
    `NOR_4(u_nor_grp_b, 1, grp_b_zero, is_aaa, is_adc, is_add, is_cmp)
    `NOR_3(u_nor_grp_c, 1, grp_c_zero, is_cmpxchg, is_sbb, is_iretd)
    wire match_any;
    `NAND_3(u_nand_match, 1, match_any, grp_a_zero, grp_b_zero, grp_c_zero)

    // ---- Active-low enables (one inverter per matched op) ----
    wire enbar_or, enbar_and, enbar_sal, enbar_sar, enbar_aaa, enbar_adc, enbar_add;
    wire enbar_cmp, enbar_cmpxchg, enbar_sbb, enbar_iretd;
    `INV_N(u_inv_or,      1, is_or,      enbar_or)
    `INV_N(u_inv_and,     1, is_and,     enbar_and)
    `INV_N(u_inv_sal,     1, is_sal,     enbar_sal)
    `INV_N(u_inv_sar,     1, is_sar,     enbar_sar)
    `INV_N(u_inv_aaa,     1, is_aaa,     enbar_aaa)
    `INV_N(u_inv_adc,     1, is_adc,     enbar_adc)
    `INV_N(u_inv_add,     1, is_add,     enbar_add)
    `INV_N(u_inv_cmp,     1, is_cmp,     enbar_cmp)
    `INV_N(u_inv_cmpxchg, 1, is_cmpxchg, enbar_cmpxchg)
    `INV_N(u_inv_sbb,     1, is_sbb,     enbar_sbb)
    `INV_N(u_inv_iretd,   1, is_iretd,   enbar_iretd)

    // ---- Shared 1-bit tristated bus (driven by exactly one tristateL$ when match_any=1) ----
    wire tristated_bus;
    `TRISTATE_L(u_tri_or,      1, enbar_or,      or_af,      tristated_bus)
    `TRISTATE_L(u_tri_and,     1, enbar_and,     and_af,     tristated_bus)
    `TRISTATE_L(u_tri_sal,     1, enbar_sal,     sal_op_af,  tristated_bus)
    `TRISTATE_L(u_tri_sar,     1, enbar_sar,     sar_op_af,  tristated_bus)
    `TRISTATE_L(u_tri_aaa,     1, enbar_aaa,     aaa_af,     tristated_bus)
    `TRISTATE_L(u_tri_adc,     1, enbar_adc,     adc_af,     tristated_bus)
    `TRISTATE_L(u_tri_add,     1, enbar_add,     add_op_af,  tristated_bus)
    `TRISTATE_L(u_tri_cmp,     1, enbar_cmp,     cmp_af,     tristated_bus)
    `TRISTATE_L(u_tri_cmpxchg, 1, enbar_cmpxchg, cmpxchg_af, tristated_bus)
    `TRISTATE_L(u_tri_sbb,     1, enbar_sbb,     sbb_af,     tristated_bus)
    `TRISTATE_L(u_tri_iretd,   1, enbar_iretd,   iretd_af,   tristated_bus)

    // ---- Final 2:1 mux: match_any ? tristated_bus : curr_af_flag ----
    `MUX_2(u_mux_af_o, 1, af_flag_o, curr_af_flag, tristated_bus, match_any)

endmodule
