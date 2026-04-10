// ============================================================================
// mem_controller_structural.v
// ============================================================================
// Structural Verilog-2005 conversion of mem_controller.sv
//
// All struct interfaces flattened to packed bit vectors.
// All always_ff -> reg_rst_we cells.
// All always_comb -> assign + gate instantiations.
// mem_controller_fsm instantiated directly (already structural).
// genvars/generate used for repeated structures.
// ============================================================================

`include "mem_controller_macros.vh"


module mem_controller_structural (
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
    wire [3:0] chipNum;  // address_bus[9:6], selects 1-of-16 chips
    wire [1:0] bankBits_InChip;  // address_bus[5:4], selects bank within chip
    wire [4:0] rowBit;  // address_bus[14:10], SRAM row address
    wire [5:0] bank_num_for_chip;  // {chipNum, bankBits_InChip}, 1-of-64 bank
    wire [2:0] bankGroup;  // address_bus[6:4], selects 1-of-8 bank groups

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
        .clk(clk),
        .rst(rst),
        .ld_req_i(dte_ld_req),
        .write_req_i(dte_st_req),
        .hit_i(hit_into_fsm),
        .S_0(fsm_state_bits[0]),
        .S_1(fsm_state_bits[1]),
        .S_2(fsm_state_bits[2]),
        .S_3(fsm_state_bits[3]),
        .mem_ready_o(fsm_mem_ready),
        .set_ld_tristate_o(fsm_set_ld_tristate),
        .start_store_o(fsm_start_store),
        .ld_address_changed_o(fsm_ld_address_changed),
        .set_WriteBuf_V_o(fsm_set_WriteBuf_V),
        .fill0_o(fsm_fill0),
        .fill1_o(fsm_fill1),
        .fill2_o(fsm_fill2),
        .fill3_o(fsm_fill3)
    );

    // ================================================================
    // CHIP TABLE: 16 chips, each with a 15-bit address register
    // ================================================================
    // Reset: address <= 0
    // Write: when fsm_ld_address_changed AND chipNum == i, latch address_bus

    // One-hot chip select
    wire [15:0] chip_sel_oh;
    decoder_onehot #(
        .WIDTH(16)
    ) u_chip_dec (
        .sel(chipNum),
        .out(chip_sel_oh)
    );

    // Per-chip WE = chip_sel_oh[i] & fsm_ld_address_changed
    wire [15:0] chip_addr_we;
    // Chip address registers: packed as 16 x 15 bits
    wire [14:0] chip_addr[0:15];
    // Row address from each chip = chip_addr[i][14:10]
    wire [4:0] chip_row[0:15];

    genvar ci;
    generate
        for (ci = 0; ci < 16; ci = ci + 1) begin : g_chip
            and2$ u_we (
                .out(chip_addr_we[ci]),
                .in0(chip_sel_oh[ci]),
                .in1(fsm_ld_address_changed)
            );

            `REG_RST_WE(u_addr, clk, rst, chip_addr_we[ci], address_bus[14:0], chip_addr[ci], 15);

            assign chip_row[ci] = chip_addr[ci][14:10];
        end
    endgenerate

    // ================================================================
    // BANK GROUP TABLE: 8 groups
    // ================================================================

    // ---- One-hot bank-group select ----
    wire [7:0] bg_sel_oh;
    decoder_onehot #(
        .WIDTH(8)
    ) u_bg_dec (
        .sel(bankGroup),
        .out(bg_sel_oh)
    );

    // ---- writeBuf_Valid (1-bit per group) ----
    //   SET   = fsm_set_WriteBuf_V & bg_sel_oh[i]
    //   CLEAR = OR(banks_clear_writebufV for every bank in group i)
    //   Priority: clear overrides set (matches original SV loop ordering)
    //   D = set & ~clear,  WE = set | clear

    wire [7:0] bg_writeBufV;
    wire [7:0] bg_set, bg_clr, bg_any_chg, bg_clr_inv, bg_new_val;

    generate
        for (ci = 0; ci < 8; ci = ci + 1) begin : g_wbv

            // SET
            and2$ u_set (
                .out(bg_set[ci]),
                .in0(fsm_set_WriteBuf_V),
                .in1(bg_sel_oh[ci])
            );

            // CLEAR: OR-reduce 8 clear_writebufV signals for banks ci*8 .. ci*8+7
            wire [3:0] clr_pair;
            or2$ u_c01 (
                .out(clr_pair[0]),
                .in0(banks_clear_writebufV[ci*8+0]),
                .in1(banks_clear_writebufV[ci*8+1])
            );
            or2$ u_c23 (
                .out(clr_pair[1]),
                .in0(banks_clear_writebufV[ci*8+2]),
                .in1(banks_clear_writebufV[ci*8+3])
            );
            or2$ u_c45 (
                .out(clr_pair[2]),
                .in0(banks_clear_writebufV[ci*8+4]),
                .in1(banks_clear_writebufV[ci*8+5])
            );
            or2$ u_c67 (
                .out(clr_pair[3]),
                .in0(banks_clear_writebufV[ci*8+6]),
                .in1(banks_clear_writebufV[ci*8+7])
            );
            wire clr_ab, clr_cd;
            or2$ u_cab (
                .out(clr_ab),
                .in0(clr_pair[0]),
                .in1(clr_pair[1])
            );
            or2$ u_ccd (
                .out(clr_cd),
                .in0(clr_pair[2]),
                .in1(clr_pair[3])
            );
            or2$ u_cfn (
                .out(bg_clr[ci]),
                .in0(clr_ab),
                .in1(clr_cd)
            );

            // D logic
            or2$ u_any (
                .out(bg_any_chg[ci]),
                .in0(bg_set[ci]),
                .in1(bg_clr[ci])
            );
            inv1$ u_ci (
                .out(bg_clr_inv[ci]),
                .in (bg_clr[ci])
            );
            and2$ u_nv (
                .out(bg_new_val[ci]),
                .in0(bg_set[ci]),
                .in1(bg_clr_inv[ci])
            );

            `REG_RST_WE(u_wbv, clk, rst, bg_any_chg[ci], bg_new_val[ci], bg_writeBufV[ci], 1);
        end
    endgenerate

    // ---- bankGroup address registers (15 bits each) ----
    wire [14:0] bg_addr[0:7];
    wire [7:0] bg_addr_we;
    wire [4:0] bg_row[0:7];

    generate
        for (ci = 0; ci < 8; ci = ci + 1) begin : g_bg_addr
            and2$ u_we (
                .out(bg_addr_we[ci]),
                .in0(fsm_set_WriteBuf_V),
                .in1(bg_sel_oh[ci])
            );

            `REG_RST_WE(u_ar, clk, rst, bg_addr_we[ci], address_bus[14:0], bg_addr[ci], 15);

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
            and2$ u_f0 (
                .out(f0_we),
                .in0(fsm_fill0),
                .in1(bg_sel_oh[ci])
            );
            and2$ u_f1 (
                .out(f1_we),
                .in0(fsm_fill1),
                .in1(bg_sel_oh[ci])
            );
            and2$ u_f2 (
                .out(f2_we),
                .in0(fsm_fill2),
                .in1(bg_sel_oh[ci])
            );
            and2$ u_f3 (
                .out(f3_we),
                .in0(fsm_fill3),
                .in1(bg_sel_oh[ci])
            );

            // fill0: bytes 0-3
            `REG_RST_WE(u_b0, clk, rst, f0_we, data_bus[7:0], bg_wb[ci][7:0], 8);
            `REG_RST_WE(u_b1, clk, rst, f0_we, data_bus[15:8], bg_wb[ci][15:8], 8);
            `REG_RST_WE(u_b2, clk, rst, f0_we, data_bus[23:16], bg_wb[ci][23:16], 8);
            `REG_RST_WE(u_b3, clk, rst, f0_we, data_bus[31:24], bg_wb[ci][31:24], 8);
            // fill1: bytes 4-7
            `REG_RST_WE(u_b4, clk, rst, f1_we, data_bus[7:0], bg_wb[ci][39:32], 8);
            `REG_RST_WE(u_b5, clk, rst, f1_we, data_bus[15:8], bg_wb[ci][47:40], 8);
            `REG_RST_WE(u_b6, clk, rst, f1_we, data_bus[23:16], bg_wb[ci][55:48], 8);
            `REG_RST_WE(u_b7, clk, rst, f1_we, data_bus[31:24], bg_wb[ci][63:56], 8);
            // fill2: bytes 8-11
            `REG_RST_WE(u_b8, clk, rst, f2_we, data_bus[7:0], bg_wb[ci][71:64], 8);
            `REG_RST_WE(u_b9, clk, rst, f2_we, data_bus[15:8], bg_wb[ci][79:72], 8);
            `REG_RST_WE(u_b10, clk, rst, f2_we, data_bus[23:16], bg_wb[ci][87:80], 8);
            `REG_RST_WE(u_b11, clk, rst, f2_we, data_bus[31:24], bg_wb[ci][95:88], 8);
            // fill3: bytes 12-15
            `REG_RST_WE(u_b12, clk, rst, f3_we, data_bus[7:0], bg_wb[ci][103:96], 8);
            `REG_RST_WE(u_b13, clk, rst, f3_we, data_bus[15:8], bg_wb[ci][111:104], 8);
            `REG_RST_WE(u_b14, clk, rst, f3_we, data_bus[23:16], bg_wb[ci][119:112], 8);
            `REG_RST_WE(u_b15, clk, rst, f3_we, data_bus[31:24], bg_wb[ci][127:120], 8);
        end
    endgenerate

    // ================================================================
    // OUTPUT: bank_cmd_ld_address  (64 banks x 5 bits)
    // ================================================================
    // Bank b is in chip b/4. Its ld_address = chip_row[b/4].
    genvar bi;
    generate
        for (bi = 0; bi < 64; bi = bi + 1) begin : g_ld_addr
            assign bank_cmd_ld_address[bi*5+:5] = chip_row[bi/4];
        end
    endgenerate

    // ================================================================
    // OUTPUT: bank_cmd_ld_address_change  (64 banks)
    // ================================================================
    // Default 0. When fsm_ld_address_changed, set for all banks in selected chip.
    // bank b: ld_addr_change = chip_sel_oh[b/4] & fsm_ld_address_changed
    generate
        for (bi = 0; bi < 64; bi = bi + 1) begin : g_ld_chg
            and2$ u_lc (
                .out(bank_cmd_ld_address_change[bi]),
                .in0(chip_sel_oh[bi/4]),
                .in1(fsm_ld_address_changed)
            );
        end
    endgenerate

    // ================================================================
    // OUTPUT: bank_cmd_driveMemBus  (64 banks)
    // ================================================================
    // Default 0. When fsm_set_ld_tristate, set for bank_num_for_chip.
    wire [63:0] bank_oh;
    decoder_onehot #(
        .WIDTH(64)
    ) u_bank_dec (
        .sel(bank_num_for_chip),
        .out(bank_oh)
    );
    generate
        for (bi = 0; bi < 64; bi = bi + 1) begin : g_drive
            and2$ u_dm (
                .out(bank_cmd_driveMemBus[bi]),
                .in0(bank_oh[bi]),
                .in1(fsm_set_ld_tristate)
            );
        end
    endgenerate

    // ================================================================
    // OUTPUT: bank_cmd_st_address  (64 banks x 5 bits)
    // ================================================================
    // Bank b is in bank-group b/8.  st_address = bg_row[b/8].
    generate
        for (bi = 0; bi < 64; bi = bi + 1) begin : g_st_addr
            assign bank_cmd_st_address[bi*5+:5] = bg_row[bi/8];
        end
    endgenerate

    // ================================================================
    // OUTPUT: bank_cmd_start_store  (64 banks)
    // ================================================================
    // Default 0. When fsm_start_store, set for bank {addr[9:7], bankGroup}.
    // store_bank_idx = {address_bus[9:7], address_bus[6:4]} = address_bus[9:4]
    wire [5:0] store_bank_idx;
    assign store_bank_idx = address_bus[9:4];

    wire [63:0] store_oh;
    decoder_onehot #(
        .WIDTH(64)
    ) u_store_dec (
        .sel(store_bank_idx),
        .out(store_oh)
    );
    generate
        for (bi = 0; bi < 64; bi = bi + 1) begin : g_ss
            and2$ u_ss (
                .out(bank_cmd_start_store[bi]),
                .in0(store_oh[bi]),
                .in1(fsm_start_store)
            );
        end
    endgenerate

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

    // Level 0: 8 x 5-bit 2:1 mux (select by chipNum[0])
    wire [4:0] cr_L0[0:7];
    mux_n #(
        .WIDTH(5)
    ) u_cr0 (
        .out(cr_L0[0]),
        .in0(chip_row[0]),
        .in1(chip_row[1]),
        .sel(chipNum[0])
    );
    mux_n #(
        .WIDTH(5)
    ) u_cr1 (
        .out(cr_L0[1]),
        .in0(chip_row[2]),
        .in1(chip_row[3]),
        .sel(chipNum[0])
    );
    mux_n #(
        .WIDTH(5)
    ) u_cr2 (
        .out(cr_L0[2]),
        .in0(chip_row[4]),
        .in1(chip_row[5]),
        .sel(chipNum[0])
    );
    mux_n #(
        .WIDTH(5)
    ) u_cr3 (
        .out(cr_L0[3]),
        .in0(chip_row[6]),
        .in1(chip_row[7]),
        .sel(chipNum[0])
    );
    mux_n #(
        .WIDTH(5)
    ) u_cr4 (
        .out(cr_L0[4]),
        .in0(chip_row[8]),
        .in1(chip_row[9]),
        .sel(chipNum[0])
    );
    mux_n #(
        .WIDTH(5)
    ) u_cr5 (
        .out(cr_L0[5]),
        .in0(chip_row[10]),
        .in1(chip_row[11]),
        .sel(chipNum[0])
    );
    mux_n #(
        .WIDTH(5)
    ) u_cr6 (
        .out(cr_L0[6]),
        .in0(chip_row[12]),
        .in1(chip_row[13]),
        .sel(chipNum[0])
    );
    mux_n #(
        .WIDTH(5)
    ) u_cr7 (
        .out(cr_L0[7]),
        .in0(chip_row[14]),
        .in1(chip_row[15]),
        .sel(chipNum[0])
    );

    // Level 1 (select by chipNum[1])
    wire [4:0] cr_L1[0:3];
    mux_n #(
        .WIDTH(5)
    ) u_cr10 (
        .out(cr_L1[0]),
        .in0(cr_L0[0]),
        .in1(cr_L0[1]),
        .sel(chipNum[1])
    );
    mux_n #(
        .WIDTH(5)
    ) u_cr11 (
        .out(cr_L1[1]),
        .in0(cr_L0[2]),
        .in1(cr_L0[3]),
        .sel(chipNum[1])
    );
    mux_n #(
        .WIDTH(5)
    ) u_cr12 (
        .out(cr_L1[2]),
        .in0(cr_L0[4]),
        .in1(cr_L0[5]),
        .sel(chipNum[1])
    );
    mux_n #(
        .WIDTH(5)
    ) u_cr13 (
        .out(cr_L1[3]),
        .in0(cr_L0[6]),
        .in1(cr_L0[7]),
        .sel(chipNum[1])
    );

    // Level 2 (select by chipNum[2])
    wire [4:0] cr_L2[0:1];
    mux_n #(
        .WIDTH(5)
    ) u_cr20 (
        .out(cr_L2[0]),
        .in0(cr_L1[0]),
        .in1(cr_L1[1]),
        .sel(chipNum[2])
    );
    mux_n #(
        .WIDTH(5)
    ) u_cr21 (
        .out(cr_L2[1]),
        .in0(cr_L1[2]),
        .in1(cr_L1[3]),
        .sel(chipNum[2])
    );

    // Level 3 (select by chipNum[3])
    mux_n #(
        .WIDTH(5)
    ) u_cr30 (
        .out(sel_chip_row),
        .in0(cr_L2[0]),
        .in1(cr_L2[1]),
        .sel(chipNum[3])
    );

    // ---- 5-bit comparator ----
    wire addr_match;
    bit_compare_n #(
        .WIDTH(5)
    ) u_cmp (
        .eq(addr_match),
        .a (sel_chip_row),
        .b (rowBit)
    );

    // ---- 64:1 mux of banks_precharged, selected by bank_num_for_chip ----
    wire sel_precharge;

    // Level 0: 32 x 1-bit 2:1 mux (select by bank_num_for_chip[0])
    wire [31:0] pr_L0;
    genvar pi;
    generate
        for (pi = 0; pi < 32; pi = pi + 1) begin : g_pr0
            mux2_1b u_m (
                .out(pr_L0[pi]),
                .in0(banks_precharged[pi*2]),
                .in1(banks_precharged[pi*2+1]),
                .sel(bank_num_for_chip[0])
            );
        end
    endgenerate

    // Level 1: 16 (select by [1])
    wire [15:0] pr_L1;
    generate
        for (pi = 0; pi < 16; pi = pi + 1) begin : g_pr1
            mux2_1b u_m (
                .out(pr_L1[pi]),
                .in0(pr_L0[pi*2]),
                .in1(pr_L0[pi*2+1]),
                .sel(bank_num_for_chip[1])
            );
        end
    endgenerate

    // Level 2: 8 (select by [2])
    wire [7:0] pr_L2;
    generate
        for (pi = 0; pi < 8; pi = pi + 1) begin : g_pr2
            mux2_1b u_m (
                .out(pr_L2[pi]),
                .in0(pr_L1[pi*2]),
                .in1(pr_L1[pi*2+1]),
                .sel(bank_num_for_chip[2])
            );
        end
    endgenerate

    // Level 3: 4 (select by [3])
    wire [3:0] pr_L3;
    generate
        for (pi = 0; pi < 4; pi = pi + 1) begin : g_pr3
            mux2_1b u_m (
                .out(pr_L3[pi]),
                .in0(pr_L2[pi*2]),
                .in1(pr_L2[pi*2+1]),
                .sel(bank_num_for_chip[3])
            );
        end
    endgenerate

    // Level 4: 2 (select by [4])
    wire [1:0] pr_L4;
    generate
        for (pi = 0; pi < 2; pi = pi + 1) begin : g_pr4
            mux2_1b u_m (
                .out(pr_L4[pi]),
                .in0(pr_L3[pi*2]),
                .in1(pr_L3[pi*2+1]),
                .sel(bank_num_for_chip[4])
            );
        end
    endgenerate

    // Level 5: final (select by [5])
    mux2_1b u_pr5 (
        .out(sel_precharge),
        .in0(pr_L4[0]),
        .in1(pr_L4[1]),
        .sel(bank_num_for_chip[5])
    );

    // ---- Final hit AND ----
    and3$ u_hit (
        .out(hit_into_fsm),
        .in0(dte_ld_req),
        .in1(addr_match),
        .in2(sel_precharge)
    );

endmodule
