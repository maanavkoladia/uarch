module br_info_processing (
    input bool cs_branch,
    input uint32_t eip,
    input logic [3:0] br_length,
    input bool pred_taken,
    input l_address_t pred_target,
    output br_info_t branch_output
);
    uint32_t branch_end;
    assign branch_end = eip + br_length - 1;

    assign branch_output = '{
        valid : cs_branch,
        br_eip : eip,
        br_xcl : (eip[8:4] == branch_end[8:4]) ? 1'b0 : 1'b1,
        br_pred_taken : pred_taken,
        sepculative_target : pred_target
    };
endmodule