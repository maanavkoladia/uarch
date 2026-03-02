module mem_bank (

    input logic clk,
    input logic rst,

    input mem_controller_2_mem_bank_t controller2bank_i,

    //ld should drive the whole bus, the entire $line
    //however, the write should come from the write bus
    inout [MEM_BUS_SIZE - 1 : 0] mem_bus,

    //data from the write buf
    input byte_t writeBuf[CACHE_LINES_SIZE_B],

    output mem_bank_out_t outputs

);

    import common_pkg::*;
    import mem_common_pkg::*;

    localparam int NUM_SRAM_CELLS = 4;

    // controller outputs
    logic mem_bank_controller_oe;
    logic mem_bank_controller_we;
    logic mem_bank_controller_send_store_address;

    // address mux
    logic [NUM_SRAM_ADDRESS_BITS-1:0] bank_address_i;
    assign bank_address_i = mem_bank_controller_send_store_address ?
                            controller2bank_i.st_address : controller2bank_i.ld_address;

    // bank internal bus
    logic [MEM_BUS_SIZE-1:0] bank_bus;

    // drive mem_bus tri-state
    assign mem_bus  = mem_bank_controller_oe ? bank_bus : 'z;
    assign bank_bus = mem_bank_controller_we ? writeBuf : 'z;

    // create the SRAM cells
    genvar i_gen;
    generate
        for (i_gen = 0; i_gen < NUM_SRAM_CELLS; i_gen++) begin : g_sram_cells
            localparam int UPPER_BOUND = (i_gen + 1) * data_bus_width_bits - 1;
            localparam int LOWER_BOUND = i_gen * data_bus_width_bits;

            sram32x32$ mem_cell_u_X (
                .A(bank_address_i),
                .DIO(bank_bus[UPPER_BOUND : LOWER_BOUND]),
                .OE(mem_bank_controller_oe),
                .WR(mem_bank_controller_we),
                .CE(1'b0)  // always enabled
            );
        end
    endgenerate

    // instantiate the controller FSM
    bank_controller_fsm_logic u0_Controller (
        .clk(clk),
        .rst(rst),
        .ld_address_change_i(controller2bank_i.ld_address_change),
        .start_store_i(controller2bank_i.start_store),
        .st_addr_release_o(mem_bank_controller_send_store_address),
        .OE_o(mem_bank_controller_oe),
        .WE_o(mem_bank_controller_we),
        .clear_writebufV_o(outputs.clear_writebufV),
        .PreCharged_o(outputs.precharged)
    );

endmodule
