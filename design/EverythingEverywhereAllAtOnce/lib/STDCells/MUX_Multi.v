`default_nettype none
////////////////////////////////////////////////////////////////////////////////
// MPS Multi-Input MUX Library (Timing Optimized)
//
// NOTE:
//   All modules use *unpacked (separate) inputs* instead of packed vectors.
//   Example:
//     OLD: input [15:0] in
//     NEW: input in0, in1, ..., in15
//
// Modules:
//   MPS_MUX_IN2  (out, in0, in1, sel)
//   MPS_MUX_IN3  (out, in0, in1, in2, sel[1:0])
//   MPS_MUX_IN4  (out, in0, in1, in2, in3, sel[1:0])
//   MPS_MUX_IN8  (out, in0–in7, sel[2:0])
//   MPS_MUX_IN16 (out, in0–in15, sel[3:0])
//   MPS_MUX_IN32 (out, in0–in31, sel[4:0])
//   MPS_MUX_IN64 (out, in0–in63, sel[5:0])
////////////////////////////////////////////////////////////////////////////////

module MPS_MUX_IN2 (
    output out,
    input in0, in1,
    input sel
);
    mux2$ u0 (.outb(out), .in0(in0), .in1(in1), .s0(sel));

endmodule


//module  mux3$(outb, in0, in1, in2, s0, s1);
module MPS_MUX_IN3 (
    output out,
    input in0, in1, in2,
    input [1:0] sel
);
    mux3$ u0 (
        .outb(out),
        .in0(in0),
        .in1(in1),
        .in2(in2),
        .s0(sel[0]),
        .s1(sel[1])
    );

endmodule

module MPS_MUX_IN4 (
    output out,
    input in0, in1, in2, in3,
    input [1:0] sel
);

    mux4$ u0 (
        .outb(out),
        .in0(in0),
        .in1(in1),
        .in2(in2),
        .in3(in3),
        .s0(sel[0]),
        .s1(sel[1])
    );

endmodule

module MPS_MUX_IN8 (
    output out,
    input in0, in1, in2, in3, in4, in5, in6, in7,
    input [2:0] sel
);

    wire w0, w1;

    // Level 1
    mux4$ u0 (.outb(w0), .in0(in0), .in1(in1), .in2(in2), .in3(in3), .s0(sel[0]), .s1(sel[1]));
    mux4$ u1 (.outb(w1), .in0(in4), .in1(in5), .in2(in6), .in3(in7), .s0(sel[0]), .s1(sel[1]));

    // Level 2
    MPS_MUX_IN2 u2 (out, w0, w1, sel[2]);

endmodule

module MPS_MUX_IN16 (
    output out,
    input in0, input in1, input in2, input in3,
    input in4, input in5, input in6, input in7,
    input in8, input in9, input in10, input in11,
    input in12, input in13, input in14, input in15,
    input [3:0] sel
);

    wire w0, w1, w2, w3;

    // Level 1
    mux4$ u0 (.outb(w0), .in0(in0), .in1(in1), .in2(in2), .in3(in3), .s0(sel[0]), .s1(sel[1]));
    mux4$ u1 (.outb(w1), .in0(in4), .in1(in5), .in2(in6), .in3(in7), .s0(sel[0]), .s1(sel[1]));
    mux4$ u2 (.outb(w2), .in0(in8), .in1(in9), .in2(in10), .in3(in11), .s0(sel[0]), .s1(sel[1]));
    mux4$ u3 (.outb(w3), .in0(in12), .in1(in13), .in2(in14), .in3(in15), .s0(sel[0]), .s1(sel[1]));

    // Level 2
    mux4$ u4 (.outb(out), .in0(w0), .in1(w1), .in2(w2), .in3(w3), .s0(sel[2]), .s1(sel[3]));

endmodule

module MPS_MUX_IN32 (
    output out,
    input in0, input in1, input in2, input in3,
    input in4, input in5, input in6, input in7,
    input in8, input in9, input in10, input in11,
    input in12, input in13, input in14, input in15,
    input in16, input in17, input in18, input in19,
    input in20, input in21, input in22, input in23,
    input in24, input in25, input in26, input in27,
    input in28, input in29, input in30, input in31,
    input [4:0] sel
);

    wire [7:0] w1;
    wire [1:0] w2;

    // Level 1
    mux4$ u0 (.outb(w1[0]), .in0(in0), .in1(in1), .in2(in2), .in3(in3), .s0(sel[0]), .s1(sel[1]));
    mux4$ u1 (.outb(w1[1]), .in0(in4), .in1(in5), .in2(in6), .in3(in7), .s0(sel[0]), .s1(sel[1]));
    mux4$ u2 (.outb(w1[2]), .in0(in8), .in1(in9), .in2(in10), .in3(in11), .s0(sel[0]), .s1(sel[1]));
    mux4$ u3 (.outb(w1[3]), .in0(in12), .in1(in13), .in2(in14), .in3(in15), .s0(sel[0]), .s1(sel[1]));
    mux4$ u4 (.outb(w1[4]), .in0(in16), .in1(in17), .in2(in18), .in3(in19), .s0(sel[0]), .s1(sel[1]));
    mux4$ u5 (.outb(w1[5]), .in0(in20), .in1(in21), .in2(in22), .in3(in23), .s0(sel[0]), .s1(sel[1]));
    mux4$ u6 (.outb(w1[6]), .in0(in24), .in1(in25), .in2(in26), .in3(in27), .s0(sel[0]), .s1(sel[1]));
    mux4$ u7 (.outb(w1[7]), .in0(in28), .in1(in29), .in2(in30), .in3(in31), .s0(sel[0]), .s1(sel[1]));

    // Level 2
    mux4$ u8 (.outb(w2[0]), .in0(w1[0]), .in1(w1[1]), .in2(w1[2]), .in3(w1[3]), .s0(sel[2]), .s1(sel[3]));
    mux4$ u9 (.outb(w2[1]), .in0(w1[4]), .in1(w1[5]), .in2(w1[6]), .in3(w1[7]), .s0(sel[2]), .s1(sel[3]));

    // Level 3
    mux4$ u10 (.outb(out), .in0(w2[0]), .in1(w2[1]), .in2(1'b0), .in3(1'b0), .s0(sel[4]), .s1(1'b0));

endmodule

module MPS_MUX_IN64 (
    output out,
    input in0, input in1, input in2, input in3,
    input in4, input in5, input in6, input in7,
    input in8, input in9, input in10, input in11,
    input in12, input in13, input in14, input in15,
    input in16, input in17, input in18, input in19,
    input in20, input in21, input in22, input in23,
    input in24, input in25, input in26, input in27,
    input in28, input in29, input in30, input in31,
    input in32, input in33, input in34, input in35,
    input in36, input in37, input in38, input in39,
    input in40, input in41, input in42, input in43,
    input in44, input in45, input in46, input in47,
    input in48, input in49, input in50, input in51,
    input in52, input in53, input in54, input in55,
    input in56, input in57, input in58, input in59,
    input in60, input in61, input in62, input in63,
    input [5:0] sel
);

    wire w1[15:0];
    wire w2[3:0];
    wire w3;

    genvar i;

    // Level 1
    generate
        for (i = 0; i < 16; i = i + 1) begin
            mux4$ u (
                .outb(w1[i]),
                .in0(i==0  ? in0  : i==1  ? in4  : i==2  ? in8  : i==3  ? in12 :
                     i==4  ? in16 : i==5  ? in20 : i==6  ? in24 : i==7  ? in28 :
                     i==8  ? in32 : i==9  ? in36 : i==10 ? in40 : i==11 ? in44 :
                     i==12 ? in48 : i==13 ? in52 : i==14 ? in56 : in60),
                .in1(i==0  ? in1  : i==1  ? in5  : i==2  ? in9  : i==3  ? in13 :
                     i==4  ? in17 : i==5  ? in21 : i==6  ? in25 : i==7  ? in29 :
                     i==8  ? in33 : i==9  ? in37 : i==10 ? in41 : i==11 ? in45 :
                     i==12 ? in49 : i==13 ? in53 : i==14 ? in57 : in61),
                .in2(i==0  ? in2  : i==1  ? in6  : i==2  ? in10 : i==3  ? in14 :
                     i==4  ? in18 : i==5  ? in22 : i==6  ? in26 : i==7  ? in30 :
                     i==8  ? in34 : i==9  ? in38 : i==10 ? in42 : i==11 ? in46 :
                     i==12 ? in50 : i==13 ? in54 : i==14 ? in58 : in62),
                .in3(i==0  ? in3  : i==1  ? in7  : i==2  ? in11 : i==3  ? in15 :
                     i==4  ? in19 : i==5  ? in23 : i==6  ? in27 : i==7  ? in31 :
                     i==8  ? in35 : i==9  ? in39 : i==10 ? in43 : i==11 ? in47 :
                     i==12 ? in51 : i==13 ? in55 : i==14 ? in59 : in63),
                .s0(sel[0]),
                .s1(sel[1])
            );
        end
    endgenerate

    // Level 2
    generate
        for (i = 0; i < 4; i = i + 1) begin
            mux4$ u (
                .outb(w2[i]),
                .in0(w1[i*4]),
                .in1(w1[i*4+1]),
                .in2(w1[i*4+2]),
                .in3(w1[i*4+3]),
                .s0(sel[2]),
                .s1(sel[3])
            );
        end
    endgenerate

    // Level 3
    mux4$ u_final (
        .outb(w3),
        .in0(w2[0]),
        .in1(w2[1]),
        .in2(w2[2]),
        .in3(w2[3]),
        .s0(sel[4]),
        .s1(sel[5])
    );

    assign out = w3;

endmodule


