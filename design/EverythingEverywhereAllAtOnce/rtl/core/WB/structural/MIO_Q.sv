// Pure structural port of MIO_Q (1-entry MIO store queue).
//
// Functional summary:
//   * Holds at most one entry. 'full' indicates that an entry is present.
//   * On a successful push, the entry is overwritten (stays full).
//   * On a successful pop, the entry is consumed (becomes empty).
//   * push_fail asserts when push is requested but the queue is full and no
//     simultaneous pop is freeing a slot. WB.sv ORs this into stall_flop_next.
//
// Reset (active LOW): full_q=0, address/data forced to 0 via MPS_reg_rst_we$.
//   That gives outs_full=0, outs_empty=~full_q=1 -- matches legacy
//   `full <= 0; empty <= 1;` reset behavior.
//
// Notes vs legacy:
//   - Legacy carried a `mio_q.valid` flop that was written but NEVER read
//     (it is not part of st_q_2_dcache_t). Omitted here as dead state.
//   - Legacy carried a separate `empty` flop. In a single-entry queue,
//     empty is always exactly ~full, so we synthesize it from full_q.
//
// Struct unrolling map:
//   mio_input.data.valid    -> mio_input_data_valid     (1)
//   mio_input.data.address  -> mio_input_data_address   (15)
//   mio_input.data.data     -> mio_input_data_data      (128)
//   mio_input.push          -> mio_input_push           (1)
//   mio_input.pop           -> mio_input_pop            (1)
//   outs.full               -> outs_full                (1)
//   outs.empty              -> outs_empty               (1)
//   outs.address            -> outs_address             (15)
//   outs.bit_vec            -> outs_bit_vec             (16)  -- tied to 0
//   outs.data               -> outs_data                (128)

module MIO_Q (
    input  wire         clk,
    input  wire         rst,                  // active LOW

    input  wire         mio_input_data_valid, // unused -- legacy dead bit,
                                              //   kept on the port for parity
    input  wire [14:0]  mio_input_data_address,
    input  wire [127:0] mio_input_data_data,
    input  wire         mio_input_push,
    input  wire         mio_input_pop,

    output wire         push_fail,

    output wire         outs_full,
    output wire         outs_empty,
    output wire [14:0]  outs_address,
    output wire [15:0]  outs_bit_vec,
    output wire [127:0] outs_data
);

    // ---------------- state register: full_q ----------------
    wire full_q;

    // ---------------- combinational control ----------------
    wire inv_full_w;        // ~full_q
    wire inv_pop_in_w;      // ~mio_input_pop
    wire or_pop_or_notfull_w;
    wire valid_push_w;
    wire valid_pop_w;
    wire full_and_notpop_w;
    wire inv_valid_pop_w;
    wire full_hold_w;       // full_q & ~valid_pop
    wire next_full_w;

    `INV_N(u_inv_full,   1, full_q,        inv_full_w)
    `INV_N(u_inv_pop_in, 1, mio_input_pop, inv_pop_in_w)

    // valid_push = push & (~full | pop)
    `OR_2 (u_or_notfull_pop, 1, or_pop_or_notfull_w, inv_full_w, mio_input_pop)
    `AND_2(u_valid_push,     1, valid_push_w, mio_input_push, or_pop_or_notfull_w)

    // valid_pop  = pop & ~empty   (since empty = ~full_q, ~empty = full_q)
    `AND_2(u_valid_pop,      1, valid_pop_w, mio_input_pop, full_q)

    // push_fail = push & full & ~pop
    `AND_2(u_full_notpop,    1, full_and_notpop_w, full_q, inv_pop_in_w)
    `AND_2(u_push_fail,      1, push_fail, mio_input_push, full_and_notpop_w)

    // next_full = valid_push | (full & ~valid_pop)
    `INV_N(u_inv_vpop,       1, valid_pop_w, inv_valid_pop_w)
    `AND_2(u_full_hold,      1, full_hold_w, full_q, inv_valid_pop_w)
    `OR_2 (u_next_full,      1, next_full_w, valid_push_w, full_hold_w)

    // outs_empty is just ~full_q (1-entry queue invariant)
    `INV_N(u_outs_empty,     1, full_q, outs_empty)

    // ---------------- registers ----------------
    // full_q: always-clocked, sync active-low reset to 0.
    `REG_RST(u_full_q, 1, clk, rst, next_full_w, full_q)

    // address: WE = valid_push  (only updated on a real push)
    `REG_RST_WE(u_qaddr, 15, clk, rst, valid_push_w, mio_input_data_address, outs_address)

    // data: WE = valid_push
    `REG_RST_WE(u_qdata, 128, clk, rst, valid_push_w, mio_input_data_data, outs_data)

    // ---------------- direct outputs ----------------
    assign outs_full    = full_q;
    assign outs_bit_vec = 16'h0000;

endmodule
