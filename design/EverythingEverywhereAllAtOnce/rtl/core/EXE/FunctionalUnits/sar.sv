// SAR - Shift Arithmetic Right Functional Unit
// Handles SAR8, SAR16, SAR32
// Sign-extends during right shift

import common_pkg::*;

module sar (
    input  uint64_t operand,
    input  uint8_t  shift_count,    // Shift amount
    input  logic [1:0] data_size,   // 00=8bit, 01=16bit, 10=32bit
    
    output uint64_t result,
    output bool CF,  // Carry flag (last bit shifted out)
    output bool PF,  // Parity flag
    output bool AF,  // Auxiliary flag (undefined for shifts)
    output bool ZF,  // Zero flag
    output bool SF,  // Sign flag
    output bool OF   // Overflow flag (always 0 for SAR)
);

    logic signed [7:0]  operand8;
    logic signed [15:0] operand16;
    logic signed [31:0] operand32;
    logic [7:0]  result8;
    logic [15:0] result16;
    logic [31:0] result32;
    logic [5:0]  count;
    
    always_comb begin
        AF = 1'b0;  // Undefined for shifts
        OF = 1'b0;  // Always 0 for SAR
        
        case (data_size)
            2'b00: begin  // 8-bit SAR
                count = shift_count[4:0] & 6'h07;  // Mask to 0-7
                operand8 = operand[7:0];
                
                if (count == 0) begin
                    result = {56'h0, operand[7:0]};
                    CF = 1'b0;
                end else begin
                    result8 = operand8 >>> count;  // Arithmetic right shift
                    result = {56'h0, result8};
                    CF = (count <= 8) ? operand[count - 1] : operand[7];
                end
                
                ZF = (result[7:0] == 8'h0);
                SF = result[7];
                PF = ~^result[7:0];
            end
            
            2'b01: begin  // 16-bit SAR
                count = shift_count[4:0] & 6'h0F;  // Mask to 0-15
                operand16 = operand[15:0];
                
                if (count == 0) begin
                    result = {48'h0, operand[15:0]};
                    CF = 1'b0;
                end else begin
                    result16 = operand16 >>> count;  // Arithmetic right shift
                    result = {48'h0, result16};
                    CF = (count <= 16) ? operand[count - 1] : operand[15];
                end
                
                ZF = (result[15:0] == 16'h0);
                SF = result[15];
                PF = ~^result[7:0];
            end
            
            2'b10: begin  // 32-bit SAR
                count = shift_count[4:0];  // Use all 5 bits (0-31)
                operand32 = operand[31:0];
                
                if (count == 0) begin
                    result = {32'h0, operand[31:0]};
                    CF = 1'b0;
                end else begin
                    result32 = operand32 >>> count;  // Arithmetic right shift
                    result = {32'h0, result32};
                    CF = (count <= 32) ? operand[count - 1] : operand[31];
                end
                
                ZF = (result[31:0] == 32'h0);
                SF = result[31];
                PF = ~^result[7:0];
            end
            
            default: begin
                result = 64'h0;
                CF = 1'b0;
                ZF = 1'b1;
                SF = 1'b0;
                PF = 1'b1;
            end
        endcase
    end

endmodule
