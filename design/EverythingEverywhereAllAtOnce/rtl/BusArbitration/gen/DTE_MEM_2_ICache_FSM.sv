// ======================================================================
// FSM : DTE_MEM_2_ICache_FSM
// Tool: fsm2rtl.py  (auto-generated -- do not hand-edit)
// NOTE: ERROR state was synthesised automatically.
//       Any undefined transition lands here (all outputs = 0).
// ======================================================================
//
// State Enumeration  (3 bits, 6 states)
// --------------------------------------------------
//   IDLE                          000  (decimal 0)  // IDLE (reset state)
//   LD0                           001  (decimal 1)
//   LD1                           010  (decimal 2)
//   LD2                           011  (decimal 3)
//   MEM_REQ                       100  (decimal 4)
//   ERROR                         101  (decimal 5)  // ERROR (trap state), synthesised
//
// Truth Table (pre-expansion, original CSV rows)
// -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//         S_0         S_1         S_2   req_hit_i  others_busy_i  mem_ready_i  |        NS_0        NS_1        NS_2      busy_o  mem_valid_o    ld_req_o  Drive_Addr_Bus_o  Drv_DB_0_o  Drv_DB_1_o  Drv_DB_2_o  Drv_DB_3_o   transition
// -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//           0           0           0           x           1           x  |           0           0           0           0           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           0           0           x           x  |           0           0           0           0           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           0           1           0           x  |           0           0           1           1           0           0           1           0           0           0           0   IDLE -> MEM_REQ
//           0           0           1           x           x           0  |           0           0           1           1           0           1           1           0           0           0           0   MEM_REQ -> MEM_REQ
//           0           0           1           x           x           1  |           1           0           0           1           1           0           1           1           0           0           0   MEM_REQ -> LD0
//           1           0           0           x           x           x  |           0           1           0           1           1           0           1           0           1           0           0   LD0 -> LD1
//           0           1           0           x           x           x  |           1           1           0           1           1           0           1           0           0           1           0   LD1 -> LD2
//           1           1           0           x           x           x  |           0           0           0           1           1           0           1           0           0           0           1   LD2 -> IDLE
// -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//

module DTE_MEM_2_ICache_FSM (
    input  wire clk,
    input  wire rst,
    input  wire req_hit_i,
    input  wire others_busy_i,
    input  wire mem_ready_i,
    output wire S_0,  // current-state bit 0 (LSB)
    output wire S_1,  // current-state bit 1 (1)
    output wire S_2,  // current-state bit 2 (MSB)
    output wire busy_o,
    output wire mem_valid_o,
    output wire ld_req_o,
    output wire Drive_Addr_Bus_o,
    output wire Drv_DB_0_o,
    output wire Drv_DB_1_o,
    output wire Drv_DB_2_o,
    output wire Drv_DB_3_o
);

// Next-state wires  (NS_0=LSB ... NS_{N-1}=MSB)
wire NS_0;
wire NS_1;
wire NS_2;

// State encoding  (IDLE = 0, ERROR = highest, guaranteed by tool)
//   IDLE                         = 000  (decimal 0)  // IDLE (reset state)
//   LD0                          = 001  (decimal 1)
//   LD1                          = 010  (decimal 2)
//   LD2                          = 011  (decimal 3)
//   MEM_REQ                      = 100  (decimal 4)
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
wire S_0_inv;
wire S_1_inv;
wire S_2_inv;
wire mem_ready_i_inv;
wire others_busy_i_inv;

inv1$ inv_S_0 (S_0_inv, S_0);
inv1$ inv_S_1 (S_1_inv, S_1);
inv1$ inv_S_2 (S_2_inv, S_2);
inv1$ inv_mem_ready_i (mem_ready_i_inv, mem_ready_i);
inv1$ inv_others_busy_i (others_busy_i_inv, others_busy_i);

// Next-state and output SOP logic

// NS_0 = (!S_0 & S_1 & !S_2) | (S_0 & !S_1 & S_2) | (!S_1 & S_2 & mem_ready_i)
wire NS_0_t0;
wire NS_0_t1;
wire NS_0_t2;

and3$ NS_0_and0 (NS_0_t0, S_0_inv, S_1, S_2_inv);
and3$ NS_0_and1 (NS_0_t1, S_0, S_1_inv, S_2);
and3$ NS_0_and2 (NS_0_t2, S_1_inv, S_2, mem_ready_i);
or3$  NS_0_or  (NS_0, NS_0_t0, NS_0_t1, NS_0_t2);

// NS_1 = (!S_0 & S_1 & !S_2) | (S_0 & !S_1 & !S_2)
wire NS_1_t0;
wire NS_1_t1;

