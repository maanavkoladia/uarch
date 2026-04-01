module cmp32_structural_mux (
    input  uint64_t operand1,
    input  uint64_t operand2,
    input  logic [3:0] data_size,  // bottom 3 bits used: data_size[2:0]
    
    output bool CF,
    output bool OF,
    output bool SF,
    output bool ZF,
    output bool AF,
    output bool PF
);

    // Single 32-bit subtraction
    logic [32:0] diff32;   // 32-bit result + carry
    logic [31:0] result32;

    assign diff32  = {1'b0, operand1[31:0]} - {1'b0, operand2[31:0]};
    assign result32 = diff32[31:0];

    // Signals for different ranges
    logic [7:0] lower8   = result32[7:0];
    logic [7:0] upper8   = result32[15:8];
    logic [15:0] lower16 = result32[15:0];
    logic [31:0] full32  = result32[31:0];

    always_comb begin
        // Default flags
        CF = 0; OF = 0; SF = 0; ZF = 0; AF = 0; PF = 0;

        case (data_size[2:0])
            3'b001: begin // lower 8 bits
                ZF = (lower8 == 8'h0);
                SF = lower8[7];
                PF = ~^lower8;

                CF = diff32[8];
                AF = (operand1[3:0] < operand2[3:0]);
                OF = (operand1[7] ^ operand2[7]) & (operand1[7] ^ lower8[7]);
            end

            3'b010: begin // upper 8 bits
                ZF = (upper8 == 8'h0);
                SF = upper8[7];
                PF = ~^upper8;

                CF = diff32[16];
                AF = (operand1[11:8] < operand2[11:8]);
                OF = (operand1[15] ^ operand2[15]) & (operand1[15] ^ upper8[7]);
            end

            3'b011: begin // lower 16 bits
                ZF = (lower16 == 16'h0);
                SF = lower16[15];
                PF = ~^lower16[7:0];

                CF = diff32[16];
                AF = (operand1[3:0] < operand2[3:0]);
                OF = (operand1[15] ^ operand2[15]) & (operand1[15] ^ lower16[15]);
            end

            3'b111: begin // full 32 bits
                ZF = (full32 == 32'h0);
                SF = full32[31];
                PF = ~^full32[7:0];

                CF = diff32[32];
                AF = (operand1[3:0] < operand2[3:0]);
                OF = (operand1[31] ^ operand2[31]) & (operand1[31] ^ full32[31]);
            end

            default: begin
                // invalid / error case
                ZF = 1'b0;
                SF = 1'b0;
                PF = 1'b0;
                CF = 1'b0;
                AF = 1'b0;
                OF = 1'b0;
            end
        endcase
    end

endmodule