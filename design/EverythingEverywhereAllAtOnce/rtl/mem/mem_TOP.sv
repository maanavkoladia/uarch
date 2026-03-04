module mem_TOP (
    input wire clk,
    input wire rst,

    //adress and data bus
    inout logic [ADDRESS_BUS_WIDTH_BITS  -1 : 0] address_bus,
    inout logic [DATA_BUS_WIDTH_BITS - 1 : 0] data_bus,

    //arb stuff
    input dte_2_mem_t inFromDte,

    output mem_2_dte_t out2Dte,
    output mem_2_scheduler_t out2Sch


);
    import common_pkg::*;
    import mem_common_pkg::*;
    import system_bus_ifs_pkg::*;

    mem_controller_2_mem_bank_t controller_2_bank_Cmds[NUM_BANKS];
    mem_bank_out_t bank_out_2_controller[NUM_BANKS];

    logic [MEM_BUS_SIZE - 1 : 0] mem_bus;

    //create the banks
    genvar i_gen;
    generate
        for (i_gen = 0; i_gen < NUM_BANKS; i_gen++) begin : g_mem_banks
            mem_bank mem_bank_unit_uX (
                .clk(clk),
                .rst(rst),
                .controller2bank_i(controller_2_bank_Cmds[i]),
                .mem_bus(mem_bus),
                .outputs(bank_out_2_controller[i])
            );
        end
    endgenerate
    //create the controller,
    //

    mem_controller controller (
        .clk(clk),
        .rst(rst),
        .address_bus(address_bus),
        .DTE_i(inFromDte),
        .ToDTE_o(out2Dte),
        .ToScheduler_o(out2Sch),
        .bank_cmds_o(controller_2_bank_Cmds),
        .banks_i(bank_out_2_controller)
    );

    initial begin
        //need to load in the program
    end

    //actually drive the bus, data should inyl reach this point if
    //DTE want to do a trnafser and the controller has given permission
    //to a bank to drive the mem_bus, idk about the write logic
    always_comb begin
        data_bus = 'z;
        for (int i = 0; i < MEM_BUS_SIZE / DATA_BUS_WIDTH_BITS; i++) begin
            if (inFromDte.permission2DriveBus[i]) begin
                localparam int upperBound = (i + 1) * DATA_BUS_WIDTH_BITS - 1;
                localparam int lowerBound = i * DATA_BUS_WIDTH_BITS;
                data_bus = mem_bus[upperBound : lowerBound];
            end
        end
    end




endmodule
