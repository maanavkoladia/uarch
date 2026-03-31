// SAR - Arithmetic Right Shift Functional Unit
// Handles SAR8, SAR16, SAR32
// Updates ZF, SF, PF, CF; OF is 0 for count=1, undefined for count > 1
// AF is undefined (omitted)

import common_pkg::*;

module sar_op(
    input  uint64_t value_i,        // The value to be shifted
    input  uint64_t shift_amt_i,    // The shift count
    input  logic [1:0] data_size,   // 00=8b, 01=16b, 10=32b
    input  logic       shift_by_one,
    // Note: If count is 0, flags should not be updated by the writeback logic
    output uint64_t dr_o,
    output uint64_t res_buf_o,
    output logic    ZF,
    output logic    SF,
    output logic    PF,
    output logic    OF,
    output logic    CF
);

    logic [63:0] shifted_val;
    logic [4:0]  count; // x86 masks shift count to 5 bits for 8/16/32-bit ops

    assign count = shift_by_one ? 5'd1 : shift_amt_i[4:0];

    always_comb begin
        // Defaults
        shifted_val = value_i;
        CF = 0;
        OF = 0; // SAR clears OF for count=1; undefined for count > 1 (clearing is safe)

        if (count > 0) begin
            case (data_size)
                2'b00: begin // 8-bit
                    // Perform sign-extension to 64-bit for the shift, then mask back
                    shifted_val[7:0] = $signed(value_i[7:0]) >>> count;
                    CF = value_i[count - 1];
                end
                
                2'b01: begin // 16-bit
                    shifted_val[15:0] = $signed(value_i[15:0]) >>> count;
                    CF = value_i[count - 1];
                end
                
                default: begin // 32-bit
                    shifted_val[31:0] = $signed(value_i[31:0]) >>> count;
                    CF = value_i[count - 1];
                end
            endcase
        end

        // Merge shifted bits into the original value (upper bits preserved for srA)
        case (data_size)
            2'b00:   dr_o = {value_i[63:8],  shifted_val[7:0]};
            2'b01:   dr_o = {value_i[63:16], shifted_val[15:0]};
            default: dr_o = {value_i[63:32], shifted_val[31:0]};
        endcase

        res_buf_o = {32'd0, dr_o[31:0]};

        // Flag Generation (Only valid if count > 0)
        case (data_size)
            2'b00: begin
                ZF = (dr_o[7:0] == 8'h0);
                SF = dr_o[7];
            end
            2'b01: begin
                ZF = (dr_o[15:0] == 16'h0);
                SF = dr_o[15];
            end
            default: begin
                ZF = (dr_o[31:0] == 32'h0);
                SF = dr_o[31];
            end
        endcase
        
        PF = ~^dr_o[7:0]; // Parity always uses the low 8 bits
    end

endmodule
