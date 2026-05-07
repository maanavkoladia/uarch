// ----------------------------------------------------------------
// TLB -- structural Verilog 2005 port.
//
// Reference: rtl/core/TLB/TLB.sv (+ rtl/core/TLB/pkg/TLB_pkg.sv)
//
// 8 entries, each with {valid, present, r_w, mmio, vpn[19:0], pfn[19:0]}.
// State has no internal driver (matches the .sv reference) -- it is
// loaded externally by a tlb_loader, which today writes via hierarchical
// reference into per-entry-array slots.  This port flattens the per-entry
// state into individually-named regs so the future structural tlb_loader
// can drive them directly without struct/array indexing.
//
// Constants (from pkgs):
//   ADDRESS_BITS = 32, PAGE_SIZE = 4096, OFFSET_BITS = 12, VPN_BITS = 20
//   PHY_MEM_SIZE = 32768  ->  p_address_t = 15 bits
//   PFN bits used in physical_addr = 15 - 12 = 3  (pfn_winner[2:0])
//
//   vpn_eq_i  = (vpn_i == virtual_addr[31:12])
//   hit_i     = valid_i & vpn_eq_i
//
//   physical_addr_valid = OR(hit_i)
//   MIO                 = OR(hit_i & mmio_i)
//   gp_exp              = OR(hit_i & write_intention & ~r_w_i)
//   pageFault           = ~OR(hit_i & present_i)
//   physical_addr[14:0] = { pfn_winner[2:0], virtual_addr[11:0] }
//                          pfn_winner[b] = OR(hit_i & pfn_i[b])
// ----------------------------------------------------------------

