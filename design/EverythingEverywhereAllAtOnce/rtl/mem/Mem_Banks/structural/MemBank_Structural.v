
`define CACHE_LINES_SIZE_B 16
`define CACHE_LINES_SIZE_Bits (`CACHE_LINES_SIZE_B * 8)

`define ADDRESS_BITS 32
`define PAGE_SIZE 4096
`define PHY_MEM_SIZE (1 << 15)

// buses
`define DATA_BUS_WIDTH_BITS 32
`define ADDRESS_BUS_WIDTH_BITS 32

// derived (manual clog2 replacement)
`define PHY_MEM_ADDR_BITS 15   // log2(1<<15)

// queue / structure sizes
`define NUM_WB_ST_QS 4
`define ST_Q_DEPTH 4
`define NUM_IDM_SLOTS 4

`define MEM_BUS_SIZE `CACHE_LINES_SIZE_Bits

`define NUM_SBS 22
`define NUM_BANKS (64)
`define NUM_BANK_GROUPS (8)
`define NUM_BANKS_PER_BANK_GROUP (`NUM_BANKS / `NUM_BANK_GROUPS)


`define NUM_OF_BANK_CHIPS (16)
`define NUM_BANKS_PER_CHIP (`NUM_BANKS / `NUM_OF_BANK_CHIPS)

`define NUM_SRAM_ADDRESS_WORD (32)

// Replace $clog2 manually (since not available in Verilog-2005)
`define NUM_SRAM_ADDRESS_BITS (5)   // log2(32) = 5

`define MEM_SIZE (1 << 15)
`define PHY_MEM_ADDRESS_SIZE (15)   // log2(2^15) = 15

// Bit ranges
`define MEM_BANKGROUP_BITS_UB (6)
`define MEM_BANKGROUP_BITS_LD (4)

`define MEM_CHIP_BITS_UB (9)
`define MEM_CHIP_BITS_LD (6)


module MemBank_Structural (
    input wire clk,
    input wire rst,
    input wire [`NUM_SRAM_ADDRESS_BITS - 1 : 0] ld_address,

    //mem_controller_2_mem_bank_t
    input wire [`NUM_SRAM_ADDRESS_BITS - 1 : 0] st_address,
    input wire start_store,
    input wire ld_address_change,
    input wire driveMemBus,
    input [7 : 0] writeBuf[`CACHE_LINES_SIZE_B],


    inout [`MEM_BUS_SIZE - 1 : 0] mem_bus,

    //mem_bank_out_t 
    input wire precharged,
    input wire clear_writebufV

);
    wire mem_bank_controller_oe;
    wire mem_bank_controller_we;
    wire mem_bank_controller_send_store_address;
    wire mem_bank_controller_send_store_address_delayed;

    //delay of .24, need four lined up
    buffer_delay_stages$ U_mem_bank_controller_send_store_address_delay (
        .out(mem_bank_controller_send_store_address_delayed),
        .in (mem_bank_controller_send_store_address)
    );

    wire bank_address_i;
    mux2_8$ u_bank_address_sel (
        .Y  (),
        .IN0(),
        .IN1(),
        .S0 ()
    );

endmodule
