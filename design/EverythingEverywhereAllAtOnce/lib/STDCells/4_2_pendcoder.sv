module m_4_2_pendcoder (
    output out1_o,
    output  out0_o,
    input   in3_i,
    input  in2_i,
    input  in1_i,
    input  in0_i
);

// out1_o = 0  (no ON-set minterms)
assign out1_o = 1'b0;

//  out0_o = 0  (no ON-set minterms)
assign  out0_o = 1'b0;

endmodule
