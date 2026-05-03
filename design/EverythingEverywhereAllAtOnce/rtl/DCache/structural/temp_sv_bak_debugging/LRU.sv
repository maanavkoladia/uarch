// Structural Verilog 2005 port of LRU.
// Reference SV: rtl/DCache/DCache_Block/VCache/LRU.sv
// 3 1-bit flops in a binary tree for 4-way pseudo-LRU. Bits point toward MRU;
// inverse gives LRU way. Reset clears all to 0. updateLRU latches the
// computed newLRU on the rising edge.

module LRU (
    input  wire       clk,
    input  wire       rst,                 // active-low

    input  wire       updateLRU,
    input  wire [1:0] savedIDX,            // $clog2(VCACHE_NUM_LINES) = 2

    output wire [1:0] currLRU_IDX
);

    // ---------------------------------------------------------------
    // Storage: 3 1-bit flops (matches SV `logic LRU[3]`)
    //   LRU[0] = LRU_ROOT
    //   LRU[1] = LRU_LEFT_LEAF
    //   LRU[2] = LRU_RIGHT_LEAF
    // ---------------------------------------------------------------
    wire LRU_ROOT_q;
    wire LRU_LEFT_LEAF_q;
    wire LRU_RIGHT_LEAF_q;

    // ---------------------------------------------------------------
    // Per-flop write-enable derivation (mirrors SV case at lines 33-62)
    //   ROOT       always written when updateLRU (d = savedIDX[1])
    //   LEFT_LEAF  written when updateLRU & ~savedIDX[1] (cases 00/01)
    //   RIGHT_LEAF written when updateLRU &  savedIDX[1] (cases 10/11)
    // When the gate condition is false the write is suppressed (we=0),
    // matching the SV `default: hold` for the unused leaf.
    // ---------------------------------------------------------------
    wire saved_hi_bar;
    wire we_LEFT;
    wire we_RIGHT;
    `INV_N(u_saved_hi_bar, 1, savedIDX[1], saved_hi_bar)
    `AND_2(u_we_LEFT,      1, we_LEFT,  updateLRU, saved_hi_bar)
    `AND_2(u_we_RIGHT,     1, we_RIGHT, updateLRU, savedIDX[1])

    // ---------------------------------------------------------------
    // Flops
    // ---------------------------------------------------------------
    `REG_RST_WE(u_LRU_ROOT,       1, clk, rst, updateLRU, savedIDX[1], LRU_ROOT_q)
    `REG_RST_WE(u_LRU_LEFT_LEAF,  1, clk, rst, we_LEFT,   savedIDX[0], LRU_LEFT_LEAF_q)
    `REG_RST_WE(u_LRU_RIGHT_LEAF, 1, clk, rst, we_RIGHT,  savedIDX[0], LRU_RIGHT_LEAF_q)

    // ---------------------------------------------------------------
    // Output: pseudo-LRU way index (mirrors SV lines 70-71)
    //   currLRU_IDX[1] = ~LRU_ROOT
    //   currLRU_IDX[0] = (~LRU_ROOT) ? ~LRU_RIGHT_LEAF : ~LRU_LEFT_LEAF
    //                  = MUX_2(sel=LRU_ROOT, in0=~LRU_RIGHT_LEAF, in1=~LRU_LEFT_LEAF)
    // ---------------------------------------------------------------
    wire LRU_ROOT_bar;
    wire LRU_LEFT_LEAF_bar;
    wire LRU_RIGHT_LEAF_bar;
    `INV_N(u_root_bar,  1, LRU_ROOT_q,       LRU_ROOT_bar)
    `INV_N(u_left_bar,  1, LRU_LEFT_LEAF_q,  LRU_LEFT_LEAF_bar)
    `INV_N(u_right_bar, 1, LRU_RIGHT_LEAF_q, LRU_RIGHT_LEAF_bar)

    assign currLRU_IDX[1] = LRU_ROOT_bar;
    `MUX_2(u_currLRU_lo, 1, currLRU_IDX[0],
           LRU_RIGHT_LEAF_bar,   // in0: when LRU_ROOT_q == 0
           LRU_LEFT_LEAF_bar,    // in1: when LRU_ROOT_q == 1
           LRU_ROOT_q)

endmodule
