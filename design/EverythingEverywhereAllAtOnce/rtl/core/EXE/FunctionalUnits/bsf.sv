// BSF - Bit Scan Forward Functional Unit
// Handles BSF16, BSF32
// Scans from LSB to MSB looking for first set bit

import common_pkg::*;

module bsf (
    input  uint64_t operand,
    input  logic    is_32bit,    // 1=32bit, 0=16bit
    
    output uint64_t result,      // Index of first set bit
    output bool     ZF           // Zero flag (set if operand is 0)
);

    logic [31:0] op32;
    logic [15:0] op16;
    logic [5:0]  index32;
    logic [4:0]  index16;
    logic        found32, found16;
    
    always_comb begin
        if (is_32bit) begin
            // 32-bit BSF
            op32 = operand[31:0];
            found32 = 1'b0;
            index32 = 6'd0;
            
            if (op32 == 32'h0) begin
                ZF = 1'b1;
                result = 64'h0;  // Result undefined if ZF=1, using 0
            end else begin
                ZF = 1'b0;
                // Find first set bit from LSB
                for (int i = 0; i < 32; i++) begin
                    if (!found32 && op32[i]) begin
                        index32 = i[5:0];
                        found32 = 1'b1;
                    end
                end
                result = {58'h0, index32};
            end
        end else begin
            // 16-bit BSF
            op16 = operand[15:0];
            found16 = 1'b0;
            index16 = 5'd0;
            
            if (op16 == 16'h0) begin
                ZF = 1'b1;
                result = 64'h0;  // Result undefined if ZF=1, using 0
            end else begin
                ZF = 1'b0;
                // Find first set bit from LSB
                for (int i = 0; i < 16; i++) begin
                    if (!found16 && op16[i]) begin
                        index16 = i[4:0];
                        found16 = 1'b1;
                    end
                end
                result = {59'h0, index16};
            end
        end
    end

endmodule
