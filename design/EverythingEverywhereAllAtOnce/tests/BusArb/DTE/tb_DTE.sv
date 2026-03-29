import interconnect_pkg::*;
import common_pkg::*;

module tb_memSystem ();
    localparam int Clk_PERIOD = 10;

    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    // ================= CLOCK / RESET =================
    `CLK_INIT(Clk_PERIOD);
    logic                                                       rst;

    // ================= ICACHE =================
    dte_2_icache_t                                              dte_2_icache;

    core_2_icache_t                                             core_2_icache;
    icache_2_core_t                                             icache_2_core;

    // ================= DCACHE =================
    dte_2_dcache_t                                              dte_2_dcache;

    core_2_dcache_t                                             core_2_dcache;
    dcache_2_core_t                                             dcache_2_core;

    // ================= MEMORY =================
    mem_2_dte_t                                                 mem_2_dte;
    dte_2_mem_t                                                 dte_2_mem;

    // ================= DMA =================
    dte_2_dma_controller_t                                      dte_2_dma;
    dma_controller_2_core_t                                     dma_2_core;

    // ================= DDR5 =================
    dte_2_ddr5_t                                                dte_2_ddr5;

    //sch pick signals
    req_2_sch_t                                                 bestPick_req_2_dte;
    logic                   [$clog2(NNUM_DCACHE_PORTS) - 1 : 0] bestPick_bk_id_2_dte;


    task automatic DelayClks(input int cycles);
        #(Clk_PERIOD * cycles);
    endtask

    DTE uut_DTE (
        .clk(clk),
        .rst(rst),
        .bestPick_i(req_2_dte),
        .bestPick_bk_id_i(req_hit_bk_id_2_dte),
        .dte_out_2_icache_o(dte_2_icache),
        .dte_out_2_dcache_o(dte_2_dcache),
        .mem_2_dte_i(mem_2_dte),
        .dte_2_mem_o(dte_2_mem),
        .dte_2_dma_o(dte_2_dma),
        .dte_2_ddr5_o(dte_2_ddr5)
    );

    initial begin
        `LOG("Starting mem System TB");
        //drive all signals going into dte to 0, shoudl just be memvalid right?
        //also need to give it a scheudler pick, no_req in this case
        rst = 0;  //active low
        mem_2_dte.mem_Ready = 0;
        bestPick_req_2_dte = NO_REQ;
        bestPick_bk_id_2_dte = 0;
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
