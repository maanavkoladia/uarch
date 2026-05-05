// ======================================================================
// FSM : VCache_FSM
// Tool: fsm2rtl.py  (auto-generated -- do not hand-edit)
// Std : Verilog-2005 (IEEE 1364-2005)
// NOTE: ERROR state was synthesised automatically.
//       Any undefined transition lands here (all outputs = 0).
// ======================================================================
//
// State Enumeration  (3 bits, 6 states)
// --------------------------------------------------
//   IDLE                          000  (decimal 0)  // IDLE (reset state)
//   LD_VC_SWAP                    001  (decimal 1)
//   WAITEVICT                     010  (decimal 2)
//   WRITE_2_VCACHE                011  (decimal 3)
//   WRITE_EB                      100  (decimal 4)
//   ERROR                         101  (decimal 5)  // ERROR (trap state), synthesised
//
// Truth Table (pre-expansion, original CSV rows)
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//         S_0         S_1         S_2     V_Hit_i  DC_will_evict_i  VC_needs_2_evict_i      EB_V_i        we_i  |        NS_0        NS_1        NS_2   WR_2_EB_o  CLR_D_SWAP_V_o  Read_DSWAP_o  Write_VSWAP_o  Update_LRU_o      busy_o   blocked_o   transition
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//           0           0           0           0           0           x           x           x  |           0           0           0           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           0           1           x           x           x           0  |           1           1           0           0           0           0           1           0           0           0   IDLE -> WRITE_2_VCACHE
//           0           0           0           1           x           x           x           1  |           1           0           0           0           0           0           0           0           0           0   IDLE -> LD_VC_SWAP
//           0           0           0           0           1           0           0           x  |           1           1           0           0           0           0           0           0           0           0   IDLE -> WRITE_2_VCACHE
//           0           0           0           0           1           0           1           x  |           1           1           0           0           0           0           0           0           0           0   IDLE -> WRITE_2_VCACHE
//           0           0           0           0           1           1           0           x  |           0           0           1           0           0           0           0           0           0           0   IDLE -> WRITE_EB
//           0           0           0           0           1           1           1           x  |           0           1           0           0           0           0           0           0           0           0   IDLE -> WAITEVICT
//           1           0           0           x           x           x           x           x  |           1           1           0           0           0           0           1           0           1           0   LD_VC_SWAP -> WRITE_2_VCACHE
//           1           1           0           x           x           x           x           x  |           0           0           0           0           1           1           0           1           1           0   WRITE_2_VCACHE -> IDLE
//           0           0           1           x           x           x           x           x  |           1           1           0           1           0           0           0           0           1           0   WRITE_EB -> WRITE_2_VCACHE
//           0           1           0           x           x           x           1           x  |           0           1           0           1           0           0           0           0           1           1   WAITEVICT -> WAITEVICT
//           0           1           0           x           x           x           0           x  |           1           1           0           1           0           0           0           0           1           0   WAITEVICT -> WRITE_2_VCACHE
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
    output wire busy_o,
    output wire blocked_o
);

// ----------------------------------------------------------------
// Next-state wires  (NS_0 = LSB ... NS_{N-1} = MSB)
// ----------------------------------------------------------------
wire NS_0;
wire NS_1;
wire NS_2;

// State encoding  (IDLE = 0, ERROR = highest, guaranteed by tool)
//   IDLE                         = 000  (decimal 0)  // IDLE (reset state)
//   LD_VC_SWAP                   = 001  (decimal 1)
//   WAITEVICT                    = 010  (decimal 2)
//   WRITE_2_VCACHE               = 011  (decimal 3)
//   WRITE_EB                     = 100  (decimal 4)
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
wire EB_V_i_inv;
wire S_0_inv;
wire S_1_inv;
wire S_2_inv;
wire VC_needs_2_evict_i_inv;
wire V_Hit_i_inv;
wire we_i_inv;

`INV_N(inv_EB_V_i, 1, EB_V_i, EB_V_i_inv)
`INV_N(inv_S_0, 1, S_0, S_0_inv)
`INV_N(inv_S_1, 1, S_1, S_1_inv)
`INV_N(inv_S_2, 1, S_2, S_2_inv)
`INV_N(inv_VC_needs_2_evict_i, 1, VC_needs_2_evict_i, VC_needs_2_evict_i_inv)
`INV_N(inv_V_Hit_i, 1, V_Hit_i, V_Hit_i_inv)
`INV_N(inv_we_i, 1, we_i, we_i_inv)

// ----------------------------------------------------------------
// Next-state and output SOP logic
// ----------------------------------------------------------------

// NS_0 = (!S_1 & V_Hit_i) | (S_0 & !S_1) | (!S_1 & S_2) | (!S_0 & S_1 & !S_2 & !EB_V_i) | (!S_1 & DC_will_evict_i & !VC_needs_2_evict_i)
wire NS_0_t0;
`AND_2(NS_0_and0, 1, NS_0_t0, S_1_inv, V_Hit_i)
wire NS_0_t1;
`AND_2(NS_0_and1, 1, NS_0_t1, S_0, S_1_inv)
wire NS_0_t2;
`AND_2(NS_0_and2, 1, NS_0_t2, S_1_inv, S_2)
wire NS_0_t3;
`AND_4(NS_0_and3, 1, NS_0_t3, S_0_inv, S_1, S_2_inv, EB_V_i_inv)
wire NS_0_t4;
`AND_3(NS_0_and4, 1, NS_0_t4, S_1_inv, DC_will_evict_i, VC_needs_2_evict_i_inv)

