// ----------------------------------------------------------------------------
// reg_rst_we : N-bit register, active-low sync reset to 0, active-high WE
// Priority: rst (active low) overrides we.
//   !rst          -> q <= 0
//   rst & we      -> q <= din
//   rst & !we     -> q <= q (hold)
// 
// Implementation:
//   d_we   = we ? din : q       (write-enable mux)
//   d_final= rst ? d_we : 0     (reset mux, rst active low so !rst -> 0)
//   reg_n always captures d_final (we tied low = always write)
// ----------------------------------------------------------------------------
module MPS_reg_rst_we$ #(
    parameter WIDTH = 1
) (
    input  wire clk,
    input  wire rst,   // active LOW
    input  wire we,
    input  wire [WIDTH-1:0] d,
    output wire [WIDTH-1:0] q
);

    localparam NUM_REGS = (WIDTH + 63) / 64;

    genvar i;

generate
    for (i = 0; i < NUM_REGS; i = i + 1) begin : gen_reg64

        localparam integer REMAIN = WIDTH - i*64;
        localparam integer SLICE_W = (REMAIN >= 64) ? 64 : REMAIN;

        wire [63:0] d_slice;
        wire [63:0] q_slice;

        if (REMAIN >= 64) begin : gen_reg64_if_block
            assign d_slice = d[i*64 +: 64];
            assign q[i*64 +: 64] = q_slice;
        end else begin : gen_reg64_else_block
            assign d_slice = {{(64-SLICE_W){1'b0}}, d[i*64 +: SLICE_W]};
            assign q[i*64 +: SLICE_W] = q_slice[SLICE_W-1:0];
        end

        reg64e$ u_reg (
            .CLK(clk),
            .Din(d_slice),
            .Q(q_slice),
            .QBAR(),
            .CLR(rst),
            .PRE(1'b1),
            .en(we)
        );

    end
endgenerate
endmodule
