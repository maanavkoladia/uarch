

module ICache_DataStore (
    input  wire        rst,
    input  wire        clk,
    input  wire        en,
    input  wire [31:0] v_addr_i,
    input  wire        LD_IC_SWAP_BUF,
    input  wire        fill0_i,
    input  wire        fill1_i,
    input  wire        fill2_i,
    input  wire        fill3_i,
    input  wire        busy,
    input  wire        ld_From_I_VC_Swap,

    // I_VC_SwapBuf_i (decomposed). Only _line is used internally.
    input  wire         I_VC_SwapBuf_i_valid,
    input  wire [31:0]  I_VC_SwapBuf_i_lineAddr,
    input  wire [127:0] I_VC_SwapBuf_i_line,

    input  wire [31:0]  dataBus,
    output wire [127:0] currLine_o
);

    // ------------------------------------------------------------------
    // Address decomposition (pure wire slices)
    // ------------------------------------------------------------------
    wire [3:0] v_addr_index;
    wire [2:0] addr_2_store;
    wire       dataLineOutSel;

    assign v_addr_index   = v_addr_i[7:4];
    assign addr_2_store   = v_addr_index[2:0];
    assign dataLineOutSel = v_addr_index[3];

    // ------------------------------------------------------------------
    // Phased clock (10 stages * 0.25 ns = 2.5 ns)
    // ------------------------------------------------------------------
    wire clk_45_phase;
    `BUFFER_DELAY(u_phase_buf, 12, 1, clk, clk_45_phase)

    // ------------------------------------------------------------------
    // Quad-level write-want: wbw_Q[q] = ld_From_I_VC_Swap | fill{q}_i
    //   q=0 -> bytes 0..3, q=1 -> 4..7, q=2 -> 8..11, q=3 -> 12..15
    // ------------------------------------------------------------------
    wire [3:0] wbw_Q;
    `OR_2(u_wbw_Q0, 1, wbw_Q[0], ld_From_I_VC_Swap, fill0_i)
    `OR_2(u_wbw_Q1, 1, wbw_Q[1], ld_From_I_VC_Swap, fill1_i)
    `OR_2(u_wbw_Q2, 1, wbw_Q[2], ld_From_I_VC_Swap, fill2_i)
    `OR_2(u_wbw_Q3, 1, wbw_Q[3], ld_From_I_VC_Swap, fill3_i)

    // ------------------------------------------------------------------
    // Layer gating: only the selected layer actually writes.
    //   sel_layer[0] = !dataLineOutSel & rst
    //   sel_layer[1] =  dataLineOutSel & rst
    // ------------------------------------------------------------------
    wire [1:0] sel_layer;
    wire dataLineOutSel_bar;

    `INV_N(u_dls_bar, 1, dataLineOutSel, dataLineOutSel_bar)
    `AND_2(u_sl0, 1, sel_layer[0], dataLineOutSel_bar, rst)
    `AND_2(u_sl1, 1, sel_layer[1], dataLineOutSel,     rst)

    // ------------------------------------------------------------------
    // DIN byte mux (16 bytes). Byte i picks between swap-buf and the
    // repeating dataBus quad pattern (byte i <- dataBus[8*(i%4) +: 8]).
    // DIN_pack[i*8 +: 8] = byte i of the write data bus.
    // ------------------------------------------------------------------
    wire [127:0] DIN_pack;

    genvar di;
    generate
        for (di = 0; di < 16; di = di + 1) begin : g_din_mux
            `MUX_2(u_din, 8, DIN_pack[di*8 +: 8],
                   dataBus[(di%4)*8 +: 8],
                   I_VC_SwapBuf_i_line[di*8 +: 8],
                   ld_From_I_VC_Swap)
        end
    endgenerate

    // ------------------------------------------------------------------
    // Per-(layer,byte) WR pulse generation.
    //   want[l*16 + j] = wbw_Q[j/4] & sel_layer[l]
    //   gate[l*16 + j] = clk_45_phase & want[l*16 + j]
    //   WR_actual[l*16 + j] = ~gate[l*16 + j]   (active-low to RAM)
    // ------------------------------------------------------------------
    wire [31:0] want_pack;
    wire [31:0] gate_pack;
    wire [31:0] WR_actual;

    genvar wL, wB;
    generate
        for (wL = 0; wL < 2; wL = wL + 1) begin : g_wr_layer
            for (wB = 0; wB < 16; wB = wB + 1) begin : g_wr_byte
                `AND_2(u_want, 1, want_pack[wL*16 + wB], wbw_Q[wB/4], sel_layer[wL])
                `AND_2(u_gate, 1, gate_pack[wL*16 + wB], clk_45_phase, want_pack[wL*16 + wB])
                `INV_N(u_wra,  1, gate_pack[wL*16 + wB], WR_actual[wL*16 + wB])
            end
        end
    endgenerate

    // ------------------------------------------------------------------
    // OE (active-low to RAM)
    //   OE_2_DataStore = !((!busy | LD_IC_SWAP_BUF) & rst & en)
    // ------------------------------------------------------------------
    wire busy_bar, nb_or_ld, oe_hi, OE_2_DataStore;

    `INV_N(u_busy_bar, 1, busy, busy_bar)
    `OR_2 (u_nb_or_ld, 1, nb_or_ld, busy_bar, LD_IC_SWAP_BUF)
    `AND_3(u_oe_hi,    1, oe_hi, nb_or_ld, rst, en)
    `INV_N(u_oe,       1, oe_hi, OE_2_DataStore)

    // ------------------------------------------------------------------
    // RAM cells: 2 layers x 16 byte-cells.
    // Instance hierarchy (required by external XMRs in icache_loader):
    //   g_mem_layer[i].g_memCells[j].dataStore_memCell
    // dout_pack layout: layer i byte j -> bits [i*128 + j*8 +: 8]
    // ------------------------------------------------------------------
    wire [255:0] dout_pack;

    genvar mL, mB;
    generate
        for (mL = 0; mL < 2; mL = mL + 1) begin : g_mem_layer
            for (mB = 0; mB < 16; mB = mB + 1) begin : g_memCells
                ram8b8w$ dataStore_memCell (
                    .A   (addr_2_store),
                    .WR  (WR_actual[mL*16 + mB]),
                    .DIN (DIN_pack[mB*8 +: 8]),
                    .OE  (OE_2_DataStore),
                    .DOUT(dout_pack[mL*128 + mB*8 +: 8])
                );
            end
        end
    endgenerate

    // ------------------------------------------------------------------
    // Layer-select output mux (128 bits)
    // ------------------------------------------------------------------
    `MUX_2(u_line_sel, 128, currLine_o, dout_pack[127:0], dout_pack[255:128], dataLineOutSel)

endmodule
