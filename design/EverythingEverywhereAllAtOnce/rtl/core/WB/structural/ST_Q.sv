// Pure structural port of ST_Q (4-deep store-queue FIFO).
//
// FIFO semantics (matches the legacy SV exactly):
//   * Pointers head and tail are each `clog2(DEPTH)+1` = 3 bits, so the
//     extra MSB acts as a wrap bit.
//   * head_ptr = head[1:0] is the slot to read; tail_ptr = tail[1:0] is the
//     slot to write next.
//   * empty:  head == tail        (all 3 bits equal)
//     full:   head[2] != tail[2] AND head[1:0] == tail[1:0]
//   * Per-cycle: a push, a pop, BOTH or NEITHER may happen.
//     valid_push = push & (~full | pop)        -- push allowed if room or
//                                                  a simultaneous pop frees a
//                                                  slot.
//     valid_pop  = pop  & ~empty
//     push_fail  = push & full & ~pop          -- raised to WB.sv stall logic
//
// Per-slot registers:
//   q_<i>_valid    1    WE = push_to_i | pop_from_i, D = push? input.valid : 0
//   q_<i>_address  15   WE = push_to_i,             D = wb_in_data_address
//   q_<i>_bit_vec  16   WE = push_to_i,             D = wb_in_data_bit_vec
//   q_<i>_data    128   WE = push_to_i,             D = wb_in_data_data
// where push_to_i = valid_push & (tail_ptr == i),
//       pop_from_i = valid_pop  & (head_ptr == i)
// Both decodes come from a 2->4 DECODER_N on head_ptr / tail_ptr.
//
// Reset (active LOW): all registers clear to 0.  head=tail=0 -> empty.
//   The legacy SV did the same plus zeroed every entry; same here.
//
// Struct unrolling map (st_q_inputs_t wb_in / st_q_outputs_t outputs):
//   wb_in.data.valid     -> wb_in_data_valid       (1)
//   wb_in.data.address   -> wb_in_data_address     (15)
//   wb_in.data.bit_vec   -> wb_in_data_bit_vec     (16)
//   wb_in.data.data      -> wb_in_data_data        (128)
//   wb_in.push           -> wb_in_push             (1)
//   wb_in.pop            -> wb_in_pop              (1)
//   outputs.full         -> outputs_full           (1)
//   outputs.empty        -> outputs_empty          (1)
//   outputs.valid[i]     -> outputs_valid_<i>      (1)   for i = 0..3
//   outputs.address[i]   -> outputs_address_<i>    (15)  for i = 0..3
//   outputs.head_address -> outputs_head_address   (15)
//   outputs.bit_vec      -> outputs_bit_vec        (16)
//   outputs.data         -> outputs_data           (128)
//   outputs.push_fail    -> outputs_push_fail      (1)

