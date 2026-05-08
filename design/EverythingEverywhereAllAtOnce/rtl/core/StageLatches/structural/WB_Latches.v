// =============================================================================
// WB_Latches  (pure Verilog-2005 structural stage latch)
//
//   Reference SV struct (kept for documentation):
//     typedef struct {
//         bool ST_OP; bool WB_DR; bool WB_SR; bool WB_EAX;
//     } wb_cs_t;
//
//     typedef struct {
//         bool valid;
//         wb_cs_t cs;
//         bool ST_XCL;
//         p_address_t ST_PADDR_0;     // 15 bits
//         uint16_t   ST_BIT_VEC_0;    // 16 bits
//         p_address_t ST_PADDR_1;     // 15 bits
//         uint16_t   ST_BIT_VEC_1;    // 16 bits
//         bool MIO;
//         uint32_t EIP;
//         byte_t res_buf[CACHE_LINES_SIZE_B*2];   // 256 bits packed
//         reg_ids_e sr_id;            // 5 bits
//         uint64_t  sr_data;
//         reg_ids_e dr_id;            // 5 bits
//         uint64_t  dr_data;
//         uint32_t  EAX;
//     } wb_latches_t;
//
//   - SV `import` removed; no struct/typedef/enum used.
//   - Every field is its own scalar/vector port (`.field` -> `_field`).
//   - res_buf is a single 256-bit packed bus on the boundary
//     (byte 0 = bits [7:0], matching the SV unpacked-array byte order).
// =============================================================================

