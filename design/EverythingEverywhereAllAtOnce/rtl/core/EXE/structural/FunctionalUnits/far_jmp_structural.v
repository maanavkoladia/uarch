// Structural Verilog 2005 port of EXE/FunctionalUnits/far_jmp.sv (module: far_jmp_op).
//
// IMPORTANT: SV reference takes `op_type` as `exe_cs_operation_type_e` (enum).
// Structural port replaces it with `wire [`EXE_STRUCT_OP_W-1:0] op_type`. The
// EXE_structural.sv wrapper passes `op_type_w` (the flat 6-bit alias) here.
//
// dr_o = (op_type == FAR_JMP16) ? {48'd0, srA[31:16]} : {48'd0, srA[47:32]}

module far_jmp_op (
    input  wire [`EXE_STRUCT_OP_W-1:0] op_type,
    input  wire [63:0]                 srA,
    output wire [63:0]                 dr_o
);

    wire is_jmp16;
    wire is_jmp16_raw;
    `CMP_N(u_cmp_jmp16, `EXE_STRUCT_OP_W, is_jmp16_raw, op_type, `EXE_OP_FAR_JMP16)
    // is_jmp16 feeds the 64-bit u_mux_dr select (fanout=64, exact fit for
    // bufferH64$ rated 64, 0.30 ns typ).
    bufferH64$ u_buf_is_jmp16 (.out(is_jmp16), .in(is_jmp16_raw));

    `MUX_2(u_mux_dr, 64, dr_o, {48'd0, srA[47:32]}, {48'd0, srA[31:16]}, is_jmp16)

endmodule
