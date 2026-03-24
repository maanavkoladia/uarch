// AND - Bitwise AND Functional Unit
// Handles AND8, AND16, AND16sign, AND32, AND32sign

import common_pkg::*;

module and_op (
    input  uint64_t operand1,
    input  uint64_t operand2,
    input  logic [1:0] data_size,  // 00=8bit, 01=16bit, 10=32bit
    
    output uint64_t result,
    output bool CF,  // Carry flag (always 0 for AND)
    output bool PF,  // Parity flag
    output bool AF,  // Auxiliary carry flag (undefined for AND)
    output bool ZF,  // Zero flag
    output bool SF,  // Sign flag
    output bool OF   // Overflow flag (always 0 for AND)
);

    logic [7:0]  result8;
    logic [15:0] result16;
    logic [31:0] result32;
    
    always_comb begin
        // AND clears CF and OF
        CF = 1'b0;
        OF = 1'b0;
        AF = 1'b0;  // Undefined, setting to 0
        
        case (data_size)
            2'b00: begin  // 8-bit AND
                result8 = operand1[7:0] & operand2[7:0];
                result = {56'h0, result8};
                
                ZF = (result8 == 8'h0);
                SF = result8[7];
                PF = ~^result8;  // Even parity
            end
            
            2'b01: begin  // 16-bit AND
                result16 = operand1[15:0] & operand2[15:0];
                result = {48'h0, result16};
                
                ZF = (result16 == 16'h0);
                SF = result16[15];
                PF = ~^result16[7:0];  // Parity on low byte
            end
            
            2'b10: begin  // 32-bit AND
                result32 = operand1[31:0] & operand2[31:0];
                result = {32'h0, result32};
                
                ZF = (result32 == 32'h0);
                SF = result32[31];
                PF = ~^result32[7:0];  // Parity on low byte
            end
            
            default: begin
                result = 64'h0;
                ZF = 1'b1;
                SF = 1'b0;
                PF = 1'b1;
            end
        endcase
    end

endmodule
