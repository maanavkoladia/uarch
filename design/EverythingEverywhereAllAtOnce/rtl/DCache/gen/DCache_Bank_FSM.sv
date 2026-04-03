// ======================================================================
// FSM : DCache_Bank_FSM
// Tool: fsm2rtl.py  (auto-generated -- do not hand-edit)
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
//           1           1           1           0           x           x           x           x           x           x           x  |           0           0           0           0           0           0           1           1           0           0           0           0           0           0           0   SWAPPING_LD -> IDLE
//           0           0           0           1           x           x           x           x           x           x           x  |           1           1           1           0           0           0           0           0           0           0           0           0           0           0           0   SWAPPING_ST0 -> SWAPPING_LD
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

// Next-state wires  (NS_0=LSB ... NS_{N-1}=MSB)
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
wire DTE_Mem_valid_i_inv;
wire D_Swap_valid_i_inv;
wire EB_Hit_i_inv;
wire Line_valid_i_inv;
wire S_0_inv;
wire S_1_inv;
wire S_2_inv;
wire S_3_inv;
wire V_Miss_i_inv;
wire we_i_inv;

inv1$ inv_DTE_Mem_valid_i (DTE_Mem_valid_i_inv, DTE_Mem_valid_i);
inv1$ inv_D_Swap_valid_i (D_Swap_valid_i_inv, D_Swap_valid_i);
inv1$ inv_EB_Hit_i (EB_Hit_i_inv, EB_Hit_i);
inv1$ inv_Line_valid_i (Line_valid_i_inv, Line_valid_i);
inv1$ inv_S_0 (S_0_inv, S_0);
inv1$ inv_S_1 (S_1_inv, S_1);
inv1$ inv_S_2 (S_2_inv, S_2);
inv1$ inv_S_3 (S_3_inv, S_3);
inv1$ inv_V_Miss_i (V_Miss_i_inv, V_Miss_i);
inv1$ inv_we_i (we_i_inv, we_i);

// Next-state and output SOP logic

// NS_0 = (!S_1 & !S_2 & S_3) | (S_0 & !S_1 & !S_2 & EB_Hit_i) | (S_0 & !S_1 & S_2 & !S_3 & !DTE_Mem_valid_i) | (S_1 & !S_2 & !S_3 & !DTE_Mem_valid_i & !D_Swap_valid_i) | (!S_0 & !S_1 & S_2 & !S_3 & DTE_Mem_valid_i) | (!S_0 & S_1 & !S_2 & !S_3 & !D_Swap_valid_i) | (S_0 & S_1 & !S_2 & !S_3 & !DTE_Mem_valid_i) | (!S_0 & !S_1 & !S_2 & D_Miss_i & !Line_valid_i) | (!S_1 & !S_2 & D_Miss_i & EB_Hit_i & !we_i) | (!S_1 & !S_2 & D_Miss_i & V_Miss_i & EB_Hit_i) | (!S_0 & !S_1 & !S_2 & D_Miss_i & !V_Miss_i & !we_i)
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
wire NS_0_t10;

and3$ NS_0_and0 (NS_0_t0, S_1_inv, S_2_inv, S_3);
and4$ NS_0_and1 (NS_0_t1, S_0, S_1_inv, S_2_inv, EB_Hit_i);
and5$ NS_0_and2 (NS_0_t2, S_0, S_1_inv, S_2, S_3_inv, DTE_Mem_valid_i_inv);
and5$ NS_0_and3 (NS_0_t3, S_1, S_2_inv, S_3_inv, DTE_Mem_valid_i_inv, D_Swap_valid_i_inv);
and5$ NS_0_and4 (NS_0_t4, S_0_inv, S_1_inv, S_2, S_3_inv, DTE_Mem_valid_i);
and5$ NS_0_and5 (NS_0_t5, S_0_inv, S_1, S_2_inv, S_3_inv, D_Swap_valid_i_inv);
and5$ NS_0_and6 (NS_0_t6, S_0, S_1, S_2_inv, S_3_inv, DTE_Mem_valid_i_inv);
and5$ NS_0_and7 (NS_0_t7, S_0_inv, S_1_inv, S_2_inv, D_Miss_i, Line_valid_i_inv);
and5$ NS_0_and8 (NS_0_t8, S_1_inv, S_2_inv, D_Miss_i, EB_Hit_i, we_i_inv);
and5$ NS_0_and9 (NS_0_t9, S_1_inv, S_2_inv, D_Miss_i, V_Miss_i, EB_Hit_i);
and6$ NS_0_and10 (NS_0_t10, S_0_inv, S_1_inv, S_2_inv, D_Miss_i, V_Miss_i_inv, we_i_inv);
or11$  NS_0_or  (NS_0, NS_0_t0, NS_0_t1, NS_0_t2, NS_0_t3, NS_0_t4, NS_0_t5, NS_0_t6, NS_0_t7, NS_0_t8, NS_0_t9, NS_0_t10);

