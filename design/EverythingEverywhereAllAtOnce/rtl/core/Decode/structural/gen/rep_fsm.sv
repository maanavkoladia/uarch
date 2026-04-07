// ======================================================================
// FSM : rep_fsm
// Tool: fsm2rtl.py  (auto-generated -- do not hand-edit)
// NOTE: ERROR state was synthesised automatically.
//       Any undefined transition lands here (all outputs = 0).
// ======================================================================
//
// State Enumeration  (4 bits, 15 states)
// --------------------------------------------------
//   IDLE                          0000  (decimal 0)  // IDLE (reset state)
//   CMP                           0001  (decimal 1)
//   CMP0                          0010  (decimal 2)
//   CMP1                          0011  (decimal 3)
//   CMP2                          0100  (decimal 4)
//   CMP3                          0101  (decimal 5)
//   CMP4                          0110  (decimal 6)
//   FUCK_ME                       0111  (decimal 7)
//   MOV0                          1000  (decimal 8)
//   MOV1                          1001  (decimal 9)
//   MOV2                          1010  (decimal 10)
//   MOV3                          1011  (decimal 11)
//   MOVS                          1100  (decimal 12)
//   WAIT                          1101  (decimal 13)
//   ERROR                         1110  (decimal 14)  // ERROR (trap state), synthesised
//
// Truth Table (pre-expansion, original CSV rows)
// -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//         S_0         S_1         S_2         S_3  cont_mov_i  cont_cmp_i  rep_prefix_i    cs_mov_i    cs_cmp_i     stall_i  |        NS_0        NS_1        NS_2        NS_3   set_rep_o  clear_rep_o  select_line2_o  select_line1_o  select_line0_o   transition
// -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//           0           0           0           0           x           x           0           x           x           0  |           0           0           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           0           0           x           x           1           x           x           0  |           1           0           1           1           1           0           0           0           0   IDLE -> WAIT
//           1           0           1           1           x           x           x           0           0           0  |           1           1           1           0           0           0           0           0           0   WAIT -> FUCK_ME
//           1           0           1           1           x           x           x           0           1           0  |           1           0           0           0           0           0           0           0           0   WAIT -> CMP
//           1           0           1           1           x           x           x           1           0           0  |           0           0           1           1           0           0           0           0           0   WAIT -> MOVS
//           1           0           1           1           x           x           x           1           1           0  |           1           1           1           0           0           0           0           0           0   WAIT -> FUCK_ME
//           0           0           1           1           1           x           x           x           x           0  |           0           0           0           1           0           0           0           0           1   MOVS -> MOV0
//           0           0           1           1           0           x           x           x           x           0  |           0           0           0           0           0           1           0           0           0   MOVS -> IDLE
//           1           0           0           0           x           1           x           x           x           0  |           0           1           0           0           0           0           1           0           1   CMP -> CMP0
//           1           0           0           0           x           0           x           x           x           0  |           0           0           0           0           0           1           0           0           0   CMP -> IDLE
//           0           0           0           1           x           x           x           x           x           0  |           1           0           0           1           0           0           0           1           0   MOV0 -> MOV1
//           1           0           0           1           x           x           x           x           x           0  |           0           1           0           1           0           0           0           1           1   MOV1 -> MOV2
//           0           1           0           1           x           x           x           x           x           0  |           1           1           0           1           0           0           1           0           0   MOV2 -> MOV3
//           1           1           0           1           x           x           x           x           x           0  |           0           0           1           1           0           0           0           0           0   MOV3 -> MOVS
//           0           1           0           0           x           x           x           x           x           0  |           1           1           0           0           0           0           1           1           0   CMP0 -> CMP1
//           1           1           0           0           x           x           x           x           x           0  |           0           0           1           0           0           0           1           1           1   CMP1 -> CMP2
//           0           0           1           0           x           x           x           x           x           0  |           1           0           1           0           0           0           0           1           1   CMP2 -> CMP3
//           1           0           1           0           x           x           x           x           x           0  |           0           1           1           0           0           0           1           0           0   CMP3 -> CMP4
//           0           1           1           0           x           x           x           x           x           0  |           1           0           0           0           0           0           0           0           0   CMP4 -> CMP
//           1           1           1           0           x           x           x           x           x           x  |           1           1           1           0           0           0           0           0           0   FUCK_ME -> FUCK_ME
//           0           0           0           0           x           x           x           x           x           1  |           0           0           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           1           1           x           x           x           x           x           1  |           0           0           1           1           0           0           0           0           0   MOVS -> MOVS
//           1           0           0           0           x           x           x           x           x           1  |           1           0           0           0           0           0           0           0           0   CMP -> CMP
//           0           0           0           1           x           x           x           x           x           1  |           0           0           0           1           0           0           0           0           0   MOV0 -> MOV0
//           1           0           0           1           x           x           x           x           x           1  |           1           0           0           1           0           0           0           0           0   MOV1 -> MOV1
//           0           1           0           1           x           x           x           x           x           1  |           0           1           0           1           0           0           0           0           0   MOV2 -> MOV2
//           1           1           0           1           x           x           x           x           x           1  |           1           1           0           1           0           0           0           0           0   MOV3 -> MOV3
//           0           1           0           0           x           x           x           x           x           1  |           0           1           0           0           0           0           0           0           0   CMP0 -> CMP0
//           1           1           0           0           x           x           x           x           x           1  |           1           1           0           0           0           0           0           0           0   CMP1 -> CMP1
//           0           0           1           0           x           x           x           x           x           1  |           0           0           1           0           0           0           0           0           0   CMP2 -> CMP2
//           1           0           1           0           x           x           x           x           x           1  |           1           0           1           0           0           0           0           0           0   CMP3 -> CMP3
//           0           1           1           0           x           x           x           x           x           1  |           0           1           1           0           0           0           0           0           0   CMP4 -> CMP4
//           1           0           1           1           x           x           x           x           x           1  |           1           0           1           1           0           0           0           0           0   WAIT -> WAIT
// -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//

