module RegFile (
    input  wire        clk,
    input  wire        rst,
    input  wire [4:0]  DR_ID,
    input  wire [4:0]  SR_ID,
    input  wire [4:0]  SIB_IDX_ID,
    input  wire [4:0]  SIB_BASE_ID,
    input  wire [63:0] WB_DR0_data,
    input  wire [63:0] WB_DR1_data,
    input  wire [4:0]  WB_DR0_ID,
    input  wire [4:0]  WB_DR1_ID,
    input  wire        WB_DR0_we,
    input  wire        WB_DR1_we,
    input  wire [4:0]  Segment0_ID,
    input  wire [4:0]  Segment1_ID,

    output wire [63:0] DR_data,
    output wire [63:0] SR_data,
    output wire [31:0] SIB_IDX_data,
    output wire [31:0] SIB_BASE_data,
    output wire [31:0] ECX_data,
    output wire [31:0] EAX_data,
    output wire [31:0] CS_data,
    output wire [31:0] Segment0_data,
    output wire [31:0] Segment1_data,

    output wire [63:0] REG_CS_o,
    output wire [63:0] REG_DS_o,
    output wire [63:0] REG_SS_o,
    output wire [63:0] REG_ES_o,
    output wire [63:0] REG_FS_o,
    output wire [63:0] REG_GS_o,
    output wire [63:0] REG_EXPS_o,
    output wire [63:0] REG_EAX_o,
    output wire [63:0] REG_EBX_o,
    output wire [63:0] REG_ECX_o,
    output wire [63:0] REG_EDX_o,
    output wire [63:0] REG_ESI_o,
    output wire [63:0] REG_EDI_o,
    output wire [63:0] REG_ESP_o,
    output wire [63:0] REG_EBP_o,
    output wire [63:0] REG_MM0_o,
    output wire [63:0] REG_MM1_o,
    output wire [63:0] REG_MM2_o,
    output wire [63:0] REG_MM3_o,
    output wire [63:0] REG_MM4_o,
    output wire [63:0] REG_MM5_o,
    output wire [63:0] REG_MM6_o,
    output wire [63:0] REG_MM7_o,
    output wire [63:0] REG_ETR_o,
    output wire [63:0] REG_ERROR_REG_o,
    output wire [63:0] REG_NO_REG_o
);

    //=========================================================================
    // Per-register write path
    //   For each register R with numeric ID i:
    //     match0_R = (WB_DR0_ID == i)
    //     match1_R = (WB_DR1_ID == i)
    //     we0_R    = WB_DR0_we & match0_R
    //     we1_R    = WB_DR1_we & match1_R
    //     we_R     = we0_R | we1_R
    //     din_R    = we0_R ? WB_DR0_data : WB_DR1_data   (DR0 wins on collision)
    //     REG_R    = REG_RST_WE(clk, rst, we_R, din_R)
    //=========================================================================

    // ----- CS  (ID 0) -----
    // Two register copies, same we/din:
    //   _a -> DR/SR/SIB_IDX read muxes + REG_CS_o port (~3-4 fanout)
    //   _b -> SIB_BASE/Seg0/Seg1 muxes + CS_data alias  (~3-4 fanout)
    // No output buffer needed — duplication keeps per-Q fanout in-spec.
    wire        match0_CS, match1_CS, we0_CS_pre, we0_CS, we1_CS, we_CS;
    wire [63:0] din_CS;
    `CMP_N(cmp0_CS, 5, match0_CS, WB_DR0_ID, 5'd0)
    `CMP_N(cmp1_CS, 5, match1_CS, WB_DR1_ID, 5'd0)
    `AND_2(and_we0_CS, 1, we0_CS_pre, WB_DR0_we, match0_CS)
    bufferH256$ u_buf_we0_CS (.out(we0_CS), .in(we0_CS_pre));
    `AND_2(and_we1_CS, 1, we1_CS, WB_DR1_we, match1_CS)
    `OR_2 (or_we_CS,   1, we_CS,  we0_CS, we1_CS)
    `MUX_2(mux_din_CS, 64, din_CS, WB_DR1_data, WB_DR0_data, we0_CS)
    wire [63:0] REG_CS_a_o, REG_CS_b_o;
    wire [63:0] REG_CS_a_o_pre_buf, REG_CS_b_o_pre_buf;
    `REG_RST_WE(REG_CS_a, 64, clk, rst, we_CS, din_CS, REG_CS_a_o_pre_buf)
    `REG_RST_WE(REG_CS_b, 64, clk, rst, we_CS, din_CS, REG_CS_b_o_pre_buf)
    // fanout buf attach
    bufferH16$ u_attach_REG_CS_a_q_31 (.out(REG_CS_a_o[31]), .in(REG_CS_a_o_pre_buf[31]));
    bufferH16$ u_attach_REG_CS_b_q_15 (.out(REG_CS_b_o[15]), .in(REG_CS_b_o_pre_buf[15]));
    assign REG_CS_a_o[63:32] = REG_CS_a_o_pre_buf[63:32];
    assign REG_CS_a_o[30:0]  = REG_CS_a_o_pre_buf[30:0];
    assign REG_CS_b_o[63:16] = REG_CS_b_o_pre_buf[63:16];
    assign REG_CS_b_o[14:0]  = REG_CS_b_o_pre_buf[14:0];
    assign REG_CS_o = REG_CS_a_o;

    // ----- DS  (ID 1) -----
    wire        match0_DS, match1_DS, we0_DS_pre, we0_DS, we1_DS, we_DS;
    wire [63:0] din_DS;
    `CMP_N(cmp0_DS, 5, match0_DS, WB_DR0_ID, 5'd1)
    `CMP_N(cmp1_DS, 5, match1_DS, WB_DR1_ID, 5'd1)
    `AND_2(and_we0_DS, 1, we0_DS_pre, WB_DR0_we, match0_DS)
    bufferH256$ u_buf_we0_DS (.out(we0_DS), .in(we0_DS_pre));
    `AND_2(and_we1_DS, 1, we1_DS, WB_DR1_we, match1_DS)
    `OR_2 (or_we_DS,   1, we_DS,  we0_DS, we1_DS)
    `MUX_2(mux_din_DS, 64, din_DS, WB_DR1_data, WB_DR0_data, we0_DS)
    wire [63:0] REG_DS_a_o, REG_DS_b_o;
    wire [63:0] REG_DS_a_o_pre_buf;
    `REG_RST_WE(REG_DS_a, 64, clk, rst, we_DS, din_DS, REG_DS_a_o_pre_buf)
    `REG_RST_WE(REG_DS_b, 64, clk, rst, we_DS, din_DS, REG_DS_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_DS_a_q_31 (.out(REG_DS_a_o[31]), .in(REG_DS_a_o_pre_buf[31]));
    assign REG_DS_a_o[63:32] = REG_DS_a_o_pre_buf[63:32];
    assign REG_DS_a_o[30:0]  = REG_DS_a_o_pre_buf[30:0];
    assign REG_DS_o = REG_DS_a_o;

    // ----- SS  (ID 2) -----
    wire        match0_SS, match1_SS, we0_SS_pre, we0_SS, we1_SS, we_SS;
    wire [63:0] din_SS;
    `CMP_N(cmp0_SS, 5, match0_SS, WB_DR0_ID, 5'd2)
    `CMP_N(cmp1_SS, 5, match1_SS, WB_DR1_ID, 5'd2)
    `AND_2(and_we0_SS, 1, we0_SS_pre, WB_DR0_we, match0_SS)
    bufferH256$ u_buf_we0_SS (.out(we0_SS), .in(we0_SS_pre));
    `AND_2(and_we1_SS, 1, we1_SS, WB_DR1_we, match1_SS)
    `OR_2 (or_we_SS,   1, we_SS,  we0_SS, we1_SS)
    `MUX_2(mux_din_SS, 64, din_SS, WB_DR1_data, WB_DR0_data, we0_SS)
    wire [63:0] REG_SS_a_o, REG_SS_b_o;
    wire [63:0] REG_SS_a_o_pre_buf;
    `REG_RST_WE(REG_SS_a, 64, clk, rst, we_SS, din_SS, REG_SS_a_o_pre_buf)
    `REG_RST_WE(REG_SS_b, 64, clk, rst, we_SS, din_SS, REG_SS_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_SS_a_q_31 (.out(REG_SS_a_o[31]), .in(REG_SS_a_o_pre_buf[31]));
    assign REG_SS_a_o[63:32] = REG_SS_a_o_pre_buf[63:32];
    assign REG_SS_a_o[30:0]  = REG_SS_a_o_pre_buf[30:0];
    assign REG_SS_o = REG_SS_a_o;

    // ----- ES  (ID 3) -----
    wire        match0_ES, match1_ES, we0_ES_pre, we0_ES, we1_ES, we_ES;
    wire [63:0] din_ES;
    `CMP_N(cmp0_ES, 5, match0_ES, WB_DR0_ID, 5'd3)
    `CMP_N(cmp1_ES, 5, match1_ES, WB_DR1_ID, 5'd3)
    `AND_2(and_we0_ES, 1, we0_ES_pre, WB_DR0_we, match0_ES)
    bufferH256$ u_buf_we0_ES (.out(we0_ES), .in(we0_ES_pre));
    `AND_2(and_we1_ES, 1, we1_ES, WB_DR1_we, match1_ES)
    `OR_2 (or_we_ES,   1, we_ES,  we0_ES, we1_ES)
    `MUX_2(mux_din_ES, 64, din_ES, WB_DR1_data, WB_DR0_data, we0_ES)
    wire [63:0] REG_ES_a_o, REG_ES_b_o;
    wire [63:0] REG_ES_a_o_pre_buf;
    `REG_RST_WE(REG_ES_a, 64, clk, rst, we_ES, din_ES, REG_ES_a_o_pre_buf)
    `REG_RST_WE(REG_ES_b, 64, clk, rst, we_ES, din_ES, REG_ES_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_ES_a_q_31 (.out(REG_ES_a_o[31]), .in(REG_ES_a_o_pre_buf[31]));
    assign REG_ES_a_o[63:32] = REG_ES_a_o_pre_buf[63:32];
    assign REG_ES_a_o[30:0]  = REG_ES_a_o_pre_buf[30:0];
    assign REG_ES_o = REG_ES_a_o;

    // ----- FS  (ID 4) -----
    wire        match0_FS, match1_FS, we0_FS_pre, we0_FS, we1_FS, we_FS;
    wire [63:0] din_FS;
    `CMP_N(cmp0_FS, 5, match0_FS, WB_DR0_ID, 5'd4)
    `CMP_N(cmp1_FS, 5, match1_FS, WB_DR1_ID, 5'd4)
    `AND_2(and_we0_FS, 1, we0_FS_pre, WB_DR0_we, match0_FS)
    bufferH256$ u_buf_we0_FS (.out(we0_FS), .in(we0_FS_pre));
    `AND_2(and_we1_FS, 1, we1_FS, WB_DR1_we, match1_FS)
    `OR_2 (or_we_FS,   1, we_FS,  we0_FS, we1_FS)
    `MUX_2(mux_din_FS, 64, din_FS, WB_DR1_data, WB_DR0_data, we0_FS)
    wire [63:0] REG_FS_a_o, REG_FS_b_o;
    wire [63:0] REG_FS_a_o_pre_buf;
    `REG_RST_WE(REG_FS_a, 64, clk, rst, we_FS, din_FS, REG_FS_a_o_pre_buf)
    `REG_RST_WE(REG_FS_b, 64, clk, rst, we_FS, din_FS, REG_FS_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_FS_a_q_31 (.out(REG_FS_a_o[31]), .in(REG_FS_a_o_pre_buf[31]));
    assign REG_FS_a_o[63:32] = REG_FS_a_o_pre_buf[63:32];
    assign REG_FS_a_o[30:0]  = REG_FS_a_o_pre_buf[30:0];
    assign REG_FS_o = REG_FS_a_o;

    // ----- GS  (ID 5) -----
    wire        match0_GS, match1_GS, we0_GS_pre, we0_GS, we1_GS, we_GS;
    wire [63:0] din_GS;
    `CMP_N(cmp0_GS, 5, match0_GS, WB_DR0_ID, 5'd5)
    `CMP_N(cmp1_GS, 5, match1_GS, WB_DR1_ID, 5'd5)
    `AND_2(and_we0_GS, 1, we0_GS_pre, WB_DR0_we, match0_GS)
    bufferH256$ u_buf_we0_GS (.out(we0_GS), .in(we0_GS_pre));
    `AND_2(and_we1_GS, 1, we1_GS, WB_DR1_we, match1_GS)
    `OR_2 (or_we_GS,   1, we_GS,  we0_GS, we1_GS)
    `MUX_2(mux_din_GS, 64, din_GS, WB_DR1_data, WB_DR0_data, we0_GS)
    wire [63:0] REG_GS_a_o, REG_GS_b_o;
    wire [63:0] REG_GS_a_o_pre_buf;
    `REG_RST_WE(REG_GS_a, 64, clk, rst, we_GS, din_GS, REG_GS_a_o_pre_buf)
    `REG_RST_WE(REG_GS_b, 64, clk, rst, we_GS, din_GS, REG_GS_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_GS_a_q_31 (.out(REG_GS_a_o[31]), .in(REG_GS_a_o_pre_buf[31]));
    assign REG_GS_a_o[63:32] = REG_GS_a_o_pre_buf[63:32];
    assign REG_GS_a_o[30:0]  = REG_GS_a_o_pre_buf[30:0];
    assign REG_GS_o = REG_GS_a_o;

    // ----- EXPS  (ID 6) -----
    wire        match0_EXPS, match1_EXPS, we0_EXPS_pre, we0_EXPS, we1_EXPS, we_EXPS;
    wire [63:0] din_EXPS;
    `CMP_N(cmp0_EXPS, 5, match0_EXPS, WB_DR0_ID, 5'd6)
    `CMP_N(cmp1_EXPS, 5, match1_EXPS, WB_DR1_ID, 5'd6)
    `AND_2(and_we0_EXPS, 1, we0_EXPS_pre, WB_DR0_we, match0_EXPS)
    bufferH256$ u_buf_we0_EXPS (.out(we0_EXPS), .in(we0_EXPS_pre));
    `AND_2(and_we1_EXPS, 1, we1_EXPS, WB_DR1_we, match1_EXPS)
    `OR_2 (or_we_EXPS,   1, we_EXPS,  we0_EXPS, we1_EXPS)
    `MUX_2(mux_din_EXPS, 64, din_EXPS, WB_DR1_data, WB_DR0_data, we0_EXPS)
    wire [63:0] REG_EXPS_a_o, REG_EXPS_b_o;
    wire [63:0] REG_EXPS_a_o_pre_buf;
    `REG_RST_WE(REG_EXPS_a, 64, clk, rst, we_EXPS, din_EXPS, REG_EXPS_a_o_pre_buf)
    `REG_RST_WE(REG_EXPS_b, 64, clk, rst, we_EXPS, din_EXPS, REG_EXPS_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_EXPS_a_q_31 (.out(REG_EXPS_a_o[31]), .in(REG_EXPS_a_o_pre_buf[31]));
    assign REG_EXPS_a_o[63:32] = REG_EXPS_a_o_pre_buf[63:32];
    assign REG_EXPS_a_o[30:0]  = REG_EXPS_a_o_pre_buf[30:0];
    assign REG_EXPS_o = REG_EXPS_a_o;

    // ----- EAX  (ID 7) -----
    wire        match0_EAX, match1_EAX, we0_EAX_pre, we0_EAX, we1_EAX, we_EAX;
    wire [63:0] din_EAX;
    `CMP_N(cmp0_EAX, 5, match0_EAX, WB_DR0_ID, 5'd7)
    `CMP_N(cmp1_EAX, 5, match1_EAX, WB_DR1_ID, 5'd7)
    `AND_2(and_we0_EAX, 1, we0_EAX_pre, WB_DR0_we, match0_EAX)
    bufferH256$ u_buf_we0_EAX (.out(we0_EAX), .in(we0_EAX_pre));
    `AND_2(and_we1_EAX, 1, we1_EAX, WB_DR1_we, match1_EAX)
    `OR_2 (or_we_EAX,   1, we_EAX,  we0_EAX, we1_EAX)
    `MUX_2(mux_din_EAX, 64, din_EAX, WB_DR1_data, WB_DR0_data, we0_EAX)
    // EAX has the heaviest external fanout (EAX_data port goes to many places).
    // Three copies: _a -> DR/SR/SIB_IDX muxes, _b -> SIB_BASE/Seg0/Seg1 muxes,
    // _c -> REG_EAX_o port + EAX_data alias.
    wire [63:0] REG_EAX_a_o, REG_EAX_b_o, REG_EAX_c_o;
    wire [63:0] REG_EAX_c_o_pre_buf;
    `REG_RST_WE(REG_EAX_a, 64, clk, rst, we_EAX, din_EAX, REG_EAX_a_o)
    `REG_RST_WE(REG_EAX_b, 64, clk, rst, we_EAX, din_EAX, REG_EAX_b_o)
    `REG_RST_WE(REG_EAX_c, 64, clk, rst, we_EAX, din_EAX, REG_EAX_c_o_pre_buf)
    // fanout buf attach
    bufferH16$ u_attach_REG_EAX_c_q_31 (.out(REG_EAX_c_o[31]), .in(REG_EAX_c_o_pre_buf[31]));
    assign REG_EAX_c_o[63:32] = REG_EAX_c_o_pre_buf[63:32];
    assign REG_EAX_c_o[30:0]  = REG_EAX_c_o_pre_buf[30:0];
    assign REG_EAX_o = REG_EAX_c_o;

    // ----- EBX  (ID 8) -----
    wire        match0_EBX, match1_EBX, we0_EBX_pre, we0_EBX, we1_EBX, we_EBX;
    wire [63:0] din_EBX;
    `CMP_N(cmp0_EBX, 5, match0_EBX, WB_DR0_ID, 5'd8)
    `CMP_N(cmp1_EBX, 5, match1_EBX, WB_DR1_ID, 5'd8)
    `AND_2(and_we0_EBX, 1, we0_EBX_pre, WB_DR0_we, match0_EBX)
    bufferH256$ u_buf_we0_EBX (.out(we0_EBX), .in(we0_EBX_pre));
    `AND_2(and_we1_EBX, 1, we1_EBX, WB_DR1_we, match1_EBX)
    `OR_2 (or_we_EBX,   1, we_EBX,  we0_EBX, we1_EBX)
    `MUX_2(mux_din_EBX, 64, din_EBX, WB_DR1_data, WB_DR0_data, we0_EBX)
    wire [63:0] REG_EBX_a_o, REG_EBX_b_o;
    wire [63:0] REG_EBX_a_o_pre_buf;
    `REG_RST_WE(REG_EBX_a, 64, clk, rst, we_EBX, din_EBX, REG_EBX_a_o_pre_buf)
    `REG_RST_WE(REG_EBX_b, 64, clk, rst, we_EBX, din_EBX, REG_EBX_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_EBX_a_q_31 (.out(REG_EBX_a_o[31]), .in(REG_EBX_a_o_pre_buf[31]));
    assign REG_EBX_a_o[63:32] = REG_EBX_a_o_pre_buf[63:32];
    assign REG_EBX_a_o[30:0]  = REG_EBX_a_o_pre_buf[30:0];
    assign REG_EBX_o = REG_EBX_a_o;

    // ----- ECX  (ID 9) -----
    wire        match0_ECX, match1_ECX, we0_ECX_pre, we0_ECX, we1_ECX, we_ECX;
    wire [63:0] din_ECX;
    `CMP_N(cmp0_ECX, 5, match0_ECX, WB_DR0_ID, 5'd9)
    `CMP_N(cmp1_ECX, 5, match1_ECX, WB_DR1_ID, 5'd9)
    `AND_2(and_we0_ECX, 1, we0_ECX_pre, WB_DR0_we, match0_ECX)
    bufferH256$ u_buf_we0_ECX (.out(we0_ECX), .in(we0_ECX_pre));
    `AND_2(and_we1_ECX, 1, we1_ECX, WB_DR1_we, match1_ECX)
    `OR_2 (or_we_ECX,   1, we_ECX,  we0_ECX, we1_ECX)
    `MUX_2(mux_din_ECX, 64, din_ECX, WB_DR1_data, WB_DR0_data, we0_ECX)
    wire [63:0] REG_ECX_a_o, REG_ECX_b_o;
    wire [63:0] REG_ECX_a_o_pre_buf;
    `REG_RST_WE(REG_ECX_a, 64, clk, rst, we_ECX, din_ECX, REG_ECX_a_o_pre_buf)
    `REG_RST_WE(REG_ECX_b, 64, clk, rst, we_ECX, din_ECX, REG_ECX_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_ECX_a_q_31 (.out(REG_ECX_a_o[31]), .in(REG_ECX_a_o_pre_buf[31]));
    assign REG_ECX_a_o[63:32] = REG_ECX_a_o_pre_buf[63:32];
    assign REG_ECX_a_o[30:0]  = REG_ECX_a_o_pre_buf[30:0];
    assign REG_ECX_o = REG_ECX_a_o;

    // ----- EDX  (ID 10) -----
    wire        match0_EDX, match1_EDX, we0_EDX_pre, we0_EDX, we1_EDX, we_EDX;
    wire [63:0] din_EDX;
    `CMP_N(cmp0_EDX, 5, match0_EDX, WB_DR0_ID, 5'd10)
    `CMP_N(cmp1_EDX, 5, match1_EDX, WB_DR1_ID, 5'd10)
    `AND_2(and_we0_EDX, 1, we0_EDX_pre, WB_DR0_we, match0_EDX)
    bufferH256$ u_buf_we0_EDX (.out(we0_EDX), .in(we0_EDX_pre));
    `AND_2(and_we1_EDX, 1, we1_EDX, WB_DR1_we, match1_EDX)
    `OR_2 (or_we_EDX,   1, we_EDX,  we0_EDX, we1_EDX)
    `MUX_2(mux_din_EDX, 64, din_EDX, WB_DR1_data, WB_DR0_data, we0_EDX)
    wire [63:0] REG_EDX_a_o, REG_EDX_b_o;
    wire [63:0] REG_EDX_a_o_pre_buf;
    `REG_RST_WE(REG_EDX_a, 64, clk, rst, we_EDX, din_EDX, REG_EDX_a_o_pre_buf)
    `REG_RST_WE(REG_EDX_b, 64, clk, rst, we_EDX, din_EDX, REG_EDX_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_EDX_a_q_31 (.out(REG_EDX_a_o[31]), .in(REG_EDX_a_o_pre_buf[31]));
    assign REG_EDX_a_o[63:32] = REG_EDX_a_o_pre_buf[63:32];
    assign REG_EDX_a_o[30:0]  = REG_EDX_a_o_pre_buf[30:0];
    assign REG_EDX_o = REG_EDX_a_o;

    // ----- ESI  (ID 11) -----
    wire        match0_ESI, match1_ESI, we0_ESI_pre, we0_ESI, we1_ESI, we_ESI;
    wire [63:0] din_ESI;
    `CMP_N(cmp0_ESI, 5, match0_ESI, WB_DR0_ID, 5'd11)
    `CMP_N(cmp1_ESI, 5, match1_ESI, WB_DR1_ID, 5'd11)
    `AND_2(and_we0_ESI, 1, we0_ESI_pre, WB_DR0_we, match0_ESI)
    bufferH256$ u_buf_we0_ESI (.out(we0_ESI), .in(we0_ESI_pre));
    `AND_2(and_we1_ESI, 1, we1_ESI, WB_DR1_we, match1_ESI)
    `OR_2 (or_we_ESI,   1, we_ESI,  we0_ESI, we1_ESI)
    `MUX_2(mux_din_ESI, 64, din_ESI, WB_DR1_data, WB_DR0_data, we0_ESI)
    wire [63:0] REG_ESI_a_o, REG_ESI_b_o;
    wire [63:0] REG_ESI_a_o_pre_buf;
    `REG_RST_WE(REG_ESI_a, 64, clk, rst, we_ESI, din_ESI, REG_ESI_a_o_pre_buf)
    `REG_RST_WE(REG_ESI_b, 64, clk, rst, we_ESI, din_ESI, REG_ESI_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_ESI_a_q_31 (.out(REG_ESI_a_o[31]), .in(REG_ESI_a_o_pre_buf[31]));
    assign REG_ESI_a_o[63:32] = REG_ESI_a_o_pre_buf[63:32];
    assign REG_ESI_a_o[30:0]  = REG_ESI_a_o_pre_buf[30:0];
    assign REG_ESI_o = REG_ESI_a_o;

    // ----- EDI  (ID 12) -----
    wire        match0_EDI, match1_EDI, we0_EDI_pre, we0_EDI, we1_EDI, we_EDI;
    wire [63:0] din_EDI;
    `CMP_N(cmp0_EDI, 5, match0_EDI, WB_DR0_ID, 5'd12)
    `CMP_N(cmp1_EDI, 5, match1_EDI, WB_DR1_ID, 5'd12)
    `AND_2(and_we0_EDI, 1, we0_EDI_pre, WB_DR0_we, match0_EDI)
    bufferH256$ u_buf_we0_EDI (.out(we0_EDI), .in(we0_EDI_pre));
    `AND_2(and_we1_EDI, 1, we1_EDI, WB_DR1_we, match1_EDI)
    `OR_2 (or_we_EDI,   1, we_EDI,  we0_EDI, we1_EDI)
    `MUX_2(mux_din_EDI, 64, din_EDI, WB_DR1_data, WB_DR0_data, we0_EDI)
    wire [63:0] REG_EDI_a_o, REG_EDI_b_o;
    wire [63:0] REG_EDI_a_o_pre_buf;
    `REG_RST_WE(REG_EDI_a, 64, clk, rst, we_EDI, din_EDI, REG_EDI_a_o_pre_buf)
    `REG_RST_WE(REG_EDI_b, 64, clk, rst, we_EDI, din_EDI, REG_EDI_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_EDI_a_q_31 (.out(REG_EDI_a_o[31]), .in(REG_EDI_a_o_pre_buf[31]));
    assign REG_EDI_a_o[63:32] = REG_EDI_a_o_pre_buf[63:32];
    assign REG_EDI_a_o[30:0]  = REG_EDI_a_o_pre_buf[30:0];
    assign REG_EDI_o = REG_EDI_a_o;

    // ----- ESP  (ID 13) -----
    wire        match0_ESP, match1_ESP, we0_ESP_pre, we0_ESP, we1_ESP, we_ESP;
    wire [63:0] din_ESP;
    `CMP_N(cmp0_ESP, 5, match0_ESP, WB_DR0_ID, 5'd13)
    `CMP_N(cmp1_ESP, 5, match1_ESP, WB_DR1_ID, 5'd13)
    `AND_2(and_we0_ESP, 1, we0_ESP_pre, WB_DR0_we, match0_ESP)
    bufferH256$ u_buf_we0_ESP (.out(we0_ESP), .in(we0_ESP_pre));
    `AND_2(and_we1_ESP, 1, we1_ESP, WB_DR1_we, match1_ESP)
    `OR_2 (or_we_ESP,   1, we_ESP,  we0_ESP, we1_ESP)
    `MUX_2(mux_din_ESP, 64, din_ESP, WB_DR1_data, WB_DR0_data, we0_ESP)
    wire [63:0] REG_ESP_a_o, REG_ESP_b_o;
    wire [63:0] REG_ESP_a_o_pre_buf;
    `REG_RST_WE(REG_ESP_a, 64, clk, rst, we_ESP, din_ESP, REG_ESP_a_o_pre_buf)
    `REG_RST_WE(REG_ESP_b, 64, clk, rst, we_ESP, din_ESP, REG_ESP_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_ESP_a_q_31 (.out(REG_ESP_a_o[31]), .in(REG_ESP_a_o_pre_buf[31]));
    assign REG_ESP_a_o[63:32] = REG_ESP_a_o_pre_buf[63:32];
    assign REG_ESP_a_o[30:0]  = REG_ESP_a_o_pre_buf[30:0];
    assign REG_ESP_o = REG_ESP_a_o;

    // ----- EBP  (ID 14) -----
    wire        match0_EBP, match1_EBP, we0_EBP_pre, we0_EBP, we1_EBP, we_EBP;
    wire [63:0] din_EBP;
    `CMP_N(cmp0_EBP, 5, match0_EBP, WB_DR0_ID, 5'd14)
    `CMP_N(cmp1_EBP, 5, match1_EBP, WB_DR1_ID, 5'd14)
    `AND_2(and_we0_EBP, 1, we0_EBP_pre, WB_DR0_we, match0_EBP)
    bufferH256$ u_buf_we0_EBP (.out(we0_EBP), .in(we0_EBP_pre));
    `AND_2(and_we1_EBP, 1, we1_EBP, WB_DR1_we, match1_EBP)
    `OR_2 (or_we_EBP,   1, we_EBP,  we0_EBP, we1_EBP)
    `MUX_2(mux_din_EBP, 64, din_EBP, WB_DR1_data, WB_DR0_data, we0_EBP)
    wire [63:0] REG_EBP_a_o, REG_EBP_b_o;
    wire [63:0] REG_EBP_a_o_pre_buf;
    `REG_RST_WE(REG_EBP_a, 64, clk, rst, we_EBP, din_EBP, REG_EBP_a_o_pre_buf)
    `REG_RST_WE(REG_EBP_b, 64, clk, rst, we_EBP, din_EBP, REG_EBP_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_EBP_a_q_31 (.out(REG_EBP_a_o[31]), .in(REG_EBP_a_o_pre_buf[31]));
    assign REG_EBP_a_o[63:32] = REG_EBP_a_o_pre_buf[63:32];
    assign REG_EBP_a_o[30:0]  = REG_EBP_a_o_pre_buf[30:0];
    assign REG_EBP_o = REG_EBP_a_o;

    // ----- MM0 (ID 15) -----
    wire        match0_MM0, match1_MM0, we0_MM0_pre, we0_MM0, we1_MM0, we_MM0;
    wire [63:0] din_MM0;
    `CMP_N(cmp0_MM0, 5, match0_MM0, WB_DR0_ID, 5'd15)
    `CMP_N(cmp1_MM0, 5, match1_MM0, WB_DR1_ID, 5'd15)
    `AND_2(and_we0_MM0, 1, we0_MM0_pre, WB_DR0_we, match0_MM0)
    bufferH256$ u_buf_we0_MM0 (.out(we0_MM0), .in(we0_MM0_pre));
    `AND_2(and_we1_MM0, 1, we1_MM0, WB_DR1_we, match1_MM0)
    `OR_2 (or_we_MM0,   1, we_MM0,  we0_MM0, we1_MM0)
    `MUX_2(mux_din_MM0, 64, din_MM0, WB_DR1_data, WB_DR0_data, we0_MM0)
    wire [63:0] REG_MM0_a_o, REG_MM0_b_o;
    wire [63:0] REG_MM0_a_o_pre_buf;
    `REG_RST_WE(REG_MM0_a, 64, clk, rst, we_MM0, din_MM0, REG_MM0_a_o_pre_buf)
    `REG_RST_WE(REG_MM0_b, 64, clk, rst, we_MM0, din_MM0, REG_MM0_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_MM0_a_q_31 (.out(REG_MM0_a_o[31]), .in(REG_MM0_a_o_pre_buf[31]));
    assign REG_MM0_a_o[63:32] = REG_MM0_a_o_pre_buf[63:32];
    assign REG_MM0_a_o[30:0]  = REG_MM0_a_o_pre_buf[30:0];
    assign REG_MM0_o = REG_MM0_a_o;

    // ----- MM1 (ID 16) -----
    wire        match0_MM1, match1_MM1, we0_MM1_pre, we0_MM1, we1_MM1, we_MM1;
    wire [63:0] din_MM1;
    `CMP_N(cmp0_MM1, 5, match0_MM1, WB_DR0_ID, 5'd16)
    `CMP_N(cmp1_MM1, 5, match1_MM1, WB_DR1_ID, 5'd16)
    `AND_2(and_we0_MM1, 1, we0_MM1_pre, WB_DR0_we, match0_MM1)
    bufferH256$ u_buf_we0_MM1 (.out(we0_MM1), .in(we0_MM1_pre));
    `AND_2(and_we1_MM1, 1, we1_MM1, WB_DR1_we, match1_MM1)
    `OR_2 (or_we_MM1,   1, we_MM1,  we0_MM1, we1_MM1)
    `MUX_2(mux_din_MM1, 64, din_MM1, WB_DR1_data, WB_DR0_data, we0_MM1)
    wire [63:0] REG_MM1_a_o, REG_MM1_b_o;
    wire [63:0] REG_MM1_a_o_pre_buf;
    `REG_RST_WE(REG_MM1_a, 64, clk, rst, we_MM1, din_MM1, REG_MM1_a_o_pre_buf)
    `REG_RST_WE(REG_MM1_b, 64, clk, rst, we_MM1, din_MM1, REG_MM1_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_MM1_a_q_31 (.out(REG_MM1_a_o[31]), .in(REG_MM1_a_o_pre_buf[31]));
    assign REG_MM1_a_o[63:32] = REG_MM1_a_o_pre_buf[63:32];
    assign REG_MM1_a_o[30:0]  = REG_MM1_a_o_pre_buf[30:0];
    assign REG_MM1_o = REG_MM1_a_o;

    // ----- MM2 (ID 17) -----
    wire        match0_MM2, match1_MM2, we0_MM2_pre, we0_MM2, we1_MM2, we_MM2;
    wire [63:0] din_MM2;
    `CMP_N(cmp0_MM2, 5, match0_MM2, WB_DR0_ID, 5'd17)
    `CMP_N(cmp1_MM2, 5, match1_MM2, WB_DR1_ID, 5'd17)
    `AND_2(and_we0_MM2, 1, we0_MM2_pre, WB_DR0_we, match0_MM2)
    bufferH256$ u_buf_we0_MM2 (.out(we0_MM2), .in(we0_MM2_pre));
    `AND_2(and_we1_MM2, 1, we1_MM2, WB_DR1_we, match1_MM2)
    `OR_2 (or_we_MM2,   1, we_MM2,  we0_MM2, we1_MM2)
    `MUX_2(mux_din_MM2, 64, din_MM2, WB_DR1_data, WB_DR0_data, we0_MM2)
    wire [63:0] REG_MM2_a_o, REG_MM2_b_o;
    wire [63:0] REG_MM2_a_o_pre_buf;
    `REG_RST_WE(REG_MM2_a, 64, clk, rst, we_MM2, din_MM2, REG_MM2_a_o_pre_buf)
    `REG_RST_WE(REG_MM2_b, 64, clk, rst, we_MM2, din_MM2, REG_MM2_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_MM2_a_q_31 (.out(REG_MM2_a_o[31]), .in(REG_MM2_a_o_pre_buf[31]));
    assign REG_MM2_a_o[63:32] = REG_MM2_a_o_pre_buf[63:32];
    assign REG_MM2_a_o[30:0]  = REG_MM2_a_o_pre_buf[30:0];
    assign REG_MM2_o = REG_MM2_a_o;

    // ----- MM3 (ID 18) -----
    wire        match0_MM3, match1_MM3, we0_MM3_pre, we0_MM3, we1_MM3, we_MM3;
    wire [63:0] din_MM3;
    `CMP_N(cmp0_MM3, 5, match0_MM3, WB_DR0_ID, 5'd18)
    `CMP_N(cmp1_MM3, 5, match1_MM3, WB_DR1_ID, 5'd18)
    `AND_2(and_we0_MM3, 1, we0_MM3_pre, WB_DR0_we, match0_MM3)
    bufferH256$ u_buf_we0_MM3 (.out(we0_MM3), .in(we0_MM3_pre));
    `AND_2(and_we1_MM3, 1, we1_MM3, WB_DR1_we, match1_MM3)
    `OR_2 (or_we_MM3,   1, we_MM3,  we0_MM3, we1_MM3)
    `MUX_2(mux_din_MM3, 64, din_MM3, WB_DR1_data, WB_DR0_data, we0_MM3)
    wire [63:0] REG_MM3_a_o, REG_MM3_b_o;
    wire [63:0] REG_MM3_a_o_pre_buf;
    `REG_RST_WE(REG_MM3_a, 64, clk, rst, we_MM3, din_MM3, REG_MM3_a_o_pre_buf)
    `REG_RST_WE(REG_MM3_b, 64, clk, rst, we_MM3, din_MM3, REG_MM3_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_MM3_a_q_31 (.out(REG_MM3_a_o[31]), .in(REG_MM3_a_o_pre_buf[31]));
    assign REG_MM3_a_o[63:32] = REG_MM3_a_o_pre_buf[63:32];
    assign REG_MM3_a_o[30:0]  = REG_MM3_a_o_pre_buf[30:0];
    assign REG_MM3_o = REG_MM3_a_o;

    // ----- MM4 (ID 19) -----
    wire        match0_MM4, match1_MM4, we0_MM4_pre, we0_MM4, we1_MM4, we_MM4;
    wire [63:0] din_MM4;
    `CMP_N(cmp0_MM4, 5, match0_MM4, WB_DR0_ID, 5'd19)
    `CMP_N(cmp1_MM4, 5, match1_MM4, WB_DR1_ID, 5'd19)
    `AND_2(and_we0_MM4, 1, we0_MM4_pre, WB_DR0_we, match0_MM4)
    bufferH256$ u_buf_we0_MM4 (.out(we0_MM4), .in(we0_MM4_pre));
    `AND_2(and_we1_MM4, 1, we1_MM4, WB_DR1_we, match1_MM4)
    `OR_2 (or_we_MM4,   1, we_MM4,  we0_MM4, we1_MM4)
    `MUX_2(mux_din_MM4, 64, din_MM4, WB_DR1_data, WB_DR0_data, we0_MM4)
    wire [63:0] REG_MM4_a_o, REG_MM4_b_o;
    wire [63:0] REG_MM4_a_o_pre_buf;
    `REG_RST_WE(REG_MM4_a, 64, clk, rst, we_MM4, din_MM4, REG_MM4_a_o_pre_buf)
    `REG_RST_WE(REG_MM4_b, 64, clk, rst, we_MM4, din_MM4, REG_MM4_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_MM4_a_q_31 (.out(REG_MM4_a_o[31]), .in(REG_MM4_a_o_pre_buf[31]));
    assign REG_MM4_a_o[63:32] = REG_MM4_a_o_pre_buf[63:32];
    assign REG_MM4_a_o[30:0]  = REG_MM4_a_o_pre_buf[30:0];
    assign REG_MM4_o = REG_MM4_a_o;

    // ----- MM5 (ID 20) -----
    wire        match0_MM5, match1_MM5, we0_MM5_pre, we0_MM5, we1_MM5, we_MM5;
    wire [63:0] din_MM5;
    `CMP_N(cmp0_MM5, 5, match0_MM5, WB_DR0_ID, 5'd20)
    `CMP_N(cmp1_MM5, 5, match1_MM5, WB_DR1_ID, 5'd20)
    `AND_2(and_we0_MM5, 1, we0_MM5_pre, WB_DR0_we, match0_MM5)
    bufferH256$ u_buf_we0_MM5 (.out(we0_MM5), .in(we0_MM5_pre));
    `AND_2(and_we1_MM5, 1, we1_MM5, WB_DR1_we, match1_MM5)
    `OR_2 (or_we_MM5,   1, we_MM5,  we0_MM5, we1_MM5)
    `MUX_2(mux_din_MM5, 64, din_MM5, WB_DR1_data, WB_DR0_data, we0_MM5)
    wire [63:0] REG_MM5_a_o, REG_MM5_b_o;
    wire [63:0] REG_MM5_a_o_pre_buf;
    `REG_RST_WE(REG_MM5_a, 64, clk, rst, we_MM5, din_MM5, REG_MM5_a_o_pre_buf)
    `REG_RST_WE(REG_MM5_b, 64, clk, rst, we_MM5, din_MM5, REG_MM5_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_MM5_a_q_31 (.out(REG_MM5_a_o[31]), .in(REG_MM5_a_o_pre_buf[31]));
    assign REG_MM5_a_o[63:32] = REG_MM5_a_o_pre_buf[63:32];
    assign REG_MM5_a_o[30:0]  = REG_MM5_a_o_pre_buf[30:0];
    assign REG_MM5_o = REG_MM5_a_o;

    // ----- MM6 (ID 21) -----
    wire        match0_MM6, match1_MM6, we0_MM6_pre, we0_MM6, we1_MM6, we_MM6;
    wire [63:0] din_MM6;
    `CMP_N(cmp0_MM6, 5, match0_MM6, WB_DR0_ID, 5'd21)
    `CMP_N(cmp1_MM6, 5, match1_MM6, WB_DR1_ID, 5'd21)
    `AND_2(and_we0_MM6, 1, we0_MM6_pre, WB_DR0_we, match0_MM6)
    bufferH256$ u_buf_we0_MM6 (.out(we0_MM6), .in(we0_MM6_pre));
    `AND_2(and_we1_MM6, 1, we1_MM6, WB_DR1_we, match1_MM6)
    `OR_2 (or_we_MM6,   1, we_MM6,  we0_MM6, we1_MM6)
    `MUX_2(mux_din_MM6, 64, din_MM6, WB_DR1_data, WB_DR0_data, we0_MM6)
    wire [63:0] REG_MM6_a_o, REG_MM6_b_o;
    wire [63:0] REG_MM6_a_o_pre_buf;
    `REG_RST_WE(REG_MM6_a, 64, clk, rst, we_MM6, din_MM6, REG_MM6_a_o_pre_buf)
    `REG_RST_WE(REG_MM6_b, 64, clk, rst, we_MM6, din_MM6, REG_MM6_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_MM6_a_q_31 (.out(REG_MM6_a_o[31]), .in(REG_MM6_a_o_pre_buf[31]));
    assign REG_MM6_a_o[63:32] = REG_MM6_a_o_pre_buf[63:32];
    assign REG_MM6_a_o[30:0]  = REG_MM6_a_o_pre_buf[30:0];
    assign REG_MM6_o = REG_MM6_a_o;

    // ----- MM7 (ID 22) -----
    wire        match0_MM7, match1_MM7, we0_MM7_pre, we0_MM7, we1_MM7, we_MM7;
    wire [63:0] din_MM7;
    `CMP_N(cmp0_MM7, 5, match0_MM7, WB_DR0_ID, 5'd22)
    `CMP_N(cmp1_MM7, 5, match1_MM7, WB_DR1_ID, 5'd22)
    `AND_2(and_we0_MM7, 1, we0_MM7_pre, WB_DR0_we, match0_MM7)
    bufferH256$ u_buf_we0_MM7 (.out(we0_MM7), .in(we0_MM7_pre));
    `AND_2(and_we1_MM7, 1, we1_MM7, WB_DR1_we, match1_MM7)
    `OR_2 (or_we_MM7,   1, we_MM7,  we0_MM7, we1_MM7)
    `MUX_2(mux_din_MM7, 64, din_MM7, WB_DR1_data, WB_DR0_data, we0_MM7)
    wire [63:0] REG_MM7_a_o, REG_MM7_b_o;
    wire [63:0] REG_MM7_a_o_pre_buf;
    `REG_RST_WE(REG_MM7_a, 64, clk, rst, we_MM7, din_MM7, REG_MM7_a_o_pre_buf)
    `REG_RST_WE(REG_MM7_b, 64, clk, rst, we_MM7, din_MM7, REG_MM7_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_MM7_a_q_31 (.out(REG_MM7_a_o[31]), .in(REG_MM7_a_o_pre_buf[31]));
    assign REG_MM7_a_o[63:32] = REG_MM7_a_o_pre_buf[63:32];
    assign REG_MM7_a_o[30:0]  = REG_MM7_a_o_pre_buf[30:0];
    assign REG_MM7_o = REG_MM7_a_o;

    // ----- ETR  (ID 23) -----
    wire        match0_ETR, match1_ETR, we0_ETR_pre, we0_ETR, we1_ETR, we_ETR;
    wire [63:0] din_ETR;
    `CMP_N(cmp0_ETR, 5, match0_ETR, WB_DR0_ID, 5'd23)
    `CMP_N(cmp1_ETR, 5, match1_ETR, WB_DR1_ID, 5'd23)
    `AND_2(and_we0_ETR, 1, we0_ETR_pre, WB_DR0_we, match0_ETR)
    bufferH256$ u_buf_we0_ETR (.out(we0_ETR), .in(we0_ETR_pre));
    `AND_2(and_we1_ETR, 1, we1_ETR, WB_DR1_we, match1_ETR)
    `OR_2 (or_we_ETR,   1, we_ETR,  we0_ETR, we1_ETR)
    `MUX_2(mux_din_ETR, 64, din_ETR, WB_DR1_data, WB_DR0_data, we0_ETR)
    wire [63:0] REG_ETR_a_o, REG_ETR_b_o;
    wire [63:0] REG_ETR_a_o_pre_buf;
    `REG_RST_WE(REG_ETR_a, 64, clk, rst, we_ETR, din_ETR, REG_ETR_a_o_pre_buf)
    `REG_RST_WE(REG_ETR_b, 64, clk, rst, we_ETR, din_ETR, REG_ETR_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_ETR_a_q_31 (.out(REG_ETR_a_o[31]), .in(REG_ETR_a_o_pre_buf[31]));
    assign REG_ETR_a_o[63:32] = REG_ETR_a_o_pre_buf[63:32];
    assign REG_ETR_a_o[30:0]  = REG_ETR_a_o_pre_buf[30:0];
    assign REG_ETR_o = REG_ETR_a_o;

    // ----- ERROR_REG  (ID 24) -----
    wire        match0_ERROR_REG, match1_ERROR_REG, we0_ERROR_REG_pre, we0_ERROR_REG, we1_ERROR_REG, we_ERROR_REG;
    wire [63:0] din_ERROR_REG;
    `CMP_N(cmp0_ERROR_REG, 5, match0_ERROR_REG, WB_DR0_ID, 5'd24)
    `CMP_N(cmp1_ERROR_REG, 5, match1_ERROR_REG, WB_DR1_ID, 5'd24)
    `AND_2(and_we0_ERROR_REG, 1, we0_ERROR_REG_pre, WB_DR0_we, match0_ERROR_REG)
    bufferH256$ u_buf_we0_ERROR_REG (.out(we0_ERROR_REG), .in(we0_ERROR_REG_pre));
    `AND_2(and_we1_ERROR_REG, 1, we1_ERROR_REG, WB_DR1_we, match1_ERROR_REG)
    `OR_2 (or_we_ERROR_REG,   1, we_ERROR_REG,  we0_ERROR_REG, we1_ERROR_REG)
    `MUX_2(mux_din_ERROR_REG, 64, din_ERROR_REG, WB_DR1_data, WB_DR0_data, we0_ERROR_REG)
    wire [63:0] REG_ERROR_REG_a_o, REG_ERROR_REG_b_o;
    wire [63:0] REG_ERROR_REG_a_o_pre_buf;
    `REG_RST_WE(REG_ERROR_REG_a, 64, clk, rst, we_ERROR_REG, din_ERROR_REG, REG_ERROR_REG_a_o_pre_buf)
    `REG_RST_WE(REG_ERROR_REG_b, 64, clk, rst, we_ERROR_REG, din_ERROR_REG, REG_ERROR_REG_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_ERROR_REG_a_q_31 (.out(REG_ERROR_REG_a_o[31]), .in(REG_ERROR_REG_a_o_pre_buf[31]));
    assign REG_ERROR_REG_a_o[63:32] = REG_ERROR_REG_a_o_pre_buf[63:32];
    assign REG_ERROR_REG_a_o[30:0]  = REG_ERROR_REG_a_o_pre_buf[30:0];
    assign REG_ERROR_REG_o = REG_ERROR_REG_a_o;

    // ----- NO_REG  (ID 25) -----
    wire        match0_NO_REG, match1_NO_REG, we0_NO_REG_pre, we0_NO_REG, we1_NO_REG, we_NO_REG;
    wire [63:0] din_NO_REG;
    `CMP_N(cmp0_NO_REG, 5, match0_NO_REG, WB_DR0_ID, 5'd25)
    `CMP_N(cmp1_NO_REG, 5, match1_NO_REG, WB_DR1_ID, 5'd25)
    `AND_2(and_we0_NO_REG, 1, we0_NO_REG_pre, WB_DR0_we, match0_NO_REG)
    bufferH256$ u_buf_we0_NO_REG (.out(we0_NO_REG), .in(we0_NO_REG_pre));
    `AND_2(and_we1_NO_REG, 1, we1_NO_REG, WB_DR1_we, match1_NO_REG)
    `OR_2 (or_we_NO_REG,   1, we_NO_REG,  we0_NO_REG, we1_NO_REG)
    `MUX_2(mux_din_NO_REG, 64, din_NO_REG, WB_DR1_data, WB_DR0_data, we0_NO_REG)
    wire [63:0] REG_NO_REG_a_o, REG_NO_REG_b_o;
    wire [63:0] REG_NO_REG_a_o_pre_buf;
    `REG_RST_WE(REG_NO_REG_a, 64, clk, rst, we_NO_REG, din_NO_REG, REG_NO_REG_a_o_pre_buf)
    `REG_RST_WE(REG_NO_REG_b, 64, clk, rst, we_NO_REG, din_NO_REG, REG_NO_REG_b_o)
    // fanout buf attach
    bufferH16$ u_attach_REG_NO_REG_a_q_31 (.out(REG_NO_REG_a_o[31]), .in(REG_NO_REG_a_o_pre_buf[31]));
    assign REG_NO_REG_a_o[63:32] = REG_NO_REG_a_o_pre_buf[63:32];
    assign REG_NO_REG_a_o[30:0]  = REG_NO_REG_a_o_pre_buf[30:0];
    assign REG_NO_REG_o = REG_NO_REG_a_o;


    //=========================================================================
    // Read path
    //   Variable-index reads use 32:1 muxes (5-bit select). Only IDs 0..25
    //   are valid; inputs 26..31 are tied to constant 0.
    //   Fixed-index reads (ECX/EAX/CS) are direct part-selects on the
    //   corresponding register output wire.
    //=========================================================================

    // 64-bit DR_data : driven by the _a copy of each register
    wire [63:0] DR_data_pre_buf;
    `MUX_32(mux_DR_data, 64, DR_data_pre_buf,
        REG_CS_a_o, REG_DS_a_o, REG_SS_a_o, REG_ES_a_o,
        REG_FS_a_o, REG_GS_a_o, REG_EXPS_a_o, REG_EAX_a_o,
        REG_EBX_a_o, REG_ECX_a_o, REG_EDX_a_o, REG_ESI_a_o,
        REG_EDI_a_o, REG_ESP_a_o, REG_EBP_a_o, REG_MM0_a_o,
        REG_MM1_a_o, REG_MM2_a_o, REG_MM3_a_o, REG_MM4_a_o,
        REG_MM5_a_o, REG_MM6_a_o, REG_MM7_a_o, REG_ETR_a_o,
        REG_ERROR_REG_a_o, REG_NO_REG_a_o, 64'd0, 64'd0,
        64'd0, 64'd0, 64'd0, 64'd0,
        DR_ID)
    // fanout buf attach
    genvar gi_dr;
    generate
        for (gi_dr = 0; gi_dr < 64; gi_dr = gi_dr + 1) begin : g_buf_DR_data
            bufferH16$ u_attach_DR_data (.out(DR_data[gi_dr]), .in(DR_data_pre_buf[gi_dr]));
        end
    endgenerate

    // 64-bit SR_data : driven by the _a copy
    wire [63:0] SR_data_pre_buf;
    `MUX_32(mux_SR_data, 64, SR_data_pre_buf,
        REG_CS_a_o, REG_DS_a_o, REG_SS_a_o, REG_ES_a_o,
        REG_FS_a_o, REG_GS_a_o, REG_EXPS_a_o, REG_EAX_a_o,
        REG_EBX_a_o, REG_ECX_a_o, REG_EDX_a_o, REG_ESI_a_o,
        REG_EDI_a_o, REG_ESP_a_o, REG_EBP_a_o, REG_MM0_a_o,
        REG_MM1_a_o, REG_MM2_a_o, REG_MM3_a_o, REG_MM4_a_o,
        REG_MM5_a_o, REG_MM6_a_o, REG_MM7_a_o, REG_ETR_a_o,
        REG_ERROR_REG_a_o, REG_NO_REG_a_o, 64'd0, 64'd0,
        64'd0, 64'd0, 64'd0, 64'd0,
        SR_ID)
    // fanout buf attach
    genvar gi_sr;
    generate
        for (gi_sr = 0; gi_sr < 64; gi_sr = gi_sr + 1) begin : g_buf_SR_data
            bufferH16$ u_attach_SR_data (.out(SR_data[gi_sr]), .in(SR_data_pre_buf[gi_sr]));
        end
    endgenerate

    // 32-bit SIB_IDX_data : driven by the _a copy (lower 32)
    `MUX_32(mux_SIB_IDX_data, 32, SIB_IDX_data,
        REG_CS_a_o[31:0], REG_DS_a_o[31:0], REG_SS_a_o[31:0], REG_ES_a_o[31:0],
        REG_FS_a_o[31:0], REG_GS_a_o[31:0], REG_EXPS_a_o[31:0], REG_EAX_a_o[31:0],
        REG_EBX_a_o[31:0], REG_ECX_a_o[31:0], REG_EDX_a_o[31:0], REG_ESI_a_o[31:0],
        REG_EDI_a_o[31:0], REG_ESP_a_o[31:0], REG_EBP_a_o[31:0], REG_MM0_a_o[31:0],
        REG_MM1_a_o[31:0], REG_MM2_a_o[31:0], REG_MM3_a_o[31:0], REG_MM4_a_o[31:0],
        REG_MM5_a_o[31:0], REG_MM6_a_o[31:0], REG_MM7_a_o[31:0], REG_ETR_a_o[31:0],
        REG_ERROR_REG_a_o[31:0], REG_NO_REG_a_o[31:0], 32'd0, 32'd0,
        32'd0, 32'd0, 32'd0, 32'd0,
        SIB_IDX_ID)

    // 32-bit SIB_BASE_data : driven by the _b copy
    `MUX_32(mux_SIB_BASE_data, 32, SIB_BASE_data,
        REG_CS_b_o[31:0], REG_DS_b_o[31:0], REG_SS_b_o[31:0], REG_ES_b_o[31:0],
        REG_FS_b_o[31:0], REG_GS_b_o[31:0], REG_EXPS_b_o[31:0], REG_EAX_b_o[31:0],
        REG_EBX_b_o[31:0], REG_ECX_b_o[31:0], REG_EDX_b_o[31:0], REG_ESI_b_o[31:0],
        REG_EDI_b_o[31:0], REG_ESP_b_o[31:0], REG_EBP_b_o[31:0], REG_MM0_b_o[31:0],
        REG_MM1_b_o[31:0], REG_MM2_b_o[31:0], REG_MM3_b_o[31:0], REG_MM4_b_o[31:0],
        REG_MM5_b_o[31:0], REG_MM6_b_o[31:0], REG_MM7_b_o[31:0], REG_ETR_b_o[31:0],
        REG_ERROR_REG_b_o[31:0], REG_NO_REG_b_o[31:0], 32'd0, 32'd0,
        32'd0, 32'd0, 32'd0, 32'd0,
        SIB_BASE_ID)

    // 32-bit Segment0_data : driven by the _b copy
    `MUX_32(mux_Segment0_data, 32, Segment0_data,
        REG_CS_b_o[31:0], REG_DS_b_o[31:0], REG_SS_b_o[31:0], REG_ES_b_o[31:0],
        REG_FS_b_o[31:0], REG_GS_b_o[31:0], REG_EXPS_b_o[31:0], REG_EAX_b_o[31:0],
        REG_EBX_b_o[31:0], REG_ECX_b_o[31:0], REG_EDX_b_o[31:0], REG_ESI_b_o[31:0],
        REG_EDI_b_o[31:0], REG_ESP_b_o[31:0], REG_EBP_b_o[31:0], REG_MM0_b_o[31:0],
        REG_MM1_b_o[31:0], REG_MM2_b_o[31:0], REG_MM3_b_o[31:0], REG_MM4_b_o[31:0],
        REG_MM5_b_o[31:0], REG_MM6_b_o[31:0], REG_MM7_b_o[31:0], REG_ETR_b_o[31:0],
        REG_ERROR_REG_b_o[31:0], REG_NO_REG_b_o[31:0], 32'd0, 32'd0,
        32'd0, 32'd0, 32'd0, 32'd0,
        Segment0_ID)

    // 32-bit Segment1_data : driven by the _b copy
    `MUX_32(mux_Segment1_data, 32, Segment1_data,
        REG_CS_b_o[31:0], REG_DS_b_o[31:0], REG_SS_b_o[31:0], REG_ES_b_o[31:0],
        REG_FS_b_o[31:0], REG_GS_b_o[31:0], REG_EXPS_b_o[31:0], REG_EAX_b_o[31:0],
        REG_EBX_b_o[31:0], REG_ECX_b_o[31:0], REG_EDX_b_o[31:0], REG_ESI_b_o[31:0],
        REG_EDI_b_o[31:0], REG_ESP_b_o[31:0], REG_EBP_b_o[31:0], REG_MM0_b_o[31:0],
        REG_MM1_b_o[31:0], REG_MM2_b_o[31:0], REG_MM3_b_o[31:0], REG_MM4_b_o[31:0],
        REG_MM5_b_o[31:0], REG_MM6_b_o[31:0], REG_MM7_b_o[31:0], REG_ETR_b_o[31:0],
        REG_ERROR_REG_b_o[31:0], REG_NO_REG_b_o[31:0], 32'd0, 32'd0,
        32'd0, 32'd0, 32'd0, 32'd0,
        Segment1_ID)

    // Fixed-index reads: special-data aliases driven by the _b copy
    // (or _c for EAX, which has 3 register copies due to high external load).
    assign ECX_data = REG_ECX_b_o[31:0];
    assign EAX_data = REG_EAX_c_o[31:0];
    assign CS_data  = REG_CS_b_o[31:0];

endmodule
