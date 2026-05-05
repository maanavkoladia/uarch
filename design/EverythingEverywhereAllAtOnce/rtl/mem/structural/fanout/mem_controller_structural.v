// ============================================================================
// mem_controller_structural.v
// ============================================================================
// Structural Verilog-2005 conversion of mem_controller.sv
//
// All struct interfaces flattened to packed bit vectors.
// All always_ff -> REG_RST_WE cells.
// All always_comb -> assign + gate instantiations.
// mem_controller_fsm instantiated directly (already structural).
// genvars/generate used for repeated structures.
// ============================================================================


module mem_controller(
    input wire clk,
    input wire rst,  // active low

    // address bus (input only, mem never drives)
    input wire [14:0] address_bus,

    // data bus
    inout wire [31:0] data_bus,

    // DTE inputs (dte_2_mem_t flattened)
    input wire dte_ld_req,
    input wire dte_st_req,
    input wire [3:0] dte_permission2DriveBus,

    // DTE output (mem_2_dte_t flattened)
    output wire ToDTE_mem_Ready,

    // Scheduler output (mem_2_scheduler_t: writeBuf_V[8])
    output wire [7:0] ToScheduler_writeBuf_V,

    // Bank command outputs (64 banks, all packed)
    // ld_address:  64 banks x 5 bits = 320 bits
    output wire [ 64*5-1:0] bank_cmd_ld_address,
    // st_address:  64 banks x 5 bits = 320 bits
    output wire [ 64*5-1:0] bank_cmd_st_address,
    // start_store: 64 banks x 1 bit
    output wire [     63:0] bank_cmd_start_store,
    // ld_address_change: 64 banks x 1 bit
    output wire [     63:0] bank_cmd_ld_address_change,
    // driveMemBus: 64 banks x 1 bit
    output wire [     63:0] bank_cmd_driveMemBus,
    // writeBuf: 8 groups x 128 bits = 1024 bits (banks in same group share)
    output wire [8*128-1:0] bank_cmd_writeBuf,

    // Bank inputs (mem_bank_out_t flattened, 64 banks)
    input wire [63:0] banks_precharged,
    input wire [63:0] banks_clear_writebufV
);

    // ================================================================
    // ADDRESS FIELD EXTRACTION
    // ================================================================
    wire [3:0] chipNum;  // address_bus[9:6],  selects 1-of-16 chips
    wire [1:0] bankBits_InChip;  // address_bus[5:4],  selects bank within chip
    wire [4:0] rowBit;  // address_bus[14:10], SRAM row address
    wire [5:0] bank_num_for_chip;  // {chipNum, bankBits_InChip}, 1-of-64 bank
    wire [2:0] bankGroup;  // address_bus[6:4],  selects 1-of-8 bank groups

    assign chipNum           = address_bus[9:6];
    assign bankBits_InChip   = address_bus[5:4];
    assign rowBit            = address_bus[14:10];
    assign bank_num_for_chip = {chipNum, bankBits_InChip};
    assign bankGroup         = address_bus[6:4];

    // ================================================================
    // FSM (already structural, instantiate directly)
    // ================================================================
    wire [3:0] fsm_state_bits;
    wire fsm_mem_ready;
    wire fsm_set_ld_tristate;
    wire fsm_start_store;
    wire fsm_ld_address_changed;
    wire fsm_set_WriteBuf_V;
    wire fsm_fill0, fsm_fill1, fsm_fill2, fsm_fill3;
    wire hit_into_fsm;

    mem_controller_fsm u0_fsm (
        .clk                 (clk),
        .rst                 (rst),
        .ld_req_i            (dte_ld_req),
        .write_req_i         (dte_st_req),
        .hit_i               (hit_into_fsm),
        .S_0                 (fsm_state_bits[0]),
        .S_1                 (fsm_state_bits[1]),
        .S_2                 (fsm_state_bits[2]),
        .S_3                 (fsm_state_bits[3]),
        .mem_ready_o         (fsm_mem_ready),
        .set_ld_tristate_o   (fsm_set_ld_tristate),
        .start_store_o       (fsm_start_store),
        .ld_address_changed_o(fsm_ld_address_changed),
        .set_WriteBuf_V_o    (fsm_set_WriteBuf_V),
        .fill0_o             (fsm_fill0),
        .fill1_o             (fsm_fill1),
        .fill2_o             (fsm_fill2),
        .fill3_o             (fsm_fill3)
    );

    // ================================================================
    // CHIP TABLE: 16 chips, each with a 15-bit address register
    // ================================================================
    // Reset: address <= 0
    // Write: when fsm_ld_address_changed AND chipNum == i, latch address_bus

    // One-hot chip select
    wire [15:0] chip_sel_oh;
    `DECODER_N(u_chip_dec, 4, chipNum, chip_sel_oh)

    // Per-chip WE = chip_sel_oh[i] & fsm_ld_address_changed
    wire [15:0] chip_addr_we;
    // Chip address registers DUPLICATED x2 -- _a feeds the MUX_16 (1 load
    // per row bit), _b feeds the 4 bank_cmd_ld_address assigns (4 loads
    // per row bit). With each copy now driving <=4 leaf pins per bit,
    // no buffer is needed (0 ns added). Same WE/clk/rst feeds both.
    wire [14:0] chip_addr_a[0:15];
    wire [14:0] chip_addr_b[0:15];
    wire [4:0]  chip_row[0:15];     // for MUX_16
    wire [4:0]  chip_row_b[0:15];   // for the 4 bank_cmd_ld_address assigns

    genvar ci;
    generate
        for (ci = 0; ci < 16; ci = ci + 1) begin : g_chip
            `AND_2(u_we, 1, chip_addr_we[ci], chip_sel_oh[ci], fsm_ld_address_changed)

            `REG_RST_WE(u_addr_a, 15, clk, rst, chip_addr_we[ci], address_bus[14:0], chip_addr_a[ci])
            `REG_RST_WE(u_addr_b, 15, clk, rst, chip_addr_we[ci], address_bus[14:0], chip_addr_b[ci])

            assign chip_row[ci]   = chip_addr_a[ci][14:10];
            assign chip_row_b[ci] = chip_addr_b[ci][14:10];
        end
    endgenerate

    // ================================================================
    // BANK GROUP TABLE: 8 groups
    // ================================================================

    // ---- One-hot bank-group select ----
    wire [7:0] bg_sel_oh;
    `DECODER_N(u_bg_dec, 3, bankGroup, bg_sel_oh)

    // ---- writeBuf_Valid (1-bit per group) ----
    //   SET   = fsm_set_WriteBuf_V & bg_sel_oh[i]
    //   CLEAR = OR(banks_clear_writebufV for every bank in group i)
    //   Under new mapping bank b is in group b%8, so group ci contains
    //   banks {ci, ci+8, ci+16, ci+24, ci+32, ci+40, ci+48, ci+56}.
    //   Priority: clear overrides set (matches original SV loop ordering)
    //   D = set & ~clear,  WE = set | clear

    wire [7:0] bg_writeBufV;
    wire [7:0] bg_set, bg_clr, bg_any_chg, bg_clr_inv, bg_new_val;

    generate
        for (ci = 0; ci < 8; ci = ci + 1) begin : g_wbv

            // SET
            `AND_2(u_set, 1, bg_set[ci], fsm_set_WriteBuf_V, bg_sel_oh[ci])

            // CLEAR: OR-reduce clear_writebufV from the 8 banks in group ci
            // (SV: bankGroupTable[i % 8].writeBuf_Valid <= 0  for bank i)
            `OR_8(u_cfn, 1, bg_clr[ci], banks_clear_writebufV[ci+0],
                  banks_clear_writebufV[ci+8],  banks_clear_writebufV[ci+16],
                  banks_clear_writebufV[ci+24], banks_clear_writebufV[ci+32],
                  banks_clear_writebufV[ci+40], banks_clear_writebufV[ci+48],
                  banks_clear_writebufV[ci+56])

            // D logic
            `OR_2(u_any, 1, bg_any_chg[ci], bg_set[ci], bg_clr[ci])
            `INV_N(u_ci, 1, bg_clr[ci], bg_clr_inv[ci])
            `AND_2(u_nv, 1, bg_new_val[ci], bg_set[ci], bg_clr_inv[ci])

            `REG_RST_WE(u_wbv, 1, clk, rst, bg_any_chg[ci], bg_new_val[ci], bg_writeBufV[ci])
        end
    endgenerate

    // ---- bankGroup address registers (15 bits each) ----
    wire [14:0] bg_addr[0:7];
    wire [7:0] bg_addr_we;
    wire [4:0] bg_row[0:7];

    generate
        for (ci = 0; ci < 8; ci = ci + 1) begin : g_bg_addr
            `AND_2(u_we, 1, bg_addr_we[ci], fsm_set_WriteBuf_V, bg_sel_oh[ci])

            `REG_RST_WE(u_ar, 15, clk, rst, bg_addr_we[ci], address_bus[14:0], bg_addr[ci])

            assign bg_row[ci] = bg_addr[ci][14:10];
        end
    endgenerate

    // ---- bankGroup writeBuf (128 bits = 16 bytes per group) ----
    // fill0 -> bytes 0-3,  fill1 -> bytes 4-7
    // fill2 -> bytes 8-11, fill3 -> bytes 12-15
    // Each fill loads 4 bytes from data_bus[31:0].
    // WE for byte in group i = fillX & bg_sel_oh[i]

    wire [127:0] bg_wb[0:7];

    generate
        for (ci = 0; ci < 8; ci = ci + 1) begin : g_bg_wb
            wire f0_we, f1_we, f2_we, f3_we;
            `AND_2(u_f0, 1, f0_we, fsm_fill0, bg_sel_oh[ci])
            `AND_2(u_f1, 1, f1_we, fsm_fill1, bg_sel_oh[ci])
            `AND_2(u_f2, 1, f2_we, fsm_fill2, bg_sel_oh[ci])
            `AND_2(u_f3, 1, f3_we, fsm_fill3, bg_sel_oh[ci])

            // fill0: bytes 0-3
            `REG_RST_WE(u_b0, 8, clk, rst, f0_we, data_bus[7:0], bg_wb[ci][7:0])
            `REG_RST_WE(u_b1, 8, clk, rst, f0_we, data_bus[15:8], bg_wb[ci][15:8])
            `REG_RST_WE(u_b2, 8, clk, rst, f0_we, data_bus[23:16], bg_wb[ci][23:16])
            `REG_RST_WE(u_b3, 8, clk, rst, f0_we, data_bus[31:24], bg_wb[ci][31:24])
            // fill1: bytes 4-7
            `REG_RST_WE(u_b4, 8, clk, rst, f1_we, data_bus[7:0], bg_wb[ci][39:32])
            `REG_RST_WE(u_b5, 8, clk, rst, f1_we, data_bus[15:8], bg_wb[ci][47:40])
            `REG_RST_WE(u_b6, 8, clk, rst, f1_we, data_bus[23:16], bg_wb[ci][55:48])
            `REG_RST_WE(u_b7, 8, clk, rst, f1_we, data_bus[31:24], bg_wb[ci][63:56])
            // fill2: bytes 8-11
            `REG_RST_WE(u_b8, 8, clk, rst, f2_we, data_bus[7:0], bg_wb[ci][71:64])
            `REG_RST_WE(u_b9, 8, clk, rst, f2_we, data_bus[15:8], bg_wb[ci][79:72])
            `REG_RST_WE(u_b10, 8, clk, rst, f2_we, data_bus[23:16], bg_wb[ci][87:80])
            `REG_RST_WE(u_b11, 8, clk, rst, f2_we, data_bus[31:24], bg_wb[ci][95:88])
            // fill3: bytes 12-15
            `REG_RST_WE(u_b12, 8, clk, rst, f3_we, data_bus[7:0], bg_wb[ci][103:96])
            `REG_RST_WE(u_b13, 8, clk, rst, f3_we, data_bus[15:8], bg_wb[ci][111:104])
            `REG_RST_WE(u_b14, 8, clk, rst, f3_we, data_bus[23:16], bg_wb[ci][119:112])
            `REG_RST_WE(u_b15, 8, clk, rst, f3_we, data_bus[31:24], bg_wb[ci][127:120])
        end
    endgenerate

    // ================================================================
    // OUTPUT: bank_cmd_ld_address  (64 banks x 5 bits)
    // ================================================================
    // Bank b is in chip b/4. Its ld_address = chip_row[b/4].
    genvar bi;
    generate
        for (bi = 0; bi < 64; bi = bi + 1) begin : g_ld_addr
            assign bank_cmd_ld_address[bi*5+:5] = chip_row_b[bi/4];
        end
    endgenerate

    // ================================================================
    // OUTPUT: bank_cmd_ld_address_change  (64 banks)
    // ================================================================
    // Default 0. When fsm_ld_address_changed, set for all banks in selected chip.
    // bank b: ld_addr_change = chip_sel_oh[b/4] & fsm_ld_address_changed
    generate
        for (bi = 0; bi < 64; bi = bi + 1) begin : g_ld_chg
            `AND_2(u_lc, 1, bank_cmd_ld_address_change[bi], chip_sel_oh[bi/4],
                   fsm_ld_address_changed)
        end
    endgenerate

    // ================================================================
    // OUTPUT: bank_cmd_driveMemBus  (64 banks)
    // ================================================================
    // Default 0. When fsm_set_ld_tristate, set for bank_num_for_chip.
    wire [63:0] bank_oh;
    `DECODER_N(u_bank_dec, 6, bank_num_for_chip, bank_oh)

    // replicate scalar to 64 bits
    wire [63:0] fsm_set_ld_tristate_vec;
    assign fsm_set_ld_tristate_vec = {64{fsm_set_ld_tristate}};

    // single wide AND
    `AND_2(u_dm, 64, bank_cmd_driveMemBus, bank_oh, fsm_set_ld_tristate_vec)
    // ================================================================
    // OUTPUT: bank_cmd_st_address  (64 banks x 5 bits)
    // ================================================================
    // Bank b is in bank-group b%8.  st_address = bg_row[b%8].
    // (SV: bank_cmds_o[(NUM_BANKS_PER_BANK_GROUP*j)+i].st_address =
    //      bankGroupTable[i].address[14:10], i=group, j=bank-in-group)
    generate
        for (bi = 0; bi < 64; bi = bi + 1) begin : g_st_addr
            assign bank_cmd_st_address[bi*5+:5] = bg_row[bi%8];
        end
    endgenerate

    // ================================================================
    // OUTPUT: bank_cmd_start_store  (64 banks)
    // ================================================================
    // Default 0. When fsm_start_store, set for bank {addr[9:7], bankGroup}.
    // SV: bank_num_in_bank_group = {address_bus[9:7], bankGroup}
    //   = {address_bus[9:7], address_bus[6:4]} = address_bus[9:4]
    wire [5:0] store_bank_idx;
    assign store_bank_idx = {address_bus[9:7], bankGroup};

    // ---- decoder ----
    wire [63:0] store_oh;
    `DECODER_N(u_store_dec, 6, store_bank_idx, store_oh)

    // ---- replicate FSM signal ----
    wire [63:0] fsm_start_store_vec;
    assign fsm_start_store_vec = {64{fsm_start_store}};

    // ---- single wide AND ----
    `AND_2(u_ss, 64, bank_cmd_start_store, store_oh, fsm_start_store_vec)

    // ================================================================
    // OUTPUT: bank_cmd_writeBuf  (8 groups x 128 bits)
    // ================================================================
    // Banks in same group share the same writeBuf.
    generate
        for (ci = 0; ci < 8; ci = ci + 1) begin : g_wb_out
            assign bank_cmd_writeBuf[ci*128+:128] = bg_wb[ci];
        end
    endgenerate

    // ================================================================
    // OUTPUT: ToScheduler_writeBuf_V
    // ================================================================
    assign ToScheduler_writeBuf_V = bg_writeBufV;

    // ================================================================
    // OUTPUT: ToDTE_mem_Ready
    // ================================================================
    assign ToDTE_mem_Ready = fsm_mem_ready;

    // ================================================================
    // HIT LOGIC
    // ================================================================
    // hit = dte_ld_req
    //     & (chipTable[chipNum].address[14:10] == address_bus[14:10])
    //     & banks_precharged[bank_num_for_chip]
    //
    // 1) 16:1 mux of chip_row[chipNum] (5-bit, 4-level binary tree)
    // 2) 5-bit comparator vs rowBit
    // 3) 64:1 mux of banks_precharged[bank_num_for_chip] (6-level binary tree)
    // 4) 3-input AND

    // ---- 16:1 mux of chip_row, selected by chipNum ----
    wire [4:0] sel_chip_row;

    `MUX_16(u_chiprow, 5, sel_chip_row, chip_row[0], chip_row[1], chip_row[2], chip_row[3],
            chip_row[4], chip_row[5], chip_row[6], chip_row[7], chip_row[8], chip_row[9],
            chip_row[10], chip_row[11], chip_row[12], chip_row[13], chip_row[14], chip_row[15],
            chipNum)
    // ---- 5-bit comparator ----
    wire addr_match;
    `CMP_N(u_cmp, 5, addr_match, sel_chip_row, rowBit)

    wire sel_precharge;

    `MUX_64(u_pre, 1, sel_precharge, banks_precharged[0], banks_precharged[1], banks_precharged[2],
            banks_precharged[3], banks_precharged[4], banks_precharged[5], banks_precharged[6],
            banks_precharged[7], banks_precharged[8], banks_precharged[9], banks_precharged[10],
            banks_precharged[11], banks_precharged[12], banks_precharged[13], banks_precharged[14],
            banks_precharged[15], banks_precharged[16], banks_precharged[17], banks_precharged[18],
            banks_precharged[19], banks_precharged[20], banks_precharged[21], banks_precharged[22],
            banks_precharged[23], banks_precharged[24], banks_precharged[25], banks_precharged[26],
            banks_precharged[27], banks_precharged[28], banks_precharged[29], banks_precharged[30],
            banks_precharged[31], banks_precharged[32], banks_precharged[33], banks_precharged[34],
            banks_precharged[35], banks_precharged[36], banks_precharged[37], banks_precharged[38],
            banks_precharged[39], banks_precharged[40], banks_precharged[41], banks_precharged[42],
            banks_precharged[43], banks_precharged[44], banks_precharged[45], banks_precharged[46],
            banks_precharged[47], banks_precharged[48], banks_precharged[49], banks_precharged[50],
            banks_precharged[51], banks_precharged[52], banks_precharged[53], banks_precharged[54],
            banks_precharged[55], banks_precharged[56], banks_precharged[57], banks_precharged[58],
            banks_precharged[59], banks_precharged[60], banks_precharged[61], banks_precharged[62],
            banks_precharged[63], bank_num_for_chip)

    // ---- Final hit AND ----
    `AND_3(u_hit, 1, hit_into_fsm, dte_ld_req, addr_match, sel_precharge)

endmodule
