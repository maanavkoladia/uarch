// Structural Verilog 2005 port of EXE/FunctionalUnits/push_op.sv
// num_bytes = data_size_vec[2] ? 4 : 2
// sr_o      = sp - num_bytes
// res_buf   = {32'd0, value[31:0]}

module push_op (
    input  wire [63:0] value,
    input  wire [63:0] sp,
    input  wire [3:0]  data_size_vec,
    output wire [63:0] res_buf,
    output wire [63:0] sr_o
);

    assign res_buf = {32'd0, value[31:0]};

    wire [63:0] num_bytes_64;
    `MUX_2(u_mux_nb, 64, num_bytes_64, 64'd2, 64'd4, data_size_vec[2])

    wire [63:0] num_bytes_inv;
    `INV_N(u_inv_nb, 64, num_bytes_64, num_bytes_inv)

    wire        sub_cout;
    `ADD_N(u_sub, 64, sr_o, sub_cout, sp, num_bytes_inv, 1'b1)

endmodule
