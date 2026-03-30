// ======================================================================
// FSM : VCache_FSM
// Tool: fsm2rtl.py  (auto-generated -- do not hand-edit)
// NOTE: ERROR state was synthesised automatically.
//       Any undefined transition lands here (all outputs = 0).
// ======================================================================
//
// State Enumeration  (2 bits, 4 states)
// --------------------------------------------------
//   IDLE                          00  (decimal 0)  // IDLE (reset state)
//   RD_DSWAP                      01  (decimal 1)
//   WAITEVICT                     10  (decimal 2)
//   ERROR                         11  (decimal 3)  // ERROR (trap state), synthesised
//
// Truth Table (pre-expansion, original CSV rows)
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//         S_0         S_1     V_Hit_i  DC_will_evict_i  VC_needs_2_evict_i      EB_V_i  |        NS_0        NS_1     LD_EB_o  CLR_D_SWAP_V_o  Read_DSWAP_o  Write_VSWAP_o      busy_o   blocked_o   transition
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//           0           0           0           0           x           x  |           0           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           1           x           x           x  |           1           0           0           0           0           1           1           0   IDLE -> RD_DSWAP
//           0           0           0           1           0           0  |           1           0           0           0           0           0           1           0   IDLE -> RD_DSWAP
//           0           0           0           1           1           0  |           1           0           1           0           0           0           1           0   IDLE -> RD_DSWAP
//           0           0           0           1           1           1  |           0           1           1           0           0           0           1           1   IDLE -> WAITEVICT
//           1           0           x           x           x           x  |           0           0           0           1           1           0           1           0   RD_DSWAP -> IDLE
//           0           1           x           x           x           1  |           0           1           0           0           0           0           1           1   WAITEVICT -> WAITEVICT
//           0           1           x           x           x           0  |           1           0           1           0           0           0           1           0   WAITEVICT -> RD_DSWAP
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//

module VCache_FSM (
    input  wire clk,
    input  wire rst,
    input  wire V_Hit_i,
    input  wire DC_will_evict_i,
    input  wire VC_needs_2_evict_i,
    input  wire EB_V_i,
    output wire S_0,  // current-state bit 0 (LSB)
    output wire S_1,  // current-state bit 1 (MSB)
    output wire LD_EB_o,
    output wire CLR_D_SWAP_V_o,
    output wire Read_DSWAP_o,
    output wire Write_VSWAP_o,
    output wire busy_o,
    output wire blocked_o
);

// Next-state wires  (NS_0=LSB ... NS_{N-1}=MSB)
wire NS_0;
wire NS_1;

// State encoding  (IDLE = 0, ERROR = highest, guaranteed by tool)
//   IDLE                         = 00  (decimal 0)  // IDLE (reset state)
//   RD_DSWAP                     = 01  (decimal 1)
//   WAITEVICT                    = 10  (decimal 2)
//   ERROR                        = 11  (decimal 3)  // ERROR (trap state), synthesised

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

// Inverters
wire EB_V_i_inv;
wire S_0_inv;
wire S_1_inv;
wire VC_needs_2_evict_i_inv;
wire V_Hit_i_inv;

inv1$ inv_EB_V_i (EB_V_i_inv, EB_V_i);
inv1$ inv_S_0 (S_0_inv, S_0);
inv1$ inv_S_1 (S_1_inv, S_1);
inv1$ inv_VC_needs_2_evict_i (VC_needs_2_evict_i_inv, VC_needs_2_evict_i);
inv1$ inv_V_Hit_i (V_Hit_i_inv, V_Hit_i);

// Next-state and output SOP logic

// NS_0 = (S_1 & !EB_V_i) | (S_0 & S_1) | (!S_0 & !S_1 & V_Hit_i) | (!S_0 & DC_will_evict_i & !EB_V_i) | (!S_0 & !S_1 & DC_will_evict_i & !VC_needs_2_evict_i)
wire NS_0_t0;
wire NS_0_t1;
wire NS_0_t2;
wire NS_0_t3;
wire NS_0_t4;

