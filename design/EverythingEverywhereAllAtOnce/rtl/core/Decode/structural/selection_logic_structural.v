module selection_logic (
    input  [511:0] queue,
    input  [31:0]  EIP,
    output [127:0] IR
);

    // Buffered queue: each byte fans out to 16 tristates.
    wire [511:0] queue_buffered;

    // Pre-buffer IR (driven by tristates), then a bufferH64$ per bit drives the output port.
    wire [127:0] IR_pre;

    // ROM enables (active-low enbar): rom_out[i][k] = 0 enables routing of
    // queue[i] -> IR[k].
    wire [15:0] rom_out [0:63];

    ir_vector_roms ir_gates (
        .input5_i(EIP[5]), .input4_i(EIP[4]), .input3_i(EIP[3]),
        .input2_i(EIP[2]), .input1_i(EIP[1]), .input0_i(EIP[0]),
        .o0_0_o(rom_out[0][0]), .o0_1_o(rom_out[0][1]), .o0_2_o(rom_out[0][2]), .o0_3_o(rom_out[0][3]), .o0_4_o(rom_out[0][4]), .o0_5_o(rom_out[0][5]), .o0_6_o(rom_out[0][6]), .o0_7_o(rom_out[0][7]), .o0_8_o(rom_out[0][8]), .o0_9_o(rom_out[0][9]), .o0_10_o(rom_out[0][10]), .o0_11_o(rom_out[0][11]), .o0_12_o(rom_out[0][12]), .o0_13_o(rom_out[0][13]), .o0_14_o(rom_out[0][14]), .o0_15_o(rom_out[0][15]),
        .o1_0_o(rom_out[1][0]), .o1_1_o(rom_out[1][1]), .o1_2_o(rom_out[1][2]), .o1_3_o(rom_out[1][3]), .o1_4_o(rom_out[1][4]), .o1_5_o(rom_out[1][5]), .o1_6_o(rom_out[1][6]), .o1_7_o(rom_out[1][7]), .o1_8_o(rom_out[1][8]), .o1_9_o(rom_out[1][9]), .o1_10_o(rom_out[1][10]), .o1_11_o(rom_out[1][11]), .o1_12_o(rom_out[1][12]), .o1_13_o(rom_out[1][13]), .o1_14_o(rom_out[1][14]), .o1_15_o(rom_out[1][15]),
        .o2_0_o(rom_out[2][0]), .o2_1_o(rom_out[2][1]), .o2_2_o(rom_out[2][2]), .o2_3_o(rom_out[2][3]), .o2_4_o(rom_out[2][4]), .o2_5_o(rom_out[2][5]), .o2_6_o(rom_out[2][6]), .o2_7_o(rom_out[2][7]), .o2_8_o(rom_out[2][8]), .o2_9_o(rom_out[2][9]), .o2_10_o(rom_out[2][10]), .o2_11_o(rom_out[2][11]), .o2_12_o(rom_out[2][12]), .o2_13_o(rom_out[2][13]), .o2_14_o(rom_out[2][14]), .o2_15_o(rom_out[2][15]),
        .o3_0_o(rom_out[3][0]), .o3_1_o(rom_out[3][1]), .o3_2_o(rom_out[3][2]), .o3_3_o(rom_out[3][3]), .o3_4_o(rom_out[3][4]), .o3_5_o(rom_out[3][5]), .o3_6_o(rom_out[3][6]), .o3_7_o(rom_out[3][7]), .o3_8_o(rom_out[3][8]), .o3_9_o(rom_out[3][9]), .o3_10_o(rom_out[3][10]), .o3_11_o(rom_out[3][11]), .o3_12_o(rom_out[3][12]), .o3_13_o(rom_out[3][13]), .o3_14_o(rom_out[3][14]), .o3_15_o(rom_out[3][15]),
        .o4_0_o(rom_out[4][0]), .o4_1_o(rom_out[4][1]), .o4_2_o(rom_out[4][2]), .o4_3_o(rom_out[4][3]), .o4_4_o(rom_out[4][4]), .o4_5_o(rom_out[4][5]), .o4_6_o(rom_out[4][6]), .o4_7_o(rom_out[4][7]), .o4_8_o(rom_out[4][8]), .o4_9_o(rom_out[4][9]), .o4_10_o(rom_out[4][10]), .o4_11_o(rom_out[4][11]), .o4_12_o(rom_out[4][12]), .o4_13_o(rom_out[4][13]), .o4_14_o(rom_out[4][14]), .o4_15_o(rom_out[4][15]),
        .o5_0_o(rom_out[5][0]), .o5_1_o(rom_out[5][1]), .o5_2_o(rom_out[5][2]), .o5_3_o(rom_out[5][3]), .o5_4_o(rom_out[5][4]), .o5_5_o(rom_out[5][5]), .o5_6_o(rom_out[5][6]), .o5_7_o(rom_out[5][7]), .o5_8_o(rom_out[5][8]), .o5_9_o(rom_out[5][9]), .o5_10_o(rom_out[5][10]), .o5_11_o(rom_out[5][11]), .o5_12_o(rom_out[5][12]), .o5_13_o(rom_out[5][13]), .o5_14_o(rom_out[5][14]), .o5_15_o(rom_out[5][15]),
        .o6_0_o(rom_out[6][0]), .o6_1_o(rom_out[6][1]), .o6_2_o(rom_out[6][2]), .o6_3_o(rom_out[6][3]), .o6_4_o(rom_out[6][4]), .o6_5_o(rom_out[6][5]), .o6_6_o(rom_out[6][6]), .o6_7_o(rom_out[6][7]), .o6_8_o(rom_out[6][8]), .o6_9_o(rom_out[6][9]), .o6_10_o(rom_out[6][10]), .o6_11_o(rom_out[6][11]), .o6_12_o(rom_out[6][12]), .o6_13_o(rom_out[6][13]), .o6_14_o(rom_out[6][14]), .o6_15_o(rom_out[6][15]),
        .o7_0_o(rom_out[7][0]), .o7_1_o(rom_out[7][1]), .o7_2_o(rom_out[7][2]), .o7_3_o(rom_out[7][3]), .o7_4_o(rom_out[7][4]), .o7_5_o(rom_out[7][5]), .o7_6_o(rom_out[7][6]), .o7_7_o(rom_out[7][7]), .o7_8_o(rom_out[7][8]), .o7_9_o(rom_out[7][9]), .o7_10_o(rom_out[7][10]), .o7_11_o(rom_out[7][11]), .o7_12_o(rom_out[7][12]), .o7_13_o(rom_out[7][13]), .o7_14_o(rom_out[7][14]), .o7_15_o(rom_out[7][15]),
        .o8_0_o(rom_out[8][0]), .o8_1_o(rom_out[8][1]), .o8_2_o(rom_out[8][2]), .o8_3_o(rom_out[8][3]), .o8_4_o(rom_out[8][4]), .o8_5_o(rom_out[8][5]), .o8_6_o(rom_out[8][6]), .o8_7_o(rom_out[8][7]), .o8_8_o(rom_out[8][8]), .o8_9_o(rom_out[8][9]), .o8_10_o(rom_out[8][10]), .o8_11_o(rom_out[8][11]), .o8_12_o(rom_out[8][12]), .o8_13_o(rom_out[8][13]), .o8_14_o(rom_out[8][14]), .o8_15_o(rom_out[8][15]),
        .o9_0_o(rom_out[9][0]), .o9_1_o(rom_out[9][1]), .o9_2_o(rom_out[9][2]), .o9_3_o(rom_out[9][3]), .o9_4_o(rom_out[9][4]), .o9_5_o(rom_out[9][5]), .o9_6_o(rom_out[9][6]), .o9_7_o(rom_out[9][7]), .o9_8_o(rom_out[9][8]), .o9_9_o(rom_out[9][9]), .o9_10_o(rom_out[9][10]), .o9_11_o(rom_out[9][11]), .o9_12_o(rom_out[9][12]), .o9_13_o(rom_out[9][13]), .o9_14_o(rom_out[9][14]), .o9_15_o(rom_out[9][15]),
        .o10_0_o(rom_out[10][0]), .o10_1_o(rom_out[10][1]), .o10_2_o(rom_out[10][2]), .o10_3_o(rom_out[10][3]), .o10_4_o(rom_out[10][4]), .o10_5_o(rom_out[10][5]), .o10_6_o(rom_out[10][6]), .o10_7_o(rom_out[10][7]), .o10_8_o(rom_out[10][8]), .o10_9_o(rom_out[10][9]), .o10_10_o(rom_out[10][10]), .o10_11_o(rom_out[10][11]), .o10_12_o(rom_out[10][12]), .o10_13_o(rom_out[10][13]), .o10_14_o(rom_out[10][14]), .o10_15_o(rom_out[10][15]),
        .o11_0_o(rom_out[11][0]), .o11_1_o(rom_out[11][1]), .o11_2_o(rom_out[11][2]), .o11_3_o(rom_out[11][3]), .o11_4_o(rom_out[11][4]), .o11_5_o(rom_out[11][5]), .o11_6_o(rom_out[11][6]), .o11_7_o(rom_out[11][7]), .o11_8_o(rom_out[11][8]), .o11_9_o(rom_out[11][9]), .o11_10_o(rom_out[11][10]), .o11_11_o(rom_out[11][11]), .o11_12_o(rom_out[11][12]), .o11_13_o(rom_out[11][13]), .o11_14_o(rom_out[11][14]), .o11_15_o(rom_out[11][15]),
        .o12_0_o(rom_out[12][0]), .o12_1_o(rom_out[12][1]), .o12_2_o(rom_out[12][2]), .o12_3_o(rom_out[12][3]), .o12_4_o(rom_out[12][4]), .o12_5_o(rom_out[12][5]), .o12_6_o(rom_out[12][6]), .o12_7_o(rom_out[12][7]), .o12_8_o(rom_out[12][8]), .o12_9_o(rom_out[12][9]), .o12_10_o(rom_out[12][10]), .o12_11_o(rom_out[12][11]), .o12_12_o(rom_out[12][12]), .o12_13_o(rom_out[12][13]), .o12_14_o(rom_out[12][14]), .o12_15_o(rom_out[12][15]),
        .o13_0_o(rom_out[13][0]), .o13_1_o(rom_out[13][1]), .o13_2_o(rom_out[13][2]), .o13_3_o(rom_out[13][3]), .o13_4_o(rom_out[13][4]), .o13_5_o(rom_out[13][5]), .o13_6_o(rom_out[13][6]), .o13_7_o(rom_out[13][7]), .o13_8_o(rom_out[13][8]), .o13_9_o(rom_out[13][9]), .o13_10_o(rom_out[13][10]), .o13_11_o(rom_out[13][11]), .o13_12_o(rom_out[13][12]), .o13_13_o(rom_out[13][13]), .o13_14_o(rom_out[13][14]), .o13_15_o(rom_out[13][15]),
        .o14_0_o(rom_out[14][0]), .o14_1_o(rom_out[14][1]), .o14_2_o(rom_out[14][2]), .o14_3_o(rom_out[14][3]), .o14_4_o(rom_out[14][4]), .o14_5_o(rom_out[14][5]), .o14_6_o(rom_out[14][6]), .o14_7_o(rom_out[14][7]), .o14_8_o(rom_out[14][8]), .o14_9_o(rom_out[14][9]), .o14_10_o(rom_out[14][10]), .o14_11_o(rom_out[14][11]), .o14_12_o(rom_out[14][12]), .o14_13_o(rom_out[14][13]), .o14_14_o(rom_out[14][14]), .o14_15_o(rom_out[14][15]),
        .o15_0_o(rom_out[15][0]), .o15_1_o(rom_out[15][1]), .o15_2_o(rom_out[15][2]), .o15_3_o(rom_out[15][3]), .o15_4_o(rom_out[15][4]), .o15_5_o(rom_out[15][5]), .o15_6_o(rom_out[15][6]), .o15_7_o(rom_out[15][7]), .o15_8_o(rom_out[15][8]), .o15_9_o(rom_out[15][9]), .o15_10_o(rom_out[15][10]), .o15_11_o(rom_out[15][11]), .o15_12_o(rom_out[15][12]), .o15_13_o(rom_out[15][13]), .o15_14_o(rom_out[15][14]), .o15_15_o(rom_out[15][15]),
        .o16_0_o(rom_out[16][0]), .o16_1_o(rom_out[16][1]), .o16_2_o(rom_out[16][2]), .o16_3_o(rom_out[16][3]), .o16_4_o(rom_out[16][4]), .o16_5_o(rom_out[16][5]), .o16_6_o(rom_out[16][6]), .o16_7_o(rom_out[16][7]), .o16_8_o(rom_out[16][8]), .o16_9_o(rom_out[16][9]), .o16_10_o(rom_out[16][10]), .o16_11_o(rom_out[16][11]), .o16_12_o(rom_out[16][12]), .o16_13_o(rom_out[16][13]), .o16_14_o(rom_out[16][14]), .o16_15_o(rom_out[16][15]),
        .o17_0_o(rom_out[17][0]), .o17_1_o(rom_out[17][1]), .o17_2_o(rom_out[17][2]), .o17_3_o(rom_out[17][3]), .o17_4_o(rom_out[17][4]), .o17_5_o(rom_out[17][5]), .o17_6_o(rom_out[17][6]), .o17_7_o(rom_out[17][7]), .o17_8_o(rom_out[17][8]), .o17_9_o(rom_out[17][9]), .o17_10_o(rom_out[17][10]), .o17_11_o(rom_out[17][11]), .o17_12_o(rom_out[17][12]), .o17_13_o(rom_out[17][13]), .o17_14_o(rom_out[17][14]), .o17_15_o(rom_out[17][15]),
        .o18_0_o(rom_out[18][0]), .o18_1_o(rom_out[18][1]), .o18_2_o(rom_out[18][2]), .o18_3_o(rom_out[18][3]), .o18_4_o(rom_out[18][4]), .o18_5_o(rom_out[18][5]), .o18_6_o(rom_out[18][6]), .o18_7_o(rom_out[18][7]), .o18_8_o(rom_out[18][8]), .o18_9_o(rom_out[18][9]), .o18_10_o(rom_out[18][10]), .o18_11_o(rom_out[18][11]), .o18_12_o(rom_out[18][12]), .o18_13_o(rom_out[18][13]), .o18_14_o(rom_out[18][14]), .o18_15_o(rom_out[18][15]),
        .o19_0_o(rom_out[19][0]), .o19_1_o(rom_out[19][1]), .o19_2_o(rom_out[19][2]), .o19_3_o(rom_out[19][3]), .o19_4_o(rom_out[19][4]), .o19_5_o(rom_out[19][5]), .o19_6_o(rom_out[19][6]), .o19_7_o(rom_out[19][7]), .o19_8_o(rom_out[19][8]), .o19_9_o(rom_out[19][9]), .o19_10_o(rom_out[19][10]), .o19_11_o(rom_out[19][11]), .o19_12_o(rom_out[19][12]), .o19_13_o(rom_out[19][13]), .o19_14_o(rom_out[19][14]), .o19_15_o(rom_out[19][15]),
        .o20_0_o(rom_out[20][0]), .o20_1_o(rom_out[20][1]), .o20_2_o(rom_out[20][2]), .o20_3_o(rom_out[20][3]), .o20_4_o(rom_out[20][4]), .o20_5_o(rom_out[20][5]), .o20_6_o(rom_out[20][6]), .o20_7_o(rom_out[20][7]), .o20_8_o(rom_out[20][8]), .o20_9_o(rom_out[20][9]), .o20_10_o(rom_out[20][10]), .o20_11_o(rom_out[20][11]), .o20_12_o(rom_out[20][12]), .o20_13_o(rom_out[20][13]), .o20_14_o(rom_out[20][14]), .o20_15_o(rom_out[20][15]),
        .o21_0_o(rom_out[21][0]), .o21_1_o(rom_out[21][1]), .o21_2_o(rom_out[21][2]), .o21_3_o(rom_out[21][3]), .o21_4_o(rom_out[21][4]), .o21_5_o(rom_out[21][5]), .o21_6_o(rom_out[21][6]), .o21_7_o(rom_out[21][7]), .o21_8_o(rom_out[21][8]), .o21_9_o(rom_out[21][9]), .o21_10_o(rom_out[21][10]), .o21_11_o(rom_out[21][11]), .o21_12_o(rom_out[21][12]), .o21_13_o(rom_out[21][13]), .o21_14_o(rom_out[21][14]), .o21_15_o(rom_out[21][15]),
        .o22_0_o(rom_out[22][0]), .o22_1_o(rom_out[22][1]), .o22_2_o(rom_out[22][2]), .o22_3_o(rom_out[22][3]), .o22_4_o(rom_out[22][4]), .o22_5_o(rom_out[22][5]), .o22_6_o(rom_out[22][6]), .o22_7_o(rom_out[22][7]), .o22_8_o(rom_out[22][8]), .o22_9_o(rom_out[22][9]), .o22_10_o(rom_out[22][10]), .o22_11_o(rom_out[22][11]), .o22_12_o(rom_out[22][12]), .o22_13_o(rom_out[22][13]), .o22_14_o(rom_out[22][14]), .o22_15_o(rom_out[22][15]),
        .o23_0_o(rom_out[23][0]), .o23_1_o(rom_out[23][1]), .o23_2_o(rom_out[23][2]), .o23_3_o(rom_out[23][3]), .o23_4_o(rom_out[23][4]), .o23_5_o(rom_out[23][5]), .o23_6_o(rom_out[23][6]), .o23_7_o(rom_out[23][7]), .o23_8_o(rom_out[23][8]), .o23_9_o(rom_out[23][9]), .o23_10_o(rom_out[23][10]), .o23_11_o(rom_out[23][11]), .o23_12_o(rom_out[23][12]), .o23_13_o(rom_out[23][13]), .o23_14_o(rom_out[23][14]), .o23_15_o(rom_out[23][15]),
        .o24_0_o(rom_out[24][0]), .o24_1_o(rom_out[24][1]), .o24_2_o(rom_out[24][2]), .o24_3_o(rom_out[24][3]), .o24_4_o(rom_out[24][4]), .o24_5_o(rom_out[24][5]), .o24_6_o(rom_out[24][6]), .o24_7_o(rom_out[24][7]), .o24_8_o(rom_out[24][8]), .o24_9_o(rom_out[24][9]), .o24_10_o(rom_out[24][10]), .o24_11_o(rom_out[24][11]), .o24_12_o(rom_out[24][12]), .o24_13_o(rom_out[24][13]), .o24_14_o(rom_out[24][14]), .o24_15_o(rom_out[24][15]),
        .o25_0_o(rom_out[25][0]), .o25_1_o(rom_out[25][1]), .o25_2_o(rom_out[25][2]), .o25_3_o(rom_out[25][3]), .o25_4_o(rom_out[25][4]), .o25_5_o(rom_out[25][5]), .o25_6_o(rom_out[25][6]), .o25_7_o(rom_out[25][7]), .o25_8_o(rom_out[25][8]), .o25_9_o(rom_out[25][9]), .o25_10_o(rom_out[25][10]), .o25_11_o(rom_out[25][11]), .o25_12_o(rom_out[25][12]), .o25_13_o(rom_out[25][13]), .o25_14_o(rom_out[25][14]), .o25_15_o(rom_out[25][15]),
        .o26_0_o(rom_out[26][0]), .o26_1_o(rom_out[26][1]), .o26_2_o(rom_out[26][2]), .o26_3_o(rom_out[26][3]), .o26_4_o(rom_out[26][4]), .o26_5_o(rom_out[26][5]), .o26_6_o(rom_out[26][6]), .o26_7_o(rom_out[26][7]), .o26_8_o(rom_out[26][8]), .o26_9_o(rom_out[26][9]), .o26_10_o(rom_out[26][10]), .o26_11_o(rom_out[26][11]), .o26_12_o(rom_out[26][12]), .o26_13_o(rom_out[26][13]), .o26_14_o(rom_out[26][14]), .o26_15_o(rom_out[26][15]),
        .o27_0_o(rom_out[27][0]), .o27_1_o(rom_out[27][1]), .o27_2_o(rom_out[27][2]), .o27_3_o(rom_out[27][3]), .o27_4_o(rom_out[27][4]), .o27_5_o(rom_out[27][5]), .o27_6_o(rom_out[27][6]), .o27_7_o(rom_out[27][7]), .o27_8_o(rom_out[27][8]), .o27_9_o(rom_out[27][9]), .o27_10_o(rom_out[27][10]), .o27_11_o(rom_out[27][11]), .o27_12_o(rom_out[27][12]), .o27_13_o(rom_out[27][13]), .o27_14_o(rom_out[27][14]), .o27_15_o(rom_out[27][15]),
        .o28_0_o(rom_out[28][0]), .o28_1_o(rom_out[28][1]), .o28_2_o(rom_out[28][2]), .o28_3_o(rom_out[28][3]), .o28_4_o(rom_out[28][4]), .o28_5_o(rom_out[28][5]), .o28_6_o(rom_out[28][6]), .o28_7_o(rom_out[28][7]), .o28_8_o(rom_out[28][8]), .o28_9_o(rom_out[28][9]), .o28_10_o(rom_out[28][10]), .o28_11_o(rom_out[28][11]), .o28_12_o(rom_out[28][12]), .o28_13_o(rom_out[28][13]), .o28_14_o(rom_out[28][14]), .o28_15_o(rom_out[28][15]),
        .o29_0_o(rom_out[29][0]), .o29_1_o(rom_out[29][1]), .o29_2_o(rom_out[29][2]), .o29_3_o(rom_out[29][3]), .o29_4_o(rom_out[29][4]), .o29_5_o(rom_out[29][5]), .o29_6_o(rom_out[29][6]), .o29_7_o(rom_out[29][7]), .o29_8_o(rom_out[29][8]), .o29_9_o(rom_out[29][9]), .o29_10_o(rom_out[29][10]), .o29_11_o(rom_out[29][11]), .o29_12_o(rom_out[29][12]), .o29_13_o(rom_out[29][13]), .o29_14_o(rom_out[29][14]), .o29_15_o(rom_out[29][15]),
        .o30_0_o(rom_out[30][0]), .o30_1_o(rom_out[30][1]), .o30_2_o(rom_out[30][2]), .o30_3_o(rom_out[30][3]), .o30_4_o(rom_out[30][4]), .o30_5_o(rom_out[30][5]), .o30_6_o(rom_out[30][6]), .o30_7_o(rom_out[30][7]), .o30_8_o(rom_out[30][8]), .o30_9_o(rom_out[30][9]), .o30_10_o(rom_out[30][10]), .o30_11_o(rom_out[30][11]), .o30_12_o(rom_out[30][12]), .o30_13_o(rom_out[30][13]), .o30_14_o(rom_out[30][14]), .o30_15_o(rom_out[30][15]),
        .o31_0_o(rom_out[31][0]), .o31_1_o(rom_out[31][1]), .o31_2_o(rom_out[31][2]), .o31_3_o(rom_out[31][3]), .o31_4_o(rom_out[31][4]), .o31_5_o(rom_out[31][5]), .o31_6_o(rom_out[31][6]), .o31_7_o(rom_out[31][7]), .o31_8_o(rom_out[31][8]), .o31_9_o(rom_out[31][9]), .o31_10_o(rom_out[31][10]), .o31_11_o(rom_out[31][11]), .o31_12_o(rom_out[31][12]), .o31_13_o(rom_out[31][13]), .o31_14_o(rom_out[31][14]), .o31_15_o(rom_out[31][15]),
        .o32_0_o(rom_out[32][0]), .o32_1_o(rom_out[32][1]), .o32_2_o(rom_out[32][2]), .o32_3_o(rom_out[32][3]), .o32_4_o(rom_out[32][4]), .o32_5_o(rom_out[32][5]), .o32_6_o(rom_out[32][6]), .o32_7_o(rom_out[32][7]), .o32_8_o(rom_out[32][8]), .o32_9_o(rom_out[32][9]), .o32_10_o(rom_out[32][10]), .o32_11_o(rom_out[32][11]), .o32_12_o(rom_out[32][12]), .o32_13_o(rom_out[32][13]), .o32_14_o(rom_out[32][14]), .o32_15_o(rom_out[32][15]),
        .o33_0_o(rom_out[33][0]), .o33_1_o(rom_out[33][1]), .o33_2_o(rom_out[33][2]), .o33_3_o(rom_out[33][3]), .o33_4_o(rom_out[33][4]), .o33_5_o(rom_out[33][5]), .o33_6_o(rom_out[33][6]), .o33_7_o(rom_out[33][7]), .o33_8_o(rom_out[33][8]), .o33_9_o(rom_out[33][9]), .o33_10_o(rom_out[33][10]), .o33_11_o(rom_out[33][11]), .o33_12_o(rom_out[33][12]), .o33_13_o(rom_out[33][13]), .o33_14_o(rom_out[33][14]), .o33_15_o(rom_out[33][15]),
        .o34_0_o(rom_out[34][0]), .o34_1_o(rom_out[34][1]), .o34_2_o(rom_out[34][2]), .o34_3_o(rom_out[34][3]), .o34_4_o(rom_out[34][4]), .o34_5_o(rom_out[34][5]), .o34_6_o(rom_out[34][6]), .o34_7_o(rom_out[34][7]), .o34_8_o(rom_out[34][8]), .o34_9_o(rom_out[34][9]), .o34_10_o(rom_out[34][10]), .o34_11_o(rom_out[34][11]), .o34_12_o(rom_out[34][12]), .o34_13_o(rom_out[34][13]), .o34_14_o(rom_out[34][14]), .o34_15_o(rom_out[34][15]),
        .o35_0_o(rom_out[35][0]), .o35_1_o(rom_out[35][1]), .o35_2_o(rom_out[35][2]), .o35_3_o(rom_out[35][3]), .o35_4_o(rom_out[35][4]), .o35_5_o(rom_out[35][5]), .o35_6_o(rom_out[35][6]), .o35_7_o(rom_out[35][7]), .o35_8_o(rom_out[35][8]), .o35_9_o(rom_out[35][9]), .o35_10_o(rom_out[35][10]), .o35_11_o(rom_out[35][11]), .o35_12_o(rom_out[35][12]), .o35_13_o(rom_out[35][13]), .o35_14_o(rom_out[35][14]), .o35_15_o(rom_out[35][15]),
        .o36_0_o(rom_out[36][0]), .o36_1_o(rom_out[36][1]), .o36_2_o(rom_out[36][2]), .o36_3_o(rom_out[36][3]), .o36_4_o(rom_out[36][4]), .o36_5_o(rom_out[36][5]), .o36_6_o(rom_out[36][6]), .o36_7_o(rom_out[36][7]), .o36_8_o(rom_out[36][8]), .o36_9_o(rom_out[36][9]), .o36_10_o(rom_out[36][10]), .o36_11_o(rom_out[36][11]), .o36_12_o(rom_out[36][12]), .o36_13_o(rom_out[36][13]), .o36_14_o(rom_out[36][14]), .o36_15_o(rom_out[36][15]),
        .o37_0_o(rom_out[37][0]), .o37_1_o(rom_out[37][1]), .o37_2_o(rom_out[37][2]), .o37_3_o(rom_out[37][3]), .o37_4_o(rom_out[37][4]), .o37_5_o(rom_out[37][5]), .o37_6_o(rom_out[37][6]), .o37_7_o(rom_out[37][7]), .o37_8_o(rom_out[37][8]), .o37_9_o(rom_out[37][9]), .o37_10_o(rom_out[37][10]), .o37_11_o(rom_out[37][11]), .o37_12_o(rom_out[37][12]), .o37_13_o(rom_out[37][13]), .o37_14_o(rom_out[37][14]), .o37_15_o(rom_out[37][15]),
        .o38_0_o(rom_out[38][0]), .o38_1_o(rom_out[38][1]), .o38_2_o(rom_out[38][2]), .o38_3_o(rom_out[38][3]), .o38_4_o(rom_out[38][4]), .o38_5_o(rom_out[38][5]), .o38_6_o(rom_out[38][6]), .o38_7_o(rom_out[38][7]), .o38_8_o(rom_out[38][8]), .o38_9_o(rom_out[38][9]), .o38_10_o(rom_out[38][10]), .o38_11_o(rom_out[38][11]), .o38_12_o(rom_out[38][12]), .o38_13_o(rom_out[38][13]), .o38_14_o(rom_out[38][14]), .o38_15_o(rom_out[38][15]),
        .o39_0_o(rom_out[39][0]), .o39_1_o(rom_out[39][1]), .o39_2_o(rom_out[39][2]), .o39_3_o(rom_out[39][3]), .o39_4_o(rom_out[39][4]), .o39_5_o(rom_out[39][5]), .o39_6_o(rom_out[39][6]), .o39_7_o(rom_out[39][7]), .o39_8_o(rom_out[39][8]), .o39_9_o(rom_out[39][9]), .o39_10_o(rom_out[39][10]), .o39_11_o(rom_out[39][11]), .o39_12_o(rom_out[39][12]), .o39_13_o(rom_out[39][13]), .o39_14_o(rom_out[39][14]), .o39_15_o(rom_out[39][15]),
        .o40_0_o(rom_out[40][0]), .o40_1_o(rom_out[40][1]), .o40_2_o(rom_out[40][2]), .o40_3_o(rom_out[40][3]), .o40_4_o(rom_out[40][4]), .o40_5_o(rom_out[40][5]), .o40_6_o(rom_out[40][6]), .o40_7_o(rom_out[40][7]), .o40_8_o(rom_out[40][8]), .o40_9_o(rom_out[40][9]), .o40_10_o(rom_out[40][10]), .o40_11_o(rom_out[40][11]), .o40_12_o(rom_out[40][12]), .o40_13_o(rom_out[40][13]), .o40_14_o(rom_out[40][14]), .o40_15_o(rom_out[40][15]),
        .o41_0_o(rom_out[41][0]), .o41_1_o(rom_out[41][1]), .o41_2_o(rom_out[41][2]), .o41_3_o(rom_out[41][3]), .o41_4_o(rom_out[41][4]), .o41_5_o(rom_out[41][5]), .o41_6_o(rom_out[41][6]), .o41_7_o(rom_out[41][7]), .o41_8_o(rom_out[41][8]), .o41_9_o(rom_out[41][9]), .o41_10_o(rom_out[41][10]), .o41_11_o(rom_out[41][11]), .o41_12_o(rom_out[41][12]), .o41_13_o(rom_out[41][13]), .o41_14_o(rom_out[41][14]), .o41_15_o(rom_out[41][15]),
        .o42_0_o(rom_out[42][0]), .o42_1_o(rom_out[42][1]), .o42_2_o(rom_out[42][2]), .o42_3_o(rom_out[42][3]), .o42_4_o(rom_out[42][4]), .o42_5_o(rom_out[42][5]), .o42_6_o(rom_out[42][6]), .o42_7_o(rom_out[42][7]), .o42_8_o(rom_out[42][8]), .o42_9_o(rom_out[42][9]), .o42_10_o(rom_out[42][10]), .o42_11_o(rom_out[42][11]), .o42_12_o(rom_out[42][12]), .o42_13_o(rom_out[42][13]), .o42_14_o(rom_out[42][14]), .o42_15_o(rom_out[42][15]),
        .o43_0_o(rom_out[43][0]), .o43_1_o(rom_out[43][1]), .o43_2_o(rom_out[43][2]), .o43_3_o(rom_out[43][3]), .o43_4_o(rom_out[43][4]), .o43_5_o(rom_out[43][5]), .o43_6_o(rom_out[43][6]), .o43_7_o(rom_out[43][7]), .o43_8_o(rom_out[43][8]), .o43_9_o(rom_out[43][9]), .o43_10_o(rom_out[43][10]), .o43_11_o(rom_out[43][11]), .o43_12_o(rom_out[43][12]), .o43_13_o(rom_out[43][13]), .o43_14_o(rom_out[43][14]), .o43_15_o(rom_out[43][15]),
        .o44_0_o(rom_out[44][0]), .o44_1_o(rom_out[44][1]), .o44_2_o(rom_out[44][2]), .o44_3_o(rom_out[44][3]), .o44_4_o(rom_out[44][4]), .o44_5_o(rom_out[44][5]), .o44_6_o(rom_out[44][6]), .o44_7_o(rom_out[44][7]), .o44_8_o(rom_out[44][8]), .o44_9_o(rom_out[44][9]), .o44_10_o(rom_out[44][10]), .o44_11_o(rom_out[44][11]), .o44_12_o(rom_out[44][12]), .o44_13_o(rom_out[44][13]), .o44_14_o(rom_out[44][14]), .o44_15_o(rom_out[44][15]),
        .o45_0_o(rom_out[45][0]), .o45_1_o(rom_out[45][1]), .o45_2_o(rom_out[45][2]), .o45_3_o(rom_out[45][3]), .o45_4_o(rom_out[45][4]), .o45_5_o(rom_out[45][5]), .o45_6_o(rom_out[45][6]), .o45_7_o(rom_out[45][7]), .o45_8_o(rom_out[45][8]), .o45_9_o(rom_out[45][9]), .o45_10_o(rom_out[45][10]), .o45_11_o(rom_out[45][11]), .o45_12_o(rom_out[45][12]), .o45_13_o(rom_out[45][13]), .o45_14_o(rom_out[45][14]), .o45_15_o(rom_out[45][15]),
        .o46_0_o(rom_out[46][0]), .o46_1_o(rom_out[46][1]), .o46_2_o(rom_out[46][2]), .o46_3_o(rom_out[46][3]), .o46_4_o(rom_out[46][4]), .o46_5_o(rom_out[46][5]), .o46_6_o(rom_out[46][6]), .o46_7_o(rom_out[46][7]), .o46_8_o(rom_out[46][8]), .o46_9_o(rom_out[46][9]), .o46_10_o(rom_out[46][10]), .o46_11_o(rom_out[46][11]), .o46_12_o(rom_out[46][12]), .o46_13_o(rom_out[46][13]), .o46_14_o(rom_out[46][14]), .o46_15_o(rom_out[46][15]),
        .o47_0_o(rom_out[47][0]), .o47_1_o(rom_out[47][1]), .o47_2_o(rom_out[47][2]), .o47_3_o(rom_out[47][3]), .o47_4_o(rom_out[47][4]), .o47_5_o(rom_out[47][5]), .o47_6_o(rom_out[47][6]), .o47_7_o(rom_out[47][7]), .o47_8_o(rom_out[47][8]), .o47_9_o(rom_out[47][9]), .o47_10_o(rom_out[47][10]), .o47_11_o(rom_out[47][11]), .o47_12_o(rom_out[47][12]), .o47_13_o(rom_out[47][13]), .o47_14_o(rom_out[47][14]), .o47_15_o(rom_out[47][15]),
        .o48_0_o(rom_out[48][0]), .o48_1_o(rom_out[48][1]), .o48_2_o(rom_out[48][2]), .o48_3_o(rom_out[48][3]), .o48_4_o(rom_out[48][4]), .o48_5_o(rom_out[48][5]), .o48_6_o(rom_out[48][6]), .o48_7_o(rom_out[48][7]), .o48_8_o(rom_out[48][8]), .o48_9_o(rom_out[48][9]), .o48_10_o(rom_out[48][10]), .o48_11_o(rom_out[48][11]), .o48_12_o(rom_out[48][12]), .o48_13_o(rom_out[48][13]), .o48_14_o(rom_out[48][14]), .o48_15_o(rom_out[48][15]),
        .o49_0_o(rom_out[49][0]), .o49_1_o(rom_out[49][1]), .o49_2_o(rom_out[49][2]), .o49_3_o(rom_out[49][3]), .o49_4_o(rom_out[49][4]), .o49_5_o(rom_out[49][5]), .o49_6_o(rom_out[49][6]), .o49_7_o(rom_out[49][7]), .o49_8_o(rom_out[49][8]), .o49_9_o(rom_out[49][9]), .o49_10_o(rom_out[49][10]), .o49_11_o(rom_out[49][11]), .o49_12_o(rom_out[49][12]), .o49_13_o(rom_out[49][13]), .o49_14_o(rom_out[49][14]), .o49_15_o(rom_out[49][15]),
        .o50_0_o(rom_out[50][0]), .o50_1_o(rom_out[50][1]), .o50_2_o(rom_out[50][2]), .o50_3_o(rom_out[50][3]), .o50_4_o(rom_out[50][4]), .o50_5_o(rom_out[50][5]), .o50_6_o(rom_out[50][6]), .o50_7_o(rom_out[50][7]), .o50_8_o(rom_out[50][8]), .o50_9_o(rom_out[50][9]), .o50_10_o(rom_out[50][10]), .o50_11_o(rom_out[50][11]), .o50_12_o(rom_out[50][12]), .o50_13_o(rom_out[50][13]), .o50_14_o(rom_out[50][14]), .o50_15_o(rom_out[50][15]),
        .o51_0_o(rom_out[51][0]), .o51_1_o(rom_out[51][1]), .o51_2_o(rom_out[51][2]), .o51_3_o(rom_out[51][3]), .o51_4_o(rom_out[51][4]), .o51_5_o(rom_out[51][5]), .o51_6_o(rom_out[51][6]), .o51_7_o(rom_out[51][7]), .o51_8_o(rom_out[51][8]), .o51_9_o(rom_out[51][9]), .o51_10_o(rom_out[51][10]), .o51_11_o(rom_out[51][11]), .o51_12_o(rom_out[51][12]), .o51_13_o(rom_out[51][13]), .o51_14_o(rom_out[51][14]), .o51_15_o(rom_out[51][15]),
        .o52_0_o(rom_out[52][0]), .o52_1_o(rom_out[52][1]), .o52_2_o(rom_out[52][2]), .o52_3_o(rom_out[52][3]), .o52_4_o(rom_out[52][4]), .o52_5_o(rom_out[52][5]), .o52_6_o(rom_out[52][6]), .o52_7_o(rom_out[52][7]), .o52_8_o(rom_out[52][8]), .o52_9_o(rom_out[52][9]), .o52_10_o(rom_out[52][10]), .o52_11_o(rom_out[52][11]), .o52_12_o(rom_out[52][12]), .o52_13_o(rom_out[52][13]), .o52_14_o(rom_out[52][14]), .o52_15_o(rom_out[52][15]),
        .o53_0_o(rom_out[53][0]), .o53_1_o(rom_out[53][1]), .o53_2_o(rom_out[53][2]), .o53_3_o(rom_out[53][3]), .o53_4_o(rom_out[53][4]), .o53_5_o(rom_out[53][5]), .o53_6_o(rom_out[53][6]), .o53_7_o(rom_out[53][7]), .o53_8_o(rom_out[53][8]), .o53_9_o(rom_out[53][9]), .o53_10_o(rom_out[53][10]), .o53_11_o(rom_out[53][11]), .o53_12_o(rom_out[53][12]), .o53_13_o(rom_out[53][13]), .o53_14_o(rom_out[53][14]), .o53_15_o(rom_out[53][15]),
        .o54_0_o(rom_out[54][0]), .o54_1_o(rom_out[54][1]), .o54_2_o(rom_out[54][2]), .o54_3_o(rom_out[54][3]), .o54_4_o(rom_out[54][4]), .o54_5_o(rom_out[54][5]), .o54_6_o(rom_out[54][6]), .o54_7_o(rom_out[54][7]), .o54_8_o(rom_out[54][8]), .o54_9_o(rom_out[54][9]), .o54_10_o(rom_out[54][10]), .o54_11_o(rom_out[54][11]), .o54_12_o(rom_out[54][12]), .o54_13_o(rom_out[54][13]), .o54_14_o(rom_out[54][14]), .o54_15_o(rom_out[54][15]),
        .o55_0_o(rom_out[55][0]), .o55_1_o(rom_out[55][1]), .o55_2_o(rom_out[55][2]), .o55_3_o(rom_out[55][3]), .o55_4_o(rom_out[55][4]), .o55_5_o(rom_out[55][5]), .o55_6_o(rom_out[55][6]), .o55_7_o(rom_out[55][7]), .o55_8_o(rom_out[55][8]), .o55_9_o(rom_out[55][9]), .o55_10_o(rom_out[55][10]), .o55_11_o(rom_out[55][11]), .o55_12_o(rom_out[55][12]), .o55_13_o(rom_out[55][13]), .o55_14_o(rom_out[55][14]), .o55_15_o(rom_out[55][15]),
        .o56_0_o(rom_out[56][0]), .o56_1_o(rom_out[56][1]), .o56_2_o(rom_out[56][2]), .o56_3_o(rom_out[56][3]), .o56_4_o(rom_out[56][4]), .o56_5_o(rom_out[56][5]), .o56_6_o(rom_out[56][6]), .o56_7_o(rom_out[56][7]), .o56_8_o(rom_out[56][8]), .o56_9_o(rom_out[56][9]), .o56_10_o(rom_out[56][10]), .o56_11_o(rom_out[56][11]), .o56_12_o(rom_out[56][12]), .o56_13_o(rom_out[56][13]), .o56_14_o(rom_out[56][14]), .o56_15_o(rom_out[56][15]),
        .o57_0_o(rom_out[57][0]), .o57_1_o(rom_out[57][1]), .o57_2_o(rom_out[57][2]), .o57_3_o(rom_out[57][3]), .o57_4_o(rom_out[57][4]), .o57_5_o(rom_out[57][5]), .o57_6_o(rom_out[57][6]), .o57_7_o(rom_out[57][7]), .o57_8_o(rom_out[57][8]), .o57_9_o(rom_out[57][9]), .o57_10_o(rom_out[57][10]), .o57_11_o(rom_out[57][11]), .o57_12_o(rom_out[57][12]), .o57_13_o(rom_out[57][13]), .o57_14_o(rom_out[57][14]), .o57_15_o(rom_out[57][15]),
        .o58_0_o(rom_out[58][0]), .o58_1_o(rom_out[58][1]), .o58_2_o(rom_out[58][2]), .o58_3_o(rom_out[58][3]), .o58_4_o(rom_out[58][4]), .o58_5_o(rom_out[58][5]), .o58_6_o(rom_out[58][6]), .o58_7_o(rom_out[58][7]), .o58_8_o(rom_out[58][8]), .o58_9_o(rom_out[58][9]), .o58_10_o(rom_out[58][10]), .o58_11_o(rom_out[58][11]), .o58_12_o(rom_out[58][12]), .o58_13_o(rom_out[58][13]), .o58_14_o(rom_out[58][14]), .o58_15_o(rom_out[58][15]),
        .o59_0_o(rom_out[59][0]), .o59_1_o(rom_out[59][1]), .o59_2_o(rom_out[59][2]), .o59_3_o(rom_out[59][3]), .o59_4_o(rom_out[59][4]), .o59_5_o(rom_out[59][5]), .o59_6_o(rom_out[59][6]), .o59_7_o(rom_out[59][7]), .o59_8_o(rom_out[59][8]), .o59_9_o(rom_out[59][9]), .o59_10_o(rom_out[59][10]), .o59_11_o(rom_out[59][11]), .o59_12_o(rom_out[59][12]), .o59_13_o(rom_out[59][13]), .o59_14_o(rom_out[59][14]), .o59_15_o(rom_out[59][15]),
        .o60_0_o(rom_out[60][0]), .o60_1_o(rom_out[60][1]), .o60_2_o(rom_out[60][2]), .o60_3_o(rom_out[60][3]), .o60_4_o(rom_out[60][4]), .o60_5_o(rom_out[60][5]), .o60_6_o(rom_out[60][6]), .o60_7_o(rom_out[60][7]), .o60_8_o(rom_out[60][8]), .o60_9_o(rom_out[60][9]), .o60_10_o(rom_out[60][10]), .o60_11_o(rom_out[60][11]), .o60_12_o(rom_out[60][12]), .o60_13_o(rom_out[60][13]), .o60_14_o(rom_out[60][14]), .o60_15_o(rom_out[60][15]),
        .o61_0_o(rom_out[61][0]), .o61_1_o(rom_out[61][1]), .o61_2_o(rom_out[61][2]), .o61_3_o(rom_out[61][3]), .o61_4_o(rom_out[61][4]), .o61_5_o(rom_out[61][5]), .o61_6_o(rom_out[61][6]), .o61_7_o(rom_out[61][7]), .o61_8_o(rom_out[61][8]), .o61_9_o(rom_out[61][9]), .o61_10_o(rom_out[61][10]), .o61_11_o(rom_out[61][11]), .o61_12_o(rom_out[61][12]), .o61_13_o(rom_out[61][13]), .o61_14_o(rom_out[61][14]), .o61_15_o(rom_out[61][15]),
        .o62_0_o(rom_out[62][0]), .o62_1_o(rom_out[62][1]), .o62_2_o(rom_out[62][2]), .o62_3_o(rom_out[62][3]), .o62_4_o(rom_out[62][4]), .o62_5_o(rom_out[62][5]), .o62_6_o(rom_out[62][6]), .o62_7_o(rom_out[62][7]), .o62_8_o(rom_out[62][8]), .o62_9_o(rom_out[62][9]), .o62_10_o(rom_out[62][10]), .o62_11_o(rom_out[62][11]), .o62_12_o(rom_out[62][12]), .o62_13_o(rom_out[62][13]), .o62_14_o(rom_out[62][14]), .o62_15_o(rom_out[62][15]),
        .o63_0_o(rom_out[63][0]), .o63_1_o(rom_out[63][1]), .o63_2_o(rom_out[63][2]), .o63_3_o(rom_out[63][3]), .o63_4_o(rom_out[63][4]), .o63_5_o(rom_out[63][5]), .o63_6_o(rom_out[63][6]), .o63_7_o(rom_out[63][7]), .o63_8_o(rom_out[63][8]), .o63_9_o(rom_out[63][9]), .o63_10_o(rom_out[63][10]), .o63_11_o(rom_out[63][11]), .o63_12_o(rom_out[63][12]), .o63_13_o(rom_out[63][13]), .o63_14_o(rom_out[63][14]), .o63_15_o(rom_out[63][15])
    );

    genvar i, k;

    // Stage 1: buffer each queue byte to meet downstream tristate fanout.
    generate
        for (i = 0; i < 64; i = i + 1) begin : queue_buf
            `BUFFER_DELAY(buf_inst, 1, 8, queue[i*8 +: 8], queue_buffered[i*8 +: 8])
        end
    endgenerate

    // Buffered copy of rom_out: every (i,k) bit is wire-OR'd inside
    // ir_vector_roms by two rom64b32w$ drivers, so blanket-buffer all 64x16
    // = 1024 bits with bufferH16$ to ensure no load sits on a multi-driven
    // bus.
    wire [15:0] rom_out_buf [0:63];
    genvar bi, bk;
    generate
        for (bi = 0; bi < 64; bi = bi + 1) begin : rb_set
            for (bk = 0; bk < 16; bk = bk + 1) begin : rb_pos
                bufferH16$ u_buf (.out(rom_out_buf[bi][bk]), .in(rom_out[bi][bk]));
            end
        end
    endgenerate

    // Stage 2: 64 sets x 16 tristates. Each set i drives queue_buffered[i]
    // onto IR_pre[k] when rom_out_buf[i][k] is low. Wire-or onto IR_pre[k*8 +: 8].
    generate
        for (i = 0; i < 64; i = i + 1) begin : tri_set
            for (k = 0; k < 16; k = k + 1) begin : tri_pos
                `TRISTATE_L(tri_inst, 8, rom_out_buf[i][k],
                              queue_buffered[i*8 +: 8],
                              IR_pre[k*8 +: 8])
            end
        end
    endgenerate

    // Per-bit buffer from IR_pre to IR. Strength chosen per fanout report:
    //   bits 5-7,38-127: bufferH256$  (fanout <= 256)
    //   bits 0-4,8-37 (mostly): bufferH1024$  (fanout 256..1024)
    //   bits 11,19,27: bufferH4096$  (fanout > 1024)
    generate
        for (i = 5; i < 8; i = i + 1) begin : ir_buf_lo
            bufferH256$ u_buf (.out(IR[i]), .in(IR_pre[i]));
        end
        for (i = 38; i < 128; i = i + 1) begin : ir_buf_hi
            bufferH256$ u_buf (.out(IR[i]), .in(IR_pre[i]));
        end
    endgenerate

    bufferH1024$ buf_IR_0  (.out(IR[ 0]), .in(IR_pre[ 0]));
    bufferH1024$ buf_IR_1  (.out(IR[ 1]), .in(IR_pre[ 1]));
    bufferH1024$ buf_IR_2  (.out(IR[ 2]), .in(IR_pre[ 2]));
    bufferH1024$ buf_IR_3  (.out(IR[ 3]), .in(IR_pre[ 3]));
    bufferH1024$ buf_IR_4  (.out(IR[ 4]), .in(IR_pre[ 4]));
    bufferH1024$ buf_IR_8  (.out(IR[ 8]), .in(IR_pre[ 8]));
    bufferH1024$ buf_IR_9  (.out(IR[ 9]), .in(IR_pre[ 9]));
    bufferH1024$ buf_IR_10 (.out(IR[10]), .in(IR_pre[10]));
    bufferH4096$ buf_IR_11 (.out(IR[11]), .in(IR_pre[11]));
    bufferH1024$ buf_IR_12 (.out(IR[12]), .in(IR_pre[12]));
    bufferH1024$ buf_IR_13 (.out(IR[13]), .in(IR_pre[13]));
    bufferH1024$ buf_IR_14 (.out(IR[14]), .in(IR_pre[14]));
    bufferH1024$ buf_IR_15 (.out(IR[15]), .in(IR_pre[15]));
    bufferH1024$ buf_IR_16 (.out(IR[16]), .in(IR_pre[16]));
    bufferH1024$ buf_IR_17 (.out(IR[17]), .in(IR_pre[17]));
    bufferH1024$ buf_IR_18 (.out(IR[18]), .in(IR_pre[18]));
    bufferH4096$ buf_IR_19 (.out(IR[19]), .in(IR_pre[19]));
    bufferH1024$ buf_IR_20 (.out(IR[20]), .in(IR_pre[20]));
    bufferH1024$ buf_IR_21 (.out(IR[21]), .in(IR_pre[21]));
    bufferH1024$ buf_IR_22 (.out(IR[22]), .in(IR_pre[22]));
    bufferH1024$ buf_IR_23 (.out(IR[23]), .in(IR_pre[23]));
    bufferH1024$ buf_IR_24 (.out(IR[24]), .in(IR_pre[24]));
    bufferH1024$ buf_IR_25 (.out(IR[25]), .in(IR_pre[25]));
    bufferH1024$ buf_IR_26 (.out(IR[26]), .in(IR_pre[26]));
    bufferH4096$ buf_IR_27 (.out(IR[27]), .in(IR_pre[27]));
    bufferH1024$ buf_IR_28 (.out(IR[28]), .in(IR_pre[28]));
    bufferH1024$ buf_IR_29 (.out(IR[29]), .in(IR_pre[29]));
    bufferH1024$ buf_IR_30 (.out(IR[30]), .in(IR_pre[30]));
    bufferH1024$ buf_IR_31 (.out(IR[31]), .in(IR_pre[31]));
    bufferH1024$ buf_IR_32 (.out(IR[32]), .in(IR_pre[32]));
    bufferH1024$ buf_IR_33 (.out(IR[33]), .in(IR_pre[33]));
    bufferH1024$ buf_IR_34 (.out(IR[34]), .in(IR_pre[34]));
    bufferH1024$ buf_IR_35 (.out(IR[35]), .in(IR_pre[35]));
    bufferH1024$ buf_IR_36 (.out(IR[36]), .in(IR_pre[36]));
    bufferH1024$ buf_IR_37 (.out(IR[37]), .in(IR_pre[37]));

