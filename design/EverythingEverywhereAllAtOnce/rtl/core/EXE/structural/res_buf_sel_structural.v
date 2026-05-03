// Structural Verilog 2005 port of EXE/res_buf_sel.sv
// 17-source op_type-driven 64-bit result-buffer selector.
// Tristate-mux of matched ops + 2:1 MUX with NAND-NOR match_any select.
// On no match res_buf_o = 64'h0 (matches the default in the SV reference).

`include "STDCell_Macros.vh"
`include "exe_structural_defines.vh"

module res_buf_sel (
    input  wire [`EXE_STRUCT_OP_W-1:0] op_type,

    input  wire [63:0] adc_res_buf_i,
    input  wire [63:0] add_res_buf_i,
    input  wire [63:0] and_res_buf_i,
    input  wire [63:0] call_res_buf_i,
    input  wire [63:0] cmpxchg_buf_i,
    input  wire [63:0] far_call_res_buf_i,
    input  wire [63:0] mov_res_buf_i,
    input  wire [63:0] mov_s_res_buf_i,
    input  wire [63:0] not_res_buf_i,
    input  wire [63:0] or_res_buf_i,
    input  wire [63:0] push_res_buf_i,
    input  wire [63:0] pop_res_buf_i,
    input  wire [63:0] sar_res_buf_i,
    input  wire [63:0] sal_res_buf_i,
    input  wire [63:0] sbb_res_buf_i,
    input  wire [63:0] xchg_res_buf_i,
    input  wire [63:0] exp_call_res_buf_i,

    output wire [63:0] res_buf_o
);

    // ---- One-hot match per matched op_type (17 total) ----
    wire is_adc, is_add, is_and, is_call;
    wire is_cmpxchg, is_far_call, is_mov, is_movs;
    wire is_not, is_or, is_push, is_pop;
    wire is_sar, is_sal, is_sbb, is_xchg;
    wire is_exp_call;

    `CMP_N(u_cmp_adc,      `EXE_STRUCT_OP_W, is_adc,      op_type, `EXE_OP_ADC)
    `CMP_N(u_cmp_add,      `EXE_STRUCT_OP_W, is_add,      op_type, `EXE_OP_ADD)
    `CMP_N(u_cmp_and,      `EXE_STRUCT_OP_W, is_and,      op_type, `EXE_OP_AND)
    `CMP_N(u_cmp_call,     `EXE_STRUCT_OP_W, is_call,     op_type, `EXE_OP_CALL)
    `CMP_N(u_cmp_cmpxchg,  `EXE_STRUCT_OP_W, is_cmpxchg,  op_type, `EXE_OP_CMPXCHG)
    `CMP_N(u_cmp_far_call, `EXE_STRUCT_OP_W, is_far_call, op_type, `EXE_OP_FAR_CALL)
    `CMP_N(u_cmp_mov,      `EXE_STRUCT_OP_W, is_mov,      op_type, `EXE_OP_MOV)
    `CMP_N(u_cmp_movs,     `EXE_STRUCT_OP_W, is_movs,     op_type, `EXE_OP_MOVS)
    `CMP_N(u_cmp_not,      `EXE_STRUCT_OP_W, is_not,      op_type, `EXE_OP_NOT)
    `CMP_N(u_cmp_or,       `EXE_STRUCT_OP_W, is_or,       op_type, `EXE_OP_OR)
    `CMP_N(u_cmp_push,     `EXE_STRUCT_OP_W, is_push,     op_type, `EXE_OP_PUSH)
    `CMP_N(u_cmp_pop,      `EXE_STRUCT_OP_W, is_pop,      op_type, `EXE_OP_POP)
    `CMP_N(u_cmp_sar,      `EXE_STRUCT_OP_W, is_sar,      op_type, `EXE_OP_SAR)
    `CMP_N(u_cmp_sal,      `EXE_STRUCT_OP_W, is_sal,      op_type, `EXE_OP_SAL)
    `CMP_N(u_cmp_sbb,      `EXE_STRUCT_OP_W, is_sbb,      op_type, `EXE_OP_SBB)
    `CMP_N(u_cmp_xchg,     `EXE_STRUCT_OP_W, is_xchg,     op_type, `EXE_OP_XCHG)
    `CMP_N(u_cmp_exp_call, `EXE_STRUCT_OP_W, is_exp_call, op_type, `EXE_OP_EXP_CALL)

    // ---- match_any via NAND-NOR tree (17 = 4+4+4+4 + 1, 3 levels) ----
    //   grp_x_zero = NOR_4(is_X1..is_X4) = 1 iff group is all-zero
    //   matched_in_first_16 = NAND_4(all four grp_zero) = 1 iff any group has a 1
    //   match_any = matched_in_first_16 | is_exp_call
    wire grp_a_zero, grp_b_zero, grp_c_zero, grp_d_zero;
    `NOR_4(u_nor_grp_a, 1, grp_a_zero, is_adc,     is_add,      is_and,  is_call)
    `NOR_4(u_nor_grp_b, 1, grp_b_zero, is_cmpxchg, is_far_call, is_mov,  is_movs)
    `NOR_4(u_nor_grp_c, 1, grp_c_zero, is_not,     is_or,       is_push, is_pop)
    `NOR_4(u_nor_grp_d, 1, grp_d_zero, is_sar,     is_sal,      is_sbb,  is_xchg)
    wire matched_in_first_16;
    `NAND_4(u_nand_first16, 1, matched_in_first_16, grp_a_zero, grp_b_zero, grp_c_zero, grp_d_zero)
    wire match_any;
    `OR_2(u_or_match_any, 1, match_any, matched_in_first_16, is_exp_call)

    // ---- Active-low enables ----
    wire enbar_adc, enbar_add, enbar_and, enbar_call, enbar_cmpxchg, enbar_far_call;
    wire enbar_mov, enbar_movs, enbar_not, enbar_or, enbar_push, enbar_pop;
    wire enbar_sar, enbar_sal, enbar_sbb, enbar_xchg, enbar_exp_call;

    `INV_N(u_inv_adc,      1, is_adc,      enbar_adc)
    `INV_N(u_inv_add,      1, is_add,      enbar_add)
    `INV_N(u_inv_and,      1, is_and,      enbar_and)
    `INV_N(u_inv_call,     1, is_call,     enbar_call)
    `INV_N(u_inv_cmpxchg,  1, is_cmpxchg,  enbar_cmpxchg)
    `INV_N(u_inv_far_call, 1, is_far_call, enbar_far_call)
    `INV_N(u_inv_mov,      1, is_mov,      enbar_mov)
    `INV_N(u_inv_movs,     1, is_movs,     enbar_movs)
    `INV_N(u_inv_not,      1, is_not,      enbar_not)
    `INV_N(u_inv_or,       1, is_or,       enbar_or)
    `INV_N(u_inv_push,     1, is_push,     enbar_push)
    `INV_N(u_inv_pop,      1, is_pop,      enbar_pop)
    `INV_N(u_inv_sar,      1, is_sar,      enbar_sar)
    `INV_N(u_inv_sal,      1, is_sal,      enbar_sal)
    `INV_N(u_inv_sbb,      1, is_sbb,      enbar_sbb)
    `INV_N(u_inv_xchg,     1, is_xchg,     enbar_xchg)
    `INV_N(u_inv_exp_call, 1, is_exp_call, enbar_exp_call)

    // ---- 17 tristateL$ drivers feed the shared bus (one fires when match_any=1) ----
    wire [63:0] tristated_bus;
    `TRISTATE_L(u_tri_adc,      64, enbar_adc,      adc_res_buf_i,      tristated_bus)
    `TRISTATE_L(u_tri_add,      64, enbar_add,      add_res_buf_i,      tristated_bus)
    `TRISTATE_L(u_tri_and,      64, enbar_and,      and_res_buf_i,      tristated_bus)
    `TRISTATE_L(u_tri_call,     64, enbar_call,     call_res_buf_i,     tristated_bus)
    `TRISTATE_L(u_tri_cmpxchg,  64, enbar_cmpxchg,  cmpxchg_buf_i,      tristated_bus)
    `TRISTATE_L(u_tri_far_call, 64, enbar_far_call, far_call_res_buf_i, tristated_bus)
    `TRISTATE_L(u_tri_mov,      64, enbar_mov,      mov_res_buf_i,      tristated_bus)
    `TRISTATE_L(u_tri_movs,     64, enbar_movs,     mov_s_res_buf_i,    tristated_bus)
    `TRISTATE_L(u_tri_not,      64, enbar_not,      not_res_buf_i,      tristated_bus)
    `TRISTATE_L(u_tri_or,       64, enbar_or,       or_res_buf_i,       tristated_bus)
    `TRISTATE_L(u_tri_push,     64, enbar_push,     push_res_buf_i,     tristated_bus)
    `TRISTATE_L(u_tri_pop,      64, enbar_pop,      pop_res_buf_i,      tristated_bus)
    `TRISTATE_L(u_tri_sar,      64, enbar_sar,      sar_res_buf_i,      tristated_bus)
    `TRISTATE_L(u_tri_sal,      64, enbar_sal,      sal_res_buf_i,      tristated_bus)
    `TRISTATE_L(u_tri_sbb,      64, enbar_sbb,      sbb_res_buf_i,      tristated_bus)
    `TRISTATE_L(u_tri_xchg,     64, enbar_xchg,     xchg_res_buf_i,     tristated_bus)
    `TRISTATE_L(u_tri_exp_call, 64, enbar_exp_call, exp_call_res_buf_i, tristated_bus)

    // ---- Final 2:1 mux: match_any ? tristated_bus : 64'h0 ----
    wire [63:0] zero64;
    assign zero64 = 64'h0;
    `MUX_2(u_mux_res_buf_o, 64, res_buf_o, zero64, tristated_bus, match_any)

endmodule
