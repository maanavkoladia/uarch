// SBB - Subtract with Borrow Functional Unit
// Handles SBB8, SBB16, SBB32
// Updates ZF, SF, PF, CF, OF, AF

import common_pkg::*;

module sbb_op (
    input  uint64_t srA,      // Destination (srA)
    input  uint64_t srB,      // Source (srB)
    input  bool     CF_in,         // Borrow-in
    input  logic [3:0] data_size,  // 0001=AL(8), 0010=AH(8), 0011=AX(16), 0111=EAX(32)
    
    output uint64_t dr_o,          // Merged 64-bit result
    output uint64_t res_buf_o,     // Lower 32 bits (zero extended)
    output bool CF,
    output bool PF,
    output bool AF,
    output bool ZF,
    output bool SF,
    output bool OF
);

    logic [32:0] diff;
    logic [31:0] res_val;
    logic        bin;
    uint64_t     result;

    assign bin = CF_in;

    always_comb begin
        // Initialize defaults
        diff = 33'd0;
        res_val = 32'd0;
        CF = 1'b0;
        OF = 1'b0;
        ZF = 1'b0;
        SF = 1'b0;
        result = srA;
        
        // Perform sizing-aware subtraction to get correct CF/OF/AF
        case (data_size)
            4'b0001: begin // Lower 8-bit (AL)
                diff    = {1'b0, srA[7:0]} - {1'b0, srB[7:0]} - bin;
                res_val = {24'h0, diff[7:0]};
                CF      = diff[8];
                OF      = (srA[7] ^ srB[7]) & (srA[7] ^ diff[7]);
                ZF      = (diff[7:0] == 8'h0);
                SF      = diff[7];
                result  = {srA[63:8], diff[7:0]};
            end

            4'b0010: begin // Upper 8-bit (AH)
                diff    = {1'b0, srA[15:8]} - {1'b0, srB[15:8]} - bin;
                res_val = {24'h0, diff[7:0]};
                CF      = diff[8];
                OF      = (srA[15] ^ srB[15]) & (srA[15] ^ diff[7]);
                ZF      = (diff[7:0] == 8'h0);
                SF      = diff[7];
                result  = {srA[63:16], diff[7:0], srA[7:0]};
            end

            4'b0011: begin // 16-bit (AX)
                diff    = {1'b0, srA[15:0]} - {1'b0, srB[15:0]} - bin;
                res_val = {16'h0, diff[15:0]};
                CF      = diff[16];
                OF      = (srA[15] ^ srB[15]) & (srA[15] ^ diff[15]);
                ZF      = (diff[15:0] == 16'h0);
                SF      = diff[15];
                result  = {srA[63:16], diff[15:0]};
            end

            4'b0111: begin // 32-bit (EAX)
                diff    = {1'b0, srA[31:0]} - {1'b0, srB[31:0]} - bin;
                res_val = diff[31:0];
                CF      = diff[32];
                OF      = (srA[31] ^ srB[31]) & (srA[31] ^ diff[31]);
                ZF      = (diff[31:0] == 32'h0);
                SF      = diff[31];
                result  = {srA[63:32], diff[31:0]};
            end

            default: begin // Invalid size
                diff    = 33'd0;
                res_val = 32'd0;
                CF      = 1'b0;
                OF      = 1'b0;
                ZF      = 1'b0;
                SF      = 1'b0;
                result  = srA;
            end
        endcase

        // res_buf_o is always the lower 32 bits zero-extended
        res_buf_o = {32'd0, result[31:0]};
        dr_o = result;

        // PF always reflects parity of the lowest 8 bits of result
        PF = ~^result[7:0];

        // AF is borrow from bit 3 to 4
        AF = ((srA[3:0] < srB[3:0]) || ((srA[3:0] == srB[3:0]) && bin));
    end

endmodule
