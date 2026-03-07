module pf_vector_gen (
    input [1:0] pfs,
    input [9:0] pf_vector0, pf_vector1, pf_vector2,
    output [9:0] total_pf_vector
);

    wire [9:0] real_vector0, real_vector1, real_vector2;
    wire sel0, sel2;

    mux2_10 mux0(.in0(10'b0), .in1(pf_vector0), .sel(sel0), .out(real_vector0));
    mux2_10 mux1(.in0(10'b0), .in1(pf_vector1), .sel(pfs[1]), .out(real_vector1));
    mux2_10 mux2(.in0(10'b0), .in1(pf_vector2), .sel(sel2), .out(real_vector2));

    or2$ or0(sel0, pfs[0], pfs[1]);
    and2$ and0(sel2, pfs[0], pfs[1]);

    genvar i;
    generate
        for(i=0; i<10; i=i+1) begin
            or3$ orX(total_pf_vector[i], real_vector0[i], real_vector1[i], real_vector2[i]);
        end
    endgenerate

endmodule