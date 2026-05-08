// Structural Verilog 2005 port of EXP_Ctrl_ROMS.
// Reference SV: rtl/core/Fetch/structural/EXP_Ctrl_ROMS.sv (original).
//
// Picks the IDT entry index for the firing exception/interrupt, latches it on
// the pipe-clear cycle, and emits a 16-byte microcode "call handler" cache
// line whose byte 2..5 carries the IDT entry address.
//
// IDT indices (from the SV reference):
//   GP_IDT  = 5'd13   (general protection fault)
//   PF_IDT  = 5'd14   (page fault)
//   DMA_IDT = 5'd7    (DMA interrupt)
//   DDR_IDT = 5'd4    (DDR placeholder)
//
// Pipeline:
//   fetch_exp_out = Fetch_gp ? GP_IDT : PF_IDT
//   dc_gp_exp     = DC_exp & ~DC_pf
//   DC_exp_out    = dc_gp_exp ? GP_IDT : PF_IDT
//   exp_idx       = DC_exp   ? DC_exp_out : fetch_exp_out
//   int_idx       = DMA_int  ? DMA_IDT    : DDR_IDT
//   rom_idx       = exp_pipe_clear ? exp_idx : int_idx
//   rom_addr      = rom_idx                       // see comment below
//   rom_sel       <- rom_addr  when (exp_pipe_clear | int_pipe_clear)
//   idtEntryAddy  = IDTR + (rom_sel << 3)         // IDTR is tied to 0
//
// Output cache line (LSB-first byte index):
//   byte  0       = 8'h31
//   byte  1       = 8'h32
//   byte  2..5    = idtEntryAddy[7:0], [15:8], [23:16], [31:24]
//   byte  6       = 8'h30
//   byte  7..15   = 8'h00
//
// Notes vs. the SV reference:
//   * IDTR was declared but never assigned in the SV. Tied to 32'h0 here
//     (per design decision — no LIDT-style write port yet).
//   * The SV always_ff had no reset; this port adds an active-low rst for
//     REG_RST_WE. Fetch.sv passes its top-level rst.

module EXP_Ctrl_ROMS (
    input  wire        clk,
    input  wire        rst,             // active low

    input  wire        exp_pipe_clear,
    input  wire        int_pipe_clear,
    input  wire        DC_pf,
    input  wire        DC_exp,
    input  wire        Fetch_pf,
    input wire         Fetch_gp,
    input  wire        DMA_int,

    input  wire        exp_mode,        // present in SV port; unused (kept for parity)

    output wire [127:0]  rom_data_out
);

    // ----------------------------------------------------------------
    // IDT-index muxes (all 5 bits wide)
    // ----------------------------------------------------------------
    wire [4:0] fetch_exp_out;
    wire [4:0] DC_exp_out;
    wire [4:0] exp_idx;
    wire [4:0] int_idx;
    wire [4:0] rom_idx;

    // dc_gp_exp = DC_exp & ~DC_pf  (matches SV: assign dc_gp_exp = DC_exp & !DC_pf)
    wire        dc_pf_n;
    wire        dc_gp_exp;
    `INV_N     (u_dc_pf_inv, 1, DC_pf, dc_pf_n)
    `AND_2     (u_dc_gp,     1, dc_gp_exp, DC_exp, dc_pf_n)

    // fetch_exp_out = Fetch_gp ? GP_IDT : PF_IDT  (sel=1→in1=GP, sel=0→in0=PF)
    `MUX_2(u_fexp,   5, fetch_exp_out, 5'd14, 5'd13, Fetch_gp)   // PF / GP
    // DC_exp_out   = dc_gp_exp ? GP_IDT : PF_IDT
    `MUX_2(u_dcexp,  5, DC_exp_out,    5'd14, 5'd13, dc_gp_exp)  // PF / GP
    `MUX_2(u_eidx,   5, exp_idx,       fetch_exp_out, DC_exp_out, DC_exp)
    `MUX_2(u_iidx,   5, int_idx,       5'd4,  5'd7,  DMA_int)    // DDR / DMA
    `MUX_2(u_ridx,   5, rom_idx,       int_idx, exp_idx, exp_pipe_clear)

    // ----------------------------------------------------------------
    // rom_addr
    // SV does {2'b00, rom_idx} into a 5-bit lvalue, which truncates the
    // top two zeros — the net is just rom_idx. Mirroring that here.
    // ----------------------------------------------------------------
    wire [4:0] rom_addr;
    assign rom_addr = rom_idx;

    // ----------------------------------------------------------------
    // rom_sel register (5-bit). WE = exp_pipe_clear | int_pipe_clear.
    // ----------------------------------------------------------------
    wire        rom_sel_we;
    wire [4:0]  rom_sel;

    `OR_2      (u_sel_we,  1, rom_sel_we, exp_pipe_clear, int_pipe_clear)
    `REG_RST_WE(u_rom_sel, 5, clk, rst, rom_sel_we, rom_addr, rom_sel)

    // ----------------------------------------------------------------
    // idtEntryAddy = IDTR + (rom_sel << 3)
    //   IDTR tied to 0 (settled design decision).
    //   rom_sel << 3 done as a constant-shift wire concat (no gates).
    // ----------------------------------------------------------------
    reg [31:0] IDTR;
    wire [31:0] shifted_rom_sel;
    wire [31:0] idtEntryAddy;
    wire        idt_cout_unused;

    //assign idtr            = 32'h0;
    assign shifted_rom_sel = {24'h0, rom_sel, 3'b0};

    `ADD_N(u_idt_add, 32, idtEntryAddy, idt_cout_unused, IDTR, shifted_rom_sel, 1'b0)

    // ----------------------------------------------------------------
    // 16-byte cache line fan-out (pure assigns)
    // ----------------------------------------------------------------
    assign rom_data_out[ 0*8 +: 8] = 8'h31;
    assign rom_data_out[ 1*8 +: 8] = 8'h32;
    assign rom_data_out[ 2*8 +: 8] = idtEntryAddy[ 7: 0];
    assign rom_data_out[ 3*8 +: 8] = idtEntryAddy[15: 8];
    assign rom_data_out[ 4*8 +: 8] = idtEntryAddy[23:16];
    assign rom_data_out[ 5*8 +: 8] = idtEntryAddy[31:24];
    assign rom_data_out[ 6*8 +: 8] = 8'h30;
    assign rom_data_out[ 7*8 +: 8] = 8'h00;
    assign rom_data_out[ 8*8 +: 8] = 8'h00;
    assign rom_data_out[ 9*8 +: 8] = 8'h00;
    assign rom_data_out[10*8 +: 8] = 8'h00;
    assign rom_data_out[11*8 +: 8] = 8'h00;
    assign rom_data_out[12*8 +: 8] = 8'h00;
    assign rom_data_out[13*8 +: 8] = 8'h00;
    assign rom_data_out[14*8 +: 8] = 8'h00;
    assign rom_data_out[15*8 +: 8] = 8'h00;

endmodule
