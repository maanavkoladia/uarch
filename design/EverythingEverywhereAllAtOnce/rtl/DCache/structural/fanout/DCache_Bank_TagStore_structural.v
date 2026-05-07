// Pure Verilog 2005 port of DCache_Bank_TagStore.
// Reference: rtl/DCache/structural/DCache_Bank_TagStore.sv
// All logic via STDCell macros. The 6-bit tag word is held in one
// ram8b8w$ cell (address = 3-bit index, data = {2'b0, tag}). Per-line
// valid and dirty bits are held in REG_RST_WE flops (8 of each).

module DCache_Bank_TagStore (
    input  wire        clk,
    input  wire        rst,                       // active-low

    input  wire [14:0] p_addr_i,                  // p_address_t
    input  wire        oe_i,
    input  wire        we_i,

    input  wire        ld_From_V_Swap_i,
    input  wire        V_Cache_SwapBuf_DirtyBit,

    input  wire        fill3_i,
    input  wire        write2_Dwap_i,

    input  wire        bankControllerBusy_i,

    input  wire        writeSuccess,

    output wire [5:0]  tagOut_o,                  // DCACHE_BANK_TAG_WIDTH = 6
    output wire        currLine_V_o,
    output wire        currLine_Dirty_o
);

    wire [2:0] index;
    wire [5:0] tag_in;
    assign index  = p_addr_i[8:6];
    assign tag_in = p_addr_i[14:9];

    wire [7:0] index_decoded;
    `DECODER_N(u_index_dec, 3, index, index_decoded)

    wire [7:0] valid_q;
    wire [7:0] dirty_q;

    // u_fill_or_ldswap external fanout 17 -> bufferH64$.  u_ldswap_dirty fanout 8 -> bufferH16$.
    wire fill_or_ldswap, fill_or_ldswap_pre;
    `OR_2(u_fill_or_ldswap, 1, fill_or_ldswap_pre, fill3_i, ld_From_V_Swap_i)
    bufferH64$ u_fill_or_ldswap_buf (.out(fill_or_ldswap), .in(fill_or_ldswap_pre));

    wire ldswap_dirty, ldswap_dirty_pre;
    `AND_2(u_ldswap_dirty, 1, ldswap_dirty_pre, ld_From_V_Swap_i, V_Cache_SwapBuf_DirtyBit)
    bufferH16$ u_ldswap_dirty_buf (.out(ldswap_dirty), .in(ldswap_dirty_pre));

    wire [7:0] valid_we;
    wire [7:0] dirty_we;
    wire [7:0] dirty_d;
    wire [7:0] dirty_ws_event;
    wire [7:0] dirty_fill_event;

    genvar gtl;
    generate
        for (gtl = 0; gtl < 8; gtl = gtl + 1) begin : g_tag_meta
            `AND_2(u_valid_we, 1, valid_we[gtl], index_decoded[gtl], fill_or_ldswap)
            `REG_RST_WE(u_valid_reg, 1, clk, rst, valid_we[gtl], 1'b1, valid_q[gtl])

            `AND_2(u_dirty_ws_evt,   1, dirty_ws_event[gtl],   index_decoded[gtl], writeSuccess)
            `AND_2(u_dirty_fill_evt, 1, dirty_fill_event[gtl], index_decoded[gtl], fill_or_ldswap)
            `OR_2 (u_dirty_we,       1, dirty_we[gtl], dirty_ws_event[gtl], dirty_fill_event[gtl])
            `MUX_2(u_dirty_d, 1, dirty_d[gtl], ldswap_dirty, 1'b1, dirty_ws_event[gtl])
            `REG_RST_WE(u_dirty_reg, 1, clk, rst, dirty_we[gtl], dirty_d[gtl], dirty_q[gtl])
        end
    endgenerate

    // u_valid_mux external fanout 7 -> bufferH16$ on currLine_V_o output port.
    wire currLine_V_o_pre;
    `MUX_8(u_valid_mux, 1, currLine_V_o_pre,
           valid_q[0], valid_q[1], valid_q[2], valid_q[3],
           valid_q[4], valid_q[5], valid_q[6], valid_q[7],
           index)
    bufferH16$ u_currLine_V_o_buf (.out(currLine_V_o), .in(currLine_V_o_pre));
    `MUX_8(u_dirty_mux, 1, currLine_Dirty_o,
           dirty_q[0], dirty_q[1], dirty_q[2], dirty_q[3],
           dirty_q[4], dirty_q[5], dirty_q[6], dirty_q[7],
           index)

    //wire clk_45_phase;
    //`BUFFER_DELAY(u_phase, 12, 1, clk, clk_45_phase)

    wire clk_duty_mask;
    wire delay_rise;
    wire delay_fall;

    `BUFFER_DELAY(u_phase_rise, 25, 1, clk, delay_rise);
    `BUFFER_DELAY(u_phase_fall, 15, 1, clk, delay_fall);

    `AND_2(u_clk_duty_mask, 1, clk_duty_mask, delay_rise, delay_fall);

    wire wr_event_pre;
    wire wr_event_phased;
    wire WR_2_TagStore_actual;
    `AND_2(u_wr_event,    1, wr_event_pre,    rst, fill_or_ldswap)
    //`AND_2(u_wr_phased,   1, wr_event_phased, wr_event_pre, clk_45_phase)
    `AND_2(u_wr_phased,   1, wr_event_phased, wr_event_pre, clk_duty_mask)
    `INV_N(u_wr_actual,   1, wr_event_phased, WR_2_TagStore_actual)

    wire oe_or_we;
    wire not_busy;
    wire access_active;
    wire read_event;
    wire rst_and_read;
    wire OE_2_TagStore;
    `OR_2 (u_oe_or_we,     1, oe_or_we,      oe_i, we_i)
    `INV_N(u_not_busy,     1, bankControllerBusy_i, not_busy)
    `AND_2(u_access_act,   1, access_active, oe_or_we, not_busy)
    `OR_2 (u_read_event,   1, read_event,    access_active, write2_Dwap_i)
    `AND_2(u_rst_and_read, 1, rst_and_read,  rst, read_event)
    `INV_N(u_oe_actual,    1, rst_and_read,  OE_2_TagStore)

    wire [7:0] DIN_2_TagStore;
    wire [7:0] DOUT_2_TagStore_extended;
    assign DIN_2_TagStore = {2'b00, tag_in};

    ram8b8w$ tag_store_ramCell (
        .A   (index),
        .WR  (WR_2_TagStore_actual),
        .DIN (DIN_2_TagStore),
        .OE  (OE_2_TagStore),
        .DOUT(DOUT_2_TagStore_extended)
    );

    assign tagOut_o = DOUT_2_TagStore_extended[5:0];

endmodule