module rep_fsm (
    input  wire clk,
    input  wire rst,
    input  wire cont_mov_i,
    input  wire cont_cmp_i,
    input  wire rep_prefix_i,
    input  wire cs_mov_i,
    input  wire cs_cmp_i,
    input  wire stall_i,
    output wire S_0,  // current-state bit 0 (LSB)
    output wire S_1,  // current-state bit 1 (1)
    output wire S_2,  // current-state bit 2 (2)
    output wire S_3,  // current-state bit 3 (MSB)
    output wire set_rep_o,
    output wire clear_rep_o,
    output wire select_line2_o,
    output wire select_line1_o,
    output wire select_line0_o
);

// Next-state wires  (NS_0=LSB ... NS_{N-1}=MSB)
wire NS_0;
wire NS_1;
wire NS_2;
wire NS_3;

// State encoding  (IDLE = 0, ERROR = highest, guaranteed by tool)
//   IDLE                         = 0000  (decimal 0)  // IDLE (reset state)
//   CMP                          = 0001  (decimal 1)
//   CMP0                         = 0010  (decimal 2)
//   CMP1                         = 0011  (decimal 3)
//   CMP2                         = 0100  (decimal 4)
//   CMP3                         = 0101  (decimal 5)
//   CMP4                         = 0110  (decimal 6)
//   FUCK_ME                      = 0111  (decimal 7)
//   MOV0                         = 1000  (decimal 8)
//   MOV1                         = 1001  (decimal 9)
//   MOV2                         = 1010  (decimal 10)
//   MOV3                         = 1011  (decimal 11)
//   MOVS                         = 1100  (decimal 12)
//   WAIT                         = 1101  (decimal 13)
//   ERROR                        = 1110  (decimal 14)  // ERROR (trap state), synthesised

// State flip-flops  (reg1b, active-low async reset)
// Reset drives all state bits to 0, which is IDLE by construction.
reg1b ff_0 (
    .clk(clk),
    .rst(rst),
    .d(NS_0),
    .q(S_0)
);
reg1b ff_1 (
    .clk(clk),
    .rst(rst),
    .d(NS_1),
    .q(S_1)
);
reg1b ff_2 (
    .clk(clk),
    .rst(rst),
    .d(NS_2),
    .q(S_2)
);
reg1b ff_3 (
    .clk(clk),
    .rst(rst),
    .d(NS_3),
    .q(S_3)
);

// Inverters
wire S_0_inv;
wire S_1_inv;
wire S_2_inv;
wire S_3_inv;
wire cont_cmp_i_inv;
wire cont_mov_i_inv;
wire cs_cmp_i_inv;
wire cs_mov_i_inv;
wire stall_i_inv;

