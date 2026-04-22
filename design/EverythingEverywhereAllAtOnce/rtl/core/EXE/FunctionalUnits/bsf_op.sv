// BSF - Bit Scan Forward Functional Unit
// Handles BSF16, BSF32
// Scans from LSB to MSB looking for first set bit

import common_pkg::*;

module bsf_op (
    input  uint64_t srA,
    input  logic [3:0] data_size,    // 01=16bit, 10=32bit
    output uint64_t dr_o,      // Index of first set bit
    output uint64_t res_buf_o,
    output bool     ZF           // Zero flag (set if srA is 0)
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
        op32 = srA[31:0];
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
        op16 = srA[15:0];
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

    // Mux result based on data_size
    assign dr_o = (data_size[2]) ? result32 : result16;
    assign res_buf_o = (data_size[2]) ? result32 : result16;
    assign ZF   = (data_size[2]) ? ZF32 : ZF16;

endmodule
