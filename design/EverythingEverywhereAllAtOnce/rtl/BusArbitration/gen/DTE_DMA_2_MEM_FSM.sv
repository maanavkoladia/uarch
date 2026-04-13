// ======================================================================
// FSM : DTE_DMA_2_MEM_FSM
// Tool: fsm2rtl.py  (auto-generated -- do not hand-edit)
// Std : Verilog-2005 (IEEE 1364-2005)
// NOTE: ERROR state was synthesised automatically.
//       Any undefined transition lands here (all outputs = 0).
// ======================================================================
//
// State Enumeration  (3 bits, 6 states)
// --------------------------------------------------
//   IDLE                          000  (decimal 0)  // IDLE (reset state)
//   ST0                           001  (decimal 1)
//   ST1                           010  (decimal 2)
//   ST2                           011  (decimal 3)
//   ST_REQ                        100  (decimal 4)
//   ERROR                         101  (decimal 5)  // ERROR (trap state), synthesised
//
// Truth Table (pre-expansion, original CSV rows)
// -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//         S_0         S_1         S_2   req_hit_i  others_busy_i  |        NS_0        NS_1        NS_2      busy_o    st_req_o  WriteComplete_o  Commiting_o  Drive_Addr_Bus_o  Drv_DB_0_o  Drv_DB_1_o  Drv_DB_2_o  Drv_DB_3_o   transition
// -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//           0           0           0           x           1  |           0           0           0           0           0           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           0           0           x  |           0           0           0           0           0           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           0           1           0  |           0           0           1           0           0           0           0           1           0           0           0           0   IDLE -> ST_REQ
//           0           0           1           x           x  |           1           0           0           1           1           0           1           1           1           0           0           0   ST_REQ -> ST0
//           1           0           0           x           x  |           0           1           0           1           0           0           0           1           0           1           0           0   ST0 -> ST1
//           0           1           0           x           x  |           1           1           0           1           0           0           0           1           0           0           1           0   ST1 -> ST2
//           1           1           0           x           x  |           0           0           0           1           0           1           0           1           0           0           0           1   ST2 -> IDLE
// -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//

module DTE_DMA_2_MEM_FSM (
    input  wire clk,
    input  wire rst,
    input  wire req_hit_i,
    input  wire others_busy_i,
    output wire S_0,  // current-state bit 0 (LSB)
    output wire S_1,  // current-state bit 1 (1)
    output wire S_2,  // current-state bit 2 (MSB)
    output wire busy_o,
    output wire st_req_o,
    output wire WriteComplete_o,
    output wire Commiting_o,
    output wire Drive_Addr_Bus_o,
    output wire Drv_DB_0_o,
    output wire Drv_DB_1_o,
    output wire Drv_DB_2_o,
    output wire Drv_DB_3_o
);

// ----------------------------------------------------------------
// Next-state wires  (NS_0 = LSB ... NS_{N-1} = MSB)
// ----------------------------------------------------------------
wire NS_0;
wire NS_1;
wire NS_2;

// State encoding  (IDLE = 0, ERROR = highest, guaranteed by tool)
//   IDLE                         = 000  (decimal 0)  // IDLE (reset state)
//   ST0                          = 001  (decimal 1)
//   ST1                          = 010  (decimal 2)
//   ST2                          = 011  (decimal 3)
//   ST_REQ                       = 100  (decimal 4)
//   ERROR                        = 101  (decimal 5)  // ERROR (trap state), synthesised

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
wire others_busy_i_inv;

`INV_N(inv_S_0, 1, S_0, S_0_inv)
`INV_N(inv_S_1, 1, S_1, S_1_inv)
`INV_N(inv_S_2, 1, S_2, S_2_inv)
`INV_N(inv_others_busy_i, 1, others_busy_i, others_busy_i_inv)

// ----------------------------------------------------------------
// Next-state and output SOP logic
// ----------------------------------------------------------------

// NS_0 = (!S_1 & S_2) | (!S_0 & S_1 & !S_2)
wire NS_0_t0;
`AND_2(NS_0_and0, 1, NS_0_t0, S_1_inv, S_2)
wire NS_0_t1;
`AND_3(NS_0_and1, 1, NS_0_t1, S_0_inv, S_1, S_2_inv)