inv1$ inv_S_0 (S_0_inv, S_0);
inv1$ inv_S_1 (S_1_inv, S_1);
inv1$ inv_S_2 (S_2_inv, S_2);
inv1$ inv_S_3 (S_3_inv, S_3);
inv1$ inv_cont_cmp_i (cont_cmp_i_inv, cont_cmp_i);
inv1$ inv_cont_mov_i (cont_mov_i_inv, cont_mov_i);
inv1$ inv_cs_cmp_i (cs_cmp_i_inv, cs_cmp_i);
inv1$ inv_cs_mov_i (cs_mov_i_inv, cs_mov_i);
inv1$ inv_stall_i (stall_i_inv, stall_i);

// Next-state and output SOP logic

// NS_0 = (S_0 & !S_1 & stall_i) | (S_0 & !S_3 & stall_i) | (!S_0 & !S_2 & S_3 & !stall_i) | (S_1 & S_2 & !S_3 & !stall_i) | (!S_0 & !S_3 & rep_prefix_i & !stall_i) | (S_0 & !S_2 & stall_i) | (!S_0 & S_1 & !S_3 & !stall_i) | (!S_0 & S_2 & !S_3 & !stall_i) | (S_0 & !S_1 & S_2 & S_3 & cs_cmp_i) | (S_0 & !S_1 & S_2 & S_3 & !cs_mov_i)
wire NS_0_t0;
wire NS_0_t1;
wire NS_0_t2;
wire NS_0_t3;
wire NS_0_t4;
wire NS_0_t5;
wire NS_0_t6;
wire NS_0_t7;
wire NS_0_t8;
wire NS_0_t9;

and3$ NS_0_and0 (NS_0_t0, S_0, S_1_inv, stall_i);
and3$ NS_0_and1 (NS_0_t1, S_0, S_3_inv, stall_i);
and4$ NS_0_and2 (NS_0_t2, S_0_inv, S_2_inv, S_3, stall_i_inv);
and4$ NS_0_and3 (NS_0_t3, S_1, S_2, S_3_inv, stall_i_inv);
and4$ NS_0_and4 (NS_0_t4, S_0_inv, S_3_inv, rep_prefix_i, stall_i_inv);
and3$ NS_0_and5 (NS_0_t5, S_0, S_2_inv, stall_i);
and4$ NS_0_and6 (NS_0_t6, S_0_inv, S_1, S_3_inv, stall_i_inv);
and4$ NS_0_and7 (NS_0_t7, S_0_inv, S_2, S_3_inv, stall_i_inv);
and5$ NS_0_and8 (NS_0_t8, S_0, S_1_inv, S_2, S_3, cs_cmp_i);
and5$ NS_0_and9 (NS_0_t9, S_0, S_1_inv, S_2, S_3, cs_mov_i_inv);
or10$  NS_0_or  (NS_0, NS_0_t0, NS_0_t1, NS_0_t2, NS_0_t3, NS_0_t4, NS_0_t5, NS_0_t6, NS_0_t7, NS_0_t8, NS_0_t9);

// NS_1 = (!S_0 & S_1 & !S_2) | (S_1 & !S_3 & stall_i) | (!S_0 & S_1 & S_3) | (S_0 & S_2 & !S_3 & !stall_i) | (S_1 & !S_2 & stall_i) | (S_0 & !S_1 & !S_2 & S_3 & !stall_i) | (S_0 & !S_1 & !S_2 & cont_cmp_i & !stall_i) | (S_0 & !S_1 & S_3 & !cs_mov_i & !cs_cmp_i & !stall_i) | (S_0 & !S_1 & S_3 & cs_mov_i & cs_cmp_i & !stall_i)
wire NS_1_t0;
wire NS_1_t1;
wire NS_1_t2;
wire NS_1_t3;
wire NS_1_t4;
wire NS_1_t5;
wire NS_1_t6;
wire NS_1_t7;
wire NS_1_t8;

