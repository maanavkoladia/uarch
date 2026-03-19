//this file needs to ouput the isntruncitons needed for
//taken an isntrunciton

import common_pkg::*;

module EXP_Ctrl_ROMS (
    //fully comb no clk

    //exp mux sels
    input logic RR_pf,
    input logic RR_exp,
    input logic Fetch_pf,

    //probably from the dma jk 
    input logic DMA_int,

    //from the expmode bit in fetch
    input logic exp_mode,

    output byte_t rom_data_out[CACHE_LINES_SIZE_B]
);

    // IDT (Interrupt Descriptor Table) entry indices
    localparam logic [2:0] GP_IDT = 3'b000;  // General Protection Fault
    localparam logic [2:0] PF_IDT = 3'b001;  // Page Fault
    localparam logic [2:0] DMA_IDT = 3'b010; // DMA Interrupt
    localparam logic [2:0] DDR_IDT = 3'b011; // DDR (placeholder)

    // Exception/interrupt selection logic
    wire [2:0] fetch_exp_out;
    mux2_3 fetchP_pf_mux(.in0(GP_IDT), .in1(PF_IDT), .sel(Fetch_pf), .out(fetch_exp_out));

    wire [2:0] rr_exp_out;
    mux2_3 rr_pf_mux(.in0(GP_IDT), .in1(PF_IDT), .sel(RR_pf), .out(rr_exp_out));

    wire [2:0] exp_idx;
    mux2_3 exp_sel_mux(.in0(fetch_exp_out), .in1(rr_exp_out), .sel(RR_exp), .out(exp_idx));

    wire [2:0] int_idx;
    mux2_3 dma_int_mux(.in0(DDR_IDT), .in1(DMA_IDT), .sel(DMA_int), .out(int_idx));

    wire [2:0] rom_idx;
    mux2_3 exp_mode_mux(.in0(int_idx), .in1(exp_idx), .sel(exp_mode), .out(rom_idx));


    // BELOW ALL DONE BY CLAUDE COULD BE TOTALLY WRONG
    // ROM outputs (need 128 bits = 16 bytes for cache line)
    wire [63:0] rom_low_data;   // Lower 8 bytes (bits 63:0)
    wire [63:0] rom_high_data;  // Upper 8 bytes (bits 127:64)
    wire [4:0] rom_addr;
    
    // Extend 3-bit index to 5-bit ROM address (only use first 8 entries of 32-entry ROM)
    assign rom_addr = {2'b00, rom_idx};

    // Instantiate two 64-bit ROMs to get 128 bits total
    rom64b32w$ rom_low (
        .A(rom_addr),
        .OE(1'b1),           // Always enabled (active high)
        .DOUT(rom_low_data)
    );

    rom64b32w$ rom_high (
        .A(rom_addr),
        .OE(1'b1),           // Always enabled (active high)
        .DOUT(rom_high_data)
    );
    
    // Initialize ROM contents with test patterns
    initial begin
        // Lower ROM (bytes 0-7): Each row filled with its row number
        // Row 0 = 0x0000000000000000, Row 1 = 0x0101010101010101, etc.
        for (int i = 0; i < 8; i++) begin
            rom_low.mem[i] = {8{i[7:0]}};  // Replicate byte i across all 8 bytes
        end
        
        // Upper ROM (bytes 8-15): Same pattern
        for (int i = 0; i < 8; i++) begin
            rom_high.mem[i] = {8{i[7:0]}};  // Replicate byte i across all 8 bytes
        end
        
        // Result: Full cache line for each entry is filled with entry number
        // Entry 0: 0x00000000000000000000000000000000 (16 bytes of 0x00)
        // Entry 1: 0x01010101010101010101010101010101 (16 bytes of 0x01)
        // Entry 2: 0x02020202020202020202020202020202 (16 bytes of 0x02)
        // ... etc
        
        // OR populate specific exception handlers:
        // rom_low.mem[GP_IDT]  = 64'h1122334455667788;  // GP fault handler bytes 0-7
        // rom_high.mem[GP_IDT] = 64'h99AABBCCDDEEFF00;  // GP fault handler bytes 8-15
        // rom_low.mem[PF_IDT]  = 64'hAABBCCDDEEFF0011;  // Page fault bytes 0-7
        // rom_high.mem[PF_IDT] = 64'h2233445566778899;  // Page fault bytes 8-15
    end

    // Pack ROM outputs into byte array
    // rom_data_out[0:7] = rom_low_data[63:0]
    // rom_data_out[8:15] = rom_high_data[63:0]
    always_comb begin
        for (int i = 0; i < 8; i++) begin
            rom_data_out[i] = rom_low_data[i*8 +: 8];      // Bytes 0-7
            rom_data_out[i+8] = rom_high_data[i*8 +: 8];   // Bytes 8-15
        end
    end

endmodule
