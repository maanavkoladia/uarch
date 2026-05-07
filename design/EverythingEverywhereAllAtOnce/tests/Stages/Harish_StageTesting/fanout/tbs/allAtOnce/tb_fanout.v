module tb_fanout ;
    wire clk_i, rst_i;
 AllAtOnce_TOP uut_aao(
    .clk(clk_i),
    .rst(rst_i)
);

endmodule