and3$ NS_1_and0 (NS_1_t0, S_0_inv, S_1, S_2_inv);
and3$ NS_1_and1 (NS_1_t1, S_1, S_3_inv, stall_i);
and3$ NS_1_and2 (NS_1_t2, S_0_inv, S_1, S_3);
and4$ NS_1_and3 (NS_1_t3, S_0, S_2, S_3_inv, stall_i_inv);
and3$ NS_1_and4 (NS_1_t4, S_1, S_2_inv, stall_i);
and5$ NS_1_and5 (NS_1_t5, S_0, S_1_inv, S_2_inv, S_3, stall_i_inv);
and5$ NS_1_and6 (NS_1_t6, S_0, S_1_inv, S_2_inv, cont_cmp_i, stall_i_inv);
and6$ NS_1_and7 (NS_1_t7, S_0, S_1_inv, S_3, cs_mov_i_inv, cs_cmp_i_inv, stall_i_inv);
and6$ NS_1_and8 (NS_1_t8, S_0, S_1_inv, S_3, cs_mov_i, cs_cmp_i, stall_i_inv);
or9$  NS_1_or  (NS_1, NS_1_t0, NS_1_t1, NS_1_t2, NS_1_t3, NS_1_t4, NS_1_t5, NS_1_t6, NS_1_t7, NS_1_t8);

// NS_2 = (!S_1 & S_2 & stall_i) | (S_0 & S_2 & !S_3) | (!S_0 & S_2 & stall_i) | (S_0 & S_1 & !S_2 & !stall_i) | (!S_1 & S_2 & !S_3) | (!S_0 & S_1 & S_2 & S_3) | (S_0 & !S_1 & S_2 & !cs_cmp_i) | (!S_0 & !S_1 & !S_3 & rep_prefix_i & !stall_i) | (S_0 & !S_1 & S_2 & cs_mov_i)
wire NS_2_t0;
wire NS_2_t1;
wire NS_2_t2;
wire NS_2_t3;
wire NS_2_t4;
wire NS_2_t5;
wire NS_2_t6;
wire NS_2_t7;
wire NS_2_t8;

and3$ NS_2_and0 (NS_2_t0, S_1_inv, S_2, stall_i);
and3$ NS_2_and1 (NS_2_t1, S_0, S_2, S_3_inv);
and3$ NS_2_and2 (NS_2_t2, S_0_inv, S_2, stall_i);
and4$ NS_2_and3 (NS_2_t3, S_0, S_1, S_2_inv, stall_i_inv);
and3$ NS_2_and4 (NS_2_t4, S_1_inv, S_2, S_3_inv);
and4$ NS_2_and5 (NS_2_t5, S_0_inv, S_1, S_2, S_3);
and4$ NS_2_and6 (NS_2_t6, S_0, S_1_inv, S_2, cs_cmp_i_inv);
and5$ NS_2_and7 (NS_2_t7, S_0_inv, S_1_inv, S_3_inv, rep_prefix_i, stall_i_inv);
and4$ NS_2_and8 (NS_2_t8, S_0, S_1_inv, S_2, cs_mov_i);
or9$  NS_2_or  (NS_2, NS_2_t0, NS_2_t1, NS_2_t2, NS_2_t3, NS_2_t4, NS_2_t5, NS_2_t6, NS_2_t7, NS_2_t8);

// NS_3 = (!S_2 & S_3) | (!S_1 & S_3 & stall_i) | (!S_0 & S_1 & S_3) | (!S_0 & S_3 & cont_mov_i) | (!S_0 & !S_1 & !S_2 & rep_prefix_i & !stall_i) | (S_0 & !S_1 & S_3 & cs_mov_i & !cs_cmp_i)
wire NS_3_t0;
wire NS_3_t1;
wire NS_3_t2;
wire NS_3_t3;
wire NS_3_t4;
wire NS_3_t5;

and2$ NS_3_and0 (NS_3_t0, S_2_inv, S_3);
and3$ NS_3_and1 (NS_3_t1, S_1_inv, S_3, stall_i);
and3$ NS_3_and2 (NS_3_t2, S_0_inv, S_1, S_3);
and3$ NS_3_and3 (NS_3_t3, S_0_inv, S_3, cont_mov_i);
and5$ NS_3_and4 (NS_3_t4, S_0_inv, S_1_inv, S_2_inv, rep_prefix_i, stall_i_inv);
and5$ NS_3_and5 (NS_3_t5, S_0, S_1_inv, S_3, cs_mov_i, cs_cmp_i_inv);
or6$  NS_3_or  (NS_3, NS_3_t0, NS_3_t1, NS_3_t2, NS_3_t3, NS_3_t4, NS_3_t5);

// set_rep_o = (!S_0 & !S_1 & !S_2 & !S_3 & rep_prefix_i & !stall_i)
and6$ set_rep_o_and (set_rep_o, S_0_inv, S_1_inv, S_2_inv, S_3_inv, rep_prefix_i, stall_i_inv);

