import common_pkg::*;
import contorl_store_pkg::*;

module df_flag_sel(
    input bool std_df,
    input bool curr_df_flag,
	input exe_cs_operation_type_e op_type,
    
    output bool df_flag_o
);

    assign df_flag_o = (op_type == STD) ? std_df : curr_df_flag;

endmodule

