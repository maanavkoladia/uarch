// Structural Verilog 2005 port of VCache_TagStore.
// Reference SV: rtl/DCache/DCache_Block/VCache/VCache_TagStore.sv
// 4-way fully associative tag store. RAM geometry preserved EXACTLY:
//   4 ways x 2 cells/way = 8 ram8b4w$ instances, address tied to 2'b0,
//   tag stored as cell[0]=DIN[7:0], cell[1]={7'b0, DIN[8]}.
// Per-line valid + dirty held in REG_RST_WE flops.
// LRU instance is internal to TagStore (matches SV).
// Phased clock kept as BUFFER_DELAY (NOT the duty-mask scheme).

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

    output wire [1:0]  hitIDX_o,                     // $clog2(VCACHE_NUM_LINES) = 2
    output wire [1:0]  evictionIDX_o,
    output wire [1:0]  savedIDX_o,

    output wire        currLine_Dirty_o,
    output wire        VC_Will_Need_ToEvict_o
);

    // Local sizing constants (mirror SV lines 46-47)
    //   NUM_CELLS_NEEDED = 2  (because tag is 9 bits wide)
    //   CELL_WIDTH_BITS  = 8
    //   V_CACHE_TAG_WIDTH = 9
    //   VCACHE_NUM_LINES  = 4

    // ---------------------------------------------------------------
    // p_addr field slices (mirror SV lines 59-64)
    //   tag    = p_addr_i[14:6]  (9 bits)
    //   bank   = p_addr_i[5:4]   (2 bits)
    //   offset = p_addr_i[3:0]   (4 bits)
    // ---------------------------------------------------------------
    wire [8:0] p_addr_fields_tag;
    assign p_addr_fields_tag = p_addr_i[14:6];

    // DCache_SwapBuf_lineAddr_fields.tag (mirror SV lines 66-71)
    wire [8:0] D_Cache_SwapBuf_tag;
    assign D_Cache_SwapBuf_tag = D_Cache_SwapBuf_Addr[14:6];

    // ---------------------------------------------------------------
    // Storage: per-way valid + dirty flops (4 each).
    // tagMetaStore.idx is dead state in SV (set on reset, never read) - omitted.
    // ---------------------------------------------------------------
    wire [3:0] tagMetaStore_valid_q;
    wire [3:0] tagMetaStore_dirty_q;

    // savedIDX register (2 bits)
    wire [1:0] savedIDX_q;

    // currLRU_IDX from internal LRU (forward declared)
    wire [1:0] currLRU_IDX;

    // ---------------------------------------------------------------
    // savedIDX one-hot decoder (mirrors `tagMetaStore[savedIDX]` indexing)
    //   used for per-way write enables on Read_DSWAP
    // ---------------------------------------------------------------
    wire [3:0] saveIDX_decoded;
    `DECODER_N(u_saveIDX_dec, 2, savedIDX_q, saveIDX_decoded)

    // ---------------------------------------------------------------
    // Phased clock for RAM write window (regular pattern - NOT the
    // DataStore duty-mask scheme, per user instruction).
    //   CLK_PHASE_DELAY = 2.5 ns = 10 stages of 0.25 ns
    // ---------------------------------------------------------------
    wire clk_phase_45;
    `BUFFER_DELAY(u_phase, 12, 1, clk, clk_phase_45)

    // ---------------------------------------------------------------
    // WR_2_TagStore (mirror SV lines 100-112)
    //   per-way wr_event[i] = saveIDX_decoded[i] & Read_DSWAP_i
    //   per-way WR_actual[i] = ~(rst & wr_event[i] & clk_phase_45)
    // ---------------------------------------------------------------
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

    // ---------------------------------------------------------------
    // DIN mux (mirror SV lines 118-126)
    //   DIN_2_TagStore = D_Cache_SwapBuf_lineAddr_fields.tag (9 bits)
    //   DIN_net[0] = DIN[7:0]
    //   DIN_net[1] = {7'b0, DIN[8]}
    // ---------------------------------------------------------------
    wire [8:0] DIN_2_TagStore;
    wire [7:0] DIN_2_TagStore_net_0;
    wire [7:0] DIN_2_TagStore_net_1;
    assign DIN_2_TagStore       = D_Cache_SwapBuf_tag;
    assign DIN_2_TagStore_net_0 = DIN_2_TagStore[7:0];
    assign DIN_2_TagStore_net_1 = {7'b0, DIN_2_TagStore[8]};

    // ---------------------------------------------------------------
    // OE_2_TagStore (mirror SV lines 137-147)
    //   OE_idx = use_savedIDX ? savedIDX : currLRU_IDX
    //   doAccess = (we_i | oe_i) & ~busy_i
    //   if (doAccess)            : all OE = 0 (enabled)
    //   else if (WR_2_EB | Write_VSWAP) : OE[OE_idx] = 0
    //   else                     : all OE = 1
    // Equivalent: OE_enable[i] = doAccess | (wr2eb_or_vswap & oe_idx_decoded[i])
    // ---------------------------------------------------------------
    wire [1:0] OE_2_TagStore_idx;
    wire [3:0] oe_idx_decoded;
    wire       doAccess;
    wire       oe_or_we;
    wire       not_busy;
    wire       wr2eb_or_vswap;
    wire [3:0] OE_2_TagStore;

    `MUX_2 (u_oe_idx, 2, OE_2_TagStore_idx,
            currLRU_IDX,    // in0: use_savedIDX == 0
            savedIDX_q,     // in1: use_savedIDX == 1
            use_savedIDX)
    `DECODER_N(u_oe_idx_dec, 2, OE_2_TagStore_idx, oe_idx_decoded)

    `OR_2  (u_oe_or_we,       1, oe_or_we, we_i, oe_i)
    `INV_N (u_not_busy,       1, busy_i, not_busy)

    `AND_2 (u_doAccess,       1, doAccess, oe_or_we, not_busy)
    `OR_2  (u_wr2eb_or_vswap, 1, wr2eb_or_vswap, WR_2_EB_i, Write_VSWAP_i)

    genvar goe;
    generate
        for (goe = 0; goe < 4; goe = goe + 1) begin : g_tagStore_OE
            wire cond_select;
            wire enable_oe;
            `AND_2(u_cond_select, 1, cond_select, wr2eb_or_vswap, oe_idx_decoded[goe])
            // `OR_2 (u_enable_oe,   1, enable_oe,   doAccess, cond_select)
            // `INV_N(u_oe_actual,   1, enable_oe,   OE_2_TagStore[goe])
            nor2$ u_oe_actual (.out(OE_2_TagStore[goe]), .in1(doAccess), .in1(cond_select));
        end
    endgenerate

    // ---------------------------------------------------------------
    // RAM cells - 4 ways x 2 cells per way (PRESERVE GEOMETRY EXACTLY)
    // Block names g_tagStore_Entry / g_tagStoreCell preserved from SV.
    // ---------------------------------------------------------------
    wire [7:0] DOUT_of_TagStore_Net_00, DOUT_of_TagStore_Net_01;
    wire [7:0] DOUT_of_TagStore_Net_10, DOUT_of_TagStore_Net_11;
    wire [7:0] DOUT_of_TagStore_Net_20, DOUT_of_TagStore_Net_21;
    wire [7:0] DOUT_of_TagStore_Net_30, DOUT_of_TagStore_Net_31;

    // We use a 4x2 net array via per-way concatenation; the generate
    // below preserves the SV nested-generate naming.
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

    // ---------------------------------------------------------------
    // Per-way DOUT reconstruction (mirror SV lines 153-157)
    //   DOUT_of_TagStore[i] = {DOUT_Net[i][1][0], DOUT_Net[i][0]}  (9 bits)
    // ---------------------------------------------------------------
    wire [8:0] DOUT_of_TagStore_0, DOUT_of_TagStore_1;
    wire [8:0] DOUT_of_TagStore_2, DOUT_of_TagStore_3;
    assign DOUT_of_TagStore_0 = {DOUT_of_TagStore_Net[0][1][0], DOUT_of_TagStore_Net[0][0]};
    assign DOUT_of_TagStore_1 = {DOUT_of_TagStore_Net[1][1][0], DOUT_of_TagStore_Net[1][0]};
    assign DOUT_of_TagStore_2 = {DOUT_of_TagStore_Net[2][1][0], DOUT_of_TagStore_Net[2][0]};
    assign DOUT_of_TagStore_3 = {DOUT_of_TagStore_Net[3][1][0], DOUT_of_TagStore_Net[3][0]};

    // ---------------------------------------------------------------
    // Hit detection (mirror SV lines 196-211)
    //   per-way: way_hit[i] = doAccess & valid[i] & (DOUT[i] == p_addr.tag)
    //   hit  = OR of way_hits
    //   miss = doAccess & ~hit
    //   writeSuccess = hit & we_i
    // ---------------------------------------------------------------
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

    `NAND_4 (u_hit,          1, hit, way_hit[0], way_hit[1], way_hit[2], way_hit[3])
    // `INV_N(u_not_hit,      1, hit, not_hit)
    nor4$ u_not_hit(.out(not_hit), .in0(way_hit[0]), .in1(way_hit[1]), .in2(way_hit[2]), .in3(way_hit[3]));

    `AND_2(u_miss,         1, miss, doAccess, not_hit)
    `AND_2(u_writeSuccess, 1, writeSuccess, hit, we_i)

    // hitIdx encoder: at most one way_hit can be high (unique tags), so
    //   hitIdx[1] = way_hit[2] | way_hit[3]
    //   hitIdx[0] = way_hit[1] | way_hit[3]
    wire [1:0] hitIdx;
    `OR_2(u_hitIdx_1, 1, hitIdx[1], way_hit[2], way_hit[3])
    `OR_2(u_hitIdx_0, 1, hitIdx[0], way_hit[1], way_hit[3])

    // hitIdx one-hot for writeSuccess writes
    wire [3:0] hitIdx_decoded;
    `DECODER_N(u_hitIdx_dec, 2, hitIdx, hitIdx_decoded)

    // ---------------------------------------------------------------
    // tagMetaStore valid + dirty per-way flops (mirror SV lines 161-176)
    //
    //   if (Read_DSWAP_i): valid[savedIDX] <= 1; dirty[savedIDX] <= D_Cache_SwapBuf_DirtyBit
    //   if (writeSuccess): dirty[hitIdx]   <= 1
    // (two separate if's; second non-blocking write wins when both fire)
    // ---------------------------------------------------------------
    wire [3:0] dswap_event;
    wire [3:0] ws_event;
    wire [3:0] dirty_we;
    wire [3:0] dirty_d;

    genvar gm;
    generate
        for (gm = 0; gm < 4; gm = gm + 1) begin : g_tagStore_Meta
            // valid: we = saveIDX_decoded[i] & Read_DSWAP_i, d = 1
            `AND_2(u_dswap_evt, 1, dswap_event[gm], saveIDX_decoded[gm], Read_DSWAP_i)
            `REG_RST_WE(u_valid_reg, 1, clk, rst, dswap_event[gm], 1'b1, tagMetaStore_valid_q[gm])

            // dirty: we = dswap_event | ws_event,
            //        d  = ws_event ? 1 : D_Cache_SwapBuf_DirtyBit  (ws priority)
            `AND_2(u_ws_evt,   1, ws_event[gm], hitIdx_decoded[gm], writeSuccess)
            `OR_2 (u_dirty_we, 1, dirty_we[gm], dswap_event[gm], ws_event[gm])
            `MUX_2(u_dirty_d,  1, dirty_d[gm],
                   D_Cache_SwapBuf_DirtyBit,   // in0
                   1'b1,                        // in1: when ws_event fires
                   ws_event[gm])
            `REG_RST_WE(u_dirty_reg, 1, clk, rst, dirty_we[gm], dirty_d[gm], tagMetaStore_dirty_q[gm])
        end
    endgenerate

    // ---------------------------------------------------------------
    // savedIDX register (mirror SV lines 179-187)
    //   we = saveIDX
    //   d  = DCache_Will_Evict_i ? currLRU_IDX : hitIdx
    // ---------------------------------------------------------------
    wire [1:0] savedIDX_d;
    `MUX_2(u_savedIDX_d, 2, savedIDX_d,
           hitIdx,         // in0: DCache_Will_Evict_i == 0
           currLRU_IDX,    // in1: DCache_Will_Evict_i == 1
           DCache_Will_Evict_i)
    `REG_RST_WE(u_savedIDX, 2, clk, rst, saveIDX, savedIDX_d, savedIDX_q)

    // ---------------------------------------------------------------
    // Internal LRU instance (mirror SV lines 237-243)
    // ---------------------------------------------------------------
    LRU LRU_unit (
        .clk        (clk),
        .rst        (rst),
        .updateLRU  (Update_LRU),
        .savedIDX   (savedIDX_q),
        .currLRU_IDX(currLRU_IDX)
    );

    // ---------------------------------------------------------------
    // Output muxes (mirror SV lines 251-279)
    // ---------------------------------------------------------------
    // tag_out_write_to_vswap_idx = use_savedIDX ? savedIDX : hitIdx
    wire [1:0] tag_out_write_to_vswap_idx;
    `MUX_2(u_tag_vswap_idx, 2, tag_out_write_to_vswap_idx,
           hitIdx,         // in0
           savedIDX_q,     // in1
           use_savedIDX)

    // tag_out_write_to_eb_idx = use_savedIDX ? savedIDX : currLRU_IDX
    wire [1:0] tag_out_write_to_eb_idx;
    `MUX_2(u_tag_eb_idx, 2, tag_out_write_to_eb_idx,
           currLRU_IDX,    // in0
           savedIDX_q,     // in1
           use_savedIDX)

    // currLine_Dirty_idx = use_savedIDX ? savedIDX : hitIdx
    wire [1:0] currLine_Dirty_idx;
    `MUX_2(u_dirty_idx, 2, currLine_Dirty_idx,
           hitIdx,         // in0
           savedIDX_q,     // in1
           use_savedIDX)

    // tagOut_o cascade (mirror SV lines 260-269; second `if` wins -> WR_2_EB > Write_VSWAP > 0)
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
           9'b0,        // in0: when ~Write_VSWAP_i
           vswap_tag,   // in1: when Write_VSWAP_i
           Write_VSWAP_i)
    `MUX_2(u_tagOut,    9, tagOut_o,
           tagOut_intermediate,    // in0: when ~WR_2_EB_i
           eb_tag,                  // in1: when WR_2_EB_i
           WR_2_EB_i)

    // currLine_Dirty_o = tagMetaStore[currLine_Dirty_idx].dirty
    `MUX_4(u_currDirty, 1, currLine_Dirty_o,
           tagMetaStore_dirty_q[0], tagMetaStore_dirty_q[1],
           tagMetaStore_dirty_q[2], tagMetaStore_dirty_q[3],
           currLine_Dirty_idx)

    // VC_Will_Need_ToEvict_o = tagMetaStore[currLRU_IDX].dirty & .valid
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

    // Direct outputs
    assign hit_o         = hit;
    assign miss_o        = miss;
    assign hitIDX_o      = hitIdx;
    assign savedIDX_o    = savedIDX_q;
    // evictionIDX_o = use_savedIDX ? savedIDX : currLRU_IDX (same as tag_out_write_to_eb_idx)
    assign evictionIDX_o = tag_out_write_to_eb_idx;

endmodule
