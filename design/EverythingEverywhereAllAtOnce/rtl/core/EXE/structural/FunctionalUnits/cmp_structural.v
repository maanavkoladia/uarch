// Structural Verilog 2005 port of EXE/FunctionalUnits/cmp.sv
//
// Computes flags for srA - srB at three data sizes (AL/AX/EAX) and selects
// which set is exposed based on data_size. Note: AL case uses a low-byte-select
// of srB (data_size[0] picks srB[7:0] vs srB[15:8]) — preserved from SV ref.
//
// Subtraction is implemented as: a - b = a + ~b + 1, in widths 9, 17, 33 to
// expose the borrow at bit[N+8/16/32] (matching the SV ref's al_sum[8] etc.).
//
// data_size selection:
//   4'b0001 or 4'b0010 -> AL flags
//   4'b0011            -> AX flags
//   4'b0111            -> EAX flags
//   default            -> all 0

module cmp (
    input  wire [63:0] srA,
    input  wire [63:0] srB,
    input  wire [3:0]  data_size,
    output wire        CF,
    output wire        OF,
    output wire        SF,
    output wire        ZF,
    output wire        AF,
    output wire        PF
);

    // ---- Low byte source for 8-bit compare ----
    wire [7:0] low_sr_val;
    `MUX_2(u_mux_lsv, 8, low_sr_val, srB[15:8], srB[7:0], data_size[0])

    // ---- 9-bit AL subtract ----
    wire [8:0] al_a_ext, al_b_ext, al_b_inv, al_sum;
    wire       al_cout;
    assign al_a_ext = {1'b0, srA[7:0]};
    assign al_b_ext = {1'b0, low_sr_val};
    `INV_N(u_inv_al, 9, al_b_ext, al_b_inv)
    `ADD_N(u_sub_al, 9, al_sum, al_cout, al_a_ext, al_b_inv, 1'b1)

    // ---- 17-bit AX subtract ----
    wire [16:0] ax_a_ext, ax_b_ext, ax_b_inv, ax_sum;
    wire        ax_cout;
    assign ax_a_ext = {1'b0, srA[15:0]};
    assign ax_b_ext = {1'b0, srB[15:0]};
    `INV_N(u_inv_ax, 17, ax_b_ext, ax_b_inv)
    `ADD_N(u_sub_ax, 17, ax_sum, ax_cout, ax_a_ext, ax_b_inv, 1'b1)

    // ---- 33-bit EAX subtract ----
    wire [32:0] eax_a_ext, eax_b_ext, eax_b_inv, eax_sum;
    wire        eax_cout;
    assign eax_a_ext = {1'b0, srA[31:0]};
    assign eax_b_ext = {1'b0, srB[31:0]};
    `INV_N(u_inv_eax, 33, eax_b_ext, eax_b_inv)
    `ADD_N(u_sub_eax, 33, eax_sum, eax_cout, eax_a_ext, eax_b_inv, 1'b1)

    // ---- Per-width ZF (NOR-tree, shared helper) ----
    wire al_zf, ax_zf, eax_zf;
    zf_red_8  u_zf_al  (.x(al_sum[7:0]),   .z(al_zf));
    zf_red_16 u_zf_ax  (.x(ax_sum[15:0]),  .z(ax_zf));
    zf_red_32 u_zf_eax (.x(eax_sum[31:0]), .z(eax_zf));

    // ---- Per-width PF (XNOR over low 8 bits, shared helper) ----
    wire al_pf, ax_pf, eax_pf;
    pf_red_8 u_pf_al  (.x(al_sum[7:0]),  .p(al_pf));
    pf_red_8 u_pf_ax  (.x(ax_sum[7:0]),  .p(ax_pf));
    pf_red_8 u_pf_eax (.x(eax_sum[7:0]), .p(eax_pf));

    // ---- Per-width SF / CF (direct bit picks) ----
    wire al_sf,  ax_sf,  eax_sf;
    wire al_cf,  ax_cf,  eax_cf;
    assign al_sf  = al_sum[7];
    assign ax_sf  = ax_sum[15];
    assign eax_sf = eax_sum[31];
    assign al_cf  = al_sum[8];
    assign ax_cf  = ax_sum[16];
    assign eax_cf = eax_sum[32];

    // ---- Per-width OF: (A_msb XOR B_msb) AND (A_msb XOR sum_msb) ----
    wire al_of_t1, al_of_t2, al_of;
    `XOR_2(u_xor_al_of_t1, 1, al_of_t1, srA[7], low_sr_val[7])
    `XOR_2(u_xor_al_of_t2, 1, al_of_t2, srA[7], al_sum[7])
    `AND_2(u_and_al_of,    1, al_of,    al_of_t1, al_of_t2)

    wire ax_of_t1, ax_of_t2, ax_of;
    `XOR_2(u_xor_ax_of_t1, 1, ax_of_t1, srA[15], srB[15])
    `XOR_2(u_xor_ax_of_t2, 1, ax_of_t2, srA[15], ax_sum[15])
    `AND_2(u_and_ax_of,    1, ax_of,    ax_of_t1, ax_of_t2)

    wire eax_of_t1, eax_of_t2, eax_of;
    `XOR_2(u_xor_eax_of_t1, 1, eax_of_t1, srA[31], srB[31])
    `XOR_2(u_xor_eax_of_t2, 1, eax_of_t2, srA[31], eax_sum[31])
    `AND_2(u_and_eax_of,    1, eax_of,    eax_of_t1, eax_of_t2)

    // ---- Per-width AF: srA[4] XOR B[4] XOR sum[4] ----
    wire al_af_t, al_af;
    `XOR_2(u_xor_al_af_t, 1, al_af_t, srA[4], low_sr_val[4])
    `XOR_2(u_xor_al_af,   1, al_af,   al_af_t, al_sum[4])

    wire ax_af_t, ax_af;
    `XOR_2(u_xor_ax_af_t, 1, ax_af_t, srA[4], srB[4])
    `XOR_2(u_xor_ax_af,   1, ax_af,   ax_af_t, ax_sum[4])

    wire eax_af_t, eax_af;
    `XOR_2(u_xor_eax_af_t, 1, eax_af_t, srA[4], srB[4])
    `XOR_2(u_xor_eax_af,   1, eax_af,   eax_af_t, eax_sum[4])

    // ---- data_size selectors ----
    wire is_001, is_010, is_011, is_111, is_al;
    wire is_011_raw, is_111_raw;
    `CMP_N(u_cmp_001, 4, is_001,     data_size, 4'b0001)
    `CMP_N(u_cmp_010, 4, is_010,     data_size, 4'b0010)
    `CMP_N(u_cmp_011, 4, is_011_raw, data_size, 4'b0011)
    `CMP_N(u_cmp_111, 4, is_111_raw, data_size, 4'b0111)
    wire is_al_raw;
    `OR_2(u_or_al, 1, is_al_raw, is_001, is_010)
    // is_al feeds 6 mux selects (zf/sf/cf/pf flag muxes etc.) — bufferH16$.
    bufferH16$ u_buf_is_al (.out(is_al), .in(is_al_raw));
    // is_011 / is_111 each feed 4 flag-mux selects (zf/sf/cf/pf) plus other
    // small consumers — fanout 6 per signal. bufferH16$ is the smallest fit.
    bufferH16$ u_buf_is_011 (.out(is_011), .in(is_011_raw));
    bufferH16$ u_buf_is_111 (.out(is_111), .in(is_111_raw));

    // ---- Per-flag one-hot AND/OR (2 levels instead of 3-deep MUX cascade) ----
    // is_al, is_011, is_111 are mutually exclusive (one-hot from CMP_N decoders).
    // When none match, all AND outputs are 0 and the OR yields 0 — same default
    // behavior as the previous MUX_2 cascade (which started from 1'b0).
    //
    //   was: zf_s1 = is_111 ? eax_zf : 0
    //        zf_s2 = is_011 ? ax_zf  : zf_s1
    //        ZF    = is_al  ? al_zf  : zf_s2          (3 levels)
    //   now: ZF = (is_al & al_zf) | (is_011 & ax_zf) | (is_111 & eax_zf)  (2 levels)

    wire zf_t_al, zf_t_ax, zf_t_eax;
    wire ZF_raw;
    `AND_2(u_and_zf_al,  1, zf_t_al,  al_zf,  is_al)
    `AND_2(u_and_zf_ax,  1, zf_t_ax,  ax_zf,  is_011)
    `AND_2(u_and_zf_eax, 1, zf_t_eax, eax_zf, is_111)
    `OR_3(u_or_zf,       1, ZF_raw,   zf_t_al, zf_t_ax, zf_t_eax)
    // Buffer ZF with bufferH256$: external fanout 97 exceeds bufferH64$'s
    // 64-load rating; bufferH256$ (rated 256, 0.54 ns typ) is the next size.
    bufferH256$ u_buf_zf (.out(ZF), .in(ZF_raw));

    wire sf_t_al, sf_t_ax, sf_t_eax;
    `AND_2(u_and_sf_al,  1, sf_t_al,  al_sf,  is_al)
    `AND_2(u_and_sf_ax,  1, sf_t_ax,  ax_sf,  is_011)
    `AND_2(u_and_sf_eax, 1, sf_t_eax, eax_sf, is_111)
    `OR_3(u_or_sf,       1, SF,       sf_t_al, sf_t_ax, sf_t_eax)

    wire cf_t_al, cf_t_ax, cf_t_eax;
    `AND_2(u_and_cf_al,  1, cf_t_al,  al_cf,  is_al)
    `AND_2(u_and_cf_ax,  1, cf_t_ax,  ax_cf,  is_011)
    `AND_2(u_and_cf_eax, 1, cf_t_eax, eax_cf, is_111)
    `OR_3(u_or_cf,       1, CF,       cf_t_al, cf_t_ax, cf_t_eax)

    wire pf_t_al, pf_t_ax, pf_t_eax;
    `AND_2(u_and_pf_al,  1, pf_t_al,  al_pf,  is_al)
    `AND_2(u_and_pf_ax,  1, pf_t_ax,  ax_pf,  is_011)
    `AND_2(u_and_pf_eax, 1, pf_t_eax, eax_pf, is_111)
    `OR_3(u_or_pf,       1, PF,       pf_t_al, pf_t_ax, pf_t_eax)

    wire of_t_al, of_t_ax, of_t_eax;
    `AND_2(u_and_of_al,  1, of_t_al,  al_of,  is_al)
    `AND_2(u_and_of_ax,  1, of_t_ax,  ax_of,  is_011)
    `AND_2(u_and_of_eax, 1, of_t_eax, eax_of, is_111)
    `OR_3(u_or_of,       1, OF,       of_t_al, of_t_ax, of_t_eax)

    // SV reference omits AF in its `default` branch (i.e., AF retains last value
    // and would synthesize as a latch). Structural can't do that — drive 0.
    wire af_t_al, af_t_ax, af_t_eax;
    `AND_2(u_and_af_al,  1, af_t_al,  al_af,  is_al)
    `AND_2(u_and_af_ax,  1, af_t_ax,  ax_af,  is_011)
    `AND_2(u_and_af_eax, 1, af_t_eax, eax_af, is_111)
    `OR_3(u_or_af,       1, AF,       af_t_al, af_t_ax, af_t_eax)

endmodule


// ZF/PF reduction helpers (zf_red_8/16/32, pf_red_8) live in
// flag_helpers_structural.v — shared with add_op, sbb_op, etc.
