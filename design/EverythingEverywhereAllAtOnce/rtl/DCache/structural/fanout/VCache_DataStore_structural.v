// Pure Verilog 2005 port of VCache_DataStore.
// Reference: rtl/DCache/structural/VCache_DataStore.sv
// 16 byte-wide RAM cells (ram8b4w$) hold one cache line per way (4 ways).
// 2-bit address selects the way; per-byte WR enable; shared OE.

module VCache_DataStore (
    input  wire         clk_i,
    input  wire         rst_i,                       // active-low

    input  wire [14:0]  p_addr_i,
    input  wire         oe_i,
    input  wire         we_i,

    input  wire [127:0] st_q_data_i,
    input  wire [15:0]  st_data_vec_i,

    input  wire [127:0] DCache_SwapBuf_Line_i,

    input  wire         read_D_SWAP_i,
    input  wire         Write_VSWAP_i,
    input  wire         busy_i,
    input  wire         WR_2_EB,

    input  wire         tagStore_hit_i,
    input  wire         useSavedIDX,

    input  wire [1:0]   hitIDX_i,
    input  wire [1:0]   evictionIDX_i,
    input  wire [1:0]   savedIDX_i,

    output wire [127:0] VCache_DataStore_LineOut_o
);

    wire [1:0] step1;
    wire [1:0] ADDRESS_2_DataStore;
    `MUX_2(u_addr_step1, 2, step1,
           hitIDX_i,
           evictionIDX_i,
           WR_2_EB)
    // u_addr_final fanout 16/bit -> bufferH16$ per bit.
    wire [1:0] ADDRESS_2_DataStore_pre;
    `MUX_2(u_addr_final, 2, ADDRESS_2_DataStore_pre,
           step1,
           savedIDX_i,
           useSavedIDX)
    bufferH16$ u_addr_final_buf0 (.out(ADDRESS_2_DataStore[0]), .in(ADDRESS_2_DataStore_pre[0]));
    bufferH16$ u_addr_final_buf1 (.out(ADDRESS_2_DataStore[1]), .in(ADDRESS_2_DataStore_pre[1]));

    wire not_busy;
    wire store_path, store_path_pre;
    wire not_store_path;
    wire swap_path, swap_path_pre;
    `INV_N(u_not_busy,       1, busy_i,         not_busy)
    // u_store_path fanout 145 -> bufferH256$.  u_swap_path fanout 16 -> bufferH16$.
    `AND_2(u_store_path,     1, store_path_pre, not_busy, we_i)
    bufferH256$ u_store_path_buf (.out(store_path), .in(store_path_pre));
    `INV_N(u_not_store_path, 1, store_path,     not_store_path)
    `AND_2(u_swap_path,      1, swap_path_pre,  not_store_path, read_D_SWAP_i)
    bufferH16$  u_swap_path_buf (.out(swap_path), .in(swap_path_pre));

    // wire clk_duty_mask;
    // wire clk_duty_mask_buffer;
    // reg  fast_clk;
    // initial begin
    //     fast_clk = 1;
    // end
    // always begin
    //     fast_clk = #2 ~fast_clk;
    // end

    // wire clk_latch_inv;
    // wire inv_clk;
    // wire clk_duty_latch_out;

    // `INV_N(u_clk_latch_inv, 1, clk_duty_latch_out, clk_latch_inv);
    // `REG_RST(u_clk_duty_latch, 1, fast_clk, rst_i, clk_latch_inv, clk_duty_latch_out);
    // `AND_3(u_clk_duty_mask, 1, clk_duty_mask, fast_clk, clk_duty_latch_out, inv_clk);
    // `INV_N(u_inv_clk, 1, clk_i, inv_clk);

    // `BUFFER_DELAY(u_phase_duty, 6, 1, clk_duty_mask, clk_duty_mask_buffer)

    wire delay_rise;
    wire delay_fall;
    wire clk_duty_mask;
 
    `BUFFER_DELAY(u_phase_rise, 27, 1, clk_i, delay_rise);
    `BUFFER_DELAY(u_phase_fall, 16, 1, clk_i, delay_fall);


    `AND_2(u_clk_duty_mask, 1, clk_duty_mask, delay_rise, delay_fall);

    wire oe_and_not_busy;
    wire oe_event;
    wire OE_2_DataStore_clk;
    `AND_2(u_oe_and_nb, 1, oe_and_not_busy, oe_i, not_busy)
    `OR_3 (u_oe_event,  1, oe_event, WR_2_EB, Write_VSWAP_i, oe_and_not_busy)
    `INV_N(u_oe_clk,    1, oe_event, OE_2_DataStore_clk)

    wire rst_inv;
    wire OE_2_DataStore;
    `INV_N(u_rst_inv,    1, rst_i, rst_inv)
    `OR_2 (u_pre_delay,  1, OE_2_DataStore, rst_inv, OE_2_DataStore_clk)

    wire OE_clk_bar;
    wire OE_delay_bar;
    wire oe_active;
    wire OE_2_DataStore_actual;
    `INV_N(u_oe_clk_bar,   1, OE_2_DataStore_clk,   OE_clk_bar)
    `INV_N(u_oe_delay_bar, 1, OE_2_DataStore, OE_delay_bar)
    `AND_2(u_oe_active,    1, oe_active, OE_clk_bar, OE_delay_bar)
    `INV_N(u_oe_actual,    1, oe_active, OE_2_DataStore_actual)

    wire [127:0] DOUT_flat;
    wire [15:0]  WR_2_DataStore_actual;
    wire [15:0]  store_byte_event;
    wire [15:0]  byte_write_event;
    wire [127:0] DIN_flat;

    genvar gi;
    generate
        for (gi = 0; gi < 16; gi = gi + 1) begin : g_vcache_data_store_ram_cells
            `AND_3(u_store_evt, 1, store_byte_event[gi],
                   store_path, st_data_vec_i[gi], tagStore_hit_i)

            `OR_2 (u_byte_write, 1, byte_write_event[gi],
                   store_byte_event[gi], swap_path)

            nand3$ u_wr_actual (
                .out(WR_2_DataStore_actual[gi]),
                .in0(rst_i),
                .in1(byte_write_event[gi]),
                .in2(clk_duty_mask)
            );

            `MUX_2(u_din_byte, 8, DIN_flat[gi*8 +: 8],
                   DCache_SwapBuf_Line_i[gi*8 +: 8],
                   st_q_data_i[gi*8 +: 8],
                   store_path)

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
