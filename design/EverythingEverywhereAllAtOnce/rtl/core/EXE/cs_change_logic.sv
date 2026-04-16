module cs_change_logic(
    input exe_cs_operation_type_e op_type,
    input bool curr_cf_flag,
    input bool cs_st_op,
    output bool st_op_o

);

    always_comb begin
        st_op_o = cs_st_op;
        if(op_type == CMOVC)begin
            st_op_o = curr_cf_flag ? 1 : 0;
        end
    end


endmodule