endmodule



// module selection_logic (
//     input [511:0] queue,
//     input [31:0] EIP,
//     output [127:0] IR
// );

//     wire [5:0] sel_index [0:15];
//     wire [15:0] adder_cout;

//     ir_logic ir_logic_module(
//         .o0_5_o(sel_index[0][5]), .o0_4_o(sel_index[0][4]), .o0_3_o(sel_index[0][3]), .o0_2_o(sel_index[0][2]), .o0_1_o(sel_index[0][1]), .o0_0_o(sel_index[0][0]),
//         .o1_5_o(sel_index[1][5]), .o1_4_o(sel_index[1][4]), .o1_3_o(sel_index[1][3]), .o1_2_o(sel_index[1][2]), .o1_1_o(sel_index[1][1]), .o1_0_o(sel_index[1][0]),
//         .o2_5_o(sel_index[2][5]), .o2_4_o(sel_index[2][4]), .o2_3_o(sel_index[2][3]), .o2_2_o(sel_index[2][2]), .o2_1_o(sel_index[2][1]), .o2_0_o(sel_index[2][0]),
//         .o3_5_o(sel_index[3][5]), .o3_4_o(sel_index[3][4]), .o3_3_o(sel_index[3][3]), .o3_2_o(sel_index[3][2]), .o3_1_o(sel_index[3][1]), .o3_0_o(sel_index[3][0]),
//         .o4_5_o(sel_index[4][5]), .o4_4_o(sel_index[4][4]), .o4_3_o(sel_index[4][3]), .o4_2_o(sel_index[4][2]), .o4_1_o(sel_index[4][1]), .o4_0_o(sel_index[4][0]),
//         .o5_5_o(sel_index[5][5]), .o5_4_o(sel_index[5][4]), .o5_3_o(sel_index[5][3]), .o5_2_o(sel_index[5][2]), .o5_1_o(sel_index[5][1]), .o5_0_o(sel_index[5][0]),
//         .o6_5_o(sel_index[6][5]), .o6_4_o(sel_index[6][4]), .o6_3_o(sel_index[6][3]), .o6_2_o(sel_index[6][2]), .o6_1_o(sel_index[6][1]), .o6_0_o(sel_index[6][0]),
//         .o7_5_o(sel_index[7][5]), .o7_4_o(sel_index[7][4]), .o7_3_o(sel_index[7][3]), .o7_2_o(sel_index[7][2]), .o7_1_o(sel_index[7][1]), .o7_0_o(sel_index[7][0]),
//         .o8_5_o(sel_index[8][5]), .o8_4_o(sel_index[8][4]), .o8_3_o(sel_index[8][3]), .o8_2_o(sel_index[8][2]), .o8_1_o(sel_index[8][1]), .o8_0_o(sel_index[8][0]),
//         .o9_5_o(sel_index[9][5]), .o9_4_o(sel_index[9][4]), .o9_3_o(sel_index[9][3]), .o9_2_o(sel_index[9][2]), .o9_1_o(sel_index[9][1]), .o9_0_o(sel_index[9][0]),
//         .o10_5_o(sel_index[10][5]), .o10_4_o(sel_index[10][4]), .o10_3_o(sel_index[10][3]), .o10_2_o(sel_index[10][2]), .o10_1_o(sel_index[10][1]), .o10_0_o(sel_index[10][0]),
//         .o11_5_o(sel_index[11][5]), .o11_4_o(sel_index[11][4]), .o11_3_o(sel_index[11][3]), .o11_2_o(sel_index[11][2]), .o11_1_o(sel_index[11][1]), .o11_0_o(sel_index[11][0]),
//         .o12_5_o(sel_index[12][5]), .o12_4_o(sel_index[12][4]), .o12_3_o(sel_index[12][3]), .o12_2_o(sel_index[12][2]), .o12_1_o(sel_index[12][1]), .o12_0_o(sel_index[12][0]),
//         .o13_5_o(sel_index[13][5]), .o13_4_o(sel_index[13][4]), .o13_3_o(sel_index[13][3]), .o13_2_o(sel_index[13][2]), .o13_1_o(sel_index[13][1]), .o13_0_o(sel_index[13][0]),
//         .o14_5_o(sel_index[14][5]), .o14_4_o(sel_index[14][4]), .o14_3_o(sel_index[14][3]), .o14_2_o(sel_index[14][2]), .o14_1_o(sel_index[14][1]), .o14_0_o(sel_index[14][0]),
//         .o15_5_o(sel_index[15][5]), .o15_4_o(sel_index[15][4]), .o15_3_o(sel_index[15][3]), .o15_2_o(sel_index[15][2]), .o15_1_o(sel_index[15][1]), .o15_0_o(sel_index[15][0]),

