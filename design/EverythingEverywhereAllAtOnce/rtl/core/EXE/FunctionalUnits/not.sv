// NOT - Bitwise NOT Functional Unit
// Handles NOT8, NOT16, NOT32
// NOT does not affect any flags

import common_pkg::*;

module not_op (
    input  uint64_t operand,
    input  logic [1:0] data_size,  // 00=8bit, 01=16bit, 10=32bit
    
    output uint64_t result
);

    always_comb begin
        case (data_size)
            2'b00: begin  // 8-bit NOT
                result = {56'h0, ~operand[7:0]};
            end
            
            2'b01: begin  // 16-bit NOT
                result = {48'h0, ~operand[15:0]};
            end
            
            2'b10: begin  // 32-bit NOT
                result = {32'h0, ~operand[31:0]};
            end
            
            default: begin
                result = 64'h0;
            end
        endcase
    end

endmodule
