/*

    typedef struct {
        bool ST_OP;
        bool WB_DR;
        bool WB_SR;
        bool WB_EAX;
    } wb_cs_t;

    typedef struct {
        bool valid;
        wb_cs_t cs;
        bool ST_XCL;  //valid bit or second set of st info if st_op
        p_address_t ST_PADDR_0;  //cacheline algned
        uint16_t ST_BIT_VEC_0;  //where to write
        p_address_t ST_PADDR_1;  //cacheline algned
        uint16_t ST_BIT_VEC_1;  //where to write
        bool MIO;
        uint32_t EIP; //used for tagging insts, for edebugging
        byte_t res_buf[CACHE_LINES_SIZE_B*2];  //32 byte buf
        reg_ids_e sr_id;
        uint64_t  sr_data;
        reg_ids_e dr_id;
        uint64_t  dr_data;
        uint32_t EAX;

    } wb_latches_t;

*/

`define STRUCTURAL_WB_STAGE_LATCHES
`ifdef STRUCTURAL_WB_STAGE_LATCHES
//fully unrolled stage latch, every field of wb_latches_t gets its own port.
//res_buf is flattened to UINTCL_T_WIDTH*2 = 256 bits.
module WB_Latches (
    input wire clk,
    input wire rst,
    input wire write_enable_i,

    // ----- nextLatches_i (unrolled) -----
    input wire        nextLatches_valid_i,

    input wire        nextLatches_cs_ST_OP_i,
    input wire        nextLatches_cs_WB_DR_i,
    input wire        nextLatches_cs_WB_SR_i,
    input wire        nextLatches_cs_WB_EAX_i,

    input wire        nextLatches_ST_XCL_i,
    input wire [14:0] nextLatches_ST_PADDR_0_i,
    input wire [15:0] nextLatches_ST_BIT_VEC_0_i,
    input wire [14:0] nextLatches_ST_PADDR_1_i,
    input wire [15:0] nextLatches_ST_BIT_VEC_1_i,
    input wire        nextLatches_MIO_i,
    input wire [31:0] nextLatches_EIP_i,
    input wire [255:0] nextLatches_res_buf_i,
    input wire [4:0]  nextLatches_sr_id_i,
    input wire [63:0] nextLatches_sr_data_i,
    input wire [4:0]  nextLatches_dr_id_i,
    input wire [63:0] nextLatches_dr_data_i,
    input wire [31:0] nextLatches_EAX_i,

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

`else
module WB_Latches (
    input wire clk,
    input wire rst,
    input wb_latches_t nextLatches_i,
    input wire write_enable_i,
    output wb_latches_t latches_o
);

    // ---- alias wires (same names as the unrolled-port version) ----
    wire        nextLatches_valid_i;
    wire        nextLatches_cs_ST_OP_i;
    wire        nextLatches_cs_WB_DR_i;
    wire        nextLatches_cs_WB_SR_i;
    wire        nextLatches_cs_WB_EAX_i;
    wire        nextLatches_ST_XCL_i;
    wire [14:0] nextLatches_ST_PADDR_0_i;
    wire [15:0] nextLatches_ST_BIT_VEC_0_i;
    wire [14:0] nextLatches_ST_PADDR_1_i;
    wire [15:0] nextLatches_ST_BIT_VEC_1_i;
    wire        nextLatches_MIO_i;
    wire [31:0] nextLatches_EIP_i;
    wire [255:0] nextLatches_res_buf_i;
    wire [4:0]  nextLatches_sr_id_i;
    wire [63:0] nextLatches_sr_data_i;
    wire [4:0]  nextLatches_dr_id_i;
    wire [63:0] nextLatches_dr_data_i;
    wire [31:0] nextLatches_EAX_i;

    wire        latches_valid_o;
    wire        latches_cs_ST_OP_o;
    wire        latches_cs_WB_DR_o;
    wire        latches_cs_WB_SR_o;
    wire        latches_cs_WB_EAX_o;
    wire        latches_ST_XCL_o;
    wire [14:0] latches_ST_PADDR_0_o;
    wire [15:0] latches_ST_BIT_VEC_0_o;
    wire [14:0] latches_ST_PADDR_1_o;
    wire [15:0] latches_ST_BIT_VEC_1_o;
    wire        latches_MIO_o;
    wire [31:0] latches_EIP_o;
    wire [255:0] latches_res_buf_o;
    wire [4:0]  latches_sr_id_o;
    wire [63:0] latches_sr_data_o;
    wire [4:0]  latches_dr_id_o;
    wire [63:0] latches_dr_data_o;
    wire [31:0] latches_EAX_o;

    // ---- bridge SV struct fields -> alias wires ----
    assign nextLatches_valid_i        = nextLatches_i.valid;
    assign nextLatches_cs_ST_OP_i     = nextLatches_i.cs.ST_OP;
    assign nextLatches_cs_WB_DR_i     = nextLatches_i.cs.WB_DR;
    assign nextLatches_cs_WB_SR_i     = nextLatches_i.cs.WB_SR;
    assign nextLatches_cs_WB_EAX_i    = nextLatches_i.cs.WB_EAX;
    assign nextLatches_ST_XCL_i       = nextLatches_i.ST_XCL;
    assign nextLatches_ST_PADDR_0_i   = nextLatches_i.ST_PADDR_0;
    assign nextLatches_ST_BIT_VEC_0_i = nextLatches_i.ST_BIT_VEC_0;
    assign nextLatches_ST_PADDR_1_i   = nextLatches_i.ST_PADDR_1;
    assign nextLatches_ST_BIT_VEC_1_i = nextLatches_i.ST_BIT_VEC_1;
    assign nextLatches_MIO_i          = nextLatches_i.MIO;
    assign nextLatches_EIP_i          = nextLatches_i.EIP;
    assign nextLatches_sr_id_i        = nextLatches_i.sr_id;
    assign nextLatches_sr_data_i      = nextLatches_i.sr_data;
    assign nextLatches_dr_id_i        = nextLatches_i.dr_id;
    assign nextLatches_dr_data_i      = nextLatches_i.dr_data;
    assign nextLatches_EAX_i          = nextLatches_i.EAX;

    assign latches_o.valid        = latches_valid_o;
    assign latches_o.cs.ST_OP     = latches_cs_ST_OP_o;
    assign latches_o.cs.WB_DR     = latches_cs_WB_DR_o;
    assign latches_o.cs.WB_SR     = latches_cs_WB_SR_o;
    assign latches_o.cs.WB_EAX    = latches_cs_WB_EAX_o;
    assign latches_o.ST_XCL       = latches_ST_XCL_o;
    assign latches_o.ST_PADDR_0   = latches_ST_PADDR_0_o;
    assign latches_o.ST_BIT_VEC_0 = latches_ST_BIT_VEC_0_o;
    assign latches_o.ST_PADDR_1   = latches_ST_PADDR_1_o;
    assign latches_o.ST_BIT_VEC_1 = latches_ST_BIT_VEC_1_o;
    assign latches_o.MIO          = latches_MIO_o;
    assign latches_o.EIP          = latches_EIP_o;
    assign latches_o.sr_id        = latches_sr_id_o;
    assign latches_o.sr_data      = latches_sr_data_o;
    assign latches_o.dr_id        = latches_dr_id_o;
    assign latches_o.dr_data      = latches_dr_data_o;
    assign latches_o.EAX          = latches_EAX_o;

    // pack/unpack the res_buf unpacked byte array <-> 256-bit flat wire
    genvar gi;
    generate
        for (gi = 0; gi < 32; gi = gi + 1) begin : g_pack_res_buf
            assign nextLatches_res_buf_i[gi*8 +: 8] = nextLatches_i.res_buf[gi];
            assign latches_o.res_buf[gi]            = latches_res_buf_o[gi*8 +: 8];
        end
    endgenerate

`endif

    // ============================================================
    // Gate-level body (identical in both port modes)
    // `REG_RST_WE(__unitName__, __width__, __clk__, __rst__, __we__, __din__, __dout__)
    //   active async low rst
    // ============================================================

    `REG_RST_WE(wb_latches_valid,        1,   clk, rst, write_enable_i, nextLatches_valid_i,        latches_valid_o);

    `REG_RST_WE(wb_latches_cs_ST_OP,     1,   clk, rst, write_enable_i, nextLatches_cs_ST_OP_i,     latches_cs_ST_OP_o);
    `REG_RST_WE(wb_latches_cs_WB_DR,     1,   clk, rst, write_enable_i, nextLatches_cs_WB_DR_i,     latches_cs_WB_DR_o);
    `REG_RST_WE(wb_latches_cs_WB_SR,     1,   clk, rst, write_enable_i, nextLatches_cs_WB_SR_i,     latches_cs_WB_SR_o);
    `REG_RST_WE(wb_latches_cs_WB_EAX,    1,   clk, rst, write_enable_i, nextLatches_cs_WB_EAX_i,    latches_cs_WB_EAX_o);

    `REG_RST_WE(wb_latches_ST_XCL,       1,   clk, rst, write_enable_i, nextLatches_ST_XCL_i,       latches_ST_XCL_o);
    `REG_RST_WE(wb_latches_ST_PADDR_0,   15,  clk, rst, write_enable_i, nextLatches_ST_PADDR_0_i,   latches_ST_PADDR_0_o);
    `REG_RST_WE(wb_latches_ST_BIT_VEC_0, 16,  clk, rst, write_enable_i, nextLatches_ST_BIT_VEC_0_i, latches_ST_BIT_VEC_0_o);
    `REG_RST_WE(wb_latches_ST_PADDR_1,   15,  clk, rst, write_enable_i, nextLatches_ST_PADDR_1_i,   latches_ST_PADDR_1_o);
    `REG_RST_WE(wb_latches_ST_BIT_VEC_1, 16,  clk, rst, write_enable_i, nextLatches_ST_BIT_VEC_1_i, latches_ST_BIT_VEC_1_o);
    `REG_RST_WE(wb_latches_MIO,          1,   clk, rst, write_enable_i, nextLatches_MIO_i,          latches_MIO_o);
    `REG_RST_WE(wb_latches_EIP,          32,  clk, rst, write_enable_i, nextLatches_EIP_i,          latches_EIP_o);

    `REG_RST_WE(wb_latches_res_buf,      256, clk, rst, write_enable_i, nextLatches_res_buf_i,      latches_res_buf_o);

    `REG_RST_WE(wb_latches_sr_id,        5,   clk, rst, write_enable_i, nextLatches_sr_id_i,        latches_sr_id_o);
    `REG_RST_WE(wb_latches_sr_data,      64,  clk, rst, write_enable_i, nextLatches_sr_data_i,      latches_sr_data_o);
    `REG_RST_WE(wb_latches_dr_id,        5,   clk, rst, write_enable_i, nextLatches_dr_id_i,        latches_dr_id_o);
    `REG_RST_WE(wb_latches_dr_data,      64,  clk, rst, write_enable_i, nextLatches_dr_data_i,      latches_dr_data_o);
    `REG_RST_WE(wb_latches_EAX,          32,  clk, rst, write_enable_i, nextLatches_EAX_i,          latches_EAX_o);

endmodule
