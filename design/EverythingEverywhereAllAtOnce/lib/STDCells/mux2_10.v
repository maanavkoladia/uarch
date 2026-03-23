module mux2_10 (
    input [9:0] in0, in1,
    input sel,
    output [9:0] out
);

    genvar i;
    generate
        for(i=0; i<10; i=i+1) begin : g_mux2_10_sub_muxes_0
            mux2$ muxX(out[i], in0[i], in1[i], sel);
        end
    endgenerate
    
endmodule
