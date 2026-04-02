import core_stage_latches_pkg::*;
import core_common_pkg::*;
import control_store_pkg::*;

module tb_exe();

    logic clk;
    logic rst;
    exe_latches_t exe_latches;
    wb_outputs_t wb_outs;

    
    EXE uut_exe(
        .clk(clk),
        .rst(rst),
        .latches_i(exe_latches),
        .wb_outs_i(wb_outs),
        .wb_latches_next_o(),
        .outs_o()
    );

   initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        exe_latches = '{default: '0};
        wb_outs = '{default: '0};


    end




endmodule