// ======================================================================
// FSM : rep_cmp_fsm
// Tool: fsm2rtl.py  (auto-generated -- do not hand-edit)
// Std : Verilog-2005 (IEEE 1364-2005)
// NOTE: ERROR state was synthesised automatically.
//       Any undefined transition lands here (all outputs = 0).
// ======================================================================
//
// State Enumeration  (3 bits, 8 states)
// --------------------------------------------------
//   IDLE                          000  (decimal 0)  // IDLE (reset state)
//   CMP                           001  (decimal 1)
//   CMP0                          010  (decimal 2)
//   CMP1                          011  (decimal 3)
//   CMP2                          100  (decimal 4)
//   CMP3                          101  (decimal 5)
//   DEC_ECX_CMP                   110  (decimal 6)
//   ERROR                         111  (decimal 7)  // ERROR (trap state), synthesised
//
// Truth Table (pre-expansion, original CSV rows)
// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//         S_0         S_1         S_2     start_i  exit_mov_i  cont_cmp_i  exit_cmp_i      wait_i  |        NS_0        NS_1        NS_2  clear_rep_o  select_line2_o  select_line1_o  select_line0_o   transition
// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//           0           0           0           0           x           x           x           0  |           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           0           1           x           x           x           0  |           1           0           0           0           0           0           0   IDLE -> CMP
//           1           0           0           x           0           x           x           0  |           0           1           0           0           0           0           0   CMP -> CMP0
//           1           0           0           x           1           x           x           0  |           0           0           0           1           0           0           0   CMP -> IDLE
//           0           1           0           x           x           x           x           0  |           1           1           0           0           0           1           1   CMP0 -> CMP1
//           1           1           0           x           x           x           x           0  |           0           1           1           0           1           0           0   CMP1 -> DEC_ECX_CMP
//           0           1           1           x           x           x           x           0  |           0           0           1           0           0           1           0   DEC_ECX_CMP -> CMP2
//           0           0           1           x           x           x           x           0  |           1           0           1           0           1           0           1   CMP2 -> CMP3
//           1           0           1           x           x           1           0           0  |           0           1           0           0           0           0           0   CMP3 -> CMP0
//           1           0           1           x           x           0           1           0  |           0           0           0           1           0           0           0   CMP3 -> IDLE
//           0           0           0           x           x           x           x           1  |           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           1           1           x           x           x           x           1  |           0           1           1           0           0           0           0   DEC_ECX_CMP -> DEC_ECX_CMP
//           0           1           0           x           x           x           x           1  |           0           1           0           0           0           0           0   CMP0 -> CMP0
//           1           1           0           x           x           x           x           1  |           1           1           0           0           0           0           0   CMP1 -> CMP1
//           0           0           1           x           x           x           x           1  |           0           0           1           0           0           0           0   CMP2 -> CMP2
//           1           0           1           x           x           x           x           1  |           1           0           1           0           0           0           0   CMP3 -> CMP3
// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//

