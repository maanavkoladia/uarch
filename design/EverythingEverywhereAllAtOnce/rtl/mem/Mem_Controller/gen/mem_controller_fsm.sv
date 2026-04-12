// ======================================================================
// FSM : mem_controller_fsm
// Tool: fsm2rtl.py  (auto-generated -- do not hand-edit)
// Std : Verilog-2005 (IEEE 1364-2005)
// ======================================================================
//
// State Enumeration  (4 bits, 10 states)
// --------------------------------------------------
//   IDLE                          0000  (decimal 0)  // IDLE (reset state)
//   LD_0                          0001  (decimal 1)
//   LD_1                          0010  (decimal 2)
//   LD_2                          0011  (decimal 3)
//   LD_HIT                        0100  (decimal 4)
//   LD_MISS                       0101  (decimal 5)
//   W0                            0110  (decimal 6)
//   W1                            0111  (decimal 7)
//   W2                            1000  (decimal 8)
//   ERROR                         1001  (decimal 9)  // ERROR (trap state)
//
// Truth Table (pre-expansion, original CSV rows)
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//         S_0         S_1         S_2         S_3    ld_req_i  write_req_i       hit_i  |        NS_0        NS_1        NS_2        NS_3  mem_ready_o  set_ld_tristate_o  start_store_o  ld_address_changed_o  set_WriteBuf_V_o     fill0_o     fill1_o     fill2_o     fill3_o   transition
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//           0           0           0           0           0           0           x  |           0           0           0           0           0           0           0           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           0           0           0           1           x  |           0           1           1           0           0           0           0           0           1           1           0           0           0   IDLE -> W0
//           0           0           0           0           1           0           0  |           1           0           1           0           0           0           0           1           0           0           0           0           0   IDLE -> LD_MISS
//           0           0           0           0           1           0           1  |           0           0           1           0           1           1           0           0           0           0           0           0           0   IDLE -> LD_HIT
//           0           0           0           0           1           1           x  |           1           0           0           1           0           0           0           0           0           0           0           0           0   IDLE -> ERROR
//           0           1           1           0           x           x           x  |           1           1           1           0           0           0           0           0           0           0           1           0           0   W0 -> W1
//           1           1           1           0           x           x           x  |           0           0           0           1           0           0           0           0           0           0           0           1           0   W1 -> W2
//           0           0           0           1           x           x           x  |           0           0           0           0           0           0           1           0           0           0           0           0           1   W2 -> IDLE
//           0           0           1           0           x           x           x  |           1           0           0           0           0           1           0           0           0           0           0           0           0   LD_HIT -> LD_0
//           1           0           0           0           x           x           x  |           0           1           0           0           0           1           0           0           0           0           0           0           0   LD_0 -> LD_1
//           0           1           0           0           x           x           x  |           1           1           0           0           0           1           0           0           0           0           0           0           0   LD_1 -> LD_2
//           1           1           0           0           x           x           x  |           0           0           0           0           0           1           0           0           0           0           0           0           0   LD_2 -> IDLE
//           1           0           1           0           x           x           0  |           1           0           1           0           0           0           0           0           0           0           0           0           0   LD_MISS -> LD_MISS
//           1           0           1           0           x           x           1  |           0           0           1           0           1           1           0           0           0           0           0           0           0   LD_MISS -> LD_HIT
//           1           0           0           1           x           x           x  |           1           0           0           1           0           0           0           0           0           0           0           0           0   ERROR -> ERROR
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//

module mem_controller_fsm (
    input  wire clk,
    input  wire rst,
    input  wire ld_req_i,
    input  wire write_req_i,
    input  wire hit_i,
    output wire S_0,  // current-state bit 0 (LSB)
    output wire S_1,  // current-state bit 1 (1)
    output wire S_2,  // current-state bit 2 (2)
    output wire S_3,  // current-state bit 3 (MSB)
    output wire mem_ready_o,
    output wire set_ld_tristate_o,
    output wire start_store_o,
    output wire ld_address_changed_o,
    output wire set_WriteBuf_V_o,
    output wire fill0_o,
    output wire fill1_o,
    output wire fill2_o,
    output wire fill3_o
);

// ----------------------------------------------------------------
// Next-state wires  (NS_0 = LSB ... NS_{N-1} = MSB)
// ----------------------------------------------------------------
wire NS_0;
wire NS_1;
wire NS_2;
wire NS_3;

// State encoding  (IDLE = 0, ERROR = highest, guaranteed by tool)
//   IDLE                         = 0000  (decimal 0)  // IDLE (reset state)
//   LD_0                         = 0001  (decimal 1)
//   LD_1                         = 0010  (decimal 2)
//   LD_2                         = 0011  (decimal 3)
//   LD_HIT                       = 0100  (decimal 4)
//   LD_MISS                      = 0101  (decimal 5)
//   W0                           = 0110  (decimal 6)
//   W1                           = 0111  (decimal 7)
//   W2                           = 1000  (decimal 8)
//   ERROR                        = 1001  (decimal 9)  // ERROR (trap state)

