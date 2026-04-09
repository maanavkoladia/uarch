`ifndef STD_CELL_MACROS_VH
`define STD_CELL_MACROS_VH

`define INV_N(unitName, width, in, out) \
    inv_N$ #(.WIDTH(width)) unitName ( .in(in), .out(out) );

`define AND_2(unitName, width, out, in0, in1) \
    and2_N$ #(.WIDTH(width)) unitName (.out(out),.in0(in0),.in1(in1);
`define AND_3(unitName, width, out, in0, in1, in2) \
    and3_N$ #(.WIDTH(width)) unitName (.out(out),.in0(in0),.in1(in1),.in2(in2);
`define AND_4(unitName, width, out, in0, in1, in2, in3) \
    and4_N$ #(.WIDTH(width)) unitName (.out(out),.in0(in0),.in1(in1),.in2(in2),.in3(in3);
`define AND_5(unitName, width, out, in0, in1, in2, in3, in4) \
    and5_N$ #(.WIDTH(width)) unitName (.out(out),.in0(in0),.in1(in1),.in2(in2),.in3(in3),.in4(in4);
`define AND_6(unitName, width, out, in0, in1, in2, in3, in4, in5) \
    and6_N$ #(.WIDTH(width)) unitName (.out(out),.in0(in0),.in1(in1),.in2(in2),.in3(in3),.in4(in4),.in5(in5);
`define AND_7(unitName, width, out, in0, in1, in2, in3, in4, in5, in6) \
    and7_N$ #(.WIDTH(width)) unitName (.out(out),.in0(in0),.in1(in1),.in2(in2),.in3(in3),.in4(in4),.in5(in5),.in6(in6);
`define AND_8(unitName, width, out, in0, in1, in2, in3, in4, in5, in6, in7) \
    and8_N$ #(.WIDTH(width)) unitName (.out(out),.in0(in0),.in1(in1),.in2(in2),.in3(in3),.in4(in4),.in5(in5),.in6(in6),.in7(in7);
`define AND_9(unitName, width, out, in0, in1, in2, in3, in4, in5, in6, in7, in8) \
    and9_N$ #(.WIDTH(width)) unitName (.out(out),.in0(in0),.in1(in1),.in2(in2),.in3(in3),.in4(in4),.in5(in5),.in6(in6),.in7(in7),.in8(in8);
`define AND_10(unitName, width, out, in0, in1, in2, in3, in4, in5, in6, in7, in8, in9) \
    and10_N$ #(.WIDTH(width)) unitName (.out(out),.in0(in0),.in1(in1),.in2(in2),.in3(in3),.in4(in4),.in5(in5),.in6(in6),.in7(in7),.in8(in8),.in9(in9);
`define AND_11(unitName, width, out, in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10) \
    and11_N$ #(.WIDTH(width)) unitName (.out(out),.in0(in0),.in1(in1),.in2(in2),.in3(in3),.in4(in4),.in5(in5),.in6(in6),.in7(in7),.in8(in8),.in9(in9),.in10(in10);
`define AND_12(unitName, width, out, in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11) \
    and12_N$ #(.WIDTH(width)) unitName (.out(out),.in0(in0),.in1(in1),.in2(in2),.in3(in3),.in4(in4),.in5(in5),.in6(in6),.in7(in7),.in8(in8),.in9(in9),.in10(in10),.in11(in11);

/* ---------------- OR_2 to OR_12 macros ---------------- */

`define OR_2(unitName, width, out, in0, in1) \
    or2_N$ #(.WIDTH(width)) unitName (.out(out),.in0(in0),.in1(in1);
`define OR_3(unitName, width, out, in0, in1, in2) \
    or3_N$ #(.WIDTH(width)) unitName (.out(out),.in0(in0),.in1(in1),.in2(in2);
`define OR_4(unitName, width, out, in0, in1, in2, in3) \
    or4_N$ #(.WIDTH(width)) unitName (.out(out),.in0(in0),.in1(in1),.in2(in2),.in3(in3);
`define OR_5(unitName, width, out, in0, in1, in2, in3, in4) \
    or5_N$ #(.WIDTH(width)) unitName (.out(out),.in0(in0),.in1(in1),.in2(in2),.in3(in3),.in4(in4);
