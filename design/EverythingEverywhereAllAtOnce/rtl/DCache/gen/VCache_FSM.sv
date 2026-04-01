// ======================================================================
// FSM : VCache_FSM
// Tool: fsm2rtl.py  (auto-generated -- do not hand-edit)
// NOTE: ERROR state was synthesised automatically.
//       Any undefined transition lands here (all outputs = 0).
// ======================================================================
//
// State Enumeration  (3 bits, 6 states)
// --------------------------------------------------
//   IDLE                          000  (decimal 0)  // IDLE (reset state)
//   LD_VC_SWAP                    001  (decimal 1)
//   WAITEVICT                     010  (decimal 2)
//   WRITE_2_HIT_IDX               011  (decimal 3)
//   WRITE_2_LRU                   100  (decimal 4)
//   ERROR                         101  (decimal 5)  // ERROR (trap state), synthesised
//
// Truth Table (pre-expansion, original CSV rows)
// ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//         S_0         S_1         S_2     V_Hit_i  DC_will_evict_i  VC_needs_2_evict_i      EB_V_i        we_i  |        NS_0        NS_1        NS_2   WR_2_EB_o  CLR_D_SWAP_V_o  Read_DSWAP_o  Write_VSWAP_o  Update_LRU_o  saveSwapIDX_o  use_savedSwapIDX_o   blocked_o      busy_o   saveReq_o  useSavedReq_o   transition
// ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//           0           0           0           0           0           x           x           x  |           0           0           0           0           0           0           0           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           0           1           x           x           x           0  |           1           1           0           0           0           0           1           1           1           0           0           0           1           0   IDLE -> WRITE_2_HIT_IDX
//           0           0           0           1           x           x           x           1  |           1           0           0           0           0           0           0           1           1           0           0           0           1           0   IDLE -> LD_VC_SWAP
//           0           0           0           0           1           0           0           x  |           0           0           1           0           0           0           0           1           0           0           0           0           1           0   IDLE -> WRITE_2_LRU
//           0           0           0           0           1           1           0           x  |           0           0           1           1           0           0           0           1           0           0           0           0           1           0   IDLE -> WRITE_2_LRU
//           0           0           0           0           1           1           1           x  |           0           1           0           1           0           0           0           1           0           0           0           0           1           0   IDLE -> WAITEVICT
//           1           0           0           x           x           x           x           x  |           1           1           0           0           0           0           1           0           0           1           0           1           0           1   LD_VC_SWAP -> WRITE_2_HIT_IDX
//           1           1           0           x           x           x           x           x  |           0           0           0           0           1           1           0           0           0           1           0           1           0           1   WRITE_2_HIT_IDX -> IDLE
//           0           0           1           x           x           x           x           x  |           0           0           0           0           1           1           0           0           0           0           0           1           0           1   WRITE_2_LRU -> IDLE
//           0           1           0           x           x           x           1           x  |           0           1           0           1           0           0           0           0           0           0           1           1           0           1   WAITEVICT -> WAITEVICT
//           0           1           0           x           x           x           0           x  |           0           0           1           1           0           0           0           0           0           0           0           1           0           1   WAITEVICT -> WRITE_2_LRU
// ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//

module VCache_FSM (
    input  wire clk,
    input  wire rst,
    input  wire V_Hit_i,
    input  wire DC_will_evict_i,
    input  wire VC_needs_2_evict_i,
    input  wire EB_V_i,
    input  wire we_i,
    output wire S_0,  // current-state bit 0 (LSB)
    output wire S_1,  // current-state bit 1 (1)
    output wire S_2,  // current-state bit 2 (MSB)
    output wire WR_2_EB_o,
    output wire CLR_D_SWAP_V_o,
    output wire Read_DSWAP_o,
    output wire Write_VSWAP_o,
    output wire Update_LRU_o,
    output wire saveSwapIDX_o,
    output wire use_savedSwapIDX_o,
    output wire blocked_o,
    output wire busy_o,
    output wire saveReq_o,
    output wire useSavedReq_o
);

// Next-state wires  (NS_0=LSB ... NS_{N-1}=MSB)
wire NS_0;
wire NS_1;
wire NS_2;

// State encoding  (IDLE = 0, ERROR = highest, guaranteed by tool)
//   IDLE                         = 000  (decimal 0)  // IDLE (reset state)
//   LD_VC_SWAP                   = 001  (decimal 1)
//   WAITEVICT                    = 010  (decimal 2)
//   WRITE_2_HIT_IDX              = 011  (decimal 3)
//   WRITE_2_LRU                  = 100  (decimal 4)
//   ERROR                        = 101  (decimal 5)  // ERROR (trap state), synthesised

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
wire EB_V_i_inv;
wire S_0_inv;
wire S_1_inv;
wire S_2_inv;
wire VC_needs_2_evict_i_inv;
wire V_Hit_i_inv;
wire we_i_inv;

