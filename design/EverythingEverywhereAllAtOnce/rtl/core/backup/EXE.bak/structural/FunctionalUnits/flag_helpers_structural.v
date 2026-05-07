// Shared structural helpers used by EXE flag-producing functional units
// (cmp, add_op, adc_op, sbb_op, or_op, and_op, ...).
//
//  zf_red_8/16/32 : reduction-AND of NORs ("all bits zero" → 1).
//  pf_red_8       : even-parity over 8 bits (XNOR-tree).

module zf_red_8 (
    input  wire [7:0] x,
    output wire       z
);
    wire n_lo, n_hi;
    `NOR_4(u_nor_lo, 1, n_lo, x[0], x[1], x[2], x[3])
    `NOR_4(u_nor_hi, 1, n_hi, x[4], x[5], x[6], x[7])
    `AND_2(u_and,    1, z,    n_lo, n_hi)
endmodule

module zf_red_16 (
    input  wire [15:0] x,
    output wire        z
);
    wire n0, n1, n2, n3;
    `NOR_4(u_nor0, 1, n0, x[0],  x[1],  x[2],  x[3])
    `NOR_4(u_nor1, 1, n1, x[4],  x[5],  x[6],  x[7])
    `NOR_4(u_nor2, 1, n2, x[8],  x[9],  x[10], x[11])
    `NOR_4(u_nor3, 1, n3, x[12], x[13], x[14], x[15])
    `AND_4(u_and, 1, z, n0, n1, n2, n3)
endmodule

module zf_red_32 (
    input  wire [31:0] x,
    output wire        z
);
    wire n0, n1, n2, n3, n4, n5, n6, n7;
    `NOR_4(u_nor0, 1, n0, x[0],  x[1],  x[2],  x[3])
    `NOR_4(u_nor1, 1, n1, x[4],  x[5],  x[6],  x[7])
    `NOR_4(u_nor2, 1, n2, x[8],  x[9],  x[10], x[11])
    `NOR_4(u_nor3, 1, n3, x[12], x[13], x[14], x[15])
    `NOR_4(u_nor4, 1, n4, x[16], x[17], x[18], x[19])
    `NOR_4(u_nor5, 1, n5, x[20], x[21], x[22], x[23])
    `NOR_4(u_nor6, 1, n6, x[24], x[25], x[26], x[27])
    `NOR_4(u_nor7, 1, n7, x[28], x[29], x[30], x[31])
    wire a0, a1;
    `AND_4(u_and0, 1, a0, n0, n1, n2, n3)
    `AND_4(u_and1, 1, a1, n4, n5, n6, n7)
    `AND_2(u_and,  1, z,  a0, a1)
endmodule

// PF: even parity over low 8 bits = ~XOR(8 bits)
module pf_red_8 (
    input  wire [7:0] x,
    output wire       p
);
    wire t0, t1, t2, t3;
    `XOR_2(u_xor0, 1, t0, x[0], x[1])
    `XOR_2(u_xor1, 1, t1, x[2], x[3])
    `XOR_2(u_xor2, 1, t2, x[4], x[5])
    `XOR_2(u_xor3, 1, t3, x[6], x[7])
    wire u0, u1;
    `XOR_2(u_xor4, 1, u0, t0, t1)
    `XOR_2(u_xor5, 1, u1, t2, t3)
    wire xor_all;
    `XOR_2(u_xor6, 1, xor_all, u0, u1)
    `INV_N(u_inv,  1, xor_all, p)
endmodule
