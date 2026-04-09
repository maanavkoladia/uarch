/* ============================================================
 * Module Summary: MPS Multi-Input AND Library
 * ============================================================
 *
 * MPS_AND_IN2 (
 *     out,
 *     in0, in1
 * );
 *
 * MPS_AND_IN3 (
 *     out,
 *     in0, in1, in2
 * );
 *
 * MPS_AND_IN4 (
 *     out,
 *     in0, in1, in2, in3
 * );
 *
 * MPS_AND_IN5$ (
 *     out,
 *     in0, in1, in2, in3, in4
 * );
 *
 * MPS_AND_IN6$ (
 *     out,
 *     in0, in1, in2, in3, in4, in5
 * );
 *
 * MPS_AND_IN7$ (
 *     out,
 *     in0, in1, in2, in3, in4, in5, in6
 * );
 *
 * MPS_AND_IN8$ (
 *     out,
 *     in0, in1, in2, in3, in4, in5, in6, in7
 * );
 *
 * MPS_AND_IN9$ (
 *     out,
 *     in0, in1, in2, in3, in4, in5, in6, in7, in8
 * );
 *
 * MPS_AND_IN10$ (
 *     out,
 *     in0, in1, in2, in3, in4, in5, in6, in7, in8, in9
 * );
 *
 * MPS_AND_IN11$ (
 *     out,
 *     in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10
 * );
 *
 * MPS_AND_IN12$ (
 *     out,
 *     in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11
 * );
 *
 * ============================================================
 */

