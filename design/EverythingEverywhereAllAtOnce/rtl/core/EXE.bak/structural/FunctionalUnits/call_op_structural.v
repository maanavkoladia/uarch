// Structural Verilog 2005 port of EXE/FunctionalUnits/call_op.sv
// res_buf = {32'd0, NEIP[31:0]}
// sr_o    = {32'd0, stack_ptr[31:0] - 4}

module call_op (
    input  wire [63:0] NEIP,
    input  wire [63:0] stack_ptr,
    output wire [63:0] sr_o,
    output wire [63:0] res_buf
);

    assign res_buf = {32'd0, NEIP[31:0]};

    // stack_ptr[31:0] - 4  ==  stack_ptr[31:0] + 32'hFFFFFFFC (with cin = 0)
    wire [31:0] sub_sum;
    wire        sub_cout;
    `ADD_N(u_sub_4, 32, sub_sum, sub_cout, stack_ptr[31:0], 32'hFFFFFFFC, 1'b0)

    assign sr_o = {32'd0, sub_sum};

endmodule
