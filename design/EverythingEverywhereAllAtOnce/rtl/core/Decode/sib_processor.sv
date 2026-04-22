import common_pkg::*;
module sib_processor (
    input uint8_t sib_byte,
    output reg_ids_e sib_idx_id,
    output reg_ids_e sib_base_id,
    output uint8_t sib_scale
);
    always_comb begin
        case (sib_byte[2:0])
            3'b000: sib_base_id = EAX;
            3'b001: sib_base_id = ECX;
            3'b010: sib_base_id = EDX;
            3'b011: sib_base_id = EBX;
            3'b100: sib_base_id = ESP;
            3'b101: sib_base_id = EBP;
            3'b110: sib_base_id = ESI;
            3'b111: sib_base_id = EDI;
        endcase

        case (sib_byte[5:3])
            3'b000: sib_idx_id = EAX;
            3'b001: sib_idx_id = ECX;
            3'b010: sib_idx_id = EDX;
            3'b011: sib_idx_id = EBX;
            3'b100: sib_idx_id = ESP;
            3'b101: sib_idx_id = EBP;
            3'b110: sib_idx_id = ESI;
            3'b111: sib_idx_id = EDI;
        endcase

        case (sib_byte[7:6])
            2'b00: sib_scale = 8'd1;
            2'b01: sib_scale = 8'd2;
            2'b10: sib_scale = 8'd4;
            2'b11: sib_scale = 8'd8;
        endcase
    end
endmodule