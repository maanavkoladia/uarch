// Structural Verilog 2005 port of EXE/reg_wb_logic.sv
// Drives the two register-file write ports out of EXE.

module reg_wb_logic (
    input  wire [`EXE_STRUCT_OP_W-1:0]      op_type,
    input  wire [63:0]                       next_dr_data,
    input  wire [`EXE_STRUCT_REG_ID_W-1:0]   dr_id,
    input  wire                              WB_DR,
    input  wire [63:0]                       next_EAX,
    input  wire [63:0]                       next_sr_data,
    input  wire [`EXE_STRUCT_REG_ID_W-1:0]   sr_id,
    input  wire                              WB_EAX,
    input  wire                              WB_SR,
    input  wire                              valid,
    input  wire                              stall_flop,

    output wire [`EXE_STRUCT_REG_ID_W-1:0]   dr0_id_o,
    output wire                              dr0_we_o,
    output wire [63:0]                       dr0_data_o,
    output wire [`EXE_STRUCT_REG_ID_W-1:0]   dr1_id_o,
    output wire                              dr1_we_o,
    output wire [63:0]                       dr1_data_o
);

    // dr0_data_o is a direct passthrough.
    assign dr0_data_o = next_dr_data;

    // is_exp_call = (op_type == EXP_CALL)
    wire is_exp_call;
    wire is_exp_call_raw;
    `CMP_N(u_cmp_exp_call, `EXE_STRUCT_OP_W, is_exp_call_raw, op_type, `EXE_OP_EXP_CALL)
    // is_exp_call fanout 5 → bufferH16$ smallest fit.
    bufferH16$ u_buf_is_exp_call (.out(is_exp_call), .in(is_exp_call_raw));

    // dr0_id_o = is_exp_call ? CS : dr_id
    wire [`EXE_STRUCT_REG_ID_W-1:0] cs_id;
    assign cs_id = `EXE_REG_CS;
    `MUX_2(u_mux_dr0_id, `EXE_STRUCT_REG_ID_W, dr0_id_o, dr_id, cs_id, is_exp_call)

    // nstall = ~stall_flop
    wire nstall;
    `INV_N(u_inv_stall, 1, stall_flop, nstall)

    // dr0_we_o = WB_DR & nstall & valid
    `AND_3(u_and_dr0_we, 1, dr0_we_o, WB_DR, nstall, valid)

    // dr1_data_o = WB_EAX ? next_EAX : next_sr_data
    `MUX_2(u_mux_dr1_data, 64, dr1_data_o, next_sr_data, next_EAX, WB_EAX)

    // dr1_id_o = WB_EAX ? EAX : sr_id
    wire [`EXE_STRUCT_REG_ID_W-1:0] eax_id;
    assign eax_id = `EXE_REG_EAX;
    `MUX_2(u_mux_dr1_id, `EXE_STRUCT_REG_ID_W, dr1_id_o, sr_id, eax_id, WB_EAX)

    // wb_sr_or_eax = WB_SR | WB_EAX  (one-hot from CS, never both, but OR is correct)
    wire wb_sr_or_eax;
    `OR_2(u_or_wb_sr_eax, 1, wb_sr_or_eax, WB_SR, WB_EAX)

    // dr1_we_o = wb_sr_or_eax & nstall & valid
    `AND_3(u_and_dr1_we, 1, dr1_we_o, wb_sr_or_eax, nstall, valid)

endmodule
