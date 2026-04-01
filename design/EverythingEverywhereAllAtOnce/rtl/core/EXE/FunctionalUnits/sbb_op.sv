// SBB - Subtract with Borrow Functional Unit
// Handles SBB8, SBB16, SBB32
// Updates ZF, SF, PF, CF, OF, AF

import common_pkg::*;

module sbb_op (
    input  uint64_t operand1,      // Destination (srA)
    input  uint64_t operand2,      // Source (srB)
    input  bool     CF_in,         // Borrow-in
    input  logic [1:0] data_size,  // 00=8bit, 01=16bit, 10=32bit
    
    output uint64_t dr_o,        // Merged 64-bit result (dr_o)
    output uint64_t res_buf_o,    // Lower 32 bits (zero extended)
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

    uint64_t result,
    assign bin = CF_in;

    always_comb begin
        // Perform sizing-aware subtraction to get correct CF/OF/AF
        case (data_size)
            2'b00: begin // 8-bit
                diff    = {1'b0, operand1[7:0]} - {1'b0, operand2[7:0]} - bin;
                res_val = {24'h0, diff[7:0]};
                CF      = diff[8];
                OF      = (operand1[7] ^ operand2[7]) & (operand1[7] ^ res_val[7]);
                ZF      = (res_val[7:0] == 8'h0);
                SF      = res_val[7];
                result  = {operand1[63:8], res_val[7:0]};
            end

            2'b01: begin // 16-bit
                diff    = {1'b0, operand1[15:0]} - {1'b0, operand2[15:0]} - bin;
                res_val = {16'h0, diff[15:0]};
                CF      = diff[16];
                OF      = (operand1[15] ^ operand2[15]) & (operand1[15] ^ res_val[15]);
                ZF      = (res_val[15:0] == 16'h0);
                SF      = res_val[15];
                result  = {operand1[63:16], res_val[15:0]};
            end

            default: begin // 32-bit (10)
                diff    = {1'b0, operand1[31:0]} - {1'b0, operand2[31:0]} - bin;
                res_val = diff[31:0];
                CF      = diff[32];
                OF      = (operand1[31] ^ operand2[31]) & (operand1[31] ^ res_val[31]);
                ZF      = (res_val == 32'h0);
                SF      = res_val[31];
                result  = {operand1[63:32], res_val};
            end
        endcase

        // res_buf_o is always the lower 32 bits zero-extended
        res_buf_o = {32'd0, result[31:0]};
        dr_o = {32'd0, result[31:0]};

        // PF always reflects parity of the lowest 8 bits
        PF = ~^res_val[7:0];

        // AF is borrow from bit 3 to 4
        // Logic: (A ^ B ^ Result) & 0x10
        AF = ((operand1[3:0] ^ operand2[3:0] ^ res_val[3:0]) & 4'h10) != 0;
    end

endmodule
