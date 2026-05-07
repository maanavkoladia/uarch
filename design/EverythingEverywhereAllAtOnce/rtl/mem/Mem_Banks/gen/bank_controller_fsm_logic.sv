// ======================================================================
// FSM : bank_controller_fsm_logic
// Tool: fsm2rtl.py  (auto-generated -- do not hand-edit)
// Std : Verilog-2005 (IEEE 1364-2005)
// NOTE: ERROR state was synthesised automatically.
//       Any undefined transition lands here (all outputs = 0).
// ======================================================================
//
// State Enumeration  (5 bits, 22 states)
// --------------------------------------------------
//   IDLE                          00000  (decimal 0)  // IDLE (reset state)
//   LD_WAIT_0                     00001  (decimal 1)
//   LD_WAIT_1                     00010  (decimal 2)
//   LD_WAIT_2                     00011  (decimal 3)
//   LD_WAIT_3                     00100  (decimal 4)
//   LD_WAIT_4                     00101  (decimal 5)
//   LD_WAIT_5                     00110  (decimal 6)
//   LD_WAIT_6                     00111  (decimal 7)
//   LD_WAIT_7                     01000  (decimal 8)
//   ST_ADDR_WAIT_0                01001  (decimal 9)
//   ST_ADDR_WAIT_1                01010  (decimal 10)
//   ST_ADDR_WAIT_2                01011  (decimal 11)
//   ST_ADDR_WAIT_3                01100  (decimal 12)
//   ST_WRITE_WAIT_0               01101  (decimal 13)
//   ST_WRITE_WAIT_1               01110  (decimal 14)
//   ST_WRITE_WAIT_2               01111  (decimal 15)
//   ST_WRITE_WAIT_3               10000  (decimal 16)
//   ST_WRITE_WAIT_4               10001  (decimal 17)
//   ST_WRITE_WAIT_5               10010  (decimal 18)
//   ST_WRITE_WAIT_6               10011  (decimal 19)
//   ST_WRITE_WAIT_7               10100  (decimal 20)
//   ERROR                         10101  (decimal 21)  // ERROR (trap state), synthesised
//
// Truth Table (pre-expansion, original CSV rows)
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//         S_0         S_1         S_2         S_3         S_4  ld_address_change_i  start_store_i  |        NS_0        NS_1        NS_2        NS_3        NS_4  st_addr_release_o        OE_o        WE_o  clear_writebufV_o  PreCharged_o   transition
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//           0           0           0           0           0           x           0  |           1           0           0           0           0           0           1           1           0           0   IDLE -> LD_WAIT_0
//           0           0           0           0           0           x           1  |           1           0           0           1           0           1           1           1           0           0   IDLE -> ST_ADDR_WAIT_0
//           1           0           0           1           0           x           x  |           0           1           0           1           0           1           1           1           0           0   ST_ADDR_WAIT_0 -> ST_ADDR_WAIT_1
//           0           1           0           1           0           x           x  |           1           1           0           1           0           1           1           1           0           0   ST_ADDR_WAIT_1 -> ST_ADDR_WAIT_2
//           1           1           0           1           0           x           x  |           0           0           1           1           0           1           1           1           0           0   ST_ADDR_WAIT_2 -> ST_ADDR_WAIT_3
//           0           0           1           1           0           x           x  |           1           0           1           1           0           1           1           1           0           0   ST_ADDR_WAIT_3 -> ST_WRITE_WAIT_0
//           1           0           1           1           0           x           x  |           0           1           1           1           0           1           1           0           0           0   ST_WRITE_WAIT_0 -> ST_WRITE_WAIT_1
//           0           1           1           1           0           x           x  |           1           1           1           1           0           1           1           0           0           0   ST_WRITE_WAIT_1 -> ST_WRITE_WAIT_2
//           1           1           1           1           0           x           x  |           0           0           0           0           1           1           1           0           0           0   ST_WRITE_WAIT_2 -> ST_WRITE_WAIT_3
//           0           0           0           0           1           x           x  |           1           0           0           0           1           1           1           0           0           0   ST_WRITE_WAIT_3 -> ST_WRITE_WAIT_4
//           1           0           0           0           1           x           x  |           0           1           0           0           1           1           1           0           0           0   ST_WRITE_WAIT_4 -> ST_WRITE_WAIT_5
//           0           1           0           0           1           x           x  |           1           1           0           0           1           1           1           0           0           0   ST_WRITE_WAIT_5 -> ST_WRITE_WAIT_6
//           1           1           0           0           1           x           x  |           0           0           1           0           1           1           1           0           0           0   ST_WRITE_WAIT_6 -> ST_WRITE_WAIT_7
//           0           0           1           0           1           x           x  |           0           0           0           0           0           0           1           1           1           0   ST_WRITE_WAIT_7 -> IDLE
//           1           0           0           0           0           0           0  |           0           1           0           0           0           0           0           1           0           0   LD_WAIT_0 -> LD_WAIT_1
//           1           0           0           0           0           1           0  |           1           0           0           0           0           0           0           1           0           0   LD_WAIT_0 -> LD_WAIT_0
//           1           0           0           0           0           x           1  |           1           0           0           1           0           1           1           1           0           0   LD_WAIT_0 -> ST_ADDR_WAIT_0
//           0           1           0           0           0           0           0  |           1           1           0           0           0           0           0           1           0           0   LD_WAIT_1 -> LD_WAIT_2
//           0           1           0           0           0           1           0  |           1           0           0           0           0           0           0           1           0           0   LD_WAIT_1 -> LD_WAIT_0
//           0           1           0           0           0           x           1  |           1           0           0           1           0           1           1           1           0           0   LD_WAIT_1 -> ST_ADDR_WAIT_0
//           1           1           0           0           0           0           0  |           0           0           1           0           0           0           0           1           0           0   LD_WAIT_2 -> LD_WAIT_3
//           1           1           0           0           0           1           0  |           1           0           0           0           0           0           0           1           0           0   LD_WAIT_2 -> LD_WAIT_0
//           1           1           0           0           0           x           1  |           1           0           0           1           0           1           1           1           0           0   LD_WAIT_2 -> ST_ADDR_WAIT_0
//           0           0           1           0           0           0           0  |           1           0           1           0           0           0           0           1           0           0   LD_WAIT_3 -> LD_WAIT_4
//           0           0           1           0           0           1           0  |           1           0           0           0           0           0           0           1           0           0   LD_WAIT_3 -> LD_WAIT_0
//           0           0           1           0           0           x           1  |           1           0           0           1           0           1           1           1           0           0   LD_WAIT_3 -> ST_ADDR_WAIT_0
//           1           0           1           0           0           0           0  |           0           1           1           0           0           0           0           1           0           0   LD_WAIT_4 -> LD_WAIT_5
//           1           0           1           0           0           1           0  |           1           0           0           0           0           0           0           1           0           0   LD_WAIT_4 -> LD_WAIT_0
//           1           0           1           0           0           x           1  |           1           0           0           1           0           1           1           1           0           0   LD_WAIT_4 -> ST_ADDR_WAIT_0
//           0           1           1           0           0           0           0  |           1           1           1           0           0           0           0           1           0           0   LD_WAIT_5 -> LD_WAIT_6
//           0           1           1           0           0           1           0  |           1           0           0           0           0           0           0           1           0           0   LD_WAIT_5 -> LD_WAIT_0
//           0           1           1           0           0           x           1  |           1           0           0           1           0           1           1           1           0           0   LD_WAIT_5 -> ST_ADDR_WAIT_0
//           1           1           1           0           0           0           0  |           0           0           0           1           0           0           0           1           0           0   LD_WAIT_6 -> LD_WAIT_7
//           1           1           1           0           0           1           0  |           1           0           0           0           0           0           0           1           0           0   LD_WAIT_6 -> LD_WAIT_0
//           1           1           1           0           0           x           1  |           1           0           0           1           0           1           1           1           0           0   LD_WAIT_6 -> ST_ADDR_WAIT_0
//           0           0           0           1           0           0           0  |           0           0           0           1           0           0           0           1           0           1   LD_WAIT_7 -> LD_WAIT_7
//           0           0           0           1           0           1           0  |           1           0           0           0           0           0           0           1           0           1   LD_WAIT_7 -> LD_WAIT_0
//           0           0           0           1           0           x           1  |           1           0           0           1           0           1           1           1           0           1   LD_WAIT_7 -> ST_ADDR_WAIT_0
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//

