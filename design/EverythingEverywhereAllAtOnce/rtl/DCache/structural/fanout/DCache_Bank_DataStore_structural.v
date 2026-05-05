// Pure Verilog 2005 port of DCache_Bank_DataStore.
// Reference: rtl/DCache/structural/DCache_Bank_DataStore.sv
// 16 byte-wide RAM cells (ram8b8w$, instantiated via generate-for) hold
// one cache line per index. Per-byte WR is gated by FSM fill phases /
// store request / load-from-VCache. No internal flops outside the duty
// generator below.

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

    input  wire [127:0] vcache_swapBuf_line_i,
    input  wire [31:0]  dataBus_i,

    input  wire         tagStore_hit_i,

    output wire [127:0] lineOut_o
);

    wire [2:0] index;
    assign index = p_addr_i[8:6];

    wire any_high_pri;
    wire no_high_pri;
    wire not_busy;
    `OR_5 (u_any_high_pri, 1, any_high_pri,
           ld_From_V_Swap_i, fill0_i, fill1_i, fill2_i, fill3_i)
    `INV_N(u_no_high_pri,  1, any_high_pri, no_high_pri)
    `INV_N(u_not_busy,     1, bankControllerBusy_i, not_busy)

    wire clk_duty_mask;
    wire delay_rise;
    wire delay_fall;


    `BUFFER_DELAY(u_phase_rise, 25, 1, clk, delay_rise);
    `BUFFER_DELAY(u_phase_fall, 15, 1, clk, delay_fall);


    wire clk_latch_inv;
    wire inv_clk;
    wire clk_duty_latch_out;
    wire clk_duty_pre_buf;


    `AND_2(u_clk_duty_mask, 1, clk_duty_mask, delay_rise, delay_fall);

    // `INV_N(u_clk_latch_inv, 1, clk_duty_latch_out, clk_latch_inv);
    // `REG_RST(u_clk_duty_latch, 1, fast_clk, rst, clk_latch_inv, clk_duty_latch_out);

    // `AND_3(u_clk_duty_mask, 1, clk_duty_pre_buf, fast_clk, clk_duty_latch_out, inv_clk);

    // `INV_N(u_inv_clk, 1, clk, inv_clk);
    // `BUFFER_DELAY(u_phase, 6, 1, clk_duty_pre_buf, clk_duty_mask);

    wire oe_and_not_busy;
    wire OE_2_DataStore;
    `AND_2(u_oe_and_nb, 1, oe_and_not_busy, oe, not_busy)
    nor2$ u_oe_actual (.out(OE_2_DataStore), .in0(write2_Dwap_i), .in1(oe_and_not_busy));

    wire [127:0] DOUT_flat;
    wire [15:0]  WR_2_DataStore_actual;
    wire [15:0]  store_event;
    wire [15:0]  byte_write;
    wire [127:0] DIN_flat;

    genvar gi;
    generate
        for (gi = 0; gi < 16; gi = gi + 1) begin : g_dcache_bank_data_store_ram_cells
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

            `AND_5(u_store_evt, 1, store_event[gi],
                   st_data_vec[gi], we, not_busy, tagStore_hit_i, no_high_pri)

            `OR_3 (u_byte_write, 1, byte_write[gi],
                   ld_From_V_Swap_i, range_fill, store_event[gi])

            nand3$ u_wr_actual (.out(WR_2_DataStore_actual[gi]), .in0(rst), .in1(byte_write[gi]), .in2(clk_duty_mask));

            wire [7:0] din_mid;
            `MUX_2(u_din_mid, 8, din_mid,
                   stq_data_i[gi*8 +: 8],
                   range_slice,
                   range_fill)
            `MUX_2(u_din_byte, 8, DIN_flat[gi*8 +: 8],
                   din_mid,
                   vcache_swapBuf_line_i[gi*8 +: 8],
                   ld_From_V_Swap_i)

            ram8b8w$ dcache_bank_data_store_ramCell (
                .A   (index),
                .WR  (WR_2_DataStore_actual[gi]),
                .DIN (DIN_flat[gi*8 +: 8]),
                .OE  (OE_2_DataStore),
                .DOUT(DOUT_flat[gi*8 +: 8])
            );
        end
    endgenerate

    assign lineOut_o = DOUT_flat;

endmodule