// ----------------------------------------------------------------
// State flip-flops
// `REG_RST samples D on every rising clk edge.
// Active-high rst drives all state bits to 0 (= IDLE encoding).
// ----------------------------------------------------------------
`REG_RST(ff_0, 1, clk, rst, NS_0, S_0)
`REG_RST(ff_1, 1, clk, rst, NS_1, S_1)
`REG_RST(ff_2, 1, clk, rst, NS_2, S_2)
`REG_RST(ff_3, 1, clk, rst, NS_3, S_3)

// ----------------------------------------------------------------
// Inverters for negated literals
// ----------------------------------------------------------------
wire S_0_inv;
wire S_1_inv;
wire S_2_inv;
wire S_3_inv;
wire hit_i_inv;
wire ld_req_i_inv;
wire write_req_i_inv;

`INV_N(inv_S_0, 1, S_0, S_0_inv)
`INV_N(inv_S_1, 1, S_1, S_1_inv)
`INV_N(inv_S_2, 1, S_2, S_2_inv)
`INV_N(inv_S_3, 1, S_3, S_3_inv)
`INV_N(inv_hit_i, 1, hit_i, hit_i_inv)
`INV_N(inv_ld_req_i, 1, ld_req_i, ld_req_i_inv)
`INV_N(inv_write_req_i, 1, write_req_i, write_req_i_inv)

// ----------------------------------------------------------------
// Next-state and output SOP logic
// ----------------------------------------------------------------

// NS_0 = (!S_0 & S_2 & !S_3) | (!S_0 & S_1 & !S_3) | (S_0 & !S_1 & !S_2 & S_3) | (!S_1 & S_2 & !S_3 & !hit_i) | (!S_0 & !S_3 & ld_req_i & write_req_i) | (!S_0 & !S_3 & ld_req_i & !hit_i)
wire NS_0_t0;
`AND_3(NS_0_and0, 1, NS_0_t0, S_0_inv, S_2, S_3_inv)
wire NS_0_t1;
`AND_3(NS_0_and1, 1, NS_0_t1, S_0_inv, S_1, S_3_inv)
wire NS_0_t2;
`AND_4(NS_0_and2, 1, NS_0_t2, S_0, S_1_inv, S_2_inv, S_3)
wire NS_0_t3;
`AND_4(NS_0_and3, 1, NS_0_t3, S_1_inv, S_2, S_3_inv, hit_i_inv)
wire NS_0_t4;
`AND_4(NS_0_and4, 1, NS_0_t4, S_0_inv, S_3_inv, ld_req_i, write_req_i)
wire NS_0_t5;
`AND_4(NS_0_and5, 1, NS_0_t5, S_0_inv, S_3_inv, ld_req_i, hit_i_inv)

`OR_6(NS_0_or, 1, NS_0, NS_0_t0, NS_0_t1, NS_0_t2, NS_0_t3, NS_0_t4, NS_0_t5)

// NS_1 = (!S_0 & S_1 & !S_3) | (S_0 & !S_1 & !S_2 & !S_3) | (!S_1 & !S_2 & !S_3 & !ld_req_i & write_req_i)
wire NS_1_t0;
`AND_3(NS_1_and0, 1, NS_1_t0, S_0_inv, S_1, S_3_inv)
wire NS_1_t1;
`AND_4(NS_1_and1, 1, NS_1_t1, S_0, S_1_inv, S_2_inv, S_3_inv)
wire NS_1_t2;
`AND_5(NS_1_and2, 1, NS_1_t2, S_1_inv, S_2_inv, S_3_inv, ld_req_i_inv, write_req_i)

`OR_3(NS_1_or, 1, NS_1, NS_1_t0, NS_1_t1, NS_1_t2)

// NS_2 = (!S_0 & S_1 & S_2 & !S_3) | (S_0 & !S_1 & S_2 & !S_3) | (!S_0 & !S_1 & !S_2 & !S_3 & ld_req_i & !write_req_i) | (!S_0 & !S_1 & !S_2 & !S_3 & !ld_req_i & write_req_i)
wire NS_2_t0;
`AND_4(NS_2_and0, 1, NS_2_t0, S_0_inv, S_1, S_2, S_3_inv)
wire NS_2_t1;
`AND_4(NS_2_and1, 1, NS_2_t1, S_0, S_1_inv, S_2, S_3_inv)
wire NS_2_t2;
`AND_6(NS_2_and2, 1, NS_2_t2, S_0_inv, S_1_inv, S_2_inv, S_3_inv, ld_req_i, write_req_i_inv)
wire NS_2_t3;
`AND_6(NS_2_and3, 1, NS_2_t3, S_0_inv, S_1_inv, S_2_inv, S_3_inv, ld_req_i_inv, write_req_i)

