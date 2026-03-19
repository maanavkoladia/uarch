module selection_logic (
    input [63:0][7:0] queue,
    input [31:0] EIP,
    output [15:0][7:0] IRbyte
);

    wire [15:0][5:0] temp;
    assign temp[0] = EIP[5:0];
    assign temp[1] = EIP[5:0] + 6'd1;
    assign temp[2] = EIP[5:0] + 6'd2;
    assign temp[3] = EIP[5:0] + 6'd3;

    assign temp[4] = EIP[5:0] + 6'd4;
    assign temp[5] = EIP[5:0] + 6'd5;
    assign temp[6] = EIP[5:0] + 6'd6;
    assign temp[7] = EIP[5:0] + 6'd7;

    assign temp[8] = EIP[5:0] + 6'd8;
    assign temp[9] = EIP[5:0] + 6'd9;
    assign temp[10] = EIP[5:0] + 6'd10;
    assign temp[11] = EIP[5:0] + 6'd11;

    assign temp[12] = EIP[5:0] + 6'd12;
    assign temp[13] = EIP[5:0] + 6'd13;
    assign temp[14] = EIP[5:0] + 6'd14;
    assign temp[15] = EIP[5:0] + 6'd15;

    ir_logic ir_logic_module(
        .o0_5_o(temp[0][5]), .o0_4_o(temp[0][4]), .o0_3_o(temp[0][3]), .o0_2_o(temp[0][2]), .o0_1_o(temp[0][1]), .o0_0_o(temp[0][0]),
        .o1_5_o(temp[1][5]), .o1_4_o(temp[1][4]), .o1_3_o(temp[1][3]), .o1_2_o(temp[1][2]), .o1_1_o(temp[1][1]), .o1_0_o(temp[1][0]),
        .o2_5_o(temp[2][5]), .o2_4_o(temp[2][4]), .o2_3_o(temp[2][3]), .o2_2_o(temp[2][2]), .o2_1_o(temp[2][1]), .o2_0_o(temp[2][0]),
        .o3_5_o(temp[3][5]), .o3_4_o(temp[3][4]), .o3_3_o(temp[3][3]), .o3_2_o(temp[3][2]), .o3_1_o(temp[3][1]), .o3_0_o(temp[3][0]),
        .o4_5_o(temp[4][5]), .o4_4_o(temp[4][4]), .o4_3_o(temp[4][3]), .o4_2_o(temp[4][2]), .o4_1_o(temp[4][1]), .o4_0_o(temp[4][0]),
        .o5_5_o(temp[5][5]), .o5_4_o(temp[5][4]), .o5_3_o(temp[5][3]), .o5_2_o(temp[5][2]), .o5_1_o(temp[5][1]), .o5_0_o(temp[5][0]),
        .o6_5_o(temp[6][5]), .o6_4_o(temp[6][4]), .o6_3_o(temp[6][3]), .o6_2_o(temp[6][2]), .o6_1_o(temp[6][1]), .o6_0_o(temp[6][0]),
        .o7_5_o(temp[7][5]), .o7_4_o(temp[7][4]), .o7_3_o(temp[7][3]), .o7_2_o(temp[7][2]), .o7_1_o(temp[7][1]), .o7_0_o(temp[7][0]),
        .o8_5_o(temp[8][5]), .o8_4_o(temp[8][4]), .o8_3_o(temp[8][3]), .o8_2_o(temp[8][2]), .o8_1_o(temp[8][1]), .o8_0_o(temp[8][0]),
        .o9_5_o(temp[9][5]), .o9_4_o(temp[9][4]), .o9_3_o(temp[9][3]), .o9_2_o(temp[9][2]), .o9_1_o(temp[9][1]), .o9_0_o(temp[9][0]),
        .o10_5_o(temp[10][5]), .o10_4_o(temp[10][4]), .o10_3_o(temp[10][3]), .o10_2_o(temp[10][2]), .o10_1_o(temp[10][1]), .o10_0_o(temp[10][0]),
        .o11_5_o(temp[11][5]), .o11_4_o(temp[11][4]), .o11_3_o(temp[11][3]), .o11_2_o(temp[11][2]), .o11_1_o(temp[11][1]), .o11_0_o(temp[11][0]),
        .o12_5_o(temp[12][5]), .o12_4_o(temp[12][4]), .o12_3_o(temp[12][3]), .o12_2_o(temp[12][2]), .o12_1_o(temp[12][1]), .o12_0_o(temp[12][0]),
        .o13_5_o(temp[13][5]), .o13_4_o(temp[13][4]), .o13_3_o(temp[13][3]), .o13_2_o(temp[13][2]), .o13_1_o(temp[13][1]), .o13_0_o(temp[13][0]),
        .o14_5_o(temp[14][5]), .o14_4_o(temp[14][4]), .o14_3_o(temp[14][3]), .o14_2_o(temp[14][2]), .o14_1_o(temp[14][1]), .o14_0_o(temp[14][0]),
        .o15_5_o(temp[15][5]), .o15_4_o(temp[15][4]), .o15_3_o(temp[15][3]), .o15_2_o(temp[15][2]), .o15_1_o(temp[15][1]), .o15_0_o(temp[15][0]),

        .i5_i(EIP[5]), .i4_i(EIP[4]), .i3_i(EIP[3]), .i2_i(EIP[2]), .i1_i(EIP[1]), .i0_i(EIP[0])
    );



    genvar i;
    generate
        for(i = 0; i < 16; i=i+1) begin : IR_sel_mux
            mux64_8 sixtyfourmux(.in(queue), .sel(temp[i]), .out(IRbyte[i]));
        end
    endgenerate

endmodule
