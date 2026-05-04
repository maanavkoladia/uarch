// Structural Verilog 2005 port of EXE/FunctionalUnits/bsf_op.sv
//
// 16-bit and 32-bit Bit Scan Forward.
//   For each width: cumulative-not-found chain produces a one-hot match[i],
//   then 32 (or 16) tristate drivers drive the index constant onto a shared
//   bus. When the input is all-zero, no driver is enabled and the output
//   index is forced to 0 via the final 2:1 mux. Width selected by data_size[2].
//
// Partial-register-write merge:
//   srB carries the value to scan (source operand).
//   srA carries the destination's current value.  For a 16-bit BSF the
//   register file commits a 32-bit value, so to preserve the architectural
//   semantics that BSF r16 leaves the upper 16 of the dest register unchanged
//   we have to merge srA[31:16] back into the result here.

module bsf_op (
    input  wire [63:0] srA,        // destination's current value (for partial-write merge)
    input  wire [63:0] srB,        // value to scan
    input  wire [3:0]  data_size,  // [2]=1 -> 32-bit, [2]=0 -> 16-bit
    output wire [63:0] dr_o,
    output wire [63:0] res_buf_o,
    output wire        ZF
);

    wire [31:0] op32;
    wire [15:0] op16;
    assign op32 = srB[31:0];
    assign op16 = srB[15:0];

    // ============================================================
    // 32-bit BSF
    // ============================================================
    // Cumulative-not-found chain: prefix_or32[i] = OR(op32[0..i-1])
    wire [31:0] prefix_or32;
    assign prefix_or32[0] = 1'b0;
    genvar gi32;
    generate
        for (gi32 = 0; gi32 < 31; gi32 = gi32 + 1) begin : g_por32
            `OR_2(u_por, 1, prefix_or32[gi32+1], prefix_or32[gi32], op32[gi32])
        end
    endgenerate

    wire [31:0] not_prefix32;
    `INV_N(u_inv_pre32, 32, prefix_or32, not_prefix32)

    // match32[i] = op32[i] AND ~prefix_or32[i]
    wire [31:0] match32;
    `AND_2(u_match32, 32, match32, op32, not_prefix32)

    // Active-low enables for tristateL$
    wire [31:0] match32_enbar;
    `INV_N(u_match32_enbar, 32, match32, match32_enbar)

    // Tristate-mux: 32 drivers each pushing constant 'i' onto idx32_bus.
    wire [5:0] idx32_bus;
    genvar gt32;
    generate
        for (gt32 = 0; gt32 < 32; gt32 = gt32 + 1) begin : g_tri32
            localparam [5:0] IDX_C = gt32;
            `TRISTATE_L(u_tri, 6, match32_enbar[gt32], IDX_C, idx32_bus)
        end
    endgenerate

    // op32 ZF / any-set
    wire op32_zf, op32_any;
    zf_red_32 u_zf32 (.x(op32), .z(op32_zf));
    `INV_N(u_any32, 1, op32_zf, op32_any)

    // index32 = op32_any ? idx32_bus : 6'd0
    wire [5:0] index32;
    `MUX_2(u_mux_idx32, 6, index32, 6'd0, idx32_bus, op32_any)

    // result32 = op32_any ? {58'h0, index32} : 64'h0
    wire [63:0] result32;
    `MUX_2(u_mux_res32, 64, result32, 64'h0, {58'h0, index32}, op32_any)

    // ============================================================
    // 16-bit BSF
    // ============================================================
    wire [15:0] prefix_or16;
    assign prefix_or16[0] = 1'b0;
    genvar gi16;
    generate
        for (gi16 = 0; gi16 < 15; gi16 = gi16 + 1) begin : g_por16
            `OR_2(u_por, 1, prefix_or16[gi16+1], prefix_or16[gi16], op16[gi16])
        end
    endgenerate

    wire [15:0] not_prefix16;
    `INV_N(u_inv_pre16, 16, prefix_or16, not_prefix16)

    wire [15:0] match16;
    `AND_2(u_match16, 16, match16, op16, not_prefix16)

    wire [15:0] match16_enbar;
    `INV_N(u_match16_enbar, 16, match16, match16_enbar)

    wire [4:0] idx16_bus;
    genvar gt16;
    generate
        for (gt16 = 0; gt16 < 16; gt16 = gt16 + 1) begin : g_tri16
            localparam [4:0] IDX_C = gt16;
            `TRISTATE_L(u_tri, 5, match16_enbar[gt16], IDX_C, idx16_bus)
        end
    endgenerate

    wire op16_zf, op16_any;
    zf_red_16 u_zf16 (.x(op16), .z(op16_zf));
    `INV_N(u_any16, 1, op16_zf, op16_any)

    wire [4:0] index16;
    `MUX_2(u_mux_idx16, 5, index16, 5'd0, idx16_bus, op16_any)

    wire [63:0] result16;
    `MUX_2(u_mux_res16, 64, result16, 64'h0, {59'h0, index16}, op16_any)

    // ============================================================
    // Width-aware merge with the destination's current value (srA):
    //   32-bit BSF -> {32'h0, result32[31:0]}
    //   16-bit BSF -> {32'h0, srA[31:16], result16[15:0]}   (preserve upper 16)
    // ============================================================
    wire [63:0] merged32;
    wire [63:0] merged16;
    assign merged32 = {32'h0, result32[31:0]};
    assign merged16 = {32'h0, srA[31:16], result16[15:0]};

    `MUX_2(u_mux_dr, 64, dr_o,      merged16, merged32, data_size[2])
    `MUX_2(u_mux_rb, 64, res_buf_o, merged16, merged32, data_size[2])
    `MUX_2(u_mux_zf,  1, ZF,        op16_zf,   op32_zf,  data_size[2])

endmodule
