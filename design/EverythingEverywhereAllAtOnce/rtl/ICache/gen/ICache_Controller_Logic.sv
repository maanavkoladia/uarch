// ======================================================================
// FSM : ICache_Controller_Logic
// Tool: fsm2rtl.py  (auto-generated -- do not hand-edit)
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
// -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//         S_0         S_1         S_2   IC_miss_i  I_VC_Miss_i  mem_valid_i        en_i  |        NS_0        NS_1        NS_2  LD_IC_SWAP_BUF_o  RD_I_VC_SWAP_BUF_o      busy_o  saveAddress_o  UseSavedAddr_o   MakeReq_o   Fill0EN_o   Fill1EN_o   Fill2EN_o   Fill3EN_o   transition
// -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//           0           0           0           x           x           x           0  |           0           0           0           0           0           0           1           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           0           0           x           x           1  |           0           0           0           0           0           0           1           0           0           0           0           0           0   IDLE -> IDLE
//           0           0           0           1           1           x           1  |           1           0           0           0           0           0           1           0           0           0           0           0           0   IDLE -> Fill0
//           0           0           0           1           0           x           1  |           1           0           1           1           0           0           1           0           0           0           0           0           0   IDLE -> SWAP
//           1           0           1           x           x           x           x  |           0           0           0           0           1           1           0           1           0           0           0           0           0   SWAP -> IDLE
//           1           0           0           x           x           0           x  |           1           0           0           0           0           1           0           1           1           0           0           0           0   Fill0 -> Fill0
//           1           0           0           x           x           1           x  |           0           1           0           0           0           1           0           1           0           1           0           0           0   Fill0 -> Fill1
//           0           1           0           x           x           0           x  |           0           1           0           0           0           1           0           1           0           0           0           0           0   Fill1 -> Fill1
//           0           1           0           x           x           1           x  |           1           1           0           0           0           1           0           1           0           0           1           0           0   Fill1 -> Fill2
//           1           1           0           x           x           0           x  |           1           1           0           0           0           1           0           1           0           0           0           0           0   Fill2 -> Fill2
//           1           1           0           x           x           1           x  |           0           0           1           0           0           1           0           1           0           0           0           1           0   Fill2 -> Fill3
//           0           0           1           x           x           0           x  |           0           0           1           0           0           1           0           1           0           0           0           0           0   Fill3 -> Fill3
//           0           0           1           x           x           1           x  |           0           0           0           0           0           1           0           1           0           0           0           0           1   Fill3 -> IDLE
// -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
    output wire saveAddress_o,
    output wire UseSavedAddr_o,
    output wire MakeReq_o,
    output wire Fill0EN_o,
    output wire Fill1EN_o,
    output wire Fill2EN_o,
    output wire Fill3EN_o
);

// Next-state wires  (NS_0=LSB ... NS_{N-1}=MSB)
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
wire I_VC_Miss_i_inv;
wire S_0_inv;
wire S_1_inv;
wire S_2_inv;
wire mem_valid_i_inv;

inv1$ inv_I_VC_Miss_i (I_VC_Miss_i_inv, I_VC_Miss_i);
inv1$ inv_S_0 (S_0_inv, S_0);
inv1$ inv_S_1 (S_1_inv, S_1);
inv1$ inv_S_2 (S_2_inv, S_2);
inv1$ inv_mem_valid_i (mem_valid_i_inv, mem_valid_i);

// Next-state and output SOP logic

// NS_0 = (S_0 & !S_2 & !mem_valid_i) | (!S_0 & S_1 & !S_2 & mem_valid_i) | (!S_0 & !S_1 & !S_2 & IC_miss_i & en_i)
wire NS_0_t0;
wire NS_0_t1;
wire NS_0_t2;

and3$ NS_0_and0 (NS_0_t0, S_0, S_2_inv, mem_valid_i_inv);
and4$ NS_0_and1 (NS_0_t1, S_0_inv, S_1, S_2_inv, mem_valid_i);
and5$ NS_0_and2 (NS_0_t2, S_0_inv, S_1_inv, S_2_inv, IC_miss_i, en_i);
or3$  NS_0_or  (NS_0, NS_0_t0, NS_0_t1, NS_0_t2);

// NS_1 = (!S_0 & S_1) | (S_1 & !S_2 & !mem_valid_i) | (S_0 & !S_1 & !S_2 & mem_valid_i)
wire NS_1_t0;
wire NS_1_t1;
wire NS_1_t2;

