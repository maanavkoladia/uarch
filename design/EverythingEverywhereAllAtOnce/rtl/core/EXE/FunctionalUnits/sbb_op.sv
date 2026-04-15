// SBB - Subtract with Borrow Functional Unit
// Handles SBB8(AL), SBB8(AH), SBB16, SBB32
// Updates ZF, SF, PF, CF, OF, AF
//
// Two's complement identity:
//   A - B - CF_in  =  A + (~B) + (~CF_in)
//   Borrow-out (CF) = ~carry_out_of_addition

import common_pkg::*;

module sbb_op (
    input  uint64_t srA,      // Destination
    input  uint64_t srB,      // Source
    input  bool     CF_in,    // Borrow-in
    input  logic [3:0] data_size,  // 0001=AL, 0010=AH, 0011=AX, 0111=EAX

    output uint64_t dr_o,
    output uint64_t res_buf_o,
    output bool CF,
    output bool PF,
    output bool AF,
    output bool ZF,
    output bool SF,
    output bool OF
);

    // Width-isolated two's complement sums: A + (~B) + (~CF_in)
    // Carry bit is at the top of each sum; borrow = ~carry.
    logic [8:0]  al_sum;
    logic [8:0]  ah_sum;
    logic [16:0] ax_sum;
    logic [32:0] eax_sum;

    assign al_sum  = {1'b0, srA[7:0]}  + {1'b0, ~srB[7:0]}  + {8'd0,  ~CF_in};
    assign ah_sum  = {1'b0, srA[15:8]} + {1'b0, ~srB[15:8]} + {8'd0,  ~CF_in};
    assign ax_sum  = {1'b0, srA[15:0]} + {1'b0, ~srB[15:0]} + {16'd0, ~CF_in};
    assign eax_sum = {1'b0, srA[31:0]} + {1'b0, ~srB[31:0]} + {32'd0, ~CF_in};

    // AF: borrow out of bit 3  =  ~carry of nibble two's complement sum
    logic [4:0] nibble_sum;
    assign nibble_sum = {1'b0, srA[3:0]} + {1'b0, ~srB[3:0]} + {4'd0, ~CF_in};
    assign AF = ~nibble_sum[4];

    uint64_t result;

    always_comb begin
        CF = 1'b0; OF = 1'b0; ZF = 1'b0; SF = 1'b0; PF = 1'b0;
        result = srA;

        case (data_size)
            4'b0001: begin // AL (lower 8-bit)
                result = {srA[63:8],  al_sum[7:0]};
                CF     = ~al_sum[8];
                ZF     = (al_sum[7:0] == 8'h0);
                SF     = al_sum[7];
                PF     = ~^al_sum[7:0];
                OF     = (srA[7]  ^ srB[7])  & (srA[7]  ^ al_sum[7]);
            end
            4'b0010: begin // AH (upper 8-bit)
                result = {srA[63:16], ah_sum[7:0], srA[7:0]};
                CF     = ~ah_sum[8];
                ZF     = (ah_sum[7:0] == 8'h0);
                SF     = ah_sum[7];
                PF     = ~^ah_sum[7:0];
                OF     = (srA[15] ^ srB[15]) & (srA[15] ^ ah_sum[7]);
            end
            4'b0011: begin // AX (16-bit)
                result = {srA[63:16], ax_sum[15:0]};
                CF     = ~ax_sum[16];
                ZF     = (ax_sum[15:0] == 16'h0);
                SF     = ax_sum[15];
                PF     = ~^ax_sum[7:0];
                OF     = (srA[15] ^ srB[15]) & (srA[15] ^ ax_sum[15]);
            end
            4'b0111: begin // EAX (32-bit)
                result = {32'd0, eax_sum[31:0]};
                CF     = ~eax_sum[32];
                ZF     = (eax_sum[31:0] == 32'h0);
                SF     = eax_sum[31];
                PF     = ~^eax_sum[7:0];
                OF     = (srA[31] ^ srB[31]) & (srA[31] ^ eax_sum[31]);
            end
            default: begin
                result = srA;
                CF = 1'b0; OF = 1'b0; ZF = 1'b0; SF = 1'b0; PF = 1'b0;
            end
        endcase

        dr_o      = {32'd0,result[31:0]};
        res_buf_o = {32'd0, result[31:0]};
    end

endmodule
