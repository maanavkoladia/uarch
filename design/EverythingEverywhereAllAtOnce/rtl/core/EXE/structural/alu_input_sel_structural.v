// Structural Verilog 2005 port of EXE/alu_input_sel.sv
// Selects ALU operands srA_64, srB_64, branch source br_sel, and exp_ld_buf_o
// from a wide variety of inputs. Uses MUX_32 (one per output) with selector
// signals coming from latches.
//
// res_buf_in is a packed 256-bit wire (32 bytes, byte i in bits [8i+7:8i]).
// EXE.sv is responsible for flattening latches_i.ld_buf into this format.


module alu_input_sel (
    input  wire [`EXE_STRUCT_P_ADDR_W-1:0] ld_addr_0,  // p_address_t (15 bits)
    input  wire [255:0]                res_buf_in,    // packed 32 bytes
    input  wire [63:0]                 imm64,
    input  wire [63:0]                 sr_data,
    input  wire [63:0]                 dr_data,
    input  wire [31:0]                 EAX,
    input  wire [31:0]                 NEIP,
    input  wire [31:0]                 EIP,
    input  wire [31:0]                 flags,
    input  wire [`EXE_STRUCT_SRC_SEL_W-1:0] alu_inputA_sel,
    input  wire [`EXE_STRUCT_SRC_SEL_W-1:0] alu_inputB_sel,
    input  wire                        shift_sr_down,
    input  wire                        shift_sr_up,
    input  wire [`EXE_STRUCT_SRC_SEL_W-1:0] br_input_sel,

    output wire [63:0]                 exp_ld_buf_o,
    output wire [63:0]                 srA_64,
    output wire [63:0]                 srB_64,
    output wire [31:0]                 br_sel
);

    // -------------------------------------------------------------------------
    // res_buf_out : 16 bytes (128 bits) shifted from res_buf_in by ld_addr_0[3:0]
    // -------------------------------------------------------------------------
    wire [3:0] res_buf_offset;
    assign res_buf_offset = ld_addr_0[3:0];

    wire [127:0] res_buf_out;

    // Pre-buffer wires for the 4 MUX_16 byte outputs whose bits are read by
    // 5 leaf consumers each. Bytes 0/1: BUFFER+srA, BUFFER+srB, exp_ld_buf_o,
    // br_buf32, br_zext_buf16. Bytes 6/7: BUFFER+srA, IRETD+srA, BUFFER+srB,
    // IRETD+srB, exp_ld_buf_o (iretd_sel_val = res_buf_out[95:32]).
    wire [7:0] res_buf_b0_raw, res_buf_b1_raw, res_buf_b6_raw, res_buf_b7_raw;

    // 16 output bytes, each a MUX_16 over 16 candidate input bytes.
    // For output byte j, input byte at sel=o is res_buf_in byte (j+o).
    `MUX_16(u_rb_b0, 8, res_buf_b0_raw,
        res_buf_in[ 0*8 +: 8], res_buf_in[ 1*8 +: 8], res_buf_in[ 2*8 +: 8], res_buf_in[ 3*8 +: 8],
        res_buf_in[ 4*8 +: 8], res_buf_in[ 5*8 +: 8], res_buf_in[ 6*8 +: 8], res_buf_in[ 7*8 +: 8],
        res_buf_in[ 8*8 +: 8], res_buf_in[ 9*8 +: 8], res_buf_in[10*8 +: 8], res_buf_in[11*8 +: 8],
        res_buf_in[12*8 +: 8], res_buf_in[13*8 +: 8], res_buf_in[14*8 +: 8], res_buf_in[15*8 +: 8],
        res_buf_offset)
    `MUX_16(u_rb_b1, 8, res_buf_b1_raw,
        res_buf_in[ 1*8 +: 8], res_buf_in[ 2*8 +: 8], res_buf_in[ 3*8 +: 8], res_buf_in[ 4*8 +: 8],
        res_buf_in[ 5*8 +: 8], res_buf_in[ 6*8 +: 8], res_buf_in[ 7*8 +: 8], res_buf_in[ 8*8 +: 8],
        res_buf_in[ 9*8 +: 8], res_buf_in[10*8 +: 8], res_buf_in[11*8 +: 8], res_buf_in[12*8 +: 8],
        res_buf_in[13*8 +: 8], res_buf_in[14*8 +: 8], res_buf_in[15*8 +: 8], res_buf_in[16*8 +: 8],
        res_buf_offset)
    `MUX_16(u_rb_b2, 8, res_buf_out[23:16],
        res_buf_in[ 2*8 +: 8], res_buf_in[ 3*8 +: 8], res_buf_in[ 4*8 +: 8], res_buf_in[ 5*8 +: 8],
        res_buf_in[ 6*8 +: 8], res_buf_in[ 7*8 +: 8], res_buf_in[ 8*8 +: 8], res_buf_in[ 9*8 +: 8],
        res_buf_in[10*8 +: 8], res_buf_in[11*8 +: 8], res_buf_in[12*8 +: 8], res_buf_in[13*8 +: 8],
        res_buf_in[14*8 +: 8], res_buf_in[15*8 +: 8], res_buf_in[16*8 +: 8], res_buf_in[17*8 +: 8],
        res_buf_offset)
    `MUX_16(u_rb_b3, 8, res_buf_out[31:24],
        res_buf_in[ 3*8 +: 8], res_buf_in[ 4*8 +: 8], res_buf_in[ 5*8 +: 8], res_buf_in[ 6*8 +: 8],
        res_buf_in[ 7*8 +: 8], res_buf_in[ 8*8 +: 8], res_buf_in[ 9*8 +: 8], res_buf_in[10*8 +: 8],
        res_buf_in[11*8 +: 8], res_buf_in[12*8 +: 8], res_buf_in[13*8 +: 8], res_buf_in[14*8 +: 8],
        res_buf_in[15*8 +: 8], res_buf_in[16*8 +: 8], res_buf_in[17*8 +: 8], res_buf_in[18*8 +: 8],
        res_buf_offset)
    `MUX_16(u_rb_b4, 8, res_buf_out[39:32],
        res_buf_in[ 4*8 +: 8], res_buf_in[ 5*8 +: 8], res_buf_in[ 6*8 +: 8], res_buf_in[ 7*8 +: 8],
        res_buf_in[ 8*8 +: 8], res_buf_in[ 9*8 +: 8], res_buf_in[10*8 +: 8], res_buf_in[11*8 +: 8],
        res_buf_in[12*8 +: 8], res_buf_in[13*8 +: 8], res_buf_in[14*8 +: 8], res_buf_in[15*8 +: 8],
        res_buf_in[16*8 +: 8], res_buf_in[17*8 +: 8], res_buf_in[18*8 +: 8], res_buf_in[19*8 +: 8],
        res_buf_offset)
    `MUX_16(u_rb_b5, 8, res_buf_out[47:40],
        res_buf_in[ 5*8 +: 8], res_buf_in[ 6*8 +: 8], res_buf_in[ 7*8 +: 8], res_buf_in[ 8*8 +: 8],
        res_buf_in[ 9*8 +: 8], res_buf_in[10*8 +: 8], res_buf_in[11*8 +: 8], res_buf_in[12*8 +: 8],
        res_buf_in[13*8 +: 8], res_buf_in[14*8 +: 8], res_buf_in[15*8 +: 8], res_buf_in[16*8 +: 8],
        res_buf_in[17*8 +: 8], res_buf_in[18*8 +: 8], res_buf_in[19*8 +: 8], res_buf_in[20*8 +: 8],
        res_buf_offset)
    `MUX_16(u_rb_b6, 8, res_buf_b6_raw,
        res_buf_in[ 6*8 +: 8], res_buf_in[ 7*8 +: 8], res_buf_in[ 8*8 +: 8], res_buf_in[ 9*8 +: 8],
        res_buf_in[10*8 +: 8], res_buf_in[11*8 +: 8], res_buf_in[12*8 +: 8], res_buf_in[13*8 +: 8],
        res_buf_in[14*8 +: 8], res_buf_in[15*8 +: 8], res_buf_in[16*8 +: 8], res_buf_in[17*8 +: 8],
        res_buf_in[18*8 +: 8], res_buf_in[19*8 +: 8], res_buf_in[20*8 +: 8], res_buf_in[21*8 +: 8],
        res_buf_offset)
    `MUX_16(u_rb_b7, 8, res_buf_b7_raw,
        res_buf_in[ 7*8 +: 8], res_buf_in[ 8*8 +: 8], res_buf_in[ 9*8 +: 8], res_buf_in[10*8 +: 8],
        res_buf_in[11*8 +: 8], res_buf_in[12*8 +: 8], res_buf_in[13*8 +: 8], res_buf_in[14*8 +: 8],
        res_buf_in[15*8 +: 8], res_buf_in[16*8 +: 8], res_buf_in[17*8 +: 8], res_buf_in[18*8 +: 8],
        res_buf_in[19*8 +: 8], res_buf_in[20*8 +: 8], res_buf_in[21*8 +: 8], res_buf_in[22*8 +: 8],
        res_buf_offset)
    `MUX_16(u_rb_b8, 8, res_buf_out[71:64],
        res_buf_in[ 8*8 +: 8], res_buf_in[ 9*8 +: 8], res_buf_in[10*8 +: 8], res_buf_in[11*8 +: 8],
        res_buf_in[12*8 +: 8], res_buf_in[13*8 +: 8], res_buf_in[14*8 +: 8], res_buf_in[15*8 +: 8],
        res_buf_in[16*8 +: 8], res_buf_in[17*8 +: 8], res_buf_in[18*8 +: 8], res_buf_in[19*8 +: 8],
        res_buf_in[20*8 +: 8], res_buf_in[21*8 +: 8], res_buf_in[22*8 +: 8], res_buf_in[23*8 +: 8],
        res_buf_offset)
    `MUX_16(u_rb_b9, 8, res_buf_out[79:72],
        res_buf_in[ 9*8 +: 8], res_buf_in[10*8 +: 8], res_buf_in[11*8 +: 8], res_buf_in[12*8 +: 8],
        res_buf_in[13*8 +: 8], res_buf_in[14*8 +: 8], res_buf_in[15*8 +: 8], res_buf_in[16*8 +: 8],
        res_buf_in[17*8 +: 8], res_buf_in[18*8 +: 8], res_buf_in[19*8 +: 8], res_buf_in[20*8 +: 8],
        res_buf_in[21*8 +: 8], res_buf_in[22*8 +: 8], res_buf_in[23*8 +: 8], res_buf_in[24*8 +: 8],
        res_buf_offset)
    `MUX_16(u_rb_b10, 8, res_buf_out[87:80],
        res_buf_in[10*8 +: 8], res_buf_in[11*8 +: 8], res_buf_in[12*8 +: 8], res_buf_in[13*8 +: 8],
        res_buf_in[14*8 +: 8], res_buf_in[15*8 +: 8], res_buf_in[16*8 +: 8], res_buf_in[17*8 +: 8],
        res_buf_in[18*8 +: 8], res_buf_in[19*8 +: 8], res_buf_in[20*8 +: 8], res_buf_in[21*8 +: 8],
        res_buf_in[22*8 +: 8], res_buf_in[23*8 +: 8], res_buf_in[24*8 +: 8], res_buf_in[25*8 +: 8],
        res_buf_offset)
    `MUX_16(u_rb_b11, 8, res_buf_out[95:88],
        res_buf_in[11*8 +: 8], res_buf_in[12*8 +: 8], res_buf_in[13*8 +: 8], res_buf_in[14*8 +: 8],
        res_buf_in[15*8 +: 8], res_buf_in[16*8 +: 8], res_buf_in[17*8 +: 8], res_buf_in[18*8 +: 8],
        res_buf_in[19*8 +: 8], res_buf_in[20*8 +: 8], res_buf_in[21*8 +: 8], res_buf_in[22*8 +: 8],
        res_buf_in[23*8 +: 8], res_buf_in[24*8 +: 8], res_buf_in[25*8 +: 8], res_buf_in[26*8 +: 8],
        res_buf_offset)
    `MUX_16(u_rb_b12, 8, res_buf_out[103:96],
        res_buf_in[12*8 +: 8], res_buf_in[13*8 +: 8], res_buf_in[14*8 +: 8], res_buf_in[15*8 +: 8],
        res_buf_in[16*8 +: 8], res_buf_in[17*8 +: 8], res_buf_in[18*8 +: 8], res_buf_in[19*8 +: 8],
        res_buf_in[20*8 +: 8], res_buf_in[21*8 +: 8], res_buf_in[22*8 +: 8], res_buf_in[23*8 +: 8],
        res_buf_in[24*8 +: 8], res_buf_in[25*8 +: 8], res_buf_in[26*8 +: 8], res_buf_in[27*8 +: 8],
        res_buf_offset)
    `MUX_16(u_rb_b13, 8, res_buf_out[111:104],
        res_buf_in[13*8 +: 8], res_buf_in[14*8 +: 8], res_buf_in[15*8 +: 8], res_buf_in[16*8 +: 8],
        res_buf_in[17*8 +: 8], res_buf_in[18*8 +: 8], res_buf_in[19*8 +: 8], res_buf_in[20*8 +: 8],
        res_buf_in[21*8 +: 8], res_buf_in[22*8 +: 8], res_buf_in[23*8 +: 8], res_buf_in[24*8 +: 8],
        res_buf_in[25*8 +: 8], res_buf_in[26*8 +: 8], res_buf_in[27*8 +: 8], res_buf_in[28*8 +: 8],
        res_buf_offset)
    `MUX_16(u_rb_b14, 8, res_buf_out[119:112],
        res_buf_in[14*8 +: 8], res_buf_in[15*8 +: 8], res_buf_in[16*8 +: 8], res_buf_in[17*8 +: 8],
        res_buf_in[18*8 +: 8], res_buf_in[19*8 +: 8], res_buf_in[20*8 +: 8], res_buf_in[21*8 +: 8],
        res_buf_in[22*8 +: 8], res_buf_in[23*8 +: 8], res_buf_in[24*8 +: 8], res_buf_in[25*8 +: 8],
        res_buf_in[26*8 +: 8], res_buf_in[27*8 +: 8], res_buf_in[28*8 +: 8], res_buf_in[29*8 +: 8],
        res_buf_offset)
    `MUX_16(u_rb_b15, 8, res_buf_out[127:120],
        res_buf_in[15*8 +: 8], res_buf_in[16*8 +: 8], res_buf_in[17*8 +: 8], res_buf_in[18*8 +: 8],
        res_buf_in[19*8 +: 8], res_buf_in[20*8 +: 8], res_buf_in[21*8 +: 8], res_buf_in[22*8 +: 8],
        res_buf_in[23*8 +: 8], res_buf_in[24*8 +: 8], res_buf_in[25*8 +: 8], res_buf_in[26*8 +: 8],
        res_buf_in[27*8 +: 8], res_buf_in[28*8 +: 8], res_buf_in[29*8 +: 8], res_buf_in[30*8 +: 8],
        res_buf_offset)

    // Buffer the 4 high-fanout byte slices with bufferH16$ (0.24 ns typ,
    // rated 16 loads). Fanout=5 per bit fits comfortably; smaller H-buffers
    // don't exist, larger ones add delay without benefit.
    genvar gi_buf_rb;
    generate
        for (gi_buf_rb = 0; gi_buf_rb < 8; gi_buf_rb = gi_buf_rb + 1) begin : g_rb_byte_buf
            bufferH16$ u_buf_b0 (.out(res_buf_out[     gi_buf_rb]), .in(res_buf_b0_raw[gi_buf_rb]));
            bufferH16$ u_buf_b1 (.out(res_buf_out[ 8 + gi_buf_rb]), .in(res_buf_b1_raw[gi_buf_rb]));
            bufferH16$ u_buf_b6 (.out(res_buf_out[48 + gi_buf_rb]), .in(res_buf_b6_raw[gi_buf_rb]));
            bufferH16$ u_buf_b7 (.out(res_buf_out[56 + gi_buf_rb]), .in(res_buf_b7_raw[gi_buf_rb]));
        end
    endgenerate

    // exp_ld_buf_o = res_buf_out[63:0]
    assign exp_ld_buf_o = res_buf_out[63:0];

    // -------------------------------------------------------------------------
    // Common candidate values for srA / srB
    // -------------------------------------------------------------------------
    wire [63:0] zero64;
    assign zero64 = 64'h0;

    // Sign-extend imm64[7:0] → 32-bit, zero-extend to 64-bit.
    wire [63:0] sext8_64;
    assign sext8_64 = {32'h0, {24{imm64[7]}}, imm64[7:0]};

    wire [63:0] zext_neip;     assign zext_neip     = {32'h0, NEIP};
    wire [63:0] zext_eip;      assign zext_eip      = {32'h0, EIP};
    wire [63:0] zext_eax;      assign zext_eax      = {32'h0, EAX};
    wire [63:0] zext_flags;    assign zext_flags    = {32'h0, flags};
    wire [63:0] segment_neip;  assign segment_neip  = {dr_data[31:0], NEIP};      // for srA
    wire [63:0] segment_eip_a; assign segment_eip_a = {EIP, dr_data[31:0]};       // for srA
    wire [63:0] sr_dr_concat;  assign sr_dr_concat  = {sr_data[31:0], dr_data[31:0]};
    wire [63:0] cmpxchg_pair;  assign cmpxchg_pair  = {sr_data[31:0], EAX};       // {sr_data, EAX}[63:0]
    wire [63:0] iretd_sel_val; assign iretd_sel_val = res_buf_out[95:32];

    // Pre-buffer wires; the actual output ports srA_64 / srB_64 are driven
    // by bufferH256$ at the bottom of the module to handle their high fanout
    // across EXE's functional units.
    wire [63:0] srA_64_raw;
    wire [63:0] srB_64_raw;

    // -------------------------------------------------------------------------
    // srA_64 selection (MUX_32 over 14 used + 18 unused-zero entries)
    //   index encoding follows source_selector_e
    // -------------------------------------------------------------------------
    `MUX_32(u_mux_srA, 64, srA_64_raw,
        zero64,           // 0  NO_EXE
        sr_data,          // 1  SR_REGISTER
        dr_data,          // 2  DR_REGISTER
        res_buf_out[63:0],// 3  BUFFER
        zext_neip,        // 4  NEIP
        zext_eax,         // 5  EAX_REG
        sext8_64,         // 6  SEXT8
        segment_neip,     // 7  SEGMENT_NEIP
        imm64,            // 8  IMM64
        zero64,           // 9  IMM32  (unused for srA)
        zero64,           // 10 ZEXT_IMM8 (unused)
        zero64,           // 11 BUF32 (unused)
        zero64,           // 12 ZEXT_BUF16 (unused)
        zero64,           // 13 ZEXT_IMM16 (unused)
        segment_eip_a,    // 14 SEGMENT_EIP
        zext_flags,       // 15 FLAGS
        zext_eip,         // 16 EIP
        zero64,           // 17 CMPXCHG_SEL (unused for srA)
        sr_dr_concat,     // 18 SR_DR_SEL
        iretd_sel_val,    // 19 IRETD_SEL
        zero64, zero64, zero64, zero64,         // 20..23 (unused)
        zero64, zero64, zero64, zero64,         // 24..27
        zero64, zero64, zero64, zero64,         // 28..31
        alu_inputA_sel)

    // -------------------------------------------------------------------------
    // srB selection — produces srB before the optional shift_sr_*
    //   Note: SV uses SV-truncating concatenation; preserve those exact lower-64 results.
    //   {NEIP, dr_data}[63:0]    = dr_data
    //   {EIP, dr_data}[63:0]     = dr_data
    //   {sr_data, EAX}[63:0]     = {sr_data[31:0], EAX}
    // -------------------------------------------------------------------------
    wire [63:0] srB_pre;
    `MUX_32(u_mux_srB_pre, 64, srB_pre,
        zero64,           // 0  NO_EXE
        sr_data,          // 1  SR_REGISTER
        dr_data,          // 2  DR_REGISTER
        res_buf_out[63:0],// 3  BUFFER
        zext_neip,        // 4  NEIP   (srB: {32'd0, NEIP})
        zext_eax,         // 5  EAX_REG
        sext8_64,         // 6  SEXT8
        dr_data,          // 7  SEGMENT_NEIP — preserved truncation: {NEIP,dr_data}[63:0]=dr_data
        imm64,            // 8  IMM64
        zero64,           // 9  IMM32  (unused for srB)
        zero64,           // 10 ZEXT_IMM8
        zero64,           // 11 BUF32
        zero64,           // 12 ZEXT_BUF16
        zero64,           // 13 ZEXT_IMM16
        dr_data,          // 14 SEGMENT_EIP — preserved truncation: {EIP,dr_data}[63:0]=dr_data
        zext_flags,       // 15 FLAGS
        zero64,           // 16 EIP (unused for srB)
        cmpxchg_pair,     // 17 CMPXCHG_SEL
        zero64,           // 18 SR_DR_SEL (unused for srB)
        iretd_sel_val,    // 19 IRETD_SEL
        zero64, zero64, zero64, zero64,
        zero64, zero64, zero64, zero64,
        zero64, zero64, zero64, zero64,
        alu_inputB_sel)

    // -------------------------------------------------------------------------
    // Apply shift_sr_down / shift_sr_up to srB_pre to produce srB_64
    //   shift_sr_down → {8'h0,   srB_pre[63:8]}
    //   shift_sr_up   → {srB_pre[56:0], 8'h0}
    //   shift_sr_up takes precedence over shift_sr_down (SV always_comb order)
    // -------------------------------------------------------------------------
    wire [63:0] srB_shift_down;
    wire [63:0] srB_shift_up;
    assign srB_shift_down = {8'h0, srB_pre[63:8]};
    assign srB_shift_up   = {srB_pre[56:0], 8'h0};

    wire [63:0] srB_after_down;
    `MUX_2(u_mux_srB_down, 64, srB_after_down, srB_pre, srB_shift_down, shift_sr_down)
    `MUX_2(u_mux_srB_up,   64, srB_64_raw,     srB_after_down, srB_shift_up, shift_sr_up)

    // -------------------------------------------------------------------------
    // br_sel (32-bit) selection
    // -------------------------------------------------------------------------
    wire [31:0] zero32;
    assign zero32 = 32'h0;
    wire [31:0] br_zext_imm16;
    assign br_zext_imm16 = {16'h0, imm64[15:0]};
    wire [31:0] br_imm32;
    assign br_imm32 = imm64[31:0];
    wire [31:0] br_zext_buf16;
    assign br_zext_buf16 = {16'h0, res_buf_out[15:0]};
    wire [31:0] br_buf32;
    assign br_buf32 = res_buf_out[31:0];

    `MUX_32(u_mux_br, 32, br_sel,
        zero32,         // 0  NO_EXE
        sr_data[31:0],  // 1  SR_REGISTER
        dr_data[31:0],  // 2  DR_REGISTER
        zero32,         // 3  BUFFER (unused for br)
        zero32,         // 4  NEIP (unused)
        zero32,         // 5  EAX_REG (unused)
        zero32,         // 6  SEXT8 (unused)
        zero32,         // 7  SEGMENT_NEIP (unused)
        zero32,         // 8  IMM64 (unused)
        br_imm32,       // 9  IMM32
        zero32,         // 10 ZEXT_IMM8 (unused)
        br_buf32,       // 11 BUF32
        br_zext_buf16,  // 12 ZEXT_BUF16
        br_zext_imm16,  // 13 ZEXT_IMM16
        zero32,         // 14 SEGMENT_EIP (unused)
        zero32,         // 15 FLAGS (unused)
        zero32,         // 16 EIP (unused)
        zero32,         // 17 CMPXCHG_SEL (unused)
        zero32,         // 18 SR_DR_SEL (unused)
        zero32,         // 19 IRETD_SEL (unused)
        zero32, zero32, zero32, zero32,
        zero32, zero32, zero32, zero32,
        zero32, zero32, zero32, zero32,
        br_input_sel)

    // -------------------------------------------------------------------------
    // Output buffering for high-fanout operand ports.
    //   srA_64 worst-case fanout ~178 across all 64 bits
    //   srB_64 worst-case fanout ~74  across all 64 bits
    // bufferH256$ is the smallest H-buffer covering 178 loads (rated <=256,
    // 0.54 ns typ). bufferH64$ would be faster (0.30 ns) but tops out at 64
    // loads, so it can't safely cover srA_64 (or the 65+ bits of srB_64).
    // bufferH1024$ / bufferH4096$ work but cost extra delay (0.60 / 0.80 ns).
    // Using the same cell for both signals keeps the operand-arrival skew
    // matched at the FU inputs.
    // -------------------------------------------------------------------------
    genvar gi_buf;
    generate
        for (gi_buf = 0; gi_buf < 64; gi_buf = gi_buf + 1) begin : g_out_buf
            bufferH256$ u_buf_srA (.out(srA_64[gi_buf]), .in(srA_64_raw[gi_buf]));
            bufferH256$ u_buf_srB (.out(srB_64[gi_buf]), .in(srB_64_raw[gi_buf]));
        end
    endgenerate

endmodule