module bank_controller_fsm_logic (
    input  wire clk,
    input  wire rst,
    input  wire ld_address_change_i,
    input  wire start_store_i,
    output wire S_0,  // current-state bit 0 (LSB)
    output wire S_1,  // current-state bit 1 (1)
    output wire S_2,  // current-state bit 2 (2)
    output wire S_3,  // current-state bit 3 (3)
    output wire S_4,  // current-state bit 4 (MSB)
    output wire st_addr_release_o,
    output wire OE_o,
    output wire WE_o,
    output wire clear_writebufV_o,
    output wire PreCharged_o
);

// ----------------------------------------------------------------
// Next-state wires  (NS_0 = LSB ... NS_{N-1} = MSB)
// ----------------------------------------------------------------
wire NS_0;
wire NS_1;
wire NS_2;
wire NS_3;
wire NS_4;

// State encoding  (IDLE = 0, ERROR = highest, guaranteed by tool)
//   IDLE                         = 00000  (decimal 0)  // IDLE (reset state)
//   LD_WAIT_0                    = 00001  (decimal 1)
//   LD_WAIT_1                    = 00010  (decimal 2)
//   LD_WAIT_2                    = 00011  (decimal 3)
//   LD_WAIT_3                    = 00100  (decimal 4)
//   LD_WAIT_4                    = 00101  (decimal 5)
//   LD_WAIT_5                    = 00110  (decimal 6)
//   LD_WAIT_6                    = 00111  (decimal 7)
//   LD_WAIT_7                    = 01000  (decimal 8)
//   ST_ADDR_WAIT_0               = 01001  (decimal 9)
//   ST_ADDR_WAIT_1               = 01010  (decimal 10)
//   ST_ADDR_WAIT_2               = 01011  (decimal 11)
//   ST_ADDR_WAIT_3               = 01100  (decimal 12)
//   ST_WRITE_WAIT_0              = 01101  (decimal 13)
//   ST_WRITE_WAIT_1              = 01110  (decimal 14)
//   ST_WRITE_WAIT_2              = 01111  (decimal 15)
//   ST_WRITE_WAIT_3              = 10000  (decimal 16)
//   ST_WRITE_WAIT_4              = 10001  (decimal 17)
//   ST_WRITE_WAIT_5              = 10010  (decimal 18)
//   ST_WRITE_WAIT_6              = 10011  (decimal 19)
//   ST_WRITE_WAIT_7              = 10100  (decimal 20)
//   ERROR                        = 10101  (decimal 21)  // ERROR (trap state), synthesised

