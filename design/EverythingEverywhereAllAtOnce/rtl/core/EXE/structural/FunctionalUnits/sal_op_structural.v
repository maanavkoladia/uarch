// Structural Verilog 2005 port of EXE/FunctionalUnits/sal_op.sv
//
// 6-stage barrel left-shift. Two shifters: a 64-bit one on value_i (gives
// AL/AX/EAX result and CF for free as bit 8/16/32), and a 16-bit one on
// {8'd0, value_i[15:8]} for AH (so the AL→AH carry doesn't leak).
//
// Count source: shift_by_one→1, else  data_size[0] ? shift_amt[4:0] : shift_amt[12:8].
//
// Flag semantics:
//   count == 0: all flags = curr_*_flag (preserved); result = value_i.
//   count >  0: AF = 0; OF = (count==1) ? (result[N-1] XOR CF) : 0;
//               ZF/SF/CF/PF derived per-width from the appropriate shift slice.
//   For data_size = EAX, result[63:32] is forced to 0 (zero-extend).

module sal_op (
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
    // Per Intel SAL/SHL spec: "count is masked to 5 bits, range 0 to 31".
    // count[5] is therefore always 0 by ISA contract -- the previous 6th
    // barrel-shift stage (shift-by-32) was dead logic and is removed below,
    // saving one MUX level on the entire result/flag critical path.
    wire [4:0] cnt_amt;
    `MUX_2(u_mux_cnt_amt, 5, cnt_amt, shift_amt_i[12:8], shift_amt_i[4:0], data_size[0])
    wire [5:0] count_pre;
    assign count_pre = {1'b0, cnt_amt};
    wire [5:0] count;          // cmp/comparator path (low fanout)
    wire [4:0] count_sh64;     // sh64 cascade selects (64 loads/bit)
    wire [4:0] count_sh16;     // sh16 cascade selects (16 loads/bit)
    wire [5:0] count_raw;
    `MUX_2(u_mux_count, 6, count_raw, count_pre, 6'd1, shift_by_one)

    // Split the per-bit fanout into three buffered taps so each driver fights
    // a smaller load instead of one 0.54 ns bufferH256$:
    //   sh64 cascade (64 loads/bit) -> bufferH64$  (0.30 ns)
    //   sh16 cascade (16 loads/bit) -> bufferH16$  (0.24 ns)
    //   is_count_one + is_count_zero CMPs -> bufferH16$  (0.24 ns)
    genvar gi_buf_cnt;
    generate
        for (gi_buf_cnt = 0; gi_buf_cnt < 5; gi_buf_cnt = gi_buf_cnt + 1) begin : g_count_buf_sh
            bufferH64$ u_buf_cnt_sh64 (
                .out(count_sh64[gi_buf_cnt]),
                .in (count_raw[gi_buf_cnt]));
            bufferH16$ u_buf_cnt_sh16 (
                .out(count_sh16[gi_buf_cnt]),
                .in (count_raw[gi_buf_cnt]));
        end
        for (gi_buf_cnt = 0; gi_buf_cnt < 6; gi_buf_cnt = gi_buf_cnt + 1) begin : g_count_buf_cmp
            bufferH16$ u_buf_cnt_cmp (
                .out(count[gi_buf_cnt]),
                .in (count_raw[gi_buf_cnt]));
        end
    endgenerate

    // ---- 64-bit barrel left shift of value_i ----
    // 5 stages cover shift amounts 0..31 (max per Intel spec for a 32-bit
    // operand).  Stage-by-32 was always pass-through (count[5]==0) so removed.
    wire [63:0] sh64_s0, sh64_s1, sh64_s2, sh64_s3, sh64;
    wire [63:0] sh64_raw;
    `MUX_2(u_sh64_0, 64, sh64_s0,  value_i, {value_i[62:0],  1'b0}, count_sh64[0])
    `MUX_2(u_sh64_1, 64, sh64_s1,  sh64_s0, {sh64_s0[61:0],  2'b0}, count_sh64[1])
    `MUX_2(u_sh64_2, 64, sh64_s2,  sh64_s1, {sh64_s1[59:0],  4'b0}, count_sh64[2])
    `MUX_2(u_sh64_3, 64, sh64_s3,  sh64_s2, {sh64_s2[55:0],  8'b0}, count_sh64[3])
    `MUX_2(u_sh64_4, 64, sh64_raw, sh64_s3, {sh64_s3[47:0], 16'b0}, count_sh64[4])

    // sh64 bits feed flag reductions, byte-lane muxes, and individual flag
    // bits — worst per-bit fanout ~11. bufferH16$ (0.24 ns) is the right size.
    genvar gi_buf_sh;
    generate
        for (gi_buf_sh = 0; gi_buf_sh < 64; gi_buf_sh = gi_buf_sh + 1) begin : g_sh64_buf
            bufferH16$ u_buf_sh (.out(sh64[gi_buf_sh]), .in(sh64_raw[gi_buf_sh]));
        end
    endgenerate

    // ---- 16-bit barrel left shift of {8'd0, value_i[15:8]} (for AH) ----
    // Same: 5 stages cover shift 0..31; the dead stage 5 is removed.
    wire [15:0] ah_in;
    assign ah_in = {8'd0, value_i[15:8]};
    wire [15:0] sh16_s0, sh16_s1, sh16_s2, sh16_s3, sh16_raw, sh16;
    wire        sh16_b7_buf;
    `MUX_2(u_sh16_0, 16, sh16_s0,  ah_in,    {ah_in[14:0],   1'b0}, count_sh16[0])
    `MUX_2(u_sh16_1, 16, sh16_s1,  sh16_s0,  {sh16_s0[13:0], 2'b0}, count_sh16[1])
    `MUX_2(u_sh16_2, 16, sh16_s2,  sh16_s1,  {sh16_s1[11:0], 4'b0}, count_sh16[2])
    `MUX_2(u_sh16_3, 16, sh16_s3,  sh16_s2,  {sh16_s2[7:0],  8'b0}, count_sh16[3])
    `MUX_2(u_sh16_4, 16, sh16_raw, sh16_s3,  16'b0,                count_sh16[4])

    // Only sh16[7] (sign bit) has fanout 5 — buffer just that bit so other
    // bits don't pay buffer delay.
    bufferH16$ u_buf_sh16_b7 (.out(sh16_b7_buf), .in(sh16_raw[7]));
    assign sh16 = {sh16_raw[15:8], sh16_b7_buf, sh16_raw[6:0]};

    // ---- Per-width raw flags / result candidates ----
    // CF: bit shifted out (= bit at position N of the extended-width shift).
    wire al_cf  = sh64[8];
    wire ah_cf  = sh16[8];
    wire ax_cf  = sh64[16];
    wire eax_cf = sh64[32];

    // SF: top bit of the lane result.
    wire al_sf  = sh64[7];
    wire ah_sf  = sh16[7];
    wire ax_sf  = sh64[15];
    wire eax_sf = sh64[31];

    // ZF: NOR over result lane bits.
    wire al_zf, ah_zf, ax_zf, eax_zf;
    zf_red_8  u_zf_al  (.x(sh64[7:0]),  .z(al_zf));
    zf_red_8  u_zf_ah  (.x(sh16[7:0]),  .z(ah_zf));
    zf_red_16 u_zf_ax  (.x(sh64[15:0]), .z(ax_zf));
    zf_red_32 u_zf_eax (.x(sh64[31:0]), .z(eax_zf));

    // PF: AL/AX/EAX use sh64[7:0]; AH uses sh16[7:0].
    wire al_pf, ah_pf, ax_pf, eax_pf;
    pf_red_8 u_pf_al  (.x(sh64[7:0]), .p(al_pf));
    pf_red_8 u_pf_ah  (.x(sh16[7:0]), .p(ah_pf));
    pf_red_8 u_pf_ax  (.x(sh64[7:0]), .p(ax_pf));
    pf_red_8 u_pf_eax (.x(sh64[7:0]), .p(eax_pf));

    // OF (count > 0): count == 1 ? (result_msb XOR CF) : 0.
    wire is_count_one;
    `CMP_N(u_cmp_cone, 6, is_count_one, count, 6'd1)
    wire al_of_x, ah_of_x, ax_of_x, eax_of_x;
    `XOR_2(u_xor_al_of,  1, al_of_x,  al_sf,  al_cf)
    `XOR_2(u_xor_ah_of,  1, ah_of_x,  ah_sf,  ah_cf)
    `XOR_2(u_xor_ax_of,  1, ax_of_x,  ax_sf,  ax_cf)
    `XOR_2(u_xor_eax_of, 1, eax_of_x, eax_sf, eax_cf)
    wire al_of, ah_of, ax_of, eax_of;
    `MUX_2(u_mux_al_of,  1, al_of,  1'b0, al_of_x,  is_count_one)
    `MUX_2(u_mux_ah_of,  1, ah_of,  1'b0, ah_of_x,  is_count_one)
    `MUX_2(u_mux_ax_of,  1, ax_of,  1'b0, ax_of_x,  is_count_one)
    `MUX_2(u_mux_eax_of, 1, eax_of, 1'b0, eax_of_x, is_count_one)

    // ---- data_size selectors ----
    wire is_al, is_ah, is_ax, is_eax, is_eax_big;
    wire is_al_raw, is_ah_raw, is_ax_raw, is_eax_raw;
    `CMP_N(u_cmp_al,  4, is_al_raw,  data_size, 4'b0001)
    `CMP_N(u_cmp_ah,  4, is_ah_raw,  data_size, 4'b0010)
    `CMP_N(u_cmp_ax,  4, is_ax_raw,  data_size, 4'b0011)
    `CMP_N(u_cmp_eax, 4, is_eax_raw, data_size, 4'b0111)
    // Per-fanout sizing.
    // is_al/ah=13 → H16. is_ax=21 fits H64 single-cell (0.30 ns).
    // is_eax fanout 69 = u_mux_rtop(32) + rb23(16) + rb0_1(8) + rb1_1(8) + 5
    // flag muxes. Single bufferH256$ would be 0.54 ns. Split:
    //   - is_eax_big drives u_mux_rtop  (32 loads) — bufferH64$ (0.30 ns)
    //   - is_eax     drives 37 others   (rb23+rb0_1+rb1_1+flag muxes)
    //                                    — bufferH64$ (0.30 ns)
    // Saves 0.24 ns on rtop path (which is the longest data path here).
    bufferH16$ u_buf_is_al      (.out(is_al),      .in(is_al_raw));
    bufferH16$ u_buf_is_ah      (.out(is_ah),      .in(is_ah_raw));
    bufferH64$ u_buf_is_ax      (.out(is_ax),      .in(is_ax_raw));
    bufferH64$ u_buf_is_eax_sm  (.out(is_eax),     .in(is_eax_raw));
    bufferH64$ u_buf_is_eax_lg  (.out(is_eax_big), .in(is_eax_raw));

    // ---- Per-flag one-hot AND/OR (2 levels instead of 4-deep MUX cascade) ----
    // is_al, is_ah, is_ax, is_eax are mutually exclusive (one-hot from CMP_N).
    // When none match, all AND outputs are 0 and the OR yields 0 — same default
    // as the previous MUX_2 cascade.
    //
    //   was: 4-deep MUX_2 cascade per flag                  (4 levels)
    //   now: zf_w = (is_al & al_zf) | (is_ah & ah_zf)
    //              | (is_ax & ax_zf) | (is_eax & eax_zf)   (2 levels)

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

    wire of_w_t_al, of_w_t_ah, of_w_t_ax, of_w_t_eax, of_w;
    `AND_2(u_and_ofw_al,  1, of_w_t_al,  al_of,  is_al)
    `AND_2(u_and_ofw_ah,  1, of_w_t_ah,  ah_of,  is_ah)
    `AND_2(u_and_ofw_ax,  1, of_w_t_ax,  ax_of,  is_ax)
    `AND_2(u_and_ofw_eax, 1, of_w_t_eax, eax_of, is_eax)
    `OR_4(u_or_ofw,       1, of_w, of_w_t_al, of_w_t_ah, of_w_t_ax, of_w_t_eax)

    // ---- count-zero override ----
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

    // count==0 → curr_*; else width-muxed value (AF is 0 when count > 0).
    `MUX_2(u_mux_zf_final, 1, ZF, zf_w, curr_zf_flag, is_count_zero)
    `MUX_2(u_mux_sf_final, 1, SF, sf_w, curr_sf_flag, is_count_zero)
    `MUX_2(u_mux_cf_final, 1, CF, cf_w, curr_cf_flag, is_count_zero)
    `MUX_2(u_mux_pf_final, 1, PF, pf_w, curr_pf_flag, is_count_zero)
    `MUX_2(u_mux_of_final, 1, OF, of_w, curr_of_flag, is_count_zero)
    `MUX_2(u_mux_af_final, 1, AF, 1'b0, curr_af_flag, is_count_zero)

    // ---- merged_result lanes (default = value_i; EAX zero-extends top) ----
    wire [7:0] r_b0_s1, r_b0_s2, r_b0;
    `MUX_2(u_mux_rb0_1, 8, r_b0_s1, value_i[7:0], sh64[7:0], is_eax)
    `MUX_2(u_mux_rb0_2, 8, r_b0_s2, r_b0_s1,      sh64[7:0], is_ax)
    `MUX_2(u_mux_rb0,   8, r_b0,    r_b0_s2,      sh64[7:0], is_al)

    wire [7:0] r_b1_s1, r_b1_s2, r_b1;
    `MUX_2(u_mux_rb1_1, 8, r_b1_s1, value_i[15:8], sh64[15:8], is_eax)
    `MUX_2(u_mux_rb1_2, 8, r_b1_s2, r_b1_s1,       sh64[15:8], is_ax)
    `MUX_2(u_mux_rb1,   8, r_b1,    r_b1_s2,       sh16[7:0],  is_ah)

    wire [15:0] r_b23;
    `MUX_2(u_mux_rb23, 16, r_b23, value_i[31:16], sh64[31:16], is_eax)

    wire [31:0] r_top;
    `MUX_2(u_mux_rtop, 32, r_top, value_i[63:32], 32'd0, is_eax_big)

    wire [63:0] result_pre;
    assign result_pre = {r_top, r_b23, r_b1, r_b0};

    // count == 0 → result = value_i (overrides any EAX zero-extension).
    wire [63:0] result;
    `MUX_2(u_mux_result, 64, result, result_pre, value_i, is_count_zero_big)

    assign dr_o      = result;
    assign res_buf_o = result;

endmodule
