import common_pkg::*;
import contorl_store_pkg::*;

module df_flag_sel(
    input bool curr_df_flag,
	input exe_cs_operation_type_e op_type,
    
    output bool df_flag_o
);

    bool next_df_flag;
    always_comb begin
        next_df_flag = curr_df_flag;
        if(op_type == STD)
            next_df_flag = 1;
        if(op_type == CLD)
            next_df_flag = 0;
    end

    assign df_flag_o = next_df_flag;

endmodule

