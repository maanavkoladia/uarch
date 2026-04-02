import reg_ids_pkg::*;
import core_stage_latches_pkg::*;
module modrm_processor (
    input byte_t modrm_byte,
    input logic [2:0] datasize,
    input decode_cs_t decode_cs_inputs,
    output modrm_processor_outs_t outputs
);
    reg_ids_e dr_id;
    reg_ids_e sr_id;
    bool dr_rd;
    bool sr_rd;
    bool dr_wr;
    bool sr_wr;
    bool ld_op;
    bool st_op;
    bool rm_reg_is_dr;
    bool reg_is_dr;

    assign rm_is_dr = (decode_cs_inputs.MODRM_NEEDED && decode_cs_inputs.RM_IS_DR && !decode_cs_inputs.REG_IS_DR);
    assign reg_is_dr = (decode_cs_inputs.MODRM_NEEDED && !decode_cs_inputs.RM_IS_DR && decode_cs_inputs.REG_IS_DR);

    always_comb begin
        //dr reg setting
        if(decode_cs_inputs.MODRM_NEEDED && decode_cs_inputs.RM_IS_DR && !decode_cs_inputs.REG_IS_DR) begin
            unique case(modrm_byte[2:0])    //rm id
                3'd0: dr_id = (datasize[1] && datasize[0]) ? MM0 : EAX;
                3'd1: dr_id = (datasize[1] && datasize[0]) ? MM1 : ECX;
                3'd2: dr_id = (datasize[1] && datasize[0]) ? MM2 : EDX;
                3'd3: dr_id = (datasize[1] && datasize[0]) ? MM3 : EBX;
                3'd4: dr_id = (datasize[1] && datasize[0]) ? MM4 : ESP;
                3'd5: dr_id = (datasize[1] && datasize[0]) ? MM5 : EBP;
                3'd6: dr_id = (datasize[1] && datasize[0]) ? MM6 : ESI;
                3'd7: dr_id = (datasize[1] && datasize[0]) ? MM7 : EDI;
            endcase
        end
        else if(decode_cs_inputs.MODRM_NEEDED && !decode_cs_inputs.RM_IS_DR && decode_cs_inputs.REG_IS_DR) begin
            unique case(modrm_byte[5:3])    //reg id
                3'd0: dr_id = (datasize[1] && datasize[0]) ? MM0 : EAX;
                3'd1: dr_id = (datasize[1] && datasize[0]) ? MM1 : ECX;
                3'd2: dr_id = (datasize[1] && datasize[0]) ? MM2 : EDX;
                3'd3: dr_id = (datasize[1] && datasize[0]) ? MM3 : EBX;
                3'd4: dr_id = (datasize[1] && datasize[0]) ? MM4 : ESP;
                3'd5: dr_id = (datasize[1] && datasize[0]) ? MM5 : EBP;
                3'd6: dr_id = (datasize[1] && datasize[0]) ? MM6 : ESI;
                3'd7: dr_id = (datasize[1] && datasize[0]) ? MM7 : EDI;
            endcase
        end
        else if(!decode_cs_inputs.MODRM_NEEDED && decode_cs_inputs.HARDCODED_DR) begin
            dr_id = decode_cs_inputs.HARDCODED_DR_ID;
        end
        else dr_id = ERROR_REG;

        dr_rd = 1'b1;
        dr_wr = (reg_is_dr) || (rm_is_dr && modrm_byte[7:6] == 2'b11);


        //sr reg setting
        if(rm_is_dr) begin
            unique case(modrm_byte[2:0])    //rm id
                3'd0: sr_id = (datasize[1] && datasize[0]) ? MM0 : EAX;
                3'd1: sr_id = (datasize[1] && datasize[0]) ? MM1 : ECX;
                3'd2: sr_id = (datasize[1] && datasize[0]) ? MM2 : EDX;
                3'd3: sr_id = (datasize[1] && datasize[0]) ? MM3 : EBX;
                3'd4: sr_id = (datasize[1] && datasize[0]) ? MM4 : ESP;
                3'd5: sr_id = (datasize[1] && datasize[0]) ? MM5 : EBP;
                3'd6: sr_id = (datasize[1] && datasize[0]) ? MM6 : ESI;
                3'd7: sr_id = (datasize[1] && datasize[0]) ? MM7 : EDI;
            endcase
        end
        else if(reg_is_dr) begin
            unique case(modrm_byte[5:3])    //reg id
                3'd0: sr_id = (datasize[1] && datasize[0]) ? MM0 : EAX;
                3'd1: sr_id = (datasize[1] && datasize[0]) ? MM1 : ECX;
                3'd2: sr_id = (datasize[1] && datasize[0]) ? MM2 : EDX;
                3'd3: sr_id = (datasize[1] && datasize[0]) ? MM3 : EBX;
                3'd4: sr_id = (datasize[1] && datasize[0]) ? MM4 : ESP;
                3'd5: sr_id = (datasize[1] && datasize[0]) ? MM5 : EBP;
                3'd6: sr_id = (datasize[1] && datasize[0]) ? MM6 : ESI;
                3'd7: sr_id = (datasize[1] && datasize[0]) ? MM7 : EDI;
            endcase
        end
        else if(!decode_cs_inputs.MODRM_NEEDED && decode_cs_inputs.HARDCODED_SR) begin
            sr_id = decode_cs_inputs.HARDCODED_SR_ID;
        end
        else sr_id = ERROR_REG;
        sr_rd = 1'b1;
        sr_wr = 1'b0;


        //st/ld op setting
        ld_op = modrm_byte[7:6] != 2'b11;
        st_op = (rm_is_dr && (modrm_byte[7:6] != 2'b11));
    end


    assign outputs = '{
        dr_id   : dr_id,
        sr_id   : sr_id,
        dr_rd   : dr_rd,
        sr_rd   : sr_rd,
        dr_wr   : dr_wr,
        sr_wr   : sr_wr,
        st_op   : st_op,
        ld_op   : ld_op
    };


endmodule