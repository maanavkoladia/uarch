// ======================================================================
// FSM : VCache_FSM
// Tool: fsm2rtl.py  (auto-generated -- do not hand-edit)
// NOTE: ERROR state was synthesised automatically.
//       Any undefined transition lands here (all outputs = 0).
// ======================================================================
//
// State Enumeration  (3 bits, 5 states)
// --------------------------------------------------
//   IDLE                          000  (decimal 0)  // IDLE (reset state)
//   EVICT                         001  (decimal 1)
//   SWAP                          010  (decimal 2)
//   WAITEVICT                     011  (decimal 3)
//   ERROR                         100  (decimal 4)  // ERROR (trap state), synthesised
//
// Truth Table (pre-expansion, original CSV rows)
// ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//         S_0         S_1         S_2     V_Hit_i      EB_V_i      EB_C_i  D$_will_evict_i  |        NS_0        NS_1        NS_2  Set_EB_W_o  Set_EB_V_o     LD_EB_o  CLR_D_SWAP_V_o  Read_DSWAP_o  Write_VSWAP_o   transition
// ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//           0           0           0           1           x           x           x  |           0           1           0           0           0           0           0           0           1   IDLE -> SWAP
//           0           0           0           0           0           x           1  |           1           0           0           1           1           1           0           0           0   IDLE -> EVICT
//           0           0           0           0           1           0           1  |           1           0           0           1           1           1           0           0           0   IDLE -> EVICT
//           0           0           0           0           1           1           1  |           1           1           0           1           1           1           0           0           0   IDLE -> WAITEVICT
//           0           1           0           x           x           x           x  |           0           0           0           0           0           0           1           1           0   SWAP -> IDLE
//           1           0           0           x           0           x           x  |           0           0           0           0           0           0           1           1           0   EVICT -> IDLE
//           1           1           0           x           x           1           x  |           1           1           0           0           0           0           0           0           0   WAITEVICT -> WAITEVICT
//           1           1           0           x           x           0           x  |           1           0           0           0           0           0           1           1           0   WAITEVICT -> EVICT
// ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//

module VCache_FSM (
    input  wire clk,
    input  wire rst,
    input  wire V_Hit_i,
    input  wire EB_V_i,
    input  wire EB_C_i,
    input  wire D$_will_evict_i,
    output wire S_0,  // current-state bit 0 (LSB)
    output wire S_1,  // current-state bit 1 (1)
    output wire S_2,  // current-state bit 2 (MSB)
    output wire Set_EB_W_o,
    output wire Set_EB_V_o,
    output wire LD_EB_o,
    output wire CLR_D_SWAP_V_o,
    output wire Read_DSWAP_o,
    output wire Write_VSWAP_o
);

// Next-state wires  (NS_0=LSB ... NS_{N-1}=MSB)
wire NS_0;
wire NS_1;
wire NS_2;

// State encoding  (IDLE = 0, ERROR = highest, guaranteed by tool)
//   IDLE                         = 000  (decimal 0)  // IDLE (reset state)
//   EVICT                        = 001  (decimal 1)
//   SWAP                         = 010  (decimal 2)
//   WAITEVICT                    = 011  (decimal 3)
//   ERROR                        = 100  (decimal 4)  // ERROR (trap state), synthesised

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
wire D$_will_evict_i_inv;
wire EB_C_i_inv;
wire EB_V_i_inv;
wire S_0_inv;
wire S_1_inv;
wire S_2_inv;
wire V_Hit_i_inv;

inv1$ inv_D$_will_evict_i (D$_will_evict_i_inv, D$_will_evict_i);
inv1$ inv_EB_C_i (EB_C_i_inv, EB_C_i);
inv1$ inv_EB_V_i (EB_V_i_inv, EB_V_i);
inv1$ inv_S_0 (S_0_inv, S_0);
inv1$ inv_S_1 (S_1_inv, S_1);
inv1$ inv_S_2 (S_2_inv, S_2);
inv1$ inv_V_Hit_i (V_Hit_i_inv, V_Hit_i);

// Next-state and output SOP logic

// NS_0 = (S_0 & S_1 & !S_2) | (!S_0 & !S_1 & !S_2 & !V_Hit_i & D$_will_evict_i)
wire NS_0_t0;
wire NS_0_t1;

and3$ NS_0_and0 (NS_0_t0, S_0, S_1, S_2_inv);
and5$ NS_0_and1 (NS_0_t1, S_0_inv, S_1_inv, S_2_inv, V_Hit_i_inv, D$_will_evict_i);
or2$  NS_0_or  (NS_0, NS_0_t0, NS_0_t1);

