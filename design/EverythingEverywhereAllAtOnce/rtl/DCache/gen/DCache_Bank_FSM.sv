// ======================================================================
// FSM : DCache_Bank_FSM
// Tool: fsm2rtl.py  (auto-generated -- do not hand-edit)
// NOTE: ERROR state was synthesised automatically.
//       Any undefined transition lands here (all outputs = 0).
// ======================================================================
//
// State Enumeration  (3 bits, 8 states)
// --------------------------------------------------
//   IDLE                          000  (decimal 0)  // IDLE (reset state)
//   EVICTING                      001  (decimal 1)
//   Req0                          010  (decimal 2)
//   Req1                          011  (decimal 3)
//   Req2                          100  (decimal 4)
//   Req3                          101  (decimal 5)
//   SWAPPING                      110  (decimal 6)
//   ERROR                         111  (decimal 7)  // ERROR (trap state), synthesised
//
// Truth Table (pre-expansion, original CSV rows)
// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//         S_0         S_1         S_2    D_Miss_i    V_Miss_i  Line_valid_i  DTE_Mem_valid_i  D_Swap_valid_i  |        NS_0        NS_1        NS_2  write_to_dswap_o  D_will_evict_o   mem_req_o      busy_o  ld_V_swap_o  invalidate_v_swap_o   MakeReq_o     fill0_o     fill1_o     fill2_o     fill3_o   transition
// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//           0           0           0           0           x           x           x           x  |           0           0           0           0           0           0           0           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           0           1           1           1           x           x  |           1           0           0           1           1           0           1           0           0           0           0           0           0           0   IDLE -> EVICTING
//           0           0           0           1           1           0           x           x  |           0           1           0           0           0           1           1           0           0           0           0           0           0           0   IDLE -> Req0
//           0           0           0           1           0           1           x           x  |           0           1           1           1           0           0           1           0           0           0           0           0           0           0   IDLE -> SWAPPING
//           1           0           0           x           x           x           x           1  |           1           0           0           0           0           0           1           0           0           0           0           0           0           0   EVICTING -> EVICTING
//           1           0           0           x           x           x           x           0  |           0           1           0           0           0           1           1           0           0           0           0           0           0           0   EVICTING -> Req0
//           0           1           1           x           x           x           x           x  |           0           0           0           0           0           0           1           1           1           0           0           0           0           0   SWAPPING -> IDLE
//           0           1           0           x           x           x           0           x  |           0           1           0           0           0           1           1           0           0           1           0           0           0           0   Req0 -> Req0
//           0           1           0           x           x           x           1           x  |           1           1           0           0           0           1           1           0           0           0           1           0           0           0   Req0 -> Req1
//           1           1           0           x           x           x           0           x  |           1           1           0           0           0           1           1           0           0           0           0           0           0           0   Req1 -> Req1
//           1           1           0           x           x           x           1           x  |           0           0           1           0           0           1           1           0           0           0           0           1           0           0   Req1 -> Req2
//           0           0           1           x           x           x           0           x  |           0           0           1           0           0           1           1           0           0           0           0           0           0           0   Req2 -> Req2
//           0           0           1           x           x           x           1           x  |           1           0           1           0           0           1           1           0           0           0           0           0           1           0   Req2 -> Req3
//           1           0           1           x           x           x           0           x  |           1           0           1           0           0           1           1           0           0           0           0           0           0           0   Req3 -> Req3
//           1           0           1           x           x           x           1           x  |           0           0           0           0           0           1           1           0           0           0           0           0           0           1   Req3 -> IDLE
// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//

module DCache_Bank_FSM (
    input  wire clk,
    input  wire rst,
    input  wire D_Miss_i,
    input  wire V_Miss_i,
    input  wire Line_valid_i,
    input  wire DTE_Mem_valid_i,
    input  wire D_Swap_valid_i,
    output wire S_0,  // current-state bit 0 (LSB)
    output wire S_1,  // current-state bit 1 (1)
    output wire S_2,  // current-state bit 2 (MSB)
    output wire write_to_dswap_o,
    output wire D_will_evict_o,
    output wire mem_req_o,
    output wire busy_o,
    output wire ld_V_swap_o,
    output wire invalidate_v_swap_o,
    output wire MakeReq_o,
    output wire fill0_o,
    output wire fill1_o,
    output wire fill2_o,
    output wire fill3_o
);

// Next-state wires  (NS_0=LSB ... NS_{N-1}=MSB)
wire NS_0;
wire NS_1;
wire NS_2;

// State encoding  (IDLE = 0, ERROR = highest, guaranteed by tool)
//   IDLE                         = 000  (decimal 0)  // IDLE (reset state)
//   EVICTING                     = 001  (decimal 1)
//   Req0                         = 010  (decimal 2)
//   Req1                         = 011  (decimal 3)
//   Req2                         = 100  (decimal 4)
//   Req3                         = 101  (decimal 5)
//   SWAPPING                     = 110  (decimal 6)
//   ERROR                        = 111  (decimal 7)  // ERROR (trap state), synthesised

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

