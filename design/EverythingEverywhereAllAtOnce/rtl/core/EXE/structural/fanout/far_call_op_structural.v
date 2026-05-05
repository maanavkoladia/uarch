// Structural Verilog 2005 port of EXE/FunctionalUnits/far_call_op.sv
// res_buf = {16'd0, segment[15:0], neip}
// dr_o    = {32'd0, new_cs}
// sr_o    = {32'd0, stack_ptr[31:0] - 8}

module far_call_op (
    input  wire [31:0] neip,
    input  wire [31:0] segment,
    input  wire [63:0] stack_ptr,
    input  wire [31:0] new_cs,
    output wire [63:0] res_buf,
    output wire [63:0] dr_o,
    output wire [63:0] sr_o
);

    assign res_buf = {16'd0, segment[15:0], neip};
    assign dr_o    = {32'd0, new_cs};

    // stack_ptr[31:0] - 8  ==  stack_ptr[31:0] + 32'hFFFFFFF8 (with cin = 0)
    wire [31:0] sub_sum;
    wire        sub_cout;
    `ADD_N(u_sub_8, 32, sub_sum, sub_cout, stack_ptr[31:0], 32'hFFFFFFF8, 1'b0)

    assign sr_o = {32'd0, sub_sum};

endmodule
