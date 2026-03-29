// ADD - Bitwise ADD Functional Unit
// Handles ADD8, ADD16, ADD32 (lower 32 bits)
// Updates ZF, SF, PF, CF, OF; AF is undefined

import common_pkg::*;

module add_op(
    input  uint64_t srA,
    input  uint64_t srB,
    input  logic [1:0] data_size, // 00=8b, 01=16b, 10=32b
    output uint64_t dr_o,
    output uint64_t res_buf_o,
    output bool ZF,
    output bool SF,
    output bool PF,
    output bool OF,
    output bool CF
);

    uint64_t add_result;
    uint64_t merged_result;
    bool ld_16;
    bool ld_32;
    logic [32:0] sum32;

    assign sum32 = {1'b0, srA[31:0]} + {1'b0, srB[31:0]};
    assign add_result[31:0] = sum32[31:0];
    assign add_result[63:32] = 32'd0;
    assign ld_16 = data_size[0] | data_size[1];
    assign ld_32 = data_size[1];

    // Only update lower 8/16/32 bits, upper 32 bits remain from srA
    assign merged_result[7:0]    = add_result[7:0];
    assign merged_result[15:8]   = ld_16 ? add_result[15:8] : srA[15:8];
    assign merged_result[31:16]  = ld_32 ? add_result[31:16] : srA[31:16];
    assign merged_result[63:32]  = srA[63:32];

    assign dr_o = merged_result;
    assign res_buf_o = {32'd0, merged_result[31:0]}; // Only lower 32 bits to res_buf_o

    always_comb begin
        // Default
        OF = 0;
        CF = 0;
        case (data_size)
            2'b00: begin
                ZF = (merged_result[7:0] == 8'h0);
                SF = merged_result[7];
                PF = ~^merged_result[7:0];
                CF = sum32[8];
                OF = (^srA[7] & ^srB[7] & merged_result[7]) | (srA[7] & srB[7] & ~merged_result[7]);
            end
            2'b01: begin
                ZF = (merged_result[15:0] == 16'h0);
                SF = merged_result[15];
                PF = ~^merged_result[7:0];
                CF = sum32[16];
                OF = (^srA[15] & ^srB[15] & merged_result[15]) | (srA[15] & srB[15] & ~merged_result[15]);
            end
            default: begin
                ZF = (merged_result[31:0] == 32'h0);
                SF = merged_result[31];
                PF = ~^merged_result[7:0];
                CF = sum32[32];
                OF = (^srA[31] & ^srB[31] & merged_result[31]) | (srA[31] & srB[31] & ~merged_result[31]);
            end
        endcase
    end

endmodule
