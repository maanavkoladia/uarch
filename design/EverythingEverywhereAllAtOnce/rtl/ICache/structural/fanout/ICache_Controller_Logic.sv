// ======================================================================
// FSM : ICache_Controller_Logic
// Tool: fsm2rtl.py  (auto-generated -- hand-edited in fanout/ for fanout fixes)
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
// Fanout fixes vs. the gen/ original:
//   - ff_0, ff_1, ff_2 are triplicated (ff_X_a/b/c) so each copy drives <=4 in-FSM loads.
//     The 9-load original violation per state bit is split 3-3-3.
//   - busy_o (fanout 37 in check.log): bufferH64$ inserted between busy_o_nand and the port.
//   - RD_I_VC_SWAP_BUF_o (fanout 134): bufferH256$ inserted between the AND_3 and the port.

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

// ----------------------------------------------------------------
// State flip-flops -- TRIPLICATED (3 copies each).
// All copies share the same NS_X / clk / rst and reset to 0, so they
// stay synchronized. Distributing the 9 in-FSM loads of each state
// bit across S_X_a/b/c brings each per-copy fanout to <=4 (no buffer
// rule violation).
// ----------------------------------------------------------------
wire S_0_a, S_0_b, S_0_c;
wire S_1_a, S_1_b, S_1_c;
wire S_2_a, S_2_b, S_2_c;

`REG_RST(ff_0_a, 1, clk, rst, NS_0, S_0_a)
`REG_RST(ff_0_b, 1, clk, rst, NS_0, S_0_b)
`REG_RST(ff_0_c, 1, clk, rst, NS_0, S_0_c)
`REG_RST(ff_1_a, 1, clk, rst, NS_1, S_1_a)
`REG_RST(ff_1_b, 1, clk, rst, NS_1, S_1_b)
`REG_RST(ff_1_c, 1, clk, rst, NS_1, S_1_c)
`REG_RST(ff_2_a, 1, clk, rst, NS_2, S_2_a)
`REG_RST(ff_2_b, 1, clk, rst, NS_2, S_2_b)
`REG_RST(ff_2_c, 1, clk, rst, NS_2, S_2_c)

// External S_x ports drive from copy A (single low-fanout external use).
assign S_0 = S_0_a;
assign S_1 = S_1_a;
assign S_2 = S_2_a;

// ----------------------------------------------------------------
// Inverters for negated literals.
// (inv_N$ -> bufferHInv64$ in synth, so per-inverter fanout is fine
// up to 64.) Each state-bit gets its own inverter; we distribute the
// downstream uses among them.
// ----------------------------------------------------------------
wire I_VC_Miss_i_inv;
wire S_0_a_inv, S_0_b_inv, S_0_c_inv;
wire S_1_a_inv, S_1_b_inv, S_1_c_inv;
wire S_2_a_inv, S_2_b_inv, S_2_c_inv;
wire mem_valid_i_inv;

`INV_N(inv_I_VC_Miss_i, 1, I_VC_Miss_i, I_VC_Miss_i_inv)
`INV_N(inv_S_0_a, 1, S_0_a, S_0_a_inv)
`INV_N(inv_S_0_b, 1, S_0_b, S_0_b_inv)
`INV_N(inv_S_0_c, 1, S_0_c, S_0_c_inv)
`INV_N(inv_S_1_a, 1, S_1_a, S_1_a_inv)
`INV_N(inv_S_1_b, 1, S_1_b, S_1_b_inv)
`INV_N(inv_S_1_c, 1, S_1_c, S_1_c_inv)
`INV_N(inv_S_2_a, 1, S_2_a, S_2_a_inv)
`INV_N(inv_S_2_b, 1, S_2_b, S_2_b_inv)
`INV_N(inv_S_2_c, 1, S_2_c, S_2_c_inv)
`INV_N(inv_mem_valid_i, 1, mem_valid_i, mem_valid_i_inv)

// ----------------------------------------------------------------
// Next-state and output SOP logic.
// The original gen/ FSM used S_0/S_1/S_2 (and their _inv forms) ONCE
// per term. Here we route each occurrence to a specific copy (a, b, c)
// so the per-copy fanout is balanced (~3 loads each).
// ----------------------------------------------------------------

// NS_0 = (S_0 & !S_2 & !mem_valid_i) | (!S_0 & S_1 & !S_2 & mem_valid_i) | (!S_0 & !S_1 & !S_2 & IC_miss_i & en_i)
wire NS_0_t0;
`AND_3(NS_0_and0, 1, NS_0_t0, S_0_a, S_2_a_inv, mem_valid_i_inv)
wire NS_0_t1;
`AND_4(NS_0_and1, 1, NS_0_t1, S_0_a_inv, S_1_a, S_2_a_inv, mem_valid_i)
wire NS_0_t2;
`AND_5(NS_0_and2, 1, NS_0_t2, S_0_a_inv, S_1_a_inv, S_2_a_inv, IC_miss_i, en_i)

`OR_3(NS_0_or, 1, NS_0, NS_0_t0, NS_0_t1, NS_0_t2)

