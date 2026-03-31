module cmp (
    input  uint64_t operand1,
    input  uint64_t operand2,
    input  logic [1:0] data_size,  // 00=8bit, 01=16bit, 10=32bit
    
    output bool CF,
    output bool OF,
    output bool SF,
    output bool ZF,
    output bool AF,
    output bool PF

);

    logic [32:0] diff32;
    logic [31:0] result32;

    // Single subtraction
    assign diff32  = {1'b0, operand1[31:0]} - {1'b0, operand2[31:0]};
    assign result32 = diff32[31:0];

    always_comb begin
        // Defaults
        CF = 0;
        PF = 0;
        AF = 0;
        ZF = 0;
        SF = 0;
        OF = 0;

        case (data_size)
            2'b00: begin // 8-bit
                ZF = (result32[7:0] == 8'h0);
                SF = result32[7];
                PF = ~^result32[7:0];

                CF = diff32[8];  // borrow
                AF = (operand1[3:0] < operand2[3:0]);

                OF = (operand1[7] ^ operand2[7]) &
                     (operand1[7] ^ result32[7]);
            end

            2'b01: begin // 16-bit
                ZF = (result32[15:0] == 16'h0);
                SF = result32[15];
                PF = ~^result32[7:0];

                CF = diff32[16];
                AF = (operand1[3:0] < operand2[3:0]);

                OF = (operand1[15] ^ operand2[15]) &
                     (operand1[15] ^ result32[15]);
            end

            2'b10: begin // 32-bit
                ZF = (result32[31:0] == 32'h0);
                SF = result32[31];
                PF = ~^result32[7:0];

                CF = diff32[32];
                AF = (operand1[3:0] < operand2[3:0]);

                OF = (operand1[31] ^ operand2[31]) &
                     (operand1[31] ^ result32[31]);
            end

            default: begin
                // optional: assert or safe default
            end
        endcase
    end

endmodule