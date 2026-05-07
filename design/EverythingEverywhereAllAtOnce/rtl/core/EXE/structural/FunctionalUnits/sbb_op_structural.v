// Structural Verilog 2005 port of EXE/FunctionalUnits/sbb_op.sv
//
// Subtract-with-borrow: A - B - CF_in == A + ~B + ~CF_in.
// Width-isolated subtractors at 8/8/16/32; CF (borrow) = ~carry_at_top_bit.
// Per-data_size flag derivation; merged_result updates only the affected lane.
// AH AF references srA[12]/srB[12] (preserves SV ref's bit indices for AH).

module sbb_op (
    input  wire [63:0] srA,
    input  wire [63:0] srB,
    input  wire        CF_in,
    input  wire [3:0]  data_size,
    output wire [63:0] dr_o,
    output wire [63:0] res_buf_o,
    output wire        CF,
    output wire        PF,
    output wire        AF,
    output wire        ZF,
    output wire        SF,
    output wire        OF
);

    wire CF_in_inv;
    `INV_N(u_inv_cfin, 1, CF_in, CF_in_inv)

    // ---- 4 width-isolated subtractors ----
    // AL (8-bit slice → 9-bit sum)
    wire [7:0] srB_al_inv;
    `INV_N(u_inv_al_b, 8, srB[7:0], srB_al_inv)
    wire [8:0] al_sum_raw; wire al_cout;
    wire [8:0] al_sum;     wire al_sum_b7_buf;
    `ADD_N(u_sub_al, 9, al_sum_raw, al_cout, {1'b0, srA[7:0]}, {1'b0, srB_al_inv}, CF_in_inv)
    // Only al_sum[7] (sign bit) has fanout 5 — buffer just that bit.
    bufferH16$ u_buf_al_sum_b7 (.out(al_sum_b7_buf), .in(al_sum_raw[7]));
    assign al_sum = {al_sum_raw[8], al_sum_b7_buf, al_sum_raw[6:0]};

    // AH (8-bit slice → 9-bit sum)
    wire [7:0] srB_ah_inv;
    `INV_N(u_inv_ah_b, 8, srB[15:8], srB_ah_inv)
    wire [8:0] ah_sum_raw; wire ah_cout;
    wire [8:0] ah_sum;     wire ah_sum_b7_buf;
    `ADD_N(u_sub_ah, 9, ah_sum_raw, ah_cout, {1'b0, srA[15:8]}, {1'b0, srB_ah_inv}, CF_in_inv)
    bufferH16$ u_buf_ah_sum_b7 (.out(ah_sum_b7_buf), .in(ah_sum_raw[7]));
    assign ah_sum = {ah_sum_raw[8], ah_sum_b7_buf, ah_sum_raw[6:0]};

    // AX (16-bit slice → 17-bit sum)
    wire [15:0] srB_ax_inv;
    `INV_N(u_inv_ax_b, 16, srB[15:0], srB_ax_inv)
    wire [16:0] ax_sum; wire ax_cout;
    `ADD_N(u_sub_ax, 17, ax_sum, ax_cout, {1'b0, srA[15:0]}, {1'b0, srB_ax_inv}, CF_in_inv)

    // EAX (32-bit slice → 33-bit sum)
    wire [31:0] srB_eax_inv;
    `INV_N(u_inv_eax_b, 32, srB[31:0], srB_eax_inv)
    wire [32:0] eax_sum; wire eax_cout;
    `ADD_N(u_sub_eax, 33, eax_sum, eax_cout, {1'b0, srA[31:0]}, {1'b0, srB_eax_inv}, CF_in_inv)

    // ---- data_size selectors ----
    wire is_al, is_ah, is_ax, is_eax;
    wire is_al_raw, is_ah_raw, is_ax_raw;
    `CMP_N(u_cmp_al,  4, is_al_raw,  data_size, 4'b0001)
    `CMP_N(u_cmp_ah,  4, is_ah_raw,  data_size, 4'b0010)
    `CMP_N(u_cmp_ax,  4, is_ax_raw,  data_size, 4'b0011)
    // Per-fanout sizing: al/ah=14 → H16; ax=22 → H64.
    bufferH16$ u_buf_is_al (.out(is_al), .in(is_al_raw));
    bufferH16$ u_buf_is_ah (.out(is_ah), .in(is_ah_raw));
    bufferH64$ u_buf_is_ax (.out(is_ax), .in(is_ax_raw));
    wire is_eax_raw;
    `CMP_N(u_cmp_eax, 4, is_eax_raw, data_size, 4'b0111)
    // is_eax fans out to 38 mux selects across the EAX result paths.
    // bufferH64$ (rated 64, 0.30 ns) is the smallest fit; bufferH16$ rated 16.
    bufferH64$ u_buf_is_eax (.out(is_eax), .in(is_eax_raw));

    // ---- merged_result lanes (default = srA[31:0]) ----
    // Lane 0: AL/AX/EAX update from sum; AH/default = srA[7:0]
    wire [7:0] l0_s1, l0_s2;
    `MUX_2(u_mux_l0_1, 8, l0_s1, srA[7:0], eax_sum[7:0], is_eax)
    `MUX_2(u_mux_l0_2, 8, l0_s2, l0_s1,    ax_sum[7:0],  is_ax)
    wire [7:0] lane0;
    `MUX_2(u_mux_l0,   8, lane0, l0_s2,    al_sum[7:0],  is_al)

    // Lane 1: AH/AX/EAX update; AL/default = srA[15:8]
    wire [7:0] l1_s1, l1_s2;
    `MUX_2(u_mux_l1_1, 8, l1_s1, srA[15:8], eax_sum[15:8], is_eax)
    `MUX_2(u_mux_l1_2, 8, l1_s2, l1_s1,     ax_sum[15:8],  is_ax)
    wire [7:0] lane1;
    `MUX_2(u_mux_l1,   8, lane1, l1_s2,     ah_sum[7:0],   is_ah)

    // Lane 2-3: EAX updates; default = srA[31:16]
    wire [15:0] lane23;
    `MUX_2(u_mux_l23, 16, lane23, srA[31:16], eax_sum[31:16], is_eax)

    wire [31:0] merged_result;
    assign merged_result = {lane23, lane1, lane0};

    assign dr_o      = {32'd0, merged_result};
    assign res_buf_o = {32'd0, merged_result};

    // ---- ZF / PF per width ----
    wire al_zf, ah_zf, ax_zf, eax_zf;
    zf_red_8  u_zf_al  (.x(al_sum[7:0]),   .z(al_zf));
    zf_red_8  u_zf_ah  (.x(ah_sum[7:0]),   .z(ah_zf));
    zf_red_16 u_zf_ax  (.x(ax_sum[15:0]),  .z(ax_zf));
    zf_red_32 u_zf_eax (.x(eax_sum[31:0]), .z(eax_zf));

    wire al_pf, ah_pf, ax_pf, eax_pf;
    pf_red_8 u_pf_al  (.x(al_sum[7:0]),  .p(al_pf));
    pf_red_8 u_pf_ah  (.x(ah_sum[7:0]),  .p(ah_pf));
    pf_red_8 u_pf_ax  (.x(ax_sum[7:0]),  .p(ax_pf));
    pf_red_8 u_pf_eax (.x(eax_sum[7:0]), .p(eax_pf));

    // ---- SF / CF (CF for sub = ~cout-bit at top of widened sum) ----
    wire al_sf  = al_sum[7];
    wire ah_sf  = ah_sum[7];
    wire ax_sf  = ax_sum[15];
    wire eax_sf = eax_sum[31];

    wire al_cf, ah_cf, ax_cf, eax_cf;
    `INV_N(u_inv_al_cf,  1, al_sum[8],   al_cf)
    `INV_N(u_inv_ah_cf,  1, ah_sum[8],   ah_cf)
    `INV_N(u_inv_ax_cf,  1, ax_sum[16],  ax_cf)
    `INV_N(u_inv_eax_cf, 1, eax_sum[32], eax_cf)

    // ---- OF for SUB: (A_msb XOR B_msb) AND (A_msb XOR sum_msb) ----
    wire al_xab, al_xas, al_of;
    `XOR_2(u_xor_al_ab, 1, al_xab, srA[7], srB[7])
    `XOR_2(u_xor_al_as, 1, al_xas, srA[7], al_sum[7])
    `AND_2(u_and_al_of, 1, al_of, al_xab, al_xas)

    wire ah_xab, ah_xas, ah_of;
    `XOR_2(u_xor_ah_ab, 1, ah_xab, srA[15], srB[15])
    `XOR_2(u_xor_ah_as, 1, ah_xas, srA[15], ah_sum[7])
    `AND_2(u_and_ah_of, 1, ah_of, ah_xab, ah_xas)

    wire ax_xab, ax_xas, ax_of;
    `XOR_2(u_xor_ax_ab, 1, ax_xab, srA[15], srB[15])
    `XOR_2(u_xor_ax_as, 1, ax_xas, srA[15], ax_sum[15])
    `AND_2(u_and_ax_of, 1, ax_of, ax_xab, ax_xas)

    wire eax_xab, eax_xas, eax_of;
    `XOR_2(u_xor_eax_ab, 1, eax_xab, srA[31], srB[31])
    `XOR_2(u_xor_eax_as, 1, eax_xas, srA[31], eax_sum[31])
    `AND_2(u_and_eax_of, 1, eax_of, eax_xab, eax_xas)

    // ---- AF: A[bit] XOR B[bit] XOR sum[bit]  (AH uses bits 12 of A/B per SV) ----
    wire al_af_t, al_af;
    `XOR_2(u_xor_al_aft, 1, al_af_t, srA[4], srB[4])
    `XOR_2(u_xor_al_af,  1, al_af,   al_af_t, al_sum[4])

    wire ah_af_t, ah_af;
    `XOR_2(u_xor_ah_aft, 1, ah_af_t, srA[12], srB[12])
    `XOR_2(u_xor_ah_af,  1, ah_af,   ah_af_t, ah_sum[4])

    wire ax_af_t, ax_af;
    `XOR_2(u_xor_ax_aft, 1, ax_af_t, srA[4], srB[4])
    `XOR_2(u_xor_ax_af,  1, ax_af,   ax_af_t, ax_sum[4])

    wire eax_af_t, eax_af;
    `XOR_2(u_xor_eax_aft, 1, eax_af_t, srA[4], srB[4])
    `XOR_2(u_xor_eax_af,  1, eax_af,   eax_af_t, eax_sum[4])

    // ---- Per-flag mux chain (default 0) ----
    wire zf_s1, zf_s2, zf_s3;
    `MUX_2(u_mux_zf_1, 1, zf_s1, 1'b0,  eax_zf, is_eax)
    `MUX_2(u_mux_zf_2, 1, zf_s2, zf_s1, ax_zf,  is_ax)
    `MUX_2(u_mux_zf_3, 1, zf_s3, zf_s2, ah_zf,  is_ah)
    `MUX_2(u_mux_zf,   1, ZF,    zf_s3, al_zf,  is_al)

    wire sf_s1, sf_s2, sf_s3;
    `MUX_2(u_mux_sf_1, 1, sf_s1, 1'b0,  eax_sf, is_eax)
    `MUX_2(u_mux_sf_2, 1, sf_s2, sf_s1, ax_sf,  is_ax)
    `MUX_2(u_mux_sf_3, 1, sf_s3, sf_s2, ah_sf,  is_ah)
    `MUX_2(u_mux_sf,   1, SF,    sf_s3, al_sf,  is_al)

    wire cf_s1, cf_s2, cf_s3;
    `MUX_2(u_mux_cf_1, 1, cf_s1, 1'b0,  eax_cf, is_eax)
    `MUX_2(u_mux_cf_2, 1, cf_s2, cf_s1, ax_cf,  is_ax)
    `MUX_2(u_mux_cf_3, 1, cf_s3, cf_s2, ah_cf,  is_ah)
    `MUX_2(u_mux_cf,   1, CF,    cf_s3, al_cf,  is_al)

    wire pf_s1, pf_s2, pf_s3;
    `MUX_2(u_mux_pf_1, 1, pf_s1, 1'b0,  eax_pf, is_eax)
    `MUX_2(u_mux_pf_2, 1, pf_s2, pf_s1, ax_pf,  is_ax)
    `MUX_2(u_mux_pf_3, 1, pf_s3, pf_s2, ah_pf,  is_ah)
    `MUX_2(u_mux_pf,   1, PF,    pf_s3, al_pf,  is_al)

    wire of_s1, of_s2, of_s3;
    `MUX_2(u_mux_of_1, 1, of_s1, 1'b0,  eax_of, is_eax)
    `MUX_2(u_mux_of_2, 1, of_s2, of_s1, ax_of,  is_ax)
    `MUX_2(u_mux_of_3, 1, of_s3, of_s2, ah_of,  is_ah)
    `MUX_2(u_mux_of,   1, OF,    of_s3, al_of,  is_al)

    wire af_s1, af_s2, af_s3;
    `MUX_2(u_mux_af_1, 1, af_s1, 1'b0,  eax_af, is_eax)
    `MUX_2(u_mux_af_2, 1, af_s2, af_s1, ax_af,  is_ax)
    `MUX_2(u_mux_af_3, 1, af_s3, af_s2, ah_af,  is_ah)
    `MUX_2(u_mux_af,   1, AF,    af_s3, al_af,  is_al)

endmodule
