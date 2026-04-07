include "../../../defines/common_define.vh"
include "../../../defines/mem_common_define.vh"

module MemBank_Structural (
    input wire clk,
    input wire rst,
    input wire [`NUM_SRAM_ADDRESS_BITS - 1 : 0] ld_address,

    //mem_controller_2_mem_bank_t
    input wire [`NUM_SRAM_ADDRESS_BITS - 1 : 0] st_address,
    input wire start_store,
    input wire ld_address_change,
    input wire driveMemBus,
    input [`CACHE_LINES_SIZE_Bits : 0] writeBuf,

    inout [`MEM_BUS_SIZE - 1 : 0] mem_bus,

    //mem_bank_out_t
    input wire precharged,
    input wire clear_writebufV

);
    wire mem_bank_controller_oe;
    wire mem_bank_controller_we;
    wire mem_bank_controller_send_store_address;
    wire mem_bank_controller_send_store_address_delayed;
    wire [$clog2(`BANK_CONTROLLER_FSM_LOGIC_STATES) - 1 : 0] mem_bank_controller_states_bits;
    //delay of .24, need four lined up
    mps_buffer_delay_stages #(
        .STAGES(4)
    ) u0 (
        .out(mem_bank_controller_send_store_address_delayed),
        .in (mem_bank_controller_send_store_address)
    );

    wire [`NUM_SRAM_ADDRESS_BITS-1:0] bank_address_i;
    wire [`MEM_BUS_SIZE-1:0] bank_bus;
    wire [`MEM_BUS_SIZE-1:0] bank_write_data;

    //assign bank_write_data = {
    //    controller2bank_i.writeBuf[15],
    //    controller2bank_i.writeBuf[14],
    //    controller2bank_i.writeBuf[13],
    //    controller2bank_i.writeBuf[12],
    //    controller2bank_i.writeBuf[11],
    //    controller2bank_i.writeBuf[10],
    //    controller2bank_i.writeBuf[9],
    //    controller2bank_i.writeBuf[8],
    //    controller2bank_i.writeBuf[7],
    //    controller2bank_i.writeBuf[6],
    //    controller2bank_i.writeBuf[5],
    //    controller2bank_i.writeBuf[4],
    //    controller2bank_i.writeBuf[3],
    //    controller2bank_i.writeBuf[2],
    //    controller2bank_i.writeBuf[1],
    //    controller2bank_i.writeBuf[0]
    //};

    assign bank_write_data = writeBuf;
    mux2_8$ u1 (
        .Y  (bank_address_i),
        .IN0(ld_address),
        .IN1(st_address),
        .S0 (mem_bank_controller_send_store_address_delayed)
    );

    // bank internal bus
    //assign bank_bus = !mem_bank_controller_we ? bank_write_data : 'z;
    mps_tristateL_width #(
        .WIDTH(`MEM_BUS_SIZE)
    ) (
        .enbar(mem_bank_controller_we),
        .in (bank_write_data),
        .out(bank_bus)
    );

    //assign mem_bus = controller2bank_i.driveMemBus ? bank_bus : 'z;
    wire driveMemBus_bar;
    inv1$ u2(.out(driveMemBus_bar), .in(driveMemBus));
    mps_tristateL_width #(
        .WIDTH(`MEM_BUS_SIZE)
    ) (
        .enbar(driveMemBus_bar),
        .in (bank_bus),
        .out(mem_bus)
    );

    genvar i_gen;
    generate
        for (i_gen = 0; i_gen < `NUM_SRAM_CELLS; i_gen++) begin : g_sram_cells

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
        .ld_address_change_i(controller2bank_i.ld_address_change),
        .start_store_i(controller2bank_i.start_store),
        .S_0(mem_bank_controller_states_bits[0]),  // current-state bit 0
        .S_1(mem_bank_controller_states_bits[1]),  // current-state bit 1
        .S_2(mem_bank_controller_states_bits[2]),  // current-state bit 2
        .S_3(mem_bank_controller_states_bits[3]),  // current-state bit 3
        .S_4(mem_bank_controller_states_bits[4]),  // current-state bit 4
        .st_addr_release_o(mem_bank_controller_send_store_address),
        .OE_o(mem_bank_controller_oe),
        .WE_o(mem_bank_controller_we),
        .clear_writebufV_o(outputs.clear_writebufV),
        .PreCharged_o(outputs.precharged)
    );


endmodule
