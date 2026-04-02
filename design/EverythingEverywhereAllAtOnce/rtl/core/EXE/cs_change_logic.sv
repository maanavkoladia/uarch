module cs_change_logic(
    input exe_cs_operation_type_e op_type,
    input bool cancel_dr_we,
    input bool cancel_sr_we,
    input bool cancel_store,
    
    input bool curr_cf_flag,

    input bool cs_wb_dr,
    input bool cs_wb_sr,
    input bool cs_st_op,

    output bool wb_dr_o,
    output bool wb_sr_o,
    output bool st_op_o
);

    always_comb begin
        if(op_type == CMPXCHG)begin
            wb_dr_o = cancel_dr_we ? 0 : cs_wb_dr;
            wb_sr_o = cancel_sr_we ? 0 : cs_wb_sr;
            st_op_o = cancel_store ? 0 : cs_st_op;
        end
        if(op_type == CMOVC)begin
            st_op_o = curr_cf_flag ? 1 : 0;
        end
    end


endmodule