module ST_Q (
    input  wire         clk,
    input  wire         rst,            // active LOW

    // wb_in (st_q_inputs_t)
    input  wire         wb_in_data_valid,
    input  wire [14:0]  wb_in_data_address,
    input  wire [15:0]  wb_in_data_bit_vec,
    input  wire [127:0] wb_in_data_data,
    input  wire         wb_in_push,
    input  wire         wb_in_pop,

    // outputs (st_q_outputs_t)
    output wire         outputs_full,
    output wire         outputs_empty,

    output wire         outputs_valid_0,
    output wire         outputs_valid_1,
    output wire         outputs_valid_2,
    output wire         outputs_valid_3,

    output wire [14:0]  outputs_address_0,
    output wire [14:0]  outputs_address_1,
    output wire [14:0]  outputs_address_2,
    output wire [14:0]  outputs_address_3,

    output wire [14:0]  outputs_head_address,
    output wire [15:0]  outputs_bit_vec,
    output wire [127:0] outputs_data,
    output wire         outputs_push_fail
);

    // -------------------------------------------------------------------
    // Pointer registers (head, tail) and increments
    // -------------------------------------------------------------------
    wire [2:0] head_q;
    wire [2:0] tail_q;
    wire [1:0] head_ptr_w;
    wire [1:0] tail_ptr_w;
    assign head_ptr_w = head_q[1:0];
    assign tail_ptr_w = tail_q[1:0];

    wire [2:0] head_plus1_w;
    wire [2:0] tail_plus1_w;
    wire       head_plus1_cout_w;   // unused
    wire       tail_plus1_cout_w;   // unused
    `ADD_N(u_head_inc, 3, head_plus1_w, head_plus1_cout_w, head_q, 3'b000, 1'b1)
    `ADD_N(u_tail_inc, 3, tail_plus1_w, tail_plus1_cout_w, tail_q, 3'b000, 1'b1)

    // -------------------------------------------------------------------
    // Full / empty detection
    //   q_empty = (head == tail)               -- 3-bit equality
    //   eq_low  = (head[1:0] == tail[1:0])
    //   eq_msb  = (head[2] == tail[2])
    //   q_full  = ~eq_msb & eq_low
    // -------------------------------------------------------------------
    wire q_empty_w;
    wire eq_low_w;
    wire eq_msb_w;
    wire neq_msb_w;
    wire q_full_w;

    `CMP_N(u_eq_full3, 3, q_empty_w, head_q, tail_q)
    `CMP_N(u_eq_low,   2, eq_low_w,  head_ptr_w, tail_ptr_w)
    `CMP_N(u_eq_msb,   1, eq_msb_w,  head_q[2], tail_q[2])
    `INV_N(u_neq_msb,  1, eq_msb_w,  neq_msb_w)
    `AND_2(u_q_full,   1, q_full_w,  neq_msb_w, eq_low_w)

    // -------------------------------------------------------------------
    // valid_push / valid_pop / push_fail
    //   valid_push = push & (~full | pop)
    //   valid_pop  = pop  & ~empty
    //   push_fail  = push & full & ~pop
    // -------------------------------------------------------------------
    wire inv_full_w;
    wire inv_empty_w;
    wire inv_pop_in_w;
    wire or_notfull_pop_w;
    wire valid_push_w;
    wire valid_pop_w;
    wire full_and_notpop_w;

    `INV_N(u_inv_full,    1, q_full_w,    inv_full_w)
    `INV_N(u_inv_empty,   1, q_empty_w,   inv_empty_w)
    `INV_N(u_inv_pop_in,  1, wb_in_pop,   inv_pop_in_w)
    `OR_2 (u_or_nf_pop,   1, or_notfull_pop_w, inv_full_w, wb_in_pop)
    `AND_2(u_valid_push,  1, valid_push_w, wb_in_push, or_notfull_pop_w)
    `AND_2(u_valid_pop,   1, valid_pop_w,  wb_in_pop,  inv_empty_w)
    `AND_2(u_full_notpop, 1, full_and_notpop_w, q_full_w, inv_pop_in_w)
    `AND_2(u_push_fail,   1, outputs_push_fail, wb_in_push, full_and_notpop_w)

    // -------------------------------------------------------------------
    // Pointer-register next-state and instantiation
    //   head <= valid_pop  ? head+1 : head
    //   tail <= valid_push ? tail+1 : tail
    // -------------------------------------------------------------------
    wire [2:0] head_din_w;
    wire [2:0] tail_din_w;
    `MUX_2(u_head_din, 3, head_din_w, head_q, head_plus1_w, valid_pop_w)
    `MUX_2(u_tail_din, 3, tail_din_w, tail_q, tail_plus1_w, valid_push_w)

    `REG_RST(u_head, 3, clk, rst, head_din_w, head_q)
    `REG_RST(u_tail, 3, clk, rst, tail_din_w, tail_q)

    // -------------------------------------------------------------------
    // Slot decoders -- one-hot push and pop targets
    // -------------------------------------------------------------------
    wire [3:0] head_dec_w;
    wire [3:0] tail_dec_w;
    `DECODER_N(u_head_dec, 2, head_ptr_w, head_dec_w)
    `DECODER_N(u_tail_dec, 2, tail_ptr_w, tail_dec_w)

    // Per-slot push_to_<i> and pop_from_<i>
    wire push_to_0_w, push_to_1_w, push_to_2_w, push_to_3_w;
    wire pop_from_0_w, pop_from_1_w, pop_from_2_w, pop_from_3_w;

    `AND_2(u_push_to_0, 1, push_to_0_w, valid_push_w, tail_dec_w[0])
    `AND_2(u_push_to_1, 1, push_to_1_w, valid_push_w, tail_dec_w[1])
    `AND_2(u_push_to_2, 1, push_to_2_w, valid_push_w, tail_dec_w[2])
    `AND_2(u_push_to_3, 1, push_to_3_w, valid_push_w, tail_dec_w[3])

    `AND_2(u_pop_from_0, 1, pop_from_0_w, valid_pop_w, head_dec_w[0])
    `AND_2(u_pop_from_1, 1, pop_from_1_w, valid_pop_w, head_dec_w[1])
    `AND_2(u_pop_from_2, 1, pop_from_2_w, valid_pop_w, head_dec_w[2])
    `AND_2(u_pop_from_3, 1, pop_from_3_w, valid_pop_w, head_dec_w[3])

    // Per-slot valid-bit WE and D
    //   valid_we_<i>  = push_to_<i> | pop_from_<i>
    //   valid_din_<i> = push_to_<i> ? wb_in_data_valid : 1'b0    (push wins)
    wire valid_we_0_w, valid_we_1_w, valid_we_2_w, valid_we_3_w;
    wire valid_din_0_w, valid_din_1_w, valid_din_2_w, valid_din_3_w;

    `OR_2(u_valid_we_0, 1, valid_we_0_w, push_to_0_w, pop_from_0_w)
    `OR_2(u_valid_we_1, 1, valid_we_1_w, push_to_1_w, pop_from_1_w)
    `OR_2(u_valid_we_2, 1, valid_we_2_w, push_to_2_w, pop_from_2_w)
    `OR_2(u_valid_we_3, 1, valid_we_3_w, push_to_3_w, pop_from_3_w)

    `MUX_2(u_valid_din_0, 1, valid_din_0_w, 1'b0, wb_in_data_valid, push_to_0_w)
    `MUX_2(u_valid_din_1, 1, valid_din_1_w, 1'b0, wb_in_data_valid, push_to_1_w)
    `MUX_2(u_valid_din_2, 1, valid_din_2_w, 1'b0, wb_in_data_valid, push_to_2_w)
    `MUX_2(u_valid_din_3, 1, valid_din_3_w, 1'b0, wb_in_data_valid, push_to_3_w)

    // -------------------------------------------------------------------
    // Slot registers (per-slot)
    // -------------------------------------------------------------------
    wire [14:0]  q_0_address_w, q_1_address_w, q_2_address_w, q_3_address_w;
    wire [15:0]  q_0_bit_vec_w, q_1_bit_vec_w, q_2_bit_vec_w, q_3_bit_vec_w;
    wire [127:0] q_0_data_w,    q_1_data_w,    q_2_data_w,    q_3_data_w;

    // ---- slot 0 ----
    `REG_RST_WE(u_q0_valid, 1,   clk, rst, valid_we_0_w, valid_din_0_w,        outputs_valid_0)
    `REG_RST_WE(u_q0_addr,  15,  clk, rst, push_to_0_w,  wb_in_data_address,   q_0_address_w)
    `REG_RST_WE(u_q0_bv,    16,  clk, rst, push_to_0_w,  wb_in_data_bit_vec,   q_0_bit_vec_w)
    `REG_RST_WE(u_q0_data,  128, clk, rst, push_to_0_w,  wb_in_data_data,      q_0_data_w)
    // ---- slot 1 ----
    `REG_RST_WE(u_q1_valid, 1,   clk, rst, valid_we_1_w, valid_din_1_w,        outputs_valid_1)
    `REG_RST_WE(u_q1_addr,  15,  clk, rst, push_to_1_w,  wb_in_data_address,   q_1_address_w)
    `REG_RST_WE(u_q1_bv,    16,  clk, rst, push_to_1_w,  wb_in_data_bit_vec,   q_1_bit_vec_w)
    `REG_RST_WE(u_q1_data,  128, clk, rst, push_to_1_w,  wb_in_data_data,      q_1_data_w)
    // ---- slot 2 ----
    `REG_RST_WE(u_q2_valid, 1,   clk, rst, valid_we_2_w, valid_din_2_w,        outputs_valid_2)
    `REG_RST_WE(u_q2_addr,  15,  clk, rst, push_to_2_w,  wb_in_data_address,   q_2_address_w)
    `REG_RST_WE(u_q2_bv,    16,  clk, rst, push_to_2_w,  wb_in_data_bit_vec,   q_2_bit_vec_w)
    `REG_RST_WE(u_q2_data,  128, clk, rst, push_to_2_w,  wb_in_data_data,      q_2_data_w)
    // ---- slot 3 ----
    `REG_RST_WE(u_q3_valid, 1,   clk, rst, valid_we_3_w, valid_din_3_w,        outputs_valid_3)
    `REG_RST_WE(u_q3_addr,  15,  clk, rst, push_to_3_w,  wb_in_data_address,   q_3_address_w)
    `REG_RST_WE(u_q3_bv,    16,  clk, rst, push_to_3_w,  wb_in_data_bit_vec,   q_3_bit_vec_w)
    `REG_RST_WE(u_q3_data,  128, clk, rst, push_to_3_w,  wb_in_data_data,      q_3_data_w)

    // -------------------------------------------------------------------
    // Direct per-slot address outputs (for dep-check view in WB.sv)
    // -------------------------------------------------------------------
    assign outputs_address_0 = q_0_address_w;
    assign outputs_address_1 = q_1_address_w;
    assign outputs_address_2 = q_2_address_w;
    assign outputs_address_3 = q_3_address_w;

    // -------------------------------------------------------------------
    // Head-selected outputs (head_address, bit_vec, data) via 4:1 muxes
    // -------------------------------------------------------------------
    `MUX_4(u_head_addr_mux, 15,  outputs_head_address,
           q_0_address_w, q_1_address_w, q_2_address_w, q_3_address_w,
           head_ptr_w)
    `MUX_4(u_head_bv_mux,   16,  outputs_bit_vec,
           q_0_bit_vec_w, q_1_bit_vec_w, q_2_bit_vec_w, q_3_bit_vec_w,
           head_ptr_w)
    `MUX_4(u_head_data_mux, 128, outputs_data,
           q_0_data_w,    q_1_data_w,    q_2_data_w,    q_3_data_w,
           head_ptr_w)

    // -------------------------------------------------------------------
    // Full / empty exposed
    // -------------------------------------------------------------------
    assign outputs_full  = q_full_w;
    assign outputs_empty = q_empty_w;

endmodule