module TLB (
    // --- inputs (tlb_inputs_t unrolled) ---
    input  wire [31:0] virtual_addr,
    input  wire        write_intention,

    // --- outputs (tlb_outputs_t unrolled) ---
    output wire [14:0] physical_addr,
    output wire        physical_addr_valid,
    output wire        gp_exp,
    output wire        pageFault,
    output wire        MIO
);
    localparam entries = 8;
    localparam PAGE_SIZE = 4096;
    localparam OFFSET_BITS = $clog2(PAGE_SIZE);
      localparam ADDRESS_BITS = 32;
    localparam VPN_BITS = ADDRESS_BITS - OFFSET_BITS;
    // ----------------------------------------------------------------
    // Per-entry storage.  Externally written by the tlb_loader.
    // Flat names so the loader sees `valid_0`, `vpn_0`, etc., rather
    // than indexing into a struct/array.
    // ----------------------------------------------------------------
    reg                  valid_0,   valid_1,   valid_2,   valid_3,
                         valid_4,   valid_5,   valid_6,   valid_7;
    reg                  present_0, present_1, present_2, present_3,
                         present_4, present_5, present_6, present_7;
    reg                  r_w_0,     r_w_1,     r_w_2,     r_w_3,
                         r_w_4,     r_w_5,     r_w_6,     r_w_7;
    reg                  mmio_0,    mmio_1,    mmio_2,    mmio_3,
                         mmio_4,    mmio_5,    mmio_6,    mmio_7;
    reg [VPN_BITS-1:0]   vpn_0,     vpn_1,     vpn_2,     vpn_3,
                         vpn_4,     vpn_5,     vpn_6,     vpn_7;
    reg [VPN_BITS-1:0]   pfn_0,     pfn_1,     pfn_2,     pfn_3,
                         pfn_4,     pfn_5,     pfn_6,     pfn_7;

    // ----------------------------------------------------------------
    // Virtual page number from the input.
    //   ADDRESS_BITS=32, OFFSET_BITS=12, VPN_BITS=20
    // ----------------------------------------------------------------
    wire [VPN_BITS-1:0]     vaddy_vpn;
    wire [OFFSET_BITS-1:0]  vaddy_offset;
    assign vaddy_vpn    = virtual_addr[ADDRESS_BITS-1 : OFFSET_BITS];
    assign vaddy_offset = virtual_addr[OFFSET_BITS-1 : 0];

    // CMP_N supports widths 2,3,4,5,6,8,9,11,22,24,28,32.  Pad VPN
    // (20 bits) with 2'b0 on both operands and use width-22 CMP_N.
    wire [21:0] vaddy_vpn_pad;
    assign vaddy_vpn_pad = {2'b00, vaddy_vpn};

    wire [21:0] vpn_0_pad, vpn_1_pad, vpn_2_pad, vpn_3_pad,
                vpn_4_pad, vpn_5_pad, vpn_6_pad, vpn_7_pad;
    assign vpn_0_pad = {2'b00, vpn_0};
    assign vpn_1_pad = {2'b00, vpn_1};
    assign vpn_2_pad = {2'b00, vpn_2};
    assign vpn_3_pad = {2'b00, vpn_3};
    assign vpn_4_pad = {2'b00, vpn_4};
    assign vpn_5_pad = {2'b00, vpn_5};
    assign vpn_6_pad = {2'b00, vpn_6};
    assign vpn_7_pad = {2'b00, vpn_7};

    // ----------------------------------------------------------------
    // Per-entry: vpn_eq, hit
    // ----------------------------------------------------------------
    wire vpn_eq_0, vpn_eq_1, vpn_eq_2, vpn_eq_3,
         vpn_eq_4, vpn_eq_5, vpn_eq_6, vpn_eq_7;
    `CMP_N(u_vpn_eq_0, 22, vpn_eq_0, vpn_0_pad, vaddy_vpn_pad)
    `CMP_N(u_vpn_eq_1, 22, vpn_eq_1, vpn_1_pad, vaddy_vpn_pad)
    `CMP_N(u_vpn_eq_2, 22, vpn_eq_2, vpn_2_pad, vaddy_vpn_pad)
    `CMP_N(u_vpn_eq_3, 22, vpn_eq_3, vpn_3_pad, vaddy_vpn_pad)
    `CMP_N(u_vpn_eq_4, 22, vpn_eq_4, vpn_4_pad, vaddy_vpn_pad)
    `CMP_N(u_vpn_eq_5, 22, vpn_eq_5, vpn_5_pad, vaddy_vpn_pad)
    `CMP_N(u_vpn_eq_6, 22, vpn_eq_6, vpn_6_pad, vaddy_vpn_pad)
    `CMP_N(u_vpn_eq_7, 22, vpn_eq_7, vpn_7_pad, vaddy_vpn_pad)

    // Logic-duplicate each hit_X into a CP copy (drives the 3 pfn ANDs that
    // feed physical_addr) and an aux copy (drives pa_valid + mio_term + gp +
    // ph -- all off the DC critical path). Both copies are independent AND_2
    // cells with identical inputs, so the CP wire (hit_X_cp) sees fanout 3
    // and the aux wire (hit_X_aux) sees fanout 4 -- both within AND_2 rated
    // load. Zero added CP delay.
    wire hit_0_cp,  hit_1_cp,  hit_2_cp,  hit_3_cp,
         hit_4_cp,  hit_5_cp,  hit_6_cp,  hit_7_cp;
    wire hit_0_aux, hit_1_aux, hit_2_aux, hit_3_aux,
         hit_4_aux, hit_5_aux, hit_6_aux, hit_7_aux;

    `AND_2(u_hit_0_cp,  1, hit_0_cp,  valid_0, vpn_eq_0)
    `AND_2(u_hit_1_cp,  1, hit_1_cp,  valid_1, vpn_eq_1)
    `AND_2(u_hit_2_cp,  1, hit_2_cp,  valid_2, vpn_eq_2)
    `AND_2(u_hit_3_cp,  1, hit_3_cp,  valid_3, vpn_eq_3)
    `AND_2(u_hit_4_cp,  1, hit_4_cp,  valid_4, vpn_eq_4)
    `AND_2(u_hit_5_cp,  1, hit_5_cp,  valid_5, vpn_eq_5)
    `AND_2(u_hit_6_cp,  1, hit_6_cp,  valid_6, vpn_eq_6)
    `AND_2(u_hit_7_cp,  1, hit_7_cp,  valid_7, vpn_eq_7)

    `AND_2(u_hit_0_aux, 1, hit_0_aux, valid_0, vpn_eq_0)
    `AND_2(u_hit_1_aux, 1, hit_1_aux, valid_1, vpn_eq_1)
    `AND_2(u_hit_2_aux, 1, hit_2_aux, valid_2, vpn_eq_2)
    `AND_2(u_hit_3_aux, 1, hit_3_aux, valid_3, vpn_eq_3)
    `AND_2(u_hit_4_aux, 1, hit_4_aux, valid_4, vpn_eq_4)
    `AND_2(u_hit_5_aux, 1, hit_5_aux, valid_5, vpn_eq_5)
    `AND_2(u_hit_6_aux, 1, hit_6_aux, valid_6, vpn_eq_6)
    `AND_2(u_hit_7_aux, 1, hit_7_aux, valid_7, vpn_eq_7)

    // ----------------------------------------------------------------
    // physical_addr_valid = OR(hit_i)
    // ----------------------------------------------------------------
    wire physical_addr_valid_w;
    `OR_8(u_pa_valid, 1, physical_addr_valid_w,
          hit_0_aux, hit_1_aux, hit_2_aux, hit_3_aux,
          hit_4_aux, hit_5_aux, hit_6_aux, hit_7_aux)

    // ----------------------------------------------------------------
    // MIO = OR(hit_i & mmio_i)
    // ----------------------------------------------------------------
    wire mio_term_0, mio_term_1, mio_term_2, mio_term_3,
         mio_term_4, mio_term_5, mio_term_6, mio_term_7;
    `AND_2(u_mio_term_0, 1, mio_term_0, hit_0_aux, mmio_0)
    `AND_2(u_mio_term_1, 1, mio_term_1, hit_1_aux, mmio_1)
    `AND_2(u_mio_term_2, 1, mio_term_2, hit_2_aux, mmio_2)
    `AND_2(u_mio_term_3, 1, mio_term_3, hit_3_aux, mmio_3)
    `AND_2(u_mio_term_4, 1, mio_term_4, hit_4_aux, mmio_4)
    `AND_2(u_mio_term_5, 1, mio_term_5, hit_5_aux, mmio_5)
    `AND_2(u_mio_term_6, 1, mio_term_6, hit_6_aux, mmio_6)
    `AND_2(u_mio_term_7, 1, mio_term_7, hit_7_aux, mmio_7)
    wire mio_w;
    `OR_8(u_mio, 1, mio_w,
          mio_term_0, mio_term_1, mio_term_2, mio_term_3,
          mio_term_4, mio_term_5, mio_term_6, mio_term_7)

    // ----------------------------------------------------------------
    // gp_exp = OR(hit_i & write_intention & ~r_w_i)
    // ----------------------------------------------------------------
    wire not_r_w_0, not_r_w_1, not_r_w_2, not_r_w_3,
         not_r_w_4, not_r_w_5, not_r_w_6, not_r_w_7;
    `INV_N(u_not_r_w_0, 1, r_w_0, not_r_w_0)
    `INV_N(u_not_r_w_1, 1, r_w_1, not_r_w_1)
    `INV_N(u_not_r_w_2, 1, r_w_2, not_r_w_2)
    `INV_N(u_not_r_w_3, 1, r_w_3, not_r_w_3)
    `INV_N(u_not_r_w_4, 1, r_w_4, not_r_w_4)
    `INV_N(u_not_r_w_5, 1, r_w_5, not_r_w_5)
    `INV_N(u_not_r_w_6, 1, r_w_6, not_r_w_6)
    `INV_N(u_not_r_w_7, 1, r_w_7, not_r_w_7)

    wire gp_0, gp_1, gp_2, gp_3, gp_4, gp_5, gp_6, gp_7;
    `AND_3(u_gp_0, 1, gp_0, hit_0_aux, write_intention, not_r_w_0)
    `AND_3(u_gp_1, 1, gp_1, hit_1_aux, write_intention, not_r_w_1)
    `AND_3(u_gp_2, 1, gp_2, hit_2_aux, write_intention, not_r_w_2)
    `AND_3(u_gp_3, 1, gp_3, hit_3_aux, write_intention, not_r_w_3)
    `AND_3(u_gp_4, 1, gp_4, hit_4_aux, write_intention, not_r_w_4)
    `AND_3(u_gp_5, 1, gp_5, hit_5_aux, write_intention, not_r_w_5)
    `AND_3(u_gp_6, 1, gp_6, hit_6_aux, write_intention, not_r_w_6)
    `AND_3(u_gp_7, 1, gp_7, hit_7_aux, write_intention, not_r_w_7)
    wire gp_exp_w;
    `OR_8(u_gp, 1, gp_exp_w,
          gp_0, gp_1, gp_2, gp_3, gp_4, gp_5, gp_6, gp_7)

    // ----------------------------------------------------------------
    // pageFault = ~OR(hit_i & present_i)
    // ----------------------------------------------------------------
    wire ph_0, ph_1, ph_2, ph_3, ph_4, ph_5, ph_6, ph_7;
    `AND_2(u_ph_0, 1, ph_0, hit_0_aux, present_0)
    `AND_2(u_ph_1, 1, ph_1, hit_1_aux, present_1)
    `AND_2(u_ph_2, 1, ph_2, hit_2_aux, present_2)
    `AND_2(u_ph_3, 1, ph_3, hit_3_aux, present_3)
    `AND_2(u_ph_4, 1, ph_4, hit_4_aux, present_4)
    `AND_2(u_ph_5, 1, ph_5, hit_5_aux, present_5)
    `AND_2(u_ph_6, 1, ph_6, hit_6_aux, present_6)
    `AND_2(u_ph_7, 1, ph_7, hit_7_aux, present_7)
    wire ph_total_w;
    `OR_8(u_ph_total, 1, ph_total_w,
          ph_0, ph_1, ph_2, ph_3, ph_4, ph_5, ph_6, ph_7)
    wire pageFault_w;
    `INV_N(u_pf, 1, ph_total_w, pageFault_w)

    // ----------------------------------------------------------------
    // PFN one-hot mux: pfn_winner[b] = OR(hit_i & pfn_i[b])
    //
    // p_address_t = 15 bits = {pfn[2:0], offset[11:0]}.  Only the lower
    // 3 bits of pfn feed the physical address, so we only generate those.
    // Iterating over all VPN_BITS would create 17 dead-output OR/AND
    // trees per TLB and add 17 to every hit_i's fanout for no benefit.
    // ----------------------------------------------------------------
    // pfn_winner_raw is the unbuffered OR_8 output (rated load too low for
    // the fanout-6 external load on physical_addr).  Buffer with bufferH16$
    // (rated 16) to clear the violation; ~0.24 ns added but well within the
    // CP slack saved by the upstream B+D optimizations.
    wire [2:0] pfn_winner_raw;
    wire [2:0] pfn_winner;
    genvar pb;
    generate
        for (pb = 0; pb < 3; pb = pb + 1) begin : g_pfn_bit
            wire pa0, pa1, pa2, pa3, pa4, pa5, pa6, pa7;
            `AND_2(u_pa_0, 1, pa0, hit_0_cp, pfn_0[pb])
            `AND_2(u_pa_1, 1, pa1, hit_1_cp, pfn_1[pb])
            `AND_2(u_pa_2, 1, pa2, hit_2_cp, pfn_2[pb])
            `AND_2(u_pa_3, 1, pa3, hit_3_cp, pfn_3[pb])
            `AND_2(u_pa_4, 1, pa4, hit_4_cp, pfn_4[pb])
            `AND_2(u_pa_5, 1, pa5, hit_5_cp, pfn_5[pb])
            `AND_2(u_pa_6, 1, pa6, hit_6_cp, pfn_6[pb])
            `AND_2(u_pa_7, 1, pa7, hit_7_cp, pfn_7[pb])
            `OR_8(u_pfn_or, 1, pfn_winner_raw[pb],
                  pa0, pa1, pa2, pa3, pa4, pa5, pa6, pa7)
            bufferH16$ u_pfn_buf (.out(pfn_winner[pb]),
                                  .in(pfn_winner_raw[pb]));
        end
    endgenerate

    // physical_addr[14:0] = { pfn_winner[2:0], vaddy_offset[11:0] }
    assign physical_addr       = {pfn_winner, vaddy_offset};
    assign physical_addr_valid = physical_addr_valid_w;
    assign MIO                 = mio_w;
    assign gp_exp              = gp_exp_w;
    assign pageFault           = pageFault_w;

endmodule
