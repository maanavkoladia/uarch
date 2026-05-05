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
    // 4 replicated copies of `hit` (each driven by its own NAND_4 + bufferH64$)
    // for downstream consumers. Each copy can drive <=64 loads (covers the
    // 32 mux4 cells per group + DS group). +0.30 ns added on vcache_hit path.
    output wire [3:0]  hit_for_mux_o,
    output wire [3:0]  hit_for_DS_o,
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

    // savedIDX register quadruplicated: bit 1 fanout was 9 (decoder + 4 muxes +
    // LRU + output port). 4 parallel reg64e$ run in parallel = 0 ns.
    // After r4 we found _c at fanout 7 because output port flattens through
    // VCache_DataStore u_addr_final x4 replicas + LRU. Splitting LRU and port
    // into separate copies brings each <=4.
    //   savedIDX_q   -> u_saveIDX_dec only (4 internal decoder cells)
    //   savedIDX_q_b -> u_oe_idx, u_tag_vswap_idx, u_tag_eb_idx, u_dirty_idx (4 mux loads)
    //   savedIDX_q_c -> LRU_unit.savedIDX (3 internal LRU loads)
    //   savedIDX_q_d -> savedIDX_o output port (4 loads in DataStore u_addr_final dups)
    wire [1:0] savedIDX_q;
    wire [1:0] savedIDX_q_b;
    wire [1:0] savedIDX_q_c;
    wire [1:0] savedIDX_q_d;

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
            savedIDX_q_b,
            use_savedIDX)
    `DECODER_N(u_oe_idx_dec, 2, OE_2_TagStore_idx, oe_idx_decoded)

    `OR_2  (u_oe_or_we,       1, oe_or_we, we_i, oe_i)
    `INV_N (u_not_busy,       1, busy_i, not_busy)

    // doAccess fanout was 12 (4 g_tagStore_OE nor2$ + 4 u_way_hit + 3
    // u_way_hit_*_idx + 1 u_miss). Triplicate AND_2 = 0 ns added.
    //   doAccess   -> g_tagStore_OE x4 nor2$ inputs (4 loads, gates RAM OE)
    //   doAccess_b -> u_way_hit_0..3 (4 NAND_3)
    //   doAccess_c -> u_way_hit_1_idx..3_idx (3) + u_miss (1) = 4 loads
    // oe_or_we / not_busy fanout 1->3 (<=4 OK).
    wire doAccess_b, doAccess_c;
    `AND_2 (u_doAccess,       1, doAccess,   oe_or_we, not_busy)
    `AND_2 (u_doAccess_b,     1, doAccess_b, oe_or_we, not_busy)
    `AND_2 (u_doAccess_c,     1, doAccess_c, oe_or_we, not_busy)
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

    // way_hit[0] used only by u_hit dups (4 loads). way_hit[1..3] are also
    // used by u_hitIdx_0/1, so replicate them x2 (one for u_hit dups, one for
    // hitIdx) to keep per-net fanout <=4. 0 ns added (no buffer).
    // doAccess (4 inputs to NAND_3 below) replaced by doAccess_b for the 4
    // u_hit-feed copies and doAccess_c for the 3 _idx copies (split for fanout).
    `NAND_3(u_way_hit_0, 1, way_hit[0], doAccess_b, tagMetaStore_valid_q[0], tag_eq[0])

    wire way_hit_1_idx, way_hit_2_idx, way_hit_3_idx;
    `NAND_3(u_way_hit_1, 1, way_hit[1], doAccess_b, tagMetaStore_valid_q[1], tag_eq[1])
    `NAND_3(u_way_hit_1_idx, 1, way_hit_1_idx, doAccess_c, tagMetaStore_valid_q[1], tag_eq[1])
    `NAND_3(u_way_hit_2, 1, way_hit[2], doAccess_b, tagMetaStore_valid_q[2], tag_eq[2])
    `NAND_3(u_way_hit_2_idx, 1, way_hit_2_idx, doAccess_c, tagMetaStore_valid_q[2], tag_eq[2])
    `NAND_3(u_way_hit_3, 1, way_hit[3], doAccess_b, tagMetaStore_valid_q[3], tag_eq[3])
    `NAND_3(u_way_hit_3_idx, 1, way_hit_3_idx, doAccess_c, tagMetaStore_valid_q[3], tag_eq[3])

    // ================================================================
    // CASCADE-FIXED `hit` CHAIN (was fanout 151 single NAND_4)
    //
    // 4 NAND_4 copies + bufferH64$ on each. Each buffered copy drives one
    // partition of consumers (DataStore, mux chunks, misc). way_hit[i]
    // each get 4 loads (one per copy) <=4 OK -- no upstream cascade needed.
    // hit critical-path delay added: +0.30 ns (single bufferH64$ in series).
    //
    // hit_dup_buf[0]: misc internal (u_not_hit, u_writeSuccess, hit_o port)
    // hit_dup_buf[1]: DataStore via hit_for_DS_o (16 byte iters, replicated 4x for <=4 per net)
    // hit_dup_buf[2..3]: 32 mux chunks split as 16 chunks each
    //                   (DCache_Block uses hit_for_mux_o[k/8])
    // ================================================================
    wire [3:0] hit_dup;
    wire [3:0] hit_dup_buf;
    `NAND_4(u_hit_0, 1, hit_dup[0], way_hit[0], way_hit[1], way_hit[2], way_hit[3])
    `NAND_4(u_hit_1, 1, hit_dup[1], way_hit[0], way_hit[1], way_hit[2], way_hit[3])
    `NAND_4(u_hit_2, 1, hit_dup[2], way_hit[0], way_hit[1], way_hit[2], way_hit[3])
    `NAND_4(u_hit_3, 1, hit_dup[3], way_hit[0], way_hit[1], way_hit[2], way_hit[3])
    bufferH64$ u_hit_buf_0 (.out(hit_dup_buf[0]), .in(hit_dup[0]));
    bufferH64$ u_hit_buf_1 (.out(hit_dup_buf[1]), .in(hit_dup[1]));
    bufferH64$ u_hit_buf_2 (.out(hit_dup_buf[2]), .in(hit_dup[2]));
    bufferH64$ u_hit_buf_3 (.out(hit_dup_buf[3]), .in(hit_dup[3]));

    // hit (misc): drives u_not_hit, u_writeSuccess, output hit_o
    assign hit = hit_dup_buf[0];

    // 4 hit copies for VCache_DataStore byte groups (1 group = 4 byte iters)
    // (parent VCache routes hit_for_DS_o[3:0] to VCache_DataStore.tagStore_hit_i[3:0])
    assign hit_for_DS_o = {4{hit_dup_buf[1]}};

    // 4 hit copies for the 32 MUX_4 chunks in DCache_Block
    // Each hit_for_mux_o[k] is reused across 8 of the 32 chunks (k = chunk_idx/8)
    assign hit_for_mux_o[0] = hit_dup_buf[0];
    assign hit_for_mux_o[1] = hit_dup_buf[1];
    assign hit_for_mux_o[2] = hit_dup_buf[2];
    assign hit_for_mux_o[3] = hit_dup_buf[3];

    `INV_N(u_not_hit,      1, hit, not_hit)

    // u_miss fanout=13 (drives FSM V_Miss_i + various flat consumers). bufferH16$
    // at output -- +0.24 ns. Off read-hit critical path (FSM transitions / miss
    // signaling), parallel with downstream hit-data routing.
    wire miss_pre;
    `AND_2(u_miss,         1, miss_pre, doAccess_c, not_hit)
    bufferH16$ u_miss_buf (.out(miss), .in(miss_pre));
    `AND_2(u_writeSuccess, 1, writeSuccess, hit, we_i)

    // hitIdx is on the read critical path (drives DataStore addr select via
    // hitIDX_o port). Each NAND_2 fanout was 5 (savedIDX mux + 3 tag muxes
    // + hitIDX_o port that flattens externally). Replicate x2 = 0 ns -- both
    // copies run in parallel; way_hit_*_idx fanout grows 1->2 (<=4 OK).
    wire [1:0] hitIdx;
    wire [1:0] hitIdx_b;
    `NAND_2(u_hitIdx_1,   1, hitIdx[1],   way_hit_2_idx, way_hit_3_idx)
    `NAND_2(u_hitIdx_0,   1, hitIdx[0],   way_hit_1_idx, way_hit_3_idx)
    `NAND_2(u_hitIdx_1_b, 1, hitIdx_b[1], way_hit_2_idx, way_hit_3_idx)
    `NAND_2(u_hitIdx_0_b, 1, hitIdx_b[0], way_hit_1_idx, way_hit_3_idx)

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
    `REG_RST_WE(u_savedIDX,    2, clk, rst, saveIDX, savedIDX_d, savedIDX_q)
    `REG_RST_WE(u_savedIDX_qb, 2, clk, rst, saveIDX, savedIDX_d, savedIDX_q_b)
    // savedIDX_q_c[1] still showed fanout=7 because LRU's MPS_reg_rst_we$
    // expansion exposes more leaves than the apparent 3 internal LRU loads.
    // bufferH16$ on bit 1 only -- +0.24 ns on LRU update path (off cache
    // read-hit critical path; LRU is replacement-policy state).
    wire [1:0] savedIDX_q_c_pre;
    `REG_RST_WE(u_savedIDX_qc, 2, clk, rst, saveIDX, savedIDX_d, savedIDX_q_c_pre)
    assign savedIDX_q_c[0] = savedIDX_q_c_pre[0];
    bufferH16$ u_savedIDX_qc_b1_buf (.out(savedIDX_q_c[1]), .in(savedIDX_q_c_pre[1]));
    `REG_RST_WE(u_savedIDX_qd, 2, clk, rst, saveIDX, savedIDX_d, savedIDX_q_d)

    LRU LRU_unit (
        .clk        (clk),
        .rst        (rst),
        .updateLRU  (Update_LRU),
        .savedIDX   (savedIDX_q_c),
        .currLRU_IDX(currLRU_IDX)
    );

    // u_tag_vswap_idx / u_tag_eb_idx: mux2$ output drives MUX_4(width=9) select
    // (9 internal mux4$ cells per select bit). fanout=9 violates -- bufferH16$
    // at output. +0.24 ns on the EB/VSWAP write path -- NOT on the read-hit
    // critical path (tag_eq path uses `tagOut_o` which goes via u_tagOut MUX_2).
    wire [1:0] tag_out_write_to_vswap_idx_pre;
    `MUX_2(u_tag_vswap_idx, 2, tag_out_write_to_vswap_idx_pre,
           hitIdx_b,
           savedIDX_q_b,
           use_savedIDX)
    wire [1:0] tag_out_write_to_vswap_idx;
    bufferH16$ u_tag_vswap_idx_buf0 (.out(tag_out_write_to_vswap_idx[0]), .in(tag_out_write_to_vswap_idx_pre[0]));
    bufferH16$ u_tag_vswap_idx_buf1 (.out(tag_out_write_to_vswap_idx[1]), .in(tag_out_write_to_vswap_idx_pre[1]));

    wire [1:0] tag_out_write_to_eb_idx_pre;
    `MUX_2(u_tag_eb_idx, 2, tag_out_write_to_eb_idx_pre,
           currLRU_IDX,
           savedIDX_q_b,
           use_savedIDX)
    wire [1:0] tag_out_write_to_eb_idx;
    bufferH16$ u_tag_eb_idx_buf0 (.out(tag_out_write_to_eb_idx[0]), .in(tag_out_write_to_eb_idx_pre[0]));
    bufferH16$ u_tag_eb_idx_buf1 (.out(tag_out_write_to_eb_idx[1]), .in(tag_out_write_to_eb_idx_pre[1]));

    wire [1:0] currLine_Dirty_idx;
    `MUX_2(u_dirty_idx, 2, currLine_Dirty_idx,
           hitIdx,
           savedIDX_q_b,
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
    assign hitIDX_o      = hitIdx_b;
    // savedIDX_o output port driven by savedIDX_q_d (dedicated copy).
    // The output flattens through VCache_DataStore u_addr_final x4 replicas
    // -> 4 loads on bit 1. Keeping LRU on savedIDX_q_c, port on _d separates
    // them so each <=4 loads.
    assign savedIDX_o    = savedIDX_q_d;
    assign evictionIDX_o = tag_out_write_to_eb_idx;

endmodule
