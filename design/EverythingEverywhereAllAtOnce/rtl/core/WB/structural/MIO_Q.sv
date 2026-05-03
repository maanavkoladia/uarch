// ============================================================================
// ACTIVE: Legacy SystemVerilog implementation.
// Reverted to legacy after the multi-module structural port broke regression.
// To re-enable the structural version: comment this module out and uncomment
// the structural one at the bottom of this file (and rewire its instantiation
// in WB.sv to flat ports).
// ============================================================================
module MIO_Q(
    input clk,
    input rst,
    input mio_inputs_t mio_input,
    output bool push_fail,
    output st_q_2_dcache_t outs
);


    mio_entry_t mio_q;
    bool full;
    bool empty;

    bool next_full;
    bool next_empty;

    bool valid_push;
    bool valid_pop;


    assign valid_push = mio_input.push &  (~full | mio_input.pop);
    assign valid_pop =  mio_input.pop & (~empty);
    assign push_fail = mio_input.push & (full & ~mio_input.pop);

//else if because if we have a valid push then the queue will be full no matter what
    always_comb begin
        // Default: maintain current state
        next_full = full;
        next_empty = empty;

        if (valid_push) begin
            next_full = 1;
            next_empty = 0;
        end
        else if (valid_pop) begin
            next_empty = 1;
            next_full = 0;
        end

    end
//work to do, if push
    always_ff @(posedge clk) begin
        if (!rst) begin
            full <= 0;
            empty <= 1;
            mio_q <= '{default: '0};
        end else begin
            if (valid_push) begin
                mio_q <= mio_input.data;  // Replace old with new, stay full
            end else if (valid_pop) begin
                mio_q.valid <= 1'b0;
            end
            full <= next_full;
            empty <= next_empty;
        end
    end

    assign outs = '{
        full: full,
        empty: empty,
        address: mio_q.address,
        bit_vec: '0,
        data: mio_q.data
    };



endmodule


// ============================================================================
// COMMENTED OUT: Pure structural port. Restore by uncommenting and commenting
// the legacy module above; also flip its WB.sv instantiation back to flat ports.
// ============================================================================
//
// // Pure structural port of MIO_Q (1-entry MIO store queue).
// //
// // Notes vs legacy:
// //   - Legacy carried a `mio_q.valid` flop that was written but NEVER read
// //     (it is not part of st_q_2_dcache_t). Omitted here as dead state.
// //   - Legacy carried a separate `empty` flop. In a single-entry queue,
// //     empty is always exactly ~full, so we synthesize it from full_q.
// //
// // Struct unrolling map:
// //   mio_input.data.valid    -> mio_input_data_valid     (1)
// //   mio_input.data.address  -> mio_input_data_address   (15)
// //   mio_input.data.data     -> mio_input_data_data      (128)
// //   mio_input.push          -> mio_input_push           (1)
// //   mio_input.pop           -> mio_input_pop            (1)
// //   outs.full               -> outs_full                (1)
// //   outs.empty              -> outs_empty               (1)
// //   outs.address            -> outs_address             (15)
// //   outs.bit_vec            -> outs_bit_vec             (16)  -- tied to 0
// //   outs.data               -> outs_data                (128)
//
// module MIO_Q (
//     input  wire         clk,
//     input  wire         rst,                  // active LOW
//
//     input  wire         mio_input_data_valid, // unused -- legacy dead bit
//     input  wire [14:0]  mio_input_data_address,
//     input  wire [127:0] mio_input_data_data,
//     input  wire         mio_input_push,
//     input  wire         mio_input_pop,
//
//     output wire         push_fail,
//
//     output wire         outs_full,
//     output wire         outs_empty,
//     output wire [14:0]  outs_address,
//     output wire [15:0]  outs_bit_vec,
//     output wire [127:0] outs_data
// );
//
//     wire full_q;
//
//     wire inv_full_w;
//     wire inv_pop_in_w;
//     wire or_pop_or_notfull_w;
//     wire valid_push_w;
//     wire valid_pop_w;
//     wire full_and_notpop_w;
//     wire inv_valid_pop_w;
//     wire full_hold_w;
//     wire next_full_w;
//
//     `INV_N(u_inv_full,   1, full_q,        inv_full_w)
//     `INV_N(u_inv_pop_in, 1, mio_input_pop, inv_pop_in_w)
//
//     // valid_push = push & (~full | pop)
//     `OR_2 (u_or_notfull_pop, 1, or_pop_or_notfull_w, inv_full_w, mio_input_pop)
//     `AND_2(u_valid_push,     1, valid_push_w, mio_input_push, or_pop_or_notfull_w)
//
//     // valid_pop  = pop & ~empty   (since empty = ~full_q, ~empty = full_q)
//     `AND_2(u_valid_pop,      1, valid_pop_w, mio_input_pop, full_q)
//
//     // push_fail = push & full & ~pop
//     `AND_2(u_full_notpop,    1, full_and_notpop_w, full_q, inv_pop_in_w)
//     `AND_2(u_push_fail,      1, push_fail, mio_input_push, full_and_notpop_w)
//
//     // next_full = valid_push | (full & ~valid_pop)
//     `INV_N(u_inv_vpop,       1, valid_pop_w, inv_valid_pop_w)
//     `AND_2(u_full_hold,      1, full_hold_w, full_q, inv_valid_pop_w)
//     `OR_2 (u_next_full,      1, next_full_w, valid_push_w, full_hold_w)
//
//     // outs_empty is just ~full_q (1-entry queue invariant)
//     `INV_N(u_outs_empty,     1, full_q, outs_empty)
//
//     // full_q register: always-clocked, sync active-low reset to 0.
//     `REG_RST(u_full_q, 1, clk, rst, next_full_w, full_q)
//
//     // address: WE = valid_push  (only updated on a real push)
//     `REG_RST_WE(u_qaddr, 15, clk, rst, valid_push_w, mio_input_data_address, outs_address)
//
//     // data: WE = valid_push
//     `REG_RST_WE(u_qdata, 128, clk, rst, valid_push_w, mio_input_data_data, outs_data)
//
//     assign outs_full    = full_q;
//     assign outs_bit_vec = 16'h0000;
//
// endmodule
