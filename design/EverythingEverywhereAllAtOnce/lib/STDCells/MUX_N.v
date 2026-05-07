// 2-input
////////////////////////////////////////////////////////////////////////////////
// Port Declarations
//
// mux2_N:
//   output [WIDTH-1:0] out;
//   input  [WIDTH-1:0] in0, in1;
//   input              sel;
//
// mux3_N:
//   output [WIDTH-1:0] out;
//   input  [WIDTH-1:0] in0, in1, in2;
//   input              sel;
//
// mux4_N:
//   output [WIDTH-1:0] out;
//   input  [WIDTH-1:0] in0, in1, in2, in3;
//   input  [1:0]       sel;
//
// mux8_N:
//   output [WIDTH-1:0] out;
//   input  [WIDTH-1:0] in0–in7;
//   input  [2:0]       sel;
//
// mux16_N:
//   output [WIDTH-1:0] out;
//   input  [WIDTH-1:0] in0–in15;
//   input  [3:0]       sel;
//
// mux32_N:
//   output [WIDTH-1:0] out;
//   input  [WIDTH-1:0] in0–in31;
//   input  [4:0]       sel;
//
// mux64_N:
//   output [WIDTH-1:0] out;
//   input  [WIDTH-1:0] in0–in63;
//   input  [5:0]       sel;
////////////////////////////////////////////////////////////////////////////////

module mux2_N #(parameter WIDTH = 1)(
    output wire [WIDTH-1:0] out,
    input  wire [WIDTH-1:0] in0, in1,
    input  wire             sel
);
    genvar i;
    generate
        for(i = 0; i < WIDTH; i = i + 1) begin : gen_mux
            MPS_MUX_IN2 u_mux (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .sel(sel)
            );
        end
    endgenerate
endmodule

module mux2_N_H8 #(parameter WIDTH = 1)(
    output wire [WIDTH-1:0] out,
    input  wire [WIDTH-1:0] in0, in1,
    input  wire             sel0, sel1
);
    genvar i;
    generate
        for(i = 0; i < 4; i = i + 1) begin : gen_mux_lo
            MPS_MUX_IN2 u_mux (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .sel(sel0)
            );
        end
        for(i = 4; i < WIDTH; i = i + 1) begin : gen_mux_hi
            MPS_MUX_IN2 u_mux (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .sel(sel1)
            );
        end
    endgenerate
endmodule

module mux3_N #(parameter WIDTH = 1)(
    output wire [WIDTH-1:0] out,
    input  wire [WIDTH-1:0] in0, in1, in2,
    input  wire [1:0]       sel
);
    genvar i;
    generate
        for(i = 0; i < WIDTH; i = i + 1) begin : gen_mux
            MPS_MUX_IN3 u_mux (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .in2(in2[i]),
                .sel(sel)
            );
        end
    endgenerate
endmodule

module mux4_N #(parameter WIDTH = 1)(
    output [WIDTH-1:0] out,
    input  [WIDTH-1:0] in0, in1, in2, in3,
    input  [1:0]       sel
);

    genvar i;

    generate
        for(i = 0; i < WIDTH; i = i + 1) begin : gen_mux
            MPS_MUX_IN4 u_mux (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .in2(in2[i]),
                .in3(in3[i]),
                .sel(sel)
            );
        end
    endgenerate

endmodule

module mux4_N_H8 #(parameter WIDTH = 1)(
    output [WIDTH-1:0] out,
    input  [WIDTH-1:0] in0, in1, in2, in3,
    input  [1:0]       sel0,
    input  [1:0]       sel1
);

    genvar i;

    generate
        for(i = 0; i < 4; i = i + 1) begin : gen_mux_lo
            MPS_MUX_IN4 u_mux (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .in2(in2[i]),
                .in3(in3[i]),
                .sel(sel0)
            );
        end
        for(i = 4; i < WIDTH; i = i + 1) begin : gen_mux_hi
            MPS_MUX_IN4 u_mux (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .in2(in2[i]),
                .in3(in3[i]),
                .sel(sel1)
            );
        end
    endgenerate

endmodule

module mux8_N #(parameter WIDTH = 1)(
    output [WIDTH-1:0] out,
    input  [WIDTH-1:0] in0, in1, in2, in3,
    input  [WIDTH-1:0] in4, in5, in6, in7,
    input  [2:0]       sel
);

    genvar i;

    generate
        for(i = 0; i < WIDTH; i = i + 1) begin : gen_mux
            MPS_MUX_IN8 u_mux (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .in2(in2[i]),
                .in3(in3[i]),
                .in4(in4[i]),
                .in5(in5[i]),
                .in6(in6[i]),
                .in7(in7[i]),
                .sel(sel)
            );
        end
    endgenerate

endmodule