//         .i5_i(EIP[5]), .i4_i(EIP[4]), .i3_i(EIP[3]), .i2_i(EIP[2]), .i1_i(EIP[1]), .i0_i(EIP[0])
//     );

//     genvar i;
//     // generate
//     //     for (i = 0; i < 16; i++) begin : ir_logic_adders
//     //         kogge_stone_adder #(
//     //             .WIDTH(6)
//     //         ) IR_index_adder (
//     //             .a   (EIP[5:0]),
//     //             .b   (6'(i)),       // cast loop index to 6-bit
//     //             .cin (1'b0),
//     //             .sum (sel_index[i]),
//     //             .cout(adder_cout[i])             // unused
//     //         );
//     //     end
//     // endgenerate 

//     generate
//         for(i = 0; i < 16; i=i+1) begin : IR_sel_mux
//             `MUX_64(IR_sel_mux_inst, 8,
//                 IR[i*8 +: 8],
//                 queue[0*8 +: 8],   queue[1*8 +: 8],   queue[2*8 +: 8],   queue[3*8 +: 8],
//                 queue[4*8 +: 8],   queue[5*8 +: 8],   queue[6*8 +: 8],   queue[7*8 +: 8],
//                 queue[8*8 +: 8],   queue[9*8 +: 8],   queue[10*8 +: 8],  queue[11*8 +: 8],
//                 queue[12*8 +: 8],  queue[13*8 +: 8],  queue[14*8 +: 8],  queue[15*8 +: 8],
//                 queue[16*8 +: 8],  queue[17*8 +: 8],  queue[18*8 +: 8],  queue[19*8 +: 8],
//                 queue[20*8 +: 8],  queue[21*8 +: 8],  queue[22*8 +: 8],  queue[23*8 +: 8],
//                 queue[24*8 +: 8],  queue[25*8 +: 8],  queue[26*8 +: 8],  queue[27*8 +: 8],
//                 queue[28*8 +: 8],  queue[29*8 +: 8],  queue[30*8 +: 8],  queue[31*8 +: 8],
//                 queue[32*8 +: 8],  queue[33*8 +: 8],  queue[34*8 +: 8],  queue[35*8 +: 8],
//                 queue[36*8 +: 8],  queue[37*8 +: 8],  queue[38*8 +: 8],  queue[39*8 +: 8],
//                 queue[40*8 +: 8],  queue[41*8 +: 8],  queue[42*8 +: 8],  queue[43*8 +: 8],
//                 queue[44*8 +: 8],  queue[45*8 +: 8],  queue[46*8 +: 8],  queue[47*8 +: 8],
//                 queue[48*8 +: 8],  queue[49*8 +: 8],  queue[50*8 +: 8],  queue[51*8 +: 8],
//                 queue[52*8 +: 8],  queue[53*8 +: 8],  queue[54*8 +: 8],  queue[55*8 +: 8],
//                 queue[56*8 +: 8],  queue[57*8 +: 8],  queue[58*8 +: 8],  queue[59*8 +: 8],
//                 queue[60*8 +: 8],  queue[61*8 +: 8],  queue[62*8 +: 8],  queue[63*8 +: 8],
//                 sel_index[i]
//             )
//         end
//     endgenerate

// endmodule
