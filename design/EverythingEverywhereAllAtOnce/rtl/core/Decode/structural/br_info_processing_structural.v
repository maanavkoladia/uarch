// module br_info_processing (
//     input wire cs_branch,
//     input wire [31:0] eip,
//     input wire [31:0] neip,
//     input wire pred_taken,
//     input wire [31:0] pred_target,
//     output wire branch_info_valid,
//     output wire [31:0] branch_info_br_eip,
//     output wire branch_info_br_xcl,
//     output wire branch_info_br_pred_taken,
//     output wire [31:0] branch_info_speculative_target
// );
//     // wire neip_eip_b4_xor;
//     // wire neip_low_nz;
//     // wire br_xcl;

//     // `XOR_2(u_neip_eip_b4_xor, 1, neip_eip_b4_xor, neip[4], eip[4])
//     // `OR_4(u_neip_low_nz, 1, neip_low_nz, neip[0], neip[1], neip[2], neip[3])
//     // `AND_2(u_br_xcl, 1, br_xcl, neip_eip_b4_xor, neip_low_nz)

//     assign branch_info_valid = cs_branch;
//     assign branch_info_br_eip = eip;
//     assign branch_info_br_xcl = br_xcl;
//     assign branch_info_br_pred_taken = pred_taken;
//     assign branch_info_speculative_target = pred_target;

// endmodule

module br_info_processing (
    input wire cs_branch,
    input wire [31:0] eip,
    //input wire [3:0] br_length,
    input wire [31:0] neip,
    input wire pred_taken,
    input wire [31:0] pred_target,
    output wire branch_info_valid,
    output wire [31:0] branch_info_br_eip,
    output wire branch_info_br_xcl,
    output wire branch_info_br_pred_taken,
    output wire [31:0] branch_info_speculative_target
);
    // wire [31:0] branch_end;
    // wire [3:0] decremented_br_length;
    // wire adder_cout, adder_cout1;
    
    // `ADD_N(decrementer_adder, 4, decremented_br_length, adder_cout, br_length, 4'hF, 1'b0)
    // `ADD_N(branch_end_adder, 32, branch_end, adder_cout1, eip, {28'd0, decremented_br_length}, 1'b0)

    // wire eip_equals_br_end;
    // `CMP_N(eip_br_end_comp, 5, eip_equals_br_end, eip[5:4], branch_end[5:4])

    // wire br_xcl;
    // `MUX_2(br_xcl_mux, 1, br_xcl, 1'b1, 1'b0, eip_equals_br_end) 
    
    wire br_xcl;

    wire might_be_xcl;
    wire neip_alinged, neip_not_alinged;
    `XOR_2 (u_br_xcl_maybe, 1, might_be_xcl, eip[4], neip[4])
    `CMP_N (u_neip_zero,    4, neip_aligned, neip[3:0], 4'b0000)
    `INV_N (u_inv_neip_aligned, 1, neip_aligned, neip_not_aligned)
    `AND_2 (u_br_sel,       1, br_xcl, might_be_xcl, neip_not_aligned)

    assign branch_info_valid = cs_branch;
    assign branch_info_br_eip = eip;
    assign branch_info_br_xcl = br_xcl;
    assign branch_info_br_pred_taken = pred_taken;
    assign branch_info_speculative_target = pred_target;

endmodule

