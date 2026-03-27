// ======================================================================
// FSM : DTE_Core_2_DMA_FSM
// Tool: fsm2rtl.py  (auto-generated -- do not hand-edit)
// NOTE: ERROR state was synthesised automatically.
//       Any undefined transition lands here (all outputs = 0).
// ======================================================================
//
// State Enumeration  (2 bits, 3 states)
// --------------------------------------------------
//   IDLE                          00  (decimal 0)  // IDLE (reset state)
//   ST_DMA                        01  (decimal 1)
//   ERROR                         10  (decimal 2)  // ERROR (trap state), synthesised
//
// Truth Table (pre-expansion, original CSV rows)
// ----------------------------------------------------------------------------------------------------------------------------------------------------
//         S_0         S_1   req_hit_i  others_busy_i  |        NS_0        NS_1      busy_o  reqServed_o  Drive_Addr_Bus_o    Drv_DB_o  coreValOnBus_o   transition
// ----------------------------------------------------------------------------------------------------------------------------------------------------
//           0           0           x           1  |           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           0           x  |           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           1           0  |           1           0           1           0           1           0           0   IDLE -> ST_DMA
//           1           0           x           x  |           0           0           1           1           1           1           1   ST_DMA -> IDLE
// ----------------------------------------------------------------------------------------------------------------------------------------------------
//

module DTE_Core_2_DMA_FSM (
    input  wire clk,
    input  wire rst,
    input  wire req_hit_i,
    input  wire others_busy_i,
    output wire S_0,  // current-state bit 0 (LSB)
    output wire S_1,  // current-state bit 1 (MSB)
    output wire busy_o,
    output wire reqServed_o,
    output wire Drive_Addr_Bus_o,
    output wire Drv_DB_o,
    output wire coreValOnBus_o
);

// Next-state wires  (NS_0=LSB ... NS_{N-1}=MSB)
wire NS_0;
wire NS_1;

// State encoding  (IDLE = 0, ERROR = highest, guaranteed by tool)
//   IDLE                         = 00  (decimal 0)  // IDLE (reset state)
//   ST_DMA                       = 01  (decimal 1)
//   ERROR                        = 10  (decimal 2)  // ERROR (trap state), synthesised

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
wire S_0_inv;
wire S_1_inv;
wire others_busy_i_inv;

inv1$ inv_S_0 (S_0_inv, S_0);
inv1$ inv_S_1 (S_1_inv, S_1);
inv1$ inv_others_busy_i (others_busy_i_inv, others_busy_i);

// Next-state and output SOP logic

// NS_0 = (!S_0 & !S_1 & req_hit_i & !others_busy_i)
and4$ NS_0_and (NS_0, S_0_inv, S_1_inv, req_hit_i, others_busy_i_inv);

// NS_1 = (!S_0 & S_1)
and2$ NS_1_and (NS_1, S_0_inv, S_1);

// busy_o = (S_0 & !S_1) | (!S_1 & req_hit_i & !others_busy_i)
wire busy_o_t0;
wire busy_o_t1;

and2$ busy_o_and0 (busy_o_t0, S_0, S_1_inv);
and3$ busy_o_and1 (busy_o_t1, S_1_inv, req_hit_i, others_busy_i_inv);
or2$  busy_o_or  (busy_o, busy_o_t0, busy_o_t1);

// reqServed_o = (S_0 & !S_1)
and2$ reqServed_o_and (reqServed_o, S_0, S_1_inv);

// Drive_Addr_Bus_o = (S_0 & !S_1) | (!S_1 & req_hit_i & !others_busy_i)
wire Drive_Addr_Bus_o_t0;
wire Drive_Addr_Bus_o_t1;

and2$ Drive_Addr_Bus_o_and0 (Drive_Addr_Bus_o_t0, S_0, S_1_inv);
and3$ Drive_Addr_Bus_o_and1 (Drive_Addr_Bus_o_t1, S_1_inv, req_hit_i, others_busy_i_inv);
or2$  Drive_Addr_Bus_o_or  (Drive_Addr_Bus_o, Drive_Addr_Bus_o_t0, Drive_Addr_Bus_o_t1);

// Drv_DB_o = (S_0 & !S_1)
and2$ Drv_DB_o_and (Drv_DB_o, S_0, S_1_inv);

// coreValOnBus_o = (S_0 & !S_1)
and2$ coreValOnBus_o_and (coreValOnBus_o, S_0, S_1_inv);

endmodule