module mux8_N_H8 #(parameter WIDTH = 1)(
    output [WIDTH-1:0] out,
    input  [WIDTH-1:0] in0, in1, in2, in3,
    input  [WIDTH-1:0] in4, in5, in6, in7,
    input  [2:0]       sel0,
    input  [2:0]       sel1
);

    genvar i;

    generate
        for(i = 0; i < 4; i = i + 1) begin : gen_mux_lo
            MPS_MUX_IN8 u_mux (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .in2(in2[i]),
                .in3(in3[i]),
                .in4(in4[i]),
                .in5(in5[i]),
                .in6(in6[i]),
                .in7(in7[i]),
                .sel(sel0)
            );
        end
        for(i = 4; i < WIDTH; i = i + 1) begin : gen_mux_hi
            MPS_MUX_IN8 u_mux (
                .out(out[i]),
                .in0(in0[i]),
                .in1(in1[i]),
                .in2(in2[i]),
                .in3(in3[i]),
                .in4(in4[i]),
                .in5(in5[i]),
                .in6(in6[i]),
                .in7(in7[i]),
                .sel(sel1)
            );
        end
    endgenerate

endmodule





////////////////////////////////////////////////////////////////////////////////
// 16-input wrapper (Verilog-2005 safe)
////////////////////////////////////////////////////////////////////////////////
module mux16_N #(parameter WIDTH = 1)(
    output [WIDTH-1:0] out,
    input  [WIDTH-1:0] in0,  input [WIDTH-1:0] in1,
    input  [WIDTH-1:0] in2,  input [WIDTH-1:0] in3,
    input  [WIDTH-1:0] in4,  input [WIDTH-1:0] in5,
    input  [WIDTH-1:0] in6,  input [WIDTH-1:0] in7,
    input  [WIDTH-1:0] in8,  input [WIDTH-1:0] in9,
    input  [WIDTH-1:0] in10, input [WIDTH-1:0] in11,
    input  [WIDTH-1:0] in12, input [WIDTH-1:0] in13,
    input  [WIDTH-1:0] in14, input [WIDTH-1:0] in15,
    input  [3:0] sel
);

    genvar i;

    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : mux_bits
            wire o;

            MPS_MUX_IN16 u_mux (
                .out(o),
                .in0(in0[i]),  .in1(in1[i]),
                .in2(in2[i]),  .in3(in3[i]),
                .in4(in4[i]),  .in5(in5[i]),
                .in6(in6[i]),  .in7(in7[i]),
                .in8(in8[i]),  .in9(in9[i]),
                .in10(in10[i]), .in11(in11[i]),
                .in12(in12[i]), .in13(in13[i]),
                .in14(in14[i]), .in15(in15[i]),
                .sel(sel)
            );

            assign out[i] = o;
        end
    endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
// 32-input wrapper (Verilog-2005 safe)
////////////////////////////////////////////////////////////////////////////////
module mux32_N #(parameter WIDTH = 1)(
    output [WIDTH-1:0] out,
    input  [WIDTH-1:0] in0,  input [WIDTH-1:0] in1,
    input  [WIDTH-1:0] in2,  input [WIDTH-1:0] in3,
    input  [WIDTH-1:0] in4,  input [WIDTH-1:0] in5,
    input  [WIDTH-1:0] in6,  input [WIDTH-1:0] in7,
    input  [WIDTH-1:0] in8,  input [WIDTH-1:0] in9,
    input  [WIDTH-1:0] in10, input [WIDTH-1:0] in11,
    input  [WIDTH-1:0] in12, input [WIDTH-1:0] in13,
    input  [WIDTH-1:0] in14, input [WIDTH-1:0] in15,
    input  [WIDTH-1:0] in16, input [WIDTH-1:0] in17,
    input  [WIDTH-1:0] in18, input [WIDTH-1:0] in19,
    input  [WIDTH-1:0] in20, input [WIDTH-1:0] in21,
    input  [WIDTH-1:0] in22, input [WIDTH-1:0] in23,
    input  [WIDTH-1:0] in24, input [WIDTH-1:0] in25,
    input  [WIDTH-1:0] in26, input [WIDTH-1:0] in27,
    input  [WIDTH-1:0] in28, input [WIDTH-1:0] in29,
    input  [WIDTH-1:0] in30, input [WIDTH-1:0] in31,
    input  [4:0] sel
);

    genvar i;

    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : mux_bits
            wire o;

            MPS_MUX_IN32 u_mux (
                .out(o),
                .in0(in0[i]),   .in1(in1[i]),
                .in2(in2[i]),   .in3(in3[i]),
                .in4(in4[i]),   .in5(in5[i]),
                .in6(in6[i]),   .in7(in7[i]),
                .in8(in8[i]),   .in9(in9[i]),
                .in10(in10[i]), .in11(in11[i]),
                .in12(in12[i]), .in13(in13[i]),
                .in14(in14[i]), .in15(in15[i]),
                .in16(in16[i]), .in17(in17[i]),
                .in18(in18[i]), .in19(in19[i]),
                .in20(in20[i]), .in21(in21[i]),
                .in22(in22[i]), .in23(in23[i]),
                .in24(in24[i]), .in25(in25[i]),
                .in26(in26[i]), .in27(in27[i]),
                .in28(in28[i]), .in29(in29[i]),
                .in30(in30[i]), .in31(in31[i]),
                .sel(sel)
            );

            assign out[i] = o;
        end
    endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
