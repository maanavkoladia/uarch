// ======================================================================
// FSM : DCache_Bank_FSM
// Tool: fsm2rtl.py  (auto-generated -- do not hand-edit)
// Std : Verilog-2005 (IEEE 1364-2005)
// NOTE: ERROR state was synthesised automatically.
//       Any undefined transition lands here (all outputs = 0).
// ======================================================================
//
// State Enumeration  (4 bits, 10 states)
// --------------------------------------------------
//   IDLE                          0000  (decimal 0)  // IDLE (reset state)
//   EB_BLOCKING                   0001  (decimal 1)
//   EVICTING                      0010  (decimal 2)
//   Req0                          0011  (decimal 3)
//   Req1                          0100  (decimal 4)
//   Req2                          0101  (decimal 5)
//   Req3                          0110  (decimal 6)
//   SWAPPING_LD                   0111  (decimal 7)
//   SWAPPING_ST0                  1000  (decimal 8)
//   ERROR                         1001  (decimal 9)  // ERROR (trap state), synthesised
//
// Truth Table (pre-expansion, original CSV rows)
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//         S_0         S_1         S_2         S_3    D_Miss_i    V_Miss_i    EB_Hit_i  Line_valid_i  DTE_Mem_valid_i  D_Swap_valid_i        we_i  |        NS_0        NS_1        NS_2        NS_3  write_to_dswap_o  D_will_evict_o  ldFrom_V_swap_o  clr_v_swap_o   MakeReq_o   Blocked_o      busy_o     fill0_o     fill1_o     fill2_o     fill3_o   transition
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//           0           0           0           0           0           x           x           x           x           x           x  |           0           0           0           0           0           0           0           0           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           0           0           1           1           x           0           x           x           x  |           1           1           0           0           0           0           0           0           0           0           0           0           0           0           0   IDLE -> Req0
//           0           0           0           0           1           0           x           1           x           x           0  |           1           1           1           0           1           0           0           0           0           0           0           0           0           0           0   IDLE -> SWAPPING_LD
//           0           0           0           0           1           0           x           1           x           x           1  |           0           0           0           1           1           0           0           0           0           0           0           0           0           0           0   IDLE -> SWAPPING_ST0
//           0           0           0           0           1           1           0           1           x           x           x  |           0           1           0           0           1           1           0           0           0           0           0           0           0           0           0   IDLE -> EVICTING
//           0           0           0           0           1           1           1           1           x           x           x  |           1           0           0           0           0           0           0           0           0           0           0           0           0           0           0   IDLE -> EB_BLOCKING
//           0           1           0           0           x           x           x           x           x           1           x  |           0           1           0           0           0           0           0           0           0           0           1           0           0           0           0   EVICTING -> EVICTING
//           0           1           0           0           x           x           x           x           x           0           x  |           1           1           0           0           0           0           0           0           0           0           1           0           0           0           0   EVICTING -> Req0
//           1           1           1           0           x           x           x           x           x           x           x  |           0           0           0           0           0           0           1           1           0           0           1           0           0           0           0   SWAPPING_LD -> IDLE
//           0           0           0           1           x           x           x           x           x           x           x  |           1           1           1           0           0           0           0           0           0           0           1           0           0           0           0   SWAPPING_ST0 -> SWAPPING_LD
//           1           0           0           0           x           x           1           x           x           x           x  |           1           0           0           0           0           0           0           0           0           1           1           0           0           0           0   EB_BLOCKING -> EB_BLOCKING
//           1           0           0           0           x           x           0           x           x           x           x  |           0           0           0           0           0           0           0           0           0           0           1           0           0           0           0   EB_BLOCKING -> IDLE
//           1           1           0           0           x           x           x           x           0           x           x  |           1           1           0           0           0           0           0           0           1           0           1           0           0           0           0   Req0 -> Req0
//           1           1           0           0           x           x           x           x           1           x           x  |           0           0           1           0           0           0           0           0           0           0           1           1           0           0           0   Req0 -> Req1
//           0           0           1           0           x           x           x           x           0           x           x  |           0           0           1           0           0           0           0           0           0           0           1           0           0           0           0   Req1 -> Req1
//           0           0           1           0           x           x           x           x           1           x           x  |           1           0           1           0           0           0           0           0           0           0           1           0           1           0           0   Req1 -> Req2
//           1           0           1           0           x           x           x           x           0           x           x  |           1           0           1           0           0           0           0           0           0           0           1           0           0           0           0   Req2 -> Req2
//           1           0           1           0           x           x           x           x           1           x           x  |           0           1           1           0           0           0           0           0           0           0           1           0           0           1           0   Req2 -> Req3
//           0           1           1           0           x           x           x           x           0           x           x  |           0           1           1           0           0           0           0           0           0           0           1           0           0           0           0   Req3 -> Req3
//           0           1           1           0           x           x           x           x           1           x           x  |           0           0           0           0           0           0           0           0           0           0           1           0           0           0           1   Req3 -> IDLE
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//

