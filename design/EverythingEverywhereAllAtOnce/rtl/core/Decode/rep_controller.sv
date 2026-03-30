module rep_controller (
    input wire clk, rst,
    input bool rep_prefix,
    input bool mov_inst,
    input bool cmp_inst,
    input bool clear_zf, set_zf,
    input uint32_t ecx,
    input bool ecx_sb,
    input bool zf_flag,
    input bool stall,
    input bool flush,
    output rr_latches_general_t rep_latches,
    output bool rep_register
);

    reg REP_IN_PROGRESS;
    assign rep_register = REP_IN_PROGRESS;

    bool continue_mov, continue_cmp;
    assign continue_mov = !ecx_sb && ecx != 32'b0;
    assign continue_cmp = continue_mov && (zf_sb.counter == 0) && !zf_flag;

    regsb_entry_t zf_sb;

    logic [2:0] inst_select;
    bool s0, s1, s2, s3, set_rep, clear_rep;
    rep_fsm fsm_rep(.clk(clk), .rst(rst), .cont_mov_i(continue_mov), .cont_cmp_i(continue_cmp), .rep_prefix_i(rep_prefix),
        .cs_mov_i(mov_inst), .cs_cmp_i(cmp_inst), .stall_i(stall),
        .S_0(s0), .S_1(s1), .S_2(s2), .S_3(s3), .set_rep_o(set_rep),
        .clear_rep_o(clear_rep), .select_line2_o(inst_select[2]),
        .select_line1_o(inst_select[1]), .select_line0_o(inst_select[0])
    );

    always_ff @(posedge clk) begin
        if(!rst) begin
            REP_IN_PROGRESS <= 1'b0;
        end
        else begin
            if(flush) REP_IN_PROGRESS <= 1'b0;
            else begin
                unique case ({set_rep, clear_rep})
                    2'b00: REP_IN_PROGRESS <= REP_IN_PROGRESS;
                    2'b01: REP_IN_PROGRESS <= 1'b0;
                    2'b10: REP_IN_PROGRESS <= 1'b1;
                    2'b11: REP_IN_PROGRESS <= REP_IN_PROGRESS;
                endcase
            end
        end
    end

    always_ff @(posedge clk) begin
        if(!rst) begin
            zf_sb <= '0;
        end
        else begin
            if(flush) zf_sb <= '0;
            else begin
                unique case ({set_zf, clear_zf})
                    2'b00: zf_sb <= zf_sb;
                    2'b01: zf_sb.counter <= (zf_sb.counter == 0) ? zf_sb.counter : zf_sb.counter - 1;
                    2'b10: zf_sb.counter <= (zf_sb == '1) ? zf_sb.counter : zf_sb.counter + 1;
                    2'b11: zf_sb <= zf_sb;
                endcase
            end
        end
    end


    rr_latches_general_t idle_output;
    rr_latches_general_t movs_edi_esi;  //mov0
    rr_latches_general_t decrement_ecx; //mov1
    rr_latches_general_t add_df_edi;    //mov2/cmp3
    rr_latches_general_t add_df_esi;    //mov3/cmp4
    rr_latches_general_t mov_etr;       //cmp0
    rr_latches_general_t add_etr;       //cmp1
    rr_latches_general_t add_nf;        //cmp2

    always_comb begin
        unique case (inst_select)
            3'b000: rep_latches = idle_output;
            3'b001: rep_latches = movs_edi_esi;
            3'b010: rep_latches = decrement_ecx;
            3'b011: rep_latches = add_df_edi;
            3'b100: rep_latches = add_df_esi;
            3'b101: rep_latches = mov_etr;
            3'b110: rep_latches = add_etr;
            3'b111: rep_latches = add_nf;
        endcase
    end



endmodule