// NS_1 = (!S_0 & S_1) | (S_1 & !S_2 & !mem_valid_i) | (S_0 & !S_1 & !S_2 & mem_valid_i)
wire NS_1_n0;
`NAND_2(NS_1_nand0, 1, NS_1_n0, S_0_b_inv, S_1_b)
wire NS_1_n1;
`NAND_3(NS_1_nand1, 1, NS_1_n1, S_1_b, S_2_b_inv, mem_valid_i_inv)
wire NS_1_n2;
`NAND_4(NS_1_nand2, 1, NS_1_n2, S_0_b, S_1_b_inv, S_2_b_inv, mem_valid_i)

`NAND_3(NS_1_nand, 1, NS_1, NS_1_n0, NS_1_n1, NS_1_n2)

// NS_2 = (!S_0 & S_1 & S_2) | (!S_0 & S_2 & !mem_valid_i) | (S_0 & S_1 & !S_2 & mem_valid_i) | (!S_0 & !S_1 & !S_2 & IC_miss_i & !I_VC_Miss_i & en_i)
wire NS_2_t0;
`AND_3(NS_2_and0, 1, NS_2_t0, S_0_c_inv, S_1_c, S_2_c)
wire NS_2_t1;
`AND_3(NS_2_and1, 1, NS_2_t1, S_0_c_inv, S_2_c, mem_valid_i_inv)
wire NS_2_t2;
`AND_4(NS_2_and2, 1, NS_2_t2, S_0_c, S_1_c, S_2_c_inv, mem_valid_i)
wire NS_2_t3;
`AND_6(NS_2_and3, 1, NS_2_t3, S_0_c_inv, S_1_c_inv, S_2_c_inv, IC_miss_i, I_VC_Miss_i_inv, en_i)

`OR_4(NS_2_or, 1, NS_2, NS_2_t0, NS_2_t1, NS_2_t2, NS_2_t3)

// LD_IC_SWAP_BUF_o = (!S_0 & !S_1 & !S_2 & IC_miss_i & en_i)
`AND_5(LD_IC_SWAP_BUF_o_and, 1, LD_IC_SWAP_BUF_o, S_0_a_inv, S_1_a_inv, S_2_a_inv, IC_miss_i, en_i)

// ----------------------------------------------------------------
// RD_I_VC_SWAP_BUF_o (fanout 134 in original) -- the gate output
// drives ~134 leaf-cell loads after hierarchical flattening.
// Compute as before, then re-buffer with bufferH256$ from lib2.
// ----------------------------------------------------------------
wire RD_I_VC_SWAP_BUF_o_pre;
`AND_3(RD_I_VC_SWAP_BUF_o_and, 1, RD_I_VC_SWAP_BUF_o_pre, S_0_b, S_1_b_inv, S_2_b)
bufferH256$ u_RD_I_VC_SWAP_BUF_o_buf (
    .out(RD_I_VC_SWAP_BUF_o),
    .in (RD_I_VC_SWAP_BUF_o_pre)
);

// ----------------------------------------------------------------
// busy_o (fanout 37 in original) -- re-buffer with bufferH64$ from lib2.
//   busy_o = (S_0 & !S_1) | (S_1 & !S_2) | (!S_1 & S_2)
// ----------------------------------------------------------------
wire busy_o_n0;
`NAND_2(busy_o_nand0, 1, busy_o_n0, S_0_b, S_1_a_inv)
wire busy_o_n1;
`NAND_2(busy_o_nand1, 1, busy_o_n1, S_1_b, S_2_a_inv)
wire busy_o_n2;
`NAND_2(busy_o_nand2, 1, busy_o_n2, S_1_c_inv, S_2_b)

wire busy_o_pre;
`NAND_3(busy_o_nand, 1, busy_o_pre, busy_o_n0, busy_o_n1, busy_o_n2)
// busy fanout after round 1 measured ~101 leaf loads (TagStore, DataStore,
// I_VCache, plus local logic). bufferH64$ wasn't big enough; upgrade to
// bufferH256$ (tier-256 covers 65..256).
bufferH256$ u_busy_o_buf (
    .out(busy_o),
    .in (busy_o_pre)
);

// MakeReq_o = (S_0 & !S_1 & !S_2 & !mem_valid_i)
`AND_4(MakeReq_o_and, 1, MakeReq_o, S_0_c, S_1_c_inv, S_2_b_inv, mem_valid_i_inv)

// Fill0EN_o = (S_0 & !S_1 & !S_2 & mem_valid_i)
`AND_4(Fill0EN_o_and, 1, Fill0EN_o, S_0_c, S_1_c_inv, S_2_c_inv, mem_valid_i)

// Fill1EN_o = (!S_0 & S_1 & !S_2 & mem_valid_i)
`AND_4(Fill1EN_o_and, 1, Fill1EN_o, S_0_b_inv, S_1_c, S_2_b_inv, mem_valid_i)

// Fill2EN_o = (S_0 & S_1 & !S_2 & mem_valid_i)
`AND_4(Fill2EN_o_and, 1, Fill2EN_o, S_0_a, S_1_a, S_2_c_inv, mem_valid_i)

// Fill3EN_o = (!S_0 & !S_1 & S_2 & mem_valid_i)
// Fanout went to 5 after round 1 (TagStore/DataStore each split fill3_i loads).
// Re-buffer with bufferH16$ from lib2 to clear the tier-16 rule.
wire Fill3EN_o_pre;
`AND_4(Fill3EN_o_and, 1, Fill3EN_o_pre, S_0_c_inv, S_1_b_inv, S_2_a, mem_valid_i)
bufferH16$ u_Fill3EN_o_buf (.out(Fill3EN_o), .in(Fill3EN_o_pre));

endmodule