// NS_1 = (S_1 & !S_2 & !S_3 & !DTE_Mem_valid_i) | (!S_0 & !S_1 & !S_2 & S_3) | (!S_0 & S_1 & !S_2 & !S_3) | (!S_0 & S_1 & !S_3 & !DTE_Mem_valid_i) | (S_0 & !S_1 & S_2 & !S_3 & DTE_Mem_valid_i) | (!S_0 & !S_2 & !S_3 & D_Miss_i & V_Miss_i & !Line_valid_i) | (!S_0 & !S_2 & !S_3 & D_Miss_i & V_Miss_i & !EB_Hit_i) | (!S_0 & !S_2 & !S_3 & D_Miss_i & !V_Miss_i & Line_valid_i & !we_i)
wire NS_1_t0;
wire NS_1_t1;
wire NS_1_t2;
wire NS_1_t3;
wire NS_1_t4;
wire NS_1_t5;
wire NS_1_t6;
wire NS_1_t7;

and4$ NS_1_and0 (NS_1_t0, S_1, S_2_inv, S_3_inv, DTE_Mem_valid_i_inv);
and4$ NS_1_and1 (NS_1_t1, S_0_inv, S_1_inv, S_2_inv, S_3);
and4$ NS_1_and2 (NS_1_t2, S_0_inv, S_1, S_2_inv, S_3_inv);
and4$ NS_1_and3 (NS_1_t3, S_0_inv, S_1, S_3_inv, DTE_Mem_valid_i_inv);
and5$ NS_1_and4 (NS_1_t4, S_0, S_1_inv, S_2, S_3_inv, DTE_Mem_valid_i);
and6$ NS_1_and5 (NS_1_t5, S_0_inv, S_2_inv, S_3_inv, D_Miss_i, V_Miss_i, Line_valid_i_inv);
and6$ NS_1_and6 (NS_1_t6, S_0_inv, S_2_inv, S_3_inv, D_Miss_i, V_Miss_i, EB_Hit_i_inv);
and7$ NS_1_and7 (NS_1_t7, S_0_inv, S_2_inv, S_3_inv, D_Miss_i, V_Miss_i_inv, Line_valid_i, we_i_inv);
or8$  NS_1_or  (NS_1, NS_1_t0, NS_1_t1, NS_1_t2, NS_1_t3, NS_1_t4, NS_1_t5, NS_1_t6, NS_1_t7);

// NS_2 = (!S_1 & S_2 & !S_3) | (!S_0 & !S_1 & !S_2 & S_3) | (!S_0 & S_2 & !S_3 & !DTE_Mem_valid_i) | (S_0 & S_1 & !S_2 & !S_3 & DTE_Mem_valid_i) | (!S_0 & !S_1 & !S_2 & D_Miss_i & !V_Miss_i & Line_valid_i & !we_i)
wire NS_2_t0;
wire NS_2_t1;
wire NS_2_t2;
wire NS_2_t3;
wire NS_2_t4;

and3$ NS_2_and0 (NS_2_t0, S_1_inv, S_2, S_3_inv);
and4$ NS_2_and1 (NS_2_t1, S_0_inv, S_1_inv, S_2_inv, S_3);
and4$ NS_2_and2 (NS_2_t2, S_0_inv, S_2, S_3_inv, DTE_Mem_valid_i_inv);
and5$ NS_2_and3 (NS_2_t3, S_0, S_1, S_2_inv, S_3_inv, DTE_Mem_valid_i);
and7$ NS_2_and4 (NS_2_t4, S_0_inv, S_1_inv, S_2_inv, D_Miss_i, V_Miss_i_inv, Line_valid_i, we_i_inv);
or5$  NS_2_or  (NS_2, NS_2_t0, NS_2_t1, NS_2_t2, NS_2_t3, NS_2_t4);

// NS_3 = (S_0 & !S_1 & !S_2 & S_3) | (!S_0 & !S_1 & !S_2 & !S_3 & D_Miss_i & !V_Miss_i & !Line_valid_i) | (!S_0 & !S_1 & !S_2 & !S_3 & D_Miss_i & !V_Miss_i & we_i)
wire NS_3_t0;
wire NS_3_t1;
wire NS_3_t2;

