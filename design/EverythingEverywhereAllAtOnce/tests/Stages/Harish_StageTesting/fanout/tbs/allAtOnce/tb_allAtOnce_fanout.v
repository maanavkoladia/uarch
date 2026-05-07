module tb_allAtOnce_fanout ;
    wire clk_i, rst_i;
 AllAtOnce_TOP uut_aaot(
    .clk(clk_i),
    .rst(rst_i)
);

endmodule