`OR_2(NS_0_or, 1, NS_0, NS_0_t0, NS_0_t1)

// NS_1 = (!S_0 & S_1 & !S_2) | (S_0 & !S_1 & !S_2)
wire NS_1_t0;
`AND_3(NS_1_and0, 1, NS_1_t0, S_0_inv, S_1, S_2_inv)
wire NS_1_t1;
`AND_3(NS_1_and1, 1, NS_1_t1, S_0, S_1_inv, S_2_inv)

`OR_2(NS_1_or, 1, NS_1, NS_1_t0, NS_1_t1)

// NS_2 = (S_0 & !S_1 & S_2) | (!S_0 & !S_1 & !S_2 & req_hit_i & !others_busy_i)
wire NS_2_t0;
`AND_3(NS_2_and0, 1, NS_2_t0, S_0, S_1_inv, S_2)
wire NS_2_t1;
`AND_5(NS_2_and1, 1, NS_2_t1, S_0_inv, S_1_inv, S_2_inv, req_hit_i, others_busy_i_inv)

`OR_2(NS_2_or, 1, NS_2, NS_2_t0, NS_2_t1)

// busy_o = (S_1 & !S_2) | (S_0 & !S_2) | (!S_0 & !S_1 & S_2)
wire busy_o_t0;
`AND_2(busy_o_and0, 1, busy_o_t0, S_1, S_2_inv)
wire busy_o_t1;
`AND_2(busy_o_and1, 1, busy_o_t1, S_0, S_2_inv)
wire busy_o_t2;
`AND_3(busy_o_and2, 1, busy_o_t2, S_0_inv, S_1_inv, S_2)

`OR_3(busy_o_or, 1, busy_o, busy_o_t0, busy_o_t1, busy_o_t2)

// st_req_o = (!S_0 & !S_1 & S_2)
`AND_3(st_req_o_and, 1, st_req_o, S_0_inv, S_1_inv, S_2)

// WriteComplete_o = (S_0 & S_1 & !S_2)
`AND_3(WriteComplete_o_and, 1, WriteComplete_o, S_0, S_1, S_2_inv)

// Commiting_o = (!S_0 & !S_1 & S_2)
`AND_3(Commiting_o_and, 1, Commiting_o, S_0_inv, S_1_inv, S_2)

// Drive_Addr_Bus_o = (S_1 & !S_2) | (S_0 & !S_2) | (!S_0 & !S_1 & S_2) | (!S_2 & req_hit_i & !others_busy_i)
wire Drive_Addr_Bus_o_t0;
`AND_2(Drive_Addr_Bus_o_and0, 1, Drive_Addr_Bus_o_t0, S_1, S_2_inv)
wire Drive_Addr_Bus_o_t1;
`AND_2(Drive_Addr_Bus_o_and1, 1, Drive_Addr_Bus_o_t1, S_0, S_2_inv)
wire Drive_Addr_Bus_o_t2;
`AND_3(Drive_Addr_Bus_o_and2, 1, Drive_Addr_Bus_o_t2, S_0_inv, S_1_inv, S_2)
wire Drive_Addr_Bus_o_t3;
`AND_3(Drive_Addr_Bus_o_and3, 1, Drive_Addr_Bus_o_t3, S_2_inv, req_hit_i, others_busy_i_inv)

`OR_4(Drive_Addr_Bus_o_or, 1, Drive_Addr_Bus_o, Drive_Addr_Bus_o_t0, Drive_Addr_Bus_o_t1, Drive_Addr_Bus_o_t2, Drive_Addr_Bus_o_t3)

// Drv_DB_0_o = (!S_0 & !S_1 & S_2)
`AND_3(Drv_DB_0_o_and, 1, Drv_DB_0_o, S_0_inv, S_1_inv, S_2)

// Drv_DB_1_o = (S_0 & !S_1 & !S_2)
`AND_3(Drv_DB_1_o_and, 1, Drv_DB_1_o, S_0, S_1_inv, S_2_inv)

// Drv_DB_2_o = (!S_0 & S_1 & !S_2)
`AND_3(Drv_DB_2_o_and, 1, Drv_DB_2_o, S_0_inv, S_1, S_2_inv)

// Drv_DB_3_o = (S_0 & S_1 & !S_2)
`AND_3(Drv_DB_3_o_and, 1, Drv_DB_3_o, S_0, S_1, S_2_inv)

endmodule
