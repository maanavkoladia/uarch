// Structural Verilog 2005 port of EXE/FunctionalUnits/bsf_op.sv
//
// BSF (Bit Scan Forward): scans srB from LSB upward and returns the index
// of the first set bit.
//
//   data_size[2] == 1 -> 32-bit BSF (scan srB[31:0])
//   data_size[2] == 0 -> 16-bit BSF (scan srB[15:0])
//
// ZF = 1 iff the scanned slice was all zero.  When ZF=1 the SDM defines
// the destination as "undefined"; the SV reference (and this port) pick 0
// as the concrete value.  This implementation hits that case naturally
// (the per-byte BSF results are AND-gated by their pencoder valid bits,
// so a fully-zero input produces a 0 result with no special-case logic).
//
// Partial-register write semantics:
//   * 32-bit BSF writes the full low-32 of dest; the FU output's high-32
//     are forced to 0 (regfile commits 32-bit values).
//   * 16-bit BSF only changes dest[15:0]; dest[31:16] must be preserved.
//     srA carries the destination's current value so we can merge its
//     upper-16 into the result here.
//
// Critical-path-friendly algorithm (replaces the prior 31-deep prefix-OR
// cascade):
//
//   1. Bit-reverse each byte of srB.  After bit-reversal the lowest set
//      bit of the byte becomes the highest set bit of the reversed byte,
//      so a leading-1 priority encoder gives us the BSF position.
//
//   2. Run four pencoder8_3v$ primitives (lib5.v) in parallel, one per
//      byte.  Each fires in ~0.76 ns and produces:
//        Y[k][2:0] = 7 - (BSF position within byte k)   (when valid)
//                  = 0                                  (when byte == 0)
//        v[k]      = 1 iff byte k has any set bit
//
//   3. low[k] = (~Y[k]) & {3{v[k]}}  -> BSF-within-byte gated by valid.
//      Gating by v[k] ensures an all-zero byte produces 0 (otherwise the
//      bit-flip of the pencoder's Y=0 would yield 7).
//
//   4. Pick the lowest-indexed byte that has v[k]=1.  This is itself a
//      tiny priority encoder over v[3:0]:
//        s1 = ~v0 & v1
//        s2 = ~v0 & ~v1 & v2
//        s3 = ~v0 & ~v1 & ~v2 & v3
//        byte_idx32 = {s2|s3, s1|s3}
//      Implementing the same structure for v[1:0] gives byte_idx16.
//
//   5. The 5-bit 32-bit BSF index is {byte_idx32, mux4(low[0..3])}; the
//      4-bit 16-bit BSF index is {byte_idx16, mux2(low0, low1)}.
//
//   6. ZF32 = NOR(v[3:0]); ZF16 = NOR(v[1:0]); ZF = data_size[2] ? ZF32
//      : ZF16.
//
//   7. Final 64-bit merge: high-32 = 0; [31:16] keeps srA[31:16] for
//      16-bit BSF (or 0 for 32-bit BSF, which writes the whole low-32);
//      [15:5] = 0 (max index = 31 fits in 5 bits); [4:0] picks index32
//      vs {1'b0, index16} based on data_size[2].
//
// Worst-case data path (approximate):
//   pencoder (0.76) + INV (~v) (0.30) + AND_4 (s3) (0.50) + OR_2 (0.50)
//   + MUX_2 (output mux, 0.60)  =  ~2.7 ns
// vs. the prior linear cascade's ~17 ns.