module rep_cmp_fsm (
    input  wire clk,
    input  wire rst,
    input  wire start_i,
    input  wire exit_mov_i,
    input  wire cont_cmp_i,
    input  wire exit_cmp_i,
    input  wire wait_i,
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
//   CMP                          = 001  (decimal 1)
//   CMP0                         = 010  (decimal 2)
//   CMP1                         = 011  (decimal 3)
//   CMP2                         = 100  (decimal 4)
//   CMP3                         = 101  (decimal 5)
//   DEC_ECX_CMP                  = 110  (decimal 6)
//   ERROR                        = 111  (decimal 7)  // ERROR (trap state), synthesised

// ----------------------------------------------------------------
// State flip-flops
// `REG_RST samples D on every rising clk edge.
// Active-high rst drives all state bits to 0 (= IDLE encoding).
// ----------------------------------------------------------------
`REG_RST(ff_0, 1, clk, rst, NS_0, S_0)
`REG_RST(ff_1, 1, clk, rst, NS_1, S_1)
`REG_RST(ff_2, 1, clk, rst, NS_2, S_2)

// ----------------------------------------------------------------
// Inverters for negated literals
// ----------------------------------------------------------------
wire S_0_inv;
wire S_1_inv;
wire S_2_inv;
wire cont_cmp_i_inv;
wire exit_cmp_i_inv;
wire exit_mov_i_inv;
wire wait_i_inv;

`INV_N(inv_S_0, 1, S_0, S_0_inv)
`INV_N(inv_S_1, 1, S_1, S_1_inv)
`INV_N(inv_S_2, 1, S_2, S_2_inv)
`INV_N(inv_cont_cmp_i, 1, cont_cmp_i, cont_cmp_i_inv)
`INV_N(inv_exit_cmp_i, 1, exit_cmp_i, exit_cmp_i_inv)
`INV_N(inv_exit_mov_i, 1, exit_mov_i, exit_mov_i_inv)
`INV_N(inv_wait_i, 1, wait_i, wait_i_inv)

// ----------------------------------------------------------------
// Next-state and output SOP logic
// ----------------------------------------------------------------

// NS_0 = (S_0 & wait_i) | (S_0 & S_1 & S_2) | (!S_0 & !S_2 & start_i & !wait_i) | (!S_0 & !S_1 & S_2 & !wait_i) | (!S_0 & S_1 & !S_2 & !wait_i) | (S_0 & S_2 & cont_cmp_i & exit_cmp_i) | (S_0 & S_2 & !cont_cmp_i & !exit_cmp_i)
wire NS_0_t0;
`AND_2(NS_0_and0, 1, NS_0_t0, S_0, wait_i)
wire NS_0_t1;
`AND_3(NS_0_and1, 1, NS_0_t1, S_0, S_1, S_2)
wire NS_0_t2;
`AND_4(NS_0_and2, 1, NS_0_t2, S_0_inv, S_2_inv, start_i, wait_i_inv)
wire NS_0_t3;
`AND_4(NS_0_and3, 1, NS_0_t3, S_0_inv, S_1_inv, S_2, wait_i_inv)
wire NS_0_t4;
`AND_4(NS_0_and4, 1, NS_0_t4, S_0_inv, S_1, S_2_inv, wait_i_inv)
wire NS_0_t5;
`AND_4(NS_0_and5, 1, NS_0_t5, S_0, S_2, cont_cmp_i, exit_cmp_i)
wire NS_0_t6;
`AND_4(NS_0_and6, 1, NS_0_t6, S_0, S_2, cont_cmp_i_inv, exit_cmp_i_inv)

`OR_7(NS_0_or, 1, NS_0, NS_0_t0, NS_0_t1, NS_0_t2, NS_0_t3, NS_0_t4, NS_0_t5, NS_0_t6)

// NS_1 = (S_0 & S_1) | (S_1 & wait_i) | (S_1 & !S_2) | (S_0 & !S_2 & wait_i) | (S_0 & !S_2 & !exit_mov_i) | (S_0 & S_2 & !exit_cmp_i & !wait_i) | (S_0 & S_2 & cont_cmp_i & !wait_i)
wire NS_1_t0;
`AND_2(NS_1_and0, 1, NS_1_t0, S_0, S_1)
wire NS_1_t1;
`AND_2(NS_1_and1, 1, NS_1_t1, S_1, wait_i)
wire NS_1_t2;
`AND_2(NS_1_and2, 1, NS_1_t2, S_1, S_2_inv)
wire NS_1_t3;
`AND_3(NS_1_and3, 1, NS_1_t3, S_0, S_2_inv, wait_i)
wire NS_1_t4;
`AND_3(NS_1_and4, 1, NS_1_t4, S_0, S_2_inv, exit_mov_i_inv)
wire NS_1_t5;
`AND_4(NS_1_and5, 1, NS_1_t5, S_0, S_2, exit_cmp_i_inv, wait_i_inv)
wire NS_1_t6;
`AND_4(NS_1_and6, 1, NS_1_t6, S_0, S_2, cont_cmp_i, wait_i_inv)

`OR_7(NS_1_or, 1, NS_1, NS_1_t0, NS_1_t1, NS_1_t2, NS_1_t3, NS_1_t4, NS_1_t5, NS_1_t6)

// NS_2 = (!S_0 & S_2) | (S_2 & wait_i) | (S_0 & S_1 & !wait_i) | (S_0 & !S_1 & wait_i) | (S_2 & !cont_cmp_i & !exit_cmp_i) | (S_2 & cont_cmp_i & exit_cmp_i)
wire NS_2_t0;
`AND_2(NS_2_and0, 1, NS_2_t0, S_0_inv, S_2)
wire NS_2_t1;
`AND_2(NS_2_and1, 1, NS_2_t1, S_2, wait_i)
wire NS_2_t2;
`AND_3(NS_2_and2, 1, NS_2_t2, S_0, S_1, wait_i_inv)
wire NS_2_t3;
`AND_3(NS_2_and3, 1, NS_2_t3, S_0, S_1_inv, wait_i)
wire NS_2_t4;
`AND_3(NS_2_and4, 1, NS_2_t4, S_2, cont_cmp_i_inv, exit_cmp_i_inv)
wire NS_2_t5;
`AND_3(NS_2_and5, 1, NS_2_t5, S_2, cont_cmp_i, exit_cmp_i)

`OR_6(NS_2_or, 1, NS_2, NS_2_t0, NS_2_t1, NS_2_t2, NS_2_t3, NS_2_t4, NS_2_t5)

// clear_rep_o = (S_0 & !S_1 & !S_2 & exit_mov_i & !wait_i) | (S_0 & !S_1 & S_2 & !cont_cmp_i & exit_cmp_i & !wait_i)
wire clear_rep_o_t0;
`AND_5(clear_rep_o_and0, 1, clear_rep_o_t0, S_0, S_1_inv, S_2_inv, exit_mov_i, wait_i_inv)
wire clear_rep_o_t1;
`AND_6(clear_rep_o_and1, 1, clear_rep_o_t1, S_0, S_1_inv, S_2, cont_cmp_i_inv, exit_cmp_i, wait_i_inv)

`OR_2(clear_rep_o_or, 1, clear_rep_o, clear_rep_o_t0, clear_rep_o_t1)

// select_line2_o = (!S_0 & !S_1 & S_2 & !wait_i) | (S_0 & S_1 & !S_2 & !wait_i)
wire select_line2_o_n0;
`NAND_4(select_line2_o_nand0, 1, select_line2_o_n0, S_0_inv, S_1_inv, S_2, wait_i_inv)
wire select_line2_o_n1;
`NAND_4(select_line2_o_nand1, 1, select_line2_o_n1, S_0, S_1, S_2_inv, wait_i_inv)

`NAND_2(select_line2_o_nand, 1, select_line2_o, select_line2_o_n0, select_line2_o_n1)

// select_line1_o = (!S_0 & S_1 & !wait_i)
`AND_3(select_line1_o_and, 1, select_line1_o, S_0_inv, S_1, wait_i_inv)

// select_line0_o = (!S_0 & !S_1 & S_2 & !wait_i) | (!S_0 & S_1 & !S_2 & !wait_i)
wire select_line0_o_n0;
`NAND_4(select_line0_o_nand0, 1, select_line0_o_n0, S_0_inv, S_1_inv, S_2, wait_i_inv)
wire select_line0_o_n1;
`NAND_4(select_line0_o_nand1, 1, select_line0_o_n1, S_0_inv, S_1, S_2_inv, wait_i_inv)

`NAND_2(select_line0_o_nand, 1, select_line0_o, select_line0_o_n0, select_line0_o_n1)

endmodule
