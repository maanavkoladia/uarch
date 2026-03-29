import common_pkg::*;

module sal_op(
    input  uint64_t value_i,        // The value to be shifted
    input  uint64_t shift_amt_i,    // The shift count (used if shift_by_one is low)
    input  logic [1:0] data_size, 
    input  bool shift_by_one,

    output uint64_t dr_o,
    output uint64_t res_buf_o,
    output bool ZF,
    output bool SF,
    output bool PF,
    output bool OF,
    output bool CF
);

    uint64_t shift_result;
    logic [5:0] final_count;
    logic [63:0] temp_res;
    
    // Determine shift amount: 1 if forced, otherwise mask shift_amt_i to 5 bits
    assign final_count = shift_by_one ? 6'd1 : shift_amt_i[5:0];

    always_comb begin
        // Default: No shift
        temp_res = value_i;
        CF = 0;
        OF = 0;

        case (data_size)
            2'b00: begin // 8-bit
                if (final_count > 0) begin
                    temp_res = {56'b0, value_i[7:0]} << final_count;
                    CF = value_i[8 - final_count];
                    // OF = MSB of result XOR CF
                    OF = temp_res[7] ^ CF;
                end
                shift_result = {value_i[63:8], temp_res[7:0]};
            end
            
            2'b01: begin // 16-bit
                if (final_count > 0) begin
                    temp_res = {48'b0, value_i[15:0]} << final_count;
                    CF = value_i[16 - final_count];
                    OF = temp_res[15] ^ CF;
                end
                shift_result = {value_i[63:16], temp_res[15:0]};
            end
            
            default: begin // 32-bit
                if (final_count > 0) begin
                    temp_res = {32'b0, value_i[31:0]} << final_count;
                    CF = value_i[32 - final_count];
                    OF = temp_res[31] ^ CF;
                end
                shift_result = {value_i[63:32], temp_res[31:0]};
            end
        endcase
    end

    // Drive data outputs
    assign dr_o = shift_result;
    assign res_buf_o = {32'd0, shift_result[31:0]};

    // Flag Logic
    always_comb begin
        // If count is 0, flags are not affected (handled by external write logic)
        // SF, ZF, PF are updated based on the sized result
        case (data_size)
            2'b00: begin
                ZF = (shift_result[7:0] == 8'h0);
                SF = shift_result[7];
                PF = ~^shift_result[7:0];
            end
            2'b01: begin
                ZF = (shift_result[15:0] == 16'h0);
                SF = shift_result[15];
                PF = ~^shift_result[7:0];
            end
            default: begin
                ZF = (shift_result[31:0] == 32'h0);
                SF = shift_result[31];
                PF = ~^shift_result[7:0];
            end
        endcase
        
        // Note: x86 spec says OF is undefined for shifts > 1. 
        // Some implementations leave it, but we zero it or keep it as computed.
        if (final_count != 1) OF = 1'b0; 
    end

endmodule