// Inverters
wire DTE_Mem_valid_i_inv;
wire D_Swap_valid_i_inv;
wire Line_valid_i_inv;
wire S_0_inv;
wire S_1_inv;
wire S_2_inv;
wire V_Miss_i_inv;

inv1$ inv_DTE_Mem_valid_i (DTE_Mem_valid_i_inv, DTE_Mem_valid_i);
inv1$ inv_D_Swap_valid_i (D_Swap_valid_i_inv, D_Swap_valid_i);
inv1$ inv_Line_valid_i (Line_valid_i_inv, Line_valid_i);
inv1$ inv_S_0 (S_0_inv, S_0);
inv1$ inv_S_1 (S_1_inv, S_1);
inv1$ inv_S_2 (S_2_inv, S_2);
inv1$ inv_V_Miss_i (V_Miss_i_inv, V_Miss_i);

// Next-state and output SOP logic

// NS_0 = (S_0 & S_2 & !DTE_Mem_valid_i) | (S_0 & !DTE_Mem_valid_i & D_Swap_valid_i) | (S_0 & S_1 & S_2) | (!S_0 & S_1 & !S_2 & DTE_Mem_valid_i) | (!S_0 & !S_1 & S_2 & DTE_Mem_valid_i) | (S_0 & S_1 & !DTE_Mem_valid_i) | (S_0 & !S_1 & !S_2 & D_Swap_valid_i) | (!S_0 & !S_1 & !S_2 & D_Miss_i & V_Miss_i & Line_valid_i) | (!S_0 & !S_1 & !S_2 & D_Miss_i & !V_Miss_i & !Line_valid_i)
wire NS_0_t0;
wire NS_0_t1;
wire NS_0_t2;
wire NS_0_t3;
wire NS_0_t4;
wire NS_0_t5;
wire NS_0_t6;
wire NS_0_t7;
wire NS_0_t8;

and3$ NS_0_and0 (NS_0_t0, S_0, S_2, DTE_Mem_valid_i_inv);
and3$ NS_0_and1 (NS_0_t1, S_0, DTE_Mem_valid_i_inv, D_Swap_valid_i);
and3$ NS_0_and2 (NS_0_t2, S_0, S_1, S_2);
and4$ NS_0_and3 (NS_0_t3, S_0_inv, S_1, S_2_inv, DTE_Mem_valid_i);
and4$ NS_0_and4 (NS_0_t4, S_0_inv, S_1_inv, S_2, DTE_Mem_valid_i);
and3$ NS_0_and5 (NS_0_t5, S_0, S_1, DTE_Mem_valid_i_inv);
and4$ NS_0_and6 (NS_0_t6, S_0, S_1_inv, S_2_inv, D_Swap_valid_i);
and6$ NS_0_and7 (NS_0_t7, S_0_inv, S_1_inv, S_2_inv, D_Miss_i, V_Miss_i, Line_valid_i);
and6$ NS_0_and8 (NS_0_t8, S_0_inv, S_1_inv, S_2_inv, D_Miss_i, V_Miss_i_inv, Line_valid_i_inv);
or9$  NS_0_or  (NS_0, NS_0_t0, NS_0_t1, NS_0_t2, NS_0_t3, NS_0_t4, NS_0_t5, NS_0_t6, NS_0_t7, NS_0_t8);

// NS_1 = (S_1 & !S_2 & !DTE_Mem_valid_i) | (S_0 & S_1 & S_2) | (!S_0 & S_1 & !S_2) | (S_0 & !S_1 & !S_2 & !D_Swap_valid_i) | (!S_0 & !S_2 & D_Miss_i & !Line_valid_i) | (!S_0 & !S_2 & D_Miss_i & !V_Miss_i)
wire NS_1_t0;
wire NS_1_t1;
wire NS_1_t2;
wire NS_1_t3;
wire NS_1_t4;
wire NS_1_t5;

and3$ NS_1_and0 (NS_1_t0, S_1, S_2_inv, DTE_Mem_valid_i_inv);
and3$ NS_1_and1 (NS_1_t1, S_0, S_1, S_2);
and3$ NS_1_and2 (NS_1_t2, S_0_inv, S_1, S_2_inv);
and4$ NS_1_and3 (NS_1_t3, S_0, S_1_inv, S_2_inv, D_Swap_valid_i_inv);
and4$ NS_1_and4 (NS_1_t4, S_0_inv, S_2_inv, D_Miss_i, Line_valid_i_inv);
and4$ NS_1_and5 (NS_1_t5, S_0_inv, S_2_inv, D_Miss_i, V_Miss_i_inv);
or6$  NS_1_or  (NS_1, NS_1_t0, NS_1_t1, NS_1_t2, NS_1_t3, NS_1_t4, NS_1_t5);

// NS_2 = (!S_0 & !S_1 & S_2) | (S_0 & S_2 & !DTE_Mem_valid_i) | (S_0 & S_1 & DTE_Mem_valid_i) | (!S_0 & !S_1 & D_Miss_i & !V_Miss_i)
wire NS_2_t0;
wire NS_2_t1;
wire NS_2_t2;
wire NS_2_t3;

