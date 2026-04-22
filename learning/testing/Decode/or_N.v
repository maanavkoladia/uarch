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

`endcelldefine
