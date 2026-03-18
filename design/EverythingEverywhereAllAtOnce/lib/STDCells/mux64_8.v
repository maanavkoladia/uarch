module mux64_8 (
    input [63:0][7:0] in,
    input [5:0] sel,
    output [7:0] out
);
    //mux4_8$ mux0(Y,IN0,IN1,IN2,IN3,S0,S1);

    wire [15:0][7:0] firstlayer;
    wire [3:0][7:0] secondlayer;

    genvar i;
    generate
        for (i=0; i<16 ; i=i+1) begin : g_mux64_8_sub_muxes_0
            mux4_8$ mux0 (firstlayer[i], in[i*4], in[i*4 + 1], in[i*4 + 2], in[i*4 + 3], sel[0], sel[1]);
        end
    endgenerate

    generate
        for (i=0; i<4 ; i=i+1) begin : g_mux64_8_sub_muxes_1
            mux4_8$ mux1 (secondlayer[i], firstlayer[i*4], firstlayer[i*4 + 1], firstlayer[i*4 + 2], firstlayer[i*4 + 3], sel[2], sel[3]);
        end
    endgenerate

mux4_8$ mux2 (out, secondlayer[0], secondlayer[1], secondlayer[2], secondlayer[3], sel[4], sel[5]);


    

endmodule