and2$ NS_1_and0 (NS_1_t0, S_0_inv, S_1);
and3$ NS_1_and1 (NS_1_t1, S_1, S_2_inv, mem_valid_i_inv);
and4$ NS_1_and2 (NS_1_t2, S_0, S_1_inv, S_2_inv, mem_valid_i);
or3$  NS_1_or  (NS_1, NS_1_t0, NS_1_t1, NS_1_t2);

// NS_2 = (!S_0 & S_1 & S_2) | (!S_0 & S_2 & !mem_valid_i) | (S_0 & S_1 & !S_2 & mem_valid_i) | (!S_0 & !S_1 & !S_2 & IC_miss_i & !I_VC_Miss_i & en_i)
wire NS_2_t0;
wire NS_2_t1;
wire NS_2_t2;
wire NS_2_t3;

and3$ NS_2_and0 (NS_2_t0, S_0_inv, S_1, S_2);
and3$ NS_2_and1 (NS_2_t1, S_0_inv, S_2, mem_valid_i_inv);
and4$ NS_2_and2 (NS_2_t2, S_0, S_1, S_2_inv, mem_valid_i);
and6$ NS_2_and3 (NS_2_t3, S_0_inv, S_1_inv, S_2_inv, IC_miss_i, I_VC_Miss_i_inv, en_i);
or4$  NS_2_or  (NS_2, NS_2_t0, NS_2_t1, NS_2_t2, NS_2_t3);

// LD_IC_SWAP_BUF_o = (!S_0 & !S_1 & !S_2 & IC_miss_i & !I_VC_Miss_i & en_i)
and6$ LD_IC_SWAP_BUF_o_and (LD_IC_SWAP_BUF_o, S_0_inv, S_1_inv, S_2_inv, IC_miss_i, I_VC_Miss_i_inv, en_i);

// RD_I_VC_SWAP_BUF_o = (S_0 & !S_1 & S_2)
and3$ RD_I_VC_SWAP_BUF_o_and (RD_I_VC_SWAP_BUF_o, S_0, S_1_inv, S_2);

// busy_o = (!S_1 & S_2) | (S_1 & !S_2) | (S_0 & !S_2)
wire busy_o_t0;
wire busy_o_t1;
wire busy_o_t2;

and2$ busy_o_and0 (busy_o_t0, S_1_inv, S_2);
and2$ busy_o_and1 (busy_o_t1, S_1, S_2_inv);
and2$ busy_o_and2 (busy_o_t2, S_0, S_2_inv);
or3$  busy_o_or  (busy_o, busy_o_t0, busy_o_t1, busy_o_t2);

// saveAddress_o = (!S_0 & !S_1 & !S_2)
and3$ saveAddress_o_and (saveAddress_o, S_0_inv, S_1_inv, S_2_inv);

// UseSavedAddr_o = (!S_1 & S_2) | (S_1 & !S_2) | (S_0 & !S_2)
wire UseSavedAddr_o_t0;
wire UseSavedAddr_o_t1;
wire UseSavedAddr_o_t2;

and2$ UseSavedAddr_o_and0 (UseSavedAddr_o_t0, S_1_inv, S_2);
and2$ UseSavedAddr_o_and1 (UseSavedAddr_o_t1, S_1, S_2_inv);
and2$ UseSavedAddr_o_and2 (UseSavedAddr_o_t2, S_0, S_2_inv);
or3$  UseSavedAddr_o_or  (UseSavedAddr_o, UseSavedAddr_o_t0, UseSavedAddr_o_t1, UseSavedAddr_o_t2);

// MakeReq_o = (S_0 & !S_1 & !S_2 & !mem_valid_i)
and4$ MakeReq_o_and (MakeReq_o, S_0, S_1_inv, S_2_inv, mem_valid_i_inv);

// Fill0EN_o = (S_0 & !S_1 & !S_2 & mem_valid_i)
and4$ Fill0EN_o_and (Fill0EN_o, S_0, S_1_inv, S_2_inv, mem_valid_i);

// Fill1EN_o = (!S_0 & S_1 & !S_2 & mem_valid_i)
and4$ Fill1EN_o_and (Fill1EN_o, S_0_inv, S_1, S_2_inv, mem_valid_i);

// Fill2EN_o = (S_0 & S_1 & !S_2 & mem_valid_i)
and4$ Fill2EN_o_and (Fill2EN_o, S_0, S_1, S_2_inv, mem_valid_i);

// Fill3EN_o = (!S_0 & !S_1 & S_2 & mem_valid_i)
and4$ Fill3EN_o_and (Fill3EN_o, S_0_inv, S_1_inv, S_2, mem_valid_i);

endmodule
