// ======================================================================
// FSM : DTE_DDR5_2_Core_FSM
// Tool: fsm2rtl.py  (auto-generated -- do not hand-edit)
// Std : Verilog-2005 (IEEE 1364-2005)
// NOTE: ERROR state was synthesised automatically.
//       Any undefined transition lands here (all outputs = 0).
// ======================================================================
//
// State Enumeration  (2 bits, 4 states)
// --------------------------------------------------
//   IDLE                          00  (decimal 0)  // IDLE (reset state)
//   DELAY                         01  (decimal 1)
//   LD_DDR5                       10  (decimal 2)
//   ERROR                         11  (decimal 3)  // ERROR (trap state), synthesised
//
// Truth Table (pre-expansion, original CSV rows)
// ------------------------------------------------------------------------------------------------------------------------------------
//         S_0         S_1   req_hit_i  others_busy_i  |        NS_0        NS_1      busy_o  reqServed_o  Drive_Addr_Bus_o    Drv_DB_o   transition
// ------------------------------------------------------------------------------------------------------------------------------------
//           0           0           x           1  |           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           0           x  |           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           1           0  |           0           1           0           0           1           0   IDLE -> LD_DDR5
//           0           1           x           x  |           1           0           1           1           1           1   LD_DDR5 -> DELAY
//           1           0           x           x  |           0           0           1           0           0           0   DELAY -> IDLE
// ------------------------------------------------------------------------------------------------------------------------------------
//

module DTE_DDR5_2_Core_FSM (
    input  wire clk,
    input  wire rst,
    input  wire req_hit_i,
    input  wire others_busy_i,
    output wire S_0,  // current-state bit 0 (LSB)
    output wire S_1,  // current-state bit 1 (MSB)
    output wire busy_o,
    output wire reqServed_o,
    output wire Drive_Addr_Bus_o,
    output wire Drv_DB_o
);

// ----------------------------------------------------------------
// Next-state wires  (NS_0 = LSB ... NS_{N-1} = MSB)
// ----------------------------------------------------------------
wire NS_0;
wire NS_1;

// State encoding  (IDLE = 0, ERROR = highest, guaranteed by tool)
//   IDLE                         = 00  (decimal 0)  // IDLE (reset state)
//   DELAY                        = 01  (decimal 1)
//   LD_DDR5                      = 10  (decimal 2)
//   ERROR                        = 11  (decimal 3)  // ERROR (trap state), synthesised

// ----------------------------------------------------------------
// State flip-flops
// `REG_RST samples D on every rising clk edge.
// Active-high rst drives all state bits to 0 (= IDLE encoding).
// ----------------------------------------------------------------
`REG_RST(ff_0, 1, clk, rst, NS_0, S_0)
`REG_RST(ff_1, 1, clk, rst, NS_1, S_1)

// ----------------------------------------------------------------
// Inverters for negated literals
// ----------------------------------------------------------------
wire S_0_inv;
wire S_1_inv;
wire others_busy_i_inv;

`INV_N(inv_S_0, 1, S_0, S_0_inv)
`INV_N(inv_S_1, 1, S_1, S_1_inv)
`INV_N(inv_others_busy_i, 1, others_busy_i, others_busy_i_inv)

// ----------------------------------------------------------------
// Next-state and output SOP logic
// ----------------------------------------------------------------

// NS_0 = S_1
wire NS_0_and_buf_mid;
`INV_N(NS_0_and_buf_i0, 1, S_1, NS_0_and_buf_mid)
`INV_N(NS_0_and_buf_i1, 1, NS_0_and_buf_mid, NS_0)

// NS_1 = (S_0 & S_1) | (!S_0 & !S_1 & req_hit_i & !others_busy_i)
wire NS_1_n0;
`NAND_2(NS_1_nand0, 1, NS_1_n0, S_0, S_1)
wire NS_1_n1;
`NAND_4(NS_1_nand1, 1, NS_1_n1, S_0_inv, S_1_inv, req_hit_i, others_busy_i_inv)

`NAND_2(NS_1_nand, 1, NS_1, NS_1_n0, NS_1_n1)

// busy_o = (S_0 & !S_1) | (!S_0 & S_1)
wire busy_o_n0;
`NAND_2(busy_o_nand0, 1, busy_o_n0, S_0, S_1_inv)
wire busy_o_n1;
`NAND_2(busy_o_nand1, 1, busy_o_n1, S_0_inv, S_1)

`NAND_2(busy_o_nand, 1, busy_o, busy_o_n0, busy_o_n1)

// reqServed_o = (!S_0 & S_1)
`AND_2(reqServed_o_and, 1, reqServed_o, S_0_inv, S_1)

// Drive_Addr_Bus_o = (!S_0 & S_1) | (!S_0 & req_hit_i & !others_busy_i)
wire Drive_Addr_Bus_o_n0;
`NAND_2(Drive_Addr_Bus_o_nand0, 1, Drive_Addr_Bus_o_n0, S_0_inv, S_1)
wire Drive_Addr_Bus_o_n1;
`NAND_3(Drive_Addr_Bus_o_nand1, 1, Drive_Addr_Bus_o_n1, S_0_inv, req_hit_i, others_busy_i_inv)

`NAND_2(Drive_Addr_Bus_o_nand, 1, Drive_Addr_Bus_o, Drive_Addr_Bus_o_n0, Drive_Addr_Bus_o_n1)

// Drv_DB_o = (!S_0 & S_1)
`AND_2(Drv_DB_o_and, 1, Drv_DB_o, S_0_inv, S_1)

endmodule
