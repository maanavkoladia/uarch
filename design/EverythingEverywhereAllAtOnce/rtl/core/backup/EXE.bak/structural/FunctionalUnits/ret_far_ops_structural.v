// Structural Verilog 2005 port of EXE/FunctionalUnits/ret_far_ops.sv
// dr_o = {32'd0, 16'd0, cs[15:0]}
// sr_o = stack_ptr + 8

module ret_far_op (
    input  wire [31:0] cs,
    input  wire [63:0] stack_ptr,
    output wire [63:0] dr_o,
    output wire [63:0] sr_o
);

    assign dr_o = {32'd0, 16'd0, cs[15:0]};

    wire add_cout;
    `ADD_N(u_add_8, 64, sr_o, add_cout, stack_ptr, 64'd8, 1'b0)

endmodule
