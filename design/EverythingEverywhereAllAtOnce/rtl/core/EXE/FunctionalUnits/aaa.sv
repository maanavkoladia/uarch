module aaa (
    input  uint64_t EAX_in,     // Full 64-bit input
    input  bool     AF_flag_in, // Input Auxiliary Flag

    output uint64_t EAX_out,    // 64-bit output (ready to write to EAX)
    output bool     CF,         // Carry flag
    output bool     AF          // Auxiliary flag
);

    logic adjust;
    logic [7:0] AL, AH;
    logic [15:0] AX_new;

    always_comb begin
        // Extract AX from EAX
        AL = EAX_in[7:0];
        AH = EAX_in[15:8];

        // Determine if adjustment is needed
        adjust = ((AL & 8'h0F) > 8'h09) || AF_flag_in;

        if (adjust) begin
            AL = AL + 8'h06;
            AH = AH + 1;
            CF = 1'b1;
            AF = 1'b1;
        end else begin
            CF = 1'b0;
            AF = 1'b0;
        end

        // Recombine AL/AH into AX
        AX_new = {AH, AL};

        // Build 64-bit output: upper 32 bits zeroed, preserve EAX[31:16]
        // EAX_out = {upper32=0, old_EAX[31:16], new_AX}
        EAX_out = {32'h0, EAX_in[31:16], AX_new};
    end

endmodule