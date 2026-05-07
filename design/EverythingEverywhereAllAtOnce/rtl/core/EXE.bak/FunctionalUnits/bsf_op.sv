// BSF - Bit Scan Forward Functional Unit
// Handles BSF16, BSF32
// Scans from LSB to MSB looking for first set bit.
//
// data_size[2] : 1 = 32-bit BSF, 0 = 16-bit BSF
//
// Partial-register write semantics:
//   * 32-bit BSF (BSF r32, r/m32): writes the full 32-bit destination.
//   * 16-bit BSF (BSF r16, r/m16): only the low 16 bits of the destination
//     register may change; the upper 16 bits must be preserved.  Because the
//     register file always commits a 32-bit value (no partial-write enable),
//     this FU must merge the new low-16 result with the destination's
//     current upper-16 itself.  srA carries the destination's current value
//     for that purpose; srB is the scanned source operand.
//
// Spec note (Intel SDM Vol 2A, BSF):
//   When SRC = 0, ZF is set to 1 and DEST is "undefined".  We pick 0 as the
//   concrete undefined value (for 32-bit) and 0 in the low 16 bits with the
//   upper-16 preserved (for 16-bit).

import common_pkg::*;

module bsf_op (
    input  uint64_t srA,             // destination's current value (for partial-write merge)
    input  uint64_t srB,             // value to scan (source operand)
    input  logic [3:0] data_size,    // [2]==1 -> 32-bit, [2]==0 -> 16-bit
    output uint64_t dr_o,            // merged destination value
    output uint64_t res_buf_o,
    output bool     ZF               // 1 if scanned source was zero
);

    logic [31:0] op32;
    logic [15:0] op16;
    logic [5:0]  index32;
    logic [4:0]  index16;
    logic        found32, found16;
    logic [63:0] result32, result16;
    logic        ZF32, ZF16;

    // 32-bit BSF
    always_comb begin
        op32 = srB[31:0];
        found32 = 1'b0;
        index32 = 6'd0;
        if (op32 == 32'h0) begin
            ZF32 = 1'b1;
            result32 = 64'h0;
        end else begin
            ZF32 = 1'b0;
            for (int i = 0; i < 32; i++) begin
                if (!found32 && op32[i]) begin
                    index32 = i[5:0];
                    found32 = 1'b1;
                end
            end
            result32 = {58'h0, index32};
        end
    end

    // 16-bit BSF
    always_comb begin
        op16 = srB[15:0];
        found16 = 1'b0;
        index16 = 5'd0;
        if (op16 == 16'h0) begin
            ZF16 = 1'b1;
            result16 = 64'h0;
        end else begin
            ZF16 = 1'b0;
            for (int i = 0; i < 16; i++) begin
                if (!found16 && op16[i]) begin
                    index16 = i[4:0];
                    found16 = 1'b1;
                end
            end
            result16 = {59'h0, index16};
        end
    end

    // Width-aware merge with the destination's current value (srA):
    //   32-bit BSF -> overwrite all 32 bits of the dest, upper-32 of the
    //                 64-bit FU output is zero-padded (regfile uses [31:0]).
    //   16-bit BSF -> overwrite low-16 only; preserve dest[31:16] from srA.
    uint64_t merged;
    always_comb begin
        if (data_size[2]) begin
            merged = {32'h0, result32[31:0]};
        end else begin
            merged = {32'h0, srA[31:16], result16[15:0]};
        end
    end

    assign dr_o      = merged;
    assign res_buf_o = merged;
    assign ZF        = (data_size[2]) ? ZF32 : ZF16;

endmodule
