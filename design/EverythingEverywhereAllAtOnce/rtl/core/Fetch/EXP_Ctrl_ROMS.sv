//this file needs to ouput the isntruncitons needed for
//taken an isntrunciton

import common_pkg::*;

module EXP_Ctrl_ROMS (
    //fully comb no clk

    //exp mux sels
    input clk,
    input bool exp_pipe_clear,
    input bool int_pipe_clear,
    input logic DC_pf,
    input logic DC_exp,
    input logic Fetch_pf,

    //probably from the dma jk 
    input logic DMA_int,

    //from the expmode bit in fetch
    input logic exp_mode,

    output byte_t rom_data_out[CACHE_LINES_SIZE_B]
);

    logic [4:0] rom_sel;

    // IDT (Interrupt Descriptor Table) entry indices
    localparam logic [2:0] GP_IDT = 3'b001;  // General Protection Fault
    localparam logic [2:0] PF_IDT = 3'b010;  // Page Fault
    localparam logic [2:0] DMA_IDT = 3'b011; // DMA Interrupt
    localparam logic [2:0] DDR_IDT = 3'b100; // DDR (placeholder)

    // Exception/interrupt selection logic
    wire [2:0] fetch_exp_out;
    mux2_3 fetchP_pf_mux(.in0(GP_IDT), .in1(PF_IDT), .sel(Fetch_pf), .out(fetch_exp_out));

    wire [2:0] DC_exp_out;
    mux2_3 DC_pf_mux(.in0(GP_IDT), .in1(PF_IDT), .sel(DC_pf), .out(DC_exp_out));

    wire [2:0] exp_idx;
    mux2_3 exp_sel_mux(.in0(fetch_exp_out), .in1(DC_exp_out), .sel(DC_exp), .out(exp_idx));

    wire [2:0] int_idx;
    mux2_3 dma_int_mux(.in0(DDR_IDT), .in1(DMA_IDT), .sel(DMA_int), .out(int_idx));

    wire [2:0] rom_idx;
    mux2_3 exp_mode_mux(.in0(int_idx), .in1(exp_idx), .sel(exp_pipe_clear), .out(rom_idx));

  


    // Simple ROM: 32 entries, each 16 bytes
    logic [7:0] rom_mem [0:31][0:15];
    
    wire [4:0] rom_addr;
    
    // Extend 3-bit index to 5-bit ROM address (only use first 8 entries of 32-entry ROM)
    assign rom_addr = {2'b00, rom_idx};
    
    //this is by me. On pipeclear we need to clear all the stages. RR exceptions would disapear so we need some way to latch the ROM address we want to use
    always_ff@(posedge clk)begin
            if(exp_pipe_clear | int_pipe_clear)begin
                rom_sel <= rom_addr;
            end
    end

    // Initialize ROM contents with test patterns
    // Each entry filled with its entry number repeated 16 times
    initial begin
        for (int i = 0; i < 32; i++) begin
            for (int j = 0; j < 16; j++) begin
                rom_mem[i][j] = i[7:0];  // Entry 0=0x00, Entry 1=0x01, etc.
            end
        end
        
        // Result: Full cache line for each entry is filled with entry number
        // Entry 0x00: 0x00000000000000000000000000000000 (16 bytes of 0x00)
        // Entry 0x01: 0x01010101010101010101010101010101 (16 bytes of 0x01)
        // Entry 0x02: 0x02020202020202020202020202020202 (16 bytes of 0x02)
        // ...
        // Entry 0x0F: 0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F (16 bytes of 0x0F)
        // Entry 0x10: 0x10101010101010101010101010101010 (16 bytes of 0x10)
        // Entry 0x11: 0x11111111111111111111111111111111 (16 bytes of 0x11)
        // Entry 0x12: 0x12121212121212121212121212121212 (16 bytes of 0x12)
        // Entry 0x13: 0x13131313131313131313131313131313 (16 bytes of 0x13)
        // ... etc up to 0x1F
    end

    // Output the selected ROM entry
    always_comb begin
        for (int i = 0; i < CACHE_LINES_SIZE_B; i++) begin
            rom_data_out[i] = rom_mem[rom_sel][i];
        end
    end

endmodule
