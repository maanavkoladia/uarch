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
    wire [4:0] cnt_amt;
    `MUX_2(u_mux_cnt_amt, 5, cnt_amt, shift_amt_i[12:8], shift_amt_i[4:0], data_size[0])
    wire [5:0] count_pre;
    assign count_pre = {1'b0, cnt_amt};
    wire [5:0] count;
    `MUX_2(u_mux_count, 6, count, count_pre, 6'd1, shift_by_one)

    // ---- Sign bits per width ----
    wire al_sign  = value_i[7];
    wire ah_sign  = value_i[15];
    wire ax_sign  = value_i[15];
    wire eax_sign = value_i[31];

    // ---- 8-bit barrel right (AL) ----
    wire [7:0] al_in = value_i[7:0];
    wire [7:0] al_s0, al_s1, al_s2, al_s3, al_s4, al_res;
    `MUX_2(u_al_0, 8, al_s0, al_in, {al_sign,         al_in[7:1]},  count[0])
    `MUX_2(u_al_1, 8, al_s1, al_s0, {{2{al_sign}},    al_s0[7:2]},  count[1])
    `MUX_2(u_al_2, 8, al_s2, al_s1, {{4{al_sign}},    al_s1[7:4]},  count[2])
    `MUX_2(u_al_3, 8, al_s3, al_s2, {8{al_sign}},                   count[3])
    `MUX_2(u_al_4, 8, al_s4, al_s3, {8{al_sign}},                   count[4])
    `MUX_2(u_al_5, 8, al_res, al_s4,{8{al_sign}},                   count[5])

    // ---- 8-bit barrel right (AH) ----
    wire [7:0] ah_in = value_i[15:8];
    wire [7:0] ah_s0, ah_s1, ah_s2, ah_s3, ah_s4, ah_res;
    `MUX_2(u_ah_0, 8, ah_s0, ah_in, {ah_sign,         ah_in[7:1]},  count[0])
    `MUX_2(u_ah_1, 8, ah_s1, ah_s0, {{2{ah_sign}},    ah_s0[7:2]},  count[1])
    `MUX_2(u_ah_2, 8, ah_s2, ah_s1, {{4{ah_sign}},    ah_s1[7:4]},  count[2])
    `MUX_2(u_ah_3, 8, ah_s3, ah_s2, {8{ah_sign}},                   count[3])
    `MUX_2(u_ah_4, 8, ah_s4, ah_s3, {8{ah_sign}},                   count[4])
    `MUX_2(u_ah_5, 8, ah_res, ah_s4,{8{ah_sign}},                   count[5])

    // ---- 16-bit barrel right (AX) ----
    wire [15:0] ax_in = value_i[15:0];
    wire [15:0] ax_s0, ax_s1, ax_s2, ax_s3, ax_s4, ax_res;
    `MUX_2(u_ax_0, 16, ax_s0, ax_in, {ax_sign,         ax_in[15:1]}, count[0])
    `MUX_2(u_ax_1, 16, ax_s1, ax_s0, {{2{ax_sign}},    ax_s0[15:2]}, count[1])
    `MUX_2(u_ax_2, 16, ax_s2, ax_s1, {{4{ax_sign}},    ax_s1[15:4]}, count[2])
    `MUX_2(u_ax_3, 16, ax_s3, ax_s2, {{8{ax_sign}},    ax_s2[15:8]}, count[3])
    `MUX_2(u_ax_4, 16, ax_s4, ax_s3, {16{ax_sign}},                   count[4])
    `MUX_2(u_ax_5, 16, ax_res, ax_s4,{16{ax_sign}},                   count[5])

    // ---- 32-bit barrel right (EAX) ----
    wire [31:0] eax_in = value_i[31:0];
    wire [31:0] eax_s0, eax_s1, eax_s2, eax_s3, eax_s4, eax_res;
    `MUX_2(u_eax_0, 32, eax_s0, eax_in, {eax_sign,         eax_in[31:1]},  count[0])
    `MUX_2(u_eax_1, 32, eax_s1, eax_s0, {{2{eax_sign}},    eax_s0[31:2]},  count[1])
    `MUX_2(u_eax_2, 32, eax_s2, eax_s1, {{4{eax_sign}},    eax_s1[31:4]},  count[2])
    `MUX_2(u_eax_3, 32, eax_s3, eax_s2, {{8{eax_sign}},    eax_s2[31:8]},  count[3])
    `MUX_2(u_eax_4, 32, eax_s4, eax_s3, {{16{eax_sign}},   eax_s3[31:16]}, count[4])
    `MUX_2(u_eax_5, 32, eax_res, eax_s4,{32{eax_sign}},                    count[5])

    // ============================================================
    // CF per width (variable bit-select with saturation to sign bit)
    // ============================================================
    wire [2:0] cnt_lo3 = count[2:0];
    wire [3:0] cnt_lo4 = count[3:0];
    wire [4:0] cnt_lo5 = count[4:0];

    // AL: in0 = value_i[7] (count=0 or count=8), inI = value_i[I-1]
    wire al_cf_inner;
    `MUX_8(u_mux_al_cf, 1, al_cf_inner,
        value_i[7], value_i[0], value_i[1], value_i[2],
        value_i[3], value_i[4], value_i[5], value_i[6],
        cnt_lo3)
    wire al_count_ge8;
    `OR_3(u_or_al_ge8, 1, al_count_ge8, count[5], count[4], count[3])
    wire al_cf;
    `MUX_2(u_mux_al_cfsat, 1, al_cf, al_cf_inner, value_i[7], al_count_ge8)

    // AH: in0 = value_i[15] (count=0 or count=8), inI = value_i[7+I]
    wire ah_cf_inner;
    `MUX_8(u_mux_ah_cf, 1, ah_cf_inner,
        value_i[15], value_i[8],  value_i[9],  value_i[10],
        value_i[11], value_i[12], value_i[13], value_i[14],
        cnt_lo3)
    wire ah_count_ge8;
    `OR_3(u_or_ah_ge8, 1, ah_count_ge8, count[5], count[4], count[3])
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
    wire ax_count_ge16;
    `OR_2(u_or_ax_ge16, 1, ax_count_ge16, count[5], count[4])
    wire ax_cf;
    `MUX_2(u_mux_ax_cfsat, 1, ax_cf, ax_cf_inner, value_i[15], ax_count_ge16)

    // EAX: in0 = value_i[31], inI = value_i[I-1]
    wire eax_cf_inner;
    `MUX_32(u_mux_eax_cf, 1, eax_cf_inner,
        value_i[31], value_i[0],  value_i[1],  value_i[2],
        value_i[3],  value_i[4],  value_i[5],  value_i[6],
        value_i[7],  value_i[8],  value_i[9],  value_i[10],
        value_i[11], value_i[12], value_i[13], value_i[14],
        value_i[15], value_i[16], value_i[17], value_i[18],
        value_i[19], value_i[20], value_i[21], value_i[22],
        value_i[23], value_i[24], value_i[25], value_i[26],
        value_i[27], value_i[28], value_i[29], value_i[30],
        cnt_lo5)
    wire eax_cf;
    `MUX_2(u_mux_eax_cfsat, 1, eax_cf, eax_cf_inner, value_i[31], count[5])

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
    wire is_al, is_ah, is_ax, is_eax;
    `CMP_N(u_cmp_al,  4, is_al,  data_size, 4'b0001)
    `CMP_N(u_cmp_ah,  4, is_ah,  data_size, 4'b0010)
    `CMP_N(u_cmp_ax,  4, is_ax,  data_size, 4'b0011)
    `CMP_N(u_cmp_eax, 4, is_eax, data_size, 4'b0111)

    // ============================================================
    // Per-flag width mux (default 0, count > 0)
    // ============================================================
    wire zf_w_s1, zf_w_s2, zf_w_s3, zf_w;
    `MUX_2(u_mux_zfw_1, 1, zf_w_s1, 1'b0,    eax_zf, is_eax)
    `MUX_2(u_mux_zfw_2, 1, zf_w_s2, zf_w_s1, ax_zf,  is_ax)
    `MUX_2(u_mux_zfw_3, 1, zf_w_s3, zf_w_s2, ah_zf,  is_ah)
    `MUX_2(u_mux_zfw,   1, zf_w,    zf_w_s3, al_zf,  is_al)

    wire sf_w_s1, sf_w_s2, sf_w_s3, sf_w;
    `MUX_2(u_mux_sfw_1, 1, sf_w_s1, 1'b0,    eax_sf, is_eax)
    `MUX_2(u_mux_sfw_2, 1, sf_w_s2, sf_w_s1, ax_sf,  is_ax)
    `MUX_2(u_mux_sfw_3, 1, sf_w_s3, sf_w_s2, ah_sf,  is_ah)
    `MUX_2(u_mux_sfw,   1, sf_w,    sf_w_s3, al_sf,  is_al)

    wire cf_w_s1, cf_w_s2, cf_w_s3, cf_w;
    `MUX_2(u_mux_cfw_1, 1, cf_w_s1, 1'b0,    eax_cf, is_eax)
    `MUX_2(u_mux_cfw_2, 1, cf_w_s2, cf_w_s1, ax_cf,  is_ax)
    `MUX_2(u_mux_cfw_3, 1, cf_w_s3, cf_w_s2, ah_cf,  is_ah)
    `MUX_2(u_mux_cfw,   1, cf_w,    cf_w_s3, al_cf,  is_al)

    wire pf_w_s1, pf_w_s2, pf_w_s3, pf_w;
    `MUX_2(u_mux_pfw_1, 1, pf_w_s1, 1'b0,    eax_pf, is_eax)
    `MUX_2(u_mux_pfw_2, 1, pf_w_s2, pf_w_s1, ax_pf,  is_ax)
    `MUX_2(u_mux_pfw_3, 1, pf_w_s3, pf_w_s2, ah_pf,  is_ah)
    `MUX_2(u_mux_pfw,   1, pf_w,    pf_w_s3, al_pf,  is_al)

    // ============================================================
    // count-zero override (preserve curr_*_flag); OF/AF: 0 when count > 0.
    // ============================================================
    wire is_count_zero;
    `CMP_N(u_cmp_czero, 6, is_count_zero, count, 6'd0)

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
    `MUX_2(u_mux_rtop, 32, r_top, value_i[63:32], 32'd0, is_eax)

    wire [63:0] result_pre;
    assign result_pre = {r_top, r_b23, r_b1, r_b0};

    wire [63:0] result;
    `MUX_2(u_mux_result, 64, result, result_pre, value_i, is_count_zero)

    assign dr_o      = result;
    assign res_buf_o = result;

endmodule