module DCache_Bank_FSM (
    input  wire clk,
    input  wire rst,
    input  wire D_Miss_i,
    input  wire V_Miss_i,
    input  wire EB_Hit_i,
    input  wire Line_valid_i,
    input  wire DTE_Mem_valid_i,
    input  wire D_Swap_valid_i,
    input  wire we_i,
    output wire S_0,  // current-state bit 0 (LSB)
    output wire S_1,  // current-state bit 1 (1)
    output wire S_2,  // current-state bit 2 (2)
    output wire S_3,  // current-state bit 3 (MSB)
    output wire write_to_dswap_o,
    output wire D_will_evict_o,
    output wire ldFrom_V_swap_o,
    output wire clr_v_swap_o,
    output wire MakeReq_o,
    output wire Blocked_o,
    output wire busy_o,
    output wire fill0_o,
    output wire fill1_o,
    output wire fill2_o,
    output wire fill3_o
);

// ----------------------------------------------------------------
// Next-state wires  (NS_0 = LSB ... NS_{N-1} = MSB)
// ----------------------------------------------------------------
wire NS_0;
wire NS_1;
wire NS_2;
wire NS_3;

// State encoding  (IDLE = 0, ERROR = highest, guaranteed by tool)
//   IDLE                         = 0000  (decimal 0)  // IDLE (reset state)
//   EB_BLOCKING                  = 0001  (decimal 1)
//   EVICTING                     = 0010  (decimal 2)
//   Req0                         = 0011  (decimal 3)
//   Req1                         = 0100  (decimal 4)
//   Req2                         = 0101  (decimal 5)
//   Req3                         = 0110  (decimal 6)
//   SWAPPING_LD                  = 0111  (decimal 7)
//   SWAPPING_ST0                 = 1000  (decimal 8)
//   ERROR                        = 1001  (decimal 9)  // ERROR (trap state), synthesised

// ----------------------------------------------------------------
// State flip-flops
// `REG_RST samples D on every rising clk edge.
// Active-high rst drives all state bits to 0 (= IDLE encoding).
// ----------------------------------------------------------------
// State FFs feed bufferH64$ to lift drive class above the raw reg64e$ tier-4.
// Internal SOP fanout per state bit is up to ~16 (13 SOP + 2 inv inputs + 1
// external port), well within bufferH64$ capacity.
wire S_0_pre, S_1_pre, S_2_pre, S_3_pre;
`REG_RST(ff_0, 1, clk, rst, NS_0, S_0_pre)
`REG_RST(ff_1, 1, clk, rst, NS_1, S_1_pre)
`REG_RST(ff_2, 1, clk, rst, NS_2, S_2_pre)
`REG_RST(ff_3, 1, clk, rst, NS_3, S_3_pre)
bufferH64$ u_S_0_buf (.out(S_0), .in(S_0_pre));
bufferH64$ u_S_1_buf (.out(S_1), .in(S_1_pre));
bufferH64$ u_S_2_buf (.out(S_2), .in(S_2_pre));
bufferH64$ u_S_3_buf (.out(S_3), .in(S_3_pre));

