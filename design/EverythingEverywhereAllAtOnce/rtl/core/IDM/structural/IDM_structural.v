// =============================================================================
// IDM (pure Verilog-2005 structural port of IDM_structural.sv)
//
//   - All SystemVerilog struct/typedef/array port constructs are removed.
//     Each struct field is exposed as a separate flat scalar/vector port
//     whose name follows the original `struct.field` path with `.` replaced
//     by `_`.
//
//   - fetch_outputs_t.idm_reqs.req[NUM_IDM_SLOTS] is unrolled per slot.
//     Each per-slot data[CACHE_LINES_SIZE_B] (byte array) becomes a 128-bit
//     packed bus (byte 0 = bits [7:0]).
//   - idm_outputs_t.idm_slots[NUM_IDM_SLOTS] is unrolled per slot. Each
//     per-slot data[16] (byte array) is packed into a 128-bit bus on the
//     output boundary.
//
//   Internal logic is identical to IDM_structural.sv: the only differences
//   are the port plumbing and the flat-to-internal/internal-to-flat
//   adapter assigns.
//
//   Reset / clear semantics (unchanged from .sv version):
//     * rst (active low) drives every REG_RST_WE.rst pin -- async, per the
//       macro's contract.
//     * exp_pipe_clear is treated as a SYNCHRONOUS clear of just the .valid
//       bit of every slot. The br_* / data fields are not touched -- consumers
//       gate on valid.
// =============================================================================