`define OR_6(unitName, width, out, in0, in1, in2, in3, in4, in5) \
    or6_N$ #(.WIDTH(width)) unitName (.out(out),.in0(in0),.in1(in1),.in2(in2),.in3(in3),.in4(in4),.in5(in5);
`define OR_7(unitName, width, out, in0, in1, in2, in3, in4, in5, in6) \
    or7_N$ #(.WIDTH(width)) unitName (.out(out),.in0(in0),.in1(in1),.in2(in2),.in3(in3),.in4(in4),.in5(in5),.in6(in6);
`define OR_8(unitName, width, out, in0, in1, in2, in3, in4, in5, in6, in7) \
    or8_N$ #(.WIDTH(width)) unitName (.out(out),.in0(in0),.in1(in1),.in2(in2),.in3(in3),.in4(in4),.in5(in5),.in6(in6),.in7(in7);
`define OR_9(unitName, width, out, in0, in1, in2, in3, in4, in5, in6, in7, in8) \
    or9_N$ #(.WIDTH(width)) unitName (.out(out),.in0(in0),.in1(in1),.in2(in2),.in3(in3),.in4(in4),.in5(in5),.in6(in6),.in7(in7),.in8(in8);
`define OR_10(unitName, width, out, in0, in1, in2, in3, in4, in5, in6, in7, in8, in9) \
    or10_N$ #(.WIDTH(width)) unitName (.out(out),.in0(in0),.in1(in1),.in2(in2),.in3(in3),.in4(in4),.in5(in5),.in6(in6),.in7(in7),.in8(in8),.in9(in9);
`define OR_11(unitName, width, out, in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10) \
    or11_N$ #(.WIDTH(width)) unitName (.out(out),.in0(in0),.in1(in1),.in2(in2),.in3(in3),.in4(in4),.in5(in5),.in6(in6),.in7(in7),.in8(in8),.in9(in9),.in10(in10);
`define OR_12(unitName, width, out, in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11) \
    or12_N$ #(.WIDTH(width)) unitName (.out(out),.in0(in0),.in1(in1),.in2(in2),.in3(in3),.in4(in4),.in5(in5),.in6(in6),.in7(in7),.in8(in8),.in9(in9),.in10(in10),.in11(in11);

//muxes
`define MUX_2(unitName, width, out, in0, in1, sel1) \
    unitName mux2_N #(.WIDTH(width)) (.out(out), .in0(in0), .in1(in1), .sel(sel1));
`define MUX_3(unitName, width, out, in0, in1, in2, sel2) \
    unitName mux3_N #(.WIDTH(width)) (.out(out), .in0(in0), .in1(in1), .in2(in2), .sel(sel2));
`define MUX_4(unitName, width, out, in0, in1, in2, in3, sel2) \
    unitName mux4_N #(.WIDTH(width)) (.out(out), .in0(in0), .in1(in1), .in2(in2), .in3(in3), .sel(sel2));
`define MUX_8(unitName, width, out, in0, in1, in2, in3, in4, in5, in6, in7, sel3) \
    unitName mux8_N #(.WIDTH(width)) (.out(out), .in0(in0), .in1(in1), .in2(in2), .in3(in3), .in4(in4), .in5(in5), .in6(in6), .in7(in7), .sel(sel3));
`define MUX_16(unitName, width, out, in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15, sel4) \
    unitName mux16_N #(.WIDTH(width)) (.out(out), .in0(in0), .in1(in1), .in2(in2), .in3(in3), .in4(in4), .in5(in5), .in6(in6), .in7(in7), .in8(in8), .in9(in9), .in10(in10), .in11(in11), .in12(in12), .in13(in13), .in14(in14), .in15(in15), .sel(sel4));