// ----------------------------------------------------------------
// Inverters for negated literals
// ----------------------------------------------------------------
wire DTE_Mem_valid_i_inv;
wire D_Swap_valid_i_inv;
wire EB_Hit_i_inv;
wire Line_valid_i_inv;
wire S_0_inv_a, S_0_inv_b;
wire S_1_inv_a, S_1_inv_b;
wire S_2_inv_a, S_2_inv_b;
wire S_3_inv_a, S_3_inv_b;
wire V_Miss_i_inv;
wire we_i_inv;

`INV_N(inv_DTE_Mem_valid_i, 1, DTE_Mem_valid_i, DTE_Mem_valid_i_inv)
`INV_N(inv_D_Swap_valid_i, 1, D_Swap_valid_i, D_Swap_valid_i_inv)
`INV_N(inv_EB_Hit_i, 1, EB_Hit_i, EB_Hit_i_inv)
`INV_N(inv_Line_valid_i, 1, Line_valid_i, Line_valid_i_inv)
// State-bit inverters replicated 2x: each INV_N is bufferHInv16$ (drives <=16).
`INV_N(inv_S_0_a, 1, S_0, S_0_inv_a)
`INV_N(inv_S_0_b, 1, S_0, S_0_inv_b)
`INV_N(inv_S_1_a, 1, S_1, S_1_inv_a)
`INV_N(inv_S_1_b, 1, S_1, S_1_inv_b)
`INV_N(inv_S_2_a, 1, S_2, S_2_inv_a)
`INV_N(inv_S_2_b, 1, S_2, S_2_inv_b)
`INV_N(inv_S_3_a, 1, S_3, S_3_inv_a)
`INV_N(inv_S_3_b, 1, S_3, S_3_inv_b)
`INV_N(inv_V_Miss_i, 1, V_Miss_i, V_Miss_i_inv)
`INV_N(inv_we_i, 1, we_i, we_i_inv)

// ----------------------------------------------------------------
// Next-state and output SOP logic
// ----------------------------------------------------------------

// NS_0 = (!S_1 & !S_2 & S_3) | (S_0 & !S_1 & !S_2 & EB_Hit_i) | (S_0 & !S_1 & S_2 & !S_3 & !DTE_Mem_valid_i) | (S_1 & !S_2 & !S_3 & !DTE_Mem_valid_i & !D_Swap_valid_i) | (!S_0 & !S_1 & S_2 & !S_3 & DTE_Mem_valid_i) | (!S_0 & S_1 & !S_2 & !S_3 & !D_Swap_valid_i) | (S_0 & S_1 & !S_2 & !S_3 & !DTE_Mem_valid_i) | (!S_0 & !S_1 & !S_2 & D_Miss_i & !Line_valid_i) | (!S_1 & !S_2 & D_Miss_i & EB_Hit_i & !we_i) | (!S_1 & !S_2 & D_Miss_i & V_Miss_i & EB_Hit_i) | (!S_0 & !S_1 & !S_2 & D_Miss_i & !V_Miss_i & !we_i)
wire NS_0_t0;
`AND_3(NS_0_and0, 1, NS_0_t0, S_1_inv_a, S_2_inv_a, S_3)
wire NS_0_t1;
`AND_4(NS_0_and1, 1, NS_0_t1, S_0, S_1_inv_a, S_2_inv_a, EB_Hit_i)
wire NS_0_t2;
`AND_5(NS_0_and2, 1, NS_0_t2, S_0, S_1_inv_a, S_2, S_3_inv_a, DTE_Mem_valid_i_inv)
wire NS_0_t3;
`AND_5(NS_0_and3, 1, NS_0_t3, S_1, S_2_inv_a, S_3_inv_a, DTE_Mem_valid_i_inv, D_Swap_valid_i_inv)
wire NS_0_t4;
`AND_5(NS_0_and4, 1, NS_0_t4, S_0_inv_a, S_1_inv_a, S_2, S_3_inv_a, DTE_Mem_valid_i)
wire NS_0_t5;
`AND_5(NS_0_and5, 1, NS_0_t5, S_0_inv_a, S_1, S_2_inv_a, S_3_inv_a, D_Swap_valid_i_inv)
wire NS_0_t6;
`AND_5(NS_0_and6, 1, NS_0_t6, S_0, S_1, S_2_inv_a, S_3_inv_a, DTE_Mem_valid_i_inv)
wire NS_0_t7;
`AND_5(NS_0_and7, 1, NS_0_t7, S_0_inv_a, S_1_inv_a, S_2_inv_a, D_Miss_i, Line_valid_i_inv)
wire NS_0_t8;
`AND_5(NS_0_and8, 1, NS_0_t8, S_1_inv_a, S_2_inv_a, D_Miss_i, EB_Hit_i, we_i_inv)
wire NS_0_t9;
`AND_5(NS_0_and9, 1, NS_0_t9, S_1_inv_a, S_2_inv_a, D_Miss_i, V_Miss_i, EB_Hit_i)
wire NS_0_t10;
`AND_6(NS_0_and10, 1, NS_0_t10, S_0_inv_a, S_1_inv_a, S_2_inv_a, D_Miss_i, V_Miss_i_inv, we_i_inv)

`OR_11(NS_0_or, 1, NS_0, NS_0_t0, NS_0_t1, NS_0_t2, NS_0_t3, NS_0_t4, NS_0_t5, NS_0_t6, NS_0_t7, NS_0_t8, NS_0_t9, NS_0_t10)