`OR_5(NS_0_or, 1, NS_0, NS_0_t0, NS_0_t1, NS_0_t2, NS_0_t3, NS_0_t4)

// NS_1 = (!S_0 & S_1 & !S_2) | (!S_0 & !S_1 & S_2) | (S_0 & !S_1 & !S_2) | (!S_1 & !S_2 & V_Hit_i & !we_i) | (!S_1 & !S_2 & !V_Hit_i & DC_will_evict_i & !VC_needs_2_evict_i) | (!S_1 & !S_2 & !V_Hit_i & DC_will_evict_i & EB_V_i)
wire NS_1_t0;
`AND_3(NS_1_and0, 1, NS_1_t0, S_0_inv, S_1, S_2_inv)
wire NS_1_t1;
`AND_3(NS_1_and1, 1, NS_1_t1, S_0_inv, S_1_inv, S_2)
wire NS_1_t2;
`AND_3(NS_1_and2, 1, NS_1_t2, S_0, S_1_inv, S_2_inv)
wire NS_1_t3;
`AND_4(NS_1_and3, 1, NS_1_t3, S_1_inv, S_2_inv, V_Hit_i, we_i_inv)
wire NS_1_t4;
`AND_5(NS_1_and4, 1, NS_1_t4, S_1_inv, S_2_inv, V_Hit_i_inv, DC_will_evict_i, VC_needs_2_evict_i_inv)
wire NS_1_t5;
`AND_5(NS_1_and5, 1, NS_1_t5, S_1_inv, S_2_inv, V_Hit_i_inv, DC_will_evict_i, EB_V_i)

`OR_6(NS_1_or, 1, NS_1, NS_1_t0, NS_1_t1, NS_1_t2, NS_1_t3, NS_1_t4, NS_1_t5)

// NS_2 = (S_0 & !S_1 & S_2) | (!S_0 & !S_1 & !S_2 & !V_Hit_i & DC_will_evict_i & VC_needs_2_evict_i & !EB_V_i)
wire NS_2_t0;
`AND_3(NS_2_and0, 1, NS_2_t0, S_0, S_1_inv, S_2)
wire NS_2_t1;
`AND_7(NS_2_and1, 1, NS_2_t1, S_0_inv, S_1_inv, S_2_inv, V_Hit_i_inv, DC_will_evict_i, VC_needs_2_evict_i, EB_V_i_inv)

`OR_2(NS_2_or, 1, NS_2, NS_2_t0, NS_2_t1)

// WR_2_EB_o = (!S_0 & !S_1 & S_2) | (!S_0 & S_1 & !S_2)
wire WR_2_EB_o_n0;
`NAND_3(WR_2_EB_o_nand0, 1, WR_2_EB_o_n0, S_0_inv, S_1_inv, S_2)
wire WR_2_EB_o_n1;
`NAND_3(WR_2_EB_o_nand1, 1, WR_2_EB_o_n1, S_0_inv, S_1, S_2_inv)

`NAND_2(WR_2_EB_o_nand, 1, WR_2_EB_o, WR_2_EB_o_n0, WR_2_EB_o_n1)

// CLR_D_SWAP_V_o = (S_0 & S_1 & !S_2)
`AND_3(CLR_D_SWAP_V_o_and, 1, CLR_D_SWAP_V_o, S_0, S_1, S_2_inv)

// Read_DSWAP_o = (S_0 & S_1 & !S_2)
`AND_3(Read_DSWAP_o_and, 1, Read_DSWAP_o, S_0, S_1, S_2_inv)

// Write_VSWAP_o = (S_0 & !S_1 & !S_2) | (!S_1 & !S_2 & V_Hit_i & !we_i)
wire Write_VSWAP_o_n0;
`NAND_3(Write_VSWAP_o_nand0, 1, Write_VSWAP_o_n0, S_0, S_1_inv, S_2_inv)
wire Write_VSWAP_o_n1;
`NAND_4(Write_VSWAP_o_nand1, 1, Write_VSWAP_o_n1, S_1_inv, S_2_inv, V_Hit_i, we_i_inv)

`NAND_2(Write_VSWAP_o_nand, 1, Write_VSWAP_o, Write_VSWAP_o_n0, Write_VSWAP_o_n1)

// Update_LRU_o = (S_0 & S_1 & !S_2)
`AND_3(Update_LRU_o_and, 1, Update_LRU_o, S_0, S_1, S_2_inv)

// busy_o = (S_0 & !S_2) | (S_1 & !S_2) | (!S_0 & !S_1 & S_2)
wire busy_o_n0;
`NAND_2(busy_o_nand0, 1, busy_o_n0, S_0, S_2_inv)
wire busy_o_n1;
`NAND_2(busy_o_nand1, 1, busy_o_n1, S_1, S_2_inv)
wire busy_o_n2;
`NAND_3(busy_o_nand2, 1, busy_o_n2, S_0_inv, S_1_inv, S_2)

`NAND_3(busy_o_nand, 1, busy_o, busy_o_n0, busy_o_n1, busy_o_n2)

// blocked_o = (!S_0 & S_1 & !S_2 & EB_V_i)
`AND_4(blocked_o_and, 1, blocked_o, S_0_inv, S_1, S_2_inv, EB_V_i)

endmodule
