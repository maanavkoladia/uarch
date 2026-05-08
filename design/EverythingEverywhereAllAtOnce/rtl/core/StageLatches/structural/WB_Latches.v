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
    // ST_PADDR_0: only bit 14 violates -> attached buffer; other bits pass through
    assign latches_ST_PADDR_0_o[13:0] = wb_latches_ST_PADDR_0_pre_buf[13:0];
    bufferH16$ u_attach_ST_PADDR_0_14 (.out(latches_ST_PADDR_0_o[14]), .in(wb_latches_ST_PADDR_0_pre_buf[14])); // fanout

    `REG_RST_WE(wb_latches_ST_BIT_VEC_0, 16,  clk, rst, write_enable_i, nextLatches_ST_BIT_VEC_0_i, latches_ST_BIT_VEC_0_o)
    `REG_RST_WE(wb_latches_ST_PADDR_1,   15,  clk, rst, write_enable_i, nextLatches_ST_PADDR_1_i,   wb_latches_ST_PADDR_1_pre_buf)
    // ST_PADDR_1: only bit 14 violates -> attached buffer; other bits pass through
    assign latches_ST_PADDR_1_o[13:0] = wb_latches_ST_PADDR_1_pre_buf[13:0];
    bufferH16$ u_attach_ST_PADDR_1_14 (.out(latches_ST_PADDR_1_o[14]), .in(wb_latches_ST_PADDR_1_pre_buf[14])); // fanout

    `REG_RST_WE(wb_latches_ST_BIT_VEC_1, 16,  clk, rst, write_enable_i, nextLatches_ST_BIT_VEC_1_i, latches_ST_BIT_VEC_1_o)
    `REG_RST_WE(wb_latches_MIO,          1,   clk, rst, write_enable_i, nextLatches_MIO_i,          latches_MIO_o)
    `REG_RST_WE(wb_latches_EIP,          32,  clk, rst, write_enable_i, nextLatches_EIP_i,          latches_EIP_o)

    `REG_RST_WE(wb_latches_res_buf,      256, clk, rst, write_enable_i, nextLatches_res_buf_i,      wb_latches_res_buf_pre_buf)
    // res_buf: bits 63 and 127 violate -> attached buffers; other bits pass through
    assign latches_res_buf_o[62:0]    = wb_latches_res_buf_pre_buf[62:0];
    bufferH16$ u_attach_res_buf_63  (.out(latches_res_buf_o[63]),  .in(wb_latches_res_buf_pre_buf[63])); // fanout
    assign latches_res_buf_o[126:64]  = wb_latches_res_buf_pre_buf[126:64];
    bufferH16$ u_attach_res_buf_127 (.out(latches_res_buf_o[127]), .in(wb_latches_res_buf_pre_buf[127])); // fanout
    assign latches_res_buf_o[255:128] = wb_latches_res_buf_pre_buf[255:128];

    `REG_RST_WE(wb_latches_sr_id,        5,   clk, rst, write_enable_i, nextLatches_sr_id_i,        latches_sr_id_o)
    `REG_RST_WE(wb_latches_sr_data,      64,  clk, rst, write_enable_i, nextLatches_sr_data_i,      latches_sr_data_o)
    `REG_RST_WE(wb_latches_dr_id,        5,   clk, rst, write_enable_i, nextLatches_dr_id_i,        latches_dr_id_o)
    `REG_RST_WE(wb_latches_dr_data,      64,  clk, rst, write_enable_i, nextLatches_dr_data_i,      latches_dr_data_o)
    `REG_RST_WE(wb_latches_EAX,          32,  clk, rst, write_enable_i, nextLatches_EAX_i,          latches_EAX_o)

endmodule
