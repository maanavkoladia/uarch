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

    wire [31:0] branch_end [0:15];
    wire        branch_end_cout [0:15];
    wire [3:0]  offset [0:15];
    wire        offset_cout [0:15];
    wire        eip_equals_br_end [0:15];
    wire        br_xcl [0:15];

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : br_end_loop_g
            // First adder: compute i - 1 (i.e., i + 4'hF, no carry-in)
            `ADD_N(decrementer_adder, 4, offset[i], offset_cout[i], 4'(i), 4'hF, 1'b0)
            // Second adder: branch_end[i] = eip + (i - 1)
            `ADD_N(branch_end_adder, 32, branch_end[i], branch_end_cout[i], eip, {28'd0, offset[i]}, 1'b0)
            // Compare relevant bits of eip against this branch end
            `CMP_N(eip_br_end_comp, 5, eip_equals_br_end[i], eip[8:4], branch_end[i][8:4])
            // br_xcl[i] is 1 when eip matches this branch end, 0 otherwise
            `MUX_2(br_xcl_mux, 1, br_xcl[i], 1'b1, 1'b0, eip_equals_br_end[i])
        end
    endgenerate

    // Mux the 16 br_xcl results using br_length as select
    wire selected_br_xcl;
    `MUX_16(br_xcl_mux, 1, selected_br_xcl,
        br_xcl[0],  br_xcl[1],  br_xcl[2],  br_xcl[3],
        br_xcl[4],  br_xcl[5],  br_xcl[6],  br_xcl[7],
        br_xcl[8],  br_xcl[9],  br_xcl[10], br_xcl[11],
        br_xcl[12], br_xcl[13], br_xcl[14], br_xcl[15],
        br_length)

    assign branch_info_valid              = cs_branch;
    assign branch_info_br_eip             = eip;
    assign branch_info_br_xcl             = selected_br_xcl;
    assign branch_info_br_pred_taken      = pred_taken;
    assign branch_info_speculative_target = pred_target;

endmodule