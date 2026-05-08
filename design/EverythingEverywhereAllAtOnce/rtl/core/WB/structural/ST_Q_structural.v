// ============================================================================
// ACTIVE: Pure structural port of ST_Q (5-entry shift-register store queue).
//
// Functional summary (matches the new shift-register SV bit-for-bit):
//   * 5-entry array q[0..4]. q[0] is the head; q[4] is a sentinel that is
//     ALWAYS invalid (never written by the SV, hardwired to 0 here).
//   * One-hot pointer next_push[4:0]; bit i set means there are i entries.
//     Reset = 5'b00001 (empty). Full = 5'b10000.
//   * Push appends to the slot indicated by next_push (then advances).
//   * Pop removes q[0] and shifts everything down by one (q[i] <= q[i+1]).
//   * Push+Pop together shifts down AND inserts new data at the position
//     vacated, leaving the entry count unchanged.
//
// Per-cycle slot DIN (when WE_i = vP | vp = 1):
//   sel = {vP, vp}    DIN_i =
//   00 (idle)         q[i]                                  (don't care, WE=0)
//   01 (pop only)     q[i+1]
//   10 (push only)    next_push[i]   ? wb_in.data : q[i]
//   11 (push+pop)     next_push[i+1] ? wb_in.data : q[i+1]
//
// Implemented as one MUX_4 (sel = {vP, vp}) fed by two parallel MUX_2 sub-
// muxes for in2/in3. Data path is 2 mux levels deep.
//
// next_push register update:
//   Push only (vP=1, vp=0):  next_push <= next_push << 1
//   Pop only  (vP=0, vp=1):  next_push <= next_push >> 1
//   Push+Pop  (vP=1, vp=1):  hold (one in, one out)
//   Idle      (vP=0, vp=0):  hold
//   WE = vP XOR vp           (write only when push-only or pop-only)
//
// Two implementation simplifications, both behaviorally equivalent to the SV:
//
//   (a) The legacy SV reset value of next_push = 5'b00001 cannot be expressed
//       directly with the project's standard MPS_reg_rst_we$ cell (resets to
//       0). We store next_push[4:1] in a 4-bit register (resets to 4'b0000)
//       and reconstruct next_push[0] = NOR4(stored). All one-hot semantics
//       are preserved:
//         stored=0000 -> next_push=00001 (empty)   <- reset state
//         stored=0001 -> next_push=00010 (1 entry)
//         stored=0010 -> next_push=00100 (2)
//         stored=0100 -> next_push=01000 (3)
//         stored=1000 -> next_push=10000 (full)
//       The shifts compose cleanly:
//         <<1: new_stored = {old_stored[2:0], next_push_low_w}
//         >>1: new_stored = {1'b0,            old_stored[3:1]}
//
//   (b) q[4] is hardwired to all zeros (the SV never writes it after reset).
//       The MUX_2/MUX_4 inputs that would read q[4] are wired to literal 0.
//       Synthesis collapses these to AND gates -- no q[4] register needed.
//
// Reset (active LOW): all registers clear to 0 via MPS_reg_rst_we$ CLR(rst).
//
// To revert to the legacy SV implementation: comment this module out and
// uncomment the legacy block at the bottom of this file (and switch the
// WB.sv instantiations back to the struct-based generate loop).
// ============================================================================