inv1$ inv_EB_V_i (EB_V_i_inv, EB_V_i);
inv1$ inv_S_0 (S_0_inv, S_0);
inv1$ inv_S_1 (S_1_inv, S_1);
inv1$ inv_S_2 (S_2_inv, S_2);
inv1$ inv_VC_needs_2_evict_i (VC_needs_2_evict_i_inv, VC_needs_2_evict_i);
inv1$ inv_V_Hit_i (V_Hit_i_inv, V_Hit_i);
inv1$ inv_we_i (we_i_inv, we_i);

// Next-state and output SOP logic

// NS_0 = (S_0 & !S_1) | (!S_1 & !S_2 & V_Hit_i) | (!S_1 & !S_2 & DC_will_evict_i & !VC_needs_2_evict_i & EB_V_i)
wire NS_0_t0;
wire NS_0_t1;
wire NS_0_t2;

and2$ NS_0_and0 (NS_0_t0, S_0, S_1_inv);
and3$ NS_0_and1 (NS_0_t1, S_1_inv, S_2_inv, V_Hit_i);
and5$ NS_0_and2 (NS_0_t2, S_1_inv, S_2_inv, DC_will_evict_i, VC_needs_2_evict_i_inv, EB_V_i);
or3$  NS_0_or  (NS_0, NS_0_t0, NS_0_t1, NS_0_t2);

// NS_1 = (S_0 & !S_1 & !S_2) | (!S_0 & S_1 & !S_2 & EB_V_i) | (!S_1 & !S_2 & V_Hit_i & !we_i) | (!S_0 & !S_2 & !V_Hit_i & DC_will_evict_i & VC_needs_2_evict_i & EB_V_i)
wire NS_1_t0;
wire NS_1_t1;
wire NS_1_t2;
wire NS_1_t3;

and3$ NS_1_and0 (NS_1_t0, S_0, S_1_inv, S_2_inv);
and4$ NS_1_and1 (NS_1_t1, S_0_inv, S_1, S_2_inv, EB_V_i);
and4$ NS_1_and2 (NS_1_t2, S_1_inv, S_2_inv, V_Hit_i, we_i_inv);
and6$ NS_1_and3 (NS_1_t3, S_0_inv, S_2_inv, V_Hit_i_inv, DC_will_evict_i, VC_needs_2_evict_i, EB_V_i);
or4$  NS_1_or  (NS_1, NS_1_t0, NS_1_t1, NS_1_t2, NS_1_t3);

// NS_2 = (S_0 & !S_1 & S_2) | (!S_0 & S_1 & !S_2 & !EB_V_i) | (!S_0 & !S_2 & !V_Hit_i & DC_will_evict_i & !EB_V_i) | (!S_0 & !S_1 & !S_2 & !V_Hit_i & DC_will_evict_i & !VC_needs_2_evict_i)
wire NS_2_t0;
wire NS_2_t1;
wire NS_2_t2;
wire NS_2_t3;

and3$ NS_2_and0 (NS_2_t0, S_0, S_1_inv, S_2);
and4$ NS_2_and1 (NS_2_t1, S_0_inv, S_1, S_2_inv, EB_V_i_inv);
and5$ NS_2_and2 (NS_2_t2, S_0_inv, S_2_inv, V_Hit_i_inv, DC_will_evict_i, EB_V_i_inv);
and6$ NS_2_and3 (NS_2_t3, S_0_inv, S_1_inv, S_2_inv, V_Hit_i_inv, DC_will_evict_i, VC_needs_2_evict_i_inv);
or4$  NS_2_or  (NS_2, NS_2_t0, NS_2_t1, NS_2_t2, NS_2_t3);

// WR_2_EB_o = (!S_0 & S_1 & !S_2) | (!S_0 & !S_2 & !V_Hit_i & DC_will_evict_i & VC_needs_2_evict_i)
wire WR_2_EB_o_t0;
wire WR_2_EB_o_t1;

and3$ WR_2_EB_o_and0 (WR_2_EB_o_t0, S_0_inv, S_1, S_2_inv);
and5$ WR_2_EB_o_and1 (WR_2_EB_o_t1, S_0_inv, S_2_inv, V_Hit_i_inv, DC_will_evict_i, VC_needs_2_evict_i);
or2$  WR_2_EB_o_or  (WR_2_EB_o, WR_2_EB_o_t0, WR_2_EB_o_t1);

// CLR_D_SWAP_V_o = (S_0 & S_1 & !S_2) | (!S_0 & !S_1 & S_2)
wire CLR_D_SWAP_V_o_t0;
wire CLR_D_SWAP_V_o_t1;

and3$ CLR_D_SWAP_V_o_and0 (CLR_D_SWAP_V_o_t0, S_0, S_1, S_2_inv);
and3$ CLR_D_SWAP_V_o_and1 (CLR_D_SWAP_V_o_t1, S_0_inv, S_1_inv, S_2);
or2$  CLR_D_SWAP_V_o_or  (CLR_D_SWAP_V_o, CLR_D_SWAP_V_o_t0, CLR_D_SWAP_V_o_t1);

// Read_DSWAP_o = (S_0 & S_1 & !S_2) | (!S_0 & !S_1 & S_2)
wire Read_DSWAP_o_t0;
wire Read_DSWAP_o_t1;