// ----------------------------------------------------------------
// State flip-flops
// `REG_RST samples D on every rising clk edge.
// Active-high rst drives all state bits to 0 (= IDLE encoding).
// ----------------------------------------------------------------
`REG_RST(ff_0, 1, clk, rst, NS_0, S_0)
`REG_RST(ff_1, 1, clk, rst, NS_1, S_1)
`REG_RST(ff_2, 1, clk, rst, NS_2, S_2)
`REG_RST(ff_3, 1, clk, rst, NS_3, S_3)
`REG_RST(ff_4, 1, clk, rst, NS_4, S_4)

// ----------------------------------------------------------------
// Inverters for negated literals
// ----------------------------------------------------------------
wire S_0_inv;
wire S_1_inv;
wire S_2_inv;
wire S_3_inv;
wire S_4_inv;
wire ld_address_change_i_inv;
wire start_store_i_inv;

`INV_N(inv_S_0, 1, S_0, S_0_inv)
`INV_N(inv_S_1, 1, S_1, S_1_inv)
`INV_N(inv_S_2, 1, S_2, S_2_inv)
`INV_N(inv_S_3, 1, S_3, S_3_inv)
`INV_N(inv_S_4, 1, S_4, S_4_inv)
`INV_N(inv_ld_address_change_i, 1, ld_address_change_i, ld_address_change_i_inv)
`INV_N(inv_start_store_i, 1, start_store_i, start_store_i_inv)

// ----------------------------------------------------------------
// Next-state and output SOP logic
// ----------------------------------------------------------------

