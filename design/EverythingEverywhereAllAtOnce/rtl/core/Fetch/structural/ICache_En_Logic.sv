// Structural Verilog 2005 port of ICache_En_Logic.
// Reference SV: rtl/core/Fetch/structural/ICache_En_Logic.sv (original).
//
// Pure combinational. Drives the I-cache enable line. Cache is enabled iff
// none of the "do not fetch from icache" conditions hold AND we are not in
// reset (active-low rst).
//
//   out = ~exp_mode & ~cs_sb & ~int_mode & ~f_exp & ~DMA_int & rst
//
// rst is active low at the top of the design — when rst=0 (in reset), `out`
// is forced to 0 here, matching the SV's `&& rst` term.

module ICache_En_Logic (
    input  wire rst,           // active low
    input  wire exp_mode,
    input  wire cs_sb,
    input  wire int_mode,
    input  wire f_exp,
    input  wire DMA_int,
    output wire out
);

    // Inverters for the active-high "block fetch" signals
    wire not_exp_mode;
    wire not_cs_sb;
    wire not_int_mode;
    wire not_f_exp;
    wire not_DMA_int;

    `INV_N(u_inv_em, 1, exp_mode, not_exp_mode)
    `INV_N(u_inv_cs, 1, cs_sb,    not_cs_sb)
    `INV_N(u_inv_im, 1, int_mode, not_int_mode)
    `INV_N(u_inv_fe, 1, f_exp,    not_f_exp)
    `INV_N(u_inv_dm, 1, DMA_int,  not_DMA_int)

    // 6-input AND: enable when all "block" signals are low and we're out of reset
    `AND_6(u_en, 1, out,
           not_exp_mode,
           not_cs_sb,
           not_int_mode,
           not_f_exp,
           not_DMA_int,
           rst)

endmodule