and3$ Read_DSWAP_o_and0 (Read_DSWAP_o_t0, S_0, S_1, S_2_inv);
and3$ Read_DSWAP_o_and1 (Read_DSWAP_o_t1, S_0_inv, S_1_inv, S_2);
or2$  Read_DSWAP_o_or  (Read_DSWAP_o, Read_DSWAP_o_t0, Read_DSWAP_o_t1);

// Write_VSWAP_o = (S_0 & !S_1 & !S_2) | (!S_1 & !S_2 & V_Hit_i & !we_i)
wire Write_VSWAP_o_t0;
wire Write_VSWAP_o_t1;

and3$ Write_VSWAP_o_and0 (Write_VSWAP_o_t0, S_0, S_1_inv, S_2_inv);
and4$ Write_VSWAP_o_and1 (Write_VSWAP_o_t1, S_1_inv, S_2_inv, V_Hit_i, we_i_inv);
or2$  Write_VSWAP_o_or  (Write_VSWAP_o, Write_VSWAP_o_t0, Write_VSWAP_o_t1);

// Update_LRU_o = (!S_0 & !S_1 & !S_2 & V_Hit_i) | (!S_0 & !S_1 & !S_2 & DC_will_evict_i & !EB_V_i) | (!S_0 & !S_1 & !S_2 & DC_will_evict_i & VC_needs_2_evict_i)
wire Update_LRU_o_t0;
wire Update_LRU_o_t1;
wire Update_LRU_o_t2;

and4$ Update_LRU_o_and0 (Update_LRU_o_t0, S_0_inv, S_1_inv, S_2_inv, V_Hit_i);
and5$ Update_LRU_o_and1 (Update_LRU_o_t1, S_0_inv, S_1_inv, S_2_inv, DC_will_evict_i, EB_V_i_inv);
and5$ Update_LRU_o_and2 (Update_LRU_o_t2, S_0_inv, S_1_inv, S_2_inv, DC_will_evict_i, VC_needs_2_evict_i);
or3$  Update_LRU_o_or  (Update_LRU_o, Update_LRU_o_t0, Update_LRU_o_t1, Update_LRU_o_t2);

// saveSwapIDX_o = (!S_0 & !S_1 & !S_2 & V_Hit_i)
and4$ saveSwapIDX_o_and (saveSwapIDX_o, S_0_inv, S_1_inv, S_2_inv, V_Hit_i);

// use_savedSwapIDX_o = (S_0 & !S_2)
and2$ use_savedSwapIDX_o_and (use_savedSwapIDX_o, S_0, S_2_inv);

// blocked_o = (!S_0 & S_1 & !S_2 & EB_V_i)
and4$ blocked_o_and (blocked_o, S_0_inv, S_1, S_2_inv, EB_V_i);

// busy_o = (S_1 & !S_2) | (S_0 & !S_2) | (!S_0 & !S_1 & S_2)
wire busy_o_t0;
wire busy_o_t1;
wire busy_o_t2;

and2$ busy_o_and0 (busy_o_t0, S_1, S_2_inv);
and2$ busy_o_and1 (busy_o_t1, S_0, S_2_inv);
and3$ busy_o_and2 (busy_o_t2, S_0_inv, S_1_inv, S_2);
or3$  busy_o_or  (busy_o, busy_o_t0, busy_o_t1, busy_o_t2);

// saveReq_o = (!S_0 & !S_1 & !S_2 & V_Hit_i) | (!S_0 & !S_1 & !S_2 & DC_will_evict_i & !EB_V_i) | (!S_0 & !S_1 & !S_2 & DC_will_evict_i & VC_needs_2_evict_i)
wire saveReq_o_t0;
wire saveReq_o_t1;
wire saveReq_o_t2;

and4$ saveReq_o_and0 (saveReq_o_t0, S_0_inv, S_1_inv, S_2_inv, V_Hit_i);
and5$ saveReq_o_and1 (saveReq_o_t1, S_0_inv, S_1_inv, S_2_inv, DC_will_evict_i, EB_V_i_inv);
and5$ saveReq_o_and2 (saveReq_o_t2, S_0_inv, S_1_inv, S_2_inv, DC_will_evict_i, VC_needs_2_evict_i);
or3$  saveReq_o_or  (saveReq_o, saveReq_o_t0, saveReq_o_t1, saveReq_o_t2);

// useSavedReq_o = (S_1 & !S_2) | (S_0 & !S_2) | (!S_0 & !S_1 & S_2)
wire useSavedReq_o_t0;
wire useSavedReq_o_t1;
wire useSavedReq_o_t2;

and2$ useSavedReq_o_and0 (useSavedReq_o_t0, S_1, S_2_inv);
and2$ useSavedReq_o_and1 (useSavedReq_o_t1, S_0, S_2_inv);
and3$ useSavedReq_o_and2 (useSavedReq_o_t2, S_0_inv, S_1_inv, S_2);
or3$  useSavedReq_o_or  (useSavedReq_o, useSavedReq_o_t0, useSavedReq_o_t1, useSavedReq_o_t2);

endmodule
