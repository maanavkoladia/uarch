// ADC - Add with Carry Functional Unit
// Handles ADC32, ADC32sign

import common_pkg::*;

module adc_op (
    input  uint64_t operand1,
    input  uint64_t operand2,
    input  bool     CF_in,       // Input carry flag
    input  logic [1:0] data_size,  // 00=8bit, 01=16bit, 10=32bit
    
    output uint64_t result,
    output bool CF,  // Carry flag
    output bool PF,  // Parity flag
    output bool AF,  // Auxiliary carry flag
    output bool ZF,  // Zero flag
    output bool SF,  // Sign flag
    output bool OF   // Overflow flag
);

    logic [8:0]  sum8;
    logic [16:0] sum16;
    logic [32:0] sum32;
    logic carry_in;

    logic [32:0] merged_result;
    
    always_comb begin
        carry_in = CF_in ? 1'b1 : 1'b0;
        
        // Default values
        result = 64'h0;
        CF = 1'b0;
        PF = 1'b0;
        AF = 1'b0;
        ZF = 1'b0;
        SF = 1'b0;
        OF = 1'b0;

        
        case (data_size)
            2'b00: begin  // 8-bit ADC
                sum8 = operand1[7:0] + operand2[7:0] + {8'h0, carry_in};
                result = {56'h0, sum8[7:0]};
                
                CF = sum8[8];
                ZF = (sum8[7:0] == 8'h0);
                SF = sum8[7];
                PF = ~^sum8[7:0];
                AF = ((operand1[3:0] + operand2[3:0] + {3'h0, carry_in}) > 4'hF);
                OF = (operand1[7] == operand2[7]) && (operand1[7] != sum8[7]);
            end
            
            2'b01: begin  // 16-bit ADC
                sum16 = operand1[15:0] + operand2[15:0] + {15'h0, carry_in};
                result = {48'h0, sum16[15:0]};
                
                CF = sum16[16];
                ZF = (sum16[15:0] == 16'h0);
                SF = sum16[15];
                PF = ~^sum16[7:0];
                AF = ((operand1[3:0] + operand2[3:0] + {3'h0, carry_in}) > 4'hF);
                OF = (operand1[15] == operand2[15]) && (operand1[15] != sum16[15]);
            end
            
            2'b10: begin  // 32-bit ADC
                sum32 = operand1[31:0] + operand2[31:0] + {31'h0, carry_in};
                result = {32'h0, sum32[31:0]};
                
                CF = sum32[32];
                ZF = (sum32[31:0] == 32'h0);
                SF = sum32[31];
                PF = ~^sum32[7:0];
                AF = ((operand1[3:0] + operand2[3:0] + {3'h0, carry_in}) > 4'hF);
                OF = (operand1[31] == operand2[31]) && (operand1[31] != sum32[31]);
            end
            
            default: result = 64'h0;
        endcase
    end

endmodule
