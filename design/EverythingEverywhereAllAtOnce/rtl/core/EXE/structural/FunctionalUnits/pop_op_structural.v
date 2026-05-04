// Structural Verilog 2005 port of EXE/FunctionalUnits/pop_op.sv
// Merges popped bytes into curr_dr based on data_size, updates ESP by 2 or 4.

module pop_op (
    input  wire [63:0] value_i,   // value read from stack
    input  wire [63:0] sp_i,      // current ESP
    input  wire [63:0] curr_dr,   // current destination register value
    input  wire [3:0]  data_size, // one-hot: [0]=AL [1]=AH [2]=16-bit [3]=32-bit
    output wire [63:0] dr_o,
    output wire [63:0] sr_o,
    output wire [63:0] res_buf
);

    // num_bytes: 2 when data_size[2]=0 (16-bit), 4 when data_size[2]=1 (32-bit)
    wire [31:0] num_bytes;
    `MUX_2(u_mux_num_bytes, 32, num_bytes, 32'd2, 32'd4, data_size[2])

    // merged_res: select each byte-group from value_i or curr_dr based on data_size
    wire [31:0] merged_res;
    `MUX_2(u_mux_lo8,  8,  merged_res[7:0],   curr_dr[7:0],   value_i[7:0],   data_size[0])
    `MUX_2(u_mux_hi8,  8,  merged_res[15:8],  curr_dr[15:8],  value_i[15:8],  data_size[1])
    `MUX_2(u_mux_hi16, 16, merged_res[31:16], curr_dr[31:16], value_i[31:16], data_size[2])

    assign dr_o    = {32'd0, merged_res};
    assign res_buf = {32'd0, merged_res};

    wire [31:0] sp_plus_n;
    wire        cout;
    `ADD_N(u_add_n, 32, sp_plus_n, cout, sp_i[31:0], num_bytes, 1'b0)

    assign sr_o = {32'd0, sp_plus_n};

endmodule
