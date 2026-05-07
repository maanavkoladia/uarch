// ======================================================================
// FSM : rep_movs_fsm
// Tool: fsm2rtl.py  (auto-generated -- do not hand-edit)
// Std : Verilog-2005 (IEEE 1364-2005)
// NOTE: ERROR state was synthesised automatically.
//       Any undefined transition lands here (all outputs = 0).
// ======================================================================
//
// State Enumeration  (3 bits, 7 states)
// --------------------------------------------------
//   IDLE                          000  (decimal 0)  // IDLE (reset state)
//   DEC_ECX_MOV                   001  (decimal 1)
//   FILLER                        010  (decimal 2)
//   FUCK_ME                       011  (decimal 3)
//   MOVS                          100  (decimal 4)
//   MOVS_OP                       101  (decimal 5)
//   ERROR                         110  (decimal 6)  // ERROR (trap state), synthesised
//
// Truth Table (pre-expansion, original CSV rows)
// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//         S_0         S_1         S_2     start_i  cont_mov_i  wait_mov_i  exit_mov_i     stall_i  |        NS_0        NS_1        NS_2  clear_rep_o  select_line2_o  select_line1_o  select_line0_o   transition
// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//           0           0           0           0           x           x           x           0  |           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           0           1           x           x           x           0  |           0           0           1           0           0           0           0   IDLE -> MOVS
//           0           0           1           x           1           x           x           0  |           1           0           1           0           0           0           0   MOVS -> MOVS_OP
//           0           0           1           x           0           1           x           0  |           0           0           1           0           0           0           0   MOVS -> MOVS
//           0           0           1           x           0           0           1           0  |           0           0           0           1           0           0           0   MOVS -> IDLE
//           0           0           1           x           0           0           0           0  |           1           1           0           0           0           0           0   MOVS -> FUCK_ME
//           1           0           1           x           x           x           x           0  |           1           0           0           0           0           0           1   MOVS_OP -> DEC_ECX_MOV
//           1           0           0           x           x           x           x           0  |           0           1           0           0           0           1           0   DEC_ECX_MOV -> FILLER
//           0           1           0           x           x           x           x           0  |           0           0           1           0           0           0           0   FILLER -> MOVS
//           1           1           0           x           x           x           x           x  |           1           1           0           0           0           0           0   FUCK_ME -> FUCK_ME
//           0           0           0           x           x           x           x           1  |           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           1           x           x           x           x           1  |           0           0           1           0           0           0           0   MOVS -> MOVS
//           1           0           1           x           x           x           x           1  |           1           0           1           0           0           0           0   MOVS_OP -> MOVS_OP
//           1           0           0           x           x           x           x           1  |           1           0           0           0           0           0           0   DEC_ECX_MOV -> DEC_ECX_MOV
//           0           1           0           x           x           x           x           1  |           0           1           0           0           0           0           0   FILLER -> FILLER
// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//

module rep_movs_fsm (
    input  wire clk,
    input  wire rst,
    input  wire start_i,
    input  wire cont_mov_i,
    input  wire wait_mov_i,
    input  wire exit_mov_i,
    input  wire stall_i,
    output wire S_0,  // current-state bit 0 (LSB)
    output wire S_1,  // current-state bit 1 (1)
    output wire S_2,  // current-state bit 2 (MSB)
    output wire clear_rep_o,
    output wire select_line2_o,
    output wire select_line1_o,
    output wire select_line0_o
);

// ----------------------------------------------------------------
// Next-state wires  (NS_0 = LSB ... NS_{N-1} = MSB)
// ----------------------------------------------------------------
wire NS_0;
wire NS_1;
wire NS_2;

// State encoding  (IDLE = 0, ERROR = highest, guaranteed by tool)
//   IDLE                         = 000  (decimal 0)  // IDLE (reset state)
//   DEC_ECX_MOV                  = 001  (decimal 1)
//   FILLER                       = 010  (decimal 2)
//   FUCK_ME                      = 011  (decimal 3)
//   MOVS                         = 100  (decimal 4)
//   MOVS_OP                      = 101  (decimal 5)
//   ERROR                        = 110  (decimal 6)  // ERROR (trap state), synthesised

