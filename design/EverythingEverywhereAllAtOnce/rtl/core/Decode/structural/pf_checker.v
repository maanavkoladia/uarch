module pf_checker (
    input [7:0] IRbyte,
    output pf, 
    output [9:0] pf_vector
);

    //MSB --> 2e, 36, 3e, 26, 64, 65, 66, 67, 0f, f3  <-- LSB vector

    wire oroutput0, oroutput1, oroutput2;

    // Equality comparisons
    `CMP_N(cmp9, 9, pf_vector[9], {1'b0, IRbyte}, 9'h02E)
    `CMP_N(cmp8, 9, pf_vector[8], {1'b0, IRbyte}, 9'h036)
    `CMP_N(cmp7, 9, pf_vector[7], {1'b0, IRbyte}, 9'h03E)
    `CMP_N(cmp6, 9, pf_vector[6], {1'b0, IRbyte}, 9'h026)
    `CMP_N(cmp5, 9, pf_vector[5], {1'b0, IRbyte}, 9'h064)
    `CMP_N(cmp4, 9, pf_vector[4], {1'b0, IRbyte}, 9'h065)
    `CMP_N(cmp3, 9, pf_vector[3], {1'b0, IRbyte}, 9'h066)
    `CMP_N(cmp2, 9, pf_vector[2], {1'b0, IRbyte}, 9'h067)
    `CMP_N(cmp1, 9, pf_vector[1], {1'b0, IRbyte}, 9'h00F)
    `CMP_N(cmp0, 9, pf_vector[0], {1'b0, IRbyte}, 9'h0F3)

    // OR reduction tree
    `OR_4(or0_inst, 1, oroutput0,
        pf_vector[0], pf_vector[1], pf_vector[2], pf_vector[3])

    `OR_4(or1_inst, 1, oroutput1,
        pf_vector[4], pf_vector[5], pf_vector[6], pf_vector[7])

    `OR_2(or2_inst, 1, oroutput2,
        pf_vector[8], pf_vector[9])

    `OR_3(or3_inst, 1, pf,
        oroutput0, oroutput1, oroutput2)
    
endmodule