// NS_1 = (!S_0 & S_1 & !S_2 & !S_3) | (!S_0 & !S_1 & !S_2 & S_3) | (S_1 & !S_2 & !S_3 & !DTE_Mem_valid_i) | (!S_0 & S_1 & !S_3 & !DTE_Mem_valid_i) | (S_0 & !S_1 & S_2 & !S_3 & DTE_Mem_valid_i) | (!S_0 & !S_1 & !S_2 & D_Miss_i & V_Miss_i & !EB_Hit_i) | (!S_0 & !S_1 & !S_2 & D_Miss_i & V_Miss_i & !Line_valid_i) | (!S_0 & !S_1 & !S_2 & D_Miss_i & !V_Miss_i & Line_valid_i & !we_i)
wire NS_1_t0;
`AND_4(NS_1_and0, 1, NS_1_t0, S_0_inv_a, S_1, S_2_inv_a, S_3_inv_a)
wire NS_1_t1;
`AND_4(NS_1_and1, 1, NS_1_t1, S_0_inv_a, S_1_inv_a, S_2_inv_a, S_3)
wire NS_1_t2;
`AND_4(NS_1_and2, 1, NS_1_t2, S_1, S_2_inv_a, S_3_inv_a, DTE_Mem_valid_i_inv)
wire NS_1_t3;
`AND_4(NS_1_and3, 1, NS_1_t3, S_0_inv_a, S_1, S_3_inv_a, DTE_Mem_valid_i_inv)
wire NS_1_t4;
`AND_5(NS_1_and4, 1, NS_1_t4, S_0, S_1_inv_a, S_2, S_3_inv_a, DTE_Mem_valid_i)
wire NS_1_t5;
`AND_6(NS_1_and5, 1, NS_1_t5, S_0_inv_a, S_1_inv_a, S_2_inv_a, D_Miss_i, V_Miss_i, EB_Hit_i_inv)
wire NS_1_t6;
`AND_6(NS_1_and6, 1, NS_1_t6, S_0_inv_a, S_1_inv_a, S_2_inv_a, D_Miss_i, V_Miss_i, Line_valid_i_inv)
wire NS_1_t7;
`AND_7(NS_1_and7, 1, NS_1_t7, S_0_inv_a, S_1_inv_a, S_2_inv_a, D_Miss_i, V_Miss_i_inv, Line_valid_i, we_i_inv)