and3$ NS_2_and0 (NS_2_t0, S_0_inv, S_1_inv, S_2);
and3$ NS_2_and1 (NS_2_t1, S_0, S_2, DTE_Mem_valid_i_inv);
and3$ NS_2_and2 (NS_2_t2, S_0, S_1, DTE_Mem_valid_i);
and4$ NS_2_and3 (NS_2_t3, S_0_inv, S_1_inv, D_Miss_i, V_Miss_i_inv);
or4$  NS_2_or  (NS_2, NS_2_t0, NS_2_t1, NS_2_t2, NS_2_t3);

// write_to_dswap_o = (!S_0 & !S_1 & !S_2 & D_Miss_i & Line_valid_i)
and5$ write_to_dswap_o_and (write_to_dswap_o, S_0_inv, S_1_inv, S_2_inv, D_Miss_i, Line_valid_i);

// D_will_evict_o = (!S_0 & !S_1 & !S_2 & D_Miss_i & V_Miss_i & Line_valid_i)
and6$ D_will_evict_o_and (D_will_evict_o, S_0_inv, S_1_inv, S_2_inv, D_Miss_i, V_Miss_i, Line_valid_i);

// mem_req_o = (S_1 & !S_2) | (!S_1 & S_2) | (S_0 & !S_1 & !D_Swap_valid_i) | (!S_0 & !S_1 & D_Miss_i & V_Miss_i & !Line_valid_i)
wire mem_req_o_t0;
wire mem_req_o_t1;
wire mem_req_o_t2;
wire mem_req_o_t3;

and2$ mem_req_o_and0 (mem_req_o_t0, S_1, S_2_inv);
and2$ mem_req_o_and1 (mem_req_o_t1, S_1_inv, S_2);
and3$ mem_req_o_and2 (mem_req_o_t2, S_0, S_1_inv, D_Swap_valid_i_inv);
and5$ mem_req_o_and3 (mem_req_o_t3, S_0_inv, S_1_inv, D_Miss_i, V_Miss_i, Line_valid_i_inv);
or4$  mem_req_o_or  (mem_req_o, mem_req_o_t0, mem_req_o_t1, mem_req_o_t2, mem_req_o_t3);

// busy_o = (!S_0 & S_1) | (S_0 & !S_1) | (!S_1 & S_2) | (S_0 & !S_2) | (!S_2 & D_Miss_i & V_Miss_i) | (!S_2 & D_Miss_i & Line_valid_i)
wire busy_o_t0;
wire busy_o_t1;
wire busy_o_t2;
wire busy_o_t3;
wire busy_o_t4;
wire busy_o_t5;

and2$ busy_o_and0 (busy_o_t0, S_0_inv, S_1);
and2$ busy_o_and1 (busy_o_t1, S_0, S_1_inv);
and2$ busy_o_and2 (busy_o_t2, S_1_inv, S_2);
and2$ busy_o_and3 (busy_o_t3, S_0, S_2_inv);
and3$ busy_o_and4 (busy_o_t4, S_2_inv, D_Miss_i, V_Miss_i);
and3$ busy_o_and5 (busy_o_t5, S_2_inv, D_Miss_i, Line_valid_i);
or6$  busy_o_or  (busy_o, busy_o_t0, busy_o_t1, busy_o_t2, busy_o_t3, busy_o_t4, busy_o_t5);

// ld_V_swap_o = (!S_0 & S_1 & S_2)
and3$ ld_V_swap_o_and (ld_V_swap_o, S_0_inv, S_1, S_2);

// invalidate_v_swap_o = (!S_0 & S_1 & S_2)
and3$ invalidate_v_swap_o_and (invalidate_v_swap_o, S_0_inv, S_1, S_2);

// MakeReq_o = (!S_0 & S_1 & !S_2 & !DTE_Mem_valid_i)
and4$ MakeReq_o_and (MakeReq_o, S_0_inv, S_1, S_2_inv, DTE_Mem_valid_i_inv);

// fill0_o = (!S_0 & S_1 & !S_2 & DTE_Mem_valid_i)
and4$ fill0_o_and (fill0_o, S_0_inv, S_1, S_2_inv, DTE_Mem_valid_i);

// fill1_o = (S_0 & S_1 & !S_2 & DTE_Mem_valid_i)
and4$ fill1_o_and (fill1_o, S_0, S_1, S_2_inv, DTE_Mem_valid_i);

// fill2_o = (!S_0 & !S_1 & S_2 & DTE_Mem_valid_i)
and4$ fill2_o_and (fill2_o, S_0_inv, S_1_inv, S_2, DTE_Mem_valid_i);

// fill3_o = (S_0 & !S_1 & S_2 & DTE_Mem_valid_i)
and4$ fill3_o_and (fill3_o, S_0, S_1_inv, S_2, DTE_Mem_valid_i);

endmodule
