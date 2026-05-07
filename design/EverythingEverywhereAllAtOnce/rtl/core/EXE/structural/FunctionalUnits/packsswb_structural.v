// Structural Verilog 2005 port of EXE/FunctionalUnits/packsswb.sv
// 8 lanes of signed 16-bit -> 8-bit saturation.
//   Each 16-bit lane x[15:0] saturates to 0x7F if x > 127,
//   to 0x80 if x < -128, else passes x[7:0].
//   pos_overflow = ~x[15] & OR(x[14:7])
//   neg_overflow =  x[15] & NAND(x[14:7])

module packsswb (
    input  wire [63:0] srA,
    input  wire [63:0] srB,
    output wire [63:0] dr_o
);

    wire [7:0] r0, r1, r2, r3, r4, r5, r6, r7;

    packsswb_sat_lane u_lane0 (.x(srA[15:0]),  .y(r0));
    packsswb_sat_lane u_lane1 (.x(srA[31:16]), .y(r1));
    packsswb_sat_lane u_lane2 (.x(srA[47:32]), .y(r2));
    packsswb_sat_lane u_lane3 (.x(srA[63:48]), .y(r3));
    packsswb_sat_lane u_lane4 (.x(srB[15:0]),  .y(r4));
    packsswb_sat_lane u_lane5 (.x(srB[31:16]), .y(r5));
    packsswb_sat_lane u_lane6 (.x(srB[47:32]), .y(r6));
    packsswb_sat_lane u_lane7 (.x(srB[63:48]), .y(r7));

    assign dr_o = {r7, r6, r5, r4, r3, r2, r1, r0};

endmodule


module packsswb_sat_lane (
    input  wire [15:0] x,
    output wire [7:0]  y
);

    wire [7:0] high8;
    assign high8 = x[14:7];

    // OR(high8) via NOR-NAND: 2× NOR_4 → NAND_2
    wire nor_p0, nor_p1;
    `NOR_4(u_norp0, 1, nor_p0, high8[0], high8[1], high8[2], high8[3])
    `NOR_4(u_norp1, 1, nor_p1, high8[4], high8[5], high8[6], high8[7])
    wire any_high_set;
    `NAND_2(u_nandp, 1, any_high_set, nor_p0, nor_p1)

    wire sign_inv;
    `INV_N(u_inv_sign, 1, x[15], sign_inv)
    wire pos_ov, pos_ov_raw;
    `AND_2(u_and_pos, 1, pos_ov_raw, sign_inv, any_high_set)
    // pos_ov drives 8 mux2$ select pins inside u_mux_p (fanout 8, fits
    // bufferH16$ at 0.24 ns typ — smallest H-buffer available).
    bufferH16$ u_buf_pos_ov (.out(pos_ov), .in(pos_ov_raw));

    // NAND(high8) = OR over inverted high8.
    wire [7:0] high8_inv;
    `INV_N(u_inv_high, 8, high8, high8_inv)
    wire nor_n0, nor_n1;
    `NOR_4(u_norn0, 1, nor_n0, high8_inv[0], high8_inv[1], high8_inv[2], high8_inv[3])
    `NOR_4(u_norn1, 1, nor_n1, high8_inv[4], high8_inv[5], high8_inv[6], high8_inv[7])
    wire any_high_clear;
    `NAND_2(u_nandn, 1, any_high_clear, nor_n0, nor_n1)

    wire neg_ov, neg_ov_raw;
    `AND_2(u_and_neg, 1, neg_ov_raw, x[15], any_high_clear)
    // neg_ov drives 8 mux2$ select pins inside u_mux_n (fanout 8).
    bufferH16$ u_buf_neg_ov (.out(neg_ov), .in(neg_ov_raw));

    // Output mux
    wire [7:0] sat_pos;
    `MUX_2(u_mux_p, 8, sat_pos, x[7:0], 8'h7F, pos_ov)
    `MUX_2(u_mux_n, 8, y,       sat_pos, 8'h80, neg_ov)

endmodule
