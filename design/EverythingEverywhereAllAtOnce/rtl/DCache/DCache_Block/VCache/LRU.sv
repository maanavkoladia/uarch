import common_pkg::*;
import DCache_common_pkg::*;

module LRU (
    input wire clk,
    input wire rst,

    input logic updateLRU,

    input logic [$clog(VCACHE_NUM_LINES) - 1 : 0] savedIDX,

    output logic [$clog(VCACHE_NUM_LINES) - 1 : 0] currLRU_IDX

);
    localparam int NUM_LRU_BITS = 3;
    localparam int LRU_ROOT = 0;
    localparam int LRU_LEFT_LEAF = 1;
    localparam int LRU_RIGHT_LEAF = 2;

    logic LRU[NUM_LRU_BITS];

    //LRU logic, this is handled by the fsm, the idea is that when we write
    //into the the vcache, ie Read_DSWAP_i is high, we update the lru, if we
    //get a hit, the LRU bits need to be update, somethign interesting that
    //happens here is that if we get a hit here, we will go through a swap
    //mechanism, so im aussuming that the incoming line, which will be put
    //where
    //we got the hit, this line is no longer the lru, this shoudl become the
    //mru

    logic newLRU;

    always_comb begin
        //no latches, update on hit, not on swap bc redudant with hit, this
        //comes from hit idx
        //update if loading eb, means that a new lines is goig to be written
        //to the LRU, so LRU  is new MRU
        //cant rely on LD_EB_i signal because dont always needs to evict
        newLRU = tagMetaStore.LRU;  //the meta store stores the MRU which is used to find LRU
        // update_idx = DCache_Will_Evict_i ? currLRU_IDX : hitIdx;
        // Update LRU tree to mark accessed way as MRU (bits point toward MRU)
        case (savedIDX)
            2'b00: begin  // Way 0 accessed - point to left/left
                newLRU[LRU_ROOT]      = 1'b0;  // Point to left subtree
                newLRU[LRU_LEFT_LEAF] = 1'b0;  // Point to way 0
            end
            2'b01: begin  // Way 1 accessed - point to left/right
                newLRU[LRU_ROOT]      = 1'b0;  // Point to left subtree
                newLRU[LRU_LEFT_LEAF] = 1'b1;  // Point to way 1
            end
            2'b10: begin  // Way 2 accessed - point to right/left
                newLRU[LRU_ROOT]       = 1'b1;  // Point to right subtree
                newLRU[LRU_RIGHT_LEAF] = 1'b0;  // Point to way 2
            end
            2'b11: begin  // Way 3 accessed - point to right/right
                newLRU[LRU_ROOT]       = 1'b1;  // Point to right subtree
                newLRU[LRU_RIGHT_LEAF] = 1'b1;  // Point to way 3
            end
            default: if (rst) $fatal;
        endcase

    end

    always_ff @(posedge clk) begin
        if (!rst) LRU <= '0;
        else if (updateLRU) LRU <= newLRU;
    end

    ////////MODULE OUTPUTS///////////////////
    assign currLRU_IDX[1] = !tagMetaStore.LRU[LRU_ROOT];
    assign currLRU_IDX[0] = !tagMetaStore.LRU[LRU_ROOT] ? !tagMetaStore.LRU[LRU_RIGHT_LEAF] : !tagMetaStore.LRU[LRU_LEFT_LEAF];

endmodule
