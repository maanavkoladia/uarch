// Structural Verilog 2005 port of EXE/FunctionalUnits/add_op.sv
//
// Width-isolated adders for AL/AH/AX/EAX (matches the SV ref's avoidance of
// AH carry contamination). Per-data_size flag derivation; merged_result
// updates only the affected lane(s).
//
// data_size:
//   4'b0001 → AL  (lane 0,  bits [7:0])
//   4'b0010 → AH  (lane 1,  bits [15:8])
//   4'b0011 → AX  (lanes 0–1, bits [15:0])
//   4'b0111 → EAX (lanes 0–3, bits [31:0])
//   default → no update; flags = 0; merged_result = srA

module add_op (
    input  wire [63:0] srA,
    input  wire [63:0] srB,
    input  wire [3:0]  data_size,
    output wire [63:0] dr_o,
    output wire [63:0] res_buf_o,
    output wire        ZF,
    output wire        SF,
    output wire        PF,
    output wire        OF,
    output wire        CF,
    output wire        AF
);

    // ---- 4 width-isolated adders (each producing N+1-bit sum for CF tap) ----
    wire [8:0]  al_sum;   wire al_cout;
    `ADD_N(u_add_al, 9,  al_sum,  al_cout,  {1'b0, srA[7:0]},   {1'b0, srB[7:0]},   1'b0)

    wire [8:0]  ah_sum;   wire ah_cout;
    `ADD_N(u_add_ah, 9,  ah_sum,  ah_cout,  {1'b0, srA[15:8]},  {1'b0, srB[15:8]},  1'b0)

    wire [16:0] ax_sum;   wire ax_cout;
    `ADD_N(u_add_ax, 17, ax_sum,  ax_cout,  {1'b0, srA[15:0]},  {1'b0, srB[15:0]},  1'b0)

    wire [32:0] eax_sum;  wire eax_cout;
    `ADD_N(u_add_eax, 33, eax_sum, eax_cout, {1'b0, srA[31:0]}, {1'b0, srB[31:0]}, 1'b0)

    // ---- AF: 4-bit nibble add, AF = carry into bit 4 ----
    wire [4:0] af_sum;    wire af_cout;
    `ADD_N(u_add_af, 5, af_sum, af_cout, {1'b0, srA[3:0]}, {1'b0, srB[3:0]}, 1'b0)
    assign AF = af_sum[4];

    // ---- data_size selectors ----
    wire is_al, is_ah, is_ax, is_eax;
    `CMP_N(u_cmp_al,  4, is_al,  data_size, 4'b0001)
    `CMP_N(u_cmp_ah,  4, is_ah,  data_size, 4'b0010)
    `CMP_N(u_cmp_ax,  4, is_ax,  data_size, 4'b0011)
    `CMP_N(u_cmp_eax, 4, is_eax, data_size, 4'b0111)

    // ---- merged_result lanes ----
    // Lane 0 (bits [7:0]): srA / al_sum / ax_sum / eax_sum
    wire [7:0] l0_s1, l0_s2;
    `MUX_2(u_mux_l0_1, 8, l0_s1, srA[7:0], eax_sum[7:0], is_eax)
    `MUX_2(u_mux_l0_2, 8, l0_s2, l0_s1,    ax_sum[7:0],  is_ax)
    wire [7:0] lane0;
    `MUX_2(u_mux_l0,   8, lane0, l0_s2,    al_sum[7:0],  is_al)

    // Lane 1 (bits [15:8]): srA / ah_sum / ax_sum / eax_sum
    wire [7:0] l1_s1, l1_s2;
    `MUX_2(u_mux_l1_1, 8, l1_s1, srA[15:8], eax_sum[15:8], is_eax)
    `MUX_2(u_mux_l1_2, 8, l1_s2, l1_s1,     ax_sum[15:8],  is_ax)
    wire [7:0] lane1;
    `MUX_2(u_mux_l1,   8, lane1, l1_s2,     ah_sum[7:0],   is_ah)

    // Lanes 2-3 (bits [31:16]): srA / eax_sum
    wire [15:0] lane23;
    `MUX_2(u_mux_l23, 16, lane23, srA[31:16], eax_sum[31:16], is_eax)

    wire [31:0] merged_result;
    assign merged_result = {lane23, lane1, lane0};

    assign dr_o      = {32'd0, merged_result};
    assign res_buf_o = {32'd0, merged_result};

    // ---- ZF per width ----
    wire al_zf, ah_zf, ax_zf, eax_zf;
    zf_red_8  u_zf_al  (.x(al_sum[7:0]),   .z(al_zf));
    zf_red_8  u_zf_ah  (.x(ah_sum[7:0]),   .z(ah_zf));
    zf_red_16 u_zf_ax  (.x(ax_sum[15:0]),  .z(ax_zf));
    zf_red_32 u_zf_eax (.x(eax_sum[31:0]), .z(eax_zf));

    // ---- PF per width (low 8 bits of each sum) ----
    wire al_pf, ah_pf, ax_pf, eax_pf;
    pf_red_8 u_pf_al  (.x(al_sum[7:0]),  .p(al_pf));
    pf_red_8 u_pf_ah  (.x(ah_sum[7:0]),  .p(ah_pf));
    pf_red_8 u_pf_ax  (.x(ax_sum[7:0]),  .p(ax_pf));
    pf_red_8 u_pf_eax (.x(eax_sum[7:0]), .p(eax_pf));

    // ---- SF / CF (direct picks) ----
    wire al_sf, ah_sf, ax_sf, eax_sf;
    wire al_cf, ah_cf, ax_cf, eax_cf;
    assign al_sf  = al_sum[7];
    assign ah_sf  = ah_sum[7];
    assign ax_sf  = ax_sum[15];
    assign eax_sf = eax_sum[31];
    assign al_cf  = al_sum[8];
    assign ah_cf  = ah_sum[8];
    assign ax_cf  = ax_sum[16];
    assign eax_cf = eax_sum[32];

    // ---- OF for ADD: ~(A_msb XOR B_msb) AND (A_msb XOR sum_msb) ----
    wire al_xab, al_xas, al_of;
    `XOR_2(u_xor_al_ab, 1, al_xab, srA[7], srB[7])
    wire al_xab_inv;
    `INV_N(u_inv_al_ab, 1, al_xab, al_xab_inv)
    `XOR_2(u_xor_al_as, 1, al_xas, srA[7], al_sum[7])
    `AND_2(u_and_al_of, 1, al_of, al_xab_inv, al_xas)

    wire ah_xab, ah_xas, ah_xab_inv, ah_of;
    `XOR_2(u_xor_ah_ab, 1, ah_xab, srA[15], srB[15])
    `INV_N(u_inv_ah_ab, 1, ah_xab, ah_xab_inv)
    `XOR_2(u_xor_ah_as, 1, ah_xas, srA[15], ah_sum[7])
    `AND_2(u_and_ah_of, 1, ah_of, ah_xab_inv, ah_xas)

    wire ax_xab, ax_xas, ax_xab_inv, ax_of;
    `XOR_2(u_xor_ax_ab, 1, ax_xab, srA[15], srB[15])
    `INV_N(u_inv_ax_ab, 1, ax_xab, ax_xab_inv)
    `XOR_2(u_xor_ax_as, 1, ax_xas, srA[15], ax_sum[15])
    `AND_2(u_and_ax_of, 1, ax_of, ax_xab_inv, ax_xas)

    wire eax_xab, eax_xas, eax_xab_inv, eax_of;
    `XOR_2(u_xor_eax_ab, 1, eax_xab, srA[31], srB[31])
    `INV_N(u_inv_eax_ab, 1, eax_xab, eax_xab_inv)
    `XOR_2(u_xor_eax_as, 1, eax_xas, srA[31], eax_sum[31])
    `AND_2(u_and_eax_of, 1, eax_of, eax_xab_inv, eax_xas)

    // ---- Per-flag mux chain (default 0) ----
    // is_eax -> EAX, is_ax -> AX, is_ah -> AH, is_al -> AL.
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

endmodule