// NS_0 = (!S_0 & S_1 & !S_4) | (!S_3 & !S_4 & start_store_i) | (!S_0 & !S_2 & !S_3) | (!S_0 & S_2 & !S_4) | (!S_3 & !S_4 & ld_address_change_i) | (S_0 & !S_1 & S_2 & !S_3 & S_4) | (!S_0 & !S_4 & ld_address_change_i) | (!S_0 & !S_4 & start_store_i)
wire NS_0_t0;
`AND_3(NS_0_and0, 1, NS_0_t0, S_0_inv, S_1, S_4_inv)
wire NS_0_t1;
`AND_3(NS_0_and1, 1, NS_0_t1, S_3_inv, S_4_inv, start_store_i)
wire NS_0_t2;
`AND_3(NS_0_and2, 1, NS_0_t2, S_0_inv, S_2_inv, S_3_inv)
wire NS_0_t3;
`AND_3(NS_0_and3, 1, NS_0_t3, S_0_inv, S_2, S_4_inv)
wire NS_0_t4;
`AND_3(NS_0_and4, 1, NS_0_t4, S_3_inv, S_4_inv, ld_address_change_i)
wire NS_0_t5;
`AND_5(NS_0_and5, 1, NS_0_t5, S_0, S_1_inv, S_2, S_3_inv, S_4)
wire NS_0_t6;
`AND_3(NS_0_and6, 1, NS_0_t6, S_0_inv, S_4_inv, ld_address_change_i)
wire NS_0_t7;
`AND_3(NS_0_and7, 1, NS_0_t7, S_0_inv, S_4_inv, start_store_i)

`OR_8(NS_0_or, 1, NS_0, NS_0_t0, NS_0_t1, NS_0_t2, NS_0_t3, NS_0_t4, NS_0_t5, NS_0_t6, NS_0_t7)

// NS_1 = (!S_0 & S_1 & S_3 & !S_4) | (S_0 & !S_1 & S_3 & !S_4) | (S_0 & !S_1 & !S_2 & !S_3 & S_4) | (!S_0 & S_1 & !S_2 & !S_3 & S_4) | (S_0 & !S_1 & !S_4 & !ld_address_change_i & !start_store_i) | (!S_0 & S_1 & !S_4 & !ld_address_change_i & !start_store_i)
wire NS_1_t0;
`AND_4(NS_1_and0, 1, NS_1_t0, S_0_inv, S_1, S_3, S_4_inv)
wire NS_1_t1;
`AND_4(NS_1_and1, 1, NS_1_t1, S_0, S_1_inv, S_3, S_4_inv)
wire NS_1_t2;
`AND_5(NS_1_and2, 1, NS_1_t2, S_0, S_1_inv, S_2_inv, S_3_inv, S_4)
wire NS_1_t3;
`AND_5(NS_1_and3, 1, NS_1_t3, S_0_inv, S_1, S_2_inv, S_3_inv, S_4)
wire NS_1_t4;
`AND_5(NS_1_and4, 1, NS_1_t4, S_0, S_1_inv, S_4_inv, ld_address_change_i_inv, start_store_i_inv)
wire NS_1_t5;
`AND_5(NS_1_and5, 1, NS_1_t5, S_0_inv, S_1, S_4_inv, ld_address_change_i_inv, start_store_i_inv)

`OR_6(NS_1_or, 1, NS_1, NS_1_t0, NS_1_t1, NS_1_t2, NS_1_t3, NS_1_t4, NS_1_t5)

