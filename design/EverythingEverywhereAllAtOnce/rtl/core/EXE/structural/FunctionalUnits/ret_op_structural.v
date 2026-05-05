// Structural Verilog 2005 port of EXE/FunctionalUnits/ret_op.sv
// sr_o = stack_ptr + 4

module ret_op (
    input  wire [63:0] stack_ptr,
    output wire [63:0] sr_o
);

    wire add_cout;
    `ADD_N(u_add_4, 64, sr_o, add_cout, stack_ptr, 64'd4, 1'b0)

endmodule
