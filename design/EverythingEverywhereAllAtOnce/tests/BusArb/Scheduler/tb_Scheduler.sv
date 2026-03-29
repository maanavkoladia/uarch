import interconnect_pkg::*;
import common_pkg::*;

module tb_Scheduler ();

    localparam int Clk_PERIOD = 10;

    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    // ================= CLOCK / RESET =================
    `CLK_INIT(Clk_PERIOD);
    logic                                                            rst;

    // ================= ICACHE =================
    icache_2_scheduler_t                                             icache_2_sched;

    // ================= DCACHE =================
    dcache_2_scheduler_t                                             dcache_2_sched;

    // ================= MEMORY =================
    mem_2_scheduler_t                                                mem_2_sched;

    // ================= DMA =================
    dma_controller_2_scheduler_t                                     dma_2_sched;


    //===================sch pick signals
    req_2_sch_t                                                      bestPick_req;
    logic                        [$clog2(NNUM_DCACHE_PORTS) - 1 : 0] bestPick_bk_i;


    task automatic DelayClks(input int cycles);
        #(Clk_PERIOD * cycles);
    endtask

    module Scheduler (
        .clk(clk),
        .rst(rst),  //active low
        .iCache_2_Sch_i(icache_2_sched),
        .dCache_2_Sch_i(dcache_2_sched),
        .mem_2_Sch_i(mem_2_sched),
        .dma_2_sch_i(dma_2_sched),
        .bestPick_o(bestPick_req),
        .bestPick_bk_id_o(bestPick_bk_i)
    );

    initial begin
        `LOG("Starting mem System TB");
        rst = 0;  //active low
        icache_2_sched = '{default: '0};//for lds from mem
        dcache_2_sched = '{default: '0};//for ld and store to mem and io
        mem_2_sched = '{default: '0};//write buf status
        dma_2_sched = '{default: '0};//write to mem, giev write addr for comparisions

        DelayClks(5);
        rst = 1;

        // let it idle for a bit, shoudl countinues to rx no_reqs from
        // sceduler
        DelayClks(20);
        //now give it a pick ...
        //need to test all the picks and getting new picks while one fsm is
        //running to enure that another dte fsm doesnt startup
        /////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
        /////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////////////////
        DelayClks(30);
        $finish;
        `LOG("Finishing mem System TB");
    end
endmodule