module ST_Q (
    input  wire         clk,
    input  wire         rst,            // active LOW

    input  wire         wb_in_data_valid,
    input  wire [14:0]  wb_in_data_address,
    input  wire [15:0]  wb_in_data_bit_vec,
    input  wire [127:0] wb_in_data_data,
    input  wire         wb_in_push,
    input  wire         wb_in_pop,

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

    // ===================================================================
    // next_push: 5-bit one-hot pointer
    //   storage  = next_push_high_q[3:0] = next_push[4:1] (resets to 0)
    //   computed = next_push_low_w        = NOR(stored)   (= next_push[0])
    //   reconstructed full view = next_push_w[4:0]
    // ===================================================================
    wire [3:0] next_push_high_q;
    wire       next_push_low_w;
    wire [4:0] next_push_w;

    `NOR_4(u_np_low, 1, next_push_low_w,
           next_push_high_q[0], next_push_high_q[1],
           next_push_high_q[2], next_push_high_q[3])

    // next_push_w[i] feeds entry update muxes outside the ST_Q control loop.
    //   bit 0:     u_smpo0 cluster        (160 leaves)  → bufferH256$
    //   bits 1..3: 2 clusters each         (~320 leaves) → bufferH1024$
    //   bit 4:     u_smpp3 cluster        (160 leaves)  → bufferH256$
    // Internal feedback (np_left/right_shift, full/empty, NOR for low_w) uses
    // next_push_high_q / next_push_low_w directly so the buffers don't sit in
    // the next_push state-update loop.
    //
    // Fanout split: bit 3 of next_push_high_q (= full_w) is consumed by both
    // tight internal feedback (u_full_notpop, u_inv_full, u_np_din right-shift,
    // u_np_low NOR) AND external taps (u_buf_npw4, outputs_full → DCache_Arb).
    // To keep the internal loop tight (no buffer delay) we add a 1-bit
    // replicated register u_next_push_full_ext (instantiated after u_next_push
    // below, where its DIN/WE wires are declared) driven by the same
    // din[3]/we/clk/rst -- bit-identical to high_q[3] every cycle, but its
    // own physical net so the external loads don't accumulate on the
    // internal-feedback Q output.
    wire next_push_full_ext_w;   // = high_q[3]  (replicated for external)

    wire [4:0] next_push_w_raw;
    assign next_push_w_raw = {next_push_full_ext_w, next_push_high_q[2:0], next_push_low_w};
    bufferH256$  u_buf_npw0 (.out(next_push_w[0]), .in(next_push_w_raw[0]));
    bufferH1024$ u_buf_npw1 (.out(next_push_w[1]), .in(next_push_w_raw[1]));
    bufferH1024$ u_buf_npw2 (.out(next_push_w[2]), .in(next_push_w_raw[2]));
    bufferH1024$ u_buf_npw3 (.out(next_push_w[3]), .in(next_push_w_raw[3]));
    bufferH256$  u_buf_npw4 (.out(next_push_w[4]), .in(next_push_w_raw[4]));

    // ===================================================================
    // full / empty / valid_push / valid_pop / push_fail
    //   full  = next_push[4]
    //   empty = next_push[0]
    //   valid_push = push & (~full | pop)
    //   valid_pop  = pop  & ~empty
    //   push_fail  = push & full & ~pop
    // ===================================================================
    wire full_w;
    wire empty_w;
    assign full_w  = next_push_high_q[3];   // next_push[4]
    assign empty_w = next_push_low_w;       // next_push[0]

    wire inv_full_w;
    wire inv_empty_w;
    wire inv_pop_in_w;
    `INV_N(u_inv_full,    1, full_w,    inv_full_w)
    `INV_N(u_inv_empty,   1, empty_w,   inv_empty_w)
    `INV_N(u_inv_pop_in,  1, wb_in_pop, inv_pop_in_w)

    wire or_notfull_pop_w;
    wire valid_push_w;
    wire valid_pop_w;
    wire valid_push_raw_w;
    wire valid_pop_raw_w;
    `OR_2 (u_or_nf_pop,   1, or_notfull_pop_w, inv_full_w, wb_in_pop)
    `AND_2(u_valid_push,  1, valid_push_raw_w, wb_in_push, or_notfull_pop_w)
    `AND_2(u_valid_pop,   1, valid_pop_raw_w,  wb_in_pop,  inv_empty_w)
    // valid_push / valid_pop fan out to ~640 MUX_4 selects across all 4
    // entries (4 entries x (1+15+16+128 bits) = 640 leaves) plus a few
    // small consumers. bufferH1024$ (rated 1024, 0.60 ns typ) is the right
    // single-cell fit; splitting per-entry would only save 0.06 ns at 4x
    // the cell count.
    bufferH1024$ u_buf_vp_push (.out(valid_push_w), .in(valid_push_raw_w));
    bufferH1024$ u_buf_vp_pop  (.out(valid_pop_w),  .in(valid_pop_raw_w));

    wire full_and_notpop_w;
    `AND_2(u_full_notpop, 1, full_and_notpop_w, full_w, inv_pop_in_w)
    `AND_2(u_push_fail,   1, outputs_push_fail, wb_in_push, full_and_notpop_w)

    // outputs_full uses the replicated u_next_push_full_ext copy so the
    // external load (DCache_Arb g_st_override) does not pile onto the
    // internal-feedback Q[3] of u_next_push.
    assign outputs_full  = next_push_full_ext_w;
    assign outputs_empty = empty_w;

    // ===================================================================
    // next_push register update
    //   WE  = (vP & ~vp) | (~vP & vp)             (i.e. vP XOR vp)
    //   DIN = vp ? right_shift : left_shift
    //   left_shift  = {high[2:0], low}
    //   right_shift = {1'b0,      high[3:1]}
    // ===================================================================
    wire inv_vp_w;
    wire inv_vP_w;
    wire vP_only_w;
    wire vp_only_w;
    wire next_push_we_w;
    `INV_N(u_inv_vp,   1, valid_pop_w,  inv_vp_w)
    `INV_N(u_inv_vP,   1, valid_push_w, inv_vP_w)
    `AND_2(u_vP_only,  1, vP_only_w, valid_push_w, inv_vp_w)
    `AND_2(u_vp_only,  1, vp_only_w, inv_vP_w, valid_pop_w)
    `OR_2 (u_np_we,    1, next_push_we_w, vP_only_w, vp_only_w)

    wire [3:0] np_left_shift_w;
    wire [3:0] np_right_shift_w;
    assign np_left_shift_w  = {next_push_high_q[2:0], next_push_low_w};
    assign np_right_shift_w = {1'b0, next_push_high_q[3:1]};

    wire [3:0] next_push_din_w;
    `MUX_2(u_np_din, 4, next_push_din_w, np_left_shift_w, np_right_shift_w, valid_pop_w)

    `REG_RST_WE(u_next_push, 4, clk, rst, next_push_we_w, next_push_din_w, next_push_high_q)

    // External-fanout replica of u_next_push bit 3 (= full_w). Same DIN/WE/
    // CLK/RST as u_next_push, so its Q is bit-identical to high_q[3] every
    // cycle. Drives only u_buf_npw4 + outputs_full so the internal-feedback
    // Q[3] of u_next_push stays at fanout 4.
    `REG_RST_WE(u_next_push_full_ext, 1, clk, rst,
                next_push_we_w, next_push_din_w[3], next_push_full_ext_w)

    // ===================================================================
    // Slot register signals (q[0..3])
    //   q[4] hardwired to literal 0 in the muxes (no register).
    // ===================================================================
    wire        q_0_valid_w, q_1_valid_w, q_2_valid_w, q_3_valid_w;
    wire [14:0] q_0_address_w, q_1_address_w, q_2_address_w, q_3_address_w;
    wire [15:0] q_0_bit_vec_w, q_1_bit_vec_w, q_2_bit_vec_w, q_3_bit_vec_w;
    wire [127:0] q_0_data_w, q_1_data_w, q_2_data_w, q_3_data_w;

    // Common slot WE and 4:1 MUX sel
    wire we_w;
    wire [1:0] sel_w;
    wire we_w_raw;
    `OR_2(u_slot_we, 1, we_w_raw, valid_push_w, valid_pop_w)
    // we_w drives 16 reg-bank WE pins (4 entries x 4 widths) + a few extras
    // = fanout 20. bufferH64$ rated 64 — exact fit at 0.30 ns typ.
    bufferH64$ u_buf_we (.out(we_w), .in(we_w_raw));
    assign sel_w = {valid_push_w, valid_pop_w};

    // -------- Slot 0 (q[i]=q[0], q[i+1]=q[1]) --------
    wire        smpo0_valid_w, smpp0_valid_w;
    wire [14:0] smpo0_address_w, smpp0_address_w;
    wire [15:0] smpo0_bit_vec_w, smpp0_bit_vec_w;
    wire [127:0] smpo0_data_w,   smpp0_data_w;

    // smpo0 = next_push[0] ? wb_in.data : q[0]   (push-only sub-mux)
    `MUX_2(u_smpo0_v, 1,   smpo0_valid_w,   q_0_valid_w,   wb_in_data_valid,   next_push_w[0])
    `MUX_2(u_smpo0_a, 15,  smpo0_address_w, q_0_address_w, wb_in_data_address, next_push_w[0])
    `MUX_2(u_smpo0_b, 16,  smpo0_bit_vec_w, q_0_bit_vec_w, wb_in_data_bit_vec, next_push_w[0])
    `MUX_2(u_smpo0_d, 128, smpo0_data_w,    q_0_data_w,    wb_in_data_data,    next_push_w[0])

    // smpp0 = next_push[1] ? wb_in.data : q[1]   (push+pop sub-mux)
    `MUX_2(u_smpp0_v, 1,   smpp0_valid_w,   q_1_valid_w,   wb_in_data_valid,   next_push_w[1])
    `MUX_2(u_smpp0_a, 15,  smpp0_address_w, q_1_address_w, wb_in_data_address, next_push_w[1])
    `MUX_2(u_smpp0_b, 16,  smpp0_bit_vec_w, q_1_bit_vec_w, wb_in_data_bit_vec, next_push_w[1])
    `MUX_2(u_smpp0_d, 128, smpp0_data_w,    q_1_data_w,    wb_in_data_data,    next_push_w[1])

    // DIN_0 = MUX_4(in0=q[0], in1=q[1], in2=smpo0, in3=smpp0, sel={vP,vp})
    wire        din_0_valid_w;
    wire [14:0] din_0_address_w;
    wire [15:0] din_0_bit_vec_w;
    wire [127:0] din_0_data_w;
    `MUX_4(u_din0_v, 1,   din_0_valid_w,   q_0_valid_w,   q_1_valid_w,   smpo0_valid_w,   smpp0_valid_w,   sel_w)
    `MUX_4(u_din0_a, 15,  din_0_address_w, q_0_address_w, q_1_address_w, smpo0_address_w, smpp0_address_w, sel_w)
    `MUX_4(u_din0_b, 16,  din_0_bit_vec_w, q_0_bit_vec_w, q_1_bit_vec_w, smpo0_bit_vec_w, smpp0_bit_vec_w, sel_w)
    `MUX_4(u_din0_d, 128, din_0_data_w,    q_0_data_w,    q_1_data_w,    smpo0_data_w,    smpp0_data_w,    sel_w)

    `REG_RST_WE(u_q0_v, 1,   clk, rst, we_w, din_0_valid_w,   q_0_valid_w)
    `REG_RST_WE(u_q0_a, 15,  clk, rst, we_w, din_0_address_w, q_0_address_w)
    `REG_RST_WE(u_q0_b, 16,  clk, rst, we_w, din_0_bit_vec_w, q_0_bit_vec_w)
    `REG_RST_WE(u_q0_d, 128, clk, rst, we_w, din_0_data_w,    q_0_data_w)

    // -------- Slot 1 (q[i]=q[1], q[i+1]=q[2]) --------
    wire        smpo1_valid_w, smpp1_valid_w;
    wire [14:0] smpo1_address_w, smpp1_address_w;
    wire [15:0] smpo1_bit_vec_w, smpp1_bit_vec_w;
    wire [127:0] smpo1_data_w,   smpp1_data_w;

    `MUX_2(u_smpo1_v, 1,   smpo1_valid_w,   q_1_valid_w,   wb_in_data_valid,   next_push_w[1])
    `MUX_2(u_smpo1_a, 15,  smpo1_address_w, q_1_address_w, wb_in_data_address, next_push_w[1])
    `MUX_2(u_smpo1_b, 16,  smpo1_bit_vec_w, q_1_bit_vec_w, wb_in_data_bit_vec, next_push_w[1])
    `MUX_2(u_smpo1_d, 128, smpo1_data_w,    q_1_data_w,    wb_in_data_data,    next_push_w[1])

    `MUX_2(u_smpp1_v, 1,   smpp1_valid_w,   q_2_valid_w,   wb_in_data_valid,   next_push_w[2])
    `MUX_2(u_smpp1_a, 15,  smpp1_address_w, q_2_address_w, wb_in_data_address, next_push_w[2])
    `MUX_2(u_smpp1_b, 16,  smpp1_bit_vec_w, q_2_bit_vec_w, wb_in_data_bit_vec, next_push_w[2])
    `MUX_2(u_smpp1_d, 128, smpp1_data_w,    q_2_data_w,    wb_in_data_data,    next_push_w[2])

    wire        din_1_valid_w;
    wire [14:0] din_1_address_w;
    wire [15:0] din_1_bit_vec_w;
    wire [127:0] din_1_data_w;
    `MUX_4(u_din1_v, 1,   din_1_valid_w,   q_1_valid_w,   q_2_valid_w,   smpo1_valid_w,   smpp1_valid_w,   sel_w)
    `MUX_4(u_din1_a, 15,  din_1_address_w, q_1_address_w, q_2_address_w, smpo1_address_w, smpp1_address_w, sel_w)
    `MUX_4(u_din1_b, 16,  din_1_bit_vec_w, q_1_bit_vec_w, q_2_bit_vec_w, smpo1_bit_vec_w, smpp1_bit_vec_w, sel_w)
    `MUX_4(u_din1_d, 128, din_1_data_w,    q_1_data_w,    q_2_data_w,    smpo1_data_w,    smpp1_data_w,    sel_w)

    `REG_RST_WE(u_q1_v, 1,   clk, rst, we_w, din_1_valid_w,   q_1_valid_w)
    `REG_RST_WE(u_q1_a, 15,  clk, rst, we_w, din_1_address_w, q_1_address_w)
    `REG_RST_WE(u_q1_b, 16,  clk, rst, we_w, din_1_bit_vec_w, q_1_bit_vec_w)
    `REG_RST_WE(u_q1_d, 128, clk, rst, we_w, din_1_data_w,    q_1_data_w)

    // -------- Slot 2 (q[i]=q[2], q[i+1]=q[3]) --------
    wire        smpo2_valid_w, smpp2_valid_w;
    wire [14:0] smpo2_address_w, smpp2_address_w;
    wire [15:0] smpo2_bit_vec_w, smpp2_bit_vec_w;
    wire [127:0] smpo2_data_w,   smpp2_data_w;

    `MUX_2(u_smpo2_v, 1,   smpo2_valid_w,   q_2_valid_w,   wb_in_data_valid,   next_push_w[2])
    `MUX_2(u_smpo2_a, 15,  smpo2_address_w, q_2_address_w, wb_in_data_address, next_push_w[2])
    `MUX_2(u_smpo2_b, 16,  smpo2_bit_vec_w, q_2_bit_vec_w, wb_in_data_bit_vec, next_push_w[2])
    `MUX_2(u_smpo2_d, 128, smpo2_data_w,    q_2_data_w,    wb_in_data_data,    next_push_w[2])

    `MUX_2(u_smpp2_v, 1,   smpp2_valid_w,   q_3_valid_w,   wb_in_data_valid,   next_push_w[3])
    `MUX_2(u_smpp2_a, 15,  smpp2_address_w, q_3_address_w, wb_in_data_address, next_push_w[3])
    `MUX_2(u_smpp2_b, 16,  smpp2_bit_vec_w, q_3_bit_vec_w, wb_in_data_bit_vec, next_push_w[3])
    `MUX_2(u_smpp2_d, 128, smpp2_data_w,    q_3_data_w,    wb_in_data_data,    next_push_w[3])

    wire        din_2_valid_w;
    wire [14:0] din_2_address_w;
    wire [15:0] din_2_bit_vec_w;
    wire [127:0] din_2_data_w;
    `MUX_4(u_din2_v, 1,   din_2_valid_w,   q_2_valid_w,   q_3_valid_w,   smpo2_valid_w,   smpp2_valid_w,   sel_w)
    `MUX_4(u_din2_a, 15,  din_2_address_w, q_2_address_w, q_3_address_w, smpo2_address_w, smpp2_address_w, sel_w)
    `MUX_4(u_din2_b, 16,  din_2_bit_vec_w, q_2_bit_vec_w, q_3_bit_vec_w, smpo2_bit_vec_w, smpp2_bit_vec_w, sel_w)
    `MUX_4(u_din2_d, 128, din_2_data_w,    q_2_data_w,    q_3_data_w,    smpo2_data_w,    smpp2_data_w,    sel_w)

    `REG_RST_WE(u_q2_v, 1,   clk, rst, we_w, din_2_valid_w,   q_2_valid_w)
    `REG_RST_WE(u_q2_a, 15,  clk, rst, we_w, din_2_address_w, q_2_address_w)
    `REG_RST_WE(u_q2_b, 16,  clk, rst, we_w, din_2_bit_vec_w, q_2_bit_vec_w)
    `REG_RST_WE(u_q2_d, 128, clk, rst, we_w, din_2_data_w,    q_2_data_w)

    // -------- Slot 3 (q[i]=q[3], q[i+1]=q[4]=hardwired 0) --------
    wire        smpo3_valid_w, smpp3_valid_w;
    wire [14:0] smpo3_address_w, smpp3_address_w;
    wire [15:0] smpo3_bit_vec_w, smpp3_bit_vec_w;
    wire [127:0] smpo3_data_w,   smpp3_data_w;

    `MUX_2(u_smpo3_v, 1,   smpo3_valid_w,   q_3_valid_w,   wb_in_data_valid,   next_push_w[3])
    `MUX_2(u_smpo3_a, 15,  smpo3_address_w, q_3_address_w, wb_in_data_address, next_push_w[3])
    `MUX_2(u_smpo3_b, 16,  smpo3_bit_vec_w, q_3_bit_vec_w, wb_in_data_bit_vec, next_push_w[3])
    `MUX_2(u_smpo3_d, 128, smpo3_data_w,    q_3_data_w,    wb_in_data_data,    next_push_w[3])

    // q[4] inputs are literal 0 (sentinel always invalid)
    `MUX_2(u_smpp3_v, 1,   smpp3_valid_w,   1'b0,   wb_in_data_valid,   next_push_w[4])
    `MUX_2(u_smpp3_a, 15,  smpp3_address_w, 15'd0,  wb_in_data_address, next_push_w[4])
    `MUX_2(u_smpp3_b, 16,  smpp3_bit_vec_w, 16'd0,  wb_in_data_bit_vec, next_push_w[4])
    `MUX_2(u_smpp3_d, 128, smpp3_data_w,    128'd0, wb_in_data_data,    next_push_w[4])

    wire        din_3_valid_w;
    wire [14:0] din_3_address_w;
    wire [15:0] din_3_bit_vec_w;
    wire [127:0] din_3_data_w;
    `MUX_4(u_din3_v, 1,   din_3_valid_w,   q_3_valid_w,   1'b0,   smpo3_valid_w,   smpp3_valid_w,   sel_w)
    `MUX_4(u_din3_a, 15,  din_3_address_w, q_3_address_w, 15'd0,  smpo3_address_w, smpp3_address_w, sel_w)
    `MUX_4(u_din3_b, 16,  din_3_bit_vec_w, q_3_bit_vec_w, 16'd0,  smpo3_bit_vec_w, smpp3_bit_vec_w, sel_w)
    `MUX_4(u_din3_d, 128, din_3_data_w,    q_3_data_w,    128'd0, smpo3_data_w,    smpp3_data_w,    sel_w)

    `REG_RST_WE(u_q3_v, 1,   clk, rst, we_w, din_3_valid_w,   q_3_valid_w)
    `REG_RST_WE(u_q3_a, 15,  clk, rst, we_w, din_3_address_w, q_3_address_w)
    `REG_RST_WE(u_q3_b, 16,  clk, rst, we_w, din_3_bit_vec_w, q_3_bit_vec_w)
    `REG_RST_WE(u_q3_d, 128, clk, rst, we_w, din_3_data_w,    q_3_data_w)

    // ===================================================================
    // External-fanout replicas / buffers
    //
    //   q_1/2/3 .valid Q outputs see 4 internal mux inputs (smpp/smpo/din)
    //   PLUS dep_check (g_slot[N].u_mux_valid_0 + _mux_valid_1) = 6 loads,
    //   violating the fanout-4 limit on a reg64e$ Q. Replicate each 1-bit
    //   valid register: the _ext copy takes the same DIN/WE/CLK/RST and is
    //   bit-identical to the internal copy every cycle, but its Q drives
    //   only outputs_valid_N. The internal Q is left at fanout=4 (no buffer
    //   in the shift recurrence). Cost: 3 extra 1-bit FFs per ST_Q.
    //
    //   q_0 .address: 2 internal mux loads. Bits [14:4] also feed dep_check
    //     (2) + DCache_Arb (1) externally = 5 total. Buffer bits [14:4]
    //     through bufferH16$ -> Q sees 2 internal + 1 buffer = 3 loads.
    //   q_1/2/3 .address: 4 internal mux loads + dep_check (2) externally = 6
    //     total. Adding a buffer would push internal direct fanout to 5
    //     (4 mux + 1 buffer.in) which still violates. Instead, replicate the
    //     15-bit register: u_qN_a (internal) drives only the 4 internal mux
    //     inputs (fanout 4); u_qN_a_ext drives outputs_address_N directly
    //     (fanout = 2 dep_check loads per bit + the output port). Same
    //     DIN/WE/CLK/RST so they stay bit-identical. Cost: 3 x 15 = 45 extra
    //     FFs per ST_Q.
    // ===================================================================
    wire q_1_valid_ext_w, q_2_valid_ext_w, q_3_valid_ext_w;
    `REG_RST_WE(u_q1_v_ext, 1, clk, rst, we_w, din_1_valid_w, q_1_valid_ext_w)
    `REG_RST_WE(u_q2_v_ext, 1, clk, rst, we_w, din_2_valid_w, q_2_valid_ext_w)
    `REG_RST_WE(u_q3_v_ext, 1, clk, rst, we_w, din_3_valid_w, q_3_valid_ext_w)

    wire [14:0] q_1_address_ext_w, q_2_address_ext_w, q_3_address_ext_w;
    `REG_RST_WE(u_q1_a_ext, 15, clk, rst, we_w, din_1_address_w, q_1_address_ext_w)
    `REG_RST_WE(u_q2_a_ext, 15, clk, rst, we_w, din_2_address_w, q_2_address_ext_w)
    `REG_RST_WE(u_q3_a_ext, 15, clk, rst, we_w, din_3_address_w, q_3_address_ext_w)

    // q_0_address has only 2 internal mux loads (head); buffering [14:4] is
    // sufficient to keep the reg Q at fanout 3 (2 internal + 1 buffer).
    wire [14:0] q_0_address_buf_w;
    assign q_0_address_buf_w[3:0] = q_0_address_w[3:0];
    genvar gi_a;
    generate
        for (gi_a = 4; gi_a <= 14; gi_a = gi_a + 1) begin : g_q0addr_buf
            bufferH16$ u_q0_a_buf (.out(q_0_address_buf_w[gi_a]), .in(q_0_address_w[gi_a]));
        end
    endgenerate

    // ===================================================================
    // Combinational outputs
    //   q[0] is always the head, so head_address/bit_vec/data are
    //   direct register taps -- no mux needed (vs the old ring-buffer
    //   port that used a 4:1 head-select mux).
    // ===================================================================
    assign outputs_valid_0      = q_0_valid_w;          // fanout=4, OK
    assign outputs_valid_1      = q_1_valid_ext_w;      // replicated copy
    assign outputs_valid_2      = q_2_valid_ext_w;      // replicated copy
    assign outputs_valid_3      = q_3_valid_ext_w;      // replicated copy
    assign outputs_address_0    = q_0_address_buf_w;    // [14:4] via bufferH16$
    assign outputs_address_1    = q_1_address_ext_w;    // replicated copy
    assign outputs_address_2    = q_2_address_ext_w;    // replicated copy
    assign outputs_address_3    = q_3_address_ext_w;    // replicated copy
    assign outputs_head_address = q_0_address_buf_w;    // [14:4] via bufferH16$
    assign outputs_bit_vec      = q_0_bit_vec_w;
    assign outputs_data         = q_0_data_w;

endmodule


// ============================================================================
// COMMENTED OUT: Legacy SystemVerilog implementation (the new shift-register
// version). Restore by uncommenting this and commenting the structural
// module above; also flip its WB.sv instantiations back to the struct-based
// generate loop.
// ============================================================================
//
// import common_pkg::*;
// import WriteBack_pkg::*;
//
// module ST_Q(
//     input clk,
//     input rst,
//     input st_q_inputs_t wb_in,
//     output st_q_outputs_t outputs
// );
//
//     st_q_entry_t q[ST_Q_DEPTH + 1]; //extra entry should always be invalid
//     logic [ST_Q_DEPTH: 0] next_push; //one hot encoding I think it will be easier for structural
//
//
//
//     bool full, empty;
//     assign full = (next_push == 5'b10000);
//     assign empty = (next_push == 5'b00001);
//
//     bool valid_push, valid_pop;
//     assign valid_push = wb_in.push &  (~full | wb_in.pop);
//     assign valid_pop =  wb_in.pop & (~empty);
//
//     //q[0] is where things get popped off
//     always_ff @(posedge clk)begin
//         if(!rst) begin
//             next_push <= 1;
//             q <= '{default: '0};
//         end
//         else begin
//             if(valid_push)begin
//                 if(valid_pop)begin
//                     for(int i = 0; i < ST_Q_DEPTH; i++)begin
//                         q[i] <= next_push[i+1] ? wb_in.data : q[i+1];
//                     end
//                 end
//                 else begin
//                     next_push <= next_push <<1;
//                     for(int i = 0; i < ST_Q_DEPTH; i++)begin
//                         q[i] <= next_push[i] ? wb_in.data : q[i];
//                     end
//                 end
//             end
//             else if(valid_pop)begin
//                 next_push <= next_push >> 1;
//                 for(int i =0; i < ST_Q_DEPTH; i++)begin
//                     q[i] <= q[i+1];
//                 end
//             end
//         end
//     end
//
//     always_comb begin
//         outputs.full = full;
//         outputs.empty = empty;
//         outputs.head_address = q[0].address;
//         outputs.bit_vec = q[0].bit_vec;
//         //outputs.head_data = q[0].data;
//         outputs.push_fail = wb_in.push & (full & ~wb_in.pop);
//         outputs.data = q[0].data;
//
//         //this is for forwarding
//         for(int i = 0;  i < ST_Q_DEPTH; i++)begin
//             outputs.valid[i] = q[i].valid;
//             outputs.address[i] = q[i].address;
//             //outputs.data[i] = q[i].data;
//         end
//
//     end
//
//
//
// endmodule
