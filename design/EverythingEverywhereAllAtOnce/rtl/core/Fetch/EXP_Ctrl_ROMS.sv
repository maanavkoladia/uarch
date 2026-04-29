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
    localparam logic [4:0] GP_IDT = 5'd13;  // General Protection Fault
    localparam logic [4:0] PF_IDT = 5'b010;  // Page Fault
    localparam logic [4:0] DMA_IDT = 5'b011; // DMA Interrupt
    localparam logic [4:0] DDR_IDT = 5'b100; // DDR (placeholder)

    // Exception/interrupt selection logic
    // =====================
    // Fetch exception mux
    // =====================
    logic [2:0] fetch_exp_out;
    assign fetch_exp_out = Fetch_pf ? PF_IDT : GP_IDT;

    // =====================
    // DC exception mux
    // =====================
    logic [2:0] DC_exp_out;
    assign DC_exp_out = DC_pf ? PF_IDT : GP_IDT;

    // =====================
    // Exception select mux (DC priority)
    // =====================
    logic [2:0] exp_idx;
    assign exp_idx = DC_exp ? DC_exp_out : fetch_exp_out;

    // =====================
    // Interrupt mux
    // =====================
    logic [2:0] int_idx;
    assign int_idx = DMA_int ? DMA_IDT : DDR_IDT;

    // =====================
    // Final ROM index mux
    // =====================
    logic [2:0] rom_idx;
    assign rom_idx = exp_pipe_clear ? exp_idx : int_idx;
  


    // Simple ROM: 32 entries, each 16 bytes
    logic [7:0] rom_mem [0:31][0:15];
    
    logic [4:0] rom_addr;
    
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
// Initialize ROM contents with structured test pattern
logic [31:0] imm;

initial begin
    for (int i = 0; i < 32; i++) begin
        imm = i << 3;

        rom_mem[i][0] = 8'h31;
        rom_mem[i][1] = 8'h32;

        rom_mem[i][2] = 8'h68;
        rom_mem[i][3] = 8'h00;
        rom_mem[i][4] = 8'h00;
        rom_mem[i][5] = 8'h02;

        rom_mem[i][6] = 8'h30;

        for (int j = 7; j < 16; j++) begin
            rom_mem[i][j] = 8'h90;
        end
    end
end

    // Output the selected ROM entry
    always_comb begin
        for (int i = 0; i < CACHE_LINES_SIZE_B; i++) begin
            rom_data_out[i] = rom_mem[rom_sel][i];
        end
    end

endmodule
