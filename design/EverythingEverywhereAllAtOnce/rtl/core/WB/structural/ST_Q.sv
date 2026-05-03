// ============================================================================
// ACTIVE: Pure structural port of ST_Q (4-deep store-queue FIFO).
//
// FIFO semantics (matches the legacy SV exactly, including the simultaneous-
// push+pop race on the valid bit -- see PER-SLOT VALID BIT below).
//
//   Pointers head, tail are each clog2(DEPTH)+1 = 3 bits, with the extra MSB
//   acting as a wrap bit.
//     head_ptr = head[1:0]   tail_ptr = tail[1:0]
//     empty:  head == tail                            (all 3 bits equal)
//     full:   head[2] != tail[2] AND head[1:0] == tail[1:0]
//
//   Per cycle:
//     valid_push = push & (~full | pop)
//     valid_pop  = pop  & ~empty
//     push_fail  = push & full & ~pop
//
// Per-slot register WE / DIN (faithful to the legacy):
//
//   address / bit_vec / data:
//     WE_<i>  = push_to_<i>
//     DIN     = wb_in.data.<field>
//     -- only the push touches these fields, so no race.
//
//   valid:
//     WE_<i>  = push_to_<i> | pop_from_<i>
//     DIN_<i> = push_to_<i> & ~pop_from_<i> & wb_in.data.valid
//     -- when push and pop hit the SAME slot (only possible when full),
//        the legacy SV has two NBAs to q[X].valid:
//            q[X]       <= wb_in.data;       (sets all fields)
//            q[X].valid <= 1'b0;             (overrides valid)
//        Per IEEE 1800 the order is undefined, but every common simulator
//        resolves last-NBA-wins, so pop wins -> valid becomes 0. The AND_3
//        above implements exactly that: when pop_from_i is asserted,
//        valid_din is forced to 0 regardless of the incoming wb_in.data.valid.
//
// where push_to_i  = valid_push & (tail_ptr == i),
//       pop_from_i = valid_pop  & (head_ptr == i),
// each derived via DECODER_N + AND_2.
//
// Reset (active LOW): all registers clear to 0.  head=tail=0 -> empty.
//
// Performance note: q_empty is computed as AND_2(eq_msb, eq_low) reusing the
// two equality signals already needed for q_full, instead of a redundant
// 3-bit CMP_N. Same logic, one less comparator on the empty path.
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
//
// To revert to the legacy SV implementation: comment this module out and
// uncomment the legacy block at the bottom of this file (and switch the
// WB.sv instantiation back to the struct-based generate loop).
// ============================================================================
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
    //   eq_low  = (head[1:0] == tail[1:0])
    //   eq_msb  = (head[2]   == tail[2])
    //   q_empty = eq_msb & eq_low                 (all 3 bits equal)
    //   q_full  = ~eq_msb & eq_low                (lower equal, MSB differ)
    // -------------------------------------------------------------------
    wire eq_low_w;
    wire eq_msb_w;
    wire neq_msb_w;
    wire q_full_w;
    wire q_empty_w;

    `CMP_N(u_eq_low, 2, eq_low_w, head_ptr_w, tail_ptr_w)
    `CMP_N(u_eq_msb, 1, eq_msb_w, head_q[2], tail_q[2])
    `INV_N(u_neq_msb, 1, eq_msb_w, neq_msb_w)
    `AND_2(u_q_full,  1, q_full_w, neq_msb_w, eq_low_w)
    `AND_2(u_q_empty, 1, q_empty_w, eq_msb_w, eq_low_w)

    // -------------------------------------------------------------------
    // valid_push / valid_pop / push_fail
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

    // Per-slot valid-bit WE and DIN
    //   WE_<i>  = push_to_<i> | pop_from_<i>
    //   DIN_<i> = push_to_<i> & ~pop_from_<i> & wb_in_data_valid
    //     -> push only (no pop):    DIN = wb_in_data_valid
    //     -> pop only (no push):    DIN = 0
    //     -> push AND pop same slot:DIN = 0   (pop wins, matches legacy
    //                                          last-NBA semantic)
    //     -> neither:               WE=0 (don't care)
    wire valid_we_0_w,    valid_we_1_w,    valid_we_2_w,    valid_we_3_w;
    wire inv_pop_from_0_w,inv_pop_from_1_w,inv_pop_from_2_w,inv_pop_from_3_w;
    wire valid_din_0_w,   valid_din_1_w,   valid_din_2_w,   valid_din_3_w;

    `OR_2 (u_valid_we_0, 1, valid_we_0_w, push_to_0_w, pop_from_0_w)
    `OR_2 (u_valid_we_1, 1, valid_we_1_w, push_to_1_w, pop_from_1_w)
    `OR_2 (u_valid_we_2, 1, valid_we_2_w, push_to_2_w, pop_from_2_w)
    `OR_2 (u_valid_we_3, 1, valid_we_3_w, push_to_3_w, pop_from_3_w)

    `INV_N(u_inv_pop_from_0, 1, pop_from_0_w, inv_pop_from_0_w)
    `INV_N(u_inv_pop_from_1, 1, pop_from_1_w, inv_pop_from_1_w)
    `INV_N(u_inv_pop_from_2, 1, pop_from_2_w, inv_pop_from_2_w)
    `INV_N(u_inv_pop_from_3, 1, pop_from_3_w, inv_pop_from_3_w)

    `AND_3(u_valid_din_0, 1, valid_din_0_w, push_to_0_w, inv_pop_from_0_w, wb_in_data_valid)
    `AND_3(u_valid_din_1, 1, valid_din_1_w, push_to_1_w, inv_pop_from_1_w, wb_in_data_valid)
    `AND_3(u_valid_din_2, 1, valid_din_2_w, push_to_2_w, inv_pop_from_2_w, wb_in_data_valid)
    `AND_3(u_valid_din_3, 1, valid_din_3_w, push_to_3_w, inv_pop_from_3_w, wb_in_data_valid)

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


// ============================================================================
// COMMENTED OUT: Legacy SystemVerilog implementation. Restore by uncommenting
// and commenting the structural module above; also flip its WB.sv
// instantiation back to the struct-based generate loop.
// ============================================================================
//
// import common_pkg::*;
// import WriteBack_pkg::*;
//
// module ST_Q (
//
//     input wire clk,
//     input wire rst,
//
//     input st_q_inputs_t wb_in,
//
//     output st_q_outputs_t outputs
// );
//     //head represents the front of the queue. Tail represents the back
//     //heads points to the current value. Tail points to the next slot.
//
//
//
//     logic [$clog2(ST_Q_DEPTH):0] head;
//     logic [$clog2(ST_Q_DEPTH):0] tail;
//
//     logic [$clog2(ST_Q_DEPTH)-1:0] head_ptr;
//     logic [$clog2(ST_Q_DEPTH)-1:0] tail_ptr;
//
//     assign head_ptr = head[$clog2(ST_Q_DEPTH)-1:0];
//     assign tail_ptr = tail[$clog2(ST_Q_DEPTH)-1:0];
//
//     bool q_full, q_empty;
//     bool valid_push, valid_pop;
//
//
//     //create the q
//     st_q_entry_t q[ST_Q_DEPTH];
//
//     // Extra bit method for full/empty...probably better for combinational logic in structural.
//     assign q_full = (head[$clog2(ST_Q_DEPTH)] != tail[$clog2(ST_Q_DEPTH)]) &&
//                     (head[$clog2(ST_Q_DEPTH)-1:0] == tail[$clog2(ST_Q_DEPTH)-1:0]);
//     assign q_empty = (head == tail);
//
//
//     assign valid_push = wb_in.push &  (~q_full | wb_in.pop);
//     assign valid_pop =  wb_in.pop & (~q_empty);
//
//     //outputs
//     always_comb begin
//         outputs.full = q_full;
//         outputs.empty = q_empty;
//         outputs.head_address = q[head_ptr].address;
//         outputs.bit_vec = q[head_ptr].bit_vec;
//         outputs.data = q[head_ptr].data;
//         outputs.push_fail = wb_in.push & (q_full & ~wb_in.pop);
//         //this is for the dep checks
//         for(int i = 0;  i < ST_Q_DEPTH; i++)begin
//             outputs.valid[i] = q[i].valid;
//             outputs.address[i] = q[i].address;
//         end
//
//     end
//
//     always_ff @(posedge clk) begin
//         if (!rst) begin
//             head <= 0;
//             tail <= 0;
//             for(int i = 0; i < ST_Q_DEPTH; i++)begin
//                 q[i] <= '{default : '0};
//             end
//         end
//         else begin
//             // Push: write to tail and increment
//             if(valid_push) begin
//                 q[tail_ptr] <= wb_in.data;  // wb_in.data is already st_q_entry_t
//                 tail <= tail + 1;
//             end
//             if(valid_pop)begin
//                 q[head_ptr].valid <= 1'b0;
//                 head <= head + 1;
//             end
//         end
//     end
//
//     // Assertion: Check for invalid pop from empty queue
//     // If this fires, there's a logic flaw in the system
//     assert property (@(posedge clk) disable iff (rst)
//         !(wb_in.pop & q_empty)
//     ) else $error("ST_Q: Invalid pop from cache - attempted to pop from empty queue at time %0t", $time);
//
// endmodule
