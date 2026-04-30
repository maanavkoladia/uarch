// Structural Verilog-2005 port of
//   rtl/DCache/DCache_Block/VCache/VCache_DataStore.sv
//
// 16x ram8b4w$ cells (one per byte). Per-cell address is the same 2-bit
// VCache way index, sourced via priority mux:
//   if (WR_2_EB && !useSavedIDX) -> evictionIDX
//   else if (useSavedIDX)        -> savedIDX
//   else                         -> hitIDX
// Per-byte write enable: read_D_SWAP fills all bytes; otherwise per-byte
// driven by st_data_vec & we & ~busy & hit. Phased active-low WR.
// OE has an extra delayed-confirmation (#2ns) gate.

`include "STDCell_Macros.vh"
`include "DCache_common_define.vh"

module VCache_DataStore (
    input  wire                                       clk_i,
    input  wire                                       rst_i,                // active-low
    input  wire [`P_ADDR_W                  - 1 : 0]  p_addr_i,
    input  wire                                       oe_i,
    input  wire                                       we_i,
    input  wire [`CL_W                      - 1 : 0]  st_q_data_i,
    input  wire [`VEC_W                     - 1 : 0]  st_data_vec_i,
    input  wire [`CL_W                      - 1 : 0]  DCache_SwapBuf_Line_i,
    input  wire                                       read_D_SWAP_i,
    input  wire                                       Write_VSWAP_i,
    input  wire                                       busy_i,
    input  wire                                       WR_2_EB,
    input  wire                                       tagStore_hit_i,
    input  wire                                       useSavedIDX,
    input  wire [`VCACHE_LINE_IDX_W         - 1 : 0]  hitIDX_i,
    input  wire [`VCACHE_LINE_IDX_W         - 1 : 0]  evictionIDX_i,
    input  wire [`VCACHE_LINE_IDX_W         - 1 : 0]  savedIDX_i,
    output wire [`CL_W                      - 1 : 0]  VCache_DataStore_LineOut_o
);

    //==================================================================
    // Phased clock
    //==================================================================
    wire clk_phase_45;
    `BUFFER_DELAY(u_clk_phase, `CLK_PHASE_BUFFER_STAGES, 1, clk_i, clk_phase_45)

    //==================================================================
    // Address selection (2-bit way index)
    //   level 1: hit_or_saved = useSavedIDX ? savedIDX : hitIDX
    //   level 2: addr        = (WR_2_EB & ~useSavedIDX) ? evictionIDX : hit_or_saved
    //==================================================================
    wire        useSavedIDX_inv;
    wire        wr2eb_and_notSaved;
    wire [`VCACHE_LINE_IDX_W - 1 : 0] addr_lvl1;
    wire [`VCACHE_LINE_IDX_W - 1 : 0] addr_2_ds;

    `INV_N(inv_usesaved, 1, useSavedIDX, useSavedIDX_inv)
    `AND_2(and_wr2eb_ns, 1, wr2eb_and_notSaved, WR_2_EB, useSavedIDX_inv)

    `MUX_2(mux_addr_l1, `VCACHE_LINE_IDX_W, addr_lvl1, hitIDX_i, savedIDX_i,    useSavedIDX)
    `MUX_2(mux_addr_l2, `VCACHE_LINE_IDX_W, addr_2_ds, addr_lvl1, evictionIDX_i, wr2eb_and_notSaved)

    //==================================================================
    // Per-byte write enable (active-low to ram cells)
    //   want_write[i] = read_D_SWAP | (~busy & we & st_data_vec[i] & tagStore_hit)
    //==================================================================
    wire        busy_inv;
    `INV_N(inv_busy_vds, 1, busy_i, busy_inv)

    wire        we_pre0;
    wire        we_pre1;
    `AND_2(and_we_pre0, 1, we_pre0, we_i,    busy_inv)
    `AND_2(and_we_pre1, 1, we_pre1, we_pre0, tagStore_hit_i)

    wire [15:0] we_pre1_v;
    assign we_pre1_v = {16{we_pre1}};
    wire [15:0] per_byte_store;
    `AND_2(and_perbytestore, 16, per_byte_store, we_pre1_v, st_data_vec_i)

    wire [15:0] read_dswap_v;
    assign read_dswap_v = {16{read_D_SWAP_i}};

    wire [15:0] want_write_vec;
    `OR_2(or_want_write_vds, 16, want_write_vec, read_dswap_v, per_byte_store)

    wire        phase_and_rst;
    wire [15:0] phase_rst_vec;
    `AND_2(and_phase_rst_vds, 1, phase_and_rst, clk_phase_45, rst_i)
    assign phase_rst_vec = {16{phase_and_rst}};

    wire [15:0] write_active_vec;
    wire [15:0] WR_actual_vec;
    `AND_2(and_wact_vds, 16, write_active_vec, want_write_vec, phase_rst_vec)
    `INV_N(inv_wract_vds, 16, write_active_vec, WR_actual_vec)

    //==================================================================
    // DIN: (!busy & we) ? st_q_data : DCache_SwapBuf_Line
    //==================================================================
    wire        din_sel;
    `AND_2(and_din_sel, 1, din_sel, busy_inv, we_i)

    wire [`CL_W - 1 : 0] DIN_2_DataStore_vec;
    `MUX_2(mux_din_vds, `CL_W, DIN_2_DataStore_vec, DCache_SwapBuf_Line_i, st_q_data_i, din_sel)

    //==================================================================
    // OE chain
    //   OE_clk_active = WR_2_EB | Write_VSWAP | (~busy & oe)
    //   OE_delay_input_active_low = ~(rst & OE_clk_active)         (ie: !rst ? 1 : ~OE_clk_active)
    //   OE_delay_active_low       = BUFFER_DELAY(8, OE_delay_input_active_low)
    //   OE_active                 = OE_clk_active & ~OE_delay_active_low
    //   OE_actual (active-low)    = ~OE_active
    //==================================================================
    wire access_active;
    wire OE_clk_active;
    `AND_2(and_oe_acc_vds, 1, access_active, busy_inv, oe_i)
    wire oe_or_int;
    `OR_2 (or_oe_int_vds,  1, oe_or_int,    WR_2_EB, Write_VSWAP_i)
    `OR_2 (or_oe_full_vds, 1, OE_clk_active, oe_or_int, access_active)

    wire OE_clk_active_rst;
    wire OE_delay_pre;          // active-high pre-delay
    wire OE_delay_pre_inv;      // active-low pre-delay
    wire OE_delay_active_low;
    wire OE_delay_active_high;

    `AND_2(and_oe_rst_vds, 1, OE_clk_active_rst, OE_clk_active, rst_i)
    `INV_N(inv_oe_pre_vds, 1, OE_clk_active_rst, OE_delay_pre_inv)
    `BUFFER_DELAY(u_oe_delay, `OE_DELAY_BUFFER_STAGES, 1, OE_delay_pre_inv, OE_delay_active_low)
    `INV_N(inv_oe_post_vds, 1, OE_delay_active_low, OE_delay_active_high)

    wire OE_active;
    wire OE_actual;
    `AND_2(and_oe_active_vds, 1, OE_active, OE_clk_active, OE_delay_active_high)
    `INV_N(inv_oe_actual_vds, 1, OE_active, OE_actual)

    //==================================================================
    // 16 ram8b4w$ cells
    //==================================================================
    wire [`CL_W - 1 : 0] DOUT_DataStore_vec;
    genvar gi;
    generate
        for (gi = 0; gi < 16; gi = gi + 1) begin : g_vds_cells
            ram8b4w$ v_cache_data_store_ramCell (
                .A   (addr_2_ds),
                .DIN (DIN_2_DataStore_vec[gi*8 +: 8]),
                .OE  (OE_actual),
                .WR  (WR_actual_vec[gi]),
                .DOUT(DOUT_DataStore_vec[gi*8 +: 8])
            );
        end
    endgenerate

    assign VCache_DataStore_LineOut_o = DOUT_DataStore_vec;

endmodule
