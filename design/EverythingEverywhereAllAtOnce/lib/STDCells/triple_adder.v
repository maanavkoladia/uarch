module triple_adder (
    input [2:0] pfs_plus_one, msd_size, imm_size,
    output [3:0] result
);
    wire [3:0] first_result;
    wire cout;
    kogge_stone_adder #(.WIDTH(3)) triple_in_adder0 (
        .a(pfs_plus_one),
        .b(imm_size),
        .cin(1'b0),
        .sum(first_result[2:0]),
        .cout(first_result[3])
    );

    kogge_stone_adder #(.WIDTH(4)) triple_in_adder1 (
        .a(first_result),
        .b({1'b0, msd_size}),
        .cin(1'b0),
        .sum(result),
        .cout(cout)
    );
    
endmodule