and2$ NS_0_and0 (NS_0_t0, S_1, EB_V_i_inv);
and2$ NS_0_and1 (NS_0_t1, S_0, S_1);
and3$ NS_0_and2 (NS_0_t2, S_0_inv, S_1_inv, V_Hit_i);
and3$ NS_0_and3 (NS_0_t3, S_0_inv, DC_will_evict_i, EB_V_i_inv);
and4$ NS_0_and4 (NS_0_t4, S_0_inv, S_1_inv, DC_will_evict_i, VC_needs_2_evict_i_inv);
or5$  NS_0_or  (NS_0, NS_0_t0, NS_0_t1, NS_0_t2, NS_0_t3, NS_0_t4);

// NS_1 = (S_1 & EB_V_i) | (S_0 & S_1) | (!S_0 & !V_Hit_i & DC_will_evict_i & EB_V_i)
wire NS_1_t0;
wire NS_1_t1;
wire NS_1_t2;

and2$ NS_1_and0 (NS_1_t0, S_1, EB_V_i);
and2$ NS_1_and1 (NS_1_t1, S_0, S_1);
and4$ NS_1_and2 (NS_1_t2, S_0_inv, V_Hit_i_inv, DC_will_evict_i, EB_V_i);
or3$  NS_1_or  (NS_1, NS_1_t0, NS_1_t1, NS_1_t2);

// LD_EB_o = (!S_0 & S_1 & !EB_V_i) | (!S_0 & !S_1 & !V_Hit_i & DC_will_evict_i & VC_needs_2_evict_i)
wire LD_EB_o_t0;
wire LD_EB_o_t1;

and3$ LD_EB_o_and0 (LD_EB_o_t0, S_0_inv, S_1, EB_V_i_inv);
and5$ LD_EB_o_and1 (LD_EB_o_t1, S_0_inv, S_1_inv, V_Hit_i_inv, DC_will_evict_i, VC_needs_2_evict_i);
or2$  LD_EB_o_or  (LD_EB_o, LD_EB_o_t0, LD_EB_o_t1);

// CLR_D_SWAP_V_o = (S_0 & !S_1)
and2$ CLR_D_SWAP_V_o_and (CLR_D_SWAP_V_o, S_0, S_1_inv);

// Read_DSWAP_o = (S_0 & !S_1)
and2$ Read_DSWAP_o_and (Read_DSWAP_o, S_0, S_1_inv);

// Write_VSWAP_o = (!S_0 & !S_1 & V_Hit_i)
and3$ Write_VSWAP_o_and (Write_VSWAP_o, S_0_inv, S_1_inv, V_Hit_i);

// busy_o = (S_0 & !S_1) | (!S_0 & S_1) | (!S_0 & V_Hit_i) | (!S_0 & DC_will_evict_i & !EB_V_i) | (!S_0 & DC_will_evict_i & VC_needs_2_evict_i)
wire busy_o_t0;
wire busy_o_t1;
wire busy_o_t2;
wire busy_o_t3;
wire busy_o_t4;

and2$ busy_o_and0 (busy_o_t0, S_0, S_1_inv);
and2$ busy_o_and1 (busy_o_t1, S_0_inv, S_1);
and2$ busy_o_and2 (busy_o_t2, S_0_inv, V_Hit_i);
and3$ busy_o_and3 (busy_o_t3, S_0_inv, DC_will_evict_i, EB_V_i_inv);
and3$ busy_o_and4 (busy_o_t4, S_0_inv, DC_will_evict_i, VC_needs_2_evict_i);
or5$  busy_o_or  (busy_o, busy_o_t0, busy_o_t1, busy_o_t2, busy_o_t3, busy_o_t4);

// blocked_o = (!S_0 & S_1 & EB_V_i) | (!S_0 & !V_Hit_i & DC_will_evict_i & VC_needs_2_evict_i & EB_V_i)
wire blocked_o_t0;
wire blocked_o_t1;

and3$ blocked_o_and0 (blocked_o_t0, S_0_inv, S_1, EB_V_i);
and5$ blocked_o_and1 (blocked_o_t1, S_0_inv, V_Hit_i_inv, DC_will_evict_i, VC_needs_2_evict_i, EB_V_i);
or2$  blocked_o_or  (blocked_o, blocked_o_t0, blocked_o_t1);

endmodule
