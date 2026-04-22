module num_pf_gen (
    input pf0, pf1, pf2,
    output [1:0] num_pfs
);

    pf_gen pf_gen0(.num_pfs_1_o(num_pfs[1]), .num_pfs_0_o(num_pfs[0]),
        .pf_2_i(pf2), .pf_1_i(pf1), .pf_0_i(pf0));
    
endmodule