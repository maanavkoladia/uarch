module triple_adder (
    input [2:0] in0, in1, in2,
    output [3:0] result
);
    wire [3:0] first_result;
    wire cout;
    kogge_stone_adder #(.WIDTH(3)) triple_in_adder0 (
        .a(in0),
        .b(in1),
        .cin(1'b0),
        .sum(first_result[2:0]),
        .cout(first_result[3])
    );

    kogge_stone_adder #(.WIDTH(4)) triple_in_adder1 (
        .a(first_result),
        .b({1'b0, in2}),
        .cin(1'b0),
        .sum(result),
        .cout(cout)
    );
    
endmodule