// ----------------------------------------------------------------
// State flip-flops
// `REG_RST samples D on every rising clk edge.
// Active-high rst drives all state bits to 0 (= IDLE encoding).
// ----------------------------------------------------------------
wire S_0_pre, S_1_pre, S_2_pre;
`REG_RST(ff_0, 1, clk, rst, NS_0, S_0_pre)
`REG_RST(ff_1, 1, clk, rst, NS_1, S_1_pre)
`REG_RST(ff_2, 1, clk, rst, NS_2, S_2_pre)

bufferH16$ S_0_buf (.out(S_0), .in(S_0_pre));
bufferH16$ S_1_buf (.out(S_1), .in(S_1_pre));
bufferH16$ S_2_buf (.out(S_2), .in(S_2_pre));

// ----------------------------------------------------------------
// Inverters for negated literals
// ----------------------------------------------------------------
wire S_0_inv;
wire S_1_inv;
wire S_2_inv;
wire cont_mov_i_inv;
wire exit_mov_i_inv;
wire stall_i_inv;
wire wait_mov_i_inv;

`INV_N(inv_S_0, 1, S_0, S_0_inv)
`INV_N(inv_S_1, 1, S_1, S_1_inv)
`INV_N(inv_S_2, 1, S_2, S_2_inv)
`INV_N(inv_cont_mov_i, 1, cont_mov_i, cont_mov_i_inv)
`INV_N(inv_exit_mov_i, 1, exit_mov_i, exit_mov_i_inv)
`INV_N(inv_stall_i, 1, stall_i, stall_i_inv)
`INV_N(inv_wait_mov_i, 1, wait_mov_i, wait_mov_i_inv)

// ----------------------------------------------------------------
// Next-state and output SOP logic
// ----------------------------------------------------------------

// NS_0 = (S_0 & !S_1 & stall_i) | (S_0 & S_1 & !S_2) | (S_0 & !S_1 & S_2) | (!S_1 & S_2 & cont_mov_i & !stall_i) | (!S_1 & S_2 & !wait_mov_i & !exit_mov_i & !stall_i)
// NAND-NAND form: sum = NAND( NAND(p0..p2), NAND(p3,p4) ) collapsed to OR_2 of two 3/2-input NANDs
// Wide 5-input product (t4) uses NOR_3 of {wait,exit,stall} to absorb three negated literals.
wire NS_0_nt0, NS_0_nt1, NS_0_nt2, NS_0_nt3, NS_0_nt4;
`NAND_3(NS_0_nand0, 1, NS_0_nt0, S_0, S_1_inv, stall_i)
`NAND_3(NS_0_nand1, 1, NS_0_nt1, S_0, S_1, S_2_inv)
`NAND_3(NS_0_nand2, 1, NS_0_nt2, S_0, S_1_inv, S_2)
`NAND_4(NS_0_nand3, 1, NS_0_nt3, S_1_inv, S_2, cont_mov_i, stall_i_inv)
wire NS_0_t4_nor;
`NOR_3(NS_0_t4_nor3, 1, NS_0_t4_nor, wait_mov_i, exit_mov_i, stall_i)
`NAND_3(NS_0_nand4, 1, NS_0_nt4, NS_0_t4_nor, S_1_inv, S_2)

