// Structural Verilog 2005 port of EXE/FunctionalUnits/ret_far_imm_op.sv
// dr_o = cs (zero-extended to 64 bits)
// sr_o = stack_ptr + 8 + imm64[15:0]

module ret_far_imm (
    input  wire [31:0] cs,
    input  wire [63:0] stack_ptr,
    input  wire [63:0] imm64,
    output wire [63:0] dr_o,
    output wire [63:0] sr_o
);

    assign dr_o = {32'd0, cs};

    wire [63:0] sum_imm;
    wire        c_imm;
    wire        c_8;

    `ADD_N(u_add_imm, 64, sum_imm, c_imm, stack_ptr, {48'd0, imm64[15:0]}, 1'b0)
    `ADD_N(u_add_8,   64, sr_o,    c_8,   sum_imm,   64'd8,                1'b0)

endmodule
