// Structural Verilog 2005 port of EXE/FunctionalUnits/mov_op.sv
//
// IMPORTANT: SV reference takes `op_type` as `exe_cs_operation_type_e` (an enum).
// Structural port replaces it with `wire [`EXE_STRUCT_OP_W-1:0] op_type`. The
// EXE_structural.sv wrapper passes `op_type_w` (the flat 6-bit alias) here.
//
// masked_data_size = (op_type == CMOVC && ~curr_cf_flag) ? 4'b0000 : data_size;
// Per-byte mux of srB into srA controlled by masked_data_size (one-hot lane vec).

module mov_op (
    input  wire [63:0]                 srA,
    input  wire [63:0]                 srB,
    input  wire [3:0]                  data_size,
    input  wire [`EXE_STRUCT_OP_W-1:0] op_type,
    input  wire                        curr_cf_flag,
    output wire [63:0]                 res_buf_o,
    output wire [63:0]                 dr_o
);

    wire is_cmovc;
    `CMP_N(u_cmp_cmovc, `EXE_STRUCT_OP_W, is_cmovc, op_type, `EXE_OP_CMOVC)

    wire cf_inv;
    `INV_N(u_inv_cf, 1, curr_cf_flag, cf_inv)

    wire cancel_mov;
    `AND_2(u_and_cancel, 1, cancel_mov, is_cmovc, cf_inv)

    wire [3:0] masked_ds;
    `MUX_2(u_mux_ds, 4, masked_ds, data_size, 4'b0000, cancel_mov)

    wire [7:0]  m_b0, m_b1;
    wire [15:0] m_hi;
    wire [31:0] m_top;

    `MUX_2(u_mux_b0, 8,  m_b0,  srA[7:0],   srB[7:0],   masked_ds[0])
    `MUX_2(u_mux_b1, 8,  m_b1,  srA[15:8],  srB[15:8],  masked_ds[1])
    `MUX_2(u_mux_hi, 16, m_hi,  srA[31:16], srB[31:16], masked_ds[2])
    `MUX_2(u_mux_t,  32, m_top, srA[63:32], srB[63:32], masked_ds[3])

    wire [63:0] merged_res;
    assign merged_res = {m_top, m_hi, m_b1, m_b0};

    assign res_buf_o = merged_res;
    assign dr_o      = merged_res;

endmodule
