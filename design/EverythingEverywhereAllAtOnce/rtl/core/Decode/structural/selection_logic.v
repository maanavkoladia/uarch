module selection_logic (
    input [63:0][7:0] queue,
    input [31:0] EIP,
    input [3:0] queue_valid,
    output [15:0][7:0] IR,
    output [15:0] IR_valid_vect
);

    wire [15:0][5:0] sel_index;
    wire [15:0] adder_cout;

    ir_logic ir_logic_module(
        .o0_5_o(sel_index[0][5]), .o0_4_o(sel_index[0][4]), .o0_3_o(sel_index[0][3]), .o0_2_o(sel_index[0][2]), .o0_1_o(sel_index[0][1]), .o0_0_o(sel_index[0][0]),
        .o1_5_o(sel_index[1][5]), .o1_4_o(sel_index[1][4]), .o1_3_o(sel_index[1][3]), .o1_2_o(sel_index[1][2]), .o1_1_o(sel_index[1][1]), .o1_0_o(sel_index[1][0]),
        .o2_5_o(sel_index[2][5]), .o2_4_o(sel_index[2][4]), .o2_3_o(sel_index[2][3]), .o2_2_o(sel_index[2][2]), .o2_1_o(sel_index[2][1]), .o2_0_o(sel_index[2][0]),
        .o3_5_o(sel_index[3][5]), .o3_4_o(sel_index[3][4]), .o3_3_o(sel_index[3][3]), .o3_2_o(sel_index[3][2]), .o3_1_o(sel_index[3][1]), .o3_0_o(sel_index[3][0]),
        .o4_5_o(sel_index[4][5]), .o4_4_o(sel_index[4][4]), .o4_3_o(sel_index[4][3]), .o4_2_o(sel_index[4][2]), .o4_1_o(sel_index[4][1]), .o4_0_o(sel_index[4][0]),
        .o5_5_o(sel_index[5][5]), .o5_4_o(sel_index[5][4]), .o5_3_o(sel_index[5][3]), .o5_2_o(sel_index[5][2]), .o5_1_o(sel_index[5][1]), .o5_0_o(sel_index[5][0]),
        .o6_5_o(sel_index[6][5]), .o6_4_o(sel_index[6][4]), .o6_3_o(sel_index[6][3]), .o6_2_o(sel_index[6][2]), .o6_1_o(sel_index[6][1]), .o6_0_o(sel_index[6][0]),
        .o7_5_o(sel_index[7][5]), .o7_4_o(sel_index[7][4]), .o7_3_o(sel_index[7][3]), .o7_2_o(sel_index[7][2]), .o7_1_o(sel_index[7][1]), .o7_0_o(sel_index[7][0]),
        .o8_5_o(sel_index[8][5]), .o8_4_o(sel_index[8][4]), .o8_3_o(sel_index[8][3]), .o8_2_o(sel_index[8][2]), .o8_1_o(sel_index[8][1]), .o8_0_o(sel_index[8][0]),
        .o9_5_o(sel_index[9][5]), .o9_4_o(sel_index[9][4]), .o9_3_o(sel_index[9][3]), .o9_2_o(sel_index[9][2]), .o9_1_o(sel_index[9][1]), .o9_0_o(sel_index[9][0]),
        .o10_5_o(sel_index[10][5]), .o10_4_o(sel_index[10][4]), .o10_3_o(sel_index[10][3]), .o10_2_o(sel_index[10][2]), .o10_1_o(sel_index[10][1]), .o10_0_o(sel_index[10][0]),
        .o11_5_o(sel_index[11][5]), .o11_4_o(sel_index[11][4]), .o11_3_o(sel_index[11][3]), .o11_2_o(sel_index[11][2]), .o11_1_o(sel_index[11][1]), .o11_0_o(sel_index[11][0]),
        .o12_5_o(sel_index[12][5]), .o12_4_o(sel_index[12][4]), .o12_3_o(sel_index[12][3]), .o12_2_o(sel_index[12][2]), .o12_1_o(sel_index[12][1]), .o12_0_o(sel_index[12][0]),
        .o13_5_o(sel_index[13][5]), .o13_4_o(sel_index[13][4]), .o13_3_o(sel_index[13][3]), .o13_2_o(sel_index[13][2]), .o13_1_o(sel_index[13][1]), .o13_0_o(sel_index[13][0]),
        .o14_5_o(sel_index[14][5]), .o14_4_o(sel_index[14][4]), .o14_3_o(sel_index[14][3]), .o14_2_o(sel_index[14][2]), .o14_1_o(sel_index[14][1]), .o14_0_o(sel_index[14][0]),
        .o15_5_o(sel_index[15][5]), .o15_4_o(sel_index[15][4]), .o15_3_o(sel_index[15][3]), .o15_2_o(sel_index[15][2]), .o15_1_o(sel_index[15][1]), .o15_0_o(sel_index[15][0]),

        .i5_i(EIP[5]), .i4_i(EIP[4]), .i3_i(EIP[3]), .i2_i(EIP[2]), .i1_i(EIP[1]), .i0_i(EIP[0])
    );

    assign IR_valid_vect = {queue_valid[sel_index[15][5:4]], queue_valid[sel_index[14][5:4]], queue_valid[sel_index[13][5:4]], queue_valid[sel_index[12][5:4]],
                            queue_valid[sel_index[11][5:4]], queue_valid[sel_index[10][5:4]], queue_valid[sel_index[9][5:4]], queue_valid[sel_index[8][5:4]],
                            queue_valid[sel_index[7][5:4]], queue_valid[sel_index[6][5:4]], queue_valid[sel_index[5][5:4]], queue_valid[sel_index[4][5:4]],
                            queue_valid[sel_index[3][5:4]], queue_valid[sel_index[2][5:4]], queue_valid[sel_index[1][5:4]], queue_valid[sel_index[0][5:4]]};        



    genvar i;
    // generate
    //     for (i = 0; i < 16; i++) begin : ir_logic_adders
    //         kogge_stone_adder #(
    //             .WIDTH(6)
    //         ) IR_index_adder (
    //             .a   (EIP[5:0]),
    //             .b   (6'(i)),       // cast loop index to 6-bit
    //             .cin (1'b0),
    //             .sum (sel_index[i]),
    //             .cout(adder_cout[i])             // unused
    //         );
    //     end
    // endgenerate 

    generate
        for(i = 0; i < 16; i=i+1) begin : IR_sel_mux
            //mux64_8 sixtyfourmux(.in(queue), .sel(sel_index[i]), .out(IR[i]));
            `MUX_64(IR_sel_mux_inst, 8,
                IR[i],
                queue[0],  queue[1],  queue[2],  queue[3],
                queue[4],  queue[5],  queue[6],  queue[7],
                queue[8],  queue[9],  queue[10], queue[11],
                queue[12], queue[13], queue[14], queue[15],
                queue[16], queue[17], queue[18], queue[19],
                queue[20], queue[21], queue[22], queue[23],
                queue[24], queue[25], queue[26], queue[27],
                queue[28], queue[29], queue[30], queue[31],
                queue[32], queue[33], queue[34], queue[35],
                queue[36], queue[37], queue[38], queue[39],
                queue[40], queue[41], queue[42], queue[43],
                queue[44], queue[45], queue[46], queue[47],
                queue[48], queue[49], queue[50], queue[51],
                queue[52], queue[53], queue[54], queue[55],
                queue[56], queue[57], queue[58], queue[59],
                queue[60], queue[61], queue[62], queue[63],
                sel_index[i]
            )
        end
    endgenerate

endmodule
