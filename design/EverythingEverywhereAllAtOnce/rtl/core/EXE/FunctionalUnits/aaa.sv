// AAA - ASCII Adjust AL after Addition
// Adjusts AL register after unpacked BCD addition

import common_pkg::*;

module aaa (
    input  uint64_t AL_in,   // Input AL register (only [7:0] used)
    input  bool     AF_in,   // Input Auxiliary Flag
    
    output uint64_t AL_out,  // Output AL register
    output uint64_t AH_out,  // Output AH register (increment if adjust)
    output bool     CF,      // Carry flag
    output bool     AF       // Auxiliary flag
);

    logic adjust;
    logic [7:0] al_val;
    
    always_comb begin
        al_val = AL_in[7:0];
        
        // Check if adjustment is needed
        adjust = ((al_val & 8'h0F) > 8'h09) || AF_in;
        
        if (adjust) begin
            AL_out = {56'h0, (al_val + 8'h06) & 8'h0F};
            AH_out = 64'h01;  // Increment AH
            CF = 1'b1;
            AF = 1'b1;
        end else begin
            AL_out = {56'h0, al_val & 8'h0F};
            AH_out = 64'h00;
            CF = 1'b0;
            AF = 1'b0;
        end
    end

endmodule
