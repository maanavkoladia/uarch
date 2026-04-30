// Structural Verilog-2005 port of rtl/core/WB/ST_Q.sv
//
// 4-deep FIFO with extra-bit head/tail pointers (3 bits each = 1 wrap bit + 2-bit ptr).
// Push writes a 160-bit st_q_entry_t to q[tail_ptr]; pop clears q[head_ptr].valid.
// Outputs: full, empty, push_fail, per-entry (valid,address) for dep-check, and
// the head's (address, bit_vec, data) selected by head_ptr.

`include "STDCell_Macros.vh"
`include "WB_common_define.vh"

module ST_Q (
    input  wire                       clk,
    input  wire                       rst,            // active-low
    input  wire [`STQI_W - 1 : 0]     wb_in,
    output wire [`STQO_W - 1 : 0]     outputs
);

    //==================================================================
    // Unpack wb_in
    //==================================================================
    wire          wb_in_push;
    wire          wb_in_pop;
    wire          wb_in_data_valid;
    wire [14:0]   wb_in_data_address;
    wire [15:0]   wb_in_data_bitvec;
    wire [127:0]  wb_in_data_data;

    assign wb_in_push         = wb_in[`STQI_PUSH];
    assign wb_in_pop          = wb_in[`STQI_POP];
    assign wb_in_data_valid   = wb_in[`STQE_VALID];
    assign wb_in_data_address = wb_in[`STQE_ADDR_UB:`STQE_ADDR_LB];
    assign wb_in_data_bitvec  = wb_in[`STQE_VEC_UB:`STQE_VEC_LB];
    assign wb_in_data_data    = wb_in[`STQE_DATA_UB:`STQE_DATA_LB];

    //==================================================================
    // head / tail counters: 3 bits = 1 wrap bit + 2-bit ptr
    //==================================================================
    wire [2:0]  head_q;
    wire [2:0]  tail_q;
    wire [2:0]  head_next;
    wire [2:0]  tail_next;
    wire        head_cout_unused;
    wire        tail_cout_unused;
    wire [1:0]  head_ptr;
    wire [1:0]  tail_ptr;

    assign head_ptr = head_q[1:0];
    assign tail_ptr = tail_q[1:0];

    `ADD_N(add_head, 3, head_next, head_cout_unused, head_q, 3'b000, 1'b1)
    `ADD_N(add_tail, 3, tail_next, tail_cout_unused, tail_q, 3'b000, 1'b1)

    //==================================================================
    // q_full  = (head[2] != tail[2]) && (head[1:0] == tail[1:0])
    // q_empty = (head == tail)
    //==================================================================
    wire head_msb_inv;
    wire tail_msb_inv;
    wire ne_a;
    wire ne_b;
    wire msbs_diff;
    wire ptr_eq;
    wire q_full;
    wire q_empty;

    `INV_N(inv_head_msb, 1, head_q[2],     head_msb_inv)
    `INV_N(inv_tail_msb, 1, tail_q[2],     tail_msb_inv)
    `AND_2(and_ne_a,     1, ne_a,          head_q[2],     tail_msb_inv)
    `AND_2(and_ne_b,     1, ne_b,          head_msb_inv,  tail_q[2])
    `OR_2 (or_msbs_diff, 1, msbs_diff,     ne_a,          ne_b)
    `CMP_N(cmp_ptrs,     2, ptr_eq,        head_q[1:0],   tail_q[1:0])
    `AND_2(and_qfull,    1, q_full,        msbs_diff,     ptr_eq)
    `CMP_N(cmp_qempty,   3, q_empty,       head_q,        tail_q)

    //==================================================================
    // valid_push = push & (~full | pop)
    // valid_pop  = pop  & ~empty
    // push_fail  = push & full & ~pop
    //==================================================================
    wire q_full_inv;
    wire q_empty_inv;
    wire pop_inv;
    wire vp_or;
    wire valid_push;
    wire valid_pop;
    wire pf_pre;
    wire push_fail;

    `INV_N(inv_qfull,  1, q_full,     q_full_inv)
    `INV_N(inv_qempty, 1, q_empty,    q_empty_inv)
    `INV_N(inv_pop,    1, wb_in_pop,  pop_inv)
    `OR_2 (or_vp,      1, vp_or,      q_full_inv, wb_in_pop)
    `AND_2(and_vp,     1, valid_push, wb_in_push, vp_or)
    `AND_2(and_vpop,   1, valid_pop,  wb_in_pop,  q_empty_inv)
    `AND_2(and_pf_pre, 1, pf_pre,     q_full,     pop_inv)
    `AND_2(and_pf,     1, push_fail,  wb_in_push, pf_pre)

    //==================================================================
    // tail / head decoders (2-to-4)
    //==================================================================
    wire [3:0] tail_dec;
    wire [3:0] head_dec;
    `DECODER_N(dec_tail, 2, tail_ptr, tail_dec)
    `DECODER_N(dec_head, 2, head_ptr, head_dec)

    //==================================================================
    // 4 storage entries: per-entry valid / address / bit_vec / data
    //
    // Per-entry policy (matches SV NBA semantics):
    //   q[i].valid   : WE = push_i | pop_i, D = push_i & ~pop_i & wb_in.data.valid
    //                  (pop wins when both fire on same slot, per SV last-NBA-wins)
    //   q[i].address : WE = push_i, D = wb_in.data.address
    //   q[i].bit_vec : WE = push_i, D = wb_in.data.bit_vec
    //   q[i].data    : WE = push_i, D = wb_in.data.data
    //==================================================================
    wire [3:0]            q_valid_arr;
    wire [4*15  - 1 : 0]  q_addr_arr;
    wire [4*16  - 1 : 0]  q_vec_arr;
    wire [4*128 - 1 : 0]  q_data_arr;

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_entry
            wire push_i;
            wire pop_i;
            wire pop_i_inv;
            wire valid_we_i;
            wire vd_pre;
            wire valid_d_i;

            `AND_2(and_push_i, 1, push_i,     valid_push,        tail_dec[i])
            `AND_2(and_pop_i,  1, pop_i,      valid_pop,         head_dec[i])
            `OR_2 (or_we_i,    1, valid_we_i, push_i,            pop_i)
            `INV_N(inv_pop_i,  1, pop_i,      pop_i_inv)
            `AND_2(and_vdp,    1, vd_pre,     wb_in_data_valid,  pop_i_inv)
            `AND_2(and_vd,     1, valid_d_i,  push_i,            vd_pre)

            `REG_RST_WE(ff_valid_i, 1,   clk, rst, valid_we_i, valid_d_i,          q_valid_arr[i])
            `REG_RST_WE(ff_addr_i,  15,  clk, rst, push_i,     wb_in_data_address, q_addr_arr[i*15  +: 15])
            `REG_RST_WE(ff_vec_i,   16,  clk, rst, push_i,     wb_in_data_bitvec,  q_vec_arr [i*16  +: 16])
            `REG_RST_WE(ff_data_i,  128, clk, rst, push_i,     wb_in_data_data,    q_data_arr[i*128 +: 128])
        end
    endgenerate

    //==================================================================
    // head / tail flops
    //==================================================================
    `REG_RST_WE(ff_head, 3, clk, rst, valid_pop,  head_next, head_q)
    `REG_RST_WE(ff_tail, 3, clk, rst, valid_push, tail_next, tail_q)

    //==================================================================
    // Output muxes (head_address, bit_vec, data) selected by head_ptr
    //==================================================================
    wire [14:0]  out_head_addr;
    wire [15:0]  out_bit_vec;
    wire [127:0] out_data;

    `MUX_4(mux_head_addr, 15, out_head_addr,
            q_addr_arr[0   +: 15],
            q_addr_arr[15  +: 15],
            q_addr_arr[30  +: 15],
            q_addr_arr[45  +: 15],
            head_ptr)

    `MUX_4(mux_bit_vec, 16, out_bit_vec,
            q_vec_arr[0   +: 16],
            q_vec_arr[16  +: 16],
            q_vec_arr[32  +: 16],
            q_vec_arr[48  +: 16],
            head_ptr)

    `MUX_4(mux_data, 128, out_data,
            q_data_arr[0    +: 128],
            q_data_arr[128  +: 128],
            q_data_arr[256  +: 128],
            q_data_arr[384  +: 128],
            head_ptr)

    //==================================================================
    // Pack outputs
    //==================================================================
    assign outputs[`STQO_FULL]                            = q_full;
    assign outputs[`STQO_EMPTY]                           = q_empty;
    assign outputs[`STQO_VALID(0)]                        = q_valid_arr[0];
    assign outputs[`STQO_VALID(1)]                        = q_valid_arr[1];
    assign outputs[`STQO_VALID(2)]                        = q_valid_arr[2];
    assign outputs[`STQO_VALID(3)]                        = q_valid_arr[3];
    assign outputs[`STQO_ADDR_UB(0):`STQO_ADDR_LB(0)]     = q_addr_arr[0  +: 15];
    assign outputs[`STQO_ADDR_UB(1):`STQO_ADDR_LB(1)]     = q_addr_arr[15 +: 15];
    assign outputs[`STQO_ADDR_UB(2):`STQO_ADDR_LB(2)]     = q_addr_arr[30 +: 15];
    assign outputs[`STQO_ADDR_UB(3):`STQO_ADDR_LB(3)]     = q_addr_arr[45 +: 15];
    assign outputs[`STQO_HEAD_ADDR_UB:`STQO_HEAD_ADDR_LB] = out_head_addr;
    assign outputs[`STQO_BITVEC_UB:`STQO_BITVEC_LB]       = out_bit_vec;
    assign outputs[`STQO_DATA_UB:`STQO_DATA_LB]           = out_data;
    assign outputs[`STQO_PUSH_FAIL]                       = push_fail;

endmodule
