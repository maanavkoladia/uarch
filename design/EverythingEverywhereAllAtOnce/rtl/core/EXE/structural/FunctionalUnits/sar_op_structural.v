// Structural Verilog 2005 port of EXE/FunctionalUnits/sar_op.sv
//
// Arithmetic right shift. 4 width-isolated barrel shifters (AL, AH, AX, EAX);
// per-width CF picks the bit at position (count-1) within the lane, saturated
// to the sign bit for count > N.
//
// Count source: shift_by_one→1, else  data_size[0] ? shift_amt[4:0] : shift_amt[12:8].
//
// Flags:
//   count == 0: ZF/SF/PF/OF/CF/AF = curr_*_flag (preserved); result = value_i.
//   count >  0: OF = 0; AF = 0;
//               ZF/SF/PF derived per-width; CF as described above.
//   For data_size = EAX, result[63:32] is forced to 0 (zero-extend).

module sar_op (
    input  wire [63:0] value_i,
    input  wire [63:0] shift_amt_i,
    input  wire [3:0]  data_size,
    input  wire [3:0]  sr_data_size_vec,
    input  wire        shift_by_one,
    input  wire        curr_zf_flag,
    input  wire        curr_sf_flag,
    input  wire        curr_pf_flag,
    input  wire        curr_of_flag,
    input  wire        curr_cf_flag,
    input  wire        curr_af_flag,
    output wire [63:0] dr_o,
    output wire [63:0] res_buf_o,
    output wire        ZF,
    output wire        SF,
    output wire        PF,
    output wire        OF,
    output wire        CF,
    output wire        AF
);

    // ---- Count derivation ----
    // Per Intel SAR spec: "count is masked to 5 bits, range 0 to 31".
    // count[5] is therefore always 0 -- the previous 6th cascade stage
    // (shift-by-32) was dead logic and is removed below.
    wire [4:0] cnt_amt;
    `MUX_2(u_mux_cnt_amt, 5, cnt_amt, shift_amt_i[12:8], shift_amt_i[4:0], data_size[0])
    wire [5:0] count_pre;
    assign count_pre = {1'b0, cnt_amt};
    wire [5:0] count;          // cmp / saturation-OR / MUX_8/16/32 select path
    wire [4:0] count_cas;      // 4-cascade selects (al+ah+ax+eax = 64 loads/bit)
    wire [5:0] count_raw;
    `MUX_2(u_mux_count, 6, count_raw, count_pre, 6'd1, shift_by_one)

    // Split the per-bit fanout into two clusters so each driver fights a
    // smaller load instead of one 0.54 ns bufferH256$:
    //   4-width cascades (8+8+16+32 = 64 loads/bit) -> bufferH64$ (0.30 ns)
    //   is_count_zero CMP, ge8/ge16 ORs, MUX_8/16/32 selects (~10 loads/bit)
    //                                                  -> bufferH16$ (0.24 ns)
    genvar gi_buf_cnt;
    generate
        for (gi_buf_cnt = 0; gi_buf_cnt < 5; gi_buf_cnt = gi_buf_cnt + 1) begin : g_count_buf_cas
            bufferH64$ u_buf_cnt_cas (
                .out(count_cas[gi_buf_cnt]),
                .in (count_raw[gi_buf_cnt]));
        end
        for (gi_buf_cnt = 0; gi_buf_cnt < 6; gi_buf_cnt = gi_buf_cnt + 1) begin : g_count_buf_cmp
            // bits 3/4 reach 17 fanout (used in saturation OR + MUX_8/16/32
            // selects + cmp comparator).  Upsize to bufferH64$ (0.30 ns) to
            // clear the violation -- 0.06 ns over bufferH16$.
            bufferH64$ u_buf_cnt_cmp (
                .out(count[gi_buf_cnt]),
                .in (count_raw[gi_buf_cnt]));
        end
    endgenerate

    // ---- Sign bits per width ----
    wire al_sign  = value_i[7];
    wire ah_sign  = value_i[15];
    wire ax_sign  = value_i[15];
    wire eax_sign = value_i[31];

    // ---- 8-bit barrel right (AL) -- 5 stages cover shift 0..31 ----
    wire [7:0] al_in = value_i[7:0];
    wire [7:0] al_s0, al_s1, al_s2, al_s3, al_res;
    `MUX_2(u_al_0, 8, al_s0,  al_in, {al_sign,      al_in[7:1]}, count_cas[0])
    `MUX_2(u_al_1, 8, al_s1,  al_s0, {{2{al_sign}}, al_s0[7:2]}, count_cas[1])
    `MUX_2(u_al_2, 8, al_s2,  al_s1, {{4{al_sign}}, al_s1[7:4]}, count_cas[2])
    `MUX_2(u_al_3, 8, al_s3,  al_s2, {8{al_sign}},               count_cas[3])
    `MUX_2(u_al_4, 8, al_res, al_s3, {8{al_sign}},               count_cas[4])

    // ---- 8-bit barrel right (AH) -- 5 stages ----
    wire [7:0] ah_in = value_i[15:8];
    wire [7:0] ah_s0, ah_s1, ah_s2, ah_s3, ah_res;
    `MUX_2(u_ah_0, 8, ah_s0,  ah_in, {ah_sign,      ah_in[7:1]}, count_cas[0])
    `MUX_2(u_ah_1, 8, ah_s1,  ah_s0, {{2{ah_sign}}, ah_s0[7:2]}, count_cas[1])
    `MUX_2(u_ah_2, 8, ah_s2,  ah_s1, {{4{ah_sign}}, ah_s1[7:4]}, count_cas[2])
    `MUX_2(u_ah_3, 8, ah_s3,  ah_s2, {8{ah_sign}},               count_cas[3])
    `MUX_2(u_ah_4, 8, ah_res, ah_s3, {8{ah_sign}},               count_cas[4])

    // ---- 16-bit barrel right (AX) -- 5 stages ----
    wire [15:0] ax_in = value_i[15:0];
    wire [15:0] ax_s0, ax_s1, ax_s2, ax_s3, ax_res;
    `MUX_2(u_ax_0, 16, ax_s0,  ax_in, {ax_sign,      ax_in[15:1]}, count_cas[0])
    `MUX_2(u_ax_1, 16, ax_s1,  ax_s0, {{2{ax_sign}}, ax_s0[15:2]}, count_cas[1])
    `MUX_2(u_ax_2, 16, ax_s2,  ax_s1, {{4{ax_sign}}, ax_s1[15:4]}, count_cas[2])
    `MUX_2(u_ax_3, 16, ax_s3,  ax_s2, {{8{ax_sign}}, ax_s2[15:8]}, count_cas[3])
    `MUX_2(u_ax_4, 16, ax_res, ax_s3, {16{ax_sign}},               count_cas[4])

    // ---- 32-bit barrel right (EAX) -- 5 stages ----
    wire [31:0] eax_in = value_i[31:0];
    wire [31:0] eax_s0, eax_s1, eax_s2, eax_s3, eax_res;
    `MUX_2(u_eax_0, 32, eax_s0,  eax_in, {eax_sign,       eax_in[31:1]},   count_cas[0])
    `MUX_2(u_eax_1, 32, eax_s1,  eax_s0, {{2{eax_sign}},  eax_s0[31:2]},   count_cas[1])
    `MUX_2(u_eax_2, 32, eax_s2,  eax_s1, {{4{eax_sign}},  eax_s1[31:4]},   count_cas[2])
    `MUX_2(u_eax_3, 32, eax_s3,  eax_s2, {{8{eax_sign}},  eax_s2[31:8]},   count_cas[3])
    `MUX_2(u_eax_4, 32, eax_res, eax_s3, {{16{eax_sign}}, eax_s3[31:16]},  count_cas[4])

    // ============================================================
    // CF per width (variable bit-select with saturation to sign bit)
    // ============================================================
    wire [2:0] cnt_lo3 = count[2:0];
    wire [3:0] cnt_lo4 = count[3:0];
    wire [4:0] cnt_lo5 = count[4:0];

    // count[5] is always 0 (Intel 5-bit mask).  Saturation conditions simplify:
    //   al_count_ge8  = count[4] | count[3]
    //   ah_count_ge8  = count[4] | count[3]
    //   ax_count_ge16 = count[4]                  (no OR needed)
    //   eax saturation never triggers             (drop the mux entirely)

    // AL: in0 = value_i[7] (count=0 or count=8), inI = value_i[I-1]
    wire al_cf_inner;
    `MUX_8(u_mux_al_cf, 1, al_cf_inner,
        value_i[7], value_i[0], value_i[1], value_i[2],
        value_i[3], value_i[4], value_i[5], value_i[6],
        cnt_lo3)
    wire al_count_ge8;
    `OR_2(u_or_al_ge8, 1, al_count_ge8, count[4], count[3])
    wire al_cf;
    `MUX_2(u_mux_al_cfsat, 1, al_cf, al_cf_inner, value_i[7], al_count_ge8)

    // AH: in0 = value_i[15] (count=0 or count=8), inI = value_i[7+I]
    wire ah_cf_inner;
    `MUX_8(u_mux_ah_cf, 1, ah_cf_inner,
        value_i[15], value_i[8],  value_i[9],  value_i[10],
        value_i[11], value_i[12], value_i[13], value_i[14],
        cnt_lo3)
    wire ah_count_ge8;
    `OR_2(u_or_ah_ge8, 1, ah_count_ge8, count[4], count[3])
    wire ah_cf;
    `MUX_2(u_mux_ah_cfsat, 1, ah_cf, ah_cf_inner, value_i[15], ah_count_ge8)

    // AX: in0 = value_i[15], inI = value_i[I-1]
    wire ax_cf_inner;
    `MUX_16(u_mux_ax_cf, 1, ax_cf_inner,
        value_i[15], value_i[0],  value_i[1],  value_i[2],
        value_i[3],  value_i[4],  value_i[5],  value_i[6],
        value_i[7],  value_i[8],  value_i[9],  value_i[10],
        value_i[11], value_i[12], value_i[13], value_i[14],
        cnt_lo4)
    wire ax_cf;
    `MUX_2(u_mux_ax_cfsat, 1, ax_cf, ax_cf_inner, value_i[15], count[4])

    // EAX: in0 = value_i[31], inI = value_i[I-1].  count[5]==0 always so the
    // saturation MUX collapses to eax_cf = eax_cf_inner -- one MUX level off
    // the EAX CF path.
    wire eax_cf;
    `MUX_32(u_mux_eax_cf, 1, eax_cf,
        value_i[31], value_i[0],  value_i[1],  value_i[2],
        value_i[3],  value_i[4],  value_i[5],  value_i[6],
        value_i[7],  value_i[8],  value_i[9],  value_i[10],
        value_i[11], value_i[12], value_i[13], value_i[14],
        value_i[15], value_i[16], value_i[17], value_i[18],
        value_i[19], value_i[20], value_i[21], value_i[22],
        value_i[23], value_i[24], value_i[25], value_i[26],
        value_i[27], value_i[28], value_i[29], value_i[30],
        cnt_lo5)

    // ============================================================
    // ZF / SF / PF per width
    // ============================================================
    wire al_zf, ah_zf, ax_zf, eax_zf;
    zf_red_8  u_zf_al  (.x(al_res),  .z(al_zf));
    zf_red_8  u_zf_ah  (.x(ah_res),  .z(ah_zf));
    zf_red_16 u_zf_ax  (.x(ax_res),  .z(ax_zf));
    zf_red_32 u_zf_eax (.x(eax_res), .z(eax_zf));

    wire al_sf  = al_res[7];
    wire ah_sf  = ah_res[7];
    wire ax_sf  = ax_res[15];
    wire eax_sf = eax_res[31];

    // PF: AL/AX/EAX use result[7:0]; AH uses ah_res[7:0] (= merged[15:8]).
    wire al_pf, ah_pf, ax_pf, eax_pf;
    pf_red_8 u_pf_al  (.x(al_res),       .p(al_pf));
    pf_red_8 u_pf_ah  (.x(ah_res),       .p(ah_pf));
    pf_red_8 u_pf_ax  (.x(ax_res[7:0]),  .p(ax_pf));
    pf_red_8 u_pf_eax (.x(eax_res[7:0]), .p(eax_pf));

    // ============================================================
    // data_size selectors
    // ============================================================
    wire is_al, is_ah, is_ax, is_eax, is_eax_big;
    wire is_al_raw, is_ah_raw, is_ax_raw, is_eax_raw;
    `CMP_N(u_cmp_al,  4, is_al_raw,  data_size, 4'b0001)
    `CMP_N(u_cmp_ah,  4, is_ah_raw,  data_size, 4'b0010)
    `CMP_N(u_cmp_ax,  4, is_ax_raw,  data_size, 4'b0011)
    `CMP_N(u_cmp_eax, 4, is_eax_raw, data_size, 4'b0111)
    // Per-fanout sizing: al/ah=12 → H16; ax=20 → H64; eax=68 → H256.
    bufferH16$  u_buf_is_al  (.out(is_al),  .in(is_al_raw));
    bufferH16$  u_buf_is_ah  (.out(is_ah),  .in(is_ah_raw));
    bufferH64$  u_buf_is_ax  (.out(is_ax),  .in(is_ax_raw));
    // is_eax fanout 68 = u_mux_rtop(32) + rb23(16) + rb0_1(8) + rb1_1(8) + 4
    // flag muxes. Split: is_eax_big drives rtop (32 loads, bufferH64$ at 0.30
    // ns), is_eax drives the other 36 loads (bufferH64$, 0.30 ns). Saves
    // 0.24 ns on the rtop critical path vs single bufferH256$ (0.54 ns).
    bufferH64$ u_buf_is_eax_sm (.out(is_eax),     .in(is_eax_raw));
    bufferH64$ u_buf_is_eax_lg (.out(is_eax_big), .in(is_eax_raw));

    // ============================================================
    // Per-flag one-hot AND/OR (2 levels instead of 4-deep MUX cascade)
    //
    // is_al, is_ah, is_ax, is_eax are mutually exclusive (one-hot from CMP_N).
    // When none match, all AND outputs are 0 and the OR yields 0 — same default
    // behavior as the previous MUX_2 cascade.
    // ============================================================
    wire zf_w_t_al, zf_w_t_ah, zf_w_t_ax, zf_w_t_eax, zf_w;
    `AND_2(u_and_zfw_al,  1, zf_w_t_al,  al_zf,  is_al)
    `AND_2(u_and_zfw_ah,  1, zf_w_t_ah,  ah_zf,  is_ah)
    `AND_2(u_and_zfw_ax,  1, zf_w_t_ax,  ax_zf,  is_ax)
    `AND_2(u_and_zfw_eax, 1, zf_w_t_eax, eax_zf, is_eax)
    `OR_4(u_or_zfw,       1, zf_w, zf_w_t_al, zf_w_t_ah, zf_w_t_ax, zf_w_t_eax)

    wire sf_w_t_al, sf_w_t_ah, sf_w_t_ax, sf_w_t_eax, sf_w;
    `AND_2(u_and_sfw_al,  1, sf_w_t_al,  al_sf,  is_al)
    `AND_2(u_and_sfw_ah,  1, sf_w_t_ah,  ah_sf,  is_ah)
    `AND_2(u_and_sfw_ax,  1, sf_w_t_ax,  ax_sf,  is_ax)
    `AND_2(u_and_sfw_eax, 1, sf_w_t_eax, eax_sf, is_eax)
    `OR_4(u_or_sfw,       1, sf_w, sf_w_t_al, sf_w_t_ah, sf_w_t_ax, sf_w_t_eax)

    wire cf_w_t_al, cf_w_t_ah, cf_w_t_ax, cf_w_t_eax, cf_w;
    `AND_2(u_and_cfw_al,  1, cf_w_t_al,  al_cf,  is_al)
    `AND_2(u_and_cfw_ah,  1, cf_w_t_ah,  ah_cf,  is_ah)
    `AND_2(u_and_cfw_ax,  1, cf_w_t_ax,  ax_cf,  is_ax)
    `AND_2(u_and_cfw_eax, 1, cf_w_t_eax, eax_cf, is_eax)
    `OR_4(u_or_cfw,       1, cf_w, cf_w_t_al, cf_w_t_ah, cf_w_t_ax, cf_w_t_eax)

    wire pf_w_t_al, pf_w_t_ah, pf_w_t_ax, pf_w_t_eax, pf_w;
    `AND_2(u_and_pfw_al,  1, pf_w_t_al,  al_pf,  is_al)
    `AND_2(u_and_pfw_ah,  1, pf_w_t_ah,  ah_pf,  is_ah)
    `AND_2(u_and_pfw_ax,  1, pf_w_t_ax,  ax_pf,  is_ax)
    `AND_2(u_and_pfw_eax, 1, pf_w_t_eax, eax_pf, is_eax)
    `OR_4(u_or_pfw,       1, pf_w, pf_w_t_al, pf_w_t_ah, pf_w_t_ax, pf_w_t_eax)

    // ============================================================
    // count-zero override (preserve curr_*_flag); OF/AF: 0 when count > 0.
    // ============================================================
    wire is_count_zero;
    wire is_count_zero_big;
    wire is_count_zero_raw;
    `CMP_N(u_cmp_czero, 6, is_count_zero_raw, count, 6'd0)
    // is_count_zero has 70 leaf consumers split cleanly into two groups:
    //   - 6  flag muxes (1-bit each) below — fanout 6  → bufferH16$ (0.24 ns)
    //   - 1× 64-bit result mux           → fanout 64 → bufferH64$ (0.30 ns)
    // Splitting saves 0.30/0.24 ns vs a single bufferH256$ (0.54 ns) at the
    // cost of 1 extra cell. is_count_zero_raw has fanout 2 (the two buffers).
    bufferH16$ u_buf_iczero_sm (.out(is_count_zero),     .in(is_count_zero_raw));
    bufferH64$ u_buf_iczero_lg (.out(is_count_zero_big), .in(is_count_zero_raw));

    `MUX_2(u_mux_zf_final, 1, ZF, zf_w, curr_zf_flag, is_count_zero)
    `MUX_2(u_mux_sf_final, 1, SF, sf_w, curr_sf_flag, is_count_zero)
    `MUX_2(u_mux_cf_final, 1, CF, cf_w, curr_cf_flag, is_count_zero)
    `MUX_2(u_mux_pf_final, 1, PF, pf_w, curr_pf_flag, is_count_zero)
    `MUX_2(u_mux_of_final, 1, OF, 1'b0, curr_of_flag, is_count_zero)
    `MUX_2(u_mux_af_final, 1, AF, 1'b0, curr_af_flag, is_count_zero)

    // ============================================================
    // merged_result lanes (default = value_i; EAX zero-extends top 32 bits)
    // ============================================================
    wire [7:0] r_b0_s1, r_b0_s2, r_b0;
    `MUX_2(u_mux_rb0_1, 8, r_b0_s1, value_i[7:0], eax_res[7:0], is_eax)
    `MUX_2(u_mux_rb0_2, 8, r_b0_s2, r_b0_s1,      ax_res[7:0],  is_ax)
    `MUX_2(u_mux_rb0,   8, r_b0,    r_b0_s2,      al_res,        is_al)

    wire [7:0] r_b1_s1, r_b1_s2, r_b1;
    `MUX_2(u_mux_rb1_1, 8, r_b1_s1, value_i[15:8], eax_res[15:8], is_eax)
    `MUX_2(u_mux_rb1_2, 8, r_b1_s2, r_b1_s1,       ax_res[15:8],  is_ax)
    `MUX_2(u_mux_rb1,   8, r_b1,    r_b1_s2,       ah_res,         is_ah)

    wire [15:0] r_b23;
    `MUX_2(u_mux_rb23, 16, r_b23, value_i[31:16], eax_res[31:16], is_eax)

    wire [31:0] r_top;
    `MUX_2(u_mux_rtop, 32, r_top, value_i[63:32], 32'd0, is_eax_big)

    wire [63:0] result_pre;
    assign result_pre = {r_top, r_b23, r_b1, r_b0};

    wire [63:0] result;
    `MUX_2(u_mux_result, 64, result, result_pre, value_i, is_count_zero_big)

    assign dr_o      = result;
    assign res_buf_o = result;

endmodule