and4$ NS_3_and0 (NS_3_t0, S_0, S_1_inv, S_2_inv, S_3);
and7$ NS_3_and1 (NS_3_t1, S_0_inv, S_1_inv, S_2_inv, S_3_inv, D_Miss_i, V_Miss_i_inv, Line_valid_i_inv);
and7$ NS_3_and2 (NS_3_t2, S_0_inv, S_1_inv, S_2_inv, S_3_inv, D_Miss_i, V_Miss_i_inv, we_i);
or3$  NS_3_or  (NS_3, NS_3_t0, NS_3_t1, NS_3_t2);

// write_to_dswap_o = (!S_0 & !S_1 & !S_2 & !S_3 & D_Miss_i & !V_Miss_i & Line_valid_i) | (!S_0 & !S_1 & !S_2 & !S_3 & D_Miss_i & !EB_Hit_i & Line_valid_i)
wire write_to_dswap_o_t0;
wire write_to_dswap_o_t1;

and7$ write_to_dswap_o_and0 (write_to_dswap_o_t0, S_0_inv, S_1_inv, S_2_inv, S_3_inv, D_Miss_i, V_Miss_i_inv, Line_valid_i);
and7$ write_to_dswap_o_and1 (write_to_dswap_o_t1, S_0_inv, S_1_inv, S_2_inv, S_3_inv, D_Miss_i, EB_Hit_i_inv, Line_valid_i);
or2$  write_to_dswap_o_or  (write_to_dswap_o, write_to_dswap_o_t0, write_to_dswap_o_t1);

// D_will_evict_o = (!S_0 & !S_1 & !S_2 & !S_3 & D_Miss_i & V_Miss_i & !EB_Hit_i & Line_valid_i)
and8$ D_will_evict_o_and (D_will_evict_o, S_0_inv, S_1_inv, S_2_inv, S_3_inv, D_Miss_i, V_Miss_i, EB_Hit_i_inv, Line_valid_i);

// ldFrom_V_swap_o = (S_0 & S_1 & S_2 & !S_3)
and4$ ldFrom_V_swap_o_and (ldFrom_V_swap_o, S_0, S_1, S_2, S_3_inv);

// clr_v_swap_o = (S_0 & S_1 & S_2 & !S_3)
and4$ clr_v_swap_o_and (clr_v_swap_o, S_0, S_1, S_2, S_3_inv);

// MakeReq_o = (S_0 & S_1 & !S_2 & !S_3 & !DTE_Mem_valid_i)
and5$ MakeReq_o_and (MakeReq_o, S_0, S_1, S_2_inv, S_3_inv, DTE_Mem_valid_i_inv);

// Blocked_o = (S_0 & !S_1 & !S_2 & !S_3 & EB_Hit_i)
and5$ Blocked_o_and (Blocked_o, S_0, S_1_inv, S_2_inv, S_3_inv, EB_Hit_i);

// busy_o = (S_0 & !S_2 & !S_3) | (!S_1 & S_2 & !S_3) | (!S_0 & S_1 & !S_3)
wire busy_o_t0;
wire busy_o_t1;
wire busy_o_t2;

and3$ busy_o_and0 (busy_o_t0, S_0, S_2_inv, S_3_inv);
and3$ busy_o_and1 (busy_o_t1, S_1_inv, S_2, S_3_inv);
and3$ busy_o_and2 (busy_o_t2, S_0_inv, S_1, S_3_inv);
or3$  busy_o_or  (busy_o, busy_o_t0, busy_o_t1, busy_o_t2);

// fill0_o = (S_0 & S_1 & !S_2 & !S_3 & DTE_Mem_valid_i)
and5$ fill0_o_and (fill0_o, S_0, S_1, S_2_inv, S_3_inv, DTE_Mem_valid_i);

// fill1_o = (!S_0 & !S_1 & S_2 & !S_3 & DTE_Mem_valid_i)
and5$ fill1_o_and (fill1_o, S_0_inv, S_1_inv, S_2, S_3_inv, DTE_Mem_valid_i);

// fill2_o = (S_0 & !S_1 & S_2 & !S_3 & DTE_Mem_valid_i)
and5$ fill2_o_and (fill2_o, S_0, S_1_inv, S_2, S_3_inv, DTE_Mem_valid_i);

// fill3_o = (!S_0 & S_1 & S_2 & !S_3 & DTE_Mem_valid_i)
and5$ fill3_o_and (fill3_o, S_0_inv, S_1, S_2, S_3_inv, DTE_Mem_valid_i);

endmodule
