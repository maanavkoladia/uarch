import common_pkg::*;
import mem_common_pkg::*;
import interconnect_pkg::*;

module mem_TOP (
    input wire clk,
    input wire rst,

    //adress and data bus
    inout [ADDRESS_BUS_WIDTH_BITS -1 : 0] address_bus,
    inout [  DATA_BUS_WIDTH_BITS - 1 : 0] data_bus,

    //arb stuff
    input dte_2_mem_t inFromDte,

    output mem_2_dte_t out2Dte,
    output mem_2_scheduler_t out2Sch
);

    mem_controller_2_mem_bank_t controller_2_bank_Cmds[NUM_BANKS];
    mem_bank_out_t bank_out_2_controller[NUM_BANKS];

    wire [MEM_BUS_SIZE - 1 : 0] mem_bus;

    //mem never needs to drive address bus
    assign address_bus = 'z;

    //wire [ADDRESS_BUS_WIDTH_BITS -1 : 0] add
    //create the banks
    genvar i_gen, gi, gj;
    generate
        for (i_gen = 0; i_gen < NUM_BANKS; i_gen++) begin : g_mem_banks
            mem_bank mem_bank(
                .clk(clk),
                .rst(rst),
                .controller2bank_i(controller_2_bank_Cmds[i_gen]),
                .mem_bus(mem_bus),
                .outputs(bank_out_2_controller[i_gen])
            );
        end
    endgenerate

    //create the controller,
    // mem_controller controller (
    //     .clk(clk),
    //     .rst(rst),
    //     .address_bus(address_bus[PHY_MEM_ADDRESS_SIZE - 1 : 0]),
    //     .data_bus(data_bus),
    //     .DTE_i(inFromDte),
    //     .ToDTE_o(out2Dte),
    //     .ToScheduler_o(out2Sch),
    //     .bank_cmds_o(controller_2_bank_Cmds),
    //     .banks_i(bank_out_2_controller)
    // );
    // wire [ADDRESS_BUS_WIDTH_BITS -1 : 0] add
    // create the banks

    // create the controller,
    // --- flat wires for mem_controller_structural interface ---

    // DTE/Scheduler outputs from controller (flattened)
    wire        ctrl_ToDTE_mem_Ready;
    wire [ 7:0] ctrl_ToScheduler_writeBuf_V;

    // Bank command outputs from controller (flat packed buses)
    wire [64*5-1:0]  ctrl_bank_ld_address;
    wire [64*5-1:0]  ctrl_bank_st_address;
    wire [63:0]      ctrl_bank_start_store;
    wire [63:0]      ctrl_bank_ld_address_change;
    wire [63:0]      ctrl_bank_driveMemBus;
    wire [8*128-1:0] ctrl_bank_writeBuf;

    // Bank inputs to controller (flat)
    wire [63:0] ctrl_banks_precharged;
    wire [63:0] ctrl_banks_clear_writebufV;

    // Connect flat controller bank outputs -> controller_2_bank_Cmds structs
    generate
        for (gi = 0; gi < NUM_BANKS; gi = gi + 1) begin : g_ctrl2bank
            assign controller_2_bank_Cmds[gi].ld_address        = ctrl_bank_ld_address[gi*5+:5];
            assign controller_2_bank_Cmds[gi].st_address        = ctrl_bank_st_address[gi*5+:5];
            assign controller_2_bank_Cmds[gi].start_store       = ctrl_bank_start_store[gi];
            assign controller_2_bank_Cmds[gi].ld_address_change = ctrl_bank_ld_address_change[gi];
            assign controller_2_bank_Cmds[gi].driveMemBus       = ctrl_bank_driveMemBus[gi];
            for (gj = 0; gj < CACHE_LINES_SIZE_B; gj = gj + 1) begin : g_wb_byte
                assign controller_2_bank_Cmds[gi].writeBuf[gj] =
                    ctrl_bank_writeBuf[(gi%8)*128 + gj*8+:8];
            end
        end
    endgenerate

    // Connect bank_out_2_controller structs -> flat controller bank inputs
    generate
        for (gi = 0; gi < NUM_BANKS; gi = gi + 1) begin : g_bank2ctrl
            assign ctrl_banks_precharged[gi]      = bank_out_2_controller[gi].precharged;
            assign ctrl_banks_clear_writebufV[gi] = bank_out_2_controller[gi].clear_writebufV;
        end
    endgenerate

    // Connect DTE/Scheduler flat outputs to top-level struct ports
    assign out2Dte.mem_Ready  = ctrl_ToDTE_mem_Ready;
    assign out2Sch.writeBuf_V = ctrl_ToScheduler_writeBuf_V;

    mem_controller_structural controller (
        .clk                        (clk),
        .rst                        (rst),
        .address_bus                (address_bus[PHY_MEM_ADDRESS_SIZE - 1 : 0]),
        .data_bus                   (data_bus),
        .dte_ld_req                 (inFromDte.ld_req),
        .dte_st_req                 (inFromDte.st_req),
        .dte_permission2DriveBus    (inFromDte.permission2DriveBus),
        .ToDTE_mem_Ready            (ctrl_ToDTE_mem_Ready),
        .ToScheduler_writeBuf_V     (ctrl_ToScheduler_writeBuf_V),
        .bank_cmd_ld_address        (ctrl_bank_ld_address),
        .bank_cmd_st_address        (ctrl_bank_st_address),
        .bank_cmd_start_store       (ctrl_bank_start_store),
        .bank_cmd_ld_address_change (ctrl_bank_ld_address_change),
        .bank_cmd_driveMemBus       (ctrl_bank_driveMemBus),
        .bank_cmd_writeBuf          (ctrl_bank_writeBuf),
        .banks_precharged           (ctrl_banks_precharged),
        .banks_clear_writebufV      (ctrl_banks_clear_writebufV)
    );

    bool drive_Data_Bus;
    logic [DATA_BUS_WIDTH_BITS-1:0] dataToDrive;
    assign #5 data_bus = drive_Data_Bus ? dataToDrive : 'z;

    //actually drive the bus, data should inyl reach this point if
    //DTE want to do a trnafser and the controller has given permission
    //to a bank to drive the mem_bus, idk about the write logic
    always_comb begin
        drive_Data_Bus = 0;
        dataToDrive = 'z;
        for (int i = 0; i < MEM_BUS_SIZE / DATA_BUS_WIDTH_BITS; i++) begin
            if (inFromDte.permission2DriveBus[i]) begin
                dataToDrive = mem_bus[i*DATA_BUS_WIDTH_BITS+:DATA_BUS_WIDTH_BITS];
                drive_Data_Bus = 1;
            end
        end
    end

endmodule
