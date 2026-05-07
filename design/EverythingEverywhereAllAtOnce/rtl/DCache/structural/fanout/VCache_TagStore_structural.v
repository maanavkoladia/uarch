// Pure Verilog 2005 port of VCache_TagStore.
// Reference: rtl/DCache/structural/VCache_TagStore.sv
// 4-way fully associative tag store. RAM geometry preserved EXACTLY:
// 4 ways x 2 cells/way = 8 ram8b4w$ instances, address tied to 2'b0,
// tag stored as cell[0]=DIN[7:0], cell[1]={7'b0, DIN[8]}.

module VCache_TagStore (
    input  wire        clk,
    input  wire        rst,                          // active-low

    input  wire [14:0] p_addr_i,
    input  wire        oe_i,
    input  wire        we_i,

    input  wire        Read_DSWAP_i,
    input  wire [14:0] D_Cache_SwapBuf_Addr,
    input  wire        D_Cache_SwapBuf_DirtyBit,
    input  wire        DCache_Will_Evict_i,

    input  wire        saveIDX,
    input  wire        use_savedIDX,

    input  wire        busy_i,

    input  wire        WR_2_EB_i,
    input  wire        Write_VSWAP_i,

    input  wire        Update_LRU,

    output wire [8:0]  tagOut_o,                     // V_CACHE_TAG_WIDTH = 9
    output wire        hit_o,
    output wire        miss_o,

    output wire [1:0]  hitIDX_o,
    output wire [1:0]  evictionIDX_o,
    output wire [1:0]  savedIDX_o,

    output wire        currLine_Dirty_o,
    output wire        VC_Will_Need_ToEvict_o
);

    wire [8:0] p_addr_fields_tag;
    assign p_addr_fields_tag = p_addr_i[14:6];

    wire [8:0] D_Cache_SwapBuf_tag;
    assign D_Cache_SwapBuf_tag = D_Cache_SwapBuf_Addr[14:6];

    wire [3:0] tagMetaStore_valid_q;
    wire [3:0] tagMetaStore_dirty_q;

    wire [1:0] savedIDX_q;

    wire [1:0] currLRU_IDX;

    wire [3:0] saveIDX_decoded;
    `DECODER_N(u_saveIDX_dec, 2, savedIDX_q, saveIDX_decoded)

    wire clk_phase_45;
    `BUFFER_DELAY(u_phase, 12, 1, clk, clk_phase_45)

    wire [3:0] wr_event;
    wire [3:0] WR_2_TagStore_actual;
    wire [3:0] wr_event_phased;

    genvar gw;
    generate
        for (gw = 0; gw < 4; gw = gw + 1) begin : g_tagStore_WR
            `AND_2(u_wr_event, 1, wr_event[gw], saveIDX_decoded[gw], Read_DSWAP_i)
            `AND_3(u_wr_phased, 1, wr_event_phased[gw], rst, wr_event[gw], clk_phase_45)
            `INV_N(u_wr_actual, 1, wr_event_phased[gw], WR_2_TagStore_actual[gw])
        end
    endgenerate

    wire [8:0] DIN_2_TagStore;
    wire [7:0] DIN_2_TagStore_net_0;
    wire [7:0] DIN_2_TagStore_net_1;
    assign DIN_2_TagStore       = D_Cache_SwapBuf_tag;
    assign DIN_2_TagStore_net_0 = DIN_2_TagStore[7:0];
    assign DIN_2_TagStore_net_1 = {7'b0, DIN_2_TagStore[8]};

    wire [1:0] OE_2_TagStore_idx;
    wire [3:0] oe_idx_decoded;
    wire       doAccess;
    wire       oe_or_we;
    wire       not_busy;
    wire       wr2eb_or_vswap;
    wire [3:0] OE_2_TagStore;

    `MUX_2 (u_oe_idx, 2, OE_2_TagStore_idx,
            currLRU_IDX,
            savedIDX_q,
            use_savedIDX)
    `DECODER_N(u_oe_idx_dec, 2, OE_2_TagStore_idx, oe_idx_decoded)

    `OR_2  (u_oe_or_we,       1, oe_or_we, we_i, oe_i)
    `INV_N (u_not_busy,       1, busy_i, not_busy)

    // u_doAccess fanout 9 -> bufferH16$.
    wire doAccess_pre;
    `AND_2 (u_doAccess,       1, doAccess_pre, oe_or_we, not_busy)
    bufferH16$ u_doAccess_buf (.out(doAccess), .in(doAccess_pre));
    `OR_2  (u_wr2eb_or_vswap, 1, wr2eb_or_vswap, WR_2_EB_i, Write_VSWAP_i)

    genvar goe;
    generate
        for (goe = 0; goe < 4; goe = goe + 1) begin : g_tagStore_OE
            wire cond_select;
            `AND_2(u_cond_select, 1, cond_select, wr2eb_or_vswap, oe_idx_decoded[goe])
            nor2$ u_oe_actual (.out(OE_2_TagStore[goe]), .in0(doAccess), .in1(cond_select));
        end
    endgenerate

    wire [7:0] DOUT_of_TagStore_Net [0:3] [0:1];

    genvar gi, gj;
    generate
        for (gi = 0; gi < 4; gi = gi + 1) begin : g_tagStore_Entry
            for (gj = 0; gj < 2; gj = gj + 1) begin : g_tagStoreCell
                wire [7:0] DIN_select;
                if (gj == 0) begin : g_din0
                    assign DIN_select = DIN_2_TagStore_net_0;
                end else begin : g_din1
                    assign DIN_select = DIN_2_TagStore_net_1;
                end
                ram8b4w$ tagStoreCell (
                    .A   (2'b0),
                    .WR  (WR_2_TagStore_actual[gi]),
                    .DIN (DIN_select),
                    .OE  (OE_2_TagStore[gi]),
                    .DOUT(DOUT_of_TagStore_Net[gi][gj])
                );
            end
        end
    endgenerate

    wire [8:0] DOUT_of_TagStore_0, DOUT_of_TagStore_1;
    wire [8:0] DOUT_of_TagStore_2, DOUT_of_TagStore_3;
    assign DOUT_of_TagStore_0 = {DOUT_of_TagStore_Net[0][1][0], DOUT_of_TagStore_Net[0][0]};
    assign DOUT_of_TagStore_1 = {DOUT_of_TagStore_Net[1][1][0], DOUT_of_TagStore_Net[1][0]};
    assign DOUT_of_TagStore_2 = {DOUT_of_TagStore_Net[2][1][0], DOUT_of_TagStore_Net[2][0]};
    assign DOUT_of_TagStore_3 = {DOUT_of_TagStore_Net[3][1][0], DOUT_of_TagStore_Net[3][0]};

    wire [3:0] tag_eq;
    wire [3:0] way_hit;
    wire       hit;
    wire       miss;
    wire       writeSuccess;
    wire       not_hit;

    `CMP_N(u_tag_eq_0, 9, tag_eq[0], DOUT_of_TagStore_0, p_addr_fields_tag)
    `CMP_N(u_tag_eq_1, 9, tag_eq[1], DOUT_of_TagStore_1, p_addr_fields_tag)
    `CMP_N(u_tag_eq_2, 9, tag_eq[2], DOUT_of_TagStore_2, p_addr_fields_tag)
    `CMP_N(u_tag_eq_3, 9, tag_eq[3], DOUT_of_TagStore_3, p_addr_fields_tag)

    `NAND_3(u_way_hit_0, 1, way_hit[0], doAccess, tagMetaStore_valid_q[0], tag_eq[0])
    `NAND_3(u_way_hit_1, 1, way_hit[1], doAccess, tagMetaStore_valid_q[1], tag_eq[1])
    `NAND_3(u_way_hit_2, 1, way_hit[2], doAccess, tagMetaStore_valid_q[2], tag_eq[2])
    `NAND_3(u_way_hit_3, 1, way_hit[3], doAccess, tagMetaStore_valid_q[3], tag_eq[3])

    // u_hit fanout 151 -> bufferH256$.  miss (5), hitIdx[0]/[1] (5/5) -> bufferH16$.
    wire hit_pre;
    `NAND_4 (u_hit,          1, hit_pre, way_hit[0], way_hit[1], way_hit[2], way_hit[3])
    bufferH256$ u_hit_buf (.out(hit), .in(hit_pre));
    `INV_N(u_not_hit,      1, hit, not_hit)

    wire miss_pre;
    `AND_2(u_miss,         1, miss_pre, doAccess, not_hit)
    bufferH16$ u_miss_buf (.out(miss), .in(miss_pre));
    `AND_2(u_writeSuccess, 1, writeSuccess, hit, we_i)

    wire [1:0] hitIdx;
    wire       hitIdx_1_pre, hitIdx_0_pre;
    `NAND_2(u_hitIdx_1, 1, hitIdx_1_pre, way_hit[2], way_hit[3])
    `NAND_2(u_hitIdx_0, 1, hitIdx_0_pre, way_hit[1], way_hit[3])
    bufferH16$ u_hitIdx_1_buf (.out(hitIdx[1]), .in(hitIdx_1_pre));
    bufferH16$ u_hitIdx_0_buf (.out(hitIdx[0]), .in(hitIdx_0_pre));

    wire [3:0] hitIdx_decoded;
    `DECODER_N(u_hitIdx_dec, 2, hitIdx, hitIdx_decoded)

    wire [3:0] dswap_event;
    wire [3:0] ws_event;
    wire [3:0] dirty_we;
    wire [3:0] dirty_d;

    genvar gm;
    generate
        for (gm = 0; gm < 4; gm = gm + 1) begin : g_tagStore_Meta
            `AND_2(u_dswap_evt, 1, dswap_event[gm], saveIDX_decoded[gm], Read_DSWAP_i)
            `REG_RST_WE(u_valid_reg, 1, clk, rst, dswap_event[gm], 1'b1, tagMetaStore_valid_q[gm])

            `AND_2(u_ws_evt,   1, ws_event[gm], hitIdx_decoded[gm], writeSuccess)
            `OR_2 (u_dirty_we, 1, dirty_we[gm], dswap_event[gm], ws_event[gm])
            `MUX_2(u_dirty_d,  1, dirty_d[gm],
                   D_Cache_SwapBuf_DirtyBit,
                   1'b1,
                   ws_event[gm])
            `REG_RST_WE(u_dirty_reg, 1, clk, rst, dirty_we[gm], dirty_d[gm], tagMetaStore_dirty_q[gm])
        end
    endgenerate

    wire [1:0] savedIDX_d;
    `MUX_2(u_savedIDX_d, 2, savedIDX_d,
           hitIdx,
           currLRU_IDX,
           DCache_Will_Evict_i)
    // u_savedIDX Q[1] fanout 9 -> bufferH16$ on each bit (Q[0] also buffered for symmetry).
    wire [1:0] savedIDX_q_pre;
    `REG_RST_WE(u_savedIDX, 2, clk, rst, saveIDX, savedIDX_d, savedIDX_q_pre)
    bufferH16$ u_savedIDX_q0_buf (.out(savedIDX_q[0]), .in(savedIDX_q_pre[0]));
    bufferH16$ u_savedIDX_q1_buf (.out(savedIDX_q[1]), .in(savedIDX_q_pre[1]));

    LRU LRU_unit (
        .clk        (clk),
        .rst        (rst),
        .updateLRU  (Update_LRU),
        .savedIDX   (savedIDX_q),
        .currLRU_IDX(currLRU_IDX)
    );

    // u_tag_vswap_idx fanout 9/bit, u_tag_eb_idx fanout 10/bit -> bufferH16$ per bit.
    wire [1:0] tag_out_write_to_vswap_idx, tag_out_write_to_vswap_idx_pre;
    `MUX_2(u_tag_vswap_idx, 2, tag_out_write_to_vswap_idx_pre,
           hitIdx,
           savedIDX_q,
           use_savedIDX)
    bufferH16$ u_tag_vswap_idx_buf0 (.out(tag_out_write_to_vswap_idx[0]), .in(tag_out_write_to_vswap_idx_pre[0]));
    bufferH16$ u_tag_vswap_idx_buf1 (.out(tag_out_write_to_vswap_idx[1]), .in(tag_out_write_to_vswap_idx_pre[1]));

    wire [1:0] tag_out_write_to_eb_idx, tag_out_write_to_eb_idx_pre;
    `MUX_2(u_tag_eb_idx, 2, tag_out_write_to_eb_idx_pre,
           currLRU_IDX,
           savedIDX_q,
           use_savedIDX)
    bufferH16$ u_tag_eb_idx_buf0 (.out(tag_out_write_to_eb_idx[0]), .in(tag_out_write_to_eb_idx_pre[0]));
    bufferH16$ u_tag_eb_idx_buf1 (.out(tag_out_write_to_eb_idx[1]), .in(tag_out_write_to_eb_idx_pre[1]));

    wire [1:0] currLine_Dirty_idx;
    `MUX_2(u_dirty_idx, 2, currLine_Dirty_idx,
           hitIdx,
           savedIDX_q,
           use_savedIDX)

    wire [8:0] vswap_tag;
    wire [8:0] eb_tag;
    wire [8:0] tagOut_intermediate;
    `MUX_4(u_vswap_tag, 9, vswap_tag,
           DOUT_of_TagStore_0, DOUT_of_TagStore_1,
           DOUT_of_TagStore_2, DOUT_of_TagStore_3,
           tag_out_write_to_vswap_idx)
    `MUX_4(u_eb_tag,    9, eb_tag,
           DOUT_of_TagStore_0, DOUT_of_TagStore_1,
           DOUT_of_TagStore_2, DOUT_of_TagStore_3,
           tag_out_write_to_eb_idx)
    `MUX_2(u_tag_inter, 9, tagOut_intermediate,
           9'b0,
           vswap_tag,
           Write_VSWAP_i)
    `MUX_2(u_tagOut,    9, tagOut_o,
           tagOut_intermediate,
           eb_tag,
           WR_2_EB_i)

    `MUX_4(u_currDirty, 1, currLine_Dirty_o,
           tagMetaStore_dirty_q[0], tagMetaStore_dirty_q[1],
           tagMetaStore_dirty_q[2], tagMetaStore_dirty_q[3],
           currLine_Dirty_idx)

    wire lru_dirty;
    wire lru_valid;
    `MUX_4(u_lru_dirty, 1, lru_dirty,
           tagMetaStore_dirty_q[0], tagMetaStore_dirty_q[1],
           tagMetaStore_dirty_q[2], tagMetaStore_dirty_q[3],
           currLRU_IDX)
    `MUX_4(u_lru_valid, 1, lru_valid,
           tagMetaStore_valid_q[0], tagMetaStore_valid_q[1],
           tagMetaStore_valid_q[2], tagMetaStore_valid_q[3],
           currLRU_IDX)
    `AND_2(u_VC_will_evict, 1, VC_Will_Need_ToEvict_o, lru_dirty, lru_valid)

    assign hit_o         = hit;
    assign miss_o        = miss;
    assign hitIDX_o      = hitIdx;
    assign savedIDX_o    = savedIDX_q;
    assign evictionIDX_o = tag_out_write_to_eb_idx;

endmodule
