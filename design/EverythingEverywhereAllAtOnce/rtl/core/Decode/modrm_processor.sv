import reg_ids_pkg::*;

module modrm_processor (
    input byte_t modrm_byte,
    input logic [2:0] datasize,
    output reg_ids_e mod_rm_id,
    output reg_ids_e reg_id
);

    always_comb begin
        unique case (modrm_byte[7:6])
            2'b00, 2'b01, 2'b10: begin
                unique case(modrm_byte[2:0])
                    3'd0: mod_rm_id = EAX;
                    3'd1: mod_rm_id = ECX;
                    3'd2: mod_rm_id = EDX;
                    3'd3: mod_rm_id = EBX;
                    3'd4: mod_rm_id = ESP;
                    3'd5: mod_rm_id = EBP;
                    3'd6: mod_rm_id = ESI;
                    3'd7: mod_rm_id = EDI;
                endcase
            end
            2'b11: begin
                unique case(modrm_byte[2:0])
                    3'd0: mod_rm_id = datasize[1] ?
                            (datasize[0] ? MM0 : EAX) :
                            (datasize[0] ? AX : AL);
                    3'd1: mod_rm_id = datasize[1] ?
                            (datasize[0] ? MM1 : ECX) :
                            (datasize[0] ? CX : CL);
                    3'd2: mod_rm_id = datasize[1] ?
                            (datasize[0] ? MM2 : EDX) :
                            (datasize[0] ? DX : DL);
                    3'd3: mod_rm_id = datasize[1] ?
                            (datasize[0] ? MM3 : EBX) :
                            (datasize[0] ? BX : BL);
                    3'd4: mod_rm_id = datasize[1] ?
                            (datasize[0] ? MM4 : ESP) :
                            (datasize[0] ? SP : AH);
                    3'd5: mod_rm_id = datasize[1] ?
                            (datasize[0] ? MM5 : EBP) :
                            (datasize[0] ? BP : CH);
                    3'd6: mod_rm_id = datasize[1] ?
                            (datasize[0] ? MM6 : ESI) :
                            (datasize[0] ? SI : DH);
                    3'd7: mod_rm_id = datasize[1] ?
                            (datasize[0] ? MM7 : EDI) :
                            (datasize[0] ? DI : BH);
                endcase
            end
        endcase

        unique case(modrm_byte[5:3])
            3'd0: reg_id = datasize[1] ?
                    (datasize[0] ? MM0 : EAX) :
                    (datasize[0] ? AX : AL);
            3'd1: reg_id = datasize[1] ?
                    (datasize[0] ? MM1 : ECX) :
                    (datasize[0] ? CX : CL);
            3'd2: reg_id = datasize[1] ?
                    (datasize[0] ? MM2 : EDX) :
                    (datasize[0] ? DX : DL);
            3'd3: reg_id = datasize[1] ?
                    (datasize[0] ? MM3 : EBX) :
                    (datasize[0] ? BX : BL);
            3'd4: reg_id = datasize[1] ?
                    (datasize[0] ? MM4 : ESP) :
                    (datasize[0] ? SP : AH);
            3'd5: reg_id = datasize[1] ?
                    (datasize[0] ? MM5 : EBP) :
                    (datasize[0] ? BP : CH);
            3'd6: reg_id = datasize[1] ?
                    (datasize[0] ? MM6 : ESI) :
                    (datasize[0] ? SI : DH);
            3'd7: reg_id = datasize[1] ?
                    (datasize[0] ? MM7 : EDI) :
                    (datasize[0] ? DI : BH);
        endcase
    end


endmodule