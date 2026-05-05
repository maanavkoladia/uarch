// Structural Verilog 2005 port of VCache_DataStore.
// Reference SV: rtl/DCache/DCache_Block/VCache/VCache_DataStore.sv
// 16 byte-wide RAM cells (ram8b4w$) hold one cache line per way (4 ways).
// 2-bit address selects the way; per-byte WR enable; shared OE.
// No internal flops - all storage in the RAM cells.
//
// Clock duty-mask scheme (matches structural DCache_Bank_DataStore.sv):
//   replaces SV `#CLK_PHASE_DELAY` with a 4-ns free-running fast clock,
//   a divide-by-2 latch, and AND with the inverted main clock.
//   Used for WR gating only. OE keeps the SV `#2` delay path.

module VCache_DataStore (
    input  wire         clk_i,
    input  wire         rst_i,                       // active-low

    input  wire [14:0]  p_addr_i,
    input  wire         oe_i,
    input  wire         we_i,

    input  wire [127:0] st_q_data_i,                  // cache line
    input  wire [15:0]  st_data_vec_i,

    input  wire [127:0] DCache_SwapBuf_Line_i,        // cache line

    input  wire         read_D_SWAP_i,
    input  wire         Write_VSWAP_i,
    input  wire         busy_i,
    input  wire         WR_2_EB,

    input  wire         tagStore_hit_i,
    input  wire         useSavedIDX,

    input  wire [1:0]   hitIDX_i,
    input  wire [1:0]   evictionIDX_i,
    input  wire [1:0]   savedIDX_i,

    output wire [127:0] VCache_DataStore_LineOut_o    // cache line
);

    // ---------------------------------------------------------------
    // Address mux (mirrors SV lines 54-58: two `if`s, second wins)
    //   default = hitIDX
    //   if (useSavedIDX)               -> savedIDX
    //   if (WR_2_EB && !useSavedIDX)   -> evictionIDX
    // Equivalent in mutex form:
    //   useSavedIDX ? savedIDX : (WR_2_EB ? evictionIDX : hitIDX)
    // ---------------------------------------------------------------
    wire [1:0] step1;
    wire [1:0] ADDRESS_2_DataStore;
    `MUX_2(u_addr_step1, 2, step1,
           hitIDX_i,        // in0: WR_2_EB == 0
           evictionIDX_i,   // in1: WR_2_EB == 1
           WR_2_EB)
    `MUX_2(u_addr_final, 2, ADDRESS_2_DataStore,
           step1,           // in0: useSavedIDX == 0
           savedIDX_i,      // in1: useSavedIDX == 1
           useSavedIDX)

    // ---------------------------------------------------------------
    // Per-byte WR_clk derivation (mirrors SV lines 70-82)
    //   if (!busy && we): byte_write[i] = vec[i] & hit  (store path)
    //   else if (read_D_SWAP):           byte_write[i] = 1
    //   else:                            byte_write[i] = 0
    // The two SV `if`s have the second one winning (per blocking
    // assignment in always_comb). This is captured by:
    //   store_path overrides swap_path.
    // ---------------------------------------------------------------
    wire not_busy;
    wire store_path;
    wire not_store_path;
    wire swap_path;
    `INV_N(u_not_busy,       1, busy_i,         not_busy)
    `AND_2(u_store_path,     1, store_path,     not_busy, we_i)
    `INV_N(u_not_store_path, 1, store_path,     not_store_path)
    `AND_2(u_swap_path,      1, swap_path,      not_store_path, read_D_SWAP_i)

    // ---------------------------------------------------------------
    // Clock duty-mask scheme (verbatim from DCache_Bank_DataStore.sv).
    // Generates a duty-cycled mask for RAM writes using a 4 ns free-running
    // fast_clk + divide-by-2 latch + inverted main clock.
    // ---------------------------------------------------------------
    wire clk_duty_mask;
    wire clk_duty_mask_buffer;
    reg  fast_clk;
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
    `REG_RST(u_clk_duty_latch, 1, fast_clk, rst_i, clk_latch_inv, clk_duty_latch_out);
    `AND_3(u_clk_duty_mask, 1, clk_duty_mask, fast_clk, clk_duty_latch_out, inv_clk);
    `INV_N(u_inv_clk, 1, clk_i, inv_clk);

    `BUFFER_DELAY(u_phase_duty, 6, 1, clk_duty_mask, clk_duty_mask_buffer)

    // wire clk_phase_45;
    // `BUFFER_DELAY(u_phase, 12, 1, clk_i, clk_phase_45)


    // ---------------------------------------------------------------
    // OE path (mirrors SV lines 109-122)
    //   OE_clk    = ~(WR_2_EB | Write_VSWAP | (oe & ~busy))
    //   OE_delay  = (rst_i==0) ? 1 : delay(OE_clk)        [#2 ns delay]
    //   OE_actual = ~((OE_clk==0) & (OE_delay==0))
    //
    //   pre_delay = !rst_i ? 1 : OE_clk = (~rst_i) | OE_clk
    //   8 stages * 0.25 ns = 2 ns
    // ---------------------------------------------------------------
    wire oe_and_not_busy;
    wire oe_event;
    wire OE_2_DataStore_clk;
    `AND_2(u_oe_and_nb, 1, oe_and_not_busy, oe_i, not_busy)
    `OR_3 (u_oe_event,  1, oe_event, WR_2_EB, Write_VSWAP_i, oe_and_not_busy)
    `INV_N(u_oe_clk,    1, oe_event, OE_2_DataStore_clk)

    wire rst_inv;
    wire pre_delay;
    //wire OE_2_DataStore_delay;
    wire OE_2_DataStore;
    `INV_N(u_rst_inv,    1, rst_i, rst_inv)
    `OR_2 (u_pre_delay,  1, OE_2_DataStore, rst_inv, OE_2_DataStore_clk)
    // `BUFFER_DELAY(u_oe_delay, 8, 1, pre_delay, OE_2_DataStore_delay)

    wire OE_clk_bar;
    wire OE_delay_bar;
    wire oe_active;
    wire OE_2_DataStore_actual;
    `INV_N(u_oe_clk_bar,   1, OE_2_DataStore_clk,   OE_clk_bar)
    `INV_N(u_oe_delay_bar, 1, OE_2_DataStore, OE_delay_bar)
    `AND_2(u_oe_active,    1, oe_active, OE_clk_bar, OE_delay_bar)
    `INV_N(u_oe_actual,    1, oe_active, OE_2_DataStore_actual)

    // ---------------------------------------------------------------
    // Per-byte RAM cells, WR gating, DIN mux
    // ---------------------------------------------------------------
    wire [127:0] DOUT_flat;
    wire [15:0]  WR_2_DataStore_actual;
    wire [15:0]  store_byte_event;
    wire [15:0]  byte_write_event;
    wire [127:0] DIN_flat;

    genvar gi;
    generate
        for (gi = 0; gi < 16; gi = gi + 1) begin : g_vcache_data_store_ram_cells
            // store path: write byte i when vec[i] & hit, gated by store_path
            `AND_3(u_store_evt, 1, store_byte_event[gi],
                   store_path, st_data_vec_i[gi], tagStore_hit_i)

            // byte_write_event[i] = store_byte_event[i] | swap_path
            `OR_2 (u_byte_write, 1, byte_write_event[gi],
                   store_byte_event[gi], swap_path)

            // WR active-low: nand3$(rst, byte_write_event, clk_duty_mask)
            // matches DCache_Bank_DataStore.sv line 144
            nand3$ u_wr_actual (
                .out(WR_2_DataStore_actual[gi]),
                .in0(rst_i),
                .in1(byte_write_event[gi]),
                .in2(clk_duty_mask_buffer)
            );

            // DIN mux: store_path ? st_q_data_i[byte] : DCache_SwapBuf_Line_i[byte]
            `MUX_2(u_din_byte, 8, DIN_flat[gi*8 +: 8],
                   DCache_SwapBuf_Line_i[gi*8 +: 8],   // in0
                   st_q_data_i[gi*8 +: 8],              // in1
                   store_path)

            // RAM cell - direct primitive, matches SV pattern
            ram8b4w$ v_cache_data_store_ramCell (
                .A   (ADDRESS_2_DataStore),
                .WR  (WR_2_DataStore_actual[gi]),
                .DIN (DIN_flat[gi*8 +: 8]),
                .OE  (OE_2_DataStore_actual),
                .DOUT(DOUT_flat[gi*8 +: 8])
            );
        end
    endgenerate

    assign VCache_DataStore_LineOut_o = DOUT_flat;

endmodule
