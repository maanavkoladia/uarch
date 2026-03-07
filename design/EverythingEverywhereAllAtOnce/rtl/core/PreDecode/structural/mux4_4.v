module mux4_4 (
    input [3:0] in0, in1, in2, in3
    input sel0, sel1,
    output [3:0] out
);
    mux4$ mux0(out[0], in0[0], in1[0], in2[0], in3[0], sel0, sel1);
    mux4$ mux1(out[1], in0[1], in1[1], in2[1], in3[1], sel0, sel1);
    mux4$ mux2(out[2], in0[2], in1[2], in2[2], in3[2], sel0, sel1);
    mux4$ mux3(out[3], in0[3], in1[3], in2[3], in3[3], sel0, sel1);


    
endmodule