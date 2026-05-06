// Structural Verilog 2005 port of two_bit_sat_count.
// Reference SV: rtl/core/Fetch/structural/two_bit_sat_count.sv (original).
//
// 2-bit saturating counter, reset value = 2'b10 (weakly taken).
//   - inc & ~full   -> q+1
//   - dec & ~empty  -> q-1   (inc has priority over dec)
//   - taken         = q[1]
//
// REG_RST_WE only resets to 0, so we store bit[1] inverted:
//     stored_q[0] = q[0],  stored_q[1] = ~q[1]
// On reset, stored_q = 2'b00 -> logical q = {~0, 0} = 2'b10. ✓
// Each write inverts bit[1] going in, and we invert it back on the read.

module two_bit_sat_count (
    input  wire clk,
    input  wire rst,    // active low (REG_RST_WE convention)
    input  wire inc,
    input  wire dec,
    output wire taken
);

    // ----------------------------------------------------------------
    // Storage and logical view
    // ----------------------------------------------------------------
    wire [1:0] stored_q;        // raw register output (bit[1] is inverted)
    wire [1:0] q;               // logical counter value
    wire [1:0] q_next;          // logical next-state value
    wire [1:0] d_to_reg;        // value written into stored_q

    // q[0] passes through; q[1] is the inverse of stored_q[1]
    assign q[0] = stored_q[0];
    `INV_N(u_inv_q1, 1, stored_q[1], q[1])

    // ----------------------------------------------------------------
    // Saturation flags
    //   full  = q[1] & q[0]            (q == 2'b11)
    //   empty = ~(q[1] | q[0])         (q == 2'b00)
    // ----------------------------------------------------------------
    wire full;
    wire empty;
    wire notfull;
    wire notempty;

    `AND_2(u_full,        1, full,     q[1], q[0])
    `NOR_2(u_empty,       1, empty,    q[1], q[0])
    `INV_N(u_inv_full,    1, full,     notfull)
    `INV_N(u_inv_empty,   1, empty,    notempty)

    // ----------------------------------------------------------------
    // Update enables (matches SV if/else if priority: inc beats dec)
    //   inc_active = inc & ~full
    //   dec_active = dec & ~empty & ~inc_active
    //   we         = inc_active | dec_active
    // ----------------------------------------------------------------
    wire inc_active;
    wire dec_can;
    wire not_inc_active;
    wire dec_active;
    wire we_internal;

    `AND_2(u_inc_active,  1, inc_active,    inc,        notfull)
    `AND_2(u_dec_can,     1, dec_can,       dec,        notempty)
    `INV_N(u_not_inc_act, 1, inc_active,    not_inc_active)
    `AND_2(u_dec_active,  1, dec_active,    dec_can,    not_inc_active)
    `OR_2 (u_we,          1, we_internal,   inc_active, dec_active)

    // ----------------------------------------------------------------
    // Next-state logical value
    //   q_next[0] = ~q[0]                                 (always flips on +/-1)
    //   q_next[1] = q[1] XOR (inc_active ? q[0] : ~q[0])
    //
    //   inc:  next[1] = q[1] XOR q[0]
    //   dec:  next[1] = q[1] XOR ~q[0]
    // ----------------------------------------------------------------
    wire not_q0;
    wire xor_b_in;

    `INV_N(u_inv_q0,  1, q[0],     not_q0)
    `MUX_2(u_xor_sel, 1, xor_b_in, not_q0, q[0], inc_active)
    `XOR_2(u_xor_h,   1, q_next[1], q[1], xor_b_in)
    assign q_next[0] = not_q0;

    // ----------------------------------------------------------------
    // Apply storage inversion on bit[1] for the write path
    //   d_to_reg[0] = q_next[0]
    //   d_to_reg[1] = ~q_next[1]
    // ----------------------------------------------------------------
    `INV_N(u_inv_din1, 1, q_next[1], d_to_reg[1])
    assign d_to_reg[0] = q_next[0];

    // ----------------------------------------------------------------
    // The actual register
    // ----------------------------------------------------------------
    `REG_RST_WE(u_q_reg, 2, clk, rst, we_internal, d_to_reg, stored_q)

    // ----------------------------------------------------------------
    // Output: taken = q[1]
    // ----------------------------------------------------------------
    assign taken = q[1];

endmodule
