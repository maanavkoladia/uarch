module mux2_3 (
    input [2:0] in0, in1,
    input sel,
    output [2:0] out
);
    mux2$ mux0(out[0], in0[0], in1[0], sel);
    mux2$ mux1(out[1], in0[1], in1[1], sel);
    mux2$ mux2(out[2], in0[2], in1[2], sel);
    
endmodule