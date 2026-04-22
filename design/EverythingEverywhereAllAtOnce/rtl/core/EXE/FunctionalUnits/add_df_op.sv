module add_df_op(
    input uint64_t srA,
    input uint64_t srB,
    input bool curr_df_flag,
    output uint64_t dr_o,
    output uint64_t sr_o
);
    assign dr_o = curr_df_flag ? srA+1 : srA-1;
    assign sr_o = curr_df_flag ? srB+1 : srB-1;


endmodule