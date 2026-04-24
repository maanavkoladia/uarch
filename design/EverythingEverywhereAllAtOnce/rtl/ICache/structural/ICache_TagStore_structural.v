

module ICache_TagStore (
    input  wire        clk,
    input  wire        rst,
    input  wire        en,
    input  wire [31:0] v_addr_i,
    input  wire        ld_From_I_VC_Swap,
    input  wire        LD_IC_SWAP_BUF,
    input  wire        fill3_i,
    input  wire        busy,

    // I_VC_SwapBuf_i (decomposed) - declared for interface parity, unused internally
    input  wire         I_VC_SwapBuf_i_valid,
    input  wire [31:0]  I_VC_SwapBuf_i_lineAddr,
    input  wire [127:0] I_VC_SwapBuf_i_line,

    output wire [23:0] currTag_o,
    output wire        currLine_V
);

    // ------------------------------------------------------------------
    // Address decomposition (pure wire slices)
    // ------------------------------------------------------------------
    wire [23:0] v_addr_tag;
    wire [3:0]  v_addr_index;
    wire [2:0]  addr_2_store;
    wire        tagCellOutSel;

    assign v_addr_tag    = v_addr_i[31:8];
    assign v_addr_index  = v_addr_i[7:4];
    assign addr_2_store  = v_addr_index[2:0];
    assign tagCellOutSel = v_addr_index[3];

    // ------------------------------------------------------------------
    // Phased clock (10 stages * 0.25 ns = 2.5 ns)
    // ------------------------------------------------------------------
    wire clk_45_phase;
    `BUFFER_DELAY(u_phase_buf, 10, 1, clk, clk_45_phase)

    // ------------------------------------------------------------------
    // WR logic (per layer, active-low to RAM). WR_actual[0]=L0, [1]=L1.
    // ------------------------------------------------------------------
    wire [1:0] WR_actual;

    wire tagCellOutSel_bar;
    wire or_f3_vc;
    wire sel0, sel1;
    wire sel0_gated, sel1_gated;
    wire gate0, gate1;

    `INV_N(u_selbar, 1, tagCellOutSel, tagCellOutSel_bar)
    `OR_2 (u_or_f3, 1, or_f3_vc, fill3_i, ld_From_I_VC_Swap)

    `AND_3(u_sel0, 1, sel0, tagCellOutSel_bar, or_f3_vc, en)
    `AND_3(u_sel1, 1, sel1, tagCellOutSel,     or_f3_vc, en)

    `AND_2(u_sel0g, 1, sel0_gated, sel0, rst)
    `AND_2(u_sel1g, 1, sel1_gated, sel1, rst)

    `AND_2(u_gate0, 1, gate0, clk_45_phase, sel0_gated)
    `AND_2(u_gate1, 1, gate1, clk_45_phase, sel1_gated)

    `INV_N(u_wra0, 1, gate0, WR_actual[0])
    `INV_N(u_wra1, 1, gate1, WR_actual[1])

    // ------------------------------------------------------------------
    // DIN (always the incoming v_addr tag)
    // ------------------------------------------------------------------
    wire [23:0] DIN_2_TagStore;
    assign DIN_2_TagStore = v_addr_tag;

    // ------------------------------------------------------------------
    // OE (active-low to RAM)
    // ------------------------------------------------------------------
    wire busy_bar, nb_or_ld, oe_hi, OE_2_TagStore;

    `INV_N(u_busy_bar, 1, busy, busy_bar)
    `OR_2 (u_nb_or_ld, 1, nb_or_ld, busy_bar, LD_IC_SWAP_BUF)
    `AND_3(u_oe_hi,    1, oe_hi, nb_or_ld, rst, en)
    `INV_N(u_oe,       1, oe_hi, OE_2_TagStore)

    // ------------------------------------------------------------------
    // RAM cells: 2 layers x 3 byte-cells (24-bit tag = 3 bytes)
    // Instance hierarchy (required by external XMRs in icache_loader):
    //   g_tagStore_Layers[i].g_tagStore_Cells[j].tagStoreCell
    // ------------------------------------------------------------------
    wire [47:0] dout_pack;   // [23:0]=L0, [47:24]=L1

    genvar tsL;
    genvar tsC;
    generate
        for (tsL = 0; tsL < 2; tsL = tsL + 1) begin : g_tagStore_Layers
            for (tsC = 0; tsC < 3; tsC = tsC + 1) begin : g_tagStore_Cells
                ram8b8w$ tagStoreCell (
                    .A   (addr_2_store),
                    .WR  (WR_actual[tsL]),
                    .DIN (DIN_2_TagStore[tsC*8 +: 8]),
                    .OE  (OE_2_TagStore),
                    .DOUT(dout_pack[tsL*24 + tsC*8 +: 8])
                );
            end
        end
    endgenerate

    // Layer-select output mux
    `MUX_2(u_tag_sel, 24, currTag_o, dout_pack[23:0], dout_pack[47:24], tagCellOutSel)

    // ------------------------------------------------------------------
    // Valid bit storage (16 bits, one per cache line)
    // Reset to 0. Set to 1 when (fill3_i | ld_From_I_VC_Swap) and the
    // current v_addr_index points at this bit.
    // ------------------------------------------------------------------
    wire [15:0] idx_oh_16;
    `DECODER_N(u_valid_dec, 4, v_addr_index, idx_oh_16)

    wire we_valid_base;
    `OR_2(u_we_valid_base, 1, we_valid_base, fill3_i, ld_From_I_VC_Swap)

    wire [15:0] we_valid;
    wire [15:0] validStore;

    genvar vbi;
    generate
        for (vbi = 0; vbi < 16; vbi = vbi + 1) begin : g_valid_bits
            `AND_2(u_wv,  1, we_valid[vbi], idx_oh_16[vbi], we_valid_base)
            `REG_RST_WE(u_vs, 1, clk, rst, we_valid[vbi], 1'b1, validStore[vbi])
        end
    endgenerate

    // 16-to-1 mux select the valid bit for the current index
    `MUX_16(u_valid_sel, 1, currLine_V,
            validStore[0],  validStore[1],  validStore[2],  validStore[3],
            validStore[4],  validStore[5],  validStore[6],  validStore[7],
            validStore[8],  validStore[9],  validStore[10], validStore[11],
            validStore[12], validStore[13], validStore[14], validStore[15],
            v_addr_index)

endmodule