and3$ NS_1_and0 (NS_1_t0, S_0_inv, S_1, S_2_inv);
and3$ NS_1_and1 (NS_1_t1, S_0, S_1_inv, S_2_inv);
or2$  NS_1_or  (NS_1, NS_1_t0, NS_1_t1);

// NS_2 = (!S_1 & S_2 & !mem_ready_i) | (S_0 & !S_1 & S_2) | (!S_0 & !S_1 & !S_2 & req_hit_i & !others_busy_i)
wire NS_2_t0;
wire NS_2_t1;
wire NS_2_t2;

and3$ NS_2_and0 (NS_2_t0, S_1_inv, S_2, mem_ready_i_inv);
and3$ NS_2_and1 (NS_2_t1, S_0, S_1_inv, S_2);
and5$ NS_2_and2 (NS_2_t2, S_0_inv, S_1_inv, S_2_inv, req_hit_i, others_busy_i_inv);
or3$  NS_2_or  (NS_2, NS_2_t0, NS_2_t1, NS_2_t2);

// busy_o = (S_0 & !S_2) | (S_1 & !S_2) | (!S_0 & !S_1 & S_2) | (!S_2 & req_hit_i & !others_busy_i)
wire busy_o_t0;
wire busy_o_t1;
wire busy_o_t2;
wire busy_o_t3;

and2$ busy_o_and0 (busy_o_t0, S_0, S_2_inv);
and2$ busy_o_and1 (busy_o_t1, S_1, S_2_inv);
and3$ busy_o_and2 (busy_o_t2, S_0_inv, S_1_inv, S_2);
and3$ busy_o_and3 (busy_o_t3, S_2_inv, req_hit_i, others_busy_i_inv);
or4$  busy_o_or  (busy_o, busy_o_t0, busy_o_t1, busy_o_t2, busy_o_t3);

// mem_valid_o = (S_1 & !S_2) | (S_0 & !S_2) | (!S_0 & !S_1 & S_2 & mem_ready_i)
wire mem_valid_o_t0;
wire mem_valid_o_t1;
wire mem_valid_o_t2;

and2$ mem_valid_o_and0 (mem_valid_o_t0, S_1, S_2_inv);
and2$ mem_valid_o_and1 (mem_valid_o_t1, S_0, S_2_inv);
and4$ mem_valid_o_and2 (mem_valid_o_t2, S_0_inv, S_1_inv, S_2, mem_ready_i);
or3$  mem_valid_o_or  (mem_valid_o, mem_valid_o_t0, mem_valid_o_t1, mem_valid_o_t2);

// ld_req_o = (!S_0 & !S_1 & S_2 & !mem_ready_i)
and4$ ld_req_o_and (ld_req_o, S_0_inv, S_1_inv, S_2, mem_ready_i_inv);

// Drive_Addr_Bus_o = (S_0 & !S_2) | (S_1 & !S_2) | (!S_0 & !S_1 & S_2) | (!S_2 & req_hit_i & !others_busy_i)
wire Drive_Addr_Bus_o_t0;
wire Drive_Addr_Bus_o_t1;
wire Drive_Addr_Bus_o_t2;
wire Drive_Addr_Bus_o_t3;

and2$ Drive_Addr_Bus_o_and0 (Drive_Addr_Bus_o_t0, S_0, S_2_inv);
and2$ Drive_Addr_Bus_o_and1 (Drive_Addr_Bus_o_t1, S_1, S_2_inv);
and3$ Drive_Addr_Bus_o_and2 (Drive_Addr_Bus_o_t2, S_0_inv, S_1_inv, S_2);
and3$ Drive_Addr_Bus_o_and3 (Drive_Addr_Bus_o_t3, S_2_inv, req_hit_i, others_busy_i_inv);
or4$  Drive_Addr_Bus_o_or  (Drive_Addr_Bus_o, Drive_Addr_Bus_o_t0, Drive_Addr_Bus_o_t1, Drive_Addr_Bus_o_t2, Drive_Addr_Bus_o_t3);

// Drv_DB_0_o = (!S_0 & !S_1 & S_2 & mem_ready_i)
and4$ Drv_DB_0_o_and (Drv_DB_0_o, S_0_inv, S_1_inv, S_2, mem_ready_i);

// Drv_DB_1_o = (S_0 & !S_1 & !S_2)
and3$ Drv_DB_1_o_and (Drv_DB_1_o, S_0, S_1_inv, S_2_inv);

// Drv_DB_2_o = (!S_0 & S_1 & !S_2)
and3$ Drv_DB_2_o_and (Drv_DB_2_o, S_0_inv, S_1, S_2_inv);

// Drv_DB_3_o = (S_0 & S_1 & !S_2)
and3$ Drv_DB_3_o_and (Drv_DB_3_o, S_0, S_1, S_2_inv);

endmodule
