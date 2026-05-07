// Structural Verilog 2005 port of EXE/FunctionalUnits/not_op.sv
// Bitwise NOT of srA[31:0] with per-byte data_size masking.
// data_size[0] selects byte 0, data_size[1] byte 1, data_size[2] selects bytes 2-3.
// data_size[3] (64-bit) is not handled by the SV reference - matched here.

module not_op (
    input  wire [63:0] srA,
    input  wire [3:0]  data_size,
    output wire [63:0] dr_o,
    output wire [63:0] res_buf_o
);

    wire [31:0] out_32;
    `INV_N(u_inv_32, 32, srA[31:0], out_32)

    wire [7:0]  merged_b0;
    wire [7:0]  merged_b1;
    wire [15:0] merged_hi;

    `MUX_2(u_mux_b0, 8,  merged_b0, srA[7:0],   out_32[7:0],   data_size[0])
    `MUX_2(u_mux_b1, 8,  merged_b1, srA[15:8],  out_32[15:8],  data_size[1])
    `MUX_2(u_mux_hi, 16, merged_hi, srA[31:16], out_32[31:16], data_size[2])

    wire [31:0] merged_res;
    assign merged_res = {merged_hi, merged_b1, merged_b0};

    assign dr_o      = {32'h0, merged_res};
    assign res_buf_o = {32'h0, merged_res};

endmodule
