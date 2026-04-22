module pf_checker (
    input [7:0] IRbyte,
    output pf, 
    output [9:0] pf_vector
);
    wire [9:0] a_greater, b_greater;
    wire oroutput0, oroutput1, oroutput2;


    //MSB --> 2e, 36, 3e, 26, 64, 65, 66, 67, 0f, f3  <-- LSB vector

    mag_comp8$ comp9(IRbyte, 8'h2E, a_greater[9], b_greater[9]);
    mag_comp8$ comp8(IRbyte, 8'h36, a_greater[8], b_greater[8]);
    mag_comp8$ comp7(IRbyte, 8'h3E, a_greater[7], b_greater[7]);
    mag_comp8$ comp6(IRbyte, 8'h26, a_greater[6], b_greater[6]);
    mag_comp8$ comp5(IRbyte, 8'h64, a_greater[5], b_greater[5]);
    mag_comp8$ comp4(IRbyte, 8'h65, a_greater[4], b_greater[4]);
    mag_comp8$ comp3(IRbyte, 8'h66, a_greater[3], b_greater[3]);
    mag_comp8$ comp2(IRbyte, 8'h67, a_greater[2], b_greater[2]);
    mag_comp8$ comp1(IRbyte, 8'h0F, a_greater[1], b_greater[1]);
    mag_comp8$ comp0(IRbyte, 8'hF3, a_greater[0], b_greater[0]);


    genvar i;
    generate 
        for(i=0; i<10; i=i+1) begin : g_harish_name_this_2
            nor2$ norX(pf_vector[i], a_greater[i], b_greater[i]);
        end
    endgenerate

    or4$ or0(oroutput0, pf_vector[0], pf_vector[1], pf_vector[2], pf_vector[3]);
    or4$ or1(oroutput1, pf_vector[4], pf_vector[5], pf_vector[6], pf_vector[7]);
    or2$ or2(oroutput2, pf_vector[8], pf_vector[9]);
    or3$ or3(pf, oroutput0, oroutput1, oroutput2);




    
endmodule
