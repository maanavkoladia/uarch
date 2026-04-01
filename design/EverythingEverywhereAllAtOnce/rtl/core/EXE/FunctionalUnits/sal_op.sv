module sal_op(
    input  logic [63:0] value_i,
    input  logic [63:0] shift_amt_i,
    input  logic [3:0]  data_size, 
    input  logic        shift_by_one,
    
    // Inputs for previous flag states
    input  logic prev_ZF, prev_SF, prev_PF, prev_CF, prev_OF,

    output logic [63:0] dr_o,
    output logic ZF, SF, PF, OF, CF
);

    logic [4:0] count;
    assign count = shift_by_one ? 5'd1 : shift_amt_i[4:0];

    always_comb begin
        // Defaults
        dr_o = value_i;
        ZF = prev_ZF; SF = prev_SF; PF = prev_PF; 
        CF = prev_CF; OF = prev_OF;

        if (count > 0) begin
            case (data_size)
                4'b0001: begin // AL (8-bit lower)
                    dr_o[7:0] = value_i[7:0] << count;
                    CF = (count <= 8) ? value_i[8 - count] : 0;
                    SF = dr_o[7];
                    ZF = (dr_o[7:0] == 8'h0);
                    PF = ~^dr_o[7:0];
                    if (count == 1) OF = dr_o[7] ^ CF;
                end
                
                4'b0010: begin // AH (8-bit upper)
                    dr_o[15:8] = value_i[15:8] << count;
                    CF = (count <= 8) ? value_i[16 - count] : 0;
                    SF = dr_o[15];
                    ZF = (dr_o[15:8] == 8'h0);
                    PF = ~^dr_o[15:8]; // PF usually reflects low 8 bits of result
                    if (count == 1) OF = dr_o[15] ^ CF;
                end
                
                4'b0011: begin // AX (16-bit)
                    dr_o[15:0] = value_i[15:0] << count;
                    CF = (count <= 16) ? value_i[16 - count] : 0;
                    SF = dr_o[15];
                    ZF = (dr_o[15:0] == 16'h0);
                    PF = ~^dr_o[7:0];
                    if (count == 1) OF = dr_o[15] ^ CF;
                end
                
                4'b0111: begin // EAX (32-bit)
                    dr_o[31:0] = value_i[31:0] << count;
                    // For 32-bit, if count > 0, CF is bit 32-count
                    CF = value_i[32 - count]; 
                    SF = dr_o[31];
                    ZF = (dr_o[31:0] == 32'h0);
                    PF = ~^dr_o[7:0];
                    if (count == 1) OF = dr_o[31] ^ CF;
                end
                
                default: ; // Do nothing
            endcase
        end
    end
endmodule
