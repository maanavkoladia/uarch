module simple (
    output  y_o,
    input  a_i,
    input   b_i
);

//  y_o = (a_i &  b_i)
and2$  y_o_and ( y_o, a_i, b_i);

endmodule
