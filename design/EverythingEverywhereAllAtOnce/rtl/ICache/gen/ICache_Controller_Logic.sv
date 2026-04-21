// ======================================================================
// FSM : ICache_Controller_Logic
// Tool: fsm2rtl.py  (auto-generated -- do not hand-edit)
// Std : Verilog-2005 (IEEE 1364-2005)
// NOTE: ERROR state was synthesised automatically.
//       Any undefined transition lands here (all outputs = 0).
// ======================================================================
//
// State Enumeration  (3 bits, 7 states)
// --------------------------------------------------
//   IDLE                          000  (decimal 0)  // IDLE (reset state)
//   Fill0                         001  (decimal 1)
//   Fill1                         010  (decimal 2)
//   Fill2                         011  (decimal 3)
//   Fill3                         100  (decimal 4)
//   SWAP                          101  (decimal 5)
//   ERROR                         110  (decimal 6)  // ERROR (trap state), synthesised
//
// Truth Table (pre-expansion, original CSV rows)
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//         S_0         S_1         S_2   IC_miss_i  I_VC_Miss_i  mem_valid_i        en_i  |        NS_0        NS_1        NS_2  LD_IC_SWAP_BUF_o  RD_I_VC_SWAP_BUF_o      busy_o   MakeReq_o   Fill0EN_o   Fill1EN_o   Fill2EN_o   Fill3EN_o   transition
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//           0           0           0           x           x           x           0  |           0           0           0           0           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           0           0           x           x           1  |           0           0           0           0           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           0           1           1           x           1  |           1           0           0           1           0           0           0           0           0           0           0   IDLE -> Fill0
//           0           0           0           1           0           x           1  |           1           0           1           1           0           0           0           0           0           0           0   IDLE -> SWAP
//           1           0           1           x           x           x           x  |           0           0           0           0           1           1           0           0           0           0           0   SWAP -> IDLE
//           1           0           0           x           x           0           x  |           1           0           0           0           0           1           1           0           0           0           0   Fill0 -> Fill0
//           1           0           0           x           x           1           x  |           0           1           0           0           0           1           0           1           0           0           0   Fill0 -> Fill1
//           0           1           0           x           x           0           x  |           0           1           0           0           0           1           0           0           0           0           0   Fill1 -> Fill1
//           0           1           0           x           x           1           x  |           1           1           0           0           0           1           0           0           1           0           0   Fill1 -> Fill2
//           1           1           0           x           x           0           x  |           1           1           0           0           0           1           0           0           0           0           0   Fill2 -> Fill2
//           1           1           0           x           x           1           x  |           0           0           1           0           0           1           0           0           0           1           0   Fill2 -> Fill3
//           0           0           1           x           x           0           x  |           0           0           1           0           0           1           0           0           0           0           0   Fill3 -> Fill3
//           0           0           1           x           x           1           x  |           0           0           0           0           0           1           0           0           0           0           1   Fill3 -> IDLE
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//

module ICache_Controller_Logic (
    input  wire clk,
    input  wire rst,
    input  wire IC_miss_i,
    input  wire I_VC_Miss_i,
    input  wire mem_valid_i,
    input  wire en_i,
    output wire S_0,  // current-state bit 0 (LSB)
    output wire S_1,  // current-state bit 1 (1)
    output wire S_2,  // current-state bit 2 (MSB)
    output wire LD_IC_SWAP_BUF_o,
    output wire RD_I_VC_SWAP_BUF_o,
    output wire busy_o,
    output wire MakeReq_o,
    output wire Fill0EN_o,
    output wire Fill1EN_o,
    output wire Fill2EN_o,
    output wire Fill3EN_o
);

// ----------------------------------------------------------------
// Next-state wires  (NS_0 = LSB ... NS_{N-1} = MSB)
// ----------------------------------------------------------------
wire NS_0;
wire NS_1;
wire NS_2;

// State encoding  (IDLE = 0, ERROR = highest, guaranteed by tool)
//   IDLE                         = 000  (decimal 0)  // IDLE (reset state)
//   Fill0                        = 001  (decimal 1)
//   Fill1                        = 010  (decimal 2)
//   Fill2                        = 011  (decimal 3)
//   Fill3                        = 100  (decimal 4)
//   SWAP                         = 101  (decimal 5)
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
wire I_VC_Miss_i_inv;
wire S_0_inv;
wire S_1_inv;
wire S_2_inv;
wire mem_valid_i_inv;