`OR_4(NS_2_or, 1, NS_2, NS_2_t0, NS_2_t1, NS_2_t2, NS_2_t3)

// NS_3 = (S_0 & !S_1 & !S_2 & S_3) | (S_0 & S_1 & S_2 & !S_3) | (!S_0 & !S_1 & !S_2 & !S_3 & ld_req_i & write_req_i)
wire NS_3_t0;
`AND_4(NS_3_and0, 1, NS_3_t0, S_0, S_1_inv, S_2_inv, S_3)
wire NS_3_t1;
`AND_4(NS_3_and1, 1, NS_3_t1, S_0, S_1, S_2, S_3_inv)
wire NS_3_t2;
`AND_6(NS_3_and2, 1, NS_3_t2, S_0_inv, S_1_inv, S_2_inv, S_3_inv, ld_req_i, write_req_i)

`OR_3(NS_3_or, 1, NS_3, NS_3_t0, NS_3_t1, NS_3_t2)

// mem_ready_o = (S_0 & !S_1 & S_2 & !S_3 & hit_i) | (!S_0 & !S_1 & !S_2 & !S_3 & ld_req_i & !write_req_i & hit_i)
wire mem_ready_o_t0;
`AND_5(mem_ready_o_and0, 1, mem_ready_o_t0, S_0, S_1_inv, S_2, S_3_inv, hit_i)
wire mem_ready_o_t1;
`AND_7(mem_ready_o_and1, 1, mem_ready_o_t1, S_0_inv, S_1_inv, S_2_inv, S_3_inv, ld_req_i, write_req_i_inv, hit_i)

`OR_2(mem_ready_o_or, 1, mem_ready_o, mem_ready_o_t0, mem_ready_o_t1)

// set_ld_tristate_o = (S_0 & !S_2 & !S_3) | (S_1 & !S_2 & !S_3) | (!S_0 & !S_1 & S_2 & !S_3) | (!S_1 & S_2 & !S_3 & hit_i) | (!S_1 & !S_3 & ld_req_i & !write_req_i & hit_i)
wire set_ld_tristate_o_t0;
`AND_3(set_ld_tristate_o_and0, 1, set_ld_tristate_o_t0, S_0, S_2_inv, S_3_inv)
wire set_ld_tristate_o_t1;
`AND_3(set_ld_tristate_o_and1, 1, set_ld_tristate_o_t1, S_1, S_2_inv, S_3_inv)
wire set_ld_tristate_o_t2;
`AND_4(set_ld_tristate_o_and2, 1, set_ld_tristate_o_t2, S_0_inv, S_1_inv, S_2, S_3_inv)
wire set_ld_tristate_o_t3;
`AND_4(set_ld_tristate_o_and3, 1, set_ld_tristate_o_t3, S_1_inv, S_2, S_3_inv, hit_i)
wire set_ld_tristate_o_t4;
`AND_5(set_ld_tristate_o_and4, 1, set_ld_tristate_o_t4, S_1_inv, S_3_inv, ld_req_i, write_req_i_inv, hit_i)

`OR_5(set_ld_tristate_o_or, 1, set_ld_tristate_o, set_ld_tristate_o_t0, set_ld_tristate_o_t1, set_ld_tristate_o_t2, set_ld_tristate_o_t3, set_ld_tristate_o_t4)

// start_store_o = (!S_0 & !S_1 & !S_2 & S_3)
`AND_4(start_store_o_and, 1, start_store_o, S_0_inv, S_1_inv, S_2_inv, S_3)

// ld_address_changed_o = (!S_0 & !S_1 & !S_2 & !S_3 & ld_req_i & !write_req_i & !hit_i)
`AND_7(ld_address_changed_o_and, 1, ld_address_changed_o, S_0_inv, S_1_inv, S_2_inv, S_3_inv, ld_req_i, write_req_i_inv, hit_i_inv)

// set_WriteBuf_V_o = (!S_0 & !S_1 & !S_2 & !S_3 & !ld_req_i & write_req_i)
`AND_6(set_WriteBuf_V_o_and, 1, set_WriteBuf_V_o, S_0_inv, S_1_inv, S_2_inv, S_3_inv, ld_req_i_inv, write_req_i)

// fill0_o = (!S_0 & !S_1 & !S_2 & !S_3 & !ld_req_i & write_req_i)
`AND_6(fill0_o_and, 1, fill0_o, S_0_inv, S_1_inv, S_2_inv, S_3_inv, ld_req_i_inv, write_req_i)

// fill1_o = (!S_0 & S_1 & S_2 & !S_3)
`AND_4(fill1_o_and, 1, fill1_o, S_0_inv, S_1, S_2, S_3_inv)

// fill2_o = (S_0 & S_1 & S_2 & !S_3)
`AND_4(fill2_o_and, 1, fill2_o, S_0, S_1, S_2, S_3_inv)

// fill3_o = (!S_0 & !S_1 & !S_2 & S_3)
`AND_4(fill3_o_and, 1, fill3_o, S_0_inv, S_1_inv, S_2_inv, S_3)

endmodule
