import reg_ids_pkg::*;
import core_stage_latches_pkg::*;
import control_store_pkg::*;

module modrm_processor (
    input byte_t modrm_byte,
    input logic [1:0] datasize,
    input decode_cs_t decode_cs_inputs,
    output modrm_processor_outs_t outputs
);
    reg_ids_e dr_id;
    reg_ids_e sr_id;
    bool dr_rd;
    bool sr_rd;
    bool dr_wr;
    bool sr_wr;
    bool ld_op_unmasked;
    bool st_op_unmasked;
    bool ld_op;
    bool st_op;
    bool rm_is_dr;
    bool reg_is_dr;
    bool reg_is_segment;
    bool alu_inputA_override;
    bool alu_inputB_override;
    bool dr_high8;
    bool sr_high8;
    source_selector_e alu_inputA_override_sel;
    source_selector_e alu_inputB_override_sel;

    assign rm_is_dr = (decode_cs_inputs.MODRM_NEEDED && decode_cs_inputs.RM_IS_DR && !decode_cs_inputs.REG_IS_DR);
    assign reg_is_dr = (decode_cs_inputs.MODRM_NEEDED && !decode_cs_inputs.RM_IS_DR && decode_cs_inputs.REG_IS_DR);
    assign reg_is_segment = (decode_cs_inputs.MODRM_NEEDED && decode_cs_inputs.REG_IS_SEGMENT);

    assign alu_inputA_override = rm_is_dr && (st_op || ld_op);
    assign alu_inputB_override = reg_is_dr && ld_op;

    assign alu_inputA_override_sel = BUFFER;
    assign alu_inputB_override_sel = BUFFER;


    always_comb begin
        dr_high8 = 1'b0;
        sr_high8 = 1'b0;
        //dr reg setting
        if(rm_is_dr && 
            ({modrm_byte[7:6], modrm_byte[2:0]} != 5'b00100) &&
            ({modrm_byte[7:6], modrm_byte[2:0]} != 5'b00101) &&
            ({modrm_byte[7:6], modrm_byte[2:0]} != 5'b01100) &&
            ({modrm_byte[7:6], modrm_byte[2:0]} != 5'b10100)) 
            begin
            case(modrm_byte[2:0])    //rm id
                3'd0: dr_id = (datasize[1] && datasize[0]) ? MM0 : EAX;
                3'd1: dr_id = (datasize[1] && datasize[0]) ? MM1 : ECX;
                3'd2: dr_id = (datasize[1] && datasize[0]) ? MM2 : EDX;
                3'd3: dr_id = (datasize[1] && datasize[0]) ? MM3 : EBX;
                3'd4: begin
                    dr_id = (datasize[1] && datasize[0]) ? MM4 : 
                            (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? EAX : ESP;
                    dr_high8 = (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? 1'b1 : 1'b0;
                end
                3'd5: begin
                    dr_id = (datasize[1] && datasize[0]) ? MM5 : 
                            (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? ECX : EBP;
                    dr_high8 = (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? 1'b1 : 1'b0;
                end
                3'd6: begin
                    dr_id = (datasize[1] && datasize[0]) ? MM6 : 
                            (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? EDX : ESI;
                    dr_high8 = (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? 1'b1 : 1'b0;
                end
                3'd7: begin
                    dr_id = (datasize[1] && datasize[0]) ? MM7 :
                            (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? EBX : EDI;
                    dr_high8 = (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? 1'b1 : 1'b0;
                end
            endcase
            dr_rd = 1'b1;
            dr_wr = (modrm_byte[7:6] == 2'b11) ? 1'b1 : 1'b0;
        end
        else if(reg_is_dr && !reg_is_segment) begin
            case(modrm_byte[5:3])    //reg id
                3'd0: dr_id = (datasize[1] && datasize[0]) ? MM0 : EAX;
                3'd1: dr_id = (datasize[1] && datasize[0]) ? MM1 : ECX;
                3'd2: dr_id = (datasize[1] && datasize[0]) ? MM2 : EDX;
                3'd3: dr_id = (datasize[1] && datasize[0]) ? MM3 : EBX;
                3'd4: begin
                    dr_id = (datasize[1] && datasize[0]) ? MM4 : 
                            (!datasize[1] && !datasize[0]) ? EAX : ESP;
                    dr_high8 = (!datasize[1] && !datasize[0]) ? 1'b1 : 1'b0;
                end
                3'd5: begin
                    dr_id = (datasize[1] && datasize[0]) ? MM5 : 
                            (!datasize[1] && !datasize[0]) ? ECX : EBP;
                    dr_high8 = (!datasize[1] && !datasize[0]) ? 1'b1 : 1'b0;
                end
                3'd6: begin
                    dr_id = (datasize[1] && datasize[0]) ? MM6 : 
                            (!datasize[1] && !datasize[0]) ? EDX : ESI;
                    dr_high8 = (!datasize[1] && !datasize[0]) ? 1'b1 : 1'b0;
                end
                3'd7: begin
                    dr_id = (datasize[1] && datasize[0]) ? MM7 :
                            (!datasize[1] && !datasize[0]) ? EBX : EDI;
                    dr_high8 = (!datasize[1] && !datasize[0]) ? 1'b1 : 1'b0;
                end
            endcase
            dr_rd = 1'b1;
            dr_wr = 1'b1;
        end
        else if(reg_is_segment && reg_is_dr) begin
            case(modrm_byte[5:3])    //seg orders, given by chat, idk if i trust
                3'd0: dr_id = ES;
                3'd1: dr_id = CS;
                3'd2: dr_id = SS;
                3'd3: dr_id = DS;
                3'd4: dr_id = FS;
                3'd5: dr_id = GS;
                3'd6: dr_id = NO_REG;
                3'd7: dr_id = NO_REG;
            endcase
            dr_rd = 1'b1;
            dr_wr = 1'b1;
        end
        else if(!decode_cs_inputs.MODRM_NEEDED && decode_cs_inputs.HARDCODED_DR) begin
            dr_id = decode_cs_inputs.HARDCODED_DR_ID;
            dr_rd = decode_cs_inputs.HARDCODED_DR_RD;
            //gonna assume for now that if youre reading this reg then youre gonna write back to it since this is dr
            //actually not true for fuck ass movs case, but gonna mux outside of here cause fuck that instruction
            //actually still not true even outside of movs case, what other case? you guessed it, mov. fuck ass instruction
            dr_wr = decode_cs_inputs.HARDCODED_DR_WR;
        end
        else begin
            dr_id = NO_REG;
            dr_rd = 1'b0;
            dr_wr = 1'b0;
        end


        //sr reg setting
        if(rm_is_dr && !reg_is_segment) begin
            case(modrm_byte[5:3])    //rm id
                3'd0: sr_id = (datasize[1] && datasize[0]) ? MM0 : EAX;
                3'd1: sr_id = (datasize[1] && datasize[0]) ? MM1 : ECX;
                3'd2: sr_id = (datasize[1] && datasize[0]) ? MM2 : EDX;
                3'd3: sr_id = (datasize[1] && datasize[0]) ? MM3 : EBX;
                3'd4: begin
                    sr_id = (datasize[1] && datasize[0]) ? MM4 : 
                            (!datasize[1] && !datasize[0]) ? EAX : ESP;
                    sr_high8 = (!datasize[1] && !datasize[0]) ? 1'b1 : 1'b0;
                end
                3'd5: begin
                    sr_id = (datasize[1] && datasize[0]) ? MM5 : 
                            (!datasize[1] && !datasize[0]) ? ECX : EBP;
                    sr_high8 = (!datasize[1] && !datasize[0]) ? 1'b1 : 1'b0;
                end
                3'd6: begin
                    sr_id = (datasize[1] && datasize[0]) ? MM6 : 
                            (!datasize[1] && !datasize[0]) ? EDX : ESI;
                    sr_high8 = (!datasize[1] && !datasize[0]) ? 1'b1 : 1'b0;
                end
                3'd7: begin
                    sr_id = (datasize[1] && datasize[0]) ? MM7 :
                            (!datasize[1] && !datasize[0]) ? EBX : EDI;
                    sr_high8 = (!datasize[1] && !datasize[0]) ? 1'b1 : 1'b0;
                end
            endcase
            sr_rd = 1'b1;
            sr_wr = 1'b0;
        end
        else if(reg_is_dr &&
            ({modrm_byte[7:6], modrm_byte[2:0]} != 5'b00100) &&
            ({modrm_byte[7:6], modrm_byte[2:0]} != 5'b00101) &&
            ({modrm_byte[7:6], modrm_byte[2:0]} != 5'b01100) &&
            ({modrm_byte[7:6], modrm_byte[2:0]} != 5'b10100)) begin
            case(modrm_byte[2:0])    //reg id
                3'd0: sr_id = (datasize[1] && datasize[0]) ? MM0 : EAX;
                3'd1: sr_id = (datasize[1] && datasize[0]) ? MM1 : ECX;
                3'd2: sr_id = (datasize[1] && datasize[0]) ? MM2 : EDX;
                3'd3: sr_id = (datasize[1] && datasize[0]) ? MM3 : EBX;
                3'd4: begin
                    sr_id = (datasize[1] && datasize[0]) ? MM4 : 
                            (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? EAX : ESP;
                    sr_high8 = (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? 1'b1 : 1'b0;
                end
                3'd5: begin
                    sr_id = (datasize[1] && datasize[0]) ? MM5 : 
                            (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? ECX : EBP;
                   sr_high8 = (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? 1'b1 : 1'b0;
                end
                3'd6: begin
                    sr_id = (datasize[1] && datasize[0]) ? MM6 : 
                            (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? EDX : ESI;
                    sr_high8 = (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? 1'b1 : 1'b0;
                end
                3'd7: begin
                    sr_id = (datasize[1] && datasize[0]) ? MM7 :
                            (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? EBX : EDI;
                    sr_high8 = (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? 1'b1 : 1'b0;
                end
            endcase
            sr_rd = 1'b1;
            sr_wr = 1'b0;
        end
        else if(reg_is_segment && rm_is_dr) begin
            case(modrm_byte[5:3])    //seg orders, given by chat, idk if i trust
                3'd0: sr_id = ES;
                3'd1: sr_id = CS;
                3'd2: sr_id = SS;
                3'd3: sr_id = DS;
                3'd4: sr_id = FS;
                3'd5: sr_id = GS;
                3'd6: sr_id = NO_REG;
                3'd7: sr_id = NO_REG;
            endcase
            sr_rd = 1'b1;
            sr_wr = 1'b0;
        end
        else if(!decode_cs_inputs.MODRM_NEEDED && decode_cs_inputs.HARDCODED_SR) begin
            sr_id = decode_cs_inputs.HARDCODED_SR_ID;
            sr_rd = decode_cs_inputs.HARDCODED_SR_RD;
            sr_wr = decode_cs_inputs.HARDCODED_SR_WR;
        end
        else begin
            sr_id = NO_REG;
            sr_rd = 1'b0;
            sr_wr = 1'b0;
        end


        //st/ld op setting
        ld_op_unmasked = ((modrm_byte[7:6] != 2'b11) && decode_cs_inputs.MODRM_NEEDED) || decode_cs_inputs.HARDCODED_LD_OP;
        st_op_unmasked = (rm_is_dr && (modrm_byte[7:6] != 2'b11)) || decode_cs_inputs.HARDCODED_ST_OP;

        ld_op = ld_op_unmasked && !decode_cs_inputs.LD_OP_CANCEL;
        st_op = st_op_unmasked && !decode_cs_inputs.ST_OP_CANCEL;
    end


    assign outputs = '{
        dr_id   : dr_id,
        sr_id   : sr_id,
        dr_rd   : dr_rd,
        sr_rd   : sr_rd,
        dr_wr   : dr_wr,
        sr_wr   : sr_wr,
        st_op   : st_op,
        ld_op   : ld_op,
        dr_high8   : dr_high8,
        sr_high8   : sr_high8,
        alu_inputA_override : alu_inputA_override,
        alu_inputB_override : alu_inputB_override,
        alu_inputA_override_sel : alu_inputA_override_sel,
        alu_inputB_override_sel : alu_inputB_override_sel
    };


endmodule