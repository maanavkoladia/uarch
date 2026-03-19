package tb_mainMem_pkg;
    //10 ns
    localparam CLK_PERIOD = 10 

    task automatic DelayCLKs(
        input logic cycles
    );

        #(CLK_PERIOD * cycles);

    endtask
    
endpackage
