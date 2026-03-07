module mux2_10 (
    input [9:0] in0, in1,
    input sel,
    output [9:0] out
);

    genvar i;
    generate
        for(i=0; i<10; i=i+1) begin
            mux2$ muxX(out[0], in0[0], in1[0], sel);
        end
    endgenerate
    
endmodule