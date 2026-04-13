// ======================================================================
// FSM : DTE_MEM_2_DCache_FSM
// Tool: fsm2rtl.py  (auto-generated -- do not hand-edit)
// Std : Verilog-2005 (IEEE 1364-2005)
// NOTE: ERROR state was synthesised automatically.
//       Any undefined transition lands here (all outputs = 0).
// ======================================================================
//
// State Enumeration  (3 bits, 7 states)
// --------------------------------------------------
//   IDLE                          000  (decimal 0)  // IDLE (reset state)
//   LD0                           001  (decimal 1)
//   LD1                           010  (decimal 2)
//   LD2                           011  (decimal 3)
//   LD3                           100  (decimal 4)
//   MEM_REQ                       101  (decimal 5)
//   ERROR                         110  (decimal 6)  // ERROR (trap state), synthesised
//
// Truth Table (pre-expansion, original CSV rows)
// -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//         S_0         S_1         S_2   req_hit_i  bank_hit_i  others_busy_i  mem_ready_i  |        NS_0        NS_1        NS_2      busy_o  mem_valid_o    ld_req_o  Drive_Addr_Bus_o  Drv_DB_0_o  Drv_DB_1_o  Drv_DB_2_o  Drv_DB_3_o   transition
// -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//           0           0           0           x           x           1           x  |           0           0           0           0           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           0           0           x           x           x  |           0           0           0           0           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           0           x           0           x           x  |           0           0           0           0           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           0           1           1           0           x  |           1           0           1           0           0           0           1           0           0           0           0   IDLE -> MEM_REQ
//           1           0           1           x           x           x           0  |           1           0           1           1           0           1           1           0           0           0           0   MEM_REQ -> MEM_REQ
//           1           0           1           x           x           x           1  |           1           0           0           1           0           1           1           0           0           0           0   MEM_REQ -> LD0
//           1           0           0           x           x           x           x  |           0           1           0           1           1           0           1           1           0           0           0   LD0 -> LD1
//           0           1           0           x           x           x           x  |           1           1           0           1           1           0           1           0           1           0           0   LD1 -> LD2
//           1           1           0           x           x           x           x  |           0           0           1           1           1           0           1           0           0           1           0   LD2 -> LD3
//           0           0           1           x           x           x           x  |           0           0           0           1           1           0           1           0           0           0           1   LD3 -> IDLE
// -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//