// NS_2 = (!S_0 & S_2 & S_3 & !S_4) | (!S_1 & S_2 & S_3 & !S_4) | (S_0 & S_1 & !S_2 & S_3 & !S_4) | (S_0 & !S_1 & S_2 & !S_3 & S_4) | (S_0 & S_1 & !S_2 & !S_3 & S_4) | (!S_1 & S_2 & !S_4 & !ld_address_change_i & !start_store_i) | (!S_0 & S_2 & !S_4 & !ld_address_change_i & !start_store_i) | (S_0 & S_1 & !S_2 & !S_3 & !ld_address_change_i & !start_store_i)
wire NS_2_t0;
`AND_4(NS_2_and0, 1, NS_2_t0, S_0_inv, S_2, S_3, S_4_inv)
wire NS_2_t1;
`AND_4(NS_2_and1, 1, NS_2_t1, S_1_inv, S_2, S_3, S_4_inv)
wire NS_2_t2;
`AND_5(NS_2_and2, 1, NS_2_t2, S_0, S_1, S_2_inv, S_3, S_4_inv)
wire NS_2_t3;
`AND_5(NS_2_and3, 1, NS_2_t3, S_0, S_1_inv, S_2, S_3_inv, S_4)
wire NS_2_t4;
`AND_5(NS_2_and4, 1, NS_2_t4, S_0, S_1, S_2_inv, S_3_inv, S_4)
wire NS_2_t5;
`AND_5(NS_2_and5, 1, NS_2_t5, S_1_inv, S_2, S_4_inv, ld_address_change_i_inv, start_store_i_inv)
wire NS_2_t6;
`AND_5(NS_2_and6, 1, NS_2_t6, S_0_inv, S_2, S_4_inv, ld_address_change_i_inv, start_store_i_inv)
wire NS_2_t7;
`AND_6(NS_2_and7, 1, NS_2_t7, S_0, S_1, S_2_inv, S_3_inv, ld_address_change_i_inv, start_store_i_inv)

`OR_8(NS_2_or, 1, NS_2, NS_2_t0, NS_2_t1, NS_2_t2, NS_2_t3, NS_2_t4, NS_2_t5, NS_2_t6, NS_2_t7)

// NS_3 = (!S_0 & !S_4 & start_store_i) | (!S_1 & !S_4 & start_store_i) | (S_0 & !S_2 & S_3 & !S_4) | (!S_3 & !S_4 & start_store_i) | (!S_1 & S_2 & S_3 & !S_4) | (!S_0 & S_1 & S_3 & !S_4) | (!S_0 & S_3 & !S_4 & !ld_address_change_i) | (S_0 & S_1 & S_2 & !S_3 & !S_4 & !ld_address_change_i)
wire NS_3_t0;
`AND_3(NS_3_and0, 1, NS_3_t0, S_0_inv, S_4_inv, start_store_i)
wire NS_3_t1;
`AND_3(NS_3_and1, 1, NS_3_t1, S_1_inv, S_4_inv, start_store_i)
wire NS_3_t2;
`AND_4(NS_3_and2, 1, NS_3_t2, S_0, S_2_inv, S_3, S_4_inv)
wire NS_3_t3;
`AND_3(NS_3_and3, 1, NS_3_t3, S_3_inv, S_4_inv, start_store_i)
wire NS_3_t4;
`AND_4(NS_3_and4, 1, NS_3_t4, S_1_inv, S_2, S_3, S_4_inv)
wire NS_3_t5;
`AND_4(NS_3_and5, 1, NS_3_t5, S_0_inv, S_1, S_3, S_4_inv)
wire NS_3_t6;
`AND_4(NS_3_and6, 1, NS_3_t6, S_0_inv, S_3, S_4_inv, ld_address_change_i_inv)
wire NS_3_t7;
`AND_6(NS_3_and7, 1, NS_3_t7, S_0, S_1, S_2, S_3_inv, S_4_inv, ld_address_change_i_inv)

`OR_8(NS_3_or, 1, NS_3, NS_3_t0, NS_3_t1, NS_3_t2, NS_3_t3, NS_3_t4, NS_3_t5, NS_3_t6, NS_3_t7)

// NS_4 = (!S_2 & !S_3 & S_4) | (S_0 & !S_1 & !S_3 & S_4) | (S_0 & S_1 & S_2 & S_3 & !S_4)
wire NS_4_t0;
`AND_3(NS_4_and0, 1, NS_4_t0, S_2_inv, S_3_inv, S_4)
wire NS_4_t1;
`AND_4(NS_4_and1, 1, NS_4_t1, S_0, S_1_inv, S_3_inv, S_4)
wire NS_4_t2;
`AND_5(NS_4_and2, 1, NS_4_t2, S_0, S_1, S_2, S_3, S_4_inv)

`OR_3(NS_4_or, 1, NS_4, NS_4_t0, NS_4_t1, NS_4_t2)

