import common_pkg::*;
import interconnect_pkg::MEM_BUS_SIZE;
import mem_common_pkg::*;

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
    genvar i_gen;
    generate
        for (i_gen = 0; i_gen < NUM_BANKS; i_gen++) begin : g_mem_banks
            mem_bank #(
                .BANK_ID(i_gen)
            ) mem_bank (
                .clk(clk),
                .rst(rst),
                .controller2bank_i(controller_2_bank_Cmds[i_gen]),
                .mem_bus(mem_bus),
                .outputs(bank_out_2_controller[i_gen])
            );
        end
    endgenerate

    //create the controller,
    mem_controller controller (
        .clk(clk),
        .rst(rst),
        .address_bus(address_bus[PHY_MEM_ADDRESS_SIZE - 1 : 0]),
        .data_bus(data_bus),
        .DTE_i(inFromDte),
        .ToDTE_o(out2Dte),
        .ToScheduler_o(out2Sch),
        .bank_cmds_o(controller_2_bank_Cmds),
        .banks_i(bank_out_2_controller)
    );

    initial begin
        //need to load in the program
    end

    bool drive_Data_Bus;
    logic [DATA_BUS_WIDTH_BITS-1:0] dataToDrive;
    assign data_bus = drive_Data_Bus ? dataToDrive : 'z;

    //actually drive the bus, data should inyl reach this point if
    //DTE want to do a trnafser and the controller has given permission
    //to a bank to drive the mem_bus, idk about the write logic
    always_comb begin
        drive_Data_Bus = 0;
        dataToDrive = '0;
        for (int i = 0; i < MEM_BUS_SIZE / DATA_BUS_WIDTH_BITS; i++) begin
            if (inFromDte.permission2DriveBus[i]) begin
                dataToDrive = mem_bus[i*DATA_BUS_WIDTH_BITS+:DATA_BUS_WIDTH_BITS];
                drive_Data_Bus = 1;
            end
        end
    end

endmodule
