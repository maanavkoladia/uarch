// Structural Verilog-2005 port of
//   rtl/DCache/DCache_Block/DCache_Bank/DCache_Bank_DataStore.sv

`include "STDCell_Macros.vh"
`include "DCache_common_define.vh"

module DCache_Bank_DataStore (
    input  wire                                       clk,
    input  wire                                       rst,                  // active-low
    input  wire [`P_ADDR_W                  - 1 : 0]  p_addr_i,
    input  wire                                       oe,
    input  wire                                       we,
    input  wire                                       ld_From_V_Swap_i,
    input  wire                                       fill0_i,
    input  wire                                       fill1_i,
    input  wire                                       fill2_i,
    input  wire                                       fill3_i,
    input  wire                                       write2_Dwap_i,
    input  wire                                       bankControllerBusy_i,
    input  wire [`CL_W                      - 1 : 0]  st_q_data,
    input  wire [`VEC_W                     - 1 : 0]  st_data_vec,
    input  wire [`CL_W                      - 1 : 0]  VCache_SwapBuf_Line_i,
    input  wire [`DATA_BUS_WIDTH_BITS       - 1 : 0]  dataBus_i,            // 32 bits
    input  wire                                       tagStore_hit_i,
    output wire [`CL_W                      - 1 : 0]  lineOut_o
);

    // Address slice
    wire [`DCACHE_BANK_INDEX_W - 1 : 0] paddr_idx;
    assign paddr_idx = p_addr_i[`DCACHE_BANK_INDEX_UB : `DCACHE_BANK_INDEX_LB];

    // Phased clock
    wire clk_45_phase;
    `BUFFER_DELAY(u_clk_phase, `CLK_PHASE_BUFFER_STAGES, 1, clk, clk_45_phase)

    // Per-byte fill match: bits[3:0]=fill0, [7:4]=fill1, [11:8]=fill2,
    //  [15:12]=fill3 ; ld_v_swap broadcast to all 16
    wire [15:0] fillN_match_vec;
    assign fillN_match_vec = { {4{fill3_i}}, {4{fill2_i}}, {4{fill1_i}}, {4{fill0_i}} };

    wire [15:0] ld_v_swap_vec;
    assign ld_v_swap_vec = {16{ld_From_V_Swap_i}};

    wire [15:0] fill_match_vec;
    `OR_2(or_fillmatch, 16, fill_match_vec, ld_v_swap_vec, fillN_match_vec)

    // Default-path store-data write enable per byte (no fill)
    //   store_wr[i] = st_data_vec[i] & we & ~busy & tagStore_hit
    wire        busy_inv;
    `INV_N(inv_busy_ds, 1, bankControllerBusy_i, busy_inv)

    wire [15:0] we_vec;
    wire [15:0] busy_inv_vec;
    wire [15:0] hit_vec;
    assign we_vec       = {16{we}};
    assign busy_inv_vec = {16{busy_inv}};
    assign hit_vec      = {16{tagStore_hit_i}};

    wire [15:0] store_wr_v0;
    wire [15:0] store_wr_v1;
    wire [15:0] store_wr_vec;
    `AND_2(and_sw0, 16, store_wr_v0,  st_data_vec, we_vec)
    `AND_2(and_sw1, 16, store_wr_v1,  busy_inv_vec, hit_vec)
    `AND_2(and_sw,  16, store_wr_vec, store_wr_v0,  store_wr_v1)

    // want_write_vec, gated by phase & rst, then inverted -> active-low WR
    wire [15:0] want_write_vec;
    wire        phase_and_rst;
    wire [15:0] phase_rst_vec;
    wire [15:0] write_active_vec;
    wire [15:0] WR_actual_vec;

    `OR_2 (or_want, 16, want_write_vec, fill_match_vec, store_wr_vec)
    `AND_2(and_phr, 1,  phase_and_rst, clk_45_phase, rst)
    assign phase_rst_vec = {16{phase_and_rst}};
    `AND_2(and_wact, 16, write_active_vec, want_write_vec, phase_rst_vec)
    `INV_N(inv_wract, 16, write_active_vec, WR_actual_vec)

    // OE for cells (active-low)
    //   OE_actual = ~(write2_Dwap | (oe & ~busy))
    wire access_active;
    wire oe_or;
    wire OE_actual;
    `AND_2(and_oe_acc, 1, access_active, oe,            busy_inv)
    `OR_2 (or_oe_ds,   1, oe_or,         write2_Dwap_i, access_active)
    `INV_N(inv_oe_ds,  1, oe_or,         OE_actual)

    // DIN selection. dataBus broadcasted to four 32-bit lanes.
    wire [31:0]  dataBus_lane;
    assign dataBus_lane = dataBus_i;

    wire [127:0] st_or_bus_vec;
    `MUX_2(mux_din_q0, 32, st_or_bus_vec[31:0],   st_q_data[31:0],   dataBus_lane, fill0_i)
    `MUX_2(mux_din_q1, 32, st_or_bus_vec[63:32],  st_q_data[63:32],  dataBus_lane, fill1_i)
    `MUX_2(mux_din_q2, 32, st_or_bus_vec[95:64],  st_q_data[95:64],  dataBus_lane, fill2_i)
    `MUX_2(mux_din_q3, 32, st_or_bus_vec[127:96], st_q_data[127:96], dataBus_lane, fill3_i)

    wire [127:0] DIN_2_DataStore_vec;
    `MUX_2(mux_din_vc, 128, DIN_2_DataStore_vec, st_or_bus_vec, VCache_SwapBuf_Line_i, ld_From_V_Swap_i)

    // 16 RAM cells (one per byte)
    wire [127:0] DOUT_DataStore_vec;

    genvar gi;
    generate
        for (gi = 0; gi < 16; gi = gi + 1) begin : g_data_cells
            ram8b8w$ dcache_bank_data_store_ramCell (
                .A   (paddr_idx),
                .DIN (DIN_2_DataStore_vec[gi*8 +: 8]),
                .OE  (OE_actual),
                .WR  (WR_actual_vec[gi]),
                .DOUT(DOUT_DataStore_vec[gi*8 +: 8])
            );
        end
    endgenerate

    assign lineOut_o = DOUT_DataStore_vec;

endmodule
