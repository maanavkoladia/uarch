module tb_instance;
    reg clk = 0, rst;

    always begin
        #5;
        clk =  ~clk;
    end

     AllAtOnce_TOP uut (
        .clk(clk),
        .rst(rst)
    );

    initial begin
        rst = 0;
        #100;
        rst = 1;
    end
endmodule