module DTE_MEM_2_DCache_FSM (
    input  wire clk,
    input  wire rst,
    input  wire req_hit_i,
    input  wire bank_hit_i,
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

// ----------------------------------------------------------------
// Next-state wires  (NS_0 = LSB ... NS_{N-1} = MSB)
// ----------------------------------------------------------------
wire NS_0;
wire NS_1;
wire NS_2;

// State encoding  (IDLE = 0, ERROR = highest, guaranteed by tool)
//   IDLE                         = 000  (decimal 0)  // IDLE (reset state)
//   LD0                          = 001  (decimal 1)
//   LD1                          = 010  (decimal 2)
//   LD2                          = 011  (decimal 3)
//   LD3                          = 100  (decimal 4)
//   MEM_REQ                      = 101  (decimal 5)
//   ERROR                        = 110  (decimal 6)  // ERROR (trap state), synthesised

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
wire mem_ready_i_inv;
wire others_busy_i_inv;

`INV_N(inv_S_0, 1, S_0, S_0_inv)
`INV_N(inv_S_1, 1, S_1, S_1_inv)
`INV_N(inv_S_2, 1, S_2, S_2_inv)
`INV_N(inv_mem_ready_i, 1, mem_ready_i, mem_ready_i_inv)
`INV_N(inv_others_busy_i, 1, others_busy_i, others_busy_i_inv)

// ----------------------------------------------------------------
// Next-state and output SOP logic
// ----------------------------------------------------------------

// NS_0 = (!S_0 & S_1 & !S_2) | (S_0 & !S_1 & S_2) | (!S_0 & !S_2 & req_hit_i & bank_hit_i & !others_busy_i)
wire NS_0_t0;
`AND_3(NS_0_and0, 1, NS_0_t0, S_0_inv, S_1, S_2_inv)
wire NS_0_t1;
`AND_3(NS_0_and1, 1, NS_0_t1, S_0, S_1_inv, S_2)
wire NS_0_t2;
`AND_5(NS_0_and2, 1, NS_0_t2, S_0_inv, S_2_inv, req_hit_i, bank_hit_i, others_busy_i_inv)

`OR_3(NS_0_or, 1, NS_0, NS_0_t0, NS_0_t1, NS_0_t2)

// NS_1 = (!S_0 & S_1) | (S_0 & !S_1 & !S_2)
wire NS_1_t0;
`AND_2(NS_1_and0, 1, NS_1_t0, S_0_inv, S_1)
wire NS_1_t1;
`AND_3(NS_1_and1, 1, NS_1_t1, S_0, S_1_inv, S_2_inv)

`OR_2(NS_1_or, 1, NS_1, NS_1_t0, NS_1_t1)

// NS_2 = (S_0 & S_1 & !S_2) | (!S_0 & S_1 & S_2) | (S_0 & !S_1 & S_2 & !mem_ready_i) | (!S_0 & !S_1 & !S_2 & req_hit_i & bank_hit_i & !others_busy_i)
wire NS_2_t0;
`AND_3(NS_2_and0, 1, NS_2_t0, S_0, S_1, S_2_inv)
wire NS_2_t1;
`AND_3(NS_2_and1, 1, NS_2_t1, S_0_inv, S_1, S_2)
wire NS_2_t2;
`AND_4(NS_2_and2, 1, NS_2_t2, S_0, S_1_inv, S_2, mem_ready_i_inv)
wire NS_2_t3;
`AND_6(NS_2_and3, 1, NS_2_t3, S_0_inv, S_1_inv, S_2_inv, req_hit_i, bank_hit_i, others_busy_i_inv)

`OR_4(NS_2_or, 1, NS_2, NS_2_t0, NS_2_t1, NS_2_t2, NS_2_t3)

// busy_o = (S_0 & !S_2) | (!S_1 & S_2) | (S_1 & !S_2)
wire busy_o_t0;
`AND_2(busy_o_and0, 1, busy_o_t0, S_0, S_2_inv)
wire busy_o_t1;
`AND_2(busy_o_and1, 1, busy_o_t1, S_1_inv, S_2)
wire busy_o_t2;
`AND_2(busy_o_and2, 1, busy_o_t2, S_1, S_2_inv)

`OR_3(busy_o_or, 1, busy_o, busy_o_t0, busy_o_t1, busy_o_t2)

// mem_valid_o = (S_0 & !S_2) | (S_1 & !S_2) | (!S_0 & !S_1 & S_2)
wire mem_valid_o_t0;
`AND_2(mem_valid_o_and0, 1, mem_valid_o_t0, S_0, S_2_inv)
wire mem_valid_o_t1;
`AND_2(mem_valid_o_and1, 1, mem_valid_o_t1, S_1, S_2_inv)
wire mem_valid_o_t2;
`AND_3(mem_valid_o_and2, 1, mem_valid_o_t2, S_0_inv, S_1_inv, S_2)

`OR_3(mem_valid_o_or, 1, mem_valid_o, mem_valid_o_t0, mem_valid_o_t1, mem_valid_o_t2)

// ld_req_o = (S_0 & !S_1 & S_2)
`AND_3(ld_req_o_and, 1, ld_req_o, S_0, S_1_inv, S_2)

// Drive_Addr_Bus_o = (S_0 & !S_1) | (S_1 & !S_2) | (!S_1 & S_2) | (!S_1 & req_hit_i & bank_hit_i & !others_busy_i)
wire Drive_Addr_Bus_o_t0;
`AND_2(Drive_Addr_Bus_o_and0, 1, Drive_Addr_Bus_o_t0, S_0, S_1_inv)
wire Drive_Addr_Bus_o_t1;
`AND_2(Drive_Addr_Bus_o_and1, 1, Drive_Addr_Bus_o_t1, S_1, S_2_inv)
wire Drive_Addr_Bus_o_t2;
`AND_2(Drive_Addr_Bus_o_and2, 1, Drive_Addr_Bus_o_t2, S_1_inv, S_2)
wire Drive_Addr_Bus_o_t3;
`AND_4(Drive_Addr_Bus_o_and3, 1, Drive_Addr_Bus_o_t3, S_1_inv, req_hit_i, bank_hit_i, others_busy_i_inv)

`OR_4(Drive_Addr_Bus_o_or, 1, Drive_Addr_Bus_o, Drive_Addr_Bus_o_t0, Drive_Addr_Bus_o_t1, Drive_Addr_Bus_o_t2, Drive_Addr_Bus_o_t3)

// Drv_DB_0_o = (S_0 & !S_1 & !S_2)
`AND_3(Drv_DB_0_o_and, 1, Drv_DB_0_o, S_0, S_1_inv, S_2_inv)

// Drv_DB_1_o = (!S_0 & S_1 & !S_2)
`AND_3(Drv_DB_1_o_and, 1, Drv_DB_1_o, S_0_inv, S_1, S_2_inv)

// Drv_DB_2_o = (S_0 & S_1 & !S_2)
`AND_3(Drv_DB_2_o_and, 1, Drv_DB_2_o, S_0, S_1, S_2_inv)

// Drv_DB_3_o = (!S_0 & !S_1 & S_2)
`AND_3(Drv_DB_3_o_and, 1, Drv_DB_3_o, S_0_inv, S_1_inv, S_2)

endmodule
