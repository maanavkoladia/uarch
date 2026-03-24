// SIMD - SIMD/MMX Operations Functional Unit
// Handles PADDW, PADDD, PAVGB, PAVGW, PACKSSWB, PACKSSDW

import common_pkg::*;

module simd (
    input  uint64_t operand1,    // MM register or memory
    input  uint64_t operand2,    // MM register or memory
    input  logic [2:0] simd_op,  // Operation select
    
    output uint64_t result
);

    // SIMD operation encoding
    localparam PADDW     = 3'b000;  // Add packed words (4x16)
    localparam PADDD     = 3'b001;  // Add packed dwords (2x32)
    localparam PAVGB     = 3'b010;  // Average packed bytes (8x8)
    localparam PAVGW     = 3'b011;  // Average packed words (4x16)
    localparam PACKSSWB  = 3'b100;  // Pack signed word to signed byte with saturation
    localparam PACKSSDW  = 3'b101;  // Pack signed dword to signed word with saturation
    
    // Intermediate values for packed operations
    logic [15:0] word0, word1, word2, word3;
    logic [31:0] dword0, dword1;
    logic [7:0]  byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7;
    
    // Saturation helper functions
    function logic [7:0] saturate_s16_to_s8(input logic signed [15:0] val);
        if (val > 127) return 8'h7F;
        else if (val < -128) return 8'h80;
        else return val[7:0];
    endfunction
    
    function logic [15:0] saturate_s32_to_s16(input logic signed [31:0] val);
        if (val > 32767) return 16'h7FFF;
        else if (val < -32768) return 16'h8000;
        else return val[15:0];
    endfunction
    
    always_comb begin
        result = 64'h0;
        
        case (simd_op)
            PADDW: begin  // Add packed words (4 x 16-bit)
                word0 = operand1[15:0]  + operand2[15:0];
                word1 = operand1[31:16] + operand2[31:16];
                word2 = operand1[47:32] + operand2[47:32];
                word3 = operand1[63:48] + operand2[63:48];
                result = {word3, word2, word1, word0};
            end
            
            PADDD: begin  // Add packed dwords (2 x 32-bit)
                dword0 = operand1[31:0]  + operand2[31:0];
                dword1 = operand1[63:32] + operand2[63:32];
                result = {dword1, dword0};
            end
            
            PAVGB: begin  // Average packed unsigned bytes (8 x 8-bit)
                byte0 = (operand1[7:0]   + operand2[7:0]   + 8'h01) >> 1;
                byte1 = (operand1[15:8]  + operand2[15:8]  + 8'h01) >> 1;
                byte2 = (operand1[23:16] + operand2[23:16] + 8'h01) >> 1;
                byte3 = (operand1[31:24] + operand2[31:24] + 8'h01) >> 1;
                byte4 = (operand1[39:32] + operand2[39:32] + 8'h01) >> 1;
                byte5 = (operand1[47:40] + operand2[47:40] + 8'h01) >> 1;
                byte6 = (operand1[55:48] + operand2[55:48] + 8'h01) >> 1;
                byte7 = (operand1[63:56] + operand2[63:56] + 8'h01) >> 1;
                result = {byte7, byte6, byte5, byte4, byte3, byte2, byte1, byte0};
            end
            
            PAVGW: begin  // Average packed unsigned words (4 x 16-bit)
                word0 = (operand1[15:0]  + operand2[15:0]  + 16'h0001) >> 1;
                word1 = (operand1[31:16] + operand2[31:16] + 16'h0001) >> 1;
                word2 = (operand1[47:32] + operand2[47:32] + 16'h0001) >> 1;
                word3 = (operand1[63:48] + operand2[63:48] + 16'h0001) >> 1;
                result = {word3, word2, word1, word0};
            end
            
            PACKSSWB: begin  // Pack 4×i16 → 8×i8 with signed saturation
                // operand1 has 4 words, operand2 has 4 words
                // Result: 8 bytes (saturated)
                byte0 = saturate_s16_to_s8(operand1[15:0]);
                byte1 = saturate_s16_to_s8(operand1[31:16]);
                byte2 = saturate_s16_to_s8(operand1[47:32]);
                byte3 = saturate_s16_to_s8(operand1[63:48]);
                byte4 = saturate_s16_to_s8(operand2[15:0]);
                byte5 = saturate_s16_to_s8(operand2[31:16]);
                byte6 = saturate_s16_to_s8(operand2[47:32]);
                byte7 = saturate_s16_to_s8(operand2[63:48]);
                result = {byte7, byte6, byte5, byte4, byte3, byte2, byte1, byte0};
            end
            
            PACKSSDW: begin  // Pack 2×i32 → 4×i16 with signed saturation
                // operand1 has 2 dwords, operand2 has 2 dwords
                // Result: 4 words (saturated)
                word0 = saturate_s32_to_s16(operand1[31:0]);
                word1 = saturate_s32_to_s16(operand1[63:32]);
                word2 = saturate_s32_to_s16(operand2[31:0]);
                word3 = saturate_s32_to_s16(operand2[63:32]);
                result = {word3, word2, word1, word0};
            end
            
            default: begin
                result = 64'h0;
            end
        endcase
    end

endmodule