module MPS_AND_IN2 (
    out,
    in0,
    in1
);

    output out;
    input in0, in1;

    mux2$ g0 (
        .outb(out),   // match your mux port name
        .in0 (1'b0),
        .in1 (in1),
        .s0  (in0)
    );

endmodule

module MPS_AND_IN3 (
    out,
    in0,
    in1,
    in2
);

    output out;
    input in0, in1, in2;

    and3$ g0 (
        .out(out),
        .in0(in0),
        .in1(in1),
        .in2(in2)
    );

endmodule

module MPS_AND_IN4 (
    out,
    in0,
    in1,
    in2,
    in3
);

    output out;
    input in0, in1, in2, in3;

    and4$ g0 (
        .out(out),
        .in0(in0),
        .in1(in1),
        .in2(in2),
        .in3(in3)
    );

endmodule



/* ---------------- and5$ ---------------- */
module MPS_AND_IN5$ (
    out,
    in0,
    in1,
    in2,
    in3,
    in4
);

    output out;
    input in0, in1, in2, in3, in4;

    wire t0, t1;

    MPS_AND_IN3 g0 (
        t0,
        in0,
        in1,
        in2
    );

    MPS_AND_IN2 g1 (
        t1,
        in3,
        in4
    );

    MPS_AND_IN2 g2 (
        out,
        t0,
        t1
    );

endmodule

/* ---------------- and6$ ---------------- */
module MPS_AND_IN6$ (
    out,
    in0,
    in1,
    in2,
    in3,
    in4,
    in5
);

    output out;
    input in0, in1, in2, in3, in4, in5;

    wire t0, t1;

    MPS_AND_IN3 g0 (
        t0,
        in0,
        in1,
        in2
    );

    MPS_AND_IN3 g1 (
        t1,
        in3,
        in4,
        in5
    );

    MPS_AND_IN2 g2 (
        out,
        t0,
        t1
    );

endmodule

/* ---------------- and7$ ---------------- */
module MPS_AND_IN7$ (
    out,
    in0,
    in1,
    in2,
    in3,
    in4,
    in5,
    in6
);

    output out;
    input in0, in1, in2, in3, in4, in5, in6;

    wire t0, t1, t2;

    MPS_AND_IN3 g0 (
        t0,
        in0,
        in1,
        in2
    );

    MPS_AND_IN2 g1 (
        t1,
        in3,
        in4
    );

    MPS_AND_IN2 g2 (
        t2,
        in5,
        in6
    );

    MPS_AND_IN3 g3 (
        out,
        t0,
        t1,
        t2
    );

endmodule

/* ---------------- and8$ ---------------- */
module MPS_AND_IN8$ (
    out,
    in0,
    in1,
    in2,
    in3,
    in4,
    in5,
    in6,
    in7
);

    output out;
    input in0, in1, in2, in3, in4, in5, in6, in7;

    wire t0, t1, t2;

    MPS_AND_IN3 g0 (
        t0,
        in0,
        in1,
        in2
    );

    MPS_AND_IN3 g1 (
        t1,
        in3,
        in4,
        in5
    );

    MPS_AND_IN2 g2 (
        t2,
        in6,
        in7
    );

    MPS_AND_IN3 g3 (
        out,
        t0,
        t1,
        t2
    );

endmodule
/* ---------------- and9$ ---------------- */
module MPS_AND_IN9$ (
    out,
    in0,
    in1,
    in2,
    in3,
    in4,
    in5,
    in6,
    in7,
    in8
);

    output out;
    input in0, in1, in2, in3, in4, in5, in6, in7, in8;

    wire t0, t1, t2;

    MPS_AND_IN3 g0 (
        t0,
        in0,
        in1,
        in2
    );

    MPS_AND_IN3 g1 (
        t1,
        in3,
        in4,
        in5
    );

    MPS_AND_IN3 g2 (
        t2,
        in6,
        in7,
        in8
    );

    MPS_AND_IN3 g3 (
        out,
        t0,
        t1,
        t2
    );

endmodule
/* ---------------- and10$ ---------------- */
module MPS_AND_IN10$ (
    out,
    in0,
    in1,
    in2,
    in3,
    in4,
    in5,
    in6,
    in7,
    in8,
    in9
);

    output out;
    input in0, in1, in2, in3, in4, in5, in6, in7, in8, in9;

    wire t0, t1, t2, t3, t4;

    MPS_AND_IN3 g0 (
        t0,
        in0,
        in1,
        in2
    );

    MPS_AND_IN3 g1 (
        t1,
        in3,
        in4,
        in5
    );

    MPS_AND_IN2 g2 (
        t2,
        in6,
        in7
    );

    MPS_AND_IN2 g3 (
        t3,
        in8,
        in9
    );

    MPS_AND_IN2 g4 (
        t4,
        t2,
        t3
    );

    MPS_AND_IN3 g5 (
        out,
        t0,
        t1,
        t4
    );

endmodule
/* ---------------- and11$ ---------------- */
module MPS_AND_IN11$ (
    out,
    in0,
    in1,
    in2,
    in3,
    in4,
    in5,
    in6,
    in7,
    in8,
    in9,
    in10
);

    output out;
    input in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10;

    wire t0, t1, t2, t3, t4;

    MPS_AND_IN3 g0 (
        t0,
        in0,
        in1,
        in2
    );

    MPS_AND_IN3 g1 (
        t1,
        in3,
        in4,
        in5
    );

    MPS_AND_IN3 g2 (
        t2,
        in6,
        in7,
        in8
    );

    MPS_AND_IN2 g3 (
        t3,
        in9,
        in10
    );

    MPS_AND_IN2 g4 (
        t4,
        t0,
        t1
    );

    MPS_AND_IN3 g5 (
        out,
        t4,
        t2,
        t3
    );

endmodule
/* ---------------- and12$ ---------------- */
module MPS_AND_IN12$ (
    out,
    in0,
    in1,
    in2,
    in3,
    in4,
    in5,
    in6,
    in7,
    in8,
    in9,
    in10,
    in11
);

    output out;
    input in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11;

    wire t0, t1, t2, t3, t4, t5;

    MPS_AND_IN3 g0 (
        t0,
        in0,
        in1,
        in2
    );

    MPS_AND_IN3 g1 (
        t1,
        in3,
        in4,
        in5
    );

    MPS_AND_IN3 g2 (
        t2,
        in6,
        in7,
        in8
    );

    MPS_AND_IN3 g3 (
        t3,
        in9,
        in10,
        in11
    );

    MPS_AND_IN2 g4 (
        t4,
        t0,
        t1
    );

    MPS_AND_IN2 g5 (
        t5,
        t2,
        t3
    );

    MPS_AND_IN2 g6 (
        out,
        t4,
        t5
    );

endmodule
