module triple_adder (
    input [2:0] in0, in1, in2,
    output [4:0] result
);
    three_input_adder three_input_add(
        .out4_o(result[4]), .out3_o(result[3]), .out2_o(result[2]), .out1_o(result[1]), .out0_o(result[0]),
        .in2_2_i(in2[2]), .in2_1_i(in2[1]), .in2_0_i(in2[0]),
        .in1_2_i(in1[2]), .in1_1_i(in1[1]), .in1_0_i(in1[0]),
        .in0_2_i(in0[2]), .in0_1_i(in0[1]), .in0_0_i(in0[0]));     
endmodule
