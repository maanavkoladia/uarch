import common_pkg::*;

module sar_op(
    input  uint64_t value_i,
    input  uint64_t shift_amt_i,
    input  logic [3:0]  data_size,   // 0001=AL, 0010=AH, 0011=AX, 0111=EAX
    input  logic        shift_by_one,
    
    output uint64_t dr_o,
    output uint64_t res_buf_o,
    output logic    ZF, SF, PF, OF, CF
);

    logic [4:0] count;
    assign count = shift_by_one ? 5'd1 : shift_amt_i[4:0];

    always_comb begin
        // Defaults
        dr_o = value_i;
        CF   = 1'b0;
        OF   = 1'b0; // SAR clears OF for 1-bit shifts per x86 spec

        if (count > 0) begin
            case (data_size)
                4'b0001: begin // AL (8-bit lower)
                    CF = (count <= 8) ? value_i[count - 1] : value_i[7];
                    dr_o[7:0] = $signed(value_i[7:0]) >>> count;
                end
                
                4'b0010: begin // AH (8-bit upper)
                    // AH is bits [15:8], so bit shifted out is at 8 + (count - 1)
                    CF = (count <= 8) ? value_i[8 + count - 1] : value_i[15];
                    dr_o[15:8] = $signed(value_i[15:8]) >>> count;
                end
                
                4'b0011: begin // AX (16-bit)
                    CF = (count <= 16) ? value_i[count - 1] : value_i[15];
                    dr_o[15:0] = $signed(value_i[15:0]) >>> count;
                end
                
                4'b0111: begin // EAX (32-bit)
                    CF = (count <= 32) ? value_i[count - 1] : value_i[31];
                    dr_o[31:0] = $signed(value_i[31:0]) >>> count;
                end
                default: ;
            endcase
        end

        res_buf_o = {32'd0, dr_o[31:0]};

        // Flag Generation
        case (data_size)
            4'b0001: begin
                ZF = (dr_o[7:0] == 8'h0);
                SF = dr_o[7];
                PF = ~^dr_o[7:0];
            end
            4'b0010: begin
                ZF = (dr_o[15:8] == 8'h0);
                SF = dr_o[15];
                PF = ~^dr_o[15:8]; // Parity of the result byte
            end
            4'b0011: begin
                ZF = (dr_o[15:0] == 16'h0);
                SF = dr_o[15];
                PF = ~^dr_o[7:0];
            end
            4'b0111: begin
                ZF = (dr_o[31:0] == 32'h0);
                SF = dr_o[31];
                PF = ~^dr_o[7:0];
            end
            default: begin
                ZF = 0; SF = 0; PF = 0;
            end
        endcase
    end

endmodule
