import common_pkg::*;
import interconnect_pkg::MEM_BUS_SIZE;
import mem_common_pkg::*;

module mem_bank (

    input logic clk,
    input logic rst,

    input mem_controller_2_mem_bank_t controller2bank_i,
    /*
        logic [NUM_SRAM_ADDRESS_BITS -1 : 0] ld_address;

        //address from the bank group table
        logic [NUM_SRAM_ADDRESS_BITS -1 : 0] st_address;

        //thse two signals are for the bank_fsm_controller
        bool start_store;
        bool ld_address_change;

        //this comes from the mem Controller, this gives
        //permission to this bank to write to the memBus
        bool driveMemBus;

        //buf where write are stored fora bankgrup
        byte_t writeBuf[CACHE_LINES_SIZE_B];
    */

    //ld should drive the whole bus, the entire $line
    //however, the write should come from the write bus
    inout [MEM_BUS_SIZE - 1 : 0] mem_bus,

    output mem_bank_out_t outputs

);

    localparam int NUM_SRAM_CELLS = 4;

    // controller outputs
    logic mem_bank_controller_oe;
    logic mem_bank_controller_we;
    logic mem_bank_controller_send_store_address;


    logic [$clog2(
BANK_CONTROLLER_FSM_LOGIC_STATES
) - 1 : 0] mem_bank_controller_states_bits;  // packed 5-bit vector

    //writing the structurcal state bits to the sv enum
    bank_fsm_controller_state_t fsm_state;
    assign fsm_state = bank_fsm_controller_state_t'(mem_bank_controller_states_bits);

    // address mux
    logic [NUM_SRAM_ADDRESS_BITS-1:0] bank_address_i;
    assign bank_address_i = mem_bank_controller_send_store_address?
                            controller2bank_i.st_address : controller2bank_i.ld_address;

    // bank internal bus
    wire [MEM_BUS_SIZE-1:0] bank_bus;

    //buffer to take 16 bytes array into a 128 bit bank bus out
    wire [MEM_BUS_SIZE-1:0] bank_write_data;

    // drive mem_bus tri-state
    assign mem_bus = controller2bank_i.driveMemBus ? bank_bus : 'z;
    assign bank_bus = mem_bank_controller_we ? bank_write_data : 'z;


    assign bank_write_data = {
        controller2bank_i.writeBuf[15],
        controller2bank_i.writeBuf[14],
        controller2bank_i.writeBuf[13],
        controller2bank_i.writeBuf[12],
        controller2bank_i.writeBuf[11],
        controller2bank_i.writeBuf[10],
        controller2bank_i.writeBuf[9],
        controller2bank_i.writeBuf[8],
        controller2bank_i.writeBuf[7],
        controller2bank_i.writeBuf[6],
        controller2bank_i.writeBuf[5],
        controller2bank_i.writeBuf[4],
        controller2bank_i.writeBuf[3],
        controller2bank_i.writeBuf[2],
        controller2bank_i.writeBuf[1],
        controller2bank_i.writeBuf[0]
    };

    // create the SRAM cells needs to be split 4 ways
    genvar i_gen;
    generate
        for (i_gen = 0; i_gen < NUM_SRAM_CELLS; i_gen++) begin : g_sram_cells

            sram32x32$ mem_cell(
                .A(bank_address_i),
                .DIO(bank_bus[(i_gen+1)*(MEM_BUS_SIZE/4)-1 : i_gen*(MEM_BUS_SIZE/4)]),
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

    //initial begin
    //    $readmemh("fakeData/mem0.hex", mem_bank.g_sram_cells[0].mem_cell.mem);
    //    $readmemh("fakeData/mem1.hex", mem_bank.g_sram_cells[1].mem_cell.mem);
    //    $readmemh("fakeData/mem2.hex", mem_bank.g_sram_cells[2].mem_cell.mem);
    //    $readmemh("fakeData/mem3.hex", mem_bank.g_sram_cells[3].mem_cell.mem);
    //    `LOG("read in mem");
    //end

endmodule
