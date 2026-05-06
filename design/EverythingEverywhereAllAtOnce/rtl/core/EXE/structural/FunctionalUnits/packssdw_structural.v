// Structural Verilog 2005 port of EXE/FunctionalUnits/packssdw.sv
// 4 lanes of signed 32-bit -> 16-bit saturation.
//   Each 32-bit lane x[31:0] saturates to 0x7FFF if x > 32767,
//   to 0x8000 if x < -32768, else passes x[15:0].
//   Equivalently: pos_overflow = ~x[31] & OR(x[30:15])
//                 neg_overflow =  x[31] & NAND(x[30:15])
//   Output mux: neg_ov ? 0x8000 : (pos_ov ? 0x7FFF : x[15:0])

module packssdw (
    input  wire [63:0] srA,
    input  wire [63:0] srB,
    output wire [63:0] dr_o
);

    wire [15:0] r0, r1, r2, r3;

    packssdw_sat_lane u_lane0 (.x(srA[31:0]),  .y(r0));
    packssdw_sat_lane u_lane1 (.x(srA[63:32]), .y(r1));
    packssdw_sat_lane u_lane2 (.x(srB[31:0]),  .y(r2));
    packssdw_sat_lane u_lane3 (.x(srB[63:32]), .y(r3));

    assign dr_o = {r3, r2, r1, r0};

endmodule


module packssdw_sat_lane (
    input  wire [31:0] x,
    output wire [15:0] y
);

    wire [15:0] high16;
    assign high16 = x[30:15];

    // OR(high16) via NAND-NOR alternation: 4× NOR_4 → NAND_4
    wire nor_p0, nor_p1, nor_p2, nor_p3;
    `NOR_4(u_norp0, 1, nor_p0, high16[0],  high16[1],  high16[2],  high16[3])
    `NOR_4(u_norp1, 1, nor_p1, high16[4],  high16[5],  high16[6],  high16[7])
    `NOR_4(u_norp2, 1, nor_p2, high16[8],  high16[9],  high16[10], high16[11])
    `NOR_4(u_norp3, 1, nor_p3, high16[12], high16[13], high16[14], high16[15])
    wire any_high_set;
    `NAND_4(u_nandp, 1, any_high_set, nor_p0, nor_p1, nor_p2, nor_p3)

    wire sign_inv;
    `INV_N(u_inv_sign, 1, x[31], sign_inv)
    wire pos_ov, pos_ov_raw;
    `AND_2(u_and_pos, 1, pos_ov_raw, sign_inv, any_high_set)
    // pos_ov drives 16 mux2$ select pins inside u_mux_p (fanout 16, exact fit
    // for bufferH16$ at 0.24 ns typ).
    bufferH16$ u_buf_pos_ov (.out(pos_ov), .in(pos_ov_raw));

    // OR over inverted high16 (i.e., NAND of high16): invert each bit, then OR
    wire [15:0] high16_inv;
    `INV_N(u_inv_high, 16, high16, high16_inv)
    wire nor_n0, nor_n1, nor_n2, nor_n3;
    `NOR_4(u_norn0, 1, nor_n0, high16_inv[0],  high16_inv[1],  high16_inv[2],  high16_inv[3])
    `NOR_4(u_norn1, 1, nor_n1, high16_inv[4],  high16_inv[5],  high16_inv[6],  high16_inv[7])
    `NOR_4(u_norn2, 1, nor_n2, high16_inv[8],  high16_inv[9],  high16_inv[10], high16_inv[11])
    `NOR_4(u_norn3, 1, nor_n3, high16_inv[12], high16_inv[13], high16_inv[14], high16_inv[15])
    wire any_high_clear;
    `NAND_4(u_nandn, 1, any_high_clear, nor_n0, nor_n1, nor_n2, nor_n3)

    wire neg_ov, neg_ov_raw;
    `AND_2(u_and_neg, 1, neg_ov_raw, x[31], any_high_clear)
    // neg_ov drives 16 mux2$ select pins inside u_mux_n (fanout 16).
    bufferH16$ u_buf_neg_ov (.out(neg_ov), .in(neg_ov_raw));

    // Output mux: pos_ov  ? 0x7FFF : x[15:0]
    //             then neg_ov ? 0x8000 : sat_pos
    wire [15:0] sat_pos;
    `MUX_2(u_mux_p, 16, sat_pos, x[15:0], 16'h7FFF, pos_ov)
    `MUX_2(u_mux_n, 16, y,       sat_pos, 16'h8000, neg_ov)

endmodule
