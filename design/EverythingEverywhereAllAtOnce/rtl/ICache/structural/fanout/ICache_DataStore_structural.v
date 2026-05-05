

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
    // Address decomposition.
    // After round-1 split of u_vaddr_mux, v_addr_i bits 4..7 still
    // had high fanout in DataStore: bits 4..6 each drive 32 RAM A pins
    // (need bufferH64$), and bit 7 drives the 128-bit u_line_sel mux
    // select (~133 loads, needs bufferH256$).
    // ------------------------------------------------------------------
    wire [2:0] addr_2_store;
    wire       dataLineOutSel;

    wire [2:0] addr_2_store_pre;
    wire       dataLineOutSel_pre;

    assign addr_2_store_pre   = v_addr_i[6:4];
    assign dataLineOutSel_pre = v_addr_i[7];

    // Bits 0..2 each fanout 32 (32 RAM A pins) -> bufferH64$.
    bufferH64$ u_a2s0_buf (.out(addr_2_store[0]), .in(addr_2_store_pre[0]));
    bufferH64$ u_a2s1_buf (.out(addr_2_store[1]), .in(addr_2_store_pre[1]));
    bufferH64$ u_a2s2_buf (.out(addr_2_store[2]), .in(addr_2_store_pre[2]));

    // dataLineOutSel feeds 128-bit mux select + 4 sel_layer ANDs + 1 inv -> bufferH256$.
    bufferH256$ u_dls_buf (.out(dataLineOutSel), .in(dataLineOutSel_pre));

    // ------------------------------------------------------------------
    // Phased clock (10 stages * 0.25 ns = 2.5 ns)
    // ------------------------------------------------------------------
    wire clk_45_phase;
    `BUFFER_DELAY(u_phase_buf, 14, 1, clk, clk_45_phase)

    // ------------------------------------------------------------------
    // Quad-level write-want: wbw_Q[q] = ld_From_I_VC_Swap | fill{q}_i
    //   q=0 -> bytes 0..3, q=1 -> 4..7, q=2 -> 8..11, q=3 -> 12..15
    // Original wbw_Q[q] had fanout=8 (2 layers x 4 bytes/quad). Splitting
    // into wbw_Q_a (layer 0) and wbw_Q_b (layer 1) gives each fanout 4.
    // ------------------------------------------------------------------
    wire [3:0] wbw_Q_a;  // for layer 0
    wire [3:0] wbw_Q_b;  // for layer 1
    `OR_2(u_wbw_Q0_a, 1, wbw_Q_a[0], ld_From_I_VC_Swap, fill0_i)
    `OR_2(u_wbw_Q0_b, 1, wbw_Q_b[0], ld_From_I_VC_Swap, fill0_i)
    `OR_2(u_wbw_Q1_a, 1, wbw_Q_a[1], ld_From_I_VC_Swap, fill1_i)
    `OR_2(u_wbw_Q1_b, 1, wbw_Q_b[1], ld_From_I_VC_Swap, fill1_i)
    `OR_2(u_wbw_Q2_a, 1, wbw_Q_a[2], ld_From_I_VC_Swap, fill2_i)
    `OR_2(u_wbw_Q2_b, 1, wbw_Q_b[2], ld_From_I_VC_Swap, fill2_i)
    `OR_2(u_wbw_Q3_a, 1, wbw_Q_a[3], ld_From_I_VC_Swap, fill3_i)
    `OR_2(u_wbw_Q3_b, 1, wbw_Q_b[3], ld_From_I_VC_Swap, fill3_i)

    // ------------------------------------------------------------------
    // Layer gating (split per quad to bring per-AND fanout to 4):
    //   sel_layer_q[layer*4 + quad] = (layer==0 ? !dataLineOutSel : dataLineOutSel) & rst
    // Original sel_layer[l] had fanout 16 (16 bytes per layer). 4-way split
    // (one per quad) gives each fanout 4 -- no buffer required.
    // ------------------------------------------------------------------
    wire [7:0] sel_layer_q;
    wire dataLineOutSel_bar;

    `INV_N(u_dls_bar, 1, dataLineOutSel, dataLineOutSel_bar)
    `AND_2(u_sl0_q0, 1, sel_layer_q[0], dataLineOutSel_bar, rst)
    `AND_2(u_sl0_q1, 1, sel_layer_q[1], dataLineOutSel_bar, rst)
    `AND_2(u_sl0_q2, 1, sel_layer_q[2], dataLineOutSel_bar, rst)
    `AND_2(u_sl0_q3, 1, sel_layer_q[3], dataLineOutSel_bar, rst)
    `AND_2(u_sl1_q0, 1, sel_layer_q[4], dataLineOutSel,     rst)
    `AND_2(u_sl1_q1, 1, sel_layer_q[5], dataLineOutSel,     rst)
    `AND_2(u_sl1_q2, 1, sel_layer_q[6], dataLineOutSel,     rst)
    `AND_2(u_sl1_q3, 1, sel_layer_q[7], dataLineOutSel,     rst)

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

    // Two separate generate-for blocks (one per layer) so each block can
    // bind its own wbw_Q_a/b copy and its own sel_layer_q quad.
    genvar wB;
    generate
        for (wB = 0; wB < 16; wB = wB + 1) begin : g_wr_l0
            `AND_2(u_want, 1, want_pack[wB],     wbw_Q_a[wB/4], sel_layer_q[wB/4])
            `AND_2(u_gate, 1, gate_pack[wB],     clk_45_phase, want_pack[wB])
            `INV_N(u_wra,  1, gate_pack[wB],     WR_actual[wB])
        end
        for (wB = 0; wB < 16; wB = wB + 1) begin : g_wr_l1
            `AND_2(u_want, 1, want_pack[16+wB],  wbw_Q_b[wB/4], sel_layer_q[4 + wB/4])
            `AND_2(u_gate, 1, gate_pack[16+wB],  clk_45_phase, want_pack[16+wB])
            `INV_N(u_wra,  1, gate_pack[16+wB],  WR_actual[16+wB])
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
