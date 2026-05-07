// ADD - Bitwise ADD Functional Unit
// Handles ADD8(AL), ADD8(AH), ADD16, ADD32 (lower 32 bits)
// Updates ZF, SF, PF, CF, OF, AF
// data_size: 4'h1=AL, 4'h2=AH, 4'h3=AX, 4'h7=EAX

import common_pkg::*;

module add_op(
    input  uint64_t srA,
    input  uint64_t srB,
    input  logic [3:0] data_size,
    output uint64_t dr_o,
    output uint64_t res_buf_o,
    output logic ZF,
    output logic SF,
    output logic PF,
    output logic OF,
    output logic CF,
    output logic AF
);

    // Separate width-appropriate sums; avoids cross-byte carry contamination
    // (especially critical for the AH case).
    logic [8:0]  al_sum;   // 8-bit AL + BL, carry at [8]
    logic [8:0]  ah_sum;   // 8-bit AH + BH, carry at [8]
    logic [16:0] ax_sum;   // 16-bit AX + BX, carry at [16]
    logic [32:0] eax_sum;  // 32-bit EAX + EBX, carry at [32]

    logic [4:0] af_sum;

    assign al_sum  = {1'b0, srA[7:0]}  + {1'b0, srB[7:0]};
    assign ah_sum  = {1'b0, srA[15:8]} + {1'b0, srB[15:8]};
    assign ax_sum  = {1'b0, srA[15:0]} + {1'b0, srB[15:0]};
    assign eax_sum = {1'b0, srA[31:0]} + {1'b0, srB[31:0]};

    // AF: carry out from bit 3 into bit 4
    assign af_sum = ({1'b0, srA[3:0]} + {1'b0, srB[3:0]});
    assign AF = af_sum[4];

    // Result merge: only the affected byte(s) are updated
    uint64_t merged_result;
    always_comb begin
        merged_result = srA;
        case (data_size)
            4'b0001: merged_result[7:0]  = al_sum[7:0];
            4'b0010: merged_result[15:8] = ah_sum[7:0];
            4'b0011: merged_result[15:0] = ax_sum[15:0];
            4'b0111: merged_result[31:0] = eax_sum[31:0];
            default: merged_result = srA;
        endcase
    end

    assign dr_o      = {32'd0, merged_result[31:0]};
    assign res_buf_o = {32'd0, merged_result[31:0]};

    always_comb begin
        ZF = 0; SF = 0; CF = 0; OF = 0; PF = 0;

        case (data_size)
            4'b0001: begin // AL (lower 8-bit)
                ZF = (al_sum[7:0] == 8'h0);
                SF = al_sum[7];
                CF = al_sum[8];
                PF = ~^al_sum[7:0];
                OF = (~(srA[7] ^ srB[7])) & (srA[7] ^ al_sum[7]);
            end
            4'b0010: begin // AH (upper 8-bit)
                ZF = (ah_sum[7:0] == 8'h0);
                SF = ah_sum[7];
                CF = ah_sum[8];
                PF = ~^ah_sum[7:0];
                OF = (~(srA[15] ^ srB[15])) & (srA[15] ^ ah_sum[7]);
            end
            4'b0011: begin // AX (16-bit)
                ZF = (ax_sum[15:0] == 16'h0);
                SF = ax_sum[15];
                CF = ax_sum[16];
                PF = ~^ax_sum[7:0];
                OF = (~(srA[15] ^ srB[15])) & (srA[15] ^ ax_sum[15]);
            end
            4'b0111: begin // EAX (32-bit)
                ZF = (eax_sum[31:0] == 32'h0);
                SF = eax_sum[31];
                CF = eax_sum[32];
                PF = ~^eax_sum[7:0];
                OF = (~(srA[31] ^ srB[31])) & (srA[31] ^ eax_sum[31]);
            end
            default: begin
                ZF = 0; SF = 0; CF = 0; OF = 0; PF = 0;
            end
        endcase
    end

endmodule
