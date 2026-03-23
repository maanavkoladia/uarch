`celldefine

/* ---------------- or5$ ---------------- */
module or5$(out,in0,in1,in2,in3,in4);

output out;
input in0,in1,in2,in3,in4;

wire t0,t1,t2;

or2$ g0(t0,in0,in1);
or2$ g1(t1,in2,in3);
or2$ g2(t2,t0,t1);
or2$ g3(out,t2,in4);

endmodule


/* ---------------- or6$ ---------------- */
module or6$(out,in0,in1,in2,in3,in4,in5);

output out;
input in0,in1,in2,in3,in4,in5;

wire t0,t1,t2,t3;

or2$ g0(t0,in0,in1);
or2$ g1(t1,in2,in3);
or2$ g2(t2,in4,in5);

or2$ g3(t3,t0,t1);
or2$ g4(out,t3,t2);

endmodule


/* ---------------- or7$ ---------------- */
module or7$(out,in0,in1,in2,in3,in4,in5,in6);

output out;
input in0,in1,in2,in3,in4,in5,in6;

wire t0,t1,t2,t3,t4;

or2$ g0(t0,in0,in1);
or2$ g1(t1,in2,in3);
or2$ g2(t2,in4,in5);

or2$ g3(t3,t0,t1);
or2$ g4(t4,t2,in6);
or2$ g5(out,t3,t4);

endmodule


/* ---------------- or8$ ---------------- */
module or8$(out,in0,in1,in2,in3,in4,in5,in6,in7);

output out;
input in0,in1,in2,in3,in4,in5,in6,in7;

wire t0,t1,t2,t3,t4,t5;

or2$ g0(t0,in0,in1);
or2$ g1(t1,in2,in3);
or2$ g2(t2,in4,in5);
or2$ g3(t3,in6,in7);

or2$ g4(t4,t0,t1);
or2$ g5(t5,t2,t3);
or2$ g6(out,t4,t5);

endmodule


/* ---------------- or9$ ---------------- */
module or9$(out,in0,in1,in2,in3,in4,in5,in6,in7,in8);

output out;
input in0,in1,in2,in3,in4,in5,in6,in7,in8;

wire t0,t1,t2,t3,t4,t5,t6;

or2$ g0(t0,in0,in1);
or2$ g1(t1,in2,in3);
or2$ g2(t2,in4,in5);
or2$ g3(t3,in6,in7);

or2$ g4(t4,t0,t1);
or2$ g5(t5,t2,t3);
or2$ g6(t6,t4,t5);

or2$ g7(out,t6,in8);

endmodule


/* ---------------- or10$ ---------------- */
module or10$(out,in0,in1,in2,in3,in4,in5,in6,in7,in8,in9);

output out;
input in0,in1,in2,in3,in4,in5,in6,in7,in8,in9;

wire t0,t1,t2,t3,t4,t5,t6,t7;

or2$ g0(t0,in0,in1);
or2$ g1(t1,in2,in3);
or2$ g2(t2,in4,in5);
or2$ g3(t3,in6,in7);
or2$ g4(t4,in8,in9);

or2$ g5(t5,t0,t1);
or2$ g6(t6,t2,t3);

or2$ g7(t7,t5,t6);
or2$ g8(out,t7,t4);

endmodule


/* ---------------- or11$ ---------------- */
module or11$(out,in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10);

output out;
input in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10;

wire t0,t1,t2,t3,t4,t5,t6,t7,t8;

or2$ g0(t0,in0,in1);
or2$ g1(t1,in2,in3);
or2$ g2(t2,in4,in5);
or2$ g3(t3,in6,in7);
or2$ g4(t4,in8,in9);

or2$ g5(t5,t0,t1);
or2$ g6(t6,t2,t3);

or2$ g7(t7,t5,t6);
or2$ g8(t8,t7,t4);

or2$ g9(out,t8,in10);

endmodule


/* ---------------- or12$ ---------------- */
module or12$(out,in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11);

output out;
input in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11;

wire t0,t1,t2,t3,t4,t5,t6,t7,t8,t9;

or2$ g0(t0,in0,in1);
or2$ g1(t1,in2,in3);
or2$ g2(t2,in4,in5);
or2$ g3(t3,in6,in7);
or2$ g4(t4,in8,in9);
or2$ g5(t5,in10,in11);

or2$ g6(t6,t0,t1);
or2$ g7(t7,t2,t3);
or2$ g8(t8,t4,t5);

or2$ g9(t9,t6,t7);
or2$ g10(out,t9,t8);

endmodule

module or21$ (
    out,
    in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,
    in12,in13,in14,in15,in16,in17,in18,in19,in20
);

    output out;
    input  in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,
           in12,in13,in14,in15,in16,in17,in18,in19,in20;

    wire t0, t1;

    // 12 inputs
    or12$ g0 (t0, in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11);

    // remaining 9 inputs
    or9$  g1 (t1, in12,in13,in14,in15,in16,in17,in18,in19,in20);

    // combine
    or2$  g2 (out, t0, t1);

endmodule

module or24$ (
    out,
    in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,
    in12,in13,in14,in15,in16,in17,in18,in19,in20,in21,in22,in23
);

    output out;
    input  in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,
           in12,in13,in14,in15,in16,in17,in18,in19,in20,in21,in22,in23;

    wire t0, t1;

    or12$ g0 (t0, in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11);
    or12$ g1 (t1, in12,in13,in14,in15,in16,in17,in18,in19,in20,in21,in22,in23);

    or2$  g2 (out, t0, t1);

endmodule



module or64$ (
    out,
    in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,
    in12,in13,in14,in15,in16,in17,in18,in19,in20,in21,in22,in23,
    in24,in25,in26,in27,in28,in29,in30,in31,in32,in33,in34,in35,
    in36,in37,in38,in39,in40,in41,in42,in43,in44,in45,in46,in47,
    in48,in49,in50,in51,in52,in53,in54,in55,in56,in57,in58,in59,
    in60,in61,in62,in63
);

    output out;
    input  in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,
           in12,in13,in14,in15,in16,in17,in18,in19,in20,in21,in22,in23,
           in24,in25,in26,in27,in28,in29,in30,in31,in32,in33,in34,in35,
           in36,in37,in38,in39,in40,in41,in42,in43,in44,in45,in46,in47,
           in48,in49,in50,in51,in52,in53,in54,in55,in56,in57,in58,in59,
           in60,in61,in62,in63;

    wire t0, t1, t2;

    // 24 + 24
    or24$ g0 (t0,
        in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,
        in12,in13,in14,in15,in16,in17,in18,in19,in20,in21,in22,in23);

    or24$ g1 (t1,
        in24,in25,in26,in27,in28,in29,in30,in31,in32,in33,in34,in35,
        in36,in37,in38,in39,in40,in41,in42,in43,in44,in45,in46,in47);

    // remaining 16
    or12$ g2 (t2, in48,in49,in50,in51,in52,in53,in54,in55,in56,in57,in58,in59);
    or4$  g3 (t3, in60,in61,in62,in63);

    or2$  g4 (t4, t2, t3);

    // final combine
    or3$  g5 (out, t0, t1, t4);

endmodule

module or112$ (
    out,
    in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,
    in12,in13,in14,in15,in16,in17,in18,in19,in20,in21,in22,in23,
    in24,in25,in26,in27,in28,in29,in30,in31,in32,in33,in34,in35,
    in36,in37,in38,in39,in40,in41,in42,in43,in44,in45,in46,in47,
    in48,in49,in50,in51,in52,in53,in54,in55,in56,in57,in58,in59,
    in60,in61,in62,in63,
    in64,in65,in66,in67,in68,in69,in70,in71,in72,in73,in74,in75,
    in76,in77,in78,in79,in80,in81,in82,in83,in84,in85,in86,in87,
    in88,in89,in90,in91,in92,in93,in94,in95,in96,in97,in98,in99,
    in100,in101,in102,in103,in104,in105,in106,in107,in108,in109,in110,in111
);

    output out;
    input  in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,
           in12,in13,in14,in15,in16,in17,in18,in19,in20,in21,in22,in23,
           in24,in25,in26,in27,in28,in29,in30,in31,in32,in33,in34,in35,
           in36,in37,in38,in39,in40,in41,in42,in43,in44,in45,in46,in47,
           in48,in49,in50,in51,in52,in53,in54,in55,in56,in57,in58,in59,
           in60,in61,in62,in63,
           in64,in65,in66,in67,in68,in69,in70,in71,in72,in73,in74,in75,
           in76,in77,in78,in79,in80,in81,in82,in83,in84,in85,in86,in87,
           in88,in89,in90,in91,in92,in93,in94,in95,in96,in97,in98,in99,
           in100,in101,in102,in103,in104,in105,in106,in107,in108,in109,in110,in111;

    wire t0, t1, t2;

    // 64 block
    or64$ g0 (t0,
        in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,
        in12,in13,in14,in15,in16,in17,in18,in19,in20,in21,in22,in23,
        in24,in25,in26,in27,in28,in29,in30,in31,in32,in33,in34,in35,
        in36,in37,in38,in39,in40,in41,in42,in43,in44,in45,in46,in47,
        in48,in49,in50,in51,in52,in53,in54,in55,in56,in57,in58,in59,
        in60,in61,in62,in63
    );

    // 24 block
    or24$ g1 (t1,
        in64,in65,in66,in67,in68,in69,in70,in71,in72,in73,in74,in75,
        in76,in77,in78,in79,in80,in81,in82,in83,in84,in85,in86,in87
    );

    // 24 block
    or24$ g2 (t2,
        in88,in89,in90,in91,in92,in93,in94,in95,in96,in97,in98,in99,
        in100,in101,in102,in103,in104,in105,in106,in107,in108,in109,in110,in111
    );

    // final combine
    or3$ g3 (out, t0, t1, t2);

endmodule

`endcelldefine