module WB_Latches (
    input  wire        clk,
    input  wire        rst,
    input  wire        write_enable_i,

    // ----- nextLatches_i (unrolled) -----
    input  wire        nextLatches_valid_i,

    input  wire        nextLatches_cs_ST_OP_i,
    input  wire        nextLatches_cs_WB_DR_i,
    input  wire        nextLatches_cs_WB_SR_i,
    input  wire        nextLatches_cs_WB_EAX_i,

    input  wire        nextLatches_ST_XCL_i,
    input  wire [14:0] nextLatches_ST_PADDR_0_i,
    input  wire [15:0] nextLatches_ST_BIT_VEC_0_i,
    input  wire [14:0] nextLatches_ST_PADDR_1_i,
    input  wire [15:0] nextLatches_ST_BIT_VEC_1_i,
    input  wire        nextLatches_MIO_i,
    input  wire [31:0] nextLatches_EIP_i,
    input  wire [255:0] nextLatches_res_buf_i,
    input  wire [4:0]  nextLatches_sr_id_i,
    input  wire [63:0] nextLatches_sr_data_i,
    input  wire [4:0]  nextLatches_dr_id_i,
    input  wire [63:0] nextLatches_dr_data_i,
    input  wire [31:0] nextLatches_EAX_i,

    // ----- latches_o (unrolled) -----
    output wire        latches_valid_o,

    output wire        latches_cs_ST_OP_o,
    output wire        latches_cs_WB_DR_o,
    output wire        latches_cs_WB_SR_o,
    output wire        latches_cs_WB_EAX_o,

    output wire        latches_ST_XCL_o,
    output wire [14:0] latches_ST_PADDR_0_o,
    output wire [15:0] latches_ST_BIT_VEC_0_o,
    output wire [14:0] latches_ST_PADDR_1_o,
    output wire [15:0] latches_ST_BIT_VEC_1_o,
    output wire        latches_MIO_o,
    output wire [31:0] latches_EIP_o,
    output wire [255:0] latches_res_buf_o,
    output wire [4:0]  latches_sr_id_o,
    output wire [63:0] latches_sr_data_o,
    output wire [4:0]  latches_dr_id_o,
    output wire [63:0] latches_dr_data_o,
    output wire [31:0] latches_EAX_o
);

    // ============================================================
    // Gate-level body: one REG_RST_WE per former struct field.
    //   `REG_RST_WE(unit, width, clk, rst, we, din, dout)`  (async-low rst)
    // ============================================================

    // Staging wires for fanout-violating Q outputs
    wire        wb_latches_valid_pre_buf;
    wire [14:0] wb_latches_ST_PADDR_0_pre_buf;
    wire [14:0] wb_latches_ST_PADDR_1_pre_buf;
    wire [255:0] wb_latches_res_buf_pre_buf;

    `REG_RST_WE(wb_latches_valid,        1,   clk, rst, write_enable_i, nextLatches_valid_i,        wb_latches_valid_pre_buf)
    bufferH16$ u_attach_valid_0 (.out(latches_valid_o), .in(wb_latches_valid_pre_buf)); // fanout

    `REG_RST_WE(wb_latches_cs_ST_OP,     1,   clk, rst, write_enable_i, nextLatches_cs_ST_OP_i,     latches_cs_ST_OP_o)
    `REG_RST_WE(wb_latches_cs_WB_DR,     1,   clk, rst, write_enable_i, nextLatches_cs_WB_DR_i,     latches_cs_WB_DR_o)
    `REG_RST_WE(wb_latches_cs_WB_SR,     1,   clk, rst, write_enable_i, nextLatches_cs_WB_SR_i,     latches_cs_WB_SR_o)
    `REG_RST_WE(wb_latches_cs_WB_EAX,    1,   clk, rst, write_enable_i, nextLatches_cs_WB_EAX_i,    latches_cs_WB_EAX_o)

    `REG_RST_WE(wb_latches_ST_XCL,       1,   clk, rst, write_enable_i, nextLatches_ST_XCL_i,       latches_ST_XCL_o)
    `REG_RST_WE(wb_latches_ST_PADDR_0,   15,  clk, rst, write_enable_i, nextLatches_ST_PADDR_0_i,   wb_latches_ST_PADDR_0_pre_buf)
    // ST_PADDR_0: every bit feeds dep_check + DCache_Arb + forwarding paths
    // and the fanout checker reports each bit as a violation when surfaced
    // (it dedups per (reg, fanout) so one bit at a time becomes visible).
    // Bulk-buffer all 15 bits to converge in one shot.
    genvar gi_p0;
    generate
        for (gi_p0 = 0; gi_p0 <= 14; gi_p0 = gi_p0 + 1) begin : g_paddr0_buf
            bufferH16$ u_attach_ST_PADDR_0 (.out(latches_ST_PADDR_0_o[gi_p0]), .in(wb_latches_ST_PADDR_0_pre_buf[gi_p0]));
        end
    endgenerate

    `REG_RST_WE(wb_latches_ST_BIT_VEC_0, 16,  clk, rst, write_enable_i, nextLatches_ST_BIT_VEC_0_i, latches_ST_BIT_VEC_0_o)
    `REG_RST_WE(wb_latches_ST_PADDR_1,   15,  clk, rst, write_enable_i, nextLatches_ST_PADDR_1_i,   wb_latches_ST_PADDR_1_pre_buf)
    // ST_PADDR_1: same as ST_PADDR_0 -> bulk-buffer all 15 bits.
    genvar gi_p1;
    generate
        for (gi_p1 = 0; gi_p1 <= 14; gi_p1 = gi_p1 + 1) begin : g_paddr1_buf
            bufferH16$ u_attach_ST_PADDR_1 (.out(latches_ST_PADDR_1_o[gi_p1]), .in(wb_latches_ST_PADDR_1_pre_buf[gi_p1]));
        end
    endgenerate

    `REG_RST_WE(wb_latches_ST_BIT_VEC_1, 16,  clk, rst, write_enable_i, nextLatches_ST_BIT_VEC_1_i, latches_ST_BIT_VEC_1_o)
    `REG_RST_WE(wb_latches_MIO,          1,   clk, rst, write_enable_i, nextLatches_MIO_i,          latches_MIO_o)
    `REG_RST_WE(wb_latches_EIP,          32,  clk, rst, write_enable_i, nextLatches_EIP_i,          latches_EIP_o)

    `REG_RST_WE(wb_latches_res_buf,      256, clk, rst, write_enable_i, nextLatches_res_buf_i,      wb_latches_res_buf_pre_buf)
    // res_buf: every bit feeds the data-path forwarding / byte-enable muxes
    // with fanout >= 5 (the fanout checker dedups by representative so only
    // a couple bits surface at a time, but the whole-bus pattern is uniform).
    // Bulk-buffer all 256 bits through bufferH16$ -> each Q output drives a
    // single buffer input only.
    genvar gi_rb;
    generate
        for (gi_rb = 0; gi_rb <= 255; gi_rb = gi_rb + 1) begin : g_rb_buf
            bufferH16$ u_attach_res_buf (.out(latches_res_buf_o[gi_rb]), .in(wb_latches_res_buf_pre_buf[gi_rb]));
        end
    endgenerate

    `REG_RST_WE(wb_latches_sr_id,        5,   clk, rst, write_enable_i, nextLatches_sr_id_i,        latches_sr_id_o)
    `REG_RST_WE(wb_latches_sr_data,      64,  clk, rst, write_enable_i, nextLatches_sr_data_i,      latches_sr_data_o)
    `REG_RST_WE(wb_latches_dr_id,        5,   clk, rst, write_enable_i, nextLatches_dr_id_i,        latches_dr_id_o)
    `REG_RST_WE(wb_latches_dr_data,      64,  clk, rst, write_enable_i, nextLatches_dr_data_i,      latches_dr_data_o)
    `REG_RST_WE(wb_latches_EAX,          32,  clk, rst, write_enable_i, nextLatches_EAX_i,          latches_EAX_o)

endmodule