// 64-input wrapper (Verilog-2005 safe)
////////////////////////////////////////////////////////////////////////////////
module mux64_N #(parameter WIDTH = 1)(
    output [WIDTH-1:0] out,
    input  [WIDTH-1:0] in0,  input [WIDTH-1:0] in1,
    input  [WIDTH-1:0] in2,  input [WIDTH-1:0] in3,
    input  [WIDTH-1:0] in4,  input [WIDTH-1:0] in5,
    input  [WIDTH-1:0] in6,  input [WIDTH-1:0] in7,
    input  [WIDTH-1:0] in8,  input [WIDTH-1:0] in9,
    input  [WIDTH-1:0] in10, input [WIDTH-1:0] in11,
    input  [WIDTH-1:0] in12, input [WIDTH-1:0] in13,
    input  [WIDTH-1:0] in14, input [WIDTH-1:0] in15,
    input  [WIDTH-1:0] in16, input [WIDTH-1:0] in17,
    input  [WIDTH-1:0] in18, input [WIDTH-1:0] in19,
    input  [WIDTH-1:0] in20, input [WIDTH-1:0] in21,
    input  [WIDTH-1:0] in22, input [WIDTH-1:0] in23,
    input  [WIDTH-1:0] in24, input [WIDTH-1:0] in25,
    input  [WIDTH-1:0] in26, input [WIDTH-1:0] in27,
    input  [WIDTH-1:0] in28, input [WIDTH-1:0] in29,
    input  [WIDTH-1:0] in30, input [WIDTH-1:0] in31,
    input  [WIDTH-1:0] in32, input [WIDTH-1:0] in33,
    input  [WIDTH-1:0] in34, input [WIDTH-1:0] in35,
    input  [WIDTH-1:0] in36, input [WIDTH-1:0] in37,
    input  [WIDTH-1:0] in38, input [WIDTH-1:0] in39,
    input  [WIDTH-1:0] in40, input [WIDTH-1:0] in41,
    input  [WIDTH-1:0] in42, input [WIDTH-1:0] in43,
    input  [WIDTH-1:0] in44, input [WIDTH-1:0] in45,
    input  [WIDTH-1:0] in46, input [WIDTH-1:0] in47,
    input  [WIDTH-1:0] in48, input [WIDTH-1:0] in49,
    input  [WIDTH-1:0] in50, input [WIDTH-1:0] in51,
    input  [WIDTH-1:0] in52, input [WIDTH-1:0] in53,
    input  [WIDTH-1:0] in54, input [WIDTH-1:0] in55,
    input  [WIDTH-1:0] in56, input [WIDTH-1:0] in57,
    input  [WIDTH-1:0] in58, input [WIDTH-1:0] in59,
    input  [WIDTH-1:0] in60, input [WIDTH-1:0] in61,
    input  [WIDTH-1:0] in62, input [WIDTH-1:0] in63,
    input  [5:0] sel
);

    genvar i;

    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : mux_bits
            wire o;

            MPS_MUX_IN64 u_mux (
                .out(o),
                .in0(in0[i]),   .in1(in1[i]),
                .in2(in2[i]),   .in3(in3[i]),
                .in4(in4[i]),   .in5(in5[i]),
                .in6(in6[i]),   .in7(in7[i]),
                .in8(in8[i]),   .in9(in9[i]),
                .in10(in10[i]), .in11(in11[i]),
                .in12(in12[i]), .in13(in13[i]),
                .in14(in14[i]), .in15(in15[i]),
                .in16(in16[i]), .in17(in17[i]),
                .in18(in18[i]), .in19(in19[i]),
                .in20(in20[i]), .in21(in21[i]),
                .in22(in22[i]), .in23(in23[i]),
                .in24(in24[i]), .in25(in25[i]),
                .in26(in26[i]), .in27(in27[i]),
                .in28(in28[i]), .in29(in29[i]),
                .in30(in30[i]), .in31(in31[i]),
                .in32(in32[i]), .in33(in33[i]),
                .in34(in34[i]), .in35(in35[i]),
                .in36(in36[i]), .in37(in37[i]),
                .in38(in38[i]), .in39(in39[i]),
                .in40(in40[i]), .in41(in41[i]),
                .in42(in42[i]), .in43(in43[i]),
                .in44(in44[i]), .in45(in45[i]),
                .in46(in46[i]), .in47(in47[i]),
                .in48(in48[i]), .in49(in49[i]),
                .in50(in50[i]), .in51(in51[i]),
                .in52(in52[i]), .in53(in53[i]),
                .in54(in54[i]), .in55(in55[i]),
                .in56(in56[i]), .in57(in57[i]),
                .in58(in58[i]), .in59(in59[i]),
                .in60(in60[i]), .in61(in61[i]),
                .in62(in62[i]), .in63(in63[i]),
                .sel(sel)
            );

            assign out[i] = o;
        end
    endgenerate

endmodule