`define MUX_32(unitName, width, out, in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15, in16, in17, in18, in19, in20, in21, in22, in23, in24, in25, in26, in27, in28, in29, in30, in31, sel5) \
    unitName mux32_N #(.WIDTH(width)) (.out(out), .in0(in0), .in1(in1), .in2(in2), .in3(in3), .in4(in4), .in5(in5), .in6(in6), .in7(in7), .in8(in8), .in9(in9), .in10(in10), .in11(in11), .in12(in12), .in13(in13), .in14(in14), .in15(in15), .in16(in16), .in17(in17), .in18(in18), .in19(in19), .in20(in20), .in21(in21), .in22(in22), .in23(in23), .in24(in24), .in25(in25), .in26(in26), .in27(in27), .in28(in28), .in29(in29), .in30(in30), .in31(in31), .sel(sel5));
`define MUX_64(unitName, width, out, in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15, in16, in17, in18, in19, in20, in21, in22, in23, in24, in25, in26, in27, in28, in29, in30, in31, in32, in33, in34, in35, in36, in37, in38, in39, in40, in41, in42, in43, in44, in45, in46, in47, in48, in49, in50, in51, in52, in53, in54, in55, in56, in57, in58, in59, in60, in61, in62, in63, sel6) \
    unitName mux64_N #(.WIDTH(width)) (.out(out), .in0(in0), .in1(in1), .in2(in2), .in3(in3), .in4(in4), .in5(in5), .in6(in6), .in7(in7), .in8(in8), .in9(in9), .in10(in10), .in11(in11), .in12(in12), .in13(in13), .in14(in14), .in15(in15), .in16(in16), .in17(in17), .in18(in18), .in19(in19), .in20(in20), .in21(in21), .in22(in22), .in23(in23), .in24(in24), .in25(in25), .in26(in26), .in27(in27), .in28(in28), .in29(in29), .in30(in30), .in31(in31), .in32(in32), .in33(in33), .in34(in34), .in35(in35), .in36(in36), .in37(in37), .in38(in38), .in39(in39), .in40(in40), .in41(in41), .in42(in42), .in43(in43), .in44(in44), .in45(in45), .in46(in46), .in47(in47), .in48(in48), .in49(in49), .in50(in50), .in51(in51), .in52(in52), .in53(in53), .in54(in54), .in55(in55), .in56(in56), .in57(in57), .in58(in58), .in59(in59), .in60(in60), .in61(in61), .in62(in62), .in63(in63), .sel(sel6));

//eq_comp
// ============================================================
// EQ COMPARE
// ============================================================
`define CMP_N(unitName, width, out, in0, in1) \
    MPS_COMP_EQ #(.WIDTH(width)) unitName ( \
        .in0(in0), \
        .in1(in1), \
        .eq(out) \
    );


// ============================================================
// ADD (Kogge-Stone)
// ============================================================
`define ADD_N(unitName, width, sum, cout, in0, in1, cin) \
    kogge_stone_adder #(.WIDTH(width)) unitName ( \
        .a(in0), \
        .b(in1), \
        .cin(cin), \
        .sum(sum), \
        .cout(cout) \
    );


// ============================================================
// BUFFER DELAY
// ============================================================
`define BUFFER_DELAY(unitName, stages, width, in, out) \
    MPS_buffer_delay$ #(.STAGES(stages), .WIDTH(width)) unitName ( \
        .in(in), \
        .out(out) \
    );

//tristate with width
`define TRISTATE_L(unitName, width, enbar, in, out) \
    MPS_tristateL #(.WIDTH(width)) unitName ( \
        .enbar(enbar), \
        .in(in), \
        .out(out) \
    );
//bus tristate
`define BUS_TRISTATE(unitName, width, enbar, in, out) \
    MPS_bus_tristate #(.WIDTH(width)) unitName ( \
        .enbar(enbar), \
        .in(in), \
        .out(out) \
    );

//decoder
`define DECODER_N(unitName, inputs, in, out) \
    MPS_decoder$ #(.INPUTS(inputs)) unitName ( \
        .in(in), \
        .out(out) \
    );

// ============================================================
// REG WITH RESET + WRITE ENABLE
// ============================================================
`define REG_RST_WE(unitName, width, clk, rst, we, din, dout) \
    MPS_reg_rst_we$ #(.WIDTH(width)) unitName ( \
        .clk(clk), \
        .rst(rst), \
        .we(we), \
        .d(din), \
        .q(dout) \
    );


// ============================================================
// REG WITH RESET (ALWAYS ENABLED)
// ============================================================
`define REG_RST(unitName, width, clk, rst, din, dout) \
    MPS_reg_rst_we$ #(.WIDTH(width)) unitName ( \
        .clk(clk), \
        .rst(rst), \
        .we(1'b1), \
        .d(din), \
        .q(dout) \
    );

`endif
