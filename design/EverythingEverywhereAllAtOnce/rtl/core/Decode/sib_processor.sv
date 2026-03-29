module sib_processor (
    input uint8 sib_byte,
    output reg_ids_e sib_idx_id,
    output reg_ids_e sib_base_id,
    output uint8_t sib_scale
);
    always_comb begin
        unique case (sib_byte[2:0])
            3'b000: sib_base_id = reg_ids_e.EAX;
            3'b001: sib_base_id = reg_ids_e.ECX;
            3'b010: sib_base_id = reg_ids_e.EDX;
            3'b011: sib_base_id = reg_ids_e.EBX;
            3'b100: sib_base_id = reg_ids_e.ESP;
            3'b101: sib_base_id = reg_ids_e.EBP;
            3'b110: sib_base_id = reg_ids_e.ESI;
            3'b111: sib_base_id = reg_ids_e.EDI;
        endcase

        unique case (sib_byte[5:3])
            3'b000: sib_idx_id = reg_ids_e.EAX;
            3'b001: sib_idx_id = reg_ids_e.ECX;
            3'b010: sib_idx_id = reg_ids_e.EDX;
            3'b011: sib_idx_id = reg_ids_e.EBX;
            3'b100: sib_idx_id = reg_ids_e.ESP;
            3'b101: sib_idx_id = reg_ids_e.EBP;
            3'b110: sib_idx_id = reg_ids_e.ESI;
            3'b111: sib_idx_id = reg_ids_e.EDI;
        endcase

        unique case (sib_byte[7:6])
            2'b00: sib_scale = 8'd1;
            2'b01: sib_scale = 8'd2;
            2'b10: sib_scale = 8'd4;
            2'b11: sib_scale = 8'd8;
        endcase
    end
endmodule