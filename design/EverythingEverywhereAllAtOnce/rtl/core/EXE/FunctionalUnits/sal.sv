// SAL - Shift Arithmetic Left Functional Unit
// Handles SAL8, SAL16, SAL32
// SAL is identical to SHL

import common_pkg::*;

module sal (
    input  uint64_t operand,
    input  uint8_t  shift_count,    // Shift amount (0-31, masked appropriately)
    input  logic [1:0] data_size,   // 00=8bit, 01=16bit, 10=32bit
    
    output uint64_t result,
    output bool CF,  // Carry flag (last bit shifted out)
    output bool PF,  // Parity flag
    output bool AF,  // Auxiliary flag (undefined for shifts)
    output bool ZF,  // Zero flag
    output bool SF,  // Sign flag
    output bool OF   // Overflow flag (set if sign changed)
);

    logic [7:0]  result8;
    logic [15:0] result16;
    logic [31:0] result32;
    logic [5:0]  count;
    logic        orig_sign, new_sign;
    
    always_comb begin
        AF = 1'b0;  // Undefined for shifts
        
        case (data_size)
            2'b00: begin  // 8-bit SAL
                count = shift_count[4:0] & 6'h07;  // Mask to 0-7
                
                if (count == 0) begin
                    result = {56'h0, operand[7:0]};
                    CF = 1'b0;
                    OF = 1'b0;
                end else begin
                    result8 = operand[7:0] << count;
                    result = {56'h0, result8};
                    CF = (count <= 8) ? operand[8 - count] : 1'b0;
                    orig_sign = operand[7];
                    new_sign = result8[7];
                    OF = (count == 1) ? (orig_sign ^ new_sign) : 1'b0;
                end
                
                ZF = (result[7:0] == 8'h0);
                SF = result[7];
                PF = ~^result[7:0];
            end
            
            2'b01: begin  // 16-bit SAL
                count = shift_count[4:0] & 6'h0F;  // Mask to 0-15
                
                if (count == 0) begin
                    result = {48'h0, operand[15:0]};
                    CF = 1'b0;
                    OF = 1'b0;
                end else begin
                    result16 = operand[15:0] << count;
                    result = {48'h0, result16};
                    CF = (count <= 16) ? operand[16 - count] : 1'b0;
                    orig_sign = operand[15];
                    new_sign = result16[15];
                    OF = (count == 1) ? (orig_sign ^ new_sign) : 1'b0;
                end
                
                ZF = (result[15:0] == 16'h0);
                SF = result[15];
                PF = ~^result[7:0];
            end
            
            2'b10: begin  // 32-bit SAL
                count = shift_count[4:0];  // Use all 5 bits (0-31)
                
                if (count == 0) begin
                    result = {32'h0, operand[31:0]};
                    CF = 1'b0;
                    OF = 1'b0;
                end else begin
                    result32 = operand[31:0] << count;
                    result = {32'h0, result32};
                    CF = (count <= 32) ? operand[32 - count] : 1'b0;
                    orig_sign = operand[31];
                    new_sign = result32[31];
                    OF = (count == 1) ? (orig_sign ^ new_sign) : 1'b0;
                end
                
                ZF = (result[31:0] == 32'h0);
                SF = result[31];
                PF = ~^result[7:0];
            end
            
            default: begin
                result = 64'h0;
                CF = 1'b0;
                OF = 1'b0;
                ZF = 1'b1;
                SF = 1'b0;
                PF = 1'b1;
            end
        endcase
    end

endmodule