wire NS_0_g0, NS_0_g1;
`NAND_3(NS_0_g0_nand, 1, NS_0_g0, NS_0_nt0, NS_0_nt1, NS_0_nt2)
`NAND_2(NS_0_g1_nand, 1, NS_0_g1, NS_0_nt3, NS_0_nt4)
`OR_2(NS_0_or, 1, NS_0, NS_0_g0, NS_0_g1)

// NS_1 = (S_0 & !S_2 & !stall_i) | (!S_0 & S_1 & stall_i) | (!S_0 & S_1 & S_2) | (S_1 & !S_2 & stall_i) | (!S_0 & S_2 & !cont_mov_i & !wait_mov_i & !exit_mov_i & !stall_i)
// Wide 6-input product (t4) uses NOR_4 of {cont,wait,exit,stall} to absorb four negated literals.
wire NS_1_nt0, NS_1_nt1, NS_1_nt2, NS_1_nt3, NS_1_nt4;
`NAND_3(NS_1_nand0, 1, NS_1_nt0, S_0, S_2_inv, stall_i_inv)
`NAND_3(NS_1_nand1, 1, NS_1_nt1, S_0_inv, S_1, stall_i)
`NAND_3(NS_1_nand2, 1, NS_1_nt2, S_0_inv, S_1, S_2)
`NAND_3(NS_1_nand3, 1, NS_1_nt3, S_1, S_2_inv, stall_i)
wire NS_1_t4_nor;
`NOR_4(NS_1_t4_nor4, 1, NS_1_t4_nor, cont_mov_i, wait_mov_i, exit_mov_i, stall_i)
`NAND_3(NS_1_nand4, 1, NS_1_nt4, NS_1_t4_nor, S_0_inv, S_2)

wire NS_1_g0, NS_1_g1;
`NAND_3(NS_1_g0_nand, 1, NS_1_g0, NS_1_nt0, NS_1_nt1, NS_1_nt2)
`NAND_2(NS_1_g1_nand, 1, NS_1_g1, NS_1_nt3, NS_1_nt4)
`OR_2(NS_1_or, 1, NS_1, NS_1_g0, NS_1_g1)

// NS_2 = (!S_0 & S_2 & stall_i) | (!S_0 & S_1 & !stall_i) | (!S_1 & S_2 & stall_i) | (!S_0 & S_2 & wait_mov_i) | (!S_0 & !S_2 & start_i & !stall_i) | (!S_0 & S_2 & cont_mov_i)
// 6 product terms split as 3+3 into two NAND_3 collectors, OR_2 at top.
wire NS_2_nt0, NS_2_nt1, NS_2_nt2, NS_2_nt3, NS_2_nt4, NS_2_nt5;
`NAND_3(NS_2_nand0, 1, NS_2_nt0, S_0_inv, S_2, stall_i)
`NAND_3(NS_2_nand1, 1, NS_2_nt1, S_0_inv, S_1, stall_i_inv)
`NAND_3(NS_2_nand2, 1, NS_2_nt2, S_1_inv, S_2, stall_i)
`NAND_3(NS_2_nand3, 1, NS_2_nt3, S_0_inv, S_2, wait_mov_i)
`NAND_4(NS_2_nand4, 1, NS_2_nt4, S_0_inv, S_2_inv, start_i, stall_i_inv)
`NAND_3(NS_2_nand5, 1, NS_2_nt5, S_0_inv, S_2, cont_mov_i)

wire NS_2_g0, NS_2_g1;
`NAND_3(NS_2_g0_nand, 1, NS_2_g0, NS_2_nt0, NS_2_nt1, NS_2_nt2)
`NAND_3(NS_2_g1_nand, 1, NS_2_g1, NS_2_nt3, NS_2_nt4, NS_2_nt5)
`OR_2(NS_2_or, 1, NS_2, NS_2_g0, NS_2_g1)

// clear_rep_o = (!S_0 & !S_1 & S_2 & !cont_mov_i & !wait_mov_i & exit_mov_i & !stall_i)
`AND_7(clear_rep_o_and, 1, clear_rep_o, S_0_inv, S_1_inv, S_2, cont_mov_i_inv, wait_mov_i_inv, exit_mov_i, stall_i_inv)

// select_line2_o = 0
assign select_line2_o = 1'b0;

// select_line1_o = (S_0 & !S_1 & !S_2 & !stall_i)
`AND_4(select_line1_o_and, 1, select_line1_o, S_0, S_1_inv, S_2_inv, stall_i_inv)

// select_line0_o = (S_0 & !S_1 & S_2 & !stall_i)
`AND_4(select_line0_o_and, 1, select_line0_o, S_0, S_1_inv, S_2, stall_i_inv)

endmodule