// clear_rep_o = (!S_0 & !S_1 & S_2 & S_3 & !cont_mov_i & !stall_i) | (S_0 & !S_1 & !S_2 & !S_3 & !cont_cmp_i & !stall_i)
wire clear_rep_o_t0;
wire clear_rep_o_t1;

and6$ clear_rep_o_and0 (clear_rep_o_t0, S_0_inv, S_1_inv, S_2, S_3, cont_mov_i_inv, stall_i_inv);
and6$ clear_rep_o_and1 (clear_rep_o_t1, S_0, S_1_inv, S_2_inv, S_3_inv, cont_cmp_i_inv, stall_i_inv);
or2$  clear_rep_o_or  (clear_rep_o, clear_rep_o_t0, clear_rep_o_t1);

// select_line2_o = (S_1 & !S_2 & !S_3 & !stall_i) | (!S_0 & S_1 & !S_2 & !stall_i) | (S_0 & !S_1 & S_2 & !S_3 & !stall_i) | (S_0 & !S_1 & !S_3 & cont_cmp_i & !stall_i)
wire select_line2_o_t0;
wire select_line2_o_t1;
wire select_line2_o_t2;
wire select_line2_o_t3;

and4$ select_line2_o_and0 (select_line2_o_t0, S_1, S_2_inv, S_3_inv, stall_i_inv);
and4$ select_line2_o_and1 (select_line2_o_t1, S_0_inv, S_1, S_2_inv, stall_i_inv);
and5$ select_line2_o_and2 (select_line2_o_t2, S_0, S_1_inv, S_2, S_3_inv, stall_i_inv);
and5$ select_line2_o_and3 (select_line2_o_t3, S_0, S_1_inv, S_3_inv, cont_cmp_i, stall_i_inv);
or4$  select_line2_o_or  (select_line2_o, select_line2_o_t0, select_line2_o_t1, select_line2_o_t2, select_line2_o_t3);

// select_line1_o = (S_1 & !S_2 & !S_3 & !stall_i) | (!S_1 & !S_2 & S_3 & !stall_i) | (!S_0 & !S_1 & S_2 & !S_3 & !stall_i)
wire select_line1_o_t0;
wire select_line1_o_t1;
wire select_line1_o_t2;

and4$ select_line1_o_and0 (select_line1_o_t0, S_1, S_2_inv, S_3_inv, stall_i_inv);
and4$ select_line1_o_and1 (select_line1_o_t1, S_1_inv, S_2_inv, S_3, stall_i_inv);
and5$ select_line1_o_and2 (select_line1_o_t2, S_0_inv, S_1_inv, S_2, S_3_inv, stall_i_inv);
or3$  select_line1_o_or  (select_line1_o, select_line1_o_t0, select_line1_o_t1, select_line1_o_t2);

// select_line0_o = (!S_0 & !S_1 & S_2 & cont_mov_i & !stall_i) | (S_0 & !S_1 & !S_2 & S_3 & !stall_i) | (S_0 & !S_2 & !S_3 & cont_cmp_i & !stall_i) | (S_0 & S_1 & !S_2 & !S_3 & !stall_i) | (!S_0 & !S_1 & S_2 & !S_3 & !stall_i)
wire select_line0_o_t0;
wire select_line0_o_t1;
wire select_line0_o_t2;
wire select_line0_o_t3;
wire select_line0_o_t4;

and5$ select_line0_o_and0 (select_line0_o_t0, S_0_inv, S_1_inv, S_2, cont_mov_i, stall_i_inv);
and5$ select_line0_o_and1 (select_line0_o_t1, S_0, S_1_inv, S_2_inv, S_3, stall_i_inv);
and5$ select_line0_o_and2 (select_line0_o_t2, S_0, S_2_inv, S_3_inv, cont_cmp_i, stall_i_inv);
and5$ select_line0_o_and3 (select_line0_o_t3, S_0, S_1, S_2_inv, S_3_inv, stall_i_inv);
and5$ select_line0_o_and4 (select_line0_o_t4, S_0_inv, S_1_inv, S_2, S_3_inv, stall_i_inv);
or5$  select_line0_o_or  (select_line0_o, select_line0_o_t0, select_line0_o_t1, select_line0_o_t2, select_line0_o_t3, select_line0_o_t4);

endmodule
