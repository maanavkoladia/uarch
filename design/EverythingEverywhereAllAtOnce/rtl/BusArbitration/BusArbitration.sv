import common_pkg::*;
import interconnect_pkg::*;
import BusArbitration_common_pkg::*;

module BusArbitration (
    input wire clk,
    input wire rst,

    //icache
    input icache_2_scheduler_t iCache_2_Sch_i,
    output dte_2_icache_t dte_out_2_icache_o,

    //dcache
    input dcache_2_scheduler_t dCache_2_Sch_i,
    output dte_2_dcache_t dte_out_2_dcache_o,
    //mem

    input mem_2_scheduler_t mem_2_Sch_i,
    input mem_2_dte_t mem_2_dte_i,
    output dte_2_mem_t dte_2_mem_o,

    //dma
    input dma_controller_2_scheduler_t dma_2_sch_i,
    output dte_2_dma_controller_t dte_2_dma_o,

    //ddr5
    output dte_2_ddr5_t dte_2_ddr5_o
);

    //create the sch
    req_2_sch_t sch_best_pick;
    logic [$clog(NUM_DCACHE_PORTS) - 1 : 0] sch_best_pick_bk_id;

    Scheduler scheduler_unit (
        .clk(clk),
        .rst(rst),  //active low
        .iCache_2_Sch_i(iCache_2_Sch_i),
        .dCache_2_Sch_i(dCache_2_Sch_i),
        .mem_2_Sch_i(mem_2_Sch_i),
        .dma_2_sch_i(dma_2_sch_i),
        .bestPick_o(sch_best_pick),
        .bestPick_bk_id_o(sch_best_pick_bk_id)
    );

    DTE dte_unit (
        .clk(clk),
        .rst(rst),
        .bestPick_i(sch_best_pick),
        .bestPick_bk_id_i(sch_best_pick_bk_id),
        .dte_out_2_icache_o(dte_out_2_icache_o),
        .dte_out_2_dcache_o(dte_out_2_dcache_o),
        .mem_2_dte_i(mem_2_dte_i),
        .dte_2_mem_o(dte_2_mem_o),
        .dte_2_dma_o(dte_2_dma_o),
        .dte_2_ddr5_o(dte_2_ddr5_o)
    );

    //create the dte
endmodule

