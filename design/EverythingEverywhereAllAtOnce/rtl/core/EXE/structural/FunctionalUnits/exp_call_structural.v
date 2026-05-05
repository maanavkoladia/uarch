// Structural Verilog 2005 port of EXE/FunctionalUnits/exp_call.sv
// new_cs  = idt[31:16]
// exp_eip = {idt[63:48], idt[15:0]}
// res_buf = {16'd0, curr_cs[15:0], eip[31:0]}
// dr_o    = {48'd0, new_cs}
// sr_o    = {32'd0, stack_ptr[31:0] - 8}

module exp_call_op (
    input  wire [63:0] idt,
    input  wire [31:0] eip,
    input  wire [31:0] curr_cs,
    input  wire [63:0] stack_ptr,
    output wire [63:0] res_buf,
    output wire [63:0] dr_o,
    output wire [63:0] sr_o,
    output wire [31:0] exp_eip
);

    wire [15:0] new_cs;
    assign new_cs  = idt[31:16];
    assign exp_eip = {idt[63:48], idt[15:0]};
    assign res_buf = {16'd0, curr_cs[15:0], eip};
    assign dr_o    = {48'd0, new_cs};

    wire [31:0] sub_sum;
    wire        sub_cout;
    `ADD_N(u_sub_8, 32, sub_sum, sub_cout, stack_ptr[31:0], 32'hFFFFFFF8, 1'b0)

    assign sr_o = {32'd0, sub_sum};

endmodule
