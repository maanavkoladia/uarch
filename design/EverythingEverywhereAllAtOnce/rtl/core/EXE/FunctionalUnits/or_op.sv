// OR - Bitwise OR Functional Unit
// Handles OR8, OR16, OR32 (lower 32 bits)
// Updates ZF, SF, PF; clears CF, OF, AF

import common_pkg::*;

module or_op(
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

    uint64_t or_result;
    uint64_t merged_result;
    bool ld_16;
    bool ld_32;

    assign or_result = srA | srB;
    assign ld_16 = data_size[0] | data_size[1];
    assign ld_32 = data_size[1];

    // Only update lower 8/16/32 bits, upper 32 bits remain from srA
    assign merged_result[7:0]    = or_result[7:0];
    assign merged_result[15:8]   = ld_16 ? or_result[15:8] : srA[15:8];
    assign merged_result[31:16]  = ld_32 ? or_result[31:16] : srA[31:16];
    assign merged_result[63:32]  = srA[63:32];

    assign dr_o = merged_result;
    assign res_buf_o = {32'd0, merged_result[31:0]}; // Only lower 32 bits to res_buf_o

    always_comb begin
        // CF and OF are always cleared for OR
        OF = 0;
        CF = 0;
        
        // PF always reflects parity of the lowest 8 bits, regardless of data_size
        PF = ~^merged_result[7:0];

        case (data_size)
            2'b00: begin // 8-bit
                ZF = (merged_result[7:0] == 8'h0);
                SF = merged_result[7];
            end
            2'b01: begin // 16-bit
                ZF = (merged_result[15:0] == 16'h0);
                SF = merged_result[15];
            end
            default: begin // 32-bit
                ZF = (merged_result[31:0] == 32'h0);
                SF = merged_result[31];
            end
        endcase
    end

endmodule
