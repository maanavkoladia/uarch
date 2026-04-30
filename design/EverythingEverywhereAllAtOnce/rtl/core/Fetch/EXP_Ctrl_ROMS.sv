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
    uint32_t IDTR;

    // IDT (Interrupt Descriptor Table) entry indices
    localparam logic [4:0] GP_IDT = 5'd13;  // General Protection Fault
    localparam logic [4:0] PF_IDT = 5'd14;  // Page Fault
    localparam logic [4:0] DMA_IDT = 5'd7;  // DMA Interrupt
    localparam logic [4:0] DDR_IDT = 5'b100;  // DDR (placeholder)

    // Exception/interrupt selection logic
    // =====================
    // Fetch exception mux
    // =====================
    logic [4:0] fetch_exp_out;
    assign fetch_exp_out = Fetch_pf ? PF_IDT : GP_IDT;

    // =====================
    // DC exception mux
    // =====================
    logic [4:0] DC_exp_out;
    assign DC_exp_out = DC_pf ? PF_IDT : GP_IDT;

    // =====================
    // Exception select mux (DC priority)
    // =====================
    logic [4:0] exp_idx;
    assign exp_idx = DC_exp ? DC_exp_out : fetch_exp_out;

    // =====================
    // Interrupt mux
    // =====================
    logic [4:0] int_idx;
    assign int_idx = DMA_int ? DMA_IDT : DDR_IDT;

    // =====================
    // Final ROM index mux
    // =====================
    logic [4:0] rom_idx;
    assign rom_idx = exp_pipe_clear ? exp_idx : int_idx;

    // Simple ROM: 32 entries, each 16 bytes
    //logic [7:0] rom_mem  [0:31][0:15];

    logic [4:0] rom_addr;

    // Extend 3-bit index to 5-bit ROM address (only use first 8 entries of 32-entry ROM)
    assign rom_addr = {2'b00, rom_idx};

    //this is by me. On pipeclear we need to clear all the stages. RR exceptions would disapear so we need some way to latch the ROM address we want to use
    always_ff @(posedge clk) begin
        if (exp_pipe_clear | int_pipe_clear) begin
            rom_sel <= rom_addr;
        end
    end

    // Initialize ROM from genned ROM
    uint32_t idtEntryAddy;
    assign idtEntryAddy = IDTR + rom_sel;//now this needs to go into bytes 5,4,3,2 of rom_data_out, eveything else should be 

    always_comb begin
        rom_data_out = '{default: '0};
        rom_data_out[0] = 8'h31;
        rom_data_out[1] = 8'h32;
        rom_data_out[2] = idtEntryAddy[7:0];
        rom_data_out[3] = idtEntryAddy[15:8];
        rom_data_out[4] = idtEntryAddy[23:16];
        rom_data_out[5] = idtEntryAddy[31:24];
        rom_data_out[6] = 8'h30;
        for(int i = 7; i < 16; i++) rom_data_out[i] = 0;
    end

endmodule
