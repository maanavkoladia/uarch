
// ============================================================================
// mem_TOP_structural.v
// Structural Verilog-2005 conversion of mem_TOP.sv
//
// Struct ports are flattened.  All logic replaced with standard-cell macros.
// Submodules assumed:
//   mem_controller_structural  – already structural (flattened ports)
//   mem_bank                   – already structural (flattened ports, MemBank_Structural.v)
//
// Bus width constants (from common_pkg / mem_common_pkg):
//   ADDRESS_BUS_WIDTH_BITS = 32
//   DATA_BUS_WIDTH_BITS    = 32
//   MEM_BUS_SIZE           = 128   (CACHE_LINES_SIZE_BITS = 16 B * 8)
//   NUM_BANKS              = 64
//   PHY_MEM_ADDRESS_SIZE   = 15    ($clog2(1<<15))
//   numWriteBufsInMem      = 8
// ============================================================================

module mem_TOP (
    input  wire clk,
    input  wire rst,

    // address / data buses
    inout  wire [31:0] address_bus,
    inout  wire [31:0] data_bus,

    // dte_2_mem_t (flattened)
    //   bool ld_req
    //   bool st_req
    //   bool permission2DriveBus[4]   (MEM_BUS_SIZE/DATA_BUS_WIDTH_BITS = 128/32 = 4)
    input  wire        inFromDte_ld_req,
    input  wire        inFromDte_st_req,
    input  wire [3:0]  inFromDte_permission2DriveBus,

    // mem_2_dte_t (flattened)
    //   bool mem_Ready
    output wire        out2Dte_mem_Ready,

    // mem_2_scheduler_t (flattened)
    //   bool writeBuf_V[8]
    output wire [7:0]  out2Sch_writeBuf_V
);

    // -----------------------------------------------------------------------
    // Internal 128-bit mem bus shared by all banks
    // -----------------------------------------------------------------------
    wire [127:0] mem_bus;

    // -----------------------------------------------------------------------
    // Address bus: mem never drives – permanently high-Z
    // TRISTATE_L(name, width, enbar, in, out)
    // enbar=1 => always high-Z
    // -----------------------------------------------------------------------
    wire        addr_dis;
    wire [31:0] addr_zero;
    assign addr_dis  = 1'b1;
    assign addr_zero = 32'b0;
    // Use BUS_TRISTATE (tristate_bus_driver*$) so we don't mix tristate
    // classes on the addressBus (which is also driven by BusArbitration's
    // tristate_bus_driver*$ cells). Mixed-class drivers are flagged by
    // fanout.tcl as a violation; using the same family clears that.
    `BUS_TRISTATE(u_addr_z, 32, addr_dis, addr_zero, address_bus)

    // -----------------------------------------------------------------------
    // Controller -> Bank command buses
    //   bank_cmd_ld_address        [64*5-1:0]   = 320 bits  (64 x 5-bit row)
    //   bank_cmd_st_address        [64*5-1:0]   = 320 bits
    //   bank_cmd_start_store       [63:0]
    //   bank_cmd_ld_address_change [63:0]
    //   bank_cmd_driveMemBus       [63:0]
    //   bank_cmd_writeBuf          [8*128-1:0]  = 1024 bits (8 groups x 128-bit)
    // Bank -> Controller feedback buses
    //   banks_precharged           [63:0]
    //   banks_clear_writebufV      [63:0]
    // -----------------------------------------------------------------------
    wire [319:0]  bank_cmd_ld_address;
    wire [319:0]  bank_cmd_st_address;
    wire [63:0]   bank_cmd_start_store;
    wire [63:0]   bank_cmd_ld_address_change;
    wire [63:0]   bank_cmd_driveMemBus;
    wire [1023:0] bank_cmd_writeBuf;

    wire [63:0]   banks_precharged;
    wire [63:0]   banks_clear_writebufV;

    // -----------------------------------------------------------------------
    // mem_controller_structural
    // -----------------------------------------------------------------------
    mem_controller u_controller (
        .clk                        (clk),
        .rst                        (rst),
        .address_bus                (address_bus[14:0]),
        .data_bus                   (data_bus),
        .dte_ld_req                 (inFromDte_ld_req),
        .dte_st_req                 (inFromDte_st_req),
        .dte_permission2DriveBus    (inFromDte_permission2DriveBus),
        .ToDTE_mem_Ready            (out2Dte_mem_Ready),
        .ToScheduler_writeBuf_V     (out2Sch_writeBuf_V),
        .bank_cmd_ld_address        (bank_cmd_ld_address),
        .bank_cmd_st_address        (bank_cmd_st_address),
        .bank_cmd_start_store       (bank_cmd_start_store),
        .bank_cmd_ld_address_change (bank_cmd_ld_address_change),
        .bank_cmd_driveMemBus       (bank_cmd_driveMemBus),
        .bank_cmd_writeBuf          (bank_cmd_writeBuf),
        .banks_precharged           (banks_precharged),
        .banks_clear_writebufV      (banks_clear_writebufV)
    );

    // -----------------------------------------------------------------------
    // 64 mem_bank instances
    // Bank b belongs to bank-group (b % 8).
    //   Banks 0, 8, 16, ..., 56 => bank group 0 => writeBuf [127:0]
    //   Banks 1, 9, 17, ..., 57 => bank group 1 => writeBuf [255:128]
    //   ...
    //   Banks 7,15, 23, ..., 63 => bank group 7 => writeBuf [1023:896]
    // (SV: bank_cmds_o[(NUM_BANKS_PER_BANK_GROUP*j)+i].writeBuf = bankGroupTable[i].writeBuf,
    //  i=group, j=bank-in-group)
    // -----------------------------------------------------------------------
    genvar i_gen;
    generate
        for (i_gen = 0; i_gen < 64; i_gen = i_gen + 1) begin : g_mem_banks
            mem_bank mem_bank (
                .clk                 (clk),
                .rst                 (rst),
                .ld_address_i        (bank_cmd_ld_address        [i_gen*5 +: 5]),
                .st_address_i        (bank_cmd_st_address        [i_gen*5 +: 5]),
                .start_store_i       (bank_cmd_start_store       [i_gen]),
                .ld_address_change_i (bank_cmd_ld_address_change [i_gen]),
                .driveMemBus_i       (bank_cmd_driveMemBus       [i_gen]),
                .writeBuf_i          (bank_cmd_writeBuf          [(i_gen%8)*128 +: 128]),
                .mem_bus             (mem_bus),
                .precharged_o        (banks_precharged           [i_gen]),
                .clear_writebufV_o   (banks_clear_writebufV      [i_gen])
            );
        end
    endgenerate

    // -----------------------------------------------------------------------
    // Data bus driver
    //
    // Original RTL (priority-encoded loop):
    //   if (perm[i]) dataToDrive = mem_bus[i*32+:32], drive=1
    //
    // permission2DriveBus is one-hot, so structural expansion:
    //   perm[0] => mem_bus[31:0]   sel=2'b00
    //   perm[1] => mem_bus[63:32]  sel=2'b01
    //   perm[2] => mem_bus[95:64]  sel=2'b10
    //   perm[3] => mem_bus[127:96] sel=2'b11
    //
    // One-hot -> binary:
    //   sel[0] = perm[1] | perm[3]
    //   sel[1] = perm[2] | perm[3]
    //
    // drive_enable = perm[0] | perm[1] | perm[2] | perm[3]
    //
    // 5 ns delay modelled with BUFFER_DELAY: 5 ns / 0.25 ns per stage = 20 stages
    // -----------------------------------------------------------------------
    // wire        sel_bit0, sel_bit1;
    // wire [1:0]  db_sel;
    wire [3:0] perm2DriveBus_bar;
    wire [31:0] dataToDrive, dataToDrive_delayed;

    // `OR_2(u_sel_b0, 1, sel_bit0,       inFromDte_permission2DriveBus[1], inFromDte_permission2DriveBus[3])
    // `OR_2(u_sel_b1, 1, sel_bit1,       inFromDte_permission2DriveBus[2], inFromDte_permission2DriveBus[3])
    // `OR_4(u_drv_en, 1, drive_Data_Bus, inFromDte_permission2DriveBus[0], inFromDte_permission2DriveBus[1],
    //                                     inFromDte_permission2DriveBus[2], inFromDte_permission2DriveBus[3])

    // assign db_sel = {sel_bit1, sel_bit0};

    // `MUX_4(u_db_mux, 32, dataToDrive,
    //        mem_bus[31:0], mem_bus[63:32], mem_bus[95:64], mem_bus[127:96],
    //        db_sel)

    // `BUFFER_DELAY(u_db_dly, 20, 32, dataToDrive, dataToDrive_delayed)

    // u_drv_inv external fanout 32 per bit (each drives a 32-bit BUS_TRISTATE
    // enable) -> bufferH64$ per bit.
    wire [3:0] perm2DriveBus_bar_pre;
    `INV_N(u_drv_inv, 4, inFromDte_permission2DriveBus, perm2DriveBus_bar_pre);
    bufferH64$ u_drv_inv_buf_0 (.out(perm2DriveBus_bar[0]), .in(perm2DriveBus_bar_pre[0]));
    bufferH64$ u_drv_inv_buf_1 (.out(perm2DriveBus_bar[1]), .in(perm2DriveBus_bar_pre[1]));
    bufferH64$ u_drv_inv_buf_2 (.out(perm2DriveBus_bar[2]), .in(perm2DriveBus_bar_pre[2]));
    bufferH64$ u_drv_inv_buf_3 (.out(perm2DriveBus_bar[3]), .in(perm2DriveBus_bar_pre[3]));
    // `TRISTATE_L(u_db_tri, 32, drive_Data_Bus_bar, dataToDrive_delayed, data_bus)




    `BUS_TRISTATE(memBus_tri_0, 32, perm2DriveBus_bar[0], mem_bus[31:0], data_bus);
    `BUS_TRISTATE(memBus_tri_1, 32, perm2DriveBus_bar[1], mem_bus[63:32], data_bus);
    `BUS_TRISTATE(memBus_tri_2, 32, perm2DriveBus_bar[2], mem_bus[95:64], data_bus);
    `BUS_TRISTATE(memBus_tri_3, 32, perm2DriveBus_bar[3], mem_bus[127:96], data_bus);





endmodule
