// CMP - Compare Functional Unit (SUB without storing result)
// Handles COMPARE8, COMPARE16, COMPARE32

import common_pkg::*;

module cmp (
    input  uint64_t operand1,
    input  uint64_t operand2,
    input  logic [1:0] data_size,  // 00=8bit, 01=16bit, 10=32bit
    
    // No result output (compare doesn't store)
    output bool CF,  // Carry flag
    output bool PF,  // Parity flag
    output bool AF,  // Auxiliary carry flag
    output bool ZF,  // Zero flag
    output bool SF,  // Sign flag
    output bool OF   // Overflow flag
);

    logic [8:0]  diff8;
    logic [16:0] diff16;
    logic [32:0] diff32;
    
    always_comb begin
        // Default values
        CF = 1'b0;
        PF = 1'b0;
        AF = 1'b0;
        ZF = 1'b0;
        SF = 1'b0;
        OF = 1'b0;
        
        case (data_size)
            2'b00: begin  // 8-bit COMPARE
                diff8 = {1'b0, operand1[7:0]} - {1'b0, operand2[7:0]};
                
                CF = diff8[8];  // Borrow (op1 < op2)
                ZF = (diff8[7:0] == 8'h0);
                SF = diff8[7];
                PF = ~^diff8[7:0];
                AF = (operand1[3:0] < operand2[3:0]);
                OF = ((operand1[7] != operand2[7]) && (operand1[7] != diff8[7]));
            end
            
            2'b01: begin  // 16-bit COMPARE
                diff16 = {1'b0, operand1[15:0]} - {1'b0, operand2[15:0]};
                
                CF = diff16[16];
                ZF = (diff16[15:0] == 16'h0);
                SF = diff16[15];
                PF = ~^diff16[7:0];
                AF = (operand1[3:0] < operand2[3:0]);
                OF = ((operand1[15] != operand2[15]) && (operand1[15] != diff16[15]));
            end
            
            2'b10: begin  // 32-bit COMPARE
                diff32 = {1'b0, operand1[31:0]} - {1'b0, operand2[31:0]};
                
                CF = diff32[32];
                ZF = (diff32[31:0] == 32'h0);
                SF = diff32[31];
                PF = ~^diff32[7:0];
                AF = (operand1[3:0] < operand2[3:0]);
                OF = ((operand1[31] != operand2[31]) && (operand1[31] != diff32[31]));
            end
            
            default: begin
                // Do nothing
            end
        endcase
    end

endmodule