module IDM (
    input  wire        clk,
    input  wire        rst,        // active low, async

    // ====================================================================
    // fetch_outputs_t (fetch_outs_i) -- consumed fields
    // ====================================================================
    input  wire        fetch_outs_exp_pipe_clear,

    // ---- idm_reqs.req[0..3] : per-slot fetch_idm_ctrl_2_idm_t ----
    input  wire        fetch_outs_idm_reqs_req_0_ld_meta_data,
    input  wire        fetch_outs_idm_reqs_req_0_ld_data,
    input  wire        fetch_outs_idm_reqs_req_0_valid,
    input  wire        fetch_outs_idm_reqs_req_0_br_valid,
    input  wire [31:0] fetch_outs_idm_reqs_req_0_br_eip,
    input  wire [31:0] fetch_outs_idm_reqs_req_0_br_target,
    input  wire        fetch_outs_idm_reqs_req_0_br_xcl,
    input  wire [127:0] fetch_outs_idm_reqs_req_0_data,

    input  wire        fetch_outs_idm_reqs_req_1_ld_meta_data,
    input  wire        fetch_outs_idm_reqs_req_1_ld_data,
    input  wire        fetch_outs_idm_reqs_req_1_valid,
    input  wire        fetch_outs_idm_reqs_req_1_br_valid,
    input  wire [31:0] fetch_outs_idm_reqs_req_1_br_eip,
    input  wire [31:0] fetch_outs_idm_reqs_req_1_br_target,
    input  wire        fetch_outs_idm_reqs_req_1_br_xcl,
    input  wire [127:0] fetch_outs_idm_reqs_req_1_data,

    input  wire        fetch_outs_idm_reqs_req_2_ld_meta_data,
    input  wire        fetch_outs_idm_reqs_req_2_ld_data,
    input  wire        fetch_outs_idm_reqs_req_2_valid,
    input  wire        fetch_outs_idm_reqs_req_2_br_valid,
    input  wire [31:0] fetch_outs_idm_reqs_req_2_br_eip,
    input  wire [31:0] fetch_outs_idm_reqs_req_2_br_target,
    input  wire        fetch_outs_idm_reqs_req_2_br_xcl,
    input  wire [127:0] fetch_outs_idm_reqs_req_2_data,

    input  wire        fetch_outs_idm_reqs_req_3_ld_meta_data,
    input  wire        fetch_outs_idm_reqs_req_3_ld_data,
    input  wire        fetch_outs_idm_reqs_req_3_valid,
    input  wire        fetch_outs_idm_reqs_req_3_br_valid,
    input  wire [31:0] fetch_outs_idm_reqs_req_3_br_eip,
    input  wire [31:0] fetch_outs_idm_reqs_req_3_br_target,
    input  wire        fetch_outs_idm_reqs_req_3_br_xcl,
    input  wire [127:0] fetch_outs_idm_reqs_req_3_data,

    // ====================================================================
    // idm_outputs_t (idm_outs_o) -- per-slot unroll
    // ====================================================================
    output wire        idm_outs_idm_slots_0_valid,
    output wire        idm_outs_idm_slots_0_br_valid,
    output wire [31:0] idm_outs_idm_slots_0_br_eip,
    output wire [31:0] idm_outs_idm_slots_0_br_btb_target,
    output wire        idm_outs_idm_slots_0_br_xcl,
    output wire [127:0] idm_outs_idm_slots_0_data,

    output wire        idm_outs_idm_slots_1_valid,
    output wire        idm_outs_idm_slots_1_br_valid,
    output wire [31:0] idm_outs_idm_slots_1_br_eip,
    output wire [31:0] idm_outs_idm_slots_1_br_btb_target,
    output wire        idm_outs_idm_slots_1_br_xcl,
    output wire [127:0] idm_outs_idm_slots_1_data,

    output wire        idm_outs_idm_slots_2_valid,
    output wire        idm_outs_idm_slots_2_br_valid,
    output wire [31:0] idm_outs_idm_slots_2_br_eip,
    output wire [31:0] idm_outs_idm_slots_2_br_btb_target,
    output wire        idm_outs_idm_slots_2_br_xcl,
    output wire [127:0] idm_outs_idm_slots_2_data,

    output wire        idm_outs_idm_slots_3_valid,
    output wire        idm_outs_idm_slots_3_br_valid,
    output wire [31:0] idm_outs_idm_slots_3_br_eip,
    output wire [31:0] idm_outs_idm_slots_3_br_btb_target,
    output wire        idm_outs_idm_slots_3_br_xcl,
    output wire [127:0] idm_outs_idm_slots_3_data,

    output wire [2:0]  idm_outs_valid_slots
);

    // ----------------------------------------------------------------
    // Pack flat per-slot inputs into the unpacked arrays consumed by the
    // internal logic (assigns are pure aliasing / slicing -- no operators).
    // ----------------------------------------------------------------
    localparam  NUM_IDM_SLOTS = 4;
    wire        ld_meta_w  [0:NUM_IDM_SLOTS-1];
    wire        ld_data_w  [0:NUM_IDM_SLOTS-1];
    wire        in_valid_w [0:NUM_IDM_SLOTS-1];
    wire        in_brval_w [0:NUM_IDM_SLOTS-1];
    wire [31:0] in_breip_w [0:NUM_IDM_SLOTS-1];
    wire [31:0] in_brtgt_w [0:NUM_IDM_SLOTS-1];
    wire        in_brxcl_w [0:NUM_IDM_SLOTS-1];
    wire [127:0] in_data_w [0:NUM_IDM_SLOTS-1];   // packed LSB-first
    wire        exp_pipe_clear_w;

    assign exp_pipe_clear_w = fetch_outs_exp_pipe_clear;

    assign ld_meta_w[0]  = fetch_outs_idm_reqs_req_0_ld_meta_data;
    assign ld_data_w[0]  = fetch_outs_idm_reqs_req_0_ld_data;
    assign in_valid_w[0] = fetch_outs_idm_reqs_req_0_valid;
    assign in_brval_w[0] = fetch_outs_idm_reqs_req_0_br_valid;
    assign in_breip_w[0] = fetch_outs_idm_reqs_req_0_br_eip;
    assign in_brtgt_w[0] = fetch_outs_idm_reqs_req_0_br_target;
    assign in_brxcl_w[0] = fetch_outs_idm_reqs_req_0_br_xcl;
    assign in_data_w[0]  = fetch_outs_idm_reqs_req_0_data;

    assign ld_meta_w[1]  = fetch_outs_idm_reqs_req_1_ld_meta_data;
    assign ld_data_w[1]  = fetch_outs_idm_reqs_req_1_ld_data;
    assign in_valid_w[1] = fetch_outs_idm_reqs_req_1_valid;
    assign in_brval_w[1] = fetch_outs_idm_reqs_req_1_br_valid;
    assign in_breip_w[1] = fetch_outs_idm_reqs_req_1_br_eip;
    assign in_brtgt_w[1] = fetch_outs_idm_reqs_req_1_br_target;
    assign in_brxcl_w[1] = fetch_outs_idm_reqs_req_1_br_xcl;
    assign in_data_w[1]  = fetch_outs_idm_reqs_req_1_data;

    assign ld_meta_w[2]  = fetch_outs_idm_reqs_req_2_ld_meta_data;
    assign ld_data_w[2]  = fetch_outs_idm_reqs_req_2_ld_data;
    assign in_valid_w[2] = fetch_outs_idm_reqs_req_2_valid;
    assign in_brval_w[2] = fetch_outs_idm_reqs_req_2_br_valid;
    assign in_breip_w[2] = fetch_outs_idm_reqs_req_2_br_eip;
    assign in_brtgt_w[2] = fetch_outs_idm_reqs_req_2_br_target;
    assign in_brxcl_w[2] = fetch_outs_idm_reqs_req_2_br_xcl;
    assign in_data_w[2]  = fetch_outs_idm_reqs_req_2_data;

    assign ld_meta_w[3]  = fetch_outs_idm_reqs_req_3_ld_meta_data;
    assign ld_data_w[3]  = fetch_outs_idm_reqs_req_3_ld_data;
    assign in_valid_w[3] = fetch_outs_idm_reqs_req_3_valid;
    assign in_brval_w[3] = fetch_outs_idm_reqs_req_3_br_valid;
    assign in_breip_w[3] = fetch_outs_idm_reqs_req_3_br_eip;
    assign in_brtgt_w[3] = fetch_outs_idm_reqs_req_3_br_target;
    assign in_brxcl_w[3] = fetch_outs_idm_reqs_req_3_br_xcl;
    assign in_data_w[3]  = fetch_outs_idm_reqs_req_3_data;

    // ----------------------------------------------------------------
    // valid-bit gating
    //   we_valid = ld_meta_data | exp_pipe_clear   (so clear takes effect)
    //   d_valid  = exp_pipe_clear ? 1'b0 : req.valid
    // br_* / data have no clear semantics in this port: their WE is the
    // raw load enable and their D is the raw req field.
    // ----------------------------------------------------------------
    wire we_valid_w [0:NUM_IDM_SLOTS-1];
    wire d_valid_w  [0:NUM_IDM_SLOTS-1];
    genvar gi;
    generate
        for (gi = 0; gi < NUM_IDM_SLOTS; gi = gi + 1) begin: g_valid_in
            `OR_2 (u_we_valid, 1, we_valid_w[gi], ld_meta_w[gi], exp_pipe_clear_w)
            `MUX_2(u_dm_valid, 1, d_valid_w[gi],  in_valid_w[gi], 1'b0, exp_pipe_clear_w)
        end
    endgenerate

    // ----------------------------------------------------------------
    // Storage. One REG_RST_WE per (slot, field). rst (active low, async)
    // drives every .rst pin per macro contract.
    //   valid : we = we_valid_w (OR with clear), d = d_valid_w (mux'd to 0)
    //   br_*  : we = ld_meta_w, d = raw req field
    //   data  : we = ld_data_w, d = raw req data
    // ----------------------------------------------------------------
    wire        valid_q  [0:NUM_IDM_SLOTS-1];
    wire        brval_q  [0:NUM_IDM_SLOTS-1];
    wire [31:0] breip_q  [0:NUM_IDM_SLOTS-1];
    wire [31:0] brtgt_q  [0:NUM_IDM_SLOTS-1];
    wire        brxcl_q  [0:NUM_IDM_SLOTS-1];
    wire [127:0] data_q  [0:NUM_IDM_SLOTS-1];

    generate
        for (gi = 0; gi < NUM_IDM_SLOTS; gi = gi + 1) begin: g_reg
            `REG_RST_WE(u_r_valid, 1,   clk, rst, we_valid_w[gi], d_valid_w[gi],  valid_q[gi])
            `REG_RST_WE(u_r_brval, 1,   clk, rst, ld_meta_w[gi],  in_brval_w[gi], brval_q[gi])
            `REG_RST_WE(u_r_breip, 32,  clk, rst, ld_meta_w[gi],  in_breip_w[gi], breip_q[gi])
            `REG_RST_WE(u_r_brtgt, 32,  clk, rst, ld_meta_w[gi],  in_brtgt_w[gi], brtgt_q[gi])
            `REG_RST_WE(u_r_brxcl, 1,   clk, rst, ld_meta_w[gi],  in_brxcl_w[gi], brxcl_q[gi])
            `REG_RST_WE(u_r_data,  128, clk, rst, ld_data_w[gi],  in_data_w[gi],  data_q[gi])
        end
    endgenerate

    // ----------------------------------------------------------------
    // valid_slots = popcount(valid_q[3:0])  (4 -> 3 bits)
    // Two half-adders compress 4 bits -> two 2-bit pop counts, then
    // ADD_N(width=2) sums them into a 3-bit total {cout, sum[1:0]}.
    // ----------------------------------------------------------------
    wire pc01_xor_w, pc01_and_w;
    wire pc23_xor_w, pc23_and_w;
    `XOR_2(u_xor01, 1, pc01_xor_w, valid_q[0], valid_q[1])
    `XOR_2(u_xor23, 1, pc23_xor_w, valid_q[2], valid_q[3])
    `AND_2(u_and01, 1, pc01_and_w, valid_q[0], valid_q[1])
    `AND_2(u_and23, 1, pc23_and_w, valid_q[2], valid_q[3])

    wire [1:0] pc01_w, pc23_w;
    assign pc01_w = {pc01_and_w, pc01_xor_w};
    assign pc23_w = {pc23_and_w, pc23_xor_w};

    wire [1:0] sum_lo_w;
    wire       sum_hi_w;
    `ADD_N(u_count_add, 2, sum_lo_w, sum_hi_w, pc01_w, pc23_w, 1'b0)

    assign idm_outs_valid_slots = {sum_hi_w, sum_lo_w};

    // ----------------------------------------------------------------
    // Drive flat per-slot output ports from the internal q's.
    // ----------------------------------------------------------------
    assign idm_outs_idm_slots_0_valid         = valid_q[0];
    assign idm_outs_idm_slots_0_br_valid      = brval_q[0];
    assign idm_outs_idm_slots_0_br_eip        = breip_q[0];
    assign idm_outs_idm_slots_0_br_btb_target = brtgt_q[0];
    assign idm_outs_idm_slots_0_br_xcl        = brxcl_q[0];
    assign idm_outs_idm_slots_0_data          = data_q[0];

    assign idm_outs_idm_slots_1_valid         = valid_q[1];
    assign idm_outs_idm_slots_1_br_valid      = brval_q[1];
    assign idm_outs_idm_slots_1_br_eip        = breip_q[1];
    assign idm_outs_idm_slots_1_br_btb_target = brtgt_q[1];
    assign idm_outs_idm_slots_1_br_xcl        = brxcl_q[1];
    assign idm_outs_idm_slots_1_data          = data_q[1];

    assign idm_outs_idm_slots_2_valid         = valid_q[2];
    assign idm_outs_idm_slots_2_br_valid      = brval_q[2];
    assign idm_outs_idm_slots_2_br_eip        = breip_q[2];
    assign idm_outs_idm_slots_2_br_btb_target = brtgt_q[2];
    assign idm_outs_idm_slots_2_br_xcl        = brxcl_q[2];
    assign idm_outs_idm_slots_2_data          = data_q[2];

    assign idm_outs_idm_slots_3_valid         = valid_q[3];
    assign idm_outs_idm_slots_3_br_valid      = brval_q[3];
    assign idm_outs_idm_slots_3_br_eip        = breip_q[3];
    assign idm_outs_idm_slots_3_br_btb_target = brtgt_q[3];
    assign idm_outs_idm_slots_3_br_xcl        = brxcl_q[3];
    assign idm_outs_idm_slots_3_data          = data_q[3];

endmodule
