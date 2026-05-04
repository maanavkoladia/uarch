// Structural Verilog 2005 port of EXE/FunctionalUnits/ret_imm_op.sv
// sr_o = stack_ptr + 4 + imm64[15:0]

module ret_imm_op (
    input  wire [63:0] imm64,
    input  wire [63:0] stack_ptr,
    output wire [63:0] sr_o
);

    wire [63:0] sum_imm;
    wire        c_imm;
    wire        c_4;

    `ADD_N(u_add_imm, 64, sum_imm, c_imm, stack_ptr, {48'd0, imm64[15:0]}, 1'b0)
    `ADD_N(u_add_4,   64, sr_o,    c_4,   sum_imm,   64'd4,                1'b0)

endmodule