`INV_N(inv_I_VC_Miss_i, 1, I_VC_Miss_i, I_VC_Miss_i_inv)
`INV_N(inv_S_0, 1, S_0, S_0_inv)
`INV_N(inv_S_1, 1, S_1, S_1_inv)
`INV_N(inv_S_2, 1, S_2, S_2_inv)
`INV_N(inv_mem_valid_i, 1, mem_valid_i, mem_valid_i_inv)

// ----------------------------------------------------------------
// Next-state and output SOP logic
// ----------------------------------------------------------------

// NS_0 = (S_0 & !S_2 & !mem_valid_i) | (!S_0 & S_1 & !S_2 & mem_valid_i) | (!S_0 & !S_1 & !S_2 & IC_miss_i & en_i)
wire NS_0_t0;
`AND_3(NS_0_and0, 1, NS_0_t0, S_0, S_2_inv, mem_valid_i_inv)
wire NS_0_t1;
`AND_4(NS_0_and1, 1, NS_0_t1, S_0_inv, S_1, S_2_inv, mem_valid_i)
wire NS_0_t2;
`AND_5(NS_0_and2, 1, NS_0_t2, S_0_inv, S_1_inv, S_2_inv, IC_miss_i, en_i)

`OR_3(NS_0_or, 1, NS_0, NS_0_t0, NS_0_t1, NS_0_t2)

// NS_1 = (!S_0 & S_1) | (S_1 & !S_2 & !mem_valid_i) | (S_0 & !S_1 & !S_2 & mem_valid_i)
wire NS_1_t0;
`AND_2(NS_1_and0, 1, NS_1_t0, S_0_inv, S_1)
wire NS_1_t1;
`AND_3(NS_1_and1, 1, NS_1_t1, S_1, S_2_inv, mem_valid_i_inv)
wire NS_1_t2;
`AND_4(NS_1_and2, 1, NS_1_t2, S_0, S_1_inv, S_2_inv, mem_valid_i)

`OR_3(NS_1_or, 1, NS_1, NS_1_t0, NS_1_t1, NS_1_t2)

// NS_2 = (!S_0 & S_1 & S_2) | (!S_0 & S_2 & !mem_valid_i) | (S_0 & S_1 & !S_2 & mem_valid_i) | (!S_0 & !S_1 & !S_2 & IC_miss_i & !I_VC_Miss_i & en_i)
wire NS_2_t0;
`AND_3(NS_2_and0, 1, NS_2_t0, S_0_inv, S_1, S_2)
wire NS_2_t1;
`AND_3(NS_2_and1, 1, NS_2_t1, S_0_inv, S_2, mem_valid_i_inv)
wire NS_2_t2;
`AND_4(NS_2_and2, 1, NS_2_t2, S_0, S_1, S_2_inv, mem_valid_i)
wire NS_2_t3;
`AND_6(NS_2_and3, 1, NS_2_t3, S_0_inv, S_1_inv, S_2_inv, IC_miss_i, I_VC_Miss_i_inv, en_i)

`OR_4(NS_2_or, 1, NS_2, NS_2_t0, NS_2_t1, NS_2_t2, NS_2_t3)

// LD_IC_SWAP_BUF_o = (!S_0 & !S_1 & !S_2 & IC_miss_i & en_i)
`AND_5(LD_IC_SWAP_BUF_o_and, 1, LD_IC_SWAP_BUF_o, S_0_inv, S_1_inv, S_2_inv, IC_miss_i, en_i)

// RD_I_VC_SWAP_BUF_o = (S_0 & !S_1 & S_2)
`AND_3(RD_I_VC_SWAP_BUF_o_and, 1, RD_I_VC_SWAP_BUF_o, S_0, S_1_inv, S_2)

// busy_o = (!S_1 & S_2) | (S_0 & !S_2) | (S_1 & !S_2)
wire busy_o_t0;
`AND_2(busy_o_and0, 1, busy_o_t0, S_1_inv, S_2)
wire busy_o_t1;
`AND_2(busy_o_and1, 1, busy_o_t1, S_0, S_2_inv)
wire busy_o_t2;
`AND_2(busy_o_and2, 1, busy_o_t2, S_1, S_2_inv)

`OR_3(busy_o_or, 1, busy_o, busy_o_t0, busy_o_t1, busy_o_t2)

// MakeReq_o = (S_0 & !S_1 & !S_2 & !mem_valid_i)
`AND_4(MakeReq_o_and, 1, MakeReq_o, S_0, S_1_inv, S_2_inv, mem_valid_i_inv)

// Fill0EN_o = (S_0 & !S_1 & !S_2 & mem_valid_i)
`AND_4(Fill0EN_o_and, 1, Fill0EN_o, S_0, S_1_inv, S_2_inv, mem_valid_i)

// Fill1EN_o = (!S_0 & S_1 & !S_2 & mem_valid_i)
`AND_4(Fill1EN_o_and, 1, Fill1EN_o, S_0_inv, S_1, S_2_inv, mem_valid_i)

// Fill2EN_o = (S_0 & S_1 & !S_2 & mem_valid_i)
`AND_4(Fill2EN_o_and, 1, Fill2EN_o, S_0, S_1, S_2_inv, mem_valid_i)

// Fill3EN_o = (!S_0 & !S_1 & S_2 & mem_valid_i)
`AND_4(Fill3EN_o_and, 1, Fill3EN_o, S_0_inv, S_1_inv, S_2, mem_valid_i)

endmodule
