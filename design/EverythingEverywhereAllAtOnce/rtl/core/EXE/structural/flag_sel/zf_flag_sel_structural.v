// Structural Verilog 2005 port of EXE/flag_sel/zf_flag_sel.sv
// 12-source op_type-driven ZF flag selector with rep_no_zf_update overlay.
// Tristate-mux + 2:1 MUX with effective_match select.
//
//   effective_match = match_any & ~rep_no_zf_update
//   clr_ZF_sb       = effective_match
//   zf_flag_o       = effective_match ? tristated_bus : curr_zf_flag

module zf_flag_sel (
    input  wire rep_no_zf_update,
    input  wire adc_zf,
    input  wire add_zf,
    input  wire and_zf,
    input  wire bsf_zf,
    input  wire cmp_zf,
    input  wire cmpxchg_zf,
    input  wire iretd_zf,
    input  wire or_zf,
    input  wire sal_zf,
    input  wire sar_zf,
    input  wire sbb_zf,
    input  wire rep_cmp_zf,

    input  wire curr_zf_flag,
    input  wire [`EXE_STRUCT_OP_W-1:0] op_type,
    output wire zf_flag_o,
    output wire clr_ZF_sb
);

    wire is_adc, is_add, is_and, is_bsf, is_cmp, is_cmpxchg;
    wire is_or, is_sal, is_sar, is_sbb, is_iretd, is_repcmp;
    `CMP_N(u_cmp_adc,     `EXE_STRUCT_OP_W, is_adc,     op_type, `EXE_OP_ADC)
    `CMP_N(u_cmp_add,     `EXE_STRUCT_OP_W, is_add,     op_type, `EXE_OP_ADD)
    `CMP_N(u_cmp_and,     `EXE_STRUCT_OP_W, is_and,     op_type, `EXE_OP_AND)
    `CMP_N(u_cmp_bsf,     `EXE_STRUCT_OP_W, is_bsf,     op_type, `EXE_OP_BSF)
    `CMP_N(u_cmp_cmp,     `EXE_STRUCT_OP_W, is_cmp,     op_type, `EXE_OP_CMP)
    `CMP_N(u_cmp_cmpxchg, `EXE_STRUCT_OP_W, is_cmpxchg, op_type, `EXE_OP_CMPXCHG)
    `CMP_N(u_cmp_or,      `EXE_STRUCT_OP_W, is_or,      op_type, `EXE_OP_OR)
    `CMP_N(u_cmp_sal,     `EXE_STRUCT_OP_W, is_sal,     op_type, `EXE_OP_SAL)
    `CMP_N(u_cmp_sar,     `EXE_STRUCT_OP_W, is_sar,     op_type, `EXE_OP_SAR)
    `CMP_N(u_cmp_sbb,     `EXE_STRUCT_OP_W, is_sbb,     op_type, `EXE_OP_SBB)
    `CMP_N(u_cmp_iretd,   `EXE_STRUCT_OP_W, is_iretd,   op_type, `EXE_OP_IRETD)
    `CMP_N(u_cmp_repcmp,  `EXE_STRUCT_OP_W, is_repcmp,  op_type, `EXE_OP_REP_CMP)

    // match_any via NAND-NOR tree (12 = 4+4+4, 2 levels)
    wire grp_a_zero, grp_b_zero, grp_c_zero;
    `NOR_4(u_nor_grp_a, 1, grp_a_zero, is_adc, is_add, is_and, is_bsf)
    `NOR_4(u_nor_grp_b, 1, grp_b_zero, is_cmp, is_cmpxchg, is_or, is_sal)
    `NOR_4(u_nor_grp_c, 1, grp_c_zero, is_sar, is_sbb, is_iretd, is_repcmp)
    wire match_any;
    `NAND_3(u_nand_match, 1, match_any, grp_a_zero, grp_b_zero, grp_c_zero)

    // effective_match = match_any & ~rep_no_zf_update
    wire gate;  // gate = ~rep_no_zf_update
    `INV_N(u_inv_rep, 1, rep_no_zf_update, gate)
    wire effective_match;
    `AND_2(u_and_eff_match, 1, effective_match, match_any, gate)
    assign clr_ZF_sb = effective_match;

    // Active-low enables for tristates
    wire enbar_adc, enbar_add, enbar_and, enbar_bsf, enbar_cmp, enbar_cmpxchg;
    wire enbar_or, enbar_sal, enbar_sar, enbar_sbb, enbar_iretd, enbar_repcmp;
    `INV_N(u_inv_adc,     1, is_adc,     enbar_adc)
    `INV_N(u_inv_add,     1, is_add,     enbar_add)
    `INV_N(u_inv_and,     1, is_and,     enbar_and)
    `INV_N(u_inv_bsf,     1, is_bsf,     enbar_bsf)
    `INV_N(u_inv_cmp,     1, is_cmp,     enbar_cmp)
    `INV_N(u_inv_cmpxchg, 1, is_cmpxchg, enbar_cmpxchg)
    `INV_N(u_inv_or,      1, is_or,      enbar_or)
    `INV_N(u_inv_sal,     1, is_sal,     enbar_sal)
    `INV_N(u_inv_sar,     1, is_sar,     enbar_sar)
    `INV_N(u_inv_sbb,     1, is_sbb,     enbar_sbb)
    `INV_N(u_inv_iretd,   1, is_iretd,   enbar_iretd)
    `INV_N(u_inv_repcmp,  1, is_repcmp,  enbar_repcmp)

    wire tristated_bus;
    `TRISTATE_L(u_tri_adc,     1, enbar_adc,     adc_zf,     tristated_bus)
    `TRISTATE_L(u_tri_add,     1, enbar_add,     add_zf,     tristated_bus)
    `TRISTATE_L(u_tri_and,     1, enbar_and,     and_zf,     tristated_bus)
    `TRISTATE_L(u_tri_bsf,     1, enbar_bsf,     bsf_zf,     tristated_bus)
    `TRISTATE_L(u_tri_cmp,     1, enbar_cmp,     cmp_zf,     tristated_bus)
    `TRISTATE_L(u_tri_cmpxchg, 1, enbar_cmpxchg, cmpxchg_zf, tristated_bus)
    `TRISTATE_L(u_tri_or,      1, enbar_or,      or_zf,      tristated_bus)
    `TRISTATE_L(u_tri_sal,     1, enbar_sal,     sal_zf,     tristated_bus)
    `TRISTATE_L(u_tri_sar,     1, enbar_sar,     sar_zf,     tristated_bus)
    `TRISTATE_L(u_tri_sbb,     1, enbar_sbb,     sbb_zf,     tristated_bus)
    `TRISTATE_L(u_tri_iretd,   1, enbar_iretd,   iretd_zf,   tristated_bus)
    `TRISTATE_L(u_tri_repcmp,  1, enbar_repcmp,  rep_cmp_zf, tristated_bus)

    // Final 2:1 mux: effective_match ? tristated_bus : curr_zf_flag
    `MUX_2(u_mux_zf_o, 1, zf_flag_o, curr_zf_flag, tristated_bus, effective_match)

endmodule