`OR_8(NS_1_or, 1, NS_1, NS_1_t0, NS_1_t1, NS_1_t2, NS_1_t3, NS_1_t4, NS_1_t5, NS_1_t6, NS_1_t7)

// NS_2 = (!S_1 & S_2 & !S_3) | (!S_0 & !S_1 & !S_2 & S_3) | (!S_0 & S_2 & !S_3 & !DTE_Mem_valid_i) | (S_0 & S_1 & !S_2 & !S_3 & DTE_Mem_valid_i) | (!S_0 & !S_1 & !S_2 & D_Miss_i & !V_Miss_i & Line_valid_i & !we_i)
wire NS_2_t0;
`AND_3(NS_2_and0, 1, NS_2_t0, S_1_inv_a, S_2, S_3_inv_a)
wire NS_2_t1;
`AND_4(NS_2_and1, 1, NS_2_t1, S_0_inv_a, S_1_inv_a, S_2_inv_a, S_3)
wire NS_2_t2;
`AND_4(NS_2_and2, 1, NS_2_t2, S_0_inv_a, S_2, S_3_inv_a, DTE_Mem_valid_i_inv)
wire NS_2_t3;
`AND_5(NS_2_and3, 1, NS_2_t3, S_0, S_1, S_2_inv_b, S_3_inv_a, DTE_Mem_valid_i)
wire NS_2_t4;
`AND_7(NS_2_and4, 1, NS_2_t4, S_0_inv_a, S_1_inv_a, S_2_inv_b, D_Miss_i, V_Miss_i_inv, Line_valid_i, we_i_inv)

`OR_5(NS_2_or, 1, NS_2, NS_2_t0, NS_2_t1, NS_2_t2, NS_2_t3, NS_2_t4)

// NS_3 = (S_0 & !S_1 & !S_2 & S_3) | (!S_0 & !S_1 & !S_2 & !S_3 & D_Miss_i & !V_Miss_i & we_i) | (!S_0 & !S_1 & !S_2 & !S_3 & D_Miss_i & !V_Miss_i & !Line_valid_i)
wire NS_3_t0;
`AND_4(NS_3_and0, 1, NS_3_t0, S_0, S_1_inv_b, S_2_inv_b, S_3)
wire NS_3_t1;
`AND_7(NS_3_and1, 1, NS_3_t1, S_0_inv_a, S_1_inv_b, S_2_inv_b, S_3_inv_a, D_Miss_i, V_Miss_i_inv, we_i)
wire NS_3_t2;
`AND_7(NS_3_and2, 1, NS_3_t2, S_0_inv_a, S_1_inv_b, S_2_inv_b, S_3_inv_a, D_Miss_i, V_Miss_i_inv, Line_valid_i_inv)

`OR_3(NS_3_or, 1, NS_3, NS_3_t0, NS_3_t1, NS_3_t2)

// write_to_dswap_o = (!S_0 & !S_1 & !S_2 & !S_3 & D_Miss_i & !V_Miss_i & Line_valid_i) | (!S_0 & !S_1 & !S_2 & !S_3 & D_Miss_i & !EB_Hit_i & Line_valid_i)
wire write_to_dswap_o_t0;
`AND_7(write_to_dswap_o_and0, 1, write_to_dswap_o_t0, S_0_inv_a, S_1_inv_b, S_2_inv_b, S_3_inv_a, D_Miss_i, V_Miss_i_inv, Line_valid_i)
wire write_to_dswap_o_t1;
`AND_7(write_to_dswap_o_and1, 1, write_to_dswap_o_t1, S_0_inv_b, S_1_inv_b, S_2_inv_b, S_3_inv_a, D_Miss_i, EB_Hit_i_inv, Line_valid_i)

// External fanout 8; bufferH16$ covers up to 16.
wire write_to_dswap_o_pre;
`OR_2(write_to_dswap_o_or, 1, write_to_dswap_o_pre, write_to_dswap_o_t0, write_to_dswap_o_t1)
bufferH16$ u_write_to_dswap_o_buf (.out(write_to_dswap_o), .in(write_to_dswap_o_pre));

// D_will_evict_o = (!S_0 & !S_1 & !S_2 & !S_3 & D_Miss_i & V_Miss_i & !EB_Hit_i & Line_valid_i)
// External fanout 6 (under tier-16); add bufferH16$ to satisfy AND-output drive limit.
wire D_will_evict_o_pre;
`AND_8(D_will_evict_o_and, 1, D_will_evict_o_pre, S_0_inv_b, S_1_inv_b, S_2_inv_b, S_3_inv_b, D_Miss_i, V_Miss_i, EB_Hit_i_inv, Line_valid_i)
bufferH16$ u_D_will_evict_o_buf (.out(D_will_evict_o), .in(D_will_evict_o_pre));

// ldFrom_V_swap_o = (S_0 & S_1 & S_2 & !S_3)
// External fanout 147 (top-of-design); use bufferH256$.
wire ldFrom_V_swap_o_pre;
`AND_4(ldFrom_V_swap_o_and, 1, ldFrom_V_swap_o_pre, S_0, S_1, S_2, S_3_inv_b)
bufferH256$ u_ldFrom_V_swap_o_buf (.out(ldFrom_V_swap_o), .in(ldFrom_V_swap_o_pre));

