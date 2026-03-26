import common_pkg::*;
import interconnect_pkg::*;
import BusArbitration_common_pkg::*;

module DTE (
    input wire clk_i,
    input wire rst_i,  //active low


    //input bus_transaction_e req_i,
    input reqs_pri_t bestPick_i,
    input logic [$clog2(NUM_DCACHE_PORTS) - 1 : 0] bestPick_bk_id_i,

    //perms, and memvalids
    output dte_2_icache_t dte_out_2_icache_o,

    //perms for each bank, and memvalid
    output dte_2_dcache_t dte_out_2_dcache_o,

    //memready
    input mem_2_dte_t mem_2_dte_i,

    //perms, ld reg etc
    output dte_2_mem_t dte_2_mem_o,

    //perms, and clearing write buf v bit, and singal reg values
    output dte_2_dma_controller_t dte_2_dma_o,

    //perms to drive bus for read, and signaling that data on bus is for you,
    //writeable read values
    output dte_2_ddr5_t dte_2_ddr5_i

);

    //needs to run the fsm, there really shouldnt be anyhting else here



endmodule
