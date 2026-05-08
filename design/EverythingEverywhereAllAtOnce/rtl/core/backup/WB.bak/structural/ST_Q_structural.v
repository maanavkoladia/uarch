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
    wire [3:0] next_push_high_q_pre_buf; // fanout
    wire       next_push_low_w;
    wire [4:0] next_push_w;

    `NOR_4(u_np_low, 1, next_push_low_w,
           next_push_high_q[0], next_push_high_q[1],
           next_push_high_q[2], next_push_high_q[3])

    assign next_push_w = {next_push_high_q, next_push_low_w};

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
    `OR_2 (u_or_nf_pop,   1, or_notfull_pop_w, inv_full_w, wb_in_pop)
    `AND_2(u_valid_push,  1, valid_push_w, wb_in_push, or_notfull_pop_w)
    `AND_2(u_valid_pop,   1, valid_pop_w,  wb_in_pop,  inv_empty_w)

    wire full_and_notpop_w;
    `AND_2(u_full_notpop, 1, full_and_notpop_w, full_w, inv_pop_in_w)
    `AND_2(u_push_fail,   1, outputs_push_fail, wb_in_push, full_and_notpop_w)

    assign outputs_full  = full_w;
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

    `REG_RST_WE(u_next_push, 4, clk, rst, next_push_we_w, next_push_din_w, next_push_high_q_pre_buf)
    // fanout: bit 3 needs buffer, others passthrough
    assign next_push_high_q[0] = next_push_high_q_pre_buf[0];
    assign next_push_high_q[1] = next_push_high_q_pre_buf[1];
    assign next_push_high_q[2] = next_push_high_q_pre_buf[2];
    bufferH16$ u_attach_next_push_3 (.out(next_push_high_q[3]), .in(next_push_high_q_pre_buf[3]));

    // ===================================================================
    // Slot register signals (q[0..3])
    //   q[4] hardwired to literal 0 in the muxes (no register).
    // ===================================================================
    wire        q_0_valid_w, q_1_valid_w, q_2_valid_w, q_3_valid_w;
    wire [14:0] q_0_address_w, q_1_address_w, q_2_address_w, q_3_address_w;
    wire [15:0] q_0_bit_vec_w, q_1_bit_vec_w, q_2_bit_vec_w, q_3_bit_vec_w;
    wire [127:0] q_0_data_w, q_1_data_w, q_2_data_w, q_3_data_w;

    // fanout: pre-buffer staging wires for register outputs that violate
    wire [14:0] q_0_address_w_pre_buf;
    wire [14:0] q_1_address_w_pre_buf;
    wire [14:0] q_2_address_w_pre_buf;
    wire [14:0] q_3_address_w_pre_buf;
    wire        q_1_valid_w_pre_buf;
    wire        q_2_valid_w_pre_buf;
    wire        q_3_valid_w_pre_buf;

    // Common slot WE and 4:1 MUX sel
    wire we_w;
    wire [1:0] sel_w;
    `OR_2(u_slot_we, 1, we_w, valid_push_w, valid_pop_w)
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
    `REG_RST_WE(u_q0_a, 15,  clk, rst, we_w, din_0_address_w, q_0_address_w_pre_buf)
    `REG_RST_WE(u_q0_b, 16,  clk, rst, we_w, din_0_bit_vec_w, q_0_bit_vec_w)
    `REG_RST_WE(u_q0_d, 128, clk, rst, we_w, din_0_data_w,    q_0_data_w)
    // fanout: q_0_address bit 14 needs buffer
    assign q_0_address_w[13:0] = q_0_address_w_pre_buf[13:0];
    bufferH16$ u_attach_q0_a_14 (.out(q_0_address_w[14]), .in(q_0_address_w_pre_buf[14]));

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

    `REG_RST_WE(u_q1_v, 1,   clk, rst, we_w, din_1_valid_w,   q_1_valid_w_pre_buf)
    `REG_RST_WE(u_q1_a, 15,  clk, rst, we_w, din_1_address_w, q_1_address_w_pre_buf)
    `REG_RST_WE(u_q1_b, 16,  clk, rst, we_w, din_1_bit_vec_w, q_1_bit_vec_w)
    `REG_RST_WE(u_q1_d, 128, clk, rst, we_w, din_1_data_w,    q_1_data_w)
    // fanout: q_1_valid bit 0 and q_1_address bit 14 need buffers
    bufferH16$ u_attach_q1_v_0 (.out(q_1_valid_w), .in(q_1_valid_w_pre_buf));
    assign q_1_address_w[13:0] = q_1_address_w_pre_buf[13:0];
    bufferH16$ u_attach_q1_a_14 (.out(q_1_address_w[14]), .in(q_1_address_w_pre_buf[14]));

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

    `REG_RST_WE(u_q2_v, 1,   clk, rst, we_w, din_2_valid_w,   q_2_valid_w_pre_buf)
    `REG_RST_WE(u_q2_a, 15,  clk, rst, we_w, din_2_address_w, q_2_address_w_pre_buf)
    `REG_RST_WE(u_q2_b, 16,  clk, rst, we_w, din_2_bit_vec_w, q_2_bit_vec_w)
    `REG_RST_WE(u_q2_d, 128, clk, rst, we_w, din_2_data_w,    q_2_data_w)
    // fanout: q_2_valid bit 0 and q_2_address bit 14 need buffers
    bufferH16$ u_attach_q2_v_0 (.out(q_2_valid_w), .in(q_2_valid_w_pre_buf));
    assign q_2_address_w[13:0] = q_2_address_w_pre_buf[13:0];
    bufferH16$ u_attach_q2_a_14 (.out(q_2_address_w[14]), .in(q_2_address_w_pre_buf[14]));

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

    `REG_RST_WE(u_q3_v, 1,   clk, rst, we_w, din_3_valid_w,   q_3_valid_w_pre_buf)
    `REG_RST_WE(u_q3_a, 15,  clk, rst, we_w, din_3_address_w, q_3_address_w_pre_buf)
    `REG_RST_WE(u_q3_b, 16,  clk, rst, we_w, din_3_bit_vec_w, q_3_bit_vec_w)
    `REG_RST_WE(u_q3_d, 128, clk, rst, we_w, din_3_data_w,    q_3_data_w)
    // fanout: q_3_valid bit 0 and q_3_address bit 14 need buffers
    bufferH16$ u_attach_q3_v_0 (.out(q_3_valid_w), .in(q_3_valid_w_pre_buf));
    assign q_3_address_w[13:0] = q_3_address_w_pre_buf[13:0];
    bufferH16$ u_attach_q3_a_14 (.out(q_3_address_w[14]), .in(q_3_address_w_pre_buf[14]));

    // ===================================================================
    // Combinational outputs
    //   q[0] is always the head, so head_address/bit_vec/data are
    //   direct register taps -- no mux needed (vs the old ring-buffer
    //   port that used a 4:1 head-select mux).
    // ===================================================================
    assign outputs_valid_0      = q_0_valid_w;
    assign outputs_valid_1      = q_1_valid_w;
    assign outputs_valid_2      = q_2_valid_w;
    assign outputs_valid_3      = q_3_valid_w;
    assign outputs_address_0    = q_0_address_w;
    assign outputs_address_1    = q_1_address_w;
    assign outputs_address_2    = q_2_address_w;
    assign outputs_address_3    = q_3_address_w;
    assign outputs_head_address = q_0_address_w;
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
