// Structural Verilog-2005 port of rtl/DCache/DCache_Block/VCache/LRU.sv
//
// Tree-PLRU for a 4-way associative VCache.
//   LRU_q[0]=ROOT, LRU_q[1]=LEFT_LEAF, LRU_q[2]=RIGHT_LEAF
// Each tree-bit points TOWARD the MRU subtree.


module LRU (
    input  wire                                clk,
    input  wire                                rst,
    input  wire                                updateLRU,
    input  wire [`VCACHE_LINE_IDX_W - 1 : 0]   savedIDX,
    output wire [`VCACHE_LINE_IDX_W - 1 : 0]   currLRU_IDX
);

    wire [2:0] LRU_q;
    wire [2:0] newLRU;

    wire savedIDX_1_inv;
    wire LRU_root_inv;
    wire LRU_leftLeaf_inv;
    wire LRU_rightLeaf_inv;

    `INV_N(inv_savedIDX1, 1, savedIDX[1], savedIDX_1_inv)
    `INV_N(inv_LRU_root,  1, LRU_q[0],    LRU_root_inv)
    `INV_N(inv_LRU_left,  1, LRU_q[1],    LRU_leftLeaf_inv)
    `INV_N(inv_LRU_right, 1, LRU_q[2],    LRU_rightLeaf_inv)

    // newLRU[0] = savedIDX[1]
    assign newLRU[0] = savedIDX[1];

    // newLRU[1] = ~savedIDX[1] ? savedIDX[0] : LRU_q[1]
    `MUX_2(mux_left_leaf,  1, newLRU[1], LRU_q[1], savedIDX[0], savedIDX_1_inv)

    // newLRU[2] = savedIDX[1]  ? savedIDX[0] : LRU_q[2]
    `MUX_2(mux_right_leaf, 1, newLRU[2], LRU_q[2], savedIDX[0], savedIDX[1])

    `REG_RST_WE(lru_ff, 3, clk, rst, updateLRU, newLRU, LRU_q)

    // currLRU_IDX[1] = ~LRU_q[ROOT]
    assign currLRU_IDX[1] = LRU_root_inv;
    // currLRU_IDX[0] = ~LRU_q[ROOT] ? ~LRU_q[RIGHT_LEAF] : ~LRU_q[LEFT_LEAF]
    `MUX_2(mux_currIDX0, 1, currLRU_IDX[0], LRU_leftLeaf_inv, LRU_rightLeaf_inv, LRU_root_inv)

endmodule
