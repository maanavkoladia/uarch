// OR - Bitwise OR Functional Unit
// Handles OR8, OR16, OR32 (lower 32 bits)
// Updates ZF, SF, PF; clears CF, OF, AF

import common_pkg::*;

module or_op(
    input  uint64_t srA,
    input  uint64_t srB,
    input  logic [3:0] data_size, // 00=8b, 01=16b, 10=32b
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
 

    assign or_result = srA | srB;
 

    // Only update lower 8/16/32 bits, upper 32 bits remain from srA
    assign merged_result[7:0]    = data_size[0] ?  or_result[7:0] : srA[7:0];
    assign merged_result[15:8]   = data_size[1] ? or_result[15:8] : srA[15:8];
    assign merged_result[31:16]  = data_size[2] ? or_result[31:16] : srA[31:16];
    assign merged_result[63:32]  = 32'd0;

    assign dr_o = merged_result;
    assign res_buf_o = merged_result; // Only lower 32 bits to res_buf_o

   
    // CF and OF are always cleared for OR
    assign OF = 0;
    assign CF = 0;
    
    // PF always reflects parity of the lowest 8 bits, regardless of data_size
    assign PF = ~^merged_result[7:0];

    bool zf_low8;
    bool zf_up8;
    bool zf_up16;
    assign zf_low8 = (merged_result[7:0] == 8'h0);
    assign zf_up8 = (merged_result[15:8] == 8'h0);
    assign zf_up16 = (merged_result[31:16] == 16'h0);

    bool zf_low16;
    assign zf_low16 = zf_low8 & zf_up8;

    always_comb begin
      case(data_size)
        4'b0001 : ZF = zf_low8; 
        4'b0010 : ZF = zf_up8;
        4'b0011 : ZF = zf_low16;
        4'b0100 : ZF = zf_low16 & zf_up16;
        default: ZF = 0;
      endcase  
    end

    // SF is the most significant bit of the result based on data size
    always_comb begin
      case(data_size)
        4'b0001 : SF = merged_result[7];   // 8-bit: bit 7
        4'b0010 : SF = merged_result[15];  // 16-bit: bit 15
        4'b0011 : SF = merged_result[15];  // 16-bit: bit 15
        4'b0111 : SF = merged_result[31];  // 32-bit: bit 31
        default: SF = 0;
      endcase
    end
 
endmodule
