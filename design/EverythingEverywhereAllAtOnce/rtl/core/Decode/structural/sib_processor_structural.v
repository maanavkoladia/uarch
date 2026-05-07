module sib_processor (
    input wire[7:0] sib_byte,
    output wire[`REG_ID_W - 1 :0] sib_idx_id,
    output wire[`REG_ID_W - 1 :0] sib_base_id,
    output wire[7:0] sib_scale,
    output wire sib_segment_override
);
    `MUX_8(sib_base_id_mux, `REG_ID_W, sib_base_id, `EAX, `ECX, `EDX, `EBX, `ESP, `EBP, `ESI, `EDI, sib_byte[2:0])

    `MUX_8(sib_idx_id_mux, `REG_ID_W, sib_idx_id, `EAX, `ECX, `EDX, `EBX, `ESP, `EBP, `ESI, `EDI, sib_byte[5:3])

    `MUX_4(sib_scale_mux, 8, sib_scale, 8'd0, 8'd1, 8'd2, 8'd3, sib_byte[7:6])

    assign sib_segment_override = (sib_base_id == `ESP);


endmodule