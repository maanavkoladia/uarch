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
                    3'd0: mod_rm_id = reg_ids_e.EAX;
                    3'd1: mod_rm_id = reg_ids_e.ECX;
                    3'd2: mod_rm_id = reg_ids_e.EDX;
                    3'd3: mod_rm_id = reg_ids_e.EBX;
                    3'd4: mod_rm_id = reg_ids_e.ESP;
                    3'd5: mod_rm_id = reg_ids_e.EBP;
                    3'd6: mod_rm_id = reg_ids_e.ESI;
                    3'd7: mod_rm_id = reg_ids_e.EDI;
                endcase
            end
            2'b11: begin
                unique case(modrm_byte[2:0])
                    3'd0: mod_rm_id = datasize[1] ?
                            (datasize[0] ? reg_ids_e.MM0 : reg_ids_e.EAX) :
                            (datasize[0] ? reg_ids_e.AX : reg_ids_e.AL);
                    3'd1: mod_rm_id = datasize[1] ?
                            (datasize[0] ? reg_ids_e.MM1 : reg_ids_e.ECX) :
                            (datasize[0] ? reg_ids_e.CX : reg_ids_e.CL);
                    3'd2: mod_rm_id = datasize[1] ?
                            (datasize[0] ? reg_ids_e.MM2 : reg_ids_e.EDX) :
                            (datasize[0] ? reg_ids_e.DX : reg_ids_e.DL);
                    3'd3: mod_rm_id = datasize[1] ?
                            (datasize[0] ? reg_ids_e.MM3 : reg_ids_e.EBX) :
                            (datasize[0] ? reg_ids_e.BX : reg_ids_e.BL);
                    3'd4: mod_rm_id = datasize[1] ?
                            (datasize[0] ? reg_ids_e.MM4 : reg_ids_e.ESP) :
                            (datasize[0] ? reg_ids_e.SP : reg_ids_e.AH);
                    3'd5: mod_rm_id = datasize[1] ?
                            (datasize[0] ? reg_ids_e.MM5 : reg_ids_e.EBP) :
                            (datasize[0] ? reg_ids_e.BP : reg_ids_e.CH);
                    3'd6: mod_rm_id = datasize[1] ?
                            (datasize[0] ? reg_ids_e.MM6 : reg_ids_e.ESI) :
                            (datasize[0] ? reg_ids_e.SI : reg_ids_e.DH);
                    3'd7: mod_rm_id = datasize[1] ?
                            (datasize[0] ? reg_ids_e.MM7 : reg_ids_e.EDI) :
                            (datasize[0] ? reg_ids_e.DI : reg_ids_e.BH);
                endcase
            end
        endcase

        unique case(modrm_byte[5:3])
            3'd0: reg_id = datasize[1] ?
                    (datasize[0] ? reg_ids_e.MM0 : reg_ids_e.EAX) :
                    (datasize[0] ? reg_ids_e.AX : reg_ids_e.AL);
            3'd1: reg_id = datasize[1] ?
                    (datasize[0] ? reg_ids_e.MM1 : reg_ids_e.ECX) :
                    (datasize[0] ? reg_ids_e.CX : reg_ids_e.CL);
            3'd2: reg_id = datasize[1] ?
                    (datasize[0] ? reg_ids_e.MM2 : reg_ids_e.EDX) :
                    (datasize[0] ? reg_ids_e.DX : reg_ids_e.DL);
            3'd3: reg_id = datasize[1] ?
                    (datasize[0] ? reg_ids_e.MM3 : reg_ids_e.EBX) :
                    (datasize[0] ? reg_ids_e.BX : reg_ids_e.BL);
            3'd4: reg_id = datasize[1] ?
                    (datasize[0] ? reg_ids_e.MM4 : reg_ids_e.ESP) :
                    (datasize[0] ? reg_ids_e.SP : reg_ids_e.AH);
            3'd5: reg_id = datasize[1] ?
                    (datasize[0] ? reg_ids_e.MM5 : reg_ids_e.EBP) :
                    (datasize[0] ? reg_ids_e.BP : reg_ids_e.CH);
            3'd6: reg_id = datasize[1] ?
                    (datasize[0] ? reg_ids_e.MM6 : reg_ids_e.ESI) :
                    (datasize[0] ? reg_ids_e.SI : reg_ids_e.DH);
            3'd7: reg_id = datasize[1] ?
                    (datasize[0] ? reg_ids_e.MM7 : reg_ids_e.EDI) :
                    (datasize[0] ? reg_ids_e.DI : reg_ids_e.BH);
        endcase
    end


endmodule