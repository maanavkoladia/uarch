module br_info_processing (
    input wire cs_branch,
    input wire [31:0] eip,
    input wire [3:0] br_length,
    input wire pred_taken,
    input wire [31:0] pred_target,
    output wire branch_info_valid,
    output wire [31:0] branch_info_br_eip,
    output wire branch_info_br_xcl,
    output wire branch_info_br_pred_taken,
    output wire branch_info_speculative_target
);
    wire [31:0] branch_end;
    wire [3:0] decremented_br_length;
    wire adder_cout, adder_cout1;
    
    `ADD_N(decrementer_adder, 4, decremented_br_length, adder_cout, br_length, 4'hF, 1'b0)
    `ADD_N(branch_end_adder, 32, branch_end, adder_cout1, eip, {28'd0, decremented_br_length}, 1'b0)

    wire eip_equals_br_end;
    `CMP_N(eip_br_end_comp, 5, eip_equals_br_end, eip[8:4], branch_end[8:4])

    wire br_xcl;
    `MUX_2(br_xcl_mux, 1, br_xcl, 1'b1, 1'b0, eip_equals_br_end) 

    assign branch_info_valid = cs_branch;
    assign branch_info_br_eip = eip;
    assign branch_info_br_xcl = br_xcl;
    assign branch_info_br_pred_taken = pred_taken;
    assign branch_info_speculative_target = pred_target;

endmodule
