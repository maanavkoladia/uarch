// Structural Verilog 2005 port of EXE/sr_sel.sv
// Tristate-mux of all matched op_types, then a 2:1 MUX selects between the
// tristated bus and sr_data based on WB_SR. When WB_SR=0, sr_data passes
// through (no need to compute match_any from a wide OR tree).

module sr_sel (
    input  wire [`EXE_STRUCT_OP_W-1:0] op_type,
    input  wire                        WB_SR,    // mux select for final stage

    input  wire [63:0] sr_data,
    input  wire [63:0] pop_sr_i,
    input  wire [63:0] push_sr_i,
    input  wire [63:0] ret_far_sr_i,
    input  wire [63:0] ret_far_imm_sr_i,
    input  wire [63:0] ret_imm_sr_i,
    input  wire [63:0] ret_sr_i,
    input  wire [63:0] xchg_sr_i,
    input  wire [63:0] call_sr_i,
    input  wire [63:0] far_call_sr_i,
    input  wire [63:0] mov_s_sr_i,
    input  wire [63:0] add_df_sr_i,
    input  wire [63:0] exp_call_sr_i,
    input  wire [63:0] iretd_sr_i,

    output wire [63:0] sr_o
);

    // ---- One-hot match per matched op_type ----
    wire is_add_df, is_pop, is_push, is_ret_far, is_ret_far_imm;
    wire is_ret_imm, is_ret, is_xchg, is_call, is_far_call;
    wire is_movs, is_exp_call, is_iretd;

    `CMP_N(u_cmp_add_df,      `EXE_STRUCT_OP_W, is_add_df,      op_type, `EXE_OP_ADD_DF)
    `CMP_N(u_cmp_pop,         `EXE_STRUCT_OP_W, is_pop,         op_type, `EXE_OP_POP)
    `CMP_N(u_cmp_push,        `EXE_STRUCT_OP_W, is_push,        op_type, `EXE_OP_PUSH)
    `CMP_N(u_cmp_ret_far,     `EXE_STRUCT_OP_W, is_ret_far,     op_type, `EXE_OP_RET_FAR)
    `CMP_N(u_cmp_ret_far_imm, `EXE_STRUCT_OP_W, is_ret_far_imm, op_type, `EXE_OP_RET_FAR_IMM)
    `CMP_N(u_cmp_ret_imm,     `EXE_STRUCT_OP_W, is_ret_imm,     op_type, `EXE_OP_RET_IMM)
    `CMP_N(u_cmp_ret,         `EXE_STRUCT_OP_W, is_ret,         op_type, `EXE_OP_RET)
    `CMP_N(u_cmp_xchg,        `EXE_STRUCT_OP_W, is_xchg,        op_type, `EXE_OP_XCHG)
    `CMP_N(u_cmp_call,        `EXE_STRUCT_OP_W, is_call,        op_type, `EXE_OP_CALL)
    `CMP_N(u_cmp_far_call,    `EXE_STRUCT_OP_W, is_far_call,    op_type, `EXE_OP_FAR_CALL)
    `CMP_N(u_cmp_movs,        `EXE_STRUCT_OP_W, is_movs,        op_type, `EXE_OP_MOVS)
    `CMP_N(u_cmp_exp_call,    `EXE_STRUCT_OP_W, is_exp_call,    op_type, `EXE_OP_EXP_CALL)
    `CMP_N(u_cmp_iretd,       `EXE_STRUCT_OP_W, is_iretd,       op_type, `EXE_OP_IRETD)

    // ---- Active-low enables ----
    wire enbar_add_df, enbar_pop, enbar_push, enbar_ret_far, enbar_ret_far_imm;
    wire enbar_ret_imm, enbar_ret, enbar_xchg, enbar_call, enbar_far_call;
    wire enbar_movs, enbar_exp_call, enbar_iretd;
    // enbar_* feed 64-bit TRISTATE_L enables (fanout=64). bufferHInv64$ is
    // rated 64 — exact-fit single-cell replacement for the INV_N (HInv16)
    // chain. Logic preserved: same inversion semantics as INV_N.
    bufferHInv64$ u_inv_add_df      (.out(enbar_add_df),      .in(is_add_df));
    bufferHInv64$ u_inv_pop         (.out(enbar_pop),         .in(is_pop));
    bufferHInv64$ u_inv_push        (.out(enbar_push),        .in(is_push));
    bufferHInv64$ u_inv_ret_far     (.out(enbar_ret_far),     .in(is_ret_far));
    bufferHInv64$ u_inv_ret_far_imm (.out(enbar_ret_far_imm), .in(is_ret_far_imm));
    bufferHInv64$ u_inv_ret_imm     (.out(enbar_ret_imm),     .in(is_ret_imm));
    bufferHInv64$ u_inv_ret         (.out(enbar_ret),         .in(is_ret));
    bufferHInv64$ u_inv_xchg        (.out(enbar_xchg),        .in(is_xchg));
    bufferHInv64$ u_inv_call        (.out(enbar_call),        .in(is_call));
    bufferHInv64$ u_inv_far_call    (.out(enbar_far_call),    .in(is_far_call));
    bufferHInv64$ u_inv_movs        (.out(enbar_movs),        .in(is_movs));
    bufferHInv64$ u_inv_exp_call    (.out(enbar_exp_call),    .in(is_exp_call));
    bufferHInv64$ u_inv_iretd       (.out(enbar_iretd),       .in(is_iretd));

    // ---- Shared tristated bus, driven by exactly one of 13 tristateL$ when WB_SR=1 ----
    wire [63:0] tristated_bus;
    `TRISTATE_L(u_tri_add_df,      64, enbar_add_df,      add_df_sr_i,      tristated_bus)
    `TRISTATE_L(u_tri_pop,         64, enbar_pop,         pop_sr_i,         tristated_bus)
    `TRISTATE_L(u_tri_push,        64, enbar_push,        push_sr_i,        tristated_bus)
    `TRISTATE_L(u_tri_ret_far,     64, enbar_ret_far,     ret_far_sr_i,     tristated_bus)
    `TRISTATE_L(u_tri_ret_far_imm, 64, enbar_ret_far_imm, ret_far_imm_sr_i, tristated_bus)
    `TRISTATE_L(u_tri_ret_imm,     64, enbar_ret_imm,     ret_imm_sr_i,     tristated_bus)
    `TRISTATE_L(u_tri_ret,         64, enbar_ret,         ret_sr_i,         tristated_bus)
    `TRISTATE_L(u_tri_xchg,        64, enbar_xchg,        xchg_sr_i,        tristated_bus)
    `TRISTATE_L(u_tri_call,        64, enbar_call,        call_sr_i,        tristated_bus)
    `TRISTATE_L(u_tri_far_call,    64, enbar_far_call,    far_call_sr_i,    tristated_bus)
    `TRISTATE_L(u_tri_movs,        64, enbar_movs,        mov_s_sr_i,       tristated_bus)
    `TRISTATE_L(u_tri_exp_call,    64, enbar_exp_call,    exp_call_sr_i,    tristated_bus)
    `TRISTATE_L(u_tri_iretd,       64, enbar_iretd,       iretd_sr_i,       tristated_bus)

    // ---- Final 2:1 mux: WB_SR ? tristated_bus : sr_data ----
    `MUX_2(u_mux_sr_o, 64, sr_o, sr_data, tristated_bus, WB_SR)

endmodule
