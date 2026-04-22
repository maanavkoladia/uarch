`celldefine

/* ---------------- and5$ ---------------- */
module and5$(out,in0,in1,in2,in3,in4);

output out;
input in0,in1,in2,in3,in4;

wire t0,t1;

and3$ g0(t0,in0,in1,in2);
and2$ g1(t1,in3,in4);
and2$ g2(out,t0,t1);

endmodule


/* ---------------- and6$ ---------------- */
module and6$(out,in0,in1,in2,in3,in4,in5);

output out;
input in0,in1,in2,in3,in4,in5;

wire t0,t1;

and3$ g0(t0,in0,in1,in2);
and3$ g1(t1,in3,in4,in5);
and2$ g2(out,t0,t1);

endmodule


/* ---------------- and7$ ---------------- */
module and7$(out,in0,in1,in2,in3,in4,in5,in6);

output out;
input in0,in1,in2,in3,in4,in5,in6;

wire t0,t1,t2;

and3$ g0(t0,in0,in1,in2);
and2$ g1(t1,in3,in4);
and2$ g2(t2,in5,in6);
and3$ g3(out,t0,t1,t2);

endmodule


/* ---------------- and8$ ---------------- */
module and8$(out,in0,in1,in2,in3,in4,in5,in6,in7);

output out;
input in0,in1,in2,in3,in4,in5,in6,in7;

wire t0,t1,t2;

and3$ g0(t0,in0,in1,in2);
and3$ g1(t1,in3,in4,in5);
and2$ g2(t2,in6,in7);
and3$ g3(out,t0,t1,t2);

endmodule


/* ---------------- and9$ ---------------- */
module and9$(out,in0,in1,in2,in3,in4,in5,in6,in7,in8);

output out;
input in0,in1,in2,in3,in4,in5,in6,in7,in8;

wire t0,t1,t2;

and3$ g0(t0,in0,in1,in2);
and3$ g1(t1,in3,in4,in5);
and3$ g2(t2,in6,in7,in8);
and3$ g3(out,t0,t1,t2);

endmodule


/* ---------------- and10$ ---------------- */
module and10$(out,in0,in1,in2,in3,in4,in5,in6,in7,in8,in9);

output out;
input in0,in1,in2,in3,in4,in5,in6,in7,in8,in9;

wire t0,t1,t2,t3,t4;

and3$ g0(t0,in0,in1,in2);
and3$ g1(t1,in3,in4,in5);
and2$ g2(t2,in6,in7);
and2$ g3(t3,in8,in9);

and2$ g4(t4,t2,t3);
and3$ g5(out,t0,t1,t4);

endmodule


/* ---------------- and11$ ---------------- */
module and11$(out,in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10);

output out;
input in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10;

wire t0,t1,t2,t3,t4;

and3$ g0(t0,in0,in1,in2);
and3$ g1(t1,in3,in4,in5);
and3$ g2(t2,in6,in7,in8);
and2$ g3(t3,in9,in10);

and2$ g4(t4,t0,t1);
and3$ g5(out,t4,t2,t3);

endmodule


/* ---------------- and12$ ---------------- */
module and12$(out,in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11);

output out;
input in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11;

wire t0,t1,t2,t3,t4,t5;

and3$ g0(t0,in0,in1,in2);
and3$ g1(t1,in3,in4,in5);
and3$ g2(t2,in6,in7,in8);
and3$ g3(t3,in9,in10,in11);

and2$ g4(t4,t0,t1);
and2$ g5(t5,t2,t3);
and2$ g6(out,t4,t5);

endmodule


`endcelldefine