module bsf_op (
    input  wire [63:0] srA,
    input  wire [63:0] srB,
    input  wire [3:0]  data_size,
    output wire [63:0] dr_o,
    output wire [63:0] res_buf_o,
    output wire        ZF
);

    // -------------------------------------------------------------
    // 1. Per-byte bit-reverse of srB[31:0] (pure routing, no gates).
    //    X[k][i] = srB[8*k + (7-i)]   so the byte's MSB-first becomes
    //    the pencoder's high-priority input X[7].
    // -------------------------------------------------------------
    wire [7:0] X0, X1, X2, X3;
    assign X0 = {srB[0],  srB[1],  srB[2],  srB[3],  srB[4],  srB[5],  srB[6],  srB[7]};
    assign X1 = {srB[8],  srB[9],  srB[10], srB[11], srB[12], srB[13], srB[14], srB[15]};
    assign X2 = {srB[16], srB[17], srB[18], srB[19], srB[20], srB[21], srB[22], srB[23]};
    assign X3 = {srB[24], srB[25], srB[26], srB[27], srB[28], srB[29], srB[30], srB[31]};

    // -------------------------------------------------------------
    // 2. Four pencoder8_3v$ in parallel (one per byte).
    //    enbar tied low.  Y[k] reports the position of the highest
    //    asserted X-bit (= 7 - BSF position in that byte when v=1, or
    //    0 when v=0).  v[k] is 1 iff that byte has any set bit.
    // -------------------------------------------------------------
    wire [2:0] Y0, Y1, Y2, Y3;
    wire       v0, v1, v2, v3;
    wire       v0_raw, v1_raw, v2_raw, v3_raw;
    pencoder8_3v$ u_pen0 (.enbar(1'b0), .X(X0), .Y(Y0), .valid(v0_raw));
    pencoder8_3v$ u_pen1 (.enbar(1'b0), .X(X1), .Y(Y1), .valid(v1_raw));
    pencoder8_3v$ u_pen2 (.enbar(1'b0), .X(X2), .Y(Y2), .valid(v2_raw));
    pencoder8_3v$ u_pen3 (.enbar(1'b0), .X(X3), .Y(Y3), .valid(v3_raw));
    // v0..v3 fanouts 6/8/6/5 — all fit bufferH16$ (smallest H-buffer).
    bufferH16$ u_buf_v0 (.out(v0), .in(v0_raw));
    bufferH16$ u_buf_v1 (.out(v1), .in(v1_raw));
    bufferH16$ u_buf_v2 (.out(v2), .in(v2_raw));
    bufferH16$ u_buf_v3 (.out(v3), .in(v3_raw));

    // -------------------------------------------------------------
    // 3. Per-byte BSF position, gated by valid.
    //    notY = ~Y               (bit-flip; 3-bit "7 - Y" because Y is
    //                              reverse-priority within the byte)
    //    low  = notY & {3{v}}    (force 0 when byte is all-zero so the
    //                              all-zero input case yields index = 0)
    // -------------------------------------------------------------
    wire [2:0] notY0, notY1, notY2, notY3;
    `INV_N(u_inv_Y0, 3, Y0, notY0)
    `INV_N(u_inv_Y1, 3, Y1, notY1)
    `INV_N(u_inv_Y2, 3, Y2, notY2)
    `INV_N(u_inv_Y3, 3, Y3, notY3)

    wire [2:0] low0, low1, low2, low3;
    `AND_2(u_and_low0, 3, low0, notY0, {3{v0}})
    `AND_2(u_and_low1, 3, low1, notY1, {3{v1}})
    `AND_2(u_and_low2, 3, low2, notY2, {3{v2}})
    `AND_2(u_and_low3, 3, low3, notY3, {3{v3}})

    // -------------------------------------------------------------
    // 4. Byte-select priority logic over v[3:0].
    //      s1 = ~v0 &  v1
    //      s2 = ~v0 & ~v1 &  v2
    //      s3 = ~v0 & ~v1 & ~v2 &  v3
    //    (s0 = v0 isn't needed explicitly — when v0=1 byte_idx falls to
    //    0 because all of s1,s2,s3 have ~v0 in them.)
    // -------------------------------------------------------------
    wire nv0, nv1, nv2;
    `INV_N(u_inv_v0, 1, v0, nv0)
    `INV_N(u_inv_v1, 1, v1, nv1)
    `INV_N(u_inv_v2, 1, v2, nv2)

    wire s1, s2, s3;
    `AND_2(u_s1, 1, s1, nv0, v1)
    `AND_3(u_s2, 1, s2, nv0, nv1, v2)
    `AND_4(u_s3, 1, s3, nv0, nv1, nv2, v3)

    // -------------------------------------------------------------
    // 5a. 32-bit byte index and lower-3 mux.
    //       byte_idx32[0] = chosen byte is 1 or 3
    //       byte_idx32[1] = chosen byte is 2 or 3
    //       bsf_low32     = MUX_4 over low0..low3 selected by byte_idx32
    //       bsf32         = {byte_idx32, bsf_low32}     (5 bits)
    // -------------------------------------------------------------
    wire bidx32_0, bidx32_1;
    `OR_2(u_bidx32_0, 1, bidx32_0, s1, s3)
    `OR_2(u_bidx32_1, 1, bidx32_1, s2, s3)

    wire [1:0] byte_idx32;
    assign byte_idx32 = {bidx32_1, bidx32_0};

    wire [2:0] bsf_low32;
    `MUX_4(u_mux_low32, 3, bsf_low32, low0, low1, low2, low3, byte_idx32)

    wire [4:0] bsf32;
    assign bsf32 = {byte_idx32, bsf_low32};

    // -------------------------------------------------------------
    // 5b. 16-bit byte index and lower-3 mux (uses only bytes 0 and 1).
    //       byte_idx16 = ~v0 & v1   (selects byte 1 when byte 0 is all
    //                                 zero and byte 1 has any set bit;
    //                                 0 otherwise — including the
    //                                 all-zero case, which keeps the
    //                                 final result at 0)
    //       bsf_low16  = MUX_2(low0, low1, byte_idx16)
    //       bsf16      = {byte_idx16, bsf_low16}        (4 bits)
    // -------------------------------------------------------------
    wire byte_idx16;
    `AND_2(u_bidx16, 1, byte_idx16, nv0, v1)

    wire [2:0] bsf_low16;
    `MUX_2(u_mux_low16, 3, bsf_low16, low0, low1, byte_idx16)

    wire [3:0] bsf16;
    assign bsf16 = {byte_idx16, bsf_low16};

    // -------------------------------------------------------------
    // 6. ZF = 1 iff the scanned slice was all zero.
    //      ZF32 = NOR(v0, v1, v2, v3)
    //      ZF16 = NOR(v0, v1)
    //      ZF   = data_size[2] ? ZF32 : ZF16
    // -------------------------------------------------------------
    wire zf32, zf16;
    `NOR_4(u_zf32, 1, zf32, v0, v1, v2, v3)
    `NOR_2(u_zf16, 1, zf16, v0, v1)
    `MUX_2(u_mux_zf, 1, ZF, zf16, zf32, data_size[2])

    // -------------------------------------------------------------
    // 7. Width-aware merge into the 64-bit output bus.
    //      [63:32] = 32'h0           (always; regfile zero-extends)
    //      [31:16] = data_size[2] ? 16'h0 : srA[31:16]
    //                              (16-bit BSF preserves dest upper-16)
    //      [15:5]  = 11'h0           (max index = 31, fits in 5 bits)
    //      [4:0]   = data_size[2] ? bsf32 : {1'b0, bsf16}
    // -------------------------------------------------------------
    wire [15:0] m_31_16;
    `MUX_2(u_mux_hi16, 16, m_31_16, srA[31:16], 16'h0, data_size[2])

    wire [4:0] bsf16_padded;
    assign bsf16_padded = {1'b0, bsf16};

    wire [4:0] m_4_0;
    `MUX_2(u_mux_idx, 5, m_4_0, bsf16_padded, bsf32, data_size[2])

    wire [63:0] merged;
    assign merged = {32'h0, m_31_16, 11'h0, m_4_0};

    assign dr_o      = merged;
    assign res_buf_o = merged;

endmodule
