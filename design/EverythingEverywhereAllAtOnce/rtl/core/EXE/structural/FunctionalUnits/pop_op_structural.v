// Structural Verilog 2005 port of EXE/FunctionalUnits/pop_op.sv
// dr_o    = {32'd0, value_i[31:0]}
// res_buf = {32'd0, value_i[31:0]}
// sr_o    = {32'd0, sp_i[31:0] + 4}

module pop_op (
    input  wire [63:0] value_i,
    input  wire [63:0] sp_i,
    output wire [63:0] dr_o,
    output wire [63:0] sr_o,
    output wire [63:0] res_buf
);

    assign dr_o    = {32'd0, value_i[31:0]};
    assign res_buf = {32'd0, value_i[31:0]};

    wire [31:0] sp_plus4;
    wire        cout;
    `ADD_N(u_add_4, 32, sp_plus4, cout, sp_i[31:0], 32'd4, 1'b0)

    assign sr_o = {32'd0, sp_plus4};

endmodule