// st_addr_release_o = (!S_4 & start_store_i) | (!S_2 & !S_3 & S_4) | (S_1 & S_3 & !S_4) | (S_2 & S_3 & !S_4) | (S_0 & S_3 & !S_4)
wire st_addr_release_o_t0;
`AND_2(st_addr_release_o_and0, 1, st_addr_release_o_t0, S_4_inv, start_store_i)
wire st_addr_release_o_t1;
`AND_3(st_addr_release_o_and1, 1, st_addr_release_o_t1, S_2_inv, S_3_inv, S_4)
wire st_addr_release_o_t2;
`AND_3(st_addr_release_o_and2, 1, st_addr_release_o_t2, S_1, S_3, S_4_inv)
wire st_addr_release_o_t3;
`AND_3(st_addr_release_o_and3, 1, st_addr_release_o_t3, S_2, S_3, S_4_inv)
wire st_addr_release_o_t4;
`AND_3(st_addr_release_o_and4, 1, st_addr_release_o_t4, S_0, S_3, S_4_inv)

`OR_5(st_addr_release_o_or, 1, st_addr_release_o, st_addr_release_o_t0, st_addr_release_o_t1, st_addr_release_o_t2, st_addr_release_o_t3, st_addr_release_o_t4)

// OE_o = (!S_4 & start_store_i) | (!S_2 & !S_3 & S_4) | (S_2 & S_3 & !S_4) | (S_1 & S_3 & !S_4) | (!S_0 & !S_1 & !S_3 & S_4) | (S_0 & S_3 & !S_4) | (!S_0 & !S_1 & !S_2 & !S_3)
wire OE_o_t0;
`AND_2(OE_o_and0, 1, OE_o_t0, S_4_inv, start_store_i)
wire OE_o_t1;
`AND_3(OE_o_and1, 1, OE_o_t1, S_2_inv, S_3_inv, S_4)
wire OE_o_t2;
`AND_3(OE_o_and2, 1, OE_o_t2, S_2, S_3, S_4_inv)
wire OE_o_t3;
`AND_3(OE_o_and3, 1, OE_o_t3, S_1, S_3, S_4_inv)
wire OE_o_t4;
`AND_4(OE_o_and4, 1, OE_o_t4, S_0_inv, S_1_inv, S_3_inv, S_4)
wire OE_o_t5;
`AND_3(OE_o_and5, 1, OE_o_t5, S_0, S_3, S_4_inv)
wire OE_o_t6;
`AND_4(OE_o_and6, 1, OE_o_t6, S_0_inv, S_1_inv, S_2_inv, S_3_inv)

`OR_7(OE_o_or, 1, OE_o, OE_o_t0, OE_o_t1, OE_o_t2, OE_o_t3, OE_o_t4, OE_o_t5, OE_o_t6)

// WE_o = (!S_3 & !S_4) | (!S_2 & !S_4) | (!S_0 & !S_1 & !S_4) | (!S_0 & !S_1 & S_2 & !S_3)
wire WE_o_n0;
`NAND_2(WE_o_nand0, 1, WE_o_n0, S_3_inv, S_4_inv)
wire WE_o_n1;
`NAND_2(WE_o_nand1, 1, WE_o_n1, S_2_inv, S_4_inv)
wire WE_o_n2;
`NAND_3(WE_o_nand2, 1, WE_o_n2, S_0_inv, S_1_inv, S_4_inv)
wire WE_o_n3;
`NAND_4(WE_o_nand3, 1, WE_o_n3, S_0_inv, S_1_inv, S_2, S_3_inv)

`NAND_4(WE_o_nand, 1, WE_o, WE_o_n0, WE_o_n1, WE_o_n2, WE_o_n3)

// clear_writebufV_o = (!S_0 & !S_1 & S_2 & !S_3 & S_4)
`AND_5(clear_writebufV_o_and, 1, clear_writebufV_o, S_0_inv, S_1_inv, S_2, S_3_inv, S_4)

// PreCharged_o = (!S_0 & !S_1 & !S_2 & S_3 & !S_4)
`AND_5(PreCharged_o_and, 1, PreCharged_o, S_0_inv, S_1_inv, S_2_inv, S_3, S_4_inv)

endmodule
