// Structural Verilog 2005 port of DCache_Bank_DataStore.
// Reference SV: rtl/DCache/DCache_Block/DCache_Bank/DCache_Bank_DataStore.sv
// 16 byte-wide RAM cells (ram8b8w$, instantiated directly via
// `generate for`) hold one cache line per index. Per-byte write
// enable is gated by FSM fill phases / store request / load-from-VCache.
// No internal flops — all storage lives in the RAM cells.

module DCache_Bank_DataStore (
    input  wire         clk,
    input  wire         rst,                          // active-low

    input  wire [14:0]  p_addr_i,
    input  wire         oe,
    input  wire         we,

    input  wire         ld_From_V_Swap_i,
    input  wire         fill0_i,
    input  wire         fill1_i,
    input  wire         fill2_i,
    input  wire         fill3_i,
    input  wire         write2_Dwap_i,
    input  wire         bankControllerBusy_i,

    input  wire [127:0] stq_data_i,                   // cache line: byte i = bits[8i+7:8i]
    input  wire [15:0]  st_data_vec,

    input  wire [127:0] vcache_swapBuf_line_i,        // cache line, same byte ordering
    input  wire [31:0]  dataBus_i,

    input  wire         tagStore_hit_i,

    output wire [127:0] lineOut_o                     // cache line out
);

    
    // ---------------------------------------------------------------
    // Address slice (wire alias)
    // ---------------------------------------------------------------
    wire [2:0] index;
    assign index = p_addr_i[8:6];

    // ---------------------------------------------------------------
    // Shared combinational nets
    // ---------------------------------------------------------------
    wire any_high_pri;       // ld | fill0 | fill1 | fill2 | fill3
    wire no_high_pri;        // ~any_high_pri (gates the store path)
    wire not_busy;
    `OR_5 (u_any_high_pri, 1, any_high_pri,
           ld_From_V_Swap_i, fill0_i, fill1_i, fill2_i, fill3_i)
    `INV_N(u_no_high_pri,  1, any_high_pri, no_high_pri)
    `INV_N(u_not_busy,     1, bankControllerBusy_i, not_busy)

    // ---------------------------------------------------------------
    // Phased clock for RAM write window
    //   CLK_PHASE_DELAY = 2.5 ns = 10 stages of 0.25 ns each
    // ---------------------------------------------------------------
    // wire clk_45_phase;
    // `BUFFER_DELAY(u_phase,15, 1, clk, clk_45_phase)

    wire clk_duty_mask;
    reg fast_clk;
    initial begin
        fast_clk = 1;
    end
    always begin
        fast_clk = #2 ~fast_clk;
    end

    wire clk_latch_inv;
    wire inv_clk;
    wire clk_duty_latch_out;

    `INV_N(u_clk_latch_inv, 1, clk_duty_latch_out, clk_latch_inv);
    `REG_RST(u_clk_duty_latch, 1, fast_clk, rst, clk_latch_inv, clk_duty_latch_out);

    `AND_3(u_clk_duty_mask, 1, clk_duty_mask, fast_clk, clk_duty_latch_out, inv_clk);

    `INV_N(u_inv_clk, 1, clk, inv_clk);

    // ---------------------------------------------------------------
    // OE (active-low)
    //   OE = ~(write2_Dwap | (oe & ~busy))
    // ---------------------------------------------------------------
    wire oe_and_not_busy;
    wire oe_event;
    wire OE_2_DataStore;
    `AND_2(u_oe_and_nb, 1, oe_and_not_busy, oe, not_busy)
    // `OR_2 (u_oe_event,  1, oe_event, write2_Dwap_i, oe_and_not_busy)
    // `INV_N(u_oe_actual, 1, oe_event, OE_2_DataStore)
    nor2$ u_oe_actual (.out(OE_2_DataStore), .in0(write2_Dwap_i), .in1(oe_and_not_busy));

    // ---------------------------------------------------------------
    // Per-byte WR_actual, DIN mux, RAM instances, DOUT capture
    //
    // For each byte i in [0..15]:
    //   range_fill   = fill0 (i in 0..3) | fill1 (4..7) | fill2 (8..11) | fill3 (12..15)
    //   range_slice  = dataBus_i[((i mod 4)*8) +: 8]
    //   store_event  = st_data_vec[i] & we & ~busy & tagStore_hit & no_high_pri
    //   byte_write   = ld | range_fill | store_event
    //   WR_actual    = ~(byte_write & rst & clk_45_phase)
    //   DIN          = ld ? vcache_swapBuf_line[byte] : (range_fill ? range_slice : stq_data[byte])
    // ---------------------------------------------------------------
    wire [127:0] DOUT_flat;
    wire [15:0]  WR_2_DataStore_actual;
    wire [15:0]  store_event;
    wire [15:0]  byte_write;
    wire [15:0]  byte_write_phased;
    wire [127:0] DIN_flat;

    genvar gi;
    generate
        for (gi = 0; gi < 16; gi = gi + 1) begin : g_dcache_bank_data_store_ram_cells
            // Pick range-specific fill bit and dataBus slice (elaboration-time)
            wire        range_fill;
            wire [7:0]  range_slice;
            if (gi < 4) begin : g_b0_3
                assign range_fill  = fill0_i;
                assign range_slice = dataBus_i[gi*8 +: 8];
            end else if (gi < 8) begin : g_b4_7
                assign range_fill  = fill1_i;
                assign range_slice = dataBus_i[(gi-4)*8 +: 8];
            end else if (gi < 12) begin : g_b8_11
                assign range_fill  = fill2_i;
                assign range_slice = dataBus_i[(gi-8)*8 +: 8];
            end else begin : g_b12_15
                assign range_fill  = fill3_i;
                assign range_slice = dataBus_i[(gi-12)*8 +: 8];
            end

            // store_event[i] = st_data_vec[i] & we & ~busy & hit & no_high_pri
            `AND_5(u_store_evt, 1, store_event[gi],
                   st_data_vec[gi], we, not_busy, tagStore_hit_i, no_high_pri)

            // byte_write[i] = ld | range_fill | store_event
            `OR_3 (u_byte_write, 1, byte_write[gi],
                   ld_From_V_Swap_i, range_fill, store_event[gi])

            // phased gate: WR_actual = ~(byte_write & rst & clk_45_phase)
            // `AND_3(u_byte_write_phased, 1, byte_write_phased[gi],
            //        byte_write[gi], rst, clk_45_phase)
            // `INV_N(u_wr_actual, 1, byte_write_phased[gi], WR_2_DataStore_actual[gi])

            //changing and to nand
            nand3$ u_wr_actual (.out(WR_2_DataStore_actual[gi]), .in0(rst), .in1(byte_write[gi]), .in2(clk_duty_mask));


            // DIN mux: priority ld > range_fill > store
            wire [7:0] din_mid;
            `MUX_2(u_din_mid, 8, din_mid,
                   stq_data_i[gi*8 +: 8],   // in0 (default: store path)
                   range_slice,             // in1 (when range_fill selects)
                   range_fill)
            `MUX_2(u_din_byte, 8, DIN_flat[gi*8 +: 8],
                   din_mid,                                // in0
                   vcache_swapBuf_line_i[gi*8 +: 8],       // in1 (ld path)
                   ld_From_V_Swap_i)

            // RAM cell (direct primitive, matches SV pattern)
            ram8b8w$ dcache_bank_data_store_ramCell (
                .A   (index),
                .WR  (WR_2_DataStore_actual[gi]),
                .DIN (DIN_flat[gi*8 +: 8]),
                .OE  (OE_2_DataStore),
                .DOUT(DOUT_flat[gi*8 +: 8])
            );
        end
    endgenerate

    // Output is a flat 128-bit cache line; byte i lives in bits [8i+7:8i]
    // (matches the LSB-first packing used by EvictionBuf adapter and
    // DCache_Block lines 207-225).
    assign lineOut_o = DOUT_flat;

endmodule