// NS_1 = (!S_0 & !S_1 & !S_2 & V_Hit_i) | (S_0 & S_1 & !S_2 & EB_C_i) | (!S_0 & !S_1 & !S_2 & EB_V_i & EB_C_i & D$_will_evict_i)
wire NS_1_t0;
wire NS_1_t1;
wire NS_1_t2;

and4$ NS_1_and0 (NS_1_t0, S_0_inv, S_1_inv, S_2_inv, V_Hit_i);
and4$ NS_1_and1 (NS_1_t1, S_0, S_1, S_2_inv, EB_C_i);
and6$ NS_1_and2 (NS_1_t2, S_0_inv, S_1_inv, S_2_inv, EB_V_i, EB_C_i, D$_will_evict_i);
or3$  NS_1_or  (NS_1, NS_1_t0, NS_1_t1, NS_1_t2);

// NS_2 = (!S_0 & !S_1 & S_2) | (S_0 & !S_1 & !S_2 & EB_V_i) | (!S_0 & !S_1 & !V_Hit_i & !D$_will_evict_i)
wire NS_2_t0;
wire NS_2_t1;
wire NS_2_t2;

and3$ NS_2_and0 (NS_2_t0, S_0_inv, S_1_inv, S_2);
and4$ NS_2_and1 (NS_2_t1, S_0, S_1_inv, S_2_inv, EB_V_i);
and4$ NS_2_and2 (NS_2_t2, S_0_inv, S_1_inv, V_Hit_i_inv, D$_will_evict_i_inv);
or3$  NS_2_or  (NS_2, NS_2_t0, NS_2_t1, NS_2_t2);

// Set_EB_W_o = (!S_0 & !S_1 & !S_2 & !V_Hit_i & D$_will_evict_i)
and5$ Set_EB_W_o_and (Set_EB_W_o, S_0_inv, S_1_inv, S_2_inv, V_Hit_i_inv, D$_will_evict_i);

// Set_EB_V_o = (!S_0 & !S_1 & !S_2 & !V_Hit_i & D$_will_evict_i)
and5$ Set_EB_V_o_and (Set_EB_V_o, S_0_inv, S_1_inv, S_2_inv, V_Hit_i_inv, D$_will_evict_i);

// LD_EB_o = (!S_0 & !S_1 & !S_2 & !V_Hit_i & D$_will_evict_i)
and5$ LD_EB_o_and (LD_EB_o, S_0_inv, S_1_inv, S_2_inv, V_Hit_i_inv, D$_will_evict_i);

// CLR_D_SWAP_V_o = (!S_0 & S_1 & !S_2) | (S_1 & !S_2 & !EB_C_i) | (S_0 & !S_1 & !S_2 & !EB_V_i)
wire CLR_D_SWAP_V_o_t0;
wire CLR_D_SWAP_V_o_t1;
wire CLR_D_SWAP_V_o_t2;

and3$ CLR_D_SWAP_V_o_and0 (CLR_D_SWAP_V_o_t0, S_0_inv, S_1, S_2_inv);
and3$ CLR_D_SWAP_V_o_and1 (CLR_D_SWAP_V_o_t1, S_1, S_2_inv, EB_C_i_inv);
and4$ CLR_D_SWAP_V_o_and2 (CLR_D_SWAP_V_o_t2, S_0, S_1_inv, S_2_inv, EB_V_i_inv);
or3$  CLR_D_SWAP_V_o_or  (CLR_D_SWAP_V_o, CLR_D_SWAP_V_o_t0, CLR_D_SWAP_V_o_t1, CLR_D_SWAP_V_o_t2);

// Read_DSWAP_o = (!S_0 & S_1 & !S_2) | (S_1 & !S_2 & !EB_C_i) | (S_0 & !S_1 & !S_2 & !EB_V_i)
wire Read_DSWAP_o_t0;
wire Read_DSWAP_o_t1;
wire Read_DSWAP_o_t2;

and3$ Read_DSWAP_o_and0 (Read_DSWAP_o_t0, S_0_inv, S_1, S_2_inv);
and3$ Read_DSWAP_o_and1 (Read_DSWAP_o_t1, S_1, S_2_inv, EB_C_i_inv);
and4$ Read_DSWAP_o_and2 (Read_DSWAP_o_t2, S_0, S_1_inv, S_2_inv, EB_V_i_inv);
or3$  Read_DSWAP_o_or  (Read_DSWAP_o, Read_DSWAP_o_t0, Read_DSWAP_o_t1, Read_DSWAP_o_t2);

// Write_VSWAP_o = (!S_0 & !S_1 & !S_2 & V_Hit_i)
and4$ Write_VSWAP_o_and (Write_VSWAP_o, S_0_inv, S_1_inv, S_2_inv, V_Hit_i);

endmodule
