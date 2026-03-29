//format
//muxX_Y: X = num inputs, Y = num output bits

module mux2_3 (
    input [2:0] in0, in1,
    input sel,
    output [2:0] out
);
    mux2$ mux0(out[0], in0[0], in1[0], sel);
    mux2$ mux1(out[1], in0[1], in1[1], sel);
    mux2$ mux2(out[2], in0[2], in1[2], sel);

endmodule

module mux2_10 (
    input [9:0] in0, in1,
    input sel,
    output [9:0] out
);

    genvar i;
    generate
        for(i=0; i<10; i=i+1) begin : g_mux2_10_sub_muxes_0
            mux2$ muxX(out[i], in0[i], in1[i], sel);
        end
    endgenerate

endmodule

module mux4_4 (
    input [3:0] in0, in1, in2, in3,
    input sel0, sel1,
    output [3:0] out
);
    mux4$ mux0(out[0], in0[0], in1[0], in2[0], in3[0], sel0, sel1);
    mux4$ mux1(out[1], in0[1], in1[1], in2[1], in3[1], sel0, sel1);
    mux4$ mux2(out[2], in0[2], in1[2], in2[2], in3[2], sel0, sel1);
    mux4$ mux3(out[3], in0[3], in1[3], in2[3], in3[3], sel0, sel1);

endmodule


module mux64_8 (
    input [63:0][7:0] in,
    input [5:0] sel,
    output [7:0] out
);
    //mux4_8$ mux0(Y,IN0,IN1,IN2,IN3,S0,S1);

    wire [15:0][7:0] firstlayer;
    wire [3:0][7:0] secondlayer;

    genvar i;
    generate
        for (i=0; i<16 ; i=i+1) begin : g_mux64_8_sub_muxes_0
            mux4_8$ mux0 (firstlayer[i], in[i*4], in[i*4 + 1], in[i*4 + 2], in[i*4 + 3], sel[0], sel[1]);
        end
    endgenerate

    generate
        for (i=0; i<4 ; i=i+1) begin : g_mux64_8_sub_muxes_1
            mux4_8$ mux1 (secondlayer[i], firstlayer[i*4], firstlayer[i*4 + 1], firstlayer[i*4 + 2], firstlayer[i*4 + 3], sel[2], sel[3]);
        end
    endgenerate

mux4_8$ mux2 (out, secondlayer[0], secondlayer[1], secondlayer[2], secondlayer[3], sel[4], sel[5]);

endmodule

module mux4_32 (
    input [31:0] in0, in1, in2, in3,
    input sel0, sel1,
    output [31:0] out
);
    mux4_16$ first16 (.IN0(in0[15:0]), .IN1(in1[15:0]), .IN2(in2[15:0]), .IN3(in3[15:0]), .S0(sel0), .S1(sel1), .Y(out[15:0]));
    mux4_16$ last16 (.IN0(in0[31:16]), .IN1(in1[31:16]), .IN2(in2[31:16]), .IN3(in3[31:16]), .S0(sel0), .S1(sel1), .Y(out[31:16]));

endmodule

module mux4_64 (
    input [63:0] in0, in1, in2, in3,
    input sel0, sel1,
    output [63:0] out
);
    mux4_64 first32 (.in0(in0[31:0]), .in1(in1[31:0]), .in2(in2[31:0]), .in3(in3[31:0]), .sel0(sel0), .sel1(sel1), .out(out[31:0]));
    mux4_64 last32 (.in0(in0[63:32]), .in1(in1[63:32]), .in2(in2[63:32]), .in3(in3[63:32]), .sel0(sel0), .sel1(sel1), .out(out[63:32]));

endmodule
