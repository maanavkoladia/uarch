`default_nettype none

module mem_bank (
    input wire clk,
    input wire rst,
    input wire [`NUM_SRAM_ADDRESS_BITS - 1 : 0] ld_address_i,

    //mem_controller_2_mem_bank_t
    input wire [`NUM_SRAM_ADDRESS_BITS - 1 : 0] st_address_i,
    input wire start_store_i,
    input wire ld_address_change_i,
    input wire driveMemBus_i,
    input [`CACHE_LINES_SIZE_BITS - 1 : 0] writeBuf_i,

    inout [`MEM_BUS_SIZE - 1 : 0] mem_bus,

    //mem_bank_out_t
    output wire precharged_o,
    output wire clear_writebufV_o

);
    localparam NUM_SRAM_CELLS = 4;

    wire mem_bank_controller_oe;
    wire mem_bank_controller_we;
    wire mem_bank_controller_send_store_address;
    wire mem_bank_controller_send_store_address_delayed;
    wire [$clog2(`BANK_CONTROLLER_FSM_LOGIC_STATES) - 1 : 0] mem_bank_controller_states_bits;
    //delay of .24, need four lined up
    //mps_buffer_delay_stages #(
    //    .STAGES(4)
    //) u0 (
    //    .out(mem_bank_controller_send_store_address_delayed),
    //    .in (mem_bank_controller_send_store_address)
    //);

    `BUFFER_DELAY(u0, 4, 1, mem_bank_controller_send_store_address, mem_bank_controller_send_store_address_delayed);
    wire [`NUM_SRAM_ADDRESS_BITS-1:0] bank_address_i;
    wire [`MEM_BUS_SIZE-1:0] bank_bus;
    wire [`MEM_BUS_SIZE-1:0] bank_write_data;

    assign bank_write_data = writeBuf_i;

    //mux2_8$ u1 (
    //    .Y  (bank_address_i),
    //    .IN0(ld_address_i),
    //    .IN1(st_address_i),
    //    .S0 (mem_bank_controller_send_store_address_delayed)
    //);

    `MUX_2(u1, `NUM_SRAM_ADDRESS_BITS, bank_address_i, ld_address_i, st_address_i, mem_bank_controller_send_store_address_delayed);
    // bank internal bus
    //assign bank_bus = !mem_bank_controller_we ? bank_write_data : 'z;
    //mps_tristateL_width#(
    //    .WIDTH(`MEM_BUS_SIZE)
    //) (
    //    .enbar(mem_bank_controller_we), .in(bank_write_data), .out(bank_bus)
    //);
    `TRISTATE_L(u2, `MEM_BUS_SIZE, mem_bank_controller_we, bank_write_data, bank_bus)
    //assign mem_bus = controller2bank_i.driveMemBus ? bank_bus : 'z;
    wire driveMemBus_bar;
    //inv1$ u2 (
    //    .out(driveMemBus_bar),
    //    .in (driveMemBus_i)
    //);
    `INV_N(u3, 1, driveMemBus_i, driveMemBus_bar);

    //mps_tristateL_width#(
    //    .WIDTH(`MEM_BUS_SIZE)
    //) (
    //    .enbar(driveMemBus_bar), .in(bank_bus), .out(mem_bus)
    //);
    `TRISTATE_L(u4, `MEM_BUS_SIZE, driveMemBus_bar, bank_bus, mem_bus)
    genvar i_gen;
    generate
        for (i_gen = 0; i_gen < NUM_SRAM_CELLS; i_gen = i_gen + 1) begin : g_sram_cells

            sram32x32$ mem_cell (
                .A(bank_address_i),
                .DIO(bank_bus[(i_gen+1)*(`MEM_BUS_SIZE/4)-1 : i_gen*(`MEM_BUS_SIZE/4)]),
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
        .ld_address_change_i(ld_address_change_i),
        .start_store_i(start_store_i),
        .S_0(mem_bank_controller_states_bits[0]),  // current-state bit 0
        .S_1(mem_bank_controller_states_bits[1]),  // current-state bit 1
        .S_2(mem_bank_controller_states_bits[2]),  // current-state bit 2
        .S_3(mem_bank_controller_states_bits[3]),  // current-state bit 3
        .S_4(mem_bank_controller_states_bits[4]),  // current-state bit 4
        .st_addr_release_o(mem_bank_controller_send_store_address),
        .OE_o(mem_bank_controller_oe),
        .WE_o(mem_bank_controller_we),
        .clear_writebufV_o(clear_writebufV_o),
        .PreCharged_o(precharged_o)
    );


endmodule
