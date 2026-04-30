// Structural Verilog-2005 port of
//   rtl/DCache/DCache_Block/DCache_Bank/DCache_Bank_TagStore.sv
//
// Single ram8b8w$ holds 8 tags (6 bits each, padded to 8). Per-line
// {valid, dirty} flops form a metadata store of 16 bits total. Read path:
// the cell drives DOUT for the currently-addressed line; the metadata flops
// are mux'd by the index. Write path: phased active-low WR window driven by
// (ld_From_V_Swap | fill3) AND clk_45_phase.

`include "STDCell_Macros.vh"
`include "DCache_common_define.vh"

module DCache_Bank_TagStore (
    input  wire                                clk,
    input  wire                                rst,                 // active-low
    input  wire [`P_ADDR_W            - 1 : 0] p_addr_i,
    input  wire                                oe_i,
    input  wire                                we_i,
    input  wire                                ld_From_V_Swap_i,
    input  wire                                V_Cache_SwapBuf_DirtyBit,
    input  wire                                fill3_i,
    input  wire                                write2_Dwap_i,
    input  wire                                bankControllerBusy_i,
    input  wire                                writeSuccess,
    output wire [`DCACHE_BANK_TAG_W   - 1 : 0] tagOut_o,
    output wire                                currLine_V_o,
    output wire                                currLine_Dirty_o
);

    //------------------------------------------------------------------
    // Address-field slice (pure routing)
    //------------------------------------------------------------------
    wire [`DCACHE_BANK_TAG_W   - 1 : 0] paddr_tag;
    wire [`DCACHE_BANK_INDEX_W - 1 : 0] paddr_idx;

    assign paddr_tag = p_addr_i[`DCACHE_BANK_TAG_UB   : `DCACHE_BANK_TAG_LB];
    assign paddr_idx = p_addr_i[`DCACHE_BANK_INDEX_UB : `DCACHE_BANK_INDEX_LB];

    //------------------------------------------------------------------
    // Phased clock for the write window
    //------------------------------------------------------------------
    wire clk_45_phase;
    `BUFFER_DELAY(u_clk_phase, `CLK_PHASE_BUFFER_STAGES, 1, clk, clk_45_phase)

    //------------------------------------------------------------------
    // Tag-cell write enable (active-low to ram8b8w$.WR)
    //   Source: WR_clk = ~(rst & (ld_v_swap | fill3))
    //           WR_actual = ~(rst & (ld_v_swap | fill3) & clk_45_phase)
    //------------------------------------------------------------------
    wire load_or_fill;
    wire raw_we;
    wire raw_we_phased;
    wire wr_actual;

    `OR_2 (or_loadfill,  1, load_or_fill, ld_From_V_Swap_i, fill3_i)
    `AND_2(and_rawwe,    1, raw_we,        rst,          load_or_fill)
    `AND_2(and_wephased, 1, raw_we_phased, raw_we,       clk_45_phase)
    `INV_N(inv_wractual, 1, raw_we_phased, wr_actual)

    //------------------------------------------------------------------
    // Tag-cell output enable (active-low to ram8b8w$.OE)
    //   With rst=1: OE = ~(((oe|we) & ~busy) | write2_Dwap)
    //   With rst=0: OE = 1 (read disabled). Both factored together.
    //------------------------------------------------------------------
    wire busy_inv;
    wire access_or;
    wire access_active;
    wire oe_or;
    wire oe_or_rstgated;
    wire oe_actual;

    `INV_N(inv_busy,     1, bankControllerBusy_i, busy_inv)
    `OR_2 (or_access,    1, access_or,    oe_i,          we_i)
    `AND_2(and_access,   1, access_active, access_or,    busy_inv)
    `OR_2 (or_oe,        1, oe_or,         access_active, write2_Dwap_i)
    `AND_2(and_oe_rst,   1, oe_or_rstgated, oe_or,       rst)
    `INV_N(inv_oeactual, 1, oe_or_rstgated, oe_actual)

    //------------------------------------------------------------------
    // The tag RAM cell.  DIN is paddr_tag zero-extended to 8 bits.
    //------------------------------------------------------------------
    wire [7:0] cell_dout;
    wire [7:0] cell_din;
    assign cell_din = {2'b00, paddr_tag};

    ram8b8w$ tag_store_ramCell (
        .A   (paddr_idx),
        .DIN (cell_din),
        .OE  (oe_actual),
        .WR  (wr_actual),
        .DOUT(cell_dout)
    );

    assign tagOut_o = cell_dout[`DCACHE_BANK_TAG_W - 1 : 0];

    //------------------------------------------------------------------
    // Per-line metadata store: 8 lines x {valid, dirty} (16 flops)
    //   - valid is set on (fill3 | ld_v_swap); never cleared at runtime.
    //   - dirty is set on writeSuccess (1) or, if writeSuccess is 0, takes
    //     (ld_v_swap & V_DirtyBit) on a fill/swap.
    //
    // 1-of-8 line decode from index drives the per-line WE.
    //------------------------------------------------------------------
    wire [7:0] line_sel;
    `DECODER_N(u_idx_dec, 3, paddr_idx, line_sel)

    //   shared "metadata source" signals
    wire writeSuccess_inv;
    wire fill_or_swap;
    wire fill_or_swap_or_ws;
    wire ldswap_and_dirty;
    wire dirty_d;

    `INV_N(inv_ws,        1, writeSuccess,    writeSuccess_inv)
    //   fill_or_swap reuses load_or_fill above (same expression)
    assign fill_or_swap = load_or_fill;
    `OR_2 (or_meta_we,    1, fill_or_swap_or_ws, fill_or_swap, writeSuccess)
    `AND_2(and_swap_dty,  1, ldswap_and_dirty,   ld_From_V_Swap_i, V_Cache_SwapBuf_DirtyBit)
    //   dirty_d = writeSuccess ? 1 : (ld_v_swap & V_DirtyBit)
    //          MUX_2: sel=writeSuccess, in1=1, in0=ldswap_and_dirty
    `MUX_2(mux_dirtyd,    1, dirty_d,            ldswap_and_dirty, 1'b1, writeSuccess)

    wire [7:0] valid_q;
    wire [7:0] dirty_q;
    wire [7:0] valid_we_arr;
    wire [7:0] dirty_we_arr;

    //   Per-line WE: gate the global WE strobes by line_sel[i]
    `AND_2(and_v_we, 8, valid_we_arr, line_sel, {8{fill_or_swap}})
    `AND_2(and_d_we, 8, dirty_we_arr, line_sel, {8{fill_or_swap_or_ws}})

    //   Per-line flops (1 bit each): valid is always set to 1 when WE fires.
    `REG_RST_WE(ff_valid_l0, 1, clk, rst, valid_we_arr[0], 1'b1, valid_q[0])
    `REG_RST_WE(ff_valid_l1, 1, clk, rst, valid_we_arr[1], 1'b1, valid_q[1])
    `REG_RST_WE(ff_valid_l2, 1, clk, rst, valid_we_arr[2], 1'b1, valid_q[2])
    `REG_RST_WE(ff_valid_l3, 1, clk, rst, valid_we_arr[3], 1'b1, valid_q[3])
    `REG_RST_WE(ff_valid_l4, 1, clk, rst, valid_we_arr[4], 1'b1, valid_q[4])
    `REG_RST_WE(ff_valid_l5, 1, clk, rst, valid_we_arr[5], 1'b1, valid_q[5])
    `REG_RST_WE(ff_valid_l6, 1, clk, rst, valid_we_arr[6], 1'b1, valid_q[6])
    `REG_RST_WE(ff_valid_l7, 1, clk, rst, valid_we_arr[7], 1'b1, valid_q[7])

    `REG_RST_WE(ff_dirty_l0, 1, clk, rst, dirty_we_arr[0], dirty_d, dirty_q[0])
    `REG_RST_WE(ff_dirty_l1, 1, clk, rst, dirty_we_arr[1], dirty_d, dirty_q[1])
    `REG_RST_WE(ff_dirty_l2, 1, clk, rst, dirty_we_arr[2], dirty_d, dirty_q[2])
    `REG_RST_WE(ff_dirty_l3, 1, clk, rst, dirty_we_arr[3], dirty_d, dirty_q[3])
    `REG_RST_WE(ff_dirty_l4, 1, clk, rst, dirty_we_arr[4], dirty_d, dirty_q[4])
    `REG_RST_WE(ff_dirty_l5, 1, clk, rst, dirty_we_arr[5], dirty_d, dirty_q[5])
    `REG_RST_WE(ff_dirty_l6, 1, clk, rst, dirty_we_arr[6], dirty_d, dirty_q[6])
    `REG_RST_WE(ff_dirty_l7, 1, clk, rst, dirty_we_arr[7], dirty_d, dirty_q[7])

    //   Read out the addressed line via 8-to-1 muxes.
    `MUX_8(mux_v_out, 1, currLine_V_o,
           valid_q[0], valid_q[1], valid_q[2], valid_q[3],
           valid_q[4], valid_q[5], valid_q[6], valid_q[7], paddr_idx)

    `MUX_8(mux_d_out, 1, currLine_Dirty_o,
           dirty_q[0], dirty_q[1], dirty_q[2], dirty_q[3],
           dirty_q[4], dirty_q[5], dirty_q[6], dirty_q[7], paddr_idx)

endmodule
