import common_pkg::*;

module sar_op(
    input  uint64_t value_i,
    input  uint64_t shift_amt_i,
    input  logic [3:0] data_size,
    input  logic [3:0] sr_data_size_vec, // 0 selects [12:8], 1 selects [4:0]
    input  logic shift_by_one,
    // Inputs for previous flag states (for count=0 case)
    input  logic curr_zf_flag, curr_sf_flag, curr_pf_flag, curr_of_flag, curr_cf_flag,
    output uint64_t dr_o,
    output uint64_t res_buf_o,
    output logic ZF, SF, PF, OF, CF
);

    logic [5:0] count;
    uint64_t    result;

    always_comb begin
        // 1. Initialize with current states (Handles the "count=0" flag preservation)
        result = value_i;
        ZF = curr_zf_flag;
        SF = curr_sf_flag;
        PF = curr_pf_flag;
        CF = curr_cf_flag;
        OF = curr_of_flag;

        // 2. Count selection logic (matching your SAL implementation)
        if (shift_by_one) begin
            count = 6'd1;
        end else begin
            count = (~data_size[0]) ? {1'b0, shift_amt_i[12:8]} : {1'b0, shift_amt_i[4:0]};
        end

        // 3. Execution (Only if count > 0)
        if (count > 0) begin
            // Per manual: SAR clears OF for 1-bit shifts. 
            // For count > 1, OF is undefined (setting to 0 per your preference).
            OF = 1'b0; 

            case (data_size)
                4'b0001: begin // AL (8-bit)
                    CF = (count <= 8) ? value_i[count - 1] : value_i[7];
                    result[7:0] = uint8_t'($signed(value_i[7:0]) >>> count);
                    
                    ZF = (result[7:0] == 8'h0);
                    SF = result[7];
                    PF = ~^result[7:0];
                end

                4'b0010: begin // AH (8-bit upper)
                    CF = (count <= 8) ? value_i[8 + count - 1] : value_i[15];
                    result[15:8] = uint8_t'($signed(value_i[15:8]) >>> count);
                    
                    ZF = (result[15:8] == 8'h0);
                    SF = result[15];
                    PF = ~^result[15:8];
                end

                4'b0011: begin // AX (16-bit)
                    CF = (count <= 16) ? value_i[count - 1] : value_i[15];
                    result[15:0] = uint16_t'($signed(value_i[15:0]) >>> count);
                    
                    ZF = (result[15:0] == 16'h0);
                    SF = result[15];
                    PF = ~^result[7:0]; // Parity always on low 8 bits
                end

                4'b0111: begin // EAX (32-bit)
                    CF = (count <= 32) ? value_i[count - 1] : value_i[31];
                    result[31:0] = uint32_t'($signed(value_i[31:0]) >>> count);
                    result[63:32] = 32'd0; // Zero-extend result to 64-bit
                    
                    ZF = (result[31:0] == 32'h0);
                    SF = result[31];
                    PF = ~^result[7:0];
                end

                default: ;
            endcase
        end
    end

    assign dr_o = result;
    assign res_buf_o = result;

endmodule
