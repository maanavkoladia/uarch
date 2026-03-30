module sal_op(
    input  uint64_t value_i,
    input  uint64_t shift_amt_i,
    input  logic [1:0] data_size, 
    input  bool shift_by_one,
    // Inputs for previous flag states (required because count=0 must not change them)
    input  bool prev_ZF, prev_SF, prev_PF, prev_CF, prev_OF,

    output uint64_t dr_o,
    output bool ZF, SF, PF, OF, CF
);

    logic [4:0] count; // Masked to 5 bits per x86 spec
    assign count = shift_by_one ? 5'd1 : shift_amt_i[4:0];

    always_comb begin
        // Initialize with previous values
        dr_o = value_i;
        ZF = prev_ZF; SF = prev_SF; PF = prev_PF; 
        CF = prev_CF; OF = prev_OF;

        if (count > 0) begin
            case (data_size)
                2'b00: begin // 8-bit
                    dr_o[7:0] = value_i[7:0] << count;
                    CF = (count <= 8) ? value_i[8 - count] : 0;
                    ZF = (dr_o[7:0] == 8'h0);
                    SF = dr_o[7];
                    // OF is only defined for 1-bit shifts
                    if (count == 1) OF = dr_o[7] ^ CF;
                end
                
                2'b01: begin // 16-bit
                    dr_o[15:0] = value_i[15:0] << count;
                    CF = (count <= 16) ? value_i[16 - count] : 0;
                    ZF = (dr_o[15:0] == 16'h0);
                    SF = dr_o[15];
                    if (count == 1) OF = dr_o[15] ^ CF;
                end
                
                default: begin // 32-bit
                    dr_o[31:0] = value_i[31:0] << count;
                    CF = value_i[32 - count]; // count is max 31, so this is safe
                    ZF = (dr_o[31:0] == 32'h0);
                    SF = dr_o[31];
                    if (count == 1) OF = dr_o[31] ^ CF;
                end
            endcase
            PF = ~^dr_o[7:0];
        end
    end
endmodule