// clr_v_swap_o = (S_0 & S_1 & S_2 & !S_3)
`AND_4(clr_v_swap_o_and, 1, clr_v_swap_o, S_0, S_1, S_2, S_3_inv_b)

// MakeReq_o = (S_0 & S_1 & !S_2 & !S_3 & !DTE_Mem_valid_i)
`AND_5(MakeReq_o_and, 1, MakeReq_o, S_0, S_1, S_2_inv_b, S_3_inv_b, DTE_Mem_valid_i_inv)

// Blocked_o = (S_0 & !S_1 & !S_2 & !S_3 & EB_Hit_i)
`AND_5(Blocked_o_and, 1, Blocked_o, S_0, S_1_inv_b, S_2_inv_b, S_3_inv_b, EB_Hit_i)

// busy_o = (S_0 & !S_3) | (S_2 & !S_3) | (S_1 & !S_3) | (!S_0 & !S_1 & !S_2 & S_3)
wire busy_o_n0;
`NAND_2(busy_o_nand0, 1, busy_o_n0, S_0, S_3_inv_b)
wire busy_o_n1;
`NAND_2(busy_o_nand1, 1, busy_o_n1, S_2, S_3_inv_b)
wire busy_o_n2;
`NAND_2(busy_o_nand2, 1, busy_o_n2, S_1, S_3_inv_b)
wire busy_o_n3;
`NAND_4(busy_o_nand3, 1, busy_o_n3, S_0_inv_b, S_1_inv_b, S_2_inv_b, S_3)

// External fanout 163 (top-of-design); use bufferH256$.
wire busy_o_pre;
`NAND_4(busy_o_nand, 1, busy_o_pre, busy_o_n0, busy_o_n1, busy_o_n2, busy_o_n3)
bufferH256$ u_busy_o_buf (.out(busy_o), .in(busy_o_pre));

// fill0/1/2/3_o each have external fanout 37-39 (per-bank fill enables);
// use bufferH64$ on each (covers up to 64 loads).
// fill0_o = (S_0 & S_1 & !S_2 & !S_3 & DTE_Mem_valid_i)
wire fill0_o_pre;
`AND_5(fill0_o_and, 1, fill0_o_pre, S_0, S_1, S_2_inv_b, S_3_inv_b, DTE_Mem_valid_i)
bufferH64$ u_fill0_o_buf (.out(fill0_o), .in(fill0_o_pre));

// fill1_o = (!S_0 & !S_1 & S_2 & !S_3 & DTE_Mem_valid_i)
wire fill1_o_pre;
`AND_5(fill1_o_and, 1, fill1_o_pre, S_0_inv_b, S_1_inv_b, S_2, S_3_inv_b, DTE_Mem_valid_i)
bufferH64$ u_fill1_o_buf (.out(fill1_o), .in(fill1_o_pre));

// fill2_o = (S_0 & !S_1 & S_2 & !S_3 & DTE_Mem_valid_i)
wire fill2_o_pre;
`AND_5(fill2_o_and, 1, fill2_o_pre, S_0, S_1_inv_b, S_2, S_3_inv_b, DTE_Mem_valid_i)
bufferH64$ u_fill2_o_buf (.out(fill2_o), .in(fill2_o_pre));

// fill3_o = (!S_0 & S_1 & S_2 & !S_3 & DTE_Mem_valid_i)
wire fill3_o_pre;
`AND_5(fill3_o_and, 1, fill3_o_pre, S_0_inv_b, S_1, S_2, S_3_inv_b, DTE_Mem_valid_i)
bufferH64$ u_fill3_o_buf (.out(fill3_o), .in(fill3_o_pre));

endmodule
